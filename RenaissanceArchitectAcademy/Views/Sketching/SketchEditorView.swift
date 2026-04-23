import SwiftUI
#if os(iOS)
import PencilKit
#endif

/// View + annotate + delete a saved sketch from the building notebook.
///
/// Shown as a full-screen cover when the student taps a sketch entry in
/// NotebookView. Loads the stored `PKDrawing` (if any), lets the student
/// add strokes on top non-destructively, edit the text annotation, and
/// either save or delete the entry entirely.
struct SketchEditorView: View {
    let entry: NotebookEntry
    var notebookState: NotebookState

    @Environment(\.dismiss) private var dismiss

    #if os(iOS)
    @State private var drawing = PKDrawing()
    #endif
    @State private var annotation: String
    @State private var showDeleteConfirm = false

    init(entry: NotebookEntry, notebookState: NotebookState) {
        self.entry = entry
        self.notebookState = notebookState
        _annotation = State(initialValue: entry.userAnnotation ?? "")
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            RenaissanceColors.parchment.ignoresSafeArea()

            VStack(spacing: 0) {
                header
                annotationField
                canvasSection
                actionBar
            }
        }
        .onAppear {
            loadDrawing()
        }
        .confirmationDialog(
            "Delete this sketch?",
            isPresented: $showDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                notebookState.deleteSketch(entryId: entry.id, buildingId: entry.buildingId)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("The drawing and annotation will be removed from your notebook.")
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.5))
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.title)
                    .font(.custom("Cinzel-Bold", size: 20))
                    .foregroundStyle(RenaissanceColors.sepiaInk)
                Text(entry.body)
                    .font(.custom("EBGaramond-Italic", size: 13))
                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.6))
            }

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 10)
    }

    // MARK: - Annotation Field

    private var annotationField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Notes")
                .font(.custom("Cinzel-Bold", size: 13))
                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))

            TextField("Add a note about this sketch...", text: $annotation, axis: .vertical)
                .font(.custom("EBGaramond-Regular", size: 15))
                .foregroundStyle(RenaissanceColors.sepiaInk)
                .lineLimit(2...4)
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.55))
                        .overlay(RoundedRectangle(cornerRadius: 8)
                            .stroke(RenaissanceColors.sepiaInk.opacity(0.15), lineWidth: 1))
                )
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
    }

    // MARK: - Canvas

    @ViewBuilder
    private var canvasSection: some View {
        #if os(iOS)
        PencilCanvasView(drawing: $drawing)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .overlay(RoundedRectangle(cornerRadius: 10)
                        .stroke(RenaissanceColors.sepiaInk.opacity(0.15), lineWidth: 1))
                    .padding(.horizontal, 20)
            )
            .padding(.horizontal, 20)
        #else
        // macOS has no PencilKit — show the annotation-only editor.
        VStack {
            Spacer()
            Text("Drawing edits are available on iPad.")
                .font(.custom("EBGaramond-Italic", size: 15))
                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.6))
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        #endif
    }

    // MARK: - Actions

    private var actionBar: some View {
        HStack(spacing: 12) {
            Button(role: .destructive) {
                showDeleteConfirm = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "trash")
                    Text("Delete")
                }
                .font(.custom("EBGaramond-SemiBold", size: 15))
                .foregroundStyle(RenaissanceColors.errorRed)
                .padding(.horizontal, 16)
                .padding(.vertical, 11)
                .background(
                    Capsule()
                        .fill(RenaissanceColors.errorRed.opacity(0.1))
                        .overlay(Capsule().stroke(RenaissanceColors.errorRed.opacity(0.35), lineWidth: 1))
                )
            }
            .buttonStyle(.plain)

            Spacer()

            Button {
                saveEdits()
                dismiss()
            } label: {
                Text("Save")
                    .font(.custom("EBGaramond-SemiBold", size: 16))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 11)
                    .background(Capsule().fill(RenaissanceColors.warmBrown))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(
            RenaissanceColors.parchment
                .shadow(color: .black.opacity(0.08), radius: 4, y: -1)
                .ignoresSafeArea(edges: .bottom)
        )
    }

    // MARK: - Persistence

    private func loadDrawing() {
        #if os(iOS)
        if let saved = notebookState.loadDrawing(for: entry.id) {
            drawing = saved
        }
        #endif
    }

    private func saveEdits() {
        notebookState.updateAnnotation(for: entry.id,
                                       buildingId: entry.buildingId,
                                       text: annotation)
        #if os(iOS)
        // Save drawing (may be empty if the original was study-only and
        // the student didn't add anything). That's fine — an empty drawing
        // just persists as zero strokes.
        notebookState.saveDrawing(drawing, for: entry.id)
        #endif
    }
}
