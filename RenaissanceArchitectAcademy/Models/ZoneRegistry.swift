import CoreGraphics

/// The `ZoneDefinition` for every zone in the game.
///
/// `ancientRome` below is a byte-for-byte lift of the values that used to be
/// hardcoded inside `CityScene.swift` — same 40 waypoints, same 56 edges, same
/// 17-building list, same 9 trees, same labels, same spawn. Step 1 of the zone
/// plan is a pure data move: if anything here differs from what `CityScene`
/// drew before, that is a bug, not an improvement.
enum ZoneRegistry {

    /// Ancient Rome's terrain PNG is 4500px wide drawn into a 3500pt scene.
    /// Cut-outs lifted from it shrink by this to cover their own footprint.
    private static let romeTerrainPixelWidth: CGFloat = 4500
    private static let romeTreeScale: CGFloat = 3500 / romeTerrainPixelWidth

    static let ancientRome = ZoneDefinition(
        id: "ancientRome",
        displayName: "Ancient Rome",

        // Matches the standard used by every other scene in the project —
        // 3500×2500 coordinate space. Was 4048×2144 before Apr 23 2026; that
        // aspect (1.888:1) stretched the 1.4:1 terrain horizontally.
        mapSize: CGSize(width: 3500, height: 2500),
        terrainPixelWidth: romeTerrainPixelWidth,

        sharpTerrainImageName: "Terrain",
        blurredTerrainImageName: "BlurredTerrain",

        buildings: [
            // ========================================
            // ANCIENT ROME
            // ========================================
            // Use editor mode (E) to fine-tune positions over baked-in buildings
            ZoneBuildingPlacement(buildingId: "aqueduct", name: "Aqueduct", position: CGPoint(x: 2304, y: 922), era: "rome", rotation: 0),
            ZoneBuildingPlacement(buildingId: "colosseum", name: "Colosseum", position: CGPoint(x: 1491, y: 1384), era: "rome", rotation: 0),
            ZoneBuildingPlacement(buildingId: "romanBaths", name: "Roman Baths", position: CGPoint(x: 1012, y: 1523), era: "rome", rotation: 2),
            ZoneBuildingPlacement(buildingId: "pantheon", name: "Pantheon", position: CGPoint(x: 2192, y: 1677), era: "rome", rotation: 0),
            ZoneBuildingPlacement(buildingId: "romanRoads", name: "Roman Roads", position: CGPoint(x: 1004, y: 861), era: "rome", rotation: 0),
            ZoneBuildingPlacement(buildingId: "harbor", name: "Harbor", position: CGPoint(x: 2922, y: 264), era: "rome", rotation: 0),
            ZoneBuildingPlacement(buildingId: "siegeWorkshop", name: "Siege Workshop", position: CGPoint(x: 3007, y: 1717), era: "rome", rotation: 0),
            ZoneBuildingPlacement(buildingId: "insula", name: "Insula", position: CGPoint(x: 1250, y: 1903), era: "rome", rotation: 0),

            // ========================================
            // RENAISSANCE ITALY
            // ========================================
            // Still listed here because this is a byte-for-byte lift of today's
            // single-map scene. They move to their own zones in the plan's step 5.

            // Florence
            ZoneBuildingPlacement(buildingId: "duomo", name: "Il Duomo", position: CGPoint(x: 1945, y: 1143), era: "florence", rotation: 0),
            ZoneBuildingPlacement(buildingId: "botanicalGarden", name: "Botanical Garden", position: CGPoint(x: 2497, y: 151), era: "florence", rotation: 0),

            // Venice
            ZoneBuildingPlacement(buildingId: "glassworks", name: "Glassworks", position: CGPoint(x: 1657, y: 548), era: "venice", rotation: 0),
            ZoneBuildingPlacement(buildingId: "arsenal", name: "Arsenal", position: CGPoint(x: 2906, y: 709), era: "venice", rotation: 0),

            // Padua
            ZoneBuildingPlacement(buildingId: "anatomyTheater", name: "Anatomy Theater", position: CGPoint(x: 2393, y: 1934), era: "padua", rotation: 0),

            // Milan
            ZoneBuildingPlacement(buildingId: "leonardoWorkshop", name: "Leonardo's Workshop", position: CGPoint(x: 536, y: 471), era: "milan", rotation: 0),
            ZoneBuildingPlacement(buildingId: "flyingMachine", name: "Flying Machine", position: CGPoint(x: 922, y: 1321), era: "milan", rotation: 0),

            // Renaissance Rome
            ZoneBuildingPlacement(buildingId: "vaticanObservatory", name: "Vatican Observatory", position: CGPoint(x: 1028, y: 254), era: "renaissanceRome", rotation: 0),
            ZoneBuildingPlacement(buildingId: "printingPress", name: "Printing Press", position: CGPoint(x: 3121, y: 262), era: "renaissanceRome", rotation: 0)
        ],

        // The Duomo is Florence's; this terrain is Ancient Rome only.
        hiddenBuildingIds: ["duomo"],

        // 40 road junctions connecting the 17 buildings across the 3500×2500 map
        waypoints: [
            // --- Ancient Rome side (left) ---
            /* 0  */ CGPoint(x: 200,  y: 1800),  // near aqueduct-colosseum
            /* 1  */ CGPoint(x: 400,  y: 2100),  // near aqueduct
            /* 2  */ CGPoint(x: 400,  y: 1600),  // W mid
            /* 3  */ CGPoint(x: 300,  y: 1250),  // near roman baths
            /* 4  */ CGPoint(x: 550,  y: 1500),  // rome crossroads
            /* 5  */ CGPoint(x: 500,  y: 1050),  // between baths-pantheon
            /* 6  */ CGPoint(x: 700,  y: 1200),  // near pantheon
            /* 7  */ CGPoint(x: 400,  y: 750),   // near roman roads
            /* 8  */ CGPoint(x: 250,  y: 550),   // near harbor
            /* 9  */ CGPoint(x: 500,  y: 550),   // S rome
            /* 10 */ CGPoint(x: 600,  y: 400),   // near siege workshop
            /* 11 */ CGPoint(x: 750,  y: 650),   // near insula
            /* 12 */ CGPoint(x: 700,  y: 900),   // rome south junction

            // --- Center spine ---
            /* 13 */ CGPoint(x: 1000, y: 2000),  // upper center-left
            /* 14 */ CGPoint(x: 1100, y: 1500),  // center-left mid
            /* 15 */ CGPoint(x: 1000, y: 1100),  // center-left lower
            /* 16 */ CGPoint(x: 1100, y: 700),   // center-left south
            /* 17 */ CGPoint(x: 1400, y: 1800),  // center
            /* 18 */ CGPoint(x: 1400, y: 1300),  // center mid
            /* 19 */ CGPoint(x: 1400, y: 900),   // center south

            // --- Milan area ---
            /* 20 */ CGPoint(x: 1700, y: 2100),  // near leonardo's workshop
            /* 21 */ CGPoint(x: 1600, y: 1700),  // near flying machine
            /* 22 */ CGPoint(x: 1800, y: 1500),  // milan junction

            // --- Padua ---
            /* 23 */ CGPoint(x: 2100, y: 1500),  // near anatomy theater
            /* 24 */ CGPoint(x: 2000, y: 1200),  // padua south

            // --- Florence area ---
            /* 25 */ CGPoint(x: 2300, y: 2200),  // near duomo
            /* 26 */ CGPoint(x: 2500, y: 2000),  // florence junction
            /* 27 */ CGPoint(x: 2700, y: 1900),  // near botanical garden
            /* 28 */ CGPoint(x: 2600, y: 1700),  // florence south

            // --- Venice area ---
            /* 29 */ CGPoint(x: 3000, y: 1800),  // venice north
            /* 30 */ CGPoint(x: 3100, y: 1500),  // near glassworks
            /* 31 */ CGPoint(x: 2900, y: 1350),  // near arsenal
            /* 32 */ CGPoint(x: 2800, y: 1100),  // venice south

            // --- Renaissance Rome area ---
            /* 33 */ CGPoint(x: 2200, y: 900),   // between padua-renRome
            /* 34 */ CGPoint(x: 2500, y: 1000),  // near vatican observatory
            /* 35 */ CGPoint(x: 2100, y: 600),   // near printing press
            /* 36 */ CGPoint(x: 2500, y: 700),   // ren rome south
            /* 37 */ CGPoint(x: 1800, y: 800),   // center-south junction

            // --- Extra connectors ---
            /* 38 */ CGPoint(x: 1800, y: 2000),  // upper center
            /* 39 */ CGPoint(x: 2200, y: 1800),  // between padua-florence
        ],

        waypointEdges: [
            // Ancient Rome chain
            [1, 0], [0, 2], [2, 4], [2, 3], [3, 5], [4, 5], [4, 6],
            [5, 6], [5, 7], [7, 8], [7, 9], [8, 9], [9, 10], [10, 11],
            [11, 12], [12, 7], [6, 12],

            // Rome to center
            [0, 13], [4, 14], [6, 15], [12, 16], [14, 15], [15, 16],
            [13, 17], [14, 18], [16, 19],

            // Center spine
            [17, 18], [18, 19], [17, 21], [18, 22], [19, 37],

            // Milan
            [13, 20], [20, 38], [38, 17], [17, 21], [21, 22],

            // Padua
            [22, 23], [23, 24], [24, 33],

            // Florence
            [20, 25], [25, 26], [26, 27], [26, 28], [27, 28],
            [38, 26], [39, 28],

            // Venice
            [28, 29], [29, 30], [30, 31], [31, 32], [27, 29],

            // Renaissance Rome
            [24, 34], [33, 34], [33, 35], [34, 36], [35, 36],
            [19, 35], [37, 35], [32, 34],

            // Cross-links
            [21, 39], [23, 39], [39, 23], [22, 24], [37, 19],
        ],

        buildingWaypoints: [
            "aqueduct":          [1, 0],
            "colosseum":         [0, 4],
            "romanBaths":        [3, 5],
            "pantheon":          [6, 5],
            "romanRoads":        [7, 12],
            "harbor":            [8, 9],
            "siegeWorkshop":     [10, 9],
            "insula":            [11, 12],
            "duomo":             [25, 26],
            "botanicalGarden":   [27, 28],
            "glassworks":        [30, 29],
            "arsenal":           [31, 32],
            "anatomyTheater":    [23, 24],
            "leonardoWorkshop":  [20, 38],
            "flyingMachine":     [21, 17],
            "vaticanObservatory": [34, 36],
            "printingPress":     [35, 33],
        ],

        // Lower-left, a short walk from the Roman road at (1004, 861) so the
        // apprentice starts on the road network rather than mid-field.
        playerSpawn: CGPoint(x: 620, y: 540),
        cameraMaxZoomOutScale: 3.5,

        // Nine trees Marina cut out of this terrain so they can sway. Each one
        // goes back exactly where it came from — positions were recovered by
        // template-matching each cut-out against the terrain art.
        trees: [
            ZoneTreePlacement(imageName: "CityTree22", position: CGPoint(x: 1015, y: 1301), scale: romeTreeScale),   // broad olive, mid-map ridge
            ZoneTreePlacement(imageName: "CityTree23", position: CGPoint(x: 1333, y:  799), scale: romeTreeScale),   // scrub clump, west of the road
            ZoneTreePlacement(imageName: "CityTree24", position: CGPoint(x: 1811, y:  460), scale: romeTreeScale),   // big olive south of the bridge
            ZoneTreePlacement(imageName: "CityTree25", position: CGPoint(x: 2575, y:  593), scale: romeTreeScale),   // riverbank olive, far south
            ZoneTreePlacement(imageName: "CityTree26", position: CGPoint(x: 2547, y:  708), scale: romeTreeScale),   // riverbank olive, upstream
            ZoneTreePlacement(imageName: "CityTree27", position: CGPoint(x: 2288, y: 1144), scale: romeTreeScale),   // small tree by the aqueduct wall
            ZoneTreePlacement(imageName: "CityTree28", position: CGPoint(x: 2199, y: 1255), scale: romeTreeScale),   // olive above the aqueduct
            ZoneTreePlacement(imageName: "CityTree29", position: CGPoint(x: 2051, y: 1385), scale: romeTreeScale),   // cypress on the ridge
            ZoneTreePlacement(imageName: "CityTree30", position: CGPoint(x:  704, y: 1459), scale: romeTreeScale),   // cypress, west hills
        ],

        // All six numerals still sit on this one map, because all 17 buildings
        // still do. They narrow to one per zone in the plan's step 5.
        labels: [
            ZoneLabel(numeral: "I",   name: "Ancient Rome",     position: CGPoint(x: 1400, y: 1100), nodeName: "zone_ancientRome"),
            ZoneLabel(numeral: "II",  name: "Florence",         position: CGPoint(x: 2270, y:  500), nodeName: "zone_florence"),
            ZoneLabel(numeral: "III", name: "Venice",           position: CGPoint(x: 1750, y:  200), nodeName: "zone_venice"),
            ZoneLabel(numeral: "IV",  name: "Padua",            position: CGPoint(x: 1100, y: 1400), nodeName: "zone_padua"),
            ZoneLabel(numeral: "V",   name: "Milan",            position: CGPoint(x:  536, y:  580), nodeName: "zone_milan"),
            ZoneLabel(numeral: "VI",  name: "Renaissance Rome", position: CGPoint(x: 3200, y:  150), nodeName: "zone_renaissanceRome"),
        ],

        // y was `mapSize.height - 100` when these were hardcoded; 2500 - 100 = 2400.
        banners: [
            ZoneBanner(text: "ANCIENT ROME",      position: CGPoint(x:  500, y: 2400), nodeName: "label_ancientRome"),
            ZoneBanner(text: "RENAISSANCE ITALY", position: CGPoint(x: 2400, y: 2400), nodeName: "label_renaissanceItaly"),
        ]
    )
}
