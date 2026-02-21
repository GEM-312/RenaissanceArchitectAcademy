import SwiftUI

/// Navigation destinations used by GameTopBarView and ContentView
enum SidebarDestination: Hashable {
    case cityMap        // SpriteKit isometric city view
    case allBuildings   // Grid view of all buildings
    case era(Era)
    case profile
    case workshop       // Crafting mini-game
    case forest         // Italian forest exploration
    case knowledgeTests // Quiz challenges
    case notebook(Int)  // Building notebook by plot ID
}

// Add iconName to Era
extension Era {
    var iconName: String {
        switch self {
        case .ancientRome: return "building.columns"
        case .renaissance: return "paintpalette"
        }
    }
}
