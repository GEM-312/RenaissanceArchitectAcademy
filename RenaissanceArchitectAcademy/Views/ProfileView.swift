import SwiftUI

/// Student Profile View - Leonardo's Notebook aesthetic
/// Displays achievements, science mastery, resources, and progress
/// Layout matches the hand-drawn sketch: Header → Materials+Achievements → Sciences → Stats+Mastery
struct ProfileView: View {
    @ObservedObject var viewModel: CityViewModel
    var workshopState: WorkshopState
    var onboardingState: OnboardingState
    var onNavigate: ((SidebarDestination) -> Void)? = nil
    var onBackToMenu: (() -> Void)? = nil

    @State private var selectedCategory: Achievement.AchievementCategory?

    /// Display name from onboarding, fallback to "Young Architect"
    private var displayName: String {
        let name = onboardingState.apprenticeName
        return name.isEmpty ? "Young Architect" : name
    }

    /// Avatar frame prefix based on gender choice
    private var avatarFramePrefix: String {
        switch onboardingState.apprenticeGender {
        case .boy: return "AvatarBoyCleanFrame"
        case .girl: return "AvatarGirlCleanFrame"
        }
    }

    /// Number of completed buildings from live city data
    private var completedBuildings: Int {
        viewModel.buildingPlots.filter(\.isCompleted).count
    }

    /// Total raw materials collected
    private var totalRawMaterials: Int {
        workshopState.rawMaterials.values.reduce(0, +)
    }

    /// Total crafted items
    private var totalCraftedItems: Int {
        workshopState.craftedMaterials.values.reduce(0, +)
    }

    // MARK: - Computed Progress (from real game data)

    /// Overall progress: milestones completed / total possible milestones
    /// Each building: lesson (always) + quiz (if exists) + sketch (if exists) + completion (always)
    private var computedProgress: Double {
        var totalMilestones = 0
        var doneMilestones = 0

        for plot in viewModel.buildingPlots {
            let progress = viewModel.buildingProgressMap[plot.id] ?? BuildingProgress()

            // Lesson (all 17 buildings)
            totalMilestones += 1
            if progress.lessonRead { doneMilestones += 1 }

            // Quiz (only buildings with quiz content)
            if ChallengeContent.interactiveChallenge(for: plot.building.name) != nil {
                totalMilestones += 1
                if progress.quizPassed { doneMilestones += 1 }
            }

            // Sketch (only buildings with sketching content)
            if SketchingContent.sketchingChallenge(for: plot.building.name) != nil {
                totalMilestones += 1
                if progress.sketchCompleted { doneMilestones += 1 }
            }

            // Building completed
            totalMilestones += 1
            if plot.isCompleted { doneMilestones += 1 }
        }

        guard totalMilestones > 0 else { return 0 }
        return Double(doneMilestones) / Double(totalMilestones)
    }

    /// Mastery level derived from actual progress
    private var computedMasteryLevel: MasteryLevel {
        let progress = computedProgress
        if progress >= 0.67 { return .master }
        if progress >= 0.33 { return .architect }
        return .apprentice
    }

    /// Science masteries computed from earned badges across buildings
    private var computedScienceMasteries: [ScienceMastery] {
        Science.allCases.map { science in
            let buildingsWithScience = viewModel.buildingPlots.filter { $0.building.sciences.contains(science) }
            let totalForScience = buildingsWithScience.count
            let completedForScience = buildingsWithScience.filter { plot in
                let progress = viewModel.buildingProgressMap[plot.id] ?? BuildingProgress()
                return progress.scienceBadgesEarned.contains(science)
            }.count
            return ScienceMastery(
                id: science.rawValue,
                science: science,
                level: completedForScience,
                challengesCompleted: completedForScience,
                totalChallenges: totalForScience
            )
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // ── Top bar: Title + Florins ──
                HStack(spacing: 8) {
                    Text("Profile")
                        .font(.custom("Cinzel-Bold", size: 20))
                        .foregroundStyle(RenaissanceColors.sepiaInk)

                    Spacer()

                    HStack(spacing: 4) {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(RenaissanceColors.goldSuccess)
                        Text("\(viewModel.goldFlorins)")
                            .font(.custom("EBGaramond-Regular", size: 16))
                            .foregroundStyle(RenaissanceColors.sepiaInk)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(RenaissanceColors.parchment.opacity(0.9))
                    )
                }

                // ── Row 1: Header (rank | avatar | currency) ──
                ProfileHeaderRow(
                    displayName: displayName,
                    avatarFramePrefix: avatarFramePrefix,
                    masteryLevel: computedMasteryLevel,
                    goldFlorins: viewModel.goldFlorins
                )

                // ── Row 2: Materials + Achievements side-by-side ──
                HStack(alignment: .top, spacing: 16) {
                    MaterialsCard(workshopState: workshopState)
                    AchievementsSection(
                        achievements: StudentProfile.defaultAchievements,
                        selectedCategory: $selectedCategory
                    )
                }

                // ── Row 3: Sciences horizontal scroll ──
                SciencesRow(masteries: computedScienceMasteries)

                // ── Row 4: Statistics + Mastery Level side-by-side ──
                HStack(alignment: .top, spacing: 16) {
                    StatisticsCard(
                        buildingPlots: viewModel.buildingPlots,
                        totalPlayTime: viewModel.totalPlayTime
                    )
                    MasteryLevelCard(
                        masteryLevel: computedMasteryLevel,
                        progress: computedProgress
                    )
                }

                // ── Navigation Row ──
                if let onNavigate = onNavigate {
                    ProfileNavRow(
                        onNavigate: onNavigate,
                        onBackToMenu: onBackToMenu
                    )
                }
            }
            .padding()
        }
        .background(RenaissanceColors.parchmentGradient)
    }
}

// MARK: - Row 1: Profile Header Row (avatar as background)
struct ProfileHeaderRow: View {
    let displayName: String
    let avatarFramePrefix: String
    let masteryLevel: MasteryLevel
    let goldFlorins: Int

    @State private var currentFrame: Int = 0
    private let frameCount = 15
    private let fps: Double = 10

    var body: some View {
        ZStack {
            // Avatar animation as background
            Image(String(format: "%@%02d", avatarFramePrefix, currentFrame))
                .resizable()
                .scaledToFit()
                .frame(height: 280)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .opacity(0.5)

            // Overlay: rank (left), name (center), florins (right)
            VStack {
                Spacer()

                HStack(alignment: .bottom) {
                    // Left — Current Rank
                    VStack(spacing: 4) {
                        Text(masteryLevel.icon)
                            .font(.custom("EBGaramond-Regular", size: 28, relativeTo: .title3))
                        Text(masteryLevel.rawValue)
                            .font(.custom("EBGaramond-Regular", size: 14))
                            .foregroundStyle(RenaissanceColors.sepiaInk)
                    }
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(RenaissanceColors.parchment.opacity(0.85))
                    )

                    Spacer()

                    // Center — Name
                    Text(displayName)
                        .font(.custom("EBGaramond-SemiBold", size: 22))
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(RenaissanceColors.parchment.opacity(0.85))
                        )

                    Spacer()

                    // Right — Gold Florins
                    VStack(spacing: 4) {
                        ZStack {
                            Circle()
                                .fill(RenaissanceColors.goldSuccess)
                                .frame(width: 36, height: 36)
                            Image(systemName: "dollarsign.circle.fill")
                                .font(.custom("EBGaramond-Regular", size: 22, relativeTo: .title3))
                                .foregroundStyle(.white)
                        }
                        Text("\(goldFlorins)")
                            .font(.custom("EBGaramond-Regular", size: 15))
                            .foregroundStyle(RenaissanceColors.sepiaInk)
                    }
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(RenaissanceColors.parchment.opacity(0.85))
                    )
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
            }
        }
        .frame(height: 280)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(RenaissanceColors.parchment.opacity(0.6))
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 1.0 / fps, repeats: true) { timer in
                if currentFrame < frameCount - 1 {
                    currentFrame += 1
                } else {
                    timer.invalidate()
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(RenaissanceColors.parchment.opacity(0.8))
        )
    }
}

// MARK: - Row 2 Left: Materials Card
struct MaterialsCard: View {
    var workshopState: WorkshopState

    private var rawItems: [(Material, Int)] {
        Material.allCases.compactMap { mat in
            let count = workshopState.rawMaterials[mat] ?? 0
            return count > 0 ? (mat, count) : nil
        }
    }

    private var craftedItems: [(CraftedItem, Int)] {
        CraftedItem.allCases.compactMap { item in
            let count = workshopState.craftedMaterials[item] ?? 0
            return count > 0 ? (item, count) : nil
        }
    }

    private var hasAnyMaterials: Bool {
        !rawItems.isEmpty || !craftedItems.isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "shippingbox.fill")
                    .foregroundStyle(RenaissanceColors.warmBrown)
                Text("Materials")
                    .font(.custom("Cinzel-Bold", size: 15))
                    .foregroundStyle(RenaissanceColors.sepiaInk)
            }

            if hasAnyMaterials {
                // Raw materials
                if !rawItems.isEmpty {
                    Text("Raw")
                        .font(.custom("EBGaramond-Regular", size: 11))
                        .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.6))
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 6) {
                        ForEach(rawItems, id: \.0) { mat, count in
                            VStack(spacing: 2) {
                                Text(mat.icon)
                                    .font(.custom("EBGaramond-Regular", size: 20, relativeTo: .title3))
                                Text("\(count)")
                                    .font(.custom("EBGaramond-Regular", size: 11))
                                    .foregroundStyle(RenaissanceColors.sepiaInk)
                            }
                        }
                    }
                }

                // Crafted materials
                if !craftedItems.isEmpty {
                    Text("Crafted")
                        .font(.custom("EBGaramond-Regular", size: 11))
                        .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.6))
                        .padding(.top, 4)
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 6) {
                        ForEach(craftedItems, id: \.0) { item, count in
                            VStack(spacing: 2) {
                                Text(item.icon)
                                    .font(.custom("EBGaramond-Regular", size: 20, relativeTo: .title3))
                                Text("\(count)")
                                    .font(.custom("EBGaramond-Regular", size: 11))
                                    .foregroundStyle(RenaissanceColors.sepiaInk)
                            }
                        }
                    }
                }
            } else {
                Text("Visit the Workshop\nto collect materials!")
                    .font(.custom("EBGaramond-Regular", size: 12))
                    .foregroundStyle(RenaissanceColors.sepiaInk)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(RenaissanceColors.parchment)
        )
    }
}

// MARK: - Row 2 Right: Achievements Section
struct AchievementsSection: View {
    let achievements: [Achievement]
    @Binding var selectedCategory: Achievement.AchievementCategory?

    var filteredAchievements: [Achievement] {
        if let category = selectedCategory {
            return achievements.filter { $0.category == category }
        }
        return achievements
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "seal.fill")
                    .foregroundStyle(RenaissanceColors.goldSuccess)
                Text("Achievements")
                    .font(.custom("Cinzel-Bold", size: 15))
                    .foregroundStyle(RenaissanceColors.sepiaInk)
                Spacer()
                Text("\(achievements.filter { $0.isUnlocked }.count)/\(achievements.count)")
                    .font(.custom("EBGaramond-Regular", size: 12))
                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.6))
            }

            // Category filter chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    CategoryChip(title: "All", isSelected: selectedCategory == nil) {
                        selectedCategory = nil
                    }
                    ForEach(Achievement.AchievementCategory.allCases, id: \.self) { category in
                        CategoryChip(
                            title: category.rawValue,
                            isSelected: selectedCategory == category
                        ) {
                            selectedCategory = category
                        }
                    }
                }
            }

            // Achievement badges grid
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 8) {
                ForEach(filteredAchievements) { achievement in
                    AchievementBadge(achievement: achievement)
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(RenaissanceColors.parchment)
        )
    }
}

struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.custom("EBGaramond-Regular", size: 11))
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(isSelected ? RenaissanceColors.ochre : RenaissanceColors.parchment)
                )
                .foregroundStyle(isSelected ? .white : RenaissanceColors.sepiaInk)
        }
        .buttonStyle(.plain)
    }
}

struct AchievementBadge: View {
    let achievement: Achievement

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(
                        achievement.isUnlocked
                            ? RenaissanceColors.goldSuccess
                            : RenaissanceColors.stoneGray.opacity(0.5)
                    )
                    .frame(width: 44, height: 44)

                Image(systemName: achievement.iconName)
                    .font(.body)
                    .foregroundStyle(
                        achievement.isUnlocked ? .white : RenaissanceColors.sepiaInk
                    )
            }

            Text(achievement.name)
                .font(.custom("EBGaramond-Regular", size: 10))
                .foregroundStyle(
                    achievement.isUnlocked
                        ? RenaissanceColors.sepiaInk
                        : RenaissanceColors.sepiaInk
                )
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .frame(width: 64)
        .opacity(achievement.isUnlocked ? 1.0 : 0.6)
    }
}

// MARK: - Row 3: Sciences Horizontal Scroll
struct SciencesRow: View {
    let masteries: [ScienceMastery]

    // Icons with squared backgrounds that need soft edge blending
    private func needsBlending(_ science: Science) -> Bool {
        science == .chemistry || science == .engineering
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "books.vertical.fill")
                    .foregroundStyle(RenaissanceColors.renaissanceBlue)
                Text("Sciences")
                    .font(.custom("Cinzel-Bold", size: 15))
                    .foregroundStyle(RenaissanceColors.sepiaInk)
            }
            .padding(.horizontal, 12)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(masteries) { mastery in
                        ScienceMasteryCard(mastery: mastery)
                    }
                }
                .padding(.horizontal, 12)
            }
        }
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(RenaissanceColors.parchment)
        )
    }
}

struct ScienceMasteryCard: View {
    let mastery: ScienceMastery

    private var needsBlending: Bool {
        mastery.science == .chemistry || mastery.science == .engineering
    }

    var body: some View {
        VStack(spacing: 6) {
            // Science icon with border box
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(RenaissanceColors.parchment.opacity(0.9))
                    .frame(width: 72, height: 72)
                    .blur(radius: 4)

                if let imageName = mastery.science.customImageName {
                    if needsBlending {
                        Image(imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 65, height: 65)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .opacity(0.85)
                    } else {
                        Image(imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 65, height: 65)
                    }
                } else {
                    Image(systemName: mastery.science.sfSymbolName)
                        .font(.custom("EBGaramond-Regular", size: 32, relativeTo: .title3))
                        .foregroundStyle(RenaissanceColors.color(for: mastery.science))
                }

                RoundedRectangle(cornerRadius: 12)
                    .stroke(RenaissanceColors.ochre.opacity(0.5), lineWidth: 1.5)
                    .frame(width: 72, height: 72)
            }
            .frame(width: 76, height: 76)

            // Science name
            Text(mastery.science.rawValue)
                .font(.custom("EBGaramond-Regular", size: 11))
                .foregroundStyle(RenaissanceColors.sepiaInk)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            // Progress ring
            ZStack {
                Circle()
                    .stroke(RenaissanceColors.stoneGray.opacity(0.3), lineWidth: 2.5)

                Circle()
                    .trim(from: 0, to: mastery.progressPercentage)
                    .stroke(
                        RenaissanceColors.color(for: mastery.science),
                        style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))

                Text("\(mastery.level)")
                    .font(.custom("EBGaramond-Regular", size: 10))
                    .fontWeight(.bold)
                    .foregroundStyle(RenaissanceColors.sepiaInk)
            }
            .frame(width: 26, height: 26)
        }
        .frame(width: 80)
    }
}

// MARK: - Row 4 Left: Statistics Card
struct StatisticsCard: View {
    let buildingPlots: [BuildingPlot]
    let totalPlayTime: TimeInterval

    private var completedPlots: [BuildingPlot] {
        buildingPlots.filter(\.isCompleted)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundStyle(RenaissanceColors.terracotta)
                Text("Statistics")
                    .font(.custom("Cinzel-Bold", size: 15))
                    .foregroundStyle(RenaissanceColors.sepiaInk)
            }

            // Buildings completed — individual icons
            VStack(alignment: .leading, spacing: 6) {
                Text("Buildings (\(completedPlots.count)/\(buildingPlots.count))")
                    .font(.custom("EBGaramond-Regular", size: 12))
                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.6))

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 36))], spacing: 6) {
                    ForEach(buildingPlots) { plot in
                        VStack(spacing: 2) {
                            Image(systemName: plot.building.iconName)
                                .font(.custom("EBGaramond-Regular", size: 16, relativeTo: .subheadline))
                                .foregroundStyle(
                                    plot.isCompleted
                                        ? RenaissanceColors.sageGreen
                                        : RenaissanceColors.sepiaInk.opacity(0.4)
                                )
                            // Tiny dot indicator
                            Circle()
                                .fill(plot.isCompleted ? RenaissanceColors.sageGreen : RenaissanceColors.stoneGray.opacity(0.3))
                                .frame(width: 5, height: 5)
                        }
                    }
                }
            }

            Divider()
                .overlay(RenaissanceColors.ochre.opacity(0.3))

            // Play Time
            HStack(spacing: 8) {
                Image(systemName: "clock.fill")
                    .font(.custom("EBGaramond-Regular", size: 14, relativeTo: .footnote))
                    .foregroundStyle(RenaissanceColors.ochre)
                Text("Play Time")
                    .font(.custom("EBGaramond-Regular", size: 12))
                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.6))
                Spacer()
                Text(formatPlayTime(totalPlayTime))
                    .font(.custom("EBGaramond-Regular", size: 14))
                    .foregroundStyle(RenaissanceColors.sepiaInk)
            }

            // Exploration
            HStack(spacing: 8) {
                Image(systemName: "map.fill")
                    .font(.custom("EBGaramond-Regular", size: 14, relativeTo: .footnote))
                    .foregroundStyle(RenaissanceColors.renaissanceBlue)
                Text("Exploration")
                    .font(.custom("EBGaramond-Regular", size: 12))
                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.6))
                Spacer()
                let visited = buildingPlots.filter { $0.challengeProgress > 0 || $0.isCompleted }.count
                Text("\(visited) visited")
                    .font(.custom("EBGaramond-Regular", size: 14))
                    .foregroundStyle(RenaissanceColors.sepiaInk)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(RenaissanceColors.parchment)
        )
    }

    private func formatPlayTime(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }
}

// MARK: - Row 4 Right: Mastery Level Card
struct MasteryLevelCard: View {
    let masteryLevel: MasteryLevel
    let progress: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(masteryLevel.icon)
                    .font(.custom("EBGaramond-Regular", size: 24, relativeTo: .title3))
                Text("Mastery Level")
                    .font(.custom("Cinzel-Bold", size: 15))
                    .foregroundStyle(RenaissanceColors.sepiaInk)
            }

            Text(masteryLevel.rawValue)
                .font(.custom("EBGaramond-SemiBold", size: 20))
                .foregroundStyle(RenaissanceColors.sepiaInk)

            Text(masteryLevel.description)
                .font(.custom("EBGaramond-Regular", size: 12))
                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))

            // Progress bar
            VStack(alignment: .leading, spacing: 4) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(RenaissanceColors.stoneGray.opacity(0.3))
                            .frame(height: 8)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [RenaissanceColors.ochre.opacity(0.8), RenaissanceColors.ochre],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * progress, height: 8)
                    }
                }
                .frame(height: 8)

                Text("\(Int(progress * 100))% Progress")
                    .font(.custom("EBGaramond-Regular", size: 11))
                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.6))
            }

        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(RenaissanceColors.parchment)
        )
    }

}

// MARK: - Navigation Row (horizontal, below content)
struct ProfileNavRow: View {
    let onNavigate: (SidebarDestination) -> Void
    var onBackToMenu: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 8) {
            Divider()
                .overlay(RenaissanceColors.ochre.opacity(0.3))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    profileNavButton(icon: "map.fill", label: "Map") {
                        onNavigate(.cityMap)
                    }
                    profileNavButton(icon: "hammer.fill", label: "Workshop") {
                        onNavigate(.workshop)
                    }
                    profileNavButton(icon: "book.fill", label: "Tests") {
                        onNavigate(.knowledgeTests)
                    }
                    profileNavButton(icon: "book.closed.fill", label: "Notes") {
                        onNavigate(.notebook(4))
                    }
                    profileNavButton(icon: "leaf.fill", label: "Forest") {
                        onNavigate(.forest)
                    }
                    if let onBackToMenu = onBackToMenu {
                        profileNavButton(icon: "house.fill", label: "Home", action: onBackToMenu)
                    }
                }
            }
        }
    }

    private func profileNavButton(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.5))
                Text(label)
                    .font(.custom("EBGaramond-Regular", size: 11))
                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.5))
            }
            .frame(width: 70, height: 52)
            .glassButton(shape: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        ProfileView(
            viewModel: CityViewModel(),
            workshopState: WorkshopState(),
            onboardingState: OnboardingState()
        )
    }
}
