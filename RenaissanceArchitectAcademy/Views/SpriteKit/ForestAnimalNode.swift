import SpriteKit
import SwiftUI

/// Ambient forest animal (frog, goldfinch, woodpecker, …) — Kling loop clips cut out on a plain background.
/// Ambient kinds play their clip once, rest on frame 00 for a random pause, then play again, so animals
/// never move in lockstep. Patrol kinds (hedgehog) walk back and forth instead. Decorative only for now.
class ForestAnimalNode: SKNode {

    /// One animal kind: its atlas, how its frames sit on their canvas, and how it behaves
    struct Kind {
        /// Sprite atlas name — also the frame prefix (FrogCroak → FrogCroakFrame00…14)
        let atlas: String
        let frameCount: Int
        /// Display size of the frame canvas in scene points
        let displaySize: CGSize
        /// Feet position on the canvas (fraction from left / from bottom)
        let anchor: CGPoint
        /// Random rest between clips / patrol legs (seconds)
        let restRange: ClosedRange<TimeInterval>
        /// Seconds per frame
        var frameTime: TimeInterval = 0.1
        /// Ground shadow — off for animals clinging to a trunk
        var hasShadow = true
        /// Walk back and forth this far (scene points) at this speed, instead of playing in place
        var patrol: (distance: CGFloat, speed: CGFloat)? = nil

        static let frog = Kind(atlas: "FrogCroak", frameCount: 15,
                               displaySize: CGSize(width: 63, height: 49),
                               anchor: CGPoint(x: 0.497, y: 0.034),
                               restRange: 2...6)

        static let goldfinch = Kind(atlas: "GoldfinchPeck", frameCount: 15,
                                    displaySize: CGSize(width: 65, height: 47),
                                    anchor: CGPoint(x: 0.512, y: 0.039),
                                    restRange: 1.5...4)

        static let woodpecker = Kind(atlas: "WoodpeckerDrum", frameCount: 15,
                                     displaySize: CGSize(width: 34, height: 74),
                                     anchor: CGPoint(x: 0.495, y: 0.03),
                                     restRange: 2...5,
                                     frameTime: 0.05,
                                     hasShadow: false)

        static let squirrel = Kind(atlas: "SquirrelNibble", frameCount: 15,
                                   displaySize: CGSize(width: 71, height: 72),
                                   anchor: CGPoint(x: 0.503, y: 0.025),
                                   restRange: 1.5...4)

        static let hedgehog = Kind(atlas: "HedgehogWalk", frameCount: 15,
                                   displaySize: CGSize(width: 67, height: 44),
                                   anchor: CGPoint(x: 0.495, y: 0.038),
                                   restRange: 1.5...3.5,
                                   patrol: (distance: 180, speed: 25))
    }

    let kind: Kind

    private let sprite: SKSpriteNode
    private let textures: [SKTexture]
    private var isFacingRight = true

    // MARK: - Initialization

    init(kind: Kind) {
        self.kind = kind
        let atlas = SKTextureAtlas(named: kind.atlas)
        self.textures = (0..<kind.frameCount).map { atlas.textureNamed(String(format: "%@Frame%02d", kind.atlas, $0)) }
        self.sprite = SKSpriteNode(texture: textures[0], size: kind.displaySize)
        sprite.anchorPoint = kind.anchor

        super.init()

        if kind.hasShadow {
            // Small soft shadow so the animal sits on the ground instead of floating
            let shadow = SKShapeNode(ellipseOf: CGSize(width: kind.displaySize.width * 0.5, height: kind.displaySize.width * 0.12))
            shadow.fillColor = PlatformColor(RenaissanceColors.sepiaInk.opacity(0.2))
            shadow.strokeColor = .clear
            shadow.zPosition = -1
            addChild(shadow)
        }

        addChild(sprite)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Start moving — call after the position and facing are set (patrols walk relative to them)
    func startBehavior() {
        if kind.patrol != nil {
            patrolLeg()
        } else {
            scheduleNextClip()
        }
    }

    /// Frames are drawn facing right — flip to face left
    func setFacingRight(_ right: Bool) {
        isFacingRight = right
        xScale = right ? abs(xScale) : -abs(xScale)
    }

    // MARK: - Ambient Loop

    /// Rest a random while on frame 00, play the clip once, repeat
    private func scheduleNextClip() {
        let rest = SKAction.wait(forDuration: TimeInterval.random(in: kind.restRange))
        let clip = SKAction.animate(with: textures, timePerFrame: kind.frameTime, resize: false, restore: true)
        let again = SKAction.run { [weak self] in self?.scheduleNextClip() }
        sprite.run(SKAction.sequence([rest, clip, again]), withKey: "ambient")
    }

    // MARK: - Patrol

    /// Walk one leg in the facing direction, rest, turn around, repeat
    private func patrolLeg() {
        guard let patrol = kind.patrol else { return }

        let stride = SKAction.animate(with: textures, timePerFrame: kind.frameTime, resize: false, restore: false)
        sprite.run(SKAction.repeatForever(stride), withKey: "walk")

        let move = SKAction.moveBy(x: isFacingRight ? patrol.distance : -patrol.distance, y: 0,
                                   duration: TimeInterval(patrol.distance / patrol.speed))
        let stop = SKAction.run { [weak self] in
            guard let self else { return }
            self.sprite.removeAction(forKey: "walk")
            self.sprite.texture = self.textures[0]
        }
        let rest = SKAction.wait(forDuration: TimeInterval.random(in: kind.restRange))
        let turn = SKAction.run { [weak self] in
            guard let self else { return }
            self.setFacingRight(!self.isFacingRight)
            self.patrolLeg()
        }
        run(SKAction.sequence([move, stop, rest, turn]), withKey: "patrol")
    }
}
