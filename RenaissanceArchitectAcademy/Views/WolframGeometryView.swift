import SwiftUI

/// Interactive geometry visualization powered by Wolfram Alpha computations.
/// Player adjusts a slider (e.g. dome diameter) → Wolfram recalculates → diagram animates.
/// Falls back to local computation when offline.
struct WolframGeometryView: View {

    let geometry: BuildingGeometry
    var compact: Bool = false      // true = smaller version for knowledge cards

    @State private var results: [WolframGeometryResult] = []
    @State private var interactiveResult: WolframGeometryResult?
    @State private var sliderValue: Double = -1  // -1 = not yet initialized
    @State private var isLoading = true
    @State private var isComputingInteractive = false
    @State private var animateReveal = false
    @State private var diagramPulse: CGFloat = 0

    private let helper = WolframGeometryHelper()

    var body: some View {
        VStack(spacing: compact ? 12 : 16) {
            // Header
            if !compact {
                headerView
            }

            // Geometry diagram (animated)
            diagramCanvas
                .frame(height: compact ? 160 : 220)
                .background(RenaissanceColors.parchment)
                .borderCard(radius: 8)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            // Computed values from Wolfram
            if !results.isEmpty {
                valuesGrid
            }

            // Interactive slider
            if let param = geometry.interactiveParameter {
                interactiveSlider(param: param)
            }
        }
        .onAppear {
            // Set slider to default BEFORE any rendering
            if sliderValue < 0 {
                sliderValue = geometry.interactiveParameter?.defaultValue ?? 0
            }
        }
        .task {
            if sliderValue < 0 {
                sliderValue = geometry.interactiveParameter?.defaultValue ?? 0
            }
            await loadResults()
        }
    }

    // MARK: - Header

    private var headerView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(geometry.title)
                .font(.custom("Cinzel-Bold", size: 20))
                .foregroundStyle(RenaissanceColors.sepiaInk)

            Text(geometry.description)
                .font(.custom("EBGaramond-Regular", size: 14))
                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))
                .lineSpacing(2)
        }
    }

    // MARK: - Diagram Canvas

    private var diagramCanvas: some View {
        ZStack {
            // Blueprint grid background
            BlueprintGrid(height: compact ? 160 : 220)

            // Building-specific diagram
            Canvas { context, size in
                switch geometry.buildingName {
                case "Pantheon":
                    drawPantheonDome(context: context, size: size)
                case "Colosseum":
                    drawColosseumEllipse(context: context, size: size)
                case "Duomo":
                    drawDuomoDome(context: context, size: size)
                case "Aqueduct":
                    drawAqueductGradient(context: context, size: size)
                default:
                    drawGenericGeometry(context: context, size: size)
                }
            }
            .frame(height: compact ? 160 : 220)
            .opacity(animateReveal ? 1 : 0)
            .animation(.easeIn(duration: 0.8), value: animateReveal)

            // Loading spinner
            if isLoading {
                ProgressView()
                    .tint(RenaissanceColors.ochre)
            }
        }
    }

    // MARK: - Values Grid

    private var valuesGrid: some View {
        let columns = compact
            ? [GridItem(.flexible()), GridItem(.flexible())]
            : [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

        return LazyVGrid(columns: columns, spacing: 8) {
            ForEach(results) { result in
                valueCard(result)
            }
        }
    }

    private func valueCard(_ result: WolframGeometryResult) -> some View {
        VStack(spacing: 2) {
            Text(result.label)
                .font(.custom("EBGaramond-Regular", size: 11))
                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.6))

            HStack(spacing: 2) {
                Text(result.value)
                    .font(.custom("Cinzel-Bold", size: compact ? 14 : 16))
                    .foregroundStyle(RenaissanceColors.sepiaInk)

                Text(result.unit)
                    .font(.custom("EBGaramond-Regular", size: 10))
                    .foregroundStyle(RenaissanceColors.warmBrown)
            }

            // Wolfram badge
            if result.isFromWolfram {
                HStack(spacing: 2) {
                    Image(systemName: "function")
                        .font(.system(size: 7))
                    Text("Wolfram")
                        .font(.custom("EBGaramond-Regular", size: 8))
                }
                .foregroundStyle(RenaissanceColors.renaissanceBlue.opacity(0.5))
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(RenaissanceColors.ochre.opacity(0.06))
        )
        .borderCard(radius: 8)
    }

    // MARK: - Interactive Slider

    private func interactiveSlider(param: BuildingGeometry.InteractiveParam) -> some View {
        VStack(spacing: 8) {
            HStack {
                Text(param.label)
                    .font(.custom("EBGaramond-Regular", size: 13))
                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))

                Spacer()

                HStack(spacing: 2) {
                    Text(String(format: param.step < 1 ? "%.1f" : "%.0f", sliderValue))
                        .font(.custom("Cinzel-Bold", size: 16))
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                        .contentTransition(.numericText())

                    Text(param.unit)
                        .font(.custom("EBGaramond-Regular", size: 12))
                        .foregroundStyle(RenaissanceColors.warmBrown)
                }

                if isComputingInteractive {
                    ProgressView()
                        .scaleEffect(0.5)
                        .frame(width: 16, height: 16)
                }
            }

            Slider(
                value: $sliderValue,
                in: param.range,
                step: param.step
            )
            .tint(RenaissanceColors.ochre)
            .onChange(of: sliderValue) { _, newValue in
                computeInteractiveDebounced(param: param, value: newValue)
            }

            // Interactive result
            if let result = interactiveResult {
                HStack(spacing: 4) {
                    Image(systemName: "equal.circle.fill")
                        .font(.caption)
                        .foregroundStyle(RenaissanceColors.ochre)

                    Text("\(result.label): ")
                        .font(.custom("EBGaramond-Regular", size: 13))
                        .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))

                    Text(result.value)
                        .font(.custom("Cinzel-Bold", size: 15))
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                        .contentTransition(.numericText())

                    Text(result.unit)
                        .font(.custom("EBGaramond-Regular", size: 11))
                        .foregroundStyle(RenaissanceColors.warmBrown)

                    if result.isFromWolfram {
                        Image(systemName: "function")
                            .font(.system(size: 8))
                            .foregroundStyle(RenaissanceColors.renaissanceBlue.opacity(0.5))
                    }
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(RenaissanceColors.parchment.opacity(0.8))
        )
        .borderCard(radius: 10)
    }

    // MARK: - Data Loading

    private func loadResults() async {
        isLoading = true
        results = await helper.computeAll(for: geometry)

        if let param = geometry.interactiveParameter {
            interactiveResult = await helper.computeInteractive(param: param, value: param.defaultValue)
        }

        isLoading = false
        withAnimation { animateReveal = true }
    }

    @State private var computeTask: Task<Void, Never>?

    private func computeInteractiveDebounced(param: BuildingGeometry.InteractiveParam, value: Double) {
        computeTask?.cancel()
        computeTask = Task {
            // Wait 0.3s before hitting Wolfram (debounce while sliding)
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }

            isComputingInteractive = true
            let result = await helper.computeInteractive(param: param, value: value)
            guard !Task.isCancelled else { return }

            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.3)) {
                    interactiveResult = result
                    isComputingInteractive = false
                }
            }
        }
    }

    // MARK: - Pantheon Dome Drawing

    private func drawPantheonDome(context: GraphicsContext, size: CGSize) {
        let midX = size.width / 2
        let baseY = size.height * 0.85
        let domeWidth = size.width * 0.7
        let domeHeight = domeWidth * 0.5 // hemisphere proportions

        // Scale factor based on slider (1.0 = default 43.3m)
        let defaultDiameter = geometry.interactiveParameter?.defaultValue ?? 43.3
        let scale = sliderValue > 0 ? sliderValue / defaultDiameter : 1.0
        let scaledWidth = domeWidth * min(max(scale, 0.3), 1.8)
        let scaledHeight = scaledWidth * 0.5

        let inkColor = RenaissanceColors.sepiaInk

        // Floor line
        var floor = Path()
        floor.move(to: CGPoint(x: midX - scaledWidth * 0.6, y: baseY))
        floor.addLine(to: CGPoint(x: midX + scaledWidth * 0.6, y: baseY))
        context.stroke(floor, with: .color(inkColor.opacity(0.5)), lineWidth: 2)

        // Dome arc (hemisphere)
        var dome = Path()
        dome.move(to: CGPoint(x: midX - scaledWidth / 2, y: baseY))
        dome.addQuadCurve(
            to: CGPoint(x: midX + scaledWidth / 2, y: baseY),
            control: CGPoint(x: midX, y: baseY - scaledHeight)
        )
        context.stroke(dome, with: .color(inkColor), lineWidth: 2.5)

        // Dome fill (subtle)
        context.fill(dome, with: .color(RenaissanceColors.ochre.opacity(0.08)))

        // Inscribed circle (the "perfect sphere")
        let circleR = min(scaledWidth / 2, scaledHeight) * 0.95
        var circle = Path()
        circle.addEllipse(in: CGRect(
            x: midX - circleR, y: baseY - circleR * 2,
            width: circleR * 2, height: circleR * 2
        ))
        context.stroke(circle, with: .color(RenaissanceColors.renaissanceBlue.opacity(0.4)),
                       style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))

        // Oculus (top opening)
        let oculusWidth = scaledWidth * 0.12
        var oculus = Path()
        oculus.addEllipse(in: CGRect(
            x: midX - oculusWidth / 2, y: baseY - scaledHeight - 4,
            width: oculusWidth, height: oculusWidth * 0.3
        ))
        context.fill(oculus, with: .color(RenaissanceColors.renaissanceBlue.opacity(0.3)))
        context.stroke(oculus, with: .color(inkColor.opacity(0.6)), lineWidth: 1)

        // Dimension lines
        drawDimensionLine(context: context,
                         from: CGPoint(x: midX - scaledWidth / 2 - 10, y: baseY),
                         to: CGPoint(x: midX - scaledWidth / 2 - 10, y: baseY - scaledHeight),
                         label: String(format: "%.1f m", sliderValue > 0 ? sliderValue / 2 : 21.65),
                         color: inkColor)

        drawDimensionLine(context: context,
                         from: CGPoint(x: midX - scaledWidth / 2, y: baseY + 15),
                         to: CGPoint(x: midX + scaledWidth / 2, y: baseY + 15),
                         label: String(format: "%.1f m", sliderValue > 0 ? sliderValue : 43.3),
                         color: inkColor)
    }

    // MARK: - Colosseum Ellipse Drawing

    private func drawColosseumEllipse(context: GraphicsContext, size: CGSize) {
        let midX = size.width / 2
        let midY = size.height * 0.55
        let defaultMajor = geometry.interactiveParameter?.defaultValue ?? 188.0
        let scale = sliderValue > 0 ? sliderValue / defaultMajor : 1.0

        let maxW = size.width * 0.7
        let baseA = maxW / 2  // semi-major
        let baseB = baseA * (78.0 / 94.0) // semi-minor preserving real ratio

        let a = baseA * min(max(scale, 0.3), 1.5)
        let b = baseB

        let inkColor = RenaissanceColors.sepiaInk

        // Outer ellipse
        var outer = Path()
        outer.addEllipse(in: CGRect(x: midX - a, y: midY - b, width: a * 2, height: b * 2))
        context.fill(outer, with: .color(RenaissanceColors.terracotta.opacity(0.08)))
        context.stroke(outer, with: .color(inkColor), lineWidth: 2.5)

        // Inner arena ellipse (scaled down)
        let innerScale: CGFloat = 0.45
        var inner = Path()
        inner.addEllipse(in: CGRect(
            x: midX - a * innerScale, y: midY - b * innerScale,
            width: a * innerScale * 2, height: b * innerScale * 2
        ))
        context.fill(inner, with: .color(RenaissanceColors.ochre.opacity(0.1)))
        context.stroke(inner, with: .color(inkColor.opacity(0.5)),
                      style: StrokeStyle(lineWidth: 1.5, dash: [4, 3]))

        // Axes
        var majorAxis = Path()
        majorAxis.move(to: CGPoint(x: midX - a, y: midY))
        majorAxis.addLine(to: CGPoint(x: midX + a, y: midY))
        context.stroke(majorAxis, with: .color(RenaissanceColors.renaissanceBlue.opacity(0.3)),
                      style: StrokeStyle(lineWidth: 1, dash: [6, 4]))

        var minorAxis = Path()
        minorAxis.move(to: CGPoint(x: midX, y: midY - b))
        minorAxis.addLine(to: CGPoint(x: midX, y: midY + b))
        context.stroke(minorAxis, with: .color(RenaissanceColors.renaissanceBlue.opacity(0.3)),
                      style: StrokeStyle(lineWidth: 1, dash: [6, 4]))

        // Dimension label
        drawDimensionLine(context: context,
                         from: CGPoint(x: midX - a, y: midY + b + 15),
                         to: CGPoint(x: midX + a, y: midY + b + 15),
                         label: String(format: "%.0f m", sliderValue > 0 ? sliderValue : 188),
                         color: inkColor)
    }

    // MARK: - Duomo Drawing

    private func drawDuomoDome(context: GraphicsContext, size: CGSize) {
        let midX = size.width / 2
        let baseY = size.height * 0.85
        let defaultD = geometry.interactiveParameter?.defaultValue ?? 44.0
        let scale = sliderValue > 0 ? sliderValue / defaultD : 1.0

        let baseWidth = size.width * 0.55
        let scaledW = baseWidth * min(max(scale, 0.3), 1.8)
        let domeH = scaledW * 0.7 // taller than hemisphere (pointed dome)

        let inkColor = RenaissanceColors.sepiaInk

        // Drum (base)
        let drumH = size.height * 0.12
        var drum = Path()
        drum.addRect(CGRect(x: midX - scaledW / 2, y: baseY - drumH, width: scaledW, height: drumH))
        context.fill(drum, with: .color(RenaissanceColors.terracotta.opacity(0.1)))
        context.stroke(drum, with: .color(inkColor.opacity(0.5)), lineWidth: 1.5)

        // Outer dome shell (pointed)
        var outerDome = Path()
        outerDome.move(to: CGPoint(x: midX - scaledW / 2, y: baseY - drumH))
        outerDome.addQuadCurve(
            to: CGPoint(x: midX, y: baseY - drumH - domeH),
            control: CGPoint(x: midX - scaledW * 0.35, y: baseY - drumH - domeH * 0.85)
        )
        outerDome.addQuadCurve(
            to: CGPoint(x: midX + scaledW / 2, y: baseY - drumH),
            control: CGPoint(x: midX + scaledW * 0.35, y: baseY - drumH - domeH * 0.85)
        )
        context.fill(outerDome, with: .color(RenaissanceColors.terracotta.opacity(0.08)))
        context.stroke(outerDome, with: .color(inkColor), lineWidth: 2.5)

        // Inner dome shell (slightly smaller)
        let innerOff: CGFloat = scaledW * 0.04
        var innerDome = Path()
        innerDome.move(to: CGPoint(x: midX - scaledW / 2 + innerOff, y: baseY - drumH))
        innerDome.addQuadCurve(
            to: CGPoint(x: midX, y: baseY - drumH - domeH + innerOff * 2),
            control: CGPoint(x: midX - scaledW * 0.3, y: baseY - drumH - domeH * 0.8)
        )
        innerDome.addQuadCurve(
            to: CGPoint(x: midX + scaledW / 2 - innerOff, y: baseY - drumH),
            control: CGPoint(x: midX + scaledW * 0.3, y: baseY - drumH - domeH * 0.8)
        )
        context.stroke(innerDome, with: .color(inkColor.opacity(0.4)),
                      style: StrokeStyle(lineWidth: 1.5, dash: [5, 3]))

        // Lantern on top
        let lanternW: CGFloat = scaledW * 0.08
        let lanternH: CGFloat = domeH * 0.12
        var lantern = Path()
        lantern.addRect(CGRect(x: midX - lanternW / 2, y: baseY - drumH - domeH - lanternH,
                               width: lanternW, height: lanternH))
        context.stroke(lantern, with: .color(inkColor.opacity(0.6)), lineWidth: 1.5)

        // Dimension
        drawDimensionLine(context: context,
                         from: CGPoint(x: midX - scaledW / 2, y: baseY + 10),
                         to: CGPoint(x: midX + scaledW / 2, y: baseY + 10),
                         label: String(format: "%.1f m", sliderValue > 0 ? sliderValue : 44),
                         color: inkColor)
    }

    // MARK: - Aqueduct Drawing

    private func drawAqueductGradient(context: GraphicsContext, size: CGSize) {
        let defaultLen = geometry.interactiveParameter?.defaultValue ?? 200.0
        let scale = sliderValue > 0 ? sliderValue / defaultLen : 1.0

        let startX = size.width * 0.1
        let endX = size.width * 0.9
        let topY = size.height * 0.3
        let gradient = 0.005 // 0.5% slope
        let drop = size.height * 0.3 * min(scale, 3.0)

        let inkColor = RenaissanceColors.sepiaInk

        // Ground line
        var ground = Path()
        ground.move(to: CGPoint(x: startX, y: size.height * 0.85))
        ground.addLine(to: CGPoint(x: endX, y: size.height * 0.85))
        context.stroke(ground, with: .color(inkColor.opacity(0.3)), lineWidth: 1)

        // Aqueduct channel (tilted)
        let channelH: CGFloat = 12
        var channel = Path()
        channel.move(to: CGPoint(x: startX, y: topY))
        channel.addLine(to: CGPoint(x: endX, y: topY + drop))
        channel.addLine(to: CGPoint(x: endX, y: topY + drop + channelH))
        channel.addLine(to: CGPoint(x: startX, y: topY + channelH))
        channel.closeSubpath()
        context.fill(channel, with: .color(RenaissanceColors.warmBrown.opacity(0.15)))
        context.stroke(channel, with: .color(inkColor), lineWidth: 2)

        // Water flow line
        var water = Path()
        water.move(to: CGPoint(x: startX + 5, y: topY + 4))
        water.addLine(to: CGPoint(x: endX - 5, y: topY + drop + 4))
        context.stroke(water, with: .color(RenaissanceColors.renaissanceBlue.opacity(0.6)), lineWidth: 3)

        // Flow arrow
        let arrowX = endX - 20
        let arrowY = topY + drop + 2
        var arrow = Path()
        arrow.move(to: CGPoint(x: arrowX, y: arrowY - 5))
        arrow.addLine(to: CGPoint(x: arrowX + 10, y: arrowY))
        arrow.addLine(to: CGPoint(x: arrowX, y: arrowY + 5))
        context.fill(arrow, with: .color(RenaissanceColors.renaissanceBlue.opacity(0.6)))

        // Arch supports
        let archCount = 5
        for i in 0..<archCount {
            let t = CGFloat(i + 1) / CGFloat(archCount + 1)
            let ax = startX + (endX - startX) * t
            let channelY = topY + drop * t + channelH

            var pillar = Path()
            pillar.move(to: CGPoint(x: ax, y: channelY))
            pillar.addLine(to: CGPoint(x: ax, y: size.height * 0.85))
            context.stroke(pillar, with: .color(inkColor.opacity(0.3)), lineWidth: 1.5)
        }

        // Labels
        let lengthStr = String(format: "%.0f m", sliderValue > 0 ? sliderValue : 200)
        let dropStr = String(format: "%.1f m", (sliderValue > 0 ? sliderValue : 200) * gradient)

        drawDimensionLine(context: context,
                         from: CGPoint(x: startX, y: size.height * 0.88),
                         to: CGPoint(x: endX, y: size.height * 0.88),
                         label: lengthStr, color: inkColor)

        drawDimensionLine(context: context,
                         from: CGPoint(x: endX + 12, y: topY),
                         to: CGPoint(x: endX + 12, y: topY + drop),
                         label: dropStr, color: inkColor)
    }

    // MARK: - Generic Fallback

    private func drawGenericGeometry(context: GraphicsContext, size: CGSize) {
        let midX = size.width / 2
        let midY = size.height / 2
        let r = min(size.width, size.height) * 0.3

        var circle = Path()
        circle.addEllipse(in: CGRect(x: midX - r, y: midY - r, width: r * 2, height: r * 2))
        context.stroke(circle, with: .color(RenaissanceColors.sepiaInk), lineWidth: 2)

        // Cross lines
        var h = Path()
        h.move(to: CGPoint(x: midX - r, y: midY))
        h.addLine(to: CGPoint(x: midX + r, y: midY))
        context.stroke(h, with: .color(RenaissanceColors.sepiaInk.opacity(0.3)),
                      style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
    }

    // MARK: - Drawing Helpers

    private func drawDimensionLine(context: GraphicsContext, from: CGPoint, to: CGPoint,
                                   label: String, color: Color) {
        // Line
        var line = Path()
        line.move(to: from)
        line.addLine(to: to)
        context.stroke(line, with: .color(color.opacity(0.4)),
                      style: StrokeStyle(lineWidth: 1, dash: [3, 2]))

        // End ticks
        let isHorizontal = abs(to.y - from.y) < abs(to.x - from.x)
        let tickLen: CGFloat = 4

        var tick1 = Path()
        var tick2 = Path()
        if isHorizontal {
            tick1.move(to: CGPoint(x: from.x, y: from.y - tickLen))
            tick1.addLine(to: CGPoint(x: from.x, y: from.y + tickLen))
            tick2.move(to: CGPoint(x: to.x, y: to.y - tickLen))
            tick2.addLine(to: CGPoint(x: to.x, y: to.y + tickLen))
        } else {
            tick1.move(to: CGPoint(x: from.x - tickLen, y: from.y))
            tick1.addLine(to: CGPoint(x: from.x + tickLen, y: from.y))
            tick2.move(to: CGPoint(x: to.x - tickLen, y: to.y))
            tick2.addLine(to: CGPoint(x: to.x + tickLen, y: to.y))
        }
        context.stroke(tick1, with: .color(color.opacity(0.5)), lineWidth: 1)
        context.stroke(tick2, with: .color(color.opacity(0.5)), lineWidth: 1)

        // Label
        let midPoint = CGPoint(x: (from.x + to.x) / 2, y: (from.y + to.y) / 2)
        let text = Text(label)
            .font(.custom("EBGaramond-Regular", size: 11))
            .foregroundColor(color.opacity(0.7))
        let resolved = context.resolve(text)

        let offset: CGFloat = isHorizontal ? -10 : 8
        context.draw(resolved, at: CGPoint(
            x: midPoint.x + (isHorizontal ? 0 : offset),
            y: midPoint.y + (isHorizontal ? offset : 0)
        ))
    }
}
