import SpriteKit
import SwiftUI

/// Da Vinci stick figure player for the Workshop scene
/// Drawn with SKShapeNode paths — sepia ink stroke, faint warm brown fill
class PlayerNode: SKNode {

    // MARK: - Properties

    private var head: SKShapeNode!
    private var torso: SKShapeNode!
    private var leftArm: SKShapeNode!
    private var rightArm: SKShapeNode!
    private var leftLeg: SKShapeNode!
    private var rightLeg: SKShapeNode!

    private let strokeColor = PlatformColor(RenaissanceColors.sepiaInk)
    private let fillColor = PlatformColor(RenaissanceColors.warmBrown.opacity(0.25))
    private let lineWidth: CGFloat = 2.5

    /// Whether the player is currently walking
    private(set) var isWalking = false

    // MARK: - Initialization

    override init() {
        super.init()
        setupBody()
        startIdleAnimation()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Body Setup

    private func setupBody() {
        // Head — circle
        head = SKShapeNode(circleOfRadius: 12)
        head.fillColor = fillColor
        head.strokeColor = strokeColor
        head.lineWidth = lineWidth
        head.position = CGPoint(x: 0, y: 50)
        addChild(head)

        // Torso — vertical line
        let torsoPath = CGMutablePath()
        torsoPath.move(to: CGPoint(x: 0, y: 38))
        torsoPath.addLine(to: CGPoint(x: 0, y: 8))
        torso = SKShapeNode(path: torsoPath)
        torso.strokeColor = strokeColor
        torso.lineWidth = lineWidth
        addChild(torso)

        // Left arm — from shoulder out left
        let leftArmPath = CGMutablePath()
        leftArmPath.move(to: CGPoint(x: 0, y: 32))
        leftArmPath.addLine(to: CGPoint(x: -14, y: 18))
        leftArm = SKShapeNode(path: leftArmPath)
        leftArm.strokeColor = strokeColor
        leftArm.lineWidth = lineWidth
        addChild(leftArm)

        // Right arm — from shoulder out right
        let rightArmPath = CGMutablePath()
        rightArmPath.move(to: CGPoint(x: 0, y: 32))
        rightArmPath.addLine(to: CGPoint(x: 14, y: 18))
        rightArm = SKShapeNode(path: rightArmPath)
        rightArm.strokeColor = strokeColor
        rightArm.lineWidth = lineWidth
        addChild(rightArm)

        // Left leg — from hip out left
        let leftLegPath = CGMutablePath()
        leftLegPath.move(to: CGPoint(x: 0, y: 8))
        leftLegPath.addLine(to: CGPoint(x: -10, y: -14))
        leftLeg = SKShapeNode(path: leftLegPath)
        leftLeg.strokeColor = strokeColor
        leftLeg.lineWidth = lineWidth
        addChild(leftLeg)

        // Right leg — from hip out right
        let rightLegPath = CGMutablePath()
        rightLegPath.move(to: CGPoint(x: 0, y: 8))
        rightLegPath.addLine(to: CGPoint(x: 10, y: -14))
        rightLeg = SKShapeNode(path: rightLegPath)
        rightLeg.strokeColor = strokeColor
        rightLeg.lineWidth = lineWidth
        addChild(rightLeg)
    }

    // MARK: - Idle Animation (gentle breathing scale)

    private func startIdleAnimation() {
        let breatheIn = SKAction.scaleY(to: 1.02, duration: 1.5)
        breatheIn.timingMode = .easeInEaseOut
        let breatheOut = SKAction.scaleY(to: 1.0, duration: 1.5)
        breatheOut.timingMode = .easeInEaseOut
        let breathe = SKAction.sequence([breatheIn, breatheOut])
        run(SKAction.repeatForever(breathe), withKey: "idle")
    }

    // MARK: - Walking Animation

    private func startWalkAnimation() {
        removeAction(forKey: "idle")

        // Legs alternate ±15 degrees
        let legAngle: CGFloat = .pi / 12  // 15 degrees
        let legSwingDuration: TimeInterval = 0.2

        let leftLegForward = SKAction.rotate(toAngle: legAngle, duration: legSwingDuration)
        let leftLegBack = SKAction.rotate(toAngle: -legAngle, duration: legSwingDuration)
        let leftLegCycle = SKAction.sequence([leftLegForward, leftLegBack])
        leftLeg.run(SKAction.repeatForever(leftLegCycle), withKey: "walk")

        let rightLegForward = SKAction.rotate(toAngle: -legAngle, duration: legSwingDuration)
        let rightLegBack = SKAction.rotate(toAngle: legAngle, duration: legSwingDuration)
        let rightLegCycle = SKAction.sequence([rightLegForward, rightLegBack])
        rightLeg.run(SKAction.repeatForever(rightLegCycle), withKey: "walk")

        // Arms swing ±10 degrees (opposite to legs)
        let armAngle: CGFloat = .pi / 18  // 10 degrees
        let leftArmForward = SKAction.rotate(toAngle: -armAngle, duration: legSwingDuration)
        let leftArmBack = SKAction.rotate(toAngle: armAngle, duration: legSwingDuration)
        let leftArmCycle = SKAction.sequence([leftArmForward, leftArmBack])
        leftArm.run(SKAction.repeatForever(leftArmCycle), withKey: "walk")

        let rightArmForward = SKAction.rotate(toAngle: armAngle, duration: legSwingDuration)
        let rightArmBack = SKAction.rotate(toAngle: -armAngle, duration: legSwingDuration)
        let rightArmCycle = SKAction.sequence([rightArmForward, rightArmBack])
        rightArm.run(SKAction.repeatForever(rightArmCycle), withKey: "walk")

        // Subtle vertical bounce on the whole node
        let bounceUp = SKAction.moveBy(x: 0, y: 3, duration: legSwingDuration)
        bounceUp.timingMode = .easeOut
        let bounceDown = SKAction.moveBy(x: 0, y: -3, duration: legSwingDuration)
        bounceDown.timingMode = .easeIn
        let bounceCycle = SKAction.sequence([bounceUp, bounceDown])
        run(SKAction.repeatForever(bounceCycle), withKey: "bounce")
    }

    private func stopWalkAnimation() {
        leftLeg.removeAction(forKey: "walk")
        rightLeg.removeAction(forKey: "walk")
        leftArm.removeAction(forKey: "walk")
        rightArm.removeAction(forKey: "walk")
        removeAction(forKey: "bounce")

        // Reset rotations
        leftLeg.zRotation = 0
        rightLeg.zRotation = 0
        leftArm.zRotation = 0
        rightArm.zRotation = 0

        startIdleAnimation()
    }

    // MARK: - Walk To Destination (30-step lerp, same as CityScene)

    func walkTo(destination: CGPoint, duration: TimeInterval = 1.0, completion: (() -> Void)? = nil) {
        isWalking = true
        startWalkAnimation()

        let steps = 30
        let stepDuration = duration / Double(steps)
        let startPos = position
        let dx = (destination.x - startPos.x) / CGFloat(steps)
        let dy = (destination.y - startPos.y) / CGFloat(steps)

        var actions: [SKAction] = []
        for i in 1...steps {
            let step = SKAction.run { [weak self] in
                self?.position = CGPoint(
                    x: startPos.x + dx * CGFloat(i),
                    y: startPos.y + dy * CGFloat(i)
                )
            }
            actions.append(step)
            actions.append(SKAction.wait(forDuration: stepDuration))
        }

        actions.append(SKAction.run { [weak self] in
            self?.isWalking = false
            self?.stopWalkAnimation()
            completion?()
        })

        run(SKAction.sequence(actions), withKey: "walkTo")
    }

    // MARK: - Facing Direction

    func setFacingDirection(_ right: Bool) {
        xScale = right ? abs(xScale) : -abs(xScale)
    }
}
