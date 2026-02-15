import SwiftUI

/// Navigation destinations used by GameTopBarView and ContentView
enum SidebarDestination: Hashable {
    case cityMap        // SpriteKit isometric city view
    case allBuildings   // Grid view of all buildings
    case era(Era)
    case profile
    case workshop       // Crafting mini-game
    case knowledgeTests // Quiz challenges
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
