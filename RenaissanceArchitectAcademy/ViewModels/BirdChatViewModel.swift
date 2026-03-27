import SwiftUI

/// Coordinates AI service selection for the bird chat
/// Manages: provider choice, service lifecycle, tool configuration, subscription checks
@MainActor
class BirdChatViewModel: ObservableObject {

    // MARK: - Published State (forwarded from active service)

    @Published var messages: [ChatMessage] = []
    @Published var isLoading = false
    @Published var error: String?

    /// Whether the user needs to pick an AI provider (first time)
    @Published var showProviderPicker = false

    // MARK: - Active Service

    private var activeService: (any AIService)?
    private var currentContext: BirdContext?

    /// Game state for tool calling — set before starting a session
    var gameToolContext: GameToolContext?

    /// Current provider
    var currentProvider: AIProvider {
        GameSettings.shared.preferredAIProvider
    }

    // MARK: - Service Creation

    /// Create the appropriate AI service based on user preference
    private func createService(for provider: AIProvider) -> any AIService {
        switch provider {
        case .appleOnDevice:
            if #available(iOS 26.0, macOS 26.0, *), AppleAIService.isAvailable {
                return AppleAIService()
            } else {
                return MockAIService()
            }
        case .claudePremium:
            return ClaudeService()
        }
    }

    // MARK: - Session Management

    /// Start a chat session — shows picker first time, then activates service
    func startSession(context: BirdContext) {
        currentContext = context

        // First time? Show picker instead of chat
        if !GameSettings.shared.hasChosenAIProvider {
            showProviderPicker = true
            return
        }

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

        // Observe the service's state — poll since we can't use Combine across protocol
        observeService(service)
    }

    /// Forward messages from the active service
    private func observeService(_ service: any AIService) {
        // Use a timer to sync state from the active service
        // This is needed because @Published across protocol existentials
        // doesn't trigger SwiftUI updates automatically
        Task {
            while activeService != nil {
                if let svc = activeService {
                    self.messages = svc.messages
                    self.isLoading = svc.isLoading
                    self.error = svc.error
                }
                try? await Task.sleep(for: .milliseconds(100))
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
