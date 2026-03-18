import SwiftUI
import SpriteKit
import Subsonic

/// SwiftUI wrapper for the CraftingRoomScene SpriteKit interior
/// Layers: SpriteKit scene → UI bars → station overlays → educational/earn popups → master task card
struct CraftingRoomMapView: View {

    @Bindable var workshop: WorkshopState
    var viewModel: CityViewModel? = nil
    var onNavigate: ((SidebarDestination) -> Void)? = nil
    var onBackToMenu: (() -> Void)? = nil
    var onboardingState: OnboardingState? = nil
    @Binding var returnToLessonPlotId: Int?
    var notebookState: NotebookState? = nil
    var onBack: () -> Void

    // Scene reference — stored in a class box so it survives body re-evaluation
    // without triggering re-renders (unlike @State which causes infinite loops)
    @State private var sceneHolder = SceneHolder<CraftingRoomScene>()

    // Player tracking
    @State private var playerPosition: CGPoint = CGPoint(x: 0.5, y: 0.5)
    @State private var playerIsWalking = false

    // Active station overlay
    @State private var activeStation: CraftingStation? = nil

    // Knowledge cards at crafting stations
    @State private var showCraftingKnowledgeCards = false
    @State private var craftingKnowledgeCards: [KnowledgeCard] = []

    // Discovery card (no active building)
    @State private var showDiscoveryCard = false
    @State private var discoveryCard: DiscoveryCard? = nil

    // Avatar box: sprite visible only when player hasn't moved yet
    @State private var avatarInBox = true

    // Bird guidance state
    @State private var showGuidance = false
    @State private var guidanceMessage: String = ""
    @State private var guidanceDestination: SidebarDestination? = nil


    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Layer 1: SpriteKit scene
                GameSpriteView(scene: makeScene(), options: [.allowsTransparency])
                    .ignoresSafeArea()

                // Layer 2: Nav + inventory
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

                // Layer 3: Station overlays (hidden when knowledge cards showing)
                if let station = activeStation, !showCraftingKnowledgeCards {
                    RenaissanceColors.overlayDimming
                        .ignoresSafeArea()
                        .onTapGesture { dismissOverlay() }
                        .transition(.opacity)

                    stationOverlay(for: station)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                // Knowledge cards at crafting stations
                if showCraftingKnowledgeCards, !craftingKnowledgeCards.isEmpty,
                   let vm = viewModel, let bid = vm.activeBuildingId {
                    KnowledgeCardsOverlay(
                        cards: craftingKnowledgeCards,
                        buildingId: bid,
                        viewModel: vm,
                        notebookState: notebookState,
                        onDismiss: {
                            withAnimation {
                                showCraftingKnowledgeCards = false
                                craftingKnowledgeCards = []
                            }
                            // activeStation is already set; the normal overlay will show
                        },
                        onNavigate: { destination in
                            withAnimation {
                                showCraftingKnowledgeCards = false
                                craftingKnowledgeCards = []
                                activeStation = nil
                            }
                            onNavigate?(destination)
                        },
                        playerName: onboardingState?.apprenticeName ?? "Apprentice"
                    )
                    .transition(.opacity)
                }

                // Discovery card (no active building)
                if showDiscoveryCard, let card = discoveryCard {
                    DiscoveryCardOverlay(
                        card: card,
                        onDismiss: {
                            withAnimation {
                                showDiscoveryCard = false
                                discoveryCard = nil
                            }
                            // activeStation is already set; the normal overlay will show
                        },
                        onChooseBuilding: {
                            withAnimation {
                                showDiscoveryCard = false
                                discoveryCard = nil
                                activeStation = nil
                            }
                            onNavigate?(.cityMap)
                        },
                        playerName: onboardingState?.apprenticeName ?? "Apprentice"
                    )
                    .transition(.opacity)
                }

                // Bird guidance — tells player where to go next
                if showGuidance {
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
                                if let dest = guidanceDestination {
                                    Button {
                                        withAnimation(.easeOut(duration: 0.2)) { showGuidance = false }
                                        if dest == .workshop {
                                            // Crafting room is inside workshop — use back button
                                            onBack()
                                        } else {
                                            onNavigate?(dest)
                                        }
                                    } label: {
                                        HStack(spacing: 5) {
                                            Image(systemName: dest == .forest ? "tree.fill" : dest == .workshop ? "hammer.fill" : "building.columns.fill")
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
                            Spacer()
                            Button {
                                withAnimation(.easeOut(duration: 0.3)) { showGuidance = false }
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
                            RoundedRectangle(cornerRadius: CornerRadius.lg)
                                .fill(RenaissanceColors.parchment.opacity(0.95))
                        )
                        .borderWorkshop()
                        .padding(.horizontal, Spacing.lg)
                        .padding(.bottom, Spacing.xl)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(50)
                }

                // Layer 4: Educational popup
                if workshop.showEducationalPopup {
                    educationalOverlay
                        .transition(.opacity.combined(with: .scale(scale: 0.9)))
                }

                // (Earn Florins overlay removed — bird guidance handles this now)

                // Layer 4c: Master task card
                if let assignment = workshop.currentAssignment,
                   activeStation == nil,
                   !workshop.showEducationalPopup {
                    masterTaskCard(assignment: assignment)
                }
            }
        }
        .onAppear {
            if workshop.currentAssignment == nil {
                workshop.generateNewAssignment()
            }
            // Show bird guidance after short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                showCraftingGuidance()
            }
        }
        .onDisappear {
            // Release scene to free SpriteKit texture memory when navigating away
            sceneHolder.scene = nil
        }
        .onChange(of: activeStation) { oldValue, newValue in
            if oldValue != nil && newValue == nil {
                // Station overlay dismissed — player stays where they are
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showCraftingGuidance()
                }
            }
        }
        .onChange(of: workshop.showEducationalPopup) { _, isShowing in
            if !isShowing {
                // Educational popup dismissed after crafting — show guidance
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showCraftingGuidance()
                }
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
    }

    // MARK: - Scene Creation

    private func makeScene() -> CraftingRoomScene {
        if let existing = sceneHolder.scene { return existing }

        let newScene = CraftingRoomScene()
        newScene.size = CGSize(width: 3500, height: 2500)
        newScene.scaleMode = .aspectFill
        newScene.apprenticeIsBoy = onboardingState?.apprenticeGender == .boy || onboardingState == nil

        newScene.onPlayerPositionChanged = { position, isWalking in
            self.playerPosition = position
            self.playerIsWalking = isWalking
        }

        newScene.onPlayerStartedWalking = {
            withAnimation(.easeOut(duration: 0.2)) {
                self.activeStation = nil
            }
        }

        newScene.onFurnitureReached = { station in
            // Tool gate: pigment table requires mortar & pestle
            if station == .pigmentTable {
                let hasMortar = (self.workshop.tools[.mortarAndPestle] ?? 0) > 0
                if !hasMortar {
                    self.workshop.statusMessage = "You need a Mortar & Pestle to use the Pigment Table. Craft one at the Workbench!"
                    return
                }
            }

            // Dismiss any stale guidance before showing station overlay
            self.showGuidance = false

            // Check for next uncompleted knowledge card at this station
            let stationKey = "\(station)"  // enum case name matches KnowledgeCard stationKey
            if let vm = viewModel, let bid = vm.activeBuildingId,
               let nextCard = vm.nextUncompletedCard(for: bid, at: stationKey) {
                self.craftingKnowledgeCards = [nextCard]
                self.activeStation = station  // remember which station for after cards
                SubsonicController.shared.play(sound: "cards_appear.mp3")
                withAnimation(.spring(response: 0.3)) {
                    self.showCraftingKnowledgeCards = true
                }
                return
            }
            // No active building — show discovery card if available
            if let vm = viewModel, vm.activeBuildingId == nil,
               let card = DiscoveryCardContent.card(for: stationKey) {
                self.discoveryCard = card
                self.activeStation = station
                SubsonicController.shared.play(sound: "cards_appear.mp3")
                withAnimation(.spring(response: 0.3)) {
                    self.showDiscoveryCard = true
                }
                return
            }
            // No knowledge cards — show normal station overlay
            withAnimation(.spring(response: 0.3)) {
                self.activeStation = station
            }
        }

        sceneHolder.scene = newScene
        return newScene
    }

    private func dismissOverlay() {
        withAnimation(.spring(response: 0.3)) {
            activeStation = nil
        }
    }

    // MARK: - Bird Guidance

    private func showCraftingGuidance() {
        guard let vm = viewModel, let bid = vm.activeBuildingId else { return }
        guard !showCraftingKnowledgeCards && activeStation == nil
                && !workshop.showEducationalPopup else { return }

        let buildingName = vm.buildingPlots.first(where: { $0.id == bid })?.building.name ?? ""
        let building = vm.buildingPlots.first(where: { $0.id == bid })?.building
        let progress = vm.buildingProgressMap[bid] ?? BuildingProgress()

        // --- Material awareness: what's crafted, what's needed ---
        let required = building?.requiredMaterials ?? [:]
        let craftedCount = required.filter { (item, qty) in
            (workshop.craftedMaterials[item] ?? 0) >= qty
        }.count
        let totalRequired = required.count

        // LOCAL WORK FIRST: check if there's something useful to do here

        // 0. Is there something in the furnace ready to fire? Guide to furnace!
        if workshop.furnaceInput != nil && !workshop.isProcessing {
            let recipeName = workshop.currentRecipe?.output.rawValue ?? "your mixture"
            guidanceMessage = "Head to the Furnace — fire \(recipeName) to finish crafting! (\(craftedCount)/\(totalRequired) materials crafted)"
            guidanceDestination = nil
            withAnimation(.spring(response: 0.4)) { showGuidance = true }
            return
        }

        // 1. Can the player craft a recipe right now? Tell them the recipe + temperature!
        if let building = building, let recipe = nextCraftableRecipeInCraftingRoom(for: building) {
            let ingredientList = recipe.ingredients.map { "\($0.value) \($0.key.rawValue)" }.joined(separator: " + ")
            guidanceMessage = "You can craft \(recipe.output.rawValue)! Mix \(ingredientList) at \(recipe.temperature.rawValue) temperature. (\(craftedCount)/\(totalRequired) materials crafted)"
            guidanceDestination = nil
            withAnimation(.spring(response: 0.4)) { showGuidance = true }
            return
        }

        // 2. Are there crafting room knowledge cards to discover?
        let craftingCards = KnowledgeCardContent.cards(for: buildingName, in: .craftingRoom)
        let hasMortar = (workshop.tools[.mortarAndPestle] ?? 0) > 0

        // If pigment table card is the only one left and player doesn't have mortar — guide them to buy it
        let uncompletedCards = craftingCards.filter { !progress.completedCardIDs.contains($0.id) }
        if !uncompletedCards.isEmpty && uncompletedCards.allSatisfy({ $0.stationKey == "pigmentTable" }) && !hasMortar {
            guidanceMessage = "Buy a Mortar & Pestle at the Market (10 florins) to access the Pigment Table and complete your last card!"
            guidanceDestination = .workshop
            withAnimation(.spring(response: 0.4)) { showGuidance = true }
            return
        }

        let availableCards = uncompletedCards.filter { card in
            if card.stationKey == "pigmentTable" && !hasMortar { return false }
            return true
        }
        if let card = availableCards.first {
            let stationName: String
            switch card.stationKey {
            case "workbench": stationName = "Workbench"
            case "furnace": stationName = "Furnace"
            case "pigmentTable": stationName = "Pigment Table"
            case "shelf": stationName = "Storage Shelf"
            default: stationName = card.stationKey
            }
            guidanceMessage = "Walk to the \(stationName) — a knowledge card awaits!"
            guidanceDestination = nil
            withAnimation(.spring(response: 0.4)) { showGuidance = true }
            return
        }

        // 3. All building materials crafted? Celebrate!
        if totalRequired > 0 && craftedCount >= totalRequired {
            guidanceMessage = "All \(totalRequired) materials for the \(buildingName) are crafted! Head to the City Map to build!"
            guidanceDestination = .cityMap
            withAnimation(.spring(response: 0.4)) { showGuidance = true }
            return
        }

        // 4. Player has raw materials — tell them specifically what they can work toward
        if let building = building {
            if let (recipe, missing) = nextNeededRecipeWithMissing(for: building) {
                if missing.isEmpty {
                    guidanceMessage = "Walk to the Workbench to craft \(recipe.output.rawValue)! (\(craftedCount)/\(totalRequired) crafted)"
                    guidanceDestination = nil
                } else {
                    let missingList = missing.map { "\($0.value) \($0.key.rawValue)" }.joined(separator: ", ")
                    guidanceMessage = "To craft \(recipe.output.rawValue), you still need \(missingList). Collect them at the Workshop! (\(craftedCount)/\(totalRequired) crafted)"
                    guidanceDestination = .workshop
                }
                withAnimation(.spring(response: 0.4)) { showGuidance = true }
                return
            }
        }

        // 5. No recipe found — tell them what to collect
        if let building = building, let (recipe, _) = nextNeededRecipeWithMissing(for: building) {
            let ingredientList = recipe.ingredients.map { "\($0.value) \($0.key.rawValue)" }.joined(separator: ", ")
            guidanceMessage = "To craft \(recipe.output.rawValue), collect \(ingredientList) at the Workshop. (\(craftedCount)/\(totalRequired) crafted)"
            guidanceDestination = .workshop
            withAnimation(.spring(response: 0.4)) { showGuidance = true }
            return
        }

        // FALLBACK: phase-based guidance
        let phase = progress.currentPhase(for: buildingName, workshopState: workshop)

        switch phase {
        case .learn:
            guidanceMessage = "Head to the City Map first — learn about the \(buildingName)!"
            guidanceDestination = .cityMap

        case .collect:
            guidanceMessage = "Head to the Workshop — collect materials for the \(buildingName)!"
            guidanceDestination = .workshop

        case .explore:
            // Phase stuck on .explore due to forest knowledge cards not wired
            // Check timber directly — if player has enough, guide to craft instead
            let timberCount = workshop.rawMaterials[.timber] ?? 0
            let hasTimberBeams = (workshop.craftedMaterials[.timberBeams] ?? 0) >= 1
            if hasTimberBeams || timberCount >= 3 {
                guidanceMessage = "Craft your materials at the Workbench and Furnace! (\(craftedCount)/\(totalRequired) crafted)"
                guidanceDestination = nil
            } else {
                guidanceMessage = "Visit the Forest to collect timber for the \(buildingName)! (\(timberCount)/3 timber)"
                guidanceDestination = .forest
            }

        case .craft:
            guidanceMessage = "Craft your materials at the Workbench and Furnace! (\(craftedCount)/\(totalRequired) crafted)"
            guidanceDestination = nil

        case .build:
            guidanceMessage = "All materials crafted for the \(buildingName)! Head to the City Map to build!"
            guidanceDestination = .cityMap
        }

        withAnimation(.spring(response: 0.4)) {
            showGuidance = true
        }
    }

    /// Check if any recipe needed by the building can be crafted with current materials
    private func nextCraftableRecipeInCraftingRoom(for building: Building) -> Recipe? {
        for (craftedItem, qty) in building.requiredMaterials {
            let alreadyCrafted = workshop.craftedMaterials[craftedItem, default: 0]
            guard alreadyCrafted < qty else { continue }
            if let recipe = Recipe.allRecipes.first(where: { $0.output == craftedItem }) {
                let canCraft = recipe.ingredients.allSatisfy { (mat, count) in
                    (workshop.rawMaterials[mat] ?? 0) >= count
                }
                if canCraft { return recipe }
            }
        }
        return nil
    }

    /// Find the next needed recipe and what raw materials are still missing
    private func nextNeededRecipeWithMissing(for building: Building) -> (recipe: Recipe, missing: [Material: Int])? {
        for (craftedItem, qty) in building.requiredMaterials {
            let alreadyCrafted = workshop.craftedMaterials[craftedItem, default: 0]
            guard alreadyCrafted < qty else { continue }
            if let recipe = Recipe.allRecipes.first(where: { $0.output == craftedItem }) {
                var missing: [Material: Int] = [:]
                for (mat, count) in recipe.ingredients {
                    let have = workshop.rawMaterials[mat] ?? 0
                    if have < count {
                        missing[mat] = count - have
                    }
                }
                return (recipe, missing)
            }
        }
        return nil
    }

    /// Check if the building still needs materials from the workshop
    private func needsMoreMaterials(for building: Building) -> Bool {
        for (craftedItem, qty) in building.requiredMaterials {
            let alreadyCrafted = workshop.craftedMaterials[craftedItem, default: 0]
            if alreadyCrafted < qty { return true }
        }
        return false
    }

    // MARK: - Station Overlay Router

    @ViewBuilder
    private func stationOverlay(for station: CraftingStation) -> some View {
        switch station {
        case .workbench:
            workbenchOverlay
        case .furnace:
            furnaceOverlay
        case .pigmentTable:
            pigmentTableOverlay
        case .shelf:
            shelfOverlay
        }
    }

    // MARK: - Navigation Panel

    private var navigationPanel: some View {
        Group {
            if let viewModel = viewModel {
                GameTopBarView(
                    title: "Crafting Room",
                    viewModel: viewModel,
                    onNavigate: { destination in
                        onNavigate?(destination)
                    },
                    showBackButton: true,
                    onBack: onBack,
                    onBackToMenu: onBackToMenu,
                    onboardingState: onboardingState,
                    returnToLessonBuildingName: returnToLessonPlotId.flatMap { id in
                        viewModel.buildingPlots.first(where: { $0.id == id })?.building.name
                    },
                    onReturnToLesson: returnToLessonPlotId != nil ? {
                        onNavigate?(.cityMap)
                    } : nil,
                    currentDestination: .workshop,
                    hideAvatarImage: !avatarInBox
                )
            } else {
                VStack(spacing: 8) {
                    Button(action: onBack) {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.left")
                            Text("Back")
                        }
                        .font(.custom("EBGaramond-Regular", size: 16))
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                        .padding(.horizontal, Spacing.md)
                        .padding(.vertical, Spacing.xs)
                        .background(
                            Capsule()
                                .fill(RenaissanceColors.parchment.opacity(0.95))
                        )
                    }
                    Text("Crafting Room")
                        .font(RenaissanceFont.dialogTitle)
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                        .padding(.horizontal, Spacing.lg)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(RenaissanceColors.parchment.opacity(0.95))
                        )
                }
            }
        }
    }

    // MARK: - Inventory Bar

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

                Divider().frame(height: 30).padding(.horizontal, 6)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Material.allCases) { material in
                        let count = workshop.rawMaterials[material] ?? 0
                        if count > 0 {
                            HStack(spacing: 3) {
                                Text(material.icon).font(.caption)
                                Text("\(count)")
                                    .font(.custom("EBGaramond-Regular", size: 12))
                                    .foregroundStyle(RenaissanceColors.sepiaInk)
                            }
                            .padding(.horizontal, 6)
                            .padding(.vertical, Spacing.xxs)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(RenaissanceColors.parchment.opacity(0.8))
                            )
                        }
                    }
                }
            }

            Divider().frame(height: 30).padding(.horizontal, Spacing.xs)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(CraftedItem.allCases) { item in
                        let count = workshop.craftedMaterials[item] ?? 0
                        if count > 0 {
                            HStack(spacing: 3) {
                                Text(item.icon).font(.caption)
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
            RoundedRectangle(cornerRadius: CornerRadius.md)
                .fill(RenaissanceColors.parchment.opacity(0.92))
        )
    }

    // MARK: - Workbench Overlay

    private var workbenchOverlay: some View {
        VStack {
            Spacer()

            VStack(spacing: 14) {
                HStack {
                    Image("InteriorWorkbench")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80)

                    VStack(alignment: .leading) {
                        Text("Mixing Workbench")
                            .font(.custom("EBGaramond-SemiBold", size: 20))
                            .foregroundStyle(RenaissanceColors.sepiaInk)

                        if let toolRecipe = ToolRecipe.detectRecipe(from: workshop.workbenchIngredients) {
                            let owned = (workshop.tools[toolRecipe.output] ?? 0) > 0
                            HStack(spacing: 6) {
                                Text(toolRecipe.output.icon)
                                Text(toolRecipe.output.displayName)
                                    .font(RenaissanceFont.bodySmall)
                                    .foregroundStyle(owned ? RenaissanceColors.stoneGray : RenaissanceColors.ochre)
                                if owned {
                                    Text("(owned)")
                                        .font(.custom("EBGaramond-Regular", size: 12))
                                        .foregroundStyle(RenaissanceColors.sageGreen)
                                } else {
                                    Image(systemName: "hammer.fill")
                                        .foregroundStyle(RenaissanceColors.ochre)
                                        .font(.caption)
                                }
                            }
                        } else if let recipe = workshop.detectedRecipe {
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
                            Text("Add materials to discover a recipe")
                                .font(RenaissanceFont.dialogSubtitle)
                                .foregroundStyle(RenaissanceColors.sepiaInk)
                        }
                    }

                    Spacer()
                }

                // 4 mixing slots
                HStack(spacing: 12) {
                    ForEach(0..<4, id: \.self) { index in
                        workbenchSlot(index: index)
                    }
                }

                // Material picker from inventory
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
                                        Text(material.rawValue)
                                            .font(.custom("EBGaramond-Regular", size: 10))
                                            .foregroundStyle(RenaissanceColors.sepiaInk)
                                        Text("\u{00D7}\(count)")
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
                .frame(height: 70)

                // Buttons
                HStack(spacing: 16) {
                    Button("Clear") {
                        withAnimation { workshop.clearWorkbench() }
                    }
                    .font(RenaissanceFont.bodySmall)
                    .padding(.horizontal, Spacing.lg)
                    .padding(.vertical, Spacing.xs)
                    .background(
                        RoundedRectangle(cornerRadius: CornerRadius.sm)
                            .fill(RenaissanceColors.stoneGray.opacity(0.3))
                    )
                    .foregroundStyle(RenaissanceColors.sepiaInk)

                    // Tool recipe: "Forge Tool" button (skips furnace)
                    if let toolRecipe = ToolRecipe.detectRecipe(from: workshop.workbenchIngredients) {
                        let alreadyOwned = (workshop.tools[toolRecipe.output] ?? 0) > 0
                        Button {
                            guard !alreadyOwned else { return }
                            // Consume ingredients from workbench
                            workshop.workbenchSlots = [nil, nil, nil, nil]
                            if workshop.craftTool(toolRecipe.output) {
                                viewModel?.earnFlorins(GameRewards.toolCraftFlorins)
                                sceneHolder.scene?.playPlayerCelebrateAnimation()
                                workshop.educationalText = toolRecipe.educationalText
                                workshop.showEducationalPopup = true
                                workshop.statusMessage = "Forged \(toolRecipe.output.icon) \(toolRecipe.output.displayName)!"
                                dismissOverlay()
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "hammer.fill")
                                    .font(.caption)
                                Text(alreadyOwned ? "Already Owned" : "Forge Tool!")
                                    .font(RenaissanceFont.bodySemibold)
                            }
                            .padding(.horizontal, Spacing.xl)
                            .padding(.vertical, Spacing.xs)
                            .background(
                                RoundedRectangle(cornerRadius: CornerRadius.sm)
                                    .fill(alreadyOwned ? RenaissanceColors.stoneGray.opacity(0.3) : RenaissanceColors.ochre)
                            )
                            .foregroundStyle(alreadyOwned ? RenaissanceColors.sepiaInk : .white)
                        }
                        .disabled(alreadyOwned)
                    } else {
                        // Normal recipe: "Mix!" button
                        Button("Mix!") {
                            if workshop.mixIngredients() {
                                workshop.statusMessage = "Mixed! Now tap the Furnace to fire it."
                                dismissOverlay()
                            }
                        }
                        .font(RenaissanceFont.bodySemibold)
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
                    }

                    Spacer()

                    Button("Close") { dismissOverlay() }
                        .font(RenaissanceFont.bodySmall)
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                }
            }
            .padding(Spacing.lg)
            .background(overlayBackground)
            .padding(.horizontal, Spacing.xl)
            .padding(.bottom, Spacing.xxxl)
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

    // MARK: - Furnace Overlay

    private let furnaceOrange = RenaissanceColors.furnaceOrange

    private var furnaceOverlay: some View {
        VStack {
            Spacer()

            VStack(spacing: 14) {
                HStack {
                    Image("InteriorFurnace")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80)

                    VStack(alignment: .leading) {
                        Text("Furnace")
                            .font(.custom("EBGaramond-SemiBold", size: 20))
                            .foregroundStyle(RenaissanceColors.sepiaInk)
                        Text("Set temperature and fire your mixture")
                            .font(RenaissanceFont.dialogSubtitle)
                            .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))
                    }

                    Spacer()
                }

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
                                    Text("\(material.icon)\u{00D7}\(input[material]!)")
                                        .font(RenaissanceFont.caption)
                                }
                            }
                            if let recipe = workshop.currentRecipe {
                                HStack(spacing: 4) {
                                    Image(systemName: "arrow.right")
                                        .font(.caption)
                                    Text(recipe.output.icon)
                                    Text(recipe.output.rawValue)
                                        .font(RenaissanceFont.caption)
                                }
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

                    Button("Close") { dismissOverlay() }
                        .font(RenaissanceFont.bodySmall)
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                }
            }
            .padding(Spacing.lg)
            .background(overlayBackground)
            .padding(.horizontal, Spacing.xl)
            .padding(.bottom, Spacing.xxxl)
        }
    }

    // MARK: - Pigment Table Overlay

    private var pigmentTableOverlay: some View {
        VStack {
            Spacer()

            ScrollView {
                VStack(spacing: 14) {
                    // Header
                    HStack {
                        Image("InteriorPigmentTable")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80)

                        VStack(alignment: .leading) {
                            Text("Pigment Grinding Table")
                                .font(.custom("EBGaramond-SemiBold", size: 20))
                                .foregroundStyle(RenaissanceColors.sepiaInk)
                            Text("il Mortaio del Colore")
                                .font(.custom("EBGaramond-Italic", size: 14))
                                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))
                        }

                        Spacer()
                    }

                    // Tool check
                    let hasMortar = (workshop.tools[.mortarAndPestle] ?? 0) > 0
                    if !hasMortar {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(RenaissanceColors.ochre)
                            Text("You need a Mortar & Pestle. Craft one at the Workbench.")
                                .font(RenaissanceFont.dialogSubtitle)
                                .foregroundStyle(RenaissanceColors.sepiaInk)
                        }
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: CornerRadius.sm)
                                .fill(RenaissanceColors.ochre.opacity(0.1))
                        )
                    }

                    // Mortar slots
                    Text("Mortar")
                        .font(.custom("EBGaramond-Regular", size: 16))
                        .foregroundStyle(RenaissanceColors.sepiaInk)

                    HStack(spacing: 20) {
                        ForEach(0..<2, id: \.self) { index in
                            mortarSlotView(index: index, enabled: hasMortar)
                        }

                        // Arrow
                        Image(systemName: "arrow.right")
                            .font(.title3)
                            .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.5))

                        // Output preview
                        if let recipe = workshop.detectedPigmentRecipe {
                            VStack(spacing: 4) {
                                Text(recipe.output.icon)
                                    .font(.title2)
                                Text(recipe.italianName)
                                    .font(.custom("EBGaramond-Italic", size: 12))
                                    .foregroundStyle(RenaissanceColors.sepiaInk)
                            }
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: CornerRadius.sm)
                                    .fill(RenaissanceColors.sageGreen.opacity(0.15))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: CornerRadius.sm)
                                    .strokeBorder(RenaissanceColors.sageGreen, lineWidth: 1.5)
                            )
                        } else {
                            VStack(spacing: 4) {
                                Text("?")
                                    .font(.title2)
                                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.3))
                                Text("Output")
                                    .font(.custom("EBGaramond-Regular", size: 12))
                                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.4))
                            }
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: CornerRadius.sm)
                                    .fill(RenaissanceColors.stoneGray.opacity(0.1))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: CornerRadius.sm)
                                    .strokeBorder(RenaissanceColors.stoneGray.opacity(0.3), lineWidth: 1)
                            )
                        }
                    }

                    // Material picker — raw pigments + water from inventory
                    let availableMaterials = Material.allCases.filter {
                        ($0.isRawPigment || $0 == .water) && (workshop.rawMaterials[$0] ?? 0) > 0
                    }
                    if !availableMaterials.isEmpty {
                        Text("Add from Inventory")
                            .font(RenaissanceFont.dialogSubtitle)
                            .foregroundStyle(RenaissanceColors.sepiaInk)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(availableMaterials, id: \.self) { material in
                                    let count = workshop.rawMaterials[material] ?? 0
                                    Button {
                                        _ = workshop.addToMortar(material)
                                    } label: {
                                        VStack(spacing: 2) {
                                            Text(material.icon)
                                                .font(.body)
                                            Text("\(count)")
                                                .font(RenaissanceFont.captionSmall)
                                                .foregroundStyle(RenaissanceColors.sepiaInk)
                                        }
                                        .padding(Spacing.xs)
                                        .background(
                                            RoundedRectangle(cornerRadius: 6)
                                                .fill(RenaissanceColors.parchment)
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 6)
                                                .strokeBorder(RenaissanceColors.renaissanceBlue.opacity(0.5), lineWidth: 1)
                                        )
                                    }
                                    .disabled(!hasMortar || workshop.isGrinding)
                                }
                            }
                        }
                    } else if hasMortar {
                        Text("No raw pigments or water in inventory. Collect from outdoor stations.")
                            .font(RenaissanceFont.caption)
                            .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.6))
                    }

                    // Grind / Clear buttons
                    HStack(spacing: 12) {
                        Button {
                            workshop.clearMortar()
                        } label: {
                            Text("Clear")
                                .font(RenaissanceFont.bodySmall)
                                .foregroundStyle(RenaissanceColors.sepiaInk)
                                .padding(.horizontal, Spacing.md)
                                .padding(.vertical, Spacing.xs)
                                .background(
                                    RoundedRectangle(cornerRadius: CornerRadius.sm)
                                        .strokeBorder(RenaissanceColors.sepiaInk.opacity(0.3), lineWidth: 1)
                                )
                        }
                        .disabled(workshop.mortarSlots.allSatisfy { $0 == nil } || workshop.isGrinding)

                        if workshop.isGrinding {
                            // Grinding progress bar
                            VStack(spacing: 4) {
                                ProgressView(value: workshop.grindProgress)
                                    .tint(RenaissanceColors.ochre)
                                Text("Grinding...")
                                    .font(.custom("EBGaramond-Italic", size: 12))
                                    .foregroundStyle(RenaissanceColors.sepiaInk)
                            }
                            .frame(maxWidth: .infinity)
                        } else {
                            Button {
                                workshop.startGrinding()
                                guard workshop.isGrinding else { return }
                                // Animate progress
                                let duration = workshop.currentPigmentRecipe?.grindingTime ?? 3.0
                                let steps = 20
                                let interval = duration / Double(steps)
                                for step in 1...steps {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + interval * Double(step)) {
                                        workshop.grindProgress = Double(step) / Double(steps)
                                        if step == steps {
                                            workshop.completeGrinding()
                                        }
                                    }
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    Text("Grind!")
                                        .font(.custom("EBGaramond-SemiBold", size: 16))
                                    Text("⚗️")
                                }
                                .foregroundStyle(.white)
                                .padding(.horizontal, Spacing.lg)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: CornerRadius.sm)
                                        .fill(workshop.detectedPigmentRecipe != nil ? RenaissanceColors.sageGreen : RenaissanceColors.stoneGray)
                                )
                            }
                            .disabled(workshop.detectedPigmentRecipe == nil || !hasMortar)
                        }
                    }

                    Divider()

                    // Recipe reference
                    Text("Grinding Recipes")
                        .font(.custom("EBGaramond-Regular", size: 16))
                        .foregroundStyle(RenaissanceColors.sepiaInk)

                    VStack(spacing: 6) {
                        ForEach(PigmentRecipe.allRecipes) { recipe in
                            grindingRecipeRow(recipe: recipe)
                        }
                    }

                    HStack {
                        Spacer()
                        Button("Close") { dismissOverlay() }
                            .font(RenaissanceFont.bodySmall)
                            .foregroundStyle(RenaissanceColors.sepiaInk)
                    }
                }
                .padding(Spacing.lg)
            }
            .frame(maxHeight: 520)
            .background(overlayBackground)
            .padding(.horizontal, Spacing.xl)
            .padding(.bottom, Spacing.xxxl)
        }
    }

    @ViewBuilder
    private func mortarSlotView(index: Int, enabled: Bool) -> some View {
        let material = workshop.mortarSlots[index]
        Button {
            // Tap filled slot to remove material back to inventory
            if let mat = material {
                workshop.mortarSlots[index] = nil
                workshop.rawMaterials[mat, default: 0] += 1
            }
        } label: {
            VStack(spacing: 2) {
                if let mat = material {
                    Text(mat.icon)
                        .font(.title2)
                    Text(mat.rawValue)
                        .font(.custom("EBGaramond-Regular", size: 10))
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                } else {
                    Image(systemName: "plus.circle.dashed")
                        .font(.title2)
                        .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.3))
                    Text("Empty")
                        .font(.custom("EBGaramond-Regular", size: 10))
                        .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.4))
                }
            }
            .frame(width: 64, height: 64)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.sm)
                    .fill(material != nil ? RenaissanceColors.parchment : RenaissanceColors.stoneGray.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.sm)
                    .strokeBorder(material != nil ? RenaissanceColors.renaissanceBlue : RenaissanceColors.stoneGray.opacity(0.3), lineWidth: 1.5)
            )
        }
        .disabled(material == nil || workshop.isGrinding)
    }

    private func grindingRecipeRow(recipe: PigmentRecipe) -> some View {
        HStack(spacing: 8) {
            Text(recipe.output.icon)
                .font(.body)

            Text(recipe.italianName)
                .font(.custom("EBGaramond-Italic", size: 14))
                .foregroundStyle(RenaissanceColors.sepiaInk)

            Spacer()

            HStack(spacing: 4) {
                ForEach(Array(recipe.ingredients.keys.sorted(by: { $0.rawValue < $1.rawValue })), id: \.self) { material in
                    Text("\(material.icon)\u{00D7}\(recipe.ingredients[material]!)")
                        .font(.custom("EBGaramond-Regular", size: 12))
                }
            }
            .foregroundStyle(RenaissanceColors.sepiaInk)

            let hasAll = recipe.ingredients.allSatisfy { (workshop.rawMaterials[$0.key] ?? 0) >= $0.value }
            Image(systemName: hasAll ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(hasAll ? RenaissanceColors.sageGreen : RenaissanceColors.sepiaInk.opacity(0.4))
                .font(.caption)
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(RenaissanceColors.warmBrown.opacity(0.06))
        )
    }

    // MARK: - Shelf Overlay (Inventory)

    private var shelfOverlay: some View {
        VStack {
            Spacer()

            VStack(spacing: 14) {
                HStack {
                    Image("InteriorShelf")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100)

                    VStack(alignment: .leading) {
                        Text("Storage Shelf")
                            .font(.custom("EBGaramond-SemiBold", size: 20))
                            .foregroundStyle(RenaissanceColors.sepiaInk)
                        Text("Your collected materials and crafted items")
                            .font(RenaissanceFont.dialogSubtitle)
                            .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))
                    }

                    Spacer()
                }

                // Raw materials
                VStack(alignment: .leading, spacing: 6) {
                    Text("Raw Materials")
                        .font(.custom("EBGaramond-Regular", size: 16))
                        .foregroundStyle(RenaissanceColors.sepiaInk)

                    let materialsWithStock = Material.allCases.filter { (workshop.rawMaterials[$0] ?? 0) > 0 }

                    if materialsWithStock.isEmpty {
                        Text("No materials collected yet. Visit the outdoor workshop to gather resources!")
                            .font(RenaissanceFont.caption)
                            .foregroundStyle(RenaissanceColors.sepiaInk)
                    } else {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 5), spacing: 8) {
                            ForEach(materialsWithStock) { material in
                                let count = workshop.rawMaterials[material] ?? 0
                                VStack(spacing: 2) {
                                    Text(material.icon)
                                        .font(.title3)
                                    Text(material.rawValue)
                                        .font(.custom("EBGaramond-Regular", size: 9))
                                        .foregroundStyle(RenaissanceColors.sepiaInk)
                                        .lineLimit(1)
                                    Text("\u{00D7}\(count)")
                                        .font(RenaissanceFont.captionSmall)
                                        .foregroundStyle(RenaissanceColors.sepiaInk)
                                }
                                .padding(Spacing.xxs)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(RenaissanceColors.parchment.opacity(0.5))
                                )
                            }
                        }
                    }
                }

                Divider()

                // Crafted items
                VStack(alignment: .leading, spacing: 6) {
                    Text("Crafted Items")
                        .font(.custom("EBGaramond-Regular", size: 16))
                        .foregroundStyle(RenaissanceColors.sageGreen)

                    let craftedWithStock = CraftedItem.allCases.filter { (workshop.craftedMaterials[$0] ?? 0) > 0 }

                    if craftedWithStock.isEmpty {
                        Text("Nothing crafted yet. Mix materials at the Workbench, then fire in the Furnace!")
                            .font(RenaissanceFont.caption)
                            .foregroundStyle(RenaissanceColors.sepiaInk)
                    } else {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
                            ForEach(craftedWithStock) { item in
                                let count = workshop.craftedMaterials[item] ?? 0
                                VStack(spacing: 2) {
                                    Text(item.icon)
                                        .font(.title2)
                                    Text(item.rawValue)
                                        .font(.custom("EBGaramond-Regular", size: 10))
                                        .foregroundStyle(RenaissanceColors.sepiaInk)
                                        .lineLimit(1)
                                    Text("\u{00D7}\(count)")
                                        .font(RenaissanceFont.captionSmall)
                                        .foregroundStyle(RenaissanceColors.sageGreen)
                                }
                                .padding(6)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(RenaissanceColors.goldSuccess.opacity(0.08))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 6)
                                                .strokeBorder(RenaissanceColors.goldSuccess.opacity(0.3), lineWidth: 1)
                                        )
                                )
                            }
                        }
                    }
                }

                HStack {
                    Spacer()
                    Button("Close") { dismissOverlay() }
                        .font(RenaissanceFont.bodySmall)
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                }
            }
            .padding(Spacing.lg)
            .background(overlayBackground)
            .padding(.horizontal, Spacing.xl)
            .padding(.bottom, Spacing.xxxl)
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
                        Text("Here's how to earn more:")
                            .font(RenaissanceFont.dialogSubtitle)
                            .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))
                    }
                }

                VStack(spacing: 10) {
                    earnCard(icon: "book.fill", title: "Read a Lesson", reward: "+\(GameRewards.lessonReadFlorins)") {
                        workshop.showEarnFlorinsOverlay = false
                        onNavigate?(.cityMap)
                    }
                    earnCard(icon: "leaf.fill", title: "Explore the Forest", reward: "+\(GameRewards.timberCollectFlorins)/timber") {
                        workshop.showEarnFlorinsOverlay = false
                        onNavigate?(.forest)
                    }
                    earnCard(icon: "flame.fill", title: "Craft an Item", reward: "+\(GameRewards.craftCompleteFlorins)") {
                        workshop.showEarnFlorinsOverlay = false
                        dismissOverlay()
                    }
                    if let a = workshop.currentAssignment {
                        earnCard(icon: "scroll.fill", title: "Master's Task: \(a.targetItem.rawValue)", reward: "+\(a.rewardFlorins) bonus") {
                            workshop.showEarnFlorinsOverlay = false
                            dismissOverlay()
                        }
                    }
                }

                Button("Maybe Later") {
                    workshop.showEarnFlorinsOverlay = false
                }
                .font(RenaissanceFont.bodySmall)
                .foregroundStyle(RenaissanceColors.sepiaInk)
            }
            .padding(24)
            .adaptiveWidth(400)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.lg)
                    .fill(RenaissanceColors.parchment)
            )
            .borderWorkshop()
        }
    }

    private func earnCard(icon: String, title: String, reward: String, action: @escaping () -> Void) -> some View {
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
                HStack(spacing: 8) {
                    Image(systemName: "scroll.fill")
                        .font(.caption)
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                    Text("Craft \(assignment.targetItem.icon) \(assignment.targetItem.rawValue)")
                        .font(.custom("EBGaramond-Medium", size: 13))
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                    Text("+\(assignment.rewardFlorins)")
                        .font(.custom("Cinzel-Bold", size: 13))
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, Spacing.xs)
                .background(
                    Capsule()
                        .fill(RenaissanceColors.parchment.opacity(0.92))
                )
                .overlay(
                    Capsule()
                        .strokeBorder(RenaissanceColors.warmBrown.opacity(0.3), lineWidth: 1)
                )
                .padding(.trailing, Spacing.md)
            }
            .padding(.top, 420)
            Spacer()
        }
        .allowsHitTesting(false)
    }

    // MARK: - Helpers

    private var overlayBackground: some View {
        RoundedRectangle(cornerRadius: CornerRadius.lg)
            .fill(RenaissanceColors.parchment.opacity(0.95))
    }

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

            viewModel?.earnFlorins(GameRewards.craftCompleteFlorins)
            sceneHolder.scene?.playPlayerCelebrateAnimation()
            var bonusText = ""

            if workshop.checkAssignmentCompletion(craftedItem: craftedItem) {
                viewModel?.earnFlorins(GameRewards.masterAssignmentFlorins)
                bonusText = "\n\nMaster's Task complete! +\(GameRewards.masterAssignmentFlorins) bonus florins!"
                workshop.generateNewAssignment()
            }

            workshop.educationalText += "\n\n+\(GameRewards.craftCompleteFlorins) florins earned!" + bonusText

            dismissOverlay()
        }
    }
}

#Preview {
    CraftingRoomMapView(workshop: WorkshopState(), returnToLessonPlotId: .constant(nil), onBack: {})
}
