import SwiftUI

/// Reusable bird guidance content for the bottom dialog panel.
///
/// Shows the bird character, guidance message, card progress counter,
/// and optional action buttons (walk to station, navigate to environment).
/// Used across all 4 map views inside a `BottomDialogPanel`.
struct BirdGuidanceContent: View {
    private var settings: GameSettings { GameSettings.shared }
    let message: String
    var progressText: String? = nil
    let onDismiss: () -> Void

    // Optional: walk to a workshop station
    var stationType: ResourceStationType? = nil
    var onWalkToStation: ((ResourceStationType) -> Void)? = nil

    // Optional: navigate to another environment
    var destination: SidebarDestination? = nil
    var onNavigate: ((SidebarDestination) -> Void)? = nil

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            BirdCharacter(isSitting: true)
                .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 6) {
                Text(message)
                    .font(.custom("Cinzel-Bold", size: 14))
                    .foregroundStyle(settings.cardTextColor)
                    .fixedSize(horizontal: false, vertical: true)

                if let progressText {
                    Text(progressText)
                        .font(RenaissanceFont.caption)
                        .foregroundStyle(settings.cardTextColor.opacity(0.5))
                }

                HStack(spacing: 8) {
                    // "Go to Station" button (Workshop only)
                    if let station = stationType, let walkAction = onWalkToStation {
                        Button {
                            withAnimation(.easeOut(duration: 0.2)) { onDismiss() }
                            walkAction(station)
                        } label: {
                            HStack(spacing: 5) {
                                Image(systemName: "figure.walk")
                                    .font(.system(size: 12))
                                Text("Go!")
                                    .font(RenaissanceFont.footnoteBold)
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .parchmentCapsule(color: RenaissanceColors.warmBrown)
                        }
                        .buttonStyle(.plain)
                    }

                    // "Go!" to another environment
                    if let dest = destination, let navAction = onNavigate {
                        Button {
                            withAnimation(.easeOut(duration: 0.2)) { onDismiss() }
                            navAction(dest)
                        } label: {
                            HStack(spacing: 5) {
                                Image(systemName: Self.iconName(for: dest))
                                    .font(.system(size: 12))
                                Text("Go!")
                                    .font(RenaissanceFont.footnoteBold)
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .parchmentCapsule(color: RenaissanceColors.renaissanceBlue)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            Spacer()

            Button {
                withAnimation(.easeOut(duration: 0.3)) { onDismiss() }
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(settings.cardTextColor.opacity(0.4))
                    .padding(6)
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Helpers

    static func iconName(for destination: SidebarDestination) -> String {
        switch destination {
        case .forest: return "tree.fill"
        case .workshop: return "hammer.fill"
        case .cityMap: return "building.columns.fill"
        default: return "arrow.right.circle.fill"
        }
    }
}
