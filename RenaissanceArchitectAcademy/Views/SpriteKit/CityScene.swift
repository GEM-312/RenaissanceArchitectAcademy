import SpriteKit
import SwiftUI

#if os(iOS)
import UIKit
typealias PlatformColor = UIColor
#else
import AppKit
typealias PlatformColor = NSColor
#endif

/// Main SpriteKit scene for the isometric city map
/// Based on level_design_sketch.JPG layout
class CityScene: SKScene {

    // MARK: - Properties

    private var cameraNode: SKCameraNode!
    private(set) var buildingNodes: [String: BuildingNode] = [:]

    private var lastCursorPosition: CGPoint?

    // Callback when a building is tapped
    var onBuildingSelected: ((String) -> Void)?

    // Callback when mascot reaches building (for dialogue)
    var onMascotReachedBuilding: ((String) -> Void)?

    // Callback when mascot walks off to puzzle
    var onMascotExitToPuzzle: (() -> Void)?

    // (Bird overlay removed — mascot position tracking no longer needed)

    // Camera control
    private var lastPanLocation: CGPoint?
    private var initialCameraScale: CGFloat = 1.0

    #if DEBUG
    private lazy var editorMode = SceneEditorMode(scene: self)
    #endif

    // MARK: - Terrain Tile System

    /// Terrain tile for the expandable map system
    private struct TerrainTile {
        let imageName: String?  // nil = placeholder (parchment, no image yet)
        let origin: CGPoint     // bottom-left corner in map coordinates
        let size: CGSize        // tile dimensions in points
    }

    /// Map tiles — add entries to expand the map in any direction.
    /// The first tile is the current terrain. Add new tiles adjacent to it.
    /// mapSize auto-adjusts and camera panning covers all tiles.
    private let terrainTiles: [TerrainTile] = [
        // Current map
        TerrainTile(imageName: "Terrain", origin: .zero, size: CGSize(width: 3500, height: 2500)),

        // === Expansion tiles ===
        // Uncomment and replace nil with image name once art is created:
        // TerrainTile(imageName: nil, origin: CGPoint(x: 3500, y: 0),    size: CGSize(width: 3500, height: 2500)),  // East
        // TerrainTile(imageName: nil, origin: CGPoint(x: 0, y: 2500),    size: CGSize(width: 3500, height: 2500)),  // North
        // TerrainTile(imageName: nil, origin: CGPoint(x: 3500, y: 2500), size: CGSize(width: 3500, height: 2500)),  // Northeast
    ]

    /// Map size auto-computed from all terrain tiles
    private lazy var mapSize: CGSize = {
        var maxX: CGFloat = 0, maxY: CGFloat = 0
        for tile in terrainTiles {
            maxX = max(maxX, tile.origin.x + tile.size.width)
            maxY = max(maxY, tile.origin.y + tile.size.height)
        }
        return CGSize(width: max(3500, maxX), height: max(2500, maxY))
    }()

    // MARK: - Scene Setup

    override func didMove(to view: SKView) {
        backgroundColor = PlatformColor(red: 0.94, green: 0.91, blue: 0.86, alpha: 1.0) // Match terrain edge color

        setupCamera()
        setupTerrain()
        setupBuildings()
        setupDecorations()

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

    // MARK: - (Mascot removed from city map)

    // MARK: - Update Loop

    override func update(_ currentTime: TimeInterval) {
        // No-op (bird overlay removed)
    }

    private func setupCamera() {
        cameraNode = SKCameraNode()
        cameraNode.position = CGPoint(x: mapSize.width / 2, y: mapSize.height / 2)
        addChild(cameraNode)
        camera = cameraNode
        fitCameraToMap()
    }

    /// Recalculate camera scale when view resizes (.resizeFill updates scene.size)
    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        fitCameraToMap()
    }

    /// Set camera scale so the full map is visible
    private func fitCameraToMap() {
        guard let cameraNode = cameraNode else { return }
        // With .resizeFill, self.size = view size in points
        // visible area = self.size * cameraScale
        // To fit the whole map: scale = max(mapW/sizeW, mapH/sizeH)
        let s = self.size
        guard s.width > 0 && s.height > 0 else { return }
        let fitScale = max(mapSize.width / s.width, mapSize.height / s.height)
        cameraNode.setScale(fitScale)
    }

    // MARK: - Terrain

    private func setupTerrain() {
        // Lay out each terrain tile
        for tile in terrainTiles {
            let centerX = tile.origin.x + tile.size.width / 2
            let centerY = tile.origin.y + tile.size.height / 2

            if let imageName = tile.imageName {
                // Tile with art
                let texture = SKTexture(imageNamed: imageName)
                let sprite = SKSpriteNode(texture: texture)
                sprite.size = tile.size
                sprite.position = CGPoint(x: centerX, y: centerY)
                sprite.zPosition = -100
                addChild(sprite)
            } else {
                // Placeholder tile — parchment rectangle with dashed border
                let placeholder = SKSpriteNode(color: PlatformColor(red: 0.96, green: 0.90, blue: 0.83, alpha: 1.0), size: tile.size)
                placeholder.position = CGPoint(x: centerX, y: centerY)
                placeholder.zPosition = -100
                addChild(placeholder)

                // Dashed border
                let borderPath = CGMutablePath()
                borderPath.addRect(CGRect(origin: CGPoint(x: -tile.size.width / 2, y: -tile.size.height / 2), size: tile.size))
                let border = SKShapeNode(path: borderPath.copy(dashingWithPhase: 0, lengths: [20, 12]))
                border.strokeColor = PlatformColor(RenaissanceColors.ochre.opacity(0.4))
                border.lineWidth = 2
                border.fillColor = .clear
                border.position = CGPoint(x: centerX, y: centerY)
                border.zPosition = -99
                addChild(border)

                // "Expansion Area" label
                let label = SKLabelNode(text: "Expansion Area")
                label.fontName = "Mulish-Light"
                label.fontSize = 28
                label.fontColor = PlatformColor(RenaissanceColors.sepiaInk.opacity(0.25))
                label.position = CGPoint(x: centerX, y: centerY)
                label.zPosition = -98
                addChild(label)
            }
        }

        // Grid lines (Leonardo's notebook style)
        addGridOverlay()
    }

    private func addGridOverlay() {
        let gridNode = SKNode()
        gridNode.zPosition = -90

        let lineColor = PlatformColor(RenaissanceColors.sepiaInk.opacity(0.1))

        // Vertical lines
        for x in stride(from: 0, through: mapSize.width, by: 100) {
            let path = CGMutablePath()
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: mapSize.height))

            let line = SKShapeNode(path: path)
            line.strokeColor = lineColor
            line.lineWidth = 1
            gridNode.addChild(line)
        }

        // Horizontal lines
        for y in stride(from: 0, through: mapSize.height, by: 100) {
            let path = CGMutablePath()
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: mapSize.width, y: y))

            let line = SKShapeNode(path: path)
            line.strokeColor = lineColor
            line.lineWidth = 1
            gridNode.addChild(line)
        }

        addChild(gridNode)
    }

    // MARK: - Rivers

    private func setupRiver() {
        // Tiber River (Ancient Rome side)
        let tiberPath = CGMutablePath()
        tiberPath.move(to: CGPoint(x: 50, y: mapSize.height))
        tiberPath.addCurve(
            to: CGPoint(x: 100, y: mapSize.height * 0.6),
            control1: CGPoint(x: 80, y: mapSize.height * 0.85),
            control2: CGPoint(x: 30, y: mapSize.height * 0.7)
        )
        tiberPath.addCurve(
            to: CGPoint(x: 50, y: 0),
            control1: CGPoint(x: 150, y: mapSize.height * 0.4),
            control2: CGPoint(x: 80, y: mapSize.height * 0.2)
        )

        let tiber = SKShapeNode(path: tiberPath)
        tiber.strokeColor = PlatformColor(RenaissanceColors.renaissanceBlue)
        tiber.lineWidth = 50
        tiber.lineCap = .round
        tiber.zPosition = -50
        tiber.alpha = 0.5
        addChild(tiber)

        addRiverLabel("Tiber", at: CGPoint(x: 80, y: 1200), rotation: .pi / 8)

        // Grand Canal (Venice area - right side)
        let canalPath = CGMutablePath()
        canalPath.move(to: CGPoint(x: 3200, y: 1800))
        canalPath.addCurve(
            to: CGPoint(x: 3400, y: 1200),
            control1: CGPoint(x: 3350, y: 1650),
            control2: CGPoint(x: 3300, y: 1400)
        )
        canalPath.addLine(to: CGPoint(x: 3500, y: 900))

        let canal = SKShapeNode(path: canalPath)
        canal.strokeColor = PlatformColor(RenaissanceColors.deepTeal)
        canal.lineWidth = 35
        canal.lineCap = .round
        canal.zPosition = -50
        canal.alpha = 0.5
        addChild(canal)

        addRiverLabel("Grand Canal", at: CGPoint(x: 3350, y: 1400), rotation: -.pi / 4)

        // Arno River (Florence area)
        let arnoPath = CGMutablePath()
        arnoPath.move(to: CGPoint(x: 2100, y: 2400))
        arnoPath.addCurve(
            to: CGPoint(x: 2800, y: 2000),
            control1: CGPoint(x: 2300, y: 2350),
            control2: CGPoint(x: 2600, y: 2150)
        )

        let arno = SKShapeNode(path: arnoPath)
        arno.strokeColor = PlatformColor(RenaissanceColors.renaissanceBlue)
        arno.lineWidth = 30
        arno.lineCap = .round
        arno.zPosition = -50
        arno.alpha = 0.5
        addChild(arno)

        addRiverLabel("Arno", at: CGPoint(x: 2450, y: 2180), rotation: -.pi / 10)
    }

    private func addRiverLabel(_ name: String, at position: CGPoint, rotation: CGFloat) {
        let label = SKLabelNode(text: name)
        label.fontName = "Mulish-Light"
        label.fontSize = 20
        label.fontColor = PlatformColor(RenaissanceColors.renaissanceBlue.opacity(0.8))
        label.position = position
        label.zRotation = rotation
        label.zPosition = -40
        addChild(label)
    }

    // MARK: - Buildings (positions from sketch)

    private func setupBuildings() {
        // Building data matching the 6 buildings from the game
        // Positions based on level_design_sketch.JPG layout

        // All 17 buildings organized by region
        let buildings: [(id: String, name: String, position: CGPoint, era: String)] = [
            // ========================================
            // ANCIENT ROME (left side of map)
            // ========================================
            ("aqueduct", "Aqueduct", CGPoint(x: 200, y: 2100), "rome"),
            ("colosseum", "Colosseum", CGPoint(x: 550, y: 1800), "rome"),
            ("romanBaths", "Roman Baths", CGPoint(x: 250, y: 1450), "rome"),
            ("pantheon", "Pantheon", CGPoint(x: 600, y: 1200), "rome"),
            ("romanRoads", "Roman Roads", CGPoint(x: 350, y: 900), "rome"),
            ("harbor", "Harbor", CGPoint(x: 150, y: 550), "rome"),
            ("siegeWorkshop", "Siege Workshop", CGPoint(x: 500, y: 400), "rome"),
            ("insula", "Insula", CGPoint(x: 700, y: 650), "rome"),

            // ========================================
            // RENAISSANCE ITALY (right side of map)
            // ========================================

            // Florence (top right)
            ("duomo", "Il Duomo", CGPoint(x: 2400, y: 2200), "florence"),
            ("botanicalGarden", "Botanical Garden", CGPoint(x: 2700, y: 1900), "florence"),

            // Venice (middle right, near water)
            ("glassworks", "Glassworks", CGPoint(x: 3100, y: 1650), "venice"),
            ("arsenal", "Arsenal", CGPoint(x: 2900, y: 1350), "venice"),

            // Padua (center)
            ("anatomyTheater", "Anatomy Theater", CGPoint(x: 2200, y: 1500), "padua"),

            // Milan (upper middle)
            ("leonardoWorkshop", "Leonardo's Workshop", CGPoint(x: 1800, y: 2000), "milan"),
            ("flyingMachine", "Flying Machine", CGPoint(x: 1500, y: 1700), "milan"),

            // Rome (lower right - Renaissance Rome)
            ("vaticanObservatory", "Vatican Observatory", CGPoint(x: 2500, y: 900), "renaissanceRome"),
            ("printingPress", "Printing Press", CGPoint(x: 2100, y: 600), "renaissanceRome")
        ]

        for building in buildings {
            let node = BuildingNode(
                buildingId: building.id,
                buildingName: building.name,
                era: building.era
            )
            node.position = building.position
            node.zPosition = 10
            addChild(node)
            buildingNodes[building.id] = node
        }
    }

    // MARK: - Decorations (trees, paths)

    private func setupDecorations() {
        // Trees scattered around the map
        let treePositions: [CGPoint] = [
            // Ancient Rome area
            CGPoint(x: 450, y: 2000),
            CGPoint(x: 750, y: 1600),
            CGPoint(x: 400, y: 1100),
            CGPoint(x: 650, y: 800),
            CGPoint(x: 850, y: 500),
            // Center divider
            CGPoint(x: 1100, y: 1800),
            CGPoint(x: 1200, y: 1400),
            CGPoint(x: 1000, y: 1000),
            CGPoint(x: 1300, y: 600),
            // Renaissance area
            CGPoint(x: 1900, y: 2200),
            CGPoint(x: 2100, y: 1800),
            CGPoint(x: 2600, y: 1600),
            CGPoint(x: 2300, y: 1200),
            CGPoint(x: 2800, y: 800),
            CGPoint(x: 3000, y: 1100),
            CGPoint(x: 1700, y: 1400),
        ]

        for (index, position) in treePositions.enumerated() {
            let tree = createTree()
            tree.position = position
            tree.zPosition = 5
            tree.name = "tree_\(index)"
            addChild(tree)
        }

        // Zone labels for each region
        // Ancient Rome
        addZoneLabel("I", at: CGPoint(x: 450, y: 1500), for: "Ancient Rome", nodeName: "zone_ancientRome")

        // Renaissance Italy cities
        addZoneLabel("II", at: CGPoint(x: 2550, y: 2100), for: "Florence", nodeName: "zone_florence")
        addZoneLabel("III", at: CGPoint(x: 3000, y: 1500), for: "Venice", nodeName: "zone_venice")
        addZoneLabel("IV", at: CGPoint(x: 2200, y: 1650), for: "Padua", nodeName: "zone_padua")
        addZoneLabel("V", at: CGPoint(x: 1650, y: 1850), for: "Milan", nodeName: "zone_milan")
        addZoneLabel("VI", at: CGPoint(x: 2300, y: 750), for: "Renaissance Rome", nodeName: "zone_renaissanceRome")

        // Add a dividing path/road between eras
        addEraDivider()
    }

    private func addEraDivider() {
        // A subtle dotted line separating Ancient Rome from Renaissance Italy
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 1000, y: 0))
        path.addLine(to: CGPoint(x: 1200, y: mapSize.height))

        let divider = SKShapeNode(path: path)
        divider.strokeColor = PlatformColor(RenaissanceColors.ochre.opacity(0.3))
        divider.lineWidth = 3
        divider.lineCap = .round
        // Make it dashed
        divider.path = path.copy(dashingWithPhase: 0, lengths: [20, 15])
        divider.zPosition = -40
        addChild(divider)

        // Era labels at the top
        let romeLabel = SKLabelNode(text: "ANCIENT ROME")
        romeLabel.fontName = "Cinzel-Regular"
        romeLabel.fontSize = 32
        romeLabel.fontColor = PlatformColor(RenaissanceColors.sepiaInk)
        romeLabel.position = CGPoint(x: 500, y: mapSize.height - 100)
        romeLabel.zPosition = -30
        romeLabel.name = "label_ancientRome"
        addChild(romeLabel)

        let renaissanceLabel = SKLabelNode(text: "RENAISSANCE ITALY")
        renaissanceLabel.fontName = "Cinzel-Regular"
        renaissanceLabel.fontSize = 32
        renaissanceLabel.fontColor = PlatformColor(RenaissanceColors.sepiaInk)
        renaissanceLabel.position = CGPoint(x: 2400, y: mapSize.height - 100)
        renaissanceLabel.zPosition = -30
        renaissanceLabel.name = "label_renaissanceItaly"
        addChild(renaissanceLabel)
    }

    private func createTree() -> SKNode {
        let tree = SKNode()

        // Simple Leonardo-style tree sketch
        let trunk = SKShapeNode(rectOf: CGSize(width: 8, height: 30))
        trunk.fillColor = PlatformColor(RenaissanceColors.warmBrown)
        trunk.strokeColor = PlatformColor(RenaissanceColors.sepiaInk)
        trunk.lineWidth = 1
        trunk.position = CGPoint(x: 0, y: 15)
        tree.addChild(trunk)

        let foliage = SKShapeNode(circleOfRadius: 20)
        foliage.fillColor = PlatformColor(RenaissanceColors.sageGreen.opacity(0.7))
        foliage.strokeColor = PlatformColor(RenaissanceColors.sepiaInk)
        foliage.lineWidth = 1
        foliage.position = CGPoint(x: 0, y: 40)
        tree.addChild(foliage)

        return tree
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
        nameLabel.fontName = "Mulish-Light"
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
    }

    override func mouseMoved(with event: NSEvent) {
        let location = event.location(in: self)
        lastCursorPosition = location
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
            let clampedScale = max(0.5, min(3.5, newScale))
            cameraNode.setScale(clampedScale)
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
        // Check if a building was tapped
        let tappedNodes = nodes(at: location)
        for node in tappedNodes {
            if let buildingNode = node as? BuildingNode {
                // Have mascot walk to building first
                walkMascotToBuilding(buildingNode)
                return
            }
            // Also check parent (in case we tapped a child node)
            if let buildingNode = node.parent as? BuildingNode {
                walkMascotToBuilding(buildingNode)
                return
            }
        }

        // Start pan
        lastPanLocation = location
    }

    /// Tap building → animate tap → immediately trigger dialogue
    private func walkMascotToBuilding(_ buildingNode: BuildingNode) {
        // Animate the building tap
        buildingNode.animateTap()

        // Trigger dialogue immediately (no walk delay)
        onMascotReachedBuilding?(buildingNode.buildingId)
    }

    /// Reset mascot state (no-op now that bird is removed from map)
    func resetMascot() {
        // No-op — kept for compatibility with CityMapView calls
    }

    private func handleDragTo(_ location: CGPoint, from lastLocation: CGPoint) {
        // Pan camera
        let deltaX = location.x - lastLocation.x
        let deltaY = location.y - lastLocation.y

        cameraNode.position.x -= deltaX
        cameraNode.position.y -= deltaY

        clampCamera()
        lastPanLocation = location
    }

    // MARK: - Camera Control

    private func clampCamera() {
        let scale = cameraNode.xScale
        let viewSize = view?.bounds.size ?? CGSize(width: 1024, height: 768)

        // Add padding so edge buildings are fully visible
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
        let clampedScale = max(0.5, min(3.5, newScale))
        cameraNode.setScale(clampedScale)
        clampCamera()
    }

    /// Zoom via scroll delta (Magic Mouse swipe / scroll wheel)
    func handleScrollZoom(deltaY: CGFloat) {
        guard cameraNode != nil else { return }
        let zoomFactor: CGFloat = 1.0 - (deltaY * 0.05)
        let newScale = cameraNode.xScale * zoomFactor
        let clampedScale = max(0.5, min(3.5, newScale))
        cameraNode.setScale(clampedScale)
        clampCamera()
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

    // MARK: - Editor Mode (DEBUG only)

    #if DEBUG
    private func registerEditorNodes() {
        // Buildings
        for (id, node) in buildingNodes {
            editorMode.registerNode(node, name: "building_\(id)")
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
