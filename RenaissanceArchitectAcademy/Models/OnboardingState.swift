import SwiftUI

/// Gender choice for the apprentice character
enum ApprenticeGender: String, CaseIterable {
    case boy = "boy"
    case girl = "girl"

    var displayName: String {
        switch self {
        case .boy: return "Young Man"
        case .girl: return "Young Woman"
        }
    }
}

/// Persistent onboarding state — tracks whether the player has completed the intro sequence
@MainActor
@Observable
class OnboardingState {
    /// Whether the full onboarding story has been completed
    var hasCompletedOnboarding: Bool = false {
        didSet { persistToSwiftData() }
    }

    /// Player's chosen gender
    var apprenticeGender: ApprenticeGender = .boy {
        didSet { persistToSwiftData() }
    }

    /// Player's chosen name
    var apprenticeName: String = "" {
        didSet { persistToSwiftData() }
    }

    /// Guards against writing back during load
    private var isLoading = false
    private var persistenceManager: PersistenceManager?

    init() {}

    /// Load saved state from SwiftData (called once from ContentView)
    func loadFromSwiftData(manager: PersistenceManager) {
        self.persistenceManager = manager
        isLoading = true
        let save = manager.loadPlayerSave()
        hasCompletedOnboarding = save.hasCompletedOnboarding
        apprenticeGender = save.gender
        apprenticeName = save.apprenticeName
        isLoading = false
    }

    /// Mark onboarding as complete
    func completeOnboarding() {
        hasCompletedOnboarding = true
    }

    private func persistToSwiftData() {
        guard !isLoading, let manager = persistenceManager else { return }
        let save = manager.loadPlayerSave()
        save.hasCompletedOnboarding = hasCompletedOnboarding
        save.gender = apprenticeGender
        save.apprenticeName = apprenticeName
        save.lastSaved = Date()
        manager.save()
    }
}
