import CoreGraphics

/// Everything that makes one city map *that* map, separated from the scene that draws it.
///
/// `CityScene` used to hold all of this as hardcoded `private let`s, which meant one
/// scene could only ever render one map. Under the zone system (see
/// `docs/plans/zone-system-plan.md`) each of the 6 zones is the same `CityScene`
/// class constructed with a different `ZoneDefinition` — no base class, no per-zone
/// subclasses.
///
/// Nothing here imports SpriteKit: this is pure data, so it can be read by the travel
/// map, the view model or a test without pulling in a scene.
struct ZoneDefinition {
    /// Matches the `RenaissanceCity`/era naming used elsewhere: "ancientRome",
    /// "florence", "venice", "padua", "milan", "renaissanceRome".
    let id: String
    let displayName: String

    /// The scene's coordinate space. Every other scene in the project uses
    /// 3500×2500; Padua may want a smaller canvas (see the plan's §5).
    let mapSize: CGSize

    /// Terrain pixel width, used to scale cut-outs lifted from that terrain back
    /// to the footprint they occupied in the art. Rome's terrain is 4500px wide
    /// drawn into a 3500pt scene, so its cut-outs shrink by 3500/4500.
    let terrainPixelWidth: CGFloat

    /// Asset-catalog names handed to `TerrainBlurHelper.setup(in:sharp:blurred:mapSize:)`.
    let sharpTerrainImageName: String
    let blurredTerrainImageName: String

    let buildings: [ZoneBuildingPlacement]

    /// Buildings that get no node on the map at all — no sprite, no blueprint
    /// diamond, no tap target. Kept per-zone so a building can be listed but
    /// suppressed while its plot is still being painted.
    let hiddenBuildingIds: Set<String>

    let waypoints: [CGPoint]
    /// Bidirectional edges: each pair [a, b] means a↔b, indexing into `waypoints`.
    let waypointEdges: [[Int]]
    /// Which waypoints each building connects to (nearest road junctions).
    let buildingWaypoints: [String: [Int]]

    let playerSpawn: CGPoint
    /// Fallback zoom-out limit before `computeFitScale()` measures the real view.
    let cameraMaxZoomOutScale: CGFloat

    let trees: [ZoneTreePlacement]
    let labels: [ZoneLabel]
    let banners: [ZoneBanner]
}

struct ZoneBuildingPlacement {
    /// Matches `BuildingNode.buildingId` — e.g. "aqueduct".
    let buildingId: String
    let name: String
    let position: CGPoint
    let era: String
    /// Degrees; `CityScene` converts to radians.
    let rotation: CGFloat
}

/// A swaying tree cut out of this zone's own terrain art.
///
/// These are per-zone and not interchangeable: each PNG was lifted out of one
/// terrain image and only covers the hole it came from, so a tree from Rome has
/// no meaningful position on Florence's map.
struct ZoneTreePlacement {
    /// Imageset name, e.g. "CityTree22".
    let imageName: String
    /// Trunk base — the sprite's anchor is (0.5, 0).
    let position: CGPoint
    /// `mapSize.width / terrainPixelWidth`. Without it the sprite renders at the
    /// terrain's pixel size and stops covering its own footprint.
    let scale: CGFloat
}

/// The Roman-numeral + name caption drawn over a region of the map.
struct ZoneLabel {
    let numeral: String
    let name: String
    let position: CGPoint
    /// Node name, so editor mode can find and drag it.
    let nodeName: String
}

/// A large era caption across the top of the map (e.g. "ANCIENT ROME").
struct ZoneBanner {
    let text: String
    let position: CGPoint
    let nodeName: String
}
