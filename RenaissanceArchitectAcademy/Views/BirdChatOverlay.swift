import SwiftUI

/// Chat overlay for the bird companion — powered by Claude API.
/// Appears after a student reads a knowledge card and taps "Ask the Bird."
///
/// Usage:
/// ```swift
/// BirdChatOverlay(
///     card: someKnowledgeCard,
///     playerName: onboardingState.apprenticeName,
///     claudeService: claudeService,
///     onDismiss: { showBirdChat = false }
/// )
/// ```
struct BirdChatOverlay: View {
    let card: KnowledgeCard
    let playerName: String
    @ObservedObject var claudeService: ClaudeService
    let onDismiss: () -> Void

    @State private var inputText = ""
    @State private var showContent = false
    @FocusState private var isInputFocused: Bool

    /// Suggested questions based on card content
    private var suggestedQuestions: [String] {
        [
            "Why was this important?",
            "How does the \(card.science.rawValue.lowercased()) work here?",
            "Tell me something surprising!"
        ]
    }

    var body: some View {
        ZStack {
            // Dimmed background
            RenaissanceColors.overlayDimming
                .ignoresSafeArea()
                .onTapGesture { dismiss() }

            VStack(spacing: 0) {
                Spacer()

                // Chat panel
                VStack(spacing: 0) {
                    // Header
                    headerView

                    Divider()
                        .background(RenaissanceColors.ochre.opacity(0.3))

                    // Messages
                    messagesView

                    Divider()
                        .background(RenaissanceColors.ochre.opacity(0.3))

                    // Input or suggestions
                    inputView
                }
                .background(RenaissanceColors.parchment)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .borderModal(radius: 20)
                .shadow(color: .black.opacity(0.3), radius: 20, y: 8)
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
                .frame(maxHeight: 520)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 40)
            }
        }
        .onAppear {
            // Start the Claude session with card context
            claudeService.startSession(context: .init(
                buildingName: card.buildingName,
                buildingId: card.buildingId,
                sciences: [card.science.rawValue],
                cardTitle: card.title,
                cardLesson: card.lessonText,
                playerName: playerName,
                masteryLevel: "Apprentice"
            ))

            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                showContent = true
            }
        }
        .onDisappear {
            claudeService.endSession()
        }
    }

    // MARK: - Header

    private var headerView: some View {
        HStack(spacing: 12) {
            // Bird icon
            BirdCharacter(isSitting: true)
                .frame(width: 50, height: 50)

            VStack(alignment: .leading, spacing: 2) {
                Text("Ask the Bird")
                    .font(RenaissanceFont.cardTitle)
                    .tracking(Tracking.label)
                    .foregroundStyle(RenaissanceColors.ochre)

                Text(card.title)
                    .font(RenaissanceFont.captionSmall)
                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.6))
                    .lineLimit(1)
            }

            Spacer()

            // Message count
            let used = claudeService.messages.filter { $0.role == .user }.count
            let max = ClaudeService.maxMessagesPerSession
            Text("\(used)/\(max)")
                .font(RenaissanceFont.captionSmall)
                .foregroundStyle(RenaissanceColors.stoneGray)

            // Close button
            Button { dismiss() } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(RenaissanceColors.stoneGray)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - Messages

    private var messagesView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    // Welcome message (always shown)
                    birdBubble(
                        text: "I see you've been reading about \(card.title.lowercased())! What would you like to know?",
                        id: "welcome"
                    )

                    // Chat messages
                    ForEach(claudeService.messages) { message in
                        switch message.role {
                        case .user:
                            userBubble(text: message.content, id: message.id.uuidString)
                        case .assistant:
                            birdBubble(text: message.content, id: message.id.uuidString)
                        case .system:
                            EmptyView()
                        }
                    }

                    // Loading indicator
                    if claudeService.isLoading {
                        HStack(spacing: 6) {
                            TypingIndicator()
                            Text("Thinking...")
                                .font(RenaissanceFont.captionSmall)
                                .foregroundStyle(RenaissanceColors.stoneGray)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .id("loading")
                    }

                    // Error message
                    if let error = claudeService.error {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(RenaissanceColors.ochre)
                            Text(error)
                                .font(RenaissanceFont.captionSmall)
                                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(RenaissanceColors.ochre.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.vertical, 12)
            }
            .onChange(of: claudeService.messages.count) { _, _ in
                withAnimation {
                    if claudeService.isLoading {
                        proxy.scrollTo("loading", anchor: .bottom)
                    } else if let last = claudeService.messages.last {
                        proxy.scrollTo(last.id.uuidString, anchor: .bottom)
                    }
                }
            }
        }
        .frame(maxHeight: 300)
    }

    // MARK: - Message Bubbles

    private func birdBubble(text: String, id: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            // Small bird icon
            Image(systemName: "bird.fill")
                .font(.system(size: 14))
                .foregroundStyle(RenaissanceColors.ochre)
                .frame(width: 28, height: 28)
                .background(RenaissanceColors.ochre.opacity(0.12))
                .clipShape(Circle())

            Text(text)
                .font(RenaissanceFont.bodySmall)
                .foregroundStyle(RenaissanceColors.sepiaInk)
                .lineSpacing(LineHeight.normal)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(RenaissanceColors.parchmentLight)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .borderCard(radius: 12)

            Spacer(minLength: 40)
        }
        .padding(.horizontal, 16)
        .id(id)
    }

    private func userBubble(text: String, id: String) -> some View {
        HStack {
            Spacer(minLength: 60)

            Text(text)
                .font(RenaissanceFont.bodySmall)
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(RenaissanceColors.renaissanceBlue)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.horizontal, 16)
        .id(id)
    }

    // MARK: - Input Area

    private var inputView: some View {
        VStack(spacing: 8) {
            // Suggested questions (only when no messages yet)
            if claudeService.messages.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(suggestedQuestions, id: \.self) { question in
                            Button {
                                sendQuestion(question)
                            } label: {
                                Text(question)
                                    .font(RenaissanceFont.captionSmall)
                                    .foregroundStyle(RenaissanceColors.renaissanceBlue)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(RenaissanceColors.renaissanceBlue.opacity(0.1))
                                    .clipShape(Capsule())
                                    .overlay(
                                        Capsule()
                                            .stroke(RenaissanceColors.renaissanceBlue.opacity(0.25), lineWidth: 1)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }

            // Text input
            HStack(spacing: 10) {
                TextField("Ask a question...", text: $inputText, axis: .vertical)
                    .font(RenaissanceFont.bodySmall)
                    .foregroundStyle(RenaissanceColors.sepiaInk)
                    .lineLimit(1...3)
                    .focused($isInputFocused)
                    .textFieldStyle(.plain)
                    .onSubmit { sendCurrentInput() }

                // Send button
                Button { sendCurrentInput() } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(
                            inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || claudeService.isLoading
                            ? RenaissanceColors.stoneGray
                            : RenaissanceColors.renaissanceBlue
                        )
                }
                .buttonStyle(.plain)
                .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || claudeService.isLoading)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(RenaissanceColors.sepiaInk.opacity(0.04))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .padding(.horizontal, 12)
        }
        .padding(.vertical, 10)
    }

    // MARK: - Actions

    private func sendQuestion(_ text: String) {
        Task {
            await claudeService.sendMessage(text)
        }
    }

    private func sendCurrentInput() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        inputText = ""
        isInputFocused = false
        sendQuestion(text)
    }

    private func dismiss() {
        withAnimation(.easeOut(duration: 0.25)) {
            showContent = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            onDismiss()
        }
    }
}

// MARK: - Typing Indicator

/// Three-dot bouncing animation while the bird is "thinking"
private struct TypingIndicator: View {
    @State private var animating = false

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(RenaissanceColors.ochre)
                    .frame(width: 6, height: 6)
                    .offset(y: animating ? -4 : 0)
                    .animation(
                        .easeInOut(duration: 0.4)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.15),
                        value: animating
                    )
            }
        }
        .onAppear { animating = true }
    }
}

// MARK: - Preview

#Preview {
    BirdChatOverlay(
        card: KnowledgeCardContent.cards(for: "Pantheon").first!,
        playerName: "Marco",
        claudeService: ClaudeService(),
        onDismiss: {}
    )
}
