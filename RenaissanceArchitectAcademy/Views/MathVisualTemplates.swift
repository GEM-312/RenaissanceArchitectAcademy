import SwiftUI

// MARK: - Blueprint Grid (shared background for all math visuals)

struct BlueprintGrid: View {
    var height: CGFloat = 220

    var body: some View {
        Canvas { context, size in
            let spacing: CGFloat = 20
            for x in stride(from: 0, through: size.width, by: spacing) {
                var path = Path()
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
                context.stroke(path, with: .color(RenaissanceColors.ochre.opacity(0.12)), lineWidth: 0.5)
            }
            for y in stride(from: 0, through: size.height, by: spacing) {
                var path = Path()
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                context.stroke(path, with: .color(RenaissanceColors.ochre.opacity(0.12)), lineWidth: 0.5)
            }
        }
        .frame(height: height)
    }
}

// MARK: - Ratio Diagram Visual
/// Shows two quantities being compared with animated bars (gradient, height ratio, gear ratio, etc.)

struct RatioDiagramVisual: View {
    @Binding var currentStep: Int
    let config: Config

    struct Config {
        let leftLabel: String
        let rightLabel: String
        let leftValue: String
        let rightValue: String
        let ratio: String
        let structureIcon: String
        let resultText: String
    }

    @State private var animateFlow = false

    var body: some View {
        ZStack {
            BlueprintGrid(height: 220)

            Canvas { context, size in
                drawDiagram(context: context, size: size)
            }
            .frame(height: 220)

            VStack {
                Spacer()
                Text(stepLabel)
                    .font(.custom("Mulish-Light", size: 12))
                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.6))
                    .padding(.bottom, 8)
            }
            .frame(height: 220)
        }
        .background(RenaissanceColors.parchment)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(RenaissanceColors.ochre.opacity(0.25), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .onChange(of: currentStep) { _, newStep in
            if newStep >= 4 {
                withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                    animateFlow = true
                }
            }
        }
    }

    private var stepLabel: String {
        switch currentStep {
        case 0: return "Tap Next Step to begin"
        case 1: return "The structure appears"
        case 2: return "\(config.rightLabel): \(config.rightValue)"
        case 3: return "Ratio = \(config.ratio)"
        case 4: return "Watch the flow"
        case 5: return config.resultText
        default: return ""
        }
    }

    private func drawDiagram(context: GraphicsContext, size: CGSize) {
        let midY = size.height * 0.45
        let leftX = size.width * 0.1
        let rightX = size.width * 0.9
        let barHeight: CGFloat = 14

        guard currentStep >= 1 else { return }

        // Step 1: Structure bar
        let tiltDrop: CGFloat = currentStep >= 2 ? 30 : 0
        var barPath = Path()
        barPath.move(to: CGPoint(x: leftX, y: midY))
        barPath.addLine(to: CGPoint(x: rightX, y: midY + tiltDrop))
        barPath.addLine(to: CGPoint(x: rightX, y: midY + tiltDrop + barHeight))
        barPath.addLine(to: CGPoint(x: leftX, y: midY + barHeight))
        barPath.closeSubpath()
        context.fill(barPath, with: .color(RenaissanceColors.warmBrown.opacity(0.2)))
        context.stroke(barPath, with: .color(RenaissanceColors.warmBrown.opacity(0.6)), lineWidth: 1.5)

        // Support arches
        let archCount = 4
        for i in 0..<archCount {
            let frac = CGFloat(i + 1) / CGFloat(archCount + 1)
            let x = leftX + (rightX - leftX) * frac
            let topY = midY + tiltDrop * frac + barHeight
            var arch = Path()
            arch.addArc(center: CGPoint(x: x, y: topY + 25),
                       radius: 18, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
            context.stroke(arch, with: .color(RenaissanceColors.warmBrown.opacity(0.3)), lineWidth: 1)
        }

        guard currentStep >= 2 else { return }

        // Step 2: Horizontal dimension line
        let dimY = midY + tiltDrop + barHeight + 50
        var hLine = Path()
        hLine.move(to: CGPoint(x: leftX, y: dimY))
        hLine.addLine(to: CGPoint(x: rightX, y: dimY))
        context.stroke(hLine, with: .color(RenaissanceColors.terracotta), lineWidth: 1)
        for x in [leftX, rightX] {
            var tick = Path()
            tick.move(to: CGPoint(x: x, y: dimY - 4))
            tick.addLine(to: CGPoint(x: x, y: dimY + 4))
            context.stroke(tick, with: .color(RenaissanceColors.terracotta), lineWidth: 1)
        }
        let dimLabel = Text(config.rightValue)
            .font(.custom("Mulish-SemiBold", size: 13))
            .foregroundColor(RenaissanceColors.sepiaInk)
        context.draw(context.resolve(dimLabel), at: CGPoint(x: (leftX + rightX) / 2, y: dimY + 14), anchor: .center)

        guard currentStep >= 3 else { return }

        // Step 3: Vertical dimension + ratio
        var vLine = Path()
        vLine.move(to: CGPoint(x: leftX - 10, y: midY))
        vLine.addLine(to: CGPoint(x: leftX - 10, y: midY + tiltDrop))
        context.stroke(vLine, with: .color(RenaissanceColors.terracotta), lineWidth: 1)
        let vertLabel = Text(config.leftValue)
            .font(.custom("Mulish-SemiBold", size: 12))
            .foregroundColor(RenaissanceColors.sepiaInk)
        context.draw(context.resolve(vertLabel), at: CGPoint(x: leftX - 30, y: midY + tiltDrop / 2), anchor: .center)

        let ratioLabel = Text(config.ratio)
            .font(.custom("Mulish-Bold", size: 24))
            .foregroundColor(RenaissanceColors.sepiaInk)
        context.draw(context.resolve(ratioLabel), at: CGPoint(x: size.width / 2, y: midY - 25), anchor: .center)

        guard currentStep >= 4 else { return }

        // Step 4: Animated flow dots
        let dotCount = 6
        let offset = animateFlow ? size.width : 0
        for i in 0..<dotCount {
            let frac = (CGFloat(i) / CGFloat(dotCount) + offset / size.width).truncatingRemainder(dividingBy: 1.0)
            let x = leftX + (rightX - leftX) * frac
            let y = midY + tiltDrop * frac + barHeight / 2
            let dot = Path(ellipseIn: CGRect(x: x - 4, y: y - 4, width: 8, height: 8))
            context.fill(dot, with: .color(RenaissanceColors.renaissanceBlue.opacity(0.6)))
        }

        guard currentStep >= 5 else { return }

        // Step 5: Checkmark
        let checkText = Text(Image(systemName: "checkmark.circle.fill"))
            .font(.system(size: 20))
            .foregroundColor(RenaissanceColors.sageGreen)
        context.draw(context.resolve(checkText), at: CGPoint(x: size.width - 20, y: 20), anchor: .center)
    }
}

// MARK: - Force Arrow Visual
/// Shows forces acting on a structure with animated arrows

struct ForceArrowVisual: View {
    @Binding var currentStep: Int
    let config: ForceConfig

    struct ForceConfig {
        let structureName: String
        let downForce: String
        let upForce: String
        let sideForces: String
        let resultText: String
    }

    @State private var arrowPulse = false

    var body: some View {
        ZStack {
            BlueprintGrid(height: 220)

            Canvas { context, size in
                drawForces(context: context, size: size)
            }
            .frame(height: 220)

            VStack {
                Spacer()
                Text(stepLabel)
                    .font(.custom("Mulish-Light", size: 12))
                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.6))
                    .padding(.bottom, 8)
            }
            .frame(height: 220)
        }
        .background(RenaissanceColors.parchment)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(RenaissanceColors.ochre.opacity(0.25), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .onChange(of: currentStep) { _, newStep in
            if newStep >= 4 {
                withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                    arrowPulse = true
                }
            }
        }
    }

    private var stepLabel: String {
        switch currentStep {
        case 0: return "Tap Next Step to begin"
        case 1: return "The \(config.structureName) stands"
        case 2: return config.downForce
        case 3: return config.sideForces
        case 4: return config.upForce
        case 5: return config.resultText
        default: return ""
        }
    }

    private func drawForces(context: GraphicsContext, size: CGSize) {
        let cx = size.width / 2
        let cy = size.height * 0.45

        guard currentStep >= 1 else { return }

        // Structure: arch shape
        var arch = Path()
        arch.addArc(center: CGPoint(x: cx, y: cy + 30), radius: 60,
                   startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
        arch.addLine(to: CGPoint(x: cx + 60, y: cy + 70))
        arch.addLine(to: CGPoint(x: cx - 60, y: cy + 70))
        arch.closeSubpath()
        context.fill(arch, with: .color(RenaissanceColors.warmBrown.opacity(0.15)))
        context.stroke(arch, with: .color(RenaissanceColors.warmBrown.opacity(0.6)), lineWidth: 1.5)

        // Keystone
        let ks = Path(ellipseIn: CGRect(x: cx - 8, y: cy - 32, width: 16, height: 16))
        context.fill(ks, with: .color(RenaissanceColors.ochre.opacity(0.3)))
        context.stroke(ks, with: .color(RenaissanceColors.ochre), lineWidth: 1)

        guard currentStep >= 2 else { return }

        // Down arrow (weight)
        let arrowLen: CGFloat = arrowPulse ? 45 : 40
        drawArrow(context: context, from: CGPoint(x: cx, y: cy - 55),
                 to: CGPoint(x: cx, y: cy - 55 + arrowLen),
                 color: RenaissanceColors.errorRed.opacity(0.7), lineWidth: 2)
        let downLabel = Text(config.downForce)
            .font(.custom("Mulish-SemiBold", size: 11))
            .foregroundColor(RenaissanceColors.errorRed)
        context.draw(context.resolve(downLabel), at: CGPoint(x: cx, y: cy - 65), anchor: .center)

        guard currentStep >= 3 else { return }

        // Side arrows (compression)
        let sideLen: CGFloat = arrowPulse ? 35 : 30
        drawArrow(context: context, from: CGPoint(x: cx - 70, y: cy + 20),
                 to: CGPoint(x: cx - 70 + sideLen, y: cy + 50),
                 color: RenaissanceColors.renaissanceBlue.opacity(0.7), lineWidth: 1.5)
        drawArrow(context: context, from: CGPoint(x: cx + 70, y: cy + 20),
                 to: CGPoint(x: cx + 70 - sideLen, y: cy + 50),
                 color: RenaissanceColors.renaissanceBlue.opacity(0.7), lineWidth: 1.5)
        let sideLabel = Text(config.sideForces)
            .font(.custom("Mulish-SemiBold", size: 11))
            .foregroundColor(RenaissanceColors.sepiaInk)
        context.draw(context.resolve(sideLabel), at: CGPoint(x: cx, y: cy + 85), anchor: .center)

        guard currentStep >= 4 else { return }

        // Up arrows (support)
        drawArrow(context: context, from: CGPoint(x: cx - 55, y: cy + 75),
                 to: CGPoint(x: cx - 55, y: cy + 75 - arrowLen),
                 color: RenaissanceColors.sageGreen.opacity(0.7), lineWidth: 2)
        drawArrow(context: context, from: CGPoint(x: cx + 55, y: cy + 75),
                 to: CGPoint(x: cx + 55, y: cy + 75 - arrowLen),
                 color: RenaissanceColors.sageGreen.opacity(0.7), lineWidth: 2)

        guard currentStep >= 5 else { return }
        let checkText = Text(Image(systemName: "checkmark.circle.fill"))
            .font(.system(size: 20))
            .foregroundColor(RenaissanceColors.sageGreen)
        context.draw(context.resolve(checkText), at: CGPoint(x: size.width - 20, y: 20), anchor: .center)
    }

    private func drawArrow(context: GraphicsContext, from: CGPoint, to: CGPoint, color: Color, lineWidth: CGFloat) {
        var line = Path()
        line.move(to: from)
        line.addLine(to: to)
        context.stroke(line, with: .color(color), lineWidth: lineWidth)
        let dx = to.x - from.x
        let dy = to.y - from.y
        let len = sqrt(dx*dx + dy*dy)
        guard len > 0 else { return }
        let ux = dx / len
        let uy = dy / len
        let headSize: CGFloat = 8
        var head = Path()
        head.move(to: to)
        head.addLine(to: CGPoint(x: to.x - headSize * ux + headSize * 0.4 * uy,
                                y: to.y - headSize * uy - headSize * 0.4 * ux))
        head.addLine(to: CGPoint(x: to.x - headSize * ux - headSize * 0.4 * uy,
                                y: to.y - headSize * uy + headSize * 0.4 * ux))
        head.closeSubpath()
        context.fill(head, with: .color(color))
    }
}

// MARK: - Flow Cycle Visual
/// Shows animated particles flowing through a circular/linear path

struct FlowCycleVisual: View {
    @Binding var currentStep: Int
    let config: FlowConfig

    struct FlowConfig {
        let stages: [String]
        let inputLabel: String
        let outputLabel: String
        let centerLabel: String
        let resultText: String
    }

    @State private var flowAngle: Double = 0

    var body: some View {
        ZStack {
            BlueprintGrid(height: 220)

            Canvas { context, size in
                drawCycle(context: context, size: size)
            }
            .frame(height: 220)

            VStack {
                Spacer()
                Text(stepLabel)
                    .font(.custom("Mulish-Light", size: 12))
                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.6))
                    .padding(.bottom, 8)
            }
            .frame(height: 220)
        }
        .background(RenaissanceColors.parchment)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(RenaissanceColors.ochre.opacity(0.25), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .onChange(of: currentStep) { _, newStep in
            if newStep >= 4 {
                withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                    flowAngle = 360
                }
            }
        }
    }

    private var stepLabel: String {
        switch currentStep {
        case 0: return "Tap Next Step to begin"
        case 1: return "The cycle begins"
        case 2: return config.inputLabel
        case 3: return config.outputLabel
        case 4: return "Watch the cycle flow"
        case 5: return config.resultText
        default: return ""
        }
    }

    private func drawCycle(context: GraphicsContext, size: CGSize) {
        let cx = size.width / 2
        let cy = size.height * 0.42
        let radius: CGFloat = 65

        guard currentStep >= 1 else { return }

        // Circle path
        let circlePath = Path(ellipseIn: CGRect(x: cx - radius, y: cy - radius, width: radius * 2, height: radius * 2))
        context.stroke(circlePath, with: .color(RenaissanceColors.ochre.opacity(0.3)), lineWidth: 1.5)

        // Center label
        let centerText = Text(config.centerLabel)
            .font(.custom("Mulish-Bold", size: 16))
            .foregroundColor(RenaissanceColors.sepiaInk)
        context.draw(context.resolve(centerText), at: CGPoint(x: cx, y: cy), anchor: .center)

        // Stage labels around the circle
        let angles: [Double] = [-90, 0, 90, 180]
        let stageCount = min(config.stages.count, 4)
        for i in 0..<stageCount {
            let angle = angles[i] * .pi / 180
            let lx = cx + (radius + 35) * cos(angle)
            let ly = cy + (radius + 35) * sin(angle)
            if currentStep >= i + 1 {
                let stageText = Text(config.stages[i])
                    .font(.custom("Mulish-SemiBold", size: 11))
                    .foregroundColor(RenaissanceColors.sepiaInk)
                context.draw(context.resolve(stageText), at: CGPoint(x: lx, y: ly), anchor: .center)
            }
        }

        guard currentStep >= 2 else { return }

        // Input arrow (left)
        let inputText = Text("\u{2192} \(config.inputLabel)")
            .font(.custom("Mulish-SemiBold", size: 12))
            .foregroundColor(RenaissanceColors.sepiaInk)
        context.draw(context.resolve(inputText), at: CGPoint(x: cx - radius - 55, y: cy - 15), anchor: .center)

        guard currentStep >= 3 else { return }

        // Output arrow (right)
        let outputText = Text("\(config.outputLabel) \u{2192}")
            .font(.custom("Mulish-SemiBold", size: 12))
            .foregroundColor(RenaissanceColors.sageGreen)
        context.draw(context.resolve(outputText), at: CGPoint(x: cx + radius + 55, y: cy + 15), anchor: .center)

        guard currentStep >= 4 else { return }

        // Animated dots around circle
        let dotCount = 4
        for i in 0..<dotCount {
            let angle = (flowAngle + Double(i) * 90) * .pi / 180
            let dx = cx + radius * cos(angle)
            let dy = cy + radius * sin(angle)
            let dot = Path(ellipseIn: CGRect(x: dx - 4, y: dy - 4, width: 8, height: 8))
            context.fill(dot, with: .color(RenaissanceColors.renaissanceBlue.opacity(0.6)))
        }

        guard currentStep >= 5 else { return }
        let checkText = Text(Image(systemName: "checkmark.circle.fill"))
            .font(.system(size: 20))
            .foregroundColor(RenaissanceColors.sageGreen)
        context.draw(context.resolve(checkText), at: CGPoint(x: size.width - 20, y: 20), anchor: .center)
    }
}

// MARK: - Graph Curve Visual
/// Shows an animated curve being plotted on axes (trajectory, growth, temperature)

struct GraphCurveVisual: View {
    @Binding var currentStep: Int
    let config: GraphConfig

    struct GraphConfig {
        let xLabel: String
        let yLabel: String
        let curveType: CurveType
        let peakLabel: String
        let formulaText: String
        let resultText: String

        enum CurveType {
            case parabola
            case exponential
            case sine
            case linear
        }
    }

    @State private var drawProgress: CGFloat = 0

    var body: some View {
        ZStack {
            BlueprintGrid(height: 220)

            Canvas { context, size in
                drawGraph(context: context, size: size)
            }
            .frame(height: 220)

            VStack {
                Spacer()
                Text(stepLabel)
                    .font(.custom("Mulish-Light", size: 12))
                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.6))
                    .padding(.bottom, 8)
            }
            .frame(height: 220)
        }
        .background(RenaissanceColors.parchment)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(RenaissanceColors.ochre.opacity(0.25), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .onChange(of: currentStep) { _, newStep in
            if newStep >= 3 {
                withAnimation(.easeInOut(duration: 2)) {
                    drawProgress = 1
                }
            }
        }
    }

    private var stepLabel: String {
        switch currentStep {
        case 0: return "Tap Next Step to begin"
        case 1: return "Setting up the axes"
        case 2: return config.formulaText
        case 3: return "Watch the curve form"
        case 4: return config.peakLabel
        case 5: return config.resultText
        default: return ""
        }
    }

    private func drawGraph(context: GraphicsContext, size: CGSize) {
        let originX = size.width * 0.12
        let originY = size.height * 0.78
        let axisW = size.width * 0.8
        let axisH = size.height * 0.6

        guard currentStep >= 1 else { return }

        // Axes
        var axes = Path()
        axes.move(to: CGPoint(x: originX, y: originY - axisH))
        axes.addLine(to: CGPoint(x: originX, y: originY))
        axes.addLine(to: CGPoint(x: originX + axisW, y: originY))
        context.stroke(axes, with: .color(RenaissanceColors.sepiaInk.opacity(0.5)), lineWidth: 1.5)

        // Axis labels
        let xLabelText = Text(config.xLabel)
            .font(.custom("Mulish-Light", size: 10))
            .foregroundColor(RenaissanceColors.sepiaInk.opacity(0.6))
        context.draw(context.resolve(xLabelText), at: CGPoint(x: originX + axisW / 2, y: originY + 15), anchor: .center)

        let yLabelText = Text(config.yLabel)
            .font(.custom("Mulish-Light", size: 10))
            .foregroundColor(RenaissanceColors.sepiaInk.opacity(0.6))
        context.draw(context.resolve(yLabelText), at: CGPoint(x: originX - 15, y: originY - axisH / 2), anchor: .center)

        guard currentStep >= 2 else { return }

        // Formula
        let formulaText = Text(config.formulaText)
            .font(.custom("Mulish-SemiBold", size: 14))
            .foregroundColor(RenaissanceColors.sepiaInk)
        context.draw(context.resolve(formulaText), at: CGPoint(x: originX + axisW * 0.6, y: originY - axisH - 10), anchor: .center)

        guard currentStep >= 3 else { return }

        // Curve
        var curve = Path()
        let points = 50
        let end = Int(CGFloat(points) * drawProgress)
        for i in 0...max(end, 0) {
            let t = CGFloat(i) / CGFloat(points)
            let x = originX + axisW * t
            let y: CGFloat
            switch config.curveType {
            case .parabola:
                y = originY - axisH * 4 * t * (1 - t)
            case .exponential:
                y = originY - axisH * (1 - exp(-3 * t))
            case .sine:
                y = originY - axisH * 0.5 * (1 + sin(t * .pi * 3))
            case .linear:
                y = originY - axisH * t
            }
            if i == 0 { curve.move(to: CGPoint(x: x, y: y)) }
            else { curve.addLine(to: CGPoint(x: x, y: y)) }
        }
        context.stroke(curve, with: .color(RenaissanceColors.renaissanceBlue), lineWidth: 2)

        guard currentStep >= 4 else { return }

        // Peak marker
        let peakT: CGFloat
        switch config.curveType {
        case .parabola: peakT = 0.5
        case .exponential: peakT = 0.9
        case .sine: peakT = 0.167
        case .linear: peakT = 1.0
        }
        let peakX = originX + axisW * peakT
        let peakY: CGFloat
        switch config.curveType {
        case .parabola: peakY = originY - axisH
        case .exponential: peakY = originY - axisH * 0.95
        case .sine: peakY = originY - axisH
        case .linear: peakY = originY - axisH
        }
        let marker = Path(ellipseIn: CGRect(x: peakX - 5, y: peakY - 5, width: 10, height: 10))
        context.fill(marker, with: .color(RenaissanceColors.goldSuccess))
        let peakText = Text(config.peakLabel)
            .font(.custom("Mulish-SemiBold", size: 11))
            .foregroundColor(RenaissanceColors.goldSuccess)
        context.draw(context.resolve(peakText), at: CGPoint(x: peakX, y: peakY - 15), anchor: .center)

        guard currentStep >= 5 else { return }
        let checkText = Text(Image(systemName: "checkmark.circle.fill"))
            .font(.system(size: 20))
            .foregroundColor(RenaissanceColors.sageGreen)
        context.draw(context.resolve(checkText), at: CGPoint(x: size.width - 20, y: 20), anchor: .center)
    }
}

// MARK: - Layer Stack Visual
/// Shows stacked layers building up (road cross-section, dome layers, soil layers)

struct LayerStackVisual: View {
    @Binding var currentStep: Int
    let config: LayerConfig

    struct LayerConfig {
        let layers: [(name: String, thickness: CGFloat, color: Color)]
        let totalLabel: String
        let resultText: String
    }

    var body: some View {
        ZStack {
            BlueprintGrid(height: 220)

            Canvas { context, size in
                drawLayers(context: context, size: size)
            }
            .frame(height: 220)

            VStack {
                Spacer()
                Text(stepLabel)
                    .font(.custom("Mulish-Light", size: 12))
                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.6))
                    .padding(.bottom, 8)
            }
            .frame(height: 220)
        }
        .background(RenaissanceColors.parchment)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(RenaissanceColors.ochre.opacity(0.25), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var stepLabel: String {
        let layerCount = config.layers.count
        switch currentStep {
        case 0: return "Tap Next Step to begin"
        case 1...layerCount:
            return "Layer \(currentStep): \(config.layers[currentStep - 1].name)"
        case layerCount + 1: return config.totalLabel
        case layerCount + 2: return config.resultText
        default: return ""
        }
    }

    private func drawLayers(context: GraphicsContext, size: CGSize) {
        let leftX = size.width * 0.15
        let rightX = size.width * 0.85
        let bottomY = size.height * 0.8
        let maxHeight = size.height * 0.6
        let totalThickness = config.layers.reduce(0) { $0 + $1.thickness }

        var currentY = bottomY

        for (index, layer) in config.layers.enumerated() {
            guard currentStep >= index + 1 else { break }

            let layerH = maxHeight * (layer.thickness / totalThickness)
            let rect = CGRect(x: leftX, y: currentY - layerH, width: rightX - leftX, height: layerH)

            context.fill(Path(rect), with: .color(layer.color.opacity(0.3)))
            context.stroke(Path(rect), with: .color(layer.color.opacity(0.6)), lineWidth: 1)

            let nameText = Text(layer.name)
                .font(.custom("Mulish-SemiBold", size: 11))
                .foregroundColor(RenaissanceColors.sepiaInk)
            context.draw(context.resolve(nameText), at: CGPoint(x: (leftX + rightX) / 2, y: currentY - layerH / 2), anchor: .center)

            currentY -= layerH
        }

        // Total dimension line
        if currentStep >= config.layers.count + 1 {
            let topY = bottomY - maxHeight
            var dimLine = Path()
            dimLine.move(to: CGPoint(x: rightX + 15, y: bottomY))
            dimLine.addLine(to: CGPoint(x: rightX + 15, y: topY))
            context.stroke(dimLine, with: .color(RenaissanceColors.terracotta), lineWidth: 1)

            let totalText = Text(config.totalLabel)
                .font(.custom("Mulish-SemiBold", size: 12))
                .foregroundColor(RenaissanceColors.sepiaInk)
            context.draw(context.resolve(totalText), at: CGPoint(x: rightX + 50, y: (bottomY + topY) / 2), anchor: .center)
        }

        if currentStep >= config.layers.count + 2 {
            let checkText = Text(Image(systemName: "checkmark.circle.fill"))
                .font(.system(size: 20))
                .foregroundColor(RenaissanceColors.sageGreen)
            context.draw(context.resolve(checkText), at: CGPoint(x: size.width - 20, y: 20), anchor: .center)
        }
    }
}

// MARK: - Mechanism Visual
/// Shows a mechanical system with moving parts (gears, pulleys, levers, presses)

struct MechanismVisual: View {
    @Binding var currentStep: Int
    let config: MechConfig

    struct MechConfig {
        let mechanismType: MechType
        let inputLabel: String
        let outputLabel: String
        let advantageLabel: String
        let formulaText: String
        let resultText: String

        enum MechType {
            case lever
            case pulley
            case gear
            case press
        }
    }

    @State private var rotation: Double = 0

    var body: some View {
        ZStack {
            BlueprintGrid(height: 220)

            Canvas { context, size in
                drawMechanism(context: context, size: size)
            }
            .frame(height: 220)

            VStack {
                Spacer()
                Text(stepLabel)
                    .font(.custom("Mulish-Light", size: 12))
                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.6))
                    .padding(.bottom, 8)
            }
            .frame(height: 220)
        }
        .background(RenaissanceColors.parchment)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(RenaissanceColors.ochre.opacity(0.25), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .onChange(of: currentStep) { _, newStep in
            if newStep >= 4 {
                withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
            }
        }
    }

    private var stepLabel: String {
        switch currentStep {
        case 0: return "Tap Next Step to begin"
        case 1: return "The mechanism"
        case 2: return config.inputLabel
        case 3: return config.formulaText
        case 4: return config.outputLabel
        case 5: return config.resultText
        default: return ""
        }
    }

    private func drawMechanism(context: GraphicsContext, size: CGSize) {
        let cx = size.width / 2
        let cy = size.height * 0.42

        guard currentStep >= 1 else { return }

        switch config.mechanismType {
        case .gear:
            drawGears(context: context, cx: cx, cy: cy, size: size)
        case .lever:
            drawLever(context: context, cx: cx, cy: cy, size: size)
        case .pulley:
            drawPulley(context: context, cx: cx, cy: cy, size: size)
        case .press:
            drawPress(context: context, cx: cx, cy: cy, size: size)
        }

        if currentStep >= 5 {
            let checkText = Text(Image(systemName: "checkmark.circle.fill"))
                .font(.system(size: 20))
                .foregroundColor(RenaissanceColors.sageGreen)
            context.draw(context.resolve(checkText), at: CGPoint(x: size.width - 20, y: 20), anchor: .center)
        }
    }

    private func drawGears(context: GraphicsContext, cx: CGFloat, cy: CGFloat, size: CGSize) {
        // Large gear
        let r1: CGFloat = 45
        let gear1 = Path(ellipseIn: CGRect(x: cx - 55 - r1, y: cy - r1, width: r1 * 2, height: r1 * 2))
        context.stroke(gear1, with: .color(RenaissanceColors.warmBrown.opacity(0.6)), lineWidth: 2)
        let teethCount1 = 12
        for i in 0..<teethCount1 {
            let angle = (Double(i) / Double(teethCount1) * 360 + rotation) * .pi / 180
            let tx = cx - 55 + (r1 + 6) * cos(angle)
            let ty = cy + (r1 + 6) * sin(angle)
            let tooth = Path(CGRect(x: tx - 2, y: ty - 2, width: 4, height: 4))
            context.fill(tooth, with: .color(RenaissanceColors.warmBrown.opacity(0.4)))
        }
        let center1 = Path(ellipseIn: CGRect(x: cx - 55 - 4, y: cy - 4, width: 8, height: 8))
        context.fill(center1, with: .color(RenaissanceColors.warmBrown))

        // Small gear
        let r2: CGFloat = 25
        let gear2 = Path(ellipseIn: CGRect(x: cx + 20 - r2, y: cy - r2, width: r2 * 2, height: r2 * 2))
        context.stroke(gear2, with: .color(RenaissanceColors.renaissanceBlue.opacity(0.6)), lineWidth: 2)
        let teethCount2 = 8
        for i in 0..<teethCount2 {
            let angle = (-Double(i) / Double(teethCount2) * 360 - rotation * Double(teethCount1) / Double(teethCount2)) * .pi / 180
            let tx = cx + 20 + (r2 + 5) * cos(angle)
            let ty = cy + (r2 + 5) * sin(angle)
            let tooth = Path(CGRect(x: tx - 2, y: ty - 2, width: 4, height: 4))
            context.fill(tooth, with: .color(RenaissanceColors.renaissanceBlue.opacity(0.4)))
        }
        let center2 = Path(ellipseIn: CGRect(x: cx + 20 - 4, y: cy - 4, width: 8, height: 8))
        context.fill(center2, with: .color(RenaissanceColors.renaissanceBlue))

        if currentStep >= 2 {
            let inputText = Text(config.inputLabel)
                .font(.custom("Mulish-SemiBold", size: 11))
                .foregroundColor(RenaissanceColors.sepiaInk)
            context.draw(context.resolve(inputText), at: CGPoint(x: cx - 55, y: cy + r1 + 18), anchor: .center)
        }
        if currentStep >= 3 {
            let advText = Text(config.advantageLabel)
                .font(.custom("Mulish-Bold", size: 20))
                .foregroundColor(RenaissanceColors.sepiaInk)
            context.draw(context.resolve(advText), at: CGPoint(x: cx, y: cy - r1 - 20), anchor: .center)
        }
        if currentStep >= 4 {
            let outputText = Text(config.outputLabel)
                .font(.custom("Mulish-SemiBold", size: 11))
                .foregroundColor(RenaissanceColors.sepiaInk)
            context.draw(context.resolve(outputText), at: CGPoint(x: cx + 20, y: cy + r2 + 18), anchor: .center)
        }
    }

    private func drawLever(context: GraphicsContext, cx: CGFloat, cy: CGFloat, size: CGSize) {
        // Fulcrum triangle
        let fulcrumX = cx - 20
        var tri = Path()
        tri.move(to: CGPoint(x: fulcrumX, y: cy + 30))
        tri.addLine(to: CGPoint(x: fulcrumX - 15, y: cy + 55))
        tri.addLine(to: CGPoint(x: fulcrumX + 15, y: cy + 55))
        tri.closeSubpath()
        context.fill(tri, with: .color(RenaissanceColors.ochre.opacity(0.3)))
        context.stroke(tri, with: .color(RenaissanceColors.ochre), lineWidth: 1.5)

        // Beam
        let tilt: CGFloat = currentStep >= 2 ? -8 : 0
        var beam = Path()
        beam.move(to: CGPoint(x: cx - 100, y: cy + 25 - tilt))
        beam.addLine(to: CGPoint(x: cx + 80, y: cy + 25 + tilt))
        context.stroke(beam, with: .color(RenaissanceColors.warmBrown), lineWidth: 3)

        if currentStep >= 2 {
            let inputText = Text("\u{2193} \(config.inputLabel)")
                .font(.custom("Mulish-SemiBold", size: 11))
                .foregroundColor(RenaissanceColors.sepiaInk)
            context.draw(context.resolve(inputText), at: CGPoint(x: cx - 80, y: cy), anchor: .center)
        }
        if currentStep >= 3 {
            let formulaText = Text(config.formulaText)
                .font(.custom("Mulish-SemiBold", size: 13))
                .foregroundColor(RenaissanceColors.sepiaInk)
            context.draw(context.resolve(formulaText), at: CGPoint(x: cx, y: cy - 30), anchor: .center)
        }
        if currentStep >= 4 {
            let outputText = Text("\u{2191} \(config.outputLabel)")
                .font(.custom("Mulish-SemiBold", size: 11))
                .foregroundColor(RenaissanceColors.sageGreen)
            context.draw(context.resolve(outputText), at: CGPoint(x: cx + 60, y: cy), anchor: .center)
        }
    }

    private func drawPulley(context: GraphicsContext, cx: CGFloat, cy: CGFloat, size: CGSize) {
        // Support beam
        var support = Path()
        support.move(to: CGPoint(x: cx - 60, y: cy - 50))
        support.addLine(to: CGPoint(x: cx + 60, y: cy - 50))
        context.stroke(support, with: .color(RenaissanceColors.warmBrown), lineWidth: 3)

        // Pulley wheels
        let wheels: [(x: CGFloat, y: CGFloat)] = [(cx - 30, cy - 35), (cx + 30, cy - 35)]
        for wheel in wheels {
            let r: CGFloat = 15
            let circle = Path(ellipseIn: CGRect(x: wheel.x - r, y: wheel.y - r, width: r * 2, height: r * 2))
            context.stroke(circle, with: .color(RenaissanceColors.warmBrown.opacity(0.6)), lineWidth: 2)
            let center = Path(ellipseIn: CGRect(x: wheel.x - 3, y: wheel.y - 3, width: 6, height: 6))
            context.fill(center, with: .color(RenaissanceColors.warmBrown))
        }

        // Rope
        var rope = Path()
        rope.move(to: CGPoint(x: cx - 60, y: cy + 50))
        rope.addLine(to: CGPoint(x: cx - 30, y: cy - 20))
        rope.addLine(to: CGPoint(x: cx + 30, y: cy - 20))
        rope.addLine(to: CGPoint(x: cx + 30, y: cy + 30))
        context.stroke(rope, with: .color(RenaissanceColors.ochre), lineWidth: 1.5)

        // Weight box
        let box = CGRect(x: cx + 15, y: cy + 30, width: 30, height: 25)
        context.fill(Path(box), with: .color(RenaissanceColors.terracotta.opacity(0.3)))
        context.stroke(Path(box), with: .color(RenaissanceColors.terracotta), lineWidth: 1.5)

        if currentStep >= 2 {
            let inputText = Text(config.inputLabel)
                .font(.custom("Mulish-SemiBold", size: 11))
                .foregroundColor(RenaissanceColors.sepiaInk)
            context.draw(context.resolve(inputText), at: CGPoint(x: cx - 60, y: cy + 65), anchor: .center)
        }
        if currentStep >= 3 {
            let advText = Text(config.advantageLabel)
                .font(.custom("Mulish-Bold", size: 18))
                .foregroundColor(RenaissanceColors.sepiaInk)
            context.draw(context.resolve(advText), at: CGPoint(x: cx, y: cy + 80), anchor: .center)
        }
        if currentStep >= 4 {
            let outputText = Text(config.outputLabel)
                .font(.custom("Mulish-SemiBold", size: 11))
                .foregroundColor(RenaissanceColors.sepiaInk)
            context.draw(context.resolve(outputText), at: CGPoint(x: cx + 30, y: cy + 65), anchor: .center)
        }
    }

    private func drawPress(context: GraphicsContext, cx: CGFloat, cy: CGFloat, size: CGSize) {
        // Press frame
        let frameRect = CGRect(x: cx - 50, y: cy - 40, width: 100, height: 80)
        context.stroke(Path(frameRect), with: .color(RenaissanceColors.warmBrown), lineWidth: 2)

        // Screw
        var screw = Path()
        screw.move(to: CGPoint(x: cx, y: cy - 60))
        screw.addLine(to: CGPoint(x: cx, y: cy - 10))
        context.stroke(screw, with: .color(RenaissanceColors.warmBrown.opacity(0.6)), lineWidth: 3)

        // Handle
        var handle = Path()
        handle.move(to: CGPoint(x: cx - 30, y: cy - 58))
        handle.addLine(to: CGPoint(x: cx + 30, y: cy - 58))
        context.stroke(handle, with: .color(RenaissanceColors.ochre), lineWidth: 2.5)

        // Press plate
        let plateY: CGFloat = currentStep >= 4 ? cy + 5 : cy - 10
        let plate = CGRect(x: cx - 40, y: plateY, width: 80, height: 8)
        context.fill(Path(plate), with: .color(RenaissanceColors.stoneGray.opacity(0.5)))

        if currentStep >= 2 {
            let inputText = Text(config.inputLabel)
                .font(.custom("Mulish-SemiBold", size: 11))
                .foregroundColor(RenaissanceColors.sepiaInk)
            context.draw(context.resolve(inputText), at: CGPoint(x: cx, y: cy - 75), anchor: .center)
        }
        if currentStep >= 3 {
            let advText = Text(config.advantageLabel)
                .font(.custom("Mulish-Bold", size: 18))
                .foregroundColor(RenaissanceColors.sepiaInk)
            context.draw(context.resolve(advText), at: CGPoint(x: cx + 70, y: cy), anchor: .center)
        }
        if currentStep >= 4 {
            let outputText = Text(config.outputLabel)
                .font(.custom("Mulish-SemiBold", size: 11))
                .foregroundColor(RenaissanceColors.sepiaInk)
            context.draw(context.resolve(outputText), at: CGPoint(x: cx, y: cy + 55), anchor: .center)
        }
    }
}

// MARK: - Geometry Diagram Visual
/// Shows geometric shapes with measurements (domes, proportions, spirals, optics)

struct GeometryDiagramVisual: View {
    @Binding var currentStep: Int
    let config: GeoConfig

    struct GeoConfig {
        let shapeType: ShapeType
        let measurements: [(label: String, value: String)]
        let formulaText: String
        let resultText: String

        enum ShapeType {
            case hemisphere
            case circle
            case rectangle
            case spiral
            case lens
        }
    }

    @State private var revealProgress: CGFloat = 0

    var body: some View {
        ZStack {
            BlueprintGrid(height: 220)

            Canvas { context, size in
                drawGeometry(context: context, size: size)
            }
            .frame(height: 220)

            VStack {
                Spacer()
                Text(stepLabel)
                    .font(.custom("Mulish-Light", size: 12))
                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.6))
                    .padding(.bottom, 8)
            }
            .frame(height: 220)
        }
        .background(RenaissanceColors.parchment)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(RenaissanceColors.ochre.opacity(0.25), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .onChange(of: currentStep) { _, newStep in
            if newStep >= 2 {
                withAnimation(.easeInOut(duration: 1.5)) {
                    revealProgress = 1
                }
            }
        }
    }

    private var stepLabel: String {
        switch currentStep {
        case 0: return "Tap Next Step to begin"
        case 1: return "The shape appears"
        case 2: return config.measurements.first.map { "\($0.label): \($0.value)" } ?? ""
        case 3: return config.formulaText
        case 4: return config.measurements.count > 1 ? "\(config.measurements[1].label): \(config.measurements[1].value)" : config.formulaText
        case 5: return config.resultText
        default: return ""
        }
    }

    private func drawGeometry(context: GraphicsContext, size: CGSize) {
        let cx = size.width / 2
        let cy = size.height * 0.5

        guard currentStep >= 1 else { return }

        switch config.shapeType {
        case .hemisphere:
            let r: CGFloat = 70 * clamp(revealProgress, min: 0, max: 1)
            var dome = Path()
            dome.addArc(center: CGPoint(x: cx, y: cy + 10), radius: max(r, 1),
                       startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
            context.stroke(dome, with: .color(RenaissanceColors.warmBrown.opacity(0.6)), lineWidth: 2)
            var base = Path()
            base.move(to: CGPoint(x: cx - r, y: cy + 10))
            base.addLine(to: CGPoint(x: cx + r, y: cy + 10))
            context.stroke(base, with: .color(RenaissanceColors.warmBrown.opacity(0.4)), lineWidth: 1.5)
            if currentStep >= 2 {
                var radiusLine = Path()
                radiusLine.move(to: CGPoint(x: cx, y: cy + 10))
                radiusLine.addLine(to: CGPoint(x: cx + 70, y: cy + 10))
                context.stroke(radiusLine, with: .color(RenaissanceColors.terracotta), lineWidth: 1)
                let rLabel = Text("r")
                    .font(.custom("Mulish-Bold", size: 14))
                    .foregroundColor(RenaissanceColors.sepiaInk)
                context.draw(context.resolve(rLabel), at: CGPoint(x: cx + 35, y: cy + 22), anchor: .center)
            }
            if currentStep >= 3 {
                var heightLine = Path()
                heightLine.move(to: CGPoint(x: cx, y: cy + 10))
                heightLine.addLine(to: CGPoint(x: cx, y: cy + 10 - 70))
                context.stroke(heightLine, with: .color(RenaissanceColors.renaissanceBlue), lineWidth: 1)
                let hLabel = Text("h = r")
                    .font(.custom("Mulish-Bold", size: 14))
                    .foregroundColor(RenaissanceColors.sepiaInk)
                context.draw(context.resolve(hLabel), at: CGPoint(x: cx - 25, y: cy - 30), anchor: .center)
            }

        case .circle:
            let r: CGFloat = 50 * clamp(revealProgress, min: 0, max: 1)
            let circle = Path(ellipseIn: CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2))
            context.stroke(circle, with: .color(RenaissanceColors.warmBrown.opacity(0.6)), lineWidth: 2)
            if currentStep >= 3 {
                for angle in stride(from: -30.0, through: 30.0, by: 15.0) {
                    let rad = angle * .pi / 180
                    var ray = Path()
                    ray.move(to: CGPoint(x: cx + 80 * cos(rad - .pi/2), y: cy - 80))
                    ray.addLine(to: CGPoint(x: cx + 40 * cos(rad), y: cy + 60))
                    context.stroke(ray, with: .color(RenaissanceColors.highlightAmber.opacity(0.3)), lineWidth: 1)
                }
            }

        case .rectangle:
            let w: CGFloat = 100 * clamp(revealProgress, min: 0, max: 1)
            let h: CGFloat = 140 * clamp(revealProgress, min: 0, max: 1)
            let rect = CGRect(x: cx - w/2, y: cy - h/2, width: w, height: h)
            context.stroke(Path(rect), with: .color(RenaissanceColors.warmBrown.opacity(0.6)), lineWidth: 2)

        case .spiral:
            let maxR: CGFloat = 60 * clamp(revealProgress, min: 0, max: 1)
            var spiral = Path()
            let points = 100
            for i in 0...points {
                let t = CGFloat(i) / CGFloat(points) * 4 * .pi
                let r = maxR * t / (4 * .pi)
                let x = cx + r * cos(t)
                let y = cy + r * sin(t)
                if i == 0 { spiral.move(to: CGPoint(x: x, y: y)) }
                else { spiral.addLine(to: CGPoint(x: x, y: y)) }
            }
            context.stroke(spiral, with: .color(RenaissanceColors.renaissanceBlue.opacity(0.6)), lineWidth: 1.5)

        case .lens:
            var lens = Path()
            lens.addArc(center: CGPoint(x: cx - 30, y: cy), radius: 50,
                       startAngle: .degrees(-30), endAngle: .degrees(30), clockwise: false)
            lens.addArc(center: CGPoint(x: cx + 30, y: cy), radius: 50,
                       startAngle: .degrees(150), endAngle: .degrees(210), clockwise: false)
            context.stroke(lens, with: .color(RenaissanceColors.renaissanceBlue.opacity(0.5)), lineWidth: 2)
            if currentStep >= 3 {
                for dy in stride(from: -20.0, through: 20.0, by: 10.0) {
                    var ray = Path()
                    ray.move(to: CGPoint(x: cx - 100, y: cy + dy))
                    ray.addLine(to: CGPoint(x: cx, y: cy + dy))
                    ray.addLine(to: CGPoint(x: cx + 80, y: cy))
                    context.stroke(ray, with: .color(RenaissanceColors.highlightAmber.opacity(0.4)), lineWidth: 1)
                }
            }
        }

        // Formula
        if currentStep >= 3 {
            let formulaText = Text(config.formulaText)
                .font(.custom("Mulish-SemiBold", size: 14))
                .foregroundColor(RenaissanceColors.sepiaInk)
            context.draw(context.resolve(formulaText), at: CGPoint(x: cx, y: size.height * 0.12), anchor: .center)
        }

        // Measurements
        if currentStep >= 4, config.measurements.count > 1 {
            let measText = Text("\(config.measurements[1].label) = \(config.measurements[1].value)")
                .font(.custom("Mulish-SemiBold", size: 12))
                .foregroundColor(RenaissanceColors.sepiaInk)
            context.draw(context.resolve(measText), at: CGPoint(x: cx, y: size.height * 0.88), anchor: .center)
        }

        if currentStep >= 5 {
            let checkText = Text(Image(systemName: "checkmark.circle.fill"))
                .font(.system(size: 20))
                .foregroundColor(RenaissanceColors.sageGreen)
            context.draw(context.resolve(checkText), at: CGPoint(x: size.width - 20, y: 20), anchor: .center)
        }
    }

    private func clamp(_ value: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
        Swift.min(Swift.max(value, min), max)
    }
}
