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

    @Environment(\.dismiss) private var dismiss

    // Scene reference
    @State private var scene: WorkshopScene?

    // Player tracking
    @State private var playerPosition: CGPoint = CGPoint(x: 0.5, y: 0.5)
    @State private var playerIsWalking = false

    // Station lesson overlay
    @State private var showStationLesson = false
    @State private var pendingLessonStation: ResourceStationType?

    // Forest choice dialogue (after lesson)
    @State private var showForestChoice = false

    // Overlay states
    @State private var activeStation: ResourceStationType?
    @State private var showHintBubble = false
    @State private var showCollectionOverlay = false
    @State private var showWorkbenchOverlay = false
    @State private var showFurnaceOverlay = false

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
                            // Forest gets a special choice dialogue
                            withAnimation(.spring(response: 0.3)) {
                                showForestChoice = true
                            }
                        } else {
                            // Normal flow: show hint then collection
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

                // Layer 2b: Forest choice dialogue (after lesson)
                if showForestChoice {
                    forestChoiceOverlay
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
                            .font(.custom("EBGaramond-Italic", size: 14))
                            .foregroundStyle(RenaissanceColors.terracotta)
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
            }
        }
    }

    // MARK: - Scene Creation

    private func makeScene() -> WorkshopScene {
        if let existing = scene { return existing }

        let newScene = WorkshopScene()
        newScene.size = CGSize(width: 3500, height: 2500)
        newScene.scaleMode = .aspectFill

        // Player position updates
        newScene.onPlayerPositionChanged = { position, isWalking in
            self.playerPosition = position
            self.playerIsWalking = isWalking
        }

        // Station reached — show appropriate overlay or enter interior
        newScene.onStationReached = { stationType in
            self.activeStation = stationType
            dismissAllOverlays()

            switch stationType {
            case .craftingRoom:
                // Transition to interior crafting room
                if let onEnterInterior = onEnterInterior {
                    onEnterInterior()
                } else {
                    // Fallback: show inline overlay
                    withAnimation(.spring(response: 0.3)) {
                        showWorkbenchOverlay = true
                    }
                }
            default:
                // Resource station — check if bird lesson needed first
                if !workshop.stationsLessonSeen.contains(stationType),
                   OnboardingContent.lesson(for: stationType) != nil {
                    pendingLessonStation = stationType
                    withAnimation(.spring(response: 0.3)) {
                        showStationLesson = true
                    }
                } else {
                    // Already seen lesson — show hint then collection
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
        showForestChoice = false
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
                    onboardingState: onboardingState
                )
            } else {
                // Fallback if no viewModel
                VStack(spacing: 8) {
                    Button { dismiss() } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .font(.custom("EBGaramond-Italic", size: 16))
                        .foregroundStyle(RenaissanceColors.renaissanceBlue)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(RenaissanceColors.parchment.opacity(0.95))
                                .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                        )
                    }
                    Text("Workshop")
                        .font(.custom("Cinzel-Bold", size: 20))
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(RenaissanceColors.parchment.opacity(0.95))
                        )
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
                                    .font(.custom("EBGaramond-Regular", size: 12))
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
                                    .font(.custom("EBGaramond-Regular", size: 12))
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
                .shadow(color: .black.opacity(0.1), radius: 4, y: -2)
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
                            .font(.custom("Cinzel-Bold", size: 16))
                            .foregroundStyle(RenaissanceColors.sepiaInk)

                        Text(workshop.hintFor(station: station))
                            .font(.custom("EBGaramond-Italic", size: 14))
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
                    .shadow(color: .black.opacity(0.15), radius: 6, y: 3)
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

    // MARK: - Forest Choice Overlay

    private var forestChoiceOverlay: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    // Dismiss and go to normal collection
                    withAnimation(.spring(response: 0.3)) {
                        showForestChoice = false
                        showHintBubble = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        withAnimation(.spring(response: 0.3)) {
                            showCollectionOverlay = true
                        }
                    }
                }

            VStack(spacing: 24) {
                Spacer()

                // Bird sitting on top
                BirdCharacter(isSitting: true)
                    .frame(width: 180, height: 180)
                    .padding(.bottom, -36)

                // Dialogue bubble with choices
                VStack(spacing: 20) {
                    Text("The Forest Awaits!")
                        .font(.custom("Cinzel-Bold", size: 22))
                        .foregroundStyle(RenaissanceColors.sepiaInk)

                    Text("Italy's forests hold many secrets — from the mighty oaks of Tuscany to the stone pines of Rome. Would you like to collect timber, or explore the forest and learn about its trees?")
                        .font(.custom("EBGaramond-Regular", size: 17))
                        .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.8))
                        .multilineTextAlignment(.center)

                    VStack(spacing: 12) {
                        // Choice 1: Collect Timber
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                showForestChoice = false
                                showHintBubble = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                withAnimation(.spring(response: 0.3)) {
                                    showCollectionOverlay = true
                                }
                            }
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "tree")
                                    .font(.title3)
                                    .foregroundStyle(RenaissanceColors.warmBrown)

                                Text("Collect Timber")
                                    .font(.custom("EBGaramond-Regular", size: 17))
                                    .foregroundStyle(RenaissanceColors.sepiaInk)

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(RenaissanceColors.stoneGray)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(RenaissanceColors.parchment)
                                    .shadow(color: RenaissanceColors.warmBrown.opacity(0.2), radius: 4, y: 2)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(RenaissanceColors.ochre.opacity(0.5), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)

                        // Choice 2: Explore the Forest
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                showForestChoice = false
                                activeStation = nil
                            }
                            onNavigate?(.forest)
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "leaf.fill")
                                    .font(.title3)
                                    .foregroundStyle(RenaissanceColors.sageGreen)

                                Text("Explore the Forest")
                                    .font(.custom("EBGaramond-Regular", size: 17))
                                    .foregroundStyle(RenaissanceColors.sepiaInk)

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(RenaissanceColors.stoneGray)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(RenaissanceColors.parchment)
                                    .shadow(color: RenaissanceColors.sageGreen.opacity(0.2), radius: 4, y: 2)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(RenaissanceColors.sageGreen.opacity(0.5), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.top, 8)
                }
                .padding(28)
                .background(DialogueBubble())
                .padding(.horizontal, 40)

                Spacer()
            }
        }
    }

    // MARK: - Layer 5: Collection Overlay

    private func collectionOverlay(for station: ResourceStationType) -> some View {
        VStack {
            Spacer()

            VStack(spacing: 12) {
                Text("Collect from \(station.label)")
                    .font(.custom("Cinzel-Regular", size: 16))
                    .foregroundStyle(RenaissanceColors.sepiaInk)

                // Florins display
                if let vm = viewModel {
                    HStack(spacing: 4) {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(RenaissanceColors.goldSuccess)
                        Text("\(vm.goldFlorins) florins")
                            .font(.custom("Cinzel-Bold", size: 13))
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
                                workshop.statusMessage = "Not enough florins! Need \(material.cost)"
                                return
                            }
                            if workshop.collectFromStation(station, material: material) {
                                vm.goldFlorins -= material.cost
                                scene?.showCollectionEffect(at: station)
                                let total = workshop.totalStockFor(station: station)
                                scene?.updateStationStock(station, totalCount: total)
                            }
                        } label: {
                            VStack(spacing: 4) {
                                Text(material.icon)
                                    .font(.title2)
                                Text(material.rawValue)
                                    .font(.custom("EBGaramond-Regular", size: 12))
                                    .foregroundStyle(RenaissanceColors.sepiaInk)
                                    .lineLimit(1)
                                HStack(spacing: 2) {
                                    Text("×\(stock)")
                                        .font(.custom("EBGaramond-Regular", size: 12))
                                        .foregroundStyle(stock > 0 ? RenaissanceColors.sageGreen : RenaissanceColors.stoneGray)
                                    Image(systemName: "dollarsign.circle.fill")
                                        .font(.system(size: 9))
                                        .foregroundStyle(RenaissanceColors.goldSuccess)
                                    Text("\(material.cost)")
                                        .font(.custom("EBGaramond-Regular", size: 11))
                                        .foregroundStyle(canAfford ? RenaissanceColors.goldSuccess : RenaissanceColors.errorRed)
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
                        .disabled(stock <= 0 || !canAfford)
                    }
                }

                Button("Done") {
                    withAnimation(.spring(response: 0.3)) {
                        showCollectionOverlay = false
                        showHintBubble = false
                        activeStation = nil
                    }
                }
                .font(.custom("EBGaramond-Italic", size: 15))
                .foregroundStyle(RenaissanceColors.renaissanceBlue)
                .padding(.top, 4)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(RenaissanceColors.parchment.opacity(0.95))
                    .shadow(color: .black.opacity(0.15), radius: 8, y: -3)
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
                    .font(.custom("Cinzel-Regular", size: 18))
                    .foregroundStyle(RenaissanceColors.sepiaInk)

                // Recipe hint
                if let recipe = workshop.detectedRecipe {
                    HStack(spacing: 6) {
                        Text(recipe.output.icon)
                        Text(recipe.output.rawValue)
                            .font(.custom("EBGaramond-Italic", size: 15))
                            .foregroundStyle(RenaissanceColors.sageGreen)
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(RenaissanceColors.sageGreen)
                            .font(.caption)
                    }
                } else {
                    Text("Add materials to mix")
                        .font(.custom("EBGaramond-Italic", size: 14))
                        .foregroundStyle(RenaissanceColors.stoneGray)
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
                                            .font(.custom("EBGaramond-Regular", size: 11))
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
                    .font(.custom("EBGaramond-Italic", size: 15))
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
                    .font(.custom("EBGaramond-Italic", size: 15))
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
                    .font(.custom("EBGaramond-Italic", size: 15))
                    .foregroundStyle(RenaissanceColors.stoneGray)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(RenaissanceColors.parchment.opacity(0.95))
                    .shadow(color: .black.opacity(0.15), radius: 8, y: -3)
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
                    .foregroundStyle(RenaissanceColors.stoneGray.opacity(0.5))
            }
        }
    }

    // MARK: - Layer 7: Furnace Overlay

    private let furnaceOrange = Color(red: 0.9, green: 0.4, blue: 0.1)

    private var furnaceOverlay: some View {
        VStack {
            Spacer()

            VStack(spacing: 14) {
                Text("Furnace")
                    .font(.custom("Cinzel-Regular", size: 18))
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
                                        .font(.custom("EBGaramond-Regular", size: 13))
                                }
                            }
                            if let recipe = workshop.currentRecipe {
                                Text("→ \(recipe.output.icon) \(recipe.output.rawValue)")
                                    .font(.custom("EBGaramond-Italic", size: 13))
                                    .foregroundStyle(RenaissanceColors.sepiaInk)
                            }
                        }
                    } else {
                        Text("Mix ingredients at the Workbench first")
                            .font(.custom("EBGaramond-Italic", size: 14))
                            .foregroundStyle(RenaissanceColors.stoneGray)
                    }
                }

                // Temperature picker
                VStack(spacing: 4) {
                    Text("Temperature")
                        .font(.custom("EBGaramond-Regular", size: 13))
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
                            .font(.custom("Cinzel-Bold", size: 16))
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
                    .font(.custom("EBGaramond-Italic", size: 15))
                    .foregroundStyle(RenaissanceColors.stoneGray)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(RenaissanceColors.parchment.opacity(0.95))
                    .shadow(color: .black.opacity(0.15), radius: 8, y: -3)
            )
            .padding(.horizontal, 24)
            .padding(.bottom, 60)
        }
    }

    // MARK: - Educational Overlay

    private var educationalOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Did You Know?")
                    .font(.custom("Cinzel-Bold", size: 24))
                    .foregroundStyle(RenaissanceColors.sepiaInk)

                Text(workshop.educationalText)
                    .font(.custom("EBGaramond-Regular", size: 17))
                    .foregroundStyle(RenaissanceColors.sepiaInk)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Button("Continue") {
                    workshop.showEducationalPopup = false
                }
                .font(.custom("EBGaramond-Italic", size: 18))
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
                    .shadow(color: .black.opacity(0.2), radius: 12, y: 4)
            )
        }
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
            workshop.completeProcessing()
            // Close furnace after educational popup
            withAnimation(.spring(response: 0.3)) {
                showFurnaceOverlay = false
                activeStation = nil
            }
        }
    }
}

#Preview {
    WorkshopMapView(workshop: WorkshopState(), onEnterInterior: {})
}
