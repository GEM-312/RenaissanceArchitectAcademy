import SwiftUI

struct ContentView: View {
    @State private var showingMainMenu = true
    @State private var selectedDestination: SidebarDestination? = .cityMap  // Start with SpriteKit map!
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    // Shared ViewModel - so map and era views share progress!
    @StateObject private var cityViewModel = CityViewModel()

    // Shared Workshop state - so materials persist between workshop and challenges
    @State private var workshopState = WorkshopState()

    var body: some View {
        ZStack {
            // Parchment background
            RenaissanceColors.parchment
                .ignoresSafeArea()

            if showingMainMenu {
                MainMenuView(
                    onStartGame: {
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
                // Use sidebar navigation on iPad landscape / Mac
                if horizontalSizeClass == .regular {
                    NavigationSplitView {
                        SidebarView(
                            selectedDestination: $selectedDestination,
                            onBackToMenu: {
                                withAnimation {
                                    showingMainMenu = true
                                }
                            }
                        )
                    } detail: {
                        detailView
                    }
                    #if os(macOS)
                    .navigationSplitViewStyle(.balanced)
                    #endif
                } else {
                    // Compact view for iPad portrait
                    NavigationStack {
                        detailView
                            .toolbar {
                                #if os(iOS)
                                ToolbarItem(placement: .navigationBarLeading) {
                                    Button {
                                        withAnimation {
                                            showingMainMenu = true
                                        }
                                    } label: {
                                        Label("Menu", systemImage: "line.3.horizontal")
                                    }
                                    .tint(RenaissanceColors.sepiaInk)
                                }
                                #else
                                ToolbarItem(placement: .automatic) {
                                    Button {
                                        withAnimation {
                                            showingMainMenu = true
                                        }
                                    } label: {
                                        Label("Menu", systemImage: "line.3.horizontal")
                                    }
                                    .tint(RenaissanceColors.sepiaInk)
                                }
                                #endif
                            }
                    }
                }
            }
        }
        #if os(macOS)
        .frame(minWidth: 800, minHeight: 600)
        #endif
    }

    /// Navigate to a destination from any screen
    private func navigateTo(_ destination: SidebarDestination) {
        withAnimation(.easeInOut(duration: 0.3)) {
            selectedDestination = destination
        }
    }

    /// Detail view based on sidebar selection
    @ViewBuilder
    private var detailView: some View {
        switch selectedDestination {
        case .cityMap:
            CityMapView(viewModel: cityViewModel, workshopState: workshopState, onNavigate: navigateTo)
        case .allBuildings:
            CityView(viewModel: cityViewModel, filterEra: nil, workshopState: workshopState)
        case .era(let era):
            CityView(viewModel: cityViewModel, filterEra: era, workshopState: workshopState)
        case .profile:
            ProfileView()
        case .workshop:
            WorkshopView(workshop: workshopState, viewModel: cityViewModel, onNavigate: navigateTo)
        case .knowledgeTests:
            KnowledgeTestsView(viewModel: cityViewModel, workshopState: workshopState)
        case .none:
            CityMapView(viewModel: cityViewModel, workshopState: workshopState, onNavigate: navigateTo)
        }
    }
}

#Preview {
    ContentView()
}

#Preview("iPad") {
    ContentView()
}
