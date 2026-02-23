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
    var onboardingState: OnboardingState? = nil
    var returnToLessonBuildingName: String? = nil
    var onReturnToLesson: (() -> Void)? = nil

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Top bar: nav buttons (left) + building icons (right)
            VStack {
                HStack(alignment: .top, spacing: 0) {
                    // LEFT: Title + Nav buttons (flush left)
                    VStack(alignment: .leading, spacing: 4) {
                        // Title + Florins row
                        HStack(spacing: 8) {
                            Text(title)
                                .font(.custom("Cinzel-Regular", size: 16))
                                .foregroundStyle(RenaissanceColors.sepiaInk)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 6)
                                .glassButton(shape: Capsule())

                            // Gold Florins badge
                            HStack(spacing: 4) {
                                Image(systemName: "dollarsign.circle.fill")
                                    .font(.custom("Mulish-Light", size: 14, relativeTo: .footnote))
                                    .foregroundStyle(RenaissanceColors.iconOchre)
                                Text("\(viewModel.goldFlorins)")
                                    .font(.custom("Cinzel-Regular", size: 13))
                                    .foregroundStyle(RenaissanceColors.sepiaInk)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .glassButton(shape: Capsule())
                        }
                        .padding(.bottom, 4)

                        navColumn
                    }

                    Spacer(minLength: 0)

                    // RIGHT: Building achievement icons (flush right)
                    buildingColumn
                        .fixedSize()
                }

                Spacer()
            }

            // Bottom-left: Avatar profile card
            avatarProfileCard {
                onNavigate(.profile)
            }
            .padding(.leading, 8)
            .padding(.bottom, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Nav Column (LEFT side, flush left)

    private var navColumn: some View {
        VStack(alignment: .leading, spacing: 4) {
            if showBackButton, let onBack = onBack {
                navButton(icon: "chevron.left", label: "Back", action: onBack)
            }

            if let buildingName = returnToLessonBuildingName, let returnAction = onReturnToLesson {
                Button(action: returnAction) {
                    VStack(spacing: 2) {
                        Image(systemName: "book.fill")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(RenaissanceColors.iconOchre)
                        Text("Lesson")
                            .font(.custom("Mulish-Light", size: 10, relativeTo: .caption))
                            .foregroundStyle(RenaissanceColors.sepiaInk)
                    }
                    .frame(width: 60, height: 48)
                    .glassButton(shape: RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Back to \(buildingName) lesson")
            }

            navButton(icon: "map.fill", label: "Map") {
                onNavigate(.cityMap)
            }

            navButton(icon: "building.2.fill", label: "All") {
                onNavigate(.allBuildings)
            }

            navButton(icon: "building.columns.fill", label: "Rome") {
                onNavigate(.era(.ancientRome))
            }

            navButton(icon: "paintpalette.fill", label: "Ren.") {
                onNavigate(.era(.renaissance))
            }

            navButton(icon: "hammer.fill", label: "Workshop") {
                onNavigate(.workshop)
            }

            navButton(icon: "leaf.fill", label: "Forest") {
                onNavigate(.forest)
            }

            navButton(icon: "book.fill", label: "Tests") {
                onNavigate(.knowledgeTests)
            }

            navButton(icon: "book.closed.fill", label: "Notes") {
                // Navigate to most recently modified notebook, or Pantheon default
                onNavigate(.notebook(4))
            }

            if let onBackToMenu = onBackToMenu {
                navButton(icon: "house.fill", label: "Home", action: onBackToMenu)
            }
        }
    }

    // MARK: - Nav Button — clear background, shadow + blurred border

    private func navButton(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(RenaissanceColors.iconOchre)
                Text(label)
                    .font(.custom("Mulish-Light", size: 11, relativeTo: .caption))
                    .foregroundStyle(RenaissanceColors.sepiaInk)
            }
            .frame(width: 60, height: 48)
            .glassButton(shape: RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Avatar Profile Card (bottom-left corner)

    private func avatarProfileCard(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                if let state = onboardingState {
                    let prefix = state.apprenticeGender == .boy ? "AvatarBoyFrame" : "AvatarGirlFrame"
                    Image("\(prefix)00")
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    Text(state.apprenticeName.isEmpty ? "Profile" : state.apprenticeName)
                        .font(.custom("Cinzel-Regular", size: 14))
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                        .lineLimit(1)
                } else {
                    Image(systemName: "person.fill")
                        .font(.system(size: 40, weight: .medium))
                        .foregroundStyle(RenaissanceColors.iconOchre)
                        .frame(height: 140)
                    Text("Profile")
                        .font(.custom("Cinzel-Regular", size: 14))
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                }
            }
            .padding(8)
            .frame(width: 160)
            .glassButton(shape: RoundedRectangle(cornerRadius: 16))
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
                    .font(.custom("Mulish-Light", size: 16, relativeTo: .subheadline))
                    .foregroundStyle(
                        isComplete ? RenaissanceColors.sageGreen :
                        isSketched ? RenaissanceColors.sepiaInk :
                        RenaissanceColors.sepiaInk.opacity(0.6)
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

// MARK: - Glass Button Modifier — no fill, shadow + blurred border

extension View {
    func glassButton<S: Shape>(shape: S) -> some View {
        self
            .background(
                shape
                    .fill(RenaissanceColors.parchment.opacity(0.8))
            )
            .overlay(
                shape
                    .stroke(RenaissanceColors.iconOchre.opacity(0.2), lineWidth: 1)
                    .blur(radius: 0.5)
            )
            .shadow(color: .black.opacity(0.1), radius: 6, y: 3)
    }
}
