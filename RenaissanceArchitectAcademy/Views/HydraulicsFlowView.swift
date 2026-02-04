import SwiftUI
import Pow

// Note: HydraulicsFlowData and FlowCheckpoint are defined in Challenge.swift

/// Interactive view for tracing water flow paths
struct HydraulicsFlowView: View {
    let data: HydraulicsFlowData
    let onComplete: (Bool) -> Void

    @State private var currentPath: [CGPoint] = []
    @State private var isDrawing = false
    @State private var hasSubmitted = false
    @State private var isCorrect = false
    @State private var passedCheckpoints: Set<UUID> = []
    @State private var showHint = false
    @State private var showSuccessEffect = false
    @State private var animateWater = false

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    private var isLargeScreen: Bool { horizontalSizeClass == .regular }

    private var canvasSize: CGSize {
        isLargeScreen ? CGSize(width: 500, height: 350) : CGSize(width: 320, height: 240)
    }

    var body: some View {
        VStack(spacing: isLargeScreen ? 24 : 16) {
            // Instructions
            Text("Trace the water flow path from start to end")
                .font(.custom("EBGaramond-Italic", size: isLargeScreen ? 18 : 14))
                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.8))

            // Drawing canvas
            drawingCanvas
                .changeEffect(
                    .spray(origin: UnitPoint(x: 0.5, y: 0.5)) {
                        Image(systemName: "drop.fill")
                            .foregroundStyle(RenaissanceColors.renaissanceBlue)
                    },
                    value: showSuccessEffect
                )

            // Legend
            legendView

            // Hint
            if let hint = data.hint, !hasSubmitted {
                hintSection(hint: hint)
            }

            // Buttons
            HStack(spacing: 16) {
                if !hasSubmitted {
                    // Clear button
                    Button {
                        clearPath()
                    } label: {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Clear")
                        }
                        .font(.custom("EBGaramond-Italic", size: 16))
                        .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))
                    }
                    .buttonStyle(.plain)
                    .disabled(currentPath.isEmpty)

                    // Check button
                    checkButton
                }
            }
        }
        .padding()
    }

    // MARK: - Drawing Canvas

    private var drawingCanvas: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 12)
                .fill(RenaissanceColors.parchment)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            hasSubmitted && isCorrect
                                ? RenaissanceColors.sageGreen
                                : RenaissanceColors.ochre.opacity(0.4),
                            lineWidth: hasSubmitted && isCorrect ? 3 : 2
                        )
                )

            // Background image if provided (shows prominently for students to draw on)
            if let imageName = data.backgroundImageName {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .opacity(0.85)
                    .padding(4)
            } else {
                // Blueprint grid only shown when no background image
                blueprintGrid
            }

            // Checkpoints
            ForEach(data.checkpoints) { checkpoint in
                checkpointView(checkpoint)
            }

            // Start point
            startEndMarker(at: data.startPoint, label: "START", color: RenaissanceColors.sageGreen)

            // End point
            startEndMarker(at: data.endPoint, label: "END", color: RenaissanceColors.terracotta)

            // User's drawn path
            if !currentPath.isEmpty {
                drawnPathView
            }

            // Animated water flow on success
            if hasSubmitted && isCorrect && animateWater {
                animatedWaterFlow
            }
        }
        .frame(width: canvasSize.width, height: canvasSize.height)
        .gesture(drawingGesture)
    }

    private var blueprintGrid: some View {
        GeometryReader { geo in
            Path { path in
                let spacing: CGFloat = 30

                // Vertical lines
                var x: CGFloat = 0
                while x < geo.size.width {
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: geo.size.height))
                    x += spacing
                }

                // Horizontal lines
                var y: CGFloat = 0
                while y < geo.size.height {
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: geo.size.width, y: y))
                    y += spacing
                }
            }
            .stroke(RenaissanceColors.blueprintBlue.opacity(0.15), lineWidth: 0.5)
        }
    }

    private func checkpointView(_ checkpoint: FlowCheckpoint) -> some View {
        let passed = passedCheckpoints.contains(checkpoint.id)

        return GeometryReader { geo in
            let x = checkpoint.position.x * geo.size.width
            let y = checkpoint.position.y * geo.size.height

            VStack(spacing: 4) {
                // Checkpoint circle
                Circle()
                    .fill(passed ? RenaissanceColors.renaissanceBlue.opacity(0.3) : RenaissanceColors.ochre.opacity(0.2))
                    .overlay(
                        Circle()
                            .stroke(
                                passed ? RenaissanceColors.renaissanceBlue : RenaissanceColors.ochre,
                                style: StrokeStyle(lineWidth: 2, dash: passed ? [] : [4, 4])
                            )
                    )
                    .frame(width: checkpoint.radius * geo.size.width * 2, height: checkpoint.radius * geo.size.width * 2)

                // Label
                Text(checkpoint.label)
                    .font(.custom("EBGaramond-Regular", size: isLargeScreen ? 12 : 10))
                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.8))
            }
            .position(x: x, y: y)
        }
    }

    private func startEndMarker(at position: CGPoint, label: String, color: Color) -> some View {
        GeometryReader { geo in
            let x = position.x * geo.size.width
            let y = position.y * geo.size.height

            VStack(spacing: 2) {
                Circle()
                    .fill(color)
                    .frame(width: 20, height: 20)
                    .overlay(
                        Image(systemName: label == "START" ? "drop.fill" : "flag.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(.white)
                    )

                Text(label)
                    .font(.custom("Cinzel-Bold", size: 10))
                    .foregroundStyle(color)
            }
            .position(x: x, y: y)
        }
    }

    private var drawnPathView: some View {
        GeometryReader { geo in
            Path { path in
                guard let first = currentPath.first else { return }
                let startX = first.x * geo.size.width
                let startY = first.y * geo.size.height
                path.move(to: CGPoint(x: startX, y: startY))

                for point in currentPath.dropFirst() {
                    let x = point.x * geo.size.width
                    let y = point.y * geo.size.height
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            .stroke(
                hasSubmitted
                    ? (isCorrect ? RenaissanceColors.renaissanceBlue : RenaissanceColors.errorRed)
                    : RenaissanceColors.renaissanceBlue,
                style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round)
            )
            .shadow(color: RenaissanceColors.renaissanceBlue.opacity(0.3), radius: 2)
        }
    }

    private var animatedWaterFlow: some View {
        GeometryReader { geo in
            ForEach(0..<5, id: \.self) { index in
                Circle()
                    .fill(RenaissanceColors.renaissanceBlue.opacity(0.6))
                    .frame(width: 8, height: 8)
                    .modifier(WaterDropAnimation(
                        path: currentPath,
                        canvasSize: geo.size,
                        delay: Double(index) * 0.2
                    ))
            }
        }
    }

    // MARK: - Legend

    private var legendView: some View {
        HStack(spacing: 20) {
            legendItem(color: RenaissanceColors.sageGreen, label: "Start")
            legendItem(color: RenaissanceColors.terracotta, label: "End")
            legendItem(color: RenaissanceColors.ochre, label: "Checkpoint", isDashed: true)
        }
        .font(.custom("EBGaramond-Regular", size: 12))
    }

    private func legendItem(color: Color, label: String, isDashed: Bool = false) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(isDashed ? color.opacity(0.2) : color)
                .overlay(
                    Circle()
                        .stroke(color, style: StrokeStyle(lineWidth: 1.5, dash: isDashed ? [3, 3] : []))
                )
                .frame(width: 12, height: 12)
            Text(label)
                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))
        }
    }

    // MARK: - Hint

    private func hintSection(hint: String) -> some View {
        VStack(spacing: 8) {
            Button {
                withAnimation { showHint.toggle() }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: showHint ? "lightbulb.fill" : "lightbulb")
                        .foregroundStyle(RenaissanceColors.highlightAmber)
                    Text(showHint ? "Hide Hint" : "Show Hint")
                        .font(.custom("EBGaramond-Italic", size: 14))
                        .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))
                }
            }
            .buttonStyle(.plain)

            if showHint {
                Text(hint)
                    .font(.custom("EBGaramond-Italic", size: isLargeScreen ? 14 : 12))
                    .foregroundStyle(RenaissanceColors.warmBrown)
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(RenaissanceColors.highlightAmber.opacity(0.1))
                    )
                    .transition(.opacity)
            }
        }
    }

    // MARK: - Check Button

    private var checkButton: some View {
        let canCheck = !currentPath.isEmpty && currentPath.count > 5

        return Button {
            checkPath()
        } label: {
            HStack {
                Image(systemName: "checkmark.seal")
                Text("Check Flow")
            }
            .font(.custom("EBGaramond-Italic", size: 18))
            .tracking(2)
            .foregroundStyle(canCheck ? RenaissanceColors.sepiaInk : RenaissanceColors.stoneGray)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(RenaissanceColors.parchment.opacity(canCheck ? 0.9 : 0.5))
            .overlay(
                ZStack {
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(RenaissanceColors.sepiaInk.opacity(canCheck ? 0.6 : 0.3), lineWidth: 1)
                        .padding(2)
                    RoundedRectangle(cornerRadius: 1)
                        .stroke(RenaissanceColors.sepiaInk.opacity(canCheck ? 0.35 : 0.15), lineWidth: 0.5)
                        .padding(5)
                }
            )
        }
        .buttonStyle(.plain)
        .disabled(!canCheck)
    }

    // MARK: - Gestures

    private var drawingGesture: some Gesture {
        DragGesture(minimumDistance: 1)
            .onChanged { value in
                guard !hasSubmitted else { return }

                let location = value.location
                let bounds = canvasSize

                // Normalize to 0-1
                let normalizedX = max(0, min(1, location.x / bounds.width))
                let normalizedY = max(0, min(1, location.y / bounds.height))
                let normalizedPoint = CGPoint(x: normalizedX, y: normalizedY)

                if !isDrawing {
                    isDrawing = true
                    currentPath = [normalizedPoint]
                } else {
                    currentPath.append(normalizedPoint)
                }

                // Check if we passed through any checkpoint
                checkCheckpoints(point: normalizedPoint)
            }
            .onEnded { _ in
                isDrawing = false
            }
    }

    // MARK: - Logic

    private func checkCheckpoints(point: CGPoint) {
        for checkpoint in data.checkpoints {
            let dx = point.x - checkpoint.position.x
            let dy = point.y - checkpoint.position.y
            let distance = sqrt(dx * dx + dy * dy)

            if distance < checkpoint.radius {
                passedCheckpoints.insert(checkpoint.id)
            }
        }
    }

    private func clearPath() {
        currentPath = []
        passedCheckpoints = []
    }

    private func checkPath() {
        // Check if path passes near start and end
        guard let first = currentPath.first, let last = currentPath.last else {
            isCorrect = false
            hasSubmitted = true
            onComplete(false)
            return
        }

        let startDist = distance(from: first, to: data.startPoint)
        let endDist = distance(from: last, to: data.endPoint)

        // All checkpoints must be passed, start near start point, end near end point
        let allCheckpointsPassed = data.checkpoints.allSatisfy { passedCheckpoints.contains($0.id) }
        let startsCorrectly = startDist < 0.15
        let endsCorrectly = endDist < 0.15

        isCorrect = allCheckpointsPassed && startsCorrectly && endsCorrectly

        withAnimation {
            hasSubmitted = true
        }

        if isCorrect {
            // Trigger celebrations
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                showSuccessEffect.toggle()
                animateWater = true
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            onComplete(isCorrect)
        }
    }

    private func distance(from p1: CGPoint, to p2: CGPoint) -> CGFloat {
        let dx = p1.x - p2.x
        let dy = p1.y - p2.y
        return sqrt(dx * dx + dy * dy)
    }
}

// MARK: - Water Drop Animation

struct WaterDropAnimation: ViewModifier {
    let path: [CGPoint]
    let canvasSize: CGSize
    let delay: Double

    @State private var progress: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .position(positionAlongPath())
            .onAppear {
                withAnimation(.linear(duration: 2).repeatForever(autoreverses: false).delay(delay)) {
                    progress = 1
                }
            }
    }

    private func positionAlongPath() -> CGPoint {
        guard !path.isEmpty else { return .zero }

        let index = Int(CGFloat(path.count - 1) * progress)
        let safeIndex = min(max(0, index), path.count - 1)
        let point = path[safeIndex]

        return CGPoint(
            x: point.x * canvasSize.width,
            y: point.y * canvasSize.height
        )
    }
}

// MARK: - Preview

#Preview("Aqueduct Flow") {
    ScrollView {
        HydraulicsFlowView(
            data: HydraulicsFlowData(
                backgroundImageName: nil,
                diagramDescription: "Trace how water flows through a Roman aqueduct system",
                checkpoints: [
                    FlowCheckpoint(position: CGPoint(x: 0.3, y: 0.3), label: "Reservoir"),
                    FlowCheckpoint(position: CGPoint(x: 0.5, y: 0.5), label: "Settling Tank"),
                    FlowCheckpoint(position: CGPoint(x: 0.7, y: 0.4), label: "Distribution")
                ],
                startPoint: CGPoint(x: 0.1, y: 0.2),
                endPoint: CGPoint(x: 0.9, y: 0.7),
                hint: "Water flows downhill using gravity. Connect all the checkpoints in order."
            ),
            onComplete: { correct in
                print("Flow path is \(correct ? "correct" : "incorrect")")
            }
        )
    }
    .background(RenaissanceColors.parchment)
}
