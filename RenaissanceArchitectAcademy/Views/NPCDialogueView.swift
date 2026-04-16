import SwiftUI

/// NPC encounter content for the bottom dialog panel.
///
/// Shows a generated Renaissance craftsman: portrait, name/trade, typewriter greeting,
/// historical fact callout, and science tip callout. Designed to be placed inside
/// a `BottomDialogPanel` alongside `BirdGuidanceContent` — the panel switches
/// between bird and NPC content with a crossfade.
struct NPCDialogContent: View {
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
    private var settings: GameSettings { GameSettings.shared }

    private let charsPerTick = 2
    private let tickInterval: TimeInterval = 0.03

    /// Max height for scrollable content area
    private var contentMaxHeight: CGFloat {
        #if os(iOS)
        let screenHeight = UIScreen.main.bounds.height
        #else
        let screenHeight: CGFloat = 900
        #endif
        let panelMax: CGFloat = isLargeScreen ? 380 : screenHeight * 0.45
        // Subtract fixed chrome: header (~68) + divider (1) + button (~44) + padding (~20)
        return panelMax - 133
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header: Portrait + Name/Trade + Close
            HStack(alignment: .top, spacing: 12) {
                portraitView
                    .frame(width: 60, height: 60)

                VStack(alignment: .leading, spacing: 2) {
                    Text(npc.name)
                        .font(.custom("Cinzel-Bold", size: isLargeScreen ? 18 : 16))
                        .foregroundStyle(settings.cardTextColor)

                    Text(npc.trade)
                        .font(.custom("EBGaramond-Italic", size: isLargeScreen ? 14 : 13))
                        .foregroundStyle(RenaissanceColors.ochre)

                    Text("at the \(stationName)")
                        .font(.custom("EBGaramond-Regular", size: 11))
                        .foregroundStyle(settings.cardTextColor.opacity(0.5))
                }

                Spacer()

                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(settings.cardTextColor.opacity(0.4))
                        .padding(6)
                }
                .buttonStyle(.plain)
            }
            .padding(.bottom, 8)

            // Divider
            Rectangle()
                .fill(RenaissanceColors.ochre.opacity(0.3))
                .frame(height: 1)

            // Scrollable content: greeting + fact + tip
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 10) {
                    // Greeting (typewriter)
                    if showContent {
                        Text(revealedGreeting)
                            .font(.custom("EBGaramond-Regular", size: isLargeScreen ? 16 : 15))
                            .foregroundStyle(settings.cardTextColor.opacity(0.85))
                            .lineSpacing(4)
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
                }
                .padding(.top, 10)
            }
            .frame(maxHeight: contentMaxHeight)

            // Continue button
            if showDismiss {
                Button {
                    dismiss()
                } label: {
                    Text("Continue")
                        .font(.custom("EBGaramond-SemiBold", size: 15))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 8)
                        .parchmentButton(color: RenaissanceColors.renaissanceBlue)
                }
                .buttonStyle(.plain)
                .padding(.top, 8)
                .transition(.opacity)
            }
        }
        .onAppear { startReveal() }
        .onDisappear { stopTypewriter() }
        .contentShape(Rectangle())
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
            Circle()
                .fill(RenaissanceColors.parchment)
                .overlay(
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(RenaissanceColors.ochre.opacity(0.5))
                )
                .overlay(Circle().stroke(RenaissanceColors.ochre.opacity(0.3), lineWidth: 1.5))
        }
    }

    // MARK: - Callout Box

    private func calloutBox(icon: String, title: String, text: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(color)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.custom("Cinzel-Bold", size: 10))
                    .tracking(0.5)
                    .foregroundStyle(color)

                Text(text)
                    .font(.custom("EBGaramond-Regular", size: isLargeScreen ? 14 : 12))
                    .foregroundStyle(settings.cardTextColor.opacity(0.8))
                    .lineSpacing(2)
            }
        }
        .padding(10)
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
