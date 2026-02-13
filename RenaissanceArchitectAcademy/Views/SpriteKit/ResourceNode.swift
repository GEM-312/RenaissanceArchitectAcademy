import SpriteKit
import SwiftUI

/// Types of resource stations in the Workshop scene
enum ResourceStationType: String, CaseIterable, Hashable {
    case quarry = "Quarry"
    case river = "River"
    case volcano = "Volcano"
    case clayPit = "Clay Pit"
    case mine = "Mine"
    case pigmentTable = "Pigment Table"
    case forest = "Forest"
    case market = "Market"
    case workbench = "Workbench"
    case furnace = "Furnace"

    /// Materials available at this station
    var materials: [Material] {
        switch self {
        case .quarry:       return [.limestone, .marbleDust, .marble]
        case .river:        return [.water, .sand]
        case .volcano:      return [.volcanicAsh]
        case .clayPit:      return [.clay]
        case .mine:         return [.ironOre, .lead]
        case .pigmentTable: return [.redOchre, .lapisBlue, .verdigrisGreen]
        case .forest:       return [.timber]
        case .market:       return [.silk, .lead, .marble]
        case .workbench:    return []   // crafting station
        case .furnace:      return []   // processing station
        }
    }

    /// Whether this is a crafting/processing station (not a resource)
    var isCraftingStation: Bool {
        self == .workbench || self == .furnace
    }

    /// Image asset name for this station (nil = use shape fallback)
    var imageName: String? {
        switch self {
        case .quarry:       return "StationQuarry"
        case .river:        return "StationRiver"
        case .volcano:      return "StationVolcano"
        case .clayPit:      return "StationClayPit"
        case .mine:         return "StationMine"
        case .forest:       return "StationForest"
        default:            return nil  // pigmentTable, market, workbench, furnace use shapes
        }
    }

    /// Label shown on the map
    var label: String { rawValue }
}

/// A tappable resource station on the Workshop map
/// Follows BuildingNode pattern: shape drawing, labels, tap bounce
class ResourceNode: SKNode {

    // MARK: - Properties

    let stationType: ResourceStationType
    private var bodyShape: SKShapeNode!
    private var spriteNode: SKSpriteNode?
    private var labelNode: SKLabelNode!
    private var countLabel: SKLabelNode?
    private var isDepleted = false

    /// Size for station sprite images (points)
    private let spriteSize: CGFloat = 120

    /// Volcano animation: 15 frames at 15fps
    private static let volcanoFrameCount = 15
    private static let volcanoFPS: TimeInterval = 1.0 / 15.0

    private let strokeColor = PlatformColor(RenaissanceColors.sepiaInk)
    private let sketchLineWidth: CGFloat = 2.0

    // MARK: - Initialization

    init(stationType: ResourceStationType) {
        self.stationType = stationType
        super.init()
        setupVisual()
        setupLabel()
        if !stationType.isCraftingStation {
            setupCountLabel()
            addPulseAnimation()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Visual Setup (image sprite or da Vinci sketch fallback)

    private func setupVisual() {
        // Try image sprite first
        if let imageName = stationType.imageName {
            let texture = SKTexture(imageNamed: imageName)
            let sprite = SKSpriteNode(texture: texture)
            sprite.size = CGSize(width: spriteSize, height: spriteSize)
            sprite.zPosition = 1
            addChild(sprite)
            spriteNode = sprite

            // Volcano: loop through 15 animation frames
            if stationType == .volcano {
                startVolcanoAnimation()
            }

            // Invisible shape for hit testing and animations
            bodyShape = SKShapeNode(circleOfRadius: spriteSize / 2)
            bodyShape.fillColor = .clear
            bodyShape.strokeColor = .clear
            bodyShape.zPosition = 0
            addChild(bodyShape)

            // Ground shadow under sprite
            let shadow = SKShapeNode(ellipseOf: CGSize(width: spriteSize * 0.8, height: spriteSize * 0.3))
            shadow.fillColor = PlatformColor(RenaissanceColors.sepiaInk.opacity(0.12))
            shadow.strokeColor = .clear
            shadow.position = CGPoint(x: 0, y: -spriteSize / 2 + 5)
            shadow.zPosition = 0
            addChild(shadow)
            return
        }

        // Fallback: hand-drawn shapes for stations without images
        switch stationType {
        case .quarry:
            bodyShape = createQuarry()
        case .river:
            bodyShape = createRiver()
        case .volcano:
            bodyShape = createVolcano()
        case .clayPit:
            bodyShape = createClayPit()
        case .mine:
            bodyShape = createMine()
        case .pigmentTable:
            bodyShape = createPigmentTable()
        case .forest:
            bodyShape = createForest()
        case .market:
            bodyShape = createMarket()
        case .workbench:
            bodyShape = createWorkbench()
        case .furnace:
            bodyShape = createFurnace()
        }

        bodyShape.zPosition = 1
        addChild(bodyShape)

        // Subtle shadow
        if let path = bodyShape.path {
            let shadow = SKShapeNode(path: path)
            shadow.fillColor = PlatformColor(RenaissanceColors.sepiaInk.opacity(0.15))
            shadow.strokeColor = .clear
            shadow.position = CGPoint(x: 4, y: -4)
            shadow.zPosition = 0
            addChild(shadow)
        }
    }

    // MARK: - Station Shapes

    /// Rock pile with chisel marks
    private func createQuarry() -> SKShapeNode {
        let path = CGMutablePath()
        // Rough rock pile shape
        path.move(to: CGPoint(x: -40, y: -20))
        path.addLine(to: CGPoint(x: -25, y: 15))
        path.addLine(to: CGPoint(x: -10, y: 5))
        path.addLine(to: CGPoint(x: 0, y: 25))
        path.addLine(to: CGPoint(x: 15, y: 10))
        path.addLine(to: CGPoint(x: 35, y: 20))
        path.addLine(to: CGPoint(x: 40, y: -20))
        path.closeSubpath()
        // Chisel mark lines
        path.move(to: CGPoint(x: -15, y: 0))
        path.addLine(to: CGPoint(x: -5, y: -10))
        path.move(to: CGPoint(x: 10, y: 5))
        path.addLine(to: CGPoint(x: 20, y: -5))

        let shape = SKShapeNode(path: path)
        shape.fillColor = PlatformColor(RenaissanceColors.stoneGray.opacity(0.4))
        shape.strokeColor = strokeColor
        shape.lineWidth = sketchLineWidth
        return shape
    }

    /// Wavy lines (da Vinci water studies)
    private func createRiver() -> SKShapeNode {
        let path = CGMutablePath()
        // Wavy pool shape
        path.move(to: CGPoint(x: -40, y: -15))
        path.addCurve(to: CGPoint(x: 0, y: -15),
                      control1: CGPoint(x: -30, y: -25),
                      control2: CGPoint(x: -10, y: -5))
        path.addCurve(to: CGPoint(x: 40, y: -15),
                      control1: CGPoint(x: 10, y: -25),
                      control2: CGPoint(x: 30, y: -5))
        path.addLine(to: CGPoint(x: 40, y: 10))
        path.addCurve(to: CGPoint(x: 0, y: 10),
                      control1: CGPoint(x: 30, y: 20),
                      control2: CGPoint(x: 10, y: 0))
        path.addCurve(to: CGPoint(x: -40, y: 10),
                      control1: CGPoint(x: -10, y: 20),
                      control2: CGPoint(x: -30, y: 0))
        path.closeSubpath()
        // Inner wave lines
        path.move(to: CGPoint(x: -25, y: 0))
        path.addCurve(to: CGPoint(x: 25, y: 0),
                      control1: CGPoint(x: -10, y: 8),
                      control2: CGPoint(x: 10, y: -8))

        let shape = SKShapeNode(path: path)
        shape.fillColor = PlatformColor(RenaissanceColors.renaissanceBlue.opacity(0.3))
        shape.strokeColor = PlatformColor(RenaissanceColors.renaissanceBlue)
        shape.lineWidth = sketchLineWidth
        return shape
    }

    /// Mountain with smoke spirals
    private func createVolcano() -> SKShapeNode {
        let path = CGMutablePath()
        // Mountain triangle
        path.move(to: CGPoint(x: -40, y: -20))
        path.addLine(to: CGPoint(x: -5, y: 30))
        path.addLine(to: CGPoint(x: 5, y: 30))
        path.addLine(to: CGPoint(x: 40, y: -20))
        path.closeSubpath()
        // Crater opening
        path.move(to: CGPoint(x: -5, y: 30))
        path.addLine(to: CGPoint(x: -3, y: 25))
        path.addLine(to: CGPoint(x: 3, y: 25))
        path.addLine(to: CGPoint(x: 5, y: 30))
        // Smoke spiral
        path.move(to: CGPoint(x: 0, y: 32))
        path.addCurve(to: CGPoint(x: 8, y: 45),
                      control1: CGPoint(x: 6, y: 34),
                      control2: CGPoint(x: 10, y: 40))
        path.addCurve(to: CGPoint(x: -2, y: 52),
                      control1: CGPoint(x: 6, y: 50),
                      control2: CGPoint(x: 2, y: 52))

        let shape = SKShapeNode(path: path)
        shape.fillColor = PlatformColor(RenaissanceColors.stoneGray.opacity(0.3))
        shape.strokeColor = strokeColor
        shape.lineWidth = sketchLineWidth
        return shape
    }

    /// Oval depression with chunks
    private func createClayPit() -> SKShapeNode {
        let path = CGMutablePath()
        // Oval pit
        path.addEllipse(in: CGRect(x: -35, y: -18, width: 70, height: 36))
        // Clay chunks inside
        path.addEllipse(in: CGRect(x: -15, y: -8, width: 12, height: 10))
        path.addEllipse(in: CGRect(x: 5, y: -5, width: 10, height: 8))
        path.addEllipse(in: CGRect(x: -5, y: 3, width: 8, height: 7))

        let shape = SKShapeNode(path: path)
        shape.fillColor = PlatformColor(RenaissanceColors.warmBrown.opacity(0.3))
        shape.strokeColor = strokeColor
        shape.lineWidth = sketchLineWidth
        return shape
    }

    /// Cave arch with crossed pickaxe
    private func createMine() -> SKShapeNode {
        let path = CGMutablePath()
        // Cave arch
        path.move(to: CGPoint(x: -30, y: -20))
        path.addLine(to: CGPoint(x: -30, y: 10))
        path.addCurve(to: CGPoint(x: 30, y: 10),
                      control1: CGPoint(x: -30, y: 35),
                      control2: CGPoint(x: 30, y: 35))
        path.addLine(to: CGPoint(x: 30, y: -20))
        path.closeSubpath()
        // Crossed pickaxe handles
        path.move(to: CGPoint(x: -12, y: -15))
        path.addLine(to: CGPoint(x: 12, y: 10))
        path.move(to: CGPoint(x: 12, y: -15))
        path.addLine(to: CGPoint(x: -12, y: 10))

        let shape = SKShapeNode(path: path)
        shape.fillColor = PlatformColor(RenaissanceColors.stoneGray.opacity(0.25))
        shape.strokeColor = strokeColor
        shape.lineWidth = sketchLineWidth
        return shape
    }

    /// Table with 3 colored circles
    private func createPigmentTable() -> SKShapeNode {
        let container = SKShapeNode()
        container.strokeColor = .clear

        // Table top
        let tablePath = CGMutablePath()
        tablePath.addRect(CGRect(x: -40, y: -5, width: 80, height: 10))
        // Table legs
        tablePath.move(to: CGPoint(x: -30, y: -5))
        tablePath.addLine(to: CGPoint(x: -30, y: -20))
        tablePath.move(to: CGPoint(x: 30, y: -5))
        tablePath.addLine(to: CGPoint(x: 30, y: -20))

        let table = SKShapeNode(path: tablePath)
        table.fillColor = PlatformColor(RenaissanceColors.warmBrown.opacity(0.3))
        table.strokeColor = strokeColor
        table.lineWidth = sketchLineWidth
        container.addChild(table)

        // Three pigment circles on the table
        let colors: [(PlatformColor, CGFloat)] = [
            (PlatformColor(RenaissanceColors.errorRed.opacity(0.6)), -22),
            (PlatformColor(RenaissanceColors.renaissanceBlue.opacity(0.6)), 0),
            (PlatformColor(RenaissanceColors.sageGreen.opacity(0.6)), 22)
        ]
        for (color, xPos) in colors {
            let circle = SKShapeNode(circleOfRadius: 8)
            circle.fillColor = color
            circle.strokeColor = strokeColor
            circle.lineWidth = 1.5
            circle.position = CGPoint(x: xPos, y: 12)
            container.addChild(circle)
        }

        // Use the table path for the body shape reference
        bodyShape = table
        return container
    }

    /// Tree cluster with axe (da Vinci nature studies)
    private func createForest() -> SKShapeNode {
        let container = SKShapeNode()
        container.strokeColor = .clear

        // Three trees
        let treePositions: [CGFloat] = [-20, 5, 25]
        let treeHeights: [CGFloat] = [35, 45, 30]
        for (xPos, height) in zip(treePositions, treeHeights) {
            // Trunk
            let trunkPath = CGMutablePath()
            trunkPath.addRect(CGRect(x: xPos - 3, y: -15, width: 6, height: height * 0.4))
            let trunk = SKShapeNode(path: trunkPath)
            trunk.fillColor = PlatformColor(RenaissanceColors.warmBrown.opacity(0.5))
            trunk.strokeColor = strokeColor
            trunk.lineWidth = 1.5
            container.addChild(trunk)

            // Foliage
            let foliage = SKShapeNode(circleOfRadius: height * 0.3)
            foliage.fillColor = PlatformColor(RenaissanceColors.sageGreen.opacity(0.5))
            foliage.strokeColor = strokeColor
            foliage.lineWidth = 1.5
            foliage.position = CGPoint(x: xPos, y: -15 + height * 0.4 + height * 0.25)
            container.addChild(foliage)
        }

        // Axe leaning against tree
        let axePath = CGMutablePath()
        axePath.move(to: CGPoint(x: -30, y: -20))
        axePath.addLine(to: CGPoint(x: -22, y: 10))  // handle
        axePath.move(to: CGPoint(x: -26, y: 5))
        axePath.addLine(to: CGPoint(x: -18, y: 8))   // blade
        let axe = SKShapeNode(path: axePath)
        axe.strokeColor = strokeColor
        axe.lineWidth = 2
        container.addChild(axe)

        return container
    }

    /// Market stall with hanging goods
    private func createMarket() -> SKShapeNode {
        let path = CGMutablePath()
        // Stall frame (tent/awning shape)
        path.move(to: CGPoint(x: -40, y: -15))
        path.addLine(to: CGPoint(x: -40, y: 15))
        path.addLine(to: CGPoint(x: -45, y: 25))  // awning peak left
        path.addLine(to: CGPoint(x: 0, y: 30))    // top center
        path.addLine(to: CGPoint(x: 45, y: 25))   // awning peak right
        path.addLine(to: CGPoint(x: 40, y: 15))
        path.addLine(to: CGPoint(x: 40, y: -15))
        path.closeSubpath()
        // Counter/table
        path.addRect(CGRect(x: -35, y: -15, width: 70, height: 8))
        // Hanging goods (circles for silk bolts, lead ingots)
        path.addEllipse(in: CGRect(x: -25, y: 0, width: 12, height: 10))
        path.addEllipse(in: CGRect(x: -5, y: 2, width: 10, height: 8))
        path.addEllipse(in: CGRect(x: 15, y: 0, width: 12, height: 10))

        let shape = SKShapeNode(path: path)
        shape.fillColor = PlatformColor(RenaissanceColors.ochre.opacity(0.25))
        shape.strokeColor = strokeColor
        shape.lineWidth = sketchLineWidth
        return shape
    }

    /// Bench with tool sketches
    private func createWorkbench() -> SKShapeNode {
        let path = CGMutablePath()
        // Bench top
        path.addRect(CGRect(x: -45, y: 0, width: 90, height: 12))
        // Legs
        path.move(to: CGPoint(x: -35, y: 0))
        path.addLine(to: CGPoint(x: -35, y: -18))
        path.move(to: CGPoint(x: 35, y: 0))
        path.addLine(to: CGPoint(x: 35, y: -18))
        // Tool sketches on top — hammer
        path.move(to: CGPoint(x: -20, y: 12))
        path.addLine(to: CGPoint(x: -20, y: 25))
        path.addRect(CGRect(x: -26, y: 25, width: 12, height: 6))
        // Tool sketches — saw
        path.move(to: CGPoint(x: 15, y: 12))
        path.addLine(to: CGPoint(x: 15, y: 22))
        path.addLine(to: CGPoint(x: 25, y: 22))
        path.addLine(to: CGPoint(x: 25, y: 18))
        path.addLine(to: CGPoint(x: 15, y: 18))

        let shape = SKShapeNode(path: path)
        shape.fillColor = PlatformColor(RenaissanceColors.warmBrown.opacity(0.35))
        shape.strokeColor = strokeColor
        shape.lineWidth = sketchLineWidth
        return shape
    }

    /// Trapezoidal brick with chimney
    private func createFurnace() -> SKShapeNode {
        let path = CGMutablePath()
        // Trapezoidal body
        path.move(to: CGPoint(x: -30, y: -20))
        path.addLine(to: CGPoint(x: -22, y: 20))
        path.addLine(to: CGPoint(x: 22, y: 20))
        path.addLine(to: CGPoint(x: 30, y: -20))
        path.closeSubpath()
        // Chimney
        path.addRect(CGRect(x: 5, y: 20, width: 12, height: 20))
        // Opening
        path.addRect(CGRect(x: -12, y: -15, width: 24, height: 16))
        // Brick lines
        path.move(to: CGPoint(x: -26, y: 0))
        path.addLine(to: CGPoint(x: 26, y: 0))
        path.move(to: CGPoint(x: -24, y: 10))
        path.addLine(to: CGPoint(x: 24, y: 10))

        let shape = SKShapeNode(path: path)
        shape.fillColor = PlatformColor(RenaissanceColors.terracotta.opacity(0.35))
        shape.strokeColor = strokeColor
        shape.lineWidth = sketchLineWidth
        return shape
    }

    // MARK: - Label

    private func setupLabel() {
        labelNode = SKLabelNode(text: stationType.label)
        labelNode.fontName = "Cinzel-Regular"
        labelNode.fontSize = 13
        labelNode.fontColor = strokeColor
        labelNode.position = CGPoint(x: 0, y: -35)
        labelNode.zPosition = 10
        addChild(labelNode)
    }

    // MARK: - Count Label

    private func setupCountLabel() {
        countLabel = SKLabelNode(text: "")
        countLabel?.fontName = "EBGaramond-Regular"
        countLabel?.fontSize = 12
        countLabel?.fontColor = PlatformColor(RenaissanceColors.warmBrown)
        countLabel?.position = CGPoint(x: 0, y: -48)
        countLabel?.zPosition = 10
        if let label = countLabel {
            addChild(label)
        }
    }

    // MARK: - Stock Updates

    func updateStock(_ totalCount: Int) {
        countLabel?.text = totalCount > 0 ? "Stock: \(totalCount)" : "Depleted"

        let newDepleted = totalCount <= 0
        if newDepleted != isDepleted {
            isDepleted = newDepleted
            let target: SKNode = spriteNode ?? bodyShape
            if isDepleted {
                target.alpha = 0.4
                target.removeAction(forKey: "pulse")
                // Pause volcano animation when depleted
                if stationType == .volcano { spriteNode?.removeAction(forKey: "volcanoAnim") }
            } else {
                target.alpha = 1.0
                addPulseAnimation()
                // Resume volcano animation when restocked
                if stationType == .volcano { startVolcanoAnimation() }
            }
        }
    }

    // MARK: - Animations

    private func addPulseAnimation() {
        let target: SKNode = spriteNode ?? bodyShape
        let scaleUp = SKAction.scale(to: 1.05, duration: 1.2)
        scaleUp.timingMode = .easeInEaseOut
        let scaleDown = SKAction.scale(to: 1.0, duration: 1.2)
        scaleDown.timingMode = .easeInEaseOut
        let pulse = SKAction.sequence([scaleUp, scaleDown])
        target.run(SKAction.repeatForever(pulse), withKey: "pulse")
    }

    func animateTap() {
        let target: SKNode = spriteNode ?? bodyShape
        target.removeAction(forKey: "pulse")

        let scaleUp = SKAction.scale(to: 1.2, duration: 0.1)
        scaleUp.timingMode = .easeOut
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
        scaleDown.timingMode = .easeIn
        let bounce = SKAction.sequence([scaleUp, scaleDown])

        target.run(bounce) { [weak self] in
            guard let self = self else { return }
            if !self.isDepleted && !self.stationType.isCraftingStation {
                self.addPulseAnimation()
            }
        }
    }

    /// Start looping volcano frame animation (VolcanoFrame00-14 at 15fps)
    private func startVolcanoAnimation() {
        guard let sprite = spriteNode else { return }
        let textures = (0..<Self.volcanoFrameCount).map { i in
            SKTexture(imageNamed: String(format: "VolcanoFrame%02d", i))
        }
        let animate = SKAction.animate(with: textures, timePerFrame: Self.volcanoFPS)
        sprite.run(SKAction.repeatForever(animate), withKey: "volcanoAnim")
    }

    func showCollectionBurst() {
        // Particle burst when collecting
        let burstCount = 8
        for i in 0..<burstCount {
            let angle = (CGFloat(i) / CGFloat(burstCount)) * .pi * 2
            let particle = SKShapeNode(circleOfRadius: 4)
            particle.fillColor = PlatformColor(RenaissanceColors.goldSuccess.opacity(0.8))
            particle.strokeColor = .clear
            particle.position = .zero
            particle.zPosition = 20
            addChild(particle)

            let dest = CGPoint(x: cos(angle) * 40, y: sin(angle) * 40)
            let moveAction = SKAction.move(to: dest, duration: 0.4)
            moveAction.timingMode = .easeOut
            let fadeAction = SKAction.fadeOut(withDuration: 0.4)
            let group = SKAction.group([moveAction, fadeAction])

            particle.run(SKAction.sequence([group, SKAction.removeFromParent()]))
        }
    }
}
