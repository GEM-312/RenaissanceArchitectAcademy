import SwiftUI
#if os(iOS)
import PencilKit
#endif

/// Persistent state for all building notebooks
/// Same @Observable pattern as OnboardingState
@Observable
class NotebookState {

    /// All notebooks keyed by building ID
    var notebooks: [Int: BuildingNotebook] = [:]

    /// Tracks which building lessons have been added to notebooks (avoid duplicates)
    var lessonsAddedToNotebook: Set<Int> = []

    /// Tracks which station lessons (bird at workshop) have been saved to notebooks
    var stationLessonsAddedToNotebook: Set<String> = []

    /// Current player name — used to scope file paths
    private(set) var playerName: String = ""

    // MARK: - Init (load from disk)

    init() {
        // Don't load yet — wait for switchPlayer(to:) to set the player name
    }

    /// Switch to a different player's notebook data
    func switchPlayer(to name: String) {
        playerName = sanitizedFileName(name)
        notebooks = [:]
        lessonsAddedToNotebook = []
        stationLessonsAddedToNotebook = []
        loadFromDisk()
    }

    /// Sanitize player name for safe filesystem use
    private func sanitizedFileName(_ name: String) -> String {
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_ "))
        let sanitized = name.unicodeScalars.filter { allowed.contains($0) }.map { Character($0) }
        let result = String(sanitized).trimmingCharacters(in: .whitespaces)
        return result.isEmpty ? "default" : result
    }

    // MARK: - Notebook Access

    /// Get or create a notebook for a building
    func getOrCreateNotebook(buildingId: Int, buildingName: String) -> BuildingNotebook {
        if let existing = notebooks[buildingId] {
            return existing
        }
        let notebook = BuildingNotebook(id: buildingId, buildingName: buildingName)
        notebooks[buildingId] = notebook
        saveToDisk()
        return notebook
    }

    /// Get notebook if it exists (nil if no entries yet)
    func notebook(for buildingId: Int) -> BuildingNotebook? {
        notebooks[buildingId]
    }

    /// Whether a notebook has any entries
    func hasEntries(for buildingId: Int) -> Bool {
        guard let notebook = notebooks[buildingId] else { return false }
        return !notebook.entries.isEmpty
    }

    // MARK: - Adding Entries

    /// Add multiple entries to a building's notebook
    func addEntries(_ entries: [NotebookEntry], buildingId: Int, buildingName: String) {
        var notebook = getOrCreateNotebook(buildingId: buildingId, buildingName: buildingName)
        notebook.entries.append(contentsOf: entries)
        notebook.lastModified = Date()
        notebooks[buildingId] = notebook
        saveToDisk()
    }

    /// Add a single user note
    func addUserNote(buildingId: Int, buildingName: String, title: String, body: String) {
        let entry = NotebookEntry(
            buildingId: buildingId,
            entryType: .userNote,
            title: title,
            body: body
        )
        var notebook = getOrCreateNotebook(buildingId: buildingId, buildingName: buildingName)
        notebook.entries.append(entry)
        notebook.lastModified = Date()
        notebooks[buildingId] = notebook
        saveToDisk()
    }

    /// Update the text annotation on an existing entry
    func updateAnnotation(for entryId: UUID, buildingId: Int, text: String) {
        guard var notebook = notebooks[buildingId] else { return }
        if let index = notebook.entries.firstIndex(where: { $0.id == entryId }) {
            notebook.entries[index].userAnnotation = text
            notebook.lastModified = Date()
            notebooks[buildingId] = notebook
            saveToDisk()
        }
    }

    /// Mark a lesson as added so we don't duplicate entries
    func markLessonAdded(for buildingId: Int) {
        lessonsAddedToNotebook.insert(buildingId)
        saveToDisk()
    }

    /// Whether this lesson's content has already been added
    func isLessonAdded(for buildingId: Int) -> Bool {
        lessonsAddedToNotebook.contains(buildingId)
    }

    // MARK: - PKDrawing Persistence (iOS only)

    #if os(iOS)
    /// Save a PKDrawing for a specific notebook entry
    func saveDrawing(_ drawing: PKDrawing, for entryId: UUID) {
        let url = drawingURL(for: entryId)
        do {
            let data = drawing.dataRepresentation()
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            try data.write(to: url)
        } catch {
            print("Failed to save drawing: \(error)")
        }
    }

    /// Load a PKDrawing for a specific notebook entry
    func loadDrawing(for entryId: UUID) -> PKDrawing? {
        let url = drawingURL(for: entryId)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? PKDrawing(data: data)
    }

    private func drawingURL(for entryId: UUID) -> URL {
        playerNotebooksDirectory
            .appendingPathComponent("Drawings")
            .appendingPathComponent("\(entryId.uuidString).pkdrawing")
    }
    #endif

    // MARK: - Stroke Persistence (macOS)

    #if os(macOS)
    /// Save strokes for a specific notebook entry as JSON
    func saveStrokes(_ strokes: [NotebookStroke], for entryId: UUID) {
        let url = strokesURL(for: entryId)
        do {
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            let data = try JSONEncoder().encode(strokes)
            try data.write(to: url)
        } catch {
            print("Failed to save strokes: \(error)")
        }
    }

    /// Load strokes for a specific notebook entry
    func loadStrokes(for entryId: UUID) -> [NotebookStroke] {
        let url = strokesURL(for: entryId)
        guard let data = try? Data(contentsOf: url),
              let strokes = try? JSONDecoder().decode([NotebookStroke].self, from: data) else {
            return []
        }
        return strokes
    }

    private func strokesURL(for entryId: UUID) -> URL {
        playerNotebooksDirectory
            .appendingPathComponent("Drawings")
            .appendingPathComponent("\(entryId.uuidString).strokes")
    }
    #endif

    // MARK: - JSON Persistence

    private var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    /// Player-scoped notebooks directory: Documents/Notebooks/{playerName}/
    private var playerNotebooksDirectory: URL {
        documentsDirectory
            .appendingPathComponent("Notebooks")
            .appendingPathComponent(playerName.isEmpty ? "default" : playerName)
    }

    private var notebooksFileURL: URL {
        playerNotebooksDirectory
            .appendingPathComponent("notebooks.json")
    }

    private func saveToDisk() {
        do {
            let dir = notebooksFileURL.deletingLastPathComponent()
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)

            let data = try JSONEncoder().encode(SavedState(
                notebooks: notebooks,
                lessonsAdded: lessonsAddedToNotebook,
                stationLessonsAdded: stationLessonsAddedToNotebook
            ))
            try data.write(to: notebooksFileURL)
        } catch {
            print("Failed to save notebooks: \(error)")
        }
    }

    private func loadFromDisk() {
        guard let data = try? Data(contentsOf: notebooksFileURL),
              let saved = try? JSONDecoder().decode(SavedState.self, from: data) else {
            return
        }
        notebooks = saved.notebooks
        lessonsAddedToNotebook = saved.lessonsAdded
        stationLessonsAddedToNotebook = saved.stationLessonsAdded ?? []
    }

    /// Whether a station lesson has already been saved to notebooks
    func isStationLessonAdded(_ stationKey: String) -> Bool {
        stationLessonsAddedToNotebook.contains(stationKey)
    }

    /// Mark a station lesson as saved
    func markStationLessonAdded(_ stationKey: String) {
        stationLessonsAddedToNotebook.insert(stationKey)
        saveToDisk()
    }

    /// Wrapper for JSON serialization
    private struct SavedState: Codable {
        let notebooks: [Int: BuildingNotebook]
        let lessonsAdded: Set<Int>
        var stationLessonsAdded: Set<String>?

        init(notebooks: [Int: BuildingNotebook], lessonsAdded: Set<Int>, stationLessonsAdded: Set<String>) {
            self.notebooks = notebooks
            self.lessonsAdded = lessonsAdded
            self.stationLessonsAdded = stationLessonsAdded
        }
    }
}
