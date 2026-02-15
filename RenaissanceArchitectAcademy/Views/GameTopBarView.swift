import SwiftUI

/// Floating navigation overlay — nav buttons on LEFT, building icons on RIGHT
/// Each button has its own small background, no big panel
struct GameTopBarView: View {
    let title: String
    @ObservedObject var viewModel: CityViewModel
    var onNavigate: (SidebarDestination) -> Void
    var showBackButton: Bool = false
    var onBack: (() -> Void)? = nil
    var onBackToMenu: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            // LEFT: Title + Nav buttons (flush left)
            VStack(alignment: .leading, spacing: 4) {
                // Title capsule
                Text(title)
                    .font(.custom("Cinzel-Bold", size: 16))
                    .foregroundStyle(RenaissanceColors.sepiaInk)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(RenaissanceColors.parchment.opacity(0.95))
                            .shadow(color: .black.opacity(0.08), radius: 2, y: 1)
                    )
                    .padding(.bottom, 4)

                navColumn
            }

            Spacer(minLength: 0)

            // RIGHT: Building achievement icons (flush right)
            buildingColumn
                .fixedSize()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Nav Column (LEFT side, flush left)

    private var navColumn: some View {
        VStack(alignment: .leading, spacing: 4) {
            if showBackButton, let onBack = onBack {
                navButton(icon: "chevron.left", label: "Back", action: onBack)
            }

            navButton(icon: "map.fill", label: "Map") {
                onNavigate(.cityMap)
            }

            navButton(icon: "building.2", label: "All") {
                onNavigate(.allBuildings)
            }

            navButton(icon: "building.columns", label: "Rome") {
                onNavigate(.era(.ancientRome))
            }

            navButton(icon: "paintpalette", label: "Ren.") {
                onNavigate(.era(.renaissance))
            }

            navButton(icon: "hammer.fill", label: "Workshop") {
                onNavigate(.workshop)
            }

            navButton(icon: "book.fill", label: "Tests") {
                onNavigate(.knowledgeTests)
            }

            navButton(icon: "person.fill", label: "Profile") {
                onNavigate(.profile)
            }

            if let onBackToMenu = onBackToMenu {
                navButton(icon: "house.fill", label: "Home", action: onBackToMenu)
            }
        }
    }

    // MARK: - Nav Button (with individual background)

    private func navButton(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.8))
                Text(label)
                    .font(.custom("EBGaramond-Regular", size: 11, relativeTo: .caption))
                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.6))
            }
            .frame(width: 60, height: 48)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(RenaissanceColors.parchment.opacity(0.95))
                    .shadow(color: .black.opacity(0.06), radius: 2, y: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Building Column (RIGHT side, with individual backgrounds)

    private var buildingColumn: some View {
        LazyVGrid(columns: [
            GridItem(.fixed(44), spacing: 2),
            GridItem(.fixed(44), spacing: 2)
        ], spacing: 2) {
            ForEach(viewModel.buildingPlots) { plot in
                buildingGridItem(plot)
            }
        }
    }

    private func buildingGridItem(_ plot: BuildingPlot) -> some View {
        let isComplete = plot.isCompleted
        let isSketched = plot.sketchingProgress.isSketchingComplete

        return VStack(spacing: 0) {
            ZStack {
                RoundedRectangle(cornerRadius: 5)
                    .fill(isComplete ? RenaissanceColors.sageGreen.opacity(0.25) :
                          isSketched ? RenaissanceColors.ochre.opacity(0.2) :
                          RenaissanceColors.parchment.opacity(0.9))
                    .shadow(color: .black.opacity(0.06), radius: 1, y: 1)
                    .frame(width: 40, height: 34)

                Image(systemName: buildingIcon(for: plot.building.name))
                    .font(.system(size: 16))
                    .foregroundStyle(
                        isComplete ? RenaissanceColors.sageGreen :
                        isSketched ? RenaissanceColors.ochre :
                        RenaissanceColors.stoneGray.opacity(0.6)
                    )
            }

            Text(String(format: "%02d", plot.id))
                .font(.system(size: 8, weight: .medium, design: .monospaced))
                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.4))
        }
    }

    // MARK: - Building Icons

    private func buildingIcon(for name: String) -> String {
        switch name {
        case "Aqueduct": return "drop.fill"
        case "Colosseum": return "theatermasks.fill"
        case "Roman Baths": return "humidity.fill"
        case "Pantheon": return "circle.circle"
        case "Roman Roads": return "road.lanes"
        case "Harbor": return "sailboat.fill"
        case "Siege Workshop": return "shield.fill"
        case "Insula": return "building.fill"
        case "Duomo", "Il Duomo": return "triangle.fill"
        case "Botanical Garden": return "leaf.fill"
        case "Glassworks": return "diamond.fill"
        case "Arsenal": return "hammer.fill"
        case "Anatomy Theater": return "figure.stand"
        case "Leonardo's Workshop": return "gearshape.fill"
        case "Flying Machine": return "airplane"
        case "Vatican Observatory": return "star.fill"
        case "Printing Press": return "book.fill"
        default: return "building.2.fill"
        }
    }
}
