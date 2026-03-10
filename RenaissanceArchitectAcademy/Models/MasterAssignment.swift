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
        case .cinnabarFrescoPigment:
            return "A cardinal's portrait needs vivid red. Prepare Cinnabar Fresco Pigment!"
        case .saffronIllumination:
            return "The scriptorium needs golden ink. Create Saffron Illumination pigment!"
        case .greenFrescoPigment:
            return "Botticelli's garden scene needs emerald leaves. Mix Green Fresco Pigment!"
        case .rawBronze:
            return "Master Lotti's goldsmith workshop needs raw bronze ingots. Smelt copper and iron!"
        case .goldLeaf:
            return "The altarpiece needs gilding. Hammer Gold Leaf from pure gold!"
        case .fumigationIncense:
            return "Plague is spreading in Santa Croce. Burn herbs and sulfur to fumigate the district!"
        case .castingMold:
            return "Master Lotti needs casting molds for a bronze commission. Mix clay with letame and charred ox horn!"
        case .temperaPaint:
            return "The fresco painter needs tempera. Crack eggs and grind pigment — Botticelli used the same recipe!"
        case .apprenticeSeal:
            return "Every apprentice needs a mark. Melt beeswax and press your seal — you belong to the guild now!"
        case .architectSeal:
            return "You've earned a copper seal. Cast it yourself — stamp your authority on every blueprint and contract!"
        case .masterSeal:
            return "Only a master carries gold. Forge your seal — the same mark Brunelleschi pressed on the Duomo orders!"
        }
    }
}
