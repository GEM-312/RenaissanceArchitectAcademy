import SwiftUI

/// Leonardo da Vinci notebook aesthetic — shows all knowledge accumulated for a building.
/// On iOS, each note card has a PencilKit canvas overlaid directly on top of the text,
/// so users can highlight, circle, and write over the actual content.
/// A pen toggle switches between reading mode and drawing mode.
struct NotebookView: View {
    let buildingId: Int
    let buildingName: String
    let sciences: [Science]
    let era: Era
    var notebookState: NotebookState
    var onDismiss: (() -> Void)? = nil

    @State private var selectedTab: NotebookTab = .keyFacts

    /// When non-nil, drawing mode is active for this entry
    @State private var drawingEntryId: UUID? = nil

    /// Global drawing mode toggle — enables drawing on ALL visible cards
    @State private var isDrawingMode = false

    #if os(macOS)
    @State private var macTool: StrokeTool = .marker
    @State private var macColor: StrokeColor = .yellow
    #endif

    /// User note creation state
    @State private var isAddingNote = false
    @State private var newNoteTitle = ""
    @State private var newNoteBody = ""

    private var notebook: BuildingNotebook? {
        notebookState.notebook(for: buildingId)
    }

    var body: some View {
        ZStack {
            RenaissanceColors.parchment.ignoresSafeArea()

            VStack(spacing: 0) {
                header
                tabBar

                if let notebook = notebook, !notebook.entries.isEmpty || selectedTab == .myNotes {
                    ScrollView {
                        LazyVStack(spacing: 14) {
                            // "Add Note" section on My Notes tab
                            if selectedTab == .myNotes {
                                addNoteSection
                            }

                            ForEach(entriesForTab(notebook)) { entry in
                                entryCard(entry)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                        .padding(.bottom, 80)
                    }
                } else {
                    emptyState
                }
            }

            // Floating draw-mode toggle
            #if os(iOS)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            isDrawingMode.toggle()
                            if !isDrawingMode {
                                drawingEntryId = nil
                            }
                        }
                    } label: {
                        Image(systemName: isDrawingMode ? "pencil.slash" : "pencil.tip")
                            .font(.custom("Mulish-SemiBold", size: 22, relativeTo: .title3))
                            .foregroundStyle(.white)
                            .frame(width: 56, height: 56)
                            .background(
                                Circle()
                                    .fill(isDrawingMode ? RenaissanceColors.errorRed : RenaissanceColors.ochre)
                                    .shadow(color: (isDrawingMode ? RenaissanceColors.errorRed : RenaissanceColors.ochre).opacity(0.4), radius: 8, y: 4)
                            )
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing, 24)
                    .padding(.bottom, 24)
                }
            }
            #elseif os(macOS)
            VStack {
                Spacer()
                HStack {
                    // Tool/color picker strip (only when drawing)
                    if isDrawingMode {
                        macDrawingToolbar
                    }
                    Spacer()
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            isDrawingMode.toggle()
                            if !isDrawingMode {
                                drawingEntryId = nil
                            }
                        }
                    } label: {
                        Image(systemName: isDrawingMode ? "pencil.slash" : "pencil.tip")
                            .font(.custom("Mulish-SemiBold", size: 22, relativeTo: .title3))
                            .foregroundStyle(.white)
                            .frame(width: 56, height: 56)
                            .background(
                                Circle()
                                    .fill(isDrawingMode ? RenaissanceColors.errorRed : RenaissanceColors.ochre)
                                    .shadow(color: (isDrawingMode ? RenaissanceColors.errorRed : RenaissanceColors.ochre).opacity(0.4), radius: 8, y: 4)
                            )
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing, 24)
                    .padding(.bottom, 24)
                }
            }
            #endif
        }
        #if os(iOS)
        .onDisappear {
            // When leaving notebook, turn off drawing and force-hide the shared picker
            // so it doesn't bleed onto the map or other views
            isDrawingMode = false
            drawingEntryId = nil
            SharedToolPicker.instance.hideFromAll()
        }
        #endif
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 8) {
            HStack {
                if let onDismiss = onDismiss {
                    Button {
                        onDismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.custom("Mulish-SemiBold", size: 16, relativeTo: .subheadline))
                            .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.6))
                            .frame(width: 36, height: 36)
                    }
                    .buttonStyle(.plain)
                }

                Spacer()

                VStack(spacing: 4) {
                    Text(buildingName)
                        .font(.custom("Cinzel-Regular", size: 22))
                        .foregroundStyle(RenaissanceColors.sepiaInk)

                    HStack(spacing: 6) {
                        Text(era.rawValue)
                            .font(.custom("Mulish-Light", size: 13))
                            .foregroundStyle(RenaissanceColors.sepiaInk)

                        ForEach(sciences, id: \.self) { science in
                            scienceChip(science)
                        }
                    }
                }

                Spacer()

                Color.clear.frame(width: 36, height: 36)
            }
            .padding(.horizontal, 16)

            HStack(spacing: 6) {
                Image(systemName: "book.closed.fill")
                    .font(.custom("Mulish-Light", size: 14, relativeTo: .footnote))
                    .foregroundStyle(RenaissanceColors.sepiaInk)
                let count = notebook?.entries.count ?? 0
                Text("\(count) \(count == 1 ? "entry" : "entries")")
                    .font(.custom("Mulish-Light", size: 14))
                    .foregroundStyle(RenaissanceColors.sepiaInk)

                if isDrawingMode {
                    Text("  Drawing Mode")
                        .font(.custom("Cinzel-Regular", size: 12))
                        .foregroundStyle(RenaissanceColors.errorRed)
                }
            }
        }
        .padding(.top, 16)
        .padding(.bottom, 8)
    }

    // MARK: - Tab Bar

    private var tabBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(NotebookTab.allCases, id: \.self) { tab in
                    tabPill(tab)
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 8)
    }

    private func tabPill(_ tab: NotebookTab) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTab = tab
            }
        } label: {
            HStack(spacing: 5) {
                Image(systemName: tab.icon)
                    .font(.custom("Delius-Regular", size: 12, relativeTo: .caption))
                Text(tab.label)
                    .font(.custom("Cinzel-Regular", size: 12))
            }
            .foregroundStyle(selectedTab == tab ? .white : RenaissanceColors.sepiaInk)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(selectedTab == tab ? RenaissanceColors.ochre : RenaissanceColors.ochre.opacity(0.1))
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Entry Cards

    private func entriesForTab(_ notebook: BuildingNotebook) -> [NotebookEntry] {
        switch selectedTab {
        case .keyFacts:
            return notebook.keyFacts
        case .vocabulary:
            return notebook.vocabularyEntries
        case .quizNotes:
            return notebook.quizResults
        case .myNotes:
            return notebook.userNotes
        }
    }

    private func entryCard(_ entry: NotebookEntry) -> some View {
        Group {
            if entry.entryType == .funFact {
                funFactCard(entry)
            } else {
                standardCard(entry)
            }
        }
    }

    // MARK: - Standard Card (with PencilKit overlay on iOS)

    private func standardCard(_ entry: NotebookEntry) -> some View {
        ZStack(alignment: .topLeading) {
            // Layer 1: Text content
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    if let science = entry.science {
                        scienceChip(science)
                    }
                    Spacer()
                    Text(entry.dateAdded, style: .date)
                        .font(.custom("Mulish-Light", size: 11))
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                }

                Text(entry.title)
                    .font(.custom("Delius-Regular", size: 16))
                    .foregroundStyle(RenaissanceColors.sepiaInk)
                    .lineLimit(2)

                markdownText(entry.body)
            }
            .padding(16)

            // Layer 2: Drawing overlay
            #if os(iOS)
            NotebookCanvasView(
                notebookState: notebookState,
                entryId: entry.id,
                isDrawing: isDrawingMode
            )
            .allowsHitTesting(isDrawingMode)
            #elseif os(macOS)
            NotebookCanvasView(
                notebookState: notebookState,
                entryId: entry.id,
                isDrawing: isDrawingMode,
                currentTool: macTool,
                currentColor: macColor
            )
            .allowsHitTesting(isDrawingMode)
            #endif
        }
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(RenaissanceColors.parchment)
                .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(isDrawingMode ? RenaissanceColors.renaissanceBlue.opacity(0.5) : RenaissanceColors.ochre.opacity(0.2), lineWidth: isDrawingMode ? 2 : 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - Fun Fact Card (with PencilKit overlay on iOS)

    private func funFactCard(_ entry: NotebookEntry) -> some View {
        ZStack(alignment: .topLeading) {
            // Layer 1: Fun fact text content
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: "paperclip")
                        .font(.custom("Mulish-Light", size: 16, relativeTo: .subheadline))
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                        .rotationEffect(.degrees(-30))
                    Text("Fun Fact")
                        .font(.custom("Cinzel-Regular", size: 14))
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                    Spacer()
                    Text(entry.dateAdded, style: .date)
                        .font(.custom("Mulish-Light", size: 11))
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                }

                markdownText(entry.body)
            }
            .padding(16)

            // Layer 2: Drawing overlay
            #if os(iOS)
            NotebookCanvasView(
                notebookState: notebookState,
                entryId: entry.id,
                isDrawing: isDrawingMode
            )
            .allowsHitTesting(isDrawingMode)
            #elseif os(macOS)
            NotebookCanvasView(
                notebookState: notebookState,
                entryId: entry.id,
                isDrawing: isDrawingMode,
                currentTool: macTool,
                currentColor: macColor
            )
            .allowsHitTesting(isDrawingMode)
            #endif
        }
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(red: 0.99, green: 0.96, blue: 0.88))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(isDrawingMode ? RenaissanceColors.renaissanceBlue.opacity(0.5) : RenaissanceColors.ochre.opacity(0.3), lineWidth: isDrawingMode ? 2 : 1.5)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: RenaissanceColors.ochre.opacity(0.1), radius: 6, y: 3)
    }

    // MARK: - Add Note Section

    private var addNoteSection: some View {
        VStack(spacing: 10) {
            if isAddingNote {
                VStack(spacing: 10) {
                    TextField("Title", text: $newNoteTitle)
                        .font(.custom("Cinzel-Regular", size: 16))
                        .textFieldStyle(.plain)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.white.opacity(0.6))
                        )

                    TextEditor(text: $newNoteBody)
                        .font(.custom("Delius-Regular", size: 15))
                        .scrollContentBackground(.hidden)
                        .frame(minHeight: 80, maxHeight: 140)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.white.opacity(0.6))
                        )

                    HStack {
                        Button("Cancel") {
                            withAnimation { isAddingNote = false }
                            newNoteTitle = ""
                            newNoteBody = ""
                        }
                        .font(.custom("Delius-Regular", size: 14))
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                        .buttonStyle(.plain)

                        Spacer()

                        Button {
                            guard !newNoteTitle.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                            notebookState.addUserNote(
                                buildingId: buildingId,
                                buildingName: buildingName,
                                title: newNoteTitle.trimmingCharacters(in: .whitespaces),
                                body: newNoteBody.trimmingCharacters(in: .whitespaces)
                            )
                            newNoteTitle = ""
                            newNoteBody = ""
                            withAnimation { isAddingNote = false }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "checkmark")
                                Text("Save")
                            }
                            .font(.custom("Cinzel-Regular", size: 14))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Capsule().fill(RenaissanceColors.ochre))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(RenaissanceColors.parchment)
                        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(RenaissanceColors.ochre.opacity(0.3), lineWidth: 1)
                )
            } else {
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        isAddingNote = true
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "plus.circle.fill")
                            .font(.custom("Delius-Regular", size: 16, relativeTo: .subheadline))
                        Text("Add Note")
                            .font(.custom("Cinzel-Regular", size: 14))
                    }
                    .foregroundStyle(RenaissanceColors.sepiaInk)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(RenaissanceColors.ochre.opacity(0.3), style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - macOS Drawing Toolbar

    #if os(macOS)
    private var macDrawingToolbar: some View {
        HStack(spacing: 8) {
            // Tool buttons
            ForEach(StrokeTool.allCases, id: \.self) { tool in
                Button {
                    macTool = tool
                } label: {
                    Image(systemName: iconForTool(tool))
                        .font(.custom(macTool == tool ? "Mulish-Bold" : "Mulish-Light", size: 14, relativeTo: .footnote))
                        .foregroundStyle(macTool == tool ? .white : RenaissanceColors.sepiaInk)
                        .frame(width: 32, height: 32)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(macTool == tool ? RenaissanceColors.ochre : RenaissanceColors.ochre.opacity(0.1))
                        )
                }
                .buttonStyle(.plain)
            }

            Divider().frame(height: 24)

            // Color buttons
            ForEach(StrokeColor.allCases, id: \.self) { color in
                Button {
                    macColor = color
                } label: {
                    Circle()
                        .fill(color.swiftUIColor)
                        .frame(width: 22, height: 22)
                        .overlay(
                            Circle()
                                .stroke(.white, lineWidth: macColor == color ? 2 : 0)
                                .shadow(radius: macColor == color ? 2 : 0)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(RenaissanceColors.parchment)
                .shadow(color: .black.opacity(0.1), radius: 6, y: 2)
        )
        .padding(.leading, 24)
        .padding(.bottom, 24)
    }

    private func iconForTool(_ tool: StrokeTool) -> String {
        switch tool {
        case .pen:    return "pencil.line"
        case .marker: return "highlighter"
        case .eraser: return "eraser.fill"
        }
    }
    #endif

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "book.closed")
                .font(.custom("Mulish-Light", size: 48, relativeTo: .title3))
                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.4))
            Text("No entries yet")
                .font(.custom("Cinzel-Regular", size: 18))
                .foregroundStyle(RenaissanceColors.sepiaInk)
            Text("Complete the lesson to fill your notebook with knowledge about \(buildingName).")
                .font(.custom("Mulish-Light", size: 15))
                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Spacer()
        }
    }

    // MARK: - Helpers

    private func scienceChip(_ science: Science) -> some View {
        HStack(spacing: 4) {
            if let imageName = science.customImageName {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                    .clipShape(RoundedRectangle(cornerRadius: 3))
            } else {
                Image(systemName: science.sfSymbolName)
                    .font(.custom("Mulish-Light", size: 11, relativeTo: .caption))
                    .foregroundStyle(RenaissanceColors.sepiaInk)
            }
            Text(science.rawValue)
                .font(.custom("Mulish-Light", size: 11))
                .foregroundStyle(RenaissanceColors.sepiaInk)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(
            Capsule()
                .fill(RenaissanceColors.ochre.opacity(0.1))
        )
    }

    private func markdownText(_ text: String) -> some View {
        let parts = parseBold(text)
        return parts.reduce(Text("")) { result, part in
            if part.isBold {
                return result + Text(part.text)
                    .font(.custom("Delius-Regular", size: 15))
                    .foregroundColor(RenaissanceColors.sepiaInk)
            } else {
                return result + Text(part.text)
                    .font(.custom("Delius-Regular", size: 15))
                    .foregroundColor(RenaissanceColors.sepiaInk)
            }
        }
        .lineSpacing(5)
        .multilineTextAlignment(.leading)
    }

    private struct TextPart {
        let text: String
        let isBold: Bool
    }

    private func parseBold(_ text: String) -> [TextPart] {
        var parts: [TextPart] = []
        var remaining = text
        while let startRange = remaining.range(of: "**") {
            let before = String(remaining[remaining.startIndex..<startRange.lowerBound])
            if !before.isEmpty {
                parts.append(TextPart(text: before, isBold: false))
            }
            let afterStart = String(remaining[startRange.upperBound...])
            if let endRange = afterStart.range(of: "**") {
                let boldText = String(afterStart[afterStart.startIndex..<endRange.lowerBound])
                parts.append(TextPart(text: boldText, isBold: true))
                remaining = String(afterStart[endRange.upperBound...])
            } else {
                parts.append(TextPart(text: "**" + afterStart, isBold: false))
                remaining = ""
            }
        }
        if !remaining.isEmpty {
            parts.append(TextPart(text: remaining, isBold: false))
        }
        return parts
    }
}

// MARK: - Notebook Tab

enum NotebookTab: String, CaseIterable {
    case keyFacts = "Key Facts"
    case vocabulary = "Vocabulary"
    case quizNotes = "Quiz Notes"
    case myNotes = "My Notes"

    var label: String { rawValue }

    var icon: String {
        switch self {
        case .keyFacts: return "lightbulb.fill"
        case .vocabulary: return "textformat.abc"
        case .quizNotes: return "checkmark.circle.fill"
        case .myNotes: return "pencil"
        }
    }
}
