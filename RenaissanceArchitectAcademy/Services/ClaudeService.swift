import Foundation

/// Service for communicating with the Claude API via a backend proxy.
///
/// Architecture:
/// - iOS app sends requests to YOUR backend proxy (never directly to Anthropic)
/// - Backend proxy adds the API key and forwards to Claude API
/// - This keeps the API key out of the app binary
///
/// For development/testing, set `useLocalMock = true` to get instant responses
/// without any network calls.
@MainActor
class ClaudeService: ObservableObject {

    // MARK: - Configuration

    /// Your backend proxy URL (Cloudflare Worker, Firebase Function, etc.)
    /// In production, this should be your deployed proxy endpoint.
    /// Example: "https://bird-chat-proxy.yourname.workers.dev/v1/messages"
    static var proxyBaseURL: String = ""

    /// Use local mock responses instead of real API calls (for development)
    static var useLocalMock: Bool = true

    /// Max messages per card session (prevents runaway costs)
    static let maxMessagesPerSession = 6

    /// Model to use (Haiku for speed + cost, Sonnet for quality)
    static let model = "claude-haiku-4-5-20251001"

    // MARK: - State

    @Published var messages: [ChatMessage] = []
    @Published var isLoading = false
    @Published var error: String?

    /// Current context for the bird companion
    private var currentContext: BirdContext?

    // MARK: - Bird Context

    /// Context passed to Claude so the bird stays on-topic
    struct BirdContext {
        let buildingName: String
        let buildingId: Int
        let sciences: [String]
        let cardTitle: String
        let cardLesson: String
        let playerName: String
        let masteryLevel: String

        /// Build the system prompt for this context
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

    // MARK: - Public API

    /// Start a new chat session with context from a knowledge card
    func startSession(context: BirdContext) {
        currentContext = context
        messages = []
        error = nil
    }

    /// Send a student's question and get the bird's response
    func sendMessage(_ text: String) async {
        guard let context = currentContext else {
            error = "No active session"
            return
        }

        guard messages.filter({ $0.role == .user }).count < Self.maxMessagesPerSession else {
            error = "You've asked lots of great questions! Try another card to keep learning."
            return
        }

        let userMessage = ChatMessage(role: .user, content: text)
        messages.append(userMessage)
        isLoading = true
        error = nil

        do {
            let response: String
            if Self.useLocalMock {
                response = await mockResponse(for: text, context: context)
            } else {
                response = try await callAPI(context: context)
            }

            let assistantMessage = ChatMessage(role: .assistant, content: response)
            messages.append(assistantMessage)
        } catch {
            self.error = "The bird seems distracted... try again?"
            print("[ClaudeService] Error: \(error)")
        }

        isLoading = false
    }

    /// Clear the current session
    func endSession() {
        messages = []
        currentContext = nil
        error = nil
        isLoading = false
    }

    // MARK: - API Call

    /// Call the Claude API through the backend proxy
    private func callAPI(context: BirdContext) async throws -> String {
        guard !Self.proxyBaseURL.isEmpty else {
            throw ClaudeError.noProxyConfigured
        }

        guard let url = URL(string: Self.proxyBaseURL) else {
            throw ClaudeError.invalidURL
        }

        // Build message history for Claude
        var apiMessages: [[String: String]] = []
        for msg in messages {
            switch msg.role {
            case .user:
                apiMessages.append(["role": "user", "content": msg.content])
            case .assistant:
                apiMessages.append(["role": "assistant", "content": msg.content])
            case .system:
                break // System prompt goes in the system field
            }
        }

        let requestBody: [String: Any] = [
            "model": Self.model,
            "max_tokens": 300,
            "system": context.systemPrompt,
            "messages": apiMessages
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        request.timeoutInterval = 15

        let (data, httpResponse) = try await URLSession.shared.data(for: request)

        guard let response = httpResponse as? HTTPURLResponse,
              (200...299).contains(response.statusCode) else {
            throw ClaudeError.apiError
        }

        // Parse Claude API response format
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let content = json["content"] as? [[String: Any]],
              let firstBlock = content.first,
              let text = firstBlock["text"] as? String else {
            throw ClaudeError.parseError
        }

        return text
    }

    // MARK: - Mock Responses (Development)

    /// Generate contextual mock responses for testing without API calls
    private func mockResponse(for question: String, context: BirdContext) async -> String {
        // Simulate network delay
        try? await Task.sleep(for: .seconds(1.0))

        let q = question.lowercased()

        // Context-aware mock responses
        if q.contains("why") || q.contains("how come") {
            return "Ah, wonderful question! The \(context.buildingName) was built this way because the Romans understood something we often forget — the simplest solution is usually the strongest. They tested everything by building small models first. Science through practice, not just theory!"
        }

        if q.contains("how") || q.contains("what") {
            return "The \(context.cardTitle.lowercased()) is fascinating! In the \(context.buildingName), this connects to \(context.sciences.first ?? "engineering") — the builders used real measurements and calculations, not guesswork. Every number had a purpose."
        }

        if q.contains("math") || q.contains("calcul") || q.contains("number") {
            return "Let's think about the math! The \(context.buildingName) uses precise geometry. Try this: if the dome is 43.3 meters across, what's the circumference? Use C = \u{03C0} \u{00D7} d. The Romans knew this formula — they just called it something different!"
        }

        if q.contains("cool") || q.contains("awesome") || q.contains("wow") {
            return "Right?! The \(context.buildingName) is one of the most incredible buildings ever constructed. And here's the amazing part — it's still standing after nearly 2,000 years. Modern buildings are designed to last maybe 100. What do you think the Romans knew that we've forgotten?"
        }

        // Default contextual response
        return "That's a great observation about the \(context.buildingName)! The \(context.cardTitle) teaches us something important about \(context.sciences.joined(separator: " and ")). The ancient builders were scientists — they just didn't call themselves that. What else are you curious about?"
    }

    // MARK: - Errors

    enum ClaudeError: LocalizedError {
        case noProxyConfigured
        case invalidURL
        case apiError
        case parseError

        var errorDescription: String? {
            switch self {
            case .noProxyConfigured:
                return "Backend proxy URL not configured. Set ClaudeService.proxyBaseURL."
            case .invalidURL:
                return "Invalid proxy URL."
            case .apiError:
                return "The bird couldn't reach the library. Check your connection."
            case .parseError:
                return "The bird's response was garbled. Try again?"
            }
        }
    }
}
