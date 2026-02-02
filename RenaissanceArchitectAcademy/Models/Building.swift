import Foundation

/// Historical era for buildings
enum Era: String, CaseIterable {
    case ancientRome = "Ancient Rome"
    case renaissance = "Renaissance"
}

/// Sciences that can be associated with building challenges
enum Science: String, CaseIterable {
    case mathematics = "Mathematics"
    case physics = "Physics"
    case chemistry = "Chemistry"
    case geometry = "Geometry"
    case engineering = "Engineering"
    case astronomy = "Astronomy"
    case biology = "Biology"
    case geology = "Geology"
    case optics = "Optics"
    case hydraulics = "Hydraulics"
    case acoustics = "Acoustics"
    case materials = "Materials Science"
    case architecture = "Architecture"

    var iconName: String {
        switch self {
        case .mathematics: return "function"
        case .physics: return "atom"
        case .chemistry: return "flask"
        case .geometry: return "triangle"
        case .engineering: return "gearshape.2"
        case .astronomy: return "star"
        case .biology: return "leaf"
        case .geology: return "mountain.2"
        case .optics: return "eye"
        case .hydraulics: return "drop"
        case .acoustics: return "waveform"
        case .materials: return "cube"
        case .architecture: return "building.columns"
        }
    }
}

/// A building that can be constructed
struct Building: Identifiable {
    let id = UUID()
    let name: String
    let era: Era
    let sciences: [Science]
    let iconName: String

    var description: String {
        "A \(era.rawValue) era building involving \(sciences.map(\.rawValue).joined(separator: ", "))"
    }
}

/// A plot in the city where a building can be placed
struct BuildingPlot: Identifiable {
    let id: Int
    let building: Building
    var isCompleted: Bool
    var challengeProgress: Double = 0.0
}
