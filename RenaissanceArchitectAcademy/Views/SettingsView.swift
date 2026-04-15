import SwiftUI

/// Game settings panel — theme toggle, volume sliders
struct SettingsView: View {
    @Bindable var settings: GameSettings
    var onDismiss: () -> Void

    var body: some View {
        ZStack {
            RenaissanceColors.overlayDimming
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            VStack(spacing: 20) {
                // Header
                HStack {
                    Text("Settings")
                        .font(.custom("Cinzel-Bold", size: 24))
                        .foregroundStyle(settings.cardTextColor)
                    Spacer()
                    Button { onDismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(settings.cardTextColor.opacity(0.5))
                    }
                    .buttonStyle(.plain)
                }

                Divider()
                    .overlay(RenaissanceColors.warmBrown.opacity(0.3))

                // Theme toggle
                VStack(alignment: .leading, spacing: 10) {
                    Text("Appearance")
                        .font(.custom("Cinzel-Bold", size: 16))
                        .foregroundStyle(settings.cardTextColor)

                    HStack(spacing: 12) {
                        ForEach(AppTheme.allCases, id: \.rawValue) { theme in
                            Button {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    settings.theme = theme
                                }
                            } label: {
                                VStack(spacing: 8) {
                                    // Preview swatch
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(theme == .dark
                                              ? Color(red: 0.18, green: 0.16, blue: 0.13)
                                              : RenaissanceColors.parchment)
                                        .frame(width: 80, height: 50)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .strokeBorder(
                                                    settings.theme == theme
                                                    ? RenaissanceColors.ochre
                                                    : RenaissanceColors.warmBrown.opacity(0.3),
                                                    lineWidth: settings.theme == theme ? 2 : 1
                                                )
                                        )
                                        .overlay(
                                            Text("Aa")
                                                .font(.custom("Cinzel-Bold", size: 18))
                                                .foregroundStyle(
                                                    theme == .dark
                                                    ? RenaissanceColors.ochre
                                                    : RenaissanceColors.sepiaInk
                                                )
                                        )

                                    Text(theme.displayName)
                                        .font(.custom("EBGaramond-Medium", size: 14))
                                        .foregroundStyle(settings.cardTextColor)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                Divider()
                    .overlay(RenaissanceColors.warmBrown.opacity(0.3))

                // Language
                VStack(alignment: .leading, spacing: 10) {
                    Text("Language")
                        .font(.custom("Cinzel-Bold", size: 16))
                        .foregroundStyle(settings.cardTextColor)

                    HStack(spacing: 6) {
                        Image(systemName: "globe")
                            .font(.caption)
                            .foregroundStyle(RenaissanceColors.warmBrown)
                        Picker("Language", selection: $settings.preferredLanguage) {
                            ForEach(AppLanguage.allCases, id: \.rawValue) { lang in
                                Text(lang.rawValue).tag(lang)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(RenaissanceColors.ochre)
                    }

                    Text("Controls AI-generated content (NPC dialogue, bird chat)")
                        .font(.custom("EBGaramond-Regular", size: 12))
                        .foregroundStyle(settings.cardTextColor.opacity(0.5))
                }

                Divider()
                    .overlay(RenaissanceColors.warmBrown.opacity(0.3))

                // Volume sliders
                VStack(alignment: .leading, spacing: 14) {
                    Text("Audio")
                        .font(.custom("Cinzel-Bold", size: 16))
                        .foregroundStyle(settings.cardTextColor)

                    volumeRow(label: "Music", icon: "music.note", value: $settings.musicVolume)
                    volumeRow(label: "Sound Effects", icon: "speaker.wave.2.fill", value: $settings.sfxVolume)
                }

                Spacer()
            }
            .padding(24)
            .frame(width: 340)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(settings.dialogBackground.opacity(0.96))
            )
            .borderModal(radius: 18)
        }
    }

    private func volumeRow(label: String, icon: String, value: Binding<Double>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(RenaissanceColors.warmBrown)
                Text(label)
                    .font(.custom("EBGaramond-Regular", size: 14))
                    .foregroundStyle(settings.cardTextColor)
            }
            HStack(spacing: 10) {
                Image(systemName: "speaker.fill")
                    .font(.caption2)
                    .foregroundStyle(RenaissanceColors.warmBrown.opacity(0.6))
                Slider(value: value, in: 0...1)
                    .tint(RenaissanceColors.ochre)
                Image(systemName: "speaker.wave.3.fill")
                    .font(.caption2)
                    .foregroundStyle(RenaissanceColors.warmBrown.opacity(0.6))
            }
        }
    }
}
