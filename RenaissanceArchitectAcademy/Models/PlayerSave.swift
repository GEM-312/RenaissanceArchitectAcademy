import Foundation
import SwiftData

@Model
final class PlayerSave {
    var hasCompletedOnboarding: Bool = false
    var apprenticeGender: String = "boy"
    var apprenticeName: String = ""
    var goldFlorins: Int = 0
    var earnedScienceBadgesRaw: [String] = []
    var rawMaterialsJSON: Data? = nil
    var craftedMaterialsJSON: Data? = nil
    var lastSaved: Date = Date()

    init() {}

    // MARK: - Computed Accessors

    var earnedScienceBadges: Set<Science> {
        get {
            Set(earnedScienceBadgesRaw.compactMap { Science(rawValue: $0) })
        }
        set {
            earnedScienceBadgesRaw = newValue.map(\.rawValue)
        }
    }

    var rawMaterials: [Material: Int] {
        get {
            guard let data = rawMaterialsJSON,
                  let dict = try? JSONDecoder().decode([String: Int].self, from: data) else { return [:] }
            var result: [Material: Int] = [:]
            for (key, value) in dict {
                if let mat = Material(rawValue: key) { result[mat] = value }
            }
            return result
        }
        set {
            let dict = Dictionary(uniqueKeysWithValues: newValue.map { ($0.key.rawValue, $0.value) })
            rawMaterialsJSON = try? JSONEncoder().encode(dict)
        }
    }

    var craftedMaterials: [CraftedItem: Int] {
        get {
            guard let data = craftedMaterialsJSON,
                  let dict = try? JSONDecoder().decode([String: Int].self, from: data) else { return [:] }
            var result: [CraftedItem: Int] = [:]
            for (key, value) in dict {
                if let item = CraftedItem(rawValue: key) { result[item] = value }
            }
            return result
        }
        set {
            let dict = Dictionary(uniqueKeysWithValues: newValue.map { ($0.key.rawValue, $0.value) })
            craftedMaterialsJSON = try? JSONEncoder().encode(dict)
        }
    }

    var gender: ApprenticeGender {
        get { ApprenticeGender(rawValue: apprenticeGender) ?? .boy }
        set { apprenticeGender = newValue.rawValue }
    }
}
