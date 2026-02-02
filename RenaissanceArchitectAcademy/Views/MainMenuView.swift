import SwiftUI

struct MainMenuView: View {
    var onStartGame: () -> Void
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    // Adaptive sizing
    private var titleSize: CGFloat { horizontalSizeClass == .regular ? 72 : 56 }
    private var subtitleSize: CGFloat { horizontalSizeClass == .regular ? 44 : 36 }
    private var taglineSize: CGFloat { horizontalSizeClass == .regular ? 24 : 20 }

    var body: some View {
        VStack(spacing: horizontalSizeClass == .regular ? 32 : 24) {
            Spacer()

            // Title
            Text("Renaissance")
                .font(.custom("Cinzel-Bold", size: titleSize, relativeTo: .largeTitle))
                .foregroundStyle(RenaissanceColors.sepiaInk)

            Text("Architect Academy")
                .font(.custom("EBGaramond-Italic", size: subtitleSize, relativeTo: .title))
                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.8))

            // Tagline
            Text("Where Science Builds Civilization")
                .font(.custom("PetitFormalScript-Regular", size: taglineSize, relativeTo: .headline))
                .foregroundStyle(RenaissanceColors.renaissanceBlue)
                .padding(.top, 8)

            Spacer()

            // Menu Buttons
            VStack(spacing: horizontalSizeClass == .regular ? 20 : 16) {
                RenaissanceButton(title: "Begin Journey", action: onStartGame)
                    #if os(macOS)
                    .keyboardShortcut(.return, modifiers: [])
                    #endif

                RenaissanceButton(title: "Continue", action: {})
                    #if os(macOS)
                    .keyboardShortcut("c", modifiers: [.command])
                    #endif

                RenaissanceButton(title: "Codex", action: {})
                    #if os(macOS)
                    .keyboardShortcut("k", modifiers: [.command])
                    #endif
            }
            .padding(.bottom, horizontalSizeClass == .regular ? 80 : 60)
        }
        .padding(horizontalSizeClass == .regular ? 40 : 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(RenaissanceColors.parchment)
    }
}

#Preview("iPhone") {
    MainMenuView(onStartGame: {})
}

#Preview("iPad") {
    MainMenuView(onStartGame: {})
        .previewInterfaceOrientation(.landscapeLeft)
}
