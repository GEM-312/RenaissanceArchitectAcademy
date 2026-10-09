import CoreGraphics

/// Everything that makes one outdoor Workshop map *that* map, separated from the
/// scene that draws it.
///
/// `WorkshopScene` used to hold all of this as hardcoded `private let`s, so it could
/// only ever render one map. The outdoor Workshop is being split into three areas —
/// Bottega, Countryside, Hills (see `docs/plans/workshop-areas-plan.md`) — and each
/// will be the same `WorkshopScene` class constructed with a different definition,
/// the way `CityScene` takes a `ZoneDefinition`.
///
/// Pure data, no SpriteKit import.
struct WorkshopAreaDefinition {
    let id: String
    let displayName: String

    /// The scene's coordinate space — 3500×2500 like every other scene.
    let mapSize: CGSize

    /// Asset-catalog names handed to `TerrainBlurHelper.setup(in:sharp:blurred:mapSize:)`.
    let sharpTerrainImageName: String
    let blurredTerrainImageName: String

    /// Stations on this map and where their tap targets sit. The station art is
    /// painted into the terrain (`ResourceNode.hideSprites`), so these must match it.
    let stations: [ResourceStationType: CGPoint]

    let waypoints: [CGPoint]
    /// Bidirectional edges: each pair [a, b] means a↔b, indexing into `waypoints`.
    let waypointEdges: [[Int]]
    /// Which waypoints each station connects to. The first entry is the station's
    /// own access waypoint; the rest are nearby hubs Dijkstra may route through.
    let stationWaypoints: [ResourceStationType: [Int]]

    /// The waypoint the apprentice starts on (and returns to when sent "home").
    /// An index rather than a point so dragging that waypoint in editor mode moves
    /// the spawn with it, as it always has.
    let playerSpawnWaypoint: Int

    /// Swaying trees cut out of this area's own terrain art.
    let trees: [ZoneTreePlacement]

    /// Ambient overlays this map has, and where each sits. An overlay that is not
    /// listed is not created — a new area only lists the ones its art has room for.
    let ambient: [WorkshopAmbientKind: CGPoint]
}

/// The always-on overlays layered over a Workshop terrain. Each one is drawn on
/// top of a specific painted feature (a crater, a chimney, a riverbank), so its
/// position belongs to the area, not to the scene.
enum WorkshopAmbientKind: Hashable {
    case volcanoSmoke
    case craftingChimneySmoke
    case smallSmokeAccent1
    case smallSmokeAccent2
    case volcanoLava
    case volcanoGlow
    case quarryCrane
    case riverFlow
    case chicken
    case fisherman
    case woodcutter
}
