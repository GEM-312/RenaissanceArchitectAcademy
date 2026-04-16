import SwiftUI

// MARK: - Shared Mini-Game Components
// Extracted from 5 StationMiniGame files to eliminate duplication.
// Used by: QuarryMiniGameView, RiverMiniGameView, FarmMiniGameView,
//          ClayPitMiniGameView, VolcanoMiniGameView

// MARK: - Rule Row

/// A single rule/instruction row with icon badge + text.
/// Previously duplicated identically in all 5 mini-game files.
struct MiniGameRuleRow: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(color)
                .frame(width: 32, height: 32)
                .background(
                    RoundedRectangle(cornerRadius: CornerRadius.sm)
                        .fill(color.opacity(0.1))
                )

            Text(text)
                .font(RenaissanceFont.footnote)
                .foregroundStyle(RenaissanceColors.sepiaInk)

            Spacer()
        }
        .padding(Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(RenaissanceColors.parchment.opacity(0.6))
                .borderWorkshop(radius: 10)
        )
    }
}

// MARK: - Intro Card

/// Parchment intro card shown before a mini-game starts.
/// Contains: icon + title header, body text, rules (ViewBuilder), begin button, back button.
/// Previously duplicated as `introCardShell` in ClayPit/Volcano and inline in Quarry/Farm/River.
struct MiniGameIntroCard<Rules: View>: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let bodyText: String
    let buttonLabel: String
    let buttonColor: Color
    let startAction: () -> Void
    let backAction: () -> Void
    @ViewBuilder let rules: () -> Rules

    var body: some View {
        VStack(spacing: 20) {
            // Header: icon + title
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundStyle(iconColor)
                    .frame(width: 44, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: CornerRadius.sm)
                            .fill(iconColor.opacity(0.1))
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.custom("Cinzel-Bold", size: 22))
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                    Text(subtitle)
                        .font(RenaissanceFont.dialogSubtitle)
                        .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))
                }
            }

            // Body text
            Text(bodyText)
                .font(RenaissanceFont.bodyMedium)
                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))
                .fixedSize(horizontal: false, vertical: true)

            // Rules (caller provides MiniGameRuleRow entries)
            rules()

            // Begin button
            Button(action: startAction) {
                HStack(spacing: 8) {
                    Image(systemName: icon)
                        .font(.caption)
                    Text(buttonLabel)
                        .font(.custom("EBGaramond-SemiBold", size: 16))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.sm)
                .parchmentButton(color: buttonColor, radius: 10)
            }
            .buttonStyle(.plain)

            // Back button
            Button("Back", action: backAction)
                .font(RenaissanceFont.bodySmall)
                .foregroundStyle(RenaissanceColors.sepiaInk)
                .buttonStyle(.plain)
        }
        .padding(Spacing.xl)
        .adaptiveWidth(400)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.lg)
                .fill(RenaissanceColors.parchment)
        )
        .borderWorkshop()
    }
}

// MARK: - Difficulty Color

/// Shared difficulty color mapping for mini-game material options.
/// Previously duplicated in Quarry, Farm, ClayPit, Volcano.
func miniGameDifficultyColor(_ difficulty: String) -> Color {
    switch difficulty {
    case "Easy":   return RenaissanceColors.sageGreen
    case "Medium": return RenaissanceColors.ochre
    case "Hard":   return RenaissanceColors.terracotta
    default:       return RenaissanceColors.stoneGray
    }
}
