import SwiftUI

/// Reusable bottom-anchored parchment dialog panel.
///
/// Used across all map views (City, Workshop, Forest, CraftingRoom) to display
/// bird guidance, NPC encounters, or any bottom-panel content. The panel slides
/// up from the bottom and sits above the inventory bar.
struct BottomDialogPanel<Content: View>: View {
    var bottomPadding: CGFloat = 90
    @ViewBuilder let content: () -> Content

    private var settings: GameSettings { GameSettings.shared }

    var body: some View {
        VStack {
            Spacer()
            content()
                .padding(Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: CornerRadius.md)
                        .fill(settings.cardBackground)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.md)
                        .stroke(settings.cardBorderColor, lineWidth: 1)
                )
                .renaissanceShadow(.card)
                .padding(.horizontal, Spacing.lg)
                .padding(.bottom, bottomPadding)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}
