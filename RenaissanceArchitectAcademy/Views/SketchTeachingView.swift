import SwiftUI

/// 3-step teaching experience before the sketching canvas:
/// Step 1 (Observe) — Met Museum sketch: tap to identify the key feature
/// Step 2 (Understand) — Wolfram geometry + engineering annotations
/// Step 3 (Plan) — Grid preview with ghost targets
struct SketchTeachingView: View {
    let teachingData: SketchTeachingData
    let challenge: SketchingChallenge
    let onComplete: () -> Void
    let onBack: () -> Void
    let onSkip: () -> Void
    var onFlorinsEarned: ((Int) -> Void)? = nil

    @State private var currentStep: SketchTeachingStep = .observe
    @State private var completedSteps: Set<SketchTeachingStep> = []

    // Step 1 — interactive tap state
    @State private var showHint = false
    @State private var foundFeature = false
    @State private var incorrectTaps = 0
    @State private var lastTapPosition: CGPoint? = nil
    @State private var showWrongFlash = false
    @StateObject private var sketchService = MuseumSketchService.shared

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    private var isLargeScreen: Bool { horizontalSizeClass == .regular }

    private let florinsPerStep = GameRewards.sketchStudyFlorins  // 3

    var body: some View {
        ZStack {
            // Background
            RenaissanceColors.parchmentGradient
                .ignoresSafeArea()
                .overlay(
                    BlueprintGridOverlay()
                        .opacity(0.03)
                )

            VStack(spacing: 0) {
                topBar
                ScrollView {
                    VStack(spacing: 20) {
                        stepContent
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, isLargeScreen ? 40 : 16)
                    .padding(.top, 16)
                }
            }
        }
        .onAppear {
            // Pre-warm Wolfram cache so Step 2 loads instantly
            if let geometry = wolframGeometry {
                Task { _ = await WolframGeometryHelper.shared.computeAll(for: geometry) }
            }
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            Button {
                if currentStep == .observe {
                    onBack()
                } else {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentStep = SketchTeachingStep(rawValue: currentStep.rawValue - 1) ?? .observe
                        resetStepState()
                    }
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.6))
            }
            .buttonStyle(.plain)

            Spacer()

            // Step indicator dots
            HStack(spacing: 8) {
                ForEach(SketchTeachingStep.allCases, id: \.rawValue) { step in
                    VStack(spacing: 3) {
                        Circle()
                            .fill(dotColor(for: step))
                            .frame(width: 10, height: 10)
                        Text(step.italianTitle)
                            .font(.custom("EBGaramond-Italic", size: 10))
                            .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.5))
                    }
                }
            }

            Spacer()

            Button {
                onSkip()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.4))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    private func dotColor(for step: SketchTeachingStep) -> Color {
        if completedSteps.contains(step) {
            return RenaissanceColors.sageGreen
        } else if step == currentStep {
            return RenaissanceColors.renaissanceBlue
        } else {
            return RenaissanceColors.stoneGray.opacity(0.3)
        }
    }

    // MARK: - Step Content Router

    @ViewBuilder
    private var stepContent: some View {
        switch currentStep {
        case .observe:
            observeStep
        case .understand:
            understandStep
        case .plan:
            planStep
        }
    }

    // MARK: - Step 1: Observe (Interactive Tap on Sketch)

    private var observeStep: some View {
        VStack(spacing: 16) {
            stepHeader(step: .observe, title: "Study the Masters", subtitle: "Tap on the sketch to find the key architectural feature")

            // Interactive Met Museum image
            interactiveSketchImage

            // Bird question + feedback
            birdQuestionSection

            // Continue button (after finding feature)
            if foundFeature {
                continueButton {
                    completeStep(.observe)
                    advanceToStep(.understand)
                }
            }

            skipTextButton
        }
    }

    private var interactiveSketchImage: some View {
        VStack(spacing: 6) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(RenaissanceColors.sepiaInk.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(RenaissanceColors.sepiaInk.opacity(0.15), lineWidth: 1)
                    )

                if let sketch = findMuseumSketch() {
                    if let cachedImage = sketchService.imageCache[sketch.id] {
                        // Interactive tappable image
                        GeometryReader { geo in
                            ZStack {
                                cachedImage
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))

                                // Wrong tap flash (red ring)
                                if showWrongFlash, let pos = lastTapPosition {
                                    Circle()
                                        .stroke(RenaissanceColors.errorRed.opacity(0.7), lineWidth: 3)
                                        .frame(width: 50, height: 50)
                                        .position(x: pos.x * geo.size.width,
                                                  y: pos.y * geo.size.height)
                                        .transition(.scale.combined(with: .opacity))
                                }

                                // Correct tap — green ring on target
                                if foundFeature {
                                    Circle()
                                        .stroke(RenaissanceColors.sageGreen, lineWidth: 3)
                                        .frame(width: 60, height: 60)
                                        .position(x: teachingData.observeTapTarget.x * geo.size.width,
                                                  y: teachingData.observeTapTarget.y * geo.size.height)
                                        .transition(.scale.combined(with: .opacity))

                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundStyle(RenaissanceColors.sageGreen)
                                        .position(x: teachingData.observeTapTarget.x * geo.size.width,
                                                  y: teachingData.observeTapTarget.y * geo.size.height)
                                        .transition(.scale)
                                }

                                // Hint pulsing circle (after 2 wrong taps)
                                if showHint && !foundFeature {
                                    Circle()
                                        .stroke(RenaissanceColors.ochre.opacity(0.5), lineWidth: 2)
                                        .frame(width: 70, height: 70)
                                        .position(x: teachingData.observeTapTarget.x * geo.size.width,
                                                  y: teachingData.observeTapTarget.y * geo.size.height)
                                        .modifier(PulseModifier())
                                }

                                // Tap gesture overlay
                                if !foundFeature {
                                    Color.clear
                                        .contentShape(Rectangle())
                                        .onTapGesture { location in
                                            handleSketchTap(location: location, size: geo.size)
                                        }
                                }
                            }
                        }
                        .transition(.opacity)
                    } else if sketchService.loadingIDs.contains(sketch.id) {
                        VStack(spacing: 12) {
                            ProgressView()
                                .tint(RenaissanceColors.warmBrown)
                            Text("Loading sketch from the Metropolitan Museum...")
                                .font(.custom("EBGaramond-Italic", size: 13))
                                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.5))
                        }
                    } else {
                        VStack(spacing: 8) {
                            Image(systemName: "photo.artframe")
                                .font(.system(size: 40))
                                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.2))
                            Text(sketch.title)
                                .font(.custom("EBGaramond-Regular", size: 14))
                                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.4))
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                    }
                } else {
                    VStack(spacing: 8) {
                        Image(systemName: "building.columns")
                            .font(.system(size: 40))
                            .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.2))
                        Text("Architectural Study")
                            .font(.custom("EBGaramond-Regular", size: 14))
                            .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.4))
                    }
                    .padding()
                }
            }
            .frame(height: isLargeScreen ? 400 : 320)

            // Caption
            if let sketch = findMuseumSketch() {
                Text("\(sketch.title) — \(sketch.artist), \(sketch.date)")
                    .font(.custom("EBGaramond-Italic", size: 12))
                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.5))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
        }
        .onAppear {
            if let sketch = findMuseumSketch() {
                Task { await sketchService.loadImage(for: sketch) }
            }
        }
    }

    private func handleSketchTap(location: CGPoint, size: CGSize) {
        let normalized = CGPoint(
            x: location.x / size.width,
            y: location.y / size.height
        )
        let dx = normalized.x - teachingData.observeTapTarget.x
        let dy = normalized.y - teachingData.observeTapTarget.y
        let distance = sqrt(dx * dx + dy * dy)

        if distance < teachingData.observeTapRadius {
            // Correct!
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                foundFeature = true
            }
        } else {
            // Wrong — show red flash
            lastTapPosition = normalized
            incorrectTaps += 1
            withAnimation(.easeOut(duration: 0.2)) {
                showWrongFlash = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation { showWrongFlash = false }
            }
            // Show hint after 2 wrong taps
            if incorrectTaps >= 2 && !showHint {
                withAnimation(.easeOut(duration: 0.3)) {
                    showHint = true
                }
            }
        }
    }

    private var birdQuestionSection: some View {
        VStack(spacing: 10) {
            HStack(alignment: .top, spacing: 10) {
                Image("BirdFrame00")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(RenaissanceColors.ochre.opacity(0.3), lineWidth: 1))

                VStack(alignment: .leading, spacing: 8) {
                    Text(teachingData.observeQuestion)
                        .font(.custom("EBGaramond-Regular", size: isLargeScreen ? 17 : 15))
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                        .fixedSize(horizontal: false, vertical: true)

                    if showHint && !foundFeature {
                        Text(teachingData.observeHint)
                            .font(.custom("EBGaramond-Italic", size: isLargeScreen ? 15 : 14))
                            .foregroundStyle(RenaissanceColors.warmBrown)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    if foundFeature {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(RenaissanceColors.sageGreen)
                            Text("Correct!")
                                .font(.custom("Cinzel-Bold", size: 13))
                                .foregroundStyle(RenaissanceColors.sageGreen)
                        }
                        .transition(.scale.combined(with: .opacity))

                        Text(teachingData.observeAnswer)
                            .font(.custom("EBGaramond-Regular", size: isLargeScreen ? 15 : 14))
                            .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.85))
                            .fixedSize(horizontal: false, vertical: true)
                            .transition(.opacity)
                    }
                }
            }

            if !foundFeature && incorrectTaps == 0 {
                Text("Tap on the sketch to identify the feature")
                    .font(.custom("EBGaramond-Italic", size: 13))
                    .foregroundStyle(RenaissanceColors.renaissanceBlue.opacity(0.7))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(RenaissanceColors.parchment)
                .borderCard(radius: 12)
        )
    }

    // MARK: - Step 2: Understand (Wolfram + Annotations)

    private var understandStep: some View {
        VStack(spacing: 16) {
            stepHeader(step: .understand, title: "Engineering Analysis", subtitle: "Understand the science behind the structure")

            // Wolfram geometry diagram
            if let geometry = wolframGeometry {
                WolframGeometryView(geometry: geometry, compact: false)
            }

            // Engineering annotations
            annotationCards

            continueButton {
                completeStep(.understand)
                advanceToStep(.plan)
            }

            skipTextButton
        }
    }

    private var annotationCards: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Key Engineering Features")
                .font(.custom("Cinzel-Bold", size: isLargeScreen ? 16 : 14))
                .foregroundStyle(RenaissanceColors.sepiaInk)
                .padding(.bottom, 2)

            ForEach(teachingData.engineeringAnnotations) { annotation in
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(RenaissanceColors.color(for: annotation.science).opacity(0.15))
                            .frame(width: 40, height: 40)
                        Image(systemName: annotation.icon)
                            .font(.system(size: 16))
                            .foregroundStyle(RenaissanceColors.color(for: annotation.science))
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(annotation.label)
                            .font(.custom("EBGaramond-Regular", size: isLargeScreen ? 16 : 14))
                            .foregroundStyle(RenaissanceColors.sepiaInk)
                            .fixedSize(horizontal: false, vertical: true)

                        Text(annotation.science.rawValue)
                            .font(.custom("EBGaramond-Italic", size: 12))
                            .foregroundStyle(RenaissanceColors.color(for: annotation.science))
                    }

                    Spacer()
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(RenaissanceColors.parchment)
                        .borderCard(radius: 8)
                )
            }
        }
    }

    // MARK: - Step 3: Plan (Grid Preview)

    private var planStep: some View {
        VStack(spacing: 16) {
            stepHeader(step: .plan, title: "Your Drawing Plan", subtitle: "Study the target floor plan before you draw")

            // Grid preview
            if let pianta = piantaData {
                gridPreview(pianta: pianta)
            }

            // Bird hint
            HStack(alignment: .top, spacing: 10) {
                Image("BirdFrame00")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(RenaissanceColors.ochre.opacity(0.3), lineWidth: 1))

                Text(teachingData.gridPreviewHint)
                    .font(.custom("EBGaramond-Regular", size: isLargeScreen ? 17 : 15))
                    .foregroundStyle(RenaissanceColors.sepiaInk)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(RenaissanceColors.parchment)
                    .borderCard(radius: 12)
            )

            // Begin Drawing button
            VStack(spacing: 12) {
                RenaissanceButton(title: "Begin Drawing") {
                    completeStep(.plan)
                    onComplete()
                }

                skipTextButton
            }
            .padding(.top, 4)
        }
    }

    private func gridPreview(pianta: PiantaPhaseData) -> some View {
        Canvas { context, size in
            let gridSize = pianta.gridSize
            let cellSize = min(size.width, size.height) / CGFloat(gridSize)
            let originX = (size.width - cellSize * CGFloat(gridSize)) / 2
            let originY = (size.height - cellSize * CGFloat(gridSize)) / 2

            // Grid lines
            for i in 0...gridSize {
                let x = originX + CGFloat(i) * cellSize
                let y = originY + CGFloat(i) * cellSize
                var vPath = Path()
                vPath.move(to: CGPoint(x: x, y: originY))
                vPath.addLine(to: CGPoint(x: x, y: originY + CGFloat(gridSize) * cellSize))
                context.stroke(vPath, with: .color(RenaissanceColors.sepiaInk.opacity(0.1)), lineWidth: 0.5)

                var hPath = Path()
                hPath.move(to: CGPoint(x: originX, y: y))
                hPath.addLine(to: CGPoint(x: originX + CGFloat(gridSize) * cellSize, y: y))
                context.stroke(hPath, with: .color(RenaissanceColors.sepiaInk.opacity(0.1)), lineWidth: 0.5)
            }

            // Target rooms as ghost outlines
            for room in pianta.targetRooms {
                if room.shape == .circle {
                    let cx = originX + CGFloat(room.origin.col) * cellSize
                    let cy = originY + CGFloat(room.origin.row) * cellSize
                    let r = CGFloat(room.width) / 2 * cellSize
                    let circleRect = CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2)
                    let circlePath = Path(ellipseIn: circleRect)
                    context.stroke(circlePath,
                                   with: .color(RenaissanceColors.renaissanceBlue.opacity(0.5)),
                                   style: StrokeStyle(lineWidth: 2, dash: [6, 4]))
                } else {
                    let rx = originX + CGFloat(room.origin.col) * cellSize
                    let ry = originY + CGFloat(room.origin.row) * cellSize
                    let rw = CGFloat(room.width) * cellSize
                    let rh = CGFloat(room.height) * cellSize
                    let rect = CGRect(x: rx, y: ry, width: rw, height: rh)
                    let rectPath = Path(rect)
                    context.stroke(rectPath,
                                   with: .color(RenaissanceColors.renaissanceBlue.opacity(0.5)),
                                   style: StrokeStyle(lineWidth: 2, dash: [6, 4]))
                }

                // Room label
                let labelX: CGFloat
                let labelY: CGFloat
                if room.shape == .circle {
                    labelX = originX + CGFloat(room.origin.col) * cellSize
                    labelY = originY + CGFloat(room.origin.row) * cellSize
                } else {
                    labelX = originX + CGFloat(room.origin.col) * cellSize + CGFloat(room.width) * cellSize / 2
                    labelY = originY + CGFloat(room.origin.row) * cellSize + CGFloat(room.height) * cellSize / 2
                }
                context.draw(
                    Text(room.label)
                        .font(.custom("EBGaramond-Italic", size: 12))
                        .foregroundStyle(RenaissanceColors.renaissanceBlue.opacity(0.7)),
                    at: CGPoint(x: labelX, y: labelY)
                )
            }

            // Target columns as dots
            for col in pianta.targetColumns {
                let cx = originX + CGFloat(col.col) * cellSize
                let cy = originY + CGFloat(col.row) * cellSize
                let dotSize: CGFloat = 8
                let dotRect = CGRect(x: cx - dotSize / 2, y: cy - dotSize / 2, width: dotSize, height: dotSize)
                context.fill(Path(ellipseIn: dotRect), with: .color(RenaissanceColors.ochre.opacity(0.6)))
            }
        }
        .frame(height: isLargeScreen ? 380 : 300)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(RenaissanceColors.parchment)
                .borderCard(radius: 12)
        )
    }

    // MARK: - Shared Components

    private func stepHeader(step: SketchTeachingStep, title: String, subtitle: String) -> some View {
        VStack(spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: step.iconName)
                    .font(.caption)
                    .foregroundStyle(RenaissanceColors.renaissanceBlue)
                Text("Step \(step.rawValue + 1): \(step.title)")
                    .font(.custom("EBGaramond-Regular", size: 14))
                    .foregroundStyle(RenaissanceColors.renaissanceBlue)
            }

            Text(title)
                .font(.custom("Cinzel-Bold", size: isLargeScreen ? 26 : 22))
                .foregroundStyle(RenaissanceColors.sepiaInk)

            Text(subtitle)
                .font(.custom("EBGaramond-Italic", size: isLargeScreen ? 16 : 14))
                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.6))
                .multilineTextAlignment(.center)
        }
    }

    private func continueButton(action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            HStack(spacing: 6) {
                Text("Continue")
                    .font(.custom("Cinzel-Bold", size: 15))
                Text("+\(florinsPerStep) florins")
                    .font(.custom("EBGaramond-Regular", size: 14))
                    .foregroundStyle(RenaissanceColors.ochre)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 28)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(RenaissanceColors.sageGreen)
            )
        }
        .buttonStyle(.plain)
    }

    private var skipTextButton: some View {
        Button {
            onSkip()
        } label: {
            Text("Skip to drawing")
                .font(.custom("EBGaramond-Regular", size: 13))
                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.4))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helpers

    private func findMuseumSketch() -> MuseumSketch? {
        let names = [challenge.buildingName, "Il \(challenge.buildingName)"]
        for name in names {
            if let match = MuseumSketchContent.sketches(for: name).first(where: { $0.id == teachingData.observeSketchID }) {
                return match
            }
        }
        return nil
    }

    private var wolframGeometry: BuildingGeometry? {
        BuildingGeometryContent.geometry(for: challenge.buildingName)
    }

    private var piantaData: PiantaPhaseData? {
        for phase in challenge.phases {
            if case .pianta(let data) = phase.phaseData {
                return data
            }
        }
        return nil
    }

    private func completeStep(_ step: SketchTeachingStep) {
        completedSteps.insert(step)
        onFlorinsEarned?(florinsPerStep)
    }

    private func advanceToStep(_ step: SketchTeachingStep) {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentStep = step
            resetStepState()
        }
    }

    private func resetStepState() {
        showHint = false
        foundFeature = false
        incorrectTaps = 0
        lastTapPosition = nil
        showWrongFlash = false
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
