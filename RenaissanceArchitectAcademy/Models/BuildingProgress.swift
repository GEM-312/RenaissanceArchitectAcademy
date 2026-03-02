import Foundation

/// Player's choice when tapping a building — the 3-card game loop menu
enum BuildingCardChoice: String, CaseIterable {
    case readToEarn = "Read to Earn"
    case environments = "Explore Environments"
    case readyToBuild = "Ready to Build"

    var icon: String {
        switch self {
        case .readToEarn: return "book.fill"
        case .environments: return "hammer.fill"
        case .readyToBuild: return "checkmark.shield.fill"
        }
    }

    var subtitle: String {
        switch self {
        case .readToEarn: return "Learn & earn florins"
        case .environments: return "Workshop · Crafting · Forest"
        case .readyToBuild: return "Check requirements"
        }
    }
}

/// Tracks per-building progress toward construction
struct BuildingProgress {
    var scienceBadgesEarned: Set<Science> = []
    var sketchCompleted: Bool = false
    var quizPassed: Bool = false
    var lessonRead: Bool = false
    var lessonSectionIndex: Int = 0  // Bookmark: which section the student is on
    var constructionSequenceCompleted: Bool = false
    var completedCardIDs: Set<String> = []    // Knowledge cards completed (deterministic IDs)
}

/// Reward constants for the game economy
enum GameRewards {
    static let lessonReadFlorins = 10
    static let quizPassFlorins = 25
    static let sketchCompleteFlorins = 15
    static let buildCompleteFlorins = 50
    static let timberCollectFlorins = 1
    static let craftCompleteFlorins = 5
    static let masterAssignmentFlorins = 15
    static let jobCompleteFlorins = 10       // Base bonus on top of job.rewardFlorins
    static let jobStreakBonus = 5             // Extra per consecutive job completed
    static let scienceCardMatchFlorins = 2   // Per correct keyword match on forest cards
    static let constructionSequenceFlorins = 20
    static let toolCraftFlorins = 3             // Bonus florins for crafting a tool
    static let toolBuyBaseCost = 10             // Cost to buy a tool at the market
}
