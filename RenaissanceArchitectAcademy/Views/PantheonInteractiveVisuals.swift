import SwiftUI

/// Interactive science visuals for Pantheon knowledge cards
/// Replaces passive Canvas drawings with drag/tap/slider interactions
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

// MARK: - Shared Styles

private let gridColor = Color.brown.opacity(0.06)
private let sepiaInk = Color(red: 0.29, green: 0.25, blue: 0.21)
private let waterBlue = Color(red: 0.35, green: 0.55, blue: 0.75)

private struct VisualTitle: View {
    let text: String
    let color: Color
    var body: some View {
        Text(text)
            .font(.custom("Cinzel-Bold", size: 12))
            .tracking(1)
            .foregroundStyle(color)
    }
}

private struct VisualCaption: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.custom("EBGaramond-Italic", size: 13))
            .foregroundStyle(sepiaInk.opacity(0.6))
            .multilineTextAlignment(.center)
    }
}

private struct PantheonBlueprintGrid: View {
    var body: some View {
        Canvas { context, size in
            let spacing: CGFloat = 15
            for x in stride(from: CGFloat(0), through: size.width, by: spacing) {
                var path = Path()
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
                context.stroke(path, with: .color(gridColor), lineWidth: 0.5)
            }
            for y in stride(from: CGFloat(0), through: size.height, by: spacing) {
                var path = Path()
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                context.stroke(path, with: .color(gridColor), lineWidth: 0.5)
            }
        }
    }
}

private struct VisualContainer<Content: View>: View {
    let title: String
    let color: Color
    let caption: String?
    var height: CGFloat = 275
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(spacing: 6) {
            VisualTitle(text: title, color: color)

            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(RenaissanceColors.parchment)
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(color.opacity(0.2), lineWidth: 1)
                PantheonBlueprintGrid()
                content()
                    .padding(12)
            }
            .frame(height: height)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            if let caption = caption {
                VisualCaption(text: caption)
            }
        }
    }
}

// MARK: - 1. Columns Count (Tap to count columns)

private struct ColumnsCountVisual: View {
    let visual: CardVisual
    let color: Color
    var height: CGFloat = 275
    @State private var tappedColumns: Set<Int> = []

    var body: some View {
        VisualContainer(title: visual.title, color: color, caption: visual.caption, height: height) {
            VStack(spacing: 8) {
                // Pediment
                PantheonTriangle()
                    .fill(color.opacity(0.08))
                    .stroke(sepiaInk.opacity(0.5), lineWidth: 1.5)
                    .frame(height: 30)
                    .padding(.horizontal, 20)

                // Entablature
                Rectangle()
                    .fill(sepiaInk.opacity(0.12))
                    .frame(height: 6)
                    .padding(.horizontal, 14)

                // 8 columns (representing 16 — tap to count)
                HStack(spacing: 6) {
                    ForEach(0..<8, id: \.self) { i in
                        VStack(spacing: 0) {
                            // Capital
                            Rectangle()
                                .fill(sepiaInk.opacity(0.15))
                                .frame(width: 16, height: 5)
                            // Shaft
                            Rectangle()
                                .fill(tappedColumns.contains(i) ? color.opacity(0.3) : sepiaInk.opacity(0.08))
                                .frame(width: 8, height: 80)
                                .overlay(
                                    Rectangle().stroke(
                                        tappedColumns.contains(i) ? color : sepiaInk.opacity(0.4),
                                        lineWidth: tappedColumns.contains(i) ? 2 : 1
                                    )
                                )
                            // Base
                            Rectangle()
                                .fill(sepiaInk.opacity(0.1))
                                .frame(width: 16, height: 4)
                        }
                        .onTapGesture {
                            withAnimation(.easeOut(duration: 0.2)) {
                                if tappedColumns.contains(i) {
                                    tappedColumns.remove(i)
                                } else {
                                    tappedColumns.insert(i)
                                }
                            }
                            SoundManager.shared.play(.tapSoft)
                        }
                    }
                }

                // Floor line
                Rectangle()
                    .fill(sepiaInk.opacity(0.3))
                    .frame(height: 1)

                // Counter
                HStack(spacing: 4) {
                    Text("Tapped: \(tappedColumns.count) × 2 = \(tappedColumns.count * 2) columns")
                        .font(.custom("EBGaramond-SemiBold", size: 12))
                        .foregroundStyle(tappedColumns.count == 8 ? RenaissanceColors.sageGreen : color)

                    if tappedColumns.count == 8 {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(RenaissanceColors.sageGreen)
                            .font(.system(size: 14))
                    }
                }
                .padding(.top, 2)

                Text("Tap each column to count — 8 visible × 2 rows = 16 total")
                    .font(.custom("EBGaramond-Italic", size: 10))
                    .foregroundStyle(sepiaInk.opacity(0.5))
            }
        }
    }
}

private struct PantheonTriangle: Shape {
    func path(in rect: CGRect) -> Path {
        Path { p in
            p.move(to: CGPoint(x: rect.midX, y: rect.minY))
            p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            p.closeSubpath()
        }
    }
}

// MARK: - 2. Ring Foundation (Tap to dig layers)

private struct LayerDigVisual: View {
    let visual: CardVisual
    let color: Color
    var height: CGFloat = 275
    @State private var revealedLayers: Int = 0

    private let layers = [
        ("Ground surface", Color.brown.opacity(0.3)),
        ("Soft Roman clay", Color(red: 0.7, green: 0.55, blue: 0.35)),
        ("Trench dug 4.5m", Color(red: 0.5, green: 0.4, blue: 0.3)),
        ("Concrete ring (7.3m wide)", Color(red: 0.6, green: 0.6, blue: 0.6)),
    ]

    var body: some View {
        VisualContainer(title: visual.title, color: color, caption: visual.caption, height: height) {
            VStack(spacing: 0) {
                // Layers stack
                ForEach(0..<layers.count, id: \.self) { i in
                    let (name, layerColor) = layers[i]
                    let revealed = i < revealedLayers

                    ZStack {
                        Rectangle()
                            .fill(revealed ? layerColor : sepiaInk.opacity(0.04))
                            .overlay(
                                Rectangle().stroke(sepiaInk.opacity(revealed ? 0.3 : 0.08), lineWidth: 1)
                            )

                        if revealed {
                            HStack {
                                Text(name)
                                    .font(.custom("EBGaramond-SemiBold", size: 11))
                                    .foregroundStyle(.white)
                                    .shadow(color: .black.opacity(0.5), radius: 2)
                                Spacer()
                                if i == 3 {
                                    Text("7.3m")
                                        .font(.custom("EBGaramond-Bold", size: 12))
                                        .foregroundStyle(color)
                                        .shadow(color: .black.opacity(0.3), radius: 1)
                                }
                            }
                            .padding(.horizontal, 8)
                        } else {
                            HStack {
                                Image(systemName: "hand.tap.fill")
                                    .font(.system(size: 14))
                                    .foregroundStyle(sepiaInk.opacity(0.2))
                                Text("Tap to dig")
                                    .font(.custom("EBGaramond-Italic", size: 11))
                                    .foregroundStyle(sepiaInk.opacity(0.3))
                            }
                        }
                    }
                    .frame(height: 42)
                    .onTapGesture {
                        if i == revealedLayers {
                            withAnimation(.spring(response: 0.3)) {
                                revealedLayers += 1
                            }
                            SoundManager.shared.play(.tapSoft)
                        }
                    }
                }

                // Depth dimension
                HStack {
                    Spacer()
                    Text("Depth: \(String(format: "%.1f", 4.5 * Double(min(revealedLayers, 4)) / 4.0))m")
                        .font(.custom("EBGaramond-SemiBold", size: 12))
                        .foregroundStyle(color)
                }
                .padding(.top, 4)
            }
        }
    }
}

// MARK: - 3. Rotunda Walls (Cross-section showing 6m walls + 8 piers + dome)

private struct SphereSliderVisual: View {
    let visual: CardVisual
    let color: Color
    var height: CGFloat = 275
    @State private var revealedPiers: Int = 0
    @State private var showDome = false

    var body: some View {
        VisualContainer(title: "Cross-Section: 6m Walls with 8 Piers", color: color, caption: visual.caption, height: height) {
            VStack(spacing: 6) {
                GeometryReader { geo in
                    let w = geo.size.width
                    let h = geo.size.height
                    let centerX = w / 2
                    let baseY = h * 0.82
                    let wallH = h * 0.55
                    let wallW: CGFloat = 24   // 6m thick walls (visual width)
                    let innerW = w * 0.55      // Interior space
                    let domeH = wallH * 0.7

                    ZStack {
                        // Floor line
                        Path { p in
                            p.move(to: CGPoint(x: centerX - innerW / 2 - wallW - 10, y: baseY))
                            p.addLine(to: CGPoint(x: centerX + innerW / 2 + wallW + 10, y: baseY))
                        }
                        .stroke(sepiaInk.opacity(0.3), lineWidth: 1.5)

                        // Left wall (6m thick)
                        Rectangle()
                            .fill(color.opacity(0.15))
                            .frame(width: wallW, height: wallH)
                            .overlay(Rectangle().stroke(sepiaInk.opacity(0.5), lineWidth: 1.5))
                            .position(x: centerX - innerW / 2 - wallW / 2, y: baseY - wallH / 2)

                        // Right wall (6m thick)
                        Rectangle()
                            .fill(color.opacity(0.15))
                            .frame(width: wallW, height: wallH)
                            .overlay(Rectangle().stroke(sepiaInk.opacity(0.5), lineWidth: 1.5))
                            .position(x: centerX + innerW / 2 + wallW / 2, y: baseY - wallH / 2)

                        // "6m" wall thickness labels
                        Text("6m")
                            .font(.custom("EBGaramond-Bold", size: 13))
                            .foregroundStyle(color)
                            .position(x: centerX - innerW / 2 - wallW / 2, y: baseY - wallH - 8)
                        Text("6m")
                            .font(.custom("EBGaramond-Bold", size: 13))
                            .foregroundStyle(color)
                            .position(x: centerX + innerW / 2 + wallW / 2, y: baseY - wallH - 8)

                        // 8 Piers (tap to reveal) — shown as thick vertical bars inside the walls
                        let pierCount = 8
                        let pierSpacing = innerW / CGFloat(pierCount + 1)
                        ForEach(0..<pierCount, id: \.self) { i in
                            let pierX = centerX - innerW / 2 + pierSpacing * CGFloat(i + 1)
                            let revealed = i < revealedPiers

                            Rectangle()
                                .fill(revealed ? color.opacity(0.25) : sepiaInk.opacity(0.04))
                                .frame(width: 10, height: wallH * 0.8)
                                .overlay(
                                    Rectangle().stroke(
                                        revealed ? color.opacity(0.6) : sepiaInk.opacity(0.1),
                                        lineWidth: revealed ? 1.5 : 0.5
                                    )
                                )
                                .position(x: pierX, y: baseY - wallH * 0.4)
                                .onTapGesture {
                                    if i == revealedPiers {
                                        withAnimation(.spring(response: 0.3)) {
                                            revealedPiers += 1
                                        }
                                        SoundManager.shared.play(.tapSoft)
                                        if revealedPiers == pierCount {
                                            withAnimation(.spring(response: 0.5).delay(0.3)) {
                                                showDome = true
                                            }
                                        }
                                    }
                                }

                            // Down arrow on revealed piers (weight channeling)
                            if revealed {
                                Image(systemName: "arrow.down")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(Color.red.opacity(0.4))
                                    .position(x: pierX, y: baseY - wallH * 0.85)
                            }
                        }

                        // Dome appears after all 8 piers revealed
                        if showDome {
                            Path { p in
                                p.move(to: CGPoint(x: centerX - innerW / 2 - wallW, y: baseY - wallH))
                                p.addQuadCurve(
                                    to: CGPoint(x: centerX + innerW / 2 + wallW, y: baseY - wallH),
                                    control: CGPoint(x: centerX, y: baseY - wallH - domeH)
                                )
                            }
                            .stroke(sepiaInk, lineWidth: 2)

                            Text("43.3m dome")
                                .font(.custom("EBGaramond-SemiBold", size: 11))
                                .foregroundStyle(color)
                                .position(x: centerX, y: baseY - wallH - domeH * 0.4)
                        }

                        // Interior width label
                        Path { p in
                            p.move(to: CGPoint(x: centerX - innerW / 2, y: baseY + 8))
                            p.addLine(to: CGPoint(x: centerX + innerW / 2, y: baseY + 8))
                        }
                        .stroke(sepiaInk.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [4, 3]))

                        Text("43.3m interior")
                            .font(.custom("EBGaramond-Regular", size: 10))
                            .foregroundStyle(sepiaInk.opacity(0.5))
                            .position(x: centerX, y: baseY + 20)
                    }
                }

                // Counter + instruction
                HStack {
                    Text("Piers found: \(revealedPiers)/8")
                        .font(.custom("EBGaramond-SemiBold", size: 13))
                        .foregroundStyle(revealedPiers == 8 ? RenaissanceColors.sageGreen : color)
                    if revealedPiers == 8 {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(RenaissanceColors.sageGreen)
                    }
                    Spacer()
                    Text(revealedPiers == 0 ? "Tap piers inside the walls" : revealedPiers < 8 ? "Keep tapping!" : "Dome supported!")
                        .font(.custom("EBGaramond-Italic", size: 11))
                        .foregroundStyle(sepiaInk.opacity(0.5))
                }
            }
        }
    }
}

// MARK: - 4. Coffers (Slider removes weight — dome walls visually thin)

private struct CofferTapVisual: View {
    let visual: CardVisual
    let color: Color
    var height: CGFloat = 275
    @State private var cofferProgress: CGFloat = 0  // 0 = solid dome, 1 = all coffers carved

    private var removedWeight: Int { Int(cofferProgress * 2400) }
    private var remainingWeight: Int { 6935 - removedWeight }

    var body: some View {
        VisualContainer(title: visual.title, color: color, caption: visual.caption, height: height) {
            VStack(spacing: 8) {
                // Weight counter
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Dome weight")
                            .font(.custom("EBGaramond-Regular", size: 11))
                            .foregroundStyle(sepiaInk.opacity(0.5))
                        Text("\(remainingWeight) tons")
                            .font(.custom("EBGaramond-Bold", size: 18))
                            .foregroundStyle(sepiaInk)
                    }
                    Spacer()
                    if removedWeight > 0 {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("Removed")
                                .font(.custom("EBGaramond-Regular", size: 11))
                                .foregroundStyle(color.opacity(0.7))
                            Text("–\(removedWeight) tons")
                                .font(.custom("EBGaramond-Bold", size: 18))
                                .foregroundStyle(color)
                        }
                    }
                }

                // Dome cross-section — walls thin as coffers are carved
                GeometryReader { geo in
                    let w = geo.size.width
                    let h = geo.size.height
                    let centerX = w / 2
                    let baseY = h * 0.88
                    let outerR = min(w * 0.42, h * 0.8)
                    // Inner radius grows as coffers are carved (wall gets thinner)
                    let wallThickness = outerR * (0.22 - cofferProgress * 0.12) // 22% → 10% thickness
                    let innerR = outerR - outerR * wallThickness / outerR * 3

                    ZStack {
                        // Outer dome arc
                        Path { p in
                            p.addArc(center: CGPoint(x: centerX, y: baseY),
                                     radius: outerR,
                                     startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
                            p.closeSubpath()
                        }
                        .fill(color.opacity(0.12))
                        .overlay(
                            Path { p in
                                p.addArc(center: CGPoint(x: centerX, y: baseY),
                                         radius: outerR,
                                         startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
                            }
                            .stroke(sepiaInk, lineWidth: 2)
                        )

                        // Inner dome arc (shows hollow space from coffers)
                        if cofferProgress > 0.05 {
                            Path { p in
                                p.addArc(center: CGPoint(x: centerX, y: baseY),
                                         radius: innerR,
                                         startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
                                p.closeSubpath()
                            }
                            .fill(RenaissanceColors.parchment)
                            .overlay(
                                Path { p in
                                    p.addArc(center: CGPoint(x: centerX, y: baseY),
                                             radius: innerR,
                                             startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
                                }
                                .stroke(color.opacity(0.4), style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
                            )
                        }

                        // Coffer grid pattern (visible between inner and outer arcs)
                        if cofferProgress > 0.1 {
                            let rows = Int(cofferProgress * 5) + 1
                            ForEach(0..<rows, id: \.self) { row in
                                let t = CGFloat(row + 1) / CGFloat(rows + 1)
                                let arcR = innerR + (outerR - innerR) * 0.5
                                let cofferCount = max(3, 7 - row)
                                ForEach(0..<cofferCount, id: \.self) { col in
                                    let angle = Double.pi - (Double(col) + 0.5) / Double(cofferCount) * Double.pi
                                    let cx = centerX + arcR * cos(angle) * t + arcR * cos(angle) * (1 - t)
                                    let cy = baseY + arcR * sin(angle)
                                    let size: CGFloat = max(8, outerR * 0.08)

                                    Rectangle()
                                        .stroke(color.opacity(0.3), lineWidth: 0.8)
                                        .frame(width: size, height: size)
                                        .position(x: cx, y: cy)
                                }
                            }
                        }

                        // Oculus at top
                        let oculusR: CGFloat = outerR * 0.08
                        Circle()
                            .fill(.white)
                            .frame(width: oculusR * 2, height: oculusR * 2)
                            .overlay(Circle().stroke(sepiaInk.opacity(0.4), lineWidth: 1))
                            .position(x: centerX, y: baseY - outerR)

                        // Floor
                        Path { p in
                            p.move(to: CGPoint(x: centerX - outerR - 8, y: baseY))
                            p.addLine(to: CGPoint(x: centerX + outerR + 8, y: baseY))
                        }
                        .stroke(sepiaInk.opacity(0.3), lineWidth: 1.5)

                        // "28 rows" label
                        if cofferProgress > 0.3 {
                            Text("28 rows of coffers")
                                .font(.custom("EBGaramond-Italic", size: 11))
                                .foregroundStyle(color.opacity(0.6))
                                .position(x: centerX, y: baseY - outerR * 0.45)
                        }
                    }
                }

                // Slider — "Carve coffers"
                VStack(spacing: 2) {
                    HStack {
                        Text("Solid dome")
                            .font(.custom("EBGaramond-Regular", size: 10))
                            .foregroundStyle(sepiaInk.opacity(0.4))
                        Spacer()
                        Text(cofferProgress < 0.1 ? "Drag to carve coffers →" : cofferProgress > 0.9 ? "All 28 rows carved!" : "Carving coffers...")
                            .font(.custom("EBGaramond-Italic", size: 11))
                            .foregroundStyle(cofferProgress > 0.9 ? RenaissanceColors.sageGreen : color)
                        Spacer()
                        Text("All coffers")
                            .font(.custom("EBGaramond-Regular", size: 10))
                            .foregroundStyle(sepiaInk.opacity(0.4))
                    }
                    Slider(value: $cofferProgress, in: 0...1)
                        .tint(cofferProgress > 0.9 ? RenaissanceColors.sageGreen : color)
                }
            }
        }
    }
}

// MARK: - 5. Oculus Compression (Tap arrows)

private struct OculusCompressionVisual: View {
    let visual: CardVisual
    let color: Color
    var height: CGFloat = 275
    @State private var showCompression = false

    var body: some View {
        VisualContainer(title: visual.title, color: color, caption: visual.caption, height: height) {
            VStack(spacing: 8) {
                GeometryReader { geo in
                    let w = geo.size.width
                    let h = geo.size.height
                    let centerX = w / 2
                    let baseY = h * 0.85
                    let radius = min(w * 0.4, h * 0.75)

                    ZStack {
                        // Dome arc
                        Path { p in
                            p.addArc(center: CGPoint(x: centerX, y: baseY),
                                     radius: radius,
                                     startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
                        }
                        .fill(color.opacity(0.04))
                        .overlay(
                            Path { p in
                                p.addArc(center: CGPoint(x: centerX, y: baseY),
                                         radius: radius,
                                         startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
                            }
                            .stroke(sepiaInk, lineWidth: 2.5)
                        )

                        // Oculus opening (white hole)
                        let oculusR: CGFloat = radius * 0.18
                        let oculusY = baseY - radius

                        Circle()
                            .fill(.white)
                            .frame(width: oculusR * 2, height: oculusR * 2)
                            .overlay(Circle().stroke(sepiaInk, lineWidth: 2))
                            .position(x: centerX, y: oculusY)

                        Text("9m")
                            .font(.custom("EBGaramond-Bold", size: 14))
                            .foregroundStyle(color)
                            .position(x: centerX, y: oculusY)

                        // Compression arrows (appear on tap)
                        if showCompression {
                            ForEach(0..<8, id: \.self) { i in
                                let angle = Double(i) / 8.0 * 2 * Double.pi - Double.pi / 2
                                let outerR = oculusR * 2.5
                                let arrowX = centerX + outerR * cos(angle)
                                let arrowY = oculusY + outerR * sin(angle)

                                Image(systemName: "arrow.right")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(Color.orange.opacity(0.8))
                                    .rotationEffect(.radians(angle + .pi))
                                    .position(x: arrowX, y: arrowY)
                                    .transition(.scale.combined(with: .opacity))
                            }

                            Text("compression")
                                .font(.custom("EBGaramond-Italic", size: 11))
                                .foregroundStyle(Color.orange.opacity(0.7))
                                .position(x: centerX, y: oculusY + oculusR * 2)
                        }
                    }
                    .onTapGesture {
                        withAnimation(.spring(response: 0.4)) {
                            showCompression.toggle()
                        }
                        SoundManager.shared.play(.tapSoft)
                    }
                }
                .frame(height: 160)

                Text(showCompression ? "The hole creates INWARD compression — making the dome stronger!" : "Tap the dome to see compression forces")
                    .font(.custom("EBGaramond-Italic", size: 11))
                    .foregroundStyle(showCompression ? color : sepiaInk.opacity(0.5))
                    .multilineTextAlignment(.center)
            }
        }
    }
}

// MARK: - 6. Limestone vs Marble (Heat transform slider)

private struct HeatTransformVisual: View {
    let visual: CardVisual
    let color: Color
    var height: CGFloat = 275
    @State private var heatLevel: CGFloat = 0

    var body: some View {
        VisualContainer(title: visual.title, color: color, caption: visual.caption, height: height) {
            VStack(spacing: 10) {
                HStack(spacing: 20) {
                    // Left: limestone/marble
                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(
                                red: 0.85 + Double(heatLevel) * 0.1,
                                green: 0.82 - Double(heatLevel) * 0.1,
                                blue: 0.78 - Double(heatLevel) * 0.15
                            ))
                            .frame(width: 80, height: 80)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(sepiaInk.opacity(0.3), lineWidth: 1)
                            )
                        Text(heatLevel < 0.5 ? "Limestone" : "Marble")
                            .font(.custom("EBGaramond-SemiBold", size: 13))
                            .foregroundStyle(sepiaInk)
                        Text("CaCO₃")
                            .font(.custom("EBGaramond-Italic", size: 11))
                            .foregroundStyle(color)
                    }

                    // Arrow
                    VStack(spacing: 2) {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 20))
                            .foregroundStyle(color)
                        Text("heat +\npressure")
                            .font(.custom("EBGaramond-Italic", size: 9))
                            .foregroundStyle(color.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }

                    // Right: result
                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(heatLevel > 0.5
                                  ? Color(red: 0.95, green: 0.93, blue: 0.9)
                                  : Color(red: 0.85, green: 0.82, blue: 0.78))
                            .frame(width: 80, height: 80)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(sepiaInk.opacity(0.3), lineWidth: 1)
                            )
                            .overlay(
                                // Crystal pattern when transformed
                                heatLevel > 0.5 ?
                                    AnyView(
                                        ForEach(0..<5, id: \.self) { i in
                                            Rectangle()
                                                .fill(Color.white.opacity(0.3))
                                                .frame(width: 2, height: 20)
                                                .rotationEffect(.degrees(Double(i) * 36))
                                        }
                                    ) : AnyView(EmptyView())
                            )
                        Text(heatLevel > 0.5 ? "Marble" : "Limestone")
                            .font(.custom("EBGaramond-SemiBold", size: 13))
                            .foregroundStyle(sepiaInk)
                        Text(heatLevel > 0.5 ? "Crystallized" : "Sedimentary")
                            .font(.custom("EBGaramond-Italic", size: 11))
                            .foregroundStyle(color)
                    }
                }

                // Heat slider
                VStack(spacing: 2) {
                    HStack {
                        Text("Room temp")
                            .font(.custom("EBGaramond-Regular", size: 10))
                            .foregroundStyle(sepiaInk.opacity(0.4))
                        Spacer()
                        Text(heatLevel > 0.5 ? "Same formula, transformed!" : "Drag to heat →")
                            .font(.custom("EBGaramond-Italic", size: 10))
                            .foregroundStyle(heatLevel > 0.5 ? RenaissanceColors.sageGreen : sepiaInk.opacity(0.5))
                        Spacer()
                        Text("200°C + pressure")
                            .font(.custom("EBGaramond-Regular", size: 10))
                            .foregroundStyle(sepiaInk.opacity(0.4))
                    }
                    Slider(value: $heatLevel, in: 0...1)
                        .tint(Color(red: 0.8 * Double(heatLevel) + 0.3, green: 0.3, blue: 0.2))
                }
            }
        }
    }
}

// MARK: - 7. Timeline Aging (Roman vs Modern concrete)

private struct TimelineAgingVisual: View {
    let visual: CardVisual
    let color: Color
    var height: CGFloat = 275
    @State private var years: CGFloat = 0

    var body: some View {
        VisualContainer(title: visual.title, color: color, caption: visual.caption, height: height) {
            VStack(spacing: 10) {
                HStack(spacing: 16) {
                    // Roman concrete
                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color(red: 0.6, green: 0.55, blue: 0.5).opacity(0.5 + Double(years) * 0.5))
                            .frame(width: 90, height: 70)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(sepiaInk.opacity(0.4), lineWidth: 1.5)
                            )
                        Text("Roman")
                            .font(.custom("EBGaramond-SemiBold", size: 12))
                            .foregroundStyle(sepiaInk)
                        Text(years > 0.5 ? "STRONGER" : "Pozzolana + lime")
                            .font(.custom("EBGaramond-Italic", size: 10))
                            .foregroundStyle(years > 0.5 ? RenaissanceColors.sageGreen : sepiaInk.opacity(0.5))
                    }

                    // Modern concrete
                    VStack(spacing: 4) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.gray.opacity(max(0.1, 0.6 - Double(years) * 0.5)))
                                .frame(width: 90, height: 70)

                            // Cracks appear over time
                            if years > 0.4 {
                                Path { p in
                                    p.move(to: CGPoint(x: 20, y: 15))
                                    p.addLine(to: CGPoint(x: 50, y: 35))
                                    p.addLine(to: CGPoint(x: 70, y: 55))
                                }
                                .stroke(Color.red.opacity(Double(years) * 0.5), lineWidth: 1.5)
                                .frame(width: 90, height: 70)
                            }
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(sepiaInk.opacity(0.3), lineWidth: 1)
                                .frame(width: 90, height: 70)
                        )
                        Text("Modern")
                            .font(.custom("EBGaramond-SemiBold", size: 12))
                            .foregroundStyle(sepiaInk)
                        Text(years > 0.5 ? "CRACKING" : "Portland cement")
                            .font(.custom("EBGaramond-Italic", size: 10))
                            .foregroundStyle(years > 0.5 ? Color.red.opacity(0.7) : sepiaInk.opacity(0.5))
                    }
                }

                // Timeline slider
                VStack(spacing: 2) {
                    HStack {
                        Text("Year 0")
                            .font(.custom("EBGaramond-Regular", size: 10))
                            .foregroundStyle(sepiaInk.opacity(0.4))
                        Spacer()
                        Text("\(Int(years * 2000)) years")
                            .font(.custom("EBGaramond-SemiBold", size: 12))
                            .foregroundStyle(color)
                        Spacer()
                        Text("2000 years")
                            .font(.custom("EBGaramond-Regular", size: 10))
                            .foregroundStyle(sepiaInk.opacity(0.4))
                    }
                    Slider(value: $years, in: 0...1)
                        .tint(color)
                }
            }
        }
    }
}

// MARK: - 8-14: Placeholder stubs (to be implemented next)

private struct PourRingsVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    var body: some View { VisualContainer(title: visual.title, color: color, caption: visual.caption, height: height) {
        Text("Pour rings — coming next").foregroundStyle(sepiaInk.opacity(0.4))
    }}
}

private struct DoorSwingVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    var body: some View { VisualContainer(title: visual.title, color: color, caption: visual.caption, height: height) {
        Text("Door swing — coming next").foregroundStyle(sepiaInk.opacity(0.4))
    }}
}

private struct CenteringBuildVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    var body: some View { VisualContainer(title: visual.title, color: color, caption: visual.caption, height: height) {
        Text("Centering build — coming next").foregroundStyle(sepiaInk.opacity(0.4))
    }}
}

private struct ScaffoldClimbVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    var body: some View { VisualContainer(title: visual.title, color: color, caption: visual.caption, height: height) {
        Text("Scaffold climb — coming next").foregroundStyle(sepiaInk.opacity(0.4))
    }}
}

private struct MixRecipeVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    var body: some View { VisualContainer(title: visual.title, color: color, caption: visual.caption, height: height) {
        Text("Mix recipe — coming next").foregroundStyle(sepiaInk.opacity(0.4))
    }}
}

private struct CalcinationSliderVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    var body: some View { VisualContainer(title: visual.title, color: color, caption: visual.caption, height: height) {
        Text("Calcination — coming next").foregroundStyle(sepiaInk.opacity(0.4))
    }}
}

private struct TessellationPuzzleVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    var body: some View { VisualContainer(title: visual.title, color: color, caption: visual.caption, height: height) {
        Text("Tessellation puzzle — coming next").foregroundStyle(sepiaInk.opacity(0.4))
    }}
}
