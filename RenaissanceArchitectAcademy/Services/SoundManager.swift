import SwiftUI
import AVFoundation

/// Manages all sound effects, background music, and ambient audio
/// Single source of truth for audio — replaces Subsonic dependency
@MainActor
class SoundManager: ObservableObject {
    static let shared = SoundManager()

    @Published var isMuted: Bool = false

    // MARK: - Players

    /// Cached SFX players (keyed by filename)
    private var sfxPlayers: [String: AVAudioPlayer] = [:]

    /// Background music (loops, crossfades between scenes)
    private var musicPlayer: AVAudioPlayer?

    /// Ambient scene sound (loops alongside music)
    private var ambientPlayer: AVAudioPlayer?

    // MARK: - Init

    private init() {
        #if os(iOS)
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
        }
        #endif
    }

    // MARK: - Sound Effects

    enum Sound: String, CaseIterable {
        // Building & Progress
        case buildingComplete = "building_complete"
        case buildingTap = "building_tap"
        case sealStamp = "seal_stamp"
        case levelUp = "level_up"

        // Cards
        case cardsAppear = "cards_appear"
        case cardFlip = "card_flip"
        case cardComplete = "card_complete"

        // Challenge Feedback
        case correctChime = "correct_chime"
        case wrongBuzz = "wrong_buzz"
        case hangmanWrong = "hangman_wrong"

        // UI
        case tapSoft = "tap_soft"
        case waterPlop = "water_plop"
        case pageFlip = "page_flip"
        case overlayOpen = "overlay_open"
        case overlayClose = "overlay_close"
        case pageTurn = "page_turn"
        case sceneTransition = "scene_transition"

        // Station Collection
        case stoneHit = "stone_hit"
        case clayDig = "clay_dig"
        case miningHammer = "mining_hammer"
        case timberChop = "timber_chop"
        case farmCollect = "farm_collect"
        case herbPick = "herb_pick"
        case pigmentGrind = "pigment_grind"
        case materialPickup = "material_pickup"

        // Crafting
        case workbenchMix = "workbench_mix"
        case furnaceWoosh = "furnace_woosh"
        case furnaceCrackling = "furnace_crackling"
        case anvilStrike = "anvil_strike"
        case craftingComplete = "crafting_complete"

        // Rewards
        case florinsEarned = "florins_earned"

        // Walking (wav format)
        case footstep = "footstep"

        /// File extension — new station/crafting/UI sounds are wav, originals are mp3
        var ext: String {
            switch self {
            case .footstep, .sealStamp, .levelUp,
                 .overlayOpen, .overlayClose, .pageTurn, .sceneTransition,
                 .stoneHit, .clayDig, .miningHammer, .timberChop,
                 .farmCollect, .herbPick, .pigmentGrind, .materialPickup,
                 .workbenchMix, .furnaceWoosh, .furnaceCrackling, .anvilStrike,
                 .craftingComplete, .florinsEarned:
                return "wav"
            default: return "mp3"
            }
        }
    }

    /// Play a one-shot sound effect (+ paired haptic if applicable)
    func play(_ sound: Sound) {
        guard !isMuted else { return }

        // Paired haptics — automatic based on sound type
        switch sound {
        case .correctChime:  HapticsManager.shared.play(.correctAnswer)
        case .wrongBuzz, .hangmanWrong: HapticsManager.shared.play(.wrongAnswer)
        case .cardFlip:      HapticsManager.shared.play(.cardFlip)
        case .cardComplete:  HapticsManager.shared.play(.craftingComplete)
        case .buildingComplete, .levelUp: HapticsManager.shared.play(.buildingComplete)
        case .buildingTap, .tapSoft: HapticsManager.shared.play(.buttonTap)
        case .craftingComplete: HapticsManager.shared.play(.craftingComplete)
        case .stoneHit, .miningHammer, .anvilStrike: HapticsManager.shared.play(.materialCollected)
        case .materialPickup, .farmCollect, .herbPick, .timberChop, .clayDig, .pigmentGrind: HapticsManager.shared.play(.materialCollected)
        case .florinsEarned: HapticsManager.shared.play(.correctAnswer)
        default: break
        }

        let sfxVol = Float(GameSettings.shared.sfxVolume)

        // Reuse cached player
        if let player = sfxPlayers[sound.rawValue] {
            player.currentTime = 0
            player.volume = sfxVol
            player.play()
            return
        }

        // Load on demand
        guard let url = Bundle.main.url(forResource: sound.rawValue, withExtension: sound.ext) else {
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = sfxVol
            player.play()
            sfxPlayers[sound.rawValue] = player
        } catch {
            print("SoundManager: failed to play \(sound.rawValue): \(error)")
        }
    }

    /// Preload a sound for instant playback
    func preload(_ sound: Sound) {
        guard sfxPlayers[sound.rawValue] == nil else { return }
        guard let url = Bundle.main.url(forResource: sound.rawValue, withExtension: sound.ext) else { return }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            sfxPlayers[sound.rawValue] = player
        } catch {}
    }

    // MARK: - Background Music

    enum MusicTrack: String {
        case mainMenu = "music_main_menu"
        case cityMap = "music_city"
        case workshop = "music_workshop"
        case forest = "music_forest"
        case craftingRoom = "music_crafting"
    }

    /// Currently playing music track (to avoid restarting the same track)
    private var currentMusic: MusicTrack?

    /// Play looping background music with optional crossfade
    func playMusic(_ track: MusicTrack, fadeDuration: TimeInterval = 1.0) {
        guard !isMuted else { return }
        guard track != currentMusic else { return }

        let musicVol = Float(GameSettings.shared.musicVolume)

        guard let url = Bundle.main.url(forResource: track.rawValue, withExtension: "mp3") else {
            // Track file doesn't exist yet — silently skip
            return
        }

        // Fade out current music
        if let current = musicPlayer, current.isPlaying {
            fadeOut(player: current, duration: fadeDuration)
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = -1  // Loop forever
            player.volume = 0
            player.play()
            currentMusic = track

            // Fade in
            fadeIn(player: player, targetVolume: musicVol, duration: fadeDuration)
            musicPlayer = player
        } catch {
            print("SoundManager: failed to play music \(track.rawValue): \(error)")
        }
    }

    /// Stop background music with fade
    func stopMusic(fadeDuration: TimeInterval = 1.0) {
        guard let player = musicPlayer, player.isPlaying else { return }
        fadeOut(player: player, duration: fadeDuration)
        currentMusic = nil
    }

    // MARK: - Ambient Sounds

    enum AmbientSound: String {
        case cityAmbient = "ambient_city"
        case workshopAmbient = "ambient_workshop"
        case forestAmbient = "ambient_forest"
        case craftingAmbient = "ambient_crafting"
    }

    private var currentAmbient: AmbientSound?

    /// Play looping ambient sound (alongside music)
    func playAmbient(_ ambient: AmbientSound, fadeDuration: TimeInterval = 0.5) {
        guard !isMuted else { return }
        guard ambient != currentAmbient else { return }

        let ambientVol = Float(GameSettings.shared.sfxVolume) * 0.6  // Ambient is quieter than SFX

        guard let url = Bundle.main.url(forResource: ambient.rawValue, withExtension: "mp3") else {
            return
        }

        if let current = ambientPlayer, current.isPlaying {
            fadeOut(player: current, duration: fadeDuration)
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = -1
            player.volume = 0
            player.play()
            currentAmbient = ambient

            fadeIn(player: player, targetVolume: ambientVol, duration: fadeDuration)
            ambientPlayer = player
        } catch {
            print("SoundManager: failed to play ambient \(ambient.rawValue): \(error)")
        }
    }

    func stopAmbient(fadeDuration: TimeInterval = 0.5) {
        guard let player = ambientPlayer, player.isPlaying else { return }
        fadeOut(player: player, duration: fadeDuration)
        currentAmbient = nil
    }

    // MARK: - Volume Control

    /// Called when GameSettings volume changes — updates all active players
    func updateVolumes() {
        let musicVol = Float(GameSettings.shared.musicVolume)
        let sfxVol = Float(GameSettings.shared.sfxVolume)

        musicPlayer?.volume = musicVol
        ambientPlayer?.volume = sfxVol * 0.6
        sfxPlayers.values.forEach { $0.volume = sfxVol }
    }

    // MARK: - Controls

    func toggleMute() {
        isMuted.toggle()
        if isMuted {
            musicPlayer?.pause()
            ambientPlayer?.pause()
        } else {
            musicPlayer?.play()
            ambientPlayer?.play()
        }
    }

    func stopAll() {
        musicPlayer?.stop()
        ambientPlayer?.stop()
        sfxPlayers.values.forEach { $0.stop() }
        currentMusic = nil
        currentAmbient = nil
    }

    // MARK: - Fade Helpers

    private func fadeIn(player: AVAudioPlayer, targetVolume: Float, duration: TimeInterval) {
        let steps = 20
        let interval = duration / Double(steps)
        let increment = targetVolume / Float(steps)

        for i in 1...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + interval * Double(i)) {
                player.volume = min(targetVolume, increment * Float(i))
            }
        }
    }

    private func fadeOut(player: AVAudioPlayer, duration: TimeInterval) {
        let steps = 20
        let interval = duration / Double(steps)
        let startVolume = player.volume
        let decrement = startVolume / Float(steps)

        for i in 1...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + interval * Double(i)) {
                player.volume = max(0, startVolume - decrement * Float(i))
                if i == steps {
                    player.stop()
                }
            }
        }
    }
}

// MARK: - SwiftUI View Extension

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
}
