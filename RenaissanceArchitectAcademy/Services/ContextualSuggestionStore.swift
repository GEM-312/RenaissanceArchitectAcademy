import SwiftUI

/// Session-scoped cache for [[ContextualSuggestionService]] output.
///
/// Both bird surfaces (city-entry guidance + bird chat first-message) read
/// from this same cache so the service is called at most once per session,
/// and so the suggestion stays coherent across views.
///
/// Lifecycle:
/// - `refreshIfNeeded()` runs the service once per session (or every time
///   when `force: true`, used by the debug button).
/// - `current` is non-nil while a suggestion is active.
/// - `markShownInGuidance()` prevents the city-entry overlay from re-firing
///   every time `showCityGuidance()` runs during gameplay.
/// - `dismiss()` clears the suggestion when the user takes the action or
///   taps "Not now".
@MainActor
@Observable
final class ContextualSuggestionStore {

    static let shared = ContextualSuggestionStore()

    private(set) var current: ContextualSuggestionPayload?
    private(set) var hasShownInGuidance: Bool = false
    private var hasRunThisSession: Bool = false
    private var inFlight: Bool = false

    private init() {}

    /// Run the service check once per session. With `force: true`, bypasses
    /// the session gate and the 24h service throttle.
    func refreshIfNeeded(force: Bool = false) async {
        if inFlight { return }
        if !force && hasRunThisSession { return }
        inFlight = true
        defer { inFlight = false }
        hasRunThisSession = true

        let outcome = await ContextualSuggestionService.check(force: force)
        switch outcome {
        case .suggestion(let payload):
            current = payload
            if force {
                // Debug retest path — let it surface in guidance again
                hasShownInGuidance = false
            }
        case .noRelevantEvents, .throttled, .unavailable:
            break
        }
    }

    /// Mark that the city-entry overlay has shown the current suggestion,
    /// so it doesn't pop again on every guidance fire during this session.
    func markShownInGuidance() {
        hasShownInGuidance = true
    }

    /// Clear the active suggestion (e.g. when the user dismisses or routes
    /// to the lesson).
    func dismiss() {
        current = nil
    }

    /// DEBUG: reset everything so the next refresh runs cleanly.
    func reset() {
        current = nil
        hasShownInGuidance = false
        hasRunThisSession = false
    }
}
