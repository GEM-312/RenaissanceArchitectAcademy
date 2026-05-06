import SwiftUI

/// Interactive science visuals for Roman Roads knowledge cards
struct RomanRoadsInteractiveVisuals {

    @ViewBuilder
    static func view(for visual: CardVisual, color: Color, height: CGFloat = 275) -> some View {
        let h = height
        Group {
            switch visual.title {
            case let t where t.contains("400,000 km"):
                RadialRoadsVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Groma"):
                GromaSurveyVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Four Layers"):
                FourLayersVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Basalt Polygons"):
                BasaltPavingVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Ice Splitting"):
                IceSplittingVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Pozzolanic Crystals"):
                CrystalGrowthVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Camber"):
                CamberDrainageVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Road Mortar") || t.contains("1:3"):
                RoadMortarRecipeVisual(visual: visual, color: color, height: h)
            case let t where t.contains("3-Day Kiln") || t.contains("Quicklime"):
                LimeFiringVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Milestone"):
                MilestoneCarveVisual(visual: visual, color: color, height: h)
            default:
                EmptyView()
            }
        }
    }

    static func hasInteractiveVisual(for visual: CardVisual) -> Bool {
        let t = visual.title
        return t.contains("400,000 km") || t.contains("Groma") ||
               t.contains("Four Layers") || t.contains("Basalt Polygons") ||
               t.contains("Ice Splitting") || t.contains("Pozzolanic Crystals") ||
               t.contains("Camber") || t.contains("Road Mortar") || t.contains("1:3") ||
               t.contains("3-Day Kiln") || t.contains("Quicklime") ||
               t.contains("Milestone")
    }
}

// MARK: - Local Colors (unique to Roman Roads)

private let basaltDark = Color(red: 0.38, green: 0.36, blue: 0.34)
private let sandBeige = Color(red: 0.82, green: 0.76, blue: 0.66)
private let gravelBrown = Color(red: 0.65, green: 0.55, blue: 0.42)

private typealias TeachingContainer = IVTeachingContainer
private typealias DimLabel = IVDimLabel
private typealias FormulaText = IVFormulaText
private typealias DimLine = IVDimLine

// MARK: - 1. Radial Roads — Tap to Extend from Golden Milestone

private struct RadialRoadsVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    @State private var extendedRoads: Set<Int> = []

    private let roadCount = 8
    private let roadNames = ["Via Appia", "Via Flaminia", "Via Salaria", "Via Aurelia",
                             "Via Cassia", "Via Latina", "Via Ostiensis", "Via Tiburtina"]

    private var label: String {
        switch step {
        case 1: return "Every road leads to Rome — from one golden milestone."
        case 2:
            if extendedRoads.count < roadCount { return "Tap to extend each highway from the milestone." }
            return "29 highways radiating 400,000 km across the empire."
        default: return "Enough road to circle Earth 10 times."
        }
    }

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3,
                         step: $step, stepLabel: label, height: height) {
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let cx = w * 0.5
                let cy = h * 0.45
                let radius = min(w, h) * 0.35

                ZStack {
                    // Golden milestone at center
                    Circle()
                        .fill(RenaissanceColors.ochre)
                        .frame(width: 16, height: 16)
                        .position(x: cx, y: cy)

                    Circle()
                        .strokeBorder(RenaissanceColors.ochre.opacity(0.5), lineWidth: 1)
                        .frame(width: 24, height: 24)
                        .position(x: cx, y: cy)

                    Text("ROMA")
                        .font(RenaissanceFont.visualTitle)
                        .foregroundStyle(RenaissanceColors.ochre)
                        .position(x: cx, y: cy + 18)

                    // Road lines
                    if step >= 2 {
                        ForEach(0..<roadCount, id: \.self) { i in
                            let angle = CGFloat(i) / CGFloat(roadCount) * .pi * 2 - .pi / 2
                            let extended = extendedRoads.contains(i)
                            let endX = cx + radius * cos(angle)
                            let endY = cy + radius * sin(angle)
                            let midX = cx + radius * 0.5 * cos(angle)
                            let midY = cy + radius * 0.5 * sin(angle)

                            // Road line
                            Path { p in
                                p.move(to: CGPoint(x: cx, y: cy))
                                p.addLine(to: CGPoint(x: extended ? endX : midX * 0.3 + cx * 0.7,
                                                      y: extended ? endY : midY * 0.3 + cy * 0.7))
                            }
                            .stroke(extended ? color : IVMaterialColors.stoneGray.opacity(0.3),
                                    lineWidth: extended ? 1.5 : 0.8)

                            // Road name label
                            if extended {
                                Text(roadNames[i])
                                    .font(RenaissanceFont.ivBody)
                                    .foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.6))
                                    .position(x: endX, y: endY)
                                    .transition(.opacity)
                            }

                            // Tap target
                            if !extended {
                                Circle()
                                    .fill(color.opacity(0.15))
                                    .frame(width: 20, height: 20)
                                    .position(x: cx + radius * 0.4 * cos(angle),
                                              y: cy + radius * 0.4 * sin(angle))
                                    .onTapGesture {
                                        withAnimation(.spring(response: 0.3)) { extendedRoads.insert(i) }
                                        SoundManager.shared.play(.tapSoft)
                                        if extendedRoads.count == roadCount {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                withAnimation { step = 3 }
                                            }
                                        }
                                    }
                            }
                        }
                    }

                    if step >= 3 {
                        FormulaText(text: "400,000 km = 10× around Earth", highlighted: true)
                            .position(x: cx, y: h * 0.88)
                            .transition(.opacity)
                    }
                }
            }
        }
    }
}

// MARK: - 2. Groma Survey Tool — Drag Plumb Lines

private struct GromaSurveyVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    @State private var plumbOffset: CGFloat = 0 // drag to align

    private var isAligned: Bool { abs(plumbOffset) < 0.05 }

    private var label: String {
        switch step {
        case 1: return "A cross-shaped tool with 4 plumb lines — the Roman surveyor's GPS."
        case 2: return "Drag to align the plumb lines — perfectly vertical = straight road."
        default: return "80 km dead straight with this simple tool."
        }
    }

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3,
                         step: $step, stepLabel: label, height: height) {
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let cx = w * 0.5
                let cy = h * 0.35
                let armLen = w * 0.25

                ZStack {
                    // Vertical pole
                    Rectangle()
                        .fill(RenaissanceColors.warmBrown.opacity(0.5))
                        .frame(width: 4, height: h * 0.45)
                        .position(x: cx, y: cy + h * 0.05)

                    // Cross arms (horizontal bar)
                    Rectangle()
                        .fill(RenaissanceColors.warmBrown.opacity(0.5))
                        .frame(width: armLen * 2, height: 4)
                        .position(x: cx, y: cy - h * 0.1)

                    // 4 plumb lines hanging from cross ends
                    let armY = cy - h * 0.1
                    let plumbLen = h * 0.2
                    let sway = plumbOffset * 15

                    ForEach([-1.0, 1.0], id: \.self) { side in
                        let armX = cx + side * armLen

                        // Plumb string
                        Path { p in
                            p.move(to: CGPoint(x: armX, y: armY))
                            p.addLine(to: CGPoint(x: armX + sway, y: armY + plumbLen))
                        }
                        .stroke(RenaissanceColors.warmBrown.opacity(0.4), lineWidth: 1)

                        // Plumb weight
                        Circle()
                            .fill(IVMaterialColors.stoneGray)
                            .frame(width: 8, height: 8)
                            .position(x: armX + sway, y: armY + plumbLen)
                    }

                    // Front-back plumb lines (perpendicular axis — shown smaller)
                    ForEach([-0.5, 0.5], id: \.self) { scale in
                        let fwd = cx + scale * armLen * 0.4
                        Path { p in
                            p.move(to: CGPoint(x: fwd, y: armY + 2))
                            p.addLine(to: CGPoint(x: fwd + sway * 0.5, y: armY + plumbLen * 0.7))
                        }
                        .stroke(RenaissanceColors.warmBrown.opacity(0.25), lineWidth: 0.8)

                        Circle()
                            .fill(IVMaterialColors.stoneGray.opacity(0.5))
                            .frame(width: 5, height: 5)
                            .position(x: fwd + sway * 0.5, y: armY + plumbLen * 0.7)
                    }

                    // Alignment indicator
                    if step >= 2 {
                        Text(isAligned ? "ALIGNED" : "Tilted")
                            .font(RenaissanceFont.visualTitle)
                            .foregroundStyle(isAligned ? RenaissanceColors.sageGreen : RenaissanceColors.errorRed.opacity(0.5))
                            .position(x: cx, y: h * 0.72)

                        // Drag gesture area
                        Color.clear
                            .contentShape(Rectangle())
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        plumbOffset = value.translation.width / (w * 0.5)
                                        plumbOffset = max(-1, min(1, plumbOffset))
                                    }
                                    .onEnded { _ in
                                        if isAligned {
                                            withAnimation(.spring(response: 0.3)) { plumbOffset = 0 }
                                            withAnimation { step = 3 }
                                            SoundManager.shared.play(.correctChime)
                                        }
                                    }
                            )
                    }

                    // Sightline when aligned (step 3)
                    if step >= 3 {
                        Path { p in
                            p.move(to: CGPoint(x: cx - armLen, y: armY))
                            p.addLine(to: CGPoint(x: cx + armLen, y: armY))
                        }
                        .stroke(RenaissanceColors.sageGreen.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [6, 4]))

                        FormulaText(text: "Sight + plumb = 80 km straight", highlighted: true)
                            .position(x: cx, y: h * 0.88)
                            .transition(.opacity)
                    }
                }
            }
        }
    }
}

// MARK: - 3. Four Layers — Tap to Build Up

private struct FourLayersVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    @State private var layersBuilt: Int = 0

    private let layers: [(name: String, latin: String, color: Color, desc: String)] = [
        ("Drainage stones", "Statumen", Color(red: 0.50, green: 0.48, blue: 0.44), "Large flat stones"),
        ("Lime gravel", "Rudus", gravelBrown, "Crushed rock + lime"),
        ("Packed sand", "Nucleus", sandBeige, "Fine sand, rammed"),
        ("Polygonal stones", "Summa crusta", basaltDark, "Interlocking basalt"),
    ]

    private var label: String {
        switch step {
        case 1: return "A Roman road is a geological sandwich — up to 1.5 meters deep."
        case 2:
            if layersBuilt < 4 { return "Tap to add layer \(layersBuilt + 1) — \(layers[layersBuilt].latin)." }
            return "4 layers, each with a different job."
        default: return "A geological sandwich — 2,300 years and still standing."
        }
    }

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3,
                         step: $step, stepLabel: label, height: height) {
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let cx = w * 0.5
                let layerH = h * 0.13
                let baseY = h * 0.7

                ZStack {
                    // Ground line
                    Path { p in
                        p.move(to: CGPoint(x: w * 0.15, y: baseY + layerH * 0.5))
                        p.addLine(to: CGPoint(x: w * 0.85, y: baseY + layerH * 0.5))
                    }
                    .stroke(RenaissanceColors.warmBrown.opacity(0.3), lineWidth: 1)

                    // Built layers (bottom to top)
                    ForEach(0..<layersBuilt, id: \.self) { i in
                        let y = baseY - CGFloat(i) * layerH

                        RoundedRectangle(cornerRadius: 2)
                            .fill(layers[i].color.opacity(0.5))
                            .frame(width: w * 0.55, height: layerH - 3)
                            .position(x: cx, y: y)
                            .transition(.move(edge: .bottom).combined(with: .opacity))

                        // Latin name
                        Text(layers[i].latin)
                            .font(RenaissanceFont.visualTitle)
                            .foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.6))
                            .position(x: cx + w * 0.35, y: y - 6)

                        Text(layers[i].desc)
                            .font(RenaissanceFont.ivBody)
                            .foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.4))
                            .position(x: cx + w * 0.35, y: y + 6)
                    }

                    // Build button
                    if step >= 2 && layersBuilt < 4 {
                        Button {
                            withAnimation(.spring(response: 0.4)) { layersBuilt += 1 }
                            SoundManager.shared.play(.tapSoft)
                            if layersBuilt >= 4 {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    withAnimation { step = 3 }
                                }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "square.stack.3d.up").font(.system(size: 13))
                                Text("Add \(layers[layersBuilt].latin)").font(RenaissanceFont.ivLabel)
                            }
                            .foregroundStyle(layers[layersBuilt].color)
                            .padding(.horizontal, 12).padding(.vertical, 6)
                            .background(layers[layersBuilt].color.opacity(0.15)).cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                        .position(x: cx, y: h * 0.12)
                    }

                    // Dimension
                    if layersBuilt >= 4 {
                        DimLine(from: CGPoint(x: w * 0.18, y: baseY - 3 * layerH - layerH * 0.5),
                                to: CGPoint(x: w * 0.18, y: baseY + layerH * 0.5))
                            .stroke(IVMaterialColors.dimColor, lineWidth: 0.8)
                        DimLabel(text: "1.5 m")
                            .position(x: w * 0.12, y: baseY - layerH * 1.5)
                    }

                    if step >= 3 {
                        FormulaText(text: "4 layers = 2,300 years of service", highlighted: true)
                            .position(x: cx, y: h * 0.12)
                            .transition(.opacity)
                    }
                }
            }
        }
    }
}

// MARK: - 4. Basalt Paving — Drag Polygons to Interlock

private struct BasaltPavingVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    @State private var placedStones: Set<Int> = []

    private let stoneCount = 6

    private var label: String {
        switch step {
        case 1: return "Polygonal basalt stones — no mortar, just gravity and geometry."
        case 2:
            if placedStones.count < stoneCount { return "Tap each stone to lock it into place." }
            return "Interlocking under weight — tighter with every cart."
        default: return "2,300 years old, still walkable."
        }
    }

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3,
                         step: $step, stepLabel: label, height: height) {
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let cx = w * 0.5
                let gridY = h * 0.42

                // Irregular polygon positions (hand-placed for natural look)
                let stonePositions: [CGPoint] = [
                    CGPoint(x: 0.3, y: 0.35), CGPoint(x: 0.5, y: 0.32),
                    CGPoint(x: 0.7, y: 0.36), CGPoint(x: 0.25, y: 0.52),
                    CGPoint(x: 0.5, y: 0.50), CGPoint(x: 0.72, y: 0.53),
                ]

                ZStack {
                    // Road bed
                    RoundedRectangle(cornerRadius: 4)
                        .fill(sandBeige.opacity(0.3))
                        .frame(width: w * 0.7, height: h * 0.4)
                        .position(x: cx, y: gridY + h * 0.03)

                    // Stones (placed or ghost)
                    if step >= 2 {
                        ForEach(0..<stoneCount, id: \.self) { i in
                            let pos = stonePositions[i]
                            let placed = placedStones.contains(i)
                            let stoneW: CGFloat = w * 0.12
                            let stoneH: CGFloat = h * 0.1

                            // Irregular polygon shape
                            Path { p in
                                let cx = pos.x * w
                                let cy = pos.y * h
                                let hw = stoneW * 0.5
                                let hh = stoneH * 0.5
                                // Irregular hexagon-ish
                                p.move(to: CGPoint(x: cx - hw * 0.7, y: cy - hh))
                                p.addLine(to: CGPoint(x: cx + hw * 0.8, y: cy - hh * 0.8))
                                p.addLine(to: CGPoint(x: cx + hw, y: cy + hh * 0.3))
                                p.addLine(to: CGPoint(x: cx + hw * 0.5, y: cy + hh))
                                p.addLine(to: CGPoint(x: cx - hw * 0.6, y: cy + hh * 0.9))
                                p.addLine(to: CGPoint(x: cx - hw, y: cy - hh * 0.2))
                                p.closeSubpath()
                            }
                            .fill(placed ? basaltDark : basaltDark.opacity(0.15))
                            .overlay {
                                if !placed {
                                    Path { p in
                                        let cx = pos.x * w
                                        let cy = pos.y * h
                                        let hw = stoneW * 0.5
                                        let hh = stoneH * 0.5
                                        p.move(to: CGPoint(x: cx - hw * 0.7, y: cy - hh))
                                        p.addLine(to: CGPoint(x: cx + hw * 0.8, y: cy - hh * 0.8))
                                        p.addLine(to: CGPoint(x: cx + hw, y: cy + hh * 0.3))
                                        p.addLine(to: CGPoint(x: cx + hw * 0.5, y: cy + hh))
                                        p.addLine(to: CGPoint(x: cx - hw * 0.6, y: cy + hh * 0.9))
                                        p.addLine(to: CGPoint(x: cx - hw, y: cy - hh * 0.2))
                                        p.closeSubpath()
                                    }
                                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [3, 3]))
                                    .foregroundStyle(color.opacity(0.4))
                                }
                            }
                            .onTapGesture {
                                guard !placed else { return }
                                withAnimation(.spring(response: 0.3)) { placedStones.insert(i) }
                                SoundManager.shared.play(.tapSoft)
                                if placedStones.count == stoneCount {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        withAnimation { step = 3 }
                                    }
                                }
                            }
                        }
                    }

                    if step >= 3 {
                        FormulaText(text: "No mortar — just geometry + gravity", highlighted: true)
                            .position(x: cx, y: h * 0.85)
                            .transition(.opacity)
                    }
                }
            }
        }
    }
}

// MARK: - 5. Ice Splitting — Freeze Animation

private struct IceSplittingVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    @State private var waterPoured = false
    @State private var frozen = false
    @State private var cracked = false

    private var label: String {
        switch step {
        case 1: return "Nature's chisel — water expands 9% when it freezes."
        case 2:
            if !waterPoured { return "Tap to pour water into the drill holes." }
            if !frozen { return "Tap to freeze — watch the stone split." }
            return "Ice expansion splits the hardest basalt along the grain."
        default: return "No iron chisel needed — just water, patience, and winter."
        }
    }

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3,
                         step: $step, stepLabel: label, height: height) {
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let cx = w * 0.5
                let blockW = w * 0.55
                let blockH = h * 0.3
                let blockY = h * 0.4

                ZStack {
                    // Stone block (splits when cracked)
                    if cracked {
                        // Left half
                        RoundedRectangle(cornerRadius: 3)
                            .fill(basaltDark)
                            .frame(width: blockW * 0.48, height: blockH)
                            .position(x: cx - blockW * 0.27, y: blockY)
                        // Right half
                        RoundedRectangle(cornerRadius: 3)
                            .fill(basaltDark)
                            .frame(width: blockW * 0.48, height: blockH)
                            .position(x: cx + blockW * 0.27, y: blockY)
                    } else {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(basaltDark)
                            .frame(width: blockW, height: blockH)
                            .position(x: cx, y: blockY)
                    }

                    // Drill holes across the top
                    ForEach(0..<5, id: \.self) { i in
                        let hx = cx - blockW * 0.35 + CGFloat(i) * blockW * 0.175
                        Circle()
                            .fill(waterPoured ? (frozen ? IVMaterialColors.waterBlue.opacity(0.8) : IVMaterialColors.waterBlue.opacity(0.5)) : basaltDark.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .position(x: hx, y: blockY - blockH * 0.3)
                    }

                    // Crack line (when frozen)
                    if frozen {
                        Path { p in
                            p.move(to: CGPoint(x: cx, y: blockY - blockH * 0.45))
                            p.addLine(to: CGPoint(x: cx - 3, y: blockY))
                            p.addLine(to: CGPoint(x: cx + 2, y: blockY + blockH * 0.45))
                        }
                        .stroke(RenaissanceColors.errorRed.opacity(cracked ? 0 : 0.6), lineWidth: 1.5)
                    }

                    // Action buttons
                    if step >= 2 {
                        if !waterPoured {
                            Button {
                                withAnimation(.spring(response: 0.3)) { waterPoured = true }
                                SoundManager.shared.play(.tapSoft)
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "drop.fill").font(.system(size: 13))
                                    Text("Pour Water").font(RenaissanceFont.ivLabel)
                                }
                                .foregroundStyle(IVMaterialColors.waterBlue)
                                .padding(.horizontal, 12).padding(.vertical, 6)
                                .background(IVMaterialColors.waterBlue.opacity(0.1)).cornerRadius(6)
                            }
                            .buttonStyle(.plain)
                            .position(x: cx, y: h * 0.78)
                        } else if !frozen {
                            Button {
                                withAnimation(.spring(response: 0.3)) { frozen = true }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                    withAnimation(.spring(response: 0.4)) { cracked = true }
                                    SoundManager.shared.play(.correctChime)
                                    withAnimation { step = 3 }
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "snowflake").font(.system(size: 13))
                                    Text("Freeze").font(RenaissanceFont.ivLabel)
                                }
                                .foregroundStyle(IVMaterialColors.waterBlue)
                                .padding(.horizontal, 12).padding(.vertical, 6)
                                .background(IVMaterialColors.waterBlue.opacity(0.1)).cornerRadius(6)
                            }
                            .buttonStyle(.plain)
                            .position(x: cx, y: h * 0.78)
                        }
                    }

                    // Formula
                    if step >= 2 {
                        FormulaText(text: "H₂O → ice = +9% volume", highlighted: frozen)
                            .position(x: cx, y: h * 0.12)
                    }

                    if step >= 3 {
                        FormulaText(text: "Water + winter = nature's chisel", highlighted: true)
                            .position(x: cx, y: h * 0.85)
                            .transition(.opacity)
                    }
                }
            }
        }
    }
}

// MARK: - 6. Crystal Growth — Time Slider

private struct CrystalGrowthVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    @State private var timeProgress: CGFloat = 0

    private var years: Int { Int(timeProgress * 2000) }
    private var crystalCount: Int { Int(timeProgress * 15) }

    private var label: String {
        switch step {
        case 1: return "Pozzolanic concrete gets STRONGER over centuries."
        case 2: return "Drag to fast-forward — watch crystals grow in the pores."
        default: return "Crystals fill the gaps — stronger at 2,000 than at 2."
        }
    }

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3,
                         step: $step, stepLabel: label, height: height) {
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let cx = w * 0.5
                let blockW = w * 0.45
                let blockH = h * 0.35

                ZStack {
                    // Mortar matrix
                    RoundedRectangle(cornerRadius: 4)
                        .fill(gravelBrown.opacity(0.3 + timeProgress * 0.4))
                        .frame(width: blockW, height: blockH)
                        .position(x: cx, y: h * 0.38)

                    // Crystal formations (grow with time)
                    ForEach(0..<crystalCount, id: \.self) { i in
                        let seed = CGFloat((i * 137 + 42) % 100) / 100.0
                        let size = 2 + timeProgress * 6 * seed

                        // Star-shaped crystal
                        Image(systemName: "sparkle")
                            .font(.system(size: size))
                            .foregroundStyle(Color.white.opacity(0.5 + timeProgress * 0.3))
                            .position(
                                x: cx + (CGFloat((i * 67) % 100) / 100.0 - 0.5) * blockW * 0.8,
                                y: h * 0.38 + (seed - 0.5) * blockH * 0.8
                            )
                    }

                    // Year counter
                    Text("\(years) years")
                        .font(.custom("EBGaramond-Bold", size: 16))
                        .monospacedDigit()
                        .foregroundStyle(timeProgress > 0.8 ? RenaissanceColors.sageGreen : IVMaterialColors.sepiaInk)
                        .position(x: cx, y: h * 0.12)

                    // Slider
                    if step >= 2 {
                        Slider(value: $timeProgress, in: 0...1)
                            .tint(timeProgress > 0.8 ? RenaissanceColors.sageGreen : color)
                            .frame(width: w * 0.6)
                            .position(x: cx, y: h * 0.72)
                            .onChange(of: timeProgress) { _, val in
                                if val > 0.9 { withAnimation { step = 3 } }
                            }
                    }

                    if step >= 3 {
                        FormulaText(text: "Crystals fill pores → stronger every year", highlighted: true)
                            .position(x: cx, y: h * 0.85)
                            .transition(.opacity)
                    }
                }
            }
        }
    }
}

// MARK: - 7. Camber Drainage — Rain Animation

private struct CamberDrainageVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    @State private var raining = false
    @State private var rainOffset: CGFloat = 0

    private var label: String {
        switch step {
        case 1: return "Every Roman road is a roof — center 15-30 cm higher than edges."
        case 2:
            if !raining { return "Tap to make it rain — watch where the water goes." }
            return "Water flows to side ditches — the road stays dry."
        default: return "A gentle arc invisible to the eye — but rain sees it perfectly."
        }
    }

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3,
                         step: $step, stepLabel: label, height: height) {
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let cx = w * 0.5
                let roadY = h * 0.5
                let camberH: CGFloat = h * 0.04

                ZStack {
                    // Road cross-section with camber (curved top)
                    Path { p in
                        p.move(to: CGPoint(x: w * 0.15, y: roadY))
                        p.addQuadCurve(
                            to: CGPoint(x: w * 0.85, y: roadY),
                            control: CGPoint(x: cx, y: roadY - camberH)
                        )
                        p.addLine(to: CGPoint(x: w * 0.85, y: roadY + h * 0.08))
                        p.addLine(to: CGPoint(x: w * 0.15, y: roadY + h * 0.08))
                        p.closeSubpath()
                    }
                    .fill(IVMaterialColors.stoneGray.opacity(0.4))

                    Path { p in
                        p.move(to: CGPoint(x: w * 0.15, y: roadY))
                        p.addQuadCurve(
                            to: CGPoint(x: w * 0.85, y: roadY),
                            control: CGPoint(x: cx, y: roadY - camberH)
                        )
                    }
                    .stroke(IVMaterialColors.stoneGray, lineWidth: 2)

                    // Side ditches
                    ForEach([0.12, 0.88], id: \.self) { xFrac in
                        let ditchX = w * xFrac
                        Path { p in
                            p.move(to: CGPoint(x: ditchX, y: roadY))
                            p.addLine(to: CGPoint(x: ditchX, y: roadY + h * 0.12))
                        }
                        .stroke(RenaissanceColors.warmBrown.opacity(0.3), lineWidth: 1.5)
                    }

                    // Camber dimension
                    DimLine(from: CGPoint(x: cx, y: roadY - camberH - 8),
                            to: CGPoint(x: cx, y: roadY - 2))
                        .stroke(IVMaterialColors.dimColor, lineWidth: 0.8)
                    DimLabel(text: "15-30 cm")
                        .position(x: cx + 30, y: roadY - camberH - 4)

                    // Rain drops
                    if raining {
                        Canvas { context, size in
                            for i in 0..<12 {
                                let baseX = w * 0.2 + CGFloat(i) * w * 0.05
                                let dropY = (rainOffset + CGFloat(i) * 0.08).truncatingRemainder(dividingBy: 1.0)
                                let y = h * 0.1 + dropY * (roadY - h * 0.1)
                                var drop = Path()
                                drop.move(to: CGPoint(x: baseX, y: y))
                                drop.addLine(to: CGPoint(x: baseX, y: y + 6))
                                context.stroke(drop, with: .color(IVMaterialColors.waterBlue.opacity(0.4)), lineWidth: 1)
                            }
                        }
                        .frame(width: w, height: h)
                        .allowsHitTesting(false)

                        // Water flow arrows on road surface
                        ForEach([-1.0, 1.0], id: \.self) { side in
                            Image(systemName: "arrow.right")
                                .font(.system(size: 13))
                                .foregroundStyle(IVMaterialColors.waterBlue)
                                .rotationEffect(.degrees(side > 0 ? 30 : -210))
                                .position(x: cx + side * w * 0.2, y: roadY - 6)
                        }

                        // Ditch water
                        ForEach([0.12, 0.88], id: \.self) { xFrac in
                            Rectangle()
                                .fill(IVMaterialColors.waterBlue.opacity(0.3))
                                .frame(width: 8, height: h * 0.06)
                                .position(x: w * xFrac, y: roadY + h * 0.08)
                        }
                    }

                    // Rain button
                    if step >= 2 && !raining {
                        Button {
                            raining = true
                            SoundManager.shared.play(.tapSoft)
                            animateRain()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                withAnimation { step = 3 }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "cloud.rain.fill").font(.system(size: 13))
                                Text("Rain").font(RenaissanceFont.ivLabel)
                            }
                            .foregroundStyle(IVMaterialColors.waterBlue)
                            .padding(.horizontal, 12).padding(.vertical, 6)
                            .background(IVMaterialColors.waterBlue.opacity(0.1)).cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                        .position(x: cx, y: h * 0.2)
                    }

                    if step >= 3 {
                        FormulaText(text: "Invisible arc — rain sees it perfectly", highlighted: true)
                            .position(x: cx, y: h * 0.88)
                            .transition(.opacity)
                    }
                }
            }
        }
    }

    private func animateRain() {
        withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
            rainOffset = 1.0
        }
    }
}

// MARK: - 8. Road Mortar Recipe — Mix 1:3

private struct RoadMortarRecipeVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    @State private var limeScoops: Int = 0
    @State private var rockScoops: Int = 0
    @State private var ramCount: Int = 0

    private var mixComplete: Bool { limeScoops >= 1 && rockScoops >= 3 }
    private var ramComplete: Bool { ramCount >= 3 }

    private var label: String {
        if !mixComplete { return "1 lime : 3 crushed volcanic rock. Tap to add." }
        if !ramComplete { return "Tap to ram-pack — 50 times per m²." }
        return "Dry mix → add water → ram 50 times per m²."
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10).fill(RenaissanceColors.parchment)
            RoundedRectangle(cornerRadius: 10).strokeBorder(color.opacity(0.2), lineWidth: 1)
            IVBlueprintGrid()

            VStack(spacing: 10) {
                FormulaText(text: "1 Lime : 3 Volcanic Rock", highlighted: mixComplete)
                    .padding(.top, 8)

                // Ratio bar
                GeometryReader { geo in
                    let barW = geo.size.width - 20
                    HStack(spacing: 2) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(limeScoops >= 1 ? IVMaterialColors.limeTan : IVMaterialColors.stoneGray.opacity(0.15))
                            .frame(width: barW * 0.25)
                            .overlay { if limeScoops >= 1 { Text("1").font(RenaissanceFont.ivFormula).foregroundStyle(IVMaterialColors.sepiaInk) } }
                        RoundedRectangle(cornerRadius: 3)
                            .fill(rockScoops >= 3 ? basaltDark.opacity(0.4) : (rockScoops > 0 ? basaltDark.opacity(0.15 * CGFloat(rockScoops)) : IVMaterialColors.stoneGray.opacity(0.15)))
                            .frame(width: barW * 0.75)
                            .overlay { if rockScoops > 0 { Text("\(rockScoops)").font(RenaissanceFont.ivFormula).foregroundStyle(IVMaterialColors.sepiaInk) } }
                    }
                    .frame(height: 28)
                    .padding(.horizontal, 10)
                }
                .frame(height: 28)

                // Ingredient buttons
                if !mixComplete {
                    HStack(spacing: 16) {
                        Button {
                            guard limeScoops < 1 else { return }
                            withAnimation(.spring(response: 0.3)) { limeScoops += 1 }
                            SoundManager.shared.play(.tapSoft)
                        } label: {
                            VStack(spacing: 2) {
                                Text("CaO").font(RenaissanceFont.ivFormula)
                                Text("Lime").font(RenaissanceFont.ivBody)
                            }
                            .frame(width: 60, height: 50)
                            .background(limeScoops >= 1 ? IVMaterialColors.stoneGray.opacity(0.1) : IVMaterialColors.limeTan.opacity(0.3))
                            .cornerRadius(6)
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(limeScoops < 1 ? color : IVMaterialColors.stoneGray.opacity(0.3), lineWidth: limeScoops < 1 ? 2 : 1))
                        }
                        .buttonStyle(.plain)
                        .opacity(limeScoops >= 1 ? 0.4 : 1)

                        Button {
                            guard limeScoops >= 1, rockScoops < 3 else { return }
                            withAnimation(.spring(response: 0.3)) { rockScoops += 1 }
                            SoundManager.shared.play(.tapSoft)
                        } label: {
                            VStack(spacing: 2) {
                                Text("ite").font(RenaissanceFont.ivFormula)
                                Text("Volcanic Rock").font(RenaissanceFont.ivBody)
                            }
                            .frame(width: 80, height: 50)
                            .background(rockScoops >= 3 ? IVMaterialColors.stoneGray.opacity(0.1) : basaltDark.opacity(0.15))
                            .cornerRadius(6)
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke((limeScoops >= 1 && rockScoops < 3) ? color : IVMaterialColors.stoneGray.opacity(0.3), lineWidth: (limeScoops >= 1 && rockScoops < 3) ? 2 : 1))
                        }
                        .buttonStyle(.plain)
                        .opacity(rockScoops >= 3 ? 0.4 : 1)
                    }
                }

                // Ram-packing button
                if mixComplete && !ramComplete {
                    Button {
                        withAnimation(.spring(response: 0.2)) { ramCount += 1 }
                        SoundManager.shared.play(.tapSoft)
                        HapticsManager.shared.play(.buttonTap)
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.down.to.line").font(.system(size: 13))
                            Text("Ram (\(ramCount)/3)").font(RenaissanceFont.ivLabel)
                        }
                        .foregroundStyle(color)
                        .padding(.horizontal, 14).padding(.vertical, 6)
                        .background(color.opacity(0.1)).cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                }

                if ramComplete {
                    FormulaText(text: "50 rams per m² — solid as stone", highlighted: true)
                        .transition(.opacity)
                }

                Text(label)
                    .font(RenaissanceFont.ivBody)
                    .foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.6))
                    .multilineTextAlignment(.center)

                Spacer()
            }
            .padding(.horizontal, 12)
        }
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - 9. Lime Firing — Temperature Slider

private struct LimeFiringVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    @State private var temperature: CGFloat = 0

    private var tempC: Int { Int(temperature * 1200) }
    private var isConverting: Bool { tempC >= 800 && tempC <= 1000 }
    private var converted: Bool { tempC >= 900 }

    private var label: String {
        switch step {
        case 1: return "3 days at 900°C — limestone becomes quicklime."
        case 2: return "Drag the temperature. Quicklime burns skin and reacts violently with water."
        default: return "CaCO₃ → CaO + CO₂ — the foundation of Roman building."
        }
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10).fill(RenaissanceColors.parchment)
            RoundedRectangle(cornerRadius: 10).strokeBorder(color.opacity(0.2), lineWidth: 1)
            IVBlueprintGrid()

            VStack(spacing: 10) {
                HStack(spacing: 4) {
                    Image(systemName: "thermometer.medium").font(.system(size: 14))
                        .foregroundStyle(tempC > 600 ? .orange : IVMaterialColors.sepiaInk.opacity(0.4))
                    Text("\(tempC)°C").font(.custom("EBGaramond-Bold", size: 18))
                        .foregroundStyle(converted ? RenaissanceColors.sageGreen : IVMaterialColors.sepiaInk)
                        .monospacedDigit()
                }
                .padding(.top, 8)

                // Stone block transforming
                HStack(spacing: 20) {
                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(IVMaterialColors.stoneGray.opacity(converted ? 0.3 : 0.6))
                            .frame(width: 50, height: 40)
                        Text("CaCO₃").font(RenaissanceFont.ivFormula).foregroundStyle(IVMaterialColors.sepiaInk)
                        Text("Limestone").font(RenaissanceFont.ivBody).foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.5))
                    }

                    Image(systemName: "arrow.right")
                        .font(.system(size: 14))
                        .foregroundStyle(converted ? RenaissanceColors.sageGreen : IVMaterialColors.sepiaInk.opacity(0.3))

                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(converted ? 0.8 : 0.2))
                            .frame(width: 50, height: 40)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .strokeBorder(converted ? RenaissanceColors.sageGreen : IVMaterialColors.stoneGray.opacity(0.2), lineWidth: 1)
                            )
                        Text("CaO").font(RenaissanceFont.ivFormula).foregroundStyle(converted ? RenaissanceColors.sageGreen : IVMaterialColors.sepiaInk.opacity(0.3))
                        Text("Quicklime").font(RenaissanceFont.ivBody).foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.5))
                    }

                    // CO₂ escaping
                    if converted {
                        Text("+ CO₂ ↑")
                            .font(RenaissanceFont.ivFormula)
                            .foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.5))
                    }
                }

                Slider(value: $temperature, in: 0...1)
                    .tint(converted ? RenaissanceColors.sageGreen : .orange)
                    .frame(width: 200)
                    .onChange(of: temperature) { _, val in
                        if val * 1200 >= 900 { withAnimation { step = 3 } }
                    }

                HStack {
                    Text("0°C").font(RenaissanceFont.ivBody)
                    Spacer()
                    Text("900°C").font(RenaissanceFont.ivBody).foregroundStyle(RenaissanceColors.sageGreen)
                    Spacer()
                    Text("1200°C").font(RenaissanceFont.ivBody)
                }
                .foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.4))
                .frame(width: 200)

                if converted {
                    Text("⚠️ Burns skin — reacts violently with water")
                        .font(RenaissanceFont.ivBody)
                        .foregroundStyle(RenaissanceColors.errorRed.opacity(0.6))
                }

                Spacer()
            }
            .padding(.horizontal, 12)
        }
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - 10. Milestone Carving — Tap to Add Inscriptions

private struct MilestoneCarveVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    @State private var inscriptions: Int = 0

    private let carvings = [
        ("IMP · CAESAR", "Emperor's name"),
        ("VIA APPIA", "Road name"),
        ("MILIA · CXXIV", "Distance: 124 miles"),
    ]

    private var label: String {
        switch step {
        case 1: return "A milestone every 1,480 meters — the Roman mile."
        case 2:
            if inscriptions < 3 { return "Tap to carve: \(carvings[inscriptions].1)." }
            return "Emperor, road, distance — carved in stone every mile."
        default: return "Golden milestone in the Forum = mile zero for the empire."
        }
    }

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3,
                         step: $step, stepLabel: label, height: height) {
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let cx = w * 0.5
                let stoneW = w * 0.25
                let stoneH = h * 0.55

                ZStack {
                    // Milestone column
                    RoundedRectangle(cornerRadius: 6)
                        .fill(IVMaterialColors.stoneGray.opacity(0.4))
                        .frame(width: stoneW, height: stoneH)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .strokeBorder(IVMaterialColors.stoneGray, lineWidth: 1.5)
                        )
                        .position(x: cx, y: h * 0.4)

                    // Inscriptions (appear as carved)
                    ForEach(0..<inscriptions, id: \.self) { i in
                        Text(carvings[i].0)
                            .font(RenaissanceFont.visualTitle)
                            .tracking(1.5)
                            .foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.6))
                            .position(x: cx, y: h * 0.25 + CGFloat(i) * 22)
                            .transition(.opacity.combined(with: .scale(scale: 0.8)))
                    }

                    // Carve button
                    if step >= 2 && inscriptions < 3 {
                        Button {
                            withAnimation(.spring(response: 0.3)) { inscriptions += 1 }
                            SoundManager.shared.play(.tapSoft)
                            HapticsManager.shared.play(.buttonTap)
                            if inscriptions >= 3 {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    withAnimation { step = 3 }
                                }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "hammer.fill").font(.system(size: 13))
                                Text("Carve").font(RenaissanceFont.ivLabel)
                            }
                            .foregroundStyle(color)
                            .padding(.horizontal, 12).padding(.vertical, 6)
                            .background(color.opacity(0.1)).cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                        .position(x: cx, y: h * 0.78)
                    }

                    // Dimension
                    DimLabel(text: "1.8 m tall")
                        .position(x: cx + stoneW * 0.5 + 25, y: h * 0.4)

                    DimLabel(text: "Every 1,480 m")
                        .position(x: cx, y: h * 0.72)

                    if step >= 3 {
                        FormulaText(text: "Mile zero = Golden Milestone in the Forum", highlighted: true)
                            .position(x: cx, y: h * 0.88)
                            .transition(.opacity)
                    }
                }
            }
        }
    }
}
