import SwiftUI
import SpriteKit
#if os(iOS)
import PencilKit
#endif

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

    /// The currently selected plot (when user taps a building)
    @State private var selectedPlot: BuildingPlot?

    /// Controls the building detail sheet
    @State private var showBuildingDetail = false

    /// Controls the challenge view
    @State private var showChallenge = false

    /// Controls the mascot dialogue (new game flow)
    @State private var showMascotDialogue = false

    /// Controls the material puzzle game
    @State private var showMaterialPuzzle = false

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

    /// Paint mode: user can draw watercolor washes on the map
    @State private var isPaintMode = false

    #if os(iOS)
    /// The saved watercolor drawing (PencilKit, persisted between sessions)
    @State private var watercolorDrawing = PKDrawing()
    #else
    /// The saved watercolor drawing (stub for macOS — strokes stored in canvas view)
    @State private var watercolorDrawing = MacDrawing()
    #endif

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
                // The SpriteKit scene (the actual game map)
                SpriteView(scene: makeScene(), options: [.allowsTransparency])
                    .ignoresSafeArea()
                    .gesture(pinchGesture)

                // Watercolor paint layer (PencilKit canvas)
                WatercolorCanvasView(
                    drawing: $watercolorDrawing,
                    isActive: $isPaintMode
                )
                .allowsHitTesting(isPaintMode)
                .ignoresSafeArea()

                // SwiftUI Mascot overlay (same look everywhere!)
                if mascotVisible && !showMascotDialogue && !showMaterialPuzzle && !isPaintMode {
                    mascotOverlay(in: geometry.size)
                }

                // SwiftUI overlay for UI elements
                VStack {
                    HStack {
                        topBar
                        Spacer()
                        paintModeButton
                    }
                    Spacer()
                    if isPaintMode {
                        paintModeHint
                    } else {
                        bottomHint
                    }
                }
                .padding()

            // Mascot dialogue (NEW: shown when building is tapped)
            if showMascotDialogue, let plot = selectedPlot {
                MascotDialogueView(
                    buildingName: plot.building.name,
                    onChoice: { choice in
                        withAnimation {
                            showMascotDialogue = false
                        }
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
                            // Show building detail for info
                            showBuildingDetail = true
                        case .needToSketch:
                            // Skip to challenge (future: sketching game)
                            showChallenge = true
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
            // Load saved watercolor painting
            loadWatercolorDrawing()
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
                        // Close the sheet after completion
                        showChallenge = false
                        selectedPlot = nil
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
                let state: BuildingState = plot.isCompleted ? .complete : .available
                scene.updateBuildingState(buildingId, state: state)
            }
        }
    }

    // MARK: - Mascot Overlay

    /// SwiftUI mascot that follows position from SpriteKit
    private func mascotOverlay(in size: CGSize) -> some View {
        let screenX = mascotPosition.x * size.width
        let screenY = mascotPosition.y * size.height

        return HStack(alignment: .bottom, spacing: -20) {
            // Splash character
            SplashCharacter()
                .frame(width: 100, height: 120)
                .scaleEffect(x: mascotFacingRight ? 1 : -1, y: 1)

            // Bird companion
            BirdCharacter()
                .frame(width: 50, height: 50)
                .offset(y: mascotIsWalking ? -5 : 0)
        }
        .scaleEffect(0.7)
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

    private var topBar: some View {
        HStack {
            // Title
            Text("City of Learning")
                .font(.custom("Cinzel-Bold", size: 24))
                .foregroundColor(RenaissanceColors.sepiaInk)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(RenaissanceColors.parchment.opacity(0.95))
                        .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                )

            Spacer()

            // Buildings completed counter
            let completedCount = viewModel.buildingPlots.filter { $0.isCompleted }.count
            let totalCount = viewModel.buildingPlots.count
            HStack(spacing: 8) {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(RenaissanceColors.sageGreen)
                Text("\(completedCount)/\(totalCount)")
                    .font(.custom("EBGaramond-Regular", size: 18))
                    .foregroundColor(RenaissanceColors.sepiaInk)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(RenaissanceColors.parchment.opacity(0.95))
            )
        }
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

    // MARK: - Paint Mode UI

    private var paintModeButton: some View {
        Button {
            withAnimation(.spring(response: 0.3)) {
                isPaintMode.toggle()
            }
            // Save when exiting paint mode
            if !isPaintMode {
                saveWatercolorDrawing()
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: isPaintMode ? "checkmark" : "paintbrush.pointed.fill")
                Text(isPaintMode ? "Done" : "Paint")
                    .font(.custom("EBGaramond-Regular", size: 16))
            }
            .foregroundColor(isPaintMode ? .white : RenaissanceColors.sepiaInk)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(isPaintMode ? RenaissanceColors.renaissanceBlue : RenaissanceColors.parchment.opacity(0.95))
                    .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
            )
        }
    }

    private var paintModeHint: some View {
        HStack(spacing: 12) {
            Text("Draw watercolor washes on the map")
                .font(.custom("EBGaramond-Italic", size: 16))
                .foregroundColor(RenaissanceColors.sepiaInk.opacity(0.8))

            Button {
                #if os(iOS)
                watercolorDrawing = PKDrawing()
                #else
                watercolorDrawing = MacDrawing()
                #endif
                saveWatercolorDrawing()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "trash")
                    Text("Clear")
                        .font(.custom("EBGaramond-Regular", size: 14))
                }
                .foregroundColor(RenaissanceColors.errorRed)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(
            Capsule()
                .fill(RenaissanceColors.parchment.opacity(0.9))
                .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
        )
    }

    // MARK: - Watercolor Drawing Persistence

    private static let drawingKey = "cityMapWatercolorDrawing"

    private func saveWatercolorDrawing() {
        #if os(iOS)
        let data = watercolorDrawing.dataRepresentation()
        UserDefaults.standard.set(data, forKey: Self.drawingKey)
        #endif
        // macOS strokes are ephemeral for now (no PencilKit serialization)
    }

    private func loadWatercolorDrawing() {
        #if os(iOS)
        guard let data = UserDefaults.standard.data(forKey: Self.drawingKey),
              let drawing = try? PKDrawing(data: data) else { return }
        watercolorDrawing = drawing
        #endif
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

// MARK: - WatercolorCanvasView (PencilKit wrapper)

#if os(iOS)
/// Wraps PKCanvasView for iPad — transparent overlay with Apple's watercolor brush
struct WatercolorCanvasView: UIViewRepresentable {
    @Binding var drawing: PKDrawing
    @Binding var isActive: Bool

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> PKCanvasView {
        let canvas = PKCanvasView()
        canvas.drawing = drawing
        canvas.backgroundColor = .clear
        canvas.isOpaque = false
        canvas.drawingPolicy = .anyInput
        canvas.delegate = context.coordinator

        // Default tool: watercolor green, wide brush
        canvas.tool = PKInkingTool(.watercolor, color: .systemGreen, width: 30)

        context.coordinator.canvas = canvas
        return canvas
    }

    func updateUIView(_ canvas: PKCanvasView, context: Context) {
        if canvas.drawing.dataRepresentation() != drawing.dataRepresentation() {
            canvas.drawing = drawing
        }
        canvas.isUserInteractionEnabled = isActive

        let coordinator = context.coordinator
        if isActive {
            coordinator.showToolPicker(for: canvas)
        } else {
            coordinator.hideToolPicker()
        }
    }

    class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: WatercolorCanvasView
        weak var canvas: PKCanvasView?
        private var toolPicker: PKToolPicker?

        init(_ parent: WatercolorCanvasView) { self.parent = parent }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            parent.drawing = canvasView.drawing
        }

        func showToolPicker(for canvas: PKCanvasView) {
            if toolPicker == nil { toolPicker = PKToolPicker() }
            toolPicker?.setVisible(true, forFirstResponder: canvas)
            toolPicker?.addObserver(canvas)
            canvas.becomeFirstResponder()
        }

        func hideToolPicker() {
            guard let canvas = canvas else { return }
            toolPicker?.setVisible(false, forFirstResponder: canvas)
            canvas.resignFirstResponder()
        }
    }
}

#else

/// Lightweight drawing stub for macOS (PencilKit is iOS-only)
struct MacDrawing: Equatable {
    var strokes: [[CGPoint]] = []
}

/// macOS fallback: simple SwiftUI drag-to-paint canvas
struct WatercolorCanvasView: View {
    @Binding var drawing: MacDrawing
    @Binding var isActive: Bool

    @State private var currentStroke: [CGPoint] = []

    var body: some View {
        Canvas { context, _ in
            for stroke in drawing.strokes {
                drawWatercolorStroke(stroke, in: &context)
            }
            if !currentStroke.isEmpty {
                drawWatercolorStroke(currentStroke, in: &context)
            }
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    guard isActive else { return }
                    currentStroke.append(value.location)
                }
                .onEnded { _ in
                    guard isActive, !currentStroke.isEmpty else { return }
                    drawing.strokes.append(currentStroke)
                    currentStroke = []
                }
        )
    }

    private func drawWatercolorStroke(_ points: [CGPoint], in context: inout GraphicsContext) {
        guard points.count >= 2 else { return }

        var path = Path()
        path.move(to: points[0])
        for i in 1..<points.count {
            let mid = CGPoint(
                x: (points[i - 1].x + points[i].x) / 2,
                y: (points[i - 1].y + points[i].y) / 2
            )
            path.addQuadCurve(to: mid, control: points[i - 1])
        }
        path.addLine(to: points.last!)

        // Wide semi-transparent green-yellow strokes to simulate watercolor wash
        context.stroke(path, with: .color(Color(RenaissanceColors.sageGreen).opacity(0.3)), lineWidth: 30)
        context.stroke(path, with: .color(Color(RenaissanceColors.ochre).opacity(0.15)), lineWidth: 20)
    }
}
#endif

// MARK: - Preview

#Preview {
    CityMapView(viewModel: CityViewModel())
}
