import SwiftUI

/// Interactive science visuals for Siege Workshop knowledge cards
struct SiegeWorkshopInteractiveVisuals {

    @ViewBuilder
    static func view(for visual: CardVisual, color: Color, height: CGFloat = 275) -> some View {
        let h = height
        Group {
            switch visual.title {
            case let t where t.contains("Onager") || t.contains("Torsion Catapult"):
                OnagerLaunchVisual(visual: visual, color: color, height: h)
            case let t where t.contains("45°") || t.contains("Maximum Range"):
                LaunchAngleVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Torsion Energy") || t.contains("Square Law"):
                TorsionSpringVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Battering Ram") || t.contains("Pendulum"):
                BatteringRamVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Siege Tower") || t.contains("Mobile Fortress"):
                SiegeTowerVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Terracotta Tiles") || t.contains("Vitrification"):
                SiegeTilesVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Bloomery") || t.contains("Smelting"):
                BloomerySmelterVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Bronze Alloy") || t.contains("90:10"):
                BronzeGearVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Wet vs Dry") || t.contains("Soaking"):
                WetDryWoodVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Green Oak") || t.contains("Catapult Design"):
                GreenOakVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Walnut") || t.contains("Precision Wood"):
                WalnutPrecisionVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Military Joints") || t.contains("No Glue"):
                MilitaryJointsVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Tempering") || t.contains("750"):
                TemperingCycleVisual(visual: visual, color: color, height: h)
            default:
                EmptyView()
            }
        }
    }

    static func hasInteractiveVisual(for visual: CardVisual) -> Bool {
        let t = visual.title
        return t.contains("Onager") || t.contains("Torsion Catapult") ||
               t.contains("45°") || t.contains("Maximum Range") ||
               t.contains("Torsion Energy") || t.contains("Square Law") ||
               t.contains("Battering Ram") || t.contains("Pendulum") ||
               t.contains("Siege Tower") || t.contains("Mobile Fortress") ||
               t.contains("Terracotta Tiles") || t.contains("Vitrification") ||
               t.contains("Bloomery") || t.contains("Smelting") ||
               t.contains("Bronze Alloy") || t.contains("90:10") ||
               t.contains("Wet vs Dry") || t.contains("Soaking") ||
               t.contains("Green Oak") || t.contains("Catapult Design") ||
               t.contains("Walnut") || t.contains("Precision Wood") ||
               t.contains("Military Joints") || t.contains("No Glue") ||
               t.contains("Tempering") || t.contains("750")
    }
}

// MARK: - Local Aliases

private let sepiaInk = ivSepiaInk
private let waterBlue = ivWaterBlue
private let dimColor = ivDimColor
private let stoneGray = Color(red: 0.65, green: 0.63, blue: 0.60)
private let oakBrown = Color(red: 0.55, green: 0.40, blue: 0.28)
private let ironDark = Color(red: 0.35, green: 0.33, blue: 0.32)
private let bronzeGold = Color(red: 0.72, green: 0.58, blue: 0.35)
private let hotRed = Color(red: 0.85, green: 0.35, blue: 0.25)

private typealias TeachingContainer = IVTeachingContainer
private typealias DimLabel = IVDimLabel
private typealias FormulaText = IVFormulaText
private typealias DimLine = IVDimLine

// MARK: - 1. Onager — Drag Arm Back + Launch

private struct OnagerLaunchVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    @State private var armPull: CGFloat = 0
    @State private var launched = false
    @State private var projectileT: CGFloat = 0

    private var label: String {
        switch step {
        case 1: return "Twisted sinew stores elastic energy — 25 kg stone, 300m range."
        case 2:
            if !launched { return "Drag to pull the arm back — then release!" }
            return "25 kg launched 300 meters — pure physics."
        default: return "Destruction is just physics with a target."
        }
    }

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3,
                         step: $step, stepLabel: label, height: height) {
            GeometryReader { geo in
                let w = geo.size.width; let h = geo.size.height; let cx = w * 0.3
                let baseY = h * 0.65; let armLen = h * 0.4
                let armAngle = launched ? -CGFloat.pi * 0.4 : CGFloat.pi * 0.1 + armPull * CGFloat.pi * 0.3

                ZStack {
                    // Base frame
                    RoundedRectangle(cornerRadius: 2).fill(oakBrown).frame(width: w * 0.3, height: 8).position(x: cx, y: baseY)
                    // Wheels
                    ForEach([-1.0, 1.0], id: \.self) { side in
                        Circle().strokeBorder(oakBrown, lineWidth: 2).frame(width: 14, height: 14)
                            .position(x: cx + side * w * 0.12, y: baseY + 10)
                    }
                    // Torsion bundle
                    Circle().fill(Color.brown.opacity(0.4)).frame(width: 12, height: 12).position(x: cx, y: baseY - 6)
                    // Arm
                    Path { p in
                        p.move(to: CGPoint(x: cx, y: baseY - 6))
                        p.addLine(to: CGPoint(x: cx + armLen * sin(armAngle), y: baseY - 6 - armLen * cos(armAngle)))
                    }.stroke(oakBrown, lineWidth: 3)
                    // Projectile (on arm tip or flying)
                    let tipX = cx + armLen * sin(armAngle)
                    let tipY = baseY - 6 - armLen * cos(armAngle)
                    if !launched {
                        Circle().fill(stoneGray).frame(width: 10, height: 10).position(x: tipX, y: tipY)
                    } else {
                        // Parabolic flight
                        let flightX = tipX + projectileT * w * 0.5
                        let flightY = tipY + projectileT * projectileT * h * 0.8 - projectileT * h * 0.5
                        Circle().fill(stoneGray).frame(width: 10, height: 10).position(x: flightX, y: flightY)
                    }
                    // Drag area (step 2)
                    if step >= 2 && !launched {
                        Color.clear.contentShape(Rectangle()).gesture(
                            DragGesture()
                                .onChanged { v in armPull = max(0, min(1, v.translation.width / (w * 0.3))) }
                                .onEnded { _ in
                                    if armPull > 0.6 {
                                        launched = true; SoundManager.shared.play(.tapSoft)
                                        withAnimation(.easeOut(duration: 0.8)) { projectileT = 1.0 }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { withAnimation { step = 3 } }
                                    } else { withAnimation(.spring(response: 0.3)) { armPull = 0 } }
                                }
                        )
                    }
                    DimLabel(text: "300m range", fontSize: 15).position(x: w * 0.75, y: baseY + 8)
                    if step >= 3 { FormulaText(text: "E = ½kx² — elastic energy", highlighted: true, fontSize: 15).position(x: w * 0.5, y: h * 0.88).transition(.opacity) }
                }
            }
        }
    }
}

// MARK: - 2. Launch Angle — Slider Changes Arc

private struct LaunchAngleVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    @State private var angle: CGFloat = 0.5
    private var degrees: Int { Int(10 + angle * 70) }
    private var isOptimal: Bool { degrees >= 40 && degrees <= 50 }

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                         stepLabel: step == 1 ? "45° = maximum range. Mathematics makes every stone count." : step == 2 ? "Drag angle — watch the arc change." : "45° = vertical speed equals horizontal speed.", height: height) {
            GeometryReader { geo in
                let w = geo.size.width; let h = geo.size.height; let cx = w * 0.15; let baseY = h * 0.7
                let angleRad = CGFloat(degrees) * .pi / 180
                let range = w * 0.7 * sin(2 * angleRad)
                ZStack {
                    Path { p in p.move(to: CGPoint(x: w * 0.1, y: baseY)); p.addLine(to: CGPoint(x: w * 0.9, y: baseY)) }
                        .stroke(Color.brown.opacity(0.3), lineWidth: 1)
                    // Parabolic arc
                    Path { p in
                        for t in stride(from: 0.0, through: 1.0, by: 0.02) {
                            let x = cx + CGFloat(t) * range
                            let y = baseY - 4 * h * 0.4 * CGFloat(t) * (1 - CGFloat(t)) * sin(angleRad)
                            if t == 0 { p.move(to: CGPoint(x: x, y: y)) } else { p.addLine(to: CGPoint(x: x, y: y)) }
                        }
                    }.stroke(isOptimal ? RenaissanceColors.sageGreen : color, lineWidth: 2)
                    // Angle label
                    Text("\(degrees)°").font(.custom("EBGaramond-Bold", size: 16)).foregroundStyle(isOptimal ? RenaissanceColors.sageGreen : sepiaInk).position(x: cx + 30, y: baseY - 20)
                    // Range label
                    DimLabel(text: "\(Int(range / w * 300))m", fontSize: 15).position(x: cx + range * 0.5, y: baseY + 14)
                    if step >= 2 {
                        Slider(value: $angle, in: 0...1).tint(isOptimal ? RenaissanceColors.sageGreen : color).frame(width: w * 0.5).position(x: w * 0.5, y: h * 0.88)
                            .onChange(of: angle) { _, _ in if isOptimal { withAnimation { step = 3 } } }
                    }
                    if step >= 3 { FormulaText(text: "45° = maximum range", highlighted: true, fontSize: 15).position(x: w * 0.5, y: h * 0.12).transition(.opacity) }
                }
            }
        }
    }
}

// MARK: - 3. Torsion Springs — Twist Slider

private struct TorsionSpringVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    @State private var twists: CGFloat = 0.3
    private var power: Int { Int(twists * twists * 16) } // square law
    private var isDangerous: Bool { twists > 0.83 }

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                         stepLabel: step == 1 ? "Double the twists = 4× the power. Square law." : step == 2 ? "Drag to twist — power grows exponentially." : "Engineering is knowing how close to the edge you can go.", height: height) {
            GeometryReader { geo in
                let w = geo.size.width; let h = geo.size.height; let cx = w * 0.5
                ZStack {
                    // Rope bundle (tighter = more twists)
                    ForEach(0..<Int(4 + twists * 8), id: \.self) { i in
                        let offset = CGFloat(i) * 3 - CGFloat(Int(4 + twists * 8)) * 1.5
                        Path { p in p.move(to: CGPoint(x: cx + offset, y: h * 0.2)); p.addLine(to: CGPoint(x: cx + offset, y: h * 0.55)) }
                            .stroke(Color.brown.opacity(0.3 + twists * 0.3), lineWidth: 2)
                    }
                    // Tension meter
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3).fill(stoneGray.opacity(0.15)).frame(width: w * 0.5, height: 16)
                        RoundedRectangle(cornerRadius: 3).fill(isDangerous ? RenaissanceColors.errorRed : color)
                            .frame(width: w * 0.5 * twists, height: 16)
                    }.position(x: cx, y: h * 0.65)
                    Text("\(power)× power").font(.custom("EBGaramond-Bold", size: 16)).foregroundStyle(isDangerous ? RenaissanceColors.errorRed : sepiaInk).position(x: cx, y: h * 0.12)
                    if isDangerous { Text("⚠️ SNAP RISK").font(.custom("Cinzel-Bold", size: 16)).foregroundStyle(RenaissanceColors.errorRed).position(x: cx, y: h * 0.22) }
                    if step >= 2 {
                        Slider(value: $twists, in: 0.1...0.95).tint(isDangerous ? RenaissanceColors.errorRed : color).frame(width: w * 0.5).position(x: cx, y: h * 0.78)
                            .onChange(of: twists) { _, v in if v > 0.7 { withAnimation { step = 3 } } }
                    }
                    if step >= 3 { FormulaText(text: "2× twists = 4× power (square law)", highlighted: true, fontSize: 15).position(x: cx, y: h * 0.88).transition(.opacity) }
                }
            }
        }
    }
}

// MARK: - 4. Battering Ram — Swing Rhythm

private struct BatteringRamVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    @State private var swingCount: Int = 0
    @State private var swingPhase: CGFloat = 0

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                         stepLabel: swingCount < 5 ? "Tap to swing — rhythm accumulates energy. (\(swingCount)/5)" : "10 swings = force of 30 men.", height: height) {
            GeometryReader { geo in
                let w = geo.size.width; let h = geo.size.height; let cx = w * 0.5
                let pivotY = h * 0.2; let ramLen = w * 0.35; let swing = sin(swingPhase) * 0.3
                ZStack {
                    // Pivot frame
                    Path { p in
                        p.move(to: CGPoint(x: cx - 20, y: pivotY - 15))
                        p.addLine(to: CGPoint(x: cx, y: pivotY - 30))
                        p.addLine(to: CGPoint(x: cx + 20, y: pivotY - 15))
                    }.stroke(oakBrown, lineWidth: 2)
                    // Ram (pendulum)
                    Path { p in
                        p.move(to: CGPoint(x: cx, y: pivotY))
                        p.addLine(to: CGPoint(x: cx + ramLen * sin(swing), y: pivotY + ramLen * cos(swing)))
                    }.stroke(oakBrown, lineWidth: 5)
                    // Iron head
                    Circle().fill(ironDark).frame(width: 14, height: 14)
                        .position(x: cx + ramLen * sin(swing), y: pivotY + ramLen * cos(swing))
                    // Wall target
                    RoundedRectangle(cornerRadius: 2).fill(stoneGray).frame(width: 12, height: h * 0.35)
                        .position(x: w * 0.82, y: h * 0.5)
                    // Force counter
                    Text("Force: \(swingCount * 6) men").font(.custom("EBGaramond-Bold", size: 15)).foregroundStyle(sepiaInk).position(x: cx, y: h * 0.78)
                    // Tap area
                    if step >= 2 && swingCount < 5 {
                        Button {
                            swingCount += 1; SoundManager.shared.play(.tapSoft); HapticsManager.shared.play(.buttonTap)
                            withAnimation(.easeInOut(duration: 0.4)) { swingPhase += .pi }
                            if swingCount >= 5 { DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { withAnimation { step = 3 } } }
                        } label: {
                            Text("SWING").font(.custom("Cinzel-Bold", size: 16)).foregroundStyle(color)
                                .padding(.horizontal, 20).padding(.vertical, 10).background(color.opacity(0.1)).cornerRadius(8)
                        }.buttonStyle(.plain).position(x: cx, y: h * 0.9)
                    }
                    if step >= 3 { FormulaText(text: "Rhythm beats raw strength", highlighted: true, fontSize: 15).position(x: cx, y: h * 0.9).transition(.opacity) }
                }
            }
        }
    }
}

// MARK: - 5. Siege Tower — Build Levels

private struct SiegeTowerVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    @State private var levelsBuilt: Int = 0
    private let levels = ["Wheels", "Level 1", "Level 2", "Level 3", "Drawbridge", "Wet hide"]

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                         stepLabel: levelsBuilt < 6 ? "Tap to build level \(levelsBuilt + 1) — \(levels[levelsBuilt])." : "20m mobile fortress — assembled in the field.", height: height) {
            GeometryReader { geo in
                let w = geo.size.width; let h = geo.size.height; let cx = w * 0.5
                let floorH = h * 0.09; let towerW = w * 0.25; let baseY = h * 0.68
                ZStack {
                    // Enemy wall
                    RoundedRectangle(cornerRadius: 2).fill(stoneGray).frame(width: 10, height: h * 0.5).position(x: w * 0.82, y: h * 0.45)
                    Text("Wall").font(.custom("EBGaramond-Regular", size: 15)).foregroundStyle(sepiaInk.opacity(0.3)).position(x: w * 0.82, y: h * 0.15)
                    // Tower levels
                    ForEach(0..<levelsBuilt, id: \.self) { i in
                        let y = baseY - CGFloat(i) * floorH
                        if i == 0 { // Wheels
                            ForEach([-1.0, 1.0], id: \.self) { s in
                                Circle().strokeBorder(oakBrown, lineWidth: 1.5).frame(width: 10, height: 10)
                                    .position(x: cx + s * towerW * 0.4, y: y + 5)
                            }
                        } else if i == 4 { // Drawbridge
                            RoundedRectangle(cornerRadius: 1).fill(oakBrown).frame(width: towerW * 0.8, height: 4)
                                .position(x: cx + towerW * 0.4, y: y).rotationEffect(.degrees(-15), anchor: .leading)
                        } else if i == 5 { // Wet hide
                            RoundedRectangle(cornerRadius: 2).fill(Color.brown.opacity(0.2)).frame(width: towerW + 4, height: floorH * CGFloat(levelsBuilt - 1))
                                .position(x: cx, y: baseY - floorH * 2)
                        } else {
                            RoundedRectangle(cornerRadius: 2).fill(oakBrown.opacity(0.3)).frame(width: towerW, height: floorH - 2)
                                .overlay(RoundedRectangle(cornerRadius: 2).strokeBorder(oakBrown, lineWidth: 1))
                                .position(x: cx, y: y).transition(.move(edge: .bottom))
                        }
                    }
                    // Build button
                    if step >= 2 && levelsBuilt < 6 {
                        Button { withAnimation(.spring(response: 0.3)) { levelsBuilt += 1 }; SoundManager.shared.play(.tapSoft)
                            if levelsBuilt >= 6 { DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { withAnimation { step = 3 } } }
                        } label: { Text("Build \(levels[levelsBuilt])").font(.custom("EBGaramond-SemiBold", size: 15)).foregroundStyle(color)
                            .padding(.horizontal, 12).padding(.vertical, 6).background(color.opacity(0.1)).cornerRadius(6) }
                            .buttonStyle(.plain).position(x: cx, y: h * 0.88)
                    }
                    DimLabel(text: "20m", fontSize: 15).position(x: cx - towerW * 0.5 - 14, y: h * 0.4)
                    if step >= 3 { FormulaText(text: "Engineering under maximum pressure", highlighted: true, fontSize: 15).position(x: cx, y: h * 0.88).transition(.opacity) }
                }
            }
        }
    }
}

// MARK: - 6-13: Remaining visuals (compact)

private struct SiegeTilesVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1; @State private var temperature: CGFloat = 0
    private var tempC: Int { Int(temperature * 1200) }; private var vitrified: Bool { tempC >= 950 && tempC <= 1050 }
    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                         stepLabel: vitrified ? "Vitrified at 1,000°C — won't burn." : "Drag to 1,000°C — tiles become fire armor.", height: height) {
            GeometryReader { geo in let w = geo.size.width; let h = geo.size.height; let cx = w * 0.5
                ZStack {
                    RoundedRectangle(cornerRadius: 4).fill(vitrified ? RenaissanceColors.terracotta : RenaissanceColors.terracotta.opacity(0.3 + temperature * 0.5))
                        .frame(width: 60, height: 40).shadow(color: tempC > 800 ? .orange.opacity(0.3) : .clear, radius: 6).position(x: cx, y: h * 0.35)
                    Text("\(tempC)°C").font(.custom("EBGaramond-Bold", size: 16)).foregroundStyle(vitrified ? RenaissanceColors.sageGreen : sepiaInk).monospacedDigit().position(x: cx, y: h * 0.15)
                    if step >= 2 { Slider(value: $temperature, in: 0...1).tint(vitrified ? RenaissanceColors.sageGreen : .orange).frame(width: w*0.5).position(x: cx, y: h*0.65)
                        .onChange(of: temperature) { _, _ in if vitrified { withAnimation { step = 3 } } } }
                    if vitrified { FormulaText(text: "500 tiles × 2kg = 1 ton of fire armor", highlighted: true, fontSize: 15).position(x: cx, y: h*0.82) }
                }
            }
        }
    }
}

private struct BloomerySmelterVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1; @State private var temperature: CGFloat = 0
    private var tempC: Int { Int(temperature * 1500) }; private var isSmelting: Bool { tempC >= 1050 }
    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                         stepLabel: isSmelting ? "Spongy bloom — hammer to expel slag." : "Drag bellows to heat — 1,100°C smelts iron.", height: height) {
            GeometryReader { geo in let w = geo.size.width; let h = geo.size.height; let cx = w * 0.5
                ZStack {
                    RoundedRectangle(cornerRadius: 4).fill(isSmelting ? ironDark.opacity(0.8) : Color.brown.opacity(0.3 + temperature * 0.3))
                        .frame(width: 55, height: 40).shadow(color: tempC > 800 ? hotRed.opacity(0.3) : .clear, radius: 8).position(x: cx, y: h * 0.35)
                    Text("\(tempC)°C").font(.custom("EBGaramond-Bold", size: 16)).foregroundStyle(isSmelting ? RenaissanceColors.sageGreen : sepiaInk).monospacedDigit().position(x: cx, y: h * 0.15)
                    Text(isSmelting ? "Iron bloom" : tempC > 600 ? "Heating..." : "Iron ore").font(.custom("EBGaramond-Regular", size: 15)).foregroundStyle(sepiaInk.opacity(0.6)).position(x: cx, y: h * 0.52)
                    if step >= 2 { Slider(value: $temperature, in: 0...1).tint(isSmelting ? RenaissanceColors.sageGreen : .orange).frame(width: w*0.5).position(x: cx, y: h*0.68)
                        .onChange(of: temperature) { _, _ in if isSmelting { withAnimation { step = 3 } } } }
                    if isSmelting { FormulaText(text: "10 folds = 1,024 layers", highlighted: true, fontSize: 15).position(x: cx, y: h*0.85) }
                }
            }
        }
    }
}

private struct BronzeGearVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1; @State private var copperAdded = false; @State private var tinAdded = false
    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                         stepLabel: !copperAdded ? "Tap copper first (90%)." : !tinAdded ? "Now add tin (10%)." : "Lost-wax casting — one model, one perfect gear.", height: height) {
            GeometryReader { geo in let w = geo.size.width; let h = geo.size.height; let cx = w * 0.5
                ZStack {
                    // Gear shape
                    Circle().fill(copperAdded && tinAdded ? bronzeGold : stoneGray.opacity(0.2)).frame(width: 60, height: 60).position(x: cx, y: h * 0.35)
                    if copperAdded && tinAdded {
                        ForEach(0..<8, id: \.self) { i in
                            let a = CGFloat(i) / 8.0 * .pi * 2
                            RoundedRectangle(cornerRadius: 1).fill(bronzeGold).frame(width: 8, height: 10)
                                .position(x: cx + 35 * cos(a), y: h * 0.35 + 35 * sin(a)).rotationEffect(.radians(Double(a)))
                        }
                    }
                    HStack(spacing: 16) {
                        Button { guard !copperAdded else { return }; withAnimation(.spring(response: 0.3)) { copperAdded = true }; SoundManager.shared.play(.tapSoft) } label: {
                            VStack { Text("90%").font(.custom("EBGaramond-Bold", size: 15)); Text("Copper").font(.custom("EBGaramond-Regular", size: 15)) }
                                .frame(width: 55, height: 40).background(copperAdded ? stoneGray.opacity(0.1) : Color(red: 0.80, green: 0.55, blue: 0.35).opacity(0.2)).cornerRadius(6)
                                .overlay(RoundedRectangle(cornerRadius: 6).stroke(!copperAdded ? color : stoneGray.opacity(0.2), lineWidth: !copperAdded ? 2 : 0.5))
                        }.buttonStyle(.plain).opacity(copperAdded ? 0.4 : 1).foregroundStyle(sepiaInk)
                        Button { guard copperAdded && !tinAdded else { return }; withAnimation(.spring(response: 0.3)) { tinAdded = true }; SoundManager.shared.play(.tapSoft)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { withAnimation { step = 3 } }
                        } label: {
                            VStack { Text("10%").font(.custom("EBGaramond-Bold", size: 15)); Text("Tin").font(.custom("EBGaramond-Regular", size: 15)) }
                                .frame(width: 55, height: 40).background(tinAdded ? stoneGray.opacity(0.1) : stoneGray.opacity(0.15)).cornerRadius(6)
                                .overlay(RoundedRectangle(cornerRadius: 6).stroke(copperAdded && !tinAdded ? color : stoneGray.opacity(0.2), lineWidth: copperAdded && !tinAdded ? 2 : 0.5))
                        }.buttonStyle(.plain).opacity(tinAdded ? 0.4 : 1).foregroundStyle(sepiaInk)
                    }.position(x: cx, y: h * 0.65)
                    if step >= 3 { FormulaText(text: "Precision starts in wax", highlighted: true, fontSize: 15).position(x: cx, y: h * 0.85).transition(.opacity) }
                }
            }
        }
    }
}

private struct WetDryWoodVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1; @State private var tested = false
    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                         stepLabel: !tested ? "Tap to test — which ram survives impact?" : "Wet wood flexes and bounces. Dry wood shatters.", height: height) {
            GeometryReader { geo in let w = geo.size.width; let h = geo.size.height
                ZStack {
                    HStack(spacing: w * 0.06) {
                        VStack(spacing: 4) {
                            Text("SOAKED").font(.custom("Cinzel-Bold", size: 16)).foregroundStyle(sepiaInk.opacity(0.5))
                            RoundedRectangle(cornerRadius: 4).fill(oakBrown.opacity(0.7)).frame(width: w*0.25, height: h*0.2)
                                .overlay { if tested { Image(systemName: "checkmark").foregroundStyle(RenaissanceColors.sageGreen) } }
                            if tested { Text("Flexes").font(.custom("EBGaramond-Bold", size: 15)).foregroundStyle(RenaissanceColors.sageGreen) }
                        }
                        VStack(spacing: 4) {
                            Text("DRY").font(.custom("Cinzel-Bold", size: 16)).foregroundStyle(sepiaInk.opacity(0.5))
                            ZStack {
                                RoundedRectangle(cornerRadius: 4).fill(oakBrown.opacity(tested ? 0.3 : 0.5)).frame(width: w*0.25, height: h*0.2)
                                if tested { ForEach(0..<3, id: \.self) { i in
                                    Path { p in p.move(to: CGPoint(x: CGFloat(i*20+5), y: 3)); p.addLine(to: CGPoint(x: CGFloat(i*15+8), y: h*0.2-3)) }
                                        .stroke(RenaissanceColors.errorRed.opacity(0.5), lineWidth: 1).frame(width: w*0.25, height: h*0.2) } }
                            }
                            if tested { Text("Shatters").font(.custom("EBGaramond-Bold", size: 15)).foregroundStyle(RenaissanceColors.errorRed) }
                        }
                    }.position(x: w * 0.5, y: h * 0.4)
                    if step >= 2 && !tested {
                        Button { withAnimation(.spring(response: 0.3)) { tested = true }; SoundManager.shared.play(.tapSoft)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { withAnimation { step = 3 } }
                        } label: { HStack(spacing: 4) { Image(systemName: "hammer.fill").font(.system(size: 13)); Text("Impact Test").font(.custom("EBGaramond-SemiBold", size: 15)) }
                            .foregroundStyle(color).padding(.horizontal, 12).padding(.vertical, 6).background(color.opacity(0.1)).cornerRadius(6) }
                            .buttonStyle(.plain).position(x: w * 0.5, y: h * 0.75)
                    }
                    if step >= 3 { FormulaText(text: "Wet absorbs shock — dry transfers it", highlighted: true, fontSize: 15).position(x: w*0.5, y: h*0.85).transition(.opacity) }
                }
            }
        }
    }
}

private struct GreenOakVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1; @State private var tested = false
    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                         stepLabel: !tested ? "Tap to compare — green vs dry oak frames." : "Green frame lasts 10× longer — flexibility wins.", height: height) {
            GeometryReader { geo in let w = geo.size.width; let h = geo.size.height
                ZStack {
                    HStack(spacing: w * 0.06) {
                        VStack(spacing: 4) {
                            Text("GREEN OAK").font(.custom("Cinzel-Bold", size: 16)).foregroundStyle(sepiaInk.opacity(0.5))
                            RoundedRectangle(cornerRadius: 4).fill(RenaissanceColors.sageGreen.opacity(0.3)).frame(width: w*0.25, height: h*0.2)
                            Text("500 shots").font(.custom("EBGaramond-Bold", size: 15)).foregroundStyle(RenaissanceColors.sageGreen)
                            Text("Flexible").font(.custom("EBGaramond-Regular", size: 15)).foregroundStyle(sepiaInk.opacity(0.4))
                        }
                        VStack(spacing: 4) {
                            Text("DRY OAK").font(.custom("Cinzel-Bold", size: 16)).foregroundStyle(sepiaInk.opacity(0.5))
                            RoundedRectangle(cornerRadius: 4).fill(oakBrown.opacity(0.3)).frame(width: w*0.25, height: h*0.2)
                            Text("50 shots").font(.custom("EBGaramond-Bold", size: 15)).foregroundStyle(RenaissanceColors.errorRed)
                            Text("Brittle").font(.custom("EBGaramond-Regular", size: 15)).foregroundStyle(sepiaInk.opacity(0.4))
                        }
                    }.position(x: w * 0.5, y: h * 0.4)
                    if step >= 2 { FormulaText(text: "10× lifespan — moisture = flexibility", highlighted: true, fontSize: 15).position(x: w*0.5, y: h*0.75) }
                }
            }
        }
    }
}

private struct WalnutPrecisionVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1; @State private var tested = false
    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                         stepLabel: !tested ? "Tap to compare — walnut vs other woods for mechanisms." : "Walnut: tight grain, no splinter, oil-resistant.", height: height) {
            GeometryReader { geo in let w = geo.size.width; let h = geo.size.height
                ZStack {
                    HStack(spacing: w * 0.06) {
                        VStack(spacing: 4) {
                            Text("WALNUT").font(.custom("Cinzel-Bold", size: 16)).foregroundStyle(sepiaInk.opacity(0.5))
                            RoundedRectangle(cornerRadius: 4).fill(Color(red: 0.45, green: 0.32, blue: 0.22)).frame(width: w*0.25, height: h*0.2)
                                .overlay { if tested { Image(systemName: "checkmark.circle.fill").foregroundStyle(RenaissanceColors.sageGreen) } }
                            if tested { Text("Stable").font(.custom("EBGaramond-Bold", size: 15)).foregroundStyle(RenaissanceColors.sageGreen) }
                        }
                        VStack(spacing: 4) {
                            Text("OTHER").font(.custom("Cinzel-Bold", size: 16)).foregroundStyle(sepiaInk.opacity(0.5))
                            RoundedRectangle(cornerRadius: 4).fill(oakBrown.opacity(0.3)).frame(width: w*0.25, height: h*0.2)
                                .overlay { if tested { Image(systemName: "xmark.circle.fill").foregroundStyle(RenaissanceColors.errorRed.opacity(0.5)) } }
                            if tested { Text("Swells").font(.custom("EBGaramond-Bold", size: 15)).foregroundStyle(RenaissanceColors.errorRed) }
                        }
                    }.position(x: w * 0.5, y: h * 0.38)
                    if step >= 2 && !tested {
                        Button { withAnimation(.spring(response: 0.3)) { tested = true }; SoundManager.shared.play(.tapSoft)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { withAnimation { step = 3 } }
                        } label: { Text("Oil Test").font(.custom("EBGaramond-SemiBold", size: 15)).foregroundStyle(color)
                            .padding(.horizontal, 14).padding(.vertical, 6).background(color.opacity(0.1)).cornerRadius(6) }
                            .buttonStyle(.plain).position(x: w * 0.5, y: h * 0.68)
                    }
                    if step >= 3 { FormulaText(text: "The wood that doesn't change = the one you trust", highlighted: true, fontSize: 15).position(x: w*0.5, y: h*0.85).transition(.opacity) }
                }
            }
        }
    }
}

private struct MilitaryJointsVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1; @State private var jointsRevealed: Int = 0
    private let joints = [("Mortise-and-tenon", "Peg in socket — strongest"), ("Dovetail", "Fan shape — pull-resistant"), ("Scarf", "End-to-end extension")]
    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                         stepLabel: jointsRevealed < 3 ? "Tap to reveal joint \(jointsRevealed + 1)." : "Onager assembled in 4 hours — no glue.", height: height) {
            GeometryReader { geo in let w = geo.size.width; let h = geo.size.height; let cx = w * 0.5
                ZStack {
                    ForEach(0..<3, id: \.self) { i in
                        let y = h * 0.2 + CGFloat(i) * h * 0.2
                        let revealed = i < jointsRevealed
                        HStack(spacing: 8) {
                            RoundedRectangle(cornerRadius: 3).fill(revealed ? oakBrown.opacity(0.4) : stoneGray.opacity(0.1))
                                .frame(width: w * 0.15, height: 18)
                            if revealed {
                                // Joint connection
                                RoundedRectangle(cornerRadius: 1).fill(oakBrown.opacity(0.6)).frame(width: 8, height: 12)
                            } else {
                                RoundedRectangle(cornerRadius: 1).strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [2,2]))
                                    .foregroundStyle(color.opacity(0.3)).frame(width: 8, height: 12)
                            }
                            RoundedRectangle(cornerRadius: 3).fill(revealed ? oakBrown.opacity(0.4) : stoneGray.opacity(0.1))
                                .frame(width: w * 0.15, height: 18)
                            if revealed {
                                VStack(alignment: .leading, spacing: 1) {
                                    Text(joints[i].0).font(.custom("Cinzel-Bold", size: 16)).foregroundStyle(sepiaInk)
                                    Text(joints[i].1).font(.custom("EBGaramond-Regular", size: 15)).foregroundStyle(sepiaInk.opacity(0.5))
                                }.transition(.opacity)
                            }
                        }.position(x: cx, y: y)
                            .onTapGesture {
                                guard step >= 2, i == jointsRevealed else { return }
                                withAnimation(.spring(response: 0.3)) { jointsRevealed += 1 }; SoundManager.shared.play(.tapSoft)
                                if jointsRevealed >= 3 { DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { withAnimation { step = 3 } } }
                            }
                    }
                    if step >= 3 { FormulaText(text: "Modularity before the word existed", highlighted: true, fontSize: 15).position(x: cx, y: h*0.85).transition(.opacity) }
                }
            }
        }
    }
}

private struct TemperingCycleVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1; @State private var phase: Int = 0 // 0=cold, 1=heated, 2=quenched, 3=tempered
    private let phases = [("Heat to 750°C", "Cherry red", hotRed), ("Oil quench", "Martensite — hard but brittle", ironDark), ("Reheat 300°C", "Straw yellow — tempered", Color(red: 0.80, green: 0.70, blue: 0.35))]
    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                         stepLabel: phase < 3 ? "Tap: \(phases[phase].0)." : "Hard enough to pierce, tough enough not to shatter.", height: height) {
            GeometryReader { geo in let w = geo.size.width; let h = geo.size.height; let cx = w * 0.5
                ZStack {
                    // Iron piece
                    RoundedRectangle(cornerRadius: 3).fill(phase == 0 ? ironDark : phase == 1 ? hotRed.opacity(0.7) : phase == 2 ? ironDark.opacity(0.9) : Color(red: 0.80, green: 0.70, blue: 0.35).opacity(0.5))
                        .frame(width: 60, height: 14).shadow(color: phase == 1 ? hotRed.opacity(0.4) : .clear, radius: 8).position(x: cx, y: h * 0.35)
                    // Phase indicators
                    HStack(spacing: 8) {
                        ForEach(0..<3, id: \.self) { i in
                            VStack(spacing: 2) {
                                Circle().fill(i < phase ? phases[i].2 : stoneGray.opacity(0.2)).frame(width: 10, height: 10)
                                Text(phases[i].0).font(.custom("EBGaramond-Regular", size: 15)).foregroundStyle(i < phase ? sepiaInk : sepiaInk.opacity(0.3))
                            }
                        }
                    }.position(x: cx, y: h * 0.55)
                    if step >= 2 && phase < 3 {
                        Button { withAnimation(.spring(response: 0.3)) { phase += 1 }; SoundManager.shared.play(.tapSoft)
                            if phase >= 3 { DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { withAnimation { step = 3 } } }
                        } label: { Text(phases[phase].0).font(.custom("EBGaramond-SemiBold", size: 15)).foregroundStyle(phases[phase].2)
                            .padding(.horizontal, 14).padding(.vertical, 6).background(phases[phase].2.opacity(0.1)).cornerRadius(6) }
                            .buttonStyle(.plain).position(x: cx, y: h * 0.75)
                    }
                    if step >= 3 { FormulaText(text: "Hard to pierce + tough not to shatter", highlighted: true, fontSize: 15).position(x: cx, y: h*0.88).transition(.opacity) }
                }
            }
        }
    }
}
