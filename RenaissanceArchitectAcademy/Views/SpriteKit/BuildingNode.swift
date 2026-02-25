import SpriteKit
import SwiftUI

// PlatformColor is defined in CityScene.swift

/// A tappable building on the city map
/// States: locked/available = wooden signpost, sketched/construction = blueprint, complete = building
class BuildingNode: SKNode {

    // MARK: - Properties

    let buildingId: String
    let buildingName: String
    let era: String

    /// Container for the current visual (signpost, blueprint, or building)
    private var visualContainer: SKNode!
    private var labelNode: SKLabelNode!
    private var stateIndicator: SKSpriteNode?
    private var tierBadge: SKNode?
    private(set) var currentState: BuildingState = .available

    // Building sizes (isometric style — used for blueprint/complete states)
    private let buildingSize = CGSize(width: 120, height: 100)

    // MARK: - Initialization

    init(buildingId: String, buildingName: String, era: String) {
        self.buildingId = buildingId
        self.buildingName = buildingName
        self.era = era
        super.init()

        visualContainer = SKNode()
        visualContainer.zPosition = 1
        addChild(visualContainer)

        updateState(.available)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - State Management

    func updateState(_ state: BuildingState) {
        currentState = state

        // Clear previous visual
        visualContainer.removeAllChildren()
        stateIndicator?.removeFromParent()
        stateIndicator = nil
        labelNode?.removeFromParent()
        labelNode = nil

        switch state {
        case .locked:
            setupSignpost(isLocked: true)

        case .available:
            setupSignpost(isLocked: false)
            addSignpostSway()

        case .sketched:
            setupBlueprint()
            addStateIcon("StateAvailable")

        case .construction:
            setupBlueprint()
            setupScaffolding()
            addStateIcon("StateConstruction")
            addConstructionAnimation()

        case .complete:
            setupCompletedBuilding()
            addStateIcon("StateComplete")
        }
    }

    // MARK: - Wooden Signpost (locked & available states)

    private func setupSignpost(isLocked: Bool) {
        let alpha: CGFloat = isLocked ? 0.5 : 1.0
        let poleColor = PlatformColor(RenaissanceColors.warmBrown)
        let plankColor = PlatformColor(RenaissanceColors.ochre)
        let plankFill = PlatformColor(RenaissanceColors.ochre.opacity(isLocked ? 0.3 : 0.7))

        // Vertical pole
        let pole = SKShapeNode(rectOf: CGSize(width: 6, height: 80))
        pole.fillColor = poleColor
        pole.strokeColor = PlatformColor(RenaissanceColors.sepiaInk.opacity(0.5))
        pole.lineWidth = 1
        pole.position = CGPoint(x: 0, y: -10)
        pole.alpha = alpha
        visualContainer.addChild(pole)

        // Horizontal crossbar at top
        let crossbar = SKShapeNode(rectOf: CGSize(width: 50, height: 5))
        crossbar.fillColor = poleColor
        crossbar.strokeColor = PlatformColor(RenaissanceColors.sepiaInk.opacity(0.4))
        crossbar.lineWidth = 0.5
        crossbar.position = CGPoint(x: 0, y: 28)
        crossbar.alpha = alpha
        visualContainer.addChild(crossbar)

        // Wooden plank (the sign board) — hanging below crossbar
        let plankWidth: CGFloat = 70
        let plankHeight: CGFloat = 40
        let plank = SKShapeNode(rectOf: CGSize(width: plankWidth, height: plankHeight), cornerRadius: 3)
        plank.fillColor = plankFill
        plank.strokeColor = PlatformColor(RenaissanceColors.warmBrown.opacity(0.6))
        plank.lineWidth = 1.5
        plank.position = CGPoint(x: 0, y: 2)
        plank.alpha = alpha
        plank.name = "plank"
        visualContainer.addChild(plank)

        // Wood grain lines on plank (horizontal)
        for yOffset: CGFloat in [-10, -3, 4, 11] {
            let grainPath = CGMutablePath()
            grainPath.move(to: CGPoint(x: -plankWidth / 2 + 4, y: yOffset))
            grainPath.addLine(to: CGPoint(x: plankWidth / 2 - 4, y: yOffset))
            let grain = SKShapeNode(path: grainPath)
            grain.strokeColor = PlatformColor(RenaissanceColors.warmBrown.opacity(isLocked ? 0.15 : 0.3))
            grain.lineWidth = 0.5
            grain.position = plank.position
            grain.alpha = alpha
            visualContainer.addChild(grain)
        }

        // Hanging chains/ropes (two short lines from crossbar to plank corners)
        for xOff: CGFloat in [-22, 22] {
            let ropePath = CGMutablePath()
            ropePath.move(to: CGPoint(x: xOff, y: 28))
            ropePath.addLine(to: CGPoint(x: xOff, y: 22))
            let rope = SKShapeNode(path: ropePath)
            rope.strokeColor = PlatformColor(RenaissanceColors.sepiaInk.opacity(0.3))
            rope.lineWidth = 1
            rope.alpha = alpha
            visualContainer.addChild(rope)
        }

        // Nail dots at top of plank
        for xOff: CGFloat in [-22, 22] {
            let nail = SKShapeNode(circleOfRadius: 2)
            nail.fillColor = PlatformColor(RenaissanceColors.sepiaInk.opacity(0.4))
            nail.strokeColor = .clear
            nail.position = CGPoint(x: xOff, y: 20)
            nail.alpha = alpha
            visualContainer.addChild(nail)
        }

        // Building name on the plank
        let nameLabel = SKLabelNode(text: shortName())
        nameLabel.fontName = "Cinzel-Regular"
        nameLabel.fontSize = 10
        nameLabel.fontColor = PlatformColor(RenaissanceColors.sepiaInk.opacity(isLocked ? 0.4 : 0.8))
        nameLabel.position = CGPoint(x: 0, y: 5)
        nameLabel.zPosition = 5
        nameLabel.verticalAlignmentMode = .center
        nameLabel.horizontalAlignmentMode = .center
        visualContainer.addChild(nameLabel)

        // Small building icon hint (below name, on the plank)
        let iconLabel = SKLabelNode(text: buildingIcon())
        iconLabel.fontSize = 12
        iconLabel.position = CGPoint(x: 0, y: -7)
        iconLabel.zPosition = 5
        iconLabel.verticalAlignmentMode = .center
        iconLabel.alpha = isLocked ? 0.3 : 0.6
        visualContainer.addChild(iconLabel)

        // Ground base (small mound)
        let basePath = CGMutablePath()
        basePath.addEllipse(in: CGRect(x: -18, y: -55, width: 36, height: 12))
        let base = SKShapeNode(path: basePath)
        base.fillColor = PlatformColor(RenaissanceColors.warmBrown.opacity(0.2))
        base.strokeColor = .clear
        base.alpha = alpha
        visualContainer.addChild(base)

        // Lock icon for locked state
        if isLocked {
            let lockLabel = SKLabelNode(text: "🔒")
            lockLabel.fontSize = 14
            lockLabel.position = CGPoint(x: 28, y: 25)
            lockLabel.zPosition = 15
            visualContainer.addChild(lockLabel)
        }

        // Full name label below the sign
        labelNode = SKLabelNode(text: buildingName)
        labelNode.fontName = "Mulish-Light"
        labelNode.fontSize = 11
        labelNode.fontColor = PlatformColor(RenaissanceColors.sepiaInk.opacity(isLocked ? 0.35 : 0.6))
        labelNode.position = CGPoint(x: 0, y: -62)
        labelNode.zPosition = 10
        addChild(labelNode)
    }

    /// Short name that fits on the signpost plank
    private func shortName() -> String {
        switch buildingName {
        case "Roman Baths": return "Baths"
        case "Roman Roads": return "Roads"
        case "Siege Workshop": return "Siege"
        case "Botanical Garden": return "Garden"
        case "Anatomy Theater": return "Anatomy"
        case "Leonardo's Workshop": return "Leonardo"
        case "Flying Machine": return "Flying"
        case "Vatican Observatory": return "Vatican"
        case "Printing Press": return "Press"
        case "Il Duomo": return "Duomo"
        default: return buildingName
        }
    }

    /// Small icon/emoji hint for the building type
    private func buildingIcon() -> String {
        switch buildingId {
        case "aqueduct": return "💧"
        case "colosseum": return "🏛"
        case "romanBaths": return "♨️"
        case "pantheon": return "⭕"
        case "romanRoads": return "🛤"
        case "harbor": return "⚓"
        case "siegeWorkshop": return "🛡"
        case "insula": return "🏠"
        case "duomo": return "⛪"
        case "botanicalGarden": return "🌿"
        case "glassworks": return "💎"
        case "arsenal": return "🔨"
        case "anatomyTheater": return "🧬"
        case "leonardoWorkshop": return "⚙️"
        case "flyingMachine": return "✈️"
        case "vaticanObservatory": return "⭐"
        case "printingPress": return "📖"
        default: return "🏗"
        }
    }

    /// Gentle sway animation for available signpost
    private func addSignpostSway() {
        guard let plank = visualContainer.childNode(withName: "plank") else { return }

        let rotateLeft = SKAction.rotate(toAngle: 0.03, duration: 1.5)
        rotateLeft.timingMode = .easeInEaseOut
        let rotateRight = SKAction.rotate(toAngle: -0.03, duration: 1.5)
        rotateRight.timingMode = .easeInEaseOut

        let sway = SKAction.sequence([rotateLeft, rotateRight])
        plank.run(SKAction.repeatForever(sway))
    }

    // MARK: - Blueprint (sketched & construction states)

    private func setupBlueprint() {
        let path = createIsometricBuildingPath()

        let blueprint = SKShapeNode(path: path)
        blueprint.fillColor = PlatformColor(RenaissanceColors.ochre.opacity(0.15))
        blueprint.strokeColor = PlatformColor(RenaissanceColors.blueprintBlue.opacity(0.5))
        blueprint.lineWidth = 2
        // Dashed outline for blueprint look
        blueprint.path = path.copy(dashingWithPhase: 0, lengths: [8, 5])
        visualContainer.addChild(blueprint)

        // Inner lines for architectural detail
        let innerPath = CGMutablePath()
        let w = buildingSize.width
        let h = buildingSize.height
        // Horizontal center line
        innerPath.move(to: CGPoint(x: -w * 0.35, y: 0))
        innerPath.addLine(to: CGPoint(x: w * 0.35, y: 0))
        // Vertical center line
        innerPath.move(to: CGPoint(x: 0, y: -h * 0.15))
        innerPath.addLine(to: CGPoint(x: 0, y: h * 0.15))

        let inner = SKShapeNode(path: innerPath)
        inner.strokeColor = PlatformColor(RenaissanceColors.blueprintBlue.opacity(0.25))
        inner.lineWidth = 0.8
        visualContainer.addChild(inner)

        // Building name label
        labelNode = SKLabelNode(text: buildingName)
        labelNode.fontName = "Cinzel-Regular"
        labelNode.fontSize = 12
        labelNode.fontColor = PlatformColor(RenaissanceColors.sepiaInk.opacity(0.6))
        labelNode.position = CGPoint(x: 0, y: -buildingSize.height * 0.4)
        labelNode.zPosition = 10
        addChild(labelNode)
    }

    // MARK: - Scaffolding (construction state overlay)

    private func setupScaffolding() {
        let w = buildingSize.width * 0.4
        let h = buildingSize.height * 0.3
        let scaffoldColor = PlatformColor(RenaissanceColors.warmBrown.opacity(0.4))

        // Vertical poles
        for xOff: CGFloat in [-w, 0, w] {
            let polePath = CGMutablePath()
            polePath.move(to: CGPoint(x: xOff, y: -h))
            polePath.addLine(to: CGPoint(x: xOff, y: h))
            let pole = SKShapeNode(path: polePath)
            pole.strokeColor = scaffoldColor
            pole.lineWidth = 2
            visualContainer.addChild(pole)
        }

        // Horizontal planks
        for yOff: CGFloat in [-h * 0.5, 0, h * 0.5] {
            let plankPath = CGMutablePath()
            plankPath.move(to: CGPoint(x: -w, y: yOff))
            plankPath.addLine(to: CGPoint(x: w, y: yOff))
            let plank = SKShapeNode(path: plankPath)
            plank.strokeColor = scaffoldColor
            plank.lineWidth = 1.5
            visualContainer.addChild(plank)
        }

        // Diagonal braces
        let bracePath = CGMutablePath()
        bracePath.move(to: CGPoint(x: -w, y: -h))
        bracePath.addLine(to: CGPoint(x: 0, y: h))
        bracePath.move(to: CGPoint(x: 0, y: -h))
        bracePath.addLine(to: CGPoint(x: w, y: h))
        let brace = SKShapeNode(path: bracePath)
        brace.strokeColor = PlatformColor(RenaissanceColors.warmBrown.opacity(0.25))
        brace.lineWidth = 1
        visualContainer.addChild(brace)
    }

    // MARK: - Completed Building

    private func setupCompletedBuilding() {
        let path = createIsometricBuildingPath()

        let building = SKShapeNode(path: path)
        building.fillColor = era == "rome"
            ? PlatformColor(RenaissanceColors.terracotta.opacity(0.8))
            : PlatformColor(RenaissanceColors.ochre.opacity(0.8))
        building.strokeColor = PlatformColor(RenaissanceColors.sepiaInk)
        building.lineWidth = 2
        visualContainer.addChild(building)

        // Shadow
        let shadow = SKShapeNode(path: path)
        shadow.fillColor = PlatformColor(RenaissanceColors.sepiaInk.opacity(0.15))
        shadow.strokeColor = .clear
        shadow.position = CGPoint(x: 4, y: -4)
        shadow.zPosition = -1
        visualContainer.addChild(shadow)

        // Completion glow
        let glow = SKShapeNode(circleOfRadius: 35)
        glow.fillColor = PlatformColor(RenaissanceColors.sageGreen.opacity(0.1))
        glow.strokeColor = PlatformColor(RenaissanceColors.sageGreen.opacity(0.3))
        glow.lineWidth = 1
        glow.zPosition = -2
        visualContainer.addChild(glow)

        // Building name label
        labelNode = SKLabelNode(text: buildingName)
        labelNode.fontName = "Cinzel-Regular"
        labelNode.fontSize = 14
        labelNode.fontColor = PlatformColor(RenaissanceColors.sepiaInk)
        labelNode.position = CGPoint(x: 0, y: -buildingSize.height * 0.4)
        labelNode.zPosition = 10
        addChild(labelNode)
    }

    private func createIsometricBuildingPath() -> CGPath {
        let path = CGMutablePath()
        let w = buildingSize.width
        let h = buildingSize.height

        // Base (diamond shape for isometric)
        path.move(to: CGPoint(x: 0, y: -h * 0.2))           // Bottom
        path.addLine(to: CGPoint(x: w * 0.5, y: 0))         // Right
        path.addLine(to: CGPoint(x: 0, y: h * 0.2))         // Top
        path.addLine(to: CGPoint(x: -w * 0.5, y: 0))        // Left
        path.closeSubpath()

        // Add roof peak for certain buildings
        if buildingId == "duomo" || buildingId == "vaticanObservatory" {
            path.move(to: CGPoint(x: 0, y: h * 0.2))
            path.addLine(to: CGPoint(x: 0, y: h * 0.5))     // Peak
            path.addLine(to: CGPoint(x: w * 0.3, y: h * 0.1))
        }

        return path
    }

    // MARK: - State Icons

    private func addStateIcon(_ imageName: String) {
        let testSprite = SKSpriteNode(imageNamed: imageName)
        if testSprite.texture != nil {
            stateIndicator = testSprite
            stateIndicator?.size = CGSize(width: 30, height: 30)
        } else {
            let circle = SKShapeNode(circleOfRadius: 12)
            circle.fillColor = stateColor(for: currentState)
            circle.strokeColor = PlatformColor(RenaissanceColors.sepiaInk)
            circle.lineWidth = 1

            let texture = SKView().texture(from: circle)
            stateIndicator = SKSpriteNode(texture: texture)
        }

        stateIndicator?.position = CGPoint(x: buildingSize.width * 0.3, y: buildingSize.height * 0.3)
        stateIndicator?.zPosition = 20
        if let indicator = stateIndicator {
            addChild(indicator)
        }
    }

    private func stateColor(for state: BuildingState) -> PlatformColor {
        switch state {
        case .locked: return PlatformColor(RenaissanceColors.stoneGray)
        case .available: return PlatformColor(RenaissanceColors.renaissanceBlue)
        case .sketched: return PlatformColor(RenaissanceColors.ochre)
        case .construction: return PlatformColor(RenaissanceColors.ochre)
        case .complete: return PlatformColor(RenaissanceColors.sageGreen)
        }
    }

    // MARK: - Animations

    private func addConstructionAnimation() {
        let moveLeft = SKAction.moveBy(x: -2, y: 0, duration: 0.1)
        let moveRight = SKAction.moveBy(x: 4, y: 0, duration: 0.2)
        let moveBack = SKAction.moveBy(x: -2, y: 0, duration: 0.1)
        let wait = SKAction.wait(forDuration: 2.0)

        let shake = SKAction.sequence([moveLeft, moveRight, moveBack, wait])
        visualContainer.run(SKAction.repeatForever(shake))
    }

    func animateTap() {
        visualContainer.removeAllActions()

        let scaleUp = SKAction.scale(to: 1.15, duration: 0.1)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
        scaleUp.timingMode = .easeOut
        scaleDown.timingMode = .easeIn

        let bounce = SKAction.sequence([scaleUp, scaleDown])
        visualContainer.run(bounce) { [weak self] in
            guard let self = self else { return }
            if self.currentState == .available {
                self.addSignpostSway()
            } else if self.currentState == .construction {
                self.addConstructionAnimation()
            }
        }
    }

    // MARK: - Tier Badge

    func setTierBadge(_ tierName: String) {
        tierBadge?.removeFromParent()

        let badgeColor: PlatformColor
        switch tierName {
        case "Apprentice":
            badgeColor = PlatformColor(RenaissanceColors.renaissanceBlue)
        case "Architect":
            badgeColor = PlatformColor(RenaissanceColors.ochre)
        case "Master":
            badgeColor = PlatformColor(RenaissanceColors.terracotta)
        default:
            badgeColor = PlatformColor(RenaissanceColors.stoneGray)
        }

        let container = SKNode()

        let dot = SKShapeNode(circleOfRadius: 5)
        dot.fillColor = badgeColor
        dot.strokeColor = PlatformColor(RenaissanceColors.sepiaInk.opacity(0.5))
        dot.lineWidth = 0.5
        container.addChild(dot)

        let label = SKLabelNode(text: tierName)
        label.fontName = "Cinzel-Regular"
        label.fontSize = 9
        label.fontColor = badgeColor
        label.horizontalAlignmentMode = .left
        label.verticalAlignmentMode = .center
        label.position = CGPoint(x: 8, y: 0)
        container.addChild(label)

        container.position = CGPoint(x: -buildingSize.width * 0.3, y: -buildingSize.height * 0.55)
        container.zPosition = 25
        addChild(container)
        tierBadge = container
    }

    // MARK: - Construction Progress

    func setConstructionProgress(_ progress: CGFloat) {
        guard currentState == .construction else { return }

        let maskHeight = buildingSize.height * progress
        let maskNode = SKShapeNode(rectOf: CGSize(width: buildingSize.width, height: maskHeight))
        maskNode.position = CGPoint(x: 0, y: -buildingSize.height/2 + maskHeight/2)
    }
}
