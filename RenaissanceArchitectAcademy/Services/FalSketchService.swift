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

    /// Which architectural view the student is sketching. Each phase gets its own
    /// prompt wording and its own cache slot, so a building rendered in multiple
    /// phases produces distinct blueprints (one per view).
    ///
    /// Currently only `.pianta` is wired into the apprentice UI; the other three
    /// cases exist so the service is ready when architect-tier brings back
    /// Alzato / Sezione / Prospettiva.
    enum SketchPhase: String, CaseIterable {
        case pianta, alzato, sezione, prospettiva

        var viewDescription: String {
            switch self {
            case .pianta:      return "floor plan — strict top-down plan view, no perspective, no 3D"
            case .alzato:      return "front elevation — strict orthographic front view, no perspective"
            case .sezione:     return "architectural cross-section — strict vertical cut view, no perspective"
            case .prospettiva: return "one-point perspective rendering with a single vanishing point"
            }
        }
    }

    private static func stylePrompt(for phase: SketchPhase) -> String {
        """
        Redraw this sketch as a precise Renaissance architectural drawing: a \
        \(phase.viewDescription). Sepia ink line work on aged parchment with a \
        delicate watercolor wash, in the style of a Leonardo da Vinci technical \
        notebook page. Preserve the EXACT layout of every wall, column, and circle \
        from the input. Crisp geometric lines, accurate proportions, no decorative \
        corner elements, no ornamental flourishes, no 3D or isometric details.
        """
    }

    // MARK: - State

    var isRendering = false
    var lastError: String?

    // MARK: - Errors

    enum RenderError: LocalizedError {
        case notSubscribed
        case invalidKey
        case encodingFailed
        case networkFailed(String)
        case timeout
        case noImageReturned

        var errorDescription: String? {
            switch self {
            case .notSubscribed: return "Blueprint rendering is an Apprentice-tier feature."
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
    ///   - sketch: The student's sketch (from the phase's canvas view).
    ///   - buildingId: Combined with `phase` as cache key — second call with same
    ///     (buildingId, phase) returns instantly from disk.
    ///   - phase: Which architectural view this sketch represents. Controls the
    ///     style prompt and cache slot.
    /// - Throws: `RenderError.notSubscribed` if the player isn't on a paid tier.
    /// - Returns: A Renaissance-styled PlatformImage.
    func render(sketch: PlatformImage, buildingId: String, phase: SketchPhase) async throws -> PlatformImage {
        print("[FalSketchService] render requested: building=\(buildingId) phase=\(phase.rawValue)")

        guard GameSettings.shared.isSubscribed else {
            print("[FalSketchService] ❌ notSubscribed")
            throw RenderError.notSubscribed
        }

        if let cached = cachedBlueprint(for: buildingId, phase: phase) {
            print("[FalSketchService] ✅ cache hit")
            return cached
        }

        guard APIKeys.falAI != "REPLACE_WITH_KEY", !APIKeys.falAI.isEmpty else {
            print("[FalSketchService] ❌ invalidKey — APIKeys.falAI not set")
            throw RenderError.invalidKey
        }

        isRendering = true
        lastError = nil
        defer { isRendering = false }

        guard let pngData = sketch.pngData() else {
            print("[FalSketchService] ❌ encodingFailed — sketch.pngData() returned nil")
            throw RenderError.encodingFailed
        }
        print("[FalSketchService] PNG size: \(pngData.count) bytes")
        let dataURL = "data:image/png;base64,\(pngData.base64EncodedString())"

        do {
            let submit = try await submitRequest(imageDataURL: dataURL, phase: phase)
            print("[FalSketchService] submit OK, request_id=\(submit.requestId)")
            print("[FalSketchService] status_url=\(submit.statusURL)")
            let resultImageURL = try await pollForResult(statusURL: submit.statusURL, responseURL: submit.responseURL)
            print("[FalSketchService] poll OK, result URL=\(resultImageURL)")
            let rendered = try await downloadImage(from: resultImageURL)
            print("[FalSketchService] ✅ render complete")
            try? cacheBlueprint(rendered, for: buildingId, phase: phase)
            return rendered
        } catch {
            print("[FalSketchService] ❌ \(error)")
            lastError = String(describing: error)
            throw error
        }
    }

    /// Returns a previously-rendered blueprint from disk if one exists for this (building, phase).
    func cachedBlueprint(for buildingId: String, phase: SketchPhase) -> PlatformImage? {
        let url = cacheURL(for: buildingId, phase: phase)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return PlatformImage(data: data)
    }

    /// Wipe all cached blueprints.
    func clearCache() {
        let dir = cacheDirectory()
        try? FileManager.default.removeItem(at: dir)
    }

    // MARK: - Request flow

    /// Submit response carries back the URLs fal.ai wants us to poll, so we use
    /// those directly instead of constructing them (avoids URL-format drift).
    private struct SubmitResponse {
        let requestId: String
        let statusURL: URL
        let responseURL: URL
    }

    private func submitRequest(imageDataURL: String, phase: SketchPhase) async throws -> SubmitResponse {
        var request = URLRequest(url: Self.submitURL)
        request.httpMethod = "POST"
        request.setValue("Key \(APIKeys.falAI)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "prompt": Self.stylePrompt(for: phase),
            "image_url": imageDataURL,
            // Default is 3.5; higher = more strict adherence to prompt + input layout.
            // 6.0 seems to keep Flux from simplifying multi-column colonnades into 4-5 columns.
            "guidance_scale": 6.0,
            "num_images": 1,
            "output_format": "png"
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            let code = (response as? HTTPURLResponse)?.statusCode ?? -1
            let msg = String(data: data, encoding: .utf8) ?? "unknown"
            print("[FalSketchService] submit HTTP \(code): \(msg)")
            throw RenderError.networkFailed("HTTP \(code): \(msg)")
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let requestId = json["request_id"] as? String else {
            throw RenderError.networkFailed("submit: no request_id in response")
        }

        // Prefer the URLs fal.ai returns. Fall back to constructing them if missing.
        let statusURL = (json["status_url"] as? String).flatMap(URL.init(string:))
            ?? URL(string: Self.statusURLBase + requestId + "/status")!
        let responseURL = (json["response_url"] as? String).flatMap(URL.init(string:))
            ?? URL(string: Self.statusURLBase + requestId)!

        return SubmitResponse(requestId: requestId, statusURL: statusURL, responseURL: responseURL)
    }

    private func pollForResult(statusURL: URL, responseURL: URL) async throws -> URL {
        let deadline = Date().addingTimeInterval(Self.timeoutInterval)

        while Date() < deadline {
            try await Task.sleep(nanoseconds: UInt64(Self.pollInterval * 1_000_000_000))

            var request = URLRequest(url: statusURL)
            request.setValue("Key \(APIKeys.falAI)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Accept")

            let (data, response) = try await URLSession.shared.data(for: request)
            let code = (response as? HTTPURLResponse)?.statusCode ?? -1

            // Empty body or non-JSON → keep polling (common right after submit)
            guard !data.isEmpty else {
                print("[FalSketchService] poll HTTP \(code): empty body — retrying")
                continue
            }
            guard let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] else {
                let preview = String(data: data.prefix(200), encoding: .utf8) ?? "<binary>"
                print("[FalSketchService] poll HTTP \(code): non-JSON body: \(preview) — retrying")
                continue
            }
            guard let status = json["status"] as? String else {
                print("[FalSketchService] poll HTTP \(code): json has no status field — retrying. keys=\(Array(json.keys))")
                continue
            }

            print("[FalSketchService] poll status=\(status)")

            if status == "COMPLETED" {
                return try await fetchResultImageURL(from: responseURL)
            }
            if status == "FAILED" {
                let errMsg = json["error"] as? String ?? String(describing: json)
                throw RenderError.networkFailed("fal.ai prediction failed: \(errMsg)")
            }
        }
        throw RenderError.timeout
    }

    private func fetchResultImageURL(from resultURL: URL) async throws -> URL {
        var request = URLRequest(url: resultURL)
        request.setValue("Key \(APIKeys.falAI)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await URLSession.shared.data(for: request)
        let code = (response as? HTTPURLResponse)?.statusCode ?? -1
        guard let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] else {
            let preview = String(data: data.prefix(200), encoding: .utf8) ?? "<binary>"
            print("[FalSketchService] result HTTP \(code): non-JSON body: \(preview)")
            throw RenderError.noImageReturned
        }
        guard let images = json["images"] as? [[String: Any]],
              let first = images.first,
              let urlString = first["url"] as? String,
              let url = URL(string: urlString) else {
            print("[FalSketchService] result HTTP \(code): no images in response. keys=\(Array(json.keys))")
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

    private func cacheURL(for buildingId: String, phase: SketchPhase) -> URL {
        cacheDirectory().appendingPathComponent("\(buildingId)_\(phase.rawValue).png")
    }

    private func cacheBlueprint(_ image: PlatformImage, for buildingId: String, phase: SketchPhase) throws {
        guard let data = image.pngData() else { throw RenderError.encodingFailed }
        try data.write(to: cacheURL(for: buildingId, phase: phase))
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
