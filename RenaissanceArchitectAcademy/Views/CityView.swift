import SwiftUI

/// City View - Leonardo's Notebook aesthetic
/// Displays building plots in an isometric grid with blueprint overlays
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

    private var completedCount: Int {
        filteredPlots.filter { $0.isCompleted }.count
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Parchment background with blueprint grid
                RenaissanceColors.parchmentGradient
                    .ignoresSafeArea()
                    .overlay(
                        BlueprintGridOverlay()
                            .opacity(0.05)
                    )

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Header for compact mode
                        if horizontalSizeClass != .regular {
                            CityHeaderView(
                                title: filterEra?.rawValue ?? "Florence",
                                completedCount: completedCount,
                                totalCount: filteredPlots.count
                            )
                            .padding(.horizontal)
                        }

                        // Progress summary for regular size
                        if horizontalSizeClass == .regular {
                            CityProgressBar(
                                completedCount: completedCount,
                                totalCount: filteredPlots.count
                            )
                            .padding(.horizontal, 40)
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
                                .bloomOnComplete(plot.isCompleted)
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

/// City header with title and progress
struct CityHeaderView: View {
    let title: String
    let completedCount: Int
    let totalCount: Int

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.custom("Cinzel-Bold", size: 32, relativeTo: .title))
                    .foregroundStyle(RenaissanceColors.sepiaInk)

                Text("\(completedCount)/\(totalCount) buildings completed")
                    .font(.custom("EBGaramond-Italic", size: 14, relativeTo: .caption))
                    .foregroundStyle(RenaissanceColors.stoneGray)
            }

            Spacer()

            // Completion seal
            if completedCount == totalCount && totalCount > 0 {
                Image(systemName: "seal.fill")
                    .font(.title)
                    .foregroundStyle(RenaissanceColors.goldSuccess)
            }
        }
    }
}

/// Progress bar for city completion
struct CityProgressBar: View {
    let completedCount: Int
    let totalCount: Int

    private var progress: Double {
        guard totalCount > 0 else { return 0 }
        return Double(completedCount) / Double(totalCount)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("City Progress")
                    .font(.custom("Cinzel-Regular", size: 14, relativeTo: .caption))
                    .foregroundStyle(RenaissanceColors.sepiaInk)

                Spacer()

                Text("\(completedCount)/\(totalCount)")
                    .font(.custom("EBGaramond-Regular", size: 14, relativeTo: .caption))
                    .foregroundStyle(RenaissanceColors.stoneGray)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: 4)
                        .fill(RenaissanceColors.stoneGray.opacity(0.2))

                    // Progress fill
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [RenaissanceColors.sageGreen, RenaissanceColors.goldSuccess],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress)
                        .animation(.easeInOut(duration: 0.5), value: progress)
                }
            }
            .frame(height: 8)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(RenaissanceColors.parchment)
                .shadow(color: RenaissanceColors.sepiaInk.opacity(0.08), radius: 4, y: 2)
        )
    }
}

/// Blueprint grid overlay for authentic Leonardo feel
struct BlueprintGridOverlay: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let spacing: CGFloat = 40

                // Vertical lines
                var x: CGFloat = 0
                while x < geometry.size.width {
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: geometry.size.height))
                    x += spacing
                }

                // Horizontal lines
                var y: CGFloat = 0
                while y < geometry.size.height {
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                    y += spacing
                }
            }
            .stroke(RenaissanceColors.blueprintBlue, lineWidth: 0.5)
        }
    }
}

#Preview {
    CityView(filterEra: nil)
}

#Preview("Filtered - Ancient Rome") {
    CityView(filterEra: .ancientRome)
}

#Preview {
    CityView(filterEra: nil)
}

#Preview("Filtered - Ancient Rome") {
    CityView(filterEra: .ancientRome)
}
