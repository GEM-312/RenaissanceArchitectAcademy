import SwiftUI

/// Interactive science visuals for Aqueduct knowledge cards
/// Same pattern as PantheonInteractiveVisuals — TeachingContainer + step progression
struct AqueductInteractiveVisuals {

    @ViewBuilder
    static func view(for visual: CardVisual, color: Color, height: CGFloat = 275) -> some View {
        let h = height
        Group {
            switch visual.title {
            case let t where t.contains("Mostly Underground"):
                UndergroundRevealVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Chorobates"):
                ChorobatesTiltVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Right Gradient"):
                GradientSliderVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Voussoirs"):
                VoussoirArchBuildVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Specus"):
                SpecusCrossSectionVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Mortar vs Concrete"):
                MortarVsConcreteVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Dissolves vs Hardens"):
                UnderwaterComparisonVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Opus Signinum") || t.contains("Burnished"):
                OpusSigninumCoatsVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Lead Fistula"):
                FistulaPipeFabVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Mortar Recipe"):
                AqueductMortarRecipeVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Firing Terracotta"):
                TerracottaFiringVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Daily Flow"):
                DailyFlowVisual(visual: visual, color: color, height: h)
            default:
                EmptyView()
            }
        }
    }

    static func hasInteractiveVisual(for visual: CardVisual) -> Bool {
        let t = visual.title
        return t.contains("Mostly Underground") || t.contains("Chorobates") ||
               t.contains("Right Gradient") || t.contains("Voussoirs") ||
               t.contains("Specus") || t.contains("Mortar vs Concrete") ||
               t.contains("Dissolves vs Hardens") || t.contains("Opus Signinum") ||
               t.contains("Burnished") || t.contains("Lead Fistula") ||
               t.contains("Mortar Recipe") || t.contains("Firing Terracotta") ||
               t.contains("Daily Flow")
    }
}

// MARK: - Local Colors (unique to Aqueduct)

private let mortarTan = Color(red: 0.80, green: 0.75, blue: 0.65)
private let pozzolanaRed = Color(red: 0.65, green: 0.40, blue: 0.30)

private typealias VisualTitle = IVVisualTitle
private typealias AqueductBlueprintGrid = IVBlueprintGrid
private typealias TeachingContainer = IVTeachingContainer
private typealias StepControls = IVStepControls
private typealias DimLabel = IVDimLabel
private typealias FormulaText = IVFormulaText
private typealias DimLine = IVDimLine

// MARK: - 6. Mortar vs Concrete — Tap to Apply

private struct MortarVsConcreteVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    @State private var mortarApplied = false
    @State private var concreteApplied = false

    private var label: String {
        switch step {
        case 1: return "Mortar holds stones together. Concrete fills foundations."
        case 2:
            if !mortarApplied && !concreteApplied { return "Tap each material to apply it." }
            if mortarApplied && !concreteApplied { return "Now tap Concrete to fill the foundation." }
            if !mortarApplied && concreteApplied { return "Now tap Mortar to bind the stones." }
            return "Same binder (lime) — completely different jobs."
        default: return "Mortar = lime + sand (thin joints). Concrete = lime + ash + aggregate (bulk fill)."
        }
    }

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3,
                         step: $step, stepLabel: label, height: height) {
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let panelW = w * 0.42
                let panelH = h * 0.45
                let gap = w * 0.06

                ZStack {
                    // Left: Stone wall with mortar joints
                    let leftX = w * 0.5 - gap / 2 - panelW / 2
                    let topY = h * 0.08

                    VStack(spacing: 0) {
                        // Wall label
                        Text("MORTAR")
                            .font(RenaissanceFont.visualTitle)
                            .tracking(1)
                            .foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.5))

                        // Stone blocks with gaps
                        ZStack {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(IVMaterialColors.stoneGray.opacity(0.3))
                                .frame(width: panelW, height: panelH)

                            // Draw stone blocks
                            VStack(spacing: 3) {
                                ForEach(0..<3, id: \.self) { row in
                                    HStack(spacing: 3) {
                                        ForEach(0..<(row % 2 == 0 ? 3 : 2), id: \.self) { _ in
                                            RoundedRectangle(cornerRadius: 2)
                                                .fill(IVMaterialColors.stoneGray)
                                                .frame(height: panelH * 0.25)
                                        }
                                    }
                                }
                            }
                            .padding(4)
                            .frame(width: panelW, height: panelH)

                            // Mortar fill in joints
                            if mortarApplied {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(mortarTan.opacity(0.6))
                                    .frame(width: panelW, height: panelH)
                                    .mask {
                                        // Show only in the 3pt gaps between stones
                                        VStack(spacing: 0) {
                                            ForEach(0..<3, id: \.self) { _ in
                                                Rectangle().fill(.clear).frame(height: panelH * 0.25)
                                                Rectangle().fill(.white).frame(height: 3)
                                            }
                                        }
                                        .frame(width: panelW, height: panelH)
                                    }
                                    .transition(.opacity)
                            }
                        }

                        if mortarApplied {
                            Text("Lime + Sand")
                                .font(RenaissanceFont.ivBody)
                                .foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.6))
                                .transition(.opacity)
                        }
                    }
                    .position(x: leftX + panelW / 2, y: topY + panelH / 2 + 10)

                    // Right: Foundation pit with concrete fill
                    let rightX = w * 0.5 + gap / 2 + panelW / 2

                    VStack(spacing: 0) {
                        Text("CONCRETE")
                            .font(RenaissanceFont.visualTitle)
                            .tracking(1)
                            .foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.5))

                        ZStack(alignment: .bottom) {
                            // Pit outline
                            RoundedRectangle(cornerRadius: 4)
                                .strokeBorder(IVMaterialColors.stoneGray, lineWidth: 2)
                                .frame(width: panelW, height: panelH)

                            // Earth sides
                            HStack {
                                Rectangle().fill(RenaissanceColors.warmBrown.opacity(0.2)).frame(width: 4)
                                Spacer()
                                Rectangle().fill(RenaissanceColors.warmBrown.opacity(0.2)).frame(width: 4)
                            }
                            .frame(width: panelW, height: panelH)

                            // Concrete fill
                            if concreteApplied {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(IVMaterialColors.stoneGray.opacity(0.5))
                                    .frame(width: panelW - 8, height: panelH * 0.85)
                                    .overlay {
                                        // Aggregate dots
                                        ForEach(0..<8, id: \.self) { i in
                                            Circle()
                                                .fill(IVMaterialColors.stoneGray)
                                                .frame(width: CGFloat.random(in: 4...8))
                                                .offset(
                                                    x: CGFloat.random(in: -panelW * 0.3...panelW * 0.3),
                                                    y: CGFloat.random(in: -panelH * 0.2...panelH * 0.2)
                                                )
                                        }
                                    }
                                    .transition(.move(edge: .bottom).combined(with: .opacity))
                            }
                        }

                        if concreteApplied {
                            Text("Lime + Ash + Aggregate")
                                .font(RenaissanceFont.ivBody)
                                .foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.6))
                                .transition(.opacity)
                        }
                    }
                    .position(x: rightX - panelW / 2 + panelW / 2, y: topY + panelH / 2 + 10)

                    // Tap buttons (step 2)
                    if step >= 2 {
                        HStack(spacing: 12) {
                            if !mortarApplied {
                                Button {
                                    withAnimation(.spring(response: 0.4)) { mortarApplied = true }
                                    SoundManager.shared.play(.tapSoft)
                                    if concreteApplied { withAnimation { step = 3 } }
                                } label: {
                                    Text("Apply Mortar")
                                        .font(RenaissanceFont.ivLabel)
                                        .padding(.horizontal, 12).padding(.vertical, 6)
                                        .background(mortarTan.opacity(0.3))
                                        .cornerRadius(6)
                                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(mortarTan, lineWidth: 1))
                                }
                                .buttonStyle(.plain)
                            }
                            if !concreteApplied {
                                Button {
                                    withAnimation(.spring(response: 0.4)) { concreteApplied = true }
                                    SoundManager.shared.play(.tapSoft)
                                    if mortarApplied { withAnimation { step = 3 } }
                                } label: {
                                    Text("Pour Concrete")
                                        .font(RenaissanceFont.ivLabel)
                                        .padding(.horizontal, 12).padding(.vertical, 6)
                                        .background(IVMaterialColors.stoneGray.opacity(0.3))
                                        .cornerRadius(6)
                                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(IVMaterialColors.stoneGray, lineWidth: 1))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .position(x: w * 0.5, y: h * 0.85)
                        .transition(.opacity)
                    }

                    // Final formula (step 3)
                    if step >= 3 {
                        FormulaText(text: "Same lime binder — different jobs", highlighted: true)
                            .position(x: w * 0.5, y: h * 0.85)
                            .transition(.opacity)
                    }
                }
            }
        }
    }
}

// MARK: - 5. Specus Channel Cross-Section — Tap to Reveal + Water

private struct SpecusCrossSectionVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    @State private var revealedLayers: Set<Int> = [] // 0=stone, 1=signinum, 2=channel
    @State private var waterLevel: CGFloat = 0

    private var label: String {
        switch step {
        case 1: return "The specus — the water channel inside every Roman aqueduct."
        case 2:
            if revealedLayers.count < 3 { return "Tap each layer to reveal the cross-section." }
            return "Three layers: stone wall, waterproof lining, water channel."
        case 3: return "Water flows by gravity alone — no pumps needed."
        default: return "Fountains first, baths second, private homes last."
        }
    }

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 4,
                         step: $step, stepLabel: label, height: height) {
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let chW = w * 0.35  // channel width
                let chH = h * 0.65  // channel height
                let cx = w * 0.5
                let cy = h * 0.42

                ZStack {
                    // Outer stone wall
                    let stoneW = chW + 24
                    let stoneH = chH + 12
                    RoundedRectangle(cornerRadius: 4)
                        .fill(revealedLayers.contains(0) ? IVMaterialColors.stoneGray : IVMaterialColors.stoneGray.opacity(0.15))
                        .frame(width: stoneW, height: stoneH)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .strokeBorder(IVMaterialColors.stoneGray, lineWidth: revealedLayers.contains(0) ? 2 : 1)
                        )
                        .position(x: cx, y: cy)
                        .onTapGesture {
                            guard step >= 2 else { return }
                            withAnimation(.spring(response: 0.3)) { revealedLayers.insert(0) }
                            SoundManager.shared.play(.tapSoft)
                            checkAllRevealed()
                        }

                    // Signinum lining
                    let linW = chW + 8
                    let linH = chH - 4
                    RoundedRectangle(cornerRadius: 3)
                        .fill(revealedLayers.contains(1) ? RenaissanceColors.terracotta.opacity(0.4) : Color.clear)
                        .frame(width: linW, height: linH)
                        .overlay(
                            RoundedRectangle(cornerRadius: 3)
                                .strokeBorder(
                                    revealedLayers.contains(1) ? RenaissanceColors.terracotta : IVMaterialColors.stoneGray.opacity(0.3),
                                    lineWidth: revealedLayers.contains(1) ? 2 : 1
                                )
                        )
                        .position(x: cx, y: cy + 4)
                        .onTapGesture {
                            guard step >= 2 else { return }
                            withAnimation(.spring(response: 0.3)) { revealedLayers.insert(1) }
                            SoundManager.shared.play(.tapSoft)
                            checkAllRevealed()
                        }

                    // Water channel
                    ZStack(alignment: .bottom) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(revealedLayers.contains(2) ? IVMaterialColors.waterBlue.opacity(0.15) : Color.clear)
                            .frame(width: chW, height: chH - 16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 2)
                                    .strokeBorder(
                                        revealedLayers.contains(2) ? IVMaterialColors.waterBlue : IVMaterialColors.stoneGray.opacity(0.2),
                                        lineWidth: revealedLayers.contains(2) ? 1.5 : 0.5
                                    )
                            )

                        // Water fill (step 3+)
                        if step >= 3 {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(IVMaterialColors.waterBlue.opacity(0.5))
                                .frame(width: chW - 2, height: (chH - 18) * waterLevel)
                        }
                    }
                    .frame(width: chW, height: chH - 16)
                    .position(x: cx, y: cy + 8)
                    .onTapGesture {
                        guard step >= 2 else { return }
                        withAnimation(.spring(response: 0.3)) { revealedLayers.insert(2) }
                        SoundManager.shared.play(.tapSoft)
                        checkAllRevealed()
                    }

                    // Layer labels (step 2+)
                    if step >= 2 {
                        // Stone label
                        DimLabel(text: "Stone wall")
                            .position(x: cx + chW * 0.5 + 30, y: cy - chH * 0.3)
                            .opacity(revealedLayers.contains(0) ? 1 : 0.4)

                        // Signinum label
                        DimLabel(text: "Opus signinum")
                            .position(x: cx + chW * 0.5 + 30, y: cy)
                            .opacity(revealedLayers.contains(1) ? 1 : 0.4)

                        // Channel label
                        DimLabel(text: "Water channel")
                            .position(x: cx + chW * 0.5 + 30, y: cy + chH * 0.25)
                            .opacity(revealedLayers.contains(2) ? 1 : 0.4)
                    }

                    // Dimension lines (step 2+)
                    if step >= 2 && revealedLayers.count == 3 {
                        // Width dimension
                        DimLine(from: CGPoint(x: cx - chW * 0.5, y: cy + chH * 0.5 + 12),
                                to: CGPoint(x: cx + chW * 0.5, y: cy + chH * 0.5 + 12))
                            .stroke(IVMaterialColors.dimColor, lineWidth: 0.8)
                        DimLabel(text: "0.9 m")
                            .position(x: cx, y: cy + chH * 0.5 + 22)

                        // Height dimension
                        DimLine(from: CGPoint(x: cx - chW * 0.5 - 16, y: cy - chH * 0.5 + 6),
                                to: CGPoint(x: cx - chW * 0.5 - 16, y: cy + chH * 0.5 - 2))
                            .stroke(IVMaterialColors.dimColor, lineWidth: 0.8)
                        DimLabel(text: "1.5 m")
                            .rotationEffect(.degrees(-90))
                            .position(x: cx - chW * 0.5 - 30, y: cy)
                    }

                    // Flow arrow (step 3)
                    if step >= 3 {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(IVMaterialColors.waterBlue)
                            .position(x: cx, y: cy - chH * 0.35)
                    }

                    // Distribution (step 4)
                    if step >= 4 {
                        HStack(spacing: 8) {
                            VStack(spacing: 2) {
                                Image(systemName: "drop.fill").font(.system(size: 13)).foregroundStyle(IVMaterialColors.waterBlue)
                                Text("Fountains").font(RenaissanceFont.ivBody)
                                Text("1st").font(RenaissanceFont.ivFormula).foregroundStyle(color)
                            }
                            VStack(spacing: 2) {
                                Image(systemName: "humidity.fill").font(.system(size: 13)).foregroundStyle(IVMaterialColors.waterBlue.opacity(0.7))
                                Text("Baths").font(RenaissanceFont.ivBody)
                                Text("2nd").font(RenaissanceFont.ivFormula).foregroundStyle(color)
                            }
                            VStack(spacing: 2) {
                                Image(systemName: "house.fill").font(.system(size: 13)).foregroundStyle(IVMaterialColors.waterBlue.opacity(0.4))
                                Text("Homes").font(RenaissanceFont.ivBody)
                                Text("3rd").font(RenaissanceFont.ivFormula).foregroundStyle(color)
                            }
                        }
                        .foregroundStyle(IVMaterialColors.sepiaInk)
                        .position(x: cx, y: h * 0.12)
                        .transition(.opacity)
                    }
                }
            }
        }
        .onChange(of: step) { _, newStep in
            if newStep >= 3 && waterLevel == 0 {
                withAnimation(.easeInOut(duration: 1.2)) { waterLevel = 0.7 }
            }
        }
    }

    private func checkAllRevealed() {
        if revealedLayers.count == 3 && step == 2 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation { step = 3 }
            }
        }
    }
}

// MARK: - 1. Underground Reveal — Tap Route Sections

private struct UndergroundRevealVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    @State private var revealedSections: Set<Int> = []
    @State private var waterOffset: CGFloat = 0

    // 7 terrain control points (Bézier hills — mountains to city)
    private let terrainPoints: [CGPoint] = [
        CGPoint(x: 0.0,  y: 0.22),  // mountain peak (high = low Y)
        CGPoint(x: 0.14, y: 0.35),  // mountain slope
        CGPoint(x: 0.28, y: 0.52),  // first valley
        CGPoint(x: 0.42, y: 0.38),  // hill between valleys
        CGPoint(x: 0.58, y: 0.55),  // second valley (arches cross here)
        CGPoint(x: 0.75, y: 0.42),  // plateau
        CGPoint(x: 1.0,  y: 0.48),  // Rome (lower ground)
    ]

    // Aqueduct channel follows terrain when underground, rises on arches over valleys
    private let aqueductPoints: [CGPoint] = [
        CGPoint(x: 0.0,  y: 0.20),  // starts at spring (in the mountain)
        CGPoint(x: 0.14, y: 0.30),  // underground — just below terrain
        CGPoint(x: 0.28, y: 0.38),  // ABOVE valley — on arches!
        CGPoint(x: 0.42, y: 0.34),  // underground through hill
        CGPoint(x: 0.58, y: 0.40),  // ABOVE valley — on arches!
        CGPoint(x: 0.75, y: 0.39),  // underground through plateau
        CGPoint(x: 1.0,  y: 0.43),  // arrives at Rome castellum
    ]

    // Which sections are underground vs on arches
    private let sectionCount = 6
    private let isUnderground = [true, true, false, true, false, true]

    private var label: String {
        switch step {
        case 1: return "69 km from mountain springs to Rome — follow the gradient."
        case 2:
            if revealedSections.count < sectionCount { return "Tap each section to reveal the aqueduct path." }
            return "Tunnels through hills, arches across valleys."
        case 3: return "Water flows by gravity — no pumps for 69 km."
        default: return "85% invisible — the longest engineering project of the ancient world."
        }
    }

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 4,
                         step: $step, stepLabel: label, height: height) {
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let margin: CGFloat = 12

                ZStack {
                    // Filled terrain (Bézier hills) — earth color below the curve
                    terrainFill(w: w, h: h, margin: margin)
                        .fill(RenaissanceColors.warmBrown.opacity(0.12))

                    // Terrain outline (Bézier curve)
                    terrainPath(w: w, h: h, margin: margin)
                        .stroke(RenaissanceColors.warmBrown.opacity(0.5), lineWidth: 2)

                    // Aqueduct channel path (step 2+ as sections are revealed)
                    if !revealedSections.isEmpty {
                        // Underground sections: dashed, inside terrain
                        aqueductPath(w: w, h: h, margin: margin, underground: true)
                            .stroke(style: StrokeStyle(lineWidth: 2, dash: [4, 3]))
                            .foregroundStyle(RenaissanceColors.warmBrown.opacity(0.5))

                        // Above-ground sections: solid with arch supports
                        aqueductPath(w: w, h: h, margin: margin, underground: false)
                            .stroke(IVMaterialColors.stoneGray, lineWidth: 2.5)

                        // Draw arch piers under above-ground sections
                        archPiers(w: w, h: h, margin: margin)
                    }

                    // Water flow animation (step 3+)
                    if step >= 3 {
                        waterDrops(w: w, h: h, margin: margin)
                    }

                    // Source and destination
                    Image(systemName: "mountain.2.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(RenaissanceColors.warmBrown.opacity(0.5))
                        .position(x: margin + 8, y: h * 0.08)
                    Text("Springs")
                        .font(RenaissanceFont.ivBody)
                        .foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.5))
                        .position(x: margin + 8, y: h * 0.16)

                    Image(systemName: "building.columns.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(RenaissanceColors.warmBrown.opacity(0.5))
                        .position(x: w - margin - 8, y: h * 0.32)
                    Text("Rome")
                        .font(RenaissanceFont.ivBody)
                        .foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.5))
                        .position(x: w - margin - 8, y: h * 0.40)

                    // Tappable sections (step 2+)
                    if step >= 2 {
                        ForEach(0..<sectionCount, id: \.self) { i in
                            let t0 = CGFloat(i) / CGFloat(sectionCount)
                            let t1 = CGFloat(i + 1) / CGFloat(sectionCount)
                            let midT = (t0 + t1) / 2
                            let x = margin + midT * (w - margin * 2)
                            let revealed = revealedSections.contains(i)

                            if !revealed {
                                // Dashed box with "?" at midpoint of section
                                RoundedRectangle(cornerRadius: 4)
                                    .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [3, 3]))
                                    .foregroundStyle(color.opacity(0.4))
                                    .frame(width: 28, height: 28)
                                    .overlay {
                                        Text("?")
                                            .font(RenaissanceFont.ivFormula)
                                            .foregroundStyle(color.opacity(0.4))
                                    }
                                    .position(x: x, y: h * 0.75)
                                    .onTapGesture {
                                        withAnimation(.spring(response: 0.3)) { revealedSections.insert(i) }
                                        SoundManager.shared.play(.tapSoft)
                                        if revealedSections.count == sectionCount {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                withAnimation { step = 3 }
                                            }
                                        }
                                    }
                            } else {
                                // Label: tunnel or arches
                                Text(isUnderground[i] ? "tunnel" : "arches")
                                    .font(RenaissanceFont.ivBody)
                                    .foregroundStyle(isUnderground[i] ? RenaissanceColors.warmBrown.opacity(0.5) : IVMaterialColors.stoneGray)
                                    .position(x: x, y: h * 0.75)
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                    }

                    // Legend + formula (step 4)
                    if step >= 4 {
                        VStack(spacing: 3) {
                            HStack(spacing: 12) {
                                HStack(spacing: 4) {
                                    Path { p in p.move(to: .zero); p.addLine(to: CGPoint(x: 16, y: 0)) }
                                        .stroke(style: StrokeStyle(lineWidth: 2, dash: [4, 3]))
                                        .foregroundStyle(RenaissanceColors.warmBrown.opacity(0.5))
                                        .frame(width: 16, height: 2)
                                    DimLabel(text: "53 km underground")
                                }
                                HStack(spacing: 4) {
                                    Rectangle().fill(IVMaterialColors.stoneGray).frame(width: 16, height: 2)
                                    DimLabel(text: "16 km on arches")
                                }
                            }
                            FormulaText(text: "85% invisible", highlighted: true)
                        }
                        .position(x: w * 0.5, y: h * 0.88)
                        .transition(.opacity)
                    }
                }
            }
        }
        .onAppear { animateWater() }
    }

    // MARK: - Bézier Terrain

    /// Smooth Catmull-Rom curve through terrain points (outline only)
    private func terrainPath(w: CGFloat, h: CGFloat, margin: CGFloat) -> Path {
        catmullRomPath(points: terrainPoints, w: w, h: h, margin: margin)
    }

    /// Filled terrain shape (curve + bottom edge)
    private func terrainFill(w: CGFloat, h: CGFloat, margin: CGFloat) -> Path {
        var path = catmullRomPath(points: terrainPoints, w: w, h: h, margin: margin)
        let pts = terrainPoints.map { denorm($0, w: w, h: h, margin: margin) }
        if let last = pts.last, let first = pts.first {
            path.addLine(to: CGPoint(x: last.x, y: h))
            path.addLine(to: CGPoint(x: first.x, y: h))
            path.closeSubpath()
        }
        return path
    }

    // MARK: - Aqueduct Path

    /// Draw aqueduct path — underground or above-ground sections only
    private func aqueductPath(w: CGFloat, h: CGFloat, margin: CGFloat, underground: Bool) -> Path {
        let pts = aqueductPoints.map { denorm($0, w: w, h: h, margin: margin) }
        var path = Path()
        for i in 0..<sectionCount {
            guard revealedSections.contains(i) else { continue }
            guard isUnderground[i] == underground else { continue }
            let startIdx = i
            let endIdx = i + 1
            guard startIdx < pts.count && endIdx < pts.count else { continue }
            path.move(to: pts[startIdx])
            path.addLine(to: pts[endIdx])
        }
        return path
    }

    /// Draw arch piers under above-ground aqueduct sections (Canvas-based)
    private func archPiers(w: CGFloat, h: CGFloat, margin: CGFloat) -> some View {
        let aqPts = aqueductPoints.map { denorm($0, w: w, h: h, margin: margin) }
        let terrPts = terrainPoints.map { denorm($0, w: w, h: h, margin: margin) }

        return Canvas { context, size in
            for i in 0..<sectionCount {
                guard revealedSections.contains(i), !isUnderground[i] else { continue }
                guard i + 1 < aqPts.count, i + 1 < terrPts.count else { continue }

                let aqY = (aqPts[i].y + aqPts[i + 1].y) / 2
                let terrY = (terrPts[i].y + terrPts[i + 1].y) / 2
                let spanX = aqPts[i + 1].x - aqPts[i].x
                let pierCount = 3

                for p in 0..<pierCount {
                    let px = aqPts[i].x + spanX * CGFloat(p + 1) / CGFloat(pierCount + 1)

                    // Pier line
                    var pier = Path()
                    pier.move(to: CGPoint(x: px, y: aqY))
                    pier.addLine(to: CGPoint(x: px, y: terrY))
                    context.stroke(pier, with: .color(IVMaterialColors.stoneGray.opacity(0.5)), lineWidth: 1.5)

                    // Small arch between piers
                    if p < pierCount - 1 {
                        let nextPx = aqPts[i].x + spanX * CGFloat(p + 2) / CGFloat(pierCount + 1)
                        var arch = Path()
                        arch.move(to: CGPoint(x: px, y: aqY + 2))
                        arch.addQuadCurve(
                            to: CGPoint(x: nextPx, y: aqY + 2),
                            control: CGPoint(x: (px + nextPx) / 2, y: aqY + (terrY - aqY) * 0.25)
                        )
                        context.stroke(arch, with: .color(IVMaterialColors.stoneGray.opacity(0.4)), lineWidth: 1)
                    }
                }
            }
        }
        .frame(width: w, height: h)
        .allowsHitTesting(false)
    }

    // MARK: - Water Flow

    private func waterDrops(w: CGFloat, h: CGFloat, margin: CGFloat) -> some View {
        let pts = aqueductPoints.map { denorm($0, w: w, h: h, margin: margin) }

        return Canvas { context, size in
            for i in 0..<4 {
                let baseProgress = (waterOffset + CGFloat(i) * 0.25).truncatingRemainder(dividingBy: 1.0)
                let totalLen = CGFloat(pts.count - 1)
                let segment = baseProgress * totalLen
                let segIdx = Int(segment)
                let segFrac = segment - CGFloat(segIdx)

                if segIdx < pts.count - 1 {
                    let p0 = pts[segIdx]
                    let p1 = pts[segIdx + 1]
                    let dropX = p0.x + (p1.x - p0.x) * segFrac
                    let dropY = p0.y + (p1.y - p0.y) * segFrac

                    let rect = CGRect(x: dropX - 2.5, y: dropY - 2.5, width: 5, height: 5)
                    context.fill(Path(ellipseIn: rect), with: .color(IVMaterialColors.waterBlue.opacity(0.8)))
                }
            }
        }
        .frame(width: w, height: h)
        .allowsHitTesting(false)
    }

    private func animateWater() {
        withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
            waterOffset = 1.0
        }
    }

    // MARK: - Curve Helpers

    private func catmullRomPath(points: [CGPoint], w: CGFloat, h: CGFloat, margin: CGFloat) -> Path {
        let pts = points.map { denorm($0, w: w, h: h, margin: margin) }
        guard pts.count >= 2 else { return Path() }
        return Path { path in
            path.move(to: pts[0])
            for i in 0..<pts.count - 1 {
                let p0 = i > 0 ? pts[i - 1] : pts[i]
                let p1 = pts[i]
                let p2 = pts[i + 1]
                let p3 = i + 2 < pts.count ? pts[i + 2] : pts[i + 1]
                let cp1 = CGPoint(x: p1.x + (p2.x - p0.x) / 6, y: p1.y + (p2.y - p0.y) / 6)
                let cp2 = CGPoint(x: p2.x - (p3.x - p1.x) / 6, y: p2.y - (p3.y - p1.y) / 6)
                path.addCurve(to: p2, control1: cp1, control2: cp2)
            }
        }
    }

    private func denorm(_ pt: CGPoint, w: CGFloat, h: CGFloat, margin: CGFloat) -> CGPoint {
        CGPoint(x: margin + pt.x * (w - margin * 2), y: pt.y * h)
    }
}

// MARK: - 2. Chorobates Tilt — Drag to Level

private struct ChorobatesTiltVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    @State private var beamTilt: CGFloat = 0

    private var label: String {
        switch step {
        case 1: return "A 6-meter wooden beam with a water channel on top."
        case 2: return "Drag left/right to tilt — the water stays level."
        default: return "1:4800 gradient — a marble on the floor rolls faster than the water."
        }
    }

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3,
                         step: $step, stepLabel: label, height: height) {
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let beamW = w * 0.75
                let beamH: CGFloat = 14
                let legH: CGFloat = h * 0.22
                let cx = w * 0.5
                let cy = h * 0.45

                ZStack {
                    // Ground line
                    Path { p in
                        p.move(to: CGPoint(x: w * 0.08, y: cy + legH + beamH / 2))
                        p.addLine(to: CGPoint(x: w * 0.92, y: cy + legH + beamH / 2))
                    }
                    .stroke(RenaissanceColors.warmBrown.opacity(0.2), lineWidth: 1)

                    // Beam assembly (rotates)
                    Group {
                        // Legs
                        let legOffset = beamW * 0.38
                        ForEach([-1.0, 1.0], id: \.self) { side in
                            Path { p in
                                let x = cx + side * legOffset
                                p.move(to: CGPoint(x: x, y: 0))
                                p.addLine(to: CGPoint(x: x, y: legH))
                            }
                            .stroke(RenaissanceColors.warmBrown.opacity(0.6), lineWidth: 3)
                        }

                        // Main beam
                        RoundedRectangle(cornerRadius: 2)
                            .fill(RenaissanceColors.warmBrown.opacity(0.5))
                            .frame(width: beamW, height: beamH)
                            .offset(y: -legH / 2 - beamH / 2 + legH / 2)

                        // Water channel on top of beam
                        ZStack {
                            // Channel trough
                            RoundedRectangle(cornerRadius: 1)
                                .fill(RenaissanceColors.warmBrown.opacity(0.3))
                                .frame(width: beamW * 0.85, height: 6)

                            // Water surface (counter-rotates to stay level)
                            RoundedRectangle(cornerRadius: 1)
                                .fill(IVMaterialColors.waterBlue.opacity(0.6))
                                .frame(width: beamW * 0.8, height: 3)
                                .rotationEffect(.degrees(-beamTilt * 8))
                        }
                        .offset(y: -legH / 2 - beamH - 1)
                    }
                    .rotationEffect(.degrees(step >= 2 ? beamTilt * 8 : 0))
                    .position(x: cx, y: cy)

                    // Drag gesture overlay (step 2)
                    if step >= 2 {
                        Color.clear
                            .contentShape(Rectangle())
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        let drag = value.translation.width / (w * 0.5)
                                        beamTilt = max(-1, min(1, drag))
                                    }
                                    .onEnded { _ in
                                        withAnimation(.spring(response: 0.3)) { beamTilt = 0 }
                                    }
                            )
                    }

                    // Dimension line
                    DimLine(from: CGPoint(x: cx - beamW * 0.38, y: cy + legH * 0.6),
                            to: CGPoint(x: cx + beamW * 0.38, y: cy + legH * 0.6))
                        .stroke(IVMaterialColors.dimColor, lineWidth: 0.8)
                    DimLabel(text: "6 m")
                        .position(x: cx, y: cy + legH * 0.6 + 12)

                    // Final formula (step 3)
                    if step >= 3 {
                        FormulaText(text: "Gradient: 1 : 4,800", highlighted: true)
                            .position(x: cx, y: h * 0.12)
                            .transition(.opacity)
                    }
                }
            }
        }
    }
}

// MARK: - 3. Gradient Slider — Water Flow Speed

private struct GradientSliderVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    @State private var slopeValue: CGFloat = 0.5
    @State private var waterOffset: CGFloat = 0

    private var slopeLabel: String {
        if slopeValue < 0.3 { return "Too gentle — water stagnates" }
        if slopeValue > 0.7 { return "Too steep — water erodes the channel" }
        return "Just right — steady flow"
    }

    private var label: String {
        switch step {
        case 1: return "Water needs gravity to flow — but how much slope?"
        case 2: return "Drag the slider to find the perfect gradient."
        default: return "1:4,800 — no pumps, just math."
        }
    }

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3,
                         step: $step, stepLabel: label, height: height) {
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let channelY = h * 0.35
                let dropAngle = (slopeValue - 0.5) * 20 // -10 to +10 degrees

                ZStack {
                    // Channel profile
                    let leftX = w * 0.1
                    let rightX = w * 0.9
                    let leftY = channelY - CGFloat(dropAngle)
                    let rightY = channelY + CGFloat(dropAngle)

                    // Channel body
                    Path { p in
                        p.move(to: CGPoint(x: leftX, y: leftY - 8))
                        p.addLine(to: CGPoint(x: rightX, y: rightY - 8))
                        p.addLine(to: CGPoint(x: rightX, y: rightY + 8))
                        p.addLine(to: CGPoint(x: leftX, y: leftY + 8))
                        p.closeSubpath()
                    }
                    .fill(IVMaterialColors.stoneGray.opacity(0.3))

                    Path { p in
                        p.move(to: CGPoint(x: leftX, y: leftY - 8))
                        p.addLine(to: CGPoint(x: rightX, y: rightY - 8))
                        p.addLine(to: CGPoint(x: rightX, y: rightY + 8))
                        p.addLine(to: CGPoint(x: leftX, y: leftY + 8))
                        p.closeSubpath()
                    }
                    .stroke(IVMaterialColors.stoneGray, lineWidth: 1.5)

                    // Water drops flowing
                    if step >= 2 {
                        let speed = max(0.1, slopeValue)
                        ForEach(0..<3, id: \.self) { i in
                            let baseX = leftX + (rightX - leftX) * CGFloat(i) / 3.0
                            let progress = (waterOffset + CGFloat(i) * 0.33).truncatingRemainder(dividingBy: 1.0)
                            let dropX = leftX + (rightX - leftX) * progress
                            let dropY = leftY + (rightY - leftY) * progress
                            Circle()
                                .fill(IVMaterialColors.waterBlue)
                                .frame(width: 6, height: 6)
                                .position(x: dropX, y: dropY)
                                .opacity(slopeValue < 0.25 ? 0.2 : 0.8)
                        }
                    }

                    // Status indicators
                    if step >= 2 {
                        // Stagnation / erosion feedback
                        if slopeValue < 0.3 {
                            Text("STAGNANT")
                                .font(RenaissanceFont.visualTitle)
                                .foregroundStyle(RenaissanceColors.sageGreen.opacity(0.6))
                                .position(x: w * 0.5, y: channelY - 30)
                        } else if slopeValue > 0.7 {
                            Text("EROSION")
                                .font(RenaissanceFont.visualTitle)
                                .foregroundStyle(RenaissanceColors.errorRed.opacity(0.6))
                                .position(x: w * 0.5, y: channelY - 30)
                        } else {
                            FormulaText(text: "34 cm / km", highlighted: true)
                                .position(x: w * 0.5, y: channelY - 30)
                        }

                        // Slider
                        VStack(spacing: 4) {
                            Slider(value: $slopeValue, in: 0...1)
                                .tint(slopeValue < 0.3 || slopeValue > 0.7 ? RenaissanceColors.errorRed : color)
                                .frame(width: w * 0.7)
                            HStack {
                                Text("Gentle").font(RenaissanceFont.ivBody).foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.4))
                                Spacer()
                                Text("Steep").font(RenaissanceFont.ivBody).foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.4))
                            }
                            .frame(width: w * 0.7)
                        }
                        .position(x: w * 0.5, y: h * 0.72)
                    }

                    // Source & destination icons
                    Image(systemName: "mountain.2.fill")
                        .font(.system(size: 13))
                        .foregroundStyle(RenaissanceColors.warmBrown.opacity(0.3))
                        .position(x: leftX - 2, y: leftY - 22)
                    Image(systemName: "building.columns.fill")
                        .font(.system(size: 13))
                        .foregroundStyle(RenaissanceColors.warmBrown.opacity(0.3))
                        .position(x: rightX + 2, y: rightY - 22)
                }
            }
        }
        .onAppear {
            animateWater()
        }
    }

    private func animateWater() {
        withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
            waterOffset = 1.0
        }
    }
}

// MARK: - 4. Voussoir Arch Build — Tap Stones Into Place

private struct VoussoirArchBuildVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    @State private var placedStones: Set<Int> = []

    private let stoneCount = 7 // 6 voussoirs + 1 keystone (index 6)
    private var keystonePlaced: Bool { placedStones.contains(stoneCount - 1) }

    private var label: String {
        switch step {
        case 1: return "An arch needs every stone. Build from the bottom up."
        case 2:
            if placedStones.count < stoneCount - 1 { return "Tap voussoirs to place them — bottom to top." }
            if !keystonePlaced { return "Now place the keystone — the last stone locks it all." }
            return "Every stone pushes against its neighbor."
        default: return "Compression makes arches strong — they want to fall, but can't."
        }
    }

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3,
                         step: $step, stepLabel: label, height: height) {
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let cx = w * 0.5
                let archRadius = min(w * 0.35, h * 0.4)
                let archCenterY = h * 0.55
                let pierW: CGFloat = 14
                let pierH = h * 0.35

                ZStack {
                    // Support piers
                    RoundedRectangle(cornerRadius: 2)
                        .fill(IVMaterialColors.stoneGray)
                        .frame(width: pierW, height: pierH)
                        .position(x: cx - archRadius - pierW / 2, y: archCenterY + pierH * 0.2)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(IVMaterialColors.stoneGray)
                        .frame(width: pierW, height: pierH)
                        .position(x: cx + archRadius + pierW / 2, y: archCenterY + pierH * 0.2)

                    // Centering scaffold (dashed arc, fades when keystone placed)
                    Path { p in
                        p.addArc(center: CGPoint(x: cx, y: archCenterY),
                                radius: archRadius - 6,
                                startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
                    }
                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                    .foregroundStyle(RenaissanceColors.warmBrown.opacity(keystonePlaced ? 0 : 0.3))
                    .animation(.easeOut(duration: 0.5), value: keystonePlaced)

                    // Voussoir slots (step 2+)
                    if step >= 2 {
                        ForEach(0..<stoneCount, id: \.self) { i in
                            let placed = placedStones.contains(i)
                            let isKeystone = i == stoneCount - 1
                            // Angles: spread evenly from 180 to 0 degrees
                            let startDeg = 180.0 - Double(i) * (180.0 / Double(stoneCount))
                            let endDeg = 180.0 - Double(i + 1) * (180.0 / Double(stoneCount))
                            let midDeg = (startDeg + endDeg) / 2.0
                            let midRad = midDeg * .pi / 180.0

                            let stoneX = cx + archRadius * 0.85 * cos(CGFloat(midRad)) * -1
                            let stoneY = archCenterY - archRadius * 0.85 * sin(CGFloat(midRad))

                            let canPlace: Bool = {
                                if isKeystone { return placedStones.count == stoneCount - 1 }
                                // Allow placing from either side (bottom up)
                                let leftCount = placedStones.filter { $0 < stoneCount / 2 }.count
                                let rightCount = placedStones.filter { $0 >= stoneCount / 2 && $0 < stoneCount - 1 }.count
                                if i < stoneCount / 2 { return i == leftCount }
                                if i < stoneCount - 1 { return i - stoneCount / 2 == rightCount }
                                return false
                            }()

                            // Stone wedge
                            RoundedRectangle(cornerRadius: 2)
                                .fill(placed ? (isKeystone ? color.opacity(0.6) : IVMaterialColors.stoneGray) : IVMaterialColors.stoneGray.opacity(0.1))
                                .frame(width: 18, height: 24)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 2)
                                        .strokeBorder(
                                            placed ? IVMaterialColors.stoneGray : (canPlace ? color : IVMaterialColors.stoneGray.opacity(0.2)),
                                            lineWidth: canPlace && !placed ? 2 : 1
                                        )
                                )
                                .rotationEffect(.degrees(90 - midDeg))
                                .position(x: stoneX, y: stoneY)
                                .opacity(placed ? 1 : (canPlace ? 0.7 : 0.3))
                                .onTapGesture {
                                    guard step >= 2, canPlace, !placed else { return }
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

                    // Compression arrows (step 3)
                    if step >= 3 {
                        ForEach(0..<stoneCount, id: \.self) { i in
                            let startDeg = 180.0 - Double(i) * (180.0 / Double(stoneCount))
                            let endDeg = 180.0 - Double(i + 1) * (180.0 / Double(stoneCount))
                            let midDeg = (startDeg + endDeg) / 2.0
                            let midRad = midDeg * .pi / 180.0
                            let arrowX = cx + (archRadius * 0.55) * cos(CGFloat(midRad)) * -1
                            let arrowY = archCenterY - (archRadius * 0.55) * sin(CGFloat(midRad))

                            Image(systemName: "arrow.down.to.line")
                                .font(.system(size: 13))
                                .foregroundStyle(RenaissanceColors.errorRed.opacity(0.6))
                                .rotationEffect(.degrees(90 - midDeg))
                                .position(x: arrowX, y: arrowY)
                        }

                        FormulaText(text: "Compression — strong because it wants to fall", highlighted: true)
                            .position(x: cx, y: h * 0.08)
                            .transition(.opacity)
                    }
                }
            }
        }
    }
}

// MARK: - 7. Underwater Comparison — Pour Water

private struct UnderwaterComparisonVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    @State private var waterPoured = false
    @State private var waterLevel: CGFloat = 0
    @State private var dissolvePhase: CGFloat = 1.0

    private var label: String {
        switch step {
        case 1: return "Two materials, one test: what happens underwater?"
        case 2:
            if !waterPoured { return "Tap to pour water — watch what happens." }
            return "Normal mortar dissolves. Pozzolanic concrete hardens."
        default: return "Discovered at Pozzuoli — the material that conquers water."
        }
    }

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3,
                         step: $step, stepLabel: label, height: height) {
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let blockW = w * 0.28
                let blockH = h * 0.25
                let baseY = h * 0.55

                ZStack {
                    // Left block: Normal mortar
                    VStack(spacing: 4) {
                        Text("Normal Mortar")
                            .font(RenaissanceFont.visualTitle)
                            .tracking(0.5)
                            .foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.5))

                        ZStack {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(mortarTan)
                                .frame(width: blockW, height: blockH)
                                .opacity(dissolvePhase)

                            // Crack lines when dissolving
                            if waterPoured {
                                ForEach(0..<3, id: \.self) { i in
                                    Path { p in
                                        p.move(to: CGPoint(x: blockW * 0.2, y: blockH * CGFloat(i + 1) * 0.25))
                                        p.addLine(to: CGPoint(x: blockW * 0.8, y: blockH * CGFloat(i + 1) * 0.25 + 5))
                                    }
                                    .stroke(RenaissanceColors.errorRed.opacity(1.0 - dissolvePhase), lineWidth: 1)
                                    .frame(width: blockW, height: blockH)
                                }
                            }
                        }

                        if waterPoured {
                            Text("Dissolves")
                                .font(RenaissanceFont.ivFormula)
                                .foregroundStyle(RenaissanceColors.errorRed)
                                .transition(.opacity)
                        }
                    }
                    .position(x: w * 0.28, y: baseY)

                    // Right block: Pozzolanic concrete
                    VStack(spacing: 4) {
                        Text("Pozzolanic")
                            .font(RenaissanceFont.visualTitle)
                            .tracking(0.5)
                            .foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.5))

                        ZStack {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(pozzolanaRed)
                                .frame(width: blockW, height: blockH)

                            if waterPoured {
                                // Strengthening glow
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(RenaissanceColors.sageGreen.opacity(0.15 * (1.0 - dissolvePhase)))
                                    .frame(width: blockW + 4, height: blockH + 4)
                            }
                        }

                        if waterPoured {
                            Text("HARDENS")
                                .font(RenaissanceFont.ivFormula)
                                .foregroundStyle(RenaissanceColors.sageGreen)
                                .transition(.opacity)
                        }
                    }
                    .position(x: w * 0.72, y: baseY)

                    // Water fill
                    if waterPoured {
                        Rectangle()
                            .fill(IVMaterialColors.waterBlue.opacity(0.25))
                            .frame(width: w, height: h * waterLevel)
                            .position(x: w * 0.5, y: h - h * waterLevel * 0.5)

                        // Water surface line
                        Path { p in
                            let surfaceY = h * (1.0 - waterLevel)
                            p.move(to: CGPoint(x: 0, y: surfaceY))
                            p.addLine(to: CGPoint(x: w, y: surfaceY))
                        }
                        .stroke(IVMaterialColors.waterBlue.opacity(0.5), lineWidth: 1)
                    }

                    // Pour button (step 2, before pouring)
                    if step >= 2 && !waterPoured {
                        Button {
                            waterPoured = true
                            SoundManager.shared.play(.tapSoft)
                            withAnimation(.easeInOut(duration: 1.5)) { waterLevel = 0.55 }
                            withAnimation(.easeInOut(duration: 2.0).delay(0.8)) { dissolvePhase = 0.3 }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                withAnimation { step = 3 }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "drop.fill").font(.system(size: 13))
                                Text("Pour Water")
                                    .font(RenaissanceFont.ivLabel)
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, 16).padding(.vertical, 8)
                            .background(IVMaterialColors.waterBlue)
                            .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                        .position(x: w * 0.5, y: h * 0.22)
                    }

                    // Final formula (step 3)
                    if step >= 3 {
                        FormulaText(text: "Silica + Lime = sets underwater", highlighted: true)
                            .position(x: w * 0.5, y: h * 0.12)
                            .transition(.opacity)
                    }
                }
            }
        }
    }
}

// MARK: - 8. Opus Signinum — 3 Burnished Coats

private struct OpusSigninumCoatsVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    @State private var coatsApplied: Int = 0
    @State private var burnishProgress: CGFloat = 0

    private var label: String {
        switch step {
        case 1: return "Three coats of crushed terracotta + lime waterproof the channel."
        case 2:
            switch coatsApplied {
            case 0: return "Tap to apply the first coat — coarse."
            case 1: return "Tap for the second coat — medium grain."
            case 2: return "Tap for the finest coat — almost smooth."
            default: return "Three coats applied. Watch the burnish."
            }
        default: return "Smoother than modern plumbing — 2,000 years and counting."
        }
    }

    private let coatColors: [Color] = [
        Color(red: 0.75, green: 0.45, blue: 0.30).opacity(0.4),  // coarse
        Color(red: 0.75, green: 0.45, blue: 0.30).opacity(0.6),  // medium
        Color(red: 0.75, green: 0.45, blue: 0.30).opacity(0.8),  // fine
    ]

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3,
                         step: $step, stepLabel: label, height: height) {
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let wallW = w * 0.55
                let wallH = h * 0.6
                let cx = w * 0.5
                let cy = h * 0.4

                ZStack {
                    // Base stone wall
                    RoundedRectangle(cornerRadius: 4)
                        .fill(IVMaterialColors.stoneGray.opacity(0.3))
                        .frame(width: wallW, height: wallH)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .strokeBorder(IVMaterialColors.stoneGray, lineWidth: 1.5)
                        )
                        .position(x: cx, y: cy)

                    // Applied coats
                    ForEach(0..<coatsApplied, id: \.self) { i in
                        let inset = CGFloat(i) * 6
                        RoundedRectangle(cornerRadius: 3)
                            .fill(coatColors[i])
                            .frame(width: wallW - 8 - inset * 2, height: wallH - 8 - inset * 2)
                            .position(x: cx, y: cy)
                            .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    }

                    // Burnish shine sweep (after 3 coats)
                    if coatsApplied >= 3 {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(
                                LinearGradient(
                                    colors: [.clear, .white.opacity(0.3), .clear],
                                    startPoint: UnitPoint(x: burnishProgress - 0.3, y: 0),
                                    endPoint: UnitPoint(x: burnishProgress + 0.1, y: 1)
                                )
                            )
                            .frame(width: wallW - 24, height: wallH - 24)
                            .position(x: cx, y: cy)
                            .clipShape(RoundedRectangle(cornerRadius: 3))
                    }

                    // Coat labels on right side
                    if step >= 2 {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 4) {
                                Circle().fill(coatsApplied >= 1 ? coatColors[0] : IVMaterialColors.stoneGray.opacity(0.2)).frame(width: 8, height: 8)
                                Text("Coarse").font(RenaissanceFont.ivBody)
                                    .foregroundStyle(coatsApplied >= 1 ? IVMaterialColors.sepiaInk : IVMaterialColors.sepiaInk.opacity(0.3))
                            }
                            HStack(spacing: 4) {
                                Circle().fill(coatsApplied >= 2 ? coatColors[1] : IVMaterialColors.stoneGray.opacity(0.2)).frame(width: 8, height: 8)
                                Text("Medium").font(RenaissanceFont.ivBody)
                                    .foregroundStyle(coatsApplied >= 2 ? IVMaterialColors.sepiaInk : IVMaterialColors.sepiaInk.opacity(0.3))
                            }
                            HStack(spacing: 4) {
                                Circle().fill(coatsApplied >= 3 ? coatColors[2] : IVMaterialColors.stoneGray.opacity(0.2)).frame(width: 8, height: 8)
                                Text("Finest").font(RenaissanceFont.ivBody)
                                    .foregroundStyle(coatsApplied >= 3 ? IVMaterialColors.sepiaInk : IVMaterialColors.sepiaInk.opacity(0.3))
                            }
                        }
                        .position(x: cx + wallW * 0.5 + 36, y: cy)
                    }

                    // Tap to apply button
                    if step >= 2 && coatsApplied < 3 {
                        Button {
                            withAnimation(.spring(response: 0.4)) { coatsApplied += 1 }
                            SoundManager.shared.play(.tapSoft)
                            if coatsApplied >= 3 {
                                // Start burnish animation
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    withAnimation(.easeInOut(duration: 1.5)) { burnishProgress = 1.3 }
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                    withAnimation { step = 3 }
                                }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "paintbrush.fill").font(.system(size: 13))
                                Text("Apply Coat \(coatsApplied + 1)")
                                    .font(RenaissanceFont.ivLabel)
                            }
                            .foregroundStyle(color)
                            .padding(.horizontal, 12).padding(.vertical, 6)
                            .background(color.opacity(0.1))
                            .cornerRadius(6)
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(color.opacity(0.3), lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                        .position(x: cx, y: h * 0.82)
                    }

                    // Final formula
                    if step >= 3 {
                        FormulaText(text: "Smoother than modern plumbing", highlighted: true)
                            .position(x: cx, y: h * 0.82)
                            .transition(.opacity)
                    }
                }
            }
        }
    }
}

// MARK: - 9. Lead Fistula Pipe — Step-by-Step Fabrication

private struct FistulaPipeFabVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1

    private var label: String {
        switch step {
        case 1: return "Start with a flat sheet of cast lead."
        case 2: return "Bend the sheet around a wooden core."
        case 3: return "Solder the seam shut — watertight."
        default: return "10 standard sizes — stamped with the emperor's name."
        }
    }

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 4,
                         step: $step, stepLabel: label, height: height) {
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let cx = w * 0.5
                let cy = h * 0.42
                let pipeSize = min(w * 0.3, h * 0.35)

                ZStack {
                    // Step 1: Flat sheet (end-on view = horizontal line)
                    if step == 1 {
                        // Side view of flat sheet
                        RoundedRectangle(cornerRadius: 2)
                            .fill(IVMaterialColors.leadGray)
                            .frame(width: w * 0.6, height: 8)
                            .position(x: cx, y: cy)

                        DimLine(from: CGPoint(x: cx - w * 0.3, y: cy + 20),
                                to: CGPoint(x: cx + w * 0.3, y: cy + 20))
                            .stroke(IVMaterialColors.dimColor, lineWidth: 0.8)
                        DimLabel(text: "Lead sheet")
                            .position(x: cx, y: cy + 32)
                    }

                    // Step 2: Bending into U/C shape
                    if step == 2 {
                        Path { p in
                            p.move(to: CGPoint(x: cx - pipeSize * 0.45, y: cy - pipeSize * 0.4))
                            p.addQuadCurve(
                                to: CGPoint(x: cx + pipeSize * 0.45, y: cy - pipeSize * 0.4),
                                control: CGPoint(x: cx, y: cy + pipeSize * 0.5)
                            )
                        }
                        .stroke(IVMaterialColors.leadGray, lineWidth: 6)

                        // Wood core (dashed circle inside)
                        Circle()
                            .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [3, 3]))
                            .foregroundStyle(RenaissanceColors.warmBrown.opacity(0.3))
                            .frame(width: pipeSize * 0.5, height: pipeSize * 0.5)
                            .position(x: cx, y: cy + 2)

                        DimLabel(text: "Wood core")
                            .position(x: cx, y: cy + pipeSize * 0.35)
                    }

                    // Step 3: Complete circle (soldered)
                    if step == 3 {
                        Circle()
                            .stroke(IVMaterialColors.leadGray, lineWidth: 6)
                            .frame(width: pipeSize * 0.7, height: pipeSize * 0.7)
                            .position(x: cx, y: cy)

                        // Solder line at top
                        Path { p in
                            p.move(to: CGPoint(x: cx - 3, y: cy - pipeSize * 0.35))
                            p.addLine(to: CGPoint(x: cx + 3, y: cy - pipeSize * 0.35))
                        }
                        .stroke(RenaissanceColors.furnaceOrange.opacity(0.6), lineWidth: 3)

                        // Flame icon
                        Image(systemName: "flame.fill")
                            .font(.system(size: 13))
                            .foregroundStyle(.orange.opacity(0.6))
                            .position(x: cx, y: cy - pipeSize * 0.35 - 14)

                        DimLabel(text: "Soldered seam")
                            .position(x: cx, y: cy - pipeSize * 0.35 - 26)
                    }

                    // Step 4: Side view with stamp
                    if step == 4 {
                        // Side view of pipe
                        RoundedRectangle(cornerRadius: pipeSize * 0.15)
                            .fill(IVMaterialColors.leadGray.opacity(0.4))
                            .frame(width: w * 0.55, height: pipeSize * 0.35)
                            .overlay(
                                RoundedRectangle(cornerRadius: pipeSize * 0.15)
                                    .strokeBorder(IVMaterialColors.leadGray, lineWidth: 1.5)
                            )
                            .position(x: cx, y: cy)

                        // Emperor stamp text
                        Text("IMP · CLAVDIVS")
                            .font(RenaissanceFont.visualTitle)
                            .tracking(2)
                            .foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.5))
                            .position(x: cx, y: cy)

                        FormulaText(text: "10 standard sizes", highlighted: true)
                            .position(x: cx, y: cy + pipeSize * 0.35)
                    }
                }
            }
        }
    }
}

// MARK: - 10. Aqueduct Mortar Recipe — Tap Ingredients

private struct AqueductMortarRecipeVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var ingredientsAdded: Int = 0 // 0=none, 1=lime, 2=+sand, 3=+sand2, 4=+pozzolana
    @State private var trowelFlipped = false

    private var statusText: String {
        switch ingredientsAdded {
        case 0: return "Tap lime to start the mix"
        case 1: return "1 lime added — now add sand (tap twice)"
        case 2: return "1 sand — tap sand again"
        case 3: return "2 sand — now add pozzolana"
        case 4: return trowelFlipped ? "It clings! Good mortar." : "Tap trowel to test"
        default: return ""
        }
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10).fill(RenaissanceColors.parchment)
            RoundedRectangle(cornerRadius: 10).strokeBorder(color.opacity(0.2), lineWidth: 1)
            AqueductBlueprintGrid()

            VStack(spacing: 10) {
                // Formula at top
                FormulaText(
                    text: "1 Lime : 2 Sand : ½ Pozzolana",
                    highlighted: ingredientsAdded >= 4,
                )
                .padding(.top, 8)

                // Ratio bar
                GeometryReader { geo in
                    let barW = geo.size.width - 20
                    let totalParts: CGFloat = 3.5 // 1 + 2 + 0.5
                    HStack(spacing: 2) {
                        // Lime portion
                        RoundedRectangle(cornerRadius: 3)
                            .fill(ingredientsAdded >= 1 ? Color.white.opacity(0.8) : IVMaterialColors.stoneGray.opacity(0.15))
                            .frame(width: barW * (1.0 / totalParts))
                            .overlay {
                                if ingredientsAdded >= 1 {
                                    Text("1").font(RenaissanceFont.ivFormula).foregroundStyle(IVMaterialColors.sepiaInk)
                                }
                            }

                        // Sand portion
                        RoundedRectangle(cornerRadius: 3)
                            .fill(ingredientsAdded >= 3 ? RenaissanceColors.candleGlow.opacity(0.3) :
                                    ingredientsAdded >= 2 ? RenaissanceColors.candleGlow.opacity(0.15) : IVMaterialColors.stoneGray.opacity(0.15))
                            .frame(width: barW * (2.0 / totalParts))
                            .overlay {
                                if ingredientsAdded >= 2 {
                                    Text(ingredientsAdded >= 3 ? "2" : "1")
                                        .font(RenaissanceFont.ivFormula).foregroundStyle(IVMaterialColors.sepiaInk)
                                }
                            }

                        // Pozzolana portion
                        RoundedRectangle(cornerRadius: 3)
                            .fill(ingredientsAdded >= 4 ? pozzolanaRed.opacity(0.4) : IVMaterialColors.stoneGray.opacity(0.15))
                            .frame(width: barW * (0.5 / totalParts))
                            .overlay {
                                if ingredientsAdded >= 4 {
                                    Text("½").font(RenaissanceFont.ivFormula).foregroundStyle(IVMaterialColors.sepiaInk)
                                }
                            }
                    }
                    .frame(height: 28)
                    .padding(.horizontal, 10)
                }
                .frame(height: 28)

                // Ingredient buttons
                HStack(spacing: 12) {
                    // Lime button
                    Button {
                        guard ingredientsAdded == 0 else { return }
                        withAnimation(.spring(response: 0.3)) { ingredientsAdded = 1 }
                        SoundManager.shared.play(.tapSoft)
                    } label: {
                        VStack(spacing: 2) {
                            Text("CaO").font(RenaissanceFont.ivFormula)
                            Text("Lime").font(RenaissanceFont.ivBody)
                        }
                        .frame(width: 60, height: 50)
                        .background(ingredientsAdded >= 1 ? IVMaterialColors.stoneGray.opacity(0.1) : Color.white.opacity(0.5))
                        .cornerRadius(6)
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(
                            ingredientsAdded == 0 ? color : IVMaterialColors.stoneGray.opacity(0.3), lineWidth: ingredientsAdded == 0 ? 2 : 1))
                    }
                    .buttonStyle(.plain)
                    .opacity(ingredientsAdded >= 1 ? 0.4 : 1)

                    // Sand button
                    Button {
                        guard ingredientsAdded >= 1 && ingredientsAdded <= 2 else { return }
                        withAnimation(.spring(response: 0.3)) { ingredientsAdded += 1 }
                        SoundManager.shared.play(.tapSoft)
                    } label: {
                        VStack(spacing: 2) {
                            Text("SiO₂").font(RenaissanceFont.ivFormula)
                            Text("Sand").font(RenaissanceFont.ivBody)
                        }
                        .frame(width: 60, height: 50)
                        .background(ingredientsAdded >= 3 ? IVMaterialColors.stoneGray.opacity(0.1) : RenaissanceColors.candleGlow.opacity(0.15))
                        .cornerRadius(6)
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(
                            (ingredientsAdded >= 1 && ingredientsAdded <= 2) ? color : IVMaterialColors.stoneGray.opacity(0.3),
                            lineWidth: (ingredientsAdded >= 1 && ingredientsAdded <= 2) ? 2 : 1))
                    }
                    .buttonStyle(.plain)
                    .opacity(ingredientsAdded >= 3 ? 0.4 : 1)

                    // Pozzolana button
                    Button {
                        guard ingredientsAdded == 3 else { return }
                        withAnimation(.spring(response: 0.3)) { ingredientsAdded = 4 }
                        SoundManager.shared.play(.tapSoft)
                    } label: {
                        VStack(spacing: 2) {
                            Text("ite").font(RenaissanceFont.ivFormula)
                            Text("Pozzolana").font(RenaissanceFont.ivBody)
                        }
                        .frame(width: 70, height: 50)
                        .background(ingredientsAdded >= 4 ? IVMaterialColors.stoneGray.opacity(0.1) : pozzolanaRed.opacity(0.15))
                        .cornerRadius(6)
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(
                            ingredientsAdded == 3 ? color : IVMaterialColors.stoneGray.opacity(0.3),
                            lineWidth: ingredientsAdded == 3 ? 2 : 1))
                    }
                    .buttonStyle(.plain)
                    .opacity(ingredientsAdded >= 4 ? 0.4 : 1)
                }

                // Trowel test (after all ingredients)
                if ingredientsAdded >= 4 {
                    Button {
                        withAnimation(.spring(response: 0.4)) { trowelFlipped = true }
                        SoundManager.shared.play(.tapSoft)
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "wrench.and.screwdriver.fill")
                                .font(.system(size: 13))
                                .rotationEffect(.degrees(trowelFlipped ? 180 : 0))
                            Text(trowelFlipped ? "It clings!" : "Trowel Test")
                                .font(RenaissanceFont.ivLabel)
                        }
                        .foregroundStyle(trowelFlipped ? RenaissanceColors.sageGreen : color)
                        .padding(.horizontal, 14).padding(.vertical, 6)
                        .background(trowelFlipped ? RenaissanceColors.sageGreen.opacity(0.1) : color.opacity(0.1))
                        .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                    .transition(.opacity)
                }

                // Status text
                Text(statusText)
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

// MARK: - 11. Firing Terracotta — Temperature Slider

private struct TerracottaFiringVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var temperature: CGFloat = 0 // 0 to 1 (maps to 0-1100°C)
    @State private var ringTestDone = false

    private var tempC: Int { Int(temperature * 1100) }

    private var clayColor: Color {
        if tempC < 400 { return Color(red: 0.55, green: 0.40, blue: 0.30) } // raw clay
        if tempC < 600 { return Color(red: 0.65, green: 0.42, blue: 0.28) } // warming
        if tempC <= 900 { return RenaissanceColors.terracotta } // fired terracotta
        return Color(red: 0.40, green: 0.30, blue: 0.28) // over-fired
    }

    private var statusText: String {
        if tempC < 400 { return "Raw clay — not yet fired" }
        if tempC < 600 { return "Warming... water evaporating" }
        if tempC <= 900 {
            if ringTestDone { return "Clear ring! Properly fired terracotta." }
            return "Tap the block to test — does it ring?"
        }
        return "Over-fired — brittle and useless"
    }

    private var inFiringRange: Bool { tempC >= 600 && tempC <= 900 }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10).fill(RenaissanceColors.parchment)
            RoundedRectangle(cornerRadius: 10).strokeBorder(color.opacity(0.2), lineWidth: 1)
            AqueductBlueprintGrid()

            VStack(spacing: 10) {
                // Temperature display
                HStack(spacing: 4) {
                    Image(systemName: "thermometer.medium")
                        .font(.system(size: 14))
                        .foregroundStyle(tempC > 600 ? .orange : IVMaterialColors.sepiaInk.opacity(0.4))
                    Text("\(tempC)°C")
                        .font(.custom("EBGaramond-Bold", size: 18))
                        .foregroundStyle(tempC > 900 ? RenaissanceColors.errorRed :
                                            inFiringRange ? RenaissanceColors.sageGreen : IVMaterialColors.sepiaInk)
                        .monospacedDigit()
                }
                .padding(.top, 8)

                // Clay block
                RoundedRectangle(cornerRadius: 6)
                    .fill(clayColor)
                    .frame(width: 80, height: 60)
                    .overlay {
                        if inFiringRange && !ringTestDone {
                            Image(systemName: "hand.tap.fill")
                                .font(.system(size: 16))
                                .foregroundStyle(.white.opacity(0.5))
                        }
                        if ringTestDone {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(RenaissanceColors.sageGreen)
                        }
                        // Over-fired cracks
                        if tempC > 900 {
                            Path { p in
                                p.move(to: CGPoint(x: 20, y: 10))
                                p.addLine(to: CGPoint(x: 50, y: 35))
                                p.addLine(to: CGPoint(x: 30, y: 55))
                            }
                            .stroke(RenaissanceColors.errorRed.opacity(0.5), lineWidth: 1.5)
                        }
                    }
                    .shadow(color: tempC > 600 ? .orange.opacity(0.3) : .clear, radius: 8)
                    .onTapGesture {
                        guard inFiringRange, !ringTestDone else { return }
                        ringTestDone = true
                        SoundManager.shared.play(.correctChime)
                        HapticsManager.shared.play(.correctAnswer)
                    }

                // Temperature slider
                VStack(spacing: 4) {
                    Slider(value: $temperature, in: 0...1)
                        .tint(tempC > 900 ? RenaissanceColors.errorRed :
                                inFiringRange ? RenaissanceColors.sageGreen : .orange)
                        .frame(width: 200)

                    // Range markers
                    HStack {
                        Text("0°C").font(RenaissanceFont.ivBody)
                        Spacer()
                        Text("600°C").font(RenaissanceFont.ivBody).foregroundStyle(RenaissanceColors.sageGreen)
                        Spacer()
                        Text("900°C").font(RenaissanceFont.ivBody).foregroundStyle(RenaissanceColors.sageGreen)
                        Spacer()
                        Text("1100°C").font(RenaissanceFont.ivBody).foregroundStyle(RenaissanceColors.errorRed)
                    }
                    .foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.4))
                    .frame(width: 200)
                }

                // Status text
                Text(statusText)
                    .font(RenaissanceFont.ivBody)
                    .foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)

                Spacer()
            }
            .padding(.horizontal, 12)
        }
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .onChange(of: temperature) { _, _ in
            ringTestDone = false // Reset when slider moves
        }
    }
}

// MARK: - 12. Daily Flow — Basin Fill + Counter

private struct DailyFlowVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    @State private var fillLevel: CGFloat = 0
    @State private var counterValue: Int = 0
    @State private var isFilling = false

    private var label: String {
        switch step {
        case 1: return "184,000 cubic meters of water flowed through Rome daily."
        case 2:
            if !isFilling && fillLevel == 0 { return "Tap Fill to see the scale of Roman water supply." }
            if isFilling { return "Filling..." }
            return "That's 190 liters per person — more than many modern cities."
        default: return "More water per person than modern London or New York."
        }
    }

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3,
                         step: $step, stepLabel: label, height: height) {
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let cx = w * 0.5
                let basinW = w * 0.45
                let basinH = h * 0.5
                let basinY = h * 0.4

                ZStack {
                    // Pipe on left
                    Path { p in
                        p.move(to: CGPoint(x: cx - basinW * 0.7, y: basinY - basinH * 0.2))
                        p.addLine(to: CGPoint(x: cx - basinW * 0.5, y: basinY - basinH * 0.2))
                    }
                    .stroke(IVMaterialColors.leadGray, lineWidth: 4)

                    // Basin outline
                    RoundedRectangle(cornerRadius: 4)
                        .strokeBorder(IVMaterialColors.stoneGray, lineWidth: 2)
                        .frame(width: basinW, height: basinH)
                        .position(x: cx, y: basinY)

                    // Water fill
                    RoundedRectangle(cornerRadius: 3)
                        .fill(IVMaterialColors.waterBlue.opacity(0.4))
                        .frame(width: basinW - 4, height: (basinH - 4) * fillLevel)
                        .position(x: cx, y: basinY + (basinH - (basinH - 4) * fillLevel) / 2 - 2)

                    // Counter inside basin
                    VStack(spacing: 2) {
                        Text("\(counterValue)")
                            .font(.custom("EBGaramond-Bold", size: counterValue > 0 ? 18 : 14))
                            .monospacedDigit()
                            .foregroundStyle(fillLevel > 0.5 ? .white : IVMaterialColors.sepiaInk)
                        if counterValue > 0 {
                            Text("m³ / day")
                                .font(RenaissanceFont.ivBody)
                                .foregroundStyle(fillLevel > 0.5 ? .white.opacity(0.8) : IVMaterialColors.sepiaInk.opacity(0.5))
                        }
                    }
                    .position(x: cx, y: basinY)

                    // Fill button (step 2, before fill)
                    if step >= 2 && !isFilling && fillLevel == 0 {
                        Button {
                            startFill()
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "drop.fill").font(.system(size: 13))
                                Text("Fill")
                                    .font(RenaissanceFont.ivLabel)
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, 16).padding(.vertical, 8)
                            .background(IVMaterialColors.waterBlue)
                            .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                        .position(x: cx, y: h * 0.82)
                    }

                    // Per person stat (step 3)
                    if step >= 3 {
                        HStack(spacing: 8) {
                            Image(systemName: "person.fill")
                                .font(.system(size: 13))
                                .foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.4))
                            FormulaText(text: "190 liters / person / day", highlighted: true)
                        }
                        .position(x: cx, y: h * 0.82)
                        .transition(.opacity)
                    }
                }
            }
        }
    }

    private func startFill() {
        isFilling = true
        SoundManager.shared.play(.tapSoft)

        // Animate fill over 2 seconds
        withAnimation(.easeInOut(duration: 2.0)) { fillLevel = 0.9 }

        // Counter ticks
        let target = 184000
        let steps = 30
        let interval = 2.0 / Double(steps)
        for i in 1...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + interval * Double(i)) {
                counterValue = Int(Double(target) * Double(i) / Double(steps))
                if i == steps {
                    isFilling = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation { step = 3 }
                    }
                }
            }
        }
    }
}
