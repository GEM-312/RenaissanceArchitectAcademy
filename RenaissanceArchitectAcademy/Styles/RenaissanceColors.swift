import SwiftUI

/// Renaissance color palette - Leonardo's Notebook aesthetic
/// Watercolor + Blueprint fusion style
enum RenaissanceColors {
    // MARK: - Primary Palette

    /// Parchment background: #F5E6D3 (aged paper texture)
    static let parchment = Color(red: 0.961, green: 0.902, blue: 0.827)

    /// Sepia ink for text: #4A4035
    static let sepiaInk = Color(red: 0.290, green: 0.251, blue: 0.208)

    /// Renaissance blue accent: #5B8FA3 (tiles, water)
    static let renaissanceBlue = Color(red: 0.357, green: 0.561, blue: 0.639)

    /// Terracotta for roofs/buildings: #D4876B
    static let terracotta = Color(red: 0.831, green: 0.529, blue: 0.420)

    /// Ochre for stone walls/highlights: #C9A86A
    static let ochre = Color(red: 0.788, green: 0.659, blue: 0.416)

    /// Sage green for completion/nature: #7A9B76
    static let sageGreen = Color(red: 0.478, green: 0.608, blue: 0.463)

    // MARK: - Accent Palette

    /// Deep teal for astronomy/water: #2B7A8C
    static let deepTeal = Color(red: 0.169, green: 0.478, blue: 0.549)

    /// Warm brown for wood accents: #8B6F47
    static let warmBrown = Color(red: 0.545, green: 0.435, blue: 0.278)

    /// Stone gray for materials: #A39D93
    static let stoneGray = Color(red: 0.639, green: 0.616, blue: 0.576)

    /// Garden green for nature: #7A9B76 (same as sageGreen)
    static let gardenGreen = Color(red: 0.478, green: 0.608, blue: 0.463)

    // MARK: - Special Effects

    /// Gold success glow: #DAA520
    static let goldSuccess = Color(red: 0.855, green: 0.647, blue: 0.125)

    /// Error red for incorrect: #CD5C5C
    static let errorRed = Color(red: 0.804, green: 0.361, blue: 0.361)

    /// Blueprint blue for technical overlays: #4169E1
    static let blueprintBlue = Color(red: 0.255, green: 0.412, blue: 0.882)

    /// Highlight amber: #FFBF00
    static let highlightAmber = Color(red: 1.0, green: 0.749, blue: 0.0)

    // MARK: - Gradients

    /// Parchment gradient for backgrounds
    static let parchmentGradient = LinearGradient(
        colors: [
            parchment,
            Color(red: 0.941, green: 0.878, blue: 0.788) // slightly darker
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    /// Golden glow gradient for success states
    static let goldenGlow = RadialGradient(
        colors: [
            goldSuccess.opacity(0.6),
            goldSuccess.opacity(0)
        ],
        center: .center,
        startRadius: 0,
        endRadius: 100
    )

    /// Blueprint overlay gradient
    static let blueprintOverlay = LinearGradient(
        colors: [
            blueprintBlue.opacity(0.1),
            blueprintBlue.opacity(0.05)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Color Extensions for Science Categories
extension RenaissanceColors {
    /// Get color for a specific science category
    static func color(for science: Science) -> Color {
        switch science {
        case .mathematics: return ochre
        case .physics: return renaissanceBlue
        case .chemistry: return sageGreen
        case .geometry: return terracotta
        case .engineering: return warmBrown
        case .astronomy: return deepTeal
        case .biology: return gardenGreen
        case .geology: return stoneGray
        case .optics: return highlightAmber
        case .hydraulics: return renaissanceBlue
        case .acoustics: return terracotta
        case .materials: return warmBrown
        case .architecture: return ochre
        }
    }
}
