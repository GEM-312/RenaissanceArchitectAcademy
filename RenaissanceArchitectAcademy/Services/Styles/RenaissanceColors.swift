import SwiftUI

/// Renaissance color palette - Leonardo's Notebook aesthetic
/// Watercolor + Blueprint fusion style
enum RenaissanceColors {
    // MARK: - Primary Palette

    /// Parchment background: #F5E5D3 (aged paper texture)
    static let parchment = Color(red: 0.961, green: 0.898, blue: 0.827)

    /// Sepia ink for text: #4A4035
    static let sepiaInk = Color(red: 0.290, green: 0.251, blue: 0.208)

    /// Renaissance blue accent: #5B8FA3 (tiles, water)
    static let renaissanceBlue = Color(red: 0.357, green: 0.561, blue: 0.639)

    /// Terracotta for roofs/buildings: #D3876B
    static let terracotta = Color(red: 0.827, green: 0.529, blue: 0.42)

    /// Ochre for stone walls/highlights: #C9A76A
    static let ochre = Color(red: 0.788, green: 0.655, blue: 0.416)

    /// Sage green for completion/nature: #7A9B76
    static let sageGreen = Color(red: 0.478, green: 0.608, blue: 0.463)

    // MARK: - Accent Palette

    /// Deep teal for astronomy/water: #2B7A8B
    static let deepTeal = Color(red: 0.169, green: 0.478, blue: 0.545)

    /// Warm brown for wood accents: #8B6F47
    static let warmBrown = Color(red: 0.545, green: 0.435, blue: 0.278)

    /// Stone gray for materials: #9F9F9B
    static let stoneGray = Color(red: 0.624, green: 0.624, blue: 0.608)

    /// Icon ochre for nav buttons: #B7953E — warm golden ochre
    static let iconOchre = Color(red: 0.718, green: 0.584, blue: 0.243)

    /// Garden green for nature: #6B8D5A — distinct from sageGreen since 2026-10-07
    static let gardenGreen = Color(red: 0.42, green: 0.553, blue: 0.353)

    // MARK: - Special Effects

    /// Gold success glow: #D9A520
    static let goldSuccess = Color(red: 0.851, green: 0.647, blue: 0.125)

    /// Error red for incorrect: #CD5C5C
    static let errorRed = Color(red: 0.804, green: 0.361, blue: 0.361)

    /// Blueprint blue for technical overlays: #4169E1
    static let blueprintBlue = Color(red: 0.255, green: 0.412, blue: 0.882)

    /// Highlight amber: #D3A74B
    static let highlightAmber = Color(red: 0.827, green: 0.655, blue: 0.294)

    /// Furnace orange for fire/heat actions: #D3763A
    static let furnaceOrange = Color(red: 0.827, green: 0.463, blue: 0.227)

    /// Candle glow — pale warm yellow for candlelight, lanterns, lamp wicks.
    /// More cream than `goldSuccess`, less saturated than `highlightAmber`.
    static let candleGlow = Color(red: 0.95, green: 0.85, blue: 0.45)

    /// Light parchment for card fills (slightly warmer): #F9EFE3
    static let parchmentLight = Color(red: 0.976, green: 0.937, blue: 0.89)

    /// Card background fills for dark/light theme modes. Previously declared
    /// as private statics in `GameSettings` — surfacing here so any view can
    /// reference the same value.
    static let darkCardBg  = Color(red: 0.18, green: 0.16, blue: 0.13)
    static let lightCardBg = Color(red: 0.93, green: 0.87, blue: 0.78)

    /// Bright lemon-yellow for notebook stroke pen tool. Brighter and less
    /// amber than `candleGlow` (which has more red/green and less blue).
    static let notebookYellow = Color(red: 1.0, green: 0.85, blue: 0.3)

    // MARK: - Material Palette (cross-file shared tokens)

    /// Roman volcanic ash / pozzolana red. Used in Pantheon, Aqueduct, Roman Baths, Harbor.
    static let pozzolanaRed = Color(red: 0.65, green: 0.40, blue: 0.30)

    /// Leaf / completion-check green. Used in Botanical Garden, Anatomy, Printing Press, Arsenal.
    static let leafGreen = Color(red: 0.30, green: 0.58, blue: 0.32)

    /// Paper / silk cream. Used in Botanical Garden, Duomo, Printing Press, Flying Machine.
    static let paperCream = Color(red: 0.95, green: 0.92, blue: 0.85)

    /// Marble white — slightly cooler than paperCream. Used in Quarry, Interactive Visual Helpers.
    static let marbleWhite = Color(red: 0.92, green: 0.90, blue: 0.88)

    /// Lime mortar — slightly warmer than marbleWhite. Used in Insula, Pantheon.
    static let limeMortar = Color(red: 0.92, green: 0.90, blue: 0.85)

    /// Warm orange — sunset / fire glow. Used in Insula, Roman Baths.
    static let warmOrange = Color(red: 0.90, green: 0.65, blue: 0.35)

    /// Forge orange — hot metal / molten. Used in Printing Press, Leonardo Workshop.
    static let forgeOrange = Color(red: 0.90, green: 0.50, blue: 0.15)

    /// Lead gray — pipes, lead roofing. Used in Duomo, Printing Press, Vatican Observatory.
    static let leadGray = Color(red: 0.55, green: 0.55, blue: 0.52)

    /// Travertine / sand beige. Used in Roman Roads, Colosseum.
    static let travertineBeige = Color(red: 0.82, green: 0.76, blue: 0.66)

    /// Mortar tan. Used in Colosseum, Aqueduct.
    static let mortarTan = Color(red: 0.80, green: 0.75, blue: 0.65)

    /// Water channel blue — aqueduct flow, baths, level indicators. Used in Card Visuals, Helpers.
    static let waterBlue = Color(red: 0.35, green: 0.55, blue: 0.75)

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

    // MARK: - Standardized Overlay Dimming

    /// Modal/overlay background dimming — uniform across all views
    static let overlayDimming = Color.black.opacity(0.45)
}

// MARK: - Standardized Border System (theme-aware)

extension View {
    /// Standard card border — theme-aware, subtle, for content cards and sections
    @MainActor
    func borderCard(radius: CGFloat = 14) -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: radius)
                .stroke(GameSettings.shared.cardBorderColor, lineWidth: 1)
        )
    }

    /// Accent card border — theme-aware, medium emphasis, for interactive/highlighted cards
    @MainActor
    func borderAccent(radius: CGFloat = 14) -> some View {
        let dark = GameSettings.shared.isDarkMode
        return self.overlay(
            RoundedRectangle(cornerRadius: radius)
                .stroke(
                    dark ? RenaissanceColors.ochre.opacity(0.4)
                         : RenaissanceColors.warmBrown.opacity(0.4),
                    lineWidth: 1.5
                )
        )
    }

    /// Modal border — theme-aware, prominent, for overlays and dialogue boxes
    @MainActor
    func borderModal(radius: CGFloat = 16) -> some View {
        let dark = GameSettings.shared.isDarkMode
        return self.overlay(
            RoundedRectangle(cornerRadius: radius)
                .stroke(
                    dark ? RenaissanceColors.ochre.opacity(0.4)
                         : RenaissanceColors.warmBrown.opacity(0.4),
                    lineWidth: 2
                )
        )
    }

    /// Workshop border — warm brown, for crafting/workshop context cards
    @MainActor
    func borderWorkshop(radius: CGFloat = 16) -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: radius)
                .stroke(GameSettings.shared.cardBorderColor, lineWidth: 1)
        )
    }
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
