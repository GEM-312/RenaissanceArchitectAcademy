# Narration Audio (Text-to-Speech) Design

**Author:** Marina Pollak — Renaissance Architect Academy
**Date:** 2026-04-22
**Target ship:** May 2026 App Store submission
**Status:** Design — no code yet

## 1. Goal

Let **subscribers** tap a Listen button on any reading surface (knowledge cards, fun facts, lesson paragraphs) and hear warm, human-quality narration. Non-subscribers see the button, tap it, get a 10-second preview then a paywall.

## 2. Provider Decision: ElevenLabs

| Provider | Quality | Latency | $/1M chars | Verdict |
|---|---|---|---|---|
| **ElevenLabs Flash v2.5** | Excellent (near-human) | ~75 ms TTFB | ~$0.15 (Creator plan eff.) | **Chosen.** Natural, expressive, 32 langs. |
| ElevenLabs Turbo v2.5 | Excellent | ~250 ms | ~$0.30 | Overkill once Flash exists. |
| ElevenLabs Multilingual v2 | Highest | ~1 s | ~$0.30 | Use for cached-forever production narration (best fidelity, latency doesn't matter when cached). |
| Apple AVSpeechSynthesizer | Robotic; flat prosody | 0 ms | Free | Fallback only. |
| OpenAI TTS (tts-1-hd) | Very good | ~400 ms | ~$30 | 200× more expensive. |
| Google WaveNet / Azure Neural | Good | ~300 ms | ~$16 | Less character than 11Labs. |

**Strategy:** generate once with **Multilingual v2** (best quality), cache the MP3 forever. Latency irrelevant after first generation — every student hears the cached file.

## 3. Voice Direction

Three voices mapped to three narrative roles. All pre-existing ElevenLabs library voices — no custom cloning needed.

| Role | Voice | ElevenLabs voice_id | Used for |
|---|---|---|---|
| **Il Maestro** (warm teacher, slight Italian lilt, mid-40s male) | **Giovanni** | `zcAOhNBS3c14rBihAFp1` | Lesson readings, knowledge-card `lessonText`, fun facts, curiosity Q&A |
| **The Apprentice Bird** (playful, light, youthful) | **Lily** | `pFZP5JQG7iQjIQuC4Bku` | Bird companion dialogue, station hints, sketching hints |
| **The Historian** (older, scholarly, British neutral) | **George** | `JBFqnCBsd6RMkjVDRZzb` | Historical context callouts (Phase 3: NPC Medici, Leonardo lines) |

**Rationale:** A warm slight-Italian-accented male teacher voice is on-theme (Renaissance Italy) without being cartoonish. A distinctly younger female voice for the bird preserves parasocial attachment from onboarding. Historical figures get a third voice to cue "this is a different speaker."

**Reject:** full Italian voice actors (comprehension cost for 10–16 yr olds) and any voice under ~25 perceived age (sounds like a child reading to a child → loses authority).

## 4. Content Scope

**Phase 1 (ship for May 2026):**
- `KnowledgeCard.lessonText` — 15 cards in KnowledgeCard.swift today, will grow to ~14/building × 17 = ~240 cards
- `KnowledgeCard.funFact`
- `LessonReading.body` across all 17 `LessonContent*.swift` files
- `LessonFunFact.text`
- `LessonCuriosity` Q&A answers

**Phase 2:**
- `LessonQuestion.explanation` (post-answer)
- Math visual captions
- NPC dialogue (Medici commissions, MascotDialogueView)

**Phase 3:**
- Bird companion hints in sketching + stations (Lily voice)
- Optional karaoke-style word highlighting
- Construction step descriptions

**Never narrate:** UI button labels, station mini-game instructions (too short), VoiceOver-handled accessibility text.

## 5. Cost Model

From `wc -c` on content files: ~312 KB of Swift code for lessons + cards. Stripping Swift boilerplate (roughly 60%), the actual narratable English prose is **~125 KB ≈ 125,000 characters** once Phase 1 content for all 17 buildings is authored.

- **One-time generation cost:** 125,000 chars × $0.30/1M (Multilingual v2) = **~$0.04 total**, round up to **$5** with regenerations + A/B voice tests.
- **Per-student runtime cost: $0.00.** Audio is cached in cloud R2 (or shipped in-bundle) — no ElevenLabs calls at student runtime.
- **Bundle impact if shipped in-app:** MP3 at 64 kbps mono ≈ 480 KB/minute of speech. 125k chars ≈ 150 min of speech = **~72 MB**. Acceptable for an iPad-first app; competitors ship 200+ MB.

**Recommendation:** **Ship pre-generated MP3s in the app bundle** for Phase 1. Zero runtime cost, offline-by-default, no CDN needed. Switch to R2-on-demand only if bundle exceeds 100 MB or Marina wants dynamic NPC narration (Phase 3).

## 6. Architecture

```
┌─────────────────────────┐      ┌──────────────────────┐
│ Build-time tool (Node)  │─────▶│ Cloudflare Worker    │
│ scripts/generate-tts.js │      │ narration-proxy.js   │
│ walks Swift content,    │ POST │ (shared w/ fal+Claude)│
│ extracts strings        │      └──────────┬───────────┘
└─────────────────────────┘                 │ Bearer ELEVENLABS_KEY
                                            ▼
                                    ┌───────────────┐
                                    │ ElevenLabs    │
                                    │ /v1/tts/...   │
                                    └──────┬────────┘
                                           │ mp3
                                           ▼
                          ┌────────────────────────────┐
                          │ narration/{hash}.mp3       │
                          │ manifest.json → {id:hash}  │
                          │ copied into Xcode bundle   │
                          └────────────────────────────┘
                                   │
                                   ▼
 Runtime (iPad):  NarrationService.swift
                  └── resolves id → Bundle.main mp3
                  └── AVAudioPlayer.play()
                  └── ducks SoundManager music via AVAudioSession
```

**Hash key:** `sha256(voiceId + ":" + text)`. Deterministic — rewording a single card only regenerates that card.

**Build script output:**
```
Assets/narration/
  manifest.json           ← { "card_4_cityMap_building_0_lesson": "a3f1…" }
  a3f1b9c2.mp3            ← 8 KB (lesson text, ~40 sec)
  …
```

## 7. Runtime: NarrationService.swift

New singleton in `Services/`:

```
@MainActor class NarrationService: ObservableObject {
  @Published var state: NarrationState = .idle   // .idle/.loading/.playing/.paused
  @Published var activeToken: String? = nil      // text hash currently playing
  @Published var progress: Double = 0

  func speak(_ text: String, voice: Voice = .giovanni, rate: Float = 1.0)
  func pause(); func resume(); func stop()
  func togglePlaybackRate()   // cycles 0.75/1.0/1.25/1.5
}
```

**Integration points:**
- `SoundManager.swift`: add `duckForNarration(_ on: Bool)` that lowers music to 0.2× while narration plays, restores on stop.
- `AVAudioSession`: change category to `.playback, .duckOthers` when narration starts; restore `.ambient, .mixWithOthers` when it ends. Handle `AVAudioSession.interruptionNotification` (phone call → pause → resume on `.shouldResume`).
- `GameSettings`: add `narrationSpeed: Double = 1.0`, `narrationAutoAdvance: Bool = false`.
- `KnowledgeCardsOverlay.swift`: add top-right Listen button on flipped card (next to existing close button).
- `BuildingLessonView.swift`: add Listen button in header bar, stop on page turn.

**Rule: only one narration at a time.** Tapping Listen on card B while card A is playing cancels A (same pattern as `SoundManager.playMusic` crossfade).

## 8. Subscription Gating (UX)

Listen button is **always visible**. For non-subscribers:

1. Tap Listen → narration plays first **10 seconds**
2. Soft auto-fade at 9.5s → 10s, stop
3. Overlay slides up: *"Enjoying Il Maestro's voice? Subscribers hear every lesson narrated. Upgrade to Apprentice."*
4. Two buttons: **See Plans** (opens paywall) / **Keep Reading** (dismisses, text still there)

For subscribers (`GameSettings.shared.isSubscribed == true`): immediate full playback, no paywall, no 10-sec limit.

Rationale: hearing 10 seconds of quality narration is the best conversion demo possible. "Always visible" beats "hidden" because curiosity → try → conversion.

## 9. Playback UI

**Listen button:** `speaker.wave.2.fill` → `speaker.wave.2` → `pause.fill` state machine. Sepia ink color (`RenaissanceColors.sepiaInk`), 44×44 hit target.

**While playing:** thin progress bar under the text being narrated in `blueprintBlue`. Bar only — no waveform in Phase 1.

**Speed control:** long-press Listen button → popover with 0.75× / 1× / 1.25× / 1.5× pills. Persist choice in `GameSettings.narrationSpeed`.

**Karaoke highlighting (Phase 3 only):** ElevenLabs returns character-level timestamps — map to word ranges, apply `blueprintBlue.opacity(0.15)` background on the currently-spoken word. Skip in Phase 1 — adds 2 weeks of work.

**Auto-advance:** toggle in Profile → Audio settings. On card completion: advance to next knowledge card; on lesson page: advance to next section. Off by default.

## 10. Offline

Because Phase 1 MP3s are shipped in-bundle, offline is automatic — no network calls at runtime. Airplane-mode kids get full narration. Phase 3 dynamic NPC lines require network; if offline, silently fall back to text-only.

## 11. Phased Rollout

| Phase | Scope | Est. effort | Ship |
|---|---|---|---|
| **Phase 1** | NarrationService + Giovanni voice + Listen on knowledge cards, fun facts, lesson readings. Pre-baked bundle MP3s. 10-sec paywall preview. | 1 week | May 2026 |
| **Phase 2** | Lily voice on bird dialogue. Speed control. Auto-advance. Q&A narration. R2 cloud cache for dynamic NPC lines. | 1 week | Post-launch v1.1 |
| **Phase 3** | George voice for historical figures. Karaoke highlighting. Sketching hint narration. | 2 weeks | v1.2 |

## 12. Risks

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| ElevenLabs pricing change | Med | Low | Pre-baked cache insulates runtime cost — affects only regeneration |
| Voice sounds "too adult" for 10-yr-olds | Med | Med | TestFlight with 5–10 kids before ship; A/B Giovanni vs Adam |
| Bundle size bloat beyond 100 MB | Low | Med | Flip to R2 on-demand + local disk cache if threshold hit |
| Audio conflict with VoiceOver | Med | Low | Detect `UIAccessibility.isVoiceOverRunning`; hide Listen button (VO reads the text itself) |
| Italian pronunciation of "Pantheon", "pozzolana" | Med | Low | ElevenLabs supports SSML `<phoneme>` — pre-insert on ~20 known terms in build script |
| Kids pause narration mid-sentence → jarring | Low | Low | Fade-out 200 ms on pause/stop |

## 13. Integration Points (files to touch)

- `Services/NarrationService.swift` (new)
- `Services/SoundManager.swift` (add ducking)
- `Models/GameSettings.swift` (add narration settings; subscription gate already exists at line 64)
- `Views/KnowledgeCardsOverlay.swift` (Listen button on flipped card)
- `Views/BuildingLessonView.swift` (Listen button in header)
- `Services/APIKeys.swift` (add `appSharedToken` if not already there for narration proxy route)
- `scripts/generate-narration.js` (new build-time tool)
- Cloudflare Worker (add `/narration/synthesize` route alongside existing `/submit` fal route)
