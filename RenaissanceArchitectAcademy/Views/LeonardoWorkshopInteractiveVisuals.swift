import SwiftUI

/// Interactive science visuals for Leonardo's Workshop knowledge cards (13 cards)
struct LeonardoWorkshopInteractiveVisuals {

    @ViewBuilder
    static func view(for visual: CardVisual, color: Color, height: CGFloat = 275) -> some View {
        let h = height
        Group {
            switch visual.title {
            case let t where t.contains("Bottega System"):
                BottegaVisual(visual: visual, color: color, height: h)
            case let t where t.contains("North Light"):
                NorthLightVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Sfumato"):
                SfumatoVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Water Tank"):
                WaterTankVisual(visual: visual, color: color, height: h)
            case let t where t.contains("The Forge"):
                ForgeVisual(visual: visual, color: color, height: h)
            case let t where t.contains("White Walls"):
                WhiteWallsVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Bronze Gears"):
                BronzeGearsVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Casting Sand"):
                CastingSandVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Custom Tools"):
                CustomToolsVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Drawing Tables"):
                DrawingTableVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Poplar Panels"):
                PoplarPanelVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Pigment Grinding"):
                PigmentGrindVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Bronze Casting"):
                LostWaxVisual(visual: visual, color: color, height: h)
            default:
                EmptyView()
            }
        }
    }

    static func hasInteractiveVisual(for visual: CardVisual) -> Bool {
        let t = visual.title
        return t.contains("Bottega System") || t.contains("North Light") ||
               t.contains("Sfumato") || t.contains("Water Tank") ||
               t.contains("The Forge") || t.contains("White Walls") ||
               t.contains("Bronze Gears") || t.contains("Casting Sand") ||
               t.contains("Custom Tools") || t.contains("Drawing Tables") ||
               t.contains("Poplar Panels") || t.contains("Pigment Grinding") ||
               t.contains("Bronze Casting")
    }
}

// MARK: - Local Colors

private let forgeOrange = Color(red: 0.90, green: 0.50, blue: 0.15)
private let ultraBlue = Color(red: 0.22, green: 0.28, blue: 0.65)
private let ochreYellow = Color(red: 0.78, green: 0.62, blue: 0.28)
private let limeWhite = Color(red: 0.94, green: 0.92, blue: 0.88)
private let poplarLight = Color(red: 0.82, green: 0.75, blue: 0.62)

private typealias TeachingContainer = IVTeachingContainer
private typealias DimLabel = IVDimLabel
private typealias FormulaText = IVFormulaText
private typealias DimLine = IVDimLine

// MARK: - 1. Bottega System

private struct BottegaVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    private let labels = ["Bottega: master + apprentices live and work together",
                          "Age 12 → grind pigments. Age 16 → assist. Age 20 → commission",
                          "Leonardo's Milan workshop: 6 apprentices, 3 disciplines"]
    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            VStack(spacing: 8) {
                // Master + apprentices
                HStack(spacing: 12) {
                    VStack(spacing: 2) {
                        Circle().fill(color.opacity(0.5)).frame(width: 18, height: 18)
                        Text("Master").font(RenaissanceFont.visualTitle).foregroundStyle(color)
                    }
                    ForEach(0..<(step >= 3 ? 6 : step >= 1 ? 3 : 0), id: \.self) { _ in
                        Circle().fill(IVMaterialColors.sepiaInk.opacity(0.25)).frame(width: 12, height: 12)
                    }
                }
                if step >= 2 {
                    HStack(spacing: 16) {
                        ageLabel("12", task: "Grind")
                        ageLabel("16", task: "Assist")
                        ageLabel("20", task: "Commission")
                    }
                }
                if step >= 3 {
                    HStack(spacing: 8) {
                        disciplinePill("Painting", icon: "paintbrush.fill")
                        disciplinePill("Engineering", icon: "gearshape.fill")
                        disciplinePill("Anatomy", icon: "figure.stand")
                    }
                }
            }
        }
    }
    @ViewBuilder private func ageLabel(_ age: String, task: String) -> some View {
        VStack(spacing: 1) {
            Text(age).font(RenaissanceFont.ivFormula).foregroundStyle(IVMaterialColors.dimColor)
            Text(task).font(RenaissanceFont.ivBody).foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.6))
        }
    }
    @ViewBuilder private func disciplinePill(_ text: String, icon: String) -> some View {
        Label(text, systemImage: icon)
            .font(RenaissanceFont.ivBody)
            .foregroundStyle(color.opacity(0.7))
            .padding(.horizontal, 6).padding(.vertical, 3)
            .background(RoundedRectangle(cornerRadius: 3).fill(color.opacity(0.06)))
    }
}

// MARK: - 2. North Light

private struct NorthLightVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    private let labels = ["North-facing windows: indirect skylight all day",
                          "No moving shadows — consistent, cool light",
                          "True form revealed without harsh highlights"]
    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            Canvas { ctx, size in
                let cx = size.width / 2, roomY = size.height * 0.2
                let roomW = size.width * 0.6, roomH = size.height * 0.5
                let room = CGRect(x: cx - roomW / 2, y: roomY, width: roomW, height: roomH)
                ctx.stroke(Path(room), with: .color(IVMaterialColors.sepiaInk.opacity(0.2)), lineWidth: 1)
                // Window on top (north)
                let winW: CGFloat = 30
                let winRect = CGRect(x: cx - winW / 2, y: roomY - 3, width: winW, height: 6)
                ctx.fill(Path(winRect), with: .color(step >= 1 ? RenaissanceColors.renaissanceBlue.opacity(0.2) : IVMaterialColors.sepiaInk.opacity(0.05)))
                ctx.stroke(Path(winRect), with: .color(IVMaterialColors.sepiaInk.opacity(0.3)), lineWidth: 1)
                // Light rays spreading down
                if step >= 1 {
                    for i in 0..<5 {
                        let spread = CGFloat(i - 2) * 15
                        var ray = Path()
                        ray.move(to: CGPoint(x: cx, y: roomY + 3))
                        ray.addLine(to: CGPoint(x: cx + spread, y: roomY + roomH * 0.7))
                        ctx.stroke(ray, with: .color(RenaissanceColors.candleGlow.opacity(0.1)), lineWidth: 1)
                    }
                }
                // Step 2: easel in room (no shadows)
                if step >= 2 {
                    let easelX = cx, easelY = roomY + roomH * 0.5
                    var easel = Path()
                    easel.move(to: CGPoint(x: easelX - 8, y: easelY + 20))
                    easel.addLine(to: CGPoint(x: easelX, y: easelY - 10))
                    easel.addLine(to: CGPoint(x: easelX + 8, y: easelY + 20))
                    ctx.stroke(easel, with: .color(IVMaterialColors.oakBrown.opacity(0.4)), lineWidth: 1.5)
                    let canvas = CGRect(x: easelX - 8, y: easelY - 10, width: 16, height: 14)
                    ctx.fill(Path(canvas), with: .color(limeWhite.opacity(0.5)))
                    ctx.stroke(Path(canvas), with: .color(IVMaterialColors.sepiaInk.opacity(0.2)), lineWidth: 0.5)
                }
                // Step 3: "N" compass at top
                if step >= 3 {
                    let nY = roomY - 15
                    var arrow = Path()
                    arrow.move(to: CGPoint(x: cx, y: nY + 6))
                    arrow.addLine(to: CGPoint(x: cx, y: nY - 6))
                    arrow.move(to: CGPoint(x: cx, y: nY - 6))
                    arrow.addLine(to: CGPoint(x: cx - 3, y: nY - 2))
                    arrow.move(to: CGPoint(x: cx, y: nY - 6))
                    arrow.addLine(to: CGPoint(x: cx + 3, y: nY - 2))
                    ctx.stroke(arrow, with: .color(color), lineWidth: 1.5)
                }
            }
        }
    }
}

// MARK: - 3. Sfumato Layers

private struct SfumatoVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    private let labels = ["20-30 translucent oil layers, barely tinted",
                          "Applied with fingertips — edges vanish like smoke",
                          "Peripheral vision sees what direct gaze misses"]
    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            Canvas { ctx, size in
                let cx = size.width / 2, cy = size.height * 0.4
                let layerCount = step >= 1 ? (step >= 2 ? 8 : 4) : 0
                // Stacked translucent circles (sfumato layers)
                for i in 0..<layerCount {
                    let t = CGFloat(i) / CGFloat(max(layerCount - 1, 1))
                    let r: CGFloat = 30 + t * 15
                    let alpha: CGFloat = 0.06 + t * 0.04
                    let offset = CGFloat(i) * 1.5
                    let circle = Path(ellipseIn: CGRect(x: cx - r + offset, y: cy - r * 0.8 + offset * 0.5,
                                                         width: r * 2, height: r * 1.6))
                    let layerColor = Color(red: 0.85 - t * 0.15, green: 0.75 - t * 0.1, blue: 0.65 - t * 0.05)
                    ctx.fill(circle, with: .color(layerColor.opacity(alpha)))
                }
                // Step 2: soft edge demonstration
                if step >= 2 {
                    // Hard edge (left)
                    let hardRect = CGRect(x: 20, y: cy + 30, width: 30, height: 20)
                    ctx.fill(Path(hardRect), with: .color(IVMaterialColors.sepiaInk.opacity(0.3)))
                    // Soft edge (right) — gradient simulation
                    for j in 0..<10 {
                        let t = CGFloat(j) / 9
                        let softRect = CGRect(x: size.width - 55 + t * 30, y: cy + 30, width: 4, height: 20)
                        ctx.fill(Path(softRect), with: .color(IVMaterialColors.sepiaInk.opacity(0.3 * (1 - t))))
                    }
                }
                // Step 3: eye icon
                if step >= 3 {
                    let eyeY = cy + 60
                    var eye = Path()
                    eye.move(to: CGPoint(x: cx - 15, y: eyeY))
                    eye.addQuadCurve(to: CGPoint(x: cx + 15, y: eyeY), control: CGPoint(x: cx, y: eyeY - 8))
                    eye.addQuadCurve(to: CGPoint(x: cx - 15, y: eyeY), control: CGPoint(x: cx, y: eyeY + 8))
                    ctx.stroke(eye, with: .color(color.opacity(0.5)), lineWidth: 1)
                    let pupil = Path(ellipseIn: CGRect(x: cx - 3, y: eyeY - 3, width: 6, height: 6))
                    ctx.fill(pupil, with: .color(color.opacity(0.4)))
                }
            }
        }
    }
}

// MARK: - 4. Water Tank — Vortex Studies

private struct WaterTankVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    private let labels = ["Glass water tanks built for observing fluid dynamics",
                          "Dye dropped in water reveals vortex patterns",
                          "730 drawings of turbulence, eddies, and waves"]
    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            Canvas { ctx, size in
                let cx = size.width / 2, tankY = size.height * 0.15
                let tankW = size.width * 0.6, tankH = size.height * 0.5
                // Tank
                let tank = CGRect(x: cx - tankW / 2, y: tankY, width: tankW, height: tankH)
                ctx.fill(Path(tank), with: .color(IVMaterialColors.waterBlue.opacity(0.06)))
                ctx.stroke(Path(tank), with: .color(IVMaterialColors.waterBlue.opacity(0.3)), lineWidth: 1.5)
                // Step 2: vortex spirals
                if step >= 2 {
                    let vortices: [(CGPoint, CGFloat)] = [
                        (CGPoint(x: cx - 20, y: tankY + tankH * 0.4), 15),
                        (CGPoint(x: cx + 25, y: tankY + tankH * 0.6), 12),
                        (CGPoint(x: cx - 5, y: tankY + tankH * 0.3), 10),
                    ]
                    for (center, r) in vortices {
                        var spiral = Path()
                        for i in 0..<20 {
                            let t = CGFloat(i) / 19
                            let angle = t * .pi * 4
                            let radius = r * (1 - t * 0.7)
                            let pt = CGPoint(x: center.x + cos(angle) * radius,
                                             y: center.y + sin(angle) * radius)
                            if i == 0 { spiral.move(to: pt) } else { spiral.addLine(to: pt) }
                        }
                        ctx.stroke(spiral, with: .color(color.opacity(0.3)), lineWidth: 0.8)
                    }
                }
                // Step 3: counter
                if step >= 3 {
                    let counterY = tankY + tankH + 10
                    let counterRect = CGRect(x: cx - 30, y: counterY, width: 60, height: 16)
                    ctx.fill(Path(roundedRect: counterRect, cornerRadius: 3), with: .color(color.opacity(0.08)))
                }
            }
            .overlay(alignment: .bottom) {
                if step >= 3 {
                    Text("730 drawings")
                        .font(RenaissanceFont.ivFormula)
                        .foregroundStyle(color)
                        .offset(y: -28)
                }
            }
        }
    }
}

// MARK: - 5. The Forge — Double Bellows

private struct ForgeVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    private let labels = ["Workshop forge: bronze casting, mechanisms, alloy experiments",
                          "Double bellows: two chambers alternate for continuous air",
                          "No puffs — steady heat doubles temperature consistency"]
    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            Canvas { ctx, size in
                let cx = size.width / 2, forgeY = size.height * 0.25
                // Forge body
                let forgeRect = CGRect(x: cx - 25, y: forgeY, width: 50, height: 35)
                ctx.fill(Path(roundedRect: forgeRect, cornerRadius: 4), with: .color(forgeOrange.opacity(step >= 1 ? 0.4 : 0.1)))
                ctx.stroke(Path(roundedRect: forgeRect, cornerRadius: 4), with: .color(IVMaterialColors.sepiaInk.opacity(0.3)), lineWidth: 1)
                // Flame
                if step >= 1 {
                    var flame = Path()
                    flame.move(to: CGPoint(x: cx - 8, y: forgeY))
                    flame.addQuadCurve(to: CGPoint(x: cx + 8, y: forgeY), control: CGPoint(x: cx, y: forgeY - 15))
                    ctx.fill(flame, with: .color(forgeOrange.opacity(0.5)))
                }
                // Step 2: double bellows
                if step >= 2 {
                    let bY = forgeY + 15
                    for (i, side) in [CGFloat(-1), CGFloat(1)].enumerated() {
                        let bx = cx + side * 50
                        let compressed = i == 0 // one compressed, one expanded
                        let bw: CGFloat = compressed ? 15 : 22
                        let bellows = CGRect(x: bx - bw / 2, y: bY - 10, width: bw, height: 20)
                        ctx.fill(Path(roundedRect: bellows, cornerRadius: 2), with: .color(IVMaterialColors.oakBrown.opacity(0.3)))
                        ctx.stroke(Path(roundedRect: bellows, cornerRadius: 2), with: .color(IVMaterialColors.sepiaInk.opacity(0.3)), lineWidth: 0.5)
                        // Air pipe to forge
                        var pipe = Path()
                        pipe.move(to: CGPoint(x: bx - side * bw / 2, y: bY))
                        pipe.addLine(to: CGPoint(x: cx + side * 25, y: bY))
                        ctx.stroke(pipe, with: .color(IVMaterialColors.sepiaInk.opacity(0.2)), lineWidth: 1)
                    }
                }
                // Step 3: continuous air arrow
                if step >= 3 {
                    let airY = forgeY + 45
                    // Steady line (not puffs)
                    var steady = Path()
                    steady.move(to: CGPoint(x: cx - 40, y: airY))
                    steady.addLine(to: CGPoint(x: cx + 40, y: airY))
                    ctx.stroke(steady, with: .color(color), lineWidth: 2)
                }
            }
        }
    }
}

// MARK: - 6. White Walls — 85% Reflection

private struct WhiteWallsVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    private let labels = ["Lime plaster: 3 coats — scratch, brown, polished finish",
                          "Reflects 85% of light (vs 40% for bare stone)",
                          "North light + white walls = bright studio without candles"]
    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            HStack(spacing: 16) {
                // Bare stone
                VStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(red: 0.55, green: 0.52, blue: 0.48).opacity(0.5))
                        .frame(width: 55, height: 50)
                    Text("Stone")
                        .font(RenaissanceFont.visualTitle)
                        .foregroundStyle(IVMaterialColors.sepiaInk.opacity(step >= 2 ? 0.4 : 0.3))
                    if step >= 2 {
                        Text("40%")
                            .font(RenaissanceFont.ivFormula)
                            .foregroundStyle(IVMaterialColors.dimColor.opacity(0.5))
                    }
                }
                if step >= 2 {
                    Text("vs")
                        .font(RenaissanceFont.ivBody)
                        .foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.3))
                }
                // Lime plaster
                VStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(limeWhite.opacity(step >= 1 ? 0.9 : 0.3))
                        .frame(width: 55, height: 50)
                        .shadow(color: step >= 3 ? RenaissanceColors.candleGlow.opacity(0.15) : .clear, radius: 8)
                    Text("Lime")
                        .font(RenaissanceFont.visualTitle)
                        .foregroundStyle(step >= 1 ? IVMaterialColors.sepiaInk : IVMaterialColors.sepiaInk.opacity(0.3))
                    if step >= 2 {
                        Text("85%")
                            .font(RenaissanceFont.ivFormula)
                            .foregroundStyle(color)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - 7. Bronze Gears — Involute Profile

private struct BronzeGearsVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    private let labels = ["200+ gear mechanisms in Leonardo's notebooks",
                          "Involute tooth profile: curves mesh smoothly at any angle",
                          "Worm gears, cam systems, compound gear trains"]
    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            Canvas { ctx, size in
                let cx = size.width / 2, cy = size.height * 0.38
                // Large gear
                let gearR: CGFloat = 28
                drawGear(ctx: &ctx, center: CGPoint(x: cx - 18, y: cy), radius: gearR, teeth: 10,
                         color: step >= 1 ? IVMaterialColors.bronzeGold : RenaissanceColors.stoneGray.opacity(0.1))
                // Small meshing gear
                if step >= 2 {
                    drawGear(ctx: &ctx, center: CGPoint(x: cx + 22, y: cy - 5), radius: gearR * 0.6, teeth: 6,
                             color: IVMaterialColors.bronzeGold.opacity(0.7))
                }
                // Step 3: worm gear hint
                if step >= 3 {
                    let wormY = cy + 40
                    // Helical line
                    var helix = Path()
                    for i in 0..<15 {
                        let t = CGFloat(i) / 14
                        let x = cx - 25 + t * 50
                        let y = wormY + sin(t * .pi * 4) * 5
                        if i == 0 { helix.move(to: CGPoint(x: x, y: y)) }
                        else { helix.addLine(to: CGPoint(x: x, y: y)) }
                    }
                    ctx.stroke(helix, with: .color(IVMaterialColors.bronzeGold), lineWidth: 2)
                }
            }
        }
    }
    private func drawGear(ctx: inout GraphicsContext, center: CGPoint, radius: CGFloat, teeth: Int, color: Color) {
        var path = Path()
        let toothDepth: CGFloat = 6
        for i in 0..<(teeth * 2) {
            let angle = CGFloat(i) * .pi / CGFloat(teeth)
            let r = i % 2 == 0 ? radius + toothDepth : radius - toothDepth * 0.3
            let pt = CGPoint(x: center.x + cos(angle) * r, y: center.y + sin(angle) * r)
            if i == 0 { path.move(to: pt) } else { path.addLine(to: pt) }
        }
        path.closeSubpath()
        ctx.fill(path, with: .color(color.opacity(0.3)))
        ctx.stroke(path, with: .color(color.opacity(0.6)), lineWidth: 1)
        // Axle
        let axle = Path(ellipseIn: CGRect(x: center.x - 3, y: center.y - 3, width: 6, height: 6))
        ctx.fill(axle, with: .color(color.opacity(0.5)))
    }
}

// MARK: - 8. Casting Sand

private struct CastingSandVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    private let labels = ["Two sand types: Arno (clay-rich) vs Mountain (pure silica)",
                          "Casting sand holds shape around wax models — needs clay",
                          "Polishing sand must be pure — clay causes scratches"]
    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            HStack(spacing: 12) {
                VStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(red: 0.72, green: 0.62, blue: 0.45).opacity(step >= 1 ? 0.5 : 0.15))
                        .frame(height: 55)
                    Text("Arno Sand")
                        .font(RenaissanceFont.visualTitle)
                        .foregroundStyle(step >= 1 ? IVMaterialColors.sepiaInk : IVMaterialColors.sepiaInk.opacity(0.3))
                    Text("Clay-rich")
                        .font(RenaissanceFont.ivBody)
                        .foregroundStyle(step >= 2 ? IVMaterialColors.dimColor : IVMaterialColors.dimColor.opacity(0.3))
                    if step >= 2 {
                        Text("→ Casting")
                            .font(RenaissanceFont.ivFormula)
                            .foregroundStyle(color)
                    }
                }
                .frame(maxWidth: .infinity)

                VStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(red: 0.85, green: 0.82, blue: 0.75).opacity(step >= 1 ? 0.5 : 0.15))
                        .frame(height: 55)
                    Text("Mountain")
                        .font(RenaissanceFont.visualTitle)
                        .foregroundStyle(step >= 1 ? IVMaterialColors.sepiaInk : IVMaterialColors.sepiaInk.opacity(0.3))
                    Text("Pure SiO₂")
                        .font(RenaissanceFont.ivBody)
                        .foregroundStyle(step >= 3 ? IVMaterialColors.dimColor : IVMaterialColors.dimColor.opacity(0.3))
                    if step >= 3 {
                        Text("→ Polishing")
                            .font(RenaissanceFont.ivFormula)
                            .foregroundStyle(color)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - 9. Custom Tools

private struct CustomToolsVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    private let labels = ["50+ custom tool designs in Leonardo's notebooks",
                          "Wire-drawing die: progressively smaller holes = uniform wire",
                          "Carburizing: pack in charcoal + heat → hardened iron"]
    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            VStack(spacing: 10) {
                // Tool icons
                if step >= 1 {
                    HStack(spacing: 8) {
                        ForEach(["wrench.fill", "scissors", "screwdriver.fill", "paintbrush.pointed.fill"], id: \.self) { icon in
                            Image(systemName: icon)
                                .font(.system(size: 14))
                                .foregroundStyle(color.opacity(0.5))
                                .frame(width: 28, height: 28)
                                .background(RoundedRectangle(cornerRadius: 4).fill(color.opacity(0.06)))
                        }
                    }
                }
                // Wire-drawing die (step 2)
                if step >= 2 {
                    HStack(spacing: 3) {
                        ForEach([12, 10, 8, 6, 4] as [CGFloat], id: \.self) { diameter in
                            Circle()
                                .strokeBorder(IVMaterialColors.sepiaInk.opacity(0.4), lineWidth: 1)
                                .frame(width: diameter, height: diameter)
                        }
                        Image(systemName: "arrow.right")
                            .font(.system(size: 13))
                            .foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.3))
                        RoundedRectangle(cornerRadius: 1)
                            .fill(color.opacity(0.4))
                            .frame(width: 30, height: 2)
                    }
                    Text("Wire die → uniform wire")
                        .font(RenaissanceFont.ivBody)
                        .foregroundStyle(IVMaterialColors.dimColor)
                }
                if step >= 3 {
                    Text("Carburize: Fe + C → hardened")
                        .font(RenaissanceFont.ivFormula)
                        .foregroundStyle(color)
                }
            }
        }
    }
}

// MARK: - 10. Drawing Table

private struct DrawingTableVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    private let labels = ["Oak drawing table — tilted at 30° for ergonomic drafting",
                          "Oak doesn't warp in humidity — crucial for accuracy",
                          "Surface planed with bronze scraper — grain-free for pen"]
    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            Canvas { ctx, size in
                let cx = size.width / 2, baseY = size.height * 0.65
                // Table legs
                var leftLeg = Path()
                leftLeg.move(to: CGPoint(x: cx - 35, y: baseY))
                leftLeg.addLine(to: CGPoint(x: cx - 40, y: baseY + 25))
                var rightLeg = Path()
                rightLeg.move(to: CGPoint(x: cx + 35, y: baseY - 15))
                rightLeg.addLine(to: CGPoint(x: cx + 40, y: baseY + 25))
                ctx.stroke(leftLeg, with: .color(IVMaterialColors.oakBrown.opacity(0.5)), lineWidth: 2)
                ctx.stroke(rightLeg, with: .color(IVMaterialColors.oakBrown.opacity(0.5)), lineWidth: 2)
                // Table surface at 30°
                var surface = Path()
                surface.move(to: CGPoint(x: cx - 40, y: baseY))
                surface.addLine(to: CGPoint(x: cx + 40, y: baseY - 22))
                ctx.stroke(surface, with: .color(IVMaterialColors.oakBrown.opacity(step >= 1 ? 0.7 : 0.3)), lineWidth: 4)
                // Angle arc
                if step >= 1 {
                    var arc = Path()
                    arc.addArc(center: CGPoint(x: cx - 40, y: baseY),
                               radius: 20, startAngle: .degrees(0), endAngle: .degrees(-30), clockwise: true)
                    ctx.stroke(arc, with: .color(IVMaterialColors.dimColor.opacity(0.5)), lineWidth: 1)
                }
                // Step 2: paper on table
                if step >= 2 {
                    var paper = Path()
                    paper.addRect(CGRect(x: cx - 18, y: baseY - 16, width: 30, height: 20))
                    let transform = CGAffineTransform(translationX: cx, y: baseY - 10)
                        .rotated(by: -30 * .pi / 180)
                        .translatedBy(x: -cx, y: -(baseY - 10))
                    ctx.fill(paper.applying(transform), with: .color(limeWhite.opacity(0.6)))
                }
            }
        }
    }
}

// MARK: - 11. Poplar Panel — Mona Lisa

private struct PoplarPanelVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    private let labels = ["Mona Lisa: poplar panel 77 × 53 cm — light, minimal grain",
                          "Gesso seal: chalk + rabbit-skin glue on both sides",
                          "World's most famous painting on the humblest wood"]
    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            VStack(spacing: 8) {
                // Panel
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(poplarLight.opacity(step >= 1 ? 0.5 : 0.15))
                        .frame(width: 65, height: 85)
                    if step >= 2 {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(limeWhite.opacity(0.4))
                            .frame(width: 59, height: 79)
                            .overlay(
                                Text("Gesso")
                                    .font(RenaissanceFont.ivBody)
                                    .foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.3))
                            )
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .strokeBorder(IVMaterialColors.sepiaInk.opacity(0.2), lineWidth: 1)
                        .frame(width: 65, height: 85)
                )

                if step >= 1 {
                    Text("77 × 53 cm")
                        .font(RenaissanceFont.ivFormula)
                        .foregroundStyle(IVMaterialColors.dimColor)
                }
                if step >= 3 {
                    Text("Poplar — humblest wood")
                        .font(RenaissanceFont.ivBody)
                        .foregroundStyle(color)
                }
            }
        }
    }
}

// MARK: - 12. Pigment Grinding

private struct PigmentGrindVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    private let labels = ["Leonardo ground pigments himself — controlling particle size",
                          "3 hours for ultramarine (lapis lazuli), 1 hour for ochre",
                          "Mix with linseed oil → oil paint. Painter controls everything"]
    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            HStack(spacing: 16) {
                // Lapis lazuli → ultramarine
                VStack(spacing: 4) {
                    Circle()
                        .fill(ultraBlue.opacity(step >= 1 ? 0.5 : 0.15))
                        .frame(width: 35, height: 35)
                    Text("Lapis")
                        .font(RenaissanceFont.visualTitle)
                        .foregroundStyle(step >= 1 ? ultraBlue : ultraBlue.opacity(0.3))
                    if step >= 2 {
                        Text("3 hours")
                            .font(RenaissanceFont.ivFormula)
                            .foregroundStyle(IVMaterialColors.dimColor)
                    }
                }

                // Ochre
                VStack(spacing: 4) {
                    Circle()
                        .fill(ochreYellow.opacity(step >= 1 ? 0.5 : 0.15))
                        .frame(width: 35, height: 35)
                    Text("Ochre")
                        .font(RenaissanceFont.visualTitle)
                        .foregroundStyle(step >= 1 ? ochreYellow : ochreYellow.opacity(0.3))
                    if step >= 2 {
                        Text("1 hour")
                            .font(RenaissanceFont.ivFormula)
                            .foregroundStyle(IVMaterialColors.dimColor)
                    }
                }

                if step >= 3 {
                    VStack(spacing: 2) {
                        Text("+")
                            .font(RenaissanceFont.visualTitle)
                            .foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.3))
                        Text("Linseed")
                            .font(RenaissanceFont.ivBody)
                            .foregroundStyle(IVMaterialColors.dimColor)
                        Text("= Paint")
                            .font(RenaissanceFont.ivFormula)
                            .foregroundStyle(color)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - 13. Lost-Wax Bronze Casting

private struct LostWaxVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    private let labels = ["Wax model → coated in 6 ceramic layers (24h each)",
                          "Fire at 700°C — wax melts out, leaving hollow mold",
                          "Pour molten bronze at 1,050°C → break shell → polish"]
    private let stages = ["Wax", "6× Ceramic", "Fire 700°", "Bronze 1050°", "Break", "Polish"]
    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            VStack(spacing: 8) {
                HStack(spacing: 3) {
                    ForEach(Array(stages.enumerated()), id: \.offset) { i, stage in
                        let active = (step == 1 && i < 2) || (step == 2 && i < 4) || step >= 3
                        Text(stage)
                            .font(RenaissanceFont.ivBody)
                            .foregroundStyle(active ? IVMaterialColors.sepiaInk : IVMaterialColors.sepiaInk.opacity(0.2))
                            .padding(.horizontal, 4).padding(.vertical, 3)
                            .background(RoundedRectangle(cornerRadius: 2).fill(active ? color.opacity(0.08) : Color.clear))

                        if i < stages.count - 1 {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 13))
                                .foregroundStyle(active ? IVMaterialColors.sepiaInk.opacity(0.2) : .clear)
                        }
                    }
                }

                if step >= 3 {
                    Text("70 tons planned for the Giant Horse")
                        .font(RenaissanceFont.ivFormula)
                        .foregroundStyle(IVMaterialColors.bronzeGold)
                }
            }
            .padding(.horizontal, 4)
        }
    }
}
