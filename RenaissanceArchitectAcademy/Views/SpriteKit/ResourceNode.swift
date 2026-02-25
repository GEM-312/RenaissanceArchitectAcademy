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
    case craftingRoom = "Crafting Room"

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
        case .craftingRoom: return []   // enters interior
        }
    }

    /// Whether this is a crafting/processing station (not a resource)
    var isCraftingStation: Bool {
        self == .workbench || self == .furnace || self == .craftingRoom
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
        case .market:       return "StationMarket"
        case .craftingRoom: return "StationCraftingRoom"
        default:            return nil  // pigmentTable, workbench, furnace use shapes
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
    private let spriteSize: CGFloat = 420

    private let strokeColor = PlatformColor(RenaissanceColors.sepiaInk)
    private let sketchLineWidth: CGFloat = 4.0

    // MARK: - Initialization

    init(stationType: ResourceStationType) {
        self.stationType = stationType
        super.init()
        setupVisual()
        setupLabel()
        if !stationType.isCraftingStation || stationType == .craftingRoom {
            if stationType != .craftingRoom { setupCountLabel() }
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

            // Invisible shape for hit testing and animations
            bodyShape = SKShapeNode(circleOfRadius: spriteSize / 2)
            bodyShape.fillColor = .clear
            bodyShape.strokeColor = .clear
            bodyShape.zPosition = 0
            addChild(bodyShape)
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
        case .craftingRoom:
            bodyShape = createCraftingRoom()
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
        path.move(to: CGPoint(x: -160, y: -80))
        path.addLine(to: CGPoint(x: -100, y: 60))
        path.addLine(to: CGPoint(x: -40, y: 20))
        path.addLine(to: CGPoint(x: 0, y: 100))
        path.addLine(to: CGPoint(x: 60, y: 40))
        path.addLine(to: CGPoint(x: 140, y: 80))
        path.addLine(to: CGPoint(x: 160, y: -80))
        path.closeSubpath()
        // Chisel mark lines
        path.move(to: CGPoint(x: -60, y: 0))
        path.addLine(to: CGPoint(x: -20, y: -40))
        path.move(to: CGPoint(x: 40, y: 20))
        path.addLine(to: CGPoint(x: 80, y: -20))

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
        path.move(to: CGPoint(x: -160, y: -60))
        path.addCurve(to: CGPoint(x: 0, y: -60),
                      control1: CGPoint(x: -120, y: -100),
                      control2: CGPoint(x: -40, y: -20))
        path.addCurve(to: CGPoint(x: 160, y: -60),
                      control1: CGPoint(x: 40, y: -100),
                      control2: CGPoint(x: 120, y: -20))
        path.addLine(to: CGPoint(x: 160, y: 40))
        path.addCurve(to: CGPoint(x: 0, y: 40),
                      control1: CGPoint(x: 120, y: 80),
                      control2: CGPoint(x: 40, y: 0))
        path.addCurve(to: CGPoint(x: -160, y: 40),
                      control1: CGPoint(x: -40, y: 80),
                      control2: CGPoint(x: -120, y: 0))
        path.closeSubpath()
        // Inner wave lines
        path.move(to: CGPoint(x: -100, y: 0))
        path.addCurve(to: CGPoint(x: 100, y: 0),
                      control1: CGPoint(x: -40, y: 32),
                      control2: CGPoint(x: 40, y: -32))

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
        path.move(to: CGPoint(x: -160, y: -80))
        path.addLine(to: CGPoint(x: -20, y: 120))
        path.addLine(to: CGPoint(x: 20, y: 120))
        path.addLine(to: CGPoint(x: 160, y: -80))
        path.closeSubpath()
        // Crater opening
        path.move(to: CGPoint(x: -20, y: 120))
        path.addLine(to: CGPoint(x: -12, y: 100))
        path.addLine(to: CGPoint(x: 12, y: 100))
        path.addLine(to: CGPoint(x: 20, y: 120))
        // Smoke spiral
        path.move(to: CGPoint(x: 0, y: 128))
        path.addCurve(to: CGPoint(x: 32, y: 180),
                      control1: CGPoint(x: 24, y: 136),
                      control2: CGPoint(x: 40, y: 160))
        path.addCurve(to: CGPoint(x: -8, y: 208),
                      control1: CGPoint(x: 24, y: 200),
                      control2: CGPoint(x: 8, y: 208))

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
        path.addEllipse(in: CGRect(x: -140, y: -72, width: 280, height: 144))
        // Clay chunks inside
        path.addEllipse(in: CGRect(x: -60, y: -32, width: 48, height: 40))
        path.addEllipse(in: CGRect(x: 20, y: -20, width: 40, height: 32))
        path.addEllipse(in: CGRect(x: -20, y: 12, width: 32, height: 28))

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
        path.move(to: CGPoint(x: -120, y: -80))
        path.addLine(to: CGPoint(x: -120, y: 40))
        path.addCurve(to: CGPoint(x: 120, y: 40),
                      control1: CGPoint(x: -120, y: 140),
                      control2: CGPoint(x: 120, y: 140))
        path.addLine(to: CGPoint(x: 120, y: -80))
        path.closeSubpath()
        // Crossed pickaxe handles
        path.move(to: CGPoint(x: -48, y: -60))
        path.addLine(to: CGPoint(x: 48, y: 40))
        path.move(to: CGPoint(x: 48, y: -60))
        path.addLine(to: CGPoint(x: -48, y: 40))

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
        tablePath.addRect(CGRect(x: -160, y: -20, width: 320, height: 40))
        // Table legs
        tablePath.move(to: CGPoint(x: -120, y: -20))
        tablePath.addLine(to: CGPoint(x: -120, y: -80))
        tablePath.move(to: CGPoint(x: 120, y: -20))
        tablePath.addLine(to: CGPoint(x: 120, y: -80))

        let table = SKShapeNode(path: tablePath)
        table.fillColor = PlatformColor(RenaissanceColors.warmBrown.opacity(0.3))
        table.strokeColor = strokeColor
        table.lineWidth = sketchLineWidth
        container.addChild(table)

        // Three pigment circles on the table
        let colors: [(PlatformColor, CGFloat)] = [
            (PlatformColor(RenaissanceColors.errorRed.opacity(0.6)), -88),
            (PlatformColor(RenaissanceColors.renaissanceBlue.opacity(0.6)), 0),
            (PlatformColor(RenaissanceColors.sageGreen.opacity(0.6)), 88)
        ]
        for (color, xPos) in colors {
            let circle = SKShapeNode(circleOfRadius: 32)
            circle.fillColor = color
            circle.strokeColor = strokeColor
            circle.lineWidth = 4
            circle.position = CGPoint(x: xPos, y: 48)
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
        let treePositions: [CGFloat] = [-80, 20, 100]
        let treeHeights: [CGFloat] = [140, 180, 120]
        for (xPos, height) in zip(treePositions, treeHeights) {
            // Trunk
            let trunkPath = CGMutablePath()
            trunkPath.addRect(CGRect(x: xPos - 12, y: -60, width: 24, height: height * 0.4))
            let trunk = SKShapeNode(path: trunkPath)
            trunk.fillColor = PlatformColor(RenaissanceColors.warmBrown.opacity(0.5))
            trunk.strokeColor = strokeColor
            trunk.lineWidth = 4
            container.addChild(trunk)

            // Foliage
            let foliage = SKShapeNode(circleOfRadius: height * 0.3)
            foliage.fillColor = PlatformColor(RenaissanceColors.sageGreen.opacity(0.5))
            foliage.strokeColor = strokeColor
            foliage.lineWidth = 4
            foliage.position = CGPoint(x: xPos, y: -60 + height * 0.4 + height * 0.25)
            container.addChild(foliage)
        }

        // Axe leaning against tree
        let axePath = CGMutablePath()
        axePath.move(to: CGPoint(x: -120, y: -80))
        axePath.addLine(to: CGPoint(x: -88, y: 40))  // handle
        axePath.move(to: CGPoint(x: -104, y: 20))
        axePath.addLine(to: CGPoint(x: -72, y: 32))   // blade
        let axe = SKShapeNode(path: axePath)
        axe.strokeColor = strokeColor
        axe.lineWidth = 4
        container.addChild(axe)

        return container
    }

    /// Market stall with hanging goods
    private func createMarket() -> SKShapeNode {
        let path = CGMutablePath()
        // Stall frame (tent/awning shape)
        path.move(to: CGPoint(x: -160, y: -60))
        path.addLine(to: CGPoint(x: -160, y: 60))
        path.addLine(to: CGPoint(x: -180, y: 100))  // awning peak left
        path.addLine(to: CGPoint(x: 0, y: 120))     // top center
        path.addLine(to: CGPoint(x: 180, y: 100))   // awning peak right
        path.addLine(to: CGPoint(x: 160, y: 60))
        path.addLine(to: CGPoint(x: 160, y: -60))
        path.closeSubpath()
        // Counter/table
        path.addRect(CGRect(x: -140, y: -60, width: 280, height: 32))
        // Hanging goods (circles for silk bolts, lead ingots)
        path.addEllipse(in: CGRect(x: -100, y: 0, width: 48, height: 40))
        path.addEllipse(in: CGRect(x: -20, y: 8, width: 40, height: 32))
        path.addEllipse(in: CGRect(x: 60, y: 0, width: 48, height: 40))

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
        path.addRect(CGRect(x: -180, y: 0, width: 360, height: 48))
        // Legs
        path.move(to: CGPoint(x: -140, y: 0))
        path.addLine(to: CGPoint(x: -140, y: -72))
        path.move(to: CGPoint(x: 140, y: 0))
        path.addLine(to: CGPoint(x: 140, y: -72))
        // Tool sketches on top — hammer
        path.move(to: CGPoint(x: -80, y: 48))
        path.addLine(to: CGPoint(x: -80, y: 100))
        path.addRect(CGRect(x: -104, y: 100, width: 48, height: 24))
        // Tool sketches — saw
        path.move(to: CGPoint(x: 60, y: 48))
        path.addLine(to: CGPoint(x: 60, y: 88))
        path.addLine(to: CGPoint(x: 100, y: 88))
        path.addLine(to: CGPoint(x: 100, y: 72))
        path.addLine(to: CGPoint(x: 60, y: 72))

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
        path.move(to: CGPoint(x: -120, y: -80))
        path.addLine(to: CGPoint(x: -88, y: 80))
        path.addLine(to: CGPoint(x: 88, y: 80))
        path.addLine(to: CGPoint(x: 120, y: -80))
        path.closeSubpath()
        // Chimney
        path.addRect(CGRect(x: 20, y: 80, width: 48, height: 80))
        // Opening
        path.addRect(CGRect(x: -48, y: -60, width: 96, height: 64))
        // Brick lines
        path.move(to: CGPoint(x: -104, y: 0))
        path.addLine(to: CGPoint(x: 104, y: 0))
        path.move(to: CGPoint(x: -96, y: 40))
        path.addLine(to: CGPoint(x: 96, y: 40))

        let shape = SKShapeNode(path: path)
        shape.fillColor = PlatformColor(RenaissanceColors.terracotta.opacity(0.35))
        shape.strokeColor = strokeColor
        shape.lineWidth = sketchLineWidth
        return shape
    }

    /// Building with arched door (enter interior)
    private func createCraftingRoom() -> SKShapeNode {
        let path = CGMutablePath()
        // Building body
        path.addRect(CGRect(x: -160, y: -100, width: 320, height: 220))
        // Roof (triangle)
        path.move(to: CGPoint(x: -180, y: 120))
        path.addLine(to: CGPoint(x: 0, y: 200))
        path.addLine(to: CGPoint(x: 180, y: 120))
        path.closeSubpath()
        // Arched door
        path.move(to: CGPoint(x: -50, y: -100))
        path.addLine(to: CGPoint(x: -50, y: 20))
        path.addCurve(to: CGPoint(x: 50, y: 20),
                      control1: CGPoint(x: -50, y: 80),
                      control2: CGPoint(x: 50, y: 80))
        path.addLine(to: CGPoint(x: 50, y: -100))
        // Window left
        path.addRect(CGRect(x: -130, y: 20, width: 50, height: 50))
        // Window right
        path.addRect(CGRect(x: 80, y: 20, width: 50, height: 50))
        // Chimney
        path.addRect(CGRect(x: 80, y: 120, width: 40, height: 60))

        let shape = SKShapeNode(path: path)
        shape.fillColor = PlatformColor(RenaissanceColors.warmBrown.opacity(0.25))
        shape.strokeColor = strokeColor
        shape.lineWidth = sketchLineWidth
        return shape
    }

    // MARK: - Label

    private func setupLabel() {
        labelNode = SKLabelNode(text: stationType.label)
        labelNode.fontName = "Cinzel-Regular"
        labelNode.fontSize = 36
        labelNode.fontColor = strokeColor
        labelNode.position = CGPoint(x: 0, y: -140)
        labelNode.zPosition = 10
        addChild(labelNode)
    }

    // MARK: - Count Label

    private func setupCountLabel() {
        countLabel = SKLabelNode(text: "")
        countLabel?.fontName = "EBGaramond-Regular"
        countLabel?.fontSize = 32
        countLabel?.fontColor = PlatformColor(RenaissanceColors.warmBrown)
        countLabel?.position = CGPoint(x: 0, y: -175)
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
            } else {
                target.alpha = 1.0
                addPulseAnimation()
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
            if !self.isDepleted && (!self.stationType.isCraftingStation || self.stationType == .craftingRoom) {
                self.addPulseAnimation()
            }
        }
    }

    func showCollectionBurst() {
        // Particle burst when collecting
        let burstCount = 8
        for i in 0..<burstCount {
            let angle = (CGFloat(i) / CGFloat(burstCount)) * .pi * 2
            let particle = SKShapeNode(circleOfRadius: 12)
            particle.fillColor = PlatformColor(RenaissanceColors.goldSuccess.opacity(0.8))
            particle.strokeColor = .clear
            particle.position = .zero
            particle.zPosition = 20
            addChild(particle)

            let dest = CGPoint(x: cos(angle) * 160, y: sin(angle) * 160)
            let moveAction = SKAction.move(to: dest, duration: 0.4)
            moveAction.timingMode = .easeOut
            let fadeAction = SKAction.fadeOut(withDuration: 0.4)
            let group = SKAction.group([moveAction, fadeAction])

            particle.run(SKAction.sequence([group, SKAction.removeFromParent()]))
        }
    }
}
