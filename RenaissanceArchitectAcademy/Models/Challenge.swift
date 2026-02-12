import Foundation

// Note: Science enum is defined in Building.swift and is already Codable

/// A single question in a challenge
struct ChallengeQuestion: Identifiable {
    let id: UUID
    let questionText: String
    let options: [String]
    let correctAnswerIndex: Int
    let science: Science
    let explanation: String  // Educational explanation shown after answering
    let funFact: String      // Historical fun fact related to the question

    init(
        id: UUID = UUID(),
        questionText: String,
        options: [String],
        correctAnswerIndex: Int,
        science: Science,
        explanation: String,
        funFact: String
    ) {
        self.id = id
        self.questionText = questionText
        self.options = options
        self.correctAnswerIndex = correctAnswerIndex
        self.science = science
        self.explanation = explanation
        self.funFact = funFact
    }
}

/// A complete challenge for a building
struct Challenge: Identifiable {
    let id: UUID
    let buildingName: String
    let introduction: String  // Historical context before starting
    let questions: [ChallengeQuestion]

    init(
        id: UUID = UUID(),
        buildingName: String,
        introduction: String,
        questions: [ChallengeQuestion]
    ) {
        self.id = id
        self.buildingName = buildingName
        self.introduction = introduction
        self.questions = questions
    }
}

/// Tracks the state of an active challenge
struct ChallengeProgress {
    var currentQuestionIndex: Int = 0
    var correctAnswers: Int = 0
    var selectedAnswerIndex: Int? = nil
    var hasAnswered: Bool = false
    var showingExplanation: Bool = false

    var isComplete: Bool {
        currentQuestionIndex >= totalQuestions
    }

    var totalQuestions: Int = 0

    var scorePercentage: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(correctAnswers) / Double(totalQuestions)
    }
}

// MARK: - Interactive Question Types

/// Data for drag-and-drop chemistry equations
struct DragDropEquationData {
    let equationTemplate: String        // "CaO + H₂O → [BLANK]"
    let availableElements: [ChemicalElement]
    let correctAnswers: [String]
    let hint: String?
}

/// A draggable chemical element
struct ChemicalElement: Identifiable, Equatable {
    let id: UUID
    let symbol: String
    let name: String
    let color: String  // "green", "blue", "gray", etc.

    init(id: UUID = UUID(), symbol: String, name: String, color: String = "blue") {
        self.id = id
        self.symbol = symbol
        self.name = name
        self.color = color
    }
}

/// Data for hydraulics flow tracing questions
struct HydraulicsFlowData {
    let backgroundImageName: String?   // Optional background image (e.g., aqueduct diagram)
    let diagramDescription: String     // Text description of what's shown
    let checkpoints: [FlowCheckpoint]  // Points the path must pass through
    let startPoint: CGPoint            // Where the flow begins (normalized 0-1)
    let endPoint: CGPoint              // Where the flow ends (normalized 0-1)
    let hint: String?
}

/// A checkpoint the water flow must pass through
struct FlowCheckpoint: Identifiable {
    let id: UUID
    let position: CGPoint    // Normalized position (0-1)
    let label: String        // "Reservoir", "Settling Tank", etc.
    let radius: CGFloat      // Hit detection radius (normalized)

    init(id: UUID = UUID(), position: CGPoint, label: String, radius: CGFloat = 0.08) {
        self.id = id
        self.position = position
        self.label = label
        self.radius = radius
    }
}

// MARK: - Hint System Models

/// Data for the 3-tier hint system (riddle → craft/earn → detailed hint scroll)
struct HintData {
    let riddle: String           // Free vague clue (always available)
    let detailedHint: String     // Full hint shown on scroll after craft/earn
    let activityType: HintActivityType
}

/// Activity types for earning a hint
enum HintActivityType {
    case trueFalse(statement: String, isTrue: Bool, explanation: String)
}

// MARK: - Molecule Diagram Models

/// Bond type between atoms in a molecule diagram
enum BondType {
    case single
    case double
    case triple
    case ionic      // Dotted line for ionic/coordinate bonds
}

/// An atom in a 2D molecule diagram
struct MoleculeAtom {
    let symbol: String        // "Ca", "O", "H", etc.
    let position: CGPoint     // Normalized 0-1 coordinates
    let charge: String?       // Superscript charge: "2+", "−", "+", "2−", etc.

    init(symbol: String, position: CGPoint, charge: String? = nil) {
        self.symbol = symbol
        self.position = position
        self.charge = charge
    }
}

/// A bond connecting two atoms
struct MoleculeBond {
    let fromAtomIndex: Int
    let toAtomIndex: Int
    let bondType: BondType
}

/// Complete molecule diagram data
struct MoleculeData {
    let name: String              // "Water"
    let formula: String           // "H₂O"
    let atoms: [MoleculeAtom]
    let bonds: [MoleculeBond]
    let educationalText: String

    // MARK: - Pre-defined Molecules

    /// H₂O — Water
    static let water = MoleculeData(
        name: "Water",
        formula: "H\u{2082}O",
        atoms: [
            MoleculeAtom(symbol: "O", position: CGPoint(x: 0.5, y: 0.3), charge: "2\u{2212}"),
            MoleculeAtom(symbol: "H", position: CGPoint(x: 0.2, y: 0.7), charge: "+"),
            MoleculeAtom(symbol: "H", position: CGPoint(x: 0.8, y: 0.7), charge: "+"),
        ],
        bonds: [
            MoleculeBond(fromAtomIndex: 0, toAtomIndex: 1, bondType: .single),
            MoleculeBond(fromAtomIndex: 0, toAtomIndex: 2, bondType: .single),
        ],
        educationalText: "Water's bent shape (104.5\u{00B0}) gives it unique properties that made Roman aqueducts possible."
    )

    /// Ca(OH)₂ — Calcium Hydroxide (Lime Mortar)
    static let calciumHydroxide = MoleculeData(
        name: "Calcium Hydroxide",
        formula: "Ca(OH)\u{2082}",
        atoms: [
            MoleculeAtom(symbol: "H", position: CGPoint(x: 0.05, y: 0.2)),
            MoleculeAtom(symbol: "O", position: CGPoint(x: 0.25, y: 0.35), charge: "\u{2212}"),
            MoleculeAtom(symbol: "Ca", position: CGPoint(x: 0.5, y: 0.65), charge: "2+"),
            MoleculeAtom(symbol: "O", position: CGPoint(x: 0.75, y: 0.35), charge: "\u{2212}"),
            MoleculeAtom(symbol: "H", position: CGPoint(x: 0.95, y: 0.2)),
        ],
        bonds: [
            MoleculeBond(fromAtomIndex: 0, toAtomIndex: 1, bondType: .single),
            MoleculeBond(fromAtomIndex: 1, toAtomIndex: 2, bondType: .ionic),
            MoleculeBond(fromAtomIndex: 2, toAtomIndex: 3, bondType: .ionic),
            MoleculeBond(fromAtomIndex: 3, toAtomIndex: 4, bondType: .single),
        ],
        educationalText: "Lime mortar held Roman buildings together for millennia \u{2014} Ca(OH)\u{2082} slowly absorbs CO\u{2082} and turns back into limestone!"
    )

    /// SiO₂ — Silicon Dioxide (Glass)
    static let siliconDioxide = MoleculeData(
        name: "Silicon Dioxide",
        formula: "SiO\u{2082}",
        atoms: [
            MoleculeAtom(symbol: "O", position: CGPoint(x: 0.15, y: 0.5), charge: "2\u{2212}"),
            MoleculeAtom(symbol: "Si", position: CGPoint(x: 0.5, y: 0.5), charge: "4+"),
            MoleculeAtom(symbol: "O", position: CGPoint(x: 0.85, y: 0.5), charge: "2\u{2212}"),
        ],
        bonds: [
            MoleculeBond(fromAtomIndex: 0, toAtomIndex: 1, bondType: .double),
            MoleculeBond(fromAtomIndex: 1, toAtomIndex: 2, bondType: .double),
        ],
        educationalText: "SiO\u{2082} is the main ingredient of Venetian glass \u{2014} heated to 1700\u{00B0}C, it becomes transparent!"
    )

    /// CaCO₃ — Calcium Carbonate (Limestone)
    static let calciumCarbonate = MoleculeData(
        name: "Calcium Carbonate",
        formula: "CaCO\u{2083}",
        atoms: [
            MoleculeAtom(symbol: "Ca", position: CGPoint(x: 0.12, y: 0.5), charge: "2+"),
            MoleculeAtom(symbol: "O", position: CGPoint(x: 0.35, y: 0.75), charge: "\u{2212}"),
            MoleculeAtom(symbol: "C", position: CGPoint(x: 0.5, y: 0.45)),
            MoleculeAtom(symbol: "O", position: CGPoint(x: 0.5, y: 0.15), charge: "\u{2212}"),
            MoleculeAtom(symbol: "O", position: CGPoint(x: 0.78, y: 0.6), charge: "\u{2212}"),
        ],
        bonds: [
            MoleculeBond(fromAtomIndex: 0, toAtomIndex: 1, bondType: .ionic),
            MoleculeBond(fromAtomIndex: 1, toAtomIndex: 2, bondType: .single),
            MoleculeBond(fromAtomIndex: 2, toAtomIndex: 3, bondType: .double),
            MoleculeBond(fromAtomIndex: 2, toAtomIndex: 4, bondType: .single),
        ],
        educationalText: "Limestone (CaCO\u{2083}) was the Romans' favorite building stone \u{2014} heat it to get quicklime for mortar!"
    )

    /// Na₂O — Sodium Oxide
    static let sodiumOxide = MoleculeData(
        name: "Sodium Oxide",
        formula: "Na\u{2082}O",
        atoms: [
            MoleculeAtom(symbol: "Na", position: CGPoint(x: 0.15, y: 0.5), charge: "+"),
            MoleculeAtom(symbol: "O", position: CGPoint(x: 0.5, y: 0.5), charge: "2\u{2212}"),
            MoleculeAtom(symbol: "Na", position: CGPoint(x: 0.85, y: 0.5), charge: "+"),
        ],
        bonds: [
            MoleculeBond(fromAtomIndex: 0, toAtomIndex: 1, bondType: .ionic),
            MoleculeBond(fromAtomIndex: 1, toAtomIndex: 2, bondType: .ionic),
        ],
        educationalText: "Sodium oxide (Na\u{2082}O) lowers glass melting temperature \u{2014} a secret Venetian glassmakers guarded for centuries!"
    )

    /// CO₂ — Carbon Dioxide
    static let carbonDioxide = MoleculeData(
        name: "Carbon Dioxide",
        formula: "CO\u{2082}",
        atoms: [
            MoleculeAtom(symbol: "O", position: CGPoint(x: 0.15, y: 0.5)),
            MoleculeAtom(symbol: "C", position: CGPoint(x: 0.5, y: 0.5)),
            MoleculeAtom(symbol: "O", position: CGPoint(x: 0.85, y: 0.5)),
        ],
        bonds: [
            MoleculeBond(fromAtomIndex: 0, toAtomIndex: 1, bondType: .double),
            MoleculeBond(fromAtomIndex: 1, toAtomIndex: 2, bondType: .double),
        ],
        educationalText: "CO\u{2082} is released when limestone is heated \u{2014} Renaissance builders saw this gas without knowing what it was!"
    )

    /// C₆H₆ — Benzene (ring structure)
    static let benzene = MoleculeData(
        name: "Benzene",
        formula: "C\u{2086}H\u{2086}",
        atoms: [
            MoleculeAtom(symbol: "C", position: CGPoint(x: 0.5, y: 0.15)),
            MoleculeAtom(symbol: "C", position: CGPoint(x: 0.76, y: 0.3)),
            MoleculeAtom(symbol: "C", position: CGPoint(x: 0.76, y: 0.6)),
            MoleculeAtom(symbol: "C", position: CGPoint(x: 0.5, y: 0.75)),
            MoleculeAtom(symbol: "C", position: CGPoint(x: 0.24, y: 0.6)),
            MoleculeAtom(symbol: "C", position: CGPoint(x: 0.24, y: 0.3)),
            MoleculeAtom(symbol: "H", position: CGPoint(x: 0.5, y: 0.02)),
            MoleculeAtom(symbol: "H", position: CGPoint(x: 0.93, y: 0.2)),
            MoleculeAtom(symbol: "H", position: CGPoint(x: 0.93, y: 0.7)),
            MoleculeAtom(symbol: "H", position: CGPoint(x: 0.5, y: 0.88)),
            MoleculeAtom(symbol: "H", position: CGPoint(x: 0.07, y: 0.7)),
            MoleculeAtom(symbol: "H", position: CGPoint(x: 0.07, y: 0.2)),
        ],
        bonds: [
            MoleculeBond(fromAtomIndex: 0, toAtomIndex: 1, bondType: .double),
            MoleculeBond(fromAtomIndex: 1, toAtomIndex: 2, bondType: .single),
            MoleculeBond(fromAtomIndex: 2, toAtomIndex: 3, bondType: .double),
            MoleculeBond(fromAtomIndex: 3, toAtomIndex: 4, bondType: .single),
            MoleculeBond(fromAtomIndex: 4, toAtomIndex: 5, bondType: .double),
            MoleculeBond(fromAtomIndex: 5, toAtomIndex: 0, bondType: .single),
            MoleculeBond(fromAtomIndex: 0, toAtomIndex: 6, bondType: .single),
            MoleculeBond(fromAtomIndex: 1, toAtomIndex: 7, bondType: .single),
            MoleculeBond(fromAtomIndex: 2, toAtomIndex: 8, bondType: .single),
            MoleculeBond(fromAtomIndex: 3, toAtomIndex: 9, bondType: .single),
            MoleculeBond(fromAtomIndex: 4, toAtomIndex: 10, bondType: .single),
            MoleculeBond(fromAtomIndex: 5, toAtomIndex: 11, bondType: .single),
        ],
        educationalText: "Benzene's ring structure was a mystery until Kekul\u{00E9} dreamed of a snake eating its tail in 1865!"
    )

    /// All pre-defined molecules
    static let all: [MoleculeData] = [water, calciumHydroxide, siliconDioxide, calciumCarbonate, sodiumOxide, carbonDioxide, benzene]

    /// Lookup molecule by formula name (matches MaterialFormula pattern)
    static func molecule(forFormula formulaName: String) -> MoleculeData? {
        switch formulaName.lowercased() {
        case "lime mortar":
            return .calciumHydroxide
        case "roman concrete":
            return .calciumCarbonate
        case "venetian glass":
            return .siliconDioxide
        default:
            return nil
        }
    }
}

/// Types of interactive questions
enum QuestionType {
    case multipleChoice
    case dragDropEquation(DragDropEquationData)
    case hydraulicsFlow(HydraulicsFlowData)
}

/// Enhanced question supporting multiple interaction types
struct InteractiveQuestion: Identifiable {
    let id: UUID
    let questionText: String
    let science: Science
    let explanation: String
    let funFact: String
    let questionType: QuestionType
    let hint: HintData?

    // Multiple choice data (only if questionType == .multipleChoice)
    let options: [String]
    let correctAnswerIndex: Int

    /// Create a multiple choice question
    init(
        id: UUID = UUID(),
        questionText: String,
        options: [String],
        correctAnswerIndex: Int,
        science: Science,
        explanation: String,
        funFact: String,
        hint: HintData? = nil
    ) {
        self.id = id
        self.questionText = questionText
        self.options = options
        self.correctAnswerIndex = correctAnswerIndex
        self.science = science
        self.explanation = explanation
        self.funFact = funFact
        self.questionType = .multipleChoice
        self.hint = hint
    }

    /// Create a drag-drop equation question
    init(
        id: UUID = UUID(),
        questionText: String,
        equationData: DragDropEquationData,
        science: Science,
        explanation: String,
        funFact: String,
        hint: HintData? = nil
    ) {
        self.id = id
        self.questionText = questionText
        self.options = []
        self.correctAnswerIndex = 0
        self.science = science
        self.explanation = explanation
        self.funFact = funFact
        self.questionType = .dragDropEquation(equationData)
        self.hint = hint
    }

    /// Create a hydraulics flow tracing question
    init(
        id: UUID = UUID(),
        questionText: String,
        flowData: HydraulicsFlowData,
        science: Science,
        explanation: String,
        funFact: String,
        hint: HintData? = nil
    ) {
        self.id = id
        self.questionText = questionText
        self.options = []
        self.correctAnswerIndex = 0
        self.science = science
        self.explanation = explanation
        self.funFact = funFact
        self.questionType = .hydraulicsFlow(flowData)
        self.hint = hint
    }
}

/// Challenge with mixed interactive question types
struct InteractiveChallenge: Identifiable {
    let id: UUID
    let buildingName: String
    let introduction: String
    let questions: [InteractiveQuestion]

    init(id: UUID = UUID(), buildingName: String, introduction: String, questions: [InteractiveQuestion]) {
        self.id = id
        self.buildingName = buildingName
        self.introduction = introduction
        self.questions = questions
    }
}

// MARK: - Challenge Content

/// Static challenge content for all buildings
/// This is where you'd add challenges for each building
enum ChallengeContent {

    // MARK: - Interactive Roman Baths (with drag-drop chemistry!)

    static let romanBathsInteractive = InteractiveChallenge(
        buildingName: "Roman Baths",
        introduction: """
        Welcome, young architect! The Roman Baths (thermae) were marvels of engineering that combined \
        water management, chemistry, and materials science. These public bathing houses served millions \
        of Romans daily, requiring sophisticated systems to heat water, maintain hygiene, and build \
        structures that would last millennia.

        As you design your bathhouse, you'll need to understand how the Romans solved these challenges \
        using the sciences of their time.
        """,
        questions: [
            // CHEMISTRY - Interactive drag-drop!
            InteractiveQuestion(
                questionText: "Complete the reaction: When Romans mixed quicklime (calcium oxide) with water to make mortar, what did they create?",
                equationData: DragDropEquationData(
                    equationTemplate: "CaO + H₂O → [BLANK]",
                    availableElements: [
                        ChemicalElement(symbol: "Ca(OH)₂", name: "Slaked Lime", color: "green"),
                        ChemicalElement(symbol: "CaCO₃", name: "Limestone", color: "gray"),
                        ChemicalElement(symbol: "Ca", name: "Pure Calcium", color: "yellow"),
                        ChemicalElement(symbol: "H₂", name: "Hydrogen Gas", color: "blue")
                    ],
                    correctAnswers: ["Ca(OH)₂"],
                    hint: "When a metal oxide reacts with water, it forms a hydroxide..."
                ),
                science: .chemistry,
                explanation: "Calcium oxide (quicklime) reacts with water in an exothermic reaction to produce calcium hydroxide - also called slaked lime. This was the base for Roman mortar and concrete!",
                funFact: "This reaction releases so much heat it can boil the water! Roman soldiers sometimes used quicklime to heat their food in the field.",
                hint: HintData(
                    riddle: "When fire-born powder meets the river's gift, a new stone rises from the mist...",
                    detailedHint: "Metal oxides react with water to form hydroxides. Calcium is the metal here.",
                    activityType: .trueFalse(
                        statement: "Quicklime (CaO) is cold when mixed with water.",
                        isTrue: false,
                        explanation: "The reaction is exothermic — it releases enough heat to boil water!"
                    )
                )
            ),

            // HYDRAULICS - Multiple choice
            InteractiveQuestion(
                questionText: "The Romans used a heating system called a hypocaust to warm their baths. How did this system work?",
                options: [
                    "Fire heated water directly in the pools",
                    "Hot air circulated under raised floors and through hollow walls",
                    "The sun heated black tiles on the roof",
                    "Underground hot springs were redirected"
                ],
                correctAnswerIndex: 1,
                science: .hydraulics,
                explanation: "The hypocaust system raised the floor on pillars (pilae), allowing hot air from a furnace to circulate underneath. The heat rose through hollow spaces in the walls, warming the entire room evenly.",
                funFact: "Some Roman baths got so hot that bathers wore wooden sandals to protect their feet from the heated floors!",
                hint: HintData(
                    riddle: "Invisible breath of flame travels beneath your feet, warming stone from below...",
                    detailedHint: "The hypocaust used a furnace to push hot air under raised floors supported by pillars, and through hollow walls.",
                    activityType: .trueFalse(
                        statement: "The hypocaust heated water directly in the bathing pools.",
                        isTrue: false,
                        explanation: "The hypocaust heated air, which circulated under floors and through walls — the heat was indirect, warming the room itself."
                    )
                )
            ),

            // CHEMISTRY - Another drag-drop!
            InteractiveQuestion(
                questionText: "Roman concrete hardened over centuries through carbonation. Complete this equation:",
                equationData: DragDropEquationData(
                    equationTemplate: "Ca(OH)₂ + CO₂ → [BLANK] + H₂O",
                    availableElements: [
                        ChemicalElement(symbol: "CaCO₃", name: "Calcium Carbonate", color: "gray"),
                        ChemicalElement(symbol: "CaO", name: "Quicklime", color: "orange"),
                        ChemicalElement(symbol: "Ca(OH)₂", name: "Slaked Lime", color: "green"),
                        ChemicalElement(symbol: "ite", name: "Calcium", color: "yellow")
                    ],
                    correctAnswers: ["CaCO₃"],
                    hint: "The hydroxide absorbs CO₂ from the air and turns back into rock..."
                ),
                science: .chemistry,
                explanation: "Over time, calcium hydroxide absorbs CO₂ from the air and converts back to calcium carbonate - essentially turning back into limestone! This is why Roman concrete gets stronger with age.",
                funFact: "Modern concrete lasts 50-100 years, but Roman concrete is stronger after 2,000 years! Scientists are still trying to recreate their formula.",
                hint: HintData(
                    riddle: "The slaked earth drinks the sky's exhaled breath and becomes stone once more...",
                    detailedHint: "Calcium hydroxide absorbs carbon dioxide from the air and reverts to a carbonate — essentially turning back into limestone.",
                    activityType: .trueFalse(
                        statement: "Roman concrete gets weaker over time, just like modern concrete.",
                        isTrue: false,
                        explanation: "Roman concrete actually gets stronger! The carbonation process converts Ca(OH)₂ back to CaCO₃ (limestone), reinforcing the material over centuries."
                    )
                )
            ),

            // MATERIALS - Multiple choice
            InteractiveQuestion(
                questionText: "What volcanic material made Roman concrete waterproof and stronger over time?",
                options: [
                    "Volcanic glass (obsidian)",
                    "Pumice stone",
                    "Volcanic ash (pozzolana)",
                    "Basalt rock"
                ],
                correctAnswerIndex: 2,
                science: .materials,
                explanation: "Pozzolanic ash from the Pozzuoli region reacted with lime and seawater to form a mineral called tobermorite, making the concrete incredibly strong and waterproof.",
                funFact: "Scientists are now trying to recreate Roman concrete for modern buildings - it could reduce construction's carbon footprint by 50%!",
                hint: HintData(
                    riddle: "Born from the mountain's fury, this grey dust turns water to stone eternal...",
                    detailedHint: "This material comes from volcanic eruptions near Pozzuoli. When mixed with lime and seawater, it creates an incredibly durable mineral called tobermorite.",
                    activityType: .trueFalse(
                        statement: "Volcanic ash (pozzolana) was named after the Italian region of Pozzuoli.",
                        isTrue: true,
                        explanation: "Correct! The region near Naples had abundant volcanic deposits that Romans discovered made their concrete waterproof and incredibly strong."
                    )
                )
            ),

            // HYDRAULICS - Interactive flow tracing!
            InteractiveQuestion(
                questionText: "Trace how water flows through a Roman aqueduct system - from the mountain source to the city baths!",
                flowData: HydraulicsFlowData(
                    backgroundImageName: nil,
                    diagramDescription: "Roman aqueduct water flow system",
                    checkpoints: [
                        FlowCheckpoint(position: CGPoint(x: 0.25, y: 0.25), label: "Reservoir"),
                        FlowCheckpoint(position: CGPoint(x: 0.5, y: 0.4), label: "Settling Tank"),
                        FlowCheckpoint(position: CGPoint(x: 0.75, y: 0.55), label: "Distribution")
                    ],
                    startPoint: CGPoint(x: 0.1, y: 0.15),
                    endPoint: CGPoint(x: 0.9, y: 0.75),
                    hint: "Water flows downhill using gravity. Connect the checkpoints in order from source to destination."
                ),
                science: .hydraulics,
                explanation: "Roman aqueducts used gravity to move water along a gentle slope (about 1:200). Water collected at mountain sources, passed through settling tanks to remove sediment, then reached distribution points called castellum divisorium before flowing to baths, fountains, and homes.",
                funFact: "The longest Roman aqueduct was the Aqua Marcia at 91 km! Engineers used groma surveying tools to maintain precise slopes over vast distances.",
                hint: HintData(
                    riddle: "From the mountain's crown, through patient channels, the silver thread descends to quench a city's thirst...",
                    detailedHint: "Water flows downhill by gravity. Trace through the reservoir first, then the settling tank where sediment drops out, then to the distribution point.",
                    activityType: .trueFalse(
                        statement: "Roman aqueducts used pumps to push water uphill to the city.",
                        isTrue: false,
                        explanation: "Aqueducts relied entirely on gravity! Engineers designed a gentle downward slope (about 1:200) over many kilometers."
                    )
                )
            ),

            // MATERIALS - Multiple choice
            InteractiveQuestion(
                questionText: "Why was marble particularly good for wet areas in Roman baths?",
                options: [
                    "Marble absorbs water like a sponge",
                    "Marble is non-porous and doesn't harbor bacteria easily",
                    "Marble generates heat when wet",
                    "Marble changes color to show water temperature"
                ],
                correctAnswerIndex: 1,
                science: .materials,
                explanation: "Marble's crystalline structure makes it relatively non-porous. Water beads on the surface rather than soaking in, making it easier to clean.",
                funFact: "The Baths of Caracalla used marble from across the empire - white from Greece, yellow from Tunisia, purple from Turkey, and green from Egypt!",
                hint: HintData(
                    riddle: "Crystal bones of the earth, polished smooth — water slides away as from a swan's feather...",
                    detailedHint: "Think about the stone's crystal structure. A surface that does not absorb water resists mold and bacteria growth.",
                    activityType: .trueFalse(
                        statement: "Marble is porous and absorbs water like a sponge.",
                        isTrue: false,
                        explanation: "Marble's crystalline structure makes it relatively non-porous — water beads on the surface, making it hygienic for wet areas."
                    )
                )
            )
        ]
    )

    // MARK: - Aqueduct Challenge (Engineering, Hydraulics, Mathematics)

    static let aqueductInteractive = InteractiveChallenge(
        buildingName: "Aqueduct",
        introduction: """
        Welcome, young engineer! The Roman aqueducts were among the greatest engineering achievements \
        of the ancient world. These massive structures carried fresh water across valleys and mountains, \
        supplying cities with millions of gallons daily - all without electric pumps!

        To build your aqueduct, you must master the mathematics of slopes, the physics of water flow, \
        and the engineering principles that made these structures last over 2,000 years.
        """,
        questions: [
            // MATHEMATICS - Multiple choice
            InteractiveQuestion(
                questionText: "Roman engineers needed the aqueduct to slope downward at exactly the right angle. If an aqueduct drops 1 meter for every 200 meters of length, what is this ratio called?",
                options: [
                    "A gradient of 1:200",
                    "A pressure of 200 pascals",
                    "A velocity of 200 m/s",
                    "A volume of 200 liters"
                ],
                correctAnswerIndex: 0,
                science: .mathematics,
                explanation: "The gradient (or slope) of 1:200 means for every 200 meters horizontally, the channel drops 1 meter vertically. This gentle slope allowed water to flow steadily without eroding the channel.",
                funFact: "Roman surveyors used a tool called a 'groma' - essentially a cross with plumb lines - to measure these precise angles across many kilometers!",
                hint: HintData(
                    riddle: "For every two hundred steps forward, one step the water descends — name this gentle fall...",
                    detailedHint: "This ratio describes how much height is lost over a horizontal distance. It is a measure of slope, not pressure, speed, or volume.",
                    activityType: .trueFalse(
                        statement: "A gradient of 1:200 means the channel drops 200 meters for every 1 meter of length.",
                        isTrue: false,
                        explanation: "It is the opposite — the channel drops 1 meter for every 200 meters of horizontal length. A very gentle slope!"
                    )
                )
            ),

            // ENGINEERING - Multiple choice
            InteractiveQuestion(
                questionText: "Why did Romans build arched bridges to carry aqueducts across valleys instead of solid walls?",
                options: [
                    "Arches were faster to build",
                    "Arches distribute weight efficiently and use less material",
                    "Arches looked more beautiful",
                    "Solid walls would block too much sunlight"
                ],
                correctAnswerIndex: 1,
                science: .engineering,
                explanation: "Arches transfer the weight of the structure outward and downward to the foundations. This allows spanning large gaps with less material than a solid wall would require.",
                funFact: "The Pont du Gard in France stands 49 meters tall with three tiers of arches - and was built without mortar! The stones are so precisely cut they hold together by friction alone.",
                hint: HintData(
                    riddle: "Curved like a bow, strong as a mountain — the empty space beneath is the secret of its strength...",
                    detailedHint: "Consider how weight is transferred through curved vs flat structures. Arches push forces outward and downward to their foundations.",
                    activityType: .trueFalse(
                        statement: "Roman arches required more building material than solid walls of the same height.",
                        isTrue: false,
                        explanation: "Arches use less material because the curved shape efficiently distributes weight, allowing large spans with relatively thin structures."
                    )
                )
            ),

            // HYDRAULICS - Multiple choice
            InteractiveQuestion(
                questionText: "At the end of an aqueduct, Romans built a 'castellum divisorium'. What was its purpose?",
                options: [
                    "To store water for emergencies",
                    "To divide water flow to different parts of the city",
                    "To filter out impurities",
                    "To increase water pressure"
                ],
                correctAnswerIndex: 1,
                science: .hydraulics,
                explanation: "The castellum divisorium was a distribution tank that divided the incoming water into multiple channels serving different areas: public fountains, baths, and wealthy private homes.",
                funFact: "In times of drought, water was rationed! Public fountains got priority, then baths, and private users were cut off first. The emperor's supply was never interrupted!",
                hint: HintData(
                    riddle: "Where the great channel ends, a stone chalice splits the silver stream into many veins for the city...",
                    detailedHint: "This structure sat at the terminus of the aqueduct. Its Latin name literally means 'dividing castle' — think about what 'dividing' water means.",
                    activityType: .trueFalse(
                        statement: "The castellum divisorium stored water for emergencies like a reservoir.",
                        isTrue: false,
                        explanation: "It was a distribution tank, not a storage tank. Its purpose was to split the incoming water flow into separate channels for different parts of the city."
                    )
                )
            ),

            // MATHEMATICS - Multiple choice
            InteractiveQuestion(
                questionText: "An aqueduct must carry 500,000 liters of water per day. If the channel is 1 meter wide and 0.5 meters deep, approximately how fast must the water flow?",
                options: [
                    "About 0.01 meters per second",
                    "About 0.1 meters per second",
                    "About 1 meter per second",
                    "About 10 meters per second"
                ],
                correctAnswerIndex: 0,
                science: .mathematics,
                explanation: "Using the formula: Flow rate = Area × Velocity. With 500,000 L/day ≈ 5.8 L/s, and channel area of 0.5 m², velocity ≈ 0.012 m/s. A gentle flow prevents erosion!",
                funFact: "Romans didn't have calculators, but they developed practical rules of thumb through centuries of experience. Their measurements were remarkably accurate!",
                hint: HintData(
                    riddle: "Half a million drops each day must pass through the narrow gate — how gently must they flow?",
                    detailedHint: "Use Flow rate = Area x Velocity. Convert 500,000 liters/day to liters/second first (divide by 86,400). The channel area is 1m x 0.5m = 0.5 m².",
                    activityType: .trueFalse(
                        statement: "Water in a Roman aqueduct flowed very fast, like a rushing river.",
                        isTrue: false,
                        explanation: "Aqueduct water flowed very gently — about 0.01 m/s. Fast flow would erode the channel walls over time."
                    )
                )
            ),

            // ENGINEERING - Multiple choice
            InteractiveQuestion(
                questionText: "When an aqueduct needed to cross a valley that was too deep for arches, what solution did Roman engineers use?",
                options: [
                    "They dug tunnels through the mountains instead",
                    "They used an 'inverted siphon' - pipes that go down then up",
                    "They built wooden bridges",
                    "They redirected to a different route"
                ],
                correctAnswerIndex: 1,
                science: .engineering,
                explanation: "An inverted siphon uses sealed pipes that descend into the valley and rise on the other side. Water pressure pushes the water up - the same principle as a U-shaped tube!",
                funFact: "The inverted siphon at Lyon, France dropped 123 meters and used nine parallel lead pipes, each 25cm in diameter, to handle the enormous water pressure!",
                hint: HintData(
                    riddle: "When the valley yawns too deep for stone legs, the water must dive down and climb again like a serpent...",
                    detailedHint: "Think of a U-shaped tube — water goes down one side and pressure pushes it up the other. This uses sealed pipes, not open channels.",
                    activityType: .trueFalse(
                        statement: "An inverted siphon uses water pressure to push water uphill through sealed pipes.",
                        isTrue: true,
                        explanation: "Correct! The weight of water on the descending side creates pressure that pushes water up the ascending side, like a U-tube."
                    )
                )
            ),

            // HYDRAULICS - Multiple choice
            InteractiveQuestion(
                questionText: "Why were settling tanks built along the aqueduct route?",
                options: [
                    "To slow down the water flow",
                    "To allow sediment and debris to sink and be removed",
                    "To add minerals to the water",
                    "To measure the water volume"
                ],
                correctAnswerIndex: 1,
                science: .hydraulics,
                explanation: "Settling tanks (piscinae) allowed the water to slow down so heavy particles like sand and silt would sink to the bottom. Workers regularly cleaned these tanks to maintain water quality.",
                funFact: "Some aqueducts had multiple settling tanks along their route. The Aqua Virgo in Rome had settling basins every few kilometers!",
                hint: HintData(
                    riddle: "Where the rushing stream rests in a quiet pool, the earth it carries sinks to slumber at the bottom...",
                    detailedHint: "These tanks allowed water to slow down so that heavier particles like sand and silt could settle to the bottom and be cleaned out.",
                    activityType: .trueFalse(
                        statement: "Settling tanks added minerals to the water to improve its taste.",
                        isTrue: false,
                        explanation: "Settling tanks removed impurities — they let sediment sink to the bottom so cleaner water could flow onward."
                    )
                )
            )
        ]
    )

    // MARK: - Colosseum Challenge (Architecture, Engineering, Acoustics)

    static let colosseumInteractive = InteractiveChallenge(
        buildingName: "Colosseum",
        introduction: """
        Welcome, young architect! The Colosseum (Flavian Amphitheatre) was the largest amphitheater \
        ever built, seating 50,000 spectators. It featured revolutionary engineering: a retractable \
        awning, underground chambers, and sophisticated crowd management.

        To design your amphitheater, you must understand how architects created spaces where everyone \
        could see and hear, how engineers built massive structures to last, and how acoustics carried \
        sound to every seat.
        """,
        questions: [
            // ARCHITECTURE - Multiple choice
            InteractiveQuestion(
                questionText: "The Colosseum's seating is arranged in a specific shape. Why did Roman architects choose an elliptical (oval) design rather than a circle?",
                options: [
                    "Ellipses were easier to construct",
                    "An ellipse provides better sight lines and fits more action in the center",
                    "Circles were considered unlucky",
                    "The site was already elliptical"
                ],
                correctAnswerIndex: 1,
                science: .architecture,
                explanation: "An elliptical arena allows spectators on the long sides to be closer to the action, while the curved ends still provide good views. It also creates a longer performance space for processions and battles.",
                funFact: "The Colosseum's ellipse measures 188 meters by 156 meters - about the size of a modern football field! The precise geometry was laid out using ropes and stakes.",
                hint: HintData(
                    riddle: "Not a perfect ring but a stretched one — every seat draws the eye closer to the spectacle within...",
                    detailedHint: "Think about what shape lets spectators on the long sides sit closer to the action, while still curving at the ends for good sightlines.",
                    activityType: .trueFalse(
                        statement: "The Colosseum is a perfect circle when viewed from above.",
                        isTrue: false,
                        explanation: "The Colosseum is an ellipse (oval), measuring 188m by 156m. This shape gives better sight lines and a longer arena for processions."
                    )
                )
            ),

            // ENGINEERING - Multiple choice
            InteractiveQuestion(
                questionText: "The Colosseum was built with a complex system of arches. What engineering principle makes the Roman arch so strong?",
                options: [
                    "The keystone at the top holds all other stones in place",
                    "Special Roman glue held the stones together",
                    "The arch was actually made of one solid piece",
                    "Metal rods reinforced the interior"
                ],
                correctAnswerIndex: 0,
                science: .engineering,
                explanation: "The wedge-shaped keystone at the top of an arch locks all the other stones (voussoirs) in place. Weight pushes down on the keystone, which transfers the force outward to the supporting columns.",
                funFact: "The Colosseum has 80 arched entrances at ground level - called 'vomitoria' - which could empty the entire stadium in just 15 minutes!",
                hint: HintData(
                    riddle: "The final wedge placed at the crown holds all its brothers in an embrace of stone...",
                    detailedHint: "Look at the top center of an arch. One special wedge-shaped stone locks all the others in place by transferring weight outward.",
                    activityType: .trueFalse(
                        statement: "The keystone is the stone at the base of a Roman arch.",
                        isTrue: false,
                        explanation: "The keystone sits at the very top (crown) of the arch. Its wedge shape locks the other stones (voussoirs) in place."
                    )
                )
            ),

            // ACOUSTICS - Multiple choice
            InteractiveQuestion(
                questionText: "How did the Colosseum's design help spectators hear announcements and performances?",
                options: [
                    "Speakers used megaphones",
                    "The curved walls and seating focused sound toward the audience",
                    "Underground tunnels carried sound",
                    "Everyone had to sit very quietly"
                ],
                correctAnswerIndex: 1,
                science: .acoustics,
                explanation: "The curved, tiered seating acted like a natural amplifier. Sound waves from the arena floor bounced off the hard stone surfaces and were directed upward toward the audience, enhancing audibility.",
                funFact: "Modern acoustic engineers have studied the Colosseum and found it has remarkably even sound distribution - a whisper on the arena floor can be heard in the upper seats!",
                hint: HintData(
                    riddle: "Shaped like a bowl for giants, the stone tiers catch every whisper and send it soaring upward...",
                    detailedHint: "Sound waves bounce off hard surfaces. The curved, tiered seating acts like a natural amplifier, directing sound from the arena floor up toward the audience.",
                    activityType: .trueFalse(
                        statement: "The Colosseum's tiered stone seating helped amplify sound naturally.",
                        isTrue: true,
                        explanation: "Correct! The hard stone surfaces reflected sound waves upward, and the curved bowl shape focused the sound toward the audience."
                    )
                )
            ),

            // ARCHITECTURE - Multiple choice
            InteractiveQuestion(
                questionText: "The Colosseum had a massive retractable awning called the 'velarium'. How was it supported?",
                options: [
                    "Wooden beams stretched across the top",
                    "Masts around the top edge with ropes and pulleys",
                    "Hot air balloons held it up",
                    "Slaves held poles from below"
                ],
                correctAnswerIndex: 1,
                science: .architecture,
                explanation: "240 wooden masts were inserted into sockets around the top of the outer wall. Ropes and pulleys controlled canvas panels that could be extended to shade spectators from the sun.",
                funFact: "A special unit of 1,000 sailors from the Roman navy operated the velarium - their experience with sails made them experts at handling the enormous canvas sheets!",
                hint: HintData(
                    riddle: "Like a ship's sails crowning the stone vessel, canvas stretches on tall timber arms with ropes and wheels...",
                    detailedHint: "Think of how sails are rigged on a ship — masts hold them up, and ropes and pulleys control their position. The velarium used the same principle.",
                    activityType: .trueFalse(
                        statement: "The velarium was a permanent stone roof over the Colosseum.",
                        isTrue: false,
                        explanation: "The velarium was a retractable canvas awning, controlled by ropes and pulleys on 240 wooden masts around the top edge."
                    )
                )
            ),

            // ENGINEERING - Multiple choice
            InteractiveQuestion(
                questionText: "The Colosseum's underground level (hypogeum) had elevators that lifted animals and scenery to the arena. How were they powered?",
                options: [
                    "Steam engines",
                    "Human-powered capstans and counterweights",
                    "Water pressure",
                    "Trained elephants"
                ],
                correctAnswerIndex: 1,
                science: .engineering,
                explanation: "Workers turned capstans (large vertical drums) that wound ropes attached to platforms. Counterweights helped balance the load, making it possible to lift heavy cages of lions or elaborate stage sets.",
                funFact: "The hypogeum had 80 vertical shafts and 30 trapdoors for surprise entrances! Animals could suddenly appear anywhere in the arena - terrifying for gladiators and thrilling for crowds.",
                hint: HintData(
                    riddle: "Beneath the sand, strong arms turn great wooden drums while heavy stones balance the rising cage...",
                    detailedHint: "Workers turned large vertical drums (capstans) that wound ropes. Counterweights helped balance the load so human muscle could lift heavy platforms.",
                    activityType: .trueFalse(
                        statement: "The Colosseum's underground elevators were powered by steam engines.",
                        isTrue: false,
                        explanation: "Steam engines were not invented until the 18th century! The elevators used human-powered capstans and counterweights."
                    )
                )
            ),

            // ACOUSTICS - Multiple choice
            InteractiveQuestion(
                questionText: "What acoustic problem did architects face in open-air amphitheaters, and how did the Colosseum's design help solve it?",
                options: [
                    "Echo - smooth walls reflected sound cleanly",
                    "Wind noise - tall walls blocked wind",
                    "Sound loss - the bowl shape contained sound energy",
                    "All of the above"
                ],
                correctAnswerIndex: 3,
                science: .acoustics,
                explanation: "The Colosseum addressed multiple acoustic challenges: its bowl shape contained sound, tall walls reduced wind noise, and the hard surfaces provided clear reflections without excessive echo.",
                funFact: "The Colosseum's acoustic design influenced theaters for centuries. Even today, amphitheater-style venues use similar principles for concerts and performances!",
                hint: HintData(
                    riddle: "Echo, wind, and the escaping voice — the great bowl of stone tames them all at once...",
                    detailedHint: "Open-air venues face multiple acoustic challenges: echoes, wind noise, and sound escaping. The Colosseum's bowl shape, tall walls, and hard surfaces addressed all of these.",
                    activityType: .trueFalse(
                        statement: "The Colosseum only solved the problem of echo, not wind noise or sound loss.",
                        isTrue: false,
                        explanation: "The design addressed all three: the bowl shape contained sound energy, tall walls blocked wind, and smooth surfaces provided clean reflections."
                    )
                )
            )
        ]
    )

    // MARK: - Duomo Challenge (Geometry, Architecture, Physics)

    static let duomoInteractive = InteractiveChallenge(
        buildingName: "Duomo",
        introduction: """
        Welcome, young master builder! The Florence Cathedral's dome, designed by Filippo Brunelleschi, \
        was the largest dome built since ancient Rome. For over a century, no one knew how to complete \
        it - the opening was too wide for traditional scaffolding!

        Brunelleschi's revolutionary solution combined geometry, physics, and architectural innovation \
        to create a masterpiece that still stands 600 years later.
        """,
        questions: [
            // GEOMETRY - Multiple choice
            InteractiveQuestion(
                questionText: "The Duomo's dome uses an octagonal (8-sided) base rather than a circular one. Why did Brunelleschi choose this shape?",
                options: [
                    "Octagons were easier to decorate",
                    "An octagon distributes weight to 8 points and allows for corner ribs",
                    "The existing building was already octagonal",
                    "Both B and C are correct"
                ],
                correctAnswerIndex: 3,
                science: .geometry,
                explanation: "The cathedral's drum (base) was already octagonal from earlier construction. Brunelleschi ingeniously used this by placing major structural ribs at each corner, distributing the dome's weight to 8 strong points.",
                funFact: "The octagon was considered a sacred shape in medieval Christianity - representing the 8th day of creation (resurrection). Many baptisteries are octagonal!",
                hint: HintData(
                    riddle: "Eight corners like a compass rose, each one bearing the weight of heaven's crown...",
                    detailedHint: "The cathedral's drum was already built in an octagonal shape. Brunelleschi placed structural ribs at each of the 8 corners to distribute the dome's weight evenly.",
                    activityType: .trueFalse(
                        statement: "Brunelleschi chose the octagonal shape because it was his personal preference.",
                        isTrue: false,
                        explanation: "The octagonal drum was already built by earlier architects. Brunelleschi ingeniously used this existing shape, placing ribs at each corner for structural support."
                    )
                )
            ),

            // PHYSICS - Multiple choice
            InteractiveQuestion(
                questionText: "The Duomo's dome is actually two domes - an inner and outer shell. What physics principle makes this double-shell design stronger?",
                options: [
                    "The air between them provides insulation",
                    "The shells brace each other, reducing outward thrust",
                    "Sound bounces between them for better acoustics",
                    "Light travels through the gap"
                ],
                correctAnswerIndex: 1,
                science: .physics,
                explanation: "The two shells are connected by horizontal stone rings and vertical ribs. This creates a rigid structure where each shell helps support the other, reducing the outward force that could crack the dome.",
                funFact: "You can actually walk between the two shells! A staircase of 463 steps winds between them, giving visitors views of both the outer city and the inner frescoes.",
                hint: HintData(
                    riddle: "Twin skins of stone, one within the other, leaning together like two hands in prayer...",
                    detailedHint: "Two shells connected by ribs and rings create a rigid structure. Each shell helps support the other, reducing the outward force (thrust) that could crack the dome.",
                    activityType: .trueFalse(
                        statement: "The air gap between the two dome shells was primarily for thermal insulation.",
                        isTrue: false,
                        explanation: "The main purpose was structural — the two shells brace each other through connecting ribs and rings, reducing the outward thrust that could collapse the dome."
                    )
                )
            ),

            // ARCHITECTURE - Multiple choice
            InteractiveQuestion(
                questionText: "Brunelleschi built the dome without the wooden centering (temporary support framework) that was standard for arch construction. How?",
                options: [
                    "He used metal supports instead",
                    "He laid bricks in a self-supporting herringbone pattern",
                    "Workers held the bricks in place",
                    "The dome was actually built on the ground and lifted up"
                ],
                correctAnswerIndex: 1,
                science: .architecture,
                explanation: "Brunelleschi invented a herringbone brick pattern where bricks are laid at angles that interlock with each other. Each ring of bricks supports itself as it's built, eliminating the need for scaffolding from below.",
                funFact: "The herringbone pattern was Brunelleschi's secret weapon - he may have learned it from studying Roman ruins. The technique was so effective it was kept secret for years!",
                hint: HintData(
                    riddle: "Like fish bones woven in clay, each brick leans upon its neighbor so none may fall...",
                    detailedHint: "Brunelleschi laid bricks at alternating angles so they interlocked with each other. Each ring of bricks was self-supporting as it was built — no scaffolding from below needed.",
                    activityType: .trueFalse(
                        statement: "Brunelleschi used traditional wooden centering (scaffolding) to support the dome during construction.",
                        isTrue: false,
                        explanation: "He invented the self-supporting herringbone brick pattern, eliminating the need for wooden centering — which would have been impossible given the dome's enormous span."
                    )
                )
            ),

            // GEOMETRY - Multiple choice
            InteractiveQuestion(
                questionText: "To create the dome's curved profile, Brunelleschi used a pointed (ogival) shape rather than a hemisphere. What geometric advantage does this provide?",
                options: [
                    "It looks taller and more impressive",
                    "A pointed arch directs forces more vertically, reducing outward thrust",
                    "It was easier to calculate",
                    "Rain slides off better"
                ],
                correctAnswerIndex: 1,
                science: .geometry,
                explanation: "A pointed arch pushes weight more directly downward compared to a round arch, which pushes outward. This reduced the horizontal forces trying to push the walls apart.",
                funFact: "Brunelleschi used a catenary curve (the shape a hanging chain makes) as his guide - this is mathematically the optimal shape for distributing compressive forces!",
                hint: HintData(
                    riddle: "The pointed crown sends its burden straight down to earth, while the round one pushes walls apart...",
                    detailedHint: "Compare a pointed arch to a hemisphere. A pointed (ogival) shape directs forces more vertically downward, reducing the horizontal thrust that pushes walls outward.",
                    activityType: .trueFalse(
                        statement: "A hemispherical (round) dome creates less outward thrust than a pointed dome.",
                        isTrue: false,
                        explanation: "A hemispherical dome creates MORE outward thrust. A pointed arch directs forces more vertically, reducing the horizontal push on the walls."
                    )
                )
            ),

            // PHYSICS - Multiple choice
            InteractiveQuestion(
                questionText: "The dome includes massive stone chains embedded horizontally around its circumference. What do these chains prevent?",
                options: [
                    "Lightning strikes",
                    "The dome from spinning in wind",
                    "The walls from spreading outward under the dome's weight",
                    "Water from leaking in"
                ],
                correctAnswerIndex: 2,
                science: .physics,
                explanation: "A dome creates outward thrust (like pushing down on a ball - it wants to spread). The stone chains act like a belt, holding the walls together and resisting this outward force through tension.",
                funFact: "There are four stone chains plus one iron chain hidden in the dome's structure. Together they contain over 700 tons of material just for reinforcement!",
                hint: HintData(
                    riddle: "Like a belt of stone girdling the great dome, these hidden rings hold the walls from fleeing outward...",
                    detailedHint: "A dome pushes outward (like pressing down on a ball). These horizontal chains act like belts, holding the walls together through tension to resist that outward spread.",
                    activityType: .trueFalse(
                        statement: "The stone chains in the dome prevent it from spinning in high winds.",
                        isTrue: false,
                        explanation: "The chains resist outward thrust — the force that tries to push the walls apart under the dome's weight. They act like a belt holding the structure together."
                    )
                )
            ),

            // ARCHITECTURE - Multiple choice
            InteractiveQuestion(
                questionText: "The lantern (the small structure on top of the dome) weighs over 750 tons. Why did Brunelleschi insist on adding such a heavy element?",
                options: [
                    "It provides a viewing platform for tourists",
                    "Its weight actually compresses and stabilizes the dome structure",
                    "It was required by the church for religious reasons",
                    "It houses the bells"
                ],
                correctAnswerIndex: 1,
                science: .architecture,
                explanation: "Counter-intuitively, the lantern's weight pushes down on the dome's crown, compressing the structure and preventing the top from opening up. It acts like a pin holding the dome's ribs together.",
                funFact: "Brunelleschi died before the lantern was complete. He designed special machines to lift the massive marble pieces - some weighing 37 tons - over 100 meters into the air!",
                hint: HintData(
                    riddle: "A crown of heavy marble atop the dome — yet it does not crush, it holds all together like a pin...",
                    detailedHint: "Counter-intuitively, adding weight on top compresses the dome's crown and prevents it from opening up. The lantern acts like a pin holding all the ribs together.",
                    activityType: .trueFalse(
                        statement: "The lantern was purely decorative and served no structural purpose.",
                        isTrue: false,
                        explanation: "The lantern's 750 tons of weight compresses the top of the dome, stabilizing the structure and preventing the crown from spreading open."
                    )
                )
            )
        ]
    )

    // MARK: - Observatory Challenge (Astronomy, Optics, Mathematics)

    static let observatoryInteractive = InteractiveChallenge(
        buildingName: "Observatory",
        introduction: """
        Welcome, young astronomer! Renaissance observatories revolutionized our understanding of the \
        cosmos. Galileo's telescopic observations of Jupiter's moons and Venus's phases helped prove \
        the sun-centered model of the solar system.

        To build your observatory, you must understand the mathematics of celestial motion, the optics \
        of lenses and light, and the instruments that revealed the secrets of the heavens.
        """,
        questions: [
            // ASTRONOMY - Multiple choice
            InteractiveQuestion(
                questionText: "Galileo observed that Venus shows phases like our Moon. What did this prove about the solar system?",
                options: [
                    "Venus has its own light source",
                    "Venus orbits the Sun, not Earth",
                    "Venus is larger than Earth",
                    "Venus has an atmosphere"
                ],
                correctAnswerIndex: 1,
                science: .astronomy,
                explanation: "If Venus orbited Earth (as in the old model), we would only ever see crescent phases. The full range of phases - from crescent to full - proves Venus orbits the Sun, sometimes on the far side from us.",
                funFact: "Galileo published his findings as an anagram to establish priority while he gathered more evidence. Decoded, it read 'The mother of love [Venus] imitates the phases of Cynthia [the Moon]'!",
                hint: HintData(
                    riddle: "The goddess of love wears many faces — crescent, half, and full — only if she dances around the Sun...",
                    detailedHint: "If Venus orbited Earth, we would only see crescent phases. Seeing a full range of phases (crescent to full) means Venus must orbit the Sun, sometimes passing behind it.",
                    activityType: .trueFalse(
                        statement: "If Venus orbited Earth, we would see it go through a full range of phases like the Moon.",
                        isTrue: false,
                        explanation: "If Venus orbited Earth (geocentric model), it could never be on the far side of the Sun, so we would only ever see crescent phases, never a full Venus."
                    )
                )
            ),

            // OPTICS - Multiple choice
            InteractiveQuestion(
                questionText: "A refracting telescope uses two lenses. What do the objective lens and eyepiece lens do?",
                options: [
                    "Both magnify equally",
                    "Objective gathers light and focuses it; eyepiece magnifies the image",
                    "Objective filters colors; eyepiece adjusts brightness",
                    "They both focus on different planets simultaneously"
                ],
                correctAnswerIndex: 1,
                science: .optics,
                explanation: "The large objective lens at the front collects light and bends it to a focal point, creating a small real image. The smaller eyepiece lens then magnifies this image for your eye to see.",
                funFact: "Galileo's best telescope had only 30x magnification - less than cheap binoculars today! Yet it was enough to discover moons around Jupiter and craters on our Moon.",
                hint: HintData(
                    riddle: "The great eye at the front drinks in starlight, while the small eye at the back makes the tiny picture large...",
                    detailedHint: "A refracting telescope has two lenses with different jobs. The large one at the front collects and focuses light; the small one near your eye magnifies the resulting image.",
                    activityType: .trueFalse(
                        statement: "Both lenses in a refracting telescope perform the same function.",
                        isTrue: false,
                        explanation: "The objective lens gathers light and focuses it to create a small image; the eyepiece lens magnifies that image for your eye. They have distinct roles."
                    )
                )
            ),

            // MATHEMATICS - Multiple choice
            InteractiveQuestion(
                questionText: "Kepler discovered that planets move in ellipses, not circles. What mathematical property describes how 'stretched' an ellipse is?",
                options: [
                    "Circumference",
                    "Eccentricity",
                    "Diameter",
                    "Radius"
                ],
                correctAnswerIndex: 1,
                science: .mathematics,
                explanation: "Eccentricity measures how much an ellipse deviates from a perfect circle. A circle has eccentricity 0, while more elongated ellipses have eccentricity closer to 1. Earth's orbit has eccentricity 0.017 (nearly circular).",
                funFact: "Kepler calculated Mars's orbit from 20 years of observations by Tycho Brahe. The 8-arcminute difference from a circular orbit led him to discover elliptical orbits!",
                hint: HintData(
                    riddle: "How much does the cosmic path stretch from a perfect ring? A number between naught and one reveals the truth...",
                    detailedHint: "This property measures how much an ellipse deviates from a perfect circle. A circle has a value of 0, and more elongated ellipses approach 1.",
                    activityType: .trueFalse(
                        statement: "Earth's orbit around the Sun is a perfect circle.",
                        isTrue: false,
                        explanation: "Earth's orbit is a slightly elliptical shape with an eccentricity of 0.017 — nearly circular, but not quite!"
                    )
                )
            ),

            // OPTICS - Multiple choice
            InteractiveQuestion(
                questionText: "Early telescope lenses created 'chromatic aberration' - colored fringes around objects. What causes this optical problem?",
                options: [
                    "The glass was dirty",
                    "Different colors of light bend by different amounts through glass",
                    "The eyepiece was too small",
                    "Stars actually have colored halos"
                ],
                correctAnswerIndex: 1,
                science: .optics,
                explanation: "White light contains all colors, and each color bends (refracts) slightly differently through glass. Blue bends more than red, so colors focus at different points, creating rainbow fringes.",
                funFact: "Newton invented the reflecting telescope partly to avoid chromatic aberration - mirrors reflect all colors equally. His design is still used in major observatories today!",
                hint: HintData(
                    riddle: "White light hides a rainbow within — when glass bends each color differently, fringes of color appear...",
                    detailedHint: "White light is made of all colors. Each color refracts (bends) by a slightly different amount through glass, so blue focuses at a different point than red, creating colored fringes.",
                    activityType: .trueFalse(
                        statement: "All colors of light bend by the same amount when passing through glass.",
                        isTrue: false,
                        explanation: "Different colors refract at different angles — blue bends more than red. This is why prisms create rainbows and why early lenses had colored fringes."
                    )
                )
            ),

            // ASTRONOMY - Multiple choice
            InteractiveQuestion(
                questionText: "Galileo discovered four moons orbiting Jupiter. What was revolutionary about this observation?",
                options: [
                    "It proved Jupiter was larger than Earth",
                    "It showed not everything orbits Earth - challenging the geocentric model",
                    "It proved the Moon was not unique",
                    "It showed Jupiter was a star"
                ],
                correctAnswerIndex: 1,
                science: .astronomy,
                explanation: "Seeing moons orbit Jupiter proved that Earth was not the center of all motion in the universe. If moons could orbit Jupiter, perhaps Earth could orbit the Sun!",
                funFact: "Galileo originally called them the 'Medician Stars' to honor his patrons. Today we call them the Galilean moons: Io, Europa, Ganymede, and Callisto!",
                hint: HintData(
                    riddle: "Four tiny stars dance around the great king of planets — if they circle Jupiter, perhaps Earth circles the Sun...",
                    detailedHint: "Seeing moons orbit Jupiter proved that not everything revolves around Earth. This was a direct challenge to the geocentric (Earth-centered) model of the universe.",
                    activityType: .trueFalse(
                        statement: "Before Galileo, everyone believed that all celestial bodies orbited the Earth.",
                        isTrue: true,
                        explanation: "Correct! The geocentric model placed Earth at the center. Galileo's discovery of moons orbiting Jupiter proved that other centers of motion exist in the cosmos."
                    )
                )
            ),

            // MATHEMATICS - Multiple choice
            InteractiveQuestion(
                questionText: "To calculate the magnification of a telescope, you divide the focal length of the objective by the focal length of the eyepiece. If the objective is 1000mm and the eyepiece is 25mm, what is the magnification?",
                options: [
                    "25x",
                    "40x",
                    "975x",
                    "1025x"
                ],
                correctAnswerIndex: 1,
                science: .mathematics,
                explanation: "Magnification = Objective focal length ÷ Eyepiece focal length = 1000mm ÷ 25mm = 40x. This means objects appear 40 times larger than with the naked eye.",
                funFact: "Higher magnification isn't always better! Too much magnification makes images dim and shaky. The atmosphere limits useful magnification to about 250x for most telescopes.",
                hint: HintData(
                    riddle: "Divide the long eye by the short eye, and the heavens grow closer by that measure...",
                    detailedHint: "Magnification = Objective focal length / Eyepiece focal length. With 1000mm and 25mm, simply divide the larger number by the smaller.",
                    activityType: .trueFalse(
                        statement: "A telescope with higher magnification always produces a better image.",
                        isTrue: false,
                        explanation: "Too much magnification makes images dim and shaky. Earth's atmosphere limits useful magnification to about 250x for ground-based telescopes."
                    )
                )
            )
        ]
    )

    // MARK: - Workshop Challenge (Engineering, Physics, Materials)

    static let workshopInteractive = InteractiveChallenge(
        buildingName: "Workshop",
        introduction: """
        Welcome, young inventor! Renaissance workshops were laboratories of innovation where masters \
        like Leonardo da Vinci designed flying machines, military weapons, and hydraulic systems. \
        These 'botteghe' combined art, science, and engineering.

        To establish your workshop, you must understand the physics of machines, the properties of \
        materials, and the engineering principles behind gears, levers, and mechanisms.
        """,
        questions: [
            // PHYSICS - Multiple choice
            InteractiveQuestion(
                questionText: "Leonardo designed many machines using levers. A lever with the fulcrum closer to the load than to the effort will:",
                options: [
                    "Require more force but move the load a greater distance",
                    "Require less force but move the load a shorter distance",
                    "Not work at all",
                    "Move at the same speed as the effort"
                ],
                correctAnswerIndex: 1,
                science: .physics,
                explanation: "This is a Class 1 lever with mechanical advantage. Moving the fulcrum closer to the load multiplies your force - but you must push farther to move the load a short distance. It's a trade-off!",
                funFact: "Leonardo filled notebooks with lever designs for cranes, catapults, and even perpetual motion machines (which he eventually proved impossible)!",
                hint: HintData(
                    riddle: "Move the balance point closer to the boulder, and a child can lift what a giant cannot...",
                    detailedHint: "When the fulcrum is closer to the load, you gain mechanical advantage — less force is needed, but you must push through a greater distance.",
                    activityType: .trueFalse(
                        statement: "A lever with mechanical advantage lets you use less force AND move the load a greater distance.",
                        isTrue: false,
                        explanation: "There is always a trade-off! Less force means you must push through a greater distance. You cannot get something for nothing with simple machines."
                    )
                )
            ),

            // ENGINEERING - Multiple choice
            InteractiveQuestion(
                questionText: "In a gear system, a small gear driving a large gear will:",
                options: [
                    "Increase speed and decrease torque",
                    "Decrease speed and increase torque",
                    "Keep speed and torque the same",
                    "Only work in one direction"
                ],
                correctAnswerIndex: 1,
                science: .engineering,
                explanation: "When a small gear (fewer teeth) drives a large gear (more teeth), the large gear turns slower but with more turning force (torque). This is called gear reduction - essential for lifting heavy loads!",
                funFact: "Leonardo designed gearboxes for cranes that could lift multi-ton marble blocks. Some of his designs were so advanced they weren't built until centuries later!",
                hint: HintData(
                    riddle: "The small wheel spins fast but the large wheel turns slow — yet with greater force it grips the earth...",
                    detailedHint: "When a small gear drives a large gear, the large gear turns more slowly but with increased torque (turning force). This is called gear reduction.",
                    activityType: .trueFalse(
                        statement: "A small gear driving a large gear increases both speed and torque.",
                        isTrue: false,
                        explanation: "Gear reduction trades speed for torque. The large gear turns slower but with more turning force — essential for lifting heavy loads."
                    )
                )
            ),

            // MATERIALS - Multiple choice
            InteractiveQuestion(
                questionText: "Renaissance craftsmen chose bronze (copper + tin alloy) for bells and cannons. Why was bronze better than pure copper?",
                options: [
                    "Bronze is shinier",
                    "Bronze is harder, stronger, and casts better than pure copper",
                    "Bronze is lighter",
                    "Bronze doesn't need to be heated"
                ],
                correctAnswerIndex: 1,
                science: .materials,
                explanation: "Adding tin to copper creates bronze, which is much harder and has a lower melting point for easier casting. It also resonates beautifully for bells and resists the explosive forces in cannons.",
                funFact: "The exact bronze recipe was a closely guarded secret! Bell makers had specific ratios (usually 80% copper, 20% tin) that produced the best sound quality.",
                hint: HintData(
                    riddle: "Copper alone is soft as gold, but wed it to tin and it becomes a warrior's metal...",
                    detailedHint: "Alloying (mixing metals) changes their properties. Bronze is harder, stronger, has a lower melting point for casting, and resonates well for bells.",
                    activityType: .trueFalse(
                        statement: "Pure copper is harder and stronger than bronze.",
                        isTrue: false,
                        explanation: "Bronze (copper + tin) is significantly harder and stronger than pure copper. The tin atoms disrupt copper's crystal structure, preventing layers from sliding."
                    )
                )
            ),

            // PHYSICS - Multiple choice
            InteractiveQuestion(
                questionText: "Leonardo studied pulleys extensively. A 'block and tackle' system with 4 pulleys reduces the effort needed by:",
                options: [
                    "Half",
                    "One quarter (4x mechanical advantage)",
                    "One eighth",
                    "It doesn't reduce effort"
                ],
                correctAnswerIndex: 1,
                science: .physics,
                explanation: "Each pulley that the rope loops around divides the effort. With 4 pulleys sharing the load, you only need 1/4 the force - but you must pull 4 times as much rope!",
                funFact: "Leonardo designed a self-supporting crane that could lift and place heavy stones without needing external anchoring - revolutionary for cathedral construction!",
                hint: HintData(
                    riddle: "Four wheels share the burden equally — each one taking a quarter of the weight upon its shoulder...",
                    detailedHint: "Each pulley the rope loops around divides the effort further. With 4 pulleys, the load is shared 4 ways, so you need only 1/4 the force — but must pull 4x as much rope.",
                    activityType: .trueFalse(
                        statement: "A 4-pulley block and tackle lets you use less force without any trade-off.",
                        isTrue: false,
                        explanation: "The trade-off is distance — you must pull 4 times as much rope to move the load the same distance. Energy is conserved!"
                    )
                )
            ),

            // MATERIALS - Multiple choice
            InteractiveQuestion(
                questionText: "Why did Renaissance workshops use seasoned (dried) wood rather than fresh-cut wood for machine parts?",
                options: [
                    "Fresh wood is too soft to cut",
                    "Seasoned wood won't shrink, warp, or crack after construction",
                    "Fresh wood attracts insects",
                    "Seasoned wood is lighter"
                ],
                correctAnswerIndex: 1,
                science: .materials,
                explanation: "Fresh wood contains moisture that evaporates over time, causing the wood to shrink unevenly and warp. Seasoning removes this moisture first, ensuring precision parts stay the right size and shape.",
                funFact: "Oak was seasoned for 2-7 years before use! Leonardo's wooden gear teeth had to be incredibly precise - a warped gear would destroy the whole mechanism.",
                hint: HintData(
                    riddle: "Green wood weeps and twists as it dries — only timber that has shed its tears holds true...",
                    detailedHint: "Fresh wood contains moisture. As it dries, water evaporates unevenly, causing warping, shrinking, and cracking. Seasoning removes this moisture before the wood is used.",
                    activityType: .trueFalse(
                        statement: "Fresh-cut wood is stronger than seasoned wood because it still contains moisture.",
                        isTrue: false,
                        explanation: "Seasoned wood is actually stronger and more stable. The moisture in fresh wood causes unpredictable shrinking and warping as it dries."
                    )
                )
            ),

            // ENGINEERING - Multiple choice
            InteractiveQuestion(
                questionText: "Leonardo's flying machine (ornithopter) was designed to flap like a bird. Why couldn't it actually fly?",
                options: [
                    "The wings were too small",
                    "Human muscles can't generate enough power for sustained flapping flight",
                    "It was too heavy to lift off",
                    "All of the above"
                ],
                correctAnswerIndex: 3,
                science: .engineering,
                explanation: "Flight requires a specific power-to-weight ratio. Human muscles produce about 0.25 horsepower sustained, but the ornithopter needed several horsepower. Combined with the weight of the frame, flight was impossible.",
                funFact: "Leonardo eventually realized this limitation and shifted to designing gliders! His hang glider designs actually could have worked - modern builders have successfully flown reconstructions.",
                hint: HintData(
                    riddle: "Wings too small, body too heavy, arms too weak — the dream of Icarus meets the truth of numbers...",
                    detailedHint: "Flight requires a specific power-to-weight ratio. Human muscles produce only about 0.25 horsepower sustained — far less than what flapping flight demands. Combined with frame weight, it was impossible.",
                    activityType: .trueFalse(
                        statement: "Leonardo's ornithopter could have flown if built with modern lightweight materials.",
                        isTrue: false,
                        explanation: "Even with modern materials, human muscles cannot generate enough sustained power for flapping flight. The fundamental power-to-weight ratio problem remains."
                    )
                )
            )
        ]
    )

    /// Get interactive challenge for a building
    static func interactiveChallenge(for buildingName: String) -> InteractiveChallenge? {
        switch buildingName {
        // Ancient Rome
        case "Roman Baths":
            return romanBathsInteractive
        case "Aqueduct":
            return aqueductInteractive
        case "Colosseum":
            return colosseumInteractive
        // Renaissance Italy (with aliases for renamed buildings)
        case "Duomo":
            return duomoInteractive
        case "Observatory", "Vatican Observatory":
            return observatoryInteractive
        case "Workshop", "Leonardo's Workshop":
            return workshopInteractive
        default:
            // Buildings without challenges yet return nil
            return nil
        }
    }

    // MARK: - Legacy Multiple Choice (kept for backwards compatibility)

    /// Roman Baths challenge - Hydraulics, Chemistry, Materials Science
    static let romanBaths = Challenge(
        buildingName: "Roman Baths",
        introduction: """
        Welcome, young architect! The Roman Baths (thermae) were marvels of engineering that combined \
        water management, chemistry, and materials science. These public bathing houses served millions \
        of Romans daily, requiring sophisticated systems to heat water, maintain hygiene, and build \
        structures that would last millennia.

        As you design your bathhouse, you'll need to understand how the Romans solved these challenges \
        using the sciences of their time.
        """,
        questions: [
            // HYDRAULICS Question 1
            ChallengeQuestion(
                questionText: "The Romans used a heating system called a hypocaust to warm their baths. How did this system work?",
                options: [
                    "Fire heated water directly in the pools",
                    "Hot air circulated under raised floors and through hollow walls",
                    "The sun heated black tiles on the roof",
                    "Underground hot springs were redirected"
                ],
                correctAnswerIndex: 1,
                science: .hydraulics,
                explanation: "The hypocaust system raised the floor on pillars (pilae), allowing hot air from a furnace (praefurnium) to circulate underneath. The heat rose through hollow spaces in the walls (tubuli), warming the entire room evenly.",
                funFact: "The word 'hypocaust' comes from Greek: 'hypo' (under) + 'kaustos' (burnt). Some Roman baths got so hot that bathers wore wooden sandals to protect their feet from the heated floors!"
            ),

            // HYDRAULICS Question 2
            ChallengeQuestion(
                questionText: "Roman aqueducts delivered water to the baths. What principle allowed water to flow from distant mountains without pumps?",
                options: [
                    "Water pressure from sealed pipes",
                    "Gravity and a gentle downward slope",
                    "Wind-powered wheels",
                    "Siphon tubes that pulled water upward"
                ],
                correctAnswerIndex: 1,
                science: .hydraulics,
                explanation: "Aqueducts used gravity to move water. Engineers calculated a precise slope (typically 1:200) so water would flow steadily over many kilometers. This is the same principle used in modern drainage systems!",
                funFact: "Rome's 11 aqueducts delivered over 1 million cubic meters of water daily - about 400 Olympic swimming pools! The Aqua Marcia ran 91 km to bring the best-tasting water to the city."
            ),

            // CHEMISTRY Question 1
            ChallengeQuestion(
                questionText: "Romans added certain substances to their bath water for health and cleanliness. Which chemical property made olive oil popular for bathing?",
                options: [
                    "It was acidic and killed bacteria",
                    "It dissolved dirt and could be scraped off with a strigil",
                    "It reacted with water to create soap",
                    "It changed color to show water purity"
                ],
                correctAnswerIndex: 1,
                science: .chemistry,
                explanation: "Olive oil is lipophilic (fat-loving), meaning it bonds with oils and dirt on skin. Romans would coat themselves in oil, then scrape it off with a curved metal tool called a strigil, removing dirt in the process.",
                funFact: "Romans didn't have soap as we know it! The Gauls and Germans invented true soap by mixing animal fat with wood ash. Romans thought this 'barbarian' invention was only good for hair styling!"
            ),

            // CHEMISTRY Question 2
            ChallengeQuestion(
                questionText: "The Romans treated their pool water to keep it clean. What natural material did they use to purify and disinfect the water?",
                options: [
                    "Salt from the sea",
                    "Copper and bronze vessels",
                    "Vinegar",
                    "Lime (calcium oxide)"
                ],
                correctAnswerIndex: 1,
                science: .chemistry,
                explanation: "Copper has natural antimicrobial properties - it releases ions that kill bacteria and algae. Romans lined pools with bronze or copper, and some baths had copper pipes. This is called the oligodynamic effect.",
                funFact: "Modern hospitals are now using copper surfaces to fight infections - the same principle Romans accidentally discovered 2,000 years ago! Copper can kill bacteria within hours."
            ),

            // MATERIALS SCIENCE Question 1
            ChallengeQuestion(
                questionText: "Roman concrete (opus caementicium) allowed them to build massive domed bath halls. What volcanic material made their concrete waterproof and stronger over time?",
                options: [
                    "Volcanic glass (obsidian)",
                    "Pumice stone",
                    "Volcanic ash (pozzolana)",
                    "Basalt rock"
                ],
                correctAnswerIndex: 2,
                science: .materials,
                explanation: "Pozzolanic ash from the Pozzuoli region reacted with lime and seawater to form a mineral called tobermorite. This actually makes the concrete stronger over time, unlike modern concrete which weakens!",
                funFact: "Scientists studied ancient Roman harbor concrete and found it's stronger after 2,000 years than when first poured! Modern concrete lasts about 50-100 years. We're now trying to recreate their formula."
            ),

            // MATERIALS SCIENCE Question 2
            ChallengeQuestion(
                questionText: "Roman baths featured beautiful marble surfaces. Why was marble particularly good for areas that got wet?",
                options: [
                    "Marble absorbs water like a sponge",
                    "Marble is non-porous and doesn't harbor bacteria easily",
                    "Marble generates heat when wet",
                    "Marble changes color to show water temperature"
                ],
                correctAnswerIndex: 1,
                science: .materials,
                explanation: "Marble's crystalline structure makes it relatively non-porous compared to other stones. Water beads on the surface rather than soaking in, making it easier to clean and less likely to grow mold or bacteria.",
                funFact: "The famous Baths of Caracalla in Rome used marble imported from across the empire - white from Greece, yellow from Tunisia, purple from Turkey, and green from Egypt. The floor alone covered 6 acres!"
            )
        ]
    )

    /// Get challenge for a specific building
    static func challenge(for buildingName: String) -> Challenge? {
        switch buildingName {
        case "Roman Baths":
            return romanBaths
        // Add more buildings here as you create them
        // case "Aqueduct":
        //     return aqueduct
        // case "Colosseum":
        //     return colosseum
        default:
            return nil
        }
    }
}
