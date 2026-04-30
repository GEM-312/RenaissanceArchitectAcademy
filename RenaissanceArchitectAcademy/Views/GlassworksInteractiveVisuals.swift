import SwiftUI

/// Interactive science visuals for Glassworks knowledge cards (12 cards)
struct GlassworksInteractiveVisuals {

    @ViewBuilder
    static func view(for visual: CardVisual, color: Color, height: CGFloat = 275) -> some View {
        let h = height
        Group {
            switch visual.title {
            case let t where t.contains("Murano") && t.contains("Secrets"):
                MuranoIslandVisual(visual: visual, color: color, height: h)
            case let t where t.contains("The Furnace"):
                FurnaceColorVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Three Chambers"):
                ThreeChamberVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Cristallo"):
                CristalloChemVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Annealing"):
                AnnealingCurveVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Limestone Flux"):
                FluxMeltingVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Crucibles"):
                CrucibleVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Blowpipes"):
                BlowpipeVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Support: Fuel"):
                FuelConsumptionVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Ventilation"):
                ConvectionVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Glass Batch"):
                GlassBatchVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Crucible Prep"):
                CruciblePreheatVisual(visual: visual, color: color, height: h)
            default:
                EmptyView()
            }
        }
    }

    static func hasInteractiveVisual(for visual: CardVisual) -> Bool {
        let t = visual.title
        return (t.contains("Murano") && t.contains("Secrets")) ||
               t.contains("The Furnace") || t.contains("Three Chambers") ||
               t.contains("Cristallo") || t.contains("Annealing") ||
               t.contains("Limestone Flux") || t.contains("Crucibles") ||
               t.contains("Blowpipes") || t.contains("Support: Fuel") ||
               t.contains("Ventilation") || t.contains("Glass Batch") ||
               t.contains("Crucible Prep")
    }
}

// MARK: - Local Colors

private let furnaceOrange = Color(red: 0.92, green: 0.55, blue: 0.18)
private let glassGreen = Color(red: 0.45, green: 0.68, blue: 0.48)
private let moltenYellow = Color(red: 0.95, green: 0.82, blue: 0.30)
private let crystalClear = Color(red: 0.80, green: 0.88, blue: 0.92)
private let bronzePipe = Color(red: 0.72, green: 0.55, blue: 0.35)

private typealias TeachingContainer = IVTeachingContainer
private typealias DimLabel = IVDimLabel
private typealias FormulaText = IVFormulaText
private typealias DimLine = IVDimLine

// MARK: - 1. Murano Island — Secrecy

private struct MuranoIslandVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1

    private let labels = ["1291: all glassmakers moved to Murano island",
                          "Island = isolation. Fleeing masters faced death",
                          "300 years of the world's finest glass — Cristallo"]

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            Canvas { ctx, size in
                let cx = size.width / 2, cy = size.height * 0.4

                // Water background
                let water = CGRect(x: 10, y: 10, width: size.width - 20, height: size.height * 0.7)
                ctx.fill(Path(roundedRect: water, cornerRadius: 6), with: .color(IVMaterialColors.waterBlue.opacity(0.08)))

                // Island shape
                let islandR: CGFloat = min(size.width, size.height) * 0.25
                var island = Path()
                island.addEllipse(in: CGRect(x: cx - islandR * 1.2, y: cy - islandR * 0.7,
                                             width: islandR * 2.4, height: islandR * 1.4))
                ctx.fill(island, with: .color(Color(red: 0.82, green: 0.76, blue: 0.65).opacity(0.4)))
                ctx.stroke(island, with: .color(IVMaterialColors.sepiaInk.opacity(0.3)), lineWidth: 1)

                // Furnace on island
                if step >= 1 {
                    let fRect = CGRect(x: cx - 10, y: cy - 12, width: 20, height: 18)
                    ctx.fill(Path(roundedRect: fRect, cornerRadius: 2), with: .color(furnaceOrange.opacity(0.4)))
                    ctx.stroke(Path(roundedRect: fRect, cornerRadius: 2), with: .color(IVMaterialColors.sepiaInk.opacity(0.3)), lineWidth: 1)
                    // Smoke
                    var smoke = Path()
                    smoke.move(to: CGPoint(x: cx, y: cy - 12))
                    smoke.addQuadCurve(to: CGPoint(x: cx + 5, y: cy - 30),
                                       control: CGPoint(x: cx - 8, y: cy - 20))
                    ctx.stroke(smoke, with: .color(IVMaterialColors.sepiaInk.opacity(0.15)), lineWidth: 1)
                }

                // Step 2: lock symbol
                if step >= 2 {
                    // Water barrier waves
                    for i in 0..<3 {
                        let wy = cy + islandR * 0.5 + CGFloat(i) * 8
                        var wave = Path()
                        wave.move(to: CGPoint(x: cx - islandR * 1.5, y: wy))
                        for j in 0..<6 {
                            let wx = cx - islandR * 1.5 + CGFloat(j) * islandR * 0.5
                            wave.addQuadCurve(to: CGPoint(x: wx + islandR * 0.25, y: wy),
                                              control: CGPoint(x: wx + islandR * 0.125, y: wy - 3))
                        }
                        ctx.stroke(wave, with: .color(IVMaterialColors.waterBlue.opacity(0.2)), lineWidth: 0.5)
                    }
                }

                // Step 3: cristallo sparkle
                if step >= 3 {
                    let sparkles: [CGPoint] = [
                        CGPoint(x: cx - 25, y: cy - 5),
                        CGPoint(x: cx + 20, y: cy + 5),
                        CGPoint(x: cx + 5, y: cy - 8),
                    ]
                    for sp in sparkles {
                        var star = Path()
                        for a in stride(from: 0.0, to: Double.pi * 2, by: Double.pi / 2) {
                            let outer = CGPoint(x: sp.x + cos(a) * 4, y: sp.y + sin(a) * 4)
                            let inner = CGPoint(x: sp.x + cos(a + .pi / 4) * 1.5, y: sp.y + sin(a + .pi / 4) * 1.5)
                            star.move(to: sp)
                            star.addLine(to: outer)
                            star.move(to: sp)
                            star.addLine(to: inner)
                        }
                        ctx.stroke(star, with: .color(crystalClear.opacity(0.6)), lineWidth: 0.5)
                    }
                }
            }
        }
    }
}

// MARK: - 2. Furnace Temperature by Color

private struct FurnaceColorVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1

    private let labels = ["Dull red glow: 600°C — too cool for glass",
                          "Cherry red → orange: 800-1,000°C — getting close",
                          "Yellow-white: 1,100°C — working temperature"]

    private let tempColors: [(String, Color, String)] = [
        ("600°C", Color(red: 0.6, green: 0.15, blue: 0.1), "Dull Red"),
        ("800°C", IVMaterialColors.cherryRed, "Cherry"),
        ("1,000°C", Color(red: 0.95, green: 0.55, blue: 0.15), "Orange"),
        ("1,100°C", Color(red: 0.98, green: 0.90, blue: 0.55), "Yellow-White"),
    ]

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            HStack(spacing: 6) {
                ForEach(Array(tempColors.enumerated()), id: \.offset) { i, temp in
                    let active = (step == 1 && i == 0) || (step == 2 && i <= 2) || (step == 3)
                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(active ? temp.1 : Color.gray.opacity(0.1))
                            .frame(height: 55)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .strokeBorder(active ? temp.1.opacity(0.8) : Color.gray.opacity(0.15), lineWidth: 1)
                            )
                            .shadow(color: active && i == 3 ? moltenYellow.opacity(0.3) : .clear, radius: 6)

                        Text(temp.0)
                            .font(RenaissanceFont.ivFormula)
                            .foregroundStyle(active ? IVMaterialColors.dimColor : IVMaterialColors.dimColor.opacity(0.3))

                        Text(temp.2)
                            .font(RenaissanceFont.ivBody)
                            .foregroundStyle(active ? IVMaterialColors.sepiaInk : IVMaterialColors.sepiaInk.opacity(0.3))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 8)
        }
    }
}

// MARK: - 3. Three-Chamber Furnace

private struct ThreeChamberVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1

    private let labels = ["Bottom: firebox — combustion zone",
                          "Middle: crucible chamber — 1,100°C melting",
                          "Top: annealing lehr — slow cooling. Heat rises naturally"]

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            Canvas { ctx, size in
                let cx = size.width / 2
                let furnaceW = size.width * 0.45, chamberH = size.height * 0.18
                let topY = size.height * 0.08
                let gap: CGFloat = 4

                let chambers: [(String, Color, CGFloat)] = [
                    ("Lehr (cooling)", crystalClear.opacity(0.3), topY),
                    ("Crucible (1,100°C)", furnaceOrange.opacity(0.4), topY + chamberH + gap),
                    ("Firebox (fire)", IVMaterialColors.cherryRed.opacity(0.3), topY + (chamberH + gap) * 2),
                ]

                for (i, (label, fillColor, y)) in chambers.enumerated() {
                    let chamberStep = 3 - i  // firebox=1, crucible=2, lehr=3
                    let active = step >= chamberStep

                    let rect = CGRect(x: cx - furnaceW / 2, y: y, width: furnaceW, height: chamberH)
                    ctx.fill(Path(roundedRect: rect, cornerRadius: 4),
                             with: .color(active ? fillColor : Color.gray.opacity(0.05)))
                    ctx.stroke(Path(roundedRect: rect, cornerRadius: 4),
                               with: .color(active ? IVMaterialColors.sepiaInk.opacity(0.4) : IVMaterialColors.sepiaInk.opacity(0.1)), lineWidth: 1)
                }

                // Heat rise arrows (step 3)
                if step >= 3 {
                    for i in 0..<3 {
                        let ax = cx - 15 + CGFloat(i) * 15
                        let fromY = topY + (chamberH + gap) * 2 + chamberH / 2
                        let toY = topY + chamberH / 2
                        var arrow = Path()
                        arrow.move(to: CGPoint(x: ax, y: fromY))
                        arrow.addLine(to: CGPoint(x: ax, y: toY))
                        ctx.stroke(arrow, with: .color(furnaceOrange.opacity(0.3)),
                                   style: StrokeStyle(lineWidth: 1, dash: [3, 2]))
                    }
                    // Upward arrowhead
                    var head = Path()
                    head.move(to: CGPoint(x: cx, y: topY + chamberH / 2 - 4))
                    head.addLine(to: CGPoint(x: cx - 5, y: topY + chamberH / 2 + 3))
                    head.addLine(to: CGPoint(x: cx + 5, y: topY + chamberH / 2 + 3))
                    head.closeSubpath()
                    ctx.fill(head, with: .color(furnaceOrange.opacity(0.4)))
                }
            }
        }
    }
}

// MARK: - 4. Cristallo — Manganese Decolorization

private struct CristalloChemVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1

    private let labels = ["Raw glass is green — iron impurities absorb red light",
                          "Add MnO₂ (manganese) — absorbs green, neutralizes color",
                          "Result: Cristallo — perfectly balanced, not pure"]

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            HStack(spacing: 12) {
                // Green glass
                VStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(glassGreen.opacity(step >= 1 ? 0.5 : 0.1))
                        .frame(width: 55, height: 65)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .strokeBorder(glassGreen.opacity(step >= 1 ? 0.6 : 0.1), lineWidth: 1.5)
                        )
                    Text("Raw")
                        .font(.custom("Cinzel-Bold", size: 16))
                        .foregroundStyle(step >= 1 ? IVMaterialColors.sepiaInk : IVMaterialColors.sepiaInk.opacity(0.3))
                    Text("Fe → green")
                        .font(RenaissanceFont.ivBody)
                        .foregroundStyle(step >= 1 ? glassGreen : glassGreen.opacity(0.3))
                }

                // Plus MnO₂
                if step >= 2 {
                    VStack(spacing: 2) {
                        Text("+")
                            .font(.custom("Cinzel-Bold", size: 16))
                            .foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.4))
                        Text("MnO₂")
                            .font(RenaissanceFont.ivFormula)
                            .foregroundStyle(RenaissanceColors.blueprintBlue.opacity(0.6))
                    }
                }

                // Arrow
                if step >= 2 {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 13))
                        .foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.3))
                }

                // Clear glass (Cristallo)
                if step >= 3 {
                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(crystalClear.opacity(0.3))
                            .frame(width: 55, height: 65)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .strokeBorder(crystalClear.opacity(0.5), lineWidth: 1.5)
                            )
                            .shadow(color: crystalClear.opacity(0.2), radius: 4)
                        Text("Cristallo")
                            .font(.custom("Cinzel-Bold", size: 16))
                            .foregroundStyle(color)
                        Text("Clear")
                            .font(RenaissanceFont.ivBody)
                            .foregroundStyle(IVMaterialColors.sepiaInk)
                    }
                }
            }
            .padding(.horizontal, 12)
        }
    }
}

// MARK: - 5. Annealing Cooling Curve

private struct AnnealingCurveVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1

    private let labels = ["Start at 500°C in the annealing lehr",
                          "Cool at 1°C per minute — even molecule rearrangement",
                          "24 hours to room temperature — patience is structural"]

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            Canvas { ctx, size in
                let padL: CGFloat = 40, padR: CGFloat = 15
                let padT: CGFloat = 15, padB: CGFloat = 25
                let graphW = size.width - padL - padR
                let graphH = size.height * 0.65 - padT

                // Axes
                var axes = Path()
                axes.move(to: CGPoint(x: padL, y: padT))
                axes.addLine(to: CGPoint(x: padL, y: padT + graphH))
                axes.addLine(to: CGPoint(x: padL + graphW, y: padT + graphH))
                ctx.stroke(axes, with: .color(IVMaterialColors.sepiaInk.opacity(0.3)), lineWidth: 1)

                // Gradual cooling curve
                let progressT: CGFloat = step == 1 ? 0.1 : step == 2 ? 0.5 : 1.0
                var curve = Path()
                let steps = 30
                for i in 0...steps {
                    let t = CGFloat(i) / CGFloat(steps) * progressT
                    let x = padL + t * graphW
                    let temp = 500.0 * exp(-3.0 * Double(t))  // exponential decay
                    let y = padT + (1 - CGFloat(temp / 500.0)) * graphH

                    if i == 0 { curve.move(to: CGPoint(x: x, y: y)) }
                    else { curve.addLine(to: CGPoint(x: x, y: y)) }
                }
                ctx.stroke(curve, with: .color(color), lineWidth: 2)

                // Start dot at 500°C
                let startDot = Path(ellipseIn: CGRect(x: padL - 3, y: padT - 3, width: 6, height: 6))
                ctx.fill(startDot, with: .color(furnaceOrange))

                // Danger zone: fast cooling (step 2+)
                if step >= 2 {
                    // Fast cooling dashed line
                    var fast = Path()
                    fast.move(to: CGPoint(x: padL, y: padT))
                    fast.addLine(to: CGPoint(x: padL + graphW * 0.15, y: padT + graphH))
                    ctx.stroke(fast, with: .color(IVMaterialColors.cherryRed.opacity(0.4)),
                               style: StrokeStyle(lineWidth: 1.5, dash: [4, 3]))
                }

                // Step 3: end dot + 24h label
                if step >= 3 {
                    let endX = padL + graphW
                    let endY = padT + graphH - 5
                    let endDot = Path(ellipseIn: CGRect(x: endX - 3, y: endY - 3, width: 6, height: 6))
                    ctx.fill(endDot, with: .color(color))
                }
            }
        }
    }
}

// MARK: - 6. Flux — Melting Point Reduction

private struct FluxMeltingVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1

    private let labels = ["Pure silica melts at 1,700°C — far too hot",
                          "Add 10% limestone (CaCO₃) as flux",
                          "Melting point drops to 1,100°C — workable!"]

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            VStack(spacing: 10) {
                // Temperature bars
                HStack(spacing: 16) {
                    // Pure silica
                    VStack(spacing: 4) {
                        ZStack(alignment: .bottom) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.1))
                                .frame(width: 35, height: 90)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(step >= 1 ? IVMaterialColors.cherryRed.opacity(0.6) : Color.gray.opacity(0.1))
                                .frame(width: 35, height: 90)
                        }
                        Text("1,700°C")
                            .font(RenaissanceFont.ivFormula)
                            .foregroundStyle(step >= 1 ? IVMaterialColors.cherryRed : IVMaterialColors.cherryRed.opacity(0.3))
                        Text("SiO₂")
                            .font(.custom("Cinzel-Bold", size: 16))
                            .foregroundStyle(step >= 1 ? IVMaterialColors.sepiaInk : IVMaterialColors.sepiaInk.opacity(0.3))
                    }

                    // With flux
                    if step >= 2 {
                        VStack(spacing: 2) {
                            Text("+10%")
                                .font(RenaissanceFont.ivFormula)
                                .foregroundStyle(IVMaterialColors.dimColor)
                            Text("CaCO₃")
                                .font(RenaissanceFont.ivBody)
                                .foregroundStyle(IVMaterialColors.dimColor)
                        }
                    }

                    if step >= 3 {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 13))
                            .foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.3))

                        VStack(spacing: 4) {
                            ZStack(alignment: .bottom) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.gray.opacity(0.1))
                                    .frame(width: 35, height: 90)
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(furnaceOrange.opacity(0.5))
                                    .frame(width: 35, height: 58)  // ~65% of 90
                            }
                            Text("1,100°C")
                                .font(RenaissanceFont.ivFormula)
                                .foregroundStyle(color)
                            Text("+ Flux")
                                .font(.custom("Cinzel-Bold", size: 16))
                                .foregroundStyle(color)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - 7. Crucible — Refractory Clay

private struct CrucibleVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1

    private let labels = ["Refractory clay from Vicenza hills — rich in alumina (Al₂O₃)",
                          "Hand-coiled, dried slowly, pre-fired to 1,300°C",
                          "Withstands 1,100°C for 6 months — harder to make than glass"]

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            Canvas { ctx, size in
                let cx = size.width / 2, cy = size.height * 0.4

                // Crucible shape (pot)
                var pot = Path()
                let potW: CGFloat = 50, potH: CGFloat = 55
                pot.move(to: CGPoint(x: cx - potW / 2, y: cy - potH / 3))
                pot.addLine(to: CGPoint(x: cx - potW * 0.4, y: cy + potH / 2))
                pot.addQuadCurve(to: CGPoint(x: cx + potW * 0.4, y: cy + potH / 2),
                                 control: CGPoint(x: cx, y: cy + potH * 0.6))
                pot.addLine(to: CGPoint(x: cx + potW / 2, y: cy - potH / 3))
                // Rim
                pot.addQuadCurve(to: CGPoint(x: cx - potW / 2, y: cy - potH / 3),
                                 control: CGPoint(x: cx, y: cy - potH / 2.5))

                let clayColor = Color(red: 0.72, green: 0.55, blue: 0.38)
                ctx.fill(pot, with: .color(step >= 1 ? clayColor.opacity(0.5) : clayColor.opacity(0.15)))
                ctx.stroke(pot, with: .color(IVMaterialColors.sepiaInk.opacity(0.4)), lineWidth: 1.5)

                // Step 2: coiling lines
                if step >= 2 {
                    for i in 1..<5 {
                        let y = cy - potH / 3 + CGFloat(i) * potH * 0.2
                        let halfW = potW * 0.35 + CGFloat(i) * 2
                        var coil = Path()
                        coil.move(to: CGPoint(x: cx - halfW, y: y))
                        coil.addLine(to: CGPoint(x: cx + halfW, y: y))
                        ctx.stroke(coil, with: .color(IVMaterialColors.sepiaInk.opacity(0.15)), lineWidth: 0.5)
                    }
                }

                // Step 3: molten glass inside + heat glow
                if step >= 3 {
                    var molten = Path()
                    molten.addEllipse(in: CGRect(x: cx - potW * 0.3, y: cy - 5, width: potW * 0.6, height: potH * 0.25))
                    ctx.fill(molten, with: .color(moltenYellow.opacity(0.5)))

                    // Heat glow around pot
                    let glow = Path(ellipseIn: CGRect(x: cx - potW * 0.7, y: cy - potH * 0.5,
                                                       width: potW * 1.4, height: potH * 1.1))
                    ctx.stroke(glow, with: .color(furnaceOrange.opacity(0.15)), lineWidth: 3)
                }
            }
        }
    }
}

// MARK: - 8. Blowpipe — Bronze Tube

private struct BlowpipeVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1

    private let labels = ["1.5-meter bronze tube — slow heat conductor",
                          "Constant rotation prevents gravity distortion",
                          "2 kg molten glass gather on the tip"]

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            Canvas { ctx, size in
                let pipeY = size.height * 0.4
                let startX: CGFloat = 15, endX = size.width - 25

                // Pipe
                let pipeRect = CGRect(x: startX, y: pipeY - 3, width: endX - startX, height: 6)
                ctx.fill(Path(pipeRect), with: .color(bronzePipe.opacity(step >= 1 ? 0.6 : 0.2)))
                ctx.stroke(Path(pipeRect), with: .color(IVMaterialColors.sepiaInk.opacity(0.3)), lineWidth: 0.5)

                // Dimension line
                if step >= 1 {
                    let dimY = pipeY + 20
                    ctx.stroke(IVDimLine(from: CGPoint(x: startX, y: dimY), to: CGPoint(x: endX, y: dimY)).path(in: .zero),
                               with: .color(IVMaterialColors.dimColor), lineWidth: 0.5)
                }

                // Step 2: rotation arrows
                if step >= 2 {
                    let rotX = (startX + endX) / 2
                    var arc = Path()
                    arc.addArc(center: CGPoint(x: rotX, y: pipeY),
                               radius: 12, startAngle: .degrees(-120), endAngle: .degrees(120), clockwise: false)
                    ctx.stroke(arc, with: .color(color.opacity(0.5)),
                               style: StrokeStyle(lineWidth: 1, dash: [3, 2]))
                    // Arrow tip
                    var tip = Path()
                    tip.move(to: CGPoint(x: rotX + 10, y: pipeY + 10))
                    tip.addLine(to: CGPoint(x: rotX + 14, y: pipeY + 6))
                    tip.addLine(to: CGPoint(x: rotX + 7, y: pipeY + 7))
                    ctx.stroke(tip, with: .color(color.opacity(0.5)), lineWidth: 1)
                }

                // Step 3: glass gather blob
                if step >= 3 {
                    let blobX = endX + 5
                    let blob = Path(ellipseIn: CGRect(x: blobX - 12, y: pipeY - 15, width: 24, height: 28))
                    ctx.fill(blob, with: .color(moltenYellow.opacity(0.5)))
                    ctx.stroke(blob, with: .color(furnaceOrange.opacity(0.4)), lineWidth: 1)
                }
            }
        }
    }
}

// MARK: - 9. Fuel Consumption

private struct FuelConsumptionVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1

    private let labels = ["Oak preferred: burns hot and long — 45 min per log",
                          "6 tons of wood consumed per furnace per day",
                          "2,000 tons/year — stripped the Dalmatian coast"]

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            VStack(spacing: 8) {
                // Log with flame
                HStack(spacing: 4) {
                    ForEach(0..<(step >= 2 ? 6 : step >= 1 ? 1 : 0), id: \.self) { _ in
                        VStack(spacing: 2) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 13))
                                .foregroundStyle(furnaceOrange.opacity(0.6))
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color(red: 0.50, green: 0.35, blue: 0.20).opacity(0.5))
                                .frame(width: 20, height: 10)
                        }
                    }
                }

                if step >= 1 {
                    Text("1 log = 45 min")
                        .font(RenaissanceFont.ivBody)
                        .foregroundStyle(IVMaterialColors.dimColor)
                }

                if step >= 2 {
                    Text("6 tons / day")
                        .font(RenaissanceFont.ivFormula)
                        .foregroundStyle(color)
                }

                if step >= 3 {
                    Text("2,000 tons / year")
                        .font(.custom("Cinzel-Bold", size: 16))
                        .foregroundStyle(IVMaterialColors.cherryRed.opacity(0.7))
                }
            }
        }
    }
}

// MARK: - 10. Convection Ventilation

private struct ConvectionVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1

    private let labels = ["Furnace at center creates rising hot air column",
                          "Hot air exits chimney, pulls cool sea air in from sides",
                          "Workers stand in cross-draft zone — survives 12-hour shifts"]

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            Canvas { ctx, size in
                let cx = size.width / 2, floorY = size.height * 0.7

                // Workshop walls (open sides)
                var leftWall = Path()
                leftWall.addRect(CGRect(x: 20, y: size.height * 0.1, width: 4, height: floorY - size.height * 0.1))
                var rightWall = Path()
                rightWall.addRect(CGRect(x: size.width - 24, y: size.height * 0.1, width: 4, height: floorY - size.height * 0.1))
                ctx.fill(leftWall, with: .color(Color(red: 0.55, green: 0.42, blue: 0.30).opacity(0.3)))
                ctx.fill(rightWall, with: .color(Color(red: 0.55, green: 0.42, blue: 0.30).opacity(0.3)))

                // Floor
                var floor = Path()
                floor.addRect(CGRect(x: 20, y: floorY, width: size.width - 40, height: 4))
                ctx.fill(floor, with: .color(IVMaterialColors.sepiaInk.opacity(0.2)))

                // Furnace at center
                let furnaceRect = CGRect(x: cx - 15, y: floorY - 25, width: 30, height: 25)
                ctx.fill(Path(roundedRect: furnaceRect, cornerRadius: 3), with: .color(furnaceOrange.opacity(0.5)))

                // Step 1: rising hot air
                if step >= 1 {
                    for i in 0..<3 {
                        let ax = cx - 8 + CGFloat(i) * 8
                        var arrow = Path()
                        arrow.move(to: CGPoint(x: ax, y: floorY - 30))
                        arrow.addCurve(to: CGPoint(x: ax + 3, y: size.height * 0.05),
                                       control1: CGPoint(x: ax + 5, y: floorY - 50),
                                       control2: CGPoint(x: ax - 3, y: size.height * 0.2))
                        ctx.stroke(arrow, with: .color(furnaceOrange.opacity(0.4)),
                                   style: StrokeStyle(lineWidth: 1, dash: [3, 2]))
                    }
                }

                // Step 2: cool air from sides
                if step >= 2 {
                    for side: CGFloat in [-1, 1] {
                        let startX = side < 0 ? CGFloat(10) : size.width - 10
                        let endX = cx + side * 40
                        let airY = floorY - 12
                        var cool = Path()
                        cool.move(to: CGPoint(x: startX, y: airY))
                        cool.addLine(to: CGPoint(x: endX, y: airY))
                        ctx.stroke(cool, with: .color(IVMaterialColors.waterBlue.opacity(0.4)), lineWidth: 1.5)
                        // Arrowhead
                        var head = Path()
                        head.move(to: CGPoint(x: endX, y: airY))
                        head.addLine(to: CGPoint(x: endX - side * 6, y: airY - 4))
                        head.addLine(to: CGPoint(x: endX - side * 6, y: airY + 4))
                        head.closeSubpath()
                        ctx.fill(head, with: .color(IVMaterialColors.waterBlue.opacity(0.4)))
                    }
                }

                // Step 3: worker figure in cross-draft
                if step >= 3 {
                    let workerX = cx + 35
                    // Simple stick figure
                    let headCircle = Path(ellipseIn: CGRect(x: workerX - 4, y: floorY - 22, width: 8, height: 8))
                    ctx.fill(headCircle, with: .color(IVMaterialColors.sepiaInk.opacity(0.3)))
                    var body = Path()
                    body.move(to: CGPoint(x: workerX, y: floorY - 14))
                    body.addLine(to: CGPoint(x: workerX, y: floorY - 4))
                    body.move(to: CGPoint(x: workerX - 5, y: floorY - 10))
                    body.addLine(to: CGPoint(x: workerX + 5, y: floorY - 10))
                    body.move(to: CGPoint(x: workerX, y: floorY - 4))
                    body.addLine(to: CGPoint(x: workerX - 4, y: floorY))
                    body.move(to: CGPoint(x: workerX, y: floorY - 4))
                    body.addLine(to: CGPoint(x: workerX + 4, y: floorY))
                    ctx.stroke(body, with: .color(IVMaterialColors.sepiaInk.opacity(0.4)), lineWidth: 1)
                }
            }
        }
    }
}

// MARK: - 11. Glass Batch Recipe

private struct GlassBatchVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1

    private let labels = ["60% silica sand (washed 3 times for purity)",
                          "15% soda + 10% lime (seashell) + 15% cullet",
                          "Mix dry for 30 minutes — cullet ensures uniform melt"]

    private let ingredients: [(String, String, CGFloat, Color)] = [
        ("Silica", "60%", 0.6, Color(red: 0.88, green: 0.82, blue: 0.68)),
        ("Soda", "15%", 0.15, Color(red: 0.75, green: 0.80, blue: 0.85)),
        ("Lime", "10%", 0.10, Color(red: 0.90, green: 0.88, blue: 0.82)),
        ("Cullet", "15%", 0.15, crystalClear),
    ]

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            VStack(spacing: 6) {
                // Stacked bar
                GeometryReader { geo in
                    HStack(spacing: 1) {
                        ForEach(Array(ingredients.enumerated()), id: \.offset) { i, ing in
                            let active = (step == 1 && i == 0) || (step >= 2)
                            Rectangle()
                                .fill(active ? ing.3 : Color.gray.opacity(0.1))
                                .frame(width: geo.size.width * ing.2)
                                .overlay {
                                    VStack(spacing: 1) {
                                        Text(ing.1)
                                            .font(RenaissanceFont.ivFormula)
                                        Text(ing.0)
                                            .font(RenaissanceFont.ivBody)
                                    }
                                    .foregroundStyle(active ? IVMaterialColors.sepiaInk : .clear)
                                }
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .overlay(RoundedRectangle(cornerRadius: 4).strokeBorder(IVMaterialColors.sepiaInk.opacity(0.2), lineWidth: 0.5))
                }
                .frame(height: 50)

                if step >= 3 {
                    Text("Mix 30 min → furnace")
                        .font(RenaissanceFont.ivFormula)
                        .foregroundStyle(color)
                }
            }
            .padding(.horizontal, 8)
        }
    }
}

// MARK: - 12. Crucible Pre-heating Stages

private struct CruciblePreheatVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1

    private let labels = ["New crucible can't go straight into 1,100°C — thermal shock",
                          "4 stages over 3 days: 200 → 500 → 800 → 1,100°C",
                          "18 hours per stage — molecules need time to expand evenly"]

    private let stages: [(String, Color)] = [
        ("200°C", Color(red: 0.6, green: 0.15, blue: 0.1).opacity(0.3)),
        ("500°C", Color(red: 0.75, green: 0.25, blue: 0.15).opacity(0.5)),
        ("800°C", furnaceOrange.opacity(0.6)),
        ("1,100°C", moltenYellow.opacity(0.7)),
    ]

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            HStack(spacing: 6) {
                ForEach(Array(stages.enumerated()), id: \.offset) { i, stage in
                    let active = step >= 2
                    VStack(spacing: 4) {
                        // Crucible shape getting warmer
                        RoundedRectangle(cornerRadius: 4)
                            .fill(active ? stage.1 : Color.gray.opacity(0.08))
                            .frame(height: 45)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .strokeBorder(active ? IVMaterialColors.sepiaInk.opacity(0.3) : IVMaterialColors.sepiaInk.opacity(0.1), lineWidth: 0.5)
                            )

                        Text(stage.0)
                            .font(RenaissanceFont.ivFormula)
                            .foregroundStyle(active ? IVMaterialColors.dimColor : IVMaterialColors.dimColor.opacity(0.2))

                        if step >= 3 {
                            Text("18h")
                                .font(RenaissanceFont.ivBody)
                                .foregroundStyle(color.opacity(0.7))
                        }
                    }
                    .frame(maxWidth: .infinity)

                    if i < stages.count - 1 {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 13))
                            .foregroundStyle(active ? IVMaterialColors.sepiaInk.opacity(0.3) : .clear)
                    }
                }
            }
            .padding(.horizontal, 6)
        }
    }
}
