import SwiftUI

/// Compact interactive science visual for knowledge card backs.
/// Sits between lesson text and "Done Reading" — ~180pt tall.
/// Each visual directly illustrates the specific concept taught in that card.
struct CardVisualView: View {
    let visual: CardVisual
    let color: Color
    var containerHeight: CGFloat = 780

    /// Visual canvas height — 55% of card for interactive, 35% for legacy
    private var visualHeight: CGFloat { containerHeight * 0.55 }

    @State private var currentStep: Int = 1   // Start at step 1 (not empty step 0)
    @State private var animationPhase: CGFloat = 0

    var body: some View {
        // Use interactive visual if available (Pantheon, Aqueduct, etc.)
        if PantheonInteractiveVisuals.hasInteractiveVisual(for: visual) {
            PantheonInteractiveVisuals.view(for: visual, color: color, height: visualHeight)
        } else if AqueductInteractiveVisuals.hasInteractiveVisual(for: visual) {
            AqueductInteractiveVisuals.view(for: visual, color: color, height: visualHeight)
        } else if ColosseumInteractiveVisuals.hasInteractiveVisual(for: visual) {
            ColosseumInteractiveVisuals.view(for: visual, color: color, height: visualHeight)
        } else if RomanRoadsInteractiveVisuals.hasInteractiveVisual(for: visual) {
            RomanRoadsInteractiveVisuals.view(for: visual, color: color, height: visualHeight)
        } else if RomanBathsInteractiveVisuals.hasInteractiveVisual(for: visual) {
            RomanBathsInteractiveVisuals.view(for: visual, color: color, height: visualHeight)
        } else if InsulaInteractiveVisuals.hasInteractiveVisual(for: visual) {
            InsulaInteractiveVisuals.view(for: visual, color: color, height: visualHeight)
        } else if HarborInteractiveVisuals.hasInteractiveVisual(for: visual) {
            HarborInteractiveVisuals.view(for: visual, color: color, height: visualHeight)
        } else if SiegeWorkshopInteractiveVisuals.hasInteractiveVisual(for: visual) {
            SiegeWorkshopInteractiveVisuals.view(for: visual, color: color, height: visualHeight)
        } else if DuomoInteractiveVisuals.hasInteractiveVisual(for: visual) {
            DuomoInteractiveVisuals.view(for: visual, color: color, height: visualHeight)
        } else if BotanicalGardenInteractiveVisuals.hasInteractiveVisual(for: visual) {
            BotanicalGardenInteractiveVisuals.view(for: visual, color: color, height: visualHeight)
        } else if GlassworksInteractiveVisuals.hasInteractiveVisual(for: visual) {
            GlassworksInteractiveVisuals.view(for: visual, color: color, height: visualHeight)
        } else if ArsenalInteractiveVisuals.hasInteractiveVisual(for: visual) {
            ArsenalInteractiveVisuals.view(for: visual, color: color, height: visualHeight)
        } else if AnatomyTheaterInteractiveVisuals.hasInteractiveVisual(for: visual) {
            AnatomyTheaterInteractiveVisuals.view(for: visual, color: color, height: visualHeight)
        } else if LeonardoWorkshopInteractiveVisuals.hasInteractiveVisual(for: visual) {
            LeonardoWorkshopInteractiveVisuals.view(for: visual, color: color, height: visualHeight)
        } else if FlyingMachineInteractiveVisuals.hasInteractiveVisual(for: visual) {
            FlyingMachineInteractiveVisuals.view(for: visual, color: color, height: visualHeight)
        } else if VaticanObservatoryInteractiveVisuals.hasInteractiveVisual(for: visual) {
            VaticanObservatoryInteractiveVisuals.view(for: visual, color: color, height: visualHeight)
        } else if PrintingPressInteractiveVisuals.hasInteractiveVisual(for: visual) {
            PrintingPressInteractiveVisuals.view(for: visual, color: color, height: visualHeight)
        } else {
            legacyCanvasView
        }
    }

    /// Legacy Canvas-based visual (for cards without interactive implementations)
    private var legacyCanvasView: some View {
        VStack(spacing: 6) {
            // Title
            Text(visual.title)
                .font(.custom("Cinzel-Bold", size: 16))
                .tracking(1)
                .foregroundStyle(color)

            // Diagram canvas
            Canvas { context, size in
                drawGrid(context: context, size: size)
                drawVisual(context: context, size: size)
            }
            .frame(height: visualHeight)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(GameSettings.shared.dialogBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(color.opacity(0.2), lineWidth: 1)
            )
            .clipped()

            // Step dots + back/next controls
            if visual.steps > 1 {
                HStack(spacing: 6) {
                    // Back arrow
                    if currentStep > 1 {
                        Button {
                            withAnimation(.easeInOut(duration: 0.4)) {
                                currentStep -= 1
                            }
                        } label: {
                            HStack(spacing: 2) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 13))
                                Text("Back")
                                    .font(.custom("EBGaramond-Regular", size: 15))
                            }
                            .foregroundStyle(color.opacity(0.6))
                        }
                        .buttonStyle(.plain)
                    }

                    Spacer()

                    // Step dots
                    ForEach(1...visual.steps, id: \.self) { step in
                        Circle()
                            .fill(step <= currentStep ? color : color.opacity(0.2))
                            .frame(width: 8, height: 8)
                    }

                    Spacer()

                    // Next button or checkmark
                    if currentStep < visual.steps {
                        Button {
                            withAnimation(.easeInOut(duration: 0.4)) {
                                currentStep += 1
                            }
                        } label: {
                            HStack(spacing: 2) {
                                Text("Next")
                                    .font(.custom("EBGaramond-Regular", size: 15))
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 13))
                            }
                            .foregroundStyle(color)
                        }
                        .buttonStyle(.plain)
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 13))
                            .foregroundStyle(RenaissanceColors.sageGreen)
                    }
                }
                .padding(.horizontal, 4)
            }

            // Caption
            if let caption = visual.caption {
                Text(caption)
                    .font(.custom("EBGaramond-Italic", size: 15))
                    .tracking(0.5)
                    .foregroundStyle(GameSettings.shared.cardTextColor.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                animationPhase = 1
            }
        }
    }

    // MARK: - Blueprint Grid

    private func drawGrid(context: GraphicsContext, size: CGSize) {
        let gridColor = Color.brown.opacity(0.06)
        let spacing: CGFloat = 15

        for x in stride(from: 0, through: size.width, by: spacing) {
            var path = Path()
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: size.height))
            context.stroke(path, with: .color(gridColor), lineWidth: 0.5)
        }
        for y in stride(from: 0, through: size.height, by: spacing) {
            var path = Path()
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: size.width, y: y))
            context.stroke(path, with: .color(gridColor), lineWidth: 0.5)
        }
    }

    // MARK: - Visual Router

    private func drawVisual(context: GraphicsContext, size: CGSize) {
        switch visual.type {
        case .reaction:
            drawReaction(context: context, size: size)
        case .crossSection:
            drawCrossSection(context: context, size: size)
        case .geometry:
            drawGeometry(context: context, size: size)
        case .ratio:
            drawRatio(context: context, size: size)
        case .temperature:
            drawTemperature(context: context, size: size)
        case .force:
            drawForce(context: context, size: size)
        case .flow:
            drawFlow(context: context, size: size)
        case .mechanism:
            drawMechanism(context: context, size: size)
        case .molecule:
            drawMolecule(context: context, size: size)
        case .comparison:
            drawComparison(context: context, size: size)
        }
    }

    // MARK: - Reaction (molecules → arrow → products)

    private func drawReaction(context: GraphicsContext, size: CGSize) {
        let w = size.width, h = size.height
        let centerY = h * 0.5
        let sepiaInk = Color(red: 0.29, green: 0.25, blue: 0.21)

        guard currentStep >= 1 else { return }

        // Reactant(s) — left side
        let reactantX = w * 0.2
        if let reactant = visual.labels.first {
            context.draw(
                Text(reactant).font(.custom("EBGaramond-SemiBold", size: 16)).foregroundColor(sepiaInk),
                at: CGPoint(x: reactantX, y: centerY)
            )
        }

        guard currentStep >= 2 else { return }

        // Arrow
        let arrowStart = CGPoint(x: w * 0.38, y: centerY)
        let arrowEnd = CGPoint(x: w * 0.62, y: centerY)
        var arrowPath = Path()
        arrowPath.move(to: arrowStart)
        arrowPath.addLine(to: arrowEnd)
        context.stroke(arrowPath, with: .color(color), lineWidth: 2)
        // Arrowhead
        var head = Path()
        head.move(to: arrowEnd)
        head.addLine(to: CGPoint(x: arrowEnd.x - 8, y: arrowEnd.y - 5))
        head.addLine(to: CGPoint(x: arrowEnd.x - 8, y: arrowEnd.y + 5))
        head.closeSubpath()
        context.fill(head, with: .color(color))

        // Condition label above arrow (e.g. "900°C" or "heat")
        if visual.labels.count > 2 {
            context.draw(
                Text(visual.labels[2]).font(.custom("EBGaramond-Italic", size: 15)).foregroundColor(color),
                at: CGPoint(x: w * 0.5, y: centerY - 18)
            )
        }

        guard currentStep >= 3 else { return }

        // Product(s) — right side
        let productX = w * 0.8
        if visual.labels.count > 1 {
            context.draw(
                Text(visual.labels[1]).font(.custom("EBGaramond-SemiBold", size: 16)).foregroundColor(sepiaInk),
                at: CGPoint(x: productX, y: centerY)
            )
        }

        // Values annotation below
        if let key = visual.values.keys.first, let val = visual.values[key] {
            let annotation = "\(key): \(val.formatted())"
            context.draw(
                Text(annotation).font(.custom("EBGaramond-Regular", size: 15)).foregroundColor(sepiaInk.opacity(0.6)),
                at: CGPoint(x: w * 0.5, y: h * 0.8)
            )
        }
    }

    // MARK: - Cross Section (layered cutaway or dome layers — one per step)

    private func drawCrossSection(context: GraphicsContext, size: CGSize) {
        let w = size.width, h = size.height
        let sepiaInk = Color(red: 0.29, green: 0.25, blue: 0.21)

        guard !visual.labels.isEmpty else { return }

        // Dome-shaped cross section
        if visual.values["dome"] == 1 {
            drawDomeLayers(context: context, size: size)
            return
        }

        // Standard flat layers
        let pad: CGFloat = 10
        let layerCount = min(visual.labels.count, 5)
        let totalHeight = h - pad * 2
        let layerHeight = totalHeight / CGFloat(layerCount)
        let layerWidth = w * 0.7
        let visibleLayers = min(currentStep, layerCount)

        // Ghost outlines
        for i in 0..<layerCount {
            let y = pad + CGFloat(i) * layerHeight
            var rect = Path()
            rect.addRect(CGRect(x: (w - layerWidth) / 2, y: y, width: layerWidth, height: layerHeight - 2))
            context.stroke(rect, with: .color(sepiaInk.opacity(0.08)), lineWidth: 0.5)
        }

        // Filled layers
        for i in 0..<visibleLayers {
            let y = pad + CGFloat(i) * layerHeight
            let opacity = 0.06 + Double(layerCount - i) * 0.05

            var rect = Path()
            rect.addRect(CGRect(x: (w - layerWidth) / 2, y: y, width: layerWidth, height: layerHeight - 2))
            context.fill(rect, with: .color(color.opacity(opacity)))
            context.stroke(rect, with: .color(sepiaInk.opacity(0.3)), lineWidth: 1)

            context.draw(
                Text(visual.labels[i]).font(.custom("EBGaramond-SemiBold", size: 15)).foregroundColor(sepiaInk),
                at: CGPoint(x: w * 0.5, y: y + layerHeight / 2)
            )
        }

        // Dimension line
        if visibleLayers > 0, let totalVal = visual.values["depth"] ?? visual.values["height"] {
            let dimX = (w + layerWidth) / 2 + 16
            let topY = pad
            let botY = pad + CGFloat(visibleLayers) * layerHeight

            var topTick = Path(); topTick.move(to: CGPoint(x: dimX - 4, y: topY)); topTick.addLine(to: CGPoint(x: dimX + 4, y: topY))
            context.stroke(topTick, with: .color(sepiaInk.opacity(0.4)), lineWidth: 1)
            var botTick = Path(); botTick.move(to: CGPoint(x: dimX - 4, y: botY)); botTick.addLine(to: CGPoint(x: dimX + 4, y: botY))
            context.stroke(botTick, with: .color(sepiaInk.opacity(0.4)), lineWidth: 1)

            var dimLine = Path()
            dimLine.move(to: CGPoint(x: dimX, y: topY)); dimLine.addLine(to: CGPoint(x: dimX, y: botY))
            context.stroke(dimLine, with: .color(sepiaInk.opacity(0.4)), style: StrokeStyle(lineWidth: 1, dash: [4, 3]))

            let shownDepth = totalVal * Double(visibleLayers) / Double(layerCount)
            context.draw(
                Text(String(format: "%.1f m", shownDepth)).font(.custom("EBGaramond-SemiBold", size: 15)).foregroundColor(color),
                at: CGPoint(x: dimX + 24, y: (topY + botY) / 2)
            )
        }
    }

    // MARK: - Dome Layers (dome-shaped cross section)

    private func drawDomeLayers(context: GraphicsContext, size: CGSize) {
        let w = size.width, h = size.height
        let sepiaInk = Color(red: 0.29, green: 0.25, blue: 0.21)
        let centerX = w * 0.5
        let baseY = h * 0.7
        let domeRadius = min(w * 0.4, baseY - 10)

        let layerCount = min(visual.labels.count, 5)
        let visibleLayers = min(currentStep, layerCount)

        // Draw dome outline (always visible as ghost)
        var domeOutline = Path()
        domeOutline.addArc(center: CGPoint(x: centerX, y: baseY), radius: domeRadius, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
        context.stroke(domeOutline, with: .color(sepiaInk.opacity(0.15)), lineWidth: 1)

        // Base line
        var baseLine = Path()
        baseLine.move(to: CGPoint(x: centerX - domeRadius, y: baseY))
        baseLine.addLine(to: CGPoint(x: centerX + domeRadius, y: baseY))
        context.stroke(baseLine, with: .color(sepiaInk.opacity(0.3)), lineWidth: 1.5)

        // Fill layers from bottom (heavy) to top (light)
        for i in 0..<visibleLayers {
            let t0 = CGFloat(i) / CGFloat(layerCount)
            let t1 = CGFloat(i + 1) / CGFloat(layerCount)
            let angle0 = Double.pi - t0 * Double.pi  // bottom to top
            let angle1 = Double.pi - t1 * Double.pi
            let opacity = 0.2 - Double(i) * 0.03  // heavier = darker

            var layerArc = Path()
            layerArc.addArc(center: CGPoint(x: centerX, y: baseY), radius: domeRadius, startAngle: .init(radians: angle0), endAngle: .init(radians: angle1), clockwise: true)
            layerArc.addArc(center: CGPoint(x: centerX, y: baseY), radius: domeRadius * 0.85, startAngle: .init(radians: angle1), endAngle: .init(radians: angle0), clockwise: false)
            layerArc.closeSubpath()

            context.fill(layerArc, with: .color(color.opacity(opacity)))
            context.stroke(layerArc, with: .color(sepiaInk.opacity(0.25)), lineWidth: 0.5)

            // Label at the midpoint of the arc
            let midAngle = (angle0 + angle1) / 2
            let labelR = domeRadius * 0.6
            let labelX = centerX + labelR * cos(midAngle)
            let labelY = baseY + labelR * sin(midAngle)

            context.draw(
                Text(visual.labels[i]).font(.custom("EBGaramond-Regular", size: 15)).foregroundColor(sepiaInk),
                at: CGPoint(x: labelX, y: labelY)
            )
        }

        // Solidify dome outline for revealed portion
        if visibleLayers > 0 {
            var solidArc = Path()
            let endAngle = Double.pi - (CGFloat(visibleLayers) / CGFloat(layerCount)) * Double.pi
            solidArc.addArc(center: CGPoint(x: centerX, y: baseY), radius: domeRadius, startAngle: .degrees(180), endAngle: .init(radians: endAngle), clockwise: true)
            context.stroke(solidArc, with: .color(sepiaInk), lineWidth: 2)
        }
    }

    // MARK: - Geometry (shapes with measurements — step-by-step)

    private func drawGeometry(context: GraphicsContext, size: CGSize) {
        // Special case: tessellation pattern
        if visual.values["tessellation"] == 1 {
            drawTessellation(context: context, size: size)
            return
        }

        // Special case: chorobates leveling beam
        if visual.values["beam"] == 1 {
            drawChorobatesBeam(context: context, size: size)
            return
        }

        let w = size.width, h = size.height
        let sepiaInk = Color(red: 0.29, green: 0.25, blue: 0.21)

        // Dome cross-section with inscribed sphere (Pantheon pattern from WolframGeometryView)
        let pad: CGFloat = 15
        let baseY = h * 0.85
        let domeWidth = w - pad * 2 - 40  // leave room for dimension labels
        let domeHeight = domeWidth * 0.5   // hemisphere
        let centerX = w * 0.5

        // Step 1: Floor line + dome arc (hemisphere outline)
        var floor = Path()
        floor.move(to: CGPoint(x: centerX - domeWidth * 0.55, y: baseY))
        floor.addLine(to: CGPoint(x: centerX + domeWidth * 0.55, y: baseY))
        context.stroke(floor, with: .color(sepiaInk.opacity(0.4)), lineWidth: 1.5)

        // Dome arc
        var dome = Path()
        dome.move(to: CGPoint(x: centerX - domeWidth / 2, y: baseY))
        dome.addQuadCurve(
            to: CGPoint(x: centerX + domeWidth / 2, y: baseY),
            control: CGPoint(x: centerX, y: baseY - domeHeight)
        )
        context.stroke(dome, with: .color(sepiaInk), lineWidth: 2)
        context.fill(dome, with: .color(color.opacity(0.05)))

        // Walls (vertical lines down from dome ends)
        for x in [centerX - domeWidth / 2, centerX + domeWidth / 2] {
            var wall = Path()
            wall.move(to: CGPoint(x: x, y: baseY))
            wall.addLine(to: CGPoint(x: x, y: baseY + 10))
            context.stroke(wall, with: .color(sepiaInk), lineWidth: 2)
        }

        guard currentStep >= 2 else { return }

        // Step 2: Inscribed dashed blue circle (the "perfect sphere")
        let circleR = min(domeWidth / 2, domeHeight) * 0.9
        var sphere = Path()
        sphere.addEllipse(in: CGRect(
            x: centerX - circleR, y: baseY - circleR * 2,
            width: circleR * 2, height: circleR * 2
        ))
        context.stroke(sphere, with: .color(RenaissanceColors.renaissanceBlue.opacity(0.5)),
                       style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))

        // "sphere" label
        context.draw(
            Text("perfect sphere").font(.custom("EBGaramond-Italic", size: 15)).foregroundColor(RenaissanceColors.renaissanceBlue.opacity(0.6)),
            at: CGPoint(x: centerX, y: baseY - circleR * 1.0)
        )

        // Diameter dimension (horizontal)
        if let diameter = visual.values["diameter"] {
            let dimY = baseY + 16
            var dimH = Path()
            dimH.move(to: CGPoint(x: centerX - domeWidth / 2, y: dimY))
            dimH.addLine(to: CGPoint(x: centerX + domeWidth / 2, y: dimY))
            context.stroke(dimH, with: .color(sepiaInk.opacity(0.4)), style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
            for x in [centerX - domeWidth / 2, centerX + domeWidth / 2] {
                var tick = Path()
                tick.move(to: CGPoint(x: x, y: dimY - 3))
                tick.addLine(to: CGPoint(x: x, y: dimY + 3))
                context.stroke(tick, with: .color(sepiaInk.opacity(0.4)), lineWidth: 1)
            }
            context.draw(
                Text("\(diameter.formatted()) m").font(.custom("EBGaramond-SemiBold", size: 15)).foregroundColor(color),
                at: CGPoint(x: centerX, y: dimY + 12)
            )
        }

        guard currentStep >= 3 else { return }

        // Step 3: Height dimension (vertical) showing height = diameter
        if let height = visual.values["height"] {
            let dimX = centerX + domeWidth / 2 + 12
            var dimV = Path()
            dimV.move(to: CGPoint(x: dimX, y: baseY))
            dimV.addLine(to: CGPoint(x: dimX, y: baseY - domeHeight))
            context.stroke(dimV, with: .color(sepiaInk.opacity(0.4)), style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
            for y in [baseY, baseY - domeHeight] {
                var tick = Path()
                tick.move(to: CGPoint(x: dimX - 3, y: y))
                tick.addLine(to: CGPoint(x: dimX + 3, y: y))
                context.stroke(tick, with: .color(sepiaInk.opacity(0.4)), lineWidth: 1)
            }
            context.draw(
                Text("\(height.formatted()) m").font(.custom("EBGaramond-SemiBold", size: 15)).foregroundColor(color),
                at: CGPoint(x: dimX + 20, y: baseY - domeHeight / 2)
            )
        }

        // "height = diameter" insight
        context.draw(
            Text("height = diameter").font(.custom("EBGaramond-SemiBold", size: 15)).foregroundColor(color),
            at: CGPoint(x: centerX, y: baseY - domeHeight - 10)
        )

        // Oculus at top of dome
        let oculusW = domeWidth * 0.1
        var oculus = Path()
        oculus.addEllipse(in: CGRect(
            x: centerX - oculusW / 2, y: baseY - domeHeight - 3,
            width: oculusW, height: oculusW * 0.3
        ))
        context.fill(oculus, with: .color(RenaissanceColors.renaissanceBlue.opacity(0.25)))
        context.stroke(oculus, with: .color(sepiaInk.opacity(0.5)), lineWidth: 1)
    }

    // MARK: - Tessellation (geometric stone floor pattern)

    private func drawTessellation(context: GraphicsContext, size: CGSize) {
        let w = size.width, h = size.height
        let sepiaInk = Color(red: 0.29, green: 0.25, blue: 0.21)
        let centerX = w * 0.5, centerY = h * 0.45

        // Stone colors matching real Pantheon floor
        let stoneColors: [Color] = [
            Color(red: 0.55, green: 0.2, blue: 0.3),   // Porphyry (purple-red)
            Color(red: 0.8, green: 0.7, blue: 0.4),     // Giallo antico (yellow)
            Color(red: 0.9, green: 0.85, blue: 0.8),    // Pavonazzetto (white)
            Color(red: 0.5, green: 0.5, blue: 0.5),     // Granite (grey)
        ]

        let visibleStones = min(currentStep, visual.labels.count)
        let tileSize: CGFloat = 24
        let gridCols = 7
        let gridRows = 4

        // Draw grid of geometric tiles
        let gridW = CGFloat(gridCols) * tileSize
        let gridH = CGFloat(gridRows) * tileSize
        let startX = centerX - gridW / 2
        let startY = centerY - gridH / 2

        for row in 0..<gridRows {
            for col in 0..<gridCols {
                let x = startX + CGFloat(col) * tileSize
                let y = startY + CGFloat(row) * tileSize
                let stoneIdx = (row + col) % stoneColors.count

                if stoneIdx < visibleStones {
                    // Filled tile
                    let tileColor = stoneColors[stoneIdx]
                    var tile = Path()

                    // Alternate between squares and circles
                    if (row + col) % 3 == 0 {
                        // Circle tile
                        tile.addEllipse(in: CGRect(x: x + 2, y: y + 2, width: tileSize - 4, height: tileSize - 4))
                    } else {
                        // Square tile
                        tile.addRect(CGRect(x: x + 1, y: y + 1, width: tileSize - 2, height: tileSize - 2))
                    }

                    context.fill(tile, with: .color(tileColor.opacity(0.3)))
                    context.stroke(tile, with: .color(tileColor.opacity(0.6)), lineWidth: 0.8)
                } else {
                    // Ghost tile
                    var ghost = Path()
                    ghost.addRect(CGRect(x: x + 1, y: y + 1, width: tileSize - 2, height: tileSize - 2))
                    context.stroke(ghost, with: .color(sepiaInk.opacity(0.08)), lineWidth: 0.5)
                }
            }
        }

        // Stone labels below
        let labelY = centerY + gridH / 2 + 16
        for i in 0..<visibleStones {
            let labelX = w * (0.15 + CGFloat(i) * 0.22)
            // Color swatch
            var swatch = Path()
            swatch.addRect(CGRect(x: labelX - 5, y: labelY - 5, width: 10, height: 10))
            context.fill(swatch, with: .color(stoneColors[i].opacity(0.5)))
            context.stroke(swatch, with: .color(stoneColors[i]), lineWidth: 0.5)

            // Name
            if i < visual.labels.count {
                context.draw(
                    Text(visual.labels[i]).font(.custom("EBGaramond-Regular", size: 15)).foregroundColor(sepiaInk.opacity(0.7)),
                    at: CGPoint(x: labelX, y: labelY + 14)
                )
            }
        }
    }

    // MARK: - Chorobates Beam (6m wooden leveling tool)

    private func drawChorobatesBeam(context: GraphicsContext, size: CGSize) {
        let w = size.width, h = size.height
        let sepiaInk = Color(red: 0.29, green: 0.25, blue: 0.21)
        let wood = Color(red: 0.6, green: 0.45, blue: 0.3)

        let beamW = w * 0.75
        let beamH: CGFloat = 14
        let beamY = h * 0.4
        let centerX = w * 0.5

        // Step 1: The wooden beam
        var beam = Path()
        beam.addRoundedRect(in: CGRect(x: centerX - beamW / 2, y: beamY, width: beamW, height: beamH),
                            cornerSize: CGSize(width: 3, height: 3))
        context.fill(beam, with: .color(wood.opacity(0.4)))
        context.stroke(beam, with: .color(wood), lineWidth: 2)

        // Wood grain lines
        for i in 0..<6 {
            let grainX = centerX - beamW / 2 + CGFloat(i + 1) * beamW / 7
            var grain = Path()
            grain.move(to: CGPoint(x: grainX, y: beamY + 2))
            grain.addLine(to: CGPoint(x: grainX, y: beamY + beamH - 2))
            context.stroke(grain, with: .color(wood.opacity(0.2)), lineWidth: 0.5)
        }

        // Legs (4 supports underneath)
        for i in 0..<4 {
            let legX = centerX - beamW / 2 + beamW * CGFloat(i + 1) / 5
            var leg = Path()
            leg.move(to: CGPoint(x: legX, y: beamY + beamH))
            leg.addLine(to: CGPoint(x: legX, y: beamY + beamH + 30))
            context.stroke(leg, with: .color(wood), lineWidth: 2)
        }

        // Ground line
        let groundY = beamY + beamH + 30
        var ground = Path()
        ground.move(to: CGPoint(x: centerX - beamW / 2 - 10, y: groundY))
        ground.addLine(to: CGPoint(x: centerX + beamW / 2 + 10, y: groundY))
        context.stroke(ground, with: .color(sepiaInk.opacity(0.2)), lineWidth: 1)

        // "6m" dimension
        let dimY = beamY - 10
        var dimLine = Path()
        dimLine.move(to: CGPoint(x: centerX - beamW / 2, y: dimY))
        dimLine.addLine(to: CGPoint(x: centerX + beamW / 2, y: dimY))
        context.stroke(dimLine, with: .color(sepiaInk.opacity(0.3)), style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
        for xOff in [centerX - beamW / 2, centerX + beamW / 2] {
            var tick = Path()
            tick.move(to: CGPoint(x: xOff, y: dimY - 3))
            tick.addLine(to: CGPoint(x: xOff, y: dimY + 3))
            context.stroke(tick, with: .color(sepiaInk.opacity(0.3)), lineWidth: 1)
        }
        context.draw(
            Text("6 meters").font(.custom("EBGaramond-SemiBold", size: 15)).foregroundColor(color),
            at: CGPoint(x: centerX, y: dimY - 10)
        )

        guard currentStep >= 2 else { return }

        // Step 2: Water channel on top (blue line showing the level surface)
        let channelInset: CGFloat = 12
        var channel = Path()
        channel.move(to: CGPoint(x: centerX - beamW / 2 + channelInset, y: beamY + 3))
        channel.addLine(to: CGPoint(x: centerX + beamW / 2 - channelInset, y: beamY + 3))
        context.stroke(channel, with: .color(Color(red: 0.35, green: 0.55, blue: 0.75)), lineWidth: 3)

        // Water surface label
        context.draw(
            Text("water channel").font(.custom("EBGaramond-Italic", size: 15)).foregroundColor(Color(red: 0.35, green: 0.55, blue: 0.75)),
            at: CGPoint(x: centerX, y: beamY - 24)
        )

        // "Level!" indicators at each end
        for xOff in [centerX - beamW / 2 + channelInset + 8, centerX + beamW / 2 - channelInset - 8] {
            var droplet = Path()
            droplet.addEllipse(in: CGRect(x: xOff - 3, y: beamY, width: 6, height: 6))
            context.fill(droplet, with: .color(Color(red: 0.35, green: 0.55, blue: 0.75).opacity(0.5)))
        }

        guard currentStep >= 3 else { return }

        // Step 3: Gradient annotation — the beam shows how tiny the slope is
        let slopeLabel = "1:4800 slope — 14m drop over 69 km"
        context.draw(
            Text(slopeLabel).font(.custom("EBGaramond-SemiBold", size: 15)).foregroundColor(color),
            at: CGPoint(x: centerX, y: groundY + 18)
        )

        // Tiny tilt indicator (exaggerated for visibility)
        let tiltStart = CGPoint(x: centerX + beamW / 2 + 16, y: beamY + beamH / 2)
        let tiltEnd = CGPoint(x: centerX + beamW / 2 + 16, y: beamY + beamH / 2 + 12)
        drawArrow(context: context, from: tiltStart, to: tiltEnd, color: Color.red.opacity(0.5))
        context.draw(
            Text("tiny drop").font(.custom("EBGaramond-Italic", size: 15)).foregroundColor(Color.red.opacity(0.5)),
            at: CGPoint(x: centerX + beamW / 2 + 16, y: beamY + beamH / 2 + 22)
        )
    }

    // MARK: - Ratio (proportional bars — step-by-step reveal)

    private func drawRatio(context: GraphicsContext, size: CGSize) {
        let w = size.width, h = size.height
        let pad: CGFloat = 12
        let sepiaInk = Color(red: 0.29, green: 0.25, blue: 0.21)
        let barWidth = w - pad * 2
        let barHeight: CGFloat = 40
        let barY = h * 0.35

        let sortedValues = visual.values.sorted { $0.value > $1.value }
        let total = sortedValues.reduce(0.0) { $0 + $1.value }
        guard total > 0 else { return }

        // Step 1: Empty bar outline + ratio text label
        var bgBar = Path()
        bgBar.addRoundedRect(in: CGRect(x: pad, y: barY, width: barWidth, height: barHeight), cornerSize: CGSize(width: 6, height: 6))
        context.fill(bgBar, with: .color(sepiaInk.opacity(0.04)))
        context.stroke(bgBar, with: .color(sepiaInk.opacity(0.15)), lineWidth: 1)

        if visual.labels.count >= 1 {
            context.draw(
                Text(visual.labels[0]).font(.custom("EBGaramond-SemiBold", size: 15)).foregroundColor(color),
                at: CGPoint(x: w / 2, y: barY - 24)
            )
        }

        guard currentStep >= 2 else { return }

        // Step 2: First segment fills in
        let firstEntry = sortedValues[0]
        let firstFrac = firstEntry.value / total
        let firstW = barWidth * firstFrac

        var seg1 = Path()
        seg1.addRoundedRect(in: CGRect(x: pad, y: barY, width: firstW, height: barHeight), cornerSize: CGSize(width: 4, height: 4))
        context.fill(seg1, with: .color(color.opacity(0.3)))
        context.stroke(seg1, with: .color(color), lineWidth: 1.5)

        context.draw(
            Text(firstEntry.key).font(.custom("EBGaramond-SemiBold", size: 15)).foregroundColor(sepiaInk),
            at: CGPoint(x: pad + firstW / 2, y: barY + barHeight / 2)
        )

        guard currentStep >= 3, sortedValues.count > 1 else { return }

        // Step 3: Remaining segments + percentages
        var offsetX = pad + firstW
        for i in 1..<sortedValues.count {
            let entry = sortedValues[i]
            let fraction = entry.value / total
            let segWidth = barWidth * fraction
            let segColor = color.opacity(0.4 - Double(i) * 0.08)

            var seg = Path()
            seg.addRoundedRect(in: CGRect(x: offsetX, y: barY, width: segWidth, height: barHeight), cornerSize: CGSize(width: 4, height: 4))
            context.fill(seg, with: .color(segColor.opacity(0.25)))
            context.stroke(seg, with: .color(segColor), lineWidth: 1)

            context.draw(
                Text(entry.key).font(.custom("EBGaramond-SemiBold", size: 15)).foregroundColor(sepiaInk),
                at: CGPoint(x: offsetX + segWidth / 2, y: barY + barHeight / 2)
            )
            offsetX += segWidth
        }

        // Percentages below each segment
        var pctX = pad
        for entry in sortedValues {
            let fraction = entry.value / total
            let segWidth = barWidth * fraction
            let pct = Int(fraction * 100)
            context.draw(
                Text("\(pct)%").font(.custom("EBGaramond-SemiBold", size: 15)).foregroundColor(color.opacity(0.7)),
                at: CGPoint(x: pctX + segWidth / 2, y: barY + barHeight + 16)
            )
            pctX += segWidth
        }

        // Values annotation
        let valStr = sortedValues.map { "\(Int($0.value))" }.joined(separator: " : ")
        context.draw(
            Text(valStr).font(.custom("EBGaramond-Bold", size: 16)).foregroundColor(color),
            at: CGPoint(x: w / 2, y: barY + barHeight + 40)
        )
    }

    // MARK: - Temperature (phase transition curve)

    private func drawTemperature(context: GraphicsContext, size: CGSize) {
        let w = size.width, h = size.height
        let pad: CGFloat = 20
        let sepiaInk = Color(red: 0.29, green: 0.25, blue: 0.21)

        guard currentStep >= 1 else { return }

        // Axes
        var yAxis = Path()
        yAxis.move(to: CGPoint(x: pad, y: pad))
        yAxis.addLine(to: CGPoint(x: pad, y: h - pad))
        context.stroke(yAxis, with: .color(sepiaInk.opacity(0.4)), lineWidth: 1)

        var xAxis = Path()
        xAxis.move(to: CGPoint(x: pad, y: h - pad))
        xAxis.addLine(to: CGPoint(x: w - pad, y: h - pad))
        context.stroke(xAxis, with: .color(sepiaInk.opacity(0.4)), lineWidth: 1)

        // Y axis label
        context.draw(
            Text("°C").font(.custom("EBGaramond-SemiBold", size: 15)).foregroundColor(sepiaInk.opacity(0.6)),
            at: CGPoint(x: pad - 12, y: pad + 10)
        )

        guard currentStep >= 2 else { return }

        // Temperature curve (rises, plateau at transition, rises again)
        let transitionTemp = visual.values["transition"] ?? 900
        let maxTemp = visual.values["max"] ?? 1200
        let graphW = w - pad * 2
        let graphH = h - pad * 2

        var curve = Path()
        let points = 50
        for i in 0...points {
            let t = CGFloat(i) / CGFloat(points)
            let temp: CGFloat
            if t < 0.3 {
                temp = t / 0.3 * transitionTemp / maxTemp
            } else if t < 0.5 {
                temp = transitionTemp / maxTemp  // plateau
            } else {
                temp = transitionTemp / maxTemp + (t - 0.5) / 0.5 * (1.0 - transitionTemp / maxTemp)
            }

            let x = pad + t * graphW
            let y = (h - pad) - temp * graphH

            if i == 0 {
                curve.move(to: CGPoint(x: x, y: y))
            } else {
                curve.addLine(to: CGPoint(x: x, y: y))
            }
        }
        context.stroke(curve, with: .color(color), lineWidth: 2)

        guard currentStep >= 3 else { return }

        // Transition marker (dashed horizontal line + label)
        let transY = (h - pad) - (transitionTemp / maxTemp) * graphH
        var transLine = Path()
        transLine.move(to: CGPoint(x: pad, y: transY))
        transLine.addLine(to: CGPoint(x: w - pad, y: transY))
        context.stroke(transLine, with: .color(Color.red.opacity(0.4)), style: StrokeStyle(lineWidth: 1, dash: [4, 3]))

        context.draw(
            Text("\(Int(transitionTemp))°C").font(.custom("EBGaramond-SemiBold", size: 15)).foregroundColor(Color.red.opacity(0.7)),
            at: CGPoint(x: w - pad - 25, y: transY - 12)
        )

        // Phase labels
        if visual.labels.count >= 2 {
            context.draw(
                Text(visual.labels[0]).font(.custom("EBGaramond-Italic", size: 15)).foregroundColor(sepiaInk.opacity(0.5)),
                at: CGPoint(x: pad + graphW * 0.15, y: h - pad + 12)
            )
            context.draw(
                Text(visual.labels[1]).font(.custom("EBGaramond-Italic", size: 15)).foregroundColor(sepiaInk.opacity(0.5)),
                at: CGPoint(x: pad + graphW * 0.75, y: h - pad + 12)
            )
        }
    }

    // MARK: - Force (load arrows on structure — or oculus compression)

    private func drawForce(context: GraphicsContext, size: CGSize) {
        let w = size.width, h = size.height
        let sepiaInk = Color(red: 0.29, green: 0.25, blue: 0.21)

        // Special case: Oculus compression ring
        if visual.values["oculus"] == 1 {
            drawOculusCompression(context: context, size: size)
            return
        }

        // Special case: Centering (curved wooden arch frame)
        if visual.values["centering"] == 1 {
            drawCentering(context: context, size: size)
            return
        }

        // Special case: Bronze doors
        if visual.values["doors"] == 1 {
            drawBronzeDoors(context: context, size: size)
            return
        }

        // Special case: Coffers inside dome
        if visual.values["coffers"] == 1 {
            drawCoffers(context: context, size: size)
            return
        }

        // Special case: Scaffolding around dome
        if visual.values["scaffolding"] == 1 {
            drawScaffolding(context: context, size: size)
            return
        }

        // Special case: Arch with voussoirs + keystone
        if visual.values["arch"] == 1 {
            drawVoussoirArch(context: context, size: size)
            return
        }

        // Standard: Portico with columns, entablature, pediment

        let pad: CGFloat = 20
        let floorY = h * 0.88        // ground line
        let entablatureY = h * 0.28  // top of columns / bottom of pediment
        let colCount = Int(visual.values["columns"] ?? 8)
        let porticoLeft = w * 0.12
        let porticoRight = w * 0.88
        let porticoW = porticoRight - porticoLeft
        let colWidth: CGFloat = 4
        let capitalH: CGFloat = 6
        let baseH: CGFloat = 5

        // Step 1: Floor + columns + entablature + pediment
        // Floor line
        var floor = Path()
        floor.move(to: CGPoint(x: pad, y: floorY))
        floor.addLine(to: CGPoint(x: w - pad, y: floorY))
        context.stroke(floor, with: .color(sepiaInk.opacity(0.3)), lineWidth: 1)

        // Columns (8 shown = representative of 16)
        let colSpacing = porticoW / CGFloat(max(colCount - 1, 1))
        for i in 0..<colCount {
            let x = porticoLeft + CGFloat(i) * colSpacing

            // Column shaft
            var shaft = Path()
            shaft.addRect(CGRect(x: x - colWidth / 2, y: entablatureY + capitalH, width: colWidth, height: floorY - entablatureY - capitalH - baseH))
            context.fill(shaft, with: .color(color.opacity(0.12)))
            context.stroke(shaft, with: .color(sepiaInk.opacity(0.5)), lineWidth: 1)

            // Capital (wider rectangle on top)
            var capital = Path()
            capital.addRect(CGRect(x: x - colWidth - 1, y: entablatureY, width: colWidth * 2 + 2, height: capitalH))
            context.fill(capital, with: .color(sepiaInk.opacity(0.15)))
            context.stroke(capital, with: .color(sepiaInk.opacity(0.4)), lineWidth: 0.8)

            // Base
            var base = Path()
            base.addRect(CGRect(x: x - colWidth - 1, y: floorY - baseH, width: colWidth * 2 + 2, height: baseH))
            context.fill(base, with: .color(sepiaInk.opacity(0.1)))
            context.stroke(base, with: .color(sepiaInk.opacity(0.3)), lineWidth: 0.8)
        }

        // Entablature (horizontal beam on top of columns)
        var entablature = Path()
        entablature.addRect(CGRect(x: porticoLeft - 6, y: entablatureY - 6, width: porticoW + 12, height: 6))
        context.fill(entablature, with: .color(sepiaInk.opacity(0.12)))
        context.stroke(entablature, with: .color(sepiaInk.opacity(0.5)), lineWidth: 1.5)

        // Triangular pediment
        var pediment = Path()
        pediment.move(to: CGPoint(x: porticoLeft - 6, y: entablatureY - 6))
        pediment.addLine(to: CGPoint(x: w / 2, y: entablatureY - 34))
        pediment.addLine(to: CGPoint(x: porticoRight + 6, y: entablatureY - 6))
        pediment.closeSubpath()
        context.fill(pediment, with: .color(color.opacity(0.06)))
        context.stroke(pediment, with: .color(sepiaInk.opacity(0.5)), lineWidth: 1.5)

        // "×16" label
        context.draw(
            Text("×16 columns").font(.custom("EBGaramond-Italic", size: 15)).foregroundColor(sepiaInk.opacity(0.5)),
            at: CGPoint(x: w / 2, y: floorY + 10)
        )

        guard currentStep >= 2 else { return }

        // Step 2: Height dimension line (12m)
        let dimX = porticoRight + 14
        var dimLine = Path()
        dimLine.move(to: CGPoint(x: dimX, y: entablatureY))
        dimLine.addLine(to: CGPoint(x: dimX, y: floorY))
        context.stroke(dimLine, with: .color(color.opacity(0.5)), style: StrokeStyle(lineWidth: 1, dash: [4, 3]))

        // Ticks
        for tickY in [entablatureY, floorY] {
            var tick = Path()
            tick.move(to: CGPoint(x: dimX - 4, y: tickY))
            tick.addLine(to: CGPoint(x: dimX + 4, y: tickY))
            context.stroke(tick, with: .color(color.opacity(0.5)), lineWidth: 1)
        }

        if let colHeight = visual.values["height"] {
            context.draw(
                Text("\(Int(colHeight))m tall").font(.custom("EBGaramond-SemiBold", size: 15)).foregroundColor(color),
                at: CGPoint(x: dimX + 22, y: (entablatureY + floorY) / 2)
            )
        }

        guard currentStep >= 3 else { return }

        // Step 3: Weight per column
        if let perCol = visual.values["perColumn"] {
            context.draw(
                Text("\(Int(perCol)) tons each").font(.custom("EBGaramond-SemiBold", size: 15)).foregroundColor(color),
                at: CGPoint(x: w / 2, y: entablatureY - 42)
            )
        }

        // Downward arrows on a few columns
        for i in stride(from: 1, to: colCount, by: 2) {
            let x = porticoLeft + CGFloat(i) * colSpacing
            drawArrow(context: context, from: CGPoint(x: x, y: entablatureY + capitalH + 4), to: CGPoint(x: x, y: floorY - baseH - 4), color: Color.red.opacity(0.25))
        }
    }

    // MARK: - Oculus Compression (dome arc + inward arrows)

    private func drawOculusCompression(context: GraphicsContext, size: CGSize) {
        let w = size.width, h = size.height
        let sepiaInk = Color(red: 0.29, green: 0.25, blue: 0.21)
        let centerX = w * 0.5
        let baseY = h * 0.7
        let domeRadius = min(w * 0.4, baseY - 10)
        let domeCenter = CGPoint(x: centerX, y: baseY)

        // Step 1: Dome arc + walls
        var dome = Path()
        dome.addArc(center: domeCenter, radius: domeRadius, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
        context.stroke(dome, with: .color(sepiaInk), lineWidth: 2.5)
        context.fill(dome, with: .color(color.opacity(0.04)))

        // Walls
        var leftWall = Path()
        leftWall.move(to: CGPoint(x: centerX - domeRadius, y: baseY))
        leftWall.addLine(to: CGPoint(x: centerX - domeRadius, y: baseY + 20))
        context.stroke(leftWall, with: .color(sepiaInk), lineWidth: 2.5)

        var rightWall = Path()
        rightWall.move(to: CGPoint(x: centerX + domeRadius, y: baseY))
        rightWall.addLine(to: CGPoint(x: centerX + domeRadius, y: baseY + 20))
        context.stroke(rightWall, with: .color(sepiaInk), lineWidth: 2.5)

        // Oculus opening at top (hole in the dome — no fill, just an opening)
        let oculusRadius: CGFloat = domeRadius * 0.2
        let oculusY = baseY - domeRadius
        var oculusCircle = Path()
        oculusCircle.addEllipse(in: CGRect(x: centerX - oculusRadius, y: oculusY - oculusRadius * 0.4, width: oculusRadius * 2, height: oculusRadius * 0.8))
        // White fill = "hole" cut through the dome, showing sky
        context.fill(oculusCircle, with: .color(.white))
        context.stroke(oculusCircle, with: .color(sepiaInk), lineWidth: 2)

        // "9m" label
        if let diameter = visual.values["diameter"] {
            context.draw(
                Text("\(Int(diameter))m").font(.custom("EBGaramond-SemiBold", size: 15)).foregroundColor(color),
                at: CGPoint(x: centerX, y: oculusY)
            )
        }

        guard currentStep >= 2 else { return }

        // Step 2: Compression arrows pointing INWARD around the oculus
        let arrowCount = 8
        let arrowRadius = oculusRadius * 2.2
        for i in 0..<arrowCount {
            let angle = Double(i) / Double(arrowCount) * 2 * Double.pi - Double.pi / 2
            let outerX = centerX + arrowRadius * cos(angle)
            let outerY = oculusY + arrowRadius * 0.5 * sin(angle)
            let innerX = centerX + (oculusRadius + 4) * cos(angle)
            let innerY = oculusY + (oculusRadius * 0.4 + 2) * sin(angle)

            drawArrow(context: context, from: CGPoint(x: outerX, y: outerY), to: CGPoint(x: innerX, y: innerY), color: Color.orange.opacity(0.7))
        }

        // "Compression" label
        context.draw(
            Text("compression").font(.custom("EBGaramond-Italic", size: 15)).foregroundColor(Color.orange.opacity(0.7)),
            at: CGPoint(x: centerX, y: oculusY + oculusRadius + 16)
        )

        guard currentStep >= 3 else { return }

        // Step 3: Annotations
        for (i, label) in visual.labels.enumerated() {
            context.draw(
                Text(label).font(.custom("EBGaramond-Italic", size: 15)).foregroundColor(sepiaInk.opacity(0.6)),
                at: CGPoint(x: centerX, y: baseY + 30 + CGFloat(i) * 14)
            )
        }
    }

    // MARK: - Voussoir Arch (wedge stones + keystone + compression)

    private func drawVoussoirArch(context: GraphicsContext, size: CGSize) {
        let w = size.width, h = size.height
        let sepiaInk = Color(red: 0.29, green: 0.25, blue: 0.21)
        let centerX = w * 0.5
        let baseY = h * 0.78
        let archRadius = w * 0.36
        let archCenter = CGPoint(x: centerX, y: baseY)

        // Step 1: Arch shape with individual voussoir wedge stones
        let voussoirs = 9  // odd number so keystone is centered
        let startAngle = Double.pi
        let endAngle = 0.0

        // Draw piers (vertical supports)
        let pierWidth: CGFloat = 14
        let pierHeight: CGFloat = h * 0.2
        for x in [centerX - archRadius, centerX + archRadius] {
            var pier = Path()
            pier.addRect(CGRect(x: x - pierWidth / 2, y: baseY, width: pierWidth, height: pierHeight))
            context.fill(pier, with: .color(sepiaInk.opacity(0.1)))
            context.stroke(pier, with: .color(sepiaInk.opacity(0.4)), lineWidth: 1)
        }

        // Ground line
        var ground = Path()
        ground.move(to: CGPoint(x: w * 0.1, y: baseY + pierHeight))
        ground.addLine(to: CGPoint(x: w * 0.9, y: baseY + pierHeight))
        context.stroke(ground, with: .color(sepiaInk.opacity(0.2)), lineWidth: 1)

        // Draw voussoir stones as wedge segments
        for i in 0..<voussoirs {
            let angle0 = startAngle - Double(i) / Double(voussoirs) * (startAngle - endAngle)
            let angle1 = startAngle - Double(i + 1) / Double(voussoirs) * (startAngle - endAngle)
            let isKeystone = i == voussoirs / 2

            var wedge = Path()
            wedge.addArc(center: archCenter, radius: archRadius, startAngle: .init(radians: angle0), endAngle: .init(radians: angle1), clockwise: true)
            wedge.addArc(center: archCenter, radius: archRadius * 0.78, startAngle: .init(radians: angle1), endAngle: .init(radians: angle0), clockwise: false)
            wedge.closeSubpath()

            let fillColor = isKeystone ? color.opacity(0.25) : sepiaInk.opacity(0.08)
            let strokeColor = isKeystone ? color : sepiaInk.opacity(0.35)
            context.fill(wedge, with: .color(fillColor))
            context.stroke(wedge, with: .color(strokeColor), lineWidth: isKeystone ? 2 : 1)
        }

        // Keystone label
        let keystoneAngle = (startAngle + endAngle) / 2
        let keystoneLabelR = archRadius * 0.55
        context.draw(
            Text("keystone").font(.custom("EBGaramond-Italic", size: 15)).foregroundColor(color),
            at: CGPoint(x: centerX + keystoneLabelR * cos(keystoneAngle), y: baseY + keystoneLabelR * sin(keystoneAngle) + 12)
        )

        guard currentStep >= 2 else { return }

        // Step 2: Compression arrows — each voussoir pushes against neighbors
        for i in 0..<voussoirs {
            let midAngle = startAngle - (Double(i) + 0.5) / Double(voussoirs) * (startAngle - endAngle)
            let innerR = archRadius * 0.65
            let outerR = archRadius * 1.12

            let fromX = centerX + outerR * cos(midAngle)
            let fromY = baseY + outerR * sin(midAngle)
            let toX = centerX + innerR * cos(midAngle)
            let toY = baseY + innerR * sin(midAngle)

            drawArrow(context: context, from: CGPoint(x: fromX, y: fromY), to: CGPoint(x: toX, y: toY), color: Color.red.opacity(0.4))
        }

        context.draw(
            Text("compression").font(.custom("EBGaramond-Italic", size: 15)).foregroundColor(Color.red.opacity(0.5)),
            at: CGPoint(x: centerX, y: baseY - archRadius - 12)
        )

        guard currentStep >= 3 else { return }

        // Step 3: Height dimension + "30m" + voussoir label
        if let height = visual.values["height"] {
            let dimX = centerX + archRadius + pierWidth / 2 + 14
            var dimLine = Path()
            dimLine.move(to: CGPoint(x: dimX, y: baseY - archRadius))
            dimLine.addLine(to: CGPoint(x: dimX, y: baseY + pierHeight))
            context.stroke(dimLine, with: .color(color.opacity(0.5)), style: StrokeStyle(lineWidth: 1, dash: [4, 3]))

            for y in [baseY - archRadius, baseY + pierHeight] {
                var tick = Path()
                tick.move(to: CGPoint(x: dimX - 3, y: y))
                tick.addLine(to: CGPoint(x: dimX + 3, y: y))
                context.stroke(tick, with: .color(color.opacity(0.5)), lineWidth: 1)
            }

            context.draw(
                Text("\(Int(height))m").font(.custom("EBGaramond-SemiBold", size: 15)).foregroundColor(color),
                at: CGPoint(x: dimX + 16, y: baseY - archRadius / 2 + pierHeight / 2)
            )
        }

        // Voussoir label pointing to a wedge
        let labelAngle = startAngle - 0.2 * (startAngle - endAngle)
        let labelR = archRadius * 1.2
        context.draw(
            Text("voussoir").font(.custom("EBGaramond-Italic", size: 15)).foregroundColor(sepiaInk.opacity(0.5)),
            at: CGPoint(x: centerX + labelR * cos(labelAngle), y: baseY + labelR * sin(labelAngle))
        )
    }

    // MARK: - Scaffolding (wooden platforms around dome)

    private func drawScaffolding(context: GraphicsContext, size: CGSize) {
        let w = size.width, h = size.height
        let sepiaInk = Color(red: 0.29, green: 0.25, blue: 0.21)
        let wood = Color.brown
        let centerX = w * 0.5
        let groundY = h * 0.72
        let domeRadius = w * 0.26
        let domeCenter = CGPoint(x: centerX, y: groundY)

        // Step 1: Dome outline (the building being constructed)
        var dome = Path()
        dome.addArc(center: domeCenter, radius: domeRadius, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
        context.stroke(dome, with: .color(sepiaInk.opacity(0.3)), lineWidth: 1.5)
        context.fill(dome, with: .color(sepiaInk.opacity(0.03)))

        // Walls below dome
        for wallX in [centerX - domeRadius, centerX + domeRadius] {
            var wall = Path()
            wall.move(to: CGPoint(x: wallX, y: groundY))
            wall.addLine(to: CGPoint(x: wallX, y: groundY + 6))
            context.stroke(wall, with: .color(sepiaInk.opacity(0.3)), lineWidth: 1.5)
        }

        // Ground line
        var ground = Path()
        ground.move(to: CGPoint(x: w * 0.08, y: groundY + 6))
        ground.addLine(to: CGPoint(x: w * 0.92, y: groundY + 6))
        context.stroke(ground, with: .color(sepiaInk.opacity(0.2)), lineWidth: 1)

        // Scaffolding structure — vertical poles + horizontal platforms on BOTH sides
        let platformCount = 5
        let scaffoldLeft = centerX - domeRadius - 18
        let scaffoldRight = centerX + domeRadius + 18
        let poleSpacing: CGFloat = 14

        for i in 0..<platformCount {
            let t = CGFloat(i) / CGFloat(platformCount)
            let platformY = groundY - t * domeRadius * 1.8

            // Left scaffolding
            // Horizontal platform
            var leftPlat = Path()
            leftPlat.move(to: CGPoint(x: scaffoldLeft - poleSpacing, y: platformY))
            leftPlat.addLine(to: CGPoint(x: scaffoldLeft + poleSpacing, y: platformY))
            context.stroke(leftPlat, with: .color(wood.opacity(0.5)), lineWidth: 1.5)

            // Right scaffolding
            var rightPlat = Path()
            rightPlat.move(to: CGPoint(x: scaffoldRight - poleSpacing, y: platformY))
            rightPlat.addLine(to: CGPoint(x: scaffoldRight + poleSpacing, y: platformY))
            context.stroke(rightPlat, with: .color(wood.opacity(0.5)), lineWidth: 1.5)

            // Cross braces (diagonal)
            if i > 0 {
                let prevY = groundY - CGFloat(i - 1) / CGFloat(platformCount) * domeRadius * 1.8
                // Left X-brace
                var lbrace = Path()
                lbrace.move(to: CGPoint(x: scaffoldLeft - poleSpacing, y: prevY))
                lbrace.addLine(to: CGPoint(x: scaffoldLeft + poleSpacing, y: platformY))
                context.stroke(lbrace, with: .color(wood.opacity(0.2)), lineWidth: 0.5)

                // Right X-brace
                var rbrace = Path()
                rbrace.move(to: CGPoint(x: scaffoldRight + poleSpacing, y: prevY))
                rbrace.addLine(to: CGPoint(x: scaffoldRight - poleSpacing, y: platformY))
                context.stroke(rbrace, with: .color(wood.opacity(0.2)), lineWidth: 0.5)
            }
        }

        // Vertical poles
        for xOffset in [-poleSpacing, poleSpacing] {
            let topY = groundY - CGFloat(platformCount - 1) / CGFloat(platformCount) * domeRadius * 1.8

            // Left poles
            var leftPole = Path()
            leftPole.move(to: CGPoint(x: scaffoldLeft + xOffset, y: groundY + 6))
            leftPole.addLine(to: CGPoint(x: scaffoldLeft + xOffset, y: topY))
            context.stroke(leftPole, with: .color(wood.opacity(0.4)), lineWidth: 1)

            // Right poles
            var rightPole = Path()
            rightPole.move(to: CGPoint(x: scaffoldRight + xOffset, y: groundY + 6))
            rightPole.addLine(to: CGPoint(x: scaffoldRight + xOffset, y: topY))
            context.stroke(rightPole, with: .color(wood.opacity(0.4)), lineWidth: 1)
        }

        // "poplar" label
        context.draw(
            Text("poplar").font(.custom("EBGaramond-Italic", size: 15)).foregroundColor(wood.opacity(0.5)),
            at: CGPoint(x: scaffoldLeft, y: groundY - domeRadius * 0.5)
        )

        guard currentStep >= 2 else { return }

        // Step 2: Height dimension line (43m)
        let dimX = scaffoldRight + poleSpacing + 14
        let topPlatY = groundY - CGFloat(platformCount - 1) / CGFloat(platformCount) * domeRadius * 1.8

        var dimLine = Path()
        dimLine.move(to: CGPoint(x: dimX, y: groundY + 6))
        dimLine.addLine(to: CGPoint(x: dimX, y: topPlatY))
        context.stroke(dimLine, with: .color(color.opacity(0.5)), style: StrokeStyle(lineWidth: 1, dash: [4, 3]))

        for tickY in [groundY + 6, topPlatY] {
            var tick = Path()
            tick.move(to: CGPoint(x: dimX - 3, y: tickY))
            tick.addLine(to: CGPoint(x: dimX + 3, y: tickY))
            context.stroke(tick, with: .color(color.opacity(0.5)), lineWidth: 1)
        }

        context.draw(
            Text("43m").font(.custom("EBGaramond-SemiBold", size: 15)).foregroundColor(color),
            at: CGPoint(x: dimX + 16, y: (groundY + topPlatY) / 2)
        )

        // Worker dots on platforms
        for i in [1, 3] {
            let platformY = groundY - CGFloat(i) / CGFloat(platformCount) * domeRadius * 1.8
            for side in [scaffoldLeft, scaffoldRight] {
                var worker = Path()
                worker.addEllipse(in: CGRect(x: side - 3, y: platformY - 8, width: 6, height: 6))
                context.fill(worker, with: .color(sepiaInk.opacity(0.4)))
            }
        }

        guard currentStep >= 3 else { return }

        // Step 3: "Steps 2-5" labels + lifecycle
        context.draw(
            Text("Steps 2→3→4→5").font(.custom("EBGaramond-SemiBold", size: 15)).foregroundColor(color),
            at: CGPoint(x: centerX, y: groundY - domeRadius - 16)
        )

        context.draw(
            Text("walls → coffers → concrete → dome").font(.custom("EBGaramond-Italic", size: 15)).foregroundColor(sepiaInk.opacity(0.5)),
            at: CGPoint(x: centerX, y: groundY - domeRadius - 4)
        )
    }

    // MARK: - Coffers (sunken panels inside dome)

    private func drawCoffers(context: GraphicsContext, size: CGSize) {
        let w = size.width, h = size.height
        let sepiaInk = Color(red: 0.29, green: 0.25, blue: 0.21)
        let centerX = w * 0.5
        let baseY = h * 0.55
        let domeRadius = min(w * 0.35, baseY - 8)
        let domeCenter = CGPoint(x: centerX, y: baseY)

        // Step 1: Dome outline with coffer grid inside
        // Dome arc
        var dome = Path()
        dome.addArc(center: domeCenter, radius: domeRadius, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
        context.stroke(dome, with: .color(sepiaInk), lineWidth: 2)
        context.fill(dome, with: .color(color.opacity(0.03)))

        // Floor/walls
        var floor = Path()
        floor.move(to: CGPoint(x: centerX - domeRadius - 5, y: baseY))
        floor.addLine(to: CGPoint(x: centerX + domeRadius + 5, y: baseY))
        context.stroke(floor, with: .color(sepiaInk.opacity(0.4)), lineWidth: 1.5)

        for wallX in [centerX - domeRadius, centerX + domeRadius] {
            var wall = Path()
            wall.move(to: CGPoint(x: wallX, y: baseY))
            wall.addLine(to: CGPoint(x: wallX, y: baseY + 8))
            context.stroke(wall, with: .color(sepiaInk), lineWidth: 2)
        }

        // Coffer rows (concentric arcs inside the dome)
        let cofferRows = 5  // representative rows (28 would be too dense)
        for row in 0..<cofferRows {
            let t = CGFloat(row + 1) / CGFloat(cofferRows + 1)
            let arcRadius = domeRadius * (1.0 - t * 0.7)

            // Row arc
            var rowArc = Path()
            rowArc.addArc(center: domeCenter, radius: arcRadius, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
            context.stroke(rowArc, with: .color(sepiaInk.opacity(0.15)), lineWidth: 0.5)

            // Individual coffer squares along this arc
            let cofferCount = max(3, 8 - row * 1)
            for col in 0..<cofferCount {
                let angle = Double.pi - (Double(col) + 0.5) / Double(cofferCount) * Double.pi
                let cx = centerX + arcRadius * cos(angle)
                let cy = baseY + arcRadius * sin(angle)
                let cofferSize = domeRadius * 0.08

                var coffer = Path()
                coffer.addRect(CGRect(x: cx - cofferSize / 2, y: cy - cofferSize / 2, width: cofferSize, height: cofferSize))
                context.fill(coffer, with: .color(color.opacity(0.08)))
                context.stroke(coffer, with: .color(sepiaInk.opacity(0.2)), lineWidth: 0.5)

                // Inner sunken square (the recessed panel look)
                let innerSize = cofferSize * 0.6
                var inner = Path()
                inner.addRect(CGRect(x: cx - innerSize / 2, y: cy - innerSize / 2, width: innerSize, height: innerSize))
                context.stroke(inner, with: .color(sepiaInk.opacity(0.12)), lineWidth: 0.3)
            }
        }

        // Oculus at top (hole — white opening)
        let oculusR = domeRadius * 0.1
        var oculus = Path()
        oculus.addEllipse(in: CGRect(x: centerX - oculusR, y: baseY - domeRadius - oculusR * 0.3, width: oculusR * 2, height: oculusR * 0.6))
        context.fill(oculus, with: .color(.white))
        context.stroke(oculus, with: .color(sepiaInk.opacity(0.4)), lineWidth: 1)

        // "28 rows" label
        context.draw(
            Text("28 rows of coffers").font(.custom("EBGaramond-Italic", size: 15)).foregroundColor(sepiaInk.opacity(0.5)),
            at: CGPoint(x: centerX, y: baseY - domeRadius * 0.5)
        )

        guard currentStep >= 2 else { return }

        // Step 2: Highlight coffers in color + show they're sunken
        for row in 0..<cofferRows {
            let t = CGFloat(row + 1) / CGFloat(cofferRows + 1)
            let arcRadius = domeRadius * (1.0 - t * 0.7)
            let cofferCount = max(3, 8 - row * 1)

            for col in 0..<cofferCount {
                let angle = Double.pi - (Double(col) + 0.5) / Double(cofferCount) * Double.pi
                let cx = centerX + arcRadius * cos(angle)
                let cy = baseY + arcRadius * sin(angle)
                let cofferSize = domeRadius * 0.08

                var coffer = Path()
                coffer.addRect(CGRect(x: cx - cofferSize / 2, y: cy - cofferSize / 2, width: cofferSize, height: cofferSize))
                context.fill(coffer, with: .color(color.opacity(0.15)))
                context.stroke(coffer, with: .color(color.opacity(0.4)), lineWidth: 0.8)
            }
        }

        // "sunken panel" label inside the dome
        context.draw(
            Text("each panel removes ~2 tons").font(.custom("EBGaramond-Italic", size: 15)).foregroundColor(color),
            at: CGPoint(x: centerX, y: baseY - domeRadius * 0.3)
        )

        guard currentStep >= 3 else { return }

        // Step 3: Weight comparison — solid vs hollowed (below dome with proper spacing)
        let barY = baseY + 20
        let barW = w * 0.7
        let barH: CGFloat = 16

        // Full weight bar (background — represents solid dome)
        var fullBar = Path()
        fullBar.addRoundedRect(in: CGRect(x: centerX - barW / 2, y: barY, width: barW, height: barH), cornerSize: CGSize(width: 4, height: 4))
        context.fill(fullBar, with: .color(sepiaInk.opacity(0.1)))
        context.stroke(fullBar, with: .color(sepiaInk.opacity(0.2)), lineWidth: 1)

        // Reduced weight bar (foreground — with coffers)
        let reducedW = barW * 0.65
        var reducedBar = Path()
        reducedBar.addRoundedRect(in: CGRect(x: centerX - barW / 2, y: barY, width: reducedW, height: barH), cornerSize: CGSize(width: 4, height: 4))
        context.fill(reducedBar, with: .color(color.opacity(0.2)))
        context.stroke(reducedBar, with: .color(color), lineWidth: 1.5)

        // Labels on bars
        context.draw(
            Text("4,535 t (with coffers)").font(.custom("EBGaramond-SemiBold", size: 15)).foregroundColor(color),
            at: CGPoint(x: centerX - barW / 2 + reducedW / 2, y: barY + barH / 2)
        )

        // Strikethrough section showing removed weight
        context.draw(
            Text("6,935 t").font(.custom("EBGaramond-Regular", size: 15)).foregroundColor(sepiaInk.opacity(0.4)),
            at: CGPoint(x: centerX - barW / 2 + barW * 0.85, y: barY + barH / 2)
        )

        // Summary below
        context.draw(
            Text("–2,400 tons removed by hollowing each panel").font(.custom("EBGaramond-SemiBold", size: 15)).foregroundColor(color),
            at: CGPoint(x: centerX, y: barY + barH + 14)
        )
    }

    // MARK: - Bronze Doors (7m tall double doors)

    private func drawBronzeDoors(context: GraphicsContext, size: CGSize) {
        let w = size.width, h = size.height
        let sepiaInk = Color(red: 0.29, green: 0.25, blue: 0.21)
        let centerX = w * 0.5
        let floorY = h * 0.88
        let doorH = h * 0.65
        let doorW = w * 0.18
        let doorTop = floorY - doorH
        let gap: CGFloat = 3  // gap between double doors

        // Step 1: Door frame (stone archway)
        // Stone frame
        let frameW = doorW * 2 + gap + 16
        var frame = Path()
        frame.addRect(CGRect(x: centerX - frameW / 2, y: doorTop - 12, width: frameW, height: doorH + 12))
        context.stroke(frame, with: .color(sepiaInk.opacity(0.3)), lineWidth: 2)

        // Semi-circular arch above doors
        var arch = Path()
        arch.addArc(center: CGPoint(x: centerX, y: doorTop), radius: frameW / 2, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
        context.stroke(arch, with: .color(sepiaInk.opacity(0.4)), lineWidth: 2)
        context.fill(arch, with: .color(sepiaInk.opacity(0.04)))

        // Left door
        var leftDoor = Path()
        leftDoor.addRect(CGRect(x: centerX - doorW - gap / 2, y: doorTop, width: doorW, height: doorH))
        context.fill(leftDoor, with: .color(Color.brown.opacity(0.15)))
        context.stroke(leftDoor, with: .color(Color.brown.opacity(0.5)), lineWidth: 1.5)

        // Right door
        var rightDoor = Path()
        rightDoor.addRect(CGRect(x: centerX + gap / 2, y: doorTop, width: doorW, height: doorH))
        context.fill(rightDoor, with: .color(Color.brown.opacity(0.15)))
        context.stroke(rightDoor, with: .color(Color.brown.opacity(0.5)), lineWidth: 1.5)

        // Door panels (decorative rectangles inside each door)
        for door in 0..<2 {
            let doorX = door == 0 ? centerX - doorW - gap / 2 : centerX + gap / 2
            for row in 0..<3 {
                let panelY = doorTop + 8 + CGFloat(row) * (doorH / 3)
                let panelH = doorH / 3 - 12
                var panel = Path()
                panel.addRect(CGRect(x: doorX + 6, y: panelY, width: doorW - 12, height: panelH))
                context.stroke(panel, with: .color(Color.brown.opacity(0.25)), lineWidth: 0.8)
            }
        }

        // Pivot dots
        for pivotY in [doorTop + 20, floorY - 20] {
            for dx: CGFloat in [-doorW - gap / 2, gap / 2 + doorW] {
                var pivot = Path()
                pivot.addEllipse(in: CGRect(x: centerX + dx - 3, y: pivotY - 3, width: 6, height: 6))
                context.fill(pivot, with: .color(Color.brown.opacity(0.4)))
            }
        }

        // Floor line
        var floor = Path()
        floor.move(to: CGPoint(x: w * 0.15, y: floorY))
        floor.addLine(to: CGPoint(x: w * 0.85, y: floorY))
        context.stroke(floor, with: .color(sepiaInk.opacity(0.2)), lineWidth: 1)

        guard currentStep >= 2 else { return }

        // Step 2: Height dimension line (7m)
        let dimX = centerX + frameW / 2 + 14
        var dimLine = Path()
        dimLine.move(to: CGPoint(x: dimX, y: doorTop))
        dimLine.addLine(to: CGPoint(x: dimX, y: floorY))
        context.stroke(dimLine, with: .color(color.opacity(0.5)), style: StrokeStyle(lineWidth: 1, dash: [4, 3]))

        for tickY in [doorTop, floorY] {
            var tick = Path()
            tick.move(to: CGPoint(x: dimX - 4, y: tickY))
            tick.addLine(to: CGPoint(x: dimX + 4, y: tickY))
            context.stroke(tick, with: .color(color.opacity(0.5)), lineWidth: 1)
        }

        if let doorHeight = visual.values["height"] {
            context.draw(
                Text("\(Int(doorHeight))m tall").font(.custom("EBGaramond-SemiBold", size: 15)).foregroundColor(color),
                at: CGPoint(x: dimX + 24, y: (doorTop + floorY) / 2)
            )
        }

        // "Bronze" material label
        context.draw(
            Text("bronze").font(.custom("EBGaramond-Italic", size: 15)).foregroundColor(Color.brown.opacity(0.6)),
            at: CGPoint(x: centerX, y: doorTop + doorH * 0.5)
        )

        guard currentStep >= 3 else { return }

        // Step 3: "200 tons melted" annotation
        if let melted = visual.values["melted"] {
            context.draw(
                Text("\(Int(melted)) tons melted by Urban VIII").font(.custom("EBGaramond-SemiBold", size: 15)).foregroundColor(color),
                at: CGPoint(x: centerX, y: doorTop - 24)
            )
        }

        // Pivot label
        context.draw(
            Text("swings on bronze pivots").font(.custom("EBGaramond-Italic", size: 15)).foregroundColor(sepiaInk.opacity(0.5)),
            at: CGPoint(x: centerX, y: floorY + 12)
        )
    }

    // MARK: - Centering (curved wooden arch frame under dome)

    private func drawCentering(context: GraphicsContext, size: CGSize) {
        let w = size.width, h = size.height
        let sepiaInk = Color(red: 0.29, green: 0.25, blue: 0.21)
        let centerX = w * 0.5
        let baseY = h * 0.7
        let archRadius = min(w * 0.4, baseY - 10)

        // Step 1: Wooden arch frame (curved beams)
        // Main arch
        var arch = Path()
        arch.addArc(center: CGPoint(x: centerX, y: baseY), radius: archRadius, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
        context.stroke(arch, with: .color(Color.brown.opacity(0.7)), lineWidth: 3)

        // Inner arch (thinner)
        var innerArch = Path()
        innerArch.addArc(center: CGPoint(x: centerX, y: baseY), radius: archRadius * 0.85, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
        context.stroke(innerArch, with: .color(Color.brown.opacity(0.4)), lineWidth: 1.5)

        // Radial support beams
        for i in 0..<7 {
            let angle = Double.pi - Double(i) / 6.0 * Double.pi
            let outerX = centerX + archRadius * cos(angle)
            let outerY = baseY + archRadius * sin(angle)
            let innerX = centerX + archRadius * 0.85 * cos(angle)
            let innerY = baseY + archRadius * 0.85 * sin(angle)

            var beam = Path()
            beam.move(to: CGPoint(x: innerX, y: innerY))
            beam.addLine(to: CGPoint(x: outerX, y: outerY))
            context.stroke(beam, with: .color(Color.brown.opacity(0.35)), lineWidth: 1)
        }

        // Vertical supports to ground
        var leftPost = Path()
        leftPost.move(to: CGPoint(x: centerX - archRadius, y: baseY))
        leftPost.addLine(to: CGPoint(x: centerX - archRadius, y: baseY + 15))
        context.stroke(leftPost, with: .color(Color.brown.opacity(0.6)), lineWidth: 3)

        var rightPost = Path()
        rightPost.move(to: CGPoint(x: centerX + archRadius, y: baseY))
        rightPost.addLine(to: CGPoint(x: centerX + archRadius, y: baseY + 15))
        context.stroke(rightPost, with: .color(Color.brown.opacity(0.6)), lineWidth: 3)

        // "OAK" label
        context.draw(
            Text("oak centering").font(.custom("EBGaramond-Italic", size: 15)).foregroundColor(Color.brown.opacity(0.6)),
            at: CGPoint(x: centerX, y: baseY - archRadius * 0.5)
        )

        guard currentStep >= 2 else { return }

        // Step 2: Load arrows pressing down on the arch (wet concrete weight)
        let arrowCount = Int(visual.values["arrows"] ?? 6)
        for i in 0..<arrowCount {
            let t = CGFloat(i + 1) / CGFloat(arrowCount + 1)
            let angle = Double.pi - Double(t) * Double.pi
            let targetX = centerX + archRadius * cos(angle)
            let targetY = baseY + archRadius * sin(angle)
            let startX = targetX
            let startY = targetY - 30

            drawArrow(context: context, from: CGPoint(x: startX, y: startY), to: CGPoint(x: targetX, y: targetY + 2), color: Color.red.opacity(0.5))
        }

        context.draw(
            Text("wet concrete").font(.custom("EBGaramond-Italic", size: 15)).foregroundColor(Color.red.opacity(0.5)),
            at: CGPoint(x: centerX, y: baseY - archRadius - 16)
        )

        guard currentStep >= 3 else { return }

        // Step 3: "3 weeks" label + annotations
        context.draw(
            Text("holds for 3 weeks → then removed").font(.custom("EBGaramond-SemiBold", size: 15)).foregroundColor(color),
            at: CGPoint(x: centerX, y: baseY + 30)
        )
    }

    // MARK: - Flow (animated path)

    private func drawFlow(context: GraphicsContext, size: CGSize) {
        let w = size.width, h = size.height
        let sepiaInk = Color(red: 0.29, green: 0.25, blue: 0.21)

        guard currentStep >= 1 else { return }

        // Channel path
        let startX = w * 0.08
        let endX = w * 0.92
        let channelY = h * 0.4
        let drop: CGFloat = currentStep >= 2 ? 30 : 0

        var channel = Path()
        channel.move(to: CGPoint(x: startX, y: channelY))
        channel.addLine(to: CGPoint(x: endX, y: channelY + drop))
        context.stroke(channel, with: .color(sepiaInk), lineWidth: 2)

        // Channel walls
        var topWall = Path()
        topWall.move(to: CGPoint(x: startX, y: channelY - 8))
        topWall.addLine(to: CGPoint(x: endX, y: channelY + drop - 8))
        context.stroke(topWall, with: .color(sepiaInk.opacity(0.3)), lineWidth: 1)

        guard currentStep >= 2 else { return }

        // Animated drops
        let dropCount = 5
        for i in 0..<dropCount {
            let baseT = CGFloat(i) / CGFloat(dropCount)
            let t = (baseT + animationPhase).truncatingRemainder(dividingBy: 1.0)
            let x = startX + t * (endX - startX)
            let y = channelY - 4 + t * drop

            var dot = Path()
            dot.addEllipse(in: CGRect(x: x - 3, y: y - 3, width: 6, height: 6))
            context.fill(dot, with: .color(RenaissanceColors.renaissanceBlue.opacity(0.6)))
        }

        // Labels
        if visual.labels.count >= 1 {
            context.draw(
                Text(visual.labels[0]).font(.custom("EBGaramond-SemiBold", size: 15)).foregroundColor(color),
                at: CGPoint(x: w / 2, y: h * 0.15)
            )
        }
    }

    // MARK: - Molecule (atom-bond structure)

    private func drawMolecule(context: GraphicsContext, size: CGSize) {
        let w = size.width, h = size.height
        let sepiaInk = Color(red: 0.29, green: 0.25, blue: 0.21)
        let centerX = w * 0.5, centerY = h * 0.45

        guard currentStep >= 1 else { return }

        // Central atom
        if let central = visual.labels.first {
            var centralCircle = Path()
            centralCircle.addEllipse(in: CGRect(x: centerX - 18, y: centerY - 18, width: 36, height: 36))
            context.fill(centralCircle, with: .color(color.opacity(0.15)))
            context.stroke(centralCircle, with: .color(color), lineWidth: 1.5)
            context.draw(
                Text(central).font(.custom("EBGaramond-SemiBold", size: 16)).foregroundColor(sepiaInk),
                at: CGPoint(x: centerX, y: centerY)
            )
        }

        guard currentStep >= 2, visual.labels.count > 1 else { return }

        // Surrounding atoms
        let bondedAtoms = Array(visual.labels.dropFirst())
        let angleStep = (2 * Double.pi) / Double(bondedAtoms.count)
        let bondLength: CGFloat = min(w, h) * 0.28

        for (i, atom) in bondedAtoms.enumerated() {
            let angle = angleStep * Double(i) - Double.pi / 2
            let x = centerX + bondLength * cos(angle)
            let y = centerY + bondLength * sin(angle)

            // Bond line
            var bond = Path()
            bond.move(to: CGPoint(x: centerX, y: centerY))
            bond.addLine(to: CGPoint(x: x, y: y))
            context.stroke(bond, with: .color(sepiaInk.opacity(0.4)), lineWidth: 1.5)

            // Atom circle
            var atomCircle = Path()
            atomCircle.addEllipse(in: CGRect(x: x - 14, y: y - 14, width: 28, height: 28))
            context.fill(atomCircle, with: .color(RenaissanceColors.parchment))
            context.stroke(atomCircle, with: .color(sepiaInk.opacity(0.5)), lineWidth: 1)
            context.draw(
                Text(atom).font(.custom("EBGaramond-Regular", size: 15)).foregroundColor(sepiaInk),
                at: CGPoint(x: x, y: y)
            )
        }

        // Formula label
        if currentStep >= 3, let formula = visual.caption {
            context.draw(
                Text(formula).font(.custom("EBGaramond-SemiBold", size: 15)).foregroundColor(color),
                at: CGPoint(x: centerX, y: h * 0.88)
            )
        }
    }

    // MARK: - Comparison (side-by-side with transformation arrow)

    private func drawComparison(context: GraphicsContext, size: CGSize) {
        let w = size.width, h = size.height
        let sepiaInk = Color(red: 0.29, green: 0.25, blue: 0.21)

        guard visual.labels.count >= 2 else { return }

        let leftX = w * 0.25, rightX = w * 0.75
        let boxW: CGFloat = w * 0.36, boxH: CGFloat = h * 0.45
        let boxY = h * 0.1

        // Step 1: Left item
        var leftBox = Path()
        leftBox.addRoundedRect(in: CGRect(x: leftX - boxW / 2, y: boxY, width: boxW, height: boxH), cornerSize: CGSize(width: 8, height: 8))
        context.fill(leftBox, with: .color(color.opacity(0.1)))
        context.stroke(leftBox, with: .color(color.opacity(0.4)), lineWidth: 1.5)

        // Split multiline labels
        let leftLines = visual.labels[0].split(separator: "\n")
        for (i, line) in leftLines.enumerated() {
            let font: Font = i == 0 ? .custom("EBGaramond-SemiBold", size: 15) : .custom("EBGaramond-Regular", size: 15)
            let textColor = i == 0 ? sepiaInk : sepiaInk.opacity(0.6)
            context.draw(
                Text(String(line)).font(font).foregroundColor(textColor),
                at: CGPoint(x: leftX, y: boxY + boxH * 0.35 + CGFloat(i) * 18)
            )
        }

        guard currentStep >= 2 else { return }

        // Step 2: Arrow between + right item
        let arrowY = boxY + boxH / 2
        let isEqual = visual.values["equal"] == 1

        // Transformation arrow
        drawArrow(context: context, from: CGPoint(x: leftX + boxW / 2 + 8, y: arrowY), to: CGPoint(x: rightX - boxW / 2 - 8, y: arrowY), color: color)

        // "=" or transformation label above arrow
        let arrowLabel = isEqual ? "= same formula" : "heat + pressure"
        context.draw(
            Text(arrowLabel).font(.custom("EBGaramond-Italic", size: 15)).foregroundColor(color.opacity(0.7)),
            at: CGPoint(x: w / 2, y: arrowY - 14)
        )

        // Right box
        var rightBox = Path()
        rightBox.addRoundedRect(in: CGRect(x: rightX - boxW / 2, y: boxY, width: boxW, height: boxH), cornerSize: CGSize(width: 8, height: 8))
        context.fill(rightBox, with: .color(color.opacity(0.05)))
        context.stroke(rightBox, with: .color(sepiaInk.opacity(0.3)), lineWidth: 1.5)

        let rightLines = visual.labels[1].split(separator: "\n")
        for (i, line) in rightLines.enumerated() {
            let font: Font = i == 0 ? .custom("EBGaramond-SemiBold", size: 15) : .custom("EBGaramond-Regular", size: 15)
            let textColor = i == 0 ? sepiaInk : sepiaInk.opacity(0.6)
            context.draw(
                Text(String(line)).font(font).foregroundColor(textColor),
                at: CGPoint(x: rightX, y: boxY + boxH * 0.35 + CGFloat(i) * 18)
            )
        }

        guard currentStep >= 3, visual.labels.count >= 3 else { return }

        // Step 3: Key insight below
        context.draw(
            Text(visual.labels[2]).font(.custom("EBGaramond-Italic", size: 15)).foregroundColor(color),
            at: CGPoint(x: w / 2, y: boxY + boxH + 20)
        )
    }

    // MARK: - Mechanism (placeholder — gears/press/pulleys)

    private func drawMechanism(context: GraphicsContext, size: CGSize) {
        // Placeholder for future mechanism visuals
        drawGeometry(context: context, size: size)
    }

    // MARK: - Arrow Helper

    private func drawArrow(context: GraphicsContext, from: CGPoint, to: CGPoint, color: Color) {
        var line = Path()
        line.move(to: from)
        line.addLine(to: to)
        context.stroke(line, with: .color(color), lineWidth: 1.5)

        // Arrowhead
        let angle = atan2(to.y - from.y, to.x - from.x)
        let headLen: CGFloat = 7
        var head = Path()
        head.move(to: to)
        head.addLine(to: CGPoint(x: to.x - headLen * cos(angle - .pi / 6), y: to.y - headLen * sin(angle - .pi / 6)))
        head.addLine(to: CGPoint(x: to.x - headLen * cos(angle + .pi / 6), y: to.y - headLen * sin(angle + .pi / 6)))
        head.closeSubpath()
        context.fill(head, with: .color(color))
    }
}
