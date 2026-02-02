import SwiftUI

@MainActor
class CityViewModel: ObservableObject {
    @Published var buildingPlots: [BuildingPlot]
    @Published var selectedPlot: BuildingPlot?

    init() {
        // Initialize with the 6 building plots (3 Ancient Rome + 3 Renaissance)
        self.buildingPlots = [
            // Ancient Rome buildings
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
            // Renaissance buildings
            BuildingPlot(
                id: 4,
                building: Building(
                    name: "Duomo",
                    era: .renaissance,
                    sciences: [.geometry, .architecture, .physics],
                    iconName: "building.2"
                ),
                isCompleted: false
            ),
            BuildingPlot(
                id: 5,
                building: Building(
                    name: "Observatory",
                    era: .renaissance,
                    sciences: [.astronomy, .optics, .mathematics],
                    iconName: "sparkles"
                ),
                isCompleted: false
            ),
            BuildingPlot(
                id: 6,
                building: Building(
                    name: "Workshop",
                    era: .renaissance,
                    sciences: [.engineering, .physics, .materials],
                    iconName: "hammer"
                ),
                isCompleted: false
            )
        ]
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
}
