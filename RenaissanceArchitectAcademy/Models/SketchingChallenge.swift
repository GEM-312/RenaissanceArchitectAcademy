import Foundation

// MARK: - Sketching Phase Types

/// The four historical drawing phases of Renaissance architecture
enum SketchingPhaseType: String, CaseIterable, Codable, Hashable {
    case pianta = "Pianta"           // Floor plan
    case alzato = "Alzato"           // Elevation
    case sezione = "Sezione"         // Cross-section
    case prospettiva = "Prospettiva" // Perspective

    var displayName: String {
        switch self {
        case .pianta: return "Floor Plan"
        case .alzato: return "Elevation"
        case .sezione: return "Cross-Section"
        case .prospettiva: return "Perspective"
        }
    }

    var italianTitle: String {
        switch self {
        case .pianta: return "Pianta"
        case .alzato: return "Alzato"
        case .sezione: return "Sezione"
        case .prospettiva: return "Prospettiva"
        }
    }

    var iconName: String {
        switch self {
        case .pianta: return "square.grid.3x3"
        case .alzato: return "building.columns"
        case .sezione: return "scissors"
        case .prospettiva: return "eye"
        }
    }
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

/// Classical column orders (for Phase 2 - Alzato)
enum ClassicalOrder: String, CaseIterable, Codable {
    case doric = "Doric"
    case ionic = "Ionic"
    case corinthian = "Corinthian"

    var heightToWidthRatio: Double {
        switch self {
        case .doric: return 6.0       // Stocky, strong
        case .ionic: return 8.0       // Elegant
        case .corinthian: return 10.0 // Slender, ornate
        }
    }
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

/// Data specific to Phase 1: Pianta (Floor Plan)
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

/// Data specific to Phase 2: Alzato (Elevation) — Bézier curve shaping
struct AlzatoPhaseData {
    let canvasWidth: Int
    let canvasHeight: Int
    let elements: [AlzatoElement]           // Draggable curve elements on the elevation
    let requiredOrder: ClassicalOrder
    let educationalText: String
    let historicalContext: String
}

/// A single draggable architectural element on the elevation view
struct AlzatoElement: Identifiable {
    let id: String                          // "arch", "dome", "columnLeft"
    let label: String                       // "Portico Arch"
    let type: AlzatoElementType
    let position: CGPoint                   // normalized 0-1 position on canvas
    let size: CGSize                        // normalized 0-1 size on canvas
    let initialPoints: [CGPoint]            // starting control points (wrong shape)
    let targetPoints: [CGPoint]             // correct control points (target shape)
    let fixedAxis: AlzatoFixedAxis          // which axis is locked during drag
    let clampRange: ClosedRange<CGFloat>    // allowed drag range on the free axis (0-1)
    let tolerance: CGFloat                  // max average distance to target for correct (0-1)
    let educationalHint: String             // shown when element is correct
}

/// Which axis is locked when dragging control points
enum AlzatoFixedAxis {
    case horizontal     // X fixed, drag Y only (arches, domes)
    case vertical       // Y fixed, drag X only (column entasis)
    case free           // both axes draggable
}

/// Types of facade elements the player shapes
enum AlzatoElementType {
    case arch           // semicircular opening (drag keystone height)
    case dome           // hemisphere profile (drag peak)
    case column         // with optional entasis (drag width at midpoint)
    case pediment       // triangular pediment (drag peak angle)
    case wall           // rectangular section (drag height)
}

// MARK: - Sezione Types (Phase 3: Cross-Section)

/// Wall thickness in cross-section — teaches load distribution
enum SezioneThickness: String, Codable, CaseIterable {
    case thin       // Upper walls, lighter loads
    case medium     // Mid-level walls
    case thick      // Foundations, heavy loads

    var displayName: String {
        switch self {
        case .thin: return "Thin"
        case .medium: return "Medium"
        case .thick: return "Thick"
        }
    }

    var gridWidth: Int {
        switch self {
        case .thin: return 1
        case .medium: return 2
        case .thick: return 3
        }
    }
}

/// A wall segment available in the drag palette for cross-section
struct SezioneWallElement: Identifiable, Codable, Equatable, Hashable {
    let id: String              // "foundation", "leftWall", "upperWall"
    let label: String           // "Foundation Wall (6m thick)"
    let targetPosition: GridCoord
    let width: Int              // Grid cells wide
    let height: Int             // Grid cells tall
    let thickness: SezioneThickness
    let material: String        // "concrete", "brick", "stone" (educational)

    static func == (lhs: Self, rhs: Self) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

/// A placed wall on the cross-section grid
struct SezioneWallPlacement: Codable, Equatable {
    let elementId: String
    let position: GridCoord
}

/// Structural curve types in cross-section
enum SezioneStructureType: String, Codable, CaseIterable {
    case arch
    case barrelVault
    case dome
    case groinVault
    case flatLintel
    case pitchedRoof

    var displayName: String {
        switch self {
        case .arch: return "Arch"
        case .barrelVault: return "Barrel Vault"
        case .dome: return "Dome"
        case .groinVault: return "Groin Vault"
        case .flatLintel: return "Flat Lintel"
        case .pitchedRoof: return "Pitched Roof"
        }
    }
}

/// A structural curve element in the cross-section (Layer 2)
struct SezioneStructuralCurve: Identifiable {
    let id: String              // "mainArch", "barrelVault"
    let label: String
    let type: SezioneStructureType
    let position: CGPoint       // Normalized 0-1 on canvas
    let size: CGSize            // Normalized 0-1
    let initialPoints: [CGPoint]  // Starting shape (wrong)
    let targetPoints: [CGPoint]   // Correct shape
    let tolerance: CGFloat      // Max avg distance for correct
    let educationalHint: String
}

/// Load path direction for arrows (Layer 3)
enum LoadDirection: String, Codable, CaseIterable {
    case down
    case diagonalLeft
    case diagonalRight
    case outward    // Lateral thrust

    var iconName: String {
        switch self {
        case .down: return "arrow.down"
        case .diagonalLeft: return "arrow.down.left"
        case .diagonalRight: return "arrow.down.right"
        case .outward: return "arrow.left.and.right"
        }
    }
}

/// A load path arrow segment (Layer 3)
struct LoadPathSegment: Identifiable, Codable, Equatable {
    let id: String
    let from: GridCoord
    let to: GridCoord
    let direction: LoadDirection
    let label: String           // "Compression through arch"
}

/// The three interactive layers in SezioneCanvasView
enum SezioneLayer: Int, CaseIterable, Comparable {
    case walls = 0
    case curves = 1
    case loadPaths = 2

    static func < (lhs: SezioneLayer, rhs: SezioneLayer) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    var displayName: String {
        switch self {
        case .walls: return "Walls"
        case .curves: return "Structure"
        case .loadPaths: return "Load Path"
        }
    }

    var iconName: String {
        switch self {
        case .walls: return "rectangle.split.3x3"
        case .curves: return "arch.brick"
        case .loadPaths: return "arrow.down.to.line"
        }
    }
}

/// Data specific to Phase 3: Sezione (Cross-Section)
struct SezionePhaseData {
    let gridRows: Int
    let gridCols: Int
    let wallElements: [SezioneWallElement]
    let structuralCurves: [SezioneStructuralCurve]
    let loadPathTargets: [LoadPathSegment]
    let educationalText: String
    let historicalContext: String
    let hint: String?
}

// MARK: - Sezione Actions (for undo/redo)

/// Value-type actions for the Sezione canvas — enables undo history
enum SezioneAction: Equatable {
    case placeWall(SezioneWallPlacement)
    case removeWall(SezioneWallPlacement)
    case lockCurve(String)
    case placeArrow(LoadPathSegment)
    case removeArrow(String)
    case advanceLayer(SezioneLayer)
}

// MARK: - Sezione Validation

/// Result of validating the student's cross-section
struct SezioneValidationResult {
    let wallsCorrect: Int
    let wallsTotal: Int
    let curvesCorrect: Int
    let curvesTotal: Int
    let arrowsCorrect: Int
    let arrowsTotal: Int

    var isComplete: Bool {
        wallsCorrect == wallsTotal &&
        curvesCorrect == curvesTotal &&
        arrowsCorrect == arrowsTotal
    }

    var layerComplete: (walls: Bool, curves: Bool, arrows: Bool) {
        (wallsCorrect == wallsTotal,
         curvesCorrect == curvesTotal,
         arrowsCorrect == arrowsTotal)
    }
}

// MARK: - Teaching Animation

/// Simplified building silhouette for the 3D→2D transition animation
struct BuildingSilhouetteData {
    let outlinePath: [CGPoint]       // Building outline (normalized 0-1)
    let roofPath: [CGPoint]?         // Roof portion (lifts away for Pianta)
    let interiorPaths: [[CGPoint]]?  // Interior lines (revealed for Sezione)
    let slicePosition: CGFloat       // Where to cut for Sezione (0-1)
}

// MARK: - Flow State Machine

/// Drives the entire sketching challenge flow — replaces boolean soup
/// Uses the existing SketchTeachingStep from SketchTeachingData.swift
enum SketchingFlowState: Equatable {
    case intro
    case animation(SketchingPhaseType)
    case teaching(Int)                   // step index (0=observe, 1=understand, 2=plan)
    case drawing(SketchingPhaseType)
    case phaseComplete(SketchingPhaseType)
    case allComplete
}

// MARK: - Sezione Tool

/// Tools available in the Sezione toolbar
enum SezioneTool: String, CaseIterable {
    case dragWall = "Drag Wall"
    case shapeCurve = "Shape Curve"
    case placeArrow = "Place Arrow"
    case eraser = "Eraser"
    case undo = "Undo"

    var iconName: String {
        switch self {
        case .dragWall: return "rectangle.split.3x3"
        case .shapeCurve: return "scribble.variable"
        case .placeArrow: return "arrow.down.to.line"
        case .eraser: return "eraser"
        case .undo: return "arrow.counterclockwise"
        }
    }
}

/// Data specific to Phase 4: Prospettiva (Perspective) - Future
struct ProspettivaPhaseData {
    let canvasWidth: Int
    let canvasHeight: Int
    let vanishingPoints: Int  // 1 or 2 point perspective
    let educationalText: String
}

// MARK: - Phase Content (Discriminated Union)

/// The specific content for each phase type
enum SketchingPhaseContent {
    case pianta(PiantaPhaseData)
    case alzato(AlzatoPhaseData)
    case sezione(SezionePhaseData)
    case prospettiva(ProspettivaPhaseData)
}

// MARK: - Sketching Phase

/// One phase within a sketching challenge
struct SketchingPhase: Identifiable {
    let id = UUID()
    let phaseType: SketchingPhaseType
    let title: String                   // e.g., "Pianta: Floor Plan"
    let introduction: String            // Instructions shown before drawing
    let sciencesFocused: [Science]      // Sciences taught in this phase
    let phaseData: SketchingPhaseContent
}

// MARK: - Sketching Challenge (Top Level)

/// A complete sketching challenge for one building (1-4 phases)
struct SketchingChallenge: Identifiable {
    let id = UUID()
    let buildingName: String
    let introduction: String            // Overall intro text
    let phases: [SketchingPhase]        // 1-4 phases
    let educationalSummary: String      // Shown after all phases complete
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

/// Tools available in the sketching toolbar
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
