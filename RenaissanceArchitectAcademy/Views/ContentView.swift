import SwiftUI

struct ContentView: View {
    @State private var showingMainMenu = true

    var body: some View {
        ZStack {
            // Parchment background
            RenaissanceColors.parchment
                .ignoresSafeArea()

            if showingMainMenu {
                MainMenuView(onStartGame: {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showingMainMenu = false
                    }
                })
            } else {
                CityView()
            }
        }
    }
}

#Preview {
    ContentView()
}
