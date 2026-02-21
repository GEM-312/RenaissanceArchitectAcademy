import SpriteKit
import SwiftUI

/// SpriteKit scene for the Italian Forest — biology & environment education
/// 4 Midjourney forest images arranged as terrain zones in a 2×2 grid
class ForestScene: SKScene {

    // MARK: - Properties

    private var cameraNode: SKCameraNode!
    private var playerNode: PlayerNode!

    // Camera control (pan + zoom like workshop/city)
    private var lastPanLocation: CGPoint?
    private var initialCameraScale: CGFloat = 1.0

    // Map size — standard 3500×2500 coordinate space
    private let mapSize = CGSize(width: 3500, height: 2500)

    #if DEBUG
    private lazy var editorMode = SceneEditorMode(scene: self)
    #endif

    /// Points of interest — Renaissance timber trees the player can tap to learn about
    struct ForestPOI {
        let name: String
        let italianName: String
        let position: CGPoint
        let usedFor: String
        let buildings: String
        let description: String
    }

    private let pointsOfInterest: [ForestPOI] = [
        ForestPOI(name: "Oak", italianName: "Quercia",
                  position: CGPoint(x: 500, y: 1650),
                  usedFor: "Roof trusses, beams, doors",
                  buildings: "ALL buildings (structural)",
                  description: "The strongest Italian hardwood — oak beams span cathedral naves and support the massive roof trusses of the Colosseum. Its heartwood resists rot for centuries."),
        ForestPOI(name: "Chestnut", italianName: "Castagno",
                  position: CGPoint(x: 2900, y: 1700),
                  usedFor: "Exterior frames, joinery",
                  buildings: "Palazzo, Villa",
                  description: "Called 'the bread tree' because its flour fed mountain villages. Chestnut wood is rich in tannins that naturally repel insects and moisture — perfect for palazzo window frames."),
        ForestPOI(name: "Cypress", italianName: "Cipresso",
                  position: CGPoint(x: 1750, y: 1900),
                  usedFor: "Interior panels, chests",
                  buildings: "Chapel, Villa",
                  description: "The tall sentinel of Tuscan landscapes. Cypress wood is aromatic and moth-resistant, making it the ideal choice for church doors, carved chests, and chapel interiors."),
        ForestPOI(name: "Walnut", italianName: "Noce",
                  position: CGPoint(x: 600, y: 750),
                  usedFor: "Fine furniture, decoration",
                  buildings: "Palazzo (luxury)",
                  description: "The most prized wood in Renaissance Italy. Walnut's deep grain and rich color made it the choice of master carvers for palazzo furniture, inlaid desks, and portrait frames."),
        ForestPOI(name: "Poplar", italianName: "Pioppo",
                  position: CGPoint(x: 2800, y: 700),
                  usedFor: "Scaffolding, painting panels",
                  buildings: "Construction phase + Chapel frescoes",
                  description: "Fast-growing and lightweight, poplar was the builder's workhorse — scaffolding for every construction site. Artists also split poplar into smooth panels for tempera paintings."),
    ]

    private var poiNodes: [SKNode] = []

    // MARK: - Callbacks to SwiftUI

    var onPlayerPositionChanged: ((CGPoint, Bool) -> Void)?
    var onBackRequested: (() -> Void)?
    /// Called when a POI is tapped — passes the POI index so SwiftUI shows the info overlay
    var onPOISelected: ((Int) -> Void)?

    // MARK: - Scene Setup

    override func didMove(to view: SKView) {
        backgroundColor = PlatformColor(RenaissanceColors.parchment)

        setupCamera()
        setupBackground()
        setupGridLines()
        setupTitle()
        setupPOIs()
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

    /// Standard fitCameraToMap — uses mapSize (not terrain size)
    private func fitCameraToMap() {
        guard let cameraNode = cameraNode else { return }
        let s = self.size
        guard s.width > 0 && s.height > 0 else { return }
        let fitScale = max(mapSize.width / s.width, mapSize.height / s.height)
        cameraNode.setScale(fitScale)
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

    // MARK: - Background (stretched to mapSize per standard)

    private func setupBackground() {
        let terrainTexture = SKTexture(imageNamed: "Forest1")
        let terrain = SKSpriteNode(texture: terrainTexture)
        terrain.size = mapSize  // Stretch to fill map coordinate space
        terrain.position = CGPoint(x: mapSize.width / 2, y: mapSize.height / 2)
        terrain.zPosition = -100
        addChild(terrain)
    }

    // MARK: - Grid Lines (notebook style)

    private func setupGridLines() {
        let gridNode = SKNode()
        gridNode.zPosition = -90

        let lineColor = PlatformColor(RenaissanceColors.sepiaInk.opacity(0.06))

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
        let title = SKLabelNode(text: "THE ITALIAN FOREST")
        title.fontName = "Cinzel-Bold"
        title.fontSize = 28
        title.fontColor = PlatformColor(RenaissanceColors.sepiaInk.opacity(0.4))
        title.position = CGPoint(x: mapSize.width / 2, y: mapSize.height - 50)
        title.zPosition = -80
        addChild(title)
    }

    // MARK: - Points of Interest

    private func setupPOIs() {
        for (index, poi) in pointsOfInterest.enumerated() {
            let container = SKNode()
            container.position = poi.position
            container.zPosition = 10
            container.name = "poi_\(index)"

            // Glowing circle background
            let glow = SKShapeNode(circleOfRadius: 40)
            glow.fillColor = PlatformColor(RenaissanceColors.sageGreen.opacity(0.2))
            glow.strokeColor = PlatformColor(RenaissanceColors.sageGreen.opacity(0.5))
            glow.lineWidth = 2
            container.addChild(glow)

            // Pulsing animation
            let scaleUp = SKAction.scale(to: 1.15, duration: 1.2)
            scaleUp.timingMode = .easeInEaseOut
            let scaleDown = SKAction.scale(to: 1.0, duration: 1.2)
            scaleDown.timingMode = .easeInEaseOut
            glow.run(SKAction.repeatForever(SKAction.sequence([scaleUp, scaleDown])))

            // Tree name label
            let label = SKLabelNode(text: poi.name)
            label.fontName = "Cinzel-Bold"
            label.fontSize = 15
            label.fontColor = PlatformColor(RenaissanceColors.sepiaInk)
            label.position = CGPoint(x: 0, y: -55)
            label.zPosition = 11
            container.addChild(label)

            // Italian name
            let italianLabel = SKLabelNode(text: poi.italianName)
            italianLabel.fontName = "EBGaramond-Italic"
            italianLabel.fontSize = 13
            italianLabel.fontColor = PlatformColor(RenaissanceColors.ochre)
            italianLabel.position = CGPoint(x: 0, y: -72)
            italianLabel.zPosition = 11
            container.addChild(italianLabel)

            addChild(container)
            poiNodes.append(container)
        }
    }

    /// Get POI data by index (for SwiftUI overlay)
    func getPOI(at index: Int) -> ForestPOI? {
        guard index >= 0 && index < pointsOfInterest.count else { return nil }
        return pointsOfInterest[index]
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

    // Scroll wheel/trackpad on macOS
    override func scrollWheel(with event: NSEvent) {
        if event.modifierFlags.contains(.option) {
            // Option + scroll = zoom
            let zoomFactor: CGFloat = 1.0 - (event.deltaY * 0.05)
            let newScale = cameraNode.xScale * zoomFactor
            let clampedScale = max(0.5, min(3.5, newScale))
            cameraNode.setScale(clampedScale)
        } else {
            // Regular scroll = pan the map
            let scale = cameraNode.xScale
            cameraNode.position.x -= event.deltaX * scale * 2
            cameraNode.position.y += event.deltaY * scale * 2
        }
        clampCamera()
    }

    // Pinch-to-zoom on trackpad
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
        // Check if a POI was tapped
        let tappedNodes = nodes(at: location)
        for node in tappedNodes {
            if let poiNode = findPOIAncestor(node) {
                walkPlayerToPOI(poiNode)
                return
            }
        }

        // Start pan
        lastPanLocation = location
    }

    private func handleDragTo(_ location: CGPoint, from lastLocation: CGPoint) {
        let deltaX = location.x - lastLocation.x
        let deltaY = location.y - lastLocation.y

        cameraNode.position.x -= deltaX
        cameraNode.position.y -= deltaY

        clampCamera()
        lastPanLocation = location
    }

    func handlePinch(scale: CGFloat) {
        let newScale = cameraNode.xScale / scale
        let clampedScale = max(0.5, min(3.5, newScale))
        cameraNode.setScale(clampedScale)
        clampCamera()
    }

    private func findPOIAncestor(_ node: SKNode) -> SKNode? {
        var current: SKNode? = node
        while let n = current {
            if let name = n.name, name.hasPrefix("poi_") {
                return n
            }
            current = n.parent
        }
        return nil
    }

    private func walkPlayerToPOI(_ poiNode: SKNode) {
        let targetPos = CGPoint(x: poiNode.position.x - 60, y: poiNode.position.y - 50)
        let playerPos = playerNode.position

        let distance = hypot(targetPos.x - playerPos.x, targetPos.y - playerPos.y)
        let duration = max(0.3, TimeInterval(distance / 467))

        let facingRight = targetPos.x > playerPos.x
        playerNode.setFacingDirection(facingRight)

        playerNode.walkTo(destination: targetPos, duration: duration) { [weak self] in
            guard let self = self,
                  let name = poiNode.name,
                  let idx = Int(name.replacingOccurrences(of: "poi_", with: "")),
                  idx < self.pointsOfInterest.count else { return }
            // Notify SwiftUI to show the info overlay
            self.onPOISelected?(idx)
        }
    }

    // MARK: - Editor Mode (DEBUG only)

    #if DEBUG
    private func registerEditorNodes() {
        for (i, node) in poiNodes.enumerated() {
            editorMode.registerNode(node, name: "poi_\(i)")
        }
        editorMode.registerNode(playerNode, name: "player")

        editorMode.onToggle = { [weak self] active in
            guard let self = self else { return }
            if !active {
                self.dumpPOIPositions()
            }
        }
    }

    private func dumpPOIPositions() {
        print("\n// ========== FOREST POI POSITIONS ==========")
        print("private let pointsOfInterest: [ForestPOI] = [")
        for (i, node) in poiNodes.enumerated() {
            let p = node.position
            let poi = pointsOfInterest[i]
            print("    ForestPOI(name: \"\(poi.name)\", italianName: \"\(poi.italianName)\",")
            print("              position: CGPoint(x: \(Int(p.x)), y: \(Int(p.y))),")
            print("              usedFor: \"\(poi.usedFor)\",")
            print("              buildings: \"\(poi.buildings)\",")
            print("              description: \"...\"),")
        }
        print("]")
        print("// =============================================\n")
    }
    #endif
}
