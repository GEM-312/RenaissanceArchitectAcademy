import SwiftUI

/// City View - Leonardo's Notebook aesthetic
/// Displays building plots in an isometric grid with blueprint overlays
struct CityView: View {
    var viewModel: CityViewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Namespace private var buildingHero

    @State private var showWorkshop = false

    // Sketching navigation state
    @State private var showingSketching = false
    @State private var activeSketchingChallenge: SketchingChallenge? = nil

    var filterEra: Era?
    var workshopState: WorkshopState = WorkshopState()
    var onNavigate: ((SidebarDestination) -> Void)? = nil

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
                            if let onNavigate {
                                Button {
                                    onNavigate(.cityMap)
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "chevron.left")
                                            .font(.caption)
                                        Text("Map")
                                            .font(RenaissanceFont.footnote)
                                    }
                                    .foregroundStyle(RenaissanceColors.renaissanceBlue)
                                }
                                .padding(.horizontal)
                            }

                            HStack(alignment: .top) {
                                CityHeaderView(
                                    title: filterEra?.rawValue ?? "Florence",
                                    completedCount: completedCount,
                                    totalCount: filteredPlots.count
                                )
                                Spacer()
                                workshopButton
                            }
                            .padding(.horizontal)
                        }

                        // Progress summary + Workshop button for regular size
                        if horizontalSizeClass == .regular {
                            if let onNavigate {
                                Button {
                                    onNavigate(.cityMap)
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "chevron.left")
                                            .font(.caption)
                                        Text("Map")
                                            .font(RenaissanceFont.footnote)
                                    }
                                    .foregroundStyle(RenaissanceColors.renaissanceBlue)
                                }
                                .padding(.horizontal, 40)
                            }

                            HStack {
                                CityProgressBar(
                                    completedCount: completedCount,
                                    totalCount: filteredPlots.count
                                )

                                workshopButton
                            }
                            .padding(.horizontal, 40)
                        }

                        // Building plots grid
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(filteredPlots) { plot in
                                BuildingPlotView(
                                    plot: plot,
                                    isLargeScreen: horizontalSizeClass == .regular,
                                    heroNamespace: buildingHero
                                ) {
                                    withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                                        viewModel.selectPlot(plot)
                                    }
                                }
                                .bloomOnComplete(plot.isCompleted)
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
                        onDismiss: {
                            withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                                viewModel.selectedPlot = nil
                            }
                        },
                        onBeginChallenge: {
                            // Check for sketching challenge
                            if let sketchChallenge = SketchingContent.sketchingChallenge(for: selected.building.name) {
                                activeSketchingChallenge = sketchChallenge
                                viewModel.selectedPlot = nil
                                showingSketching = true
                            }
                        },
                        isLargeScreen: horizontalSizeClass == .regular,
                        heroNamespace: buildingHero
                    )
                    #if os(macOS)
                    .onExitCommand { viewModel.selectedPlot = nil }
                    #endif
                }

                // Sketching Challenge view (full screen)
                if showingSketching, let sketchChallenge = activeSketchingChallenge {
                    SketchingChallengeView(
                        challenge: sketchChallenge,
                        onComplete: { completedPhases in
                            // Update sketching progress
                            if let plot = viewModel.buildingPlots.first(where: { $0.building.name == sketchChallenge.buildingName }) {
                                viewModel.completeSketchingPhase(for: plot.id, phases: completedPhases)
                            }
                            showingSketching = false
                            activeSketchingChallenge = nil
                        },
                        onDismiss: {
                            showingSketching = false
                            activeSketchingChallenge = nil
                        }
                    )
                    .transition(.move(edge: .trailing))
                }
            }
        }
        .navigationTitle(filterEra?.rawValue ?? "Florence")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
        #if os(iOS)
        .fullScreenCover(isPresented: $showWorkshop) {
            WorkshopView(workshop: workshopState, returnToLessonPlotId: .constant(nil))
        }
        #else
        .sheet(isPresented: $showWorkshop) {
            WorkshopView(workshop: workshopState, returnToLessonPlotId: .constant(nil))
                .frame(minWidth: 900, minHeight: 600)
        }
        #endif
    }

    private var workshopButton: some View {
        Button {
            showWorkshop = true
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "hammer.fill")
                    .font(.caption)
                Text("Workshop")
                    .font(RenaissanceFont.footnote)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(RenaissanceColors.terracotta)
            )
            .foregroundStyle(.white)
        }
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
                    .font(.custom("Cinzel-Regular", size: 32, relativeTo: .title))
                    .foregroundStyle(RenaissanceColors.sepiaInk)

                Text("\(completedCount)/\(totalCount) buildings completed")
                    .font(RenaissanceFont.footnote)
                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))
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
                    .font(.custom("EBGaramond-Regular", size: 16, relativeTo: .caption))
                    .foregroundStyle(RenaissanceColors.sepiaInk)

                Spacer()

                Text("\(completedCount)/\(totalCount)")
                    .font(RenaissanceFont.footnote)
                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))
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
            ZStack {
                RenaissanceColors.parchment.opacity(0.95)

                // Engineering border
                ZStack {
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(RenaissanceColors.sepiaInk.opacity(0.5), lineWidth: 1)
                        .padding(2)

                    RoundedRectangle(cornerRadius: 1)
                        .stroke(RenaissanceColors.sepiaInk.opacity(0.3), lineWidth: 0.5)
                        .padding(5)
                }
            }
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
    CityView(viewModel: CityViewModel(), filterEra: nil)
}

#Preview("Filtered - Ancient Rome") {
    CityView(viewModel: CityViewModel(), filterEra: .ancientRome)
}
