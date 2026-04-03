import SwiftUI

/// Interactive science visuals for Colosseum knowledge cards
struct ColosseumInteractiveVisuals {

    @ViewBuilder
    static func view(for visual: CardVisual, color: Color, height: CGFloat = 275) -> some View {
        let h = height
        Group {
            switch visual.title {
            case let t where t.contains("76 Exits"):
                CrowdFlowVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Drained Lake"):
                DrainFoundationVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Four Orders") || t.contains("Classical Orders"):
                ColumnOrdersVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Acoustic Bowl"):
                AcousticBowlVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Hypogeum"):
                HypogeumElevatorVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Travertine"):
                TravertineQuarryVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Iron Clamps"):
                IronClampVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Silk") || t.contains("Retractable"):
                VelariumCanvasVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Foundation Curing") || t.contains("Hydration"):
                CuringTimeLapseVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Pozzolanic Vaults") || t.contains("Graded Concrete"):
                GradedConcreteVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Marble Polishing"):
                MarblePolishVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Seating Math"):
                SeatingMathVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Velarium Tension") || t.contains("Sartiame"):
                VelariumTensionVisual(visual: visual, color: color, height: h)
            default:
                EmptyView()
            }
        }
    }

    static func hasInteractiveVisual(for visual: CardVisual) -> Bool {
        let t = visual.title
        return t.contains("76 Exits") || t.contains("Drained Lake") ||
               t.contains("Four Orders") || t.contains("Classical Orders") ||
               t.contains("Acoustic Bowl") || t.contains("Hypogeum") ||
               t.contains("Travertine") || t.contains("Iron Clamps") ||
               t.contains("Silk") || t.contains("Retractable") ||
               t.contains("Foundation Curing") || t.contains("Hydration") ||
               t.contains("Pozzolanic Vaults") || t.contains("Graded Concrete") ||
               t.contains("Marble Polishing") || t.contains("Seating Math") ||
               t.contains("Velarium Tension") || t.contains("Sartiame")
    }
}

// MARK: - Local Aliases

private let gridColor = ivGridColor
private let sepiaInk = ivSepiaInk
private let waterBlue = ivWaterBlue
private let dimColor = ivDimColor
private let stoneGray = Color(red: 0.65, green: 0.63, blue: 0.60)
private let travertineBeige = Color(red: 0.82, green: 0.76, blue: 0.66)
private let ironDark = Color(red: 0.35, green: 0.33, blue: 0.32)
private let leadSilver = Color(red: 0.72, green: 0.72, blue: 0.70)
private let marbleWhite = Color(red: 0.92, green: 0.90, blue: 0.88)

private typealias TeachingContainer = IVTeachingContainer
private typealias DimLabel = IVDimLabel
private typealias FormulaText = IVFormulaText
private typealias DimLine = IVDimLine

// MARK: - 1. Crowd Flow — Tap Exits

private struct CrowdFlowVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    @State private var openedExits: Set<Int> = []
    @State private var crowdProgress: CGFloat = 0

    private let exitCount = 8

    private var label: String {
        switch step {
        case 1: return "50,000 spectators — and 76 exits to get them out."
        case 2:
            if openedExits.count < exitCount { return "Tap each exit to open it. Watch the crowd flow." }
            return "All exits open — the arena empties in 15 minutes."
        default: return "Romans invented crowd management 2,000 years before fire codes."
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
                let rx = w * 0.35  // ellipse X radius
                let ry = h * 0.32  // ellipse Y radius

                ZStack {
                    // Arena ellipse (fill = crowd density)
                    Ellipse()
                        .fill(color.opacity(0.08 * (1.0 - crowdProgress)))
                        .frame(width: rx * 2, height: ry * 2)
                        .position(x: cx, y: cy)

                    Ellipse()
                        .strokeBorder(stoneGray, lineWidth: 2)
                        .frame(width: rx * 2, height: ry * 2)
                        .position(x: cx, y: cy)

                    // Inner arena floor
                    Ellipse()
                        .strokeBorder(stoneGray.opacity(0.3), lineWidth: 1)
                        .frame(width: rx * 1.2, height: ry * 1.2)
                        .position(x: cx, y: cy)

                    // Exit gates around the ellipse
                    if step >= 2 {
                        ForEach(0..<exitCount, id: \.self) { i in
                            let angle = (CGFloat(i) / CGFloat(exitCount)) * .pi * 2 - .pi / 2
                            let gateX = cx + rx * cos(angle)
                            let gateY = cy + ry * sin(angle)
                            let opened = openedExits.contains(i)

                            // Gate marker
                            RoundedRectangle(cornerRadius: 2)
                                .fill(opened ? RenaissanceColors.sageGreen : stoneGray.opacity(0.3))
                                .frame(width: 16, height: 10)
                                .rotationEffect(.radians(Double(angle) + .pi / 2))
                                .position(x: gateX, y: gateY)
                                .onTapGesture {
                                    guard !opened else { return }
                                    withAnimation(.spring(response: 0.3)) { openedExits.insert(i) }
                                    SoundManager.shared.play(.tapSoft)
                                    if openedExits.count == exitCount {
                                        withAnimation(.easeInOut(duration: 1.5)) { crowdProgress = 1.0 }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                                            withAnimation { step = 3 }
                                        }
                                    }
                                }

                            // Flow arrow when opened
                            if opened {
                                let arrowX = cx + (rx + 18) * cos(angle)
                                let arrowY = cy + (ry + 18) * sin(angle)
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 13))
                                    .foregroundStyle(RenaissanceColors.sageGreen)
                                    .rotationEffect(.radians(Double(angle)))
                                    .position(x: arrowX, y: arrowY)
                                    .transition(.scale)
                            }
                        }
                    }

                    // Crowd counter
                    VStack(spacing: 2) {
                        Text("\(Int(50000 * (1.0 - crowdProgress)))")
                            .font(.custom("EBGaramond-Bold", size: 16))
                            .monospacedDigit()
                            .foregroundStyle(sepiaInk)
                        Text("inside")
                            .font(.custom("EBGaramond-Regular", size: 15))
                            .foregroundStyle(sepiaInk.opacity(0.5))
                    }
                    .position(x: cx, y: cy)

                    // Final formula
                    if step >= 3 {
                        FormulaText(text: "76 exits × 15 minutes = zero crushes", highlighted: true, fontSize: 15)
                            .position(x: cx, y: h * 0.88)
                            .transition(.opacity)
                    }
                }
            }
        }
    }
}

// MARK: - 2. Drain Foundation — Water Recedes + Piles

private struct DrainFoundationVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    @State private var waterLevel: CGFloat = 1.0
    @State private var pilesVisible = false
    @State private var concreteVisible = false

    private var label: String {
        switch step {
        case 1: return "Nero's pleasure lake — 6 hectares of water."
        case 2: return "Tap to drain. The foundation goes 13 meters deep."
        case 3: return "Oak piles hammered into clay, then a massive concrete raft."
        default: return "The foundation cost more than the building above it."
        }
    }

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 4,
                         step: $step, stepLabel: label, height: height) {
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let cx = w * 0.5
                let groundY = h * 0.35

                ZStack {
                    // Ground level line
                    Path { p in
                        p.move(to: CGPoint(x: w * 0.1, y: groundY))
                        p.addLine(to: CGPoint(x: w * 0.9, y: groundY))
                    }
                    .stroke(Color.brown.opacity(0.4), lineWidth: 1.5)

                    // Earth layers below ground
                    Rectangle()
                        .fill(Color.brown.opacity(0.1))
                        .frame(width: w * 0.6, height: h * 0.5)
                        .position(x: cx, y: groundY + h * 0.25)

                    // Water (drains on step 2)
                    Rectangle()
                        .fill(waterBlue.opacity(0.3 * waterLevel))
                        .frame(width: w * 0.6, height: h * 0.5 * waterLevel)
                        .position(x: cx, y: groundY + h * 0.25 * waterLevel)

                    // Oak piles (step 3)
                    if pilesVisible {
                        ForEach(0..<5, id: \.self) { i in
                            let px = w * 0.25 + CGFloat(i) * w * 0.12
                            Rectangle()
                                .fill(Color.brown.opacity(0.6))
                                .frame(width: 4, height: h * 0.3)
                                .position(x: px, y: groundY + h * 0.2)
                        }
                        DimLabel(text: "Oak piles", fontSize: 15)
                            .position(x: w * 0.82, y: groundY + h * 0.15)
                    }

                    // Concrete raft (step 3)
                    if concreteVisible {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(stoneGray.opacity(0.4))
                            .frame(width: w * 0.55, height: h * 0.08)
                            .position(x: cx, y: groundY + h * 0.06)

                        DimLabel(text: "13m concrete raft", fontSize: 15)
                            .position(x: w * 0.82, y: groundY + h * 0.06)
                    }

                    // Drain button (step 2)
                    if step >= 2 && waterLevel > 0.1 {
                        Button {
                            withAnimation(.easeInOut(duration: 1.5)) { waterLevel = 0 }
                            SoundManager.shared.play(.tapSoft)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                                withAnimation(.spring(response: 0.4)) {
                                    pilesVisible = true
                                    concreteVisible = true
                                }
                                withAnimation { step = 3 }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.down.to.line").font(.system(size: 13))
                                Text("Drain the Lake").font(.custom("EBGaramond-SemiBold", size: 15))
                            }
                            .foregroundStyle(waterBlue)
                            .padding(.horizontal, 12).padding(.vertical, 6)
                            .background(waterBlue.opacity(0.1))
                            .cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                        .position(x: cx, y: h * 0.12)
                    }

                    // Dimension
                    if step >= 3 {
                        DimLine(from: CGPoint(x: w * 0.18, y: groundY),
                                to: CGPoint(x: w * 0.18, y: groundY + h * 0.38))
                            .stroke(dimColor, lineWidth: 0.8)
                        DimLabel(text: "13 m", fontSize: 15)
                            .position(x: w * 0.12, y: groundY + h * 0.19)
                    }

                    if step >= 4 {
                        FormulaText(text: "Foundation > Building cost", highlighted: true, fontSize: 15)
                            .position(x: cx, y: h * 0.88)
                            .transition(.opacity)
                    }
                }
            }
        }
    }
}

// MARK: - 3. Four Classical Orders — Stack Bottom to Top

private struct ColumnOrdersVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    @State private var placedOrders: [Int] = [] // indices placed in order

    private let orders = ["Doric", "Ionic", "Corinthian", "Composite"]
    private let orderColors: [Color] = [
        Color(red: 0.70, green: 0.60, blue: 0.50), // Doric — sturdy brown
        Color(red: 0.75, green: 0.68, blue: 0.58), // Ionic — warm
        Color(red: 0.80, green: 0.75, blue: 0.65), // Corinthian — lighter
        Color(red: 0.85, green: 0.82, blue: 0.75), // Composite — lightest
    ]

    private var label: String {
        switch step {
        case 1: return "Four stories, four column styles — heaviest at bottom."
        case 2:
            if placedOrders.count < 4 {
                let next = orders[placedOrders.count]
                return "Tap \(next) to place level \(placedOrders.count + 1)."
            }
            return "Heavy Doric at bottom, light Composite at top."
        default: return "Architecture is visual physics — heavier at the bottom, lighter at the top."
        }
    }

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3,
                         step: $step, stepLabel: label, height: height) {
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let cx = w * 0.5
                let floorH = h * 0.15
                let baseY = h * 0.78

                ZStack {
                    // Building frame (4 floors outline)
                    ForEach(0..<4, id: \.self) { i in
                        let y = baseY - CGFloat(i) * floorH
                        Rectangle()
                            .strokeBorder(stoneGray.opacity(0.2), lineWidth: 0.5)
                            .frame(width: w * 0.5, height: floorH)
                            .position(x: cx, y: y - floorH * 0.5)

                        // Floor number
                        Text("\(i + 1)")
                            .font(.custom("EBGaramond-Regular", size: 15))
                            .foregroundStyle(sepiaInk.opacity(0.3))
                            .position(x: cx - w * 0.3, y: y - floorH * 0.5)
                    }

                    // Placed order fills
                    ForEach(0..<placedOrders.count, id: \.self) { i in
                        let y = baseY - CGFloat(i) * floorH
                        let orderIdx = placedOrders[i]

                        RoundedRectangle(cornerRadius: 2)
                            .fill(orderColors[orderIdx].opacity(0.4))
                            .frame(width: w * 0.48, height: floorH - 2)
                            .position(x: cx, y: y - floorH * 0.5)

                        // Column silhouettes
                        HStack(spacing: w * 0.08) {
                            ForEach(0..<3, id: \.self) { _ in
                                RoundedRectangle(cornerRadius: 1)
                                    .fill(orderColors[orderIdx])
                                    .frame(width: 6, height: floorH - 8)
                            }
                        }
                        .position(x: cx, y: y - floorH * 0.5)

                        // Order label
                        Text(orders[orderIdx])
                            .font(.custom("Cinzel-Bold", size: 16))
                            .foregroundStyle(sepiaInk.opacity(0.6))
                            .position(x: cx + w * 0.32, y: y - floorH * 0.5)
                    }

                    // Tappable order buttons (step 2)
                    if step >= 2 && placedOrders.count < 4 {
                        HStack(spacing: 8) {
                            ForEach(0..<4, id: \.self) { i in
                                let isPlaced = placedOrders.contains(i)
                                let isNext = i == placedOrders.count

                                Button {
                                    guard isNext else { return }
                                    withAnimation(.spring(response: 0.3)) { placedOrders.append(i) }
                                    SoundManager.shared.play(.tapSoft)
                                    if placedOrders.count == 4 {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            withAnimation { step = 3 }
                                        }
                                    }
                                } label: {
                                    Text(orders[i])
                                        .font(.custom("EBGaramond-SemiBold", size: 15))
                                        .padding(.horizontal, 8).padding(.vertical, 4)
                                        .background(isPlaced ? stoneGray.opacity(0.1) : (isNext ? color.opacity(0.15) : stoneGray.opacity(0.05)))
                                        .cornerRadius(4)
                                        .overlay(RoundedRectangle(cornerRadius: 4).stroke(isNext ? color : stoneGray.opacity(0.2), lineWidth: isNext ? 2 : 0.5))
                                        .foregroundStyle(isPlaced ? sepiaInk.opacity(0.3) : sepiaInk)
                                }
                                .buttonStyle(.plain)
                                .disabled(isPlaced || !isNext)
                            }
                        }
                        .position(x: cx, y: h * 0.08)
                    }

                    if step >= 3 {
                        FormulaText(text: "Heavy → Light = Visual stability", highlighted: true, fontSize: 15)
                            .position(x: cx, y: h * 0.08)
                            .transition(.opacity)
                    }
                }
            }
        }
    }
}

// MARK: - 4. Acoustic Bowl — Slider Adjusts Rake

private struct AcousticBowlVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    @State private var rakeAngle: CGFloat = 0.5 // 0-1 maps to 20-50 degrees

    private var angleDeg: Int { Int(20 + rakeAngle * 30) }
    private var isOptimal: Bool { angleDeg >= 34 && angleDeg <= 40 }

    private var label: String {
        switch step {
        case 1: return "The elliptical bowl focuses sound — 50,000 could hear the announcer."
        case 2: return "Drag to adjust the seating rake angle."
        default: return "37° — the sweet spot where architecture becomes an amplifier."
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
                let bowlW = w * 0.7
                let depth = h * 0.3 * rakeAngle

                ZStack {
                    // Bowl cross-section (quadratic curve)
                    Path { p in
                        p.move(to: CGPoint(x: cx - bowlW * 0.5, y: cy - depth * 0.3))
                        p.addQuadCurve(
                            to: CGPoint(x: cx + bowlW * 0.5, y: cy - depth * 0.3),
                            control: CGPoint(x: cx, y: cy + depth)
                        )
                    }
                    .stroke(stoneGray, lineWidth: 2.5)

                    // Seating rows (lines along the bowl)
                    ForEach(0..<5, id: \.self) { row in
                        let t = CGFloat(row + 1) / 6.0
                        let rowW = bowlW * (0.4 + t * 0.6)
                        let rowY = cy + depth * (1.0 - t * 2)

                        Path { p in
                            p.move(to: CGPoint(x: cx - rowW * 0.5, y: rowY))
                            p.addLine(to: CGPoint(x: cx + rowW * 0.5, y: rowY))
                        }
                        .stroke(stoneGray.opacity(0.3), lineWidth: 0.8)
                    }

                    // Sound waves from center
                    if step >= 2 {
                        ForEach(0..<3, id: \.self) { i in
                            let radius = CGFloat(i + 1) * bowlW * 0.12
                            Circle()
                                .strokeBorder(
                                    isOptimal ? RenaissanceColors.sageGreen.opacity(0.4 - CGFloat(i) * 0.1) :
                                        color.opacity(0.3 - CGFloat(i) * 0.08),
                                    lineWidth: 1
                                )
                                .frame(width: radius * 2, height: radius * 2)
                                .position(x: cx, y: cy + depth * 0.4)
                        }
                    }

                    // Angle label
                    Text("\(angleDeg)°")
                        .font(.custom("EBGaramond-Bold", size: 16))
                        .foregroundStyle(isOptimal ? RenaissanceColors.sageGreen : sepiaInk)
                        .position(x: w * 0.85, y: cy)

                    // Slider (step 2)
                    if step >= 2 {
                        VStack(spacing: 2) {
                            Slider(value: $rakeAngle, in: 0...1)
                                .tint(isOptimal ? RenaissanceColors.sageGreen : color)
                                .frame(width: w * 0.5)
                            HStack {
                                Text("20°").font(.custom("EBGaramond-Regular", size: 15))
                                Spacer()
                                Text("37°").font(.custom("EBGaramond-Regular", size: 15)).foregroundStyle(RenaissanceColors.sageGreen)
                                Spacer()
                                Text("50°").font(.custom("EBGaramond-Regular", size: 15))
                            }
                            .foregroundStyle(sepiaInk.opacity(0.4))
                            .frame(width: w * 0.5)
                        }
                        .position(x: cx, y: h * 0.85)
                    }

                    if step >= 3 {
                        FormulaText(text: "37° = optimal sightline + sound focus", highlighted: true, fontSize: 15)
                            .position(x: cx, y: h * 0.12)
                            .transition(.opacity)
                    }
                }
            }
        }
    }
}

// MARK: - 5. Hypogeum Elevator — Drag Platform Up

private struct HypogeumElevatorVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    @State private var liftProgress: CGFloat = 0 // 0=underground, 1=arena level

    private var label: String {
        switch step {
        case 1: return "Beneath the arena floor — a world of tunnels and machines."
        case 2: return "Drag the platform up to reveal what's below."
        default: return "80 elevators powered the greatest show in Rome."
        }
    }

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3,
                         step: $step, stepLabel: label, height: height) {
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let cx = w * 0.5
                let arenaY = h * 0.25
                let bottomY = h * 0.75
                let shaftW = w * 0.25

                ZStack {
                    // Arena floor level
                    Path { p in
                        p.move(to: CGPoint(x: w * 0.15, y: arenaY))
                        p.addLine(to: CGPoint(x: w * 0.85, y: arenaY))
                    }
                    .stroke(stoneGray, lineWidth: 2)

                    Text("Arena Floor")
                        .font(.custom("EBGaramond-Regular", size: 15))
                        .foregroundStyle(sepiaInk.opacity(0.4))
                        .position(x: w * 0.82, y: arenaY - 8)

                    // Elevator shaft
                    Rectangle()
                        .strokeBorder(stoneGray.opacity(0.4), lineWidth: 1)
                        .frame(width: shaftW, height: bottomY - arenaY)
                        .position(x: cx, y: (arenaY + bottomY) / 2)

                    // Underground levels
                    ForEach(0..<2, id: \.self) { level in
                        let ly = arenaY + CGFloat(level + 1) * (bottomY - arenaY) / 3
                        Path { p in
                            p.move(to: CGPoint(x: cx - shaftW * 0.8, y: ly))
                            p.addLine(to: CGPoint(x: cx + shaftW * 0.8, y: ly))
                        }
                        .stroke(stoneGray.opacity(0.2), style: StrokeStyle(lineWidth: 0.5, dash: [3, 3]))

                        Text(level == 0 ? "Animal cages" : "Storage tunnels")
                            .font(.custom("EBGaramond-Regular", size: 15))
                            .foregroundStyle(sepiaInk.opacity(0.3))
                            .position(x: cx + shaftW * 0.8 + 30, y: ly)
                    }

                    // Ropes
                    Path { p in
                        let platformY = arenaY + (bottomY - arenaY) * (1.0 - liftProgress)
                        p.move(to: CGPoint(x: cx - shaftW * 0.3, y: arenaY - 10))
                        p.addLine(to: CGPoint(x: cx - shaftW * 0.3, y: platformY))
                        p.move(to: CGPoint(x: cx + shaftW * 0.3, y: arenaY - 10))
                        p.addLine(to: CGPoint(x: cx + shaftW * 0.3, y: platformY))
                    }
                    .stroke(Color.brown.opacity(0.4), lineWidth: 1)

                    // Platform (draggable)
                    let platformY = arenaY + (bottomY - arenaY) * (1.0 - liftProgress)

                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.brown.opacity(0.5))
                        .frame(width: shaftW - 8, height: 10)
                        .position(x: cx, y: platformY)
                        .gesture(
                            step >= 2 ? DragGesture()
                                .onChanged { value in
                                    let normalizedY = (value.location.y - arenaY) / (bottomY - arenaY)
                                    liftProgress = max(0, min(1, 1.0 - normalizedY))
                                }
                                .onEnded { _ in
                                    if liftProgress > 0.85 {
                                        withAnimation(.spring(response: 0.3)) { liftProgress = 1.0 }
                                        withAnimation { step = 3 }
                                        SoundManager.shared.play(.correctChime)
                                    }
                                } : nil
                        )

                    // Trap door opening
                    if liftProgress > 0.8 {
                        Rectangle()
                            .fill(Color.brown.opacity(0.3))
                            .frame(width: shaftW - 4, height: 4)
                            .position(x: cx, y: arenaY)
                            .opacity(Double(liftProgress - 0.8) * 5)
                    }

                    // Animal on platform
                    if liftProgress > 0.3 {
                        Text("🦁")
                            .font(.system(size: 20))
                            .position(x: cx, y: platformY - 18)
                            .opacity(min(1, Double(liftProgress - 0.3) * 2))
                    }

                    if step >= 3 {
                        FormulaText(text: "80 elevators — invisible infrastructure", highlighted: true, fontSize: 15)
                            .position(x: cx, y: h * 0.92)
                            .transition(.opacity)
                    }
                }
            }
        }
    }
}

// MARK: - 6. Travertine vs Marble — Crack and Compare

private struct TravertineQuarryVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    @State private var cracked = false

    private var label: String {
        switch step {
        case 1: return "100,000 m³ of stone — quarried 30 km east at Tivoli."
        case 2:
            if !cracked { return "Tap to crack the stone — see why travertine won." }
            return "Air pockets = lighter + clamps grip better."
        default: return "Those holes you see today? Clamp scars — not design."
        }
    }

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3,
                         step: $step, stepLabel: label, height: height) {
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let blockW = w * 0.3
                let blockH = h * 0.35

                ZStack {
                    // Travertine block (left)
                    VStack(spacing: 4) {
                        Text("TRAVERTINE")
                            .font(.custom("Cinzel-Bold", size: 16)).tracking(0.5)
                            .foregroundStyle(sepiaInk.opacity(0.5))

                        ZStack {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(travertineBeige)
                                .frame(width: blockW, height: blockH)

                            // Air pocket holes (visible after crack)
                            if cracked {
                                ForEach(0..<8, id: \.self) { i in
                                    Circle()
                                        .fill(travertineBeige.opacity(0.3))
                                        .frame(width: CGFloat.random(in: 4...10))
                                        .offset(
                                            x: CGFloat.random(in: -blockW * 0.3...blockW * 0.3),
                                            y: CGFloat.random(in: -blockH * 0.3...blockH * 0.3)
                                        )
                                }
                            }
                        }

                        if cracked {
                            VStack(spacing: 1) {
                                Text("30% lighter").font(.custom("EBGaramond-SemiBold", size: 15)).foregroundStyle(RenaissanceColors.sageGreen)
                                Text("Clamps grip holes").font(.custom("EBGaramond-Regular", size: 15)).foregroundStyle(sepiaInk.opacity(0.5))
                            }
                            .transition(.opacity)
                        }
                    }
                    .position(x: w * 0.28, y: h * 0.42)

                    // Marble block (right)
                    VStack(spacing: 4) {
                        Text("MARBLE")
                            .font(.custom("Cinzel-Bold", size: 16)).tracking(0.5)
                            .foregroundStyle(sepiaInk.opacity(0.5))

                        RoundedRectangle(cornerRadius: 4)
                            .fill(marbleWhite)
                            .frame(width: blockW, height: blockH)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .strokeBorder(stoneGray.opacity(0.3), lineWidth: 0.5)
                            )

                        if cracked {
                            VStack(spacing: 1) {
                                Text("Dense, heavy").font(.custom("EBGaramond-SemiBold", size: 15)).foregroundStyle(RenaissanceColors.errorRed.opacity(0.7))
                                Text("Clamps slip off").font(.custom("EBGaramond-Regular", size: 15)).foregroundStyle(sepiaInk.opacity(0.5))
                            }
                            .transition(.opacity)
                        }
                    }
                    .position(x: w * 0.72, y: h * 0.42)

                    // Crack button
                    if step >= 2 && !cracked {
                        Button {
                            withAnimation(.spring(response: 0.3)) { cracked = true }
                            SoundManager.shared.play(.tapSoft)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { withAnimation { step = 3 } }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "hammer.fill").font(.system(size: 13))
                                Text("Crack the Stone").font(.custom("EBGaramond-SemiBold", size: 15))
                            }
                            .foregroundStyle(color)
                            .padding(.horizontal, 12).padding(.vertical, 6)
                            .background(color.opacity(0.1)).cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                        .position(x: w * 0.5, y: h * 0.82)
                    }

                    if step >= 3 {
                        FormulaText(text: "Lighter + grippy = perfect for clamps", highlighted: true, fontSize: 15)
                            .position(x: w * 0.5, y: h * 0.85)
                            .transition(.opacity)
                    }
                }
            }
        }
    }
}

// MARK: - 7. Iron Clamps — Drag Dovetail Between Blocks

private struct IronClampVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    @State private var clampPlaced = false
    @State private var leadPoured = false

    private var label: String {
        switch step {
        case 1: return "300 tons of iron clamps lock the Colosseum together."
        case 2:
            if !clampPlaced { return "Tap to place the clamp between blocks." }
            if !leadPoured { return "Now tap to pour molten lead — anchors the clamp forever." }
            return "Flexes in earthquakes — rigid mortar would crack."
        default: return "Survived 2,000 years of earthquakes — until humans stole the iron."
        }
    }

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3,
                         step: $step, stepLabel: label, height: height) {
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let cx = w * 0.5
                let blockW = w * 0.28
                let blockH = h * 0.3
                let blockY = h * 0.42

                ZStack {
                    // Left stone block
                    RoundedRectangle(cornerRadius: 3)
                        .fill(travertineBeige)
                        .frame(width: blockW, height: blockH)
                        .position(x: cx - blockW * 0.52, y: blockY)

                    // Right stone block
                    RoundedRectangle(cornerRadius: 3)
                        .fill(travertineBeige)
                        .frame(width: blockW, height: blockH)
                        .position(x: cx + blockW * 0.52, y: blockY)

                    // Joint gap
                    Rectangle()
                        .fill(stoneGray.opacity(0.2))
                        .frame(width: 8, height: blockH)
                        .position(x: cx, y: blockY)

                    // Dovetail clamp
                    if clampPlaced {
                        // Clamp shape (trapezoid/dovetail)
                        Path { p in
                            let cw: CGFloat = blockW * 0.6
                            let ch: CGFloat = 12
                            p.move(to: CGPoint(x: cx - cw * 0.5, y: blockY - ch * 0.5))
                            p.addLine(to: CGPoint(x: cx - cw * 0.35, y: blockY + ch * 0.5))
                            p.addLine(to: CGPoint(x: cx + cw * 0.35, y: blockY + ch * 0.5))
                            p.addLine(to: CGPoint(x: cx + cw * 0.5, y: blockY - ch * 0.5))
                            p.closeSubpath()
                        }
                        .fill(ironDark)
                        .transition(.scale)

                        // Dovetail notches
                        ForEach([-1.0, 1.0], id: \.self) { side in
                            Path { p in
                                let nx = cx + side * blockW * 0.22
                                p.addRect(CGRect(x: nx - 4, y: blockY - 3, width: 8, height: 6))
                            }
                            .fill(ironDark.opacity(0.8))
                        }
                    }

                    // Lead anchoring
                    if leadPoured {
                        ForEach([-1.0, 1.0], id: \.self) { side in
                            Circle()
                                .fill(leadSilver)
                                .frame(width: 10, height: 10)
                                .position(x: cx + side * blockW * 0.22, y: blockY)
                        }

                        DimLabel(text: "Molten lead", fontSize: 15)
                            .position(x: cx, y: blockY + blockH * 0.5 + 12)
                    }

                    // Action buttons (step 2)
                    if step >= 2 {
                        if !clampPlaced {
                            Button {
                                withAnimation(.spring(response: 0.3)) { clampPlaced = true }
                                SoundManager.shared.play(.tapSoft)
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "link").font(.system(size: 13))
                                    Text("Place Clamp").font(.custom("EBGaramond-SemiBold", size: 15))
                                }
                                .foregroundStyle(ironDark)
                                .padding(.horizontal, 12).padding(.vertical, 6)
                                .background(ironDark.opacity(0.1)).cornerRadius(6)
                            }
                            .buttonStyle(.plain)
                            .position(x: cx, y: h * 0.82)
                        } else if !leadPoured {
                            Button {
                                withAnimation(.spring(response: 0.3)) { leadPoured = true }
                                SoundManager.shared.play(.tapSoft)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { withAnimation { step = 3 } }
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "flame.fill").font(.system(size: 13))
                                    Text("Pour Lead").font(.custom("EBGaramond-SemiBold", size: 15))
                                }
                                .foregroundStyle(.orange)
                                .padding(.horizontal, 12).padding(.vertical, 6)
                                .background(Color.orange.opacity(0.1)).cornerRadius(6)
                            }
                            .buttonStyle(.plain)
                            .position(x: cx, y: h * 0.82)
                        }
                    }

                    if step >= 3 {
                        FormulaText(text: "Iron flexes — mortar cracks", highlighted: true, fontSize: 15)
                            .position(x: cx, y: h * 0.85)
                            .transition(.opacity)
                    }
                }
            }
        }
    }
}

// MARK: - 8. Velarium Canvas — Extend Awning

private struct VelariumCanvasVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    @State private var canvasExtension: CGFloat = 0 // 0=retracted, 1=fully extended

    private var label: String {
        switch step {
        case 1: return "240 masts around the rim — the world's first retractable roof."
        case 2: return "Drag to extend the canvas toward the center."
        default: return "Operated by 1,000 sailors — the Roman navy's other job."
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
                let rx = w * 0.38
                let ry = h * 0.3

                ZStack {
                    // Arena outline
                    Ellipse()
                        .strokeBorder(stoneGray, lineWidth: 2)
                        .frame(width: rx * 2, height: ry * 2)
                        .position(x: cx, y: cy)

                    // Mast dots around rim
                    ForEach(0..<16, id: \.self) { i in
                        let angle = CGFloat(i) / 16.0 * .pi * 2
                        let mx = cx + rx * cos(angle)
                        let my = cy + ry * sin(angle)
                        Circle()
                            .fill(stoneGray)
                            .frame(width: 4, height: 4)
                            .position(x: mx, y: my)
                    }

                    // Canvas (extends from rim toward center)
                    if canvasExtension > 0.05 {
                        Ellipse()
                            .fill(RenaissanceColors.ochre.opacity(0.15 * canvasExtension))
                            .frame(width: rx * 2, height: ry * 2)
                            .position(x: cx, y: cy)

                        // Inner opening (shrinks as canvas extends)
                        let openRx = rx * (1.0 - canvasExtension * 0.7)
                        let openRy = ry * (1.0 - canvasExtension * 0.7)
                        Ellipse()
                            .fill(RenaissanceColors.parchment)
                            .frame(width: openRx * 2, height: openRy * 2)
                            .position(x: cx, y: cy)

                        Ellipse()
                            .strokeBorder(RenaissanceColors.ochre.opacity(0.4), lineWidth: 1)
                            .frame(width: openRx * 2, height: openRy * 2)
                            .position(x: cx, y: cy)

                        // Rope lines from masts to center
                        ForEach(0..<8, id: \.self) { i in
                            let angle = CGFloat(i) / 8.0 * .pi * 2
                            Path { p in
                                p.move(to: CGPoint(x: cx + rx * cos(angle), y: cy + ry * sin(angle)))
                                p.addLine(to: CGPoint(x: cx + openRx * cos(angle), y: cy + openRy * sin(angle)))
                            }
                            .stroke(Color.brown.opacity(0.3), lineWidth: 0.5)
                        }
                    }

                    // Slider (step 2)
                    if step >= 2 {
                        VStack(spacing: 2) {
                            Slider(value: $canvasExtension, in: 0...1)
                                .tint(RenaissanceColors.ochre)
                                .frame(width: w * 0.5)
                                .onChange(of: canvasExtension) { _, newVal in
                                    if newVal > 0.9 {
                                        withAnimation { step = 3 }
                                        SoundManager.shared.play(.correctChime)
                                    }
                                }
                            HStack {
                                Text("Retracted").font(.custom("EBGaramond-Regular", size: 15))
                                Spacer()
                                Text("Extended").font(.custom("EBGaramond-Regular", size: 15))
                            }
                            .foregroundStyle(sepiaInk.opacity(0.4))
                            .frame(width: w * 0.5)
                        }
                        .position(x: cx, y: h * 0.85)
                    }

                    if step >= 3 {
                        FormulaText(text: "1,000 sailors + 240 masts = shade for 50,000", highlighted: true, fontSize: 15)
                            .position(x: cx, y: h * 0.12)
                            .transition(.opacity)
                    }
                }
            }
        }
    }
}

// MARK: - 9. Curing Time-Lapse — Slider Drives Time

private struct CuringTimeLapseVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    @State private var timeProgress: CGFloat = 0 // 0-1 maps to 0-2 years

    private var years: String { String(format: "%.1f", timeProgress * 2) }
    private var isCured: Bool { timeProgress > 0.9 }

    private var label: String {
        switch step {
        case 1: return "Concrete needs water to cure — 2 years of daily watering."
        case 2: return "Drag to fast-forward time. Watch the crystals grow."
        default: return "The building that drained a lake needed water to set its own foundation."
        }
    }

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3,
                         step: $step, stepLabel: label, height: height) {
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let cx = w * 0.5
                let blockW = w * 0.4
                let blockH = h * 0.35

                ZStack {
                    // Concrete block (changes texture with time)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(stoneGray.opacity(0.3 + timeProgress * 0.5))
                        .frame(width: blockW, height: blockH)
                        .position(x: cx, y: h * 0.38)

                    // Crystal growth dots (appear with time)
                    ForEach(0..<Int(timeProgress * 12), id: \.self) { i in
                        let seed = CGFloat(i * 137 % 100) / 100.0
                        Circle()
                            .fill(Color.white.opacity(0.4))
                            .frame(width: 3 + seed * 4)
                            .position(
                                x: cx + (seed - 0.5) * blockW * 0.7,
                                y: h * 0.38 + (CGFloat(i * 53 % 100) / 100.0 - 0.5) * blockH * 0.7
                            )
                    }

                    // Water drops (if curing)
                    if timeProgress > 0.1 && timeProgress < 0.9 {
                        ForEach(0..<3, id: \.self) { i in
                            Image(systemName: "drop.fill")
                                .font(.system(size: 13))
                                .foregroundStyle(waterBlue.opacity(0.5))
                                .position(
                                    x: cx + CGFloat(i - 1) * blockW * 0.3,
                                    y: h * 0.38 - blockH * 0.5 - 10
                                )
                        }
                    }

                    // Time display
                    Text("\(years) years")
                        .font(.custom("EBGaramond-Bold", size: 16))
                        .foregroundStyle(isCured ? RenaissanceColors.sageGreen : sepiaInk)
                        .position(x: cx, y: h * 0.12)

                    // Slider
                    if step >= 2 {
                        Slider(value: $timeProgress, in: 0...1)
                            .tint(isCured ? RenaissanceColors.sageGreen : waterBlue)
                            .frame(width: w * 0.6)
                            .position(x: cx, y: h * 0.72)
                            .onChange(of: timeProgress) { _, newVal in
                                if newVal > 0.9 { withAnimation { step = 3 } }
                            }
                    }

                    if step >= 3 {
                        FormulaText(text: "Water + Lime → Calcium hydroxide crystals", highlighted: true, fontSize: 15)
                            .position(x: cx, y: h * 0.85)
                            .transition(.opacity)
                    }
                }
            }
        }
    }
}

// MARK: - 10. Graded Concrete — Pour 3 Layers

private struct GradedConcreteVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    @State private var layersPoured: Int = 0

    private let layers = [
        ("Basalt", "Heavy — foundation", Color(red: 0.35, green: 0.33, blue: 0.32)),
        ("Tufa", "Medium — walls", Color(red: 0.60, green: 0.55, blue: 0.48)),
        ("Pumice", "Light — upper vaults", Color(red: 0.80, green: 0.78, blue: 0.72)),
    ]

    private var label: String {
        switch step {
        case 1: return "Same lime binder, three different stones — graded by weight."
        case 2:
            if layersPoured < 3 { return "Tap to pour layer \(layersPoured + 1) — \(layers[layersPoured].0)." }
            return "Heavy at bottom, light on top — structural genius."
        default: return "The Colosseum is more concrete than stone."
        }
    }

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3,
                         step: $step, stepLabel: label, height: height) {
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let cx = w * 0.5
                let vaultW = w * 0.5
                let layerH = h * 0.15
                let baseY = h * 0.7

                ZStack {
                    // Vault outline
                    RoundedRectangle(cornerRadius: 4)
                        .strokeBorder(stoneGray.opacity(0.3), lineWidth: 1)
                        .frame(width: vaultW, height: layerH * 3 + 8)
                        .position(x: cx, y: baseY - layerH * 1.5)

                    // Poured layers
                    ForEach(0..<layersPoured, id: \.self) { i in
                        let y = baseY - CGFloat(i) * layerH
                        RoundedRectangle(cornerRadius: 2)
                            .fill(layers[i].2.opacity(0.6))
                            .frame(width: vaultW - 4, height: layerH - 2)
                            .position(x: cx, y: y - layerH * 0.5)
                            .transition(.move(edge: .top).combined(with: .opacity))

                        // Aggregate dots
                        ForEach(0..<5, id: \.self) { j in
                            Circle()
                                .fill(layers[i].2)
                                .frame(width: CGFloat(6 - i * 2))
                                .position(
                                    x: cx + CGFloat(j * 37 % 100 - 50) / 100.0 * vaultW * 0.4,
                                    y: y - layerH * 0.5 + CGFloat(j * 23 % 30 - 15)
                                )
                        }

                        // Layer label
                        HStack(spacing: 4) {
                            Text(layers[i].0).font(.custom("Cinzel-Bold", size: 16))
                            Text(layers[i].1).font(.custom("EBGaramond-Regular", size: 15)).foregroundStyle(sepiaInk.opacity(0.5))
                        }
                        .foregroundStyle(sepiaInk)
                        .position(x: cx + vaultW * 0.5 + 40, y: y - layerH * 0.5)
                    }

                    // Pour button
                    if step >= 2 && layersPoured < 3 {
                        Button {
                            withAnimation(.spring(response: 0.4)) { layersPoured += 1 }
                            SoundManager.shared.play(.tapSoft)
                            if layersPoured >= 3 {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { withAnimation { step = 3 } }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.down.circle").font(.system(size: 13))
                                Text("Pour \(layers[layersPoured].0)").font(.custom("EBGaramond-SemiBold", size: 15))
                            }
                            .foregroundStyle(layers[layersPoured].2)
                            .padding(.horizontal, 12).padding(.vertical, 6)
                            .background(layers[layersPoured].2.opacity(0.15)).cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                        .position(x: cx, y: h * 0.12)
                    }

                    if step >= 3 {
                        FormulaText(text: "Same binder + graded stone = structural genius", highlighted: true, fontSize: 15)
                            .position(x: cx, y: h * 0.12)
                            .transition(.opacity)
                    }
                }
            }
        }
    }
}

// MARK: - 11. Marble Polish — 3 Grit Stages

private struct MarblePolishVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    @State private var polishStage: Int = 0

    private let stages = [
        ("Coarse Sand", "Rough surface removed", 0.3),
        ("Pumice Powder", "Grain smoothed", 0.6),
        ("Tin Oxide", "Mirror finish", 0.95),
    ]

    private var label: String {
        switch step {
        case 1: return "Three stages of grit turn rough stone into a mirror."
        case 2:
            if polishStage < 3 { return "Tap to apply stage \(polishStage + 1) — \(stages[polishStage].0)." }
            return "Mirror-smooth marble — the Romans' calling card."
        default: return "Perfection is about grit sequence — each stage half the size."
        }
    }

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3,
                         step: $step, stepLabel: label, height: height) {
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let cx = w * 0.5
                let slabW = w * 0.5
                let slabH = h * 0.35

                ZStack {
                    // Marble slab
                    let shininess = polishStage > 0 ? stages[polishStage - 1].2 : 0.0

                    RoundedRectangle(cornerRadius: 4)
                        .fill(marbleWhite.opacity(0.5 + shininess * 0.5))
                        .frame(width: slabW, height: slabH)
                        .overlay {
                            // Surface texture dots (fewer = smoother)
                            let dotCount = max(0, 15 - polishStage * 5)
                            ForEach(0..<dotCount, id: \.self) { i in
                                Circle()
                                    .fill(stoneGray.opacity(0.3))
                                    .frame(width: CGFloat(4 - polishStage))
                                    .offset(
                                        x: CGFloat(i * 47 % 100 - 50) / 100.0 * slabW * 0.8,
                                        y: CGFloat(i * 31 % 100 - 50) / 100.0 * slabH * 0.8
                                    )
                            }

                            // Mirror shine (stage 3)
                            if polishStage >= 3 {
                                LinearGradient(
                                    colors: [.clear, .white.opacity(0.4), .clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                            }
                        }
                        .position(x: cx, y: h * 0.4)

                    // Stage indicators
                    HStack(spacing: 12) {
                        ForEach(0..<3, id: \.self) { i in
                            VStack(spacing: 2) {
                                Circle()
                                    .fill(i < polishStage ? RenaissanceColors.sageGreen : stoneGray.opacity(0.2))
                                    .frame(width: 10, height: 10)
                                Text(stages[i].0)
                                    .font(.custom("EBGaramond-Regular", size: 15))
                                    .foregroundStyle(i < polishStage ? sepiaInk : sepiaInk.opacity(0.3))
                            }
                        }
                    }
                    .position(x: cx, y: h * 0.7)

                    // Polish button
                    if step >= 2 && polishStage < 3 {
                        Button {
                            withAnimation(.spring(response: 0.3)) { polishStage += 1 }
                            SoundManager.shared.play(.tapSoft)
                            if polishStage >= 3 {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { withAnimation { step = 3 } }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "sparkle").font(.system(size: 13))
                                Text("Apply \(stages[polishStage].0)").font(.custom("EBGaramond-SemiBold", size: 15))
                            }
                            .foregroundStyle(color)
                            .padding(.horizontal, 12).padding(.vertical, 6)
                            .background(color.opacity(0.1)).cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                        .position(x: cx, y: h * 0.85)
                    }

                    if step >= 3 {
                        FormulaText(text: "Coarse → Fine → Mirror", highlighted: true, fontSize: 15)
                            .position(x: cx, y: h * 0.85)
                            .transition(.opacity)
                    }
                }
            }
        }
    }
}

// MARK: - 12. Seating Math — Assign Tiers

private struct SeatingMathVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    @State private var assignedTiers: Int = 0

    private let tiers = [
        ("Senators", "Podium", "Front rows", Color(red: 0.85, green: 0.75, blue: 0.50)),
        ("Equites", "Maenianum I", "Knights", Color(red: 0.75, green: 0.65, blue: 0.50)),
        ("Citizens", "Maenianum II", "Common people", Color(red: 0.65, green: 0.58, blue: 0.48)),
        ("Women", "Summum", "Top section", Color(red: 0.55, green: 0.50, blue: 0.44)),
        ("Slaves", "Standing", "No seats", Color(red: 0.48, green: 0.44, blue: 0.40)),
    ]

    private var label: String {
        switch step {
        case 1: return "5 social tiers — the closer to the arena, the higher your rank."
        case 2:
            if assignedTiers < 5 { return "Tap to assign tier \(assignedTiers + 1) — \(tiers[assignedTiers].0)." }
            return "76 rows, 5 tiers — every seat a unique coordinate."
        default: return "50,000 unique solutions — every seat calculated."
        }
    }

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3,
                         step: $step, stepLabel: label, height: height) {
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let cx = w * 0.5
                let bowlW = w * 0.6
                let tierH = h * 0.1

                ZStack {
                    // Bowl cross-section with tier slots
                    ForEach(0..<5, id: \.self) { i in
                        let y = h * 0.25 + CGFloat(i) * tierH
                        let rowW = bowlW * (0.5 + CGFloat(i) * 0.1)

                        // Tier fill
                        if i < assignedTiers {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(tiers[i].3.opacity(0.4))
                                .frame(width: rowW, height: tierH - 3)
                                .position(x: cx, y: y)
                                .transition(.opacity)

                            // Tier label
                            HStack(spacing: 4) {
                                Text(tiers[i].0).font(.custom("Cinzel-Bold", size: 16))
                                Text(tiers[i].1).font(.custom("EBGaramond-Regular", size: 15)).foregroundStyle(sepiaInk.opacity(0.4))
                            }
                            .foregroundStyle(sepiaInk)
                            .position(x: cx, y: y)
                        } else {
                            // Empty slot
                            RoundedRectangle(cornerRadius: 2)
                                .strokeBorder(stoneGray.opacity(0.2), lineWidth: 0.5)
                                .frame(width: rowW, height: tierH - 3)
                                .position(x: cx, y: y)
                        }
                    }

                    // Arena floor at center-bottom
                    Text("Arena")
                        .font(.custom("EBGaramond-Regular", size: 15))
                        .foregroundStyle(sepiaInk.opacity(0.3))
                        .position(x: cx, y: h * 0.16)

                    // Assign button
                    if step >= 2 && assignedTiers < 5 {
                        Button {
                            withAnimation(.spring(response: 0.3)) { assignedTiers += 1 }
                            SoundManager.shared.play(.tapSoft)
                            if assignedTiers >= 5 {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { withAnimation { step = 3 } }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "person.fill").font(.system(size: 13))
                                Text("Seat \(tiers[assignedTiers].0)").font(.custom("EBGaramond-SemiBold", size: 15))
                            }
                            .foregroundStyle(tiers[assignedTiers].3)
                            .padding(.horizontal, 12).padding(.vertical, 6)
                            .background(tiers[assignedTiers].3.opacity(0.15)).cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                        .position(x: cx, y: h * 0.85)
                    }

                    if step >= 3 {
                        FormulaText(text: "Rank = distance from the action", highlighted: true, fontSize: 15)
                            .position(x: cx, y: h * 0.85)
                            .transition(.opacity)
                    }
                }
            }
        }
    }
}

// MARK: - 13. Velarium Tension — Wind Test

private struct VelariumTensionVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    @State private var windSpeed: CGFloat = 0 // 0-1

    private var windKmh: Int { Int(windSpeed * 60) }
    private var isDangerous: Bool { windSpeed > 0.7 }

    private var label: String {
        switch step {
        case 1: return "240 masts, converging ropes — a cone of tension."
        case 2: return "Drag wind speed — watch the canvas billow."
        default: return "A circus tent the size of a football field."
        }
    }

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3,
                         step: $step, stepLabel: label, height: height) {
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let cx = w * 0.5
                let mastH = h * 0.55
                let mastY = h * 0.55
                let billowOffset = windSpeed * w * 0.08

                ZStack {
                    // Left and right masts
                    ForEach([-1.0, 1.0], id: \.self) { side in
                        Rectangle()
                            .fill(Color.brown.opacity(0.5))
                            .frame(width: 4, height: mastH)
                            .position(x: cx + side * w * 0.35, y: mastY)
                    }

                    // Ropes from masts to center ring
                    ForEach(0..<4, id: \.self) { i in
                        let ropeY = mastY - mastH * 0.5 + CGFloat(i) * mastH * 0.25
                        Path { p in
                            p.move(to: CGPoint(x: cx - w * 0.35, y: ropeY))
                            p.addQuadCurve(
                                to: CGPoint(x: cx + w * 0.35, y: ropeY),
                                control: CGPoint(x: cx + billowOffset, y: ropeY + windSpeed * 15)
                            )
                        }
                        .stroke(Color.brown.opacity(0.3), lineWidth: 0.8)
                    }

                    // Canvas fill (billows with wind)
                    Path { p in
                        let topY = mastY - mastH * 0.5
                        let botY = mastY + mastH * 0.2
                        p.move(to: CGPoint(x: cx - w * 0.35, y: topY))
                        p.addQuadCurve(
                            to: CGPoint(x: cx + w * 0.35, y: topY),
                            control: CGPoint(x: cx + billowOffset * 1.5, y: topY + windSpeed * 25)
                        )
                        p.addLine(to: CGPoint(x: cx + w * 0.35, y: botY))
                        p.addQuadCurve(
                            to: CGPoint(x: cx - w * 0.35, y: botY),
                            control: CGPoint(x: cx + billowOffset, y: botY + windSpeed * 10)
                        )
                        p.closeSubpath()
                    }
                    .fill(RenaissanceColors.ochre.opacity(0.12 + windSpeed * 0.08))

                    // Wind indicator
                    HStack(spacing: 4) {
                        Image(systemName: "wind")
                            .font(.system(size: 13))
                        Text("\(windKmh) km/h")
                            .font(.custom("EBGaramond-Bold", size: 15))
                            .monospacedDigit()
                    }
                    .foregroundStyle(isDangerous ? RenaissanceColors.errorRed : sepiaInk)
                    .position(x: cx, y: h * 0.08)

                    // Tension arrows
                    if windSpeed > 0.3 {
                        ForEach([-1.0, 1.0], id: \.self) { side in
                            Image(systemName: "arrow.left.and.right")
                                .font(.system(size: 13))
                                .foregroundStyle(isDangerous ? RenaissanceColors.errorRed.opacity(0.5) : color.opacity(0.4))
                                .position(x: cx + side * w * 0.2, y: mastY - mastH * 0.3)
                        }
                    }

                    // Slider
                    if step >= 2 {
                        VStack(spacing: 2) {
                            Slider(value: $windSpeed, in: 0...1)
                                .tint(isDangerous ? RenaissanceColors.errorRed : color)
                                .frame(width: w * 0.5)
                            HStack {
                                Text("Calm").font(.custom("EBGaramond-Regular", size: 15))
                                Spacer()
                                Text("Storm").font(.custom("EBGaramond-Regular", size: 15))
                            }
                            .foregroundStyle(sepiaInk.opacity(0.4))
                            .frame(width: w * 0.5)
                        }
                        .position(x: cx, y: h * 0.88)
                    }

                    if isDangerous && step >= 2 {
                        Text("RETRACT!")
                            .font(.custom("Cinzel-Bold", size: 16))
                            .foregroundStyle(RenaissanceColors.errorRed)
                            .position(x: cx, y: h * 0.2)
                    }
                }
            }
        }
    }
}
