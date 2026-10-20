import CoreGraphics

/// The `ZoneDefinition` for every zone in the game.
///
/// `ancientRome` below is a lift of the values that used to be hardcoded inside
/// `CityScene.swift` — same 40 waypoints, same 56 edges, same 17 buildings, same
/// 9 trees, same spawn. Step 1 of the zone plan was a pure data move.
///
/// Two deliberate changes on top of that lift, both 2026-09-20:
///  - the Botanical Garden's `era` went "florence" → "padua" (its own lesson and
///    card text always said Padua; only the code said Florence), and
///  - the six zone numerals were renumbered to the narrative order below.
/// Everything else differing from what `CityScene` drew before is a bug.
///
/// Zone order follows the storyteller's 5-act arc in docs/voice-cast-plan.md:
///   I Ancient Rome (8) · II Padua (2) · III Venice (2) · IV Renaissance Rome (2)
///   · V Milan (2) · VI Florence (1 — the Duomo finale, Brunelleschi + Medici)
enum ZoneRegistry {

    /// Every zone with a terrain, in story order. The DEBUG zone button cycles through these.
    static let all: [ZoneDefinition] = [ancientRome, padua, venice, renaissanceRome, milan, florence]

    static func zone(id: String) -> ZoneDefinition {
        all.first { $0.id == id } ?? ancientRome
    }

    /// Ancient Rome's terrain PNG is 4500px wide drawn into a 3500pt scene.
    /// Cut-outs lifted from it shrink by this to cover their own footprint.
    private static let romeTerrainPixelWidth: CGFloat = 4500

    static let ancientRome = ZoneDefinition(
        id: "ancientRome",
        displayName: "Ancient Rome",

        // Matches the standard used by every other scene in the project —
        // 3500×2500 coordinate space. Was 4048×2144 before Apr 23 2026; that
        // aspect (1.888:1) stretched the 1.4:1 terrain horizontally.
        mapSize: CGSize(width: 3500, height: 2500),
        terrainPixelWidth: romeTerrainPixelWidth,

        // Oct 19 2026 terrain (no-hatching prompt). The building positions below were
        // dragged on the Oct 13 terrain, and waypoints and spawn are Sep 2026 — all need
        // editor drags on this one. The Roman Roads and Harbor patches were baked from
        // the Oct 13 terrain and must be re-baked.
        sharpTerrainImageName: "Terrain",

        buildings: [
            // ========================================
            // ANCIENT ROME
            // ========================================
            // Oct 13 2026 positions from Marina's editor-mode drags on the new terrain
            ZoneBuildingPlacement(buildingId: "aqueduct", name: "Aqueduct", position: CGPoint(x: 1079, y: 1938), era: "rome", rotation: 0),
            ZoneBuildingPlacement(buildingId: "colosseum", name: "Colosseum", position: CGPoint(x: 2869, y: 1014), era: "rome", rotation: 0),
            ZoneBuildingPlacement(buildingId: "romanBaths", name: "Roman Baths", position: CGPoint(x: 382, y: 1860), era: "rome", rotation: 1),
            ZoneBuildingPlacement(buildingId: "pantheon", name: "Pantheon", position: CGPoint(x: 2232, y: 2047), era: "rome", rotation: 0),
            // Painted into the terrain's sketched road below the round field (Oct 14 2026).
            // The sprite is a patch of the map itself, so this position must stay
            // pixel-exact — see `spriteSizeMultiplier` in BuildingNode.
            ZoneBuildingPlacement(buildingId: "romanRoads", name: "Roman Roads", position: CGPoint(x: 3033, y: 467), era: "rome", rotation: 0),
            // Painted into the west bank of the river (Oct 14 2026), quay facing the open
            // water. Pixel-exact like the Roman Roads patch above.
            ZoneBuildingPlacement(buildingId: "harbor", name: "Harbor", position: CGPoint(x: 700, y: 501), era: "rome", rotation: 0),
            ZoneBuildingPlacement(buildingId: "siegeWorkshop", name: "Siege Workshop", position: CGPoint(x: 2036, y: 1239), era: "rome", rotation: 0),
            ZoneBuildingPlacement(buildingId: "insula", name: "Insula", position: CGPoint(x: 3264, y: 609), era: "rome", rotation: 0),

            // ========================================
            // RENAISSANCE ITALY
            // ========================================
            // Still listed here because this is a byte-for-byte lift of today's
            // single-map scene. They move to their own zones in the plan's step 5.

            // Florence — the Duomo alone, and it is the finale (Act V, Brunelleschi
            // + Cosimo de Medici). See docs/voice-cast-plan.md.
            ZoneBuildingPlacement(buildingId: "duomo", name: "Il Duomo", position: CGPoint(x: 1945, y: 1143), era: "florence", rotation: 0),

            // Venice
            ZoneBuildingPlacement(buildingId: "glassworks", name: "Glassworks", position: CGPoint(x: 1657, y: 548), era: "venice", rotation: 0),
            ZoneBuildingPlacement(buildingId: "arsenal", name: "Arsenal", position: CGPoint(x: 2906, y: 709), era: "venice", rotation: 0),

            // Padua — both University of Padua institutions. The Botanical Garden
            // moved here 2026-09-20: every line of its lesson, card and notebook text
            // already said Padua (Orto Botanico, 1545); only the code said Florence.
            // `era` is only ever compared against "rome" (BuildingNode.swift:446),
            // so this does not change how it is drawn.
            ZoneBuildingPlacement(buildingId: "anatomyTheater", name: "Anatomy Theater", position: CGPoint(x: 2393, y: 1934), era: "padua", rotation: 0),
            ZoneBuildingPlacement(buildingId: "botanicalGarden", name: "Botanical Garden", position: CGPoint(x: 2497, y: 151), era: "padua", rotation: 0),

            // Milan
            ZoneBuildingPlacement(buildingId: "leonardoWorkshop", name: "Leonardo's Workshop", position: CGPoint(x: 536, y: 471), era: "milan", rotation: 0),
            ZoneBuildingPlacement(buildingId: "flyingMachine", name: "Flying Machine", position: CGPoint(x: 922, y: 1321), era: "milan", rotation: 0),

            // Renaissance Rome
            ZoneBuildingPlacement(buildingId: "vaticanObservatory", name: "Vatican Observatory", position: CGPoint(x: 1028, y: 254), era: "renaissanceRome", rotation: 0),
            ZoneBuildingPlacement(buildingId: "printingPress", name: "Printing Press", position: CGPoint(x: 3121, y: 262), era: "renaissanceRome", rotation: 0)
        ],

        // The Duomo is Florence's; this terrain is Ancient Rome only. Hidden Oct 14 2026
        // (Marina): the six buildings that now sit on their own zone maps — Padua, Venice,
        // Renaissance Rome. Milan's two joined them Oct 19 2026 when Milan got a terrain.
        hiddenBuildingIds: [
            "duomo",
            "anatomyTheater", "botanicalGarden",     // Padua
            "glassworks", "arsenal",                 // Venice
            "vaticanObservatory", "printingPress",   // Renaissance Rome
            "leonardoWorkshop", "flyingMachine",     // Milan
        ],

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

        // None yet — the Sep 2026 cut-outs were deleted with that terrain. Cut new
        // ones from the Oct 13 terrain.
        trees: [],

        // Padua (II), Venice (III) and Renaissance Rome (IV) were removed Oct 14 2026,
        // Milan (V) and Florence (VI) Oct 19 2026 — each now has its own map with its
        // own numeral.
        labels: [
            ZoneLabel(numeral: "I",   name: "Ancient Rome",     position: CGPoint(x: 1400, y: 1100), nodeName: "zone_ancientRome"),
        ],

        // y was `mapSize.height - 100` when these were hardcoded; 2500 - 100 = 2400.
        banners: [
            ZoneBanner(text: "ANCIENT ROME",      position: CGPoint(x:  500, y: 2400), nodeName: "label_ancientRome"),
            ZoneBanner(text: "RENAISSANCE ITALY", position: CGPoint(x: 2400, y: 2400), nodeName: "label_renaissanceItaly"),
        ]
    )

    // MARK: - II Padua

    /// Padua's terrain is 4500×3214 like Rome's.
    private static let paduaTerrainPixelWidth: CGFloat = 4500

    /// Reached only from the DEBUG zone button in CityMapView until the travel map exists.
    /// Oct 19 2026 terrain. Building positions were baked from Marina's editor drag on the
    /// Oct 13 terrain (Oct 14); they and the waypoint and spawn placeholders need redoing
    /// on this one — drag them in editor mode (E) and bake the dump in here.
    static let padua = ZoneDefinition(
        id: "padua",
        displayName: "Padua",

        mapSize: CGSize(width: 3500, height: 2500),
        terrainPixelWidth: paduaTerrainPixelWidth,

        sharpTerrainImageName: "PaduaTerrain",

        // Both University of Padua institutions, drawn as one campus
        buildings: [
            ZoneBuildingPlacement(buildingId: "botanicalGarden", name: "Botanical Garden", position: CGPoint(x: 1379, y:  696), era: "padua", rotation: 0),   // the round walled lawn
            ZoneBuildingPlacement(buildingId: "anatomyTheater", name: "Anatomy Theater", position: CGPoint(x: 1400, y: 1523), era: "padua", rotation: 0),     // the square courtyard by the canal
        ],
        hiddenBuildingIds: [],

        // Along the painted gravel paths
        waypoints: [
            /* 0 */ CGPoint(x:  980, y:  854),   // west side of the round garden
            /* 1 */ CGPoint(x: 1050, y: 1100),   // path north of the garden wall
            /* 2 */ CGPoint(x: 1155, y: 1344),   // below the square courtyard, west
            /* 3 */ CGPoint(x: 1855, y:  959),   // east gate of the round garden
            /* 4 */ CGPoint(x: 2100, y: 1029),   // curved path, lower
            /* 5 */ CGPoint(x: 2380, y: 1344),   // curved path, upper
            /* 6 */ CGPoint(x: 1680, y: 1310),   // by the canal bridge
        ],
        waypointEdges: [
            [0, 1], [1, 2], [2, 6], [6, 3], [3, 0], [3, 4], [4, 5],
        ],
        buildingWaypoints: [
            "botanicalGarden": [0, 3],
            "anatomyTheater":  [2, 6],
        ],

        playerSpawn: CGPoint(x: 2380, y: 1344),
        cameraMaxZoomOutScale: 3.5,

        // None yet — the Oct 7 cut-outs were deleted with that terrain. Cut new ones
        // from the Oct 13 terrain.
        trees: [],

        labels: [
            ZoneLabel(numeral: "II", name: "Padua", position: CGPoint(x: 1750, y: 2350), nodeName: "zone_padua"),
        ],
        banners: []
    )

    // MARK: - III Venice

    /// Reached only from the DEBUG zone button. Oct 13 2026 terrain; positions are
    /// first-pass placeholders read off the painting — drag them in editor mode (E).
    static let venice = ZoneDefinition(
        id: "venice",
        displayName: "Venice",

        mapSize: CGSize(width: 3500, height: 2500),
        terrainPixelWidth: 4500,

        sharpTerrainImageName: "VeniceTerrain",

        buildings: [
            ZoneBuildingPlacement(buildingId: "glassworks", name: "Glassworks", position: CGPoint(x: 2030, y: 1152), era: "venice", rotation: 0),   // round plot, middle island
            ZoneBuildingPlacement(buildingId: "arsenal", name: "Arsenal", position: CGPoint(x: 2678, y:  686), era: "venice", rotation: 0),         // round plot by the open lagoon
        ],
        hiddenBuildingIds: [],

        // Along the boardwalks and bridges
        waypoints: [
            /* 0 */ CGPoint(x: 1120, y:  784),   // south end of the boardwalk
            /* 1 */ CGPoint(x: 1313, y: 1012),   // boardwalk bend
            /* 2 */ CGPoint(x: 1558, y: 1064),   // small arched bridge
            /* 3 */ CGPoint(x: 1820, y: 1117),   // west edge of the middle island
            /* 4 */ CGPoint(x: 2205, y:  994),   // south-east of the middle island
            /* 5 */ CGPoint(x: 2310, y:  872),   // bridge to the round island
            /* 6 */ CGPoint(x: 2485, y:  767),   // west edge of the round island
        ],
        waypointEdges: [
            [0, 1], [1, 2], [2, 3], [3, 4], [4, 5], [5, 6],
        ],
        buildingWaypoints: [
            "glassworks": [3, 4],
            "arsenal":    [6, 5],
        ],

        playerSpawn: CGPoint(x: 1150, y: 800),
        cameraMaxZoomOutScale: 3.5,

        trees: [],

        labels: [
            ZoneLabel(numeral: "III", name: "Venice", position: CGPoint(x: 1750, y: 2350), nodeName: "zone_venice"),
        ],
        banners: []
    )

    // MARK: - IV Renaissance Rome

    /// Reached only from the DEBUG zone button. Oct 13 2026 terrain; positions are
    /// first-pass placeholders read off the painting — drag them in editor mode (E).
    static let renaissanceRome = ZoneDefinition(
        id: "renaissanceRome",
        displayName: "Renaissance Rome",

        mapSize: CGSize(width: 3500, height: 2500),
        terrainPixelWidth: 4500,

        sharpTerrainImageName: "RenaissanceRomeTerrain",

        buildings: [
            ZoneBuildingPlacement(buildingId: "vaticanObservatory", name: "Vatican Observatory", position: CGPoint(x: 1505, y: 1099), era: "renaissanceRome", rotation: 0),   // the large central round plot
            ZoneBuildingPlacement(buildingId: "printingPress", name: "Printing Press", position: CGPoint(x: 1803, y:  637), era: "renaissanceRome", rotation: 0),           // round plot to the south
        ],
        hiddenBuildingIds: [],

        // Along the painted footpaths
        waypoints: [
            /* 0 */ CGPoint(x:  700, y:  960),   // west footpath
            /* 1 */ CGPoint(x: 1208, y: 1060),   // junction west of the big plot
            /* 2 */ CGPoint(x: 1470, y:  907),   // below the big plot
            /* 3 */ CGPoint(x: 1750, y:  750),   // path down to the south plots
            /* 4 */ CGPoint(x: 1960, y:  539),   // east of the south plot
            /* 5 */ CGPoint(x: 1330, y: 1625),   // path north toward the olive grove
        ],
        waypointEdges: [
            [0, 1], [1, 2], [2, 3], [3, 4], [1, 5],
        ],
        buildingWaypoints: [
            "vaticanObservatory": [2, 1],
            "printingPress":      [3, 4],
        ],

        playerSpawn: CGPoint(x: 750, y: 950),
        cameraMaxZoomOutScale: 3.5,

        trees: [],

        labels: [
            ZoneLabel(numeral: "IV", name: "Renaissance Rome", position: CGPoint(x: 1750, y: 2350), nodeName: "zone_renaissanceRome"),
        ],
        banners: []
    )

    // MARK: - V Milan

    /// Reached only from the DEBUG zone button. Oct 19 2026 terrain; positions are
    /// first-pass placeholders read off the painting — drag them in editor mode (E).
    static let milan = ZoneDefinition(
        id: "milan",
        displayName: "Milan",

        mapSize: CGSize(width: 3500, height: 2500),
        terrainPixelWidth: 4500,

        sharpTerrainImageName: "MilanTerrain",

        buildings: [
            ZoneBuildingPlacement(buildingId: "leonardoWorkshop", name: "Leonardo's Workshop", position: CGPoint(x:  775, y:  725), era: "milan", rotation: 0),   // round field west of the canal
            ZoneBuildingPlacement(buildingId: "flyingMachine", name: "Flying Machine", position: CGPoint(x: 2450, y:  937), era: "milan", rotation: 0),             // round field east of the canal
        ],
        hiddenBuildingIds: [],

        // Along the towpaths and over the canal lock
        waypoints: [
            /* 0 */ CGPoint(x:  430, y:  900),   // path north-west of the west field
            /* 1 */ CGPoint(x: 1150, y: 1000),   // path north-east of the west field
            /* 2 */ CGPoint(x: 1600, y: 1112),   // canal lock
            /* 3 */ CGPoint(x: 1900, y: 1050),   // path east of the canal
            /* 4 */ CGPoint(x: 2037, y:  900),   // west edge of the east field
        ],
        waypointEdges: [
            [0, 1], [1, 2], [2, 3], [3, 4],
        ],
        buildingWaypoints: [
            "leonardoWorkshop": [1, 0],
            "flyingMachine":    [4, 3],
        ],

        playerSpawn: CGPoint(x: 1900, y: 1050),
        cameraMaxZoomOutScale: 3.5,

        trees: [],

        labels: [
            ZoneLabel(numeral: "V", name: "Milan", position: CGPoint(x: 1750, y: 2350), nodeName: "zone_milan"),
        ],
        banners: []
    )

    // MARK: - VI Florence

    /// Reached only from the DEBUG zone button. Oct 19 2026 terrain; positions are
    /// first-pass placeholders read off the painting — drag them in editor mode (E).
    static let florence = ZoneDefinition(
        id: "florence",
        displayName: "Florence",

        mapSize: CGSize(width: 3500, height: 2500),
        terrainPixelWidth: 4500,

        sharpTerrainImageName: "FlorenceTerrain",

        // The finale — the Duomo alone, on the octagonal lawn in the central square
        buildings: [
            ZoneBuildingPlacement(buildingId: "duomo", name: "Il Duomo", position: CGPoint(x: 1762, y: 1300), era: "florence", rotation: 0),
        ],
        hiddenBuildingIds: [],

        // Around the square and down to the river quay
        waypoints: [
            /* 0 */ CGPoint(x: 1400, y: 1050),   // south-west corner of the square
            /* 1 */ CGPoint(x: 2150, y: 1100),   // south-east corner of the square
            /* 2 */ CGPoint(x: 1762, y: 1050),   // south of the lawn
            /* 3 */ CGPoint(x: 2050, y: 1650),   // north-east corner of the square
            /* 4 */ CGPoint(x: 1300, y: 1550),   // north-west corner of the square
            /* 5 */ CGPoint(x: 2550, y:  550),   // foot of the east bridge
            /* 6 */ CGPoint(x: 1500, y:  550),   // river quay
        ],
        waypointEdges: [
            [2, 0], [2, 1], [0, 4], [1, 3], [4, 3], [1, 5], [0, 6], [6, 5],
        ],
        buildingWaypoints: [
            "duomo": [2, 0],
        ],

        playerSpawn: CGPoint(x: 2550, y: 550),
        cameraMaxZoomOutScale: 3.5,

        trees: [],

        labels: [
            ZoneLabel(numeral: "VI", name: "Florence", position: CGPoint(x: 1750, y: 2350), nodeName: "zone_florence"),
        ],
        banners: []
    )
}
