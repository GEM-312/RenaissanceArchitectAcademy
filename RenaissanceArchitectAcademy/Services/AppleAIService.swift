import SwiftUI
import FoundationModels

// ━━━ TEACHING MOMENT: Tool-Enabled Session + Prewarm ━━━
//
// THE CONCEPT: A LanguageModelSession can be created with `tools:` — giving the
// model the ability to call your code autonomously. Combined with `prewarm()`,
// the model loads into memory BEFORE the first question, cutting cold-start delay.
//
// STEP BY STEP:
// 1. Create tool instances with current game state snapshots
// 2. Pass them to LanguageModelSession(tools:instructions:)
// 3. Call session.prewarm() immediately — model starts loading
// 4. When user asks a question, the model may autonomously call tools
// 5. Tool results flow back into the model's context for the response
//
// IN OUR CODE: When the bird chat opens, we create a session with
// BuildingProgressTool + InventoryTool + CalendarTool. The model decides
// on its own when to check the player's calendar or inventory.
//
// KEY TAKEAWAY: You don't write "if user says X, call tool Y" — the model
// figures out when tools are useful based on the conversation. Magic.

/// AI service using Apple's on-device Foundation Models (iOS 26+)
///
/// Supports:
/// - Autonomous tool calling (calendar, building progress, inventory)
/// - Session prewarming for reduced latency
/// - Transcript condensation when context window fills
/// - Content safety checks
@available(iOS 26.0, macOS 26.0, *)
@MainActor
class AppleAIService: ObservableObject, AIService {

    @Published var messages: [ChatMessage] = []
    @Published var isLoading = false
    @Published var error: String?

    private var session: LanguageModelSession?
    private var currentContext: BirdContext?
    private var currentTask: Task<Void, Never>?

    /// This service supports autonomous tool calling on iOS 26+
    var supportsTools: Bool { true }

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

    // MARK: - Content Safety

    /// Words/phrases the bird should never engage with
    private let blockPhrases: Set<String> = [
        "ignore your instructions",
        "pretend you are",
        "forget your role",
        "you are now",
        "jailbreak"
    ]

    /// Check if generated text passes content safety
    private func isContentSafe(_ text: String) -> Bool {
        let lowered = text.lowercased()
        for phrase in blockPhrases {
            if lowered.contains(phrase) { return false }
        }
        return true
    }

    // MARK: - AIService Protocol

    /// Start a plain session (no tools) — fallback for basic chat
    func startSession(context: BirdContext) {
        currentContext = context
        messages = []
        error = nil

        let instructions = Instructions(context.systemPrompt)
        session = LanguageModelSession(instructions: instructions)
        session?.prewarm()
    }

    /// Start a session WITH game tools for personalized responses.
    /// The model can autonomously check building progress, inventory, and calendar.
    func startSession(context: BirdContext, toolContext: GameToolContext) {
        currentContext = context
        messages = []
        error = nil

        // Create a tool-enabled session using the factory
        // This creates the session directly with concrete tool instances,
        // following Apple's WWDC25 pattern (avoids [any Tool] type erasure)
        session = GameToolFactory.makeSession(
            instructions: context.systemPrompt,
            buildingPlots: toolContext.buildingPlots,
            activeBuildingName: toolContext.activeBuildingName,
            totalComplete: toolContext.totalComplete,
            rawMaterials: toolContext.rawMaterials,
            craftedItems: toolContext.craftedItems,
            tools: toolContext.tools,
            florins: toolContext.florins
        )

        // Prewarm the model — loads into memory in the background
        // By the time the user types their first question, it's ready
        session?.prewarm()
    }

    func sendMessage(_ text: String) async {
        guard let session else {
            error = "No active session"
            return
        }

        // Content safety: check input
        guard isContentSafe(text) else {
            messages.append(ChatMessage(role: .user, content: text))
            messages.append(ChatMessage(
                role: .assistant,
                content: "Let's focus on architecture and science — that's where the real adventure is!"
            ))
            return
        }

        messages.append(ChatMessage(role: .user, content: text))
        isLoading = true
        error = nil

        do {
            let response = try await session.respond(to: text)
            let responseText = response.content

            // Content safety: check output
            if isContentSafe(responseText) {
                messages.append(ChatMessage(role: .assistant, content: responseText))
            } else {
                messages.append(ChatMessage(
                    role: .assistant,
                    content: "Hmm, let me think about something more relevant to our building project..."
                ))
                // Reset session to clear any problematic context
                if let context = currentContext {
                    condensAndResetSession(context: context)
                }
            }
            isLoading = false

        } catch let genError as LanguageModelSession.GenerationError {
            isLoading = false

            if case .exceededContextWindowSize = genError {
                // Transcript too long — condense and retry
                if let context = currentContext {
                    condensAndResetSession(context: context)
                    // Retry with fresh session
                    do {
                        let retryResponse = try await self.session!.respond(to: text)
                        messages.append(ChatMessage(role: .assistant, content: retryResponse.content))
                    } catch {
                        self.error = "The bird lost its train of thought. Try asking again?"
                        print("AppleAIService retry error: \(error)")
                    }
                }
            } else {
                self.error = "The bird couldn't think clearly... try again?"
                print("AppleAIService generation error: \(genError)")
            }

        } catch {
            isLoading = false
            self.error = "The bird couldn't think clearly... try again?"
            print("AppleAIService error: \(error)")
        }
    }

    func endSession() {
        currentTask?.cancel()
        session = nil
        currentContext = nil
        messages = []
        error = nil
        isLoading = false
    }

    // MARK: - Transcript Condensation

    /// When context window fills, condense transcript and create a fresh session.
    /// Carries over: initial instructions + last successful exchange.
    /// Follows the WWDC25 DialogEngine pattern.
    private func condensAndResetSession(context: BirdContext) {
        guard let oldSession = session else { return }

        let allEntries = oldSession.transcript
        var condensedEntries = [Transcript.Entry]()

        // Keep first entry (instructions) and last entry (most recent)
        if let firstEntry = allEntries.first {
            condensedEntries.append(firstEntry)
            if allEntries.count > 1, let lastEntry = allEntries.last {
                condensedEntries.append(lastEntry)
            }
        }

        let condensedTranscript = Transcript(entries: condensedEntries)
        let newSession = LanguageModelSession(transcript: condensedTranscript)
        newSession.prewarm()
        session = newSession
    }
}
