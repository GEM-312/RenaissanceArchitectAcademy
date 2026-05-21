import Foundation
import EventKit
#if canImport(FoundationModels)
import FoundationModels
#endif

/// Looks at the user's upcoming calendar events, finds overlap with the 17
/// game buildings via [[BuildingTopicMap]], then asks Foundation Models to
/// pick the best match and write a personalized "why" in the bird's voice.
///
/// Privacy:
/// - All processing is on-device (EventKit + Apple FM).
/// - If calendar access is denied or FM is unavailable, returns nil silently.
///
/// Throttling: hard-gated to once per 24 hours via UserDefaults so the user
/// isn't pestered. Caller can force a check by clearing `lastCheckDateKey`.
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
    /// - Parameter force: bypass the 24h throttle (used by debug button).
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
            for e in events.prefix(10) {
                print("  · \(e.startDate.formatted(date: .abbreviated, time: .omitted)): \(e.combinedSearchText)")
            }
        } catch {
            print("[ContextualSuggestionService] event fetch failed: \(error)")
            return .unavailable(reason: "Calendar access not granted")
        }

        if events.isEmpty {
            print("[ContextualSuggestionService] no events in next 7 days")
            stampCheck()
            return .noRelevantEvents
        }

        // 4) Keyword pre-filter against the topic map
        let combinedText = events.map { $0.combinedSearchText }.joined(separator: "\n")
        let candidates = BuildingTopicMap.match(eventText: combinedText)
        print("[ContextualSuggestionService] keyword matches: \(candidates.count) — \(candidates.map { $0.buildingName })")

        guard !candidates.isEmpty else {
            print("[ContextualSuggestionService] no candidates — no keyword overlap with any building")
            stampCheck()
            return .noRelevantEvents
        }

        // 5) Hand to Foundation Models for picking + reasoning
        if #available(iOS 26.0, macOS 26.0, *) {
            if let suggestion = await runFoundationModelsPick(
                events: events,
                candidates: candidates
            ) {
                stampCheck()
                return .suggestion(suggestion)
            }
        }

        // 6) FM not available or failed — graceful deterministic fallback
        let fallback = deterministicFallback(events: events, candidates: candidates)
        stampCheck()
        return .suggestion(fallback)
    }

    // MARK: - EventKit

    /// Minimal value type so the rest of the service doesn't depend on EKEvent.
    private struct CalendarEvent {
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

    // MARK: - Foundation Models reasoning

    @available(iOS 26.0, macOS 26.0, *)
    private static func runFoundationModelsPick(
        events: [CalendarEvent],
        candidates: [BuildingTopic]
    ) async -> ContextualSuggestionPayload? {
        // Direct availability check (avoids hopping to MainActor for AppleAIService.isAvailable)
        guard case .available = SystemLanguageModel.default.availability else {
            print("[ContextualSuggestionService] FM not available — \(SystemLanguageModel.default.availability)")
            return nil
        }
        print("[ContextualSuggestionService] FM available, running session.respond with \(candidates.count) candidates")

        let prompt = buildPrompt(events: events, candidates: candidates)
        let instructions = Instructions("""
            You are a warm, playful bird companion in an educational game about \
            Renaissance and Roman architecture. Maestro Leonardo da Vinci sent you.

            CRITICAL FRAMING: The player has a REAL-WORLD calendar event coming up \
            (a museum, a trip, a class). They are going THERE — to the real venue. \
            They are NOT going to the game building. The game building is the LEARNING \
            CONNECTION between their real-world visit and our game lessons.

            The 'reason' field MUST follow this structure (under 220 characters):
            "At [calendar event venue, verbatim], [something specific to look for, see, \
            or notice — from your stable training knowledge]. [Brief tie-in to the chosen \
            game building]."

            GOOD example (player has 'Visit Art Institute of Chicago' tomorrow):
            "At the Art Institute, find the Italian Renaissance galleries — Botticelli's \
            drawings show the line work Leonardo uses on our Duomo dome! Want to preview?"

            BAD example — DO NOT WRITE THIS:
            "Tomorrow you'll explore the Vatican Observatory!" — WRONG. The player isn't \
            going to the game's Vatican Observatory. They're going to a real venue in \
            their calendar. The game building is just the lesson tie-in.

            For named venues you recognize (Art Institute of Chicago, the Met, Uffizi, \
            Louvre, MoMA, Vatican Museums, etc.): use your stable training knowledge to \
            name ONE specific permanent-collection work, gallery, or section to look for. \
            Examples: "Botticelli drawings", "Italian Renaissance galleries", "Renaissance \
            bronzes section", "Caravaggio rooms".

            For travel events to a city: suggest ONE well-known historic site or artwork \
            in that real city tied to the game building. Example: "While in Florence, \
            walk past Piazza del Duomo — Brunelleschi's dome looms exactly as in our game."

            DO NOT fabricate current exhibitions, room numbers, prices, hours, or anything \
            you can't verify. Only mention permanent-collection works and historic sites \
            you're confident about from training knowledge.

            Use the relative timing label on each event line for TONE:
            - Today / Tomorrow → excited urgency
            - In 1-2 weeks → friendly preparation
            - In 3+ weeks → gentle, "save this for later"

            Set urgencyScore (1-10): 7-10 if today/tomorrow, 4-6 if 1-2 weeks, 1-3 if \
            more than two weeks away.

            Only choose a buildingId from the candidates list. Speak in the bird's voice \
            — warm, curious, occasionally referencing Maestro Leonardo.
            """)

        do {
            let session = LanguageModelSession(instructions: instructions)
            session.prewarm()
            let response = try await session.respond(
                to: prompt,
                generating: ContextualSuggestion.self
            )

            let validIds = Set(candidates.map { $0.buildingId })
            guard validIds.contains(response.content.buildingId) else {
                // Model picked something off-menu — fall back to hand-built suggestion.
                print("[ContextualSuggestionService] FM picked invalid buildingId=\(response.content.buildingId), falling back to deterministic")
                return nil
            }
            print("[ContextualSuggestionService] FM picked buildingId=\(response.content.buildingId) action=\(response.content.suggestedAction) urgency=\(response.content.urgencyScore)")
            return response.content.toPayload()
        } catch {
            print("[ContextualSuggestionService] FM pick failed: \(error)")
            return nil
        }
    }

    private static func buildPrompt(
        events: [CalendarEvent],
        candidates: [BuildingTopic]
    ) -> String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        let eventLines = events.prefix(10).map { e -> String in
            let dayFmt = e.startDate.formatted(date: .abbreviated, time: .omitted)
            let eventDay = calendar.startOfDay(for: e.startDate)
            let daysAway = calendar.dateComponents([.day], from: today, to: eventDay).day ?? 0
            let relative: String
            switch daysAway {
            case ..<0:    relative = "Past"
            case 0:       relative = "Today"
            case 1:       relative = "Tomorrow"
            case 2:       relative = "Day after tomorrow"
            case 3...6:   relative = "In \(daysAway) days"
            case 7...13:  relative = "Next week"
            case 14...20: relative = "In ~2 weeks"
            case 21...27: relative = "In ~3 weeks"
            case 28...60: relative = "In about a month"
            default:      relative = "More than a month away"
            }
            return "• \(relative) (\(dayFmt)): \(e.combinedSearchText)"
        }.joined(separator: "\n")

        let candidateLines = candidates.prefix(10).map { c -> String in
            "• id=\(c.buildingId) name=\(c.buildingName) city=\(c.city) keywords=[\(c.keywords.prefix(5).joined(separator: ", "))]"
        }.joined(separator: "\n")

        return """
            The player's upcoming calendar events (with relative timing):
            \(eventLines)

            Candidate buildings from the game whose topics overlap with these events:
            \(candidateLines)

            Pick the single most relevant building. Write a short 'reason' (under 220 \
            characters, the bird's voice) explaining why this building connects to \
            what the player has coming up. Use the relative timing in your tone and \
            urgencyScore. Choose suggestedAction based on what would be most useful: \
            openLesson for deeper reading, openCards for quick facts, openSketching if \
            a hands-on drawing activity fits.
            """
    }

    // MARK: - Deterministic fallback

    /// Used when FM is unavailable or returned an invalid pick.
    /// Picks the candidate building with the most keyword hits.
    private static func deterministicFallback(
        events: [CalendarEvent],
        candidates: [BuildingTopic]
    ) -> ContextualSuggestionPayload {
        let combined = events.map { $0.combinedSearchText }.joined(separator: " ").lowercased()

        let scored = candidates.map { topic -> (BuildingTopic, Int) in
            let hits = topic.keywords.reduce(0) { acc, kw in
                acc + (combined.contains(kw.lowercased()) ? 1 : 0)
            }
            return (topic, hits)
        }
        let best = scored.max(by: { $0.1 < $1.1 })?.0 ?? candidates[0]

        let topicLabel: String
        if let event = events.first(where: { ev in
            best.keywords.contains { ev.combinedSearchText.lowercased().contains($0.lowercased()) }
        }) {
            topicLabel = event.title.isEmpty ? "your upcoming event" : event.title
        } else {
            topicLabel = "your upcoming event"
        }

        return ContextualSuggestionPayload(
            buildingId: best.buildingId,
            reason: "I noticed \(topicLabel) on your schedule — \(best.buildingName) in \(best.city) connects beautifully. Want to explore?",
            urgencyScore: 5,
            eventTopicLabel: topicLabel,
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
