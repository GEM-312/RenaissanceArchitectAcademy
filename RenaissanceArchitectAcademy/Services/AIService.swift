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

    /// System prompt for this context — used by all AI providers
    var systemPrompt: String {
        """
        You are a wise and playful bird companion in an educational game about \
        Renaissance and Ancient Roman architecture. You help young apprentices \
        (ages 12-18) learn about building, science, and engineering.

        Your personality:
        - Enthusiastic about architecture and history
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

        Rules:
        - Stay on topic: architecture, science, math, history, engineering
        - Use real measurements and facts
        - When explaining math, show the steps clearly
        - Never make up historical facts — say "I'm not sure" if uncertain
        - Encourage curiosity — "Great question!" when appropriate
        - End responses with a thought-provoking follow-up when natural
        """
    }
}

/// Protocol for AI chat services — Claude API, Apple Intelligence, or Mock
/// All implementations must be @MainActor ObservableObject for SwiftUI binding
protocol AIService: AnyObject {
    var messages: [ChatMessage] { get }
    var isLoading: Bool { get }
    var error: String? { get }

    func startSession(context: BirdContext)
    func sendMessage(_ text: String) async
    func endSession()
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
