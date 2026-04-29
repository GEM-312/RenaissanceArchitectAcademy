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
    private var maxZoomOutScale: CGFloat = 1.0

    // Map size — matches city's 3500×2500 so terrain renders at same density
    private let mapSize = CGSize(width: 3500, height: 2500)

    /// Reusable terrain blur system
    let terrainBlur = TerrainBlurHelper()

    /// Whether the player is currently walking
    private(set) var isPlayerWalking = false

    #if DEBUG
    private lazy var editorMode = SceneEditorMode(scene: self)

    func toggleEditorMode() { editorMode.toggle() }
    var isEditorActive: Bool { editorMode.isActive }
    func editorRotateLeft() { editorMode.rotateLeft() }
    func editorRotateRight() { editorMode.rotateRight() }
    func editorNudge(dx: CGFloat, dy: CGFloat) { editorMode.nudge(dx: dx, dy: dy) }
    #endif

    // Station positions — scaled to 3500x2500 coordinate space
    // Workbench, furnace, and pigment table are inside the Crafting Room (interior scene)
    private let stationPositions: [ResourceStationType: CGPoint] = [
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
    ]

    // MARK: - Waypoint Graph (road network for pathfinding)

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
    private var waypoints: [CGPoint] = [
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
    ]

    /// Bidirectional edges — ~31 pairs total, down from ~100.
    private let waypointEdges: [[Int]] = [
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
    ]

    /// Which waypoints each station connects to. The first entry is the
    /// dedicated station-access waypoint (always closest); additional
    /// entries are nearby hubs that give Dijkstra more routing flexibility.
    private let stationWaypoints: [ResourceStationType: [Int]] = [
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
        setupAmbientEffects()
        setupPlayer()

        // Dark tint node — toggled by theme (2x mapSize to cover edge fill area)
        let tint = SKSpriteNode(color: .black, size: CGSize(width: mapSize.width * 2, height: mapSize.height * 2))
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
        let viewSize = view?.bounds.size ?? self.size
        guard viewSize.width > 0 && viewSize.height > 0 else { return }
        // For .aspectFill: compute visible area at scale 1.0, then find max scale where terrain fills
        let renderScale = max(viewSize.width / self.size.width, viewSize.height / self.size.height)
        let visibleW = viewSize.width / renderScale
        let visibleH = viewSize.height / renderScale
        let fitScale = min(mapSize.width / visibleW, mapSize.height / visibleH)
        maxZoomOutScale = fitScale
        cameraNode.setScale(fitScale)
    }

    // MARK: - Background

    private func setupBackground() {
        // Workshop terrain — sharp/blurred pair with smooth lerp crossfade
        // Edge fill hides faded Midjourney borders when camera follows player to map edges
        terrainBlur.setup(in: self, sharp: "WorkshopTerrain", blurred: "BlurredWorkshopTerrain", mapSize: mapSize, edgeFillColor: PlatformColor(RenaissanceColors.parchment))
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

    // MARK: - Ambient Effects (always-on world animation)

    /// Adds non-interactive ambient animations layered over the painted terrain
    /// — the workshop "breathes" even when the player isn't acting on a station.
    /// Particles are scene-space (`targetNode = self`) so they drift independently
    /// of camera pan/zoom.
    private func setupAmbientEffects() {
        guard let volcanoPos = stationPositions[.volcano] else { return }

        let smoke = makeVolcanoSmokeEmitter()
        // Origin sits above the volcano sprite so particles read as rising
        // from the crater, not from the station icon's center.
        smoke.position = CGPoint(x: volcanoPos.x, y: volcanoPos.y + 60)
        smoke.zPosition = 15
        smoke.targetNode = self
        smoke.name = "volcanoSmoke"
        // Pre-warm so smoke is already rising when the player first sees the scene
        // (otherwise the column has to "build up" for ~4 seconds on scene load).
        smoke.advanceSimulationTime(4.0)
        addChild(smoke)
    }

    private func makeVolcanoSmokeEmitter() -> SKEmitterNode {
        let e = SKEmitterNode()
        e.particleTexture = Self.softCircleTexture

        // Spawn rate + lifetime
        e.particleBirthRate = 8
        e.particleLifetime = 4.0
        e.particleLifetimeRange = 1.5

        // Movement — straight up with slight spread, drifting and accelerating
        e.emissionAngle = .pi / 2
        e.emissionAngleRange = .pi / 8
        e.particleSpeed = 35
        e.particleSpeedRange = 15
        e.xAcceleration = 5
        e.yAcceleration = 8

        // Size — particles grow as they rise
        e.particleScale = 0.8
        e.particleScaleRange = 0.4
        e.particleScaleSpeed = 0.3

        // Slow tumble
        e.particleRotationRange = .pi
        e.particleRotationSpeed = .pi / 8

        // Warm ash color — sepia gray with a faint volcanic warmth
        e.particleColor = PlatformColor(red: 0.45, green: 0.35, blue: 0.30, alpha: 1)
        e.particleColorBlendFactor = 1.0
        e.particleColorBlendFactorSpeed = -0.2

        // Alpha — translucent, fades to nothing as it rises
        e.particleAlpha = 0.65
        e.particleAlphaRange = 0.15
        e.particleAlphaSpeed = -0.2

        // Standard alpha blend (additive would over-glow against the watercolor terrain)
        e.particleBlendMode = .alpha

        // Spread the spawn point so the column looks organic, not a single jet
        e.particlePositionRange = CGVector(dx: 30, dy: 8)

        return e
    }

    /// Soft radial-gradient circle used as the smoke particle. Generated once at
    /// runtime so we don't have to ship another asset just for ambient particles.
    private static let softCircleTexture: SKTexture = {
        let size = CGSize(width: 64, height: 64)
        #if os(iOS)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            drawSoftCircle(in: ctx.cgContext, size: size)
        }
        return SKTexture(image: image)
        #else
        let image = NSImage(size: size, flipped: false) { _ in
            guard let cg = NSGraphicsContext.current?.cgContext else { return false }
            drawSoftCircle(in: cg, size: size)
            return true
        }
        return SKTexture(image: image)
        #endif
    }()

    private static func drawSoftCircle(in ctx: CGContext, size: CGSize) {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let radius = size.width / 2
        let space = CGColorSpaceCreateDeviceRGB()
        let colors = [
            PlatformColor(white: 1, alpha: 1).cgColor,
            PlatformColor(white: 1, alpha: 0).cgColor
        ] as CFArray
        guard let gradient = CGGradient(colorsSpace: space, colors: colors, locations: [0, 1]) else { return }
        ctx.drawRadialGradient(gradient,
                               startCenter: center, startRadius: 0,
                               endCenter: center, endRadius: radius,
                               options: [])
    }

    // MARK: - Player

    private func setupPlayer() {
        playerNode = PlayerNode(isBoy: apprenticeIsBoy)
        playerNode.zPosition = 50
        addChild(playerNode)
        // Start at the avatar box waypoint (bottom-left of map)
        playerNode.position = waypoints[16]
        updatePlayerScreenPosition()
    }

    /// Move the player back to the avatar box waypoint (bottom-left of map)
    func positionPlayerAtAvatarBox() {
        playerNode.position = waypoints[16]
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
        }

        // Clamp camera every frame — prevents SKActions from bypassing bounds
        clampCamera()

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
            let clampedScale = max(0.3, min(maxZoomOutScale, newScale))
            cameraNode.setScale(clampedScale)
        }
        clampCamera()
    }

    // Pinch-to-zoom on trackpad
    override func magnify(with event: NSEvent) {
        dismissOverlaysOnInteraction()
        let zoomFactor: CGFloat = 1.0 + event.magnification
        let newScale = cameraNode.xScale / zoomFactor
        let clampedScale = max(0.3, min(maxZoomOutScale, newScale))
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
        let fitScale = maxZoomOutScale

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
        // Clamp SCALE first — prevents SKActions from overshooting maxZoomOutScale
        // which causes terrain edges to flash visible for 1-2 frames during zoom-out
        let clampedScale = max(0.3, min(maxZoomOutScale, cameraNode.xScale))
        if cameraNode.xScale != clampedScale {
            cameraNode.setScale(clampedScale)
        }

        let scale = cameraNode.xScale
        let viewSize = view?.bounds.size ?? CGSize(width: 1024, height: 768)

        // For .aspectFill, compute visible area in scene coordinates
        let renderScale = max(viewSize.width / self.size.width, viewSize.height / self.size.height)
        let visibleWidth = (viewSize.width / renderScale) * scale
        let visibleHeight = (viewSize.height / renderScale) * scale

        let minX = visibleWidth / 2
        let maxX = mapSize.width - (visibleWidth / 2)
        let minY = visibleHeight / 2
        let maxY = mapSize.height - (visibleHeight / 2)

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
        let clampedScale = max(0.3, min(maxZoomOutScale, newScale))
        cameraNode.setScale(clampedScale)
        clampCamera()
    }

    /// Zoom via scroll delta (Magic Mouse swipe / scroll wheel)
    func handleScrollZoom(deltaY: CGFloat) {
        guard cameraNode != nil else { return }
        let zoomFactor: CGFloat = 1.0 - (deltaY * 0.05)
        let newScale = cameraNode.xScale * zoomFactor
        let clampedScale = max(0.3, min(maxZoomOutScale, newScale))
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
        let clampedScale = max(0.3, min(maxZoomOutScale, newScale))
        cameraNode.setScale(clampedScale)
        clampCamera()
    }

    /// Dismiss SwiftUI overlays on any map interaction (scroll, pan, zoom, drag)
    private func dismissOverlaysOnInteraction() {
        onPlayerStartedWalking?()
    }

    // MARK: - Public Methods

    /// Update material-needed badges on all resource stations.
    /// `neededMaterials` is the full dict of raw materials the building still needs.
    func updateStationBadges(neededMaterials: [Material: Int]) {
        for (stationType, node) in resourceNodes {
            // Filter to materials this station provides
            let stationMats = Set(stationType.materials)
            let filtered = neededMaterials.filter { stationMats.contains($0.key) }
            node.updateNeededBadge(materials: filtered)
        }
    }

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
        // Convert to RGB — macOS .white is grayscale, getRed() crashes on non-RGB colors
        #if os(macOS)
        let rgbColor = color.usingColorSpace(.deviceRGB) ?? color
        #else
        let rgbColor = color
        #endif
        rgbColor.getRed(&r, green: &g, blue: &b, alpha: &a)
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
