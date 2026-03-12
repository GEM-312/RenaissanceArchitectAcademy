import SwiftUI

/// Quarry "Strike the Stone" mini-game
/// Chisel targets appear on a stone block — tap them before they shrink away.
/// Harder materials = faster disappearing targets.
///
/// Flow: Material selection → Chisel game → Stone splits → Material awarded
struct QuarryMiniGameView: View {

    let onComplete: (Material, Int) -> Void   // material earned, bonus florins
    let onDismiss: () -> Void
    var onNudgeCamera: (() -> Void)? = nil   // Called when transitioning from full-screen game back to dialog

    @Environment(\.gameSettings) private var settings

    // MARK: - Molecule Integration

    @State private var molecule: PubChemMolecule? = nil
    @State private var moleculeReveal: CGFloat = 0        // 0→1, tied to hits/hitsNeeded
    @State private var bondPulseTimer: Timer? = nil
    @State private var bondPulse: CGFloat = 0
    @State private var showMoleculeInfo = false
    private let pubchemService = PubChemService()

    // MARK: - Game Phases

    enum Phase: Equatable {
        case choose          // Pick which material to quarry
        case intro           // Quick educational text before game
        case playing         // Active chisel game
        case success         // Stone split — material awarded
        case failed          // Too many misses
    }

    @State private var phase: Phase = .choose
    @State private var selectedMaterial: Material = .limestone

    // MARK: - Game State

    @State private var targets: [ChiselTarget] = []
    @State private var activeTargetIndex: Int = 0
    @State private var hits: Int = 0
    @State private var misses: Int = 0
    @State private var perfectHits: Int = 0
    @State private var shrinkProgress: CGFloat = 1.0   // 1.0 = full, 0.0 = gone
    @State private var showCrackAt: [CGPoint] = []
    @State private var showDustAt: CGPoint?
    @State private var stoneOpacity: Double = 1.0
    @State private var splitOffset: CGFloat = 0
    @State private var scorePopup: ScorePopup?

    // Timers
    @State private var shrinkTimer: Timer?
    @State private var spawnTimer: Timer?

    private let hitsNeeded = 5
    private let maxMisses = 3

    // MARK: - Difficulty

    private var shrinkDuration: Double {
        switch selectedMaterial {
        case .limestone:   return 2.5   // Easy
        case .marbleDust:  return 1.8   // Medium
        case .marble:      return 1.2   // Hard
        default:           return 2.0
        }
    }

    private var bonusFlorins: Int {
        perfectHits * 2
    }

    /// Map selected quarry material to its real chemical compound
    private var compoundForMaterial: (name: String, formula: String, educationalText: String) {
        switch selectedMaterial {
        case .limestone:
            return ("calcium carbonate", "CaCO\u{2083}",
                    "The main mineral in limestone and marble. Romans carved entire temples from it.")
        case .marbleDust:
            return ("calcium carbonate", "CaCO\u{2083}",
                    "Marble dust is ground calcium carbonate — the same molecule, crushed to powder.")
        case .marble:
            return ("calcium carbonate", "CaCO\u{2083}",
                    "Marble is crystallized CaCO\u{2083}. Millions of years of heat and pressure locked the crystals tight.")
        default:
            return ("calcium carbonate", "CaCO\u{2083}", "Calcium carbonate — the building block of stone.")
        }
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            if phase == .playing {
                // Playing phase: full-screen dark overlay with game
                RenaissanceColors.overlayDimming
                    .ignoresSafeArea()

                gameView
                    .transition(.opacity)
            } else {
                // Dialog phases: no dimming, bottom-anchored card over the scene
                Color.clear
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if phase == .choose { onDismiss() }
                    }

                VStack {
                    Spacer()

                    Group {
                        switch phase {
                        case .choose:
                            materialChoiceCard
                        case .intro:
                            introCard
                        case .success:
                            successCard
                        case .failed:
                            failedCard
                        case .playing:
                            EmptyView()
                        }
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.bottom, Spacing.xl)
                }
                .padding(.horizontal, Spacing.md)
            }
        }
        .animation(.spring(response: 0.4), value: phase)
    }

    // MARK: - Phase 1: Material Choice

    private var materialChoiceCard: some View {
        VStack(spacing: 20) {
            // Header — bird + title (same as Earn Florins)
            HStack(spacing: 12) {
                BirdCharacter()
                    .frame(width: 70, height: 70)

                VStack(alignment: .leading, spacing: 4) {
                    Text("La Cava")
                        .font(.custom("Cinzel-Bold", size: 22))
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                    Text("Choose your stone. Harder stone requires faster hands.")
                        .font(RenaissanceFont.dialogSubtitle)
                        .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))
                }
            }

            // Material option rows (same pattern as earnOptionCard)
            VStack(spacing: 10) {
                materialOptionRow(
                    material: .limestone,
                    difficulty: "Easy",
                    description: "Soft calcium carbonate — the foundation of concrete"
                )
                materialOptionRow(
                    material: .marbleDust,
                    difficulty: "Medium",
                    description: "Fine powder for polishing and fresco plaster"
                )
                materialOptionRow(
                    material: .marble,
                    difficulty: "Hard",
                    description: "Crystallized limestone — prized for sculpture and veneer"
                )
            }

            Button("Back") {
                onDismiss()
            }
            .font(RenaissanceFont.bodySmall)
            .foregroundStyle(RenaissanceColors.sepiaInk)
        }
        .padding(Spacing.xl)
        .adaptiveWidth(400)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.lg)
                .fill(RenaissanceColors.parchment)
        )
        .borderWorkshop()
    }

    private func materialOptionRow(material: Material, difficulty: String, description: String) -> some View {
        Button {
            selectedMaterial = material
            withAnimation { phase = .intro }
        } label: {
            HStack(spacing: 12) {
                // Icon square (matches earnOptionCard icon box)
                Text(material.icon)
                    .font(.title3)
                    .frame(width: 32, height: 32)
                    .background(
                        RoundedRectangle(cornerRadius: CornerRadius.sm)
                            .fill(RenaissanceColors.warmBrown.opacity(0.1))
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(material.rawValue)
                        .font(.custom("EBGaramond-Regular", size: 16))
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                    Text(description)
                        .font(RenaissanceFont.captionSmall)
                        .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.6))
                        .lineLimit(1)
                }

                Spacer()

                Text(difficulty)
                    .font(.custom("EBGaramond-SemiBold", size: 13))
                    .foregroundStyle(difficultyColor(difficulty))

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(RenaissanceColors.sepiaInk)
            }
            .padding(Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(RenaissanceColors.parchment.opacity(0.6))
                    .borderWorkshop(radius: 10)
            )
        }
    }

    private func difficultyColor(_ difficulty: String) -> Color {
        switch difficulty {
        case "Easy":   return RenaissanceColors.sageGreen
        case "Medium": return RenaissanceColors.ochre
        case "Hard":   return RenaissanceColors.terracotta
        default:       return RenaissanceColors.stoneGray
        }
    }

    // MARK: - Phase 2: Intro

    private var introCard: some View {
        VStack(spacing: 20) {
            // Header
            HStack(spacing: 12) {
                Image(systemName: "hammer.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(RenaissanceColors.warmBrown)
                    .frame(width: 44, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: CornerRadius.sm)
                            .fill(RenaissanceColors.warmBrown.opacity(0.1))
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text("Strike the Stone")
                        .font(.custom("Cinzel-Bold", size: 22))
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                    Text(selectedMaterial.rawValue)
                        .font(RenaissanceFont.dialogSubtitle)
                        .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))
                }
            }

            Text(introText)
                .font(.custom("EBGaramond-Regular", size: 16))
                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))
                .fixedSize(horizontal: false, vertical: true)

            // Rules as row cards
            VStack(spacing: 10) {
                ruleRow(icon: "target", text: "Swing your pickaxe at the glowing marks", color: RenaissanceColors.ochre)
                ruleRow(icon: "star.fill", text: "Early taps = Perfect bonus (+2 florins)", color: RenaissanceColors.goldSuccess)
                ruleRow(icon: "xmark.circle", text: "\(maxMisses) misses and the stone cracks wrong", color: RenaissanceColors.errorRed)
            }

            Button {
                startGame()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "hammer.fill")
                        .font(.caption)
                    Text("Begin Quarrying")
                        .font(.custom("EBGaramond-SemiBold", size: 16))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(RenaissanceColors.warmBrown)
                )
            }

            Button("Back") {
                withAnimation { phase = .choose }
            }
            .font(RenaissanceFont.bodySmall)
            .foregroundStyle(RenaissanceColors.sepiaInk)
        }
        .padding(Spacing.xl)
        .adaptiveWidth(400)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.lg)
                .fill(RenaissanceColors.parchment)
        )
        .borderWorkshop()
    }

    private func ruleRow(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(color)
                .frame(width: 32, height: 32)
                .background(
                    RoundedRectangle(cornerRadius: CornerRadius.sm)
                        .fill(color.opacity(0.1))
                )

            Text(text)
                .font(.custom("EBGaramond-Regular", size: 14))
                .foregroundStyle(RenaissanceColors.sepiaInk)

            Spacer()
        }
        .padding(Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(RenaissanceColors.parchment.opacity(0.6))
                .borderWorkshop(radius: 10)
        )
    }

    private var introText: String {
        switch selectedMaterial {
        case .limestone:
            return "Roman quarry workers read the stone like a book. Every block has natural fracture lines — invisible seams where the rock wants to split. Find the line, drill the holes, drive the wedges. The stone does the rest."
        case .marbleDust:
            return "Marble dust isn't carved — it's ground. Workers crushed marble scraps between heavy stones until the pieces became powder finer than flour. Mixed with lime, it became the smooth plaster of Roman walls."
        case .marble:
            return "Carrara marble is limestone that spent millions of years under heat and pressure. The crystals locked tight, creating stone that reflects light like no other. Michelangelo chose his own blocks. He said the sculpture was already inside — he just freed it."
        default:
            return "Choose your stone wisely."
        }
    }

    // MARK: - Phase 3: Active Game

    private var gameView: some View {
        GeometryReader { geo in
            let stoneSize = stoneSize(in: geo.size)

            ZStack {
                // Background — parchment with quarry overlay
                RoundedRectangle(cornerRadius: CornerRadius.lg)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.35, green: 0.32, blue: 0.28),
                                Color(red: 0.25, green: 0.22, blue: 0.18)
                            ],
                            startPoint: .top, endPoint: .bottom
                        )
                    )

                VStack(spacing: Spacing.md) {
                    // HUD bar — styled like a parchment strip
                    HStack {
                        // Hits progress
                        HStack(spacing: 6) {
                            ForEach(0..<hitsNeeded, id: \.self) { i in
                                Circle()
                                    .fill(i < hits ? RenaissanceColors.goldSuccess : Color.white.opacity(0.2))
                                    .frame(width: 14, height: 14)
                                    .overlay(
                                        Circle()
                                            .strokeBorder(Color.white.opacity(0.4), lineWidth: 1)
                                    )
                            }
                            Text("\(hits)/\(hitsNeeded)")
                                .font(.custom("EBGaramond-Regular", size: 13))
                                .foregroundStyle(.white.opacity(0.7))
                        }

                        Spacer()

                        // Material label
                        HStack(spacing: 4) {
                            Text("\u{26CF}\u{FE0F}")
                            Text(selectedMaterial.rawValue)
                                .font(.custom("Cinzel-Bold", size: 16))
                                .foregroundStyle(.white)
                        }

                        Spacer()

                        // Misses (X marks)
                        HStack(spacing: 4) {
                            ForEach(0..<maxMisses, id: \.self) { i in
                                Image(systemName: i < misses ? "xmark.circle.fill" : "xmark.circle")
                                    .font(.caption)
                                    .foregroundStyle(i < misses ? RenaissanceColors.errorRed : .white.opacity(0.3))
                            }
                        }
                    }
                    .padding(.horizontal, Spacing.lg)
                    .padding(.vertical, Spacing.sm)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.black.opacity(0.3))
                    )
                    .padding(.horizontal, Spacing.md)
                    .padding(.top, Spacing.md)

                    Spacer()

                    // Stone block
                    ZStack {
                        // Left half
                        stoneBlockHalf(size: stoneSize)
                            .offset(x: -splitOffset)

                        // Right half
                        stoneBlockHalf(size: stoneSize)
                            .offset(x: splitOffset)

                        // Crack lines from successful hits
                        ForEach(Array(showCrackAt.enumerated()), id: \.offset) { _, point in
                            CrackShape(origin: point, seed: point.x.hashValue)
                                .stroke(Color.black.opacity(0.6), lineWidth: 2)
                                .frame(width: stoneSize.width, height: stoneSize.height)
                        }

                        // Active target
                        if phase == .playing,
                           activeTargetIndex < targets.count {
                            let target = targets[activeTargetIndex]
                            chiselTargetView(target: target, stoneSize: stoneSize)
                        }

                        // Molecule fading in through cracks
                        if let mol = molecule, moleculeReveal > 0 {
                            PubChemMoleculeView(
                                molecule: mol,
                                revealProgress: moleculeReveal,
                                bondPulse: bondPulse
                            )
                            .frame(width: stoneSize.width * 0.7, height: stoneSize.height * 0.7)
                            .opacity(Double(moleculeReveal) * 0.9)
                            .blendMode(.screen)
                            .allowsHitTesting(false)
                        }

                        // Dust particle effect
                        if let dustPos = showDustAt {
                            DustBurst(position: dustPos)
                        }

                        // Score popup
                        if let popup = scorePopup {
                            Text(popup.text)
                                .font(.custom("Cinzel-Bold", size: 18))
                                .foregroundStyle(popup.color)
                                .shadow(color: .black.opacity(0.5), radius: 2)
                                .position(popup.position)
                                .transition(.opacity)
                        }
                    }
                    .frame(width: stoneSize.width, height: stoneSize.height)
                    .contentShape(Rectangle())
                    .onTapGesture { location in
                        handleTap(at: location, stoneSize: stoneSize)
                    }

                    Spacer()

                    // Molecule info card (appears after stone splits)
                    if let mol = molecule, showMoleculeInfo {
                        MoleculeInfoCard(molecule: mol, show: true)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                            .padding(.horizontal, Spacing.lg)
                    }

                    // Hint
                    if !showMoleculeInfo {
                        Text("Swing your pickaxe! \u{26CF}\u{FE0F}")
                            .font(.custom("EBGaramond-Italic", size: 14))
                            .foregroundStyle(.white.opacity(0.5))
                            .padding(.bottom, Spacing.lg)
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
            .borderWorkshop()
            .padding(Spacing.xl)
        }
    }

    private func stoneSize(in viewSize: CGSize) -> CGSize {
        let w = min(viewSize.width - 120, 500)
        let h = w * 0.65
        return CGSize(width: w, height: h)
    }

    private func stoneBlockHalf(size: CGSize) -> some View {
        let stoneColor: Color = {
            switch selectedMaterial {
            case .marble: return Color(red: 0.92, green: 0.90, blue: 0.88)
            case .marbleDust: return Color(red: 0.82, green: 0.78, blue: 0.74)
            default: return Color(red: 0.72, green: 0.68, blue: 0.62)
            }
        }()

        return RoundedRectangle(cornerRadius: CornerRadius.md)
            .fill(
                LinearGradient(
                    colors: [
                        stoneColor,
                        stoneColor.opacity(0.85),
                        stoneColor.opacity(0.7)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                // Stone grain texture lines
                Canvas { context, canvasSize in
                    let lineCount = 12
                    for i in 0..<lineCount {
                        let y = CGFloat(i) * canvasSize.height / CGFloat(lineCount)
                        let wobble = sin(CGFloat(i) * 0.8) * 8
                        var path = Path()
                        path.move(to: CGPoint(x: 0, y: y + wobble))
                        path.addLine(to: CGPoint(x: canvasSize.width, y: y + wobble + 3))
                        context.stroke(path, with: .color(.black.opacity(0.06)), lineWidth: 0.5)
                    }
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.md)
                    .strokeBorder(Color.black.opacity(0.2), lineWidth: 2)
            )
            .frame(width: size.width, height: size.height)
            .opacity(stoneOpacity)
    }

    private func chiselTargetView(target: ChiselTarget, stoneSize: CGSize) -> some View {
        let pos = CGPoint(
            x: target.normalizedPosition.x * stoneSize.width,
            y: target.normalizedPosition.y * stoneSize.height
        )

        let currentSize = 60 * shrinkProgress

        return ZStack {
            // Outer ring (shrinking)
            Circle()
                .strokeBorder(RenaissanceColors.goldSuccess, lineWidth: 3)
                .frame(width: currentSize, height: currentSize)
                .opacity(0.8)

            // Inner glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            RenaissanceColors.goldSuccess.opacity(0.4),
                            RenaissanceColors.goldSuccess.opacity(0.0)
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: currentSize / 2
                    )
                )
                .frame(width: currentSize, height: currentSize)

            // Center pickaxe icon
            Image(systemName: "hammer.fill")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(RenaissanceColors.goldSuccess)
                .opacity(shrinkProgress > 0.3 ? 1 : shrinkProgress / 0.3)
        }
        .position(pos)
    }

    // MARK: - Phase 4: Success

    private var successCard: some View {
        VStack(spacing: 20) {
            // Header
            HStack(spacing: 12) {
                BirdCharacter()
                    .frame(width: 70, height: 70)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Pietra Spaccata!")
                        .font(.custom("Cinzel-Bold", size: 22))
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                    Text("You extracted 1x \(selectedMaterial.rawValue)")
                        .font(RenaissanceFont.dialogSubtitle)
                        .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))
                }
            }

            // Score rows (same card style as earnOptionCard)
            VStack(spacing: 10) {
                HStack(spacing: 12) {
                    Image(systemName: "hammer.fill")
                        .font(.body)
                        .foregroundStyle(RenaissanceColors.warmBrown)
                        .frame(width: 32, height: 32)
                        .background(
                            RoundedRectangle(cornerRadius: CornerRadius.sm)
                                .fill(RenaissanceColors.warmBrown.opacity(0.1))
                        )

                    Text("\(hits) hits, \(misses) miss\(misses == 1 ? "" : "es")")
                        .font(.custom("EBGaramond-Regular", size: 16))
                        .foregroundStyle(RenaissanceColors.sepiaInk)

                    Spacer()

                    Text(selectedMaterial.icon)
                        .font(.title3)
                }
                .padding(Spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(RenaissanceColors.parchment.opacity(0.6))
                        .borderWorkshop(radius: 10)
                )

                if perfectHits > 0 {
                    HStack(spacing: 12) {
                        Image(systemName: "star.fill")
                            .font(.body)
                            .foregroundStyle(RenaissanceColors.goldSuccess)
                            .frame(width: 32, height: 32)
                            .background(
                                RoundedRectangle(cornerRadius: CornerRadius.sm)
                                    .fill(RenaissanceColors.goldSuccess.opacity(0.1))
                            )

                        Text("\(perfectHits) perfect pickaxe strike\(perfectHits == 1 ? "" : "s")")
                            .font(.custom("EBGaramond-Regular", size: 16))
                            .foregroundStyle(RenaissanceColors.sepiaInk)

                        Spacer()

                        Text("+\(bonusFlorins) florins")
                            .font(.custom("EBGaramond-SemiBold", size: 13))
                            .foregroundStyle(RenaissanceColors.goldSuccess)
                    }
                    .padding(Spacing.sm)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(RenaissanceColors.parchment.opacity(0.6))
                            .borderWorkshop(radius: 10)
                    )
                }
            }

            // Molecule discovery row
            if let mol = molecule {
                HStack(spacing: 12) {
                    Image(systemName: "atom")
                        .font(.body)
                        .foregroundStyle(RenaissanceColors.renaissanceBlue)
                        .frame(width: 32, height: 32)
                        .background(
                            RoundedRectangle(cornerRadius: CornerRadius.sm)
                                .fill(RenaissanceColors.renaissanceBlue.opacity(0.1))
                        )

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Discovered: \(mol.formula)")
                            .font(.custom("Cinzel-Bold", size: 14))
                            .foregroundStyle(RenaissanceColors.sepiaInk)
                        Text(mol.educationalText)
                            .font(.custom("EBGaramond-Regular", size: 12))
                            .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.6))
                            .lineLimit(2)
                    }

                    Spacer()
                }
                .padding(Spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(RenaissanceColors.renaissanceBlue.opacity(0.05))
                        .borderWorkshop(radius: 10)
                )
            }

            Button {
                onComplete(selectedMaterial, bonusFlorins)
            } label: {
                HStack(spacing: 8) {
                    Text(selectedMaterial.icon)
                    Text("Collect \(selectedMaterial.rawValue)")
                        .font(.custom("EBGaramond-SemiBold", size: 16))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(RenaissanceColors.sageGreen)
                )
            }
        }
        .padding(Spacing.xl)
        .adaptiveWidth(400)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.lg)
                .fill(RenaissanceColors.parchment)
        )
        .borderWorkshop()
    }

    // MARK: - Phase 5: Failed

    private var failedCard: some View {
        VStack(spacing: 20) {
            // Header
            HStack(spacing: 12) {
                BirdCharacter()
                    .frame(width: 70, height: 70)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Stone Cracked Wrong")
                        .font(.custom("Cinzel-Bold", size: 22))
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                    Text("The fracture ran the wrong way.")
                        .font(RenaissanceFont.dialogSubtitle)
                        .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))
                }
            }

            Text("A good quarryman reads the grain before striking. Try again — the stone is patient.")
                .font(.custom("EBGaramond-Regular", size: 16))
                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))

            VStack(spacing: 10) {
                Button {
                    resetGame()
                    withAnimation { phase = .intro }
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.body)
                            .foregroundStyle(RenaissanceColors.sepiaInk)
                            .frame(width: 32, height: 32)
                            .background(
                                RoundedRectangle(cornerRadius: CornerRadius.sm)
                                    .fill(RenaissanceColors.warmBrown.opacity(0.1))
                            )

                        Text("Try Again")
                            .font(.custom("EBGaramond-Regular", size: 16))
                            .foregroundStyle(RenaissanceColors.sepiaInk)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(RenaissanceColors.sepiaInk)
                    }
                    .padding(Spacing.sm)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(RenaissanceColors.parchment.opacity(0.6))
                            .borderWorkshop(radius: 10)
                    )
                }

                Button {
                    onDismiss()
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "xmark")
                            .font(.body)
                            .foregroundStyle(RenaissanceColors.sepiaInk)
                            .frame(width: 32, height: 32)
                            .background(
                                RoundedRectangle(cornerRadius: CornerRadius.sm)
                                    .fill(RenaissanceColors.warmBrown.opacity(0.1))
                            )

                        Text("Leave Quarry")
                            .font(.custom("EBGaramond-Regular", size: 16))
                            .foregroundStyle(RenaissanceColors.sepiaInk)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(RenaissanceColors.sepiaInk)
                    }
                    .padding(Spacing.sm)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(RenaissanceColors.parchment.opacity(0.6))
                            .borderWorkshop(radius: 10)
                    )
                }
            }
        }
        .padding(Spacing.xl)
        .adaptiveWidth(400)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.lg)
                .fill(RenaissanceColors.parchment)
        )
        .borderWorkshop()
    }

    // MARK: - Game Logic

    private func startGame() {
        resetGame()
        generateTargets()
        fetchMolecule()
        withAnimation { phase = .playing }

        // Start bond pulse animation
        bondPulseTimer?.invalidate()
        bondPulseTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            bondPulse += 0.05
        }

        // Small delay before first target appears
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            beginShrinkCycle()
        }
    }

    private func fetchMolecule() {
        let compound = compoundForMaterial
        Task {
            do {
                let mol = try await pubchemService.fetchCompound(
                    name: compound.name,
                    formula: compound.formula,
                    educationalText: compound.educationalText
                )
                await MainActor.run {
                    self.molecule = mol
                }
            } catch {
                print("PubChem fetch failed: \(error.localizedDescription)")
            }
        }
    }

    private func resetGame() {
        targets = []
        activeTargetIndex = 0
        hits = 0
        misses = 0
        perfectHits = 0
        shrinkProgress = 1.0
        showCrackAt = []
        showDustAt = nil
        splitOffset = 0
        stoneOpacity = 1.0
        scorePopup = nil
        shrinkTimer?.invalidate()
        spawnTimer?.invalidate()
        moleculeReveal = 0
        showMoleculeInfo = false
        bondPulseTimer?.invalidate()
        bondPulse = 0
    }

    private func generateTargets() {
        // Generate 8 potential target positions spread across the stone
        // More than hitsNeeded so misses can be recovered
        let totalTargets = hitsNeeded + maxMisses
        targets = (0..<totalTargets).map { i in
            ChiselTarget(
                id: i,
                normalizedPosition: CGPoint(
                    x: 0.15 + CGFloat.random(in: 0...0.7),
                    y: 0.15 + CGFloat.random(in: 0...0.7)
                )
            )
        }
    }

    private func beginShrinkCycle() {
        shrinkProgress = 1.0

        let interval: TimeInterval = 0.016  // ~60fps
        let totalSteps = shrinkDuration / interval

        shrinkTimer?.invalidate()
        shrinkTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            shrinkProgress -= 1.0 / totalSteps

            if shrinkProgress <= 0 {
                // Missed — target faded out
                timer.invalidate()
                handleMiss()
            }
        }
    }

    private func handleTap(at location: CGPoint, stoneSize: CGSize) {
        guard phase == .playing,
              activeTargetIndex < targets.count else { return }

        let target = targets[activeTargetIndex]
        let targetPos = CGPoint(
            x: target.normalizedPosition.x * stoneSize.width,
            y: target.normalizedPosition.y * stoneSize.height
        )

        let distance = hypot(location.x - targetPos.x, location.y - targetPos.y)
        let hitRadius: CGFloat = 40  // Generous tap area

        if distance <= hitRadius {
            handleHit(at: targetPos)
        }
        // Tapping outside the target area does nothing — only misses from timeout count
    }

    private func handleHit(at position: CGPoint) {
        shrinkTimer?.invalidate()

        let isPerfect = shrinkProgress > 0.6
        hits += 1
        if isPerfect { perfectHits += 1 }

        // Visual feedback
        withAnimation(.easeOut(duration: 0.3)) {
            showCrackAt.append(position)
            showDustAt = position
            scorePopup = ScorePopup(
                text: isPerfect ? "Perfect strike! \u{26CF}\u{FE0F}" : "Good!",
                color: isPerfect ? RenaissanceColors.goldSuccess : .white,
                position: CGPoint(x: position.x, y: position.y - 30)
            )
            // Molecule progressively reveals with each hit
            moleculeReveal = CGFloat(hits) / CGFloat(hitsNeeded)
        }

        // Clear dust and popup after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation { showDustAt = nil; scorePopup = nil }
        }

        // Check win
        if hits >= hitsNeeded {
            completeSplit()
            return
        }

        // Next target
        advanceTarget()
    }

    private func handleMiss() {
        misses += 1

        if misses >= maxMisses {
            onNudgeCamera?()
            withAnimation { phase = .failed }
            return
        }

        // Advance to next target
        advanceTarget()
    }

    private func advanceTarget() {
        activeTargetIndex += 1
        if activeTargetIndex >= targets.count {
            // Ran out of targets — regenerate more
            let additional = maxMisses
            for i in 0..<additional {
                targets.append(ChiselTarget(
                    id: targets.count + i,
                    normalizedPosition: CGPoint(
                        x: 0.15 + CGFloat.random(in: 0...0.7),
                        y: 0.15 + CGFloat.random(in: 0...0.7)
                    )
                ))
            }
        }

        // Brief pause before next target
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            if phase == .playing {
                beginShrinkCycle()
            }
        }
    }

    private func completeSplit() {
        shrinkTimer?.invalidate()

        // Animate stone splitting — molecule fully revealed
        withAnimation(.easeInOut(duration: 0.8)) {
            splitOffset = 40
            stoneOpacity = 0.5
            moleculeReveal = 1.0
        }

        // Show molecule info card briefly before success
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.spring(response: 0.5)) {
                showMoleculeInfo = true
            }
        }

        // Transition to success after molecule reveal
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            bondPulseTimer?.invalidate()
            onNudgeCamera?()
            withAnimation { phase = .success }
        }
    }
}

// MARK: - Supporting Models

struct ChiselTarget: Identifiable {
    let id: Int
    let normalizedPosition: CGPoint   // 0...1 range within stone
}

struct ScorePopup {
    let text: String
    let color: Color
    let position: CGPoint
}

// MARK: - Crack Shape

/// Draws a jagged crack line emanating from an origin point
struct CrackShape: Shape {
    let origin: CGPoint
    let seed: Int

    func path(in rect: CGRect) -> Path {
        var path = Path()
        var rng = SeededRNG(seed: UInt64(abs(seed)))

        // Draw 2-3 branching cracks from the origin
        let branchCount = 2 + (seed % 2)
        for b in 0..<branchCount {
            let angle = Double(b) * (.pi / Double(branchCount)) + .pi * 0.25
            var current = origin
            path.move(to: current)

            let segments = 4 + (seed % 3)
            for _ in 0..<segments {
                let length = CGFloat(8 + rng.nextInt(bound: 12))
                let wobble = Double(rng.nextInt(bound: 40) - 20) * .pi / 180.0
                let dx = cos(angle + wobble) * Double(length)
                let dy = sin(angle + wobble) * Double(length)
                current = CGPoint(x: current.x + dx, y: current.y + dy)
                path.addLine(to: current)
            }
        }

        return path
    }
}

/// Simple seeded RNG for deterministic crack patterns
struct SeededRNG {
    var state: UInt64

    init(seed: UInt64) {
        state = seed == 0 ? 1 : seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return state
    }

    mutating func nextInt(bound: Int) -> Int {
        guard bound > 0 else { return 0 }
        return Int(next() % UInt64(bound))
    }
}

// MARK: - Dust Burst Effect

/// Simple particle burst at a point — uses multiple circles that expand and fade
struct DustBurst: View {
    let position: CGPoint

    @State private var animate = false

    var body: some View {
        ZStack {
            ForEach(0..<6, id: \.self) { i in
                Circle()
                    .fill(Color(red: 0.75, green: 0.70, blue: 0.62).opacity(animate ? 0 : 0.6))
                    .frame(width: 8, height: 8)
                    .offset(
                        x: animate ? cos(Double(i) * .pi / 3) * 25 : 0,
                        y: animate ? sin(Double(i) * .pi / 3) * 25 : 0
                    )
            }
        }
        .position(position)
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) {
                animate = true
            }
        }
    }
}
