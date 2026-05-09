import SwiftUI

/// Types of entries that can appear in a building notebook
enum NotebookEntryType: String, Codable, CaseIterable {
    case keyFact           // From lesson readings
    case funFact           // From lesson fun facts
    case vocabulary        // Curated key terms
    case scienceConcept    // Science-specific info
    case quizResult        // Question + correct answer + explanation
    case userNote          // Player's own notes
    case environmentNote   // From workshop/forest visits
    case sketch            // Pianta floor plan sketch — PKDrawing saved separately
    case discoveryCard     // Cross-cutting station/forest fact, not tied to a specific building
}

/// A single entry in a building's notebook
struct NotebookEntry: Identifiable, Codable {
    let id: UUID
    let buildingId: Int
    let entryType: NotebookEntryType
    let science: Science?
    let title: String
    let body: String           // Supports **bold** markdown
    let dateAdded: Date
    var userAnnotation: String? // Optional text annotation by user

    init(buildingId: Int, entryType: NotebookEntryType, science: Science? = nil,
         title: String, body: String, userAnnotation: String? = nil) {
        self.id = UUID()
        self.buildingId = buildingId
        self.entryType = entryType
        self.science = science
        self.title = title
        self.body = body
        self.dateAdded = Date()
        self.userAnnotation = userAnnotation
    }
}

/// A building's complete notebook — collects all knowledge learned
struct BuildingNotebook: Identifiable, Codable {
    let id: Int                     // Same as BuildingPlot.id
    let buildingName: String
    var entries: [NotebookEntry]
    var lastModified: Date

    init(id: Int, buildingName: String) {
        self.id = id
        self.buildingName = buildingName
        self.entries = []
        self.lastModified = Date()
    }

    /// Entries grouped by science
    var entriesByScience: [Science: [NotebookEntry]] {
        var result: [Science: [NotebookEntry]] = [:]
        for entry in entries {
            if let science = entry.science {
                result[science, default: []].append(entry)
            }
        }
        return result
    }

    /// Only user-created notes
    var userNotes: [NotebookEntry] {
        entries.filter { $0.entryType == .userNote }
    }

    /// Key facts from lesson readings + environment notes
    var keyFacts: [NotebookEntry] {
        entries.filter { $0.entryType == .keyFact || $0.entryType == .scienceConcept || $0.entryType == .environmentNote }
    }

    /// Fun facts
    var funFacts: [NotebookEntry] {
        entries.filter { $0.entryType == .funFact }
    }

    /// Vocabulary terms
    var vocabularyEntries: [NotebookEntry] {
        entries.filter { $0.entryType == .vocabulary }
    }

    /// Quiz results
    var quizResults: [NotebookEntry] {
        entries.filter { $0.entryType == .quizResult }
    }

    /// Sketches — Pianta floor plans the student saved (most recent first)
    var sketches: [NotebookEntry] {
        entries.filter { $0.entryType == .sketch }
            .sorted { $0.dateAdded > $1.dateAdded }
    }
}

// MARK: - Stroke Drawing Model (macOS)

/// Drawing tool type
enum StrokeTool: String, Codable, CaseIterable {
    case pen
    case marker
    case eraser
}

/// Stroke color presets matching the Renaissance palette
enum StrokeColor: String, Codable, CaseIterable {
    case yellow
    case sepia
    case red
    case blue

    #if os(macOS)
    var nsColor: NSColor {
        NSColor(swiftUIColor)
    }
    #endif

    var swiftUIColor: Color {
        switch self {
        case .yellow: return RenaissanceColors.notebookYellow
        case .sepia:  return RenaissanceColors.sepiaInk
        case .red:    return RenaissanceColors.errorRed
        case .blue:   return RenaissanceColors.renaissanceBlue
        }
    }
}

/// A single stroke drawn on a notebook card
struct NotebookStroke: Codable, Identifiable {
    let id: UUID
    let points: [CGPoint]
    let color: StrokeColor
    let width: CGFloat
    let tool: StrokeTool

    init(points: [CGPoint], color: StrokeColor, width: CGFloat, tool: StrokeTool) {
        self.id = UUID()
        self.points = points
        self.color = color
        self.width = width
        self.tool = tool
    }
}
