import Foundation

// MARK: - Sketching Phase Types

/// The sketching phase. Only Pianta (floor plan) is supported at the apprentice level.
/// Additional historical phases (Alzato, Sezione, Prospettiva) were removed Apr 21 2026 —
/// Architect level will introduce deeper drawing work separately.
enum SketchingPhaseType: String, CaseIterable, Codable, Hashable {
    case pianta = "Pianta"  // Floor plan

    var displayName: String { "Floor Plan" }
    var italianTitle: String { "Pianta" }
    var iconName: String { "square.grid.3x3" }
}

// MARK: - Grid Types

/// A position on the squared drawing grid
struct GridCoord: Equatable, Hashable, Codable {
    let row: Int
    let col: Int
}

/// A wall segment between two grid points (horizontal or vertical only)
struct WallSegment: Identifiable, Equatable, Hashable {
    let id = UUID()
    let start: GridCoord
    let end: GridCoord

    /// Whether this wall is horizontal
    var isHorizontal: Bool { start.row == end.row }

    /// Whether this wall is vertical
    var isVertical: Bool { start.col == end.col }

    /// Length in grid cells
    var length: Int {
        if isHorizontal { return abs(end.col - start.col) }
        if isVertical { return abs(end.row - start.row) }
        return 0
    }
}

/// A column placed at a grid intersection
struct ColumnPlacement: Identifiable, Equatable, Hashable {
    let id = UUID()
    let position: GridCoord
}

/// A circle drawn on the grid (center + radius in grid cells)
struct CirclePlacement: Identifiable, Equatable, Hashable {
    let id = UUID()
    let center: GridCoord
    let radius: Int  // in grid cells
}

/// A proportional ratio (e.g., 3:2, 1:1, 4:3)
struct ProportionalRatio: Equatable {
    let numerator: Int
    let denominator: Int

    var displayString: String { "\(numerator):\(denominator)" }

    /// Check if a width:height ratio matches (within tolerance)
    func matches(width: Int, height: Int) -> Bool {
        guard width > 0 && height > 0 else { return false }
        // Check both orientations (3:2 matches 6:4, 4:6, etc.)
        let targetRatio = Double(numerator) / Double(denominator)
        let actualRatio = Double(width) / Double(height)
        let inverseRatio = Double(height) / Double(width)
        let tolerance = 0.15
        return abs(actualRatio - targetRatio) < tolerance ||
               abs(inverseRatio - targetRatio) < tolerance
    }
}

/// Symmetry axis for building designs
enum SymmetryAxis: String, Codable {
    case horizontal
    case vertical
    case both
}

// MARK: - Room Definition

/// The shape of a room on the floor plan
enum RoomShape: String {
    case rectangle
    case circle
}

/// A room that the player must create on the floor plan
struct RoomDefinition: Identifiable {
    let id = UUID()
    let label: String           // e.g., "Rotunda", "Nave", "Portico"
    let origin: GridCoord       // Top-left corner on grid (for rectangles) or center (for circles)
    let width: Int              // Width in grid cells (for circles: diameter)
    let height: Int             // Height in grid cells (for circles: diameter)
    let requiredRatio: ProportionalRatio?  // Required width:height ratio
    let shape: RoomShape        // .rectangle or .circle

    init(label: String, origin: GridCoord, width: Int, height: Int, requiredRatio: ProportionalRatio?, shape: RoomShape = .rectangle) {
        self.label = label
        self.origin = origin
        self.width = width
        self.height = height
        self.requiredRatio = requiredRatio
        self.shape = shape
    }

    /// Center position on grid
    var center: GridCoord {
        if shape == .circle {
            return origin  // origin IS the center for circles
        }
        return GridCoord(row: origin.row + height / 2, col: origin.col + width / 2)
    }

    /// Radius in grid cells (for circles)
    var radius: Int {
        width / 2
    }
}

// MARK: - Phase Data

/// Data specific to the Pianta (Floor Plan) phase
struct PiantaPhaseData {
    let gridSize: Int                           // Grid dimensions (e.g., 12 = 12x12)
    let targetRooms: [RoomDefinition]           // Rooms player must create
    let targetColumns: [GridCoord]              // Required column positions
    let symmetryAxis: SymmetryAxis?             // Required symmetry (nil = none)
    let proportionalRatios: [ProportionalRatio] // Key ratios to teach
    let hint: String?                           // First hint text
    let educationalText: String                 // Shown after completion
    let historicalContext: String               // Historical facts about this building
}

// MARK: - Phase Content

/// The content for a sketching phase. Single-case enum kept for future expansion
/// (in case Architect level reintroduces additional phase types).
enum SketchingPhaseContent {
    case pianta(PiantaPhaseData)
}

// MARK: - Sketching Phase

/// One phase within a sketching challenge (currently always Pianta)
struct SketchingPhase: Identifiable {
    let id = UUID()
    let phaseType: SketchingPhaseType
    let title: String                   // e.g., "Pianta: Floor Plan"
    let introduction: String            // Instructions shown before drawing
    let sciencesFocused: [Science]      // Sciences taught in this phase
    let phaseData: SketchingPhaseContent
}

// MARK: - Sketching Challenge (Top Level)

/// A complete sketching challenge for one building
struct SketchingChallenge: Identifiable {
    let id = UUID()
    let buildingName: String
    let introduction: String            // Overall intro text
    let phases: [SketchingPhase]        // Always [.pianta] at apprentice level
    let educationalSummary: String      // Shown after the phase is complete
}

// MARK: - Sketching Progress

/// Tracks which sketching phases a player has completed for a building
struct SketchingProgress: Codable, Equatable {
    var completedPhases: Set<SketchingPhaseType> = []

    var isSketchingComplete: Bool {
        !completedPhases.isEmpty
    }

    var completedCount: Int {
        completedPhases.count
    }
}

// MARK: - Sketching Tool

/// Tools available in the Pianta sketching toolbar
enum SketchingTool: String, CaseIterable {
    case wall = "Wall"
    case circleTool = "Circle"
    case column = "Column"
    case roomLabel = "Room"
    case eraser = "Eraser"
    case undo = "Undo"

    var iconName: String {
        switch self {
        case .wall: return "pencil.line"
        case .circleTool: return "circle.dashed"
        case .column: return "circle"
        case .roomLabel: return "tag"
        case .eraser: return "eraser"
        case .undo: return "arrow.counterclockwise"
        }
    }
}
