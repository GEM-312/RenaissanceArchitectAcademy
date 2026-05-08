import SwiftUI
import AVFoundation

/// Reusable animated story page — typewriter text reveal with optional BirdCharacter
struct StoryNarrativeView: View {
    let page: StoryPage
    /// Apprentice's name from onboarding. Pages with `{name}` tokens substitute
    /// this in at render time. Falls back to "apprentice" if empty.
    var apprenticeName: String = ""
    /// Apprentice's gender from onboarding. Pages with `{gender}` tokens in
    /// any string field (backgroundFramePrefix, audioName, backgroundImage)
    /// substitute "Boy" or "Girl" at render time. Lets a single page support
    /// gender-specific assets — e.g. `"{gender}CatchingLetterFrame"` resolves
    /// to `BoyCatchingLetterFrame` or `GirlCatchingLetterFrame`.
    var apprenticeGender: ApprenticeGender = .boy
    var onContinue: () -> Void

    /// Apprentice name with fallback for substitution.
    private var nameValue: String {
        apprenticeName.isEmpty ? "apprentice" : apprenticeName
    }

    /// Capitalized gender token used in asset name substitutions.
    private var genderToken: String {
        apprenticeGender == .girl ? "Girl" : "Boy"
    }

    /// Substitutes `{name}` tokens in the given source string.
    private func substitute(_ source: String) -> String {
        source.replacingOccurrences(of: "{name}", with: nameValue)
    }

    /// Substitutes `{gender}` tokens in asset-name strings. Used for
    /// gender-specific lookups in backgroundFramePrefix, audioName, etc.
    private func substituteGender(_ source: String) -> String {
        source.replacingOccurrences(of: "{gender}", with: genderToken)
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
            letterAttr.font = RenaissanceFont.letter
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

    /// Page asset names with `{gender}` resolved to the apprentice's choice.
    /// Returns nil if the page doesn't define that asset.
    private var resolvedFramePrefix: String? {
        page.backgroundFramePrefix.map(substituteGender)
    }

    private var resolvedBackgroundImage: String? {
        page.backgroundImage.map(substituteGender)
    }

    private var resolvedAudioName: String? {
        page.audioName.map(substituteGender)
    }

    /// Frame count for the animation, honoring per-gender variants when set.
    private var resolvedFrameCount: Int {
        page.backgroundFrameVariants[apprenticeGender]?.count ?? page.backgroundFrameCount
    }

    /// Frame animation duration in seconds, honoring per-gender variants when set.
    private var resolvedFrameDuration: Double {
        page.backgroundFrameVariants[apprenticeGender]?.duration ?? page.backgroundFrameDuration
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
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    private var isLargeScreen: Bool { sizeClass == .regular }
    /// BirdCharacter size — shrinks on compact vertical (iPhone landscape) so
    /// it doesn't crowd Page 4's body text. Audit 2026-05-07.
    private var birdSize: CGFloat {
        verticalSizeClass == .compact ? 120 : 180
    }

    var body: some View {
        // Top-level VStack — title at top, body in scrollable middle,
        // Continue at bottom via safeAreaInset. Background goes into
        // `.background` so it can ignoreSafeArea independently of the
        // foreground content. ZStack-as-root caused inconsistent sizing
        // when sibling backgrounds with `.ignoresSafeArea()` interacted
        // with the foreground VStack — title would render above the
        // visible safe area in iPad landscape on short-body pages.
        VStack(spacing: Spacing.xl) {
            Text(page.title)
                .font(.custom("Cinzel-Regular", size: isLargeScreen ? 36 : 26))
                .foregroundStyle(RenaissanceColors.sepiaInk)
                .multilineTextAlignment(.center)
                .opacity(showTitle ? 1 : 0)

            DividerOrnament()
                .frame(width: 180)
                .opacity(showTitle ? 1 : 0)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: Spacing.xl) {
                    Text(revealedAttributedText)
                        .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                        .adaptiveWidth(520)

                    if page.showBird && showBird {
                        BirdCharacter(isSitting: false)
                            .frame(width: birdSize, height: birdSize)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.sm)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(.top, Spacing.xxl)
        .padding(.horizontal, Spacing.xxl)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background {
            // Background fills entire screen including safe area. Lives
            // in `.background` so it cannot push or shift the foreground.
            Group {
                if let prefix = resolvedFramePrefix, assetExists(named: "\(prefix)00") {
                    // Parchment is the full-screen base. The animated frame
                    // sits anchored to the BOTTOM of the screen at ~67% of
                    // its previous full-fill size and reduced opacity, so
                    // the typewriter text up top reads on a clean parchment
                    // and the figure tucks beneath it. Tuneables:
                    //   videoMaxSize  — bump to 800 for a bigger figure, drop to 540 for smaller
                    //   videoOpacity  — bump to 0.40 for more presence, drop to 0.20 to fade
                    ZStack(alignment: .bottom) {
                        RenaissanceColors.parchment
                        Image(String(format: "%@%02d", prefix, bgFrame))
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 680, maxHeight: 680)
                            .opacity(0.30)
                    }
                } else if let bgImage = resolvedBackgroundImage, assetExists(named: bgImage) {
                    Image(bgImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    RenaissanceColors.parchment
                }
            }
            .ignoresSafeArea()
        }
        .overlay {
            DecorativeCorners()
                .allowsHitTesting(false)
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                stopTypewriter()
                audioPlayer?.stop()
                bgTimer?.invalidate()
                onContinue()
            } label: {
                Text("Continue")
                    .font(.custom("EBGaramond-SemiBold", size: 20))
                    .foregroundStyle(.white)
                    .padding(.horizontal, Spacing.xxxl)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(RenaissanceColors.renaissanceBlue)
                    )
            }
            .opacity(showButton ? 1 : 0)
            .padding(.bottom, Spacing.xl)
            .allowsHitTesting(showButton)
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
        guard let name = resolvedAudioName else { return }
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

    /// Returns true if the named asset is present in the bundle. Prevents
    /// rendering empty placeholder images that can break parent layout.
    private func assetExists(named name: String) -> Bool {
        #if os(iOS)
        return UIImage(named: name) != nil
        #else
        return NSImage(named: name) != nil
        #endif
    }

    private func startBackgroundAnimation() {
        // Skip if the page doesn't declare an animation OR if the resolved
        // first frame isn't in the bundle (e.g. girl assets not generated yet
        // for a `{gender}`-templated page). animationDone stays true so the
        // Continue gate doesn't wait on an animation that will never play.
        guard let prefix = resolvedFramePrefix,
              assetExists(named: "\(prefix)00") else { return }
        let frameCount = resolvedFrameCount
        let interval = resolvedFrameDuration / Double(max(frameCount - 1, 1))
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
