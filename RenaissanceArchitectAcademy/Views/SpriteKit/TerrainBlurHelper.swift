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

    /// Set up terrain with a pre-sharpened overlay for zoom-in clarity.
    /// Sharp terrain is always visible. Sharpened version fades in when zoomed in
    /// to counteract the softness of bilinear filtering at magnification.
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

        // Generate a pre-sharpened version for zoom-in clarity (~100-200ms one-time cost)
        let sharpenedTexture = Self.sharpenTexture(sharpTexture, sharpness: 0.6)
        let sharpened = SKSpriteNode(texture: sharpenedTexture)
        sharpened.size = mapSize
        sharpened.position = center
        sharpened.zPosition = -99
        sharpened.alpha = 0
        scene.addChild(sharpened)
        blurredTerrainSprite = sharpened  // Reuse the slot — now holds sharpened, not blurred
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

    /// Fade terrain slightly when zoomed in to create depth-of-field feel during walking.
    /// Terrain dims to 0.6 opacity at max zoom, stays full at overview.
    func updateBlur(cameraScale: CGFloat) {
        blurredTerrainSprite?.alpha = 0  // Sharpened overlay not used during walking

        if cameraScale < blurThreshold {
            // Smoothly fade terrain as we zoom closer — depth-of-field effect
            let t = max(0, min(1, (blurThreshold - cameraScale) / blurThreshold))
            terrainSprite?.alpha = 1.0 - t * 0.4  // Fades to 0.6 at max zoom
        } else {
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

    // MARK: - Sharpen Generation

    /// Pre-sharpen a texture using CISharpenLuminance (one-time operation at load).
    /// Sharpens luminance channel only — preserves watercolor colors.
    /// Cost: ~100-200ms for 7000x3910 image, then zero per-frame cost.
    static func sharpenTexture(_ texture: SKTexture, sharpness: CGFloat = 0.6) -> SKTexture {
        let cgImage = texture.cgImage()
        let ciImage = CIImage(cgImage: cgImage)

        guard let filter = CIFilter(name: "CISharpenLuminance") else { return texture }
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(sharpness, forKey: "inputSharpness")

        let context = CIContext()
        guard let outputImage = filter.outputImage,
              let sharpCGImage = context.createCGImage(outputImage, from: ciImage.extent) else {
            return texture
        }

        let result = SKTexture(cgImage: sharpCGImage)
        result.filteringMode = .linear
        return result
    }
}
