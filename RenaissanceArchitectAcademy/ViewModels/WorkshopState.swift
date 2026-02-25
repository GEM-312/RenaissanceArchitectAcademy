import SwiftUI

/// State management for the Workshop crafting mini-game
@MainActor
@Observable
class WorkshopState {
    // Player inventory — starts at zero, must collect from stations
    var rawMaterials: [Material: Int] = [:]

    var persistenceManager: PersistenceManager?

    var workbenchSlots: [Material?] = [nil, nil, nil, nil]
    var furnaceTemperature: Recipe.Temperature = .medium
    var furnaceInput: [Material: Int]? = nil
    var isProcessing: Bool = false
    var processProgress: Double = 0.0
    var currentRecipe: Recipe? = nil
    var craftedMaterials: [CraftedItem: Int] = [:]
    var showEducationalPopup: Bool = false
    var educationalText: String = ""
    var statusMessage: String? = nil

    /// Master assignment — current crafting task from the workshop master
    var currentAssignment: MasterAssignment?
    /// Whether the "Earn Florins" overlay is visible
    var showEarnFlorinsOverlay: Bool = false

    /// Stations whose bird lesson has been shown this session (resets each launch)
    var stationsLessonSeen: Set<ResourceStationType> = []

    // MARK: - Bottega Job System

    /// Current active job from the workshop master
    var currentJob: WorkshopJob?
    /// Whether the job board overlay is visible
    var showJobBoard: Bool = false
    /// Whether the job complete celebration overlay is visible
    var showJobComplete: Bool = false
    /// Snapshot of materials at job start — used to track collection progress
    var jobStartInventory: [Material: Int] = [:]
    /// Number of consecutive jobs completed (for streak bonus)
    var jobStreak: Int = 0
    /// Current job tier the player is working at
    var currentJobTier: WorkshopJob.JobTier = .apprentice
    /// Total jobs completed (used for tier progression)
    var totalJobsCompleted: Int = 0

    // MARK: - Station Stocks

    /// Stock per station — each station has finite materials that regenerate
    var stationStocks: [ResourceStationType: [Material: Int]] = {
        var stocks: [ResourceStationType: [Material: Int]] = [:]
        stocks[.quarry]       = [.limestone: 8, .marbleDust: 4, .marble: 6]
        stocks[.river]        = [.water: 12, .sand: 10]
        stocks[.volcano]      = [.volcanicAsh: 6]
        stocks[.clayPit]      = [.clay: 10]
        stocks[.mine]         = [.ironOre: 6, .lead: 5]
        stocks[.pigmentTable] = [.redOchre: 5, .lapisBlue: 3, .verdigrisGreen: 4]
        stocks[.forest]       = [.timber: 12]
        stocks[.market]       = [.silk: 4, .lead: 3, .marble: 3]
        return stocks
    }()

    /// Respawn interval (seconds) for depleted stations
    let stationRespawnTime: TimeInterval = 15.0
    private var respawnTimer: Timer?

    // MARK: - Station Management

    /// Collect one unit of a material from a station
    @discardableResult
    func collectFromStation(_ station: ResourceStationType, material: Material) -> Bool {
        guard var stock = stationStocks[station],
              let count = stock[material], count > 0 else {
            statusMessage = "No \(material.rawValue) left here!"
            return false
        }
        stock[material] = count - 1
        stationStocks[station] = stock
        rawMaterials[material, default: 0] += 1
        statusMessage = "Collected \(material.rawValue)!"
        persistInventory()
        return true
    }

    /// Total stock for all materials at a station
    func totalStockFor(station: ResourceStationType) -> Int {
        guard let stock = stationStocks[station] else { return 0 }
        return stock.values.reduce(0, +)
    }

    /// Educational hint text shown by the bird at each station
    /// Explains what the materials are, what they craft into, and which buildings need them
    func hintFor(station: ResourceStationType) -> String {
        switch station {
        case .quarry:
            return "Collect limestone, marble dust, and marble here. You'll craft them into lime mortar, Roman concrete, glass, and marble slabs — needed for the Aqueduct, Pantheon, Colosseum, and nearly every structure!"
        case .river:
            return "Collect sand and water — the two most versatile materials! You'll need them for mortar, concrete, glass, terracotta, and pigments. Almost every recipe at the workbench requires water or sand."
        case .volcano:
            return "Collect volcanic ash — the secret ingredient for Roman concrete! Mix it with limestone, water, and sand at the workbench. Buildings like the Pantheon, Aqueduct, and Harbor all need concrete."
        case .clayPit:
            return "Collect clay to craft terracotta tiles and bronze fittings. The Duomo's herringbone dome, the Insula's roof, and the Glassworks all need terracotta. Clay molds are also used for casting bronze!"
        case .mine:
            return "Collect iron ore and lead. Iron crafts into bronze fittings, timber beams, and carved wood. Lead makes waterproof sheeting and stained glass. The Colosseum, Aqueduct, and Printing Press all need these metals."
        case .pigmentTable:
            return "Collect red ochre, lapis lazuli, and verdigris. Grind them into fresco pigments at the workbench — the Duomo needs red fresco, the Vatican Observatory needs blue. These colors are worth more than gold!"
        case .forest:
            return "Collect timber for beams and carved wood. Timber beams support roofs in the Roman Baths, Harbor, Arsenal, and Workshop. Carved walnut builds the Anatomy Theater and Printing Press."
        case .market:
            return "Collect silk, lead, and marble from merchants. Silk crafts into fabric for the Colosseum's velarium and Leonardo's Flying Machine. Lead and marble are used across many buildings."
        case .workbench:
            return "Combine raw materials here to create building supplies."
        case .furnace:
            return "Set the right temperature and fire your mixture!"
        case .craftingRoom:
            return "Enter the Crafting Room to mix materials at the workbench, grind pigments, and fire recipes in the furnace. This is where raw materials become building supplies!"
        }
    }

    // MARK: - Respawn Timer

    func startRespawnTimer() {
        respawnTimer = Timer.scheduledTimer(withTimeInterval: stationRespawnTime, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.respawnStations()
            }
        }
    }

    func stopRespawnTimer() {
        respawnTimer?.invalidate()
        respawnTimer = nil
    }

    private func respawnStations() {
        // Replenish depleted stations with 1 unit of each material
        let defaults: [ResourceStationType: [Material: Int]] = [
            .quarry:       [.limestone: 8, .marbleDust: 4, .marble: 6],
            .river:        [.water: 12, .sand: 10],
            .volcano:      [.volcanicAsh: 6],
            .clayPit:      [.clay: 10],
            .mine:         [.ironOre: 6, .lead: 5],
            .pigmentTable: [.redOchre: 5, .lapisBlue: 3, .verdigrisGreen: 4],
            .forest:       [.timber: 12],
            .market:       [.silk: 4, .lead: 3, .marble: 3],
        ]

        for (station, maxStock) in defaults {
            guard var currentStock = stationStocks[station] else { continue }
            var anyDepleted = false
            for (material, maxCount) in maxStock {
                let current = currentStock[material] ?? 0
                if current < maxCount {
                    currentStock[material] = min(current + 1, maxCount)
                    anyDepleted = true
                }
            }
            if anyDepleted {
                stationStocks[station] = currentStock
            }
        }
    }

    // MARK: - Existing Crafting Logic (unchanged)

    /// Tally of materials currently on the workbench
    var workbenchIngredients: [Material: Int] {
        var result: [Material: Int] = [:]
        for material in workbenchSlots.compactMap({ $0 }) {
            result[material, default: 0] += 1
        }
        return result
    }

    /// Recipe that matches the current workbench contents, if any
    var detectedRecipe: Recipe? {
        Recipe.detectRecipe(from: workbenchIngredients)
    }

    /// Add a material to the first empty workbench slot
    func addToWorkbench(_ material: Material) -> Bool {
        guard let emptyIndex = workbenchSlots.firstIndex(where: { $0 == nil }) else {
            statusMessage = "Workbench full!"
            return false
        }
        guard (rawMaterials[material] ?? 0) > 0 else {
            statusMessage = "No \(material.rawValue) left!"
            return false
        }
        rawMaterials[material]! -= 1
        workbenchSlots[emptyIndex] = material
        statusMessage = nil
        return true
    }

    /// Return all workbench materials back to storage
    func clearWorkbench() {
        for material in workbenchSlots.compactMap({ $0 }) {
            rawMaterials[material, default: 0] += 1
        }
        workbenchSlots = [nil, nil, nil, nil]
        statusMessage = nil
    }

    /// Move workbench ingredients into the furnace
    func mixIngredients() -> Bool {
        guard detectedRecipe != nil else {
            statusMessage = "Invalid recipe!"
            return false
        }
        furnaceInput = workbenchIngredients
        currentRecipe = detectedRecipe
        workbenchSlots = [nil, nil, nil, nil]
        statusMessage = nil
        return true
    }

    /// Begin furnace processing (caller animates progress)
    func startProcessing() {
        guard let recipe = currentRecipe else { return }
        guard recipe.temperature == furnaceTemperature else {
            statusMessage = "Wrong temperature! \(recipe.output.rawValue) needs \(recipe.temperature.rawValue) heat."
            return
        }
        isProcessing = true
        processProgress = 0.0
        statusMessage = "Processing..."
    }

    /// Finish processing and award the crafted item
    func completeProcessing() {
        guard let recipe = currentRecipe else { return }
        craftedMaterials[recipe.output, default: 0] += 1
        educationalText = recipe.educationalText
        showEducationalPopup = true
        furnaceInput = nil
        currentRecipe = nil
        isProcessing = false
        processProgress = 0.0
        statusMessage = "Created \(recipe.output.rawValue)!"
        persistInventory()
    }

    // MARK: - Persistence

    func loadFromPersistence() {
        guard let manager = persistenceManager else { return }
        let save = manager.loadPlayerSave()
        rawMaterials = save.rawMaterials
        craftedMaterials = save.craftedMaterials
    }

    func addRawMaterials(_ materials: [Material: Int]) {
        for (mat, count) in materials {
            rawMaterials[mat, default: 0] += count
        }
        persistInventory()
    }

    func persistInventory() {
        guard let manager = persistenceManager else { return }
        let save = manager.loadPlayerSave()
        save.rawMaterials = rawMaterials
        save.craftedMaterials = craftedMaterials
        save.lastSaved = Date()
        manager.save()
    }

    // MARK: - Master Assignments

    /// Generate a new random assignment from the workshop master
    func generateNewAssignment() {
        currentAssignment = MasterAssignment.randomAssignment()
    }

    /// Check if the just-crafted item matches the current assignment
    func checkAssignmentCompletion(craftedItem: CraftedItem) -> Bool {
        guard let assignment = currentAssignment else { return false }
        return assignment.targetItem == craftedItem
    }

    // MARK: - Bottega Job System

    /// Generate a new job for the current tier
    func generateNewJob() {
        currentJob = WorkshopJob.randomJob(tier: currentJobTier)
        jobStartInventory = rawMaterials
    }

    /// Generate 3 job choices for the job board
    func jobChoices() -> [WorkshopJob] {
        var choices: [WorkshopJob] = []
        // Always offer current tier
        choices.append(WorkshopJob.randomJob(tier: currentJobTier))
        // Offer one tier below if available
        if currentJobTier != .apprentice {
            let lowerTier: WorkshopJob.JobTier = currentJobTier == .master ? .journeyman : .apprentice
            choices.append(WorkshopJob.randomJob(tier: lowerTier))
        }
        // Offer one tier above if earned enough, or another at current tier
        if totalJobsCompleted >= 5 && currentJobTier == .apprentice {
            choices.append(WorkshopJob.randomJob(tier: .journeyman))
        } else if totalJobsCompleted >= 15 && currentJobTier == .journeyman {
            choices.append(WorkshopJob.randomJob(tier: .master))
        } else {
            choices.append(WorkshopJob.randomJob(tier: currentJobTier))
        }
        return choices
    }

    /// Accept a specific job from the job board
    func acceptJob(_ job: WorkshopJob) {
        currentJob = job
        jobStartInventory = rawMaterials
        showJobBoard = false
    }

    /// Check job collection progress — how many of each material collected since job started
    func jobCollectionProgress() -> [Material: (collected: Int, needed: Int)] {
        guard let job = currentJob else { return [:] }
        var progress: [Material: (Int, Int)] = [:]
        for (material, needed) in job.requirements {
            let hadBefore = jobStartInventory[material] ?? 0
            let haveNow = rawMaterials[material] ?? 0
            let collected = max(0, haveNow - hadBefore)
            progress[material] = (min(collected, needed), needed)
        }
        return progress
    }

    /// Check if the current job's collection requirements are met
    func isJobCollectionDone() -> Bool {
        guard let job = currentJob else { return false }
        let progress = jobCollectionProgress()
        return job.requirements.allSatisfy { (material, needed) in
            (progress[material]?.collected ?? 0) >= needed
        }
    }

    /// Check if the full job is complete (collection + optional crafting)
    func checkJobCompletion(craftedItem: CraftedItem? = nil) -> Bool {
        guard let job = currentJob else { return false }

        // Collection must be done
        guard isJobCollectionDone() else { return false }

        // If job requires crafting, check that too
        if let target = job.craftTarget {
            if let crafted = craftedItem, crafted == target {
                return true
            }
            return false
        }

        // Collection-only job — done!
        return true
    }

    /// Complete the current job and award rewards
    func completeJob() -> (florins: Int, streakBonus: Int) {
        guard let job = currentJob else { return (0, 0) }

        let baseFlorins = job.rewardFlorins
        jobStreak += 1
        let streakBonus = (jobStreak - 1) * GameRewards.jobStreakBonus
        totalJobsCompleted += 1

        // Auto-promote tier after milestones
        if totalJobsCompleted >= 15 && currentJobTier == .journeyman {
            currentJobTier = .master
        } else if totalJobsCompleted >= 5 && currentJobTier == .apprentice {
            currentJobTier = .journeyman
        }

        currentJob = nil
        showJobComplete = true
        return (baseFlorins, streakBonus)
    }

    /// Abandon the current job (resets streak)
    func abandonJob() {
        currentJob = nil
        jobStreak = 0
    }
}
