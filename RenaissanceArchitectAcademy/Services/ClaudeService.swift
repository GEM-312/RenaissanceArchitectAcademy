import Foundation

/// Service for communicating with the Claude API.
///
/// HOW TO SET UP:
/// 1. Go to https://console.anthropic.com → API Keys → Create Key
/// 2. Paste your key below where it says "YOUR_API_KEY_HERE"
/// 3. Set `useLocalMock = false` to enable real API calls
///
/// Cost: ~$0.05 per 100 bird questions using Haiku 4.5
@MainActor
@Observable class ClaudeService: AIService {

    // API key loaded from APIKeys.swift (not committed to repo)
    static let apiKey = APIKeys.claude

    // Set to false once you've added your API key above
    static var useLocalMock: Bool = false

    /// Max messages per card session (prevents runaway costs)
    static let maxMessagesPerSession = 6

    /// Model to use (Haiku for speed + cost)
    static let model = "claude-haiku-4-5-20251001"

    /// Anthropic API endpoint
    private static let apiURL = "https://api.anthropic.com/v1/messages"

    // MARK: - State

    var messages: [ChatMessage] = []
    var isLoading = false
    var error: String?

    /// Current context for the bird companion
    private var currentContext: BirdContext?

    // BirdContext is defined in AIService.swift (shared across all AI providers)

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
                response = try await callClaudeAPI(context: context)
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

    // MARK: - Claude API Call (Direct to Anthropic)

    /// Call the Claude API directly at api.anthropic.com
    private func callClaudeAPI(context: BirdContext) async throws -> String {
        guard Self.apiKey != "YOUR_API_KEY_HERE" else {
            throw ClaudeError.noAPIKey
        }

        guard let url = URL(string: Self.apiURL) else {
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
                break
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
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        request.setValue(Self.apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        request.timeoutInterval = 15

        let (data, httpResponse) = try await URLSession.shared.data(for: request)

        guard let response = httpResponse as? HTTPURLResponse else {
            throw ClaudeError.apiError
        }

        guard (200...299).contains(response.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? "unknown"
            print("[ClaudeService] API error \(response.statusCode): \(body)")
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

        return "That's a great observation about the \(context.buildingName)! The \(context.cardTitle) teaches us something important about \(context.sciences.joined(separator: " and ")). The ancient builders were scientists — they just didn't call themselves that. What else are you curious about?"
    }

    // MARK: - Errors

    enum ClaudeError: LocalizedError {
        case noAPIKey
        case invalidURL
        case apiError
        case parseError

        var errorDescription: String? {
            switch self {
            case .noAPIKey:
                return "No API key. Open ClaudeService.swift and paste your key from console.anthropic.com"
            case .invalidURL:
                return "Invalid API URL."
            case .apiError:
                return "The bird couldn't reach the library. Check your connection."
            case .parseError:
                return "The bird's response was garbled. Try again?"
            }
        }
    }
}
