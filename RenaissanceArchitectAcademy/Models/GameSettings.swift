import SwiftUI

/// Language for AI-generated content (NPC dialogue, bird chat, commissions)
enum AppLanguage: String, CaseIterable, Codable {
    case english = "English"
    // Future: case spanish = "Español"
    // Future: case italian = "Italiano"
    // Future: case french = "Français"

    /// Instruction injected into Foundation Models prompts
    var aiInstruction: String {
        switch self {
        case .english:
            return "Respond entirely in English. You may use occasional Italian words naturally (like 'Buongiorno!') but sentences must be in English."
        }
    }

    /// SF Symbol for the language picker
    var icon: String { "globe" }
}

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

    // MARK: - Subscription

    /// Whether the player has an active paid subscription. Stub for now — real StoreKit
    /// wiring lands with SubscriptionManager. Gates premium features like watercolor sketch
    /// rendering (SketchRenderService). Default: false. Toggle via debug UI while testing.
    var isSubscribed: Bool = false {
        didSet { save() }
    }

    // MARK: - Language

    var preferredLanguage: AppLanguage = .english {
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
            : Color(red: 0.93, green: 0.87, blue: 0.78).opacity(0.95)
    }

    /// Dialog/modal background — full opacity for overlays
    var dialogBackground: Color {
        isDarkMode
            ? Color(red: 0.18, green: 0.16, blue: 0.13)
            : Color(red: 0.93, green: 0.87, blue: 0.78)
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
    private static let languageKey = "gameSettings_language"
    private static let subscribedKey = "gameSettings_isSubscribed"

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
        if let raw = UserDefaults.standard.string(forKey: Self.languageKey),
           let lang = AppLanguage(rawValue: raw) {
            preferredLanguage = lang
        }
        isSubscribed = UserDefaults.standard.bool(forKey: Self.subscribedKey)
    }

    private func save() {
        UserDefaults.standard.set(theme.rawValue, forKey: Self.themeKey)
        UserDefaults.standard.set(musicVolume, forKey: Self.musicVolumeKey)
        UserDefaults.standard.set(sfxVolume, forKey: Self.sfxVolumeKey)
        UserDefaults.standard.set(preferredAIProvider.rawValue, forKey: Self.aiProviderKey)
        UserDefaults.standard.set(hasChosenAIProvider, forKey: Self.aiChosenKey)
        UserDefaults.standard.set(preferredLanguage.rawValue, forKey: Self.languageKey)
        UserDefaults.standard.set(isSubscribed, forKey: Self.subscribedKey)
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
