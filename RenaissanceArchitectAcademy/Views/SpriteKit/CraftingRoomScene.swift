import SpriteKit
import SwiftUI

/// Crafting station types inside the crafting room
enum CraftingStation: String, CaseIterable, Hashable {
    case workbench = "Workbench"
    case furnace = "Furnace"
    case pigmentTable = "Pigment Table"
    case shelf = "Storage"

    var imageName: String {
        switch self {
        case .workbench:    return "InteriorWorkbench"
        case .furnace:      return "InteriorFurnace"
        case .pigmentTable: return "InteriorPigmentTable"
        case .shelf:        return "InteriorShelf"
        }
    }

    var displayName: String { rawValue }
}

/// SpriteKit scene for the Crafting Room interior
/// Apprentice walks between furniture stations: Workbench, Furnace, Pigment Table, Shelf
class CraftingRoomScene: SKScene, ScrollZoomable {

    // MARK: - Properties

    private var cameraNode: SKCameraNode!
    private var playerNode: PlayerNode!
    private var furnitureNodes: [CraftingStation: SKSpriteNode] = [:]

    /// Player gender — set from SwiftUI before scene appears
    var apprenticeIsBoy: Bool = true

    // Camera control
    private var lastPanLocation: CGPoint?
    private var maxZoomOutScale: CGFloat = 1.0

    // Map size — wider than standard 3500x2500 to fit WorkshopBackground image (7149x4032, ratio 1.77:1)
    private let mapSize = CGSize(width: 4433, height: 2500)

    #if DEBUG
    private lazy var editorMode = SceneEditorMode(scene: self)

    func toggleEditorMode() { editorMode.toggle() }
    var isEditorActive: Bool { editorMode.isActive }
    func editorRotateLeft() { editorMode.rotateLeft() }
    func editorRotateRight() { editorMode.rotateRight() }
    func editorNudge(dx: CGFloat, dy: CGFloat) { editorMode.nudge(dx: dx, dy: dy) }
    #endif

    // Furniture positions in 4433x2500 space (tap targets — art is baked into background)
    private let furniturePositions: [CraftingStation: CGPoint] = [
        .furnace:      CGPoint(x: 560,  y: 1820),
        .workbench:    CGPoint(x: 1930, y: 1645),
        .pigmentTable: CGPoint(x: 2843, y: 940),
        .shelf:        CGPoint(x: 4038, y: 1146),
    ]

    /// Sprite display size for furniture tap targets
    private let furnitureSpriteSize = CGSize(width: 760, height: 760)

    /// Floor-level positions where the apprentice stands in front of each station.
    /// Furniture is on walls/tables (high y), but player walks on the floor (low y).
    private let floorTargets: [CraftingStation: CGPoint] = [
        .furnace:      CGPoint(x: 656,  y: 915),
        .workbench:    CGPoint(x: 1648, y: 760),
        .pigmentTable: CGPoint(x: 2296, y: 21),
        .shelf:        CGPoint(x: 3819, y: 268),
    ]

    // MARK: - Waypoint Graph (floor-level paths)

    private var waypoints: [CGPoint] = [
        /* 0  */ CGPoint(x: 253,  y: 200),   // avatar box spawn (home)
        /* 1  */ CGPoint(x: 656,  y: 915),   // near furnace
        /* 2  */ CGPoint(x: 1184, y: 747),   // left corridor
        /* 3  */ CGPoint(x: 1648, y: 760),   // center
        /* 4  */ CGPoint(x: 1945, y: 435),   // right of center
        /* 5  */ CGPoint(x: 2296, y: 21),    // at pigment table
        /* 6  */ CGPoint(x: 3779, y: 49),    // right corridor
        /* 7  */ CGPoint(x: 3819, y: 268),   // at storage
    ]

    private let waypointEdges: [[Int]] = [
        // Main floor corridor (left to right)
        [0, 1], [1, 2], [2, 3], [3, 4], [4, 5], [5, 6], [6, 7],
        // Skip connections for shorter paths
        [0, 2], [1, 3], [2, 4], [3, 5], [4, 6], [5, 7],
    ]

    /// Which waypoints each station connects to
    private let stationWaypoints: [CraftingStation: [Int]] = [
        .furnace:      [1, 2],
        .workbench:    [3, 4],
        .pigmentTable: [5, 4],
        .shelf:        [7, 6],
    ]

    // MARK: - Callbacks to SwiftUI

    var onFurnitureReached: ((CraftingStation) -> Void)?
    var onPlayerPositionChanged: ((CGPoint, Bool) -> Void)?
    var onPlayerStartedWalking: (() -> Void)?

    /// Pending station walk — stored when player taps while still in the avatar box
    private var pendingStationWalk: CraftingStation?

    // MARK: - Scene Setup

    private var hasSetup = false

    override func didMove(to view: SKView) {
        guard !hasSetup else {
            if playerNode != nil { cameraNode.position = playerNode.position }
            return
        }
        hasSetup = true

        backgroundColor = PlatformColor(RenaissanceColors.parchment)

        setupCamera()
        setupBackground()
        setupGridLines()
        setupTitle()
        setupFurniture()
        setupPlayer()
        setupFurnaceFire()
        setupCraftingRoomLamps()

        isUserInteractionEnabled = true

        #if DEBUG
        registerEditorNodes()
        #endif
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

    private func fitCameraToMap() {
        guard let cameraNode = cameraNode else { return }
        let viewSize = view?.bounds.size ?? self.size
        guard viewSize.width > 0 && viewSize.height > 0 else { return }
        let renderScale = max(viewSize.width / self.size.width, viewSize.height / self.size.height)
        let visibleW = viewSize.width / renderScale
        let visibleH = viewSize.height / renderScale
        let fitScale = max(mapSize.width / visibleW, mapSize.height / visibleH)
        maxZoomOutScale = fitScale
        cameraNode.setScale(fitScale)
    }

    // MARK: - Background

    private func setupBackground() {
        let center = CGPoint(x: mapSize.width / 2, y: mapSize.height / 2)

        // Edge fill — large solid rect behind terrain to hide faded Midjourney borders
        let fill = SKSpriteNode(color: PlatformColor(RenaissanceColors.parchment), size: CGSize(width: mapSize.width * 2, height: mapSize.height * 2))
        fill.position = center
        fill.zPosition = -102
        addChild(fill)

        let terrainTexture = SKTexture(imageNamed: "WorkshopBackground")
        let terrain = SKSpriteNode(texture: terrainTexture)
        // Scale to fill the map while preserving aspect ratio (no distortion)
        let imageSize = terrainTexture.size()
        let scaleX = mapSize.width / imageSize.width
        let scaleY = mapSize.height / imageSize.height
        let fillScale = max(scaleX, scaleY)  // fill, not fit — covers the whole map
        terrain.size = CGSize(width: imageSize.width * fillScale, height: imageSize.height * fillScale)
        terrain.position = center
        terrain.zPosition = -100
        addChild(terrain)
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
        let title = SKLabelNode(text: "CRAFTING ROOM")
        title.fontName = "Cinzel-Regular"
        title.fontSize = 28
        title.fontColor = PlatformColor(RenaissanceColors.sepiaInk.opacity(0.4))
        title.position = CGPoint(x: mapSize.width / 2, y: mapSize.height - 50)
        title.zPosition = -80
        addChild(title)
    }

    // MARK: - Furniture Stations

    private func setupFurniture() {
        for station in CraftingStation.allCases {
            guard let pos = furniturePositions[station] else { continue }

            // Transparent tap target — furniture is baked into the background image
            let sprite = SKSpriteNode(color: .clear, size: furnitureSpriteSize)
            sprite.position = pos
            sprite.zPosition = 10
            sprite.name = "furniture_\(station.rawValue)"
            addChild(sprite)
            furnitureNodes[station] = sprite

            // Pill label below furniture
            let labelY = -(furnitureSpriteSize.height / 2) - 40
            let pill = SKNode.makePillLabel(
                text: station.displayName,
                fontSize: 28,
                position: CGPoint(x: 0, y: labelY),
                zPosition: 10
            )
            sprite.addChild(pill)
        }
    }

    // MARK: - Player

    private func setupPlayer() {
        playerNode = PlayerNode(isBoy: apprenticeIsBoy)
        playerNode.zPosition = 50
        // Scale up for interior scene — player is 170pt in outdoor maps,
        // needs to be ~2.5x larger to look right in this close-up room
        playerNode.setScale(5.0)
        addChild(playerNode)
        // Start at the avatar box waypoint (bottom-left of map)
        playerNode.position = waypoints[0]
        updatePlayerScreenPosition()
    }

    /// Move the player back to the avatar box waypoint (bottom-left of map)
    func positionPlayerAtAvatarBox() {
        playerNode.position = waypoints[0]
        updatePlayerScreenPosition()
    }

    func showPlayer() {
        // Player already visible at box position
    }

    func hidePlayer() {
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

    override func willMove(from view: SKView) {
        removeAllActions()
        removeAllChildren()
        playerNode = nil
        hasSetup = false
        onFurnitureReached = nil
        onPlayerPositionChanged = nil
        onPlayerStartedWalking = nil
    }

    override func update(_ currentTime: TimeInterval) {
        updatePlayerScreenPosition()
        // Clamp camera every frame — prevents SKActions from bypassing bounds
        clampCamera()
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
    }

    // Scroll wheel/trackpad on macOS — scroll = zoom, Option+scroll = pan
    override func scrollWheel(with event: NSEvent) {
        if event.modifierFlags.contains(.option) {
            // Option + scroll = pan the map
            let scale = cameraNode.xScale
            cameraNode.position.x -= event.deltaX * scale * 2
            cameraNode.position.y += event.deltaY * scale * 2
        } else {
            // Regular scroll = zoom (works with Magic Mouse)
            let zoomFactor: CGFloat = 1.0 - (event.deltaY * 0.05)
            let newScale = cameraNode.xScale * zoomFactor
            let clampedScale = max(0.5, min(maxZoomOutScale, newScale))
            cameraNode.setScale(clampedScale)
        }
        clampCamera()
    }

    override func magnify(with event: NSEvent) {
        let zoomFactor: CGFloat = 1.0 + event.magnification
        let newScale = cameraNode.xScale / zoomFactor
        let clampedScale = max(0.5, min(maxZoomOutScale, newScale))
        cameraNode.setScale(clampedScale)
        clampCamera()
    }

    override func keyDown(with event: NSEvent) {
        #if DEBUG
        if editorMode.handleKeyDown(event.keyCode) { return }
        #endif
    }
    #endif

    // MARK: - Shared Input Logic

    private func handleTapAt(_ location: CGPoint) {
        // Check if furniture was tapped
        let tappedNodes = nodes(at: location)
        for node in tappedNodes {
            if let station = stationFor(node: node) {
                onPlayerStartedWalking?()
                walkPlayerToStation(station)
                return
            }
        }

        // Start pan
        lastPanLocation = location
    }

    /// Resolve a tapped node to its CraftingStation
    private func stationFor(node: SKNode) -> CraftingStation? {
        // Direct hit on the sprite
        for (station, sprite) in furnitureNodes {
            if node === sprite || node.parent === sprite {
                return station
            }
        }
        return nil
    }

    // MARK: - Pathfinding (Dijkstra)

    private func buildAdjacency() -> [[Int]] {
        var adj = [[Int]](repeating: [], count: waypoints.count)
        for edge in waypointEdges {
            adj[edge[0]].append(edge[1])
            adj[edge[1]].append(edge[0])
        }
        return adj
    }

    private func nearestWaypoints(to point: CGPoint, count: Int = 2) -> [Int] {
        let indexed = waypoints.enumerated().map { (index: $0.offset, dist: hypot($0.element.x - point.x, $0.element.y - point.y)) }
        let sorted = indexed.sorted { $0.dist < $1.dist }
        return Array(sorted.prefix(count).map { $0.index })
    }

    private func findPath(from start: CGPoint, to end: CGPoint, startWaypoints: [Int], endWaypoints: [Int]) -> [CGPoint] {
        let n = waypoints.count
        let startVirtual = n
        let endVirtual = n + 1
        let totalNodes = n + 2

        var adj = [[(node: Int, dist: CGFloat)]](repeating: [], count: totalNodes)

        let baseAdj = buildAdjacency()
        for i in 0..<n {
            for j in baseAdj[i] {
                let d = hypot(waypoints[i].x - waypoints[j].x, waypoints[i].y - waypoints[j].y)
                adj[i].append((j, d))
            }
        }

        for wp in startWaypoints {
            let d = hypot(start.x - waypoints[wp].x, start.y - waypoints[wp].y)
            adj[startVirtual].append((wp, d))
            adj[wp].append((startVirtual, d))
        }

        for wp in endWaypoints {
            let d = hypot(end.x - waypoints[wp].x, end.y - waypoints[wp].y)
            adj[endVirtual].append((wp, d))
            adj[wp].append((endVirtual, d))
        }

        var dist = [CGFloat](repeating: .infinity, count: totalNodes)
        var prev = [Int](repeating: -1, count: totalNodes)
        var visited = [Bool](repeating: false, count: totalNodes)
        dist[startVirtual] = 0

        for _ in 0..<totalNodes {
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

            if u == endVirtual { break }

            for (v, w) in adj[u] {
                let newDist = dist[u] + w
                if newDist < dist[v] {
                    dist[v] = newDist
                    prev[v] = u
                }
            }
        }

        guard dist[endVirtual] < .infinity else { return [end] }

        var path: [Int] = []
        var cur = endVirtual
        while cur != -1 {
            path.append(cur)
            cur = prev[cur]
        }
        path.reverse()

        var result: [CGPoint] = []
        for nodeIdx in path {
            if nodeIdx == startVirtual { continue }
            if nodeIdx == endVirtual {
                result.append(end)
            } else {
                result.append(waypoints[nodeIdx])
            }
        }

        return result
    }

    private func walkPlayerToStation(_ station: CraftingStation) {
        guard let sprite = furnitureNodes[station] else { return }

        // Tap bounce animation
        sprite.removeAction(forKey: "pulse")
        let scaleUp = SKAction.scale(to: 1.15, duration: 0.1)
        scaleUp.timingMode = .easeOut
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
        scaleDown.timingMode = .easeIn
        sprite.run(SKAction.sequence([scaleUp, scaleDown])) {
            let pulseUp = SKAction.scale(to: 1.03, duration: 1.5)
            pulseUp.timingMode = .easeInEaseOut
            let pulseDown = SKAction.scale(to: 1.0, duration: 1.5)
            pulseDown.timingMode = .easeInEaseOut
            sprite.run(SKAction.repeatForever(SKAction.sequence([pulseUp, pulseDown])), withKey: "pulse")
        }

        let stationPos = sprite.position
        // Walk to floor-level target (not the furniture itself — it's on the wall/table)
        let targetPos = floorTargets[station] ?? CGPoint(x: stationPos.x, y: 300)
        let playerPos = playerNode.position

        let onArrival: () -> Void = { [weak self] in
            // Face toward the station
            let faceRight = stationPos.x > (self?.playerNode.position.x ?? 0)
            self?.playerNode.setFacingDirection(faceRight)
            self?.onFurnitureReached?(station)
        }

        // If very close, walk directly
        let directDistance = hypot(targetPos.x - playerPos.x, targetPos.y - playerPos.y)
        if directDistance < 350 {
            let facingRight = targetPos.x > playerPos.x
            playerNode.setFacingDirection(facingRight)
            playerNode.walkTo(destination: targetPos, duration: max(0.3, TimeInterval(directDistance / 467)), completion: onArrival)
            return
        }

        let startWPs = nearestWaypoints(to: playerPos)
        let endWPs = stationWaypoints[station] ?? nearestWaypoints(to: targetPos)

        let path = findPath(from: playerPos, to: targetPos, startWaypoints: startWPs, endWaypoints: endWPs)

        guard !path.isEmpty else {
            let facingRight = targetPos.x > playerPos.x
            playerNode.setFacingDirection(facingRight)
            playerNode.walkTo(destination: targetPos, duration: max(0.5, TimeInterval(directDistance / 467)), completion: onArrival)
            return
        }

        let firstTarget = path[0]
        let facingRight = firstTarget.x > playerPos.x
        playerNode.setFacingDirection(facingRight)

        playerNode.walkPath(path, speed: 467, completion: onArrival)
    }

    private func handleDragTo(_ location: CGPoint, from lastLocation: CGPoint) {
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
        let clampedScale = max(0.5, min(maxZoomOutScale, cameraNode.xScale))
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

        if maxX > minX {
            cameraNode.position.x = max(minX, min(maxX, cameraNode.position.x))
        } else {
            cameraNode.position.x = mapSize.width / 2
        }

        if maxY > minY {
            cameraNode.position.y = max(minY, min(maxY, cameraNode.position.y))
        } else {
            cameraNode.position.y = mapSize.height / 2
        }
    }

    func handlePinch(scale: CGFloat) {
        let newScale = cameraNode.xScale / scale
        let clampedScale = max(0.5, min(maxZoomOutScale, newScale))
        cameraNode.setScale(clampedScale)
        clampCamera()
    }

    /// Zoom via scroll delta (Magic Mouse swipe / scroll wheel)
    func handleScrollZoom(deltaY: CGFloat) {
        guard cameraNode != nil else { return }
        let zoomFactor: CGFloat = 1.0 - (deltaY * 0.05)
        let newScale = cameraNode.xScale * zoomFactor
        let clampedScale = max(0.5, min(maxZoomOutScale, newScale))
        cameraNode.setScale(clampedScale)
        clampCamera()
    }

    /// Pan camera via scroll deltas (called from SwiftUI event monitor)
    func handleScrollPan(deltaX: CGFloat, deltaY: CGFloat) {
        guard cameraNode != nil else { return }
        let scale = cameraNode.xScale
        cameraNode.position.x -= deltaX * scale * 2
        cameraNode.position.y += deltaY * scale * 2
        clampCamera()
    }

    /// Zoom via trackpad magnify gesture (called from SwiftUI event monitor)
    func handleMagnify(magnification: CGFloat) {
        guard cameraNode != nil else { return }
        let zoomFactor: CGFloat = 1.0 + magnification
        let newScale = cameraNode.xScale / zoomFactor
        let clampedScale = max(0.5, min(maxZoomOutScale, newScale))
        cameraNode.setScale(clampedScale)
        clampCamera()
    }

    // MARK: - Public Animation Methods

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

    // MARK: - Furnace Fire (always-on ambient atmosphere)
    //
    // Same approach as the volcano lava in WorkshopScene — an SKEmitterNode
    // for the flames + an additive-blend glow halo that breathes. The fire
    // is purely ambient (no game-state interaction), making the crafting
    // room feel alive even when the apprentice isn't using the furnace.
    //
    // Position is intentionally code-set and exposed via editor mode — tap
    // EDITOR → tap the fire → drag to align with the painted furnace mouth,
    // then read the new coords from the console and paste them back here.

    private var furnaceFire: SKEmitterNode?
    private var furnaceGlow: SKSpriteNode?

    /// Lamp flames + halos — small candle-sized flickers at fixed wall positions.
    /// Always-on (no active/idle states like the furnace), just ambient lighting.
    private var lampFires: [SKEmitterNode] = []
    private var lampGlows: [SKSpriteNode] = []

    private func setupFurnaceFire() {
        // Aligned with the painted furnace mouth via editor mode.
        // Re-tune by pressing E → drag the fire → paste the new console coords.
        let firePos = CGPoint(x: 228, y: 1398)

        let fire = makeFurnaceFireEmitter()
        fire.position = firePos
        fire.zPosition = 15
        fire.targetNode = self
        fire.name = "furnaceFire"
        fire.advanceSimulationTime(2.0)
        addChild(fire)
        furnaceFire = fire

        // Warm orange halo at the furnace mouth — additive blend brightens
        // the painted brick beneath. Pulses subtly to feel like breathing fire.
        let glow = SKSpriteNode(texture: Self.softCircleTexture)
        glow.position = firePos
        glow.size = CGSize(width: 240, height: 200)
        glow.color = PlatformColor(red: 1.0, green: 0.55, blue: 0.18, alpha: 1.0)
        glow.colorBlendFactor = 1.0
        glow.blendMode = .add
        glow.alpha = 0.4
        glow.zPosition = 13
        glow.name = "furnaceGlow"
        addChild(glow)
        furnaceGlow = glow

        // Breathing pulse — scale + alpha animate together so the warmth
        // visibly swells, matching the volcano-glow rhythm in WorkshopScene.
        let scaleUp = SKAction.scale(to: 1.08, duration: 1.4)
        let scaleDown = SKAction.scale(to: 0.95, duration: 1.4)
        let fadeUp = SKAction.fadeAlpha(to: 0.55, duration: 1.4)
        let fadeDown = SKAction.fadeAlpha(to: 0.32, duration: 1.4)
        scaleUp.timingMode = .easeInEaseOut
        scaleDown.timingMode = .easeInEaseOut
        fadeUp.timingMode = .easeInEaseOut
        fadeDown.timingMode = .easeInEaseOut
        let breatheIn  = SKAction.group([scaleUp,   fadeUp])
        let breatheOut = SKAction.group([scaleDown, fadeDown])
        glow.run(SKAction.repeatForever(SKAction.sequence([breatheIn, breatheOut])))
    }

    /// Toggle the fire between idle (small embers) and active (full flame +
    /// brighter halo). Called from CraftingRoomMapView whenever
    /// `workshop.isProcessing` changes. Particles already alive keep their
    /// old size until they die — so the transition feels like a natural
    /// ramp-up/down rather than a hard cut.
    func setFurnaceActive(_ active: Bool) {
        guard let fire = furnaceFire, let glow = furnaceGlow else { return }

        if active {
            fire.particleScale = 0.9
            fire.particleScaleRange = 0.3
            fire.particleScaleSpeed = -0.7
            fire.particleSpeed = 120
            fire.particleSpeedRange = 36
            fire.yAcceleration = 24
            fire.particlePositionRange = CGVector(dx: 60, dy: 12)
            fire.particleBirthRate = 110
            glow.run(SKAction.group([
                SKAction.resize(toWidth: 480, height: 400, duration: 0.5),
                SKAction.fadeAlpha(to: 0.7, duration: 0.5)
            ]), withKey: "furnaceIntensity")
        } else {
            fire.particleScale = 0.45
            fire.particleScaleRange = 0.15
            fire.particleScaleSpeed = -0.35
            fire.particleSpeed = 60
            fire.particleSpeedRange = 18
            fire.yAcceleration = 12
            fire.particlePositionRange = CGVector(dx: 30, dy: 6)
            fire.particleBirthRate = 70
            glow.run(SKAction.group([
                SKAction.resize(toWidth: 240, height: 200, duration: 0.5),
                SKAction.fadeAlpha(to: 0.4, duration: 0.5)
            ]), withKey: "furnaceIntensity")
        }
    }

    // MARK: - Crafting Room Lamps

    /// Two small candle-sized flames hung in the crafting room. Always on,
    /// no state toggle. Default positions are placeholders — drag each to
    /// the painted lamp via editor mode and paste the new coords back.
    private func setupCraftingRoomLamps() {
        let defaults: [(name: String, position: CGPoint)] = [
            ("lamp1", CGPoint(x: 2583, y: 1755)),  // tuned via editor mode
            ("lamp2", CGPoint(x:  555, y: 1760))   // tuned via editor mode
        ]
        for entry in defaults {
            addLamp(at: entry.position, named: entry.name)
        }
    }

    private func addLamp(at position: CGPoint, named name: String) {
        let fire = makeLampFireEmitter()
        fire.position = position
        fire.zPosition = 15
        fire.targetNode = self
        fire.name = "\(name)_fire"
        fire.advanceSimulationTime(2.0)
        addChild(fire)
        lampFires.append(fire)

        let glow = SKSpriteNode(texture: Self.softCircleTexture)
        glow.position = position
        glow.size = CGSize(width: 150, height: 165)
        glow.color = PlatformColor(red: 1.0, green: 0.65, blue: 0.25, alpha: 1.0)
        glow.colorBlendFactor = 1.0
        glow.blendMode = .add
        glow.alpha = 0.35
        glow.zPosition = 13
        glow.name = "\(name)_glow"
        addChild(glow)
        lampGlows.append(glow)

        // Subtle candle flicker — shorter cycle than the furnace breathing
        // pulse so the lamps feel "alive" without competing with the fire.
        let scaleUp   = SKAction.scale(to: 1.04, duration: 0.9)
        let scaleDown = SKAction.scale(to: 0.97, duration: 0.9)
        let fadeUp    = SKAction.fadeAlpha(to: 0.42, duration: 0.9)
        let fadeDown  = SKAction.fadeAlpha(to: 0.30, duration: 0.9)
        scaleUp.timingMode  = .easeInEaseOut
        scaleDown.timingMode = .easeInEaseOut
        fadeUp.timingMode   = .easeInEaseOut
        fadeDown.timingMode = .easeInEaseOut
        let flickerIn  = SKAction.group([scaleUp,   fadeUp])
        let flickerOut = SKAction.group([scaleDown, fadeDown])
        glow.run(SKAction.repeatForever(SKAction.sequence([flickerIn, flickerOut])))
    }

    /// Tiny candle-flame emitter. Far smaller than the furnace fire — narrow
    /// spread, low birth rate, gentle rise, almost no red in the color
    /// sequence (real candle flames are mostly yellow-orange).
    private func makeLampFireEmitter() -> SKEmitterNode {
        let e = SKEmitterNode()
        e.particleTexture = Self.softCircleTexture

        e.particleBirthRate = 25
        e.particleLifetime = 0.6
        e.particleLifetimeRange = 0.15

        e.emissionAngle = .pi / 2
        e.emissionAngleRange = .pi / 12     // very tight column

        e.particleSpeed = 38
        e.particleSpeedRange = 9

        e.xAcceleration = 0
        e.yAcceleration = 6

        e.particleScale = 0.27
        e.particleScaleRange = 0.075
        e.particleScaleSpeed = -0.3

        e.particleRotationRange = .pi
        e.particleRotationSpeed = .pi / 8

        // Candle palette — bright yellow at the wick, soft orange mid, fade.
        // No deep red because lamp flames don't reach those temperatures.
        let colors = [
            PlatformColor(red: 1.0, green: 0.95, blue: 0.55, alpha: 1.0),
            PlatformColor(red: 1.0, green: 0.70, blue: 0.25, alpha: 1.0),
            PlatformColor(red: 0.95, green: 0.45, blue: 0.10, alpha: 0.0)
        ]
        e.particleColorSequence = SKKeyframeSequence(
            keyframeValues: colors,
            times: [0.0, 0.45, 1.0]
        )
        e.particleColorBlendFactor = 1.0

        e.particleBlendMode = .add

        e.particleAlpha = 0.95
        e.particleAlphaRange = 0.05

        // Tiny mouth — wick-sized.
        e.particlePositionRange = CGVector(dx: 6, dy: 3)

        return e
    }

    private func makeFurnaceFireEmitter() -> SKEmitterNode {
        let e = SKEmitterNode()
        e.particleTexture = Self.softCircleTexture

        // Dense, fast-flickering flames — quick lifetime so the fire reads
        // as turbulent rather than a slow drift.
        e.particleBirthRate = 70
        e.particleLifetime = 0.85
        e.particleLifetimeRange = 0.25

        // Aim straight up with a narrow spread so flames stay concentrated
        // in the mouth instead of fanning into the room.
        e.emissionAngle = .pi / 2
        e.emissionAngleRange = .pi / 7

        e.particleSpeed = 60
        e.particleSpeedRange = 18

        // Slight upward acceleration accentuates the rise without making
        // particles shoot past the painted chimney area.
        e.xAcceleration = 0
        e.yAcceleration = 12

        e.particleScale = 0.45
        e.particleScaleRange = 0.15
        e.particleScaleSpeed = -0.35   // taper toward the tip of the flame

        e.particleRotationRange = .pi
        e.particleRotationSpeed = .pi / 6

        // Bright yellow at the mouth → orange mid-rise → deep red → fade.
        // 0.0 = first instant of particle life (base), 1.0 = end (tip).
        let colors = [
            PlatformColor(red: 1.0, green: 0.95, blue: 0.55, alpha: 1.0),
            PlatformColor(red: 1.0, green: 0.62, blue: 0.18, alpha: 1.0),
            PlatformColor(red: 0.85, green: 0.20, blue: 0.05, alpha: 1.0),
            PlatformColor(red: 0.30, green: 0.05, blue: 0.0,  alpha: 0.0)
        ]
        e.particleColorSequence = SKKeyframeSequence(
            keyframeValues: colors,
            times: [0.0, 0.30, 0.70, 1.0]
        )
        e.particleColorBlendFactor = 1.0

        // Additive so overlapping particles brighten the base, while the
        // cooled tip fades cleanly into the painted background.
        e.particleBlendMode = .add

        e.particleAlpha = 0.95
        e.particleAlphaRange = 0.1

        // Narrow horizontal mouth, even narrower vertically.
        e.particlePositionRange = CGVector(dx: 30, dy: 6)

        return e
    }

    /// Soft radial-gradient circle reused for both fire particles and the
    /// glow halo. Generated at runtime so we don't ship another asset.
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

    // MARK: - Editor Mode (DEBUG only)

    #if DEBUG
    private var waypointNodes: [SKNode] = []
    private var waypointContainer: SKNode?
    private var edgeLineNode: SKNode?

    private func registerEditorNodes() {
        for (station, node) in furnitureNodes {
            editorMode.registerNode(node, name: "furniture_\(station.rawValue)")
        }
        editorMode.registerNode(playerNode, name: "player")

        if let fire = furnaceFire {
            editorMode.registerNode(fire, name: "fire_furnace")
        }
        if let glow = furnaceGlow {
            editorMode.registerNode(glow, name: "glow_furnace")
        }
        for fire in lampFires {
            editorMode.registerNode(fire, name: fire.name ?? "lamp_fire")
        }
        for glow in lampGlows {
            editorMode.registerNode(glow, name: glow.name ?? "lamp_glow")
        }

        setupWaypointDebugNodes()

        editorMode.onToggle = { [weak self] active in
            guard let self = self else { return }
            self.waypointContainer?.isHidden = !active
            if active {
                self.redrawEdgeLines()
            } else {
                self.syncWaypointsFromNodes()
                self.dumpPositionData()
            }
        }
    }

    private func setupWaypointDebugNodes() {
        let container = SKNode()
        container.zPosition = 200
        container.isHidden = true

        let edgeNode = SKNode()
        container.addChild(edgeNode)
        edgeLineNode = edgeNode

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

        for edge in waypointEdges {
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

    private func syncWaypointsFromNodes() {
        for (i, node) in waypointNodes.enumerated() {
            waypoints[i] = node.position
        }
    }

    private func dumpPositionData() {
        print("\n// ========== CRAFTING ROOM POSITIONS ==========")
        print("// Furniture:")
        for (station, node) in furnitureNodes {
            let p = node.position
            print("  .\(station): CGPoint(x: \(Int(p.x)), y: \(Int(p.y)))")
        }
        print("\n// Waypoints:")
        print("private var waypoints: [CGPoint] = [")
        for (i, node) in waypointNodes.enumerated() {
            let p = node.position
            print("    /* \(i) */ CGPoint(x: \(Int(p.x)), y: \(Int(p.y))),")
        }
        print("]")
        print("// =============================================\n")
    }
    #endif
}
