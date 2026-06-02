import Foundation
import EventKit

/// Builds a read-only snapshot of the student's upcoming calendar events for AI
/// personalization.
///
/// Non-gated (EventKit predates iOS 26) so the cloud `ClaudeService` — the
/// fallback when Apple Intelligence is unavailable — can fetch the schedule and
/// inject it into its system prompt, mirroring how progress/inventory snapshots
/// work. The on-device `CalendarTool` reuses the keyword list + formatter here,
/// so the wording lives in exactly one place.
enum CalendarSnapshot {

    /// Keywords that mark an event as relevant to game content: school work,
    /// museum/gallery visits, Italy travel, and Renaissance/Roman themes.
    static let educationKeywords: [String] = [
        // school
        "test", "exam", "quiz", "class", "school", "homework", "study",
        "project", "presentation", "field trip",
        // museum / gallery / cultural
        "museum", "gallery", "exhibit", "exhibition", "tour",
        // subject areas
        "science", "history", "math", "art", "architecture",
        "painting", "sculpture", "drawing",
        // themes the game maps to
        "renaissance", "roman", "ancient rome", "da vinci", "leonardo",
        "brunelleschi", "michelangelo", "galileo", "vesalius", "medici",
        // travel that overlaps with game cities
        "italy", "italia", "italian",
        "rome", "roma", "florence", "firenze", "venice", "venezia",
        "milan", "milano", "padua", "padova", "tuscany",
        "flight", "hotel", "reservation", "vacation", "trip", "travel"
    ]

    /// Format a list of events into a compact summary string. Assumes `events`
    /// is non-empty — callers handle the empty case (each wants a different reply).
    static func classify(events: [EKEvent], days: Int) -> String {
        var relevant: [String] = []
        var other: [String] = []

        for event in events {
            let title = event.title ?? "Untitled"
            let dateStr = event.startDate.formatted(date: .abbreviated, time: .shortened)
            let entry = "\(dateStr): \(title)"

            let isEducational = educationKeywords.contains { keyword in
                title.lowercased().contains(keyword)
            }
            if isEducational {
                relevant.append("📚 \(entry)")
            } else {
                other.append("📅 \(entry)")
            }
        }

        var result = "Upcoming events (next \(days) days):\n"
        if !relevant.isEmpty {
            result += "School-related:\n" + relevant.joined(separator: "\n") + "\n"
        }
        if !other.isEmpty {
            result += "Other:\n" + other.prefix(3).joined(separator: "\n")
        }
        return result
    }

    /// Read-only snapshot for system-prompt injection.
    ///
    /// Returns `nil` when access isn't granted or there are no upcoming events —
    /// the caller then omits the calendar block entirely (no nagging, no empty
    /// section). Prompts for calendar access exactly once if it's undetermined.
    static func upcoming(days: Int = 14) async -> String? {
        let store = EKEventStore()

        switch EKEventStore.authorizationStatus(for: .event) {
        case .fullAccess:
            break
        case .notDetermined:
            let granted = (try? await store.requestFullAccessToEvents()) ?? false
            guard granted else { return nil }
        default:
            return nil  // denied / restricted / writeOnly
        }

        let clamped = min(max(days, 1), 14)
        let start = Date()
        guard let end = Calendar.current.date(byAdding: .day, value: clamped, to: start) else {
            return nil
        }

        let predicate = store.predicateForEvents(withStart: start, end: end, calendars: nil)
        let events = store.events(matching: predicate)
        guard !events.isEmpty else { return nil }

        return classify(events: events, days: clamped)
    }
}
