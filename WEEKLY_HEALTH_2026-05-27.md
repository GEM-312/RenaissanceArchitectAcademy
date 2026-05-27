# Weekly Code Health Check — 2026-05-27

---

## 1. Files Read (Step 0 Confirmation)

**Style / theme files (all read in full):**
- `Services/Styles/RenaissanceColors.swift`
- `Services/Styles/RenaissanceTheme.swift` (Spacing, CornerRadius, RenaissanceFont, RenaissanceShadow, ActivitySizing)
- `Services/Styles/RenaissanceButton.swift`
- `Services/Styles/ActivitySizing.swift`

**Model files (all read in full, 15 files):**
Building, BuildingLesson, BuildingProgress, BuildingProgressRecord, BuildingTopicMap,
ConstructionPhase, ChatMessage, ContextualSuggestion, CraftedItem, DiscoveryCard,
GameSettings, GeneratedContent, HistoricalNPCContent, KnowledgeCard + Pantheon content,
Challenge.

**Service files (all read in full, 4 files):**
WorkerClient, ClaudeService, AIService (BirdContext + systemPrompt), AppleAIService.

**View files — targeted grep scan across all 185 Swift files** for:
`Color(red:)`, `.font(.system(size:))`, `Font.custom(…, size:)`, `.padding(N)`, `.cornerRadius(N)`,
`[self]` strong captures, `% frameCount` loops, `Timer.publish`, `DispatchQueue.main.async`,
commented-out blocks ≥ 5 lines, `ForEach` without `id`, pbxproj integrity, asset catalog cross-check.

**Total Swift files in project:** 185

---

## 2. TL;DR

**YELLOW** — No crashes or security issues; widespread hardcoded values and a silent UX gap (boy intro animation missing). Existing theme token coverage is excellent but not yet applied uniformly.

| Severity | Count |
|---|---|
| CRITICAL | 0 |
| WARNING | 9 |
| INFO | 9 |

---

## 3. CRITICAL

_None._

---

## 4. WARNING

### W1 — IVMaterialColors.leadGray has drifted from the canonical token

`Views/InteractiveVisualHelpers.swift:19`

```swift
// CURRENT (wrong)
static let leadGray = Color(red: 0.50, green: 0.52, blue: 0.55)

// CANONICAL (RenaissanceColors.swift:101)
static let leadGray = Color(red: 0.55, green: 0.55, blue: 0.52)
```

Delta: R −0.05, G −0.03, B +0.03 — a warm-gray became a cool-gray. Any surface using `IVMaterialColors.leadGray` renders a different shade from every surface using `RenaissanceColors.leadGray`.

**Fix:** Replace the inline value with the token:
```swift
static let leadGray = RenaissanceColors.leadGray
```

---

### W2 — IVMaterialColors has 8 inline Color(red:) values that should reference tokens

`Views/InteractiveVisualHelpers.swift:12–26`

| Property | Current inline value | Fix |
|---|---|---|
| `dimColor` | `Color(red: 0.70, green: 0.35, blue: 0.25)` | `RenaissanceColors.pozzolanaRed` |
| `leadGray` | `Color(red: 0.50, green: 0.52, blue: 0.55)` | `RenaissanceColors.leadGray` (see W1) |
| `oakBrown` | `Color(red: 0.55, green: 0.42, blue: 0.28)` | `RenaissanceColors.warmBrown` |
| `hotRed` | `Color(red: 0.85, green: 0.35, blue: 0.25)` | `RenaissanceColors.pozzolanaRed` |
| `limeTan` | `Color(red: 0.88, green: 0.84, blue: 0.76)` | `RenaissanceColors.travertineBeige` |
| `ironDark` | `Color(red: 0.35, green: 0.33, blue: 0.32)` | Add `RenaissanceColors.ironDark` (see Missing Tokens §6) |
| `bronzeGold` | `Color(red: 0.72, green: 0.55, blue: 0.32)` | Add `RenaissanceColors.bronzeGold` (see §6) |
| `cherryRed` | `Color(red: 0.80, green: 0.25, blue: 0.20)` | Add `RenaissanceColors.cherryRed` (see §6) |
| `poplarLight` | `Color(red: 0.78, green: 0.72, blue: 0.58)` | Add `RenaissanceColors.poplarLight` (see §6) |

---

### W3 — Per-building InteractiveVisuals files define duplicate local Color(red:) constants

All 17 `*InteractiveVisuals.swift` files declare private file-scope color constants with raw `Color(red:)` values. Several duplicate each other or duplicate `IVMaterialColors`. Top offenders:

| File | Local color constants | Notable duplication |
|---|---|---|
| `DuomoInteractiveVisuals.swift:59–65` | 7 | `goldAccent` ≈ `RenaissanceColors.ochre`; `sinopiaRed` ≈ `pozzolanaRed` |
| `ArsenalInteractiveVisuals.swift:57–62` | 6 | `hullBrown` ≈ `IVMaterialColors.oakBrown`; `ironDark` duplicates IVMaterialColors.ironDark |
| `SiegeWorkshopInteractiveVisuals.swift:63–64` | 2 | `oakBrown` and `bronzeGold` are exact duplicates of `IVMaterialColors` values |
| `BotanicalGardenInteractiveVisuals.swift:50–54` | 5 | `stoneGray` duplicates `RenaissanceColors.stoneGray`; `soilBrown` ≈ `warmBrown` |
| `AnatomyTheaterInteractiveVisuals.swift:52–55` | 4 | `steelGray` ≈ `stoneGray`; `walnutBrown` ≈ `warmBrown` |
| `RomanRoadsInteractiveVisuals.swift:50,52` | 2 | `basaltDark` ≈ `sepiaInk.opacity`; `gravelBrown` ≈ `warmBrown` |

There are also ~30 additional inline `Color(red:)` literals scattered throughout these files outside the top-level constant declarations (e.g. `DuomoInteractiveVisuals.swift:758`, `ArsenalInteractiveVisuals.swift:470,604,741,782`).

**Fix:** After adding missing tokens per §6, consolidate all per-building `private let` color constants to reference `RenaissanceColors.*` or `IVMaterialColors.*`. Inline one-off `Color(red:)` literals inside `Canvas` drawing blocks are lowest priority (procedural shading); the top-level `private let` declarations are the actionable items.

---

### W4 — Hardcoded `.font(.system(size: N))` in SwiftUI views

**Total instances outside theme files: ~50.** Files with the highest counts:

| File | Instances | Example lines |
|---|---|---|
| `ForestMapView.swift` | 10 | 846 (36), 858 (13), 889 (16), 902 (10), 911 (16), 939 (14), 1080 (16), 1123 (11), 1155 (13), 1669 (28) |
| `WorkshopMapView.swift` | 8 | 1466 (14), 1497 (14), 1884 (12), 2033 (8), 2340 (10), 2907 (52), 2935 (13), 2994 (12) |
| `DiscoveryCardOverlay.swift` | 4 | 98 (44), 142 (24), 183 (16), 235 (14) |
| `RecipeBookView.swift` | 5 | 125 (68), 153 (11), 268 (11), 288 (11), 384 (12) |
| `ArsenalInteractiveVisuals.swift` | 4 | 520 (13), 535 (15), 714 (13), 729 (13) |
| `CardVisualView.swift` | 3 | 105 (13), 136 (13), 143 (13) |
| `NotebookPickerView.swift` | 3 | 113 (24), 129 (14), 152 (56) |
| `FoldableInventoryBar.swift` | 3 | 123 (20), 140 (26), 150 (22) |
| `ProfileView.swift` | 2 | 122 (14), 917 (20) |
| `InteractiveVisualHelpers.swift` | 3 | 130 (13), 153 (13), 161 (14) |
| `MascotDialogueView.swift` | 1 | 222 (20 / 36 conditional) |
| `SettingsView.swift` | 1 | 205 (10) |
| `BotanicalGardenInteractiveVisuals.swift` | 1 | 856 (16) |
| `RomanRoadsInteractiveVisuals.swift` | 6 | 363 (13), 581 (13), 600 (13), 671 (dynamic), 795 (13), 821 (13) |

**Fix mapping (use existing `RenaissanceFont.*` tokens):**

| Raw size | Token |
|---|---|
| 36, 28 | `RenaissanceFont.title` (26) or `.largeTitle` (32) — pick nearest |
| 22, 20 | `RenaissanceFont.buttonLarge` (20) or `.title3` (18) |
| 17, 16 | `RenaissanceFont.body` (17) or `.bodyMedium` (16) |
| 15, 14 | `RenaissanceFont.bodySmall` (15) or `.footnote` (14) |
| 13 | `RenaissanceFont.captionSmall` (11) or `.caption` (13) — caption is closest |
| 12, 11 | `RenaissanceFont.captionSmall` (11) |
| 10, 8 | `RenaissanceFont.captionSmall` (11) — or add `RenaissanceFont.micro` token if 8pt is intentional |

For the large decorative sizes (44, 52, 56, 68), add named tokens to `RenaissanceTheme.swift` (see §6).

---

### W5 — Hardcoded `.padding(N)` and `.padding(.axis, N)` — 87 instances

Raw integer padding values are used throughout the codebase instead of `Spacing.*` tokens. This is a systemic issue; the same layout constant (e.g. `16`) appears dozens of times with no shared reference.

**Most affected files (>5 instances each):** `WorkshopMapView.swift`, `KnowledgeCardsOverlay.swift`, `ForestMapView.swift`, `InteractiveVisualHelpers.swift`, `DiscoveryCardOverlay.swift`, and all 17 `*InteractiveVisuals.swift` files.

**Fix:** Map raw values to existing `Spacing.*` tokens:

| Raw value | Token |
|---|---|
| 4 | `Spacing.xxs` |
| 8 | `Spacing.xs` |
| 12 | `Spacing.sm` |
| 16 | `Spacing.md` |
| 20 | `Spacing.lg` |
| 24 | `Spacing.xl` / `Spacing.dialogPadding` |
| 32 | `Spacing.xxl` |
| 40 | `Spacing.xxxl` |

---

### W6 — Hardcoded `.cornerRadius(N)` — 55 instances

55 uses of raw numeric corner radii (most common: 6 and 8). `CornerRadius.sm = 8` exists; `cornerRadius(8)` should use it. `cornerRadius(6)` has no matching token — add `CornerRadius.xs = 6` (see §6).

**Fix:**

| Raw value | Token |
|---|---|
| 6 | Add `CornerRadius.xs = 6` to `RenaissanceTheme.swift` |
| 8 | `CornerRadius.sm` |
| 12 | `CornerRadius.md` |
| 16 | `CornerRadius.lg` |
| 20 | `CornerRadius.xl` |

---

### W7 — Commented-out code blocks ≥ 5 lines — 28 blocks across 18 files

These are dead code that adds noise and may hide intent. Files with the most blocks:

| File | Blocks | Lines |
|---|---|---|
| `SpriteKit/WorkshopScene.swift` | 6 | 409–413, 553–557, 663–667, 711–717, 811–816, 943–947, 1162–1169 |
| `SpriteKit/CityScene.swift` | 3 | 341–347, 489–493, 1069–1074 |
| `Onboarding/StoryNarrativeView.swift` | 2 | 151–157, 195–201 |
| `SpriteKit/ForestScene.swift` | 1 | 830–836 |
| `SpriteKit/BuildingNode.swift` | 1 | 265–271 |
| `Models/GeneratedContent.swift` | 1 | 15–20 |
| `Models/GameSettings.swift` | 1 | 229–233 |
| `Services/SubscriptionManager.swift` | 1 | 39–44 |
| `Services/NPCEncounterManager.swift` | 1 | 12–17 |
| `Services/GameTools.swift` | 1 | 11–16 |
| `Services/AppAttestService.swift` | 1 | 9–15 |
| `Services/ClaudeService.swift` | 2 | 136–140, 189–193 |
| `Services/AppleAIService.swift` | 1 | 10–15 |
| `Services/SketchValidator.swift` | 1 | 198–202 |
| `Services/GenerationService.swift` | 1 | 10–15 |
| `Views/WorkshopMapView.swift` | 1 | 729–733 |
| `Views/SpeakerButton.swift` | 1 | 8–12 |
| `Onboarding/CharacterSelectView.swift` | 1 | 28–33 (intentional per CLAUDE.md — onboarding skip disabled during dev) |

**Fix:** Remove all blocks except `CharacterSelectView.swift:28–33` (intentional, documented).

---

### W8 — `DispatchQueue.main.async` inside `@MainActor` view

`Views/RecipeBookView.swift:484`

```swift
DispatchQueue.main.async {
    // state update
}
```

This view is `@MainActor`. The `DispatchQueue.main.async` hop is redundant and suppresses Swift 6 strict-concurrency warnings.

**Fix:** Remove the wrapper — the code runs on MainActor already. Or if a next-runloop-tick deferral is truly needed, use `Task { @MainActor in … }`.

---

### W9 — `Font.custom("EBGaramond-SemiBold", …)` — unregistered font variant

`Views/InteractiveVisualHelpers.swift:174,187`

```swift
.font(fontSize.map { Font.custom("EBGaramond-SemiBold", size: $0) } ?? RenaissanceFont.ivLabel)
.font(fontSize.map { Font.custom("EBGaramond-Bold", size: $0) } ?? RenaissanceFont.ivFormula)
```

The app registers `EBGaramond-Regular` and `EBGaramond-Italic` via CoreText in `App.swift`. `EBGaramond-SemiBold` and `EBGaramond-Bold` are not registered. On iOS, unregistered font names silently fall back to system sans-serif — inconsistent with the parchment aesthetic.

**Fix:** Either register these variants in `RenaissanceArchitectAcademyApp.swift` (and add corresponding `RenaissanceFont` tokens), or replace with `EBGaramond-Regular` + `.bold()` / `.fontWeight(.semibold)` modifiers.

---

## 5. INFO

### I1 — Boy intro animation frames missing; boy onboarding silently skips the sequence

`Views/Onboarding/AvatarTransitionView.swift:23,70`

`AvatarTransitionView` looks for `BoyIntroFrame00`–`BoyIntroFrame29` when gender is `.boy`. No such imagesets exist in `Assets.xcassets`. The `assetExists()` guard at line 70 fires and calls `onFinished()` immediately — so boys proceed through onboarding without an intro animation. Girl frames are complete (30 frames, `GirlIntroFrame00`–`GirlIntroFrame29`). Note: the existing `AvatarBoyFrame00`–`AvatarBoyFrame09` use a different naming convention and are not wired up here.

No crash, but the UX gap is significant: half the player cohort silently loses the cinematic intro.

---

### I2 — `StoryNarrativeView` hardcodes `Font.custom` size 30

`Views/Onboarding/StoryNarrativeView.swift:62`

```swift
let emphasisFont = Font.custom("PetitFormalScript-Regular", size: 30, relativeTo: .title)
```

Registered font, but raw size. `RenaissanceFont.tagline` is size 20; a separate emphasis size token is missing. **Fix:** Add `RenaissanceFont.taglineEmphasis` = 30 to `RenaissanceTheme.swift`, or reuse `RenaissanceFont.tagline` if the visual is acceptable.

---

### I3 — Icon-size helpers use `size * 0.7 / 0.75` relative scaling — intentional but undocumented

`Models/CraftedItem.swift:99`, `Models/Material.swift:164`, `Models/Tool.swift:125` all use `.font(.system(size: size * 0.7))`. These receive an external `size` parameter and the scale factor is the design constant. Low risk but should have a comment explaining the ratio is intentional.

---

### I4 — `EditableModifier` uses `.font(.system(size: 7))` — debug-only, acceptable

`Views/EditableModifier.swift:54` — editor drag-handle overlay used only inside `#if DEBUG`. No fix needed.

---

### I5 — `MascotDialogueView` has one conditional hardcoded font size

`Views/MascotDialogueView.swift:222` — `.font(.system(size: isCompact ? 20 : 36))`. The compact branch maps to `RenaissanceFont.buttonLarge` (20); the regular branch maps to `RenaissanceFont.title` (26) or `.largeTitle` (32). **Fix:** `RenaissanceFont.buttonLarge` and `RenaissanceFont.hero` (36).

---

### I6 — GoldsmithScene + GoldsmithMapView added since last health check (May 24) — clean

`Views/SpriteKit/GoldsmithScene.swift`, `Views/SpriteKit/GoldsmithMapView.swift` — new files. No hardcoded colors, no `[self]` captures, no looping frame animations. Passes all checks.

---

### I7 — SpriteKit `PlatformColor(red:)` — 33 instances — intentional, no fix needed

SpriteKit scenes (`CraftingRoomScene`, `WorkshopScene`, `CityScene`, `ForestScene`, `PlayerNode`) use `PlatformColor(red:)` for particle emitters, glow effects, and procedural rendering. `SKColor` ≠ SwiftUI `Color`; a direct token bridge is not possible here. These are acceptable. Documented as INFO so future reviewers don't re-flag them.

---

### I8 — `ForEach(card.keywords …)` — Identifiable conformance should be verified

`Views/KnowledgeCardsOverlay.swift:600,796,849` — `ForEach(card.keywords.prefix(4))` etc. These rely on `KeywordPair` conforming to `Identifiable`. If it does, SwiftUI is fine. If not, a runtime warning fires on every render. Verify or add `id: \.self` as a safety measure.

---

### I9 — `NotebookCanvasView` uses `UIColor(red:)` for highlight

`Views/NotebookCanvasView.swift:42` — `UIColor(red: 1.0, green: 0.85, blue: 0.3, alpha: 0.4)`. This is inside a `UIGraphicsImageRenderer` drawing block (UIKit context). The closest token is `RenaissanceColors.highlightAmber`. **Fix:** `UIColor(RenaissanceColors.highlightAmber.opacity(0.4))` via `Color → UIColor` bridge.

---

## 6. Missing Tokens

### Add to `Services/Styles/RenaissanceColors.swift`

```swift
// Metalwork & wood palette (used across 8+ InteractiveVisuals files)
static let ironDark    = Color(red: 0.35, green: 0.33, blue: 0.32)  // dark forged iron
static let bronzeGold  = Color(red: 0.72, green: 0.55, blue: 0.32)  // cast bronze
static let cherryRed   = Color(red: 0.80, green: 0.25, blue: 0.20)  // tempered steel heat color
static let poplarLight = Color(red: 0.78, green: 0.72, blue: 0.58)  // pale poplar wood
```

### Add to `Services/Styles/RenaissanceTheme.swift` — CornerRadius

```swift
extension CornerRadius {
    static let xs: CGFloat = 6    // small chip / tag corners (used 20+ places)
}
```

### Add to `Services/Styles/RenaissanceTheme.swift` — RenaissanceFont (large decorative sizes)

```swift
// Decorative / hero emoji / icon sizes used in several views
static let heroIcon: Font  = .system(size: 44)   // DiscoveryCardOverlay icon
static let heroEmoji: Font = .system(size: 52)   // WorkshopMapView large badge
static let heroLarge: Font = .system(size: 56)   // NotebookPickerView empty state
static let craftingIcon: Font = .system(size: 68) // RecipeBookView ingredient icon

// Tagline emphasis (PetitFormalScript at 30pt)
static let taglineEmphasis: Font = Font.custom("PetitFormalScript-Regular", size: 30, relativeTo: .title)
```

---

## 7. TestFlight Feedback — Build 2 (all 5 items unresolved)

| # | Tester | Device | Date | Issue |
|---|---|---|---|---|
| F1 | Ray Garmon | iPhone11,8 / iOS 18.7.7 | Apr 17 | **Gold-sifting mini-game color confusion** — some "gold" targets appeared brown; tapping gold instead of sifting gesture |
| F2 | Ray Garmon | iPhone11,8 / iOS 18.7.7 | Apr 17 | **Quiz question/interaction mismatch** — question asked "why" but interaction required tapping picture |
| F3 | Brianna Walker | iPhone13,4 / iOS 26.4.1 | Apr 10 | **iPad horizontal layout issues** — character select needs scaling; no back button in era tabs (All/Rome/Ren./Tests); 2 different animations after choosing apprentice |
| F4 | Brianna Walker | iPhone13,4 / iOS 26.4.1 | Apr 10 | **iPhone vertical layout** — text scaling; bird companion appears over text instead of flying in from off-screen |
| F5 | Pollak Marina | iPhone16,2 / iOS 26.4 | Apr 4 | **Card interactions unclear** — "every card asking to tap somewhere on the picture but some questions and interactions doesn't make much sense" |

Build 3 (Apr 17) is the current valid build. Recommend confirming which F-items were addressed in build 3 and closing them in TestFlight.

---

## 8. Clean Scans

The following scans returned zero findings:

| Check | Result |
|---|---|
| `% frameCount` loop in any Timer animation | ✅ Clean — all frame animations stop at last frame (CLAUDE.md rule respected) |
| `[self]` strong captures in SpriteKit SKScene subclasses | ✅ Clean |
| `Timer.publish` / `.connect()/.cancel()` Combine anti-pattern | ✅ Clean |
| `Color(hex:)` / `UIColor(hex:)` / `.sRGB` hex literals | ✅ Clean |
| Duplicate pbxproj section IDs | ✅ Clean — 94 unique IDs, no suspicious repetition |
| GoldsmithScene + GoldsmithMapView (new since last check) | ✅ Clean |
| `APIKeys.swift` secret in source | ✅ Absent from disk (gitignored, WorkerClient.isConfigured used for guards) |
| `ForEach(0..<N, id:)` missing id | ✅ All range-based ForEach correct |

---

## 9. Build Status

**SKIPPED** — `xcodebuild` is not available in the cloud sandbox environment. No build result to report. Run locally with:

```bash
xcodebuild -scheme RenaissanceArchitectAcademy \
           -destination 'platform=macOS' \
           build 2>&1 | grep -E 'error:|warning:|BUILD'
```

---

## 10. Addendum — Deep Scan Findings (background agent, 117 tool uses, 185 files)

The initial report was produced from targeted grep scans. A second full-read agent pass completed after the initial commit and surfaced revised counts and corrections.

### Revised TL;DR

**Updated counts: 0 CRITICAL, 11 WARNING, 9 INFO**

W8 (DispatchQueue) severity significantly understated — see W10 below.
W7 (commented-out code) count significantly overstated — see correction below.

---

### W10 — `DispatchQueue.main.async[After]` — 228 instances across 18+ files (HIGH)

The initial report flagged 1 instance (`RecipeBookView.swift:484`). The full scan found **228 instances** in at least 18 view files. All are `@MainActor`-isolated views; the hop is redundant under Swift 6 strict concurrency and creates unnecessary task overhead.

**Top offenders:**

| File | Instances | Sample lines |
|---|---|---|
| `Views/WorkshopMapView.swift` | ~47 | 270, 307, 348, 363, 372, 399, 414, 423, 450, 465, 474, 501, 516, 525, 552, … |
| `Views/SpriteKit/CityMapView.swift` | ~18 | 283, 333, 352, 359, 370, 408, 425, 443, 549, 573, 718, 757, 814, 893, 937, 952, 991, 1014 |
| `Views/KnowledgeCardsOverlay.swift` | ~14 | 167, 225, 350, 933, 1037, 1211, 1219, 1336, 1508, 1617, 1625, 1745, 1755, 1769 |
| `Views/ForestMapView.swift` | ~14 | 198, 217, 355, 619, 1240, 1248, 1258, 1304, 1318, 1535, 1590, 1595, 1601 |
| `Views/StationMiniGames/VolcanoMiniGameView.swift` | ~13 | 480, 494, 502, 744, 767, 775, 993, 1008, 1018, 1028, 1060, 1090, 1106, 1112 |
| `Views/AqueductInteractiveVisuals.swift` | ~8 | 439, 572, 1088, 1240, 1374, 1377, 1930, 1934 |
| `Views/ColosseumInteractiveVisuals.swift` | ~8 | 136, 256, 390, 736, 869, 1168, 1280, 1383 |
| `Views/SiegeWorkshopInteractiveVisuals.swift` | ~6 | 133, 267, 321, 403, 445, 510, 556, 589 |
| `Views/InsulaInteractiveVisuals.swift` | ~7 | 138, 366, 457, 668, 768, 914, 1074 |
| `Views/HintOverlayView.swift` | ~5 | 523, 533, 535, 643, 647 |
| `Views/RomanRoadsInteractiveVisuals.swift` | ~6 | 146, 357, 484, 593, 816, 1134 |
| `Views/SpriteKit/CraftingRoomMapView.swift` | ~6 | 236, 252, 260, 1247, 1681, … |
| `Views/StationMiniGames/FarmMiniGameView.swift` | ~4 | 614, 722, 737, 747 |
| Others | ~52 | `BloomEffectView`, `SceneTransitionOverlay`, `BirdChatOverlay`, `NPCDialogueView`, `MascotDialogueView`, `Sketching/SketchResultView`, `RecipeBookView`, `MoleculeView`, `Onboarding/AvatarTransitionView` |

**Fix — replacement pattern:**
```swift
// Before (227 additional instances of this pattern):
DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
    self.someState = true
}

// After (@MainActor already; just use async Task):
Task { @MainActor in
    try? await Task.sleep(for: .seconds(0.5))
    someState = true
}
```

For plain `DispatchQueue.main.async { }` (no delay), remove the wrapper entirely — code already runs on main actor.

---

### W11 — Hardcoded font sizes: actual count is 246 (not ~50)

W4 in the initial report identified the top-count files correctly but the total is much larger. Summary of files not mentioned in W4:

| File | Additional instances |
|---|---|
| `Views/BuildingDetailOverlay.swift` | 4 (lines 52, 103, 125, 189 — `Font.custom(…, size: N)` pattern) |
| `Views/BuildingPlotView.swift` | 3 |
| `Views/ProfileView.swift` | 9 (total), not 2 |
| `Views/BuildingLessonView.swift` | 4 |
| `Views/KnowledgeCardsOverlay.swift` | 7 |
| `Views/NPCDialogueView.swift` | 3 |
| `Views/ConstructionSequenceView.swift` | 5 |
| `Views/MaterialPuzzleView.swift` | 1 |
| `Views/MathVisualTemplates.swift` | 7 |
| `Views/GameTopBarView.swift` | 3 |
| `Views/BirdChatOverlay.swift` | 3 |
| All 17 *InteractiveVisuals `.system(size:13)` on SF Symbol icons | ~100 total |

The `Font.custom("EBGaramond-SemiBold", size: N)` variant is also widespread (`BuildingDetailOverlay`, `ProfileView`, `BuildingLessonView`) — same issue, different call site.

**Priority fix for maximum impact:** Add a `RenaissanceFont.iconSmall` token (`.system(size: 13)`) and apply it to all SF Symbol icons in the 17 `*InteractiveVisuals` files. That alone resolves ~100 of the 246 instances.

---

### W12 — Hardcoded cornerRadius(6): 80+ instances (not 55)

The initial report's count of 55 covered `.cornerRadius(N)` in the top-level modifier form. The agent scan also found `RoundedRectangle(cornerRadius: 6)` inline (used in all *InteractiveVisuals step-buttons). Combined total: 80+. The fix recommendation (add `CornerRadius.xs = 6`) stands.

---

### Corrections to W7 (Commented-Out Code)

The initial W7 count of 28 blocks was significantly overstated. The agent's full read confirmed:

- **`WorkshopScene.swift`** — the 6 "blocks" are architectural documentation comment paragraphs (`///`-style explanations of waypoint graph sections), not commented-out code. **Not flagged.**
- **`CityScene.swift`**, **`StoryNarrativeView.swift`**, **`ForestScene.swift`**, **`BuildingNode.swift`** — same: multi-line `//` documentation, not dead code.
- **`Services/ClaudeService.swift:136–140,189–193`** — inline code explanation comments about the SSE streaming protocol. **Not dead code.**

**Genuine commented-out code blocks confirmed:** 2 (not 28).

| File | Lines | Content |
|---|---|---|
| `Views/ContentView.swift:73` | 1 line | Onboarding skip check — intentional per CLAUDE.md |
| `Views/SpriteKit/CityMapView.swift:1239–1241` | 3 lines | Tier badge feature stub — can be deleted |

W7 is demoted from WARNING to INFO.

---

### Corrections to I8 (ForEach without Identifiable)

Agent confirmed `KeywordPair` conforms to `Identifiable` (has `.id` property). `ForEach(card.keywords …)` is safe. I8 is resolved — no action needed.

---

### Clean Scans (Addendum — confirmed by full-read agent)

| Check | Result |
|---|---|
| `% frameCount` in frame timers | ✅ Clean — confirmed across all 185 files |
| `[self]` strong captures | ✅ Clean — confirmed in all SpriteKit and service files |
| `Timer.publish` / Combine anti-patterns | ✅ Clean — no `Timer.publish` anywhere |
| Unused `@Published` / `@State` vars | ✅ Clean — no confirmed unused state |
| Missing `Image("…")` assets | ✅ All static asset names verified present |
| `SoundManager` `numberOfLoops = -1` | ✅ Intentional music loop — not a frame animation violation |
| `MascotDialogueView` `Eye.blinkTimer` | ✅ Intentional periodic blink — not a frame animation violation |
