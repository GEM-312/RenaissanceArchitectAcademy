import SwiftUI

/// Smart material icon — displays a generated sketch-style image when available,
/// falls back to the existing emoji icon when Image Playground isn't available or cached.
///
/// Usage: Replace `Text(material.icon)` with `MaterialIconView(material: material)`
/// The view handles caching, background generation, and graceful fallback automatically.
struct MaterialIconView: View {
    let material: Material
    var size: CGFloat = 32

    /// Generated image from cache (nil if not yet generated)
    @State private var generatedImage: CGImage?
    @State private var isGenerating = false

    var body: some View {
        Group {
            if let image = generatedImage {
                // Generated sketch-style image
                Image(decorative: image, scale: 1.0)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: size * 0.15))
            } else {
                // Emoji fallback (always available)
                Text(material.icon)
                    .font(.system(size: size * 0.75))
            }
        }
        .frame(width: size, height: size)
        .onAppear {
            loadOrGenerate()
        }
    }

    private func loadOrGenerate() {
        // Check if Image Playground is available
        if #available(iOS 26.0, macOS 26.0, *), ImageGenerationService.isAvailable {
            let service = ImageGenerationService.shared

            // Check cache first (synchronous)
            if let cached = service.cachedImage(for: material.imageCacheKey) {
                generatedImage = cached
                return
            }

            // Generate in background (non-blocking)
            guard !isGenerating else { return }
            isGenerating = true
            Task {
                do {
                    let image = try await service.generateImage(
                        prompt: material.imagePrompt + ". On a simple warm stone surface, clean background.",
                        cacheKey: material.imageCacheKey,
                        style: .sketch
                    )
                    generatedImage = image
                } catch {
                    // Silently fall back to emoji — no user-visible error
                    print("[MaterialIconView] Generation failed for \(material.rawValue): \(error)")
                }
                isGenerating = false
            }
        }
        // If not available, emoji fallback is already showing
    }
}

// MARK: - Batch Generation Helper

/// Generate all material images in the background. Call once on first iOS 26+ launch.
/// Non-blocking — images appear as they're generated, views update via cache checks.
@available(iOS 26.0, macOS 26.0, *)
@MainActor
func generateAllMaterialImages(onProgress: ((Int, Int) -> Void)? = nil) async {
    // Generate each material with .animation style (no parchment prefix)
    let uncached = Material.allCases.filter {
        !ImageGenerationService.shared.isCached($0.imageCacheKey)
    }
    for (index, material) in uncached.enumerated() {
        do {
            _ = try await ImageGenerationService.shared.generateImage(
                prompt: material.imagePrompt + ". On a simple warm stone surface, clean background.",
                cacheKey: material.imageCacheKey,
                style: .sketch
            )
        } catch {
            print("[Materials] Failed: \(material.rawValue) — \(error)")
        }
        onProgress?(index + 1, uncached.count)
    }
}
