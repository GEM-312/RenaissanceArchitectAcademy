import SwiftUI

/// Light vs Dark visual theme for the game
enum AppTheme: String, CaseIterable {
    case light
    case dark

    var displayName: String {
        switch self {
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }
}

/// Persistent game settings — theme, volume, etc.
/// Uses UserDefaults for simple persistence (same pattern as OnboardingState).
@MainActor
@Observable
class GameSettings {

    // MARK: - Theme

    var theme: AppTheme = .dark {
        didSet { save() }
    }

    var isDarkMode: Bool { theme == .dark }

    // MARK: - AI Provider

    var preferredAIProvider: AIProvider = .appleOnDevice {
        didSet { save() }
    }

    var hasChosenAIProvider: Bool = false {
        didSet { save() }
    }

    // MARK: - Audio

    var musicVolume: Double = 0.7 {
        didSet {
            guard isLoaded else { return }
            save()
            SoundManager.shared.updateVolumes()
        }
    }

    var sfxVolume: Double = 0.8 {
        didSet {
            guard isLoaded else { return }
            save()
            SoundManager.shared.updateVolumes()
        }
    }

    // MARK: - Theme Colors (computed, SwiftUI)

    /// Pill label / nav button background color
    var pillBackground: Color {
        isDarkMode
            ? Color(red: 0.18, green: 0.16, blue: 0.13).opacity(0.65)
            : RenaissanceColors.parchment.opacity(0.65)
    }

    /// Pill label / nav button text color
    var pillTextColor: Color {
        isDarkMode ? RenaissanceColors.ochre : RenaissanceColors.sepiaInk
    }

    /// Pill label / nav button border color
    var pillBorderColor: Color {
        isDarkMode
            ? RenaissanceColors.ochre.opacity(0.25)
            : RenaissanceColors.warmBrown.opacity(0.25)
    }

    /// Chevron / secondary icon color
    var pillSecondaryColor: Color {
        isDarkMode
            ? RenaissanceColors.ochre.opacity(0.5)
            : RenaissanceColors.warmBrown.opacity(0.5)
    }

    // MARK: - Card / Panel Backgrounds (SwiftUI)

    /// Card background (avatar card, inventory bar, dialog panels)
    var cardBackground: Color {
        isDarkMode
            ? Color(red: 0.18, green: 0.16, blue: 0.13).opacity(0.92)
            : RenaissanceColors.parchment.opacity(0.92)
    }

    /// Card border color
    var cardBorderColor: Color {
        isDarkMode
            ? RenaissanceColors.ochre.opacity(0.3)
            : RenaissanceColors.warmBrown.opacity(0.3)
    }

    /// Primary text on cards
    var cardTextColor: Color {
        isDarkMode ? RenaissanceColors.ochre : RenaissanceColors.sepiaInk
    }

    /// Item badge background (inventory items)
    var itemBadgeBackground: Color {
        isDarkMode
            ? Color(red: 0.18, green: 0.16, blue: 0.13).opacity(0.8)
            : RenaissanceColors.parchment.opacity(0.8)
    }

    // MARK: - Theme Colors (SpriteKit — platform colors)

    /// SpriteKit pill label background
    var spritePillFillRGBA: (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        isDarkMode
            ? (0.18, 0.16, 0.13, 0.65)
            : (0.961, 0.902, 0.827, 0.65)   // parchment
    }

    /// SpriteKit pill label text color
    var spriteTextColor: Color {
        pillTextColor
    }

    // MARK: - Persistence

    private static let themeKey = "gameSettings_theme"
    private static let musicVolumeKey = "gameSettings_musicVolume"
    private static let sfxVolumeKey = "gameSettings_sfxVolume"
    private static let aiProviderKey = "gameSettings_aiProvider"
    private static let aiChosenKey = "gameSettings_aiChosen"

    /// Shared instance — used by SpriteKit scenes that can't access SwiftUI Environment
    static let shared = GameSettings()

    private var isLoaded = false

    init() {
        load()
        isLoaded = true
    }

    private func load() {
        if let raw = UserDefaults.standard.string(forKey: Self.themeKey),
           let t = AppTheme(rawValue: raw) {
            theme = t
        }
        if UserDefaults.standard.object(forKey: Self.musicVolumeKey) != nil {
            musicVolume = UserDefaults.standard.double(forKey: Self.musicVolumeKey)
        }
        if UserDefaults.standard.object(forKey: Self.sfxVolumeKey) != nil {
            sfxVolume = UserDefaults.standard.double(forKey: Self.sfxVolumeKey)
        }
        if let raw = UserDefaults.standard.string(forKey: Self.aiProviderKey),
           let p = AIProvider(rawValue: raw) {
            preferredAIProvider = p
        }
        hasChosenAIProvider = UserDefaults.standard.bool(forKey: Self.aiChosenKey)
    }

    private func save() {
        UserDefaults.standard.set(theme.rawValue, forKey: Self.themeKey)
        UserDefaults.standard.set(musicVolume, forKey: Self.musicVolumeKey)
        UserDefaults.standard.set(sfxVolume, forKey: Self.sfxVolumeKey)
        UserDefaults.standard.set(preferredAIProvider.rawValue, forKey: Self.aiProviderKey)
        UserDefaults.standard.set(hasChosenAIProvider, forKey: Self.aiChosenKey)
    }
}

// MARK: - SwiftUI Environment

private struct GameSettingsKey: EnvironmentKey {
    @MainActor static let defaultValue = GameSettings.shared
}

extension EnvironmentValues {
    var gameSettings: GameSettings {
        get { self[GameSettingsKey.self] }
        set { self[GameSettingsKey.self] = newValue }
    }
}
