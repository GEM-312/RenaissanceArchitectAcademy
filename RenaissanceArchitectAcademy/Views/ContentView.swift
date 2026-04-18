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
    @State private var cityViewModel = CityViewModel()

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

    // Game settings — theme, volume, persisted via UserDefaults (shared singleton for SpriteKit access)
    @State private var gameSettings = GameSettings.shared

    // Play time tracking
    @State private var sessionStartDate: Date? = nil

    // Scene transition uses .blurReplace on detailView (no overlay needed)

    var body: some View {
        #if DEBUG
        let _ = Self._printChanges()
        #endif
        ZStack {
            // Parchment background
            RenaissanceColors.parchment
                .ignoresSafeArea()

            if showingOnboarding {
                OnboardingView(onboardingState: onboardingState) {
                    // Prefetch city scene during onboarding completion
                    AssetManager.shared.prefetchAssets(tag: AssetManager.cityScene)
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
                // Full-width detail view — blur dissolve between scenes
                detailView
                    .transition(.blurReplace)
                    .id(selectedDestination.debugDescription)
            }
            // Editor toggle is in each scene's own debug buttons (CityMapView, etc.)
        }
        .environment(\.gameSettings, gameSettings)
        .onAppear {
            guard !hasLoadedPersistence else { return }
            hasLoadedPersistence = true
            let manager = PersistenceManager(modelContext: modelContext)
            persistenceManager = manager

            // One-time reset for corrupted saves (original)
            let resetKey = "didResetCorruptedSaves_v1"
            if !UserDefaults.standard.bool(forKey: resetKey) {
                manager.resetAllData()
                UserDefaults.standard.set(true, forKey: resetKey)
            }

            // Schema migration: clear only building progress (keeps player name, florins, onboarding)
            let schemaKey = "didMigrateBuildingProgress_v2_cards"
            if !UserDefaults.standard.bool(forKey: schemaKey) {
                print("[INIT] Schema migration — clearing building progress records only")
                manager.resetBuildingProgressOnly()
                UserDefaults.standard.set(true, forKey: schemaKey)
            }

            // Clean up stale empty-name saves from previous sessions
            manager.deleteEmptyNameSaves()

            // Try to load the most recent player's data
            if let recentName = manager.loadMostRecentPlayer() {
                manager.currentPlayerName = recentName
            }

            cityViewModel.persistenceManager = manager
            workshopState.persistenceManager = manager
            onboardingState.loadFromSwiftData(manager: manager)

            // Only load game data if we have a real player (not empty-name placeholder)
            if !manager.currentPlayerName.isEmpty {
                print("[INIT] Loading data for recent player: '\(manager.currentPlayerName)'")
                cityViewModel.loadFromPersistence()
                workshopState.loadFromPersistence()
                notebookState.switchPlayer(to: manager.currentPlayerName)
                print("[INIT] Loaded — florins: \(cityViewModel.goldFlorins), materials: \(workshopState.rawMaterials)")
            } else {
                print("[INIT] No recent player found, starting fresh")
            }

            // Seed lesson records into SwiftData on first launch
            LessonSeedService.seedIfNeeded(context: modelContext)

            // Start tracking play time
            sessionStartDate = Date()

        }
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .background, .inactive:
                flushPlayTime()
                GameCenterManager.shared.pauseCurrentActivity()
            case .active:
                // Restart session clock when returning
                if sessionStartDate == nil {
                    sessionStartDate = Date()
                }
                GameCenterManager.shared.resumeCurrentActivity()
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

        print("[PLAYER SWITCH] Switching to player: '\(name)' (was: '\(manager.currentPlayerName)')")
        print("[PLAYER SWITCH] Before reset — florins: \(cityViewModel.goldFlorins), materials: \(workshopState.rawMaterials)")

        // Reset in-memory state BEFORE changing player name
        // (prevents old data being auto-saved to new player)
        cityViewModel.goldFlorins = 0
        cityViewModel.earnedScienceBadges = []
        cityViewModel.buildingProgressMap = [:]
        cityViewModel.activeBuildingId = nil
        workshopState.rawMaterials = [:]
        workshopState.craftedMaterials = [:]

        // Now switch to the new player and load their data
        manager.currentPlayerName = name
        cityViewModel.loadFromPersistence()
        workshopState.loadFromPersistence()
        notebookState.switchPlayer(to: name)

        print("[PLAYER SWITCH] After load — florins: \(cityViewModel.goldFlorins), materials: \(workshopState.rawMaterials)")
    }

    /// Navigate to a destination from any screen
    private func navigateTo(_ destination: SidebarDestination) {
        SoundManager.shared.play(.sceneTransition)
        withAnimation(.easeInOut(duration: 0.5)) {
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
            CityView(viewModel: cityViewModel, filterEra: nil, workshopState: workshopState, onNavigate: navigateTo)
        case .era(let era):
            CityView(viewModel: cityViewModel, filterEra: era, workshopState: workshopState, onNavigate: navigateTo)
        case .profile:
            ProfileView(viewModel: cityViewModel, workshopState: workshopState, onboardingState: onboardingState, onNavigate: navigateTo, onBackToMenu: backToMenu)
        case .workshop:
            WorkshopView(workshop: workshopState, viewModel: cityViewModel, notebookState: notebookState, onNavigate: navigateTo, onBackToMenu: backToMenu, onboardingState: onboardingState, returnToLessonPlotId: $returnToLessonPlotId)
        case .forest:
            ForestMapView(workshop: workshopState, viewModel: cityViewModel, onNavigate: navigateTo, onBackToWorkshop: { navigateTo(.workshop) }, onBackToMenu: backToMenu, onboardingState: onboardingState, returnToLessonPlotId: $returnToLessonPlotId)
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
