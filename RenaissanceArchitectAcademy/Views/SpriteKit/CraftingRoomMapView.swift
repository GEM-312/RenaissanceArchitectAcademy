import SwiftUI
import SpriteKit

/// SwiftUI wrapper for the CraftingRoomScene SpriteKit interior
/// Layers: SpriteKit scene → UI bars → station overlays → educational/earn popups → master task card
struct CraftingRoomMapView: View {

    @Bindable var workshop: WorkshopState
    var viewModel: CityViewModel? = nil
    var onNavigate: ((SidebarDestination) -> Void)? = nil
    var onBackToMenu: (() -> Void)? = nil
    var onboardingState: OnboardingState? = nil
    @Binding var returnToLessonPlotId: Int?
    var onBack: () -> Void

    // Scene reference
    @State private var scene: CraftingRoomScene?

    // Player tracking
    @State private var playerPosition: CGPoint = CGPoint(x: 0.5, y: 0.5)
    @State private var playerIsWalking = false

    // Active station overlay
    @State private var activeStation: CraftingStation? = nil

    // Magic Mouse scroll-to-zoom
    @State private var scrollMonitor: Any?

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Layer 1: SpriteKit scene
                SpriteView(scene: makeScene(), options: [.allowsTransparency])
                    .ignoresSafeArea()
                    .gesture(pinchGesture)

                // Layer 2: Nav + inventory
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
                            .font(.custom("EBGaramond-Regular", size: 14))
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

                // Layer 3: Station overlays
                if let station = activeStation {
                    RenaissanceColors.overlayDimming
                        .ignoresSafeArea()
                        .onTapGesture { dismissOverlay() }
                        .transition(.opacity)

                    stationOverlay(for: station)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                // Layer 4: Educational popup
                if workshop.showEducationalPopup {
                    educationalOverlay
                        .transition(.opacity.combined(with: .scale(scale: 0.9)))
                }

                // Layer 4b: Earn Florins overlay
                if workshop.showEarnFlorinsOverlay {
                    earnFlorinsOverlay
                        .transition(.opacity.combined(with: .scale(scale: 0.9)))
                }

                // Layer 4c: Master task card
                if let assignment = workshop.currentAssignment,
                   activeStation == nil,
                   !workshop.showEducationalPopup,
                   !workshop.showEarnFlorinsOverlay {
                    masterTaskCard(assignment: assignment)
                }
            }
        }
        .onAppear {
            if workshop.currentAssignment == nil {
                workshop.generateNewAssignment()
            }
            #if os(macOS)
            scrollMonitor = NSEvent.addLocalMonitorForEvents(matching: .scrollWheel) { [self] event in
                if activeStation == nil {
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

    private func makeScene() -> CraftingRoomScene {
        if let existing = scene { return existing }

        let newScene = CraftingRoomScene()
        newScene.size = CGSize(width: 3500, height: 2500)
        newScene.scaleMode = .aspectFill
        newScene.apprenticeIsBoy = onboardingState?.apprenticeGender == .boy || onboardingState == nil

        newScene.onPlayerPositionChanged = { position, isWalking in
            self.playerPosition = position
            self.playerIsWalking = isWalking
        }

        newScene.onFurnitureReached = { station in
            withAnimation(.spring(response: 0.3)) {
                self.activeStation = station
            }
        }

        scene = newScene
        return newScene
    }

    private func dismissOverlay() {
        withAnimation(.spring(response: 0.3)) {
            activeStation = nil
        }
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
                    } : nil
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
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(RenaissanceColors.parchment.opacity(0.95))
                        )
                    }
                    Text("Crafting Room")
                        .font(.custom("EBGaramond-SemiBold", size: 22))
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

    // MARK: - Inventory Bar

    private var inventoryBar: some View {
        HStack(spacing: 0) {
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
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(RenaissanceColors.parchment.opacity(0.8))
                            )
                        }
                    }
                }
            }

            Divider().frame(height: 30).padding(.horizontal, 8)

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

                        if let recipe = workshop.detectedRecipe {
                            HStack(spacing: 6) {
                                Text(recipe.output.icon)
                                Text(recipe.output.rawValue)
                                    .font(.custom("EBGaramond-Regular", size: 15))
                                    .foregroundStyle(RenaissanceColors.sageGreen)
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(RenaissanceColors.sageGreen)
                                    .font(.caption)
                            }
                        } else {
                            Text("Add 4 materials to discover a recipe")
                                .font(.custom("EBGaramond-Regular", size: 14))
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
                .frame(height: 70)

                // Buttons
                HStack(spacing: 16) {
                    Button("Clear") {
                        withAnimation { workshop.clearWorkbench() }
                    }
                    .font(.custom("EBGaramond-Regular", size: 15))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(RenaissanceColors.stoneGray.opacity(0.3))
                    )
                    .foregroundStyle(RenaissanceColors.sepiaInk)

                    Button("Mix!") {
                        if workshop.mixIngredients() {
                            workshop.statusMessage = "Mixed! Now tap the Furnace to fire it."
                            dismissOverlay()
                        }
                    }
                    .font(.custom("EBGaramond-SemiBold", size: 17))
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

                    Button("Close") { dismissOverlay() }
                        .font(.custom("EBGaramond-Regular", size: 15))
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                }
            }
            .padding(20)
            .background(overlayBackground)
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
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
                            .font(.custom("EBGaramond-Regular", size: 14))
                            .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))
                    }

                    Spacer()
                }

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
                                    Text("\(material.icon)\u{00D7}\(input[material]!)")
                                        .font(.custom("EBGaramond-Regular", size: 13))
                                }
                            }
                            if let recipe = workshop.currentRecipe {
                                HStack(spacing: 4) {
                                    Image(systemName: "arrow.right")
                                        .font(.caption)
                                    Text(recipe.output.icon)
                                    Text(recipe.output.rawValue)
                                        .font(.custom("EBGaramond-Regular", size: 13))
                                }
                                .foregroundStyle(RenaissanceColors.sepiaInk)
                            }
                        }
                    } else {
                        Text("Mix ingredients at the Workbench first")
                            .font(.custom("EBGaramond-Regular", size: 14))
                            .foregroundStyle(RenaissanceColors.sepiaInk)
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

                    Button("Close") { dismissOverlay() }
                        .font(.custom("EBGaramond-Regular", size: 15))
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                }
            }
            .padding(20)
            .background(overlayBackground)
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }

    // MARK: - Pigment Table Overlay

    private var pigmentTableOverlay: some View {
        VStack {
            Spacer()

            VStack(spacing: 14) {
                HStack {
                    Image("InteriorPigmentTable")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80)

                    VStack(alignment: .leading) {
                        Text("Pigment Table")
                            .font(.custom("EBGaramond-SemiBold", size: 20))
                            .foregroundStyle(RenaissanceColors.sepiaInk)
                        Text("Collect & grind pigments for fresco painting")
                            .font(.custom("EBGaramond-Regular", size: 14))
                            .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))
                    }

                    Spacer()
                }

                // Florins display
                if let vm = viewModel {
                    HStack(spacing: 4) {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.footnote)
                            .foregroundStyle(RenaissanceColors.sepiaInk)
                        Text("\(vm.goldFlorins) florins")
                            .font(.custom("EBGaramond-Regular", size: 15))
                            .foregroundStyle(RenaissanceColors.sepiaInk)
                    }
                }

                // Collect pigments section
                Text("Collect Raw Pigments")
                    .font(.custom("EBGaramond-Regular", size: 16))
                    .foregroundStyle(RenaissanceColors.sepiaInk)

                HStack(spacing: 16) {
                    let pigmentMaterials: [Material] = [.redOchre, .lapisBlue, .verdigrisGreen]
                    ForEach(pigmentMaterials, id: \.self) { material in
                        let stock = workshop.stationStocks[.pigmentTable]?[material] ?? 0
                        let canAfford = (viewModel?.goldFlorins ?? 0) >= material.cost
                        Button {
                            guard let vm = viewModel else { return }
                            guard vm.goldFlorins >= material.cost else {
                                workshop.showEarnFlorinsOverlay = true
                                dismissOverlay()
                                return
                            }
                            if workshop.collectFromStation(.pigmentTable, material: material) {
                                vm.goldFlorins -= material.cost
                            }
                        } label: {
                            VStack(spacing: 4) {
                                Text(material.icon)
                                    .font(.title2)
                                Text(material.rawValue)
                                    .font(.custom("EBGaramond-Regular", size: 11))
                                    .foregroundStyle(RenaissanceColors.sepiaInk)
                                    .lineLimit(1)
                                HStack(spacing: 2) {
                                    Text("×\(stock)")
                                        .font(.custom("EBGaramond-Regular", size: 12))
                                        .foregroundStyle(stock > 0 ? RenaissanceColors.sageGreen : RenaissanceColors.sepiaInk)
                                    Image(systemName: "dollarsign.circle.fill")
                                        .font(.system(size: 9))
                                        .foregroundStyle(RenaissanceColors.sepiaInk)
                                    Text("\(material.cost)")
                                        .font(.custom("EBGaramond-Regular", size: 11))
                                        .foregroundStyle(canAfford ? RenaissanceColors.sepiaInk : RenaissanceColors.errorRed)
                                }
                            }
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(stock > 0 ? RenaissanceColors.parchment : RenaissanceColors.stoneGray.opacity(0.15))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .strokeBorder(stock > 0 ? RenaissanceColors.renaissanceBlue : RenaissanceColors.stoneGray.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .disabled(stock <= 0)
                    }
                }

                Divider()

                // Pigment recipes reference
                Text("Pigment Recipes")
                    .font(.custom("EBGaramond-Regular", size: 16))
                    .foregroundStyle(RenaissanceColors.sepiaInk)

                VStack(spacing: 8) {
                    pigmentRecipeRow(
                        recipe: Recipe.allRecipes.first(where: { $0.output == .redFrescoPigment }),
                        label: "Red Fresco",
                        color: RenaissanceColors.errorRed
                    )
                    pigmentRecipeRow(
                        recipe: Recipe.allRecipes.first(where: { $0.output == .blueFrescoPigment }),
                        label: "Blue Fresco",
                        color: RenaissanceColors.renaissanceBlue
                    )
                    pigmentRecipeRow(
                        recipe: Recipe.allRecipes.first(where: { $0.output == .stainedGlass }),
                        label: "Stained Glass",
                        color: RenaissanceColors.deepTeal
                    )
                }

                Text("Collect pigments above, then mix at the Workbench")
                    .font(.custom("EBGaramond-Regular", size: 12))
                    .foregroundStyle(RenaissanceColors.sepiaInk)

                HStack {
                    Spacer()
                    Button("Close") { dismissOverlay() }
                        .font(.custom("EBGaramond-Regular", size: 15))
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                }
            }
            .padding(20)
            .background(overlayBackground)
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }

    private func pigmentRecipeRow(recipe: Recipe?, label: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color.opacity(0.6))
                .frame(width: 24, height: 24)

            Text(label)
                .font(.custom("EBGaramond-Regular", size: 16))
                .foregroundStyle(RenaissanceColors.sepiaInk)

            Spacer()

            if let recipe = recipe {
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
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(color.opacity(0.08))
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
                            .font(.custom("EBGaramond-Regular", size: 14))
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
                            .font(.custom("EBGaramond-Regular", size: 13))
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
                                        .font(.custom("EBGaramond-Regular", size: 11))
                                        .foregroundStyle(RenaissanceColors.sepiaInk)
                                }
                                .padding(4)
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
                            .font(.custom("EBGaramond-Regular", size: 13))
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
                                        .font(.custom("EBGaramond-Regular", size: 11))
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
                        .font(.custom("EBGaramond-Regular", size: 15))
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                }
            }
            .padding(20)
            .background(overlayBackground)
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
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
                    .font(.custom("EBGaramond-Regular", size: 17, relativeTo: .body))
                    .foregroundStyle(RenaissanceColors.sepiaInk)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Button("Continue") {
                    workshop.showEducationalPopup = false
                }
                .font(.custom("EBGaramond-Regular", size: 18))
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
                        Text("Here's how to earn more:")
                            .font(.custom("EBGaramond-Regular", size: 14))
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
                .font(.custom("EBGaramond-Regular", size: 15))
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

    private func earnCard(icon: String, title: String, reward: String, action: @escaping () -> Void) -> some View {
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
                    .font(.custom("EBGaramond-SemiBold", size: 13))
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
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(RenaissanceColors.parchment.opacity(0.92))
                )
                .overlay(
                    Capsule()
                        .strokeBorder(RenaissanceColors.warmBrown.opacity(0.3), lineWidth: 1)
                )
                .padding(.trailing, 16)
            }
            .padding(.top, 420)
            Spacer()
        }
        .allowsHitTesting(false)
    }

    // MARK: - Helpers

    private var overlayBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(RenaissanceColors.parchment.opacity(0.95))
    }

    private var pinchGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                scene?.handlePinch(scale: value)
            }
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
            scene?.playPlayerCelebrateAnimation()
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
