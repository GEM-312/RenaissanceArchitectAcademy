import SwiftUI

/// Animated aqueduct slope/gradient diagram — 5 steps
/// Step 1: Flat aqueduct channel appears on blueprint grid
/// Step 2: Channel tilts, "200 m" horizontal dimension line draws itself
/// Step 3: "1 m drop" vertical line draws, "1:200" ratio label appears
/// Step 4: Water drops animate flowing down the slope
/// Step 5: Summary text + checkmark
struct GradientSlopeVisual: View {
    @Binding var currentStep: Int

    // Water drop animation
    @State private var waterOffset: CGFloat = 0
    @State private var waterAnimating = false

    var body: some View {
        VStack(spacing: 0) {
            Canvas { context, size in
                drawDiagram(context: context, size: size)
            }
            .frame(height: 220)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(RenaissanceColors.parchment)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(RenaissanceColors.blueprintBlue.opacity(0.2), lineWidth: 1)
            )
            .clipped()

            // Step-specific text below diagram
            stepLabel
                .padding(.top, 12)
        }
        .onChange(of: currentStep) { _, newValue in
            if newValue >= 4 {
                startWaterAnimation()
            }
        }
        .onAppear {
            if currentStep >= 4 {
                startWaterAnimation()
            }
        }
    }

    // MARK: - Canvas Drawing

    private func drawDiagram(context: GraphicsContext, size: CGSize) {
        let w = size.width
        let h = size.height
        let pad: CGFloat = 30

        // Blueprint grid (always visible)
        drawGrid(context: context, size: size)

        guard currentStep >= 1 else { return }

        // Channel geometry
        let channelLeft = CGPoint(x: pad + 20, y: h * 0.45)
        let channelRight: CGPoint
        let channelThickness: CGFloat = 12

        if currentStep >= 2 {
            // Tilted: right end drops slightly
            let dropPx: CGFloat = 30
            channelRight = CGPoint(x: w - pad - 20, y: h * 0.45 + dropPx)
        } else {
            // Flat
            channelRight = CGPoint(x: w - pad - 20, y: h * 0.45)
        }

        // Draw aqueduct channel (thick line with channel shape)
        drawChannel(context: context, from: channelLeft, to: channelRight, thickness: channelThickness)

        // Step 2+: Horizontal dimension line "200 m"
        if currentStep >= 2 {
            let dimY = channelRight.y + 50
            drawDimensionLine(
                context: context,
                from: CGPoint(x: channelLeft.x, y: dimY),
                to: CGPoint(x: channelRight.x, y: dimY),
                label: "200 m",
                horizontal: true
            )
        }

        // Step 3+: Vertical dimension line "1 m drop" + ratio label
        if currentStep >= 3 {
            let vertX = channelRight.x + 10
            drawDimensionLine(
                context: context,
                from: CGPoint(x: vertX, y: channelLeft.y),
                to: CGPoint(x: vertX, y: channelRight.y),
                label: "1 m",
                horizontal: false
            )

            // Ratio label in center
            let labelCenter = CGPoint(x: w / 2, y: h * 0.2)
            let ratioText = Text("1 : 200")
                .font(.custom("Cinzel-Bold", size: 24))
                .foregroundColor(RenaissanceColors.blueprintBlue)
            context.draw(context.resolve(ratioText), at: labelCenter, anchor: .center)
        }

        // Step 4+: Water drops flowing down the slope
        if currentStep >= 4 {
            drawWaterDrops(context: context, from: channelLeft, to: channelRight, thickness: channelThickness)
        }

        // Step 5: Checkmark in corner
        if currentStep >= 5 {
            let checkPos = CGPoint(x: w - pad, y: pad)
            let checkText = Text(Image(systemName: "checkmark.circle.fill"))
                .font(.system(size: 28))
                .foregroundColor(RenaissanceColors.sageGreen)
            context.draw(context.resolve(checkText), at: checkPos, anchor: .center)
        }
    }

    // MARK: - Blueprint Grid

    private func drawGrid(context: GraphicsContext, size: CGSize) {
        let spacing: CGFloat = 20
        let color = RenaissanceColors.blueprintBlue.opacity(0.15)

        for x in stride(from: 0, through: size.width, by: spacing) {
            var path = Path()
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: size.height))
            context.stroke(path, with: .color(color), lineWidth: 0.5)
        }
        for y in stride(from: 0, through: size.height, by: spacing) {
            var path = Path()
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: size.width, y: y))
            context.stroke(path, with: .color(color), lineWidth: 0.5)
        }
    }

    // MARK: - Aqueduct Channel Shape

    private func drawChannel(context: GraphicsContext, from start: CGPoint, to end: CGPoint, thickness: CGFloat) {
        // Top surface
        var topPath = Path()
        topPath.move(to: CGPoint(x: start.x, y: start.y - thickness / 2))
        topPath.addLine(to: CGPoint(x: end.x, y: end.y - thickness / 2))
        context.stroke(topPath, with: .color(RenaissanceColors.blueprintBlue), style: StrokeStyle(lineWidth: 1.5, lineCap: .round))

        // Bottom surface
        var bottomPath = Path()
        bottomPath.move(to: CGPoint(x: start.x, y: start.y + thickness / 2))
        bottomPath.addLine(to: CGPoint(x: end.x, y: end.y + thickness / 2))
        context.stroke(bottomPath, with: .color(RenaissanceColors.blueprintBlue), style: StrokeStyle(lineWidth: 1.5, lineCap: .round))

        // Fill between
        var fillPath = Path()
        fillPath.move(to: CGPoint(x: start.x, y: start.y - thickness / 2))
        fillPath.addLine(to: CGPoint(x: end.x, y: end.y - thickness / 2))
        fillPath.addLine(to: CGPoint(x: end.x, y: end.y + thickness / 2))
        fillPath.addLine(to: CGPoint(x: start.x, y: start.y + thickness / 2))
        fillPath.closeSubpath()
        context.fill(fillPath, with: .color(RenaissanceColors.blueprintBlue.opacity(0.08)))

        // Arch supports (decorative)
        let archCount = 5
        let dx = end.x - start.x
        let dy = end.y - start.y
        for i in 1...archCount {
            let t = CGFloat(i) / CGFloat(archCount + 1)
            let cx = start.x + dx * t
            let cy = start.y + dy * t + thickness / 2
            let archHeight: CGFloat = 25

            var archPath = Path()
            archPath.move(to: CGPoint(x: cx - 12, y: cy))
            archPath.addQuadCurve(
                to: CGPoint(x: cx + 12, y: cy),
                control: CGPoint(x: cx, y: cy + archHeight)
            )
            // Vertical legs
            archPath.move(to: CGPoint(x: cx - 12, y: cy))
            archPath.addLine(to: CGPoint(x: cx - 12, y: cy + archHeight + 5))
            archPath.move(to: CGPoint(x: cx + 12, y: cy))
            archPath.addLine(to: CGPoint(x: cx + 12, y: cy + archHeight + 5))

            context.stroke(archPath, with: .color(RenaissanceColors.blueprintBlue.opacity(0.4)), style: StrokeStyle(lineWidth: 1, lineCap: .round))
        }
    }

    // MARK: - Dimension Lines

    private func drawDimensionLine(context: GraphicsContext, from start: CGPoint, to end: CGPoint, label: String, horizontal: Bool) {
        let color = RenaissanceColors.warmBrown

        // Main line
        var linePath = Path()
        linePath.move(to: start)
        linePath.addLine(to: end)
        context.stroke(linePath, with: .color(color), style: StrokeStyle(lineWidth: 1, lineCap: .round))

        // End ticks
        let tickSize: CGFloat = 6
        if horizontal {
            for pt in [start, end] {
                var tick = Path()
                tick.move(to: CGPoint(x: pt.x, y: pt.y - tickSize))
                tick.addLine(to: CGPoint(x: pt.x, y: pt.y + tickSize))
                context.stroke(tick, with: .color(color), lineWidth: 1)
            }
        } else {
            for pt in [start, end] {
                var tick = Path()
                tick.move(to: CGPoint(x: pt.x - tickSize, y: pt.y))
                tick.addLine(to: CGPoint(x: pt.x + tickSize, y: pt.y))
                context.stroke(tick, with: .color(color), lineWidth: 1)
            }
        }

        // Label
        let mid = CGPoint(x: (start.x + end.x) / 2, y: (start.y + end.y) / 2)
        let labelText = Text(label)
            .font(.custom("Cinzel-Bold", size: 13))
            .foregroundColor(color)

        if horizontal {
            context.draw(context.resolve(labelText), at: CGPoint(x: mid.x, y: mid.y - 12), anchor: .center)
        } else {
            context.draw(context.resolve(labelText), at: CGPoint(x: mid.x + 20, y: mid.y), anchor: .leading)
        }
    }

    // MARK: - Water Drops

    private func drawWaterDrops(context: GraphicsContext, from start: CGPoint, to end: CGPoint, thickness: CGFloat) {
        let dropCount = 6
        let dx = end.x - start.x
        let dy = end.y - start.y

        for i in 0..<dropCount {
            let baseT = CGFloat(i) / CGFloat(dropCount)
            let t = (baseT + waterOffset).truncatingRemainder(dividingBy: 1.0)
            let cx = start.x + dx * t
            let cy = start.y + dy * t
            let dropSize: CGFloat = 5

            var dropPath = Path()
            dropPath.addEllipse(in: CGRect(
                x: cx - dropSize / 2,
                y: cy - dropSize / 2,
                width: dropSize,
                height: dropSize
            ))
            context.fill(dropPath, with: .color(RenaissanceColors.renaissanceBlue.opacity(0.7)))
        }
    }

    // MARK: - Water Animation

    private func startWaterAnimation() {
        guard !waterAnimating else { return }
        waterAnimating = true
        withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
            waterOffset = 1.0
        }
    }

    // MARK: - Step Labels

    @ViewBuilder
    private var stepLabel: some View {
        switch currentStep {
        case 0:
            Text("Tap \"Next Step\" to begin")
                .font(.custom("EBGaramond-Italic", size: 15))
                .foregroundStyle(RenaissanceColors.stoneGray)
        case 1:
            Text("A flat aqueduct channel sits on its stone arches.")
                .font(.system(size: 16))
                .foregroundStyle(RenaissanceColors.sepiaInk)
        case 2:
            Text("The channel tilts slightly downhill. The horizontal distance is **200 meters**.")
                .font(.system(size: 16))
                .foregroundStyle(RenaissanceColors.sepiaInk)
        case 3:
            VStack(alignment: .leading, spacing: 4) {
                Text("The drop is just **1 meter** over that distance.")
                    .font(.system(size: 16))
                    .foregroundStyle(RenaissanceColors.sepiaInk)
                Text("Gradient = drop / distance = 1 : 200")
                    .font(.custom("Cinzel-Bold", size: 14))
                    .foregroundStyle(RenaissanceColors.blueprintBlue)
            }
        case 4:
            Text("Water flows down this gentle slope using only **gravity** -- no pumps needed!")
                .font(.system(size: 16))
                .foregroundStyle(RenaissanceColors.sepiaInk)
        case 5:
            HStack(spacing: 6) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(RenaissanceColors.sageGreen)
                Text("A 1:200 gradient means 1 meter of drop for every 200 meters of length. This tiny tilt kept water flowing across entire countries.")
                    .font(.system(size: 16))
                    .foregroundStyle(RenaissanceColors.sepiaInk)
            }
        default:
            EmptyView()
        }
    }
}
