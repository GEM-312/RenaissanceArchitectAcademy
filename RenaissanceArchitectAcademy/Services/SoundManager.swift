import SwiftUI
import Subsonic

/// Manages all sound effects and music for the Renaissance Architect Academy
@MainActor
class SoundManager: ObservableObject {
    static let shared = SoundManager()

    @Published var isMuted: Bool = false
    @Published var volume: Double = 0.8

    private init() {}

    // MARK: - Sound Effect Names
    enum Sound: String {
        // UI Sounds
        case buttonTap = "button_tap"
        case menuOpen = "menu_open"
        case menuClose = "menu_close"

        // Building Sounds
        case buildingSelect = "building_select"
        case buildingComplete = "building_complete"
        case constructionStart = "construction_start"

        // Challenge Sounds
        case challengeStart = "challenge_start"
        case challengeSuccess = "challenge_success"
        case challengeFail = "challenge_fail"

        // Ambient
        case quillWriting = "quill_writing"
        case pageFlip = "page_flip"
        case sealStamp = "seal_stamp"

        var filename: String {
            "\(rawValue).mp3"
        }
    }

    // MARK: - Play Sound
    /// Play a sound effect
    func play(_ sound: Sound) {
        guard !isMuted else { return }
        // Subsonic will look for the file in the bundle
        // For now, this is a placeholder - add actual sound files to Resources
        // play(sound: sound.filename)
    }

    /// Play a sound with a specific volume
    func play(_ sound: Sound, volume: Double) {
        guard !isMuted else { return }
        // play(sound: sound.filename, volume: volume)
    }

    // MARK: - Controls
    func toggleMute() {
        isMuted.toggle()
    }

    func setVolume(_ newVolume: Double) {
        volume = max(0, min(1, newVolume))
    }
}

// MARK: - SwiftUI View Extension for Easy Sound Playing
extension View {
    /// Play a sound when a condition becomes true
    func playSound(_ sound: SoundManager.Sound, when condition: Bool) -> some View {
        self.onChange(of: condition) { _, newValue in
            if newValue {
                Task { @MainActor in
                    SoundManager.shared.play(sound)
                }
            }
        }
    }

    /// Play a sound on tap
    func withTapSound(_ sound: SoundManager.Sound = .buttonTap) -> some View {
        self.simultaneousGesture(
            TapGesture().onEnded {
                Task { @MainActor in
                    SoundManager.shared.play(sound)
                }
            }
        )
    }
}
