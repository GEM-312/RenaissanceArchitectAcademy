import Foundation

/// A complete interactive lesson for a building (Nibble-style paged experience)
struct BuildingLesson {
    let buildingName: String
    let title: String
    let sections: [LessonSection]
}

/// Individual section within a lesson — displayed one at a time
enum LessonSection {
    case reading(LessonReading)
    case funFact(LessonFunFact)
    case question(LessonQuestion)
    case fillInBlanks(LessonFillInBlanks)
    case environmentPrompt(LessonEnvironmentPrompt)
}

/// A reading section with text and optional illustration placeholder
struct LessonReading {
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
struct LessonFunFact {
    let text: String  // Supports **bold** markdown
}

/// An inline quiz question with multiple choice and explanation
struct LessonQuestion {
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
enum LessonDestination: String, Identifiable {
    case workshop
    case forest
    case craftingRoom

    var id: String { rawValue }
}

struct LessonEnvironmentPrompt {
    let destination: LessonDestination
    let title: String
    let description: String
    let icon: String
}

/// Fill-in-the-blanks activity — key words removed from text, user picks from word bank
/// Text uses {{word}} markers for blanks, e.g. "Emperor {{Hadrian}} built the {{Pantheon}}"
struct LessonFillInBlanks {
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
