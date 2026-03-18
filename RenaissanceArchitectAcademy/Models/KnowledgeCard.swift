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

    // MARK: - Pantheon (14 cards — mapped to 8 construction steps)
    // Writing style: Morgan Housel — story-driven, surprising, punchy.
    // Each card teaches ONE construction step so the player knows the building order.
    // Steps: 1.Foundation → 2.Walls → 3.Coffers → 4.Grade Concrete → 5.Pour Dome → 6.Oculus → 7.Bronze Doors → 8.Marble Floor

    private static var pantheonCards: [KnowledgeCard] {
        let bid = 4
        let name = "Pantheon"
        return [
            // ── CITY MAP (5 cards): Steps 1-3 + overview ─────

            KnowledgeCard(
                id: "\(bid)_cityMap_building_0",
                buildingId: bid, buildingName: name,
                science: .architecture,
                environment: .cityMap, stationKey: "building",
                title: "Temple of All Gods",
                italianTitle: "Tempio di Tutti gli Dei",
                icon: "building.columns.fill",
                lessonText: "Sixteen columns guard the Pantheon's entrance. Each one is 12 meters tall, weighs 60 tons, and traveled by ship from Egypt. Emperor Hadrian built this around 125 AD. The name means 'all gods.' To build it, you'll follow 8 steps — from laying the ring foundation to finishing the marble floor. Every step builds on the last.",
                keywords: [
                    KeywordPair(keyword: "Pantheon", definition: "Temple dedicated to all the gods"),
                    KeywordPair(keyword: "Portico", definition: "Covered entrance with columns"),
                    KeywordPair(keyword: "Hadrian", definition: "Roman emperor who built the Pantheon"),
                    KeywordPair(keyword: "8 steps", definition: "Foundation → walls → coffers → concrete → dome → oculus → doors → floor"),
                ],
                activity: .hangman(word: "PANTHEON", hint: "Temple dedicated to all the gods"),
                notebookSummary: "Emperor Hadrian built the Pantheon (~125 AD). 16 granite columns from Egypt. Construction follows 8 steps: foundation → walls → coffers → concrete → dome → oculus → doors → floor."
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_1",
                buildingId: bid, buildingName: name,
                science: .engineering,
                environment: .cityMap, stationKey: "building",
                title: "Step 1: Ring Foundation",
                italianTitle: "Passo 1: Fondazione Anulare",
                icon: "circle.circle",
                lessonText: "Everything starts underground. A circular trench is dug 4.5 meters deep and filled with 7.3 meters of concrete — the ring foundation. This massive hidden circle distributes the dome's weight evenly into the clay beneath Rome. If the foundation isn't perfect, nothing above it will be. The strongest part of the building is the part you never see.",
                keywords: [
                    KeywordPair(keyword: "Ring foundation", definition: "Circular concrete base beneath the walls"),
                    KeywordPair(keyword: "4.5 meters", definition: "Depth of the foundation trench"),
                    KeywordPair(keyword: "7.3 meters", definition: "Width of the foundation ring"),
                    KeywordPair(keyword: "Load distribution", definition: "Spreading weight evenly across soft ground"),
                ],
                activity: .numberFishing(question: "How wide is the Pantheon's ring foundation (meters)?", correctAnswer: 7, decoys: [3, 5, 10, 15, 20]),
                notebookSummary: "STEP 1: Dig circular trench 4.5m deep, pour 7.3m-wide ring foundation. Distributes the dome's weight into soft Roman clay. Foundation first — always."
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_2",
                buildingId: bid, buildingName: name,
                science: .geometry,
                environment: .cityMap, stationKey: "building",
                title: "Step 2: Rotunda Walls",
                italianTitle: "Passo 2: Muri della Rotonda",
                icon: "square.stack.fill",
                lessonText: "The walls rise 6 meters thick — packed with hidden brick arches that channel the dome's weight downward to 8 piers. Height equals diameter: 43.3 meters. A perfect sphere fits inside. The Romans encoded meaning into math — circle dome for the heavens, square floor for the earth. Without these walls, the dome has nothing to push against.",
                keywords: [
                    KeywordPair(keyword: "Rotunda", definition: "Circular room beneath the dome"),
                    KeywordPair(keyword: "Relieving arch", definition: "Hidden arch inside walls that redirects weight"),
                    KeywordPair(keyword: "43.3 meters", definition: "Both height and diameter — a perfect sphere"),
                    KeywordPair(keyword: "Pier", definition: "Thick pillar that carries the dome's weight to ground"),
                ],
                activity: .numberFishing(question: "What is the dome's height and diameter in meters?", correctAnswer: 43, decoys: [28, 35, 51, 60, 72]),
                notebookSummary: "STEP 2: Build 6m-thick walls with hidden relieving arches. 8 piers carry the load. Height = diameter = 43.3m. Walls BEFORE dome."
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_3",
                buildingId: bid, buildingName: name,
                science: .geometry,
                environment: .cityMap, stationKey: "building",
                title: "Step 3: Coffers",
                italianTitle: "Passo 3: Cassettoni",
                icon: "square.grid.3x3",
                lessonText: "Before pouring the dome, the builders carved 28 rows of sunken panels — coffers — into the formwork. Tourists think they're decoration. Engineers know better. Each coffer removes about 2 tons of concrete. Across the entire dome: 2,400 tons gone. The coffers must be built INTO the dome as it rises, not carved after. The prettiest part is the smartest.",
                keywords: [
                    KeywordPair(keyword: "Coffer", definition: "Recessed square panel that reduces dome weight"),
                    KeywordPair(keyword: "28 rows", definition: "Number of coffer rows in the dome"),
                    KeywordPair(keyword: "2,400 tons", definition: "Weight removed by all coffers combined"),
                ],
                activity: .numberFishing(question: "How many rows of coffers are in the dome?", correctAnswer: 28, decoys: [14, 22, 36, 42, 50]),
                notebookSummary: "STEP 3: Build coffers INTO the formwork before pouring concrete. 28 rows remove 2,400 tons. Decoration that's actually engineering."
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_4",
                buildingId: bid, buildingName: name,
                science: .architecture,
                environment: .cityMap, stationKey: "building",
                title: "Step 6: The Oculus",
                italianTitle: "Passo 6: L'Oculo",
                icon: "eye.fill",
                lessonText: "After pouring the dome in rings, leave a 9-meter hole at the top — the oculus. No windows. This is the only light. As Earth rotates, the beam crawls like a sundial. Rain falls in through 22 drain holes. Here's the physics: the hole creates a compression ring that actually STRENGTHENS the dome's crown. The weakest-looking point is the strongest.",
                keywords: [
                    KeywordPair(keyword: "Oculus", definition: "9-meter opening at the dome's apex"),
                    KeywordPair(keyword: "Compression ring", definition: "Circle of force that strengthens the opening"),
                    KeywordPair(keyword: "Step 6", definition: "Oculus is opened AFTER the dome is poured"),
                ],
                activity: .wordScramble(word: "OCULUS", hint: "The 9-meter eye at the dome's top"),
                notebookSummary: "STEP 6: Open the 9m oculus AFTER pouring the dome. Creates a compression ring that strengthens the crown. Light enters, rain drains through 22 holes."
            ),

            // ── WORKSHOP (4 cards): Steps 1, 4, 7 materials ──

            KnowledgeCard(
                id: "\(bid)_workshop_quarry_0",
                buildingId: bid, buildingName: name,
                science: .materials,
                environment: .workshop, stationKey: "quarry",
                title: "Step 1 Material: Stone from the Quarry",
                italianTitle: "Materiale Passo 1: Pietra dalla Cava",
                icon: "mountain.2.fill",
                lessonText: "Here's a surprise: limestone and marble have the same chemical formula — CaCO₃. Marble is just limestone transformed by underground heat and pressure. Same rock, different destiny. Cheap limestone gets burned at 900°C to make concrete for the foundation (Step 1). Expensive marble gets sliced paper-thin for the floor (Step 8). One rock builds the skeleton. The other makes it beautiful.",
                keywords: [
                    KeywordPair(keyword: "CaCO₃", definition: "Chemical formula shared by limestone AND marble"),
                    KeywordPair(keyword: "Metamorphism", definition: "Heat + pressure transforms limestone into marble"),
                    KeywordPair(keyword: "Limestone", definition: "Burned into quicklime for concrete (Step 1)"),
                    KeywordPair(keyword: "Marble", definition: "Cut into decorative slabs for the floor (Step 8)"),
                ],
                activity: .trueFalse(statement: "Limestone and marble share the same chemical formula: CaCO₃", isTrue: true),
                notebookSummary: "STEP 1 & 8 MATERIAL: Limestone and marble are both CaCO₃. Limestone → burned for concrete (foundation). Marble → sliced for decoration (floor). Same rock, different destiny."
            ),

            KnowledgeCard(
                id: "\(bid)_workshop_volcano_0",
                buildingId: bid, buildingName: name,
                science: .chemistry,
                environment: .workshop, stationKey: "volcano",
                title: "Step 4 Material: Pozzolana",
                italianTitle: "Materiale Passo 4: Pozzolana",
                icon: "flame.fill",
                lessonText: "Step 4 — grading the concrete mix — requires volcanic ash. Romans mixed pozzolana from near Vesuvius with lime and water. The silica triggers a reaction that gets STRONGER over time. Modern concrete lasts 100 years. Roman concrete: 2,000. The secret isn't just the recipe — it's changing the aggregate at each height. Heavy basalt at base, light pumice at top.",
                keywords: [
                    KeywordPair(keyword: "Pozzolana", definition: "Volcanic ash for Step 4 concrete grading"),
                    KeywordPair(keyword: "Graduated mix", definition: "Heavy aggregate at base, light at top"),
                    KeywordPair(keyword: "Pumice", definition: "Volcanic rock so light it floats"),
                ],
                activity: .wordScramble(word: "POZZOLANA", hint: "Volcanic ash that makes concrete last 2,000 years"),
                notebookSummary: "STEP 4 MATERIAL: Pozzolana (volcanic ash) + lime = concrete that lasts 2,000 years. Grade it: heavy basalt (base) → light pumice (top)."
            ),

            KnowledgeCard(
                id: "\(bid)_workshop_river_0",
                buildingId: bid, buildingName: name,
                science: .materials,
                environment: .workshop, stationKey: "river",
                title: "Step 5: Pour in Rings",
                italianTitle: "Passo 5: Getto a Anelli",
                icon: "drop.triangle.fill",
                lessonText: "Step 5 is where everything comes together. The dome is poured in horizontal rings — each ring must cure before the next is added. Water is critical: too much weakens concrete, too little and it won't set. The ratio is exact. Each ring is self-supporting as it rises, so no centering is needed above the first few courses. Ring by ring, the dome closes toward the oculus.",
                keywords: [
                    KeywordPair(keyword: "Ring pouring", definition: "Building the dome in horizontal layers (Step 5)"),
                    KeywordPair(keyword: "Curing", definition: "Concrete hardening — each ring must cure first"),
                    KeywordPair(keyword: "Self-supporting", definition: "Each ring holds itself without centering"),
                ],
                activity: .trueFalse(statement: "The Pantheon dome was poured in horizontal rings, each curing before the next", isTrue: true),
                notebookSummary: "STEP 5: Pour dome in horizontal rings. Each ring cures before the next. Self-supporting as it rises. Ring by ring toward the oculus."
            ),

            KnowledgeCard(
                id: "\(bid)_workshop_mine_0",
                buildingId: bid, buildingName: name,
                science: .materials,
                environment: .workshop, stationKey: "mine",
                title: "Step 7 Material: Bronze",
                italianTitle: "Materiale Passo 7: Bronzo",
                icon: "shield.lefthalf.filled",
                lessonText: "Step 7 — install the bronze doors. Each door is 7 meters tall and weighs several tons, yet swings on bronze pivots. Lead clamps join the stone frame. The dome once gleamed with gilded bronze tiles too. In 663 AD, Emperor Constans II stripped every tile. Later, Pope Urban VIII melted 200 tons for Bernini's baldachin. Doors and fittings come near the END of construction.",
                keywords: [
                    KeywordPair(keyword: "Bronze doors", definition: "7m tall doors installed in Step 7"),
                    KeywordPair(keyword: "Lead clamp", definition: "Metal fastener joining stone to frame"),
                    KeywordPair(keyword: "Step 7", definition: "Doors installed AFTER the dome and oculus"),
                ],
                activity: .numberFishing(question: "How many tons of bronze did Pope Urban VIII melt?", correctAnswer: 200, decoys: [50, 100, 350, 500, 800]),
                notebookSummary: "STEP 7 MATERIAL: Bronze for doors (7m tall) and fittings. Lead clamps join stone. Doors go in AFTER dome + oculus. Near the end."
            ),

            // ── FOREST (2 cards): Step 5 support ─────────────

            KnowledgeCard(
                id: "\(bid)_forest_oak_0",
                buildingId: bid, buildingName: name,
                science: .engineering,
                environment: .forest, stationKey: "oak",
                title: "Step 5 Support: Centering",
                italianTitle: "Supporto Passo 5: Centina",
                icon: "arrowshape.turn.up.backward.badge.clock",
                lessonText: "Before Step 5 (pouring the dome), a wooden dome must be built first. Oak beams curve into a massive temporary frame — centering — that holds wet concrete while it cures. For three weeks, this timber skeleton carries thousands of tons. Then it's removed from below and the concrete stands alone. The thing that makes the dome possible is designed to disappear.",
                keywords: [
                    KeywordPair(keyword: "Centering", definition: "Temporary oak frame for Step 5 dome pouring"),
                    KeywordPair(keyword: "Curing", definition: "3 weeks for concrete to harden"),
                    KeywordPair(keyword: "Remove from below", definition: "Centering is dismantled after concrete sets"),
                ],
                activity: .wordScramble(word: "CENTERING", hint: "Temporary frame supporting the dome during Step 5"),
                notebookSummary: "STEP 5 SUPPORT: Oak centering holds wet concrete for 3 weeks. Then removed — designed to disappear after the dome cures."
            ),

            KnowledgeCard(
                id: "\(bid)_forest_poplar_0",
                buildingId: bid, buildingName: name,
                science: .engineering,
                environment: .forest, stationKey: "poplar",
                title: "Steps 2-5: Scaffolding",
                italianTitle: "Passi 2-5: Impalcatura",
                icon: "square.stack.3d.up",
                lessonText: "Poplar grows 3 meters a year — light, cheap, disposable. Perfect for scaffolding. Workers stood on poplar platforms 43 meters up throughout Steps 2 through 5: building walls, constructing coffers, grading concrete, pouring the dome ring by ring. Poplar formwork shaped each layer. When construction finished, the wood became crates and firewood. Nothing was wasted.",
                keywords: [
                    KeywordPair(keyword: "Scaffolding", definition: "Poplar platforms for Steps 2-5"),
                    KeywordPair(keyword: "Formwork", definition: "Wooden mold shaping wet concrete"),
                    KeywordPair(keyword: "Steps 2-5", definition: "Walls → coffers → concrete → dome pouring"),
                ],
                activity: .hangman(word: "SCAFFOLDING", hint: "Temporary poplar platforms used through Steps 2-5"),
                notebookSummary: "STEPS 2-5 SUPPORT: Poplar scaffolding for walls, coffers, concrete, dome. 43m up. Light, cheap, recycled after. Nothing wasted."
            ),

            // ── CRAFTING ROOM (3 cards): Steps 4, 1, 8 ──────

            KnowledgeCard(
                id: "\(bid)_craftingRoom_workbench_0",
                buildingId: bid, buildingName: name,
                science: .chemistry,
                environment: .craftingRoom, stationKey: "workbench",
                title: "Step 4: Mix the Concrete",
                italianTitle: "Passo 4: Miscelare il Calcestruzzo",
                icon: "flask.fill",
                lessonText: "Step 4 is grading the concrete — mixing different recipes for different heights. Vitruvius's ratio: 1 part lime to 3 parts volcanic ash. First, slake quicklime with water (dangerously hot reaction). Mix in pozzolana and aggregate. At the base: heavy basalt chunks. Middle: medium tufa. Top: light pumice. Pour into formwork, tamp with wooden tools. One layer at a time.",
                keywords: [
                    KeywordPair(keyword: "1:3 ratio", definition: "1 lime + 3 pozzolana (Step 4 recipe)"),
                    KeywordPair(keyword: "Slaking", definition: "Adding water to quicklime — very hot"),
                    KeywordPair(keyword: "Graduated", definition: "Heavy at base, light at top"),
                    KeywordPair(keyword: "Tamping", definition: "Compacting concrete with wooden tools"),
                ],
                activity: .wordScramble(word: "VITRUVIUS", hint: "Roman architect who wrote the Step 4 concrete recipe"),
                notebookSummary: "STEP 4: Grade concrete. 1 lime + 3 pozzolana. Heavy basalt (base) → tufa (middle) → pumice (top). Slake, mix, pour, tamp."
            ),

            KnowledgeCard(
                id: "\(bid)_craftingRoom_furnace_0",
                buildingId: bid, buildingName: name,
                science: .chemistry,
                environment: .craftingRoom, stationKey: "furnace",
                title: "Step 1: Fire the Quicklime",
                italianTitle: "Passo 1: Cottura della Calce",
                icon: "flame.circle.fill",
                lessonText: "Before Step 1 (foundation), you need quicklime. Take limestone, heat to 900°C. Carbon dioxide burns off: CaCO₃ → CaO + CO₂. The white powder left behind explodes when it touches water. Roman kilns ran day and night. This quicklime binds the foundation concrete. Without it, there IS no foundation. Fire transforms limestone into the glue that holds Rome together.",
                keywords: [
                    KeywordPair(keyword: "900°C", definition: "Temperature to make quicklime for Step 1"),
                    KeywordPair(keyword: "CaCO₃ → CaO + CO₂", definition: "Limestone becomes quicklime + carbon dioxide"),
                    KeywordPair(keyword: "Quicklime", definition: "Foundation binder — made BEFORE Step 1"),
                ],
                activity: .numberFishing(question: "What temperature (°C) converts limestone to quicklime?", correctAnswer: 900, decoys: [450, 600, 750, 1100, 1500]),
                notebookSummary: "BEFORE STEP 1: Fire limestone at 900°C → quicklime (CaO). The binder for foundation concrete. Must be made first."
            ),

            KnowledgeCard(
                id: "\(bid)_craftingRoom_pigmentTable_0",
                buildingId: bid, buildingName: name,
                science: .architecture,
                environment: .craftingRoom, stationKey: "pigmentTable",
                title: "Step 8: Marble Floor",
                italianTitle: "Passo 8: Pavimento in Marmo",
                icon: "diamond.fill",
                lessonText: "The final step. Seven types of marble from three continents cover the floor in geometric patterns — yellow giallo antico from Tunisia, purple pavonazzetto from Turkey, grey granite from Egypt. Craftsmen sliced stones paper-thin and pinned them to concrete walls with bronze clamps. The floor slopes slightly for rain drainage. Step 8 is the finishing touch — beauty meets function.",
                keywords: [
                    KeywordPair(keyword: "Step 8", definition: "Marble floor is the LAST construction step"),
                    KeywordPair(keyword: "Giallo antico", definition: "Yellow marble from Tunisia"),
                    KeywordPair(keyword: "Veneer", definition: "Thin marble slices covering concrete walls"),
                ],
                activity: .hangman(word: "VENEER", hint: "Thin marble slices covering the concrete walls (Step 8)"),
                notebookSummary: "STEP 8 (LAST): Marble floor + wall veneer. 7 types from 3 continents. Geometric patterns, slight slope for drainage. Beauty meets function."
            ),
        ]
    }
}
    // Aqua Claudia stretched 69 km. Only 16 km on arches. The rest? Underground.
