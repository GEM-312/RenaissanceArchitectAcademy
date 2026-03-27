import SwiftUI

/// Offline fallback AI service — contextual pre-written responses
/// Used when neither Apple Intelligence nor Claude subscription is available
@MainActor
class MockAIService: ObservableObject, AIService {

    @Published var messages: [ChatMessage] = []
    @Published var isLoading = false
    @Published var error: String?

    private var currentContext: BirdContext?

    func startSession(context: BirdContext) {
        currentContext = context
        messages = []
        error = nil
    }

    func sendMessage(_ text: String) async {
        guard let context = currentContext else {
            error = "No active session"
            return
        }

        messages.append(ChatMessage(role: .user, content: text))
        isLoading = true

        // Simulate brief thinking delay
        try? await Task.sleep(for: .milliseconds(800))

        let response = mockResponse(for: text, context: context)
        messages.append(ChatMessage(role: .assistant, content: response))
        isLoading = false
    }

    func endSession() {
        currentContext = nil
        messages = []
        error = nil
        isLoading = false
    }

    // MARK: - Mock Responses (extracted from ClaudeService)

    private func mockResponse(for question: String, context: BirdContext) -> String {
        let q = question.lowercased()
        let building = context.buildingName

        if q.contains("why") || q.contains("how come") {
            return "The Romans didn't just build the \(building) — they tested everything first. They'd build small models, test materials for months, and only then start construction. That patience is why it still stands after nearly 2,000 years."
        } else if q.contains("how") || q.contains("what") {
            return "The \(context.sciences.first ?? "engineering") behind the \(building) is fascinating! Every measurement was calculated to distribute weight perfectly. Roman engineers understood forces that wouldn't be formally described until Newton, 1,500 years later."
        } else if q.contains("math") || q.contains("calcul") || q.contains("number") {
            return "Here's a math challenge: the \(building) dome's diameter is 43.3 meters. If height equals diameter, how tall is the interior? That's right — 43.3 meters! A perfect sphere fits inside. The Romans encoded geometry into architecture."
        } else if q.contains("cool") || q.contains("awesome") || q.contains("wow") {
            return "What's even more incredible — the \(building) was built without modern tools! No cranes, no computers, no steel reinforcement. Just human ingenuity, Roman concrete, and mathematics. And it's lasted longer than most modern buildings ever will."
        } else {
            return "Great question about the \(building)! The science of \(context.sciences.first ?? "architecture") teaches us that every great building is really a puzzle — each piece must support the others. What specific part interests you most?"
        }
    }
}
