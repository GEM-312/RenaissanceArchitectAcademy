import SwiftUI

/// Interactive science visuals for Anatomy Theater knowledge cards (11 cards)
struct AnatomyTheaterInteractiveVisuals {

    @ViewBuilder
    static func view(for visual: CardVisual, color: Color, height: CGFloat = 275) -> some View {
        let h = height
        Group {
            switch visual.title {
            case let t where t.contains("Vesalius"):
                VesaliusVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Funnel Shape"):
                FunnelShapeVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Candlelight"):
                CandlelightVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Sight Lines"):
                SightLinesVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Bronze Pivot"):
                BronzePivotVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Scalpel"):
                ScalpelSteelVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Timber Prep"):
                TimberPrepVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Walnut Carvings"):
                WalnutCarvingVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Oak Structure"):
                OakStructureVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Cypress"):
                CypressVentVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Carving Tools"):
                CarvingToolsVisual(visual: visual, color: color, height: h)
            default:
                EmptyView()
            }
        }
    }

    static func hasInteractiveVisual(for visual: CardVisual) -> Bool {
        let t = visual.title
        return t.contains("Vesalius") || t.contains("Funnel Shape") ||
               t.contains("Candlelight") || t.contains("Sight Lines") ||
               t.contains("Bronze Pivot") || t.contains("Scalpel") ||
               t.contains("Timber Prep") || t.contains("Walnut Carvings") ||
               t.contains("Oak Structure") || t.contains("Cypress") ||
               t.contains("Carving Tools")
    }
}

// MARK: - Local Colors

private let walnutBrown = Color(red: 0.45, green: 0.32, blue: 0.20)
private let oakTan = Color(red: 0.60, green: 0.48, blue: 0.32)
private let cypressGreen = Color(red: 0.35, green: 0.50, blue: 0.30)
private let steelGray = Color(red: 0.55, green: 0.55, blue: 0.58)
private let candleYellow = Color(red: 0.95, green: 0.85, blue: 0.45)

private typealias TeachingContainer = IVTeachingContainer
private typealias DimLabel = IVDimLabel
private typealias FormulaText = IVFormulaText
private typealias DimLine = IVDimLine

// MARK: - 1. Vesalius Revolution

private struct VesaliusVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 340
    @State private var step: Int = 1

    private let dogmaBlue = Color(red: 0.28, green: 0.35, blue: 0.52)
    private let observationRed = Color(red: 0.65, green: 0.22, blue: 0.18)
    private let sageGreen = Color(red: 0.30, green: 0.58, blue: 0.32)

    private let labels = ["1543 — Vesalius publishes De Humani Corporis Fabrica",
                          "Galen dissected pigs and monkeys — wrong about humans for 1,300 years",
                          "700 pages of woodcut illustrations changed medicine forever"]

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            VStack(spacing: 0) {
                // Top split: OLD DOGMA vs NEW OBSERVATION
                HStack(spacing: 0) {
                    // Left — Galen / Old Dogma
                    VStack(spacing: 6) {
                        Text("THE OLD DOGMA")
                            .font(.custom("Cinzel-Bold", size: 15))
                            .foregroundStyle(dogmaBlue)
                        Text("(Pre-1543)")
                            .font(RenaissanceFont.ivBody)
                            .foregroundStyle(dogmaBlue.opacity(0.6))

                        RoundedRectangle(cornerRadius: 8)
                            .fill(dogmaBlue.opacity(step >= 2 ? 0.12 : 0.06))
                            .frame(height: 70)
                            .overlay {
                                VStack(spacing: 4) {
                                    Text("🐒")
                                        .font(.system(size: 30))
                                        .opacity(step >= 2 ? 1.0 : 0.3)
                                    Text("Animal Myths")
                                        .font(RenaissanceFont.ivLabel)
                                        .foregroundStyle(dogmaBlue)
                                }
                            }
                            .overlay(alignment: .topTrailing) {
                                if step >= 2 {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 18))
                                        .foregroundStyle(.red.opacity(0.6))
                                        .offset(x: 6, y: -6)
                                }
                            }

                        if step >= 2 {
                            Text("Galen dissected\npigs & monkeys")
                                .font(RenaissanceFont.ivBody)
                                .foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.6))
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                                .transition(.opacity)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 6)

                    // Center divider
                    Rectangle()
                        .fill(IVMaterialColors.sepiaInk.opacity(0.15))
                        .frame(width: 1.5)
                        .padding(.vertical, 8)

                    // Right — Vesalius / New Observation
                    VStack(spacing: 6) {
                        Text("NEW OBSERVATION")
                            .font(.custom("Cinzel-Bold", size: 15))
                            .foregroundStyle(observationRed)
                        Text("(Vesalius)")
                            .font(RenaissanceFont.ivBody)
                            .foregroundStyle(observationRed.opacity(0.6))

                        RoundedRectangle(cornerRadius: 8)
                            .fill(observationRed.opacity(step >= 1 ? 0.12 : 0.06))
                            .frame(height: 70)
                            .overlay {
                                VStack(spacing: 4) {
                                    Text("🫀")
                                        .font(.system(size: 30))
                                        .opacity(step >= 1 ? 1.0 : 0.3)
                                    Text("Human Reality")
                                        .font(RenaissanceFont.ivLabel)
                                        .foregroundStyle(observationRed)
                                }
                            }
                            .overlay(alignment: .topTrailing) {
                                if step >= 1 {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 18))
                                        .foregroundStyle(sageGreen.opacity(0.7))
                                        .offset(x: 6, y: -6)
                                }
                            }

                        if step >= 1 {
                            Text("Seeing is\nCorrecting")
                                .font(RenaissanceFont.ivLabel)
                                .foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.7))
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                                .transition(.opacity)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 6)
                }
                .padding(.top, 4)

                Spacer().frame(height: 10)

                // Bottom: 700 pages callout
                if step >= 3 {
                    VStack(spacing: 4) {
                        HStack(spacing: 6) {
                            Image(systemName: "book.pages")
                                .font(.system(size: 20))
                                .foregroundStyle(color)
                            Text("700")
                                .font(.custom("Cinzel-Bold", size: 28))
                                .foregroundStyle(color)
                            Text("Pages")
                                .font(.custom("EBGaramond-Regular", size: 18))
                                .foregroundStyle(IVMaterialColors.sepiaInk)
                        }
                        Text("of Revolutionary Science")
                            .font(.custom("EBGaramond-Italic", size: 16))
                            .foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.6))
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(color.opacity(0.06))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .strokeBorder(color.opacity(0.15), lineWidth: 1)
                            )
                    )
                    .transition(.scale(scale: 0.9).combined(with: .opacity))
                }
            }
            .animation(.easeInOut(duration: 0.4), value: step)
        }
    }
}

// MARK: - 2. Funnel Shape — Inverted Cone

private struct FunnelShapeVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 340
    @State private var step: Int = 1

    private let labels = ["The inverted funnel — narrow at bottom, wide at top",
                          "6 concentric oval tiers — 300 students stand and look down",
                          "11 meters wide at top, just 2 meters at the dissection table"]

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            Canvas { ctx, size in
                let cx = size.width / 2
                let tiers = 6
                let topY: CGFloat = size.height * 0.04
                let bottomY: CGFloat = size.height * 0.78
                let minW: CGFloat = size.width * 0.14  // Bottom tier (2m)
                let maxW: CGFloat = size.width * 0.75   // Top tier (11m)
                let tierH = (bottomY - topY) / CGFloat(tiers)
                let railColor = walnutBrown

                // Arched alcove behind dissection table
                let alcoveW: CGFloat = minW * 1.6
                let alcoveH: CGFloat = tierH * 1.3
                let alcoveY = bottomY - 2
                var alcove = Path()
                alcove.move(to: CGPoint(x: cx - alcoveW / 2, y: alcoveY + alcoveH))
                alcove.addLine(to: CGPoint(x: cx - alcoveW / 2, y: alcoveY + alcoveH * 0.3))
                alcove.addQuadCurve(to: CGPoint(x: cx + alcoveW / 2, y: alcoveY + alcoveH * 0.3),
                                    control: CGPoint(x: cx, y: alcoveY - alcoveH * 0.1))
                alcove.addLine(to: CGPoint(x: cx + alcoveW / 2, y: alcoveY + alcoveH))
                alcove.closeSubpath()
                ctx.fill(alcove, with: .color(Color(red: 0.88, green: 0.80, blue: 0.68).opacity(0.4)))
                ctx.stroke(alcove, with: .color(IVMaterialColors.sepiaInk.opacity(0.2)), lineWidth: 0.8)

                // Dissection table
                let tableW: CGFloat = minW * 0.7
                let tableH: CGFloat = 6.0
                let tableY = alcoveY + alcoveH * 0.6
                let tableRect = CGRect(x: cx - tableW / 2, y: tableY, width: tableW, height: tableH)
                ctx.fill(Path(roundedRect: tableRect, cornerRadius: 1.5), with: .color(walnutBrown.opacity(0.6)))
                // Table legs
                let legW: CGFloat = 2
                ctx.fill(Path(CGRect(x: cx - tableW / 2 + 4, y: tableY + tableH, width: legW, height: 8)),
                         with: .color(walnutBrown.opacity(0.4)))
                ctx.fill(Path(CGRect(x: cx + tableW / 2 - 6, y: tableY + tableH, width: legW, height: 8)),
                         with: .color(walnutBrown.opacity(0.4)))

                // 6 tiers — drawn from bottom (narrow) to top (wide)
                for i in 0..<tiers {
                    let showTier = step >= 2 || i < 3
                    guard showTier else { continue }

                    let t = CGFloat(i) / CGFloat(tiers - 1)  // 0 = bottom, 1 = top
                    let w = minW + t * (maxW - minW)
                    let y = bottomY - CGFloat(i + 1) * tierH

                    // Tier platform (3D-ish trapezoid)
                    let tierDepth: CGFloat = tierH * 0.55
                    let nextW = i < tiers - 1 ? minW + CGFloat(i + 1) / CGFloat(tiers - 1) * (maxW - minW) : w
                    var tierPath = Path()
                    tierPath.move(to: CGPoint(x: cx - w / 2, y: y + tierDepth))
                    tierPath.addLine(to: CGPoint(x: cx - w / 2, y: y))
                    tierPath.addLine(to: CGPoint(x: cx + w / 2, y: y))
                    tierPath.addLine(to: CGPoint(x: cx + w / 2, y: y + tierDepth))
                    tierPath.closeSubpath()

                    let tierFill = Color(red: 0.72 - t * 0.08, green: 0.58 - t * 0.06, blue: 0.38 - t * 0.04)
                    ctx.fill(tierPath, with: .color(tierFill.opacity(0.25 + t * 0.1)))
                    ctx.stroke(tierPath, with: .color(IVMaterialColors.sepiaInk.opacity(0.25)), lineWidth: 0.8)

                    // Railing at top edge of each tier
                    let railY = y + 2
                    var rail = Path()
                    rail.move(to: CGPoint(x: cx - w / 2 + 2, y: railY))
                    rail.addLine(to: CGPoint(x: cx + w / 2 - 2, y: railY))
                    ctx.stroke(rail, with: .color(railColor.opacity(0.4)), lineWidth: 1.2)

                    // Railing posts
                    let postCount = 3 + i * 2
                    for p in 0..<postCount {
                        let px = cx - w * 0.42 + CGFloat(p) * (w * 0.84 / CGFloat(max(1, postCount - 1)))
                        var post = Path()
                        post.move(to: CGPoint(x: px, y: railY))
                        post.addLine(to: CGPoint(x: px, y: railY + tierDepth * 0.5))
                        ctx.stroke(post, with: .color(railColor.opacity(0.25)), lineWidth: 0.6)
                    }

                    // People silhouettes on tier
                    if step >= 2 {
                        let people = 2 + i * 2
                        for p in 0..<people {
                            let px = cx - w * 0.38 + CGFloat(p) * (w * 0.76 / CGFloat(max(1, people - 1)))
                            let personY = y + 4
                            // Head
                            let head = Path(ellipseIn: CGRect(x: px - 2.5, y: personY, width: 5, height: 5))
                            ctx.fill(head, with: .color(IVMaterialColors.sepiaInk.opacity(0.25)))
                            // Body
                            var body = Path()
                            body.move(to: CGPoint(x: px, y: personY + 5))
                            body.addLine(to: CGPoint(x: px - 3, y: personY + tierDepth * 0.7))
                            body.addLine(to: CGPoint(x: px + 3, y: personY + tierDepth * 0.7))
                            body.closeSubpath()
                            ctx.fill(body, with: .color(IVMaterialColors.sepiaInk.opacity(0.15)))
                        }
                    }
                }

                // --- Dimension lines & labels ---
                if step >= 3 {
                    let topTierY = bottomY - CGFloat(tiers) * tierH
                    // Top dimension: 11 meters
                    ctx.stroke(IVDimLine(from: CGPoint(x: cx - maxW / 2, y: topTierY - 8),
                                         to: CGPoint(x: cx + maxW / 2, y: topTierY - 8), tickSize: 4).path(in: .zero),
                               with: .color(IVMaterialColors.dimColor), lineWidth: 0.8)
                    let topLabel = ctx.resolve(Text("11 m").font(RenaissanceFont.ivLabel).foregroundColor(IVMaterialColors.dimColor))
                    ctx.draw(topLabel, at: CGPoint(x: cx, y: topTierY - 16))

                    // Bottom dimension: 2 meters
                    let botDimY = bottomY + 4
                    ctx.stroke(IVDimLine(from: CGPoint(x: cx - minW / 2, y: botDimY),
                                         to: CGPoint(x: cx + minW / 2, y: botDimY), tickSize: 3).path(in: .zero),
                               with: .color(IVMaterialColors.dimColor), lineWidth: 0.8)
                    let botLabel = ctx.resolve(Text("2 m").font(RenaissanceFont.ivLabel).foregroundColor(IVMaterialColors.dimColor))
                    ctx.draw(botLabel, at: CGPoint(x: cx, y: botDimY + 10))
                }

                // --- Callout labels ---
                if step >= 1 {
                    // "Standing Room Only" — left side
                    let calloutFont = Font.custom("EBGaramond-SemiBold", size: 15)
                    let standingLabel = ctx.resolve(Text("Standing\nRoom Only")
                        .font(calloutFont).foregroundColor(IVMaterialColors.sepiaInk.opacity(0.7)))
                    let midTierY = bottomY - 3.5 * tierH
                    ctx.draw(standingLabel, at: CGPoint(x: size.width * 0.08, y: midTierY), anchor: .leading)

                    // Leader line from label to tier
                    let midTierW = minW + 2.5 / CGFloat(tiers - 1) * (maxW - minW)
                    var leader = Path()
                    leader.move(to: CGPoint(x: size.width * 0.22, y: midTierY))
                    leader.addLine(to: CGPoint(x: cx - midTierW / 2 - 2, y: midTierY))
                    ctx.stroke(leader, with: .color(IVMaterialColors.sepiaInk.opacity(0.3)), lineWidth: 0.6)
                }

                if step >= 2 {
                    // "Bird's-Eye View" — right side
                    let calloutFont = Font.custom("EBGaramond-SemiBold", size: 15)
                    let birdLabel = ctx.resolve(Text("Bird's-Eye\nView ↓")
                        .font(calloutFont).foregroundColor(IVMaterialColors.sepiaInk.opacity(0.7)))
                    let upperTierY = bottomY - 4.5 * tierH
                    ctx.draw(birdLabel, at: CGPoint(x: size.width * 0.92, y: upperTierY), anchor: .trailing)
                }

                if step >= 1 {
                    // "Dissection Table" label below alcove
                    let tableLabel = ctx.resolve(Text("Central Dissection Table")
                        .font(RenaissanceFont.ivBody).foregroundColor(IVMaterialColors.sepiaInk.opacity(0.5)))
                    ctx.draw(tableLabel, at: CGPoint(x: cx, y: bottomY + (step >= 3 ? 22 : 14)))
                }
            }
            .animation(.easeInOut(duration: 0.4), value: step)
        }
    }
}

// MARK: - 3. Candlelight — Shadowless Illumination

private struct CandlelightVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1

    private let labels = ["Dissections in winter — no windows, candles only",
                          "Each student holds a candle at 45° toward the table",
                          "300 candles = shadowless ring light from every direction"]

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            Canvas { ctx, size in
                let cx = size.width / 2, cy = size.height * 0.45

                // Table at center
                let tableR: CGFloat = 12
                let table = Path(ellipseIn: CGRect(x: cx - tableR, y: cy - tableR * 0.6, width: tableR * 2, height: tableR * 1.2))
                ctx.fill(table, with: .color(walnutBrown.opacity(0.4)))

                // Candle ring
                let candleCount = step >= 3 ? 12 : step >= 2 ? 6 : 0
                let ringR = min(size.width, size.height) * 0.32

                for i in 0..<candleCount {
                    let angle = CGFloat(i) * (2 * .pi / CGFloat(candleCount)) - .pi / 2
                    let candleX = cx + cos(angle) * ringR
                    let candleY = cy + sin(angle) * ringR

                    // Candle flame
                    var flame = Path()
                    flame.move(to: CGPoint(x: candleX, y: candleY - 5))
                    flame.addQuadCurve(to: CGPoint(x: candleX, y: candleY + 2),
                                       control: CGPoint(x: candleX + 3, y: candleY - 2))
                    flame.addQuadCurve(to: CGPoint(x: candleX, y: candleY - 5),
                                       control: CGPoint(x: candleX - 3, y: candleY - 2))
                    ctx.fill(flame, with: .color(candleYellow.opacity(0.6)))

                    // Light ray toward center (45°)
                    if step >= 2 {
                        var ray = Path()
                        ray.move(to: CGPoint(x: candleX, y: candleY))
                        ray.addLine(to: CGPoint(x: cx + cos(angle) * tableR * 1.2, y: cy + sin(angle) * tableR * 0.7))
                        ctx.stroke(ray, with: .color(candleYellow.opacity(0.15)), lineWidth: 1)
                    }
                }

                // Step 3: glow at center (shadowless)
                if step >= 3 {
                    let glow = Path(ellipseIn: CGRect(x: cx - tableR * 1.5, y: cy - tableR, width: tableR * 3, height: tableR * 2))
                    ctx.fill(glow, with: .color(candleYellow.opacity(0.08)))
                }
            }
        }
    }
}

// MARK: - 4. Sight Lines Geometry

private struct SightLinesVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1

    private let labels = ["Each tier: +30 cm rise, +40 cm setback from tier below",
                          "90 cm railings — waist-high, see over from tier above",
                          "300 positions, zero dead angles — geometry as democracy"]

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            Canvas { ctx, size in
                let startX: CGFloat = 30, tableX: CGFloat = 20
                let baseY = size.height * 0.7
                let tiers = 5
                let risePerTier: CGFloat = 18
                let setbackPerTier: CGFloat = 22

                // Table
                let tableRect = CGRect(x: tableX - 8, y: baseY - 4, width: 16, height: 8)
                ctx.fill(Path(tableRect), with: .color(walnutBrown.opacity(0.5)))

                for i in 0..<tiers {
                    let x = startX + CGFloat(i) * setbackPerTier
                    let y = baseY - CGFloat(i) * risePerTier

                    // Tier step
                    let stepRect = CGRect(x: x, y: y - risePerTier, width: setbackPerTier, height: risePerTier)
                    ctx.fill(Path(stepRect), with: .color(walnutBrown.opacity(0.08 + CGFloat(i) * 0.03)))
                    ctx.stroke(Path(stepRect), with: .color(IVMaterialColors.sepiaInk.opacity(0.2)), lineWidth: 0.5)

                    // Person dot
                    let personX = x + setbackPerTier * 0.5
                    let personY = y - risePerTier - 3
                    let head = Path(ellipseIn: CGRect(x: personX - 2, y: personY - 2, width: 4, height: 4))
                    ctx.fill(head, with: .color(IVMaterialColors.sepiaInk.opacity(0.35)))

                    // Sight line to table (step 1+)
                    if step >= 1 {
                        var sightLine = Path()
                        sightLine.move(to: CGPoint(x: personX, y: personY))
                        sightLine.addLine(to: CGPoint(x: tableX, y: baseY - 4))
                        ctx.stroke(sightLine, with: .color(color.opacity(0.2)),
                                   style: StrokeStyle(lineWidth: 0.5, dash: [3, 2]))
                    }

                    // Railing (step 2+)
                    if step >= 2 {
                        let railH: CGFloat = 10  // represents 90cm
                        var rail = Path()
                        rail.move(to: CGPoint(x: x, y: y - risePerTier))
                        rail.addLine(to: CGPoint(x: x, y: y - risePerTier - railH))
                        ctx.stroke(rail, with: .color(walnutBrown.opacity(0.4)), lineWidth: 1.5)
                    }
                }

                // Step 1: dimension annotations
                if step >= 1 {
                    // Rise dimension
                    let riseX = startX - 10
                    ctx.stroke(IVDimLine(from: CGPoint(x: riseX, y: baseY),
                                         to: CGPoint(x: riseX, y: baseY - risePerTier)).path(in: .zero),
                               with: .color(IVMaterialColors.dimColor), lineWidth: 0.5)
                }
            }
        }
    }
}

// MARK: - 5. Bronze Pivot

private struct BronzePivotVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1

    private let labels = ["Tapered cone bearing — borrowed from Roman door hinges",
                          "Bronze-on-bronze with weekly oiling = silent rotation",
                          "Table rotates to face any tier — simplest mechanism"]

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            Canvas { ctx, size in
                let cx = size.width / 2, cy = size.height * 0.4

                // Table (top view)
                let tableW: CGFloat = 60, tableH: CGFloat = 30
                let table = Path(ellipseIn: CGRect(x: cx - tableW / 2, y: cy - tableH / 2, width: tableW, height: tableH))
                ctx.fill(table, with: .color(walnutBrown.opacity(0.3)))
                ctx.stroke(table, with: .color(IVMaterialColors.sepiaInk.opacity(0.3)), lineWidth: 1)

                // Pivot center
                let pivotR: CGFloat = 5
                let pivot = Path(ellipseIn: CGRect(x: cx - pivotR, y: cy - pivotR, width: pivotR * 2, height: pivotR * 2))
                ctx.fill(pivot, with: .color(IVMaterialColors.bronzeGold.opacity(step >= 1 ? 0.7 : 0.2)))
                ctx.stroke(pivot, with: .color(IVMaterialColors.sepiaInk.opacity(0.4)), lineWidth: 1)

                // Step 2: rotation arrows
                if step >= 2 {
                    var arc = Path()
                    arc.addArc(center: CGPoint(x: cx, y: cy), radius: tableW / 2 + 10,
                               startAngle: .degrees(-60), endAngle: .degrees(200), clockwise: false)
                    ctx.stroke(arc, with: .color(color.opacity(0.4)),
                               style: StrokeStyle(lineWidth: 1.5, dash: [4, 3]))

                    // Arrow tip
                    let tipAngle: CGFloat = 200 * .pi / 180
                    let tipX = cx + cos(tipAngle) * (tableW / 2 + 10)
                    let tipY = cy + sin(tipAngle) * (tableW / 2 + 10)
                    var tip = Path()
                    tip.move(to: CGPoint(x: tipX, y: tipY))
                    tip.addLine(to: CGPoint(x: tipX + 5, y: tipY - 3))
                    tip.addLine(to: CGPoint(x: tipX + 2, y: tipY + 4))
                    ctx.stroke(tip, with: .color(color.opacity(0.4)), lineWidth: 1.5)
                }

                // Step 3: cross-section of tapered cone below
                if step >= 3 {
                    let coneY = cy + tableH / 2 + 20
                    // Cone (inverted triangle)
                    var cone = Path()
                    cone.move(to: CGPoint(x: cx - 10, y: coneY))
                    cone.addLine(to: CGPoint(x: cx, y: coneY + 25))
                    cone.addLine(to: CGPoint(x: cx + 10, y: coneY))
                    cone.closeSubpath()
                    ctx.fill(cone, with: .color(IVMaterialColors.bronzeGold.opacity(0.4)))
                    ctx.stroke(cone, with: .color(IVMaterialColors.sepiaInk.opacity(0.3)), lineWidth: 1)

                    // Socket
                    var socket = Path()
                    socket.move(to: CGPoint(x: cx - 12, y: coneY))
                    socket.addLine(to: CGPoint(x: cx - 2, y: coneY + 28))
                    socket.move(to: CGPoint(x: cx + 12, y: coneY))
                    socket.addLine(to: CGPoint(x: cx + 2, y: coneY + 28))
                    ctx.stroke(socket, with: .color(IVMaterialColors.sepiaInk.opacity(0.2)), lineWidth: 1)
                }
            }
        }
    }
}

// MARK: - 6. Scalpel Steel

private struct ScalpelSteelVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1

    private let labels = ["High-carbon steel: iron + 1.5% carbon, Rockwell 60",
                          "15° edge angle — half a butcher's knife",
                          "Bronze handle resists blood corrosion"]

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            Canvas { ctx, size in
                let cx = size.width / 2, bladeY = size.height * 0.35

                // Handle (bronze)
                let handleRect = CGRect(x: cx - 50, y: bladeY - 5, width: 40, height: 10)
                ctx.fill(Path(roundedRect: handleRect, cornerRadius: 3),
                         with: .color(step >= 3 ? IVMaterialColors.bronzeGold.opacity(0.5) : IVMaterialColors.sepiaInk.opacity(0.1)))
                ctx.stroke(Path(roundedRect: handleRect, cornerRadius: 3),
                           with: .color(IVMaterialColors.sepiaInk.opacity(0.3)), lineWidth: 1)

                // Blade (steel)
                var blade = Path()
                blade.move(to: CGPoint(x: cx - 10, y: bladeY - 4))
                blade.addLine(to: CGPoint(x: cx + 45, y: bladeY - 1))
                blade.addLine(to: CGPoint(x: cx + 50, y: bladeY))
                blade.addLine(to: CGPoint(x: cx + 45, y: bladeY + 1))
                blade.addLine(to: CGPoint(x: cx - 10, y: bladeY + 4))
                blade.closeSubpath()
                ctx.fill(blade, with: .color(steelGray.opacity(step >= 1 ? 0.6 : 0.2)))
                ctx.stroke(blade, with: .color(IVMaterialColors.sepiaInk.opacity(0.4)), lineWidth: 0.5)

                // Step 2: angle indicator at tip
                if step >= 2 {
                    let tipX = cx + 48, tipY = bladeY
                    var angleArc = Path()
                    angleArc.addArc(center: CGPoint(x: CGFloat(tipX), y: CGFloat(tipY)),
                                    radius: 15, startAngle: .degrees(-15), endAngle: .degrees(15), clockwise: false)
                    ctx.stroke(angleArc, with: .color(IVMaterialColors.dimColor.opacity(0.6)), lineWidth: 1)
                }

                // Step 1: composition
                if step >= 1 {
                    let compY = bladeY + 30
                    let compRect = CGRect(x: cx - 40, y: compY, width: 80, height: 16)
                    ctx.fill(Path(roundedRect: compRect, cornerRadius: 3), with: .color(steelGray.opacity(0.08)))
                }
            }
            .overlay(alignment: .bottom) {
                if step >= 1 {
                    Text("Fe + 1.5% C → Rockwell 60")
                        .font(RenaissanceFont.ivFormula)
                        .foregroundStyle(color)
                        .offset(y: -28)
                }
            }
        }
    }
}

// MARK: - 7. Timber Prep — River Soaking

private struct TimberPrepVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1

    private let labels = ["Walnut logs soaked in river water for 6 months",
                          "Water dissolves sap and tannins — prevents cracking",
                          "1 year air-drying after. Total: 18 months prep"]

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            HStack(spacing: 8) {
                // River soak
                VStack(spacing: 4) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(IVMaterialColors.waterBlue.opacity(step >= 1 ? 0.15 : 0.05))
                            .frame(height: 50)
                        RoundedRectangle(cornerRadius: 3)
                            .fill(walnutBrown.opacity(step >= 1 ? 0.5 : 0.15))
                            .frame(width: 25, height: 35)
                    }
                    Text("6 mo")
                        .font(RenaissanceFont.ivFormula)
                        .foregroundStyle(step >= 1 ? IVMaterialColors.waterBlue : IVMaterialColors.waterBlue.opacity(0.3))
                    Text("Soak")
                        .font(.custom("Cinzel-Bold", size: 16))
                        .foregroundStyle(step >= 1 ? IVMaterialColors.sepiaInk : IVMaterialColors.sepiaInk.opacity(0.3))
                }

                if step >= 2 {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 13))
                        .foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.3))
                }

                // Air dry
                if step >= 3 {
                    VStack(spacing: 4) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.clear)
                                .frame(height: 50)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .strokeBorder(IVMaterialColors.sepiaInk.opacity(0.15), style: StrokeStyle(lineWidth: 1, dash: [3, 2]))
                                )
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color(red: 0.55, green: 0.40, blue: 0.25).opacity(0.4))
                                .frame(width: 25, height: 35)
                        }
                        Text("12 mo")
                            .font(RenaissanceFont.ivFormula)
                            .foregroundStyle(IVMaterialColors.dimColor)
                        Text("Air Dry")
                            .font(.custom("Cinzel-Bold", size: 16))
                            .foregroundStyle(IVMaterialColors.sepiaInk)
                    }

                    Image(systemName: "arrow.right")
                        .font(.system(size: 13))
                        .foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.3))

                    // Ready to carve
                    VStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(Color(red: 0.30, green: 0.58, blue: 0.32).opacity(0.6))
                        Text("18 mo")
                            .font(RenaissanceFont.ivFormula)
                            .foregroundStyle(color)
                        Text("Ready")
                            .font(.custom("Cinzel-Bold", size: 16))
                            .foregroundStyle(color)
                    }
                }
            }
            .padding(.horizontal, 10)
        }
    }
}

// MARK: - 8. Walnut Carving

private struct WalnutCarvingVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1

    private let labels = ["Walnut grain is uniform — carves equally in all directions",
                          "Floral scrolls carved 3mm deep — still sharp after 400 years",
                          "Oak splits along grain. Pine too soft. Walnut is isotropic"]

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            Canvas { ctx, size in
                let cx = size.width / 2, cy = size.height * 0.35

                // Wood block
                let blockW: CGFloat = 70, blockH: CGFloat = 50
                let block = CGRect(x: cx - blockW / 2, y: cy - blockH / 2, width: blockW, height: blockH)
                ctx.fill(Path(roundedRect: block, cornerRadius: 4), with: .color(walnutBrown.opacity(step >= 1 ? 0.4 : 0.15)))
                ctx.stroke(Path(roundedRect: block, cornerRadius: 4), with: .color(IVMaterialColors.sepiaInk.opacity(0.3)), lineWidth: 1)

                // Grain lines (uniform in all directions)
                if step >= 1 {
                    // Horizontal
                    for i in 0..<3 {
                        let y = cy - 12 + CGFloat(i) * 12
                        var grain = Path()
                        grain.move(to: CGPoint(x: cx - blockW / 2 + 5, y: y))
                        grain.addQuadCurve(to: CGPoint(x: cx + blockW / 2 - 5, y: y),
                                           control: CGPoint(x: cx, y: y + 2))
                        ctx.stroke(grain, with: .color(walnutBrown.opacity(0.2)), lineWidth: 0.5)
                    }
                }

                // Carving direction arrows (step 1)
                if step >= 1 {
                    let arrowR: CGFloat = blockW / 2 + 12
                    let directions: [CGFloat] = [0, .pi / 4, .pi / 2, .pi * 3 / 4]
                    for a in directions {
                        let endX = cx + cos(a) * arrowR
                        let endY = cy + sin(a) * arrowR
                        var arrow = Path()
                        arrow.move(to: CGPoint(x: cx + cos(a) * (blockW / 2 + 3), y: cy + sin(a) * (blockH / 2 + 3)))
                        arrow.addLine(to: CGPoint(x: endX, y: endY))
                        ctx.stroke(arrow, with: .color(color.opacity(0.3)), lineWidth: 1)
                    }
                }

                // Step 2: scroll pattern
                if step >= 2 {
                    let scrollY = cy + blockH / 2 + 18
                    var scroll = Path()
                    scroll.move(to: CGPoint(x: cx - 25, y: scrollY))
                    scroll.addCurve(to: CGPoint(x: cx + 25, y: scrollY),
                                    control1: CGPoint(x: cx - 10, y: scrollY - 12),
                                    control2: CGPoint(x: cx + 10, y: scrollY + 12))
                    ctx.stroke(scroll, with: .color(walnutBrown.opacity(0.5)), lineWidth: 1.5)
                }
            }
        }
    }
}

// MARK: - 9. Oak Structure (Hidden Posts)

private struct OakStructureVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1

    private let labels = ["20 cm square oak posts hidden inside walls",
                          "Each post carries the weight of 50 students",
                          "Walnut outside (beauty) + oak inside (strength)"]

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            Canvas { ctx, size in
                let cx = size.width / 2, wallY = size.height * 0.1

                // Wall cross-section
                let wallW: CGFloat = 50, wallH = size.height * 0.6
                let wallRect = CGRect(x: cx - wallW / 2, y: wallY, width: wallW, height: wallH)

                // Walnut cladding (outer)
                ctx.fill(Path(wallRect), with: .color(walnutBrown.opacity(step >= 3 ? 0.3 : 0.15)))
                ctx.stroke(Path(wallRect), with: .color(IVMaterialColors.sepiaInk.opacity(0.3)), lineWidth: 1)

                // Oak post (inner, hidden)
                if step >= 1 {
                    let postW: CGFloat = 18
                    let postRect = CGRect(x: cx - postW / 2, y: wallY + 5, width: postW, height: wallH - 10)
                    ctx.fill(Path(postRect), with: .color(oakTan.opacity(step >= 1 ? 0.5 : 0.1)))
                    ctx.stroke(Path(postRect), with: .color(oakTan), lineWidth: 1)
                }

                // Step 2: weight arrows from above
                if step >= 2 {
                    for i in 0..<3 {
                        let ax = cx - 6 + CGFloat(i) * 6
                        var arrow = Path()
                        arrow.move(to: CGPoint(x: ax, y: wallY - 12))
                        arrow.addLine(to: CGPoint(x: ax, y: wallY + 2))
                        ctx.stroke(arrow, with: .color(IVMaterialColors.sepiaInk.opacity(0.4)), lineWidth: 1)
                    }
                    var head = Path()
                    head.move(to: CGPoint(x: cx, y: wallY + 2))
                    head.addLine(to: CGPoint(x: cx - 4, y: wallY - 4))
                    head.addLine(to: CGPoint(x: cx + 4, y: wallY - 4))
                    head.closeSubpath()
                    ctx.fill(head, with: .color(IVMaterialColors.sepiaInk.opacity(0.4)))
                }

                // Labels
                if step >= 3 {
                    // Left label: walnut
                    var wLine = Path()
                    wLine.move(to: CGPoint(x: cx - wallW / 2 - 3, y: wallY + wallH / 2))
                    wLine.addLine(to: CGPoint(x: cx - wallW / 2 - 20, y: wallY + wallH / 2))
                    ctx.stroke(wLine, with: .color(walnutBrown.opacity(0.4)), lineWidth: 0.5)

                    // Right label: oak
                    var oLine = Path()
                    oLine.move(to: CGPoint(x: cx + wallW / 2 + 3, y: wallY + wallH / 2))
                    oLine.addLine(to: CGPoint(x: cx + wallW / 2 + 20, y: wallY + wallH / 2))
                    ctx.stroke(oLine, with: .color(oakTan.opacity(0.5)), lineWidth: 0.5)
                }
            }
        }
    }
}

// MARK: - 10. Cypress Ventilation

private struct CypressVentVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1

    private let labels = ["Cypress wood contains thujone + cedrol aromatic oils",
                          "Oils repel insects and resist fungal decay",
                          "Masks decomposition during 3-day winter dissections"]

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            VStack(spacing: 10) {
                // Cypress panel
                RoundedRectangle(cornerRadius: 6)
                    .fill(cypressGreen.opacity(step >= 1 ? 0.25 : 0.08))
                    .frame(height: 45)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .strokeBorder(cypressGreen.opacity(0.3), lineWidth: 1)
                    )
                    .overlay {
                        if step >= 1 {
                            // Aromatic wave lines
                            HStack(spacing: 12) {
                                ForEach(0..<4, id: \.self) { i in
                                    Path { p in
                                        p.move(to: CGPoint(x: 0, y: 15))
                                        p.addCurve(to: CGPoint(x: 0, y: -10),
                                                    control1: CGPoint(x: 6, y: 8),
                                                    control2: CGPoint(x: -6, y: -3))
                                    }
                                    .stroke(cypressGreen.opacity(step >= 2 ? 0.4 : 0.2), lineWidth: 0.5)
                                    .frame(width: 10, height: 30)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)

                HStack(spacing: 16) {
                    if step >= 1 {
                        Text("Thujone")
                            .font(RenaissanceFont.ivFormula)
                            .foregroundStyle(cypressGreen)
                    }
                    if step >= 1 {
                        Text("Cedrol")
                            .font(RenaissanceFont.ivFormula)
                            .foregroundStyle(cypressGreen)
                    }
                }

                if step >= 2 {
                    HStack(spacing: 12) {
                        Label("No insects", systemImage: "ant.fill")
                            .font(RenaissanceFont.ivBody)
                        Label("No fungus", systemImage: "leaf.fill")
                            .font(RenaissanceFont.ivBody)
                    }
                    .foregroundStyle(color.opacity(0.7))
                }

                if step >= 3 {
                    Text("3-day dissection odor control")
                        .font(RenaissanceFont.ivFormula)
                        .foregroundStyle(color)
                }
            }
            .padding(.horizontal, 8)
        }
    }
}

// MARK: - 11. Carving Tools

private struct CarvingToolsVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1

    private let labels = ["30 chisel profiles — each for a specific curve",
                          "Design → carbon transfer → gouge → detail → sand",
                          "Seal with walnut oil → signature deep brown"]

    private let toolSteps = ["Draw", "Transfer", "Gouge", "Detail", "Sand", "Oil"]

    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            VStack(spacing: 8) {
                // Chisel profiles (step 1)
                if step >= 1 {
                    HStack(spacing: 3) {
                        ForEach(0..<8, id: \.self) { i in
                            Canvas { ctx, size in
                                let w = size.width, h = size.height
                                var profile = Path()
                                // Different chisel shapes
                                switch i % 4 {
                                case 0: // flat
                                    profile.move(to: CGPoint(x: w * 0.2, y: h))
                                    profile.addLine(to: CGPoint(x: w * 0.2, y: h * 0.3))
                                    profile.addLine(to: CGPoint(x: w * 0.8, y: h * 0.3))
                                    profile.addLine(to: CGPoint(x: w * 0.8, y: h))
                                case 1: // gouge (curved)
                                    profile.move(to: CGPoint(x: w * 0.15, y: h))
                                    profile.addLine(to: CGPoint(x: w * 0.15, y: h * 0.4))
                                    profile.addQuadCurve(to: CGPoint(x: w * 0.85, y: h * 0.4),
                                                         control: CGPoint(x: w * 0.5, y: h * 0.15))
                                    profile.addLine(to: CGPoint(x: w * 0.85, y: h))
                                case 2: // V-tool
                                    profile.move(to: CGPoint(x: w * 0.15, y: h))
                                    profile.addLine(to: CGPoint(x: w * 0.15, y: h * 0.4))
                                    profile.addLine(to: CGPoint(x: w * 0.5, y: h * 0.2))
                                    profile.addLine(to: CGPoint(x: w * 0.85, y: h * 0.4))
                                    profile.addLine(to: CGPoint(x: w * 0.85, y: h))
                                default: // veiner (deep curve)
                                    profile.move(to: CGPoint(x: w * 0.2, y: h))
                                    profile.addLine(to: CGPoint(x: w * 0.2, y: h * 0.5))
                                    profile.addQuadCurve(to: CGPoint(x: w * 0.8, y: h * 0.5),
                                                         control: CGPoint(x: w * 0.5, y: h * 0.1))
                                    profile.addLine(to: CGPoint(x: w * 0.8, y: h))
                                }
                                ctx.fill(profile, with: .color(steelGray.opacity(0.4)))
                                ctx.stroke(profile, with: .color(IVMaterialColors.sepiaInk.opacity(0.3)), lineWidth: 0.5)
                            }
                            .frame(width: 16, height: 30)
                        }
                    }
                }

                // Process steps (step 2+)
                if step >= 2 {
                    HStack(spacing: 3) {
                        ForEach(Array(toolSteps.enumerated()), id: \.offset) { i, s in
                            let active = step >= 3 || i < 5
                            Text(s)
                                .font(RenaissanceFont.ivBody)
                                .foregroundStyle(active ? (i == 5 && step >= 3 ? color : IVMaterialColors.sepiaInk) : IVMaterialColors.sepiaInk.opacity(0.3))
                                .padding(.horizontal, 4)
                                .padding(.vertical, 2)
                                .background(
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(active ? color.opacity(0.06) : Color.clear)
                                )

                            if i < toolSteps.count - 1 {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 13))
                                    .foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.2))
                            }
                        }
                    }
                }

                if step >= 3 {
                    Text("2 weeks carving + walnut oil seal")
                        .font(RenaissanceFont.ivFormula)
                        .foregroundStyle(walnutBrown)
                }
            }
            .padding(.horizontal, 6)
        }
    }
}
