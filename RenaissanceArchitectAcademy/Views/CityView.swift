import SwiftUI

struct CityView: View {
    @StateObject private var viewModel = CityViewModel()
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var filterEra: Era?

    // Adaptive grid columns based on screen size
    private var columns: [GridItem] {
        let minSize: CGFloat = horizontalSizeClass == .regular ? 200 : 140
        return [GridItem(.adaptive(minimum: minSize, maximum: 300), spacing: 20)]
    }

    private var filteredPlots: [BuildingPlot] {
        if let era = filterEra {
            return viewModel.buildingPlots.filter { $0.building.era == era }
        }
        return viewModel.buildingPlots
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // City background
                RenaissanceColors.parchment
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Header for compact mode
                        if horizontalSizeClass != .regular {
                            Text("Florence")
                                .font(.custom("Cinzel-Bold", size: 32, relativeTo: .title))
                                .foregroundStyle(RenaissanceColors.sepiaInk)
                                .padding(.horizontal)
                        }

                        // Building plots grid
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(filteredPlots) { plot in
                                BuildingPlotView(
                                    plot: plot,
                                    isLargeScreen: horizontalSizeClass == .regular
                                ) {
                                    viewModel.selectPlot(plot)
                                }
                                #if os(macOS)
                                .keyboardShortcut(KeyEquivalent(Character("\(plot.id)")), modifiers: [])
                                #endif
                            }
                        }
                        .padding(.horizontal, horizontalSizeClass == .regular ? 40 : 20)
                        .padding(.vertical, 20)
                    }
                }

                // Selected building overlay
                if let selected = viewModel.selectedPlot {
                    BuildingDetailOverlay(
                        plot: selected,
                        onDismiss: { viewModel.selectedPlot = nil },
                        isLargeScreen: horizontalSizeClass == .regular
                    )
                    #if os(macOS)
                    .onExitCommand { viewModel.selectedPlot = nil }
                    #endif
                }
            }
        }
        .navigationTitle(filterEra?.rawValue ?? "Florence")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
    }
}

#Preview {
    CityView(filterEra: nil)
}

#Preview("Filtered - Ancient Rome") {
    CityView(filterEra: .ancientRome)
}
