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
class CraftingRoomScene: SKScene {

    // MARK: - Properties

    private var cameraNode: SKCameraNode!
    private var playerNode: PlayerNode!
    private var furnitureNodes: [CraftingStation: SKSpriteNode] = [:]

    // Camera control
    private var lastPanLocation: CGPoint?

    // Map size — matches all scenes' 3500x2500 standard
    private let mapSize = CGSize(width: 3500, height: 2500)

    #if DEBUG
    private lazy var editorMode = SceneEditorMode(scene: self)
    #endif

    // Furniture positions in 3500x2500 coordinate space
    private let furniturePositions: [CraftingStation: CGPoint] = [
        .workbench:    CGPoint(x: 875,  y: 1500),
        .furnace:      CGPoint(x: 2520, y: 1125),
        .pigmentTable: CGPoint(x: 1680, y: 1625),
        .shelf:        CGPoint(x: 2975, y: 875),
    ]

    /// Sprite display size for furniture images
    private let furnitureSpriteSize = CGSize(width: 500, height: 500)

    // MARK: - Waypoint Graph (simple indoor paths)

    private var waypoints: [CGPoint] = [
        /* 0  */ CGPoint(x: 1750, y: 2200),   // door (player spawn)
        /* 1  */ CGPoint(x: 1750, y: 1800),   // bottom-center
        /* 2  */ CGPoint(x: 1300, y: 1550),   // center-left
        /* 3  */ CGPoint(x: 1750, y: 1400),   // center
        /* 4  */ CGPoint(x: 2200, y: 1350),   // center-right
        /* 5  */ CGPoint(x: 875,  y: 1500),   // workbench
        /* 6  */ CGPoint(x: 1680, y: 1625),   // pigment table
        /* 7  */ CGPoint(x: 2520, y: 1125),   // furnace
        /* 8  */ CGPoint(x: 2975, y: 875),    // shelf
        /* 9  */ CGPoint(x: 2600, y: 1400),   // right connector
        /* 10 */ CGPoint(x: 1100, y: 1700),   // left connector
    ]

    private let waypointEdges: [[Int]] = [
        // Door → bottom center
        [0, 1],
        // Bottom center → branches
        [1, 2], [1, 3], [1, 6], [1, 10],
        // Center connections
        [2, 3], [2, 5], [2, 10],
        [3, 4], [3, 6],
        // Right side
        [4, 7], [4, 9],
        [9, 7], [9, 8],
        [7, 8],
        // Left side
        [10, 5], [10, 6],
        // Cross links
        [6, 3], [5, 10],
    ]

    /// Which waypoints each station connects to
    private let stationWaypoints: [CraftingStation: [Int]] = [
        .workbench:    [5, 2, 10],
        .furnace:      [7, 4, 9],
        .pigmentTable: [6, 1, 3],
        .shelf:        [8, 9, 7],
    ]

    // MARK: - Callbacks to SwiftUI

    var onFurnitureReached: ((CraftingStation) -> Void)?
    var onPlayerPositionChanged: ((CGPoint, Bool) -> Void)?

    // MARK: - Scene Setup

    override func didMove(to view: SKView) {
        backgroundColor = PlatformColor(RenaissanceColors.parchment)

        setupCamera()
        setupBackground()
        setupGridLines()
        setupTitle()
        setupFurniture()
        setupPlayer()

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
        let s = self.size
        guard s.width > 0 && s.height > 0 else { return }
        let fitScale = max(mapSize.width / s.width, mapSize.height / s.height)
        cameraNode.setScale(fitScale)
    }

    // MARK: - Background

    private func setupBackground() {
        let terrainTexture = SKTexture(imageNamed: "WorkshopBackground")
        let terrain = SKSpriteNode(texture: terrainTexture)
        terrain.size = mapSize
        terrain.position = CGPoint(x: mapSize.width / 2, y: mapSize.height / 2)
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

            let texture = SKTexture(imageNamed: station.imageName)
            let sprite = SKSpriteNode(texture: texture)
            sprite.size = furnitureSpriteSize
            sprite.position = pos
            sprite.zPosition = 10
            sprite.name = "furniture_\(station.rawValue)"
            addChild(sprite)
            furnitureNodes[station] = sprite

            // Label below furniture
            let label = SKLabelNode(text: station.displayName)
            label.fontName = "Cinzel-Regular"
            label.fontSize = 36
            label.fontColor = PlatformColor(RenaissanceColors.sepiaInk)
            label.position = CGPoint(x: 0, y: -(furnitureSpriteSize.height / 2) - 50)
            label.zPosition = 11
            sprite.addChild(label)

            // Subtle pulse animation
            let scaleUp = SKAction.scale(to: 1.03, duration: 1.5)
            scaleUp.timingMode = .easeInEaseOut
            let scaleDown = SKAction.scale(to: 1.0, duration: 1.5)
            scaleDown.timingMode = .easeInEaseOut
            sprite.run(SKAction.repeatForever(SKAction.sequence([scaleUp, scaleDown])), withKey: "pulse")
        }
    }

    // MARK: - Player

    private func setupPlayer() {
        playerNode = PlayerNode()
        // Spawn at door position (bottom center)
        playerNode.position = waypoints[0]
        playerNode.zPosition = 50
        addChild(playerNode)
        updatePlayerScreenPosition()
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

    override func update(_ currentTime: TimeInterval) {
        updatePlayerScreenPosition()
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

    override func scrollWheel(with event: NSEvent) {
        if event.modifierFlags.contains(.option) {
            let zoomFactor: CGFloat = 1.0 - (event.deltaY * 0.05)
            let newScale = cameraNode.xScale * zoomFactor
            let clampedScale = max(0.5, min(3.5, newScale))
            cameraNode.setScale(clampedScale)
        } else {
            let scale = cameraNode.xScale
            cameraNode.position.x -= event.deltaX * scale * 2
            cameraNode.position.y += event.deltaY * scale * 2
        }
        clampCamera()
    }

    override func magnify(with event: NSEvent) {
        let zoomFactor: CGFloat = 1.0 + event.magnification
        let newScale = cameraNode.xScale / zoomFactor
        let clampedScale = max(0.5, min(3.5, newScale))
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
        let targetPos = CGPoint(x: stationPos.x - 140, y: stationPos.y - 75)
        let playerPos = playerNode.position

        // If very close, walk directly
        let directDistance = hypot(targetPos.x - playerPos.x, targetPos.y - playerPos.y)
        if directDistance < 350 {
            let facingRight = targetPos.x > playerPos.x
            playerNode.setFacingDirection(facingRight)
            playerNode.walkTo(destination: targetPos, duration: max(0.3, TimeInterval(directDistance / 467))) { [weak self] in
                self?.onFurnitureReached?(station)
            }
            return
        }

        let startWPs = nearestWaypoints(to: playerPos)
        let endWPs = stationWaypoints[station] ?? nearestWaypoints(to: targetPos)

        let path = findPath(from: playerPos, to: targetPos, startWaypoints: startWPs, endWaypoints: endWPs)

        guard !path.isEmpty else {
            let facingRight = targetPos.x > playerPos.x
            playerNode.setFacingDirection(facingRight)
            playerNode.walkTo(destination: targetPos, duration: max(0.5, TimeInterval(directDistance / 467))) { [weak self] in
                self?.onFurnitureReached?(station)
            }
            return
        }

        let firstTarget = path[0]
        let facingRight = firstTarget.x > playerPos.x
        playerNode.setFacingDirection(facingRight)

        playerNode.walkPath(path, speed: 467) { [weak self] in
            self?.onFurnitureReached?(station)
        }
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
        let scale = cameraNode.xScale
        let viewSize = view?.bounds.size ?? CGSize(width: 1024, height: 768)

        let padding: CGFloat = 200
        let visibleWidth = viewSize.width * scale
        let visibleHeight = viewSize.height * scale

        let minX = (visibleWidth / 2) - padding
        let maxX = mapSize.width - (visibleWidth / 2) + padding
        let minY = (visibleHeight / 2) - padding
        let maxY = mapSize.height - (visibleHeight / 2) + padding

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
        let clampedScale = max(0.5, min(3.5, newScale))
        cameraNode.setScale(clampedScale)
        clampCamera()
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
