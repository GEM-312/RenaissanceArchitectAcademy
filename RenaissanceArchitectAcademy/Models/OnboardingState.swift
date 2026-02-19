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
@Observable
class OnboardingState {
    /// Whether the full onboarding story has been completed (persisted)
    var hasCompletedOnboarding: Bool {
        didSet { UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding") }
    }

    /// Player's chosen gender (persisted)
    var apprenticeGender: ApprenticeGender {
        didSet { UserDefaults.standard.set(apprenticeGender.rawValue, forKey: "apprenticeGender") }
    }

    /// Player's chosen name (persisted)
    var apprenticeName: String {
        didSet { UserDefaults.standard.set(apprenticeName, forKey: "apprenticeName") }
    }

    init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        self.apprenticeGender = ApprenticeGender(rawValue: UserDefaults.standard.string(forKey: "apprenticeGender") ?? "") ?? .boy
        self.apprenticeName = UserDefaults.standard.string(forKey: "apprenticeName") ?? ""
    }

    /// Mark onboarding as complete
    func completeOnboarding() {
        hasCompletedOnboarding = true
    }
}
