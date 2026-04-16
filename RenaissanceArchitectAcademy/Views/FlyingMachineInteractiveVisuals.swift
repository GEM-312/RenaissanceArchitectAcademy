import SwiftUI

/// Interactive science visuals for Flying Machine knowledge cards (11 cards)
struct FlyingMachineInteractiveVisuals {

    @ViewBuilder
    static func view(for visual: CardVisual, color: Color, height: CGFloat = 275) -> some View {
        let h = height
        Group {
            switch visual.title {
            case let t where t.contains("Ornithopter"):
                OrnithopterVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Bird Anatomy"):
                BirdAnatomyVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Wing Area"):
                WingAreaMathVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Power Ratio"):
                PowerRatioVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Monte Ceceri"):
                MonteCeceriVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Silk Covering"):
                SilkCoveringVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Bronze Pivots"):
                BronzePivotsVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Iron Cables"):
                IronCablesVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Wing Ribs"):
                WingRibsVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Oak Harness"):
                OakHarnessVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Silk Assembly"):
                SilkAssemblyVisual(visual: visual, color: color, height: h)
            default:
                EmptyView()
            }
        }
    }

    static func hasInteractiveVisual(for visual: CardVisual) -> Bool {
        let t = visual.title
        return t.contains("Ornithopter") || t.contains("Bird Anatomy") ||
               t.contains("Wing Area") || t.contains("Power Ratio") ||
               t.contains("Monte Ceceri") || t.contains("Silk Covering") ||
               t.contains("Bronze Pivots") || t.contains("Iron Cables") ||
               t.contains("Wing Ribs") || t.contains("Oak Harness") ||
               t.contains("Silk Assembly")
    }
}

// MARK: - Local Colors

private let silkCream = Color(red: 0.95, green: 0.92, blue: 0.85)
private let skyBlue = Color(red: 0.55, green: 0.72, blue: 0.88)
private let ironWire = Color(red: 0.48, green: 0.48, blue: 0.50)

private typealias TeachingContainer = IVTeachingContainer
private typealias DimLabel = IVDimLabel
private typealias FormulaText = IVFormulaText
private typealias DimLine = IVDimLine

// MARK: - 1. The Ornithopter

private struct OrnithopterVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    private let labels = ["Flapping-wing machine: pilot lies face-down, pedals wings",
                          "12-meter wingspan — 500 sketches in Leonardo's notebooks",
                          "35,000 words on flight. Never flew, most researched ever"]
    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            Canvas { ctx, size in
                let cx = size.width / 2, cy = size.height * 0.35
                // Wings
                let wingSpan = size.width * 0.8
                var leftWing = Path()
                leftWing.move(to: CGPoint(x: cx, y: cy))
                leftWing.addQuadCurve(to: CGPoint(x: cx - wingSpan / 2, y: cy - 10),
                                      control: CGPoint(x: cx - wingSpan / 4, y: step >= 1 ? cy - 25 : cy - 15))
                leftWing.addLine(to: CGPoint(x: cx - wingSpan / 2, y: cy + 5))
                leftWing.addQuadCurve(to: CGPoint(x: cx, y: cy + 5),
                                      control: CGPoint(x: cx - wingSpan / 4, y: cy + 3))
                ctx.fill(leftWing, with: .color(silkCream.opacity(step >= 1 ? 0.4 : 0.1)))
                ctx.stroke(leftWing, with: .color(IVMaterialColors.sepiaInk.opacity(0.3)), lineWidth: 1)
                // Right wing (mirror)
                var rightWing = Path()
                rightWing.move(to: CGPoint(x: cx, y: cy))
                rightWing.addQuadCurve(to: CGPoint(x: cx + wingSpan / 2, y: cy - 10),
                                       control: CGPoint(x: cx + wingSpan / 4, y: step >= 1 ? cy - 25 : cy - 15))
                rightWing.addLine(to: CGPoint(x: cx + wingSpan / 2, y: cy + 5))
                rightWing.addQuadCurve(to: CGPoint(x: cx, y: cy + 5),
                                       control: CGPoint(x: cx + wingSpan / 4, y: cy + 3))
                ctx.fill(rightWing, with: .color(silkCream.opacity(step >= 1 ? 0.4 : 0.1)))
                ctx.stroke(rightWing, with: .color(IVMaterialColors.sepiaInk.opacity(0.3)), lineWidth: 1)
                // Body/cradle
                let cradle = CGRect(x: cx - 8, y: cy - 3, width: 16, height: 20)
                ctx.fill(Path(roundedRect: cradle, cornerRadius: 3), with: .color(IVMaterialColors.oakBrown.opacity(0.4)))
                // Pilot head
                let head = Path(ellipseIn: CGRect(x: cx - 4, y: cy - 8, width: 8, height: 8))
                ctx.fill(head, with: .color(IVMaterialColors.sepiaInk.opacity(0.3)))
                // Step 2: wingspan dimension
                if step >= 2 {
                    let dimY = cy + 30
                    ctx.stroke(IVDimLine(from: CGPoint(x: cx - wingSpan / 2, y: dimY),
                                         to: CGPoint(x: cx + wingSpan / 2, y: dimY)).path(in: .zero),
                               with: .color(IVMaterialColors.dimColor), lineWidth: 0.5)
                }
                // Step 3: notebook sketches count
                if step >= 3 {
                    let noteY = cy + 45
                    let noteRect = CGRect(x: cx - 30, y: noteY, width: 60, height: 16)
                    ctx.fill(Path(roundedRect: noteRect, cornerRadius: 3), with: .color(color.opacity(0.08)))
                }
            }
            .overlay(alignment: .bottom) {
                if step >= 2 {
                    Text("12m wingspan")
                        .font(.custom("EBGaramond-Bold", size: 15))
                        .foregroundStyle(IVMaterialColors.dimColor)
                        .offset(y: step >= 3 ? -45 : -28)
                }
            }
            .overlay(alignment: .bottom) {
                if step >= 3 {
                    Text("500 sketches · 35,000 words")
                        .font(.custom("EBGaramond-Bold", size: 15))
                        .foregroundStyle(color)
                        .offset(y: -28)
                }
            }
        }
    }
}

// MARK: - 2. Bird Anatomy — Camber & Lift

private struct BirdAnatomyVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    private let labels = ["Wing cross-section: curved top (camber), flat bottom",
                          "Air faster over top → low pressure → lift",
                          "Twist on downstroke (thrust) + flatten on upstroke (less drag)"]
    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            Canvas { ctx, size in
                let cx = size.width / 2, cy = size.height * 0.35
                let airfoilW = size.width * 0.6
                // Airfoil cross-section
                var airfoil = Path()
                airfoil.move(to: CGPoint(x: cx - airfoilW / 2, y: cy))
                // Curved top
                airfoil.addQuadCurve(to: CGPoint(x: cx + airfoilW / 2, y: cy),
                                     control: CGPoint(x: cx, y: cy - 25))
                // Flat bottom (back to start)
                airfoil.addQuadCurve(to: CGPoint(x: cx - airfoilW / 2, y: cy),
                                     control: CGPoint(x: cx, y: cy + 5))
                ctx.fill(airfoil, with: .color(IVMaterialColors.sepiaInk.opacity(step >= 1 ? 0.1 : 0.03)))
                ctx.stroke(airfoil, with: .color(IVMaterialColors.sepiaInk.opacity(0.4)), lineWidth: 1.5)
                // Step 1: camber label
                if step >= 1 {
                    var camberLine = Path()
                    camberLine.move(to: CGPoint(x: cx, y: cy - 20))
                    camberLine.addLine(to: CGPoint(x: cx + 30, y: cy - 30))
                    ctx.stroke(camberLine, with: .color(IVMaterialColors.dimColor.opacity(0.5)), lineWidth: 0.5)
                }
                // Step 2: airflow arrows + pressure labels
                if step >= 2 {
                    // Fast air over top
                    for i in 0..<4 {
                        let ax = cx - airfoilW * 0.3 + CGFloat(i) * airfoilW * 0.2
                        let ay = cy - 18 - CGFloat(i % 2) * 5
                        var arrow = Path()
                        arrow.move(to: CGPoint(x: ax - 12, y: ay))
                        arrow.addLine(to: CGPoint(x: ax + 12, y: ay))
                        ctx.stroke(arrow, with: .color(skyBlue.opacity(0.5)), lineWidth: 1)
                    }
                    // Lift arrow (up)
                    var lift = Path()
                    lift.move(to: CGPoint(x: cx, y: cy - 5))
                    lift.addLine(to: CGPoint(x: cx, y: cy - 35))
                    ctx.stroke(lift, with: .color(color), lineWidth: 2)
                    var liftHead = Path()
                    liftHead.move(to: CGPoint(x: cx, y: cy - 35))
                    liftHead.addLine(to: CGPoint(x: cx - 4, y: cy - 29))
                    liftHead.addLine(to: CGPoint(x: cx + 4, y: cy - 29))
                    liftHead.closeSubpath()
                    ctx.fill(liftHead, with: .color(color))
                }
                // Step 3: downstroke vs upstroke
                if step >= 3 {
                    let dsY = cy + 30
                    // Downstroke arrow (down + forward)
                    var ds = Path()
                    ds.move(to: CGPoint(x: cx - 30, y: dsY))
                    ds.addLine(to: CGPoint(x: cx - 10, y: dsY + 15))
                    ctx.stroke(ds, with: .color(color.opacity(0.5)), lineWidth: 1.5)
                    // Upstroke arrow (up, flat)
                    var us = Path()
                    us.move(to: CGPoint(x: cx + 10, y: dsY + 15))
                    us.addLine(to: CGPoint(x: cx + 30, y: dsY))
                    ctx.stroke(us, with: .color(IVMaterialColors.sepiaInk.opacity(0.3)), style: StrokeStyle(lineWidth: 1, dash: [3, 2]))
                }
            }
        }
    }
}

// MARK: - 3. Wing Area Math

private struct WingAreaMathVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    private let labels = ["Rule: 0.1 m² wing area per kg of weight",
                          "90 kg pilot + machine → needs 18 m² of wing",
                          "Math correct! But humans produce only 1/10 bird power"]
    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            VStack(spacing: 10) {
                // Formula
                if step >= 1 {
                    Text("0.1 m² / kg × 90 kg = 18 m²")
                        .font(.custom("EBGaramond-Bold", size: 15))
                        .foregroundStyle(step >= 2 ? color : IVMaterialColors.sepiaInk)
                }
                // Power comparison
                if step >= 3 {
                    HStack(spacing: 20) {
                        VStack(spacing: 2) {
                            Text("🐦")
                                .font(.system(size: 20))
                            Text("10 W/kg")
                                .font(.custom("EBGaramond-Bold", size: 15))
                                .foregroundStyle(color)
                        }
                        VStack(spacing: 2) {
                            Text("vs")
                                .font(.custom("EBGaramond-Regular", size: 15))
                                .foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.3))
                        }
                        VStack(spacing: 2) {
                            Text("🧑")
                                .font(.system(size: 20))
                            Text("1 W/kg")
                                .font(.custom("EBGaramond-Bold", size: 15))
                                .foregroundStyle(.red.opacity(0.6))
                        }
                    }
                    Text("10× too weak to flap")
                        .font(.custom("EBGaramond-Bold", size: 15))
                        .foregroundStyle(.red.opacity(0.5))
                }
            }
        }
    }
}

// MARK: - 4. Power Ratio — Pivot to Glider

private struct PowerRatioVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    private let labels = ["Flapping requires 10× human power — impossible",
                          "Leonardo pivots to fixed-wing gliders (1505)",
                          "Hang glider design nearly identical to modern ones"]
    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            Canvas { ctx, size in
                let cx = size.width / 2, cy = size.height * 0.35
                if step == 1 {
                    // Flapping (crossed out)
                    var wing = Path()
                    wing.move(to: CGPoint(x: cx - 40, y: cy - 15))
                    wing.addQuadCurve(to: CGPoint(x: cx + 40, y: cy - 15),
                                      control: CGPoint(x: cx, y: cy - 35))
                    ctx.stroke(wing, with: .color(IVMaterialColors.sepiaInk.opacity(0.3)), lineWidth: 1.5)
                    // Red X
                    var xMark = Path()
                    xMark.move(to: CGPoint(x: cx - 15, y: cy - 25))
                    xMark.addLine(to: CGPoint(x: cx + 15, y: cy - 5))
                    xMark.move(to: CGPoint(x: cx + 15, y: cy - 25))
                    xMark.addLine(to: CGPoint(x: cx - 15, y: cy - 5))
                    ctx.stroke(xMark, with: .color(.red.opacity(0.5)), lineWidth: 2)
                }
                // Step 2+: fixed wing glider
                if step >= 2 {
                    // Fixed triangular wing
                    var glider = Path()
                    glider.move(to: CGPoint(x: cx, y: cy - 10))
                    glider.addLine(to: CGPoint(x: cx - 50, y: cy + 8))
                    glider.addLine(to: CGPoint(x: cx + 50, y: cy + 8))
                    glider.closeSubpath()
                    ctx.fill(glider, with: .color(silkCream.opacity(0.4)))
                    ctx.stroke(glider, with: .color(color.opacity(0.5)), lineWidth: 1.5)
                    // Pilot hanging below
                    var pilot = Path()
                    pilot.move(to: CGPoint(x: cx, y: cy + 8))
                    pilot.addLine(to: CGPoint(x: cx, y: cy + 25))
                    ctx.stroke(pilot, with: .color(IVMaterialColors.sepiaInk.opacity(0.3)), lineWidth: 1)
                    let pilotDot = Path(ellipseIn: CGRect(x: cx - 3, y: cy + 23, width: 6, height: 6))
                    ctx.fill(pilotDot, with: .color(IVMaterialColors.sepiaInk.opacity(0.3)))
                    // Control bar
                    var bar = Path()
                    bar.move(to: CGPoint(x: cx - 12, y: cy + 18))
                    bar.addLine(to: CGPoint(x: cx + 12, y: cy + 18))
                    ctx.stroke(bar, with: .color(IVMaterialColors.oakBrown.opacity(0.5)), lineWidth: 1.5)
                }
                // Step 3: thermals (rising air)
                if step >= 3 {
                    for i in 0..<3 {
                        let ax = cx - 20 + CGFloat(i) * 20
                        let startY = cy + 45
                        var thermal = Path()
                        thermal.move(to: CGPoint(x: ax, y: startY))
                        thermal.addCurve(to: CGPoint(x: ax + 3, y: startY - 25),
                                         control1: CGPoint(x: ax + 5, y: startY - 8),
                                         control2: CGPoint(x: ax - 5, y: startY - 18))
                        ctx.stroke(thermal, with: .color(Color.orange.opacity(0.25)),
                                   style: StrokeStyle(lineWidth: 1, dash: [2, 2]))
                    }
                }
            }
        }
    }
}

// MARK: - 5. Monte Ceceri

private struct MonteCeceriVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    private let labels = ["Monte Ceceri (Swan Mountain): 400m above Florence",
                          "'The great bird will take its first flight...' — Leonardo, 1505",
                          "Possibly attempted — Masini may have broken his leg"]
    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            Canvas { ctx, size in
                let cx = size.width / 2, baseY = size.height * 0.65
                // Mountain profile
                var mountain = Path()
                mountain.move(to: CGPoint(x: 10, y: baseY))
                mountain.addQuadCurve(to: CGPoint(x: cx, y: baseY - size.height * 0.45),
                                      control: CGPoint(x: cx * 0.5, y: baseY - size.height * 0.2))
                mountain.addQuadCurve(to: CGPoint(x: size.width - 10, y: baseY),
                                      control: CGPoint(x: cx * 1.5, y: baseY - size.height * 0.2))
                ctx.fill(mountain, with: .color(Color(red: 0.65, green: 0.58, blue: 0.48).opacity(0.2)))
                ctx.stroke(mountain, with: .color(IVMaterialColors.sepiaInk.opacity(0.3)), lineWidth: 1)
                // Step 1: height dimension
                if step >= 1 {
                    let peakY = baseY - size.height * 0.45
                    ctx.stroke(IVDimLine(from: CGPoint(x: size.width - 25, y: baseY),
                                         to: CGPoint(x: size.width - 25, y: peakY)).path(in: .zero),
                               with: .color(IVMaterialColors.dimColor), lineWidth: 0.5)
                }
                // Step 2: glider at peak
                if step >= 2 {
                    let peakX = cx, peakY = baseY - size.height * 0.45 - 10
                    var glider = Path()
                    glider.move(to: CGPoint(x: peakX - 15, y: peakY + 4))
                    glider.addLine(to: CGPoint(x: peakX, y: peakY - 4))
                    glider.addLine(to: CGPoint(x: peakX + 15, y: peakY + 4))
                    ctx.stroke(glider, with: .color(color), lineWidth: 1.5)
                }
                // Step 3: dotted flight path
                if step >= 3 {
                    let startX = cx, startY = baseY - size.height * 0.45 - 10
                    var flightPath = Path()
                    flightPath.move(to: CGPoint(x: startX, y: startY))
                    flightPath.addQuadCurve(to: CGPoint(x: startX + 60, y: startY + 30),
                                            control: CGPoint(x: startX + 40, y: startY - 5))
                    ctx.stroke(flightPath, with: .color(color.opacity(0.4)),
                               style: StrokeStyle(lineWidth: 1.5, dash: [4, 3]))
                }
            }
        }
    }
}

// MARK: - 6. Silk Covering

private struct SilkCoveringVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    private let labels = ["Taffeta di seta: strongest natural fiber per weight",
                          "Stretched over frame + sealed with linseed oil = airtight",
                          "2 kg covering resists 50 kg of air pressure"]
    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            VStack(spacing: 8) {
                // Silk swatch
                RoundedRectangle(cornerRadius: 6)
                    .fill(silkCream.opacity(step >= 1 ? 0.6 : 0.15))
                    .frame(height: 50)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .strokeBorder(IVMaterialColors.sepiaInk.opacity(0.2), lineWidth: 1)
                    )
                    .overlay {
                        if step >= 2 {
                            // Weave pattern
                            Canvas { ctx, size in
                                for i in stride(from: CGFloat(0), through: size.width, by: 6) {
                                    var v = Path(); v.move(to: CGPoint(x: i, y: 0)); v.addLine(to: CGPoint(x: i, y: size.height))
                                    ctx.stroke(v, with: .color(IVMaterialColors.sepiaInk.opacity(0.04)), lineWidth: 0.5)
                                }
                                for j in stride(from: CGFloat(0), through: size.height, by: 6) {
                                    var h = Path(); h.move(to: CGPoint(x: 0, y: j)); h.addLine(to: CGPoint(x: size.width, y: j))
                                    ctx.stroke(h, with: .color(IVMaterialColors.sepiaInk.opacity(0.04)), lineWidth: 0.5)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)

                if step >= 1 {
                    Text("Silk taffeta")
                        .font(.custom("Cinzel-Bold", size: 16))
                        .foregroundStyle(IVMaterialColors.sepiaInk)
                }

                if step >= 3 {
                    HStack(spacing: 16) {
                        VStack(spacing: 1) {
                            Text("2 kg").font(.custom("EBGaramond-Bold", size: 15)).foregroundStyle(color)
                            Text("weight").font(.custom("EBGaramond-Regular", size: 15)).foregroundStyle(IVMaterialColors.dimColor)
                        }
                        Text("resists")
                            .font(.custom("EBGaramond-Regular", size: 15))
                            .foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.4))
                        VStack(spacing: 1) {
                            Text("50 kg").font(.custom("EBGaramond-Bold", size: 15)).foregroundStyle(color)
                            Text("pressure").font(.custom("EBGaramond-Regular", size: 15)).foregroundStyle(IVMaterialColors.dimColor)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - 7. Bronze Pivots — 6 per Wing

private struct BronzePivotsVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    private let labels = ["6 pivot joints per wing for flapping + twisting",
                          "Bronze bearings with leather washers — no galling",
                          "Grease channels cut into bronze for continuous lubrication"]
    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            Canvas { ctx, size in
                let cx = size.width / 2, cy = size.height * 0.35
                // Wing outline with pivot points
                var wing = Path()
                wing.move(to: CGPoint(x: cx - 10, y: cy))
                wing.addLine(to: CGPoint(x: cx + size.width * 0.35, y: cy - 8))
                ctx.stroke(wing, with: .color(IVMaterialColors.sepiaInk.opacity(0.3)), lineWidth: 1.5)
                // 6 pivot dots along wing
                let pivotCount = step >= 1 ? 6 : 0
                for i in 0..<pivotCount {
                    let t = CGFloat(i) / 5
                    let px = cx - 10 + t * size.width * 0.35 + 10
                    let py = cy - t * 8
                    let pivotR: CGFloat = step >= 2 ? 5 : 3
                    let pivot = Path(ellipseIn: CGRect(x: px - pivotR, y: py - pivotR, width: pivotR * 2, height: pivotR * 2))
                    ctx.fill(pivot, with: .color(IVMaterialColors.bronzeGold.opacity(0.6)))
                    ctx.stroke(pivot, with: .color(IVMaterialColors.sepiaInk.opacity(0.3)), lineWidth: 0.5)
                    // Step 3: grease channel lines
                    if step >= 3 {
                        var channel = Path()
                        channel.addArc(center: CGPoint(x: px, y: py), radius: pivotR + 2,
                                       startAngle: .degrees(-45), endAngle: .degrees(135), clockwise: false)
                        ctx.stroke(channel, with: .color(IVMaterialColors.bronzeGold.opacity(0.3)),
                                   style: StrokeStyle(lineWidth: 0.5, dash: [2, 1]))
                    }
                }
            }
        }
    }
}

// MARK: - 8. Iron Cables — Work Hardening

private struct IronCablesVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    private let labels = ["Iron wire connects pedals to wing tips — tension cables",
                          "Drawn wire: pulled through progressively smaller dies",
                          "Work hardening doubles tensile strength vs cast iron"]
    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            VStack(spacing: 10) {
                // Wire drawing dies (step 2+)
                if step >= 2 {
                    HStack(spacing: 4) {
                        ForEach([14, 11, 8, 5, 3] as [CGFloat], id: \.self) { diameter in
                            Circle()
                                .strokeBorder(ironWire, lineWidth: 1)
                                .frame(width: diameter, height: diameter)
                        }
                        Image(systemName: "arrow.right")
                            .font(.system(size: 13))
                            .foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.3))
                        Rectangle()
                            .fill(ironWire.opacity(0.6))
                            .frame(width: 40, height: 2)
                    }
                }
                // Strength comparison (step 3)
                if step >= 3 {
                    HStack(spacing: 16) {
                        VStack(spacing: 2) {
                            Text("Cast").font(.custom("Cinzel-Bold", size: 16)).foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.5))
                            RoundedRectangle(cornerRadius: 2).fill(ironWire.opacity(0.3)).frame(width: 40, height: 20)
                            Text("1×").font(.custom("EBGaramond-Bold", size: 15)).foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.5))
                        }
                        VStack(spacing: 2) {
                            Text("Drawn").font(.custom("Cinzel-Bold", size: 16)).foregroundStyle(color)
                            RoundedRectangle(cornerRadius: 2).fill(ironWire.opacity(0.5)).frame(width: 40, height: 40)
                            Text("2×").font(.custom("EBGaramond-Bold", size: 15)).foregroundStyle(color)
                        }
                    }
                }
                if step == 1 {
                    Text("Pedals → cables → wing tips")
                        .font(.custom("EBGaramond-Bold", size: 15))
                        .foregroundStyle(IVMaterialColors.sepiaInk)
                }
            }
        }
    }
}

// MARK: - 9. Wing Ribs — Poplar Steam Bent

private struct WingRibsVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    private let labels = ["Poplar ribs: 40% lighter than oak, grows straight",
                          "Steam bending: boil → clamp on form → dry = permanent curve",
                          "20 ribs per wing, each 3m × 2cm — skeleton of flight"]
    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            Canvas { ctx, size in
                let cx = size.width / 2, cy = size.height * 0.4
                // Wing outline
                var wingOutline = Path()
                wingOutline.move(to: CGPoint(x: 15, y: cy + 5))
                wingOutline.addQuadCurve(to: CGPoint(x: size.width - 15, y: cy + 5),
                                         control: CGPoint(x: cx, y: cy - 30))
                ctx.stroke(wingOutline, with: .color(IVMaterialColors.sepiaInk.opacity(0.15)), lineWidth: 0.5)
                // Ribs (curved lines)
                let ribCount = step >= 3 ? 10 : step >= 1 ? 5 : 0
                for i in 0..<ribCount {
                    let t = CGFloat(i) / CGFloat(max(ribCount - 1, 1))
                    let startX = 20 + t * (size.width - 40)
                    var rib = Path()
                    rib.move(to: CGPoint(x: startX, y: cy + 5))
                    rib.addQuadCurve(to: CGPoint(x: startX + 2, y: cy - 15 - t * 10),
                                     control: CGPoint(x: startX + 5, y: cy - 5))
                    ctx.stroke(rib, with: .color(IVMaterialColors.poplarLight.opacity(step >= 1 ? 0.6 : 0.2)), lineWidth: 1.5)
                }
                // Step 2: steam bending process
                if step >= 2 {
                    let processY = cy + 25
                    let stages = ["Boil", "Clamp", "Dry"]
                    for (i, stage) in stages.enumerated() {
                        let sx = 30 + CGFloat(i) * (size.width - 60) / 2
                        let stageRect = CGRect(x: sx - 15, y: processY, width: 30, height: 14)
                        ctx.fill(Path(roundedRect: stageRect, cornerRadius: 2), with: .color(color.opacity(0.06)))
                    }
                }
            }
        }
    }
}

// MARK: - 10. Oak Harness

private struct OakHarnessVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    private let labels = ["Oak cradle holds pilot face-down with leather straps",
                          "Bears combined forces: weight + lift + pedaling torsion",
                          "Iron brackets reinforce joints — weakest link determines all"]
    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            Canvas { ctx, size in
                let cx = size.width / 2, cy = size.height * 0.35
                // Cradle frame
                let frameW: CGFloat = 50, frameH: CGFloat = 25
                let frame = CGRect(x: cx - frameW / 2, y: cy - frameH / 2, width: frameW, height: frameH)
                ctx.fill(Path(roundedRect: frame, cornerRadius: 3), with: .color(IVMaterialColors.oakBrown.opacity(step >= 1 ? 0.4 : 0.1)))
                ctx.stroke(Path(roundedRect: frame, cornerRadius: 3), with: .color(IVMaterialColors.sepiaInk.opacity(0.3)), lineWidth: 1.5)
                // Pilot (face down)
                if step >= 1 {
                    let head = Path(ellipseIn: CGRect(x: cx - 4, y: cy - frameH / 2 - 8, width: 8, height: 8))
                    ctx.fill(head, with: .color(IVMaterialColors.sepiaInk.opacity(0.25)))
                    // Straps
                    for offset: CGFloat in [-12, 0, 12] {
                        var strap = Path()
                        strap.move(to: CGPoint(x: cx + offset, y: cy - frameH / 2))
                        strap.addLine(to: CGPoint(x: cx + offset, y: cy + frameH / 2))
                        ctx.stroke(strap, with: .color(Color(red: 0.55, green: 0.35, blue: 0.20).opacity(0.3)), lineWidth: 1)
                    }
                }
                // Step 2: force arrows
                if step >= 2 {
                    // Weight down
                    var down = Path()
                    down.move(to: CGPoint(x: cx, y: cy + frameH / 2 + 5))
                    down.addLine(to: CGPoint(x: cx, y: cy + frameH / 2 + 18))
                    ctx.stroke(down, with: .color(.red.opacity(0.4)), lineWidth: 1.5)
                    // Lift up
                    var up = Path()
                    up.move(to: CGPoint(x: cx, y: cy - frameH / 2 - 12))
                    up.addLine(to: CGPoint(x: cx, y: cy - frameH / 2 - 25))
                    ctx.stroke(up, with: .color(color.opacity(0.5)), lineWidth: 1.5)
                }
                // Step 3: iron brackets at corners
                if step >= 3 {
                    let corners: [CGPoint] = [
                        CGPoint(x: cx - frameW / 2, y: cy - frameH / 2),
                        CGPoint(x: cx + frameW / 2, y: cy - frameH / 2),
                        CGPoint(x: cx - frameW / 2, y: cy + frameH / 2),
                        CGPoint(x: cx + frameW / 2, y: cy + frameH / 2),
                    ]
                    for corner in corners {
                        let bracket = Path(ellipseIn: CGRect(x: corner.x - 3, y: corner.y - 3, width: 6, height: 6))
                        ctx.fill(bracket, with: .color(ironWire.opacity(0.6)))
                    }
                }
            }
        }
    }
}

// MARK: - 11. Silk Assembly

private struct SilkAssemblyVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    private let labels = ["Cut silk, soak in warm water to pre-shrink",
                          "Stretch over ribs, stitch with waxed linen thread",
                          "Dry = contracts drum-tight, seal with linseed oil. 3 days/wing"]
    private let stages = ["Cut", "Soak", "Stretch", "Stitch", "Dry", "Seal"]
    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            VStack(spacing: 10) {
                HStack(spacing: 3) {
                    ForEach(Array(stages.enumerated()), id: \.offset) { i, stage in
                        let active = (step == 1 && i < 2) || (step == 2 && i < 4) || step >= 3
                        Text(stage)
                            .font(.custom("EBGaramond-Regular", size: 15))
                            .foregroundStyle(active ? IVMaterialColors.sepiaInk : IVMaterialColors.sepiaInk.opacity(0.2))
                            .padding(.horizontal, 4).padding(.vertical, 3)
                            .background(RoundedRectangle(cornerRadius: 2).fill(active ? color.opacity(0.06) : Color.clear))
                        if i < stages.count - 1 {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 13))
                                .foregroundStyle(active ? IVMaterialColors.sepiaInk.opacity(0.2) : .clear)
                        }
                    }
                }

                if step >= 3 {
                    Text("3 days per wing")
                        .font(.custom("EBGaramond-Bold", size: 15))
                        .foregroundStyle(color)
                }
            }
            .padding(.horizontal, 4)
        }
    }
}
