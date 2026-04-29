// Renaissance Architect Academy API — Cloudflare Worker
//
// Secure proxy between the iOS app and external APIs (Anthropic Claude,
// Wolfram Alpha, ElevenLabs TTS). API keys live here as server-side
// secrets — they never ship in the iOS app binary.
//
// Endpoints:
//   GET  /health          → smoke test, no auth
//   POST /chat            → proxies to Anthropic Messages API (bird chat + sketch validation)
//   GET  /wolfram/query   → proxies to Wolfram Alpha Full Results API (XML)
//   GET  /wolfram/result  → proxies to Wolfram Alpha Short Answer API (plaintext)
//   POST /tts/:voiceId    → proxies to ElevenLabs Text-to-Speech (returns audio/mpeg)
//
// Auth: all non-/health routes require X-Proxy-Token header. This is a
// shared-secret speed bump. Phase 3 of the migration replaces it with
// Apple App Attest for cryptographic proof the request came from our app.

export interface Env {
  PROXY_TOKEN: string;
  ANTHROPIC_API_KEY: string;
  WOLFRAM_APP_ID: string;
  ELEVENLABS_API_KEY: string;
}

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const url = new URL(request.url);

    if (url.pathname === "/health") {
      return json({
        status: "ok",
        worker: "raa-api",
        time: new Date().toISOString(),
      });
    }

    const authError = checkProxyToken(request, env);
    if (authError) return authError;

    if (url.pathname === "/chat" && request.method === "POST") {
      return handleChat(request, env);
    }

    if (url.pathname === "/wolfram/query" && request.method === "GET") {
      return handleWolframQuery(url, env);
    }

    if (url.pathname === "/wolfram/result" && request.method === "GET") {
      return handleWolframResult(url, env);
    }

    if (url.pathname.startsWith("/tts/") && request.method === "POST") {
      const voiceId = url.pathname.slice("/tts/".length);
      return handleTTS(voiceId, request, env);
    }

    return json({ error: "not_found", path: url.pathname }, 404);
  },
};

// MARK: - Auth

function checkProxyToken(request: Request, env: Env): Response | null {
  const token = request.headers.get("X-Proxy-Token");
  if (!token || token !== env.PROXY_TOKEN) {
    return json({ error: "unauthorized" }, 401);
  }
  return null;
}

// MARK: - /chat → Anthropic

async function handleChat(request: Request, env: Env): Promise<Response> {
  if (!env.ANTHROPIC_API_KEY) {
    return json({ error: "anthropic_key_not_configured" }, 500);
  }

  let body: unknown;
  try {
    body = await request.json();
  } catch {
    return json({ error: "invalid_json" }, 400);
  }

  const upstream = await fetch("https://api.anthropic.com/v1/messages", {
    method: "POST",
    headers: {
      "content-type": "application/json",
      "x-api-key": env.ANTHROPIC_API_KEY,
      "anthropic-version": "2023-06-01",
    },
    body: JSON.stringify(body),
  });

  // Pass the response through as-is so the iOS client can keep its existing
  // Anthropic response parser.
  return new Response(upstream.body, {
    status: upstream.status,
    headers: { "content-type": "application/json" },
  });
}

// MARK: - /wolfram/query → Wolfram Alpha Full Results (XML)

async function handleWolframQuery(url: URL, env: Env): Promise<Response> {
  if (!env.WOLFRAM_APP_ID) {
    return json({ error: "wolfram_key_not_configured" }, 500);
  }

  const input = url.searchParams.get("input");
  if (!input) {
    return json({ error: "missing_input" }, 400);
  }

  const encoded = encodeURIComponent(input);
  const upstreamURL =
    `https://api.wolframalpha.com/v2/query?input=${encoded}` +
    `&appid=${env.WOLFRAM_APP_ID}&format=plaintext,image`;

  const upstream = await fetch(upstreamURL);

  // Wolfram Full Results returns XML; preserve content-type so the iOS
  // XML parser sees the same shape it would from a direct call.
  const contentType = upstream.headers.get("content-type") ?? "application/xml";
  return new Response(upstream.body, {
    status: upstream.status,
    headers: { "content-type": contentType },
  });
}

// MARK: - /wolfram/result → Wolfram Alpha Short Answer (plaintext)

async function handleWolframResult(url: URL, env: Env): Promise<Response> {
  if (!env.WOLFRAM_APP_ID) {
    return json({ error: "wolfram_key_not_configured" }, 500);
  }

  const input = url.searchParams.get("input");
  if (!input) {
    return json({ error: "missing_input" }, 400);
  }

  const encoded = encodeURIComponent(input);
  const upstreamURL =
    `https://api.wolframalpha.com/v1/result?i=${encoded}&appid=${env.WOLFRAM_APP_ID}`;

  const upstream = await fetch(upstreamURL);

  // Short Answer returns plain text/plain.
  const contentType = upstream.headers.get("content-type") ?? "text/plain";
  return new Response(upstream.body, {
    status: upstream.status,
    headers: { "content-type": contentType },
  });
}

// MARK: - /tts/:voiceId → ElevenLabs Text-to-Speech

async function handleTTS(voiceId: string, request: Request, env: Env): Promise<Response> {
  if (!env.ELEVENLABS_API_KEY) {
    return json({ error: "elevenlabs_key_not_configured" }, 500);
  }

  // ElevenLabs voice IDs are alphanumeric. Reject anything else so we
  // can't be tricked into issuing requests against arbitrary upstream paths.
  if (!/^[A-Za-z0-9]+$/.test(voiceId)) {
    return json({ error: "invalid_voice_id" }, 400);
  }

  const bodyText = await request.text();

  const upstream = await fetch(`https://api.elevenlabs.io/v1/text-to-speech/${voiceId}`, {
    method: "POST",
    headers: {
      "content-type": "application/json",
      "xi-api-key": env.ELEVENLABS_API_KEY,
      "accept": "audio/mpeg",
    },
    body: bodyText,
  });

  // Forward audio bytes (or JSON error) with upstream's content-type so
  // the iOS client sees the same response shape as a direct ElevenLabs call.
  const contentType = upstream.headers.get("content-type") ?? "application/octet-stream";
  return new Response(upstream.body, {
    status: upstream.status,
    headers: { "content-type": contentType },
  });
}

// MARK: - Helpers

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "content-type": "application/json" },
  });
}
