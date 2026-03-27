import SwiftUI

/// Renaissance NPC encounter overlay — shows a generated craftsman at a workshop station.
///
/// Displays: portrait (generated sketch or placeholder), name + trade title,
/// greeting with typewriter animation, historical fact callout, science tip callout.
/// Matches the game's parchment aesthetic with Cinzel/EBGaramond fonts.
struct NPCDialogueView: View {
    let npc: NPCDisplayData
    var portrait: CGImage? = nil
    let stationName: String
    let onDismiss: () -> Void

    @State private var revealedCharCount = 0
    @State private var showContent = false
    @State private var showFact = false
    @State private var showTip = false
    @State private var showDismiss = false
    @State private var typewriterTimer: Timer?

    @Environment(\.horizontalSizeClass) private var sizeClass
    private var isLargeScreen: Bool { sizeClass == .regular }

    private let charsPerTick = 2
    private let tickInterval: TimeInterval = 0.03

    var body: some View {
        ZStack {
            // Dimming background
            RenaissanceColors.overlayDimming
                .ignoresSafeArea()
                .onTapGesture { dismiss() }

            // Parchment card
            VStack(spacing: 16) {
                // Portrait + Header
                HStack(spacing: 16) {
                    // Portrait circle
                    portraitView
                        .frame(width: 80, height: 80)

                    // Name + Trade
                    VStack(alignment: .leading, spacing: 4) {
                        Text(npc.name)
                            .font(.custom("Cinzel-Bold", size: isLargeScreen ? 22 : 18))
                            .foregroundStyle(RenaissanceColors.sepiaInk)

                        Text(npc.trade)
                            .font(.custom("EBGaramond-Italic", size: isLargeScreen ? 16 : 14))
                            .foregroundStyle(RenaissanceColors.ochre)

                        Text("at the \(stationName)")
                            .font(.custom("EBGaramond-Regular", size: 12))
                            .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.5))
                    }

                    Spacer()
                }

                // Divider
                Rectangle()
                    .fill(RenaissanceColors.ochre.opacity(0.3))
                    .frame(height: 1)

                // Greeting (typewriter)
                if showContent {
                    Text(revealedGreeting)
                        .font(.custom("EBGaramond-Regular", size: isLargeScreen ? 18 : 16))
                        .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.85))
                        .lineSpacing(5)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                // Historical Fact callout
                if showFact {
                    calloutBox(
                        icon: "scroll.fill",
                        title: "Historical Fact",
                        text: npc.historicalFact,
                        color: RenaissanceColors.ochre
                    )
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }

                // Science Tip callout
                if showTip {
                    calloutBox(
                        icon: "atom",
                        title: "Science Tip",
                        text: npc.scienceTip,
                        color: RenaissanceColors.renaissanceBlue
                    )
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }

                // Dismiss button
                if showDismiss {
                    Button {
                        dismiss()
                    } label: {
                        Text("Continue")
                            .font(.custom("EBGaramond-SemiBold", size: 16))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: CornerRadius.sm)
                                    .fill(RenaissanceColors.renaissanceBlue)
                            )
                    }
                    .buttonStyle(.plain)
                    .transition(.opacity)
                }
            }
            .padding(24)
            .frame(maxWidth: isLargeScreen ? 480 : .infinity)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.lg)
                    .fill(RenaissanceColors.parchment)
            )
            .borderModal(radius: CornerRadius.lg)
            .renaissanceShadow(.modal)
            .padding(.horizontal, isLargeScreen ? 0 : 16)
        }
        .onAppear { startReveal() }
        .onDisappear { stopTypewriter() }
        .onTapGesture {
            // Tap to skip typewriter
            if revealedCharCount < npc.greeting.count {
                stopTypewriter()
                revealedCharCount = npc.greeting.count
                showAllContent()
            }
        }
    }

    // MARK: - Portrait

    @ViewBuilder
    private var portraitView: some View {
        if let cgImage = portrait {
            Image(decorative: cgImage, scale: 1.0)
                .resizable()
                .scaledToFill()
                .clipShape(Circle())
                .overlay(Circle().stroke(RenaissanceColors.ochre.opacity(0.4), lineWidth: 2))
        } else {
            // Placeholder — parchment circle with craft icon
            Circle()
                .fill(RenaissanceColors.parchment)
                .overlay(
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(RenaissanceColors.ochre.opacity(0.5))
                )
                .overlay(Circle().stroke(RenaissanceColors.ochre.opacity(0.3), lineWidth: 1.5))
        }
    }

    // MARK: - Callout Box

    private func calloutBox(icon: String, title: String, text: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(color)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.custom("Cinzel-Bold", size: 11))
                    .tracking(0.5)
                    .foregroundStyle(color)

                Text(text)
                    .font(.custom("EBGaramond-Regular", size: isLargeScreen ? 15 : 13))
                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.8))
                    .lineSpacing(3)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.sm)
                .fill(color.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.sm)
                .stroke(color.opacity(0.15), lineWidth: 1)
        )
    }

    // MARK: - Typewriter

    private var revealedGreeting: String {
        let text = npc.greeting
        let endIndex = text.index(text.startIndex, offsetBy: min(revealedCharCount, text.count))
        return String(text[text.startIndex..<endIndex])
    }

    private func startReveal() {
        withAnimation(.easeOut(duration: 0.3)) {
            showContent = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            typewriterTimer = Timer.scheduledTimer(withTimeInterval: tickInterval, repeats: true) { timer in
                if revealedCharCount < npc.greeting.count {
                    revealedCharCount = min(revealedCharCount + charsPerTick, npc.greeting.count)
                } else {
                    timer.invalidate()
                    showAllContent()
                }
            }
        }
    }

    private func showAllContent() {
        withAnimation(.easeOut(duration: 0.3).delay(0.2)) {
            showFact = true
        }
        withAnimation(.easeOut(duration: 0.3).delay(0.5)) {
            showTip = true
        }
        withAnimation(.easeOut(duration: 0.3).delay(0.8)) {
            showDismiss = true
        }
    }

    private func stopTypewriter() {
        typewriterTimer?.invalidate()
        typewriterTimer = nil
    }

    private func dismiss() {
        SoundManager.shared.play(.tapSoft)
        stopTypewriter()
        onDismiss()
    }
}
