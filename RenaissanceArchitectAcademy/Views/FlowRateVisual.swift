import SwiftUI

/// Animated flow rate diagram — 5 steps
/// Step 1: Pipe + empty basin appear
/// Step 2: Formula "speed × time = total" typewriter-reveals
/// Step 3: Clock appears, water fills basin, counter ticks up
/// Step 4: Basin full, counter stops at 1,800,000, formula highlights
/// Step 5: Summary + bathtub icon grid
struct FlowRateVisual: View {
    @Binding var currentStep: Int

    // Fill animation
    @State private var fillLevel: CGFloat = 0
    @State private var counterValue: Int = 0
    @State private var counterTimer: Timer?

    var body: some View {
        VStack(spacing: 0) {
            Canvas { context, size in
                drawDiagram(context: context, size: size)
            }
            .frame(height: 240)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(RenaissanceColors.parchment)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(RenaissanceColors.ochre.opacity(0.25), lineWidth: 1)
            )
            .clipped()

            // Step-specific text below diagram
            stepLabel
                .padding(.top, 12)
        }
        .onChange(of: currentStep) { _, newValue in
            if newValue >= 3 {
                startFillAnimation()
            }
        }
        .onAppear {
            if currentStep >= 3 {
                fillLevel = currentStep >= 4 ? 1.0 : 0
                counterValue = currentStep >= 4 ? 1_800_000 : 0
                if currentStep == 3 {
                    startFillAnimation()
                }
            }
        }
        .onDisappear {
            counterTimer?.invalidate()
            counterTimer = nil
        }
    }

    // MARK: - Canvas Drawing

    private func drawDiagram(context: GraphicsContext, size: CGSize) {
        let w = size.width
        let h = size.height

        // Blueprint grid
        drawGrid(context: context, size: size)

        guard currentStep >= 1 else { return }

        // Pipe (left side)
        let pipeStartX: CGFloat = 40
        let pipeEndX = w * 0.4
        let pipeY = h * 0.3
        let pipeHeight: CGFloat = 16

        var pipePath = Path()
        pipePath.addRoundedRect(in: CGRect(
            x: pipeStartX, y: pipeY - pipeHeight / 2,
            width: pipeEndX - pipeStartX, height: pipeHeight
        ), cornerSize: CGSize(width: 4, height: 4))
        context.fill(pipePath, with: .color(RenaissanceColors.warmBrown.opacity(0.15)))
        context.stroke(pipePath, with: .color(RenaissanceColors.warmBrown), lineWidth: 1.5)

        // Pipe opening arrow
        var arrowPath = Path()
        arrowPath.move(to: CGPoint(x: pipeEndX - 5, y: pipeY - 10))
        arrowPath.addLine(to: CGPoint(x: pipeEndX + 8, y: pipeY))
        arrowPath.addLine(to: CGPoint(x: pipeEndX - 5, y: pipeY + 10))
        context.stroke(arrowPath, with: .color(RenaissanceColors.renaissanceBlue), style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))

        // Basin (right side)
        let basinX = w * 0.45
        let basinW = w * 0.45
        let basinY = h * 0.35
        let basinH = h * 0.5

        // Basin outline
        var basinPath = Path()
        basinPath.move(to: CGPoint(x: basinX, y: basinY))
        basinPath.addLine(to: CGPoint(x: basinX, y: basinY + basinH))
        basinPath.addLine(to: CGPoint(x: basinX + basinW, y: basinY + basinH))
        basinPath.addLine(to: CGPoint(x: basinX + basinW, y: basinY))
        context.stroke(basinPath, with: .color(RenaissanceColors.warmBrown), style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))

        // Water fill (step 3+)
        if currentStep >= 3 {
            let waterH = basinH * fillLevel
            let waterY = basinY + basinH - waterH
            var waterPath = Path()
            waterPath.addRect(CGRect(
                x: basinX + 2, y: waterY,
                width: basinW - 4, height: waterH - 2
            ))
            context.fill(waterPath, with: .color(RenaissanceColors.renaissanceBlue.opacity(0.2)))

            // Water stream from pipe to basin
            if fillLevel < 1.0 {
                var streamPath = Path()
                streamPath.move(to: CGPoint(x: pipeEndX + 8, y: pipeY))
                streamPath.addQuadCurve(
                    to: CGPoint(x: basinX + basinW / 4, y: waterY),
                    control: CGPoint(x: basinX, y: pipeY + 20)
                )
                context.stroke(streamPath, with: .color(RenaissanceColors.renaissanceBlue.opacity(0.4)), style: StrokeStyle(lineWidth: 3, lineCap: .round))
            }
        }

        // Step 2+: Formula
        if currentStep >= 2 {
            let formulaY = h * 0.12
            let highlighted = currentStep >= 4

            let formulaText = Text("speed  \u{00D7}  time  =  total")
                .font(.custom("Mulish-SemiBold", size: 18))
                .foregroundColor(highlighted ? RenaissanceColors.goldSuccess : RenaissanceColors.warmBrown)
            context.draw(context.resolve(formulaText), at: CGPoint(x: w / 2, y: formulaY), anchor: .center)

            // Values below formula (step 3+)
            if currentStep >= 3 {
                let valuesText = Text("500 cups/s  \u{00D7}  3,600 s  =  ?")
                    .font(.custom("Mulish-Light", size: 15, relativeTo: .subheadline))
                    .foregroundColor(RenaissanceColors.sepiaInk.opacity(0.7))
                context.draw(context.resolve(valuesText), at: CGPoint(x: w / 2, y: formulaY + 22), anchor: .center)
            }

            if currentStep >= 4 {
                let resultText = Text("= 1,800,000 cups")
                    .font(.custom("Mulish-SemiBold", size: 16))
                    .foregroundColor(RenaissanceColors.sageGreen)
                context.draw(context.resolve(resultText), at: CGPoint(x: w / 2, y: formulaY + 42), anchor: .center)
            }
        }

        // Step 3+: Counter display
        if currentStep >= 3 {
            let counterStr = formatNumber(counterValue)
            let counterText = Text(counterStr)
                .font(.custom("Mulish-Bold", size: 20))
                .foregroundColor(currentStep >= 4 ? RenaissanceColors.sageGreen : RenaissanceColors.sepiaInk)
            let counterPos = CGPoint(x: basinX + basinW / 2, y: basinY + basinH / 2)
            context.draw(context.resolve(counterText), at: counterPos, anchor: .center)

            // "cups" label
            let cupsText = Text("cups")
                .font(.custom("Mulish-Light", size: 13))
                .foregroundColor(RenaissanceColors.sepiaInk)
            context.draw(context.resolve(cupsText), at: CGPoint(x: counterPos.x, y: counterPos.y + 22), anchor: .center)

            // Clock icon (left of basin)
            let clockText = Text(Image(systemName: "clock.fill"))
                .font(.custom("Mulish-Light", size: 22, relativeTo: .title3))
                .foregroundColor(RenaissanceColors.sepiaInk.opacity(0.6))
            context.draw(context.resolve(clockText), at: CGPoint(x: pipeStartX + 30, y: h * 0.65), anchor: .center)

            let timeLabel = Text("1 hour")
                .font(.custom("Mulish-Light", size: 12))
                .foregroundColor(RenaissanceColors.sepiaInk)
            context.draw(context.resolve(timeLabel), at: CGPoint(x: pipeStartX + 30, y: h * 0.73), anchor: .center)
        }

        // Step 5: Bathtub grid in corner
        if currentStep >= 5 {
            let gridX = pipeStartX
            let gridY = h * 0.55
            let iconSize: CGFloat = 14
            let cols = 4
            let rows = 2

            for row in 0..<rows {
                for col in 0..<cols {
                    let x = gridX + CGFloat(col) * (iconSize + 4)
                    let y = gridY + CGFloat(row) * (iconSize + 4)
                    let tubText = Text(Image(systemName: "bathtub.fill"))
                        .font(.custom("Mulish-Light", size: iconSize, relativeTo: .footnote))
                        .foregroundColor(RenaissanceColors.sepiaInk.opacity(0.4))
                    context.draw(context.resolve(tubText), at: CGPoint(x: x, y: y), anchor: .topLeading)
                }
            }

            let checkPos = CGPoint(x: w - 30, y: 30)
            let checkText = Text(Image(systemName: "checkmark.circle.fill"))
                .font(.custom("Mulish-Light", size: 28, relativeTo: .title3))
                .foregroundColor(RenaissanceColors.sageGreen)
            context.draw(context.resolve(checkText), at: checkPos, anchor: .center)
        }
    }

    // MARK: - Blueprint Grid

    private func drawGrid(context: GraphicsContext, size: CGSize) {
        let spacing: CGFloat = 20
        let color = RenaissanceColors.ochre.opacity(0.12)

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

    // MARK: - Fill Animation

    private func startFillAnimation() {
        guard fillLevel < 1.0 else { return }
        counterTimer?.invalidate()

        // Animate fill
        withAnimation(.easeInOut(duration: 2.5)) {
            fillLevel = 1.0
        }

        // Counter ticks
        let totalTicks = 20
        let interval = 2.5 / Double(totalTicks)
        var tick = 0
        counterTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            tick += 1
            counterValue = Int(Double(1_800_000) * Double(tick) / Double(totalTicks))
            if tick >= totalTicks {
                counterValue = 1_800_000
                timer.invalidate()
                counterTimer = nil
            }
        }
    }

    // MARK: - Helpers

    private func formatNumber(_ n: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: n)) ?? "\(n)"
    }

    // MARK: - Step Labels

    @ViewBuilder
    private var stepLabel: some View {
        switch currentStep {
        case 0:
            Text("Tap \"Next Step\" to begin")
                .font(.custom("Mulish-Light", size: 15))
                .foregroundStyle(RenaissanceColors.sepiaInk)
        case 1:
            Text("A pipe delivers water into a large stone basin.")
                .font(.custom("Mulish-Light", size: 16, relativeTo: .subheadline))
                .foregroundStyle(RenaissanceColors.sepiaInk)
        case 2:
            VStack(alignment: .leading, spacing: 4) {
                Text("The formula is simple:")
                    .font(.custom("Mulish-Light", size: 16, relativeTo: .subheadline))
                    .foregroundStyle(RenaissanceColors.sepiaInk)
                Text("speed \u{00D7} time = total water")
                    .font(.custom("Mulish-SemiBold", size: 15))
                    .foregroundStyle(RenaissanceColors.sepiaInk)
            }
        case 3:
            Text("500 cups per second, flowing for 1 hour (3,600 seconds). Watch the basin fill...")
                .font(.custom("Mulish-Light", size: 16, relativeTo: .subheadline))
                .foregroundStyle(RenaissanceColors.sepiaInk)
        case 4:
            VStack(alignment: .leading, spacing: 4) {
                Text("**1,800,000 cups** in just one hour!")
                    .font(.custom("Mulish-Light", size: 16, relativeTo: .subheadline))
                    .foregroundStyle(RenaissanceColors.sepiaInk)
                Text("500 \u{00D7} 3,600 = 1,800,000")
                    .font(.custom("Mulish-SemiBold", size: 14))
                    .foregroundStyle(RenaissanceColors.sageGreen)
            }
        case 5:
            HStack(spacing: 6) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(RenaissanceColors.sageGreen)
                Text("Rome's 11 aqueducts delivered about 1 million cubic meters of water per day -- roughly 400 Olympic swimming pools!")
                    .font(.custom("Mulish-Light", size: 16, relativeTo: .subheadline))
                    .foregroundStyle(RenaissanceColors.sepiaInk)
            }
        default:
            EmptyView()
        }
    }
}
