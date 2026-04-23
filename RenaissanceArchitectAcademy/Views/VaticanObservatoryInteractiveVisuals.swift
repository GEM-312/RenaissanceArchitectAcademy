import SwiftUI

/// Interactive science visuals for Vatican Observatory knowledge cards (13 cards)
struct VaticanObservatoryInteractiveVisuals {

    @ViewBuilder
    static func view(for visual: CardVisual, color: Color, height: CGFloat = 275) -> some View {
        let h = height
        Group {
            switch visual.title {
            case let t where t.contains("Galileo"):
                GalileoVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Lens Grinding"):
                LensGrindingVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Meridian Line"):
                MeridianLineVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Pendulum"):
                PendulumVisual(visual: visual, color: color, height: h)
            case let t where t.contains("First Discovery"):
                JupiterMoonsVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Lead Dome"):
                LeadDomeVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Marble Floor"):
                MarbleFloorVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Pure Glass"):
                PureGlassVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Ultramarine Fresco"):
                UltramarineFrescoVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Telescope Tube"):
                TelescopeTubeVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Lead Tube"):
                LeadTubeVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Grind Ultramarine"):
                GrindUltramarineVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Star Charts"):
                StarChartsVisual(visual: visual, color: color, height: h)
            default:
                EmptyView()
            }
        }
    }

    static func hasInteractiveVisual(for visual: CardVisual) -> Bool {
        let t = visual.title
        return t.contains("Galileo") || t.contains("Lens Grinding") ||
               t.contains("Meridian Line") || t.contains("Pendulum") ||
               t.contains("First Discovery") || t.contains("Lead Dome") ||
               t.contains("Marble Floor") || t.contains("Pure Glass") ||
               t.contains("Ultramarine Fresco") || t.contains("Telescope Tube") ||
               t.contains("Lead Tube") || t.contains("Grind Ultramarine") ||
               t.contains("Star Charts")
    }
}

// MARK: - Local Colors

private let nightBlue = Color(red: 0.12, green: 0.15, blue: 0.35)
private let starGold = Color(red: 0.92, green: 0.82, blue: 0.45)
private let leadGray = Color(red: 0.55, green: 0.55, blue: 0.52)
private let ultraBlue = Color(red: 0.22, green: 0.30, blue: 0.68)
private let lensGlass = Color(red: 0.78, green: 0.85, blue: 0.90)
private let brassGold = Color(red: 0.80, green: 0.68, blue: 0.35)

private typealias TeachingContainer = IVTeachingContainer
private typealias DimLabel = IVDimLabel
private typealias FormulaText = IVFormulaText
private typealias DimLine = IVDimLine

// MARK: - 1. Galileo's Revolution
private struct GalileoVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    private let labels = ["1610: Galileo points telescope at Jupiter",
                          "Four moons orbiting Jupiter — not Earth",
                          "Church resisted, then built its own observatory"]
    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            Canvas { ctx, size in
                let cx = size.width / 2, cy = size.height * 0.38
                // Jupiter
                let jupR: CGFloat = 22
                let jup = Path(ellipseIn: CGRect(x: cx - jupR, y: cy - jupR, width: jupR * 2, height: jupR * 2))
                ctx.fill(jup, with: .color(Color(red: 0.78, green: 0.65, blue: 0.45).opacity(step >= 1 ? 0.5 : 0.15)))
                ctx.stroke(jup, with: .color(IVMaterialColors.sepiaInk.opacity(0.3)), lineWidth: 1)
                // Bands on Jupiter
                if step >= 1 {
                    for i in [-8, -3, 3, 8] as [CGFloat] {
                        var band = Path()
                        band.move(to: CGPoint(x: cx - jupR * 0.85, y: cy + i))
                        band.addLine(to: CGPoint(x: cx + jupR * 0.85, y: cy + i))
                        ctx.stroke(band, with: .color(IVMaterialColors.sepiaInk.opacity(0.1)), lineWidth: 0.5)
                    }
                }
                // Step 2: four moons
                if step >= 2 {
                    let moonPositions: [(CGFloat, String)] = [(-50, "Io"), (-35, "Eu"), (40, "Ga"), (55, "Ca")]
                    for (xOff, name) in moonPositions {
                        let mx = cx + xOff, my = cy
                        let moon = Path(ellipseIn: CGRect(x: mx - 3, y: my - 3, width: 6, height: 6))
                        ctx.fill(moon, with: .color(starGold.opacity(0.7)))
                        // Orbit hint
                        let orbit = Path(ellipseIn: CGRect(x: cx - abs(xOff), y: cy - abs(xOff) * 0.3,
                                                            width: abs(xOff) * 2, height: abs(xOff) * 0.6))
                        ctx.stroke(orbit, with: .color(IVMaterialColors.sepiaInk.opacity(0.08)),
                                   style: StrokeStyle(lineWidth: 0.5, dash: [2, 2]))
                    }
                }
                // Step 3: telescope on left
                if step >= 3 {
                    let telX: CGFloat = 15, telY = cy + 10
                    var tel = Path()
                    tel.move(to: CGPoint(x: telX, y: telY))
                    tel.addLine(to: CGPoint(x: telX + 35, y: telY - 8))
                    ctx.stroke(tel, with: .color(leadGray.opacity(0.5)), lineWidth: 3)
                    // Viewing line to Jupiter
                    var viewLine = Path()
                    viewLine.move(to: CGPoint(x: telX + 35, y: telY - 8))
                    viewLine.addLine(to: CGPoint(x: cx - jupR, y: cy))
                    ctx.stroke(viewLine, with: .color(color.opacity(0.15)),
                               style: StrokeStyle(lineWidth: 0.5, dash: [3, 3]))
                }
            }
        }
    }
}

// MARK: - 2-13: Remaining visuals (compact implementations)

private struct LensGrindingVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    private let labels = ["Convex objective + concave eyepiece = telescope",
                          "Parabolic grinding — spherical lenses distort edges",
                          "100 lenses ground, 2 worked. Optics = 98% rejection"]
    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            HStack(spacing: 20) {
                VStack(spacing: 4) {
                    Canvas { ctx, size in
                        let cx = size.width / 2, cy = size.height / 2, r = min(size.width, size.height) * 0.38
                        var lens = Path()
                        lens.addArc(center: CGPoint(x: cx - r * 0.3, y: cy), radius: r, startAngle: .degrees(-30), endAngle: .degrees(30), clockwise: false)
                        lens.addArc(center: CGPoint(x: cx + r * 0.3, y: cy), radius: r, startAngle: .degrees(150), endAngle: .degrees(210), clockwise: false)
                        ctx.fill(lens, with: .color(lensGlass.opacity(step >= 1 ? 0.4 : 0.1)))
                        ctx.stroke(lens, with: .color(color.opacity(0.4)), lineWidth: 1)
                    }.frame(width: 50, height: 40)
                    Text("Convex").font(.custom("Cinzel-Bold", size: 16)).foregroundStyle(step >= 1 ? IVMaterialColors.sepiaInk : IVMaterialColors.sepiaInk.opacity(0.3))
                }
                VStack(spacing: 4) {
                    Canvas { ctx, size in
                        let cx = size.width / 2, cy = size.height / 2, r = min(size.width, size.height) * 0.5
                        var lens = Path()
                        lens.addArc(center: CGPoint(x: cx + r * 0.5, y: cy), radius: r, startAngle: .degrees(150), endAngle: .degrees(210), clockwise: false)
                        lens.addArc(center: CGPoint(x: cx - r * 0.5, y: cy), radius: r, startAngle: .degrees(-30), endAngle: .degrees(30), clockwise: false)
                        ctx.fill(lens, with: .color(lensGlass.opacity(step >= 1 ? 0.3 : 0.1)))
                        ctx.stroke(lens, with: .color(color.opacity(0.4)), lineWidth: 1)
                    }.frame(width: 50, height: 40)
                    Text("Concave").font(.custom("Cinzel-Bold", size: 16)).foregroundStyle(step >= 1 ? IVMaterialColors.sepiaInk : IVMaterialColors.sepiaInk.opacity(0.3))
                }
            }
            if step >= 3 {
                Text("100 → 2 (98% rejected)")
                    .font(RenaissanceFont.ivFormula)
                    .foregroundStyle(color)
            }
        }
    }
}

private struct MeridianLineVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    private let labels = ["Brass strip on marble floor, running exactly north-south",
                          "Sunlight through roof hole projects a dot onto the line",
                          "Dot position = time of day + season + Earth's 23.5° tilt"]
    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            Canvas { ctx, size in
                let cx = size.width / 2
                // Floor
                let floorY = size.height * 0.3, floorH = size.height * 0.45
                let floor = CGRect(x: 15, y: floorY, width: size.width - 30, height: floorH)
                ctx.fill(Path(floor), with: .color(IVMaterialColors.marbleWhite.opacity(0.3)))
                // Brass line N-S
                var line = Path()
                line.move(to: CGPoint(x: cx, y: floorY))
                line.addLine(to: CGPoint(x: cx, y: floorY + floorH))
                ctx.stroke(line, with: .color(brassGold.opacity(step >= 1 ? 0.7 : 0.2)), lineWidth: 2)
                // Step 2: sun dot
                if step >= 2 {
                    let dotY = floorY + floorH * 0.4
                    let dot = Path(ellipseIn: CGRect(x: cx - 5, y: dotY - 5, width: 10, height: 10))
                    ctx.fill(dot, with: .color(starGold.opacity(0.7)))
                    // Light beam from roof
                    var beam = Path()
                    beam.move(to: CGPoint(x: cx + 15, y: floorY - 20))
                    beam.addLine(to: CGPoint(x: cx, y: dotY))
                    ctx.stroke(beam, with: .color(starGold.opacity(0.2)), lineWidth: 1)
                    // Hole in roof
                    let hole = Path(ellipseIn: CGRect(x: cx + 12, y: floorY - 24, width: 8, height: 8))
                    ctx.fill(hole, with: .color(starGold.opacity(0.3)))
                }
                // Step 3: season markers
                if step >= 3 {
                    let markers: [(CGFloat, String)] = [(0.2, "S"), (0.5, "E"), (0.8, "W")]
                    for (t, label) in markers {
                        let my = floorY + floorH * t
                        var tick = Path()
                        tick.move(to: CGPoint(x: cx - 6, y: my))
                        tick.addLine(to: CGPoint(x: cx + 6, y: my))
                        ctx.stroke(tick, with: .color(brassGold.opacity(0.4)), lineWidth: 0.5)
                    }
                }
            }
        }
    }
}

private struct PendulumVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    private let labels = ["Pendulum swing depends ONLY on length — not weight or arc",
                          "1-meter pendulum = 1 second per swing",
                          "Huygens built first pendulum clock (1656) — enabled astronomy"]
    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            Canvas { ctx, size in
                let cx = size.width / 2, pivotY = size.height * 0.08
                let stringL = size.height * 0.45
                // Pivot point
                let pivot = Path(ellipseIn: CGRect(x: cx - 3, y: pivotY - 3, width: 6, height: 6))
                ctx.fill(pivot, with: .color(IVMaterialColors.sepiaInk.opacity(0.4)))
                // String + weight
                let weightY = pivotY + stringL
                var string = Path()
                string.move(to: CGPoint(x: cx, y: pivotY))
                string.addLine(to: CGPoint(x: cx, y: weightY))
                ctx.stroke(string, with: .color(IVMaterialColors.sepiaInk.opacity(0.4)), lineWidth: 1)
                let weight = Path(ellipseIn: CGRect(x: cx - 8, y: weightY - 4, width: 16, height: 16))
                ctx.fill(weight, with: .color(color.opacity(step >= 1 ? 0.4 : 0.15)))
                ctx.stroke(weight, with: .color(IVMaterialColors.sepiaInk.opacity(0.3)), lineWidth: 1)
                // Swing arc
                if step >= 1 {
                    var arc = Path()
                    arc.addArc(center: CGPoint(x: cx, y: pivotY), radius: stringL + 8,
                               startAngle: .degrees(75), endAngle: .degrees(105), clockwise: false)
                    ctx.stroke(arc, with: .color(color.opacity(0.2)), style: StrokeStyle(lineWidth: 1, dash: [3, 2]))
                }
                // Step 2: dimension
                if step >= 2 {
                    let dimX = cx + 25
                    ctx.stroke(IVDimLine(from: CGPoint(x: dimX, y: pivotY), to: CGPoint(x: dimX, y: weightY)).path(in: .zero),
                               with: .color(IVMaterialColors.dimColor), lineWidth: 0.5)
                }
            }
            .overlay(alignment: .bottom) {
                if step >= 2 {
                    Text("1m = 1 second")
                        .font(RenaissanceFont.ivFormula)
                        .foregroundStyle(color)
                        .offset(y: -28)
                }
            }
        }
    }
}

private struct JupiterMoonsVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    private let labels = ["4 Galilean moons: Io, Europa, Ganymede, Callisto",
                          "Orbits proved moons orbit PLANETS, not just Earth",
                          "Nightly tracking — first systematic orbital data"]
    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            VStack(spacing: 6) {
                HStack(spacing: 12) {
                    ForEach(["Io", "Europa", "Ganymede", "Callisto"], id: \.self) { name in
                        let active = step >= 1
                        VStack(spacing: 2) {
                            Circle()
                                .fill(starGold.opacity(active ? 0.6 : 0.15))
                                .frame(width: name == "Ganymede" ? 16 : 12, height: name == "Ganymede" ? 16 : 12)
                            Text(name)
                                .font(RenaissanceFont.ivBody)
                                .foregroundStyle(active ? IVMaterialColors.sepiaInk : IVMaterialColors.sepiaInk.opacity(0.3))
                        }
                    }
                }
                if step >= 2 {
                    Text("Moons orbit Jupiter → not everything orbits Earth")
                        .font(RenaissanceFont.ivBody)
                        .foregroundStyle(color.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                if step >= 3 {
                    Text("Systematic data defeated dogma")
                        .font(RenaissanceFont.ivFormula)
                        .foregroundStyle(color)
                }
            }
        }
    }
}

private struct LeadDomeVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    private let labels = ["Lead sheeting: malleable, waterproof, expands without cracking",
                          "Sheets overlap 5 cm, sealed with molten lead solder",
                          "Lead's weight (11.3 g/cm³) provides smooth rotational momentum"]
    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            Canvas { ctx, size in
                let cx = size.width / 2, baseY = size.height * 0.65
                var dome = Path()
                dome.move(to: CGPoint(x: cx - 50, y: baseY))
                dome.addQuadCurve(to: CGPoint(x: cx + 50, y: baseY), control: CGPoint(x: cx, y: baseY - 55))
                ctx.fill(dome, with: .color(leadGray.opacity(step >= 1 ? 0.3 : 0.1)))
                ctx.stroke(dome, with: .color(IVMaterialColors.sepiaInk.opacity(0.4)), lineWidth: 1.5)
                // Sheet overlap lines
                if step >= 2 {
                    for i in 1..<5 {
                        let t = CGFloat(i) / 5
                        let lx = cx - 45 + t * 90
                        var sheetLine = Path()
                        sheetLine.move(to: CGPoint(x: lx, y: baseY - 5))
                        sheetLine.addQuadCurve(to: CGPoint(x: lx + 3, y: baseY - 50 + t * 20),
                                               control: CGPoint(x: lx + 2, y: baseY - 30))
                        ctx.stroke(sheetLine, with: .color(IVMaterialColors.sepiaInk.opacity(0.15)), lineWidth: 0.5)
                    }
                }
                // Step 3: rotation arrow
                if step >= 3 {
                    var arc = Path()
                    arc.addArc(center: CGPoint(x: cx, y: baseY + 5), radius: 55,
                               startAngle: .degrees(-160), endAngle: .degrees(-20), clockwise: false)
                    ctx.stroke(arc, with: .color(color.opacity(0.3)), style: StrokeStyle(lineWidth: 1.5, dash: [4, 3]))
                }
            }
        }
    }
}

private struct MarbleFloorVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    private let labels = ["Carrara marble planed to 0.5 mm tolerance",
                          "Brass inlaid in 2 mm groove — meridian line",
                          "Marble expands just 0.006 mm/°C/m — floor is an instrument"]
    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            VStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(IVMaterialColors.marbleWhite.opacity(step >= 1 ? 0.6 : 0.2))
                    .frame(height: 35)
                    .overlay {
                        if step >= 2 {
                            Rectangle().fill(brassGold.opacity(0.6)).frame(width: 2)
                        }
                    }
                    .overlay(RoundedRectangle(cornerRadius: 4).strokeBorder(IVMaterialColors.sepiaInk.opacity(0.2), lineWidth: 0.5))
                    .padding(.horizontal, 20)
                if step >= 1 { Text("± 0.5 mm").font(RenaissanceFont.ivFormula).foregroundStyle(IVMaterialColors.dimColor) }
                if step >= 3 { Text("0.006 mm/°C/m expansion").font(RenaissanceFont.ivFormula).foregroundStyle(color) }
            }
        }
    }
}

private struct PureGlassVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    private let labels = ["Triple-filtered cristallo — purest glass for lenses",
                          "Stirred 24 hours at 1,100°C, cooled 5 days",
                          "10 kg batch → 200g usable. 2% yield"]
    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            VStack(spacing: 8) {
                Circle().fill(lensGlass.opacity(step >= 1 ? 0.4 : 0.1)).frame(width: 50, height: 50)
                    .overlay(Circle().strokeBorder(color.opacity(0.3), lineWidth: 1))
                if step >= 2 { Text("24h stir · 5-day cool").font(RenaissanceFont.ivBody).foregroundStyle(IVMaterialColors.dimColor) }
                if step >= 3 { Text("2% yield").font(RenaissanceFont.ivFormula).foregroundStyle(color) }
            }
        }
    }
}

private struct UltramarineFrescoVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    private let labels = ["Lapis lazuli from Afghanistan (Sar-i Sang, 6,000 km)",
                          "Costlier per gram than gold",
                          "Observatory ceilings painted to represent the night sky"]
    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            VStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(ultraBlue.opacity(step >= 1 ? 0.4 : 0.1))
                    .frame(height: 50)
                    .overlay {
                        if step >= 3 {
                            ForEach(0..<6, id: \.self) { i in
                                Circle().fill(starGold.opacity(0.5))
                                    .frame(width: 3, height: 3)
                                    .offset(x: CGFloat.random(in: -50...50), y: CGFloat.random(in: -15...15))
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                if step >= 1 { Text("Lapis Lazuli").font(.custom("Cinzel-Bold", size: 16)).foregroundStyle(ultraBlue) }
                if step >= 2 { Text("6,000 km · costlier than gold").font(RenaissanceFont.ivFormula).foregroundStyle(IVMaterialColors.dimColor) }
            }
        }
    }
}

private struct TelescopeTubeVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    private let labels = ["Two lenses in a lead tube — simple but precise",
                          "20× magnification. Alignment within 0.1 mm",
                          "Leather shims for precise lens fit"]
    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            Canvas { ctx, size in
                let cx = size.width / 2, cy = size.height * 0.38
                let tubeW = size.width * 0.7, tubeH: CGFloat = 14
                let tube = CGRect(x: cx - tubeW / 2, y: cy - tubeH / 2, width: tubeW, height: tubeH)
                ctx.fill(Path(roundedRect: tube, cornerRadius: 2), with: .color(leadGray.opacity(step >= 1 ? 0.4 : 0.15)))
                ctx.stroke(Path(roundedRect: tube, cornerRadius: 2), with: .color(IVMaterialColors.sepiaInk.opacity(0.3)), lineWidth: 1)
                // Objective lens (left)
                if step >= 1 {
                    let lx = cx - tubeW / 2 + 5
                    let lens = Path(ellipseIn: CGRect(x: lx - 2, y: cy - 8, width: 4, height: 16))
                    ctx.fill(lens, with: .color(lensGlass.opacity(0.5)))
                }
                // Eyepiece (right)
                if step >= 1 {
                    let rx = cx + tubeW / 2 - 5
                    let lens = Path(ellipseIn: CGRect(x: rx - 2, y: cy - 6, width: 4, height: 12))
                    ctx.fill(lens, with: .color(lensGlass.opacity(0.5)))
                }
                if step >= 2 {
                    let magRect = CGRect(x: cx - 15, y: cy + tubeH / 2 + 8, width: 30, height: 14)
                    ctx.fill(Path(roundedRect: magRect, cornerRadius: 2), with: .color(color.opacity(0.08)))
                }
            }
            .overlay(alignment: .bottom) {
                if step >= 2 {
                    Text("20×").font(RenaissanceFont.ivFormula).foregroundStyle(color).offset(y: -28)
                }
            }
        }
    }
}

private struct LeadTubeVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    private let labels = ["Lead melts at 327°C — poured around wooden mandrel",
                          "Cool 15 min, remove mandrel, ream interior smooth",
                          "Must be perfectly cylindrical — oval misaligns lenses"]
    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            VStack(spacing: 8) {
                HStack(spacing: 12) {
                    VStack(spacing: 2) {
                        RoundedRectangle(cornerRadius: 3).fill(Color(red: 0.55, green: 0.42, blue: 0.28).opacity(0.4))
                            .frame(width: 40, height: 12)
                        Text("Mandrel").font(.custom("Cinzel-Bold", size: 16)).foregroundStyle(step >= 1 ? IVMaterialColors.sepiaInk : IVMaterialColors.sepiaInk.opacity(0.3))
                    }
                    if step >= 2 {
                        Image(systemName: "arrow.right").font(.system(size: 13)).foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.3))
                        VStack(spacing: 2) {
                            RoundedRectangle(cornerRadius: 3).fill(leadGray.opacity(0.5)).frame(width: 45, height: 14)
                                .overlay(RoundedRectangle(cornerRadius: 2).fill(Color.clear).frame(width: 36, height: 8)
                                    .overlay(RoundedRectangle(cornerRadius: 1).strokeBorder(IVMaterialColors.sepiaInk.opacity(0.15), lineWidth: 0.5)))
                            Text("Lead tube").font(.custom("Cinzel-Bold", size: 16)).foregroundStyle(IVMaterialColors.sepiaInk)
                        }
                    }
                }
                if step >= 1 { Text("327°C").font(RenaissanceFont.ivFormula).foregroundStyle(IVMaterialColors.dimColor) }
                if step >= 3 { Text("Perfectly cylindrical").font(RenaissanceFont.ivFormula).foregroundStyle(color) }
            }
        }
    }
}

private struct GrindUltramarineVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    private let labels = ["Crush lapis + mix with pine resin, wax, lye",
                          "Knead 3 weeks — blue lazurite migrates into lye",
                          "3 extractions: deep blue → pale → grey"]
    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    Circle().fill(ultraBlue.opacity(step >= 3 ? 0.7 : step >= 1 ? 0.4 : 0.1)).frame(width: 30, height: 30)
                        .overlay { Text("1st").font(RenaissanceFont.ivBody).foregroundStyle(.white.opacity(step >= 3 ? 0.7 : 0)) }
                    if step >= 3 {
                        Circle().fill(ultraBlue.opacity(0.3)).frame(width: 25, height: 25)
                            .overlay { Text("2nd").font(RenaissanceFont.ivBody).foregroundStyle(.white.opacity(0.6)) }
                        Circle().fill(Color.gray.opacity(0.3)).frame(width: 20, height: 20)
                            .overlay { Text("3rd").font(RenaissanceFont.ivBody).foregroundStyle(.white.opacity(0.5)) }
                    }
                }
                if step >= 2 { Text("3 weeks kneading").font(RenaissanceFont.ivFormula).foregroundStyle(IVMaterialColors.dimColor) }
                if step >= 3 { Text("Deep → Pale → Grey").font(RenaissanceFont.ivFormula).foregroundStyle(color) }
            }
        }
    }
}

private struct StarChartsVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    private let labels = ["Right ascension (hours, E-W) + declination (degrees, N-S)",
                          "Tycho Brahe: 1,000 stars, accurate to 1 arcminute",
                          "The notebook is the real instrument"]
    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            Canvas { ctx, size in
                let cx = size.width / 2, cy = size.height * 0.4, r = min(size.width, size.height) * 0.3
                // Celestial sphere outline
                let sphere = Path(ellipseIn: CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2))
                ctx.stroke(sphere, with: .color(nightBlue.opacity(step >= 1 ? 0.3 : 0.1)), lineWidth: 1)
                // Grid lines (RA + Dec)
                if step >= 1 {
                    // Horizontal (declination)
                    for i in [-1, 0, 1] as [CGFloat] {
                        var dec = Path()
                        dec.addEllipse(in: CGRect(x: cx - r, y: cy + i * r * 0.4 - 3, width: r * 2, height: 6))
                        ctx.stroke(dec, with: .color(nightBlue.opacity(0.1)), lineWidth: 0.5)
                    }
                    // Vertical (right ascension)
                    for i in 0..<4 {
                        let a = CGFloat(i) * .pi / 2
                        var ra = Path()
                        ra.move(to: CGPoint(x: cx + cos(a) * r, y: cy + sin(a) * r))
                        ra.addLine(to: CGPoint(x: cx - cos(a) * r, y: cy - sin(a) * r))
                        ctx.stroke(ra, with: .color(nightBlue.opacity(0.1)), lineWidth: 0.5)
                    }
                }
                // Stars
                if step >= 2 {
                    let stars: [CGPoint] = [
                        CGPoint(x: cx - 15, y: cy - 10), CGPoint(x: cx + 20, y: cy + 5),
                        CGPoint(x: cx - 8, y: cy + 15), CGPoint(x: cx + 12, y: cy - 18),
                        CGPoint(x: cx - 20, y: cy + 8), CGPoint(x: cx + 5, y: cy - 5),
                    ]
                    for s in stars {
                        let star = Path(ellipseIn: CGRect(x: s.x - 2, y: s.y - 2, width: 4, height: 4))
                        ctx.fill(star, with: .color(starGold.opacity(0.6)))
                    }
                }
            }
            .overlay(alignment: .bottom) {
                if step >= 3 {
                    Text("1,000 stars · 1 arcminute")
                        .font(RenaissanceFont.ivFormula)
                        .foregroundStyle(color)
                        .offset(y: -28)
                }
            }
        }
    }
}
