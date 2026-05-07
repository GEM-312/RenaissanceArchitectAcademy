# Weekly Health Check — 2026-05-07

**Project:** Renaissance Architect Academy  
**Developer:** Marina Pollak  
**Auditor:** Claude (automated — full codebase read before analysis)  
**Swift files read:** 142 of 142 (all files under `RenaissanceArchitectAcademy/`)  
**Theme files read:** `RenaissanceColors.swift`, `RenaissanceTheme.swift`, `RenaissanceButton.swift`, `GameSceneKitView.swift`, `GameSpriteView.swift`  
**Date:** 2026-05-07

---

## 1. Files Read (Step 0 Confirmation)

142 Swift files read in full. Theme/style files confirmed read:

| File | Purpose |
|---|---|
| `Services/Styles/RenaissanceColors.swift` | Color token palette + border/dimming extensions |
| `Services/Styles/RenaissanceTheme.swift` | Font tokens (RenaissanceFont), Spacing, CornerRadius, Shadow, ViewModifiers |
| `Services/Styles/RenaissanceButton.swift` | Button components |
| `Services/Styles/GameSpriteView.swift` | SpriteKit UIViewRepresentable wrapper |
| `Services/Styles/GameSceneKitView.swift` | SceneKit UIViewRepresentable wrapper |

---

## 2. TL;DR

🟡 **YELLOW** — 0 CRITICAL · 5 WARNING · 5 INFO

No security issues, no crashes. Three persistent issues carried over from the 2026-05-06 report remain unresolved: station sprite name mismatch, hardcoded NSColor/UIColor for parchment in GameSceneKitView, and hardcoded Font.custom in core style files. Systemic font token debt continues at 447 inline `.custom(...)` calls (down from 941 counted last week, partly due to expanded token set in RenaissanceTheme.swift).

---

## 3. CRITICAL

*None found this week.*

> **Security (API Keys):** `APIKeys.swift` is correctly gitignored and absent from the checkout. `WorkerClient.swift` references `APIKeys.proxyToken` without ever inlining the value. Cloudflare Worker (`cloudflare-worker/src/index.ts`) reads all credentials from environment variables (`env.ANTHROPIC_API_KEY`, `env.WOLFRAM_APP_ID`, etc.) — no hardcoded secrets anywhere in the codebase. ✅

---

## 4. WARNING

### W-1 · 8 Station Sprite Assets Missing — `ResourceNode.swift:47–54`

All 8 station sprites referenced in code are absent from `Assets.xcassets`. SpriteKit returns a placeholder texture (gray/white box) when `SKTexture(imageNamed:)` gets a nonexistent name — no crash, but wrong visuals.

| Code reference (ResourceNode.swift) | Asset exists in catalog? |
|---|---|
| `"StationQuarry"` | ✗ Missing |
| `"StationRiver"` | ✗ Missing |
| `"StationVolcano"` | ✗ Missing |
| `"StationClayPit"` | ✗ Missing |
| `"StationMine"` | ✗ Missing |
| `"StationForest"` | ✗ Missing |
| `"StationMarket"` | ✗ Missing — but `Market.imageset` **does** exist; likely a name mismatch |
| `"StationCraftingRoom"` | ✗ Missing |

**Note:** CLAUDE.md marks "Add station sprites for remaining stations" as ✅ DONE Feb 22 2026, but the assets are not in this branch. Either they were never added or were removed. The `Market.imageset` → `StationMarket` name mismatch is a likely bug.

**Fix:** Either (a) rename `Market.imageset` → `StationMarket.imageset` in Xcode's asset catalog, or (b) change `ResourceNode.swift:54` to `return "Market"`. Add the remaining 7 missing imagesets.

---

### W-2 · Hardcoded Platform Color in `GameSceneKitView.swift` — Lines 23 & 67

The parchment background color is hardcoded as a platform-specific literal instead of using `RenaissanceColors`:

```swift
// Line 23 (macOS)
scnView.backgroundColor = NSColor(red: 0.961, green: 0.902, blue: 0.827, alpha: 1.0)

// Line 67 (iOS)
scnView.backgroundColor = UIColor(red: 0.961, green: 0.902, blue: 0.827, alpha: 1.0)
```

**Fix:** Use the `PlatformColor(RenaissanceColors.parchment)` pattern already established in `CityScene.swift` and `WorkshopScene.swift`. Replace both lines with:

```swift
scnView.backgroundColor = PlatformColor(RenaissanceColors.parchment)
```

`PlatformColor` is already defined as `typealias PlatformColor = NSColor` / `UIColor` in `CityScene.swift`.

---

### W-3 · Hardcoded Font in `RenaissanceButton.swift` — Lines 19 & 130

The core `RenaissanceButton` and `RenaissanceSecondaryButton` components (shared across the entire app) bypass the `RenaissanceFont` token system:

```swift
// Line 19 — RenaissanceButton
.font(.custom("EBGaramond-Regular", size: 20, relativeTo: .body))
// Should use → RenaissanceFont.buttonLarge  (EBGaramond-Regular, 20pt ✓)

// Line 130 — RenaissanceSecondaryButton
.font(.custom("EBGaramond-Regular", size: 18, relativeTo: .body))
// Should use → RenaissanceFont.button  (EBGaramond-SemiBold, 18pt)
// NOTE: weight differs (Regular vs SemiBold) — if intentional, add RenaissanceFont.buttonRegular = Font.custom("EBGaramond-Regular", size: 18)
```

---

### W-4 · Hardcoded Font in `AssetManager.swift` — Lines 186, 191, 199

The on-demand resource loading overlay (`ODRLoadingView`) hardcodes three font calls that have exact tokens in `RenaissanceTheme.swift`:

```swift
// Line 186
.font(.custom("EBGaramond-Italic", size: 16))     → RenaissanceFont.bodyItalic
// Line 191
.font(.custom("EBGaramond-Regular", size: 13))    → RenaissanceFont.caption
// Line 199
.font(.custom("EBGaramond-SemiBold", size: 14))   → RenaissanceFont.footnoteBold
```

---

### W-5 · Unresolved TestFlight Feedback (Build 2 · 5 Items)

All feedback was submitted against build 2 (2026-04-03). Build 3 (2026-04-17) is the latest. Status unknown — none of these appear to have a corresponding git commit message addressing them.

| Tester | Comment | Likely root cause |
|---|---|---|
| Ray Garmon | "I'm tapping on the gold objects instead of sifting. One of the golds I have to tap was brown." | RiverMiniGame gold/brown color contrast issue |
| Ray Garmon | "Not related with question. It asked why and I had to tap picture." | Knowledge card interactive visual doesn't match question type |
| Brianna Walker | "iPad horizontal view — scale down 'Choose your apprentice' screen" | `CharacterSelectView` responsive layout |
| Brianna Walker | "iPhone vertical — bird companion flies over the text" | `StoryNarrativeView` bird entrance z-order |
| Pollak Marina | "Every card asking to tap somewhere on the picture but some questions don't make sense." | Card interactive visual content mismatch |

---

## 5. INFO

### I-1 · Inline CornerRadius in `RenaissanceButton.swift:27`

```swift
RoundedRectangle(cornerRadius: 20)  // → CornerRadius.xl (= 20)
```

### I-2 · Spacing Gap — `RenaissanceButton.swift:24`

`.padding(.vertical, 14)` has no exact `Spacing` token (nearest: `Spacing.sm = 12`, `Spacing.lg = 20`). If this value is intentional, add `Spacing.buttonV: CGFloat = 14` to `RenaissanceTheme.swift`.

### I-3 · Mulish Font Registered but No Longer Used

`RenaissanceArchitectAcademyApp.swift` does not register Mulish (confirmed — registration list is clean). However, 9 Mulish `.ttf` files remain in the `Fonts/` directory from before the EBGaramond migration (CLAUDE.md: "replaced by EBGaramond Feb 2026"). They add ~300 KB to the app bundle without serving any purpose. Safe to delete from Xcode's file navigator.

### I-4 · `repeatForever` Ambient Animations — 28 instances across 12 files

28 SwiftUI `.repeatForever(autoreverses:)` calls found in: `ForestMapView`, `MascotDialogueView`, `KnowledgeCardsOverlay`, `BirdChatOverlay`, `RomanRoadsInteractiveVisuals`, `AqueductInteractiveVisuals`, `GradientSlopeVisual`, `SketchTeachingView`, `MathVisualTemplates`, `CardVisualView`, `RomanBathsInteractiveVisuals`, `PantheonInteractiveVisuals`.

All uses are ambient visual effects (aurora glow, water flow, character breathing, floating elements) — **not** timer-based sprite frame animations. CLAUDE.md's "play ONCE" rule targets Timer-based `% frameCount` frame animations only; zero of those were found. The `repeatForever` uses are appropriate for continuously-cycling ambient effects.

One borderline case: `MaterialPuzzleView.swift:323` — pulses a UI element. If this pulse is intended to draw attention to an action button, consider stopping it after user interaction begins.

### I-5 · Systemic Font Token Debt — 447 Inline `.custom(...)` Calls in Views

447 hardcoded `.custom("EBGaramond…", size:)` / `.custom("Cinzel…", size:)` calls remain across all View files (down from 941 in the 2026-05-06 report). Most are in the `*InteractiveVisuals.swift` files using adaptive sizing (`isLargeScreen ? X : Y`). Static adaptive sizing cannot always use fixed-size tokens, but the non-adaptive calls (fixed size, single platform) should migrate to tokens as part of the ongoing cleanup. This is a long-tail issue, not blocking.

---

## 6. Missing Tokens

| Value | Location | Recommended fix |
|---|---|---|
| `CGFloat(14)` as button vertical padding | `RenaissanceButton.swift:24` | Add `Spacing.buttonV: CGFloat = 14` to `RenaissanceTheme.swift` |
| `PlatformColor` for parchment | `GameSceneKitView.swift:23,67` | Use existing `PlatformColor(RenaissanceColors.parchment)` pattern (no new token needed) |
| `EBGaramond-Regular, 18pt` (button variant, Regular weight) | `RenaissanceButton.swift:130` | Determine if weight difference is intentional; if yes, add `RenaissanceFont.buttonRegular = Font.custom("EBGaramond-Regular", size: 18, relativeTo: .body)` |

---

## 7. Clean Scans

The following areas were reviewed and found clean:

- **Security / Secrets** — No API keys, tokens, or credentials hardcoded anywhere in Swift source or committed config files. ✅
- **pbxproj consistency** — All 142 Swift files tracked. Only `APIKeys.swift` is in pbxproj but absent from disk (expected — gitignored). No orphaned Swift files on disk missing from pbxproj. UUID cross-references confirmed normal (not duplicate IDs). ✅
- **SwiftUI Image() asset coverage** — All 8 `Image("…")` SwiftUI calls (`BackgroundMain`, `BirdFrame00`, `BookBackground`, `ButtonBackground`, `InteriorFurnace`, `InteriorPigmentTable`, `InteriorShelf`, `InteriorWorkbench`) have matching imagesets in the catalog. ✅
- **SpriteKit texture atlas** — `BirdFlySit.spriteatlas` folder properly exists in `Assets.xcassets` for `MascotNode.swift:130` `SKTextureAtlas(named: "BirdFlySit")` call. ✅
- **Font files on disk** — All fonts registered in `RenaissanceArchitectAcademyApp.swift` have corresponding `.ttf` files in `Fonts/`. ✅
- **Timer lifecycle** — All 19 `Timer.scheduledTimer` instances properly invalidated: via `timer.invalidate()` within the closure on completion, via `?.invalidate()` on view disappear, or both. No runaway timers found. ✅
- **`[weak self]` in SpriteKit closures** — All SKAction `run {}` callbacks, `DispatchQueue.main.asyncAfter` closures, and `editorMode.onToggle` callbacks in `CityScene.swift`, `WorkshopScene.swift`, `ForestScene.swift`, `GoldsmithScene.swift` use `[weak self]`. No retain cycles found. ✅
- **`% frameCount` loop pattern** — Zero instances found. All Timer-based sprite animations stop on the last frame per CLAUDE.md rule. ✅
- **ForEach id safety** — All `ForEach` calls iterate over `Identifiable` types (Building, Achievement, ScienceMastery, KnowledgeCard, etc.) or use explicit `.enumerated()` / `Array(...)` with `id: \.offset`. No raw String/Int arrays iterated without id. ✅
- **No dead code blocks** — No 5+ line commented-out code blocks found in Views or Services. ✅

---

## 8. Build Status

**SKIPPED** — `xcodebuild` not available in this Linux audit environment.

Last known state: TestFlight build v3 uploaded 2026-04-17, status `VALID`. No build errors since then based on git history.

Warning count: N/A (build not run).

---

*Generated 2026-05-07 by automated health check. All 142 .swift files were read before analysis.*
