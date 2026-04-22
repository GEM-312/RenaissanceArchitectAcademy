import SwiftUI

/// Interactive science visuals for Pantheon knowledge cards
/// Each visual teaches with labeled dimension lines, formulas, and step-by-step progression
struct PantheonInteractiveVisuals {

    /// Returns an interactive view for a Pantheon card visual, or nil if not yet implemented
    @ViewBuilder
    static func view(for visual: CardVisual, color: Color, height: CGFloat = 275) -> some View {
        let h = height
        return Group {
            switch visual.title {
            case let t where t.contains("16 Columns"):
                ColumnsCountVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Ring Foundation"):
                LayerDigVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Perfect Sphere"):
                SphereSliderVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Coffers"):
                CofferTapVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Oculus"):
                OculusCompressionVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Limestone vs Marble"):
                HeatTransformVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Roman vs Modern"):
                TimelineAgingVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Graded Aggregate"):
                PourRingsVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Bronze Doors"):
                DoorSwingVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Centering"):
                CenteringBuildVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Scaffolding"):
                ScaffoldClimbVisual(visual: visual, color: color, height: h)
            case let t where t.contains("1:3"):
                MixRecipeVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Calcination") || t.contains("CaCO"):
                CalcinationSliderVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Opus Sectile"):
                TessellationPuzzleVisual(visual: visual, color: color, height: h)
            default:
                EmptyView()
            }
        }
    }

    /// Check if we have an interactive visual for this card
    static func hasInteractiveVisual(for visual: CardVisual) -> Bool {
        let t = visual.title
        return t.contains("16 Columns") || t.contains("Ring Foundation") ||
               t.contains("Perfect Sphere") || t.contains("Coffers") ||
               t.contains("Oculus") || t.contains("Limestone vs Marble") ||
               t.contains("Roman vs Modern") || t.contains("Graded Aggregate") ||
               t.contains("Bronze Doors") || t.contains("Centering") ||
               t.contains("Scaffolding") || t.contains("1:3") ||
               t.contains("Calcination") || t.contains("CaCO") ||
               t.contains("Opus Sectile")
    }
}

// MARK: - Local Aliases (point to shared InteractiveVisualHelpers)
private typealias VisualTitle = IVVisualTitle
private typealias PantheonBlueprintGrid = IVBlueprintGrid
private typealias TeachingContainer = IVTeachingContainer
private typealias StepControls = IVStepControls
private typealias DimLabel = IVDimLabel
private typealias FormulaText = IVFormulaText
private typealias DimLine = IVDimLine

// MARK: - 1. Columns — 16 × 12m × 60t = 960 tons

private struct ColumnsCountVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    private var label: String {
        switch step {
        case 1: return "A portico of granite columns guards the entrance."
        case 2: return "Each column: 12m tall, 1.5m diameter — quarried in Egypt."
        case 3: return "Each column carries 60 tons of the portico roof."
        default: return "16 × 60 = 960 tons. The portico alone outweighs most buildings."
        }
    }
    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 4, step: $step, stepLabel: label, height: height) {
            GeometryReader { geo in
                let w = geo.size.width; let h = geo.size.height
                let baseY = h * 0.85; let topY = h * 0.12
                let colW: CGFloat = 10; let colCount = 8
                let spacing = (w - 60) / CGFloat(colCount - 1)
                let startX: CGFloat = 30

                ZStack {
                    // Pediment
                    Path { p in
                        p.move(to: CGPoint(x: w / 2, y: topY - 15))
                        p.addLine(to: CGPoint(x: startX - 10, y: topY))
                        p.addLine(to: CGPoint(x: startX + spacing * CGFloat(colCount - 1) + 10, y: topY))
                        p.closeSubpath()
                    }
                    .fill(color.opacity(0.06))
                    .stroke(IVMaterialColors.sepiaInk.opacity(0.3), lineWidth: 1)

                    // Entablature
                    Rectangle()
                        .fill(IVMaterialColors.sepiaInk.opacity(0.08))
                        .frame(width: w - 40, height: 5)
                        .position(x: w / 2, y: topY + 2)

                    // Columns
                    ForEach(0..<colCount, id: \.self) { i in
                        let cx = startX + spacing * CGFloat(i)
                        Rectangle()
                            .fill(IVMaterialColors.sepiaInk.opacity(0.08))
                            .overlay(Rectangle().stroke(IVMaterialColors.sepiaInk.opacity(0.4), lineWidth: 1))
                            .frame(width: colW, height: baseY - topY - 6)
                            .position(x: cx, y: (topY + 6 + baseY) / 2)
                    }

                    // Floor
                    Path { p in
                        p.move(to: CGPoint(x: 10, y: baseY))
                        p.addLine(to: CGPoint(x: w - 10, y: baseY))
                    }
                    .stroke(IVMaterialColors.sepiaInk.opacity(0.3), lineWidth: 1.5)

                    // Step 2: dimension lines
                    if step >= 2 {
                        let dimX = startX + spacing * CGFloat(colCount - 1) + 20
                        DimLine(from: CGPoint(x: dimX, y: topY + 6), to: CGPoint(x: dimX, y: baseY))
                            .stroke(IVMaterialColors.dimColor, lineWidth: 1)
                        DimLabel(text: "12m")
                            .position(x: dimX + 16, y: (topY + 6 + baseY) / 2)

                        DimLine(from: CGPoint(x: startX - colW / 2, y: baseY + 8),
                                to: CGPoint(x: startX + colW / 2, y: baseY + 8))
                            .stroke(IVMaterialColors.dimColor, lineWidth: 1)
                        DimLabel(text: "1.5m")
                            .position(x: startX, y: baseY + 18)
                    }

                    // Step 3: force arrows + weight
                    if step >= 3 {
                        ForEach(0..<colCount, id: \.self) { i in
                            let cx = startX + spacing * CGFloat(i)
                            Image(systemName: "arrow.down")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(Color.red.opacity(0.5))
                                .position(x: cx, y: topY + 14)
                        }
                        Text("60t each")
                            .font(RenaissanceFont.ivLabel)
                            .foregroundStyle(Color.red.opacity(0.6))
                            .position(x: w / 2, y: topY + 24)
                    }

                    // Step 4: formula
                    if step >= 4 {
                        FormulaText(text: "16 × 60t = 960 tons", highlighted: true)
                            .position(x: w / 2, y: baseY - 12)
                    }
                }
            }
        }
    }
}

// MARK: - 2. Foundation — 4.5m deep, 7.3m wide ring

private struct LayerDigVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    private var label: String {
        switch step {
        case 1: return "Construction begins at ground level."
        case 2: return "Dig a circular trench 4.5m deep into soft Roman clay."
        case 3: return "Fill with a 7.3m wide concrete ring — the hidden foundation."
        default: return "The ring distributes the dome's weight evenly into the earth."
        }
    }
    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 4, step: $step, stepLabel: label, height: height) {
            GeometryReader { geo in
                let w = geo.size.width; let h = geo.size.height
                let groundY = h * 0.25
                let trenchBottom = h * 0.78
                let ringW = w * 0.55
                let ringH: CGFloat = 20

                ZStack {
                    // Ground surface
                    Path { p in
                        p.move(to: CGPoint(x: 10, y: groundY))
                        p.addLine(to: CGPoint(x: w - 10, y: groundY))
                    }
                    .stroke(Color.brown.opacity(0.5), lineWidth: 2)
                    Text("Ground level")
                        .font(RenaissanceFont.ivBody.italic())
                        .foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.4))
                        .position(x: w * 0.8, y: groundY - 8)

                    // Step 2: trench
                    if step >= 2 {
                        // Trench walls
                        let trenchL = (w - ringW) / 2
                        let trenchR = trenchL + ringW
                        Path { p in
                            p.move(to: CGPoint(x: trenchL, y: groundY))
                            p.addLine(to: CGPoint(x: trenchL, y: trenchBottom))
                            p.addLine(to: CGPoint(x: trenchR, y: trenchBottom))
                            p.addLine(to: CGPoint(x: trenchR, y: groundY))
                        }
                        .stroke(IVMaterialColors.sepiaInk.opacity(0.4), lineWidth: 1.5)

                        // Clay fill
                        Rectangle()
                            .fill(Color(red: 0.7, green: 0.55, blue: 0.35).opacity(0.15))
                            .frame(width: ringW, height: trenchBottom - groundY)
                            .position(x: w / 2, y: (groundY + trenchBottom) / 2)

                        Text("Soft clay")
                            .font(RenaissanceFont.ivBody.italic())
                            .foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.4))
                            .position(x: w / 2, y: (groundY + trenchBottom) / 2)

                        // Depth dimension
                        DimLine(from: CGPoint(x: w - 20, y: groundY), to: CGPoint(x: w - 20, y: trenchBottom))
                            .stroke(IVMaterialColors.dimColor, lineWidth: 1)
                        DimLabel(text: "4.5m")
                            .position(x: w - 8, y: (groundY + trenchBottom) / 2)
                    }

                    // Step 3: concrete ring
                    if step >= 3 {
                        let trenchL = (w - ringW) / 2
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.gray.opacity(0.35))
                            .overlay(RoundedRectangle(cornerRadius: 3).stroke(IVMaterialColors.sepiaInk.opacity(0.5), lineWidth: 1.5))
                            .frame(width: ringW, height: ringH)
                            .position(x: w / 2, y: trenchBottom - ringH / 2)

                        Text("Concrete ring")
                            .font(RenaissanceFont.ivLabel)
                            .foregroundStyle(.white)
                            .shadow(color: .black.opacity(0.5), radius: 1)
                            .position(x: w / 2, y: trenchBottom - ringH / 2)

                        // Width dimension
                        DimLine(from: CGPoint(x: trenchL, y: trenchBottom + 8),
                                to: CGPoint(x: trenchL + ringW, y: trenchBottom + 8))
                            .stroke(IVMaterialColors.dimColor, lineWidth: 1)
                        DimLabel(text: "7.3m")
                            .position(x: w / 2, y: trenchBottom + 18)
                    }

                    // Step 4: load arrows
                    if step >= 4 {
                        ForEach([0.3, 0.4, 0.5, 0.6, 0.7], id: \.self) { frac in
                            Image(systemName: "arrow.down")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(Color.red.opacity(0.4))
                                .position(x: w * frac, y: groundY - 16)
                        }
                        Text("Dome weight distributed →")
                            .font(RenaissanceFont.ivBody.italic())
                            .foregroundStyle(Color.red.opacity(0.5))
                            .position(x: w / 2, y: groundY - 26)
                    }
                }
            }
        }
    }
}

// MARK: - 3. Rotunda — Height = Diameter = 43.3m, sphere fits inside

private struct SphereSliderVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    private var label: String {
        switch step {
        case 1: return "The rotunda walls define the cylinder: 43.3m tall."
        case 2: return "The diameter is also 43.3m — height equals width."
        case 3: return "Because height = diameter, a perfect sphere fits exactly inside."
        default: return "6m-thick walls contain hidden arches channeling weight to 8 piers."
        }
    }
    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 4, step: $step, stepLabel: label, height: height) {
            GeometryReader { geo in
                let w = geo.size.width; let h = geo.size.height
                let cx = w / 2
                let baseY = h * 0.88
                let wallW: CGFloat = 16
                let innerW = w * 0.52
                let wallH = h * 0.72

                ZStack {
                    // Floor
                    Path { p in
                        p.move(to: CGPoint(x: cx - innerW / 2 - wallW - 5, y: baseY))
                        p.addLine(to: CGPoint(x: cx + innerW / 2 + wallW + 5, y: baseY))
                    }
                    .stroke(IVMaterialColors.sepiaInk.opacity(0.3), lineWidth: 1.5)

                    // Left wall
                    Rectangle()
                        .fill(color.opacity(0.12))
                        .overlay(Rectangle().stroke(IVMaterialColors.sepiaInk.opacity(0.4), lineWidth: 1.5))
                        .frame(width: wallW, height: wallH)
                        .position(x: cx - innerW / 2 - wallW / 2, y: baseY - wallH / 2)

                    // Right wall
                    Rectangle()
                        .fill(color.opacity(0.12))
                        .overlay(Rectangle().stroke(IVMaterialColors.sepiaInk.opacity(0.4), lineWidth: 1.5))
                        .frame(width: wallW, height: wallH)
                        .position(x: cx + innerW / 2 + wallW / 2, y: baseY - wallH / 2)

                    // Dome arc
                    Path { p in
                        p.addArc(center: CGPoint(x: cx, y: baseY),
                                 radius: innerW / 2 + wallW,
                                 startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
                    }
                    .stroke(IVMaterialColors.sepiaInk.opacity(0.4), lineWidth: 1.5)

                    // Step 1: height dimension
                    if step >= 1 {
                        let dimX = cx + innerW / 2 + wallW + 14
                        DimLine(from: CGPoint(x: dimX, y: baseY), to: CGPoint(x: dimX, y: baseY - wallH))
                            .stroke(IVMaterialColors.dimColor, lineWidth: 1)
                        DimLabel(text: "43.3m")
                            .position(x: dimX + 18, y: baseY - wallH / 2)
                    }

                    // Step 2: diameter dimension + formula
                    if step >= 2 {
                        DimLine(from: CGPoint(x: cx - innerW / 2, y: baseY + 8),
                                to: CGPoint(x: cx + innerW / 2, y: baseY + 8))
                            .stroke(IVMaterialColors.dimColor, lineWidth: 1)
                        DimLabel(text: "43.3m")
                            .position(x: cx, y: baseY + 18)

                        FormulaText(text: "Height = Diameter = 43.3m")
                            .position(x: cx, y: baseY - wallH - 8)
                    }

                    // Step 3: inscribed sphere (dashed circle)
                    if step >= 3 {
                        let sphereR = innerW / 2
                        Circle()
                            .stroke(color.opacity(0.4), style: StrokeStyle(lineWidth: 1.5, dash: [5, 3]))
                            .frame(width: sphereR * 2, height: sphereR * 2)
                            .position(x: cx, y: baseY - sphereR)

                        Text("Perfect sphere")
                            .font(RenaissanceFont.ivBody.italic())
                            .foregroundStyle(color)
                            .position(x: cx, y: baseY - sphereR)
                    }

                    // Step 4: wall thickness dimensions
                    if step >= 4 {
                        // Left wall thickness
                        let lwLeft = cx - innerW / 2 - wallW
                        let lwRight = cx - innerW / 2
                        let dimY = baseY - wallH * 0.15
                        DimLine(from: CGPoint(x: lwLeft, y: dimY), to: CGPoint(x: lwRight, y: dimY))
                            .stroke(IVMaterialColors.dimColor, lineWidth: 1)
                        DimLabel(text: "6m")
                            .position(x: (lwLeft + lwRight) / 2, y: dimY - 8)

                        // Right wall thickness
                        let rwLeft = cx + innerW / 2
                        let rwRight = cx + innerW / 2 + wallW
                        DimLine(from: CGPoint(x: rwLeft, y: dimY), to: CGPoint(x: rwRight, y: dimY))
                            .stroke(IVMaterialColors.dimColor, lineWidth: 1)
                        DimLabel(text: "6m")
                            .position(x: (rwLeft + rwRight) / 2, y: dimY - 8)

                        FormulaText(text: "Height = Diameter ∴ sphere fits", highlighted: true)
                            .position(x: cx, y: baseY - wallH - 8)
                    }
                }
            }
        }
    }
}

// MARK: - 4. Coffers — 2,400/4,535 = 53% weight reduction

private struct CofferTapVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    private var label: String {
        switch step {
        case 1: return "The dome, if solid, would weigh 4,535 tons."
        case 2: return "28 rows of coffers remove 2,400 tons of concrete."
        case 3: return "That's 53% weight reduction — 2,135 tons remaining."
        default: return "Lighter dome = less outward thrust. Decoration that is engineering."
        }
    }
    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 4, step: $step, stepLabel: label, height: height) {
            GeometryReader { geo in
                let w = geo.size.width; let h = geo.size.height
                let cx = w / 2; let baseY = h * 0.85
                let domeR = min(w * 0.38, h * 0.72)

                ZStack {
                    // Base line
                    Path { p in
                        p.move(to: CGPoint(x: cx - domeR - 10, y: baseY))
                        p.addLine(to: CGPoint(x: cx + domeR + 10, y: baseY))
                    }
                    .stroke(IVMaterialColors.sepiaInk.opacity(0.3), lineWidth: 1.5)

                    // Solid dome (step 1)
                    Path { p in
                        p.addArc(center: CGPoint(x: cx, y: baseY),
                                 radius: domeR,
                                 startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
                        p.closeSubpath()
                    }
                    .fill(color.opacity(step == 1 ? 0.2 : 0.08))
                    .overlay(
                        Path { p in
                            p.addArc(center: CGPoint(x: cx, y: baseY),
                                     radius: domeR,
                                     startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
                        }
                        .stroke(IVMaterialColors.sepiaInk.opacity(0.4), lineWidth: 1.5)
                    )

                    // Weight label
                    if step == 1 {
                        FormulaText(text: "4,535 tons", fontSize: 16)
                            .position(x: cx, y: baseY - domeR * 0.45)
                    }

                    // Step 2+: coffer rows visible
                    if step >= 2 {
                        // Inner dome (thinned)
                        Path { p in
                            p.addArc(center: CGPoint(x: cx, y: baseY),
                                     radius: domeR * 0.8,
                                     startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
                            p.closeSubpath()
                        }
                        .fill(RenaissanceColors.parchment)

                        // Coffer row indicators
                        ForEach(0..<5, id: \.self) { row in
                            let angle = 160.0 - Double(row) * 30.0
                            let midR = (domeR + domeR * 0.8) / 2
                            let rad = angle * .pi / 180
                            let px = cx + midR * cos(rad)
                            let py = baseY + midR * sin(rad)
                            Rectangle()
                                .fill(color.opacity(0.15))
                                .frame(width: 12, height: 8)
                                .overlay(Rectangle().stroke(color.opacity(0.3), lineWidth: 0.5))
                                .position(x: px, y: py)
                        }

                        Text("−2,400t")
                            .font(RenaissanceFont.ivFormula)
                            .foregroundStyle(color)
                            .position(x: cx, y: baseY - domeR * 0.45)
                    }

                    // Step 3: formula
                    if step >= 3 {
                        VStack(spacing: 1) {
                            FormulaText(text: "2,400 ÷ 4,535 = 53%", highlighted: true)
                            Text("Remaining: 2,135 tons")
                                .font(RenaissanceFont.ivLabel)
                                .foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.5))
                        }
                        .position(x: cx, y: baseY - domeR * 0.2)
                    }

                    // Step 4: thrust arrows (smaller)
                    if step >= 4 {
                        ForEach([-1.0, 1.0], id: \.self) { dir in
                            Image(systemName: dir > 0 ? "arrow.right" : "arrow.left")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(RenaissanceColors.sageGreen.opacity(0.6))
                                .position(x: cx + dir * (domeR + 18), y: baseY - 10)
                        }
                        Text("Less thrust!")
                            .font(RenaissanceFont.ivBody.italic())
                            .foregroundStyle(RenaissanceColors.sageGreen)
                            .position(x: cx, y: baseY + 10)
                    }
                }
            }
        }
    }
}

// MARK: - 5. Oculus — 9m compression ring

private struct OculusCompressionVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    private var label: String {
        switch step {
        case 1: return "The oculus is a 9m opening at the dome's crown."
        case 2: return "Without the ring, dome weight pushes outward — spreading the walls."
        case 3: return "The compression ring redirects forces inward around the opening."
        default: return "A hole that makes the dome stronger — the weakest point is the strongest."
        }
    }
    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 4, step: $step, stepLabel: label, height: height) {
            GeometryReader { geo in
                let w = geo.size.width; let h = geo.size.height
                let cx = w / 2; let baseY = h * 0.88
                let domeR = min(w * 0.4, h * 0.78)
                let oculusR: CGFloat = domeR * 0.18

                ZStack {
                    // Dome arc
                    Path { p in
                        p.addArc(center: CGPoint(x: cx, y: baseY),
                                 radius: domeR,
                                 startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
                    }
                    .stroke(IVMaterialColors.sepiaInk.opacity(0.4), lineWidth: 2)

                    // Base
                    Path { p in
                        p.move(to: CGPoint(x: cx - domeR - 5, y: baseY))
                        p.addLine(to: CGPoint(x: cx + domeR + 5, y: baseY))
                    }
                    .stroke(IVMaterialColors.sepiaInk.opacity(0.3), lineWidth: 1.5)

                    // Oculus circle at top
                    let oculusY = baseY - domeR + oculusR * 0.3
                    Circle()
                        .fill(Color.white.opacity(0.7))
                        .frame(width: oculusR * 2, height: oculusR * 2)
                        .overlay(Circle().stroke(IVMaterialColors.sepiaInk.opacity(0.5), lineWidth: 2))
                        .position(x: cx, y: oculusY)

                    // Step 1: 9m dimension
                    DimLine(from: CGPoint(x: cx - oculusR, y: oculusY - oculusR - 6),
                            to: CGPoint(x: cx + oculusR, y: oculusY - oculusR - 6))
                        .stroke(IVMaterialColors.dimColor, lineWidth: 1)
                    DimLabel(text: "9m")
                        .position(x: cx, y: oculusY - oculusR - 14)

                    // Step 2: outward thrust arrows
                    if step >= 2 {
                        ForEach([150.0, 120.0, 60.0, 30.0], id: \.self) { deg in
                            let rad = deg * .pi / 180
                            let ax = cx - domeR * 0.6 * cos(rad)
                            let ay = baseY - domeR * 0.6 * sin(rad)
                            Image(systemName: deg > 90 ? "arrow.left" : "arrow.right")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(Color.red.opacity(0.5))
                                .position(x: ax + (deg > 90 ? -10 : 10), y: ay)
                        }
                        Text("Outward thrust")
                            .font(RenaissanceFont.ivBody.italic())
                            .foregroundStyle(Color.red.opacity(0.5))
                            .position(x: cx, y: baseY - domeR * 0.3)
                    }

                    // Step 3: inward compression arrows
                    if step >= 3 {
                        ForEach(0..<8, id: \.self) { i in
                            let angle = Double(i) / 8.0 * 2.0 * .pi - .pi / 2
                            let arrowR = oculusR * 2.2
                            let ax = cx + arrowR * cos(angle)
                            let ay = oculusY + arrowR * sin(angle)
                            Image(systemName: "arrow.right")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(Color.orange.opacity(0.7))
                                .rotationEffect(.radians(angle + .pi))
                                .position(x: ax, y: ay)
                        }
                        Text("Compression →")
                            .font(RenaissanceFont.ivLabel)
                            .foregroundStyle(Color.orange)
                            .position(x: cx + oculusR * 3, y: oculusY)
                    }

                    // Step 4: highlighted formula
                    if step >= 4 {
                        FormulaText(text: "Hole = stronger dome", highlighted: true)
                            .position(x: cx, y: baseY - domeR * 0.35)
                    }
                }
            }
        }
    }
}

// MARK: - 6. Limestone vs Marble — CaCO₃ same formula, different structure

private struct HeatTransformVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    private var label: String {
        switch step {
        case 1: return "Limestone: sedimentary rock. Chemical formula: CaCO₃."
        case 2: return "Underground heat (900°C) and pressure begin transformation."
        case 3: return "Random grains recrystallize into aligned, interlocking crystals."
        default: return "Marble: same CaCO₃, but metamorphic. Same formula, different rock."
        }
    }
    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 4, step: $step, stepLabel: label, height: height) {
            GeometryReader { geo in
                let w = geo.size.width; let h = geo.size.height
                let blockSize: CGFloat = min(w * 0.22, h * 0.45)
                let leftX = w * 0.22; let rightX = w * 0.78
                let centerY = h * 0.45

                ZStack {
                    // Left block: Limestone
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(red: 0.75, green: 0.72, blue: 0.65))
                        .frame(width: blockSize, height: blockSize)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(IVMaterialColors.sepiaInk.opacity(0.4), lineWidth: 1.5)
                        )
                        .overlay(
                            // Random grain dots
                            ZStack {
                                ForEach(0..<8, id: \.self) { i in
                                    Circle()
                                        .fill(IVMaterialColors.sepiaInk.opacity(0.12))
                                        .frame(width: 4, height: 4)
                                        .offset(x: CGFloat([-10, 8, -5, 12, -8, 3, 10, -12][i]),
                                                y: CGFloat([5, -8, 10, -3, -10, 8, 2, -5][i]))
                                }
                            }
                        )
                        .position(x: leftX, y: centerY)

                    Text("Limestone")
                        .font(RenaissanceFont.ivLabel)
                        .foregroundStyle(IVMaterialColors.sepiaInk)
                        .position(x: leftX, y: centerY + blockSize / 2 + 12)

                    FormulaText(text: "CaCO₃")
                        .position(x: leftX, y: centerY + blockSize / 2 + 24)

                    // Step 2+: heat + pressure arrows + temperature
                    if step >= 2 {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(RenaissanceColors.furnaceOrange)
                            .position(x: w / 2, y: centerY)

                        Text("900°C")
                            .font(RenaissanceFont.ivFormula)
                            .foregroundStyle(RenaissanceColors.furnaceOrange)
                            .position(x: w / 2, y: centerY - 14)

                        Text("+ pressure")
                            .font(RenaissanceFont.ivBody.italic())
                            .foregroundStyle(RenaissanceColors.furnaceOrange.opacity(0.7))
                            .position(x: w / 2, y: centerY + 14)
                    }

                    // Step 3+: crystal change visualization
                    if step >= 3 {
                        // Arrow showing grain transformation
                        VStack(spacing: 2) {
                            Text("Random → Aligned")
                                .font(RenaissanceFont.ivBody.italic())
                                .foregroundStyle(color)
                        }
                        .position(x: w / 2, y: h * 0.82)
                    }

                    // Step 3+: right block (marble)
                    if step >= 3 {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color(red: 0.92, green: 0.90, blue: 0.87))
                            .frame(width: blockSize, height: blockSize)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(IVMaterialColors.sepiaInk.opacity(0.4), lineWidth: 1.5)
                            )
                            .overlay(
                                // Aligned crystal lines
                                ZStack {
                                    ForEach(0..<5, id: \.self) { i in
                                        Rectangle()
                                            .fill(IVMaterialColors.sepiaInk.opacity(0.06))
                                            .frame(width: blockSize * 0.7, height: 1)
                                            .rotationEffect(.degrees(Double(i) * 36))
                                    }
                                }
                            )
                            .position(x: rightX, y: centerY)

                        Text("Marble")
                            .font(RenaissanceFont.ivLabel)
                            .foregroundStyle(IVMaterialColors.sepiaInk)
                            .position(x: rightX, y: centerY + blockSize / 2 + 12)

                        FormulaText(text: "CaCO₃")
                            .position(x: rightX, y: centerY + blockSize / 2 + 24)
                    }

                    // Step 4: highlighted formula
                    if step >= 4 {
                        FormulaText(text: "Same CaCO₃ — different structure", highlighted: true)
                            .position(x: w / 2, y: h * 0.1)
                    }
                }
            }
        }
    }
}

// MARK: - 7. Roman vs Modern Concrete — Ca(OH)₂ + SiO₂ → CaSiO₃

private struct TimelineAgingVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    @State private var yearSlider: CGFloat = 0
    private var label: String {
        switch step {
        case 1: return "Two concrete blocks, fresh from the mixer."
        case 2: return "Roman concrete uses pozzolanic reaction: Ca(OH)₂ + SiO₂ → CaSiO₃."
        case 3: return "Drag the slider. At 100 years: modern cracks, Roman holds."
        default: return "At 2,000 years: modern gone. Roman is stronger than day one."
        }
    }
    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 4, step: $step, stepLabel: label, height: height) {
            VStack(spacing: 6) {
                // Formula (step 2+)
                if step >= 2 {
                    Text("Ca(OH)₂ + SiO₂ → CaSiO₃")
                        .font(.custom("EBGaramond-Bold", size: step >= 4 ? 13 : 12))
                        .foregroundStyle(step >= 4 ? RenaissanceColors.sageGreen : IVMaterialColors.sepiaInk)
                }

                // Two blocks
                HStack(spacing: 20) {
                    // Roman
                    VStack(spacing: 4) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color(red: 0.6, green: 0.55, blue: 0.5)
                                    .opacity(0.5 + (step >= 3 ? yearSlider * 0.5 : 0)))
                                .frame(width: 70, height: 55)
                                .overlay(RoundedRectangle(cornerRadius: 6).stroke(IVMaterialColors.sepiaInk.opacity(0.3), lineWidth: 1))
                        }
                        Text("Roman")
                            .font(RenaissanceFont.ivLabel)
                            .foregroundStyle(IVMaterialColors.sepiaInk)
                        if step >= 3 {
                            Text(yearSlider > 0.5 ? "STRONGER" : "Pozzolana + lime")
                                .font(RenaissanceFont.ivBody.italic())
                                .foregroundStyle(yearSlider > 0.5 ? RenaissanceColors.sageGreen : IVMaterialColors.sepiaInk.opacity(0.5))
                        }
                    }

                    // Modern
                    VStack(spacing: 4) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.gray.opacity(max(0.1, 0.5 - (step >= 3 ? yearSlider * 0.4 : 0))))
                                .frame(width: 70, height: 55)
                                .overlay(RoundedRectangle(cornerRadius: 6).stroke(IVMaterialColors.sepiaInk.opacity(0.3), lineWidth: 1))

                            if step >= 3 && yearSlider > 0.05 {
                                Path { p in
                                    p.move(to: CGPoint(x: 15, y: 10))
                                    p.addLine(to: CGPoint(x: 35, y: 28))
                                    p.addLine(to: CGPoint(x: 25, y: 45))
                                }
                                .stroke(Color.red.opacity(min(1, yearSlider)), lineWidth: 1.5)
                                .frame(width: 70, height: 55)
                            }
                        }
                        Text("Modern")
                            .font(RenaissanceFont.ivLabel)
                            .foregroundStyle(IVMaterialColors.sepiaInk)
                        if step >= 3 {
                            Text(yearSlider > 0.5 ? "CRACKING" : "Portland cement")
                                .font(RenaissanceFont.ivBody.italic())
                                .foregroundStyle(yearSlider > 0.5 ? Color.red.opacity(0.7) : IVMaterialColors.sepiaInk.opacity(0.5))
                        }
                    }
                }

                // Year slider (step 3+)
                if step >= 3 {
                    VStack(spacing: 2) {
                        HStack {
                            Text("Year 0").font(RenaissanceFont.ivBody).foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.4))
                            Spacer()
                            DimLabel(text: "\(Int(yearSlider * 2000)) years")
                            Spacer()
                            Text("2,000").font(RenaissanceFont.ivBody).foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.4))
                        }
                        Slider(value: $yearSlider, in: 0...1).tint(color)
                    }
                }
            }
        }
    }
}

// MARK: - 8. Dome Layers — density 2,400 → 1,350 kg/m³

private struct PourRingsVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    private let rings: [(name: String, density: String, c: Color)] = [
        ("Basalt",       "2,400 kg/m³", Color(red: 0.40, green: 0.35, blue: 0.30)),
        ("Tufa",         "2,000 kg/m³", Color(red: 0.50, green: 0.45, blue: 0.38)),
        ("Tufa",         "1,750 kg/m³", Color(red: 0.60, green: 0.55, blue: 0.45)),
        ("Tufa+brick",   "1,500 kg/m³", Color(red: 0.72, green: 0.65, blue: 0.52)),
        ("Pumice",       "1,350 kg/m³", Color(red: 0.85, green: 0.78, blue: 0.65)),
    ]
    private var label: String {
        switch step {
        case 1: return "The dome is 21.65m tall, poured in 5 layers bottom to top."
        case 2: return "Ring 1: basalt at 2,400 kg/m³ — heaviest at the base."
        case 3: return "Rings 2-3: tufa at 2,000 and 1,750 kg/m³ — progressively lighter."
        default: return "Rings 4-5: pumice at 1,350 kg/m³. Heavy base, light top = stable dome."
        }
    }
    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 4, step: $step, stepLabel: label, height: height) {
            GeometryReader { geo in
                let w = geo.size.width; let h = geo.size.height
                let cx = w / 2; let baseY = h * 0.88
                let domeR = min(w * 0.38, h * 0.78)

                ZStack {
                    // Base
                    Path { p in
                        p.move(to: CGPoint(x: cx - domeR - 10, y: baseY))
                        p.addLine(to: CGPoint(x: cx + domeR + 10, y: baseY))
                    }
                    .stroke(IVMaterialColors.sepiaInk.opacity(0.3), lineWidth: 1.5)

                    // Dome outline (dashed)
                    Path { p in
                        p.addArc(center: CGPoint(x: cx, y: baseY), radius: domeR,
                                 startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
                    }
                    .stroke(IVMaterialColors.sepiaInk.opacity(0.1), style: StrokeStyle(lineWidth: 1, dash: [4, 3]))

                    // Height dimension
                    DimLine(from: CGPoint(x: cx + domeR + 12, y: baseY),
                            to: CGPoint(x: cx + domeR + 12, y: baseY - domeR))
                        .stroke(IVMaterialColors.dimColor, lineWidth: 1)
                    DimLabel(text: "21.65m")
                        .position(x: cx + domeR + 30, y: baseY - domeR / 2)

                    // Rings based on step
                    let visibleRings = step == 1 ? 0 : step == 2 ? 1 : step == 3 ? 3 : 5
                    ForEach(0..<visibleRings, id: \.self) { i in
                        let startDeg = 180.0 - Double(i) * 36.0
                        let endDeg = 180.0 - Double(i + 1) * 36.0
                        let outerR = domeR; let innerR = domeR * 0.82

                        Path { p in
                            p.addArc(center: CGPoint(x: cx, y: baseY), radius: outerR,
                                     startAngle: .degrees(startDeg), endAngle: .degrees(endDeg), clockwise: true)
                            p.addArc(center: CGPoint(x: cx, y: baseY), radius: innerR,
                                     startAngle: .degrees(endDeg), endAngle: .degrees(startDeg), clockwise: false)
                            p.closeSubpath()
                        }
                        .fill(rings[i].c.opacity(0.45))
                        .overlay(
                            Path { p in
                                p.addArc(center: CGPoint(x: cx, y: baseY), radius: outerR,
                                         startAngle: .degrees(startDeg), endAngle: .degrees(endDeg), clockwise: true)
                                p.addArc(center: CGPoint(x: cx, y: baseY), radius: innerR,
                                         startAngle: .degrees(endDeg), endAngle: .degrees(startDeg), clockwise: false)
                                p.closeSubpath()
                            }
                            .stroke(IVMaterialColors.sepiaInk.opacity(0.25), lineWidth: 0.5)
                        )

                        // Density label
                        let midDeg = (startDeg + endDeg) / 2.0
                        let labelR = (outerR + innerR) / 2
                        let lx = cx + labelR * cos(midDeg * .pi / 180)
                        let ly = baseY + labelR * sin(midDeg * .pi / 180)
                        Text(rings[i].density)
                            .font(RenaissanceFont.ivLabel)
                            .foregroundStyle(.white)
                            .shadow(color: .black.opacity(0.6), radius: 1)
                            .position(x: lx, y: ly)
                    }

                    // Step 4: gradient formula
                    if step >= 4 {
                        FormulaText(text: "2,400 → 1,350 kg/m³", highlighted: true)
                            .position(x: cx, y: baseY - domeR * 0.4)
                    }
                }
            }
        }
    }
}

// MARK: - 9. Bronze Doors — 7m tall, top-down pivot view

private struct DoorSwingVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    @State private var doorSlider: CGFloat = 0
    private var label: String {
        switch step {
        case 1: return "Each bronze door stands 7 meters tall."
        case 2: return "Bronze cylinder bearings at top and bottom — the pivot mechanism."
        case 3: return "Top-down view: drag to swing. Torque = Force × Distance."
        default: return "Still swinging on original pivots after 2,000 years."
        }
    }
    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 4, step: $step, stepLabel: label, height: height) {
            GeometryReader { geo in
                let w = geo.size.width; let h = geo.size.height
                let cx = w / 2

                ZStack {
                    if step <= 2 {
                        // FRONT ELEVATION (steps 1-2)
                        let floorY = h * 0.85; let doorH = h * 0.55; let doorW = w * 0.14

                        // Stone arch frame
                        Path { p in
                            let archR = doorW + 10
                            p.addArc(center: CGPoint(x: cx, y: floorY - doorH),
                                     radius: archR,
                                     startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
                        }
                        .stroke(IVMaterialColors.sepiaInk.opacity(0.3), lineWidth: 2)

                        // Left door
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color(red: 0.6, green: 0.45, blue: 0.25).opacity(0.35))
                            .overlay(RoundedRectangle(cornerRadius: 2).stroke(IVMaterialColors.sepiaInk.opacity(0.5), lineWidth: 1.5))
                            .frame(width: doorW, height: doorH)
                            .position(x: cx - doorW / 2 - 2, y: floorY - doorH / 2)

                        // Right door
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color(red: 0.6, green: 0.45, blue: 0.25).opacity(0.35))
                            .overlay(RoundedRectangle(cornerRadius: 2).stroke(IVMaterialColors.sepiaInk.opacity(0.5), lineWidth: 1.5))
                            .frame(width: doorW, height: doorH)
                            .position(x: cx + doorW / 2 + 2, y: floorY - doorH / 2)

                        // Floor
                        Path { p in
                            p.move(to: CGPoint(x: cx - doorW * 2, y: floorY))
                            p.addLine(to: CGPoint(x: cx + doorW * 2, y: floorY))
                        }
                        .stroke(IVMaterialColors.sepiaInk.opacity(0.3), lineWidth: 1.5)

                        // 7m dimension
                        let dimX = cx + doorW + 16
                        DimLine(from: CGPoint(x: dimX, y: floorY), to: CGPoint(x: dimX, y: floorY - doorH))
                            .stroke(IVMaterialColors.dimColor, lineWidth: 1)
                        DimLabel(text: "7m")
                            .position(x: dimX + 14, y: floorY - doorH / 2)

                        // Step 2: pivot circles
                        if step >= 2 {
                            let pivotColor = Color(red: 0.7, green: 0.55, blue: 0.3)
                            ForEach([floorY - doorH, floorY], id: \.self) { py in
                                Circle().fill(pivotColor).frame(width: 8, height: 8)
                                    .position(x: cx - doorW - 2, y: py)
                                Circle().fill(pivotColor).frame(width: 8, height: 8)
                                    .position(x: cx + doorW + 2, y: py)
                            }
                            Text("Bronze pivots")
                                .font(RenaissanceFont.ivBody.italic())
                                .foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.5))
                                .position(x: cx - doorW - 30, y: floorY - doorH / 2)
                        }
                    } else {
                        // TOP-DOWN PLAN VIEW (steps 3-4)
                        let planY = h * 0.4
                        let wallThickness: CGFloat = 12
                        let doorLen = w * 0.2
                        let wallSpan = w * 0.7

                        // Wall (top-down)
                        Rectangle()
                            .fill(IVMaterialColors.sepiaInk.opacity(0.12))
                            .frame(width: wallSpan, height: wallThickness)
                            .overlay(Rectangle().stroke(IVMaterialColors.sepiaInk.opacity(0.3), lineWidth: 1))
                            .position(x: cx, y: planY)

                        // Opening in wall
                        Rectangle()
                            .fill(RenaissanceColors.parchment)
                            .frame(width: doorLen * 2 + 8, height: wallThickness + 2)
                            .position(x: cx, y: planY)

                        Text("PLAN VIEW (top-down)")
                            .font(RenaissanceFont.ivBody.italic())
                            .foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.3))
                            .position(x: cx, y: h * 0.08)

                        // Left door (rotates from left hinge)
                        let leftHingeX = cx - doorLen - 4
                        let angleRad = Double(doorSlider) * .pi / 2
                        let leftEndX = leftHingeX + doorLen * cos(angleRad)
                        let leftEndY = planY + doorLen * sin(angleRad)

                        Path { p in
                            p.move(to: CGPoint(x: leftHingeX, y: planY))
                            p.addLine(to: CGPoint(x: leftEndX, y: leftEndY))
                        }
                        .stroke(Color(red: 0.6, green: 0.45, blue: 0.25), lineWidth: 4)

                        // Right door (rotates from right hinge)
                        let rightHingeX = cx + doorLen + 4
                        let rightEndX = rightHingeX - doorLen * cos(angleRad)
                        let rightEndY = planY + doorLen * sin(angleRad)

                        Path { p in
                            p.move(to: CGPoint(x: rightHingeX, y: planY))
                            p.addLine(to: CGPoint(x: rightEndX, y: rightEndY))
                        }
                        .stroke(Color(red: 0.6, green: 0.45, blue: 0.25), lineWidth: 4)

                        // Pivot dots
                        Circle().fill(Color(red: 0.7, green: 0.55, blue: 0.3)).frame(width: 8, height: 8)
                            .position(x: leftHingeX, y: planY)
                        Circle().fill(Color(red: 0.7, green: 0.55, blue: 0.3)).frame(width: 8, height: 8)
                            .position(x: rightHingeX, y: planY)

                        // Angle label
                        Text("\(Int(doorSlider * 90))°")
                            .font(RenaissanceFont.ivFormula)
                            .foregroundStyle(color)
                            .position(x: cx, y: planY + 30)

                        // Slider
                        VStack(spacing: 2) {
                            Slider(value: $doorSlider, in: 0...1).tint(color)
                            HStack {
                                Text("Closed").font(RenaissanceFont.ivBody).foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.4))
                                Spacer()
                                Text("Open").font(RenaissanceFont.ivBody).foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.4))
                            }
                        }
                        .position(x: cx, y: h * 0.78)
                        .frame(width: w * 0.7)

                        // Formula
                        FormulaText(text: step >= 4 ? "2,000 years on original pivots" : "Torque = Force × Distance",
                                    highlighted: step >= 4)
                            .position(x: cx, y: h * 0.93)
                    }
                }
            }
        }
    }
}

// MARK: - 10. Centering — 4,535 tons load, 3 weeks cure

private struct CenteringBuildVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    private var label: String {
        switch step {
        case 1: return "An arch cannot support itself until complete — needs temporary support."
        case 2: return "Oak centering: curved wooden frame holds the arch shape."
        case 3: return "Wet concrete presses down with 4,535 tons. Must cure 3 weeks."
        default: return "Remove the centering — arch stands through compression alone."
        }
    }
    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 4, step: $step, stepLabel: label, height: height) {
            GeometryReader { geo in
                let w = geo.size.width; let h = geo.size.height
                let cx = w / 2; let baseY = h * 0.8
                let archR = min(w * 0.35, baseY - 15)

                ZStack {
                    // Floor
                    Path { p in
                        p.move(to: CGPoint(x: cx - archR - 15, y: baseY))
                        p.addLine(to: CGPoint(x: cx + archR + 15, y: baseY))
                    }
                    .stroke(IVMaterialColors.sepiaInk.opacity(0.3), lineWidth: 1.5)

                    // Support walls
                    Rectangle()
                        .fill(IVMaterialColors.sepiaInk.opacity(0.1))
                        .overlay(Rectangle().stroke(IVMaterialColors.sepiaInk.opacity(0.3), lineWidth: 1))
                        .frame(width: 12, height: archR * 0.5)
                        .position(x: cx - archR - 6, y: baseY - archR * 0.25)
                    Rectangle()
                        .fill(IVMaterialColors.sepiaInk.opacity(0.1))
                        .overlay(Rectangle().stroke(IVMaterialColors.sepiaInk.opacity(0.3), lineWidth: 1))
                        .frame(width: 12, height: archR * 0.5)
                        .position(x: cx + archR + 6, y: baseY - archR * 0.25)

                    // Ghost arch (step 1)
                    Path { p in
                        p.addArc(center: CGPoint(x: cx, y: baseY), radius: archR,
                                 startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
                    }
                    .stroke(IVMaterialColors.sepiaInk.opacity(0.1), style: StrokeStyle(lineWidth: 1, dash: [4, 3]))

                    // Step 2: wood centering
                    if step >= 2 && step < 4 {
                        Path { p in
                            p.addArc(center: CGPoint(x: cx, y: baseY), radius: archR * 0.92,
                                     startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
                        }
                        .stroke(Color.brown.opacity(0.7), lineWidth: 4)

                        ForEach(0..<7, id: \.self) { i in
                            let ang = (180.0 - Double(i) * 30.0) * .pi / 180
                            Path { p in
                                p.move(to: CGPoint(x: cx, y: baseY))
                                p.addLine(to: CGPoint(x: cx + archR * 0.92 * cos(ang),
                                                      y: baseY + archR * 0.92 * sin(ang)))
                            }
                            .stroke(Color.brown.opacity(0.4), lineWidth: 1.5)
                        }

                        Text("Oak centering")
                            .font(RenaissanceFont.ivLabel)
                            .foregroundStyle(Color.brown)
                            .position(x: cx, y: baseY - archR * 0.4)
                    }

                    // Step 3: concrete arch + load
                    if step >= 3 {
                        Path { p in
                            p.addArc(center: CGPoint(x: cx, y: baseY), radius: archR,
                                     startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
                            p.addArc(center: CGPoint(x: cx, y: baseY), radius: archR * 0.85,
                                     startAngle: .degrees(0), endAngle: .degrees(180), clockwise: true)
                            p.closeSubpath()
                        }
                        .fill(color.opacity(0.2))
                        .overlay(
                            Path { p in
                                p.addArc(center: CGPoint(x: cx, y: baseY), radius: archR,
                                         startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
                            }
                            .stroke(IVMaterialColors.sepiaInk.opacity(0.5), lineWidth: 2)
                        )

                        if step == 3 {
                            ForEach([50.0, 90.0, 130.0], id: \.self) { deg in
                                let rad = deg * .pi / 180
                                Image(systemName: "arrow.down")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundStyle(Color.red.opacity(0.5))
                                    .position(x: cx - archR * cos(rad), y: baseY - archR * sin(rad) - 10)
                            }
                            DimLabel(text: "4,535 tons")
                                .position(x: cx, y: baseY - archR - 10)
                            DimLabel(text: "3 weeks cure")
                                .position(x: cx, y: baseY - archR * 0.5)
                        }
                    }

                    // Step 4: centering removed
                    if step >= 4 {
                        FormulaText(text: "Self-supporting through compression!", highlighted: true)
                            .position(x: cx, y: baseY - archR * 0.4)
                    }
                }
            }
        }
    }
}

// MARK: - 11. Scaffolding — 43m, 4 tiers

private struct ScaffoldClimbVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    private let heights = ["11m", "22m", "33m", "43m"]
    private var label: String {
        switch step {
        case 1: return "The dome reaches 43 meters — workers need platforms at every level."
        case 2: return "Tier 1: 11m. Poplar wood — grows 3m/year, light and cheap."
        case 3: return "Tiers 2-3: 22m and 33m. Scaffold rises with construction."
        default: return "Tier 4: 43m. Putlog holes in the wall still visible today."
        }
    }
    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 4, step: $step, stepLabel: label, height: height) {
            GeometryReader { geo in
                let w = geo.size.width; let h = geo.size.height
                let cx = w / 2; let groundY = h * 0.9
                let domeR = w * 0.2
                let tierH = (groundY - 10) / 5.0
                let scaffL = cx - domeR - 25; let scaffR = cx + domeR + 25

                ZStack {
                    // Ground
                    Path { p in
                        p.move(to: CGPoint(x: 5, y: groundY))
                        p.addLine(to: CGPoint(x: w - 5, y: groundY))
                    }
                    .stroke(IVMaterialColors.sepiaInk.opacity(0.3), lineWidth: 1.5)

                    // Dome outline
                    Path { p in
                        p.addArc(center: CGPoint(x: cx, y: groundY), radius: domeR,
                                 startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
                    }
                    .stroke(IVMaterialColors.sepiaInk.opacity(0.15), lineWidth: 2)

                    // 43m dimension
                    DimLine(from: CGPoint(x: w - 12, y: groundY), to: CGPoint(x: w - 12, y: groundY - domeR))
                        .stroke(IVMaterialColors.dimColor, lineWidth: 1)
                    DimLabel(text: "43m")
                        .position(x: w - 3, y: groundY - domeR / 2)

                    // Visible tiers based on step
                    let visibleTiers = step == 1 ? 0 : step == 2 ? 1 : step == 3 ? 3 : 4

                    ForEach(0..<visibleTiers, id: \.self) { level in
                        let tierTop = groundY - CGFloat(level + 1) * tierH
                        let tierBot = groundY - CGFloat(level) * tierH

                        // Left scaffold
                        Path { p in
                            p.move(to: CGPoint(x: scaffL, y: tierBot))
                            p.addLine(to: CGPoint(x: scaffL, y: tierTop))
                            p.move(to: CGPoint(x: scaffL + 14, y: tierBot))
                            p.addLine(to: CGPoint(x: scaffL + 14, y: tierTop))
                            p.move(to: CGPoint(x: scaffL - 2, y: tierTop))
                            p.addLine(to: CGPoint(x: scaffL + 18, y: tierTop))
                            p.move(to: CGPoint(x: scaffL, y: tierBot))
                            p.addLine(to: CGPoint(x: scaffL + 14, y: tierTop))
                        }
                        .stroke(Color.brown.opacity(0.5), lineWidth: 1.5)

                        // Right scaffold
                        Path { p in
                            p.move(to: CGPoint(x: scaffR, y: tierBot))
                            p.addLine(to: CGPoint(x: scaffR, y: tierTop))
                            p.move(to: CGPoint(x: scaffR - 14, y: tierBot))
                            p.addLine(to: CGPoint(x: scaffR - 14, y: tierTop))
                            p.move(to: CGPoint(x: scaffR - 18, y: tierTop))
                            p.addLine(to: CGPoint(x: scaffR + 2, y: tierTop))
                            p.move(to: CGPoint(x: scaffR, y: tierBot))
                            p.addLine(to: CGPoint(x: scaffR - 14, y: tierTop))
                        }
                        .stroke(Color.brown.opacity(0.5), lineWidth: 1.5)

                        // Height tick mark
                        DimLabel(text: heights[level])
                            .position(x: scaffR + 22, y: tierTop)
                    }

                    // Step 3: poplar formula
                    if step >= 3 {
                        Text("Poplar: 3m/year")
                            .font(RenaissanceFont.ivBody.italic())
                            .foregroundStyle(color.opacity(0.6))
                            .position(x: scaffL - 10, y: groundY - tierH * 2)
                    }

                    // Step 4: putlog holes
                    if step >= 4 {
                        ForEach([0.3, 0.5, 0.7], id: \.self) { frac in
                            let ang = .pi * frac
                            let hx = cx - domeR * 0.92 * cos(ang)
                            let hy = groundY - domeR * 0.92 * sin(ang)
                            Rectangle()
                                .fill(IVMaterialColors.sepiaInk.opacity(0.5))
                                .frame(width: 4, height: 4)
                                .position(x: hx, y: hy)
                        }
                        Text("Putlog holes")
                            .font(RenaissanceFont.ivBody.italic())
                            .foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.5))
                            .position(x: cx, y: groundY - domeR - 6)
                    }
                }
            }
        }
    }
}

// MARK: - 12. Mix Recipe — Vitruvius 1:3

private struct MixRecipeVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var scoopsAdded: Int = 0
    private let limeC = Color(red: 0.92, green: 0.90, blue: 0.85)
    private let pozzC = Color(red: 0.65, green: 0.40, blue: 0.30)

    private var isLimeTurn: Bool { scoopsAdded == 0 }
    private var isPozzTurn: Bool { scoopsAdded >= 1 && scoopsAdded < 4 }
    private var isDone: Bool { scoopsAdded == 4 }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10).fill(RenaissanceColors.parchment)
            RoundedRectangle(cornerRadius: 10).strokeBorder(color.opacity(0.2), lineWidth: 1)
            PantheonBlueprintGrid()

            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height

                VStack(spacing: 0) {
                    // Formula — big and prominent
                    Text("1 Lime + 3 Pozzolana = Roman Concrete")
                        .font(.custom("EBGaramond-Bold", size: 17))
                        .foregroundStyle(isDone ? RenaissanceColors.sageGreen : IVMaterialColors.sepiaInk)
                        .multilineTextAlignment(.center)
                        .padding(.top, 12)

                    Spacer()

                    // Ratio bar — full width, proportional
                    HStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(scoopsAdded >= 1 ? limeC : IVMaterialColors.sepiaInk.opacity(0.06))
                            .overlay(RoundedRectangle(cornerRadius: 4).stroke(IVMaterialColors.sepiaInk.opacity(0.3), lineWidth: 1))
                            .frame(height: 24)
                            .overlay(
                                Text(scoopsAdded >= 1 ? "Lime" : "")
                                    .font(RenaissanceFont.ivLabel)
                                    .foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.6))
                            )

                        ForEach(0..<3, id: \.self) { i in
                            RoundedRectangle(cornerRadius: 4)
                                .fill(scoopsAdded >= i + 2 ? pozzC.opacity(0.45) : IVMaterialColors.sepiaInk.opacity(0.06))
                                .overlay(RoundedRectangle(cornerRadius: 4).stroke(IVMaterialColors.sepiaInk.opacity(0.3), lineWidth: 1))
                                .frame(height: 24)
                                .overlay(
                                    Text(scoopsAdded >= i + 2 ? "Pozz" : "")
                                        .font(RenaissanceFont.ivLabel)
                                        .foregroundStyle(.white.opacity(0.8))
                                )
                        }
                    }
                    .padding(.horizontal, 16)

                    // Ratio label
                    Text("Ratio: \(scoopsAdded >= 1 ? "1" : "—") : \(max(0, scoopsAdded - 1))")
                        .font(RenaissanceFont.ivLabel)
                        .foregroundStyle(isDone ? RenaissanceColors.sageGreen : color)
                        .padding(.top, 8)

                    Spacer()

                    // Two big tappable ingredient boxes
                    HStack(spacing: 24) {
                        // Lime box
                        Button {
                            if isLimeTurn {
                                withAnimation(.spring(response: 0.3)) { scoopsAdded = 1 }
                                SoundManager.shared.play(.tapSoft)
                            }
                        } label: {
                            VStack(spacing: 8) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(limeC)
                                    .frame(height: h * 0.22)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(isLimeTurn ? color : IVMaterialColors.sepiaInk.opacity(0.2), lineWidth: isLimeTurn ? 3 : 1)
                                    )
                                    .overlay(
                                        VStack(spacing: 4) {
                                            Text("CaO")
                                                .font(.custom("EBGaramond-Bold", size: 18))
                                                .foregroundStyle(IVMaterialColors.sepiaInk)
                                            if isLimeTurn {
                                                Text("TAP")
                                                    .font(RenaissanceFont.ivLabel)
                                                    .foregroundStyle(color)
                                            }
                                        }
                                    )
                                Text("Lime — 1 part")
                                    .font(RenaissanceFont.ivLabel)
                                    .foregroundStyle(IVMaterialColors.sepiaInk)
                            }
                        }
                        .buttonStyle(.plain)
                        .opacity(scoopsAdded >= 1 ? 0.4 : 1)

                        // Pozzolana box
                        Button {
                            if isPozzTurn {
                                withAnimation(.spring(response: 0.3)) { scoopsAdded += 1 }
                                SoundManager.shared.play(.tapSoft)
                            }
                        } label: {
                            VStack(spacing: 8) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(pozzC.opacity(0.4))
                                    .frame(height: h * 0.22)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(isPozzTurn ? color : IVMaterialColors.sepiaInk.opacity(0.2), lineWidth: isPozzTurn ? 3 : 1)
                                    )
                                    .overlay(
                                        VStack(spacing: 4) {
                                            Text("SiO₂")
                                                .font(.custom("EBGaramond-Bold", size: 18))
                                                .foregroundStyle(IVMaterialColors.sepiaInk)
                                            if isPozzTurn {
                                                Text("TAP ×\(4 - scoopsAdded)")
                                                    .font(RenaissanceFont.ivLabel)
                                                    .foregroundStyle(color)
                                            }
                                        }
                                    )
                                Text("Pozzolana — 3 parts")
                                    .font(RenaissanceFont.ivLabel)
                                    .foregroundStyle(IVMaterialColors.sepiaInk)
                            }
                        }
                        .buttonStyle(.plain)
                        .opacity(isDone ? 0.4 : 1)
                    }
                    .padding(.horizontal, 16)

                    Spacer()

                    // Status
                    if isDone {
                        Text("Perfect 1:3 ratio! The recipe that outlasts empires.")
                            .font(RenaissanceFont.ivFormula)
                            .foregroundStyle(RenaissanceColors.sageGreen)
                            .multilineTextAlignment(.center)
                    } else {
                        Text(isLimeTurn ? "Tap lime to add 1 part binder" : "Tap pozzolana to add volcanic ash (\(scoopsAdded - 1)/3)")
                            .font(RenaissanceFont.ivBody.italic())
                            .foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.5))
                    }

                    Spacer().frame(height: 8)
                }
            }
        }
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

private struct BowlShape: Shape {
    func path(in rect: CGRect) -> Path {
        Path { p in
            p.move(to: CGPoint(x: 0, y: rect.minY + rect.height * 0.2))
            p.addQuadCurve(to: CGPoint(x: rect.width, y: rect.minY + rect.height * 0.2),
                           control: CGPoint(x: rect.width / 2, y: rect.maxY + rect.height * 0.1))
        }
    }
}

// MARK: - 13. Calcination — CaCO₃ → CaO + CO₂ (slider-driven formula fade-in)

private struct CalcinationSliderVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var temperature: CGFloat = 0
    @State private var bubblePhase: Bool = false

    private var tempC: Int { Int(temperature * 1000) }
    private var arrowOpacity: Double { min(1, max(0, (temperature - 0.4) / 0.2)) }
    private var caoOpacity: Double { min(1, max(0, (temperature - 0.6) / 0.15)) }
    private var plusOpacity: Double { min(1, max(0, (temperature - 0.75) / 0.1)) }
    private var co2Opacity: Double { min(1, max(0, (temperature - 0.85) / 0.1)) }
    private var isCalcining: Bool { tempC >= 900 }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10).fill(RenaissanceColors.parchment)
            RoundedRectangle(cornerRadius: 10).strokeBorder(color.opacity(0.2), lineWidth: 1)
            PantheonBlueprintGrid()

            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height

                VStack(spacing: 0) {
                    Spacer()

                    // Formula — large, elements fade in with slider
                    HStack(spacing: 10) {
                        Text("CaCO₃")
                            .font(.custom("EBGaramond-Bold", size: 22))
                            .foregroundStyle(IVMaterialColors.sepiaInk)

                        Image(systemName: "arrow.right")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(RenaissanceColors.furnaceOrange.opacity(arrowOpacity))

                        Text("CaO")
                            .font(.custom("EBGaramond-Bold", size: 22))
                            .foregroundStyle(color.opacity(caoOpacity))

                        Text("+")
                            .font(.custom("EBGaramond-Bold", size: 20))
                            .foregroundStyle(IVMaterialColors.sepiaInk.opacity(plusOpacity))

                        Text("CO₂↑")
                            .font(.custom("EBGaramond-Bold", size: 22))
                            .foregroundStyle(RenaissanceColors.sageGreen.opacity(co2Opacity))
                    }

                    Spacer()

                    // Stone block + CO₂ — centered, large
                    HStack(spacing: 0) {
                        Spacer()

                        // Stone block
                        VStack(spacing: 6) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(
                                    red: isCalcining ? 0.92 : 0.65,
                                    green: isCalcining ? 0.90 : 0.63,
                                    blue: isCalcining ? 0.85 : 0.60
                                ))
                                .frame(width: isCalcining ? h * 0.28 : h * 0.38,
                                       height: isCalcining ? h * 0.28 : h * 0.38)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(IVMaterialColors.sepiaInk.opacity(0.4), lineWidth: 1.5))
                                .animation(.spring(response: 0.5), value: isCalcining)

                            DimLabel(text: isCalcining ? "56g (CaO)" : "100g (CaCO₃)")
                        }

                        // CO₂ bubbles
                        if isCalcining {
                            VStack(spacing: 4) {
                                ZStack {
                                    ForEach(0..<8, id: \.self) { i in
                                        Circle()
                                            .fill(IVMaterialColors.sepiaInk.opacity(0.2))
                                            .frame(width: CGFloat(5 + i % 3 * 3))
                                            .offset(
                                                x: CGFloat([-12, 8, -5, 14, -9, 5, -3, 10][i]),
                                                y: bubblePhase ? CGFloat([-40, -25, -45, -30, -20, -50, -35, -15][i]) : 0
                                            )
                                    }
                                }
                                .frame(width: 50, height: h * 0.25)

                                DimLabel(text: "44g CO₂↑")
                            }
                            .padding(.leading, 20)
                            .transition(.opacity)
                        }

                        Spacer()
                    }

                    Spacer()

                    // Temperature slider — full width
                    VStack(spacing: 3) {
                        HStack {
                            Text("0°C").font(RenaissanceFont.ivBody).foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.4))
                            Spacer()
                            DimLabel(text: "\(tempC)°C")
                            if isCalcining {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(RenaissanceColors.sageGreen)
                                    .font(.system(size: 13))
                            }
                            Spacer()
                            Text("1000°C").font(RenaissanceFont.ivBody).foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.4))
                        }
                        Slider(value: $temperature, in: 0...1)
                            .tint(isCalcining ? RenaissanceColors.furnaceOrange : color)

                        Text(isCalcining ? "CaCO₃(100) → CaO(56) + CO₂(44) — mass conserved" : "Drag to 900°C to trigger the reaction")
                            .font(RenaissanceFont.ivBody.italic())
                            .foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.5))
                    }
                }
                .padding(12)
            }
        }
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .onChange(of: isCalcining) { _, calcining in
            if calcining {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    bubblePhase = true
                }
            } else {
                bubblePhase = false
            }
        }
    }
}

// MARK: - 14. Tessellation — Opus Sectile, 4 stones from 4 countries

private struct TessellationPuzzleVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1

    private let stones: [(name: String, origin: String, c: Color)] = [
        ("Porphyry",      "Egypt",   Color(red: 0.55, green: 0.20, blue: 0.30)),
        ("Giallo antico", "Tunisia", Color(red: 0.80, green: 0.70, blue: 0.40)),
        ("Pavonazzetto",  "Turkey",  Color(red: 0.90, green: 0.85, blue: 0.80)),
        ("Granite",       "Egypt",   Color(red: 0.50, green: 0.50, blue: 0.50)),
    ]
    private let pattern: [[Int]] = [[0, 1, 0], [2, 3, 2], [0, 1, 0]]

    private var label: String {
        switch step {
        case 1: return "An empty floor awaits hand-cut marble from across the empire."
        case 2: return "Porphyry from Egypt — the imperial purple reserved for emperors."
        case 3: return "Giallo antico (Tunisia), pavonazzetto (Turkey), granite (Egypt)."
        default: return "4 countries, 4 stones, no mortar. The floor echoes the dome above."
        }
    }

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 4, step: $step, stepLabel: label, height: height) {
            VStack(spacing: 8) {
                // Grid
                VStack(spacing: 3) {
                    ForEach(0..<3, id: \.self) { row in
                        HStack(spacing: 3) {
                            ForEach(0..<3, id: \.self) { col in
                                let stoneIdx = pattern[row][col]
                                let visible = stoneVisible(stoneIdx: stoneIdx)

                                ZStack {
                                    if visible {
                                        RoundedRectangle(cornerRadius: 3)
                                            .fill(stones[stoneIdx].c.opacity(0.35))
                                        RoundedRectangle(cornerRadius: 3)
                                            .stroke(stones[stoneIdx].c.opacity(0.6), lineWidth: 1)
                                        if row == 1 && col == 1 {
                                            // Center diamond accent
                                            Path { p in
                                                let s: CGFloat = 10
                                                p.move(to: CGPoint(x: 22, y: 22 - s))
                                                p.addLine(to: CGPoint(x: 22 + s, y: 22))
                                                p.addLine(to: CGPoint(x: 22, y: 22 + s))
                                                p.addLine(to: CGPoint(x: 22 - s, y: 22))
                                                p.closeSubpath()
                                            }
                                            .fill(stones[stoneIdx].c.opacity(0.2))
                                            .frame(width: 44, height: 44)
                                        }
                                    } else {
                                        RoundedRectangle(cornerRadius: 3)
                                            .stroke(IVMaterialColors.sepiaInk.opacity(0.1), style: StrokeStyle(lineWidth: 1, dash: [3, 2]))
                                    }
                                }
                                .frame(width: 44, height: 44)
                            }
                        }
                    }
                }

                // Legend with origins
                HStack(spacing: 6) {
                    ForEach(0..<stones.count, id: \.self) { i in
                        let visible = step >= (i == 0 ? 2 : 3)
                        VStack(spacing: 1) {
                            Circle()
                                .fill(visible ? stones[i].c.opacity(0.5) : IVMaterialColors.sepiaInk.opacity(0.1))
                                .frame(width: 8, height: 8)
                            Text(stones[i].name)
                                .font(RenaissanceFont.ivBody)
                                .foregroundStyle(visible ? IVMaterialColors.sepiaInk : IVMaterialColors.sepiaInk.opacity(0.3))
                            if visible {
                                Text(stones[i].origin)
                                    .font(RenaissanceFont.ivBody.italic())
                                    .foregroundStyle(IVMaterialColors.dimColor)
                            }
                        }
                    }
                }

                if step >= 4 {
                    FormulaText(text: "No mortar — precision cut", highlighted: true)
                }
            }
        }
    }

    private func stoneVisible(stoneIdx: Int) -> Bool {
        switch step {
        case 1: return false
        case 2: return stoneIdx == 0
        case 3: return stoneIdx <= 2
        default: return true
        }
    }
}
