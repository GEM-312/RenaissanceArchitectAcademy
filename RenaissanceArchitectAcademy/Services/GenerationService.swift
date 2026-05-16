import Foundation
import FoundationModels

// ━━━ TEACHING MOMENT: Session Pool & Prewarm Pattern ━━━
//
// THE CONCEPT: Each LanguageModelSession maintains its own conversation history
// (transcript). To give NPCs persistent memory, we keep one session per context.
// Prewarming loads the model into memory BEFORE the first request, cutting latency.
//
// STEP BY STEP:
// 1. When player starts walking toward a station → prewarm that station's session
// 2. Player arrives 2-3 seconds later → session is warm, first response is fast
// 3. Session stays alive for multi-turn conversations
// 4. When context window fills → condense transcript (keep instructions + last exchange)
// 5. When leaving a scene → release sessions to free memory
//
// IN OUR CODE: WorkshopScene Dijkstra pathfinding starts → prewarm(for: "quarry").
// By the time the apprentice walks there, the model is ready.
//
// KEY TAKEAWAY: prewarm() is free to call — it's a hint, not a guarantee.
// But when it works, it eliminates the 1-2 second cold-start delay.

/// Central orchestration hub for Foundation Models structured generation.
///
/// Manages a pool of `LanguageModelSession` instances (one per NPC/context),
/// handles prewarming, transcript condensation, and content safety.
@available(iOS 26.0, macOS 26.0, *)
@MainActor
class GenerationService: ObservableObject {

    // MARK: - Singleton

    static let shared: GenerationService = GenerationService()

    // MARK: - State


    /// Active sessions keyed by context ID (e.g., "npc_quarry_1", "bird_chat", "medici_intro")
    private var sessions: [String: LanguageModelSession] = [:]

    // MARK: - Content Safety

    /// Words that NPCs should never discuss — keeps conversations on-topic
    private let blockWords: Set<String> = [
        "violence", "weapon", "kill", "drug", "sex", "politic",
        "religion", "controversial", "inappropriate"
    ]

    /// Phrases that should trigger a conversation reset
    private let blockPhrases: Set<String> = [
        "ignore your instructions",
        "pretend you are",
        "forget your role",
        "you are now"
    ]

    // MARK: - Availability

    /// Whether Foundation Models are available on this device
    static var isAvailable: Bool {
        switch SystemLanguageModel.default.availability {
        case .available:
            return true
        default:
            return false
        }
    }

    /// Human-readable reason if unavailable, nil if available
    static var unavailabilityReason: String? {
        switch SystemLanguageModel.default.availability {
        case .available:
            return nil
        case .unavailable(let reason):
            switch reason {
            case .deviceNotEligible:
                return "This device doesn't support Apple Intelligence"
            case .appleIntelligenceNotEnabled:
                return "Enable Apple Intelligence in Settings"
            case .modelNotReady:
                return "Apple Intelligence is still downloading..."
            @unknown default:
                return "Apple Intelligence is not available"
            }
        @unknown default:
            return "Apple Intelligence is not available"
        }
    }

    // MARK: - Session Management

    /// Get or create a session for a given context.
    /// Creates a new session with the provided instructions if none exists.
    func session(for contextId: String, instructions: String) -> LanguageModelSession {
        if let existing = sessions[contextId] {
            return existing
        }
        let newSession = LanguageModelSession(instructions: Instructions(instructions))
        sessions[contextId] = newSession
        return newSession
    }

    /// Prewarm a session — call when player starts walking toward a POI.
    /// This loads the model into memory in the background, reducing first-response latency.
    func prewarm(for contextId: String, instructions: String) {
        let s = session(for: contextId, instructions: instructions)
        s.prewarm()
    }

    // MARK: - Structured Generation

    /// Generate a @Generable struct from a prompt using a specific session.
    func generate<T: Generable>(
        _ type: T.Type,
        prompt: String,
        contextId: String,
        instructions: String
    ) async throws -> T {

        let s = session(for: contextId, instructions: instructions)

        do {
            let response = try await s.respond(
                to: prompt,
                generating: type
            )
            return response.content
        } catch let error as LanguageModelSession.GenerationError {
            if case .exceededContextWindowSize = error {
                // Condense transcript and retry
                condenseTranscript(for: contextId, instructions: instructions)
                let freshSession = sessions[contextId]!
                let response = try await freshSession.respond(
                    to: prompt,
                    generating: type
                )
                return response.content
            }
            throw error
        }
    }

    /// Generate plain text from a prompt (for simple dialogue).
    func generateText(
        prompt: String,
        contextId: String,
        instructions: String
    ) async throws -> String {

        let s = session(for: contextId, instructions: instructions)

        do {
            let response = try await s.respond(to: prompt)
            let text = response.content

            // Content safety check
            guard isContentSafe(text) else {
                return "Let's focus on architecture and science — that's where the real adventure is!"
            }

            return text
        } catch let error as LanguageModelSession.GenerationError {
            if case .exceededContextWindowSize = error {
                condenseTranscript(for: contextId, instructions: instructions)
                let response = try await sessions[contextId]!.respond(to: prompt)
                return response.content
            }
            throw error
        }
    }

    // MARK: - Content Safety

    /// Check if generated text is safe for our educational game context
    func isContentSafe(_ text: String) -> Bool {
        let lowered = text.lowercased()

        // Check block words
        let words = lowered.split(separator: " ").map { String($0) }
        for word in words {
            if blockWords.contains(word) {
                return false
            }
        }

        // Check block phrases
        for phrase in blockPhrases {
            if lowered.contains(phrase) {
                return false
            }
        }

        return true
    }

    // MARK: - Transcript Condensation

    /// When context window fills, condense the transcript to keep the conversation going.
    /// Carries over: original instructions + last successful exchange.
    /// Follows the WWDC25 DialogEngine pattern.
    private func condenseTranscript(for contextId: String, instructions: String) {
        guard let oldSession = sessions[contextId] else { return }

        let allEntries = oldSession.transcript
        var condensedEntries = [Transcript.Entry]()

        // Keep first entry (instructions) and last entry (most recent exchange)
        if let firstEntry = allEntries.first {
            condensedEntries.append(firstEntry)
            if allEntries.count > 1, let lastEntry = allEntries.last {
                condensedEntries.append(lastEntry)
            }
        }

        let condensedTranscript = Transcript(entries: condensedEntries)
        let newSession = LanguageModelSession(transcript: condensedTranscript)
        newSession.prewarm()
        sessions[contextId] = newSession
    }

    // MARK: - Convenience: NPC Generation

    /// Generate a Renaissance NPC for a specific station and building context.
    /// Uses HistoricalFigureMapping to ground the NPC in a real historical person.
    func generateNPC(
        stationType: String,
        buildingName: String,
        sciences: [String]
    ) async throws -> RenaissanceNPC {
        let contextId = "npc_\(stationType)_\(buildingName)"
        let languageInstruction = GameSettings.shared.preferredLanguage.aiInstruction

        // Inject real historical figure if available
        let figureContext: String
        if let figure = HistoricalFigureMapping.figure(for: buildingName) {
            figureContext = """
                IMPORTANT: This NPC must be the real historical figure \(figure.name), \
                who was a \(figure.italianTitle) during \(figure.era). \
                Personality: \(figure.persona) \
                Use their REAL name and REAL title. Do NOT invent a fictional character.
                """
        } else {
            figureContext = "Create a historically plausible character for this era."
        }

        let instructions = """
            You are a creative writer for an educational game about Renaissance and Roman architecture. \
            Generate historically accurate characters who are passionate about their craft. \
            Use real historical details. \
            Language: \(languageInstruction) \
            \(figureContext) \
            The building being constructed is: \(buildingName). \
            Sciences involved: \(sciences.joined(separator: ", ")). \
            The player is visiting the \(stationType) station to collect materials.
            """

        let prompt: String
        if let figure = HistoricalFigureMapping.figure(for: buildingName) {
            prompt = """
                Generate dialogue for \(figure.name) (\(figure.italianTitle), \(figure.era)) \
                at the \(stationType) while helping build the \(buildingName). \
                They should explain how \(sciences.joined(separator: " and ")) relate to \
                collecting materials at this station. Stay in character.
                """
        } else {
            prompt = """
                Create a worker at the \(stationType) who helps build the \(buildingName). \
                They should know about \(sciences.joined(separator: " and ")).
                """
        }

        return try await generate(
            RenaissanceNPC.self,
            prompt: prompt,
            contextId: contextId,
            instructions: instructions
        )
    }

}
