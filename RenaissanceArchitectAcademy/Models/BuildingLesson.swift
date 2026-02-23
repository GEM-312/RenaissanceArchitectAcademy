import Foundation

/// A complete interactive lesson for a building (Nibble-style paged experience)
struct BuildingLesson: Codable {
    let buildingName: String
    let title: String
    let sections: [LessonSection]
}

/// Individual section within a lesson — displayed one at a time
enum LessonSection: Codable {
    case reading(LessonReading)
    case funFact(LessonFunFact)
    case question(LessonQuestion)
    case fillInBlanks(LessonFillInBlanks)
    case environmentPrompt(LessonEnvironmentPrompt)
    case curiosity(LessonCuriosity)          // "Students Also Ask" — tappable Q&A
    case mathVisual(LessonMathVisual)        // Animated step-by-step math diagram

    // MARK: - Custom Codable for enum with associated values

    private enum CodingKeys: String, CodingKey {
        case type, data
    }

    private enum SectionType: String, Codable {
        case reading, funFact, question, fillInBlanks, environmentPrompt, curiosity, mathVisual
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .reading(let v):
            try container.encode(SectionType.reading, forKey: .type)
            try container.encode(v, forKey: .data)
        case .funFact(let v):
            try container.encode(SectionType.funFact, forKey: .type)
            try container.encode(v, forKey: .data)
        case .question(let v):
            try container.encode(SectionType.question, forKey: .type)
            try container.encode(v, forKey: .data)
        case .fillInBlanks(let v):
            try container.encode(SectionType.fillInBlanks, forKey: .type)
            try container.encode(v, forKey: .data)
        case .environmentPrompt(let v):
            try container.encode(SectionType.environmentPrompt, forKey: .type)
            try container.encode(v, forKey: .data)
        case .curiosity(let v):
            try container.encode(SectionType.curiosity, forKey: .type)
            try container.encode(v, forKey: .data)
        case .mathVisual(let v):
            try container.encode(SectionType.mathVisual, forKey: .type)
            try container.encode(v, forKey: .data)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(SectionType.self, forKey: .type)
        switch type {
        case .reading:
            self = .reading(try container.decode(LessonReading.self, forKey: .data))
        case .funFact:
            self = .funFact(try container.decode(LessonFunFact.self, forKey: .data))
        case .question:
            self = .question(try container.decode(LessonQuestion.self, forKey: .data))
        case .fillInBlanks:
            self = .fillInBlanks(try container.decode(LessonFillInBlanks.self, forKey: .data))
        case .environmentPrompt:
            self = .environmentPrompt(try container.decode(LessonEnvironmentPrompt.self, forKey: .data))
        case .curiosity:
            self = .curiosity(try container.decode(LessonCuriosity.self, forKey: .data))
        case .mathVisual:
            self = .mathVisual(try container.decode(LessonMathVisual.self, forKey: .data))
        }
    }
}

// MARK: - Math Visual Types (2 per building)

/// Types of animated math diagrams — 2 per building, 34 total
enum MathVisualType: String, Codable {
    // Aqueduct (#1) — Engineering, Hydraulics, Math
    case aqueductGradient           // Slope ratio diagram (1:200)
    case aqueductFlowRate           // Speed × time = total water

    // Colosseum (#2) — Architecture, Engineering, Acoustics
    case colosseumArchForce         // How arches distribute weight downward
    case colosseumSoundWave         // Sound reflection in amphitheater bowl

    // Roman Baths (#3) — Hydraulics, Chemistry, Materials
    case bathsHeatTransfer          // Hypocaust: hot air rises through floor pillae
    case bathsWaterVolume           // Pool volume = length × width × depth

    // Pantheon (#4) — Geometry, Architecture, Materials
    case pantheonDomeGeometry       // Perfect hemisphere: height = radius
    case pantheonOculusLight        // Sun angle through the oculus at different hours

    // Roman Roads (#5) — Engineering, Geology, Materials
    case roadsLayerCross            // Cross-section: 4 road layers + crown
    case roadsLoadDistribution      // Weight spreads through layers

    // Harbor (#6) — Engineering, Physics, Hydraulics
    case harborBuoyancy             // Archimedes: displaced water = buoyant force
    case harborTidalForce           // Wave force on breakwater

    // Siege Workshop (#7) — Physics, Engineering, Math
    case siegeProjectile            // Parabolic trajectory of catapult
    case siegeLeverArm              // Lever: effort × distance = load × distance

    // Insula (#8) — Architecture, Materials, Math
    case insulaFloorLoading         // Weight per floor stacks up
    case insulaHeightRatio          // Height-to-base stability ratio

    // Duomo (#9) — Geometry, Architecture, Physics
    case duomoCurvature             // Catenary curve of the double dome
    case duomoForceRing             // Compression forces in the lantern ring

    // Botanical Garden (#10) — Biology, Chemistry, Geology
    case gardenPhotosynthesis       // CO₂ + H₂O + sunlight → glucose + O₂
    case gardenGrowthRate           // Plant growth curve over time

    // Glassworks (#11) — Chemistry, Optics, Materials
    case glassTemperature           // Phase diagram: solid → liquid → workable
    case glassRefraction            // Snell's law: light bends entering glass

    // Arsenal (#12) — Engineering, Physics, Materials
    case arsenalPulleySystem        // Mechanical advantage with pulleys
    case arsenalProductionRate      // Assembly line: ships per month

    // Anatomy Theater (#13) — Biology, Optics, Chemistry
    case anatomyProportion          // Vitruvian Man: body ratios
    case anatomyCirculation         // Blood flow: heart → arteries → veins → heart

    // Leonardo's Workshop (#14) — Engineering, Physics, Materials
    case leonardoGearRatio          // Gear teeth: driven/driver = speed ratio
    case leonardoGoldenSpiral       // Golden ratio spiral construction

    // Flying Machine (#15) — Physics, Engineering, Math
    case flyingLiftFormula          // Lift = ½ρv²SCL (simplified)
    case flyingWingArea             // Wing area calculation for weight

    // Vatican Observatory (#16) — Astronomy, Optics, Math
    case observatoryMagnification   // Telescope: focal length ratio = magnification
    case observatoryParallax        // Stellar parallax measurement

    // Printing Press (#17) — Engineering, Chemistry, Physics
    case pressForceMultiplier       // Screw press: torque → linear force
    case pressTypeSetting           // Characters per page calculation
}

/// An animated step-by-step math diagram embedded in a lesson
struct LessonMathVisual: Codable {
    let type: MathVisualType
    let title: String
    let science: Science
    let totalSteps: Int
    let caption: String
}

// MARK: - Section Data Types (all Codable)

/// A reading section with text and optional illustration placeholder
struct LessonReading: Codable {
    let title: String?
    let body: String              // Supports **bold** markdown
    let science: Science?         // Which science this teaches (badge shown)
    let illustrationIcon: String? // SF Symbol for placeholder illustration
    let caption: String?          // Optional image caption

    init(title: String? = nil, body: String, science: Science? = nil,
         illustrationIcon: String? = nil, caption: String? = nil) {
        self.title = title
        self.body = body
        self.science = science
        self.illustrationIcon = illustrationIcon
        self.caption = caption
    }
}

/// A fun fact callout card (sticky-note style with paperclip)
struct LessonFunFact: Codable {
    let text: String  // Supports **bold** markdown
}

/// An inline quiz question with multiple choice and explanation
struct LessonQuestion: Codable {
    let question: String
    let options: [String]
    let correctIndex: Int
    let explanation: String
    let science: Science
    let hints: [String]?  // Progressive hints (up to 3 levels) for math questions

    init(question: String, options: [String], correctIndex: Int,
         explanation: String, science: Science, hints: [String]? = nil) {
        self.question = question
        self.options = options
        self.correctIndex = correctIndex
        self.explanation = explanation
        self.science = science
        self.hints = hints
    }
}

/// A prompt to visit an interactive environment (Workshop, Forest, etc.)
enum LessonDestination: String, Codable, Identifiable {
    case workshop
    case forest
    case craftingRoom

    var id: String { rawValue }
}

struct LessonEnvironmentPrompt: Codable {
    let destination: LessonDestination
    let title: String
    let description: String
    let icon: String
}

/// "Students Also Ask" — expandable Q&A cards shown after readings
struct LessonCuriosity: Codable {
    let questions: [CuriosityQA]
}

/// A single curiosity question + pre-written answer
struct CuriosityQA: Codable {
    let question: String
    let answer: String
}

/// Fill-in-the-blanks activity — key words removed from text, user picks from word bank
/// Text uses {{word}} markers for blanks, e.g. "Emperor {{Hadrian}} built the {{Pantheon}}"
struct LessonFillInBlanks: Codable {
    let title: String?
    let text: String            // Text with {{word}} markers for blanks
    let distractors: [String]   // Extra wrong words mixed into the word bank
    let science: Science?

    init(title: String? = nil, text: String, distractors: [String] = [], science: Science? = nil) {
        self.title = title
        self.text = text
        self.distractors = distractors
        self.science = science
    }

    /// Extract the correct words from {{markers}} in order
    var correctWords: [String] {
        var words: [String] = []
        var remaining = text[text.startIndex...]
        while let openRange = remaining.range(of: "{{") {
            let afterOpen = remaining[openRange.upperBound...]
            if let closeRange = afterOpen.range(of: "}}") {
                let word = String(afterOpen[afterOpen.startIndex..<closeRange.lowerBound])
                words.append(word)
                remaining = afterOpen[closeRange.upperBound...]
            } else {
                break
            }
        }
        return words
    }

    /// All words for the word bank (correct + distractors), shuffled
    var wordBank: [String] {
        (correctWords + distractors).shuffled()
    }

    /// Text segments split around blanks: [("Emperor ", nil), ("", "Hadrian"), (" built the ", nil), ("", "Pantheon")]
    var segments: [(text: String, blankWord: String?)] {
        var result: [(String, String?)] = []
        var remaining = text[text.startIndex...]
        while let openRange = remaining.range(of: "{{") {
            let before = String(remaining[remaining.startIndex..<openRange.lowerBound])
            if !before.isEmpty {
                result.append((before, nil))
            }
            let afterOpen = remaining[openRange.upperBound...]
            if let closeRange = afterOpen.range(of: "}}") {
                let word = String(afterOpen[afterOpen.startIndex..<closeRange.lowerBound])
                result.append(("", word))
                remaining = afterOpen[closeRange.upperBound...]
            } else {
                break
            }
        }
        let trailing = String(remaining)
        if !trailing.isEmpty {
            result.append((trailing, nil))
        }
        return result
    }
}
