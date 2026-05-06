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

// MARK: - Card Visual Model (science diagram data)

/// Type of interactive science visual shown below lesson text on a knowledge card
enum CardVisualType {
    case reaction           // Molecules → arrow → products
    case crossSection       // Layered cutaway with dimensions
    case geometry           // Shapes with measurements
    case ratio              // Proportional bars with numbers
    case temperature        // Phase transition curve
    case force              // Load arrows on structure
    case flow               // Animated path movement
    case mechanism          // Moving parts (gears, press)
    case molecule           // Atom-bond structure
    case comparison         // Side-by-side difference
}

/// Pre-computed data for a science visual. All values bundled — no live API calls.
struct CardVisual {
    let type: CardVisualType
    let title: String                   // Label above visual
    let values: [String: Double]        // Pre-computed numbers
    let labels: [String]                // Dimension/annotation labels
    let steps: Int                      // Animation steps (3-5)
    var caption: String? = nil          // Optional caption below
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
    var funFact: String? = nil        // Optional fun fact shown in lightbulb callout
    var infographic: InfographicReveal? = nil  // Optional infographic with dust-reveal interaction
    var visual: CardVisual? = nil     // Optional interactive science visual below lesson text
    var isLeadCard: Bool = false      // Building's welcome card — adds "Ah, {name} —" vocative when narrated

    /// Color based on science — single source of truth in RenaissanceColors.color(for:)
    var color: Color {
        RenaissanceColors.color(for: science)
    }

}

// MARK: - Infographic Reveal

/// Data for the dust-reveal infographic reward on a knowledge card.
/// Shown after completing the card's activity as a cinematic reward.
/// Uses the same RadialGradient mask pattern as MainMenuView's dome reveal.
struct InfographicReveal {
    let imageName: String           // Asset catalog image name
    let zones: [InfographicZone]    // Auto-reveal zones (played one by one)
}

/// A reveal zone — normalized position + radius on the infographic
struct InfographicZone {
    let x: CGFloat      // 0-1 horizontal position
    let y: CGFloat      // 0-1 vertical position
    let radius: CGFloat // 0-1 relative to image width
    let label: String   // What this zone reveals
}

// MARK: - Content Router

enum KnowledgeCardContent {

    /// All cards for a building
    static func cards(for buildingName: String) -> [KnowledgeCard] {
        switch buildingName {
        // Ancient Rome
        case "Aqueduct":            return aqueductCards
        case "Colosseum":           return colosseumCards
        case "Roman Baths":         return romanBathsCards
        case "Pantheon":            return pantheonCards
        case "Roman Roads":         return romanRoadsCards
        case "Harbor":              return harborCards
        case "Siege Workshop":      return siegeWorkshopCards
        case "Insula":              return insulaCards
        // Renaissance
        case "Duomo", "Il Duomo":   return duomoCards
        case "Botanical Garden":    return botanicalGardenCards
        case "Glassworks":          return glassworksCards
        case "Arsenal":             return arsenalCards
        case "Anatomy Theater":     return anatomyTheaterCards
        case "Leonardo's Workshop": return leonardoWorkshopCards
        case "Flying Machine":      return flyingMachineCards
        case "Vatican Observatory": return vaticanObservatoryCards
        case "Printing Press":      return printingPressCards
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
                lessonText: "Look. Sixteen columns, standing guard. Each one twelve meters tall. Sixty tons of granite. Shipped across the sea from Egypt. Imagine the voyage. Emperor Hadrian built this around 125 AD, and he gave it a beautiful name — Pantheon, \"all the gods.\" Together, we will build it the Roman way. Eight steps in all. Foundation, walls, coffers. Concrete, dome, oculus. Doors, and floor. Each step rests on the one before. Are you ready?",
                keywords: [
                    KeywordPair(keyword: "Pantheon", definition: "Temple dedicated to all the gods"),
                    KeywordPair(keyword: "Portico", definition: "Covered entrance with columns"),
                    KeywordPair(keyword: "Hadrian", definition: "Roman emperor who built the Pantheon"),
                    KeywordPair(keyword: "8 steps", definition: "Foundation → walls → coffers → concrete → dome → oculus → doors → floor"),
                ],
                activity: .hangman(word: "PANTHEON", hint: "Temple dedicated to all the gods"),
                notebookSummary: "Emperor Hadrian built the Pantheon (~125 AD). 16 granite columns from Egypt. Construction follows 8 steps: foundation → walls → coffers → concrete → dome → oculus → doors → floor.",
                visual: CardVisual(
                    type: .force,
                    title: "16 Columns Carrying the Portico",
                    values: ["columns": 8, "height": 12, "perColumn": 60],
                    labels: ["×16 columns, 12m tall, 60 tons each"],
                    steps: 3, caption: "16 granite columns shipped from Egypt carry the entire portico"
                ),
                isLeadCard: true
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_1",
                buildingId: bid, buildingName: name,
                science: .engineering,
                environment: .cityMap, stationKey: "building",
                title: "Step 1: Ring Foundation",
                italianTitle: "Passo 1: Fondazione Anulare",
                icon: "circle.circle",
                lessonText: "Everything begins underground. See? Before a single column rises, the workers dig — a circle four and a half meters deep. They fill it with seven meters of concrete. We call this the ring foundation. This hidden circle… is what carries the entire dome. Spreads its weight evenly into the soft clay beneath Rome. If we get this wrong — if the circle is off, even by a little — nothing above will stand. Strange — no? The strongest part of the Pantheon is the part nobody ever sees.",
                keywords: [
                    KeywordPair(keyword: "Ring foundation", definition: "Circular concrete base beneath the walls"),
                    KeywordPair(keyword: "4.5 meters", definition: "Depth of the foundation trench"),
                    KeywordPair(keyword: "7.3 meters", definition: "Width of the foundation ring"),
                    KeywordPair(keyword: "Load distribution", definition: "Spreading weight evenly across soft ground"),
                ],
                activity: .numberFishing(question: "How wide is the Pantheon's ring foundation (meters)?", correctAnswer: 7, decoys: [3, 5, 10, 15, 20]),
                notebookSummary: "STEP 1: Dig circular trench 4.5m deep, pour 7.3m-wide ring foundation. Distributes the dome's weight into soft Roman clay. Foundation first — always.",
                infographic: InfographicReveal(
                    imageName: "PantheonStep1Infographic",
                    zones: [
                        InfographicZone(x: 0.50, y: 0.08, radius: 0.25, label: "Step 1: The Ring Foundation"),
                        InfographicZone(x: 0.20, y: 0.50, radius: 0.25, label: "Underground Construction"),
                        InfographicZone(x: 0.50, y: 0.55, radius: 0.28, label: "Pouring the Concrete"),
                        InfographicZone(x: 0.82, y: 0.25, radius: 0.22, label: "Even Load Distribution"),
                        InfographicZone(x: 0.82, y: 0.78, radius: 0.22, label: "Foundational Integrity"),
                    ]
                ),
                visual: CardVisual(
                    type: .crossSection,
                    title: "Ring Foundation Cross-Section",
                    values: ["depth": 4.5, "width": 7.3],
                    labels: ["Ground surface", "Trench dug 4.5m down", "Soft Roman clay", "Concrete ring (7.3m wide)"],
                    steps: 4, caption: "Hidden underground — the strongest part of the building is the part you never see"
                )
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_2",
                buildingId: bid, buildingName: name,
                science: .geometry,
                environment: .cityMap, stationKey: "building",
                title: "Step 2: Rotunda Walls",
                italianTitle: "Passo 2: Muri della Rotonda",
                icon: "square.stack.fill",
                lessonText: "Now we go up. The walls rise — six meters thick. Six. Inside them, hidden brick arches channel the dome's weight down. Down to eight massive piers. The math is beautiful. Height equals diameter — both forty-three meters. A perfect sphere fits inside. The Romans put meaning into geometry. The circle of the dome for the heavens. The square of the floor for the earth. Without these walls, the dome has nothing to push against. So the walls come second. Always.",
                keywords: [
                    KeywordPair(keyword: "Rotunda", definition: "Circular room beneath the dome"),
                    KeywordPair(keyword: "Relieving arch", definition: "Hidden arch inside walls that redirects weight"),
                    KeywordPair(keyword: "43.3 meters", definition: "Both height and diameter — a perfect sphere"),
                    KeywordPair(keyword: "Pier", definition: "Thick pillar that carries the dome's weight to ground"),
                ],
                activity: .numberFishing(question: "What is the dome's height and diameter in meters?", correctAnswer: 43, decoys: [28, 35, 51, 60, 72]),
                notebookSummary: "STEP 2: Build 6m-thick walls with hidden relieving arches. 8 piers carry the load. Height = diameter = 43.3m. Walls BEFORE dome.",
                visual: CardVisual(
                    type: .geometry,
                    title: "Perfect Sphere Inside the Rotunda",
                    values: ["diameter": 43.3, "height": 43.3, "wallThickness": 6],
                    labels: ["Height = Diameter = 43.3m", "A perfect sphere fits inside"],
                    steps: 3, caption: "6m-thick walls with 8 piers channel the dome's weight"
                )
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_3",
                buildingId: bid, buildingName: name,
                science: .geometry,
                environment: .cityMap, stationKey: "building",
                title: "Step 3: Coffers",
                italianTitle: "Passo 3: Cassettoni",
                icon: "square.grid.3x3",
                lessonText: "Look up. Twenty-eight rows of sunken panels — these are coffers. Tourists think they are decoration. Engineers know better. Each one removes about two tons of concrete. Across the whole dome — twenty-four hundred tons. Gone. Disappeared. The trick? Coffers must be built INTO the dome as it rises. Not carved after. The prettiest part of the Pantheon is also the smartest. Beautiful — no?",
                keywords: [
                    KeywordPair(keyword: "Coffer", definition: "Recessed square panel that reduces dome weight"),
                    KeywordPair(keyword: "28 rows", definition: "Number of coffer rows in the dome"),
                    KeywordPair(keyword: "2,400 tons", definition: "Weight removed by all coffers combined"),
                ],
                activity: .numberFishing(question: "How many rows of coffers are in the dome?", correctAnswer: 28, decoys: [14, 22, 36, 42, 50]),
                notebookSummary: "STEP 3: Build coffers INTO the formwork before pouring concrete. 28 rows remove 2,400 tons. Decoration that's actually engineering.",
                visual: CardVisual(
                    type: .force,
                    title: "28 Rows of Coffers Inside the Dome",
                    values: ["coffers": 1, "rows": 28, "removed": 2400, "total": 4535],
                    labels: ["Coffers = sunken square panels", "28 rows × ~86 tons each", "2,400 tons removed from the dome"],
                    steps: 3, caption: "The prettiest part of the dome is the smartest engineering"
                )
            ),

            KnowledgeCard(
                id: "\(bid)_cityMap_building_4",
                buildingId: bid, buildingName: name,
                science: .architecture,
                environment: .cityMap, stationKey: "building",
                title: "Step 6: The Oculus",
                italianTitle: "Passo 6: L'Oculo",
                icon: "eye.fill",
                lessonText: "Look up. Way up. There — a hole. Nine meters across. We call it the oculus. The eye. No windows in this temple — only this. As the earth turns, sunlight crawls across the floor like a sundial. When it rains, the water falls through, and twenty-two small drains carry it away. But here is the secret. The hole creates a ring of compression around its edge. That ring STRENGTHENS the dome's crown. The weakest-looking point — actually the strongest.",
                keywords: [
                    KeywordPair(keyword: "Oculus", definition: "9-meter opening at the dome's apex"),
                    KeywordPair(keyword: "Compression ring", definition: "Circle of force that strengthens the opening"),
                    KeywordPair(keyword: "Step 6", definition: "Oculus is opened AFTER the dome is poured"),
                ],
                activity: .wordScramble(word: "OCULUS", hint: "The 9-meter eye at the dome's top"),
                notebookSummary: "STEP 6: Open the 9m oculus AFTER pouring the dome. Creates a compression ring that strengthens the crown. Light enters, rain drains through 22 holes.",
                visual: CardVisual(
                    type: .force,
                    title: "Oculus Compression Ring",
                    values: ["oculus": 1, "diameter": 9, "arrows": 8],
                    labels: ["9m opening at dome crown", "Arrows = compression pushing INWARD", "The hole makes the dome STRONGER"],
                    steps: 3, caption: "The opening creates inward compression that strengthens the crown"
                )
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
                lessonText: "Now — here is a beautiful secret. Limestone and marble. Same rock. Same chemical formula — calcium carbonate. The difference? Heat and pressure. Deep underground, over millions of years. That is what turns one into the other. Cheap limestone — we burn it at nine hundred degrees to make the concrete of our foundation. Step 1. Expensive marble — we slice it paper-thin to cover the floor. Step 8. Same rock. Different destiny. One builds the skeleton. The other makes it beautiful.",
                keywords: [
                    KeywordPair(keyword: "CaCO₃", definition: "Chemical formula shared by limestone AND marble"),
                    KeywordPair(keyword: "Metamorphism", definition: "Heat + pressure transforms limestone into marble"),
                    KeywordPair(keyword: "Limestone", definition: "Burned into quicklime for concrete (Step 1)"),
                    KeywordPair(keyword: "Marble", definition: "Cut into decorative slabs for the floor (Step 8)"),
                ],
                activity: .trueFalse(statement: "Limestone and marble share the same chemical formula: CaCO₃", isTrue: true),
                notebookSummary: "STEP 1 & 8 MATERIAL: Limestone and marble are both CaCO₃. Limestone → burned for concrete (foundation). Marble → sliced for decoration (floor). Same rock, different destiny.",
                visual: CardVisual(
                    type: .comparison,
                    title: "Limestone vs Marble — Same Formula",
                    values: ["equal": 1],
                    labels: ["Limestone\nCaCO₃\nBurned → concrete", "Marble\nCaCO₃\nSliced → decoration", "Same chemical formula — heat + pressure transforms one into the other"],
                    steps: 3, caption: "Same rock, different destiny: foundation vs floor"
                )
            ),

            KnowledgeCard(
                id: "\(bid)_workshop_volcano_0",
                buildingId: bid, buildingName: name,
                science: .chemistry,
                environment: .workshop, stationKey: "volcano",
                title: "Step 4 Material: Pozzolana",
                italianTitle: "Materiale Passo 4: Pozzolana",
                icon: "flame.fill",
                lessonText: "Now we need a special ingredient. Pozzolana. Volcanic ash, gathered from the slopes of Vesuvius — yes, that Vesuvius. We mix it with lime and water. And something remarkable happens. The silica in the ash triggers a slow reaction. The concrete grows STRONGER over time. Modern concrete lasts a hundred years. Roman concrete — two thousand. But the recipe alone is not enough. We change the stone at each height. Heavy basalt at the base. Light pumice at the top. That is the real secret.",
                keywords: [
                    KeywordPair(keyword: "Pozzolana", definition: "Volcanic ash for Step 4 concrete grading"),
                    KeywordPair(keyword: "Graduated mix", definition: "Heavy aggregate at base, light at top"),
                    KeywordPair(keyword: "Pumice", definition: "Volcanic rock so light it floats"),
                ],
                activity: .wordScramble(word: "POZZOLANA", hint: "Volcanic ash that makes concrete last 2,000 years"),
                notebookSummary: "STEP 4 MATERIAL: Pozzolana (volcanic ash) + lime = concrete that lasts 2,000 years. Grade it: heavy basalt (base) → light pumice (top).",
                visual: CardVisual(
                    type: .comparison,
                    title: "Roman vs Modern Concrete",
                    values: ["equal": 0],
                    labels: ["Roman concrete\n2,000 years\nPozzolana + lime", "Modern concrete\n100 years\nPortland cement", "Secret: volcanic silica gets STRONGER over time"],
                    steps: 3, caption: "Ca(OH)₂ + SiO₂ → CaSiO₃ — the reaction that outlasts empires"
                )
            ),

            KnowledgeCard(
                id: "\(bid)_workshop_river_0",
                buildingId: bid, buildingName: name,
                science: .materials,
                environment: .workshop, stationKey: "river",
                title: "Step 5: Pour in Rings",
                italianTitle: "Passo 5: Getto a Anelli",
                icon: "drop.triangle.fill",
                lessonText: "Now. The most beautiful step. We pour the dome — but not all at once. In rings. Ring by ring, horizontal layers. Each ring must cure — must harden — before the next can rest on top. Water is everything here. Too much, and the concrete weakens. Too little, and it never sets at all. The ratio must be exact. Once the lower rings cure, they hold themselves up. No support needed. And so, slowly, ring by ring, the dome closes. Up toward the open eye.",
                keywords: [
                    KeywordPair(keyword: "Ring pouring", definition: "Building the dome in horizontal layers (Step 5)"),
                    KeywordPair(keyword: "Curing", definition: "Concrete hardening — each ring must cure first"),
                    KeywordPair(keyword: "Self-supporting", definition: "Each ring holds itself without centering"),
                ],
                activity: .trueFalse(statement: "The Pantheon dome was poured in horizontal rings, each curing before the next", isTrue: true),
                notebookSummary: "STEP 5: Pour dome in horizontal rings. Each ring cures before the next. Self-supporting as it rises. Ring by ring toward the oculus.",
                visual: CardVisual(
                    type: .crossSection,
                    title: "Dome Layers — Graded Aggregate",
                    values: ["height": 21.65, "dome": 1],
                    labels: ["Heavy basalt", "Medium tufa", "Light pumice", "Oculus (open)"],
                    steps: 4, caption: "Heavy aggregate at base → light pumice at top, poured ring by ring"
                )
            ),

            KnowledgeCard(
                id: "\(bid)_workshop_mine_0",
                buildingId: bid, buildingName: name,
                science: .materials,
                environment: .workshop, stationKey: "mine",
                title: "Step 7 Material: Bronze",
                italianTitle: "Materiale Passo 7: Bronzo",
                icon: "shield.lefthalf.filled",
                lessonText: "Almost done. Now — the doors. Two of them. Each one seven meters tall. Each weighing several tons. And yet — they swing on bronze pivots, smooth as silk. Lead clamps lock them into the stone frame. Once, the dome above gleamed with gilded bronze tiles. But in 663 AD, an emperor stripped every one. Later, Pope Urban the Eighth melted two hundred tons of Pantheon bronze for Bernini's canopy in Saint Peter's. The metalwork comes near the end. Always.",
                keywords: [
                    KeywordPair(keyword: "Bronze doors", definition: "7m tall doors installed in Step 7"),
                    KeywordPair(keyword: "Lead clamp", definition: "Metal fastener joining stone to frame"),
                    KeywordPair(keyword: "Step 7", definition: "Doors installed AFTER the dome and oculus"),
                ],
                activity: .numberFishing(question: "How many tons of bronze did Pope Urban VIII melt?", correctAnswer: 200, decoys: [50, 100, 350, 500, 800]),
                notebookSummary: "STEP 7 MATERIAL: Bronze for doors (7m tall) and fittings. Lead clamps join stone. Doors go in AFTER dome + oculus. Near the end.",
                visual: CardVisual(
                    type: .force,
                    title: "7-Meter Bronze Doors",
                    values: ["doors": 1, "height": 7, "melted": 200],
                    labels: ["7m tall bronze doors", "Swing on bronze pivots", "Pope Urban VIII melted 200 tons for Bernini's baldachin"],
                    steps: 3, caption: "Installed in Step 7 — doors and fittings come near the END"
                )
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
                lessonText: "Before we can pour the dome, we must build one. A wooden one. Oak beams curve up and meet at the top — we call this the centering. A temporary frame. A timber skeleton. It holds the wet concrete while it cures. For three full weeks. Three weeks of timber bearing thousands of tons. Then — the workers go underneath. Carefully. They take it apart, piece by piece. And the concrete dome stands alone. The thing that makes the dome possible is designed to disappear.",
                keywords: [
                    KeywordPair(keyword: "Centering", definition: "Temporary oak frame for Step 5 dome pouring"),
                    KeywordPair(keyword: "Curing", definition: "3 weeks for concrete to harden"),
                    KeywordPair(keyword: "Remove from below", definition: "Centering is dismantled after concrete sets"),
                ],
                activity: .wordScramble(word: "CENTERING", hint: "Temporary frame supporting the dome during Step 5"),
                notebookSummary: "STEP 5 SUPPORT: Oak centering holds wet concrete for 3 weeks. Then removed — designed to disappear after the dome cures.",
                visual: CardVisual(
                    type: .force,
                    title: "Centering — Temporary Dome Frame",
                    values: ["centering": 1, "load": 4535, "arrows": 6, "weeks": 3],
                    labels: ["Oak beams curve into temporary dome", "Carries thousands of tons for 3 weeks", "Removed after concrete cures"],
                    steps: 3, caption: "The thing that makes the dome possible is designed to disappear"
                )
            ),

            KnowledgeCard(
                id: "\(bid)_forest_poplar_0",
                buildingId: bid, buildingName: name,
                science: .engineering,
                environment: .forest, stationKey: "poplar",
                title: "Steps 2-5: Scaffolding",
                italianTitle: "Passi 2-5: Impalcatura",
                icon: "square.stack.3d.up",
                lessonText: "Look at the poplar tree. Three meters a year, this one grows. Fast. Light. Cheap. The perfect wood for scaffolding. Workers stand on poplar platforms — forty-three meters up. Higher than any building they have ever climbed. From these platforms they build walls. They shape coffers. They mix concrete. They pour the dome — ring by ring. Poplar holds them all. And when the work is finished? The wood becomes crates. Firewood. The Romans wasted nothing. Not even a board.",
                keywords: [
                    KeywordPair(keyword: "Scaffolding", definition: "Poplar platforms for Steps 2-5"),
                    KeywordPair(keyword: "Formwork", definition: "Wooden mold shaping wet concrete"),
                    KeywordPair(keyword: "Steps 2-5", definition: "Walls → coffers → concrete → dome pouring"),
                ],
                activity: .hangman(word: "SCAFFOLDING", hint: "Temporary poplar platforms used through Steps 2-5"),
                notebookSummary: "STEPS 2-5 SUPPORT: Poplar scaffolding for walls, coffers, concrete, dome. 43m up. Light, cheap, recycled after. Nothing wasted.",
                visual: CardVisual(
                    type: .force,
                    title: "Scaffolding Around the Dome — 43m High",
                    values: ["scaffolding": 1, "height": 43, "platforms": 5],
                    labels: ["Poplar platforms for Steps 2-5", "Workers stood 43m up", "Removed after → became crates + firewood"],
                    steps: 3, caption: "Poplar grows 3m/year — light, cheap, disposable, nothing wasted"
                )
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
                lessonText: "Now — your hands get dirty. Vitruvius wrote the recipe two thousand years ago. One part lime. Three parts volcanic ash. Simple — no? But there are tricks. First, you must slake the lime. Pour water onto quicklime, and step back. The reaction is dangerously hot. Steam. Boiling. Once cool, you mix in your pozzolana and your aggregate. Heavy basalt at the base. Medium tufa in the middle. Light pumice at the top. Pour. Tamp with wooden tools. One layer at a time. Patience is the secret ingredient.",
                keywords: [
                    KeywordPair(keyword: "1:3 ratio", definition: "1 lime + 3 pozzolana (Step 4 recipe)"),
                    KeywordPair(keyword: "Slaking", definition: "Adding water to quicklime — very hot"),
                    KeywordPair(keyword: "Graduated", definition: "Heavy at base, light at top"),
                    KeywordPair(keyword: "Tamping", definition: "Compacting concrete with wooden tools"),
                ],
                activity: .wordScramble(word: "VITRUVIUS", hint: "Roman architect who wrote the Step 4 concrete recipe"),
                notebookSummary: "STEP 4: Grade concrete. 1 lime + 3 pozzolana. Heavy basalt (base) → tufa (middle) → pumice (top). Slake, mix, pour, tamp.",
                visual: CardVisual(
                    type: .ratio,
                    title: "Vitruvius Concrete Recipe — 1:3",
                    values: ["Lime": 1, "Pozzolana": 3],
                    labels: ["1 part lime to 3 parts volcanic ash"],
                    steps: 3, caption: "Slake quicklime, mix pozzolana, grade aggregate by height"
                )
            ),

            KnowledgeCard(
                id: "\(bid)_craftingRoom_furnace_0",
                buildingId: bid, buildingName: name,
                science: .chemistry,
                environment: .craftingRoom, stationKey: "furnace",
                title: "Step 1: Fire the Quicklime",
                italianTitle: "Passo 1: Cottura della Calce",
                icon: "flame.circle.fill",
                lessonText: "Before we can lay the foundation, we need glue. Real glue. The kind that holds Rome together. Take limestone. Place it in the kiln. Heat it to nine hundred degrees. The fire drives off the carbon dioxide — and what remains is a white powder. We call it quicklime. Be careful with it. Touch it with water, and it explodes. The Roman kilns burned day and night. Year after year. Without this powder, there IS no foundation. Fire transforms a stone into a binder. Strange — no?",
                keywords: [
                    KeywordPair(keyword: "900°C", definition: "Temperature to make quicklime for Step 1"),
                    KeywordPair(keyword: "CaCO₃ → CaO + CO₂", definition: "Limestone becomes quicklime + carbon dioxide"),
                    KeywordPair(keyword: "Quicklime", definition: "Foundation binder — made BEFORE Step 1"),
                ],
                activity: .numberFishing(question: "What temperature (°C) converts limestone to quicklime?", correctAnswer: 900, decoys: [450, 600, 750, 1100, 1500]),
                notebookSummary: "BEFORE STEP 1: Fire limestone at 900°C → quicklime (CaO). The binder for foundation concrete. Must be made first.",
                visual: CardVisual(
                    type: .temperature,
                    title: "Calcination — CaCO₃ → CaO + CO₂",
                    values: ["transition": 900, "max": 1200],
                    labels: ["Limestone (CaCO₃)", "Quicklime (CaO)"],
                    steps: 3, caption: "At 900°C, CO₂ burns off — limestone becomes the glue of Rome"
                )
            ),

            KnowledgeCard(
                id: "\(bid)_craftingRoom_shelf_0",
                buildingId: bid, buildingName: name,
                science: .architecture,
                environment: .craftingRoom, stationKey: "shelf",
                title: "Step 8: Opus Sectile Floor",
                italianTitle: "Passo 8: Pavimento in Opus Sectile",
                icon: "diamond.fill",
                lessonText: "The final step. The floor. No paint. No tile. Only natural stone — every color the empire can offer. Listen. Purple porphyry, from Egypt. Yellow giallo antico, from Tunisia. White pavonazzetto, with violet veins, from Turkey. Grey granite, from the banks of the Nile. Each one sliced paper-thin. Polished until it shines like a mirror. Fitted together without a drop of mortar. The squares and circles in the floor echo the coffers in the dome above. Look down. The whole Roman empire is under your feet.",
                keywords: [
                    KeywordPair(keyword: "Opus sectile", definition: "Cut stone fitted together without mortar"),
                    KeywordPair(keyword: "Porphyry", definition: "Imperial purple-red stone from Egypt"),
                    KeywordPair(keyword: "Giallo antico", definition: "Honey-yellow marble from Tunisia"),
                    KeywordPair(keyword: "Pavonazzetto", definition: "White marble with purple veins from Turkey"),
                ],
                activity: .hangman(word: "PORPHYRY", hint: "Imperial purple-red stone from Egypt, reserved for emperors (Step 8)"),
                notebookSummary: "STEP 8 (LAST): Opus sectile floor. No paint — only natural stone. Porphyry (Egypt), giallo antico (Tunisia), pavonazzetto (Turkey), granite (Egypt). Cut, polished, fitted without mortar.",
                visual: CardVisual(
                    type: .geometry,
                    title: "Opus Sectile — Geometric Stone Puzzle",
                    values: ["tessellation": 1, "stones": 4],
                    labels: ["Porphyry (purple)", "Giallo antico (yellow)", "Pavonazzetto (white)", "Granite (grey)"],
                    steps: 4, caption: "Cut marble fitted together like a puzzle — no mortar, no paint"
                )
            ),
        ]
    }
}
