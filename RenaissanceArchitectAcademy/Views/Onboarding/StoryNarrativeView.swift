import SwiftUI
import AVFoundation

/// Reusable animated story page — typewriter text reveal with optional BirdCharacter
struct StoryNarrativeView: View {
    let page: StoryPage
    /// Apprentice's name from onboarding. Pages with `{name}` tokens substitute
    /// this in at render time. Falls back to "apprentice" if empty.
    var apprenticeName: String = ""
    var onContinue: () -> Void

    /// Apprentice name with fallback for substitution.
    private var nameValue: String {
        apprenticeName.isEmpty ? "apprentice" : apprenticeName
    }

    /// Substitutes `{name}` tokens in the given source string.
    private func substitute(_ source: String) -> String {
        source.replacingOccurrences(of: "{name}", with: nameValue)
    }

    /// The full attributed text for this page, with per-section font runs:
    /// intro (default body) → letter (PetitFormalScript) → outro (default body).
    /// Pages without `letterText` collapse to a single body run.
    private var fullAttributedText: AttributedString {
        var result = AttributedString()

        var intro = AttributedString(substitute(page.text))
        intro.font = RenaissanceFont.bodyLarge
        result += intro

        if let letter = page.letterText {
            var letterAttr = AttributedString("\n\n" + substitute(letter))
            letterAttr.font = .custom("PetitFormalScript-Regular", size: 22)
            result += letterAttr
        }

        if let outro = page.outroText {
            var outroAttr = AttributedString("\n\n" + substitute(outro))
            outroAttr.font = RenaissanceFont.bodyLarge
            result += outroAttr
        }

        return result
    }

    /// Total character count across all sections — drives the typewriter timer.
    private var totalCharCount: Int {
        fullAttributedText.characters.count
    }

    /// Typewriter-truncated attributed text. Preserves font runs across the slice.
    private var revealedAttributedText: AttributedString {
        let full = fullAttributedText
        let n = min(revealedCharCount, full.characters.count)
        guard n > 0 else { return AttributedString("") }
        let endIndex = full.characters.index(full.characters.startIndex, offsetBy: n)
        return AttributedString(full[full.characters.startIndex..<endIndex])
    }

    @State private var showTitle = false
    @State private var revealedCharCount = 0
    @State private var showBird = false
    @State private var showButton = false
    @State private var typewriterTimer: Timer?
    @State private var audioPlayer: AVAudioPlayer?

    // Animated background frames — count + duration come from the page
    @State private var bgFrame: Int = 0
    @State private var bgTimer: Timer?

    // The Continue button only appears once typewriter, audio narration, and
    // frame animation are all done — otherwise the player can advance past a
    // cinematic that is still mid-flight.
    @State private var typewriterDone = false
    @State private var audioDone = true
    @State private var animationDone = true

    private let charsPerTick = 2
    private let tickInterval: TimeInterval = 0.03

    @Environment(\.horizontalSizeClass) private var sizeClass
    private var isLargeScreen: Bool { sizeClass == .regular }

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
            } else if let bgImage = page.backgroundImage {
                // Static background image (e.g. parchment letter for The Invitation)
                Image(bgImage)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            } else {
                RenaissanceColors.parchment
                    .ignoresSafeArea()
            }

            DecorativeCorners()

            // Title + divider + body text. Wrapped in a ScrollView so long
            // pages (e.g. The Invitation, with intro + handwritten letter +
            // outro) don't push the Continue button off-screen on shorter
            // viewports.
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    Spacer(minLength: 60)

                    // Title
                    Text(page.title)
                        .font(.custom("Cinzel-Regular", size: isLargeScreen ? 36 : 26))
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                        .opacity(showTitle ? 1 : 0)
                        .offset(y: showTitle ? 0 : -15)

                    DividerOrnament()
                        .frame(width: 180)
                        .opacity(showTitle ? 1 : 0)

                    // Typewriter text — uses AttributedString so different sections
                    // can render in different fonts (narrator body vs. handwritten letter).
                    Text(revealedAttributedText)
                        .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                        .adaptiveWidth(520)

                    // Bird companion (only on final story page)
                    if page.showBird && showBird {
                        BirdCharacter(isSitting: false)
                            .frame(width: 180, height: 180)
                    }

                    // Reserve space at the bottom so the last line of text
                    // never sits under the pinned Continue button.
                    Spacer(minLength: 140)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 32)
            }

            // Continue button — pinned to the bottom of the ZStack so it's
            // always visible regardless of content height. Hidden until all
            // cinematic gates (typewriter + audio + animation) finish.
            VStack {
                Spacer()
                Button {
                    stopTypewriter()
                    audioPlayer?.stop()
                    bgTimer?.invalidate()
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
        }
        .onAppear {
            startReveal()
            startBackgroundAnimation()
            startNarration()
        }
        .onDisappear {
            stopTypewriter()
            bgTimer?.invalidate()
            bgTimer = nil
            audioPlayer?.stop()
            audioPlayer = nil
        }
        // Tap to skip — fast-forwards typewriter, audio, and frame animation,
        // then shows the Continue button immediately.
        .onTapGesture {
            skipToEnd()
        }
    }

    /// Marks all gates done and reveals the Continue button. Stops audio + animation.
    private func skipToEnd() {
        if revealedCharCount < totalCharCount {
            stopTypewriter()
            revealedCharCount = totalCharCount
        }
        audioPlayer?.stop()
        audioPlayer = nil
        bgTimer?.invalidate()
        bgTimer = nil
        bgFrame = max(page.backgroundFrameCount - 1, 0)
        typewriterDone = true
        audioDone = true
        animationDone = true
        showContinueIfReady()
    }

    // MARK: - Typewriter Logic

    private func startReveal() {
        withAnimation(.easeOut(duration: 0.6)) {
            showTitle = true
        }

        // Start typewriter after title animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            let total = totalCharCount
            typewriterTimer = Timer.scheduledTimer(withTimeInterval: tickInterval, repeats: true) { timer in
                if revealedCharCount < total {
                    revealedCharCount = min(revealedCharCount + charsPerTick, total)
                } else {
                    timer.invalidate()
                    typewriterDone = true
                    showContinueIfReady()
                }
            }
        }
    }

    /// Reveals the Continue button (and bird, if applicable) — but only when
    /// every cinematic gate has finished: typewriter text, audio narration,
    /// and the bg frame animation. Each of those calls this when it's done.
    private func showContinueIfReady() {
        guard typewriterDone, audioDone, animationDone else { return }
        guard !showButton else { return }
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

    private func startNarration() {
        guard let name = page.audioName else { return }
        // Look up .mp3 first, then .m4a — supports either format depending on
        // how the narration was exported (ElevenLabs / OpenArt → mp3,
        // GarageBand / iOS recordings → m4a).
        let url = Bundle.main.url(forResource: name, withExtension: "mp3")
            ?? Bundle.main.url(forResource: name, withExtension: "m4a")
        guard let url else { return }
        guard let player = try? AVAudioPlayer(contentsOf: url) else { return }
        audioPlayer = player
        audioDone = false
        player.play()
        // Reveal the Continue button once the audio's duration has elapsed.
        // The exact moment of `player.isPlaying == false` is harder to observe
        // without a delegate; the duration-based timer is good enough for
        // narration files where the runtime is known and fixed.
        DispatchQueue.main.asyncAfter(deadline: .now() + player.duration) {
            audioDone = true
            showContinueIfReady()
        }
    }

    private func startBackgroundAnimation() {
        guard page.backgroundFramePrefix != nil else { return }
        let frameCount = page.backgroundFrameCount
        let interval = page.backgroundFrameDuration / Double(max(frameCount - 1, 1))
        animationDone = false
        bgTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            if bgFrame < frameCount - 1 {
                bgFrame += 1
            } else {
                timer.invalidate()
                bgTimer = nil
                animationDone = true
                showContinueIfReady()
            }
        }
    }
}
