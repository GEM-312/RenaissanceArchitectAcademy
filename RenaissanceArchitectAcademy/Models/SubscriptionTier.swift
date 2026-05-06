import Foundation

/// The three subscription tiers a player can choose at the end of onboarding.
/// Apprentice is one-time; Plus and Premium are monthly/annual subscriptions.
enum SubscriptionTier: String, Codable, CaseIterable, Identifiable {
    case apprentice
    case plus
    case premium

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .apprentice: return "Apprentice"
        case .plus:       return "Plus"
        case .premium:    return "Premium"
        }
    }

    var italianName: String {
        switch self {
        case .apprentice: return "Apprendista"
        case .plus:       return "Compagno"
        case .premium:    return "Maestro"
        }
    }

    /// One-line tagline shown under the tier name on the picker card.
    var tagline: String {
        switch self {
        case .apprentice: return "Begin your apprenticeship."
        case .plus:       return "Travel with the bird as your living companion."
        case .premium:    return "Hear every voice across the journey."
        }
    }

    /// Bullet list of what the tier unlocks. Order matters — most-impactful first.
    var features: [String] {
        switch self {
        case .apprentice:
            return [
                "All 17 buildings — Ancient Rome + Renaissance Italy",
                "Read-to-Earn lessons across 13 sciences",
                "Sketching, crafting, and construction puzzles",
                "Wolfram math and PubMed reference (free APIs)",
                "Yours forever — no subscription",
            ]
        case .plus:
            return [
                "Everything in Apprentice",
                "Bird AI companion — ask questions, get hints",
                "Storyteller voice on every knowledge card",
                "Priority on new content as it ships",
            ]
        case .premium:
            return [
                "Everything in Plus",
                "Bird speaks her replies aloud",
                "Future Architect-level content as it lands",
                "Early access to new buildings and characters",
            ]
        }
    }

    // MARK: - Feature gates

    /// Plus and Premium can chat with the bird. Apprentice cannot.
    var canChat: Bool { self != .apprentice }

    /// Plus and Premium can play the storyteller voice on knowledge cards.
    var canPlayStorytellerVoice: Bool { self != .apprentice }

    /// Only Premium gets the bird's voice speaking chat replies.
    var canHearBirdVoice: Bool { self == .premium }
}

/// Billing plan for a tier. Apprentice is always `.oneTime`.
enum SubscriptionPlan: String, Codable {
    case oneTime
    case monthly
    case annual
}

/// Pricing the picker displays. These are baseline values — the live numbers
/// will come from `Product.displayPrice` once StoreKit 2 is wired in. The
/// strings here are the fallbacks for previews and pre-StoreKit builds.
enum SubscriptionPricing {
    static let apprenticeOneTime = "$9.99"
    static let plusMonthly       = "$4.99"
    static let plusAnnual        = "$39.99"   // ~$3.33/mo, 33% off monthly
    static let premiumMonthly    = "$9.99"
    static let premiumAnnual     = "$79.99"   // ~$6.66/mo, 33% off monthly
}

/// App Store Connect product IDs. Register these matching strings in ASC under
/// the same bundle ID before submitting. Until then, `SubscriptionManager`
/// uses a mock purchase flow.
enum SubscriptionProductID {
    static let apprentice     = "com.marinapollak.RenaissanceArchitectAcademy.apprentice"
    static let plusMonthly    = "com.marinapollak.RenaissanceArchitectAcademy.plus_monthly"
    static let plusAnnual     = "com.marinapollak.RenaissanceArchitectAcademy.plus_annual"
    static let premiumMonthly = "com.marinapollak.RenaissanceArchitectAcademy.premium_monthly"
    static let premiumAnnual  = "com.marinapollak.RenaissanceArchitectAcademy.premium_annual"
}
