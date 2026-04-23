# API Integration Plan — Renaissance Architect Academy

## Context

This doc was originally written as a 5-phase roadmap for integrating external
APIs. Since then, Phases 1–4 have largely shipped, `KnowledgeCardsOverlay`
has been wired into all four game environments, and the system has grown
past the original plan (Apple Intelligence path, on-device NPC generation,
Wolfram geometry slider, Met Museum sketch study). The plan has been
refined (Apr 23, 2026) to reflect what's actually in the repo and to
narrow the remaining work to a short, concrete backlog.

**Scope of this document**: track external-API integrations only. Gameplay
work lives in `CLAUDE.md`'s "Next Steps".

---

## Current Status

| Proposed | Actual shipped file | Notes |
|---|---|---|
| `ClaudeService.swift` | [`Services/ClaudeService.swift`](RenaissanceArchitectAcademy/Services/ClaudeService.swift) | Direct-to-Anthropic (no proxy yet — see P0) |
| `APIConfiguration.swift` | `Services/APIKeys.swift` (gitignored) | Renamed |
| `BirdChatOverlay.swift` | [`Views/BirdChatOverlay.swift`](RenaissanceArchitectAcademy/Views/BirdChatOverlay.swift) | |
| `ChatMessage.swift` | [`Models/ChatMessage.swift`](RenaissanceArchitectAcademy/Models/ChatMessage.swift) | |
| `PubChemService.swift` | [`Services/PubChemService.swift`](RenaissanceArchitectAcademy/Services/PubChemService.swift) | Swift `actor`, in-memory cache |
| `MoleculeData.swift` | merged into `PubChemService.swift` | |
| `RenaissanceMoleculeView` | [`Views/PubChemMoleculeView.swift`](RenaissanceArchitectAcademy/Views/PubChemMoleculeView.swift) | Uses CPK coloring, not the originally-proposed Renaissance palette |
| `ReactionAnimationView` | — not built — | See P1 |
| `CachedMolecules.json` | [`Models/StationCompounds.swift`](RenaissanceArchitectAcademy/Models/StationCompounds.swift) | In-code, per-station |
| `MetMuseumService.swift` | [`ViewModels/MuseumSketchService.swift`](RenaissanceArchitectAcademy/ViewModels/MuseumSketchService.swift) | Pivoted from "See the Real Thing" to the sketch-study mini-game |
| `RealWorldArtOverlay.swift` | [`Views/SketchStudyOverlay.swift`](RenaissanceArchitectAcademy/Views/SketchStudyOverlay.swift) | |
| `CachedArtwork.json` | [`Models/MuseumSketch.swift`](RenaissanceArchitectAcademy/Models/MuseumSketch.swift) | In-code, per-building |
| `WolframService.swift` | [`Services/WolframService.swift`](RenaissanceArchitectAcademy/Services/WolframService.swift) + [`WolframGeometryHelper.swift`](RenaissanceArchitectAcademy/Services/WolframGeometryHelper.swift) | Live query + cached geometry |
| `CachedComputations.json` | in-code in `WolframGeometryHelper` | |
| `RenaissanceGraphView` | — not built — | See P2 |
| `KnowledgeCardsOverlay` wired to all 4 envs | [`Views/KnowledgeCardsOverlay.swift`](RenaissanceArchitectAcademy/Views/KnowledgeCardsOverlay.swift) in `ForestMapView`, `WorkshopMapView`, `CraftingRoomMapView`, `CityMapView` | |

**Beyond the original plan**, the codebase also added:

- [`Services/AIService.swift`](RenaissanceArchitectAcademy/Services/AIService.swift) protocol + [`AppleAIService.swift`](RenaissanceArchitectAcademy/Services/AppleAIService.swift) (iOS 26 Foundation Models, autonomous tool calling) + [`MockAIService.swift`](RenaissanceArchitectAcademy/Services/MockAIService.swift)
- [`Views/AIProviderPickerView.swift`](RenaissanceArchitectAcademy/Views/AIProviderPickerView.swift) + `GameSettings.aiProvider`
- [`Services/GenerationService.swift`](RenaissanceArchitectAcademy/Services/GenerationService.swift) — session pool + prewarm
- [`Services/NPCEncounterManager.swift`](RenaissanceArchitectAcademy/Services/NPCEncounterManager.swift) — per-station NPC generation + disk cache
- [`Services/GameTools.swift`](RenaissanceArchitectAcademy/Services/GameTools.swift) — inventory/progress/calendar tools for `AppleAIService`

---

## Architecture (actual)

### Bird chat

```
BirdChatOverlay
      │
      ▼
 AIService (protocol)        ──► MockAIService       (canned replies, dev)
      ├──► AppleAIService    (iOS 26 Foundation Models + tools)
      └──► ClaudeService     (Haiku 4.5, direct-to-Anthropic)
```

Provider chosen once in `AIProviderPickerView`, persisted in
`GameSettings.aiProvider`. `AppleAIService.supportsTools == true` — the model
can call `GameTools` autonomously (building progress, inventory, calendar).
`ClaudeService` is text-only for now.

### Chemistry (PubChem)

```
QuarryMiniGameView / (future) ReactionAnimationView
      │
      ▼
 PubChemService (actor, in-memory cache)
      │ HTTPS
      ▼
 https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/name/{name}/record/JSON
```

Per-station compound lists live in `StationCompounds.swift`. No API key.

### Met Museum (sketch study)

```
SketchTeachingView / SketchStudyOverlay
      │
      ▼
 MuseumSketchService (URLCache + disk cache, per-building images)
      │ HTTPS
      ▼
 https://images.metmuseum.org/…
```

Curated Met object IDs are bundled in `MuseumSketch.swift`. No search call
at runtime — the app ships with the IDs it needs. No API key.

### Wolfram Alpha

```
WolframGeometryView (slider)
      │
      ├──► WolframGeometryHelper (cached defaults for all shipped buildings)
      └──► WolframService (Full Results XML)  ← key in APIKeys.swift
```

`WolframGeometryHelper` covers the default slider position so first-frame
render is offline. Live calls only fire when the player drags the slider.

---

## Backlog

### P0 — Secure the Claude API key behind a backend proxy

Today `ClaudeService.callClaudeAPI` reads `APIKeys.claude` and calls
`api.anthropic.com` directly with `x-api-key`. `APIKeys.swift` is gitignored,
but once the app ships to TestFlight or the App Store, the key is embedded
in the binary and extractable. That's fine for the Columbia class build;
it's not fine for public distribution.

**Shape**: a Cloudflare Worker (free tier) that receives `POST /bird-chat`,
forwards to Anthropic with the real key, returns the response unchanged. The
app sends the same JSON body it sends today; only the URL and auth header
change.

**Request shape the worker must accept** (identical to current Anthropic
body so the migration is small):

```json
{
  "model": "claude-haiku-4-5-20251001",
  "max_tokens": 300,
  "system": "<BirdContext.systemPrompt>",
  "messages": [{"role": "user", "content": "..."}]
}
```

**Auth**: per-install token (generated on first launch, stored in Keychain).
Worker validates the token against a KV allowlist. This also gives us the
P3 rate-limiting primitive for free.

**iOS changes**:
- `Services/ClaudeService.swift` — swap `apiURL` to the Worker URL; drop the
  `x-api-key` and `anthropic-version` headers; add `Authorization: Bearer <token>`.
- `Services/APIKeys.swift` — remove `claude`; keep `wolfram` (still direct).
- New token provisioning on app launch (one-time, stored via Keychain).

**Worker changes** (outside the iOS project):
- New `backend/cloudflare-worker/worker.js` at repo root.
- Secrets: `ANTHROPIC_API_KEY` in Worker env.

**Cost today**: ~$5/mo at 100 Columbia students. Keep that note only.

### P1 — Chemistry reactions at workbench crafting

The one Phase-2 promise that never shipped. `PubChemMoleculeView` already
fades in through cracks in `QuarryMiniGameView`, but there's no "lime +
water → Ca(OH)₂" animation after a workbench mix. This is the visible
payoff for having PubChem data at all, and it's the moment where chemistry
stops being a list of ingredients and starts being a reaction.

**Shape**: new `Views/ReactionAnimationView.swift` that takes N reactant
`PubChemMolecule`s and one product, animates reactants drifting together →
bonds reforming → product pulse + gold flash. Bird narrates each phase.
Triggered from `CraftingRoomScene`/`CraftingRoomMapView` after the workbench
`Mix` action completes, before the existing educational popup.

**Files to change**:
- New: `Views/ReactionAnimationView.swift` (SwiftUI, reuses `PubChemMoleculeView`).
- `Models/Recipe.swift` — add optional `reactionCompounds: (reactants: [String], product: String)`.
- `Views/SpriteKit/CraftingRoomMapView.swift` — present the new view after
  crafting completes (currently around line 136, alongside `KnowledgeCardsOverlay`).
- Reuse `PubChemService` + educational text from `StationCompounds.swift`.

### P2 — `RenaissanceGraphView`

Wolfram already computes values (`WolframGeometryHelper`) and shows diagrams
(`WolframGeometryView`), but there's no reusable curve/function graph in the
Renaissance aesthetic. A few challenges would benefit — Aqueduct gradient,
Duomo catenary, Flying Machine trajectory — but none of them are blocked on
it today.

**Shape**: SwiftUI `Views/RenaissanceGraphView.swift` — parchment background,
blueprint grid, sepia sampled `Path` for `(x) -> y` closures, Cinzel axis
labels. No new API. Builds on the patterns in `GradientSlopeVisual.swift`
and `FlowRateVisual.swift`.

Pull into the active sprint when a challenge calls for it; otherwise, leave
alone.

### P3 — Monitoring & per-user rate limits

Session-level cap already exists (`ClaudeService.maxMessagesPerSession = 6`),
but there's no daily cap and no visibility into spend. This folds into the
P0 worker: per-install token bucket (10 questions/day), log each call to a
cheap KV store for weekly review, return 429 on overflow. No iOS changes
beyond showing a friendly "come back tomorrow" message when the proxy
returns 429.

---

## Verification

- `git diff main -- ApiPlan.md` is the only non-trivial change in a
  refinement PR. No Swift files move.
- Every file path in the Current Status table resolves. Spot check with
  `ls <path>` after rebasing.
- When P0 ships: set `APIKeys.claude` to empty, run the app, send a bird
  question, confirm it still works (proxy path). Revoke the old Anthropic
  key afterwards.
- When P1 ships: craft `limeMortar` at the workbench; reaction plays once,
  bird narrates, florins award, `BuildingProgress.completedCardIDs` unchanged.
- When P3 ships: send 11 bird questions in one day on a fresh install;
  question 11 returns the friendly "come back tomorrow" message.

---

## Appendix — deprecated sections (kept for history)

The original plan also included:

- A cost-projection table for 1k / 10k students — superseded by the single
  "~$5/mo today" note under P0. Revisit when the app actually scales.
- A Renaissance-specific element color palette — superseded by CPK coloring
  in `PubChemMoleculeView.swift` (`ChemElement.color`). CPK is what every
  chemistry textbook uses; students should see the same colors here.
- A "Tomorrow's Session (Mar 10, 2026)" block — all three items shipped or
  moved into `CLAUDE.md`'s Next Steps (knowledge cards, book findings,
  molecule viewer).
- "Implementation Order / Sprint 1–4" — dated; work is past that.
