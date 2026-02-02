import SwiftUI

/// Student Profile View - Leonardo's Notebook aesthetic
/// Displays achievements, science mastery, resources, and progress
struct ProfileView: View {
    @State private var profile = StudentProfile.newStudent(name: "Young Architect")
    @State private var selectedCategory: Achievement.AchievementCategory?
    @State private var showingEditName = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header with avatar and name
                ProfileHeaderView(profile: $profile, showingEditName: $showingEditName)

                // Resources bar
                ResourcesBarView(resources: profile.resources)

                // Mastery Level Card
                MasteryLevelCard(masteryLevel: profile.masteryLevel, progress: profile.overallProgress)

                // Science Mastery Grid
                ScienceMasteryGrid(masteries: profile.scienceMasteries)

                // Achievements Section
                AchievementsSection(
                    achievements: profile.achievements,
                    selectedCategory: $selectedCategory
                )

                // Statistics
                StatisticsCard(profile: profile)
            }
            .padding()
        }
        .background(RenaissanceColors.parchmentGradient)
        .navigationTitle("Codex Personalis")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
    }
}

// MARK: - Profile Header
struct ProfileHeaderView: View {
    @Binding var profile: StudentProfile
    @Binding var showingEditName: Bool

    var body: some View {
        VStack(spacing: 12) {
            // Avatar with decorative frame
            ZStack {
                // Decorative circle frame
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [RenaissanceColors.ochre, RenaissanceColors.warmBrown],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 4
                    )
                    .frame(width: 110, height: 110)

                Circle()
                    .fill(RenaissanceColors.parchment)
                    .frame(width: 100, height: 100)

                Image(systemName: profile.avatarName)
                    .font(.system(size: 50))
                    .foregroundStyle(RenaissanceColors.sepiaInk)
            }

            // Name with edit button
            HStack {
                Text(profile.name)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(RenaissanceColors.sepiaInk)

                Button {
                    showingEditName = true
                } label: {
                    Image(systemName: "pencil.circle")
                        .foregroundStyle(RenaissanceColors.warmBrown)
                }
            }

            // Joined date
            Text("Joined \(profile.dateJoined.formatted(date: .abbreviated, time: .omitted))")
                .font(.caption)
                .foregroundStyle(RenaissanceColors.stoneGray)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(RenaissanceColors.parchment.opacity(0.8))
                .shadow(color: RenaissanceColors.sepiaInk.opacity(0.1), radius: 8, y: 4)
        )
    }
}

// MARK: - Resources Bar
struct ResourcesBarView: View {
    let resources: Resources

    var body: some View {
        HStack(spacing: 16) {
            ResourceItem(icon: "dollarsign.circle.fill", value: resources.goldFlorins, label: "Florins", color: RenaissanceColors.goldSuccess)
            ResourceItem(icon: "square.stack.3d.up.fill", value: resources.stoneBlocks, label: "Stone", color: RenaissanceColors.stoneGray)
            ResourceItem(icon: "rectangle.stack.fill", value: resources.woodPlanks, label: "Wood", color: RenaissanceColors.warmBrown)
            ResourceItem(icon: "drop.fill", value: resources.pigmentJars, label: "Pigment", color: RenaissanceColors.renaissanceBlue)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(RenaissanceColors.parchment)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(RenaissanceColors.ochre.opacity(0.5), lineWidth: 1)
                )
        )
    }
}

struct ResourceItem: View {
    let icon: String
    let value: Int
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            Text("\(value)")
                .font(.headline)
                .foregroundStyle(RenaissanceColors.sepiaInk)

            Text(label)
                .font(.caption2)
                .foregroundStyle(RenaissanceColors.stoneGray)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Mastery Level Card
struct MasteryLevelCard: View {
    let masteryLevel: MasteryLevel
    let progress: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Mastery Level")
                    .font(.headline)
                    .foregroundStyle(RenaissanceColors.sepiaInk)

                Spacer()

                Text(masteryLevel.icon)
                    .font(.title2)

                Text(masteryLevel.rawValue)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(masteryColor)
            }

            Text(masteryLevel.description)
                .font(.caption)
                .foregroundStyle(RenaissanceColors.stoneGray)

            // Progress bar
            VStack(alignment: .leading, spacing: 4) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        RoundedRectangle(cornerRadius: 4)
                            .fill(RenaissanceColors.stoneGray.opacity(0.3))
                            .frame(height: 8)

                        // Progress fill
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [masteryColor.opacity(0.8), masteryColor],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * progress, height: 8)
                    }
                }
                .frame(height: 8)

                Text("\(Int(progress * 100))% Overall Progress")
                    .font(.caption2)
                    .foregroundStyle(RenaissanceColors.stoneGray)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(RenaissanceColors.parchment)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(masteryColor.opacity(0.3), lineWidth: 2)
                )
        )
    }

    private var masteryColor: Color {
        switch masteryLevel {
        case .apprentice: return RenaissanceColors.renaissanceBlue
        case .architect: return RenaissanceColors.ochre
        case .master: return RenaissanceColors.goldSuccess
        }
    }
}

// MARK: - Science Mastery Grid
struct ScienceMasteryGrid: View {
    let masteries: [ScienceMastery]

    private let columns = [
        GridItem(.adaptive(minimum: 100, maximum: 150), spacing: 12)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "books.vertical.fill")
                    .foregroundStyle(RenaissanceColors.warmBrown)

                Text("Sciences")
                    .font(.headline)
                    .foregroundStyle(RenaissanceColors.sepiaInk)
            }

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(masteries) { mastery in
                    ScienceMasteryCard(mastery: mastery)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(RenaissanceColors.parchment.opacity(0.6))
        )
    }
}

struct ScienceMasteryCard: View {
    let mastery: ScienceMastery

    var body: some View {
        VStack(spacing: 8) {
            // Science icon
            ZStack {
                Circle()
                    .fill(RenaissanceColors.color(for: mastery.science).opacity(0.2))
                    .frame(width: 44, height: 44)

                Image(systemName: mastery.science.iconName)
                    .font(.title3)
                    .foregroundStyle(RenaissanceColors.color(for: mastery.science))
            }

            // Science name
            Text(mastery.science.rawValue)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(RenaissanceColors.sepiaInk)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            // Progress ring
            ZStack {
                Circle()
                    .stroke(RenaissanceColors.stoneGray.opacity(0.3), lineWidth: 3)

                Circle()
                    .trim(from: 0, to: mastery.progressPercentage)
                    .stroke(
                        RenaissanceColors.color(for: mastery.science),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))

                Text("\(mastery.level)")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(RenaissanceColors.sepiaInk)
            }
            .frame(width: 32, height: 32)
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.5))
        )
    }
}

// MARK: - Achievements Section
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
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "seal.fill")
                    .foregroundStyle(RenaissanceColors.goldSuccess)

                Text("Achievements")
                    .font(.headline)
                    .foregroundStyle(RenaissanceColors.sepiaInk)

                Spacer()

                Text("\(achievements.filter { $0.isUnlocked }.count)/\(achievements.count)")
                    .font(.subheadline)
                    .foregroundStyle(RenaissanceColors.stoneGray)
            }

            // Category filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
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

            // Achievement grid
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 12) {
                ForEach(filteredAchievements) { achievement in
                    AchievementBadge(achievement: achievement)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(RenaissanceColors.parchment.opacity(0.6))
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
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
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
        VStack(spacing: 6) {
            // Wax seal style badge
            ZStack {
                // Outer seal
                Circle()
                    .fill(
                        achievement.isUnlocked
                            ? RenaissanceColors.goldSuccess
                            : RenaissanceColors.stoneGray.opacity(0.5)
                    )
                    .frame(width: 56, height: 56)
                    .shadow(
                        color: achievement.isUnlocked
                            ? RenaissanceColors.goldSuccess.opacity(0.4)
                            : .clear,
                        radius: 4
                    )

                // Inner icon
                Image(systemName: achievement.iconName)
                    .font(.title3)
                    .foregroundStyle(
                        achievement.isUnlocked
                            ? .white
                            : RenaissanceColors.stoneGray
                    )
            }

            Text(achievement.name)
                .font(.caption2)
                .foregroundStyle(
                    achievement.isUnlocked
                        ? RenaissanceColors.sepiaInk
                        : RenaissanceColors.stoneGray
                )
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .frame(width: 80)
        .opacity(achievement.isUnlocked ? 1.0 : 0.6)
    }
}

// MARK: - Statistics Card
struct StatisticsCard: View {
    let profile: StudentProfile

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundStyle(RenaissanceColors.renaissanceBlue)

                Text("Statistics")
                    .font(.headline)
                    .foregroundStyle(RenaissanceColors.sepiaInk)
            }

            HStack(spacing: 20) {
                StatItem(
                    icon: "building.columns.fill",
                    value: "\(profile.buildingsCompleted)",
                    label: "Buildings"
                )

                StatItem(
                    icon: "clock.fill",
                    value: formatPlayTime(profile.totalPlayTime),
                    label: "Play Time"
                )

                StatItem(
                    icon: "star.fill",
                    value: "\(profile.totalAchievements)",
                    label: "Achievements"
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(RenaissanceColors.parchment.opacity(0.6))
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

struct StatItem: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(RenaissanceColors.warmBrown)

            Text(value)
                .font(.headline)
                .foregroundStyle(RenaissanceColors.sepiaInk)

            Text(label)
                .font(.caption2)
                .foregroundStyle(RenaissanceColors.stoneGray)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    NavigationStack {
        ProfileView()
    }
}
