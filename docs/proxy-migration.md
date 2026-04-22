# Proxy Migration Plan — fal.ai

**Status:** Required before App Store submission. Scaffold is dev/TestFlight-only.

## The problem

`APIKeys.swift` currently holds a raw fal.ai key. The iOS app binary embeds that
string at compile time. Anyone with a Mac and ~10 minutes can use
`strings`/Hopper/Frida to extract it from a shipped `.ipa` and drain the account.

Apple's own App Store Review Guidelines (§5.1.1) also flag apps that ship with
third-party credentials visible in the binary.

**Bottom line:** the current setup works for Marina-only local dev and for
TestFlight internal builds. It **cannot** ship to the public App Store.

## The fix: Cloudflare Worker reverse proxy

A tiny serverless function sits between the app and fal.ai. The fal.ai key lives
as a secret on Cloudflare (never in the binary). The app hits our domain; the
Worker forwards to fal.ai; the response comes back through us.

Cloudflare Workers free tier allows 100k requests/day — more than enough.

### Architecture

```
iOS app  ──→  https://sketch.your-domain.com/render
                (no auth from the app itself — Worker validates instead)
                           │
                           ▼
              Cloudflare Worker
                (injects fal.ai key from secret store)
                           │
                           ▼
              https://queue.fal.run/fal-ai/flux-pro/kontext
```

### Worker code (`worker.js`)

```javascript
export default {
  async fetch(request, env) {
    // Allow only POST from our app
    if (request.method !== 'POST') {
      return new Response('Method not allowed', { status: 405 });
    }

    // Basic App Attest or token check — minimal acceptable:
    const appToken = request.headers.get('X-App-Token');
    if (appToken !== env.APP_SHARED_TOKEN) {
      return new Response('Unauthorized', { status: 401 });
    }

    const url = new URL(request.url);
    const path = url.pathname;  // /submit, /status/:id, /result/:id

    // Route to fal.ai
    let falURL;
    if (path === '/submit') {
      falURL = 'https://queue.fal.run/fal-ai/flux-pro/kontext';
    } else if (path.startsWith('/status/')) {
      const id = path.slice('/status/'.length);
      falURL = `https://queue.fal.run/fal-ai/flux-pro/kontext/requests/${id}/status`;
    } else if (path.startsWith('/result/')) {
      const id = path.slice('/result/'.length);
      falURL = `https://queue.fal.run/fal-ai/flux-pro/kontext/requests/${id}`;
    } else {
      return new Response('Not found', { status: 404 });
    }

    const upstream = await fetch(falURL, {
      method: path === '/submit' ? 'POST' : 'GET',
      headers: {
        'Authorization': `Key ${env.FAL_AI_KEY}`,
        'Content-Type': 'application/json'
      },
      body: path === '/submit' ? await request.text() : undefined
    });

    return new Response(upstream.body, {
      status: upstream.status,
      headers: upstream.headers
    });
  }
};
```

### Setup (one-time, ~2 hours)

1. Create Cloudflare account (free) → Workers & Pages → Create Worker
2. Paste `worker.js` above into the editor
3. Settings → Variables → Add secret:
   - `FAL_AI_KEY` = `<your fal.ai key>`
   - `APP_SHARED_TOKEN` = `<new random 32-char string>`
4. Assign a custom domain (e.g. `sketch.renaissancearchitect.app`) — free via
   Cloudflare if your domain is on their DNS
5. Deploy

### App-side changes

In `FalSketchService.swift`, change these three things:

```swift
// Before
private static let submitURL = URL(string: "https://queue.fal.run/fal-ai/flux-pro/kontext")!
private static let statusURLBase = "https://queue.fal.run/fal-ai/flux-pro/kontext/requests/"

// After (proxy)
private static let submitURL = URL(string: "https://sketch.renaissancearchitect.app/submit")!
private static let statusURLBase = "https://sketch.renaissancearchitect.app/status/"
// And add a parallel resultURLBase = "https://sketch.renaissancearchitect.app/result/"
```

And replace the `Authorization` header:

```swift
// Before
request.setValue("Key \(APIKeys.falAI)", forHTTPHeaderField: "Authorization")

// After
request.setValue(APIKeys.appSharedToken, forHTTPHeaderField: "X-App-Token")
```

Then in `APIKeys.swift`, delete `falAI`, add `appSharedToken` (the shared secret
you set in Cloudflare). The shared token is still extractable from the binary,
but it's a rotatable one-way gate to YOUR proxy — rotating it is a 5-minute
Cloudflare secret update, vs. a fal.ai account compromise.

## Stronger option (later): App Attest

For higher security, replace `X-App-Token` with Apple's App Attest:
https://developer.apple.com/documentation/devicecheck/establishing-your-app-s-integrity

The Worker validates an attestation before forwarding. Only real, unmodified
installs of your app can call the proxy. Takes ~half a day to wire up. Overkill
for TestFlight, worth doing for public release.

## What to do when

- **Now (local dev):** do nothing, use the scaffold as-is
- **TestFlight internal testers:** still fine, key is visible but exposure is
  limited to your 4 testers
- **Public TestFlight (external testers, link on social media, etc.):** ship the
  proxy before that point
- **App Store submission:** must have proxy; strongly recommend App Attest too
