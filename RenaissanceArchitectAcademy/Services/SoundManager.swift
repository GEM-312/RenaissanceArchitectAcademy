import SwiftUI
import AVFoundation

/// Manages all sound effects and music for the Renaissance Architect Academy
/// Uses AVFoundation for audio playback
@MainActor
class SoundManager: ObservableObject {
    static let shared = SoundManager()

    @Published var isMuted: Bool = false
    @Published var volume: Float = 0.8

    private var audioPlayers: [String: AVAudioPlayer] = [:]

    private init() {
        // Configure audio session for mixing with other apps
        #if os(iOS)
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
        }
        #endif
    }

    // MARK: - Sound Effect Names
    enum Sound: String, CaseIterable {
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

    // MARK: - Preload Sounds
    /// Preload a sound for faster playback
    func preload(_ sound: Sound) {
        guard let url = Bundle.main.url(forResource: sound.rawValue, withExtension: "mp3") else {
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            player.volume = volume
            audioPlayers[sound.rawValue] = player
        } catch {
            print("Failed to preload sound \(sound.rawValue): \(error)")
        }
    }

    /// Preload all sounds
    func preloadAll() {
        Sound.allCases.forEach { preload($0) }
    }

    // MARK: - Play Sound
    /// Play a sound effect
    func play(_ sound: Sound) {
        guard !isMuted else { return }

        // Check if already preloaded
        if let player = audioPlayers[sound.rawValue] {
            player.currentTime = 0
            player.volume = volume
            player.play()
            return
        }

        // Load and play on demand
        guard let url = Bundle.main.url(forResource: sound.rawValue, withExtension: "mp3") else {
            print("Sound file not found: \(sound.filename)")
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = volume
            player.play()
            audioPlayers[sound.rawValue] = player
        } catch {
            print("Failed to play sound \(sound.rawValue): \(error)")
        }
    }

    // MARK: - Controls
    func toggleMute() {
        isMuted.toggle()
    }

    func setVolume(_ newVolume: Float) {
        volume = max(0, min(1, newVolume))
        // Update all existing players
        audioPlayers.values.forEach { $0.volume = volume }
    }

    func stopAll() {
        audioPlayers.values.forEach { $0.stop() }
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

    /// Play a sound on tap (use with buttons)
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
