import SwiftUI

/// Wipes player data across every storage layer the app uses. Two scopes:
///
/// - `wipeOnboardingOnly()` — clears the onboarding-completion flag and the
///   subscription tier so the picker re-fires. Keeps game progress, settings,
///   and inventory. DEBUG / dev tool.
///
/// - `wipeAllData()` — full reset: SwiftData (PlayerSave, BuildingProgressRecord,
///   LessonRecord), every known UserDefaults key, and the on-disk TTS cache.
///   Apple-side subscription receipts are NOT touched — the user can hit
///   Restore Purchase after re-onboarding to recover their tier.
@MainActor
enum DataManagementService {

    /// All UserDefaults keys this app writes to. Keep this list in sync with
    /// every `UserDefaults.standard.set(...)` site in the codebase.
    private static let userDefaultsKeys: [String] = [
        // GameSettings
        "gameSettings_theme",
        "gameSettings_musicVolume",
        "gameSettings_sfxVolume",
        "gameSettings_aiProvider",
        "gameSettings_hasChosenAIProvider",
        "gameSettings_language",
        "gameSettings_isSubscribed",
        "gameSettings_cardTextScale",
        // SubscriptionManager
        "subscription_tier",
        "subscription_plan",
        "subscription_purchasedAt",
        // ContentView one-time migrations (re-run on next launch — harmless)
        "didResetCorruptedSaves_v1",
        "didMigrateBuildingProgress_v2_cards",
    ]

    // MARK: - Onboarding-only reset (DEBUG)

    /// Clears just the onboarding flag and subscription tier so the next launch
    /// (or the next call to `OnboardingState.loadFromSwiftData`) treats the
    /// player as new. Keeps game progress, inventory, settings.
    static func wipeOnboardingOnly(persistence: PersistenceManager?,
                                   onboardingState: OnboardingState) {
        // SwiftData: clear the onboarding flag on the current PlayerSave
        if let manager = persistence {
            let save = manager.loadPlayerSave()
            save.hasCompletedOnboarding = false
            manager.save()
        }

        // In-memory state — set BEFORE clearing the subscription so the UI
        // observes a consistent reset.
        onboardingState.hasCompletedOnboarding = false

        // Subscription
        SubscriptionManager.shared.clearLocalState()
    }

    // MARK: - Full reset

    /// Full wipe across SwiftData, UserDefaults, and on-disk caches. The app
    /// should prompt the user to relaunch after this — too many in-memory
    /// view models hold stale references to the wiped state to safely
    /// continue running.
    static func wipeAllData(persistence: PersistenceManager?) {
        // SwiftData
        persistence?.resetAllData()

        // UserDefaults
        for key in userDefaultsKeys {
            UserDefaults.standard.removeObject(forKey: key)
        }

        // TTS cache directory
        if let cacheRoot = FileManager.default.urls(for: .cachesDirectory,
                                                    in: .userDomainMask).first {
            let ttsCache = cacheRoot.appendingPathComponent("TTSCache",
                                                            isDirectory: true)
            try? FileManager.default.removeItem(at: ttsCache)
        }

        // Subscription manager in-memory reset
        SubscriptionManager.shared.clearLocalState()
    }
}
