import Foundation

/// Raw materials for the Workshop crafting system
enum Material: String, CaseIterable, Identifiable, Codable {
    case limestone = "Limestone"
    case volcanicAsh = "Volcanic Ash"
    case sand = "Sand"
    case water = "Water"
    case ironOre = "Iron Ore"
    case clay = "Clay"
    case marbleDust = "Marble Dust"
    case redOchre = "Red Ochre"
    case lapisBlue = "Lapis Blue"
    case verdigrisGreen = "Verdigris Green"
    case timber = "Timber"
    case lead = "Lead"
    case marble = "Marble"
    case silk = "Silk"

    var id: String { rawValue }

    /// Cost in gold florins to collect one unit
    var cost: Int {
        switch self {
        case .water, .sand, .clay:             return 1   // Common
        case .limestone, .timber:              return 2   // Basic building
        case .volcanicAsh, .ironOre, .lead:    return 3   // Specialized
        case .marbleDust, .marble:             return 4   // Premium stone
        case .redOchre, .verdigrisGreen:       return 5   // Pigments
        case .lapisBlue:                       return 8   // Rare pigment
        case .silk:                            return 6   // Imported luxury
        }
    }

    var icon: String {
        switch self {
        case .limestone: return "🪨"
        case .volcanicAsh: return "🌋"
        case .sand: return "🏖️"
        case .water: return "💧"
        case .ironOre: return "⛏️"
        case .clay: return "🟤"
        case .marbleDust: return "⚪"
        case .redOchre: return "🔴"
        case .lapisBlue: return "🔵"
        case .verdigrisGreen: return "🟢"
        case .timber: return "🪵"
        case .lead: return "🔩"
        case .marble: return "🏛️"
        case .silk: return "🧵"
        }
    }
}
