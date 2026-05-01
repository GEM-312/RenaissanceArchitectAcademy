//
//  SpeakerButton.swift
//  RenaissanceArchitectAcademy
//
//  Reusable play/stop button for ElevenLabs TTS narration. Drop one in
//  next to any block of text the bird should be able to read aloud.
//
//  States:
//   - locked    — player is not subscribed (Apprentice tier gate)
//   - disabled  — proxy token or voice ID isn't configured yet
//   - idle      — ready to play, shows a speaker icon
//   - speaking  — this specific text is currently playing, shows a stop icon
//

import SwiftUI

struct SpeakerButton: View {

    /// The text to narrate. Used both as the speak input and as the key for
    /// `TTSService.isSpeaking(_:)` so the active button can show its own
    /// stop state without flipping every other button on screen.
    let text: String

    /// ElevenLabs voice to use. Defaults to the bird companion voice.
    var voiceID: String = TTSVoice.bird

    /// Tint for the icon. Knowledge cards pass `card.color`; bird chat passes
    /// `RenaissanceColors.ochre` to match the bird's plumage.
    var color: Color = RenaissanceColors.renaissanceBlue

    /// Visual size of the SF Symbol. The hit area is `size * 1.8` so the
    /// button stays comfortably tappable even at small icon sizes.
    var size: CGFloat = 14

    @ObservedObject private var tts = TTSService.shared

    var body: some View {
        Button {
            guard isAvailable else { return }
            if isThisSpeaking {
                tts.stop()
            } else {
                tts.speak(text, voiceID: voiceID)
            }
        } label: {
            Image(systemName: iconName)
                .font(.system(size: size))
                .foregroundStyle(iconColor)
                .frame(width: size * 1.8, height: size * 1.8)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .disabled(!isAvailable)
    }

    // MARK: - Derived state

    private var isSubscribed: Bool { GameSettings.shared.isSubscribed }

    private var isVoiceReady: Bool {
        WorkerClient.isConfigured && TTSVoice.isConfigured(voiceID)
    }

    /// The button is interactive only when the player is subscribed AND the
    /// voice is wired up. Locked / unwired states render the icon greyed.
    private var isAvailable: Bool { isSubscribed && isVoiceReady }

    private var isThisSpeaking: Bool { tts.isSpeaking(text) }

    private var iconName: String {
        if !isSubscribed { return "lock.fill" }
        return isThisSpeaking ? "stop.fill" : "speaker.wave.2.fill"
    }

    private var iconColor: Color {
        isAvailable ? color : color.opacity(0.4)
    }
}
