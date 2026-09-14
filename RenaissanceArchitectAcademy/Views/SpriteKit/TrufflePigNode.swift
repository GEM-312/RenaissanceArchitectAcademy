import SpriteKit
import SwiftUI

/// Truffle-hunting pig for the Forest scene.
/// Frames come from Kling clips drawn on the forest map and cut out by hand, then aligned on one
/// shared 550×515 canvas. The clips were chained (sniff → dig → eat), so the pig moves naturally
/// between animations without jumping. Walk loops while trotting; sniff, dig and eat play once.
class TrufflePigNode: SKNode {

    // MARK: - Properties

    private var sprite: SKSpriteNode!

    /// Walk stride loop (PigWalkFrame00–06)
    private let walkTextures: [SKTexture]

    /// Sniff, dig and eat animations (15 frames each) — nil if their atlas is missing
    private let sniffTextures: [SKTexture]?
    private let digTextures: [SKTexture]?
    private let eatTextures: [SKTexture]?

    /// Display size of the 550×515 frame canvas
    private let spriteSize = CGSize(width: 209, height: 196)

    /// Canvas width in pixels — converts measured frame offsets to display points
    private let canvasWidth: CGFloat = 550

    /// Where the walk-frame hooves sit on the canvas (fraction from left / from bottom)
    private let feetAnchor = CGPoint(x: 0.387, y: 0.377)

    /// Measured on the canvas, relative to the walk hooves anchor (px, y up):
    /// the truffle in eat frame 00, and the snout while digging
    private let truffleOffset = CGPoint(x: 127, y: -74)
    private let digSnoutOffset = CGPoint(x: 221, y: -27)

    /// The pig ends dig / eat standing a little right of its walking spot (px, y up) —
    /// the node shifts by this before trotting off so the walk frames don't jump back
    private let leaveShiftAfterDig = CGPoint(x: 12, y: -4)
    private let leaveShiftAfterEat = CGPoint(x: 28, y: -13)

    /// Tap radius around the truffle (canvas px) — generous so kids can hit it
    private let truffleTapRadius: CGFloat = 90

    /// Seconds per frame
    private let walkFrameTime: TimeInterval = 0.1
    private let actionFrameTime: TimeInterval = 0.1

    /// Name of the tappable truffle node — ForestScene checks tapped nodes for it
    static let truffleHitName = "pigTruffleHit"

    private var truffleHit: SKShapeNode?

    private var pointsPerPixel: CGFloat { spriteSize.width / canvasWidth }

    // MARK: - Initialization

    override init() {
        let walkAtlas = SKTextureAtlas(named: "PigWalk")
        self.walkTextures = (0..<7).map { walkAtlas.textureNamed(String(format: "PigWalkFrame%02d", $0)) }
        self.sniffTextures = PlayerNode.loadOptionalTextures(prefix: "PigSniffFrame", count: 15)
        self.digTextures = PlayerNode.loadOptionalTextures(prefix: "PigDigFrame", count: 15)
        self.eatTextures = PlayerNode.loadOptionalTextures(prefix: "PigEatFrame", count: 15)

        super.init()
        setupSprite()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Sprite Setup

    private func setupSprite() {
        // Soft ground shadow under the hooves
        let shadow = SKShapeNode(ellipseOf: CGSize(width: spriteSize.width * 0.5, height: spriteSize.width * 0.12))
        shadow.fillColor = PlatformColor(RenaissanceColors.sepiaInk.opacity(0.25))
        shadow.strokeColor = .clear
        shadow.zPosition = -1
        addChild(shadow)

        sprite = SKSpriteNode(texture: walkTextures[0], size: spriteSize)
        sprite.anchorPoint = feetAnchor
        addChild(sprite)
    }

    private func points(_ canvasOffset: CGPoint) -> CGPoint {
        CGPoint(x: canvasOffset.x * pointsPerPixel, y: canvasOffset.y * pointsPerPixel)
    }

    /// Play a one-shot animation (never loops), then call completion
    private func playOnce(_ textures: [SKTexture]?, key: String, completion: @escaping () -> Void) {
        guard let textures else {
            completion()
            return
        }
        let anim = SKAction.animate(with: textures, timePerFrame: actionFrameTime, resize: false, restore: false)
        sprite.run(SKAction.sequence([anim, SKAction.run(completion)]), withKey: key)
    }

    // MARK: - Trot

    /// Trot in a straight line with the walk loop, then stand on the first walk frame
    func trot(to destination: CGPoint, speed: CGFloat, completion: (() -> Void)? = nil) {
        let distance = hypot(destination.x - position.x, destination.y - position.y)

        let stride = SKAction.animate(with: walkTextures, timePerFrame: walkFrameTime, resize: false, restore: false)
        sprite.run(SKAction.repeatForever(stride), withKey: "walk")

        let move = SKAction.move(to: destination, duration: TimeInterval(distance / speed))
        let finish = SKAction.run { [weak self] in
            guard let self else { return }
            self.sprite.removeAction(forKey: "walk")
            self.sprite.texture = self.walkTextures[0]
            completion?()
        }
        run(SKAction.sequence([move, finish]), withKey: "trot")
    }

    // MARK: - Sniff + Dig

    /// Nose to the ground, sniffing out the truffle
    func sniff(completion: @escaping () -> Void) {
        playOnce(sniffTextures, key: "sniff", completion: completion)
    }

    /// Root at the soil — the cutouts have no dirt, so clods fly from the snout while digging
    func dig(completion: @escaping () -> Void) {
        let snout = points(digSnoutOffset)
        let clods = SKAction.repeat(SKAction.sequence([
            SKAction.run { [weak self] in self?.spawnDirtPuff(at: snout) },
            SKAction.wait(forDuration: 0.4)
        ]), count: 3)
        run(SKAction.sequence([SKAction.wait(forDuration: 0.3), clods]), withKey: "digClods")

        if digTextures == nil {
            run(SKAction.sequence([SKAction.wait(forDuration: 1.5), SKAction.run(completion)]), withKey: "dig")
        } else {
            playOnce(digTextures, key: "dig", completion: completion)
        }
    }

    /// Little clods of earth hop out and fall back down
    private func spawnDirtPuff(at point: CGPoint) {
        for i in 0..<8 {
            let clod = SKShapeNode(circleOfRadius: CGFloat.random(in: 2...4))
            clod.fillColor = PlatformColor(RenaissanceColors.warmBrown)
            clod.strokeColor = .clear
            clod.position = point
            clod.zPosition = 3
            addChild(clod)

            let hop = SKAction.moveBy(x: CGFloat.random(in: -30...30), y: CGFloat.random(in: 15...40), duration: 0.35)
            hop.timingMode = .easeOut
            let fall = SKAction.moveBy(x: 0, y: -20, duration: 0.3)
            fall.timingMode = .easeIn

            clod.run(SKAction.sequence([
                SKAction.wait(forDuration: Double(i) * 0.05),
                hop,
                SKAction.group([fall, SKAction.fadeOut(withDuration: 0.3)]),
                SKAction.removeFromParent()
            ]))
        }
    }

    // MARK: - Truffle

    /// The truffle pops out: a dirt puff covers the swap to eat frame 00 (pig looking at the truffle),
    /// then a pulsing tap target appears on the truffle
    func showTruffle() {
        let truffleSpot = points(truffleOffset)
        spawnDirtPuff(at: truffleSpot)
        if let lookingAtTruffle = eatTextures?.first {
            sprite.texture = lookingAtTruffle
        }

        let hit = SKShapeNode(circleOfRadius: truffleTapRadius * pointsPerPixel)
        hit.name = Self.truffleHitName
        hit.position = truffleSpot
        hit.fillColor = PlatformColor(RenaissanceColors.goldSuccess.opacity(0.12))
        hit.strokeColor = PlatformColor(RenaissanceColors.goldSuccess.opacity(0.7))
        hit.lineWidth = 2
        hit.zPosition = 2

        let grow = SKAction.scale(to: 1.15, duration: 0.45)
        grow.timingMode = .easeInEaseOut
        let shrink = SKAction.scale(to: 1.0, duration: 0.45)
        shrink.timingMode = .easeInEaseOut
        hit.run(SKAction.repeatForever(SKAction.sequence([grow, shrink])))

        addChild(hit)
        truffleHit = hit
    }

    func removeTruffleHit() {
        truffleHit?.removeFromParent()
        truffleHit = nil
    }

    /// The pig eats the truffle — eat frames play once, then it pauses on the last frame
    func eatTruffle(completion: @escaping () -> Void) {
        removeTruffleHit()
        playOnce(eatTextures, key: "eat") { [weak self] in
            self?.run(SKAction.sequence([SKAction.wait(forDuration: 0.4), SKAction.run(completion)]), withKey: "eatPause")
        }
    }

    // MARK: - Leave

    /// Trot off to the right, fade out on the way, and remove the pig
    /// - Parameter afterEating: true when leaving from the last eat frame, false when leaving right after digging
    func leave(afterEating: Bool, distance: CGFloat, speed: CGFloat, completion: (() -> Void)? = nil) {
        removeTruffleHit()

        // Line the walk frames up with where the pig is actually standing
        let shift = points(afterEating ? leaveShiftAfterEat : leaveShiftAfterDig)
        position = CGPoint(x: position.x + shift.x, y: position.y + shift.y)

        let duration = TimeInterval(distance / speed)
        trot(to: CGPoint(x: position.x + distance, y: position.y), speed: speed)

        run(SKAction.sequence([
            SKAction.wait(forDuration: duration * 0.6),
            SKAction.fadeOut(withDuration: duration * 0.4),
            SKAction.run { [weak self] in
                self?.removeFromParent()
                completion?()
            }
        ]), withKey: "leave")
    }
}
