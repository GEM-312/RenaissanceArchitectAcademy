import SwiftUI
#if os(iOS)
import PencilKit
#endif

/// Pianta (Floor Plan) — full-page sketching surface.
///
/// iPad → PencilKit canvas with the blueprint always visible at 30%
/// underneath so the student can trace it. Hold Peek → blueprint jumps to
/// 60%. System `PKToolPicker` gives pencil / pen / marker / ruler / eraser.
/// "Check Plan" renders the student's PKDrawing on a white background and
/// sends it to Claude Haiku vision against the reference blueprint.
///
/// iPhone → no drawing (Apple Pencil-less small-screen sketching is bad
/// UX). Instead a scrollable study-only reader; tapping "Mark as Studied"
/// completes the phase with the same florins as the iPad sketch path.
///
/// "Just Study Today" skip button on iPad gives the same credit without
/// drawing — per WWDC26 Apple guidance on cancellable async work, the
/// Claude Task is stored in a @State handle and cancelled on dismiss so
/// dismiss-mid-validation doesn't mutate state post-unmount.
struct PiantaCanvasView: View {
    let phaseData: PiantaPhaseData
    let buildingName: String
    var notebookState: NotebookState? = nil
    var buildingId: Int? = nil
    let onComplete: (Set<SketchingPhaseType>) -> Void

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        // iPad → sketching canvas. iPhone + macOS → study-only reader.
        #if os(iOS)
        if horizontalSizeClass == .regular {
            iPadCanvasBody
        } else {
            BlueprintStudyView(
                phaseData: phaseData,
                buildingName: buildingName,
                notebookState: notebookState,
                buildingId: buildingId,
                onComplete: { onComplete([.pianta]) }
            )
        }
        #else
        BlueprintStudyView(
            phaseData: phaseData,
            buildingName: buildingName,
            notebookState: notebookState,
            buildingId: buildingId,
            onComplete: { onComplete([.pianta]) }
        )
        #endif
    }

    // MARK: - iPad canvas

    #if os(iOS)
    @State private var drawing = PKDrawing()
    @State private var showStudyMode = true
    @State private var isPeeking = false
    @State private var isValidating = false
    @State private var validationResult: SketchValidator.Result?
    @State private var validationTask: Task<Void, Never>?
    /// Flips false on `.onDisappear` so the tool picker dismisses before
    /// the canvas finishes tearing down — prevents the picker from lingering
    /// over the Workshop / City Map while `.fullScreenCover` animates out.
    @State private var canvasIsActive = true
    /// Tiny "✓ Saved to your notebook" toast shown after a save.
    @State private var savedToastVisible = false

    private var iPadCanvasBody: some View {
        ZStack {
            RenaissanceColors.parchment.ignoresSafeArea()

            // Blueprint layer — always visible at 30%, jumps to 60% while Peek is held
            blueprintBackgroundLayer

            // PencilKit canvas — transparent so blueprint shows through.
            // Tool picker is hidden while Study Mode is over the top OR
            // while the view is being dismissed (canvasIsActive goes false
            // on .onDisappear so the picker vanishes before teardown).
            PencilCanvasView(drawing: $drawing,
                             isToolPickerVisible: canvasIsActive && !showStudyMode)
                .ignoresSafeArea(edges: .bottom)

            // Top bar (title + Study + close)
            VStack {
                topBar
                Spacer()
                bottomBar
            }
        }
        .overlay {
            if isValidating { validatingOverlay }
            if let result = validationResult {
                resultOverlay(result)
            }
        }
        .overlay(alignment: .top) {
            if savedToastVisible { savedToast }
        }
        .fullScreenCover(isPresented: $showStudyMode) {
            StudyModeView(
                phaseData: phaseData,
                buildingName: buildingName,
                onBeginSketching: { showStudyMode = false },
                onJustStudyToday: {
                    showStudyMode = false
                    // Save a "studied only" notebook entry (no drawing file)
                    saveToNotebook(withDrawing: false, score: nil)
                    // Same credit as a completed sketch
                    onComplete([.pianta])
                }
            )
        }
        .onDisappear {
            validationTask?.cancel()
            // Hide the tool picker immediately so it doesn't linger on top
            // of the screen we're animating into (Workshop / City / etc.)
            canvasIsActive = false
        }
    }

    private var blueprintBackgroundLayer: some View {
        Group {
            if imageExists(phaseData.referencePlanImageName) {
                // Hidden by default — only visible while the student holds
                // "Peek". The student is meant to *study* the blueprint
                // first and then draw from memory, not trace it constantly.
                Image(phaseData.referencePlanImageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .opacity(isPeeking ? 0.6 : 0)
                    .animation(.easeInOut(duration: 0.2), value: isPeeking)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "doc.richtext")
                        .font(.system(size: 48))
                        .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.2))
                    Text("Blueprint for \(buildingName) coming soon")
                        .font(.custom("EBGaramond-Italic", size: 16))
                        .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.4))
                }
                .allowsHitTesting(false)
            }
        }
    }

    private var topBar: some View {
        HStack(spacing: 12) {
            Button {
                validationTask?.cancel()
                onComplete([])   // dismiss without credit
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.6))
            }
            .buttonStyle(.plain)

            Text("Pianta: \(buildingName)")
                .font(.custom("Cinzel-Bold", size: 20))
                .foregroundStyle(RenaissanceColors.sepiaInk)

            Spacer()

            Button {
                showStudyMode = true
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "book")
                    Text("Study")
                }
                .font(.custom("EBGaramond-SemiBold", size: 14))
                .foregroundStyle(RenaissanceColors.sepiaInk)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(
                    Capsule()
                        .fill(RenaissanceColors.renaissanceBlue.opacity(0.15))
                        .overlay(Capsule().stroke(RenaissanceColors.renaissanceBlue.opacity(0.4), lineWidth: 1))
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }

    private var bottomBar: some View {
        HStack(spacing: 12) {
            PeekButton(isPeeking: $isPeeking)
                .frame(maxWidth: 160)

            Button {
                guard !isValidating else { return }
                runValidation()
            } label: {
                Text(isValidating ? "Checking..." : "Check Plan")
                    .font(.custom("EBGaramond-SemiBold", size: 16))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(RenaissanceColors.warmBrown)
                    )
            }
            .buttonStyle(.plain)
            .disabled(isValidating || drawing.strokes.isEmpty)
            .opacity(drawing.strokes.isEmpty ? 0.5 : 1.0)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }

    private var validatingOverlay: some View {
        ZStack {
            Color.black.opacity(0.35).ignoresSafeArea()
            VStack(spacing: 12) {
                ProgressView().scaleEffect(1.4).tint(.white)
                Text("Comparing your sketch to the master plan...")
                    .font(.custom("EBGaramond-SemiBold", size: 16))
                    .foregroundStyle(.white)
            }
            .padding(32)
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.black.opacity(0.6)))
        }
        .transition(.opacity)
    }

    private func resultOverlay(_ result: SketchValidator.Result) -> some View {
        ZStack {
            Color.black.opacity(0.45).ignoresSafeArea()
            SketchResultView(
                result: result,
                buildingName: buildingName,
                onRetry: { validationResult = nil },
                onContinue: {
                    validationResult = nil
                    // Save the student's actual PKDrawing alongside the score
                    saveToNotebook(withDrawing: true, score: result.score)
                    onComplete([.pianta])
                }
            )
        }
        .transition(.opacity)
    }

    // MARK: - Save to Notebook + Toast

    private var savedToast: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(RenaissanceColors.sageGreen)
            Text("Saved to your notebook")
                .font(.custom("EBGaramond-SemiBold", size: 15))
                .foregroundStyle(RenaissanceColors.sepiaInk)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(RenaissanceColors.parchment)
                .overlay(RoundedRectangle(cornerRadius: 20)
                    .stroke(RenaissanceColors.sageGreen.opacity(0.4), lineWidth: 1))
                .shadow(color: .black.opacity(0.15), radius: 6, y: 2)
        )
        .padding(.top, 16)
        .transition(.move(edge: .top).combined(with: .opacity))
    }

    /// Persist a notebook entry for this sketching session. When
    /// `withDrawing` is true and there are strokes, the PKDrawing file is
    /// saved next to the entry on disk; otherwise only the text entry is
    /// added (e.g. the "Just Study Today" path).
    private func saveToNotebook(withDrawing: Bool, score: Int?) {
        guard let notebookState, let buildingId else { return }

        let title = "Pianta — \(buildingName)"
        let body: String
        if withDrawing {
            if let score {
                body = "Sketched and reviewed by Maestro. Score: \(score)/100."
            } else {
                body = "Sketched \(formattedDate())."
            }
        } else {
            body = "Studied the master blueprint \(formattedDate())."
        }

        let entryId = notebookState.addSketchEntry(
            buildingId: buildingId,
            buildingName: buildingName,
            title: title,
            body: body
        )

        if withDrawing, !drawing.strokes.isEmpty {
            notebookState.saveDrawing(drawing, for: entryId)
        }

        showSavedToast()
    }

    private func showSavedToast() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            savedToastVisible = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            withAnimation(.easeOut(duration: 0.3)) {
                savedToastVisible = false
            }
        }
    }

    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: Date())
    }

    // MARK: - Validation

    private func runValidation() {
        guard !drawing.strokes.isEmpty else { return }
        guard imageExists(phaseData.referencePlanImageName),
              let reference = UIImage(named: phaseData.referencePlanImageName) else {
            // No reference art — grant completion on good faith
            onComplete([.pianta])
            return
        }

        isValidating = true
        let snapshot = drawing.renderedImage(size: CGSize(width: 1024, height: 1024))

        validationTask?.cancel()
        validationTask = Task { @MainActor in
            defer { isValidating = false }
            do {
                let result = try await SketchValidator.shared.validate(
                    studentSketch: snapshot,
                    referencePlan: reference,
                    buildingName: buildingName
                )
                guard !Task.isCancelled else { return }
                withAnimation(.easeInOut(duration: 0.3)) {
                    validationResult = result
                }
            } catch is CancellationError {
                // View dismissed — URLSession request already dropped
            } catch {
                guard !Task.isCancelled else { return }
                print("[PiantaCanvasView] validation failed: \(error)")
                // Graceful fallback — grant completion so the student isn't blocked
                onComplete([.pianta])
            }
        }
    }
    #endif

    // MARK: - Asset check

    private func imageExists(_ name: String) -> Bool {
        #if os(iOS)
        return UIImage(named: name) != nil
        #else
        return NSImage(named: name) != nil
        #endif
    }
}

// MARK: - Peek Button

/// Press-and-hold button that boosts blueprint opacity while held.
struct PeekButton: View {
    @Binding var isPeeking: Bool

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "eye")
                .font(.system(size: 14))
            Text(isPeeking ? "Peeking..." : "Hold to Peek")
                .font(.custom("EBGaramond-SemiBold", size: 15))
        }
        .foregroundStyle(isPeeking ? .white : RenaissanceColors.sepiaInk)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(isPeeking ? RenaissanceColors.renaissanceBlue : RenaissanceColors.parchment)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(RenaissanceColors.sepiaInk.opacity(0.35), lineWidth: 1))
        )
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPeeking {
                        withAnimation(.easeInOut(duration: 0.15)) { isPeeking = true }
                    }
                }
                .onEnded { _ in
                    withAnimation(.easeInOut(duration: 0.15)) { isPeeking = false }
                }
        )
    }
}

// MARK: - Study Mode (full-screen blueprint reader on iPad)

/// Full-screen blueprint viewer. Shown on first appear and reopenable from
/// the canvas header "Study" button. Two actions: Begin Sketching, or
/// "Just Study Today" → same credit as completing a sketch.
struct StudyModeView: View {
    let phaseData: PiantaPhaseData
    let buildingName: String
    let onBeginSketching: () -> Void
    let onJustStudyToday: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            RenaissanceColors.parchment.ignoresSafeArea()

            VStack(spacing: 16) {
                header
                blueprintImage
                    .padding(.horizontal, 20)
                educationalCards
                actionButtons
                    .padding(.horizontal, 40)
                    .padding(.bottom, 20)
            }
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Study the Blueprint")
                    .font(.custom("Cinzel-Bold", size: 26))
                    .foregroundStyle(RenaissanceColors.sepiaInk)
                Text("\(buildingName) — plan, elevation, and section")
                    .font(.custom("EBGaramond-Italic", size: 15))
                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))
            }
            Spacer()
            Button {
                dismiss()
                onBeginSketching()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.5))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
    }

    @ViewBuilder
    private var blueprintImage: some View {
        let name = phaseData.referencePlanImageName
        #if os(iOS)
        let hasImage = UIImage(named: name) != nil
        #else
        let hasImage = NSImage(named: name) != nil
        #endif

        if hasImage {
            Image(name)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 3)
        } else {
            RoundedRectangle(cornerRadius: 10)
                .fill(RenaissanceColors.parchment.opacity(0.6))
                .overlay(
                    VStack(spacing: 12) {
                        Image(systemName: "doc.richtext")
                            .font(.system(size: 60))
                            .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.3))
                        Text("Blueprint for \(buildingName) coming soon")
                            .font(.custom("EBGaramond-Italic", size: 17))
                            .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.5))
                    }
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(RenaissanceColors.sepiaInk.opacity(0.15), style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private var educationalCards: some View {
        HStack(alignment: .top, spacing: 14) {
            studyCard(title: "In Context", body: phaseData.educationalText)
            studyCard(title: "History", body: phaseData.historicalContext)
        }
        .padding(.horizontal, 24)
    }

    private func studyCard(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.custom("Cinzel-Bold", size: 14))
                .foregroundStyle(RenaissanceColors.sepiaInk)
            Text(body)
                .font(.custom("EBGaramond-Regular", size: 14))
                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.85))
                .lineSpacing(3)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.5))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(RenaissanceColors.sepiaInk.opacity(0.15), lineWidth: 1))
        )
    }

    private var actionButtons: some View {
        VStack(spacing: 10) {
            Button {
                dismiss()
                onBeginSketching()
            } label: {
                Text("Begin Sketching")
                    .font(.custom("EBGaramond-SemiBold", size: 18))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(RoundedRectangle(cornerRadius: 10).fill(RenaissanceColors.warmBrown))
            }
            .buttonStyle(.plain)

            Button {
                dismiss()
                onJustStudyToday()
            } label: {
                Text("Just Study Today")
                    .font(.custom("EBGaramond-Regular", size: 15))
                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.75))
                    .underline()
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    PiantaCanvasView(
        phaseData: PiantaPhaseData(
            gridSize: 12,
            hint: nil,
            educationalText: "The Pantheon's dome spans 43.3 meters.",
            historicalContext: "Built by Emperor Hadrian around 126 AD.",
            referencePlanImageName: "PantheonBlueprint"
        ),
        buildingName: "Pantheon",
        onComplete: { _ in }
    )
}
