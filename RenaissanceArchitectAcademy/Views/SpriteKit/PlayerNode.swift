import SpriteKit
import SwiftUI

/// Apprentice player for the Workshop/CraftingRoom/Forest scenes
/// Uses 15-frame sprite animation extracted from Midjourney walking videos
/// Supports boy/girl variants based on player's chosen gender
class PlayerNode: SKNode {

    // MARK: - Properties

    private var sprite: SKSpriteNode!

    /// Gender determines which sprite set to use
    private let isBoy: Bool

    /// All walk-cycle textures (ApprenticeFrame00–14 or ApprenticeGirlFrame00–14)
    private let walkTextures: [SKTexture]

    /// Collecting textures (CollectBoyFrame00–14 or CollectGirlFrame00–14) — nil until videos are added
    private let collectTextures: [SKTexture]?

    /// Celebrating textures (CelebrateBoyFrame00–14 or CelebrateGirlFrame00–14) — nil until videos are added
    private let celebrateTextures: [SKTexture]?

    /// Idle texture (first frame)
    private var idleTexture: SKTexture { walkTextures[0] }

    /// Whether the player is currently walking
    private(set) var isWalking = false

    /// Whether the player is performing an action animation (collecting, celebrating)
    private(set) var isAnimating = false

    /// Sprite display size
    private let spriteSize = CGSize(width: 170, height: 170)

    // MARK: - Initialization

    /// Create a player node for the given gender
    /// - Parameter isBoy: true for boy apprentice, false for girl apprentice
    init(isBoy: Bool = true) {
        self.isBoy = isBoy
        let prefix = isBoy ? "ApprenticeFrame" : "ApprenticeGirlFrame"
        self.walkTextures = (0..<15).map { SKTexture(imageNamed: String(format: "%@%02d", prefix, $0)) }

        // Load collecting textures if available (CollectBoyFrame00–14 / CollectGirlFrame00–14)
        let collectPrefix = isBoy ? "CollectBoyFrame" : "CollectGirlFrame"
        self.collectTextures = Self.loadOptionalTextures(prefix: collectPrefix, count: 15)

        // Load celebrating textures if available (CelebrateBoyFrame00–14 / CelebrateGirlFrame00–14)
        let celebratePrefix = isBoy ? "CelebrateBoyFrame" : "CelebrateGirlFrame"
        self.celebrateTextures = Self.loadOptionalTextures(prefix: celebratePrefix, count: 15)

        super.init()
        setupSprite()
        startIdleAnimation()
    }

    /// Load textures only if the first frame exists in the asset catalog
    private static func loadOptionalTextures(prefix: String, count: Int) -> [SKTexture]? {
        let testName = String(format: "%@%02d", prefix, 0)
        // SKTexture always creates a texture object — check if the image actually exists
        #if os(iOS)
        guard UIImage(named: testName) != nil else { return nil }
        #else
        guard NSImage(named: testName) != nil else { return nil }
        #endif
        return (0..<count).map { SKTexture(imageNamed: String(format: "%@%02d", prefix, $0)) }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Sprite Setup

    private func setupSprite() {
        // Shadow ellipse at feet — sits behind the sprite on the ground
        let shadow = SKShapeNode(ellipseOf: CGSize(width: spriteSize.width * 0.6, height: spriteSize.width * 0.2))
        shadow.fillColor = SKColor(red: 0, green: 0, blue: 0, alpha: 0.25)
        shadow.strokeColor = .clear
        shadow.position = CGPoint(x: 0, y: 4) // slightly above node origin (feet level)
        shadow.zPosition = -1
        addChild(shadow)

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

        // 1.3x faster than original GIF pace (0.347 / 1.3 ≈ 0.267s per frame)
        let walkAction = SKAction.animate(with: walkTextures, timePerFrame: 0.18, resize: false, restore: false)
        sprite.run(SKAction.repeatForever(walkAction), withKey: "walk")

        startFootstepSound()
    }

    private func stopWalkAnimation() {
        sprite.removeAction(forKey: "walk")
        stopFootstepSound()
        startIdleAnimation()
    }

    // MARK: - Footstep Sound

    private func startFootstepSound() {
        removeAction(forKey: "footsteps")
        let step = SKAction.playSoundFileNamed("footstep.wav", waitForCompletion: false)
        let pause = SKAction.wait(forDuration: 0.55)
        let sequence = SKAction.sequence([step, pause])
        run(SKAction.repeatForever(sequence), withKey: "footsteps")
    }

    private func stopFootstepSound() {
        removeAction(forKey: "footsteps")
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

    // MARK: - Collecting Animation

    /// Play collecting animation — apprentice bends down to pick up materials.
    /// Uses sprite frames if available (CollectBoy/GirlFrame00–14), otherwise falls back
    /// to a procedural bend-down + sparkle effect. Plays once, then returns to idle.
    /// - Parameter completion: called after animation finishes
    func playCollectAnimation(completion: (() -> Void)? = nil) {
        guard !isAnimating else {
            completion?()
            return
        }

        isAnimating = true
        sprite.removeAction(forKey: "idle")
        sprite.removeAction(forKey: "walk")
        sprite.yScale = 1.0

        let finishAction = SKAction.run { [weak self] in
            self?.isAnimating = false
            self?.spawnCollectSparkles()
            self?.startIdleAnimation()
            completion?()
        }

        if let textures = collectTextures {
            // Sprite-based: play 15 frames once (no loop per project convention)
            let anim = SKAction.animate(with: textures, timePerFrame: 0.08, resize: false, restore: true)
            sprite.run(SKAction.sequence([anim, finishAction]), withKey: "collect")
        } else {
            // Procedural fallback: bend down (squash + lower), pause, stand back up
            let bendDown = SKAction.group([
                SKAction.scaleY(to: 0.7, duration: 0.25),
                SKAction.moveBy(x: 0, y: -15, duration: 0.25)
            ])
            bendDown.timingMode = .easeOut

            let hold = SKAction.wait(forDuration: 0.3)

            let standUp = SKAction.group([
                SKAction.scaleY(to: 1.0, duration: 0.2),
                SKAction.moveBy(x: 0, y: 15, duration: 0.2)
            ])
            standUp.timingMode = .easeIn

            sprite.run(SKAction.sequence([bendDown, hold, standUp, finishAction]), withKey: "collect")
        }
    }

    /// Sparkle particles rising from the player's hands after collecting
    private func spawnCollectSparkles() {
        let sparkleCount = 6
        for i in 0..<sparkleCount {
            let spark = SKShapeNode(circleOfRadius: 3)
            spark.fillColor = SKColor(red: 0.85, green: 0.66, blue: 0.41, alpha: 0.9) // ochre sparkle
            spark.strokeColor = .clear
            spark.position = CGPoint(
                x: CGFloat.random(in: -25...25),
                y: spriteSize.height * 0.4
            )
            spark.zPosition = 100
            addChild(spark)

            let angle = CGFloat.random(in: -0.3...0.3)
            let rise = SKAction.moveBy(x: sin(angle) * 30, y: CGFloat.random(in: 40...80), duration: 0.6)
            rise.timingMode = .easeOut
            let fade = SKAction.fadeOut(withDuration: 0.4)
            let scale = SKAction.scale(to: 0.3, duration: 0.6)
            let delay = SKAction.wait(forDuration: Double(i) * 0.05)

            spark.run(SKAction.sequence([
                delay,
                SKAction.group([rise, fade, scale]),
                SKAction.removeFromParent()
            ]))
        }
    }

    // MARK: - Celebrating Animation

    /// Play celebrating animation — apprentice jumps with joy.
    /// Uses sprite frames if available (CelebrateBoy/GirlFrame00–14), otherwise falls back
    /// to a procedural jump + star burst. Plays once, then returns to idle.
    /// - Parameter completion: called after animation finishes
    func playCelebrateAnimation(completion: (() -> Void)? = nil) {
        guard !isAnimating else {
            completion?()
            return
        }

        isAnimating = true
        sprite.removeAction(forKey: "idle")
        sprite.removeAction(forKey: "walk")
        sprite.yScale = 1.0

        let finishAction = SKAction.run { [weak self] in
            self?.isAnimating = false
            self?.spawnCelebrateStars()
            self?.startIdleAnimation()
            completion?()
        }

        if let textures = celebrateTextures {
            // Sprite-based: play 15 frames once
            let anim = SKAction.animate(with: textures, timePerFrame: 0.08, resize: false, restore: true)
            sprite.run(SKAction.sequence([anim, finishAction]), withKey: "celebrate")
        } else {
            // Procedural fallback: jump up, slight squash on landing, arms-up stretch
            let crouch = SKAction.scaleY(to: 0.85, duration: 0.1)
            crouch.timingMode = .easeIn

            let jumpUp = SKAction.group([
                SKAction.scaleY(to: 1.15, duration: 0.25),
                SKAction.moveBy(x: 0, y: 40, duration: 0.25)
            ])
            jumpUp.timingMode = .easeOut

            let hangTime = SKAction.wait(forDuration: 0.1)

            let comeDown = SKAction.group([
                SKAction.scaleY(to: 0.9, duration: 0.2),
                SKAction.moveBy(x: 0, y: -40, duration: 0.2)
            ])
            comeDown.timingMode = .easeIn

            let recover = SKAction.scaleY(to: 1.0, duration: 0.15)
            recover.timingMode = .easeOut

            // Spawn stars at the peak of the jump
            let spawnStars = SKAction.run { [weak self] in
                self?.spawnCelebrateStars()
            }

            sprite.run(SKAction.sequence([crouch, jumpUp, spawnStars, hangTime, comeDown, recover, finishAction]), withKey: "celebrate")
        }
    }

    /// Star burst around the player during celebration
    private func spawnCelebrateStars() {
        let starCount = 8
        for i in 0..<starCount {
            let angle = (CGFloat(i) / CGFloat(starCount)) * .pi * 2
            let star = SKShapeNode(circleOfRadius: 4)
            star.fillColor = SKColor(red: 0.85, green: 0.65, blue: 0.13, alpha: 1.0) // gold
            star.strokeColor = SKColor(red: 1.0, green: 0.9, blue: 0.5, alpha: 0.8)
            star.lineWidth = 1
            star.position = CGPoint(x: 0, y: spriteSize.height * 0.5)
            star.zPosition = 100
            star.setScale(0.3)
            addChild(star)

            let radius: CGFloat = CGFloat.random(in: 50...90)
            let outward = SKAction.move(
                to: CGPoint(
                    x: cos(angle) * radius,
                    y: spriteSize.height * 0.5 + sin(angle) * radius
                ),
                duration: 0.4
            )
            outward.timingMode = .easeOut

            let grow = SKAction.scale(to: 1.0, duration: 0.2)
            let shrink = SKAction.scale(to: 0.0, duration: 0.3)
            let fade = SKAction.fadeOut(withDuration: 0.3)
            let delay = SKAction.wait(forDuration: Double(i) * 0.03)

            star.run(SKAction.sequence([
                delay,
                SKAction.group([outward, SKAction.sequence([grow, SKAction.group([shrink, fade])])]),
                SKAction.removeFromParent()
            ]))
        }
    }
}
