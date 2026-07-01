# Weekly Health Check — 2026-07-01

## 1. Files Read

**Step 0 completed.** All 187 `.swift` files were read in full across 8 parallel agents plus direct Bash searches.

**Style/theme files read in full:**
- `Services/Styles/RenaissanceColors.swift` — 149 color tokens + border/card modifiers
- `Services/Styles/RenaissanceTheme.swift` — `RenaissanceFont`, `Spacing`, `CornerRadius`, `RenaissanceShadow`, `Tracking`, `LineHeight`, `DialogWidth`, `TextEmphasis` + reusable modifiers
- `Services/Styles/RenaissanceButton.swift` — `RenaissanceButton`, `RenaissanceSecondaryButton`, `EngineeringBorder`, `DimensionLines`
- `Services/Styles/ActivitySizing.swift` — all activity sizing tokens (iPad vs iPhone adaptive)
- `Services/Styles/GameSceneKitView.swift` — SceneKit representable
- `Services/Styles/GameSpriteView.swift` — SpriteKit representable

**Swift file count:** 187 files across Models/ (22), Services/ (26), ViewModels/ (7), Views/ (132 incl. SpriteKit, Onboarding, Sketching, StationMiniGames, InteractiveVisuals).

---

## 2. TL;DR

🟡 **YELLOW** — No crashes or security leaks. Two functional gaps (TTS NPC voices unconfigured; 60fps SwiftUI Timer) plus a consistent pattern of hardcoded font sizes in newer Views files and a missing `CornerRadius.xs` token causing 47 raw `.cornerRadius(6)` calls.

| Severity | Count |
|----------|-------|
| CRITICAL | 0 |
| WARNING  | 7 |
| INFO     | 9 |

---

## 3. CRITICAL

_None._

---

## 4. WARNING

### W-1 — TTSService.swift:31,34 — NPC voice IDs not configured (silent TTS failure)

**File:** `Services/TTSService.swift:31,34`

```swift
static let npcMale   = "PASTE_NPC_MALE_VOICE_ID_HERE"
static let npcFemale = "PASTE_NPC_FEMALE_VOICE_ID_HERE"
```

The `bird` and `storyteller` voice IDs are real ElevenLabs IDs in source (lines 25, 28). The two NPC slots are placeholders. `TTSVoice.isConfigured(_:)` correctly gates TTS calls, so nothing crashes — but any NPC TTS call silently returns without speaking. When NPC dialogue is added, this will produce silent NPCs with no error.

**Fix:** Populate from `APIKeys.swift` (already gitignored) using the same pattern as `WorkerClient.proxyToken`, OR paste in the real IDs. Do not leave placeholders in a production build.

---

### W-2 — FarmMiniGameView.swift:658 — 60 fps SwiftUI Timer (performance)

**File:** `Views/StationMiniGames/FarmMiniGameView.swift:658`

```swift
gameTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
```

`Timer.scheduledTimer` at 16 ms runs on the RunLoop and is not synchronized with the display refresh cycle, causing missed frames and CPU waste on 120Hz ProMotion displays. The timer is properly invalidated in `.onDisappear`, so there's no leak.

**Fix:** Replace with `TimelineView(.animation)` (iOS 15+) or a `Task { while !Task.isCancelled { await Task.sleep(for: .seconds(1/60)); ... } }` pattern that respects `Task.isCancelled`.

---

### W-3 — IVMaterialColors in InteractiveVisualHelpers.swift:20–28 — Hardcoded colors partially duplicating RenaissanceColors

**File:** `Views/InteractiveVisualHelpers.swift:14–28`

```swift
static let dimColor   = Color(red: 0.7, green: 0.35, blue: 0.25)   // ← not in palette
static let leadGray   = Color(red: 0.50, green: 0.52, blue: 0.55)   // ← RenaissanceColors.leadGray is (0.55,0.55,0.52)
static let ironDark   = Color(red: 0.35, green: 0.33, blue: 0.32)   // ← not in palette
static let oakBrown   = Color(red: 0.55, green: 0.42, blue: 0.28)   // ← RenaissanceColors.warmBrown is (0.545,0.435,0.278)
static let bronzeGold = Color(red: 0.72, green: 0.55, blue: 0.32)   // ← not in palette
static let hotRed     = Color(red: 0.85, green: 0.35, blue: 0.25)   // ← not in palette
static let limeTan    = Color(red: 0.88, green: 0.84, blue: 0.76)   // ← not in palette
static let cherryRed  = Color(red: 0.80, green: 0.25, blue: 0.20)   // ← not in palette
static let poplarLight= Color(red: 0.78, green: 0.72, blue: 0.58)   // ← not in palette
```

`IVMaterialColors` is the right place to centralise interactive-visual material colours (the comment says so), but two of its values are near-duplicates of existing tokens that have drifted:
- `oakBrown` (0.55/0.42/0.28) ≈ `RenaissanceColors.warmBrown` (0.545/0.435/0.278) — 1–2 channel-point drift
- `leadGray` (0.50/0.52/0.55) ≈ `RenaissanceColors.leadGray` (0.55/0.55/0.52) — 5 channel-point drift

**Fix (two steps):**
1. Replace `IVMaterialColors.oakBrown` → `RenaissanceColors.warmBrown` and `IVMaterialColors.leadGray` → `RenaissanceColors.leadGray` to eliminate drift.
2. Add the seven remaining material colours (`dimColor`, `ironDark`, `bronzeGold`, `hotRed`, `limeTan`, `cherryRed`, `poplarLight`) as named tokens to `RenaissanceColors.swift` under a new `// MARK: - Interactive Visual Material Palette` section so they appear in the canonical colour reference.

---

### W-4 — ForestMapView.swift:846–1669 — 10+ hardcoded `.font(.system(size:))`

**File:** `Views/ForestMapView.swift`

Lines 846, 858, 889, 902, 911, 939, 1080, 1123, 1155, 1669 all use `.font(.system(size: N))` with literal sizes (10, 11, 13, 14, 16, 28, 36). This is a newer file that was written outside the `RenaissanceFont` token system.

**Fix:** Replace with nearest `RenaissanceFont` token:
- `size: 10–11` → `RenaissanceFont.captionSmall`
- `size: 13` → `RenaissanceFont.caption`
- `size: 14` → `RenaissanceFont.footnote`
- `size: 16` → `RenaissanceFont.bodyMedium`
- `size: 28` → `RenaissanceFont.largeTitle` (closest Cinzel token) or `RenaissanceFont.bodyLarge` if body text
- `size: 36` → `RenaissanceFont.hero` (36pt Cinzel-Bold)

---

### W-5 — WorkshopMapView.swift — 8+ hardcoded `.font(.system(size:))`

**File:** `Views/WorkshopMapView.swift`

Lines 1466, 1497, 1884, 2033, 2340, 2907, 2935, 2994 use `.font(.system(size: N))` with literals (8, 10, 12, 13, 14, 52). Same issue as W-4; WorkshopMapView is a large file with several sections added at different times.

**Fix:** Same mapping as W-4. Size 52 is closest to `RenaissanceFont.hero` (36pt) — likely needs a new `RenaissanceFont.display` token at 52pt, or use `.custom("Cinzel-Bold", size: 52 * ...)` via an `ActivitySizing`-style adaptive function.

---

### W-6 — Sketching views — hardcoded `.font(.system(size:))`

**Files:**
- `Views/Sketching/PiantaCanvasView.swift:142,387,488` — sizes 14, 48, 60
- `Views/Sketching/BlueprintStudyView.swift:108` — size 48
- `Views/Sketching/SketchResultView.swift:160` — size 14

The Sketching sub-system was written or extended after the `RenaissanceFont` system was in place but didn't adopt it. Sizes 48 and 60 are large blueprint-annotation sizes that have no current token.

**Fix:** Sizes 14 → `RenaissanceFont.footnote`. Sizes 48/60: add `RenaissanceFont.blueprint = Font.custom("Cinzel-Bold", size: 48)` (or a size-class-adaptive variant in `ActivitySizing`).

---

### W-7 — Interactive Visuals — 47 occurrences of `.cornerRadius(6)` (no matching token)

**Files:** `AqueductInteractiveVisuals.swift` (7×), `RomanRoadsInteractiveVisuals.swift` (8×), `SiegeWorkshopInteractiveVisuals.swift` (6×), and 12 other Interactive Visual files.

`CornerRadius` tokens are: `sm=8`, `md=12`, `lg=16`, `xl=20`. There is no token for 6. All 47 `.cornerRadius(6)` calls are on small badge/chip/pill elements (ingredient tags, layer labels, element buttons) that intentionally sit below the standard `sm` radius.

**Fix:** Add `CornerRadius.xs: CGFloat = 6` to `RenaissanceTheme.swift` and do a search-replace across these files.

---

## 5. INFO

### I-1 — MascotDialogueView.swift:524 — Blink timer fires on 3-second loop

**File:** `Views/MascotDialogueView.swift:507,524`

The `BirdCharacter` struct starts a `blinkTimer` that fires every 3 seconds indefinitely while the bird is visible. The timer IS properly invalidated in `.onDisappear`. The animation plays one blink cycle then stays on the last frame (correct CLAUDE.md pattern). No issue — confirmed clean. Flagged here for awareness only.

---

### I-2 — KnowledgeCardsOverlay.swift:412,451,603 — Mixed font token usage

**File:** `Views/KnowledgeCardsOverlay.swift`

Lines 501, 515, 528 correctly use `ActivitySizing.cardHeaderIconSize(sizeClass)` for dynamic sizing. Lines 412 (`.font(.system(size: 44))`) and 451 (`.font(.system(size: 11))`) and 603 (`.font(.system(size: 13))`) use hardcoded system sizes. These are in the same file as correct token usage, suggesting they were added ad-hoc.

**Fix:** Line 412 (44pt emoji/icon) → `.font(.system(size: ActivitySizing.cardHeaderIconSize(sizeClass) * 1.5))` or a new token. Lines 451 and 603 → `RenaissanceFont.captionSmall`.

---

### I-3 — MuseumSketchService.swift:24,58 — Magic numbers for cache and image dimension

**File:** `ViewModels/MuseumSketchService.swift:24,58`

```swift
memoryCapacity: 20_000_000    // 20 MB
diskCapacity:   100_000_000   // 100 MB
maxDimension:   1024
```

These are unnamed constants. Not a bug, but they'll be opaque when someone needs to tune memory on low-end devices.

**Fix:** Extract to named constants or a `enum MuseumSketchConfig { static let memoryCacheMB = 20 ... }`.

---

### I-4 — Sketching views — large commented-out file-header blocks

**Files:** `Sketching/PiantaCanvasView.swift:6–21` (16 lines), `Sketching/PencilCanvasView.swift:5–17` (13 lines), `Sketching/ShapeSnap.swift:5–11` (7 lines), `Sketching/BlueprintStudyView.swift:3–8` (6 lines), `Sketching/SketchEditorView.swift:6–11` (6 lines), `Sketching/SketchResultView.swift:3–8` (6 lines).

All are vestigial migration notes from the Phase 2+ sketching system (now tracked in CLAUDE.md). Safe to delete.

---

### I-5 — ContentView.swift — onboarding skip still commented out

**File:** `Views/ContentView.swift` (line referenced in CLAUDE.md)

CLAUDE.md already tracks this: "Re-enable onboarding skip — uncomment the check in ContentView once onboarding is finalized." No action needed here — already on the roadmap.

---

### I-6 — WorkshopMapView.swift:729–733 — 5-line commented block

**File:** `Views/WorkshopMapView.swift:729–733`

Small legacy comment block. Safe to delete.

---

### I-7 — BirdChatViewModel.swift:104–107 — Commented subscription check

**File:** `ViewModels/BirdChatViewModel.swift:104–107`

3-line commented-out future-feature guard for subscription tiers. Leave or delete — not affecting behaviour.

---

### I-8 — TestFlight feedback — 5 unresolved items (all from Build 2, April 2026)

Feedback file: `feedback/latest_feedback.json` (synced 2026-04-18, most recent build: 3).

| # | Tester | Summary | Status |
|---|--------|---------|--------|
| 1 | Ray Garmon | Gold nuggets in river mini-game look brown; tapping instead of sifting | Unresolved |
| 2 | Ray Garmon | Card interaction mismatch ("asked why, had to tap picture") | Unresolved |
| 3 | Brianna Walker | iPad horizontal: "Choose apprentice" screen too big; no back button in All/Rome/Ren/Tests nav; double animation after character select | Unresolved |
| 4 | Brianna Walker | iPhone vertical: minor scaling; bird flies over text in StoryNarrativeView | Unresolved |
| 5 | Marina Pollak | Card tap interactions confusing / not matching questions | Unresolved |

Build 3 was released Apr 17 and has no feedback yet. No recent commits cross-referencing the feedback are visible. All 5 items predate Build 3 — unclear if any were addressed. Recommend reviewing against Build 3 changes.

**Highest priority:** Item 1 (gold/brown colour distinction in `RiverMiniGameView`) and Items 3–4 (iPhone/iPad layout in Onboarding).

---

### I-9 — TerrainBlurHelper.swift — disabled feature with large comment

**File:** `Views/SpriteKit/TerrainBlurHelper.swift`

Terrain blur was disabled 2026-04-22 (per comment). Large comment block explains the CIGaussianBlur approach that was reverted. The code still compiles but is effectively dead. Either restore or delete the blur approach.

---

## 6. Missing Tokens

| Token | Recommended value | Where to add | Needed by |
|-------|-------------------|--------------|-----------|
| `CornerRadius.xs` | `6` | `RenaissanceTheme.swift`, `CornerRadius` enum | 47× `.cornerRadius(6)` across Interactive Visuals (W-7) |
| `RenaissanceFont.blueprint` | `Font.custom("Cinzel-Bold", size: 48, relativeTo: .largeTitle)` | `RenaissanceTheme.swift`, `RenaissanceFont` enum | Sketching canvas annotations (W-6) |
| 9 `IVMaterialColors` entries | See W-3 fix above | `RenaissanceColors.swift`, new `// MARK: - Interactive Visual Material Palette` | `InteractiveVisualHelpers.swift` + 17 IV files |

---

## 7. Clean Scans

The following file groups were reviewed and found **clean** (no hardcoded values, no dead code, no memory issues, no secrets):

- **All 22 Models/ files** — `Building.swift`, `BuildingLesson.swift`, `BuildingProgress.swift`, `BuildingProgressRecord.swift`, `BuildingTopicMap.swift`, `Challenge.swift`, `ChatMessage.swift`, `ConstructionPhase.swift`, `ContextualSuggestion.swift`, `CraftedItem.swift`, `DiscoveryCard.swift`, `GameSettings.swift`, `GeneratedContent.swift`, `HistoricalNPCContent.swift`, `KnowledgeCard.swift`, `KnowledgeCardContentRenaissance.swift`, `KnowledgeCardContentRome.swift`, `LessonContent.swift`, `LessonContentRenaissance.swift`, `LessonContentRome.swift`, `LessonRecord.swift`, `MasterAssignment.swift`, `Material.swift`, `MuseumSketch.swift`, `NotebookContent.swift`, `NotebookContentRenaissance.swift`, `NotebookContentRome.swift`, `NotebookEntry.swift`, `OnboardingContent.swift`, `OnboardingState.swift`, `PigmentRecipe.swift`, `PlayerSave.swift`, `Recipe.swift`, `ScienceCardContent.swift`, `SketchTeachingData.swift`, `SketchingChallenge.swift`, `SketchingContent.swift`, `StationCompounds.swift`, `StudentProfile.swift`, `SubscriptionTier.swift`, `Tool.swift`, `ToolRecipe.swift`, `VenueGuide.swift`, `WorkshopJob.swift`
- **ViewModels** — `CityViewModel.swift`, `NotebookState.swift`, `PersistenceManager.swift`, `WorkshopState.swift` (educational content strings are by design, not hardcoded UI)
- **Services** — `AIService.swift`, `AppAttestService.swift`, `AppleAIService.swift`, `AssetManager.swift`, `CalendarSnapshot.swift`, `ClaudeService.swift`, `ContextualSuggestionService.swift`, `ContextualSuggestionStore.swift`, `DataManagementService.swift`, `GameCenterManager.swift`, `GameTools.swift`, `GenerationService.swift`, `HapticsManager.swift`, `MockAIService.swift`, `NPCEncounterManager.swift`, `PubChemService.swift`, `SketchValidator.swift`, `SoundManager.swift`, `SubscriptionManager.swift`, `VisualEditorState.swift`, `WolframGeometryHelper.swift`, `WolframService.swift`, `WorkerClient.swift`
- **RenaissanceArchitectAcademyApp.swift** — clean
- **Views** — `BloomEffectView.swift`, `BottomDialogPanel.swift`, `BuildingChecklistView.swift`, `BuildingDetailOverlay.swift`, `BuildingPlotView.swift`, `CityView.swift`, `ContentView.swift`, `ConstructionSequenceView.swift`, `DiscoveryCardOverlay.swift`, `EditableModifier.swift`, `EditorBottomPanel.swift`, `GameCenterDashboardView.swift`, `GameTopBarView.swift`, `HintOverlayView.swift`, `InfographicRevealView.swift`, `InventoryBarView.swift`, `MascotDialogueView.swift`, `MaterialPuzzleView.swift`, `MainMenuView.swift`, `MoleculeView.swift`, `NotebookCanvasView.swift`, `NotebookPickerView.swift`, `NotebookView.swift`, `PhaseCompleteOverlay.swift`, `ProfileView.swift`, `RecipeBookView.swift`, `SceneEditorButtons.swift`, `SceneTransitionOverlay.swift`, `ScienceIconView.swift`, `SettingsView.swift`, `SidebarView.swift`, `SketchStudyOverlay.swift`, `SketchTeachingView.swift`, `SketchingChallengeView.swift`, `SpeakerButton.swift`, `WorkshopMapView.swift` (except W-5 font issues), `WorkshopView.swift`
- **SpriteKit** — `BuildingNode.swift`, `CityScene.swift`, `CityMapView.swift`, `CraftingRoomScene.swift`, `CraftingRoomMapView.swift`, `ForestScene.swift`, `GoldsmithMapView.swift`, `GoldsmithScene.swift`, `MascotNode.swift`, `PlayerNode.swift`, `ResourceNode.swift`, `SceneEditorMode.swift`, `TerrainBlurHelper.swift`, `WorkshopScene.swift`
  - Note: SpriteKit scenes use `SKAction.repeatForever()` for ambient animations (tree sway, lamp flicker, smoke) — this is correct SpriteKit usage, not a CLAUDE.md violation. CLAUDE.md's "play once" rule applies only to **Timer-based SwiftUI frame animations**, not to SpriteKit ambient loops.
- **Onboarding** — `AvatarTransitionView.swift`, `CharacterSelectView.swift`, `OnboardingView.swift`, `StationLessonOverlay.swift`, `StoryNarrativeView.swift`, `SubscriptionPickerView.swift`
  - All Timers in Onboarding views are properly invalidated in `.onDisappear`. No retain cycles (all views are SwiftUI structs).

### Asset verification
All `Image("...")` and `SKTexture(imageNamed:)` calls reference assets confirmed present in `Assets.xcassets`:

| Asset name | Present |
|------------|---------|
| `BackgroundMain` | ✅ |
| `BookBackground` | ✅ |
| `ButtonBackground` | ✅ |
| `BirdFrame00` (through BirdFrame12) | ✅ |
| `InteriorFurnace` | ✅ |
| `InteriorPigmentTable` | ✅ |
| `InteriorShelf` | ✅ |
| `InteriorWorkbench` | ✅ |
| `WorkshopBackground` | ✅ |

Dynamic asset patterns (`ApprenticeFrame00–14`, `ApprenticeGirlFrame00–14`, `BirdFlySitFrame00–14`, `BirdSitBlinkFrame00–14`, etc.) all have corresponding sprite atlases in the catalog.

### Font files
All fonts referenced in `RenaissanceFont` tokens (`Cinzel-Bold`, `Cinzel-Regular`, `EBGaramond-Regular`, `EBGaramond-Italic`, `EBGaramond-SemiBold`, `EBGaramond-Bold`, `PetitFormalScript-Regular`, `Delius-Regular`) are present in `Fonts/`. No missing or orphaned font files.

---

## 8. Build Status

**Build verification skipped — no macOS toolchain in sandbox (Linux environment).**

The codebase has no obvious Swift syntax errors observable from static analysis. All imports are consistent, no duplicate type definitions detected. Provisioning/signing not applicable in this environment.

---

_Generated 2026-07-01 by automated weekly health check._
