import SwiftUI

/// Workshop mini-game — outdoor gathering + indoor crafting
/// Outdoor: SpriteKit map where apprentice collects materials from resource stations
/// Indoor: Crafting room with workbench, furnace, pigment table, storage shelf
struct WorkshopView: View {
    var workshop: WorkshopState
    var viewModel: CityViewModel? = nil
    var onNavigate: ((SidebarDestination) -> Void)? = nil
    var onBackToMenu: (() -> Void)? = nil
    var onboardingState: OnboardingState? = nil

    @State private var showInterior = false

    var body: some View {
        ZStack {
            if showInterior {
                WorkshopInteriorView(workshop: workshop, viewModel: viewModel, onNavigate: onNavigate, onBackToMenu: onBackToMenu, onboardingState: onboardingState) {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        showInterior = false
                    }
                }
                .transition(.move(edge: .trailing))
            } else {
                WorkshopMapView(
                    workshop: workshop,
                    viewModel: viewModel,
                    onNavigate: onNavigate,
                    onBackToMenu: onBackToMenu,
                    onEnterInterior: {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            showInterior = true
                        }
                    },
                    onboardingState: onboardingState
                )
                .transition(.move(edge: .leading))
            }
        }
        .onAppear { workshop.startRespawnTimer() }
        .onDisappear { workshop.stopRespawnTimer() }
    }
}

#Preview {
    WorkshopView(workshop: WorkshopState())
}
