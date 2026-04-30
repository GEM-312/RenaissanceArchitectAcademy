import SwiftUI

/// Reusable bottom-anchored parchment dialog panel.
///
/// Used across all map views (City, Workshop, Forest, CraftingRoom) to display
/// bird guidance, NPC encounters, or any bottom-panel content. The panel slides
/// up from the bottom and sits above the inventory bar.
struct BottomDialogPanel<Content: View>: View {
    var bottomPadding: CGFloat = 90
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .padding(Spacing.md)
            .themedCard()
            .padding(.horizontal, Spacing.lg)
            .padding(.bottom, bottomPadding)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}
