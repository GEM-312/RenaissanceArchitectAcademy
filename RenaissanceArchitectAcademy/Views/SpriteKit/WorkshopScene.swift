import SpriteKit
import SwiftUI

/// SpriteKit scene for Leonardo's Workshop mini-game
/// Player walks between resource stations to collect materials, then crafts at workbench/furnace
class WorkshopScene: SKScene {

    // MARK: - Properties

    private var cameraNode: SKCameraNode!
    private var playerNode: PlayerNode!
    private var resourceNodes: [ResourceStationType: ResourceNode] = [:]

    // Camera control
    private var lastPanLocation: CGPoint?

    // Map size (smaller than city's 3500×2500)
    private let mapSize = CGSize(width: 1500, height: 1000)

    #if DEBUG
    private lazy var editorMode = SceneEditorMode(scene: self)
    #endif

    // Station positions — resources ring edges, crafting at center
    private let stationPositions: [ResourceStationType: CGPoint] = [
        .quarry:       CGPoint(x: 200,  y: 850),
        .river:        CGPoint(x: 500,  y: 900),
        .volcano:      CGPoint(x: 850,  y: 880),
        .clayPit:      CGPoint(x: 1200, y: 800),
        .mine:         CGPoint(x: 1350, y: 550),
        .pigmentTable: CGPoint(x: 1250, y: 250),
        .forest:       CGPoint(x: 200,  y: 400),
        .market:       CGPoint(x: 500,  y: 200),
        .workbench:    CGPoint(x: 600,  y: 500),
        .furnace:      CGPoint(x: 900,  y: 480),
    ]

    // MARK: - Callbacks to SwiftUI

    var onPlayerPositionChanged: ((CGPoint, Bool) -> Void)?
    var onStationReached: ((ResourceStationType) -> Void)?
    var onPlayerFacingChanged: ((Bool) -> Void)?

    // MARK: - Scene Setup

    override func didMove(to view: SKView) {
        backgroundColor = PlatformColor(RenaissanceColors.parchment)

        setupCamera()
        setupBackground()
        setupGridLines()
        setupTitle()
        setupWalkingPaths()
        setupStations()
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
        // Terrain texture matches the map exactly — full image visible
        let terrainTexture = SKTexture(imageNamed: "Terrain")
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

        for x in stride(from: 0, through: mapSize.width, by: 80) {
            let path = CGMutablePath()
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: mapSize.height))
            let line = SKShapeNode(path: path)
            line.strokeColor = lineColor
            line.lineWidth = 0.5
            gridNode.addChild(line)
        }

        for y in stride(from: 0, through: mapSize.height, by: 80) {
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
        title.fontName = "Cinzel-Bold"
        title.fontSize = 28
        title.fontColor = PlatformColor(RenaissanceColors.sepiaInk.opacity(0.4))
        title.position = CGPoint(x: mapSize.width / 2, y: mapSize.height - 50)
        title.zPosition = -80
        addChild(title)
    }

    // MARK: - Walking Paths (dotted lines connecting stations to crafting area)

    private func setupWalkingPaths() {
        let pathNode = SKNode()
        pathNode.zPosition = -50

        let craftingCenter = CGPoint(x: 750, y: 490)  // between workbench and furnace

        for (stationType, pos) in stationPositions {
            if stationType.isCraftingStation { continue }

            let linePath = CGMutablePath()
            linePath.move(to: pos)
            linePath.addLine(to: craftingCenter)

            let dottedLine = SKShapeNode(path: linePath)
            dottedLine.strokeColor = PlatformColor(RenaissanceColors.ochre.opacity(0.25))
            dottedLine.lineWidth = 2
            dottedLine.path = linePath.copy(dashingWithPhase: 0, lengths: [12, 8])
            pathNode.addChild(dottedLine)
        }

        // Path between workbench and furnace
        let wbPos = stationPositions[.workbench]!
        let fPos = stationPositions[.furnace]!
        let connectPath = CGMutablePath()
        connectPath.move(to: wbPos)
        connectPath.addLine(to: fPos)
        let connectLine = SKShapeNode(path: connectPath)
        connectLine.strokeColor = PlatformColor(RenaissanceColors.ochre.opacity(0.35))
        connectLine.lineWidth = 2.5
        connectLine.path = connectPath.copy(dashingWithPhase: 0, lengths: [8, 6])
        pathNode.addChild(connectLine)

        addChild(pathNode)
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
        playerNode = PlayerNode()
        playerNode.position = CGPoint(x: mapSize.width / 2, y: mapSize.height / 2)
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
            // Option + scroll = zoom
            let zoomFactor: CGFloat = 1.0 - (event.deltaY * 0.05)
            let newScale = cameraNode.xScale * zoomFactor
            cameraNode.setScale(max(0.8, min(2.5, newScale)))
        } else {
            // Scroll = pan
            let scale = cameraNode.xScale
            cameraNode.position.x -= event.deltaX * scale * 2
            cameraNode.position.y += event.deltaY * scale * 2
        }
        clampCamera()
    }

    override func magnify(with event: NSEvent) {
        let zoomFactor: CGFloat = 1.0 + event.magnification
        let newScale = cameraNode.xScale / zoomFactor
        cameraNode.setScale(max(0.8, min(2.5, newScale)))
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
        // Check if a station was tapped
        let tappedNodes = nodes(at: location)
        for node in tappedNodes {
            if let resourceNode = node as? ResourceNode {
                walkPlayerToStation(resourceNode)
                return
            }
            if let resourceNode = node.parent as? ResourceNode {
                walkPlayerToStation(resourceNode)
                return
            }
            // Check grandparent too (for pigment table sub-nodes)
            if let resourceNode = node.parent?.parent as? ResourceNode {
                walkPlayerToStation(resourceNode)
                return
            }
        }

        // Start pan
        lastPanLocation = location
    }

    private func walkPlayerToStation(_ stationNode: ResourceNode) {
        stationNode.animateTap()

        let stationPos = stationNode.position
        let targetPos = CGPoint(x: stationPos.x - 60, y: stationPos.y - 30)

        // Face the station
        let facingRight = targetPos.x > playerNode.position.x
        playerNode.setFacingDirection(facingRight)
        onPlayerFacingChanged?(facingRight)

        playerNode.walkTo(destination: targetPos, duration: 0.8) { [weak self] in
            self?.onStationReached?(stationNode.stationType)
        }
    }

    private func handleDragTo(_ location: CGPoint, from lastLocation: CGPoint) {
        let dx = location.x - lastLocation.x
        let dy = location.y - lastLocation.y
        cameraNode.position.x -= dx
        cameraNode.position.y -= dy
        clampCamera()
        lastPanLocation = location
    }

    // MARK: - Camera Clamping

    private func clampCamera() {
        let scale = cameraNode.xScale
        let viewSize = view?.bounds.size ?? CGSize(width: 1024, height: 768)
        let padding: CGFloat = 100

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
        cameraNode.setScale(max(0.8, min(2.5, newScale)))
        clampCamera()
    }

    // MARK: - Public Methods

    /// Update stock display on a resource node
    func updateStationStock(_ stationType: ResourceStationType, totalCount: Int) {
        resourceNodes[stationType]?.updateStock(totalCount)
    }

    /// Show collection burst on a station
    func showCollectionEffect(at stationType: ResourceStationType) {
        resourceNodes[stationType]?.showCollectionBurst()
    }

    /// Get current player position
    func getPlayerPosition() -> CGPoint {
        return playerNode.position
    }

    // MARK: - Editor Mode (DEBUG only)

    #if DEBUG
    private func registerEditorNodes() {
        // Resource stations
        for (stationType, node) in resourceNodes {
            editorMode.registerNode(node, name: "station_\(stationType.rawValue)")
        }

        // Player
        editorMode.registerNode(playerNode, name: "player")
    }
    #endif
}
