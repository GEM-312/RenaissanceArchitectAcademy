import SwiftUI

struct CityView: View {
    @StateObject private var viewModel = CityViewModel()

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // City background (placeholder)
                RenaissanceColors.parchment
                    .ignoresSafeArea()

                // Building plots grid
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 20) {
                    ForEach(viewModel.buildingPlots) { plot in
                        BuildingPlotView(plot: plot) {
                            viewModel.selectPlot(plot)
                        }
                    }
                }
                .padding(40)

                // Selected building overlay
                if let selected = viewModel.selectedPlot {
                    BuildingDetailOverlay(
                        plot: selected,
                        onDismiss: { viewModel.selectedPlot = nil }
                    )
                }
            }
        }
    }
}

#Preview {
    CityView()
}
