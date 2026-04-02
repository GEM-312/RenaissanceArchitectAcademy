import SpriteKit
import CoreImage

/// Reusable terrain blur system — manages sharp/blurred terrain crossfade based on camera zoom.
/// Used by all outdoor SpriteKit scenes for consistent depth-of-field effect.
///
/// Zero ongoing GPU cost: pre-blurred texture is a static sprite, crossfade is just alpha changes.
///
/// Usage:
///   1. In `didMove(to:)`:  `terrainBlur.setup(in: self, sharp: "Terrain", blurred: "BlurredTerrain", mapSize: mapSize)`
///   2. In `update()`:      `terrainBlur.updateCrossfade(cameraScale: cameraNode.xScale)`
///   3. In `willMove(from:)`: `terrainBlur.cleanup()`
class TerrainBlurHelper {

    /// The sharp (zoomed-out) terrain sprite
    private(set) var terrainSprite: SKSpriteNode?
    /// The blurred (zoomed-in) terrain sprite
    private(set) var blurredTerrainSprite: SKSpriteNode?
    /// Solid-color fill behind terrain to hide faded Midjourney edges when camera pans to map borders
    private(set) var fillSprite: SKSpriteNode?

    /// Camera scale below which blurred terrain shows (instant swap, no crossfade)
    var blurThreshold: CGFloat = 0.95

    // MARK: - Setup with pre-blurred asset

    /// Set up terrain pair using a pre-blurred image from the asset catalog.
    /// This is the preferred approach — zero setup cost, zero GPU cost.
    /// - Parameter edgeFillColor: Optional solid color placed behind terrain (2x mapSize) to hide faded Midjourney edges.
    func setup(in scene: SKScene, sharp sharpImage: String, blurred blurredImage: String, mapSize: CGSize, edgeFillColor: PlatformColor? = nil) {
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

        let blurredTexture = SKTexture(imageNamed: blurredImage)
        blurredTexture.filteringMode = .linear
        let blurred = SKSpriteNode(texture: blurredTexture)
        blurred.size = mapSize
        blurred.position = center
        blurred.zPosition = -99
        blurred.alpha = 0
        scene.addChild(blurred)
        blurredTerrainSprite = blurred
    }

    // MARK: - Setup with auto-generated blur

    /// Set up terrain pair by generating the blurred version at runtime.
    /// One-time CIFilter cost at scene load (~50ms for 2912x1632), then zero GPU cost.
    /// Use this when no pre-blurred asset exists (e.g. ForestScene).
    /// - Parameter edgeFillColor: Optional solid color placed behind terrain (2x mapSize) to hide faded Midjourney edges.
    func setup(in scene: SKScene, sharp sharpImage: String, mapSize: CGSize, blurRadius: CGFloat = 12.0, edgeFillColor: PlatformColor? = nil) {
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

        // Generate blurred texture from sharp one (one-time cost, not per-frame)
        let blurredTexture = Self.blurTexture(sharpTexture, radius: blurRadius)
        blurredTexture.filteringMode = .linear
        let blurred = SKSpriteNode(texture: blurredTexture)
        blurred.size = mapSize
        blurred.position = center
        blurred.zPosition = -99
        blurred.alpha = 0
        scene.addChild(blurred)
        blurredTerrainSprite = blurred
    }

    // MARK: - Update (call every frame)

    /// Smooth crossfade between sharp and blurred terrain based on camera zoom.
    /// Call this in the scene's `update(_:)` method.
    /// Instant swap: sharp when zoomed out, blurred when zoomed in. No crossfade.
    func updateBlur(cameraScale: CGFloat) {
        if cameraScale < blurThreshold {
            // Zoomed in — show blurred
            blurredTerrainSprite?.alpha = 1
            terrainSprite?.alpha = 0
        } else {
            // Zoomed out — show sharp
            blurredTerrainSprite?.alpha = 0
            terrainSprite?.alpha = 1
        }
    }

    // MARK: - Cleanup

    /// Release sprite references. Call in `willMove(from:)`.
    func cleanup() {
        terrainSprite = nil
        blurredTerrainSprite = nil
        fillSprite = nil
    }

    // MARK: - Blur Generation

    /// Generate a blurred version of a texture using CIGaussianBlur (one-time operation).
    private static func blurTexture(_ texture: SKTexture, radius: CGFloat) -> SKTexture {
        let cgImage = texture.cgImage()
        let ciImage = CIImage(cgImage: cgImage)

        guard let filter = CIFilter(name: "CIGaussianBlur") else { return texture }
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(radius, forKey: kCIInputRadiusKey)

        let context = CIContext()
        guard let outputImage = filter.outputImage,
              let blurredCGImage = context.createCGImage(outputImage, from: ciImage.extent) else {
            return texture
        }

        return SKTexture(cgImage: blurredCGImage)
    }
}
