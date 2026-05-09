import SwiftUI

/// Interactive science visuals for Harbor knowledge cards
struct HarborInteractiveVisuals {

    @ViewBuilder
    static func view(for visual: CardVisual, color: Color, height: CGFloat = 275) -> some View {
        let h = height
        Group {
            switch visual.title {
            case let t where t.contains("200-Acre") || t.contains("Portus"):
                HarborPlanVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Wave Impact"):
                WaveForceVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Cofferdam") || t.contains("Build Dry"):
                CofferdamVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Breakwater Block"):
                BreakwaterVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Lighthouse"):
                LighthouseVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Harbor Stone"):
                HarborStoneVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Marine Concrete") || t.contains("vs Modern Marine"):
                MarineConcreteVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Lead Hull") || t.contains("Hull Protection"):
                HullProtectionVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Warehouse Truss"):
                WarehouseTrussVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Poplar Piles") || t.contains("Swell Tight"):
                PoplarPilesVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Marine Mortar") || t.contains("Seawater"):
                MarineMortarVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Lead Casting") || t.contains("327"):
                LeadCastingVisual(visual: visual, color: color, height: h)
            default:
                EmptyView()
            }
        }
    }

    static func hasInteractiveVisual(for visual: CardVisual) -> Bool {
        let t = visual.title
        return t.contains("200-Acre") || t.contains("Portus") ||
               t.contains("Wave Impact") || t.contains("Cofferdam") ||
               t.contains("Build Dry") || t.contains("Breakwater Block") ||
               t.contains("Lighthouse") || t.contains("Harbor Stone") ||
               t.contains("Marine Concrete") || t.contains("vs Modern Marine") ||
               t.contains("Lead Hull") || t.contains("Hull Protection") ||
               t.contains("Warehouse Truss") || t.contains("Poplar Piles") ||
               t.contains("Swell Tight") || t.contains("Marine Mortar") ||
               t.contains("Seawater") || t.contains("Lead Casting") || t.contains("327")
    }
}

// MARK: - Local Colors (unique to Harbor)

private let seaBlue = Color(red: 0.30, green: 0.50, blue: 0.65)
private let tufaBrown = Color(red: 0.72, green: 0.62, blue: 0.48)

private typealias TeachingContainer = IVTeachingContainer
private typealias DimLabel = IVDimLabel
private typealias FormulaText = IVFormulaText
private typealias DimLine = IVDimLine

// MARK: - 1. Harbor Plan — Tap to Place Ships

private struct HarborPlanVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    @State private var placedItems: Set<Int> = []

    private let items = ["Ship 1", "Ship 2", "Ship 3", "Lighthouse"]

    private var label: String {
        switch step {
        case 1: return "Portus — 200 acres, 350 ships simultaneously."
        case 2:
            if placedItems.count < 4 { return "Tap to place ships and the lighthouse." }
            return "Hexagonal inner harbor — calm water even in storms."
        default: return "The harbor that fed a million people."
        }
    }

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3,
                         step: $step, stepLabel: label, height: height) {
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let cx = w * 0.5
                let cy = h * 0.42

                ZStack {
                    // Outer harbor (ellipse)
                    Ellipse()
                        .fill(seaBlue.opacity(0.1))
                        .frame(width: w * 0.7, height: h * 0.55)
                        .position(x: cx, y: cy)
                    Ellipse()
                        .strokeBorder(seaBlue.opacity(0.4), lineWidth: 1.5)
                        .frame(width: w * 0.7, height: h * 0.55)
                        .position(x: cx, y: cy)

                    // Inner hexagonal harbor
                    Path { p in
                        let r: CGFloat = min(w, h) * 0.15
                        for i in 0..<6 {
                            let angle = CGFloat(i) / 6.0 * .pi * 2 - .pi / 2
                            let pt = CGPoint(x: cx + r * cos(angle), y: cy + r * sin(angle))
                            if i == 0 { p.move(to: pt) } else { p.addLine(to: pt) }
                        }
                        p.closeSubpath()
                    }
                    .fill(seaBlue.opacity(0.15))
                    .overlay(
                        Path { p in
                            let r: CGFloat = min(w, h) * 0.15
                            for i in 0..<6 {
                                let angle = CGFloat(i) / 6.0 * .pi * 2 - .pi / 2
                                let pt = CGPoint(x: cx + r * cos(angle), y: cy + r * sin(angle))
                                if i == 0 { p.move(to: pt) } else { p.addLine(to: pt) }
                            }
                            p.closeSubpath()
                        }
                        .stroke(seaBlue, lineWidth: 1)
                    )

                    // Breakwater (curved wall)
                    Path { p in
                        p.addArc(center: CGPoint(x: cx, y: cy),
                                radius: w * 0.35,
                                startAngle: .degrees(160), endAngle: .degrees(20), clockwise: true)
                    }
                    .stroke(RenaissanceColors.stoneGray, lineWidth: 3)

                    // Placeable items
                    if step >= 2 {
                        let positions: [CGPoint] = [
                            CGPoint(x: cx - w * 0.12, y: cy - h * 0.08),
                            CGPoint(x: cx + w * 0.08, y: cy + h * 0.05),
                            CGPoint(x: cx - w * 0.05, y: cy + h * 0.12),
                            CGPoint(x: cx + w * 0.28, y: cy - h * 0.22), // lighthouse
                        ]

                        ForEach(0..<4, id: \.self) { i in
                            let placed = placedItems.contains(i)
                            let isLighthouse = i == 3

                            if placed {
                                if isLighthouse {
                                    Image(systemName: "light.beacon.max.fill")
                                        .font(.system(size: 14))
                                        .foregroundStyle(RenaissanceColors.ochre)
                                        .position(positions[i])
                                        .transition(.scale)
                                } else {
                                    Image(systemName: "ferry.fill")
                                        .font(.system(size: 13))
                                        .foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.5))
                                        .position(positions[i])
                                        .transition(.scale)
                                }
                            } else {
                                Circle()
                                    .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [3, 3]))
                                    .foregroundStyle(color.opacity(0.4))
                                    .frame(width: 22, height: 22)
                                    .overlay { Text("+").font(.system(size: 13)).foregroundStyle(color.opacity(0.4)) }
                                    .position(positions[i])
                                    .onTapGesture {
                                        withAnimation(.spring(response: 0.3)) { placedItems.insert(i) }
                                        SoundManager.shared.play(.tapSoft)
                                        if placedItems.count == 4 {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                withAnimation { step = 3 }
                                            }
                                        }
                                    }
                            }
                        }
                    }

                    if step >= 3 {
                        FormulaText(text: "350 ships — Rome's lifeline", highlighted: true)
                            .position(x: cx, y: h * 0.88)
                            .transition(.opacity)
                    }
                }
            }
        }
    }
}

// MARK: - 2. Wave Force — Drag Height Slider

private struct WaveForceVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    @State private var waveHeight: CGFloat = 0.3

    private var meters: String { String(format: "%.1f", waveHeight * 5) }
    private var tons: Int { Int(waveHeight * 5 * 10) }

    private var label: String {
        switch step {
        case 1: return "Waves hit walls with tons of force per meter."
        case 2: return "Drag wave height — force counter updates."
        default: return "The strongest wall doesn't fight the wave — it absorbs it."
        }
    }

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3,
                         step: $step, stepLabel: label, height: height) {
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let cx = w * 0.5
                let wallX = w * 0.65
                let seaLevel = h * 0.5
                let waveAmp = h * 0.15 * waveHeight

                ZStack {
                    // Sea surface with wave
                    Path { p in
                        p.move(to: CGPoint(x: w * 0.05, y: seaLevel))
                        for x in stride(from: w * 0.05, through: wallX, by: 2) {
                            let phase = (x / w) * .pi * 4
                            let y = seaLevel - sin(phase) * waveAmp
                            p.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                    .stroke(seaBlue, lineWidth: 1.5)

                    // Sea fill
                    Path { p in
                        p.move(to: CGPoint(x: w * 0.05, y: seaLevel))
                        for x in stride(from: w * 0.05, through: wallX, by: 2) {
                            let phase = (x / w) * .pi * 4
                            let y = seaLevel - sin(phase) * waveAmp
                            p.addLine(to: CGPoint(x: x, y: y))
                        }
                        p.addLine(to: CGPoint(x: wallX, y: h))
                        p.addLine(to: CGPoint(x: w * 0.05, y: h))
                        p.closeSubpath()
                    }
                    .fill(seaBlue.opacity(0.15))

                    // Breakwater wall
                    RoundedRectangle(cornerRadius: 2)
                        .fill(RenaissanceColors.stoneGray)
                        .frame(width: 12, height: h * 0.5)
                        .position(x: wallX, y: seaLevel)

                    // Force arrow
                    if waveHeight > 0.2 {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 13 + waveHeight * 12))
                            .foregroundStyle(RenaissanceColors.errorRed.opacity(0.3 + waveHeight * 0.4))
                            .position(x: wallX - 25, y: seaLevel - waveAmp * 0.5)
                    }

                    // Force readout
                    VStack(spacing: 2) {
                        Text("\(meters)m wave")
                            .font(RenaissanceFont.ivFormula)
                            .foregroundStyle(IVMaterialColors.sepiaInk)
                        Text("\(tons) tons/m")
                            .font(.custom("EBGaramond-Bold", size: 16))
                            .foregroundStyle(waveHeight > 0.6 ? RenaissanceColors.errorRed : color)
                    }
                    .position(x: w * 0.25, y: h * 0.15)

                    // Slider
                    if step >= 2 {
                        Slider(value: $waveHeight, in: 0.1...1.0)
                            .tint(waveHeight > 0.6 ? RenaissanceColors.errorRed : seaBlue)
                            .frame(width: w * 0.5)
                            .position(x: cx, y: h * 0.85)
                            .onChange(of: waveHeight) { _, val in
                                if val > 0.7 { withAnimation { step = 3 } }
                            }
                    }

                    if step >= 3 {
                        FormulaText(text: "3m wave = 30 tons/meter", highlighted: true)
                            .position(x: cx, y: h * 0.15)
                            .transition(.opacity)
                    }
                }
            }
        }
    }
}

// MARK: - 3. Cofferdam — Drain + Build

private struct CofferdamVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    @State private var waterDrained: CGFloat = 1.0
    @State private var pilesVisible = false

    private var label: String {
        switch step {
        case 1: return "How do you build underwater? Make the water leave."
        case 2:
            if waterDrained > 0.3 { return "Tap to pump — Archimedean screw drains the water." }
            return "Dry area inside double pile walls."
        case 3: return "Now build on dry ground — surrounded by sea."
        default: return "Building underwater is just building on land — minus the water."
        }
    }

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 4,
                         step: $step, stepLabel: label, height: height) {
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let cx = w * 0.5
                let cofferW = w * 0.4
                let cofferH = h * 0.5
                let baseY = h * 0.45

                ZStack {
                    // Sea on both sides
                    Rectangle()
                        .fill(seaBlue.opacity(0.12))
                        .frame(width: w, height: h * 0.4)
                        .position(x: cx, y: h * 0.55)

                    // Double pile walls
                    ForEach([-1.0, 1.0], id: \.self) { side in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(RenaissanceColors.warmBrown.opacity(0.5))
                            .frame(width: 6, height: cofferH)
                            .position(x: cx + side * cofferW * 0.5, y: baseY)

                        RoundedRectangle(cornerRadius: 2)
                            .fill(RenaissanceColors.warmBrown.opacity(0.4))
                            .frame(width: 4, height: cofferH)
                            .position(x: cx + side * (cofferW * 0.5 + 8), y: baseY)
                    }

                    // Water inside cofferdam (drains)
                    Rectangle()
                        .fill(seaBlue.opacity(0.25 * waterDrained))
                        .frame(width: cofferW - 12, height: cofferH * waterDrained)
                        .position(x: cx, y: baseY + (cofferH - cofferH * waterDrained) * 0.5)

                    // Dry building area
                    if waterDrained < 0.2 {
                        Rectangle()
                            .fill(RenaissanceColors.warmBrown.opacity(0.15))
                            .frame(width: cofferW - 12, height: cofferH * 0.3)
                            .position(x: cx, y: baseY + cofferH * 0.25)

                        Text("DRY")
                            .font(RenaissanceFont.visualTitle)
                            .foregroundStyle(RenaissanceColors.sageGreen)
                            .position(x: cx, y: baseY)
                    }

                    // Pump button
                    if step >= 2 && waterDrained > 0.2 {
                        Button {
                            withAnimation(.easeInOut(duration: 1.5)) { waterDrained = 0.05 }
                            SoundManager.shared.play(.tapSoft)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                                withAnimation { step = 3 }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.up.circle").font(.system(size: 13))
                                Text("Pump Water").font(RenaissanceFont.ivLabel)
                            }
                            .foregroundStyle(seaBlue)
                            .padding(.horizontal, 12).padding(.vertical, 6)
                            .background(seaBlue.opacity(0.1)).cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                        .position(x: cx, y: h * 0.1)
                    }

                    if step >= 4 {
                        FormulaText(text: "Build on land — inside the sea", highlighted: true)
                            .position(x: cx, y: h * 0.88)
                            .transition(.opacity)
                    }
                }
            }
        }
    }
}

// MARK: - 4. Breakwater — Stack Blocks

private struct BreakwaterVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    @State private var blocksPlaced: Int = 0

    private var label: String {
        switch step {
        case 1: return "10-15 ton blocks resist 3× wave uplift."
        case 2:
            if blocksPlaced < 4 { return "Tap to stack block \(blocksPlaced + 1)." }
            return "Overbuilt by 3× — survives the first storm."
        default: return "Overbuilding sounds wasteful until the storm proves you right."
        }
    }

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3,
                         step: $step, stepLabel: label, height: height) {
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let cx = w * 0.5
                let blockW = w * 0.18
                let blockH = h * 0.1
                let baseY = h * 0.65

                ZStack {
                    // Sea
                    Rectangle()
                        .fill(seaBlue.opacity(0.1))
                        .frame(width: w, height: h * 0.3)
                        .position(x: cx, y: h * 0.65)

                    // Wave arrows
                    ForEach(0..<3, id: \.self) { i in
                        Image(systemName: "arrow.right")
                            .font(.system(size: 13))
                            .foregroundStyle(seaBlue.opacity(0.4))
                            .position(x: w * 0.15, y: baseY - CGFloat(i) * 20)
                    }

                    // Stacked blocks
                    ForEach(0..<blocksPlaced, id: \.self) { i in
                        let row = i / 2
                        let col = i % 2
                        let x = cx + CGFloat(col) * blockW * 0.55 - blockW * 0.25
                        let y = baseY - CGFloat(row) * blockH

                        RoundedRectangle(cornerRadius: 3)
                            .fill(RenaissanceColors.stoneGray.opacity(0.5))
                            .frame(width: blockW, height: blockH - 2)
                            .overlay(
                                RoundedRectangle(cornerRadius: 3)
                                    .strokeBorder(RenaissanceColors.stoneGray, lineWidth: 1)
                            )
                            .position(x: x, y: y)
                            .transition(.move(edge: .top).combined(with: .opacity))

                        if row == 0 && col == 0 {
                            DimLabel(text: "15 t")
                                .position(x: x, y: y)
                        }
                    }

                    // Stack button
                    if step >= 2 && blocksPlaced < 4 {
                        Button {
                            withAnimation(.spring(response: 0.3)) { blocksPlaced += 1 }
                            SoundManager.shared.play(.tapSoft)
                            if blocksPlaced >= 4 {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    withAnimation { step = 3 }
                                }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "square.stack.3d.up").font(.system(size: 13))
                                Text("Place Block").font(RenaissanceFont.ivLabel)
                            }
                            .foregroundStyle(color)
                            .padding(.horizontal, 12).padding(.vertical, 6)
                            .background(color.opacity(0.1)).cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                        .position(x: cx, y: h * 0.15)
                    }

                    if step >= 3 {
                        FormulaText(text: "3× overbuilt = survives any storm", highlighted: true)
                            .position(x: cx, y: h * 0.88)
                            .transition(.opacity)
                    }
                }
            }
        }
    }
}

// MARK: - 5. Lighthouse — Rotate Mirror

private struct LighthouseVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    @State private var mirrorAngle: CGFloat = 0

    private var label: String {
        switch step {
        case 1: return "50 meters tall — bronze mirror reflects firelight 50 km."
        case 2: return "Drag to rotate the mirror — sweep the beam across the sea."
        default: return "Fire and reflection — solving navigation in the dark."
        }
    }

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3,
                         step: $step, stepLabel: label, height: height) {
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let cx = w * 0.5
                let towerW: CGFloat = 20
                let towerH = h * 0.5
                let topY = h * 0.2

                ZStack {
                    // Tower
                    Path { p in
                        p.move(to: CGPoint(x: cx - towerW * 0.7, y: h * 0.7))
                        p.addLine(to: CGPoint(x: cx - towerW * 0.4, y: topY))
                        p.addLine(to: CGPoint(x: cx + towerW * 0.4, y: topY))
                        p.addLine(to: CGPoint(x: cx + towerW * 0.7, y: h * 0.7))
                        p.closeSubpath()
                    }
                    .fill(RenaissanceColors.stoneGray.opacity(0.4))

                    // Fire at top
                    Image(systemName: "flame.fill")
                        .font(.system(size: 13))
                        .foregroundStyle(.orange)
                        .position(x: cx, y: topY - 8)

                    // Light beam (rotates with mirror)
                    Path { p in
                        let beamLen = w * 0.4
                        let angle = mirrorAngle - .pi / 2
                        p.move(to: CGPoint(x: cx, y: topY))
                        // Cone of light
                        let endX1 = cx + beamLen * cos(angle - 0.15)
                        let endY1 = topY + beamLen * sin(angle - 0.15)
                        let endX2 = cx + beamLen * cos(angle + 0.15)
                        let endY2 = topY + beamLen * sin(angle + 0.15)
                        p.addLine(to: CGPoint(x: endX1, y: endY1))
                        p.addLine(to: CGPoint(x: endX2, y: endY2))
                        p.closeSubpath()
                    }
                    .fill(
                        RadialGradient(
                            colors: [RenaissanceColors.ochre.opacity(0.4), RenaissanceColors.ochre.opacity(0)],
                            center: UnitPoint(x: 0.5, y: 0),
                            startRadius: 5,
                            endRadius: w * 0.4
                        )
                    )

                    // Sea
                    Rectangle()
                        .fill(seaBlue.opacity(0.08))
                        .frame(width: w, height: h * 0.2)
                        .position(x: cx, y: h * 0.8)

                    // Dimension
                    DimLine(from: CGPoint(x: cx + towerW, y: topY),
                            to: CGPoint(x: cx + towerW, y: h * 0.7))
                        .stroke(IVMaterialColors.dimColor, lineWidth: 0.8)
                    DimLabel(text: "50 m")
                        .position(x: cx + towerW + 18, y: h * 0.45)

                    // Drag to rotate (step 2)
                    if step >= 2 {
                        Color.clear
                            .contentShape(Rectangle())
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        mirrorAngle = value.translation.width * 0.01
                                        mirrorAngle = max(-1, min(1, mirrorAngle))
                                    }
                                    .onEnded { _ in
                                        SoundManager.shared.play(.tapSoft)
                                        if abs(mirrorAngle) > 0.5 { withAnimation { step = 3 } }
                                    }
                            )
                    }

                    if step >= 3 {
                        FormulaText(text: "Fire + bronze mirror = 50 km visible", highlighted: true)
                            .position(x: cx, y: h * 0.92)
                            .transition(.opacity)
                    }
                }
            }
        }
    }
}

// MARK: - 6. Harbor Stone — Salt Test

private struct HarborStoneVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    @State private var saltPoured = false

    private var label: String {
        switch step {
        case 1: return "Not all stone survives salt water."
        case 2:
            if !saltPoured { return "Tap to pour salt water on both stones." }
            return "Tufa absorbs harmlessly — marble cracks from inside."
        default: return "The softest stone wins at the harbor."
        }
    }

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3,
                         step: $step, stepLabel: label, height: height) {
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let blockW = w * 0.25
                let blockH = h * 0.28

                ZStack {
                    // Tufa block (left)
                    VStack(spacing: 4) {
                        Text("TUFA").font(RenaissanceFont.visualTitle).tracking(0.5).foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.5))
                        ZStack {
                            RoundedRectangle(cornerRadius: 4).fill(tufaBrown).frame(width: blockW, height: blockH)
                            // Pores (visible)
                            ForEach(0..<6, id: \.self) { i in
                                Circle().fill(tufaBrown.opacity(0.4)).frame(width: CGFloat.random(in: 3...7))
                                    .offset(x: CGFloat(i * 17 % 30 - 15), y: CGFloat(i * 13 % 30 - 15))
                            }
                            if saltPoured {
                                // Salt fills pores (harmless)
                                ForEach(0..<4, id: \.self) { i in
                                    Circle().fill(Color.white.opacity(0.4)).frame(width: 3)
                                        .offset(x: CGFloat(i * 17 % 20 - 10), y: CGFloat(i * 11 % 20 - 10))
                                }
                            }
                        }
                        if saltPoured {
                            Text("Absorbs safely").font(RenaissanceFont.ivFormula).foregroundStyle(RenaissanceColors.sageGreen).transition(.opacity)
                        }
                        Text("Porous").font(RenaissanceFont.ivBody).foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.4))
                    }
                    .position(x: w * 0.28, y: h * 0.4)

                    // Marble block (right)
                    VStack(spacing: 4) {
                        Text("MARBLE").font(RenaissanceFont.visualTitle).tracking(0.5).foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.5))
                        ZStack {
                            RoundedRectangle(cornerRadius: 4).fill(Color(red: 0.90, green: 0.88, blue: 0.86)).frame(width: blockW, height: blockH)
                            if saltPoured {
                                ForEach(0..<3, id: \.self) { i in
                                    Path { p in
                                        p.move(to: CGPoint(x: CGFloat(i * 20 + 5), y: 3))
                                        p.addLine(to: CGPoint(x: CGFloat(i * 15 + 10), y: blockH - 3))
                                    }
                                    .stroke(RenaissanceColors.errorRed.opacity(0.5), lineWidth: 1)
                                    .frame(width: blockW, height: blockH)
                                }
                            }
                        }
                        if saltPoured {
                            Text("Cracks inside").font(RenaissanceFont.ivFormula).foregroundStyle(RenaissanceColors.errorRed).transition(.opacity)
                        }
                        Text("Dense").font(RenaissanceFont.ivBody).foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.4))
                    }
                    .position(x: w * 0.72, y: h * 0.4)

                    // Pour button
                    if step >= 2 && !saltPoured {
                        Button {
                            withAnimation(.spring(response: 0.4)) { saltPoured = true }
                            SoundManager.shared.play(.tapSoft)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { withAnimation { step = 3 } }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "drop.fill").font(.system(size: 13))
                                Text("Pour Salt Water").font(RenaissanceFont.ivLabel)
                            }
                            .foregroundStyle(seaBlue)
                            .padding(.horizontal, 12).padding(.vertical, 6)
                            .background(seaBlue.opacity(0.1)).cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                        .position(x: w * 0.5, y: h * 0.78)
                    }

                    if step >= 3 {
                        FormulaText(text: "Soft + porous beats hard + dense at sea", highlighted: true)
                            .position(x: w * 0.5, y: h * 0.85)
                            .transition(.opacity)
                    }
                }
            }
        }
    }
}

// MARK: - 7-12: Remaining Harbor Visuals (compact implementations)

private struct MarineConcreteVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    @State private var years: CGFloat = 0

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                         stepLabel: step == 1 ? "Roman marine concrete vs modern Portland." :
                                   step == 2 ? "Drag timeline — Roman strengthens, modern dissolves." :
                                   "The ocean makes Roman concrete immortal.", height: height) {
            GeometryReader { geo in
                let w = geo.size.width; let h = geo.size.height; let cx = w * 0.5
                ZStack {
                    HStack(spacing: w * 0.06) {
                        VStack(spacing: 4) {
                            Text("ROMAN").font(RenaissanceFont.visualTitle).foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.5))
                            RoundedRectangle(cornerRadius: 4).fill(RenaissanceColors.stoneGray.opacity(0.4 + years * 0.4))
                                .frame(width: w * 0.25, height: h * 0.25)
                            Text(years > 0.5 ? "Stronger" : "").font(RenaissanceFont.ivFormula).foregroundStyle(RenaissanceColors.sageGreen)
                        }
                        VStack(spacing: 4) {
                            Text("MODERN").font(RenaissanceFont.visualTitle).foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.5))
                            RoundedRectangle(cornerRadius: 4).fill(RenaissanceColors.stoneGray.opacity(0.6 - years * 0.4))
                                .frame(width: w * 0.25, height: h * 0.25)
                                .overlay { if years > 0.5 {
                                    ForEach(0..<3, id: \.self) { i in
                                        Path { p in p.move(to: CGPoint(x: CGFloat(i*20+5), y: 3)); p.addLine(to: CGPoint(x: CGFloat(i*15+8), y: h*0.25-3)) }
                                            .stroke(RenaissanceColors.errorRed.opacity(years * 0.5), lineWidth: 1)
                                            .frame(width: w*0.25, height: h*0.25)
                                    }
                                }}
                            Text(years > 0.5 ? "Dissolves" : "").font(RenaissanceFont.ivFormula).foregroundStyle(RenaissanceColors.errorRed)
                        }
                    }.position(x: cx, y: h * 0.38)

                    Text("\(Int(years * 2000)) years").font(RenaissanceFont.ivFormula).foregroundStyle(IVMaterialColors.sepiaInk).position(x: cx, y: h * 0.12)

                    if step >= 2 {
                        Slider(value: $years, in: 0...1).tint(seaBlue).frame(width: w * 0.5).position(x: cx, y: h * 0.7)
                            .onChange(of: years) { _, v in if v > 0.8 { withAnimation { step = 3 } } }
                    }
                    if step >= 3 { FormulaText(text: "Seawater = secret ingredient", highlighted: true).position(x: cx, y: h * 0.85).transition(.opacity) }
                }
            }
        }
    }
}

private struct HullProtectionVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    @State private var layersAdded: Int = 0
    private let parts = [("Oak planks", RenaissanceColors.warmBrown.opacity(0.5)), ("Lead sheet", IVMaterialColors.leadGray), ("Copper tacks", Color(red: 0.80, green: 0.55, blue: 0.35))]

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                         stepLabel: layersAdded < 3 ? "Tap to add layer \(layersAdded + 1)." : "Protection weighs something — it always does.", height: height) {
            GeometryReader { geo in
                let w = geo.size.width; let h = geo.size.height; let cx = w * 0.5
                ZStack {
                    ForEach(0..<layersAdded, id: \.self) { i in
                        RoundedRectangle(cornerRadius: 4).fill(parts[i].1).frame(width: w * 0.5 - CGFloat(i)*8, height: h * 0.18)
                            .position(x: cx, y: h * 0.35 + CGFloat(i) * h * 0.12).transition(.opacity)
                        DimLabel(text: parts[i].0).position(x: cx + w * 0.32, y: h * 0.35 + CGFloat(i) * h * 0.12)
                    }
                    if step >= 2 && layersAdded < 3 {
                        Button { withAnimation(.spring(response: 0.3)) { layersAdded += 1 }; SoundManager.shared.play(.tapSoft)
                            if layersAdded >= 3 { DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { withAnimation { step = 3 } } }
                        } label: { Text("Add \(parts[layersAdded].0)").font(RenaissanceFont.ivLabel).foregroundStyle(color).padding(.horizontal, 12).padding(.vertical, 6).background(color.opacity(0.1)).cornerRadius(6) }
                            .buttonStyle(.plain).position(x: cx, y: h * 0.82)
                    }
                    if step >= 3 { FormulaText(text: "Planks → Lead → Tacks", highlighted: true).position(x: cx, y: h * 0.85).transition(.opacity) }
                }
            }
        }
    }
}

private struct WarehouseTrussVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    @State private var loadWeight: CGFloat = 0
    private var tons: Int { Int(loadWeight * 20) }

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                         stepLabel: step == 1 ? "Queen-post truss spans 12-15m of warehouse." : step == 2 ? "Drag to load cargo — watch the truss flex." : "Oak tannins naturally repel moisture.", height: height) {
            GeometryReader { geo in
                let w = geo.size.width; let h = geo.size.height; let cx = w * 0.5
                let trussW = w * 0.65; let trussY = h * 0.35; let deflect = loadWeight * 6
                ZStack {
                    Path { p in p.move(to: CGPoint(x: cx - trussW*0.5, y: trussY)); p.addQuadCurve(to: CGPoint(x: cx + trussW*0.5, y: trussY), control: CGPoint(x: cx, y: trussY + deflect)) }
                        .stroke(RenaissanceColors.warmBrown.opacity(0.6), lineWidth: 3)
                    Path { p in p.move(to: CGPoint(x: cx - trussW*0.5, y: trussY + h*0.15)); p.addLine(to: CGPoint(x: cx + trussW*0.5, y: trussY + h*0.15)) }
                        .stroke(RenaissanceColors.warmBrown.opacity(0.4), lineWidth: 2)
                    ForEach([-0.25, 0.25], id: \.self) { off in
                        Path { p in p.move(to: CGPoint(x: cx + trussW * off, y: trussY + deflect * abs(off) * 2)); p.addLine(to: CGPoint(x: cx + trussW * off, y: trussY + h*0.15)) }
                            .stroke(RenaissanceColors.warmBrown.opacity(0.5), lineWidth: 2)
                    }
                    Text("\(tons) tons").font(RenaissanceFont.ivFormula).foregroundStyle(IVMaterialColors.sepiaInk).position(x: cx, y: h * 0.12)
                    if step >= 2 { Slider(value: $loadWeight, in: 0...1).tint(color).frame(width: w*0.5).position(x: cx, y: h*0.72)
                        .onChange(of: loadWeight) { _, v in if v > 0.7 { withAnimation { step = 3 } } } }
                    if step >= 3 { FormulaText(text: "Oak + tannins = naturally waterproof", highlighted: true).position(x: cx, y: h*0.85).transition(.opacity) }
                }
            }
        }
    }
}

private struct PoplarPilesVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    @State private var pilesHammered: Int = 0

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                         stepLabel: pilesHammered < 5 ? "Tap to drive pile \(pilesHammered + 1)." : "Poplar swells tight in water — natural seal.", height: height) {
            GeometryReader { geo in
                let w = geo.size.width; let h = geo.size.height; let cx = w * 0.5
                let seaY = h * 0.35
                ZStack {
                    Rectangle().fill(seaBlue.opacity(0.1)).frame(width: w, height: h * 0.5).position(x: cx, y: h * 0.6)
                    Path { p in p.move(to: CGPoint(x: w*0.1, y: seaY)); p.addLine(to: CGPoint(x: w*0.9, y: seaY)) }.stroke(seaBlue.opacity(0.3), lineWidth: 1)
                    ForEach(0..<pilesHammered, id: \.self) { i in
                        RoundedRectangle(cornerRadius: 1).fill(RenaissanceColors.warmBrown.opacity(0.5)).frame(width: 6, height: h * 0.35)
                            .position(x: w * 0.25 + CGFloat(i) * w * 0.12, y: h * 0.52).transition(.move(edge: .top))
                    }
                    if step >= 2 && pilesHammered < 5 {
                        Button { withAnimation(.spring(response: 0.3)) { pilesHammered += 1 }; SoundManager.shared.play(.tapSoft); HapticsManager.shared.play(.buttonTap)
                            if pilesHammered >= 5 { DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { withAnimation { step = 3 } } }
                        } label: { HStack(spacing: 4) { Image(systemName: "arrow.down").font(.system(size: 13)); Text("Drive Pile").font(RenaissanceFont.ivLabel) }
                            .foregroundStyle(color).padding(.horizontal, 12).padding(.vertical, 6).background(color.opacity(0.1)).cornerRadius(6) }
                            .buttonStyle(.plain).position(x: cx, y: h * 0.12)
                    }
                    if step >= 3 { FormulaText(text: "Poplar swells tight — natural waterproof seal", highlighted: true).position(x: cx, y: h*0.88).transition(.opacity) }
                }
            }
        }
    }
}

private struct MarineMortarVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var scoops: Int = 0
    @State private var seawaterAdded = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10).fill(RenaissanceColors.parchment)
            RoundedRectangle(cornerRadius: 10).strokeBorder(color.opacity(0.2), lineWidth: 1)
            IVBlueprintGrid()
            VStack(spacing: 10) {
                FormulaText(text: "1 Lime : 3 Volcanic Ash + Seawater", highlighted: seawaterAdded).padding(.top, 8)
                HStack(spacing: 12) {
                    Button { guard scoops == 0 else { return }; withAnimation(.spring(response: 0.3)) { scoops = 1 }; SoundManager.shared.play(.tapSoft) } label: {
                        Text("+ Lime").font(RenaissanceFont.ivLabel).padding(.horizontal, 12).padding(.vertical, 6)
                            .background(scoops >= 1 ? RenaissanceColors.stoneGray.opacity(0.1) : Color.white.opacity(0.3)).cornerRadius(6)
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(scoops < 1 ? color : RenaissanceColors.stoneGray.opacity(0.2), lineWidth: scoops < 1 ? 2 : 0.5))
                    }.buttonStyle(.plain).opacity(scoops >= 1 ? 0.4 : 1).foregroundStyle(IVMaterialColors.sepiaInk)
                    Button { guard scoops >= 1 && scoops < 4 else { return }; withAnimation(.spring(response: 0.3)) { scoops += 1 }; SoundManager.shared.play(.tapSoft) } label: {
                        Text("+ Ash").font(RenaissanceFont.ivLabel).padding(.horizontal, 12).padding(.vertical, 6)
                            .background(scoops >= 4 ? RenaissanceColors.stoneGray.opacity(0.1) : Color(red: 0.65, green: 0.40, blue: 0.30).opacity(0.15)).cornerRadius(6)
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke((scoops >= 1 && scoops < 4) ? color : RenaissanceColors.stoneGray.opacity(0.2), lineWidth: (scoops >= 1 && scoops < 4) ? 2 : 0.5))
                    }.buttonStyle(.plain).opacity(scoops >= 4 ? 0.4 : 1).foregroundStyle(IVMaterialColors.sepiaInk)
                }
                if scoops >= 4 && !seawaterAdded {
                    Button { withAnimation(.spring(response: 0.3)) { seawaterAdded = true }; SoundManager.shared.play(.correctChime) } label: {
                        HStack(spacing: 4) { Image(systemName: "drop.fill").font(.system(size: 13)); Text("Add SEAWATER (not fresh!)").font(RenaissanceFont.ivLabel) }
                            .foregroundStyle(seaBlue).padding(.horizontal, 14).padding(.vertical, 8).background(seaBlue.opacity(0.1)).cornerRadius(8)
                    }.buttonStyle(.plain)
                }
                if seawaterAdded { FormulaText(text: "Sets underwater in 7 days", highlighted: true) }
                Text(scoops < 1 ? "Add lime first" : scoops < 4 ? "Add ash (3 scoops)" : !seawaterAdded ? "Now the secret: SEAWATER" : "Salt triggers the reaction")
                    .font(RenaissanceFont.ivBody).foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.6))
                Spacer()
            }.padding(.horizontal, 12)
        }.frame(height: height).clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

private struct LeadCastingVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    @State private var temperature: CGFloat = 0
    private var tempC: Int { Int(temperature * 600) }
    private var isMolten: Bool { tempC >= 327 }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10).fill(RenaissanceColors.parchment)
            RoundedRectangle(cornerRadius: 10).strokeBorder(color.opacity(0.2), lineWidth: 1)
            IVBlueprintGrid()
            VStack(spacing: 10) {
                HStack(spacing: 4) {
                    Image(systemName: "thermometer.medium").font(.system(size: 14)).foregroundStyle(tempC > 300 ? .orange : IVMaterialColors.sepiaInk.opacity(0.4))
                    Text("\(tempC)°C").font(.custom("EBGaramond-Bold", size: 18)).foregroundStyle(isMolten ? RenaissanceColors.sageGreen : IVMaterialColors.sepiaInk).monospacedDigit()
                }.padding(.top, 8)
                RoundedRectangle(cornerRadius: 6).fill(isMolten ? IVMaterialColors.leadGray.opacity(0.3) : IVMaterialColors.leadGray)
                    .frame(width: 70, height: isMolten ? 25 : 45).shadow(color: isMolten ? .orange.opacity(0.3) : .clear, radius: 6)
                    .animation(.spring(response: 0.5), value: isMolten)
                Text(isMolten ? "Molten — pour into molds" : tempC > 200 ? "Warming..." : "Solid lead")
                    .font(RenaissanceFont.ivLabel).foregroundStyle(isMolten ? RenaissanceColors.sageGreen : IVMaterialColors.sepiaInk)
                Slider(value: $temperature, in: 0...1).tint(isMolten ? RenaissanceColors.sageGreen : .orange).frame(width: 200)
                HStack { Text("0°C").font(RenaissanceFont.ivBody); Spacer()
                    Text("327°C").font(RenaissanceFont.ivBody).foregroundStyle(RenaissanceColors.sageGreen); Spacer()
                    Text("600°C").font(RenaissanceFont.ivBody)
                }.foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.4)).frame(width: 200)
                if isMolten { FormulaText(text: "Lowest melting point = most useful metal", highlighted: true) }
                Spacer()
            }.padding(.horizontal, 12)
        }.frame(height: height).clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
