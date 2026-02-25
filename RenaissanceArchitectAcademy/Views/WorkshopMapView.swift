import SwiftUI
import SpriteKit

/// SwiftUI wrapper for the WorkshopScene SpriteKit mini-game
/// Layers: SpriteKit scene → companion overlay → UI bars → hint/collection/crafting overlays
struct WorkshopMapView: View {

    @Bindable var workshop: WorkshopState
    var viewModel: CityViewModel? = nil
    var notebookState: NotebookState? = nil
    var onNavigate: ((SidebarDestination) -> Void)? = nil
    var onBackToMenu: (() -> Void)? = nil
    var onEnterInterior: (() -> Void)? = nil
    var onboardingState: OnboardingState? = nil
    @Binding var returnToLessonPlotId: Int?

    @Environment(\.dismiss) private var dismiss

    // Scene reference
    @State private var scene: WorkshopScene?

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

    // Job system states
    @State private var jobBoardChoices: [WorkshopJob] = []
    @State private var completedJob: WorkshopJob?
    @State private var jobRewardFlorins: Int = 0
    @State private var jobStreakBonus: Int = 0

    // Magic Mouse scroll-to-zoom
    @State private var scrollMonitor: Any?

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Layer 1: SpriteKit scene
                SpriteView(scene: makeScene(), options: [.allowsTransparency])
                    .ignoresSafeArea()
                    .gesture(pinchGesture)

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
                            // Normal flow: show hint bubble with bird, then collection
                            withAnimation(.spring(response: 0.3)) {
                                showHintBubble = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                withAnimation(.spring(response: 0.3)) {
                                    showCollectionOverlay = true
                                }
                            }
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
                .padding(16)

                // Status message overlay
                if let status = workshop.statusMessage {
                    VStack {
                        Text(status)
                            .font(.custom("Mulish-Light", size: 14))
                            .foregroundStyle(RenaissanceColors.sepiaInk)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(RenaissanceColors.parchment.opacity(0.95))
                            )
                        Spacer()
                    }
                    .padding(.top, 8)
                    .allowsHitTesting(false)
                }

                // Layer 4: Hint bubble (Splash shows text at resource nodes)
                if showHintBubble, let station = activeStation {
                    hintBubbleOverlay(for: station)
                        .transition(.opacity.combined(with: .scale(scale: 0.9)))
                }

                // Layer 5: Collection overlay (tap to collect materials)
                if showCollectionOverlay, let station = activeStation {
                    collectionOverlay(for: station)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }

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
            #if os(macOS)
            scrollMonitor = NSEvent.addLocalMonitorForEvents(matching: .scrollWheel) { [self] event in
                if !showCollectionOverlay && !showHintBubble && !showWorkbenchOverlay && !showFurnaceOverlay && !workshop.showEducationalPopup && !workshop.showJobBoard && !workshop.showJobComplete {
                    scene?.handleScrollZoom(deltaY: event.deltaY)
                }
                return event
            }
            #endif
        }
        .onDisappear {
            #if os(macOS)
            if let monitor = scrollMonitor {
                NSEvent.removeMonitor(monitor)
                scrollMonitor = nil
            }
            #endif
        }
    }

    // MARK: - Scene Creation

    private func makeScene() -> WorkshopScene {
        if let existing = scene { return existing }

        let newScene = WorkshopScene()
        newScene.size = CGSize(width: 3500, height: 2500)
        newScene.scaleMode = .aspectFill
        newScene.apprenticeIsBoy = onboardingState?.apprenticeGender == .boy || onboardingState == nil

        // Player position updates
        newScene.onPlayerPositionChanged = { position, isWalking in
            self.playerPosition = position
            self.playerIsWalking = isWalking
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
            case .forest:
                // Navigate to forest scene
                activeStation = nil
                onNavigate?(.forest)
            default:
                // Show hint bubble + collection overlay
                withAnimation(.spring(response: 0.3)) {
                    showHintBubble = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    withAnimation(.spring(response: 0.3)) {
                        showCollectionOverlay = true
                    }
                }
            }
        }

        // Sync initial stock displays
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            syncAllStationStocks(in: newScene)
        }

        scene = newScene
        return newScene
    }

    private func syncAllStationStocks(in scene: WorkshopScene) {
        for stationType in ResourceStationType.allCases where !stationType.isCraftingStation {
            let total = workshop.totalStockFor(station: stationType)
            scene.updateStationStock(stationType, totalCount: total)
        }
    }

    private func dismissAllOverlays() {
        showHintBubble = false
        showCollectionOverlay = false
        showWorkbenchOverlay = false
        showFurnaceOverlay = false
        showStationLesson = false
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
                    } : nil
                )
            } else {
                // Fallback if no viewModel
                VStack(spacing: 8) {
                    Button { dismiss() } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .font(.custom("Mulish-Light", size: 16))
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .glassButton(shape: Capsule())
                    }
                    Text("Workshop")
                        .font(.custom("EBGaramond-SemiBold", size: 22))
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .glassButton(shape: Capsule())
                }
            }
        }
    }

    private var inventoryBar: some View {
        HStack(spacing: 0) {
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
                                    .font(.custom("Mulish-Light", size: 12))
                                    .foregroundStyle(RenaissanceColors.sepiaInk)
                            }
                            .padding(.horizontal, 6)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(RenaissanceColors.parchment.opacity(0.8))
                            )
                        }
                    }
                }
            }

            Divider()
                .frame(height: 30)
                .padding(.horizontal, 8)

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
                                    .font(.custom("Mulish-Light", size: 12))
                                    .foregroundStyle(RenaissanceColors.sageGreen)
                            }
                            .padding(.horizontal, 6)
                            .padding(.vertical, 4)
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
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(RenaissanceColors.parchment.opacity(0.92))
        )
    }

    // MARK: - Layer 4: Hint Bubble

    private func hintBubbleOverlay(for station: ResourceStationType) -> some View {
        VStack {
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    BirdCharacter()
                        .frame(width: 80, height: 80)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(station.label)
                            .font(.custom("EBGaramond-SemiBold", size: 18))
                            .foregroundStyle(RenaissanceColors.sepiaInk)

                        Text(workshop.hintFor(station: station))
                            .font(.custom("Mulish-Light", size: 14))
                            .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.8))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: 360)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(RenaissanceColors.parchment.opacity(0.95))
            )
            .padding(.top, 80)

            Spacer()
        }
        .onTapGesture {
            withAnimation(.easeOut(duration: 0.2)) {
                showHintBubble = false
            }
        }
    }

    // MARK: - Layer 5: Collection Overlay

    private func collectionOverlay(for station: ResourceStationType) -> some View {
        VStack {
            Spacer()

            VStack(spacing: 12) {
                Text("Collect from \(station.label)")
                    .font(.custom("EBGaramond-SemiBold", size: 18))
                    .foregroundStyle(RenaissanceColors.sepiaInk)

                // Florins display
                if let vm = viewModel {
                    HStack(spacing: 4) {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.custom("Mulish-Light", size: 14, relativeTo: .footnote))
                            .foregroundStyle(RenaissanceColors.sepiaInk)
                        Text("\(vm.goldFlorins) florins")
                            .font(.custom("EBGaramond-Regular", size: 15))
                            .foregroundStyle(RenaissanceColors.sepiaInk)
                    }
                    .padding(.bottom, 4)
                }

                HStack(spacing: 16) {
                    ForEach(station.materials, id: \.self) { material in
                        let stock = workshop.stationStocks[station]?[material] ?? 0
                        let canAfford = (viewModel?.goldFlorins ?? 0) >= material.cost
                        Button {
                            // Check florins before collecting
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
                                scene?.showCollectionEffect(at: station)
                                scene?.playPlayerCelebrateAnimation()
                                let total = workshop.totalStockFor(station: station)
                                scene?.updateStationStock(station, totalCount: total)

                                // Check job completion for collection-only jobs
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
                            VStack(spacing: 4) {
                                Text(material.icon)
                                    .font(.title2)
                                Text(material.rawValue)
                                    .font(.custom("Mulish-Light", size: 12))
                                    .foregroundStyle(RenaissanceColors.sepiaInk)
                                    .lineLimit(1)
                                HStack(spacing: 2) {
                                    Text("×\(stock)")
                                        .font(.custom("Mulish-Light", size: 12))
                                        .foregroundStyle(stock > 0 ? RenaissanceColors.sageGreen : RenaissanceColors.sepiaInk)
                                    Image(systemName: "dollarsign.circle.fill")
                                        .font(.custom("Mulish-Light", size: 9, relativeTo: .caption2))
                                        .foregroundStyle(RenaissanceColors.sepiaInk)
                                    Text("\(material.cost)")
                                        .font(.custom("Mulish-Light", size: 11))
                                        .foregroundStyle(canAfford ? RenaissanceColors.sepiaInk : RenaissanceColors.errorRed)
                                }
                            }
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(stock > 0 && canAfford ? RenaissanceColors.parchment : RenaissanceColors.stoneGray.opacity(0.15))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .strokeBorder(stock > 0 && canAfford ? RenaissanceColors.renaissanceBlue : RenaissanceColors.stoneGray.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .disabled(stock <= 0)
                    }
                }

                Button("Done") {
                    withAnimation(.spring(response: 0.3)) {
                        showCollectionOverlay = false
                        showHintBubble = false
                        activeStation = nil
                    }
                }
                .font(.custom("Mulish-Light", size: 15))
                .foregroundStyle(RenaissanceColors.sepiaInk)
                .padding(.top, 4)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(RenaissanceColors.parchment.opacity(0.95))
            )
            .padding(.horizontal, 24)
            .padding(.bottom, 60)
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
                            .font(.custom("Mulish-Light", size: 15))
                            .foregroundStyle(RenaissanceColors.sageGreen)
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(RenaissanceColors.sageGreen)
                            .font(.caption)
                    }
                } else {
                    Text("Add materials to mix")
                        .font(.custom("Mulish-Light", size: 14))
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
                                            .font(.custom("Mulish-Light", size: 11))
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
                    .font(.custom("Mulish-Light", size: 15))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
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
                    .font(.custom("Mulish-Light", size: 15))
                    .padding(.horizontal, 24)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
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
                    .font(.custom("Mulish-Light", size: 15))
                    .foregroundStyle(RenaissanceColors.sepiaInk)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(RenaissanceColors.parchment.opacity(0.95))
            )
            .padding(.horizontal, 24)
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
                    RoundedRectangle(cornerRadius: 12)
                        .fill(RenaissanceColors.terracotta.opacity(0.3))
                        .frame(height: 80)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(RenaissanceColors.terracotta, lineWidth: 2)
                        )

                    if workshop.isProcessing {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(furnaceOrange.opacity(0.25))
                            .frame(height: 80)
                            .blur(radius: 8)
                    }

                    if let input = workshop.furnaceInput {
                        VStack(spacing: 4) {
                            HStack(spacing: 4) {
                                ForEach(Array(input.keys.sorted(by: { $0.rawValue < $1.rawValue })), id: \.self) { material in
                                    Text("\(material.icon)×\(input[material]!)")
                                        .font(.custom("Mulish-Light", size: 13))
                                }
                            }
                            if let recipe = workshop.currentRecipe {
                                Text("→ \(recipe.output.icon) \(recipe.output.rawValue)")
                                    .font(.custom("Mulish-Light", size: 13))
                                    .foregroundStyle(RenaissanceColors.sepiaInk)
                            }
                        }
                    } else {
                        Text("Mix ingredients at the Workbench first")
                            .font(.custom("Mulish-Light", size: 14))
                            .foregroundStyle(RenaissanceColors.sepiaInk)
                    }
                }

                // Temperature picker
                VStack(spacing: 4) {
                    Text("Temperature")
                        .font(.custom("Mulish-Light", size: 13))
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
                            .font(.custom("EBGaramond-SemiBold", size: 18))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
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
                    .font(.custom("Mulish-Light", size: 15))
                    .foregroundStyle(RenaissanceColors.sepiaInk)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(RenaissanceColors.parchment.opacity(0.95))
            )
            .padding(.horizontal, 24)
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
                    .font(.custom("Mulish-Light", size: 17, relativeTo: .body))
                    .foregroundStyle(RenaissanceColors.sepiaInk)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Button("Continue") {
                    workshop.showEducationalPopup = false
                }
                .font(.custom("Mulish-Light", size: 18))
                .padding(.horizontal, 32)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(RenaissanceColors.renaissanceBlue)
                )
                .foregroundStyle(.white)
            }
            .padding(32)
            .frame(maxWidth: 500)
            .background(
                RoundedRectangle(cornerRadius: 16)
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
                            .font(.custom("Mulish-Light", size: 14))
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
                .font(.custom("Mulish-Light", size: 15))
                .foregroundStyle(RenaissanceColors.sepiaInk)
            }
            .padding(24)
            .frame(maxWidth: 400)
            .background(
                RoundedRectangle(cornerRadius: 16)
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
                        RoundedRectangle(cornerRadius: 8)
                            .fill(RenaissanceColors.warmBrown.opacity(0.1))
                    )

                Text(title)
                    .font(.custom("EBGaramond-Regular", size: 16))
                    .foregroundStyle(RenaissanceColors.sepiaInk)

                Spacer()

                Text(reward)
                    .font(.custom("Mulish-SemiBold", size: 13))
                    .foregroundStyle(RenaissanceColors.sepiaInk)

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(RenaissanceColors.sepiaInk)
            }
            .padding(12)
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
                            .foregroundStyle(RenaissanceColors.warmBrown)

                        Text("Bottega Jobs")
                            .font(.custom("Mulish-Medium", size: 13))
                            .foregroundStyle(RenaissanceColors.sepiaInk)

                        Image(systemName: "chevron.right")
                            .font(.system(size: 10))
                            .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.5))
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(RenaissanceColors.parchment.opacity(0.92))
                    )
                    .overlay(
                        Capsule()
                            .strokeBorder(RenaissanceColors.warmBrown.opacity(0.3), lineWidth: 1)
                    )
                }
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
                            .font(.custom("Mulish-Medium", size: 13))
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
                                    .font(.custom("Mulish-Light", size: 11))
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
                                    .font(.custom("Mulish-Light", size: 11))
                                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.6))
                            }
                        }
                    }

                    // Check if collection complete — show "Complete!" or craft reminder
                    if workshop.isJobCollectionDone() {
                        if job.craftTarget != nil {
                            Text("Materials ready! Craft at the workbench.")
                                .font(.custom("Mulish-Light", size: 11))
                                .foregroundStyle(RenaissanceColors.renaissanceBlue)
                        } else {
                            Button {
                                completeCurrentJob()
                            } label: {
                                Text("Turn In Job")
                                    .font(.custom("Mulish-Medium", size: 12))
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
                            .font(.custom("Mulish-Light", size: 10))
                            .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.4))
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(RenaissanceColors.parchment.opacity(0.92))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(RenaissanceColors.warmBrown.opacity(0.3), lineWidth: 1)
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
                            .font(.custom("Mulish-Light", size: 14))
                            .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))
                    }
                }

                // Tier + streak info
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Text("Rank:")
                            .font(.custom("Mulish-Light", size: 13))
                            .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.6))
                        Text("\(workshop.currentJobTier.icon) \(workshop.currentJobTier.italianTitle)")
                            .font(.custom("EBGaramond-SemiBold", size: 15))
                            .foregroundStyle(RenaissanceColors.sepiaInk)
                    }
                    if workshop.jobStreak > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                                .font(.caption)
                                .foregroundStyle(RenaissanceColors.furnaceOrange)
                            Text("Streak: \(workshop.jobStreak)")
                                .font(.custom("Mulish-Light", size: 13))
                                .foregroundStyle(RenaissanceColors.sepiaInk)
                        }
                    }
                    HStack(spacing: 4) {
                        Text("Jobs: \(workshop.totalJobsCompleted)")
                            .font(.custom("Mulish-Light", size: 13))
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
                .font(.custom("Mulish-Light", size: 15))
                .foregroundStyle(RenaissanceColors.sepiaInk)
            }
            .padding(24)
            .frame(maxWidth: 500)
            .background(
                RoundedRectangle(cornerRadius: 16)
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
                        .font(.custom("EBGaramond-SemiBold", size: 17))
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
                        .font(.custom("Mulish-Light", size: 12))
                        .foregroundStyle(tierColor(job.tier))
                }

                // Flavor text
                Text(job.flavorText)
                    .font(.custom("Mulish-Light", size: 13))
                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)

                // Requirements
                HStack(spacing: 8) {
                    ForEach(Array(job.requirements.keys.sorted(by: { $0.rawValue < $1.rawValue })), id: \.self) { material in
                        HStack(spacing: 2) {
                            Text(material.icon)
                                .font(.caption2)
                            Text("×\(job.requirements[material]!)")
                                .font(.custom("Mulish-Light", size: 12))
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
                                .font(.custom("Mulish-Light", size: 12))
                                .foregroundStyle(RenaissanceColors.sageGreen)
                        }
                    }
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(RenaissanceColors.parchment.opacity(0.6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
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
                        .font(.custom("Mulish-Light", size: 14))
                        .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))
                        .multilineTextAlignment(.center)
                }

                // Rewards
                VStack(spacing: 6) {
                    HStack(spacing: 6) {
                        Image(systemName: "dollarsign.circle.fill")
                            .foregroundStyle(RenaissanceColors.iconOchre)
                        Text("+\(jobRewardFlorins) florins")
                            .font(.custom("EBGaramond-SemiBold", size: 18))
                            .foregroundStyle(RenaissanceColors.sepiaInk)
                    }
                    if jobStreakBonus > 0 {
                        HStack(spacing: 6) {
                            Image(systemName: "flame.fill")
                                .foregroundStyle(RenaissanceColors.furnaceOrange)
                            Text("+\(jobStreakBonus) streak bonus!")
                                .font(.custom("Mulish-Medium", size: 15))
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
                        .font(.custom("Mulish-Light", size: 15))
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
                        .font(.custom("Mulish-Medium", size: 14))
                        .foregroundStyle(RenaissanceColors.renaissanceBlue)
                        .multilineTextAlignment(.center)
                } else if workshop.totalJobsCompleted == 15 && workshop.currentJobTier == .master {
                    Text("Promoted to Maestro! You can now take Master commissions.")
                        .font(.custom("Mulish-Medium", size: 14))
                        .foregroundStyle(RenaissanceColors.goldSuccess)
                        .multilineTextAlignment(.center)
                }

                Button("Next Commission") {
                    workshop.showJobComplete = false
                    completedJob = nil
                    jobBoardChoices = workshop.jobChoices()
                    workshop.showJobBoard = true
                }
                .font(.custom("Mulish-Medium", size: 16))
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
                .font(.custom("Mulish-Light", size: 14))
                .foregroundStyle(RenaissanceColors.sepiaInk)
            }
            .padding(28)
            .frame(maxWidth: 480)
            .background(
                RoundedRectangle(cornerRadius: 16)
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

    // MARK: - Gestures

    private var pinchGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                scene?.handlePinch(scale: value)
            }
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
