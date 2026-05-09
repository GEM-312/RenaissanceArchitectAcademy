import SwiftUI

/// Interactive science visuals for Botanical Garden knowledge cards (10 cards)
struct BotanicalGardenInteractiveVisuals {

    @ViewBuilder
    static func view(for visual: CardVisual, color: Color, height: CGFloat = 275) -> some View {
        let h = height
        Group {
            switch visual.title {
            case let t where t.contains("Padua 1545"):
                GardenOriginVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Circular Layout"):
                CircularLayoutVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Taxonomy"):
                TaxonomyTreeVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Records"):
                SeedExchangeVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Boundary Wall"):
                ThermalWallVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Irrigation"):
                IrrigationSystemVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Observation Path"):
                LimestonePathVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Cold House Glass"):
                GreenhouseGlassVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Cold House Heat"):
                UnderfloorHeatVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Soil Beds"):
                SoilSubstrateVisual(visual: visual, color: color, height: h)
            default:
                EmptyView()
            }
        }
    }

    static func hasInteractiveVisual(for visual: CardVisual) -> Bool {
        let t = visual.title
        return t.contains("Padua 1545") || t.contains("Circular Layout") ||
               t.contains("Taxonomy") || t.contains("Records") ||
               t.contains("Boundary Wall") || t.contains("Irrigation") ||
               t.contains("Observation Path") || t.contains("Cold House Glass") ||
               t.contains("Cold House Heat") || t.contains("Soil Beds")
    }
}

// MARK: - Local Colors

private let leafGreen = Color(red: 0.30, green: 0.58, blue: 0.32)
private let soilBrown = Color(red: 0.52, green: 0.38, blue: 0.26)
private let stoneGray = Color(red: 0.68, green: 0.65, blue: 0.60)
private let warmSun = Color(red: 0.90, green: 0.72, blue: 0.30)
private let infrared = Color(red: 0.85, green: 0.30, blue: 0.20)
private let uvLight = Color(red: 0.55, green: 0.40, blue: 0.85)

private typealias TeachingContainer = IVTeachingContainer
private typealias DimLabel = IVDimLabel
private typealias FormulaText = IVFormulaText
private typealias DimLine = IVDimLine

// MARK: - 1. Padua 1545 — Garden Origin

private struct GardenOriginVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1

    private let labels = ["1545: Venice funds a garden at the University of Padua",
                          "Purpose: medical students study plants firsthand, not from books",
                          "Still there today — world's oldest in its original location"]

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            Canvas { ctx, size in
                let cx = size.width / 2, cy = size.height * 0.4

                // Circular garden outline
                let r = min(size.width, size.height) * 0.28
                let circle = Path(ellipseIn: CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2))
                ctx.stroke(circle, with: .color(leafGreen.opacity(0.4)), lineWidth: 2)
                ctx.fill(circle, with: .color(leafGreen.opacity(0.06)))

                // Cross paths
                var cross = Path()
                cross.move(to: CGPoint(x: cx - r, y: cy))
                cross.addLine(to: CGPoint(x: cx + r, y: cy))
                cross.move(to: CGPoint(x: cx, y: cy - r))
                cross.addLine(to: CGPoint(x: cx, y: cy + r))
                ctx.stroke(cross, with: .color(soilBrown.opacity(0.3)), lineWidth: 1)

                // Step 1: year label
                if step >= 1 {
                    let yearRect = CGRect(x: cx - 25, y: cy - 8, width: 50, height: 16)
                    ctx.fill(Path(roundedRect: yearRect, cornerRadius: 3), with: .color(color.opacity(0.1)))
                }

                // Step 2: small plant icons in quadrants
                if step >= 2 {
                    let plantPositions: [CGPoint] = [
                        CGPoint(x: cx - r * 0.45, y: cy - r * 0.45),
                        CGPoint(x: cx + r * 0.45, y: cy - r * 0.45),
                        CGPoint(x: cx - r * 0.45, y: cy + r * 0.45),
                        CGPoint(x: cx + r * 0.45, y: cy + r * 0.45),
                    ]
                    for pt in plantPositions {
                        // Simple leaf shape
                        var leaf = Path()
                        leaf.move(to: CGPoint(x: pt.x, y: pt.y + 6))
                        leaf.addQuadCurve(to: CGPoint(x: pt.x, y: pt.y - 6),
                                          control: CGPoint(x: pt.x + 8, y: pt.y))
                        leaf.addQuadCurve(to: CGPoint(x: pt.x, y: pt.y + 6),
                                          control: CGPoint(x: pt.x - 8, y: pt.y))
                        ctx.fill(leaf, with: .color(leafGreen.opacity(0.4)))
                    }
                }

                // Step 3: checkmark — still exists
                if step >= 3 {
                    let checkY = cy + r + 18
                    var check = Path()
                    check.move(to: CGPoint(x: cx - 8, y: checkY))
                    check.addLine(to: CGPoint(x: cx - 2, y: checkY + 6))
                    check.addLine(to: CGPoint(x: cx + 10, y: checkY - 6))
                    ctx.stroke(check, with: .color(leafGreen), lineWidth: 2)
                }
            }
            .overlay {
                if step >= 1 {
                    Text("1545")
                        .font(RenaissanceFont.visualTitle)
                        .foregroundStyle(color)
                        .position(x: 999, y: 999) // Canvas draws it
                }
            }
        }
    }
}

// MARK: - 2. Circular Layout — 4 Quadrants

private struct CircularLayoutVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1

    private let labels = ["84-meter diameter circle divided by compass-aligned paths",
                          "4 quadrants: Earth, Water, Air, Fire",
                          "Each quadrant split into 16 planting beds"]

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            Canvas { ctx, size in
                let cx = size.width / 2, cy = size.height * 0.42
                let r = min(size.width, size.height) * 0.34

                // Outer wall
                let wallCircle = Path(ellipseIn: CGRect(x: cx - r - 4, y: cy - r - 4, width: (r + 4) * 2, height: (r + 4) * 2))
                ctx.stroke(wallCircle, with: .color(stoneGray), lineWidth: 3)

                // Inner garden circle
                let gardenCircle = Path(ellipseIn: CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2))
                ctx.fill(gardenCircle, with: .color(leafGreen.opacity(0.05)))
                ctx.stroke(gardenCircle, with: .color(leafGreen.opacity(0.3)), lineWidth: 1)

                // Cross paths (compass)
                var cross = Path()
                cross.move(to: CGPoint(x: cx - r, y: cy))
                cross.addLine(to: CGPoint(x: cx + r, y: cy))
                cross.move(to: CGPoint(x: cx, y: cy - r))
                cross.addLine(to: CGPoint(x: cx, y: cy + r))
                ctx.stroke(cross, with: .color(soilBrown.opacity(0.4)), lineWidth: 1.5)

                // Compass labels
                let compassLabels: [(String, CGPoint)] = [
                    ("N", CGPoint(x: cx, y: cy - r - 12)),
                    ("S", CGPoint(x: cx, y: cy + r + 12)),
                    ("E", CGPoint(x: cx + r + 12, y: cy)),
                    ("W", CGPoint(x: cx - r - 12, y: cy)),
                ]
                for (_, _) in compassLabels {
                    // Drawn via overlay
                }

                // Step 2: quadrant coloring
                if step >= 2 {
                    let quadColors: [Color] = [soilBrown, IVMaterialColors.waterBlue, RenaissanceColors.stoneGray.opacity(0.5), infrared]
                    for (i, qColor) in quadColors.enumerated() {
                        let startAngle = CGFloat(i) * .pi / 2
                        let endAngle = startAngle + .pi / 2
                        var sector = Path()
                        sector.move(to: CGPoint(x: cx, y: cy))
                        sector.addArc(center: CGPoint(x: cx, y: cy), radius: r * 0.95,
                                      startAngle: .radians(startAngle - .pi / 2), endAngle: .radians(endAngle - .pi / 2), clockwise: false)
                        sector.closeSubpath()
                        ctx.fill(sector, with: .color(qColor.opacity(0.1)))
                    }
                }

                // Step 3: 16 beds per quadrant (subdividing lines)
                if step >= 3 {
                    for i in 0..<4 {
                        let baseAngle = CGFloat(i) * .pi / 2 - .pi / 2
                        for j in 1..<4 {
                            let angle = baseAngle + CGFloat(j) * .pi / 8
                            var subLine = Path()
                            subLine.move(to: CGPoint(x: cx + cos(angle) * r * 0.15, y: cy + sin(angle) * r * 0.15))
                            subLine.addLine(to: CGPoint(x: cx + cos(angle) * r * 0.9, y: cy + sin(angle) * r * 0.9))
                            ctx.stroke(subLine, with: .color(leafGreen.opacity(0.15)), lineWidth: 0.5)
                        }
                    }
                    // Concentric dividers
                    for ringR in [r * 0.4, r * 0.65] {
                        let ring = Path(ellipseIn: CGRect(x: cx - ringR, y: cy - ringR, width: ringR * 2, height: ringR * 2))
                        ctx.stroke(ring, with: .color(leafGreen.opacity(0.15)), lineWidth: 0.5)
                    }
                }

                // Dimension line
                let dimFrom = CGPoint(x: cx - r, y: cy + r + 20)
                let dimTo = CGPoint(x: cx + r, y: cy + r + 20)
                ctx.stroke(IVDimLine(from: dimFrom, to: dimTo).path(in: .zero), with: .color(IVMaterialColors.dimColor), lineWidth: 1)
            }
        }
    }
}

// MARK: - 3. Taxonomy Tree

private struct TaxonomyTreeVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1

    private let labels = ["6,000 species needed organizing — group by shared traits",
                          "Classification tree: leaf shape → flower → seed type",
                          "Herbarium: pressed plants become data points"]

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            Canvas { ctx, size in
                let cx = size.width / 2
                let topY = size.height * 0.08

                // Root node
                let rootR: CGFloat = 12
                let rootPt = CGPoint(x: cx, y: topY + rootR)
                let rootCircle = Path(ellipseIn: CGRect(x: rootPt.x - rootR, y: rootPt.y - rootR, width: rootR * 2, height: rootR * 2))
                ctx.fill(rootCircle, with: .color(leafGreen.opacity(0.3)))
                ctx.stroke(rootCircle, with: .color(leafGreen), lineWidth: 1.5)

                // Level 1 branches (step 2+)
                if step >= 2 {
                    let level1Y = topY + 55
                    let level1Pts: [CGFloat] = [cx - 60, cx, cx + 60]
                    let labels = ["🍃", "🌸", "🌰"]

                    for (i, lx) in level1Pts.enumerated() {
                        // Branch line
                        var branch = Path()
                        branch.move(to: CGPoint(x: cx, y: rootPt.y + rootR))
                        branch.addLine(to: CGPoint(x: lx, y: level1Y - 8))
                        ctx.stroke(branch, with: .color(soilBrown.opacity(0.4)), lineWidth: 1)

                        // Node
                        let node = Path(ellipseIn: CGRect(x: lx - 8, y: level1Y - 8, width: 16, height: 16))
                        ctx.fill(node, with: .color(color.opacity(0.15)))
                        ctx.stroke(node, with: .color(color.opacity(0.5)), lineWidth: 1)

                        // Level 2 sub-branches
                        if step >= 2 {
                            for offset: CGFloat in [-15, 15] {
                                let subX = lx + offset
                                let subY = level1Y + 35
                                var subBranch = Path()
                                subBranch.move(to: CGPoint(x: lx, y: level1Y + 8))
                                subBranch.addLine(to: CGPoint(x: subX, y: subY - 4))
                                ctx.stroke(subBranch, with: .color(soilBrown.opacity(0.2)), lineWidth: 0.5)

                                let subNode = Path(ellipseIn: CGRect(x: subX - 4, y: subY - 4, width: 8, height: 8))
                                ctx.fill(subNode, with: .color(leafGreen.opacity(0.2)))
                            }
                        }
                    }
                }

                // Step 3: herbarium pressed leaf at bottom
                if step >= 3 {
                    let pressY = size.height * 0.68
                    // Paper rectangle
                    let paper = CGRect(x: cx - 40, y: pressY, width: 80, height: 30)
                    ctx.fill(Path(roundedRect: paper, cornerRadius: 3), with: .color(Color(red: 0.95, green: 0.92, blue: 0.85)))
                    ctx.stroke(Path(roundedRect: paper, cornerRadius: 3), with: .color(IVMaterialColors.sepiaInk.opacity(0.2)), lineWidth: 0.5)

                    // Pressed leaf
                    var leaf = Path()
                    leaf.move(to: CGPoint(x: cx - 10, y: pressY + 22))
                    leaf.addQuadCurve(to: CGPoint(x: cx - 10, y: pressY + 8),
                                      control: CGPoint(x: cx + 6, y: pressY + 15))
                    leaf.addQuadCurve(to: CGPoint(x: cx - 10, y: pressY + 22),
                                      control: CGPoint(x: cx - 26, y: pressY + 15))
                    ctx.fill(leaf, with: .color(leafGreen.opacity(0.3)))

                    // Label line
                    var labelLine = Path()
                    labelLine.move(to: CGPoint(x: cx + 5, y: pressY + 15))
                    labelLine.addLine(to: CGPoint(x: cx + 30, y: pressY + 15))
                    ctx.stroke(labelLine, with: .color(IVMaterialColors.sepiaInk.opacity(0.3)), lineWidth: 0.5)
                }
            }
        }
    }
}

// MARK: - 4. Seed Exchange Network

private struct SeedExchangeVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1

    private let labels = ["Every plant recorded: origin, date, soil, growth, uses",
                          "Index Seminum: seed catalog shared with 60 gardens",
                          "Europe's first open-source scientific network"]

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            Canvas { ctx, size in
                let cx = size.width / 2, cy = size.height * 0.4

                // Central node (Padua)
                let cR: CGFloat = 14
                let center = Path(ellipseIn: CGRect(x: cx - cR, y: cy - cR, width: cR * 2, height: cR * 2))
                ctx.fill(center, with: .color(color.opacity(0.3)))
                ctx.stroke(center, with: .color(color), lineWidth: 2)

                // Step 1: catalog/book icon
                if step == 1 {
                    let bookRect = CGRect(x: cx - 20, y: cy + 25, width: 40, height: 28)
                    ctx.fill(Path(roundedRect: bookRect, cornerRadius: 3), with: .color(Color(red: 0.92, green: 0.88, blue: 0.80)))
                    ctx.stroke(Path(roundedRect: bookRect, cornerRadius: 3), with: .color(IVMaterialColors.sepiaInk.opacity(0.3)), lineWidth: 1)
                    // Lines on book
                    for i in 0..<3 {
                        var line = Path()
                        let ly = bookRect.minY + 7 + CGFloat(i) * 7
                        line.move(to: CGPoint(x: bookRect.minX + 6, y: ly))
                        line.addLine(to: CGPoint(x: bookRect.maxX - 6, y: ly))
                        ctx.stroke(line, with: .color(IVMaterialColors.sepiaInk.opacity(0.15)), lineWidth: 0.5)
                    }
                }

                // Step 2+: network nodes
                if step >= 2 {
                    let nodeCount = step >= 3 ? 10 : 6
                    let networkR = min(size.width, size.height) * 0.35
                    for i in 0..<nodeCount {
                        let angle = CGFloat(i) * (2 * .pi / CGFloat(nodeCount)) - .pi / 2
                        let nx = cx + cos(angle) * networkR
                        let ny = cy + sin(angle) * networkR

                        // Connection line
                        var conn = Path()
                        conn.move(to: CGPoint(x: cx, y: cy))
                        conn.addLine(to: CGPoint(x: nx, y: ny))
                        ctx.stroke(conn, with: .color(leafGreen.opacity(0.25)), lineWidth: 0.5)

                        // Node
                        let node = Path(ellipseIn: CGRect(x: nx - 5, y: ny - 5, width: 10, height: 10))
                        ctx.fill(node, with: .color(leafGreen.opacity(0.3)))
                        ctx.stroke(node, with: .color(leafGreen.opacity(0.5)), lineWidth: 0.5)
                    }

                    // Bidirectional arrows on a few connections
                    if step >= 3 {
                        for i in [0, 3, 6] where i < nodeCount {
                            let angle = CGFloat(i) * (2 * .pi / CGFloat(nodeCount)) - .pi / 2
                            let midX = cx + cos(angle) * networkR * 0.5
                            let midY = cy + sin(angle) * networkR * 0.5
                            let arrow = Path(ellipseIn: CGRect(x: midX - 2, y: midY - 2, width: 4, height: 4))
                            ctx.fill(arrow, with: .color(color))
                        }
                    }
                }
            }
        }
    }
}

// MARK: - 5. Thermal Wall

private struct ThermalWallVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1

    private let labels = ["Trachyte wall: volcanic stone from the Euganean Hills",
                          "Absorbs sun heat during the day — thermal mass",
                          "Radiates warmth at night: +2°C for nearby plants"]

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            Canvas { ctx, size in
                // Wall cross-section
                let wallX = size.width * 0.35, wallW: CGFloat = 25
                let wallTop = size.height * 0.1, wallBot = size.height * 0.7

                // Stone wall
                let wall = CGRect(x: wallX, y: wallTop, width: wallW, height: wallBot - wallTop)
                ctx.fill(Path(wall), with: .color(stoneGray.opacity(0.5)))
                ctx.stroke(Path(wall), with: .color(IVMaterialColors.sepiaInk.opacity(0.4)), lineWidth: 1.5)

                // Stone blocks pattern
                for row in 0..<6 {
                    let y = wallTop + CGFloat(row) * (wallBot - wallTop) / 6
                    var line = Path()
                    line.move(to: CGPoint(x: wallX, y: y))
                    line.addLine(to: CGPoint(x: wallX + wallW, y: y))
                    ctx.stroke(line, with: .color(IVMaterialColors.sepiaInk.opacity(0.15)), lineWidth: 0.5)
                }

                // Step 1: sun on left
                let sunX = wallX - 40, sunY = size.height * 0.25
                let sun = Path(ellipseIn: CGRect(x: sunX - 10, y: sunY - 10, width: 20, height: 20))
                ctx.fill(sun, with: .color(warmSun.opacity(step >= 1 ? 0.7 : 0.2)))

                // Step 2: heat arrows INTO wall
                if step >= 2 {
                    for i in 0..<3 {
                        let ay = wallTop + 15 + CGFloat(i) * 30
                        var arrow = Path()
                        arrow.move(to: CGPoint(x: sunX + 12, y: ay))
                        arrow.addLine(to: CGPoint(x: wallX - 3, y: ay))
                        ctx.stroke(arrow, with: .color(warmSun.opacity(0.5)), lineWidth: 1.5)
                    }
                    // Wall glow
                    ctx.fill(Path(wall), with: .color(warmSun.opacity(0.15)))
                }

                // Step 3: heat arrows OUT from wall (right side, toward plants)
                if step >= 3 {
                    let plantX = wallX + wallW + 30
                    for i in 0..<3 {
                        let ay = wallTop + 20 + CGFloat(i) * 28
                        // Radiating wavy line
                        var wave = Path()
                        wave.move(to: CGPoint(x: wallX + wallW + 3, y: ay))
                        wave.addCurve(to: CGPoint(x: plantX, y: ay),
                                      control1: CGPoint(x: wallX + wallW + 12, y: ay - 5),
                                      control2: CGPoint(x: plantX - 10, y: ay + 5))
                        ctx.stroke(wave, with: .color(infrared.opacity(0.4)), lineWidth: 1)
                    }

                    // Small plant near wall
                    var stem = Path()
                    stem.move(to: CGPoint(x: plantX + 5, y: wallBot))
                    stem.addLine(to: CGPoint(x: plantX + 5, y: wallBot - 20))
                    ctx.stroke(stem, with: .color(leafGreen.opacity(0.5)), lineWidth: 1)

                    var leaf = Path()
                    leaf.move(to: CGPoint(x: plantX + 5, y: wallBot - 18))
                    leaf.addQuadCurve(to: CGPoint(x: plantX + 5, y: wallBot - 8),
                                      control: CGPoint(x: plantX + 18, y: wallBot - 13))
                    ctx.fill(leaf, with: .color(leafGreen.opacity(0.4)))
                }
            }
        }
    }
}

// MARK: - 6. Irrigation System

private struct IrrigationSystemVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1

    private let labels = ["Bacchiglione River feeds underground terra-cotta pipes",
                          "Central cistern distributes water to 4 quadrants",
                          "Sluice gates control water per bed — custom rainfall"]

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            Canvas { ctx, size in
                let cx = size.width / 2, cy = size.height * 0.45

                // River (left)
                if step >= 1 {
                    var river = Path()
                    river.move(to: CGPoint(x: 0, y: size.height * 0.15))
                    river.addCurve(to: CGPoint(x: 30, y: size.height * 0.65),
                                   control1: CGPoint(x: 15, y: size.height * 0.3),
                                   control2: CGPoint(x: 5, y: size.height * 0.5))
                    ctx.stroke(river, with: .color(IVMaterialColors.waterBlue.opacity(0.5)), lineWidth: 8)

                    // Pipe from river
                    var pipe = Path()
                    pipe.move(to: CGPoint(x: 30, y: size.height * 0.4))
                    pipe.addLine(to: CGPoint(x: cx - 15, y: cy))
                    ctx.stroke(pipe, with: .color(soilBrown.opacity(0.5)), style: StrokeStyle(lineWidth: 3, dash: [6, 3]))
                }

                // Step 2: central cistern
                if step >= 2 {
                    let cisternR: CGFloat = 12
                    let cistern = Path(ellipseIn: CGRect(x: cx - cisternR, y: cy - cisternR, width: cisternR * 2, height: cisternR * 2))
                    ctx.fill(cistern, with: .color(IVMaterialColors.waterBlue.opacity(0.3)))
                    ctx.stroke(cistern, with: .color(IVMaterialColors.waterBlue), lineWidth: 1.5)

                    // 4 output channels
                    let directions: [(CGFloat, CGFloat)] = [(0, -1), (0, 1), (-1, 0), (1, 0)]
                    for (dx, dy) in directions {
                        var channel = Path()
                        channel.move(to: CGPoint(x: cx + dx * cisternR, y: cy + dy * cisternR))
                        channel.addLine(to: CGPoint(x: cx + dx * 50, y: cy + dy * 40))
                        ctx.stroke(channel, with: .color(IVMaterialColors.waterBlue.opacity(0.4)), lineWidth: 2)
                    }
                }

                // Step 3: sluice gates
                if step >= 3 {
                    let gatePositions: [CGPoint] = [
                        CGPoint(x: cx, y: cy - 30),
                        CGPoint(x: cx, y: cy + 30),
                        CGPoint(x: cx - 35, y: cy),
                        CGPoint(x: cx + 35, y: cy),
                    ]
                    for gp in gatePositions {
                        let gate = CGRect(x: gp.x - 4, y: gp.y - 3, width: 8, height: 6)
                        ctx.fill(Path(gate), with: .color(soilBrown.opacity(0.6)))
                        ctx.stroke(Path(gate), with: .color(IVMaterialColors.sepiaInk.opacity(0.4)), lineWidth: 0.5)
                    }

                    // Bed rectangles at ends
                    let beds: [CGRect] = [
                        CGRect(x: cx - 10, y: cy - 55, width: 20, height: 12),
                        CGRect(x: cx - 10, y: cy + 43, width: 20, height: 12),
                        CGRect(x: cx - 62, y: cy - 6, width: 20, height: 12),
                        CGRect(x: cx + 42, y: cy - 6, width: 20, height: 12),
                    ]
                    for bed in beds {
                        ctx.fill(Path(roundedRect: bed, cornerRadius: 2), with: .color(leafGreen.opacity(0.15)))
                        ctx.stroke(Path(roundedRect: bed, cornerRadius: 2), with: .color(leafGreen.opacity(0.3)), lineWidth: 0.5)
                    }
                }
            }
        }
    }
}

// MARK: - 7. Limestone Path — Natural Fertilizer

private struct LimestonePathVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1

    private let labels = ["Paths paved with Euganean Hills limestone gravel",
                          "Rain dissolves gravel → releases calcium into soil",
                          "Natural liming keeps pH alkaline — perfect for herbs"]

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            Canvas { ctx, size in
                let pathY = size.height * 0.35
                let pathH: CGFloat = 20
                let soilY = pathY + pathH
                let soilH: CGFloat = 35

                // Gravel path
                let pathRect = CGRect(x: 20, y: pathY, width: size.width - 40, height: pathH)
                ctx.fill(Path(pathRect), with: .color(stoneGray.opacity(0.4)))
                ctx.stroke(Path(pathRect), with: .color(IVMaterialColors.sepiaInk.opacity(0.2)), lineWidth: 0.5)

                // Gravel dots
                for _ in 0..<15 {
                    let gx = CGFloat.random(in: 25...(size.width - 25))
                    let gy = CGFloat.random(in: pathY + 3...pathY + pathH - 3)
                    let dot = Path(ellipseIn: CGRect(x: gx - 2, y: gy - 1.5, width: 4, height: 3))
                    ctx.fill(dot, with: .color(stoneGray.opacity(0.6)))
                }

                // Soil layer
                let soilRect = CGRect(x: 20, y: soilY, width: size.width - 40, height: soilH)
                ctx.fill(Path(soilRect), with: .color(soilBrown.opacity(0.3)))

                // Step 2: rain drops dissolving
                if step >= 2 {
                    for i in 0..<5 {
                        let rx = 40 + CGFloat(i) * (size.width - 80) / 4
                        // Rain drop
                        var drop = Path()
                        drop.move(to: CGPoint(x: rx, y: pathY - 15))
                        drop.addLine(to: CGPoint(x: rx - 3, y: pathY - 5))
                        drop.addQuadCurve(to: CGPoint(x: rx + 3, y: pathY - 5),
                                          control: CGPoint(x: rx, y: pathY - 2))
                        drop.closeSubpath()
                        ctx.fill(drop, with: .color(IVMaterialColors.waterBlue.opacity(0.4)))

                        // Dissolving arrow downward
                        var arrow = Path()
                        arrow.move(to: CGPoint(x: rx, y: pathY + pathH))
                        arrow.addLine(to: CGPoint(x: rx, y: soilY + 10))
                        ctx.stroke(arrow, with: .color(color.opacity(0.4)), style: StrokeStyle(lineWidth: 1, dash: [2, 2]))
                    }
                }

                // Step 3: Ca²⁺ ions and pH indicator
                if step >= 3 {
                    // Plant roots in soil
                    for i in 0..<3 {
                        let px = 50 + CGFloat(i) * (size.width - 100) / 2
                        // Stem
                        var stem = Path()
                        stem.move(to: CGPoint(x: px, y: soilY))
                        stem.addLine(to: CGPoint(x: px, y: soilY - 15))
                        ctx.stroke(stem, with: .color(leafGreen.opacity(0.5)), lineWidth: 1)
                        // Leaf
                        var leaf = Path()
                        leaf.move(to: CGPoint(x: px, y: soilY - 13))
                        leaf.addQuadCurve(to: CGPoint(x: px, y: soilY - 5),
                                          control: CGPoint(x: px + 10, y: soilY - 9))
                        ctx.fill(leaf, with: .color(leafGreen.opacity(0.4)))
                    }

                    // pH label
                    let phRect = CGRect(x: size.width * 0.3, y: soilY + soilH + 5, width: size.width * 0.4, height: 16)
                    ctx.fill(Path(roundedRect: phRect, cornerRadius: 3), with: .color(color.opacity(0.08)))
                }
            }
            .overlay(alignment: .bottom) {
                if step >= 3 {
                    Text("CaCO₃ → Ca²⁺ + alkaline pH")
                        .font(RenaissanceFont.ivFormula)
                        .foregroundStyle(color)
                        .offset(y: -28)
                }
            }
        }
    }
}

// MARK: - 8. Greenhouse Glass — Light Transmission

private struct GreenhouseGlassVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1

    private let labels = ["Murano glass panes: 80% light transmission",
                          "UV light passes through → photosynthesis",
                          "Infrared (heat) trapped inside — greenhouse effect"]

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            Canvas { ctx, size in
                let glassX = size.width * 0.45
                let glassW: CGFloat = 10
                let topY = size.height * 0.08
                let botY = size.height * 0.7

                // Glass pane
                let glass = CGRect(x: glassX - glassW / 2, y: topY, width: glassW, height: botY - topY)
                ctx.fill(Path(glass), with: .color(RenaissanceColors.renaissanceBlue.opacity(0.08)))
                ctx.stroke(Path(glass), with: .color(IVMaterialColors.sepiaInk.opacity(0.3)), lineWidth: 1.5)

                // Lead came frame
                ctx.fill(Path(CGRect(x: glassX - glassW / 2 - 2, y: topY, width: 2, height: botY - topY)), with: .color(RenaissanceColors.stoneGray.opacity(0.4)))
                ctx.fill(Path(CGRect(x: glassX + glassW / 2, y: topY, width: 2, height: botY - topY)), with: .color(RenaissanceColors.stoneGray.opacity(0.4)))

                // Sunlight (left side)
                if step >= 1 {
                    let sunX: CGFloat = 15, sunY = size.height * 0.15
                    let sunCircle = Path(ellipseIn: CGRect(x: sunX - 8, y: sunY - 8, width: 16, height: 16))
                    ctx.fill(sunCircle, with: .color(warmSun.opacity(0.7)))
                }

                // Step 2: UV arrow passes through
                if step >= 2 {
                    let uvY = size.height * 0.25
                    var uvArrow = Path()
                    uvArrow.move(to: CGPoint(x: 30, y: uvY))
                    uvArrow.addLine(to: CGPoint(x: size.width - 20, y: uvY))
                    ctx.stroke(uvArrow, with: .color(uvLight.opacity(0.6)), lineWidth: 2)

                    // Plant on right
                    let plantX = size.width * 0.75
                    var stem = Path()
                    stem.move(to: CGPoint(x: plantX, y: botY))
                    stem.addLine(to: CGPoint(x: plantX, y: botY - 25))
                    ctx.stroke(stem, with: .color(leafGreen), lineWidth: 1.5)
                    var leaf = Path()
                    leaf.move(to: CGPoint(x: plantX, y: botY - 23))
                    leaf.addQuadCurve(to: CGPoint(x: plantX, y: botY - 10),
                                      control: CGPoint(x: plantX + 14, y: botY - 16))
                    leaf.addQuadCurve(to: CGPoint(x: plantX, y: botY - 23),
                                      control: CGPoint(x: plantX - 14, y: botY - 16))
                    ctx.fill(leaf, with: .color(leafGreen.opacity(0.5)))
                }

                // Step 3: infrared bounces back (trapped)
                if step >= 3 {
                    let irY = size.height * 0.45
                    // IR arrow going right
                    var irRight = Path()
                    irRight.move(to: CGPoint(x: size.width * 0.7, y: irY))
                    irRight.addLine(to: CGPoint(x: glassX + glassW / 2, y: irY))
                    ctx.stroke(irRight, with: .color(infrared.opacity(0.5)), lineWidth: 1.5)

                    // IR bounces back
                    var irBounce = Path()
                    irBounce.move(to: CGPoint(x: glassX + glassW / 2, y: irY))
                    irBounce.addLine(to: CGPoint(x: size.width * 0.65, y: irY + 15))
                    ctx.stroke(irBounce, with: .color(infrared.opacity(0.5)), style: StrokeStyle(lineWidth: 1.5, dash: [3, 2]))

                    // X on glass for IR
                    var xMark = Path()
                    xMark.move(to: CGPoint(x: glassX - 4, y: irY - 4))
                    xMark.addLine(to: CGPoint(x: glassX + 4, y: irY + 4))
                    xMark.move(to: CGPoint(x: glassX + 4, y: irY - 4))
                    xMark.addLine(to: CGPoint(x: glassX - 4, y: irY + 4))
                    ctx.stroke(xMark, with: .color(infrared.opacity(0.6)), lineWidth: 1.5)
                }
            }
        }
    }
}

// MARK: - 9. Underfloor Heating

private struct UnderfloorHeatVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1

    private let labels = ["Terracotta pipes carry warm air beneath brick floor",
                          "Brick thermal mass: absorbs 4× more heat than wood",
                          "Floor releases stored heat at night — keeps above 10°C"]

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            Canvas { ctx, size in
                let floorY = size.height * 0.45
                let floorH: CGFloat = 14
                let pipeY = floorY + floorH + 8

                // Floor
                let floor = CGRect(x: 20, y: floorY, width: size.width - 40, height: floorH)
                ctx.fill(Path(floor), with: .color(step >= 2 ? soilBrown.opacity(0.5) : soilBrown.opacity(0.3)))
                ctx.stroke(Path(floor), with: .color(IVMaterialColors.sepiaInk.opacity(0.3)), lineWidth: 1)

                // Brick pattern on floor
                let brickW: CGFloat = 18
                for i in 0..<Int((size.width - 40) / brickW) {
                    let bx = 20 + CGFloat(i) * brickW
                    var line = Path()
                    line.move(to: CGPoint(x: bx, y: floorY))
                    line.addLine(to: CGPoint(x: bx, y: floorY + floorH))
                    ctx.stroke(line, with: .color(IVMaterialColors.sepiaInk.opacity(0.1)), lineWidth: 0.5)
                }

                // Underground pipes
                if step >= 1 {
                    var pipe = Path()
                    pipe.move(to: CGPoint(x: 20, y: pipeY))
                    for i in 0..<6 {
                        let px = 20 + CGFloat(i) * (size.width - 40) / 5
                        let direction: CGFloat = i % 2 == 0 ? 1 : -1
                        pipe.addQuadCurve(to: CGPoint(x: px + (size.width - 40) / 5, y: pipeY),
                                          control: CGPoint(x: px + (size.width - 40) / 10, y: pipeY + direction * 10))
                    }
                    ctx.stroke(pipe, with: .color(soilBrown.opacity(0.6)), lineWidth: 3)

                    // Furnace on left
                    let furnace = CGRect(x: 5, y: pipeY - 8, width: 18, height: 16)
                    ctx.fill(Path(roundedRect: furnace, cornerRadius: 2), with: .color(infrared.opacity(0.3)))
                    ctx.stroke(Path(roundedRect: furnace, cornerRadius: 2), with: .color(IVMaterialColors.sepiaInk.opacity(0.3)), lineWidth: 1)
                }

                // Step 2: heat arrows UP through floor
                if step >= 2 {
                    for i in 0..<4 {
                        let ax = 40 + CGFloat(i) * (size.width - 80) / 3
                        var arrow = Path()
                        arrow.move(to: CGPoint(x: ax, y: pipeY - 3))
                        arrow.addLine(to: CGPoint(x: ax, y: floorY + floorH + 2))
                        ctx.stroke(arrow, with: .color(warmSun.opacity(0.4)), lineWidth: 1)
                    }
                    // Glow on floor
                    ctx.fill(Path(floor), with: .color(warmSun.opacity(0.1)))
                }

                // Step 3: heat radiating UP from floor at night
                if step >= 3 {
                    for i in 0..<5 {
                        let ax = 35 + CGFloat(i) * (size.width - 70) / 4
                        var wave = Path()
                        wave.move(to: CGPoint(x: ax, y: floorY))
                        wave.addCurve(to: CGPoint(x: ax, y: floorY - 30),
                                      control1: CGPoint(x: ax + 6, y: floorY - 10),
                                      control2: CGPoint(x: ax - 6, y: floorY - 20))
                        ctx.stroke(wave, with: .color(infrared.opacity(0.3)), lineWidth: 1)
                    }

                    // Temperature label
                    let tempRect = CGRect(x: size.width * 0.3, y: floorY - 50, width: size.width * 0.4, height: 16)
                    ctx.fill(Path(roundedRect: tempRect, cornerRadius: 3), with: .color(color.opacity(0.08)))
                }
            }
            .overlay(alignment: .top) {
                if step >= 3 {
                    Text("> 10°C")
                        .font(RenaissanceFont.ivFormula)
                        .foregroundStyle(color)
                        .padding(.top, 8)
                }
            }
        }
    }
}

// MARK: - 10. Soil Substrates — Custom Mixes

private struct SoilSubstrateVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1

    private let labels = ["Different plants need different soil mixes",
                          "Sand + compost (herbs), clay + peat (bog), gravel (alpine)",
                          "Add charcoal (biochar) → drainage + no root rot"]

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            HStack(spacing: 8) {
                soilColumn(label: "Mediterranean", layers: [
                    ("Sand", Color(red: 0.88, green: 0.82, blue: 0.68)),
                    ("Compost", soilBrown.opacity(0.6)),
                ], plant: "🌿", active: step >= 1, showCharcoal: step >= 3)

                soilColumn(label: "Bog", layers: [
                    ("Clay", Color(red: 0.65, green: 0.55, blue: 0.45)),
                    ("Peat", Color(red: 0.35, green: 0.30, blue: 0.22)),
                ], plant: "🌾", active: step >= 2, showCharcoal: step >= 3)

                soilColumn(label: "Alpine", layers: [
                    ("Gravel", stoneGray),
                ], plant: "🌼", active: step >= 2, showCharcoal: step >= 3)
            }
            .padding(.horizontal, 10)
        }
    }

    @ViewBuilder
    private func soilColumn(label: String, layers: [(String, Color)], plant: String, active: Bool, showCharcoal: Bool) -> some View {
        VStack(spacing: 2) {
            Text(plant)
                .font(.system(size: 16))
                .opacity(active ? 1 : 0.2)

            // Soil layers
            VStack(spacing: 0) {
                ForEach(Array(layers.enumerated()), id: \.offset) { _, layer in
                    Rectangle()
                        .fill(active ? layer.1 : RenaissanceColors.stoneGray.opacity(0.1))
                        .frame(height: 22)
                        .overlay {
                            Text(layer.0)
                                .font(RenaissanceFont.ivBody)
                                .foregroundStyle(active ? .white.opacity(0.8) : .clear)
                        }
                }

                // Charcoal layer
                if showCharcoal {
                    Rectangle()
                        .fill(Color(red: 0.2, green: 0.2, blue: 0.2).opacity(0.6))
                        .frame(height: 12)
                        .overlay {
                            Text("Biochar")
                                .font(RenaissanceFont.ivBody)
                                .foregroundStyle(.white.opacity(0.7))
                        }
                }
            }
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .strokeBorder(active ? IVMaterialColors.sepiaInk.opacity(0.3) : IVMaterialColors.sepiaInk.opacity(0.1), lineWidth: 0.5)
            )

            Text(label)
                .font(RenaissanceFont.visualTitle)
                .foregroundStyle(active ? IVMaterialColors.sepiaInk : IVMaterialColors.sepiaInk.opacity(0.3))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }
}
