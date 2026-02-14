import SpriteKit
import SwiftUI

// PlatformColor is defined in CityScene.swift

/// A tappable building on the city map
/// Each building shows its state (locked, available, under construction, complete)
class BuildingNode: SKNode {

    // MARK: - Properties

    let buildingId: String
    let buildingName: String
    let era: String

    private var buildingSprite: SKShapeNode!
    private var labelNode: SKLabelNode!
    private var stateIndicator: SKSpriteNode?
    private var currentState: BuildingState = .available

    // Building sizes (isometric style)
    private let buildingSize = CGSize(width: 120, height: 100)

    // MARK: - Initialization

    init(buildingId: String, buildingName: String, era: String) {
        self.buildingId = buildingId
        self.buildingName = buildingName
        self.era = era
        super.init()

        setupBuilding()
        setupLabel()
        updateState(.available)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupBuilding() {
        // Create isometric building shape (simple for now, can add Midjourney art later)
        let path = createIsometricBuildingPath()

        buildingSprite = SKShapeNode(path: path)
        buildingSprite.fillColor = era == "rome"
            ? PlatformColor(RenaissanceColors.terracotta.opacity(0.8))
            : PlatformColor(RenaissanceColors.ochre.opacity(0.8))
        buildingSprite.strokeColor = PlatformColor(RenaissanceColors.sepiaInk)
        buildingSprite.lineWidth = 2
        buildingSprite.zPosition = 1
        addChild(buildingSprite)

        // Add subtle shadow
        let shadow = SKShapeNode(path: path)
        shadow.fillColor = PlatformColor(RenaissanceColors.sepiaInk.opacity(0.2))
        shadow.strokeColor = .clear
        shadow.position = CGPoint(x: 5, y: -5)
        shadow.zPosition = 0
        addChild(shadow)
    }

    private func createIsometricBuildingPath() -> CGPath {
        // Simple isometric building shape
        // Looks like a 3D box viewed from above-right

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
        if buildingId == "duomo" || buildingId == "observatory" {
            path.move(to: CGPoint(x: 0, y: h * 0.2))
            path.addLine(to: CGPoint(x: 0, y: h * 0.5))     // Peak
            path.addLine(to: CGPoint(x: w * 0.3, y: h * 0.1))
        }

        return path
    }

    private func setupLabel() {
        // Building name label
        labelNode = SKLabelNode(text: buildingName)
        labelNode.fontName = "Cinzel-Regular"
        labelNode.fontSize = 14
        labelNode.fontColor = PlatformColor(RenaissanceColors.sepiaInk)
        labelNode.position = CGPoint(x: 0, y: -buildingSize.height * 0.4)
        labelNode.zPosition = 10
        addChild(labelNode)
    }

    // MARK: - State Management

    func updateState(_ state: BuildingState) {
        currentState = state

        // Remove old indicator
        stateIndicator?.removeFromParent()

        // Update building appearance based on state
        switch state {
        case .locked:
            buildingSprite.alpha = 0.4
            addStateIcon("StateLocked")

        case .available:
            buildingSprite.alpha = 1.0
            addPulseAnimation()

        case .sketched:
            buildingSprite.alpha = 1.0
            buildingSprite.fillColor = PlatformColor(RenaissanceColors.ochre.opacity(0.2))
            addStateIcon("StateAvailable")

        case .construction:
            buildingSprite.alpha = 0.7
            addStateIcon("StateConstruction")
            addConstructionAnimation()

        case .complete:
            buildingSprite.alpha = 1.0
            buildingSprite.fillColor = PlatformColor(RenaissanceColors.sageGreen.opacity(0.3))
            addStateIcon("StateComplete")
        }
    }

    private func addStateIcon(_ imageName: String) {
        // Try to use custom state icons from Assets
        // SKSpriteNode(imageNamed:) works cross-platform
        let testSprite = SKSpriteNode(imageNamed: imageName)
        if testSprite.texture != nil {
            stateIndicator = testSprite
            stateIndicator?.size = CGSize(width: 30, height: 30)
        } else {
            // Fallback to colored circle
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

    private func addPulseAnimation() {
        // Gentle pulse to show building is available
        let scaleUp = SKAction.scale(to: 1.05, duration: 1.0)
        let scaleDown = SKAction.scale(to: 1.0, duration: 1.0)
        scaleUp.timingMode = .easeInEaseOut
        scaleDown.timingMode = .easeInEaseOut

        let pulse = SKAction.sequence([scaleUp, scaleDown])
        buildingSprite.run(SKAction.repeatForever(pulse))
    }

    private func addConstructionAnimation() {
        // Scaffolding effect - subtle shake
        let moveLeft = SKAction.moveBy(x: -2, y: 0, duration: 0.1)
        let moveRight = SKAction.moveBy(x: 4, y: 0, duration: 0.2)
        let moveBack = SKAction.moveBy(x: -2, y: 0, duration: 0.1)
        let wait = SKAction.wait(forDuration: 2.0)

        let shake = SKAction.sequence([moveLeft, moveRight, moveBack, wait])
        buildingSprite.run(SKAction.repeatForever(shake))
    }

    func animateTap() {
        // Bounce effect when tapped
        buildingSprite.removeAllActions()

        let scaleUp = SKAction.scale(to: 1.2, duration: 0.1)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
        scaleUp.timingMode = .easeOut
        scaleDown.timingMode = .easeIn

        let bounce = SKAction.sequence([scaleUp, scaleDown])
        buildingSprite.run(bounce) { [weak self] in
            // Restore state animation if needed
            if self?.currentState == .available {
                self?.addPulseAnimation()
            }
        }
    }

    // MARK: - Construction Progress

    func setConstructionProgress(_ progress: CGFloat) {
        // Visual feedback for how much of the building is "built"
        // progress: 0.0 to 1.0

        guard currentState == .construction else { return }

        // Gradually reveal the building
        let maskHeight = buildingSize.height * progress
        let maskNode = SKShapeNode(rectOf: CGSize(width: buildingSize.width, height: maskHeight))
        maskNode.position = CGPoint(x: 0, y: -buildingSize.height/2 + maskHeight/2)

        // Could use this for crop effect in future
    }
}
