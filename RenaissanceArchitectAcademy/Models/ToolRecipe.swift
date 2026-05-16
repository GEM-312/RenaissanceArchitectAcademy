import Foundation

/// A crafting recipe that forges raw Materials into a Tool at the workbench
struct ToolRecipe: Identifiable {
    let id = UUID()
    let output: Tool
    let ingredients: [Material: Int]
    let educationalText: String

    static let allRecipes: [ToolRecipe] = [
        ToolRecipe(
            output: .pickaxe,
            ingredients: [.ironOre: 1, .timber: 1],
            educationalText: "A quarryman's pick — iron head fitted to an ash-wood handle. Roman picks weighed 3 kg and lasted months of daily hammering."
        ),
        ToolRecipe(
            output: .bucket,
            ingredients: [.timber: 2, .ironOre: 1],
            educationalText: "Coopers bent steamed oak staves into buckets, bound with iron hoops. A well-made bucket could carry 10 litres without leaking a drop."
        ),
        ToolRecipe(
            output: .ashRake,
            ingredients: [.ironOre: 1, .timber: 1],
            educationalText: "Ash rakers used long-handled iron rakes to gather pozzolana safely from still-warm volcanic fields around Pozzuoli."
        ),
        ToolRecipe(
            output: .shovel,
            ingredients: [.ironOre: 1, .timber: 1],
            educationalText: "A flat iron blade on a sturdy handle — clay diggers preferred elm wood for its resistance to splitting under heavy loads."
        ),
        ToolRecipe(
            output: .miningHammer,
            ingredients: [.ironOre: 2, .timber: 1],
            educationalText: "Mining hammers had double iron heads — one flat for striking, one pointed for following ore veins. Heavier than a pickaxe but more precise."
        ),
        ToolRecipe(
            output: .axe,
            ingredients: [.ironOre: 1, .timber: 1],
            educationalText: "Leonardo sketched the ideal axe: a curved cutting edge, wedge-shaped head, and a handle of seasoned hickory cut in winter."
        ),
        ToolRecipe(
            output: .tradePurse,
            ingredients: [.silk: 1, .ironOre: 1],
            educationalText: "Silk purses with iron clasps kept florins safe during trade. The clasp was stamped with the merchant's guild seal as proof of membership."
        ),
        ToolRecipe(
            output: .mortarAndPestle,
            ingredients: [.marble: 1, .ironOre: 1],
            educationalText: "Marble mortars were preferred because the smooth stone didn't contaminate pigments. A heavy iron pestle ground lapis lazuli into the finest powder."
        ),
        ToolRecipe(
            output: .pitchfork,
            ingredients: [.timber: 2, .ironOre: 1],
            educationalText: "Tuscan farmers forged pitchforks with three or four iron tines on a chestnut-wood shaft — light enough to lift hay all day, sturdy enough to last a generation."
        ),
    ]

    /// Detect a matching tool recipe from the given ingredient counts
    static func detectRecipe(from ingredients: [Material: Int]) -> ToolRecipe? {
        allRecipes.first(where: { $0.ingredients == ingredients })
    }
}
