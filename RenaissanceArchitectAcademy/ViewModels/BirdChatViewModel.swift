import SwiftUI

/// Coordinates AI service selection for the bird chat
/// Manages: provider choice, service lifecycle, tool configuration, subscription checks
@MainActor
@Observable class BirdChatViewModel {

    // MARK: - State (forwarded from active service)

    var messages: [ChatMessage] = []
    var isLoading = false
    var error: String?

    /// Live partial reply forwarded from a streaming service (Claude). Nil when
    /// not streaming or when the active service doesn't stream.
    var streamingText: String?

    /// Whether the user needs to pick an AI provider (first time)
    var showProviderPicker = false

    // MARK: - Active Service

    @ObservationIgnored private var activeService: (any AIService)?
    @ObservationIgnored private var currentContext: BirdContext?

    /// Game state for tool calling — set before starting a session
    var gameToolContext: GameToolContext?

    /// Chat is Claude-only. Apple Intelligence was removed as a chat brain — the
    /// on-device model is too weak for free-form chat (it still powers the
    /// contextual-suggestion nudges elsewhere). Hardcoded so the message-cap
    /// display and service creation don't depend on a stored setting.
    var currentProvider: AIProvider { .claudePremium }

    // MARK: - Service Creation

    /// The bird chat always uses Claude (via the Worker proxy).
    private func createService(for provider: AIProvider) -> any AIService {
        ClaudeService()
    }

    // MARK: - Session Management

    /// Start a chat session — Claude-only, activates immediately (no picker).
    func startSession(context: BirdContext) {
        currentContext = context
        activateService(provider: currentProvider, context: context)
    }

    /// Called after user picks a provider from the picker
    func selectProvider(_ provider: AIProvider) {
        GameSettings.shared.preferredAIProvider = provider
        GameSettings.shared.hasChosenAIProvider = true
        showProviderPicker = false

        if let context = currentContext {
            activateService(provider: provider, context: context)
        }
    }

    private func activateService(provider: AIProvider, context: BirdContext) {
        let service = createService(for: provider)
        activeService = service

        // If the service supports tools AND we have game state, start with tools
        if service.supportsTools, let toolCtx = gameToolContext {
            service.startSession(context: context, toolContext: toolCtx)
        } else {
            service.startSession(context: context)
        }

        // Observe the service's state via withObservationTracking (bridges protocol existential)
        observeService(service)
    }

    /// Forward state from the active service using observation tracking.
    /// Replaces the old 100ms polling loop — fires once per change, event-driven.
    private func observeService(_ service: any AIService) {
        withObservationTracking {
            _ = service.messages
            _ = service.isLoading
            _ = service.error
            _ = service.streamingText
        } onChange: {
            Task { @MainActor [weak self] in
                guard let self, self.activeService != nil else { return }
                self.messages = service.messages
                self.isLoading = service.isLoading
                self.error = service.error
                self.streamingText = service.streamingText
                self.observeService(service)  // re-register for next change
            }
        }
    }

    /// Send a message through the active service
    func sendMessage(_ text: String) async {
        guard let service = activeService else {
            error = "No AI service active"
            return
        }

        // Claude API: check subscription (skip for now — always allow in dev)
        // if currentProvider == .claudeAPI && !SubscriptionManager.shared.hasActiveSubscription {
        //     error = "Subscribe to use Claude AI"
        //     return
        // }

        await service.sendMessage(text)
    }

    /// End the current session
    func endSession() {
        activeService?.endSession()
        activeService = nil
        messages = []
        error = nil
        isLoading = false
        streamingText = nil
        currentContext = nil
    }

    /// Message count for rate limiting display (Claude only)
    var userMessageCount: Int {
        messages.filter { $0.role == .user }.count
    }

    /// Max messages (only applies to Claude API)
    var maxMessages: Int? {
        currentProvider == .claudePremium ? ClaudeService.maxMessagesPerSession : nil
    }
}
