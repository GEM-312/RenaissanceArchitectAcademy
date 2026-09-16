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

    /// Container for the current visual (blueprint, ghost, or building)
    private var visualContainer: SKNode!
    private var labelNode: SKLabelNode!
    private var pillLabelNode: SKNode?
    private var stateIndicator: SKSpriteNode?
    private var tierBadge: SKNode?
    private(set) var currentState: BuildingState = .available

    /// True once the stone-by-stone construction frames have played, so the bloom
    /// that follows doesn't rebuild the building again. Reset by `updateState`.
    private var hasPlayedConstructionBuild = false

    // Building sizes (isometric style — used for blueprint/complete states)
    private let buildingSize = CGSize(width: 120, height: 100)

    /// Sprite size for Midjourney building art (matches workshop station sprites at 420)
    private let spriteSize = CGSize(width: 420, height: 420)

    /// Debug: force all buildings to show as complete (for previewing sprites on map)
    static var debugShowAllComplete = false

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
        hasPlayedConstructionBuild = false

        // Clear previous visual + pill label + state icon
        visualContainer.removeAllChildren()
        stateIndicator?.removeFromParent()
        stateIndicator = nil
        labelNode?.removeFromParent()
        labelNode = nil
        pillLabelNode?.removeFromParent()
        pillLabelNode = nil
        // Also clean any stray lock icons left over from a prior locked state
        children.filter { $0.name == "buildingLockIcon" }.forEach { $0.removeFromParent() }

        // Debug: show all buildings as complete to preview sprites
        if BuildingNode.debugShowAllComplete && state != .locked {
            setupCompletedBuilding()
            addStateIcon("StateComplete")
            addPillLabel(isLocked: false)
            return
        }

        let hasBuildArt = buildAnimationAtlasName() != nil

        switch state {
        case .locked:
            // No in-world signpost graphic — pill label alone marks the
            // location, with reduced alpha + lock icon to communicate state.
            addLockIcon()

        case .available:
            if hasBuildArt {
                setupUnbuiltBuilding()
            }

        case .sketched:
            if hasBuildArt {
                setupUnbuiltBuilding()
            } else {
                setupBlueprint()
            }
            addStateIcon("StateAvailable")

        case .construction:
            if hasBuildArt {
                setupUnbuiltBuilding()
            } else {
                setupBlueprint()
                setupScaffolding()
            }
            addStateIcon("StateConstruction")

        case .complete:
            setupCompletedBuilding()
            addStateIcon("StateComplete")
        }

        // Pill label — same style workshop uses for stations.
        addPillLabel(isLocked: state == .locked)
    }

    // MARK: - Pill Label (matches workshop station label style)

    /// Building name as a clean uppercase pill label — same style as the
    /// workshop's `SKNode.makePillLabel`. Replaces the old wooden-signpost
    /// graphic + tiny 10pt Cinzel text that was unreadable on city map.
    private func addPillLabel(isLocked: Bool) {
        let pill = SKNode.makePillLabel(
            text: buildingName,
            fontSize: 24,
            position: CGPoint(x: 0, y: -56),
            zPosition: 9
        )
        if isLocked {
            pill.alpha = 0.5
        }
        addChild(pill)
        pillLabelNode = pill
    }

    /// Small lock glyph beside the pill for `.locked` state.
    private func addLockIcon() {
        let lock = SKLabelNode(text: "🔒")
        lock.name = "buildingLockIcon"
        lock.fontSize = 18
        lock.position = CGPoint(x: 0, y: -90)
        lock.zPosition = 15
        addChild(lock)
    }

    /// Map buildingId to the COMPLETED sprite asset name in Assets.xcassets —
    /// the finished building shown once construction is done. Unbuilt states use
    /// frame 00 of `buildAnimationAtlasName()` instead; buildings in neither list
    /// fall back to the vector blueprint diamond.
    private func buildingSpriteImageName() -> String? {
        switch buildingId {
        case "duomo":         return "Duomo"
        case "pantheon":      return "Pantheon"
        case "aqueduct":      return "Aqueduct"
        case "harbor":        return "Harbor"
        case "insula":        return "Insula"
        case "romanRoads":    return "RomanRoad"
        case "siegeWorkshop": return "SiegeWorkshop"
        case "glassworks":    return "Glassworks"
        default:              return nil
        }
    }

    /// Atlas of construction frames for buildings that build themselves stone by stone
    /// ("PantheonBuild" → PantheonBuildFrame00…14). The last frame matches the
    /// completed sprite exactly, so the animation lands on the static art.
    private func buildAnimationAtlasName() -> (atlas: String, frameCount: Int)? {
        switch buildingId {
        case "pantheon":      return ("PantheonBuild", 15)
        case "aqueduct":      return ("AqueductBuild", 15)
        case "harbor":        return ("HarborBuild", 15)
        case "insula":        return ("InsulaBuild", 15)
        case "romanRoads":    return ("RomanRoadBuild", 15)
        case "siegeWorkshop": return ("SiegeWorkshopBuild", 15)
        case "glassworks":    return ("GlassworksBuild", 15)
        case "duomo":         return ("DuomoBuild", 15)
        default:              return nil
        }
    }

    /// Seconds per construction frame — 15 frames ≈ 2.4s
    private let buildFrameTime: TimeInterval = 0.16

    /// Per-building size multiplier on the nominal 420×420 sprite box.
    /// Use this to make individual buildings render larger relative to the map.
    private var spriteSizeMultiplier: CGFloat {
        switch buildingId {
        case "duomo": return 1.5
        default:      return 1.0
        }
    }

    /// Scale `spriteSize` to match a texture's aspect ratio, fitting inside the
    /// nominal 420×420 box (times per-building multiplier). Prevents stretch on
    /// non-square art (e.g. the Duomo, which is taller than wide).
    private func aspectFittedSpriteSize(for texture: SKTexture) -> CGSize {
        let tex = texture.size()
        guard tex.width > 0, tex.height > 0 else { return spriteSize }
        let target = CGSize(
            width: spriteSize.width * spriteSizeMultiplier,
            height: spriteSize.height * spriteSizeMultiplier
        )
        let widthRatio = target.width / tex.width
        let heightRatio = target.height / tex.height
        let scale = min(widthRatio, heightRatio)
        return CGSize(width: tex.width * scale, height: tex.height * scale)
    }

    /// Check if a sprite image exists in the asset catalog
    private func spriteImageExists(_ name: String) -> Bool {
        #if os(iOS)
        return UIImage(named: name) != nil
        #else
        return NSImage(named: name) != nil
        #endif
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

    // MARK: - Completion Bloom (sparkles + glow over the finished building)
    //
    // SpriteKit-native mirror of BloomEffectView (SwiftUI). Locks to the
    // building's world position so it tracks camera scroll/zoom correctly.
    //
    // Flow:
    // 1. Buildings with construction art build themselves stone by stone first.
    // 2. Burst 12 ochre/blue sparkles outward, fading + shrinking.
    // 3. Radial ochre glow node expands then fades.
    // 4. Play buildingComplete sound.
    // 5. After animation, swap to the proper completed visual.

    /// Build the building stone by stone: plays the construction frames once, from
    /// foundation to finished, then hands over to `completion`. No-op (calls
    /// `completion` straight away) for buildings without construction art.
    func playConstructionBuild(completion: @escaping () -> Void) {
        guard let build = buildAnimationAtlasName() else { completion(); return }

        let atlas = SKTextureAtlas(named: build.atlas)
        let frames = (0..<build.frameCount).map {
            atlas.textureNamed(String(format: "%@Frame%02d", build.atlas, $0))
        }
        guard let first = frames.first else { completion(); return }

        visualContainer.removeAllChildren()
        let sprite = SKSpriteNode(texture: first)
        sprite.size = aspectFittedSpriteSize(for: first)
        visualContainer.addChild(sprite)

        sprite.run(SKAction.sequence([
            SKAction.animate(with: frames, timePerFrame: buildFrameTime, resize: false, restore: false),
            SKAction.run(completion)
        ]))
    }

    func playCompletionBloom() {
        // Buildings with construction art rise stone by stone first, then bloom.
        if buildAnimationAtlasName() != nil, !hasPlayedConstructionBuild {
            hasPlayedConstructionBuild = true
            playConstructionBuild { [weak self] in self?.playCompletionBloom() }
            return
        }

        // Radial glow node
        let glow = SKShapeNode(circleOfRadius: 40)
        glow.fillColor = PlatformColor(RenaissanceColors.ochre.opacity(0.6))
        glow.strokeColor = .clear
        glow.alpha = 0
        glow.zPosition = 6
        glow.blendMode = .add
        visualContainer.addChild(glow)
        glow.run(SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 3.5, duration: 1.5),
                SKAction.sequence([
                    SKAction.fadeAlpha(to: 0.8, duration: 0.3),
                    SKAction.fadeAlpha(to: 0, duration: 1.2)
                ])
            ]),
            SKAction.removeFromParent()
        ]))

        // 12 sparkles bursting outward
        for i in 0..<12 {
            let angle = CGFloat(i) * .pi / 6.0
            let sparkle = SKShapeNode(circleOfRadius: 4)
            sparkle.fillColor = i % 2 == 0
                ? PlatformColor(RenaissanceColors.ochre)
                : PlatformColor(RenaissanceColors.renaissanceBlue)
            sparkle.strokeColor = .clear
            sparkle.position = .zero
            sparkle.zPosition = 7
            sparkle.blendMode = .add
            visualContainer.addChild(sparkle)

            let distance: CGFloat = 100
            let target = CGPoint(x: cos(angle) * distance, y: sin(angle) * distance)
            sparkle.run(SKAction.sequence([
                SKAction.group([
                    SKAction.move(to: target, duration: 1.4),
                    SKAction.fadeOut(withDuration: 1.4),
                    SKAction.scale(to: 0.2, duration: 1.4)
                ]),
                SKAction.removeFromParent()
            ]))
        }

        // Sound
        SoundManager.shared.play(.buildingComplete)

        // Snap to the proper completed visual after the animation finishes
        run(SKAction.sequence([
            SKAction.wait(forDuration: 1.6),
            SKAction.run { [weak self] in
                self?.updateState(.complete)
            }
        ]))
    }

    // MARK: - Unbuilt Building (available/sketched/construction states)

    /// An unfinished building shows the first frame of its construction animation —
    /// the foundation stones and stacked material, drawn in full colour. It is the
    /// same artwork the build animation starts from, so construction continues
    /// seamlessly from what the player was already looking at.
    private func setupUnbuiltBuilding() {
        guard let build = buildAnimationAtlasName() else {
            // No construction art — the blueprint diamond marks the location instead.
            return
        }

        let atlas = SKTextureAtlas(named: build.atlas)
        let texture = atlas.textureNamed(String(format: "%@Frame00", build.atlas))
        let sprite = SKSpriteNode(texture: texture)
        sprite.size = aspectFittedSpriteSize(for: texture)
        visualContainer.addChild(sprite)
    }

    // MARK: - Completed Building (full color sprite)

    private func setupCompletedBuilding() {
        // Try to use Midjourney sprite
        if let imageName = buildingSpriteImageName(), spriteImageExists(imageName) {
            let texture = SKTexture(imageNamed: imageName)
            let sprite = SKSpriteNode(texture: texture)
            sprite.size = aspectFittedSpriteSize(for: texture)
            visualContainer.addChild(sprite)
            return
        }

        // Fallback: shape-based building
        let path = createIsometricBuildingPath()

        let building = SKShapeNode(path: path)
        building.fillColor = era == "rome"
            ? PlatformColor(RenaissanceColors.terracotta.opacity(0.8))
            : PlatformColor(RenaissanceColors.ochre.opacity(0.8))
        building.strokeColor = PlatformColor(RenaissanceColors.sepiaInk)
        building.lineWidth = 2
        visualContainer.addChild(building)

        // Completion glow
        let glow = SKShapeNode(circleOfRadius: 35)
        glow.fillColor = PlatformColor(RenaissanceColors.sageGreen.opacity(0.1))
        glow.strokeColor = PlatformColor(RenaissanceColors.sageGreen.opacity(0.3))
        glow.lineWidth = 1
        glow.zPosition = -2
        visualContainer.addChild(glow)
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

    /// Gentle breathing pulse — matches workshop station sprites
    private func addSpritePulse(_ sprite: SKSpriteNode) {
        let scaleUp = SKAction.scale(to: 1.05, duration: 1.2)
        scaleUp.timingMode = .easeInEaseOut
        let scaleDown = SKAction.scale(to: 1.0, duration: 1.2)
        scaleDown.timingMode = .easeInEaseOut
        let pulse = SKAction.sequence([scaleUp, scaleDown])
        sprite.run(SKAction.repeatForever(pulse), withKey: "pulse")
    }

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
        visualContainer.run(bounce)
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
