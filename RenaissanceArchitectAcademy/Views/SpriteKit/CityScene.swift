import SpriteKit
import SwiftUI

#if os(iOS)
import UIKit
typealias PlatformColor = UIColor
typealias PlatformFont = UIFont
#else
import AppKit
typealias PlatformColor = NSColor
typealias PlatformFont = NSFont
#endif

/// Main SpriteKit scene for the isometric city map
/// Based on level_design_sketch.JPG layout
class CityScene: SKScene, ScrollZoomable {

    // MARK: - Zone

    /// Everything that makes this map *this* map — terrain names, building
    /// placements, waypoint graph, trees, labels, spawn. All six zones are this
    /// same class constructed with a different definition; there is no base
    /// class and no per-zone subclass. See `docs/plans/zone-system-plan.md`.
    let zone: ZoneDefinition

    init(zone: ZoneDefinition) {
        self.zone = zone
        super.init(size: zone.mapSize)
        maxZoomOutScale = zone.cameraMaxZoomOutScale
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented — use init(zone:)")
    }

    // MARK: - Properties

    private var cameraNode: SKCameraNode!
    /// Maximum zoom-out scale = full map visible (computed in fitCameraToMap)
    private var maxZoomOutScale: CGFloat = 3.5
    private(set) var buildingNodes: [String: BuildingNode] = [:]

    /// Swaying-tree decoration — same wind-warp animation as WorkshopScene.
    /// Each tree pulses gently in continuous sway; the apprentice's footfalls
    /// trigger a stronger one-shot lean when she walks within 150pt.
    private struct SwayingTree {
        let node: SKSpriteNode
        var lastDisturbed: TimeInterval = 0
    }
    private var swayingTrees: [SwayingTree] = []
    private var playerNode: PlayerNode!

    /// Player gender — set from SwiftUI before scene appears
    var apprenticeIsBoy: Bool = true

    /// Tracks last known theme to detect changes in update()
    private var lastKnownDarkMode: Bool?

    private var lastCursorPosition: CGPoint?

    // Callback when a building is tapped
    var onBuildingSelected: ((String) -> Void)?

    // Callback when player reaches building: (buildingId, screenPosition)
    var onMascotReachedBuilding: ((String) -> Void)?

    /// Callback with building's screen-space position (normalized 0–1) — updated every frame
    var onBuildingScreenPosition: ((CGPoint) -> Void)?

    /// The building currently showing a dialog — tracked every frame for position updates
    private var dialogBuildingNode: BuildingNode?

    /// Last reported screen position — only fire callback when position changes meaningfully
    private var lastReportedScreenPos: CGPoint = .zero

    /// Callback when player starts walking (dismiss any open dialogs)
    var onPlayerStartedWalking: (() -> Void)?

    // Callback when mascot walks off to puzzle
    var onMascotExitToPuzzle: (() -> Void)?

    /// White spotlight glow under player during walking — makes apprentice pop against terrain
    private var playerSpotlight: SKSpriteNode?

    /// Animated river shape nodes (for cleanup + theme)

    /// Whether the player is currently walking to a building
    private(set) var isPlayerWalking = false

    /// Camera follows player while walking
    private var isFollowingPlayer = false
    /// The building position the player is walking toward (for gradual zoom)
    private var walkTargetPosition: CGPoint?

    // Camera control
    private var lastPanLocation: CGPoint?
    private var initialCameraScale: CGFloat = 1.0

    /// Reusable terrain blur system
    let terrainBlur = TerrainBlurHelper()

    #if DEBUG
    private lazy var editorMode = SceneEditorMode(scene: self)

    /// Toggle editor mode from SwiftUI (for iPad / when keyboard doesn't work)
    func toggleEditorMode() {
        editorMode.toggle()
    }

    var isEditorActive: Bool { editorMode.isActive }

    func editorRotateLeft() { editorMode.rotateLeft() }
    func editorRotateRight() { editorMode.rotateRight() }
    func editorNudge(dx: CGFloat, dy: CGFloat) { editorMode.nudge(dx: dx, dy: dy) }
    #endif

    // MARK: - Map Size

    /// The scene's coordinate space, from the zone. Every scene in the project
    /// uses 3500×2500; the terrain PNG is 1.4:1 to match.
    private var mapSize: CGSize { zone.mapSize }

    /// Buildings that get no node on the map at all — no sprite, no blueprint diamond,
    /// no tap target.
    private var hiddenBuildingIds: Set<String> { zone.hiddenBuildingIds }

    // MARK: - Waypoint Graph (road network for pathfinding)

    /// Road junctions for this zone's map, from the zone definition.
    private var waypoints: [CGPoint] { zone.waypoints }

    /// Bidirectional edges: each pair [a, b] means a↔b
    private var waypointEdges: [[Int]] { zone.waypointEdges }

    /// Which waypoints each building connects to (nearest road junctions)
    private var buildingWaypoints: [String: [Int]] { zone.buildingWaypoints }

    // Walk speed and constants (same as Workshop)
    private let walkSpeed: CGFloat = 467
    private let directWalkThreshold: CGFloat = 350

    // MARK: - Scene Setup

    private var hasSetup = false

    override func didMove(to view: SKView) {
        // Drop to 30fps when idle — bumped to 60 during walking/zooming
        view.preferredFramesPerSecond = 30

        guard !hasSetup else {
            if playerNode != nil { cameraNode.position = playerNode.position }
            return
        }
        hasSetup = true

        backgroundColor = PlatformColor(RenaissanceColors.parchment) // #F5E6D3

        setupCamera()
        setupTerrain()
        setupBuildings()
        setupDecorations()
        setupSwayingTrees()
        setupPlayer()

        // Dark tint node — toggled by theme
        let tint = SKSpriteNode(color: .black, size: mapSize)
        tint.name = "darkTint"
        tint.position = CGPoint(x: mapSize.width / 2, y: mapSize.height / 2)
        tint.zPosition = 12
        tint.alpha = 0.3
        addChild(tint)

        // Dark mode glow (warm ochre)
        for (_, node) in buildingNodes {
            let glow = WorkshopScene.makeRadialGlow(radius: 180, color: PlatformColor(red: 0.85, green: 0.66, blue: 0.37, alpha: 1.0))
            glow.name = "darkGlow"
            glow.position = node.position
            glow.zPosition = 13
            glow.alpha = 0.5
            glow.blendMode = .add
            addChild(glow)
        }

        // Apply initial theme
        applyTheme()

        // Enable touch and tracking
        isUserInteractionEnabled = true

        #if os(macOS)
        // Enable mouse moved events
        view.window?.acceptsMouseMovedEvents = true
        #endif

        #if DEBUG
        registerEditorNodes()
        #endif
    }

    // MARK: - Player Setup

    private func setupPlayer() {
        playerNode = PlayerNode(isBoy: apprenticeIsBoy)
        playerNode.position = zone.playerSpawn
        // Scaled on the node, not on PlayerNode's spriteSize, so this stays local to
        // the city map — the Workshop, Forest and Crafting Room share PlayerNode and
        // keep their own scale. The breathing/squash animations run on the child
        // sprite, so they still work relative to this.
        playerNode.setScale(1.3)
        playerNode.zPosition = 50
        addChild(playerNode)

        // White spotlight glow — follows player, only visible during walking
        let spot = WorkshopScene.makeRadialGlow(radius: 120, color: .white)
        spot.zPosition = 49  // Just behind player
        spot.alpha = 0
        spot.blendMode = .alpha
        addChild(spot)
        playerSpotlight = spot
    }

    // MARK: - Theme

    private func applyTheme() {
        let dark = GameSettings.shared.isDarkMode

        // Toggle tint + glow visibility
        enumerateChildNodes(withName: "darkTint") { node, _ in node.isHidden = !dark }
        enumerateChildNodes(withName: "darkGlow") { node, _ in node.isHidden = !dark }
    }

    // MARK: - Scene Lifecycle

    override func willMove(from view: SKView) {
        // Release all textures and children to free memory when scene is removed
        removeAllActions()
        removeAllChildren()
        terrainBlur.cleanup()
        playerNode = nil
        hasSetup = false
        // Break retain cycles from closures capturing SwiftUI views
        onBuildingSelected = nil
        onMascotReachedBuilding = nil
        onBuildingScreenPosition = nil
        onPlayerStartedWalking = nil
        onMascotExitToPuzzle = nil
    }

    // MARK: - Update Loop

    override func update(_ currentTime: TimeInterval) {
        // Check for theme change
        let currentDark = GameSettings.shared.isDarkMode
        if lastKnownDarkMode != currentDark {
            lastKnownDarkMode = currentDark
            applyTheme()
        }

        // Smoothly follow the player while walking to a building. Lerp toward
        // the clamp-respecting position for the player — for edge buildings
        // the raw player position is outside the allowed camera range, and
        // lerping toward it would have clamp slam the camera back to bounds
        // every frame (visible "shift"). Lerping toward the clamped target
        // means lerp and clamp agree, so the camera glides smoothly and the
        // player walks into frame at the edge.
        if isFollowingPlayer {
            let target = clampedPosition(for: playerNode.position)
            let current = cameraNode.position
            let lerpFactor: CGFloat = 0.08
            cameraNode.position = CGPoint(
                x: current.x + (target.x - current.x) * lerpFactor,
                y: current.y + (target.y - current.y) * lerpFactor
            )
        }

        // Spotlight follows player, fades in/out with walking
        if let spot = playerSpotlight {
            spot.position = playerNode.position
            let targetAlpha: CGFloat = isPlayerWalking ? 0.35 : 0
            spot.alpha += (targetAlpha - spot.alpha) * 0.1
        }

        // Clamp camera every frame — prevents SKActions from bypassing bounds
        clampCamera()

        // Trees sway when the apprentice walks near them
        disturbTreesNearPlayer()

        // Terrain clarity — crossfade sharpened overlay based on zoom level
        if let cam = cameraNode {
            terrainBlur.updateBlur(cameraScale: cam.xScale)
        }

        // Update dialog position — only fires callback when position changes by >1pt
        // to avoid triggering SwiftUI re-renders every frame (causes flicker on iPhone)
        if let buildingNode = dialogBuildingNode, let view = self.view {
            let viewPoint = convertPoint(toView: buildingNode.position)
            let viewSize = view.bounds.size
            // macOS NSView has Y-up (0 at bottom), SwiftUI has Y-down (0 at top) → flip Y
            #if os(iOS)
            let normalizedY = viewPoint.y / viewSize.height
            #else
            let normalizedY = 1.0 - (viewPoint.y / viewSize.height)
            #endif
            let normalized = CGPoint(
                x: viewPoint.x / viewSize.width,
                y: normalizedY
            )
            // Only update if moved more than ~1pt in screen space to avoid per-frame SwiftUI re-renders
            let dx = abs(normalized.x - lastReportedScreenPos.x) * viewSize.width
            let dy = abs(normalized.y - lastReportedScreenPos.y) * viewSize.height
            if dx > 1.0 || dy > 1.0 {
                lastReportedScreenPos = normalized
                onBuildingScreenPosition?(normalized)
            }
        }
    }

    private func setupCamera() {
        cameraNode = SKCameraNode()
        cameraNode.position = CGPoint(x: mapSize.width / 2, y: mapSize.height / 2)
        addChild(cameraNode)
        camera = cameraNode
        // Start fully zoomed out so terrain is sharp on launch.
        // Uses the same .aspectFill fit math as WorkshopScene.
        cameraNode.setScale(computeFitScale() ?? 1.0)
    }

    /// Recalculate zoom limits when view resizes.
    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        if let fit = computeFitScale() {
            maxZoomOutScale = fit
        }
    }

    /// Set camera scale so the full map is visible. Uses the .aspectFill
    /// render-scale-aware calculation (copied from WorkshopScene) — the
    /// naive `min(mapSize/viewSize)` formula only works for .resizeFill
    /// and would leave huge parchment borders around the map.
    private func fitCameraToMap() {
        guard let cameraNode = cameraNode, let fitScale = computeFitScale() else { return }
        maxZoomOutScale = fitScale
        cameraNode.setScale(fitScale)
        cameraNode.position = CGPoint(x: mapSize.width / 2, y: mapSize.height / 2)
    }

    /// Camera scale at which the full map exactly fills the view under
    /// `.aspectFill`. Returns nil if the view isn't sized yet.
    private func computeFitScale() -> CGFloat? {
        let viewSize = view?.bounds.size ?? self.size
        guard viewSize.width > 0, viewSize.height > 0 else { return nil }
        let renderScale = max(viewSize.width / self.size.width,
                              viewSize.height / self.size.height)
        let visibleW = viewSize.width / renderScale
        let visibleH = viewSize.height / renderScale
        return min(mapSize.width / visibleW, mapSize.height / visibleH)
    }

    // MARK: - Terrain

    private func setupTerrain() {
        let centerX = mapSize.width / 2
        let centerY = mapSize.height / 2

        // Single terrain image handled by TerrainBlurHelper (sharp + blurred crossfade)
        terrainBlur.setup(in: self, sharp: zone.sharpTerrainImageName, blurred: zone.blurredTerrainImageName, mapSize: mapSize)
        terrainBlur.terrainSprite?.position = CGPoint(x: centerX, y: centerY)
        terrainBlur.blurredTerrainSprite?.position = CGPoint(x: centerX, y: centerY)

        // Grid lines (Leonardo's notebook style)
        addGridOverlay()
    }

    private func addGridOverlay() {
        // Single combined path for all grid lines — 1 draw call instead of 55
        let combinedPath = CGMutablePath()

        // Vertical lines
        for x in stride(from: 0, through: mapSize.width, by: 100) {
            combinedPath.move(to: CGPoint(x: x, y: 0))
            combinedPath.addLine(to: CGPoint(x: x, y: mapSize.height))
        }

        // Horizontal lines
        for y in stride(from: 0, through: mapSize.height, by: 100) {
            combinedPath.move(to: CGPoint(x: 0, y: y))
            combinedPath.addLine(to: CGPoint(x: mapSize.width, y: y))
        }

        let gridNode = SKShapeNode(path: combinedPath)
        gridNode.strokeColor = PlatformColor(RenaissanceColors.sepiaInk.opacity(0.1))
        gridNode.lineWidth = 1
        gridNode.zPosition = -90
        gridNode.isAntialiased = false  // Crisp 1px lines, no blending blur
        addChild(gridNode)
    }

    // MARK: - Buildings (positions from sketch)

    private func setupBuildings() {
        for building in zone.buildings {
            if hiddenBuildingIds.contains(building.buildingId) { continue }

            let node = BuildingNode(
                buildingId: building.buildingId,
                buildingName: building.name,
                era: building.era
            )
            node.position = building.position
            node.zRotation = building.rotation * .pi / 180  // degrees to radians
            node.zPosition = 10
            addChild(node)
            buildingNodes[building.buildingId] = node
        }
    }

    // MARK: - Decorations (trees, paths)

    private func setupDecorations() {
        for label in zone.labels {
            addZoneLabel(label.numeral, at: label.position, for: label.name, nodeName: label.nodeName)
        }
        for banner in zone.banners {
            addEraBanner(banner)
        }
    }

    private func addEraBanner(_ banner: ZoneBanner) {
        let label = SKLabelNode(text: banner.text)
        label.fontName = "Cinzel-Regular"
        label.fontSize = 32
        label.fontColor = PlatformColor(RenaissanceColors.sepiaInk)
        label.position = banner.position
        label.zPosition = -30
        label.name = banner.nodeName
        addChild(label)
    }

    private func addZoneLabel(_ numeral: String, at position: CGPoint, for name: String, nodeName: String = "") {
        let container = SKNode()
        container.position = position
        container.zPosition = 1
        if !nodeName.isEmpty { container.name = nodeName }

        // Roman numeral
        let numLabel = SKLabelNode(text: numeral)
        numLabel.fontName = "Cinzel-Regular"
        numLabel.fontSize = 36
        numLabel.fontColor = PlatformColor(RenaissanceColors.sepiaInk.opacity(0.4))
        numLabel.position = CGPoint(x: 0, y: 20)
        container.addChild(numLabel)

        // Zone name
        let nameLabel = SKLabelNode(text: name)
        nameLabel.fontName = "EBGaramond-Regular"
        nameLabel.fontSize = 18
        nameLabel.fontColor = PlatformColor(RenaissanceColors.sepiaInk.opacity(0.3))
        nameLabel.position = CGPoint(x: 0, y: -10)
        container.addChild(nameLabel)

        addChild(container)
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

        if let lastLocation = lastPanLocation {
            handleDragTo(location, from: lastLocation)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        #if DEBUG
        if editorMode.handleRelease() { /* fall through to also clear pan */ }
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

        guard let lastLocation = lastPanLocation else { return }
        handleDragTo(location, from: lastLocation)
    }

    override func mouseUp(with event: NSEvent) {
        #if DEBUG
        if editorMode.handleRelease() { /* fall through to also clear pan */ }
        #endif
        lastPanLocation = nil
        hasFiredDragCallback = false
    }

    override func mouseMoved(with event: NSEvent) {
        let location = event.location(in: self)
        lastCursorPosition = location
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
            let clampedScale = max(0.5, min(maxZoomOutScale, newScale))
            cameraNode.setScale(clampedScale)
        }
        clampCamera()
    }

    // Pinch-to-zoom on trackpad
    override func magnify(with event: NSEvent) {
        dismissOverlaysOnInteraction()
        let zoomFactor: CGFloat = 1.0 + event.magnification
        let newScale = cameraNode.xScale / zoomFactor
        let clampedScale = max(0.5, min(maxZoomOutScale, newScale))
        cameraNode.setScale(clampedScale)
        clampCamera()
    }

    override func keyDown(with event: NSEvent) {
        #if DEBUG
        if editorMode.handleKeyDown(event.keyCode) { return }

        // B key: toggle building sprite preview (ghost ↔ complete)
        if event.keyCode == 11 { // B key
            BuildingNode.debugShowAllComplete.toggle()
            let mode = BuildingNode.debugShowAllComplete ? "COMPLETE (full color)" : "GHOST (normal game state)"
            print("🏛 Building preview: \(mode)")
            // Refresh all building nodes
            for (_, node) in buildingNodes {
                node.updateState(node.currentState)
            }
        }
        #endif
    }
    #endif

    // MARK: - Shared Input Logic

    private func handleTapAt(_ location: CGPoint) {
        // Check if a building was tapped
        let tappedNodes = nodes(at: location)
        for node in tappedNodes {
            if let buildingNode = node as? BuildingNode {
                walkPlayerToBuilding(buildingNode)
                return
            }
            // Also check parent (in case we tapped a child node)
            if let buildingNode = node.parent as? BuildingNode {
                walkPlayerToBuilding(buildingNode)
                return
            }
        }

        // Start pan
        lastPanLocation = location
    }

    // MARK: - Pathfinding (Dijkstra on waypoint graph)

    /// Build adjacency list from edge pairs
    private func buildAdjacency() -> [[Int]] {
        var adj = [[Int]](repeating: [], count: waypoints.count)
        for edge in waypointEdges {
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
        let startVirtual = n
        let endVirtual = n + 1
        let totalNodes = n + 2

        var adj = [[(node: Int, dist: CGFloat)]](repeating: [], count: totalNodes)

        // Real waypoint edges
        let baseAdj = buildAdjacency()
        for i in 0..<n {
            for j in baseAdj[i] {
                let d = hypot(waypoints[i].x - waypoints[j].x, waypoints[i].y - waypoints[j].y)
                adj[i].append((j, d))
            }
        }

        // Connect start virtual node
        for wp in startWaypoints {
            let d = hypot(start.x - waypoints[wp].x, start.y - waypoints[wp].y)
            adj[startVirtual].append((wp, d))
            adj[wp].append((startVirtual, d))
        }

        // Connect end virtual node
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

    // MARK: - Walk Player to Building

    /// Tap building → player walks there via waypoints → camera follows → callback when arrived
    private func walkPlayerToBuilding(_ buildingNode: BuildingNode) {
        buildingNode.animateTap()

        // Cancel any current walk
        playerNode.removeAction(forKey: "walkTo")

        // Stop tracking previous building position
        dialogBuildingNode = nil

        // Dismiss any open dialogs immediately
        onPlayerStartedWalking?()

        let buildingPos = buildingNode.position
        let targetPos = CGPoint(x: buildingPos.x - 140, y: buildingPos.y - 75)
        let playerPos = playerNode.position

        isPlayerWalking = true
        view?.preferredFramesPerSecond = 60  // Smooth animation while walking

        // Start camera follow — gentle zoom + gradual approach in update()
        startFollowingPlayer(toward: buildingPos)
        startWalkingTerrainEffects()

        let directDistance = hypot(targetPos.x - playerPos.x, targetPos.y - playerPos.y)

        // If very close, walk directly
        if directDistance < directWalkThreshold {
            let facingRight = targetPos.x > playerPos.x
            playerNode.setFacingDirection(facingRight)
            playerNode.walkTo(destination: targetPos, duration: max(0.3, TimeInterval(directDistance / walkSpeed))) { [weak self] in
                self?.playerArrivedAtBuilding(buildingNode)
            }
            return
        }

        // Get waypoints for start and end
        let startWPs = nearestWaypoints(to: playerPos)
        let endWPs = buildingWaypoints[buildingNode.buildingId] ?? nearestWaypoints(to: targetPos)

        let path = findPath(from: playerPos, to: targetPos, startWaypoints: startWPs, endWaypoints: endWPs)

        guard !path.isEmpty else {
            let facingRight = targetPos.x > playerPos.x
            playerNode.setFacingDirection(facingRight)
            playerNode.walkTo(destination: targetPos, duration: max(0.5, TimeInterval(directDistance / walkSpeed))) { [weak self] in
                self?.playerArrivedAtBuilding(buildingNode)
            }
            return
        }

        let firstTarget = path[0]
        playerNode.setFacingDirection(firstTarget.x > playerPos.x)

        playerNode.walkPath(path, speed: walkSpeed) { [weak self] in
            self?.playerArrivedAtBuilding(buildingNode)
        }
    }

    /// Called when player finishes walking to a building
    private func playerArrivedAtBuilding(_ buildingNode: BuildingNode) {
        isPlayerWalking = false
        isFollowingPlayer = false
        walkTargetPosition = nil
        view?.preferredFramesPerSecond = 30  // Back to idle frame rate

        // Keep blur active while zoomed in near the building

        // Face forward (toward camera) now that she's arrived
        playerNode.faceForward()

        // Zoom camera to the building
        zoomCameraToBuilding(buildingNode.position)

        // Start tracking this building's screen position every frame
        dialogBuildingNode = buildingNode

        // Notify SwiftUI — bird dialogue appears
        onMascotReachedBuilding?(buildingNode.buildingId)
    }

    // MARK: - Terrain Effects

    /// Walking terrain effects — zoom-based swap in update() handles the actual terrain switch
    private func startWalkingTerrainEffects() {
        // Handled by update() loop based on camera zoom level
    }

    private func stopWalkingTerrainEffects() {
        // Handled by update() loop based on camera zoom level
    }

    // MARK: - Camera Follow & Zoom

    /// Start following player — front-load the zoom to close-zoom in 0.5s so
    /// clamp can't pull the camera off edge stations during the walk. The
    /// previous approach (gentle 0.8 zoom + gradual 0.8→0.55 in update())
    /// kept visible area too large during the walk, causing visible "shifts"
    /// at edge stations when clamp engaged.
    private func startFollowingPlayer(toward target: CGPoint) {
        guard let cameraNode = cameraNode else { return }
        isFollowingPlayer = true
        walkTargetPosition = target

        let zoomAction = SKAction.scale(to: 0.6, duration: 0.5)
        zoomAction.timingMode = .easeInEaseOut
        cameraNode.run(zoomAction, withKey: "cameraZoom")
    }

    /// Settle camera on the building after player arrives — pan only, no zoom change.
    /// The move target is clamped to the camera's allowed range so edge buildings
    /// (Glassworks, Pantheon, Printing Press, Harbor) don't pan the camera past
    /// map bounds, which would expose the parchment background around the terrain.
    private func zoomCameraToBuilding(_ buildingPos: CGPoint) {
        guard let cameraNode = cameraNode else { return }
        let clampedTarget = clampedPosition(for: buildingPos)
        let moveAction = SKAction.move(to: clampedTarget, duration: 0.5)
        moveAction.timingMode = .easeInEaseOut
        cameraNode.run(moveAction, withKey: "cameraZoom")
    }

    /// Pan back to map center when overlay/dialogue dismisses — preserves zoom.
    func zoomCameraOut() {
        guard let cameraNode = cameraNode else { return }
        isFollowingPlayer = false
        walkTargetPosition = nil
        dialogBuildingNode = nil

        // Remove blur + walking terrain when player exits a building
        stopWalkingTerrainEffects()

        view?.preferredFramesPerSecond = 60  // Smooth pan animation

        let mapCenter = CGPoint(x: mapSize.width / 2, y: mapSize.height / 2)
        let moveAction = SKAction.move(to: mapCenter, duration: 0.6)
        moveAction.timingMode = .easeInEaseOut

        let idleAfter = SKAction.run { [weak self] in self?.view?.preferredFramesPerSecond = 30 }
        cameraNode.run(SKAction.sequence([moveAction, idleAfter]), withKey: "cameraZoom")
    }

    /// Reset internal state only — does NOT zoom the camera.
    /// Camera stays where it is so bird guidance can appear without jarring zoom-out.
    func resetMascot() {
        isFollowingPlayer = false
        walkTargetPosition = nil
        dialogBuildingNode = nil
        stopWalkingTerrainEffects()
    }

    private var hasFiredDragCallback = false

    private func handleDragTo(_ location: CGPoint, from lastLocation: CGPoint) {
        // Dismiss all dialogs when user drags the map
        if !hasFiredDragCallback {
            hasFiredDragCallback = true
            dialogBuildingNode = nil
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

    // MARK: - Camera Control

    /// Where the camera *can* be while looking at `target`, given the current
    /// scale and view bounds. Used by the walk-follow lerp so we lerp toward
    /// a reachable position instead of toward `playerNode.position` (which
    /// for edge stations is outside the allowed range — clamp would slam the
    /// camera back to bounds every frame, creating the visible "shift").
    private func clampedPosition(for target: CGPoint) -> CGPoint {
        let scale = cameraNode.xScale
        let viewSize = view?.bounds.size ?? CGSize(width: 1024, height: 768)
        let renderScale = max(viewSize.width / self.size.width,
                              viewSize.height / self.size.height)
        let visibleWidth = (viewSize.width / renderScale) * scale
        let visibleHeight = (viewSize.height / renderScale) * scale

        let minX = visibleWidth / 2
        let maxX = mapSize.width - (visibleWidth / 2)
        let minY = visibleHeight / 2
        let maxY = mapSize.height - (visibleHeight / 2)

        let clampedX = maxX > minX ? max(minX, min(maxX, target.x)) : mapSize.width / 2
        let clampedY = maxY > minY ? max(minY, min(maxY, target.y)) : mapSize.height / 2
        return CGPoint(x: clampedX, y: clampedY)
    }

    private func clampCamera() {
        // Keep maxZoomOutScale in sync with the current view size so the
        // student can't zoom out past the point where terrain fills the
        // screen. Uses the same .aspectFill render-scale math as the
        // initial fit.
        if let fit = computeFitScale() {
            maxZoomOutScale = fit
        }

        // Clamp SCALE first — prevents SKActions from overshooting
        // maxZoomOutScale which causes terrain edges to flash visible
        // for 1-2 frames during zoom-out.
        let clampedScale = max(0.5, min(maxZoomOutScale, cameraNode.xScale))
        if cameraNode.xScale != clampedScale {
            cameraNode.setScale(clampedScale)
        }

        let scale = cameraNode.xScale
        let viewSize = view?.bounds.size ?? CGSize(width: 1024, height: 768)

        // For .aspectFill, visible area in SCENE coordinates is
        // viewSize / renderScale. Multiplying by scale gives the area
        // visible at the current camera zoom. This is the same formula
        // WorkshopScene uses — without it the clamp limits are in
        // view-pixel space which doesn't match the scene coord space,
        // so panning exposes parchment at the edges.
        let renderScale = max(viewSize.width / self.size.width,
                              viewSize.height / self.size.height)
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
        dismissOverlaysOnInteraction()
        let zoomFactor: CGFloat = 1.0 - (deltaY * 0.05)
        let newScale = cameraNode.xScale * zoomFactor
        let clampedScale = max(0.5, min(maxZoomOutScale, newScale))
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
        let clampedScale = max(0.5, min(maxZoomOutScale, newScale))
        cameraNode.setScale(clampedScale)
        clampCamera()
    }

    /// Dismiss SwiftUI overlays on any map interaction (scroll, pan, zoom, drag).
    /// Only fires the callback if there's actually a dialog to dismiss, preventing
    /// redundant SwiftUI state changes on every gesture tick (which cause flicker).
    private func dismissOverlaysOnInteraction() {
        guard dialogBuildingNode != nil else { return }
        dialogBuildingNode = nil
        onPlayerStartedWalking?()
    }

    // MARK: - Public Methods

    func focusOnBuilding(_ buildingId: String) {
        guard let node = buildingNodes[buildingId] else { return }

        let moveAction = SKAction.move(to: node.position, duration: 0.5)
        moveAction.timingMode = .easeInEaseOut

        let zoomAction = SKAction.scale(to: 1.0, duration: 0.5)
        zoomAction.timingMode = .easeInEaseOut

        cameraNode.run(SKAction.group([moveAction, zoomAction]))
    }

    func updateBuildingState(_ buildingId: String, state: BuildingState) {
        buildingNodes[buildingId]?.updateState(state)
    }

    // MARK: - Swaying Trees
    //
    // Mirrors WorkshopScene.setupSwayingTrees — same warp-grid two-layer wind
    // animation, registered with editor mode for drag-positioning.
    // Which trees a map has is zone data (`zone.trees`); the sway animation
    // below is not. Rome's set is CityTree22..CityTree30, which bypasses the
    // workshop's Tree1..Tree9 namespace so there's no collision. CityTree02..21
    // were cut from the previous terrain and are no longer placed; their
    // imagesets are still in Assets.xcassets.

    private func setupSwayingTrees() {
        // Cut-outs lifted from this zone's own terrain art, each placed back on
        // the hole it came from, at the scale that makes it cover its own
        // footprint. Positions were recovered by template-matching each PNG
        // against the terrain.
        for tree in zone.trees {
            addSwayingTree(image: tree.imageName, position: tree.position, scale: tree.scale)
        }
    }

    private func addSwayingTree(image: String, position: CGPoint, scale: CGFloat = 1.0) {
        // Skip silently if the imageset isn't present — keeps this idempotent.
        #if os(iOS)
        guard UIImage(named: image) != nil else { return }
        #else
        guard NSImage(named: image) != nil else { return }
        #endif

        let tree = SKSpriteNode(imageNamed: image)
        tree.anchorPoint = CGPoint(x: 0.5, y: 0.0)  // pivot at trunk base
        tree.position = position
        tree.setScale(scale)
        // IN FRONT of the building artwork, which lands at effective z 11 — SpriteKit
        // ACCUMULATES zPosition down the tree, so BuildingNode (10) + its visualContainer
        // (1) = 11, not 10. A tree at 11 ties with it and `.ignoresSiblingOrder` breaks
        // the tie arbitrarily, which reads as "still behind".
        // 11.5 clears the artwork but stays under the dark tint (12) and dark-mode glow
        // (13), so trees dim with everything else at night, and well under the lock (25),
        // state badge (30), pill label (35) and apprentice (50).
        tree.zPosition = 11.5
        tree.name = image
        addChild(tree)

        // Top-only wind sway via per-vertex warp. Bottom row stays anchored
        // (trunk doesn't move), higher rows lean proportionally more — y² weight
        // accentuates the canopy tip while the mid-trunk barely shifts.
        let cols = 1
        let rows = 3
        let src: [SIMD2<Float>] = [
            SIMD2(0, 0),    SIMD2(1, 0),
            SIMD2(0, 0.33), SIMD2(1, 0.33),
            SIMD2(0, 0.66), SIMD2(1, 0.66),
            SIMD2(0, 1),    SIMD2(1, 1)
        ]
        func lean(_ amp: Float) -> [SIMD2<Float>] {
            return src.map { p in
                let yWeight = p.y * p.y
                return SIMD2(p.x + amp * yWeight, p.y)
            }
        }
        let amp: Float = 0.10
        let baseGrid  = SKWarpGeometryGrid(columns: cols, rows: rows,
                                           sourcePositions: src,
                                           destinationPositions: src)
        let leftGrid  = SKWarpGeometryGrid(columns: cols, rows: rows,
                                           sourcePositions: src,
                                           destinationPositions: lean(-amp))
        let rightGrid = SKWarpGeometryGrid(columns: cols, rows: rows,
                                           sourcePositions: src,
                                           destinationPositions: lean(amp))

        tree.warpGeometry = baseGrid

        let duration = Double.random(in: 1.6...2.4)
        let phase = Double.random(in: 0...duration)

        guard let toRight = SKAction.warp(to: rightGrid, duration: duration),
              let toLeft  = SKAction.warp(to: leftGrid,  duration: duration)
        else { return }
        toRight.timingMode = .easeInEaseOut
        toLeft.timingMode  = .easeInEaseOut

        let cycle = SKAction.sequence([toRight, toLeft])
        tree.run(SKAction.sequence([
            SKAction.wait(forDuration: phase),
            SKAction.repeatForever(cycle)
        ]), withKey: "windWarp")

        swayingTrees.append(SwayingTree(node: tree))
    }

    /// Called from update(_:). O(n) — n = 9 trees.
    private func disturbTreesNearPlayer() {
        guard !swayingTrees.isEmpty, playerNode != nil else { return }
        let triggerRadius: CGFloat = 150
        let now = CACurrentMediaTime()
        for i in swayingTrees.indices {
            let dx = swayingTrees[i].node.position.x - playerNode.position.x
            let dy = swayingTrees[i].node.position.y - playerNode.position.y
            let dist = hypot(dx, dy)
            if dist < triggerRadius && now - swayingTrees[i].lastDisturbed > 2.0 {
                let strong = SKAction.sequence([
                    SKAction.rotate(byAngle:  .pi / 30, duration: 0.4),
                    SKAction.rotate(byAngle: -.pi / 15, duration: 0.6),
                    SKAction.rotate(byAngle:  .pi / 30, duration: 0.4)
                ])
                strong.timingMode = .easeInEaseOut
                swayingTrees[i].node.run(strong, withKey: "treeDisturbance")
                swayingTrees[i].lastDisturbed = now
            }
        }
    }

    // MARK: - Editor Mode (DEBUG only)

    #if DEBUG
    private func registerEditorNodes() {
        // Buildings
        for (id, node) in buildingNodes {
            editorMode.registerNode(node, name: "building_\(id)")
        }

        // Swaying trees (zone.trees — CityTree22..CityTree30 on Rome)
        for entry in swayingTrees {
            editorMode.registerNode(entry.node, name: entry.node.name ?? "citytree")
        }

        // Trees (named tree_0, tree_1, etc. in setupDecorations)
        for child in children where child.name?.hasPrefix("tree_") == true {
            editorMode.registerNode(child, name: child.name!)
        }

        // Zone labels
        for child in children where child.name?.hasPrefix("zone_") == true {
            editorMode.registerNode(child, name: child.name!)
        }

        // Era labels
        for child in children where child.name?.hasPrefix("label_") == true {
            editorMode.registerNode(child, name: child.name!)
        }
    }
    #endif
}
