import SwiftUI

/// Phase 2: Alzato (Elevation) — Player shapes architectural elements with Bézier curves
/// Inspired by Old Man's Journey terrain deformation: drag control points to shape arches, domes, columns
struct AlzatoCanvasView: View {

    let phaseData: AlzatoPhaseData
    let onComplete: (Set<SketchingPhaseType>) -> Void

    // MARK: - Element State

    /// Current control points for each element (keyed by element.id)
    @State private var elementPoints: [String: [CGPoint]] = [:]
    /// Which elements have been validated correct and locked
    @State private var lockedElements: Set<String> = []
    /// Whether the player has tapped "Check"
    @State private var hasChecked = false
    /// Elements that were wrong on last check (flash red)
    @State private var wrongElements: Set<String> = []

    // MARK: - Bird Companion

    @State private var birdPosition: CGPoint = .zero
    @State private var birdBounce: CGFloat = 0
    @State private var showBirdSpeech: String? = nil
    @State private var birdFacingRight = true

    // MARK: - Hint System

    @State private var hintLevel: Int = 0  // 0=none, 1=labels, 2=ghost targets, 3=snap assist

    // MARK: - Completion

    @State private var showSuccess = false

    var body: some View {
        GeometryReader { geo in
            let canvasW = geo.size.width
            let canvasH = geo.size.height * 0.78  // leave room for controls below

            ZStack(alignment: .top) {
                // Blueprint grid background
                blueprintGrid(size: CGSize(width: canvasW, height: canvasH))

                // Ground line
                Path { p in
                    let groundY = canvasH * 0.88
                    p.move(to: CGPoint(x: 0, y: groundY))
                    p.addLine(to: CGPoint(x: canvasW, y: groundY))
                }
                .stroke(Color.brown.opacity(0.3), lineWidth: 1.5)
                .frame(width: canvasW, height: canvasH)

                // Elevation elements — each is a BezierDragShape
                ForEach(phaseData.elements) { element in
                    let isLocked = lockedElements.contains(element.id)
                    let isWrong = wrongElements.contains(element.id)
                    let showTarget = hintLevel >= 2

                    VStack(spacing: 0) {
                        // Element label
                        Text(element.label)
                            .font(.custom("Cinzel-Bold", size: 10))
                            .tracking(0.5)
                            .foregroundStyle(
                                isLocked ? RenaissanceColors.sageGreen :
                                isWrong ? RenaissanceColors.errorRed :
                                RenaissanceColors.sepiaInk.opacity(0.5)
                            )

                        // The draggable curve
                        BezierDragShape(
                            element: element,
                            currentPoints: bindingForElement(element.id),
                            showTarget: showTarget,
                            isLocked: isLocked
                        )
                        .frame(
                            width: canvasW * element.size.width,
                            height: canvasH * element.size.height
                        )
                        .overlay(
                            // Wrong flash
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(RenaissanceColors.errorRed, lineWidth: 2)
                                .opacity(isWrong ? 1 : 0)
                        )
                    }
                    .position(
                        x: canvasW * element.position.x,
                        y: canvasH * element.position.y
                    )
                }

                // Bird companion
                birdView
                    .position(
                        x: canvasW * 0.85,
                        y: canvasH * 0.15 + birdBounce
                    )

                // Controls at bottom
                VStack(spacing: 8) {
                    Spacer()

                    // Educational text
                    if let speech = showBirdSpeech {
                        Text(speech)
                            .font(.custom("EBGaramond-Regular", size: 13))
                            .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            .transition(.opacity)
                    }

                    HStack(spacing: 16) {
                        // Hint button
                        Button {
                            withAnimation { hintLevel = min(hintLevel + 1, 3) }
                            updateBirdSpeech()
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "lightbulb.fill")
                                    .font(.system(size: 12))
                                Text("Hint")
                                    .font(.custom("EBGaramond-SemiBold", size: 13))
                            }
                            .foregroundStyle(RenaissanceColors.ochre)
                            .padding(.horizontal, 14).padding(.vertical, 8)
                            .background(RenaissanceColors.ochre.opacity(0.1))
                            .cornerRadius(8)
                        }
                        .buttonStyle(.plain)

                        // Check button
                        if !showSuccess {
                            Button {
                                validateAll()
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "checkmark.circle")
                                        .font(.system(size: 14))
                                    Text("Check Elevation")
                                        .font(.custom("EBGaramond-SemiBold", size: 14))
                                }
                                .foregroundStyle(.white)
                                .padding(.horizontal, 18).padding(.vertical, 10)
                                .background(RenaissanceColors.renaissanceBlue)
                                .cornerRadius(10)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.bottom, 12)
                }
                .frame(width: canvasW, height: geo.size.height)

                // Success overlay
                if showSuccess {
                    successOverlay(width: canvasW)
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                }
            }
        }
        .onAppear { initializePoints() }
        .onAppear { startBirdBounce() }
        .onAppear {
            showBirdSpeech = "Shape each element to match the \(phaseData.requiredOrder.rawValue.capitalized) order. Drag the golden handles!"
        }
    }

    // MARK: - Initialization

    private func initializePoints() {
        for element in phaseData.elements {
            elementPoints[element.id] = element.initialPoints
        }
    }

    // MARK: - Binding Helper

    private func bindingForElement(_ id: String) -> Binding<[CGPoint]> {
        Binding(
            get: { elementPoints[id] ?? [] },
            set: { elementPoints[id] = $0 }
        )
    }

    // MARK: - Validation

    private func validateAll() {
        hasChecked = true
        wrongElements.removeAll()
        var newlyLocked: [String] = []

        for element in phaseData.elements {
            guard !lockedElements.contains(element.id) else { continue }
            guard let points = elementPoints[element.id] else { continue }

            // Check if close enough to target
            let totalDist = zip(points, element.targetPoints).reduce(CGFloat(0)) { sum, pair in
                sum + hypot(pair.0.x - pair.1.x, pair.0.y - pair.1.y)
            }
            let avgDist = totalDist / CGFloat(points.count)

            if avgDist <= element.tolerance {
                newlyLocked.append(element.id)
                // Snap to exact target
                elementPoints[element.id] = element.targetPoints
            } else {
                wrongElements.insert(element.id)
            }
        }

        // Animate locking
        withAnimation(.spring(response: 0.4)) {
            for id in newlyLocked {
                lockedElements.insert(id)
            }
        }

        // Sound feedback
        if !newlyLocked.isEmpty {
            SoundManager.shared.play(.correctChime)
            HapticsManager.shared.play(.correctAnswer)
        }
        if !wrongElements.isEmpty {
            SoundManager.shared.play(.wrongBuzz)
            // Clear wrong flash after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation { wrongElements.removeAll() }
            }
        }

        // Update bird speech
        let correctCount = lockedElements.count
        let totalCount = phaseData.elements.count

        if correctCount == totalCount {
            // All correct — complete!
            withAnimation(.spring(response: 0.5).delay(0.3)) {
                showSuccess = true
            }
            showBirdSpeech = "Perfect elevation! Every element matches the \(phaseData.requiredOrder.rawValue.capitalized) order."
        } else if !newlyLocked.isEmpty {
            let remaining = totalCount - correctCount
            showBirdSpeech = "\(newlyLocked.count) correct! \(remaining) more to go."
        } else {
            showBirdSpeech = "Not quite — keep adjusting the curves. Try the hint button!"
            if hintLevel < 2 { hintLevel = max(hintLevel, 1) }
        }
    }

    // MARK: - Bird

    @ViewBuilder
    private var birdView: some View {
        VStack(spacing: 2) {
            Image("BirdFrame00")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 44)
                .scaleEffect(x: birdFacingRight ? 1 : -1, y: 1)
        }
    }

    private func startBirdBounce() {
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            birdBounce = -6
        }
    }

    private func updateBirdSpeech() {
        switch hintLevel {
        case 1:
            showBirdSpeech = "Look at the element labels — each tells you what shape to make."
        case 2:
            showBirdSpeech = "See the green dashed lines? Those are the target shapes. Match them!"
        case 3:
            showBirdSpeech = "Drag each handle close to the green curve. You're almost there!"
        default:
            break
        }
    }

    // MARK: - Success Overlay

    @ViewBuilder
    private func successOverlay(width: CGFloat) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 40))
                .foregroundStyle(RenaissanceColors.sageGreen)

            Text("Elevation Complete!")
                .font(.custom("Cinzel-Bold", size: 20))
                .foregroundStyle(RenaissanceColors.sepiaInk)

            Text(phaseData.educationalText)
                .font(.custom("EBGaramond-Regular", size: 14))
                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Button {
                onComplete([.alzato])
            } label: {
                Text("Continue")
                    .font(.custom("EBGaramond-SemiBold", size: 16))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24).padding(.vertical, 12)
                    .background(RenaissanceColors.sageGreen)
                    .cornerRadius(10)
            }
            .buttonStyle(.plain)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(RenaissanceColors.parchment)
                .shadow(color: .black.opacity(0.15), radius: 12, y: 4)
        )
        .frame(maxWidth: width * 0.7)
        .position(x: width * 0.5, y: 200)
    }

    // MARK: - Blueprint Grid

    @ViewBuilder
    private func blueprintGrid(size: CGSize) -> some View {
        Canvas { context, canvasSize in
            let spacing: CGFloat = 20
            let color = Color.brown.opacity(0.06)
            for x in stride(from: CGFloat(0), through: canvasSize.width, by: spacing) {
                var path = Path()
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: canvasSize.height))
                context.stroke(path, with: .color(color), lineWidth: 0.5)
            }
            for y in stride(from: CGFloat(0), through: canvasSize.height, by: spacing) {
                var path = Path()
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: canvasSize.width, y: y))
                context.stroke(path, with: .color(color), lineWidth: 0.5)
            }
        }
        .frame(width: size.width, height: size.height)
    }
}
