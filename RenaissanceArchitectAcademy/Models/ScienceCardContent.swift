import SwiftUI

// MARK: - Science Card Types

/// The 4 science categories shown on forest tree cards
enum ForestCardCategory: String, CaseIterable, Identifiable {
    case architecture = "Architecture"
    case furniture = "Furniture"
    case modernUse = "Modern Use"
    case biology = "Biology"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .architecture: return "building.columns.fill"
        case .furniture: return "chair.lounge.fill"
        case .modernUse: return "hammer.fill"
        case .biology: return "leaf.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .architecture: return RenaissanceColors.ochre
        case .furniture: return RenaissanceColors.warmBrown
        case .modernUse: return RenaissanceColors.renaissanceBlue
        case .biology: return RenaissanceColors.sageGreen
        }
    }
}

/// Tracks the phase of an individual science card
enum CardPhase: Equatable {
    case faceUp        // Showing category name + icon, not yet tapped
    case reading       // Card flipped, showing lesson text
    case activity      // Keyword matching mini-game
    case completed     // Green checkmark, card done
}

/// Keyword + definition pair for the matching activity
struct KeywordPair: Identifiable, Equatable {
    let id = UUID()
    let keyword: String
    let definition: String

    static func == (lhs: KeywordPair, rhs: KeywordPair) -> Bool {
        lhs.id == rhs.id
    }
}

/// Complete card content for one category of one tree
struct ScienceCardData: Identifiable {
    let id = UUID()
    let category: ForestCardCategory
    let lessonText: String
    let keywords: [KeywordPair]
}

// MARK: - Content Lookup

enum ScienceCardContent {

    /// Build 4 science cards for a given tree name
    static func cards(for treeName: String) -> [ScienceCardData] {
        switch treeName {
        case "Oak":     return oakCards
        case "Chestnut": return chestnutCards
        case "Cypress": return cypressCards
        case "Walnut":  return walnutCards
        case "Poplar":  return poplarCards
        default:        return oakCards
        }
    }

    // MARK: - Oak

    private static var oakCards: [ScienceCardData] { [
        ScienceCardData(
            category: .architecture,
            lessonText: "Oak is the backbone of Renaissance construction. Its heartwood forms roof trusses — triangular frames that span cathedral naves and support massive stone roofs. The Colosseum's retractable awning used oak masts. Load-bearing oak beams can support tons of weight for centuries.",
            keywords: [
                KeywordPair(keyword: "Roof truss", definition: "Triangular frame supporting a roof"),
                KeywordPair(keyword: "Heartwood", definition: "Dense inner wood of the tree"),
                KeywordPair(keyword: "Load-bearing", definition: "Carries the weight of structure above"),
                KeywordPair(keyword: "Nave", definition: "Central hall of a cathedral"),
            ]
        ),
        ScienceCardData(
            category: .furniture,
            lessonText: "Oak's tight grain holds the most intricate carvings for generations without splitting. Renaissance carvers shaped it into dining tables, church pews, and elaborate altarpieces. The wood darkens with age, developing a rich patina that collectors prize. Oak pews in Italian churches still bear 500-year-old carvings.",
            keywords: [
                KeywordPair(keyword: "Grain", definition: "Pattern of fibers in wood"),
                KeywordPair(keyword: "Altarpiece", definition: "Decorated panel behind a church altar"),
                KeywordPair(keyword: "Patina", definition: "Surface aging that adds beauty"),
                KeywordPair(keyword: "Pew", definition: "Long bench for church seating"),
            ]
        ),
        ScienceCardData(
            category: .modernUse,
            lessonText: "Oak remains the gold standard for structural timber worldwide. It is used for hardwood flooring, wine barrels (the tannins flavor the wine), and whiskey casks. Shipbuilders still choose oak for hulls. A single mature oak can yield enough timber for a small house frame.",
            keywords: [
                KeywordPair(keyword: "Tannins", definition: "Natural chemicals that flavor wine in barrels"),
                KeywordPair(keyword: "Cask", definition: "Wooden barrel for aging spirits"),
                KeywordPair(keyword: "Hull", definition: "Main body of a ship"),
            ]
        ),
        ScienceCardData(
            category: .biology,
            lessonText: "Oak trees only produce acorns after 20-50 years of growth — patience rewarded. A mature oak transpires 150 liters of water daily through its leaves, cooling the entire forest around it. Oaks can live over 1,000 years and a single tree supports 2,300 species of insects, birds, and fungi.",
            keywords: [
                KeywordPair(keyword: "Transpire", definition: "Release water vapor through leaves"),
                KeywordPair(keyword: "Acorn", definition: "Oak seed, produced after decades"),
                KeywordPair(keyword: "Symbiosis", definition: "Species living together beneficially"),
                KeywordPair(keyword: "Canopy", definition: "Upper layer of forest formed by tree crowns"),
            ]
        ),
    ] }

    // MARK: - Chestnut

    private static var chestnutCards: [ScienceCardData] { [
        ScienceCardData(
            category: .architecture,
            lessonText: "Chestnut wood is rich in natural tannins — chemicals that repel insects and resist moisture. Renaissance builders used it for window frames and exterior cladding on palazzi. Unlike oak, chestnut needs no treatment to survive outdoors. Its natural rot resistance makes it ideal for any surface exposed to Italian rain.",
            keywords: [
                KeywordPair(keyword: "Tannin", definition: "Natural chemical that repels insects"),
                KeywordPair(keyword: "Cladding", definition: "Outer covering of a building"),
                KeywordPair(keyword: "Palazzo", definition: "Grand Italian townhouse or palace"),
                KeywordPair(keyword: "Rot resistance", definition: "Ability to withstand decay from moisture"),
            ]
        ),
        ScienceCardData(
            category: .furniture,
            lessonText: "Chestnut was called 'the bread tree' because its flour fed entire mountain villages during famine. Craftsmen shaped it into storage chests, bed frames, and rustic tables. The wood's warm honey color and straight grain made it a favorite for everyday Italian furniture — beautiful without being precious.",
            keywords: [
                KeywordPair(keyword: "Bread tree", definition: "Nickname — its flour fed villages"),
                KeywordPair(keyword: "Straight grain", definition: "Parallel wood fibers, easy to work"),
                KeywordPair(keyword: "Rustic", definition: "Simple, sturdy countryside style"),
            ]
        ),
        ScienceCardData(
            category: .modernUse,
            lessonText: "Today chestnut is prized for fence posts and outdoor furniture because its tannin content means no chemical treatment is needed. Garden structures, pergolas, and wine stakes across Italy are chestnut. It is one of the most sustainable construction woods — fast-growing and naturally durable.",
            keywords: [
                KeywordPair(keyword: "Pergola", definition: "Open garden structure with climbing plants"),
                KeywordPair(keyword: "Sustainable", definition: "Can be harvested without depleting"),
                KeywordPair(keyword: "Wine stake", definition: "Post supporting grapevines in a vineyard"),
            ]
        ),
        ScienceCardData(
            category: .biology,
            lessonText: "Chestnut bark contains 8-13% tannin — a powerful chemical defense. Medieval builders discovered that wood soaked in this natural tannin resists both rot and insects without treatment. The tree practices coppicing: when cut, it regrows from the stump, providing timber every 15-20 years indefinitely.",
            keywords: [
                KeywordPair(keyword: "Coppicing", definition: "Cutting a tree so it regrows from the stump"),
                KeywordPair(keyword: "Chemical defense", definition: "Natural compounds that protect the tree"),
                KeywordPair(keyword: "Bark", definition: "Outer protective layer of a tree trunk"),
                KeywordPair(keyword: "Stump", definition: "Base left after a tree is cut"),
            ]
        ),
    ] }

    // MARK: - Cypress

    private static var cypressCards: [ScienceCardData] { [
        ScienceCardData(
            category: .architecture,
            lessonText: "Cypress wood contains aromatic oils that repel moths and preserve sacred spaces. Renaissance builders chose it for church doors, chapel interiors, and ceiling panels. The doors of old St. Peter's Basilica were cypress and lasted 1,100 years. Its fine, even texture takes detailed carving beautifully.",
            keywords: [
                KeywordPair(keyword: "Aromatic oils", definition: "Natural fragrant chemicals in the wood"),
                KeywordPair(keyword: "Chapel", definition: "Small place of worship"),
                KeywordPair(keyword: "Basilica", definition: "Large important church building"),
                KeywordPair(keyword: "Texture", definition: "Feel and appearance of the wood surface"),
            ]
        ),
        ScienceCardData(
            category: .furniture,
            lessonText: "Cypress's moth-repelling scent made it perfect for carved chests, wardrobes, and hope chests where precious linens and vestments were stored. A Renaissance bride's dowry chest was often cypress — protecting her trousseau for a lifetime. The wood's sweet cedar-like fragrance persists for decades.",
            keywords: [
                KeywordPair(keyword: "Hope chest", definition: "Chest storing a bride's belongings"),
                KeywordPair(keyword: "Vestment", definition: "Ceremonial religious garment"),
                KeywordPair(keyword: "Trousseau", definition: "Bride's collection of household items"),
                KeywordPair(keyword: "Dowry", definition: "Property a bride brings to marriage"),
            ]
        ),
        ScienceCardData(
            category: .modernUse,
            lessonText: "The tall sentinel cypress defines the Tuscan landscape — rows of dark spires lining hillside roads. Today its essential oils are used in aromatherapy and perfumery. The wood serves in garden trellises and decorative structures. Cypress is planted as windbreaks to protect olive groves and vineyards.",
            keywords: [
                KeywordPair(keyword: "Sentinel", definition: "Standing guard — describes the tree's tall form"),
                KeywordPair(keyword: "Essential oil", definition: "Concentrated plant extract used in perfume"),
                KeywordPair(keyword: "Windbreak", definition: "Row of trees blocking wind"),
            ]
        ),
        ScienceCardData(
            category: .biology,
            lessonText: "Cypress resin contains natural fungicides and insecticides — a built-in chemical defense system. The tree is evergreen, photosynthesizing year-round even in mild Italian winters. Its columnar shape (fastigiate form) evolved to shed snow efficiently. Cypress can live 1,000+ years in Mediterranean climates.",
            keywords: [
                KeywordPair(keyword: "Fungicide", definition: "Substance that kills fungi"),
                KeywordPair(keyword: "Evergreen", definition: "Keeps leaves all year round"),
                KeywordPair(keyword: "Fastigiate", definition: "Narrow, columnar tree shape"),
                KeywordPair(keyword: "Resin", definition: "Sticky substance trees produce for defense"),
            ]
        ),
    ] }

    // MARK: - Walnut

    private static var walnutCards: [ScienceCardData] { [
        ScienceCardData(
            category: .architecture,
            lessonText: "Walnut was reserved for the finest Renaissance interiors — inlaid palazzo ceilings, ornamental door frames, and decorative wall panels. Its deep chocolate color and swirling grain patterns made every surface a work of art. Only wealthy patrons like the Medici could afford walnut paneling throughout.",
            keywords: [
                KeywordPair(keyword: "Inlaid", definition: "Decorative wood set into a surface"),
                KeywordPair(keyword: "Ornamental", definition: "Designed for beauty, not structure"),
                KeywordPair(keyword: "Medici", definition: "Powerful Renaissance banking family"),
                KeywordPair(keyword: "Paneling", definition: "Wood sheets covering interior walls"),
            ]
        ),
        ScienceCardData(
            category: .furniture,
            lessonText: "Master carvers and cabinet makers prized walnut above all other woods. They crafted it into writing desks, portrait frames, and marquetry — pictures made from tiny wood pieces inlaid into furniture. A walnut writing desk could take a craftsman six months. The wood was so valuable it was sometimes used as currency.",
            keywords: [
                KeywordPair(keyword: "Marquetry", definition: "Pictures made from inlaid wood pieces"),
                KeywordPair(keyword: "Cabinet maker", definition: "Skilled furniture craftsman"),
                KeywordPair(keyword: "Writing desk", definition: "Table designed for reading and writing"),
            ]
        ),
        ScienceCardData(
            category: .modernUse,
            lessonText: "Walnut still commands premium prices worldwide. Gunstock makers choose it for its shock absorption. Luxury veneer, musical instruments, and high-end cabinetry all use walnut. A single large walnut tree can be worth thousands of euros — some Italian farmers grow them as their retirement investment.",
            keywords: [
                KeywordPair(keyword: "Veneer", definition: "Thin decorative wood layer glued to surface"),
                KeywordPair(keyword: "Shock absorption", definition: "Ability to cushion impact"),
                KeywordPair(keyword: "Premium", definition: "Highest quality commanding top price"),
            ]
        ),
        ScienceCardData(
            category: .biology,
            lessonText: "Walnut roots release juglone, a natural herbicide that kills competing plants nearby — this is called allelopathy, chemical warfare between plants. Few species can grow under a walnut tree. This gives walnuts more sunlight and water but also makes walnut forests surprisingly sparse and park-like.",
            keywords: [
                KeywordPair(keyword: "Juglone", definition: "Chemical walnut roots release to kill rivals"),
                KeywordPair(keyword: "Allelopathy", definition: "Chemical warfare between plants"),
                KeywordPair(keyword: "Herbicide", definition: "Substance that kills plants"),
                KeywordPair(keyword: "Sparse", definition: "Thinly spread, few plants growing together"),
            ]
        ),
    ] }

    // MARK: - Poplar

    private static var poplarCards: [ScienceCardData] { [
        ScienceCardData(
            category: .architecture,
            lessonText: "Every Renaissance construction site depended on poplar. Its lightweight timber was perfect for scaffolding, temporary centering for arches, and formwork for concrete. When the Duomo's dome was built, poplar scaffolding held workers 100 meters in the air. After construction, the poplar was recycled into crates.",
            keywords: [
                KeywordPair(keyword: "Scaffolding", definition: "Temporary platform for workers at height"),
                KeywordPair(keyword: "Centering", definition: "Wooden frame supporting an arch during construction"),
                KeywordPair(keyword: "Formwork", definition: "Mold that holds concrete until it sets"),
                KeywordPair(keyword: "Duomo", definition: "Florence's famous cathedral dome"),
            ]
        ),
        ScienceCardData(
            category: .furniture,
            lessonText: "Poplar's smooth, pale surface made it the Renaissance artist's canvas. Botticelli painted 'The Birth of Venus' on poplar panels. The wood was also used for simple shelving and storage crates — everyday items that Renaissance homes needed. Unlike oak or walnut, poplar was affordable for common people.",
            keywords: [
                KeywordPair(keyword: "Panel painting", definition: "Art painted on a flat wood surface"),
                KeywordPair(keyword: "Botticelli", definition: "Renaissance artist, painted Birth of Venus"),
                KeywordPair(keyword: "Canvas", definition: "Surface an artist paints on"),
            ]
        ),
        ScienceCardData(
            category: .modernUse,
            lessonText: "Poplar is Italy's most renewable timber — it grows up to 3 meters per year. Today it becomes plywood, paper pulp, matchsticks, and packaging. Poplar plantations along the Po River valley are harvested every 10-12 years. Italy is Europe's largest poplar producer, growing it as a fast-rotation crop.",
            keywords: [
                KeywordPair(keyword: "Renewable", definition: "Can be regrown and harvested repeatedly"),
                KeywordPair(keyword: "Plywood", definition: "Layered wood sheets glued together"),
                KeywordPair(keyword: "Fast-rotation", definition: "Harvested every 10-12 years"),
                KeywordPair(keyword: "Po River", definition: "Italy's longest river, runs through the north"),
            ]
        ),
        ScienceCardData(
            category: .biology,
            lessonText: "Poplar is one of Europe's fastest-growing trees — up to 3 meters per year. This rapid growth makes it a powerful carbon sink, absorbing CO2 faster than most species. Its roots stabilize riverbanks, and its leaves decompose quickly, enriching soil. Scientists study poplar's genome because it was the first tree to be fully sequenced.",
            keywords: [
                KeywordPair(keyword: "Carbon sink", definition: "Absorbs more CO2 than it releases"),
                KeywordPair(keyword: "Genome", definition: "Complete set of DNA instructions"),
                KeywordPair(keyword: "Decompose", definition: "Break down into nutrients in soil"),
                KeywordPair(keyword: "Sequenced", definition: "DNA fully mapped by scientists"),
            ]
        ),
    ] }
}
