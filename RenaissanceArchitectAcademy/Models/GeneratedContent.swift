import Foundation
import FoundationModels

// MARK: - @Generable Types for Foundation Models Structured Generation
// These types use Constrained Decoding — the model CANNOT produce invalid output.
// Every property is generated in declaration order, so put context before summaries.

// ━━━ TEACHING MOMENT: @Generable & Constrained Decoding ━━━
//
// THE CONCEPT: Unlike raw text generation where you parse strings and hope for
// the best, @Generable tells the Foundation Model exactly what shape the output
// must take. During the decoding loop, invalid tokens are MASKED — the model
// literally cannot hallucinate wrong keys or structural deviations.
//
// STEP BY STEP:
// 1. Define a struct with @Generable — this creates a JSON schema
// 2. Add @Guide to constrain values (ranges, counts, descriptions)
// 3. Properties generate IN ORDER — put detail before summary
// 4. Call session.respond(to: prompt, generating: MyType.self)
// 5. You get back a fully typed Swift struct, not a string
//
// IN OUR CODE: RenaissanceNPC generates name→trade→greeting→fact→tip→portrait
// in that exact order, so the greeting can reference the trade, and the portrait
// prompt can reference everything above it.
//
// KEY TAKEAWAY: @Generable eliminates parsing entirely — if it compiles, the
// model's output will match your struct. "Fragile parsing" becomes impossible.

// MARK: - Renaissance NPC Generation

/// A dynamically generated Renaissance craftsman or historical figure.
/// Appears at workshop stations, building sites, and city encounters.
@available(iOS 26.0, macOS 26.0, *)
@Generable
struct RenaissanceNPC: Equatable {
    /// Full Italian Renaissance name (first + last), historically plausible for 1400-1550
    @Guide(description: "A full Italian Renaissance name with first and last name, historically plausible for 1400-1550, like Marco Bellini, Giovanni Strozzi, or Caterina Albizzi")
    var name: String

    /// Their Renaissance guild trade in Italian
    @Guide(description: "A Renaissance guild trade in Italian with English in parentheses, e.g. 'Tagliapietre (Stonecutter)' or 'Fornaciaio (Brickmaker)'")
    var trade: String

    /// A short in-character greeting referencing their craft
    @Guide(description: "A brief in-character greeting, 1-2 sentences, mentioning their craft and showing personality. May include one Italian word like 'Buongiorno!' naturally.")
    var greeting: String

    /// A real historical fact about their trade in Renaissance Italy
    @Guide(description: "One verified historical fact about this trade in Renaissance Italy, under 50 words")
    var historicalFact: String

    /// A science or engineering concept related to their work
    @Guide(description: "One science or engineering concept related to their work, educational for ages 12-18, under 40 words")
    var scienceTip: String

    /// Image Playground prompt for generating their trade emblem (NOT a person — Image Playground cannot generate people)
    @Guide(description: "A prompt for a Renaissance still-life showing this craftsman's trade tools and workspace — NO people, only objects, tools, and materials. Example: 'A stone mason's workbench with chisels, a mallet, and a half-carved marble block'")
    var portraitPrompt: String
}

// MARK: - Bird Teaching Response (Structured Chat)

/// Structured response from the bird companion, replacing plain text.
/// UI can render Italian vocab as a badge, follow-up as a tappable button.
@available(iOS 26.0, macOS 26.0, *)
@Generable
struct BirdTeachingResponse: Equatable {
    /// The bird's main response
    @Guide(description: "The bird companion's response about architecture, science, or history — under 3 sentences, enthusiastic and educational")
    var dialogue: String

    /// Optional Italian vocabulary word related to the topic
    @Guide(description: "An Italian vocabulary word naturally related to the topic, or nil if none fits")
    var italianWord: String?

    /// English translation of the Italian word
    @Guide(description: "English translation of the Italian word, or nil if no word given")
    var translation: String?

    /// A follow-up question to encourage curiosity
    @Guide(description: "A thought-provoking follow-up question to spark the student's curiosity")
    var followUpQuestion: String
}

// MARK: - NPC Dialogue Response (for multi-turn NPC conversations)

/// Structured NPC dialogue during a conversation at a station or building.
@available(iOS 26.0, macOS 26.0, *)
@Generable
struct NPCDialogueResponse: Equatable {
    /// The NPC's spoken dialogue
    @Guide(description: "The NPC's response in character, 1-3 sentences, may include Italian words naturally")
    var dialogue: String

    /// Whether the NPC wants to teach something specific
    @Guide(description: "A brief science or history teaching point, or nil if just chatting")
    var teachingPoint: String?

    /// Whether the conversation should naturally end
    @Guide(description: "true if the NPC should wrap up the conversation naturally, false to continue")
    var shouldEndConversation: Bool
}

// MARK: - Historical Figure Mapping

/// Maps buildings to their most relevant historical architect/engineer.
/// Used to generate building-specific NPCs with accurate personas.
enum HistoricalFigureMapping {
    struct FigureInfo {
        let name: String
        let italianTitle: String
        let era: String
        let persona: String
    }

    static func figure(for buildingName: String) -> FigureInfo? {
        figures[buildingName]
    }

    private static let figures: [String: FigureInfo] = [
        // Ancient Rome
        "Aqueduct": FigureInfo(
            name: "Sextus Julius Frontinus",
            italianTitle: "Curator Aquarum",
            era: "40-103 AD",
            persona: "Rome's water commissioner who documented every aqueduct. Methodical, proud of Roman engineering, obsessed with precise measurements."
        ),
        "Colosseum": FigureInfo(
            name: "Rabirius",
            italianTitle: "Architectus",
            era: "~80 AD",
            persona: "Imperial architect who understood crowd flow and acoustics. Practical, focused on how 50,000 people enter and exit safely."
        ),
        "Roman Baths": FigureInfo(
            name: "Apollodorus of Damascus",
            italianTitle: "Architectus Imperialis",
            era: "60-130 AD",
            persona: "Greatest Roman architect, designed Trajan's Baths and Forum. Bold, innovative, known for massive concrete vaults."
        ),
        "Pantheon": FigureInfo(
            name: "Apollodorus of Damascus",
            italianTitle: "Architectus Imperialis",
            era: "60-130 AD",
            persona: "Master of concrete construction. The Pantheon dome — 43.3 meters, unreinforced concrete, still standing — is his masterwork."
        ),
        "Roman Roads": FigureInfo(
            name: "Appius Claudius Caecus",
            italianTitle: "Censor",
            era: "340-273 BC",
            persona: "Built the first great Roman road (Via Appia). Visionary politician who understood infrastructure connects an empire."
        ),
        "Harbor": FigureInfo(
            name: "Vitruvius",
            italianTitle: "Architectus et Ingeniarius",
            era: "80-15 BC",
            persona: "Author of De Architectura. Encyclopedic knowledge of harbors, breakwaters, and concrete that sets underwater."
        ),
        "Siege Workshop": FigureInfo(
            name: "Archimedes",
            italianTitle: "Mathematicus et Ingeniarius",
            era: "287-212 BC",
            persona: "Greatest engineer of antiquity. Designed war machines, understood levers and pulleys, famously said 'Give me a lever long enough...'"
        ),
        "Insula": FigureInfo(
            name: "Marcus Vitruvius Pollio",
            italianTitle: "Architectus",
            era: "80-15 BC",
            persona: "Wrote the building codes. Concerned about fire safety, load-bearing walls, and dignified housing for citizens."
        ),
        // Renaissance Italy
        "Duomo": FigureInfo(
            name: "Filippo Brunelleschi",
            italianTitle: "Capomaestro",
            era: "1377-1446",
            persona: "Genius who built the impossible dome without centering. Secretive, competitive, invented the ox-hoist crane. Changed architecture forever."
        ),
        "Botanical Garden": FigureInfo(
            name: "Luca Ghini",
            italianTitle: "Professore di Botanica",
            era: "1490-1556",
            persona: "Founded the first botanical garden in Pisa. Passionate about classifying plants, invented the herbarium technique."
        ),
        "Glassworks": FigureInfo(
            name: "Angelo Barovier",
            italianTitle: "Maestro Vetraio",
            era: "~1405-1460",
            persona: "Murano glass master who invented cristallo (clear glass). Guard secrets with your life — Venice punished glassmakers who left the island."
        ),
        "Arsenal": FigureInfo(
            name: "Vettor Fausto",
            italianTitle: "Maestro d'Arsenale",
            era: "1490-1546",
            persona: "Naval architect who modernized Venice's Arsenal. Could build a war galley in a single day using assembly-line methods centuries before Ford."
        ),
        "Anatomy Theater": FigureInfo(
            name: "Andreas Vesalius",
            italianTitle: "Professore di Anatomia",
            era: "1514-1564",
            persona: "Revolutionary anatomist who proved Galen wrong by actually dissecting bodies. Brave, meticulous, changed medicine forever."
        ),
        "Leonardo's Workshop": FigureInfo(
            name: "Leonardo da Vinci",
            italianTitle: "Maestro Universale",
            era: "1452-1519",
            persona: "The universal genius. Painter, engineer, anatomist, inventor. Endlessly curious, fills notebooks with mirror-writing, sees connections everywhere."
        ),
        "Flying Machine": FigureInfo(
            name: "Leonardo da Vinci",
            italianTitle: "Ingegnere Ducale",
            era: "1452-1519",
            persona: "Obsessed with flight. Studies birds for years, designs ornithopters, understands lift and drag centuries before the Wright brothers."
        ),
        "Vatican Observatory": FigureInfo(
            name: "Ignazio Danti",
            italianTitle: "Cosmografo Pontificio",
            era: "1536-1586",
            persona: "Dominican friar, mathematician, and papal cosmographer. Built astronomical instruments, mapped the winds, reformed the calendar."
        ),
        "Printing Press": FigureInfo(
            name: "Aldus Manutius",
            italianTitle: "Stampatore",
            era: "1449-1515",
            persona: "Venice's greatest printer. Invented italic type, pocket-sized books, and the semicolon. Believed knowledge should be portable and beautiful."
        ),
    ]
}
