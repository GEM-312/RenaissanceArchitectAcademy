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

    // MARK: - Properties

    private var cameraNode: SKCameraNode!
    /// Maximum zoom-out scale = full map visible (computed in fitCameraToMap)
    private var maxZoomOutScale: CGFloat = 3.5
    private(set) var buildingNodes: [String: BuildingNode] = [:]
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

    /// Matches the standard used by every other scene in the project —
    /// 3500×2500 coordinate space, 2x (7000×5000) terrain PNGs. Was
    /// 4048×2144 before Apr 23 2026; that aspect (1.888:1) stretched the
    /// new 1.4:1 terrain horizontally / squashed it vertically.
    private let mapSize = CGSize(width: 3500, height: 2500)

    // MARK: - Waypoint Graph (road network for pathfinding)

    /// 40 road junctions connecting the 17 buildings across the 3500×2500 map
    private var waypoints: [CGPoint] = [
        // --- Ancient Rome side (left) ---
        /* 0  */ CGPoint(x: 200,  y: 1800),  // near aqueduct-colosseum
        /* 1  */ CGPoint(x: 400,  y: 2100),  // near aqueduct
        /* 2  */ CGPoint(x: 400,  y: 1600),  // W mid
        /* 3  */ CGPoint(x: 300,  y: 1250),  // near roman baths
        /* 4  */ CGPoint(x: 550,  y: 1500),  // rome crossroads
        /* 5  */ CGPoint(x: 500,  y: 1050),  // between baths-pantheon
        /* 6  */ CGPoint(x: 700,  y: 1200),  // near pantheon
        /* 7  */ CGPoint(x: 400,  y: 750),   // near roman roads
        /* 8  */ CGPoint(x: 250,  y: 550),   // near harbor
        /* 9  */ CGPoint(x: 500,  y: 550),   // S rome
        /* 10 */ CGPoint(x: 600,  y: 400),   // near siege workshop
        /* 11 */ CGPoint(x: 750,  y: 650),   // near insula
        /* 12 */ CGPoint(x: 700,  y: 900),   // rome south junction

        // --- Center spine ---
        /* 13 */ CGPoint(x: 1000, y: 2000),  // upper center-left
        /* 14 */ CGPoint(x: 1100, y: 1500),  // center-left mid
        /* 15 */ CGPoint(x: 1000, y: 1100),  // center-left lower
        /* 16 */ CGPoint(x: 1100, y: 700),   // center-left south
        /* 17 */ CGPoint(x: 1400, y: 1800),  // center
        /* 18 */ CGPoint(x: 1400, y: 1300),  // center mid
        /* 19 */ CGPoint(x: 1400, y: 900),   // center south

        // --- Milan area ---
        /* 20 */ CGPoint(x: 1700, y: 2100),  // near leonardo's workshop
        /* 21 */ CGPoint(x: 1600, y: 1700),  // near flying machine
        /* 22 */ CGPoint(x: 1800, y: 1500),  // milan junction

        // --- Padua ---
        /* 23 */ CGPoint(x: 2100, y: 1500),  // near anatomy theater
        /* 24 */ CGPoint(x: 2000, y: 1200),  // padua south

        // --- Florence area ---
        /* 25 */ CGPoint(x: 2300, y: 2200),  // near duomo
        /* 26 */ CGPoint(x: 2500, y: 2000),  // florence junction
        /* 27 */ CGPoint(x: 2700, y: 1900),  // near botanical garden
        /* 28 */ CGPoint(x: 2600, y: 1700),  // florence south

        // --- Venice area ---
        /* 29 */ CGPoint(x: 3000, y: 1800),  // venice north
        /* 30 */ CGPoint(x: 3100, y: 1500),  // near glassworks
        /* 31 */ CGPoint(x: 2900, y: 1350),  // near arsenal
        /* 32 */ CGPoint(x: 2800, y: 1100),  // venice south

        // --- Renaissance Rome area ---
        /* 33 */ CGPoint(x: 2200, y: 900),   // between padua-renRome
        /* 34 */ CGPoint(x: 2500, y: 1000),  // near vatican observatory
        /* 35 */ CGPoint(x: 2100, y: 600),   // near printing press
        /* 36 */ CGPoint(x: 2500, y: 700),   // ren rome south
        /* 37 */ CGPoint(x: 1800, y: 800),   // center-south junction

        // --- Extra connectors ---
        /* 38 */ CGPoint(x: 1800, y: 2000),  // upper center
        /* 39 */ CGPoint(x: 2200, y: 1800),  // between padua-florence
    ]

    /// Bidirectional edges: each pair [a, b] means a↔b
    private let waypointEdges: [[Int]] = [
        // Ancient Rome chain
        [1, 0], [0, 2], [2, 4], [2, 3], [3, 5], [4, 5], [4, 6],
        [5, 6], [5, 7], [7, 8], [7, 9], [8, 9], [9, 10], [10, 11],
        [11, 12], [12, 7], [6, 12],

        // Rome to center
        [0, 13], [4, 14], [6, 15], [12, 16], [14, 15], [15, 16],
        [13, 17], [14, 18], [16, 19],

        // Center spine
        [17, 18], [18, 19], [17, 21], [18, 22], [19, 37],

        // Milan
        [13, 20], [20, 38], [38, 17], [17, 21], [21, 22],

        // Padua
        [22, 23], [23, 24], [24, 33],

        // Florence
        [20, 25], [25, 26], [26, 27], [26, 28], [27, 28],
        [38, 26], [39, 28],

        // Venice
        [28, 29], [29, 30], [30, 31], [31, 32], [27, 29],

        // Renaissance Rome
        [24, 34], [33, 34], [33, 35], [34, 36], [35, 36],
        [19, 35], [37, 35], [32, 34],

        // Cross-links
        [21, 39], [23, 39], [39, 23], [22, 24], [37, 19],
    ]

    /// Which waypoints each building connects to (nearest road junctions)
    private let buildingWaypoints: [String: [Int]] = [
        "aqueduct":          [1, 0],
        "colosseum":         [0, 4],
        "romanBaths":        [3, 5],
        "pantheon":          [6, 5],
        "romanRoads":        [7, 12],
        "harbor":            [8, 9],
        "siegeWorkshop":     [10, 9],
        "insula":            [11, 12],
        "duomo":             [25, 26],
        "botanicalGarden":   [27, 28],
        "glassworks":        [30, 29],
        "arsenal":           [31, 32],
        "anatomyTheater":    [23, 24],
        "leonardoWorkshop":  [20, 38],
        "flyingMachine":     [21, 17],
        "vaticanObservatory": [34, 36],
        "printingPress":     [35, 33],
    ]

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
        // Spawn near the center of the map
        playerNode.position = CGPoint(x: 1400, y: 1300)
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

        // Smoothly follow the player while walking to a building — preserve
        // whatever zoom the player set themselves. No auto zoom-in during
        // approach, no auto zoom-out on arrival.
        if isFollowingPlayer {
            let target = playerNode.position
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
        terrainBlur.setup(in: self, sharp: "Terrain", blurred: "BlurredTerrain", mapSize: mapSize)
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
        // Building data matching the 6 buildings from the game
        // Positions based on level_design_sketch.JPG layout

        // All 17 buildings organized by region
        let buildings: [(id: String, name: String, position: CGPoint, era: String, rotation: CGFloat)] = [
            // ========================================
            // ANCIENT ROME
            // ========================================
            // Positions rescaled for new 3500x1955 map (Y × 0.782 from old 2500 height)
            // Use editor mode (E) to fine-tune positions over baked-in buildings
            ("aqueduct", "Aqueduct", CGPoint(x: 2607, y: 1247), "rome", 0),
            ("colosseum", "Colosseum", CGPoint(x: 799, y: 687), "rome", 0),
            ("romanBaths", "Roman Baths", CGPoint(x: 720, y: 1757), "rome", 0),
            ("pantheon", "Pantheon", CGPoint(x: 1635, y: 650), "rome", 0),
            ("romanRoads", "Roman Roads", CGPoint(x: 2535, y: 723), "rome", 0),
            ("harbor", "Harbor", CGPoint(x: 3121, y: 1366), "rome", 0),
            ("siegeWorkshop", "Siege Workshop", CGPoint(x: 1888, y: 1455), "rome", 0),
            ("insula", "Insula", CGPoint(x: 372, y: 966), "rome", 0),

            // ========================================
            // RENAISSANCE ITALY
            // ========================================

            // Florence
            ("duomo", "Il Duomo", CGPoint(x: 2040, y: 724), "florence", 0),
            ("botanicalGarden", "Botanical Garden", CGPoint(x: 2497, y: 151), "florence", 0),

            // Venice
            ("glassworks", "Glassworks", CGPoint(x: 2190, y: 280), "venice", 0),
            ("arsenal", "Arsenal", CGPoint(x: 1300, y: 113), "venice", 0),

            // Padua
            ("anatomyTheater", "Anatomy Theater", CGPoint(x: 1236, y: 1285), "padua", 0),

            // Milan
            ("leonardoWorkshop", "Leonardo's Workshop", CGPoint(x: 536, y: 471), "milan", 0),
            ("flyingMachine", "Flying Machine", CGPoint(x: 3125, y: 687), "milan", 0),

            // Renaissance Rome
            ("vaticanObservatory", "Vatican Observatory", CGPoint(x: 1028, y: 254), "renaissanceRome", 0),
            ("printingPress", "Printing Press", CGPoint(x: 3339, y: 336), "renaissanceRome", 0)
        ]

        for building in buildings {
            let node = BuildingNode(
                buildingId: building.id,
                buildingName: building.name,
                era: building.era
            )
            node.position = building.position
            node.zRotation = building.rotation * .pi / 180  // degrees to radians
            node.zPosition = 10
            addChild(node)
            buildingNodes[building.id] = node
        }
    }

    // MARK: - Decorations (trees, paths)

    private func setupDecorations() {
        // Zone labels — repositioned for 3500×1955 map
        // Ancient Rome: buildings cluster around (372-2607, 687-1757)
        addZoneLabel("I", at: CGPoint(x: 1400, y: 1100), for: "Ancient Rome", nodeName: "zone_ancientRome")

        // Florence: Duomo (2040,724), Botanical Garden (2497,151)
        addZoneLabel("II", at: CGPoint(x: 2270, y: 500), for: "Florence", nodeName: "zone_florence")

        // Venice: Glassworks (2190,280), Arsenal (1300,113)
        addZoneLabel("III", at: CGPoint(x: 1750, y: 200), for: "Venice", nodeName: "zone_venice")

        // Padua: Anatomy Theater (1236,1285)
        addZoneLabel("IV", at: CGPoint(x: 1100, y: 1400), for: "Padua", nodeName: "zone_padua")

        // Milan: Leonardo's Workshop (536,471), Flying Machine (3125,687)
        addZoneLabel("V", at: CGPoint(x: 536, y: 580), for: "Milan", nodeName: "zone_milan")

        // Renaissance Rome: Vatican Observatory (1028,254), Printing Press (3298,36)
        addZoneLabel("VI", at: CGPoint(x: 3200, y: 150), for: "Renaissance Rome", nodeName: "zone_renaissanceRome")

        // Add a dividing path/road between eras
        addEraDivider()
    }

    private func addEraDivider() {
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

    /// Start following player — gentle initial zoom, gradual approach in update()
    private func startFollowingPlayer(toward target: CGPoint) {
        guard let cameraNode = cameraNode else { return }
        isFollowingPlayer = true
        walkTargetPosition = target

        // Zoom to 0.8x (gentle start) — gradual zoom to 0.55 happens in update()
        let zoomAction = SKAction.scale(to: 0.8, duration: 0.5)
        zoomAction.timingMode = .easeInEaseOut
        cameraNode.run(zoomAction, withKey: "cameraZoom")
    }

    /// Settle camera on the building after player arrives
    private func zoomCameraToBuilding(_ buildingPos: CGPoint) {
        guard let cameraNode = cameraNode else { return }

        // On smaller screens (iPhone), zoom less so the player sprite stays visible
        let viewWidth = view?.bounds.width ?? 1024
        let targetScale: CGFloat = viewWidth < 500 ? 0.85 : 0.6

        let moveAction = SKAction.move(to: buildingPos, duration: 0.5)
        moveAction.timingMode = .easeInEaseOut

        let zoomAction = SKAction.scale(to: targetScale, duration: 0.5)
        zoomAction.timingMode = .easeInEaseOut

        cameraNode.run(SKAction.group([moveAction, zoomAction]), withKey: "cameraZoom")
    }

    /// Zoom back out to show the full map (call when overlay/dialogue dismisses)
    func zoomCameraOut() {
        guard let cameraNode = cameraNode else { return }
        isFollowingPlayer = false
        walkTargetPosition = nil
        dialogBuildingNode = nil

        // Remove blur + walking terrain when zooming back out
        stopWalkingTerrainEffects()

        view?.preferredFramesPerSecond = 60  // Smooth zoom-out animation

        let mapCenter = CGPoint(x: mapSize.width / 2, y: mapSize.height / 2)

        let moveAction = SKAction.move(to: mapCenter, duration: 0.6)
        moveAction.timingMode = .easeInEaseOut

        let zoomAction = SKAction.scale(to: maxZoomOutScale, duration: 0.6)
        zoomAction.timingMode = .easeInEaseOut

        let idleAfter = SKAction.run { [weak self] in self?.view?.preferredFramesPerSecond = 30 }
        cameraNode.run(SKAction.sequence([SKAction.group([moveAction, zoomAction]), idleAfter]), withKey: "cameraZoom")
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
