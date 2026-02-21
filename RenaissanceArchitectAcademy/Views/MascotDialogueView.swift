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
    @State private var birdOffset: CGFloat = 0

    private var progress: BuildingProgress {
        viewModel.buildingProgressMap[plot.id] ?? BuildingProgress()
    }

    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            VStack(spacing: 16) {
                Spacer()

                // Bird sitting on top of dialogue box
                BirdCharacter(isSitting: true)
                    .frame(width: 180, height: 180)
                    .offset(y: birdOffset)
                    .scaleEffect(showMascot ? 1 : 0.3)
                    .opacity(showMascot ? 1 : 0)
                    .padding(.bottom, -30)

                // Dialogue bubble with cards
                VStack(spacing: 16) {
                    // Title
                    VStack(spacing: 8) {
                        Text(plot.building.name)
                            .font(.custom("Cinzel-Bold", size: 22))
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
                                        .font(.system(size: 16))
                                        .foregroundStyle(RenaissanceColors.warmBrown)
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
                                    .font(.system(size: 13))
                                Text("Open Notebook")
                                    .font(.custom("Cinzel-Bold", size: 12))
                            }
                            .foregroundStyle(RenaissanceColors.renaissanceBlue)
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
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                birdOffset = -10
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
                        .font(.system(size: 22))
                        .foregroundStyle(cardColor(for: choice))
                }

                // Title
                Text(choice.rawValue)
                    .font(.custom("Cinzel-Bold", size: 13))
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
                    .shadow(color: cardColor(for: choice).opacity(0.15), radius: 6, y: 3)
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
                    .font(.system(size: 12))
                    .foregroundStyle(RenaissanceColors.goldSuccess)
                Text("+\(GameRewards.lessonReadFlorins)")
                    .font(.custom("Cinzel-Bold", size: 12))
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
                .font(.custom("EBGaramond-Italic", size: 11))
                .foregroundStyle(RenaissanceColors.stoneGray)
                .multilineTextAlignment(.center)
                .lineLimit(2)

        case .readyToBuild:
            // Mini checklist preview
            let reqCount = requirementsMet()
            let totalReqs = totalRequirements()
            HStack(spacing: 4) {
                Image(systemName: reqCount == totalReqs ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 12))
                    .foregroundStyle(reqCount == totalReqs ? RenaissanceColors.sageGreen : RenaissanceColors.stoneGray)
                Text("\(reqCount)/\(totalReqs)")
                    .font(.custom("Cinzel-Bold", size: 12))
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

/// Animated bird companion — 13-frame flying animation or sitting (perched)
struct BirdCharacter: View {
    /// When true, shows sitting/perched frames instead of flying
    var isSitting: Bool = false

    /// Total flying animation frames
    private static let frameCount = 13
    /// Seconds per frame (~15 fps for smooth flapping)
    private static let frameDuration: TimeInterval = 1.0 / 15.0

    @State private var currentFrame = 0
    @State private var showFrame2 = false
    @State private var timer: Timer?

    var body: some View {
        Group {
            if isSitting {
                Image(showFrame2 ? "SittingBird2" : "SittingBird1")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Image("BirdFrame\(String(format: "%02d", currentFrame))")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        }
        .onAppear {
            if isSitting {
                withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                    showFrame2 = true
                }
            } else {
                startFlyingAnimation()
            }
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
        .onChange(of: isSitting) { _, sitting in
            if sitting {
                timer?.invalidate()
                timer = nil
                withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                    showFrame2 = true
                }
            } else {
                startFlyingAnimation()
            }
        }
    }

    private func startFlyingAnimation() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: Self.frameDuration, repeats: true) { _ in
            currentFrame = (currentFrame + 1) % Self.frameCount
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
                .shadow(color: .black.opacity(0.2), radius: 20, y: 10)

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
