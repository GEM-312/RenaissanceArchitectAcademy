import SwiftUI

/// Mascot dialogue view with 3 visual game-loop cards
/// Appears when user taps a building — Learn, Explore, Build
struct MascotDialogueView: View {
    let plot: BuildingPlot
    var viewModel: CityViewModel
    var workshopState: WorkshopState
    var notebookState: NotebookState? = nil
    var onOpenNotebook: ((Int) -> Void)? = nil
    var heroNamespace: Namespace.ID? = nil
    let onChoice: (BuildingCardChoice) -> Void
    let onDismiss: () -> Void

    private var settings: GameSettings { GameSettings.shared }

    @Environment(\.horizontalSizeClass) private var sizeClass

    @State private var showMascot = false
    @State private var showDialogue = false
    @State private var showChoices = false
    @State private var auroraPhase = false
    @State private var cardFloat: CGFloat = 0

    /// Card dimensions — smaller on iPhone
    private var cardWidth: CGFloat { sizeClass == .compact ? 110 : 200 }
    private var cardHeight: CGFloat { sizeClass == .compact ? 160 : 280 }
    private var isCompact: Bool { sizeClass == .compact }

    private var progress: BuildingProgress {
        viewModel.buildingProgressMap[plot.id] ?? BuildingProgress()
    }

    var body: some View {
        ZStack {
            // Dimmed background
            RenaissanceColors.overlayDimming
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            VStack(spacing: 0) {
                Spacer()

                // Bird flies in from the map
                BirdCharacter(isSitting: false)
                    .frame(width: isCompact ? 80 : 140, height: isCompact ? 80 : 140)
                    .opacity(showMascot ? 1 : 0)
                    .padding(.bottom, isCompact ? -4 : -10)

                // Title above cards (no panel)
                VStack(spacing: isCompact ? 4 : 8) {
                    Text(plot.building.name)
                        .font(isCompact ? RenaissanceFont.title3 : RenaissanceFont.title)
                        .tracking(Tracking.label)
                        .foregroundColor(RenaissanceColors.ochre)
                        .shadow(color: .black.opacity(0.6), radius: 4, y: 2)
                        .heroEffect(id: "building-name-\(plot.id)", namespace: heroNamespace)

                    // Science icons row
                    HStack(spacing: isCompact ? 4 : 6) {
                        ForEach(plot.building.sciences, id: \.self) { science in
                            let iconSize: CGFloat = isCompact ? 20 : 28
                            if let imageName = science.customImageName {
                                Image(imageName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: iconSize, height: iconSize)
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                            } else {
                                Image(systemName: science.sfSymbolName)
                                    .font(isCompact ? RenaissanceFont.caption : RenaissanceFont.bodySmall)
                                    .foregroundStyle(RenaissanceColors.ochre)
                                    .shadow(color: .black.opacity(0.4), radius: 3, y: 1)
                                    .frame(width: iconSize, height: iconSize)
                            }
                        }
                    }

                    // Notebook button (if entries exist)
                    if let ns = notebookState, ns.hasEntries(for: plot.id) {
                        Button {
                            onDismiss()
                            onOpenNotebook?(plot.id)
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "book.closed.fill")
                                    .font(RenaissanceFont.caption)
                                Text("Open Notebook")
                                    .font(RenaissanceFont.bodySmall)
                            }
                            .foregroundStyle(RenaissanceColors.ochre)
                            .shadow(color: .black.opacity(0.4), radius: 3, y: 1)
                            .padding(.horizontal, Spacing.md)
                            .padding(.vertical, Spacing.xs)
                            .background(
                                Capsule()
                                    .fill(Color.black.opacity(0.25))
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .opacity(showDialogue ? 1 : 0)
                .offset(y: showDialogue ? 0 : 20)
                .padding(.bottom, 20)

                // 3 Cards — floating with connection line
                ZStack {
                    // Connection line behind cards
                    Rectangle()
                        .fill(RenaissanceColors.ochre.opacity(0.2))
                        .frame(width: 3 * cardWidth + 2 * (isCompact ? Spacing.xs : Spacing.md) - 60, height: 2)

                    HStack(spacing: isCompact ? Spacing.xs : Spacing.md) {
                        ForEach(Array(BuildingCardChoice.allCases.enumerated()), id: \.element) { index, choice in
                            buildingCard(choice: choice, index: index)
                                .offset(y: cardFloat * (index.isMultiple(of: 2) ? 1 : -1))
                                .opacity(showChoices ? 1 : 0)
                                .offset(y: showChoices ? 0 : 30)
                                .animation(
                                    .spring(response: 0.5, dampingFraction: 0.7)
                                    .delay(Double(index) * 0.12),
                                    value: showChoices
                                )
                        }
                    }
                }

                Spacer()
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                showMascot = true
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
                showDialogue = true
            }
            withAnimation(.spring(response: 0.5).delay(0.6)) {
                showChoices = true
            }
            auroraPhase = true
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                cardFloat = 8
            }
        }
    }

    // MARK: - Card Builder

    @ViewBuilder
    private func buildingCard(choice: BuildingCardChoice, index: Int) -> some View {
        Button {
            withAnimation(.spring()) {
                onChoice(choice)
            }
        } label: {
            let color = cardColor(for: choice)
            ZStack {
                // Layer 1: Glass background + aurora blobs (matches Forest/Knowledge cards)
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(RenaissanceColors.sepiaInk)
                    )
                    .overlay(
                        ZStack {
                            Ellipse()
                                .fill(color.opacity(0.55))
                                .frame(width: 180, height: 120)
                                .blur(radius: 38)
                                .offset(
                                    x: auroraPhase ? 40 : -30,
                                    y: auroraPhase ? 100 : 130
                                )
                                .animation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true), value: auroraPhase)

                            Ellipse()
                                .fill(color.opacity(0.4))
                                .frame(width: 128, height: 165)
                                .blur(radius: 33)
                                .offset(
                                    x: auroraPhase ? -35 : 25,
                                    y: auroraPhase ? 110 : 140
                                )
                                .animation(.easeInOut(duration: 5.5).repeatForever(autoreverses: true), value: auroraPhase)

                            Ellipse()
                                .fill(RenaissanceColors.goldSuccess.opacity(0.3))
                                .frame(width: 135, height: 90)
                                .blur(radius: 36)
                                .offset(
                                    x: auroraPhase ? 20 : -40,
                                    y: auroraPhase ? 105 : 135
                                )
                                .animation(.easeInOut(duration: 6.5).repeatForever(autoreverses: true), value: auroraPhase)

                            Circle()
                                .fill(Color.white.opacity(0.25))
                                .frame(width: 82, height: 82)
                                .blur(radius: 27)
                                .offset(
                                    x: auroraPhase ? -15 : 30,
                                    y: auroraPhase ? 115 : 120
                                )
                                .animation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true), value: auroraPhase)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    )

                // Layer 2: Content (matches Forest/Knowledge card layout)
                VStack(spacing: isCompact ? Spacing.xxs : Spacing.sm) {
                    Spacer()

                    ZStack {
                        Circle()
                            .fill(color.opacity(0.15))
                            .frame(width: isCompact ? 40 : 70, height: isCompact ? 40 : 70)
                        Image(systemName: choice.icon)
                            .font(.system(size: isCompact ? 20 : 36))
                            .foregroundStyle(color)
                            .shadow(color: color.opacity(0.5), radius: 6)
                    }

                    Text(choice.rawValue)
                        .font(isCompact ? RenaissanceFont.captionSmall : RenaissanceFont.cardTitle)
                        .tracking(isCompact ? 0.5 : Tracking.label)
                        .foregroundStyle(color)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)

                    if !isCompact {
                        cardDetail(for: choice)
                    }

                    Spacer()
                }
            }
            .frame(width: cardWidth, height: cardHeight)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(color.opacity(0.3), lineWidth: 1.5)
            )
            .shadow(color: color.opacity(0.5), radius: 20, y: 6)
            .shadow(color: color.opacity(0.3), radius: 40, y: 10)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func cardDetail(for choice: BuildingCardChoice) -> some View {
        switch choice {
        case .readToEarn:
            // Show card progress if building has knowledge cards, otherwise florins badge
            let cardInfo = viewModel.cardProgress(for: plot.id)
            if cardInfo.total > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "square.stack.fill")
                        .font(RenaissanceFont.captionSmall)
                        .foregroundStyle(cardInfo.completed == cardInfo.total ? RenaissanceColors.sageGreen : RenaissanceColors.ochre)
                    Text("\(cardInfo.completed)/\(cardInfo.total)")
                        .font(RenaissanceFont.bodySmall)
                        .foregroundStyle(cardInfo.completed == cardInfo.total ? RenaissanceColors.sageGreen : RenaissanceColors.ochre)
                }
                .padding(.horizontal, Spacing.sm)
                .padding(.vertical, Spacing.xxs)
                .background(
                    Capsule()
                        .fill((cardInfo.completed == cardInfo.total ? RenaissanceColors.sageGreen : RenaissanceColors.ochre).opacity(0.12))
                )
            } else {
                HStack(spacing: 4) {
                    Image(systemName: "dollarsign.circle.fill")
                        .font(RenaissanceFont.captionSmall)
                        .foregroundStyle(RenaissanceColors.goldSuccess)
                    Text("+\(GameRewards.lessonReadFlorins)")
                        .font(RenaissanceFont.bodySmall)
                        .foregroundStyle(RenaissanceColors.goldSuccess)
                }
                .padding(.horizontal, Spacing.sm)
                .padding(.vertical, Spacing.xxs)
                .background(
                    Capsule()
                        .fill(RenaissanceColors.goldSuccess.opacity(0.12))
                )
            }

        case .environments:
            Text(choice.subtitle)
                .font(RenaissanceFont.captionSmall)
                .foregroundStyle(settings.cardTextColor)
                .multilineTextAlignment(.center)
                .lineLimit(2)

        case .readyToBuild:
            // Mini checklist preview
            let reqCount = requirementsMet()
            let totalReqs = totalRequirements()
            HStack(spacing: 4) {
                Image(systemName: reqCount == totalReqs ? "checkmark.circle.fill" : "circle")
                    .font(RenaissanceFont.captionSmall)
                    .foregroundStyle(reqCount == totalReqs ? RenaissanceColors.sageGreen : RenaissanceColors.stoneGray)
                Text("\(reqCount)/\(totalReqs)")
                    .font(RenaissanceFont.bodySmall)
                    .foregroundStyle(reqCount == totalReqs ? RenaissanceColors.sageGreen : RenaissanceColors.stoneGray)
            }
        }
    }

    private func cardColor(for choice: BuildingCardChoice) -> Color {
        switch choice {
        case .readToEarn: return RenaissanceColors.ochre
        case .environments: return RenaissanceColors.renaissanceBlue
        case .readyToBuild: return RenaissanceColors.sageGreen
        }
    }

    /// Count how many requirements are met for this building
    private func requirementsMet() -> Int {
        var met = 0
        // 1. Lesson read (via knowledge cards or old paged lesson)
        let hasLesson = LessonContent.lesson(for: plot.building.name) != nil
        let hasCards = !KnowledgeCardContent.cards(for: plot.building.name).isEmpty
        if (!hasLesson && !hasCards) || progress.lessonRead { met += 1 }
        // 2. Science badges
        let sciences = plot.building.sciences
        let badgesEarned = progress.scienceBadgesEarned
        if sciences.allSatisfy({ badgesEarned.contains($0) }) { met += 1 }
        // 3. Sketch
        let hasSketchContent = SketchingContent.sketchingChallenge(for: plot.building.name) != nil
        if !hasSketchContent || progress.sketchCompleted { met += 1 }
        // 4. Materials
        let materialsOk = plot.building.requiredMaterials.allSatisfy { item, needed in
            (workshopState.craftedMaterials[item] ?? 0) >= needed
        }
        if materialsOk { met += 1 }
        return met
    }

    private func totalRequirements() -> Int {
        return 4 // lesson, sciences, sketch, materials
    }
}


/// Animated bird companion — flies in from off-screen, lands, and sits still.
///
/// Two animation sets, both play ONCE and stop on last frame:
/// 1. **Flying → Sitting** (BirdFlySitFrame00–14): bird flies in and lands
/// 2. **Sitting Blink** (BirdSitBlinkFrame00–14): bird blinks once while perched
///
/// The bird also animates its SwiftUI position — it starts off-screen (top-right)
/// and swoops down to its resting spot while the sprite frames play the wing flap.
///
/// Usage:
/// - `BirdCharacter()` — flies in from top-right, plays landing, sits still
/// - `BirdCharacter(isSitting: true)` — already sitting, plays one blink, sits still
struct BirdCharacter: View {
    /// When true, starts in sitting position (skips fly-in)
    var isSitting: Bool = false

    private static let flySitFrameCount = 15
    private static let sitBlinkFrameCount = 15
    private static let flyFPS: TimeInterval = 1.0 / 5.0    // ~5fps — slow, graceful fly-in
    private static let blinkFPS: TimeInterval = 1.0 / 8.0   // ~8fps for gentle blink
    /// Play fly frames once — single fly-in and land
    private static let totalFlyFrames = flySitFrameCount
    /// Total duration of the fly-in sprite animation
    private static let flyDuration: TimeInterval = Double(totalFlyFrames) * flyFPS

    @State private var currentFrameName: String = "BirdFlySitFrame00"
    @State private var timer: Timer?

    // Fly-in position animation state
    @State private var flyOffset: CGSize = CGSize(width: -120, height: -200) // start off-screen top-left
    @State private var flyRotation: Double = 15  // slight tilt while flying

    var body: some View {
        Image(currentFrameName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .rotationEffect(.degrees(isSitting ? 0 : flyRotation))
            .offset(isSitting ? .zero : flyOffset)
            .onAppear {
                if isSitting {
                    // Already sitting — show last fly frame, play blink once
                    flyOffset = .zero
                    flyRotation = 0
                    SoundManager.shared.play(.birdChirp)
                    playSittingBlink()
                } else {
                    playFlyIn()
                }
            }
            .onDisappear {
                timer?.invalidate()
                timer = nil
            }
            .onChange(of: isSitting) { _, sitting in
                timer?.invalidate()
                timer = nil
                if sitting {
                    playSittingBlink()
                } else {
                    playFlyIn()
                }
            }
    }

    /// Fly in from top-left: loop flying frames, swoop down, then land
    private func playFlyIn() {
        timer?.invalidate()

        // Bird's audible wingbeat — synced to the visual swoop
        SoundManager.shared.play(.birdFlyIn)

        // Reset to start position (off-screen top-left, tilted)
        flyOffset = CGSize(width: -180, height: -280)
        flyRotation = 20
        currentFrameName = "BirdFlySitFrame00"

        // Animate SwiftUI position — bird swoops down to center over the full duration
        withAnimation(.easeInOut(duration: Self.flyDuration)) {
            flyOffset = .zero
            flyRotation = 0
        }

        // Play sprite frames: loop flySit frames N times, then hold on last frame
        var totalFrame = 0
        timer = Timer.scheduledTimer(withTimeInterval: Self.flyFPS, repeats: true) { t in
            totalFrame += 1
            if totalFrame < Self.totalFlyFrames {
                currentFrameName = String(format: "BirdFlySitFrame%02d", totalFrame)
            } else {
                // Final frame — bird has landed
                currentFrameName = String(format: "BirdFlySitFrame%02d", Self.flySitFrameCount - 1)
                t.invalidate()
            }
        }
    }

    /// Play sitting blink animation ONCE — stops on last frame
    private func playSittingBlink() {
        timer?.invalidate()
        var frame = 0
        currentFrameName = "BirdSitBlinkFrame00"

        timer = Timer.scheduledTimer(withTimeInterval: Self.blinkFPS, repeats: true) { t in
            if frame < Self.sitBlinkFrameCount - 1 {
                frame += 1
                currentFrameName = String(format: "BirdSitBlinkFrame%02d", frame)
            } else {
                t.invalidate()
                // Stay on last frame
            }
        }
    }
}


// MARK: - Shape Components

struct WatercolorSplash: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height

        // Organic blob shape
        path.move(to: CGPoint(x: w * 0.5, y: 0))
        path.addCurve(
            to: CGPoint(x: w, y: h * 0.4),
            control1: CGPoint(x: w * 0.8, y: 0),
            control2: CGPoint(x: w, y: h * 0.2)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.7, y: h),
            control1: CGPoint(x: w, y: h * 0.7),
            control2: CGPoint(x: w * 0.9, y: h)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.3, y: h),
            control1: CGPoint(x: w * 0.5, y: h),
            control2: CGPoint(x: w * 0.4, y: h)
        )
        path.addCurve(
            to: CGPoint(x: 0, y: h * 0.4),
            control1: CGPoint(x: w * 0.1, y: h),
            control2: CGPoint(x: 0, y: h * 0.7)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.5, y: 0),
            control1: CGPoint(x: 0, y: h * 0.2),
            control2: CGPoint(x: w * 0.2, y: 0)
        )

        return path
    }
}

struct Eye: View {
    @State private var blink = false
    @State private var blinkTimer: Timer?

    var body: some View {
        ZStack {
            // White
            Ellipse()
                .fill(.white)
                .frame(width: 20, height: blink ? 3 : 18)

            // Pupil
            Circle()
                .fill(RenaissanceColors.sepiaInk)
                .frame(width: 10, height: 10)
                .offset(y: 2)
                .opacity(blink ? 0 : 1)
        }
        .onAppear {
            blinkTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
                withAnimation(.easeInOut(duration: 0.15)) {
                    blink = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        blink = false
                    }
                }
            }
        }
        .onDisappear {
            blinkTimer?.invalidate()
            blinkTimer = nil
        }
    }
}

struct Smile: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addQuadCurve(
            to: CGPoint(x: rect.width, y: 0),
            control: CGPoint(x: rect.width / 2, y: rect.height)
        )
        return path
    }
}

struct InkDrip: View {
    let height: CGFloat
    @State private var drip = false

    var body: some View {
        Capsule()
            .fill(RenaissanceColors.warmBrown.opacity(0.7))
            .frame(width: 8, height: height)
            .offset(y: drip ? 5 : 0)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true).delay(Double.random(in: 0...0.5))) {
                    drip = true
                }
            }
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct DialogueBubble: View {
    private var settings: GameSettings { GameSettings.shared }

    var body: some View {
        ZStack {
            // Main bubble
            RoundedRectangle(cornerRadius: 20)
                .fill(settings.dialogBackground)

            // Border
            RoundedRectangle(cornerRadius: 20)
                .stroke(settings.cardBorderColor, lineWidth: 2)

            // Decorative corner flourishes
            VStack {
                HStack {
                    DialogueCornerFlourish()
                    Spacer()
                    DialogueCornerFlourish()
                        .scaleEffect(x: -1)
                }
                Spacer()
                HStack {
                    DialogueCornerFlourish()
                        .scaleEffect(y: -1)
                    Spacer()
                    DialogueCornerFlourish()
                        .scaleEffect(x: -1, y: -1)
                }
            }
            .padding(8)
        }
    }
}

struct DialogueCornerFlourish: View {
    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 20))
            path.addQuadCurve(
                to: CGPoint(x: 20, y: 0),
                control: CGPoint(x: 0, y: 0)
            )
        }
        .stroke(RenaissanceColors.ochre.opacity(0.4), lineWidth: 2)
        .frame(width: 20, height: 20)
    }
}

// MARK: - Preview

#Preview {
    MascotDialogueView(
        plot: BuildingPlot(
            id: 4,
            building: Building(name: "Pantheon", era: .ancientRome, sciences: [.geometry, .architecture, .materials], iconName: "circle.circle"),
            isCompleted: false
        ),
        viewModel: CityViewModel(),
        workshopState: WorkshopState(),
        notebookState: NotebookState(),
        onChoice: { choice in
            print("Chose: \(choice.rawValue)")
        },
        onDismiss: {}
    )
}
