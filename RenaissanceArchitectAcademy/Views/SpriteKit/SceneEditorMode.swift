import SpriteKit

#if DEBUG

/// Developer-only editor mode for repositioning nodes in SpriteKit scenes.
/// Press E (macOS) or triple-tap (iOS) to toggle.
/// Drag elements to reposition, arrow keys to nudge.
/// On deactivate, all positions are printed to console in copy-paste format.
class SceneEditorMode {

    // MARK: - State

    private(set) var isActive = false
    private weak var scene: SKScene?

    /// Registered draggable nodes: name → node
    private var registeredNodes: [(name: String, node: SKNode)] = []

    /// Currently selected node
    private var selectedName: String?
    private var selectedNode: SKNode?

    /// Visual overlays
    private var highlightBorder: SKShapeNode?
    private var coordinateLabel: SKLabelNode?
    private var coordinateBg: SKShapeNode?
    private var badgeNode: SKNode?

    /// Callbacks
    var onToggle: ((Bool) -> Void)?
    var onNodeSelected: ((String, SKNode) -> Void)?

    // MARK: - Init

    init(scene: SKScene) {
        self.scene = scene
    }

    // MARK: - Register Nodes

    func registerNode(_ node: SKNode, name: String) {
        registeredNodes.append((name: name, node: node))
    }

    // MARK: - Toggle

    func toggle() {
        isActive.toggle()
        if isActive {
            showBadge()
            print("🎨 EDITOR MODE ON — drag elements to reposition, arrows to nudge, E to finish")
        } else {
            deselect()
            hideBadge()
            dumpAllPositions()
            print("🎨 EDITOR MODE OFF — positions printed above ↑")
        }
        onToggle?(isActive)
    }

    // MARK: - Input Handlers (return true if consumed)

    /// Handle tap/click down — selects nearest registered node
    func handleTapDown(at point: CGPoint) -> Bool {
        guard isActive else { return false }

        // Find closest registered node within 80pt
        var bestDist: CGFloat = 80
        var bestEntry: (name: String, node: SKNode)?

        for entry in registeredNodes {
            let dist = hypot(entry.node.position.x - point.x, entry.node.position.y - point.y)
            if dist < bestDist {
                bestDist = dist
                bestEntry = entry
            }
        }

        if let entry = bestEntry {
            select(entry.name, node: entry.node)
        } else {
            deselect()
        }

        return bestEntry != nil
    }

    /// Handle drag — move selected node
    func handleDrag(to point: CGPoint) -> Bool {
        guard isActive, let node = selectedNode else { return false }
        node.position = point
        updateHighlight()
        updateCoordinateLabel()
        return true
    }

    /// Handle release — print position
    func handleRelease() -> Bool {
        guard isActive, let node = selectedNode, let name = selectedName else { return false }
        let p = node.position
        print("  \"\(name)\": CGPoint(x: \(Int(p.x)), y: \(Int(p.y)))")
        return true
    }

    /// Handle key press — E toggles, arrows nudge
    func handleKeyDown(_ keyCode: UInt16) -> Bool {
        // E key = toggle
        if keyCode == 14 {
            toggle()
            return true
        }

        guard isActive, let node = selectedNode else { return false }

        let nudge: CGFloat = 1
        switch keyCode {
        case 123: node.position.x -= nudge  // left arrow
        case 124: node.position.x += nudge  // right arrow
        case 125: node.position.y -= nudge  // down arrow
        case 126: node.position.y += nudge  // up arrow
        default: return false
        }

        updateHighlight()
        updateCoordinateLabel()
        return true
    }

    // MARK: - Selection

    private func select(_ name: String, node: SKNode) {
        deselect()
        selectedName = name
        selectedNode = node
        showHighlight(around: node)
        showCoordinateLabel(above: node)
        onNodeSelected?(name, node)
    }

    private func deselect() {
        highlightBorder?.removeFromParent()
        highlightBorder = nil
        coordinateLabel?.removeFromParent()
        coordinateLabel = nil
        coordinateBg?.removeFromParent()
        coordinateBg = nil
        selectedName = nil
        selectedNode = nil
    }

    // MARK: - Visual Feedback

    private func showHighlight(around node: SKNode) {
        let rect = CGRect(x: -65, y: -55, width: 130, height: 110)
        let border = SKShapeNode(rect: rect, cornerRadius: 6)
        border.strokeColor = .yellow
        border.lineWidth = 3
        border.fillColor = .clear
        border.zPosition = 9999
        border.name = "_editor_highlight"
        node.addChild(border)
        highlightBorder = border
    }

    private func updateHighlight() {
        // Highlight stays as child of selected node, so it moves automatically
    }

    private func showCoordinateLabel(above node: SKNode) {
        guard let scene = scene else { return }

        let label = SKLabelNode(text: coordText(for: node))
        label.fontName = "Menlo-Bold"
        label.fontSize = 14
        label.fontColor = .white
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.zPosition = 10001

        let bg = SKShapeNode(rectOf: CGSize(width: 180, height: 24), cornerRadius: 4)
        bg.fillColor = SKColor(red: 0, green: 0, blue: 0, alpha: 0.85)
        bg.strokeColor = .yellow
        bg.lineWidth = 1
        bg.zPosition = 10000
        bg.name = "_editor_coord_bg"

        // Position in scene space above the node
        let abovePos = CGPoint(x: node.position.x, y: node.position.y + 70)
        bg.position = abovePos
        label.position = abovePos

        scene.addChild(bg)
        scene.addChild(label)
        coordinateLabel = label
        coordinateBg = bg
    }

    private func updateCoordinateLabel() {
        guard let node = selectedNode else { return }
        coordinateLabel?.text = coordText(for: node)
        let abovePos = CGPoint(x: node.position.x, y: node.position.y + 70)
        coordinateLabel?.position = abovePos
        coordinateBg?.position = abovePos
    }

    private func coordText(for node: SKNode) -> String {
        "x: \(Int(node.position.x))  y: \(Int(node.position.y))"
    }

    // MARK: - Badge

    private func showBadge() {
        guard let scene = scene, let camera = scene.camera else { return }

        let container = SKNode()
        container.zPosition = 10000
        container.name = "_editor_badge"

        let bg = SKShapeNode(rectOf: CGSize(width: 200, height: 36), cornerRadius: 8)
        bg.fillColor = SKColor(red: 0.9, green: 0.1, blue: 0.1, alpha: 0.9)
        bg.strokeColor = .white
        bg.lineWidth = 2

        let label = SKLabelNode(text: "EDITOR MODE")
        label.fontName = "Menlo-Bold"
        label.fontSize = 16
        label.fontColor = .white
        label.verticalAlignmentMode = .center

        container.addChild(bg)
        container.addChild(label)

        // Position at bottom of camera view
        let viewSize = scene.view?.bounds.size ?? CGSize(width: 1024, height: 768)
        let scale = camera.xScale
        container.position = CGPoint(x: 0, y: -(viewSize.height * scale / 2) + 40)

        camera.addChild(container)
        badgeNode = container

        // Pulse animation
        let pulse = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.5, duration: 0.6),
            SKAction.fadeAlpha(to: 1.0, duration: 0.6)
        ])
        container.run(SKAction.repeatForever(pulse))
    }

    private func hideBadge() {
        badgeNode?.removeFromParent()
        badgeNode = nil
    }

    // MARK: - Dump Positions

    private func dumpAllPositions() {
        print("\n// ========== EDITOR MODE — ALL POSITIONS ==========")
        for entry in registeredNodes {
            let p = entry.node.position
            print("  \"\(entry.name)\": CGPoint(x: \(Int(p.x)), y: \(Int(p.y))),")
        }
        print("// ==================================================\n")
    }
}

#endif
