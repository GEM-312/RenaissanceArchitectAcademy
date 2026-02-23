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
}
