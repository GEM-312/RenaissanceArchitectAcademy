import SwiftUI

/// Bird lesson modal shown before a player's first visit to a workshop station
/// Displays a historical narrative with science badges and typewriter text animation
struct StationLessonOverlay: View {
    let lesson: StationLesson
    var onDismiss: () -> Void

    @State private var showContent = false
    @State private var revealedCharCount = 0
    @State private var showButton = false
    @State private var typewriterTimer: Timer?
    private var settings: GameSettings { GameSettings.shared }

    private let charsPerTick = 2
    private let tickInterval: TimeInterval = 0.03

    var body: some View {
        ZStack {
            // Dimmed backdrop
            RenaissanceColors.overlayDimming
                .ignoresSafeArea()
                .onTapGesture {
                    // Tap backdrop to skip text or dismiss
                    if revealedCharCount < lesson.text.count {
                        skipTypewriter()
                    }
                }

            // Lesson card
            VStack(spacing: Spacing.md) {
                // Bird + title
                HStack(spacing: Spacing.sm) {
                    BirdCharacter(isSitting: true)
                        .frame(width: 80, height: 80)

                    VStack(alignment: .leading, spacing: Spacing.xxs) {
                        Text(lesson.stationLabel)
                            .font(RenaissanceFont.footnote)
                            .foregroundStyle(settings.cardTextColor.opacity(0.6))

                        Text(lesson.title)
                            .font(RenaissanceFont.dialogTitle)
                            .foregroundStyle(settings.cardTextColor)
                    }
                }

                DividerOrnament()
                    .frame(width: 160)

                // Typewriter text
                Text(revealedText)
                    .font(RenaissanceFont.body)
                    .foregroundStyle(settings.cardTextColor.opacity(0.85))
                    .multilineTextAlignment(.leading)
                    .lineSpacing(LineHeight.relaxed)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // Science badges
                HStack(spacing: Spacing.xs) {
                    ForEach(lesson.sciences, id: \.self) { science in
                        HStack(spacing: Spacing.xxs) {
                            if let imageName = science.customImageName {
                                Image(imageName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                            } else {
                                Image(systemName: science.sfSymbolName)
                                    .font(.caption2)
                            }
                            Text(science.rawValue)
                                .font(RenaissanceFont.footnoteSmall)
                        }
                        .padding(.horizontal, Spacing.xs)
                        .padding(.vertical, Spacing.xxs)
                        .background(
                            Capsule()
                                .fill(RenaissanceColors.renaissanceBlue.opacity(0.1))
                        )
                        .foregroundStyle(settings.cardTextColor)
                    }
                }

                // Continue button
                Button {
                    stopTypewriter()
                    onDismiss()
                } label: {
                    Text("Continue")
                        .font(RenaissanceFont.button)
                        .foregroundStyle(.white)
                        .padding(.horizontal, Spacing.xxl)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: CornerRadius.sm)
                                .fill(RenaissanceColors.renaissanceBlue)
                        )
                        .frame(minHeight: 44)
                        .contentShape(Rectangle())
                }
                .opacity(showButton ? 1 : 0)
            }
            .padding(Spacing.xl)
            .adaptiveWidth(480)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.lg)
                    .fill(settings.dialogBackground)
            )
            .padding(.horizontal, Spacing.xxl)
            .opacity(showContent ? 1 : 0)
            .scaleEffect(showContent ? 1 : 0.9)
        }
        .onAppear {
            withAnimation(.spring(response: 0.4)) {
                showContent = true
            }
            startTypewriter()
        }
        .onDisappear {
            stopTypewriter()
        }
    }

    // MARK: - Typewriter

    private var revealedText: String {
        let endIndex = lesson.text.index(lesson.text.startIndex, offsetBy: min(revealedCharCount, lesson.text.count))
        return String(lesson.text[lesson.text.startIndex..<endIndex])
    }

    private func startTypewriter() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            typewriterTimer = Timer.scheduledTimer(withTimeInterval: tickInterval, repeats: true) { timer in
                if revealedCharCount < lesson.text.count {
                    revealedCharCount = min(revealedCharCount + charsPerTick, lesson.text.count)
                } else {
                    timer.invalidate()
                    withAnimation(.easeOut(duration: 0.3)) {
                        showButton = true
                    }
                }
            }
        }
    }

    private func skipTypewriter() {
        stopTypewriter()
        revealedCharCount = lesson.text.count
        withAnimation(.easeOut(duration: 0.3)) {
            showButton = true
        }
    }

    private func stopTypewriter() {
        typewriterTimer?.invalidate()
        typewriterTimer = nil
    }
}
