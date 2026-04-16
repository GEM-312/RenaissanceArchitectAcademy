import Foundation
import SwiftUI

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
    case cinnabar = "Cinnabar"
    case saffron = "Saffron"
    case groundRedOchre = "Ground Red Ochre"
    case groundLapisBlue = "Ground Lapis Blue"
    case groundVerdigris = "Ground Verdigris"
    case groundCinnabar = "Ground Cinnabar"
    case groundSaffron = "Ground Saffron"
    case sulfur = "Sulfur"
    case copper = "Copper"
    case gold = "Gold"
    case herbs = "Medicinal Herbs"
    case letame = "Letame"
    case charredOxHorn = "Charred Ox Horn"
    case beeswax = "Beeswax"
    case eggs = "Eggs"

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
        case .cinnabar:                        return 6   // Volcanic mineral pigment
        case .saffron:                         return 4   // Crocus meadow flowers
        case .groundRedOchre, .groundVerdigris,
             .groundCinnabar, .groundSaffron:  return 0   // Output of grinding
        case .groundLapisBlue:                 return 0   // Output of grinding
        case .sulfur:                          return 4   // Volcanic mineral
        case .copper:                          return 5   // Mined metal
        case .gold:                            return 10  // Luxury import
        case .herbs:                           return 3   // Forest medicinal plants
        case .letame:                          return 2   // Farm — cheap and plentiful
        case .charredOxHorn:                   return 3   // Farm — burned keratin for molds
        case .beeswax:                         return 4   // Farm — for lost-wax casting
        case .eggs:                            return 2   // Farm — for tempera paint binding
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
        case .cinnabar: return "🔻"
        case .saffron: return "🌸"
        case .groundRedOchre: return "🟠"
        case .groundLapisBlue: return "💎"
        case .groundVerdigris: return "🫒"
        case .groundCinnabar: return "❤️"
        case .groundSaffron: return "🌕"
        case .sulfur: return "🔥"
        case .copper: return "🪙"
        case .gold: return "👑"
        case .herbs: return "🌿"
        case .letame: return "💩"
        case .charredOxHorn: return "🦴"
        case .beeswax: return "🐝"
        case .eggs: return "🥚"
        }
    }

    /// Asset catalog image name (Midjourney art) — nil if no image yet
    var imageName: String? {
        switch self {
        case .limestone:                        return "MaterialLimestone"
        case .volcanicAsh:                      return "MaterialVolcanicAsh"
        case .ironOre:                          return "MaterialIronOre"
        case .clay:                             return "MaterialClay"
        case .timber:                           return "MaterialTimber"
        case .lead:                             return "MaterialLead"
        case .marble:                           return "MaterialMarble"
        case .marbleDust:                       return "MaterialQuicklime"
        case .sulfur:                           return "MaterialSulfur"
        case .copper:                           return "MaterialCopper"
        case .gold:                             return "MaterialGold"
        case .herbs:                            return "MaterialHerbs"
        case .letame:                           return "MaterialLetame"
        case .charredOxHorn:                    return "MaterialOxHorn"
        case .beeswax:                          return "MaterialBeeswax"
        case .redOchre, .groundRedOchre:        return "PigmentRedOchre"
        case .lapisBlue, .groundLapisBlue:      return "PigmentLapisLazuli"
        case .verdigrisGreen, .groundVerdigris: return "PigmentVerdigris"
        case .cinnabar, .groundCinnabar:        return "PigmentVermillion"
        case .saffron, .groundSaffron:          return "PigmentSienna"
        case .sand:                             return "MaterialSand"
        case .water:                            return "MaterialWater"
        case .silk:                             return "MaterialSilk"
        case .eggs:                             return "MaterialEggs"
        }
    }

    /// Whether this is a raw pigment that can be ground at the Pigment Table
    var isRawPigment: Bool {
        switch self {
        case .redOchre, .lapisBlue, .verdigrisGreen, .cinnabar, .saffron:
            return true
        default:
            return false
        }
    }

    /// Whether this is a ground pigment (output of grinding)
    var isGroundPigment: Bool {
        switch self {
        case .groundRedOchre, .groundLapisBlue, .groundVerdigris, .groundCinnabar, .groundSaffron:
            return true
        default:
            return false
        }
    }
}

// MARK: - Material Icon View (Midjourney image or emoji fallback)

/// Shows Midjourney material art if available, otherwise the emoji icon
struct MaterialIconView: View {
    let material: Material
    var size: CGFloat = 28

    var body: some View {
        if let name = material.imageName {
            Image(name)
                .resizable()
                .scaledToFit()
                .frame(height: size)
        } else {
            Text(material.icon)
                .font(.system(size: size * 0.7))
        }
    }

}
