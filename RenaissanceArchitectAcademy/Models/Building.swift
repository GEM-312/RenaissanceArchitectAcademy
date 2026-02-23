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
    case sketched     // Sketching phases complete (sepia ink drawing)
    case construction // In progress (partial watercolor)
    case complete     // Finished (full watercolor)

    /// Custom state image name from Assets.xcassets
    var imageName: String {
        switch self {
        case .locked: return "StateLocked"
        case .available: return "StateAvailable"
        case .sketched: return "StateAvailable"  // Reuse until we have a sketch icon
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

    /// Custom image name from Assets.xcassets (nil → uses SF Symbol instead)
    var customImageName: String? {
        return nil
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
    let difficultyTier: MasteryLevel

    init(name: String, era: Era, city: RenaissanceCity? = nil, sciences: [Science], iconName: String, difficultyTier: MasteryLevel = .apprentice) {
        self.name = name
        self.era = era
        self.city = city
        self.sciences = sciences
        self.iconName = iconName
        self.difficultyTier = difficultyTier
    }

    /// Crafted materials needed from the Workshop to build this structure
    /// Each building requires materials for walls, roof, windows, and floors
    var requiredMaterials: [CraftedItem: Int] {
        switch name {
        // ── Ancient Rome ──────────────────────────────────
        case "Aqueduct":
            // Walls: limestone blocks + concrete core | Roof: lead-lined water channel | Floor: waterproof mortar
            return [.romanConcrete: 1, .limeMortar: 1, .leadSheeting: 1, .marbleSlabs: 1]
        case "Colosseum":
            // Walls: travertine + concrete | Roof: canvas velarium! | Floor: sand + travertine | Special: iron clamps
            return [.romanConcrete: 1, .silkFabric: 1, .marbleSlabs: 1, .bronzeFittings: 1]
        case "Roman Baths":
            // Walls: brick-faced concrete | Roof: concrete vaults + bronze tiles | Windows: cast glass | Floor: marble mosaic
            return [.romanConcrete: 1, .timberBeams: 1, .glassPanes: 1, .marbleSlabs: 1]
        case "Pantheon":
            // Walls: 6m-thick concrete | Roof: concrete dome + lead sheeting | Floor: colored marble | Special: bronze doors
            return [.romanConcrete: 1, .leadSheeting: 1, .marbleSlabs: 1, .bronzeFittings: 1]
        case "Roman Roads":
            // Four layers: stone foundation → rubble+mortar → gravel+mortar → basalt paving
            return [.romanConcrete: 1, .limeMortar: 1, .marbleSlabs: 1]
        case "Harbor":
            // Walls: underwater pozzolana concrete | Roof: timber warehouse roofs | Floor: stone docks | Special: lead ships
            return [.romanConcrete: 1, .timberBeams: 1, .marbleSlabs: 1, .leadSheeting: 1]
        case "Siege Workshop":
            // Walls: timber frame | Roof: timber + tile | Floor: packed earth + stone | Special: bronze gears, carved wood machines
            return [.timberBeams: 1, .terracottaTiles: 1, .bronzeFittings: 1, .carvedWood: 1]
        case "Insula":
            // Walls: brick ground, timber upper | Roof: terracotta tiles | Windows: mica sheets | Floor: wood planks
            return [.limeMortar: 1, .terracottaTiles: 1, .timberBeams: 1, .glassPanes: 1]

        // ── Renaissance Italy ─────────────────────────────
        case "Il Duomo":
            // Walls: polychrome marble | Roof: herringbone brick dome + terracotta | Windows: stained glass! | Floor: marble | Special: frescoes
            return [.marbleSlabs: 1, .terracottaTiles: 1, .stainedGlass: 1, .redFrescoPigment: 1]
        case "Botanical Garden":
            // Walls: brick perimeter | Roof: glass greenhouse | Floor: gravel + stone paths
            return [.limeMortar: 1, .glassPanes: 1, .marbleSlabs: 1]
        case "Glassworks":
            // Walls: thick brick (fire safety) | Roof: timber + tile with vents | Floor: brick + sand | Special: glass furnace
            return [.limeMortar: 1, .timberBeams: 1, .terracottaTiles: 1, .bronzeFittings: 1]
        case "Arsenal":
            // Walls: massive brick + Istrian limestone | Roof: wide-span timber trusses | Windows: Murano glass | Special: bronze cannons
            return [.romanConcrete: 1, .timberBeams: 1, .glassPanes: 1, .bronzeFittings: 1]
        case "Anatomy Theater":
            // Entirely carved walnut wood — no windows, lit by candles only
            return [.carvedWood: 2, .bronzeFittings: 1, .timberBeams: 1]
        case "Leonardo's Workshop":
            // Walls: brick + plaster | Roof: timber + terracotta | Windows: oiled linen/glass | Floor: terracotta tile | Special: bronze tools
            return [.limeMortar: 1, .timberBeams: 1, .glassPanes: 1, .bronzeFittings: 1]
        case "Flying Machine":
            // Frame: pine + bamboo | Skin: starched silk taffeta | Fittings: bronze pivots + iron wire
            return [.timberBeams: 1, .silkFabric: 1, .bronzeFittings: 1]
        case "Vatican Observatory":
            // Walls: brick tower + frescoes | Roof: lead sheeting + terracotta | Windows: precise meridian openings | Floor: marble meridian line
            return [.leadSheeting: 1, .blueFrescoPigment: 1, .glassPanes: 1, .marbleSlabs: 1]
        case "Printing Press":
            // Walls: timber frame | Roof: timber + tile | Windows: glass roundels | Special: lead type alloy, oak screw, carved wood frame
            return [.timberBeams: 1, .leadSheeting: 1, .glassPanes: 1, .carvedWood: 1]
        default:
            return [.limeMortar: 1]
        }
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
    var sketchingProgress: SketchingProgress = SketchingProgress()
}
