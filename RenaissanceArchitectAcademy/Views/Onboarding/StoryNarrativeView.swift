import SwiftUI

/// Reusable animated story page — typewriter text reveal with optional BirdCharacter
struct StoryNarrativeView: View {
    let page: StoryPage
    /// Optional dynamic text override (e.g., generated Medici commission).
    /// When set, replaces page.text. Typewriter animation works identically.
    var dynamicTextOverride: String? = nil
    /// Optional generated background scene (e.g., Medici at his desk writing).
    /// Replaces backgroundFramePrefix when available. Fades in behind text.
    var dynamicSceneImage: CGImage? = nil
    /// Optional generated inline image (e.g., sealed letter with Medici crest).
    /// Displayed between title and typewriter text.
    var dynamicLetterImage: CGImage? = nil
    var onContinue: () -> Void

    /// The text to display — dynamic override if available, otherwise static page text
    private var displayText: String { dynamicTextOverride ?? page.text }

    @State private var showTitle = false
    @State private var revealedCharCount = 0
    @State private var showBird = false
    @State private var showButton = false
    @State private var typewriterTimer: Timer?
    @State private var showLetterImage = false

    // Animated background frames
    @State private var bgFrame: Int = 0
    @State private var bgTimer: Timer?
    private let bgFrameCount = 15
    private let bgFPS: Double = 10

    private let charsPerTick = 2
    private let tickInterval: TimeInterval = 0.03

    @Environment(\.horizontalSizeClass) private var sizeClass
    private var isLargeScreen: Bool { sizeClass == .regular }

    var body: some View {
        ZStack {
            // Background layer: generated scene image OR animated frames OR plain parchment
            if let sceneImage = dynamicSceneImage {
                // Generated scene (e.g., Medici writing at his desk)
                Image(decorative: sceneImage, scale: 1.0)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .opacity(0.4)

                // Parchment overlay for readability
                RenaissanceColors.parchment
                    .opacity(0.6)
                    .ignoresSafeArea()
            } else if let prefix = page.backgroundFramePrefix {
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
                    .font(.custom("Cinzel-Regular", size: isLargeScreen ? 36 : 26))
                    .foregroundStyle(RenaissanceColors.sepiaInk)
                    .opacity(showTitle ? 1 : 0)
                    .offset(y: showTitle ? 0 : -15)

                DividerOrnament()
                    .frame(width: 180)
                    .opacity(showTitle ? 1 : 0)

                // Generated letter image with vignette fade — can arrive late, fades in
                if let letterImage = dynamicLetterImage {
                    Image(decorative: letterImage, scale: 1.0)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: isLargeScreen ? 280 : 200, maxHeight: isLargeScreen ? 200 : 150)
                        .mask(
                            // Radial vignette — center is opaque, edges fade to transparent
                            RadialGradient(
                                gradient: Gradient(colors: [.white, .white, .white.opacity(0)]),
                                center: .center,
                                startRadius: isLargeScreen ? 60 : 40,
                                endRadius: isLargeScreen ? 150 : 110
                            )
                        )
                        .shadow(color: RenaissanceColors.ochre.opacity(0.2), radius: 12, y: 2)
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                }

                // Typewriter text
                Text(revealedText)
                    .font(.custom("EBGaramond-Regular", size: 19))
                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .adaptiveWidth(520)
                    .padding(.horizontal, 24)

                // Bird companion (only on final story page)
                // Conditionally inserted when showBird=true so BirdCharacter's
                // onAppear fly-in animation plays at the right moment.
                if page.showBird && showBird {
                    BirdCharacter(isSitting: false)
                        .frame(width: 180, height: 180)
                        .transition(.opacity)
                }

                Spacer()

                // Continue button
                Button {
                    stopTypewriter()
                    onContinue()
                } label: {
                    Text("Continue")
                        .font(.custom("EBGaramond-SemiBold", size: 20))
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
            if revealedCharCount < displayText.count {
                stopTypewriter()
                revealedCharCount = displayText.count
                finishReveal()
            }
        }
    }

    // MARK: - Typewriter Logic

    private var revealedText: String {
        let text = displayText
        let endIndex = text.index(text.startIndex, offsetBy: min(revealedCharCount, text.count))
        return String(text[text.startIndex..<endIndex])
    }

    private func startReveal() {
        withAnimation(.easeOut(duration: 0.6)) {
            showTitle = true
        }

        // Reveal letter image shortly after title
        if dynamicLetterImage != nil {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.75).delay(0.4)) {
                showLetterImage = true
            }
        }

        // Start typewriter after title + letter animation
        DispatchQueue.main.asyncAfter(deadline: .now() + (dynamicLetterImage != nil ? 1.0 : 0.7)) {
            typewriterTimer = Timer.scheduledTimer(withTimeInterval: tickInterval, repeats: true) { timer in
                if revealedCharCount < displayText.count {
                    revealedCharCount = min(revealedCharCount + charsPerTick, displayText.count)
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
