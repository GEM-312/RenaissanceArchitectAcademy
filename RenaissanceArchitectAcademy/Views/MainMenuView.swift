import SwiftUI

struct MainMenuView: View {
    var onStartGame: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Title
            Text("Renaissance")
                .font(.custom("Cinzel-Bold", size: 56, relativeTo: .largeTitle))
                .foregroundStyle(RenaissanceColors.sepiaInk)

            Text("Architect Academy")
                .font(.custom("EBGaramond-Italic", size: 36, relativeTo: .title))
                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.8))

            // Tagline
            Text("Where Science Builds Civilization")
                .font(.custom("PetitFormalScript-Regular", size: 20, relativeTo: .headline))
                .foregroundStyle(RenaissanceColors.renaissanceBlue)
                .padding(.top, 8)

            Spacer()

            // Menu Buttons
            VStack(spacing: 16) {
                RenaissanceButton(title: "Begin Journey", action: onStartGame)
                RenaissanceButton(title: "Continue", action: {})
                RenaissanceButton(title: "Codex", action: {})
            }
            .padding(.bottom, 60)
        }
        .padding()
    }
}

#Preview {
    MainMenuView(onStartGame: {})
}
