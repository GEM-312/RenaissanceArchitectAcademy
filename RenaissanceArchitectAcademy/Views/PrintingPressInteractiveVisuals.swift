import SwiftUI

/// Interactive science visuals for Printing Press knowledge cards (12 cards)
struct PrintingPressInteractiveVisuals {

    @ViewBuilder
    static func view(for visual: CardVisual, color: Color, height: CGFloat = 275) -> some View {
        let h = height
        Group {
            switch visual.title {
            case let t where t.contains("Gutenberg"):
                GutenbergVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Screw Press"):
                ScrewPressVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Type Metal"):
                TypeMetalVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Oil-Based Ink"):
                OilInkVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Compose"):
                CompositorVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Type Alloy"):
                TypeAlloyVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Dampen Paper"):
                DampenPaperVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Iron Frame"):
                IronFrameVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Oak Press"):
                OakPressVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Type Cases"):
                TypeCasesVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Punch to Matrix"):
                PunchMatrixVisual(visual: visual, color: color, height: h)
            case let t where t.contains("Cast Type"):
                CastTypeVisual(visual: visual, color: color, height: h)
            default:
                EmptyView()
            }
        }
    }

    static func hasInteractiveVisual(for visual: CardVisual) -> Bool {
        let t = visual.title
        return t.contains("Gutenberg") || t.contains("Screw Press") ||
               t.contains("Type Metal") || t.contains("Oil-Based Ink") ||
               t.contains("Compose") || t.contains("Type Alloy") ||
               t.contains("Dampen Paper") || t.contains("Iron Frame") ||
               t.contains("Oak Press") || t.contains("Type Cases") ||
               t.contains("Punch to Matrix") || t.contains("Cast Type")
    }
}

private let gridColor = ivGridColor
private let sepiaInk = ivSepiaInk
private let waterBlue = ivWaterBlue
private let dimColor = ivDimColor
private let inkBlack = Color(red: 0.12, green: 0.10, blue: 0.08)
private let leadGray = Color(red: 0.55, green: 0.55, blue: 0.52)
private let oakBrown = Color(red: 0.55, green: 0.42, blue: 0.28)
private let ironDark = Color(red: 0.38, green: 0.36, blue: 0.34)
private let copperRose = Color(red: 0.72, green: 0.48, blue: 0.35)
private let paperCream = Color(red: 0.95, green: 0.92, blue: 0.85)
private let walnutDark = Color(red: 0.45, green: 0.32, blue: 0.20)

private typealias TeachingContainer = IVTeachingContainer
private typealias DimLabel = IVDimLabel
private typealias FormulaText = IVFormulaText
private typealias DimLine = IVDimLine

// MARK: - 1. Gutenberg's Revolution
private struct GutenbergVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    private let labels = ["Before: 1 monk, 1 Bible, 2 years of hand copying",
                          "After Gutenberg: 180 Bibles in 3 years",
                          "Venice by 1500: 150 print shops, 4,000 titles"]
    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            VStack(spacing: 10) {
                HStack(spacing: 20) {
                    VStack(spacing: 4) {
                        Text("✍️").font(.system(size: 20)).opacity(step >= 1 ? 0.7 : 0.2)
                        Text("1 Bible").font(.custom("EBGaramond-Bold", size: 11)).foregroundStyle(step >= 1 ? sepiaInk : sepiaInk.opacity(0.3))
                        Text("2 years").font(.custom("EBGaramond-Regular", size: 9)).foregroundStyle(dimColor.opacity(step >= 1 ? 0.6 : 0.2))
                    }
                    if step >= 2 {
                        Image(systemName: "arrow.right").font(.system(size: 10)).foregroundStyle(sepiaInk.opacity(0.3))
                        VStack(spacing: 4) {
                            Text("🖨️").font(.system(size: 20))
                            Text("180 Bibles").font(.custom("EBGaramond-Bold", size: 11)).foregroundStyle(color)
                            Text("3 years").font(.custom("EBGaramond-Regular", size: 9)).foregroundStyle(dimColor)
                        }
                    }
                }
                if step >= 3 {
                    Text("150 shops · 4,000 titles by 1500")
                        .font(.custom("EBGaramond-Bold", size: 12))
                        .foregroundStyle(color)
                }
            }
        }
    }
}

// MARK: - 2. Screw Press — 314× Force
private struct ScrewPressVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    private let labels = ["Screw converts rotation into downward pressure",
                          "314× mechanical advantage from thread geometry",
                          "10 kg pull → 3,140 kg on platen"]
    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            Canvas { ctx, size in
                let cx = size.width / 2, cy = size.height * 0.38
                // Screw thread
                var screw = Path()
                for i in 0..<12 {
                    let t = CGFloat(i) / 11
                    let y = cy - 25 + t * 50
                    let x = cx + sin(t * .pi * 6) * 8
                    if i == 0 { screw.move(to: CGPoint(x: x, y: y)) } else { screw.addLine(to: CGPoint(x: x, y: y)) }
                }
                ctx.stroke(screw, with: .color(ironDark.opacity(step >= 1 ? 0.5 : 0.2)), lineWidth: 2)
                // Handle
                if step >= 1 {
                    var handle = Path()
                    handle.move(to: CGPoint(x: cx - 30, y: cy - 25))
                    handle.addLine(to: CGPoint(x: cx + 30, y: cy - 25))
                    ctx.stroke(handle, with: .color(oakBrown.opacity(0.5)), lineWidth: 3)
                }
                // Platen
                let platenY = cy + 30
                let platen = CGRect(x: cx - 35, y: platenY, width: 70, height: 8)
                ctx.fill(Path(platen), with: .color(ironDark.opacity(step >= 2 ? 0.4 : 0.15)))
                // Force arrow
                if step >= 2 {
                    var force = Path()
                    force.move(to: CGPoint(x: cx, y: cy + 25))
                    force.addLine(to: CGPoint(x: cx, y: platenY - 2))
                    ctx.stroke(force, with: .color(color), lineWidth: 2)
                    var head = Path()
                    head.move(to: CGPoint(x: cx, y: platenY - 2))
                    head.addLine(to: CGPoint(x: cx - 4, y: platenY - 8))
                    head.addLine(to: CGPoint(x: cx + 4, y: platenY - 8))
                    head.closeSubpath()
                    ctx.fill(head, with: .color(color))
                }
            }
            .overlay(alignment: .bottom) {
                if step >= 3 {
                    Text("10 kg → 3,140 kg (314×)")
                        .font(.custom("EBGaramond-Bold", size: 12))
                        .foregroundStyle(color)
                        .offset(y: -28)
                }
            }
        }
    }
}

// MARK: - 3. Type Metal Alloy
private struct TypeMetalVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    private let labels = ["Type metal: 80% lead + 15% antimony + 5% tin",
                          "Antimony hardens, tin improves flow into molds",
                          "Expands 1% on cooling — fills every detail perfectly"]
    private let metals: [(String, String, CGFloat, Color)] = [
        ("Lead", "80%", 0.8, leadGray),
        ("Antimony", "15%", 0.15, Color(red: 0.60, green: 0.58, blue: 0.62)),
        ("Tin", "5%", 0.05, Color(red: 0.75, green: 0.72, blue: 0.68)),
    ]
    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            VStack(spacing: 8) {
                GeometryReader { geo in
                    HStack(spacing: 1) {
                        ForEach(Array(metals.enumerated()), id: \.offset) { i, metal in
                            let active = step >= 1
                            Rectangle()
                                .fill(active ? metal.3 : Color.gray.opacity(0.1))
                                .frame(width: geo.size.width * metal.2)
                                .overlay {
                                    VStack(spacing: 1) {
                                        Text(metal.1).font(.custom("EBGaramond-Bold", size: 10))
                                        Text(metal.0).font(.custom("EBGaramond-Regular", size: 7))
                                    }.foregroundStyle(active ? .white.opacity(0.8) : .clear)
                                }
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .overlay(RoundedRectangle(cornerRadius: 4).strokeBorder(sepiaInk.opacity(0.2), lineWidth: 0.5))
                }.frame(height: 40)
                if step >= 3 { Text("+1% expansion on cooling").font(.custom("EBGaramond-Bold", size: 12)).foregroundStyle(color) }
            }.padding(.horizontal, 8)
        }
    }
}

// MARK: - 4. Oil-Based Ink
private struct OilInkVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    private let labels = ["Water-based ink beads off metal type — useless",
                          "Lampblack + linseed oil + turpentine = oil-based ink",
                          "Clings to metal, dries by oxidation — no smearing"]
    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            HStack(spacing: 16) {
                // Water-based (fails)
                VStack(spacing: 4) {
                    Circle().fill(waterBlue.opacity(step >= 1 ? 0.3 : 0.1)).frame(width: 35, height: 35)
                        .overlay { if step >= 1 { Image(systemName: "xmark").font(.system(size: 10)).foregroundStyle(.red.opacity(0.5)) } }
                    Text("Water").font(.custom("Cinzel-Bold", size: 8)).foregroundStyle(step >= 1 ? .red.opacity(0.5) : sepiaInk.opacity(0.3))
                    Text("Beads off").font(.custom("EBGaramond-Regular", size: 7)).foregroundStyle(step >= 1 ? dimColor : dimColor.opacity(0.3))
                }
                if step >= 2 {
                    Image(systemName: "arrow.right").font(.system(size: 9)).foregroundStyle(sepiaInk.opacity(0.3))
                    // Oil-based (works)
                    VStack(spacing: 4) {
                        Circle().fill(inkBlack.opacity(0.6)).frame(width: 35, height: 35)
                            .overlay { if step >= 3 { Image(systemName: "checkmark").font(.system(size: 10)).foregroundStyle(Color(red: 0.30, green: 0.58, blue: 0.32)) } }
                        Text("Oil").font(.custom("Cinzel-Bold", size: 8)).foregroundStyle(color)
                        Text("Clings").font(.custom("EBGaramond-Regular", size: 7)).foregroundStyle(dimColor)
                    }
                }
            }.padding(.horizontal, 20)
        }
    }
}

// MARK: - 5. Compositor
private struct CompositorVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    private let labels = ["Pick type pieces, arrange backward + mirrored",
                          "1,500 characters per hour by skilled compositor",
                          "Set once → print 500 copies/day. Bottleneck = composition"]
    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            VStack(spacing: 8) {
                // Type blocks
                if step >= 1 {
                    HStack(spacing: 2) {
                        ForEach(Array("PRINT".enumerated()), id: \.offset) { _, ch in
                            Text(String(ch))
                                .font(.custom("Cinzel-Bold", size: 12))
                                .foregroundStyle(sepiaInk)
                                .frame(width: 18, height: 22)
                                .background(RoundedRectangle(cornerRadius: 2).fill(leadGray.opacity(0.3)))
                                .scaleEffect(x: -1) // mirrored
                        }
                    }
                    Text("← mirrored").font(.custom("EBGaramond-Regular", size: 8)).foregroundStyle(dimColor.opacity(0.5))
                }
                if step >= 2 { Text("1,500 chars/hour").font(.custom("EBGaramond-Bold", size: 13)).foregroundStyle(color) }
                if step >= 3 { Text("→ 500 copies/day").font(.custom("EBGaramond-Bold", size: 12)).foregroundStyle(color) }
            }
        }
    }
}

// MARK: - 6-12: Remaining compact visuals

private struct TypeAlloyVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    private let labels = ["3 ores: galena (Pb), cassiterite (Sn), stibnite (Sb)",
                          "Smelted separately: 327°C, 232°C, 630°C",
                          "Must survive 500 impressions but be recastable"]
    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            VStack(spacing: 6) {
                HStack(spacing: 10) {
                    orePill("Galena", formula: "PbS", temp: "327°C", active: step >= 1)
                    orePill("Cassiterite", formula: "SnO₂", temp: "232°C", active: step >= 2)
                    orePill("Stibnite", formula: "Sb₂S₃", temp: "630°C", active: step >= 2)
                }
                if step >= 3 { Text("500 impressions per piece").font(.custom("EBGaramond-Bold", size: 11)).foregroundStyle(color) }
            }
        }
    }
    @ViewBuilder private func orePill(_ name: String, formula: String, temp: String, active: Bool) -> some View {
        VStack(spacing: 2) {
            Text(formula).font(.custom("EBGaramond-Bold", size: 9)).foregroundStyle(active ? dimColor : dimColor.opacity(0.2))
            Text(name).font(.custom("Cinzel-Bold", size: 7)).foregroundStyle(active ? sepiaInk : sepiaInk.opacity(0.2))
            Text(temp).font(.custom("EBGaramond-Regular", size: 8)).foregroundStyle(active ? color : color.opacity(0.2))
        }.padding(.horizontal, 4).padding(.vertical, 3)
        .background(RoundedRectangle(cornerRadius: 3).fill(active ? color.opacity(0.06) : Color.clear))
    }
}

private struct DampenPaperVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    private let labels = ["Paper printed damp — fibers absorb ink better",
                          "Dampened to 20-25% moisture between wet felts overnight",
                          "Too wet = bleeding. Too dry = smearing. Balance is everything"]
    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            VStack(spacing: 8) {
                // Paper sheet
                RoundedRectangle(cornerRadius: 4)
                    .fill(paperCream.opacity(step >= 1 ? 0.7 : 0.2))
                    .frame(height: 40)
                    .overlay(RoundedRectangle(cornerRadius: 4).strokeBorder(sepiaInk.opacity(0.2), lineWidth: 0.5))
                    .padding(.horizontal, 30)
                if step >= 2 { Text("20-25% moisture").font(.custom("EBGaramond-Bold", size: 13)).foregroundStyle(color) }
                if step >= 3 {
                    HStack(spacing: 20) {
                        Text("Too wet: bleed").font(.custom("EBGaramond-Regular", size: 9)).foregroundStyle(.red.opacity(0.5))
                        Text("Too dry: smear").font(.custom("EBGaramond-Regular", size: 9)).foregroundStyle(.red.opacity(0.5))
                    }
                }
            }
        }
    }
}

private struct IronFrameVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    private let labels = ["Cast-iron frame replaced wooden structure",
                          "200 kg, bolted floor to ceiling",
                          "Resists 3,000+ kg — even pressure edge to edge"]
    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            Canvas { ctx, size in
                let cx = size.width / 2, frameW: CGFloat = 50, frameH = size.height * 0.55
                let topY = size.height * 0.1
                // Frame uprights
                ctx.fill(Path(CGRect(x: cx - frameW / 2, y: topY, width: 6, height: frameH)), with: .color(ironDark.opacity(step >= 1 ? 0.5 : 0.15)))
                ctx.fill(Path(CGRect(x: cx + frameW / 2 - 6, y: topY, width: 6, height: frameH)), with: .color(ironDark.opacity(step >= 1 ? 0.5 : 0.15)))
                // Crossbeam
                ctx.fill(Path(CGRect(x: cx - frameW / 2, y: topY, width: frameW, height: 6)), with: .color(ironDark.opacity(step >= 1 ? 0.5 : 0.15)))
                // Step 2: bolts
                if step >= 2 {
                    for y in [topY - 5, topY + frameH + 2] {
                        for x in [cx - frameW / 2 + 3, cx + frameW / 2 - 3] {
                            let bolt = Path(ellipseIn: CGRect(x: x - 2, y: y - 2, width: 4, height: 4))
                            ctx.fill(bolt, with: .color(ironDark.opacity(0.6)))
                        }
                    }
                }
                // Step 3: force arrows
                if step >= 3 {
                    var force = Path()
                    force.move(to: CGPoint(x: cx, y: topY + 10))
                    force.addLine(to: CGPoint(x: cx, y: topY + frameH - 10))
                    ctx.stroke(force, with: .color(color.opacity(0.4)), lineWidth: 1.5)
                }
            }
            .overlay(alignment: .bottom) {
                if step >= 3 { Text("3,000+ kg").font(.custom("EBGaramond-Bold", size: 13)).foregroundStyle(color).offset(y: -28) }
            }
        }
    }
}

private struct OakPressVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    private let labels = ["Original press: oak uprights 15 × 15 cm",
                          "Each upright carries 1,500 kg compression",
                          "Bronze bushing in screw hole — smooth rotation"]
    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            VStack(spacing: 8) {
                HStack(spacing: 20) {
                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 3).fill(oakBrown.opacity(step >= 1 ? 0.5 : 0.15))
                            .frame(width: 25, height: 60)
                        Text("15×15cm").font(.custom("EBGaramond-Bold", size: 9)).foregroundStyle(step >= 1 ? dimColor : dimColor.opacity(0.3))
                    }
                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 3).fill(oakBrown.opacity(step >= 1 ? 0.5 : 0.15))
                            .frame(width: 25, height: 60)
                        Text("15×15cm").font(.custom("EBGaramond-Bold", size: 9)).foregroundStyle(step >= 1 ? dimColor : dimColor.opacity(0.3))
                    }
                }
                if step >= 2 { Text("1,500 kg each").font(.custom("EBGaramond-Bold", size: 12)).foregroundStyle(color) }
                if step >= 3 { Text("Bronze bushing → smooth screw").font(.custom("EBGaramond-Regular", size: 10)).foregroundStyle(dimColor) }
            }
        }
    }
}

private struct TypeCasesVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    private let labels = ["Walnut type cases: compartments per character",
                          "UPPER case (capitals above) — lower case (small below)",
                          "Language preserves the memory of wooden furniture"]
    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            VStack(spacing: 6) {
                // Upper case (angled)
                if step >= 2 {
                    RoundedRectangle(cornerRadius: 3).fill(walnutDark.opacity(0.25))
                        .frame(height: 25)
                        .overlay {
                            HStack(spacing: 2) {
                                ForEach(["A","B","C","D","E"], id: \.self) { ch in
                                    Text(ch).font(.custom("Cinzel-Bold", size: 9)).foregroundStyle(sepiaInk.opacity(0.5))
                                        .frame(width: 16, height: 16)
                                        .background(RoundedRectangle(cornerRadius: 1).fill(paperCream.opacity(0.3)))
                                }
                            }
                        }
                        .overlay(alignment: .leading) { Text("UPPER").font(.custom("EBGaramond-Regular", size: 7)).foregroundStyle(dimColor).padding(.leading, 4) }
                        .padding(.horizontal, 20)
                }
                // Lower case
                if step >= 1 {
                    RoundedRectangle(cornerRadius: 3).fill(walnutDark.opacity(0.2))
                        .frame(height: 25)
                        .overlay {
                            HStack(spacing: 2) {
                                ForEach(["a","b","c","d","e","f","g","h"], id: \.self) { ch in
                                    Text(ch).font(.custom("EBGaramond-Regular", size: 9)).foregroundStyle(sepiaInk.opacity(0.5))
                                        .frame(width: 14, height: 14)
                                        .background(RoundedRectangle(cornerRadius: 1).fill(paperCream.opacity(0.3)))
                                }
                            }
                        }
                        .overlay(alignment: .leading) { Text("lower").font(.custom("EBGaramond-Regular", size: 7)).foregroundStyle(dimColor).padding(.leading, 4) }
                        .padding(.horizontal, 20)
                }
                if step >= 3 { Text("\"Uppercase\" = top tray position").font(.custom("EBGaramond-Bold", size: 10)).foregroundStyle(color) }
            }
        }
    }
}

private struct PunchMatrixVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    private let labels = ["Steel punch: letter carved in relief (raised)",
                          "Hammer into copper bar → matrix (letter in reverse)",
                          "Pour type metal into matrix → type piece (relief again)"]
    private let stages = ["Punch", "→", "Matrix", "→", "Type"]
    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            HStack(spacing: 4) {
                // Punch (steel)
                VStack(spacing: 2) {
                    RoundedRectangle(cornerRadius: 2).fill(ironDark.opacity(step >= 1 ? 0.5 : 0.15))
                        .frame(width: 22, height: 35)
                        .overlay(alignment: .bottom) {
                            Text("A").font(.custom("Cinzel-Bold", size: 10)).foregroundStyle(.white.opacity(step >= 1 ? 0.6 : 0))
                                .padding(.bottom, 2)
                        }
                    Text("Punch").font(.custom("EBGaramond-Regular", size: 7)).foregroundStyle(step >= 1 ? sepiaInk : sepiaInk.opacity(0.3))
                }
                if step >= 2 {
                    Image(systemName: "arrow.right").font(.system(size: 8)).foregroundStyle(sepiaInk.opacity(0.3))
                    // Matrix (copper)
                    VStack(spacing: 2) {
                        RoundedRectangle(cornerRadius: 2).fill(copperRose.opacity(0.4))
                            .frame(width: 22, height: 30)
                            .overlay {
                                Text("A").font(.custom("Cinzel-Bold", size: 10)).foregroundStyle(copperRose.opacity(0.3))
                                    .scaleEffect(x: -1)
                            }
                        Text("Matrix").font(.custom("EBGaramond-Regular", size: 7)).foregroundStyle(sepiaInk)
                    }
                }
                if step >= 3 {
                    Image(systemName: "arrow.right").font(.system(size: 8)).foregroundStyle(sepiaInk.opacity(0.3))
                    // Type piece
                    VStack(spacing: 2) {
                        RoundedRectangle(cornerRadius: 2).fill(leadGray.opacity(0.4))
                            .frame(width: 22, height: 30)
                            .overlay(alignment: .top) {
                                Text("A").font(.custom("Cinzel-Bold", size: 10)).foregroundStyle(leadGray.opacity(0.7))
                                    .scaleEffect(x: -1).padding(.top, 2)
                            }
                        Text("Type").font(.custom("EBGaramond-Regular", size: 7)).foregroundStyle(color)
                    }
                }
            }.padding(.horizontal, 16)
        }
    }
}

private struct CastTypeVisual: View {
    let visual: CardVisual; let color: Color; var height: CGFloat = 275
    @State private var step: Int = 1
    private let labels = ["Type metal melts at 240°C — small charcoal furnace",
                          "Ladle into hand mold with copper matrix. Cool 10 seconds",
                          "4,000 identical pieces per day. Uniformity is the point"]
    var body: some View {
        TeachingContainer(title: visual.title, color: color, totalSteps: 3, step: $step,
                          stepLabel: labels[step - 1], height: height) {
            VStack(spacing: 8) {
                if step >= 1 { Text("240°C").font(.custom("EBGaramond-Bold", size: 16)).foregroundStyle(Color(red: 0.90, green: 0.50, blue: 0.15)) }
                if step >= 2 { Text("Cool 10 sec → perfect letter").font(.custom("EBGaramond-Regular", size: 11)).foregroundStyle(dimColor) }
                if step >= 3 {
                    HStack(spacing: 2) {
                        ForEach(0..<8, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 1).fill(leadGray.opacity(0.4)).frame(width: 12, height: 16)
                        }
                    }
                    Text("4,000 / day — every one identical")
                        .font(.custom("EBGaramond-Bold", size: 12))
                        .foregroundStyle(color)
                }
            }
        }
    }
}
