import Foundation
import SwiftData

/// SwiftData model for persisting lessons — stores BuildingLesson as JSON
@Model
final class LessonRecord {
    @Attribute(.unique) var buildingName: String
    var title: String
    var sectionsJSON: Data
    var lastModified: Date
    var version: Int

    init(buildingName: String, title: String, sectionsJSON: Data,
         lastModified: Date = .now, version: Int = 1) {
        self.buildingName = buildingName
        self.title = title
        self.sectionsJSON = sectionsJSON
        self.lastModified = lastModified
        self.version = version
    }

    /// Decode sections from stored JSON
    var sections: [LessonSection] {
        (try? JSONDecoder().decode([LessonSection].self, from: sectionsJSON)) ?? []
    }

    /// Convert to in-memory BuildingLesson
    var lesson: BuildingLesson {
        BuildingLesson(buildingName: buildingName, title: title, sections: sections)
    }

    /// Create from a static BuildingLesson
    convenience init(from lesson: BuildingLesson) {
        let json = (try? JSONEncoder().encode(lesson.sections)) ?? Data()
        self.init(buildingName: lesson.buildingName, title: lesson.title, sectionsJSON: json)
    }
}

// MARK: - Seed Service

enum LessonSeedService {

    /// Seed all 17 building lessons into SwiftData on first launch
    @MainActor
    static func seedIfNeeded(context: ModelContext) {
        // Check if lessons already exist
        let descriptor = FetchDescriptor<LessonRecord>()
        let count = (try? context.fetchCount(descriptor)) ?? 0
        if count >= 17 { return }

        // All 17 building names in order
        let buildingNames = [
            "Aqueduct", "Colosseum", "Roman Baths", "Pantheon",
            "Roman Roads", "Harbor", "Siege Workshop", "Insula",
            "Il Duomo", "Botanical Garden", "Glassworks", "Arsenal",
            "Anatomy Theater", "Leonardo's Workshop", "Flying Machine",
            "Vatican Observatory", "Printing Press"
        ]

        for name in buildingNames {
            if let lesson = LessonContent.lesson(for: name) {
                let record = LessonRecord(from: lesson)
                context.insert(record)
            }
        }

        try? context.save()
    }

    /// Fetch a lesson by building name from SwiftData
    @MainActor
    static func fetchLesson(for buildingName: String, context: ModelContext) -> BuildingLesson? {
        var descriptor = FetchDescriptor<LessonRecord>(
            predicate: #Predicate { $0.buildingName == buildingName }
        )
        descriptor.fetchLimit = 1
        guard let record = try? context.fetch(descriptor).first else {
            // Fall back to static content
            return LessonContent.lesson(for: buildingName)
        }
        return record.lesson
    }
}
