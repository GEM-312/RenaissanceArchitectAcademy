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
            ingredients: [.groundRedOchre: 2, .limestone: 1],
            temperature: .low,
            processingTime: 3.0,
            educationalText: "Fresco means 'fresh' — ground pigments applied to wet lime plaster. The lime crystallizes around pigment, making colors last centuries!"
        ),
        Recipe(
            output: .blueFrescoPigment,
            ingredients: [.groundLapisBlue: 2, .limestone: 1],
            temperature: .low,
            processingTime: 3.0,
            educationalText: "Lapis lazuli was more expensive than gold! Renaissance painters reserved ultramarine blue for the Virgin Mary's robes."
        ),
        Recipe(
            output: .bronzeFittings,
            ingredients: [.copper: 1, .ironOre: 1, .clay: 1],
            temperature: .high,
            processingTime: 5.0,
            educationalText: "Bronze fittings required copper melted with iron ore in clay molds. Goldsmiths in Santa Croce cast door handles, hinges, and decorative hardware — the same workshops where Brunelleschi and Donatello first learned their craft."
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
        ),
        Recipe(
            output: .cinnabarFrescoPigment,
            ingredients: [.groundCinnabar: 2, .limestone: 1],
            temperature: .low,
            processingTime: 3.0,
            educationalText: "Cinnabar red was the color of power. Cardinals' robes, papal seals, illuminated capitals — all cinnabar. Pompeii's Villa of Mysteries still blazes with it after 2,000 years under ash."
        ),
        Recipe(
            output: .saffronIllumination,
            ingredients: [.groundSaffron: 2, .limestone: 1],
            temperature: .low,
            processingTime: 3.0,
            educationalText: "Manuscript illuminators mixed saffron with egg white to paint golden halos. Unlike gold leaf, saffron absorbed candlelight and re-emitted it warm. Monks called it 'poor man's gold' — but it was anything but cheap."
        ),
        Recipe(
            output: .greenFrescoPigment,
            ingredients: [.groundVerdigris: 2, .limestone: 1],
            temperature: .low,
            processingTime: 3.0,
            educationalText: "Verdigris green gave Renaissance frescoes their lush landscapes. But painters worked fast — mixed with lime plaster, verdigris had hours before it darkened. Botticelli's Primavera preserves the original emerald because it was painted on panel, not wall."
        ),
        Recipe(
            output: .rawBronze,
            ingredients: [.copper: 2, .ironOre: 1],
            temperature: .high,
            processingTime: 5.0,
            educationalText: "Bronze is roughly 88% copper and 12% tin. Florentine founders melted copper in clay crucibles, adding tin to lower the melting point from 1085°C to 950°C. The resulting alloy was harder than either metal alone — perfect for bells, cannons, and Ghiberti's Gates of Paradise."
        ),
        Recipe(
            output: .goldLeaf,
            ingredients: [.gold: 1, .lead: 1],
            temperature: .medium,
            processingTime: 4.0,
            educationalText: "A single ounce of gold can be hammered into 300 square feet of leaf — thinner than a human hair. Goldbeaters placed gold between sheets of ox-gut membrane and struck with heavy hammers for hours. Lead backing sheets protected the delicate leaf during transport."
        ),
        Recipe(
            output: .fumigationIncense,
            ingredients: [.herbs: 2, .sulfur: 1],
            temperature: .low,
            processingTime: 3.0,
            educationalText: "During the Black Death of 1400, Florentines burned wormwood, juniper, and lavender in every hearth. When that failed, they added sulfur — the fumigations so intense that sparrows fell dead from rooftops. The chemistry was real: sulfur dioxide kills bacteria. They had the right molecule, wrong delivery method."
        ),
        Recipe(
            output: .castingMold,
            ingredients: [.clay: 2, .letame: 1, .charredOxHorn: 1],
            temperature: .medium,
            processingTime: 4.0,
            educationalText: "Florentine founders mixed clay with letame and charred ox horn to make casting molds. The organic fibers create micro-channels that let steam escape — without them, molten bronze at 1100°C would shatter the mold on contact. One civilization's waste is another's engineering breakthrough."
        ),
        Recipe(
            output: .temperaPaint,
            ingredients: [.eggs: 2, .groundRedOchre: 1],
            temperature: .low,
            processingTime: 3.0,
            educationalText: "Before oil paint, every Renaissance masterpiece was egg tempera. Painters cracked an egg, separated the yolk, mixed it with ground pigment, and painted in thin translucent layers. Botticelli's Birth of Venus? Egg tempera. It dries in minutes, lasts for centuries."
        ),
        Recipe(
            output: .apprenticeSeal,
            ingredients: [.beeswax: 2, .clay: 1],
            temperature: .low,
            processingTime: 3.0,
            educationalText: "Every guild apprentice received a wax seal — your mark on contracts, letters, and finished work. The clay stamp was carved by your master, the beeswax melted and pressed. Simple materials, but it meant something: you belonged to a trade. Brunelleschi's first seal bore the goldsmith's compass."
        ),
        Recipe(
            output: .architectSeal,
            ingredients: [.beeswax: 2, .copper: 1, .clay: 1],
            temperature: .medium,
            processingTime: 4.0,
            educationalText: "An architect's seal was cast in copper — harder to forge, impossible to ignore. Brunelleschi stamped his on the Duomo construction documents. Every load of marble, every payment to stonemasons, every engineering change — sealed. The copper die outlasted the wax it pressed."
        ),
        Recipe(
            output: .masterSeal,
            ingredients: [.beeswax: 1, .gold: 1, .lead: 1],
            temperature: .medium,
            processingTime: 5.0,
            educationalText: "A master's seal was gold — the ultimate proof of authority. Goldbeaters hammered the die from a single ingot, engraved with the master's personal device. When Brunelleschi sealed the final Duomo capstone order, he used a gold seal bearing his ox-head emblem. Only 12 master seals existed in all of Florence."
        ),
    ]

    /// Detect a matching recipe from the given ingredient counts
    static func detectRecipe(from ingredients: [Material: Int]) -> Recipe? {
        allRecipes.first { $0.ingredients == ingredients }
    }
}
