import Foundation
import SwiftData

@Model
final class BuildingProgressRecord {
    var buildingId: Int = 0
    var playerName: String = ""
    var scienceBadgesRaw: [String] = []
    var sketchCompleted: Bool = false
    var quizPassed: Bool = false
    var lessonRead: Bool = false
    var lessonSectionIndex: Int = 0
    var isCompleted: Bool = false
    var challengeProgress: Double = 0.0
    var sketchingPhasesRaw: [String] = []

    init() {}

    init(buildingId: Int) {
        self.buildingId = buildingId
    }

    // MARK: - Computed Accessors

    var scienceBadgesEarned: Set<Science> {
        get {
            Set(scienceBadgesRaw.compactMap { Science(rawValue: $0) })
        }
        set {
            scienceBadgesRaw = newValue.map(\.rawValue)
        }
    }

    var completedSketchingPhases: Set<SketchingPhaseType> {
        get {
            Set(sketchingPhasesRaw.compactMap { SketchingPhaseType(rawValue: $0) })
        }
        set {
            sketchingPhasesRaw = newValue.map(\.rawValue)
        }
    }

    // MARK: - Conversion Helpers

    func toBuildingProgress() -> BuildingProgress {
        var progress = BuildingProgress()
        progress.scienceBadgesEarned = scienceBadgesEarned
        progress.sketchCompleted = sketchCompleted
        progress.quizPassed = quizPassed
        progress.lessonRead = lessonRead
        progress.lessonSectionIndex = lessonSectionIndex
        return progress
    }

    func update(from progress: BuildingProgress) {
        scienceBadgesEarned = progress.scienceBadgesEarned
        sketchCompleted = progress.sketchCompleted
        quizPassed = progress.quizPassed
        lessonRead = progress.lessonRead
        lessonSectionIndex = progress.lessonSectionIndex
    }
}
