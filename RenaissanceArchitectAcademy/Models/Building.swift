import Foundation

/// Historical era for buildings
enum Era: String, CaseIterable, Codable {
    case ancientRome = "Ancient Rome"
    case renaissance = "Renaissance Italy"

    /// Custom city image name from Assets.xcassets
    var cityImageName: String {
        switch self {
        case .ancientRome: return "CityRome"
        case .renaissance: return "CityFlorence"
        }
    }
}

/// City/location for Renaissance Italy buildings
enum RenaissanceCity: String, CaseIterable, Codable {
    case florence = "Florence"
    case venice = "Venice"
    case padua = "Padua"
    case milan = "Milan"
    case rome = "Rome"
}

/// Building/plot state for visual representation
enum BuildingState: String, CaseIterable {
    case locked       // Not yet available
    case available    // Ready to start
    case construction // In progress
    case complete     // Finished

    /// Custom state image name from Assets.xcassets
    var imageName: String {
        switch self {
        case .locked: return "StateLocked"
        case .available: return "StateAvailable"
        case .construction: return "StateConstruction"
        case .complete: return "StateComplete"
        }
    }
}

/// Sciences that can be associated with building challenges
enum Science: String, CaseIterable, Codable {
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

    /// SF Symbol fallback icon name
    var sfSymbolName: String {
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

    /// Custom image name from Assets.xcassets (nil if no custom image)
    var customImageName: String? {
        switch self {
        case .mathematics: return "ScienceMath"
        case .physics: return "SciencePhysics"
        case .chemistry: return "ScienceChemistry"
        case .geometry: return "ScienceGeometry"
        case .engineering: return "ScienceEngineering"
        case .optics: return "ScienceOptics"
        case .biology: return "ScienceBiology"
        case .materials: return "ScienceMaterials"
        case .astronomy: return "ScienceAstronomy"
        case .geology: return "ScienceGeology"
        case .hydraulics: return "ScienceHydraulics"
        case .acoustics: return "ScienceAcoustics"
        case .architecture: return "ScienceArchitecture"
        }
    }

    /// Whether this science has a custom image
    var hasCustomImage: Bool {
        customImageName != nil
    }
}

/// A building that can be constructed
struct Building: Identifiable {
    let id = UUID()
    let name: String
    let era: Era
    let city: RenaissanceCity?  // Only for Renaissance buildings
    let sciences: [Science]
    let iconName: String

    init(name: String, era: Era, city: RenaissanceCity? = nil, sciences: [Science], iconName: String) {
        self.name = name
        self.era = era
        self.city = city
        self.sciences = sciences
        self.iconName = iconName
    }

    var description: String {
        if let city = city {
            return "A \(era.rawValue) building in \(city.rawValue) involving \(sciences.map(\.rawValue).joined(separator: ", "))"
        }
        return "A \(era.rawValue) building involving \(sciences.map(\.rawValue).joined(separator: ", "))"
    }

    var locationName: String {
        city?.rawValue ?? "Rome"
    }
}

/// A plot in the city where a building can be placed
struct BuildingPlot: Identifiable {
    let id: Int
    let building: Building
    var isCompleted: Bool
    var challengeProgress: Double = 0.0
}
