import Foundation
import SwiftData

@MainActor
final class PersistenceManager {
    let modelContext: ModelContext
    var currentPlayerName: String = ""

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Player Save (scoped by currentPlayerName)

    func loadPlayerSave() -> PlayerSave {
        let name = currentPlayerName
        let descriptor = FetchDescriptor<PlayerSave>(
            predicate: #Predicate { $0.apprenticeName == name }
        )
        if let existing = try? modelContext.fetch(descriptor).first {
            return existing
        }
        // No save for this player — create new one
        let save = PlayerSave()
        save.apprenticeName = name
        modelContext.insert(save)
        try? modelContext.save()
        return save
    }

    /// Returns the most recently saved player name, or nil if no saves exist
    func loadMostRecentPlayer() -> String? {
        var descriptor = FetchDescriptor<PlayerSave>(
            sortBy: [SortDescriptor(\.lastSaved, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        guard let save = try? modelContext.fetch(descriptor).first,
              !save.apprenticeName.isEmpty else {
            return nil
        }
        return save.apprenticeName
    }

    private func migrateFromUserDefaults(into save: PlayerSave) {
        let defaults = UserDefaults.standard
        save.hasCompletedOnboarding = defaults.bool(forKey: "hasCompletedOnboarding")
        save.apprenticeGender = defaults.string(forKey: "apprenticeGender") ?? "boy"
        save.apprenticeName = defaults.string(forKey: "apprenticeName") ?? ""

        // Migrate lesson bookmarks into BuildingProgressRecords
        for buildingId in 1...17 {
            let key = "lessonBookmark_\(buildingId)"
            let sectionIndex = defaults.integer(forKey: key)
            if sectionIndex > 0 {
                let record = getOrCreateBuildingProgress(for: buildingId)
                record.lessonSectionIndex = sectionIndex
            }
        }

        // Clean up old UserDefaults keys
        defaults.removeObject(forKey: "hasCompletedOnboarding")
        defaults.removeObject(forKey: "apprenticeGender")
        defaults.removeObject(forKey: "apprenticeName")
        for buildingId in 1...17 {
            defaults.removeObject(forKey: "lessonBookmark_\(buildingId)")
        }
    }

    // MARK: - Building Progress (scoped by currentPlayerName)

    func loadAllBuildingProgress() -> [Int: BuildingProgressRecord] {
        let name = currentPlayerName
        let descriptor = FetchDescriptor<BuildingProgressRecord>(
            predicate: #Predicate { $0.playerName == name }
        )
        guard let records = try? modelContext.fetch(descriptor) else { return [:] }
        return Dictionary(uniqueKeysWithValues: records.map { ($0.buildingId, $0) })
    }

    func getOrCreateBuildingProgress(for buildingId: Int) -> BuildingProgressRecord {
        let name = currentPlayerName
        var descriptor = FetchDescriptor<BuildingProgressRecord>(
            predicate: #Predicate { $0.buildingId == buildingId && $0.playerName == name }
        )
        descriptor.fetchLimit = 1
        if let existing = try? modelContext.fetch(descriptor).first {
            return existing
        }
        let record = BuildingProgressRecord(buildingId: buildingId)
        record.playerName = currentPlayerName
        modelContext.insert(record)
        return record
    }

    // MARK: - Save

    func save() {
        try? modelContext.save()
    }
}
