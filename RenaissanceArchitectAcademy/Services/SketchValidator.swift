import Foundation
#if os(iOS)
import UIKit
/// Platform-agnostic image type — UIImage on iOS/iPadOS, NSImage on macOS.
typealias PlatformImage = UIImage
#else
import AppKit
typealias PlatformImage = NSImage
#endif

/// Grades a student's floor-plan sketch against a reference engineering plan
/// by sending both images to Claude Haiku's vision endpoint and asking for a
/// structured similarity assessment.
/// Cost per comparison: ~$0.005 (Claude Haiku, ~2k input tokens + 2 image slots
/// + ~300 output tokens).
@MainActor
@Observable final class SketchValidator {

    static let shared = SketchValidator()

    // MARK: - Types

    struct Result: Codable {
        /// Similarity 0–100 between student sketch and reference plan.
        let score: Int
        /// Architectural elements the student got right (e.g. "Circular rotunda", "8 front columns").
        let strengths: [String]
        /// Elements that are missing, misplaced, or wrong (e.g. "Portico detached from rotunda").
        let gaps: [String]

        /// True when the sketch meets the passing threshold; below this = retry.
        var passed: Bool { score >= 60 }
    }

    enum ValidationError: LocalizedError {
        case encodingFailed
        case invalidKey
        case networkFailed(String)
        case unparseableResponse(String)

        var errorDescription: String? {
            switch self {
            case .encodingFailed:        return "Couldn't encode the sketch image."
            case .invalidKey:            return "Claude API key is missing."
            case .networkFailed(let m):  return "Network error: \(m)"
            case .unparseableResponse(let m): return "Couldn't parse Claude response: \(m)"
            }
        }
    }

    // MARK: - Configuration

    private static let apiURL = URL(string: "https://api.anthropic.com/v1/messages")!
    private static let model = "claude-haiku-4-5-20251001"
    private static let maxTokens = 512

    // MARK: - State

    var isValidating = false
    var lastError: String?

    // MARK: - Public API

    /// Compare a student sketch PNG to a reference floor plan PNG.
    /// - Parameters:
    ///   - studentSketch: PNG the student drew on the canvas.
    ///   - referencePlan: PNG of the correct engineering floor plan for this building.
    ///   - buildingName: Used only for a richer prompt ("...for the Pantheon").
    func validate(studentSketch: PlatformImage,
                  referencePlan: PlatformImage,
                  buildingName: String) async throws -> Result {
        print("[SketchValidator] validate requested: building=\(buildingName)")

        guard APIKeys.claude.hasPrefix("sk-ant-") else {
            throw ValidationError.invalidKey
        }

        guard let studentData = studentSketch.pngDataCompat(),
              let referenceData = referencePlan.pngDataCompat() else {
            throw ValidationError.encodingFailed
        }
        print("[SketchValidator] student PNG: \(studentData.count) bytes, reference PNG: \(referenceData.count) bytes")

        isValidating = true
        lastError = nil
        defer { isValidating = false }

        let body = requestBody(
            studentBase64: studentData.base64EncodedString(),
            referenceBase64: referenceData.base64EncodedString(),
            buildingName: buildingName
        )

        var request = URLRequest(url: Self.apiURL)
        request.httpMethod = "POST"
        request.setValue(APIKeys.claude, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)
        let code = (response as? HTTPURLResponse)?.statusCode ?? -1
        guard (200..<300).contains(code) else {
            let msg = String(data: data, encoding: .utf8) ?? "<no body>"
            print("[SketchValidator] HTTP \(code): \(msg)")
            throw ValidationError.networkFailed("HTTP \(code): \(msg)")
        }

        return try parseResult(from: data)
    }

    // MARK: - Request construction

    private func requestBody(studentBase64: String, referenceBase64: String, buildingName: String) -> [String: Any] {
        // Claude vision expects inline image blocks in the user message content array.
        [
            "model": Self.model,
            "max_tokens": Self.maxTokens,
            "system": """
                You are an architecture tutor grading a student's floor-plan sketch for \
                \(buildingName). You will receive two images: (1) the student's sketch, \
                (2) the correct engineering floor plan. Compare them and reply with a \
                JSON object ONLY — no prose, no markdown, no explanation outside JSON.

                JSON shape:
                { "score": <int 0-100>,
                  "strengths": [<short phrase>, ...],
                  "gaps": [<short phrase>, ...] }

                Guidelines:
                - score: 100 if the sketch matches the reference closely in major shapes, \
                  positions, and proportions. 0 if it's blank or unrelated.
                - strengths: 2–5 short phrases describing what the student got right.
                - gaps: 2–5 short phrases for what's missing, misplaced, or wrong.
                - Be kind but honest. This is an educational game for students.
                """,
            "messages": [
                [
                    "role": "user",
                    "content": [
                        ["type": "text", "text": "Image 1 — my sketch:"],
                        ["type": "image",
                         "source": ["type": "base64", "media_type": "image/png", "data": studentBase64]],
                        ["type": "text", "text": "Image 2 — the correct engineering floor plan:"],
                        ["type": "image",
                         "source": ["type": "base64", "media_type": "image/png", "data": referenceBase64]],
                        ["type": "text", "text": "Grade my sketch against the reference. Reply with JSON only."]
                    ]
                ]
            ]
        ]
    }

    // MARK: - Response parsing

    private func parseResult(from data: Data) throws -> Result {
        guard let top = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let content = top["content"] as? [[String: Any]],
              let textBlock = content.first(where: { ($0["type"] as? String) == "text" }),
              let text = textBlock["text"] as? String else {
            throw ValidationError.unparseableResponse("no text block in response")
        }

        // Claude sometimes wraps JSON in ```json fences despite instructions — strip them.
        let trimmed = text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let jsonData = trimmed.data(using: .utf8) else {
            throw ValidationError.unparseableResponse("couldn't convert Claude text to data")
        }

        do {
            let result = try JSONDecoder().decode(Result.self, from: jsonData)
            print("[SketchValidator] ✅ score=\(result.score), strengths=\(result.strengths.count), gaps=\(result.gaps.count)")
            return result
        } catch {
            throw ValidationError.unparseableResponse("Claude returned: \(trimmed)")
        }
    }
}

// MARK: - PlatformImage PNG helper

private extension PlatformImage {
    func pngDataCompat() -> Data? {
        #if os(iOS)
        return pngData()
        #else
        guard let tiff = tiffRepresentation,
              let rep = NSBitmapImageRep(data: tiff) else { return nil }
        return rep.representation(using: .png, properties: [:])
        #endif
    }
}
