import SwiftUI
import FoundationModels

/// AI service using Apple's on-device Foundation Models (iOS 26+)
/// Uses whatever AI the user has configured in Apple Intelligence settings
/// (on-device model, or their connected OpenAI/Gemini/Claude account)
/// No message limit from us — user's own account handles their limits
@available(iOS 26.0, macOS 26.0, *)
@MainActor
class AppleAIService: ObservableObject, AIService {

    @Published var messages: [ChatMessage] = []
    @Published var isLoading = false
    @Published var error: String?

    private var session: LanguageModelSession?
    private var currentContext: BirdContext?

    // MARK: - Availability Check

    /// Check if Apple Intelligence is available on this device
    static var isAvailable: Bool {
        switch SystemLanguageModel.default.availability {
        case .available:
            return true
        default:
            return false
        }
    }

    /// Detailed availability status for UI
    static var availabilityReason: String? {
        switch SystemLanguageModel.default.availability {
        case .available:
            return nil
        case .unavailable(let reason):
            switch reason {
            case .deviceNotEligible:
                return "This device doesn't support Apple Intelligence"
            case .appleIntelligenceNotEnabled:
                return "Enable Apple Intelligence in Settings → Apple Intelligence"
            case .modelNotReady:
                return "Apple Intelligence model is still downloading..."
            @unknown default:
                return "Apple Intelligence is not available"
            }
        @unknown default:
            return "Apple Intelligence is not available"
        }
    }

    // MARK: - AIService Protocol

    func startSession(context: BirdContext) {
        currentContext = context
        messages = []
        error = nil

        // Create a new session with the bird's system prompt as Instructions
        let instructions = Instructions(context.systemPrompt)
        session = LanguageModelSession(instructions: instructions)
    }

    func sendMessage(_ text: String) async {
        guard session != nil else {
            error = "No active session"
            return
        }

        // Add user message
        messages.append(ChatMessage(role: .user, content: text))
        isLoading = true
        error = nil

        do {
            // Use non-streaming respond for simplicity
            let response = try await session!.respond(to: text)
            let responseText = response.content
            messages.append(ChatMessage(role: .assistant, content: responseText))
            isLoading = false
        } catch {
            isLoading = false
            self.error = "The bird couldn't think clearly... try again?"
            print("AppleAIService error: \(error)")
        }
    }

    func endSession() {
        session = nil
        currentContext = nil
        messages = []
        error = nil
        isLoading = false
    }
}
