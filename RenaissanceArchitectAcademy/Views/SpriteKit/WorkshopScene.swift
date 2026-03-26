import SpriteKit
import SwiftUI

/// SpriteKit scene for Leonardo's Workshop mini-game
/// Player walks between resource stations to collect materials, then crafts at workbench/furnace
class WorkshopScene: SKScene, ScrollZoomable {

    // MARK: - Properties

    private var cameraNode: SKCameraNode!
    private var playerNode: PlayerNode!
    private var resourceNodes: [ResourceStationType: ResourceNode] = [:]

    /// Player gender — set from SwiftUI before scene appears
    var apprenticeIsBoy: Bool = true

    /// Tracks last known theme to detect changes in update()
    private var lastKnownDarkMode: Bool?

    // Camera control
    private var lastPanLocation: CGPoint?

    // Map size — matches city's 3500×2500 so terrain renders at same density
    private let mapSize = CGSize(width: 3500, height: 2500)

    /// Reusable terrain blur system
    let terrainBlur = TerrainBlurHelper()

    /// Whether the player is currently walking
    private(set) var isPlayerWalking = false

    #if DEBUG
    private lazy var editorMode = SceneEditorMode(scene: self)
    #endif

    // Station positions — scaled to 3500x2500 coordinate space
    // Workbench, furnace, and pigment table are inside the Crafting Room (interior scene)
    private let stationPositions: [ResourceStationType: CGPoint] = [
        .quarry:       CGPoint(x: 499,  y: 1441),
        .river:        CGPoint(x: 1166, y: 1257),
        .volcano:      CGPoint(x: 2879, y: 450),
        .clayPit:      CGPoint(x: 2796, y: 2046),
        .mine:         CGPoint(x: 1032, y: 1758),
        .forest:       CGPoint(x: 293,  y: 679),
        .market:       CGPoint(x: 1397, y: 594),
        .craftingRoom: CGPoint(x: 1636, y: 1144),
        .farm:         CGPoint(x: 2450, y: 1450),
        .goldsmithWorkshop: CGPoint(x: 2100, y: 1550),
    ]

    // MARK: - Waypoint Graph (road network for pathfinding)

    /// 64 road junctions — scaled to 3500x2500 coordinate space
    private var waypoints: [CGPoint] = [
        // --- Row D: center band ---
        /* 0  */ CGPoint(x: 1750, y: 1225),  // central hub
        /* 1  */ CGPoint(x: 1213, y: 1175),  // west hub
        /* 2  */ CGPoint(x: 2287, y: 1150),  // east hub
        // --- Row B: upper band ---
        /* 3  */ CGPoint(x: 583,  y: 1750),  // NW road
        /* 4  */ CGPoint(x: 1167, y: 1800),  // N road
        /* 5  */ CGPoint(x: 1750, y: 1850),  // N center
        /* 6  */ CGPoint(x: 2450, y: 1875),  // NE road
        // --- Row D continued ---
        /* 7  */ CGPoint(x: 583,  y: 1250),  // W road
        // --- Row E: south band ---
        /* 8  */ CGPoint(x: 817,  y: 800),   // SW road
        /* 9  */ CGPoint(x: 1400, y: 700),   // S road
        /* 10 */ CGPoint(x: 2100, y: 750),   // S center
        /* 11 */ CGPoint(x: 2683, y: 750),   // SE road
        // --- Row B/C: east side ---
        /* 12 */ CGPoint(x: 2917, y: 1700),  // E upper
        /* 13 */ CGPoint(x: 2800, y: 1250),  // E mid
        /* 14 */ CGPoint(x: 2987, y: 1000),  // E lower
        // --- Row A: top ---
        /* 15 */ CGPoint(x: 933,  y: 2075),  // N upper (quarry-river link)
        // --- Row C: mid band ---
        /* 16 */ CGPoint(x: 583,  y: 1500),  // W mid
        /* 17 */ CGPoint(x: 933,  y: 1475),  // W-center
        /* 18 */ CGPoint(x: 1470, y: 1550),  // center-N
        /* 19 */ CGPoint(x: 2053, y: 1575),  // center-NE
        /* 20 */ CGPoint(x: 2567, y: 1550),  // E mid-N
        // --- Row A: top corners ---
        /* 21 */ CGPoint(x: 350,  y: 1950),  // near quarry
        /* 22 */ CGPoint(x: 1517, y: 2050),  // top center
        /* 23 */ CGPoint(x: 2637, y: 1950),  // near clay pit
        // --- Row D: inner ring ---
        /* 24 */ CGPoint(x: 817,  y: 1200),  // W inner (near forest)
        /* 25 */ CGPoint(x: 1050, y: 900),   // SW inner
        /* 26 */ CGPoint(x: 1750, y: 875),   // S mid
        /* 27 */ CGPoint(x: 2450, y: 925),   // SE inner
        // --- Row F: bottom ---
        /* 28 */ CGPoint(x: 1167, y: 375),   // near market
        /* 29 */ CGPoint(x: 1750, y: 450),   // S center low
        /* 30 */ CGPoint(x: 2333, y: 550),   // S-E low
        /* 31 */ CGPoint(x: 3150, y: 1125),  // near mine

        // ====== Waypoints 32-63 ======

        // --- Row A extras: top edge ---
        /* 32 */ CGPoint(x: 700,  y: 2175),  // between quarry and wp15
        /* 33 */ CGPoint(x: 1750, y: 2175),  // top center
        /* 34 */ CGPoint(x: 2333, y: 2125),  // near volcano
        /* 35 */ CGPoint(x: 3033, y: 2075),  // near clay pit

        // --- Row B extras: upper ---
        /* 36 */ CGPoint(x: 933,  y: 1875),  // between wp3 and wp4
        /* 37 */ CGPoint(x: 1517, y: 1875),  // upper center
        /* 38 */ CGPoint(x: 2100, y: 1900),  // between wp5 and wp6
        /* 39 */ CGPoint(x: 2800, y: 1800),  // upper east

        // --- Row C extras: mid ---
        /* 40 */ CGPoint(x: 350,  y: 1375),  // far west
        /* 41 */ CGPoint(x: 1213, y: 1550),  // mid west-center
        /* 42 */ CGPoint(x: 1750, y: 1550),  // mid center
        /* 43 */ CGPoint(x: 2333, y: 1375),  // mid east
        /* 44 */ CGPoint(x: 3033, y: 1500),  // far east mid

        // --- Row D extras: lower-mid ---
        /* 45 */ CGPoint(x: 350,  y: 1050),  // far west lower
        /* 46 */ CGPoint(x: 1050, y: 1175),  // between wp24 and wp1
        /* 47 */ CGPoint(x: 1517, y: 1075),  // between wp1 and wp0
        /* 48 */ CGPoint(x: 1983, y: 1125),  // between wp0 and wp2
        /* 49 */ CGPoint(x: 2567, y: 1125),  // between wp2 and wp13

        // --- Row E extras: south ---
        /* 50 */ CGPoint(x: 583,  y: 700),   // far SW
        /* 51 */ CGPoint(x: 1050, y: 700),   // SW
        /* 52 */ CGPoint(x: 1633, y: 800),   // S center-west
        /* 53 */ CGPoint(x: 1983, y: 875),   // S center
        /* 54 */ CGPoint(x: 2333, y: 850),   // S east inner

        // --- Row F extras: bottom ---
        /* 55 */ CGPoint(x: 700,  y: 450),   // bottom west
        /* 56 */ CGPoint(x: 1400, y: 500),   // bottom center-west
        /* 57 */ CGPoint(x: 2100, y: 375),   // bottom center-east
        /* 58 */ CGPoint(x: 2567, y: 450),   // bottom east

        // --- Far edges + corners ---
        /* 59 */ CGPoint(x: 233,  y: 1625),  // far west mid
        /* 60 */ CGPoint(x: 3150, y: 1750),  // far NE
        /* 61 */ CGPoint(x: 3267, y: 1375),  // far east
        /* 62 */ CGPoint(x: 2917, y: 625),   // near pigment table
        /* 63 */ CGPoint(x: 3150, y: 800),   // far SE

        // --- Home: avatar box (bottom-left corner) ---
        /* 64 */ CGPoint(x: 200,  y: 200),   // avatar box spawn
    ]

    /// Bidirectional edges: each pair [a, b] means a↔b (~100 edges)
    private let waypointEdges: [[Int]] = [
        // ── Row A: top chain ──
        [21, 32], [32, 15], [15, 22], [22, 33], [33, 34], [34, 35], [35, 23],

        // ── Row B: upper chain ──
        [3, 36], [36, 4], [36, 37], [4, 37], [37, 5], [37, 38], [5, 38],
        [38, 6], [38, 39], [6, 39], [39, 12],

        // ── A↔B vertical ──
        [21, 3], [32, 36], [15, 36], [22, 37], [33, 5], [33, 38],
        [34, 38], [35, 39], [23, 39], [23, 6],

        // ── Row C: mid chain ──
        [59, 40], [40, 16], [16, 17], [17, 41], [41, 18], [18, 42],
        [42, 19], [19, 43], [43, 20], [20, 44], [44, 60],

        // ── B↔C vertical ──
        [3, 16], [36, 17], [4, 41], [37, 42], [5, 42], [38, 19],
        [6, 20], [39, 44], [12, 60],

        // ── Row D: center chain ──
        [45, 7], [7, 24], [24, 46], [46, 1], [1, 47], [47, 0],
        [0, 48], [48, 2], [2, 49], [49, 13], [13, 31], [31, 61],

        // ── C↔D vertical ──
        [40, 45], [59, 40], [16, 7], [17, 24], [17, 46], [41, 46],
        [18, 47], [42, 0], [19, 48], [43, 2], [20, 49], [44, 61],

        // ── Row E: south chain ──
        [50, 8], [8, 51], [51, 9], [9, 52], [52, 26], [26, 53],
        [53, 10], [10, 54], [54, 27], [27, 11], [11, 62], [62, 63],

        // ── D↔E vertical ──
        [45, 50], [7, 8], [24, 25], [25, 51], [46, 51], [47, 52],
        [0, 26], [48, 53], [2, 27], [49, 27], [13, 14], [14, 63],

        // ── Row F: bottom chain ──
        [55, 28], [28, 56], [56, 29], [29, 57], [57, 30], [30, 58],
        [58, 62],

        // ── E↔F vertical ──
        [50, 55], [51, 28], [9, 56], [52, 56], [26, 29], [10, 57],
        [54, 30], [27, 58], [11, 62],

        // ── Diagonal cross-links (shortcuts) ──
        [0, 1], [0, 2], [1, 4], [25, 9], [25, 8],
        [12, 13], [31, 14], [60, 12],

        // ── Avatar box (home) connections ──
        [64, 55], [64, 50], [64, 28],
    ]

    /// Which waypoints each station connects to (nearest 3 road junctions)
    private let stationWaypoints: [ResourceStationType: [Int]] = [
        .quarry:       [21, 32, 15],
        .river:        [15, 22, 32],
        .volcano:      [33, 38, 34],
        .clayPit:      [23, 39, 35],
        .mine:         [61, 31, 14],
        .forest:       [45, 7, 24],
        .market:       [28, 55, 51],
        .craftingRoom: [0, 47, 48],
        .farm:         [20, 43, 6],
        .goldsmithWorkshop: [19, 42, 5],
    ]

    // MARK: - Camera Follow

    /// When true, camera smoothly tracks the player while walking
    private var isFollowingPlayer = false
    /// The station position the player is walking toward (for gradual zoom)
    private var walkTargetPosition: CGPoint?

    // MARK: - Callbacks to SwiftUI

    var onPlayerPositionChanged: ((CGPoint, Bool) -> Void)?
    var onStationReached: ((ResourceStationType) -> Void)?

    /// Callback when player starts walking (dismiss any open dialogs/overlays)
    var onPlayerStartedWalking: (() -> Void)?


    // MARK: - Scene Setup

    private var hasSetup = false

    override func didMove(to view: SKView) {
        guard !hasSetup else {
            // Scene reused — reset terrain to sharp, camera to full view
            if playerNode != nil {
                cameraNode.position = playerNode.position
            }
            terrainBlur.terrainSprite?.alpha = 1.0
            terrainBlur.blurredTerrainSprite?.alpha = 0
            fitCameraToMap()
            return
        }
        hasSetup = true

        backgroundColor = PlatformColor(RenaissanceColors.parchment)

        setupCamera()
        setupBackground()
        // Force terrain sharp on first load (before update() loop starts)
        terrainBlur.terrainSprite?.alpha = 1.0
        terrainBlur.blurredTerrainSprite?.alpha = 0
        setupGridLines()
        setupTitle()
        setupWalkingPaths()
        setupStations()
        setupPlayer()

        // Dark tint node — toggled by theme
        let tint = SKSpriteNode(color: .black, size: mapSize)
        tint.name = "darkTint"
        tint.position = CGPoint(x: mapSize.width / 2, y: mapSize.height / 2)
        tint.zPosition = 12
        tint.alpha = 0.3
        addChild(tint)

        // Dark mode glow (warm ochre)
        for (_, pos) in stationPositions {
            let glow = Self.makeRadialGlow(radius: 200, color: PlatformColor(red: 0.85, green: 0.66, blue: 0.37, alpha: 1.0))
            glow.name = "darkGlow"
            glow.position = pos
            glow.zPosition = 13
            glow.alpha = 0.5
            glow.blendMode = .add
            addChild(glow)
        }

        // Apply initial theme
        applyTheme()

        isUserInteractionEnabled = true

        #if DEBUG
        registerEditorNodes()
        #endif
    }

    // MARK: - Theme

    private func applyTheme() {
        let dark = GameSettings.shared.isDarkMode

        // Toggle tint + glow visibility
        enumerateChildNodes(withName: "darkTint") { node, _ in node.isHidden = !dark }
        enumerateChildNodes(withName: "darkGlow") { node, _ in node.isHidden = !dark }

        // Update station label colors
        for child in children {
            guard let resourceNode = child as? ResourceNode else { continue }
            resourceNode.updateLabelTheme(isDark: dark)
        }
    }

    // MARK: - Camera

    private func setupCamera() {
        cameraNode = SKCameraNode()
        cameraNode.position = CGPoint(x: mapSize.width / 2, y: mapSize.height / 2)
        addChild(cameraNode)
        camera = cameraNode
        fitCameraToMap()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        fitCameraToMap()
    }

    /// Set camera scale so the full map is visible
    private func fitCameraToMap() {
        guard let cameraNode = cameraNode else { return }
        // With .aspectFill, self.size = initial scene size (stays constant)
        // Camera scale determines visible area
        let s = self.size
        guard s.width > 0 && s.height > 0 else { return }
        let fitScale = max(mapSize.width / s.width, mapSize.height / s.height)
        cameraNode.setScale(fitScale)
    }

    // MARK: - Background

    private func setupBackground() {
        // Workshop terrain — sharp/blurred pair with smooth lerp crossfade
        terrainBlur.setup(in: self, sharp: "WorkshopTerrain", blurred: "BlurredWorkshopTerrain", mapSize: mapSize)
    }

    // MARK: - Grid Lines (notebook style)

    private func setupGridLines() {
        let gridNode = SKNode()
        gridNode.zPosition = -90

        let lineColor = PlatformColor(RenaissanceColors.sepiaInk.opacity(0.08))

        for x in stride(from: 0, through: mapSize.width, by: 100) {
            let path = CGMutablePath()
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: mapSize.height))
            let line = SKShapeNode(path: path)
            line.strokeColor = lineColor
            line.lineWidth = 0.5
            gridNode.addChild(line)
        }

        for y in stride(from: 0, through: mapSize.height, by: 100) {
            let path = CGMutablePath()
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: mapSize.width, y: y))
            let line = SKShapeNode(path: path)
            line.strokeColor = lineColor
            line.lineWidth = 0.5
            gridNode.addChild(line)
        }

        addChild(gridNode)
    }

    // MARK: - Title

    private func setupTitle() {
        let title = SKLabelNode(text: "LEONARDO'S WORKSHOP")
        title.fontName = "Cinzel-Regular"
        title.fontSize = 28
        title.fontColor = PlatformColor(RenaissanceColors.sepiaInk.opacity(0.4))
        title.position = CGPoint(x: mapSize.width / 2, y: mapSize.height - 50)
        title.zPosition = -80
        addChild(title)
    }

    // MARK: - Walking Paths (dotted lines connecting stations to crafting area)

    private func setupWalkingPaths() {
        // Removed — dashed path lines cluttered the terrain
    }

    // MARK: - Stations

    private func setupStations() {
        for (stationType, pos) in stationPositions {
            let node = ResourceNode(stationType: stationType)
            node.position = pos
            node.zPosition = 10
            addChild(node)
            resourceNodes[stationType] = node
        }
    }

    // MARK: - Player

    private func setupPlayer() {
        playerNode = PlayerNode(isBoy: apprenticeIsBoy)
        playerNode.zPosition = 50
        addChild(playerNode)
        // Start at the avatar box waypoint (bottom-left of map)
        playerNode.position = waypoints[64]
        updatePlayerScreenPosition()
    }

    /// Move the player back to the avatar box waypoint (bottom-left of map)
    func positionPlayerAtAvatarBox() {
        playerNode.position = waypoints[64]
        updatePlayerScreenPosition()
    }

    /// Show the player sprite on the map — no repositioning needed, already visible
    func showPlayer() {
        // Player is already visible at the box. Nothing to do.
    }

    /// Hide the player sprite (called when avatar returns to the profile box)
    func hidePlayer() {
        // Move player back to box position
        positionPlayerAtAvatarBox()
    }

    // MARK: - Position Tracking

    private func updatePlayerScreenPosition() {
        guard let view = self.view else { return }
        let viewPoint = convertPoint(toView: playerNode.position)
        let viewSize = view.bounds.size
        let normalizedX = viewPoint.x / viewSize.width
        let normalizedY = viewPoint.y / viewSize.height
        onPlayerPositionChanged?(CGPoint(x: normalizedX, y: normalizedY), playerNode.isWalking)
    }

    // MARK: - Scene Lifecycle

    override func willMove(from view: SKView) {
        removeAllActions()
        removeAllChildren()
        terrainBlur.cleanup()
        playerNode = nil
        hasSetup = false
        // Break retain cycles from closures capturing SwiftUI views
        onPlayerPositionChanged = nil
        onStationReached = nil
        onPlayerStartedWalking = nil
    }

    override func update(_ currentTime: TimeInterval) {
        // Check for theme change
        let currentDark = GameSettings.shared.isDarkMode
        if lastKnownDarkMode != currentDark {
            lastKnownDarkMode = currentDark
            applyTheme()
        }

        updatePlayerScreenPosition()

        // Smoothly follow the player while walking to a station
        if isFollowingPlayer {
            let target = playerNode.position
            let current = cameraNode.position
            let lerpFactor: CGFloat = 0.08
            cameraNode.position = CGPoint(
                x: current.x + (target.x - current.x) * lerpFactor,
                y: current.y + (target.y - current.y) * lerpFactor
            )

            // Gradual zoom: ease from overview → close-up during approach
            if let dest = walkTargetPosition {
                let totalDist = hypot(dest.x - cameraNode.position.x, dest.y - cameraNode.position.y)
                let closeZoom: CGFloat = 0.45
                let farZoom: CGFloat = 0.65
                let zoomStartDist: CGFloat = 700

                if totalDist < zoomStartDist {
                    let progress = 1.0 - (totalDist / zoomStartDist)
                    let targetScale = farZoom - (farZoom - closeZoom) * progress
                    let currentScale = cameraNode.xScale
                    cameraNode.setScale(currentScale + (targetScale - currentScale) * 0.06)
                }
            }

            clampCamera()
        }

        // Terrain blur — zoomed in = blurred, zoomed out = sharp
        if let cam = cameraNode {
            terrainBlur.updateBlur(cameraScale: cam.xScale)
        }

    }

    // MARK: - Input Handling

    #if os(iOS)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        #if DEBUG
        if editorMode.handleTapDown(at: location) { return }
        #endif

        handleTapAt(location)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        #if DEBUG
        if editorMode.handleDrag(to: location) { return }
        #endif

        if let last = lastPanLocation {
            handleDragTo(location, from: last)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        #if DEBUG
        if editorMode.handleRelease() { /* fall through */ }
        #endif
        lastPanLocation = nil
        hasFiredDragCallback = false
    }
    #else
    override func mouseDown(with event: NSEvent) {
        let location = event.location(in: self)

        #if DEBUG
        if editorMode.handleTapDown(at: location) { return }
        #endif

        handleTapAt(location)
    }

    override func mouseDragged(with event: NSEvent) {
        let location = event.location(in: self)

        #if DEBUG
        if editorMode.handleDrag(to: location) { return }
        #endif

        guard let last = lastPanLocation else { return }
        handleDragTo(location, from: last)
    }

    override func mouseUp(with event: NSEvent) {
        #if DEBUG
        if editorMode.handleRelease() { /* fall through */ }
        #endif
        lastPanLocation = nil
        hasFiredDragCallback = false
    }

    // Scroll wheel/trackpad on macOS — scroll = zoom, Option+scroll = pan
    override func scrollWheel(with event: NSEvent) {
        dismissOverlaysOnInteraction()
        if event.modifierFlags.contains(.option) {
            // Option + scroll = pan the map
            let scale = cameraNode.xScale
            cameraNode.position.x -= event.deltaX * scale * 2
            cameraNode.position.y += event.deltaY * scale * 2
        } else {
            // Regular scroll = zoom (works with Magic Mouse)
            let zoomFactor: CGFloat = 1.0 - (event.deltaY * 0.05)
            let newScale = cameraNode.xScale * zoomFactor
            let clampedScale = max(0.3, min(3.5, newScale))
            cameraNode.setScale(clampedScale)
        }
        clampCamera()
    }

    // Pinch-to-zoom on trackpad
    override func magnify(with event: NSEvent) {
        dismissOverlaysOnInteraction()
        let zoomFactor: CGFloat = 1.0 + event.magnification
        let newScale = cameraNode.xScale / zoomFactor
        let clampedScale = max(0.3, min(3.5, newScale))
        cameraNode.setScale(clampedScale)
        clampCamera()
    }

    override func keyDown(with event: NSEvent) {
        #if DEBUG
        if handleEditorKeyDown(event.keyCode) { return }
        if editorMode.handleKeyDown(event.keyCode) { return }
        #endif
    }
    #endif

    // MARK: - Shared Input Logic

    private func handleTapAt(_ location: CGPoint) {
        // Check if a station was tapped
        let tappedNodes = nodes(at: location)
        for node in tappedNodes {
            let resourceNode = (node as? ResourceNode)
                ?? (node.parent as? ResourceNode)
                ?? (node.parent?.parent as? ResourceNode)
            if let resourceNode {
                onPlayerStartedWalking?()
                walkPlayerToStation(resourceNode)
                return
            }
        }

        // Start pan
        lastPanLocation = location
    }

    // MARK: - Pathfinding (Dijkstra on waypoint graph)

    /// Build adjacency list from edge pairs
    private func buildAdjacency() -> [[Int]] {
        #if DEBUG
        let edges = waypointEdgesEdited ?? waypointEdges
        #else
        let edges = waypointEdges
        #endif
        var adj = [[Int]](repeating: [], count: waypoints.count)
        for edge in edges {
            adj[edge[0]].append(edge[1])
            adj[edge[1]].append(edge[0])
        }
        return adj
    }

    /// Find the 2 nearest waypoints to a given position
    private func nearestWaypoints(to point: CGPoint, count: Int = 2) -> [Int] {
        let indexed = waypoints.enumerated().map { (index: $0.offset, dist: hypot($0.element.x - point.x, $0.element.y - point.y)) }
        let sorted = indexed.sorted { $0.dist < $1.dist }
        return Array(sorted.prefix(count).map { $0.index })
    }

    /// Dijkstra shortest path on waypoint graph with virtual start/end nodes
    private func findPath(from start: CGPoint, to end: CGPoint, startWaypoints: [Int], endWaypoints: [Int]) -> [CGPoint] {
        let n = waypoints.count
        let startVirtual = n       // virtual node index for player position
        let endVirtual = n + 1     // virtual node index for target position
        let totalNodes = n + 2

        // Build adjacency with distances
        var adj = [[(node: Int, dist: CGFloat)]](repeating: [], count: totalNodes)

        // Real waypoint edges
        let baseAdj = buildAdjacency()
        for i in 0..<n {
            for j in baseAdj[i] {
                let d = hypot(waypoints[i].x - waypoints[j].x, waypoints[i].y - waypoints[j].y)
                adj[i].append((j, d))
            }
        }

        // Connect start virtual node to its nearest waypoints
        for wp in startWaypoints {
            let d = hypot(start.x - waypoints[wp].x, start.y - waypoints[wp].y)
            adj[startVirtual].append((wp, d))
            adj[wp].append((startVirtual, d))
        }

        // Connect end virtual node to its nearest waypoints
        for wp in endWaypoints {
            let d = hypot(end.x - waypoints[wp].x, end.y - waypoints[wp].y)
            adj[endVirtual].append((wp, d))
            adj[wp].append((endVirtual, d))
        }

        // Dijkstra
        var dist = [CGFloat](repeating: .infinity, count: totalNodes)
        var prev = [Int](repeating: -1, count: totalNodes)
        var visited = [Bool](repeating: false, count: totalNodes)
        dist[startVirtual] = 0

        for _ in 0..<totalNodes {
            // Find unvisited node with smallest distance
            var u = -1
            var bestDist: CGFloat = .infinity
            for v in 0..<totalNodes {
                if !visited[v] && dist[v] < bestDist {
                    bestDist = dist[v]
                    u = v
                }
            }
            guard u >= 0 else { break }
            visited[u] = true

            if u == endVirtual { break }  // found target

            for (v, w) in adj[u] {
                let newDist = dist[u] + w
                if newDist < dist[v] {
                    dist[v] = newDist
                    prev[v] = u
                }
            }
        }

        // Reconstruct path (skip virtual start node, include virtual end = target position)
        guard dist[endVirtual] < .infinity else { return [end] }

        var path: [Int] = []
        var cur = endVirtual
        while cur != -1 {
            path.append(cur)
            cur = prev[cur]
        }
        path.reverse()

        // Convert node indices to CGPoints (skip startVirtual)
        var result: [CGPoint] = []
        for nodeIdx in path {
            if nodeIdx == startVirtual { continue }
            if nodeIdx == endVirtual {
                result.append(end)
            } else {
                result.append(waypoints[nodeIdx])
            }
        }

        // Trim backtracking: once we get close to the target, skip waypoints that move away
        if result.count > 2 {
            let target = result.last!
            var trimmed: [CGPoint] = []
            var minDistSoFar: CGFloat = .infinity
            for (i, pt) in result.enumerated() {
                let distToTarget = hypot(pt.x - target.x, pt.y - target.y)
                if i == result.count - 1 {
                    // Always include the final target
                    trimmed.append(pt)
                } else if distToTarget <= minDistSoFar || trimmed.isEmpty {
                    trimmed.append(pt)
                    minDistSoFar = min(minDistSoFar, distToTarget)
                }
                // Skip waypoints that move farther from target after we got close
            }
            result = trimmed
        }

        return result
    }

    private func walkPlayerToStation(_ stationNode: ResourceNode) {
        guard playerNode != nil else { return }
        stationNode.animateTap()

        // Cancel any current walk
        playerNode.removeAction(forKey: "walkTo")

        // Dismiss any open overlays immediately
        onPlayerStartedWalking?()

        let stationPos = stationNode.position
        let targetPos = CGPoint(x: stationPos.x - 200, y: stationPos.y - 65)
        let playerPos = playerNode.position

        isPlayerWalking = true

        // Stage 1: Gentle zoom + follow player — gradual approach in update()
        startFollowingPlayer(toward: stationPos)
        startWalkingTerrainEffects()

        #if DEBUG
        syncWaypointsFromNodes()  // pick up any dragged waypoint positions
        #endif

        // If very close, walk directly (adjacent stations like Workbench ↔ Furnace)
        let directDistance = hypot(targetPos.x - playerPos.x, targetPos.y - playerPos.y)
        if directDistance < 350 {
            let facingRight = targetPos.x > playerPos.x
            playerNode.setFacingDirection(facingRight)

            playerNode.walkTo(destination: targetPos, duration: max(0.3, TimeInterval(directDistance / 467))) { [weak self] in
                self?.playerArrivedAtStation(stationNode)
            }
            return
        }

        // Get waypoints for start and end
        let startWPs = nearestWaypoints(to: playerPos)
        let endWPs = stationWaypoints[stationNode.stationType] ?? nearestWaypoints(to: targetPos)

        // Find path through waypoint graph
        let path = findPath(from: playerPos, to: targetPos, startWaypoints: startWPs, endWaypoints: endWPs)

        guard !path.isEmpty else {
            // Fallback: direct walk
            let facingRight = targetPos.x > playerPos.x
            playerNode.setFacingDirection(facingRight)
            playerNode.walkTo(destination: targetPos, duration: max(0.5, TimeInterval(directDistance / 467))) { [weak self] in
                self?.playerArrivedAtStation(stationNode)
            }
            return
        }

        // Initial facing direction (toward first waypoint)
        let firstTarget = path[0]
        let facingRight = firstTarget.x > playerPos.x
        playerNode.setFacingDirection(facingRight)

        // Walk along the path
        playerNode.walkPath(path, speed: 467) { [weak self] in
            self?.playerArrivedAtStation(stationNode)
        }
    }

    /// Called when player finishes walking to a station — Stage 2: zoom to station, then notify SwiftUI
    private func playerArrivedAtStation(_ stationNode: ResourceNode) {
        isPlayerWalking = false
        isFollowingPlayer = false
        walkTargetPosition = nil

        // Keep blur while zoomed in at station

        // Face toward the station (player is to the left, so face right)
        let faceRight = stationNode.position.x > playerNode.position.x
        playerNode.setFacingDirection(faceRight)

        // Zoom camera to station
        zoomCameraToStation(stationNode.position)

        // Play collecting animation (skip for crafting room entrance), then notify SwiftUI
        if stationNode.stationType.isCraftingStation {
            onStationReached?(stationNode.stationType)
        } else {
            playerNode.playCollectAnimation { [weak self] in
                self?.onStationReached?(stationNode.stationType)
            }
        }
    }

    // MARK: - Terrain Effects (walking overlay fade)

    private func startWalkingTerrainEffects() {
        // Blur handled by crossfade in update()
    }

    private func stopWalkingTerrainEffects() {
        // Sharp restore handled by crossfade in update()
    }

    // MARK: - Station Camera Zoom

    /// Stage 1: Start following player — gentle initial zoom, gradual approach in update()
    private func startFollowingPlayer(toward target: CGPoint) {
        guard let cameraNode = cameraNode else { return }
        isFollowingPlayer = true
        walkTargetPosition = target

        // Zoom to 0.65x (gentle start) — gradual zoom to 0.45 happens in update()
        let zoomAction = SKAction.scale(to: 0.65, duration: 0.5)
        zoomAction.timingMode = .easeInEaseOut
        cameraNode.run(zoomAction, withKey: "cameraZoom")
    }

    /// Stage 2: Settle camera on the station after player arrives
    private func zoomCameraToStation(_ stationPos: CGPoint) {
        guard let cameraNode = cameraNode else { return }

        let moveAction = SKAction.move(to: stationPos, duration: 0.5)
        moveAction.timingMode = .easeInEaseOut

        let zoomAction = SKAction.scale(to: 0.45, duration: 0.5)
        zoomAction.timingMode = .easeInEaseOut

        cameraNode.run(SKAction.group([moveAction, zoomAction]), withKey: "cameraZoom")
    }

    /// Nudge camera upward so the station appears in the top third of the screen.
    /// Called when a bottom-anchored overlay (e.g. quarry mini-game) needs room.
    func nudgeCameraUp(by screenFraction: CGFloat = 0.25) {
        guard let cameraNode = cameraNode else { return }
        // In SpriteKit, camera Y+ = up, so moving camera down shows content higher on screen
        let visibleHeight = self.size.height * cameraNode.xScale
        let offset = visibleHeight * screenFraction
        let newY = cameraNode.position.y - offset

        let moveAction = SKAction.moveTo(y: newY, duration: 0.4)
        moveAction.timingMode = .easeInEaseOut
        cameraNode.run(moveAction, withKey: "cameraNudge")
    }

    /// Zoom back out to show the full map (call when overlay dismisses)
    func zoomCameraOut() {
        guard let cameraNode = cameraNode else { return }
        isFollowingPlayer = false
        walkTargetPosition = nil

        let mapCenter = CGPoint(x: mapSize.width / 2, y: mapSize.height / 2)
        let fitScale = max(mapSize.width / self.size.width, mapSize.height / self.size.height)

        let moveAction = SKAction.move(to: mapCenter, duration: 0.6)
        moveAction.timingMode = .easeInEaseOut

        let zoomAction = SKAction.scale(to: fitScale, duration: 0.6)
        zoomAction.timingMode = .easeInEaseOut

        cameraNode.run(SKAction.group([moveAction, zoomAction]), withKey: "cameraZoom")
    }

    private var hasFiredDragCallback = false

    private func handleDragTo(_ location: CGPoint, from lastLocation: CGPoint) {
        // Dismiss overlays on first drag movement only
        if !hasFiredDragCallback {
            hasFiredDragCallback = true
            onPlayerStartedWalking?()
        }

        // Pan camera
        let deltaX = location.x - lastLocation.x
        let deltaY = location.y - lastLocation.y

        cameraNode.position.x -= deltaX
        cameraNode.position.y -= deltaY

        clampCamera()
        lastPanLocation = location
    }

    // MARK: - Camera Clamping

    private func clampCamera() {
        let scale = cameraNode.xScale
        let viewSize = view?.bounds.size ?? CGSize(width: 1024, height: 768)

        let padding: CGFloat = 200

        // Calculate visible area at current zoom
        let visibleWidth = viewSize.width * scale
        let visibleHeight = viewSize.height * scale

        // Allow camera to move so all parts of map (plus padding) are reachable
        let minX = (visibleWidth / 2) - padding
        let maxX = mapSize.width - (visibleWidth / 2) + padding
        let minY = (visibleHeight / 2) - padding
        let maxY = mapSize.height - (visibleHeight / 2) + padding

        // Only clamp if the map is larger than the visible area
        if maxX > minX {
            cameraNode.position.x = max(minX, min(maxX, cameraNode.position.x))
        } else {
            // Map fits in view, center it
            cameraNode.position.x = mapSize.width / 2
        }

        if maxY > minY {
            cameraNode.position.y = max(minY, min(maxY, cameraNode.position.y))
        } else {
            // Map fits in view, center it
            cameraNode.position.y = mapSize.height / 2
        }
    }

    func handlePinch(scale: CGFloat) {
        let newScale = cameraNode.xScale / scale
        let clampedScale = max(0.3, min(3.5, newScale))
        cameraNode.setScale(clampedScale)
        clampCamera()
    }

    /// Zoom via scroll delta (Magic Mouse swipe / scroll wheel)
    func handleScrollZoom(deltaY: CGFloat) {
        guard cameraNode != nil else { return }
        let zoomFactor: CGFloat = 1.0 - (deltaY * 0.05)
        let newScale = cameraNode.xScale * zoomFactor
        let clampedScale = max(0.3, min(3.5, newScale))
        cameraNode.setScale(clampedScale)
        clampCamera()
    }

    /// Pan camera via scroll deltas (called from SwiftUI event monitor)
    func handleScrollPan(deltaX: CGFloat, deltaY: CGFloat) {
        guard cameraNode != nil else { return }
        dismissOverlaysOnInteraction()
        let scale = cameraNode.xScale
        cameraNode.position.x -= deltaX * scale * 2
        cameraNode.position.y += deltaY * scale * 2
        clampCamera()
    }

    /// Zoom via trackpad magnify gesture (called from SwiftUI event monitor)
    func handleMagnify(magnification: CGFloat) {
        guard cameraNode != nil else { return }
        dismissOverlaysOnInteraction()
        let zoomFactor: CGFloat = 1.0 + magnification
        let newScale = cameraNode.xScale / zoomFactor
        let clampedScale = max(0.3, min(3.5, newScale))
        cameraNode.setScale(clampedScale)
        clampCamera()
    }

    /// Dismiss SwiftUI overlays on any map interaction (scroll, pan, zoom, drag)
    private func dismissOverlaysOnInteraction() {
        onPlayerStartedWalking?()
    }

    // MARK: - Public Methods

    /// Show collection burst on a station
    func showCollectionEffect(at stationType: ResourceStationType) {
        resourceNodes[stationType]?.showCollectionBurst()
    }

    /// Play collecting animation on the player (bend down + sparkles)
    func playPlayerCollectAnimation(completion: (() -> Void)? = nil) {
        guard playerNode != nil else { completion?(); return }
        playerNode.playCollectAnimation(completion: completion)
    }

    /// Play celebrating animation on the player (jump + star burst)
    func playPlayerCelebrateAnimation(completion: (() -> Void)? = nil) {
        guard playerNode != nil else { completion?(); return }
        playerNode.playCelebrateAnimation(completion: completion)
    }

    /// Walk the player to a station programmatically (called from SwiftUI)
    func walkToStation(_ stationType: ResourceStationType) {
        guard playerNode != nil, let node = resourceNodes[stationType] else { return }
        walkPlayerToStation(node)
    }

    /// Get current player position
    func getPlayerPosition() -> CGPoint {
        guard playerNode != nil else { return .zero }
        return playerNode.position
    }

    // MARK: - Editor Mode (DEBUG only)

    #if DEBUG
    private var waypointNodes: [SKNode] = []
    private var waypointContainer: SKNode?
    private var edgeLineNode: SKNode?
    private var editableEdges: [[Int]] = []        // mutable copy for editor
    private var selectedWaypointIndex: Int?         // for C-key connect mode
    private var connectModeSource: Int?             // wp index waiting for second click

    private func registerEditorNodes() {
        // Resource stations
        for (stationType, node) in resourceNodes {
            editorMode.registerNode(node, name: "station_\(stationType.rawValue)")
        }

        // Player
        editorMode.registerNode(playerNode, name: "player")

        // Waypoint dots (hidden until editor mode)
        editableEdges = waypointEdges
        setupWaypointDebugNodes()

        // Show/hide waypoints with editor toggle
        editorMode.onToggle = { [weak self] active in
            guard let self = self else { return }
            self.waypointContainer?.isHidden = !active
            if active {
                self.redrawEdgeLines()
            } else {
                self.syncWaypointsFromNodes()
                self.dumpWaypointData()
            }
            self.connectModeSource = nil
        }

        // Track which waypoint is selected
        editorMode.onNodeSelected = { [weak self] name, _ in
            guard let self = self else { return }
            if name.hasPrefix("wp_"), let idx = Int(name.dropFirst(3)) {
                // If we're in connect mode, toggle the edge
                if let source = self.connectModeSource, source != idx {
                    self.toggleEdge(source, idx)
                    self.connectModeSource = nil
                    print("🔗 Connect mode OFF")
                }
                self.selectedWaypointIndex = idx
            } else {
                self.selectedWaypointIndex = nil
                self.connectModeSource = nil
            }
        }
    }

    private func setupWaypointDebugNodes() {
        let container = SKNode()
        container.zPosition = 200
        container.isHidden = true  // hidden until editor mode

        // Edge lines container
        let edgeNode = SKNode()
        container.addChild(edgeNode)
        edgeLineNode = edgeNode

        // Waypoint dots
        for (i, wp) in waypoints.enumerated() {
            let dot = SKShapeNode(circleOfRadius: 12)
            dot.fillColor = PlatformColor(.orange.opacity(0.7))
            dot.strokeColor = PlatformColor(.white)
            dot.lineWidth = 2
            dot.position = wp
            dot.zPosition = 201

            let label = SKLabelNode(text: "\(i)")
            label.fontName = "Menlo-Bold"
            label.fontSize = 11
            label.fontColor = .white
            label.verticalAlignmentMode = .center
            label.zPosition = 202
            dot.addChild(label)

            container.addChild(dot)
            waypointNodes.append(dot)
            editorMode.registerNode(dot, name: "wp_\(i)")
        }

        addChild(container)
        waypointContainer = container
        redrawEdgeLines()
    }

    private func redrawEdgeLines() {
        edgeLineNode?.removeAllChildren()
        guard let edgeNode = edgeLineNode else { return }

        for edge in editableEdges {
            let a = waypointNodes[edge[0]].position
            let b = waypointNodes[edge[1]].position
            let path = CGMutablePath()
            path.move(to: a)
            path.addLine(to: b)
            let line = SKShapeNode(path: path)
            line.strokeColor = PlatformColor(.orange.opacity(0.35))
            line.lineWidth = 2
            edgeNode.addChild(line)
        }
    }

    /// Toggle edge between two waypoints. Press C on selected wp, then click another.
    private func toggleEdge(_ a: Int, _ b: Int) {
        let pair = [min(a, b), max(a, b)]
        if let idx = editableEdges.firstIndex(where: { [min($0[0], $0[1]), max($0[0], $0[1])] == pair }) {
            editableEdges.remove(at: idx)
            print("❌ Removed edge \(a)↔\(b)")
        } else {
            editableEdges.append(pair)
            print("✅ Added edge \(a)↔\(b)")
        }
        redrawEdgeLines()
    }

    /// Handle C key for connect mode (called from keyDown before editorMode)
    func handleEditorKeyDown(_ keyCode: UInt16) -> Bool {
        guard editorMode.isActive else { return false }

        // C key = 8
        if keyCode == 8, let wpIdx = selectedWaypointIndex {
            if connectModeSource == nil {
                connectModeSource = wpIdx
                print("🔗 Connect mode ON — click another waypoint to toggle edge from wp_\(wpIdx)")
            } else {
                connectModeSource = nil
                print("🔗 Connect mode OFF")
            }
            return true
        }

        // R key = 15 — redraw edges (useful after dragging)
        if keyCode == 15, editorMode.isActive {
            redrawEdgeLines()
            return true
        }

        return false
    }

    /// Sync waypoint array from dragged node positions
    private func syncWaypointsFromNodes() {
        for (i, node) in waypointNodes.enumerated() {
            waypoints[i] = node.position
        }
        // Also sync edges in case they were edited
        waypointEdgesEdited = editableEdges
    }

    /// Storage for edited edges so pathfinding uses them
    private var waypointEdgesEdited: [[Int]]?

    private func dumpWaypointData() {
        print("\n// ========== WAYPOINTS ==========")
        print("private var waypoints: [CGPoint] = [")
        for (i, node) in waypointNodes.enumerated() {
            let p = node.position
            print("    /* \(i) */ CGPoint(x: \(Int(p.x)), y: \(Int(p.y))),")
        }
        print("]")
        print("\nprivate let waypointEdges: [[Int]] = [")
        for edge in editableEdges {
            print("    [\(edge[0]), \(edge[1])],")
        }
        print("]")
        print("// ================================\n")
    }
    #endif

    // MARK: - Radial Glow Helper

    /// Creates a soft radial glow sprite — bright center fading to transparent
    static func makeRadialGlow(radius: CGFloat, color: PlatformColor) -> SKSpriteNode {
        let diameter = Int(radius * 2)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        let colors = [
            PlatformColor(red: r, green: g, blue: b, alpha: 0.6).cgColor,
            PlatformColor(red: r, green: g, blue: b, alpha: 0.0).cgColor
        ] as CFArray
        let locations: [CGFloat] = [0.0, 1.0]

        guard let ctx = CGContext(data: nil, width: diameter, height: diameter,
                                   bitsPerComponent: 8, bytesPerRow: 0,
                                   space: colorSpace,
                                   bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue),
              let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: locations) else {
            return SKSpriteNode()
        }

        let center = CGPoint(x: CGFloat(diameter) / 2, y: CGFloat(diameter) / 2)
        ctx.drawRadialGradient(gradient, startCenter: center, startRadius: 0,
                               endCenter: center, endRadius: radius, options: [])

        guard let image = ctx.makeImage() else { return SKSpriteNode() }
        let texture = SKTexture(cgImage: image)
        let sprite = SKSpriteNode(texture: texture, size: CGSize(width: diameter, height: diameter))
        return sprite
    }

    /// Creates a mask texture: white everywhere with soft radial fade-to-clear holes at given positions.
    /// Used with SKCropNode — white = show dark overlay, clear = reveal terrain underneath.
    /// Creates a mask texture: white everywhere with blurred clear holes at given positions.
    /// Hard clear circles are punched first, then the entire image is Gaussian-blurred
    /// so the edges feather naturally. Used with SKCropNode.
    static func makeCutoutMask(mapSize: CGSize, holePositions: [CGPoint], holeRadius: CGFloat, blurRadius: CGFloat = 40) -> SKTexture {
        let w = Int(mapSize.width)
        let h = Int(mapSize.height)
        let colorSpace = CGColorSpaceCreateDeviceRGB()

        guard let ctx = CGContext(data: nil, width: w, height: h,
                                   bitsPerComponent: 8, bytesPerRow: 0,
                                   space: colorSpace,
                                   bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return SKTexture()
        }

        // Fill entire mask white (opaque = dark overlay visible)
        ctx.setFillColor(PlatformColor.white.cgColor)
        ctx.fill(CGRect(x: 0, y: 0, width: w, height: h))

        // Punch hard clear circles at each position
        ctx.setBlendMode(.copy)
        ctx.setFillColor(PlatformColor(white: 1.0, alpha: 0.0).cgColor)
        for pos in holePositions {
            ctx.fillEllipse(in: CGRect(x: pos.x - holeRadius, y: pos.y - holeRadius,
                                        width: holeRadius * 2, height: holeRadius * 2))
        }

        guard let hardImage = ctx.makeImage() else { return SKTexture() }

        // Apply Gaussian blur to the whole mask — softens circle edges
        let ciImage = CIImage(cgImage: hardImage)
        let blur = CIFilter(name: "CIGaussianBlur", parameters: [
            kCIInputImageKey: ciImage,
            "inputRadius": blurRadius
        ])
        let ciContext = CIContext()
        guard let output = blur?.outputImage,
              let blurredImage = ciContext.createCGImage(output, from: ciImage.extent) else {
            return SKTexture(cgImage: hardImage)
        }

        return SKTexture(cgImage: blurredImage)
    }
}
