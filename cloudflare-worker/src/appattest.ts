// App Attest verification — server-side.
//
// Implements Apple's App Attest verification flow for both:
//   - Attestation (one-time per install) — proves a key was generated on
//     genuine Apple hardware running our bundle ID.
//   - Assertion (per-request) — proves the request was signed by that key.
//
// Reference: https://developer.apple.com/documentation/devicecheck/establishing_your_app_s_integrity
//
// The cryptographic guarantee: only a real iPhone/iPad running our app with
// our bundle ID + team ID can produce valid assertions. Anyone extracting
// the proxy token from the IPA cannot bypass this.

import { decode as cborDecode } from "cbor-x";
import { X509Certificate, X509ChainBuilder } from "@peculiar/x509";

// Apple App Attest Root CA — public certificate.
// Source: https://www.apple.com/certificateauthority/Apple_App_Attestation_Root_CA.pem
// Pinned in source so we don't trust any other root for App Attest chains.
const APPLE_APP_ATTEST_ROOT_CA_PEM = `-----BEGIN CERTIFICATE-----
MIICITCCAaegAwIBAgIQC/O+DvHN0uD7jG5yH2IXmDAKBggqhkjOPQQDAzBSMSYw
JAYDVQQDDB1BcHBsZSBBcHAgQXR0ZXN0YXRpb24gUm9vdCBDQTETMBEGA1UECgwK
QXBwbGUgSW5jLjETMBEGA1UECAwKQ2FsaWZvcm5pYTAeFw0yMDAzMTgxODMyNTNa
Fw00NTAzMTUwMDAwMDBaMFIxJjAkBgNVBAMMHUFwcGxlIEFwcCBBdHRlc3RhdGlv
biBSb290IENBMRMwEQYDVQQKDApBcHBsZSBJbmMuMRMwEQYDVQQIDApDYWxpZm9y
bmlhMHYwEAYHKoZIzj0CAQYFK4EEACIDYgAERTHhmLW07ATaFQIEVwTtT4dyctdh
NbJhFs/Ii2FdCgAHGbpphY3+d8qjuDngIN3WVhQUBHAoMeQ/cLiP1sOUtgjqK9au
Yen1mMEvRq9Sk3Jm5X8U62H+xTD3FE9TgS41o0IwQDAPBgNVHRMBAf8EBTADAQH/
MB0GA1UdDgQWBBSskRBTM72+aEH/pwyp5frq5eWKoTAOBgNVHQ8BAf8EBAMCAQYw
CgYIKoZIzj0EAwMDaAAwZQIwQgFGnByvsiVbpTKwSga0kP0e8EeDS4+sQmTvb7vn
53O5+FRXgeLhpJ06ysC5PrOyAjEAp5U4xDgEgllF7En3VcE3iexZZtKeYnpqtijV
oyFraWVIyd/dganmrduC1bmTBGwD
-----END CERTIFICATE-----`;

// App ID hash: SHA256("TEAMID.bundle.id") — embedded in every authData.
// Team M84U73M2CT + bundle com.marinapollak.RenaissanceArchitectAcademy.
const EXPECTED_APP_ID = "M84U73M2CT.com.marinapollak.RenaissanceArchitectAcademy";

// AAGUID values Apple uses to mark App Attest authenticator data.
// "appattest\0\0\0\0\0\0\0" for production, "appattestdevelop" for dev builds.
const AAGUID_PROD = new Uint8Array([
  0x61, 0x70, 0x70, 0x61, 0x74, 0x74, 0x65, 0x73,
  0x74, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
]);
const AAGUID_DEV = new Uint8Array([
  0x61, 0x70, 0x70, 0x61, 0x74, 0x74, 0x65, 0x73,
  0x74, 0x64, 0x65, 0x76, 0x65, 0x6c, 0x6f, 0x70,
]);

export interface StoredKey {
  publicKeyJwk: JsonWebKey;
  counter: number;
}

// ---------- Public API ----------

/// Verify an attestation object from `DCAppAttestService.attestKey(_:clientDataHash:)`
/// and return the public key + initial counter to store in KV.
/// Throws on any verification failure — caller should respond 401.
export async function verifyAttestation(args: {
  attestationCBOR: Uint8Array;
  expectedNonce: Uint8Array;
  keyId: Uint8Array;
}): Promise<StoredKey> {
  const { attestationCBOR, expectedNonce, keyId } = args;

  // 1. Decode CBOR. Expected shape:
  //    { fmt: "apple-appattest", attStmt: { x5c: [Buffer, Buffer], receipt: Buffer }, authData: Buffer }
  const att = cborDecode(attestationCBOR) as {
    fmt: string;
    attStmt: { x5c: Uint8Array[]; receipt?: Uint8Array };
    authData: Uint8Array;
  };

  if (att.fmt !== "apple-appattest") {
    throw new Error("attestation_unsupported_format");
  }
  if (!Array.isArray(att.attStmt?.x5c) || att.attStmt.x5c.length < 1) {
    throw new Error("attestation_missing_x5c");
  }
  if (!(att.authData instanceof Uint8Array)) {
    throw new Error("attestation_missing_authdata");
  }

  // 2. Parse cert chain. Leaf = credCert, then intermediates, then we add Apple root.
  const certs = att.attStmt.x5c.map((der) => new X509Certificate(new Uint8Array(der)));
  const credCert = certs[0];
  const appleRoot = new X509Certificate(APPLE_APP_ATTEST_ROOT_CA_PEM);

  // 3. Verify the chain leaf → intermediates → Apple App Attest root.
  const chain = new X509ChainBuilder({
    certificates: [...certs.slice(1), appleRoot],
  });
  const builtChain = await chain.build(credCert);
  // Must end with the Apple root we pinned (not just any cert named the same).
  // Compare SHA256 hashes of the raw DER bytes — library-independent.
  const rootInBuiltChain = builtChain[builtChain.length - 1];
  const rootBuiltHash = await sha256(new Uint8Array(rootInBuiltChain.rawData));
  const appleRootHash = await sha256(new Uint8Array(appleRoot.rawData));
  if (!bytesEqual(rootBuiltHash, appleRootHash)) {
    throw new Error("attestation_chain_not_apple_root");
  }
  // Validate each link's signature.
  for (let i = 0; i < builtChain.length - 1; i++) {
    const cert = builtChain[i];
    const issuer = builtChain[i + 1];
    const ok = await cert.verify({ publicKey: issuer.publicKey, signatureOnly: true });
    if (!ok) throw new Error(`attestation_chain_invalid_at_${i}`);
  }

  // 4. Verify nonce: SHA256(authData || clientDataHash) must match the nonce
  // embedded in credCert's OID 1.2.840.113635.100.8.2 extension.
  // Per Apple docs: extension value is DER: SEQUENCE { [1] SEQUENCE { OCTET STRING expected_nonce } }
  const clientDataHash = await sha256(expectedNonce);
  const composite = concatBytes(att.authData, clientDataHash);
  const expectedNonceHash = await sha256(composite);

  const nonceExtension = findCertExtension(credCert, "1.2.840.113635.100.8.2");
  if (!nonceExtension) {
    throw new Error("attestation_missing_nonce_extension");
  }
  const credCertNonce = extractNonceFromExtension(nonceExtension);
  if (!bytesEqual(credCertNonce, expectedNonceHash)) {
    throw new Error("attestation_nonce_mismatch");
  }

  // 5. Verify keyId === SHA256(credCert.publicKey)
  const credPubKeySpki = new Uint8Array(credCert.publicKey.rawData);
  // Apple wants SHA256 over the EC point bytes only (uncompressed 0x04 || X || Y),
  // which we can extract from the SPKI by skipping the algorithm header.
  // Use a robust method: import the key, export as raw EC point.
  const ecPubKey = await crypto.subtle.importKey(
    "spki",
    credPubKeySpki.buffer.slice(credPubKeySpki.byteOffset, credPubKeySpki.byteOffset + credPubKeySpki.byteLength) as ArrayBuffer,
    { name: "ECDSA", namedCurve: "P-256" },
    true,
    ["verify"],
  );
  const ecPubKeyRaw = new Uint8Array(await crypto.subtle.exportKey("raw", ecPubKey));
  const computedKeyId = await sha256(ecPubKeyRaw);
  if (!bytesEqual(computedKeyId, keyId)) {
    throw new Error("attestation_keyid_mismatch");
  }

  // 6. Parse authData and verify:
  //    - rpIdHash == SHA256(appID)
  //    - counter == 0
  //    - aaguid is appattest or appattestdevelop
  //    - credentialId matches keyId
  const parsed = parseAuthData(att.authData);
  const expectedRpIdHash = await sha256(new TextEncoder().encode(EXPECTED_APP_ID));
  if (!bytesEqual(parsed.rpIdHash, expectedRpIdHash)) {
    throw new Error("attestation_rpid_mismatch");
  }
  if (parsed.counter !== 0) {
    throw new Error("attestation_counter_not_zero");
  }
  if (
    !bytesEqual(parsed.aaguid, AAGUID_PROD) &&
    !bytesEqual(parsed.aaguid, AAGUID_DEV)
  ) {
    throw new Error("attestation_aaguid_invalid");
  }
  if (!parsed.credentialId || !bytesEqual(parsed.credentialId, keyId)) {
    throw new Error("attestation_credential_id_mismatch");
  }

  // 7. Success — return the pubkey (JWK form, easier to store + re-import)
  const jwk = await crypto.subtle.exportKey("jwk", ecPubKey);
  return { publicKeyJwk: jwk, counter: 0 };
}

/// Verify a per-request assertion (`DCAppAttestService.generateAssertion`).
/// Returns the new counter to write back to KV. Throws on any failure.
export async function verifyAssertion(args: {
  assertionCBOR: Uint8Array;
  nonce: Uint8Array;
  storedKey: StoredKey;
}): Promise<{ newCounter: number }> {
  const { assertionCBOR, nonce, storedKey } = args;

  // 1. Decode CBOR: { signature, authenticatorData }
  const ass = cborDecode(assertionCBOR) as {
    signature: Uint8Array;
    authenticatorData: Uint8Array;
  };
  if (!(ass.signature instanceof Uint8Array) || !(ass.authenticatorData instanceof Uint8Array)) {
    throw new Error("assertion_invalid_cbor");
  }

  // 2. clientDataHash = SHA256(nonce). We use the nonce as the full clientData
  // (Apple lets you decide what clientData is — we keep it simple and per-request
  // by issuing a unique nonce each time, single-use, short TTL).
  const clientDataHash = await sha256(nonce);

  // 3. Reconstruct signed message: authenticatorData || clientDataHash
  const signedBytes = concatBytes(ass.authenticatorData, clientDataHash);

  // 4. Verify ECDSA P-256 signature against stored public key
  const pubKey = await crypto.subtle.importKey(
    "jwk",
    storedKey.publicKeyJwk,
    { name: "ECDSA", namedCurve: "P-256" },
    false,
    ["verify"],
  );
  // App Attest signatures are DER-encoded — WebCrypto expects raw r||s.
  const rawSig = derSignatureToRaw(ass.signature);
  const ok = await crypto.subtle.verify(
    { name: "ECDSA", hash: "SHA-256" },
    pubKey,
    rawSig,
    signedBytes,
  );
  if (!ok) throw new Error("assertion_signature_invalid");

  // 5. Verify authData rpIdHash + counter strictly increasing.
  const parsed = parseAuthData(ass.authenticatorData);
  const expectedRpIdHash = await sha256(new TextEncoder().encode(EXPECTED_APP_ID));
  if (!bytesEqual(parsed.rpIdHash, expectedRpIdHash)) {
    throw new Error("assertion_rpid_mismatch");
  }
  if (parsed.counter <= storedKey.counter) {
    throw new Error("assertion_counter_replay");
  }

  return { newCounter: parsed.counter };
}

// ---------- Helpers ----------

async function sha256(data: Uint8Array): Promise<Uint8Array> {
  const buf = await crypto.subtle.digest("SHA-256", data);
  return new Uint8Array(buf);
}

function concatBytes(...arrays: Uint8Array[]): Uint8Array {
  const total = arrays.reduce((s, a) => s + a.length, 0);
  const out = new Uint8Array(total);
  let offset = 0;
  for (const a of arrays) {
    out.set(a, offset);
    offset += a.length;
  }
  return out;
}

function bytesEqual(a: Uint8Array, b: Uint8Array): boolean {
  if (a.length !== b.length) return false;
  let diff = 0;
  for (let i = 0; i < a.length; i++) diff |= a[i] ^ b[i];
  return diff === 0;
}

interface ParsedAuthData {
  rpIdHash: Uint8Array;          // 32 bytes
  flags: number;                 // 1 byte
  counter: number;               // 4 bytes BE
  aaguid: Uint8Array | null;     // 16 bytes, only if AT flag set
  credentialId: Uint8Array | null;
}

function parseAuthData(authData: Uint8Array): ParsedAuthData {
  if (authData.length < 37) throw new Error("authdata_too_short");
  const rpIdHash = authData.slice(0, 32);
  const flags = authData[32];
  const counter =
    (authData[33] << 24) |
    (authData[34] << 16) |
    (authData[35] << 8) |
    authData[36];
  const out: ParsedAuthData = { rpIdHash, flags, counter, aaguid: null, credentialId: null };
  // AT flag (attested credential data present) = bit 6 (0x40)
  if (flags & 0x40) {
    if (authData.length < 55) throw new Error("authdata_attested_short");
    out.aaguid = authData.slice(37, 53);
    const credIdLen = (authData[53] << 8) | authData[54];
    if (authData.length < 55 + credIdLen) throw new Error("authdata_credid_short");
    out.credentialId = authData.slice(55, 55 + credIdLen);
  }
  return out;
}

function findCertExtension(cert: X509Certificate, oid: string): Uint8Array | null {
  const ext = cert.extensions.find((e) => e.type === oid);
  if (!ext) return null;
  return new Uint8Array(ext.value);
}

/// Apple wraps the nonce hash in: SEQUENCE { [1] OCTET STRING value }
/// Parse the OCTET STRING bytes. (Note: earlier draft expected an extra
/// SEQUENCE level — that was wrong per Apple's actual encoding.)
function extractNonceFromExtension(extValue: Uint8Array): Uint8Array {
  // Walk DER: 0x30 (SEQUENCE) -> 0xA1 (context [1]) -> 0x04 (OCTET STRING)
  let p = 0;
  if (extValue[p++] !== 0x30) throw new Error("ext_not_sequence");
  p += derLengthSkip(extValue, p - 1);
  if (extValue[p++] !== 0xa1) throw new Error("ext_not_context1");
  p += derLengthSkip(extValue, p - 1);
  if (extValue[p++] !== 0x04) throw new Error("ext_not_octet_string");
  const { length, headerLen } = derLength(extValue, p - 1);
  return extValue.slice(p - 1 + headerLen, p - 1 + headerLen + length);
}

function derLength(buf: Uint8Array, tagIndex: number): { length: number; headerLen: number } {
  const first = buf[tagIndex + 1];
  if (first < 0x80) return { length: first, headerLen: 2 };
  const numOctets = first & 0x7f;
  let length = 0;
  for (let i = 0; i < numOctets; i++) length = (length << 8) | buf[tagIndex + 2 + i];
  return { length, headerLen: 2 + numOctets };
}

function derLengthSkip(buf: Uint8Array, tagIndex: number): number {
  // Return additional bytes to skip past the length field (header length minus the tag byte we already consumed)
  const { headerLen } = derLength(buf, tagIndex);
  return headerLen - 1; // we already moved past tag; skip the length bytes
}

/// Convert DER-encoded ECDSA signature (SEQUENCE { INTEGER r, INTEGER s }) to
/// the raw r||s form WebCrypto expects (64 bytes for P-256).
function derSignatureToRaw(der: Uint8Array): Uint8Array {
  // 0x30 SEQUENCE
  if (der[0] !== 0x30) throw new Error("sig_not_sequence");
  let p = 2;
  if (der[1] & 0x80) p = 2 + (der[1] & 0x7f);
  // 0x02 INTEGER r
  if (der[p++] !== 0x02) throw new Error("sig_r_not_integer");
  const rLen = der[p++];
  let r = der.slice(p, p + rLen);
  p += rLen;
  // 0x02 INTEGER s
  if (der[p++] !== 0x02) throw new Error("sig_s_not_integer");
  const sLen = der[p++];
  let s = der.slice(p, p + sLen);
  // Strip leading 0x00 (DER negative padding) and left-pad to 32 bytes
  if (r.length > 32) r = r.slice(r.length - 32);
  if (s.length > 32) s = s.slice(s.length - 32);
  const padded = new Uint8Array(64);
  padded.set(r, 32 - r.length);
  padded.set(s, 64 - s.length);
  return padded;
}
