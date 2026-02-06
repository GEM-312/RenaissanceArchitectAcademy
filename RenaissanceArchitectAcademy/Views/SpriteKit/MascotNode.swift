import SpriteKit
import SwiftUI

#if os(iOS)
import UIKit
typealias PlatformColor = UIColor
#else
import AppKit
typealias PlatformColor = NSColor
#endif

/// Mascot characters for the city map - Splash (watercolor blob) and Bird companion
class MascotNode: SKNode {

    // MARK: - Child Nodes

    private var splashBody: SKShapeNode!
    private var leftEye: SKShapeNode!
    private var rightEye: SKShapeNode!
    private var smile: SKShapeNode!
    private var birdBody: SKShapeNode!
    private var birdWing: SKShapeNode!

    // Animation state
    private var isWalking = false
    private var targetPosition: CGPoint?
    var onReachedDestination: (() -> Void)?

    // MARK: - Initialization

    override init() {
        super.init()
        setupSplash()
        setupBird()
        startIdleAnimations()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup Splash Character

    private func setupSplash() {
        // Main body - organic blob shape
        let bodyPath = createBlobPath(width: 80, height: 100)
        splashBody = SKShapeNode(path: bodyPath)
        splashBody.fillColor = PlatformColor(RenaissanceColors.ochre)
        splashBody.strokeColor = PlatformColor(RenaissanceColors.warmBrown)
        splashBody.lineWidth = 2
        splashBody.zPosition = 10
        addChild(splashBody)

        // Left eye
        leftEye = SKShapeNode(ellipseOf: CGSize(width: 14, height: 16))
        leftEye.fillColor = .white
        leftEye.strokeColor = .clear
        leftEye.position = CGPoint(x: -15, y: 20)
        leftEye.zPosition = 11
        splashBody.addChild(leftEye)

        // Left pupil
        let leftPupil = SKShapeNode(circleOfRadius: 5)
        leftPupil.fillColor = PlatformColor(RenaissanceColors.sepiaInk)
        leftPupil.strokeColor = .clear
        leftPupil.position = CGPoint(x: 0, y: -2)
        leftPupil.name = "leftPupil"
        leftEye.addChild(leftPupil)

        // Right eye
        rightEye = SKShapeNode(ellipseOf: CGSize(width: 14, height: 16))
        rightEye.fillColor = .white
        rightEye.strokeColor = .clear
        rightEye.position = CGPoint(x: 15, y: 20)
        rightEye.zPosition = 11
        splashBody.addChild(rightEye)

        // Right pupil
        let rightPupil = SKShapeNode(circleOfRadius: 5)
        rightPupil.fillColor = PlatformColor(RenaissanceColors.sepiaInk)
        rightPupil.strokeColor = .clear
        rightPupil.position = CGPoint(x: 0, y: -2)
        rightPupil.name = "rightPupil"
        rightEye.addChild(rightPupil)

        // Smile
        let smilePath = CGMutablePath()
        smilePath.move(to: CGPoint(x: -12, y: 0))
        smilePath.addQuadCurve(to: CGPoint(x: 12, y: 0), control: CGPoint(x: 0, y: -10))
        smile = SKShapeNode(path: smilePath)
        smile.strokeColor = PlatformColor(RenaissanceColors.sepiaInk)
        smile.lineWidth = 3
        smile.lineCap = .round
        smile.position = CGPoint(x: 0, y: -5)
        smile.zPosition = 11
        splashBody.addChild(smile)

        // Ink drips at bottom
        for i in 0..<3 {
            let drip = SKShapeNode(ellipseOf: CGSize(width: 8, height: CGFloat.random(in: 15...30)))
            drip.fillColor = PlatformColor(RenaissanceColors.warmBrown.opacity(0.7))
            drip.strokeColor = .clear
            drip.position = CGPoint(x: CGFloat(i - 1) * 20, y: -55)
            drip.zPosition = 9
            splashBody.addChild(drip)

            // Drip animation
            let dripAction = SKAction.sequence([
                SKAction.moveBy(x: 0, y: -5, duration: 1.0),
                SKAction.moveBy(x: 0, y: 5, duration: 1.0)
            ])
            drip.run(SKAction.repeatForever(dripAction))
        }
    }

    // MARK: - Setup Bird Companion

    private func setupBird() {
        // Bird container
        let birdContainer = SKNode()
        birdContainer.position = CGPoint(x: 60, y: 40)
        birdContainer.zPosition = 12
        birdContainer.name = "bird"
        addChild(birdContainer)

        // Bird body
        birdBody = SKShapeNode(ellipseOf: CGSize(width: 30, height: 25))
        birdBody.fillColor = PlatformColor(RenaissanceColors.renaissanceBlue)
        birdBody.strokeColor = .clear
        birdContainer.addChild(birdBody)

        // Bird head
        let head = SKShapeNode(circleOfRadius: 12)
        head.fillColor = PlatformColor(RenaissanceColors.renaissanceBlue)
        head.strokeColor = .clear
        head.position = CGPoint(x: 12, y: 10)
        birdContainer.addChild(head)

        // Bird eye
        let eye = SKShapeNode(circleOfRadius: 4)
        eye.fillColor = PlatformColor(RenaissanceColors.sepiaInk)
        eye.strokeColor = .clear
        eye.position = CGPoint(x: 16, y: 12)
        birdContainer.addChild(eye)

        // Bird beak
        let beakPath = CGMutablePath()
        beakPath.move(to: CGPoint(x: 0, y: 0))
        beakPath.addLine(to: CGPoint(x: 12, y: 0))
        beakPath.addLine(to: CGPoint(x: 0, y: -5))
        beakPath.closeSubpath()
        let beak = SKShapeNode(path: beakPath)
        beak.fillColor = PlatformColor(RenaissanceColors.ochre)
        beak.strokeColor = .clear
        beak.position = CGPoint(x: 22, y: 10)
        birdContainer.addChild(beak)

        // Bird wing
        birdWing = SKShapeNode(ellipseOf: CGSize(width: 18, height: 10))
        birdWing.fillColor = PlatformColor(RenaissanceColors.deepTeal)
        birdWing.strokeColor = .clear
        birdWing.position = CGPoint(x: -5, y: 5)
        birdWing.zRotation = 0.3
        birdContainer.addChild(birdWing)

        // Bird bobbing animation
        let bobAction = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 8, duration: 0.8),
            SKAction.moveBy(x: 0, y: -8, duration: 0.8)
        ])
        birdContainer.run(SKAction.repeatForever(bobAction))

        // Wing flap animation
        let flapAction = SKAction.sequence([
            SKAction.rotate(toAngle: 0.5, duration: 0.15),
            SKAction.rotate(toAngle: 0.1, duration: 0.15)
        ])
        birdWing.run(SKAction.repeatForever(flapAction))
    }

    // MARK: - Animations

    private func startIdleAnimations() {
        // Splash wobble
        let wobbleAction = SKAction.sequence([
            SKAction.rotate(toAngle: 0.05, duration: 1.5),
            SKAction.rotate(toAngle: -0.05, duration: 1.5)
        ])
        splashBody.run(SKAction.repeatForever(wobbleAction))

        // Blink animation
        let blinkAction = SKAction.sequence([
            SKAction.wait(forDuration: Double.random(in: 2...4)),
            SKAction.run { [weak self] in self?.blink() },
        ])
        run(SKAction.repeatForever(blinkAction))
    }

    private func blink() {
        let blinkDuration = 0.1
        let scaleDown = SKAction.scaleY(to: 0.1, duration: blinkDuration)
        let scaleUp = SKAction.scaleY(to: 1.0, duration: blinkDuration)
        let blinkSequence = SKAction.sequence([scaleDown, scaleUp])

        leftEye.run(blinkSequence)
        rightEye.run(blinkSequence)
    }

    // MARK: - Create Blob Path

    private func createBlobPath(width: CGFloat, height: CGFloat) -> CGPath {
        let path = CGMutablePath()
        let w = width / 2
        let h = height / 2

        path.move(to: CGPoint(x: 0, y: h))
        path.addCurve(to: CGPoint(x: w, y: 0),
                      control1: CGPoint(x: w * 0.8, y: h),
                      control2: CGPoint(x: w, y: h * 0.5))
        path.addCurve(to: CGPoint(x: w * 0.7, y: -h),
                      control1: CGPoint(x: w, y: -h * 0.5),
                      control2: CGPoint(x: w * 0.9, y: -h))
        path.addCurve(to: CGPoint(x: -w * 0.7, y: -h),
                      control1: CGPoint(x: w * 0.3, y: -h * 1.1),
                      control2: CGPoint(x: -w * 0.3, y: -h * 1.1))
        path.addCurve(to: CGPoint(x: -w, y: 0),
                      control1: CGPoint(x: -w * 0.9, y: -h),
                      control2: CGPoint(x: -w, y: -h * 0.5))
        path.addCurve(to: CGPoint(x: 0, y: h),
                      control1: CGPoint(x: -w, y: h * 0.5),
                      control2: CGPoint(x: -w * 0.8, y: h))

        return path
    }

    // MARK: - Follow Cursor

    func followPoint(_ point: CGPoint, smoothing: CGFloat = 0.1) {
        guard !isWalking else { return }

        // Smooth follow with lerp
        let dx = (point.x - position.x) * smoothing
        let dy = (point.y - position.y) * smoothing

        position.x += dx
        position.y += dy

        // Look at cursor direction
        if abs(dx) > 1 {
            let scaleX: CGFloat = dx > 0 ? 1 : -1
            splashBody.xScale = scaleX
        }
    }

    // MARK: - Walk to Building

    func walkTo(_ destination: CGPoint, duration: TimeInterval = 1.5) {
        isWalking = true
        targetPosition = destination

        // Face direction
        let dx = destination.x - position.x
        splashBody.xScale = dx > 0 ? 1 : -1

        // Bounce walk animation
        let bounceUp = SKAction.moveBy(x: 0, y: 15, duration: 0.15)
        let bounceDown = SKAction.moveBy(x: 0, y: -15, duration: 0.15)
        let bounce = SKAction.sequence([bounceUp, bounceDown])
        let bounceRepeat = SKAction.repeat(bounce, count: Int(duration / 0.3))

        // Move to destination
        let moveAction = SKAction.move(to: destination, duration: duration)
        moveAction.timingMode = .easeInEaseOut

        // Run both together
        let group = SKAction.group([moveAction, bounceRepeat])

        run(group) { [weak self] in
            self?.isWalking = false
            self?.onReachedDestination?()
        }
    }

    // MARK: - Exit Animation (walk off screen)

    func walkOffScreen(to edge: CGPoint, duration: TimeInterval = 0.8, completion: @escaping () -> Void) {
        isWalking = true

        // Face direction
        let dx = edge.x - position.x
        splashBody.xScale = dx > 0 ? 1 : -1

        // Quick bounce walk
        let bounceUp = SKAction.moveBy(x: 0, y: 10, duration: 0.1)
        let bounceDown = SKAction.moveBy(x: 0, y: -10, duration: 0.1)
        let bounce = SKAction.sequence([bounceUp, bounceDown])
        let bounceRepeat = SKAction.repeat(bounce, count: Int(duration / 0.2))

        // Move off screen
        let moveAction = SKAction.move(to: edge, duration: duration)
        moveAction.timingMode = .easeIn

        // Scale down as leaving
        let scaleAction = SKAction.scale(to: 0.5, duration: duration)

        let group = SKAction.group([moveAction, bounceRepeat, scaleAction])

        run(group) {
            completion()
        }
    }

    // MARK: - Happy Reaction

    func celebrateMatch() {
        // Jump!
        let jumpUp = SKAction.moveBy(x: 0, y: 30, duration: 0.2)
        let jumpDown = SKAction.moveBy(x: 0, y: -30, duration: 0.2)
        let jump = SKAction.sequence([jumpUp, jumpDown])

        // Spin bird
        if let bird = childNode(withName: "bird") {
            let spin = SKAction.rotate(byAngle: .pi * 2, duration: 0.4)
            bird.run(spin)
        }

        run(jump)
    }
}
