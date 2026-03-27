import SwiftUI
import SpriteKit
// Audio via SoundManager

/// SwiftUI wrapper for the WorkshopScene SpriteKit mini-game
/// Layers: SpriteKit scene → companion overlay → UI bars → hint/collection/crafting overlays
struct WorkshopMapView: View {

    @Bindable var workshop: WorkshopState
    var viewModel: CityViewModel? = nil
    var notebookState: NotebookState? = nil
    var onNavigate: ((SidebarDestination) -> Void)? = nil
    var onBackToMenu: (() -> Void)? = nil
    var onEnterInterior: (() -> Void)? = nil
    var onEnterGoldsmith: (() -> Void)? = nil
    var onboardingState: OnboardingState? = nil
    @Binding var returnToLessonPlotId: Int?

    @Environment(\.dismiss) private var dismiss
    @Environment(\.gameSettings) private var settings
    @Environment(\.horizontalSizeClass) private var sizeClass
    private var isLargeScreen: Bool { sizeClass == .regular }

    // Scene reference — stored in a class box so it survives body re-evaluation
    // without triggering re-renders (unlike @State which causes infinite loops)
    @State private var sceneHolder = SceneHolder<WorkshopScene>()

    // Player tracking
    @State private var playerPosition: CGPoint = CGPoint(x: 0.5, y: 0.5)
    @State private var playerIsWalking = false

    // Station lesson overlay
    @State private var showStationLesson = false
    @State private var pendingLessonStation: ResourceStationType?

    // Overlay states
    @State private var activeStation: ResourceStationType?
    @State private var showHintBubble = false
    @State private var showCollectionOverlay = false
    @State private var showWorkbenchOverlay = false
    @State private var showFurnaceOverlay = false

    // Knowledge cards at workshop stations
    @State private var showStationKnowledgeCards = false
    @State private var stationKnowledgeCards: [KnowledgeCard] = []

    // Discovery card (no active building)
    @State private var showDiscoveryCard = false
    @State private var discoveryCard: DiscoveryCard? = nil

    // After knowledge card dismissed, proceed to tool check / mini-game for this station
    @State private var pendingStationAfterCard: ResourceStationType?
    // Skip knowledge card when player is sent to market via "Go to Market" button
    @State private var skipCardForMarket = false
    // Track which station sent player to market — so bird guides BACK there after buying tool
    @State private var returnToStationAfterMarket: ResourceStationType?

    // Station mini-games
    @State private var showQuarryMiniGame = false
    @State private var showVolcanoMiniGame = false
    @State private var showRiverMiniGame = false
    @State private var showClayPitMiniGame = false
    @State private var showFarmMiniGame = false

    // Avatar box: portrait visible only when player hasn't moved yet
    @State private var avatarInBox = true

    // Bird guidance — tells player where to go next
    @State private var showArrivalGuidance = false
    @State private var guidanceMessage: String = ""
    @State private var guidanceDestination: SidebarDestination? = nil  // nil = stay in workshop
    @State private var guidanceStationType: ResourceStationType? = nil  // station to walk to
    // Stations player has collected from since last non-station activity
    // Resets when player does a card, navigates to another env, or buys a tool
    @State private var recentlyCollectedStations: Set<ResourceStationType> = []

    // Job system states
    @State private var jobBoardChoices: [WorkshopJob] = []
    @State private var completedJob: WorkshopJob?
    @State private var jobRewardFlorins: Int = 0
    @State private var jobStreakBonus: Int = 0

    // NPC encounter (Foundation Models — iOS 26+)
    @State private var showNPCEncounter = false
    @State private var npcDisplayData: NPCDisplayData?
    @State private var npcPortrait: CGImage?

    @ObservedObject private var assetManager = AssetManager.shared

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Layer 1: SpriteKit scene (wait for ODR on iOS)
                if assetManager.isReady(AssetManager.workshopScene) {
                    GameSpriteView(scene: makeScene(), options: [.allowsTransparency])
                        .ignoresSafeArea()
                } else {
                    ODRLoadingView(tag: AssetManager.workshopScene, message: "Preparing the workshop...")
                }

                // Layer 2: Station lesson overlay (bird teaches before first collection)
                if showStationLesson, let station = pendingLessonStation,
                   let lesson = OnboardingContent.lesson(for: station) {
                    StationLessonOverlay(lesson: lesson) {
                        withAnimation(.spring(response: 0.3)) {
                            showStationLesson = false
                            workshop.stationsLessonSeen.insert(station)
                        }

                        // Save bird station lesson to notebooks of matching buildings
                        if let ns = notebookState, let vm = viewModel,
                           !ns.isStationLessonAdded(station.rawValue) {
                            let results = NotebookContent.entriesFromStationLesson(lesson, buildings: vm.buildingPlots)
                            for (bid, bname, entry) in results {
                                ns.addEntries([entry], buildingId: bid, buildingName: bname)
                            }
                            ns.markStationLessonAdded(station.rawValue)
                        }

                        if station == .forest {
                            // Navigate directly to the forest
                            activeStation = nil
                            onNavigate?(.forest)
                        } else if station == .craftingRoom {
                            // Enter crafting room after lesson
                            activeStation = nil
                            if let onEnterInterior = onEnterInterior {
                                onEnterInterior()
                            }
                        } else {
                            // Single overlay: tool requirement OR hint+collection
                            showSingleStationOverlay()
                        }
                    }
                    .transition(.opacity)
                }

                // Layer 3: Nav (left) + Buildings (right) with margins — same as city map
                VStack(spacing: 0) {
                    navigationPanel
                        .frame(maxWidth: .infinity)
                    Spacer()
                    inventoryBar
                }
                .frame(maxWidth: .infinity)
                .padding(Spacing.md)

                // Status message overlay
                if let status = workshop.statusMessage {
                    VStack {
                        Text(status)
                            .font(RenaissanceFont.dialogSubtitle)
                            .foregroundStyle(RenaissanceColors.sepiaInk)
                            .padding(.horizontal, Spacing.sm)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(RenaissanceColors.parchment.opacity(0.95))
                            )
                        Spacer()
                    }
                    .padding(.top, Spacing.xs)
                    .allowsHitTesting(false)
                }

                // Bird guidance — tells player where to go next
                if showArrivalGuidance {
                    VStack {
                        Spacer()
                        HStack(alignment: .top, spacing: 10) {
                            BirdCharacter(isSitting: true)
                                .frame(width: 44, height: 44)
                            VStack(alignment: .leading, spacing: 6) {
                                Text(guidanceMessage)
                                    .font(.custom("Cinzel-Bold", size: 14))
                                    .foregroundStyle(RenaissanceColors.sepiaInk)
                                    .fixedSize(horizontal: false, vertical: true)
                                if let vm = viewModel, let bid = vm.activeBuildingId {
                                    let progress = vm.cardProgress(for: bid)
                                    Text("\(progress.completed)/\(progress.total) cards collected")
                                        .font(RenaissanceFont.caption)
                                        .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.5))
                                }

                                HStack(spacing: 8) {
                                    // "Go to Station" button — walks player to the suggested station
                                    if let station = guidanceStationType {
                                        Button {
                                            withAnimation(.easeOut(duration: 0.2)) { showArrivalGuidance = false }
                                            sceneHolder.scene?.walkToStation(station)
                                        } label: {
                                            HStack(spacing: 5) {
                                                Image(systemName: "figure.walk")
                                                    .font(.system(size: 12))
                                                Text("Go!")
                                                    .font(.custom("EBGaramond-SemiBold", size: 14))
                                            }
                                            .foregroundStyle(.white)
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 6)
                                            .background(Capsule().fill(RenaissanceColors.warmBrown))
                                        }
                                        .buttonStyle(.plain)
                                    }

                                    // "Go!" button if guidance points to another environment
                                    if let dest = guidanceDestination, onNavigate != nil {
                                        Button {
                                            withAnimation(.easeOut(duration: 0.2)) { showArrivalGuidance = false }
                                            onNavigate?(dest)
                                        } label: {
                                            HStack(spacing: 5) {
                                                Image(systemName: dest == .forest ? "tree.fill" : dest == .cityMap ? "building.columns.fill" : "hammer.fill")
                                                    .font(.system(size: 12))
                                                Text("Go!")
                                                    .font(.custom("EBGaramond-SemiBold", size: 14))
                                            }
                                            .foregroundStyle(.white)
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 6)
                                            .background(Capsule().fill(RenaissanceColors.renaissanceBlue))
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                            Spacer()
                            Button {
                                withAnimation(.easeOut(duration: 0.3)) { showArrivalGuidance = false }
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.4))
                                    .padding(6)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(Spacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: CornerRadius.md)
                                .fill(RenaissanceColors.parchment.opacity(0.95))
                                .shadow(color: .black.opacity(0.1), radius: 6, y: 2)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: CornerRadius.md)
                                .stroke(RenaissanceColors.renaissanceBlue.opacity(0.2), lineWidth: 1)
                        )
                        .padding(.horizontal, Spacing.lg)
                        .padding(.bottom, 90) // above inventory bar
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                // (dialog is now inside GameTopBarView's avatar card)

                // Layer 6: Workbench overlay (mixing slots + recipe)
                if showWorkbenchOverlay {
                    workbenchOverlay
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                // Layer 7: Furnace overlay (temperature + fire)
                if showFurnaceOverlay {
                    furnaceOverlay
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                // Layer 8: Knowledge cards at workshop stations
                if showStationKnowledgeCards, !stationKnowledgeCards.isEmpty, let vm = viewModel, let bid = vm.activeBuildingId {
                    KnowledgeCardsOverlay(
                        cards: stationKnowledgeCards,
                        buildingId: bid,
                        viewModel: vm,
                        notebookState: notebookState,
                        onDismiss: {
                            withAnimation {
                                showStationKnowledgeCards = false
                                stationKnowledgeCards = []
                            }
                            // After card dismissed, proceed to tool check / mini-game
                            if let pending = pendingStationAfterCard {
                                pendingStationAfterCard = nil
                                activeStation = pending
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    showSingleStationOverlay()
                                }
                            } else {
                                activeStation = nil
                            }
                        },
                        onNavigate: { destination in
                            withAnimation {
                                showStationKnowledgeCards = false
                                stationKnowledgeCards = []
                                activeStation = nil
                            }
                            pendingStationAfterCard = nil
                            onNavigate?(destination)
                        },
                        playerName: onboardingState?.apprenticeName ?? "Apprentice",
                        triggerBirdChat: .constant(false),
                        workshopState: workshop,
                        currentStation: activeStation
                    )
                    .transition(.opacity)
                }

                // Layer 8b: Discovery card (no active building)
                if showDiscoveryCard, let card = discoveryCard {
                    DiscoveryCardOverlay(
                        card: card,
                        onDismiss: {
                            withAnimation {
                                showDiscoveryCard = false
                                discoveryCard = nil
                            }
                            // After dismissing discovery, show normal station overlay
                            if let pending = pendingStationAfterCard {
                                pendingStationAfterCard = nil
                                activeStation = pending
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    showSingleStationOverlay()
                                }
                            }
                        },
                        onChooseBuilding: {
                            withAnimation {
                                showDiscoveryCard = false
                                discoveryCard = nil
                                activeStation = nil
                            }
                            pendingStationAfterCard = nil
                            onNavigate?(.cityMap)
                        },
                        playerName: onboardingState?.apprenticeName ?? "Apprentice"
                    )
                    .transition(.opacity)
                }

                // Layer 8c: NPC encounter (Foundation Models — iOS 26+)
                if showNPCEncounter, let npc = npcDisplayData {
                    NPCDialogueView(
                        npc: npc,
                        portrait: npcPortrait,
                        stationName: activeStation?.rawValue ?? "Workshop"
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            showNPCEncounter = false
                            npcDisplayData = nil
                            npcPortrait = nil
                        }
                        // Continue with normal guidance after NPC dismissed
                        showNextGuidance(forceRefresh: true)
                    }
                    .transition(.opacity)
                }

                // Layer 9: Quarry mini-game
                if showQuarryMiniGame {
                    QuarryMiniGameView(
                        onComplete: { material, bonusFlorins in
                            workshop.rawMaterials[material, default: 0] += 1
                            viewModel?.goldFlorins += bonusFlorins
                            sceneHolder.scene?.playPlayerCelebrateAnimation()
                            sceneHolder.scene?.showCollectionEffect(at: .quarry)
                            recentlyCollectedStations.insert(.quarry)

                            if workshop.currentJob != nil && workshop.currentJob?.craftTarget == nil {
                                if workshop.checkJobCompletion() {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        withAnimation(.spring(response: 0.3)) {
                                            showQuarryMiniGame = false
                                            activeStation = nil
                                        }
                                        completeCurrentJob()
                                    }
                                    return
                                }
                            }

                            withAnimation {
                                showQuarryMiniGame = false
                                activeStation = nil
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                showNextGuidance(forceRefresh: true)
                            }
                        },
                        onDismiss: {
                            withAnimation {
                                showQuarryMiniGame = false
                                activeStation = nil
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                showNextGuidance(forceRefresh: true)
                            }
                        },
                        onNudgeCamera: {
                            sceneHolder.scene?.nudgeCameraUp(by: 0.2)
                        }
                    )
                    .transition(.opacity)
                }

                // Layer 10: Volcano mini-game
                if showVolcanoMiniGame {
                    VolcanoMiniGameView(
                        onComplete: { material, bonusFlorins in
                            workshop.rawMaterials[material, default: 0] += 1
                            viewModel?.goldFlorins += bonusFlorins
                            sceneHolder.scene?.playPlayerCelebrateAnimation()
                            sceneHolder.scene?.showCollectionEffect(at: .volcano)
                            recentlyCollectedStations.insert(.volcano)

                            if workshop.currentJob != nil && workshop.currentJob?.craftTarget == nil {
                                if workshop.checkJobCompletion() {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        withAnimation(.spring(response: 0.3)) {
                                            showVolcanoMiniGame = false
                                            activeStation = nil
                                        }
                                        completeCurrentJob()
                                    }
                                    return
                                }
                            }

                            withAnimation {
                                showVolcanoMiniGame = false
                                activeStation = nil
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                showNextGuidance(forceRefresh: true)
                            }
                        },
                        onDismiss: {
                            withAnimation {
                                showVolcanoMiniGame = false
                                activeStation = nil
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                showNextGuidance(forceRefresh: true)
                            }
                        },
                        onNudgeCamera: {
                            sceneHolder.scene?.nudgeCameraUp(by: 0.2)
                        }
                    )
                    .transition(.opacity)
                }

                // Layer 11: River mini-game
                if showRiverMiniGame {
                    RiverMiniGameView(
                        onComplete: { material, bonusFlorins in
                            workshop.rawMaterials[material, default: 0] += 1
                            viewModel?.goldFlorins += bonusFlorins
                            sceneHolder.scene?.playPlayerCelebrateAnimation()
                            sceneHolder.scene?.showCollectionEffect(at: .river)
                            recentlyCollectedStations.insert(.river)

                            if workshop.currentJob != nil && workshop.currentJob?.craftTarget == nil {
                                if workshop.checkJobCompletion() {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        withAnimation(.spring(response: 0.3)) {
                                            showRiverMiniGame = false
                                            activeStation = nil
                                        }
                                        completeCurrentJob()
                                    }
                                    return
                                }
                            }

                            withAnimation {
                                showRiverMiniGame = false
                                activeStation = nil
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                showNextGuidance(forceRefresh: true)
                            }
                        },
                        onDismiss: {
                            withAnimation {
                                showRiverMiniGame = false
                                activeStation = nil
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                showNextGuidance(forceRefresh: true)
                            }
                        },
                        onNudgeCamera: {
                            sceneHolder.scene?.nudgeCameraUp(by: 0.2)
                        }
                    )
                    .transition(.opacity)
                }

                // Layer 12: Clay Pit mini-game
                if showClayPitMiniGame {
                    ClayPitMiniGameView(
                        onComplete: { material, bonusFlorins in
                            workshop.rawMaterials[material, default: 0] += 1
                            viewModel?.goldFlorins += bonusFlorins
                            sceneHolder.scene?.playPlayerCelebrateAnimation()
                            sceneHolder.scene?.showCollectionEffect(at: .clayPit)
                            recentlyCollectedStations.insert(.clayPit)

                            if workshop.currentJob != nil && workshop.currentJob?.craftTarget == nil {
                                if workshop.checkJobCompletion() {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        withAnimation(.spring(response: 0.3)) {
                                            showClayPitMiniGame = false
                                            activeStation = nil
                                        }
                                        completeCurrentJob()
                                    }
                                    return
                                }
                            }

                            withAnimation {
                                showClayPitMiniGame = false
                                activeStation = nil
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                showNextGuidance(forceRefresh: true)
                            }
                        },
                        onDismiss: {
                            withAnimation {
                                showClayPitMiniGame = false
                                activeStation = nil
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                showNextGuidance(forceRefresh: true)
                            }
                        },
                        onNudgeCamera: {
                            sceneHolder.scene?.nudgeCameraUp(by: 0.2)
                        }
                    )
                    .transition(.opacity)
                }

                // Layer 13: Farm mini-game
                if showFarmMiniGame {
                    FarmMiniGameView(
                        onComplete: { material, bonusFlorins in
                            workshop.rawMaterials[material, default: 0] += 1
                            viewModel?.goldFlorins += bonusFlorins
                            sceneHolder.scene?.playPlayerCelebrateAnimation()
                            sceneHolder.scene?.showCollectionEffect(at: .farm)
                            recentlyCollectedStations.insert(.farm)

                            if workshop.currentJob != nil && workshop.currentJob?.craftTarget == nil {
                                if workshop.checkJobCompletion() {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        withAnimation(.spring(response: 0.3)) {
                                            showFarmMiniGame = false
                                            activeStation = nil
                                        }
                                        completeCurrentJob()
                                    }
                                    return
                                }
                            }

                            withAnimation {
                                showFarmMiniGame = false
                                activeStation = nil
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                showNextGuidance(forceRefresh: true)
                            }
                        },
                        onDismiss: {
                            withAnimation {
                                showFarmMiniGame = false
                                activeStation = nil
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                showNextGuidance(forceRefresh: true)
                            }
                        },
                        onNudgeCamera: {
                            sceneHolder.scene?.nudgeCameraUp(by: 0.2)
                        }
                    )
                    .transition(.opacity)
                }

                // Educational popup
                if workshop.showEducationalPopup {
                    educationalOverlay
                        .transition(.opacity.combined(with: .scale(scale: 0.9)))
                }

                // (Earn Florins overlay removed — bird guidance handles this now)

                // Bottega job progress card (replaces master task card when job active)
                if let job = workshop.currentJob,

                   !showCollectionOverlay,
                   !showHintBubble,
                   !showWorkbenchOverlay,
                   !showFurnaceOverlay,
                   !workshop.showEducationalPopup,
                   !workshop.showJobBoard,
                   !workshop.showJobComplete {
                    jobProgressCard(job: job)
                }

                // Master's Task floating card (only when no active job)
                if workshop.currentJob == nil,
                   let assignment = workshop.currentAssignment,

                   !showCollectionOverlay,
                   !showHintBubble,
                   !showWorkbenchOverlay,
                   !showFurnaceOverlay,
                   !workshop.showEducationalPopup,
                   !workshop.showJobBoard,
                   !workshop.showJobComplete {
                    masterTaskCard(assignment: assignment)
                }

                // Job Board overlay (3 job choices)
                if workshop.showJobBoard {
                    jobBoardOverlay
                        .transition(.opacity.combined(with: .scale(scale: 0.9)))
                }

                // Job Complete celebration overlay
                if workshop.showJobComplete, let lastJob = completedJob {
                    jobCompleteOverlay(job: lastJob)
                        .transition(.opacity.combined(with: .scale(scale: 0.9)))
                }
            }
        }
        .task {
            await AssetManager.shared.requestAssets(tag: AssetManager.workshopScene)
            AssetManager.shared.prefetchAssets(tag: AssetManager.craftingRoom)
            AssetManager.shared.prefetchAssets(tag: AssetManager.forestScene)
        }
        .onAppear {
            recentlyCollectedStations.removeAll()
            if workshop.currentAssignment == nil {
                workshop.generateNewAssignment()
            }
            // Show bird guidance if player has an active building with workshop cards
            checkArrivalGuidance()
        }
        .onDisappear {
            // Release scene to free SpriteKit texture memory when navigating away
            sceneHolder.scene = nil
        }
        .onChange(of: activeStation) { oldValue, newValue in
            if oldValue != nil && newValue == nil {
                // Station overlay dismissed — show guidance (player stays where they are)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showNextGuidance()
                }
            }
        }
        .onChange(of: playerIsWalking) { _, isWalking in
            if isWalking && avatarInBox {
                // Hide the SwiftUI sprite image — SpriteKit player walks from same spot
                avatarInBox = false
            }
            if isWalking && showArrivalGuidance {
                withAnimation(.easeOut(duration: 0.2)) { showArrivalGuidance = false }
            }
        }
    }

    // MARK: - Scene Creation

    private func makeScene() -> WorkshopScene {
        if let existing = sceneHolder.scene { return existing }

        let newScene = WorkshopScene()
        newScene.size = CGSize(width: 3500, height: 2500)
        newScene.scaleMode = .aspectFill
        newScene.apprenticeIsBoy = onboardingState?.apprenticeGender == .boy || onboardingState == nil

        // Player position updates
        newScene.onPlayerPositionChanged = { position, isWalking in
            self.playerPosition = position
            self.playerIsWalking = isWalking
        }

        // Dismiss all overlays when player starts walking to a new station
        newScene.onPlayerStartedWalking = {
            withAnimation(.easeOut(duration: 0.2)) {
                dismissAllOverlays()
                showStationKnowledgeCards = false
                stationKnowledgeCards = []
            }
        }


        // Station reached — show knowledge card first, then tool check / mini-game
        newScene.onStationReached = { stationType in
            self.activeStation = stationType
            dismissAllOverlays()

            switch stationType {
            case .craftingRoom:
                // Transition to interior crafting room
                if let onEnterInterior = onEnterInterior {
                    onEnterInterior()
                } else {
                    withAnimation(.spring(response: 0.3)) {
                        showWorkbenchOverlay = true
                    }
                }
            case .goldsmithWorkshop:
                // Transition to goldsmith workshop interior
                if let onEnterGoldsmith = onEnterGoldsmith {
                    onEnterGoldsmith()
                }
            case .forest:
                // Navigate to forest scene
                activeStation = nil
                onNavigate?(.forest)
            default:
                // Skip card if player was sent to market (skip for market) or sent BACK to collect (returnToStation)
                let sentToCollect = (returnToStationAfterMarket == stationType && workshop.hasTool(for: stationType))
                if skipCardForMarket && stationType == .market {
                    skipCardForMarket = false
                    showSingleStationOverlay()
                } else if sentToCollect {
                    // Player was sent back to collect materials — go straight to mini-game
                    returnToStationAfterMarket = nil
                    showSingleStationOverlay()
                } else if hasKnowledgeCard(at: stationType) {
                    // Show card first, then proceed to tool/minigame after card is dismissed
                    pendingStationAfterCard = stationType
                    showKnowledgeCardForStation(stationType)
                } else {
                    showSingleStationOverlay()
                }
            }
        }

        // @State cannot be set during body — defer to next runloop
        sceneHolder.scene = newScene
        return newScene
    }


    /// Show bird guidance following phase-based progression.
    /// forceRefresh: bypasses overlay guards (used after buying tools at market)
    private func showNextGuidance(forceRefresh: Bool = false) {
        guard let vm = viewModel else { return }
        // Don't show if another overlay is active (unless force-refreshing after tool purchase)
        if !forceRefresh {
            guard !showCollectionOverlay && !showHintBubble && !showWorkbenchOverlay
                    && !showFurnaceOverlay && !showStationKnowledgeCards else { return }
        }

        let florins = vm.goldFlorins
        let toolCost = GameRewards.toolBuyBaseCost

        // Get building context
        let bid = vm.activeBuildingId
        let buildingName: String = {
            guard let bid = bid else { return "" }
            return vm.buildingPlots.first(where: { $0.id == bid })?.building.name ?? ""
        }()
        let progress = bid.flatMap { vm.buildingProgressMap[$0] } ?? BuildingProgress()
        let building = bid.flatMap { id in vm.buildingPlots.first(where: { $0.id == id })?.building }

        // Phase-based: check if player should be in the workshop at all
        let phase = progress.currentPhase(for: buildingName, workshopState: workshop, craftedMaterials: workshop.craftedMaterials)

        // Reset station guidance each time
        guidanceStationType = nil

        // If not in COLLECT phase, guide player to the correct environment
        if phase != .collect {
            // Special case: phase says "explore" but player may already have enough timber
            // The phase gets stuck on .explore because forest knowledge cards can't be completed
            // in the current system. Check timber directly instead.
            if phase == .explore {
                let timberCount = workshop.rawMaterials[.timber] ?? 0
                let needsTimber = building?.requiredMaterials[.timberBeams] != nil
                let hasTimberBeams = (workshop.craftedMaterials[.timberBeams] ?? 0) >= 1
                if !needsTimber || hasTimberBeams || timberCount >= 3 {
                    // Player has enough timber or doesn't need it — skip forest, continue with workshop/crafting
                    // Fall through to COLLECT phase logic below
                } else {
                    guidanceMessage = "Explore the Forest — collect timber for the \(buildingName)! (\(timberCount)/3 timber)"
                    guidanceDestination = .forest
                    withAnimation(.spring(response: 0.4)) { showArrivalGuidance = true }
                    return
                }
            } else {
                switch phase {
                case .learn:
                    guidanceMessage = "Head to the City Map first — learn about the \(buildingName)!"
                    guidanceDestination = .cityMap
                case .craft:
                    guidanceMessage = "Time for the Crafting Room — transform your materials for the \(buildingName)!"
                    guidanceDestination = nil
                    guidanceStationType = .craftingRoom
                case .build:
                    // Safety: check if materials are actually ready before sending to city
                    let required = Building.requiredCraftedItems(for: buildingName)
                    let allCrafted = required.allSatisfy { item, needed in
                        (workshop.craftedMaterials[item] ?? 0) >= needed
                    }
                    if allCrafted {
                        guidanceMessage = "All done for the \(buildingName)! Head to the City Map to build!"
                        guidanceDestination = .cityMap
                    } else {
                        // Materials still missing — guide to crafting room, don't loop back to city
                        guidanceMessage = "Time for the Crafting Room — craft the remaining materials for the \(buildingName)!"
                        guidanceDestination = nil
                        guidanceStationType = .craftingRoom
                    }
                default:
                    break
                }
                withAnimation(.spring(response: 0.4)) { showArrivalGuidance = true }
                return
            }
        }

        // ── COLLECT PHASE: Workshop-specific guidance ──

        // Compute what raw materials the building still needs
        let neededRaw = rawMaterialsStillNeeded(for: building)
        // Which stations provide needed materials
        let stationsWithNeededMaterials = stationsForNeededMaterials(neededRaw)

        // PRIORITY 1: Player just bought a tool — guide them BACK to the station they came from
        if let returnStation = returnToStationAfterMarket, workshop.hasTool(for: returnStation) {
            let toolName = Tool.requiredFor(station: returnStation)?.displayName ?? "tool"
            guidanceMessage = "You got your \(toolName)! Head back to the \(returnStation.label) to collect materials!"
            guidanceDestination = nil
            guidanceStationType = returnStation
            returnToStationAfterMarket = nil
            withAnimation(.spring(response: 0.4)) { showArrivalGuidance = true }
            return
        }

        // PRIORITY 2: Can craft a recipe the building needs — go to Crafting Room!
        if let building = building {
            if let craftable = nextCraftableRecipe(for: building) {
                guidanceMessage = "You have the materials to craft \(craftable.output.rawValue)! Head to the Crafting Room!"
                guidanceDestination = nil
                guidanceStationType = .craftingRoom
                recentlyCollectedStations.removeAll()
                withAnimation(.spring(response: 0.4)) { showArrivalGuidance = true }
                return
            }
        }

        // Categorize stations
        let allReadyStations = stationsWithNeededMaterials.filter { workshop.hasTool(for: $0) }
        let freshStations = allReadyStations.filter { !recentlyCollectedStations.contains($0) }
        let needToolStations = stationsWithNeededMaterials.filter { station in
            !workshop.hasTool(for: station) && Tool.requiredFor(station: station) != nil
        }

        // Uncompleted workshop knowledge cards — ONLY at affordable stations
        let workshopCards: [KnowledgeCard] = {
            guard !buildingName.isEmpty else { return [] }
            let cards = KnowledgeCardContent.cards(for: buildingName, in: .workshop)
            return cards.filter { card in
                guard !progress.completedCardIDs.contains(card.id) else { return false }
                if let stationType = stationTypeFromKey(card.stationKey) {
                    if !workshop.hasTool(for: stationType) && florins < toolCost {
                        return false
                    }
                }
                return true
            }
        }()

        // PRIORITY 3: Fresh station (not recently visited) with needed materials
        if let station = freshStations.first {
            let stationMats = station.materials
            if let needed = stationMats.first(where: { neededRaw[$0, default: 0] > 0 }) {
                let progressHint = materialProgressHint(needed, neededRaw: neededRaw, building: building)
                guidanceMessage = "Head to the \(station.label) — you need \(needed.rawValue)\(progressHint) for the \(buildingName)!"
                guidanceDestination = nil
                guidanceStationType = station
                withAnimation(.spring(response: 0.4)) { showArrivalGuidance = true }
                return
            }
        }

        // PRIORITY 4: Need a tool + can afford — BUY IT before re-cycling old stations!
        if let station = needToolStations.first, let tool = Tool.requiredFor(station: station), florins >= toolCost {
            returnToStationAfterMarket = station
            let stationMats = station.materials
            let neededMat = stationMats.first(where: { neededRaw[$0, default: 0] > 0 })?.rawValue ?? "materials"
            guidanceMessage = "Buy a \(tool.displayName) at the Market (\(toolCost) florins) — the \(station.label) has \(neededMat) you need!"
            guidanceDestination = nil
            guidanceStationType = .market
            recentlyCollectedStations.removeAll()
            withAnimation(.spring(response: 0.4)) { showArrivalGuidance = true }
            return
        }

        // PRIORITY 5: Workshop knowledge cards (learn + earn florins toward tools)
        if let card = workshopCards.first {
            guidanceMessage = "Head to the \(card.stationKey.capitalized) — discover a knowledge card about the \(buildingName)!"
            guidanceDestination = nil
            guidanceStationType = stationTypeFromKey(card.stationKey)
            withAnimation(.spring(response: 0.4)) { showArrivalGuidance = true }
            return
        }

        // PRIORITY 6: Need tools but can't afford — tell player HOW to earn florins
        if let station = needToolStations.first, let tool = Tool.requiredFor(station: station), florins < toolCost {
            guidanceMessage = "You need \(toolCost) florins for a \(tool.displayName) (you have \(florins)). Explore the City Map or Forest to earn more!"
            guidanceDestination = .cityMap
            withAnimation(.spring(response: 0.4)) { showArrivalGuidance = true }
            return
        }

        // PRIORITY 7: All stations visited — cycle back with progress info
        if !allReadyStations.isEmpty {
            recentlyCollectedStations.removeAll()
            // Count total materials still needed across all stations
            let totalNeeded = neededRaw.values.reduce(0, +)
            if let station = allReadyStations.first {
                let stationMats = station.materials
                if let needed = stationMats.first(where: { neededRaw[$0, default: 0] > 0 }) {
                    let progressHint = materialProgressHint(needed, neededRaw: neededRaw, building: building)
                    if allReadyStations.count == 1 && totalNeeded <= 3 {
                        guidanceMessage = "Almost there! \(neededRaw[needed, default: 0]) more \(needed.rawValue) to go!"
                    } else {
                        guidanceMessage = "Back to the \(station.label) — \(needed.rawValue)\(progressHint) still needed!"
                    }
                    guidanceDestination = nil
                    guidanceStationType = station
                    withAnimation(.spring(response: 0.4)) { showArrivalGuidance = true }
                    return
                }
            }
        }

        // PRIORITY 8: Uncompleted crafting room cards needing tools (e.g., pigment table needs mortar & pestle)
        if !buildingName.isEmpty {
            let craftingCards = KnowledgeCardContent.cards(for: buildingName, in: .craftingRoom)
            let uncompletedCrafting = craftingCards.filter { !progress.completedCardIDs.contains($0.id) }
            if !uncompletedCrafting.isEmpty {
                let hasMortar = (workshop.tools[.mortarAndPestle] ?? 0) > 0
                if uncompletedCrafting.contains(where: { $0.stationKey == "pigmentTable" }) && !hasMortar {
                    if florins >= toolCost {
                        guidanceMessage = "Buy a Mortar & Pestle at the Market (10 florins) — you need it for the Pigment Table in the Crafting Room!"
                        guidanceDestination = nil
                        guidanceStationType = .market
                        withAnimation(.spring(response: 0.4)) { showArrivalGuidance = true }
                        return
                    }
                } else {
                    guidanceMessage = "Head to the Crafting Room — a knowledge card awaits at the \(uncompletedCrafting.first?.stationKey.capitalized ?? "station")!"
                    guidanceDestination = nil
                    guidanceStationType = .craftingRoom
                    withAnimation(.spring(response: 0.4)) { showArrivalGuidance = true }
                    return
                }
            }
        }

        // Default
        guidanceMessage = "Explore the workshop — collect materials and learn about building!"
        guidanceDestination = nil
        withAnimation(.spring(response: 0.4)) {
            showArrivalGuidance = true
        }
    }

    // MARK: - Building-Aware Guidance Helpers

    /// Compute raw materials the active building still needs (accounting for what's already collected and crafted)
    private func rawMaterialsStillNeeded(for building: Building?) -> [Material: Int] {
        guard let building = building else { return [:] }
        var needed: [Material: Int] = [:]
        for (craftedItem, qty) in building.requiredMaterials {
            let alreadyCrafted = workshop.craftedMaterials[craftedItem, default: 0]
            let stillNeed = max(0, qty - alreadyCrafted)
            guard stillNeed > 0 else { continue }
            // Find the recipe for this crafted item
            if let recipe = Recipe.allRecipes.first(where: { $0.output == craftedItem }) {
                for (mat, count) in recipe.ingredients {
                    needed[mat, default: 0] += count * stillNeed
                }
            }
        }
        // Subtract what player already has
        for (mat, have) in workshop.rawMaterials {
            if needed[mat] != nil {
                needed[mat] = max(0, (needed[mat] ?? 0) - have)
                if needed[mat] == 0 { needed.removeValue(forKey: mat) }
            }
        }
        return needed
    }

    /// Show progress like " (2 more)" for a material the player is collecting
    private func materialProgressHint(_ material: Material, neededRaw: [Material: Int], building: Building?) -> String {
        let stillNeeded = neededRaw[material, default: 0]
        guard stillNeeded > 1 else { return "" }
        // Find total required for this material across all recipes
        guard let building = building else { return " (\(stillNeeded) more)" }
        var totalRequired = 0
        for (craftedItem, qty) in building.requiredMaterials {
            if let recipe = Recipe.allRecipes.first(where: { $0.output == craftedItem }) {
                totalRequired += (recipe.ingredients[material] ?? 0) * qty
            }
        }
        let collected = totalRequired - stillNeeded
        if collected > 0 {
            return " (\(collected)/\(totalRequired) collected)"
        }
        return " (\(stillNeeded) needed)"
    }

    /// Which stations provide materials the building needs (ordered by priority)
    private func stationsForNeededMaterials(_ neededRaw: [Material: Int]) -> [ResourceStationType] {
        let stationOrder: [ResourceStationType] = [.quarry, .volcano, .river, .mine, .clayPit, .farm]
        return stationOrder.filter { station in
            station.materials.contains { neededRaw[$0, default: 0] > 0 }
        }
    }

    /// Check if any recipe needed by the building can be crafted right now
    private func nextCraftableRecipe(for building: Building) -> Recipe? {
        for (craftedItem, qty) in building.requiredMaterials {
            let alreadyCrafted = workshop.craftedMaterials[craftedItem, default: 0]
            guard alreadyCrafted < qty else { continue }
            if let recipe = Recipe.allRecipes.first(where: { $0.output == craftedItem }) {
                // Check if player has all ingredients
                let canCraft = recipe.ingredients.allSatisfy { (mat, count) in
                    (workshop.rawMaterials[mat] ?? 0) >= count
                }
                if canCraft { return recipe }
            }
        }
        return nil
    }

    /// Map a knowledge card stationKey (lowercase) to ResourceStationType
    private func stationTypeFromKey(_ key: String) -> ResourceStationType? {
        switch key.lowercased() {
        case "quarry": return .quarry
        case "river": return .river
        case "volcano": return .volcano
        case "claypit", "clay pit": return .clayPit
        case "mine": return .mine
        case "forest": return .forest
        case "market": return .market
        case "farm": return .farm
        case "pigmenttable", "pigment table": return .pigmentTable
        default: return nil
        }
    }

    /// Check if a station has an uncompleted knowledge card OR a discovery card
    private func hasKnowledgeCard(at station: ResourceStationType) -> Bool {
        guard let vm = viewModel else { return false }
        if let bid = vm.activeBuildingId {
            return vm.nextUncompletedCard(for: bid, at: "\(station)") != nil
        }
        // No active building — show discovery card if available
        return DiscoveryCardContent.card(for: "\(station)") != nil
    }

    /// Show knowledge card overlay for a station, or discovery card if no active building
    private func showKnowledgeCardForStation(_ station: ResourceStationType) {
        guard let vm = viewModel else { return }
        let stationKey = "\(station)"

        if let bid = vm.activeBuildingId,
           let nextCard = vm.nextUncompletedCard(for: bid, at: stationKey) {
            // Active building — show building-specific knowledge card
            showArrivalGuidance = false
            stationKnowledgeCards = [nextCard]
            SoundManager.shared.play(.cardsAppear)
            withAnimation(.spring(response: 0.3)) {
                showStationKnowledgeCards = true
            }
        } else if vm.activeBuildingId == nil,
                  let card = DiscoveryCardContent.card(for: stationKey) {
            // No active building — show discovery card
            showArrivalGuidance = false
            discoveryCard = card
            SoundManager.shared.play(.cardsAppear)
            withAnimation(.spring(response: 0.3)) {
                showDiscoveryCard = true
            }
        }
    }

    /// Check for guidance on initial appear (called from onAppear)
    private func checkArrivalGuidance() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            showNextGuidance()
        }
    }

    private func dismissAllOverlays() {
        showHintBubble = false
        showCollectionOverlay = false
        showWorkbenchOverlay = false
        showFurnaceOverlay = false
        showStationLesson = false
        showQuarryMiniGame = false
        showVolcanoMiniGame = false
        showRiverMiniGame = false
        showClayPitMiniGame = false
        showFarmMiniGame = false
        showArrivalGuidance = false
    }

    /// Show a single overlay based on tool ownership:
    /// - No tool → tool requirement dialog (collectionOverlay)
    /// - Has tool → station mini-game (if available) or hint bubble with collection buttons
    private func showSingleStationOverlay() {
        guard let station = activeStation else { return }

        // Station mini-games (replace simple collection for specific stations)
        if station == .quarry && workshop.hasTool(for: station) {
            sceneHolder.scene?.nudgeCameraUp(by: 0.2)
            withAnimation(.spring(response: 0.3)) {
                showQuarryMiniGame = true
            }
            return
        }

        if station == .volcano && workshop.hasTool(for: station) {
            sceneHolder.scene?.nudgeCameraUp(by: 0.2)
            withAnimation(.spring(response: 0.3)) {
                showVolcanoMiniGame = true
            }
            return
        }

        if station == .river && workshop.hasTool(for: station) {
            sceneHolder.scene?.nudgeCameraUp(by: 0.2)
            withAnimation(.spring(response: 0.3)) {
                showRiverMiniGame = true
            }
            return
        }

        if station == .clayPit && workshop.hasTool(for: station) {
            sceneHolder.scene?.nudgeCameraUp(by: 0.2)
            withAnimation(.spring(response: 0.3)) {
                showClayPitMiniGame = true
            }
            return
        }

        if station == .farm && workshop.hasTool(for: station) {
            sceneHolder.scene?.nudgeCameraUp(by: 0.2)
            withAnimation(.spring(response: 0.3)) {
                showFarmMiniGame = true
            }
            return
        }

        if workshop.hasTool(for: station) {
            withAnimation(.spring(response: 0.3)) {
                showHintBubble = true
            }
        } else {
            withAnimation(.spring(response: 0.3)) {
                showCollectionOverlay = true
            }
        }
    }

    // MARK: - Layer 3: Navigation Panel + Inventory

    private var navigationPanel: some View {
        Group {
            if let viewModel = viewModel {
                GameTopBarView(
                    title: "Workshop",
                    viewModel: viewModel,
                    onNavigate: { destination in
                        onNavigate?(destination)
                    },
                    showBackButton: true,
                    onBack: { dismiss() },
                    onBackToMenu: onBackToMenu,
                    onboardingState: onboardingState,
                    returnToLessonBuildingName: returnToLessonPlotId.flatMap { id in
                        viewModel.buildingPlots.first(where: { $0.id == id })?.building.name
                    },
                    onReturnToLesson: returnToLessonPlotId != nil ? {
                        onNavigate?(.cityMap)
                    } : nil,
                    currentDestination: .workshop,
                    hideAvatarImage: !avatarInBox,
                    avatarDialogContent: workshopDialogContent
                )
            } else {
                // Fallback if no viewModel
                VStack(spacing: 8) {
                    Button { dismiss() } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .font(.custom("EBGaramond-Regular", size: 16))
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                        .padding(.horizontal, Spacing.md)
                        .padding(.vertical, Spacing.xs)
                        .glassButton(shape: Capsule())
                    }
                    Text("Workshop")
                        .font(RenaissanceFont.dialogTitle)
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                        .padding(.horizontal, Spacing.lg)
                        .padding(.vertical, 10)
                        .glassButton(shape: Capsule())
                }
            }
        }
    }

    private var inventoryBar: some View {
        HStack(spacing: 0) {
            // Tools (ochre badges)
            let ownedTools = Tool.allCases.filter { (workshop.tools[$0] ?? 0) > 0 }
            if !ownedTools.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(ownedTools) { tool in
                            ToolIconView(tool: tool, size: 56)
                                .padding(.horizontal, 5)
                                .padding(.vertical, Spacing.xxs)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(RenaissanceColors.ochre.opacity(0.15))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 6)
                                                .strokeBorder(RenaissanceColors.ochre.opacity(0.4), lineWidth: 1)
                                        )
                                )
                        }
                    }
                }

                Divider()
                    .frame(height: 30)
                    .padding(.horizontal, 6)
            }

            // Raw materials (compact)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Material.allCases) { material in
                        let count = workshop.rawMaterials[material] ?? 0
                        if count > 0 {
                            HStack(spacing: 3) {
                                MaterialIconView(material: material, size: 20)
                                Text("\(count)")
                                    .font(.custom("EBGaramond-Regular", size: 12))
                                    .foregroundStyle(settings.cardTextColor)
                            }
                            .padding(.horizontal, 6)
                            .padding(.vertical, Spacing.xxs)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(settings.itemBadgeBackground)
                            )
                        }
                    }
                }
            }

            Divider()
                .frame(height: 30)
                .padding(.horizontal, Spacing.xs)

            // Crafted items
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(CraftedItem.allCases) { item in
                        let count = workshop.craftedMaterials[item] ?? 0
                        if count > 0 {
                            HStack(spacing: 3) {
                                Text(item.icon)
                                    .font(.caption)
                                Text("\(count)")
                                    .font(.custom("EBGaramond-Regular", size: 12))
                                    .foregroundStyle(RenaissanceColors.sageGreen)
                            }
                            .padding(.horizontal, 6)
                            .padding(.vertical, Spacing.xxs)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(RenaissanceColors.goldSuccess.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .strokeBorder(RenaissanceColors.goldSuccess.opacity(0.4), lineWidth: 1)
                                    )
                            )
                        }
                    }
                }
            }
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.xs)
        .background(
            ZStack {
                // Wood plank texture — warm brown gradient with grain lines
                RoundedRectangle(cornerRadius: CornerRadius.md)
                    .fill(
                        settings.isDarkMode
                            ? Color(red: 0.18, green: 0.16, blue: 0.13).opacity(0.65)
                            : Color(red: 0.58, green: 0.44, blue: 0.30).opacity(0.25)
                    )

                // Subtle horizontal grain lines
                VStack(spacing: 0) {
                    ForEach(0..<3, id: \.self) { _ in
                        Spacer()
                        Rectangle()
                            .fill(
                                settings.isDarkMode
                                    ? RenaissanceColors.ochre.opacity(0.08)
                                    : RenaissanceColors.warmBrown.opacity(0.08)
                            )
                            .frame(height: 0.5)
                    }
                    Spacer()
                }
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.md)
                .strokeBorder(
                    settings.isDarkMode
                        ? RenaissanceColors.ochre.opacity(0.2)
                        : RenaissanceColors.warmBrown.opacity(0.2),
                    lineWidth: 1
                )
        )
    }

    // MARK: - Layer 4: Hint Bubble

    // MARK: - Workshop Dialog Content (passed into GameTopBarView avatar card)

    /// Returns dialog content to embed in the avatar card, or nil when no dialog
    private var workshopDialogContent: AnyView? {
        guard (showHintBubble || showCollectionOverlay), let station = activeStation else {
            return nil
        }
        return AnyView(
            VStack(alignment: .leading, spacing: 6) {
                if showCollectionOverlay {
                    if let requiredTool = Tool.requiredFor(station: station),
                       !workshop.hasTool(for: station) {
                        toolRequirementCompact(tool: requiredTool, station: station)
                    } else {
                        collectionMaterialsView(for: station)
                    }
                } else if showHintBubble {
                    HStack(spacing: 8) {
                        BirdCharacter(isSitting: true)
                            .frame(width: 32, height: 32)
                        Text(station.label)
                            .font(.custom("EBGaramond-SemiBold", size: 16))
                            .foregroundStyle(settings.cardTextColor)
                    }
                    collectionMaterialsView(for: station)
                }
            }
        )
    }

    /// Compact tool requirement for the integrated avatar card
    private func toolRequirementCompact(tool: Tool, station: ResourceStationType) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                ToolIconView(tool: tool, size: 108)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Need \(tool.displayName)")
                        .font(.custom("Cinzel-Bold", size: 15))
                        .foregroundStyle(settings.cardTextColor)
                    Text(tool.italianName)
                        .font(.custom("EBGaramond-Italic", size: 14))
                        .foregroundStyle(settings.pillSecondaryColor)
                }
            }

            Text(tool.educationalText)
                .font(.custom("EBGaramond-Regular", size: 14))
                .foregroundStyle(settings.cardTextColor.opacity(0.8))
                .fixedSize(horizontal: false, vertical: true)

            Button {
                // Remember which station sent us to market so bird guides back
                returnToStationAfterMarket = activeStation
                withAnimation(.spring(response: 0.3)) {
                    showCollectionOverlay = false
                    showHintBubble = false
                    activeStation = nil
                }
                skipCardForMarket = true
                let capturedScene = sceneHolder.scene
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    capturedScene?.walkToStation(.market)
                }
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
                withAnimation(.spring(response: 0.3)) {
                    showCollectionOverlay = false
                    showHintBubble = false
                    activeStation = nil
                }
            } label: {
                Text("Close")
                    .font(.custom("EBGaramond-Regular", size: 13))
                    .foregroundStyle(settings.cardTextColor.opacity(0.4))
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private func hintBubbleOverlay(for station: ResourceStationType) -> some View {
        VStack(spacing: 10) {
            // Bird + station name
            HStack(spacing: 8) {
                BirdCharacter(isSitting: true)
                    .frame(width: 44, height: 44)

                Text(station.label)
                    .font(RenaissanceFont.button)
                    .foregroundStyle(settings.cardTextColor)
            }

            // Collection buttons built into the hint bubble
            collectionMaterialsView(for: station)
        }
        .padding(Spacing.md)
        .frame(width: 280)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.lg)
                .fill(settings.cardBackground)
        )
        .padding(.trailing, Spacing.md)
    }

    // MARK: - Layer 5: Collection Overlay

    private func collectionOverlay(for station: ResourceStationType) -> some View {
        VStack(spacing: 0) {
            Spacer()
            VStack(spacing: 12) {
                // Station name header
                HStack {
                    Text(station.label)
                        .font(RenaissanceFont.title2)
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                    Spacer()
                    if let building = viewModel?.activeBuildingName {
                        Text("for the \(building)")
                            .font(RenaissanceFont.caption)
                            .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.5))
                    }
                }

                // Only shown when player lacks the required tool
                if let requiredTool = Tool.requiredFor(station: station) {
                    toolRequirementView(tool: requiredTool, station: station)
                } else {
                    // Fallback (station has no tool requirement) — show collection
                    collectionMaterialsView(for: station)
                }
            }
            .padding(Spacing.xl)
            .padding(.bottom, 60) // above inventory bar
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.xl)
                    .fill(settings.cardBackground)
            )
            .borderModal(radius: CornerRadius.xl)
        }
        .ignoresSafeArea(edges: .bottom)
    }

    /// Shows when player lacks the tool for a station — compact right-side card
    private func toolRequirementView(tool: Tool, station: ResourceStationType) -> some View {
        VStack(spacing: 10) {
            HStack(spacing: 8) {
                ToolIconView(tool: tool, size: 120)
                VStack(alignment: .leading, spacing: 2) {
                    Text("You need \(tool.displayName)")
                        .font(.custom("Cinzel-Bold", size: 14))
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                    Text(tool.italianName)
                        .font(RenaissanceFont.italicSmall)
                        .foregroundStyle(RenaissanceColors.warmBrown)
                }
            }

            Text(tool.educationalText)
                .font(RenaissanceFont.captionSmall)
                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))
                .multilineTextAlignment(.center)
                .lineLimit(2)

            // Choice buttons — walk player to Market or Crafting Room
            VStack(spacing: 8) {
                Button {
                    // Remember which station sent us to market so bird guides back
                    returnToStationAfterMarket = activeStation
                    withAnimation(.spring(response: 0.3)) {
                        showCollectionOverlay = false
                        showHintBubble = false
                        activeStation = nil
                    }
                    skipCardForMarket = true
                    let capturedScene = sceneHolder.scene
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        capturedScene?.walkToStation(.market)
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text("🏪")
                            .font(.caption)
                        Text("Go to Market")
                            .font(RenaissanceFont.buttonSmall)
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
                    withAnimation(.spring(response: 0.3)) {
                        showCollectionOverlay = false
                        showHintBubble = false
                        activeStation = nil
                    }
                } label: {
                    Text("Close")
                        .font(RenaissanceFont.captionSmall)
                        .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.4))
                }
            }
        }
    }

    /// The normal material collection buttons (shown when player has the tool)
    private func collectionMaterialsView(for station: ResourceStationType) -> some View {
        VStack(spacing: 8) {
            // Market gets a segmented control: Materials | Tools
            if station == .market {
                marketOverlayContent
            } else {
                // Florins display
                if let vm = viewModel {
                    HStack(spacing: 6) {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.body)
                            .foregroundStyle(settings.pillTextColor)
                        Text("\(vm.goldFlorins) florins")
                            .font(RenaissanceFont.bodySemibold)
                            .foregroundStyle(settings.cardTextColor)
                    }
                }

                // Material buttons — use flexible grid for narrow card
                let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: min(station.materials.count, 3))
                LazyVGrid(columns: columns, spacing: 6) {
                    ForEach(station.materials, id: \.self) { material in
                        let canAfford = (viewModel?.goldFlorins ?? 0) >= material.cost
                        Button {
                            guard let vm = viewModel else { return }
                            guard vm.goldFlorins >= material.cost else {
                                withAnimation(.spring(response: 0.3)) {
                                    showCollectionOverlay = false
                                    showHintBubble = false
                                    activeStation = nil
                                }
                                // Guide player to earn florins instead of showing overlay
                                showNextGuidance(forceRefresh: true)
                                return
                            }
                            if workshop.collectFromStation(station, material: material) {
                                vm.goldFlorins -= material.cost
                                sceneHolder.scene?.showCollectionEffect(at: station)
                                sceneHolder.scene?.playPlayerCelebrateAnimation()
                                recentlyCollectedStations.insert(station)

                                if workshop.currentJob != nil && workshop.currentJob?.craftTarget == nil {
                                    if workshop.checkJobCompletion() {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            withAnimation(.spring(response: 0.3)) {
                                                showCollectionOverlay = false
                                                showHintBubble = false
                                            }
                                            completeCurrentJob()
                                        }
                                    }
                                }

                                // Dismiss and show next guidance after a beat
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                    withAnimation(.spring(response: 0.3)) {
                                        showCollectionOverlay = false
                                        showHintBubble = false
                                        activeStation = nil
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        showNextGuidance(forceRefresh: true)
                                    }
                                }
                            }
                        } label: {
                            VStack(spacing: 4) {
                                MaterialIconView(material: material, size: 96)
                                Text(material.rawValue)
                                    .font(RenaissanceFont.body)
                                    .foregroundStyle(settings.cardTextColor)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                                HStack(spacing: 3) {
                                    Image(systemName: "dollarsign.circle.fill")
                                        .font(.system(size: 12))
                                        .foregroundStyle(settings.cardTextColor)
                                    Text("\(material.cost)")
                                        .font(RenaissanceFont.bodySmall)
                                        .foregroundStyle(canAfford ? settings.cardTextColor : RenaissanceColors.errorRed)
                                }
                            }
                            .padding(10)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: CornerRadius.sm)
                                    .fill(canAfford ? settings.itemBadgeBackground : RenaissanceColors.stoneGray.opacity(0.15))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: CornerRadius.sm)
                                    .strokeBorder(canAfford ? settings.cardBorderColor : RenaissanceColors.stoneGray.opacity(0.3), lineWidth: 1)
                            )
                        }
                    }
                }

                Button("Back") {
                    withAnimation(.spring(response: 0.3)) {
                        showCollectionOverlay = false
                        showHintBubble = false
                        activeStation = nil
                    }
                }
                .font(RenaissanceFont.bodySmall)
                .foregroundStyle(settings.cardTextColor.opacity(0.5))
            }
        }
    }

    // MARK: - Market Tools Tab

    @State private var marketTab: MarketTab = .materials

    private enum MarketTab: String, CaseIterable {
        case materials = "Materials"
        case tools = "Tools"
    }

    private var marketOverlayContent: some View {
        VStack(spacing: 8) {
            // Florins display
            if let vm = viewModel {
                HStack(spacing: 4) {
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.caption)
                        .foregroundStyle(settings.pillTextColor)
                    Text("\(vm.goldFlorins)")
                        .font(.custom("EBGaramond-Regular", size: 13))
                        .foregroundStyle(settings.cardTextColor)
                }
            }

            // Tab picker
            HStack(spacing: 0) {
                ForEach(MarketTab.allCases, id: \.self) { tab in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) { marketTab = tab }
                    } label: {
                        Text(tab.rawValue)
                            .font(.custom("EBGaramond-SemiBold", size: 12))
                            .foregroundStyle(marketTab == tab ? .white : settings.cardTextColor)
                            .padding(.horizontal, Spacing.md)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: CornerRadius.sm)
                                    .fill(marketTab == tab ? RenaissanceColors.ochre : Color.clear)
                            )
                    }
                }
            }
            .padding(2)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(settings.pillBackground)
            )

            if marketTab == .materials {
                marketMaterialsGrid
            } else {
                marketToolsGrid
            }

            Button("Done") {
                withAnimation(.spring(response: 0.3)) {
                    showCollectionOverlay = false
                    showHintBubble = false
                    activeStation = nil
                }
            }
            .font(RenaissanceFont.captionSmall)
            .foregroundStyle(settings.cardTextColor.opacity(0.5))
        }
    }

    private var marketMaterialsGrid: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(ResourceStationType.market.materials, id: \.self) { material in
                    let canAfford = (viewModel?.goldFlorins ?? 0) >= material.cost
                    Button {
                        guard let vm = viewModel else { return }
                        guard vm.goldFlorins >= material.cost else {
                            withAnimation(.spring(response: 0.3)) {
                                showCollectionOverlay = false
                                showHintBubble = false
                                activeStation = nil
                            }
                            showNextGuidance(forceRefresh: true)
                            return
                        }
                        if workshop.collectFromStation(.market, material: material) {
                            vm.goldFlorins -= material.cost
                            sceneHolder.scene?.showCollectionEffect(at: .market)
                            sceneHolder.scene?.playPlayerCelebrateAnimation()
                        }
                    } label: {
                        VStack(spacing: 4) {
                            MaterialIconView(material: material, size: 96)

                            Text(material.rawValue)
                                .font(RenaissanceFont.captionSmall)
                                .foregroundStyle(settings.cardTextColor)
                                .lineLimit(1)

                            HStack(spacing: 2) {
                                Image(systemName: "dollarsign.circle.fill")
                                    .font(.custom("EBGaramond-Regular", size: 9, relativeTo: .caption2))
                                    .foregroundStyle(settings.cardTextColor)
                                Text("\(material.cost)")
                                    .font(RenaissanceFont.captionSmall)
                                    .foregroundStyle(canAfford ? settings.cardTextColor : RenaissanceColors.errorRed)
                            }
                        }
                        .padding(Spacing.xs)
                        .frame(width: 80)
                        .background(
                            RoundedRectangle(cornerRadius: CornerRadius.sm)
                                .fill(canAfford ? settings.itemBadgeBackground : RenaissanceColors.stoneGray.opacity(0.15))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: CornerRadius.sm)
                                .strokeBorder(canAfford ? settings.cardBorderColor : RenaissanceColors.stoneGray.opacity(0.3), lineWidth: 1)
                        )
                    }
                }
            }
        }
    }

    private var marketToolsGrid: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(Tool.allCases) { tool in
                    let owned = (workshop.tools[tool] ?? 0) > 0
                    let cost = GameRewards.toolBuyBaseCost
                    let canAfford = (viewModel?.goldFlorins ?? 0) >= cost

                    Button {
                        guard !owned, let vm = viewModel else { return }
                        guard canAfford else {
                            withAnimation(.spring(response: 0.3)) {
                                showCollectionOverlay = false
                                showHintBubble = false
                                activeStation = nil
                            }
                            showNextGuidance(forceRefresh: true)
                            return
                        }
                        if workshop.buyTool(tool) {
                            vm.goldFlorins -= cost
                            sceneHolder.scene?.playPlayerCelebrateAnimation()
                            workshop.statusMessage = "Bought \(tool.icon) \(tool.displayName)!"
                            // Refresh bird guidance immediately — guide back to the station
                            withAnimation(.easeOut(duration: 0.2)) { showArrivalGuidance = false }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                showNextGuidance(forceRefresh: true)
                            }
                        }
                    } label: {
                        VStack(spacing: 4) {
                            ToolIconView(tool: tool, size: 96)

                            Text(tool.displayName)
                                .font(RenaissanceFont.captionSmall)
                                .foregroundStyle(settings.cardTextColor)
                                .lineLimit(1)

                            Text(tool.italianName)
                                .font(.custom("EBGaramond-Italic", size: 9))
                                .foregroundStyle(settings.pillSecondaryColor)
                                .lineLimit(1)

                            if owned {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.caption)
                                    .foregroundStyle(RenaissanceColors.sageGreen)
                            } else {
                                HStack(spacing: 2) {
                                    Image(systemName: "dollarsign.circle.fill")
                                        .font(.custom("EBGaramond-Regular", size: 9, relativeTo: .caption2))
                                        .foregroundStyle(settings.cardTextColor)
                                    Text("\(cost)")
                                        .font(RenaissanceFont.captionSmall)
                                        .foregroundStyle(canAfford ? settings.cardTextColor : RenaissanceColors.errorRed)
                                }
                            }
                        }
                        .padding(Spacing.xs)
                        .frame(width: 80)
                        .background(
                            RoundedRectangle(cornerRadius: CornerRadius.sm)
                                .fill(owned ? RenaissanceColors.sageGreen.opacity(0.08) : (canAfford ? settings.itemBadgeBackground : RenaissanceColors.stoneGray.opacity(0.15)))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: CornerRadius.sm)
                                .strokeBorder(owned ? RenaissanceColors.sageGreen.opacity(0.4) : (canAfford ? settings.cardBorderColor : RenaissanceColors.stoneGray.opacity(0.3)), lineWidth: 1)
                        )
                    }
                    .disabled(owned)
                }
            }
        }
    }

    // MARK: - Layer 6: Workbench Overlay

    private var workbenchOverlay: some View {
        VStack {
            Spacer()

            VStack(spacing: 14) {
                Text("Mixing Workbench")
                    .font(.custom("EBGaramond-SemiBold", size: 20))
                    .foregroundStyle(RenaissanceColors.sepiaInk)

                // Recipe hint
                if let recipe = workshop.detectedRecipe {
                    HStack(spacing: 6) {
                        Text(recipe.output.icon)
                        Text(recipe.output.rawValue)
                            .font(RenaissanceFont.bodySmall)
                            .foregroundStyle(RenaissanceColors.sageGreen)
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(RenaissanceColors.sageGreen)
                            .font(.caption)
                    }
                } else {
                    Text("Add materials to mix")
                        .font(RenaissanceFont.dialogSubtitle)
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                }

                // 4 mixing slots
                HStack(spacing: 12) {
                    ForEach(0..<4, id: \.self) { index in
                        workbenchSlot(index: index)
                    }
                }

                // Material picker (from inventory)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Material.allCases) { material in
                            let count = workshop.rawMaterials[material] ?? 0
                            if count > 0 {
                                Button {
                                    _ = workshop.addToWorkbench(material)
                                } label: {
                                    VStack(spacing: 2) {
                                        MaterialIconView(material: material, size: 28)
                                        Text("×\(count)")
                                            .font(RenaissanceFont.captionSmall)
                                            .foregroundStyle(RenaissanceColors.sepiaInk)
                                    }
                                    .padding(6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(RenaissanceColors.parchment.opacity(0.6))
                                    )
                                }
                            }
                        }
                    }
                }
                .frame(height: 55)

                // Action buttons
                HStack(spacing: 16) {
                    Button("Clear") {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            workshop.clearWorkbench()
                        }
                    }
                    .font(RenaissanceFont.bodySmall)
                    .padding(.horizontal, Spacing.lg)
                    .padding(.vertical, Spacing.xs)
                    .background(
                        RoundedRectangle(cornerRadius: CornerRadius.sm)
                            .fill(RenaissanceColors.stoneGray.opacity(0.3))
                    )
                    .foregroundStyle(RenaissanceColors.sepiaInk)

                    Button("Mix!") {
                        if workshop.mixIngredients() {
                            withAnimation(.spring(response: 0.3)) {
                                showWorkbenchOverlay = false
                                activeStation = nil
                            }
                            workshop.statusMessage = "Mixed! Walk to the Furnace to fire."
                        }
                    }
                    .font(RenaissanceFont.bodySmall)
                    .padding(.horizontal, Spacing.xl)
                    .padding(.vertical, Spacing.xs)
                    .background(
                        RoundedRectangle(cornerRadius: CornerRadius.sm)
                            .fill(workshop.detectedRecipe != nil
                                  ? RenaissanceColors.renaissanceBlue
                                  : RenaissanceColors.stoneGray.opacity(0.3))
                    )
                    .foregroundStyle(workshop.detectedRecipe != nil ? .white : RenaissanceColors.sepiaInk)
                    .disabled(workshop.detectedRecipe == nil)

                    Spacer()

                    Button("Close") {
                        withAnimation(.spring(response: 0.3)) {
                            showWorkbenchOverlay = false
                            activeStation = nil
                        }
                    }
                    .font(RenaissanceFont.bodySmall)
                    .foregroundStyle(RenaissanceColors.sepiaInk)
                }
            }
            .padding(Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.lg)
                    .fill(RenaissanceColors.parchment.opacity(0.95))
            )
            .padding(.horizontal, Spacing.xl)
            .padding(.bottom, 60)
        }
    }

    private func workbenchSlot(index: Int) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(
                    workshop.workbenchSlots[index] != nil
                        ? RenaissanceColors.renaissanceBlue
                        : RenaissanceColors.stoneGray.opacity(0.4),
                    style: StrokeStyle(lineWidth: 1.5, dash: workshop.workbenchSlots[index] == nil ? [6, 4] : [])
                )
                .frame(width: 56, height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(RenaissanceColors.parchment.opacity(0.6))
                )

            if let material = workshop.workbenchSlots[index] {
                MaterialIconView(material: material, size: 32)
            } else {
                Image(systemName: "plus")
                    .font(.caption)
                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.5))
            }
        }
    }

    // MARK: - Layer 7: Furnace Overlay

    private let furnaceOrange = RenaissanceColors.furnaceOrange

    private var furnaceOverlay: some View {
        VStack {
            Spacer()

            VStack(spacing: 14) {
                Text("Furnace")
                    .font(.custom("EBGaramond-SemiBold", size: 20))
                    .foregroundStyle(RenaissanceColors.sepiaInk)

                // Furnace contents
                ZStack {
                    RoundedRectangle(cornerRadius: CornerRadius.md)
                        .fill(RenaissanceColors.terracotta.opacity(0.3))
                        .frame(height: 80)
                        .overlay(
                            RoundedRectangle(cornerRadius: CornerRadius.md)
                                .strokeBorder(RenaissanceColors.terracotta, lineWidth: 2)
                        )

                    if workshop.isProcessing {
                        RoundedRectangle(cornerRadius: CornerRadius.md)
                            .fill(furnaceOrange.opacity(0.25))
                            .frame(height: 80)
                            .blur(radius: 8)
                    }

                    if let input = workshop.furnaceInput {
                        VStack(spacing: 4) {
                            HStack(spacing: 4) {
                                ForEach(Array(input.keys.sorted(by: { $0.rawValue < $1.rawValue })), id: \.self) { material in
                                    Text("\(material.icon)×\(input[material]!)")
                                        .font(RenaissanceFont.caption)
                                }
                            }
                            if let recipe = workshop.currentRecipe {
                                Text("→ \(recipe.output.icon) \(recipe.output.rawValue)")
                                    .font(RenaissanceFont.caption)
                                    .foregroundStyle(RenaissanceColors.sepiaInk)
                            }
                        }
                    } else {
                        Text("Mix ingredients at the Workbench first")
                            .font(RenaissanceFont.dialogSubtitle)
                            .foregroundStyle(RenaissanceColors.sepiaInk)
                    }
                }

                // Temperature picker
                VStack(spacing: 4) {
                    Text("Temperature")
                        .font(RenaissanceFont.caption)
                        .foregroundStyle(RenaissanceColors.sepiaInk)

                    Picker("Temperature", selection: $workshop.furnaceTemperature) {
                        ForEach(Recipe.Temperature.allCases, id: \.self) { temp in
                            Text(temp.rawValue).tag(temp)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                // Progress bar
                if workshop.isProcessing {
                    ProgressView(value: workshop.processProgress)
                        .tint(furnaceOrange)
                }

                // Buttons
                HStack(spacing: 16) {
                    Button {
                        fireFurnace()
                    } label: {
                        Text("FIRE!")
                            .font(RenaissanceFont.button)
                            .foregroundStyle(.white)
                            .padding(.horizontal, Spacing.xxl)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: CornerRadius.sm)
                                    .fill(workshop.furnaceInput != nil && !workshop.isProcessing
                                          ? furnaceOrange
                                          : RenaissanceColors.stoneGray.opacity(0.4))
                            )
                    }
                    .disabled(workshop.furnaceInput == nil || workshop.isProcessing)

                    Spacer()

                    Button("Close") {
                        withAnimation(.spring(response: 0.3)) {
                            showFurnaceOverlay = false
                            activeStation = nil
                        }
                    }
                    .font(RenaissanceFont.bodySmall)
                    .foregroundStyle(RenaissanceColors.sepiaInk)
                }
            }
            .padding(Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.lg)
                    .fill(RenaissanceColors.parchment.opacity(0.95))
            )
            .padding(.horizontal, Spacing.xl)
            .padding(.bottom, 60)
        }
    }

    // MARK: - Educational Overlay

    private var educationalOverlay: some View {
        ZStack {
            RenaissanceColors.overlayDimming
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Did You Know?")
                    .font(.custom("Cinzel-Regular", size: 24))
                    .foregroundStyle(RenaissanceColors.sepiaInk)

                Text(workshop.educationalText)
                    .font(RenaissanceFont.body)
                    .foregroundStyle(RenaissanceColors.sepiaInk)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Button("Continue") {
                    workshop.showEducationalPopup = false
                }
                .font(.custom("EBGaramond-Regular", size: 18))
                .padding(.horizontal, Spacing.xxl)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: CornerRadius.sm)
                        .fill(RenaissanceColors.renaissanceBlue)
                )
                .foregroundStyle(.white)
            }
            .padding(Spacing.xxl)
            .adaptiveWidth(500)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.lg)
                    .fill(RenaissanceColors.parchment)
            )
            .adaptivePadding(.horizontal, regular: 0, compact: 40)
        }
    }

    // MARK: - Earn Florins Overlay

    private var earnFlorinsOverlay: some View {
        ZStack {
            RenaissanceColors.overlayDimming
                .ignoresSafeArea()
                .onTapGesture {
                    workshop.showEarnFlorinsOverlay = false
                }

            VStack(spacing: 20) {
                HStack(spacing: 12) {
                    BirdCharacter()
                        .frame(width: 70, height: 70)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Earn Florins")
                            .font(.custom("Cinzel-Bold", size: 22))
                            .foregroundStyle(RenaissanceColors.sepiaInk)
                        Text("You need more florins! Here's how:")
                            .font(RenaissanceFont.dialogSubtitle)
                            .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))
                    }
                }

                VStack(spacing: 10) {
                    earnOptionCard(
                        icon: "book.fill",
                        title: "Read a Lesson",
                        reward: "+\(GameRewards.lessonReadFlorins) florins"
                    ) {
                        workshop.showEarnFlorinsOverlay = false
                        dismissAllOverlays()
                        onNavigate?(.cityMap)
                    }

                    earnOptionCard(
                        icon: "leaf.fill",
                        title: "Explore the Forest",
                        reward: "+\(GameRewards.timberCollectFlorins)/timber"
                    ) {
                        workshop.showEarnFlorinsOverlay = false
                        dismissAllOverlays()
                        onNavigate?(.forest)
                    }

                    earnOptionCard(
                        icon: "flame.fill",
                        title: "Craft an Item",
                        reward: "+\(GameRewards.craftCompleteFlorins) florins"
                    ) {
                        workshop.showEarnFlorinsOverlay = false
                        dismissAllOverlays()
                        if let onEnterInterior = onEnterInterior {
                            onEnterInterior()
                        }
                    }

                    if let assignment = workshop.currentAssignment {
                        earnOptionCard(
                            icon: "scroll.fill",
                            title: "Master's Task: \(assignment.targetItem.rawValue)",
                            reward: "+\(assignment.rewardFlorins) bonus"
                        ) {
                            workshop.showEarnFlorinsOverlay = false
                            dismissAllOverlays()
                            if let onEnterInterior = onEnterInterior {
                                onEnterInterior()
                            }
                        }
                    }
                }

                Button("Maybe Later") {
                    workshop.showEarnFlorinsOverlay = false
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
    }

    private func earnOptionCard(icon: String, title: String, reward: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.body)
                    .foregroundStyle(RenaissanceColors.sepiaInk)
                    .frame(width: 32, height: 32)
                    .background(
                        RoundedRectangle(cornerRadius: CornerRadius.sm)
                            .fill(RenaissanceColors.warmBrown.opacity(0.1))
                    )

                Text(title)
                    .font(.custom("EBGaramond-Regular", size: 16))
                    .foregroundStyle(RenaissanceColors.sepiaInk)

                Spacer()

                Text(reward)
                    .font(.custom("EBGaramond-SemiBold", size: 13))
                    .foregroundStyle(RenaissanceColors.sepiaInk)

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

    // MARK: - Master Task Card

    private func masterTaskCard(assignment: MasterAssignment) -> some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    jobBoardChoices = workshop.jobChoices()
                    workshop.showJobBoard = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "scroll.fill")
                            .font(.caption)
                            .foregroundStyle(settings.pillTextColor)

                        Text("Bottega Jobs")
                            .font(.custom("EBGaramond-Medium", size: 13))
                            .foregroundStyle(settings.pillTextColor)

                        Image(systemName: "chevron.right")
                            .font(.system(size: 10))
                            .foregroundStyle(settings.pillSecondaryColor)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, Spacing.xs)
                    .background(
                        Capsule()
                            .fill(settings.pillBackground)
                    )
                    .overlay(
                        Capsule()
                            .strokeBorder(settings.pillBorderColor, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                .padding(.trailing, 16)
            }
            .padding(.top, isLargeScreen ? 420 : 200)

            Spacer()
        }
    }

    // MARK: - Job Progress Card (floating, shows active job progress)

    private func jobProgressCard(job: WorkshopJob) -> some View {
        VStack {
            HStack {
                Spacer()
                VStack(alignment: .trailing, spacing: 6) {
                    // Job title + tier badge
                    HStack(spacing: 6) {
                        Text(job.tier.icon)
                            .font(.caption)
                        Text(job.title)
                            .font(.custom("EBGaramond-Medium", size: 13))
                            .foregroundStyle(RenaissanceColors.sepiaInk)
                        Text("+\(job.rewardFlorins)")
                            .font(.custom("Cinzel-Bold", size: 12))
                            .foregroundStyle(RenaissanceColors.warmBrown)
                    }

                    // Collection progress indicators
                    let progress = workshop.jobCollectionProgress()
                    HStack(spacing: 8) {
                        ForEach(Array(job.requirements.keys.sorted(by: { $0.rawValue < $1.rawValue })), id: \.self) { material in
                            let p = progress[material]
                            let collected = p?.collected ?? 0
                            let needed = p?.needed ?? job.requirements[material] ?? 0
                            let done = collected >= needed
                            HStack(spacing: 2) {
                                Text(material.icon)
                                    .font(.caption2)
                                Text("\(collected)/\(needed)")
                                    .font(RenaissanceFont.captionSmall)
                                    .foregroundStyle(done ? RenaissanceColors.sageGreen : RenaissanceColors.sepiaInk)
                            }
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(done ? RenaissanceColors.sageGreen.opacity(0.15) : Color.clear)
                            )
                        }

                        if let target = job.craftTarget {
                            HStack(spacing: 2) {
                                Text(target.icon)
                                    .font(.caption2)
                                Text("Craft")
                                    .font(RenaissanceFont.captionSmall)
                                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.6))
                            }
                        }
                    }

                    // Check if collection complete — show "Complete!" or craft reminder
                    if workshop.isJobCollectionDone() {
                        if job.craftTarget != nil {
                            Text("Materials ready! Craft at the workbench.")
                                .font(RenaissanceFont.captionSmall)
                                .foregroundStyle(RenaissanceColors.renaissanceBlue)
                        } else {
                            Button {
                                completeCurrentJob()
                            } label: {
                                Text("Turn In Job")
                                    .font(.custom("EBGaramond-Medium", size: 12))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 5)
                                    .background(
                                        Capsule()
                                            .fill(RenaissanceColors.sageGreen)
                                    )
                            }
                        }
                    }

                    // Abandon button
                    Button {
                        workshop.abandonJob()
                    } label: {
                        Text("Abandon")
                            .font(.custom("EBGaramond-Regular", size: 10))
                            .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.4))
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: CornerRadius.md)
                        .fill(RenaissanceColors.parchment.opacity(0.92))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.md)
                        .strokeBorder(RenaissanceColors.warmBrown.opacity(0.3), lineWidth: 0.5)
                    .blur(radius: 0.2)
                )
                .padding(.trailing, 16)
            }
            .padding(.top, isLargeScreen ? 420 : 200)

            Spacer()
        }
    }

    // MARK: - Job Board Overlay (pick from 3 jobs)

    private var jobBoardOverlay: some View {
        ZStack {
            RenaissanceColors.overlayDimming
                .ignoresSafeArea()
                .onTapGesture {
                    workshop.showJobBoard = false
                }

            VStack(spacing: 16) {
                // Header
                HStack(spacing: 12) {
                    Image(systemName: "scroll.fill")
                        .font(.title2)
                        .foregroundStyle(RenaissanceColors.warmBrown)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Bottega Job Board")
                            .font(.custom("Cinzel-Bold", size: 22))
                            .foregroundStyle(RenaissanceColors.sepiaInk)
                        Text("Choose a commission from the workshop master")
                            .font(RenaissanceFont.dialogSubtitle)
                            .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))
                    }
                }

                // Tier + streak info
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Text("Rank:")
                            .font(RenaissanceFont.caption)
                            .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.6))
                        Text("\(workshop.currentJobTier.icon) \(workshop.currentJobTier.italianTitle)")
                            .font(RenaissanceFont.buttonSmall)
                            .foregroundStyle(RenaissanceColors.sepiaInk)
                    }
                    if workshop.jobStreak > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                                .font(.caption)
                                .foregroundStyle(RenaissanceColors.furnaceOrange)
                            Text("Streak: \(workshop.jobStreak)")
                                .font(RenaissanceFont.caption)
                                .foregroundStyle(RenaissanceColors.sepiaInk)
                        }
                    }
                    HStack(spacing: 4) {
                        Text("Jobs: \(workshop.totalJobsCompleted)")
                            .font(RenaissanceFont.caption)
                            .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.6))
                    }
                }

                // Job cards
                ForEach(jobBoardChoices) { job in
                    jobCard(job: job)
                }

                Button("Maybe Later") {
                    workshop.showJobBoard = false
                }
                .font(RenaissanceFont.bodySmall)
                .foregroundStyle(RenaissanceColors.sepiaInk)
            }
            .padding(Spacing.xl)
            .adaptiveWidth(500)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.lg)
                    .fill(RenaissanceColors.parchment)
            )
        }
    }

    private func jobCard(job: WorkshopJob) -> some View {
        Button {
            workshop.acceptJob(job)
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                // Title row: tier icon + title + reward
                HStack {
                    Text(job.tier.icon)
                    Text(job.title)
                        .font(RenaissanceFont.bodySemibold)
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                    Spacer()
                    Text("+\(job.rewardFlorins)")
                        .font(.custom("Cinzel-Bold", size: 14))
                        .foregroundStyle(RenaissanceColors.warmBrown)
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.caption)
                        .foregroundStyle(RenaissanceColors.iconOchre)
                }

                // Trade name + tier
                HStack(spacing: 8) {
                    Text(job.tradeName)
                        .font(.custom("EBGaramond-Italic", size: 14))
                        .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.6))
                    Text("·")
                        .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.3))
                    Text(job.tier.rawValue)
                        .font(.custom("EBGaramond-Regular", size: 12))
                        .foregroundStyle(tierColor(job.tier))
                }

                // Flavor text
                Text(job.flavorText)
                    .font(RenaissanceFont.caption)
                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)

                // Requirements
                HStack(spacing: 8) {
                    ForEach(Array(job.requirements.keys.sorted(by: { $0.rawValue < $1.rawValue })), id: \.self) { material in
                        HStack(spacing: 2) {
                            Text(material.icon)
                                .font(.caption2)
                            Text("×\(job.requirements[material]!)")
                                .font(.custom("EBGaramond-Regular", size: 12))
                                .foregroundStyle(RenaissanceColors.sepiaInk)
                        }
                    }
                    if let target = job.craftTarget {
                        HStack(spacing: 2) {
                            Text("→")
                                .font(.caption2)
                                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.4))
                            Text(target.icon)
                                .font(.caption2)
                            Text(target.rawValue)
                                .font(.custom("EBGaramond-Regular", size: 12))
                                .foregroundStyle(RenaissanceColors.sageGreen)
                        }
                    }
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.md)
                    .fill(RenaissanceColors.parchment.opacity(0.6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.md)
                    .strokeBorder(tierColor(job.tier).opacity(0.4), lineWidth: 1)
            )
        }
    }

    private func tierColor(_ tier: WorkshopJob.JobTier) -> Color {
        switch tier {
        case .apprentice: return RenaissanceColors.warmBrown
        case .journeyman: return RenaissanceColors.renaissanceBlue
        case .master: return RenaissanceColors.goldSuccess
        }
    }

    // MARK: - Job Complete Celebration Overlay

    private func jobCompleteOverlay(job: WorkshopJob) -> some View {
        ZStack {
            RenaissanceColors.overlayDimming
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Commission Complete!")
                    .font(.custom("Cinzel-Bold", size: 24))
                    .foregroundStyle(RenaissanceColors.sepiaInk)

                // Trade badge
                VStack(spacing: 4) {
                    Text(job.tier.icon)
                        .font(.largeTitle)
                    Text(job.tradeName)
                        .font(.custom("EBGaramond-Italic", size: 20))
                        .foregroundStyle(RenaissanceColors.warmBrown)
                    Text(job.tradeDescription)
                        .font(RenaissanceFont.dialogSubtitle)
                        .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))
                        .multilineTextAlignment(.center)
                }

                // Rewards
                VStack(spacing: 6) {
                    HStack(spacing: 6) {
                        Image(systemName: "dollarsign.circle.fill")
                            .foregroundStyle(RenaissanceColors.iconOchre)
                        Text("+\(jobRewardFlorins) florins")
                            .font(RenaissanceFont.button)
                            .foregroundStyle(RenaissanceColors.sepiaInk)
                    }
                    if jobStreakBonus > 0 {
                        HStack(spacing: 6) {
                            Image(systemName: "flame.fill")
                                .foregroundStyle(RenaissanceColors.furnaceOrange)
                            Text("+\(jobStreakBonus) streak bonus!")
                                .font(.custom("EBGaramond-Medium", size: 15))
                                .foregroundStyle(RenaissanceColors.furnaceOrange)
                        }
                    }
                }

                // History fact
                VStack(spacing: 6) {
                    Text("Did You Know?")
                        .font(.custom("Cinzel-Regular", size: 16))
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                    Text(job.historyFact)
                        .font(RenaissanceFont.bodySmall)
                        .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(RenaissanceColors.warmBrown.opacity(0.08))
                )

                // Tier progression hint
                if workshop.totalJobsCompleted == 5 && workshop.currentJobTier == .journeyman {
                    Text("Promoted to Lavorante (Journeyman)! Harder jobs now available.")
                        .font(.custom("EBGaramond-Medium", size: 14))
                        .foregroundStyle(RenaissanceColors.renaissanceBlue)
                        .multilineTextAlignment(.center)
                } else if workshop.totalJobsCompleted == 15 && workshop.currentJobTier == .master {
                    Text("Promoted to Maestro! You can now take Master commissions.")
                        .font(.custom("EBGaramond-Medium", size: 14))
                        .foregroundStyle(RenaissanceColors.goldSuccess)
                        .multilineTextAlignment(.center)
                }

                Button("Next Commission") {
                    workshop.showJobComplete = false
                    completedJob = nil
                    jobBoardChoices = workshop.jobChoices()
                    workshop.showJobBoard = true
                }
                .font(.custom("EBGaramond-Medium", size: 16))
                .foregroundStyle(.white)
                .padding(.horizontal, 28)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(RenaissanceColors.renaissanceBlue)
                )

                Button("Continue Working") {
                    workshop.showJobComplete = false
                    completedJob = nil
                }
                .font(RenaissanceFont.dialogSubtitle)
                .foregroundStyle(RenaissanceColors.sepiaInk)
            }
            .padding(28)
            .adaptiveWidth(480)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.lg)
                    .fill(RenaissanceColors.parchment)
            )
        }
    }

    // MARK: - Job Completion Action

    private func completeCurrentJob() {
        guard let job = workshop.currentJob else { return }
        completedJob = job
        let (florins, streak) = workshop.completeJob()
        jobRewardFlorins = florins
        jobStreakBonus = streak
        viewModel?.earnFlorins(florins + streak)
    }

    // MARK: - Actions

    private func fireFurnace() {
        workshop.startProcessing()
        guard workshop.isProcessing,
              let recipe = workshop.currentRecipe else { return }

        withAnimation(.linear(duration: recipe.processingTime)) {
            workshop.processProgress = 1.0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + recipe.processingTime) {
            let craftedItem = recipe.output
            workshop.completeProcessing()

            // Award crafting florins
            viewModel?.earnFlorins(GameRewards.craftCompleteFlorins)
            var bonusText = ""

            // Check master assignment
            if workshop.checkAssignmentCompletion(craftedItem: craftedItem) {
                viewModel?.earnFlorins(GameRewards.masterAssignmentFlorins)
                bonusText = "\n\nMaster's Task complete! +\(GameRewards.masterAssignmentFlorins) bonus florins!"
                workshop.generateNewAssignment()
            }

            // Check Bottega job completion for craft-required jobs
            if workshop.currentJob != nil && workshop.checkJobCompletion(craftedItem: craftedItem) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.completeCurrentJob()
                }
            }

            // Append reward info to educational popup
            workshop.educationalText += "\n\n+\(GameRewards.craftCompleteFlorins) florins earned!" + bonusText

            // Close furnace after educational popup
            withAnimation(.spring(response: 0.3)) {
                showFurnaceOverlay = false
                activeStation = nil
            }
        }
    }

    // MARK: - NPC Encounter (Foundation Models)

    /// Try to show an NPC encounter after station interaction.
    /// If available and not yet seen this session, shows the NPC overlay.
    /// Otherwise falls through to normal guidance.
    private func tryShowNPCEncounter(for station: ResourceStationType) {
        guard let vm = viewModel, let buildingId = vm.activeBuildingId else {
            showNextGuidance(forceRefresh: true)
            return
        }

        let buildingName = vm.buildingPlots.first(where: { $0.id == buildingId })?.building.name ?? ""
        let sciences = vm.buildingPlots.first(where: { $0.id == buildingId })?.building.sciences.map(\.rawValue) ?? []

        if #available(iOS 26.0, macOS 26.0, *) {
            let manager = NPCEncounterManager.shared
            guard manager.shouldShowNPC(station: station.rawValue, buildingId: buildingId) else {
                showNextGuidance(forceRefresh: true)
                return
            }

            Task {
                if let npc = await manager.getNPC(
                    station: station.rawValue,
                    buildingId: buildingId,
                    buildingName: buildingName,
                    sciences: sciences
                ) {
                    npcDisplayData = npc
                    npcPortrait = manager.currentPortrait
                    withAnimation(.spring(response: 0.3)) {
                        showNPCEncounter = true
                    }
                } else {
                    showNextGuidance(forceRefresh: true)
                }
            }
        } else {
            showNextGuidance(forceRefresh: true)
        }
    }
}

#Preview {
    WorkshopMapView(workshop: WorkshopState(), onEnterInterior: {}, returnToLessonPlotId: .constant(nil))
}
