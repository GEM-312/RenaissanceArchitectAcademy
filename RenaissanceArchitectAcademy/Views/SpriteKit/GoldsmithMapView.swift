import SwiftUI
import SpriteKit

/// SwiftUI wrapper for the GoldsmithScene SpriteKit interior
/// Bottega di Benincasa Lotti — master-level goldsmith workshop in Santa Croce, Florence
struct GoldsmithMapView: View {

    @Bindable var workshop: WorkshopState
    var viewModel: CityViewModel? = nil
    var onNavigate: ((SidebarDestination) -> Void)? = nil
    var onBackToMenu: (() -> Void)? = nil
    var onboardingState: OnboardingState? = nil
    @Binding var returnToLessonPlotId: Int?
    var notebookState: NotebookState? = nil
    var onBack: () -> Void

    @State private var sceneHolder = SceneHolder<GoldsmithScene>()

    // Player tracking
    @State private var playerPosition: CGPoint = CGPoint(x: 0.5, y: 0.5)
    @State private var playerIsWalking = false

    // Active station overlay
    @State private var activeStation: GoldsmithStation? = nil

    // Avatar box
    @State private var avatarInBox = true

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Layer 1: SpriteKit scene
                GameSpriteView(scene: makeScene(), options: [.allowsTransparency])
                    .ignoresSafeArea()

                // Layer 2: Nav bar
                if let vm = viewModel {
                    VStack(spacing: 0) {
                        GameTopBarView(
                            title: "Bottega di Lotti",
                            viewModel: vm,
                            onNavigate: { dest in onNavigate?(dest) },
                            onBackToMenu: onBackToMenu
                        )
                        Spacer()
                    }
                }

                // Layer 3: Station info overlay
                if let station = activeStation {
                    stationOverlay(for: station, in: geometry)
                }

                // Layer 4: Back button
                VStack {
                    Spacer()
                    HStack {
                        Button(action: onBack) {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.left")
                                Text("Back to Workshop")
                            }
                            .font(.custom("EBGaramond-Regular", size: 16))
                            .foregroundStyle(RenaissanceColors.sepiaInk)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(RenaissanceColors.parchment.opacity(0.92))
                                    .overlay(
                                        Capsule()
                                            .stroke(RenaissanceColors.warmBrown.opacity(0.3), lineWidth: 1.5)
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                        .padding(20)
                        Spacer()
                    }
                }
            }
        }
    }

    // MARK: - Scene Factory

    private func makeScene() -> GoldsmithScene {
        if let existing = sceneHolder.scene {
            return existing
        }
        let scene = GoldsmithScene()
        scene.size = CGSize(width: 3500, height: 2500)
        scene.scaleMode = .aspectFill
        scene.apprenticeIsBoy = onboardingState?.apprenticeGender == .boy

        scene.onPlayerPositionChanged = { pos, walking in
            self.playerPosition = pos
            self.playerIsWalking = walking
        }

        scene.onPlayerStartedWalking = {
            withAnimation(.easeOut(duration: 0.2)) {
                self.activeStation = nil
                self.avatarInBox = false
            }
        }

        scene.onFurnitureReached = { station in
            withAnimation(.spring(response: 0.3)) {
                self.activeStation = station
            }
        }

        sceneHolder.scene = scene
        return scene
    }

    // MARK: - Station Overlay

    private func stationOverlay(for station: GoldsmithStation, in geometry: GeometryProxy) -> some View {
        VStack(spacing: 12) {
            // Station title
            Text(station.displayName)
                .font(.custom("Cinzel-Bold", size: 22))
                .foregroundStyle(RenaissanceColors.sepiaInk)

            Text(station.italianName)
                .font(.custom("EBGaramond-Italic", size: 16))
                .foregroundStyle(RenaissanceColors.warmBrown)

            // Educational text
            Text(station.educationalText)
                .font(.custom("EBGaramond-Regular", size: 15))
                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.85))
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            // Dismiss
            Button("Continue") {
                withAnimation(.easeOut(duration: 0.2)) {
                    activeStation = nil
                }
            }
            .font(.custom("EBGaramond-Regular", size: 16))
            .foregroundStyle(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 8)
            .background(Capsule().fill(RenaissanceColors.warmBrown))
        }
        .padding(24)
        .frame(maxWidth: 420)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(RenaissanceColors.parchment)
                .shadow(color: .black.opacity(0.2), radius: 12, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(RenaissanceColors.warmBrown.opacity(0.3), lineWidth: 1.5)
        )
        .transition(.scale.combined(with: .opacity))
        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
    }
}
