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

    @State private var scene: ForestScene?
    @State private var playerPosition: CGPoint = CGPoint(x: 0.5, y: 0.5)
    @State private var playerIsWalking = false

    // POI info overlay state
    @State private var selectedPOIIndex: Int?

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

            VStack(spacing: 16) {
                // Title
                Text("\(poi.name) (\(poi.italianName))")
                    .font(.custom("Cinzel-Bold", size: 20))
                    .foregroundStyle(RenaissanceColors.sepiaInk)

                // Used for
                HStack(spacing: 6) {
                    Image(systemName: "hammer.fill")
                        .font(.caption)
                        .foregroundStyle(RenaissanceColors.warmBrown)
                    Text("Used for: \(poi.usedFor)")
                        .font(.custom("EBGaramond-Italic", size: 16))
                        .foregroundStyle(RenaissanceColors.warmBrown)
                }

                // Buildings
                HStack(spacing: 6) {
                    Image(systemName: "building.columns.fill")
                        .font(.caption)
                        .foregroundStyle(RenaissanceColors.sageGreen)
                    Text("Buildings: \(poi.buildings)")
                        .font(.custom("EBGaramond-Regular", size: 15))
                        .foregroundStyle(RenaissanceColors.sageGreen)
                }

                // Description
                Text(poi.description)
                    .font(.custom("EBGaramond-Regular", size: 16))
                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                // Dismiss button
                Button {
                    withAnimation(.easeOut(duration: 0.2)) {
                        selectedPOIIndex = nil
                    }
                } label: {
                    Text("Continue Exploring")
                        .font(.custom("EBGaramond-Italic", size: 16))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(RenaissanceColors.sageGreen)
                        )
                }
                .padding(.top, 4)
            }
            .padding(28)
            .frame(maxWidth: 420)
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
                    onboardingState: onboardingState
                )
            } else {
                // Fallback if no viewModel
                VStack(spacing: 8) {
                    Button { onBackToWorkshop?() } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                            Text("Workshop")
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
                    Text("Italian Forest")
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
    ForestMapView(workshop: WorkshopState())
}
