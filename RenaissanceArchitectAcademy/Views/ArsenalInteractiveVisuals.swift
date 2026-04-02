import SwiftUI

/// Interactive science visuals for Arsenal knowledge cards (12 cards)
struct ArsenalInteractiveVisuals {

    @ViewBuilder
    static func view(for visual: CardVisual, color: Color, height: CGFloat = 275) -> some View {
        let h = height
        Group {
            switch visual.title {
            case let t where t.contains("16,000"):
                WorkforceVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Rope Walk"):
                RopeWalkVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Assembly Line"):
                AssemblyLineVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Sea Trial"):
                BuoyancyVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Wet Docks"):
                WetDockVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Dock Stone"):
                IstrianStoneVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Marine Concrete"):
                MarineConcreteVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Forge Anchors"):
                AnchorForgeVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Sail Canvas"):
                SailLiftVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Timber Stores"):
                TimberSeasonVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Ship Fittings"):
                PulleyVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Oakum"):
                OakumCaulkVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Iron Quenching"):
                QuenchingVisual(visual: visual, color: color, height: h)
            default:
                EmptyView()
            }
        }
    }

    static func hasInteractiveVisual(for visual: CardVisual) -> Bool {
        let t = visual.title
        return t.contains("16,000") || t.contains("Rope Walk") ||
               t.contains("Assembly Line") || t.contains("Sea Trial") ||
               t.contains("Wet Docks") || t.contains("Dock Stone") ||
               t.contains("Marine Concrete") || t.contains("Forge Anchors") ||
               t.contains("Sail Canvas") || t.contains("Timber Stores") ||
               t.contains("Ship Fittings") || t.contains("Oakum") ||
               t.contains("Iron Quenching")
    }
}

// MARK: - Local Aliases

private let gridColor = ivGridColor
private let sepiaInk = ivSepiaInk
private let waterBlue = ivWaterBlue
private let dimColor = ivDimColor
private let hullBrown = Color(red: 0.55, green: 0.40, blue: 0.25)
private let ironDark = Color(red: 0.35, green: 0.33, blue: 0.30)
private let sailCream = Color(red: 0.92, green: 0.88, blue: 0.78)
private let ropeGold = Color(red: 0.78, green: 0.62, blue: 0.35)
private let stoneWhite = Color(red: 0.90, green: 0.88, blue: 0.85)
private let pitchBlack = Color(red: 0.18, green: 0.15, blue: 0.12)
private let cherryRed = Color(red: 0.80, green: 0.25, blue: 0.20)

private typealias TeachingContainer = IVTeachingContainer
private typealias DimLabel = IVDimLabel
private typealias FormulaText = IVFormulaText
private typealias DimLine = IVDimLine

// MARK: - 1. Workforce Scale

private struct WorkforceVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1

    private let labels = ["16,000 arsenalotti — more than most Renaissance cities",
                          "Each a specialist: hull, mast, rope, caulk, weapons",
                          "Peak: one complete galley launched every single day"]

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            Canvas { ctx, size in
                // Dots representing workers
                let dotsPerRow = 20
                let rows = step >= 1 ? (step >= 3 ? 8 : step >= 2 ? 5 : 3) : 0
                let dotR: CGFloat = 3
                let spacing: CGFloat = min((size.width - 20) / CGFloat(dotsPerRow), 12)
                let startX = (size.width - CGFloat(dotsPerRow) * spacing) / 2
                let startY = size.height * 0.08

                let specialtyColors: [Color] = [hullBrown, ropeGold, ironDark, waterBlue, color]

                for row in 0..<rows {
                    for col in 0..<dotsPerRow {
                        let x = startX + CGFloat(col) * spacing + spacing / 2
                        let y = startY + CGFloat(row) * spacing + spacing / 2
                        let colorIdx = step >= 2 ? (col + row) % specialtyColors.count : 0
                        let dotColor = step >= 2 ? specialtyColors[colorIdx] : sepiaInk
                        let dot = Path(ellipseIn: CGRect(x: x - dotR, y: y - dotR, width: dotR * 2, height: dotR * 2))
                        ctx.fill(dot, with: .color(dotColor.opacity(0.5)))
                    }
                }

                // Step 3: ship silhouette at bottom
                if step >= 3 {
                    let shipY = size.height * 0.7
                    var hull = Path()
                    hull.move(to: CGPoint(x: size.width * 0.15, y: shipY))
                    hull.addQuadCurve(to: CGPoint(x: size.width * 0.85, y: shipY),
                                      control: CGPoint(x: size.width * 0.5, y: shipY + 20))
                    hull.addLine(to: CGPoint(x: size.width * 0.8, y: shipY - 5))
                    hull.addLine(to: CGPoint(x: size.width * 0.2, y: shipY - 5))
                    hull.closeSubpath()
                    ctx.fill(hull, with: .color(hullBrown.opacity(0.3)))
                    ctx.stroke(hull, with: .color(sepiaInk.opacity(0.3)), lineWidth: 1)

                    // Mast
                    var mast = Path()
                    mast.move(to: CGPoint(x: size.width * 0.5, y: shipY - 5))
                    mast.addLine(to: CGPoint(x: size.width * 0.5, y: shipY - 30))
                    ctx.stroke(mast, with: .color(hullBrown.opacity(0.5)), lineWidth: 1.5)
                }
            }
        }
    }
}

// MARK: - 2. Rope Walk — 316m

private struct RopeWalkVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1

    private let labels = ["The Tana: 316-meter rope walk — one of Europe's longest",
                          "800 hemp fibers twisted into strands, strands into rope",
                          "S-twist + Z-twist = won't unravel. Geometry of spirals"]

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            Canvas { ctx, size in
                let ropeY = size.height * 0.35
                let startX: CGFloat = 15, endX = size.width - 15

                // Building outline (long rectangle)
                let building = CGRect(x: startX, y: ropeY - 20, width: endX - startX, height: 40)
                ctx.fill(Path(roundedRect: building, cornerRadius: 3), with: .color(stoneWhite.opacity(0.3)))
                ctx.stroke(Path(roundedRect: building, cornerRadius: 3), with: .color(sepiaInk.opacity(0.2)), lineWidth: 1)

                // Dimension
                let dimY = ropeY + 30
                ctx.stroke(IVDimLine(from: CGPoint(x: startX, y: dimY), to: CGPoint(x: endX, y: dimY)).path(in: .zero),
                           with: .color(dimColor), lineWidth: 0.5)

                // Step 2: fiber → strand → rope
                if step >= 2 {
                    let fiberY = size.height * 0.6
                    // Single fibers
                    for i in 0..<5 {
                        let fx = 30 + CGFloat(i) * 8
                        var fiber = Path()
                        fiber.move(to: CGPoint(x: fx, y: fiberY))
                        fiber.addLine(to: CGPoint(x: fx, y: fiberY + 25))
                        ctx.stroke(fiber, with: .color(ropeGold.opacity(0.4)), lineWidth: 0.5)
                    }

                    // Arrow
                    var a1 = Path()
                    a1.move(to: CGPoint(x: 80, y: fiberY + 12))
                    a1.addLine(to: CGPoint(x: 95, y: fiberY + 12))
                    ctx.stroke(a1, with: .color(sepiaInk.opacity(0.3)), lineWidth: 0.5)

                    // Twisted strand
                    let strandX: CGFloat = 105
                    for i in 0..<8 {
                        let sy = fiberY + CGFloat(i) * 3
                        let sx = strandX + sin(CGFloat(i) * 0.8) * 3
                        let dot = Path(ellipseIn: CGRect(x: sx - 1.5, y: sy - 1, width: 3, height: 2))
                        ctx.fill(dot, with: .color(ropeGold.opacity(0.6)))
                    }

                    // Arrow
                    var a2 = Path()
                    a2.move(to: CGPoint(x: 120, y: fiberY + 12))
                    a2.addLine(to: CGPoint(x: 135, y: fiberY + 12))
                    ctx.stroke(a2, with: .color(sepiaInk.opacity(0.3)), lineWidth: 0.5)

                    // Thick rope
                    var rope = Path()
                    rope.move(to: CGPoint(x: 145, y: fiberY))
                    for j in 0..<8 {
                        let ry = fiberY + CGFloat(j) * 3
                        rope.addLine(to: CGPoint(x: 145 + sin(CGFloat(j) * 1.2) * 4, y: ry))
                    }
                    ctx.stroke(rope, with: .color(ropeGold), lineWidth: 3)
                }

                // Step 3: S/Z twist labels
                if step >= 3 {
                    let twistY = size.height * 0.6
                    let twistX = size.width * 0.6

                    // S-twist spiral
                    var sSpiral = Path()
                    for i in 0..<10 {
                        let t = CGFloat(i) / 9
                        let x = twistX + t * 30
                        let y = twistY + sin(t * .pi * 3) * 6
                        if i == 0 { sSpiral.move(to: CGPoint(x: x, y: y)) }
                        else { sSpiral.addLine(to: CGPoint(x: x, y: y)) }
                    }
                    ctx.stroke(sSpiral, with: .color(ropeGold.opacity(0.6)), lineWidth: 1.5)

                    // Z-twist (opposite)
                    var zSpiral = Path()
                    for i in 0..<10 {
                        let t = CGFloat(i) / 9
                        let x = twistX + t * 30
                        let y = twistY + 18 - sin(t * .pi * 3) * 6
                        if i == 0 { zSpiral.move(to: CGPoint(x: x, y: y)) }
                        else { zSpiral.addLine(to: CGPoint(x: x, y: y)) }
                    }
                    ctx.stroke(zSpiral, with: .color(color.opacity(0.6)), lineWidth: 1.5)
                }
            }
        }
    }
}

// MARK: - 3. Assembly Line — 5 Stations

private struct AssemblyLineVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1

    private let labels = ["Hull floated through canal past sequential stations",
                          "5 stations: masts → rigging → oars → weapons → provisions",
                          "Complete 40m warship assembled in one day"]

    private let stations = ["Masts", "Rigging", "Oars", "Weapons", "Provisions"]

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            Canvas { ctx, size in
                let canalY = size.height * 0.4
                let canalH: CGFloat = 18

                // Canal
                let canal = CGRect(x: 0, y: canalY, width: size.width, height: canalH)
                ctx.fill(Path(canal), with: .color(waterBlue.opacity(0.12)))
                ctx.stroke(Path(CGRect(x: 0, y: canalY, width: size.width, height: 1)), with: .color(waterBlue.opacity(0.3)), lineWidth: 0.5)
                ctx.stroke(Path(CGRect(x: 0, y: canalY + canalH, width: size.width, height: 1)), with: .color(waterBlue.opacity(0.3)), lineWidth: 0.5)

                // Stations
                let stationCount = step >= 2 ? 5 : (step >= 1 ? 1 : 0)
                let spacing = size.width / 6

                for i in 0..<stationCount {
                    let sx = spacing + CGFloat(i) * spacing
                    let stationRect = CGRect(x: sx - 12, y: canalY - 22, width: 24, height: 18)
                    ctx.fill(Path(roundedRect: stationRect, cornerRadius: 2), with: .color(color.opacity(0.15)))
                    ctx.stroke(Path(roundedRect: stationRect, cornerRadius: 2), with: .color(color.opacity(0.3)), lineWidth: 0.5)
                }

                // Ship moving through (step 1+)
                if step >= 1 {
                    let shipX = step >= 3 ? size.width * 0.85 : step >= 2 ? size.width * 0.5 : size.width * 0.2
                    var hull = Path()
                    hull.move(to: CGPoint(x: shipX - 20, y: canalY + 5))
                    hull.addLine(to: CGPoint(x: shipX + 22, y: canalY + 5))
                    hull.addLine(to: CGPoint(x: shipX + 28, y: canalY + canalH / 2))
                    hull.addLine(to: CGPoint(x: shipX + 22, y: canalY + canalH - 5))
                    hull.addLine(to: CGPoint(x: shipX - 20, y: canalY + canalH - 5))
                    hull.closeSubpath()
                    ctx.fill(hull, with: .color(hullBrown.opacity(0.5)))
                    ctx.stroke(hull, with: .color(sepiaInk.opacity(0.3)), lineWidth: 1)
                }

                // Flow arrow
                var flowArrow = Path()
                flowArrow.move(to: CGPoint(x: 10, y: canalY + canalH + 12))
                flowArrow.addLine(to: CGPoint(x: size.width - 10, y: canalY + canalH + 12))
                ctx.stroke(flowArrow, with: .color(sepiaInk.opacity(0.2)), lineWidth: 0.5)
                var arrowHead = Path()
                arrowHead.move(to: CGPoint(x: size.width - 10, y: canalY + canalH + 12))
                arrowHead.addLine(to: CGPoint(x: size.width - 18, y: canalY + canalH + 8))
                arrowHead.addLine(to: CGPoint(x: size.width - 18, y: canalY + canalH + 16))
                arrowHead.closeSubpath()
                ctx.fill(arrowHead, with: .color(sepiaInk.opacity(0.2)))
            }
        }
    }
}

// MARK: - 4. Buoyancy — Archimedes

private struct BuoyancyVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1

    private let labels = ["Ship weight must equal weight of displaced water",
                          "Half-hull models tested in water tanks at 1:10 scale",
                          "150-ton galley displaces exactly 150 tons of seawater"]

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            Canvas { ctx, size in
                let cx = size.width / 2
                let waterY = size.height * 0.45

                // Water
                let water = CGRect(x: 20, y: waterY, width: size.width - 40, height: size.height * 0.3)
                ctx.fill(Path(water), with: .color(waterBlue.opacity(0.1)))
                // Waterline
                var wl = Path()
                wl.move(to: CGPoint(x: 20, y: waterY))
                wl.addLine(to: CGPoint(x: size.width - 20, y: waterY))
                ctx.stroke(wl, with: .color(waterBlue.opacity(0.4)), lineWidth: 1)

                // Hull cross-section
                var hull = Path()
                hull.move(to: CGPoint(x: cx - 35, y: waterY - 8))
                hull.addLine(to: CGPoint(x: cx + 35, y: waterY - 8))
                hull.addLine(to: CGPoint(x: cx + 25, y: waterY + 18))
                hull.addQuadCurve(to: CGPoint(x: cx - 25, y: waterY + 18),
                                  control: CGPoint(x: cx, y: waterY + 25))
                hull.addLine(to: CGPoint(x: cx - 35, y: waterY - 8))
                ctx.fill(hull, with: .color(hullBrown.opacity(0.4)))
                ctx.stroke(hull, with: .color(sepiaInk.opacity(0.4)), lineWidth: 1.5)

                // Step 1: weight arrow down
                if step >= 1 {
                    var down = Path()
                    down.move(to: CGPoint(x: cx, y: waterY - 25))
                    down.addLine(to: CGPoint(x: cx, y: waterY - 12))
                    ctx.stroke(down, with: .color(sepiaInk.opacity(0.5)), lineWidth: 1.5)

                    // Buoyancy arrow up
                    var up = Path()
                    up.move(to: CGPoint(x: cx, y: waterY + 30))
                    up.addLine(to: CGPoint(x: cx, y: waterY + 20))
                    ctx.stroke(up, with: .color(waterBlue.opacity(0.6)), lineWidth: 1.5)
                }

                // Step 2: small model
                if step >= 2 {
                    let modelX = size.width * 0.2
                    let modelY = waterY + 2
                    var model = Path()
                    model.move(to: CGPoint(x: modelX - 10, y: modelY - 3))
                    model.addLine(to: CGPoint(x: modelX + 10, y: modelY - 3))
                    model.addQuadCurve(to: CGPoint(x: modelX - 10, y: modelY - 3),
                                       control: CGPoint(x: modelX, y: modelY + 8))
                    ctx.fill(model, with: .color(hullBrown.opacity(0.6)))
                    ctx.stroke(model, with: .color(sepiaInk.opacity(0.3)), lineWidth: 0.5)
                }
            }
        }
    }
}

// MARK: - 5. Wet Dock

private struct WetDockVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1

    private let labels = ["Wet dock: enclosed basin — ship floats during construction",
                          "Gates seal the basin, pumps control water level",
                          "Ship already floating — no dangerous slipway launch"]

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            Canvas { ctx, size in
                let dockY = size.height * 0.3
                let waterH = size.height * 0.35

                // Dock walls
                let wallW: CGFloat = 8
                ctx.fill(Path(CGRect(x: 25, y: dockY, width: wallW, height: waterH)), with: .color(stoneWhite.opacity(0.6)))
                ctx.fill(Path(CGRect(x: size.width - 33, y: dockY, width: wallW, height: waterH)), with: .color(stoneWhite.opacity(0.6)))
                ctx.stroke(Path(CGRect(x: 25, y: dockY, width: wallW, height: waterH)), with: .color(sepiaInk.opacity(0.3)), lineWidth: 1)
                ctx.stroke(Path(CGRect(x: size.width - 33, y: dockY, width: wallW, height: waterH)), with: .color(sepiaInk.opacity(0.3)), lineWidth: 1)

                // Water in dock
                let waterRect = CGRect(x: 33, y: dockY + 10, width: size.width - 66, height: waterH - 10)
                ctx.fill(Path(waterRect), with: .color(waterBlue.opacity(0.12)))

                // Step 2: gate
                if step >= 2 {
                    let gateRect = CGRect(x: size.width - 33, y: dockY + 5, width: 12, height: waterH - 10)
                    ctx.fill(Path(gateRect), with: .color(hullBrown.opacity(0.5)))
                    ctx.stroke(Path(gateRect), with: .color(sepiaInk.opacity(0.4)), lineWidth: 1)
                }

                // Ship floating in dock
                let shipY = dockY + 15
                var hull = Path()
                let hx = size.width / 2
                hull.move(to: CGPoint(x: hx - 40, y: shipY))
                hull.addLine(to: CGPoint(x: hx + 40, y: shipY))
                hull.addLine(to: CGPoint(x: hx + 30, y: shipY + 15))
                hull.addQuadCurve(to: CGPoint(x: hx - 30, y: shipY + 15),
                                  control: CGPoint(x: hx, y: shipY + 20))
                hull.closeSubpath()
                ctx.fill(hull, with: .color(hullBrown.opacity(0.4)))
                ctx.stroke(hull, with: .color(sepiaInk.opacity(0.3)), lineWidth: 1)

                // Step 3: checkmark — safe, no launch
                if step >= 3 {
                    let checkY = dockY + waterH + 10
                    var check = Path()
                    check.move(to: CGPoint(x: hx - 8, y: checkY))
                    check.addLine(to: CGPoint(x: hx - 2, y: checkY + 6))
                    check.addLine(to: CGPoint(x: hx + 10, y: checkY - 6))
                    ctx.stroke(check, with: .color(Color(red: 0.30, green: 0.58, blue: 0.32)), lineWidth: 2)
                }
            }
        }
    }
}

// MARK: - 6. Istrian Stone

private struct IstrianStoneVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1

    private let labels = ["Istrian stone: dense white limestone from Croatia",
                          "Tight grain blocks salt crystal penetration",
                          "Looks like marble but 3× harder — Venice's foundation"]

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            HStack(spacing: 16) {
                // Stone block
                VStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(stoneWhite.opacity(step >= 1 ? 0.7 : 0.2))
                        .frame(width: 65, height: 55)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .strokeBorder(sepiaInk.opacity(0.3), lineWidth: 1)
                        )
                    Text("Istrian")
                        .font(.custom("Cinzel-Bold", size: 9))
                        .foregroundStyle(step >= 1 ? sepiaInk : sepiaInk.opacity(0.3))
                }

                // vs
                if step >= 3 {
                    VStack(spacing: 4) {
                        Text("3×")
                            .font(.custom("Cinzel-Bold", size: 16))
                            .foregroundStyle(color)
                        Text("harder")
                            .font(.custom("EBGaramond-Regular", size: 10))
                            .foregroundStyle(dimColor)
                    }
                }

                // Marble for comparison
                if step >= 3 {
                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(red: 0.95, green: 0.93, blue: 0.90).opacity(0.6))
                            .frame(width: 65, height: 55)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .strokeBorder(sepiaInk.opacity(0.15), lineWidth: 1)
                            )
                        Text("Marble")
                            .font(.custom("Cinzel-Bold", size: 9))
                            .foregroundStyle(sepiaInk.opacity(0.5))
                    }
                }
            }
            .padding(.horizontal, 16)

            if step >= 2 {
                Text("Salt ✕ → tight grain")
                    .font(.custom("EBGaramond-Bold", size: 11))
                    .foregroundStyle(color)
            }
        }
    }
}

// MARK: - 7. Marine Concrete

private struct MarineConcreteVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1

    private let labels = ["Pozzolanic ash from Phlegraean Fields near Naples",
                          "Venice adds crushed brick for extra alumina",
                          "500 years in saltwater — Roman recipe + Venetian innovation"]

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            VStack(spacing: 8) {
                HStack(spacing: 6) {
                    ingredientPill("Pozzolana", icon: "🌋", active: step >= 1)
                    if step >= 1 { Text("+").foregroundStyle(sepiaInk.opacity(0.3)) }
                    ingredientPill("Lime", icon: "ite", active: step >= 1)
                    if step >= 2 { Text("+").foregroundStyle(sepiaInk.opacity(0.3)) }
                    if step >= 2 {
                        ingredientPill("Brick", icon: "🧱", active: true)
                    }
                }

                if step >= 3 {
                    HStack(spacing: 4) {
                        Image(systemName: "drop.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(waterBlue.opacity(0.5))
                        Text("500 years in saltwater")
                            .font(.custom("EBGaramond-Bold", size: 12))
                            .foregroundStyle(color)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func ingredientPill(_ label: String, icon: String, active: Bool) -> some View {
        VStack(spacing: 2) {
            Text(icon)
                .font(.system(size: 14))
                .opacity(active ? 1 : 0.2)
            Text(label)
                .font(.custom("EBGaramond-Regular", size: 9))
                .foregroundStyle(active ? sepiaInk : sepiaInk.opacity(0.3))
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(active ? color.opacity(0.08) : Color.gray.opacity(0.03))
        )
    }
}

// MARK: - 8. Anchor Forge

private struct AnchorForgeVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1

    private let labels = ["4 iron bars faggot-welded at 1,200°C white heat",
                          "500 hammer blows by 4 smiths striking in rotation",
                          "Arms curved at 40° — angle for maximum seabed grip"]

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            Canvas { ctx, size in
                let cx = size.width / 2, cy = size.height * 0.4

                // Anchor shape
                let shankH: CGFloat = 50
                // Shank
                var shank = Path()
                shank.move(to: CGPoint(x: cx, y: cy - shankH / 2))
                shank.addLine(to: CGPoint(x: cx, y: cy + shankH / 2))
                ctx.stroke(shank, with: .color(ironDark.opacity(step >= 1 ? 0.7 : 0.2)), lineWidth: 3)

                // Cross bar at top
                var crossbar = Path()
                crossbar.move(to: CGPoint(x: cx - 15, y: cy - shankH / 2))
                crossbar.addLine(to: CGPoint(x: cx + 15, y: cy - shankH / 2))
                ctx.stroke(crossbar, with: .color(ironDark.opacity(step >= 1 ? 0.7 : 0.2)), lineWidth: 2)

                // Arms at 40° (step 3 shows angle)
                let armLen: CGFloat = 25
                let armAngle: CGFloat = step >= 3 ? 40 * .pi / 180 : 30 * .pi / 180
                for side: CGFloat in [-1, 1] {
                    var arm = Path()
                    arm.move(to: CGPoint(x: cx, y: cy + shankH / 2))
                    arm.addLine(to: CGPoint(x: cx + side * cos(.pi / 2 - armAngle) * armLen,
                                            y: cy + shankH / 2 - sin(.pi / 2 - armAngle) * armLen))
                    ctx.stroke(arm, with: .color(ironDark.opacity(step >= 1 ? 0.7 : 0.2)), lineWidth: 2.5)
                }

                // Step 2: hammer strike sparks
                if step >= 2 {
                    let sparkPositions: [CGPoint] = [
                        CGPoint(x: cx + 8, y: cy - 5),
                        CGPoint(x: cx - 10, y: cy + 3),
                        CGPoint(x: cx + 5, y: cy + 8),
                    ]
                    for sp in sparkPositions {
                        var star = Path()
                        for a in stride(from: 0.0, to: Double.pi * 2, by: Double.pi / 3) {
                            star.move(to: sp)
                            star.addLine(to: CGPoint(x: sp.x + cos(a) * 5, y: sp.y + sin(a) * 5))
                        }
                        ctx.stroke(star, with: .color(Color(red: 0.95, green: 0.75, blue: 0.25).opacity(0.5)), lineWidth: 0.5)
                    }
                }

                // Step 3: 40° angle indicator
                if step >= 3 {
                    let arcCenter = CGPoint(x: cx, y: cy + shankH / 2)
                    var arc = Path()
                    arc.addArc(center: arcCenter, radius: 15,
                               startAngle: .degrees(-90), endAngle: .degrees(-90 + 40), clockwise: false)
                    ctx.stroke(arc, with: .color(dimColor.opacity(0.6)), lineWidth: 1)
                }
            }
        }
    }
}

// MARK: - 9. Sail Lift

private struct SailLiftVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1

    private let labels = ["Wind over curved sail creates low pressure = forward pull",
                          "Lateen (triangular) sails closer to the wind than square",
                          "Airfoil principle — same physics as airplane wings"]

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            Canvas { ctx, size in
                let cx = size.width / 2, cy = size.height * 0.4

                // Mast
                var mast = Path()
                mast.move(to: CGPoint(x: cx, y: cy + 35))
                mast.addLine(to: CGPoint(x: cx, y: cy - 35))
                ctx.stroke(mast, with: .color(hullBrown.opacity(0.5)), lineWidth: 2)

                // Lateen sail (triangular, curved)
                var sail = Path()
                sail.move(to: CGPoint(x: cx, y: cy - 30))
                sail.addQuadCurve(to: CGPoint(x: cx, y: cy + 25),
                                  control: CGPoint(x: cx + 45, y: cy))
                sail.addLine(to: CGPoint(x: cx, y: cy - 30))
                ctx.fill(sail, with: .color(sailCream.opacity(step >= 1 ? 0.5 : 0.15)))
                ctx.stroke(sail, with: .color(sepiaInk.opacity(0.3)), lineWidth: 1)

                // Step 1: wind arrows
                if step >= 1 {
                    for i in 0..<3 {
                        let wy = cy - 15 + CGFloat(i) * 15
                        var wind = Path()
                        wind.move(to: CGPoint(x: cx - 40, y: wy))
                        wind.addLine(to: CGPoint(x: cx - 10, y: wy))
                        ctx.stroke(wind, with: .color(waterBlue.opacity(0.4)), lineWidth: 1)
                    }
                }

                // Step 2: lift arrow (forward)
                if step >= 2 {
                    var lift = Path()
                    lift.move(to: CGPoint(x: cx + 20, y: cy))
                    lift.addLine(to: CGPoint(x: cx + 45, y: cy))
                    ctx.stroke(lift, with: .color(color), lineWidth: 2)
                    var head = Path()
                    head.move(to: CGPoint(x: cx + 45, y: cy))
                    head.addLine(to: CGPoint(x: cx + 39, y: cy - 4))
                    head.addLine(to: CGPoint(x: cx + 39, y: cy + 4))
                    head.closeSubpath()
                    ctx.fill(head, with: .color(color))
                }

                // Step 3: pressure labels
                if step >= 3 {
                    // Low P on front
                    let lowRect = CGRect(x: cx + 20, y: cy - 25, width: 35, height: 14)
                    ctx.fill(Path(roundedRect: lowRect, cornerRadius: 2), with: .color(color.opacity(0.1)))
                    // High P on back
                    let hiRect = CGRect(x: cx - 45, y: cy - 5, width: 30, height: 14)
                    ctx.fill(Path(roundedRect: hiRect, cornerRadius: 2), with: .color(cherryRed.opacity(0.1)))
                }
            }
        }
    }
}

// MARK: - 10. Timber Seasoning

private struct TimberSeasonVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1

    private let labels = ["Fresh oak: 80% moisture — warps if used green",
                          "3 years in open-air sheds → 15% moisture",
                          "Venice kept 100,000 logs in reserve, labeled by date"]

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            VStack(spacing: 10) {
                HStack(spacing: 20) {
                    // Wet log
                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(hullBrown.opacity(step >= 1 ? 0.7 : 0.2))
                            .frame(width: 40, height: 30)
                            .overlay {
                                if step >= 1 {
                                    Image(systemName: "drop.fill")
                                        .font(.system(size: 10))
                                        .foregroundStyle(waterBlue.opacity(0.5))
                                }
                            }
                        Text("80%")
                            .font(.custom("EBGaramond-Bold", size: 11))
                            .foregroundStyle(step >= 1 ? waterBlue : waterBlue.opacity(0.3))
                        Text("Fresh")
                            .font(.custom("Cinzel-Bold", size: 8))
                            .foregroundStyle(step >= 1 ? sepiaInk : sepiaInk.opacity(0.3))
                    }

                    if step >= 2 {
                        VStack(spacing: 2) {
                            Image(systemName: "arrow.right")
                                .font(.system(size: 10))
                                .foregroundStyle(sepiaInk.opacity(0.3))
                            Text("3 yrs")
                                .font(.custom("EBGaramond-Regular", size: 9))
                                .foregroundStyle(dimColor)
                        }
                    }

                    // Dry log
                    if step >= 2 {
                        VStack(spacing: 4) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(red: 0.65, green: 0.50, blue: 0.32).opacity(0.6))
                                .frame(width: 40, height: 30)
                            Text("15%")
                                .font(.custom("EBGaramond-Bold", size: 11))
                                .foregroundStyle(color)
                            Text("Seasoned")
                                .font(.custom("Cinzel-Bold", size: 8))
                                .foregroundStyle(sepiaInk)
                        }
                    }
                }

                if step >= 3 {
                    Text("100,000 logs in reserve")
                        .font(.custom("EBGaramond-Bold", size: 12))
                        .foregroundStyle(color)
                }
            }
        }
    }
}

// MARK: - 11. Walnut Pulleys

private struct PulleyVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1

    private let labels = ["Walnut: tight grain machines smoothly, no splinters",
                          "Natural oils self-lubricate — sheave spins freely",
                          "40 walnut pulleys per galley — 'per meccanismi' only"]

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            Canvas { ctx, size in
                let cx = size.width / 2, cy = size.height * 0.38

                // Pulley housing
                let housingW: CGFloat = 30, housingH: CGFloat = 45
                let housing = CGRect(x: cx - housingW / 2, y: cy - housingH / 2, width: housingW, height: housingH)
                ctx.fill(Path(roundedRect: housing, cornerRadius: 4), with: .color(Color(red: 0.50, green: 0.38, blue: 0.25).opacity(step >= 1 ? 0.5 : 0.15)))
                ctx.stroke(Path(roundedRect: housing, cornerRadius: 4), with: .color(sepiaInk.opacity(0.3)), lineWidth: 1)

                // Sheave (wheel)
                let sheaveR: CGFloat = 10
                let sheave = Path(ellipseIn: CGRect(x: cx - sheaveR, y: cy - sheaveR, width: sheaveR * 2, height: sheaveR * 2))
                ctx.fill(sheave, with: .color(Color(red: 0.55, green: 0.42, blue: 0.28).opacity(step >= 1 ? 0.6 : 0.2)))
                ctx.stroke(sheave, with: .color(sepiaInk.opacity(0.4)), lineWidth: 1)

                // Axle dot
                let axle = Path(ellipseIn: CGRect(x: cx - 2, y: cy - 2, width: 4, height: 4))
                ctx.fill(axle, with: .color(ironDark.opacity(0.5)))

                // Rope through pulley
                var rope = Path()
                rope.move(to: CGPoint(x: cx - 15, y: cy - housingH))
                rope.addLine(to: CGPoint(x: cx - sheaveR, y: cy))
                rope.addArc(center: CGPoint(x: cx, y: cy), radius: sheaveR,
                            startAngle: .degrees(180), endAngle: .degrees(0), clockwise: true)
                rope.addLine(to: CGPoint(x: cx + 15, y: cy + housingH))
                ctx.stroke(rope, with: .color(ropeGold.opacity(0.5)), lineWidth: 1.5)

                // Step 2: rotation arrow
                if step >= 2 {
                    var arc = Path()
                    arc.addArc(center: CGPoint(x: cx, y: cy), radius: sheaveR + 6,
                               startAngle: .degrees(-60), endAngle: .degrees(180), clockwise: false)
                    ctx.stroke(arc, with: .color(color.opacity(0.5)),
                               style: StrokeStyle(lineWidth: 1, dash: [2, 2]))
                }
            }
        }
    }
}

// MARK: - 12. Oakum Caulking

private struct OakumCaulkVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1

    private let labels = ["Gap between every hull plank must be sealed",
                          "Oakum: tarred hemp hammered into seams with mallet",
                          "200 meters of sealed seams per galley + hot pitch finish"]

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            Canvas { ctx, size in
                let cx = size.width / 2
                let plankY = size.height * 0.2
                let plankH: CGFloat = 18
                let gap: CGFloat = 5

                // Two planks with gap
                for i in 0..<3 {
                    let y = plankY + CGFloat(i) * (plankH + gap)
                    let plank = CGRect(x: 20, y: y, width: size.width - 40, height: plankH)
                    ctx.fill(Path(plank), with: .color(hullBrown.opacity(0.4)))
                    ctx.stroke(Path(plank), with: .color(sepiaInk.opacity(0.2)), lineWidth: 0.5)
                }

                // Gaps highlighted
                if step >= 1 {
                    for i in 0..<2 {
                        let y = plankY + CGFloat(i) * (plankH + gap) + plankH
                        let gapRect = CGRect(x: 25, y: y, width: size.width - 50, height: gap)
                        ctx.fill(Path(gapRect), with: .color(step >= 2 ? ropeGold.opacity(0.4) : Color.red.opacity(0.15)))
                    }
                }

                // Step 2: oakum fibers in gap
                if step >= 2 {
                    for i in 0..<2 {
                        let y = plankY + CGFloat(i) * (plankH + gap) + plankH + gap / 2
                        for j in 0..<8 {
                            let fx = 30 + CGFloat(j) * (size.width - 60) / 7
                            var fiber = Path()
                            fiber.move(to: CGPoint(x: fx - 3, y: y - 1))
                            fiber.addQuadCurve(to: CGPoint(x: fx + 3, y: y + 1),
                                               control: CGPoint(x: fx, y: y - 2))
                            ctx.stroke(fiber, with: .color(ropeGold.opacity(0.6)), lineWidth: 0.5)
                        }
                    }
                }

                // Step 3: pitch seal
                if step >= 3 {
                    for i in 0..<2 {
                        let y = plankY + CGFloat(i) * (plankH + gap) + plankH
                        let pitch = CGRect(x: 25, y: y, width: size.width - 50, height: gap)
                        ctx.fill(Path(pitch), with: .color(pitchBlack.opacity(0.3)))
                    }
                }
            }
        }
    }
}

// MARK: - 13. Iron Quenching

private struct QuenchingVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1

    private let labels = ["Heat iron to cherry red — 800°C",
                          "Plunge into 40°C seawater — salt increases cooling speed",
                          "Rapid cooling traps carbon in iron lattice → harder"]

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            Canvas { ctx, size in
                let cx = size.width / 2
                let waterY = size.height * 0.5

                // Iron bar
                let barW: CGFloat = 50, barH: CGFloat = 10
                let barY = step >= 2 ? waterY + 5 : size.height * 0.2
                let barColor = step >= 1 ? cherryRed : ironDark
                let bar = CGRect(x: cx - barW / 2, y: barY, width: barW, height: barH)
                ctx.fill(Path(roundedRect: bar, cornerRadius: 2), with: .color(barColor.opacity(0.7)))
                ctx.stroke(Path(roundedRect: bar, cornerRadius: 2), with: .color(sepiaInk.opacity(0.3)), lineWidth: 1)

                // Heat glow (step 1)
                if step == 1 {
                    let glow = Path(ellipseIn: CGRect(x: cx - barW * 0.7, y: barY - 5, width: barW * 1.4, height: barH + 10))
                    ctx.stroke(glow, with: .color(cherryRed.opacity(0.2)), lineWidth: 2)
                }

                // Water bath (step 2+)
                if step >= 2 {
                    let bath = CGRect(x: cx - 45, y: waterY, width: 90, height: 35)
                    ctx.fill(Path(roundedRect: bath, cornerRadius: 4), with: .color(waterBlue.opacity(0.15)))
                    ctx.stroke(Path(roundedRect: bath, cornerRadius: 4), with: .color(waterBlue.opacity(0.4)), lineWidth: 1)

                    // Steam bubbles
                    let bubbles: [CGPoint] = [
                        CGPoint(x: cx - 15, y: waterY - 5),
                        CGPoint(x: cx + 10, y: waterY - 8),
                        CGPoint(x: cx, y: waterY - 12),
                    ]
                    for b in bubbles {
                        let bubble = Path(ellipseIn: CGRect(x: b.x - 3, y: b.y - 3, width: 6, height: 6))
                        ctx.stroke(bubble, with: .color(waterBlue.opacity(0.3)), lineWidth: 0.5)
                    }
                }

                // Step 3: crystal lattice hint
                if step >= 3 {
                    let latticeY = waterY + 45
                    // Simple grid = crystal structure
                    for row in 0..<2 {
                        for col in 0..<4 {
                            let lx = cx - 20 + CGFloat(col) * 13
                            let ly = latticeY + CGFloat(row) * 13
                            let dot = Path(ellipseIn: CGRect(x: lx - 2, y: ly - 2, width: 4, height: 4))
                            ctx.fill(dot, with: .color(ironDark.opacity(0.5)))
                        }
                    }
                    // Carbon atom (trapped)
                    let carbon = Path(ellipseIn: CGRect(x: cx - 3, y: latticeY + 5, width: 6, height: 6))
                    ctx.fill(carbon, with: .color(color))
                }
            }
        }
    }
}
