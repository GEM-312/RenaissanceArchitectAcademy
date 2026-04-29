//
//  WorkerClient.swift
//  RenaissanceArchitectAcademy
//
//  Central config for the Cloudflare Worker proxy. The Worker forwards
//  Anthropic Claude and Wolfram Alpha requests so our API keys never ship
//  in the iOS app binary.
//
//  The proxy token is a shared secret — it proves "this request came from
//  our app" in a weak way (the token still rides along in the binary).
//  Phase 3 of the migration replaces it with Apple App Attest for
//  cryptographic proof.
//

import Foundation

enum WorkerClient {

    /// Cloudflare Worker base URL — not secret, safe to hardcode.
    static let baseURL = URL(string: "https://raa-api.pollak.workers.dev")!

    /// POST — Anthropic Messages API (bird chat + sketch validation).
    static var chatURL: URL { baseURL.appendingPathComponent("chat") }

    /// GET — Wolfram Alpha Full Results (XML), used by chemical/scientific lookups.
    static func wolframQueryURL(input: String) -> URL? {
        var components = URLComponents(url: baseURL.appendingPathComponent("wolfram/query"),
                                       resolvingAgainstBaseURL: false)
        components?.queryItems = [URLQueryItem(name: "input", value: input)]
        return components?.url
    }

    /// GET — Wolfram Alpha Short Answer (plaintext).
    static func wolframResultURL(input: String) -> URL? {
        var components = URLComponents(url: baseURL.appendingPathComponent("wolfram/result"),
                                       resolvingAgainstBaseURL: false)
        components?.queryItems = [URLQueryItem(name: "input", value: input)]
        return components?.url
    }

    /// POST — ElevenLabs Text-to-Speech for the given voice ID. Returns audio/mpeg.
    /// Premium-tier feature; the iOS playback service is wired in a separate session.
    static func ttsURL(voiceID: String) -> URL {
        baseURL.appendingPathComponent("tts/\(voiceID)")
    }

    /// Shared-secret header that the Worker checks. Stored in APIKeys.swift
    /// (gitignored) so it doesn't end up in screenshots or commits.
    static var proxyToken: String { APIKeys.proxyToken }

    /// True once the proxy token has been pasted into APIKeys.swift.
    /// Use this to short-circuit network calls before they hit the wire.
    static var isConfigured: Bool {
        !proxyToken.isEmpty && proxyToken != "PASTE_YOUR_HEX_TOKEN_HERE"
    }
}
