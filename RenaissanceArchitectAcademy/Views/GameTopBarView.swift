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
                                .font(.custom("EBGaramond-SemiBold", size: 18))
                                .foregroundStyle(RenaissanceColors.sepiaInk)
                                .padding(.horizontal, 14)
                                .padding(.vertical, Spacing.xs)
                                .background(
                                    Capsule()
                                        .fill(RenaissanceColors.parchment.opacity(0.92))
                                )
                                .overlay(
                                    Capsule()
                                        .strokeBorder(RenaissanceColors.warmBrown.opacity(0.3), lineWidth: 0.5)
                    .blur(radius: 0.2)
                                )
                                .padding(6)
                                .background(
                                    RoundedRectangle(cornerRadius: 24)
                                        .fill(RenaissanceColors.parchment.opacity(0.3))
                                )

                            // Gold Florins badge
                            HStack(spacing: 4) {
                                Image(systemName: "dollarsign.circle.fill")
                                    .font(.caption)
                                    .foregroundStyle(RenaissanceColors.warmBrown)
                                Text("\(viewModel.goldFlorins)")
                                    .font(.custom("EBGaramond-Medium", size: 15))
                                    .foregroundStyle(RenaissanceColors.sepiaInk)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, Spacing.xs)
                            .background(
                                Capsule()
                                    .fill(RenaissanceColors.parchment.opacity(0.92))
                            )
                            .overlay(
                                Capsule()
                                    .strokeBorder(RenaissanceColors.warmBrown.opacity(0.3), lineWidth: 0.5)
                    .blur(radius: 0.2)
                            )
                            .padding(6)
                            .background(
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(RenaissanceColors.parchment.opacity(0.3))
                            )
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
                navButton(icon: "book.fill", label: "Lesson", action: returnAction)
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

    // MARK: - Nav Button — Bottega Jobs capsule style with glass backing

    private func navButton(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(RenaissanceColors.warmBrown)
                Text(label)
                    .font(.custom("EBGaramond-Medium", size: 13))
                    .foregroundStyle(RenaissanceColors.sepiaInk)
                Image(systemName: "chevron.right")
                    .font(.system(size: 10))
                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.5))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, Spacing.xs)
            .background(
                Capsule()
                    .fill(RenaissanceColors.parchment.opacity(0.92))
            )
            .overlay(
                Capsule()
                    .strokeBorder(RenaissanceColors.warmBrown.opacity(0.3), lineWidth: 0.5)
                    .blur(radius: 0.2)
            )
            .padding(6)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(RenaissanceColors.parchment.opacity(0.3))
            )
                    }
        .buttonStyle(.plain)
    }

    // MARK: - Avatar Profile Card (bottom-left corner)

    private func avatarProfileCard(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                if let state = onboardingState {
                    let prefix = state.apprenticeGender == .boy ? "AvatarBoyCleanFrame" : "AvatarGirlCleanFrame"
                    Image("\(prefix)00")
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    Text(state.apprenticeName.isEmpty ? "Profile" : state.apprenticeName)
                        .font(.custom("EBGaramond-SemiBold", size: 16))
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                        .lineLimit(1)
                } else {
                    Image(systemName: "person.fill")
                        .font(.system(size: 40, weight: .medium))
                        .foregroundStyle(RenaissanceColors.iconOchre)
                        .frame(height: 140)
                    Text("Profile")
                        .font(.custom("EBGaramond-SemiBold", size: 16))
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                }
            }
            .padding(8)
            .frame(width: 160)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(RenaissanceColors.parchment.opacity(0.92))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(RenaissanceColors.warmBrown.opacity(0.3), lineWidth: 0.5)
                    .blur(radius: 0.2)
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
                Color.clear
                    .frame(width: 40, height: 34)

                Image(systemName: buildingIcon(for: plot.building.name))
                    .font(.custom("EBGaramond-Regular", size: 16, relativeTo: .subheadline))
                    .foregroundStyle(
                        isComplete ? RenaissanceColors.sageGreen :
                        isSketched ? RenaissanceColors.ochre :
                        RenaissanceColors.iconOchre.opacity(0.5)
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

// MARK: - Glass Button Modifier

extension View {
    func glassButton<S: Shape>(shape: S) -> some View {
        self
            .background(
                shape.fill(RenaissanceColors.parchment.opacity(0.5))
            )
            .overlay(
                shape
                    .stroke(RenaissanceColors.iconOchre.opacity(0.3), lineWidth: 0.1)
            )
                }
}
