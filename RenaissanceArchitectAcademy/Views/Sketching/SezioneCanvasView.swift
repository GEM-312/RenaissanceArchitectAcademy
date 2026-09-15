import SwiftUI
#if os(iOS)
import PencilKit
#endif

/// Sezione (Cross-Section) — full-page sketching surface.
///
/// Same approach as `PiantaCanvasView`: iPad → PencilKit canvas with the
/// cross-section blueprint underneath; iPhone/macOS → study-only reader.
/// Claude Haiku vision grades the student's sketch against the reference.
struct SezioneCanvasView: View {
    let phaseData: SezionePhaseData
    let buildingName: String
    var notebookState: NotebookState? = nil
    var buildingId: Int? = nil
    let onComplete: (Set<SketchingPhaseType>) -> Void

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        #if os(iOS)
        if horizontalSizeClass == .regular {
            iPadCanvasBody
        } else {
            sezioneStudyView
        }
        #else
        sezioneStudyView
        #endif
    }

    // MARK: - Study-only fallback (iPhone / macOS)

    private var sezioneStudyView: some View {
        ZStack {
            RenaissanceColors.parchment.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 20) {
                    Text("Sezione: Cross-Section")
                        .font(RenaissanceFont.title)
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                        .padding(.top, 24)

                    Text(buildingName)
                        .font(RenaissanceFont.italic)
                        .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))

                    blueprintImageView
                        .padding(.horizontal, 20)

                    studyCard(title: "In Context", body: phaseData.educationalText)
                        .padding(.horizontal, 20)
                    studyCard(title: "History", body: phaseData.historicalContext)
                        .padding(.horizontal, 20)

                    RenaissanceButton(title: "Mark as Studied") {
                        onComplete([.sezione])
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 24)
                }
            }
        }
    }

    // MARK: - iPad canvas

    #if os(iOS)
    @State private var drawing = PKDrawing()
    @State private var showStudyMode = true
    @State private var isPeeking = false
    @State private var isValidating = false
    @State private var validationResult: SketchValidator.Result?
    @State private var validationTask: Task<Void, Never>?
    @State private var canvasIsActive = true
    @State private var savedToastVisible = false

    private var iPadCanvasBody: some View {
        ZStack {
            RenaissanceColors.parchment.ignoresSafeArea()

            blueprintBackgroundLayer

            PencilCanvasView(drawing: $drawing,
                             isToolPickerVisible: canvasIsActive && !showStudyMode)
                .ignoresSafeArea(edges: .bottom)

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
            SezioneStudyModeView(
                phaseData: phaseData,
                buildingName: buildingName,
                onBeginSketching: { showStudyMode = false },
                onJustStudyToday: {
                    showStudyMode = false
                    saveToNotebook(withDrawing: false, score: nil)
                    onComplete([.sezione])
                }
            )
        }
        .onDisappear {
            validationTask?.cancel()
            canvasIsActive = false
        }
    }

    private var blueprintBackgroundLayer: some View {
        Group {
            if imageExists(phaseData.referencePlanImageName) {
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
                    Text("Cross-section blueprint for \(buildingName) coming soon")
                        .font(RenaissanceFont.bodyItalic)
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
                onComplete([])
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.6))
            }
            .buttonStyle(.plain)

            Text("Sezione: \(buildingName)")
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
                .font(RenaissanceFont.footnoteBold)
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
                Text(isValidating ? "Checking..." : "Check Section")
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
                Text("Comparing your cross-section to the master plan...")
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
            RenaissanceColors.overlayDimming.ignoresSafeArea()
            SketchResultView(
                result: result,
                buildingName: buildingName,
                onRetry: { validationResult = nil },
                onContinue: {
                    validationResult = nil
                    saveToNotebook(withDrawing: true, score: result.score)
                    onComplete([.sezione])
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
                .font(RenaissanceFont.buttonSmall)
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

    private func saveToNotebook(withDrawing: Bool, score: Int?) {
        guard let notebookState, let buildingId else { return }

        let title = "Sezione — \(buildingName)"
        let body: String
        if withDrawing {
            if let score {
                body = "Cross-section sketched and reviewed by Maestro. Score: \(score)/100."
            } else {
                body = "Cross-section sketched \(formattedDate())."
            }
        } else {
            body = "Studied the cross-section blueprint \(formattedDate())."
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
            onComplete([.sezione])
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
                // View dismissed
            } catch {
                guard !Task.isCancelled else { return }
                print("[SezioneCanvasView] validation failed: \(error)")
                onComplete([.sezione])
            }
        }
    }
    #endif

    // MARK: - Shared helpers

    private func imageExists(_ name: String) -> Bool {
        #if os(iOS)
        return UIImage(named: name) != nil
        #else
        return NSImage(named: name) != nil
        #endif
    }

    @ViewBuilder
    private var blueprintImageView: some View {
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
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(color: .black.opacity(0.2), radius: 6, y: 3)
        } else {
            RoundedRectangle(cornerRadius: 10)
                .fill(RenaissanceColors.parchment.opacity(0.6))
                .overlay(
                    VStack(spacing: 12) {
                        Image(systemName: "doc.richtext")
                            .font(.system(size: 48))
                            .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.3))
                        Text("Cross-section blueprint coming soon")
                            .font(RenaissanceFont.italic)
                            .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.5))
                    }
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(RenaissanceColors.sepiaInk.opacity(0.15),
                                style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
                )
                .frame(height: 300)
        }
    }

    private func studyCard(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.custom("Cinzel-Bold", size: 14))
                .foregroundStyle(RenaissanceColors.sepiaInk)
            Text(body)
                .font(RenaissanceFont.footnote)
                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.85))
                .lineSpacing(3)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.5))
                .overlay(RoundedRectangle(cornerRadius: 10)
                    .stroke(RenaissanceColors.sepiaInk.opacity(0.15), lineWidth: 1))
        )
    }
}

// MARK: - Sezione Study Mode (full-screen blueprint reader)

struct SezioneStudyModeView: View {
    let phaseData: SezionePhaseData
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
                Text("Study the Cross-Section")
                    .font(RenaissanceFont.title)
                    .foregroundStyle(RenaissanceColors.sepiaInk)
                Text("\(buildingName) — how the building stands up")
                    .font(RenaissanceFont.italicSmall)
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
                        Text("Cross-section blueprint for \(buildingName) coming soon")
                            .font(RenaissanceFont.italic)
                            .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.5))
                    }
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(RenaissanceColors.sepiaInk.opacity(0.15),
                                style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private var educationalCards: some View {
        HStack(alignment: .top, spacing: 14) {
            studyCard(title: "Structure", body: phaseData.educationalText)
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
                .font(RenaissanceFont.footnote)
                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.85))
                .lineSpacing(3)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.5))
                .overlay(RoundedRectangle(cornerRadius: 10)
                    .stroke(RenaissanceColors.sepiaInk.opacity(0.15), lineWidth: 1))
        )
    }

    private var actionButtons: some View {
        VStack(spacing: 10) {
            Button {
                dismiss()
                onBeginSketching()
            } label: {
                Text("Begin Sketching")
                    .font(RenaissanceFont.button)
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
                    .font(RenaissanceFont.bodySmall)
                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.75))
                    .underline()
            }
            .buttonStyle(.plain)
        }
    }
}
