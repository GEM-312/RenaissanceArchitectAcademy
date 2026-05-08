# Weekly Code Health Report — 2026-05-08
**Project:** Renaissance Architect Academy  
**Checked by:** Claude Code (claude-sonnet-4-6)  
**Files read:** 178 Swift files across all directories (Models, Services, ViewModels, Views, SpriteKit, Sketching, Onboarding, StationMiniGames, Styles)

---

## TL;DR

**Status: YELLOW**

| Severity | Count |
|----------|-------|
| CRITICAL | 0 |
| WARNING  | 14 |
| INFO     | 8 |

No secrets in source, no build toolchain available in this environment to verify compilation, no `% frameCount` loop violations, no SpriteKit memory leaks. The main issues are hardcoded raw colors that belong in the theme system, and 5 pieces of TestFlight feedback that need triaging.

---

## CHECK 1 — Build Status

**Result: INCONCLUSIVE** — `xcodebuild` is not installed in this Linux environment. The project cannot be compiled here; run `Cmd+B` in Xcode to verify the build.

---

## CHECK 2 — Hardcoded Values

### CRITICAL — None found
No API keys, passwords, or secrets are hardcoded in any Swift file. `APIKeys.swift` is properly gitignored and referenced only through `WorkerClient.proxyToken`. Worker base URL (`https://raa-api.pollak.workers.dev`) is a non-secret domain — correct to hardcode.

---

### WARNING — Hardcoded Colors outside Theme System

**W-01 · GameSettings.swift:106–107** — Two private Color literals define dark/light card backgrounds but are not exposed as public tokens in `RenaissanceColors.swift`. Any view that needs "dark card background" cannot safely reference this.

```swift
// GameSettings.swift lines 106–107 (private — inaccessible to views)
private static let darkCardBackground = Color(red: 0.18, green: 0.16, blue: 0.13)
private static let lightCardBackground = Color(red: 0.93, green: 0.87, blue: 0.78)
```
**Fix:** Add these two tokens to `RenaissanceColors.swift`:
```swift
static let darkCardBg = Color(red: 0.18, green: 0.16, blue: 0.13)   // Dark mode card fill
static let lightCardBg = Color(red: 0.93, green: 0.87, blue: 0.78)  // Light mode card fill
```
Then change `GameSettings` private statics to reference them.

---

**W-02 · SettingsView.swift:50** — Dark theme preview swatch duplicates `GameSettings.darkCardBackground` inline instead of using the token.

```swift
// SettingsView.swift:50 — raw literal
? Color(red: 0.18, green: 0.16, blue: 0.13)
```
**Fix:** After W-01 is applied → `RenaissanceColors.darkCardBg`

---

**W-03 · CardVisualView.swift:212,275,344,416,528,605** — Six separate `let sepiaInk = Color(red: 0.29, 0.25, 0.21)` local variables redeclare a color that is already `RenaissanceColors.sepiaInk`.

**Fix:** Delete local `let sepiaInk` declarations. Import and use `RenaissanceColors.sepiaInk` directly in each location.

---

**W-04 · RenaissanceButton.swift:25** — `.padding(.vertical, 14)` has no matching `Spacing` token. The spacing scale goes `Spacing.sm=12` and `Spacing.md=16` — 14 falls between both.

**Fix:** Either round to `Spacing.md` (16) for consistency, or add `static let buttonV: CGFloat = 14` to the `Spacing` enum in `RenaissanceTheme.swift`.

---

**W-05 · RenaissanceButton.swift:132** — `.padding(.vertical, 10)` for `RenaissanceSecondaryButton` has no matching `Spacing` token.

**Fix:** Use `Spacing.xs` (8) or add `static let buttonSecondaryV: CGFloat = 10` to `Spacing`.

---

**W-06 · InteractiveVisualHelpers.swift:15** — `IVMaterialColors.stoneGray = Color(red: 0.65, 0.63, 0.60)` is a near-duplicate of `RenaissanceColors.stoneGray (0.639, 0.616, 0.576)`. The slight difference (≈ +0.01 across channels) appears unintentional.

**Fix:** Replace `IVMaterialColors.stoneGray` with `RenaissanceColors.stoneGray` across all interactive visual files, then remove the duplicate definition.

---

**W-07 · NotebookEntry.swift:126–129** — Stroke color palette uses raw `Color(red:)` literals that map almost exactly to existing tokens (floating-point rounding only):

| Case | Raw value | Existing token |
|------|-----------|----------------|
| `.yellow` | (1.0, 0.85, 0.3) | `candleGlow` (0.95, 0.85, 0.45) — close but not identical |
| `.sepia` | (0.29, 0.25, 0.21) | `sepiaInk` (0.290, 0.251, 0.208) — matches |
| `.red` | (0.80, 0.36, 0.36) | `errorRed` (0.804, 0.361, 0.361) — matches |
| `.blue` | (0.36, 0.56, 0.64) | `renaissanceBlue` (0.357, 0.561, 0.639) — matches |

**Fix:** Replace `.sepia`, `.red`, `.blue` with `RenaissanceColors.*` tokens. For `.yellow`, decide whether `candleGlow` or `highlightAmber` is correct, or add a dedicated `notebookYellow` token.

---

**W-08 · CraftedItem.swift:99, Material.swift:164, Tool.swift:126** — Icon fallback views use `.font(.system(size: size * 0.7))` / `.system(size: size * 0.75)`. These are emoji-only fallback renders — legitimate where no image asset exists, but they bypass the Renaissance font system.

**Fix (low priority):** These are acceptable as-is for emoji fallbacks. If you later add SF Symbol or Midjourney sprites for all items, remove the system font fallback.

---

### WARNING — Hardcoded Colors in Interactive Visuals (acknowledged art constants)

**W-09 · Views/*InteractiveVisuals*.swift** — 189 `Color(red:)` instances across 10 building-specific interactive visual files. These define material-specific art colors (travertine, basalt, brickwork, hemp rope, etc.) that have no meaningful theme token equivalents. They live inside `private let` or inline `Color(red:)` in drawing closures.

These are **art constants, not UI constants** — adding 50+ tokens to `RenaissanceColors.swift` for building-specific simulation colors would bloat the theme file. However, consolidating them into a single `IVMaterialColors` enum (which `InteractiveVisualHelpers.swift` already partially does) would be cleaner.

**Fix (medium priority):** Move the per-file `private let oakBrown`, `private let ironGray`, etc. into `IVMaterialColors` in `InteractiveVisualHelpers.swift` so all 10 visual files share the same material palette. Do not add these to `RenaissanceColors.swift`.

---

### INFO — Missing Tokens (additions recommended)

**I-01 · RenaissanceColors.swift** — Missing `darkCardBg` and `lightCardBg` (see W-01).  
**I-02 · RenaissanceTheme.swift Spacing enum** — Missing `buttonV` (14pt) and `buttonSecondaryV` (10pt) padding tokens (see W-04, W-05).

---

## CHECK 3 — Dead Code

**W-10 · ContentView.swift:73** — Onboarding skip check is commented out (known from CLAUDE.md — intentional for development). This is a tracked TODO, not an accident.
```swift
// TODO: Re-enable skip after onboarding is finalized:
// if onboardingState.hasCompletedOnboarding { showingMainMenu = false; return }
```
**Action:** Re-enable once onboarding is finalized (see CLAUDE.md Next Steps).

---

**W-11 · SubscriptionManager.swift:39–60** — StoreKit 2 purchase + restore flows are mock stubs. All real StoreKit calls are commented out with `// TODO: StoreKit 2`.

**Action:** Real StoreKit 2 wiring is a known upcoming task. No action needed now beyond tracking.

---

**I-03 · Comment blocks ≥ 5 lines** — 75 comment blocks found across the codebase. Most are legitimate teaching moments (GameTools.swift, GeneratedContent.swift), file headers, or section separators. None are obviously dead code — the multi-line comment blocks are documentation patterns established in CLAUDE.md.

---

**I-04 · Amellina + GreatVibes fonts** — Two fonts (`Amellina.ttf`, `GreatVibes-Regular.ttf`) are registered in `RenaissanceArchitectAcademyApp.swift` and `Amellina` is actively used in `MainMenuView.swift` for the tagline. Neither font is listed in CLAUDE.md's font registry.

**Action:** Add both to the CLAUDE.md font registry so future sessions know they exist.

---

## CHECK 4 — Memory & Performance

**Result: CLEAN**

- **`% frameCount` loops:** Zero found. All frame animations use a stop-at-last-frame pattern as required by CLAUDE.md.
- **SpriteKit `[weak self]`:** All SKScene subclasses (WorkshopScene, CraftingRoomScene, GoldsmithScene, ForestScene, CityScene) correctly use `[weak self]` in closure callbacks. The `DispatchQueue.main.asyncAfter` at `ForestScene.swift:1145` is safely nested inside an outer `[weak self]` closure — `self?` is already weakly captured.
- **SoundManager timers:** `fadeIn`/`fadeOut` closures in `SoundManager.swift` capture local `player` variables (not `self`) — no retain cycle.
- **`Timer.publish` anti-pattern:** Not used anywhere. All timers use `Timer.scheduledTimer`.
- **ForEach without `id:`:** All 28 occurrences iterate types that conform to `Identifiable` (`BuildingPlot`, `KnowledgeCard`, `ChatMessage`, `Material`, `Tool`, `CraftedItem`, `KeywordPair`, `ScrambleTile`, `FishingBubble`, `FallingFlorin`, `WolframGeometryResult`). All are safe.

---

## CHECK 5 — pbxproj Consistency

**Result: CLEAN**

- 180 Swift filenames in `project.pbxproj` vs 178 files on disk.
- Missing from disk: `APIKeys.swift` (expected — gitignored), `sourcecode.swift` (pbxproj artifact string, not a real file reference).
- No Swift files on disk are missing from the pbxproj.

---

## CHECK 6 — Missing Assets

**Result: CLEAN**

All 9 named image asset references found in Swift code (`BackgroundMain`, `BirdFrame00`, `BookBackground`, `ButtonBackground`, `InteriorFurnace`, `InteriorPigmentTable`, `InteriorShelf`, `InteriorWorkbench`, `WorkshopBackground`) have corresponding imagesets in `Assets.xcassets`. Dynamic frame references (`\(framePrefix)\(String(format:...))`) resolve at runtime against the frame sequences already in the catalog.

**I-05 · Fonts on disk vs CLAUDE.md registry:** Two fonts present in `Fonts/` are not listed in CLAUDE.md:
- `Amellina.ttf` — actively used (`MainMenuView.swift:61`)
- `GreatVibes-Regular.ttf` — registered in App.swift but no usage found in Swift files

**Action:** Add Amellina to CLAUDE.md font list. Verify whether GreatVibes is intended for future use or can be removed from registration/`Fonts/`.

---

## CHECK 7 — TestFlight Feedback

**5 items from `/home/user/RenaissanceArchitectAcademy/feedback/latest_feedback.json`**  
Latest build: version 3 (uploaded 2026-04-17). 4 testers with app installed.

| # | Tester | Build | Summary | Priority |
|---|--------|-------|---------|----------|
| 1 | Ray Garmon | 2 | "I'm tapping on the gold objects instead of sifting. One of the golds I have to tap was brown." — River mini-game gold nuggets have a brown tint making them hard to identify as "gold" | HIGH |
| 2 | Ray Garmon | 2 | "Not related with question. It asked why and I had to tap picture." — Knowledge card question type mismatch: text question shown but interaction is tap-the-image | HIGH |
| 3 | Brianna Walker | 2 | iPad horizontal: scale down "Choose your apprentice" screen; no back button in (All/Rome/Ren/Tests) tabs; 2 different animations after character select | MEDIUM |
| 4 | Brianna Walker | 2 | iPhone vertical: minor scaling + text adjustments; bird companion appears over text instead of flying in from off-screen | MEDIUM |
| 5 | Marina Pollak | 2 | "Every card asking to tap somewhere on the picture but some questions and interactions don't make much sense." — confirms feedback #2 | HIGH |

**3 HIGH priority items all relate to the same root cause:** knowledge card tap-target interaction is being used for question types that don't match (text/why questions expecting a tap-on-image response). Review `KnowledgeCardsOverlay.swift` activity routing logic to ensure `CardActivityType` is correctly matched to its render mode.

---

## Clean Scans

| Check | Result |
|-------|--------|
| API keys / secrets in source | CLEAN |
| `% frameCount` timer loop violations | CLEAN |
| SpriteKit `[weak self]` retain cycles | CLEAN |
| Named image assets missing from catalog | CLEAN |
| Swift files on disk missing from pbxproj | CLEAN |
| Mulish (deprecated) font usage | CLEAN — zero references |
| Hardcoded base URL `raa-api.pollak.workers.dev` | EXPECTED — non-secret worker domain |
| Wolfram/Claude proxy token in source | CLEAN — `APIKeys.swift` only (gitignored) |

---

## Missing Tokens Summary

| Token | Value | Suggested name | File to add |
|-------|-------|----------------|-------------|
| Dark mode card background | `Color(red: 0.18, green: 0.16, blue: 0.13)` | `darkCardBg` | `RenaissanceColors.swift` |
| Light mode card background (alt) | `Color(red: 0.93, green: 0.87, blue: 0.78)` | `lightCardBg` | `RenaissanceColors.swift` |
| Button vertical padding | `14` pt | `Spacing.buttonV` | `RenaissanceTheme.swift` |
| Secondary button vertical padding | `10` pt | `Spacing.buttonSecondaryV` | `RenaissanceTheme.swift` |

---

*Report generated 2026-05-08 by Claude Code. All checks performed via static analysis and file inspection. Build verification requires Xcode on macOS.*
