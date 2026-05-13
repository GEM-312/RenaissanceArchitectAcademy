# Weekly Code Health Report — 2026-05-13
**Project:** Renaissance Architect Academy  
**Checked by:** Claude Code (claude-sonnet-4-6)  
**Files read:** 178 Swift files across all directories (Models, Services, ViewModels, Views, SpriteKit, Sketching, Onboarding, StationMiniGames, Styles)

---

## TL;DR

**Status: YELLOW**

| Severity | Count |
|----------|-------|
| CRITICAL | 0 |
| WARNING  | 5 |
| INFO     | 7 |

No secrets in source. No `% frameCount` loop violations found — all timers either self-invalidate on a counter check or are properly cleaned up `onDisappear`. The main issues are one confirmed UserDefaults key mismatch that silently breaks data wipe, 13 missing blueprint assets for the sketch system, and a pervasive hardcoded-font pattern across 445 view call sites. TestFlight build is stale (last upload: 2026-04-17).

---

## CHECK 1 — Build Status

**Result: INCONCLUSIVE** — `xcodebuild` is not installed in this Linux environment. Run `Cmd+B` in Xcode to verify. No structural compilation blockers were found during file review.

---

## CHECK 2 — Hardcoded Values

### CRITICAL — None found

No API keys, bearer tokens, or secrets are hardcoded in any Swift source file. `APIKeys.swift` is properly listed in `.gitignore` and only accessed through `WorkerClient.proxyToken`. Worker base URL (`https://raa-api.pollak.workers.dev`) is a public domain — correct to hardcode. ElevenLabs voice IDs (`TTSVoice.npcMale = "PASTE_NPC_MALE_VOICE_ID_HERE"`) use a sentinel string pattern; `TTSVoice.isConfigured()` checks for the `"PASTE_"` prefix before making any network call — safe.

---

### WARNING — Hardcoded raw font names in Views (445 call sites)

**W-01 · Views/ (many files)** — 445 `.font(.custom("EBGaramond-...", size:))` calls bypass the `RenaissanceFont` token system. The token enum in `RenaissanceTheme.swift` is comprehensive (35 tokens covering all weights and sizes) but views are not using it. Every direct `.font(.custom(...))` call is a maintenance liability: if a font name or baseline size needs to change, it requires touching hundreds of call sites instead of one token definition.

Examples (three of the most common patterns):
- `.font(.custom("EBGaramond-SemiBold", size: 16))` — 27 sites → should use `RenaissanceFont.bodyMedium` (defined as EBGaramond-Regular 16pt; the SemiBold 16pt variant needs `RenaissanceFont.bodySemibold` adjusted to size 16, or a new token)
- `.font(.custom("EBGaramond-SemiBold", size: 13))` — 17 sites → no exact token exists; add `static let captionSemibold = Font.custom("EBGaramond-SemiBold", size: 13, relativeTo: .caption)` to `RenaissanceTheme.swift`
- `.font(.system(size: 13))` — 91 sites → use `RenaissanceFont.caption`

**Fix (do not rush):** This is a refactor, not a fire. Tackle one file at a time during quiet periods. The mapping:
- `EBGaramond-Regular size:17` → `RenaissanceFont.body`
- `EBGaramond-Regular size:16` → `RenaissanceFont.bodyMedium`
- `EBGaramond-Regular size:15` → `RenaissanceFont.bodySmall`
- `EBGaramond-Regular size:14` → `RenaissanceFont.footnote`
- `EBGaramond-Regular size:13` → `RenaissanceFont.caption`
- `EBGaramond-Italic size:17` → `RenaissanceFont.italic`
- `EBGaramond-SemiBold size:15` → `RenaissanceFont.buttonSmall`
- `EBGaramond-SemiBold size:18` → `RenaissanceFont.button`
- `Cinzel-Bold size:20` → `RenaissanceFont.visualTitle` (16pt) or add a new `RenaissanceFont.navLabel` token

Note: `MainMenuView.swift:61` uses `.font(.custom("Amellina", size: taglineSize + 6))` — `Amellina` has no token in `RenaissanceTheme.swift`. Add `static let menuScript = Font.custom("Amellina", size: 26, relativeTo: .title3)` if this font is permanent.

---

### WARNING — Hardcoded raw colors in SpriteKit (ResourceNode, CityScene)

**W-02 · ResourceNode.swift:652,653,780,781,864,865,892,893** — Eight `PlatformColor(red: 0.18, green: 0.16, blue: 0.13, ...)` and `PlatformColor(red: 0.961, green: 0.902, blue: 0.827, ...)` calls that duplicate `RenaissanceColors.darkCardBg` and `RenaissanceColors.parchment`. `PlatformColor` does accept a SwiftUI `Color` via `PlatformColor(RenaissanceColors.parchment)` as shown in `CityScene.swift:233`.

**Fix:** Replace every:
- `PlatformColor(red: 0.18, green: 0.16, blue: 0.13, alpha: x)` → `PlatformColor(RenaissanceColors.darkCardBg).withAlphaComponent(x)`
- `PlatformColor(red: 0.961, green: 0.902, blue: 0.827, alpha: x)` → `PlatformColor(RenaissanceColors.parchment).withAlphaComponent(x)`

**W-03 · CityScene.swift:251** — Building glow color `PlatformColor(red: 0.85, green: 0.66, blue: 0.37, alpha: 1.0)` is a near-match for `RenaissanceColors.ochre` (0.788, 0.659, 0.416) — slightly brighter. This is either an intentional departure (brighter glow) or a drift.

**Fix:** If intentional, add `static let buildingGlow = Color(red: 0.85, green: 0.66, blue: 0.37)` to `RenaissanceColors.swift`. If accidental, use `PlatformColor(RenaissanceColors.ochre)`.

---

### WARNING — UserDefaults key mismatch in DataManagementService

**W-04 · DataManagementService.swift:24** — The key `"gameSettings_hasChosenAIProvider"` does not match `GameSettings.aiChosenKey = "gameSettings_aiChosen"` (`GameSettings.swift:186`). When `DataManagementService.wipeAllData()` runs, it attempts to remove `"gameSettings_hasChosenAIProvider"`, which does not exist — the actual key `"gameSettings_aiChosen"` is never cleared. After a full data wipe, `GameSettings.hasChosenAIProvider` remains `true`, so the AI provider picker does not re-show on the next launch as expected.

**Fix:** In `DataManagementService.swift` line 24, change:
```swift
// BEFORE (wrong key):
"gameSettings_hasChosenAIProvider",

// AFTER (matches GameSettings.aiChosenKey):
"gameSettings_aiChosen",
```

---

### WARNING — `IVMaterialColors` tokens are local to Views, not in `RenaissanceColors`

**W-05 · InteractiveVisualHelpers.swift:11–24** — Nine material colors (`waterBlue`, `dimColor`, `marbleWhite`, `leadGray`, `ironDark`, `oakBrown`, `bronzeGold`, `hotRed`, `limeTan`) are defined as raw literals in a file-local enum. These colors are shared across all 17 interactive visual files. They belong in `RenaissanceColors.swift` as named tokens so the palette stays in one canonical file.

**Fix:** Move the nine `IVMaterialColors` statics (with the same names) into a `// MARK: - Interactive Visual Materials` section at the bottom of `RenaissanceColors.swift`. Keep the `IVMaterialColors` type alias pointing to `RenaissanceColors` so call sites don't break.

---

## CHECK 3 — Dead Code

**Result: CLEAN with one INFO note**

No unused structs or functions detected. All 178 Swift files are referenced in the project. `GoldsmithMapView.swift` and `GoldsmithScene.swift` are actively used by `WorkshopView.swift:48` — not dead code.

**INFO-01** — `GreatVibes-Regular.ttf` is registered in `RenaissanceArchitectAcademyApp.swift:53` but there is no corresponding token in `RenaissanceTheme.swift` and no call site using `GreatVibes` in any view (only `Amellina` and `PetitFormalScript-Regular` appear in view code). If `GreatVibes` is not planned for use, it can be removed from the font registration list to reduce app startup overhead.

---

## CHECK 4 — Memory / Performance

**Result: CLEAN**

All `Timer.scheduledTimer(repeats: true)` calls were inspected. None are infinite loops:

| File | Timer | Stop condition |
|------|-------|---------------|
| `MascotDialogueView.swift:486` | fly-to-sit sprite | `t.invalidate()` when `totalFrame >= totalFlyFrames` |
| `MascotDialogueView.swift:504` | fly-to-sit (onChange) | `t.invalidate()` when `frame >= flySitFrameCount - 1` |
| `MascotDialogueView.swift:520` | blink sprite | `t.invalidate()` when `frame >= sitBlinkFrameCount - 1` |
| `MascotDialogueView.swift:592` | idle blink | Cleaned up `onDisappear` via `blinkTimer?.invalidate()` |
| `FlowRateVisual.swift:238` | counter | `timer.invalidate()` on counter completion; `counterTimer?.invalidate()` on `onDisappear` |
| `KnowledgeCardsOverlay.swift:1658` | fishing bubble drift | `fishingTimer?.invalidate()` on answer, completion, and `onDisappear` |
| `ProfileView.swift:374` | avatar frame | `timer.invalidate()` when `currentFrame >= frameCount - 1` |
| `NPCDialogueView.swift:216` | typewriter | `timer.invalidate()` when text fully revealed; `onDisappear` cleanup |
| `BuildingLessonView.swift:1573` | word bank shuffle | `wordBankShuffleTimer?.invalidate()` when answer is confirmed |
| `StationLessonOverlay.swift:132` | typewriter | `timer.invalidate()` when complete |
| `AvatarTransitionView.swift:78` | frame animation | `timer.invalidate()` when `currentFrame >= frameCount - 1` (plays ONCE) |
| `StoryNarrativeView.swift:190` | typewriter | `timer.invalidate()` when complete |
| `StoryNarrativeView.swift:235` | background frames | `timer.invalidate()` when `bgFrame >= bgFrameCount - 1` (plays ONCE) |
| `QuarryMiniGameView.swift:783` | bond pulse | Invalidated on game complete (`line 827`) and on answer (`line 974`) |
| `QuarryMiniGameView.swift:853` | shrink timer | `timer.invalidate()` when `timeLeft <= 0` |
| `ClayPitMiniGameView.swift:1022` | wash grid reshuffle | `washTimer?.invalidate()` when phase exits `.playingWash` |
| `FarmMiniGameView.swift:658` | game loop | `gameTimer?.invalidate()` on game over (`line 664`) |
| `SoundManager.swift:347,363` | fade in/out | Invalidated after `steps` (20) iterations |

**INFO-02** — `QuarryMiniGameView.swift:783` `bondPulseTimer` has no `onDisappear` cleanup call. It is invalidated at `line 827` (game cleanup) and `line 974` (answer confirmed), but if the view is dismissed during the bond-pulse phase without completing, the timer outlives the view. This is low risk (the timer only mutates a local `@State var bondPulse: Double`) but technically a leak.

**Fix:** Add `bondPulseTimer?.invalidate()` to an `.onDisappear { }` modifier in `QuarryMiniGameView`.

---

## CHECK 5 — pbxproj Consistency

**Result: TWO files in pbxproj not on disk (expected)**

| File | Status |
|------|--------|
| `APIKeys.swift` | Intentionally gitignored — developer must create locally from template |
| `sourcecode.swift` | Phantom Xcode artifact — not a real source file; harmless |

All 178 Swift files on disk are referenced in the project. No orphaned source files.

---

## CHECK 6 — Missing Assets

### Blueprint images for the Sketch system (13 of 17 missing)

**INFO-03** — `SketchingContent.swift` references blueprint imagesets for all 17 buildings via `referencePlanImageName`. Only 4 exist in `Assets.xcassets`. When a blueprint is missing, `PiantaCanvasView` shows a "Blueprint coming soon" placeholder (by design — see comment in `SketchingContent.swift:12`). This is tracked but the count has grown.

| Blueprint | Status |
|-----------|--------|
| `PantheonBlueprint` | FOUND |
| `AqueductBlueprint` | FOUND |
| `ColosseumBlueprint` | FOUND |
| `RomanBathsBlueprint` | FOUND |
| `RomanRoadsBlueprint` | MISSING |
| `HarborBlueprint` | MISSING |
| `SiegeWorkshopBlueprint` | MISSING |
| `InsulaBlueprint` | MISSING |
| `DuomoBlueprint` | MISSING |
| `BotanicalGardenBlueprint` | MISSING |
| `GlassworksBlueprint` | MISSING |
| `ArsenalBlueprint` | MISSING |
| `AnatomyTheaterBlueprint` | MISSING |
| `LeonardoWorkshopBlueprint` | MISSING |
| `FlyingMachineBlueprint` | MISSING |
| `VaticanObservatoryBlueprint` | MISSING |
| `PrintingPressBlueprint` | MISSING |

All tool assets (`ToolPickaxe`, `ToolBucket`, `ToolAshRake`, `ToolShovel`, `ToolMiningHammer`, `ToolAxe`, `ToolMortarAndPestle`, `ToolPitchfork`, `ToolTradePurse`) are present. All `BirdFrame00–12` and `VolcanoFrame00–14` animation frames are present.

---

## CHECK 7 — TestFlight Feedback

**Last build uploaded:** 2026-04-17 (version 3, build `c45a886e`) — **26 days ago**. 4 active testers.

**5 feedback items since last report:**

| # | Tester | Device | Build | Issue | Priority |
|---|--------|--------|-------|-------|----------|
| 1 | Ray Garmon | iPhone11,8 (iOS 18.7.7) | 2 | "I'm tapping on the gold objects instead of sifting. One of the golds I have to tap was brown." — Hit target mismatch in river mini-game gold-sifting activity; one gold nugget renders brown, possibly asset color issue | HIGH |
| 2 | Ray Garmon | iPhone11,8 (iOS 18.7.7) | 2 | "Not related with question. It asked why and I had to tap picture." — Knowledge card `.reflect` question type confusion: player expects a text answer but UI shows tap-target interaction; instruction text needs to clarify the mechanic | HIGH |
| 3 | Brianna Walker | iPhone13,4 (iOS 26.4.1) | 2 | "iPad horizontal view: just scale down a bit for 'Choose your apprentice' screen. No back button in All/Rome/Ren./Tests. 2 different animations after choosing your apprentice." | MEDIUM |
| 4 | Brianna Walker | iPhone13,4 (iOS 26.4.1) | 2 | "iPhone vertical view: minor scaling changes, text adjustments, bird companion flies in over text" | MEDIUM |
| 5 | Marina Pollak | iPhone16,2 (iOS 26.4) | 2 | "Every card asking to tap somewhere but some questions and interactions don't make much sense." — Confirms feedback #2: `.find` tap-target mechanic is not clearly communicated to players | HIGH |

**Action items:**
1. (HIGH) River mini-game: audit gold nugget asset colors — one nugget may be rendering with a brown fallback instead of the gold Midjourney asset.
2. (HIGH) Knowledge cards `.reflect` and `.find` types: add a visible instructional micro-label ("Tap to answer" vs "Explain why") so the interaction mode is clear before the player taps anything.
3. (MEDIUM) Character select screen: reduce font/image scale for iPad landscape and add back-navigation button to `CityView` era tabs.
4. (MEDIUM) Bird companion entrance in `StoryNarrativeView`: bird enters from off-screen but the entry animation overlaps dialogue text on iPhone portrait; delay or offset the entrance.

---

## Missing Tokens (add to source before next sprint)

| Token | File | Value |
|-------|------|-------|
| `RenaissanceFont.menuScript` | `RenaissanceTheme.swift` | `Font.custom("Amellina", size: 26, relativeTo: .title3)` — currently hardcoded in `MainMenuView.swift:61` |
| `RenaissanceFont.captionSemibold` | `RenaissanceTheme.swift` | `Font.custom("EBGaramond-SemiBold", size: 13, relativeTo: .caption)` — 17 hardcoded sites |
| `RenaissanceColors.buildingGlow` | `RenaissanceColors.swift` | `Color(red: 0.85, green: 0.66, blue: 0.37)` — used as dark-mode glow in `CityScene.swift:251`; verify intentional vs ochre drift |

---

## Clean Scans

- **API keys / secrets:** CLEAN — no `sk-`, `Bearer ` assigned to literals, no `ANTHROPIC_API_KEY`, no raw Wolfram app IDs in source. All proxied through `WorkerClient`.
- **`% frameCount` loop violations:** CLEAN — zero timer closures use modulo to wrap frame counters. All animations play once and stop.
- **SwiftData schema:** CLEAN — `ModelContainer` schema `[PlayerSave.self, BuildingProgressRecord.self, LessonRecord.self]` matches all `@Model` classes. No orphaned model types.
- **SpriteKit `[weak self]`:** CLEAN for main game scenes. MascotDialogueView timer closures capture only value types (`totalFrame`, `frame`) — no strong `self` capture risk.
- **Font files vs registration:** CLEAN — all 32 font files registered in `RenaissanceArchitectAcademyApp.swift` exist in `Fonts/`. `Cinzel-VariableFont_wght.ttf`, `EBGaramond-VariableFont_wght.ttf`, and `EBGaramond-Italic-VariableFont_wght.ttf` exist on disk but are registered too — harmless (CoreText ignores duplicates). `GreatVibes-Regular.ttf` is registered but unused (see INFO-01).
- **`ForEach` IDs:** CLEAN — all `id: \.self` usages are on `enum` types (`Science`, `Material`, `MarketTab`) or integer ranges where values are guaranteed unique in context.

---

## Build Status

`xcodebuild` unavailable in this environment. Cannot produce a compilation log. Recommend running `Cmd+B` in Xcode on macOS before shipping.
