import SwiftUI

/// Fetches and caches Metropolitan Museum of Art images for the sketch study system
@MainActor
@Observable class MuseumSketchService {

    static let shared = MuseumSketchService()

    /// In-memory image cache keyed by Met object ID
    private(set) var imageCache: [Int: Image] = [:]
    private(set) var loadingIDs: Set<Int> = []
    /// Aspect ratios (width/height) for loaded images
    private(set) var aspectRatios: [Int: CGFloat] = [:]

    @ObservationIgnored private let urlSession: URLSession
    @ObservationIgnored private var diskCacheURL: URL? {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?
            .appendingPathComponent("MuseumSketches", isDirectory: true)
    }

    private init() {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .returnCacheDataElseLoad
        config.urlCache = URLCache(memoryCapacity: 20_000_000, diskCapacity: 100_000_000)
        self.urlSession = URLSession(configuration: config)

        // Create disk cache directory
        if let cacheDir = diskCacheURL {
            try? FileManager.default.createDirectory(at: cacheDir, withIntermediateDirectories: true)
        }
    }

    /// Load image for a sketch, checking disk cache first then fetching from Met API
    func loadImage(for sketch: MuseumSketch) async {
        let objectID = sketch.id
        guard imageCache[objectID] == nil, !loadingIDs.contains(objectID) else { return }

        loadingIDs.insert(objectID)
        defer { loadingIDs.remove(objectID) }

        // Check disk cache
        if let diskImage = loadFromDisk(objectID: objectID) {
            imageCache[objectID] = diskImage
            return
        }

        // Fetch from network
        guard let url = URL(string: sketch.imageURL) else { return }

        do {
            let (data, response) = try await urlSession.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else { return }

            #if os(iOS)
            guard let uiImage = UIImage(data: data) else { return }
            // Downscale for memory efficiency (max 1024px on longest side)
            let scaled = downsample(uiImage, maxDimension: 1024)
            let image = Image(uiImage: scaled)
            aspectRatios[objectID] = scaled.size.width / scaled.size.height
            #else
            guard let nsImage = NSImage(data: data) else { return }
            let image = Image(nsImage: nsImage)
            aspectRatios[objectID] = nsImage.size.width / nsImage.size.height
            #endif

            imageCache[objectID] = image
            saveToDisk(data: data, objectID: objectID)
        } catch {
            // Network error — silent fail, UI shows placeholder
        }
    }

    /// Preload all sketches for a building
    func preloadSketches(for buildingName: String) {
        let sketches = MuseumSketchContent.sketches(for: buildingName)
        for sketch in sketches {
            Task { await loadImage(for: sketch) }
        }
    }

    // MARK: - Disk Cache

    private func diskPath(objectID: Int) -> URL? {
        diskCacheURL?.appendingPathComponent("met_\(objectID).jpg")
    }

    private func loadFromDisk(objectID: Int) -> Image? {
        guard let path = diskPath(objectID: objectID),
              FileManager.default.fileExists(atPath: path.path) else { return nil }

        #if os(iOS)
        guard let uiImage = UIImage(contentsOfFile: path.path) else { return nil }
        aspectRatios[objectID] = uiImage.size.width / uiImage.size.height
        return Image(uiImage: uiImage)
        #else
        guard let nsImage = NSImage(contentsOfFile: path.path) else { return nil }
        aspectRatios[objectID] = nsImage.size.width / nsImage.size.height
        return Image(nsImage: nsImage)
        #endif
    }

    private func saveToDisk(data: Data, objectID: Int) {
        guard let path = diskPath(objectID: objectID) else { return }
        try? data.write(to: path)
    }

    // MARK: - Image Processing

    #if os(iOS)
    private func downsample(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
        let size = image.size
        let scale = min(maxDimension / max(size.width, size.height), 1.0)
        guard scale < 1.0 else { return image }

        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
    #endif
}
