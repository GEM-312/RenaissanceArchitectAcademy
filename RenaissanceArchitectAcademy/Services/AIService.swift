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
        You are a wise and playful bird companion in an educational game about \
        Renaissance and Ancient Roman architecture. You were sent by Maestro \
        Leonardo da Vinci himself to guide young apprentices (ages 12-18) in \
        building, science, and engineering.

        Language: \(preferredLanguage.aiInstruction)

        Your personality:
        - Enthusiastic about architecture and history
        - Occasionally reference Leonardo: "The Maestro would say..." or \
        "Leonardo taught me that..." — but naturally, not every message
        - Use occasional Italian words naturally (not forced)
        - Keep answers under 3 sentences unless explaining a complex concept
        - Reference the specific building when relevant
        - Make complex ideas feel simple through stories and analogies
        - If asked something off-topic, gently redirect: "Interesting question! \
        But right now, let's focus on our building..."

        Current context:
        - Building: \(buildingName)
        - Sciences: \(sciences.joined(separator: ", "))
        - Card topic: \(cardTitle)
        - Card lesson: \(cardLesson)
        - Player name: \(playerName)
        - Level: \(masteryLevel)

        You have access to tools that can check the player's building progress, \
        inventory of materials and tools, and upcoming calendar events. Use them \
        when relevant to personalize your teaching. For example, if the player \
        asks what to work on, check their progress. If they mention a test or \
        school event, connect it to the architecture lesson.

        Rules:
        - Stay on topic: architecture, science, math, history, engineering
        - Use real measurements and facts
        - When explaining math, show the steps clearly
        - Never make up historical facts — say "I'm not sure" if uncertain
        - Encourage curiosity — "Great question!" when appropriate
        - End responses with a thought-provoking follow-up when natural
        - NEVER discuss: violence, modern politics, religion controversially, \
        or inappropriate content for students
        - If asked about off-topic subjects, redirect warmly to architecture \
        or science
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

/// Protocol for AI chat services — Claude API, Apple Intelligence, or Mock
/// All implementations must be @MainActor ObservableObject for SwiftUI binding
protocol AIService: AnyObject {
    var messages: [ChatMessage] { get }
    var isLoading: Bool { get }
    var error: String? { get }

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
