import Foundation
import SwiftUI

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
    case cinnabarFrescoPigment = "Cinnabar Fresco Pigment"
    case saffronIllumination = "Saffron Illumination"
    case greenFrescoPigment = "Green Fresco Pigment"
    case rawBronze = "Raw Bronze"
    case goldLeaf = "Gold Leaf"
    case fumigationIncense = "Fumigation Incense"
    case castingMold = "Casting Mold"
    case temperaPaint = "Tempera Paint"
    case apprenticeSeal = "Apprentice Seal"
    case architectSeal = "Architect Seal"
    case masterSeal = "Master Seal"

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
        case .cinnabarFrescoPigment: return "🖼️"
        case .saffronIllumination: return "📜"
        case .greenFrescoPigment: return "🎨"
        case .rawBronze: return "🥉"
        case .goldLeaf: return "✨"
        case .fumigationIncense: return "🪔"
        case .castingMold: return "🫕"
        case .temperaPaint: return "🎭"
        case .apprenticeSeal: return "🔰"
        case .architectSeal: return "🏛️"
        case .masterSeal: return "🏆"
        }
    }

    /// Asset catalog image name — nil if no image yet
    var imageName: String? {
        switch self {
        case .limeMortar:             return "CraftedLimeMortar"
        case .romanConcrete:          return "CraftedRomanConcrete"
        case .terracottaTiles:        return "CraftedTerracottaTiles"
        case .bronzeFittings:         return "MaterialBronze"
        case .rawBronze:              return "MaterialRawBronze"
        case .castingMold:            return "MaterialCastingMold"
        case .temperaPaint:           return "MaterialTemperaPaint"
        case .redFrescoPigment:       return "PigmentRedOchre"
        case .blueFrescoPigment:      return "PigmentLapisLazuli"
        case .cinnabarFrescoPigment:  return "PigmentVermillion"
        case .saffronIllumination:    return "PigmentSienna"
        case .greenFrescoPigment:     return "PigmentVerdigris"
        case .fumigationIncense:      return "CraftedFumigation"
        case .goldLeaf:               return "CraftedGoldLeaf"
        case .timberBeams:            return "CraftedTimberBeams"
        default:                      return nil
        }
    }
}

// MARK: - Crafted Item Icon View (Midjourney image or emoji fallback)

struct CraftedItemIconView: View {
    let item: CraftedItem
    var size: CGFloat = 28

    var body: some View {
        if let name = item.imageName, imageExists(name) {
            Image(name)
                .resizable()
                .scaledToFit()
                .frame(height: size)
        } else {
            Text(item.icon)
                .font(.system(size: size * 0.7))
        }
    }

    private func imageExists(_ name: String) -> Bool {
        #if os(iOS)
        return UIImage(named: name) != nil
        #else
        return NSImage(named: name) != nil
        #endif
    }
}
