import SwiftUI

/// Reusable bird-companion modal overlay used wherever the bird presents
/// a centered prompt above a dimmed background — environment picker,
/// locked-building message, etc.
///
/// Replaces the duplicated `ZStack { dimming; VStack { Spacer; BirdCharacter;
/// content.padding.background(DialogueBubble); Spacer } }` pattern that
/// appeared multiple times in CityMapView with subtly different sizes/paddings.
///
/// The dim background dismisses on tap via `onDismissBackground`. Content is
/// wrapped automatically with the standard padding + DialogueBubble chrome.
struct BirdModalOverlay<Content: View>: View {
    var birdSize: CGFloat = 160
    var contentPadding: CGFloat = 28
    var onDismissBackground: () -> Void
    @ViewBuilder let content: () -> Content

    var body: some View {
        ZStack {
            RenaissanceColors.overlayDimming
                .ignoresSafeArea()
                .onTapGesture(perform: onDismissBackground)

            VStack(spacing: 20) {
                Spacer()

                BirdCharacter(isSitting: true)
                    .frame(width: birdSize, height: birdSize)

                content()
                    .padding(contentPadding)
                    .background(DialogueBubble())
                    .padding(.horizontal, Spacing.xxxl)

                Spacer()
            }
        }
    }
}
