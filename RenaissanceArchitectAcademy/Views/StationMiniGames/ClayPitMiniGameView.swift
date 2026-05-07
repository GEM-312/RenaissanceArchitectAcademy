import SwiftUI

/// Clay Pit "La Fossa d'Argilla" — THREE distinct mini-games based on real clay extraction:
/// 1. Digging "Lo Scavo" (Easy) — Tap through geological soil layers to reach clay deposits
/// 2. Kneading "L'Impasto" (Medium) — Follow press/fold/turn sequences to remove air bubbles
/// 3. Washing "La Levigazione" (Hard) — Tap pure clay in settling basin, avoid debris and stones
struct ClayPitMiniGameView: View {

    let onComplete: (Material, Int) -> Void
    let onDismiss: () -> Void
    var onNudgeCamera: (() -> Void)? = nil
    /// Optional — if set, adds "Ask the Master for help" button to the fail card.
    /// Parent is responsible for showing the NPC helper overlay and awarding the material.
    var onAskMasterHelp: (() -> Void)? = nil

    // MARK: - Phases

    enum Phase: Equatable {
        case choose
        case introDig
        case introKnead
        case introWash
        case playingDig
        case playingKnead
        case playingWash
        case success
        case failed
    }

    @State private var phase: Phase = .choose
    @State private var selectedGame: ClayGame = .digging

    // ── Digging state ──
    @State private var digLayers: [DigLayer] = []
    @State private var currentLayerIndex: Int = 0
    @State private var digTapsOnLayer: Int = 0
    @State private var digProgress: CGFloat = 0    // 0...1 overall
    @State private var digHitRock: Bool = false
    @State private var digRockHits: Int = 0
    @State private var digFeedback: String?
    @State private var digFeedbackColor: Color = .white

    private let maxRockHits = 3

    // ── Kneading state ──
    @State private var kneadSequence: [KneadAction] = []
    @State private var kneadPlayerSequence: [KneadAction] = []
    @State private var kneadRound: Int = 0
    @State private var kneadShowingPattern: Bool = false
    @State private var kneadHighlightAction: KneadAction?
    @State private var kneadMisses: Int = 0
    @State private var kneadPerfect: Int = 0
    @State private var kneadFeedback: String?
    @State private var kneadFeedbackColor: Color = .white
    @State private var airBubbles: CGFloat = 1.0   // 1.0 = full of air, 0 = pure clay

    private let kneadTotalRounds = 5
    private let kneadMaxMisses = 3

    // ── Washing state ──
    @State private var washItems: [WashItem] = []
    @State private var washCollected: Int = 0
    @State private var washMisses: Int = 0
    @State private var washTimer: Timer?
    @State private var washFeedback: String?
    @State private var washFeedbackColor: Color = .white

    private let washNeeded = 6
    private let washMaxMisses = 3
    private let washGridCols = 4
    private let washGridRows = 3

    // ── Shared ──
    @State private var perfectCount: Int = 0

    private var bonusFlorins: Int { perfectCount * 2 }

    // MARK: - Body

    var body: some View {
        ZStack {
            if phase == .playingDig || phase == .playingKnead || phase == .playingWash {
                RenaissanceColors.overlayDimming
                    .ignoresSafeArea()

                Group {
                    switch phase {
                    case .playingDig:   digGameView
                    case .playingKnead: kneadGameView
                    case .playingWash:  washGameView
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
                        case .choose:     choiceCard
                        case .introDig:   introDigCard
                        case .introKnead: introKneadCard
                        case .introWash:  introWashCard
                        case .success:    successCard
                        case .failed:     failedCard
                        default:          EmptyView()
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
                    Text("La Fossa d'Argilla")
                        .font(RenaissanceFont.title)
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                    Text("Three steps to perfect clay — dig, knead, wash.")
                        .font(RenaissanceFont.body)
                        .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))
                }
                Spacer()
            }

            VStack(spacing: 12) {
                gameOptionRow(
                    game: .digging,
                    difficulty: "Easy",
                    description: "Dig through soil layers to reach the clay deposit"
                )
                gameOptionRow(
                    game: .kneading,
                    difficulty: "Medium",
                    description: "Knead the clay — press, fold, turn to remove air bubbles"
                )
                gameOptionRow(
                    game: .washing,
                    difficulty: "Hard",
                    description: "Wash raw clay in a settling basin — separate pure clay from debris"
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

    private func gameOptionRow(game: ClayGame, difficulty: String, description: String) -> some View {
        Button {
            selectedGame = game
            withAnimation {
                switch game {
                case .digging:  phase = .introDig
                case .kneading: phase = .introKnead
                case .washing:  phase = .introWash
                }
            }
        } label: {
            HStack(spacing: 14) {
                Image(systemName: game.icon)
                    .font(.title2)
                    .foregroundStyle(RenaissanceColors.terracotta)
                    .frame(width: 44, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: CornerRadius.sm)
                            .fill(RenaissanceColors.terracotta.opacity(0.1))
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(game.displayName)
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
    // MARK: - 1. DIGGING GAME — "Lo Scavo"
    // ═══════════════════════════════════════════════════════════════

    private var introDigCard: some View {
        MiniGameIntroCard(
            icon: "shovel.fill",
            iconColor: RenaissanceColors.terracotta,
            title: "Lo Scavo",
            subtitle: "Dig to the Clay",
            bodyText: "Dig with your shovel through each layer. Beneath every Roman building site lies clay — but you have to dig for it. The earth is layered: topsoil, then gravel, then sand, then finally the clay deposit. Each layer tells a geological story millions of years old. Dig carefully — hit too many rocks and your shovel breaks.",
            buttonLabel: "Begin Digging",
            buttonColor: RenaissanceColors.terracotta,
            startAction: { startDigGame() },
            backAction: { withAnimation { phase = .choose } }
        ) {
            VStack(spacing: 10) {
                MiniGameRuleRow(icon: "hand.tap.fill", text: "Tap each soil layer to dig through it", color: RenaissanceColors.terracotta)
                MiniGameRuleRow(icon: "mountain.2.fill", text: "Avoid hidden rocks — \(maxRockHits) strikes and your shovel breaks", color: RenaissanceColors.errorRed)
                MiniGameRuleRow(icon: "star.fill", text: "Clean digs (no rocks) = bonus florins", color: RenaissanceColors.goldSuccess)
            }
        }
    }

    private var digGameView: some View {
        GeometryReader { geo in
            let layerHeight = min((geo.size.height - 200) / CGFloat(digLayers.count), 90)

            ZStack {
                // Background — earth cross-section
                RoundedRectangle(cornerRadius: CornerRadius.lg)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.30, green: 0.25, blue: 0.18),
                                Color(red: 0.25, green: 0.18, blue: 0.12),
                                Color(red: 0.20, green: 0.14, blue: 0.08)
                            ],
                            startPoint: .top, endPoint: .bottom
                        )
                    )

                VStack(spacing: 0) {
                    // HUD
                    HStack {
                        Text("Depth: \(Int(digProgress * 100))%")
                            .font(RenaissanceFont.footnote)
                            .foregroundStyle(.white.opacity(0.8))

                        Spacer()

                        HStack(spacing: 4) {
                            Text("\u{1FA8F}")
                            Text("Lo Scavo")
                                .font(RenaissanceFont.visualTitle)
                                .foregroundStyle(.white)
                        }

                        Spacer()

                        HStack(spacing: 4) {
                            Image(systemName: "wrench.fill")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.6))
                            ForEach(0..<maxRockHits, id: \.self) { i in
                                Image(systemName: i < digRockHits ? "xmark.circle.fill" : "xmark.circle")
                                    .font(.caption)
                                    .foregroundStyle(i < digRockHits ? RenaissanceColors.errorRed : .white.opacity(0.3))
                            }
                        }
                    }
                    .padding(.horizontal, Spacing.lg)
                    .padding(.vertical, Spacing.sm)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.black.opacity(0.3)))
                    .padding(.horizontal, Spacing.md)
                    .padding(.top, Spacing.md)

                    // Feedback
                    if let fb = digFeedback {
                        Text(fb)
                            .font(.custom("EBGaramond-SemiBold", size: 16))
                            .foregroundStyle(digFeedbackColor)
                            .padding(.top, Spacing.sm)
                            .transition(.opacity)
                    }

                    Spacer()

                    // Soil layers — stack from top (surface) to bottom (clay)
                    VStack(spacing: 4) {
                        ForEach(Array(digLayers.enumerated()), id: \.element.id) { index, layer in
                            digLayerView(layer: layer, index: index, height: layerHeight, width: geo.size.width - 60)
                        }
                    }
                    .padding(.horizontal, Spacing.lg)

                    Spacer()

                    Text("Dig with your shovel! \u{1FA8F}")
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

    private func digLayerView(layer: DigLayer, index: Int, height: CGFloat, width: CGFloat) -> some View {
        let isCurrent = index == currentLayerIndex
        let isDug = layer.isDug
        let isLocked = index > currentLayerIndex

        return Button {
            guard isCurrent && !isDug else { return }
            handleDigTap(index: index)
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        isDug
                            ? Color.black.opacity(0.3)
                            : layer.color
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(
                                isCurrent ? RenaissanceColors.goldSuccess.opacity(0.8) :
                                Color.white.opacity(isDug ? 0.05 : 0.15),
                                lineWidth: isCurrent ? 2 : 1
                            )
                    )

                if isDug {
                    // Dug through — show checkmark
                    HStack {
                        Image(systemName: "checkmark")
                            .foregroundStyle(RenaissanceColors.sageGreen)
                        Text(layer.name)
                            .font(RenaissanceFont.caption)
                            .foregroundStyle(.white.opacity(0.4))
                        if !layer.scienceFact.isEmpty {
                            Spacer()
                            Text(layer.scienceFact)
                                .font(.custom("EBGaramond-Italic", size: 11))
                                .foregroundStyle(.white.opacity(0.3))
                                .lineLimit(1)
                        }
                    }
                    .padding(.horizontal, Spacing.sm)
                } else if isLocked {
                    // Can't dig yet — show locked layer
                    HStack {
                        Text(layer.icon)
                            .font(.title3)
                        Text(layer.name)
                            .font(RenaissanceFont.bodySmall)
                            .foregroundStyle(.white.opacity(0.5))
                        Spacer()
                        if layer.hasRock {
                            Text("🪨")
                                .font(.caption)
                                .opacity(0.3)
                        }
                    }
                    .padding(.horizontal, Spacing.sm)
                } else {
                    // Current layer — tappable
                    HStack {
                        Text(layer.icon)
                            .font(.title2)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(layer.name)
                                .font(RenaissanceFont.buttonSmall)
                                .foregroundStyle(.white)
                            Text("Tap \(layer.tapsRequired - digTapsOnLayer) more time\(layer.tapsRequired - digTapsOnLayer == 1 ? "" : "s")")
                                .font(RenaissanceFont.footnoteSmall)
                                .foregroundStyle(.white.opacity(0.6))
                        }

                        Spacer()

                        // Progress dots
                        HStack(spacing: 4) {
                            ForEach(0..<layer.tapsRequired, id: \.self) { i in
                                Circle()
                                    .fill(i < digTapsOnLayer ? RenaissanceColors.goldSuccess : Color.white.opacity(0.3))
                                    .frame(width: 10, height: 10)
                            }
                        }
                    }
                    .padding(.horizontal, Spacing.sm)
                }
            }
            .frame(height: height)
            .frame(maxWidth: width)
        }
        .buttonStyle(.plain)
        .disabled(!isCurrent || isDug)
        .opacity(isDug ? 0.5 : 1)
    }

    // Dig Logic

    private func startDigGame() {
        digLayers = [
            DigLayer(id: 0, name: "Topsoil",  icon: "🌱", color: Color(red: 0.35, green: 0.30, blue: 0.18), tapsRequired: 2, hasRock: false, scienceFact: "Organic humus layer"),
            DigLayer(id: 1, name: "Gravel",    icon: "🪨", color: Color(red: 0.50, green: 0.45, blue: 0.38), tapsRequired: 3, hasRock: true,  scienceFact: "Alluvial deposits"),
            DigLayer(id: 2, name: "Sandy Silt", icon: "🏜️", color: Color(red: 0.60, green: 0.52, blue: 0.40), tapsRequired: 3, hasRock: Bool.random(), scienceFact: "Fine-grained sediment"),
            DigLayer(id: 3, name: "Dense Subsoil", icon: "⛏️", color: Color(red: 0.45, green: 0.35, blue: 0.25), tapsRequired: 4, hasRock: true, scienceFact: "Compressed mineral layer"),
            DigLayer(id: 4, name: "Clay Deposit!", icon: "🟤", color: Color(red: 0.65, green: 0.40, blue: 0.25), tapsRequired: 2, hasRock: false, scienceFact: "Kaolinite + illite minerals"),
        ]
        currentLayerIndex = 0
        digTapsOnLayer = 0
        digProgress = 0
        digRockHits = 0
        digHitRock = false
        digFeedback = nil
        perfectCount = 0
        withAnimation { phase = .playingDig }
    }

    private func handleDigTap(index: Int) {
        guard index == currentLayerIndex, index < digLayers.count else { return }
        let layer = digLayers[index]

        digTapsOnLayer += 1

        // Rock check: random chance on rock layers (not every tap)
        if layer.hasRock && !digHitRock && digTapsOnLayer == 2 {
            digHitRock = true
            digRockHits += 1
            withAnimation {
                digFeedback = "Hit a rock! \u{1FA8F} Shovel damaged."
                digFeedbackColor = RenaissanceColors.errorRed
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation { digFeedback = nil }
            }

            if digRockHits >= maxRockHits {
                onNudgeCamera?()
                withAnimation { phase = .failed }
                return
            }
        }

        // Check if layer is fully dug
        if digTapsOnLayer >= layer.tapsRequired {
            withAnimation(.easeInOut(duration: 0.3)) {
                digLayers[index].isDug = true
                digProgress = CGFloat(index + 1) / CGFloat(digLayers.count)
            }

            // Science feedback
            withAnimation {
                digFeedback = "\(layer.name) cleared — \(layer.scienceFact)"
                digFeedbackColor = RenaissanceColors.sageGreen
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation { digFeedback = nil }
            }

            // Last layer = clay found!
            if index == digLayers.count - 1 {
                perfectCount = digRockHits == 0 ? 3 : 0
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    onNudgeCamera?()
                    withAnimation { phase = .success }
                }
                return
            }

            // Advance
            currentLayerIndex = index + 1
            digTapsOnLayer = 0
            digHitRock = false
        }
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: - 2. KNEADING GAME — "L'Impasto"
    // ═══════════════════════════════════════════════════════════════

    private var introKneadCard: some View {
        MiniGameIntroCard(
            icon: "hands.sparkles.fill",
            iconColor: RenaissanceColors.terracotta,
            title: "L'Impasto",
            subtitle: "Knead the Clay",
            bodyText: "Set down your shovel — this requires bare hands. Raw clay is full of trapped air. Every bubble is a weak point — when fired, the air expands and cracks the piece. Roman potters kneaded clay for hours: press to flatten, fold to trap layers, turn to work evenly. The Japanese call it 'wedging' — chrysanthemum kneading, because the folds look like petals.",
            buttonLabel: "Begin Kneading",
            buttonColor: RenaissanceColors.ochre,
            startAction: { startKneadGame() },
            backAction: { withAnimation { phase = .choose } }
        ) {
            VStack(spacing: 10) {
                MiniGameRuleRow(icon: "hand.point.down.fill", text: "Watch the pattern, then repeat: Press, Fold, Turn", color: RenaissanceColors.terracotta)
                MiniGameRuleRow(icon: "bubble.left.fill", text: "Each round removes air bubbles from the clay", color: RenaissanceColors.ochre)
                MiniGameRuleRow(icon: "xmark.circle", text: "\(kneadMaxMisses) wrong moves and the clay dries out", color: RenaissanceColors.errorRed)
            }
        }
    }

    private var kneadGameView: some View {
        GeometryReader { geo in
            ZStack {
                RoundedRectangle(cornerRadius: CornerRadius.lg)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.38, green: 0.28, blue: 0.18),
                                Color(red: 0.30, green: 0.20, blue: 0.12)
                            ],
                            startPoint: .top, endPoint: .bottom
                        )
                    )

                VStack(spacing: Spacing.md) {
                    // HUD
                    HStack {
                        HStack(spacing: 6) {
                            Text("Round \(kneadRound + 1)/\(kneadTotalRounds)")
                                .font(RenaissanceFont.footnote)
                                .foregroundStyle(.white.opacity(0.8))
                        }

                        Spacer()

                        HStack(spacing: 4) {
                            Text("\u{1FA8F}")
                            Text("L'Impasto")
                                .font(RenaissanceFont.visualTitle)
                                .foregroundStyle(.white)
                        }

                        Spacer()

                        HStack(spacing: 4) {
                            ForEach(0..<kneadMaxMisses, id: \.self) { i in
                                Image(systemName: i < kneadMisses ? "xmark.circle.fill" : "xmark.circle")
                                    .font(.caption)
                                    .foregroundStyle(i < kneadMisses ? RenaissanceColors.errorRed : .white.opacity(0.3))
                            }
                        }
                    }
                    .padding(.horizontal, Spacing.lg)
                    .padding(.vertical, Spacing.sm)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.black.opacity(0.3)))
                    .padding(.horizontal, Spacing.md)
                    .padding(.top, Spacing.md)

                    // Feedback
                    if let fb = kneadFeedback {
                        Text(fb)
                            .font(.custom("EBGaramond-SemiBold", size: 16))
                            .foregroundStyle(kneadFeedbackColor)
                            .transition(.opacity)
                    }

                    Spacer()

                    // Clay blob with air bubbles visualization
                    ZStack {
                        // Clay mass
                        Ellipse()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color(red: 0.72, green: 0.45, blue: 0.30),
                                        Color(red: 0.58, green: 0.36, blue: 0.22)
                                    ],
                                    center: .center,
                                    startRadius: 10,
                                    endRadius: 80
                                )
                            )
                            .frame(width: 180, height: 120)
                            .overlay(
                                Ellipse()
                                    .strokeBorder(Color(red: 0.48, green: 0.30, blue: 0.18), lineWidth: 2)
                            )

                        // Air bubbles (fade out as you knead)
                        ForEach(0..<8, id: \.self) { i in
                            Circle()
                                .fill(Color.white.opacity(0.2 * Double(airBubbles)))
                                .frame(width: CGFloat(6 + i % 4 * 3), height: CGFloat(6 + i % 4 * 3))
                                .offset(
                                    x: CGFloat([-50, 30, -20, 55, -40, 15, 45, -10][i]),
                                    y: CGFloat([-25, 10, 30, -15, 5, -35, 20, -5][i])
                                )
                        }

                        // Air bubble percentage
                        Text("Air: \(Int(airBubbles * 100))%")
                            .font(RenaissanceFont.footnoteBold)
                            .foregroundStyle(.white.opacity(0.6))
                            .offset(y: 75)
                    }

                    // Pattern display or status
                    if kneadShowingPattern {
                        Text("Watch the pattern...")
                            .font(RenaissanceFont.bodyItalic)
                            .foregroundStyle(RenaissanceColors.goldSuccess)
                    } else {
                        Text("Your turn — repeat the sequence!")
                            .font(.custom("EBGaramond-Italic", size: 14))
                            .foregroundStyle(.white.opacity(0.5))
                    }

                    Spacer()

                    // Action buttons — Press / Fold / Turn
                    HStack(spacing: 16) {
                        kneadActionButton(.press)
                        kneadActionButton(.fold)
                        kneadActionButton(.turn)
                    }
                    .padding(.horizontal, Spacing.lg)
                    .padding(.bottom, Spacing.xl)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
            .borderWorkshop()
            .padding(Spacing.xl)
        }
    }

    private func kneadActionButton(_ action: KneadAction) -> some View {
        let isHighlighted = kneadHighlightAction == action

        return Button {
            guard !kneadShowingPattern else { return }
            handleKneadTap(action)
        } label: {
            VStack(spacing: 6) {
                Image(systemName: action.icon)
                    .font(.system(size: 28))
                    .foregroundStyle(
                        isHighlighted ? .white : .white.opacity(0.7)
                    )

                Text(action.displayName)
                    .font(.custom("EBGaramond-SemiBold", size: 13))
                    .foregroundStyle(
                        isHighlighted ? .white : .white.opacity(0.6)
                    )
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        isHighlighted
                            ? action.color.opacity(0.8)
                            : action.color.opacity(0.3)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(
                                isHighlighted ? .white.opacity(0.6) : .white.opacity(0.15),
                                lineWidth: isHighlighted ? 2 : 1
                            )
                    )
            )
            .scaleEffect(isHighlighted ? 1.08 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: isHighlighted)
        }
        .buttonStyle(.plain)
        .disabled(kneadShowingPattern)
    }

    // Knead Logic

    private func startKneadGame() {
        kneadRound = 0
        kneadMisses = 0
        kneadPerfect = 0
        kneadFeedback = nil
        kneadHighlightAction = nil
        airBubbles = 1.0
        perfectCount = 0
        kneadSequence = []
        kneadPlayerSequence = []

        withAnimation { phase = .playingKnead }

        // Start first round after short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            addRoundAndShowPattern()
        }
    }

    private func addRoundAndShowPattern() {
        // Add a new action to the sequence
        let actions: [KneadAction] = [.press, .fold, .turn]
        kneadSequence.append(actions.randomElement()!)
        kneadPlayerSequence = []
        kneadShowingPattern = true

        // Show each action in sequence
        for (i, action) in kneadSequence.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.7) {
                withAnimation { kneadHighlightAction = action }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.7 + 0.4) {
                withAnimation { kneadHighlightAction = nil }
            }
        }

        // After pattern shown, enable input
        let totalTime = Double(kneadSequence.count) * 0.7 + 0.3
        DispatchQueue.main.asyncAfter(deadline: .now() + totalTime) {
            kneadShowingPattern = false
        }
    }

    private func handleKneadTap(_ action: KneadAction) {
        let expectedIndex = kneadPlayerSequence.count
        guard expectedIndex < kneadSequence.count else { return }

        // Flash the button
        withAnimation { kneadHighlightAction = action }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation { kneadHighlightAction = nil }
        }

        if action == kneadSequence[expectedIndex] {
            // Correct!
            kneadPlayerSequence.append(action)

            if kneadPlayerSequence.count == kneadSequence.count {
                // Round complete!
                kneadRound += 1
                kneadPerfect += 1

                withAnimation(.easeInOut(duration: 0.4)) {
                    airBubbles = max(0, 1.0 - CGFloat(kneadRound) / CGFloat(kneadTotalRounds))
                }

                withAnimation {
                    kneadFeedback = "Round \(kneadRound) complete! Air bubbles reducing..."
                    kneadFeedbackColor = RenaissanceColors.sageGreen
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    withAnimation { kneadFeedback = nil }
                }

                if kneadRound >= kneadTotalRounds {
                    // Win!
                    perfectCount = kneadMisses == 0 ? kneadPerfect : kneadPerfect / 2
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        onNudgeCamera?()
                        withAnimation { phase = .success }
                    }
                    return
                }

                // Next round
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    addRoundAndShowPattern()
                }
            }
        } else {
            // Wrong!
            kneadMisses += 1
            kneadPlayerSequence = []  // Reset this round

            withAnimation {
                kneadFeedback = "Wrong move! Watch the pattern again."
                kneadFeedbackColor = RenaissanceColors.errorRed
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation { kneadFeedback = nil }
            }

            if kneadMisses >= kneadMaxMisses {
                onNudgeCamera?()
                withAnimation { phase = .failed }
                return
            }

            // Re-show the current pattern
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                kneadPlayerSequence = []
                kneadShowingPattern = true

                for (i, act) in kneadSequence.enumerated() {
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.7) {
                        withAnimation { kneadHighlightAction = act }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.7 + 0.4) {
                        withAnimation { kneadHighlightAction = nil }
                    }
                }

                let totalTime = Double(kneadSequence.count) * 0.7 + 0.3
                DispatchQueue.main.asyncAfter(deadline: .now() + totalTime) {
                    kneadShowingPattern = false
                }
            }
        }
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: - 3. WASHING GAME — "La Levigazione"
    // ═══════════════════════════════════════════════════════════════

    private var introWashCard: some View {
        MiniGameIntroCard(
            icon: "drop.triangle.fill",
            iconColor: RenaissanceColors.terracotta,
            title: "La Levigazione",
            subtitle: "Wash the Clay",
            bodyText: "Scoop pure clay from the basin with your shovel. Levigation — the Roman technique for purifying clay. Raw earth is mixed with water in a settling basin. Heavy stones and gravel sink fast. Organic debris floats. Pure clay particles suspended in between — the finest, smoothest material for pottery.",
            buttonLabel: "Begin Washing",
            buttonColor: Color(red: 0.4, green: 0.55, blue: 0.65),
            startAction: { startWashGame() },
            backAction: { withAnimation { phase = .choose } }
        ) {
            VStack(spacing: 10) {
                MiniGameRuleRow(icon: "hand.tap.fill", text: "Tap clay chunks (brown) to collect them", color: RenaissanceColors.terracotta)
                MiniGameRuleRow(icon: "xmark.circle", text: "Don't tap stones or debris — \(washMaxMisses) mistakes allowed", color: RenaissanceColors.errorRed)
                MiniGameRuleRow(icon: "drop.fill", text: "Items sink and shift — be quick!", color: RenaissanceColors.renaissanceBlue)
            }
        }
    }

    private var washGameView: some View {
        GeometryReader { geo in
            let cellSize = min((geo.size.width - 100) / CGFloat(washGridCols), 80)

            ZStack {
                // Background — murky water basin
                RoundedRectangle(cornerRadius: CornerRadius.lg)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.30, green: 0.40, blue: 0.45),
                                Color(red: 0.22, green: 0.32, blue: 0.38),
                                Color(red: 0.18, green: 0.25, blue: 0.30)
                            ],
                            startPoint: .top, endPoint: .bottom
                        )
                    )

                // Water ripple circles (decorative)
                ForEach(0..<5, id: \.self) { i in
                    Circle()
                        .strokeBorder(Color.white.opacity(0.04), lineWidth: 1)
                        .frame(width: CGFloat(80 + i * 60), height: CGFloat(80 + i * 60))
                        .offset(
                            x: CGFloat([-30, 50, -20, 40, 0][i]),
                            y: CGFloat([60, -40, 100, 20, -80][i])
                        )
                }

                VStack(spacing: Spacing.md) {
                    // HUD
                    HStack {
                        HStack(spacing: 6) {
                            ForEach(0..<washNeeded, id: \.self) { i in
                                Circle()
                                    .fill(i < washCollected ? RenaissanceColors.goldSuccess : Color.white.opacity(0.2))
                                    .frame(width: 10, height: 10)
                            }
                            Text("\(washCollected)/\(washNeeded)")
                                .font(RenaissanceFont.caption)
                                .foregroundStyle(.white.opacity(0.7))
                        }

                        Spacer()

                        HStack(spacing: 4) {
                            Text("\u{1FA8F}")
                            Text("La Levigazione")
                                .font(RenaissanceFont.visualTitle)
                                .foregroundStyle(.white)
                        }

                        Spacer()

                        HStack(spacing: 4) {
                            ForEach(0..<washMaxMisses, id: \.self) { i in
                                Image(systemName: i < washMisses ? "xmark.circle.fill" : "xmark.circle")
                                    .font(.caption)
                                    .foregroundStyle(i < washMisses ? RenaissanceColors.errorRed : .white.opacity(0.3))
                            }
                        }
                    }
                    .padding(.horizontal, Spacing.lg)
                    .padding(.vertical, Spacing.sm)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.black.opacity(0.3)))
                    .padding(.horizontal, Spacing.md)
                    .padding(.top, Spacing.md)

                    if let fb = washFeedback {
                        Text(fb)
                            .font(.custom("EBGaramond-SemiBold", size: 16))
                            .foregroundStyle(washFeedbackColor)
                            .transition(.opacity)
                    }

                    Spacer()

                    // Settling basin grid
                    VStack(spacing: 8) {
                        ForEach(0..<washGridRows, id: \.self) { row in
                            HStack(spacing: 8) {
                                ForEach(0..<washGridCols, id: \.self) { col in
                                    let index = row * washGridCols + col
                                    if index < washItems.count {
                                        washItemButton(item: washItems[index], index: index, cellSize: cellSize)
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

                    Text("Scoop clay with your shovel \u{1FA8F}")
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

    private func washItemButton(item: WashItem, index: Int, cellSize: CGFloat) -> some View {
        Button {
            handleWashTap(index: index)
        } label: {
            ZStack {
                // Water cell background
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        item.tapped
                            ? (item.isClay
                               ? RenaissanceColors.sageGreen.opacity(0.3)
                               : RenaissanceColors.errorRed.opacity(0.3))
                            : Color(red: 0.28, green: 0.38, blue: 0.44).opacity(0.6)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(
                                item.tapped
                                    ? (item.isClay ? RenaissanceColors.sageGreen : RenaissanceColors.errorRed)
                                    : Color.white.opacity(0.1),
                                lineWidth: 1.5
                            )
                    )

                if item.tapped {
                    Image(systemName: item.isClay ? "checkmark" : "xmark")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(item.isClay ? RenaissanceColors.sageGreen : RenaissanceColors.errorRed)
                } else {
                    Text(item.icon)
                        .font(.system(size: cellSize * 0.4))
                }
            }
            .frame(width: cellSize, height: cellSize)
        }
        .buttonStyle(.plain)
        .disabled(item.tapped)
    }

    // Wash Logic

    private func startWashGame() {
        washCollected = 0
        washMisses = 0
        washFeedback = nil
        perfectCount = 0
        washTimer?.invalidate()
        generateWashGrid()
        withAnimation { phase = .playingWash }

        // Periodically reshuffle remaining items to simulate settling
        washTimer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { _ in
            guard phase == .playingWash else {
                washTimer?.invalidate()
                return
            }
            reshuffleWashItems()
        }
    }

    private func generateWashGrid() {
        let totalCells = washGridRows * washGridCols
        let clayCount = washNeeded + 1
        let debrisCount = totalCells - clayCount

        var items: [WashItem] = []

        // Clay chunks — brown earthy icons
        let clayIcons = ["🟤", "🫘", "🥜", "🍂"]
        for i in 0..<clayCount {
            items.append(WashItem(
                id: i,
                icon: clayIcons[i % clayIcons.count],
                isClay: true,
                tapped: false
            ))
        }

        // Debris — stones, twigs, shells
        let debrisIcons = ["🪨", "🪵", "🐚", "🌿", "🦴"]
        for i in 0..<debrisCount {
            items.append(WashItem(
                id: clayCount + i,
                icon: debrisIcons[i % debrisIcons.count],
                isClay: false,
                tapped: false
            ))
        }

        washItems = items.shuffled()
    }

    private func reshuffleWashItems() {
        // Only shuffle untapped items — keep tapped in place
        var tapped: [(Int, WashItem)] = []
        var untapped: [WashItem] = []

        for (i, item) in washItems.enumerated() {
            if item.tapped {
                tapped.append((i, item))
            } else {
                untapped.append(item)
            }
        }

        untapped.shuffle()

        var newItems = Array(repeating: WashItem(id: -1, icon: "", isClay: false, tapped: false), count: washItems.count)
        for (i, item) in tapped {
            newItems[i] = item
        }

        var untappedIdx = 0
        for i in 0..<newItems.count {
            if newItems[i].id == -1 {
                newItems[i] = untapped[untappedIdx]
                untappedIdx += 1
            }
        }

        withAnimation(.easeInOut(duration: 0.3)) {
            washItems = newItems
        }
    }

    private func handleWashTap(index: Int) {
        guard index < washItems.count, !washItems[index].tapped else { return }

        washItems[index].tapped = true
        let item = washItems[index]

        if item.isClay {
            washCollected += 1
            withAnimation {
                washFeedback = "Pure clay! Fine kaolinite particles."
                washFeedbackColor = RenaissanceColors.sageGreen
            }

            if washCollected >= washNeeded {
                washTimer?.invalidate()
                perfectCount = washMisses == 0 ? 3 : (washMisses == 1 ? 1 : 0)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    onNudgeCamera?()
                    withAnimation { phase = .success }
                }
                return
            }
        } else {
            washMisses += 1
            withAnimation {
                washFeedback = "That's debris! Let it settle."
                washFeedbackColor = RenaissanceColors.errorRed
            }

            if washMisses >= washMaxMisses {
                washTimer?.invalidate()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    onNudgeCamera?()
                    withAnimation { phase = .failed }
                }
                return
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation { washFeedback = nil }
        }

        // Refill if running out of untapped clay
        let untappedClay = washItems.filter { !$0.tapped && $0.isClay }
        if untappedClay.isEmpty && washCollected < washNeeded {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                generateWashGrid()
            }
        }
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: - SUCCESS / FAILED CARDS
    // ═══════════════════════════════════════════════════════════════

    private var successCard: some View {
        VStack(spacing: 20) {
            HStack(spacing: 12) {
                BirdCharacter()
                    .frame(width: 70, height: 70)

                VStack(alignment: .leading, spacing: 4) {
                    Text(selectedGame.successTitle)
                        .font(RenaissanceFont.title2Bold)
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                    Text("You collected 1x Clay")
                        .font(RenaissanceFont.dialogSubtitle)
                        .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))
                }
            }

            VStack(spacing: 10) {
                HStack(spacing: 12) {
                    Image(systemName: selectedGame.icon)
                        .font(.body)
                        .foregroundStyle(RenaissanceColors.terracotta)
                        .frame(width: 32, height: 32)
                        .background(
                            RoundedRectangle(cornerRadius: CornerRadius.sm)
                                .fill(RenaissanceColors.terracotta.opacity(0.1))
                        )

                    Text(successDetail)
                        .font(RenaissanceFont.bodyMedium)
                        .foregroundStyle(RenaissanceColors.sepiaInk)

                    Spacer()

                    MaterialIconView(material: .clay, size: 28)
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

                        Text(selectedGame.bonusText)
                            .font(RenaissanceFont.bodyMedium)
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
                SoundManager.shared.play(.clayDig)
                onComplete(.clay, bonusFlorins)
            } label: {
                HStack(spacing: 8) {
                    MaterialIconView(material: .clay, size: 24)
                    Text("Collect Clay")
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

    private var successDetail: String {
        switch selectedGame {
        case .digging:
            return "Shoveled through \(digLayers.count) layers, \(digRockHits) rock\(digRockHits == 1 ? "" : "s") hit"
        case .kneading:
            return "\(kneadTotalRounds) rounds, \(kneadMisses) mistake\(kneadMisses == 1 ? "" : "s")"
        case .washing:
            return "Scooped \(washCollected) clay with your shovel, \(washMisses) miss\(washMisses == 1 ? "" : "es")"
        }
    }

    private var failedCard: some View {
        VStack(spacing: 20) {
            HStack(spacing: 12) {
                BirdCharacter()
                    .frame(width: 70, height: 70)

                VStack(alignment: .leading, spacing: 4) {
                    Text(selectedGame.failTitle)
                        .font(RenaissanceFont.title2Bold)
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                    Text(selectedGame.failSubtitle)
                        .font(RenaissanceFont.dialogSubtitle)
                        .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))
                }
            }

            Text(selectedGame.failEncouragement)
                .font(RenaissanceFont.bodyMedium)
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
                    switch selectedGame {
                    case .digging:  withAnimation { phase = .introDig }
                    case .kneading: withAnimation { phase = .introKnead }
                    case .washing:  withAnimation { phase = .introWash }
                    }
                } label: {
                    failedOptionRow(icon: "arrow.counterclockwise", text: "Try Again")
                }

                Button {
                    washTimer?.invalidate()
                    onDismiss()
                } label: {
                    failedOptionRow(icon: "xmark", text: "Leave Clay Pit")
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
                .font(RenaissanceFont.bodyMedium)
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

enum ClayGame {
    case digging
    case kneading
    case washing

    var displayName: String {
        switch self {
        case .digging:  return "Lo Scavo"
        case .kneading: return "L'Impasto"
        case .washing:  return "La Levigazione"
        }
    }

    var icon: String {
        switch self {
        case .digging:  return "shovel.fill"
        case .kneading: return "hands.sparkles.fill"
        case .washing:  return "drop.triangle.fill"
        }
    }

    var successTitle: String {
        switch self {
        case .digging:  return "Argilla Trovata!"
        case .kneading: return "Argilla Perfetta!"
        case .washing:  return "Argilla Pura!"
        }
    }

    var bonusText: String {
        switch self {
        case .digging:  return "Clean shovel work — no rocks!"
        case .kneading: return "Perfect kneading rhythm!"
        case .washing:  return "Pure separation!"
        }
    }

    var failTitle: String {
        switch self {
        case .digging:  return "Shovel Broken!"
        case .kneading: return "Clay Dried Out!"
        case .washing:  return "Basin Muddied!"
        }
    }

    var failSubtitle: String {
        switch self {
        case .digging:  return "Too many rocks damaged your tools."
        case .kneading: return "The clay hardened before you finished."
        case .washing:  return "Too much debris mixed in."
        }
    }

    var failEncouragement: String {
        switch self {
        case .digging:
            return "Roman quarrymen studied the earth before digging. Different colors signal different layers — dark soil on top, lighter sand beneath, then the reddish-brown clay deposit. Read the ground like a book."
        case .kneading:
            return "Japanese potters say you can hear the air leaving the clay if you listen. Each press forces bubbles to the surface. The pattern must be steady — press to flatten, fold to trap layers, turn for evenness."
        case .washing:
            return "Levigation separates by particle size. Clay particles are 100x smaller than sand grains. In still water, sand sinks in seconds — clay stays suspended for hours. Patience is the purifier."
        }
    }
}

struct DigLayer: Identifiable {
    let id: Int
    let name: String
    let icon: String
    let color: Color
    let tapsRequired: Int
    let hasRock: Bool
    let scienceFact: String
    var isDug: Bool = false
}

enum KneadAction: CaseIterable {
    case press
    case fold
    case turn

    var displayName: String {
        switch self {
        case .press: return "Press"
        case .fold:  return "Fold"
        case .turn:  return "Turn"
        }
    }

    var icon: String {
        switch self {
        case .press: return "hand.point.down.fill"
        case .fold:  return "arrow.uturn.down"
        case .turn:  return "arrow.triangle.2.circlepath"
        }
    }

    var color: Color {
        switch self {
        case .press: return Color(red: 0.65, green: 0.40, blue: 0.25)
        case .fold:  return Color(red: 0.55, green: 0.45, blue: 0.30)
        case .turn:  return Color(red: 0.50, green: 0.50, blue: 0.35)
        }
    }
}

struct WashItem: Identifiable {
    let id: Int
    let icon: String
    let isClay: Bool
    var tapped: Bool
}
