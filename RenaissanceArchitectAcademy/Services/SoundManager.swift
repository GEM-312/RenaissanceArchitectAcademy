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

        // Bird Companion
        case birdFlyIn = "bird_fly_in"
        case birdChirp = "bird_chirp"
        case birdHappyTrill = "bird_happy_trill"
        case birdSquawk = "bird_squawk"

        /// File extension — new station/crafting/UI sounds are wav, originals are mp3
        var ext: String {
            switch self {
            case .footstep, .sealStamp, .levelUp,
                 .overlayOpen, .overlayClose, .pageTurn, .sceneTransition,
                 .stoneHit, .clayDig, .miningHammer, .timberChop,
                 .farmCollect, .herbPick, .pigmentGrind, .materialPickup,
                 .workbenchMix, .furnaceWoosh, .furnaceCrackling, .anvilStrike,
                 .craftingComplete, .florinsEarned,
                 .birdFlyIn, .birdChirp, .birdHappyTrill, .birdSquawk:
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

        // Paired bird reactions — the bird voices success and failure alongside UI sounds
        switch sound {
        case .correctChime, .cardComplete, .buildingComplete, .levelUp:
            playBirdReaction(.birdHappyTrill)
        case .wrongBuzz, .hangmanWrong:
            playBirdReaction(.birdSquawk)
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

   /// Play a bird reaction cached alongside the UI sound, at 0.7× volume so it layers cleanly.
    private func playBirdReaction(_ bird: Sound) {
        let sfxVol = Float(GameSettings.shared.sfxVolume) * 0.7
        if let player = sfxPlayers[bird.rawValue] {
            player.currentTime = 0
            player.volume = sfxVol
            player.play()
            return
        }
        guard let url = Bundle.main.url(forResource: bird.rawValue, withExtension: bird.ext) else { return }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = sfxVol
            player.play()
            sfxPlayers[bird.rawValue] = player
        } catch {}
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
        case lesson = "music_lesson"

        /// Shipped so far as wav; older tracks still mp3 until reauthored.
        var ext: String {
            switch self {
            case .lesson: return "wav"
            default: return "mp3"
            }
        }
    }

    /// Currently playing music track (to avoid restarting the same track)
    private var currentMusic: MusicTrack?

    /// Play looping background music with optional crossfade
    func playMusic(_ track: MusicTrack, fadeDuration: TimeInterval = 1.0) {
        guard !isMuted else { return }
        guard track != currentMusic else { return }

        let musicVol = Float(GameSettings.shared.musicVolume)

        guard let url = Bundle.main.url(forResource: track.rawValue, withExtension: track.ext) else {
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

    /// Stop background music with fade. If `track` is provided, only stops
    /// when the currently-playing track matches — prevents a leaving view
    /// from killing its successor's music when SwiftUI fires .onAppear before
    /// .onDisappear during a scene transition. Pass nil to force-stop anything.
    func stopMusic(_ track: MusicTrack? = nil, fadeDuration: TimeInterval = 1.0) {
        guard let player = musicPlayer, player.isPlaying else { return }
        if let track, currentMusic != track { return }
        fadeOut(player: player, duration: fadeDuration)
        currentMusic = nil
    }

    // MARK: - Ambient Sounds

    enum AmbientSound: String, CaseIterable {
        case cityAmbient = "city_ambient"
        // Forest plays the old workshop_ambient.wav (which was always more
        // forest-y than workshop-y). forest_ambient.wav is orphaned in the
        // bundle until cleanup. The workshop has no base ambient — only
        // music + per-station ambients that crossfade on arrival.
        case forestAmbient = "workshop_ambient"
        case craftingAmbient = "crafting_ambient"

        // Per-station ambient layer — crossfades over the base workshop ambient
        // when the player arrives at one of these stations, fades back on leaving.
        case quarryAmbient = "quarry_ambient"
        case clayPitAmbient = "clay_pit_ambient"
        case volcanoRumble = "volcano_rumble_ambient"
        case riverAmbient = "river_ambient"
        case marketChatter = "market_chatter_ambient"

        /// Shipped so far as wav; older mp3 fallback for anything not converted yet.
        var ext: String {
            switch self {
            case .forestAmbient, .craftingAmbient: return "wav"
            default: return "mp3"
            }
        }
    }

    private var currentAmbient: AmbientSound?

    /// Play looping ambient sound (alongside music)
    func playAmbient(_ ambient: AmbientSound, fadeDuration: TimeInterval = 0.5) {
        guard !isMuted else { return }
        guard ambient != currentAmbient else { return }

        // Ambient is quieter than SFX. Per-track multiplier compensates for
        // files that were AI-generated quiet (volcano rumble was designed
        // "never peaks" — needs a 2x boost to be audible under music).
        let perTrackBoost: Float = ambient == .volcanoRumble ? 2.0 : 1.0
        let ambientVol = min(1.0, Float(GameSettings.shared.sfxVolume) * 0.6 * perTrackBoost)

        guard let url = Bundle.main.url(forResource: ambient.rawValue, withExtension: ambient.ext) else {
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

    /// Stop the ambient track with fade. Same track-guard pattern as `stopMusic` —
    /// pass the ambient you started to ensure you only stop your own, or pass nil
    /// to clear whatever's playing (used by per-station crossfade on walk-away).
    func stopAmbient(_ ambient: AmbientSound? = nil, fadeDuration: TimeInterval = 0.5) {
        guard let player = ambientPlayer, player.isPlaying else { return }
        if let ambient, currentAmbient != ambient { return }
        fadeOut(player: player, duration: fadeDuration)
        currentAmbient = nil
    }

    /// Stop the ambient only if the currently-playing one is in `allowed`.
    /// Used by views that own multiple possible ambients (e.g. workshop has
    /// quarry/volcano/etc. station ambients) to clean up on disappear without
    /// killing a successor view's just-started ambient.
    func stopAmbient(matching allowed: Set<AmbientSound>, fadeDuration: TimeInterval = 0.5) {
        guard let current = currentAmbient, allowed.contains(current) else { return }
        stopAmbient(current, fadeDuration: fadeDuration)
    }

    /// Defensive cleanup: stop any ambient that ISN'T one of `keep`. Used at
    /// each scene's appear to clear lingering audio from views whose
    /// .onDisappear didn't fire (SwiftUI lifecycle is unreliable in this
    /// navigation context — verified during the May 13 audio debug).
    func stopAmbientExcept(_ keep: Set<AmbientSound>, fadeDuration: TimeInterval = 0.5) {
        let toClear = Set(AmbientSound.allCases).subtracting(keep)
        stopAmbient(matching: toClear, fadeDuration: fadeDuration)
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

    /// Fade volume from 0 to target using async Task — replaces the prior
    /// Timer.scheduledTimer approach, which silently failed (timer was being
    /// deallocated before firing, leaving every ambient/music track at volume 0).
    private func fadeIn(player: AVAudioPlayer, targetVolume: Float, duration: TimeInterval) {
        let steps = 20
        let interval = duration / Double(steps)
        let increment = targetVolume / Float(steps)
        Task { @MainActor [weak player] in
            for step in 1...steps {
                guard let player else { return }
                player.volume = min(targetVolume, increment * Float(step))
                try? await Task.sleep(for: .seconds(interval))
            }
        }
    }

    private func fadeOut(player: AVAudioPlayer, duration: TimeInterval) {
        let steps = 20
        let interval = duration / Double(steps)
        let startVolume = player.volume
        let decrement = startVolume / Float(steps)
        Task { @MainActor [weak player] in
            for step in 1...steps {
                guard let player else { return }
                player.volume = max(0, startVolume - decrement * Float(step))
                try? await Task.sleep(for: .seconds(interval))
            }
            player?.stop()
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
