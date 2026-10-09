import CoreGraphics

/// The `WorkshopAreaDefinition` for every outdoor Workshop map.
///
/// `legacy` is a lift of the values that used to be hardcoded inside
/// `WorkshopScene.swift` — same 10 stations, same 17 waypoints and edges, same
/// overlay positions, same 9 trees, same spawn. Step 1 of the workshop areas plan
/// is a pure data move: anything differing from what `WorkshopScene` drew before
/// is a bug. It stays live until the Bottega, Countryside and Hills maps replace it.
enum WorkshopAreaRegistry {

    static let legacy = WorkshopAreaDefinition(
        id: "legacy",
        displayName: "Leonardo's Workshop",

        // Matches city's 3500×2500 so terrain renders at same density
        mapSize: CGSize(width: 3500, height: 2500),

        sharpTerrainImageName: "WorkshopTerrain",
        blurredTerrainImageName: "BlurredWorkshopTerrain",

        // Station positions — scaled to 3500x2500 coordinate space
        // Workbench, furnace, and pigment table are inside the Crafting Room (interior scene)
        stations: [
            .quarry:       CGPoint(x: 1227, y: 1818),
            .river:        CGPoint(x: 1057, y: 1104),
            .volcano:      CGPoint(x: 2669, y: 2184),
            .clayPit:      CGPoint(x: 2992, y: 1005),
            .mine:         CGPoint(x: 2209, y: 1487),
            .forest:       CGPoint(x: 540,  y: 525),
            .market:       CGPoint(x: 1487, y: 365),
            .craftingRoom: CGPoint(x: 3160, y: 1350),
            .farm:         CGPoint(x: 1769, y: 850),
            .goldsmithWorkshop: CGPoint(x: 2835, y: 231),
        ],

        /// 16 waypoints + 1 spawn (Apr 23 2026 rewrite — cut from 64 to
        /// eliminate "overwalking" where the apprentice zig-zagged through
        /// multiple intermediate nodes on short trips). The graph is a simple
        /// hub-and-spoke: 10 station-access waypoints (one per station, placed
        /// just toward the map center from each station), 6 corridor hubs at
        /// natural crossings, and 1 spawn at the bottom-left avatar box.
        /// Paths are no longer expressive enough to navigate around arbitrary
        /// terrain obstacles — if the apprentice clips through a river or
        /// mountain, nudge waypoints in editor mode (press E, drag, paste the
        /// printed positions back here).
        waypoints: [
            // --- Station-access waypoints (one per outdoor station) ---
            /* 0  */ CGPoint(x:  720, y:  650),   // Forest access
            /* 1  */ CGPoint(x: 1487, y:  500),   // Market access
            /* 2  */ CGPoint(x: 2700, y:  380),   // Goldsmith access
            /* 3  */ CGPoint(x: 1769, y: 1000),   // Farm access
            /* 4  */ CGPoint(x: 1200, y: 1150),   // River access
            /* 5  */ CGPoint(x: 2850, y: 1150),   // Clay Pit access
            /* 6  */ CGPoint(x: 2150, y: 1400),   // Mine access
            /* 7  */ CGPoint(x: 3050, y: 1400),   // Crafting Room access
            /* 8  */ CGPoint(x: 1350, y: 1700),   // Quarry access
            /* 9  */ CGPoint(x: 2550, y: 2050),   // Volcano access

            // --- Corridor hubs ---
            /* 10 */ CGPoint(x: 1000, y:  700),   // Hub-SW (forest↔market↔river)
            /* 11 */ CGPoint(x: 2100, y:  400),   // Hub-S  (market↔goldsmith↔farm)
            /* 12 */ CGPoint(x: 1400, y: 1250),   // Hub-CenterW
            /* 13 */ CGPoint(x: 2500, y: 1250),   // Hub-CenterE
            /* 14 */ CGPoint(x: 1900, y: 1900),   // Hub-N  (quarry↔volcano↔mine)
            /* 15 */ CGPoint(x: 2850, y: 1800),   // Hub-NE (volcano↔crafting↔clay)

            // --- Home: avatar box (bottom-left spawn) ---
            /* 16 */ CGPoint(x:  200, y:  200),
        ],

        /// Bidirectional edges — ~31 pairs total, down from ~100.
        waypointEdges: [
            // Station access → corridor hubs
            [0, 10],            // Forest ↔ SW
            [1, 10], [1, 11],   // Market ↔ SW, S
            [2, 11],            // Goldsmith ↔ S
            [3, 11], [3, 12], [3, 13],  // Farm ↔ S, CenterW, CenterE
            [4, 10], [4, 12],   // River ↔ SW, CenterW
            [5, 11], [5, 13], [5, 15],  // Clay Pit ↔ S, CenterE, NE
            [6, 12], [6, 13], [6, 14],  // Mine ↔ CenterW, CenterE, N
            [7, 13], [7, 15],   // Crafting ↔ CenterE, NE
            [8, 12], [8, 14],   // Quarry ↔ CenterW, N
            [9, 14], [9, 15],   // Volcano ↔ N, NE

            // Hub ↔ Hub
            [10, 11], [10, 12],     // SW ↔ S, CenterW
            [11, 13],               // S ↔ CenterE
            [12, 13], [12, 14],     // CenterW ↔ CenterE, N
            [13, 14], [13, 15],     // CenterE ↔ N, NE
            [14, 15],               // N ↔ NE

            // Avatar spawn connections
            [16, 0], [16, 10],
        ],

        stationWaypoints: [
            .forest:            [0, 10],
            .market:            [1, 10, 11],
            .goldsmithWorkshop: [2, 11],
            .farm:              [3, 12, 13],
            .river:             [4, 12, 10],
            .clayPit:           [5, 13, 15],
            .mine:              [6, 12, 13],
            .craftingRoom:      [7, 13, 15],
            .quarry:            [8, 12, 14],
            .volcano:           [9, 14, 15],
        ],

        // Start at the avatar box waypoint (bottom-left of map)
        playerSpawnWaypoint: 16,

        // Default positions spread across the workshop map. Marina uses editor
        // mode to drag each tree to its real spot in WorkshopTerrain.
        trees: [
            ZoneTreePlacement(imageName: "Tree1", position: CGPoint(x:  500, y: 1000), scale: 1.0),
            ZoneTreePlacement(imageName: "Tree2", position: CGPoint(x:  800, y: 1100), scale: 1.0),
            ZoneTreePlacement(imageName: "Tree3", position: CGPoint(x: 1100, y: 1000), scale: 1.0),
            ZoneTreePlacement(imageName: "Tree4", position: CGPoint(x: 1400, y: 1100), scale: 1.0),
            ZoneTreePlacement(imageName: "Tree5", position: CGPoint(x: 1700, y: 1000), scale: 1.0),
            ZoneTreePlacement(imageName: "Tree6", position: CGPoint(x: 2230, y: 1124), scale: 1.0),
            ZoneTreePlacement(imageName: "Tree7", position: CGPoint(x: 2300, y: 1000), scale: 1.0),
            ZoneTreePlacement(imageName: "Tree8", position: CGPoint(x: 2600, y: 1100), scale: 1.0),
            ZoneTreePlacement(imageName: "Tree9", position: CGPoint(x: 2900, y: 1000), scale: 1.0),
        ],

        // Positions were dialed in via editor mode and dumped from the iPad.
        ambient: [
            .volcanoSmoke:         CGPoint(x: 2006, y: 2334),   // volcano crater
            .craftingChimneySmoke: CGPoint(x: 3207, y: 1767),   // Crafting Room chimney
            .smallSmokeAccent1:    CGPoint(x: 2218, y: 2243),   // distant vent
            .smallSmokeAccent2:    CGPoint(x: 3301, y: 1749),   // distant chimney
            .volcanoLava:          CGPoint(x: 2062, y: 2290),   // crater opening, top of the lava trail
            .volcanoGlow:          CGPoint(x: 2249, y: 2078),
            .quarryCrane:          CGPoint(x:  903, y: 1863),   // aligned with the painted crane
            .riverFlow:            CGPoint(x:  889, y:  632),
            .chicken:              CGPoint(x: 1307, y:  724),
            .fisherman:            CGPoint(x:  866, y:  642),
            .woodcutter:           CGPoint(x:  258, y:  610),
        ]
    )
}
