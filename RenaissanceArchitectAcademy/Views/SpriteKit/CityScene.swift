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

    /// Whether the player is currently walking to a building
    private(set) var isPlayerWalking = false

    /// Camera follows player while walking
    private var isFollowingPlayer = false
    /// The building position the player is walking toward (for gradual zoom)
    private var walkTargetPosition: CGPoint?

    // Camera control
    private var lastPanLocation: CGPoint?
    private var initialCameraScale: CGFloat = 1.0

    /// Terrain sprite reference — fades when zoomed in to reveal clean parchment
    private var terrainSprite: SKSpriteNode?

    /// Pre-blurred terrain that fades in during walking/zoom-in (replaces memory-heavy CIGaussianBlur)
    private var blurredTerrainSprite: SKSpriteNode?

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
        guard !hasSetup else {
            if playerNode != nil { cameraNode.position = playerNode.position }
            return
        }
        hasSetup = true

        backgroundColor = PlatformColor(red: 0.94, green: 0.91, blue: 0.86, alpha: 1.0) // Match terrain edge color

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

        // Light mode glow (subtle sepia)
        for (_, node) in buildingNodes {
            let glow = WorkshopScene.makeRadialGlow(radius: 160, color: PlatformColor(red: 0.55, green: 0.44, blue: 0.28, alpha: 1.0))
            glow.name = "lightGlow"
            glow.position = node.position
            glow.zPosition = 13
            glow.alpha = 0.25
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
    }

    // MARK: - Theme

    private func applyTheme() {
        let dark = GameSettings.shared.isDarkMode

        // Toggle tint + glow visibility
        enumerateChildNodes(withName: "darkTint") { node, _ in node.isHidden = !dark }
        enumerateChildNodes(withName: "darkGlow") { node, _ in node.isHidden = !dark }
        enumerateChildNodes(withName: "lightGlow") { node, _ in node.isHidden = dark }
    }

    // MARK: - Scene Lifecycle

    override func willMove(from view: SKView) {
        // Release all textures and children to free memory when scene is removed
        removeAllActions()
        removeAllChildren()
        terrainSprite = nil
        blurredTerrainSprite = nil
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

        // Smoothly follow the player while walking to a building
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
                let closeZoom: CGFloat = 0.55
                let farZoom: CGFloat = 0.8
                let zoomStartDist: CGFloat = 800  // city map is bigger, start zooming earlier

                if totalDist < zoomStartDist {
                    let progress = 1.0 - (totalDist / zoomStartDist)
                    let targetScale = farZoom - (farZoom - closeZoom) * progress
                    let currentScale = cameraNode.xScale
                    cameraNode.setScale(currentScale + (targetScale - currentScale) * 0.06)
                }
            }

            clampCamera()
        }

        // Terrain crossfade — smooth transition between sharp and blurred terrain
        // Uses a transition zone (0.8–1.2) to avoid hard-threshold blinking when scale
        // hovers near 1.0 during pan/zoom gestures.
        if let cam = cameraNode {
            let scale = cam.xScale
            let loThreshold: CGFloat = 0.8   // fully blurred below this
            let hiThreshold: CGFloat = 1.2   // fully sharp above this
            let blurAlpha: CGFloat
            if scale <= loThreshold {
                blurAlpha = 1.0
            } else if scale >= hiThreshold {
                blurAlpha = 0.0
            } else {
                // Linear interpolation through the transition zone
                blurAlpha = 1.0 - (scale - loThreshold) / (hiThreshold - loThreshold)
            }
            // Smooth lerp to avoid per-frame jitter
            let lerpSpeed: CGFloat = 0.15
            let currentBlur = blurredTerrainSprite?.alpha ?? 0
            let newBlur = currentBlur + (blurAlpha - currentBlur) * lerpSpeed
            blurredTerrainSprite?.alpha = newBlur
            // Fade sharp terrain as blur fades in, but never below 0.35 to prevent
            // background color bleed-through (which caused blinking)
            let sharpAlpha = max(0.35, 1.0 - newBlur)
            let currentSharp = terrainSprite?.alpha ?? 1.0
            terrainSprite?.alpha = currentSharp + (sharpAlpha - currentSharp) * lerpSpeed
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
        cameraNode.setScale(1.7)
    }

    /// Recalculate camera scale when view resizes (.resizeFill updates scene.size)
    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        // Don't override the initial 0.3 zoom — only re-fit if the user has zoomed out past fitScale
        // (i.e. this is a real window resize, not the initial SpriteKit sizing)
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
                // Tile with art — use linear filtering for smooth zoom-in
                let texture = SKTexture(imageNamed: imageName)
                texture.filteringMode = .linear
                let sprite = SKSpriteNode(texture: texture)
                sprite.size = tile.size
                sprite.position = CGPoint(x: centerX, y: centerY)
                sprite.zPosition = -100
                addChild(sprite)
                terrainSprite = sprite

                // Pre-blurred terrain — fades in during walking/zoom for depth-of-field effect
                // Zero GPU cost: just alpha crossfade between sharp and blurred textures
                let blurredTexture = SKTexture(imageNamed: "BlurredTerrain")
                blurredTexture.filteringMode = .linear
                let blurred = SKSpriteNode(texture: blurredTexture)
                blurred.size = tile.size
                blurred.position = CGPoint(x: centerX, y: centerY)
                blurred.zPosition = -99
                blurred.alpha = 0
                addChild(blurred)
                blurredTerrainSprite = blurred
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
                label.fontName = "EBGaramond-Regular"
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
        label.fontName = "EBGaramond-Regular"
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
            let clampedScale = max(0.5, min(3.5, newScale))
            cameraNode.setScale(clampedScale)
        }
        clampCamera()
    }

    // Pinch-to-zoom on trackpad
    override func magnify(with event: NSEvent) {
        dismissOverlaysOnInteraction()
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

        let mapCenter = CGPoint(x: mapSize.width / 2, y: mapSize.height / 2)
        let fitScale = max(mapSize.width / self.size.width, mapSize.height / self.size.height)

        let moveAction = SKAction.move(to: mapCenter, duration: 0.6)
        moveAction.timingMode = .easeInEaseOut

        let zoomAction = SKAction.scale(to: fitScale, duration: 0.6)
        zoomAction.timingMode = .easeInEaseOut

        cameraNode.run(SKAction.group([moveAction, zoomAction]), withKey: "cameraZoom")
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
        dismissOverlaysOnInteraction()
        let zoomFactor: CGFloat = 1.0 - (deltaY * 0.05)
        let newScale = cameraNode.xScale * zoomFactor
        let clampedScale = max(0.5, min(3.5, newScale))
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
        let clampedScale = max(0.5, min(3.5, newScale))
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

    // MARK: - Helpers

    /// Check if a named image exists in the asset catalog (platform-safe)
    private static func imageExists(named name: String) -> Bool {
        #if os(iOS)
        return UIImage(named: name) != nil
        #else
        return NSImage(named: name) != nil
        #endif
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
