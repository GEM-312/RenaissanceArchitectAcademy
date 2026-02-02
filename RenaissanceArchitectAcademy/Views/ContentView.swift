import SwiftUI

struct ContentView: View {
    @State private var showingMainMenu = true
    @State private var selectedDestination: SidebarDestination? = .allBuildings
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
                            selectedDestination: $selectedDestination,
                            onBackToMenu: {
                                withAnimation {
                                    showingMainMenu = true
                                }
                            }
                        )
                    } detail: {
                        detailView
                    }
                    #if os(macOS)
                    .navigationSplitViewStyle(.balanced)
                    #endif
                } else {
                    // Compact view for iPad portrait
                    NavigationStack {
                        detailView
                            .toolbar {
                                #if os(iOS)
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
                                #else
                                ToolbarItem(placement: .automatic) {
                                    Button {
                                        withAnimation {
                                            showingMainMenu = true
                                        }
                                    } label: {
                                        Label("Menu", systemImage: "line.3.horizontal")
                                    }
                                    .tint(RenaissanceColors.sepiaInk)
                                }
                                #endif
                            }
                    }
                }
            }
        }
        #if os(macOS)
        .frame(minWidth: 800, minHeight: 600)
        #endif
    }

    /// Detail view based on sidebar selection
    @ViewBuilder
    private var detailView: some View {
        switch selectedDestination {
        case .allBuildings:
            CityView(filterEra: nil)
        case .era(let era):
            CityView(filterEra: era)
        case .profile:
            ProfileView()
        case .none:
            CityView(filterEra: nil)
        }
    }
}

#Preview {
    ContentView()
}

#Preview("iPad") {
    ContentView()
}
