import SwiftUI

/// Interior workshop scene — crafting room with tappable stations
/// Background: Leonardo's workshop room
/// Stations: Workbench (mixing), Furnace (firing), Pigment Table (color mixing), Storage Shelf (inventory)
struct WorkshopInteriorView: View {

    @Bindable var workshop: WorkshopState
    var viewModel: CityViewModel? = nil
    var onNavigate: ((SidebarDestination) -> Void)? = nil
    var onBack: () -> Void

    // Which station overlay is showing
    @State private var activeStation: InteriorStation? = nil

    // Entrance animation
    @State private var appeared = false

    enum InteriorStation: String, CaseIterable {
        case workbench = "Workbench"
        case furnace = "Furnace"
        case pigmentTable = "Pigment Table"
        case shelf = "Storage"
    }

    // MARK: - Default Furniture Positions (relative 0-1)

    /// Default positions for each furniture station — edit these after using editor mode
    private static let defaultPositions: [InteriorStation: CGPoint] = [
        .workbench:    CGPoint(x: 0.25, y: 0.6),
        .furnace:      CGPoint(x: 0.72, y: 0.45),
        .pigmentTable: CGPoint(x: 0.48, y: 0.65),
        .shelf:        CGPoint(x: 0.85, y: 0.35),
    ]

    /// Default image widths as fraction of screen width
    private static let defaultWidths: [InteriorStation: CGFloat] = [
        .workbench:    0.28,
        .furnace:      0.22,
        .pigmentTable: 0.26,
        .shelf:        0.22,
    ]

    // MARK: - Editor Mode (DEBUG only)

    #if DEBUG
    @State private var editorActive = false
    @State private var editedPositions: [InteriorStation: CGPoint] = defaultPositions
    @State private var selectedEditorStation: InteriorStation? = nil
    #endif

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Layer 1: Room background
                Image("WorkshopBackground")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()

                // Layer 2: Tappable furniture stations
                furnitureLayer(in: geo.size)

                // Layer 3: Top bar
                VStack {
                    topBar
                    Spacer()
                    inventoryBar
                }
                .padding(.horizontal)
                .padding(.vertical, 8)

                // Layer 4: Station overlays
                if let station = activeStation {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture { dismissOverlay() }
                        .transition(.opacity)

                    stationOverlay(for: station)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                // Layer 5: Educational popup
                if workshop.showEducationalPopup {
                    educationalOverlay
                        .transition(.opacity.combined(with: .scale(scale: 0.9)))
                }

                // Layer 6: Editor mode overlay (DEBUG only)
                #if DEBUG
                if editorActive {
                    editorOverlay(in: geo.size)
                }
                #endif
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                appeared = true
            }
        }
        #if DEBUG
        .onKeyPress("e") {
            toggleEditor()
            return .handled
        }
        #endif
    }

    // MARK: - Furniture Layer

    private func furnitureLayer(in size: CGSize) -> some View {
        // Position furniture relative to the room background
        // Room image: wide workshop interior, left side has tables, center has workspace, right has shelves
        ZStack {
            ForEach(InteriorStation.allCases, id: \.self) { station in
                let imageName: String = {
                    switch station {
                    case .workbench:    return "InteriorWorkbench"
                    case .furnace:      return "InteriorFurnace"
                    case .pigmentTable: return "InteriorPigmentTable"
                    case .shelf:        return "InteriorShelf"
                    }
                }()

                #if DEBUG
                let pos = editorActive ? editedPositions[station]! : Self.defaultPositions[station]!
                #else
                let pos = Self.defaultPositions[station]!
                #endif

                let imgWidth = size.width * (Self.defaultWidths[station] ?? 0.25)

                furnitureButton(
                    imageName: imageName,
                    station: station,
                    size: size,
                    relativeX: pos.x,
                    relativeY: pos.y,
                    imageWidth: imgWidth
                )
                #if DEBUG
                .gesture(editorActive ? editorDragGesture(for: station, in: size) : nil)
                #endif
            }
        }
    }

    private func furnitureButton(imageName: String, station: InteriorStation, size: CGSize, relativeX: CGFloat, relativeY: CGFloat, imageWidth: CGFloat) -> some View {
        Button {
            withAnimation(.spring(response: 0.3)) {
                activeStation = station
            }
        } label: {
            VStack(spacing: 4) {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: imageWidth)

                // Label below furniture
                Text(station.rawValue)
                    .font(.custom("Cinzel-Regular", size: 13))
                    .foregroundStyle(RenaissanceColors.parchment)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(RenaissanceColors.sepiaInk.opacity(0.7))
                    )
            }
            .scaleEffect(appeared ? 1.0 : 0.8)
            .opacity(appeared ? 1.0 : 0)
        }
        .position(x: size.width * relativeX, y: size.height * relativeY)
    }

    // MARK: - Station Overlays

    @ViewBuilder
    private func stationOverlay(for station: InteriorStation) -> some View {
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
                            .font(.custom("Cinzel-Regular", size: 18))
                            .foregroundStyle(RenaissanceColors.sepiaInk)

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
                            Text("Add 4 materials to discover a recipe")
                                .font(.custom("EBGaramond-Italic", size: 14))
                                .foregroundStyle(RenaissanceColors.stoneGray)
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
                            workshop.statusMessage = "Mixed! Now tap the Furnace to fire it."
                            dismissOverlay()
                        }
                    }
                    .font(.custom("Cinzel-Bold", size: 15))
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
                        .font(.custom("EBGaramond-Italic", size: 15))
                        .foregroundStyle(RenaissanceColors.stoneGray)
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
                    .foregroundStyle(RenaissanceColors.stoneGray.opacity(0.5))
            }
        }
    }

    // MARK: - Furnace Overlay

    private let furnaceOrange = Color(red: 0.9, green: 0.4, blue: 0.1)

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
                            .font(.custom("Cinzel-Regular", size: 18))
                            .foregroundStyle(RenaissanceColors.sepiaInk)
                        Text("Set temperature and fire your mixture")
                            .font(.custom("EBGaramond-Italic", size: 14))
                            .foregroundStyle(RenaissanceColors.stoneGray)
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
                                        .font(.custom("EBGaramond-Italic", size: 13))
                                }
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

                    Button("Close") { dismissOverlay() }
                        .font(.custom("EBGaramond-Italic", size: 15))
                        .foregroundStyle(RenaissanceColors.stoneGray)
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
                            .font(.custom("Cinzel-Regular", size: 18))
                            .foregroundStyle(RenaissanceColors.sepiaInk)
                        Text("Mix pigments for fresco painting")
                            .font(.custom("EBGaramond-Italic", size: 14))
                            .foregroundStyle(RenaissanceColors.stoneGray)
                    }

                    Spacer()
                }

                // Pigment recipes available
                VStack(spacing: 10) {
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

                // Quick-add pigment materials from inventory
                Text("Your pigment materials:")
                    .font(.custom("EBGaramond-Regular", size: 13))
                    .foregroundStyle(RenaissanceColors.sepiaInk)

                HStack(spacing: 12) {
                    let pigmentMaterials: [Material] = [.redOchre, .lapisBlue, .verdigrisGreen, .limestone, .water, .lead, .sand]
                    ForEach(pigmentMaterials, id: \.self) { material in
                        let count = workshop.rawMaterials[material] ?? 0
                        VStack(spacing: 2) {
                            Text(material.icon)
                                .font(.title3)
                            Text("\(count)")
                                .font(.custom("EBGaramond-Regular", size: 11))
                                .foregroundStyle(count > 0 ? RenaissanceColors.sepiaInk : RenaissanceColors.stoneGray)
                        }
                        .padding(6)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(count > 0 ? RenaissanceColors.parchment.opacity(0.6) : RenaissanceColors.stoneGray.opacity(0.1))
                        )
                    }
                }

                Text("Use the Workbench to mix pigment recipes")
                    .font(.custom("EBGaramond-Italic", size: 12))
                    .foregroundStyle(RenaissanceColors.stoneGray)

                HStack {
                    Spacer()
                    Button("Close") { dismissOverlay() }
                        .font(.custom("EBGaramond-Italic", size: 15))
                        .foregroundStyle(RenaissanceColors.stoneGray)
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
                .font(.custom("Cinzel-Regular", size: 14))
                .foregroundStyle(RenaissanceColors.sepiaInk)

            Spacer()

            if let recipe = recipe {
                HStack(spacing: 4) {
                    ForEach(Array(recipe.ingredients.keys.sorted(by: { $0.rawValue < $1.rawValue })), id: \.self) { material in
                        Text("\(material.icon)\u{00D7}\(recipe.ingredients[material]!)")
                            .font(.custom("EBGaramond-Regular", size: 12))
                    }
                }
                .foregroundStyle(RenaissanceColors.stoneGray)

                // Check if player has all ingredients
                let hasAll = recipe.ingredients.allSatisfy { (workshop.rawMaterials[$0.key] ?? 0) >= $0.value }
                Image(systemName: hasAll ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(hasAll ? RenaissanceColors.sageGreen : RenaissanceColors.stoneGray.opacity(0.4))
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
                            .font(.custom("Cinzel-Regular", size: 18))
                            .foregroundStyle(RenaissanceColors.sepiaInk)
                        Text("Your collected materials and crafted items")
                            .font(.custom("EBGaramond-Italic", size: 14))
                            .foregroundStyle(RenaissanceColors.stoneGray)
                    }

                    Spacer()
                }

                // Raw materials
                VStack(alignment: .leading, spacing: 6) {
                    Text("Raw Materials")
                        .font(.custom("Cinzel-Regular", size: 14))
                        .foregroundStyle(RenaissanceColors.warmBrown)

                    let materialsWithStock = Material.allCases.filter { (workshop.rawMaterials[$0] ?? 0) > 0 }

                    if materialsWithStock.isEmpty {
                        Text("No materials collected yet. Visit the outdoor workshop to gather resources!")
                            .font(.custom("EBGaramond-Italic", size: 13))
                            .foregroundStyle(RenaissanceColors.stoneGray)
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
                                        .foregroundStyle(RenaissanceColors.warmBrown)
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
                        .font(.custom("Cinzel-Regular", size: 14))
                        .foregroundStyle(RenaissanceColors.sageGreen)

                    let craftedWithStock = CraftedItem.allCases.filter { (workshop.craftedMaterials[$0] ?? 0) > 0 }

                    if craftedWithStock.isEmpty {
                        Text("Nothing crafted yet. Mix materials at the Workbench, then fire in the Furnace!")
                            .font(.custom("EBGaramond-Italic", size: 13))
                            .foregroundStyle(RenaissanceColors.stoneGray)
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
                        .font(.custom("EBGaramond-Italic", size: 15))
                        .foregroundStyle(RenaissanceColors.stoneGray)
                }
            }
            .padding(20)
            .background(overlayBackground)
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        VStack(spacing: 4) {
            if let viewModel = viewModel {
                GameTopBarView(
                    title: "Crafting Room",
                    viewModel: viewModel,
                    onNavigate: { destination in
                        onNavigate?(destination)
                    },
                    showBackButton: true,
                    onBack: onBack
                )
            } else {
                // Fallback if no viewModel
                HStack {
                    Button(action: onBack) {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.left")
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
                    Spacer()
                    Text("Crafting Room")
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

            // Status message
            if let status = workshop.statusMessage {
                Text(status)
                    .font(.custom("EBGaramond-Italic", size: 14))
                    .foregroundStyle(RenaissanceColors.terracotta)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(RenaissanceColors.parchment.opacity(0.95))
                    )
                    .transition(.opacity)
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
                .shadow(color: .black.opacity(0.1), radius: 4, y: -2)
        )
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

    // MARK: - Helpers

    private var overlayBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(RenaissanceColors.parchment.opacity(0.95))
            .shadow(color: .black.opacity(0.15), radius: 8, y: -3)
    }

    private func dismissOverlay() {
        withAnimation(.spring(response: 0.3)) {
            activeStation = nil
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
            workshop.completeProcessing()
            dismissOverlay()
        }
    }

    // MARK: - Editor Mode (DEBUG only)

    #if DEBUG
    private func toggleEditor() {
        editorActive.toggle()
        if editorActive {
            // Initialize edited positions from defaults
            editedPositions = Self.defaultPositions
            selectedEditorStation = nil
            print("🎨 INTERIOR EDITOR ON — drag furniture to reposition, press E to finish")
        } else {
            dumpFurniturePositions()
            selectedEditorStation = nil
            print("🎨 INTERIOR EDITOR OFF — positions printed above ↑")
        }
    }

    private func editorDragGesture(for station: InteriorStation, in size: CGSize) -> some Gesture {
        DragGesture()
            .onChanged { value in
                selectedEditorStation = station
                let relX = value.location.x / size.width
                let relY = value.location.y / size.height
                editedPositions[station] = CGPoint(
                    x: max(0.05, min(0.95, relX)),
                    y: max(0.05, min(0.95, relY))
                )
            }
            .onEnded { _ in
                if let pos = editedPositions[station] {
                    print("  \"\(station.rawValue)\": CGPoint(x: \(String(format: "%.2f", pos.x)), y: \(String(format: "%.2f", pos.y)))")
                }
            }
    }

    private func editorOverlay(in size: CGSize) -> some View {
        ZStack {
            // Editor badge
            VStack {
                HStack {
                    Spacer()
                    Text("EDITOR MODE")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(.red.opacity(0.9))
                                .overlay(Capsule().strokeBorder(.white, lineWidth: 2))
                        )
                        .opacity(editorActive ? 1 : 0)
                    Spacer()
                }
                .padding(.top, 50)

                Spacer()
            }

            // Yellow highlight around selected station
            if let station = selectedEditorStation, let pos = editedPositions[station] {
                let imgWidth = size.width * (Self.defaultWidths[station] ?? 0.25)
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(.yellow, lineWidth: 3)
                    .frame(width: imgWidth + 20, height: imgWidth * 0.8 + 40)
                    .position(x: size.width * pos.x, y: size.height * pos.y)

                // Coordinate label
                Text("x: \(String(format: "%.2f", pos.x))  y: \(String(format: "%.2f", pos.y))")
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(.black.opacity(0.85))
                            .overlay(Capsule().strokeBorder(.yellow, lineWidth: 1))
                    )
                    .position(x: size.width * pos.x, y: size.height * pos.y - imgWidth * 0.4 - 30)
            }
        }
        .allowsHitTesting(false)
    }

    private func dumpFurniturePositions() {
        print("\n// ========== INTERIOR FURNITURE POSITIONS ==========")
        print("private static let defaultPositions: [InteriorStation: CGPoint] = [")
        for station in InteriorStation.allCases {
            if let pos = editedPositions[station] {
                print("    .\(station): CGPoint(x: \(String(format: "%.2f", pos.x)), y: \(String(format: "%.2f", pos.y))),")
            }
        }
        print("]")
        print("// ===================================================\n")
    }
    #endif
}

#Preview {
    WorkshopInteriorView(workshop: WorkshopState(), onBack: {})
}
