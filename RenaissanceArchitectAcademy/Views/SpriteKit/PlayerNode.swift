import SpriteKit
import SwiftUI

/// Apprentice boy player for the Workshop scene
/// Uses 15-frame sprite animation extracted from Midjourney walking GIF
class PlayerNode: SKNode {

    // MARK: - Properties

    private var sprite: SKSpriteNode!

    /// All walk-cycle textures (ApprenticeFrame00–14)
    private let walkTextures: [SKTexture] = {
        (0..<15).map { SKTexture(imageNamed: String(format: "ApprenticeFrame%02d", $0)) }
    }()

    /// Idle texture (first frame)
    private var idleTexture: SKTexture { walkTextures[0] }

    /// Whether the player is currently walking
    private(set) var isWalking = false

    /// Sprite display size
    private let spriteSize = CGSize(width: 80, height: 80)

    // MARK: - Initialization

    override init() {
        super.init()
        setupSprite()
        startIdleAnimation()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Sprite Setup

    private func setupSprite() {
        sprite = SKSpriteNode(texture: idleTexture, size: spriteSize)
        sprite.anchorPoint = CGPoint(x: 0.5, y: 0.0) // bottom-center anchor so feet stay on ground
        addChild(sprite)
    }

    // MARK: - Idle Animation (gentle breathing scale)

    private func startIdleAnimation() {
        sprite.removeAction(forKey: "walk")

        // Show idle frame
        sprite.texture = idleTexture

        let breatheIn = SKAction.scaleY(to: 1.02, duration: 1.5)
        breatheIn.timingMode = .easeInEaseOut
        let breatheOut = SKAction.scaleY(to: 1.0, duration: 1.5)
        breatheOut.timingMode = .easeInEaseOut
        let breathe = SKAction.sequence([breatheIn, breatheOut])
        sprite.run(SKAction.repeatForever(breathe), withKey: "idle")
    }

    // MARK: - Walking Animation

    private func startWalkAnimation() {
        sprite.removeAction(forKey: "idle")
        sprite.yScale = 1.0 // reset breathing scale

        // Match original GIF pace: 5.21s across 15 frames ≈ 0.347s per frame
        let walkAction = SKAction.animate(with: walkTextures, timePerFrame: 0.347, resize: false, restore: false)
        sprite.run(SKAction.repeatForever(walkAction), withKey: "walk")
    }

    private func stopWalkAnimation() {
        sprite.removeAction(forKey: "walk")
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

    // MARK: - Walk Along Waypoint Path

    /// Walk through a sequence of waypoints, turning at each corner.
    /// Uses the same 30-step lerp per segment as `walkTo`.
    func walkPath(_ waypoints: [CGPoint], speed: CGFloat = 200, completion: (() -> Void)? = nil) {
        guard !waypoints.isEmpty else {
            completion?()
            return
        }

        isWalking = true
        startWalkAnimation()

        var allActions: [SKAction] = []
        var currentPos = position

        for waypoint in waypoints {
            let segStart = currentPos
            let dx = waypoint.x - segStart.x
            let dy = waypoint.y - segStart.y
            let distance = hypot(dx, dy)
            guard distance > 1 else { continue }

            let duration = max(0.15, TimeInterval(distance / speed))
            let steps = max(5, Int(duration / 0.033))  // ~30fps steps
            let stepDuration = duration / Double(steps)
            let stepDx = dx / CGFloat(steps)
            let stepDy = dy / CGFloat(steps)

            // Face new direction at the start of each segment
            let facingRight = dx > 0
            let turnAction = SKAction.run { [weak self] in
                self?.setFacingDirection(facingRight)
            }
            allActions.append(turnAction)

            for i in 1...steps {
                let step = SKAction.run { [weak self] in
                    self?.position = CGPoint(
                        x: segStart.x + stepDx * CGFloat(i),
                        y: segStart.y + stepDy * CGFloat(i)
                    )
                }
                allActions.append(step)
                allActions.append(SKAction.wait(forDuration: stepDuration))
            }

            currentPos = waypoint
        }

        allActions.append(SKAction.run { [weak self] in
            self?.isWalking = false
            self?.stopWalkAnimation()
            completion?()
        })

        run(SKAction.sequence(allActions), withKey: "walkTo")
    }

    // MARK: - Facing Direction

    func setFacingDirection(_ right: Bool) {
        // Sprite naturally faces left, so flip when walking right
        xScale = right ? -abs(xScale) : abs(xScale)
    }
}
