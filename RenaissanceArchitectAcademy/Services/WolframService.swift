import Foundation

// MARK: - Wolfram Alpha Response Models

/// Parsed result from Wolfram Alpha Full Results API
struct WolframResult {
    let pods: [WolframPod]

    /// Get the first plaintext answer from a specific pod title
    func text(for podTitle: String) -> String? {
        pods.first(where: { $0.title.localizedCaseInsensitiveContains(podTitle) })?.subpods.first?.plaintext
    }

    /// Get all plaintext answers joined
    var allText: String {
        pods.flatMap { $0.subpods.compactMap { $0.plaintext } }.joined(separator: "\n")
    }

    /// Get the first image URL from a specific pod
    func imageURL(for podTitle: String) -> URL? {
        guard let src = pods.first(where: { $0.title.localizedCaseInsensitiveContains(podTitle) })?.subpods.first?.imageSrc else { return nil }
        return URL(string: src)
    }
}

struct WolframPod {
    let title: String
    let subpods: [WolframSubpod]
}

struct WolframSubpod {
    let plaintext: String?
    let imageSrc: String?
}

// MARK: - XML Parser

/// Wolfram Full Results API returns XML — this parser extracts pods and subpods
private class WolframXMLParser: NSObject, XMLParserDelegate {
    var pods: [WolframPod] = []
    private var currentPodTitle = ""
    private var currentSubpods: [WolframSubpod] = []
    private var currentPlaintext: String?
    private var currentImageSrc: String?
    private var currentElement = ""
    private var textBuffer = ""
    private var inPlaintext = false

    func parse(data: Data) -> [WolframPod] {
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
        return pods
    }

    func parser(_ parser: XMLParser, didStartElement element: String, namespaceURI: String?,
                qualifiedName: String?, attributes: [String: String] = [:]) {
        currentElement = element
        if element == "pod" {
            currentPodTitle = attributes["title"] ?? ""
            currentSubpods = []
        } else if element == "subpod" {
            currentPlaintext = nil
            currentImageSrc = nil
        } else if element == "plaintext" {
            inPlaintext = true
            textBuffer = ""
        } else if element == "img" {
            currentImageSrc = attributes["src"]
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if inPlaintext {
            textBuffer += string
        }
    }

    func parser(_ parser: XMLParser, didEndElement element: String, namespaceURI: String?,
                qualifiedName: String?) {
        if element == "plaintext" {
            inPlaintext = false
            let text = textBuffer.trimmingCharacters(in: .whitespacesAndNewlines)
            currentPlaintext = text.isEmpty ? nil : text
        } else if element == "subpod" {
            currentSubpods.append(WolframSubpod(plaintext: currentPlaintext, imageSrc: currentImageSrc))
        } else if element == "pod" {
            pods.append(WolframPod(title: currentPodTitle, subpods: currentSubpods))
        }
    }
}

// MARK: - Wolfram Service

/// Queries Wolfram Alpha for chemical/scientific information.
///
/// Usage:
/// ```swift
/// let result = try await wolframService.query("chemical formula calcium carbonate")
/// let formula = result.text(for: "Chemical formula")
/// ```
actor WolframService {

    private let appID = APIKeys.wolframAlpha
    private var cache: [String: WolframResult] = [:]

    /// Full Results query — returns structured pods with text + images
    func query(_ input: String) async throws -> WolframResult {
        let key = input.lowercased()
        if let cached = cache[key] { return cached }

        let encoded = input.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? input
        let urlString = "https://api.wolframalpha.com/v2/query?input=\(encoded)&appid=\(appID)&format=plaintext,image"
        guard let url = URL(string: urlString) else {
            throw WolframError.invalidQuery
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw WolframError.requestFailed
        }

        let parser = WolframXMLParser()
        let pods = parser.parse(data: data)
        guard !pods.isEmpty else {
            throw WolframError.noResults(input)
        }

        let result = WolframResult(pods: pods)
        cache[key] = result
        return result
    }

    /// Short answer — returns a single text string (faster, simpler)
    func shortAnswer(_ input: String) async throws -> String {
        let encoded = input.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? input
        let urlString = "https://api.wolframalpha.com/v1/result?i=\(encoded)&appid=\(appID)"
        guard let url = URL(string: urlString) else {
            throw WolframError.invalidQuery
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw WolframError.requestFailed
        }

        guard let text = String(data: data, encoding: .utf8), !text.isEmpty else {
            throw WolframError.noResults(input)
        }
        return text
    }

    /// Get chemical properties for a compound
    func chemicalProperties(of compound: String) async throws -> ChemicalInfo {
        let result = try await query("chemical properties of \(compound)")

        return ChemicalInfo(
            name: compound,
            formula: result.text(for: "Formula") ?? result.text(for: "Chemical formula"),
            molecularWeight: result.text(for: "Molecular weight") ?? result.text(for: "Molar mass"),
            meltingPoint: result.text(for: "Melting point"),
            boilingPoint: result.text(for: "Boiling point"),
            density: result.text(for: "Density"),
            structure: result.text(for: "Structure") ?? result.text(for: "Chemical names"),
            allPods: result.pods
        )
    }

    /// Get a balanced chemical reaction
    func reaction(_ equation: String) async throws -> ReactionInfo {
        let result = try await query("balance \(equation)")

        return ReactionInfo(
            balanced: result.text(for: "Balanced equation") ?? result.text(for: "Result"),
            reactants: result.text(for: "Reactants"),
            products: result.text(for: "Products"),
            reactionType: result.text(for: "Reaction type"),
            allPods: result.pods
        )
    }
}

// MARK: - Result Types

struct ChemicalInfo {
    let name: String
    let formula: String?
    let molecularWeight: String?
    let meltingPoint: String?
    let boilingPoint: String?
    let density: String?
    let structure: String?
    let allPods: [WolframPod]
}

struct ReactionInfo {
    let balanced: String?
    let reactants: String?
    let products: String?
    let reactionType: String?
    let allPods: [WolframPod]
}

// MARK: - Errors

enum WolframError: LocalizedError {
    case invalidQuery
    case requestFailed
    case noResults(String)

    var errorDescription: String? {
        switch self {
        case .invalidQuery: return "Invalid Wolfram Alpha query"
        case .requestFailed: return "Wolfram Alpha request failed"
        case .noResults(let q): return "No results for '\(q)'"
        }
    }
}
