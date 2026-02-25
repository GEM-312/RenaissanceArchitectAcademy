import Foundation

/// A work commission from the workshop master — the Renaissance Bottega system
/// Apprentices receive tasks based on skill level: collect resources, craft items, or both
struct WorkshopJob: Identifiable {
    let id = UUID()
    let tier: JobTier
    let title: String
    let tradeName: String        // Italian guild trade name
    let tradeDescription: String // What this trade was in Renaissance Italy
    let station: ResourceStationType?  // nil for crafting-only jobs
    let requirements: [Material: Int]  // Materials to collect (collection jobs)
    let craftTarget: CraftedItem?      // Item to craft (crafting jobs, nil for collect-only)
    let rewardFlorins: Int
    let flavorText: String
    let historyFact: String      // Educational content about this trade

    /// Job difficulty tiers — based on Renaissance guild system
    enum JobTier: String, CaseIterable {
        case apprentice = "Apprentice"     // Garzone — simple single-station collection
        case journeyman = "Journeyman"     // Lavorante — multi-material or multi-station
        case master = "Master"             // Maestro — full craft chain (collect + craft)

        var icon: String {
            switch self {
            case .apprentice: return "🔨"
            case .journeyman: return "⚒️"
            case .master: return "👑"
            }
        }

        var italianTitle: String {
            switch self {
            case .apprentice: return "Garzone"
            case .journeyman: return "Lavorante"
            case .master: return "Maestro"
            }
        }
    }

    // MARK: - Job Completion Tracking

    /// Check if the player has collected enough materials for this job
    func isCollectionComplete(inventory: [Material: Int]) -> Bool {
        for (material, needed) in requirements {
            if (inventory[material] ?? 0) < needed { return false }
        }
        return true
    }

    /// Check if the crafting target was met (if applicable)
    func isCraftComplete(crafted: [CraftedItem: Int]) -> Bool {
        guard let target = craftTarget else { return true }
        return (crafted[target] ?? 0) > 0
    }

    // MARK: - Job Generation

    /// All available jobs organized by tier
    static let allJobs: [WorkshopJob] = apprenticeJobs + journeymanJobs + masterJobs

    /// Generate a random job for the given tier
    static func randomJob(tier: JobTier) -> WorkshopJob {
        let pool: [WorkshopJob]
        switch tier {
        case .apprentice: pool = apprenticeJobs
        case .journeyman: pool = journeymanJobs
        case .master: pool = masterJobs
        }
        return pool.randomElement()!
    }

    // MARK: - Apprentice Jobs (Garzone) — Simple collection at one station

    private static let apprenticeJobs: [WorkshopJob] = [
        WorkshopJob(
            tier: .apprentice,
            title: "Cut Timber",
            tradeName: "Boscaiolo",
            tradeDescription: "Woodcutter — felled trees and shaped logs for construction",
            station: .forest,
            requirements: [.timber: 3],
            craftTarget: nil,
            rewardFlorins: 8,
            flavorText: "The master needs timber for roof beams. Head to the forest and cut 3 logs!",
            historyFact: "Renaissance woodcutters (boscaioli) worked in teams. They used two-man crosscut saws and oxen to drag logs. Florentine law protected certain forests — illegal logging meant prison!"
        ),
        WorkshopJob(
            tier: .apprentice,
            title: "Quarry Stone",
            tradeName: "Tagliapietre",
            tradeDescription: "Stonecutter — quarried and rough-shaped building stone",
            station: .quarry,
            requirements: [.limestone: 3],
            craftTarget: nil,
            rewardFlorins: 8,
            flavorText: "We need limestone blocks for mortar. Head to the quarry and cut 3 blocks!",
            historyFact: "Stonecutters (tagliapietre) were among the highest-paid workers on building sites. They used iron chisels, mallets, and wedges. The best came from Lombardy and were hired across Italy."
        ),
        WorkshopJob(
            tier: .apprentice,
            title: "Fetch Water & Sand",
            tradeName: "Manovale",
            tradeDescription: "Laborer — carried materials to masons and craftsmen",
            station: .river,
            requirements: [.water: 2, .sand: 2],
            craftTarget: nil,
            rewardFlorins: 6,
            flavorText: "Every recipe needs water and sand. Fill buckets at the river!",
            historyFact: "Manovali were the lowest-paid workers, but essential. They carried water, mixed mortar, and hauled materials up scaffolding. Many were farmers earning extra money between harvests."
        ),
        WorkshopJob(
            tier: .apprentice,
            title: "Dig Clay",
            tradeName: "Fornaciaio",
            tradeDescription: "Brickmaker — dug clay and molded it into bricks and tiles",
            station: .clayPit,
            requirements: [.clay: 4],
            craftTarget: nil,
            rewardFlorins: 7,
            flavorText: "The tile-makers need clay. Dig 4 loads from the clay pit!",
            historyFact: "Fornaciai worked near rivers where clay deposits formed. They shaped bricks in wooden molds and dried them in the sun before firing. Florence's red rooftops are all their handiwork!"
        ),
        WorkshopJob(
            tier: .apprentice,
            title: "Mine Ore",
            tradeName: "Minatore",
            tradeDescription: "Miner — extracted iron and lead from underground shafts",
            station: .mine,
            requirements: [.ironOre: 2],
            craftTarget: nil,
            rewardFlorins: 9,
            flavorText: "The blacksmith needs iron. Mine 2 loads of iron ore!",
            historyFact: "Renaissance miners worked in dangerous conditions — dark shafts, bad air, cave-ins. Georgius Agricola's 1556 book 'De Re Metallica' was the first scientific mining manual, with detailed illustrations of tools and ventilation systems."
        ),
        WorkshopJob(
            tier: .apprentice,
            title: "Collect Volcanic Ash",
            tradeName: "Pozzolanaro",
            tradeDescription: "Pozzolana gatherer — collected volcanic ash for concrete",
            station: .volcano,
            requirements: [.volcanicAsh: 3],
            craftTarget: nil,
            rewardFlorins: 10,
            flavorText: "Roman concrete needs volcanic ash. Collect 3 loads from the volcano!",
            historyFact: "Pozzolana gets its name from Pozzuoli near Naples, where Romans first discovered volcanic ash makes concrete waterproof. This 'magic ingredient' is why the Pantheon dome still stands 2000 years later!"
        ),
        WorkshopJob(
            tier: .apprentice,
            title: "Buy Silk at Market",
            tradeName: "Setaiolo",
            tradeDescription: "Silk merchant — traded silk from the Orient and local workshops",
            station: .market,
            requirements: [.silk: 2],
            craftTarget: nil,
            rewardFlorins: 8,
            flavorText: "Leonardo needs silk for his flying machine design. Buy 2 bolts at the market!",
            historyFact: "Florence's silk guild (Arte della Seta) was one of the most powerful. Silk came via the Silk Road from China, but by the 1400s, Florentines raised their own silkworms on mulberry trees."
        ),
    ]

    // MARK: - Journeyman Jobs (Lavorante) — Multi-material collection

    private static let journeymanJobs: [WorkshopJob] = [
        WorkshopJob(
            tier: .journeyman,
            title: "Prepare Mortar Ingredients",
            tradeName: "Muratore",
            tradeDescription: "Mason — built walls and mixed mortar on site",
            station: nil,
            requirements: [.limestone: 2, .water: 1, .sand: 1],
            craftTarget: nil,
            rewardFlorins: 14,
            flavorText: "The masons need mortar ingredients: limestone, water, and sand. Gather them all!",
            historyFact: "Muratori were skilled tradesmen who could read architectural plans. A master mason earned 3-4 times what a laborer made. They mixed mortar fresh each morning — leftover mortar was useless by afternoon."
        ),
        WorkshopJob(
            tier: .journeyman,
            title: "Gather Concrete Materials",
            tradeName: "Cementista",
            tradeDescription: "Concrete worker — mixed and poured Roman concrete",
            station: nil,
            requirements: [.limestone: 1, .volcanicAsh: 1, .water: 1, .sand: 1],
            craftTarget: nil,
            rewardFlorins: 16,
            flavorText: "Roman concrete needs four ingredients from different stations. Collect them all!",
            historyFact: "Roman concrete (opus caementicium) was layered into wooden forms. Workers poured it in courses, each about 20cm thick, then tamped it down. The Pantheon dome was cast in this way, with lighter pumice aggregate near the top."
        ),
        WorkshopJob(
            tier: .journeyman,
            title: "Supply the Glassmaker",
            tradeName: "Vetraio",
            tradeDescription: "Glassmaker — blew and shaped glass in fiery furnaces",
            station: nil,
            requirements: [.sand: 2, .limestone: 1, .water: 1],
            craftTarget: nil,
            rewardFlorins: 14,
            flavorText: "The glass furnace is ready — gather sand, limestone, and water for glass-making!",
            historyFact: "Murano glassmakers were so valuable that Venice forbade them from leaving the island — on pain of death! They kept recipes secret for centuries. A master glassblower could shape a goblet in under a minute."
        ),
        WorkshopJob(
            tier: .journeyman,
            title: "Equip the Carpenter",
            tradeName: "Falegname",
            tradeDescription: "Carpenter — shaped timber into structural elements and furniture",
            station: nil,
            requirements: [.timber: 3, .ironOre: 1],
            craftTarget: nil,
            rewardFlorins: 13,
            flavorText: "The carpenter needs timber and iron nails. Collect from the forest and mine!",
            historyFact: "Falegnami were essential to every building project. They built scaffolding, centering for arches, roof trusses, and doors. Brunelleschi invented a special ox-driven hoist — the carpenter who built it became famous too!"
        ),
        WorkshopJob(
            tier: .journeyman,
            title: "Prepare Pigment Supplies",
            tradeName: "Speziale",
            tradeDescription: "Apothecary — ground pigments, mixed medicines, sold dyes",
            station: nil,
            requirements: [.redOchre: 2, .water: 1, .limestone: 1],
            craftTarget: nil,
            rewardFlorins: 15,
            flavorText: "The fresco painter awaits! Gather ochre, water, and limestone for red pigment.",
            historyFact: "Speziali ground pigments on marble slabs with a muller (stone roller). Each color came from a different source: red ochre from earth, lapis lazuli from Afghanistan, verdigris from corroded copper plates."
        ),
        WorkshopJob(
            tier: .journeyman,
            title: "Stock the Forge",
            tradeName: "Fabbro",
            tradeDescription: "Blacksmith — forged iron tools, hardware, and weapons",
            station: nil,
            requirements: [.ironOre: 2, .clay: 1],
            craftTarget: nil,
            rewardFlorins: 14,
            flavorText: "The blacksmith's forge is cold. Bring iron ore and clay for casting molds!",
            historyFact: "Fabbri worked with bellows-driven charcoal forges reaching 1200°C. Every building site had a forge nearby — masons constantly needed new chisels resharpened. A good fabbro could tell iron's temperature by its color."
        ),
    ]

    // MARK: - Master Jobs (Maestro) — Full craft chain: collect + craft

    private static let masterJobs: [WorkshopJob] = [
        WorkshopJob(
            tier: .master,
            title: "Build Roman Concrete",
            tradeName: "Capomastro",
            tradeDescription: "Master builder — oversaw entire construction projects",
            station: nil,
            requirements: [.limestone: 1, .volcanicAsh: 1, .water: 1, .sand: 1],
            craftTarget: .romanConcrete,
            rewardFlorins: 25,
            flavorText: "The Pantheon needs repairs. Gather all ingredients AND craft Roman Concrete!",
            historyFact: "The Capomastro was responsible for everything: hiring workers, ordering materials, reading plans, and ensuring quality. Filippo Brunelleschi held this role for the Duomo — he even designed the kitchen that fed 300 workers lunch on the scaffolding!"
        ),
        WorkshopJob(
            tier: .master,
            title: "Fire Terracotta Tiles",
            tradeName: "Maestro Fornaciaio",
            tradeDescription: "Master brickmaker — managed kilns and quality control",
            station: nil,
            requirements: [.clay: 3, .water: 1],
            craftTarget: .terracottaTiles,
            rewardFlorins: 22,
            flavorText: "The Duomo needs roof tiles! Collect clay and water, then fire terracotta at the furnace.",
            historyFact: "A master fornaciaio could judge kiln temperature by the color of the flame. Too cool and tiles crumbled; too hot and they warped. The best tiles rang like a bell when tapped — a quality test still used today!"
        ),
        WorkshopJob(
            tier: .master,
            title: "Craft Timber Beams",
            tradeName: "Maestro d'Ascia",
            tradeDescription: "Master carpenter — designed and built major timber structures",
            station: nil,
            requirements: [.timber: 3, .ironOre: 1],
            craftTarget: .timberBeams,
            rewardFlorins: 22,
            flavorText: "The Roman Baths roof sags! Cut timber, mine iron, then shape beams at the workbench.",
            historyFact: "Maestri d'ascia (master axe-men) could shape a beam perfectly square using only an axe and adze. The best were shipbuilders from Venice's Arsenal, where they could build a warship in a single day!"
        ),
        WorkshopJob(
            tier: .master,
            title: "Blow Glass Panes",
            tradeName: "Maestro Vetraio",
            tradeDescription: "Master glassmaker — created fine glass in Murano furnaces",
            station: nil,
            requirements: [.sand: 2, .limestone: 1, .water: 1],
            craftTarget: .glassPanes,
            rewardFlorins: 24,
            flavorText: "The Glassworks needs demonstration pieces. Gather materials and blow glass!",
            historyFact: "Murano's maestri vetrai were the only people in Europe who knew how to make cristallo — perfectly clear glass. The secret? Manganese dioxide as a decolorizer. Angelo Barovier discovered this around 1450."
        ),
        WorkshopJob(
            tier: .master,
            title: "Create Stained Glass",
            tradeName: "Maestro delle Vetrate",
            tradeDescription: "Stained glass master — designed and assembled colored windows",
            station: nil,
            requirements: [.sand: 1, .lead: 1, .lapisBlue: 1, .limestone: 1],
            craftTarget: .stainedGlass,
            rewardFlorins: 28,
            flavorText: "A cathedral window awaits! Gather rare materials and create stained glass.",
            historyFact: "Stained glass masters drew full-size designs (cartoons) on whitewashed tables. Each color was a different metal oxide: cobalt for blue, gold chloride for red, iron for green. Lead cames joined the pieces — a window could have 1000+ pieces!"
        ),
        WorkshopJob(
            tier: .master,
            title: "Mix Lime Mortar",
            tradeName: "Maestro Muratore",
            tradeDescription: "Master mason — directed wall construction and mortar quality",
            station: nil,
            requirements: [.limestone: 2, .water: 1, .sand: 1],
            craftTarget: .limeMortar,
            rewardFlorins: 22,
            flavorText: "The Aqueduct needs mortar! Quarry limestone, fetch water and sand, then mix at the workbench.",
            historyFact: "A master muratore tested mortar by feel — too dry and it crumbled, too wet and it sagged. The best mortar was 'slaked' for months in pits, improving its workability. Some Roman mortar was slaked for years!"
        ),
        WorkshopJob(
            tier: .master,
            title: "Grind Red Fresco Pigment",
            tradeName: "Maestro dei Colori",
            tradeDescription: "Color master — prepared and tested pigments for painters",
            station: nil,
            requirements: [.redOchre: 2, .water: 1, .limestone: 1],
            craftTarget: .redFrescoPigment,
            rewardFlorins: 24,
            flavorText: "A chapel wall awaits color! Collect ochre and prepare red fresco pigment.",
            historyFact: "Pigment masters tested colors by painting a small sample on wet plaster and waiting for it to dry — colors often changed dramatically. Cennino Cennini's 'Il Libro dell'Arte' (1437) documented every pigment recipe in detail."
        ),
        WorkshopJob(
            tier: .master,
            title: "Cast Bronze Fittings",
            tradeName: "Maestro Fonditore",
            tradeDescription: "Master founder — cast bronze statues, bells, and hardware",
            station: nil,
            requirements: [.ironOre: 2, .clay: 1],
            craftTarget: .bronzeFittings,
            rewardFlorins: 24,
            flavorText: "The Arsenal doors need hardware! Mine ore, dig clay for molds, then cast bronze.",
            historyFact: "Lorenzo Ghiberti spent 27 years casting the Florence Baptistery doors — Michelangelo called them 'The Gates of Paradise.' The lost-wax casting technique required wax models, clay molds, and furnaces reaching 1100°C."
        ),
    ]
}
