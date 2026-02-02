import SwiftUI

struct ContentView: View {
    @State private var showingMainMenu = true
    @State private var selectedEra: Era? = nil
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

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
                // Use sidebar navigation on iPad landscape / Mac
                if horizontalSizeClass == .regular {
                    NavigationSplitView {
                        SidebarView(
                            selectedEra: $selectedEra,
                            onBackToMenu: {
                                withAnimation {
                                    showingMainMenu = true
                                }
                            }
                        )
                    } detail: {
                        CityView(filterEra: selectedEra)
                    }
                    #if os(macOS)
                    .navigationSplitViewStyle(.balanced)
                    #endif
                } else {
                    // Compact view for iPhone / iPad portrait
                    NavigationStack {
                        CityView(filterEra: nil)
                            .toolbar {
                                ToolbarItem(placement: .navigationBarLeading) {
                                    Button {
                                        withAnimation {
                                            showingMainMenu = true
                                        }
                                    } label: {
                                        Label("Menu", systemImage: "line.3.horizontal")
                                    }
                                    .tint(RenaissanceColors.sepiaInk)
                                }
                            }
                    }
                }
            }
        }
        #if os(macOS)
        .frame(minWidth: 800, minHeight: 600)
        #endif
    }
}

#Preview {
    ContentView()
}

#Preview("iPad") {
    ContentView()
        .previewDevice("iPad Pro (12.9-inch) (6th generation)")
}
