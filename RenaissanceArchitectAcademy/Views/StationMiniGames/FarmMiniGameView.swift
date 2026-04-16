import SwiftUI

/// Farm "La Fattoria" mini-game
/// Catch falling farm items in the right baskets.
/// Each item drops and the player swipes to choose the correct collection basket.
///
/// Flow: Material selection → Sorting game → Material awarded
struct FarmMiniGameView: View {

    let onComplete: (Material, Int) -> Void   // material earned, bonus florins
    let onDismiss: () -> Void
    var onNudgeCamera: (() -> Void)? = nil

    // MARK: - Game Phases

    enum Phase: Equatable {
        case choose
        case intro
        case playing
        case success
        case failed
    }

    @State private var phase: Phase = .choose
    @State private var selectedMaterial: Material = .eggs

    // MARK: - Game State

    @State private var fallingItems: [FarmItem] = []
    @State private var currentItemIndex: Int = 0
    @State private var basketPosition: Int = 1       // 0=left, 1=center, 2=right
    @State private var catches: Int = 0
    @State private var drops: Int = 0
    @State private var perfectCatches: Int = 0
    @State private var itemY: CGFloat = 0            // 0=top, 1=bottom
    @State private var showCatchFeedback: CatchFeedback?

    // Timers
    @State private var gameTimer: Timer?

    private let totalCatches = 6
    private let maxDrops = 3

    // MARK: - Difficulty

    private var fallSpeed: CGFloat {
        switch selectedMaterial {
        case .eggs:          return 0.008   // Slow — easy
        case .beeswax:       return 0.010   // Medium
        case .letame:        return 0.012   // Medium-fast
        case .charredOxHorn: return 0.014   // Fast — hard
        default:             return 0.010
        }
    }

    private var bonusFlorins: Int { perfectCatches * 2 }

    // MARK: - Body

    var body: some View {
        ZStack {
            if phase == .playing {
                RenaissanceColors.overlayDimming
                    .ignoresSafeArea()

                gameView
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
        VStack(spacing: Spacing.lg) {
            HStack(spacing: 14) {
                BirdCharacter()
                    .frame(width: 70, height: 70)

                VStack(alignment: .leading, spacing: 6) {
                    Text("La Fattoria")
                        .font(RenaissanceFont.title)
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                    Text("Harvest what the land provides. Every farm material has a purpose.")
                        .font(RenaissanceFont.body)
                        .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))
                }
                Spacer()
            }

            VStack(spacing: 12) {
                materialOptionRow(
                    material: .eggs,
                    difficulty: "Easy",
                    description: "Egg yolk binds tempera paint — the medium of Botticelli"
                )
                materialOptionRow(
                    material: .beeswax,
                    difficulty: "Medium",
                    description: "Essential for lost-wax casting of bronze sculptures"
                )
                materialOptionRow(
                    material: .letame,
                    difficulty: "Medium",
                    description: "Mixed into casting molds — organic fibers prevent cracking"
                )
                materialOptionRow(
                    material: .charredOxHorn,
                    difficulty: "Hard",
                    description: "Burned keratin for precision molds and case-hardening steel"
                )
            }

            Button("Back") {
                onDismiss()
            }
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
            withAnimation { phase = .intro }
        } label: {
            HStack(spacing: 14) {
                MaterialIconView(material: material, size: 36)
                    .frame(width: 44, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: CornerRadius.sm)
                            .fill(RenaissanceColors.sageGreen.opacity(0.1))
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

    // MARK: - Phase 2: Intro

    private var introCard: some View {
        MiniGameIntroCard(
            icon: "leaf.fill",
            iconColor: RenaissanceColors.sageGreen,
            title: "Farm Harvest",
            subtitle: selectedMaterial.rawValue,
            bodyText: introText,
            buttonLabel: "Begin Harvest",
            buttonColor: RenaissanceColors.sageGreen,
            startAction: { startGame() },
            backAction: { withAnimation { phase = .choose } }
        ) {
            MiniGameRuleRow(icon: "hand.point.up.left.fill", text: "Catch falling items with your pitchfork", color: RenaissanceColors.sageGreen)
            MiniGameRuleRow(icon: "arrow.down", text: "Tap left, center, or right to move your pitchfork", color: RenaissanceColors.ochre)
            MiniGameRuleRow(icon: "star.fill", text: "Catch in the center = bonus florins", color: RenaissanceColors.goldSuccess)
        }
    }

    private var introText: String {
        switch selectedMaterial {
        case .eggs:
            return "Every Renaissance painting started with an egg. Tempera — pigment mixed with egg yolk — was the standard medium before oil paint arrived from Flanders. Botticelli's 'Birth of Venus' glows because of yolk. One egg covers about two square feet of panel."
        case .beeswax:
            return "Lost-wax casting: sculpt in wax, encase in clay, heat until wax melts out, pour in bronze. The Baptistery doors in Florence took Ghiberti 27 years — each panel started as a wax model no thicker than a coin. One ounce of wax becomes one ounce of bronze."
        case .letame:
            return "Goldsmith molds were made from a mixture of clay, charred ox horn, and cow dung. The organic fibers — yes, from dung — created tiny air channels that let steam escape when molten metal was poured in. Without them, the mold explodes. Science disguised as filth."
        case .charredOxHorn:
            return "Ox horn, burned to charcoal, was ground to a fine black powder and packed around iron to case-harden it — the carbon atoms migrated into the metal surface at 900°C, creating a hard shell over soft iron. This is how Florentine armorers made sword blades that were both flexible and sharp."
        default:
            return "The farm provides."
        }
    }

    // MARK: - Phase 3: Active Game

    private var gameView: some View {
        GeometryReader { geo in
            ZStack {
                // Background — pastoral green
                RoundedRectangle(cornerRadius: CornerRadius.lg)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.18, green: 0.28, blue: 0.15),
                                Color(red: 0.15, green: 0.22, blue: 0.12),
                                Color(red: 0.12, green: 0.18, blue: 0.10)
                            ],
                            startPoint: .top, endPoint: .bottom
                        )
                    )

                VStack(spacing: 0) {
                    // HUD
                    HStack {
                        HStack(spacing: 6) {
                            ForEach(0..<totalCatches, id: \.self) { i in
                                Circle()
                                    .fill(i < catches ? RenaissanceColors.goldSuccess : Color.white.opacity(0.2))
                                    .frame(width: 14, height: 14)
                                    .overlay(
                                        Circle()
                                            .strokeBorder(Color.white.opacity(0.4), lineWidth: 1)
                                    )
                            }
                        }

                        Spacer()

                        HStack(spacing: 4) {
                            Text("\u{1F531}")
                            Text(selectedMaterial.rawValue)
                                .font(.custom("Cinzel-Bold", size: 16))
                                .foregroundStyle(.white)
                        }

                        Spacer()

                        HStack(spacing: 4) {
                            ForEach(0..<maxDrops, id: \.self) { i in
                                Image(systemName: i < drops ? "xmark.circle.fill" : "xmark.circle")
                                    .font(.caption)
                                    .foregroundStyle(i < drops ? RenaissanceColors.errorRed : .white.opacity(0.3))
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

                    // Falling area
                    ZStack {
                        // Three lanes
                        HStack(spacing: 0) {
                            ForEach(0..<3, id: \.self) { lane in
                                Rectangle()
                                    .fill(Color.white.opacity(lane == 1 ? 0.03 : 0.0))
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                        }

                        // Current falling item
                        if currentItemIndex < fallingItems.count {
                            let item = fallingItems[currentItemIndex]
                            let laneWidth = (geo.size.width - 80) / 3
                            let xOffset = (CGFloat(item.lane) - 1) * laneWidth

                            Text(item.icon)
                                .font(.system(size: 40))
                                .offset(x: xOffset, y: itemYPosition(in: geo.size.height - 200))
                        }

                        // Feedback
                        if let fb = showCatchFeedback {
                            Text(fb.text)
                                .font(.custom("Cinzel-Bold", size: 22))
                                .foregroundStyle(fb.color)
                                .shadow(color: .black.opacity(0.5), radius: 3)
                                .transition(.opacity)
                        }
                    }
                    .frame(maxHeight: .infinity)

                    // Basket row
                    HStack(spacing: 0) {
                        ForEach(0..<3, id: \.self) { lane in
                            Button {
                                moveBasket(to: lane)
                            } label: {
                                ZStack {
                                    if basketPosition == lane {
                                        // Active basket
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(RenaissanceColors.warmBrown.opacity(0.4))
                                        Text("\u{1F531}")
                                            .font(.system(size: 36))
                                    } else {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.white.opacity(0.05))
                                        Text("·")
                                            .font(.title)
                                            .foregroundStyle(.white.opacity(0.3))
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 70)
                            }
                        }
                    }
                    .padding(.horizontal, Spacing.lg)

                    Text("Move your pitchfork! \u{1F531}")
                        .font(.custom("EBGaramond-Italic", size: 13))
                        .foregroundStyle(.white.opacity(0.4))
                        .padding(.vertical, Spacing.sm)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
            .borderWorkshop()
            .padding(Spacing.xl)
        }
    }

    private func itemYPosition(in height: CGFloat) -> CGFloat {
        // Map 0...1 to -height/2...height/2
        return -height / 2 + itemY * height
    }

    // MARK: - Phase 4: Success

    private var successCard: some View {
        VStack(spacing: 20) {
            HStack(spacing: 12) {
                BirdCharacter()
                    .frame(width: 70, height: 70)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Raccolto!")
                        .font(.custom("Cinzel-Bold", size: 22))
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                    Text("Your pitchfork caught 1x \(selectedMaterial.rawValue)")
                        .font(RenaissanceFont.dialogSubtitle)
                        .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))
                }
            }

            VStack(spacing: 10) {
                HStack(spacing: 12) {
                    Image(systemName: "leaf.fill")
                        .font(.body)
                        .foregroundStyle(RenaissanceColors.sageGreen)
                        .frame(width: 32, height: 32)
                        .background(
                            RoundedRectangle(cornerRadius: CornerRadius.sm)
                                .fill(RenaissanceColors.sageGreen.opacity(0.1))
                        )

                    Text("\(catches) caught on pitchfork, \(drops) dropped")
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

                if perfectCatches > 0 {
                    HStack(spacing: 12) {
                        Image(systemName: "star.fill")
                            .font(.body)
                            .foregroundStyle(RenaissanceColors.goldSuccess)
                            .frame(width: 32, height: 32)
                            .background(
                                RoundedRectangle(cornerRadius: CornerRadius.sm)
                                    .fill(RenaissanceColors.goldSuccess.opacity(0.1))
                            )

                        Text("\(perfectCatches) perfect pitchfork catch\(perfectCatches == 1 ? "" : "es")")
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
                SoundManager.shared.play(.farmCollect)
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

    // MARK: - Phase 5: Failed

    private var failedCard: some View {
        VStack(spacing: 20) {
            HStack(spacing: 12) {
                BirdCharacter()
                    .frame(width: 70, height: 70)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Harvest Lost!")
                        .font(.custom("Cinzel-Bold", size: 22))
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                    Text("Too many slipped past your pitchfork.")
                        .font(RenaissanceFont.dialogSubtitle)
                        .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))
                }
            }

            Text("A Renaissance farmhand's hands were always ready. The bees don't wait, the hens don't pause, and the ox horn burns on its own schedule. Stay alert.")
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

                        Text("Leave Farm")
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
        generateItems()
        withAnimation { phase = .playing }

        // Start first item falling after short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            beginFall()
        }
    }

    private func resetGame() {
        fallingItems = []
        currentItemIndex = 0
        catches = 0
        drops = 0
        perfectCatches = 0
        basketPosition = 1
        itemY = 0
        showCatchFeedback = nil
        gameTimer?.invalidate()
    }

    private func generateItems() {
        // Generate items — mix of target material icons and distractors
        let targetIcon = selectedMaterial.icon
        let distractors = farmDistractors

        fallingItems = (0..<(totalCatches + maxDrops + 2)).map { i in
            let isTarget = i < totalCatches || Bool.random()
            return FarmItem(
                id: i,
                icon: isTarget ? targetIcon : distractors.randomElement()!,
                isTarget: isTarget,
                lane: Int.random(in: 0...2)
            )
        }
        fallingItems.shuffle()
    }

    private var farmDistractors: [String] {
        // Items that look farm-like but aren't the target
        ["🌾", "🪺", "🐓", "🌻", "🥛", "🪣", "🌿", "🍎"]
    }

    private func beginFall() {
        guard phase == .playing, currentItemIndex < fallingItems.count else { return }

        itemY = 0
        gameTimer?.invalidate()
        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            guard phase == .playing else { return }
            itemY += fallSpeed

            if itemY >= 1.0 {
                // Item reached bottom
                gameTimer?.invalidate()
                handleItemLanded()
            }
        }
    }

    private func moveBasket(to lane: Int) {
        guard phase == .playing else { return }
        withAnimation(.easeInOut(duration: 0.15)) {
            basketPosition = lane
        }
    }

    private func handleItemLanded() {
        guard currentItemIndex < fallingItems.count else { return }
        let item = fallingItems[currentItemIndex]

        if item.lane == basketPosition {
            // Caught!
            if item.isTarget {
                catches += 1
                let isPerfect = itemY < 1.05  // Caught right at bottom
                if isPerfect { perfectCatches += 1 }
                showFeedback(isPerfect ? "Perfect!" : "Caught!", color: isPerfect ? RenaissanceColors.goldSuccess : RenaissanceColors.sageGreen)
            } else {
                // Caught a distractor — counts as drop
                drops += 1
                showFeedback("Wrong item!", color: RenaissanceColors.errorRed)
            }
        } else {
            if item.isTarget {
                // Missed a target
                drops += 1
                showFeedback("Missed!", color: RenaissanceColors.errorRed)
            }
            // Missing a distractor is fine — no penalty
        }

        // Check win/lose
        if catches >= totalCatches {
            onNudgeCamera?()
            withAnimation { phase = .success }
            return
        }

        if drops >= maxDrops {
            onNudgeCamera?()
            withAnimation { phase = .failed }
            return
        }

        // Next item
        currentItemIndex += 1
        if currentItemIndex < fallingItems.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                beginFall()
            }
        } else {
            // Ran out of items — generate more
            let extra = totalCatches - catches + maxDrops
            let targetIcon = selectedMaterial.icon
            for i in 0..<extra {
                fallingItems.append(FarmItem(
                    id: fallingItems.count + i,
                    icon: targetIcon,
                    isTarget: true,
                    lane: Int.random(in: 0...2)
                ))
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                beginFall()
            }
        }
    }

    private func showFeedback(_ text: String, color: Color) {
        withAnimation {
            showCatchFeedback = CatchFeedback(text: text, color: color)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation { showCatchFeedback = nil }
        }
    }
}

// MARK: - Supporting Models

struct FarmItem: Identifiable {
    let id: Int
    let icon: String
    let isTarget: Bool
    let lane: Int       // 0, 1, 2
}

struct CatchFeedback {
    let text: String
    let color: Color
}
