import SwiftUI
import SpriteKit
import Subsonic

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

    // Avatar box: portrait visible only when player hasn't moved yet
    @State private var avatarInBox = true

    // Job system states
    @State private var jobBoardChoices: [WorkshopJob] = []
    @State private var completedJob: WorkshopJob?
    @State private var jobRewardFlorins: Int = 0
    @State private var jobStreakBonus: Int = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Layer 1: SpriteKit scene
                GameSpriteView(scene: makeScene(), options: [.allowsTransparency])
                    .ignoresSafeArea()

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
                            // After dismissing cards, show single station overlay
                            showSingleStationOverlay()
                        }
                    )
                    .transition(.opacity)
                }

                // Educational popup
                if workshop.showEducationalPopup {
                    educationalOverlay
                        .transition(.opacity.combined(with: .scale(scale: 0.9)))
                }

                // Earn Florins overlay (shown when player can't afford materials)
                if workshop.showEarnFlorinsOverlay {
                    earnFlorinsOverlay
                        .transition(.opacity.combined(with: .scale(scale: 0.9)))
                }

                // Bottega job progress card (replaces master task card when job active)
                if let job = workshop.currentJob,
                   !workshop.showEarnFlorinsOverlay,
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
                   !workshop.showEarnFlorinsOverlay,
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
        .onAppear {
            if workshop.currentAssignment == nil {
                workshop.generateNewAssignment()
            }
        }
        .onChange(of: activeStation) { oldValue, newValue in
            if oldValue != nil && newValue == nil {
                // Station overlay dismissed — zoom camera back out
                sceneHolder.scene?.zoomCameraOut()
                // Player walks back to box position
                sceneHolder.scene?.hidePlayer()
                avatarInBox = true
            }
        }
        .onChange(of: playerIsWalking) { _, isWalking in
            if isWalking && avatarInBox {
                // Hide the SwiftUI sprite image — SpriteKit player walks from same spot
                avatarInBox = false
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


        // Station reached — show hint bubble + collection overlay
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
                // Check for knowledge cards at this station for the active building
                let stationKey = "\(stationType)"  // enum case name matches KnowledgeCard stationKey
                if let buildingName = viewModel?.activeBuildingName {
                    let cards = KnowledgeCardContent.cards(for: buildingName, at: stationKey)
                    let progress = viewModel?.buildingProgressMap[viewModel?.activeBuildingId ?? 0] ?? BuildingProgress()
                    let incompleteCards = cards.filter { !progress.completedCardIDs.contains($0.id) }
                    if !incompleteCards.isEmpty {
                        stationKnowledgeCards = cards
                        SubsonicController.shared.play(sound: "cards_appear.mp3")
                        withAnimation(.spring(response: 0.3)) {
                            showStationKnowledgeCards = true
                        }
                        return
                    }
                }
                // No knowledge cards — show single station overlay
                showSingleStationOverlay()
            }
        }

        // @State cannot be set during body — defer to next runloop
        sceneHolder.scene = newScene
        return newScene
    }


    private func dismissAllOverlays() {
        showHintBubble = false
        showCollectionOverlay = false
        showWorkbenchOverlay = false
        showFurnaceOverlay = false
        showStationLesson = false
    }

    /// Show a single overlay based on tool ownership:
    /// - No tool → tool requirement dialog (collectionOverlay)
    /// - Has tool → enhanced hint bubble with collection buttons built in
    private func showSingleStationOverlay() {
        guard let station = activeStation else { return }
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
                            Text(tool.icon)
                                .font(.caption)
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
                                Text(material.icon)
                                    .font(.caption)
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
                Text(tool.icon)
                    .font(.system(size: 28))
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
                withAnimation(.spring(response: 0.3)) {
                    showCollectionOverlay = false
                    showHintBubble = false
                    activeStation = nil
                }
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
        VStack(spacing: 10) {
            // Only shown when player lacks the required tool
            if let requiredTool = Tool.requiredFor(station: station) {
                toolRequirementView(tool: requiredTool, station: station)
            } else {
                // Fallback (station has no tool requirement) — show collection
                collectionMaterialsView(for: station)
            }
        }
        .padding(Spacing.md)
        .frame(width: 280)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.lg)
                .fill(settings.cardBackground)
        )
        .padding(.trailing, Spacing.md)
    }

    /// Shows when player lacks the tool for a station — compact right-side card
    private func toolRequirementView(tool: Tool, station: ResourceStationType) -> some View {
        VStack(spacing: 10) {
            HStack(spacing: 8) {
                Text(tool.icon)
                    .font(.system(size: 32))
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
                    withAnimation(.spring(response: 0.3)) {
                        showCollectionOverlay = false
                        showHintBubble = false
                        activeStation = nil
                    }
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
                    HStack(spacing: 4) {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.caption)
                            .foregroundStyle(settings.pillTextColor)
                        Text("\(vm.goldFlorins)")
                            .font(.custom("EBGaramond-Regular", size: 15))
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
                                }
                                workshop.showEarnFlorinsOverlay = true
                                return
                            }
                            if workshop.collectFromStation(station, material: material) {
                                vm.goldFlorins -= material.cost
                                sceneHolder.scene?.showCollectionEffect(at: station)
                                sceneHolder.scene?.playPlayerCelebrateAnimation()

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
                            }
                        } label: {
                            VStack(spacing: 2) {
                                Text(material.icon)
                                    .font(.body)
                                Text(material.rawValue)
                                    .font(.custom("EBGaramond-Regular", size: 13))
                                    .foregroundStyle(settings.cardTextColor)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                                HStack(spacing: 2) {
                                    Image(systemName: "dollarsign.circle.fill")
                                        .font(.system(size: 9))
                                        .foregroundStyle(settings.cardTextColor)
                                    Text("\(material.cost)")
                                        .font(.custom("EBGaramond-Regular", size: 12))
                                        .foregroundStyle(canAfford ? settings.cardTextColor : RenaissanceColors.errorRed)
                                }
                            }
                            .padding(6)
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
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 6), GridItem(.flexible(), spacing: 6)], spacing: 6) {
            ForEach(ResourceStationType.market.materials, id: \.self) { material in
                let canAfford = (viewModel?.goldFlorins ?? 0) >= material.cost
                Button {
                    guard let vm = viewModel else { return }
                    guard vm.goldFlorins >= material.cost else {
                        withAnimation(.spring(response: 0.3)) {
                            showCollectionOverlay = false
                            showHintBubble = false
                        }
                        workshop.showEarnFlorinsOverlay = true
                        return
                    }
                    if workshop.collectFromStation(.market, material: material) {
                        vm.goldFlorins -= material.cost
                        sceneHolder.scene?.showCollectionEffect(at: .market)
                        sceneHolder.scene?.playPlayerCelebrateAnimation()
                    }
                } label: {
                    VStack(spacing: 2) {
                        Text(material.icon)
                            .font(.body)
                        Text(material.rawValue)
                            .font(.custom("EBGaramond-Regular", size: 10))
                            .foregroundStyle(settings.cardTextColor)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                        HStack(spacing: 1) {
                            Image(systemName: "dollarsign.circle.fill")
                                .font(.system(size: 8))
                                .foregroundStyle(settings.cardTextColor)
                            Text("\(material.cost)")
                                .font(.custom("EBGaramond-Regular", size: 10))
                                .foregroundStyle(canAfford ? settings.cardTextColor : RenaissanceColors.errorRed)
                        }
                    }
                    .padding(6)
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
                            }
                            workshop.showEarnFlorinsOverlay = true
                            return
                        }
                        if workshop.buyTool(tool) {
                            vm.goldFlorins -= cost
                            sceneHolder.scene?.playPlayerCelebrateAnimation()
                            workshop.statusMessage = "Bought \(tool.icon) \(tool.displayName)!"
                        }
                    } label: {
                        VStack(spacing: 4) {
                            Text(tool.icon)
                                .font(.title2)

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
                                        Text(material.icon)
                                            .font(.title3)
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
                Text(material.icon)
                    .font(.title2)
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
            .frame(maxWidth: 500)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.lg)
                    .fill(RenaissanceColors.parchment)
            )
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
            .frame(maxWidth: 400)
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
            .padding(.top, 420)

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
            .padding(.top, 420)

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
            .frame(maxWidth: 500)
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
            .frame(maxWidth: 480)
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
}

#Preview {
    WorkshopMapView(workshop: WorkshopState(), onEnterInterior: {}, returnToLessonPlotId: .constant(nil))
}
