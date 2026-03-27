import SwiftUI
import FoundationModels

#if canImport(ImagePlayground)
import ImagePlayground
#endif

// ━━━ TEACHING MOMENT: Image Playground .sketch Style ━━━
//
// THE CONCEPT: Image Playground is Apple's on-device image generation framework.
// The .sketch style produces pen-and-ink drawings — which is EXACTLY our game's
// Leonardo da Vinci notebook aesthetic. We don't need Midjourney for every icon.
//
// STEP BY STEP:
// 1. Create an ImageCreator instance (async — loads the model)
// 2. Call generator.images(for: [.text(prompt)], style: .sketch, limit: 1)
// 3. Iterate the async sequence to get CGImage results
// 4. Cache to disk so we never regenerate the same image twice
//
// IN OUR CODE: Materials get sketch-style icons, knowledge cards get
// illustrations, NPCs get portraits — all matching the da Vinci aesthetic.
//
// KEY TAKEAWAY: .sketch style + good prompts = images that look hand-drawn
// in our notebook style. Cache aggressively — generation is CPU-intensive.

/// On-device image generation via Image Playground with persistent disk caching.
///
/// All images use `.sketch` style to match the Leonardo da Vinci notebook aesthetic.
/// Cache lives in `Caches/GeneratedImages/` — the OS can purge it under storage pressure,
/// and images will regenerate on next access.
@available(iOS 26.0, macOS 26.0, *)
@MainActor
class ImageGenerationService: ObservableObject {

    // MARK: - Singleton

    static let shared: ImageGenerationService = ImageGenerationService()

    // MARK: - Published State

    @Published var isGenerating = false
    @Published var activeGenerationCount = 0

    // MARK: - Cache

    private let cacheDirectory: URL
    private var memoryCache: [String: CGImage] = [:]
    private static let maxCacheSizeMB: Int = 200

    /// Style prefix appended to all prompts for consistent aesthetic.
    /// IMPORTANT: Do NOT mention any person's name — Image Playground rejects prompts with person references.
    static let stylePrefix = "Renaissance pen-and-ink sketch on aged parchment, detailed cross-hatching, architectural notebook style: "

    // MARK: - Init

    private init() {
        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        cacheDirectory = caches.appendingPathComponent("GeneratedImages", isDirectory: true)

        // Create cache directory if needed
        try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }

    // MARK: - Availability

    /// Check if Image Playground is available on this device
    static var isAvailable: Bool {
        #if canImport(ImagePlayground)
        // Image Playground availability mirrors Foundation Models availability
        // on iOS 26+ devices with Apple Intelligence enabled
        if #available(iOS 26.0, macOS 26.0, *) {
            switch SystemLanguageModel.default.availability {
            case .available:
                return true
            default:
                return false
            }
        }
        #endif
        return false
    }

    // MARK: - Core Generation

    /// Generate an image from a text prompt, using cache if available.
    ///
    /// - Parameters:
    ///   - prompt: Description of the desired image (style prefix is added automatically)
    ///   - cacheKey: Deterministic key for disk caching (e.g., "material_limestone")
    /// - Returns: Generated CGImage, or nil if generation fails
    /// Image style options for different use cases
    enum Style {
        case sketch      // Pen-and-ink, da Vinci notebook (scenes, materials, cards)
        case animation   // Cleaner, cartoon-like (NPC mascots, characters — no background clutter)

        #if canImport(ImagePlayground)
        @available(iOS 26.0, macOS 26.0, *)
        var playgroundStyle: ImagePlaygroundStyle {
            switch self {
            case .sketch: return .sketch
            case .animation: return .animation
            }
        }
        #endif
    }

    func generateImage(prompt: String, cacheKey: String, style: Style = .sketch) async throws -> CGImage? {
        // Check memory cache first
        if let cached = memoryCache[cacheKey] {
            return cached
        }

        // Check disk cache
        if let diskCached = loadFromDisk(cacheKey: cacheKey) {
            memoryCache[cacheKey] = diskCached
            return diskCached
        }

        // Generate new image
        #if canImport(ImagePlayground)
        activeGenerationCount += 1
        isGenerating = true
        defer {
            activeGenerationCount -= 1
            if activeGenerationCount == 0 {
                isGenerating = false
            }
        }

        // No prefix — the .sketch/.animation style parameter handles the aesthetic.
        // Prompts should describe the subject directly.
        let fullPrompt = prompt
        let generator = try await ImageCreator()
        let generations = generator.images(
            for: [.text(fullPrompt)],
            style: style.playgroundStyle,
            limit: 1
        )

        for try await generation in generations {
            let image = generation.cgImage
            // Cache to memory and disk
            memoryCache[cacheKey] = image
            saveToDisk(image: image, cacheKey: cacheKey)
            return image
        }
        #endif

        return nil
    }

    /// Get a cached image synchronously (for SwiftUI views). Returns nil if not cached.
    func cachedImage(for cacheKey: String) -> CGImage? {
        if let memory = memoryCache[cacheKey] {
            return memory
        }
        if let disk = loadFromDisk(cacheKey: cacheKey) {
            memoryCache[cacheKey] = disk
            return disk
        }
        return nil
    }

    /// Check if an image is already cached (without loading it)
    func isCached(_ cacheKey: String) -> Bool {
        if memoryCache[cacheKey] != nil { return true }
        let fileURL = cacheDirectory.appendingPathComponent("\(cacheKey).png")
        return FileManager.default.fileExists(atPath: fileURL.path)
    }

    // MARK: - Batch Generation

    /// Generate multiple images in sequence (not parallel — respects device resources).
    /// Skips items that are already cached.
    func generateBatch(requests: [(prompt: String, cacheKey: String)],
                       onProgress: ((Int, Int) -> Void)? = nil) async {
        let uncached = requests.filter { !isCached($0.cacheKey) }
        for (index, request) in uncached.enumerated() {
            do {
                _ = try await generateImage(prompt: request.prompt, cacheKey: request.cacheKey)
            } catch {
                print("[ImageGenerationService] Batch item failed: \(request.cacheKey) — \(error)")
            }
            onProgress?(index + 1, uncached.count)
        }
    }

    // MARK: - Cache Management

    /// Total size of cached images on disk, in bytes
    var cacheSizeBytes: Int64 {
        let fm = FileManager.default
        guard let enumerator = fm.enumerator(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey]) else {
            return 0
        }
        var total: Int64 = 0
        for case let fileURL as URL in enumerator {
            if let size = try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                total += Int64(size)
            }
        }
        return total
    }

    /// Formatted cache size for display (e.g., "12.3 MB")
    var formattedCacheSize: String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: cacheSizeBytes)
    }

    /// Clear all generated images from disk and memory
    func clearCache() {
        memoryCache.removeAll()
        try? FileManager.default.removeItem(at: cacheDirectory)
        try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }

    /// Evict oldest cached images if cache exceeds size limit
    func evictIfNeeded() {
        let maxBytes = Int64(Self.maxCacheSizeMB * 1024 * 1024)
        guard cacheSizeBytes > maxBytes else { return }

        let fm = FileManager.default
        guard let enumerator = fm.enumerator(
            at: cacheDirectory,
            includingPropertiesForKeys: [.contentModificationDateKey, .fileSizeKey]
        ) else { return }

        // Collect files with dates
        var files: [(url: URL, date: Date, size: Int64)] = []
        for case let fileURL as URL in enumerator {
            if let values = try? fileURL.resourceValues(forKeys: [.contentModificationDateKey, .fileSizeKey]),
               let date = values.contentModificationDate,
               let size = values.fileSize {
                files.append((fileURL, date, Int64(size)))
            }
        }

        // Sort oldest first (LRU eviction)
        files.sort { $0.date < $1.date }

        var currentSize = cacheSizeBytes
        for file in files {
            guard currentSize > maxBytes else { break }
            try? fm.removeItem(at: file.url)
            currentSize -= file.size
            // Remove from memory cache too
            let key = file.url.deletingPathExtension().lastPathComponent
            memoryCache.removeValue(forKey: key)
        }
    }

    // MARK: - Disk I/O

    private func saveToDisk(image: CGImage, cacheKey: String) {
        let fileURL = cacheDirectory.appendingPathComponent("\(cacheKey).png")

        #if os(iOS)
        let uiImage = UIImage(cgImage: image)
        if let data = uiImage.pngData() {
            try? data.write(to: fileURL, options: .atomic)
        }
        #else
        let nsImage = NSImage(cgImage: image, size: NSSize(width: image.width, height: image.height))
        if let tiffData = nsImage.tiffRepresentation,
           let bitmap = NSBitmapImageRep(data: tiffData),
           let pngData = bitmap.representation(using: .png, properties: [:]) {
            try? pngData.write(to: fileURL, options: .atomic)
        }
        #endif

        // Evict if over limit
        evictIfNeeded()
    }

    private func loadFromDisk(cacheKey: String) -> CGImage? {
        let fileURL = cacheDirectory.appendingPathComponent("\(cacheKey).png")
        guard FileManager.default.fileExists(atPath: fileURL.path),
              let data = try? Data(contentsOf: fileURL) else {
            return nil
        }

        #if os(iOS)
        return UIImage(data: data)?.cgImage
        #else
        guard let nsImage = NSImage(data: data),
              let cgImage = nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return nil
        }
        return cgImage
        #endif
    }
}
