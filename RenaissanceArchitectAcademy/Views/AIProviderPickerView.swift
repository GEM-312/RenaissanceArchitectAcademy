import SwiftUI
import FoundationModels

/// AI provider picker — Apple Intelligence (free) or Claude AI (premium)
struct AIProviderPickerView: View {
    let onSelect: (AIProvider) -> Void

    @Environment(\.horizontalSizeClass) private var sizeClass
    private var isLargeScreen: Bool { sizeClass == .regular }

    var body: some View {
        ZStack {
            RenaissanceColors.overlayDimming
                .ignoresSafeArea()
                .onTapGesture { /* block dismiss */ }

            VStack(spacing: 24) {
                BirdCharacter(isSitting: true)
                    .frame(width: 80, height: 80)

                VStack(spacing: 6) {
                    Text("Choose Your AI")
                        .font(.custom("Cinzel-Bold", size: isLargeScreen ? 22 : 18))
                        .foregroundStyle(RenaissanceColors.sepiaInk)

                    Text("You can change this anytime in Settings")
                        .font(.custom("EBGaramond-Italic", size: 14))
                        .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.5))
                }

                VStack(spacing: 12) {
                    // Apple Intelligence (free)
                    providerButton(
                        provider: .appleOnDevice,
                        available: appleAIAvailable,
                        badge: "FREE",
                        badgeColor: RenaissanceColors.sageGreen,
                        subtitle: appleAIAvailable ? nil : appleAIStatusMessage
                    )

                    // Claude AI (premium)
                    providerButton(
                        provider: .claudePremium,
                        available: true,
                        badge: "$1.99/mo",
                        badgeColor: RenaissanceColors.ochre,
                        subtitle: nil
                    )
                }
            }
            .padding(28)
            .frame(maxWidth: isLargeScreen ? 380 : .infinity)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.lg)
                    .fill(RenaissanceColors.parchment)
            )
            .borderModal(radius: CornerRadius.lg)
            .renaissanceShadow(.modal)
            .padding(.horizontal, isLargeScreen ? 0 : 20)
        }
    }

    private func providerButton(provider: AIProvider, available: Bool, badge: String, badgeColor: Color, subtitle: String?) -> some View {
        Button {
            guard available else { return }
            SoundManager.shared.play(.tapSoft)
            onSelect(provider)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: provider.icon)
                    .font(.system(size: 22))
                    .foregroundStyle(available ? RenaissanceColors.ochre : RenaissanceColors.stoneGray)
                    .frame(width: 36)

                VStack(alignment: .leading, spacing: 3) {
                    Text(provider.displayName)
                        .font(.custom("EBGaramond-SemiBold", size: 17))
                        .foregroundStyle(available ? RenaissanceColors.sepiaInk : RenaissanceColors.stoneGray)

                    Text(provider.description)
                        .font(.custom("EBGaramond-Regular", size: 13))
                        .foregroundStyle(available ? RenaissanceColors.sepiaInk.opacity(0.6) : RenaissanceColors.stoneGray.opacity(0.5))

                    if let subtitle {
                        Text(subtitle)
                            .font(.custom("EBGaramond-Italic", size: 11))
                            .foregroundStyle(RenaissanceColors.errorRed.opacity(0.7))
                    }
                }

                Spacer()

                Text(badge)
                    .font(.custom("Cinzel-Bold", size: 11))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(available ? badgeColor : RenaissanceColors.stoneGray))
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.md)
                    .fill(RenaissanceColors.parchment)
            )
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.md)
                    .stroke(available ? RenaissanceColors.ochre.opacity(0.3) : RenaissanceColors.stoneGray.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .disabled(!available)
    }

    private var appleAIAvailable: Bool {
        if #available(iOS 26.0, macOS 26.0, *) {
            return AppleAIService.isAvailable
        }
        return false
    }

    private var appleAIStatusMessage: String {
        if #available(iOS 26.0, macOS 26.0, *) {
            return AppleAIService.availabilityReason ?? ""
        }
        return "Requires iOS 26 or later"
    }
}
