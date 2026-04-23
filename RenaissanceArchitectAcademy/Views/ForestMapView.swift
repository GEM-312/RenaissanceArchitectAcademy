import SwiftUI
import SpriteKit
// Audio via SoundManager

/// SwiftUI wrapper for the ForestScene SpriteKit experience
/// Layers: SpriteKit scene → bird companion → nav panel + inventory → science cards overlay → truffle overlay
struct ForestMapView: View {

    private var settings: GameSettings { GameSettings.shared }
    var workshop: WorkshopState
    var viewModel: CityViewModel? = nil
    var onNavigate: ((SidebarDestination) -> Void)? = nil
    var onBackToWorkshop: (() -> Void)? = nil
    var onBackToMenu: (() -> Void)? = nil
    var onboardingState: OnboardingState? = nil
    @Binding var returnToLessonPlotId: Int?

    // Scene reference — stored in a class box so it survives body re-evaluation
    // without triggering re-renders (unlike @State which causes infinite loops)
    @State private var sceneHolder = SceneHolder<ForestScene>()
    @State private var playerPosition: CGPoint = CGPoint(x: 0.5, y: 0.5)
    @State private var playerIsWalking = false

    // POI info overlay state
    @State private var selectedPOIIndex: Int?

    // Science Cards state
    @State private var scienceCards: [ScienceCardData] = []
    @State private var cardPhases: [ForestCardCategory: CardPhase] = [:]
    @State private var completedCards: Set<ForestCardCategory> = []
    @State private var flippedCards: Set<ForestCardCategory> = []  // which cards are face-down (showing lesson)
    @State private var activeCard: ForestCardCategory? = nil       // which card is in activity mode
    @State private var cardsAppeared = false

    // Keyword matching state
    @State private var matchedPairIDs: Set<UUID> = []
    @State private var selectedKeywordID: UUID? = nil
    @State private var selectedDefinitionID: UUID? = nil
    @State private var shuffledDefinitions: [KeywordPair] = []
    @State private var wrongMatchFlash = false
    @State private var earnedFlorinsFloat: Int? = nil

    // Truffle discovery overlay state
    @State private var discoveredTruffle: ForestScene.TruffleFind?
    @State private var pendingTruffle: ForestScene.TruffleFind?

    // Floating timber collection feedback
    @State private var showTimberFloat = false
    @State private var timberFloatAmount = 0
    @State private var timberFloatFlorins = 0

    // Floating truffle sale feedback
    @State private var showTruffleSaleFloat = false
    @State private var truffleSaleFlorins = 0

    // Avatar box: sprite visible only when player hasn't moved yet
    @State private var avatarInBox = true

    // Tool requirement dialog (shown when player reaches POI without axe)
    @State private var showToolDialog = false

    // Bird guidance state
    @State private var showGuidance = false
    @State private var guidanceMessage: String = ""
    @State private var guidanceDestination: SidebarDestination? = nil

    @ObservedObject private var assetManager = AssetManager.shared

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Layer 1: SpriteKit scene (wait for ODR on iOS)
                if assetManager.isReady(AssetManager.forestScene) {
                    GameSpriteView(scene: makeScene(), options: [.allowsTransparency])
                        .ignoresSafeArea()
                } else {
                    ODRLoadingView(tag: AssetManager.forestScene, message: "Preparing the forest...")
                }

                // Layer 2: Bird companion overlay — only show when stopped (reduces memory)
                if !playerIsWalking {
                    BirdCharacter(isSitting: true)
                        .frame(width: 80, height: 80)
                        .position(
                            x: playerPosition.x * geometry.size.width + 60,
                            y: playerPosition.y * geometry.size.height - 45
                        )
                        .allowsHitTesting(false)
                        .transition(.opacity)
                }

                // Layer 3: Nav panel (inventory bar moved to its own layer
                // below so it can dock top or bottom).
                VStack(spacing: 0) {
                    navigationPanel
                        .frame(maxWidth: .infinity)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(Spacing.md)

                // Layer 3b: Foldable inventory bar
                inventoryBar
                    .padding(.horizontal, Spacing.md)
                    .padding(.bottom, Spacing.md)

                #if DEBUG
                SceneEditorButtons(
                    isActive: sceneHolder.scene?.isEditorActive == true,
                    onToggle: { sceneHolder.scene?.toggleEditorMode() },
                    onRotateLeft: { sceneHolder.scene?.editorRotateLeft() },
                    onRotateRight: { sceneHolder.scene?.editorRotateRight() },
                    onNudge: { dx, dy in sceneHolder.scene?.editorNudge(dx: dx, dy: dy) }
                )
                #endif

                // Layer 4: Tree info + collect timber overlay
                if let poiIndex = selectedPOIIndex,
                   let poi = sceneHolder.scene?.getPOI(at: poiIndex) {
                    treeInfoOverlay(poi: poi)
                        .transition(.opacity.combined(with: .scale(scale: 0.9)))
                }

                // Layer 5: Truffle discovery overlay
                if let truffle = discoveredTruffle {
                    truffleDiscoveryOverlay(truffle: truffle)
                        .transition(.opacity.combined(with: .scale(scale: 0.85)))
                }

                // Layer 6: Floating "+N timber +N florins" feedback
                if showTimberFloat {
                    HStack(spacing: 8) {
                        Text("+\(timberFloatAmount) 🪵")
                            .font(.custom("Cinzel-Bold", size: 22))
                            .foregroundStyle(settings.cardTextColor)
                        if timberFloatFlorins > 0 {
                            Text("+\(timberFloatFlorins) florins")
                                .font(.custom("Cinzel-Bold", size: 20))
                                .foregroundStyle(RenaissanceColors.goldSuccess)
                        }
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    .padding(.bottom, 80)
                    .allowsHitTesting(false)
                }

                // Layer 7: Floating truffle sale feedback
                if showTruffleSaleFloat {
                    Text("+\(truffleSaleFlorins) florins")
                        .font(.custom("Cinzel-Bold", size: 24))
                        .foregroundStyle(RenaissanceColors.goldSuccess)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                        .padding(.bottom, 80)
                        .allowsHitTesting(false)
                }

                // Layer 8: Floating florins earned from keyword match
                if let florins = earnedFlorinsFloat {
                    Text("+\(florins) florins")
                        .font(.custom("Cinzel-Bold", size: 20))
                        .foregroundStyle(RenaissanceColors.goldSuccess)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .offset(y: -40)
                        .allowsHitTesting(false)
                }

                // Bird guidance — tells player where to go next
                if showGuidance {
                    BottomDialogPanel(bottomPadding: Spacing.xl) {
                        BirdGuidanceContent(
                            message: guidanceMessage,
                            progressText: {
                                guard let vm = viewModel, let bid = vm.activeBuildingId else { return nil }
                                let p = vm.cardProgress(for: bid)
                                return "\(p.completed)/\(p.total) cards collected"
                            }(),
                            onDismiss: { withAnimation { showGuidance = false } },
                            destination: guidanceDestination,
                            onNavigate: onNavigate
                        )
                    }
                    .zIndex(50)
                }
            }
            .onChange(of: selectedPOIIndex) { oldValue, newValue in
                if newValue != nil {
                    if let poi = sceneHolder.scene?.getPOI(at: newValue!) {
                        setupScienceCards(for: poi)
                    }
                } else if oldValue != nil {
                    // POI dismissed — player stays where they are
                    showToolDialog = false
                    if let truffle = pendingTruffle {
                        pendingTruffle = nil
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                discoveredTruffle = truffle
                            }
                        }
                    }
                    // POI dismissed — player continues exploring freely
                }
            }
            .onChange(of: playerIsWalking) { _, isWalking in
                if isWalking && avatarInBox {
                    avatarInBox = false
                }
                if isWalking && showGuidance {
                    withAnimation(.easeOut(duration: 0.2)) { showGuidance = false }
                }
            }
            .onAppear {
                // Show bird guidance after player settles (avoid race with auto-walk)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    if !showGuidance && selectedPOIIndex == nil {
                        showForestGuidance()
                    }
                }
            }
        }
    }

    // MARK: - Science Cards Setup

    // MARK: - Bird Guidance

    private func showForestGuidance() {
        print("[FOREST GUIDANCE] Called. selectedPOI=\(selectedPOIIndex as Any), truffle=\(discoveredTruffle != nil)")
        guard selectedPOIIndex == nil && discoveredTruffle == nil else {
            print("[FOREST GUIDANCE] Blocked by POI/truffle guard")
            return
        }

        let hasAxe = workshop.hasTool(for: .forest)
        let timberCount = workshop.rawMaterials[.timber] ?? 0

        print("[FOREST GUIDANCE] hasAxe=\(hasAxe), timber=\(timberCount), activeBuildingId=\(viewModel?.activeBuildingId as Any)")

        // No active building — guide through forest activities
        guard let vm = viewModel, let bid = vm.activeBuildingId else {
            if !hasAxe {
                guidanceMessage = "You need an Axe to collect timber! Buy one at the Market in the Workshop (10 florins)."
                guidanceDestination = .workshop
            } else if timberCount < 3 {
                guidanceMessage = "Tap a tree → complete all 4 science cards → collect timber! You need 3 timber for scaffolding. (\(timberCount)/3 collected)"
                guidanceDestination = nil
            } else {
                guidanceMessage = "Good work! You've collected \(timberCount) timber. Head back to the Workshop to craft Timber Beams!"
                guidanceDestination = .workshop
            }
            withAnimation(.spring(response: 0.4)) { showGuidance = true }
            return
        }

        let buildingName = vm.buildingPlots.first(where: { $0.id == bid })?.building.name ?? ""
        let progress = vm.buildingProgressMap[bid] ?? BuildingProgress()

        // LOCAL WORK FIRST: check forest knowledge cards
        let forestCards = KnowledgeCardContent.cards(for: buildingName, in: .forest)
        let hasUncompletedCards = forestCards.contains { !progress.completedCardIDs.contains($0.id) }

        // 1. Need an axe first
        if !hasAxe {
            guidanceMessage = "You need an Axe to collect timber! Buy one at the Market in the Workshop (10 florins)."
            guidanceDestination = .workshop
            withAnimation(.spring(response: 0.4)) { showGuidance = true }
            return
        }

        // 2. Need timber — guide to the specific tree with the next knowledge card
        if timberCount < 3 {
            let forestCards = KnowledgeCardContent.cards(for: buildingName, in: .forest)
            let nextCard = forestCards.first { !progress.completedCardIDs.contains($0.id) }
            if let card = nextCard {
                let treeName = card.stationKey.capitalized
                guidanceMessage = "Visit the \(treeName) tree! Learn about \(card.title) and collect timber for the \(buildingName). (\(timberCount)/3 timber)"
            } else {
                guidanceMessage = "Tap any tree to collect timber for the \(buildingName)! (\(timberCount)/3 timber)"
            }
            guidanceDestination = nil
            withAnimation(.spring(response: 0.4)) { showGuidance = true }
            return
        }

        // 4. Enough timber — guide to Crafting Room to craft Timber Beams
        let hasCraftedTimberBeams = (workshop.craftedMaterials[.timberBeams] ?? 0) >= 1
        if hasCraftedTimberBeams {
            guidanceMessage = "All done for the \(buildingName)! Head to the City Map to build!"
            guidanceDestination = .cityMap
        } else {
            guidanceMessage = "You have \(timberCount) timber! Head to the Crafting Room to craft Timber Beams for the \(buildingName)!"
            guidanceDestination = .workshop
        }

        withAnimation(.spring(response: 0.4)) {
            showGuidance = true
        }
    }

    private func setupScienceCards(for poi: ForestScene.ForestPOI) {
        showGuidance = false  // Dismiss guidance when opening science cards
        scienceCards = ScienceCardContent.cards(for: poi.name)
        cardPhases = [:]
        completedCards = []
        flippedCards = []
        flippedOpenCard = nil
        activeCard = nil
        flipAngles = [:]
        cardsAppeared = false
        floatOffset = 0
        auroraPhase = false
        matchedPairIDs = []
        selectedKeywordID = nil
        selectedDefinitionID = nil
        shuffledDefinitions = []
        wrongMatchFlash = false

        for cat in ForestCardCategory.allCases {
            cardPhases[cat] = .faceUp
            flipAngles[cat] = 0
        }

        // Staggered card appearance animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            SoundManager.shared.play(.cardsAppear)
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                cardsAppeared = true
            }
        }
    }

    // MARK: - Science Cards Overlay

    /// Which card is currently flipped open (showing lesson back). nil = all face-up spread.
    @State private var flippedOpenCard: ForestCardCategory? = nil
    /// Floating bob offset, animated on appear
    @State private var floatOffset: CGFloat = 0
    /// Aurora blob animation phase
    @State private var auroraPhase = false

    private let cardW: CGFloat = 200
    private let cardH: CGFloat = 280  // ~5:7 poker ratio
    private let flippedW: CGFloat = 560
    private let flippedH: CGFloat = 780

    // MARK: - Tree Info + Collect Timber Overlay (replaces old 4-card science cards)

    private func treeInfoOverlay(poi: ForestScene.ForestPOI) -> some View {
        let hasAxe = workshop.hasTool(for: .forest)
        let timberCount = workshop.rawMaterials[.timber] ?? 0

        return ZStack {
            RenaissanceColors.overlayDimming
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeOut(duration: 0.2)) {
                        selectedPOIIndex = nil
                    }
                }

            VStack(spacing: Spacing.md) {
                Spacer(minLength: 40)

                // Tree header
                VStack(spacing: Spacing.xs) {
                    Text(poi.name)
                        .font(RenaissanceFont.title)
                        .tracking(Tracking.label)
                        .foregroundStyle(RenaissanceColors.ochre)
                    Text(poi.italianName)
                        .font(RenaissanceFont.dialogSubtitle)
                        .foregroundStyle(RenaissanceColors.ochre.opacity(0.7))
                    HStack(spacing: 6) {
                        poiBadge(poi.woodType, color: RenaissanceColors.ochre)
                        poiBadge(poi.leafType, color: RenaissanceColors.sageGreen)
                        poiBadge(poi.maxHeight, color: RenaissanceColors.warmBrown)
                    }
                }

                // Biology fact
                VStack(spacing: Spacing.sm) {
                    Text(poi.biologyFact)
                        .font(RenaissanceFont.body)
                        .foregroundStyle(settings.cardTextColor)
                        .multilineTextAlignment(.center)
                        .lineSpacing(LineHeight.relaxed)
                        .padding(.horizontal, Spacing.lg)

                    // Building-specific knowledge card lesson (if exists)
                    if let vm = viewModel, let bid = vm.activeBuildingId {
                        let treeName = poi.name.lowercased()
                        let buildingName = vm.activeBuildingName ?? ""
                        let treeCards = KnowledgeCardContent.cards(for: buildingName, at: treeName)
                        if let card = treeCards.first {
                            VStack(spacing: Spacing.xs) {
                                Text(card.title)
                                    .font(RenaissanceFont.cardTitle)
                                    .foregroundStyle(RenaissanceColors.renaissanceBlue)
                                Text(card.lessonText)
                                    .font(RenaissanceFont.bodySmall)
                                    .foregroundStyle(settings.cardTextColor.opacity(0.8))
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(LineHeight.normal)
                            }
                            .padding(Spacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: CornerRadius.sm)
                                    .fill(RenaissanceColors.renaissanceBlue.opacity(0.06))
                            )
                            .padding(.horizontal, Spacing.md)
                        }
                    } else if viewModel?.activeBuildingId == nil {
                        // No active building — show discovery card for this tree
                        let treeName = poi.name.lowercased()
                        if let card = DiscoveryCardContent.card(for: treeName) {
                            VStack(spacing: Spacing.xs) {
                                HStack(spacing: 6) {
                                    Text("DISCOVERY")
                                        .font(.custom("Cinzel-Bold", size: 9))
                                        .tracking(1.5)
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .background(card.color.opacity(0.8), in: Capsule())
                                    Spacer()
                                }
                                Text(card.storyText)
                                    .font(RenaissanceFont.bodySmall)
                                    .foregroundStyle(settings.cardTextColor.opacity(0.8))
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(LineHeight.normal)

                                HStack(spacing: 6) {
                                    Image(systemName: "lightbulb.fill")
                                        .foregroundStyle(.yellow)
                                        .font(.caption)
                                    Text(card.funFact)
                                        .font(.custom("EBGaramond-Italic", size: 12))
                                        .foregroundStyle(settings.cardTextColor.opacity(0.7))
                                }

                                Button {
                                    selectedPOIIndex = nil
                                    onNavigate?(.cityMap)
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "building.columns.fill")
                                            .font(.caption)
                                        Text("Choose a Building")
                                            .font(.custom("Cinzel-Bold", size: 11))
                                    }
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 7)
                                    .parchmentButton(color: card.color, radius: 8)
                                }
                            }
                            .padding(Spacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: CornerRadius.sm)
                                    .fill(card.color.opacity(0.06))
                            )
                            .padding(.horizontal, Spacing.md)
                        }
                    }
                }
                .padding(Spacing.lg)
                .background(
                    RoundedRectangle(cornerRadius: CornerRadius.lg)
                        .fill(settings.dialogBackground.opacity(0.95))
                )
                .borderModal(radius: CornerRadius.lg)
                .padding(.horizontal, Spacing.lg)

                // Collect timber button
                VStack(spacing: 8) {
                    Button {
                        if hasAxe { collectTimber(from: poi) }
                    } label: {
                        HStack(spacing: 8) {
                            if !hasAxe {
                                Text("Need an Axe (buy at Market — 10 florins)")
                                    .font(RenaissanceFont.buttonSmall)
                            } else {
                                Image(systemName: "leaf.fill")
                                    .font(.body)
                                Text("Collect Timber (+\(poi.timberYield) 🪵)  [\(timberCount)/3]")
                                    .font(RenaissanceFont.buttonSmall)
                            }
                        }
                        .foregroundStyle(.white)
                        .padding(.vertical, 11)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(hasAxe ? RenaissanceColors.ochre : RenaissanceColors.stoneGray.opacity(0.5))
                        )
                    }
                    .disabled(!hasAxe)
                    .padding(.horizontal, Spacing.lg)

                    Button {
                        withAnimation(.easeOut(duration: 0.2)) { selectedPOIIndex = nil }
                    } label: {
                        Text("Continue Exploring")
                            .font(RenaissanceFont.caption)
                            .foregroundStyle(settings.cardTextColor.opacity(0.4))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.bottom, 80)
            }
        }
    }

    // MARK: - Old Science Cards (kept for reference, no longer shown)

    private func scienceCardsOverlay(poi: ForestScene.ForestPOI) -> some View {
        GeometryReader { geo in
            ZStack {
                RenaissanceColors.overlayDimming
                    .ignoresSafeArea()
                    .onTapGesture {
                        if let open = flippedOpenCard, cardPhases[open] == .activity {
                            // Go back to reading from activity
                            withAnimation(.easeInOut(duration: 0.4)) {
                                cardPhases[open] = .reading
                                activeCard = nil
                            }
                        } else if let open = flippedOpenCard {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
                                flipAngles[open] = 0
                                flippedOpenCard = nil
                            }
                        } else {
                            dismissScienceCards()
                        }
                    }

                    // Vertical layout: tree header + cards + timber button
                    VStack(spacing: 0) {
                        Spacer(minLength: 20)

                        // Tree header
                        VStack(spacing: Spacing.xs) {
                            Text(poi.name)
                                .font(RenaissanceFont.title)
                                .tracking(Tracking.label)
                                .foregroundStyle(RenaissanceColors.ochre)
                                .shadow(color: .black.opacity(0.6), radius: 4, y: 2)
                            Text(poi.italianName)
                                .font(RenaissanceFont.dialogSubtitle)
                                .foregroundStyle(RenaissanceColors.ochre.opacity(0.7))
                                .shadow(color: .black.opacity(0.4), radius: 3, y: 1)
                            HStack(spacing: 6) {
                                poiBadge(poi.woodType, color: RenaissanceColors.ochre)
                                poiBadge(poi.leafType, color: RenaissanceColors.sageGreen)
                                poiBadge(poi.maxHeight, color: RenaissanceColors.warmBrown)
                            }
                        }
                        .padding(.bottom, Spacing.sm)

                        // Cards row — 3D flip in place, pile when one flips
                        cardsRowView(screenSize: geo.size)

                        // Bottom bar: bird encouragement + timber collect button
                        VStack(spacing: 8) {
                            birdEncouragement
                            collectTimberButton(poi: poi)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, Spacing.sm)
                        .padding(.bottom, 80) // above inventory bar
                    }
            }
        }
        .task {
            await AssetManager.shared.requestAssets(tag: AssetManager.forestScene)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                floatOffset = 8
            }
            auroraPhase = true
            // Show bird guidance after short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                showForestGuidance()
            }
        }
        .onDisappear {
            // Nil out callbacks before releasing scene to break closure references
            sceneHolder.scene?.onPlayerPositionChanged = nil
            sceneHolder.scene?.onBackRequested = nil
            sceneHolder.scene?.onPOISelected = nil
            sceneHolder.scene?.onTruffleFound = nil
            sceneHolder.scene?.onPlayerStartedWalking = nil
            // Release scene to free SpriteKit texture memory when navigating away
            sceneHolder.scene = nil
        }
    }

    // MARK: - Cards Row (3D flip in place, pile when one flips)

    /// Tracks the Y-axis flip angle per card for 3D rotation
    @State private var flipAngles: [ForestCardCategory: Double] = [:]

    private func cardsRowView(screenSize: CGSize) -> some View {
        let allCategories = ForestCardCategory.allCases
        let spacing: CGFloat = 16
        let totalWidth = CGFloat(allCategories.count) * cardW + CGFloat(allCategories.count - 1) * spacing

        return ZStack {
            // Connection line behind spread cards
            if flippedOpenCard == nil {
                Rectangle()
                    .fill(RenaissanceColors.ochre.opacity(0.2))
                    .frame(width: totalWidth - 60, height: 2)
            }

            ForEach(Array(allCategories.enumerated()), id: \.element) { index, category in
                let isCompleted = completedCards.contains(category)
                let isThisFlipped = flippedOpenCard == category
                let someCardFlipped = flippedOpenCard != nil
                let isPiled = someCardFlipped && !isThisFlipped
                let angle = flipAngles[category] ?? 0

                // Spread position: center the row
                let spreadX = CGFloat(index) * (cardW + spacing) - (totalWidth - cardW) / 2

                // Pile position: stack to the left
                let pileX = -screenSize.width * 0.35 + CGFloat(pileStackIndex(category)) * 8

                // 3D flippable card — front and back in a ZStack
                ZStack {
                    // FRONT face — visible when angle < 90
                    cardFront(category: category, isCompleted: isCompleted)
                        .frame(width: cardW, height: cardH)
                        .opacity(angle < 90 ? 1 : 0)

                    // BACK face — visible when angle >= 90, counter-rotated so text reads correctly
                    // Scales up from tiny to full size with a spring pop
                    if let cardData = scienceCards.first(where: { $0.category == category }) {
                        flippedCardBack(cardData: cardData, isCompleted: isCompleted)
                            .frame(width: flippedW, height: flippedH)
                            .scaleEffect(isThisFlipped ? 1.0 : 0.15)
                            .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                            .opacity(angle >= 90 ? 1 : 0)
                            .animation(.spring(response: 0.5, dampingFraction: 0.7), value: isThisFlipped)
                    }
                }
                .rotation3DEffect(.degrees(angle), axis: (x: 0, y: 1, z: 0), perspective: 0.4)
                .scaleEffect(isPiled ? 0.5 : 1.0)
                .offset(
                    x: someCardFlipped ? (isPiled ? pileX : 0) : spreadX,
                    y: isPiled ? CGFloat(pileStackIndex(category)) * 5 : floatOffset * (index.isMultiple(of: 2) ? 1 : -1)
                )
                .rotation3DEffect(.degrees(isPiled ? -5 + Double(pileStackIndex(category)) * 3 : 0), axis: (x: 0, y: 0, z: 1))
                .opacity(isPiled ? 0.65 : 1.0)
                .zIndex(isThisFlipped ? 10 : Double(isPiled ? pileStackIndex(category) : index))
                // Appear animation
                .scaleEffect(cardsAppeared ? 1.0 : 0.2)
                .opacity(cardsAppeared ? 1.0 : 0)
                .animation(
                    .spring(response: 0.5, dampingFraction: 0.65)
                        .delay(Double(index) * 0.1),
                    value: cardsAppeared
                )
                .animation(.spring(response: 0.6, dampingFraction: 0.75), value: flippedOpenCard)
                .animation(.spring(response: 0.6, dampingFraction: 0.75), value: flipAngles[category])
                .onTapGesture {
                    // Only handle tap when showing front face or reading — not during activity
                    if cardPhases[category] != .activity {
                        handleCardTap(category: category, isCompleted: isCompleted)
                    }
                }
            }
        }
    }

    /// Stack order for piled cards
    private func pileStackIndex(_ category: ForestCardCategory) -> Int {
        let others = ForestCardCategory.allCases.filter { $0 != flippedOpenCard }
        return others.firstIndex(of: category) ?? 0
    }

    /// The next card the player should work on (first uncompleted in order)
    private var nextUnlockedCategory: ForestCardCategory? {
        ForestCardCategory.allCases.first { !completedCards.contains($0) }
    }

    /// Whether a card is currently unlocked for interaction
    private func isCardUnlocked(_ category: ForestCardCategory) -> Bool {
        completedCards.contains(category) || category == nextUnlockedCategory
    }

    /// Handle tap on a card — 3D flip or unflip
    private func handleCardTap(category: ForestCardCategory, isCompleted: Bool) {
        if isCompleted && flippedOpenCard != category { return }

        // Only allow tapping the next unlocked card
        guard isCardUnlocked(category) else { return }

        if flippedOpenCard == category {
            // Tapping the flipped card — unflip back to front
            SoundManager.shared.play(.cardFlip)
            withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
                flipAngles[category] = 0
                flippedOpenCard = nil
                if cardPhases[category] == .activity {
                    activeCard = nil
                }
            }
        } else {
            // Unflip any currently open card first
            if let current = flippedOpenCard {
                flipAngles[current] = 0
                if cardPhases[current] == .activity {
                    activeCard = nil
                }
            }
            // Flip this card with 3D rotation, others pile left
            SoundManager.shared.play(.cardFlip)
            withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
                flippedOpenCard = category
                flipAngles[category] = 180
                flippedCards.insert(category)
                cardPhases[category] = .reading
            }
        }
    }

    // MARK: - Card Front (icon + science name)

    @ViewBuilder
    private func cardFront(category: ForestCardCategory, isCompleted: Bool) -> some View {
        let locked = !isCardUnlocked(category)
        ZStack {
            // Layer 1: Glass background + aurora blobs
            RoundedRectangle(cornerRadius: 14)
                .fill(
                    isCompleted
                    ? RenaissanceColors.sageGreen.opacity(0.06)
                    : locked ? RenaissanceColors.sepiaInk.opacity(0.4) : Color.clear
                )
                .overlay(
                    Group {
                        if !isCompleted {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(RenaissanceColors.sepiaInk)
                        }
                    }
                )
                // Aurora blobs on top of glass, below content
                .overlay(
                    ZStack {
                        if !isCompleted {
                            Ellipse()
                                .fill(category.color.opacity(0.55))
                                .frame(width: 180, height: 120)
                                .blur(radius: 38)
                                .offset(
                                    x: auroraPhase ? 40 : -30,
                                    y: auroraPhase ? 100 : 130
                                )
                                .animation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true), value: auroraPhase)

                            Ellipse()
                                .fill(category.color.opacity(0.4))
                                .frame(width: 128, height: 165)
                                .blur(radius: 33)
                                .offset(
                                    x: auroraPhase ? -35 : 25,
                                    y: auroraPhase ? 110 : 140
                                )
                                .animation(.easeInOut(duration: 5.5).repeatForever(autoreverses: true), value: auroraPhase)

                            Ellipse()
                                .fill(RenaissanceColors.goldSuccess.opacity(0.3))
                                .frame(width: 135, height: 90)
                                .blur(radius: 36)
                                .offset(
                                    x: auroraPhase ? 20 : -40,
                                    y: auroraPhase ? 105 : 135
                                )
                                .animation(.easeInOut(duration: 6.5).repeatForever(autoreverses: true), value: auroraPhase)

                            Circle()
                                .fill(Color.white.opacity(0.25))
                                .frame(width: 82, height: 82)
                                .blur(radius: 27)
                                .offset(
                                    x: auroraPhase ? -15 : 30,
                                    y: auroraPhase ? 115 : 120
                                )
                                .animation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true), value: auroraPhase)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                )

            // Layer 2: Content (icon + title) — always in front
            VStack(spacing: 12) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(isCompleted ? RenaissanceColors.sageGreen.opacity(0.2) : category.color.opacity(0.15))
                        .frame(width: 70, height: 70)

                    Image(systemName: isCompleted ? "checkmark.circle.fill" : locked ? "lock.fill" : category.icon)
                        .font(.system(size: 36))
                        .foregroundStyle(isCompleted ? RenaissanceColors.sageGreen : locked ? settings.cardTextColor.opacity(0.4) : category.color)
                        .shadow(color: isCompleted || locked ? .clear : category.color.opacity(0.5), radius: 6)
                }

                Text(category.rawValue)
                    .font(RenaissanceFont.cardTitle)
                    .tracking(Tracking.label)
                    .foregroundStyle(isCompleted ? RenaissanceColors.sageGreen : locked ? settings.cardTextColor.opacity(0.4) : category.color)

                if !isCompleted && !locked {
                    Image(systemName: "hand.tap.fill")
                        .font(.system(size: 13))
                        .foregroundStyle(settings.cardTextColor.opacity(0.3))
                }

                Spacer()
            }
        }
        .frame(width: cardW, height: cardH)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    isCompleted
                    ? RenaissanceColors.sageGreen.opacity(0.4)
                    : category.color.opacity(0.3),
                    lineWidth: 1.5
                )
        )
        .shadow(color: isCompleted ? .clear : category.color.opacity(0.5), radius: 20, y: 6)
        .shadow(color: isCompleted ? .clear : category.color.opacity(0.3), radius: 40, y: 10)
    }

    // MARK: - Flipped Card Back (reading ↔ activity fade on same card)

    private func flippedCardBack(cardData: ScienceCardData, isCompleted: Bool) -> some View {
        let isActivity = cardPhases[cardData.category] == .activity

        return VStack(spacing: 0) {
            // Category header — always visible
            HStack(spacing: 8) {
                Image(systemName: cardData.category.icon)
                    .font(.system(size: 16))
                Text(cardData.category.rawValue)
                    .font(.custom("Cinzel-Bold", size: 16))
                Spacer()
                if isActivity {
                    Button {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            cardPhases[cardData.category] = .reading
                            activeCard = nil
                        }
                    } label: {
                        HStack(spacing: 3) {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 10))
                            Text("Lesson")
                                .font(RenaissanceFont.caption)
                        }
                        .foregroundStyle(cardData.category.color.opacity(0.6))
                    }
                }
                if isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(RenaissanceColors.sageGreen)
                }
            }
            .foregroundStyle(cardData.category.color)
            .padding(.top, Spacing.sm)
            .padding(.bottom, 6)
            .padding(.horizontal, 4)

            Rectangle()
                .fill(cardData.category.color.opacity(0.2))
                .frame(height: 1)
                .padding(.horizontal, Spacing.xs)

            // Content area — fades between reading and activity
            ZStack {
                // READING content
                if !isActivity {
                    VStack(spacing: 0) {
                        // Keyword circles
                        HStack(spacing: 10) {
                            ForEach(cardData.keywords.prefix(4)) { pair in
                                VStack(spacing: 3) {
                                    Circle()
                                        .fill(cardData.category.color.opacity(0.1))
                                        .frame(width: 36, height: 36)
                                        .overlay(
                                            Image(systemName: cardData.category.icon)
                                                .font(.system(size: 14))
                                                .foregroundStyle(cardData.category.color.opacity(0.5))
                                        )
                                    Text(pair.keyword)
                                        .font(.custom("EBGaramond-SemiBold", size: 9))
                                        .foregroundStyle(cardData.category.color)
                                        .lineLimit(1)
                                }
                            }
                        }
                        .padding(.vertical, Spacing.xs)

                        Rectangle()
                            .fill(cardData.category.color.opacity(0.1))
                            .frame(height: 1)
                            .padding(.horizontal, Spacing.xs)

                        // Lesson text with highlighted keywords
                        ScrollView(.vertical, showsIndicators: false) {
                            highlightedLessonText(cardData: cardData)
                                .padding(.top, Spacing.xs)
                        }

                        Spacer(minLength: 6)

                        if !isCompleted {
                            Button {
                                openActivityForCard(cardData.category)
                            } label: {
                                Text("Done Reading")
                                    .font(RenaissanceFont.buttonSmall)
                                    .foregroundStyle(.white)
                                    .padding(.vertical, Spacing.sm)
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        RoundedRectangle(cornerRadius: 9)
                                            .fill(cardData.category.color)
                                    )
                            }
                        }
                    }
                    .transition(.opacity)
                }

                // ACTIVITY content (keyword matching)
                if isActivity {
                    ScrollView(.vertical, showsIndicators: false) {
                        activityPhaseView(cardData: cardData)
                    }
                    .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.4), value: isActivity)
        }
        .padding(Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(settings.dialogBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(cardData.category.color.opacity(0.4), lineWidth: 2)
        )
        .shadow(color: cardData.category.color.opacity(0.15), radius: 8, y: 3)
    }

    // MARK: - Highlighted Lesson Text (keywords colored by category)

    private func highlightedLessonText(cardData: ScienceCardData) -> Text {
        let lesson = cardData.lessonText
        let keywords = cardData.keywords.map { $0.keyword }
        let color = cardData.category.color

        // Build ranges of keyword matches
        var segments: [(String, Bool)] = [] // (text, isKeyword)
        var remaining = lesson

        while !remaining.isEmpty {
            // Find the earliest keyword match
            var earliestRange: Range<String.Index>? = nil

            for kw in keywords {
                if let range = remaining.range(of: kw, options: .caseInsensitive) {
                    if earliestRange == nil || range.lowerBound < earliestRange!.lowerBound {
                        earliestRange = range
                    }
                }
            }

            if let range = earliestRange {
                // Add text before the keyword
                let before = String(remaining[remaining.startIndex..<range.lowerBound])
                if !before.isEmpty {
                    segments.append((before, false))
                }
                // Add the keyword (use original casing from text)
                segments.append((String(remaining[range]), true))
                remaining = String(remaining[range.upperBound...])
            } else {
                // No more keywords found
                segments.append((remaining, false))
                remaining = ""
            }
        }

        // Build the styled Text
        var result = Text("")
        for (text, isKeyword) in segments {
            if isKeyword {
                result = result + Text(text)
                    .font(RenaissanceFont.buttonSmall)
                    .foregroundColor(color)
            } else {
                result = result + Text(text)
                    .font(RenaissanceFont.bodySmall)
                    .foregroundColor(settings.cardTextColor)
            }
        }

        return result
    }

    // MARK: - Activity Phase (Keyword Matching)

    private func activityPhaseView(cardData: ScienceCardData) -> some View {
        VStack(spacing: 10) {
            Text("Match each term to its meaning")
                .font(.custom("EBGaramond-Medium", size: 12))
                .foregroundStyle(settings.cardTextColor.opacity(0.6))

            // Keywords column
            VStack(spacing: 6) {
                ForEach(cardData.keywords) { pair in
                    let isMatched = matchedPairIDs.contains(pair.id)
                    let isSelected = selectedKeywordID == pair.id

                    Button {
                        if !isMatched { selectKeyword(pair.id, cardData: cardData) }
                    } label: {
                        HStack {
                            Image(systemName: isMatched ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 16))
                                .foregroundStyle(isMatched ? RenaissanceColors.sageGreen : cardData.category.color.opacity(0.4))

                            Text(pair.keyword)
                                .font(RenaissanceFont.buttonSmall)
                                .foregroundStyle(
                                    isMatched ? RenaissanceColors.sageGreen
                                    : isSelected ? cardData.category.color
                                    : settings.cardTextColor
                                )

                            Spacer()
                        }
                        .padding(.horizontal, Spacing.sm)
                        .padding(.vertical, Spacing.sm)
                        .background(
                            RoundedRectangle(cornerRadius: CornerRadius.sm)
                                .fill(
                                    isMatched ? RenaissanceColors.sageGreen.opacity(0.08)
                                    : isSelected ? cardData.category.color.opacity(0.12)
                                    : RenaissanceColors.ochre.opacity(0.04)
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: CornerRadius.sm)
                                .stroke(
                                    isSelected ? cardData.category.color.opacity(0.6) : Color.clear,
                                    lineWidth: 1.5
                                )
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(isMatched)
                    .opacity(isMatched ? 0.6 : 1)
                }
            }

            // Divider with arrow
            HStack {
                Rectangle()
                    .fill(settings.cardTextColor.opacity(0.1))
                    .frame(height: 1)
                Image(systemName: "arrow.down")
                    .font(.system(size: 11))
                    .foregroundStyle(settings.cardTextColor.opacity(0.25))
                Rectangle()
                    .fill(settings.cardTextColor.opacity(0.1))
                    .frame(height: 1)
            }

            // Definitions column (shuffled)
            VStack(spacing: 6) {
                ForEach(shuffledDefinitions) { pair in
                    let isMatched = matchedPairIDs.contains(pair.id)
                    let isSelected = selectedDefinitionID == pair.id
                    let isWrong = wrongMatchFlash && isSelected

                    Button {
                        if !isMatched { selectDefinition(pair.id, cardData: cardData) }
                    } label: {
                        HStack {
                            Text(pair.definition)
                                .font(RenaissanceFont.dialogSubtitle)
                                .foregroundStyle(
                                    isWrong ? RenaissanceColors.errorRed
                                    : isMatched ? RenaissanceColors.sageGreen
                                    : isSelected ? cardData.category.color
                                    : settings.cardTextColor.opacity(0.8)
                                )
                                .multilineTextAlignment(.leading)

                            Spacer()

                            if isMatched {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundStyle(RenaissanceColors.sageGreen)
                            }
                        }
                        .padding(.horizontal, Spacing.sm)
                        .padding(.vertical, Spacing.sm)
                        .background(
                            RoundedRectangle(cornerRadius: CornerRadius.sm)
                                .fill(
                                    isWrong ? RenaissanceColors.errorRed.opacity(0.08)
                                    : isMatched ? RenaissanceColors.sageGreen.opacity(0.08)
                                    : isSelected ? cardData.category.color.opacity(0.08)
                                    : RenaissanceColors.ochre.opacity(0.04)
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: CornerRadius.sm)
                                .stroke(
                                    isWrong ? RenaissanceColors.errorRed.opacity(0.5)
                                    : isSelected ? cardData.category.color.opacity(0.5)
                                    : Color.clear,
                                    lineWidth: 1.5
                                )
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(isMatched)
                    .opacity(isMatched ? 0.6 : 1)
                }
            }

            // Progress indicator
            let total = cardData.keywords.count
            let matched = matchedPairIDs.count
            HStack(spacing: 4) {
                ForEach(0..<total, id: \.self) { i in
                    Circle()
                        .fill(i < matched ? RenaissanceColors.sageGreen : settings.cardTextColor.opacity(0.15))
                        .frame(width: 8, height: 8)
                }
            }
        }
    }

    // MARK: - Keyword Matching Logic

    private func selectKeyword(_ id: UUID, cardData: ScienceCardData) {
        withAnimation(.easeOut(duration: 0.15)) {
            selectedKeywordID = id
        }
        // If a definition is already selected, try to match
        if let defID = selectedDefinitionID {
            tryMatch(keywordID: id, definitionID: defID, cardData: cardData)
        }
    }

    private func selectDefinition(_ id: UUID, cardData: ScienceCardData) {
        withAnimation(.easeOut(duration: 0.15)) {
            selectedDefinitionID = id
        }
        // If a keyword is already selected, try to match
        if let kwID = selectedKeywordID {
            tryMatch(keywordID: kwID, definitionID: id, cardData: cardData)
        }
    }

    private func tryMatch(keywordID: UUID, definitionID: UUID, cardData: ScienceCardData) {
        // Both IDs should refer to the same KeywordPair (keyword tapped = definition tapped)
        if keywordID == definitionID {
            // Correct match!
            SoundManager.shared.play(.correctChime)
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                matchedPairIDs.insert(keywordID)
                selectedKeywordID = nil
                selectedDefinitionID = nil
            }

            // Award florins
            let florins = GameRewards.scienceCardMatchFlorins
            viewModel?.earnFlorins(florins)

            // Show floating florins
            withAnimation(.spring(response: 0.3)) {
                earnedFlorinsFloat = florins
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeOut(duration: 0.3)) {
                    earnedFlorinsFloat = nil
                }
            }

            // Check if all pairs matched — card complete
            if matchedPairIDs.count == cardData.keywords.count {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    completeCard(cardData.category)
                }
            }
        } else {
            // Wrong match — flash red
            SoundManager.shared.play(.wrongBuzz)
            withAnimation(.easeOut(duration: 0.15)) {
                wrongMatchFlash = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeOut(duration: 0.15)) {
                    wrongMatchFlash = false
                    selectedKeywordID = nil
                    selectedDefinitionID = nil
                }
            }
        }
    }

    // MARK: - Card Actions

    /// User tapped "Done Reading" — fade to keyword matching on the same card
    private func openActivityForCard(_ category: ForestCardCategory) {
        if let cardData = scienceCards.first(where: { $0.category == category }) {
            shuffledDefinitions = cardData.keywords.shuffled()
            matchedPairIDs = []
            selectedKeywordID = nil
            selectedDefinitionID = nil
        }

        withAnimation(.easeInOut(duration: 0.4)) {
            activeCard = category
            cardPhases[category] = .activity
        }
    }

    /// Close the activity view and return to reading on the same card
    private func closeActiveCard() {
        if let category = activeCard {
            withAnimation(.easeInOut(duration: 0.4)) {
                cardPhases[category] = .reading
                activeCard = nil
            }
        }
    }

    /// Mark a card as completed — flip it back to front showing green checkmark
    private func completeCard(_ category: ForestCardCategory) {
        SoundManager.shared.play(.cardComplete)
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            cardPhases[category] = .completed
            completedCards.insert(category)
            activeCard = nil
        }
        // Flip the card back to show the completed front face
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
                flipAngles[category] = 0
                flippedOpenCard = nil
            }
        }
    }

    private func dismissScienceCards() {
        withAnimation(.easeOut(duration: 0.2)) {
            selectedPOIIndex = nil
            cardsAppeared = false
        }
        // Show bird guidance after cards dismiss
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showForestGuidance()
        }
    }

    // MARK: - Bird Encouragement

    private var birdEncouragement: some View {
        HStack(spacing: 10) {
            BirdCharacter(isSitting: true)
                .frame(width: 36, height: 36)

            let count = completedCards.count
            Text(count == 0 ? "Tap a card to learn about this tree!"
                 : count < 2 ? "\(2 - count) more card\(2 - count == 1 ? "" : "s") to unlock timber!"
                 : "Ready! Collect your timber below!")
                .font(RenaissanceFont.caption)
                .foregroundStyle(settings.cardTextColor.opacity(0.7))
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.xs)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(RenaissanceColors.ochre.opacity(0.06))
        )
    }

    // MARK: - Collect Timber Button (gated behind building knowledge card OR science cards)

    /// Check if timber collection is unlocked at this tree
    private func isTimberUnlocked(for poi: ForestScene.ForestPOI) -> Bool {
        // Require at least 1 science card completed to unlock timber
        return completedCards.count >= 1
    }

    private func collectTimberButton(poi: ForestScene.ForestPOI) -> some View {
        let unlocked = isTimberUnlocked(for: poi)
        let hasAxe = workshop.hasTool(for: .forest)

        return VStack(spacing: 6) {
            Button {
                if unlocked && hasAxe { collectTimber(from: poi) }
            } label: {
                HStack(spacing: 8) {
                    if !hasAxe {
                        Text("🪓")
                            .font(.body)
                        Text("Need an Axe to collect timber")
                            .font(RenaissanceFont.buttonSmall)
                    } else {
                        Image(systemName: unlocked ? "leaf.fill" : "lock.fill")
                            .font(.body)
                        Text(unlocked
                             ? "Collect Timber (+\(poi.timberYield) 🪵)"
                             : "Complete the cards to collect")
                            .font(RenaissanceFont.buttonSmall)
                    }
                }
                .foregroundStyle(.white)
                .padding(.vertical, 11)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(unlocked && hasAxe ? RenaissanceColors.ochre : RenaissanceColors.stoneGray.opacity(0.5))
                )
            }
            .disabled(!unlocked || !hasAxe)
            .scaleEffect(unlocked && hasAxe ? 1.0 : 0.97)
            .animation(.easeInOut(duration: 0.3), value: unlocked)

            Button {
                dismissScienceCards()
            } label: {
                Text("Continue Exploring")
                    .font(RenaissanceFont.caption)
                    .foregroundStyle(settings.cardTextColor.opacity(0.4))
            }
        }
    }

    // MARK: - Badges

    private func poiBadge(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.custom("EBGaramond-Medium", size: 11))
            .foregroundStyle(settings.cardTextColor)
            .padding(.horizontal, Spacing.xs)
            .padding(.vertical, 3)
            .background(
                Capsule()
                    .fill(color.opacity(0.12))
            )
    }

    // MARK: - Truffle Discovery Overlay — compact excitement card

    private func truffleDiscoveryOverlay(truffle: ForestScene.TruffleFind) -> some View {
        ZStack {
            RenaissanceColors.overlayDimming
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeOut(duration: 0.2)) {
                        discoveredTruffle = nil
                    }
                }

            VStack(spacing: 14) {
                Text("You found something!")
                    .font(.custom("Cinzel-Bold", size: 13))
                    .foregroundStyle(RenaissanceColors.ochre)
                    .tracking(Tracking.button)

                Text(truffle.name)
                    .font(.custom("Cinzel-Bold", size: 22))
                    .foregroundStyle(settings.cardTextColor)

                HStack(spacing: 8) {
                    Text(truffle.italianName)
                        .font(RenaissanceFont.dialogSubtitle)
                        .foregroundStyle(RenaissanceColors.warmBrown)

                    Text(truffle.rarity)
                        .font(.custom("EBGaramond-SemiBold", size: 11))
                        .foregroundStyle(truffle.rarity == "Rare" ? RenaissanceColors.goldSuccess : settings.cardTextColor)
                        .padding(.horizontal, Spacing.xs)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(truffle.rarity == "Rare"
                                      ? RenaissanceColors.goldSuccess.opacity(0.15)
                                      : RenaissanceColors.ochre.opacity(0.12))
                        )
                }

                Text(truffle.description)
                    .font(RenaissanceFont.dialogSubtitle)
                    .foregroundStyle(settings.cardTextColor.opacity(0.75))
                    .multilineTextAlignment(.center)
                    .lineLimit(3)

                HStack(alignment: .top, spacing: 10) {
                    BirdCharacter(isSitting: true)
                        .frame(width: 40, height: 40)

                    Text(birdTruffleAdvice(for: truffle))
                        .font(RenaissanceFont.caption)
                        .foregroundStyle(settings.cardTextColor.opacity(0.75))
                        .lineLimit(3)
                }
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(RenaissanceColors.ochre.opacity(0.05))
                )

                Button {
                    sellTruffle(truffle)
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.body)
                        Text("Sell at Market (+\(truffle.value) florins)")
                            .font(.custom("EBGaramond-SemiBold", size: 16))
                    }
                    .foregroundStyle(.white)
                    .padding(.vertical, Spacing.sm)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(RenaissanceColors.goldSuccess)
                    )
                }

                Button {
                    withAnimation(.easeOut(duration: 0.2)) {
                        discoveredTruffle = nil
                    }
                } label: {
                    Text("Keep Exploring")
                        .font(RenaissanceFont.dialogSubtitle)
                        .foregroundStyle(settings.cardTextColor.opacity(0.5))
                }
            }
            .padding(Spacing.lg)
            .adaptiveWidth(380)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.lg)
                    .fill(settings.dialogBackground)
            )
            .borderAccent(radius: 16)
        }
    }

    private func birdTruffleAdvice(for truffle: ForestScene.TruffleFind) -> String {
        switch truffle.rarity {
        case "Rare":
            return "A \(truffle.italianName)! Nobles paid fortunes for these — sell it for \(truffle.value) florins!"
        default:
            return "A truffle! Sell it at the market for \(truffle.value) florins. Not bad for something hiding in the dirt!"
        }
    }

    // MARK: - Truffle Sale

    private func sellTruffle(_ truffle: ForestScene.TruffleFind) {
        SoundManager.shared.play(.florinsEarned)
        viewModel?.earnFlorins(truffle.value)
        sceneHolder.scene?.playPlayerCelebrateAnimation()

        withAnimation(.easeOut(duration: 0.2)) {
            discoveredTruffle = nil
        }

        truffleSaleFlorins = truffle.value
        withAnimation(.spring(response: 0.4)) {
            showTruffleSaleFloat = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            withAnimation(.easeOut(duration: 0.3)) {
                showTruffleSaleFloat = false
            }
        }
    }

    // MARK: - Timber Collection

    private func collectTimber(from poi: ForestScene.ForestPOI) {
        var collected = 0
        for _ in 0..<poi.timberYield {
            if workshop.collectFromStation(.forest, material: .timber) {
                collected += 1
            }
        }

        let florinsEarned = collected * GameRewards.timberCollectFlorins
        if florinsEarned > 0 {
            SoundManager.shared.play(.timberChop)
            viewModel?.earnFlorins(florinsEarned)
            sceneHolder.scene?.playPlayerCelebrateAnimation()
        }

        // Auto-complete the next forest knowledge card for the active building
        // Each tree has 4 science cards — completing those + collecting timber earns credit
        if let vm = viewModel {
            let bid = vm.activeBuildingId ?? vm.buildingPlots.first(where: {
                !KnowledgeCardContent.cards(for: $0.building.name, in: .forest).isEmpty
            })?.id

            if let bid = bid {
                let buildingName = vm.buildingPlots.first(where: { $0.id == bid })?.building.name ?? ""
                let allForestCards = KnowledgeCardContent.cards(for: buildingName, in: .forest)
                let progress = vm.buildingProgressMap[bid] ?? BuildingProgress()

                // Complete the NEXT uncompleted forest card (any tree visit counts)
                if let nextCard = allForestCards.first(where: { !progress.completedCardIDs.contains($0.id) }) {
                    vm.markCardCompleted(for: bid, cardID: nextCard.id)
                    print("[FOREST] Auto-completed knowledge card '\(nextCard.id)' from \(poi.name) tree — science cards + timber earned it")
                }
            }
        }

        withAnimation(.easeOut(duration: 0.2)) {
            selectedPOIIndex = nil
            cardsAppeared = false
        }

        if collected > 0 {
            timberFloatAmount = collected
            timberFloatFlorins = florinsEarned
            withAnimation(.spring(response: 0.4)) {
                showTimberFloat = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeOut(duration: 0.3)) {
                    showTimberFloat = false
                }
                // Show guidance after timber float fades
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showForestGuidance()
                }
            }
        } else {
            // No timber collected (already maxed) — show guidance immediately
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showForestGuidance()
            }
        }
    }

    // MARK: - Navigation Panel

    private var navigationPanel: some View {
        Group {
            if let viewModel = viewModel {
                GameTopBarView(
                    title: "Italian Forest",
                    viewModel: viewModel,
                    onNavigate: { destination in
                        onNavigate?(destination)
                    },
                    showBackButton: true,
                    onBack: { onBackToWorkshop?() },
                    onBackToMenu: onBackToMenu,
                    onboardingState: onboardingState,
                    returnToLessonBuildingName: returnToLessonPlotId.flatMap { id in
                        viewModel.buildingPlots.first(where: { $0.id == id })?.building.name
                    },
                    onReturnToLesson: returnToLessonPlotId != nil ? {
                        onNavigate?(.cityMap)
                    } : nil,
                    currentDestination: .forest,
                    hideAvatarImage: !avatarInBox,
                    avatarDialogContent: forestDialogContent
                )
            } else {
                VStack(spacing: 8) {
                    Button { onBackToWorkshop?() } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                            Text("Workshop")
                        }
                        .font(.custom("EBGaramond-Regular", size: 16))
                        .foregroundStyle(settings.cardTextColor)
                        .padding(.horizontal, Spacing.md)
                        .padding(.vertical, Spacing.xs)
                        .glassButton(shape: Capsule())
                    }
                    Text("Italian Forest")
                        .font(RenaissanceFont.dialogTitle)
                        .foregroundStyle(settings.cardTextColor)
                        .padding(.horizontal, Spacing.lg)
                        .padding(.vertical, Spacing.xs)
                        .glassButton(shape: Capsule())
                }
            }
        }
    }

    // MARK: - Forest Dialog Content (passed into GameTopBarView avatar card)

    private var forestDialogContent: AnyView? {
        guard showToolDialog else { return nil }
        let hasAxe = workshop.hasTool(for: .forest)
        guard !hasAxe else {
            // Has axe — no dialog needed, science cards overlay handles it
            return nil
        }
        return AnyView(
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Text("🪓")
                        .font(.system(size: 28))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Need Axe")
                            .font(.custom("Cinzel-Bold", size: 15))
                            .foregroundStyle(settings.cardTextColor)
                        Text("l'Ascia")
                            .font(.custom("EBGaramond-Italic", size: 14))
                            .foregroundStyle(RenaissanceColors.warmBrown)
                    }
                }

                Text("Renaissance woodcutters used broad-headed axes forged by local blacksmiths. Each tree species required a different cutting angle.")
                    .font(.custom("EBGaramond-Regular", size: 14))
                    .foregroundStyle(settings.cardTextColor.opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)

                Button {
                    dismissToolDialog()
                    onBackToWorkshop?()
                } label: {
                    HStack(spacing: 5) {
                        Text("🏪")
                            .font(.subheadline)
                        Text("Go to Market")
                            .font(.custom("EBGaramond-SemiBold", size: 15))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: CornerRadius.sm)
                            .fill(RenaissanceColors.ochre)
                    )
                }

                Button {
                    dismissToolDialog()
                } label: {
                    Text("Close")
                        .font(.custom("EBGaramond-Regular", size: 13))
                        .foregroundStyle(settings.cardTextColor.opacity(0.4))
                        .frame(maxWidth: .infinity)
                }
            }
        )
    }

    private func dismissToolDialog() {
        withAnimation(.spring(response: 0.3)) {
            showToolDialog = false
        }
    }

    // MARK: - Inventory Bar

    private var inventoryBar: some View {
        FoldableInventoryBar(workshop: workshop)
    }

    // MARK: - Scene Setup

    private func makeScene() -> ForestScene {
        if let existing = sceneHolder.scene { return existing }

        let newScene = ForestScene()
        newScene.size = CGSize(width: 3500, height: 2500)
        newScene.scaleMode = .aspectFill
        newScene.apprenticeIsBoy = onboardingState?.apprenticeGender == .boy || onboardingState == nil

        newScene.onPlayerPositionChanged = { position, isWalking in
            playerPosition = position
            playerIsWalking = isWalking
        }

        newScene.onBackRequested = {
            onBackToWorkshop?()
        }

        newScene.onPlayerStartedWalking = {
            withAnimation(.easeOut(duration: 0.2)) {
                selectedPOIIndex = nil
                showToolDialog = false
            }
            GameCenterManager.shared.endCurrentActivity()
        }

        newScene.onPOISelected = { index in
            // Start forest activity when reaching a tree POI
            GameCenterManager.shared.startActivity(GameCenterManager.ActivityID.forest)
            let hasAxe = workshop.hasTool(for: .forest)
            if !hasAxe {
                // No axe — ONLY show tool requirement dialog, no science cards
                withAnimation(.spring(response: 0.3)) {
                    showToolDialog = true
                }
            } else {
                // Has axe — show science cards overlay
                withAnimation(.easeOut(duration: 0.25)) {
                    selectedPOIIndex = index
                }
            }
        }

        newScene.onTruffleFound = { truffle in
            pendingTruffle = truffle
        }

        sceneHolder.scene = newScene

        return newScene
    }

}

#Preview {
    ForestMapView(workshop: WorkshopState(), returnToLessonPlotId: .constant(nil))
}
