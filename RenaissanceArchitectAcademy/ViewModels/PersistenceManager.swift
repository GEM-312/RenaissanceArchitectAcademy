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
        do {
            if let existing = try modelContext.fetch(descriptor).first {
                print("[PERSIST] Found existing save for '\(name)' — florins: \(existing.goldFlorins), apprenticeName: '\(existing.apprenticeName)'")
                return existing
            }
        } catch {
            print("[PERSIST ERROR] fetch(PlayerSave where name='\(name)') failed: \(error)")
        }
        print("[PERSIST] No save found for '\(name)' — creating fresh save")
        let save = PlayerSave()
        save.apprenticeName = name
        modelContext.insert(save)
        do {
            try modelContext.save()
        } catch {
            print("[PERSIST ERROR] insert new PlayerSave('\(name)') failed: \(error)")
        }
        return save
    }

    /// Returns the most recently saved player name, or nil if no saves exist
    func loadMostRecentPlayer() -> String? {
        var descriptor = FetchDescriptor<PlayerSave>(
            sortBy: [SortDescriptor(\.lastSaved, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        do {
            let all = try modelContext.fetch(descriptor)
            print("[PERSIST] loadMostRecentPlayer — \(all.count) PlayerSave row(s) in store")
            guard let save = all.first else {
                print("[PERSIST] loadMostRecentPlayer — store is empty, returning nil")
                return nil
            }
            guard !save.apprenticeName.isEmpty else {
                print("[PERSIST] loadMostRecentPlayer — most recent save has empty name, returning nil")
                return nil
            }
            print("[PERSIST] loadMostRecentPlayer — returning '\(save.apprenticeName)' (florins: \(save.goldFlorins), lastSaved: \(save.lastSaved))")
            return save.apprenticeName
        } catch {
            print("[PERSIST ERROR] loadMostRecentPlayer fetch failed: \(error)")
            return nil
        }
    }

    // MARK: - Building Progress (scoped by currentPlayerName)

    func loadAllBuildingProgress() -> [Int: BuildingProgressRecord] {
        let name = currentPlayerName
        let descriptor = FetchDescriptor<BuildingProgressRecord>(
            predicate: #Predicate { $0.playerName == name }
        )
        do {
            let records = try modelContext.fetch(descriptor)
            print("[PERSIST] loadAllBuildingProgress('\(name)') → \(records.count) record(s)")
            return Dictionary(uniqueKeysWithValues: records.map { ($0.buildingId, $0) })
        } catch {
            print("[PERSIST ERROR] loadAllBuildingProgress('\(name)') failed: \(error)")
            return [:]
        }
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

    // MARK: - Cleanup

    /// Delete any PlayerSave records with empty apprenticeName (stale placeholder saves)
    func deleteEmptyNameSaves() {
        let descriptor = FetchDescriptor<PlayerSave>(
            predicate: #Predicate { $0.apprenticeName == "" }
        )
        do {
            let stale = try modelContext.fetch(descriptor)
            guard !stale.isEmpty else { return }
            print("[PERSIST] Deleting \(stale.count) empty-name PlayerSave(s)")
            for save in stale { modelContext.delete(save) }
            try modelContext.save()
        } catch {
            print("[PERSIST ERROR] deleteEmptyNameSaves failed: \(error)")
        }
    }

    /// Wipe ALL player saves and building progress (full database reset)
    func resetAllData() {
        print("[PERSIST] resetAllData() called — wiping ALL saves")
        do {
            let allSaves = try modelContext.fetch(FetchDescriptor<PlayerSave>())
            print("[PERSIST] resetAllData — deleting \(allSaves.count) PlayerSave(s)")
            for save in allSaves { modelContext.delete(save) }
        } catch {
            print("[PERSIST ERROR] resetAllData fetch PlayerSave: \(error)")
        }
        do {
            let allProgress = try modelContext.fetch(FetchDescriptor<BuildingProgressRecord>())
            print("[PERSIST] resetAllData — deleting \(allProgress.count) BuildingProgressRecord(s)")
            for record in allProgress { modelContext.delete(record) }
        } catch {
            print("[PERSIST ERROR] resetAllData fetch BuildingProgressRecord: \(error)")
        }
        do { try modelContext.save() } catch {
            print("[PERSIST ERROR] resetAllData save: \(error)")
        }
        currentPlayerName = ""
    }

    /// Reset only BuildingProgressRecords (keeps PlayerSave intact — player name, florins, onboarding)
    func resetBuildingProgressOnly() {
        do {
            let allProgress = try modelContext.fetch(FetchDescriptor<BuildingProgressRecord>())
            print("[PERSIST] Clearing \(allProgress.count) building progress records (schema migration)")
            for record in allProgress { modelContext.delete(record) }
            try modelContext.save()
        } catch {
            print("[PERSIST ERROR] resetBuildingProgressOnly: \(error)")
        }
    }

    // MARK: - Save

    func save() {
        do {
            try modelContext.save()
        } catch {
            print("[PERSIST ERROR] modelContext.save() failed: \(error)")
        }
    }
}
