import Foundation

/// Linear phase-based progression for each building.
/// The bird guides the player through phases in order — no ping-pong between environments.
enum BuildingPhase: Int, CaseIterable, Comparable {
    case learn   = 0  // City Map: knowledge cards + sketch studies
    case collect = 1  // Workshop: buy tools, collect materials via mini-games, workshop cards
    case explore = 2  // Forest: forest cards + collect timber
    case craft   = 3  // Crafting Room: crafting room cards + craft required items
    case build   = 4  // City Map: construction sequence puzzle → complete

    static func < (lhs: BuildingPhase, rhs: BuildingPhase) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    var displayName: String {
        switch self {
        case .learn:   return "Learn"
        case .collect: return "Collect"
        case .explore: return "Explore"
        case .craft:   return "Craft"
        case .build:   return "Build"
        }
    }

    /// The environment this phase takes place in
    var environment: CardEnvironment? {
        switch self {
        case .learn:   return .cityMap
        case .collect: return .workshop
        case .explore: return .forest
        case .craft:   return .craftingRoom
        case .build:   return nil  // Back to city map for construction
        }
    }
}

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
    var lessonRead: Bool = false
    var lessonSectionIndex: Int = 0  // Bookmark: which section the student is on
    var constructionSequenceCompleted: Bool = false
    var completedCardIDs: Set<String> = []    // Knowledge cards completed (deterministic IDs)
    var completedSketchStudyIDs: Set<Int> = []  // Met Museum object IDs studied

    // MARK: - Phase Computation

    /// Determine which phase the player is currently in for a given building.
    /// `craftedMaterials` is passed as a plain dict to avoid @MainActor isolation issues.
    func currentPhase(for buildingName: String, workshopState: WorkshopState, craftedMaterials: [CraftedItem: Int] = [:]) -> BuildingPhase {
        let cityCards = KnowledgeCardContent.cards(for: buildingName, in: .cityMap)
        let workshopCards = KnowledgeCardContent.cards(for: buildingName, in: .workshop)
        let forestCards = KnowledgeCardContent.cards(for: buildingName, in: .forest)
        let craftingCards = KnowledgeCardContent.cards(for: buildingName, in: .craftingRoom)

        let citySketches = MuseumSketchContent.sketches(for: buildingName)

        // Phase 1: LEARN — city cards + sketch studies not done yet
        let cityCardsDone = cityCards.allSatisfy { completedCardIDs.contains($0.id) }
        let sketchesDone = citySketches.allSatisfy { completedSketchStudyIDs.contains($0.id) }
        if !cityCards.isEmpty && (!cityCardsDone || !sketchesDone) {
            return .learn
        }

        // Phase 2: COLLECT — workshop cards + raw materials not gathered
        let workshopCardsDone = workshopCards.allSatisfy { completedCardIDs.contains($0.id) }
        if !workshopCardsDone {
            return .collect
        }

        // Phase 3: EXPLORE — forest cards not done
        let forestCardsDone = forestCards.allSatisfy { completedCardIDs.contains($0.id) }
        if !forestCards.isEmpty && !forestCardsDone {
            return .explore
        }

        // Phase 4: CRAFT — crafting room cards not done OR required materials not crafted
        let craftingCardsDone = craftingCards.allSatisfy { completedCardIDs.contains($0.id) }
        if !craftingCardsDone {
            return .craft
        }

        // Even with all cards done, stay in CRAFT if the building's required
        // crafted materials aren't ready. This prevents the infinite loop where
        // phase=.build but CityMapView sends to Workshop and Workshop sends back.
        let required = Building.requiredCraftedItems(for: buildingName)
        if !required.isEmpty {
            let allCrafted = required.allSatisfy { item, needed in
                (craftedMaterials[item] ?? 0) >= needed
            }
            if !allCrafted {
                return .craft
            }
        }

        // Phase 5: BUILD — all learning done AND materials ready
        return .build
    }

    /// How many cards are done in a specific environment
    func cardsCompleted(for buildingName: String, in environment: CardEnvironment) -> (done: Int, total: Int) {
        let cards = KnowledgeCardContent.cards(for: buildingName, in: environment)
        let done = cards.filter { completedCardIDs.contains($0.id) }.count
        return (done, cards.count)
    }
}

/// Reward constants for the game economy
enum GameRewards {
    static let lessonReadFlorins = 10
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
    static let sketchStudyFlorins = 3            // Studying a Met Museum sketch
}
