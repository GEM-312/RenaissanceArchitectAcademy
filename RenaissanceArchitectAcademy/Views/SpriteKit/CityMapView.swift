import SwiftUI
import SpriteKit

/// SwiftUI wrapper for the SpriteKit city scene
///
/// HOW THIS WORKS:
/// ---------------
/// SwiftUI can't directly show SpriteKit content, so we use `SpriteView` as a bridge.
/// Think of it like a window into the game world.
///
/// The data flow:
/// 1. User taps building in SpriteKit → CityScene calls onBuildingSelected
/// 2. We find the matching BuildingPlot from CityViewModel
/// 3. We show BuildingDetailOverlay (pure SwiftUI) as a sheet
/// 4. User taps "Begin Challenge" → we show InteractiveChallengeView
///
struct CityMapView: View {

    // MARK: - Properties

    /// ViewModel holds all building data (shared with CityView)
    @ObservedObject var viewModel: CityViewModel

    /// Shared workshop state for hint crafting cost
    var workshopState: WorkshopState

    /// Shared notebook state for building notebooks
    var notebookState: NotebookState? = nil

    /// Navigate to other screens via top bar
    var onNavigate: ((SidebarDestination) -> Void)? = nil

    /// Return to main menu (Home button in panel)
    var onBackToMenu: (() -> Void)? = nil

    /// Onboarding state for avatar display
    var onboardingState: OnboardingState? = nil

    /// When set, auto-opens the lesson for this plot ID (used for return-from-workshop)
    @Binding var returnToLessonPlotId: Int?

    /// The currently selected plot (when user taps a building)
    @State private var selectedPlot: BuildingPlot?

    /// Controls the building detail sheet
    @State private var showBuildingDetail = false

    /// Controls the challenge view
    @State private var showChallenge = false

    /// Controls the sketching challenge view
    @State private var showSketching = false

    /// Controls the mascot dialogue (new game flow)
    @State private var showMascotDialogue = false

    /// Controls the material puzzle game
    @State private var showMaterialPuzzle = false

    /// Tracks which dialogue path brought user to the challenge
    @State private var challengeEntryPath: BuildingCardChoice?

    /// Controls the "Go to Workshop" prompt after quiz completion
    @State private var showWorkshopPrompt = false

    /// Controls the building lesson view (Card 1: Read to Earn)
    @State private var showBuildingLesson = false

    /// Controls the environment picker (Card 2: Explore Environments)
    @State private var showEnvironmentPicker = false

    /// Controls the building checklist view (Card 3: Ready to Build)
    @State private var showBuildingChecklist = false

    /// Controls the Workshop sheet (opened from post-quiz prompt)
    @State private var showWorkshopSheet = false

    /// Controls the locked building message overlay
    @State private var showLockedMessage = false
    @State private var lockedMessage = ""

    /// Reference to the SpriteKit scene (so we can call methods on it)
    @State private var scene: CityScene?

    /// NSEvent monitor for Magic Mouse scroll-to-zoom
    @State private var scrollMonitor: Any?

    /// Environment for navigation
    @Environment(\.dismiss) private var dismiss

    // MARK: - Building ID Mapping
    /// Maps SpriteKit building IDs to ViewModel plot IDs
    private let buildingIdToPlotId: [String: Int] = [
        // Ancient Rome (8)
        "aqueduct": 1,
        "colosseum": 2,
        "romanBaths": 3,
        "pantheon": 4,
        "romanRoads": 5,
        "harbor": 6,
        "siegeWorkshop": 7,
        "insula": 8,
        // Renaissance Italy (9)
        "duomo": 9,
        "botanicalGarden": 10,
        "glassworks": 11,
        "arsenal": 12,
        "anatomyTheater": 13,
        "leonardoWorkshop": 14,
        "flyingMachine": 15,
        "vaticanObservatory": 16,
        "printingPress": 17
    ]

    // MARK: - Body

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // The SpriteKit scene (the actual game map — fills full width)
                SpriteView(scene: makeScene(), options: [.allowsTransparency])
                    .ignoresSafeArea()
                    .gesture(pinchGesture)

                // Nav (left) + Buildings (right) with margins
                VStack(spacing: 0) {
                    navigationPanel
                        .frame(maxWidth: .infinity)
                    Spacer()
                    bottomHint
                }
                .frame(maxWidth: .infinity)
                .padding(16)

            // Mascot dialogue — 3 game-loop cards
            if showMascotDialogue, let plot = selectedPlot {
                MascotDialogueView(
                    plot: plot,
                    viewModel: viewModel,
                    workshopState: workshopState,
                    notebookState: notebookState,
                    onOpenNotebook: { buildingId in
                        withAnimation {
                            showMascotDialogue = false
                            selectedPlot = nil
                        }
                        scene?.resetMascot()
                        onNavigate?(.notebook(buildingId))
                    },
                    onChoice: { choice in
                        withAnimation {
                            showMascotDialogue = false
                        }
                        challengeEntryPath = choice
                        switch choice {
                        case .readToEarn:
                            // Show building lesson view
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                withAnimation(.spring(response: 0.3)) {
                                    showBuildingLesson = true
                                }
                            }
                        case .environments:
                            // Show environment picker
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                withAnimation(.spring(response: 0.3)) {
                                    showEnvironmentPicker = true
                                }
                            }
                        case .readyToBuild:
                            // Show building checklist
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                withAnimation(.spring(response: 0.3)) {
                                    showBuildingChecklist = true
                                }
                            }
                        }
                    },
                    onDismiss: {
                        withAnimation {
                            showMascotDialogue = false
                            selectedPlot = nil
                        }
                        scene?.resetMascot()
                    }
                )
                .transition(.opacity)
            }

            // Building Lesson (Card 1: Read to Earn)
            if showBuildingLesson, let plot = selectedPlot {
                BuildingLessonView(
                    plot: plot,
                    viewModel: viewModel,
                    workshopState: workshopState,
                    notebookState: notebookState,
                    onNavigate: { destination in
                        // Store return-to-lesson before navigating to workshop/forest
                        returnToLessonPlotId = plot.id
                        withAnimation {
                            showBuildingLesson = false
                            selectedPlot = nil
                        }
                        scene?.resetMascot()
                        onNavigate?(destination)
                    },
                    onDismiss: {
                        withAnimation {
                            showBuildingLesson = false
                            selectedPlot = nil
                        }
                        scene?.resetMascot()
                    }
                )
                .transition(.opacity)
            }

            // Environment Picker (Card 2: Explore Environments)
            if showEnvironmentPicker {
                ZStack {
                    RenaissanceColors.overlayDimming
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation {
                                showEnvironmentPicker = false
                                selectedPlot = nil
                            }
                            scene?.resetMascot()
                        }

                    VStack(spacing: 20) {
                        Spacer()

                        BirdCharacter(isSitting: true)
                            .frame(width: 140, height: 140)

                        VStack(spacing: 16) {
                            Text("Where to next?")
                                .font(.custom("EBGaramond-SemiBold", size: 24))
                                .foregroundStyle(RenaissanceColors.sepiaInk)

                            environmentButton(icon: "hammer.fill", title: "Workshop", subtitle: "Collect raw materials", color: RenaissanceColors.warmBrown) {
                                withAnimation { showEnvironmentPicker = false; selectedPlot = nil }
                                scene?.resetMascot()
                                onNavigate?(.workshop)
                            }

                            environmentButton(icon: "tree.fill", title: "Forest", subtitle: "Gather timber & explore", color: RenaissanceColors.sageGreen) {
                                withAnimation { showEnvironmentPicker = false; selectedPlot = nil }
                                scene?.resetMascot()
                                onNavigate?(.forest)
                            }

                            Button {
                                withAnimation {
                                    showEnvironmentPicker = false
                                    selectedPlot = nil
                                }
                                scene?.resetMascot()
                            } label: {
                                Text("Stay on Map")
                                    .font(.custom("Mulish-Light", size: 16))
                                    .foregroundStyle(RenaissanceColors.sepiaInk)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(24)
                        .background(DialogueBubble())
                        .padding(.horizontal, 40)

                        Spacer()
                    }
                }
                .transition(.opacity)
            }

            // Building Checklist (Card 3: Ready to Build)
            if showBuildingChecklist, let plot = selectedPlot {
                BuildingChecklistView(
                    plot: plot,
                    viewModel: viewModel,
                    workshopState: workshopState,
                    onBeginConstruction: {
                        // Transition to construction → complete
                        viewModel.completeChallenge(for: plot.id)
                        viewModel.earnFlorins(GameRewards.buildCompleteFlorins)
                        if let buildingId = buildingIdToPlotId.first(where: { $0.value == plot.id })?.key {
                            scene?.updateBuildingState(buildingId, state: .complete)
                        }
                        withAnimation {
                            showBuildingChecklist = false
                            selectedPlot = nil
                        }
                        scene?.resetMascot()
                    },
                    onDismiss: {
                        withAnimation {
                            showBuildingChecklist = false
                            selectedPlot = nil
                        }
                        scene?.resetMascot()
                    }
                )
                .transition(.opacity)
            }

            // Locked building message
            if showLockedMessage {
                ZStack {
                    RenaissanceColors.overlayDimming
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation {
                                showLockedMessage = false
                            }
                            scene?.resetMascot()
                        }

                    VStack(spacing: 20) {
                        Spacer()

                        BirdCharacter(isSitting: true)
                            .frame(width: 160, height: 160)

                        VStack(spacing: 16) {
                            Image(systemName: "lock.fill")
                                .font(.custom("Mulish-Light", size: 32, relativeTo: .title3))
                                .foregroundStyle(RenaissanceColors.sepiaInk)

                            Text("Not Yet Unlocked")
                                .font(.custom("EBGaramond-SemiBold", size: 24))
                                .foregroundStyle(RenaissanceColors.sepiaInk)

                            Text(lockedMessage)
                                .font(.custom("EBGaramond-Regular", size: 18, relativeTo: .body))
                                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)

                            RenaissanceButton(title: "Got It") {
                                withAnimation {
                                    showLockedMessage = false
                                }
                                scene?.resetMascot()
                            }
                        }
                        .padding(28)
                        .background(DialogueBubble())
                        .padding(.horizontal, 40)

                        Spacer()
                    }
                }
                .transition(.opacity)
            }

            // Material puzzle game
            if showMaterialPuzzle, let plot = selectedPlot {
                MaterialPuzzleView(
                    buildingName: plot.building.name,
                    formula: formulaForBuilding(plot.building.name),
                    workshopState: workshopState,
                    onComplete: {
                        withAnimation {
                            showMaterialPuzzle = false
                        }
                        // Reset mascot and show challenge
                        scene?.resetMascot()
                        showChallenge = true
                    },
                    onDismiss: {
                        withAnimation {
                            showMaterialPuzzle = false
                            selectedPlot = nil
                        }
                        // Reset mascot position
                        scene?.resetMascot()
                    }
                )
                .transition(.move(edge: .trailing))  // Slide in from right
            }

            // Workshop prompt (after quiz from "I don't know" path)
            if showWorkshopPrompt {
                ZStack {
                    RenaissanceColors.overlayDimming
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation {
                                showWorkshopPrompt = false
                                selectedPlot = nil
                            }
                            scene?.resetMascot()
                        }

                    VStack(spacing: 20) {
                        Spacer()

                        BirdCharacter(isSitting: true)
                            .frame(width: 160, height: 160)

                        VStack(spacing: 16) {
                            Text("Nice work on the quiz!")
                                .font(.custom("EBGaramond-SemiBold", size: 24))
                                .foregroundStyle(RenaissanceColors.sepiaInk)

                            Text("Now head to the Workshop to collect raw materials and craft what you need to build.")
                                .font(.custom("EBGaramond-Regular", size: 18, relativeTo: .body))
                                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)

                            VStack(spacing: 10) {
                                RenaissanceButton(title: "Go to Workshop") {
                                    withAnimation {
                                        showWorkshopPrompt = false
                                        selectedPlot = nil
                                    }
                                    scene?.resetMascot()
                                    showWorkshopSheet = true
                                }

                                RenaissanceSecondaryButton(title: "Stay on Map") {
                                    withAnimation {
                                        showWorkshopPrompt = false
                                        selectedPlot = nil
                                    }
                                    scene?.resetMascot()
                                }
                            }
                        }
                        .padding(28)
                        .background(DialogueBubble())
                        .padding(.horizontal, 40)

                        Spacer()
                    }
                }
                .transition(.opacity)
            }

            // Building detail overlay (shown for info/help)
            if showBuildingDetail, let plot = selectedPlot {
                BuildingDetailOverlay(
                    plot: plot,
                    onDismiss: {
                        withAnimation {
                            showBuildingDetail = false
                            selectedPlot = nil
                        }
                    },
                    onBeginChallenge: {
                        showBuildingDetail = false
                        showChallenge = true
                    },
                    isLargeScreen: true
                )
                .transition(.opacity)
            }
            } // end ZStack
        } // end GeometryReader
        .onAppear {
            // Sync completion states when view appears (e.g., after completing in Era view)
            if let currentScene = scene {
                syncCompletionStates(in: currentScene)
            }
            // Auto-open lesson if returning from workshop/forest
            if let plotId = returnToLessonPlotId,
               let plot = viewModel.buildingPlots.first(where: { $0.id == plotId }) {
                selectedPlot = plot
                showBuildingLesson = true
                returnToLessonPlotId = nil
            }
            #if os(macOS)
            scrollMonitor = NSEvent.addLocalMonitorForEvents(matching: .scrollWheel) { [self] event in
                if !showMascotDialogue && !showBuildingLesson && !showChallenge && !showLockedMessage && !showBuildingChecklist {
                    scene?.handleScrollZoom(deltaY: event.deltaY)
                }
                return event
            }
            #endif
        }
        .onDisappear {
            #if os(macOS)
            if let monitor = scrollMonitor {
                NSEvent.removeMonitor(monitor)
                scrollMonitor = nil
            }
            #endif
        }
        .sheet(isPresented: $showChallenge) {
            if let plot = selectedPlot,
               let challenge = ChallengeContent.interactiveChallenge(for: plot.building.name) {
                InteractiveChallengeView(
                    challenge: challenge,
                    workshopState: workshopState,
                    onComplete: { correctAnswers, totalQuestions in
                        // Mark as complete if they got most questions right
                        let passThreshold = totalQuestions / 2
                        if correctAnswers > passThreshold {
                            viewModel.completeChallenge(for: plot.id)
                            // Update the SpriteKit building state
                            if let buildingId = buildingIdToPlotId.first(where: { $0.value == plot.id })?.key {
                                scene?.updateBuildingState(buildingId, state: .complete)
                            }
                        }
                        // Close the challenge sheet
                        showChallenge = false

                        // If user came from "I don't know", offer to go to Workshop
                        if challengeEntryPath == .readToEarn {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                withAnimation(.spring(response: 0.4)) {
                                    showWorkshopPrompt = true
                                }
                            }
                        } else {
                            selectedPlot = nil
                        }
                    },
                    onDismiss: {
                        showChallenge = false
                        selectedPlot = nil
                    }
                )
            } else {
                // Fallback if no challenge exists yet
                Text("Challenge coming soon!")
                    .font(.custom("EBGaramond-Regular", size: 24))
                    .foregroundColor(RenaissanceColors.sepiaInk)
            }
        }
        .sheet(isPresented: $showSketching) {
            if let plot = selectedPlot,
               let sketchChallenge = SketchingContent.sketchingChallenge(for: plot.building.name) {
                SketchingChallengeView(
                    challenge: sketchChallenge,
                    onComplete: { completedPhases in
                        viewModel.completeSketchingPhase(for: plot.id, phases: completedPhases)
                        // Update the SpriteKit building state
                        if let buildingId = buildingIdToPlotId.first(where: { $0.value == plot.id })?.key {
                            scene?.updateBuildingState(buildingId, state: .sketched)
                        }
                        showSketching = false
                        selectedPlot = nil
                    },
                    onDismiss: {
                        showSketching = false
                        selectedPlot = nil
                    }
                )
            } else {
                Text("Sketching challenge coming soon!")
                    .font(.custom("EBGaramond-Regular", size: 24))
                    .foregroundColor(RenaissanceColors.sepiaInk)
            }
        }
        .sheet(isPresented: $showWorkshopSheet) {
            WorkshopView(workshop: workshopState, returnToLessonPlotId: .constant(nil))
                #if os(macOS)
                .frame(minWidth: 900, minHeight: 600)
                #endif
        }
    }

    // MARK: - Scene Creation

    /// Creates the SpriteKit scene (only once)
    private func makeScene() -> CityScene {
        // Return existing scene if we already have one
        if let existingScene = scene {
            // Sync completion states in case they changed
            syncCompletionStates(in: existingScene)
            return existingScene
        }

        // Create new scene
        let newScene = CityScene()
        newScene.size = CGSize(width: 3500, height: 2500)
        newScene.scaleMode = .aspectFill

        // When mascot reaches building, show dialogue (or locked message)
        newScene.onMascotReachedBuilding = { [self] buildingId in
            // Convert SpriteKit ID ("duomo") to ViewModel ID (4)
            guard let plotId = buildingIdToPlotId[buildingId],
                  let plot = viewModel.buildingPlots.first(where: { $0.id == plotId }) else {
                return
            }

            // Block tapping locked buildings — show unlock message instead
            if !viewModel.isTierUnlocked(plot.building.difficultyTier) {
                lockedMessage = viewModel.tierUnlockMessage(for: plot.building.difficultyTier)
                withAnimation(.spring(response: 0.3)) {
                    showLockedMessage = true
                }
                return
            }

            // Show the mascot dialogue (new game flow)
            selectedPlot = plot
            withAnimation(.spring(response: 0.3)) {
                showMascotDialogue = true
            }
        }

        // When mascot exits to puzzle, show puzzle view
        newScene.onMascotExitToPuzzle = { [self] in
            withAnimation(.spring(response: 0.3)) {
                showMaterialPuzzle = true
            }
        }

        // Keep the old callback for direct access if needed
        newScene.onBuildingSelected = { _ in
            // Now handled by onMascotReachedBuilding
        }

        // Store reference immediately
        scene = newScene

        // Sync initial completion states from ViewModel
        // This runs after scene is set up, so we delay slightly
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.syncCompletionStates(in: newScene)
        }

        return newScene
    }

    /// Sync building completion states from ViewModel to SpriteKit scene
    private func syncCompletionStates(in scene: CityScene) {
        for (buildingId, plotId) in buildingIdToPlotId {
            if let plot = viewModel.buildingPlots.first(where: { $0.id == plotId }) {
                let tierUnlocked = viewModel.isTierUnlocked(plot.building.difficultyTier)
                let state: BuildingState
                if !tierUnlocked {
                    state = .locked
                } else if plot.isCompleted {
                    state = .complete
                } else if plot.sketchingProgress.isSketchingComplete {
                    state = .sketched
                } else {
                    state = .available
                }
                scene.updateBuildingState(buildingId, state: state)

                // Set tier badge on building node
                if let node = scene.buildingNodes[buildingId] {
                    node.setTierBadge(plot.building.difficultyTier.rawValue)
                }
            }
        }
    }

    // MARK: - Gestures

    /// Pinch-to-zoom gesture
    private var pinchGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                scene?.handlePinch(scale: value)
            }
    }

    // MARK: - UI Components

    /// Right-side floating navigation panel
    private var navigationPanel: some View {
        GameTopBarView(
            title: "City of Learning",
            viewModel: viewModel,
            onNavigate: { destination in
                onNavigate?(destination)
            },
            onBackToMenu: onBackToMenu,
            onboardingState: onboardingState
        )
    }

    private var bottomHint: some View {
        #if os(iOS)
        let hintText = "Tap a building to begin  •  Pinch to zoom  •  Drag to explore"
        #else
        let hintText = "Click a building to begin  •  Scroll to pan  •  Pinch or ⌥+scroll to zoom"
        #endif

        return Text(hintText)
            .font(.custom("Mulish-Light", size: 16))
            .foregroundColor(RenaissanceColors.sepiaInk.opacity(0.8))
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(RenaissanceColors.parchment.opacity(0.9))
            )
    }

    // MARK: - Environment Button

    private func environmentButton(icon: String, title: String, subtitle: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.custom("Mulish-Light", size: 20, relativeTo: .title3))
                    .foregroundStyle(color)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(color.opacity(0.12)))

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.custom("EBGaramond-SemiBold", size: 18))
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                    Text(subtitle)
                        .font(.custom("Mulish-Light", size: 13))
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(RenaissanceColors.sepiaInk)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(RenaissanceColors.parchment)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Material Formulas

    /// Get the appropriate formula for each building type
    private func formulaForBuilding(_ buildingName: String) -> MaterialFormula {
        switch buildingName.lowercased() {
        case "aqueduct", "roman baths", "pantheon":
            return .limeMortar  // CaO + H₂O → Ca(OH)₂
        case "colosseum", "roman roads", "harbor", "siege workshop", "insula":
            return .concrete    // Roman concrete
        case "duomo", "glassworks", "arsenal":
            return .glass       // SiO₂ + Na₂O → Glass
        case "botanical garden", "anatomy theater":
            return .limeMortar
        case "leonardo's workshop", "flying machine", "vatican observatory", "printing press":
            return .glass
        default:
            return .limeMortar  // Default fallback
        }
    }
}

// MARK: - Preview

#Preview {
    CityMapView(viewModel: CityViewModel(), workshopState: WorkshopState(), returnToLessonPlotId: .constant(nil))
}
