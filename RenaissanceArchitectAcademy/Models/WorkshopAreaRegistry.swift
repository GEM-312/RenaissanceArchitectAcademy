import CoreGraphics

/// The `WorkshopAreaDefinition` for every outdoor Workshop map — the Bottega hub,
/// the Countryside and the Hills (see `docs/plans/workshop-areas-plan.md`). The
/// single pre-split map (`legacy`, `WorkshopTerrain`) was removed Oct 24 2026 once
/// signpost travel between these three was tested on iPad.
enum WorkshopAreaRegistry {

    /// The three areas players travel between by signpost. The Bottega is the hub:
    /// both outer areas connect only to it. The DEBUG area button cycles through these.
    static let all: [WorkshopAreaDefinition] = [bottega, countryside, hills]

    static func area(id: String) -> WorkshopAreaDefinition {
        all.first { $0.id == id } ?? bottega
    }

    /// The area a station is on — where a walk to that station has to go.
    static func areaId(containing station: ResourceStationType) -> String? {
        all.first { $0.stations[station] != nil }?.id
    }

    /// The Bottega — the arrival hub: Crafting Room, Goldsmith, Market around a
    /// cobbled plaza (Oct 20 2026 terrain). Station and plaza positions confirmed by
    /// Marina Oct 24; the two road waypoints (6, 7) and signposts are first guesses
    /// read off the art. No trees, no overlays — the chimney smoke is already painted.
    static let bottega = WorkshopAreaDefinition(
        id: "bottega",
        displayName: "Bottega",

        mapSize: CGSize(width: 3500, height: 2500),

        sharpTerrainImageName: "WorkshopBottegaTerrain",

        stations: [
            .craftingRoom:      CGPoint(x: 1460, y: 1460),   // arched double doors
            .goldsmithWorkshop: CGPoint(x: 1970, y: 1480),   // carved shopfront
            .market:            CGPoint(x: 2400, y: 1100),   // striped stalls
        ],

        waypoints: [
            /* 0 */ CGPoint(x: 1460, y: 1280),   // Crafting Room access
            /* 1 */ CGPoint(x: 1950, y: 1290),   // Goldsmith access
            /* 2 */ CGPoint(x: 2250, y:  900),   // Market access
            /* 3 */ CGPoint(x: 1500, y: 1150),   // Plaza by the well
            /* 4 */ CGPoint(x: 1500, y:  900),   // Plaza centre
            /* 5 */ CGPoint(x: 1600, y:  600),   // Spawn — foot of the cobbled path
            /* 6 */ CGPoint(x:  760, y:  840),   // Left road, by the Countryside signpost
            /* 7 */ CGPoint(x: 3100, y: 1180),   // Right road, by the Hills signpost
        ],

        waypointEdges: [
            [0, 3], [1, 3], [1, 4], [2, 4], [3, 4], [4, 5],
            [4, 6], [2, 7],
        ],

        stationWaypoints: [
            .craftingRoom:      [0, 3],
            .goldsmithWorkshop: [1, 3, 4],
            .market:            [2, 4],
        ],

        playerSpawnWaypoint: 5,

        exits: [
            WorkshopAreaExit(destinationAreaId: "countryside", position: CGPoint(x:  680, y:  960), waypoint: 6),
            WorkshopAreaExit(destinationAreaId: "hills",       position: CGPoint(x: 3150, y: 1320), waypoint: 7),
        ],

        trees: [],

        ambient: [:]
    )

    /// The Countryside — farm inside the river bend, river with a sandbank, wheat
    /// field, olive grove, forest gate at top right (Oct 20 2026 terrain). Positions
    /// are first guesses read off the art, awaiting Marina's editor drags. No bridge
    /// is painted, so the 2↔3 edge crosses open water. Spawn is on the road by the
    /// signpost (the way in from the Bottega).
    static let countryside = WorkshopAreaDefinition(
        id: "countryside",
        displayName: "Countryside",

        mapSize: CGSize(width: 3500, height: 2500),

        sharpTerrainImageName: "WorkshopCountrysideTerrain",

        stations: [
            .farm:   CGPoint(x:  700, y: 1560),   // farmhouse
            .river:  CGPoint(x: 1400, y:  900),   // water's edge by the sandbank
            .forest: CGPoint(x: 2540, y: 1660),   // footpath into the trees
        ],

        waypoints: [
            /* 0 */ CGPoint(x:  820, y: 1380),   // Farm access — path below the farmhouse
            /* 1 */ CGPoint(x:  900, y:  920),   // Meadow below the garden fence
            /* 2 */ CGPoint(x: 1240, y:  820),   // River access — sandbank
            /* 3 */ CGPoint(x: 1860, y:  920),   // Right bank
            /* 4 */ CGPoint(x: 2260, y: 1280),   // Olive grove footpath
            /* 5 */ CGPoint(x: 2460, y: 1480),   // Forest access
            /* 6 */ CGPoint(x: 2920, y:  860),   // Spawn — road by the signpost
        ],

        waypointEdges: [
            [0, 1], [1, 2], [2, 3], [3, 4], [4, 5], [4, 6],
        ],

        stationWaypoints: [
            .farm:   [0, 1],
            .river:  [2, 1, 3],
            .forest: [5, 4],
        ],

        playerSpawnWaypoint: 6,

        exits: [
            WorkshopAreaExit(destinationAreaId: "bottega", position: CGPoint(x: 2820, y: 840), waypoint: 6),
        ],

        trees: [],

        ambient: [:]
    )

    /// The Hills & Quarries — quarry terraces, mine entrance, red clay pit, volcano
    /// with painted smoke and lava (Oct 20 2026 terrain). Positions are first guesses
    /// read off the art, awaiting Marina's editor drags. No overlays — the volcano
    /// smoke and lava are already painted. Spawn is on the road by the signpost.
    static let hills = WorkshopAreaDefinition(
        id: "hills",
        displayName: "Hills",

        mapSize: CGSize(width: 3500, height: 2500),

        sharpTerrainImageName: "WorkshopHillsTerrain",

        stations: [
            .quarry:  CGPoint(x:  880, y: 1200),   // stone terraces
            .mine:    CGPoint(x: 1510, y: 1100),   // timber-framed entrance
            .clayPit: CGPoint(x: 2360, y:  640),   // red pit
            .volcano: CGPoint(x: 2000, y: 2000),   // crater
        ],

        waypoints: [
            /* 0 */ CGPoint(x: 1120, y:  720),   // Quarry access
            /* 1 */ CGPoint(x: 1600, y:  960),   // Mine access
            /* 2 */ CGPoint(x: 1920, y:  580),   // Clay Pit access
            /* 3 */ CGPoint(x: 1520, y: 1720),   // Volcano access — top of the path
            /* 4 */ CGPoint(x: 1700, y:  840),   // Path junction below the mine
            /* 5 */ CGPoint(x: 1780, y: 1260),   // Volcano path, halfway up
            /* 6 */ CGPoint(x: 1960, y:  380),   // Bottom road
            /* 7 */ CGPoint(x:  760, y:  380),   // Spawn — road by the signpost
        ],

        waypointEdges: [
            [7, 0], [0, 4], [4, 1], [4, 5], [5, 3], [4, 2], [2, 6], [6, 7],
        ],

        stationWaypoints: [
            .quarry:  [0, 4],
            .mine:    [1, 4],
            .clayPit: [2, 4, 6],
            .volcano: [3, 5],
        ],

        playerSpawnWaypoint: 7,

        exits: [
            WorkshopAreaExit(destinationAreaId: "bottega", position: CGPoint(x: 650, y: 460), waypoint: 7),
        ],

        trees: [],

        ambient: [:]
    )
}
