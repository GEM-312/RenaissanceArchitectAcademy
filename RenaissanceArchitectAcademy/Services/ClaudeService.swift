import Foundation

/// Service for communicating with Claude — proxied through our Cloudflare Worker.
///
/// The real Anthropic key lives as a server-side secret on the Worker; this
/// app only carries `APIKeys.proxyToken`, the shared-secret that authenticates
/// the request to the Worker.
///
/// The bird uses real Anthropic tool-use: it can call `checkProgress`,
/// `checkInventory`, and `checkCalendar` on demand, and our app executes those
/// tools client-side (the calendar one reads EventKit). Claude decides *when* to
/// call them — we just run the loop.
///
/// Cost: ~$0.05 per 100 bird questions using Haiku 4.5
@MainActor
@Observable class ClaudeService: AIService {

    // Set to true to skip network calls and return canned responses instead.
    static var useLocalMock: Bool = false

    /// Max messages per card session (prevents runaway costs)
    static let maxMessagesPerSession = 6

    /// Model to use (Haiku for speed + cost)
    static let model = "claude-haiku-4-5-20251001"

    /// Sampling randomness (0.0 = deterministic, 1.0 = default). We use 0.0 so
    /// the bird's answers are consistent and stay tightly on the facts/lesson —
    /// the same question gives the same reliable reply, which also makes the
    /// prompt evals reproducible. Set ONLY temperature OR top_p, never both
    /// (Claude 4+ returns 400). Allowed on Haiku/Sonnet 4.x — removed on Opus 4.7.
    private let temperature = 0.0

    /// Hard cap on tool-use rounds per question, so a misbehaving model that
    /// keeps asking for tools can never spin forever (each round is a network call).
    private let maxToolRounds = 4

    /// This service uses real tool-calling — `BirdChatViewModel` hands us the
    /// `GameToolContext` so the tools have live progress/inventory data to return.
    var supportsTools: Bool { true }

    // MARK: - State

    var messages: [ChatMessage] = []
    var isLoading = false
    var error: String?

    /// Current context for the bird companion
    private var currentContext: BirdContext?

    /// Live game state the tools read from. Captured at session start; the
    /// calendar tool reads EventKit directly when called.
    private var toolContext: GameToolContext?

    // BirdContext is defined in AIService.swift (shared across all AI providers)

    // MARK: - Public API

    /// Start a new chat session with context from a knowledge card
    func startSession(context: BirdContext) {
        currentContext = context
        toolContext = nil
        messages = []
        error = nil
    }

    /// Start a session WITH game tools. The bird can call checkProgress /
    /// checkInventory / checkCalendar on demand; these read from `toolContext`.
    func startSession(context: BirdContext, toolContext: GameToolContext) {
        currentContext = context
        self.toolContext = toolContext
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
        toolContext = nil
        error = nil
        isLoading = false
    }

    // MARK: - Tool Definitions (Anthropic schema)

    /// The tools the bird may call. Descriptions are what Claude reads to decide
    /// *when* to call each — keep them action-oriented. `input_schema` follows
    /// JSON Schema; no-argument tools use an empty `properties` object.
    private static let toolDefinitions: [[String: Any]] = [
        [
            "name": "checkProgress",
            "description": "Check the player's building progress across the 17 buildings — which are complete, in progress, or locked, and which they're working on now. Call when the student asks what to do next or about their progress.",
            "input_schema": ["type": "object", "properties": [String: Any]()]
        ],
        [
            "name": "checkInventory",
            "description": "Check the player's raw materials, crafted items, tools, and gold florins. Call to suggest what they can craft or still need to collect.",
            "input_schema": ["type": "object", "properties": [String: Any]()]
        ],
        [
            "name": "checkCalendar",
            "description": "Check the student's upcoming real-world calendar events (tests, field trips, museum visits, trips to Italy) so you can connect a lesson to their actual schedule. Call when timing or what's-coming-up is relevant.",
            "input_schema": [
                "type": "object",
                "properties": [
                    "daysAhead": [
                        "type": "integer",
                        "description": "How many days ahead to look, between 1 and 14."
                    ]
                ]
            ]
        ]
    ]

    /// Execute a tool the model asked for, returning a string the model reads.
    private func runTool(name: String, input: [String: Any]) async -> String {
        guard let ctx = toolContext else {
            return "No game data is available right now."
        }
        switch name {
        case "checkProgress":
            return GameSnapshots.buildingProgress(
                buildingPlots: ctx.buildingPlots,
                activeBuildingName: ctx.activeBuildingName,
                totalComplete: ctx.totalComplete
            )
        case "checkInventory":
            return GameSnapshots.inventory(
                rawMaterials: ctx.rawMaterials,
                craftedItems: ctx.craftedItems,
                tools: ctx.tools,
                florins: ctx.florins
            )
        case "checkCalendar":
            let days = (input["daysAhead"] as? Int) ?? 14
            return await CalendarSnapshot.upcoming(days: days)
                ?? "No calendar access, or no upcoming events in that window."
        default:
            return "Unknown tool: \(name)"
        }
    }

    // MARK: - Claude API Call (via Cloudflare Worker proxy)

    /// Call Claude through our Cloudflare Worker (`POST /chat`), driving the
    /// tool-use loop. The Worker injects the real Anthropic key and forwards the
    /// `tools` array unchanged. Non-streaming: combining live streaming with
    /// tool-use parsing is fragile, so we take the whole JSON response per turn.
    private func callClaudeAPI(context: BirdContext) async throws -> String {
        guard WorkerClient.isConfigured else {
            throw ClaudeError.noAPIKey
        }

        // Seed the API message history from the visible chat (plain text turns).
        // Content uses [Any] so we can append tool_use / tool_result block arrays
        // as the loop progresses.
        var apiMessages: [[String: Any]] = messages.compactMap { msg in
            switch msg.role {
            case .user: return ["role": "user", "content": msg.content]
            case .assistant: return ["role": "assistant", "content": msg.content]
            case .system: return nil
            }
        }

        var round = 0
        while true {
            round += 1
            guard round <= maxToolRounds else {
                print("[ClaudeService] ⚠️ tool loop hit \(maxToolRounds) rounds — bailing")
                throw ClaudeError.apiError
            }

            let requestBody: [String: Any] = [
                "model": Self.model,
                "max_tokens": 300,
                "temperature": temperature,
                "system": context.systemPrompt,
                "tools": Self.toolDefinitions,
                "messages": apiMessages
            ]

            var request = URLRequest(url: WorkerClient.chatURL)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "content-type")
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            try await WorkerClient.authenticate(&request)
            request.timeoutInterval = 30

            let (data, httpResponse) = try await URLSession.shared.data(for: request)

            guard let response = httpResponse as? HTTPURLResponse else {
                throw ClaudeError.apiError
            }
            guard (200...299).contains(response.statusCode) else {
                print("[ClaudeService] API error \(response.statusCode): \(String(data: data, encoding: .utf8) ?? "")")
                throw ClaudeError.apiError
            }

            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let content = json["content"] as? [[String: Any]] else {
                throw ClaudeError.parseError
            }
            let stopReason = json["stop_reason"] as? String

            // Split the response content into text + any tool calls.
            var assembledText = ""
            var toolUses: [(id: String, name: String, input: [String: Any])] = []
            for block in content {
                switch block["type"] as? String {
                case "text":
                    if let t = block["text"] as? String { assembledText += t }
                case "tool_use":
                    if let id = block["id"] as? String, let name = block["name"] as? String {
                        toolUses.append((id, name, block["input"] as? [String: Any] ?? [:]))
                    }
                default:
                    break
                }
            }

            // The model asked for tools — run them, feed results back, loop.
            if stopReason == "tool_use", !toolUses.isEmpty {
                print("[ClaudeService] 🔧 round \(round): \(toolUses.map(\.name).joined(separator: ", "))")
                // Echo the assistant's turn verbatim (required before tool_result).
                apiMessages.append(["role": "assistant", "content": content])

                var resultBlocks: [[String: Any]] = []
                for use in toolUses {
                    let result = await runTool(name: use.name, input: use.input)
                    resultBlocks.append([
                        "type": "tool_result",
                        "tool_use_id": use.id,
                        "content": result
                    ])
                }
                apiMessages.append(["role": "user", "content": resultBlocks])
                continue
            }

            // Terminal turn — produce the answer.
            if stopReason == "refusal" {
                print("[ClaudeService] ⚠️ stop_reason=refusal — bird declined")
                return "Hmm, let's explore a different question about this card! 🐦"
            }
            guard !assembledText.isEmpty else {
                throw ClaudeError.parseError
            }
            if stopReason == "max_tokens" {
                print("[ClaudeService] ⚠️ stop_reason=max_tokens — bird reply clipped at 300 tokens")
            }
            return assembledText
        }
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
                return "Proxy token missing. Paste your hex token into APIKeys.swift."
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
