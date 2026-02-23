import SwiftUI

@MainActor
class CityViewModel: ObservableObject {
    @Published var buildingPlots: [BuildingPlot]
    @Published var selectedPlot: BuildingPlot?
    @Published var goldFlorins: Int = 0
    @Published var earnedScienceBadges: Set<Science> = []
    @Published var buildingProgressMap: [Int: BuildingProgress] = [:]
    @Published var totalPlayTime: TimeInterval = 0

    var persistenceManager: PersistenceManager?

    init() {
        // Initialize with 17 building plots (8 Ancient Rome + 9 Renaissance Italy)
        self.buildingPlots = [
            // ============================================
            // ANCIENT ROME (8 buildings)
            // ============================================
            BuildingPlot(
                id: 1,
                building: Building(
                    name: "Aqueduct",
                    era: .ancientRome,
                    sciences: [.engineering, .hydraulics, .mathematics],
                    iconName: "water.waves",
                    difficultyTier: .apprentice
                ),
                isCompleted: false
            ),
            BuildingPlot(
                id: 2,
                building: Building(
                    name: "Colosseum",
                    era: .ancientRome,
                    sciences: [.architecture, .engineering, .acoustics],
                    iconName: "building.columns",
                    difficultyTier: .architect
                ),
                isCompleted: false
            ),
            BuildingPlot(
                id: 3,
                building: Building(
                    name: "Roman Baths",
                    era: .ancientRome,
                    sciences: [.hydraulics, .chemistry, .materials],
                    iconName: "drop.circle",
                    difficultyTier: .apprentice
                ),
                isCompleted: false
            ),
            BuildingPlot(
                id: 4,
                building: Building(
                    name: "Pantheon",
                    era: .ancientRome,
                    sciences: [.geometry, .architecture, .materials],
                    iconName: "circle.circle",
                    difficultyTier: .architect
                ),
                isCompleted: false
            ),
            BuildingPlot(
                id: 5,
                building: Building(
                    name: "Roman Roads",
                    era: .ancientRome,
                    sciences: [.engineering, .geology, .materials],
                    iconName: "road.lanes",
                    difficultyTier: .apprentice
                ),
                isCompleted: false
            ),
            BuildingPlot(
                id: 6,
                building: Building(
                    name: "Harbor",
                    era: .ancientRome,
                    sciences: [.engineering, .physics, .hydraulics],
                    iconName: "ferry",
                    difficultyTier: .apprentice
                ),
                isCompleted: false
            ),
            BuildingPlot(
                id: 7,
                building: Building(
                    name: "Siege Workshop",
                    era: .ancientRome,
                    sciences: [.physics, .engineering, .mathematics],
                    iconName: "hammer",
                    difficultyTier: .architect
                ),
                isCompleted: false
            ),
            BuildingPlot(
                id: 8,
                building: Building(
                    name: "Insula",
                    era: .ancientRome,
                    sciences: [.architecture, .materials, .mathematics],
                    iconName: "building",
                    difficultyTier: .apprentice
                ),
                isCompleted: false
            ),

            // ============================================
            // RENAISSANCE ITALY (9 buildings across 5 cities)
            // ============================================

            // FLORENCE (2 buildings)
            BuildingPlot(
                id: 9,
                building: Building(
                    name: "Duomo",
                    era: .renaissance,
                    city: .florence,
                    sciences: [.geometry, .architecture, .physics],
                    iconName: "building.2",
                    difficultyTier: .master
                ),
                isCompleted: false
            ),
            BuildingPlot(
                id: 10,
                building: Building(
                    name: "Botanical Garden",
                    era: .renaissance,
                    city: .florence,
                    sciences: [.biology, .chemistry, .geology],
                    iconName: "leaf",
                    difficultyTier: .apprentice
                ),
                isCompleted: false
            ),

            // VENICE (2 buildings)
            BuildingPlot(
                id: 11,
                building: Building(
                    name: "Glassworks",
                    era: .renaissance,
                    city: .venice,
                    sciences: [.chemistry, .optics, .materials],
                    iconName: "eyeglasses",
                    difficultyTier: .architect
                ),
                isCompleted: false
            ),
            BuildingPlot(
                id: 12,
                building: Building(
                    name: "Arsenal",
                    era: .renaissance,
                    city: .venice,
                    sciences: [.engineering, .physics, .materials],
                    iconName: "sailboat",
                    difficultyTier: .architect
                ),
                isCompleted: false
            ),

            // PADUA (1 building)
            BuildingPlot(
                id: 13,
                building: Building(
                    name: "Anatomy Theater",
                    era: .renaissance,
                    city: .padua,
                    sciences: [.biology, .optics, .chemistry],
                    iconName: "figure.stand",
                    difficultyTier: .master
                ),
                isCompleted: false
            ),

            // MILAN (2 buildings)
            BuildingPlot(
                id: 14,
                building: Building(
                    name: "Leonardo's Workshop",
                    era: .renaissance,
                    city: .milan,
                    sciences: [.engineering, .physics, .materials],
                    iconName: "gearshape.2",
                    difficultyTier: .master
                ),
                isCompleted: false
            ),
            BuildingPlot(
                id: 15,
                building: Building(
                    name: "Flying Machine",
                    era: .renaissance,
                    city: .milan,
                    sciences: [.physics, .engineering, .mathematics],
                    iconName: "bird",
                    difficultyTier: .master
                ),
                isCompleted: false
            ),

            // ROME (2 buildings)
            BuildingPlot(
                id: 16,
                building: Building(
                    name: "Vatican Observatory",
                    era: .renaissance,
                    city: .rome,
                    sciences: [.astronomy, .optics, .mathematics],
                    iconName: "sparkles",
                    difficultyTier: .master
                ),
                isCompleted: false
            ),
            BuildingPlot(
                id: 17,
                building: Building(
                    name: "Printing Press",
                    era: .renaissance,
                    city: .rome,
                    sciences: [.engineering, .chemistry, .physics],
                    iconName: "book",
                    difficultyTier: .architect
                ),
                isCompleted: false
            )
        ]
    }

    // MARK: - Persistence

    func loadFromPersistence() {
        guard let manager = persistenceManager else { return }
        let save = manager.loadPlayerSave()
        goldFlorins = save.goldFlorins
        earnedScienceBadges = save.earnedScienceBadges
        totalPlayTime = save.totalPlayTimeSeconds

        let records = manager.loadAllBuildingProgress()
        for (buildingId, record) in records {
            buildingProgressMap[buildingId] = record.toBuildingProgress()
            if let index = buildingPlots.firstIndex(where: { $0.id == buildingId }) {
                buildingPlots[index].isCompleted = record.isCompleted
                buildingPlots[index].challengeProgress = record.challengeProgress
                buildingPlots[index].sketchingProgress.completedPhases = record.completedSketchingPhases
            }
        }
    }

    private func persistPlayerSave() {
        guard let manager = persistenceManager else { return }
        let save = manager.loadPlayerSave()
        save.goldFlorins = goldFlorins
        save.earnedScienceBadges = earnedScienceBadges
        save.lastSaved = Date()
        manager.save()
    }

    private func persistBuildingProgress(for plotId: Int) {
        guard let manager = persistenceManager else { return }
        let record = manager.getOrCreateBuildingProgress(for: plotId)
        if let progress = buildingProgressMap[plotId] {
            record.update(from: progress)
        }
        if let plot = buildingPlots.first(where: { $0.id == plotId }) {
            record.isCompleted = plot.isCompleted
            record.challengeProgress = plot.challengeProgress
            record.completedSketchingPhases = plot.sketchingProgress.completedPhases
        }
        manager.save()
    }

    // MARK: - Difficulty Tier Unlock Logic

    /// Count completed buildings in a given tier
    func completedCount(for tier: MasteryLevel) -> Int {
        buildingPlots.filter { $0.building.difficultyTier == tier && $0.isCompleted }.count
    }

    /// Whether a tier's buildings are unlocked
    func isTierUnlocked(_ tier: MasteryLevel) -> Bool {
        switch tier {
        case .apprentice:
            return true
        case .architect:
            return completedCount(for: .apprentice) >= 3
        case .master:
            return completedCount(for: .architect) >= 3
        }
    }

    /// Message explaining what's needed to unlock a tier
    func tierUnlockMessage(for tier: MasteryLevel) -> String {
        switch tier {
        case .apprentice:
            return ""
        case .architect:
            let done = completedCount(for: .apprentice)
            return "Complete \(3 - done) more Apprentice building\(3 - done == 1 ? "" : "s") to unlock Architect buildings!"
        case .master:
            let done = completedCount(for: .architect)
            return "Complete \(3 - done) more Architect building\(3 - done == 1 ? "" : "s") to unlock Master buildings!"
        }
    }

    var ancientRomeBuildings: [BuildingPlot] {
        buildingPlots.filter { $0.building.era == .ancientRome }
    }

    var renaissanceBuildings: [BuildingPlot] {
        buildingPlots.filter { $0.building.era == .renaissance }
    }

    func buildingsFor(city: RenaissanceCity) -> [BuildingPlot] {
        buildingPlots.filter { $0.building.city == city }
    }

    func selectPlot(_ plot: BuildingPlot) {
        selectedPlot = plot
    }

    func completeChallenge(for plotId: Int) {
        if let index = buildingPlots.firstIndex(where: { $0.id == plotId }) {
            buildingPlots[index].isCompleted = true
            buildingPlots[index].challengeProgress = 1.0
        }
        persistBuildingProgress(for: plotId)
    }

    func completeSketchingPhase(for plotId: Int, phases: Set<SketchingPhaseType>) {
        if let index = buildingPlots.firstIndex(where: { $0.id == plotId }) {
            buildingPlots[index].sketchingProgress.completedPhases.formUnion(phases)
        }
        persistBuildingProgress(for: plotId)
    }

    // MARK: - Play Time

    func addPlayTime(_ seconds: TimeInterval) {
        totalPlayTime += seconds
        guard let manager = persistenceManager else { return }
        let save = manager.loadPlayerSave()
        save.totalPlayTimeSeconds = totalPlayTime
        save.lastSaved = Date()
        manager.save()
    }

    // MARK: - Game Economy & Progress

    func earnFlorins(_ amount: Int) {
        goldFlorins += amount
        persistPlayerSave()
    }

    @discardableResult
    func spendFlorins(_ amount: Int) -> Bool {
        guard goldFlorins >= amount else { return false }
        goldFlorins -= amount
        persistPlayerSave()
        return true
    }

    func earnScienceBadge(for plotId: Int, science: Science) {
        var progress = buildingProgressMap[plotId] ?? BuildingProgress()
        progress.scienceBadgesEarned.insert(science)
        buildingProgressMap[plotId] = progress
        earnedScienceBadges.insert(science)
        persistPlayerSave()
        persistBuildingProgress(for: plotId)
    }

    func markLessonRead(for plotId: Int) {
        var progress = buildingProgressMap[plotId] ?? BuildingProgress()
        guard !progress.lessonRead else { return }
        progress.lessonRead = true
        buildingProgressMap[plotId] = progress
        persistBuildingProgress(for: plotId)
        // Award florins + science badges
        if let plot = buildingPlots.first(where: { $0.id == plotId }) {
            earnFlorins(GameRewards.lessonReadFlorins)
            for science in plot.building.sciences {
                earnScienceBadge(for: plotId, science: science)
            }
        }
    }

    func markQuizPassed(for plotId: Int) {
        var progress = buildingProgressMap[plotId] ?? BuildingProgress()
        guard !progress.quizPassed else { return }
        progress.quizPassed = true
        buildingProgressMap[plotId] = progress
        persistBuildingProgress(for: plotId)
        earnFlorins(GameRewards.quizPassFlorins)
    }

    func markSketchCompleted(for plotId: Int) {
        var progress = buildingProgressMap[plotId] ?? BuildingProgress()
        guard !progress.sketchCompleted else { return }
        progress.sketchCompleted = true
        buildingProgressMap[plotId] = progress
        persistBuildingProgress(for: plotId)
        earnFlorins(GameRewards.sketchCompleteFlorins)
    }

    // MARK: - Lesson Bookmarks (SwiftData)

    func saveLessonBookmark(for plotId: Int, sectionIndex: Int) {
        var progress = buildingProgressMap[plotId] ?? BuildingProgress()
        progress.lessonSectionIndex = sectionIndex
        buildingProgressMap[plotId] = progress
        persistBuildingProgress(for: plotId)
    }

    func loadLessonBookmark(for plotId: Int) -> Int {
        let progress = buildingProgressMap[plotId]
        return progress?.lessonSectionIndex ?? 0
    }

    func canStartBuilding(for plotId: Int, workshopState: WorkshopState) -> Bool {
        guard let plot = buildingPlots.first(where: { $0.id == plotId }) else { return false }
        let progress = buildingProgressMap[plotId] ?? BuildingProgress()

        // All sciences must be earned
        let allSciencesBadged = plot.building.sciences.allSatisfy { progress.scienceBadgesEarned.contains($0) }

        // Sketch must be done if sketching content exists
        let sketchOk = SketchingContent.sketchingChallenge(for: plot.building.name) == nil || progress.sketchCompleted

        // Quiz must be passed if quiz content exists
        let quizOk = ChallengeContent.interactiveChallenge(for: plot.building.name) == nil || progress.quizPassed

        // All required materials
        let materialsOk = plot.building.requiredMaterials.allSatisfy { item, needed in
            (workshopState.craftedMaterials[item] ?? 0) >= needed
        }

        return allSciencesBadged && sketchOk && quizOk && materialsOk
    }
}
