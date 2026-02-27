import SwiftUI

// MARK: - Knowledge Card Model

/// Where in the game world a knowledge card appears
enum CardEnvironment: String, CaseIterable, Codable {
    case workshop       // Outdoor resource stations
    case forest         // Tree POIs
    case craftingRoom   // Indoor furniture stations
    case cityMap        // At the building itself
}

/// Activity types for the back of a knowledge card
enum CardActivityType: Codable, Equatable {
    case keywordMatch                                                         // Tap word → tap definition (proven forest pattern)
    case fillInBlanks(text: String, blanks: [String], distractors: [String])  // Complete a sentence
    case multipleChoice(question: String, options: [String], correctIndex: Int)
    case trueFalse(statement: String, isTrue: Bool)
    case wordScramble(word: String, hint: String)                             // Scrambled letter tiles — tap in order
    case numberFishing(question: String, correctAnswer: Int, decoys: [Int])   // Floating numbers — tap the right one
    case hangman(word: String, hint: String)                                  // Classic hangman with alphabet grid

    // MARK: - Custom Codable

    private enum CodingKeys: String, CodingKey { case type, data }
    private enum ActivityCodingType: String, Codable {
        case keywordMatch, fillInBlanks, multipleChoice, trueFalse
        case wordScramble, numberFishing, hangman
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .keywordMatch:
            try container.encode(ActivityCodingType.keywordMatch, forKey: .type)
        case .fillInBlanks(let text, let blanks, let distractors):
            try container.encode(ActivityCodingType.fillInBlanks, forKey: .type)
            try container.encode([text] + blanks + ["|||"] + distractors, forKey: .data)
        case .multipleChoice(let q, let opts, let idx):
            try container.encode(ActivityCodingType.multipleChoice, forKey: .type)
            try container.encode([q] + opts + ["\(idx)"], forKey: .data)
        case .trueFalse(let stmt, let isTrue):
            try container.encode(ActivityCodingType.trueFalse, forKey: .type)
            try container.encode([stmt, isTrue ? "true" : "false"], forKey: .data)
        case .wordScramble(let word, let hint):
            try container.encode(ActivityCodingType.wordScramble, forKey: .type)
            try container.encode([word, hint], forKey: .data)
        case .numberFishing(let question, let correct, let decoys):
            try container.encode(ActivityCodingType.numberFishing, forKey: .type)
            try container.encode([question, "\(correct)"] + decoys.map { "\($0)" }, forKey: .data)
        case .hangman(let word, let hint):
            try container.encode(ActivityCodingType.hangman, forKey: .type)
            try container.encode([word, hint], forKey: .data)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(ActivityCodingType.self, forKey: .type)
        switch type {
        case .keywordMatch:
            self = .keywordMatch
        case .fillInBlanks:
            let parts = try container.decode([String].self, forKey: .data)
            if let sep = parts.firstIndex(of: "|||"), parts.count > 1 {
                self = .fillInBlanks(text: parts[0], blanks: Array(parts[1..<sep]), distractors: Array(parts[(sep+1)...]))
            } else {
                self = .keywordMatch
            }
        case .multipleChoice:
            let parts = try container.decode([String].self, forKey: .data)
            if parts.count >= 3, let idx = Int(parts.last ?? "") {
                self = .multipleChoice(question: parts[0], options: Array(parts[1..<(parts.count-1)]), correctIndex: idx)
            } else {
                self = .keywordMatch
            }
        case .trueFalse:
            let parts = try container.decode([String].self, forKey: .data)
            self = .trueFalse(statement: parts.first ?? "", isTrue: parts.last == "true")
        case .wordScramble:
            let parts = try container.decode([String].self, forKey: .data)
            self = .wordScramble(word: parts.first ?? "", hint: parts.count > 1 ? parts[1] : "")
        case .numberFishing:
            let parts = try container.decode([String].self, forKey: .data)
            let question = parts.first ?? ""
            let correct = parts.count > 1 ? (Int(parts[1]) ?? 0) : 0
            let decoys = parts.dropFirst(2).compactMap { Int($0) }
            self = .numberFishing(question: question, correctAnswer: correct, decoys: decoys)
        case .hangman:
            let parts = try container.decode([String].self, forKey: .data)
            self = .hangman(word: parts.first ?? "", hint: parts.count > 1 ? parts[1] : "")
        }
    }
}

/// A single knowledge card — placed at a station in an environment, teaches about a specific building
struct KnowledgeCard: Identifiable {
    let id: String                    // Deterministic: "{buildingId}_{environment}_{stationKey}_{index}"
    let buildingId: Int               // Which building this teaches about
    let buildingName: String
    let science: Science              // Which science this covers
    let environment: CardEnvironment  // Where this card appears
    let stationKey: String            // Which station (e.g., "quarry", "oak", "workbench")
    let title: String                 // Card front title
    let italianTitle: String          // Italian term
    let icon: String                  // SF Symbol for card front
    let lessonText: String            // Card back — short reading (50-80 words)
    let keywords: [KeywordPair]       // 3-4 keyword/definition pairs for keyword match
    let activity: CardActivityType    // Activity type on card back
    let notebookSummary: String       // What gets saved to the notebook on completion

    /// Color based on science
    var color: Color {
        scienceColor(science)
    }
}

/// Color mapping for sciences (used on card fronts/backs)
func scienceColor(_ science: Science) -> Color {
    switch science {
    case .engineering:  return RenaissanceColors.warmBrown
    case .mathematics:  return RenaissanceColors.renaissanceBlue
    case .physics:      return RenaissanceColors.deepTeal
    case .chemistry:    return RenaissanceColors.terracotta
    case .geometry:     return RenaissanceColors.ochre
    case .architecture: return RenaissanceColors.ochre
    case .hydraulics:   return RenaissanceColors.renaissanceBlue
    case .geology:      return RenaissanceColors.warmBrown
    case .materials:    return RenaissanceColors.terracotta
    case .biology:      return RenaissanceColors.sageGreen
    case .optics:       return RenaissanceColors.goldSuccess
    case .acoustics:    return RenaissanceColors.deepTeal
    case .astronomy:    return Color.indigo
    }
}

// MARK: - Content Router

enum KnowledgeCardContent {

    /// All cards for a building
    static func cards(for buildingName: String) -> [KnowledgeCard] {
        switch buildingName {
        case "Pantheon":       return pantheonCards
        // TODO: Add remaining 16 buildings
        default: return []
        }
    }

    /// Cards for a building at a specific station
    static func cards(for buildingName: String, at stationKey: String) -> [KnowledgeCard] {
        cards(for: buildingName).filter { $0.stationKey == stationKey }
    }

    /// Cards for a building in a specific environment
    static func cards(for buildingName: String, in environment: CardEnvironment) -> [KnowledgeCard] {
        cards(for: buildingName).filter { $0.environment == environment }
    }

    /// All cards for a building at a given station — returns empty if no building active
    static func cards(forBuildingId buildingId: Int, at stationKey: String, buildings: [String: Int]) -> [KnowledgeCard] {
        guard let name = buildings.first(where: { $0.value == buildingId })?.key else { return [] }
        return cards(for: name, at: stationKey)
    }

    // MARK: - Pantheon (14 cards)
    // Writing style: Morgan Housel — story-driven, surprising, punchy.
    // Start with a hook. Make complex ideas feel obvious. End with a twist.

    private static var pantheonCards: [KnowledgeCard] {
        let bid = 4
        let name = "Pantheon"
        return [
            // ── CITY MAP (5 cards) ────────────────────────────

            KnowledgeCard(
                id: "\(bid)_cityMap_building_0",
                buildingId: bid, buildingName: name,
                science: .architecture,
                environment: .cityMap, stationKey: "building",
                title: "Temple of All Gods",
                italianTitle: "Tempio di Tutti gli Dei",
                icon: "building.columns.fill",
                lessonText: "Sixteen columns guard the Pantheon's entrance. Each one is 12 meters tall, weighs 60 tons, and traveled by ship from Egypt. That's a 2,000-kilometer journey for a single piece of stone — before engines existed. Emperor Hadrian built this around 125 AD. The name means 'all gods' in Greek. He wasn't thinking small.",
                keywords: [
                    KeywordPair(keyword: "Pantheon", definition: "Temple dedicated to all the gods"),
                    KeywordPair(keyword: "Portico", definition: "Covered entrance with columns"),
                    KeywordPair(keyword: "Hadrian", definition: "Roman emperor who built the Pantheon"),
                    KeywordPair(keyword: "Granite", definition: "Hard stone used for the columns"),
                ],
                activity: .hangman(word: "PANTHEON", hint: "Temple dedicated to all the gods"),
                notebookSummary: "Emperor Hadrian built the Pantheon (~125 AD) — 'temple of all gods.' 16 granite columns shipped 2,000 km from Egypt."
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_1",
                buildingId: bid, buildingName: name,
                science: .geometry,
                environment: .cityMap, stationKey: "building",
                title: "A Perfect Sphere",
                italianTitle: "Una Sfera Perfetta",
                icon: "circle.circle",
                lessonText: "If you could roll a giant ball inside the Pantheon, it would fit perfectly — touching the floor and the top of the dome. The height and diameter are identical: 43.3 meters. That's not a coincidence. The Romans encoded meaning into math. The circular dome represented the heavens. The square floor, the earth. One building, two worlds.",
                keywords: [
                    KeywordPair(keyword: "Sphere", definition: "3D shape — dome height equals diameter"),
                    KeywordPair(keyword: "43.3 meters", definition: "Both the height and diameter of the dome"),
                    KeywordPair(keyword: "Proportion", definition: "Mathematical relationship between dimensions"),
                ],
                activity: .numberFishing(question: "What is the dome's height and diameter in meters?", correctAnswer: 43, decoys: [28, 35, 51, 60, 72]),
                notebookSummary: "A perfect sphere fits inside. Height = diameter = 43.3m. Circle dome = heavens, square floor = earth."
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_2",
                buildingId: bid, buildingName: name,
                science: .architecture,
                environment: .cityMap, stationKey: "building",
                title: "The Eye of the Pantheon",
                italianTitle: "L'Occhio del Pantheon",
                icon: "eye.fill",
                lessonText: "There are no windows. The only light comes from a 9-meter hole at the top of the dome — the oculus, 'the eye.' As the Earth rotates, the light beam crawls across the walls like a sundial. What about rain? It falls straight in. But 22 nearly invisible drain holes in the floor handle it. The hole also makes the dome lighter exactly where it's thinnest.",
                keywords: [
                    KeywordPair(keyword: "Oculus", definition: "Circular opening at the dome's top"),
                    KeywordPair(keyword: "Apex", definition: "Highest point of the dome"),
                    KeywordPair(keyword: "Sundial", definition: "Light beam tracks time across the floor"),
                    KeywordPair(keyword: "Drain holes", definition: "22 floor openings that channel rain away"),
                ],
                activity: .wordScramble(word: "OCULUS", hint: "The circular opening at the dome's top — 'the eye'"),
                notebookSummary: "The oculus — a 9m hole — is the only light source. Light sweeps like a sundial. Rain enters and drains through 22 floor holes."
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_3",
                buildingId: bid, buildingName: name,
                science: .geometry,
                environment: .cityMap, stationKey: "building",
                title: "Coffered Dome",
                italianTitle: "Cupola a Cassettoni",
                icon: "square.grid.3x3",
                lessonText: "Look up inside the dome and you'll see 28 rows of sunken square panels — coffers. Tourists think they're decoration. Engineers know better. Each coffer scoops out about 2 tons of concrete. Multiply that across the entire dome and you've removed roughly 2,400 tons of dead weight. The prettiest part of the building is also the smartest.",
                keywords: [
                    KeywordPair(keyword: "Coffer", definition: "Recessed square panel in a ceiling"),
                    KeywordPair(keyword: "28 rows", definition: "Number of coffer rows in the dome"),
                    KeywordPair(keyword: "Lighten", definition: "Coffers reduce the dome's weight"),
                ],
                activity: .numberFishing(question: "How many rows of coffers are in the dome?", correctAnswer: 28, decoys: [14, 22, 36, 42, 50]),
                notebookSummary: "28 rows of coffers look like decoration but remove ~2,400 tons. The prettiest part is the smartest engineering."
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_4",
                buildingId: bid, buildingName: name,
                science: .architecture,
                environment: .cityMap, stationKey: "building",
                title: "Hidden Relieving Arches",
                italianTitle: "Archi di Scarico Nascosti",
                icon: "archivebox.fill",
                lessonText: "The Pantheon has a skeleton. You just can't see it. Buried inside the 6-meter-thick walls are brick arches that channel the dome's crushing weight down to eight massive piers at ground level. Without this hidden framework, the walls would have split apart centuries ago. The best engineering is often invisible.",
                keywords: [
                    KeywordPair(keyword: "Relieving arch", definition: "Hidden arch that redirects weight downward"),
                    KeywordPair(keyword: "Pier", definition: "Thick pillar supporting massive loads"),
                    KeywordPair(keyword: "Load path", definition: "Route weight travels through a structure"),
                ],
                activity: .hangman(word: "PIER", hint: "Thick pillar supporting massive loads"),
                notebookSummary: "Hidden brick arches inside 6m-thick walls funnel the dome's weight to 8 ground piers. The best engineering is invisible."
            ),

            // ── WORKSHOP (4 cards) ───────────────────────────

            KnowledgeCard(
                id: "\(bid)_workshop_quarry_0",
                buildingId: bid, buildingName: name,
                science: .materials,
                environment: .workshop, stationKey: "quarry",
                title: "Limestone & Travertine",
                italianTitle: "Calcare e Travertino",
                icon: "mountain.2.fill",
                lessonText: "Every dome wants to push its walls outward. That's physics. The Pantheon fights this with weight — its foundation is built from travertine, the same dense stone as the Colosseum. Each block weighs 5 tons, quarried near Tivoli where hot springs deposited limestone over millennia. Workers split them with iron wedges hammered into drilled holes. Heavy stone at the bottom keeps everything from flying apart at the top.",
                keywords: [
                    KeywordPair(keyword: "Travertine", definition: "Limestone formed by hot spring deposits"),
                    KeywordPair(keyword: "Tivoli", definition: "Town near Rome with famous quarries"),
                    KeywordPair(keyword: "Thrust", definition: "Outward force a dome exerts on walls"),
                    KeywordPair(keyword: "Iron wedge", definition: "Tool driven into stone to split it"),
                ],
                activity: .wordScramble(word: "TRAVERTINE", hint: "Limestone formed by hot spring deposits near Tivoli"),
                notebookSummary: "5-ton travertine blocks from Tivoli anchor the foundation. Heavy stone at the bottom counteracts the dome's outward thrust."
            ),

            KnowledgeCard(
                id: "\(bid)_workshop_volcano_0",
                buildingId: bid, buildingName: name,
                science: .chemistry,
                environment: .workshop, stationKey: "volcano",
                title: "Volcanic Ash — Pozzolana",
                italianTitle: "Cenere Vulcanica — Pozzolana",
                icon: "flame.fill",
                lessonText: "Modern concrete lasts about 100 years. Roman concrete has lasted 2,000. The difference? Volcanic ash. Romans mixed pozzolana — ash from near Mount Vesuvius — with lime and water. The silica in the ash triggered a chemical reaction that gets stronger over time, not weaker. It even sets underwater. Roman harbors still stand on the seafloor. We only recently figured out why.",
                keywords: [
                    KeywordPair(keyword: "Pozzolana", definition: "Volcanic ash that makes Roman concrete"),
                    KeywordPair(keyword: "Silica", definition: "Chemical in ash that strengthens concrete"),
                    KeywordPair(keyword: "Hydraulic", definition: "Sets and hardens even underwater"),
                    KeywordPair(keyword: "Lime", definition: "Calcium oxide — mixed with ash to make concrete"),
                ],
                activity: .wordScramble(word: "POZZOLANA", hint: "Volcanic ash that makes Roman concrete last 2,000 years"),
                notebookSummary: "Roman concrete outlasts modern by 20x. Secret: pozzolana (volcanic ash) + lime. The silica reaction strengthens over time. Sets underwater."
            ),

            KnowledgeCard(
                id: "\(bid)_workshop_river_0",
                buildingId: bid, buildingName: name,
                science: .materials,
                environment: .workshop, stationKey: "river",
                title: "Graduated Aggregate",
                italianTitle: "Aggregato Graduato",
                icon: "drop.triangle.fill",
                lessonText: "Here's something counterintuitive: the Pantheon's dome is made of different concrete at different heights. Heavy travertine chunks at the base. Medium-weight tufa in the middle. Featherweight pumice — volcanic rock so light it floats on water — near the top. The dome literally gets lighter as it rises. Less weight where the structure is thinnest. Simple idea. Took a genius to think of it.",
                keywords: [
                    KeywordPair(keyword: "Aggregate", definition: "Stones mixed into concrete for strength"),
                    KeywordPair(keyword: "Pumice", definition: "Lightweight volcanic rock full of air holes"),
                    KeywordPair(keyword: "Tufa", definition: "Medium-weight volcanic stone"),
                    KeywordPair(keyword: "Graduated", definition: "Changing density from heavy to light"),
                ],
                activity: .hangman(word: "PUMICE", hint: "Volcanic rock so light it floats on water"),
                notebookSummary: "Different concrete at different heights: heavy travertine (base) → tufa (middle) → pumice that floats on water (top). Lighter where thinnest."
            ),

            KnowledgeCard(
                id: "\(bid)_workshop_mine_0",
                buildingId: bid, buildingName: name,
                science: .materials,
                environment: .workshop, stationKey: "mine",
                title: "Bronze & Lead",
                italianTitle: "Bronzo e Piombo",
                icon: "shield.lefthalf.filled",
                lessonText: "The Pantheon's dome once gleamed with gilded bronze tiles — gold over bronze, visible for miles. In 663 AD, Byzantine Emperor Constans II sailed to Rome and stripped every tile. Centuries later, Pope Urban VIII melted 200 tons of bronze from the portico ceiling to build Bernini's famous canopy in St. Peter's. Romans built it. Everyone else recycled it.",
                keywords: [
                    KeywordPair(keyword: "Gilded bronze", definition: "Bronze covered with a thin layer of gold"),
                    KeywordPair(keyword: "Lead clamp", definition: "Metal fastener joining stone or timber"),
                    KeywordPair(keyword: "Baldachin", definition: "Ornamental canopy over an altar"),
                ],
                activity: .numberFishing(question: "How many tons of bronze did Pope Urban VIII melt?", correctAnswer: 200, decoys: [50, 100, 350, 500, 800]),
                notebookSummary: "Once covered in gilded bronze. Stripped by Emperor Constans II (663 AD). Pope Urban VIII melted 200 tons for Bernini's baldachin. Romans built it; everyone else recycled it."
            ),

            // ── FOREST (2 cards) ─────────────────────────────

            KnowledgeCard(
                id: "\(bid)_forest_oak_0",
                buildingId: bid, buildingName: name,
                science: .engineering,
                environment: .forest, stationKey: "oak",
                title: "Timber Centering",
                italianTitle: "Centina di Legno",
                icon: "arrowshape.turn.up.backward.badge.clock",
                lessonText: "Before the dome existed, a wooden one had to be built first. Oak beams were curved into a massive temporary frame — centering — that held the wet concrete while it hardened. For three weeks, this timber skeleton carried thousands of tons. Then it was removed from below and the concrete stood on its own. The thing that made the dome possible was designed to disappear.",
                keywords: [
                    KeywordPair(keyword: "Centering", definition: "Temporary frame supporting a dome during construction"),
                    KeywordPair(keyword: "Curing", definition: "Chemical hardening of concrete over time"),
                    KeywordPair(keyword: "Deflection", definition: "Bending under weight — centering must resist this"),
                ],
                activity: .wordScramble(word: "CENTERING", hint: "Temporary frame supporting a dome during construction"),
                notebookSummary: "A temporary oak framework (centering) held wet concrete for 3 weeks. Then removed — designed to make the dome possible and disappear."
            ),

            KnowledgeCard(
                id: "\(bid)_forest_poplar_0",
                buildingId: bid, buildingName: name,
                science: .engineering,
                environment: .forest, stationKey: "poplar",
                title: "Scaffolding & Formwork",
                italianTitle: "Impalcatura e Cassaforma",
                icon: "square.stack.3d.up",
                lessonText: "Poplar grows 3 meters a year. It's light, cheap, and disposable — which made it perfect for scaffolding. Workers stood on poplar platforms 43 meters up, pouring concrete ring by ring. Poplar formwork shaped each layer of the dome like a mold. When construction finished, the wood became crates and firewood. Nothing was wasted in Rome.",
                keywords: [
                    KeywordPair(keyword: "Scaffolding", definition: "Temporary platforms for workers at height"),
                    KeywordPair(keyword: "Formwork", definition: "Wooden mold that shapes wet concrete"),
                    KeywordPair(keyword: "Layer by layer", definition: "Dome built in horizontal rings, bottom to top"),
                ],
                activity: .hangman(word: "SCAFFOLDING", hint: "Temporary platforms for workers at height"),
                notebookSummary: "Fast-growing poplar: light, cheap, disposable. Workers stood 43m up on poplar platforms. Afterward, recycled into crates and firewood."
            ),

            // ── CRAFTING ROOM (3 cards) ──────────────────────

            KnowledgeCard(
                id: "\(bid)_craftingRoom_workbench_0",
                buildingId: bid, buildingName: name,
                science: .chemistry,
                environment: .craftingRoom, stationKey: "workbench",
                title: "Mixing Roman Concrete",
                italianTitle: "Miscelare il Calcestruzzo Romano",
                icon: "flask.fill",
                lessonText: "The recipe hasn't been improved in 2,000 years. Vitruvius wrote it down: 1 part lime to 3 parts volcanic ash. First, workers added water to quicklime — a reaction so hot it could burn skin. Then they mixed in pozzolana and stone aggregate, poured it into wooden molds, and packed it down with tools. One layer at a time. Patience was the secret ingredient.",
                keywords: [
                    KeywordPair(keyword: "Vitruvius", definition: "Roman architect who wrote the recipe"),
                    KeywordPair(keyword: "Slaking", definition: "Adding water to quicklime (hot reaction)"),
                    KeywordPair(keyword: "1:3 ratio", definition: "1 part lime to 3 parts pozzolana"),
                    KeywordPair(keyword: "Tamping", definition: "Compacting concrete with wooden tools"),
                ],
                activity: .wordScramble(word: "VITRUVIUS", hint: "Roman architect who wrote the concrete recipe"),
                notebookSummary: "Vitruvius's 2,000-year-old recipe: 1 lime + 3 pozzolana. Slake quicklime (dangerously hot), mix with ash, pour into molds, tamp. Patience is the secret ingredient."
            ),

            KnowledgeCard(
                id: "\(bid)_craftingRoom_furnace_0",
                buildingId: bid, buildingName: name,
                science: .chemistry,
                environment: .craftingRoom, stationKey: "furnace",
                title: "Firing Quicklime",
                italianTitle: "Cottura della Calce Viva",
                icon: "flame.circle.fill",
                lessonText: "Take a piece of limestone. Heat it to 900°C. The carbon dioxide burns off and you're left with a white powder — quicklime — that explodes when it touches water. Roman kilns ran day and night, eating through entire forests for fuel. One chemical equation powered an empire: CaCO₃ → CaO + CO₂. Limestone becomes quicklime. Heat transforms everything.",
                keywords: [
                    KeywordPair(keyword: "Quicklime", definition: "Calcium oxide — made by heating limestone"),
                    KeywordPair(keyword: "900°C", definition: "Temperature needed to convert limestone"),
                    KeywordPair(keyword: "Kiln", definition: "High-temperature oven for firing materials"),
                    KeywordPair(keyword: "CaCO₃ → CaO + CO₂", definition: "Limestone loses carbon dioxide when heated"),
                ],
                activity: .numberFishing(question: "What temperature (°C) converts limestone to quicklime?", correctAnswer: 900, decoys: [450, 600, 750, 1100, 1500]),
                notebookSummary: "Heat limestone to 900°C → CO₂ burns off → quicklime (CaO) remains. Reacts violently with water. One equation powered an empire."
            ),

            KnowledgeCard(
                id: "\(bid)_craftingRoom_pigmentTable_0",
                buildingId: bid, buildingName: name,
                science: .architecture,
                environment: .craftingRoom, stationKey: "pigmentTable",
                title: "Marble Finishing",
                italianTitle: "Finitura in Marmo",
                icon: "paintbrush.fill",
                lessonText: "The Pantheon's walls are concrete. But you'd never know it. Every surface is covered in marble shipped from three continents: yellow giallo antico from Tunisia, purple pavonazzetto from Turkey, grey granite from Egypt. Craftsmen sliced these stones paper-thin and pinned them to the walls with bronze clamps. The floor alone uses 7 types of marble. The building is a map of the Empire.",
                keywords: [
                    KeywordPair(keyword: "Veneer", definition: "Thin decorative marble slice on a wall"),
                    KeywordPair(keyword: "Giallo antico", definition: "Yellow marble from Tunisia"),
                    KeywordPair(keyword: "Pavonazzetto", definition: "Purple-veined marble from Turkey"),
                ],
                activity: .hangman(word: "VENEER", hint: "Thin decorative marble slice covering a wall"),
                notebookSummary: "Concrete walls hidden behind marble from 3 continents. 7 types of marble in the floor. The building is a map of the Roman Empire."
            ),
        ]
    }
}
    // Aqua Claudia stretched 69 km. Only 16 km on arches. The rest? Underground.
