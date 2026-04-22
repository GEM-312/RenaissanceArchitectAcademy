import Foundation
#if os(iOS)
import UIKit
typealias PlatformImage = UIImage
#else
import AppKit
typealias PlatformImage = NSImage
#endif

/// Renders a student's Pianta floor-plan sketch into a Renaissance-style watercolor
/// blueprint using fal.ai's Flux Kontext Pro model.
///
/// Flux Kontext Pro is an image-editing model: given an input image + prompt, it
/// transforms the image while preserving spatial structure. That's exactly the
/// "keep walls where the student drew them, apply Renaissance style" transformation
/// our sketching mini-game needs — without the strict-ControlNet plumbing of SDXL.
///
/// Cost: ~$0.04 per render. Cached on disk per building, so each building only
/// costs once per student for the lifetime of their save file.
@MainActor
@Observable class FalSketchService {

    static let shared = FalSketchService()

    // MARK: - Configuration

    /// Flux Kontext Pro endpoint (queue mode — async with polling).
    private static let submitURL = URL(string: "https://queue.fal.run/fal-ai/flux-pro/kontext")!
    private static let statusURLBase = "https://queue.fal.run/fal-ai/flux-pro/kontext/requests/"

    private static let pollInterval: TimeInterval = 1.0
    private static let timeoutInterval: TimeInterval = 90.0

    private static let stylePrompt = """
        Transform this floor plan sketch into a Leonardo da Vinci Renaissance \
        architectural blueprint. Sepia ink line work on aged parchment, delicate \
        watercolor wash, elegant classical style. Preserve the exact layout of \
        walls, columns, and rooms. Clean, refined, museum-quality.
        """

    // MARK: - State

    var isRendering = false
    var lastError: String?

    // MARK: - Errors

    enum RenderError: LocalizedError {
        case invalidKey
        case encodingFailed
        case networkFailed(String)
        case timeout
        case noImageReturned

        var errorDescription: String? {
            switch self {
            case .invalidKey: return "fal.ai API key is missing or invalid."
            case .encodingFailed: return "Couldn't encode the sketch image."
            case .networkFailed(let msg): return "Network error: \(msg)"
            case .timeout: return "Render timed out after 90 seconds."
            case .noImageReturned: return "fal.ai returned no image."
            }
        }
    }

    // MARK: - Public API

    /// Render a sketch into a Renaissance watercolor blueprint.
    /// - Parameters:
    ///   - sketch: The student's sketch (PiantaCanvas render).
    ///   - buildingId: Used as cache key — second call with same id returns instantly.
    /// - Returns: A Renaissance-styled PlatformImage.
    func render(sketch: PlatformImage, buildingId: String) async throws -> PlatformImage {
        if let cached = cachedBlueprint(for: buildingId) {
            return cached
        }

        guard APIKeys.falAI != "REPLACE_WITH_KEY", !APIKeys.falAI.isEmpty else {
            throw RenderError.invalidKey
        }

        isRendering = true
        lastError = nil
        defer { isRendering = false }

        guard let pngData = sketch.pngData() else {
            throw RenderError.encodingFailed
        }
        let dataURL = "data:image/png;base64,\(pngData.base64EncodedString())"

        let requestId = try await submitRequest(imageDataURL: dataURL)
        let resultImageURL = try await pollForResult(requestId: requestId)
        let rendered = try await downloadImage(from: resultImageURL)

        try? cacheBlueprint(rendered, for: buildingId)
        return rendered
    }

    /// Returns a previously-rendered blueprint from disk if one exists.
    func cachedBlueprint(for buildingId: String) -> PlatformImage? {
        let url = cacheURL(for: buildingId)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return PlatformImage(data: data)
    }

    /// Wipe all cached blueprints.
    func clearCache() {
        let dir = cacheDirectory()
        try? FileManager.default.removeItem(at: dir)
    }

    // MARK: - Request flow

    private func submitRequest(imageDataURL: String) async throws -> String {
        var request = URLRequest(url: Self.submitURL)
        request.httpMethod = "POST"
        request.setValue("Key \(APIKeys.falAI)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "prompt": Self.stylePrompt,
            "image_url": imageDataURL,
            "guidance_scale": 3.5,
            "num_images": 1,
            "safety_tolerance": "2",
            "output_format": "png"
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            let msg = String(data: data, encoding: .utf8) ?? "unknown"
            throw RenderError.networkFailed("submit failed: \(msg)")
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let requestId = json["request_id"] as? String else {
            throw RenderError.networkFailed("submit: no request_id in response")
        }
        return requestId
    }

    private func pollForResult(requestId: String) async throws -> URL {
        let deadline = Date().addingTimeInterval(Self.timeoutInterval)
        let statusURL = URL(string: Self.statusURLBase + requestId + "/status")!
        let resultURL = URL(string: Self.statusURLBase + requestId)!

        while Date() < deadline {
            try await Task.sleep(nanoseconds: UInt64(Self.pollInterval * 1_000_000_000))

            var request = URLRequest(url: statusURL)
            request.setValue("Key \(APIKeys.falAI)", forHTTPHeaderField: "Authorization")

            let (data, _) = try await URLSession.shared.data(for: request)
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let status = json["status"] as? String else {
                continue
            }

            if status == "COMPLETED" {
                return try await fetchResultImageURL(from: resultURL)
            }
            if status == "FAILED" {
                throw RenderError.networkFailed("fal.ai prediction failed")
            }
        }
        throw RenderError.timeout
    }

    private func fetchResultImageURL(from resultURL: URL) async throws -> URL {
        var request = URLRequest(url: resultURL)
        request.setValue("Key \(APIKeys.falAI)", forHTTPHeaderField: "Authorization")

        let (data, _) = try await URLSession.shared.data(for: request)
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let images = json["images"] as? [[String: Any]],
              let first = images.first,
              let urlString = first["url"] as? String,
              let url = URL(string: urlString) else {
            throw RenderError.noImageReturned
        }
        return url
    }

    private func downloadImage(from url: URL) async throws -> PlatformImage {
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let image = PlatformImage(data: data) else {
            throw RenderError.noImageReturned
        }
        return image
    }

    // MARK: - Cache

    private func cacheDirectory() -> URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dir = docs.appendingPathComponent("SketchRenders", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    private func cacheURL(for buildingId: String) -> URL {
        cacheDirectory().appendingPathComponent("\(buildingId).png")
    }

    private func cacheBlueprint(_ image: PlatformImage, for buildingId: String) throws {
        guard let data = image.pngData() else { throw RenderError.encodingFailed }
        try data.write(to: cacheURL(for: buildingId))
    }
}

// MARK: - PlatformImage PNG helper (macOS only — iOS UIImage already has pngData())

#if os(macOS)
private extension NSImage {
    func pngData() -> Data? {
        guard let tiff = self.tiffRepresentation,
              let rep = NSBitmapImageRep(data: tiff) else { return nil }
        return rep.representation(using: .png, properties: [:])
    }
}
#endif
