import SwiftUI

/// Interactive science visuals for Duomo knowledge cards (14 cards)
struct DuomoInteractiveVisuals {

    @ViewBuilder
    static func view(for visual: CardVisual, color: Color, height: CGFloat = 275) -> some View {
        let h = height
        Group {
            switch visual.title {
            case let t where t.contains("Brunelleschi") && t.contains("Genius"):
                DomeCompetitionVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Octagonal Drum"):
                OctagonStressVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Double Shell"):
                DoubleShellVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Herringbone Brick"):
                HerringboneVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Lantern"):
                LanternCompressionVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Carrara"):
                CarraraMarbleVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Material: Bricks") || t.contains("Quattro Milioni"):
                BrickProductionVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Iron Chains"):
                IronChainVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Stained Glass"):
                StainedGlassVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Herringbone Mortar"):
                MortarSetVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Brick Firing"):
                BrickFiringVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Sinopia"):
                SinopiaVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Quinto Acuto"):
                QuintoAcutoVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Lead Cames"):
                LeadCamesVisual(visual: visual, color: color, height: h)
            default:
                EmptyView()
            }
        }
    }

    static func hasInteractiveVisual(for visual: CardVisual) -> Bool {
        let t = visual.title
        return (t.contains("Brunelleschi") && t.contains("Genius")) ||
               t.contains("Octagonal Drum") || t.contains("Double Shell") ||
               t.contains("Herringbone Brick") || t.contains("Lantern") ||
               t.contains("Carrara") || t.contains("Material: Bricks") || t.contains("Quattro Milioni") ||
               t.contains("Iron Chains") || t.contains("Stained Glass") ||
               t.contains("Herringbone Mortar") || t.contains("Brick Firing") ||
               t.contains("Sinopia") || t.contains("Quinto Acuto") || t.contains("Lead Cames")
    }
}

// MARK: - Local Colors

private let brickRed = Color(red: 0.78, green: 0.38, blue: 0.25)
private let ironGray = Color(red: 0.40, green: 0.40, blue: 0.42)
private let greenPrato = Color(red: 0.35, green: 0.55, blue: 0.35)
private let pinkMaremma = Color(red: 0.82, green: 0.60, blue: 0.58)
private let cobaltBlue = Color(red: 0.22, green: 0.35, blue: 0.72)
private let goldAccent = Color(red: 0.85, green: 0.66, blue: 0.37)
private let sinopiaRed = Color(red: 0.72, green: 0.30, blue: 0.18)
private let leadGray = Color(red: 0.55, green: 0.55, blue: 0.52)

private typealias TeachingContainer = IVTeachingContainer
private typealias DimLabel = IVDimLabel
private typealias FormulaText = IVFormulaText
private typealias DimLine = IVDimLine

// MARK: - 1. Dome Competition — 42m Opening

private struct DomeCompetitionVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1

    private let labels = ["The octagonal drum — 42m wide, open to the sky",
                          "No wooden centering large enough existed",
                          "Brunelleschi: build it without centering"]

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            Canvas { ctx, size in
                let cx = size.width / 2, cy = size.height * 0.5
                let radius = min(size.width, size.height) * 0.35

                // Draw octagonal drum
                let octPath = octagonPath(center: CGPoint(x: cx, y: cy), radius: radius)
                ctx.stroke(octPath, with: .color(IVMaterialColors.sepiaInk.opacity(0.6)), lineWidth: 2)
                ctx.fill(octPath, with: .color(brickRed.opacity(step >= 1 ? 0.15 : 0)))

                // 42m dimension
                if step >= 1 {
                    let dimFrom = CGPoint(x: cx - radius, y: cy + radius + 15)
                    let dimTo = CGPoint(x: cx + radius, y: cy + radius + 15)
                    ctx.stroke(IVDimLine(from: dimFrom, to: dimTo).path(in: .zero), with: .color(IVMaterialColors.dimColor), lineWidth: 1)
                }

                // Step 2: crossed-out centering
                if step >= 2 {
                    // Curved centering lines
                    var arcPath = Path()
                    arcPath.addArc(center: CGPoint(x: cx, y: cy + radius * 0.4),
                                   radius: radius * 0.7, startAngle: .degrees(-150), endAngle: .degrees(-30), clockwise: false)
                    ctx.stroke(arcPath, with: .color(IVMaterialColors.sepiaInk.opacity(0.3)), style: StrokeStyle(lineWidth: 1, dash: [4, 3]))

                    // Red X through centering
                    let xSize = radius * 0.3
                    var xPath = Path()
                    xPath.move(to: CGPoint(x: cx - xSize, y: cy - xSize * 0.5))
                    xPath.addLine(to: CGPoint(x: cx + xSize, y: cy + xSize * 0.5))
                    xPath.move(to: CGPoint(x: cx + xSize, y: cy - xSize * 0.5))
                    xPath.addLine(to: CGPoint(x: cx - xSize, y: cy + xSize * 0.5))
                    ctx.stroke(xPath, with: .color(.red.opacity(0.6)), lineWidth: 2)
                }

                // Step 3: dome outline (self-supporting)
                if step >= 3 {
                    var domePath = Path()
                    domePath.move(to: CGPoint(x: cx - radius, y: cy))
                    domePath.addQuadCurve(to: CGPoint(x: cx + radius, y: cy),
                                          control: CGPoint(x: cx, y: cy - radius * 1.4))
                    ctx.stroke(domePath, with: .color(color), lineWidth: 2.5)
                }
            }
        }
    }

    private func octagonPath(center: CGPoint, radius: CGFloat) -> Path {
        Path { p in
            for i in 0..<8 {
                let angle = CGFloat(i) * .pi / 4 - .pi / 8
                let pt = CGPoint(x: center.x + cos(angle) * radius,
                                 y: center.y + sin(angle) * radius)
                if i == 0 { p.move(to: pt) } else { p.addLine(to: pt) }
            }
            p.closeSubpath()
        }
    }
}

// MARK: - 2. Octagon Stress Distribution

private struct OctagonStressVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1

    private let labels = ["Square: 4 corners take all the stress",
                          "Circle: even distribution but hard to build in stone",
                          "Octagon: 8 points share load + flat walls"]

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            HStack(spacing: 12) {
                // Square
                shapeView(sides: 4, label: "4", active: step == 1)
                // Circle
                circleView(active: step == 2)
                // Octagon
                shapeView(sides: 8, label: "8", active: step == 3)
            }
            .padding(.horizontal, 8)
        }
    }

    @ViewBuilder
    private func shapeView(sides: Int, label: String, active: Bool) -> some View {
        Canvas { ctx, size in
            let cx = size.width / 2, cy = size.height / 2
            let r = min(size.width, size.height) * 0.38

            var path = Path()
            for i in 0..<sides {
                let a = CGFloat(i) * (2 * .pi / CGFloat(sides)) - .pi / 2
                let pt = CGPoint(x: cx + cos(a) * r, y: cy + sin(a) * r)
                if i == 0 { path.move(to: pt) } else { path.addLine(to: pt) }
            }
            path.closeSubpath()

            ctx.fill(path, with: .color(active ? color.opacity(0.15) : IVMaterialColors.sepiaInk.opacity(0.05)))
            ctx.stroke(path, with: .color(active ? color : IVMaterialColors.sepiaInk.opacity(0.4)), lineWidth: active ? 2 : 1)

            // Stress arrows at corners
            if active {
                for i in 0..<sides {
                    let a = CGFloat(i) * (2 * .pi / CGFloat(sides)) - .pi / 2
                    let outer = CGPoint(x: cx + cos(a) * (r + 12), y: cy + sin(a) * (r + 12))
                    let inner = CGPoint(x: cx + cos(a) * (r + 3), y: cy + sin(a) * (r + 3))
                    var arrow = Path()
                    arrow.move(to: outer)
                    arrow.addLine(to: inner)
                    ctx.stroke(arrow, with: .color(IVMaterialColors.dimColor.opacity(0.7)), lineWidth: 1.5)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .overlay(alignment: .bottom) {
            Text(label)
                .font(.custom("Cinzel-Bold", size: 16))
                .foregroundStyle(active ? color : IVMaterialColors.sepiaInk.opacity(0.4))
        }
    }

    @ViewBuilder
    private func circleView(active: Bool) -> some View {
        Canvas { ctx, size in
            let cx = size.width / 2, cy = size.height / 2
            let r = min(size.width, size.height) * 0.38
            let circle = Path(ellipseIn: CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2))
            ctx.fill(circle, with: .color(active ? color.opacity(0.15) : IVMaterialColors.sepiaInk.opacity(0.05)))
            ctx.stroke(circle, with: .color(active ? color : IVMaterialColors.sepiaInk.opacity(0.4)), lineWidth: active ? 2 : 1)

            if active {
                // Evenly distributed arrows
                for i in 0..<12 {
                    let a = CGFloat(i) * (2 * .pi / 12)
                    let outer = CGPoint(x: cx + cos(a) * (r + 10), y: cy + sin(a) * (r + 10))
                    let inner = CGPoint(x: cx + cos(a) * (r + 2), y: cy + sin(a) * (r + 2))
                    var arrow = Path()
                    arrow.move(to: outer)
                    arrow.addLine(to: inner)
                    ctx.stroke(arrow, with: .color(IVMaterialColors.dimColor.opacity(0.5)), lineWidth: 1)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .overlay(alignment: .bottom) {
            Text("∞")
                .font(.custom("Cinzel-Bold", size: 16))
                .foregroundStyle(active ? color : IVMaterialColors.sepiaInk.opacity(0.4))
        }
    }
}

// MARK: - 3. Double Shell Cross-Section

private struct DoubleShellVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1

    private let labels = ["Inner shell: 2.1m thick — carries all structural load",
                          "Outer shell: 0.6m thick — sheds rain, looks magnificent",
                          "Gap between: 463-step staircase, 25% weight savings"]

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            Canvas { ctx, size in
                let cx = size.width / 2
                let baseY = size.height * 0.78
                let domeW = size.width * 0.8
                let domeH = size.height * 0.65

                // Base drum
                var drum = Path()
                drum.addRect(CGRect(x: cx - domeW / 2, y: baseY, width: domeW, height: 12))
                ctx.fill(drum, with: .color(brickRed.opacity(0.3)))
                ctx.stroke(drum, with: .color(IVMaterialColors.sepiaInk.opacity(0.4)), lineWidth: 1)

                // Inner shell (always visible)
                let innerThick: CGFloat = domeW * 0.06  // ~2.1m proportion
                var innerOuter = domeArc(cx: cx, baseY: baseY, width: domeW * 0.85, height: domeH * 0.9)
                var innerInner = domeArc(cx: cx, baseY: baseY, width: domeW * 0.85 - innerThick * 2, height: domeH * 0.9 - innerThick)

                ctx.stroke(innerOuter, with: .color(step >= 1 ? brickRed : IVMaterialColors.sepiaInk.opacity(0.3)), lineWidth: step == 1 ? 2.5 : 1.5)
                ctx.stroke(innerInner, with: .color(step >= 1 ? brickRed.opacity(0.6) : IVMaterialColors.sepiaInk.opacity(0.2)), lineWidth: 1)

                // Outer shell
                if step >= 2 {
                    let outerPath = domeArc(cx: cx, baseY: baseY, width: domeW, height: domeH)
                    let outerInner = domeArc(cx: cx, baseY: baseY, width: domeW - domeW * 0.035 * 2, height: domeH - domeW * 0.02)
                    ctx.stroke(outerPath, with: .color(IVMaterialColors.marbleWhite.opacity(0.8)), lineWidth: 2.5)
                    ctx.stroke(outerInner, with: .color(IVMaterialColors.sepiaInk.opacity(0.2)), lineWidth: 1)
                }

                // Gap + staircase hint
                if step >= 3 {
                    // Dashed lines in gap
                    let gapMid = domeArc(cx: cx, baseY: baseY, width: domeW * 0.92, height: domeH * 0.95)
                    ctx.stroke(gapMid, with: .color(IVMaterialColors.sepiaInk.opacity(0.2)), style: StrokeStyle(lineWidth: 0.5, dash: [3, 3]))

                    // Staircase dots
                    for i in 0..<8 {
                        let t = CGFloat(i) / 7
                        let angle = .pi * 0.15 + t * .pi * 0.7
                        let midR = domeW * 0.46
                        let x = cx + cos(angle) * midR * 0.5
                        let y = baseY - sin(angle) * domeH * 0.47
                        let dot = Path(ellipseIn: CGRect(x: x - 2, y: y - 2, width: 4, height: 4))
                        ctx.fill(dot, with: .color(IVMaterialColors.sepiaInk.opacity(0.3)))
                    }
                }
            }
        }
    }

    private func domeArc(cx: CGFloat, baseY: CGFloat, width: CGFloat, height: CGFloat) -> Path {
        Path { p in
            p.move(to: CGPoint(x: cx - width / 2, y: baseY))
            p.addQuadCurve(to: CGPoint(x: cx + width / 2, y: baseY),
                           control: CGPoint(x: cx, y: baseY - height))
        }
    }
}

// MARK: - 4. Herringbone Brick Pattern

private struct HerringboneVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    @State private var bricksLaid: Int = 0

    private let labels = ["Horizontal bricks laid in curved rows",
                          "Vertical bricks inserted at alternating angles",
                          "Interlocking wedges — self-supporting without centering"]

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            Canvas { ctx, size in
                let rows = 6
                let cols = 8
                let bw: CGFloat = size.width / CGFloat(cols + 1)
                let bh: CGFloat = 10
                let startY = size.height * 0.2

                for row in 0..<rows {
                    let y = startY + CGFloat(row) * (bh + 4)
                    let offset: CGFloat = row % 2 == 0 ? 0 : bw * 0.5

                    for col in 0..<cols {
                        let x = offset + CGFloat(col) * bw + bw * 0.3

                        // Horizontal brick
                        let brick = CGRect(x: x, y: y, width: bw * 0.9, height: bh)
                        ctx.fill(Path(brick), with: .color(brickRed.opacity(0.4)))
                        ctx.stroke(Path(brick), with: .color(IVMaterialColors.sepiaInk.opacity(0.3)), lineWidth: 0.5)

                        // Vertical herringbone bricks (step 2+)
                        if step >= 2 && col % 3 == 1 {
                            let vx = x + bw * 0.3
                            let vy = y - 2
                            let angle: CGFloat = (row + col) % 2 == 0 ? 0.4 : -0.4

                            ctx.drawLayer { layerCtx in
                                let transform = CGAffineTransform(translationX: vx, y: vy)
                                    .rotated(by: angle)
                                var vBrick = Path()
                                vBrick.addRect(CGRect(x: -3, y: -bh * 0.6, width: 6, height: bh * 1.2))
                                let transformed = vBrick.applying(transform)
                                layerCtx.fill(transformed, with: .color(step >= 3 ? color.opacity(0.5) : brickRed.opacity(0.7)))
                                layerCtx.stroke(transformed, with: .color(IVMaterialColors.sepiaInk.opacity(0.5)), lineWidth: 0.5)
                            }
                        }
                    }
                }

                // Step 3: interlocking arrows
                if step >= 3 {
                    let arrowY = startY + CGFloat(rows) * (bh + 4) + 15
                    for i in 0..<3 {
                        let ax = size.width * 0.25 + CGFloat(i) * size.width * 0.25
                        var arrow = Path()
                        arrow.move(to: CGPoint(x: ax - 8, y: arrowY + 5))
                        arrow.addLine(to: CGPoint(x: ax, y: arrowY - 5))
                        arrow.addLine(to: CGPoint(x: ax + 8, y: arrowY + 5))
                        ctx.stroke(arrow, with: .color(color), lineWidth: 1.5)
                    }
                }
            }
        }
    }
}

// MARK: - 5. Lantern Compression

private struct LanternCompressionVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1

    private let labels = ["The dome without the lantern — outward thrust (splay)",
                          "800-ton marble lantern sits atop the crown",
                          "Downward force locks the compression ring tight"]

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            Canvas { ctx, size in
                let cx = size.width / 2, baseY = size.height * 0.75
                let domeW = size.width * 0.7, domeH = size.height * 0.55

                // Dome
                var dome = Path()
                dome.move(to: CGPoint(x: cx - domeW / 2, y: baseY))
                dome.addQuadCurve(to: CGPoint(x: cx + domeW / 2, y: baseY),
                                  control: CGPoint(x: cx, y: baseY - domeH))
                ctx.stroke(dome, with: .color(brickRed.opacity(0.7)), lineWidth: 2)
                ctx.fill(dome, with: .color(brickRed.opacity(0.1)))

                // Step 1: splay arrows (outward)
                if step == 1 {
                    for side: CGFloat in [-1, 1] {
                        let startX = cx + side * domeW * 0.3
                        let endX = cx + side * (domeW * 0.3 + 25)
                        var arrow = Path()
                        arrow.move(to: CGPoint(x: startX, y: baseY * 0.7))
                        arrow.addLine(to: CGPoint(x: endX, y: baseY * 0.7))
                        ctx.stroke(arrow, with: .color(.red.opacity(0.6)), lineWidth: 2)
                        // Arrowhead
                        var head = Path()
                        head.move(to: CGPoint(x: endX, y: baseY * 0.7))
                        head.addLine(to: CGPoint(x: endX - side * 6, y: baseY * 0.7 - 4))
                        head.addLine(to: CGPoint(x: endX - side * 6, y: baseY * 0.7 + 4))
                        head.closeSubpath()
                        ctx.fill(head, with: .color(.red.opacity(0.6)))
                    }
                }

                // Step 2+: lantern
                if step >= 2 {
                    let lanternW: CGFloat = 30, lanternH: CGFloat = 35
                    let lanternY = baseY - domeH + 5
                    let lantern = CGRect(x: cx - lanternW / 2, y: lanternY - lanternH, width: lanternW, height: lanternH)
                    ctx.fill(Path(roundedRect: lantern, cornerRadius: 3), with: .color(IVMaterialColors.marbleWhite.opacity(0.8)))
                    ctx.stroke(Path(roundedRect: lantern, cornerRadius: 3), with: .color(IVMaterialColors.sepiaInk.opacity(0.5)), lineWidth: 1.5)

                    // Ball on top
                    let ball = Path(ellipseIn: CGRect(x: cx - 6, y: lanternY - lanternH - 10, width: 12, height: 12))
                    ctx.fill(ball, with: .color(goldAccent))
                }

                // Step 3: compression arrows (downward + inward)
                if step >= 3 {
                    let topY = baseY - domeH - 20
                    // Downward arrow
                    var down = Path()
                    down.move(to: CGPoint(x: cx, y: topY))
                    down.addLine(to: CGPoint(x: cx, y: topY + 20))
                    ctx.stroke(down, with: .color(color), lineWidth: 2.5)
                    var downHead = Path()
                    downHead.move(to: CGPoint(x: cx, y: topY + 20))
                    downHead.addLine(to: CGPoint(x: cx - 5, y: topY + 14))
                    downHead.addLine(to: CGPoint(x: cx + 5, y: topY + 14))
                    downHead.closeSubpath()
                    ctx.fill(downHead, with: .color(color))

                    // Inward arrows at sides
                    for side: CGFloat in [-1, 1] {
                        let startX = cx + side * (domeW * 0.3 + 20)
                        let endX = cx + side * domeW * 0.3
                        var arrow = Path()
                        arrow.move(to: CGPoint(x: startX, y: baseY * 0.7))
                        arrow.addLine(to: CGPoint(x: endX, y: baseY * 0.7))
                        ctx.stroke(arrow, with: .color(color), lineWidth: 2)
                    }
                }
            }
        }
    }
}

// MARK: - 6. Carrara Marble — Three Colors

private struct CarraraMarbleVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1

    private let labels = ["White marble from Carrara — 99% pure CaCO₃",
                          "Green marble from Prato + pink from Maremma",
                          "Three-color facade: 1,000m mountain quarries"]

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            HStack(spacing: 8) {
                // White
                marbleSwatch(label: "Carrara", sublabel: "99% CaCO₃", color: IVMaterialColors.marbleWhite,
                             borderColor: IVMaterialColors.sepiaInk.opacity(0.3), active: step >= 1)
                // Green
                marbleSwatch(label: "Prato", sublabel: "Serpentine", color: greenPrato.opacity(0.5),
                             borderColor: greenPrato, active: step >= 2)
                // Pink
                marbleSwatch(label: "Maremma", sublabel: "Iron traces", color: pinkMaremma.opacity(0.4),
                             borderColor: pinkMaremma, active: step >= 2)
            }
            .padding(.horizontal, 12)
        }
    }

    @ViewBuilder
    private func marbleSwatch(label: String, sublabel: String, color: Color, borderColor: Color, active: Bool) -> some View {
        VStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 6)
                .fill(active ? color : Color.gray.opacity(0.1))
                .frame(maxWidth: .infinity)
                .frame(height: 70)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .strokeBorder(active ? borderColor : Color.gray.opacity(0.2), lineWidth: 1.5)
                )
                .overlay {
                    if active {
                        // Marble veining
                        Canvas { ctx, size in
                            for i in 0..<3 {
                                var vein = Path()
                                let startX = CGFloat.random(in: 0...size.width)
                                vein.move(to: CGPoint(x: startX, y: 0))
                                vein.addQuadCurve(to: CGPoint(x: startX + CGFloat(i * 8 - 8), y: size.height),
                                                  control: CGPoint(x: startX + 15, y: size.height * 0.5))
                                ctx.stroke(vein, with: .color(borderColor.opacity(0.2)), lineWidth: 0.5)
                            }
                        }
                    }
                }

            Text(label)
                .font(.custom("Cinzel-Bold", size: 16))
                .foregroundStyle(active ? IVMaterialColors.sepiaInk : IVMaterialColors.sepiaInk.opacity(0.3))
            Text(sublabel)
                .font(.custom("EBGaramond-Regular", size: 15))
                .foregroundStyle(active ? IVMaterialColors.dimColor : IVMaterialColors.dimColor.opacity(0.3))
        }
    }
}

// MARK: - 7. Brick Production — 4 Million

private struct BrickProductionVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1

    private let labels = ["Impruneta clay: iron-rich Tuscan soil, 15 km south",
                          "Each brick stamped with maker's mark — quality control",
                          "4 million bricks — failed batches rejected entirely"]

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            Canvas { ctx, size in
                let bw: CGFloat = 28, bh: CGFloat = 12
                let cols = Int(size.width / (bw + 3))
                let rows = Int((size.height * 0.6) / (bh + 3))
                let startX = (size.width - CGFloat(cols) * (bw + 3)) / 2
                let startY = size.height * 0.1

                for row in 0..<rows {
                    for col in 0..<cols {
                        let offset: CGFloat = row % 2 == 0 ? 0 : bw * 0.5
                        let x = startX + offset + CGFloat(col) * (bw + 3)
                        let y = startY + CGFloat(row) * (bh + 3)
                        let brick = CGRect(x: x, y: y, width: bw, height: bh)

                        let opacity: CGFloat = step >= 1 ? 0.5 : 0.2
                        ctx.fill(Path(brick), with: .color(brickRed.opacity(opacity)))
                        ctx.stroke(Path(brick), with: .color(IVMaterialColors.sepiaInk.opacity(0.2)), lineWidth: 0.5)

                        // Maker's mark (step 2+)
                        if step >= 2 && (row + col) % 4 == 0 {
                            let markCenter = CGPoint(x: x + bw / 2, y: y + bh / 2)
                            let mark = Path(ellipseIn: CGRect(x: markCenter.x - 3, y: markCenter.y - 2, width: 6, height: 4))
                            ctx.stroke(mark, with: .color(IVMaterialColors.sepiaInk.opacity(0.4)), lineWidth: 0.5)
                        }
                    }
                }

                // Step 3: counter
                if step >= 3 {
                    let counterRect = CGRect(x: size.width * 0.25, y: size.height * 0.7, width: size.width * 0.5, height: 24)
                    ctx.fill(Path(roundedRect: counterRect, cornerRadius: 4), with: .color(color.opacity(0.1)))
                    ctx.stroke(Path(roundedRect: counterRect, cornerRadius: 4), with: .color(color.opacity(0.3)), lineWidth: 1)
                }
            }
            .overlay(alignment: .bottom) {
                if step >= 3 {
                    Text("4,000,000")
                        .font(.custom("Cinzel-Bold", size: 16))
                        .foregroundStyle(color)
                        .offset(y: -42)
                }
            }
        }
    }
}

// MARK: - 8. Iron Chain Hoop Stress

private struct IronChainVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1

    private let labels = ["Dome pushes outward — hoop stress at every level",
                          "Iron catena: hidden chains encircle the dome like belts",
                          "3 chain levels, 70 tons total — invisible engineering"]

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            Canvas { ctx, size in
                let cx = size.width / 2, baseY = size.height * 0.78
                let domeW = size.width * 0.75, domeH = size.height * 0.6

                // Dome cross-section
                var dome = Path()
                dome.move(to: CGPoint(x: cx - domeW / 2, y: baseY))
                dome.addQuadCurve(to: CGPoint(x: cx + domeW / 2, y: baseY),
                                  control: CGPoint(x: cx, y: baseY - domeH))
                ctx.stroke(dome, with: .color(brickRed.opacity(0.5)), lineWidth: 1.5)

                // Step 1: outward arrows (hoop stress)
                if step >= 1 {
                    let levels: [CGFloat] = [0.3, 0.5, 0.7]
                    for t in levels {
                        let y = baseY - domeH * (1 - t)
                        let halfW = domeW * 0.5 * t
                        for side: CGFloat in [-1, 1] {
                            let startX = cx + side * halfW * 0.7
                            let endX = cx + side * (halfW * 0.7 + 12)
                            var arrow = Path()
                            arrow.move(to: CGPoint(x: startX, y: y))
                            arrow.addLine(to: CGPoint(x: endX, y: y))
                            ctx.stroke(arrow, with: .color(step == 1 ? .red.opacity(0.5) : .red.opacity(0.2)), lineWidth: 1.5)
                        }
                    }
                }

                // Step 2+: chains
                if step >= 2 {
                    let chainLevels: [CGFloat] = [0.35, 0.55, 0.75]
                    for (i, t) in chainLevels.enumerated() {
                        let y = baseY - domeH * (1 - t)
                        let halfW = domeW * 0.5 * t

                        // Chain line
                        var chain = Path()
                        chain.move(to: CGPoint(x: cx - halfW * 0.75, y: y))
                        chain.addLine(to: CGPoint(x: cx + halfW * 0.75, y: y))
                        ctx.stroke(chain, with: .color(ironGray), style: StrokeStyle(lineWidth: step >= 3 ? 2.5 : 2, dash: [4, 2]))

                        // Inward arrows (step 3)
                        if step >= 3 {
                            for side: CGFloat in [-1, 1] {
                                let outerX = cx + side * (halfW * 0.75 + 8)
                                let innerX = cx + side * halfW * 0.75
                                var arrow = Path()
                                arrow.move(to: CGPoint(x: outerX, y: y))
                                arrow.addLine(to: CGPoint(x: innerX, y: y))
                                ctx.stroke(arrow, with: .color(color), lineWidth: 1.5)
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - 9. Stained Glass — Light Absorption

private struct StainedGlassVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1

    private let labels = ["White light contains all colors (RGB spectrum)",
                          "Cobalt oxide absorbs red + green light",
                          "Only blue light passes through — 2% cobalt = deep blue"]

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            Canvas { ctx, size in
                let glassX = size.width * 0.5
                let glassW: CGFloat = 12
                let topY = size.height * 0.1
                let botY = size.height * 0.75

                // Glass pane
                let glass = CGRect(x: glassX - glassW / 2, y: topY, width: glassW, height: botY - topY)
                ctx.fill(Path(glass), with: .color(cobaltBlue.opacity(step >= 2 ? 0.4 : 0.1)))
                ctx.stroke(Path(glass), with: .color(IVMaterialColors.sepiaInk.opacity(0.4)), lineWidth: 1)

                // Incoming white light (left side)
                let colors: [(Color, String)] = [(.red, "R"), (.green, "G"), (.blue, "B")]
                let spacing: CGFloat = 18

                for (i, (c, label)) in colors.enumerated() {
                    let y = topY + 20 + CGFloat(i) * spacing
                    let startX: CGFloat = 10
                    let endX = glassX - glassW / 2

                    // Incoming ray
                    var ray = Path()
                    ray.move(to: CGPoint(x: startX, y: y))
                    ray.addLine(to: CGPoint(x: endX, y: y))
                    ctx.stroke(ray, with: .color(c.opacity(step >= 1 ? 0.7 : 0.3)), lineWidth: 1.5)

                    // Step 2+: absorbed or transmitted
                    if step >= 2 {
                        if label == "B" {
                            // Blue passes through
                            var through = Path()
                            through.move(to: CGPoint(x: glassX + glassW / 2, y: y))
                            through.addLine(to: CGPoint(x: size.width - 10, y: y))
                            ctx.stroke(through, with: .color(.blue.opacity(0.7)), lineWidth: 2)
                        } else {
                            // Red and green absorbed — X mark
                            let mx = glassX
                            var xMark = Path()
                            xMark.move(to: CGPoint(x: mx - 4, y: y - 4))
                            xMark.addLine(to: CGPoint(x: mx + 4, y: y + 4))
                            xMark.move(to: CGPoint(x: mx + 4, y: y - 4))
                            xMark.addLine(to: CGPoint(x: mx - 4, y: y + 4))
                            ctx.stroke(xMark, with: .color(.red.opacity(0.5)), lineWidth: 1.5)
                        }
                    }
                }

                // Step 3: formula
                if step >= 3 {
                    let formulaY = botY + 10
                    let rect = CGRect(x: size.width * 0.1, y: formulaY, width: size.width * 0.8, height: 20)
                    ctx.fill(Path(roundedRect: rect, cornerRadius: 3), with: .color(cobaltBlue.opacity(0.08)))
                }
            }
            .overlay(alignment: .bottom) {
                if step >= 3 {
                    Text("2% CoO → deep blue")
                        .font(.custom("EBGaramond-Bold", size: 15))
                        .foregroundStyle(cobaltBlue)
                        .offset(y: -28)
                }
            }
        }
    }
}

// MARK: - 10. Mortar Setting Time

private struct MortarSetVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1

    private let labels = ["Standard lime mortar: 3 days to set on curved surface",
                          "Add gypsum → 15 minutes! But weakens with moisture",
                          "Solution: gypsum for vertical bricks, lime for horizontal"]

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            HStack(spacing: 16) {
                // Lime mortar
                VStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(red: 0.88, green: 0.85, blue: 0.78).opacity(step == 1 ? 0.8 : 0.3))
                        .frame(height: 60)
                        .overlay {
                            Text("☁ 3 days")
                                .font(.custom("EBGaramond-Bold", size: 15))
                                .foregroundStyle(step == 1 ? IVMaterialColors.sepiaInk : IVMaterialColors.sepiaInk.opacity(0.3))
                        }
                    Text("Lime")
                        .font(.custom("Cinzel-Bold", size: 16))
                        .foregroundStyle(step == 1 || step == 3 ? IVMaterialColors.sepiaInk : IVMaterialColors.sepiaInk.opacity(0.3))
                    if step >= 3 {
                        Text("→ horizontal")
                            .font(.custom("EBGaramond-Regular", size: 15))
                            .foregroundStyle(color)
                    }
                }

                // Gypsum mortar
                VStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(red: 0.95, green: 0.92, blue: 0.85).opacity(step >= 2 ? 0.8 : 0.3))
                        .frame(height: 60)
                        .overlay {
                            Text("⚡ 15 min")
                                .font(.custom("EBGaramond-Bold", size: 15))
                                .foregroundStyle(step >= 2 ? color : IVMaterialColors.sepiaInk.opacity(0.3))
                        }
                    Text("Gypsum")
                        .font(.custom("Cinzel-Bold", size: 16))
                        .foregroundStyle(step >= 2 ? IVMaterialColors.sepiaInk : IVMaterialColors.sepiaInk.opacity(0.3))
                    if step >= 3 {
                        Text("→ vertical")
                            .font(.custom("EBGaramond-Regular", size: 15))
                            .foregroundStyle(color)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - 11. Brick Firing — Iron Oxide Color

private struct BrickFiringVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1

    private let labels = ["Fe₂O₃ in Tuscan clay gives bricks their color",
                          "900°C + oxygen → warm red",
                          "1,000°C restricted oxygen → dark brown"]

    private var brickSize: CGFloat { max(60, height * 0.18) }
    private var brickHeight: CGFloat { brickSize * 0.7 }

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            VStack(spacing: height * 0.04) {
                Spacer()

                // Temperature label
                if step >= 1 {
                    Text("Fe₂O₃")
                        .font(.custom("EBGaramond-Bold", size: 20))
                        .foregroundStyle(brickRed.opacity(0.7))
                }

                HStack(spacing: height * 0.06) {
                    // Red brick
                    VStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(brickRed.opacity(step >= 2 ? 0.8 : 0.2))
                            .frame(width: brickSize, height: brickHeight)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .strokeBorder(IVMaterialColors.sepiaInk.opacity(0.3), lineWidth: 1)
                            )
                        Text("900°C + O₂")
                            .font(.custom("EBGaramond-Bold", size: 15))
                            .foregroundStyle(step >= 2 ? IVMaterialColors.dimColor : IVMaterialColors.dimColor.opacity(0.3))
                        Text("Red")
                            .font(.custom("Cinzel-Bold", size: 18))
                            .foregroundStyle(step >= 2 ? brickRed : brickRed.opacity(0.3))
                    }

                    // Dark brick
                    VStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color(red: 0.4, green: 0.28, blue: 0.2).opacity(step >= 3 ? 0.8 : 0.2))
                            .frame(width: brickSize, height: brickHeight)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .strokeBorder(IVMaterialColors.sepiaInk.opacity(0.3), lineWidth: 1)
                            )
                        Text("1000°C − O₂")
                            .font(.custom("EBGaramond-Bold", size: 15))
                            .foregroundStyle(step >= 3 ? IVMaterialColors.dimColor : IVMaterialColors.dimColor.opacity(0.3))
                        Text("Brown")
                            .font(.custom("Cinzel-Bold", size: 18))
                            .foregroundStyle(step >= 3 ? Color(red: 0.4, green: 0.28, blue: 0.2) : Color.gray.opacity(0.3))
                    }
                }

                Spacer()
            }
        }
    }
}

// MARK: - 12. Sinopia Drawing

private struct SinopiaVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1

    private let labels = ["Red ochre (Fe₂O₃) from Sinop, Turkey",
                          "Ground on marble slab with muller stone",
                          "Painted on wet plaster as architect's first draft"]

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            Canvas { ctx, size in
                let cx = size.width / 2

                // Plaster wall background
                let wall = CGRect(x: 20, y: 10, width: size.width - 40, height: size.height * 0.7)
                ctx.fill(Path(roundedRect: wall, cornerRadius: 4), with: .color(Color(red: 0.92, green: 0.89, blue: 0.83)))
                ctx.stroke(Path(roundedRect: wall, cornerRadius: 4), with: .color(IVMaterialColors.sepiaInk.opacity(0.2)), lineWidth: 0.5)

                // Sinopia sketch (simple dome outline drawn in red ochre)
                if step >= 3 {
                    var sketch = Path()
                    let sketchBase = wall.maxY - 15
                    let sketchW = wall.width * 0.6
                    sketch.move(to: CGPoint(x: cx - sketchW / 2, y: sketchBase))
                    sketch.addQuadCurve(to: CGPoint(x: cx + sketchW / 2, y: sketchBase),
                                        control: CGPoint(x: cx, y: wall.minY + 20))
                    // Columns
                    sketch.move(to: CGPoint(x: cx - sketchW / 2, y: sketchBase))
                    sketch.addLine(to: CGPoint(x: cx - sketchW / 2, y: sketchBase + 10))
                    sketch.move(to: CGPoint(x: cx + sketchW / 2, y: sketchBase))
                    sketch.addLine(to: CGPoint(x: cx + sketchW / 2, y: sketchBase + 10))

                    ctx.stroke(sketch, with: .color(sinopiaRed.opacity(0.7)), lineWidth: 2)
                }

                // Step 1: pigment chunk
                if step == 1 {
                    let chunk = Path(ellipseIn: CGRect(x: cx - 15, y: size.height * 0.35, width: 30, height: 20))
                    ctx.fill(chunk, with: .color(sinopiaRed.opacity(0.6)))
                    ctx.stroke(chunk, with: .color(sinopiaRed), lineWidth: 1)
                }

                // Step 2: muller on slab
                if step == 2 {
                    // Slab
                    let slab = CGRect(x: cx - 30, y: size.height * 0.3, width: 60, height: 8)
                    ctx.fill(Path(slab), with: .color(Color.gray.opacity(0.3)))
                    ctx.stroke(Path(slab), with: .color(IVMaterialColors.sepiaInk.opacity(0.3)), lineWidth: 0.5)
                    // Muller
                    let muller = Path(ellipseIn: CGRect(x: cx - 10, y: size.height * 0.25, width: 20, height: 14))
                    ctx.fill(muller, with: .color(Color.gray.opacity(0.5)))
                    // Ground pigment
                    let pigment = Path(ellipseIn: CGRect(x: cx - 20, y: size.height * 0.32, width: 40, height: 6))
                    ctx.fill(pigment, with: .color(sinopiaRed.opacity(0.4)))
                }
            }
        }
    }
}

// MARK: - 13. Quinto Acuto Geometry

private struct QuintoAcutoVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1

    private let labels = ["Hemisphere: center at base — maximum outward thrust",
                          "Quinto acuto: center at 4/5 height — steeper profile",
                          "Steeper curve = less thrust = no centering needed"]

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            Canvas { ctx, size in
                let cx = size.width / 2, baseY = size.height * 0.75
                let domeW = size.width * 0.7

                // Hemisphere (step 1)
                var hemiPath = Path()
                hemiPath.move(to: CGPoint(x: cx - domeW / 2, y: baseY))
                hemiPath.addArc(center: CGPoint(x: cx, y: baseY), radius: domeW / 2,
                                startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
                ctx.stroke(hemiPath, with: .color(step == 1 ? IVMaterialColors.sepiaInk.opacity(0.6) : IVMaterialColors.sepiaInk.opacity(0.2)),
                           style: StrokeStyle(lineWidth: step == 1 ? 2 : 1, dash: step > 1 ? [4, 3] : []))

                // Quinto acuto (step 2+) — pointed fifth arc
                if step >= 2 {
                    let quintoH = domeW * 0.8  // steeper than hemisphere
                    var quintoPath = Path()
                    quintoPath.move(to: CGPoint(x: cx - domeW / 2, y: baseY))
                    quintoPath.addQuadCurve(to: CGPoint(x: cx + domeW / 2, y: baseY),
                                            control: CGPoint(x: cx, y: baseY - quintoH))
                    ctx.stroke(quintoPath, with: .color(color), lineWidth: 2.5)

                    // Center point at 4/5
                    let centerY = baseY - quintoH * 0.8
                    let centerDot = Path(ellipseIn: CGRect(x: cx - 3, y: centerY - 3, width: 6, height: 6))
                    ctx.fill(centerDot, with: .color(IVMaterialColors.dimColor))

                    // 4/5 label line
                    var labelLine = Path()
                    labelLine.move(to: CGPoint(x: cx + 8, y: centerY))
                    labelLine.addLine(to: CGPoint(x: cx + 35, y: centerY))
                    ctx.stroke(labelLine, with: .color(IVMaterialColors.dimColor.opacity(0.5)), lineWidth: 0.5)
                }

                // Step 3: thrust arrows comparison
                if step >= 3 {
                    // Large outward arrows for hemisphere
                    for side: CGFloat in [-1, 1] {
                        let x = cx + side * domeW * 0.35
                        var bigArrow = Path()
                        bigArrow.move(to: CGPoint(x: x, y: baseY - 15))
                        bigArrow.addLine(to: CGPoint(x: x + side * 18, y: baseY - 15))
                        ctx.stroke(bigArrow, with: .color(.red.opacity(0.3)), lineWidth: 1)
                    }
                    // Small inward arrows for quinto
                    for side: CGFloat in [-1, 1] {
                        let x = cx + side * domeW * 0.35
                        var smallArrow = Path()
                        smallArrow.move(to: CGPoint(x: x + side * 12, y: baseY - 30))
                        smallArrow.addLine(to: CGPoint(x: x + side * 6, y: baseY - 30))
                        ctx.stroke(smallArrow, with: .color(color), lineWidth: 1.5)
                    }
                }

                // Base line
                var baseLine = Path()
                baseLine.move(to: CGPoint(x: cx - domeW / 2 - 10, y: baseY))
                baseLine.addLine(to: CGPoint(x: cx + domeW / 2 + 10, y: baseY))
                ctx.stroke(baseLine, with: .color(IVMaterialColors.sepiaInk.opacity(0.3)), lineWidth: 1)
            }
            .overlay {
                if step >= 2 {
                    Text("4/5")
                        .font(.custom("EBGaramond-Bold", size: 15))
                        .foregroundStyle(IVMaterialColors.dimColor)
                        .position(x: 999, y: 999) // positioned via canvas
                }
            }
        }
    }
}

// MARK: - 14. Lead Cames — Stained Glass Assembly

private struct LeadCamesVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1

    private let labels = ["H-shaped lead strips (cames) grip glass on both sides",
                          "Glass cut with hot iron, fitted into came channels",
                          "Sealed with linseed putty — 500+ cames per rose window"]

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            Canvas { ctx, size in
                let cx = size.width / 2, cy = size.height * 0.4

                // Step 1: H-profile cross section
                if step >= 1 {
                    let hx = cx - 40, hy = cy - 20
                    // Left flange
                    ctx.fill(Path(CGRect(x: hx, y: hy, width: 4, height: 40)), with: .color(leadGray))
                    // Right flange
                    ctx.fill(Path(CGRect(x: hx + 16, y: hy, width: 4, height: 40)), with: .color(leadGray))
                    // Web
                    ctx.fill(Path(CGRect(x: hx + 4, y: hy + 18, width: 12, height: 4)), with: .color(leadGray))
                    // Glass pieces in channels
                    ctx.fill(Path(CGRect(x: hx + 4, y: hy + 2, width: 12, height: 16)), with: .color(cobaltBlue.opacity(0.3)))
                    ctx.fill(Path(CGRect(x: hx + 4, y: hy + 22, width: 12, height: 16)), with: .color(.red.opacity(0.2)))

                    // Label
                    let labelX = hx + 30
                    var line = Path()
                    line.move(to: CGPoint(x: hx + 20, y: hy + 20))
                    line.addLine(to: CGPoint(x: labelX, y: hy + 20))
                    ctx.stroke(line, with: .color(IVMaterialColors.sepiaInk.opacity(0.3)), lineWidth: 0.5)
                }

                // Step 2+: assembled window segment
                if step >= 2 {
                    let wx = cx + 20, wy = cy - 25
                    let pieces: [(CGRect, Color)] = [
                        (CGRect(x: wx, y: wy, width: 25, height: 20), cobaltBlue.opacity(0.4)),
                        (CGRect(x: wx + 28, y: wy, width: 20, height: 20), .red.opacity(0.25)),
                        (CGRect(x: wx, y: wy + 23, width: 20, height: 25), .green.opacity(0.25)),
                        (CGRect(x: wx + 23, y: wy + 23, width: 25, height: 25), goldAccent.opacity(0.3)),
                    ]

                    for (rect, glassColor) in pieces {
                        ctx.fill(Path(rect), with: .color(glassColor))
                        ctx.stroke(Path(rect), with: .color(leadGray), lineWidth: 2)
                    }
                }

                // Step 3: rose window hint (circular pattern)
                if step >= 3 {
                    let roseY = size.height * 0.72
                    let roseR: CGFloat = 25
                    let rose = Path(ellipseIn: CGRect(x: cx - roseR, y: roseY - roseR, width: roseR * 2, height: roseR * 2))
                    ctx.stroke(rose, with: .color(leadGray), lineWidth: 1.5)

                    // Radial spokes
                    for i in 0..<8 {
                        let a = CGFloat(i) * .pi / 4
                        var spoke = Path()
                        spoke.move(to: CGPoint(x: cx, y: roseY))
                        spoke.addLine(to: CGPoint(x: cx + cos(a) * roseR, y: roseY + sin(a) * roseR))
                        ctx.stroke(spoke, with: .color(leadGray.opacity(0.5)), lineWidth: 1)
                    }

                    // Colored segments
                    let segColors: [Color] = [cobaltBlue, .red, .green, goldAccent, cobaltBlue, .purple, .red, .green]
                    for i in 0..<8 {
                        let a1 = CGFloat(i) * .pi / 4
                        let a2 = CGFloat(i + 1) * .pi / 4
                        var seg = Path()
                        seg.move(to: CGPoint(x: cx, y: roseY))
                        seg.addArc(center: CGPoint(x: cx, y: roseY), radius: roseR * 0.8,
                                   startAngle: .radians(a1), endAngle: .radians(a2), clockwise: false)
                        seg.closeSubpath()
                        ctx.fill(seg, with: .color(segColors[i].opacity(0.2)))
                    }
                }
            }
        }
    }
}
