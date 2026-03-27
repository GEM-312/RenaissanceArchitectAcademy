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

    // MARK: - Image Generation (Foundation Models / Image Playground)

    /// Cache key for generated sketch-style image
    var imageCacheKey: String { "material_v4_\(self)" }

    /// Image Playground prompt — describes the material for sketch-style generation.
    /// Style prefix is added by ImageGenerationService automatically.
    var imagePrompt: String {
        switch self {
        case .limestone:        return "A rough-cut block of pale cream limestone showing layered sedimentary texture"
        case .volcanicAsh:      return "A pile of dark grey volcanic ash with visible mineral crystals and pumice fragments"
        case .sand:             return "A mound of fine golden river sand with small pebbles mixed in"
        case .water:            return "A clay amphora pouring clear water into a Roman stone basin"
        case .ironOre:          return "A chunk of rusty reddish-brown iron ore with metallic glints"
        case .clay:             return "A lump of wet reddish-brown terracotta clay on a potter's wheel, soft and malleable"
        case .marbleDust:       return "A small pile of fine white marble powder next to a marble fragment"
        case .redOchre:         return "A chunk of deep red ochre mineral pigment with earthy texture"
        case .lapisBlue:        return "A polished piece of deep blue lapis lazuli stone with gold pyrite flecks"
        case .verdigrisGreen:   return "Green verdigris crystals forming on a corroded copper plate"
        case .timber:           return "A stack of freshly cut oak timber planks with visible wood grain"
        case .lead:             return "A rolled sheet of dull grey lead metal with a Roman plumber's stamp"
        case .marble:           return "A polished block of white Carrara marble with subtle grey veins"
        case .silk:             return "A bolt of shimmering silk fabric draped over a merchant's table"
        case .cinnabar:         return "A bright vermillion red cinnabar mineral crystal cluster"
        case .saffron:          return "Dried saffron crocus threads in a small ceramic bowl, deep orange-red"
        case .groundRedOchre:   return "Fine red ochre powder in a stone mortar, ready for paint mixing"
        case .groundLapisBlue:  return "Brilliant ultramarine blue powder ground from lapis lazuli in a mortar"
        case .groundVerdigris:  return "Fine green verdigris powder in a ceramic dish"
        case .groundCinnabar:   return "Bright red ground cinnabar powder in a small glass vial"
        case .groundSaffron:    return "Fine golden-yellow saffron powder in a ceramic cup"
        case .sulfur:           return "Bright yellow sulfur crystals in a volcanic rock crevice"
        case .copper:           return "A rough chunk of native copper with greenish patina on edges"
        case .gold:             return "A small gold ingot stamped with a Florentine lily mark"
        case .herbs:            return "A bundle of dried medicinal herbs — rosemary, sage, and wormwood tied together"
        case .letame:           return "A wooden cart of dark composted manure for Renaissance farming"
        case .charredOxHorn:    return "A blackened piece of charred ox horn used for casting molds"
        case .beeswax:          return "A golden block of beeswax with honeycomb texture impression"
        case .eggs:             return "Three brown eggs in a straw nest, used for tempera paint binding"
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
