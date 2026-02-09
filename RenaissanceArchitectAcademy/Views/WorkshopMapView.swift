import SwiftUI
import SpriteKit

/// SwiftUI wrapper for the WorkshopScene SpriteKit mini-game
/// Layers: SpriteKit scene → companion overlay → UI bars → hint/collection/crafting overlays
struct WorkshopMapView: View {

    @Bindable var workshop: WorkshopState

    @Environment(\.dismiss) private var dismiss

    // Scene reference
    @State private var scene: WorkshopScene?

    // Player tracking
    @State private var playerPosition: CGPoint = CGPoint(x: 0.5, y: 0.5)
    @State private var playerIsWalking = false
    @State private var playerFacingRight = true

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

                // Layer 2: Companion overlay (Splash + Bird trailing player)
                companionOverlay(in: geometry.size)

                // Layer 3: Top bar + bottom inventory bar
                VStack(spacing: 0) {
                    topBar
                    Spacer()
                    inventoryBar
                }
                .padding(.horizontal)
                .padding(.vertical, 8)

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
        newScene.size = CGSize(width: 1024, height: 768)
        newScene.scaleMode = .aspectFill

        // Player position updates
        newScene.onPlayerPositionChanged = { position, isWalking in
            self.playerPosition = position
            self.playerIsWalking = isWalking
        }

        // Facing direction updates
        newScene.onPlayerFacingChanged = { facingRight in
            self.playerFacingRight = facingRight
        }

        // Station reached — show appropriate overlay
        newScene.onStationReached = { stationType in
            self.activeStation = stationType
            dismissAllOverlays()

            switch stationType {
            case .workbench:
                withAnimation(.spring(response: 0.3)) {
                    showWorkbenchOverlay = true
                }
            case .furnace:
                withAnimation(.spring(response: 0.3)) {
                    showFurnaceOverlay = true
                }
            default:
                // Resource station — show hint then collection
                withAnimation(.spring(response: 0.3)) {
                    showHintBubble = true
                }
                // Show collection UI after hint displays briefly
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
    }

    // MARK: - Layer 2: Companion Overlay

    private func companionOverlay(in size: CGSize) -> some View {
        let screenX = playerPosition.x * size.width
        let screenY = playerPosition.y * size.height

        // Companions trail slightly behind the player
        let offsetX: CGFloat = playerFacingRight ? -55 : 55

        return HStack(alignment: .bottom, spacing: -15) {
            SplashCharacter()
                .frame(width: 80, height: 100)
                .scaleEffect(x: playerFacingRight ? 1 : -1, y: 1)

            BirdCharacter()
                .frame(width: 40, height: 40)
                .offset(y: playerIsWalking ? -4 : 0)
        }
        .scaleEffect(0.55)
        .position(x: screenX + offsetX, y: screenY + 15)
        .animation(.easeInOut(duration: 0.15), value: playerPosition)
        .animation(.easeInOut(duration: 0.1), value: playerIsWalking)
        .allowsHitTesting(false)
    }

    // MARK: - Layer 3: Top Bar + Inventory

    private var topBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
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

            Spacer()

            Text("Leonardo's Workshop")
                .font(.custom("Cinzel-Bold", size: 20))
                .foregroundStyle(RenaissanceColors.sepiaInk)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(RenaissanceColors.parchment.opacity(0.95))
                        .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                )

            Spacer()

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
                    SplashCharacter()
                        .frame(width: 50, height: 60)

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

    // MARK: - Layer 5: Collection Overlay

    private func collectionOverlay(for station: ResourceStationType) -> some View {
        VStack {
            Spacer()

            VStack(spacing: 12) {
                Text("Collect from \(station.label)")
                    .font(.custom("Cinzel-Regular", size: 16))
                    .foregroundStyle(RenaissanceColors.sepiaInk)

                HStack(spacing: 16) {
                    ForEach(station.materials, id: \.self) { material in
                        let stock = workshop.stationStocks[station]?[material] ?? 0
                        Button {
                            if workshop.collectFromStation(station, material: material) {
                                scene?.showCollectionEffect(at: station)
                                // Update station stock display
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
                                Text("×\(stock)")
                                    .font(.custom("EBGaramond-Regular", size: 12))
                                    .foregroundStyle(stock > 0 ? RenaissanceColors.sageGreen : RenaissanceColors.stoneGray)
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
    WorkshopMapView(workshop: WorkshopState())
}
