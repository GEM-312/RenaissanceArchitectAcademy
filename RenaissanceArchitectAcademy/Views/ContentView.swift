import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var showingMainMenu = true
    @State private var showingOnboarding = false
    @State private var selectedDestination: SidebarDestination? = .cityMap  // Start with SpriteKit map!
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase

    // Shared ViewModel - so map and era views share progress!
    @StateObject private var cityViewModel = CityViewModel()

    // Shared Workshop state - so materials persist between workshop and challenges
    @State private var workshopState = WorkshopState()

    // Onboarding state — persists to SwiftData
    @State private var onboardingState = OnboardingState()

    // Notebook state — persists to Documents/Notebooks/
    @State private var notebookState = NotebookState()

    // Persistence manager — kept as @State so helpers can access it
    @State private var persistenceManager: PersistenceManager?

    // Persistence loading guard
    @State private var hasLoadedPersistence = false

    // Lesson return — stores plot ID when student navigates to workshop/forest from a lesson
    @State private var returnToLessonPlotId: Int? = nil

    // Play time tracking
    @State private var sessionStartDate: Date? = nil

    var body: some View {
        ZStack {
            // Parchment background
            RenaissanceColors.parchment
                .ignoresSafeArea()

            if showingOnboarding {
                OnboardingView(onboardingState: onboardingState) {
                    // Onboarding completed — switch to the new player's data
                    let name = onboardingState.apprenticeName
                    if !name.isEmpty {
                        switchToPlayer(name)
                    }
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
        .onAppear {
            guard !hasLoadedPersistence else { return }
            hasLoadedPersistence = true
            let manager = PersistenceManager(modelContext: modelContext)
            persistenceManager = manager

            // Try to load the most recent player's data
            if let recentName = manager.loadMostRecentPlayer() {
                manager.currentPlayerName = recentName
            }

            cityViewModel.persistenceManager = manager
            cityViewModel.loadFromPersistence()
            workshopState.persistenceManager = manager
            workshopState.loadFromPersistence()
            onboardingState.loadFromSwiftData(manager: manager)

            // Seed lesson records into SwiftData on first launch
            LessonSeedService.seedIfNeeded(context: modelContext)

            // Scope notebook to the current player
            notebookState.switchPlayer(to: manager.currentPlayerName)

            // Start tracking play time
            sessionStartDate = Date()
        }
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .background, .inactive:
                flushPlayTime()
            case .active:
                // Restart session clock when returning
                if sessionStartDate == nil {
                    sessionStartDate = Date()
                }
            @unknown default:
                break
            }
        }
        #if os(macOS)
        .frame(minWidth: 800, minHeight: 700)
        #endif
    }

    // MARK: - Player Switching

    /// Switch all systems to a specific player's save data
    private func switchToPlayer(_ name: String) {
        guard let manager = persistenceManager else { return }
        manager.currentPlayerName = name
        cityViewModel.loadFromPersistence()
        workshopState.loadFromPersistence()
        notebookState.switchPlayer(to: name)
    }

    /// Navigate to a destination from any screen
    private func navigateTo(_ destination: SidebarDestination) {
        withAnimation(.easeInOut(duration: 0.3)) {
            selectedDestination = destination
        }
    }

    /// Save accumulated play time since session start
    private func flushPlayTime() {
        guard let start = sessionStartDate else { return }
        let elapsed = Date().timeIntervalSince(start)
        if elapsed > 1 {
            cityViewModel.addPlayTime(elapsed)
        }
        sessionStartDate = nil
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
            CityMapView(viewModel: cityViewModel, workshopState: workshopState, notebookState: notebookState, onNavigate: navigateTo, onBackToMenu: backToMenu, onboardingState: onboardingState, returnToLessonPlotId: $returnToLessonPlotId)
        case .allBuildings:
            CityView(viewModel: cityViewModel, filterEra: nil, workshopState: workshopState)
        case .era(let era):
            CityView(viewModel: cityViewModel, filterEra: era, workshopState: workshopState)
        case .profile:
            ProfileView(viewModel: cityViewModel, workshopState: workshopState, onboardingState: onboardingState, onNavigate: navigateTo, onBackToMenu: backToMenu)
        case .workshop:
            WorkshopView(workshop: workshopState, viewModel: cityViewModel, notebookState: notebookState, onNavigate: navigateTo, onBackToMenu: backToMenu, onboardingState: onboardingState, returnToLessonPlotId: $returnToLessonPlotId)
        case .forest:
            ForestMapView(workshop: workshopState, viewModel: cityViewModel, onNavigate: navigateTo, onBackToWorkshop: { navigateTo(.workshop) }, onBackToMenu: backToMenu, onboardingState: onboardingState, returnToLessonPlotId: $returnToLessonPlotId)
        case .knowledgeTests:
            KnowledgeTestsView(viewModel: cityViewModel, workshopState: workshopState)
        case .notebook(let buildingId):
            if let plot = cityViewModel.buildingPlots.first(where: { $0.id == buildingId }) {
                NotebookView(
                    buildingId: buildingId,
                    buildingName: plot.building.name,
                    sciences: plot.building.sciences,
                    era: plot.building.era,
                    notebookState: notebookState,
                    onDismiss: { navigateTo(.cityMap) }
                )
            } else {
                CityMapView(viewModel: cityViewModel, workshopState: workshopState, notebookState: notebookState, onNavigate: navigateTo, onBackToMenu: backToMenu, onboardingState: onboardingState, returnToLessonPlotId: $returnToLessonPlotId)
            }
        case .none:
            CityMapView(viewModel: cityViewModel, workshopState: workshopState, notebookState: notebookState, onNavigate: navigateTo, onBackToMenu: backToMenu, onboardingState: onboardingState, returnToLessonPlotId: $returnToLessonPlotId)
        }
    }
}

#Preview {
    ContentView()
}

#Preview("iPad") {
    ContentView()
}
