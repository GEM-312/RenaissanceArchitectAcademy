import SwiftUI

struct ContentView: View {
    @State private var showingMainMenu = true
    @State private var showingOnboarding = false
    @State private var selectedDestination: SidebarDestination? = .cityMap  // Start with SpriteKit map!
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    // Shared ViewModel - so map and era views share progress!
    @StateObject private var cityViewModel = CityViewModel()

    // Shared Workshop state - so materials persist between workshop and challenges
    @State private var workshopState = WorkshopState()

    // Onboarding state — persists to UserDefaults
    @State private var onboardingState = OnboardingState()

    var body: some View {
        ZStack {
            // Parchment background
            RenaissanceColors.parchment
                .ignoresSafeArea()

            if showingOnboarding {
                OnboardingView(onboardingState: onboardingState) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showingOnboarding = false
                        showingMainMenu = false
                    }
                }
                .transition(.opacity)
            } else if showingMainMenu {
                MainMenuView(
                    onStartGame: {
                        // TODO: Re-enable skip after onboarding is finalized:
                        // if onboardingState.hasCompletedOnboarding { showingMainMenu = false; return }
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showingOnboarding = true
                        }
                    },
                    onContinue: {
                        // Skip onboarding, go straight to city map
                        selectedDestination = .cityMap
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showingMainMenu = false
                        }
                    },
                    onOpenWorkshop: {
                        selectedDestination = .workshop
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showingMainMenu = false
                        }
                    }
                )
            } else {
                // Full-width detail view — no sidebar
                detailView
            }
        }
        #if os(macOS)
        .frame(minWidth: 800, minHeight: 700)
        #endif
    }

    /// Navigate to a destination from any screen
    private func navigateTo(_ destination: SidebarDestination) {
        withAnimation(.easeInOut(duration: 0.3)) {
            selectedDestination = destination
        }
    }

    /// Return to the main menu
    private func backToMenu() {
        withAnimation(.easeInOut(duration: 0.5)) {
            showingMainMenu = true
        }
    }

    /// Detail view based on sidebar selection
    @ViewBuilder
    private var detailView: some View {
        switch selectedDestination {
        case .cityMap:
            CityMapView(viewModel: cityViewModel, workshopState: workshopState, onNavigate: navigateTo, onBackToMenu: backToMenu)
        case .allBuildings:
            CityView(viewModel: cityViewModel, filterEra: nil, workshopState: workshopState)
        case .era(let era):
            CityView(viewModel: cityViewModel, filterEra: era, workshopState: workshopState)
        case .profile:
            ProfileView()
        case .workshop:
            WorkshopView(workshop: workshopState, viewModel: cityViewModel, onNavigate: navigateTo, onBackToMenu: backToMenu)
        case .knowledgeTests:
            KnowledgeTestsView(viewModel: cityViewModel, workshopState: workshopState)
        case .none:
            CityMapView(viewModel: cityViewModel, workshopState: workshopState, onNavigate: navigateTo, onBackToMenu: backToMenu)
        }
    }
}

#Preview {
    ContentView()
}

#Preview("iPad") {
    ContentView()
}
