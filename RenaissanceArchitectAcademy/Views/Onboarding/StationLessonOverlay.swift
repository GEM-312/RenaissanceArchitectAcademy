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

    private let charsPerTick = 2
    private let tickInterval: TimeInterval = 0.03

    var body: some View {
        ZStack {
            // Dimmed backdrop
            Color.black.opacity(0.45)
                .ignoresSafeArea()
                .onTapGesture {
                    // Tap backdrop to skip text or dismiss
                    if revealedCharCount < lesson.text.count {
                        skipTypewriter()
                    }
                }

            // Lesson card
            VStack(spacing: 16) {
                // Bird + title
                HStack(spacing: 12) {
                    BirdCharacter(isSitting: true)
                        .frame(width: 80, height: 80)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(lesson.stationLabel)
                            .font(.custom("Mulish-Light", size: 14))
                            .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.6))

                        Text(lesson.title)
                            .font(.custom("Cinzel-Regular", size: 20))
                            .foregroundStyle(RenaissanceColors.sepiaInk)
                    }
                }

                DividerOrnament()
                    .frame(width: 160)

                // Typewriter text
                Text(revealedText)
                    .font(.custom("Mulish-Light", size: 17, relativeTo: .body))
                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.85))
                    .multilineTextAlignment(.leading)
                    .lineSpacing(5)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // Science badges
                HStack(spacing: 8) {
                    ForEach(lesson.sciences, id: \.self) { science in
                        HStack(spacing: 4) {
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
                                .font(.custom("Mulish-Light", size: 12))
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(RenaissanceColors.renaissanceBlue.opacity(0.1))
                        )
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                    }
                }

                // Continue button
                Button {
                    stopTypewriter()
                    onDismiss()
                } label: {
                    Text("Continue")
                        .font(.custom("Cinzel-Regular", size: 16))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(RenaissanceColors.renaissanceBlue)
                        )
                }
                .opacity(showButton ? 1 : 0)
            }
            .padding(24)
            .frame(maxWidth: 480)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(RenaissanceColors.parchment)
                    .shadow(color: .black.opacity(0.2), radius: 12, y: 4)
            )
            .padding(.horizontal, 32)
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
