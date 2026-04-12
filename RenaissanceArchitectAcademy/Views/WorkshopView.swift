import SwiftUI

/// Workshop mini-game — outdoor gathering + indoor crafting + goldsmith workshop
/// Outdoor: SpriteKit map where apprentice collects materials from resource stations
/// Indoor: Crafting room with workbench, furnace, pigment table, storage shelf
/// Goldsmith: Bottega di Lotti with engraving bench, casting station, furnace, polishing wheel
struct WorkshopView: View {
    var workshop: WorkshopState
    var viewModel: CityViewModel? = nil
    var notebookState: NotebookState? = nil
    var onNavigate: ((SidebarDestination) -> Void)? = nil
    var onBackToMenu: (() -> Void)? = nil
    var onboardingState: OnboardingState? = nil
    @Binding var returnToLessonPlotId: Int?

    enum WorkshopInterior {
        case outdoor
        case craftingRoom
        case goldsmith
    }

    @State private var activeInterior: WorkshopInterior = .outdoor

    // Interior transition overlay state
    @State private var isTransitioning = false
    @State private var pendingInterior: WorkshopInterior?

    /// Switch interior with ink-wash transition
    private func switchInterior(to interior: WorkshopInterior) {
        guard !isTransitioning else { return }
        SoundManager.shared.play(.sceneTransition)
        pendingInterior = interior
        isTransitioning = true
    }

    var body: some View {
        ZStack {
            switch activeInterior {
            case .outdoor:
                WorkshopMapView(
                    workshop: workshop,
                    viewModel: viewModel,
                    notebookState: notebookState,
                    onNavigate: onNavigate,
                    onBackToMenu: onBackToMenu,
                    onEnterInterior: { switchInterior(to: .craftingRoom) },
                    onEnterGoldsmith: { switchInterior(to: .goldsmith) },
                    onboardingState: onboardingState,
                    returnToLessonPlotId: $returnToLessonPlotId
                )

            case .craftingRoom:
                CraftingRoomMapView(workshop: workshop, viewModel: viewModel, onNavigate: onNavigate, onBackToMenu: onBackToMenu, onboardingState: onboardingState, returnToLessonPlotId: $returnToLessonPlotId, notebookState: notebookState) {
                    switchInterior(to: .outdoor)
                }

            case .goldsmith:
                GoldsmithMapView(workshop: workshop, viewModel: viewModel, onNavigate: onNavigate, onBackToMenu: onBackToMenu, onboardingState: onboardingState, returnToLessonPlotId: $returnToLessonPlotId, notebookState: notebookState) {
                    switchInterior(to: .outdoor)
                }
            }
        }
        .sceneTransition(isActive: $isTransitioning) {
            // Midpoint: swap interior while screen is covered
            if let pending = pendingInterior {
                activeInterior = pending
                pendingInterior = nil
            }
        }
    }
}

#Preview {
    WorkshopView(workshop: WorkshopState(), returnToLessonPlotId: .constant(nil))
}
