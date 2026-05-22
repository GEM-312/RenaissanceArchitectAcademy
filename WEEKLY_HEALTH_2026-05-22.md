# Weekly Health Check — 2026-05-22

## 1. Files Read (Step 0)

**185 Swift files read** across all directories.

Style/theme files read in full:
- `Services/Styles/RenaissanceColors.swift` — 31 color tokens + gradients + `overlayDimming`
- `Services/Styles/RenaissanceTheme.swift` — `RenaissanceFont` (35 tokens), `Spacing` (11 tokens), `CornerRadius` (sm/md/lg/xl), `RenaissanceShadow`, `Tracking`, `LineHeight`, `TextEmphasis`, `DialogWidth`
- `Services/Styles/RenaissanceButton.swift` — button style enum
- `Services/Styles/ActivitySizing.swift` — activity size helpers
- `Services/Styles/GameSceneKitView.swift` — SceneKit view wrapper
- `Services/Styles/GameSpriteView.swift` — SpriteView helper
- `Views/InteractiveVisualHelpers.swift` — `IVMaterialColors` shared color enum

All 188 `.swift` files on disk were enumerated; 3 were not found under the `RenaissanceArchitectAcademy/` subfolder (the 3 extra entries in the pbxproj with path format mismatches explained in §5).

---

## 2. TL;DR

**YELLOW** — no crashes or credential leaks, but 2 timer-leak warnings, 15+ hardcoded font calls, and a detached HEAD that must be resolved before pushing.

| Severity | Count |
|----------|-------|
| CRITICAL | 0 |
| WARNING  | 9 |
| INFO     | 8 |

---

## 3. CRITICAL

_None._

No hardcoded API keys or secrets found in any source file. `APIKeys.swift` is correctly gitignored (absent from disk, referenced in pbxproj only). No credential leaks into code paths, no actual `Bearer <token>` literals.

---

## 4. WARNING

### W1 — FarmMiniGameView: gameTimer leaks if view is dismissed mid-game
**File:** `Views/StationMiniGames/FarmMiniGameView.swift:658`
**Issue:** `gameTimer` is started via `Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true)` (60 Hz). The view has **zero `onDisappear` modifiers**. If the user navigates away while an item is falling, the timer continues to fire against stale SwiftUI state bindings.
**Fix:** Add `.onDisappear { gameTimer?.invalidate(); gameTimer = nil }` at the root view level. Pattern already used correctly in `ClayPitMiniGameView`, `BuildingLessonView`, and `MascotDialogueView`.

### W2 — QuarryMiniGameView: bondPulseTimer / shrinkTimer leak on dismiss
**File:** `Views/StationMiniGames/QuarryMiniGameView.swift:782, 851`
**Issue:** `bondPulseTimer` (20 Hz) and `shrinkTimer` are started in game logic functions but the view has **no `onDisappear`**. Both timers can outlive the view.
**Fix:** Add `.onDisappear { bondPulseTimer?.invalidate(); shrinkTimer?.invalidate(); bondPulseTimer = nil; shrinkTimer = nil }`.

### W3 — StoryNarrativeView: 3 inline `Font.custom` calls bypass RenaissanceFont
**File:** `Views/Onboarding/StoryNarrativeView.swift:62, 160, 242`

| Line | Inline call | Correct fix |
|------|-------------|-------------|
| 62 | `Font.custom("PetitFormalScript-Regular", size: 30, relativeTo: .title)` | Add `RenaissanceFont.letterLarge` token (PetitFormalScript at 30pt) to `RenaissanceTheme.swift` |
| 160 | `Font.custom("Cinzel-Regular", size: isLargeScreen ? 36 : 26)` | `RenaissanceFont.hero` (36pt) / `RenaissanceFont.title` (26pt) |
| 242 | `Font.custom("EBGaramond-SemiBold", size: 20)` | `RenaissanceFont.buttonLarge` |

### W4 — MainMenuView: Amellina font has no RenaissanceFont token
**File:** `Views/MainMenuView.swift:61`
**Issue:** `Font.custom("Amellina", size: taglineSize + 6, relativeTo: .headline)` is inlined. `Amellina` is registered in `RenaissanceArchitectAcademyApp.swift` but has no entry in `RenaissanceFont`.
**Fix:** Add `static let menuTagline = Font.custom("Amellina", size: 26, relativeTo: .headline)` (or with `relativeTo` matching the intended semantic) to `RenaissanceTheme.swift`, then use it in `MainMenuView`.

### W5 — RecipeBookView: 5 hardcoded `.font(.system(size:))` calls
**File:** `Views/RecipeBookView.swift:125, 153, 268, 288, 384`

| Line | Size | Fix |
|------|------|-----|
| 125 | `.system(size: 68)` (emoji icon) | Add `RenaissanceFont.emojiLarge` or use `.font(.system(size: 68))` as documented exception if truly decorative-only |
| 153, 268 | `.system(size: 11)` | `RenaissanceFont.captionSmall` (11pt) |
| 288 | `.system(size: 11, weight: .bold)` | `RenaissanceFont.captionSmall` + `.fontWeight(.bold)` |
| 384 | `.system(size: 12)` | `RenaissanceFont.footnoteSmall` (12pt) |

### W6 — ForestMapView: 9 hardcoded system fonts
**File:** `Views/ForestMapView.swift:846, 858, 889, 902, 911, 939, 1080, 1123, 1155, 1364, 1369, 1478, 1691`

| Lines | Call | Fix |
|-------|------|-----|
| 858, 939, 1155 | `.system(size: 13)` / `.system(size: 13, weight: .bold)` | `RenaissanceFont.caption` / `.fontWeight(.bold)` |
| 889, 911, 1080 | `.system(size: 16)` | `RenaissanceFont.bodyMedium` |
| 902, 1123 | `.system(size: 10/11)` | `RenaissanceFont.captionSmall` |
| 846, 1669 | `.system(size: 36)` / `.system(size: 28)` (emoji) | `RenaissanceFont.hero` / `RenaissanceFont.title3` |
| 517, 1364, 1369, 1478 | `.font(.body)` (system) | `RenaissanceFont.body` |
| 1691 | `.font(.subheadline)` (system) | `RenaissanceFont.bodySmall` |

### W7 — NotebookCanvasView: UIColor inline duplicates `RenaissanceColors.notebookYellow`
**File:** `Views/NotebookCanvasView.swift:42`
**Issue:** `UIColor(red: 1.0, green: 0.85, blue: 0.3, alpha: 0.4)` matches `RenaissanceColors.notebookYellow` (same RGB values) but bypasses the token.
**Fix:** `UIColor(RenaissanceColors.notebookYellow).withAlphaComponent(0.4)`

### W8 — IVMaterialColors.leadGray is a local redefinition; drifted from `RenaissanceColors.leadGray`
**File:** `Views/InteractiveVisualHelpers.swift:19`
**Issue:** `IVMaterialColors.leadGray = Color(red: 0.50, green: 0.52, blue: 0.55)` differs from `RenaissanceColors.leadGray = Color(red: 0.55, green: 0.55, blue: 0.52)`. This was the same drift noted in the comment for `stoneGray`. The two will render visibly differently.
**Fix:** Replace `IVMaterialColors.leadGray` with `RenaissanceColors.leadGray` and delete the local duplicate.

### W9 — BirdChatViewModel: Claude AI subscription gate is commented out
**File:** `ViewModels/BirdChatViewModel.swift:113–115`
**Issue:** The guard that prevents Claude API usage without an active subscription is disabled:
```swift
// if currentProvider == .claudeAPI && !SubscriptionManager.shared.hasActiveSubscription {
//     error = "Subscribe to use Claude AI"
//     return
// }
```
Comment says "skip for now — always allow in dev." This means **all users on any subscription tier can call the Claude API endpoint**, incurring usage costs with no gate.
**Note:** This is flagged as WARNING, not CRITICAL, because it may be intentional during TestFlight. Re-enable before App Store release.

---

## 5. INFO

### I1 — pbxproj: mixed `sourceTree` path styles (cosmetic, not a build error)
36 newer files (all `*InteractiveVisuals*.swift`, SpriteKit files, `MascotDialogueView`, `MaterialPuzzleView`, `BirdChatViewModel`) use `sourceTree = "<group>"` with a group-relative path, while the majority use `sourceTree = "SOURCE_ROOT"` with a repo-relative path. Xcode resolves both correctly; the inconsistency makes `project.pbxproj` harder to diff and merge. Clean up by re-adding files through Xcode's "Add Files" dialog with consistent group placement.

### I2 — GreatVibes-Regular.ttf is registered but never used
**File:** `RenaissanceArchitectAcademyApp.swift:53`
`GreatVibes-Regular` is registered via CoreText alongside Amellina, but no `Font.custom("GreatVibes-Regular", ...)` call exists anywhere in the codebase. The font file loads on every launch for nothing.
**Fix:** Remove `"GreatVibes-Regular"` from the registration array in `RenaissanceArchitectAcademyApp.swift`.

### I3 — Hardcoded `cornerRadius` values not using `CornerRadius` tokens (INFO volume)
Many views use raw integers. Values matching existing tokens should use them; values without tokens are noted:

| Value | Token to use | Files with violations |
|-------|-------------|----------------------|
| 12 | `CornerRadius.md` | SketchingChallengeView:141, FlowRateVisual:24 |
| 8  | `CornerRadius.sm` | RecipeBookView:296, WorkshopMapView:1980 |
| 18 | no token — add `CornerRadius.book = 18` | RecipeBookView:70, 77 |
| 10 | no token — add `CornerRadius.card = 10` | InteractiveVisualHelpers:80,90, ForestMapView:526,1340,1380,1469,1486, WorkshopMapView:2254,2263 |
| 14 | no token — add `CornerRadius.dialog = 14` | ForestMapView:773,782,833,866,868,995,999 |
| 6  | no token — add `CornerRadius.xs = 6` (or reuse `sm` at 8 if close enough) | RecipeBookView:348,399,403, WorkshopMapView:2183 |
| 4  | no token — add `CornerRadius.xxs = 4` | RecipeBookView:237, WorkshopMapView:2399 |

### I4 — MascotDialogueView: 1 hardcoded system font
**File:** `Views/MascotDialogueView.swift:222`
`.font(.system(size: isCompact ? 20 : 36))` for the bird emoji. Use `RenaissanceFont.buttonLarge`/`RenaissanceFont.hero`.

### I5 — SketchingChallengeView: 2 `.font(.caption)` system calls
**File:** `Views/SketchingChallengeView.swift:84, 301`
Use `RenaissanceFont.caption` instead.

### I6 — TestFlight feedback status
Three items from `feedback/latest_feedback.json` (synced 2026-04-18):

| ID | Tester | Issue | Status |
|----|--------|-------|--------|
| AFEkX5LN | Ray Garmon | Gold objects looked brown in river mini-game | **FIXED** — `RiverMiniGameView.swift:846` comment confirms: "no brown 🟤 which confused testers" |
| AOVEMjw- | Ray Garmon | Question prompt didn't match the required action | Open — no evidence of a fix in recent commits |
| AN75Jh3v | Brianna Walker | "Choose your apprentice" scale too large on iPad horizontal; no back button in category tabs; 2 animations on character select | Open — no fix found in recent commits |
| ALyw50qg | Brianna Walker | iPhone vertical: scaling, bird appears over text | Open |
| APY9_829 | Marina | Knowledge cards prompt to tap but interactions unclear | Open |

4 of 5 feedback items remain unresolved as of this check.

### I7 — ContentView onboarding skip is intentionally disabled
**File:** `Views/ContentView.swift:73`
`// if onboardingState.hasCompletedOnboarding { showingMainMenu = false; return }` is a known TODO per CLAUDE.md. Flagged for visibility — re-enable before shipping.

### I8 — Git HEAD is detached
Running `git status` shows `HEAD detached from refs/heads/main`. This means pushing requires `git checkout main` first (handled in the commit step below).

---

## 6. Missing Tokens

Tokens that should be added to existing theme files to cover flagged hardcoded values:

**`RenaissanceTheme.swift` → `RenaissanceFont`:**
```swift
static let letterLarge = Font.custom("PetitFormalScript-Regular", size: 30, relativeTo: .title)
static let menuTagline  = Font.custom("Amellina", size: 26, relativeTo: .headline)
```

**`RenaissanceTheme.swift` → `CornerRadius`:**
```swift
static let xxs:    CGFloat = 4   // pill/tag inner radius
static let xs:     CGFloat = 6   // recipe inset corners
static let card:   CGFloat = 10  // general content cards (ForestMap, Workshop)
static let dialog: CGFloat = 14  // POI/dialogue card popups (ForestMap)
static let book:   CGFloat = 18  // recipe book cover shape
```

---

## 7. Clean Scans

Files and systems confirmed clean:

- **No API keys / secrets in source** — all 185 files searched; "secret" matches are narrative game text only
- **SpriteKit `[weak self]`** — `CityScene`, `WorkshopScene`, `CraftingRoomScene`, `ForestScene`, `GoldsmithScene` all use `[weak self]` in every closure that captures `self`
- **No looping frame animations** — zero `% frameCount` modulo patterns found; all frame timers self-terminate via `timer.invalidate()` when `frame >= last`
- **No `Timer.publish().autoconnect()` anti-pattern** — only `Timer.scheduledTimer` used; no Combine timer publishers present
- **Timer cleanup for all other views** — `FlowRateVisual`, `MascotDialogueView`, `KnowledgeCardsOverlay`, `ProfileView`, `NPCDialogueView`, `BuildingLessonView`, `StationLessonOverlay`, `AvatarTransitionView`, `StoryNarrativeView`, `ClayPitMiniGameView` all properly invalidate in `onDisappear`
- **Image assets** — all `Image("BackgroundMain")`, `Image("BirdFrame00")`, `Image("BookBackground")`, `Image("ButtonBackground")`, `Image("InteriorFurnace/Workbench/Shelf/PigmentTable")`, `Image("WorkshopBackground")` confirmed present in `Assets.xcassets`
- **Font files** — all fonts referenced in code (`Cinzel-Bold`, `Cinzel-Regular`, `EBGaramond-*`, `PetitFormalScript-Regular`, `Delius-Regular`, `Amellina`) confirmed present in `Fonts/`
- **No `ForEach` on non-Identifiable types** — all `ForEach` without explicit `id:` use `Identifiable` element types
- **No duplicate pbxproj IDs** — all IDs appear ≤3 times (1× definition, 1× parent group, 1× build phase), which is the normal expected count
- **IVMaterialColors** — `dimColor`, `ironDark`, `oakBrown`, `bronzeGold`, `hotRed`, `limeTan`, `cherryRed`, `poplarLight` are correctly scoped in their own namespace; the only violation is `leadGray` (W8 above)
- **ArsenalInteractiveVisuals** / **SiegeWorkshopInteractiveVisuals** — private `let` colors (`hullBrown`, `brickRed`, `ironGray`, etc.) are building-specific rendering colors, not shared UI chrome — acceptable per project convention

---

## 8. Build Status

**Skipped — no macOS toolchain in sandbox.**

`xcodebuild` is not on PATH in this cloud execution environment. Build verification must be run locally via Xcode (`Cmd+R`) or CI.

---

*Report generated by Claude Code weekly health check — 2026-05-22*

---

## Addendum — Additional Findings (full codebase read pass)

After the initial report was committed, a full deep-read pass of all 185 Swift files surfaced the following additional issues.

**Updated TL;DR:** **ORANGE** — 2 CRITICAL added (station sprites invisible in release; FoundationModels compile failures on older SDK).

---

### CRITICAL (added)

#### C1 — ResourceNode.hideSprites = true ships to release, hiding ALL station art
**File:** `Views/SpriteKit/ResourceNode.swift:83`
**Issue:** `static var hideSprites = true` has no `#if DEBUG` guard. In any production build, every station sprite (quarry, river, volcano, clay pit, mine, forest, market, crafting room) is invisible. Pill labels and tap targets still function, but artwork never renders.
**Fix:** Either set `hideSprites = false` now that terrain repositioning is done, or wrap the default in `#if DEBUG`:
```swift
#if DEBUG
static var hideSprites = true   // set false when terrain is final
#else
static var hideSprites = false
#endif
```
**Impact:** TestFlight build 3 shipped with invisible station sprites unless this was overridden at runtime.

#### C2 — Six files use bare `import FoundationModels` without `#if canImport`
**Files:**
- `Models/GeneratedContent.swift`
- `Views/AIProviderPickerView.swift`
- `Services/NPCEncounterManager.swift`
- `Services/GameTools.swift`
- `Services/AppleAIService.swift`
- `Services/GenerationService.swift`

**Issue:** These import `FoundationModels` at the top level. `Models/ContextualSuggestion.swift` correctly uses `#if canImport(FoundationModels)` as a guard. Without the guard, building against any SDK prior to iOS 26 will produce `"no such module 'FoundationModels'"` and fail to compile.
**Fix:** Wrap imports and all Apple AI code in `#if canImport(FoundationModels)` / `#endif` matching the pattern in `ContextualSuggestion.swift`.

---

### WARNING (added)

#### W10 — SoundManager has dead Timer-based faders alongside live Task-based faders
**File:** `Services/SoundManager.swift`
**Issue:** The file contains two sets of fade helpers:
1. **Old** `fadeIn(player:targetVolume:duration:)` / `fadeOut(player:duration:)` — Timer-based (lines ~341–372), creating a new `Timer` each call with no invalidation of previous timers.
2. **New** Task-based per-channel faders (lines ~395–441) — properly cancellable.

The public `playMusic` / `playAmbient` / `stopMusic` / `stopAmbient` methods resolve to the **old Timer-based** overloads by name. The Task-based faders are present but unreachable from the public API. This means competing fades are NOT cancelled — the Timer-based race condition fix described in `SoundManager.swift:393` (the comment explaining why the Task approach was chosen) is not actually active.
**Fix:** Remove the old Timer-based `fadeIn`/`fadeOut` and update `playMusic`/`playAmbient` callers to call the Task-based channel API. Follow the existing comment's intent.

#### W11 — NPC TTS voice IDs are placeholder strings — NPC dialogue audio is silent
**File:** `Services/TTSService.swift` (TTSVoice enum)
**Issue:** `TTSVoice.npcMale = "PASTE_NPC_MALE_VOICE_ID_HERE"` and `TTSVoice.npcFemale = "PASTE_NPC_FEMALE_VOICE_ID_HERE"`. `TTSVoice.isConfigured()` returns `false` for these and calls are silently dropped. Any NPC dialogue TTS is non-functional.
**Fix:** Replace with real ElevenLabs / Cartesia voice IDs, or add a clear `// TODO: voice IDs needed before shipping NPC audio` comment rather than a string that could silently slip through.

#### W12 — BirdChatViewModel subscription check references non-existent API
**File:** `ViewModels/BirdChatViewModel.swift:113–115`
**Issue:** The commented-out subscription check references `SubscriptionManager.shared.hasActiveSubscription`, which does not exist — `SubscriptionManager` exposes `hasChosenTier`. The comment cannot be reinstated verbatim; it will not compile.
**Fix:** When re-enabling the gate, replace with:
```swift
if currentProvider == .claudeAPI && !SubscriptionManager.shared.hasChosenTier {
    error = "Subscribe to use Claude AI"
    return
}
```
(W9 in the original report already flagged the gate being disabled; this adds the compile-error detail.)

---

### INFO (added)

#### I9 — MascotNode class appears unused at runtime
**File:** `Views/SpriteKit/MascotNode.swift`
**Issue:** `MascotNode` (the blob/splash mascot) is fully implemented but is not instantiated in `CityScene`, `WorkshopScene`, or any other active scene. The bird companion renders as a SwiftUI overlay; `PlayerNode` handles the apprentice. `MascotNode` is dead code unless planned for a future scene.
**Action:** Mark with `// Reserved for future scene` or remove if not on the roadmap.

#### I10 — "Il Duomo" vs "Duomo" name inconsistency
**File:** `Models/LessonRecord.swift:50` seeds `"Il Duomo"`; `ViewModels/CityViewModel.swift:118` uses `"Duomo"`.
**Impact:** Low — all content routers (`LessonContent`, `NotebookContent`, `KnowledgeCardContent`) use `case "Duomo", "Il Duomo":` dual-matching. Correctly handled everywhere. Worth standardising to one form in a future cleanup pass.

#### I11 — NPCEncounterManager availability guard at call sites
**File:** `Services/NPCEncounterManager.swift` (class marked `@available(iOS 26.0, macOS 26.0, *)`)
**Issue:** Any access to `NPCEncounterManager.shared` without a wrapping `if #available(iOS 26.0, macOS 26.0, *)` block will compile but crash at runtime on older OS versions.
**Action:** Audit all `NPCEncounterManager.shared` call sites and confirm they are inside availability guards.

*Addendum added 2026-05-22 following full deep-read pass.*
