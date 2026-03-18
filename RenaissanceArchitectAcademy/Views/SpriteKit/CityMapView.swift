import SwiftUI
import SpriteKit
import Subsonic

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

    /// Controls the knowledge cards overlay (replaces lesson for buildings with cards)
    @State private var showKnowledgeCards = false
    /// Stored card so the overlay doesn't vanish when ViewModel re-renders after card completion
    @State private var activeKnowledgeCard: KnowledgeCard? = nil

    /// Controls the environment picker (Card 2: Explore Environments)
    @State private var showEnvironmentPicker = false

    /// Controls the building checklist view (Card 3: Ready to Build)
    @State private var showBuildingChecklist = false

    /// Controls the construction sequence puzzle (shown after checklist)
    @State private var showConstructionSequence = false

    /// Controls the "build this building?" bird prompt (shown when player walks to building)
    @State private var showBuildingPrompt = false

    /// Building's screen position (normalized 0–1) for positioning the dialog bubble
    @State private var buildingScreenPos: CGPoint = CGPoint(x: 0.5, y: 0.5)

    /// Controls the Workshop sheet (opened from post-quiz prompt)
    @State private var showWorkshopSheet = false

    /// Controls the locked building message overlay
    @State private var showLockedMessage = false
    @State private var lockedMessage = ""

    /// Bird guidance state
    @State private var showGuidance = false
    @State private var guidanceMessage: String = ""
    @State private var guidanceDestination: SidebarDestination? = nil

    /// Sketch Study overlay state (activity between knowledge cards)
    @State private var showSketchStudy = false
    @State private var activeSketch: MuseumSketch? = nil

    /// Reference to the SpriteKit scene — stored in a class box so it survives body
    /// re-evaluation without triggering re-renders (unlike @State which causes infinite loops)
    @State private var sceneHolder = SceneHolder<CityScene>()


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
                GameSpriteView(scene: makeScene(), options: [.allowsTransparency])
                    .ignoresSafeArea()

                // Nav (left) + Buildings (right) with margins
                VStack(spacing: 0) {
                    navigationPanel
                        .frame(maxWidth: .infinity)
                    Spacer()
                    bottomHint
                }
                .frame(maxWidth: .infinity)
                .padding(Spacing.md)

            // Bird prompt — positioned above the building on the map
            if showBuildingPrompt, let plot = selectedPlot {
                GeometryReader { geo in
                    let bx = buildingScreenPos.x * geo.size.width
                    let by = buildingScreenPos.y * geo.size.height

                    VStack(spacing: 0) {
                        HStack(alignment: .top, spacing: 10) {
                            // Bird on the left
                            BirdCharacter(isSitting: true)
                                .frame(width: 55, height: 55)
                                .offset(x: -4, y: -8)

                            VStack(alignment: .leading, spacing: 7) {
                                Text(plot.building.name)
                                    .font(.custom("Cinzel-Bold", size: 17))
                                    .foregroundStyle(RenaissanceColors.sepiaInk)

                                Text("Work on this building?")
                                    .font(RenaissanceFont.dialogSubtitle)
                                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))

                                HStack(spacing: 12) {
                                    Button {
                                        withAnimation {
                                            showBuildingPrompt = false
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                            handleBuildingAction(for: plot)
                                        }
                                    } label: {
                                        Text("Yes, let's build!")
                                            .font(.custom("EBGaramond-SemiBold", size: 14))
                                            .foregroundStyle(.white)
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 7)
                                            .background(
                                                Capsule()
                                                    .fill(RenaissanceColors.warmBrown)
                                            )
                                    }
                                    .buttonStyle(.plain)

                                    Button {
                                        withAnimation {
                                            showBuildingPrompt = false
                                            selectedPlot = nil
                                        }
                                        sceneHolder.scene?.resetMascot()
                                    } label: {
                                        Text("Not this one")
                                            .font(RenaissanceFont.caption)
                                            .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.5))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(RenaissanceColors.parchment)
                                .shadow(color: .black.opacity(0.2), radius: 6, y: 3)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(RenaissanceColors.ochre.opacity(0.3), lineWidth: 1)
                        )

                        // Triangle pointing down toward the building
                        Triangle()
                            .fill(RenaissanceColors.parchment)
                            .frame(width: 18, height: 11)
                            .rotationEffect(.degrees(180))
                            .offset(y: -1)
                    }
                    .frame(width: 286)
                    .position(x: bx, y: by - 170)
                }
                .allowsHitTesting(true)
                .transition(.scale(scale: 0.8).combined(with: .opacity))
            }

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
                        sceneHolder.scene?.resetMascot()
                        onNavigate?(.notebook(buildingId))
                    },
                    onChoice: { choice in
                        withAnimation {
                            showMascotDialogue = false
                        }
                        challengeEntryPath = choice
                        switch choice {
                        case .readToEarn:
                            // Check if building has an uncompleted city-map knowledge card
                            viewModel.setActiveBuilding(plot.id)
                            let nextCityCard = viewModel.nextUncompletedCard(for: plot.id, in: .cityMap)
                            if let card = nextCityCard {
                                // Store the card so overlay survives ViewModel re-renders
                                activeKnowledgeCard = card
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    SubsonicController.shared.play(sound: "cards_appear.mp3")
                                    withAnimation(.spring(response: 0.3)) {
                                        showKnowledgeCards = true
                                    }
                                }
                            } else if !KnowledgeCardContent.cards(for: plot.building.name).isEmpty {
                                // All city cards done — bird suggests next environment
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    withAnimation(.spring(response: 0.3)) {
                                        showEnvironmentPicker = true
                                    }
                                }
                            } else {
                                // Fallback to old paged lesson (buildings without cards)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    SubsonicController.shared.play(sound: "cards_appear.mp3")
                                    withAnimation(.spring(response: 0.3)) {
                                        showBuildingLesson = true
                                    }
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
                        sceneHolder.scene?.resetMascot()
                        // Show bird guidance after dismissing mascot dialogue
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            showCityGuidance()
                        }
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
                        sceneHolder.scene?.resetMascot()
                        onNavigate?(destination)
                    },
                    onDismiss: {
                        withAnimation {
                            showBuildingLesson = false
                            selectedPlot = nil
                        }
                        sceneHolder.scene?.resetMascot()
                    }
                )
                .transition(.opacity)
            }

            // Knowledge Card (1 at a time — uses stored card so it survives re-renders)
            if showKnowledgeCards, let plot = selectedPlot, let card = activeKnowledgeCard {
                KnowledgeCardsOverlay(
                    cards: [card],
                    buildingId: plot.id,
                    viewModel: viewModel,
                    notebookState: notebookState,
                    onDismiss: {
                        let buildingName = plot.building.name
                        let progress = viewModel.buildingProgressMap[plot.id] ?? BuildingProgress()
                        withAnimation {
                            showKnowledgeCards = false
                            activeKnowledgeCard = nil
                        }

                        // INTERLEAVE: After each card, show a sketch study FIRST, then next card
                        let sketches = MuseumSketchContent.sketches(for: buildingName)
                        let nextSketch = sketches.first { !progress.completedSketchStudyIDs.contains($0.id) }
                        if let sketch = nextSketch {
                            // Show sketch study between cards
                            activeSketch = sketch
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                withAnimation(.spring(response: 0.4)) {
                                    showSketchStudy = true
                                }
                            }
                        } else if let nextCard = viewModel.nextUncompletedCard(for: plot.id, in: .cityMap) {
                            // No sketch available — show next card (stay zoomed in)
                            activeKnowledgeCard = nextCard
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                SubsonicController.shared.play(sound: "cards_appear.mp3")
                                withAnimation(.spring(response: 0.3)) {
                                    showKnowledgeCards = true
                                }
                            }
                        } else {
                            // All cards + sketches done — zoom out and show guidance
                            selectedPlot = nil
                            sceneHolder.scene?.resetMascot()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                showCityGuidance()
                            }
                        }
                    },
                    onAllComplete: {
                        // Single card done
                    },
                    onNavigate: { destination in
                        withAnimation {
                            showKnowledgeCards = false
                            activeKnowledgeCard = nil
                            selectedPlot = nil
                        }
                        sceneHolder.scene?.resetMascot()
                        onNavigate?(destination)
                    },
                    playerName: onboardingState?.apprenticeName ?? "Apprentice",
                    workshopState: workshopState
                )
                .transition(.opacity)
            }

            // Sketch Study overlay (activity BETWEEN knowledge cards)
            if showSketchStudy, let sketch = activeSketch, let plot = selectedPlot {
                SketchStudyOverlay(
                    sketch: sketch,
                    onDismiss: {
                        withAnimation {
                            showSketchStudy = false
                            activeSketch = nil
                        }
                        // After sketch study dismissed — continue to next card (stay zoomed in)
                        continueCardFlow(for: plot)
                    },
                    onComplete: { florins in
                        // Mark sketch study as completed
                        if let bid = viewModel.activeBuildingId {
                            viewModel.buildingProgressMap[bid, default: BuildingProgress()]
                                .completedSketchStudyIDs.insert(sketch.id)
                        }
                        viewModel.earnFlorins(florins)
                        withAnimation {
                            showSketchStudy = false
                            activeSketch = nil
                        }
                        // After sketch study complete — continue to next card (stay zoomed in)
                        continueCardFlow(for: plot)
                    }
                )
                .transition(.opacity)
                .zIndex(45)
            }

            // Bird guidance — tells player where to go next
            if showGuidance {
                VStack {
                    Spacer()
                    HStack(alignment: .top, spacing: 10) {
                        BirdCharacter(isSitting: true)
                            .frame(width: 44, height: 44)
                        VStack(alignment: .leading, spacing: 6) {
                            Text(guidanceMessage)
                                .font(.custom("Cinzel-Bold", size: 14))
                                .foregroundStyle(RenaissanceColors.sepiaInk)
                                .fixedSize(horizontal: false, vertical: true)
                            if let bid = viewModel.activeBuildingId {
                                let progress = viewModel.cardProgress(for: bid)
                                Text("\(progress.completed)/\(progress.total) cards collected")
                                    .font(RenaissanceFont.caption)
                                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.5))
                            }
                            if let dest = guidanceDestination, onNavigate != nil {
                                Button {
                                    withAnimation(.easeOut(duration: 0.2)) { showGuidance = false }
                                    onNavigate?(dest)
                                } label: {
                                    HStack(spacing: 5) {
                                        Image(systemName: dest == .forest ? "tree.fill" : dest == .workshop ? "hammer.fill" : "building.columns.fill")
                                            .font(.system(size: 12))
                                        Text("Go!")
                                            .font(.custom("EBGaramond-SemiBold", size: 14))
                                    }
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 6)
                                    .background(Capsule().fill(RenaissanceColors.renaissanceBlue))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        Spacer()
                        Button {
                            withAnimation(.easeOut(duration: 0.3)) { showGuidance = false }
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.4))
                                .padding(6)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(Spacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: CornerRadius.lg)
                            .fill(RenaissanceColors.parchment.opacity(0.95))
                    )
                    .borderWorkshop()
                    .padding(.horizontal, Spacing.lg)
                    .padding(.bottom, Spacing.xl)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(50)
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
                            sceneHolder.scene?.resetMascot()
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
                                sceneHolder.scene?.resetMascot()
                                onNavigate?(.workshop)
                            }

                            environmentButton(icon: "tree.fill", title: "Forest", subtitle: "Gather timber & explore", color: RenaissanceColors.sageGreen) {
                                withAnimation { showEnvironmentPicker = false; selectedPlot = nil }
                                sceneHolder.scene?.resetMascot()
                                onNavigate?(.forest)
                            }

                            Button {
                                withAnimation {
                                    showEnvironmentPicker = false
                                    selectedPlot = nil
                                }
                                sceneHolder.scene?.resetMascot()
                            } label: {
                                Text("Stay on Map")
                                    .font(.custom("EBGaramond-Regular", size: 16))
                                    .foregroundStyle(RenaissanceColors.sepiaInk)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(24)
                        .background(DialogueBubble())
                        .padding(.horizontal, Spacing.xxxl)

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
                        // If this building has a construction sequence, show it first
                        if ConstructionSequenceContent.sequence(for: plot.building.name) != nil {
                            withAnimation(.spring(response: 0.3)) {
                                showBuildingChecklist = false
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                withAnimation(.spring(response: 0.3)) {
                                    showConstructionSequence = true
                                }
                            }
                        } else {
                            // No sequence — complete immediately
                            viewModel.completeChallenge(for: plot.id)
                            viewModel.earnFlorins(GameRewards.buildCompleteFlorins)
                            if let buildingId = buildingIdToPlotId.first(where: { $0.value == plot.id })?.key {
                                sceneHolder.scene?.updateBuildingState(buildingId, state: .complete)
                            }
                            withAnimation {
                                showBuildingChecklist = false
                                selectedPlot = nil
                            }
                            sceneHolder.scene?.resetMascot()
                        }
                    },
                    onDismiss: {
                        withAnimation {
                            showBuildingChecklist = false
                            selectedPlot = nil
                        }
                        sceneHolder.scene?.resetMascot()
                    }
                )
                .transition(.opacity)
            }

            // Construction Sequence Puzzle (shown after checklist)
            if showConstructionSequence, let plot = selectedPlot,
               let sequence = ConstructionSequenceContent.sequence(for: plot.building.name) {
                ConstructionSequenceView(
                    sequence: sequence,
                    onComplete: {
                        // Puzzle complete — award florins and finish the building
                        viewModel.buildingProgressMap[plot.id, default: BuildingProgress()].constructionSequenceCompleted = true
                        viewModel.completeChallenge(for: plot.id)
                        viewModel.earnFlorins(GameRewards.buildCompleteFlorins + GameRewards.constructionSequenceFlorins)
                        if let buildingId = buildingIdToPlotId.first(where: { $0.value == plot.id })?.key {
                            sceneHolder.scene?.updateBuildingState(buildingId, state: .complete)
                        }
                        withAnimation {
                            showConstructionSequence = false
                            selectedPlot = nil
                        }
                        sceneHolder.scene?.resetMascot()
                    },
                    onDismiss: {
                        withAnimation {
                            showConstructionSequence = false
                            selectedPlot = nil
                        }
                        sceneHolder.scene?.resetMascot()
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
                            sceneHolder.scene?.resetMascot()
                        }

                    VStack(spacing: 20) {
                        Spacer()

                        BirdCharacter(isSitting: true)
                            .frame(width: 160, height: 160)

                        VStack(spacing: 16) {
                            Image(systemName: "lock.fill")
                                .font(.custom("EBGaramond-Regular", size: 32, relativeTo: .title3))
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
                                sceneHolder.scene?.resetMascot()
                            }
                        }
                        .padding(28)
                        .background(DialogueBubble())
                        .padding(.horizontal, Spacing.xxxl)

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
                        sceneHolder.scene?.resetMascot()
                        showChallenge = true
                    },
                    onDismiss: {
                        withAnimation {
                            showMaterialPuzzle = false
                            selectedPlot = nil
                        }
                        // Reset mascot position
                        sceneHolder.scene?.resetMascot()
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
                            sceneHolder.scene?.resetMascot()
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
                                    sceneHolder.scene?.resetMascot()
                                    showWorkshopSheet = true
                                }

                                RenaissanceSecondaryButton(title: "Stay on Map") {
                                    withAnimation {
                                        showWorkshopPrompt = false
                                        selectedPlot = nil
                                    }
                                    sceneHolder.scene?.resetMascot()
                                }
                            }
                        }
                        .padding(28)
                        .background(DialogueBubble())
                        .padding(.horizontal, Spacing.xxxl)

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
            if let currentScene = sceneHolder.scene {
                syncCompletionStates(in: currentScene)
            }
            // Auto-open lesson if returning from workshop/forest
            if let plotId = returnToLessonPlotId,
               let plot = viewModel.buildingPlots.first(where: { $0.id == plotId }) {
                selectedPlot = plot
                showBuildingLesson = true
                returnToLessonPlotId = nil
            }
            // Show bird guidance after short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                showCityGuidance()
            }
        }
        .onDisappear {
            // Release scene to free SpriteKit texture memory when navigating away
            sceneHolder.scene = nil
        }
        .onChange(of: showKnowledgeCards) { _, _ in
            // Knowledge cards dismissed — player can freely explore
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
                                sceneHolder.scene?.updateBuildingState(buildingId, state: .complete)
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
                            sceneHolder.scene?.updateBuildingState(buildingId, state: .sketched)
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
        if let existingScene = sceneHolder.scene {
            // Sync completion states in case they changed
            syncCompletionStates(in: existingScene)
            return existingScene
        }

        // Create new scene
        let newScene = CityScene()
        newScene.size = CGSize(width: 3500, height: 2500)
        newScene.scaleMode = .resizeFill

        // Set player gender before scene setup
        if let gender = onboardingState?.apprenticeGender {
            newScene.apprenticeIsBoy = (gender == .boy)
        }

        // When player walks to building, show "build this?" prompt (or locked message)
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

            SubsonicController.shared.play(sound: "building_tap.mp3")
            selectedPlot = plot

            // If this is the active building and player already started cards, skip the prompt
            // and go straight to the next card/action
            let progress = viewModel.buildingProgressMap[plotId] ?? BuildingProgress()
            if viewModel.activeBuildingId == plotId && !progress.completedCardIDs.isEmpty {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    handleBuildingAction(for: plot)
                }
            } else {
                // First time or different building — show "Work on this building?" prompt
                withAnimation(.spring(response: 0.3)) {
                    showBuildingPrompt = true
                }
            }
        }

        // Receive building screen position for dialog placement
        newScene.onBuildingScreenPosition = { [self] normalizedPos in
            buildingScreenPos = normalizedPos
        }

        // Dismiss all dialogs when player starts walking to a new building
        newScene.onPlayerStartedWalking = { [self] in
            withAnimation {
                showBuildingPrompt = false
                showLockedMessage = false
                showMascotDialogue = false
                showGuidance = false
                selectedPlot = nil
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

        sceneHolder.scene = newScene

        // Sync initial completion states from ViewModel
        // This runs after scene is set up, so we delay slightly
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.syncCompletionStates(in: newScene)
        }

        return newScene
    }

    // MARK: - Phase-Based Building Action

    /// Skip the 3-card menu — go directly to the right action based on current phase
    /// Continue the interleaved Card → Sketch → Card flow after a sketch study
    private func continueCardFlow(for plot: BuildingPlot) {
        if let nextCard = viewModel.nextUncompletedCard(for: plot.id, in: .cityMap) {
            // Show next card (stay zoomed in)
            activeKnowledgeCard = nextCard
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                SubsonicController.shared.play(sound: "cards_appear.mp3")
                withAnimation(.spring(response: 0.3)) {
                    showKnowledgeCards = true
                }
            }
        } else {
            // All cards + sketches done — zoom out and show guidance
            selectedPlot = nil
            sceneHolder.scene?.resetMascot()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showCityGuidance()
            }
        }
    }

    private func handleBuildingAction(for plot: BuildingPlot) {
        viewModel.setActiveBuilding(plot.id)
        let buildingName = plot.building.name
        let progress = viewModel.buildingProgressMap[plot.id] ?? BuildingProgress()

        // CHECK IF READY TO BUILD FIRST — skip phase routing if all requirements met
        if viewModel.canStartBuilding(for: plot.id, workshopState: workshopState) {
            selectedPlot = plot
            withAnimation(.spring(response: 0.3)) {
                showBuildingChecklist = true
            }
            return
        }

        let phase = progress.currentPhase(for: buildingName, workshopState: workshopState)

        switch phase {
        case .learn:
            // Open knowledge card directly (or lesson for buildings without cards)
            showGuidance = false  // Dismiss any stale guidance
            let nextCityCard = viewModel.nextUncompletedCard(for: plot.id, in: .cityMap)
            if let card = nextCityCard {
                activeKnowledgeCard = card
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    SubsonicController.shared.play(sound: "cards_appear.mp3")
                    withAnimation(.spring(response: 0.3)) {
                        showKnowledgeCards = true
                    }
                }
            } else {
                // Check sketch studies
                let sketches = MuseumSketchContent.sketches(for: buildingName)
                if let sketch = sketches.first(where: { !progress.completedSketchStudyIDs.contains($0.id) }) {
                    activeSketch = sketch
                    withAnimation(.spring(response: 0.3)) {
                        showSketchStudy = true
                    }
                } else {
                    // City cards + sketch studies done — check architectural sketch next
                    let needsSketch = SketchingContent.sketchingChallenge(for: buildingName) != nil && !progress.sketchCompleted
                    if needsSketch {
                        guidanceMessage = "Now sketch the \(buildingName)! Use what you learned to draw the floor plan (Pianta)."
                        guidanceDestination = nil
                        withAnimation(.spring(response: 0.4)) { showGuidance = true }
                        // Show sketching challenge
                        selectedPlot = plot
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            showGuidance = false
                            withAnimation(.spring(response: 0.3)) {
                                showSketching = true
                            }
                        }
                    } else if !KnowledgeCardContent.cards(for: buildingName).isEmpty {
                        // All city cards + sketch done, nudge to workshop
                        guidanceMessage = "Well studied! Time to collect materials. Head to the Workshop!"
                        guidanceDestination = .workshop
                        withAnimation(.spring(response: 0.4)) { showGuidance = true }
                    } else if LessonContent.lesson(for: buildingName) != nil {
                        SubsonicController.shared.play(sound: "cards_appear.mp3")
                        withAnimation(.spring(response: 0.3)) {
                            showBuildingLesson = true
                        }
                    }
                }
            }

        case .collect:
            onNavigate?(.workshop)

        case .explore:
            // If player already has timber, go to workshop instead of forest
            let timberHave = workshopState.rawMaterials[.timber] ?? 0
            let hasBeams = (workshopState.craftedMaterials[.timberBeams] ?? 0) >= 1
            if hasBeams || timberHave >= 3 {
                onNavigate?(.workshop)
            } else {
                onNavigate?(.forest)
            }

        case .craft:
            onNavigate?(.workshop)  // Go through workshop to crafting room

        case .build:
            // Check if ACTUALLY ready — cards may be done but materials might not be
            if viewModel.canStartBuilding(for: plot.id, workshopState: workshopState) {
                selectedPlot = plot
                withAnimation(.spring(response: 0.3)) {
                    showBuildingChecklist = true
                }
            } else {
                // Missing materials or sketch — guide to workshop
                let materialsOk = plot.building.requiredMaterials.allSatisfy { item, needed in
                    (workshopState.craftedMaterials[item] ?? 0) >= needed
                }
                if !materialsOk {
                    // List exactly what's missing
                    let missing = plot.building.requiredMaterials.filter { item, needed in
                        (workshopState.craftedMaterials[item] ?? 0) < needed
                    }.map { $0.key.rawValue }
                    let missingList = missing.joined(separator: ", ")
                    guidanceMessage = "You still need to craft: \(missingList). Head to the Workshop to collect raw materials and craft them!"
                    guidanceDestination = .workshop
                    withAnimation(.spring(response: 0.4)) { showGuidance = true }
                } else {
                    selectedPlot = plot
                    withAnimation(.spring(response: 0.3)) {
                        showBuildingChecklist = true
                    }
                }
            }
        }
    }

    // MARK: - Bird Guidance

    private func showCityGuidance() {
        // Don't show if other overlays are active
        guard !showKnowledgeCards && !showMascotDialogue && !showBuildingLesson
                && !showBuildingChecklist && !showConstructionSequence
                && !showEnvironmentPicker && !showSketchStudy else { return }

        // No active building yet — brand new player
        guard let bid = viewModel.activeBuildingId else {
            guidanceMessage = "Welcome, Apprentice! Tap a building on the map to begin your journey."
            guidanceDestination = nil
            withAnimation(.spring(response: 0.4)) { showGuidance = true }
            return
        }

        let buildingName = viewModel.buildingPlots.first(where: { $0.id == bid })?.building.name ?? ""
        let progress = viewModel.buildingProgressMap[bid] ?? BuildingProgress()

        // Ready to build? Skip phase guidance
        if viewModel.canStartBuilding(for: bid, workshopState: workshopState) {
            guidanceMessage = "All ready! Tap the \(buildingName) to begin construction!"
            guidanceDestination = nil
            withAnimation(.spring(response: 0.4)) { showGuidance = true }
            return
        }

        let phase = progress.currentPhase(for: buildingName, workshopState: workshopState)

        switch phase {

        // PHASE 1: LEARN — stay on city map, do cards + sketch studies
        case .learn:
            let cityCards = KnowledgeCardContent.cards(for: buildingName, in: .cityMap)
            let nextCard = cityCards.first { !progress.completedCardIDs.contains($0.id) }
            let sketches = MuseumSketchContent.sketches(for: buildingName)
            let nextSketch = sketches.first { !progress.completedSketchStudyIDs.contains($0.id) }
            let cityDone = progress.cardsCompleted(for: buildingName, in: .cityMap)

            if nextCard != nil {
                if cityDone.done == 0 {
                    guidanceMessage = "Tap the \(buildingName) to discover your first knowledge card!"
                } else {
                    guidanceMessage = "Keep going! Tap the \(buildingName) for card \(cityDone.done + 1) of \(cityDone.total)."
                }
                guidanceDestination = nil
            } else if nextSketch != nil {
                guidanceMessage = "Tap the \(buildingName) — study a master architect's sketch!"
                guidanceDestination = nil
            } else {
                // Cards + sketch studies done — check architectural sketch
                let needsSketch = SketchingContent.sketchingChallenge(for: buildingName) != nil && !progress.sketchCompleted
                if needsSketch {
                    guidanceMessage = "Time to sketch the \(buildingName)! Tap it to draw the floor plan using what you learned."
                    guidanceDestination = nil
                } else {
                    guidanceMessage = "Well studied! Time to collect materials. Head to the Workshop!"
                    guidanceDestination = .workshop
                }
            }

        // PHASE 2: COLLECT — go to workshop
        case .collect:
            guidanceMessage = "Head to the Workshop — collect materials and discover more about the \(buildingName)!"
            guidanceDestination = .workshop

        // PHASE 3: EXPLORE — go to forest (unless player already has timber)
        case .explore:
            let timberCount = workshopState.rawMaterials[.timber] ?? 0
            let hasTimberBeams = (workshopState.craftedMaterials[.timberBeams] ?? 0) >= 1
            if hasTimberBeams || timberCount >= 3 {
                guidanceMessage = "Visit the Crafting Room — craft Timber Beams and more for the \(buildingName)!"
                guidanceDestination = .workshop
            } else {
                guidanceMessage = "Time for the Forest! Collect timber for the \(buildingName). (\(timberCount)/3 timber)"
                guidanceDestination = .forest
            }

        // PHASE 4: CRAFT — go to crafting room (through workshop)
        case .craft:
            guidanceMessage = "Visit the Crafting Room — transform your materials for the \(buildingName)!"
            guidanceDestination = .workshop

        // PHASE 5: BUILD — ready to construct
        case .build:
            if viewModel.canStartBuilding(for: bid, workshopState: workshopState) {
                guidanceMessage = "All ready! Tap the \(buildingName) to begin construction!"
                guidanceDestination = nil
            } else {
                // Cards done but missing materials or sketch — guide to what's needed
                let materialsOk = viewModel.buildingPlots.first(where: { $0.id == bid })?.building.requiredMaterials.allSatisfy { item, needed in
                    (workshopState.craftedMaterials[item] ?? 0) >= needed
                } ?? true
                let sketchOk = SketchingContent.sketchingChallenge(for: buildingName) == nil || progress.sketchCompleted
                if !materialsOk {
                    let missing = viewModel.buildingPlots.first(where: { $0.id == bid })?.building.requiredMaterials.filter { item, needed in
                        (workshopState.craftedMaterials[item] ?? 0) < needed
                    }.map { $0.key.rawValue } ?? []
                    let missingList = missing.joined(separator: ", ")
                    guidanceMessage = "You need to craft: \(missingList). Head to the Workshop!"
                    guidanceDestination = .workshop
                } else if !sketchOk {
                    guidanceMessage = "Tap the \(buildingName) to draw the floor plan sketch!"
                    guidanceDestination = nil
                } else {
                    guidanceMessage = "Almost there! Tap the \(buildingName) to check requirements."
                    guidanceDestination = nil
                }
            }
        }

        withAnimation(.spring(response: 0.4)) {
            showGuidance = true
        }
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
            onboardingState: onboardingState,
            currentDestination: .cityMap
        )
    }

    private var bottomHint: some View {
        #if os(iOS)
        let hintText = "Tap a building to begin  •  Pinch to zoom  •  Drag to explore"
        #else
        let hintText = "Click a building to begin  •  Scroll to pan  •  Pinch or Option+scroll to zoom"
        #endif

        return Text(hintText)
            .font(.custom("EBGaramond-Regular", size: 16))
            .foregroundColor(RenaissanceColors.sepiaInk.opacity(0.8))
            .padding(.horizontal, Spacing.xl)
            .padding(.vertical, Spacing.sm)
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
                    .font(.custom("EBGaramond-Regular", size: 20, relativeTo: .title3))
                    .foregroundStyle(color)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(color.opacity(0.12)))

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(RenaissanceFont.button)
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                    Text(subtitle)
                        .font(RenaissanceFont.caption)
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(RenaissanceColors.sepiaInk)
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.md)
                    .fill(RenaissanceColors.parchment)
            )
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.md)
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
