import SwiftUI

/// Phase 3: Sezione (Cross-Section) Canvas
/// 3-layer interactive canvas where students build structural cross-sections.
/// Layer 1: Drag wall segments from palette → grid
/// Layer 2: Shape arches/vaults with Bézier drag handles
/// Layer 3: Place load-path arrows showing force flow
struct SezioneCanvasView: View {
    let phaseData: SezionePhaseData
    let onComplete: (Set<SketchingPhaseType>) -> Void

    @Bindable var canvasState: SezioneCanvasState

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    private var isLargeScreen: Bool { horizontalSizeClass == .regular }

    // Drag state for wall placement (Layer 1)
    @State private var dragOffset: CGSize = .zero
    @State private var isDraggingWall = false

    var body: some View {
        VStack(spacing: 12) {
            // Header with layer info
            headerView

            // Bird message
            if let message = canvasState.birdMessage {
                birdMessageView(message)
            }

            // Canvas
            GeometryReader { geo in
                let canvasWidth = geo.size.width - 32
                let canvasHeight = min(canvasWidth * 0.75, geo.size.height - 80)
                let cellWidth = canvasWidth / CGFloat(phaseData.gridCols)
                let cellHeight = canvasHeight / CGFloat(phaseData.gridRows)

                ZStack(alignment: .topLeading) {
                    // Grid background
                    gridBackground(cellWidth: cellWidth, cellHeight: cellHeight,
                                   canvasWidth: canvasWidth, canvasHeight: canvasHeight)

                    // Hint overlays
                    if canvasState.hintLevel >= 2 {
                        hintOverlay(cellWidth: cellWidth, cellHeight: cellHeight)
                    }

                    // Placed walls (Layer 1) — always visible once placed
                    ForEach(phaseData.wallElements) { element in
                        if let placement = canvasState.placedWalls.first(where: { $0.elementId == element.id }) {
                            placedWallView(element: element, position: placement.position,
                                           cellWidth: cellWidth, cellHeight: cellHeight)
                        }
                    }

                    // Structural curves (Layer 2) — visible when layer >= curves
                    if canvasState.activeLayer >= .curves {
                        ForEach(phaseData.structuralCurves) { curve in
                            curveView(curve: curve, cellWidth: cellWidth, cellHeight: cellHeight,
                                      canvasWidth: canvasWidth, canvasHeight: canvasHeight)
                        }
                    }

                    // Load path arrows (Layer 3) — visible when layer >= loadPaths
                    if canvasState.activeLayer >= .loadPaths {
                        ForEach(canvasState.placedArrows) { arrow in
                            arrowView(arrow: arrow, cellWidth: cellWidth, cellHeight: cellHeight)
                        }

                        // Arrow target hints
                        if canvasState.hintLevel >= 2 {
                            ForEach(phaseData.loadPathTargets) { target in
                                if !canvasState.placedArrows.contains(where: { $0.from == target.from && $0.to == target.to }) {
                                    arrowHintView(target: target, cellWidth: cellWidth, cellHeight: cellHeight)
                                }
                            }
                        }
                    }

                    // Tap gesture for load path arrow placement (Layer 3)
                    if canvasState.activeLayer == .loadPaths {
                        Color.clear
                            .contentShape(Rectangle())
                            .onTapGesture { location in
                                handleLoadPathTap(at: location, cellWidth: cellWidth, cellHeight: cellHeight)
                            }
                    }
                }
                .frame(width: canvasWidth, height: canvasHeight)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.5))
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(RenaissanceColors.sepiaInk.opacity(0.3), lineWidth: 1)
                        )
                )
                .position(x: geo.size.width / 2, y: canvasHeight / 2)
            }

            // Wall palette (Layer 1) or info bar (Layers 2-3)
            switch canvasState.activeLayer {
            case .walls:
                wallPalette
            case .curves:
                curveInfoBar
            case .loadPaths:
                loadPathInfoBar
            }

            // Toolbar
            SezioneToolbarView(
                activeLayer: canvasState.activeLayer,
                completedLayers: canvasState.layerCompleted,
                onUndo: { canvasState.undo() },
                onAdvanceLayer: { withAnimation(.spring(response: 0.3)) { canvasState.advanceLayer() } }
            )

            // Completion button
            if canvasState.allLayersComplete {
                Button {
                    onComplete([.sezione])
                } label: {
                    Text("Complete Cross-Section")
                        .font(.custom("Cinzel-Bold", size: 16))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(RenaissanceColors.sageGreen)
                        )
                }
                .buttonStyle(.plain)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 16)
        .onAppear {
            canvasState.configure(with: phaseData)
        }
    }

    // MARK: - Header

    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Sezione: Cross-Section")
                    .font(.custom("Cinzel-Regular", size: isLargeScreen ? 20 : 16))
                    .foregroundStyle(RenaissanceColors.sepiaInk)

                Text("Build the structure layer by layer")
                    .font(.custom("EBGaramond-Regular", size: isLargeScreen ? 14 : 12))
                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.6))
            }

            Spacer()

            // Hint button
            Button {
                canvasState.requestHint()
            } label: {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(RenaissanceColors.ochre)
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(RenaissanceColors.ochre.opacity(0.15))
                    )
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Bird Message

    private func birdMessageView(_ message: String) -> some View {
        HStack(spacing: 8) {
            Image("BirdFlySit00")
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32)

            Text(message)
                .font(.custom("EBGaramond-Regular", size: isLargeScreen ? 14 : 12))
                .foregroundStyle(RenaissanceColors.sepiaInk)
                .lineLimit(2)

            Spacer()
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(RenaissanceColors.parchment)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(RenaissanceColors.ochre.opacity(0.3), lineWidth: 1)
                )
        )
        .transition(.move(edge: .top).combined(with: .opacity))
    }

    // MARK: - Grid Background

    private func gridBackground(cellWidth: CGFloat, cellHeight: CGFloat,
                                 canvasWidth: CGFloat, canvasHeight: CGFloat) -> some View {
        Canvas { context, size in
            // Vertical grid lines
            for col in 0...phaseData.gridCols {
                let x = CGFloat(col) * cellWidth
                var path = Path()
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: canvasHeight))
                context.stroke(path, with: .color(RenaissanceColors.blueprintBlue.opacity(0.15)), lineWidth: 0.5)
            }
            // Horizontal grid lines
            for row in 0...phaseData.gridRows {
                let y = CGFloat(row) * cellHeight
                var path = Path()
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: canvasWidth, y: y))
                context.stroke(path, with: .color(RenaissanceColors.blueprintBlue.opacity(0.15)), lineWidth: 0.5)
            }

            // Ground line (bottom)
            var groundPath = Path()
            groundPath.move(to: CGPoint(x: 0, y: canvasHeight - cellHeight))
            groundPath.addLine(to: CGPoint(x: canvasWidth, y: canvasHeight - cellHeight))
            context.stroke(groundPath, with: .color(RenaissanceColors.warmBrown.opacity(0.4)), lineWidth: 2)
        }
    }

    // MARK: - Layer 1: Wall Palette

    private var wallPalette: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(phaseData.wallElements) { element in
                    let isPlaced = canvasState.placedWalls.contains { $0.elementId == element.id }

                    wallPaletteItem(element: element, isPlaced: isPlaced)
                        .draggable(element.id) {
                            // Drag preview
                            wallPreviewShape(element: element)
                        }
                }
            }
            .padding(.horizontal, 16)
        }
        .frame(height: 70)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(RenaissanceColors.parchment.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(RenaissanceColors.sepiaInk.opacity(0.2), lineWidth: 1)
                )
        )
    }

    private func wallPaletteItem(element: SezioneWallElement, isPlaced: Bool) -> some View {
        VStack(spacing: 4) {
            // Wall shape preview
            RoundedRectangle(cornerRadius: 3)
                .fill(isPlaced ? RenaissanceColors.sageGreen.opacity(0.3) :
                      thicknessColor(element.thickness).opacity(0.6))
                .frame(
                    width: CGFloat(element.width) * 6,
                    height: CGFloat(element.height) * 4
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 3)
                        .stroke(isPlaced ? RenaissanceColors.sageGreen :
                                thicknessColor(element.thickness), lineWidth: 1)
                )
                .overlay {
                    if isPlaced {
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(RenaissanceColors.sageGreen)
                    }
                }

            Text(element.label)
                .font(.custom("EBGaramond-Regular", size: 9))
                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))
                .lineLimit(1)
        }
        .frame(width: 70)
        .padding(.vertical, 6)
    }

    private func wallPreviewShape(element: SezioneWallElement) -> some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(thicknessColor(element.thickness).opacity(0.8))
            .frame(width: CGFloat(element.width) * 12, height: CGFloat(element.height) * 8)
            .overlay(
                RoundedRectangle(cornerRadius: 3)
                    .stroke(thicknessColor(element.thickness), lineWidth: 2)
            )
    }

    // MARK: - Layer 1: Placed Wall

    private func placedWallView(element: SezioneWallElement, position: GridCoord,
                                cellWidth: CGFloat, cellHeight: CGFloat) -> some View {
        let x = CGFloat(position.col) * cellWidth
        let y = CGFloat(position.row) * cellHeight
        let w = CGFloat(element.width) * cellWidth
        let h = CGFloat(element.height) * cellHeight
        let isCorrect = position == element.targetPosition

        return RoundedRectangle(cornerRadius: 2)
            .fill(isCorrect ? thicknessColor(element.thickness).opacity(0.7) :
                  RenaissanceColors.errorRed.opacity(0.3))
            .frame(width: w, height: h)
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(isCorrect ? thicknessColor(element.thickness) :
                            RenaissanceColors.errorRed, lineWidth: 1.5)
            )
            .overlay {
                // Material label
                Text(element.material)
                    .font(.custom("EBGaramond-Regular", size: max(8, min(w, h) * 0.15)))
                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.5))
            }
            .position(x: x + w / 2, y: y + h / 2)
            .dropDestination(for: String.self) { items, location in
                guard let wallId = items.first,
                      let element = phaseData.wallElements.first(where: { $0.id == wallId }) else { return false }
                let gridCol = Int(location.x / cellWidth)
                let gridRow = Int(location.y / cellHeight)
                canvasState.placeWall(element, at: GridCoord(row: gridRow, col: gridCol))
                return true
            }
    }

    // MARK: - Layer 2: Curve View (Bézier)

    private func curveView(curve: SezioneStructuralCurve,
                           cellWidth: CGFloat, cellHeight: CGFloat,
                           canvasWidth: CGFloat, canvasHeight: CGFloat) -> some View {
        let points = canvasState.curvePoints[curve.id] ?? curve.initialPoints
        let isLocked = canvasState.lockedCurves.contains(curve.id)
        let curveX = curve.position.x * canvasWidth
        let curveY = curve.position.y * canvasHeight
        let curveW = curve.size.width * canvasWidth
        let curveH = curve.size.height * canvasHeight

        return ZStack {
            // Draw the curve path
            BezierCurvePath(points: points, size: CGSize(width: curveW, height: curveH))
                .stroke(isLocked ? RenaissanceColors.sageGreen : RenaissanceColors.renaissanceBlue,
                        lineWidth: isLocked ? 3 : 2)
                .frame(width: curveW, height: curveH)

            // Drag handles (only when active and not locked)
            if canvasState.activeLayer == .curves && !isLocked {
                ForEach(Array(points.enumerated()), id: \.offset) { index, point in
                    Circle()
                        .fill(RenaissanceColors.renaissanceBlue)
                        .frame(width: 16, height: 16)
                        .overlay(Circle().stroke(.white, lineWidth: 2))
                        .position(x: point.x * curveW, y: point.y * curveH)
                        .gesture(
                            DragGesture(minimumDistance: 1)
                                .onChanged { value in
                                    let newX = value.location.x / curveW
                                    let newY = value.location.y / curveH
                                    let clamped = CGPoint(
                                        x: min(max(newX, 0), 1),
                                        y: min(max(newY, 0), 1)
                                    )
                                    canvasState.updateCurvePoint(curve.id, pointIndex: index, to: clamped)
                                }
                                .onEnded { _ in
                                    canvasState.checkCurveLock(curve.id)
                                }
                        )
                }
            }

            // Lock checkmark
            if isLocked {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(RenaissanceColors.sageGreen)
                    .position(x: curveW / 2, y: 4)
            }
        }
        .position(x: curveX + curveW / 2, y: curveY + curveH / 2)
    }

    // MARK: - Layer 3: Arrow View

    private func arrowView(arrow: LoadPathSegment,
                           cellWidth: CGFloat, cellHeight: CGFloat) -> some View {
        let fromX = (CGFloat(arrow.from.col) + 0.5) * cellWidth
        let fromY = (CGFloat(arrow.from.row) + 0.5) * cellHeight
        let toX = (CGFloat(arrow.to.col) + 0.5) * cellWidth
        let toY = (CGFloat(arrow.to.row) + 0.5) * cellHeight

        let isCorrect = phaseData.loadPathTargets.contains { $0.from == arrow.from && $0.to == arrow.to }

        return ZStack {
            // Arrow line
            Path { path in
                path.move(to: CGPoint(x: fromX, y: fromY))
                path.addLine(to: CGPoint(x: toX, y: toY))
            }
            .stroke(isCorrect ? RenaissanceColors.sageGreen : RenaissanceColors.ochre,
                    style: StrokeStyle(lineWidth: 2.5, lineCap: .round))

            // Arrowhead
            arrowHead(from: CGPoint(x: fromX, y: fromY), to: CGPoint(x: toX, y: toY))
                .fill(isCorrect ? RenaissanceColors.sageGreen : RenaissanceColors.ochre)
        }
    }

    private func arrowHead(from: CGPoint, to: CGPoint) -> Path {
        let angle = atan2(to.y - from.y, to.x - from.x)
        let headLength: CGFloat = 10
        let headAngle: CGFloat = .pi / 6

        return Path { path in
            path.move(to: to)
            path.addLine(to: CGPoint(
                x: to.x - headLength * cos(angle - headAngle),
                y: to.y - headLength * sin(angle - headAngle)
            ))
            path.addLine(to: CGPoint(
                x: to.x - headLength * cos(angle + headAngle),
                y: to.y - headLength * sin(angle + headAngle)
            ))
            path.closeSubpath()
        }
    }

    private func arrowHintView(target: LoadPathSegment,
                               cellWidth: CGFloat, cellHeight: CGFloat) -> some View {
        let fromX = (CGFloat(target.from.col) + 0.5) * cellWidth
        let fromY = (CGFloat(target.from.row) + 0.5) * cellHeight
        let toX = (CGFloat(target.to.col) + 0.5) * cellWidth
        let toY = (CGFloat(target.to.row) + 0.5) * cellHeight

        return Path { path in
            path.move(to: CGPoint(x: fromX, y: fromY))
            path.addLine(to: CGPoint(x: toX, y: toY))
        }
        .stroke(RenaissanceColors.renaissanceBlue.opacity(0.2),
                style: StrokeStyle(lineWidth: 2, dash: [6, 4]))
    }

    // MARK: - Load Path Tap Handling

    private func handleLoadPathTap(at location: CGPoint, cellWidth: CGFloat, cellHeight: CGFloat) {
        let col = Int(location.x / cellWidth)
        let row = Int(location.y / cellHeight)
        let tapped = GridCoord(row: row, col: col)

        if let start = canvasState.arrowStartPoint {
            // Second tap — create arrow
            let direction: LoadDirection = {
                if tapped.col == start.col { return .down }
                if tapped.col < start.col { return .diagonalLeft }
                if tapped.col > start.col { return .diagonalRight }
                return .down
            }()

            let segment = LoadPathSegment(
                id: "\(start.row)-\(start.col)-\(tapped.row)-\(tapped.col)",
                from: start, to: tapped,
                direction: direction,
                label: "Load path"
            )
            withAnimation(.spring(response: 0.2)) {
                canvasState.placeArrow(segment)
            }
        } else {
            // First tap — set start point
            canvasState.arrowStartPoint = tapped
        }
    }

    // MARK: - Hint Overlay

    private func hintOverlay(cellWidth: CGFloat, cellHeight: CGFloat) -> some View {
        ForEach(phaseData.wallElements) { element in
            if !canvasState.placedWalls.contains(where: { $0.elementId == element.id }) {
                let x = CGFloat(element.targetPosition.col) * cellWidth
                let y = CGFloat(element.targetPosition.row) * cellHeight
                let w = CGFloat(element.width) * cellWidth
                let h = CGFloat(element.height) * cellHeight

                RoundedRectangle(cornerRadius: 2)
                    .stroke(RenaissanceColors.renaissanceBlue.opacity(0.3),
                            style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
                    .frame(width: w, height: h)
                    .position(x: x + w / 2, y: y + h / 2)
            }
        }
    }

    // MARK: - Info Bars

    private var curveInfoBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "scribble.variable")
                .foregroundStyle(RenaissanceColors.renaissanceBlue)
            Text("Drag the handles to shape each arch and vault")
                .font(.custom("EBGaramond-Regular", size: 13))
                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))
            Spacer()
            Text("\(canvasState.lockedCurves.count)/\(phaseData.structuralCurves.count)")
                .font(.custom("EBGaramond-SemiBold", size: 13))
                .foregroundStyle(RenaissanceColors.sageGreen)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(RenaissanceColors.parchment.opacity(0.8))
        )
    }

    private var loadPathInfoBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "arrow.down.to.line")
                .foregroundStyle(RenaissanceColors.ochre)
            Text(canvasState.arrowStartPoint != nil ?
                 "Tap the end point for the arrow" :
                 "Tap a starting point, then tap where the force goes")
                .font(.custom("EBGaramond-Regular", size: 13))
                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))
            Spacer()
            Text("\(canvasState.placedArrows.count)/\(phaseData.loadPathTargets.count)")
                .font(.custom("EBGaramond-SemiBold", size: 13))
                .foregroundStyle(RenaissanceColors.sageGreen)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(RenaissanceColors.parchment.opacity(0.8))
        )
    }

    // MARK: - Helpers

    private func thicknessColor(_ thickness: SezioneThickness) -> Color {
        switch thickness {
        case .thick: return RenaissanceColors.warmBrown
        case .medium: return RenaissanceColors.ochre
        case .thin: return RenaissanceColors.stoneGray
        }
    }
}

// MARK: - Bézier Curve Path (for Layer 2)

/// Draws a smooth curve through control points using Catmull-Rom interpolation
struct BezierCurvePath: Shape {
    let points: [CGPoint]
    let size: CGSize

    func path(in rect: CGRect) -> Path {
        guard points.count >= 2 else { return Path() }

        var path = Path()
        let scaled = points.map { CGPoint(x: $0.x * size.width, y: $0.y * size.height) }

        path.move(to: scaled[0])

        if scaled.count == 2 {
            path.addLine(to: scaled[1])
        } else {
            for i in 0..<(scaled.count - 1) {
                let p0 = i > 0 ? scaled[i - 1] : scaled[i]
                let p1 = scaled[i]
                let p2 = scaled[i + 1]
                let p3 = (i + 2) < scaled.count ? scaled[i + 2] : scaled[i + 1]

                let cp1 = CGPoint(
                    x: p1.x + (p2.x - p0.x) / 6,
                    y: p1.y + (p2.y - p0.y) / 6
                )
                let cp2 = CGPoint(
                    x: p2.x - (p3.x - p1.x) / 6,
                    y: p2.y - (p3.y - p1.y) / 6
                )

                path.addCurve(to: p2, control1: cp1, control2: cp2)
            }
        }

        return path
    }
}
