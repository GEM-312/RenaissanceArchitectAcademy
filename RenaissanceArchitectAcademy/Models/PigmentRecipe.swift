import Foundation

/// A grinding recipe that transforms a raw pigment + water into a ground pigment
/// at the Pigment Table using a mortar and pestle
struct PigmentRecipe: Identifiable {
    let id = UUID()
    let output: Material
    let ingredients: [Material: Int]
    let grindingTime: Double
    let educationalText: String
    let italianName: String
    let historicalSource: String

    static let allRecipes: [PigmentRecipe] = [
        PigmentRecipe(
            output: .groundRedOchre,
            ingredients: [.redOchre: 1, .water: 1],
            grindingTime: 3.0,
            educationalText: "Roman painters called it sinopia — the red earth that mapped every fresco before a single color was laid. One sketch beneath the Camposanto in Pisa survived 600 years after the painting above was destroyed. The underdrawing outlasted the masterpiece.",
            italianName: "Sinopia",
            historicalSource: "Iron-rich clay from river deposits"
        ),
        PigmentRecipe(
            output: .groundLapisBlue,
            ingredients: [.lapisBlue: 1, .water: 1],
            grindingTime: 5.0,
            educationalText: "Lapis lazuli traveled 4,000 miles from Afghan mines to Florentine workshops. Apprentices ground it for weeks, washing and re-grinding to extract pure ultramarine. The first wash gave the richest blue. The last gave grey. Painters paid more per ounce than they paid for gold.",
            italianName: "Oltremare",
            historicalSource: "Imported lapis lazuli from Afghanistan"
        ),
        PigmentRecipe(
            output: .groundVerdigris,
            ingredients: [.verdigrisGreen: 1, .water: 1],
            grindingTime: 3.0,
            educationalText: "Hang copper plates over vinegar and wait. In two weeks, a green crust forms — verdigris. Renaissance painters loved it and feared it. The most vivid green available, but it ate through canvas and turned black with age. Every green passage in a Botticelli is a race against chemistry.",
            italianName: "Verderame",
            historicalSource: "Copper carbonate mineral from mines"
        ),
        PigmentRecipe(
            output: .groundCinnabar,
            ingredients: [.cinnabar: 1, .water: 1],
            grindingTime: 4.0,
            educationalText: "Cinnabar is mercury sulfide — the most dangerous pigment in the Renaissance palette. Miners in Almadén worked 6-hour shifts because longer exposure was lethal. The finer you ground it, the brighter the red. Apprentices wore cloth over their faces. The color of cardinals' robes cost lives.",
            italianName: "Cinabro",
            historicalSource: "Mercury sulfide from volcanic regions"
        ),
        PigmentRecipe(
            output: .groundSaffron,
            ingredients: [.saffron: 1, .water: 1],
            grindingTime: 3.0,
            educationalText: "Each crocus flower gives three stigmas. Each stigma gives a trace of gold pigment. It takes 150,000 flowers to make one kilogram of saffron. Manuscript illuminators in San Gimignano used it to paint halos — real gold was cheaper, but saffron glowed differently by candlelight.",
            italianName: "Zafferano",
            historicalSource: "Crocus stigmas from San Gimignano meadows"
        ),
    ]

    /// Detect a matching pigment recipe from the given ingredient counts
    static func detectRecipe(from ingredients: [Material: Int]) -> PigmentRecipe? {
        allRecipes.first { $0.ingredients == ingredients }
    }
}
