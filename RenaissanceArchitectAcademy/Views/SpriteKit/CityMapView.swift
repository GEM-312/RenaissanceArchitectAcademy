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

    /// Navigate to other screens via top bar
    var onNavigate: ((SidebarDestination) -> Void)? = nil

    /// Return to main menu (Home button in panel)
    var onBackToMenu: (() -> Void)? = nil

    /// Onboarding state for avatar display
    var onboardingState: OnboardingState? = nil

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
    @State private var challengeEntryPath: BuildingStartChoice?

    /// Controls the "Go to Workshop" prompt after quiz completion
    @State private var showWorkshopPrompt = false

    /// Controls the Workshop sheet (opened from post-quiz prompt)
    @State private var showWorkshopSheet = false

    /// Reference to the SpriteKit scene (so we can call methods on it)
    @State private var scene: CityScene?

    /// Mascot position in screen coordinates (0-1 normalized)
    @State private var mascotPosition: CGPoint = CGPoint(x: 0.5, y: 0.5)

    /// Whether mascot is currently walking
    @State private var mascotIsWalking = false

    /// Whether mascot is visible on the map
    @State private var mascotVisible = true

    /// Mascot facing direction (true = right)
    @State private var mascotFacingRight = true

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

                // SwiftUI Mascot overlay (same look everywhere!)
                if mascotVisible && !showMascotDialogue && !showMaterialPuzzle {
                    mascotOverlay(in: geometry.size)
                }

                // Nav (left) + Buildings (right) with margins
                VStack(spacing: 0) {
                    navigationPanel
                        .frame(maxWidth: .infinity)
                    Spacer()
                    bottomHint
                }
                .frame(maxWidth: .infinity)
                .padding(16)

            // Mascot dialogue (NEW: shown when building is tapped)
            if showMascotDialogue, let plot = selectedPlot {
                MascotDialogueView(
                    buildingName: plot.building.name,
                    onChoice: { choice in
                        withAnimation {
                            showMascotDialogue = false
                        }
                        challengeEntryPath = choice
                        switch choice {
                        case .needMaterials:
                            // Mascot walks off, puzzle appears after short delay
                            scene?.mascotWalkToPuzzle()
                            // Show puzzle after mascot starts walking
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                withAnimation(.spring(response: 0.3)) {
                                    showMaterialPuzzle = true
                                }
                            }
                        case .dontKnow:
                            // Go straight to challenge — after completing, will offer Workshop
                            showChallenge = true
                        case .needToSketch:
                            // Route to sketching challenge if available, otherwise quiz
                            if let plot = selectedPlot,
                               SketchingContent.sketchingChallenge(for: plot.building.name) != nil {
                                showSketching = true
                            } else {
                                showChallenge = true
                            }
                        }
                    },
                    onDismiss: {
                        withAnimation {
                            showMascotDialogue = false
                            selectedPlot = nil
                        }
                        // Reset mascot position
                        scene?.resetMascot()
                    }
                )
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
                    Color.black.opacity(0.5)
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
                                .font(.custom("Cinzel-Bold", size: 22))
                                .foregroundStyle(RenaissanceColors.sepiaInk)

                            Text("Now head to the Workshop to collect raw materials and craft what you need to build.")
                                .font(.custom("EBGaramond-Regular", size: 17))
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
                        if challengeEntryPath == .dontKnow {
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
                    .font(.custom("Cinzel-Bold", size: 24))
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
                    .font(.custom("Cinzel-Bold", size: 24))
                    .foregroundColor(RenaissanceColors.sepiaInk)
            }
        }
        .sheet(isPresented: $showWorkshopSheet) {
            WorkshopView(workshop: workshopState)
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

        // When mascot reaches building, show dialogue
        newScene.onMascotReachedBuilding = { [self] buildingId in
            // Convert SpriteKit ID ("duomo") to ViewModel ID (4)
            guard let plotId = buildingIdToPlotId[buildingId],
                  let plot = viewModel.buildingPlots.first(where: { $0.id == plotId }) else {
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

        // Mascot position updates from SpriteKit
        newScene.onMascotPositionChanged = { [self] position, isWalking in
            // Update SwiftUI mascot position
            self.mascotPosition = position
            self.mascotIsWalking = isWalking

            // Update facing direction based on movement
            if let scene = self.scene {
                self.mascotFacingRight = scene.getMascotFacingRight()
            }
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
                let state: BuildingState = plot.isCompleted ? .complete : (plot.sketchingProgress.isSketchingComplete ? .sketched : .available)
                scene.updateBuildingState(buildingId, state: state)
            }
        }
    }

    // MARK: - Mascot Overlay

    /// SwiftUI mascot that follows position from SpriteKit
    private func mascotOverlay(in size: CGSize) -> some View {
        let screenX = mascotPosition.x * size.width
        let screenY = mascotPosition.y * size.height

        return BirdCharacter()
            .frame(width: 200, height: 200)
            .scaleEffect(x: mascotFacingRight ? 1 : -1, y: 1)
            .offset(y: mascotIsWalking ? -5 : 0)
            .position(x: screenX, y: screenY)
        .animation(.easeInOut(duration: 0.1), value: mascotPosition)
        .animation(.easeInOut(duration: 0.15), value: mascotIsWalking)
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
            .font(.custom("EBGaramond-Italic", size: 16))
            .foregroundColor(RenaissanceColors.sepiaInk.opacity(0.8))
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(RenaissanceColors.parchment.opacity(0.9))
                    .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
            )
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
    CityMapView(viewModel: CityViewModel(), workshopState: WorkshopState())
}
