import Foundation

/// Student mastery level based on the three learning modes
enum MasteryLevel: String, CaseIterable, Codable {
    case apprentice = "Apprentice"
    case architect = "Architect"
    case master = "Master"

    var icon: String {
        switch self {
        case .apprentice: return "📚"
        case .architect: return "🏛️"
        case .master: return "⭐"
        }
    }

    var description: String {
        switch self {
        case .apprentice: return "Learning the basics with guided tutorials"
        case .architect: return "Solving challenges with optional hints"
        case .master: return "True mastery - no hints, full accuracy"
        }
    }
}

/// Achievement badges - watercolor + blueprint style
struct Achievement: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let iconName: String
    let category: AchievementCategory
    var isUnlocked: Bool
    var dateUnlocked: Date?

    enum AchievementCategory: String, Codable, CaseIterable {
        case mathematics = "Mathematics"
        case physics = "Physics"
        case chemistry = "Chemistry"
        case geometry = "Geometry"
        case astronomy = "Astronomy"
        case general = "General"

        var color: String {
            switch self {
            case .mathematics: return "ochre"
            case .physics: return "renaissanceBlue"
            case .chemistry: return "sageGreen"
            case .geometry: return "terracotta"
            case .astronomy: return "deepTeal"
            case .general: return "warmBrown"
            }
        }
    }
}

/// Science mastery tracking for the 13+ sciences
struct ScienceMastery: Identifiable, Codable {
    let id: String
    let science: Science
    var level: Int // 0-100
    var challengesCompleted: Int
    var totalChallenges: Int

    var progressPercentage: Double {
        guard totalChallenges > 0 else { return 0 }
        return Double(challengesCompleted) / Double(totalChallenges)
    }
}

/// Resources the student has collected
struct Resources: Codable {
    var goldFlorins: Int
    var stoneBlocks: Int
    var woodPlanks: Int
    var pigmentJars: Int

    static let initial = Resources(
        goldFlorins: 100,
        stoneBlocks: 10,
        woodPlanks: 20,
        pigmentJars: 5
    )
}

/// Complete student profile
struct StudentProfile: Identifiable, Codable {
    let id: UUID
    var name: String
    var avatarName: String // SF Symbol or custom image name
    var masteryLevel: MasteryLevel
    var resources: Resources
    var achievements: [Achievement]
    var scienceMasteries: [ScienceMastery]
    var buildingsCompleted: Int
    var totalPlayTime: TimeInterval
    var dateJoined: Date
    var lastActive: Date

    // Computed properties
    var totalAchievements: Int {
        achievements.filter { $0.isUnlocked }.count
    }

    var overallProgress: Double {
        guard !scienceMasteries.isEmpty else { return 0 }
        let total = scienceMasteries.reduce(0.0) { $0 + $1.progressPercentage }
        return total / Double(scienceMasteries.count)
    }

    // Default profile for new students
    static func newStudent(name: String) -> StudentProfile {
        StudentProfile(
            id: UUID(),
            name: name,
            avatarName: "person.crop.circle.fill",
            masteryLevel: .apprentice,
            resources: .initial,
            achievements: Self.defaultAchievements,
            scienceMasteries: Self.defaultScienceMasteries,
            buildingsCompleted: 0,
            totalPlayTime: 0,
            dateJoined: Date(),
            lastActive: Date()
        )
    }

    // Default achievements (all locked initially)
    static let defaultAchievements: [Achievement] = [
        // Mathematics
        Achievement(id: "calc", name: "The Calculator", description: "Solve 10 math challenges", iconName: "function", category: .mathematics, isUnlocked: false),
        Achievement(id: "golden", name: "Golden Mind", description: "Use golden ratio perfectly 5 times", iconName: "seal.fill", category: .mathematics, isUnlocked: false),
        Achievement(id: "merchant", name: "Master Merchant", description: "Manage budget successfully 20 times", iconName: "banknote.fill", category: .mathematics, isUnlocked: false),

        // Physics
        Achievement(id: "force", name: "Force Master", description: "Complete 10 structural challenges", iconName: "arrow.up.and.down.and.arrow.left.and.right", category: .physics, isUnlocked: false),
        Achievement(id: "dome", name: "Dome Builder", description: "Build a self-supporting dome", iconName: "building.columns.fill", category: .physics, isUnlocked: false),

        // Chemistry
        Achievement(id: "alchemist", name: "Alchemist", description: "Mix 10 pigments successfully", iconName: "flask.fill", category: .chemistry, isUnlocked: false),
        Achievement(id: "fresco", name: "Fresco Virtuoso", description: "Complete 3 frescoes", iconName: "paintbrush.fill", category: .chemistry, isUnlocked: false),

        // General
        Achievement(id: "first_palazzo", name: "First Palazzo", description: "Complete your first building", iconName: "house.fill", category: .general, isUnlocked: false),
        Achievement(id: "renaissance_master", name: "Renaissance Master", description: "Reach Master level", iconName: "star.fill", category: .general, isUnlocked: false),
    ]

    // Default science masteries
    static let defaultScienceMasteries: [ScienceMastery] = Science.allCases.map { science in
        ScienceMastery(
            id: science.rawValue,
            science: science,
            level: 0,
            challengesCompleted: 0,
            totalChallenges: 10
        )
    }
}
