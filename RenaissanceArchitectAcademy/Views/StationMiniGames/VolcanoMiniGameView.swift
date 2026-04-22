import SwiftUI

/// Volcano "Il Vulcano" — THREE distinct mini-games based on real volcanic material collection:
/// 1. Pozzolana "La Pozzolana" (Easy) — Identify true volcanic ash from earth samples
/// 2. Cinnabar "Il Cinabro" (Medium) — Carefully extract red HgS crystals from rock wall
/// 3. Sulfur "Lo Zolfo" (Hard) — Grab crystals between toxic gas clouds at a fumarole
struct VolcanoMiniGameView: View {

    let onComplete: (Material, Int) -> Void
    let onDismiss: () -> Void
    var onNudgeCamera: (() -> Void)? = nil
    /// Optional — if set, adds "Ask the Master for help" button to the fail card.
    var onAskMasterHelp: (() -> Void)? = nil

    @Environment(\.gameSettings) private var settings

    // MARK: - Phases

    enum Phase: Equatable {
        case choose
        case introAsh
        case introCinnabar
        case introSulfur
        case playingAsh
        case playingCinnabar
        case playingSulfur
        case success
        case failed
    }

    @State private var phase: Phase = .choose
    @State private var selectedMaterial: Material = .volcanicAsh

    // ── Pozzolana (ash identification) state ──
    @State private var ashSamples: [AshSample] = []
    @State private var ashCollected: Int = 0
    @State private var ashMisses: Int = 0
    @State private var ashFeedback: String?
    @State private var ashFeedbackColor: Color = .white

    private let ashNeeded = 6
    private let ashMaxMisses = 3
    private let ashGridCols = 4
    private let ashGridRows = 3

    // ── Cinnabar (crystal extraction) state ──
    @State private var crystalNodes: [CrystalNode] = []
    @State private var crystalsExtracted: Int = 0
    @State private var crystalsCracked: Int = 0
    @State private var cinnabarFeedback: String?
    @State private var cinnabarFeedbackColor: Color = .white

    private let crystalsNeeded = 5
    private let maxCracks = 3

    // ── Sulfur (fumarole grab) state ──
    @State private var sulfurCrystals: [SulfurCrystal] = []
    @State private var sulfurCollected: Int = 0
    @State private var sulfurMissed: Int = 0
    @State private var gasCloudOpacity: Double = 0.0
    @State private var isGasClear: Bool = true
    @State private var sulfurTimer: Timer?
    @State private var gasTimer: Timer?
    @State private var sulfurFeedback: String?
    @State private var sulfurFeedbackColor: Color = .white

    private let sulfurNeeded = 5
    private let sulfurMaxMissed = 4  // crystals that expired uncollected

    // ── Shared ──
    @State private var perfectCount: Int = 0

    private var bonusFlorins: Int { perfectCount * 2 }

    // MARK: - Body

    var body: some View {
        ZStack {
            if phase == .playingAsh || phase == .playingCinnabar || phase == .playingSulfur {
                RenaissanceColors.overlayDimming
                    .ignoresSafeArea()

                Group {
                    switch phase {
                    case .playingAsh:      ashGameView
                    case .playingCinnabar: cinnabarGameView
                    case .playingSulfur:   sulfurGameView
                    default: EmptyView()
                    }
                }
                .transition(.opacity)
            } else {
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
                        case .choose:        choiceCard
                        case .introAsh:      introAshCard
                        case .introCinnabar: introCinnabarCard
                        case .introSulfur:   introSulfurCard
                        case .success:       successCard
                        case .failed:        failedCard
                        default:             EmptyView()
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

    // MARK: - Choice Card

    private var choiceCard: some View {
        VStack(spacing: Spacing.lg) {
            HStack(spacing: 14) {
                BirdCharacter()
                    .frame(width: 70, height: 70)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Il Vulcano")
                        .font(RenaissanceFont.title)
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                    Text("The volcano gives three treasures — each demands different skill.")
                        .font(RenaissanceFont.body)
                        .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))
                }
                Spacer()
            }

            VStack(spacing: 12) {
                materialOptionRow(
                    material: .volcanicAsh,
                    difficulty: "Easy",
                    description: "Identify true pozzolana — the ash that makes eternal concrete"
                )
                materialOptionRow(
                    material: .cinnabar,
                    difficulty: "Medium",
                    description: "Extract red HgS crystals from volcanic rock without cracking them"
                )
                materialOptionRow(
                    material: .sulfur,
                    difficulty: "Hard",
                    description: "Grab sulfur crystals between waves of toxic fumarole gas"
                )
            }

            Button("Back") { onDismiss() }
                .font(RenaissanceFont.body)
                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.5))
        }
        .padding(Spacing.xl)
        .padding(.bottom, 60)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.xl)
                .fill(RenaissanceColors.parchment)
        )
        .borderModal(radius: CornerRadius.xl)
    }

    private func materialOptionRow(material: Material, difficulty: String, description: String) -> some View {
        Button {
            selectedMaterial = material
            withAnimation {
                switch material {
                case .volcanicAsh: phase = .introAsh
                case .cinnabar:    phase = .introCinnabar
                case .sulfur:      phase = .introSulfur
                default: break
                }
            }
        } label: {
            HStack(spacing: 14) {
                MaterialIconView(material: material, size: 36)
                    .frame(width: 44, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: CornerRadius.sm)
                            .fill(RenaissanceColors.furnaceOrange.opacity(0.1))
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(material.rawValue)
                        .font(RenaissanceFont.bodySemibold)
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                    Text(description)
                        .font(RenaissanceFont.bodySmall)
                        .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.6))
                        .lineLimit(2)
                }

                Spacer()

                Text(difficulty)
                    .font(RenaissanceFont.bodySemibold)
                    .foregroundStyle(miniGameDifficultyColor(difficulty))

                Image(systemName: "chevron.right")
                    .font(.body)
                    .foregroundStyle(RenaissanceColors.sepiaInk)
            }
            .padding(Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(RenaissanceColors.parchment.opacity(0.6))
                    .borderWorkshop(radius: 10)
            )
        }
    }

    // MARK: - Shared Helpers (migrated to MiniGameSharedComponents.swift)

    // ═══════════════════════════════════════════════════════════════
    // MARK: - 1. POZZOLANA GAME — "La Pozzolana"
    // ═══════════════════════════════════════════════════════════════

    private var introAshCard: some View {
        MiniGameIntroCard(
            icon: "mountain.2.fill",
            iconColor: RenaissanceColors.furnaceOrange,
            title: "La Pozzolana",
            subtitle: "Identify the Volcanic Ash",
            bodyText: "Rake through the cooled lava field with your ash rake. Near Pozzuoli, workers searched for the right ash. Not all volcanic material works — only pozzolana rich in silica and alumina reacts with lime to form concrete that hardens underwater. Romans discovered this by accident. 2,000 years later, their harbors still stand.",
            buttonLabel: "Begin Collecting",
            buttonColor: RenaissanceColors.furnaceOrange,
            startAction: { startAshGame() },
            backAction: { withAnimation { phase = .choose } }
        ) {
            VStack(spacing: 10) {
                MiniGameRuleRow(icon: "hand.tap.fill", text: "Tap reddish-brown pozzolana samples", color: RenaissanceColors.furnaceOrange)
                MiniGameRuleRow(icon: "xmark.circle", text: "Avoid regular soil, rock, and pumice — \(ashMaxMisses) mistakes allowed", color: RenaissanceColors.errorRed)
                MiniGameRuleRow(icon: "star.fill", text: "No mistakes = bonus florins", color: RenaissanceColors.goldSuccess)
            }
        }
    }

    private var ashGameView: some View {
        GeometryReader { geo in
            let cellSize = min((geo.size.width - 100) / CGFloat(ashGridCols), 80)

            ZStack {
                // Volcanic landscape background
                RoundedRectangle(cornerRadius: CornerRadius.lg)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.25, green: 0.20, blue: 0.18),
                                Color(red: 0.30, green: 0.22, blue: 0.15),
                                Color(red: 0.35, green: 0.25, blue: 0.18)
                            ],
                            startPoint: .top, endPoint: .bottom
                        )
                    )

                VStack(spacing: Spacing.md) {
                    // HUD
                    HStack {
                        HStack(spacing: 6) {
                            ForEach(0..<ashNeeded, id: \.self) { i in
                                Circle()
                                    .fill(i < ashCollected ? RenaissanceColors.goldSuccess : Color.white.opacity(0.2))
                                    .frame(width: 10, height: 10)
                            }
                            Text("\(ashCollected)/\(ashNeeded)")
                                .font(.custom("EBGaramond-Regular", size: 13))
                                .foregroundStyle(.white.opacity(0.7))
                        }

                        Spacer()

                        HStack(spacing: 4) {
                            Text("\u{1F9F9}")
                            Text("La Pozzolana")
                                .font(.custom("Cinzel-Bold", size: 16))
                                .foregroundStyle(.white)
                        }

                        Spacer()

                        HStack(spacing: 4) {
                            ForEach(0..<ashMaxMisses, id: \.self) { i in
                                Image(systemName: i < ashMisses ? "xmark.circle.fill" : "xmark.circle")
                                    .font(.caption)
                                    .foregroundStyle(i < ashMisses ? RenaissanceColors.errorRed : .white.opacity(0.3))
                            }
                        }
                    }
                    .padding(.horizontal, Spacing.lg)
                    .padding(.vertical, Spacing.sm)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.black.opacity(0.3)))
                    .padding(.horizontal, Spacing.md)
                    .padding(.top, Spacing.md)

                    if let fb = ashFeedback {
                        Text(fb)
                            .font(.custom("EBGaramond-SemiBold", size: 15))
                            .foregroundStyle(ashFeedbackColor)
                            .transition(.opacity)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, Spacing.md)
                    }

                    Spacer()

                    // Earth samples grid
                    VStack(spacing: 8) {
                        ForEach(0..<ashGridRows, id: \.self) { row in
                            HStack(spacing: 8) {
                                ForEach(0..<ashGridCols, id: \.self) { col in
                                    let index = row * ashGridCols + col
                                    if index < ashSamples.count {
                                        ashSampleButton(sample: ashSamples[index], index: index, cellSize: cellSize)
                                    } else {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.clear)
                                            .frame(width: cellSize, height: cellSize)
                                    }
                                }
                            }
                        }
                    }

                    Spacer()

                    Text("Use your ash rake \u{1F9F9} to identify pozzolana")
                        .font(.custom("EBGaramond-Italic", size: 13))
                        .foregroundStyle(.white.opacity(0.4))
                        .padding(.bottom, Spacing.lg)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
            .borderWorkshop()
            .padding(Spacing.xl)
        }
    }

    private func ashSampleButton(sample: AshSample, index: Int, cellSize: CGFloat) -> some View {
        Button {
            handleAshTap(index: index)
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        sample.tapped
                            ? (sample.isPozzolana
                               ? RenaissanceColors.sageGreen.opacity(0.3)
                               : RenaissanceColors.errorRed.opacity(0.3))
                            : sample.color
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(
                                sample.tapped
                                    ? (sample.isPozzolana ? RenaissanceColors.sageGreen : RenaissanceColors.errorRed)
                                    : Color.white.opacity(0.1),
                                lineWidth: 1.5
                            )
                    )

                if sample.tapped {
                    VStack(spacing: 2) {
                        Image(systemName: sample.isPozzolana ? "checkmark" : "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(sample.isPozzolana ? RenaissanceColors.sageGreen : RenaissanceColors.errorRed)
                        Text(sample.label)
                            .font(.custom("EBGaramond-Regular", size: 9))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                } else {
                    // Show visual cue — color + texture name
                    VStack(spacing: 2) {
                        Text(sample.icon)
                            .font(.system(size: cellSize * 0.3))
                        Text(sample.label)
                            .font(.custom("EBGaramond-Regular", size: 10))
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }
            }
            .frame(width: cellSize, height: cellSize)
        }
        .buttonStyle(.plain)
        .disabled(sample.tapped)
    }

    // Ash Logic

    private func startAshGame() {
        ashCollected = 0
        ashMisses = 0
        ashFeedback = nil
        perfectCount = 0
        generateAshGrid()
        withAnimation { phase = .playingAsh }
    }

    private func generateAshGrid() {
        let totalCells = ashGridRows * ashGridCols
        let pozzolanaCount = ashNeeded + 1

        var items: [AshSample] = []

        // True pozzolana — reddish-brown volcanic ash
        for i in 0..<pozzolanaCount {
            items.append(AshSample(
                id: i,
                label: ["Pozzolana", "Volcanic Ash", "Red Ash", "Fine Ash", "Silica Ash", "Brown Ash", "Vesuvian Ash"].randomElement()!,
                icon: "🟤",
                color: Color(
                    red: Double.random(in: 0.55...0.70),
                    green: Double.random(in: 0.28...0.38),
                    blue: Double.random(in: 0.15...0.25)
                ),
                isPozzolana: true,
                scienceFact: [
                    "SiO₂ + Al₂O₃ — reacts with lime",
                    "Pozzolanic reaction: ash + Ca(OH)₂ → C-S-H gel",
                    "Silica-rich — hardens even underwater",
                    "From Pozzuoli — gave pozzolana its name",
                    "80% silica + alumina content",
                    "Roman concrete: 2000 years and counting",
                    "Key ingredient in opus caementicium"
                ].randomElement()!,
                tapped: false
            ))
        }

        // Distractors
        let distractors: [(String, String, Color, String)] = [
            ("Topsoil", "🌱", Color(red: 0.35, green: 0.30, blue: 0.20), "Organic matter — burns, doesn't bind"),
            ("Grey Pumice", "⬜", Color(red: 0.60, green: 0.58, blue: 0.55), "Too porous — no binding strength"),
            ("Black Basalt", "⬛", Color(red: 0.20, green: 0.18, blue: 0.18), "Dense lava rock — won't react with lime"),
            ("River Sand", "🟡", Color(red: 0.70, green: 0.62, blue: 0.42), "Quartz sand — filler, not binder"),
            ("Yellow Clay", "🟨", Color(red: 0.68, green: 0.58, blue: 0.30), "Clay swells with water — cracks concrete"),
        ]

        let debrisCount = totalCells - pozzolanaCount
        for i in 0..<debrisCount {
            let d = distractors[i % distractors.count]
            items.append(AshSample(
                id: pozzolanaCount + i,
                label: d.0,
                icon: d.1,
                color: d.2,
                isPozzolana: false,
                scienceFact: d.3,
                tapped: false
            ))
        }

        ashSamples = items.shuffled()
    }

    private func handleAshTap(index: Int) {
        guard index < ashSamples.count, !ashSamples[index].tapped else { return }

        ashSamples[index].tapped = true
        let sample = ashSamples[index]

        if sample.isPozzolana {
            ashCollected += 1
            withAnimation {
                ashFeedback = "Pozzolana! \(sample.scienceFact)"
                ashFeedbackColor = RenaissanceColors.sageGreen
            }

            if ashCollected >= ashNeeded {
                perfectCount = ashMisses == 0 ? 3 : 0
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    onNudgeCamera?()
                    withAnimation { phase = .success }
                }
                return
            }
        } else {
            ashMisses += 1
            withAnimation {
                ashFeedback = "Not pozzolana! \(sample.scienceFact)"
                ashFeedbackColor = RenaissanceColors.errorRed
            }

            if ashMisses >= ashMaxMisses {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    onNudgeCamera?()
                    withAnimation { phase = .failed }
                }
                return
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation { ashFeedback = nil }
        }
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: - 2. CINNABAR GAME — "Il Cinabro"
    // ═══════════════════════════════════════════════════════════════

    private var introCinnabarCard: some View {
        MiniGameIntroCard(
            icon: "sparkles",
            iconColor: RenaissanceColors.furnaceOrange,
            title: "Il Cinabro",
            subtitle: "Extract the Red Crystals",
            bodyText: "Use the rake handle to chip red crystals from the rock. Cinnabar — mercury sulfide, HgS — forms in volcanic vents where mercury vapor meets sulfur deposits. The most prized pigment in Rome: vermillion red. Too hard a strike shatters the crystal into worthless dust. Too gentle and it stays locked in stone.",
            buttonLabel: "Begin Extraction",
            buttonColor: Color(red: 0.75, green: 0.15, blue: 0.15),
            startAction: { startCinnabarGame() },
            backAction: { withAnimation { phase = .choose } }
        ) {
            VStack(spacing: 10) {
                MiniGameRuleRow(icon: "hand.tap.fill", text: "Tap red crystal veins gently — 2 taps to extract", color: Color(red: 0.75, green: 0.15, blue: 0.15))
                MiniGameRuleRow(icon: "xmark.circle", text: "Tap grey rock = crack! \(maxCracks) cracks and the wall collapses", color: RenaissanceColors.errorRed)
                MiniGameRuleRow(icon: "star.fill", text: "No cracks = perfect extraction bonus", color: RenaissanceColors.goldSuccess)
            }
        }
    }

    private var cinnabarGameView: some View {
        GeometryReader { geo in
            let cols = 5
            let rows = 4
            let cellSize = min((geo.size.width - 80) / CGFloat(cols), (geo.size.height - 220) / CGFloat(rows), 75)

            ZStack {
                // Dark cave wall background
                RoundedRectangle(cornerRadius: CornerRadius.lg)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.18, green: 0.15, blue: 0.14),
                                Color(red: 0.22, green: 0.18, blue: 0.16),
                                Color(red: 0.16, green: 0.12, blue: 0.10)
                            ],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )

                VStack(spacing: Spacing.md) {
                    // HUD
                    HStack {
                        HStack(spacing: 6) {
                            ForEach(0..<crystalsNeeded, id: \.self) { i in
                                Image(systemName: "diamond.fill")
                                    .font(.system(size: 10))
                                    .foregroundStyle(i < crystalsExtracted ? Color(red: 0.85, green: 0.2, blue: 0.2) : Color.white.opacity(0.2))
                            }
                            Text("\(crystalsExtracted)/\(crystalsNeeded)")
                                .font(.custom("EBGaramond-Regular", size: 13))
                                .foregroundStyle(.white.opacity(0.7))
                        }

                        Spacer()

                        HStack(spacing: 4) {
                            Text("\u{1F9F9}")
                            Text("Il Cinabro")
                                .font(.custom("Cinzel-Bold", size: 16))
                                .foregroundStyle(.white)
                        }

                        Spacer()

                        HStack(spacing: 4) {
                            ForEach(0..<maxCracks, id: \.self) { i in
                                Image(systemName: i < crystalsCracked ? "bolt.fill" : "bolt")
                                    .font(.caption)
                                    .foregroundStyle(i < crystalsCracked ? RenaissanceColors.errorRed : .white.opacity(0.3))
                            }
                        }
                    }
                    .padding(.horizontal, Spacing.lg)
                    .padding(.vertical, Spacing.sm)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.black.opacity(0.3)))
                    .padding(.horizontal, Spacing.md)
                    .padding(.top, Spacing.md)

                    if let fb = cinnabarFeedback {
                        Text(fb)
                            .font(.custom("EBGaramond-SemiBold", size: 15))
                            .foregroundStyle(cinnabarFeedbackColor)
                            .transition(.opacity)
                            .padding(.horizontal, Spacing.md)
                    }

                    Spacer()

                    // Rock wall grid
                    VStack(spacing: 3) {
                        ForEach(0..<rows, id: \.self) { row in
                            HStack(spacing: 3) {
                                ForEach(0..<cols, id: \.self) { col in
                                    let index = row * cols + col
                                    if index < crystalNodes.count {
                                        crystalNodeView(node: crystalNodes[index], index: index, cellSize: cellSize)
                                    }
                                }
                            }
                        }
                    }

                    Spacer()

                    Text("Tap with your rake handle \u{1F9F9} to extract")
                        .font(.custom("EBGaramond-Italic", size: 13))
                        .foregroundStyle(.white.opacity(0.4))
                        .padding(.bottom, Spacing.lg)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
            .borderWorkshop()
            .padding(Spacing.xl)
        }
    }

    private func crystalNodeView(node: CrystalNode, index: Int, cellSize: CGFloat) -> some View {
        Button {
            handleCrystalTap(index: index)
        } label: {
            ZStack {
                // Rock or crystal background
                RoundedRectangle(cornerRadius: 4)
                    .fill(node.displayColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .strokeBorder(
                                node.state == .extracted ? RenaissanceColors.sageGreen.opacity(0.6) :
                                node.state == .cracked ? RenaissanceColors.errorRed.opacity(0.6) :
                                node.isCrystal ? Color(red: 0.85, green: 0.2, blue: 0.2).opacity(0.3) :
                                Color.white.opacity(0.05),
                                lineWidth: node.isCrystal && node.state == .intact ? 1.5 : 1
                            )
                    )

                // Content
                if node.state == .extracted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(RenaissanceColors.sageGreen)
                } else if node.state == .cracked {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(RenaissanceColors.errorRed.opacity(0.6))
                } else if node.isCrystal {
                    // Crystal vein — show red sparkle
                    VStack(spacing: 1) {
                        Image(systemName: "diamond.fill")
                            .font(.system(size: cellSize * 0.25))
                            .foregroundStyle(Color(red: 0.85, green: 0.2, blue: 0.2))
                        if node.tapsRemaining < 2 {
                            Text("1 more")
                                .font(.custom("EBGaramond-Regular", size: 8))
                                .foregroundStyle(.white.opacity(0.5))
                        }
                    }
                } else {
                    // Rock texture
                    Canvas { context, size in
                        // Rock grain lines
                        for i in 0..<3 {
                            let y = CGFloat(i + 1) * size.height / 4
                            var path = Path()
                            path.move(to: CGPoint(x: 2, y: y))
                            path.addLine(to: CGPoint(x: size.width - 2, y: y + CGFloat(i % 2 == 0 ? 2 : -2)))
                            context.stroke(path, with: .color(.white.opacity(0.06)), lineWidth: 0.5)
                        }
                    }
                }
            }
            .frame(width: cellSize, height: cellSize)
        }
        .buttonStyle(.plain)
        .disabled(node.state != .intact)
    }

    // Cinnabar Logic

    private func startCinnabarGame() {
        crystalsExtracted = 0
        crystalsCracked = 0
        cinnabarFeedback = nil
        perfectCount = 0
        generateCrystalWall()
        withAnimation { phase = .playingCinnabar }
    }

    private func generateCrystalWall() {
        let total = 20  // 5x4
        let crystalCount = crystalsNeeded + 2

        var nodes: [CrystalNode] = []

        for i in 0..<crystalCount {
            nodes.append(CrystalNode(
                id: i,
                isCrystal: true,
                tapsRemaining: 2,
                state: .intact
            ))
        }

        for i in crystalCount..<total {
            nodes.append(CrystalNode(
                id: i,
                isCrystal: false,
                tapsRemaining: 1,
                state: .intact
            ))
        }

        crystalNodes = nodes.shuffled()
    }

    private func handleCrystalTap(index: Int) {
        guard index < crystalNodes.count, crystalNodes[index].state == .intact else { return }

        if crystalNodes[index].isCrystal {
            crystalNodes[index].tapsRemaining -= 1

            if crystalNodes[index].tapsRemaining <= 0 {
                // Extracted!
                crystalNodes[index].state = .extracted
                crystalsExtracted += 1

                withAnimation {
                    cinnabarFeedback = "HgS crystal extracted! Mercury sulfide — vermillion pigment."
                    cinnabarFeedbackColor = Color(red: 0.85, green: 0.2, blue: 0.2)
                }

                if crystalsExtracted >= crystalsNeeded {
                    perfectCount = crystalsCracked == 0 ? 3 : 0
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        onNudgeCamera?()
                        withAnimation { phase = .success }
                    }
                    return
                }
            } else {
                withAnimation {
                    cinnabarFeedback = "Loosening crystal... tap once more!"
                    cinnabarFeedbackColor = RenaissanceColors.ochre
                }
            }
        } else {
            // Hit rock — crack!
            crystalNodes[index].state = .cracked
            crystalsCracked += 1

            withAnimation {
                cinnabarFeedback = "Crack! That was plain rock."
                cinnabarFeedbackColor = RenaissanceColors.errorRed
            }

            if crystalsCracked >= maxCracks {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    onNudgeCamera?()
                    withAnimation { phase = .failed }
                }
                return
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation { cinnabarFeedback = nil }
        }
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: - 3. SULFUR GAME — "Lo Zolfo"
    // ═══════════════════════════════════════════════════════════════

    private var introSulfurCard: some View {
        MiniGameIntroCard(
            icon: "flame.fill",
            iconColor: RenaissanceColors.furnaceOrange,
            title: "Lo Zolfo",
            subtitle: "Rake Between the Gas Clouds",
            bodyText: "Rake sulfur crystals to safety between gas bursts. Sicilian sulfur miners worked at fumaroles — volcanic vents spewing SO₂ and H₂S at lethal concentrations. Sulfur crystallizes in brilliant yellow formations around the vent opening. Breathe wrong and your lungs burn. Hesitate and the crystal re-sublimates back to gas.",
            buttonLabel: "Begin Collecting",
            buttonColor: Color(red: 0.75, green: 0.70, blue: 0.15),
            startAction: { startSulfurGame() },
            backAction: { withAnimation { phase = .choose } }
        ) {
            VStack(spacing: 10) {
                MiniGameRuleRow(icon: "hand.tap.fill", text: "Tap yellow crystals when the air is clear", color: Color(red: 0.75, green: 0.70, blue: 0.15))
                MiniGameRuleRow(icon: "cloud.fill", text: "Wait for gas clouds to pass — can't grab in fog", color: Color(red: 0.55, green: 0.65, blue: 0.40))
                MiniGameRuleRow(icon: "timer", text: "Crystals vanish fast — miss \(sulfurMaxMissed) and you fail", color: RenaissanceColors.errorRed)
            }
        }
    }

    private var sulfurGameView: some View {
        GeometryReader { geo in
            ZStack {
                // Volcanic vent background — dark with yellow/green tint
                RoundedRectangle(cornerRadius: CornerRadius.lg)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.20, green: 0.22, blue: 0.12),
                                Color(red: 0.15, green: 0.15, blue: 0.08),
                                Color(red: 0.12, green: 0.10, blue: 0.05)
                            ],
                            startPoint: .top, endPoint: .bottom
                        )
                    )

                // Vent glow at bottom
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 0.6, green: 0.5, blue: 0.1).opacity(0.3),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 150
                        )
                    )
                    .frame(width: 300, height: 200)
                    .offset(y: geo.size.height * 0.3)

                VStack(spacing: Spacing.md) {
                    // HUD
                    HStack {
                        HStack(spacing: 6) {
                            ForEach(0..<sulfurNeeded, id: \.self) { i in
                                Image(systemName: "diamond.fill")
                                    .font(.system(size: 10))
                                    .foregroundStyle(i < sulfurCollected ? Color(red: 0.85, green: 0.80, blue: 0.15) : Color.white.opacity(0.2))
                            }
                            Text("\(sulfurCollected)/\(sulfurNeeded)")
                                .font(.custom("EBGaramond-Regular", size: 13))
                                .foregroundStyle(.white.opacity(0.7))
                        }

                        Spacer()

                        HStack(spacing: 4) {
                            Text("\u{1F9F9}")
                            Text("Lo Zolfo")
                                .font(.custom("Cinzel-Bold", size: 16))
                                .foregroundStyle(.white)
                        }

                        Spacer()

                        HStack(spacing: 4) {
                            Image(systemName: "wind")
                                .font(.caption)
                                .foregroundStyle(isGasClear ? RenaissanceColors.sageGreen : Color(red: 0.6, green: 0.7, blue: 0.2))
                            Text(isGasClear ? "Clear" : "Gas!")
                                .font(.custom("EBGaramond-Regular", size: 12))
                                .foregroundStyle(isGasClear ? RenaissanceColors.sageGreen : RenaissanceColors.errorRed)
                        }
                    }
                    .padding(.horizontal, Spacing.lg)
                    .padding(.vertical, Spacing.sm)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.black.opacity(0.3)))
                    .padding(.horizontal, Spacing.md)
                    .padding(.top, Spacing.md)

                    if let fb = sulfurFeedback {
                        Text(fb)
                            .font(.custom("EBGaramond-SemiBold", size: 15))
                            .foregroundStyle(sulfurFeedbackColor)
                            .transition(.opacity)
                    }

                    Spacer()

                    // Crystal field — scattered positions
                    ZStack {
                        // Crystal buttons
                        ForEach(Array(sulfurCrystals.enumerated()), id: \.element.id) { _, crystal in
                            if crystal.state == .visible {
                                Button {
                                    handleSulfurTap(id: crystal.id)
                                } label: {
                                    ZStack {
                                        // Glow
                                        Circle()
                                            .fill(
                                                RadialGradient(
                                                    colors: [
                                                        Color(red: 0.9, green: 0.85, blue: 0.2).opacity(0.4),
                                                        Color.clear
                                                    ],
                                                    center: .center,
                                                    startRadius: 5,
                                                    endRadius: 30
                                                )
                                            )
                                            .frame(width: 60, height: 60)

                                        // Crystal shape
                                        Image(systemName: "diamond.fill")
                                            .font(.system(size: 24))
                                            .foregroundStyle(
                                                LinearGradient(
                                                    colors: [
                                                        Color(red: 0.95, green: 0.90, blue: 0.20),
                                                        Color(red: 0.80, green: 0.75, blue: 0.10)
                                                    ],
                                                    startPoint: .top, endPoint: .bottom
                                                )
                                            )
                                            .shadow(color: Color(red: 0.9, green: 0.8, blue: 0.1).opacity(0.5), radius: 4)
                                    }
                                }
                                .buttonStyle(.plain)
                                .position(
                                    x: crystal.normalizedX * (geo.size.width - 120) + 60,
                                    y: crystal.normalizedY * 250 + 30
                                )
                                .transition(.scale.combined(with: .opacity))
                            }
                        }
                    }
                    .frame(height: 310)

                    Spacer()

                    // Missed counter
                    if sulfurMissed > 0 {
                        Text("Crystals lost: \(sulfurMissed)/\(sulfurMaxMissed)")
                            .font(.custom("EBGaramond-Regular", size: 13))
                            .foregroundStyle(RenaissanceColors.errorRed.opacity(0.7))
                    }

                    Text(isGasClear ? "Rake crystals now! \u{1F9F9}" : "Wait for the gas to clear...")
                        .font(.custom("EBGaramond-Italic", size: 13))
                        .foregroundStyle(.white.opacity(0.4))
                        .padding(.bottom, Spacing.lg)
                }

                // Gas cloud overlay
                if gasCloudOpacity > 0 {
                    RoundedRectangle(cornerRadius: CornerRadius.lg)
                        .fill(
                            Color(red: 0.45, green: 0.50, blue: 0.25).opacity(gasCloudOpacity * 0.7)
                        )
                        .allowsHitTesting(false)

                    // Toxic gas text
                    if gasCloudOpacity > 0.5 {
                        VStack {
                            Spacer()
                            Text("☠️ SO₂ + H₂S")
                                .font(.custom("Cinzel-Bold", size: 20))
                                .foregroundStyle(Color(red: 0.7, green: 0.75, blue: 0.3).opacity(gasCloudOpacity))
                            Text("Toxic volcanic gas — wait!")
                                .font(.custom("EBGaramond-Italic", size: 14))
                                .foregroundStyle(.white.opacity(gasCloudOpacity * 0.6))
                            Spacer()
                        }
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
            .borderWorkshop()
            .padding(Spacing.xl)
        }
    }

    // Sulfur Logic

    private func startSulfurGame() {
        sulfurCollected = 0
        sulfurMissed = 0
        sulfurFeedback = nil
        gasCloudOpacity = 0
        isGasClear = true
        perfectCount = 0
        sulfurCrystals = []
        sulfurTimer?.invalidate()
        gasTimer?.invalidate()

        withAnimation { phase = .playingSulfur }

        // Spawn first crystals after brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            spawnSulfurCrystals()
        }

        // Gas cycle: clear for 3-4s, then gas for 2-3s
        startGasCycle()
    }

    private func startGasCycle() {
        guard phase == .playingSulfur else { return }

        // Clear phase
        isGasClear = true
        let clearDuration = Double.random(in: 3.0...4.5)

        DispatchQueue.main.asyncAfter(deadline: .now() + clearDuration) {
            guard self.phase == .playingSulfur else { return }

            // Gas rolls in
            withAnimation(.easeIn(duration: 0.8)) {
                self.gasCloudOpacity = 1.0
                self.isGasClear = false
            }

            let gasDuration = Double.random(in: 2.0...3.0)
            DispatchQueue.main.asyncAfter(deadline: .now() + gasDuration) {
                guard self.phase == .playingSulfur else { return }

                // Gas clears
                withAnimation(.easeOut(duration: 0.6)) {
                    self.gasCloudOpacity = 0
                    self.isGasClear = true
                }

                // Spawn new crystals when gas clears
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.spawnSulfurCrystals()
                }

                // Continue cycle
                self.startGasCycle()
            }
        }
    }

    private func spawnSulfurCrystals() {
        guard phase == .playingSulfur else { return }

        // Add 2-3 crystals at random positions
        let count = Int.random(in: 2...3)
        let baseId = (sulfurCrystals.last?.id ?? -1) + 1

        for i in 0..<count {
            let crystal = SulfurCrystal(
                id: baseId + i,
                normalizedX: CGFloat.random(in: 0.1...0.9),
                normalizedY: CGFloat.random(in: 0.1...0.9),
                state: .visible
            )

            withAnimation(.spring(response: 0.3)) {
                sulfurCrystals.append(crystal)
            }

            // Crystal expires after 4-6 seconds
            let crystalId = crystal.id
            let expiry = Double.random(in: 4.0...6.0)
            DispatchQueue.main.asyncAfter(deadline: .now() + expiry) {
                self.expireCrystal(id: crystalId)
            }
        }
    }

    private func expireCrystal(id: Int) {
        guard phase == .playingSulfur else { return }
        guard let idx = sulfurCrystals.firstIndex(where: { $0.id == id && $0.state == .visible }) else { return }

        withAnimation {
            sulfurCrystals[idx].state = .expired
        }

        sulfurMissed += 1

        if sulfurMissed >= sulfurMaxMissed {
            sulfurTimer?.invalidate()
            gasTimer?.invalidate()
            onNudgeCamera?()
            withAnimation { phase = .failed }
        }
    }

    private func handleSulfurTap(id: Int) {
        guard let idx = sulfurCrystals.firstIndex(where: { $0.id == id && $0.state == .visible }) else { return }

        if !isGasClear {
            withAnimation {
                sulfurFeedback = "Can't see through the gas! Wait!"
                sulfurFeedbackColor = Color(red: 0.7, green: 0.75, blue: 0.3)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation { sulfurFeedback = nil }
            }
            return
        }

        // Collected!
        withAnimation(.spring(response: 0.2)) {
            sulfurCrystals[idx].state = .collected
        }
        sulfurCollected += 1

        withAnimation {
            sulfurFeedback = "Sulfur crystal! S₈ ring molecules — burns blue."
            sulfurFeedbackColor = Color(red: 0.85, green: 0.80, blue: 0.15)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation { sulfurFeedback = nil }
        }

        if sulfurCollected >= sulfurNeeded {
            perfectCount = sulfurMissed == 0 ? 3 : (sulfurMissed <= 1 ? 1 : 0)
            sulfurTimer?.invalidate()
            gasTimer?.invalidate()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                onNudgeCamera?()
                withAnimation { phase = .success }
            }
        }
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: - SUCCESS / FAILED
    // ═══════════════════════════════════════════════════════════════

    private var successCard: some View {
        VStack(spacing: 20) {
            HStack(spacing: 12) {
                BirdCharacter()
                    .frame(width: 70, height: 70)

                VStack(alignment: .leading, spacing: 4) {
                    Text(successTitle)
                        .font(.custom("Cinzel-Bold", size: 22))
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                    Text("You collected 1x \(selectedMaterial.rawValue)")
                        .font(RenaissanceFont.dialogSubtitle)
                        .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))
                }
            }

            VStack(spacing: 10) {
                HStack(spacing: 12) {
                    Image(systemName: "flame.fill")
                        .font(.body)
                        .foregroundStyle(RenaissanceColors.furnaceOrange)
                        .frame(width: 32, height: 32)
                        .background(
                            RoundedRectangle(cornerRadius: CornerRadius.sm)
                                .fill(RenaissanceColors.furnaceOrange.opacity(0.1))
                        )

                    Text(successDetail)
                        .font(.custom("EBGaramond-Regular", size: 16))
                        .foregroundStyle(RenaissanceColors.sepiaInk)

                    Spacer()

                    MaterialIconView(material: selectedMaterial, size: 28)
                }
                .padding(Spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(RenaissanceColors.parchment.opacity(0.6))
                        .borderWorkshop(radius: 10)
                )

                if bonusFlorins > 0 {
                    HStack(spacing: 12) {
                        Image(systemName: "star.fill")
                            .font(.body)
                            .foregroundStyle(RenaissanceColors.goldSuccess)
                            .frame(width: 32, height: 32)
                            .background(
                                RoundedRectangle(cornerRadius: CornerRadius.sm)
                                    .fill(RenaissanceColors.goldSuccess.opacity(0.1))
                            )

                        Text("Perfect collection!")
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

            Button {
                SoundManager.shared.play(.materialPickup)
                onComplete(selectedMaterial, bonusFlorins)
            } label: {
                HStack(spacing: 8) {
                    MaterialIconView(material: selectedMaterial, size: 24)
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

    private var successTitle: String {
        switch selectedMaterial {
        case .volcanicAsh: return "Pozzolana Raccolta!"
        case .cinnabar:    return "Cinabro Estratto!"
        case .sulfur:      return "Zolfo Catturato!"
        default:           return "Raccolto!"
        }
    }

    private var successDetail: String {
        switch selectedMaterial {
        case .volcanicAsh:
            return "Raked \(ashCollected) samples with your ash rake, \(ashMisses) mistake\(ashMisses == 1 ? "" : "s")"
        case .cinnabar:
            return "\(crystalsExtracted) crystals chipped with your rake handle, \(crystalsCracked) crack\(crystalsCracked == 1 ? "" : "s")"
        case .sulfur:
            return "Raked \(sulfurCollected) crystals to safety, \(sulfurMissed) lost to gas"
        default:
            return "Collected successfully"
        }
    }

    private var failedCard: some View {
        VStack(spacing: 20) {
            HStack(spacing: 12) {
                BirdCharacter()
                    .frame(width: 70, height: 70)

                VStack(alignment: .leading, spacing: 4) {
                    Text(failTitle)
                        .font(.custom("Cinzel-Bold", size: 22))
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                    Text(failSubtitle)
                        .font(RenaissanceFont.dialogSubtitle)
                        .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))
                }
            }

            Text(failEncouragement)
                .font(.custom("EBGaramond-Regular", size: 16))
                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))

            VStack(spacing: 10) {
                if onAskMasterHelp != nil {
                    Button {
                        SoundManager.shared.play(.tapSoft)
                        onAskMasterHelp?()
                    } label: {
                        failedOptionRow(icon: "hand.raised.fill", text: "Ask the Master for help")
                    }
                }

                Button {
                    switch selectedMaterial {
                    case .volcanicAsh: withAnimation { phase = .introAsh }
                    case .cinnabar:    withAnimation { phase = .introCinnabar }
                    case .sulfur:      withAnimation { phase = .introSulfur }
                    default: break
                    }
                } label: {
                    failedOptionRow(icon: "arrow.counterclockwise", text: "Try Again")
                }

                Button {
                    sulfurTimer?.invalidate()
                    gasTimer?.invalidate()
                    onDismiss()
                } label: {
                    failedOptionRow(icon: "xmark", text: "Leave Volcano")
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

    private var failTitle: String {
        switch selectedMaterial {
        case .volcanicAsh: return "Wrong Material!"
        case .cinnabar:    return "Wall Collapsed!"
        case .sulfur:      return "Crystals Lost!"
        default:           return "Failed!"
        }
    }

    private var failSubtitle: String {
        switch selectedMaterial {
        case .volcanicAsh: return "Too many wrong samples collected."
        case .cinnabar:    return "The rock fractured — crystals destroyed."
        case .sulfur:      return "Too many crystals vanished in the gas."
        default:           return "The volcano won this round."
        }
    }

    private var failEncouragement: String {
        switch selectedMaterial {
        case .volcanicAsh:
            return "True pozzolana is reddish-brown, never grey or yellow. The silica and alumina content gives it that distinctive warm color. Roman builders could identify it by sight — and so can you."
        case .cinnabar:
            return "Cinnabar veins glow red against grey rock — like veins of blood in stone. Roman miners used bronze picks, never iron, because a spark near mercury vapor could be lethal. Gentle hands, sharp eyes."
        case .sulfur:
            return "Sicilian sulfur miners tied wet cloth over their mouths and counted between gas bursts. Three breaths clear, then run. The rhythm of the fumarole is the rhythm of survival."
        default:
            return "The volcano is patient. Try again."
        }
    }

    private func failedOptionRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(RenaissanceColors.sepiaInk)
                .frame(width: 32, height: 32)
                .background(
                    RoundedRectangle(cornerRadius: CornerRadius.sm)
                        .fill(RenaissanceColors.warmBrown.opacity(0.1))
                )

            Text(text)
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

// ═══════════════════════════════════════════════════════════════
// MARK: - Supporting Models
// ═══════════════════════════════════════════════════════════════

struct AshSample: Identifiable {
    let id: Int
    let label: String
    let icon: String
    let color: Color
    let isPozzolana: Bool
    let scienceFact: String
    var tapped: Bool
}

enum CrystalState {
    case intact
    case extracted
    case cracked
}

struct CrystalNode: Identifiable {
    let id: Int
    let isCrystal: Bool
    var tapsRemaining: Int
    var state: CrystalState

    var displayColor: Color {
        switch state {
        case .extracted:
            return Color(red: 0.15, green: 0.12, blue: 0.10)
        case .cracked:
            return Color(red: 0.20, green: 0.15, blue: 0.12)
        case .intact:
            if isCrystal {
                return Color(red: 0.40, green: 0.15, blue: 0.12)
            } else {
                // Random grey rock tones
                let g = Double.random(in: 0.22...0.30)
                return Color(red: g + 0.02, green: g, blue: g - 0.02)
            }
        }
    }
}

enum SulfurCrystalState {
    case visible
    case collected
    case expired
}

struct SulfurCrystal: Identifiable {
    let id: Int
    let normalizedX: CGFloat
    let normalizedY: CGFloat
    var state: SulfurCrystalState
}
