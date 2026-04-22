import SwiftUI

/// Game settings panel — theme toggle, volume sliders, Game Center
struct SettingsView: View {
    @Bindable var settings: GameSettings
    var onDismiss: () -> Void
    // Game Center presented via GameCenterManager.showDashboard()

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

                    volumeRow(label: "Music", icon: "music.note", value: $settings.musicVolume, testAction: nil)
                    volumeRow(label: "Sound Effects", icon: "speaker.wave.2.fill", value: $settings.sfxVolume) {
                        SoundManager.shared.play(.tapSoft)
                    }
                }

                Divider()
                    .overlay(RenaissanceColors.warmBrown.opacity(0.3))

                // Reading — card text size slider
                cardTextSizeRow

                Divider()
                    .overlay(RenaissanceColors.warmBrown.opacity(0.3))

                // Game Center
                VStack(alignment: .leading, spacing: 10) {
                    Text("Game Center")
                        .font(.custom("Cinzel-Bold", size: 16))
                        .foregroundStyle(settings.cardTextColor)

                    let gc = GameCenterManager.shared
                    HStack(spacing: 8) {
                        Image(systemName: gc.isAuthenticated ? "checkmark.circle.fill" : "xmark.circle")
                            .font(.caption)
                            .foregroundStyle(gc.isAuthenticated ? RenaissanceColors.sageGreen : RenaissanceColors.warmBrown.opacity(0.5))
                        Text(gc.isAuthenticated ? (gc.playerDisplayName ?? "Signed In") : "Not signed in")
                            .font(.custom("EBGaramond-Regular", size: 14))
                            .foregroundStyle(settings.cardTextColor)
                    }

                    if gc.isAuthenticated {
                        Button {
                            GameCenterManager.shared.showDashboard()
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "trophy.fill")
                                    .font(.caption)
                                Text("Leaderboards & Achievements")
                                    .font(.custom("EBGaramond-SemiBold", size: 14))
                            }
                            .foregroundStyle(RenaissanceColors.ochre)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .strokeBorder(RenaissanceColors.ochre.opacity(0.5), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
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
            // Game Center dashboard presented via GameCenterManager.showDashboard()
        }
    }

    private func volumeRow(
        label: String,
        icon: String,
        value: Binding<Double>,
        testAction: (() -> Void)?
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(RenaissanceColors.warmBrown)
                Text(label)
                    .font(.custom("EBGaramond-Regular", size: 14))
                    .foregroundStyle(settings.cardTextColor)
                Spacer()
                if let testAction {
                    Button {
                        testAction()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 10))
                            Text("Try")
                                .font(.custom("EBGaramond-Regular", size: 12))
                        }
                        .foregroundStyle(RenaissanceColors.ochre)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            Capsule().strokeBorder(RenaissanceColors.ochre.opacity(0.4), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
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

    // MARK: - Reading / Card Text Size

    @ViewBuilder
    private var cardTextSizeRow: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "textformat.size")
                    .font(.caption)
                    .foregroundStyle(RenaissanceColors.warmBrown)
                Text("Card Text Size")
                    .font(.custom("Cinzel-Bold", size: 16))
                    .foregroundStyle(settings.cardTextColor)
                Spacer()
                Text("\(Int(settings.cardTextScale * 100))%")
                    .font(.custom("EBGaramond-SemiBold", size: 14))
                    .foregroundStyle(settings.cardTextColor.opacity(0.7))
                    .monospacedDigit()
            }
            HStack(spacing: 10) {
                Text("A")
                    .font(.custom("EBGaramond-Regular", size: 12))
                    .foregroundStyle(RenaissanceColors.warmBrown.opacity(0.6))
                Slider(value: $settings.cardTextScale, in: 0.8...1.3, step: 0.05)
                    .tint(RenaissanceColors.ochre)
                Text("A")
                    .font(.custom("EBGaramond-Regular", size: 22))
                    .foregroundStyle(RenaissanceColors.warmBrown.opacity(0.6))
            }
            Text("Adjusts text size inside knowledge card visuals")
                .font(.custom("EBGaramond-Regular", size: 12))
                .foregroundStyle(settings.cardTextColor.opacity(0.5))
        }
    }
}
