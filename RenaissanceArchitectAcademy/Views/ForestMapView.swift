import SwiftUI
import SpriteKit

/// SwiftUI wrapper for the ForestScene SpriteKit experience
/// Layers: SpriteKit scene → bird companion → nav panel + inventory → POI info overlay
struct ForestMapView: View {

    var workshop: WorkshopState
    var viewModel: CityViewModel? = nil
    var onNavigate: ((SidebarDestination) -> Void)? = nil
    var onBackToWorkshop: (() -> Void)? = nil
    var onBackToMenu: (() -> Void)? = nil
    var onboardingState: OnboardingState? = nil
    @Binding var returnToLessonPlotId: Int?

    @State private var scene: ForestScene?
    @State private var playerPosition: CGPoint = CGPoint(x: 0.5, y: 0.5)
    @State private var playerIsWalking = false

    // POI info overlay state
    @State private var selectedPOIIndex: Int?

    // Floating timber collection feedback
    @State private var showTimberFloat = false
    @State private var timberFloatAmount = 0
    @State private var timberFloatFlorins = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Layer 1: SpriteKit scene
                SpriteView(scene: makeScene(), options: [.allowsTransparency])
                    .ignoresSafeArea()
                    .gesture(pinchGesture)

                // Layer 2: Bird companion overlay
                BirdCharacter(isSitting: !playerIsWalking)
                    .frame(width: 100, height: 100)
                    .position(
                        x: playerPosition.x * geometry.size.width + 70,
                        y: playerPosition.y * geometry.size.height - 50
                    )
                    .allowsHitTesting(false)

                // Layer 3: Nav panel + inventory bar (same layout as Workshop)
                VStack(spacing: 0) {
                    navigationPanel
                        .frame(maxWidth: .infinity)
                    Spacer()
                    inventoryBar
                }
                .frame(maxWidth: .infinity)
                .padding(16)

                // Layer 4: POI info overlay (SwiftUI — scales properly unlike SpriteKit nodes)
                if let poiIndex = selectedPOIIndex,
                   let poi = scene?.getPOI(at: poiIndex) {
                    poiInfoOverlay(poi: poi)
                        .transition(.opacity.combined(with: .scale(scale: 0.9)))
                }

                // Layer 5: Floating "+N 🪵 +N florins" timber collection feedback
                if showTimberFloat {
                    HStack(spacing: 8) {
                        Text("+\(timberFloatAmount) 🪵")
                            .font(.custom("Cinzel-Bold", size: 22))
                            .foregroundStyle(RenaissanceColors.sepiaInk)
                        if timberFloatFlorins > 0 {
                            Text("+\(timberFloatFlorins) florins")
                                .font(.custom("Cinzel-Bold", size: 20))
                                .foregroundStyle(RenaissanceColors.goldSuccess)
                        }
                    }
                    .shadow(color: .white, radius: 4)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    .padding(.bottom, 80)
                    .allowsHitTesting(false)
                }
            }
        }
    }

    // MARK: - POI Info Overlay (SwiftUI)

    private func poiInfoOverlay(poi: ForestScene.ForestPOI) -> some View {
        ZStack {
            // Dimmed tap-to-dismiss background
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeOut(duration: 0.2)) {
                        selectedPOIIndex = nil
                    }
                }

            ScrollView {
                VStack(spacing: 16) {
                    // Title + wood type badge
                    VStack(spacing: 8) {
                        Text("\(poi.name) (\(poi.italianName))")
                            .font(.custom("Cinzel-Regular", size: 20))
                            .foregroundStyle(RenaissanceColors.sepiaInk)

                        HStack(spacing: 8) {
                            // Wood type badge
                            Text(poi.woodType)
                                .font(.custom("Mulish-Medium", size: 12))
                                .foregroundStyle(RenaissanceColors.sepiaInk)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(RenaissanceColors.ochre.opacity(0.12))
                                )

                            // Buildings badge
                            Text(poi.buildings)
                                .font(.custom("Mulish-Medium", size: 12))
                                .foregroundStyle(RenaissanceColors.sepiaInk)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(RenaissanceColors.ochre.opacity(0.1))
                                )
                        }
                    }

                    // Description
                    Text(poi.description)
                        .font(.system(size: 15))
                        .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)

                    // Architecture section
                    infoCard(
                        icon: "building.columns.fill",
                        title: "Architecture",
                        text: poi.usedFor
                    )

                    // Furniture section
                    infoCard(
                        icon: "chair.lounge.fill",
                        title: "Furniture",
                        text: poi.furnitureUse
                    )

                    // Modern use section
                    infoCard(
                        icon: "hammer.fill",
                        title: "Today",
                        text: poi.modernUse
                    )

                    // Buttons
                    VStack(spacing: 10) {
                        // Collect Timber button — warm ochre style
                        Button {
                            collectTimber(from: poi)
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "leaf.fill")
                                    .font(.body)
                                Text("Collect Timber (+\(poi.timberYield) 🪵)")
                                    .font(.custom("Mulish-SemiBold", size: 16))
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(RenaissanceColors.ochre)
                            )
                        }

                        // Continue Exploring button
                        Button {
                            withAnimation(.easeOut(duration: 0.2)) {
                                selectedPOIIndex = nil
                            }
                        } label: {
                            Text("Continue Exploring")
                                .font(.custom("Mulish-Light", size: 15))
                                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.6))
                        }
                    }
                    .padding(.top, 4)
                }
                .padding(24)
            }
            .frame(maxWidth: 420, maxHeight: 520)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(RenaissanceColors.parchment)
                    .shadow(color: .black.opacity(0.2), radius: 12, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(RenaissanceColors.ochre.opacity(0.4), lineWidth: 1.5)
            )
        }
    }

    // MARK: - Info Card (reusable for architecture/furniture/today sections)

    private func infoCard(icon: String, title: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            // Icon in warm ochre on parchment rounded square
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(RenaissanceColors.sepiaInk)
                .frame(width: 36, height: 36)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(RenaissanceColors.ochre.opacity(0.1))
                )
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.custom("Cinzel-Regular", size: 14))
                    .foregroundStyle(RenaissanceColors.sepiaInk)

                Text(text)
                    .font(.system(size: 14))
                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.75))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(RenaissanceColors.ochre.opacity(0.06))
        )
    }

    // MARK: - Timber Collection

    private func collectTimber(from poi: ForestScene.ForestPOI) {
        var collected = 0
        for _ in 0..<poi.timberYield {
            if workshop.collectFromStation(.forest, material: .timber) {
                collected += 1
            }
        }

        // Award florins for timber collection
        let florinsEarned = collected * GameRewards.timberCollectFlorins
        if florinsEarned > 0 {
            viewModel?.earnFlorins(florinsEarned)
        }

        // Dismiss overlay
        withAnimation(.easeOut(duration: 0.2)) {
            selectedPOIIndex = nil
        }

        // Show floating feedback
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
                    } : nil
                )
            } else {
                // Fallback if no viewModel
                VStack(spacing: 8) {
                    Button { onBackToWorkshop?() } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                            Text("Workshop")
                        }
                        .font(.custom("Mulish-Light", size: 16))
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .glassButton(shape: Capsule())
                    }
                    Text("Italian Forest")
                        .font(.custom("Cinzel-Regular", size: 20))
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .glassButton(shape: Capsule())
                }
            }
        }
    }

    // MARK: - Inventory Bar

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
                .shadow(color: .black.opacity(0.1), radius: 4, y: -2)
        )
    }

    // MARK: - Scene Setup

    private func makeScene() -> ForestScene {
        if let existing = scene { return existing }

        let newScene = ForestScene()
        newScene.size = CGSize(width: 3500, height: 2500)
        newScene.scaleMode = .aspectFill

        newScene.onPlayerPositionChanged = { position, isWalking in
            playerPosition = position
            playerIsWalking = isWalking
        }

        newScene.onBackRequested = {
            onBackToWorkshop?()
        }

        newScene.onPOISelected = { index in
            withAnimation(.easeOut(duration: 0.25)) {
                selectedPOIIndex = index
            }
        }

        DispatchQueue.main.async {
            scene = newScene
        }

        return newScene
    }

    // MARK: - Gestures

    private var pinchGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                scene?.handlePinch(scale: value)
            }
    }
}

#Preview {
    ForestMapView(workshop: WorkshopState(), returnToLessonPlotId: .constant(nil))
}
