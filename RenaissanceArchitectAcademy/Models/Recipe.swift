import Foundation

/// A crafting recipe that transforms raw Materials into a CraftedItem
struct Recipe: Identifiable {
    let id = UUID()
    let output: CraftedItem
    let ingredients: [Material: Int]
    let temperature: Temperature
    let processingTime: Double
    let educationalText: String

    enum Temperature: String, CaseIterable {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
    }

    static let allRecipes: [Recipe] = [
        Recipe(
            output: .limeMortar,
            ingredients: [.limestone: 2, .water: 1, .sand: 1],
            temperature: .high,
            processingTime: 4.0,
            educationalText: "Limestone (calcium carbonate) heats to 900°C becoming quicklime (calcium oxide), then mixed with water creates slaked lime! Romans used this for 2000 years."
        ),
        Recipe(
            output: .romanConcrete,
            ingredients: [.limestone: 1, .volcanicAsh: 1, .water: 1, .sand: 1],
            temperature: .medium,
            processingTime: 5.0,
            educationalText: "Romans discovered volcanic ash (pozzolana) creates concrete stronger than modern Portland cement. The Pantheon dome still stands after 2000 years!"
        ),
        Recipe(
            output: .terracottaTiles,
            ingredients: [.clay: 3, .water: 1],
            temperature: .high,
            processingTime: 4.0,
            educationalText: "Terra cotta means 'baked earth' in Italian. Firing clay at 1000°C creates the iconic red roof tiles of Florence!"
        ),
        Recipe(
            output: .redFrescoPigment,
            ingredients: [.redOchre: 2, .water: 1, .limestone: 1],
            temperature: .low,
            processingTime: 3.0,
            educationalText: "Fresco means 'fresh' — pigments applied to wet lime plaster. The lime crystallizes around pigment, making colors last centuries!"
        ),
        Recipe(
            output: .blueFrescoPigment,
            ingredients: [.lapisBlue: 2, .water: 1, .limestone: 1],
            temperature: .low,
            processingTime: 3.0,
            educationalText: "Lapis lazuli was more expensive than gold! Renaissance painters reserved ultramarine blue for the Virgin Mary's robes."
        ),
        Recipe(
            output: .bronzeFittings,
            ingredients: [.ironOre: 2, .clay: 1],
            temperature: .high,
            processingTime: 5.0,
            educationalText: "Bronze casting requires extreme heat to melt metal into clay molds. Renaissance craftsmen created elaborate door handles and decorations this way."
        ),
        Recipe(
            output: .timberBeams,
            ingredients: [.timber: 3, .ironOre: 1],
            temperature: .medium,
            processingTime: 3.0,
            educationalText: "Timber beams were shaped with iron adzes and joined with iron nails. Oak and chestnut were prized for their strength and resistance to rot."
        ),
        Recipe(
            output: .glassPanes,
            ingredients: [.sand: 2, .limestone: 1, .water: 1],
            temperature: .high,
            processingTime: 4.0,
            educationalText: "Romans invented cast flat glass! Sand (silica) melts at 1700°C, but adding limestone and soda ash lowers it to 1000°C. Early glass was greenish and bubbly."
        ),
        Recipe(
            output: .stainedGlass,
            ingredients: [.sand: 1, .lead: 1, .lapisBlue: 1, .limestone: 1],
            temperature: .high,
            processingTime: 5.0,
            educationalText: "Stained glass windows told stories in light! Colored glass was cut, then joined with lead cames. Cobalt made blue, gold chloride made red."
        ),
        Recipe(
            output: .marbleSlabs,
            ingredients: [.marble: 3, .water: 1],
            temperature: .low,
            processingTime: 3.0,
            educationalText: "Marble was cut with sand-fed saws and polished with water. The Pantheon floor uses porphyry from Egypt, giallo antico from Tunisia, and Carrara white."
        ),
        Recipe(
            output: .leadSheeting,
            ingredients: [.lead: 2, .ironOre: 1, .water: 1],
            temperature: .high,
            processingTime: 4.0,
            educationalText: "Lead was melted and cast into sheets for waterproof roofing and pipes. Roman lead pipes (fistulae) supplied water to entire cities!"
        ),
        Recipe(
            output: .silkFabric,
            ingredients: [.silk: 2, .water: 1],
            temperature: .low,
            processingTime: 3.0,
            educationalText: "Leonardo specified starched taffeta (silk) for his flying machine wings — lightweight, airtight, and could be stretched taut over a wooden frame."
        ),
        Recipe(
            output: .carvedWood,
            ingredients: [.timber: 2, .ironOre: 1],
            temperature: .low,
            processingTime: 4.0,
            educationalText: "Walnut was the wood of choice for fine carving. The Padua Anatomy Theater is entirely carved walnut — six steep tiers where 300 students stood to watch dissections."
        )
    ]

    /// Detect a matching recipe from the given ingredient counts
    static func detectRecipe(from ingredients: [Material: Int]) -> Recipe? {
        allRecipes.first { $0.ingredients == ingredients }
    }
}
