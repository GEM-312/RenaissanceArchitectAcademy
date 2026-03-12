import Foundation

/// Tools that the apprentice needs to collect materials from stations
enum Tool: String, CaseIterable, Identifiable, Codable {
    case pickaxe = "Pickaxe"
    case bucket = "Bucket"
    case ashRake = "Ash Rake"
    case shovel = "Shovel"
    case miningHammer = "Mining Hammer"
    case axe = "Axe"
    case tradePurse = "Trade Purse"
    case mortarAndPestle = "Mortar & Pestle"
    case pitchfork = "Pitchfork"

    var id: String { rawValue }

    /// Asset catalog image name (nil = use emoji fallback)
    var imageName: String? {
        switch self {
        case .pickaxe:         return "ToolPickaxe"
        case .bucket:          return "ToolBucket"
        case .ashRake:         return "ToolAshRake"
        case .shovel:          return "ToolShovel"
        case .miningHammer:    return "ToolMiningHammer"
        case .axe:             return "ToolAxe"
        case .mortarAndPestle: return "ToolMortarAndPestle"
        case .pitchfork:       return "ToolPitchfork"
        case .tradePurse:      return "ToolTradePurse"
        }
    }

    var icon: String {
        switch self {
        case .pickaxe:        return "⛏️"
        case .bucket:         return "🪣"
        case .ashRake:        return "🧹"
        case .shovel:         return "🪏"
        case .miningHammer:   return "🔨"
        case .axe:            return "🪓"
        case .tradePurse:     return "👛"
        case .mortarAndPestle: return "⚗️"
        case .pitchfork:      return "🔱"
        }
    }

    var displayName: String { rawValue }

    var italianName: String {
        switch self {
        case .pickaxe:        return "il Piccone"
        case .bucket:         return "il Secchio"
        case .ashRake:        return "il Rastrello"
        case .shovel:         return "la Pala"
        case .miningHammer:   return "il Martello da Mina"
        case .axe:            return "l'Ascia"
        case .tradePurse:     return "la Borsa"
        case .mortarAndPestle: return "il Mortaio"
        case .pitchfork:      return "il Forcone"
        }
    }

    var educationalText: String {
        switch self {
        case .pickaxe:
            return "Every Roman quarry had a piccone — a heavy iron pick with a wooden handle. Quarrymen carved channels into limestone, then drove wooden wedges soaked in water to split massive blocks."
        case .bucket:
            return "Water carriers (aquarii) hauled buckets from rivers to construction sites. A single bucket of water mixed with lime mortar could bind hundreds of bricks together."
        case .ashRake:
            return "Volcanic ash collectors near Vesuvius raked pozzolana from cooled lava fields. This grey powder was Rome's secret ingredient — it made concrete that hardens underwater."
        case .shovel:
            return "Renaissance brickmakers dug clay with broad-bladed shovels called pale. Good clay had to be aged for a full winter before shaping — frost broke down the lumps."
        case .miningHammer:
            return "Iron miners struck rock faces with heavy hammers, following veins of ore deep underground. A skilled miner could read the colour of rock to find the richest deposits."
        case .axe:
            return "Leonardo recommended felling timber in autumn when sap runs low — drier wood is stronger. A sharp ascia could fell an oak in under an hour."
        case .tradePurse:
            return "Florentine merchants carried silk purses stamped with their guild mark. The Medici banking family invented double-entry bookkeeping to track trade across Europe."
        case .mortarAndPestle:
            return "Apothecaries and painters ground pigments in marble mortars. Lapis lazuli required weeks of grinding and washing to extract pure ultramarine blue — worth more than gold."
        case .pitchfork:
            return "For 10,000 years, humans have built with manure. Adobe bricks, kiln fuel, insulating plaster. Florentine founders mixed letame into bronze casting molds — the organic fibers create micro-channels that let steam escape when 1100°C molten metal is poured in."
        }
    }

    /// Which station requires this tool for collection
    var requiredAtStation: ResourceStationType {
        switch self {
        case .pickaxe:        return .quarry
        case .bucket:         return .river
        case .ashRake:        return .volcano
        case .shovel:         return .clayPit
        case .miningHammer:   return .mine
        case .axe:            return .forest
        case .tradePurse:     return .market
        case .mortarAndPestle: return .pigmentTable
        case .pitchfork:      return .farm
        }
    }

    /// Returns the tool required to collect from a given station, or nil if no tool needed
    static func requiredFor(station: ResourceStationType) -> Tool? {
        // Market never requires a tool (bootstrap — player needs to buy first tool here)
        if station == .market { return nil }
        return allCases.first(where: { $0.requiredAtStation == station })
    }
}

// MARK: - Tool Icon View

import SwiftUI

/// Displays a tool's Midjourney image if available, or falls back to emoji
struct ToolIconView: View {
    let tool: Tool
    var size: CGFloat = 32

    var body: some View {
        if let imageName = tool.imageName {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size, height: size)
        } else {
            Text(tool.icon)
                .font(.system(size: size * 0.75))
        }
    }
}
