import SwiftUI

/// Interactive science visuals for Roman Baths knowledge cards
struct RomanBathsInteractiveVisuals {

    @ViewBuilder
    static func view(for visual: CardVisual, color: Color, height: CGFloat = 275) -> some View {
        let h = height
        Group {
            switch visual.title {
            case let t where t.contains("More Than a Bath"):
                ThermaeFloorPlanVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Hypocaust"):
                HypocaustVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Castellum") || t.contains("3 Outlets"):
                CastellumVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Temperature Gradient") || t.contains("Bath Temperature"):
                BathGradientVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Zero Waste") || t.contains("10 Million"):
                DrainFlowVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Bath Wall") || t.contains("3 Layers"):
                BathWallLayersVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Bath Concrete") || t.contains("1:4"):
                BathConcreteVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Making Glass") || t.contains("Sand at"):
                GlassMakingVisual(visual: visual, color: color, height: h)
            case let t where t.contains("King-Post") || t.contains("Truss"):
                TrussLoadVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Furnace") && t.contains("Floor"):
                FurnaceGradientVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Glass Recipe") || t.contains("Roman Glass Recipe"):
                GlassRecipeVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Venturi"):
                VenturiEffectVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Amphora"):
                AmphoraVisual(visual: visual, color: color, height: h)
            default:
                EmptyView()
            }
        }
    }

    static func hasInteractiveVisual(for visual: CardVisual) -> Bool {
        let t = visual.title
        return t.contains("More Than a Bath") || t.contains("Hypocaust") ||
               t.contains("Castellum") || t.contains("3 Outlets") ||
               t.contains("Bath Temperature") || t.contains("Temperature Gradient") ||
               t.contains("Zero Waste") || t.contains("10 Million") ||
               t.contains("Bath Wall") || t.contains("3 Layers") ||
               t.contains("Bath Concrete") || t.contains("1:4") ||
               t.contains("Making Glass") || t.contains("Sand at") ||
               t.contains("King-Post") || t.contains("Truss") ||
               (t.contains("Furnace") && t.contains("Floor")) ||
               t.contains("Glass Recipe") || t.contains("Roman Glass Recipe") ||
               t.contains("Venturi") || t.contains("Amphora")
    }
}

// MARK: - Local Colors (unique to Roman Baths)

private let warmOrange = Color(red: 0.90, green: 0.65, blue: 0.35)
private let coolBlue = Color(red: 0.45, green: 0.60, blue: 0.80)

private typealias TeachingContainer = IVTeachingContainer
private typealias DimLabel = IVDimLabel
private typealias FormulaText = IVFormulaText
private typealias DimLine = IVDimLine

// MARK: - 1. Thermae Floor Plan — Tap Rooms

private struct ThermaeFloorPlanVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    @State private var discoveredRooms: Set<Int> = []

    private let rooms: [(name: String, icon: String, color: Color)] = [
        ("Caldarium", "flame.fill", IVMaterialColors.hotRed),
        ("Tepidarium", "thermometer.medium", warmOrange),
        ("Frigidarium", "snowflake", coolBlue),
        ("Palaestra", "figure.run", RenaissanceColors.sageGreen),
        ("Library", "book.fill", RenaissanceColors.ochre),
        ("Garden", "leaf.fill", RenaissanceColors.sageGreen.opacity(0.7)),
    ]

    private var label: String {
        switch step {
        case 1: return "Not just a bath — a social center for 1,600 people."
        case 2:
            if discoveredRooms.count < rooms.count { return "Tap each room to discover what's inside." }
            return "Bath + gym + library + garden — almost free for all citizens."
        default: return "Social engineering as architecture — open to everyone."
        }
    }

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3,
                         step: $step, stepLabel: label, height: height) {
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height

                // Room layout (simplified floor plan grid)
                let cols = 3
                let rows = 2
                let cellW = w * 0.25
                let cellH = h * 0.28
                let startX = w * 0.5 - CGFloat(cols) * cellW * 0.5
                let startY = h * 0.18

                ZStack {
                    // Outer wall
                    RoundedRectangle(cornerRadius: 6)
                        .strokeBorder(IVMaterialColors.stoneGray, lineWidth: 2)
                        .frame(width: CGFloat(cols) * cellW + 16, height: CGFloat(rows) * cellH + 16)
                        .position(x: w * 0.5, y: startY + CGFloat(rows) * cellH * 0.5)

                    if step >= 2 {
                        ForEach(0..<rooms.count, id: \.self) { i in
                            let col = i % cols
                            let row = i / cols
                            let x = startX + CGFloat(col) * cellW + cellW * 0.5 + 8
                            let y = startY + CGFloat(row) * cellH + cellH * 0.5
                            let discovered = discoveredRooms.contains(i)

                            RoundedRectangle(cornerRadius: 4)
                                .fill(discovered ? rooms[i].color.opacity(0.2) : IVMaterialColors.stoneGray.opacity(0.08))
                                .frame(width: cellW - 6, height: cellH - 6)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .strokeBorder(discovered ? rooms[i].color.opacity(0.4) : IVMaterialColors.stoneGray.opacity(0.2), lineWidth: 1)
                                )
                                .overlay {
                                    if discovered {
                                        VStack(spacing: 2) {
                                            Image(systemName: rooms[i].icon)
                                                .font(.system(size: 14))
                                                .foregroundStyle(rooms[i].color)
                                            Text(rooms[i].name)
                                                .font(RenaissanceFont.visualTitle)
                                                .foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.6))
                                        }
                                    } else {
                                        Text("?")
                                            .font(.custom("EBGaramond-Bold", size: 16))
                                            .foregroundStyle(color.opacity(0.3))
                                    }
                                }
                                .position(x: x, y: y)
                                .onTapGesture {
                                    guard !discovered else { return }
                                    withAnimation(.spring(response: 0.3)) { discoveredRooms.insert(i) }
                                    SoundManager.shared.play(.tapSoft)
                                    if discoveredRooms.count == rooms.count {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            withAnimation { step = 3 }
                                        }
                                    }
                                }
                        }
                    }

                    if step >= 3 {
                        FormulaText(text: "6 rooms — one ticket — almost free", highlighted: true)
                            .position(x: w * 0.5, y: h * 0.88)
                            .transition(.opacity)
                    }
                }
            }
        }
    }
}

// MARK: - 2. Hypocaust — Furnace → Under Floor → Up Walls

private struct HypocaustVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    @State private var heatPhase: Int = 0 // 0=off, 1=furnace lit, 2=under floor, 3=up walls

    private var label: String {
        switch step {
        case 1: return "The world's first central heating — 1st century AD."
        case 2:
            switch heatPhase {
            case 0: return "Tap to light the furnace."
            case 1: return "Hot air flows under the raised floor."
            case 2: return "Air rises through hollow walls (tubuli)."
            default: return "Furnace → floor → walls → roof vents. Full circuit."
            }
        default: return "Central heating reinvented 1,800 years later."
        }
    }

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3,
                         step: $step, stepLabel: label, height: height) {
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let cx = w * 0.5

                ZStack {
                    // Room cross-section
                    let floorY = h * 0.5
                    let ceilingY = h * 0.15
                    let baseY = h * 0.7

                    // Walls
                    Path { p in
                        p.move(to: CGPoint(x: w * 0.2, y: ceilingY))
                        p.addLine(to: CGPoint(x: w * 0.2, y: baseY))
                        p.move(to: CGPoint(x: w * 0.8, y: ceilingY))
                        p.addLine(to: CGPoint(x: w * 0.8, y: baseY))
                    }
                    .stroke(IVMaterialColors.stoneGray, lineWidth: 3)

                    // Floor (raised on pilae)
                    Path { p in
                        p.move(to: CGPoint(x: w * 0.2, y: floorY))
                        p.addLine(to: CGPoint(x: w * 0.8, y: floorY))
                    }
                    .stroke(IVMaterialColors.stoneGray, lineWidth: 2)

                    // Pilae stacks (under-floor supports)
                    ForEach(0..<4, id: \.self) { i in
                        let px = w * 0.28 + CGFloat(i) * w * 0.15
                        RoundedRectangle(cornerRadius: 1)
                            .fill(IVMaterialColors.stoneGray.opacity(0.5))
                            .frame(width: 8, height: h * 0.15)
                            .position(x: px, y: floorY + h * 0.08)
                    }

                    // Furnace (left side)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(heatPhase >= 1 ? IVMaterialColors.hotRed.opacity(0.4) : IVMaterialColors.stoneGray.opacity(0.2))
                        .frame(width: w * 0.12, height: h * 0.2)
                        .position(x: w * 0.12, y: floorY + h * 0.05)

                    if heatPhase >= 1 {
                        // Flame
                        Image(systemName: "flame.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(IVMaterialColors.hotRed)
                            .position(x: w * 0.12, y: floorY + h * 0.02)
                    }

                    // Heat flow arrows
                    if heatPhase >= 1 {
                        // Under floor flow
                        ForEach(0..<3, id: \.self) { i in
                            Image(systemName: "arrow.right")
                                .font(.system(size: 13))
                                .foregroundStyle(IVMaterialColors.hotRed.opacity(0.5))
                                .position(x: w * 0.3 + CGFloat(i) * w * 0.15, y: floorY + h * 0.08)
                        }
                    }

                    if heatPhase >= 2 {
                        // Up through walls (tubuli)
                        ForEach([0.22, 0.78], id: \.self) { xFrac in
                            ForEach(0..<2, id: \.self) { j in
                                Image(systemName: "arrow.up")
                                    .font(.system(size: 13))
                                    .foregroundStyle(warmOrange.opacity(0.5))
                                    .position(x: w * xFrac, y: floorY - CGFloat(j + 1) * h * 0.12)
                            }
                        }
                    }

                    if heatPhase >= 3 {
                        // Roof vents
                        ForEach([0.35, 0.65], id: \.self) { xFrac in
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 13))
                                .foregroundStyle(warmOrange.opacity(0.3))
                                .position(x: w * xFrac, y: ceilingY - 8)
                        }
                    }

                    // Labels
                    DimLabel(text: "Floor")
                        .position(x: w * 0.87, y: floorY - 8)
                    DimLabel(text: "Pilae")
                        .position(x: w * 0.87, y: floorY + h * 0.08)

                    // Action button
                    if step >= 2 && heatPhase < 3 {
                        Button {
                            withAnimation(.spring(response: 0.4)) { heatPhase += 1 }
                            SoundManager.shared.play(.tapSoft)
                            if heatPhase >= 3 {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    withAnimation { step = 3 }
                                }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: heatPhase == 0 ? "flame.fill" : "arrow.right")
                                    .font(.system(size: 13))
                                Text(heatPhase == 0 ? "Light Furnace" : "Flow →")
                                    .font(RenaissanceFont.ivLabel)
                            }
                            .foregroundStyle(IVMaterialColors.hotRed)
                            .padding(.horizontal, 12).padding(.vertical, 6)
                            .background(IVMaterialColors.hotRed.opacity(0.1)).cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                        .position(x: cx, y: h * 0.88)
                    }

                    if step >= 3 {
                        FormulaText(text: "Full circuit: furnace → floor → walls → roof", highlighted: true)
                            .position(x: cx, y: h * 0.88)
                            .transition(.opacity)
                    }
                }
            }
        }
    }
}

// MARK: - 3. Castellum — Water Level Slider

private struct CastellumVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    @State private var waterLevel: CGFloat = 1.0

    private var hotActive: Bool { waterLevel > 0.7 }
    private var warmActive: Bool { waterLevel > 0.4 }
    private var coldActive: Bool { waterLevel > 0.1 }

    private var label: String {
        switch step {
        case 1: return "Three outlets at different heights — gravity rations automatically."
        case 2: return "Drag water level down — watch which outlets cut off first."
        default: return "Low supply? Hot cuts first, cold lasts longest."
        }
    }

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3,
                         step: $step, stepLabel: label, height: height) {
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let cx = w * 0.5
                let tankW = w * 0.3
                let tankH = h * 0.6
                let tankY = h * 0.4

                ZStack {
                    // Water tank
                    RoundedRectangle(cornerRadius: 4)
                        .strokeBorder(IVMaterialColors.stoneGray, lineWidth: 2)
                        .frame(width: tankW, height: tankH)
                        .position(x: cx, y: tankY)

                    // Water fill
                    RoundedRectangle(cornerRadius: 3)
                        .fill(IVMaterialColors.waterBlue.opacity(0.4))
                        .frame(width: tankW - 4, height: (tankH - 4) * waterLevel)
                        .position(x: cx, y: tankY + (tankH - (tankH - 4) * waterLevel) / 2 - 2)

                    // Three outlet pipes at different heights
                    let outlets: [(name: String, height: CGFloat, color: Color, active: Bool)] = [
                        ("Hot", 0.25, IVMaterialColors.hotRed, hotActive),
                        ("Warm", 0.50, warmOrange, warmActive),
                        ("Cold", 0.75, coolBlue, coldActive),
                    ]

                    ForEach(0..<3, id: \.self) { i in
                        let outlet = outlets[i]
                        let oy = tankY - tankH * 0.5 + tankH * outlet.height
                        let pipeEndX = cx + tankW * 0.5 + w * 0.15

                        // Pipe
                        Path { p in
                            p.move(to: CGPoint(x: cx + tankW * 0.5, y: oy))
                            p.addLine(to: CGPoint(x: pipeEndX, y: oy))
                        }
                        .stroke(outlet.active ? outlet.color : IVMaterialColors.stoneGray.opacity(0.3), lineWidth: 3)

                        // Flow drops
                        if outlet.active {
                            Circle()
                                .fill(outlet.color.opacity(0.5))
                                .frame(width: 6, height: 6)
                                .position(x: pipeEndX + 8, y: oy)
                        }

                        // Label
                        Text(outlet.name)
                            .font(RenaissanceFont.visualTitle)
                            .foregroundStyle(outlet.active ? outlet.color : IVMaterialColors.sepiaInk.opacity(0.3))
                            .position(x: pipeEndX + 25, y: oy)

                        if !outlet.active {
                            Text("OFF")
                                .font(RenaissanceFont.ivFormula)
                                .foregroundStyle(RenaissanceColors.errorRed.opacity(0.5))
                                .position(x: pipeEndX + 25, y: oy + 10)
                        }
                    }

                    // Slider
                    if step >= 2 {
                        VStack(spacing: 2) {
                            Slider(value: $waterLevel, in: 0...1)
                                .tint(IVMaterialColors.waterBlue)
                                .frame(width: w * 0.3)
                                .rotationEffect(.degrees(-90))
                                .onChange(of: waterLevel) { _, val in
                                    if val < 0.15 { withAnimation { step = 3 } }
                                }
                        }
                        .position(x: cx - tankW * 0.5 - 25, y: tankY)
                    }

                    if step >= 3 {
                        FormulaText(text: "Gravity rations — no valves needed", highlighted: true)
                            .position(x: cx, y: h * 0.88)
                            .transition(.opacity)
                    }
                }
            }
        }
    }
}

// MARK: - 4. Bath Temperature Gradient — Tap Rooms

private struct BathGradientVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    @State private var visitedRooms: Set<Int> = []

    private let bathRooms: [(name: String, temp: Int, color: Color)] = [
        ("Frigidarium", 15, coolBlue),
        ("Tepidarium", 28, warmOrange.opacity(0.6)),
        ("Caldarium", 40, IVMaterialColors.hotRed),
    ]

    private var label: String {
        switch step {
        case 1: return "Cold → warm → hot: a temperature gradient you walk through."
        case 2:
            if visitedRooms.count < 3 { return "Tap each room — feel the temperature rise." }
            return "15°C to 40°C — the body acclimates gradually."
        default: return "Temperature gradient as architecture."
        }
    }

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3,
                         step: $step, stepLabel: label, height: height) {
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let cx = w * 0.5
                let roomW = w * 0.22
                let roomH = h * 0.4

                ZStack {
                    // Thermometer bar across top
                    if !visitedRooms.isEmpty {
                        HStack(spacing: 0) {
                            ForEach(0..<3, id: \.self) { i in
                                Rectangle()
                                    .fill(visitedRooms.contains(i) ? bathRooms[i].color.opacity(0.3) : IVMaterialColors.stoneGray.opacity(0.05))
                                    .frame(width: w * 0.25, height: 6)
                            }
                        }
                        .clipShape(Capsule())
                        .position(x: cx, y: h * 0.1)
                    }

                    // Three rooms
                    if step >= 2 {
                        HStack(spacing: w * 0.03) {
                            ForEach(0..<3, id: \.self) { i in
                                let visited = visitedRooms.contains(i)
                                let room = bathRooms[i]

                                VStack(spacing: 6) {
                                    Text(room.name)
                                        .font(RenaissanceFont.visualTitle)
                                        .foregroundStyle(visited ? room.color : IVMaterialColors.sepiaInk.opacity(0.4))

                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(visited ? room.color.opacity(0.15) : IVMaterialColors.stoneGray.opacity(0.06))
                                        .frame(width: roomW, height: roomH)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 6)
                                                .strokeBorder(visited ? room.color.opacity(0.4) : IVMaterialColors.stoneGray.opacity(0.2), lineWidth: 1)
                                        )
                                        .overlay {
                                            if visited {
                                                VStack(spacing: 4) {
                                                    Image(systemName: "thermometer.medium")
                                                        .font(.system(size: 16))
                                                        .foregroundStyle(room.color)
                                                    Text("\(room.temp)°C")
                                                        .font(.custom("EBGaramond-Bold", size: 16))
                                                        .foregroundStyle(room.color)
                                                }
                                            } else {
                                                Image(systemName: "hand.tap")
                                                    .font(.system(size: 16))
                                                    .foregroundStyle(color.opacity(0.2))
                                            }
                                        }

                                    if visited {
                                        // Arrow to next room
                                        if i < 2 {
                                            Image(systemName: "arrow.right")
                                                .font(.system(size: 13))
                                                .foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.3))
                                        }
                                    }
                                }
                                .onTapGesture {
                                    guard !visited else { return }
                                    // Must visit in order
                                    guard i == visitedRooms.count else { return }
                                    withAnimation(.spring(response: 0.3)) { visitedRooms.insert(i) }
                                    SoundManager.shared.play(.tapSoft)
                                    if visitedRooms.count == 3 {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            withAnimation { step = 3 }
                                        }
                                    }
                                }
                            }
                        }
                        .position(x: cx, y: h * 0.45)
                    }

                    if step >= 3 {
                        FormulaText(text: "15°C → 28°C → 40°C — gradual acclimatization", highlighted: true)
                            .position(x: cx, y: h * 0.85)
                            .transition(.opacity)
                    }
                }
            }
        }
    }
}

// MARK: - 5. Drain Flow — Water Follows 2% Slope

private struct DrainFlowVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    @State private var flowStarted = false
    @State private var waterProgress: CGFloat = 0

    private var label: String {
        switch step {
        case 1: return "10 million liters daily — and zero waste."
        case 2:
            if !flowStarted { return "Tap to start the drain — watch water follow the 2% slope." }
            return "Floor slopes 2% → drains → Cloaca Maxima sewer."
        default: return "Drain water reused for latrines — nothing wasted."
        }
    }

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3,
                         step: $step, stepLabel: label, height: height) {
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let cx = w * 0.5
                let floorY = h * 0.4
                let slopeEnd = floorY + h * 0.08 // 2% visible slope

                ZStack {
                    // Bath floor with slope
                    Path { p in
                        p.move(to: CGPoint(x: w * 0.15, y: floorY))
                        p.addLine(to: CGPoint(x: cx, y: floorY))
                        p.addLine(to: CGPoint(x: w * 0.85, y: slopeEnd))
                    }
                    .stroke(IVMaterialColors.stoneGray, lineWidth: 2)

                    // Drain opening
                    Circle()
                        .fill(IVMaterialColors.stoneGray.opacity(0.4))
                        .frame(width: 14, height: 14)
                        .position(x: w * 0.85, y: slopeEnd)

                    // Sewer pipe (below drain)
                    Path { p in
                        p.move(to: CGPoint(x: w * 0.85, y: slopeEnd + 7))
                        p.addLine(to: CGPoint(x: w * 0.85, y: h * 0.65))
                        p.addLine(to: CGPoint(x: w * 0.92, y: h * 0.65))
                    }
                    .stroke(IVMaterialColors.stoneGray.opacity(0.4), lineWidth: 2)

                    DimLabel(text: "Cloaca Maxima")
                        .position(x: w * 0.85, y: h * 0.7)

                    // Slope annotation
                    DimLabel(text: "2% slope")
                        .position(x: w * 0.65, y: floorY - 12)

                    // Water flow
                    if flowStarted {
                        Canvas { context, size in
                            for i in 0..<6 {
                                let progress = (waterProgress + CGFloat(i) * 0.15).truncatingRemainder(dividingBy: 1.0)
                                let startX = w * 0.2
                                let endX = w * 0.85
                                let dropX = startX + (endX - startX) * progress
                                let dropY = floorY + (slopeEnd - floorY) * max(0, (progress - 0.3) / 0.7) - 3

                                let rect = CGRect(x: dropX - 2.5, y: dropY - 2.5, width: 5, height: 5)
                                context.fill(Path(ellipseIn: rect), with: .color(IVMaterialColors.waterBlue.opacity(0.6)))
                            }
                        }
                        .frame(width: w, height: h)
                        .allowsHitTesting(false)
                    }

                    // Start button
                    if step >= 2 && !flowStarted {
                        Button {
                            flowStarted = true
                            SoundManager.shared.play(.tapSoft)
                            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                                waterProgress = 1.0
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                withAnimation { step = 3 }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "drop.fill").font(.system(size: 13))
                                Text("Open Drain").font(RenaissanceFont.ivLabel)
                            }
                            .foregroundStyle(IVMaterialColors.waterBlue)
                            .padding(.horizontal, 12).padding(.vertical, 6)
                            .background(IVMaterialColors.waterBlue.opacity(0.1)).cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                        .position(x: cx, y: h * 0.2)
                    }

                    if step >= 3 {
                        FormulaText(text: "Zero waste — drain reused for latrines", highlighted: true)
                            .position(x: cx, y: h * 0.85)
                            .transition(.opacity)
                    }
                }
            }
        }
    }
}

// MARK: - 6. Bath Wall Layers — Tap to Peel

private struct BathWallLayersVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    @State private var revealedLayers: Int = 0

    private let layers: [(name: String, color: Color, desc: String)] = [
        ("Marble veneer", IVMaterialColors.marbleWhite, "Beauty"),
        ("Opus signinum", RenaissanceColors.terracotta.opacity(0.5), "Waterproof"),
        ("Concrete core", IVMaterialColors.stoneGray, "Structure"),
    ]

    private var label: String {
        switch step {
        case 1: return "A bath wall is 3 layers — each with a different job."
        case 2:
            if revealedLayers < 3 { return "Tap to peel the next layer." }
            return "Beauty → waterproof → structure. Inside out."
        default: return "Watertight for 400 years — lead clamps hold the marble."
        }
    }

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3,
                         step: $step, stepLabel: label, height: height) {
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let cx = w * 0.5
                let wallW = w * 0.5
                let wallH = h * 0.55
                let wallY = h * 0.4

                ZStack {
                    // Layers (back to front: concrete → signinum → marble)
                    ForEach(0..<3, id: \.self) { i in
                        let layerIdx = 2 - i // draw from back (concrete) to front (marble)
                        let inset = CGFloat(i) * 8
                        let visible = revealedLayers <= layerIdx

                        if visible {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(layers[layerIdx].color.opacity(0.6))
                                .frame(width: wallW - inset * 2, height: wallH - inset * 2)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .strokeBorder(IVMaterialColors.stoneGray.opacity(0.3), lineWidth: 1)
                                )
                                .position(x: cx, y: wallY)
                        }
                    }

                    // Layer labels (shown as peeled)
                    ForEach(0..<revealedLayers, id: \.self) { i in
                        HStack(spacing: 4) {
                            Circle().fill(layers[i].color).frame(width: 8, height: 8)
                            VStack(alignment: .leading, spacing: 1) {
                                Text(layers[i].name).font(RenaissanceFont.visualTitle)
                                Text(layers[i].desc).font(RenaissanceFont.ivBody).foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.5))
                            }
                        }
                        .foregroundStyle(IVMaterialColors.sepiaInk)
                        .position(x: cx + wallW * 0.5 + 35, y: wallY - h * 0.15 + CGFloat(i) * 30)
                        .transition(.opacity)
                    }

                    // Peel button
                    if step >= 2 && revealedLayers < 3 {
                        Button {
                            withAnimation(.spring(response: 0.3)) { revealedLayers += 1 }
                            SoundManager.shared.play(.tapSoft)
                            if revealedLayers >= 3 {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    withAnimation { step = 3 }
                                }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "rectangle.on.rectangle").font(.system(size: 13))
                                Text("Peel Layer").font(RenaissanceFont.ivLabel)
                            }
                            .foregroundStyle(color)
                            .padding(.horizontal, 12).padding(.vertical, 6)
                            .background(color.opacity(0.1)).cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                        .position(x: cx, y: h * 0.82)
                    }

                    if step >= 3 {
                        FormulaText(text: "Beauty → Waterproof → Structure", highlighted: true)
                            .position(x: cx, y: h * 0.85)
                            .transition(.opacity)
                    }
                }
            }
        }
    }
}

// MARK: - 7. Bath Concrete 1:4 — Mix + Self-Heal

private struct BathConcreteVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var scoops: Int = 0 // 0=none, 1=lime, 2-5=pozzolana
    @State private var crackAppeared = false
    @State private var healed = false

    private var label: String {
        if scoops < 1 { return "1:4 ratio — extra silica for thermal cycling." }
        if scoops < 5 { return "4 scoops pozzolana — more than normal (1:3)." }
        if !crackAppeared { return "Heat cycles create micro-cracks..." }
        if !healed { return "Watch — the extra silica self-heals the crack!" }
        return "Self-healing concrete — 2,000 years before self-healing polymers."
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10).fill(RenaissanceColors.parchment)
            RoundedRectangle(cornerRadius: 10).strokeBorder(color.opacity(0.2), lineWidth: 1)
            IVBlueprintGrid()

            VStack(spacing: 10) {
                FormulaText(text: "1 Lime : 4 Pozzolana (extra silica)", highlighted: scoops >= 5)
                    .padding(.top, 8)

                // Ratio bar
                GeometryReader { geo in
                    let barW = geo.size.width - 20
                    HStack(spacing: 2) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(scoops >= 1 ? Color.white.opacity(0.6) : IVMaterialColors.stoneGray.opacity(0.15))
                            .frame(width: barW * 0.2)
                        RoundedRectangle(cornerRadius: 3)
                            .fill(scoops >= 2 ? Color(red: 0.65, green: 0.40, blue: 0.30).opacity(CGFloat(min(scoops - 1, 4)) * 0.2) : IVMaterialColors.stoneGray.opacity(0.15))
                            .frame(width: barW * 0.8)
                    }
                    .frame(height: 24)
                    .padding(.horizontal, 10)
                }
                .frame(height: 24)

                // Buttons
                if scoops < 5 {
                    HStack(spacing: 16) {
                        Button {
                            guard scoops == 0 else { return }
                            withAnimation(.spring(response: 0.3)) { scoops = 1 }
                            SoundManager.shared.play(.tapSoft)
                        } label: {
                            Text("+ Lime").font(RenaissanceFont.ivLabel)
                                .padding(.horizontal, 12).padding(.vertical, 6)
                                .background(scoops >= 1 ? IVMaterialColors.stoneGray.opacity(0.1) : Color.white.opacity(0.3))
                                .cornerRadius(6)
                                .overlay(RoundedRectangle(cornerRadius: 6).stroke(scoops < 1 ? color : IVMaterialColors.stoneGray.opacity(0.2), lineWidth: scoops < 1 ? 2 : 0.5))
                        }
                        .buttonStyle(.plain).disabled(scoops >= 1)
                        .opacity(scoops >= 1 ? 0.4 : 1)

                        Button {
                            guard scoops >= 1, scoops < 5 else { return }
                            withAnimation(.spring(response: 0.3)) { scoops += 1 }
                            SoundManager.shared.play(.tapSoft)
                            if scoops >= 5 {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                    withAnimation(.spring(response: 0.3)) { crackAppeared = true }
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                    withAnimation(.spring(response: 0.5)) { healed = true }
                                }
                            }
                        } label: {
                            Text("+ Pozzolana").font(RenaissanceFont.ivLabel)
                                .padding(.horizontal, 12).padding(.vertical, 6)
                                .background(Color(red: 0.65, green: 0.40, blue: 0.30).opacity(0.15))
                                .cornerRadius(6)
                                .overlay(RoundedRectangle(cornerRadius: 6).stroke(scoops >= 1 && scoops < 5 ? color : IVMaterialColors.stoneGray.opacity(0.2), lineWidth: scoops >= 1 && scoops < 5 ? 2 : 0.5))
                        }
                        .buttonStyle(.plain).disabled(scoops < 1 || scoops >= 5)
                        .opacity(scoops >= 5 ? 0.4 : 1)
                    }
                }

                // Crack + heal visualization
                if crackAppeared {
                    ZStack {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(IVMaterialColors.stoneGray.opacity(0.4))
                            .frame(width: 100, height: 50)

                        // Crack line
                        Path { p in
                            p.move(to: CGPoint(x: 30, y: 5))
                            p.addLine(to: CGPoint(x: 55, y: 25))
                            p.addLine(to: CGPoint(x: 45, y: 45))
                        }
                        .stroke(healed ? RenaissanceColors.sageGreen : RenaissanceColors.errorRed, lineWidth: healed ? 0.5 : 1.5)

                        if healed {
                            // Crystal dots along crack
                            ForEach(0..<4, id: \.self) { i in
                                Image(systemName: "sparkle")
                                    .font(.system(size: 13))
                                    .foregroundStyle(RenaissanceColors.sageGreen)
                                    .offset(x: CGFloat(i * 7 - 10), y: CGFloat(i * 10 - 15))
                            }
                        }

                        Text(healed ? "Self-healed!" : "Micro-crack")
                            .font(RenaissanceFont.ivBody)
                            .foregroundStyle(healed ? RenaissanceColors.sageGreen : RenaissanceColors.errorRed)
                            .offset(y: 32)
                    }
                }

                if healed {
                    FormulaText(text: "Extra silica fills cracks automatically", highlighted: true)
                }

                Spacer()
            }
            .padding(.horizontal, 12)
        }
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - 8. Glass Making — Temp Slider

private struct GlassMakingVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    @State private var temperature: CGFloat = 0

    private var tempC: Int { Int(temperature * 1400) }
    private var isMelting: Bool { tempC >= 1000 }
    private var isMolten: Bool { tempC >= 1100 }

    private var label: String {
        switch step {
        case 1: return "Sand + heat = glass. Simple idea, extreme temperature."
        case 2: return "Drag to 1,100°C — watch sand become glass."
        default: return "Pour flat — thick but floods the room with light."
        }
    }

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3,
                         step: $step, stepLabel: label, height: height) {
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let cx = w * 0.5

                ZStack {
                    // Sand/glass block
                    let blockColor: Color = {
                        if tempC < 600 { return Color(red: 0.85, green: 0.80, blue: 0.65) } // sand
                        if tempC < 1000 { return Color(red: 0.85, green: 0.70, blue: 0.45) } // warming
                        if tempC < 1100 { return Color(red: 0.90, green: 0.55, blue: 0.25) } // melting orange
                        return Color(red: 0.75, green: 0.85, blue: 0.80).opacity(0.6) // molten glass green
                    }()

                    RoundedRectangle(cornerRadius: isMolten ? 12 : 4)
                        .fill(blockColor)
                        .frame(width: isMolten ? w * 0.4 : w * 0.25, height: isMolten ? h * 0.08 : h * 0.2)
                        .shadow(color: tempC > 800 ? .orange.opacity(0.3) : .clear, radius: 6)
                        .position(x: cx, y: h * 0.35)
                        .animation(.spring(response: 0.5), value: isMolten)

                    // Labels
                    Text(isMolten ? "Molten glass" : isMelting ? "Melting..." : "Sand (SiO₂)")
                        .font(RenaissanceFont.ivLabel)
                        .foregroundStyle(isMolten ? RenaissanceColors.sageGreen : IVMaterialColors.sepiaInk)
                        .position(x: cx, y: h * 0.18)

                    // Temperature
                    Text("\(tempC)°C")
                        .font(.custom("EBGaramond-Bold", size: 18))
                        .monospacedDigit()
                        .foregroundStyle(isMolten ? RenaissanceColors.sageGreen : (tempC > 600 ? .orange : IVMaterialColors.sepiaInk))
                        .position(x: cx, y: h * 0.55)

                    // Slider
                    if step >= 2 {
                        Slider(value: $temperature, in: 0...1)
                            .tint(isMolten ? RenaissanceColors.sageGreen : .orange)
                            .frame(width: w * 0.6)
                            .position(x: cx, y: h * 0.68)
                            .onChange(of: temperature) { _, _ in
                                if isMolten { withAnimation { step = 3 } }
                            }
                    }

                    if step >= 3 {
                        FormulaText(text: "Pour flat → thick window → light floods in", highlighted: true)
                            .position(x: cx, y: h * 0.85)
                            .transition(.opacity)
                    }
                }
            }
        }
    }
}

// MARK: - 9. King-Post Truss — Drag Weight

private struct TrussLoadVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    @State private var loadWeight: CGFloat = 0 // 0-1

    private var tons: Int { Int(loadWeight * 20) }
    private var isOverloaded: Bool { loadWeight > 0.85 }

    private var label: String {
        switch step {
        case 1: return "A king-post truss spans 25 meters — no columns needed."
        case 2: return "Drag to add weight — watch force distribution."
        default: return "Depth = span ÷ 20: 25m span → 1.25m deep beams."
        }
    }

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3,
                         step: $step, stepLabel: label, height: height) {
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let cx = w * 0.5
                let trussY = h * 0.35
                let trussW = w * 0.7
                let trussH = h * 0.2
                let deflection = loadWeight * 8

                ZStack {
                    // Top chord (beam — deflects under load)
                    Path { p in
                        p.move(to: CGPoint(x: cx - trussW * 0.5, y: trussY))
                        p.addQuadCurve(
                            to: CGPoint(x: cx + trussW * 0.5, y: trussY),
                            control: CGPoint(x: cx, y: trussY + deflection)
                        )
                    }
                    .stroke(RenaissanceColors.warmBrown.opacity(0.6), lineWidth: 3)

                    // Bottom chord
                    Path { p in
                        p.move(to: CGPoint(x: cx - trussW * 0.5, y: trussY + trussH))
                        p.addLine(to: CGPoint(x: cx + trussW * 0.5, y: trussY + trussH))
                    }
                    .stroke(RenaissanceColors.warmBrown.opacity(0.5), lineWidth: 2)

                    // King post (vertical center)
                    Path { p in
                        p.move(to: CGPoint(x: cx, y: trussY + deflection))
                        p.addLine(to: CGPoint(x: cx, y: trussY + trussH))
                    }
                    .stroke(RenaissanceColors.warmBrown.opacity(0.6), lineWidth: 2.5)

                    // Diagonal struts
                    ForEach([-1.0, 1.0], id: \.self) { side in
                        Path { p in
                            p.move(to: CGPoint(x: cx, y: trussY + trussH))
                            p.addLine(to: CGPoint(x: cx + side * trussW * 0.35, y: trussY + deflection * 0.5))
                        }
                        .stroke(RenaissanceColors.warmBrown.opacity(0.4), lineWidth: 1.5)
                    }

                    // Support points
                    ForEach([-1.0, 1.0], id: \.self) { side in
                        Path { p in
                            let bx = cx + side * trussW * 0.5
                            p.move(to: CGPoint(x: bx - 8, y: trussY + trussH + 8))
                            p.addLine(to: CGPoint(x: bx, y: trussY + trussH))
                            p.addLine(to: CGPoint(x: bx + 8, y: trussY + trussH + 8))
                        }
                        .stroke(IVMaterialColors.stoneGray, lineWidth: 2)
                    }

                    // Force arrows (when loaded)
                    if loadWeight > 0.2 {
                        Image(systemName: "arrow.down")
                            .font(.system(size: 13))
                            .foregroundStyle(isOverloaded ? RenaissanceColors.errorRed : color.opacity(0.5))
                            .position(x: cx, y: trussY - 15)

                        ForEach([-1.0, 1.0], id: \.self) { side in
                            Image(systemName: "arrow.down")
                                .font(.system(size: 13))
                                .foregroundStyle(color.opacity(0.3))
                                .position(x: cx + side * trussW * 0.5, y: trussY + trussH + 15)
                        }
                    }

                    // Weight display
                    Text("\(tons) tons")
                        .font(RenaissanceFont.ivFormula)
                        .foregroundStyle(isOverloaded ? RenaissanceColors.errorRed : IVMaterialColors.sepiaInk)
                        .position(x: cx, y: h * 0.12)

                    // Slider
                    if step >= 2 {
                        Slider(value: $loadWeight, in: 0...1)
                            .tint(isOverloaded ? RenaissanceColors.errorRed : color)
                            .frame(width: w * 0.5)
                            .position(x: cx, y: h * 0.75)
                            .onChange(of: loadWeight) { _, val in
                                if val > 0.7 { withAnimation { step = 3 } }
                            }
                    }

                    // Dimension
                    DimLine(from: CGPoint(x: cx - trussW * 0.5, y: h * 0.63),
                            to: CGPoint(x: cx + trussW * 0.5, y: h * 0.63))
                        .stroke(IVMaterialColors.dimColor, lineWidth: 0.8)
                    DimLabel(text: "25 m span")
                        .position(x: cx, y: h * 0.66)

                    if step >= 3 {
                        FormulaText(text: "Depth = span ÷ 20 = 1.25 m", highlighted: true)
                            .position(x: cx, y: h * 0.85)
                            .transition(.opacity)
                    }
                }
            }
        }
    }
}

// MARK: - 10. Furnace to Floor — Temperature Gradient

private struct FurnaceGradientVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    @State private var showGradient = false

    private var label: String {
        switch step {
        case 1: return "Furnace burns at 300°C — bath floor reaches 40°C."
        case 2:
            if !showGradient { return "Tap to light the furnace — watch heat spread." }
            return "Chestnut burns 45 min per log — stoker feeds every 30 min."
        default: return "300°C → 40°C — temperature controlled by distance."
        }
    }

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3,
                         step: $step, stepLabel: label, height: height) {
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let cx = w * 0.5

                ZStack {
                    // Temperature gradient bar (horizontal)
                    if showGradient {
                        LinearGradient(
                            colors: [IVMaterialColors.hotRed, warmOrange, Color(red: 0.95, green: 0.85, blue: 0.70)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: w * 0.7, height: h * 0.12)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        .position(x: cx, y: h * 0.4)
                        .transition(.opacity)

                        // Temperature labels along bar
                        HStack {
                            Text("300°C").font(RenaissanceFont.ivFormula).foregroundStyle(IVMaterialColors.hotRed)
                            Spacer()
                            Text("120°C").font(RenaissanceFont.ivBody).foregroundStyle(warmOrange)
                            Spacer()
                            Text("40°C").font(RenaissanceFont.ivFormula).foregroundStyle(IVMaterialColors.sepiaInk)
                        }
                        .frame(width: w * 0.65)
                        .position(x: cx, y: h * 0.52)
                        .transition(.opacity)

                        // Labels
                        Text("Furnace")
                            .font(RenaissanceFont.visualTitle)
                            .foregroundStyle(IVMaterialColors.hotRed)
                            .position(x: w * 0.2, y: h * 0.3)

                        Text("Bath floor")
                            .font(RenaissanceFont.visualTitle)
                            .foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.5))
                            .position(x: w * 0.8, y: h * 0.3)
                    }

                    // Furnace icon
                    Image(systemName: showGradient ? "flame.fill" : "flame")
                        .font(.system(size: 24))
                        .foregroundStyle(showGradient ? IVMaterialColors.hotRed : IVMaterialColors.stoneGray.opacity(0.3))
                        .position(x: w * 0.2, y: h * 0.4)

                    // Light button
                    if step >= 2 && !showGradient {
                        Button {
                            withAnimation(.spring(response: 0.5)) { showGradient = true }
                            SoundManager.shared.play(.tapSoft)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                withAnimation { step = 3 }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "flame.fill").font(.system(size: 13))
                                Text("Light Furnace").font(RenaissanceFont.ivLabel)
                            }
                            .foregroundStyle(IVMaterialColors.hotRed)
                            .padding(.horizontal, 12).padding(.vertical, 6)
                            .background(IVMaterialColors.hotRed.opacity(0.1)).cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                        .position(x: cx, y: h * 0.7)
                    }

                    if step >= 3 {
                        FormulaText(text: "Distance controls temperature — no thermostat needed", highlighted: true)
                            .position(x: cx, y: h * 0.85)
                            .transition(.opacity)
                    }
                }
            }
        }
    }
}

// MARK: - 11. Glass Recipe — Mix 4 Ingredients

private struct GlassRecipeVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1

    private let ingredients: [(name: String, pct: String, color: Color)] = [
        ("Silica", "60%", Color(red: 0.85, green: 0.80, blue: 0.65)),
        ("Natron", "15%", Color(red: 0.70, green: 0.75, blue: 0.80)),
        ("Lime", "10%", Color.white.opacity(0.7)),
        ("Cullet", "15%", Color(red: 0.65, green: 0.80, blue: 0.72).opacity(0.5)),
    ]

    /// step 1 = empty, 2–5 = ingredient 1-4 added, 6 = fired clear glass
    private var ingredientsAdded: Int { max(0, step - 1) }

    private var crucibleColor: Color {
        switch ingredientsAdded {
        case 0: return IVMaterialColors.stoneGray.opacity(0.15)
        case 1: return ingredients[0].color.opacity(0.3)
        case 2: return Color(red: 0.80, green: 0.78, blue: 0.68).opacity(0.4)
        case 3: return Color(red: 0.78, green: 0.78, blue: 0.72).opacity(0.5)
        case 4: return Color(red: 0.70, green: 0.82, blue: 0.75).opacity(0.4) // green tint glass
        default: return Color(red: 0.90, green: 0.94, blue: 0.96).opacity(0.55) // clear glass
        }
    }

    private var stepLabel: String {
        switch step {
        case 1: return "Empty crucible — ready to receive ingredients."
        case 2: return "60% silica sand — glass-former, backbone of the mix."
        case 3: return "15% natron — flux, lowers melting temperature."
        case 4: return "10% lime — stabilizer, makes glass durable."
        case 5: return "15% cullet — recycled glass, speeds the melt."
        default: return "Fired at 1,100 °C with manganese — clear Roman glass."
        }
    }

    var body: some View {
        IVTeachingContainer(
            title: "Roman Glass Recipe",
            color: color,
            totalSteps: 6,
            step: $step,
            stepLabel: stepLabel,
            height: height
        ) {
            VStack(spacing: 10) {
                FormulaText(
                    text: step >= 6 ? "1,100°C → clear Roman glass" : "60% Silica + 15% Natron + 10% Lime + 15% Cullet",
                    highlighted: step >= 6,
                )
                .padding(.top, 4)

                // Crucible
                RoundedRectangle(cornerRadius: 8)
                    .fill(crucibleColor)
                    .frame(width: 100, height: 70)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(IVMaterialColors.stoneGray, lineWidth: 1.5)
                    )
                    .animation(.easeInOut(duration: 0.3), value: ingredientsAdded)

                // Ingredient badges — the NEXT one highlighted, added ones dimmed done
                HStack(spacing: 8) {
                    ForEach(0..<4, id: \.self) { i in
                        let isNext = i == ingredientsAdded && step < 6
                        let isDone = i < ingredientsAdded
                        VStack(spacing: 1) {
                            Text(ingredients[i].pct).font(RenaissanceFont.ivFormula)
                            Text(ingredients[i].name).font(RenaissanceFont.ivBody)
                        }
                        .frame(width: 60, height: 40)
                        .background(isDone ? IVMaterialColors.stoneGray.opacity(0.1) : ingredients[i].color.opacity(0.25))
                        .cornerRadius(4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(isNext ? color : IVMaterialColors.stoneGray.opacity(0.2), lineWidth: isNext ? 2 : 0.5)
                        )
                        .foregroundStyle(isDone ? IVMaterialColors.sepiaInk.opacity(0.35) : IVMaterialColors.sepiaInk)
                        .scaleEffect(isDone ? 0.95 : 1.0)
                        .animation(.spring(response: 0.3), value: ingredientsAdded)
                    }
                }

                if step >= 6 {
                    Text("Manganese removes the green tint")
                        .font(.custom("EBGaramond-Italic", size: 14))
                        .foregroundStyle(RenaissanceColors.sageGreen)
                        .transition(.opacity)
                }

                Spacer(minLength: 0)
            }
        }
    }
}

// MARK: - 12. Venturi Effect — Narrow the Chamber

private struct VenturiEffectVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    @State private var narrowing: CGFloat = 0.5 // 0=wide, 1=narrow

    private var airSpeed: Int { Int(10 + narrowing * 40) }
    private var isOptimal: Bool { narrowing > 0.6 && narrowing < 0.85 }

    private var label: String {
        switch step {
        case 1: return "A vaulted chamber that narrows = air accelerates = hotter fire."
        case 2: return "Drag to narrow the chamber — watch air speed increase."
        default: return "Temperature controlled by air grate, not just fuel."
        }
    }

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3,
                         step: $step, stepLabel: label, height: height) {
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let cx = w * 0.5
                let chamberH = h * 0.35
                let wideW = w * 0.6
                let narrowW = wideW * (1.0 - narrowing * 0.6)

                ZStack {
                    // Chamber walls (trapezoid shape)
                    Path { p in
                        p.move(to: CGPoint(x: cx - wideW * 0.5, y: h * 0.25))
                        p.addLine(to: CGPoint(x: cx - narrowW * 0.5, y: h * 0.25 + chamberH))
                        p.addLine(to: CGPoint(x: cx + narrowW * 0.5, y: h * 0.25 + chamberH))
                        p.addLine(to: CGPoint(x: cx + wideW * 0.5, y: h * 0.25))
                        p.closeSubpath()
                    }
                    .fill(IVMaterialColors.stoneGray.opacity(0.15))

                    Path { p in
                        p.move(to: CGPoint(x: cx - wideW * 0.5, y: h * 0.25))
                        p.addLine(to: CGPoint(x: cx - narrowW * 0.5, y: h * 0.25 + chamberH))
                        p.addLine(to: CGPoint(x: cx + narrowW * 0.5, y: h * 0.25 + chamberH))
                        p.addLine(to: CGPoint(x: cx + wideW * 0.5, y: h * 0.25))
                        p.closeSubpath()
                    }
                    .stroke(IVMaterialColors.stoneGray, lineWidth: 2)

                    // Air flow arrows (speed scales with narrowing)
                    let arrowCount = Int(2 + narrowing * 4)
                    ForEach(0..<arrowCount, id: \.self) { i in
                        let t = CGFloat(i + 1) / CGFloat(arrowCount + 1)
                        let arrowY = h * 0.25 + chamberH * t
                        let localW = wideW + (narrowW - wideW) * t

                        Image(systemName: "arrow.right")
                            .font(.system(size: CGFloat(13 + narrowing * 6)))
                            .foregroundStyle(isOptimal ? IVMaterialColors.hotRed.opacity(0.5) : warmOrange.opacity(0.4))
                            .position(x: cx, y: arrowY)
                    }

                    // Flame at narrow end
                    if narrowing > 0.3 {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 13 + narrowing * 12))
                            .foregroundStyle(IVMaterialColors.hotRed.opacity(0.4 + narrowing * 0.4))
                            .position(x: cx, y: h * 0.25 + chamberH + 15)
                    }

                    // Air speed indicator
                    Text("\(airSpeed) m/s")
                        .font(RenaissanceFont.ivFormula)
                        .foregroundStyle(isOptimal ? RenaissanceColors.sageGreen : IVMaterialColors.sepiaInk)
                        .position(x: cx, y: h * 0.15)

                    // Slider
                    if step >= 2 {
                        Slider(value: $narrowing, in: 0.2...0.9)
                            .tint(isOptimal ? RenaissanceColors.sageGreen : color)
                            .frame(width: w * 0.5)
                            .position(x: cx, y: h * 0.78)
                            .onChange(of: narrowing) { _, _ in
                                if isOptimal { withAnimation { step = 3 } }
                            }

                        HStack {
                            Text("Wide").font(RenaissanceFont.ivBody)
                            Spacer()
                            Text("Narrow").font(RenaissanceFont.ivBody)
                        }
                        .foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.4))
                        .frame(width: w * 0.5)
                        .position(x: cx, y: h * 0.84)
                    }

                    if step >= 3 {
                        FormulaText(text: "Narrow = fast air = hotter fire", highlighted: true)
                            .position(x: cx, y: h * 0.92)
                            .transition(.opacity)
                    }
                }
            }
        }
    }
}

// MARK: - 13. Amphora — Build Layer by Layer

private struct AmphoraVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    @State private var layersAdded: Int = 0

    private let parts: [(name: String, desc: String)] = [
        ("Clay vessel", "Shaped and fired"),
        ("Pine pitch lining", "Waterproof coating"),
        ("Wax-sealed cork", "Airtight seal"),
    ]

    private var label: String {
        switch step {
        case 1: return "Roman storage: oils, perfumes, cleaning supplies."
        case 2:
            if layersAdded < 3 { return "Tap to add: \(parts[layersAdded].name)." }
            return "Three layers — sealed, waterproof, airtight."
        default: return "Proper storage saves lives — especially for chemicals."
        }
    }

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3,
                         step: $step, stepLabel: label, height: height) {
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let cx = w * 0.5
                let ampW: CGFloat = 50
                let ampH: CGFloat = h * 0.45

                ZStack {
                    // Amphora shape (simplified)
                    Path { p in
                        let topY = h * 0.2
                        let midY = h * 0.35
                        let bottomY = h * 0.6

                        // Neck
                        p.move(to: CGPoint(x: cx - 8, y: topY))
                        p.addLine(to: CGPoint(x: cx - 8, y: topY + 15))
                        // Shoulder
                        p.addQuadCurve(to: CGPoint(x: cx - ampW * 0.5, y: midY),
                                      control: CGPoint(x: cx - ampW * 0.5, y: topY + 15))
                        // Body
                        p.addQuadCurve(to: CGPoint(x: cx, y: bottomY + 10),
                                      control: CGPoint(x: cx - ampW * 0.5, y: bottomY))
                        // Bottom half (mirror)
                        p.addQuadCurve(to: CGPoint(x: cx + ampW * 0.5, y: midY),
                                      control: CGPoint(x: cx + ampW * 0.5, y: bottomY))
                        p.addQuadCurve(to: CGPoint(x: cx + 8, y: topY + 15),
                                      control: CGPoint(x: cx + ampW * 0.5, y: topY + 15))
                        p.addLine(to: CGPoint(x: cx + 8, y: topY))
                    }
                    .fill(layersAdded >= 1 ? RenaissanceColors.terracotta.opacity(0.3) : IVMaterialColors.stoneGray.opacity(0.15))

                    Path { p in
                        let topY = h * 0.2
                        let midY = h * 0.35
                        let bottomY = h * 0.6
                        p.move(to: CGPoint(x: cx - 8, y: topY))
                        p.addLine(to: CGPoint(x: cx - 8, y: topY + 15))
                        p.addQuadCurve(to: CGPoint(x: cx - ampW * 0.5, y: midY),
                                      control: CGPoint(x: cx - ampW * 0.5, y: topY + 15))
                        p.addQuadCurve(to: CGPoint(x: cx, y: bottomY + 10),
                                      control: CGPoint(x: cx - ampW * 0.5, y: bottomY))
                        p.addQuadCurve(to: CGPoint(x: cx + ampW * 0.5, y: midY),
                                      control: CGPoint(x: cx + ampW * 0.5, y: bottomY))
                        p.addQuadCurve(to: CGPoint(x: cx + 8, y: topY + 15),
                                      control: CGPoint(x: cx + ampW * 0.5, y: topY + 15))
                        p.addLine(to: CGPoint(x: cx + 8, y: topY))
                    }
                    .stroke(layersAdded >= 1 ? RenaissanceColors.terracotta : IVMaterialColors.stoneGray, lineWidth: 1.5)

                    // Pine pitch lining (inner glow)
                    if layersAdded >= 2 {
                        Ellipse()
                            .fill(RenaissanceColors.warmBrown.opacity(0.2))
                            .frame(width: ampW - 12, height: h * 0.2)
                            .position(x: cx, y: h * 0.4)
                            .transition(.opacity)
                    }

                    // Cork stopper
                    if layersAdded >= 3 {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(RenaissanceColors.warmBrown.opacity(0.5))
                            .frame(width: 18, height: 10)
                            .position(x: cx, y: h * 0.195)
                            .transition(.scale)

                        // Wax seal
                        Circle()
                            .fill(RenaissanceColors.errorRed.opacity(0.4))
                            .frame(width: 12, height: 12)
                            .position(x: cx, y: h * 0.185)
                    }

                    // Part labels
                    ForEach(0..<layersAdded, id: \.self) { i in
                        HStack(spacing: 4) {
                            Circle().fill(RenaissanceColors.sageGreen).frame(width: 6, height: 6)
                            Text(parts[i].name).font(RenaissanceFont.ivBody)
                        }
                        .foregroundStyle(IVMaterialColors.sepiaInk)
                        .position(x: cx + ampW * 0.5 + 40, y: h * 0.25 + CGFloat(i) * 22)
                        .transition(.opacity)
                    }

                    // Build button
                    if step >= 2 && layersAdded < 3 {
                        Button {
                            withAnimation(.spring(response: 0.3)) { layersAdded += 1 }
                            SoundManager.shared.play(.tapSoft)
                            if layersAdded >= 3 {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    withAnimation { step = 3 }
                                }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "plus.circle").font(.system(size: 13))
                                Text("Add \(parts[layersAdded].name)").font(RenaissanceFont.ivLabel)
                            }
                            .foregroundStyle(color)
                            .padding(.horizontal, 12).padding(.vertical, 6)
                            .background(color.opacity(0.1)).cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                        .position(x: cx, y: h * 0.78)
                    }

                    if step >= 3 {
                        FormulaText(text: "Sealed, waterproof, airtight", highlighted: true)
                            .position(x: cx, y: h * 0.85)
                            .transition(.opacity)
                    }
                }
            }
        }
    }
}
