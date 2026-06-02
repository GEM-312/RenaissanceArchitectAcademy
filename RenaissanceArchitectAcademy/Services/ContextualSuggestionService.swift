import Foundation
import EventKit
#if canImport(FoundationModels)
import FoundationModels
#endif

/// Looks at the user's upcoming calendar events and surfaces a building tie-in.
///
/// Architecture (revised 2026-06-02): **code does the matching, the on-device
/// model only writes the prose.** Combining tool-calling with guided generation
/// crashes Apple's on-device model (it emits tool-call JSON into the structured
/// output → decode failure). So Swift ranks the events, picks the best one, and
/// finds the candidate buildings (subject → Science map); the model just picks
/// among a short list and writes a warm one-line reason. The date is computed in
/// code and prepended, so it's always correct.
///
/// Privacy: all on-device (EventKit + Apple FM). If access is denied or FM is
/// unavailable, returns silently.
///
/// Throttling: 24h via UserDefaults (debug button forces).
enum ContextualSuggestionService {

    /// UserDefaults key for the timestamp of the last successful check.
    static let lastCheckDateKey = "ContextualSuggestion.lastCheckDate"

    /// Minimum interval between proactive checks.
    private static let checkInterval: TimeInterval = 60 * 60 * 24 // 24h

    /// How far ahead to look for events.
    private static let lookaheadDays = 7

    enum Outcome {
        case suggestion(ContextualSuggestionPayload)
        case noRelevantEvents
        case throttled
        case unavailable(reason: String)
    }

    /// Run the proactive check. Safe to call on app launch.
    /// - Parameter force: bypass the 24h throttle (used by debug button + city entry).
    static func check(force: Bool = false) async -> Outcome {
        print("[ContextualSuggestionService] check() called force=\(force)")

        // 1) Throttle gate
        if !force, let last = UserDefaults.standard.object(forKey: lastCheckDateKey) as? Date,
           Date().timeIntervalSince(last) < checkInterval {
            print("[ContextualSuggestionService] throttled — last check was \(last)")
            return .throttled
        }

        // 2) OS / FM availability gate
        if #available(iOS 26.0, macOS 26.0, *) {
            // proceed
        } else {
            print("[ContextualSuggestionService] unavailable — pre-iOS 26")
            return .unavailable(reason: "Requires iOS 26 or later")
        }

        // 3) Fetch events
        let events: [CalendarEvent]
        do {
            events = try await fetchUpcomingEvents()
            print("[ContextualSuggestionService] fetched \(events.count) events")
        } catch {
            print("[ContextualSuggestionService] event fetch failed: \(error)")
            return .unavailable(reason: "Calendar access not granted")
        }

        // 4) Rank events by game-relevance. A real calendar is mostly noise
        // (meals, gym, generic work) — we only want events that connect to a
        // building, and we must NOT let chronological order bury a great match
        // (e.g. a Friday museum) behind today's lunch.
        let ranked = events
            .map { (event: $0, score: relevanceScore($0)) }
            .filter { $0.score > 0 }
            .sorted { $0.score != $1.score ? $0.score > $1.score : $0.event.startDate < $1.event.startDate }

        guard let best = ranked.first else {
            print("[ContextualSuggestionService] no game-relevant events among \(events.count)")
            if !force { stampCheck() }
            return .noRelevantEvents
        }

        let venue = VenueGuide.match(eventText: best.event.combinedSearchText)
        var candidates = candidateBuildings(for: best.event)
        // If we recognize the real venue/city, make its building the top candidate
        // (and ensure it's present even when keyword matching found nothing).
        if let v = venue, let topic = BuildingTopicMap.topic(forBuildingId: v.buildingId) {
            candidates = [topic] + candidates.filter { $0.buildingId != v.buildingId }
        }
        print("[ContextualSuggestionService] top event '\(best.event.title)' (score \(best.score)) venue=\(venue?.displayName ?? "—") → candidates: \(candidates.map { $0.buildingName })")
        guard !candidates.isEmpty else {
            if !force { stampCheck() }
            return .noRelevantEvents
        }

        // 5) The model only writes the reason prose (no tools — tools + guided
        // generation crash the on-device model). Returns .suggestion, .noRelevantEvents
        // (declined), or nil (FM unavailable/failed → deterministic fallback).
        if #available(iOS 26.0, macOS 26.0, *) {
            if let outcome = await runFoundationModelsWrite(event: best.event, candidates: candidates, venue: venue) {
                if !force { stampCheck() }
                return outcome
            }
        }

        // 6) FM unavailable/failed — deterministic fallback (still names the event).
        let fallback = deterministicFallback(event: best.event, candidates: candidates)
        if !force { stampCheck() }
        return .suggestion(withTiming(fallback, event: best.event))
    }

    // MARK: - EventKit

    /// Minimal value type so the rest of the service doesn't depend on EKEvent.
    fileprivate struct CalendarEvent {
        let title: String
        let location: String
        let notes: String
        let startDate: Date

        var combinedSearchText: String {
            [title, location, notes].filter { !$0.isEmpty }.joined(separator: " — ")
        }
    }

    private static func fetchUpcomingEvents() async throws -> [CalendarEvent] {
        let eventStore = EKEventStore()
        let granted = try await eventStore.requestFullAccessToEvents()
        guard granted else {
            throw NSError(domain: "ContextualSuggestionService", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "Calendar access denied"])
        }

        let calendars = eventStore.calendars(for: .event)
        let start = Date()
        guard let end = Calendar.current.date(byAdding: .day, value: lookaheadDays, to: start) else {
            return []
        }
        let predicate = eventStore.predicateForEvents(withStart: start, end: end, calendars: calendars)
        let raw = eventStore.events(matching: predicate)
        return raw.map {
            CalendarEvent(
                title: $0.title ?? "",
                location: $0.location ?? "",
                notes: $0.notes ?? "",
                startDate: $0.startDate
            )
        }
    }

    // MARK: - Matching (in code — reliable)

    /// How game-relevant an event is. 0 = ignore (meals, gym, generic work).
    private static func relevanceScore(_ e: CalendarEvent) -> Int {
        let t = e.combinedSearchText.lowercased()
        var score = 0
        if BuildingTopicMap.all.contains(where: { $0.keywords.contains { t.contains($0.lowercased()) } }) { score += 3 }
        if !sciences(forSubject: t).isEmpty { score += 2 }
        if BuildingTopicMap.broadCultureKeywords.contains(where: { t.contains($0.lowercased()) }) { score += 1 }
        if BuildingTopicMap.italyTravelKeywords.contains(where: { t.contains($0.lowercased()) }) { score += 1 }
        if VenueGuide.match(eventText: t) != nil { score += 3 }
        return score
    }

    /// The buildings that genuinely connect to one event: direct keyword hits,
    /// then subject→science matches, then a museum/art or Italy-travel widening.
    private static func candidateBuildings(for e: CalendarEvent) -> [BuildingTopic] {
        let t = e.combinedSearchText.lowercased()
        var ids = Set<Int>()
        var result: [BuildingTopic] = []
        func add(_ topic: BuildingTopic) { if ids.insert(topic.buildingId).inserted { result.append(topic) } }

        // 1. direct building-keyword matches
        for topic in BuildingTopicMap.all where topic.keywords.contains(where: { t.contains($0.lowercased()) }) {
            add(topic)
        }

        // 2. subject → science → buildings
        let sci = Set(sciences(forSubject: t))
        if !sci.isEmpty {
            for topic in BuildingTopicMap.all {
                if let s = BuildingTopicMap.sciencesByBuilding[topic.buildingId], !Set(s).isDisjoint(with: sci) {
                    add(topic)
                }
            }
        }

        // 3. generic museum/gallery/art → art-leaning buildings
        if result.isEmpty, BuildingTopicMap.broadCultureKeywords.contains(where: { t.contains($0.lowercased()) }) {
            let artSci: Set<Science> = [.architecture, .geometry, .optics]
            for topic in BuildingTopicMap.all {
                if let s = BuildingTopicMap.sciencesByBuilding[topic.buildingId], !Set(s).isDisjoint(with: artSci) {
                    add(topic)
                }
            }
        }

        // 4. Italy travel with no specific city → any building
        if result.isEmpty, BuildingTopicMap.italyTravelKeywords.contains(where: { t.contains($0.lowercased()) }) {
            for topic in BuildingTopicMap.all { add(topic) }
        }

        return Array(result.prefix(6))
    }

    /// Map a free-text subject/theme to the relevant Sciences.
    static func sciences(forSubject raw: String) -> [Science] {
        let s = raw.lowercased()
        func has(_ terms: String...) -> Bool { terms.contains { s.contains($0) } }
        var out: Set<Science> = []
        if has("math", "algebra", "calculus", "arithmetic", "trig") { out.formUnion([.mathematics, .geometry]) }
        if has("geometry") { out.formUnion([.geometry, .mathematics]) }
        if has("physic") { out.insert(.physics) }
        if has("chem") { out.insert(.chemistry) }
        if has("bio", "anatomy", "life science", "medicine", "medical") { out.insert(.biology) }
        if has("geolog", "earth science", "rocks", "mineral") { out.insert(.geology) }
        if has("astronom", "space", "stars", "planet", "cosmos") { out.insert(.astronomy) }
        if has("optic", "light", "lens", "vision") { out.insert(.optics) }
        if has("acoustic", "sound", "music") { out.insert(.acoustics) }
        if has("hydraulic", "water", "plumbing", "fluid") { out.insert(.hydraulics) }
        if has("material") { out.insert(.materials) }
        if has("engineer", "robot", "mechan", "technolog") { out.formUnion([.engineering, .physics]) }
        if has("architect", "design") { out.formUnion([.architecture, .engineering]) }
        if has("art", "draw", "paint", "sketch", "sculpt", "studio") { out.formUnion([.architecture, .geometry, .optics]) }
        if has("history", "ancient", "roman", "renaissance", "classic") { out.formUnion([.architecture, .engineering, .materials]) }
        return Array(out)
    }

    // MARK: - Timing (deterministic — always correct, never the model's job)

    /// Human timing label for a date.
    private static func displayTiming(for date: Date) -> String {
        let cal = Calendar.current
        let days = cal.dateComponents([.day], from: cal.startOfDay(for: Date()), to: cal.startOfDay(for: date)).day ?? 0
        switch days {
        case ..<0:   return "Coming up"
        case 0:      return "Today"
        case 1:      return "Tomorrow"
        case 2...6:  return "This \(date.formatted(.dateTime.weekday(.wide)))"
        case 7...13: return "Next week"
        default:     return "On \(date.formatted(date: .abbreviated, time: .omitted))"
        }
    }

    /// Prepend the correct, code-computed timing to the model's date-free reason.
    private static func withTiming(_ p: ContextualSuggestionPayload, event: CalendarEvent) -> ContextualSuggestionPayload {
        var out = p
        out.reason = "\(displayTiming(for: event.startDate)) — \(p.reason)"
        return out
    }

    /// A natural opener that names the event/venue — computed in code because the
    /// small on-device model won't reliably do it. Returns "" when we have nothing
    /// clean to name (trailing space included for direct prepending).
    private static func occasionLead(event: CalendarEvent, venue: VenueHighlight?) -> String {
        if let v = venue { return "Off to \(v.displayName)? " }
        let t = event.combinedSearchText.lowercased()
        if t.contains("museum") { return "Off to the museum? " }
        if t.contains("gallery") { return "Off to the gallery? " }
        if t.contains("exhibit") { return "Off to the exhibit? " }
        return ""
    }

    // MARK: - Foundation Models (prose only — NO tools)

    @available(iOS 26.0, macOS 26.0, *)
    private static func runFoundationModelsWrite(
        event: CalendarEvent,
        candidates: [BuildingTopic],
        venue: VenueHighlight?
    ) async -> Outcome? {
        guard case .available = SystemLanguageModel.default.availability else {
            print("[ContextualSuggestionService] FM not available — \(SystemLanguageModel.default.availability)")
            return nil
        }

        let prompt = buildPrompt(event: event, candidates: candidates, venue: venue)
        let instructions = Instructions("""
            You are a warm, playful bird companion in an educational game about \
            Renaissance and Roman architecture, sent by Maestro Leonardo da Vinci.

            The player has ONE upcoming real-world event (a class, exam, museum, or \
            trip). You are given a short list of game buildings that connect to it. \
            Pick the buildingId from that list that fits best, and write a warm 1-2 \
            sentence 'reason' (under 200 characters).

            FRAMING: the player is going to the REAL event/venue — NOT the game \
            building. Do NOT name the event, venue, or any timing word — those are \
            added automatically. Just write the recommendation: what to LOOK FOR or \
            notice there, tied back to the building. If the prompt gives venue \
            highlights, recommend ONE of those specifically; otherwise give honest \
            general advice (e.g. "look for the Renaissance paintings and notice their \
            geometry"). Example reason: "Find the Renaissance paintings — the same \
            geometry Brunelleschi used on our Duomo dome. Want a peek first?"

            Do NOT write any date or timing words (today, tomorrow, a weekday) — the \
            timing is added automatically. Use only honest, well-known facts; never \
            invent exhibitions or specifics beyond the highlights you're given. Set \
            isRelevant = false ONLY if none of the listed buildings honestly fit.

            Set urgencyScore 1-10 (higher = sooner). Choose suggestedAction: \
            openLesson (deeper reading), openCards (quick facts), or openSketching \
            (a drawing activity). Speak in the bird's voice — warm and curious.
            """)

        do {
            let session = LanguageModelSession(instructions: instructions)
            session.prewarm()
            let response = try await session.respond(to: prompt, generating: ContextualSuggestion.self)

            guard response.content.isRelevant else {
                print("[ContextualSuggestionService] FM declined — no honest tie-in")
                return .noRelevantEvents
            }

            // Keep the pick on the candidate list; if the model strays, use the top one.
            let validIds = Set(candidates.map { $0.buildingId })
            var payload = response.content.toPayload()
            if !validIds.contains(payload.buildingId) {
                print("[ContextualSuggestionService] FM picked off-list id=\(payload.buildingId) → using top candidate")
                payload.buildingId = candidates[0].buildingId
                payload.booksSearchQuery = candidates[0].suggestedBookQuery
            }
            print("[ContextualSuggestionService] FM picked buildingId=\(payload.buildingId) urgency=\(response.content.urgencyScore)")
            // Code owns the facts: timing + the event/venue name, prepended to the
            // model's recommendation prose.
            payload.reason = "\(displayTiming(for: event.startDate)) — \(occasionLead(event: event, venue: venue))\(payload.reason)"
            return .suggestion(payload)
        } catch {
            print("[ContextualSuggestionService] FM write failed: \(error)")
            return nil
        }
    }

    private static func buildPrompt(event: CalendarEvent, candidates: [BuildingTopic], venue: VenueHighlight?) -> String {
        let candidateLines = candidates.map { c -> String in
            let sci = (BuildingTopicMap.sciencesByBuilding[c.buildingId] ?? []).map(\.rawValue).joined(separator: ", ")
            return "• id=\(c.buildingId) \(c.buildingName) (\(c.city)) — teaches \(sci); topics: \(c.keywords.prefix(4).joined(separator: ", "))"
        }.joined(separator: "\n")

        var venueBlock = ""
        if let v = venue {
            venueBlock = """

                The player is visiting \(v.displayName). Real things to look for there: \
                \(v.highlights). Recommend this in your reason and connect it to the building.
                """
        }

        return """
            The player's upcoming event:
            "\(event.combinedSearchText)"
            \(venueBlock)
            Game buildings that connect to it — choose the buildingId of the best fit:
            \(candidateLines)

            Pick the single best building from the list and write the 'reason'.
            """
    }

    // MARK: - Deterministic fallback (FM unavailable/failed)

    /// Names the real event + the top code-matched building. Used only when the
    /// model can't run.
    private static func deterministicFallback(
        event: CalendarEvent,
        candidates: [BuildingTopic]
    ) -> ContextualSuggestionPayload {
        let best = candidates[0]
        let label = event.title.isEmpty ? "your upcoming event" : event.title
        return ContextualSuggestionPayload(
            buildingId: best.buildingId,
            reason: "I noticed \(label) — our \(best.buildingName) in \(best.city) connects beautifully. Want to explore?",
            urgencyScore: 5,
            eventTopicLabel: label,
            suggestedAction: .openLesson,
            booksSearchQuery: best.suggestedBookQuery
        )
    }

    // MARK: - Throttle stamp

    private static func stampCheck() {
        UserDefaults.standard.set(Date(), forKey: lastCheckDateKey)
    }

    /// Debug helper — clears the throttle stamp so the next check runs.
    static func clearThrottle() {
        UserDefaults.standard.removeObject(forKey: lastCheckDateKey)
    }
}
