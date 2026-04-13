import SpriteKit
import SwiftUI

/// Goldsmith station types inside the Bottega di Lotti
enum GoldsmithStation: String, CaseIterable, Hashable {
    case engravingBench = "Engraving Bench"
    case castingStation = "Casting Station"
    case goldsmithFurnace = "Goldsmith Furnace"
    case polishingWheel = "Polishing Wheel"

    var imageName: String {
        switch self {
        case .engravingBench:   return "InteriorEngravingBench"
        case .castingStation:   return "InteriorCastingStation"
        case .goldsmithFurnace: return "InteriorGoldsmithFurnace"
        case .polishingWheel:   return "InteriorPolishingWheel"
        }
    }

    var displayName: String { rawValue }

    var italianName: String {
        switch self {
        case .engravingBench:   return "il Banco dell'Incisore"
        case .castingStation:   return "la Fonderia"
        case .goldsmithFurnace: return "la Fornace dell'Orefice"
        case .polishingWheel:   return "la Ruota del Lucidatore"
        }
    }

    var educationalText: String {
        switch self {
        case .engravingBench:
            return "Goldsmiths engraved silver using the niello technique — cutting grooves into metal, then filling them with a black mixture of sulfur, lead, and copper. The contrast made intricate designs visible. Brunelleschi mastered this skill as an apprentice."
        case .castingStation:
            return "Lost-wax casting (cera persa) was the goldsmith's greatest technique. Sculpt in beeswax, coat in clay mixed with letame and charred ox horn, melt out the wax, pour in molten bronze. The organic fibers prevent the mold from shattering at 1100°C."
        case .goldsmithFurnace:
            return "Goldsmith furnaces burned for days — even in summer heat. The large furnaces needed to melt gold, copper, and bronze polluted the air with smoke and brought the danger of explosions and fire. Most were found in Florence's Santa Croce district."
        case .polishingWheel:
            return "After casting, bronze and gold objects were polished on rotating wheels using progressively finer abrasives — sand, pumice, then ox-bone ash. A master goldsmith could achieve a mirror finish that lasted centuries."
        }
    }
}

/// SpriteKit scene for the Goldsmith Workshop interior (Bottega di Benincasa Lotti)
/// Apprentice walks between goldsmith stations: Engraving Bench, Casting Station, Furnace, Polishing Wheel
class GoldsmithScene: SKScene, ScrollZoomable {

    // MARK: - Properties

    private var cameraNode: SKCameraNode!
    private var playerNode: PlayerNode!
    private var furnitureNodes: [GoldsmithStation: SKSpriteNode] = [:]

    /// Player gender — set from SwiftUI before scene appears
    var apprenticeIsBoy: Bool = true

    // Camera control
    private var lastPanLocation: CGPoint?
    private var maxZoomOutScale: CGFloat = 1.0

    // Map size — matches all scenes' 3500x2500 standard
    private let mapSize = CGSize(width: 3500, height: 2500)

    #if DEBUG
    private lazy var editorMode = SceneEditorMode(scene: self)

    func toggleEditorMode() { editorMode.toggle() }
    var isEditorActive: Bool { editorMode.isActive }
    func editorRotateLeft() { editorMode.rotateLeft() }
    func editorRotateRight() { editorMode.rotateRight() }
    func editorNudge(dx: CGFloat, dy: CGFloat) { editorMode.nudge(dx: dx, dy: dy) }
    #endif

    // Furniture positions in 3500x2500 coordinate space
    private let furniturePositions: [GoldsmithStation: CGPoint] = [
        .engravingBench:   CGPoint(x: 600,  y: 900),
        .castingStation:   CGPoint(x: 2800, y: 900),
        .goldsmithFurnace: CGPoint(x: 2800, y: 1600),
        .polishingWheel:   CGPoint(x: 600,  y: 1600),
    ]

    /// Sprite display size for furniture (will use shapes as fallback until Midjourney assets)
    private let furnitureSpriteSize = CGSize(width: 760, height: 760)

    // MARK: - Waypoint Graph (indoor paths)

    private var waypoints: [CGPoint] = [
        /* 0  */ CGPoint(x: 1750, y: 400),    // door (player spawn)
        /* 1  */ CGPoint(x: 1750, y: 800),    // center-bottom
        /* 2  */ CGPoint(x: 1750, y: 1250),   // center
        /* 3  */ CGPoint(x: 1750, y: 1700),   // center-top
        /* 4  */ CGPoint(x: 900,  y: 800),    // left-bottom (engraving)
        /* 5  */ CGPoint(x: 900,  y: 1250),   // left-center
        /* 6  */ CGPoint(x: 900,  y: 1700),   // left-top (polishing)
        /* 7  */ CGPoint(x: 2600, y: 800),    // right-bottom (casting)
        /* 8  */ CGPoint(x: 2600, y: 1250),   // right-center
        /* 9  */ CGPoint(x: 2600, y: 1700),   // right-top (furnace)
        // --- Home: avatar box (bottom-left corner) ---
        /* 10 */ CGPoint(x: 200,  y: 200),    // avatar box spawn
    ]

    private let waypointEdges: [[Int]] = [
        // Vertical spine
        [0, 1], [1, 2], [2, 3],
        // Left column
        [4, 5], [5, 6],
        // Right column
        [7, 8], [8, 9],
        // Cross connections
        [1, 4], [1, 7],
        [2, 5], [2, 8],
        [3, 6], [3, 9],
        // Diagonals
        [4, 2], [7, 2],
        [5, 3], [8, 3],
        // Avatar box connections
        [10, 0], [10, 1], [10, 4],
    ]

    /// Which waypoints each station connects to
    private let stationWaypoints: [GoldsmithStation: [Int]] = [
        .engravingBench:   [4, 1, 5],
        .castingStation:   [7, 1, 8],
        .goldsmithFurnace: [9, 8, 3],
        .polishingWheel:   [6, 5, 3],
    ]

    // MARK: - Callbacks to SwiftUI

    var onFurnitureReached: ((GoldsmithStation) -> Void)?
    var onPlayerPositionChanged: ((CGPoint, Bool) -> Void)?
    var onPlayerStartedWalking: (() -> Void)?

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
        let fitScale = min(mapSize.width / visibleW, mapSize.height / visibleH)
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

        // Use WorkshopBackground as placeholder until dedicated goldsmith interior
        let terrainTexture = SKTexture(imageNamed: "WorkshopBackground")
        let terrain = SKSpriteNode(texture: terrainTexture)
        terrain.size = mapSize
        terrain.position = center
        terrain.zPosition = -100
        addChild(terrain)
    }

    // MARK: - Grid Lines

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
        let title = SKLabelNode(text: "BOTTEGA DI LOTTI")
        title.fontName = "Cinzel-Regular"
        title.fontSize = 28
        title.fontColor = PlatformColor(RenaissanceColors.sepiaInk.opacity(0.4))
        title.position = CGPoint(x: mapSize.width / 2, y: mapSize.height - 50)
        title.zPosition = -80
        addChild(title)

        let subtitle = SKLabelNode(text: "Goldsmith Workshop — Santa Croce, Florence")
        subtitle.fontName = "EBGaramond-Italic"
        subtitle.fontSize = 20
        subtitle.fontColor = PlatformColor(RenaissanceColors.sepiaInk.opacity(0.3))
        subtitle.position = CGPoint(x: mapSize.width / 2, y: mapSize.height - 85)
        subtitle.zPosition = -80
        addChild(subtitle)
    }

    // MARK: - Furniture Stations

    private func setupFurniture() {
        for station in GoldsmithStation.allCases {
            guard let pos = furniturePositions[station] else { continue }

            // Try image sprite first, fall back to shape
            let sprite: SKSpriteNode
            let texture = SKTexture(imageNamed: station.imageName)
            // Check if texture loaded (non-placeholder)
            if texture.size().width > 16 {
                sprite = SKSpriteNode(texture: texture)
            } else {
                // Fallback: create a shape-based placeholder
                sprite = createFurniturePlaceholder(for: station)
            }

            sprite.size = furnitureSpriteSize
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

            // Subtle pulse animation
            let scaleUp = SKAction.scale(to: 1.03, duration: 1.5)
            scaleUp.timingMode = .easeInEaseOut
            let scaleDown = SKAction.scale(to: 1.0, duration: 1.5)
            scaleDown.timingMode = .easeInEaseOut
            sprite.run(SKAction.repeatForever(SKAction.sequence([scaleUp, scaleDown])), withKey: "pulse")
        }
    }

    /// Create a da Vinci sketch placeholder for goldsmith furniture
    private func createFurniturePlaceholder(for station: GoldsmithStation) -> SKSpriteNode {
        let container = SKSpriteNode(color: .clear, size: furnitureSpriteSize)

        let shape: SKShapeNode
        let strokeColor = PlatformColor(RenaissanceColors.sepiaInk)

        switch station {
        case .engravingBench:
            // Table with burin tool
            let path = CGMutablePath()
            path.addRect(CGRect(x: -120, y: -40, width: 240, height: 60))
            path.move(to: CGPoint(x: -80, y: -40))
            path.addLine(to: CGPoint(x: -80, y: -100))
            path.move(to: CGPoint(x: 80, y: -40))
            path.addLine(to: CGPoint(x: 80, y: -100))
            // Burin (engraving tool)
            path.move(to: CGPoint(x: -40, y: 20))
            path.addLine(to: CGPoint(x: 60, y: 80))
            shape = SKShapeNode(path: path)
            shape.fillColor = PlatformColor(RenaissanceColors.warmBrown.opacity(0.3))

        case .castingStation:
            // Crucible + mold shape
            let path = CGMutablePath()
            // Crucible (cone shape)
            path.move(to: CGPoint(x: -60, y: -80))
            path.addLine(to: CGPoint(x: -40, y: 60))
            path.addLine(to: CGPoint(x: 40, y: 60))
            path.addLine(to: CGPoint(x: 60, y: -80))
            path.closeSubpath()
            // Mold (rectangle with opening)
            path.addRect(CGRect(x: 80, y: -60, width: 80, height: 100))
            shape = SKShapeNode(path: path)
            shape.fillColor = PlatformColor(RenaissanceColors.stoneGray.opacity(0.3))

        case .goldsmithFurnace:
            // Large furnace (similar to crafting room but bigger)
            let path = CGMutablePath()
            path.move(to: CGPoint(x: -100, y: -80))
            path.addLine(to: CGPoint(x: -70, y: 80))
            path.addLine(to: CGPoint(x: 70, y: 80))
            path.addLine(to: CGPoint(x: 100, y: -80))
            path.closeSubpath()
            path.addRect(CGRect(x: 20, y: 80, width: 40, height: 60))
            // Fire glow
            path.addRect(CGRect(x: -40, y: -60, width: 80, height: 50))
            shape = SKShapeNode(path: path)
            shape.fillColor = PlatformColor(RenaissanceColors.terracotta.opacity(0.35))

        case .polishingWheel:
            // Circular wheel + stand
            let path = CGMutablePath()
            path.addEllipse(in: CGRect(x: -60, y: -20, width: 120, height: 120))
            // Stand
            path.move(to: CGPoint(x: -40, y: -20))
            path.addLine(to: CGPoint(x: -60, y: -100))
            path.move(to: CGPoint(x: 40, y: -20))
            path.addLine(to: CGPoint(x: 60, y: -100))
            // Axle
            path.move(to: CGPoint(x: -80, y: 40))
            path.addLine(to: CGPoint(x: 80, y: 40))
            shape = SKShapeNode(path: path)
            shape.fillColor = PlatformColor(RenaissanceColors.stoneGray.opacity(0.25))
        }

        shape.strokeColor = strokeColor
        shape.lineWidth = 4
        container.addChild(shape)
        return container
    }

    // MARK: - Player

    private func setupPlayer() {
        playerNode = PlayerNode(isBoy: apprenticeIsBoy)
        playerNode.zPosition = 50
        playerNode.setScale(5.0)
        addChild(playerNode)
        playerNode.position = waypoints[10]
        updatePlayerScreenPosition()
    }

    func positionPlayerAtAvatarBox() {
        playerNode.position = waypoints[10]
        updatePlayerScreenPosition()
    }

    func showPlayer() { }

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

    override func scrollWheel(with event: NSEvent) {
        if event.modifierFlags.contains(.option) {
            let scale = cameraNode.xScale
            cameraNode.position.x -= event.deltaX * scale * 2
            cameraNode.position.y += event.deltaY * scale * 2
        } else {
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
        let tappedNodes = nodes(at: location)
        for node in tappedNodes {
            if let station = stationFor(node: node) {
                onPlayerStartedWalking?()
                walkPlayerToStation(station)
                return
            }
        }
        lastPanLocation = location
    }

    private func stationFor(node: SKNode) -> GoldsmithStation? {
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

    private func walkPlayerToStation(_ station: GoldsmithStation) {
        guard let sprite = furnitureNodes[station] else { return }

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
        let targetPos = CGPoint(x: stationPos.x - 200, y: stationPos.y - 65)
        let playerPos = playerNode.position

        let onArrival: () -> Void = { [weak self] in
            let faceRight = stationPos.x > (self?.playerNode.position.x ?? 0)
            self?.playerNode.setFacingDirection(faceRight)
            self?.onFurnitureReached?(station)
        }

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

    func handleScrollZoom(deltaY: CGFloat) {
        guard cameraNode != nil else { return }
        let zoomFactor: CGFloat = 1.0 - (deltaY * 0.05)
        let newScale = cameraNode.xScale * zoomFactor
        let clampedScale = max(0.5, min(maxZoomOutScale, newScale))
        cameraNode.setScale(clampedScale)
        clampCamera()
    }

    func handleScrollPan(deltaX: CGFloat, deltaY: CGFloat) {
        guard cameraNode != nil else { return }
        let scale = cameraNode.xScale
        cameraNode.position.x -= deltaX * scale * 2
        cameraNode.position.y += deltaY * scale * 2
        clampCamera()
    }

    func handleMagnify(magnification: CGFloat) {
        guard cameraNode != nil else { return }
        let zoomFactor: CGFloat = 1.0 + magnification
        let newScale = cameraNode.xScale / zoomFactor
        let clampedScale = max(0.5, min(maxZoomOutScale, newScale))
        cameraNode.setScale(clampedScale)
        clampCamera()
    }

    // MARK: - Public Animation Methods

    func playPlayerCollectAnimation(completion: (() -> Void)? = nil) {
        guard playerNode != nil else { completion?(); return }
        playerNode.playCollectAnimation(completion: completion)
    }

    func playPlayerCelebrateAnimation(completion: (() -> Void)? = nil) {
        guard playerNode != nil else { completion?(); return }
        playerNode.playCelebrateAnimation(completion: completion)
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
        print("\n// ========== GOLDSMITH POSITIONS ==========")
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
        print("// ==========================================\n")
    }
    #endif
}
