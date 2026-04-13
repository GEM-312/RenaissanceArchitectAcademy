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
                    onEnterInterior: { transitionTo(.craftingRoom) },
                    onEnterGoldsmith: { transitionTo(.goldsmith) },
                    onboardingState: onboardingState,
                    returnToLessonPlotId: $returnToLessonPlotId
                )
                .transition(.blurReplace)

            case .craftingRoom:
                CraftingRoomMapView(workshop: workshop, viewModel: viewModel, onNavigate: onNavigate, onBackToMenu: onBackToMenu, onboardingState: onboardingState, returnToLessonPlotId: $returnToLessonPlotId, notebookState: notebookState) {
                    transitionTo(.outdoor)
                }
                .transition(.blurReplace)

            case .goldsmith:
                GoldsmithMapView(workshop: workshop, viewModel: viewModel, onNavigate: onNavigate, onBackToMenu: onBackToMenu, onboardingState: onboardingState, returnToLessonPlotId: $returnToLessonPlotId, notebookState: notebookState) {
                    transitionTo(.outdoor)
                }
                .transition(.blurReplace)
            }
        }
    }

    private func transitionTo(_ interior: WorkshopInterior) {
        SoundManager.shared.play(.sceneTransition)
        withAnimation(.easeInOut(duration: 0.4)) {
            activeInterior = interior
        }
    }
}

#Preview {
    WorkshopView(workshop: WorkshopState(), returnToLessonPlotId: .constant(nil))
}
