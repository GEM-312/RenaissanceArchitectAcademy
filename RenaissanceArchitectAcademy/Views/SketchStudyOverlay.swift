import SwiftUI

/// "Study the Masters" overlay — shows a real Met Museum architectural sketch
/// with an interactive study activity from the bird companion.
/// Two question types:
///   .find  — tap on the image to locate a feature, "I found it!" checks position
///   .count — study the image and enter a number, "I found it!" checks the count
/// 3 wrong checks → hint appears automatically.
struct SketchStudyOverlay: View {
    let sketch: MuseumSketch
    let onDismiss: () -> Void
    let onComplete: (Int) -> Void  // florins earned

    var sketchService = MuseumSketchService.shared

    // Shared state
    @State private var wrongAttempts = 0
    @State private var showHint = false
    @State private var foundFeature = false
    @State private var showWrongFlash = false
    @State private var appearAnimation = false

    // Find mode state
    @State private var tapPosition: CGPoint? = nil

    // Count mode state
    @State private var countInput: String = ""

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    private var isLargeScreen: Bool { horizontalSizeClass == .regular }

    private let florinsReward = GameRewards.sketchStudyFlorins  // 3

    private var isCountMode: Bool {
        if case .count = sketch.questionType { return true }
        return false
    }

    private var isReflectMode: Bool {
        if case .reflect = sketch.questionType { return true }
        return false
    }

    private var correctCount: Int? {
        if case .count(let n) = sketch.questionType { return n }
        return nil
    }

    /// Whether the "I found it!" button should be enabled
    private var canCheck: Bool {
        if isCountMode {
            return !countInput.isEmpty && Int(countInput) != nil
        } else {
            return tapPosition != nil
        }
    }

    var body: some View {
        ZStack {
            // Dimmed background
            RenaissanceColors.overlayDimming
                .ignoresSafeArea()
                .onTapGesture { /* block dismiss on background tap */ }

            // Main card — width adapts to image aspect ratio
            GeometryReader { geo in
                let maxCardWidth = geo.size.width * (isLargeScreen ? 0.90 : 0.96)
                let cardHeight = geo.size.height * (isLargeScreen ? 0.90 : 0.96)
                let imageHeight = cardHeight * 0.58
                // If image is loaded, size card to match its aspect ratio
                let imageAspect = sketchService.aspectRatios[sketch.id] ?? 1.2
                let imageWidth = imageHeight * imageAspect
                // Card width = image width + padding, clamped to max
                let cardWidth = min(maxCardWidth, max(imageWidth + 32, maxCardWidth * 0.5))

                VStack(spacing: 0) {
                    headerBar

                    sketchImageSection(height: imageHeight)

                    studyPromptSection

                    if isCountMode {
                        countInputSection
                    }

                    actionButtons

                    Spacer(minLength: 0)
                }
                .frame(width: cardWidth, height: cardHeight)
                .background(RenaissanceColors.parchment)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
                .borderModal(radius: CornerRadius.lg)
                .renaissanceShadow(.modal)
                .position(x: geo.size.width / 2, y: geo.size.height / 2)
                .scaleEffect(appearAnimation ? 1.0 : 0.9)
                .opacity(appearAnimation ? 1.0 : 0)
            }
        }
        .onAppear {
            Task { await sketchService.loadImage(for: sketch) }
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                appearAnimation = true
            }
        }
    }

    // MARK: - Header

    private var headerBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Study the Masters")
                    .font(RenaissanceFont.cardTitle)
                    .foregroundStyle(RenaissanceColors.sepiaInk)

                Text(sketch.artist + ", " + sketch.date)
                    .font(RenaissanceFont.italicSmall)
                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(TextEmphasis.tertiary))
            }

            Spacer()

            MediumBadge(medium: sketch.medium)

            Button {
                onDismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(TextEmphasis.faint))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.top, Spacing.sm)
        .padding(.bottom, Spacing.xs)
    }

    // MARK: - Interactive Sketch Image

    private func sketchImageSection(height: CGFloat) -> some View {
        VStack(spacing: Spacing.xxs) {
            ZStack {
                // Paper texture background
                RoundedRectangle(cornerRadius: CornerRadius.sm)
                    .fill(RenaissanceColors.sepiaInk.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.sm)
                            .stroke(RenaissanceColors.sepiaInk.opacity(0.15), lineWidth: 1)
                    )

                if let cachedImage = sketchService.imageCache[sketch.id] {
                    if isCountMode || isReflectMode {
                        // Count/reflect mode — just show the image, no tap interaction
                        cachedImage
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    } else {
                        // Find mode — interactive tappable image
                        GeometryReader { geo in
                            ZStack {
                                cachedImage
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .clipShape(RoundedRectangle(cornerRadius: 6))

                                // Player's tap marker (blue pin)
                                if let pos = tapPosition, !foundFeature {
                                    Circle()
                                        .fill(RenaissanceColors.renaissanceBlue.opacity(0.3))
                                        .frame(width: 44, height: 44)
                                        .overlay(
                                            Circle()
                                                .stroke(RenaissanceColors.renaissanceBlue, lineWidth: 2.5)
                                        )
                                        .position(
                                            x: pos.x * geo.size.width,
                                            y: pos.y * geo.size.height
                                        )
                                        .transition(.scale.combined(with: .opacity))
                                }

                                // Wrong flash — red ring
                                if showWrongFlash, let pos = tapPosition {
                                    Circle()
                                        .stroke(RenaissanceColors.errorRed.opacity(0.7), lineWidth: 3)
                                        .frame(width: 50, height: 50)
                                        .position(
                                            x: pos.x * geo.size.width,
                                            y: pos.y * geo.size.height
                                        )
                                        .transition(.scale.combined(with: .opacity))
                                }

                                // Correct — green ring + checkmark at target
                                if foundFeature {
                                    Circle()
                                        .stroke(RenaissanceColors.sageGreen, lineWidth: 3)
                                        .frame(width: 56, height: 56)
                                        .position(
                                            x: sketch.tapTarget.x * geo.size.width,
                                            y: sketch.tapTarget.y * geo.size.height
                                        )
                                        .transition(.scale.combined(with: .opacity))

                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundStyle(RenaissanceColors.sageGreen)
                                        .position(
                                            x: sketch.tapTarget.x * geo.size.width,
                                            y: sketch.tapTarget.y * geo.size.height
                                        )
                                        .transition(.scale)
                                }

                                // Hint pulse — after 3 wrong
                                if showHint && !foundFeature {
                                    Circle()
                                        .stroke(RenaissanceColors.ochre.opacity(0.5), lineWidth: 2)
                                        .frame(width: 70, height: 70)
                                        .position(
                                            x: sketch.tapTarget.x * geo.size.width,
                                            y: sketch.tapTarget.y * geo.size.height
                                        )
                                        .modifier(PulseModifier())
                                }

                                // Tap gesture (disabled after correct)
                                if !foundFeature {
                                    Color.clear
                                        .contentShape(Rectangle())
                                        .onTapGesture { location in
                                            let normalized = CGPoint(
                                                x: location.x / geo.size.width,
                                                y: location.y / geo.size.height
                                            )
                                            withAnimation(.easeOut(duration: 0.2)) {
                                                tapPosition = normalized
                                            }
                                        }
                                }
                            }
                        }
                    }
                } else if sketchService.loadingIDs.contains(sketch.id) {
                    VStack(spacing: Spacing.sm) {
                        ProgressView()
                            .tint(RenaissanceColors.warmBrown)
                        Text("Loading sketch from the Metropolitan Museum...")
                            .font(RenaissanceFont.italicSmall)
                            .foregroundStyle(RenaissanceColors.sepiaInk.opacity(TextEmphasis.tertiary))
                    }
                } else {
                    VStack(spacing: Spacing.xs) {
                        Image(systemName: "photo.artframe")
                            .font(.system(size: 40))
                            .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.2))
                        Text(sketch.title)
                            .font(RenaissanceFont.caption)
                            .foregroundStyle(RenaissanceColors.sepiaInk.opacity(TextEmphasis.faint))
                            .multilineTextAlignment(.center)
                    }
                }
            }
            .frame(height: height)
            .padding(.horizontal, Spacing.md)

            // Title caption
            Text(sketch.title)
                .font(RenaissanceFont.caption)
                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(TextEmphasis.tertiary))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .padding(.horizontal, Spacing.lg)
        }
    }

    // MARK: - Study Prompt (Bird)

    private var studyPromptSection: some View {
        VStack(spacing: Spacing.xs) {
            HStack(alignment: .top, spacing: Spacing.xs) {
                Image("BirdFrame00")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 36, height: 36)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(RenaissanceColors.ochre.opacity(0.3), lineWidth: 1))

                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(sketch.studyPrompt)
                        .font(RenaissanceFont.bodySmall)
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                        .fixedSize(horizontal: false, vertical: true)

                    // Instructions (only before answer found)
                    if !foundFeature && !showWrongFlash {
                        if isReflectMode {
                            Text("Study the sketch, then reveal the answer")
                                .font(RenaissanceFont.italicSmall)
                                .foregroundStyle(RenaissanceColors.renaissanceBlue.opacity(0.7))
                                .transition(.opacity)
                        } else if isCountMode {
                            if countInput.isEmpty {
                                Text("Study the sketch, count carefully, then enter your answer below")
                                    .font(RenaissanceFont.italicSmall)
                                    .foregroundStyle(RenaissanceColors.renaissanceBlue.opacity(0.7))
                                    .transition(.opacity)
                            }
                        } else {
                            if tapPosition == nil {
                                Text("Tap on the sketch to mark where you think it is")
                                    .font(RenaissanceFont.italicSmall)
                                    .foregroundStyle(RenaissanceColors.renaissanceBlue.opacity(0.7))
                                    .transition(.opacity)
                            }
                        }
                    }

                    // Wrong attempt feedback
                    if showWrongFlash {
                        Text(isCountMode ? "Not quite — look again and recount!" : "Not quite — try tapping a different spot!")
                            .font(RenaissanceFont.italicSmall)
                            .foregroundStyle(RenaissanceColors.errorRed)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    // Hint after 3 wrong
                    if showHint && !foundFeature {
                        Text(sketch.featureHint)
                            .font(RenaissanceFont.italicSmall)
                            .foregroundStyle(RenaissanceColors.warmBrown)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    // Correct answer
                    if foundFeature {
                        HStack(spacing: Spacing.xxs) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(RenaissanceColors.sageGreen)
                            Text(sketch.featureToFind)
                                .font(RenaissanceFont.bodySmall)
                                .foregroundStyle(RenaissanceColors.sageGreen)
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                }
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.top, Spacing.sm)
    }

    // MARK: - Count Input (custom number pad — avoids system keyboard issues over SpriteKit)

    private var countInputSection: some View {
        HStack(spacing: Spacing.sm) {
            Text("Your answer:")
                .font(RenaissanceFont.bodySmall)
                .foregroundStyle(RenaissanceColors.sepiaInk)

            // Minus button
            if !foundFeature {
                Button {
                    if let n = Int(countInput), n > 0 {
                        countInput = "\(n - 1)"
                    }
                } label: {
                    Image(systemName: "minus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                        .frame(width: 36, height: 36)
                        .background(
                            Circle().fill(RenaissanceColors.sepiaInk.opacity(0.06))
                        )
                        .overlay(Circle().stroke(RenaissanceColors.ochre.opacity(0.3), lineWidth: 0.5))
                }
                .buttonStyle(.plain)
            }

            // Number display
            Text(countInput.isEmpty ? "?" : countInput)
                .font(.custom("Cinzel-Bold", size: 24))
                .foregroundStyle(countInput.isEmpty
                                ? RenaissanceColors.sepiaInk.opacity(0.3)
                                : RenaissanceColors.sepiaInk)
                .frame(width: 56)
                .padding(.vertical, Spacing.xs)
                .background(
                    RoundedRectangle(cornerRadius: CornerRadius.sm)
                        .fill(RenaissanceColors.parchment)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.sm)
                        .stroke(foundFeature
                                ? RenaissanceColors.sageGreen
                                : showWrongFlash
                                    ? RenaissanceColors.errorRed
                                    : RenaissanceColors.ochre.opacity(0.4),
                                lineWidth: foundFeature || showWrongFlash ? 2 : 1)
                )

            // Plus button
            if !foundFeature {
                Button {
                    let n = Int(countInput) ?? 0
                    if n < 99 { countInput = "\(n + 1)" }
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                        .frame(width: 36, height: 36)
                        .background(
                            Circle().fill(RenaissanceColors.sepiaInk.opacity(0.06))
                        )
                        .overlay(Circle().stroke(RenaissanceColors.ochre.opacity(0.3), lineWidth: 0.5))
                }
                .buttonStyle(.plain)
            }

            if foundFeature, correctCount != nil {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(RenaissanceColors.sageGreen)
                    .transition(.scale)
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.top, Spacing.xs)
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        HStack(spacing: Spacing.sm) {
            if !foundFeature {
                if isReflectMode {
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            foundFeature = true
                        }
                    } label: {
                        Text("Reveal Answer")
                            .font(.custom("Cinzel-Bold", size: 14))
                            .foregroundStyle(.white)
                            .padding(.horizontal, Spacing.lg)
                            .padding(.vertical, Spacing.xs + 2)
                            .background(
                                RoundedRectangle(cornerRadius: CornerRadius.sm)
                                    .fill(RenaissanceColors.ochre)
                            )
                    }
                    .buttonStyle(.plain)
                } else {
                    Button {
                        checkAnswer()
                    } label: {
                        Text(wrongAttempts > 0 && !showWrongFlash ? "Try Again!" : "I found it!")
                            .font(.custom("Cinzel-Bold", size: 14))
                            .foregroundStyle(.white)
                            .padding(.horizontal, Spacing.lg)
                            .padding(.vertical, Spacing.xs + 2)
                            .background(
                                RoundedRectangle(cornerRadius: CornerRadius.sm)
                                    .fill(canCheck
                                          ? RenaissanceColors.renaissanceBlue
                                          : RenaissanceColors.stoneGray)
                            )
                    }
                    .buttonStyle(.plain)
                    .disabled(!canCheck)
                }
            } else {
                Button {
                    onComplete(florinsReward)
                } label: {
                    HStack(spacing: Spacing.xxs) {
                        Text("Continue")
                            .font(.custom("Cinzel-Bold", size: 14))
                        Text("+\(florinsReward) florins")
                            .font(RenaissanceFont.caption)
                            .foregroundStyle(RenaissanceColors.ochre)
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, Spacing.xl)
                    .padding(.vertical, Spacing.xs + 2)
                    .background(
                        RoundedRectangle(cornerRadius: CornerRadius.sm)
                            .fill(RenaissanceColors.sageGreen)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.top, Spacing.sm)
        .padding(.bottom, Spacing.md)
    }

    // MARK: - Check Answer

    private func checkAnswer() {
        switch sketch.questionType {
        case .find:
            checkFindAnswer()
        case .count(let correctAnswer):
            checkCountAnswer(correctAnswer)
        case .reflect:
            break // Reflect mode uses "Reveal Answer" button directly
        }
    }

    private func checkFindAnswer() {
        guard let pos = tapPosition else { return }

        let dx = pos.x - sketch.tapTarget.x
        let dy = pos.y - sketch.tapTarget.y
        let distance = sqrt(dx * dx + dy * dy)

        if distance < sketch.tapRadius {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                foundFeature = true
            }
        } else {
            handleWrongAnswer()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation { tapPosition = nil }
            }
        }
    }

    private func checkCountAnswer(_ correctAnswer: Int) {
        guard let playerAnswer = Int(countInput) else { return }

        if playerAnswer == correctAnswer {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                foundFeature = true
            }
        } else {
            handleWrongAnswer()
            countInput = ""
        }
    }

    private func handleWrongAnswer() {
        wrongAttempts += 1
        withAnimation(.easeOut(duration: 0.2)) {
            showWrongFlash = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation { showWrongFlash = false }
        }
        if wrongAttempts >= 3 && !showHint {
            withAnimation(.easeOut(duration: 0.3)) {
                showHint = true
            }
        }
    }
}

// MARK: - Medium badge

private struct MediumBadge: View {
    let medium: String

    var body: some View {
        Text(medium)
            .font(RenaissanceFont.captionSmall)
            .foregroundStyle(RenaissanceColors.sepiaInk.opacity(TextEmphasis.tertiary))
            .padding(.horizontal, Spacing.xs)
            .padding(.vertical, 3)
            .background(
                Capsule()
                    .fill(RenaissanceColors.sepiaInk.opacity(0.05))
            )
    }
}

// MARK: - Pulse Animation Modifier

private struct PulseModifier: ViewModifier {
    @State private var scale: CGFloat = 0.9

    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .opacity(Double(2.0 - scale))
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    scale = 1.3
                }
            }
    }
}
