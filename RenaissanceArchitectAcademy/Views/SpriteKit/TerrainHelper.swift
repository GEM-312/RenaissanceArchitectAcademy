import SpriteKit

/// Reusable terrain setup — one terrain sprite plus an optional edge fill behind it.
/// Used by CityScene and WorkshopScene (ForestScene uses a plain background sprite).
///
/// No blur, sharpen or depth-of-field layer — the old blurred/sharpened zoom overlay
/// was removed 2026-10-13 per Marina ("we don't need any blur layer"), and this class
/// was renamed from `TerrainBlurHelper` on 2026-10-19. Don't re-add one.
///
/// Usage:
///   1. In `didMove(to:)`:  `terrainHelper.setup(in: self, sharp: "Terrain", mapSize: mapSize)`
///   2. In `willMove(from:)`: `terrainHelper.cleanup()`
class TerrainHelper {

    /// The terrain sprite
    private(set) var terrainSprite: SKSpriteNode?
    /// Solid-color fill behind terrain to hide faded Midjourney edges when camera pans to map borders
    private(set) var fillSprite: SKSpriteNode?

    // MARK: - Setup

    /// - Parameter edgeFillColor: Optional solid color placed behind terrain (2x mapSize) to hide faded Midjourney edges.
    func setup(in scene: SKScene, sharp sharpImage: String, mapSize: CGSize, edgeFillColor: PlatformColor? = nil) {
        let center = CGPoint(x: mapSize.width / 2, y: mapSize.height / 2)

        // Edge fill — large solid rect behind everything to cover faded terrain borders
        if let fillColor = edgeFillColor {
            let fill = SKSpriteNode(color: fillColor, size: CGSize(width: mapSize.width * 2, height: mapSize.height * 2))
            fill.position = center
            fill.zPosition = -102
            scene.addChild(fill)
            fillSprite = fill
        }

        let sharpTexture = SKTexture(imageNamed: sharpImage)
        sharpTexture.filteringMode = .linear
        let sharp = SKSpriteNode(texture: sharpTexture)
        sharp.size = mapSize
        sharp.position = center
        sharp.zPosition = -100
        scene.addChild(sharp)
        terrainSprite = sharp
    }

    // MARK: - Cleanup

    /// Release sprite references. Call in `willMove(from:)`.
    func cleanup() {
        terrainSprite = nil
        fillSprite = nil
    }
}
