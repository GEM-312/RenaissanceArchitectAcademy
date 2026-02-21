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
        switch self {
        case .yellow: return NSColor(red: 1.0, green: 0.85, blue: 0.3, alpha: 1.0)
        case .sepia:  return NSColor(red: 0.29, green: 0.25, blue: 0.21, alpha: 1.0)
        case .red:    return NSColor(red: 0.8, green: 0.36, blue: 0.36, alpha: 1.0)
        case .blue:   return NSColor(red: 0.36, green: 0.56, blue: 0.64, alpha: 1.0)
        }
    }
    #endif

    var swiftUIColor: Color {
        switch self {
        case .yellow: return Color(red: 1.0, green: 0.85, blue: 0.3)
        case .sepia:  return Color(red: 0.29, green: 0.25, blue: 0.21)
        case .red:    return Color(red: 0.8, green: 0.36, blue: 0.36)
        case .blue:   return Color(red: 0.36, green: 0.56, blue: 0.64)
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
