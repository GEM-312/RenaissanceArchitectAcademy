import Foundation

/// A task from the workshop master — craft a specific item for a bonus reward
struct MasterAssignment {
    let targetItem: CraftedItem
    let rewardFlorins: Int
    let flavorText: String

    /// Generate a random assignment from available recipes
    static func randomAssignment() -> MasterAssignment {
        let recipe = Recipe.allRecipes.randomElement()!
        let flavor = flavorText(for: recipe.output)
        return MasterAssignment(
            targetItem: recipe.output,
            rewardFlorins: GameRewards.masterAssignmentFlorins,
            flavorText: flavor
        )
    }

    private static func flavorText(for item: CraftedItem) -> String {
        switch item {
        case .limeMortar:
            return "The Aqueduct repairs need mortar. Craft Lime Mortar for the builders!"
        case .romanConcrete:
            return "The Pantheon dome requires Roman Concrete. Mix volcanic ash and limestone!"
        case .terracottaTiles:
            return "The Duomo needs roof tiles. Fire some Terracotta Tiles in the furnace!"
        case .redFrescoPigment:
            return "A chapel wall awaits color. Grind Red Fresco Pigment for the painters!"
        case .blueFrescoPigment:
            return "The Vatican ceiling needs ultramarine. Prepare Blue Fresco Pigment!"
        case .bronzeFittings:
            return "The Arsenal doors need hardware. Cast some Bronze Fittings!"
        case .timberBeams:
            return "The Roman Baths roof is sagging. Shape Timber Beams to reinforce it!"
        case .glassPanes:
            return "The Glassworks needs demonstration pieces. Blow some Glass Panes!"
        case .stainedGlass:
            return "A cathedral window is incomplete. Create Stained Glass for the masons!"
        case .marbleSlabs:
            return "The Colosseum floor needs marble. Polish some Marble Slabs!"
        case .leadSheeting:
            return "The Harbor warehouse leaks. Hammer out Lead Sheeting for waterproofing!"
        case .silkFabric:
            return "Leonardo's flying machine needs wings. Weave Silk Fabric!"
        case .carvedWood:
            return "The Anatomy Theater needs more seating. Carve some walnut wood!"
        }
    }
}
