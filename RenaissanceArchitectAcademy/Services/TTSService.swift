//
//  TTSService.swift
//  RenaissanceArchitectAcademy
//
//  ElevenLabs Text-to-Speech playback. Fetches audio via the Cloudflare
//  Worker proxy (`WorkerClient.ttsURL`), caches the bytes on disk by
//  hash(voiceID + text), and plays through AVAudioPlayer.
//
//  One utterance at a time — calling `speak(...)` while another is playing
//  cancels the previous. UI binds to `isPlaying` to show a play/stop toggle.
//

import AVFoundation
import CryptoKit
import Foundation

/// Voice IDs for the bird companion and NPC casts.
/// Generated in ElevenLabs Voice Lab; paste the new ID over the placeholder
/// once a voice is locked in. Same string the Worker passes through to
/// `https://api.elevenlabs.io/v1/text-to-speech/{voiceId}`.
enum TTSVoice {
    /// Bird companion — chat replies and bird-dialog bubbles.
    /// "Curious Bird" voice: thick Roman Italian accent, early 30s, playful.
    static let bird = "bNHG92L4700oZ2OVXQSc"

    /// Knowledge-card narrator — lesson readings on flipped cards.
    /// "Storyteller in Piazza Navona" voice: thick Roman Italian accent, 50s, theatrical.
    static let storyteller = "yUUnPL3w0TMlYSSSuEO8"

    /// Male historical NPCs (Brunelleschi, Medici, Barovier, station masters).
    static let npcMale = "PASTE_NPC_MALE_VOICE_ID_HERE"

    /// Female historical NPCs.
    static let npcFemale = "PASTE_NPC_FEMALE_VOICE_ID_HERE"

    /// True if the given voice ID has been generated and pasted in.
    static func isConfigured(_ voiceID: String) -> Bool {
        !voiceID.hasPrefix("PASTE_")
    }
}

@MainActor
final class TTSService: NSObject, ObservableObject {

    static let shared = TTSService()

    /// True while audio is fetching or playing. UI binds to this to show
    /// a play/stop toggle on the speak button.
    @Published private(set) var isPlaying: Bool = false

    /// Last error string for surfacing failures in dev / settings UI.
    @Published private(set) var lastError: String?

    /// The voice ID currently speaking (or about to). Used to mark "this
    /// specific text bubble is the one playing" when multiple speak buttons
    /// share the same screen.
    @Published private(set) var currentText: String?

    private var player: AVAudioPlayer?
    private var fetchTask: Task<Void, Never>?
    private let cacheDir: URL

    override private init() {
        let cacheRoot = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        cacheDir = cacheRoot.appendingPathComponent("TTSCache", isDirectory: true)
        try? FileManager.default.createDirectory(at: cacheDir, withIntermediateDirectories: true)
        super.init()
    }

    // MARK: - Public API

    /// Speak the given text. Stops any current playback first. On disk-cache
    /// hit, playback starts within a frame; on miss, fetches via the proxy
    /// and caches before playing.
    func speak(_ text: String, voiceID: String = TTSVoice.bird) {
        stop()

        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        guard GameSettings.shared.isSubscribed else {
            lastError = "Subscribe to unlock the bird's voice."
            print("[TTS] Skipped — subscription off. Flip the Apprentice toggle in Profile (DEBUG).")
            return
        }
        guard WorkerClient.isConfigured else {
            lastError = "Proxy token missing — paste it in APIKeys.swift"
            print("[TTS] Skipped — proxy token missing in APIKeys.swift.")
            return
        }
        guard TTSVoice.isConfigured(voiceID) else {
            lastError = "Voice ID not set — generate one in ElevenLabs and paste into TTSVoice"
            print("[TTS] Skipped — voiceID '\(voiceID)' is still a placeholder.")
            return
        }

        currentText = trimmed
        isPlaying = true
        print("[TTS] Speaking with voice \(voiceID): '\(trimmed.prefix(60))…'")

        fetchTask = Task { [weak self] in
            guard let self = self else { return }
            do {
                let audioData = try await self.audioData(for: trimmed, voiceID: voiceID)
                try Task.checkCancellation()
                try self.startPlayback(audioData)
            } catch is CancellationError {
                // Cancelled by a newer speak() or stop() call — silent.
            } catch {
                self.lastError = "TTS failed: \(error.localizedDescription)"
                print("[TTS] Failed: \(error.localizedDescription)")
                self.isPlaying = false
                self.currentText = nil
            }
        }
    }

    /// Stop current playback and cancel any in-flight fetch.
    func stop() {
        fetchTask?.cancel()
        fetchTask = nil
        player?.stop()
        player = nil
        isPlaying = false
        currentText = nil
    }

    /// True if `text` is the utterance currently playing — useful for UI
    /// showing a stop icon on the active bubble while others show play.
    func isSpeaking(_ text: String) -> Bool {
        guard isPlaying, let current = currentText else { return false }
        return current == text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - Network

    private func audioData(for text: String, voiceID: String) async throws -> Data {
        let cacheURL = cacheURL(for: text, voiceID: voiceID)
        if let cached = try? Data(contentsOf: cacheURL), !cached.isEmpty {
            print("[TTS] Cache hit — playing instantly.")
            return cached
        }
        print("[TTS] Cache miss — fetching from ElevenLabs (flash v2.5)…")

        var request = URLRequest(url: WorkerClient.ttsURL(voiceID: voiceID))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(WorkerClient.proxyToken, forHTTPHeaderField: "X-Proxy-Token")
        request.httpBody = try JSONSerialization.data(withJSONObject: [
            "text": text,
            "model_id": "eleven_flash_v2_5",
            "voice_settings": [
                "stability": 0.55,
                "similarity_boost": 0.75
            ]
        ])

        let (data, response) = try await URLSession.shared.data(for: request)

        if let http = response as? HTTPURLResponse, http.statusCode != 200 {
            let body = String(data: data, encoding: .utf8) ?? "(no body)"
            throw NSError(
                domain: "TTSService", code: http.statusCode,
                userInfo: [NSLocalizedDescriptionKey: "HTTP \(http.statusCode): \(body)"]
            )
        }

        try? data.write(to: cacheURL)
        return data
    }

    private func cacheURL(for text: String, voiceID: String) -> URL {
        let combined = "\(voiceID)::\(text)"
        let digest = SHA256.hash(data: Data(combined.utf8))
        let key = digest.map { String(format: "%02x", $0) }.joined()
        return cacheDir.appendingPathComponent(key).appendingPathExtension("mp3")
    }

    // MARK: - Playback

    private func startPlayback(_ data: Data) throws {
        let player = try AVAudioPlayer(data: data)
        player.delegate = self
        player.volume = Float(GameSettings.shared.sfxVolume)
        player.prepareToPlay()
        self.player = player
        player.play()
    }
}

extension TTSService: AVAudioPlayerDelegate {
    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor [weak self] in
            self?.isPlaying = false
            self?.currentText = nil
            self?.player = nil
        }
    }

    nonisolated func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        Task { @MainActor [weak self] in
            self?.lastError = "Audio decode error: \(error?.localizedDescription ?? "unknown")"
            self?.isPlaying = false
            self?.currentText = nil
            self?.player = nil
        }
    }
}
