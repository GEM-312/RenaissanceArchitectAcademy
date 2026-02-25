import SwiftUI

/// Mascot dialogue view with 3 visual game-loop cards
/// Appears when user taps a building — Learn, Explore, Build
struct MascotDialogueView: View {
    let plot: BuildingPlot
    @ObservedObject var viewModel: CityViewModel
    var workshopState: WorkshopState
    var notebookState: NotebookState? = nil
    var onOpenNotebook: ((Int) -> Void)? = nil
    let onChoice: (BuildingCardChoice) -> Void
    let onDismiss: () -> Void

    @State private var showMascot = false
    @State private var showDialogue = false
    @State private var showChoices = false

    private var progress: BuildingProgress {
        viewModel.buildingProgressMap[plot.id] ?? BuildingProgress()
    }

    var body: some View {
        ZStack {
            // Dimmed background
            RenaissanceColors.overlayDimming
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            VStack(spacing: 16) {
                Spacer()

                // Bird flies in from the map and lands on top of dialogue box
                BirdCharacter(isSitting: false)
                    .frame(width: 180, height: 180)
                    .opacity(showMascot ? 1 : 0)
                    .padding(.bottom, -30)

                // Dialogue bubble with cards
                VStack(spacing: 16) {
                    // Title
                    VStack(spacing: 8) {
                        Text(plot.building.name)
                            .font(.custom("EBGaramond-SemiBold", size: 24))
                            .foregroundColor(RenaissanceColors.sepiaInk)

                        // Science icons row
                        HStack(spacing: 6) {
                            ForEach(plot.building.sciences, id: \.self) { science in
                                if let imageName = science.customImageName {
                                    Image(imageName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 28, height: 28)
                                        .clipShape(RoundedRectangle(cornerRadius: 6))
                                } else {
                                    Image(systemName: science.sfSymbolName)
                                        .font(.custom("Mulish-Light", size: 16, relativeTo: .subheadline))
                                        .foregroundStyle(RenaissanceColors.sepiaInk)
                                        .frame(width: 28, height: 28)
                                }
                            }
                        }
                    }
                    .opacity(showDialogue ? 1 : 0)
                    .offset(y: showDialogue ? 0 : 20)

                    // Notebook button (if entries exist)
                    if let ns = notebookState, ns.hasEntries(for: plot.id) {
                        Button {
                            onDismiss()
                            onOpenNotebook?(plot.id)
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "book.closed.fill")
                                    .font(.custom("Mulish-Light", size: 13, relativeTo: .footnote))
                                Text("Open Notebook")
                                    .font(.custom("EBGaramond-Regular", size: 14))
                            }
                            .foregroundStyle(RenaissanceColors.sepiaInk)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(
                                Capsule()
                                    .fill(RenaissanceColors.renaissanceBlue.opacity(0.1))
                            )
                        }
                        .buttonStyle(.plain)
                        .opacity(showDialogue ? 1 : 0)
                    }

                    // 3 Cards in HStack
                    HStack(spacing: 12) {
                        ForEach(Array(BuildingCardChoice.allCases.enumerated()), id: \.element) { index, choice in
                            buildingCard(choice: choice, index: index)
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
                .padding(20)
                .background(DialogueBubble())
                .padding(.horizontal, 24)

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
            VStack(spacing: 10) {
                // Icon circle
                ZStack {
                    Circle()
                        .fill(cardColor(for: choice).opacity(0.15))
                        .frame(width: 50, height: 50)
                    Image(systemName: choice.icon)
                        .font(.custom("Mulish-Light", size: 22, relativeTo: .title3))
                        .foregroundStyle(cardColor(for: choice))
                }

                // Title
                Text(choice.rawValue)
                    .font(.custom("EBGaramond-SemiBold", size: 15))
                    .foregroundStyle(RenaissanceColors.sepiaInk)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)

                // Card-specific content
                cardDetail(for: choice)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(RenaissanceColors.parchment)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(cardColor(for: choice).opacity(0.4), lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func cardDetail(for choice: BuildingCardChoice) -> some View {
        switch choice {
        case .readToEarn:
            // Florins badge
            HStack(spacing: 4) {
                Image(systemName: "dollarsign.circle.fill")
                    .font(.custom("Mulish-Light", size: 12, relativeTo: .caption))
                    .foregroundStyle(RenaissanceColors.goldSuccess)
                Text("+\(GameRewards.lessonReadFlorins)")
                    .font(.custom("EBGaramond-SemiBold", size: 14))
                    .foregroundStyle(RenaissanceColors.goldSuccess)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(RenaissanceColors.goldSuccess.opacity(0.12))
            )

        case .environments:
            Text(choice.subtitle)
                .font(.custom("Mulish-Light", size: 11))
                .foregroundStyle(RenaissanceColors.sepiaInk)
                .multilineTextAlignment(.center)
                .lineLimit(2)

        case .readyToBuild:
            // Mini checklist preview
            let reqCount = requirementsMet()
            let totalReqs = totalRequirements()
            HStack(spacing: 4) {
                Image(systemName: reqCount == totalReqs ? "checkmark.circle.fill" : "circle")
                    .font(.custom("Mulish-Light", size: 12, relativeTo: .caption))
                    .foregroundStyle(reqCount == totalReqs ? RenaissanceColors.sageGreen : RenaissanceColors.stoneGray)
                Text("\(reqCount)/\(totalReqs)")
                    .font(.custom("EBGaramond-SemiBold", size: 14))
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
        let sciences = plot.building.sciences
        let badgesEarned = progress.scienceBadgesEarned
        if sciences.allSatisfy({ badgesEarned.contains($0) }) { met += 1 }
        let hasSketchContent = SketchingContent.sketchingChallenge(for: plot.building.name) != nil
        if !hasSketchContent || progress.sketchCompleted { met += 1 }
        let hasQuizContent = ChallengeContent.interactiveChallenge(for: plot.building.name) != nil
        if !hasQuizContent || progress.quizPassed { met += 1 }
        let materialsOk = plot.building.requiredMaterials.allSatisfy { item, needed in
            (workshopState.craftedMaterials[item] ?? 0) >= needed
        }
        if materialsOk { met += 1 }
        return met
    }

    private func totalRequirements() -> Int {
        return 4 // sciences, sketch, quiz, materials
    }
}

/// Splash - the main watercolor ink mascot
struct SplashCharacter: View {
    @State private var wiggle = false

    var body: some View {
        ZStack {
            // Body - watercolor splash shape
            WatercolorSplash()
                .fill(
                    LinearGradient(
                        colors: [
                            RenaissanceColors.ochre,
                            RenaissanceColors.warmBrown,
                            RenaissanceColors.terracotta.opacity(0.8)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 120, height: 140)
                .rotationEffect(.degrees(wiggle ? 2 : -2))

            // Face
            VStack(spacing: 8) {
                // Eyes
                HStack(spacing: 24) {
                    Eye()
                    Eye()
                }

                // Friendly smile
                Smile()
                    .stroke(RenaissanceColors.sepiaInk, lineWidth: 3)
                    .frame(width: 30, height: 15)
            }
            .offset(y: -10)

            // Ink drips at bottom
            HStack(spacing: 15) {
                InkDrip(height: 20)
                InkDrip(height: 35)
                InkDrip(height: 25)
            }
            .offset(y: 60)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                wiggle = true
            }
        }
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
    private static let flyFPS: TimeInterval = 1.0 / 12.0   // ~12fps for smooth landing
    private static let blinkFPS: TimeInterval = 1.0 / 8.0   // ~8fps for gentle blink
    /// Total duration of the fly-in sprite animation
    private static let flyDuration: TimeInterval = Double(flySitFrameCount) * flyFPS

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

    /// Fly in from top-left: animate position + play sprite frames, then sit still
    private func playFlyIn() {
        timer?.invalidate()

        // Reset to start position (off-screen top-left, tilted)
        flyOffset = CGSize(width: -120, height: -200)
        flyRotation = 15
        currentFrameName = "BirdFlySitFrame00"

        // Animate SwiftUI position — bird swoops down to center
        withAnimation(.easeOut(duration: Self.flyDuration)) {
            flyOffset = .zero
            flyRotation = 0
        }

        // Play sprite frames in sync
        var frame = 0
        timer = Timer.scheduledTimer(withTimeInterval: Self.flyFPS, repeats: true) { t in
            if frame < Self.flySitFrameCount - 1 {
                frame += 1
                currentFrameName = String(format: "BirdFlySitFrame%02d", frame)
            } else {
                t.invalidate()
                // Stay on last frame (bird sitting still)
            }
        }
    }

    /// Play fly-to-sit sprite animation ONCE without position movement (used by onChange)
    private func playFlyToSit() {
        timer?.invalidate()
        var frame = 0
        currentFrameName = "BirdFlySitFrame00"

        timer = Timer.scheduledTimer(withTimeInterval: Self.flyFPS, repeats: true) { t in
            if frame < Self.flySitFrameCount - 1 {
                frame += 1
                currentFrameName = String(format: "BirdFlySitFrame%02d", frame)
            } else {
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
            // Random blinking
            Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
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
    var body: some View {
        ZStack {
            // Main bubble
            RoundedRectangle(cornerRadius: 20)
                .fill(RenaissanceColors.parchment)

            // Border
            RoundedRectangle(cornerRadius: 20)
                .stroke(RenaissanceColors.ochre.opacity(0.5), lineWidth: 2)

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
