# Weekly Health Check — 2026-05-06

**Project:** Renaissance Architect Academy  
**Developer:** Marina Pollak  
**Auditor:** Claude (automated, full codebase read before any analysis)  
**Swift files read:** 174 of 174  
**Date:** 2026-05-06

---

## Summary

| Category | Status | Count |
|---|---|---|
| Build Verification | ⚠️ SKIPPED | `xcodebuild` not available in Linux audit environment |
| Hardcoded Values | 🔴 CRITICAL | 941+ instances in Views; multiple in core style files |
| Dead Code | 🟡 WARNING | Duplicate font registrations in App.swift |
| Memory & Performance | 🟡 WARNING | 18 Timer closures missing `[weak self]`; 2 performance patterns |
| Consistency (pbxproj) | ✅ CLEAN | All 174 Swift files tracked; no orphans |
| Missing Assets | 🔴 CRITICAL | 12 sprites referenced in code but absent from asset catalog |
| TestFlight Feedback | 🟡 WARNING | 5 items (3 UX bugs, 2 layout issues) |
| CLAUDE.md Violations | 🔴 CRITICAL | 29 `repeatForever` animation instances across 16 files |

---

## 1. Build Verification

**Status: ⚠️ SKIPPED**

`xcodebuild` is not installed in this Linux audit environment. Build must be verified locally in Xcode before the next release.

**Last known state:** TestFlight build v3 (2026-04-17) uploaded successfully and marked `VALID`.

---

## 2. Hardcoded Values

**Status: 🔴 CRITICAL**

### 2a. Font sizes — 941 instances

`grep` across all Views for `.custom("…", size:)` not routed through `RenaissanceFont` tokens returned **941 matches**. Every occurrence is a violation; the token system exists specifically to eliminate these. Tokens to use:

| Token | Font | Size |
|---|---|---|
| `RenaissanceFont.hero` | Cinzel-Bold | 36 |
| `RenaissanceFont.body` | EBGaramond-Regular | 17 |
| `RenaissanceFont.button` | EBGaramond-SemiBold | 18 |
| `RenaissanceFont.buttonSmall` | EBGaramond-SemiBold | 15 |
| `RenaissanceFont.caption` | EBGaramond-Regular | 13 |
| `RenaissanceFont.footnote` | EBGaramond-Regular | 14 |
| `RenaissanceFont.bodyMedium` | EBGaramond-Regular | 16 |

Representative violations (not exhaustive):

**`GameTopBarView.swift`**
- L47: `.custom("EBGaramond-SemiBold", size: 18)` → `RenaissanceFont.button`
- L73: `.custom("EBGaramond-Medium", size: 15)` → `RenaissanceFont.buttonSmall`
- L244: `.custom("EBGaramond-Medium", size: 13)` → `RenaissanceFont.caption`
- L286: `.custom("EBGaramond-Regular", size: 16)` → `RenaissanceFont.bodyMedium`

**`RenaissanceButton.swift`**
- L19: `.custom("EBGaramond-Regular", size: 20)` — no matching token; add `RenaissanceFont.buttonLarge` at size 20
- L23: `.padding(.horizontal, 24)` — equals `Spacing.xl`; use token
- L24: `.padding(.vertical, 14)` — no token; add `Spacing.buttonV = 14` or use closest `Spacing.sm = 12`
- L128: `.custom("EBGaramond-Regular", size: 18)` — wrong weight; `RenaissanceFont.button` is SemiBold at 18
- L131: `.padding(.horizontal, 20)` — equals `Spacing.lg`
- L132: `.padding(.vertical, 10)` — no exact token

**`AssetManager.swift` (ODRLoadingView)**
- L175: `spacing: 16` → `Spacing.md`
- L181: `.custom("EBGaramond-Italic", size: 16)` — no italic token; add `RenaissanceFont.bodyItalic`
- L183: `.custom("EBGaramond-Regular", size: 13)` → `RenaissanceFont.caption`
- L189: `.padding(.horizontal, 40)` → `Spacing.xxxl`
- L193: `.custom("EBGaramond-SemiBold", size: 14)` — no exact token; `RenaissanceFont.footnote` is Regular; add `RenaissanceFont.footnoteBold` or use `buttonSmall`

### 2b. Color literals

**`GameSceneKitView.swift`**
- L23 (macOS): `NSColor(red: 0.961, green: 0.902, blue: 0.827, alpha: 1.0)` — hardcoded parchment; add a `parchmentNSColor` static in `RenaissanceColors`
- L67 (iOS): `UIColor(red: 0.961, green: 0.902, blue: 0.827, alpha: 1.0)` — same issue

**`GameSettings.swift`**
- `Color(red: 0.18, green: 0.16, blue: 0.13)` — inline dark card background appears **4 times**; extract as `private static let darkCardBackground`
- `Color(red: 0.93, green: 0.87, blue: 0.78)` — inline light card color appears **2 times**; extract as `private static let lightCardBackground`

---

## 3. Dead Code

**Status: 🟡 WARNING**

### 3a. Duplicate font registrations — `RenaissanceArchitectAcademyApp.swift`

Font `CTFontManagerRegisterFontsForURL` is called multiple times for the same EBGaramond variants:

| Font | Registration count |
|---|---|
| EBGaramond-Regular | 3× |
| EBGaramond-Medium | 2× |
| EBGaramond-SemiBold | 2× |
| EBGaramond-Bold | 2× |
| EBGaramond-Italic | 2× |

Each duplicate call is a no-op after the first (CoreText ignores re-registration), but it wastes startup time and signals copy-paste drift. Each variant should appear exactly once.

### 3b. Comment blocks ≥ 16 lines (likely doc/architecture notes — review for stale content)

| File | Max consecutive comment lines | Starting line |
|---|---|---|
| `Views/Sketching/PiantaCanvasView.swift` | 16 | L6 |
| `Services/GameTools.swift` | 16 | L288 |
| `Services/AssetManager.swift` | 15 | L3 |
| `Views/FoldableInventoryBar.swift` | 13 | L9 |
| `Views/Sketching/PencilCanvasView.swift` | 13 | L5 |
| `Views/SpriteKit/CityMapView.swift` | 13 | L5 |

These appear to be architecture notes and doc comments rather than commented-out code. Verified no ≥5-line commented-out code blocks found.

### 3c. TTSService unconfigured voice IDs

`Services/TTSService.swift` has two placeholder voice IDs that have not been filled in:
- `static let npcMale = "PASTE_NPC_MALE_VOICE_ID_HERE"`
- `static let npcFemale = "PASTE_NPC_FEMALE_VOICE_ID_HERE"`

`TTSVoice.isConfigured(_:)` will return `false` for these — NPC voices are silently disabled at runtime.

---

## 4. Memory & Performance

**Status: 🟡 WARNING**

### 4a. Timer closures missing `[weak self]` — potential retain cycles

18 `Timer.scheduledTimer(…, repeats: true)` calls without a `[weak self]` capture list were found. In SwiftUI `@Observable` classes this is reduced risk (view lifecycle drives deallocation), but timers that outlive their owning view create retain cycles. Each closure should capture `[weak self]` and guard on `self` before use.

| File | Lines |
|---|---|
| `Views/MascotDialogueView.swift` | 486, 504, 520, 592 |
| `Views/StationMiniGames/QuarryMiniGameView.swift` | 783, 853 |
| `Views/Onboarding/StoryNarrativeView.swift` | 141, 174 |
| `Views/FlowRateVisual.swift` | 238 |
| `Views/KnowledgeCardsOverlay.swift` | 1658 |
| `Views/ProfileView.swift` | 293 |
| `Views/NPCDialogueView.swift` | 216 |
| `Views/BuildingLessonView.swift` | 1573 |
| `Views/Onboarding/StationLessonOverlay.swift` | 132 |
| `Views/Onboarding/AvatarTransitionView.swift` | 85 |
| `Views/StationMiniGames/ClayPitMiniGameView.swift` | 1022 |
| `Views/StationMiniGames/FarmMiniGameView.swift` | 658 |

### 4b. AssetManager busy-wait polling (lines 57–61)

`Services/AssetManager.swift` uses a `Task.sleep` polling loop to wait for ODR downloads:
```swift
while !request.progress.isFinished {
    try await Task.sleep(for: .milliseconds(100))
}
```
This burns CPU with 10 wake-ups per second. Replace with `NSBundleResourceRequest` progress KVO or `AsyncStream` wrapping the progress callback.

### 4c. SoundManager fade loop (lines 341–367)

`Services/SoundManager.swift` `fadeIn`/`fadeOut` methods schedule **20 sequential `DispatchQueue.main.asyncAfter` calls** (one per volume step). This generates 20 scheduler entries per fade. Replace with a single `DisplayLink`-based or `CADisplayLink`-backed timer that updates volume on each frame tick.

### 4d. Large uncompressed images in Assets.xcassets

The following PNG files exceed 500 KB each and may affect memory and app size:

| File | Note |
|---|---|
| `Assets.xcassets/Market.png` | **Loose PNG** — not in an `.imageset` folder |
| `Assets.xcassets/WorkshopExterior.png` | **Loose PNG** — not in an `.imageset` folder |
| `CraftedRomanConcrete.imageset/CraftedRomanConcrete.png` | In imageset ✓ — may need sips resize |
| `QuarryFrame07.imageset/QuarryFrame07.png` | In imageset ✓ |
| `QuarryFrame02.imageset/QuarryFrame02.png` | In imageset ✓ |
| `PantheonStep1Infographic.imageset/…` | In imageset ✓ |
| `PigmentSienna.imageset/PigmentSienna.png` | In imageset ✓ |
| `MaterialBeeswax.imageset/MaterialBeeswax.png` | In imageset ✓ |
| `MaterialClay.imageset/MaterialClay.png` | In imageset ✓ |
| `MaterialTemperaPaint.imageset/MaterialTemperaPaint.png` | In imageset ✓ |

The two **loose** PNGs (`Market.png`, `WorkshopExterior.png`) are outside `.imageset` wrappers and are NOT accessible via `Image("Market")` in SwiftUI or `SKTexture(imageNamed:)` in SpriteKit. They will silently fail to load. Each needs its own `.imageset` folder with a `Contents.json`.

---

## 5. Consistency (pbxproj vs Filesystem)

**Status: ✅ CLEAN**

- `project.pbxproj` contains **700 PBXBuildFile entries** covering all 174 Swift files + all asset resources.
- **0 Swift files** present on disk but absent from pbxproj.
- **0 Swift files** in pbxproj but absent from disk.
- No orphaned file references found.

*Note: The pbxproj uses numeric file reference IDs (001, 002…) rather than filename strings — this is a non-standard but valid Xcode project format.*

---

## 6. Missing Assets

**Status: 🔴 CRITICAL**

### 6a. Station sprites (8 missing) — `ResourceNode.swift`

`Views/SpriteKit/ResourceNode.swift` returns image names for all 8 resource stations, but **none of these imagesets exist** in `Assets.xcassets`. SpriteKit renders gray boxes when `SKTexture(imageNamed:)` fails to find an asset.

| Code reference | Expected imageset | Status |
|---|---|---|
| `"StationQuarry"` | `StationQuarry.imageset` | ❌ Missing |
| `"StationRiver"` | `StationRiver.imageset` | ❌ Missing |
| `"StationVolcano"` | `StationVolcano.imageset` | ❌ Missing |
| `"StationClayPit"` | `StationClayPit.imageset` | ❌ Missing |
| `"StationMine"` | `StationMine.imageset` | ❌ Missing |
| `"StationForest"` | `StationForest.imageset` | ❌ Missing |
| `"StationMarket"` | `StationMarket.imageset` | ❌ Missing |
| `"StationCraftingRoom"` | `StationCraftingRoom.imageset` | ❌ Missing |

*The existing loose `Market.png` and `WorkshopExterior.png` files in `Assets.xcassets` may be the source art for some of these — they need to be wrapped in `.imageset` folders to be accessible.*

### 6b. Goldsmith interior sprites (4 missing) — `GoldsmithScene.swift`

`Views/SpriteKit/GoldsmithScene.swift` references 4 interior station sprites for the Goldsmith scene that do not exist in `Assets.xcassets`:

| Code reference | Expected imageset | Status |
|---|---|---|
| `"InteriorEngravingBench"` | `InteriorEngravingBench.imageset` | ❌ Missing |
| `"InteriorCastingStation"` | `InteriorCastingStation.imageset` | ❌ Missing |
| `"InteriorGoldsmithFurnace"` | `InteriorGoldsmithFurnace.imageset` | ❌ Missing |
| `"InteriorPolishingWheel"` | `InteriorPolishingWheel.imageset` | ❌ Missing |

The four existing Interior* assets (`InteriorFurnace`, `InteriorPigmentTable`, `InteriorShelf`, `InteriorWorkbench`) are for the Workshop crafting room, not the Goldsmith scene.

---

## 7. TestFlight Feedback

**Status: 🟡 WARNING**

Latest sync: **2026-04-18**. Build v3 (2026-04-17). 4 active testers. **5 feedback items**.

### Bug 1 — Volcano/River mini-game tap target color (Ray Garmon, iPhone 11, iOS 18.7.7)
> "I'm tapping on the gold objects instead of sifting. One of the golds I have to tap was brown."

The sifting interaction in VolcanoMiniGameView or RiverMiniGameView has a tap target rendered in gold/brown that the tester couldn't distinguish from the correct target. Two issues: (1) a "gold" tap target is rendered brown (wrong color/missing asset), and (2) the interaction instruction is unclear — tester didn't realize sifting vs tapping are different gestures.

*Reproduce on: iPhone 11 / iOS 18.7.7. Has screenshot.*

### Bug 2 — Museum sketch `.reflect` question type shows tap target (Ray Garmon, iPhone 11, iOS 18.7.7)
> "Not related with question. It asked why and I had to tap picture."

`MuseumSketch.questionType = .reflect` is supposed to prompt a "why/how" reflection — but the view still shows a tap-the-picture interaction. The `.reflect` case likely shares the same view path as `.find` and is not rendering a different UI for open-ended questions.

*Reproduce on: iPhone 11 / iOS 18.7.7. Has screenshot.*

### Bug 3 — Character select screen overflows on iPad landscape (Brianna Walker, iPhone 13 Pro Max, iOS 26.4.1)
> "iPad horizontal view: just scale down a bit for 'Choose your apprentice' screen"

`CharacterSelectView` (or `OnboardingView` character step) overflows on iPad landscape. Additionally: (1) no back button in `CityView` (All, Rome, Ren., Tests panels); (2) two different animations play after choosing an apprentice (duplicate animation trigger or competing transitions).

*Reproduce on: iPad, landscape. Has screenshot.*

### Bug 4 — Bird companion overlaps onboarding text on iPhone portrait (Brianna Walker, iPhone 13 Pro Max, iOS 26.4.1)
> "iPhone vertical view: bird companion flies from off the screen because it appears over the text"

The bird mascot in `StoryNarrativeView` or the onboarding sequence appears on top of the narrative text in iPhone portrait. The bird's entrance animation does not fly in from off-screen — it pops or cross-fades into view mid-text. Minor: some text and UI elements need scaling adjustments on iPhone.

*Reproduce on: iPhone portrait. Has screenshot.*

### UX Issue 5 — Museum sketch card interactions confusing (Marina, iPhone 16 Pro Max, iOS 26.4)
> "Every card asking to tap somewhere on the picture but some questions and interactions doesn't make much sense."

Multiple testers (Ray + Marina) report that the `.reflect` and `.count` question types in `SketchStudyOverlay` feel arbitrary. The tap interaction requires tapping a specific region even when the question asks "why" or "how many" — the connection between the instruction and the expected interaction is unclear. The `.reflect` question type should not use tap-to-answer; it should show a reveal button. The `.count` type needs a clearer number-entry UI.

*Reproduce across all museum sketch questions. Has screenshot.*

---

## 8. CLAUDE.md Violations — Forever Animations

**Status: 🔴 CRITICAL**

**CLAUDE.md rule:** *"Frame animations play ONCE, never loop. All Timer-based frame animations must play through once and stop."*

**29 `repeatForever` animation instances found across 16 files.** None of these are frame animations (those use Timer-based loops correctly), but the rule applies to all SwiftUI `.repeatForever` and SpriteKit `SKAction.repeatForever` uses — they run indefinitely, consuming CPU/GPU for the entire time the view is visible.

### SwiftUI `.repeatForever` — 27 instances

| File | Lines | Animation |
|---|---|---|
| `Views/MascotDialogueView.swift` | 143, 177, 187, 197, 207, 395, 632 | Bird float bounce + aurora glow |
| `Views/ForestMapView.swift` | 608, 794, 804, 814, 824 | Card float + aurora glow |
| `Views/MathVisualTemplates.swift` | 70, 219, 366, 757 | Math diagram pulse animations |
| `Views/KnowledgeCardsOverlay.swift` | 248 | Card float bounce |
| `Views/BirdChatOverlay.swift` | 341 | Bird float bounce |
| `Views/GradientSlopeVisual.swift` | 262 | Slope pulse |
| `Views/CardVisualView.swift` | 154 | Card glow |
| `Views/SketchTeachingView.swift` | 670 | Pulse |
| `Views/MaterialPuzzleView.swift` | 323 | Sparkle pulse |
| `Views/RomanRoadsInteractiveVisuals.swift` | 843 | Road animation |
| `Views/AqueductInteractiveVisuals.swift` | 723, 983 | Water flow |
| `Views/RomanBathsInteractiveVisuals.swift` | 632 | Steam/heat shimmer |
| `Views/PantheonInteractiveVisuals.swift` | 1601 | Light ray |

*Acceptable exception:* `Views/HintOverlayView.swift:530` uses `.repeatCount(4)` — limited repetition, not indefinite.

### SpriteKit `SKAction.repeatForever` — 2 instances

| File | Lines | Animation |
|---|---|---|
| `Views/SpriteKit/GoldsmithScene.swift` | 299, 639 | Station pulse + glow |

**Recommendation:** For idle/ambient animations (bird float, card glow, aurora), use `.repeatCount(N)` with a reasonable count (e.g., 3–5 cycles) or trigger the animation only once on appearance. For interactive animations (water flow in challenge views), limit to the duration of the challenge interaction.

---

## Appendix — Notable Code Quality Items (No Action Required)

These are good patterns observed during the audit:

- **BirdChatViewModel**: replaced 100ms polling with `withObservationTracking` — correct approach for `@Observable` state forwarding.
- **GameCenterManager**: wraps iOS 26 `GKGameActivity` in `Any` to avoid `@available` stored property violations — correct cross-version pattern.
- **HapticsManager**: proper `[weak self]` in engine stopped/reset handlers.
- **GenerationService**: session pool + prewarm pattern is architecturally sound.
- **MuseumSketchService**: disk cache + downsampling to 1024px max — good memory management.
- **AssetManager**: ODR tag constants are well-organized.

---

*Report generated: 2026-05-06. No source files were modified during this audit.*
