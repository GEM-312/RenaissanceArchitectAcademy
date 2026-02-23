import SwiftUI
import Pow

/// Phase 1: Pianta (Floor Plan) Canvas
/// Squared grid where players draw walls, place columns, and create rooms
struct PiantaCanvasView: View {
    let phaseData: PiantaPhaseData
    let onComplete: (Set<SketchingPhaseType>) -> Void

    // MARK: - State

    @State private var placedWalls: [WallSegment] = []
    @State private var placedColumns: [ColumnPlacement] = []
    @State private var placedCircles: [CirclePlacement] = []
    @State private var selectedTool: SketchingTool = .wall
    @State private var undoStack: [UndoAction] = []

    // Wall/circle drawing state
    @State private var dragStart: GridCoord? = nil
    @State private var dragCurrent: GridCoord? = nil
    @State private var isDragging = false
    @State private var hasPlacedFirstCircle = false

    // Room detection
    @State private var detectedRooms: [DetectedRoom] = []

    // Validation
    @State private var validationResult: ValidationResult? = nil
    @State private var showSuccessEffect = false
    @State private var showCompletion = false

    // Hint system
    @State private var hintLevel = 0  // 0=none, 1=area highlight, 2=dotted outline, 3=guide lines
    @State private var hintTargetIndex = 0  // Which target room the bird is pointing at

    // Bird companion state
    @State private var birdPosition: CGPoint = .zero   // Bird position on canvas (in points)
    @State private var birdRestPosition: CGPoint = .zero // Where bird sits when idle
    @State private var birdBounce: CGFloat = 0
    @State private var birdIsFlying = false             // true = flying animation, false = sitting
    @State private var birdScale: CGFloat = 1.0
    @State private var showBirdSpeech: String? = nil    // Speech bubble text
    @State private var birdFacingRight = true

    // Encouragement tracking
    @State private var hasPlacedFirstWall = false
    @State private var hasPlacedFirstColumn = false
    @State private var celebratedRooms: Set<String> = []

    // Canvas geometry (for bird positioning)
    @State private var canvasOriginXStored: CGFloat = 0
    @State private var canvasSizeStored: CGFloat = 300

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    private var isLargeScreen: Bool { horizontalSizeClass == .regular }

    // MARK: - Layout

    private var gridSize: Int { phaseData.gridSize }

    var body: some View {
        VStack(spacing: 16) {
            // Header
            headerView

            // Instructions
            Text(phaseData.hint ?? "Draw the walls of the building on the grid below.")
                .font(.custom("Mulish-Light", size: isLargeScreen ? 16 : 14, relativeTo: .body))
                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            // Canvas + Bird overlay
            GeometryReader { geo in
                let canvasSize = min(geo.size.width - 32, geo.size.height - 80)
                let cellSize = canvasSize / CGFloat(gridSize)
                let canvasOriginX = (geo.size.width - canvasSize) / 2

                ZStack(alignment: .topLeading) {
                    // Main canvas
                    ZStack {
                        // Grid background
                        gridBackground(cellSize: cellSize, canvasSize: canvasSize)

                        // Hint level 1: soft area highlight on target rooms
                        if hintLevel >= 1 {
                            hintAreaHighlight(cellSize: cellSize)
                        }

                        // Hint level 2+: dotted outlines
                        if hintLevel >= 2 {
                            hintOverlay(cellSize: cellSize)
                        }

                        // Hint level 3: column position markers
                        if hintLevel >= 3 {
                            hintColumnMarkers(cellSize: cellSize)
                        }

                        // Placed walls
                        ForEach(placedWalls) { wall in
                            wallPath(wall, cellSize: cellSize)
                        }

                        // Placed circles
                        ForEach(placedCircles) { circle in
                            circleShape(circle, cellSize: cellSize)
                        }

                        // Wall preview while dragging
                        if isDragging, let start = dragStart, let current = dragCurrent {
                            if selectedTool == .circleTool {
                                circlePreview(center: start, edge: current, cellSize: cellSize)
                            } else {
                                wallPreviewPath(from: start, to: current, cellSize: cellSize)
                            }
                        }

                        // Placed columns
                        ForEach(placedColumns) { col in
                            columnMarker(col, cellSize: cellSize)
                        }

                        // Room labels
                        ForEach(detectedRooms) { room in
                            roomLabel(room, cellSize: cellSize)
                        }

                        // Validation highlights
                        if let result = validationResult {
                            validationOverlay(result, cellSize: cellSize)
                        }
                    }
                    .frame(width: canvasSize, height: canvasSize)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.5))
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(RenaissanceColors.sepiaInk.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .contentShape(Rectangle())
                    .gesture(canvasGesture(cellSize: cellSize))
                    .position(x: geo.size.width / 2, y: canvasSize / 2)

                    // Bird companion overlay
                    birdOverlay(canvasSize: canvasSize, cellSize: cellSize, canvasOriginX: canvasOriginX)
                }
                .frame(maxWidth: .infinity)
                .changeEffect(
                    .spray(origin: UnitPoint(x: 0.5, y: 0.5)) {
                        Image(systemName: "sparkle")
                            .foregroundStyle(RenaissanceColors.goldSuccess)
                    },
                    value: showSuccessEffect
                )
                .onAppear {
                    // Store canvas geometry for bird positioning
                    canvasOriginXStored = canvasOriginX
                    canvasSizeStored = canvasSize

                    // Position bird at rest (top-right corner of canvas)
                    let restX = canvasOriginX + canvasSize + 10
                    let restY: CGFloat = 20
                    birdRestPosition = CGPoint(x: restX, y: restY)
                    birdPosition = birdRestPosition
                    startBirdIdleBounce()
                }
            }

            // Room info bar
            roomInfoBar

            // Toolbar
            SketchingToolbarView(selectedTool: $selectedTool, onUndo: undoLast)

            // Validation feedback
            if let result = validationResult, !result.isComplete {
                validationFeedbackView(result)
            }

            // Check Plan button
            RenaissanceButton(title: "Check Plan") {
                validatePlan()
            }
            .padding(.horizontal, 40)
        }
        .padding()
    }

    // MARK: - Validation Feedback

    private func validationFeedbackView(_ result: ValidationResult) -> some View {
        VStack(spacing: 6) {
            // Room-by-room status
            ForEach(result.roomResults) { roomResult in
                HStack(spacing: 6) {
                    Image(systemName: roomResult.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundStyle(roomResult.isCorrect ? RenaissanceColors.sageGreen : RenaissanceColors.errorRed)
                        .font(.caption)
                    Text(roomResult.room.label)
                        .font(.custom("Mulish-Light", size: 13, relativeTo: .caption))
                    Spacer()
                    if !roomResult.isCorrect {
                        if !roomResult.isDetected {
                            Text(roomResult.room.shape == .circle ? "Draw the circle" : "Draw the walls")
                                .font(.custom("Mulish-Light", size: 11, relativeTo: .caption2))
                                .foregroundStyle(RenaissanceColors.errorRed)
                        } else {
                            Text(roomResult.room.shape == .circle ? "Wrong position or size" : "Check proportions")
                                .font(.custom("Mulish-Light", size: 11, relativeTo: .caption2))
                                .foregroundStyle(RenaissanceColors.errorRed)
                        }
                    }
                }
            }

            // Neatness warning
            if let feedback = result.neatnessFeedback {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                        .font(.caption)
                    Text(feedback)
                        .font(.custom("Mulish-Light", size: 12, relativeTo: .caption))
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                }
            }

            // Column status
            if result.columnsTotal > 0 {
                HStack(spacing: 6) {
                    Image(systemName: result.columnsCorrect >= result.columnsTotal - 1 ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundStyle(result.columnsCorrect >= result.columnsTotal - 1 ? RenaissanceColors.sageGreen : RenaissanceColors.errorRed)
                        .font(.caption)
                    Text("Columns: \(result.columnsCorrect)/\(result.columnsTotal)")
                        .font(.custom("Mulish-Light", size: 13, relativeTo: .caption))
                    Spacer()
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(RenaissanceColors.parchment.opacity(0.95))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(RenaissanceColors.errorRed.opacity(0.2), lineWidth: 1)
                )
        )
        .padding(.horizontal)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    // MARK: - Header

    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Pianta: Floor Plan")
                    .font(.custom("Cinzel-Regular", size: isLargeScreen ? 22 : 18, relativeTo: .title3))
                    .foregroundStyle(RenaissanceColors.sepiaInk)

                HStack(spacing: 4) {
                    ForEach(phaseData.proportionalRatios, id: \.displayString) { ratio in
                        Text("Ratio \(ratio.displayString)")
                            .font(.custom("Mulish-Light", size: 12, relativeTo: .caption2))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(
                                Capsule()
                                    .fill(RenaissanceColors.renaissanceBlue.opacity(0.12))
                            )
                            .foregroundStyle(RenaissanceColors.sepiaInk)
                    }
                }
            }

            Spacer()

            // Hint button — asks the bird for help
            Button {
                triggerBirdHint()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "lightbulb")
                        .font(.body)
                    if hintLevel == 0 {
                        Text("Ask Bird")
                            .font(.custom("Mulish-Light", size: 12, relativeTo: .caption2))
                    } else {
                        Text("More help")
                            .font(.custom("Mulish-Light", size: 12, relativeTo: .caption2))
                    }
                }
                .foregroundStyle(RenaissanceColors.sepiaInk)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(RenaissanceColors.ochre.opacity(0.12))
                        .overlay(
                            Capsule()
                                .stroke(RenaissanceColors.ochre.opacity(0.3), lineWidth: 1)
                        )
                )
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Grid

    private func gridBackground(cellSize: CGFloat, canvasSize: CGFloat) -> some View {
        Canvas { context, size in
            // Minor grid lines
            for i in 0...gridSize {
                let pos = CGFloat(i) * cellSize

                // Vertical
                var vPath = Path()
                vPath.move(to: CGPoint(x: pos, y: 0))
                vPath.addLine(to: CGPoint(x: pos, y: canvasSize))
                context.stroke(vPath, with: .color(RenaissanceColors.blueprintBlue.opacity(0.15)), lineWidth: 0.5)

                // Horizontal
                var hPath = Path()
                hPath.move(to: CGPoint(x: 0, y: pos))
                hPath.addLine(to: CGPoint(x: canvasSize, y: pos))
                context.stroke(hPath, with: .color(RenaissanceColors.blueprintBlue.opacity(0.15)), lineWidth: 0.5)
            }

            // Major grid lines (every 4 cells)
            for i in stride(from: 0, through: gridSize, by: 4) {
                let pos = CGFloat(i) * cellSize

                var vPath = Path()
                vPath.move(to: CGPoint(x: pos, y: 0))
                vPath.addLine(to: CGPoint(x: pos, y: canvasSize))
                context.stroke(vPath, with: .color(RenaissanceColors.blueprintBlue.opacity(0.3)), lineWidth: 0.5)

                var hPath = Path()
                hPath.move(to: CGPoint(x: 0, y: pos))
                hPath.addLine(to: CGPoint(x: canvasSize, y: pos))
                context.stroke(hPath, with: .color(RenaissanceColors.blueprintBlue.opacity(0.3)), lineWidth: 0.5)
            }

            // Grid intersection dots
            for row in 0...gridSize {
                for col in 0...gridSize {
                    let x = CGFloat(col) * cellSize
                    let y = CGFloat(row) * cellSize
                    let dotRect = CGRect(x: x - 1.5, y: y - 1.5, width: 3, height: 3)
                    context.fill(Path(ellipseIn: dotRect), with: .color(RenaissanceColors.blueprintBlue.opacity(0.25)))
                }
            }
        }
    }

    // MARK: - Bird Companion Overlay

    private func birdOverlay(canvasSize: CGFloat, cellSize: CGFloat, canvasOriginX: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            // Bird character
            BirdCharacter(isSitting: !birdIsFlying)
                .frame(width: 80, height: 80)
                .scaleEffect(x: birdFacingRight ? birdScale : -birdScale, y: birdScale)
                .offset(y: birdBounce)
                .position(birdPosition)
                .onTapGesture {
                    triggerBirdHint()
                }
                .animation(.spring(response: 0.5, dampingFraction: 0.7), value: birdPosition)
                .animation(.easeInOut(duration: 0.2), value: birdScale)

            // Speech bubble
            if let speech = showBirdSpeech {
                birdSpeechBubble(text: speech)
                    .position(x: birdPosition.x, y: birdPosition.y - 60)
                    .transition(.scale.combined(with: .opacity))
                    .allowsHitTesting(false)
            }
        }
        .allowsHitTesting(true)
    }

    private func birdSpeechBubble(text: String) -> some View {
        Text(text)
            .font(.custom("Mulish-Light", size: 11, relativeTo: .caption2))
            .foregroundStyle(RenaissanceColors.sepiaInk)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(RenaissanceColors.parchment)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(RenaissanceColors.ochre.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.08), radius: 3, y: 1)
            )
            .fixedSize()
    }

    // MARK: - Bird Animations

    private func startBirdIdleBounce() {
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            birdBounce = -6
        }
    }

    private func birdCelebrate() {
        // Quick excited jump
        withAnimation(.spring(response: 0.15, dampingFraction: 0.3)) {
            birdBounce = -25
            birdScale = 1.15
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                birdBounce = 0
                birdScale = 1.0
            }
            startBirdIdleBounce()
        }
        showBirdSpeechBriefly("Perfect ratio!")
    }

    private func birdEncourage(_ message: String) {
        // Small bounce
        withAnimation(.spring(response: 0.2, dampingFraction: 0.4)) {
            birdBounce = -15
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                birdBounce = 0
            }
            startBirdIdleBounce()
        }
        showBirdSpeechBriefly(message)
    }

    private func showBirdSpeechBriefly(_ text: String) {
        withAnimation(.spring(response: 0.2)) {
            showBirdSpeech = text
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeOut(duration: 0.3)) {
                if showBirdSpeech == text {
                    showBirdSpeech = nil
                }
            }
        }
    }

    // MARK: - Bird Hint System

    private func triggerBirdHint() {
        // Find the next un-drawn target room
        let nextTarget = findNextHintTarget()

        hintLevel = min(hintLevel + 1, 3)

        switch hintLevel {
        case 1:
            // Level 1: Bird flies to the general area of next target room
            if let target = nextTarget {
                flyBirdToRoom(target)
                let speechTexts = [
                    "Try drawing here!",
                    "This area needs walls.",
                    "Start with this room!",
                    "The \(target.label) goes here."
                ]
                showBirdSpeechBriefly(speechTexts[hintTargetIndex % speechTexts.count])
            } else {
                birdEncourage("Looking good!")
            }

        case 2:
            // Level 2: Dotted outlines appear + bird speech with ratio
            if let target = nextTarget {
                flyBirdToRoom(target)
                if let ratio = target.requiredRatio {
                    showBirdSpeechBriefly("Ratio \(ratio.displayString) — \(target.width)x\(target.height) cells")
                } else {
                    showBirdSpeechBriefly("Draw the \(target.label) outline!")
                }
            }

        case 3:
            // Level 3: Full guide lines stay visible + column markers
            if let target = nextTarget {
                flyBirdToRoom(target)
                showBirdSpeechBriefly("Follow the guide lines!")
            } else if !phaseData.targetColumns.isEmpty {
                showBirdSpeechBriefly("Don't forget the columns!")
            }

        default:
            break
        }
    }

    private func findNextHintTarget() -> RoomDefinition? {
        // Find the first target room that hasn't been correctly drawn yet
        for (index, target) in phaseData.targetRooms.enumerated() {
            let detected = detectedRooms.first { $0.label == target.label }
            if detected == nil || detected?.matchesTarget == false {
                hintTargetIndex = index
                return target
            }
        }
        return nil
    }

    private func flyBirdToRoom(_ target: RoomDefinition) {
        // Room center in normalized coords (0-1 within grid)
        let normX = CGFloat(target.origin.col + target.width / 2) / CGFloat(gridSize)
        let normY = CGFloat(target.origin.row) / CGFloat(gridSize)

        // Canvas top-left in the ZStack is at (canvasOriginXStored, 0)
        // since the canvas is positioned at (containerWidth/2, canvasSize/2)
        // and has frame (canvasSize, canvasSize)
        let flyX = canvasOriginXStored + normX * canvasSizeStored
        let flyY = normY * canvasSizeStored - 30  // offset above the room

        birdIsFlying = true
        birdFacingRight = flyX > birdPosition.x

        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            birdPosition = CGPoint(x: max(40, flyX), y: max(20, flyY))
        }

        // Land after arriving
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            birdIsFlying = false
            startBirdIdleBounce()
        }

        // Return to rest after a while
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            returnBirdToRest()
        }
    }

    private func returnBirdToRest() {
        birdIsFlying = true
        birdFacingRight = true
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            birdPosition = birdRestPosition
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            birdIsFlying = false
            startBirdIdleBounce()
        }
    }

    // MARK: - Hint Overlays

    /// Level 1: Soft colored area highlight on target rooms
    private func hintAreaHighlight(cellSize: CGFloat) -> some View {
        ForEach(phaseData.targetRooms) { room in
            let isDetected = detectedRooms.contains { $0.label == room.label && $0.matchesTarget }

            if !isDetected {
                if room.shape == .circle {
                    let cx = CGFloat(room.origin.col) * cellSize
                    let cy = CGFloat(room.origin.row) * cellSize
                    let diameter = CGFloat(room.width) * cellSize
                    Circle()
                        .fill(RenaissanceColors.ochre.opacity(0.06))
                        .frame(width: diameter, height: diameter)
                        .position(x: cx, y: cy)
                        .allowsHitTesting(false)
                } else {
                    let x = CGFloat(room.origin.col) * cellSize
                    let y = CGFloat(room.origin.row) * cellSize
                    let w = CGFloat(room.width) * cellSize
                    let h = CGFloat(room.height) * cellSize
                    Rectangle()
                        .fill(RenaissanceColors.ochre.opacity(0.06))
                        .frame(width: w, height: h)
                        .position(x: x + w / 2, y: y + h / 2)
                        .allowsHitTesting(false)
                }
            }
        }
    }

    /// Level 2: Dotted outlines for target rooms
    private func hintOverlay(cellSize: CGFloat) -> some View {
        ForEach(phaseData.targetRooms) { room in
            let isDetected = detectedRooms.contains { $0.label == room.label && $0.matchesTarget }

            if !isDetected {
                if room.shape == .circle {
                    let cx = CGFloat(room.origin.col) * cellSize
                    let cy = CGFloat(room.origin.row) * cellSize
                    let diameter = CGFloat(room.width) * cellSize
                    ZStack {
                        Circle()
                            .stroke(
                                RenaissanceColors.ochre.opacity(hintLevel >= 3 ? 0.5 : 0.25),
                                style: StrokeStyle(lineWidth: hintLevel >= 3 ? 2 : 1, dash: [6, 4])
                            )
                        VStack(spacing: 2) {
                            Text(room.label)
                                .font(.custom("Mulish-Light", size: 9, relativeTo: .caption2))
                                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.5))
                            if let ratio = room.requiredRatio {
                                Text(ratio.displayString)
                                    .font(.custom("Mulish-Light", size: 8, relativeTo: .caption2))
                                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.4))
                            }
                        }
                    }
                    .frame(width: diameter, height: diameter)
                    .position(x: cx, y: cy)
                    .allowsHitTesting(false)
                } else {
                    let x = CGFloat(room.origin.col) * cellSize
                    let y = CGFloat(room.origin.row) * cellSize
                    let w = CGFloat(room.width) * cellSize
                    let h = CGFloat(room.height) * cellSize
                    ZStack {
                        Rectangle()
                            .stroke(
                                RenaissanceColors.ochre.opacity(hintLevel >= 3 ? 0.5 : 0.25),
                                style: StrokeStyle(lineWidth: hintLevel >= 3 ? 2 : 1, dash: [6, 4])
                            )
                        VStack(spacing: 2) {
                            Text(room.label)
                                .font(.custom("Mulish-Light", size: 9, relativeTo: .caption2))
                                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.5))
                            if let ratio = room.requiredRatio {
                                Text(ratio.displayString)
                                    .font(.custom("Mulish-Light", size: 8, relativeTo: .caption2))
                                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.4))
                            }
                        }
                    }
                    .frame(width: w, height: h)
                    .position(x: x + w / 2, y: y + h / 2)
                    .allowsHitTesting(false)
                }
            }
        }
    }

    /// Level 3: Column position markers
    private func hintColumnMarkers(cellSize: CGFloat) -> some View {
        ForEach(Array(phaseData.targetColumns.enumerated()), id: \.offset) { _, targetCol in
            let point = gridToPoint(targetCol, cellSize: cellSize)
            let alreadyPlaced = placedColumns.contains { col in
                abs(col.position.row - targetCol.row) <= 1 && abs(col.position.col - targetCol.col) <= 1
            }

            if !alreadyPlaced {
                ZStack {
                    Circle()
                        .stroke(RenaissanceColors.warmBrown.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [3, 3]))
                        .frame(width: cellSize * 0.6, height: cellSize * 0.6)
                    Image(systemName: "plus")
                        .font(.custom("Mulish-Light", size: 6, relativeTo: .caption2))
                        .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.3))
                }
                .position(point)
                .allowsHitTesting(false)
            }
        }
    }

    // MARK: - Walls

    private func wallPath(_ wall: WallSegment, cellSize: CGFloat) -> some View {
        Path { path in
            path.move(to: gridToPoint(wall.start, cellSize: cellSize))
            path.addLine(to: gridToPoint(wall.end, cellSize: cellSize))
        }
        .stroke(RenaissanceColors.sepiaInk, style: StrokeStyle(lineWidth: 3, lineCap: .round))
    }

    private func wallPreviewPath(from start: GridCoord, to end: GridCoord, cellSize: CGFloat) -> some View {
        let snapped = snapToAxis(from: start, to: end)
        return Path { path in
            path.move(to: gridToPoint(start, cellSize: cellSize))
            path.addLine(to: gridToPoint(snapped, cellSize: cellSize))
        }
        .stroke(RenaissanceColors.renaissanceBlue.opacity(0.5), style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [6, 4]))
    }

    // MARK: - Circles

    private func circleShape(_ circle: CirclePlacement, cellSize: CGFloat) -> some View {
        let center = gridToPoint(circle.center, cellSize: cellSize)
        let diameter = CGFloat(circle.radius * 2) * cellSize
        return Circle()
            .stroke(RenaissanceColors.sepiaInk, lineWidth: 3)
            .frame(width: diameter, height: diameter)
            .position(center)
    }

    private func circlePreview(center: GridCoord, edge: GridCoord, cellSize: CGFloat) -> some View {
        let centerPt = gridToPoint(center, cellSize: cellSize)
        let radius = gridDistance(from: center, to: edge)
        let diameter = CGFloat(radius * 2) * cellSize
        return ZStack {
            Circle()
                .stroke(
                    RenaissanceColors.renaissanceBlue.opacity(0.5),
                    style: StrokeStyle(lineWidth: 3, dash: [6, 4])
                )
            // Radius label
            Text("r=\(radius)")
                .font(.custom("Mulish-Light", size: 10, relativeTo: .caption2))
                .foregroundStyle(RenaissanceColors.sepiaInk)
                .offset(y: -diameter / 2 - 12)
        }
        .frame(width: max(diameter, 1), height: max(diameter, 1))
        .position(centerPt)
    }

    /// Grid distance (max of row/col difference — used as radius)
    private func gridDistance(from a: GridCoord, to b: GridCoord) -> Int {
        let dr = abs(b.row - a.row)
        let dc = abs(b.col - a.col)
        return max(dr, dc)
    }

    // MARK: - Columns

    private func columnMarker(_ col: ColumnPlacement, cellSize: CGFloat) -> some View {
        let point = gridToPoint(col.position, cellSize: cellSize)
        return ZStack {
            Circle()
                .fill(RenaissanceColors.warmBrown)
                .frame(width: cellSize * 0.5, height: cellSize * 0.5)
            Circle()
                .stroke(RenaissanceColors.sepiaInk, lineWidth: 1.5)
                .frame(width: cellSize * 0.5, height: cellSize * 0.5)
        }
        .position(point)
    }

    // MARK: - Room Labels

    private func roomLabel(_ room: DetectedRoom, cellSize: CGFloat) -> some View {
        let centerX: CGFloat
        let centerY: CGFloat
        let sizeText: String
        let isCorrect = room.matchesTarget

        if room.isCircle, let center = room.circleCenter, let radius = room.circleRadius {
            centerX = CGFloat(center.col) * cellSize
            centerY = CGFloat(center.row) * cellSize
            sizeText = "r=\(radius), d=\(radius * 2)"
        } else {
            centerX = (CGFloat(room.minCol) + CGFloat(room.maxCol)) / 2 * cellSize
            centerY = (CGFloat(room.minRow) + CGFloat(room.maxRow)) / 2 * cellSize
            let width = room.maxCol - room.minCol
            let height = room.maxRow - room.minRow
            let ratio = simplifyRatio(width: width, height: height)
            sizeText = "\(width)x\(height) → \(ratio)"
        }

        return VStack(spacing: 2) {
            Text(room.label)
                .font(.custom("Cinzel-Regular", size: 10, relativeTo: .caption2))
                .foregroundStyle(RenaissanceColors.sepiaInk)
            Text(sizeText)
                .font(.custom("Mulish-Light", size: 9, relativeTo: .caption2))
                .foregroundStyle(isCorrect ? RenaissanceColors.sageGreen : RenaissanceColors.errorRed)
            if isCorrect {
                Image(systemName: "checkmark.circle.fill")
                    .font(.caption2)
                    .foregroundStyle(RenaissanceColors.sageGreen)
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(RenaissanceColors.parchment.opacity(0.85))
        )
        .position(x: centerX, y: centerY)
        .allowsHitTesting(false)
    }

    // MARK: - Validation Overlay

    private func validationOverlay(_ result: ValidationResult, cellSize: CGFloat) -> some View {
        Group {
            // Highlight correct rooms in green, incorrect in red
            ForEach(result.roomResults) { roomResult in
                let room = roomResult.room
                let fillColor = roomResult.isCorrect ? RenaissanceColors.sageGreen.opacity(0.15) : RenaissanceColors.errorRed.opacity(0.1)
                let strokeColor = roomResult.isCorrect ? RenaissanceColors.sageGreen : RenaissanceColors.errorRed

                if room.shape == .circle {
                    let cx = CGFloat(room.origin.col) * cellSize
                    let cy = CGFloat(room.origin.row) * cellSize
                    let diameter = CGFloat(room.width) * cellSize
                    ZStack {
                        Circle().fill(fillColor)
                        Circle().stroke(strokeColor, lineWidth: 2)
                    }
                    .frame(width: diameter, height: diameter)
                    .position(x: cx, y: cy)
                    .allowsHitTesting(false)
                } else {
                    let x = CGFloat(room.origin.col) * cellSize
                    let y = CGFloat(room.origin.row) * cellSize
                    let w = CGFloat(room.width) * cellSize
                    let h = CGFloat(room.height) * cellSize
                    ZStack {
                        Rectangle().fill(fillColor)
                        Rectangle().stroke(strokeColor, lineWidth: 2)
                    }
                    .frame(width: w, height: h)
                    .position(x: x + w / 2, y: y + h / 2)
                    .allowsHitTesting(false)
                }
            }
        }
    }

    // MARK: - Room Info Bar

    private var roomInfoBar: some View {
        HStack(spacing: 12) {
            ForEach(phaseData.targetRooms) { target in
                let detected = detectedRooms.first { $0.label == target.label }
                HStack(spacing: 4) {
                    Image(systemName: detected?.matchesTarget == true ? "checkmark.circle.fill" : "circle")
                        .font(.caption)
                        .foregroundStyle(detected?.matchesTarget == true ? RenaissanceColors.sageGreen : RenaissanceColors.stoneGray)

                    Text(target.label)
                        .font(.custom("Mulish-Light", size: 13, relativeTo: .caption))
                        .foregroundStyle(RenaissanceColors.sepiaInk)

                    if target.shape == .circle {
                        Image(systemName: "circle.dashed")
                            .font(.caption2)
                            .foregroundStyle(RenaissanceColors.sepiaInk)
                    }

                    if let ratio = target.requiredRatio {
                        Text(ratio.displayString)
                            .font(.custom("Mulish-Light", size: 11, relativeTo: .caption2))
                            .foregroundStyle(RenaissanceColors.sepiaInk)
                    }
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(RenaissanceColors.parchment.opacity(0.9))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(RenaissanceColors.sepiaInk.opacity(0.15), lineWidth: 0.5)
                )
        )
    }

    // MARK: - Gesture Handling

    private func canvasGesture(cellSize: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                let coord = pointToGrid(value.location, cellSize: cellSize)
                guard isValidCoord(coord) else { return }

                switch selectedTool {
                case .wall:
                    if !isDragging {
                        dragStart = coord
                        isDragging = true
                    }
                    dragCurrent = coord

                case .circleTool:
                    if !isDragging {
                        dragStart = coord  // center
                        isDragging = true
                    }
                    dragCurrent = coord  // edge (determines radius)

                case .column:
                    // Column placement happens on tap (onEnded with minimal distance)
                    break

                case .eraser:
                    // Erase on tap
                    break

                case .roomLabel, .undo:
                    break
                }
            }
            .onEnded { value in
                let coord = pointToGrid(value.location, cellSize: cellSize)

                switch selectedTool {
                case .wall:
                    if let start = dragStart {
                        let end = snapToAxis(from: start, to: coord)
                        if start != end && isValidCoord(end) {
                            let wall = WallSegment(start: start, end: end)
                            placedWalls.append(wall)
                            undoStack.append(.wall(wall))
                            detectRooms()

                            // Bird encouragement for first wall
                            if !hasPlacedFirstWall {
                                hasPlacedFirstWall = true
                                birdEncourage("Great first wall!")
                            }
                        }
                    }
                    isDragging = false
                    dragStart = nil
                    dragCurrent = nil

                case .circleTool:
                    if let center = dragStart {
                        let radius = gridDistance(from: center, to: coord)
                        if radius >= 1 {
                            let circle = CirclePlacement(center: center, radius: radius)
                            placedCircles.append(circle)
                            undoStack.append(.circle(circle))
                            detectRooms()

                            if !hasPlacedFirstCircle {
                                hasPlacedFirstCircle = true
                                birdEncourage("A perfect circle!")
                            }
                        }
                    }
                    isDragging = false
                    dragStart = nil
                    dragCurrent = nil

                case .column:
                    guard isValidCoord(coord) else { break }
                    // Toggle column at position
                    if let idx = placedColumns.firstIndex(where: { $0.position == coord }) {
                        let removed = placedColumns.remove(at: idx)
                        undoStack.append(.removeColumn(removed))
                    } else {
                        let col = ColumnPlacement(position: coord)
                        placedColumns.append(col)
                        undoStack.append(.column(col))

                        // Bird encouragement for first column
                        if !hasPlacedFirstColumn {
                            hasPlacedFirstColumn = true
                            birdEncourage("Column placed!")
                        }
                    }

                case .eraser:
                    guard isValidCoord(coord) else { break }
                    eraseAt(coord, cellSize: cellSize)

                case .roomLabel:
                    guard isValidCoord(coord) else { break }
                    labelRoomAt(coord)

                case .undo:
                    undoLast()
                }

                // Clear validation on new action
                validationResult = nil
            }
    }

    // MARK: - Grid Helpers

    private func gridToPoint(_ coord: GridCoord, cellSize: CGFloat) -> CGPoint {
        CGPoint(x: CGFloat(coord.col) * cellSize, y: CGFloat(coord.row) * cellSize)
    }

    private func pointToGrid(_ point: CGPoint, cellSize: CGFloat) -> GridCoord {
        let col = Int((point.x / cellSize).rounded())
        let row = Int((point.y / cellSize).rounded())
        return GridCoord(row: clamp(row, 0, gridSize), col: clamp(col, 0, gridSize))
    }

    private func snapToAxis(from start: GridCoord, to end: GridCoord) -> GridCoord {
        let dRow = abs(end.row - start.row)
        let dCol = abs(end.col - start.col)
        // Constrain to horizontal or vertical
        if dCol >= dRow {
            return GridCoord(row: start.row, col: end.col)
        } else {
            return GridCoord(row: end.row, col: start.col)
        }
    }

    private func isValidCoord(_ coord: GridCoord) -> Bool {
        coord.row >= 0 && coord.row <= gridSize && coord.col >= 0 && coord.col <= gridSize
    }

    private func clamp(_ value: Int, _ min: Int, _ max: Int) -> Int {
        Swift.min(Swift.max(value, min), max)
    }

    private func simplifyRatio(width: Int, height: Int) -> String {
        guard width > 0 && height > 0 else { return "0:0" }
        let g = gcd(width, height)
        return "\(width / g):\(height / g)"
    }

    private func gcd(_ a: Int, _ b: Int) -> Int {
        b == 0 ? a : gcd(b, a % b)
    }

    // MARK: - Undo

    private enum UndoAction {
        case wall(WallSegment)
        case column(ColumnPlacement)
        case removeColumn(ColumnPlacement)
        case circle(CirclePlacement)
    }

    private func undoLast() {
        guard let last = undoStack.popLast() else { return }
        switch last {
        case .wall(let wall):
            placedWalls.removeAll { $0.id == wall.id }
        case .column(let col):
            placedColumns.removeAll { $0.id == col.id }
        case .removeColumn(let col):
            placedColumns.append(col)
        case .circle(let circle):
            placedCircles.removeAll { $0.id == circle.id }
        }
        detectRooms()
        validationResult = nil
    }

    // MARK: - Eraser

    private func eraseAt(_ coord: GridCoord, cellSize: CGFloat) {
        // Remove walls near this point
        let tolerance = 1
        placedWalls.removeAll { wall in
            isPointNearSegment(coord, wall: wall, tolerance: tolerance)
        }
        // Remove columns at this point
        placedColumns.removeAll { $0.position == coord }
        // Remove circles near this point (tap on or near edge)
        placedCircles.removeAll { circle in
            let dist = gridDistance(from: circle.center, to: coord)
            return dist <= circle.radius + 1 && dist >= circle.radius - 1 || coord == circle.center
        }
        detectRooms()
    }

    private func isPointNearSegment(_ point: GridCoord, wall: WallSegment, tolerance: Int) -> Bool {
        if wall.isHorizontal {
            let minCol = min(wall.start.col, wall.end.col)
            let maxCol = max(wall.start.col, wall.end.col)
            return point.row == wall.start.row && point.col >= minCol && point.col <= maxCol
        } else if wall.isVertical {
            let minRow = min(wall.start.row, wall.end.row)
            let maxRow = max(wall.start.row, wall.end.row)
            return point.col == wall.start.col && point.row >= minRow && point.row <= maxRow
        }
        return false
    }

    // MARK: - Room Label

    private func labelRoomAt(_ coord: GridCoord) {
        // Find which target room contains this point
        for target in phaseData.targetRooms {
            let inRow = coord.row >= target.origin.row && coord.row <= target.origin.row + target.height
            let inCol = coord.col >= target.origin.col && coord.col <= target.origin.col + target.width
            if inRow && inCol {
                // Check if already labeled
                if !detectedRooms.contains(where: { $0.label == target.label }) {
                    let room = DetectedRoom(
                        label: target.label,
                        minRow: target.origin.row,
                        maxRow: target.origin.row + target.height,
                        minCol: target.origin.col,
                        maxCol: target.origin.col + target.width,
                        matchesTarget: true
                    )
                    detectedRooms.append(room)
                }
                return
            }
        }
    }

    // MARK: - Room Detection

    /// Detect enclosed rooms formed by walls
    private func detectRooms() {
        // Build a wall grid to find enclosed areas
        var wallGrid = Set<WallEdge>()
        for wall in placedWalls {
            if wall.isHorizontal {
                let row = wall.start.row
                let minCol = min(wall.start.col, wall.end.col)
                let maxCol = max(wall.start.col, wall.end.col)
                for col in minCol..<maxCol {
                    wallGrid.insert(WallEdge(row: row, col: col, isHorizontal: true))
                }
            } else if wall.isVertical {
                let col = wall.start.col
                let minRow = min(wall.start.row, wall.end.row)
                let maxRow = max(wall.start.row, wall.end.row)
                for row in minRow..<maxRow {
                    wallGrid.insert(WallEdge(row: row, col: col, isHorizontal: false))
                }
            }
        }

        // For each target room, check if its walls/circles exist
        var newDetected: [DetectedRoom] = []
        for target in phaseData.targetRooms {
            if target.shape == .circle {
                // Circle detection — STRICT: center and radius must match exactly
                let targetCenter = target.origin  // origin IS center for circles
                let targetRadius = target.radius

                // Find the best matching circle (closest to target)
                var bestCircle: CirclePlacement? = nil
                var bestScore = Int.max
                for circle in placedCircles {
                    let centerDist = abs(circle.center.row - targetCenter.row) +
                                     abs(circle.center.col - targetCenter.col)
                    let radiusDiff = abs(circle.radius - targetRadius)
                    let score = centerDist + radiusDiff
                    if score < bestScore {
                        bestScore = score
                        bestCircle = circle
                    }
                }

                if let circle = bestCircle {
                    // Exact match required: center within 0 cells, radius exact
                    let centerOk = circle.center == targetCenter
                    let radiusOk = circle.radius == targetRadius
                    let isMatch = centerOk && radiusOk

                    newDetected.append(DetectedRoom(
                        label: target.label,
                        minRow: targetCenter.row - circle.radius,
                        maxRow: targetCenter.row + circle.radius,
                        minCol: targetCenter.col - circle.radius,
                        maxCol: targetCenter.col + circle.radius,
                        matchesTarget: isMatch,
                        isCircle: true,
                        circleCenter: circle.center,
                        circleRadius: circle.radius
                    ))
                }
            } else {
                // Rectangle detection — walls must form the room boundary
                let r = target.origin.row
                let c = target.origin.col
                let w = target.width
                let h = target.height

                var topWalls = 0, bottomWalls = 0, leftWalls = 0, rightWalls = 0

                // Check top wall
                for col in c..<(c + w) {
                    if wallGrid.contains(WallEdge(row: r, col: col, isHorizontal: true)) { topWalls += 1 }
                }
                // Check bottom wall
                for col in c..<(c + w) {
                    if wallGrid.contains(WallEdge(row: r + h, col: col, isHorizontal: true)) { bottomWalls += 1 }
                }
                // Check left wall
                for row in r..<(r + h) {
                    if wallGrid.contains(WallEdge(row: row, col: c, isHorizontal: false)) { leftWalls += 1 }
                }
                // Check right wall
                for row in r..<(r + h) {
                    if wallGrid.contains(WallEdge(row: row, col: c + w, isHorizontal: false)) { rightWalls += 1 }
                }

                // Room is detected if at least 90% of each wall side is drawn
                let threshold = 0.9
                let topOk = Double(topWalls) / Double(w) >= threshold
                let bottomOk = Double(bottomWalls) / Double(w) >= threshold
                let leftOk = Double(leftWalls) / Double(h) >= threshold
                let rightOk = Double(rightWalls) / Double(h) >= threshold

                if topOk && bottomOk && leftOk && rightOk {
                    let ratioMatch = target.requiredRatio?.matches(width: w, height: h) ?? true
                    newDetected.append(DetectedRoom(
                        label: target.label,
                        minRow: r,
                        maxRow: r + h,
                        minCol: c,
                        maxCol: c + w,
                        matchesTarget: ratioMatch
                    ))
                }
            }
        }

        // Check for newly correct rooms → bird celebration
        for room in newDetected where room.matchesTarget {
            if !celebratedRooms.contains(room.label) {
                celebratedRooms.insert(room.label)
                birdCelebrate()
            }
        }

        withAnimation(.easeInOut(duration: 0.2)) {
            detectedRooms = newDetected
        }
    }

    // MARK: - Validation

    private func validatePlan() {
        var roomResults: [RoomValidationResult] = []

        for target in phaseData.targetRooms {
            let detected = detectedRooms.first { $0.label == target.label }
            let isCorrect = detected?.matchesTarget ?? false
            roomResults.append(RoomValidationResult(
                room: target,
                isCorrect: isCorrect,
                isDetected: detected != nil
            ))
        }

        // Check columns
        var columnsCorrect = 0
        for targetCol in phaseData.targetColumns {
            // Allow 1-cell tolerance
            let hasColumn = placedColumns.contains { col in
                abs(col.position.row - targetCol.row) <= 1 && abs(col.position.col - targetCol.col) <= 1
            }
            if hasColumn { columnsCorrect += 1 }
        }

        // — NEATNESS CHECK —
        // An architect draws precisely. Extra elements = messy plan = fail.

        // Count expected vs actual circles
        let expectedCircles = phaseData.targetRooms.filter { $0.shape == .circle }.count
        let extraCircles = placedCircles.count - expectedCircles
        let circlesNeat = extraCircles <= 1  // allow at most 1 extra circle

        // Count expected wall segments (each target rect side = 1 wall ideally)
        let expectedRectRooms = phaseData.targetRooms.filter { $0.shape == .rectangle }
        let expectedWallCount = expectedRectRooms.reduce(0) { total, room in
            total + 4  // 4 walls per rectangle room (minimum)
        }
        let maxAllowedWalls = max(expectedWallCount * 3, 8)  // generous but bounded
        let wallsNeat = placedWalls.count <= maxAllowedWalls

        // Extra columns beyond target
        let extraColumns = max(0, placedColumns.count - phaseData.targetColumns.count)
        let columnsNeat = extraColumns <= 2  // allow at most 2 extra columns

        let isNeat = circlesNeat && wallsNeat && columnsNeat

        let allRoomsCorrect = roomResults.allSatisfy { $0.isCorrect }
        let columnsOk = phaseData.targetColumns.isEmpty ||
            columnsCorrect >= max(1, phaseData.targetColumns.count - 1)  // must get almost all columns

        let result = ValidationResult(
            roomResults: roomResults,
            columnsCorrect: columnsCorrect,
            columnsTotal: phaseData.targetColumns.count,
            isNeat: isNeat,
            neatnessFeedback: !isNeat ? neatnessFeedbackMessage(
                circlesNeat: circlesNeat, wallsNeat: wallsNeat, columnsNeat: columnsNeat
            ) : nil,
            isComplete: allRoomsCorrect && columnsOk && isNeat
        )

        withAnimation(.spring(response: 0.4)) {
            validationResult = result
        }

        if result.isComplete {
            showSuccessEffect.toggle()
            birdCelebrate()
            showBirdSpeechBriefly("Magnifico! A true architect!")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                showCompletion = true
                onComplete([.pianta])
            }
        } else if !isNeat {
            // Bird gives neatness feedback
            showBirdSpeechBriefly(result.neatnessFeedback ?? "Clean up your plan!")
        }
    }

    private func neatnessFeedbackMessage(circlesNeat: Bool, wallsNeat: Bool, columnsNeat: Bool) -> String {
        if !circlesNeat {
            return "Too many circles! Erase the extra ones — an architect draws precisely."
        }
        if !wallsNeat {
            return "Too many walls! A clean plan has only the walls you need."
        }
        if !columnsNeat {
            return "Too many columns! Place them only where needed."
        }
        return "Clean up your plan!"
    }
}

// MARK: - Helper Types

private struct WallEdge: Hashable {
    let row: Int
    let col: Int
    let isHorizontal: Bool
}

struct DetectedRoom: Identifiable {
    let id = UUID()
    let label: String
    let minRow: Int
    let maxRow: Int
    let minCol: Int
    let maxCol: Int
    let matchesTarget: Bool
    var isCircle: Bool = false
    var circleCenter: GridCoord? = nil
    var circleRadius: Int? = nil
}

struct RoomValidationResult: Identifiable {
    let id = UUID()
    let room: RoomDefinition
    let isCorrect: Bool
    let isDetected: Bool
}

struct ValidationResult {
    let roomResults: [RoomValidationResult]
    let columnsCorrect: Int
    let columnsTotal: Int
    let isNeat: Bool
    let neatnessFeedback: String?
    let isComplete: Bool
}

#Preview {
    PiantaCanvasView(
        phaseData: PiantaPhaseData(
            gridSize: 12,
            targetRooms: [
                RoomDefinition(
                    label: "Rotunda",
                    origin: GridCoord(row: 5, col: 6),
                    width: 6,
                    height: 6,
                    requiredRatio: ProportionalRatio(numerator: 1, denominator: 1),
                    shape: .circle
                ),
                RoomDefinition(
                    label: "Portico",
                    origin: GridCoord(row: 8, col: 4),
                    width: 4,
                    height: 2,
                    requiredRatio: ProportionalRatio(numerator: 2, denominator: 1)
                )
            ],
            targetColumns: [],
            symmetryAxis: nil,
            proportionalRatios: [
                ProportionalRatio(numerator: 1, denominator: 1),
                ProportionalRatio(numerator: 2, denominator: 1)
            ],
            hint: "Use the Circle tool to draw the rotunda.",
            educationalText: "The Pantheon's dome spans 43.3 meters.",
            historicalContext: "Built by Emperor Hadrian around 126 AD."
        ),
        onComplete: { _ in }
    )
}
