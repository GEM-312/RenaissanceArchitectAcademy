import Foundation

/// Items that can be crafted in the Workshop from raw materials
enum CraftedItem: String, CaseIterable, Identifiable, Codable {
    case limeMortar = "Lime Mortar"
    case romanConcrete = "Roman Concrete"
    case terracottaTiles = "Terracotta Tiles"
    case redFrescoPigment = "Red Fresco Pigment"
    case blueFrescoPigment = "Blue Fresco Pigment"
    case bronzeFittings = "Bronze Fittings"
    case timberBeams = "Timber Beams"
    case glassPanes = "Glass Panes"
    case stainedGlass = "Stained Glass"
    case marbleSlabs = "Marble Slabs"
    case leadSheeting = "Lead Sheeting"
    case silkFabric = "Silk Fabric"
    case carvedWood = "Carved Wood"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .limeMortar: return "🏺"
        case .romanConcrete: return "🧱"
        case .terracottaTiles: return "🟫"
        case .redFrescoPigment: return "🎨"
        case .blueFrescoPigment: return "🖌️"
        case .bronzeFittings: return "⚙️"
        case .timberBeams: return "🪵"
        case .glassPanes: return "🪟"
        case .stainedGlass: return "🌈"
        case .marbleSlabs: return "⬜"
        case .leadSheeting: return "📄"
        case .silkFabric: return "🧶"
        case .carvedWood: return "🪑"
        }
    }
}
