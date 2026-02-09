import SwiftUI

/// State management for the Workshop crafting mini-game
@Observable
class WorkshopState {
    // Player inventory — starts at zero, must collect from stations
    var rawMaterials: [Material: Int] = [:]

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
        return true
    }

    /// Total stock for all materials at a station
    func totalStockFor(station: ResourceStationType) -> Int {
        guard let stock = stationStocks[station] else { return 0 }
        return stock.values.reduce(0, +)
    }

    /// Educational hint text shown by Splash at each station
    func hintFor(station: ResourceStationType) -> String {
        switch station {
        case .quarry:
            return "Limestone is calcium carbonate — the Romans quarried it for mortar and concrete. Marble dust adds strength!"
        case .river:
            return "Sand and water are essential binding agents. Da Vinci studied water flow in his famous notebooks."
        case .volcano:
            return "Volcanic ash (pozzolana) from Mount Vesuvius made Roman concrete so strong it still stands today!"
        case .clayPit:
            return "Clay fires into terracotta at over 1000\u{00B0}C. 'Terra cotta' means 'baked earth' in Italian."
        case .mine:
            return "Iron ore was smelted for tools and nails. Lead was cast into sheets for waterproof roofing and water pipes!"
        case .pigmentTable:
            return "Renaissance painters ground minerals into pigments. Lapis lazuli blue was rarer than gold!"
        case .forest:
            return "Oak and chestnut timber framed roofs across Italy. Walnut was prized for fine furniture and carved panels."
        case .market:
            return "Merchants traded silk from the East, lead ingots from mines, and marble blocks quarried across the Mediterranean."
        case .workbench:
            return "Combine raw materials here to create building supplies."
        case .furnace:
            return "Set the right temperature and fire your mixture!"
        }
    }

    // MARK: - Respawn Timer

    func startRespawnTimer() {
        respawnTimer = Timer.scheduledTimer(withTimeInterval: stationRespawnTime, repeats: true) { [weak self] _ in
            self?.respawnStations()
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
    }
}
