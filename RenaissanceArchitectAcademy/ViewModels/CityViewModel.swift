import SwiftUI

@MainActor
class CityViewModel: ObservableObject {
    @Published var buildingPlots: [BuildingPlot]
    @Published var selectedPlot: BuildingPlot?

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
                    iconName: "water.waves"
                ),
                isCompleted: false
            ),
            BuildingPlot(
                id: 2,
                building: Building(
                    name: "Colosseum",
                    era: .ancientRome,
                    sciences: [.architecture, .engineering, .acoustics],
                    iconName: "building.columns"
                ),
                isCompleted: false
            ),
            BuildingPlot(
                id: 3,
                building: Building(
                    name: "Roman Baths",
                    era: .ancientRome,
                    sciences: [.hydraulics, .chemistry, .materials],
                    iconName: "drop.circle"
                ),
                isCompleted: false
            ),
            BuildingPlot(
                id: 4,
                building: Building(
                    name: "Pantheon",
                    era: .ancientRome,
                    sciences: [.geometry, .architecture, .materials],
                    iconName: "circle.circle"
                ),
                isCompleted: false
            ),
            BuildingPlot(
                id: 5,
                building: Building(
                    name: "Roman Roads",
                    era: .ancientRome,
                    sciences: [.engineering, .geology, .materials],
                    iconName: "road.lanes"
                ),
                isCompleted: false
            ),
            BuildingPlot(
                id: 6,
                building: Building(
                    name: "Harbor",
                    era: .ancientRome,
                    sciences: [.engineering, .physics, .hydraulics],
                    iconName: "ferry"
                ),
                isCompleted: false
            ),
            BuildingPlot(
                id: 7,
                building: Building(
                    name: "Siege Workshop",
                    era: .ancientRome,
                    sciences: [.physics, .engineering, .mathematics],
                    iconName: "hammer"
                ),
                isCompleted: false
            ),
            BuildingPlot(
                id: 8,
                building: Building(
                    name: "Insula",
                    era: .ancientRome,
                    sciences: [.architecture, .materials, .mathematics],
                    iconName: "building"
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
                    iconName: "building.2"
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
                    iconName: "leaf"
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
                    iconName: "eyeglasses"
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
                    iconName: "sailboat"
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
                    iconName: "figure.stand"
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
                    iconName: "gearshape.2"
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
                    iconName: "bird"
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
                    iconName: "sparkles"
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
                    iconName: "book"
                ),
                isCompleted: false
            )
        ]
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
    }

    func completeSketchingPhase(for plotId: Int, phases: Set<SketchingPhaseType>) {
        if let index = buildingPlots.firstIndex(where: { $0.id == plotId }) {
            buildingPlots[index].sketchingProgress.completedPhases.formUnion(phases)
        }
    }
}
