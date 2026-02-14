import SwiftUI

/// Shared top navigation bar across all game screens (City Map, Workshop, Crafting Room)
/// Shows quick-nav buttons (Profile, Map, Eras) + horizontal building progress strip
struct GameTopBarView: View {
    let title: String
    @ObservedObject var viewModel: CityViewModel
    var onNavigate: (SidebarDestination) -> Void
    var showBackButton: Bool = false
    var onBack: (() -> Void)? = nil

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    private var isLargeScreen: Bool { horizontalSizeClass == .regular }

    var body: some View {
        VStack(spacing: 6) {
            // Row 1: Nav buttons + title
            HStack(spacing: 8) {
                // Back button (workshop/crafting only)
                if showBackButton, let onBack = onBack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(RenaissanceColors.renaissanceBlue)
                            .frame(width: 32, height: 32)
                            .background(
                                Circle()
                                    .fill(RenaissanceColors.parchment.opacity(0.95))
                                    .shadow(color: .black.opacity(0.08), radius: 2, y: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }

                // Quick-nav: Profile
                navButton(icon: "person.fill", label: "Profile") {
                    onNavigate(.profile)
                }

                // Quick-nav: Map
                navButton(icon: "map.fill", label: "Map") {
                    onNavigate(.cityMap)
                }

                // Quick-nav: Eras
                navButton(icon: "building.columns.fill", label: "Eras") {
                    onNavigate(.allBuildings)
                }

                // Quick-nav: Workshop
                navButton(icon: "hammer.fill", label: "Workshop") {
                    onNavigate(.workshop)
                }

                Spacer()

                // Title capsule
                Text(title)
                    .font(.custom("Cinzel-Bold", size: isLargeScreen ? 18 : 14, relativeTo: .headline))
                    .foregroundStyle(RenaissanceColors.sepiaInk)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(RenaissanceColors.parchment.opacity(0.95))
                            .shadow(color: .black.opacity(0.08), radius: 2, y: 1)
                    )
            }

            // Row 2: Building progress strip
            buildingStrip
        }
    }

    // MARK: - Nav Button

    private func navButton(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Image(systemName: icon)
                    .font(.system(size: 13))
                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))
                Text(label)
                    .font(.custom("EBGaramond-Regular", size: 8, relativeTo: .caption2))
                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.5))
            }
            .frame(width: 40, height: 36)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(RenaissanceColors.parchment.opacity(0.95))
                    .shadow(color: .black.opacity(0.06), radius: 2, y: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Building Progress Strip

    private var buildingStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(viewModel.buildingPlots) { plot in
                    buildingStripItem(plot)
                }
            }
            .padding(.horizontal, 4)
        }
        .frame(height: 42)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(RenaissanceColors.parchment.opacity(0.9))
                .shadow(color: .black.opacity(0.06), radius: 2, y: 1)
        )
    }

    private func buildingStripItem(_ plot: BuildingPlot) -> some View {
        let isComplete = plot.isCompleted
        let isSketched = plot.sketchingProgress.isSketchingComplete

        return VStack(spacing: 1) {
            // Building icon
            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(isComplete ? RenaissanceColors.sageGreen.opacity(0.2) :
                          isSketched ? RenaissanceColors.ochre.opacity(0.15) :
                          RenaissanceColors.stoneGray.opacity(0.1))
                    .frame(width: 26, height: 22)

                Image(systemName: buildingIcon(for: plot.building.name))
                    .font(.system(size: 10))
                    .foregroundStyle(
                        isComplete ? RenaissanceColors.sageGreen :
                        isSketched ? RenaissanceColors.ochre :
                        RenaissanceColors.stoneGray.opacity(0.6)
                    )
            }

            // Progress number
            Text(String(format: "%02d", plot.id))
                .font(.system(size: 8, weight: .medium, design: .monospaced))
                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.4))
        }
    }

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
