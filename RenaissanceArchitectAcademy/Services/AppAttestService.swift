//
//  AppAttestService.swift
//  RenaissanceArchitectAcademy
//
//  Wraps Apple's DeviceCheck App Attest framework so the iOS app can
//  cryptographically prove to the Cloudflare Worker that requests come
//  from genuine Apple hardware running this bundle.
//
//  Flow (per-install):
//    1. Generate an App Attest key (one-time, persisted by ID in UserDefaults).
//    2. Fetch a nonce from the Worker /nonce route.
//    3. attestKey(keyId, clientDataHash: SHA256(nonce)) → CBOR attestation.
//    4. POST {keyId, nonce, attestation} to Worker /attest. Worker verifies the
//       Apple cert chain + nonce hash and stores the device's public key.
//    5. Mark "attested" in UserDefaults so we skip enrollment next launch.
//
//  Flow (per-request):
//    1. Fetch a fresh nonce from /nonce.
//    2. generateAssertion(keyId, clientDataHash: SHA256(nonce)) → CBOR assertion.
//    3. Attach X-Attest-KeyId / X-Attest-Nonce / X-Attest-Assertion headers.
//
//  Simulator: DCAppAttestService.isSupported returns false. We fall back to
//  the legacy X-Proxy-Token header so development workflows keep working.
//

import Foundation
import DeviceCheck
import CryptoKit

actor AppAttestService {

    static let shared = AppAttestService()

    private let service = DCAppAttestService.shared

    private enum Defaults {
        static let keyId = "raa.appattest.keyId"
        static let attested = "raa.appattest.attested"
    }

    // MARK: - Public API

    /// True when DeviceCheck is available on this device. False on Simulator,
    /// older iOS versions, and devices Apple has flagged. Caller should use
    /// the proxy-token fallback when this is false.
    nonisolated var isSupported: Bool {
        DCAppAttestService.shared.isSupported
    }

    /// Idempotent: returns the device's persisted keyId, attesting it with
    /// Apple + registering with the Worker the first time only.
    func ensureAttested() async throws -> String {
        let keyId = try await ensureKey()
        if UserDefaults.standard.bool(forKey: Defaults.attested) {
            return keyId
        }
        try await enroll(keyId: keyId)
        UserDefaults.standard.set(true, forKey: Defaults.attested)
        return keyId
    }

    /// Wipe local enrollment state. Next ensureAttested() call will generate
    /// a new key and re-enroll. Use when the Worker reports `attest_key_unknown`
    /// (server-side KV wipe, encoding mismatch, etc.) or in a debug menu.
    func resetLocalEnrollment() {
        UserDefaults.standard.removeObject(forKey: Defaults.keyId)
        UserDefaults.standard.removeObject(forKey: Defaults.attested)
    }

    /// Generate the X-Attest-* headers to attach to an outgoing API request.
    /// Returns (keyId, nonce, assertion) all base64url-encoded.
    /// Caller is responsible for setting them on the URLRequest.
    func attestationHeaders() async throws -> (keyId: String, nonce: String, assertion: String) {
        let keyId = try await ensureAttested()
        let nonce = try await fetchNonce()
        let clientDataHash = Data(SHA256.hash(data: Data(base64URLEncoded: nonce) ?? Data()))
        let assertion = try await service.generateAssertion(keyId, clientDataHash: clientDataHash)
        return (keyId: keyId, nonce: nonce, assertion: assertion.base64URLEncodedString())
    }

    // MARK: - Internal flow

    private func ensureKey() async throws -> String {
        if let existing = UserDefaults.standard.string(forKey: Defaults.keyId) {
            return existing
        }
        let keyId = try await service.generateKey()
        UserDefaults.standard.set(keyId, forKey: Defaults.keyId)
        return keyId
    }

    private func enroll(keyId: String) async throws {
        let nonce = try await fetchNonce()
        let nonceBytes = Data(base64URLEncoded: nonce) ?? Data()
        let clientDataHash = Data(SHA256.hash(data: nonceBytes))
        let attestation = try await service.attestKey(keyId, clientDataHash: clientDataHash)

        // Send Apple's keyId VERBATIM in both /attest body and X-Attest-KeyId
        // header. Re-encoding to base64url here would create a different string
        // than the header sends later → Worker's KV lookup misses → 401.
        let body: [String: String] = [
            "keyId": keyId,
            "nonce": nonce,
            "attestation": attestation.base64URLEncodedString(),
        ]
        var request = URLRequest(url: WorkerClient.attestURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw AppAttestError.networkError("no_http_response")
        }
        // 409 = key already registered (e.g. re-attesting after a token reset
        // wiped local UserDefaults). Treat as success — the Worker still has
        // our pubkey, we just need to mark local state caught up.
        if http.statusCode == 200 || http.statusCode == 409 {
            return
        }
        let detail = String(data: data, encoding: .utf8) ?? "<no body>"
        throw AppAttestError.attestationRejected(status: http.statusCode, detail: detail)
    }

    private func fetchNonce() async throws -> String {
        var request = URLRequest(url: WorkerClient.nonceURL)
        request.httpMethod = "GET"
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw AppAttestError.networkError("nonce_failed")
        }
        struct NonceResponse: Decodable { let nonce: String }
        let decoded = try JSONDecoder().decode(NonceResponse.self, from: data)
        return decoded.nonce
    }
}

// MARK: - Errors

enum AppAttestError: Error, LocalizedError {
    case networkError(String)
    case attestationRejected(status: Int, detail: String)

    var errorDescription: String? {
        switch self {
        case .networkError(let msg):
            return "App Attest network error: \(msg)"
        case .attestationRejected(let status, let detail):
            return "App Attest rejected (HTTP \(status)): \(detail)"
        }
    }
}

// MARK: - Base64URL helpers (Apple uses base64, Worker uses base64url — convert)

private extension Data {
    init?(base64URLEncoded string: String) {
        let normalized = string
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let padded = normalized + String(repeating: "=", count: (4 - normalized.count % 4) % 4)
        self.init(base64Encoded: padded)
    }

    func base64URLEncodedString() -> String {
        base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
