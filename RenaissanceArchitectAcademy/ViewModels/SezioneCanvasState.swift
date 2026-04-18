import Foundation
import SwiftUI

/// @Observable state for the Sezione (cross-section) canvas.
/// Manages all 3 layers: walls, structural curves, and load paths.
/// Separated from the view for testability and clean architecture.
@MainActor @Observable
class SezioneCanvasState {

    // MARK: - Phase Data (set once when canvas loads)

    private(set) var phaseData: SezionePhaseData?

    // MARK: - Layer Progression

    var activeLayer: SezioneLayer = .walls
    var layerCompleted: Set<SezioneLayer> = []

    var isCurrentLayerComplete: Bool {
        layerCompleted.contains(activeLayer)
    }

    var allLayersComplete: Bool {
        SezioneLayer.allCases.allSatisfy { layerCompleted.contains($0) }
    }

    // MARK: - Layer 1: Walls

    var placedWalls: [SezioneWallPlacement] = []
    var draggedWallId: String? = nil

    // MARK: - Layer 2: Structural Curves

    /// Current control points per curve (keyed by curve ID)
    var curvePoints: [String: [CGPoint]] = [:]
    var lockedCurves: Set<String> = []

    // MARK: - Layer 3: Load Paths

    var placedArrows: [LoadPathSegment] = []
    var arrowStartPoint: GridCoord? = nil

    // MARK: - Validation & Hints

    var validationResult: SezioneValidationResult? = nil
    var hintLevel: Int = 0  // 0=none, 1=highlight, 2=outlines, 3=full guides

    // MARK: - Undo

    var actionHistory: [SezioneAction] = []

    // MARK: - Bird Companion

    var birdMessage: String? = nil

    // MARK: - Setup

    func configure(with data: SezionePhaseData) {
        phaseData = data
        activeLayer = .walls
        layerCompleted = []
        placedWalls = []
        draggedWallId = nil
        curvePoints = [:]
        lockedCurves = []
        placedArrows = []
        arrowStartPoint = nil
        validationResult = nil
        hintLevel = 0
        actionHistory = []
        birdMessage = "Start by placing the foundation walls. Thicker walls go at the base!"

        // Initialize curve control points from initial (wrong) positions
        for curve in data.structuralCurves {
            curvePoints[curve.id] = curve.initialPoints
        }
    }

    // MARK: - Layer 1: Wall Placement

    func placeWall(_ element: SezioneWallElement, at position: GridCoord) {
        let placement = SezioneWallPlacement(elementId: element.id, position: position)

        // Remove any existing placement of this wall
        placedWalls.removeAll { $0.elementId == element.id }
        placedWalls.append(placement)

        actionHistory.append(.placeWall(placement))
        draggedWallId = nil

        validateCurrentLayer()
    }

    func removeWall(elementId: String) {
        if let placement = placedWalls.first(where: { $0.elementId == elementId }) {
            placedWalls.removeAll { $0.elementId == elementId }
            actionHistory.append(.removeWall(placement))
            validateCurrentLayer()
        }
    }

    // MARK: - Layer 2: Curve Shaping

    func updateCurvePoint(_ curveId: String, pointIndex: Int, to newPosition: CGPoint) {
        guard activeLayer == .curves else { return }
        guard !lockedCurves.contains(curveId) else { return }
        curvePoints[curveId]?[pointIndex] = newPosition
    }

    func checkCurveLock(_ curveId: String) {
        guard let data = phaseData else { return }
        guard let curve = data.structuralCurves.first(where: { $0.id == curveId }) else { return }
        guard let currentPoints = curvePoints[curveId] else { return }

        // Calculate average distance to target
        let distances = zip(currentPoints, curve.targetPoints).map { current, target in
            sqrt(pow(current.x - target.x, 2) + pow(current.y - target.y, 2))
        }
        let avgDistance = distances.reduce(0, +) / Double(distances.count)

        if avgDistance <= curve.tolerance {
            // Lock the curve — snap to target
            curvePoints[curveId] = curve.targetPoints
            lockedCurves.insert(curveId)
            actionHistory.append(.lockCurve(curveId))
            birdMessage = curve.educationalHint
            validateCurrentLayer()
        }
    }

    // MARK: - Layer 3: Load Path Arrows

    func placeArrow(_ segment: LoadPathSegment) {
        guard activeLayer == .loadPaths else { return }

        // Don't allow duplicate arrows
        guard !placedArrows.contains(where: { $0.from == segment.from && $0.to == segment.to }) else { return }

        placedArrows.append(segment)
        actionHistory.append(.placeArrow(segment))
        arrowStartPoint = nil
        validateCurrentLayer()
    }

    func removeArrow(id: String) {
        placedArrows.removeAll { $0.id == id }
        actionHistory.append(.removeArrow(id))
        validateCurrentLayer()
    }

    // MARK: - Layer Advancement

    func advanceLayer() {
        guard isCurrentLayerComplete else { return }

        if let nextLayer = SezioneLayer.allCases.first(where: { $0 > activeLayer }) {
            activeLayer = nextLayer
            actionHistory.append(.advanceLayer(nextLayer))

            switch nextLayer {
            case .walls:
                birdMessage = "Place the walls — thicker at the base!"
            case .curves:
                birdMessage = "Now shape the arches and vaults. Drag the handles to form the correct curve."
            case .loadPaths:
                birdMessage = "Show how weight flows! Place arrows from the top down to the foundation."
            }
        }
    }

    // MARK: - Validation

    func validateCurrentLayer() {
        guard let data = phaseData else { return }

        let wallsCorrect = data.wallElements.filter { element in
            placedWalls.contains { $0.elementId == element.id && $0.position == element.targetPosition }
        }.count

        let curvesCorrect = lockedCurves.count

        let arrowsCorrect = data.loadPathTargets.filter { target in
            placedArrows.contains { $0.from == target.from && $0.to == target.to }
        }.count

        validationResult = SezioneValidationResult(
            wallsCorrect: wallsCorrect,
            wallsTotal: data.wallElements.count,
            curvesCorrect: curvesCorrect,
            curvesTotal: data.structuralCurves.count,
            arrowsCorrect: arrowsCorrect,
            arrowsTotal: data.loadPathTargets.count
        )

        // Check if current layer is complete
        if let result = validationResult {
            let (walls, curves, arrows) = result.layerComplete
            switch activeLayer {
            case .walls where walls && !layerCompleted.contains(.walls):
                layerCompleted.insert(.walls)
                birdMessage = "Excellent! The walls are in place. Now let's add the structural elements."
            case .curves where curves && !layerCompleted.contains(.curves):
                layerCompleted.insert(.curves)
                birdMessage = "The structure is sound! Now show how the forces flow through it."
            case .loadPaths where arrows && !layerCompleted.contains(.loadPaths):
                layerCompleted.insert(.loadPaths)
                birdMessage = data.educationalText
            default:
                break
            }
        }
    }

    func validate() -> SezioneValidationResult {
        validateCurrentLayer()
        return validationResult ?? SezioneValidationResult(
            wallsCorrect: 0, wallsTotal: 0,
            curvesCorrect: 0, curvesTotal: 0,
            arrowsCorrect: 0, arrowsTotal: 0
        )
    }

    // MARK: - Undo

    func undo() {
        guard let lastAction = actionHistory.popLast() else { return }

        switch lastAction {
        case .placeWall(let placement):
            placedWalls.removeAll { $0.elementId == placement.elementId }
        case .removeWall(let placement):
            placedWalls.append(placement)
        case .lockCurve(let curveId):
            lockedCurves.remove(curveId)
            // Reset to initial points
            if let data = phaseData,
               let curve = data.structuralCurves.first(where: { $0.id == curveId }) {
                curvePoints[curveId] = curve.initialPoints
            }
        case .placeArrow(let segment):
            placedArrows.removeAll { $0.id == segment.id }
        case .removeArrow(let id):
            // Can't easily restore — just skip
            break
        case .advanceLayer(let layer):
            // Go back to previous layer
            if let prevIndex = SezioneLayer.allCases.firstIndex(of: layer), prevIndex > 0 {
                activeLayer = SezioneLayer.allCases[prevIndex - 1]
            }
        }

        validateCurrentLayer()
    }

    // MARK: - Hints

    func requestHint() {
        guard hintLevel < 3 else { return }
        hintLevel += 1

        switch hintLevel {
        case 1:
            birdMessage = "Look at the cross-section — where are the thickest walls?"
        case 2:
            birdMessage = "I'll highlight where each element should go."
        case 3:
            birdMessage = "Here's the full guide — follow the outlines."
        default:
            break
        }
    }
}
