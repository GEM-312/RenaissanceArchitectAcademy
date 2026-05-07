import SwiftUI

/// Floating navigation overlay — nav buttons on LEFT, building icons on RIGHT
/// Each button has its own small background, no big panel
struct GameTopBarView: View {
    let title: String
    var viewModel: CityViewModel
    var onNavigate: (SidebarDestination) -> Void
    var showBackButton: Bool = false
    var onBack: (() -> Void)? = nil
    var onBackToMenu: (() -> Void)? = nil
    var onboardingState: OnboardingState? = nil
    var returnToLessonBuildingName: String? = nil
    var onReturnToLesson: (() -> Void)? = nil
    /// Which destination this view represents — hides that button from the dropdown
    var currentDestination: SidebarDestination? = nil
    /// Hide the bottom-left avatar card entirely
    var hideAvatarCard: Bool = false
    /// Hide just the avatar image (keep name visible) — e.g. when player is on the map
    var hideAvatarImage: Bool = false
    /// Optional dialog content shown to the right of the sprite inside the same card
    var avatarDialogContent: AnyView? = nil

    @Environment(\.gameSettings) private var settings
    @State private var isNavExpanded = false
    @State private var showSettings = false
    // Game Center presented via GameCenterManager.showDashboard()

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Top bar: nav buttons (left) + building icons (right).
            // Anchored to top via .frame(maxHeight:.infinity, alignment:.top)
            // — replaces the previous VStack { HStack; Spacer } pattern.
            HStack(alignment: .top, spacing: 0) {
                    // LEFT: Title + Nav buttons (flush left)
                    VStack(alignment: .leading, spacing: 4) {
                        // Title + Florins row
                        HStack(spacing: 8) {
                            // Tappable title toggles nav dropdown
                            Button {
                                withAnimation(.spring(response: 0.45, dampingFraction: 0.65, blendDuration: 0)) {
                                    isNavExpanded.toggle()
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    Text(title)
                                        .font(RenaissanceFont.button)
                                        .foregroundStyle(settings.pillTextColor)
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundStyle(settings.pillSecondaryColor)
                                        .rotationEffect(.degrees(isNavExpanded ? 180 : 0))
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, Spacing.xs)
                                .background(
                                    Capsule()
                                        .fill(settings.pillBackground)
                                )
                                .overlay(
                                    Capsule()
                                        .strokeBorder(settings.pillBorderColor, lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)

                            // Gold Florins badge
                            HStack(spacing: 4) {
                                Image(systemName: "dollarsign.circle.fill")
                                    .font(.caption)
                                    .foregroundStyle(settings.pillTextColor)
                                Text("\(viewModel.goldFlorins)")
                                    .font(.custom("EBGaramond-Medium", size: 15))
                                    .foregroundStyle(settings.pillTextColor)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, Spacing.xs)
                            .background(
                                Capsule()
                                    .fill(settings.pillBackground)
                            )
                            .overlay(
                                Capsule()
                                    .strokeBorder(settings.pillBorderColor, lineWidth: 1)
                            )
                        }
                        .padding(.bottom, 4)

                        // Dropdown nav with staggered spring animation
                        if isNavExpanded {
                            navColumn
                                .transition(.move(edge: .top).combined(with: .opacity))
                        }
                    }

                    Spacer(minLength: 0)

                    // RIGHT: Building achievement icons (flush right)
                    buildingColumn
                        .fixedSize()
                }
            .frame(maxHeight: .infinity, alignment: .top)

            // Bottom-left: Dialog content (no avatar card — profile is in nav menu)
            if let dialog = avatarDialogContent {
                dialog
                    .adaptiveWidth(400, compact: 300)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(settings.cardBackground)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(settings.cardBorderColor, lineWidth: 0.5)
                            .blur(radius: 0.2)
                    )
                    .padding(.leading, 8)
                    .padding(.bottom, 8)
                    .transition(.move(edge: .leading).combined(with: .opacity))
            }

            // Settings overlay
            if showSettings {
                SettingsView(settings: settings) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showSettings = false
                    }
                }
                .transition(.opacity)
                .zIndex(100)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // Game Center dashboard presented via GameCenterManager.showDashboard()
    }

    // MARK: - Nav Column (LEFT side, flush left)

    private var navColumn: some View {
        let items = navItems
        return VStack(alignment: .leading, spacing: 4) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                navButton(icon: item.icon, label: item.label, action: item.action)
                    .accessibilityLabel(item.accessibilityLabel ?? item.label)
                    .offset(y: isNavExpanded ? 0 : -CGFloat(index + 1) * 10)
                    .opacity(isNavExpanded ? 1 : 0)
                    .animation(
                        .spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0)
                        .delay(Double(index) * 0.04),
                        value: isNavExpanded
                    )
            }
        }
    }

    private struct NavItem {
        let icon: String
        let label: String
        let destination: SidebarDestination?
        let action: () -> Void
        var accessibilityLabel: String? = nil
    }

    /// Returns true if a destination matches the current view (should be hidden)
    private func isCurrentDestination(_ dest: SidebarDestination?) -> Bool {
        guard let dest = dest, let current = currentDestination else { return false }
        switch (current, dest) {
        case (.cityMap, .cityMap): return true
        case (.workshop, .workshop): return true
        case (.forest, .forest): return true
        case (.allBuildings, .allBuildings): return true
        case (.era(let a), .era(let b)) where a == b: return true
        default: return false
        }
    }

    private var navItems: [NavItem] {
        var items: [NavItem] = []

        if showBackButton, let onBack = onBack {
            items.append(NavItem(icon: "chevron.left", label: "Back", destination: nil, action: onBack))
        }

        if let buildingName = returnToLessonBuildingName, let returnAction = onReturnToLesson {
            items.append(NavItem(icon: "book.fill", label: "Lesson", destination: nil, action: returnAction, accessibilityLabel: "Back to \(buildingName) lesson"))
        }

        let allItems: [NavItem] = [
            NavItem(icon: "map.fill", label: "Map", destination: .cityMap) { [onNavigate] in onNavigate(.cityMap) },
            NavItem(icon: "building.2.fill", label: "All", destination: .allBuildings) { [onNavigate] in onNavigate(.allBuildings) },
            NavItem(icon: "building.columns.fill", label: "Rome", destination: .era(.ancientRome)) { [onNavigate] in onNavigate(.era(.ancientRome)) },
            NavItem(icon: "paintpalette.fill", label: "Ren.", destination: .era(.renaissance)) { [onNavigate] in onNavigate(.era(.renaissance)) },
            NavItem(icon: "hammer.fill", label: "Workshop", destination: .workshop) { [onNavigate] in onNavigate(.workshop) },
            NavItem(icon: "leaf.fill", label: "Forest", destination: .forest) { [onNavigate] in onNavigate(.forest) },
            NavItem(icon: "book.closed.fill", label: "Notes", destination: .notebookPicker) { [onNavigate] in onNavigate(.notebookPicker) },
        ]

        items.append(contentsOf: allItems.filter { !isCurrentDestination($0.destination) })

        // Game Center button (only when authenticated)
        if GameCenterManager.shared.isAuthenticated {
            items.append(NavItem(icon: "trophy.fill", label: "Game Center", destination: nil, action: {
                GameCenterManager.shared.showDashboard()
                withAnimation(.spring(response: 0.45, dampingFraction: 0.65)) {
                    isNavExpanded = false
                }
            }))
        }

        // Profile button
        items.append(NavItem(icon: "person.fill", label: "Profile", destination: .profile) { [onNavigate] in
            onNavigate(.profile)
            withAnimation(.spring(response: 0.45, dampingFraction: 0.65)) {
                isNavExpanded = false
            }
        })

        // Settings button — always last before Home
        items.append(NavItem(icon: "gearshape.fill", label: "Settings", destination: nil, action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                showSettings = true
                isNavExpanded = false
            }
        }))

        if let onBackToMenu = onBackToMenu {
            items.append(NavItem(icon: "house.fill", label: "Home", destination: nil, action: onBackToMenu))
        }

        return items
    }

    // MARK: - Nav Button — theme-aware capsule style

    private func navButton(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(settings.pillTextColor)
                Text(label)
                    .font(.custom("EBGaramond-Medium", size: 13))
                    .foregroundStyle(settings.pillTextColor)
                Image(systemName: "chevron.right")
                    .font(.system(size: 10))
                    .foregroundStyle(settings.pillSecondaryColor)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, Spacing.xs)
            .background(
                Capsule()
                    .fill(settings.pillBackground)
            )
            .overlay(
                Capsule()
                    .strokeBorder(settings.pillBorderColor, lineWidth: 1)
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
                .foregroundStyle(settings.cardTextColor.opacity(0.4))
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
                shape.fill(GameSettings.shared.dialogBackground.opacity(0.5))
            )
            .overlay(
                shape
                    .stroke(RenaissanceColors.iconOchre.opacity(0.3), lineWidth: 0.1)
            )
                }
}
