import SwiftUI

// MARK: - Discovery Card Model
// Shown when the player visits a station WITHOUT an active building.
// Fun historical facts about the station itself, prompting the player to pick a building.

struct DiscoveryCard: Identifiable {
    let id: String              // Station key (e.g., "quarry", "oak")
    let stationName: String     // Display name
    let italianName: String     // Italian term
    let icon: String            // SF Symbol
    let color: Color            // Card accent color
    let storyText: String       // Fun historical story (~80-100 words)
    let funFact: String         // One-liner surprise fact
    let buildingTeaser: String  // "This station helps build: Pantheon, Aqueduct, Duomo..."
}

// MARK: - Discovery Card Content

enum DiscoveryCardContent {

    /// Look up a discovery card by station key
    static func card(for stationKey: String) -> DiscoveryCard? {
        allCards[stationKey]
    }

    private static let allCards: [String: DiscoveryCard] = {
        var map: [String: DiscoveryCard] = [:]
        for card in cards { map[card.id] = card }
        return map
    }()

    // MARK: - Workshop Stations

    private static let cards: [DiscoveryCard] = [

        // ── WORKSHOP OUTDOOR ───────────────────────────────

        DiscoveryCard(
            id: "quarry",
            stationName: "The Quarry",
            italianName: "La Cava",
            icon: "mountain.2.fill",
            color: RenaissanceColors.warmBrown,
            storyText: "Every great building starts with a hole in the ground. Roman quarries at Tivoli, Carrara, and the Euganean Hills supplied stone for 2,000 years of construction. Quarrymen split rock using iron wedges and frozen water — patient work that turned mountains into temples. The Pantheon's columns came from Egypt. The Colosseum's travertine came from 30 km away. The right stone for the right job — that's what quarry masters knew.",
            funFact: "The Carrara quarries that supplied Michelangelo are still active today — 2,000 years of continuous mining.",
            buildingTeaser: "Quarry stone builds: Pantheon, Aqueduct, Colosseum, Duomo, and more"
        ),

        DiscoveryCard(
            id: "volcano",
            stationName: "The Volcano",
            italianName: "Il Vulcano",
            icon: "flame.fill",
            color: RenaissanceColors.terracotta,
            storyText: "Mount Vesuvius destroyed Pompeii in 79 AD — but its volcanic ash, pozzolana, built Rome. Mixed with lime and water, pozzolana creates concrete that gets STRONGER over time. Roman concrete has lasted 2,000 years. Modern Portland cement crumbles after 100. The volcano that leveled a city gave an empire its most durable building material. Destruction and creation from the same source.",
            funFact: "Roman concrete found underwater actually grows new mineral crystals (Al-tobermorite) — it's still getting stronger.",
            buildingTeaser: "Volcanic ash builds: Pantheon, Aqueduct, Roman Roads, Harbor, and more"
        ),

        DiscoveryCard(
            id: "river",
            stationName: "The River",
            italianName: "Il Fiume",
            icon: "water.waves",
            color: RenaissanceColors.renaissanceBlue,
            storyText: "The Tiber, Arno, and Po carried more than water — they carried civilization. River sand was the key ingredient in mortar and glass. River water cured concrete and powered mills. Roman aqueducts delivered 1 million cubic meters daily to the capital. Venice was built entirely on water. Renaissance engineers didn't fight rivers — they harnessed them. Water is the one material every building needs but none contains.",
            funFact: "Ancient Rome had more fresh water per person (190 liters/day) than many modern cities.",
            buildingTeaser: "River materials build: Aqueduct, Roman Baths, Glassworks, Arsenal, and more"
        ),

        DiscoveryCard(
            id: "mine",
            stationName: "The Mine",
            italianName: "La Miniera",
            icon: "pickaxe.fill",
            color: RenaissanceColors.warmBrown,
            storyText: "Roman mines stretched from Spain to Britain. Iron ore became nails, clamps, and tools. Copper and tin became bronze for doors, gears, and statues. Lead became pipes, roofing, and type metal. Miners followed ore veins underground by candlelight, using fire-setting (heating rock then dousing with water to crack it). The metals beneath the earth built everything above it.",
            funFact: "The Colosseum used 300 tons of iron clamps — medieval looters pried them all out, leaving the holes you see today.",
            buildingTeaser: "Mined metals build: Colosseum, Siege Workshop, Printing Press, and more"
        ),

        DiscoveryCard(
            id: "clayPit",
            stationName: "The Clay Pit",
            italianName: "La Cava d'Argilla",
            icon: "rectangle.split.3x1.fill",
            color: RenaissanceColors.terracotta,
            storyText: "Clay is earth that remembers. Mold it wet, fire it at 1,000°C, and it holds that shape forever. Romans made 4 million bricks for the Duomo, 3,000 roof tiles per insula, and enough terracotta to waterproof an empire. Tuscan clay is iron-rich — that's why Florence is red. The clay pit is the most humble station and the most essential. Every city is built from dirt, transformed by fire.",
            funFact: "Brunelleschi's Duomo contains 4 million bricks — each stamped with the maker's mark for quality control.",
            buildingTeaser: "Clay builds: Insula, Duomo, Siege Workshop, Glassworks, and more"
        ),

        DiscoveryCard(
            id: "market",
            stationName: "The Market",
            italianName: "Il Mercato",
            icon: "cart.fill",
            color: RenaissanceColors.ochre,
            storyText: "Rome's markets connected three continents. Silk from China. Lapis lazuli from Afghanistan. Natron from Egypt. Cobalt from Germany. Spices from India. The Silk Road wasn't one road — it was a web of traders, each carrying materials that no local quarry or mine could provide. Venice became the richest city in Europe because it sat at the crossroads. Trade isn't just commerce. It's how civilizations share their chemistry.",
            funFact: "Lapis lazuli traveled 6,000 km from Afghanistan to Rome — and cost more per gram than gold.",
            buildingTeaser: "Traded goods build: Colosseum (silk), Duomo (cobalt glass), Vatican Observatory (lapis), and more"
        ),

        DiscoveryCard(
            id: "farm",
            stationName: "The Farm",
            italianName: "La Fattoria",
            icon: "leaf.fill",
            color: RenaissanceColors.sageGreen,
            storyText: "Renaissance farms supplied more than food — they supplied building materials. Linen for canvas and sail. Hemp rope for scaffolding and ship rigging. Beeswax for lost-wax casting. Tallow for candles that lit workshops and anatomy theaters. Animal sinew twisted into torsion ropes for siege engines. Sheep wool mixed into plaster for insulation. The farm is where biology becomes engineering.",
            funFact: "Roman siege engine ropes were made from twisted animal sinew — organic springs storing enough energy to hurl 25 kg stones 300 meters.",
            buildingTeaser: "Farm materials support: Siege Workshop (sinew), Arsenal (hemp rope), and more"
        ),

        // ── FOREST TREES ───────────────────────────────────

        DiscoveryCard(
            id: "oak",
            stationName: "The Oak",
            italianName: "La Quercia",
            icon: "tree.fill",
            color: RenaissanceColors.warmBrown,
            storyText: "Oak is the king of building woods. Its interlocking grain resists splitting. Its tannins repel moisture and insects. Roman centering (temporary dome support), frigidarium trusses, catapult frames, ship hulls, and press frames — all oak. A single oak tree takes 100 years to mature. The Romans planted forests they would never harvest. Building for the future means planting for the future.",
            funFact: "Venice's Arsenal maintained a reserve of 100,000 seasoned oak logs — the world's first timber inventory system.",
            buildingTeaser: "Oak builds: Pantheon (centering), Roman Baths (trusses), Arsenal (hulls), and more"
        ),

        DiscoveryCard(
            id: "chestnut",
            stationName: "The Chestnut",
            italianName: "Il Castagno",
            icon: "leaf.fill",
            color: RenaissanceColors.warmBrown,
            storyText: "Chestnut burns steady and splits easy — the perfect fuel wood. Roman bath furnaces consumed chestnut logs every 30 minutes to maintain 300°C. Murano glassworks burned 6 tons of wood per day per furnace — and stripped the Dalmatian coast bare to feed them. Chestnut also frames workshop walls, resisting salt air in Venice's lagoon. The tree that heats civilizations is the one that burns most reliably.",
            funFact: "Murano glassworks furnaces burned continuously for months — shutting down cracked the crucible from thermal shock.",
            buildingTeaser: "Chestnut supports: Roman Baths (furnace fuel), Glassworks (ventilation frames)"
        ),

        DiscoveryCard(
            id: "cypress",
            stationName: "The Cypress",
            italianName: "Il Cipresso",
            icon: "tree.fill",
            color: RenaissanceColors.sageGreen,
            storyText: "Cypress is the tree of Italian cemeteries — and for good reason. Its natural oils (thujone and cedrol) repel insects and resist fungal decay. Ancient Egyptian cypress coffins still smell of cedar after 3,000 years. Renaissance builders used cypress for ceiling panels where aromatic preservation mattered — like the anatomy theater in Padua, where 3-day dissections required odor management. The tree of death preserving the study of death.",
            funFact: "Cypress wood contains thujone — the same compound found in absinthe — which naturally repels termites.",
            buildingTeaser: "Cypress builds: Anatomy Theater (aromatic ceiling panels)"
        ),

        DiscoveryCard(
            id: "walnut",
            stationName: "The Walnut",
            italianName: "Il Noce",
            icon: "leaf.fill",
            color: RenaissanceColors.warmBrown,
            storyText: "Walnut is the precision wood. Its tight, uniform grain carves equally well in every direction — unlike oak which splits along the grain. Renaissance carvers used walnut for the finest work: anatomy theater railings, catapult triggers, ship pulleys, and type cases. Its natural oils make it self-lubricating for mechanical parts. Walnut's signature deep brown comes from oil finishing, not staining. The most beautiful wood is the most functional.",
            funFact: "The terms 'uppercase' and 'lowercase' come from the position of walnut type trays in printing shops.",
            buildingTeaser: "Walnut builds: Anatomy Theater, Siege Workshop, Arsenal, Printing Press"
        ),

        DiscoveryCard(
            id: "poplar",
            stationName: "The Poplar",
            italianName: "Il Pioppo",
            icon: "tree.fill",
            color: RenaissanceColors.sageGreen,
            storyText: "Poplar grows 3 meters a year — the fastest useful timber. It's 40% lighter than oak and perfectly straight. Romans used it for scaffolding (cheap and disposable), while Renaissance painters used it for panel paintings (minimal grain showing through thin paint). The Mona Lisa sits on a single poplar panel. Leonardo's flying machine ribs were steam-bent poplar. The humblest tree carried the greatest ambitions.",
            funFact: "The Mona Lisa is painted on a poplar panel just 13mm thick — Leonardo sealed both sides with gesso to prevent warping.",
            buildingTeaser: "Poplar builds: Pantheon (scaffolding), Insula (upper frames), Flying Machine (wing ribs)"
        ),

        // ── CRAFTING ROOM ──────────────────────────────────

        DiscoveryCard(
            id: "workbench",
            stationName: "The Workbench",
            italianName: "Il Banco da Lavoro",
            icon: "wrench.and.screwdriver.fill",
            color: RenaissanceColors.ochre,
            storyText: "Every Roman building site had a mixing station. Concrete, mortar, glass batches, pigment pastes — all mixed by hand with exact recipes. Vitruvius wrote the ratios: 1 part lime to 3 parts pozzolana for concrete, 1 to 2 for mortar. Renaissance craftsmen added their own innovations: gypsum for fast-set, crushed brick for marine use, manganese to clear glass. The workbench is where recipes become reality.",
            funFact: "Vitruvius's concrete recipe from 25 BC is still referenced by modern marine engineers studying Roman harbor remains.",
            buildingTeaser: "Every building needs the workbench — it's where raw materials become construction materials"
        ),

        DiscoveryCard(
            id: "furnace",
            stationName: "The Furnace",
            italianName: "La Fornace",
            icon: "flame.circle.fill",
            color: RenaissanceColors.terracotta,
            storyText: "Fire transforms everything. Limestone at 900°C becomes quicklime — the binder in all concrete. Clay at 1,000°C becomes terracotta — waterproof tiles and bricks. Sand at 1,100°C becomes glass. Iron ore at 1,100°C becomes wrought iron. Lead at 327°C becomes pipes and type metal. Every temperature unlocks a different material. The furnace is the most powerful tool in the workshop — controlled destruction creating new substances.",
            funFact: "Roman kiln operators judged temperature by color: dull red (600°C), cherry red (800°C), orange (1,000°C), yellow-white (1,100°C).",
            buildingTeaser: "Every building needs the furnace — fire transforms raw materials into building materials"
        ),

        DiscoveryCard(
            id: "shelf",
            stationName: "The Storage Shelf",
            italianName: "Lo Scaffale",
            icon: "archivebox.fill",
            color: RenaissanceColors.ochre,
            storyText: "Roman engineers were obsessive organizers. Frontinus cataloged every aqueduct's flow rate. Arsenal workers labeled timber by cut date. Printers sorted type alphabetically into walnut cases. The storage shelf is where knowledge meets inventory — measuring, recording, and organizing everything the workshop produces. Without records, you repeat mistakes. Without inventory, you waste materials. The shelf is the workshop's memory.",
            funFact: "Frontinus wrote De Aquaeductu — the world's first infrastructure management manual — to track Rome's water supply.",
            buildingTeaser: "The shelf stores completed materials and tracks your building progress"
        ),

        DiscoveryCard(
            id: "pigmentTable",
            stationName: "The Pigment Table",
            italianName: "Il Tavolo dei Pigmenti",
            icon: "paintpalette.fill",
            color: RenaissanceColors.deepTeal,
            storyText: "Color was currency in the Renaissance. Ultramarine from lapis lazuli cost more than gold. Red ochre from Turkey painted the Sistine Chapel's underdrawing. Cobalt from Germany colored the Duomo's stained glass. Each pigment was ground by hand on a marble slab with a muller — hours of work for a few grams of paint. The pigment table is where geology becomes art. Rocks ground to dust, mixed with oil, become immortal.",
            funFact: "Extracting ultramarine from lapis lazuli required 3 weeks of kneading the crushed stone with pine resin, wax, and lye.",
            buildingTeaser: "Pigments color: Duomo (red ochre frescoes), Vatican Observatory (ultramarine ceiling)"
        ),
    ]
}
