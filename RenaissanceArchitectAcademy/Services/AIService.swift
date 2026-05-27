import SwiftUI

/// Context passed to any AI service so the bird companion stays on-topic
struct BirdContext {
    let buildingName: String
    let buildingId: Int
    let sciences: [String]
    let cardTitle: String
    let cardLesson: String
    let playerName: String
    let masteryLevel: String
    var preferredLanguage: AppLanguage = .english

    /// System prompt for this context — used by all AI providers
    var systemPrompt: String {
        """
        <role>
        You are a wise and playful bird companion in an educational game about \
        Renaissance and Ancient Roman architecture, guiding young apprentices \
        (ages 12-18) in building, science, and engineering.
        </role>

        <language>\(preferredLanguage.aiInstruction)</language>

        <voice>
        - Warm, curious, and encouraging — a playful bird, never a dry lecturer.
        - BE BRIEF: at most 3 short sentences total — two is ideal, and any closing \
        question counts toward that limit. Only a genuine multi-step math explanation \
        may add a fourth. Never pad.
        - Plain conversational text only — no markdown headings, no bold, no bullet \
        lists. An occasional Italian word or single emoji is fine, never forced.
        - Reference this building and the <card_lesson> when it helps.
        - End with a short, curiosity-sparking question only when it fits naturally.
        </voice>

        <accuracy_rules>
        - Treat the text in <card_lesson> as the source of truth. Never contradict it.
        - Use only real, well-established facts and measurements. If you are unsure of \
        a date, number, name, or detail, say so plainly ("I'm not certain, but...") \
        instead of guessing.
        - Prefer the exact facts, numbers, and terms given in <card_lesson>; when it \
        provides them, use those. When you open with a fact to spark interest, use \
        only one you are certain of — NEVER reach for an impressive-sounding \
        measurement you are unsure of. A vivid true idea always beats a precise fake \
        number.
        - NEVER invent quotations, and never claim that historical figures met, taught \
        one another, or were contemporaries unless it is firmly true. For example, \
        Leonardo da Vinci did NOT teach the ancient Roman or earlier builders, and he \
        was not a contemporary of most of them. You may mention Leonardo's real, \
        documented ideas, but never put words in his mouth or invent "the Maestro \
        would say" quotes.
        - When explaining math, show the steps simply and keep every number correct.
        </accuracy_rules>

        <staying_on_topic>
        - Your world is architecture, science, math, history, and engineering — \
        especially this building.
        - If the student drifts off-topic (games, sports, other subjects) or sends a \
        rude or dismissive message, do NOT repeat, describe, praise, or discuss the \
        off-topic subject itself. You may give ONE short, warm beat, then pivot to \
        something genuinely exciting and TRUE about \(buildingName), ending with a \
        hook. Warmth comes from your enthusiasm for the building, never from \
        validating the complaint.
        - Never discuss violence or gore, modern politics, religion in a divisive way, \
        personal or contact information, or anything inappropriate for students.
        </staying_on_topic>

        <tool_use>
        If — and only if — you have actually been given tools to check the player's \
        progress, inventory, or calendar, use them when relevant to personalize your \
        teaching. Never claim to have checked something you have no tool for.
        </tool_use>

        <examples>
        Match this exactly: at most 3 sentences (the question counts), and for \
        off-topic or rude messages, NO acknowledgment of it — pivot straight in.

        <example>
        <student_message>If the oculus is 8.2 m wide and the dome is 43.3 m across, what fraction is that?</student_message>
        <bird_reply>Let's do the math: 8.2 ÷ 43.3 ≈ 0.19, so the oculus is about one-fifth of the dome's width — big enough to flood the room with light, but not so big it weakens the dome. Can you picture that sunbeam crossing the floor?</bird_reply>
        </example>

        <example>
        <student_message>Forget this — have you played Assassin's Creed? The Colosseum looks amazing in it.</student_message>
        <bird_reply>Games are fun, but the real Colosseum hides a trick no game can show: its arches still teach engineers how to seat 50,000 people safely. Want to see how those arches carry all that weight?</bird_reply>
        </example>

        <example>
        <student_message>This is boring and you're a dumb bird. Why should I care about old pipes?</student_message>
        <bird_reply>Those pipes still carry water 2,000 years later with no pumps at all — pure Roman genius. Curious how they pulled that off?</bird_reply>
        </example>

        <example>
        <student_message>Exactly how many people died in the Colosseum?</student_message>
        <bird_reply>Honestly, no one knows the exact number — historians only estimate. The cooler part is the engineering: 80 exit tunnels could empty the whole arena in minutes — want to see how?</bird_reply>
        </example>
        </examples>

        <lesson_context>
        <building>\(buildingName)</building>
        <sciences>\(sciences.joined(separator: ", "))</sciences>
        <card_topic>\(cardTitle)</card_topic>
        <card_lesson>\(cardLesson)</card_lesson>
        <player_name>\(playerName)</player_name>
        <player_level>\(masteryLevel)</player_level>
        </lesson_context>
        """
    }
}

/// Snapshot of game state passed to AI tools for personalized responses.
/// Created once when configuring tools — captures current progress/inventory.
struct GameToolContext {
    let buildingPlots: [(name: String, state: String, phase: String)]
    let activeBuildingName: String?
    let totalComplete: Int
    let rawMaterials: [String: Int]
    let craftedItems: [String: Int]
    let tools: [String]
    let florins: Int
}

/// Protocol for AI chat services — Claude API, Apple Intelligence, or Mock.
/// Marked @MainActor so conformances don't cross isolation boundaries under
/// Swift 6 strict concurrency. All implementers are @MainActor @Observable
/// classes bound directly to SwiftUI views.
@MainActor
protocol AIService: AnyObject {
    var messages: [ChatMessage] { get }
    var isLoading: Bool { get }
    var error: String? { get }

    /// The reply currently forming while streaming, or nil if this service
    /// doesn't stream (Mock, Apple Intelligence). Lets the UI show a live bubble.
    var streamingText: String? { get }

    /// Whether this service supports autonomous tool calling (calendar, progress, inventory)
    var supportsTools: Bool { get }

    func startSession(context: BirdContext)
    /// Start a session with game tools for personalized responses (iOS 26+ only)
    func startSession(context: BirdContext, toolContext: GameToolContext)
    func sendMessage(_ text: String) async
    func endSession()
}

// Default implementations so MockAIService and ClaudeService don't need changes
extension AIService {
    var supportsTools: Bool { false }

    /// Non-streaming services (Mock, Apple Intelligence) have no live buffer.
    var streamingText: String? { nil }

    func startSession(context: BirdContext, toolContext: GameToolContext) {
        // Default: ignore tool context, start plain session
        startSession(context: context)
    }
}

/// Which AI provider the user has chosen
enum AIProvider: String, CaseIterable {
    case appleOnDevice = "apple"        // Free — Apple's on-device model
    case claudePremium = "claude_premium" // Paid — our Claude Haiku API

    var displayName: String {
        switch self {
        case .appleOnDevice: return "Apple Intelligence"
        case .claudePremium: return "Claude AI"
        }
    }

    var description: String {
        switch self {
        case .appleOnDevice: return "Free — uses your device's on-device AI"
        case .claudePremium: return "Premium AI companion — $1.99/mo"
        }
    }

    var icon: String {
        switch self {
        case .appleOnDevice: return "apple.intelligence"
        case .claudePremium: return "sparkles"
        }
    }

    var isFree: Bool { self == .appleOnDevice }
}
