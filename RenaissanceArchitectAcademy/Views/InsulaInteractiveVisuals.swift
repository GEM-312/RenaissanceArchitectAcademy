import SwiftUI

/// Interactive science visuals for Insula knowledge cards
struct InsulaInteractiveVisuals {

    @ViewBuilder
    static func view(for visual: CardVisual, color: Color, height: CGFloat = 275) -> some View {
        let h = height
        Group {
            switch visual.title {
            case let t where t.contains("6-7 Story") || t.contains("Apartment"):
                ApartmentFloorsVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Height Limit"):
                HeightLimitVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Taberna"):
                TabernaShopVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Wall Thickness") || t.contains("Taper"):
                WallTaperVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Spiral Staircase"):
                SpiralStaircaseVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Cheap Mortar") || (t.contains("1:4") && !t.contains("Bath") && !t.contains("Silica")):
                CheapMortarVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Tegulae") || t.contains("Imbrices"):
                TileInterlockVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Glass vs Mica") || t.contains("Mica Window"):
                GlassMicaVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Beam Depth"):
                BeamDepthVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Oak vs Poplar"):
                OakPoplarFireVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Aged Lime") || t.contains("Lime Putty"):
                AgedLimeVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Brick Firing") || t.contains("Sweet Spot"):
                BrickFiringVisual(visual: visual, color: color, height: h)
            default:
                EmptyView()
            }
        }
    }

    static func hasInteractiveVisual(for visual: CardVisual) -> Bool {
        let t = visual.title
        return t.contains("6-7 Story") || t.contains("Apartment") ||
               t.contains("Height Limit") || t.contains("Taberna") ||
               t.contains("Wall Thickness") || t.contains("Taper") ||
               t.contains("Spiral Staircase") ||
               (t.contains("Cheap Mortar") || (t.contains("1:4") && !t.contains("Bath") && !t.contains("Silica"))) ||
               t.contains("Tegulae") || t.contains("Imbrices") ||
               t.contains("Glass vs Mica") || t.contains("Mica Window") ||
               t.contains("Beam Depth") || t.contains("Oak vs Poplar") ||
               t.contains("Aged Lime") || t.contains("Lime Putty") ||
               t.contains("Brick Firing") || t.contains("Sweet Spot")
    }
}

// MARK: - Local Colors (unique to Insula)

private let brickRed = Color(red: 0.72, green: 0.42, blue: 0.32)
private let oakBrown = Color(red: 0.55, green: 0.40, blue: 0.28)
private let poplarLight = Color(red: 0.78, green: 0.70, blue: 0.55)

private typealias TeachingContainer = IVTeachingContainer
private typealias DimLabel = IVDimLabel
private typealias FormulaText = IVFormulaText
private typealias DimLine = IVDimLine

// MARK: - 1. Apartment Floors — Build Each Floor

private struct ApartmentFloorsVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    @State private var floorsBuilt: Int = 0

    private let floors: [(name: String, desc: String, color: Color)] = [
        ("Shops", "Tabernae — street level", IVMaterialColors.stoneGray),
        ("Rich", "Large apartments, running water", Color(red: 0.80, green: 0.70, blue: 0.50)),
        ("Middle", "Smaller rooms, no water", Color(red: 0.70, green: 0.62, blue: 0.48)),
        ("Middle", "Cramped, shared kitchen", Color(red: 0.65, green: 0.58, blue: 0.46)),
        ("Poor", "Single rooms, fire risk", Color(red: 0.55, green: 0.50, blue: 0.42)),
        ("Attic", "Cheapest — hottest in summer", Color(red: 0.50, green: 0.46, blue: 0.40)),
    ]

    private var label: String {
        switch step {
        case 1: return "Rome's first apartment buildings — up to 7 stories tall."
        case 2:
            if floorsBuilt < floors.count { return "Tap to build floor \(floorsBuilt + 1) — \(floors[floorsBuilt].name)." }
            return "Rich at bottom, poor at top — vertical inequality."
        default: return "Vertical cities have always sorted people by money."
        }
    }

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3,
                         step: $step, stepLabel: label, height: height) {
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let cx = w * 0.5
                let floorH = h * 0.1
                let buildingW = w * 0.4
                let baseY = h * 0.72

                ZStack {
                    // Ground line
                    Path { p in
                        p.move(to: CGPoint(x: w * 0.2, y: baseY + floorH * 0.5))
                        p.addLine(to: CGPoint(x: w * 0.8, y: baseY + floorH * 0.5))
                    }
                    .stroke(RenaissanceColors.warmBrown.opacity(0.3), lineWidth: 1)

                    // Built floors
                    ForEach(0..<floorsBuilt, id: \.self) { i in
                        let y = baseY - CGFloat(i) * floorH
                        RoundedRectangle(cornerRadius: 2)
                            .fill(floors[i].color.opacity(0.4))
                            .frame(width: buildingW - CGFloat(i) * 3, height: floorH - 2)
                            .overlay(
                                RoundedRectangle(cornerRadius: 2)
                                    .strokeBorder(floors[i].color.opacity(0.6), lineWidth: 0.8)
                            )
                            .position(x: cx, y: y)
                            .transition(.move(edge: .bottom).combined(with: .opacity))

                        // Floor label
                        Text(floors[i].name)
                            .font(RenaissanceFont.ivBody)
                            .foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.5))
                            .position(x: cx + buildingW * 0.5 + 22, y: y)
                    }

                    // Build button
                    if step >= 2 && floorsBuilt < floors.count {
                        Button {
                            withAnimation(.spring(response: 0.3)) { floorsBuilt += 1 }
                            SoundManager.shared.play(.tapSoft)
                            if floorsBuilt >= floors.count {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    withAnimation { step = 3 }
                                }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "square.stack.3d.up").font(.system(size: 13))
                                Text("Add Floor").font(RenaissanceFont.ivLabel)
                            }
                            .foregroundStyle(floors[floorsBuilt].color)
                            .padding(.horizontal, 12).padding(.vertical, 6)
                            .background(floors[floorsBuilt].color.opacity(0.15)).cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                        .position(x: cx, y: h * 0.08)
                    }

                    if step >= 3 {
                        FormulaText(text: "Rich ↓ Poor ↑ — vertical inequality", highlighted: true)
                            .position(x: cx, y: h * 0.08)
                            .transition(.opacity)
                    }
                }
            }
        }
    }
}

// MARK: - 2. Height Limits — Slider Push Height

private struct HeightLimitVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    @State private var buildingHeight: CGFloat = 0.3

    private var meters: Int { Int(buildingHeight * 30) }
    private var overAugustus: Bool { meters > 20 }
    private var overNero: Bool { meters > 17 }

    private var label: String {
        switch step {
        case 1: return "No height limits → collapses → Augustus sets 20m maximum."
        case 2: return "Drag to push the height — watch the building codes react."
        default: return "Building codes were written in blood."
        }
    }

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3,
                         step: $step, stepLabel: label, height: height) {
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let cx = w * 0.5
                let baseY = h * 0.75
                let maxBuildH = h * 0.6
                let buildH = maxBuildH * buildingHeight

                ZStack {
                    // Ground
                    Path { p in
                        p.move(to: CGPoint(x: w * 0.15, y: baseY))
                        p.addLine(to: CGPoint(x: w * 0.85, y: baseY))
                    }
                    .stroke(RenaissanceColors.warmBrown.opacity(0.3), lineWidth: 1)

                    // Building
                    RoundedRectangle(cornerRadius: 3)
                        .fill(overAugustus ? RenaissanceColors.errorRed.opacity(0.2) : brickRed.opacity(0.3))
                        .frame(width: w * 0.2, height: buildH)
                        .overlay(
                            RoundedRectangle(cornerRadius: 3)
                                .strokeBorder(overAugustus ? RenaissanceColors.errorRed : brickRed, lineWidth: 1.5)
                        )
                        .position(x: cx, y: baseY - buildH * 0.5)

                    // Height limit lines
                    // Augustus 20m line
                    let augustusY = baseY - maxBuildH * (20.0 / 30.0)
                    Path { p in
                        p.move(to: CGPoint(x: w * 0.3, y: augustusY))
                        p.addLine(to: CGPoint(x: w * 0.7, y: augustusY))
                    }
                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
                    .foregroundStyle(RenaissanceColors.errorRed.opacity(0.5))

                    Text("Augustus: 20m")
                        .font(RenaissanceFont.ivBody)
                        .foregroundStyle(RenaissanceColors.errorRed.opacity(0.6))
                        .position(x: w * 0.78, y: augustusY)

                    // Nero 17.5m line
                    let neroY = baseY - maxBuildH * (17.5 / 30.0)
                    Path { p in
                        p.move(to: CGPoint(x: w * 0.3, y: neroY))
                        p.addLine(to: CGPoint(x: w * 0.7, y: neroY))
                    }
                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
                    .foregroundStyle(warmOrange.opacity(0.5))

                    Text("Nero: 17.5m")
                        .font(RenaissanceFont.ivBody)
                        .foregroundStyle(warmOrange.opacity(0.6))
                        .position(x: w * 0.78, y: neroY)

                    // Height label
                    Text("\(meters)m")
                        .font(.custom("EBGaramond-Bold", size: 16))
                        .foregroundStyle(overAugustus ? RenaissanceColors.errorRed : IVMaterialColors.sepiaInk)
                        .position(x: cx, y: baseY - buildH - 12)

                    if overAugustus {
                        Text("ILLEGAL")
                            .font(RenaissanceFont.visualTitle)
                            .foregroundStyle(RenaissanceColors.errorRed)
                            .position(x: cx, y: h * 0.08)
                    }

                    // Slider
                    if step >= 2 {
                        Slider(value: $buildingHeight, in: 0.1...1.0)
                            .tint(overAugustus ? RenaissanceColors.errorRed : color)
                            .frame(width: w * 0.5)
                            .position(x: cx, y: h * 0.88)
                            .onChange(of: buildingHeight) { _, _ in
                                if overAugustus { withAnimation { step = 3 } }
                            }
                    }
                }
            }
        }
    }
}

private let warmOrange = Color(red: 0.90, green: 0.65, blue: 0.35)

// MARK: - 3. Taberna Shop — Tap to Reveal

private struct TabernaShopVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    @State private var revealedParts: Set<Int> = []

    private let parts: [(name: String, icon: String)] = [
        ("Street arch", "door.left.hand.open"),
        ("Counter", "rectangle.split.3x1"),
        ("Mezzanine", "bed.double"),
    ]

    private var label: String {
        switch step {
        case 1: return "Ground floor = shop. Every insula was a mini-mall."
        case 2:
            if revealedParts.count < 3 { return "Tap to reveal each feature of the taberna." }
            return "Maximum visibility, minimum wasted space."
        default: return "2,000 years later — still how shops are designed."
        }
    }

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3,
                         step: $step, stepLabel: label, height: height) {
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let cx = w * 0.5
                let shopW = w * 0.5
                let shopH = h * 0.5

                ZStack {
                    // Shop outline
                    RoundedRectangle(cornerRadius: 4)
                        .strokeBorder(IVMaterialColors.stoneGray, lineWidth: 2)
                        .frame(width: shopW, height: shopH)
                        .position(x: cx, y: h * 0.38)

                    if step >= 2 {
                        // Street arch (front opening)
                        if revealedParts.contains(0) {
                            Path { p in
                                let archX = cx - shopW * 0.5
                                let archY = h * 0.38 + shopH * 0.1
                                p.move(to: CGPoint(x: archX, y: archY + shopH * 0.3))
                                p.addQuadCurve(
                                    to: CGPoint(x: archX, y: archY - shopH * 0.15),
                                    control: CGPoint(x: archX - 15, y: archY + shopH * 0.08)
                                )
                            }
                            .stroke(brickRed, lineWidth: 2)
                            .transition(.opacity)
                        }

                        // Counter
                        if revealedParts.contains(1) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(oakBrown.opacity(0.4))
                                .frame(width: shopW * 0.6, height: 8)
                                .position(x: cx - shopW * 0.1, y: h * 0.38 + shopH * 0.15)
                                .transition(.opacity)
                        }

                        // Mezzanine
                        if revealedParts.contains(2) {
                            Path { p in
                                p.move(to: CGPoint(x: cx - shopW * 0.5 + 4, y: h * 0.38 - shopH * 0.15))
                                p.addLine(to: CGPoint(x: cx + shopW * 0.5 - 4, y: h * 0.38 - shopH * 0.15))
                            }
                            .stroke(oakBrown, lineWidth: 2)

                            Text("Mezzanine bedroom")
                                .font(RenaissanceFont.ivBody)
                                .foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.5))
                                .position(x: cx, y: h * 0.38 - shopH * 0.25)
                                .transition(.opacity)
                        }

                        // Tap targets
                        ForEach(0..<3, id: \.self) { i in
                            if !revealedParts.contains(i) {
                                let positions: [CGPoint] = [
                                    CGPoint(x: cx - shopW * 0.4, y: h * 0.38 + shopH * 0.15),
                                    CGPoint(x: cx, y: h * 0.38 + shopH * 0.15),
                                    CGPoint(x: cx, y: h * 0.38 - shopH * 0.2),
                                ]
                                Button {
                                    withAnimation(.spring(response: 0.3)) { revealedParts.insert(i) }
                                    SoundManager.shared.play(.tapSoft)
                                    if revealedParts.count == 3 {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            withAnimation { step = 3 }
                                        }
                                    }
                                } label: {
                                    VStack(spacing: 2) {
                                        Image(systemName: parts[i].icon).font(.system(size: 13))
                                        Text(parts[i].name).font(RenaissanceFont.ivBody)
                                    }
                                    .foregroundStyle(color.opacity(0.5))
                                    .padding(6)
                                    .background(color.opacity(0.08))
                                    .cornerRadius(4)
                                }
                                .buttonStyle(.plain)
                                .position(positions[i])
                            }
                        }
                    }

                    if step >= 3 {
                        FormulaText(text: "Max visibility, min wasted space", highlighted: true)
                            .position(x: cx, y: h * 0.85)
                            .transition(.opacity)
                    }
                }
            }
        }
    }
}

// MARK: - 4. Wall Taper — Stack Thinning Floors

private struct WallTaperVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    @State private var floorsStacked: Int = 0

    private let wallWidths: [(cm: Int, material: String)] = [
        (60, "Solid brick"), (45, "Brick"), (30, "Thin brick"), (15, "Timber frame"),
    ]

    private var label: String {
        switch step {
        case 1: return "Walls thin as you go up — 60cm at ground, 15cm at top."
        case 2:
            if floorsStacked < 4 { return "Tap to stack floor \(floorsStacked + 1) — \(wallWidths[floorsStacked].cm)cm walls." }
            return "Lighter where it's tallest — structural intuition."
        default: return "Weight management in vertical architecture."
        }
    }

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3,
                         step: $step, stepLabel: label, height: height) {
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let cx = w * 0.5
                let floorH = h * 0.13
                let baseY = h * 0.65
                let maxW = w * 0.45

                ZStack {
                    ForEach(0..<floorsStacked, id: \.self) { i in
                        let y = baseY - CGFloat(i) * floorH
                        let wallFrac = CGFloat(wallWidths[i].cm) / 60.0
                        let floorW = maxW * wallFrac

                        // Wall section
                        RoundedRectangle(cornerRadius: 2)
                            .fill(brickRed.opacity(0.2 + wallFrac * 0.3))
                            .frame(width: floorW, height: floorH - 3)
                            .overlay(
                                RoundedRectangle(cornerRadius: 2)
                                    .strokeBorder(brickRed.opacity(0.5), lineWidth: 1)
                            )
                            .position(x: cx, y: y)
                            .transition(.move(edge: .bottom).combined(with: .opacity))

                        // Width label
                        DimLabel(text: "\(wallWidths[i].cm)cm")
                            .position(x: cx + floorW * 0.5 + 20, y: y)
                    }

                    // Build button
                    if step >= 2 && floorsStacked < 4 {
                        Button {
                            withAnimation(.spring(response: 0.3)) { floorsStacked += 1 }
                            SoundManager.shared.play(.tapSoft)
                            if floorsStacked >= 4 {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    withAnimation { step = 3 }
                                }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "square.stack.3d.up").font(.system(size: 13))
                                Text("Add Floor").font(RenaissanceFont.ivLabel)
                            }
                            .foregroundStyle(color)
                            .padding(.horizontal, 12).padding(.vertical, 6)
                            .background(color.opacity(0.1)).cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                        .position(x: cx, y: h * 0.12)
                    }

                    if step >= 3 {
                        FormulaText(text: "60cm → 45 → 30 → 15cm timber", highlighted: true)
                            .position(x: cx, y: h * 0.88)
                            .transition(.opacity)
                    }
                }
            }
        }
    }
}

// MARK: - 5. Spiral Staircase — Rotate View

private struct SpiralStaircaseVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    @State private var rotation: CGFloat = 0

    private var label: String {
        switch step {
        case 1: return "A 2-meter diameter spiral — maximum climb, minimum space."
        case 2: return "Drag to rotate — see the wedge steps from above."
        default: return "Maximum vertical travel in minimum floor space."
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
                let radius = min(w, h) * 0.25

                ZStack {
                    // Outer circle (stairwell wall)
                    Circle()
                        .strokeBorder(IVMaterialColors.stoneGray, lineWidth: 2)
                        .frame(width: radius * 2, height: radius * 2)
                        .position(x: cx, y: cy)

                    // Center column
                    Circle()
                        .fill(IVMaterialColors.stoneGray.opacity(0.4))
                        .frame(width: 12, height: 12)
                        .position(x: cx, y: cy)

                    // Wedge steps (top-down view)
                    ForEach(0..<8, id: \.self) { i in
                        let angle = (CGFloat(i) / 8.0) * .pi * 2 + rotation
                        let startAngle = Angle(radians: Double(angle))
                        let endAngle = Angle(radians: Double(angle + .pi / 5))

                        Path { p in
                            p.move(to: CGPoint(x: cx, y: cy))
                            p.addArc(center: CGPoint(x: cx, y: cy),
                                    radius: radius - 2,
                                    startAngle: startAngle,
                                    endAngle: endAngle,
                                    clockwise: false)
                            p.closeSubpath()
                        }
                        .fill(IVMaterialColors.stoneGray.opacity(i % 2 == 0 ? 0.25 : 0.15))

                        Path { p in
                            p.move(to: CGPoint(x: cx, y: cy))
                            p.addLine(to: CGPoint(
                                x: cx + (radius - 2) * cos(angle),
                                y: cy + (radius - 2) * sin(angle)
                            ))
                        }
                        .stroke(IVMaterialColors.stoneGray.opacity(0.4), lineWidth: 0.8)
                    }

                    // Drag gesture (step 2)
                    if step >= 2 {
                        Color.clear
                            .contentShape(Circle().size(CGSize(width: radius * 2, height: radius * 2)))
                            .frame(width: radius * 2, height: radius * 2)
                            .position(x: cx, y: cy)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        rotation += value.translation.width * 0.005
                                    }
                                    .onEnded { _ in
                                        SoundManager.shared.play(.tapSoft)
                                        if abs(rotation) > 1.5 { withAnimation { step = 3 } }
                                    }
                            )
                    }

                    // Dimension
                    DimLine(from: CGPoint(x: cx - radius, y: cy + radius + 12),
                            to: CGPoint(x: cx + radius, y: cy + radius + 12))
                        .stroke(IVMaterialColors.dimColor, lineWidth: 0.8)
                    DimLabel(text: "2 m diameter")
                        .position(x: cx, y: cy + radius + 22)

                    if step >= 3 {
                        FormulaText(text: "2m circle → 7 floors of access", highlighted: true)
                            .position(x: cx, y: h * 0.88)
                            .transition(.opacity)
                    }
                }
            }
        }
    }
}

// MARK: - 6. Cheap Mortar — Compare Strength

private struct CheapMortarVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    @State private var tested = false

    private var label: String {
        switch step {
        case 1: return "1:4 ratio — no pozzolana. Cheaper but weaker."
        case 2:
            if !tested { return "Tap to test both — which one crumbles?" }
            return "Cheap mortar crumbles — Roman concrete holds."
        default: return "Economy and engineering, balanced on a budget."
        }
    }

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3,
                         step: $step, stepLabel: label, height: height) {
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height

                ZStack {
                    HStack(spacing: w * 0.06) {
                        // Cheap mortar block
                        VStack(spacing: 4) {
                            Text("INSULA 1:4")
                                .font(RenaissanceFont.visualTitle).tracking(0.5)
                                .foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.5))
                            ZStack {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(IVMaterialColors.limeTan.opacity(tested ? 0.3 : 0.6))
                                    .frame(width: w * 0.28, height: h * 0.25)
                                if tested {
                                    // Crack lines
                                    ForEach(0..<3, id: \.self) { i in
                                        Path { p in
                                            p.move(to: CGPoint(x: CGFloat(i * 25 + 10), y: 5))
                                            p.addLine(to: CGPoint(x: CGFloat(i * 20 + 15), y: h * 0.25 - 5))
                                        }
                                        .stroke(RenaissanceColors.errorRed.opacity(0.5), lineWidth: 1)
                                        .frame(width: w * 0.28, height: h * 0.25)
                                    }
                                }
                            }
                            if tested {
                                Text("Crumbles").font(RenaissanceFont.ivFormula)
                                    .foregroundStyle(RenaissanceColors.errorRed)
                            }
                            Text("No pozzolana").font(RenaissanceFont.ivBody).foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.4))
                        }

                        // Roman concrete block
                        VStack(spacing: 4) {
                            Text("ROMAN 1:3")
                                .font(RenaissanceFont.visualTitle).tracking(0.5)
                                .foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.5))
                            RoundedRectangle(cornerRadius: 4)
                                .fill(IVMaterialColors.stoneGray.opacity(0.5))
                                .frame(width: w * 0.28, height: h * 0.25)
                                .overlay {
                                    if tested {
                                        RoundedRectangle(cornerRadius: 4)
                                            .strokeBorder(RenaissanceColors.sageGreen, lineWidth: 2)
                                    }
                                }
                            if tested {
                                Text("Holds").font(RenaissanceFont.ivFormula)
                                    .foregroundStyle(RenaissanceColors.sageGreen)
                            }
                            Text("With pozzolana").font(RenaissanceFont.ivBody).foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.4))
                        }
                    }
                    .position(x: w * 0.5, y: h * 0.4)

                    // Test button
                    if step >= 2 && !tested {
                        Button {
                            withAnimation(.spring(response: 0.4)) { tested = true }
                            SoundManager.shared.play(.tapSoft)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                withAnimation { step = 3 }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "hammer.fill").font(.system(size: 13))
                                Text("Stress Test").font(RenaissanceFont.ivLabel)
                            }
                            .foregroundStyle(color)
                            .padding(.horizontal, 12).padding(.vertical, 6)
                            .background(color.opacity(0.1)).cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                        .position(x: w * 0.5, y: h * 0.75)
                    }

                    if step >= 3 {
                        FormulaText(text: "1/3 the cost — 1/3 the strength", highlighted: true)
                            .position(x: w * 0.5, y: h * 0.85)
                            .transition(.opacity)
                    }
                }
            }
        }
    }
}

// MARK: - 7. Tegulae + Imbrices — Interlock Tiles

private struct TileInterlockVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    @State private var tilesPlaced: Int = 0

    private var label: String {
        switch step {
        case 1: return "Flat tiles (tegulae) + half-round caps (imbrices) = waterproof roof."
        case 2:
            if tilesPlaced < 4 { return "Tap to interlock tile pair \(tilesPlaced + 1)." }
            return "3,000 tiles per insula — no nails, gravity holds them."
        default: return "The system hasn't changed in 2,000 years."
        }
    }

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3,
                         step: $step, stepLabel: label, height: height) {
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let cx = w * 0.5
                let tileW = w * 0.14
                let startX = cx - tileW * 1.5

                ZStack {
                    // Roof slope line
                    Path { p in
                        p.move(to: CGPoint(x: w * 0.2, y: h * 0.55))
                        p.addLine(to: CGPoint(x: w * 0.8, y: h * 0.45))
                    }
                    .stroke(RenaissanceColors.warmBrown.opacity(0.2), lineWidth: 1)

                    if step >= 2 {
                        ForEach(0..<4, id: \.self) { i in
                            let x = startX + CGFloat(i) * tileW
                            let slopeY = h * 0.55 - CGFloat(i) * 3
                            let placed = i < tilesPlaced

                            // Tegula (flat tile)
                            RoundedRectangle(cornerRadius: 2)
                                .fill(placed ? brickRed.opacity(0.4) : brickRed.opacity(0.1))
                                .frame(width: tileW - 4, height: h * 0.12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 2)
                                        .strokeBorder(placed ? brickRed : brickRed.opacity(0.2), lineWidth: placed ? 1 : 0.5)
                                )
                                .position(x: x, y: slopeY - h * 0.08)

                            // Imbrix (half-round cap on joint)
                            if placed && i < 3 {
                                Capsule()
                                    .fill(brickRed.opacity(0.6))
                                    .frame(width: 8, height: h * 0.13)
                                    .position(x: x + tileW * 0.5 - 2, y: slopeY - h * 0.08)
                                    .transition(.scale)
                            }

                            if !placed {
                                Circle()
                                    .fill(color.opacity(0.15))
                                    .frame(width: 24, height: 24)
                                    .overlay {
                                        Text("+").font(.system(size: 14)).foregroundStyle(color.opacity(0.4))
                                    }
                                    .position(x: x, y: slopeY - h * 0.08)
                                    .onTapGesture {
                                        guard i == tilesPlaced else { return }
                                        withAnimation(.spring(response: 0.3)) { tilesPlaced += 1 }
                                        SoundManager.shared.play(.tapSoft)
                                        if tilesPlaced >= 4 {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                withAnimation { step = 3 }
                                            }
                                        }
                                    }
                            }
                        }
                    }

                    // Legend
                    HStack(spacing: 12) {
                        HStack(spacing: 4) {
                            RoundedRectangle(cornerRadius: 1).fill(brickRed.opacity(0.4)).frame(width: 12, height: 8)
                            Text("Tegula").font(RenaissanceFont.ivBody).foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.5))
                        }
                        HStack(spacing: 4) {
                            Capsule().fill(brickRed.opacity(0.6)).frame(width: 4, height: 10)
                            Text("Imbrix").font(RenaissanceFont.ivBody).foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.5))
                        }
                    }
                    .position(x: cx, y: h * 0.2)

                    if step >= 3 {
                        FormulaText(text: "No nails — gravity holds 3,000 tiles", highlighted: true)
                            .position(x: cx, y: h * 0.85)
                            .transition(.opacity)
                    }
                }
            }
        }
    }
}

// MARK: - 8. Glass vs Mica — Tap Windows

private struct GlassMicaVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    @State private var tappedGlass = false
    @State private var tappedMica = false

    private var label: String {
        switch step {
        case 1: return "Light was a luxury — priced by floor."
        case 2:
            if !tappedGlass && !tappedMica { return "Tap each window to compare." }
            if tappedGlass && !tappedMica { return "Now tap mica — the budget option." }
            if !tappedGlass && tappedMica { return "Now tap glass — the expensive one." }
            return "Clear glass for the rich, translucent mica for the rest."
        default: return "Most insulae had mica below 3rd floor, open shutters above."
        }
    }

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3,
                         step: $step, stepLabel: label, height: height) {
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let winW = w * 0.22
                let winH = h * 0.3

                ZStack {
                    // Glass window (left)
                    VStack(spacing: 4) {
                        Text("GLASS").font(RenaissanceFont.visualTitle).tracking(0.5).foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.5))
                        RoundedRectangle(cornerRadius: 4)
                            .fill(tappedGlass ? Color(red: 0.85, green: 0.92, blue: 0.95).opacity(0.6) : IVMaterialColors.stoneGray.opacity(0.1))
                            .frame(width: winW, height: winH)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .strokeBorder(IVMaterialColors.stoneGray, lineWidth: 1.5)
                            )
                            .overlay {
                                if tappedGlass {
                                    // Window grid
                                    VStack(spacing: winH * 0.3) {
                                        ForEach(0..<2, id: \.self) { _ in
                                            Rectangle().fill(IVMaterialColors.stoneGray.opacity(0.3)).frame(height: 1)
                                        }
                                    }
                                    .padding(4)
                                }
                            }
                            .onTapGesture {
                                guard step >= 2 else { return }
                                withAnimation(.spring(response: 0.3)) { tappedGlass = true }
                                SoundManager.shared.play(.tapSoft)
                                checkBoth()
                            }
                        if tappedGlass {
                            Text("Clear — expensive").font(RenaissanceFont.ivBody).foregroundStyle(RenaissanceColors.ochre)
                                .transition(.opacity)
                        }
                    }
                    .position(x: w * 0.3, y: h * 0.4)

                    // Mica window (right)
                    VStack(spacing: 4) {
                        Text("MICA").font(RenaissanceFont.visualTitle).tracking(0.5).foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.5))
                        RoundedRectangle(cornerRadius: 4)
                            .fill(tappedMica ? Color(red: 0.85, green: 0.82, blue: 0.75).opacity(0.4) : IVMaterialColors.stoneGray.opacity(0.1))
                            .frame(width: winW, height: winH)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .strokeBorder(IVMaterialColors.stoneGray, lineWidth: 1.5)
                            )
                            .overlay {
                                if tappedMica {
                                    // Frosted/translucent effect
                                    ForEach(0..<6, id: \.self) { i in
                                        Circle()
                                            .fill(Color.white.opacity(0.15))
                                            .frame(width: CGFloat.random(in: 8...16))
                                            .offset(
                                                x: CGFloat(i * 13 % 30 - 15),
                                                y: CGFloat(i * 17 % 40 - 20)
                                            )
                                    }
                                }
                            }
                            .onTapGesture {
                                guard step >= 2 else { return }
                                withAnimation(.spring(response: 0.3)) { tappedMica = true }
                                SoundManager.shared.play(.tapSoft)
                                checkBoth()
                            }
                        if tappedMica {
                            Text("Translucent — cheap").font(RenaissanceFont.ivBody).foregroundStyle(RenaissanceColors.sageGreen)
                                .transition(.opacity)
                        }
                    }
                    .position(x: w * 0.7, y: h * 0.4)

                    if step >= 3 {
                        FormulaText(text: "Light was a luxury — priced by floor", highlighted: true)
                            .position(x: w * 0.5, y: h * 0.85)
                            .transition(.opacity)
                    }
                }
            }
        }
    }

    private func checkBoth() {
        if tappedGlass && tappedMica {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { withAnimation { step = 3 } }
        }
    }
}

// MARK: - 9. Beam Depth Rule — Drag Span Slider

private struct BeamDepthVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    @State private var spanValue: CGFloat = 0.5

    private var spanM: CGFloat { 3 + spanValue * 17 } // 3-20m range
    private var depthCm: Int { Int(spanM * 100 / 20) } // span/20 rule

    private var label: String {
        switch step {
        case 1: return "Beam depth = span ÷ 20. Simple rule, saves lives."
        case 2: return "Drag the span — depth auto-calculates."
        default: return "Math prevents collapse — every centimeter matters."
        }
    }

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3,
                         step: $step, stepLabel: label, height: height) {
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let cx = w * 0.5
                let beamW = w * (0.3 + spanValue * 0.5)
                let beamH = h * (0.04 + spanValue * 0.06)
                let beamY = h * 0.38

                ZStack {
                    // Support walls
                    ForEach([-1.0, 1.0], id: \.self) { side in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(IVMaterialColors.stoneGray.opacity(0.4))
                            .frame(width: 8, height: h * 0.25)
                            .position(x: cx + side * beamW * 0.52, y: beamY + h * 0.13)
                    }

                    // Beam
                    RoundedRectangle(cornerRadius: 2)
                        .fill(oakBrown)
                        .frame(width: beamW, height: beamH)
                        .position(x: cx, y: beamY)

                    // Span dimension
                    DimLine(from: CGPoint(x: cx - beamW * 0.5, y: beamY + beamH + 10),
                            to: CGPoint(x: cx + beamW * 0.5, y: beamY + beamH + 10))
                        .stroke(IVMaterialColors.dimColor, lineWidth: 0.8)
                    DimLabel(text: String(format: "%.1fm span", spanM))
                        .position(x: cx, y: beamY + beamH + 22)

                    // Depth dimension
                    DimLabel(text: "\(depthCm)cm deep")
                        .position(x: cx + beamW * 0.5 + 30, y: beamY)

                    // Formula
                    FormulaText(text: "Depth = \(String(format: "%.1f", spanM))m ÷ 20 = \(depthCm)cm",
                               highlighted: step >= 3)
                        .position(x: cx, y: h * 0.12)

                    // Slider
                    if step >= 2 {
                        Slider(value: $spanValue, in: 0...1)
                            .tint(color)
                            .frame(width: w * 0.5)
                            .position(x: cx, y: h * 0.75)
                            .onChange(of: spanValue) { _, val in
                                if val > 0.8 { withAnimation { step = 3 } }
                            }
                    }
                }
            }
        }
    }
}

// MARK: - 10. Oak vs Poplar — Fire Test

private struct OakPoplarFireVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    @State private var fireStarted = false
    @State private var burnProgress: CGFloat = 0

    private var label: String {
        switch step {
        case 1: return "Oak for lower floors (strong), poplar for upper floors (light)."
        case 2:
            if !fireStarted { return "Tap to start a fire test." }
            return "Oak resists — poplar burns. Rome's fires started high."
        default: return "The cheapest material had the highest cost."
        }
    }

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3,
                         step: $step, stepLabel: label, height: height) {
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height

                ZStack {
                    HStack(spacing: w * 0.08) {
                        // Oak block
                        VStack(spacing: 4) {
                            Text("OAK").font(RenaissanceFont.visualTitle).tracking(0.5).foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.5))
                            RoundedRectangle(cornerRadius: 4)
                                .fill(oakBrown)
                                .frame(width: w * 0.25, height: h * 0.3)
                                .overlay {
                                    if fireStarted {
                                        // Small flame that doesn't spread
                                        Image(systemName: "flame")
                                            .font(.system(size: 13))
                                            .foregroundStyle(.orange.opacity(0.4))
                                            .offset(y: -h * 0.12)
                                    }
                                }
                            Text("Lower floors").font(RenaissanceFont.ivBody).foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.4))
                            if fireStarted {
                                Text("Resists").font(RenaissanceFont.ivFormula).foregroundStyle(RenaissanceColors.sageGreen)
                                    .transition(.opacity)
                            }
                        }

                        // Poplar block
                        VStack(spacing: 4) {
                            Text("POPLAR").font(RenaissanceFont.visualTitle).tracking(0.5).foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.5))
                            ZStack {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(poplarLight.opacity(1.0 - burnProgress * 0.6))
                                    .frame(width: w * 0.25, height: h * 0.3)
                                if fireStarted {
                                    // Growing flames
                                    Image(systemName: "flame.fill")
                                        .font(.system(size: 13 + burnProgress * 14))
                                        .foregroundStyle(.orange.opacity(0.5 + burnProgress * 0.3))
                                        .offset(y: -h * 0.08)
                                }
                            }
                            Text("Upper floors").font(RenaissanceFont.ivBody).foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.4))
                            if fireStarted {
                                Text("Burns!").font(RenaissanceFont.ivFormula).foregroundStyle(RenaissanceColors.errorRed)
                                    .transition(.opacity)
                            }
                        }
                    }
                    .position(x: w * 0.5, y: h * 0.4)

                    // Fire button
                    if step >= 2 && !fireStarted {
                        Button {
                            fireStarted = true
                            SoundManager.shared.play(.tapSoft)
                            withAnimation(.easeInOut(duration: 2.0)) { burnProgress = 1.0 }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                withAnimation { step = 3 }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "flame.fill").font(.system(size: 13))
                                Text("Fire Test").font(RenaissanceFont.ivLabel)
                            }
                            .foregroundStyle(.orange)
                            .padding(.horizontal, 12).padding(.vertical, 6)
                            .background(RenaissanceColors.terracotta.opacity(0.1)).cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                        .position(x: w * 0.5, y: h * 0.78)
                    }

                    if step >= 3 {
                        FormulaText(text: "40% lighter — but fire starts where the cheapest wood is", highlighted: true)
                            .position(x: w * 0.5, y: h * 0.85)
                            .transition(.opacity)
                    }
                }
            }
        }
    }
}

// MARK: - 11. Aged Lime Putty — Time Lapse

private struct AgedLimeVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    @State private var agingProgress: CGFloat = 0

    private var months: Int { Int(agingProgress * 6) }
    private var isReady: Bool { months >= 3 }

    private var label: String {
        switch step {
        case 1: return "Lime putty must age 3+ months — patience is an ingredient."
        case 2: return "Drag to age — watch the consistency change."
        default: return "Thick yogurt = perfect mortar. Hot spots eliminated."
        }
    }

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3,
                         step: $step, stepLabel: label, height: height) {
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let cx = w * 0.5
                let bowlW = w * 0.35
                let bowlH = h * 0.22

                ZStack {
                    // Bowl
                    Ellipse()
                        .fill(IVMaterialColors.stoneGray.opacity(0.2))
                        .frame(width: bowlW, height: bowlH)
                        .position(x: cx, y: h * 0.38)

                    Ellipse()
                        .strokeBorder(IVMaterialColors.stoneGray, lineWidth: 1.5)
                        .frame(width: bowlW, height: bowlH)
                        .position(x: cx, y: h * 0.38)

                    // Putty (color/texture changes with aging)
                    let puttyColor = isReady ?
                        Color(red: 0.92, green: 0.90, blue: 0.85) :
                        Color(red: 0.85, green: 0.82, blue: 0.72).opacity(0.5 + agingProgress * 0.4)

                    Ellipse()
                        .fill(puttyColor)
                        .frame(width: bowlW - 10, height: bowlH - 8)
                        .position(x: cx, y: h * 0.38)

                    // Consistency label
                    Text(months < 1 ? "Runny" : months < 3 ? "Thickening..." : "Thick yogurt")
                        .font(RenaissanceFont.ivLabel)
                        .foregroundStyle(isReady ? RenaissanceColors.sageGreen : IVMaterialColors.sepiaInk)
                        .position(x: cx, y: h * 0.55)

                    // Month counter
                    Text("\(months) months")
                        .font(.custom("EBGaramond-Bold", size: 16))
                        .monospacedDigit()
                        .foregroundStyle(isReady ? RenaissanceColors.sageGreen : IVMaterialColors.sepiaInk)
                        .position(x: cx, y: h * 0.15)

                    // Slider
                    if step >= 2 {
                        Slider(value: $agingProgress, in: 0...1)
                            .tint(isReady ? RenaissanceColors.sageGreen : color)
                            .frame(width: w * 0.5)
                            .position(x: cx, y: h * 0.7)
                            .onChange(of: agingProgress) { _, _ in
                                if isReady { withAnimation { step = 3 } }
                            }
                    }

                    if step >= 3 {
                        FormulaText(text: "Patience = no hot spots = stronger mortar", highlighted: true)
                            .position(x: cx, y: h * 0.85)
                            .transition(.opacity)
                    }
                }
            }
        }
    }
}

// MARK: - 12. Brick Firing Sweet Spot — Temp Slider

private struct BrickFiringVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    @State private var temperature: CGFloat = 0

    private var tempC: Int { Int(temperature * 1200) }
    private var isPerfect: Bool { tempC >= 920 && tempC <= 1050 }
    private var isTooLow: Bool { tempC < 900 }
    private var isTooHigh: Bool { tempC > 1100 }

    private var brickColor: Color {
        if tempC < 700 { return Color(red: 0.60, green: 0.48, blue: 0.38) }
        if tempC < 900 { return Color(red: 0.68, green: 0.45, blue: 0.32) }
        if tempC <= 1050 { return brickRed }
        return Color(red: 0.45, green: 0.32, blue: 0.28) // over-fired dark
    }

    private var label: String {
        switch step {
        case 1: return "950°C — the sweet spot. Below = crumbly, above = brittle."
        case 2: return "Drag temperature. Find the perfect firing range."
        default: return "Precision from a hole in a wall — air vent controls everything."
        }
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10).fill(RenaissanceColors.parchment)
            RoundedRectangle(cornerRadius: 10).strokeBorder(color.opacity(0.2), lineWidth: 1)
            IVBlueprintGrid()

            VStack(spacing: 10) {
                Text("\(tempC)°C")
                    .font(.custom("EBGaramond-Bold", size: 20))
                    .monospacedDigit()
                    .foregroundStyle(isPerfect ? RenaissanceColors.sageGreen : (isTooHigh ? RenaissanceColors.errorRed : IVMaterialColors.sepiaInk))
                    .padding(.top, 8)

                // Brick
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(brickColor)
                        .frame(width: 70, height: 45)

                    if isTooLow && tempC > 600 {
                        // Crumbly dots
                        ForEach(0..<4, id: \.self) { i in
                            Circle()
                                .fill(brickColor.opacity(0.3))
                                .frame(width: 4)
                                .offset(x: CGFloat(i * 15 - 22), y: CGFloat(i * 8 - 12))
                        }
                    }
                    if isTooHigh {
                        // Crack
                        Path { p in
                            p.move(to: CGPoint(x: 15, y: 5))
                            p.addLine(to: CGPoint(x: 40, y: 22))
                            p.addLine(to: CGPoint(x: 30, y: 40))
                        }
                        .stroke(RenaissanceColors.errorRed.opacity(0.5), lineWidth: 1.5)
                        .frame(width: 70, height: 45)
                    }
                    if isPerfect {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(RenaissanceColors.sageGreen)
                    }
                }

                // Status
                Text(isTooLow ? (tempC < 400 ? "Raw clay" : "Under-fired — crumbly") :
                     isPerfect ? "Perfect — rings when tapped!" :
                     isTooHigh ? "Over-fired — brittle!" : "Warming...")
                    .font(RenaissanceFont.ivLabel)
                    .foregroundStyle(isPerfect ? RenaissanceColors.sageGreen : (isTooHigh ? RenaissanceColors.errorRed : IVMaterialColors.sepiaInk))

                // Slider
                VStack(spacing: 2) {
                    Slider(value: $temperature, in: 0...1)
                        .tint(isPerfect ? RenaissanceColors.sageGreen : (isTooHigh ? RenaissanceColors.errorRed : .orange))
                        .frame(width: 200)
                        .onChange(of: temperature) { _, _ in
                            if isPerfect { withAnimation { step = 3 } }
                        }
                    HStack {
                        Text("0°C").font(RenaissanceFont.ivBody)
                        Spacer()
                        Text("950°C").font(RenaissanceFont.ivBody).foregroundStyle(RenaissanceColors.sageGreen)
                        Spacer()
                        Text("1200°C").font(RenaissanceFont.ivBody).foregroundStyle(RenaissanceColors.errorRed)
                    }
                    .foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.4))
                    .frame(width: 200)
                }

                Spacer()
            }
            .padding(.horizontal, 12)
        }
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
