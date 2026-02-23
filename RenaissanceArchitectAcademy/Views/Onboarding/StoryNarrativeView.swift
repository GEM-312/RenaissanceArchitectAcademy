import SwiftUI

/// Reusable animated story page — typewriter text reveal with optional BirdCharacter
struct StoryNarrativeView: View {
    let page: StoryPage
    var onContinue: () -> Void

    @State private var showTitle = false
    @State private var revealedCharCount = 0
    @State private var showBird = false
    @State private var showButton = false
    @State private var typewriterTimer: Timer?

    // Animated background frames
    @State private var bgFrame: Int = 0
    @State private var bgTimer: Timer?
    private let bgFrameCount = 15
    private let bgFPS: Double = 10

    private let charsPerTick = 2
    private let tickInterval: TimeInterval = 0.03

    var body: some View {
        ZStack {
            if let prefix = page.backgroundFramePrefix {
                // Animated background frames (looping)
                Image(String(format: "%@%02d", prefix, bgFrame))
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .opacity(0.45)

                // Darkened overlay so text stays readable
                RenaissanceColors.parchment
                    .opacity(0.55)
                    .ignoresSafeArea()
            } else {
                RenaissanceColors.parchment
                    .ignoresSafeArea()
            }

            DecorativeCorners()

            VStack(spacing: 24) {
                Spacer()

                // Title
                Text(page.title)
                    .font(.custom("Cinzel-Regular", size: 36))
                    .foregroundStyle(RenaissanceColors.sepiaInk)
                    .opacity(showTitle ? 1 : 0)
                    .offset(y: showTitle ? 0 : -15)

                DividerOrnament()
                    .frame(width: 180)
                    .opacity(showTitle ? 1 : 0)

                // Typewriter text
                Text(revealedText)
                    .font(.custom("Mulish-Light", size: 19))
                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .frame(maxWidth: 520)
                    .padding(.horizontal, 24)

                // Bird companion (only on final story page)
                if page.showBird {
                    BirdCharacter()
                        .frame(width: 180, height: 180)
                        .opacity(showBird ? 1 : 0)
                        .scaleEffect(showBird ? 1 : 0.5)
                        .offset(y: showBird ? 0 : 30)
                }

                Spacer()

                // Continue button
                Button {
                    stopTypewriter()
                    onContinue()
                } label: {
                    Text("Continue")
                        .font(.custom("Cinzel-Regular", size: 18))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(RenaissanceColors.renaissanceBlue)
                        )
                }
                .opacity(showButton ? 1 : 0)
                .offset(y: showButton ? 0 : 15)
                .padding(.bottom, 40)
            }
            .padding(.horizontal, 32)
        }
        .onAppear {
            startReveal()
            startBackgroundAnimation()
        }
        .onDisappear {
            stopTypewriter()
            bgTimer?.invalidate()
            bgTimer = nil
        }
        // Tap to skip typewriter and reveal all text
        .onTapGesture {
            if revealedCharCount < page.text.count {
                stopTypewriter()
                revealedCharCount = page.text.count
                finishReveal()
            }
        }
    }

    // MARK: - Typewriter Logic

    private var revealedText: String {
        let endIndex = page.text.index(page.text.startIndex, offsetBy: min(revealedCharCount, page.text.count))
        return String(page.text[page.text.startIndex..<endIndex])
    }

    private func startReveal() {
        withAnimation(.easeOut(duration: 0.6)) {
            showTitle = true
        }

        // Start typewriter after title animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            typewriterTimer = Timer.scheduledTimer(withTimeInterval: tickInterval, repeats: true) { timer in
                if revealedCharCount < page.text.count {
                    revealedCharCount = min(revealedCharCount + charsPerTick, page.text.count)
                } else {
                    timer.invalidate()
                    finishReveal()
                }
            }
        }
    }

    private func finishReveal() {
        if page.showBird {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                showBird = true
            }
            withAnimation(.easeOut(duration: 0.4).delay(0.5)) {
                showButton = true
            }
        } else {
            withAnimation(.easeOut(duration: 0.4).delay(0.3)) {
                showButton = true
            }
        }
    }

    private func stopTypewriter() {
        typewriterTimer?.invalidate()
        typewriterTimer = nil
    }

    private func startBackgroundAnimation() {
        guard page.backgroundFramePrefix != nil else { return }
        bgTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / bgFPS, repeats: true) { timer in
            if bgFrame < bgFrameCount - 1 {
                bgFrame += 1
            } else {
                timer.invalidate()
                bgTimer = nil
            }
        }
    }
}
