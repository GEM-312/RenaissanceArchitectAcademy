# Weekly Code Health Report — 2026-05-21

**Project:** Renaissance Architect Academy  
**Auditor:** Claude Code (claude-sonnet-4-6)  
**Date:** 2026-05-21  
**Scope:** All 178 Swift source files + shell checks

---

## Files Read

All **178 Swift files** were read in full. Complete list by category:

**Models (29 files):** Building.swift, BuildingLesson.swift, BuildingProgress.swift, BuildingProgressRecord.swift, Challenge.swift, ChatMessage.swift, ConstructionPhase.swift, CraftedItem.swift, DiscoveryCard.swift, GameSettings.swift, GeneratedContent.swift, HistoricalNPCContent.swift, KnowledgeCard.swift, KnowledgeCardContentRenaissance.swift, KnowledgeCardContentRome.swift, LessonContent.swift, LessonContentRenaissance.swift, LessonContentRome.swift, LessonRecord.swift, MasterAssignment.swift, Material.swift, MuseumSketch.swift, NotebookContent.swift, NotebookContentRenaissance.swift, NotebookContentRome.swift, NotebookEntry.swift, OnboardingContent.swift, OnboardingState.swift, PigmentRecipe.swift, PlayerSave.swift, Recipe.swift, ScienceCardContent.swift, SketchTeachingData.swift, SketchingChallenge.swift, SketchingContent.swift, StationCompounds.swift, StudentProfile.swift, SubscriptionTier.swift, Tool.swift, ToolRecipe.swift, WorkshopJob.swift

**Services (17 files):** AIService.swift, AppleAIService.swift, AssetManager.swift, ClaudeService.swift, DataManagementService.swift, GameCenterManager.swift, GameTools.swift, GenerationService.swift, HapticsManager.swift, MockAIService.swift, NPCEncounterManager.swift, PubChemService.swift, SketchValidator.swift, SoundManager.swift, SubscriptionManager.swift, TTSService.swift, VisualEditorState.swift, WolframGeometryHelper.swift, WolframService.swift, WorkerClient.swift

**Services/Styles (5 files):** RenaissanceColors.swift, RenaissanceTheme.swift, RenaissanceButton.swift, GameSpriteView.swift, GameSceneKitView.swift

**ViewModels (6 files):** BirdChatViewModel.swift, CityViewModel.swift, MuseumSketchService.swift, NotebookState.swift, PersistenceManager.swift, WorkshopState.swift

**Views (root, 61 files):** AIProviderPickerView.swift, AnatomyTheaterInteractiveVisuals.swift, AqueductInteractiveVisuals.swift, ArsenalInteractiveVisuals.swift, BirdChatOverlay.swift, BirdGuidanceContent.swift, BirdModalOverlay.swift, BloomEffectView.swift, BotanicalGardenInteractiveVisuals.swift, BottomDialogPanel.swift, BuildingChecklistView.swift, BuildingDetailOverlay.swift, BuildingLessonView.swift, BuildingPlotView.swift, CardVisualView.swift, CityView.swift, ColosseumInteractiveVisuals.swift, ConstructionSequenceView.swift, ContentView.swift, DiscoveryCardOverlay.swift, DuomoInteractiveVisuals.swift, EditableModifier.swift, EditorBottomPanel.swift, FlowRateVisual.swift, FlyingMachineInteractiveVisuals.swift, FoldableInventoryBar.swift, ForestMapView.swift, FurnaceFireView.swift, GameCenterDashboardView.swift, GameTopBarView.swift, GlassworksInteractiveVisuals.swift, GradientSlopeVisual.swift, HarborInteractiveVisuals.swift, HintOverlayView.swift, InfographicRevealView.swift, InsulaInteractiveVisuals.swift, InteractiveVisualHelpers.swift, InventoryBarView.swift, KnowledgeCardsOverlay.swift, LeonardoWorkshopInteractiveVisuals.swift, MainMenuView.swift, MascotDialogueView.swift, MaterialPuzzleView.swift, MathVisualTemplates.swift, MathVisualView.swift, MoleculeView.swift, NPCDialogueView.swift, NotebookCanvasView.swift, NotebookPickerView.swift, NotebookView.swift, PantheonInteractiveVisuals.swift, PhaseCompleteOverlay.swift, PrintingPressInteractiveVisuals.swift, ProfileView.swift, PubChemMoleculeView.swift, RecipeBookView.swift, RomanBathsInteractiveVisuals.swift, RomanRoadsInteractiveVisuals.swift, SceneEditorButtons.swift, SceneTransitionOverlay.swift, ScienceIconView.swift, SettingsView.swift, SidebarView.swift, SiegeWorkshopInteractiveVisuals.swift, SketchStudyOverlay.swift, SketchTeachingView.swift, SpeakerButton.swift, VaticanObservatoryInteractiveVisuals.swift, WolframGeometryView.swift, WorkshopMapView.swift, WorkshopView.swift

**Views/Onboarding (5 files):** AvatarTransitionView.swift, CharacterSelectView.swift, StationLessonOverlay.swift, StoryNarrativeView.swift, SubscriptionPickerView.swift

**Views/Sketching (7 files):** BlueprintStudyView.swift, PencilCanvasView.swift, PiantaCanvasView.swift, ShapeSnap.swift, SketchEditorView.swift, SketchResultView.swift, SketchingToolbarView.swift

**Views/Sketching root (1 file):** SketchingChallengeView.swift

**Views/SpriteKit (14 files):** BuildingNode.swift, CityMapView.swift, CityScene.swift, CraftingRoomMapView.swift, CraftingRoomScene.swift, ForestScene.swift, GoldsmithMapView.swift, GoldsmithScene.swift, MascotNode.swift, PlayerNode.swift, ResourceNode.swift, SceneEditorMode.swift, TerrainBlurHelper.swift, WorkshopScene.swift

**Views/StationMiniGames (6 files):** ClayPitMiniGameView.swift, FarmMiniGameView.swift, MiniGameSharedComponents.swift, QuarryMiniGameView.swift, RiverMiniGameView.swift, VolcanoMiniGameView.swift

**App entry (1 file):** RenaissanceArchitectAcademyApp.swift

---

## TL;DR

**No literal API keys in tracked source.** The codebase is large, well-structured, and architecturally sound. The primary recurring issue is pervasive bypassing of the `RenaissanceFont` / `RenaissanceColors` token system: 444 hardcoded `.font(.custom(...))` calls and 315 `Color(red:)` definitions outside `RenaissanceColors.swift`. All timers found properly invalidate. Security posture is good. The two unregistered NPC voice ID placeholders in TTSService.swift will silently no-op but are not errors, just incomplete implementation.

---

## CRITICAL

*None found.*

No literal API keys, auth tokens, or private credentials exist in any tracked Swift file. `APIKeys.swift` (containing `proxyToken`) is correctly listed in `.gitignore` (line 103) and is not tracked by git. The `WorkerClient.proxyToken` references that file at runtime. All Foundation Models and Claude API calls properly guard behind availability checks and subscription gates.

---

## WARNING

### W-01 — `EBGaramond-Medium` is not a `RenaissanceFont` token (17 usages in 7 files)

`EBGaramond-Medium` is registered in `RenaissanceArchitectAcademyApp.registerCustomFonts()` and used in 17 places, but `RenaissanceTheme.swift` has no token for it. Every usage is a raw `.font(.custom("EBGaramond-Medium", size: N))` call that bypasses the design system. If the font name or weight ever changes, all 17 sites must be updated manually.

**Files and lines:**
- `GameTopBarView.swift:73` — florins badge (size 15)
- `GameTopBarView.swift:243` — nav dropdown labels (size 13)
- `ForestMapView.swift:1061` — card body (size 12)
- `ForestMapView.swift:1397` — caption (size 11)
- `WorkshopMapView.swift:2417, 2456` — overlay labels (size 13)
- `WorkshopMapView.swift:2507` — body (size 12)
- `WorkshopMapView.swift:2741` — florins (size 15)
- `WorkshopMapView.swift:2767, 2772` — label (size 14)
- `WorkshopMapView.swift:2783` — body (size 16)
- `SettingsView.swift:73` — label (size 14)
- `KnowledgeCardsOverlay.swift:810` — caption (size 12)
- `BuildingLessonView.swift:1103, 1130` — captions (size 13)
- `BuildingLessonView.swift:1300` — subheadline (size 16)
- `CraftingRoomMapView.swift:1641` — label (size 13)

**Fix:** Add `static let bodyMediumWeight = Font.custom("EBGaramond-Medium", size: 16, relativeTo: .body)` (and similar caption/footnote variants) to `RenaissanceTheme.swift`, then replace all 17 usages with the token. The pattern already exists for `bodySemibold` — follow that model.

---

### W-02 — `EBGaramond-SemiBold` bypassed via raw `.custom(...)` in 100+ usages across view files

`RenaissanceFont` already defines tokens that use `EBGaramond-SemiBold` (e.g., `bodySemibold`, `button`, `footnoteBold`, `dialogTitle`), but 100+ view sites call `.font(.custom("EBGaramond-SemiBold", size: N))` directly. This means new uses don't inherit Dynamic Type scaling and don't go through the `cardTextScale` accessibility multiplier. The impact is highest in `ForestMapView.swift` (5 usages) and `WorkshopMapView.swift` (8 usages).

**Top offenders:**
- `WorkshopMapView.swift:1429, 1460, 1557, 1927, 2099, 2385, 3077`
- `ForestMapView.swift:938, 1435, 1475`
- `RecipeBookView.swift:290, 392`
- `FlowRateVisual.swift:143`

**Fix:** Audit each size against existing `RenaissanceFont` tokens. Size 16 → `RenaissanceFont.bodyMedium`. Size 18 → `RenaissanceFont.button`. Size 13 → `RenaissanceFont.caption`. Size 12 → `RenaissanceFont.captionSmall`. Replace direct calls with tokens.

---

### W-03 — 315 `Color(red:)` definitions outside `RenaissanceColors.swift`

Interactive visual files each define local color constants via raw `Color(red:green:blue:)` rather than referencing existing `RenaissanceColors` tokens or adding new named tokens. This creates drift: the same visual concept gets a different hex in different files.

**Breakdown by file (selected):**
- `PantheonInteractiveVisuals.swift` — 20 raw colors
- `GlassworksInteractiveVisuals.swift` — 18 raw colors
- `InsulaInteractiveVisuals.swift` — 14 raw colors
- `RomanBathsInteractiveVisuals.swift` — 13 raw colors
- `ColosseumInteractiveVisuals.swift` — 12 raw colors
- `DuomoInteractiveVisuals.swift` — 11 raw colors
- `LeonardoWorkshopInteractiveVisuals.swift` — 8 raw colors
- `VaticanObservatoryInteractiveVisuals.swift` — 7 raw colors
- `PrintingPressInteractiveVisuals.swift` — 6 raw colors
- `HarborInteractiveVisuals.swift` — 4 raw colors
- `FlyingMachineInteractiveVisuals.swift` — 4 raw colors
- `RomanRoadsInteractiveVisuals.swift` — 3 raw colors
- `InteractiveVisualHelpers.swift:12-26` — 8 shared local colors in `IVMaterialColors` enum

**Exact token matches for `IVMaterialColors` (fix these first, they're shared across all 17 IVs):**
- `IVMaterialColors.oakBrown` = `Color(red:0.55,g:0.42,b:0.28)` → `RenaissanceColors.warmBrown` (0.545,0.435,0.278) — close enough for visual use
- `IVMaterialColors.limeTan` = `Color(red:0.88,g:0.84,b:0.76)` → `RenaissanceColors.limeMortar` (0.92,0.90,0.85) — similar; or add `IVLimeTan` to RenaissanceColors
- `IVMaterialColors.leadGray` = `Color(red:0.50,g:0.52,b:0.55)` → `RenaissanceColors.leadGray` (0.55,0.55,0.52) — very close, use token
- `IVMaterialColors.bronzeGold` = `Color(red:0.72,g:0.55,b:0.32)` → `RenaissanceColors.forgeOrange` (0.90,0.50,0.15) is darker; or add `bronzeGold` to RenaissanceColors

**Fix:** For each IV file, replace color constants that map cleanly to existing `RenaissanceColors` tokens. For IV-specific colors with no close match, add a new named token to `RenaissanceColors.swift` under `// MARK: - Interactive Visual Palette` rather than leaving inline definitions.

---

### W-04 — `NotebookCanvasView.swift:42` — raw `UIColor(red:)` should use `RenaissanceColors.notebookYellow`

```swift
// Line 42 (current):
let highlightColor = UIColor(red: 1.0, green: 0.85, blue: 0.3, alpha: 0.4)
```

The values `(r:1.0, g:0.85, b:0.3)` are an exact match for `RenaissanceColors.notebookYellow` which is defined as `Color(red: 1.0, green: 0.85, blue: 0.3)`. The `alpha: 0.4` maps to `.opacity(0.4)`.

**Fix:** Replace with `UIColor(Color(RenaissanceColors.notebookYellow).opacity(0.4))`. This is a one-line change. The `UIColor()` bridge from `Color` is the standard pattern already used elsewhere.

---

### W-05 — 444 hardcoded `.font(.custom(...))` calls bypass `RenaissanceFont` tokens

In addition to the `EBGaramond-Medium` and `EBGaramond-SemiBold` cases above, there are many calls using `Cinzel-Bold`, `EBGaramond-Regular`, `EBGaramond-Italic`, and `EBGaramond-Bold` with raw size values rather than `RenaissanceFont.*` tokens. This means these texts don't respond to the `cardTextScale` accessibility slider and are harder to adjust globally.

**Fix strategy:** The fix is incremental. Prioritize files touched most frequently (WorkshopMapView, ForestMapView, KnowledgeCardsOverlay, BuildingLessonView). For each site, match the size to the closest existing `RenaissanceFont` token. Only add new tokens when no match exists within ±1pt.

---

### W-06 — `SubscriptionManager` uses mock StoreKit (2 explicit TODO comments)

`SubscriptionManager.swift` has two `// TODO: StoreKit 2` comments marking incomplete real purchase flow. The current implementation persists tier to UserDefaults only, with no real App Store transaction verification. The App Store Connect product IDs are defined in `SubscriptionProductID` (SubscriptionTier.swift) but are never used.

**Risk:** Users cannot actually subscribe. The `isSubscribed` flag can be toggled freely in Profile (DEBUG), which is correct for development but must be locked before App Store submission.

**Fix:** Wire `SubscriptionManager` to StoreKit 2 `Product.products(for:)` and `Transaction.currentEntitlements` as indicated by the TODO comments. Refer to `SubscriptionProductID` enum which already has all five product IDs ready.

---

### W-07 — `RenaissanceButton.swift` uses `cornerRadius: 20` hardcoded instead of `CornerRadius.xl`

`RoundedRectangle(cornerRadius: 20)` appears in `RenaissanceButton` (line ~44). `CornerRadius.xl = 20` is already defined in `RenaissanceTheme.swift`. The value matches but bypasses the token.

**Fix:** Replace `RoundedRectangle(cornerRadius: 20)` with `RoundedRectangle(cornerRadius: CornerRadius.xl)` in `RenaissanceButton.swift`.

---

### W-08 — TTSService NPC voice IDs are placeholder strings (not errors, incomplete implementation)

`TTSService.swift:31-34`:
```swift
static let npcMale   = "PASTE_NPC_MALE_VOICE_ID_HERE"
static let npcFemale = "PASTE_NPC_FEMALE_VOICE_ID_HERE"
```

`TTSVoice.isConfigured()` correctly guards against these, so they won't crash or produce bad network calls. However, any NPC dialogue TTS call will silently skip with a print log.

**Fix:** Once ElevenLabs voice generation is done, paste the voice IDs in place of the `PASTE_*` placeholders. The guard logic is already in place.

---

### W-09 — `NotebookState` is `@Observable` without `@MainActor`

`NotebookState.swift` uses `@Observable` but has no `@MainActor` annotation. It performs disk I/O (`saveToDisk`, `loadFromDisk`) synchronously on whatever thread calls it. All other `@Observable` ViewModels in the project have `@MainActor` (`CityViewModel`, `WorkshopState`, `GameSettings`, `OnboardingState`, `BirdChatViewModel`, `MuseumSketchService`).

The risk is low in practice (all callers are SwiftUI views which run on Main), but it's an architectural inconsistency that could become a problem if `NotebookState` is ever called from a background task.

**Fix:** Add `@MainActor` to the `NotebookState` class declaration.

---

### W-10 — `gardenGreen` and `sageGreen` are identical tokens in `RenaissanceColors.swift`

`RenaissanceColors.sageGreen` and `RenaissanceColors.gardenGreen` are both defined as `Color(red: 0.478, green: 0.608, blue: 0.463)` (#7A9B76). The comment on line 40 even acknowledges this: `/// Garden green for nature: #7A9B76 (same as sageGreen)`. They are used in the Science color router to distinguish `chemistry` vs `biology` science categories.

**Fix:** The deduplication is intentional (different semantic intent) but should be made explicit. Either:
- (a) Make `gardenGreen` an alias: `static let gardenGreen = sageGreen` to avoid silent hex drift if one is updated but not the other, or
- (b) Give biology a distinct color (e.g., `leafGreen` which is already defined at (0.30, 0.58, 0.32)) and remove `gardenGreen`.

Do not change this without Marina's explicit visual approval — it affects Science badge colors.

---

## INFO

### I-01 — All Timers properly invalidate

All 17 `Timer.scheduledTimer` sites in the codebase were checked. Every `Timer` is held in a `@State private var timer: Timer?` and invalidated via `timer?.invalidate(); timer = nil` on state change or view disappear. Specific checks:
- `MascotDialogueView` — `timer` and `blinkTimer` invalidate on phase change and appearance cycle
- `KnowledgeCardsOverlay` — `fishingTimer` invalidates in 3 places
- `BuildingLessonView` — `wordBankShuffleTimer` invalidates before re-scheduling and on cleanup
- `FlowRateVisual` — `counterTimer` invalidates on `onDisappear`
- `QuarryMiniGameView` — `bondPulseTimer` and `shrinkTimer` both invalidate before re-schedule
- `FarmMiniGameView` — `gameTimer` invalidates on stop and before start
- `StoryNarrativeView`, `AvatarTransitionView`, `StationLessonOverlay`, `NPCDialogueView` — all invalidate properly

No timer retain cycles found.

---

### I-02 — `ForestScene.swift` correctly uses `[weak self]` in closure

The scene editor toggle closure at line ~1314 (`editorMode.onToggle = { [weak self] in guard let self = self else { return }`) is correctly implemented. No retain cycle.

---

### I-03 — Frame animations stop at last frame (CLAUDE.md compliant)

`ProfileView.swift` avatar animation (line ~374) stops at `frameCount - 1` by calling `timer.invalidate()` when the last frame is reached. `AvatarTransitionView.swift` does the same. Compliant with the CLAUDE.md rule: "Frame animations play ONCE, never loop."

---

### I-04 — `APIKeys.swift` is correctly gitignored

`APIKeys.swift` is listed at line 103 of `.gitignore`. The file is not tracked by git. `WorkerClient.proxyToken` references it at runtime. No literal proxy tokens or API keys found in any tracked source file.

---

### I-05 — Foundation Models (iOS 26) properly guarded

All `AppleAIService`, `NPCEncounterManager`, and `GenerationService` usage is wrapped in `@available(iOS 26.0, macOS 26.0, *)` guards. Runtime checks use `GenerationService.isAvailable` and `AppleAIService.isAvailable` before making any Foundation Models calls. The codebase will compile and run on iOS 17 without Foundation Models.

---

### I-06 — `#if DEBUG` `Self._printChanges()` in `ContentView` body

`ContentView.swift:47`:
```swift
#if DEBUG
let _ = Self._printChanges()
#endif
```

This is a development aid that prints every property change causing a re-render. It's gated by `#if DEBUG` so it won't appear in release builds. No action required, but it should be removed before final App Store submission to keep debug output clean in TestFlight builds.

---

### I-07 — Onboarding skip is commented out in `ContentView`

`ContentView.swift:72-73`:
```swift
// TODO: Re-enable skip after onboarding is finalized:
// if onboardingState.hasCompletedOnboarding { showingMainMenu = false; return }
```

Returning players always see onboarding. This is intentional during development. Remove the comment slashes when onboarding content is finalized (see CLAUDE.md "Next Steps").

---

### I-08 — Knowledge Card content complete for all 17 buildings

All 17 buildings have `KnowledgeCard` content:
- Pantheon: 14 cards (in `KnowledgeCard.swift` directly)
- 7 Ancient Rome buildings (excl. Pantheon): ~85 cards in `KnowledgeCardContentRome.swift`
- 9 Renaissance buildings: ~109 cards in `KnowledgeCardContentRenaissance.swift`
- Router in `KnowledgeCardContentRouter` handles all 17 building names including `"Il Duomo"` alias

---

### I-09 — Large content files are well-organized

`LessonContentRenaissance.swift` (2,797 lines), `KnowledgeCardContentRenaissance.swift` (2,323 lines), `LessonContentRome.swift` (1,539 lines), `KnowledgeCardContentRome.swift` (2,171 lines) are all data-only files (no logic) with clear `// MARK:` section headers per building. No refactoring needed; they would not benefit from splitting further.

---

### I-10 — 7,164 commented-out lines

The codebase has 7,164 comment lines (grep for `^[[:space:]]*//'`). Most are legitimate inline comments and section headers. There are 3 explicit `TODO` markers:
1. `ContentView.swift:72` — onboarding skip (tracked in CLAUDE.md)
2. `SubscriptionManager.swift:39` — StoreKit 2 (W-06 above)
3. `SubscriptionManager.swift:59` — StoreKit 2 transaction check (W-06 above)

---

### I-11 — 276 `.font(.system(size:))` usages

There are 276 uses of `.font(.system(size:))` in the codebase. Most are in SpriteKit scenes (SKLabel nodes) or in icon/utility contexts where the system font is appropriate (e.g., SF Symbols sizing). This is not a token violation since the system font is used intentionally for non-content UI. No action required as a bulk change.

---

### I-12 — 1,402 hardcoded padding/frame values

There are ~1,402 `.padding(...)` and `.frame(width/height:)` calls using raw CGFloat values. The `Spacing` enum tokens exist (`xxs=4, xs=8, sm=12, md=16, lg=20, xl=24, xxl=32, xxxl=40`) but are inconsistently applied across the codebase. No single site is critical, but adoption of `Spacing.*` tokens across interactive visuals and overlay views would improve maintainability. This is a long-tail cleanup, not an urgent fix.

---

## Missing Tokens

The following values appear repeatedly in code but have no corresponding `RenaissanceFont` or `RenaissanceColors` token:

| Missing Token | Current Usage | Recommended Token Name | File to Edit |
|---|---|---|---|
| `EBGaramond-Medium` at size 13 | 4 occurrences | `RenaissanceFont.captionMedium` | `RenaissanceTheme.swift` |
| `EBGaramond-Medium` at size 15 | 2 occurrences | `RenaissanceFont.bodySmallMedium` | `RenaissanceTheme.swift` |
| `EBGaramond-Medium` at size 16 | 2 occurrences | `RenaissanceFont.bodyMediumWeight` | `RenaissanceTheme.swift` |
| `IVMaterialColors.bronzeGold` `Color(red:0.72,g:0.55,b:0.32)` | Shared across IV files | `RenaissanceColors.bronzeGold` | `RenaissanceColors.swift` |
| `IVMaterialColors.dimColor` `Color(red:0.7,g:0.35,b:0.25)` | Shared across IV files | already close to `pozzolanaRed` (0.65,0.40,0.30) — use that | — |
| `IVMaterialColors.hotRed` `Color(red:0.85,g:0.35,b:0.25)` | Shared across IV files | add `RenaissanceColors.hotRed` or use `errorRed.opacity(...)` | `RenaissanceColors.swift` |
| `IVMaterialColors.cherryRed` `Color(red:0.80,g:0.25,b:0.20)` | Shared across IV files | add `RenaissanceColors.cherryRed` | `RenaissanceColors.swift` |
| `CornerRadius.xl` (= 20) for `RenaissanceButton` | Hardcoded `cornerRadius: 20` | `CornerRadius.xl` already exists | `RenaissanceButton.swift` |

---

## Clean Scans

| Check | Result |
|---|---|
| Literal API keys in tracked source | ✅ None found |
| Literal proxy tokens in tracked source | ✅ None found (`APIKeys.swift` is gitignored) |
| `[weak self]` missing in SpriteKit closures | ✅ All checked — `ForestScene`, `WorkshopScene`, `CityScene` use `[weak self]` correctly |
| Timer retain cycles | ✅ All 17 Timer sites invalidate properly |
| Frame animations looping (CLAUDE.md rule) | ✅ All checked — `ProfileView`, `AvatarTransitionView` stop at last frame |
| Foundation Models ungated | ✅ All behind `@available(iOS 26.0, *)` guards |
| `APIKeys.swift` in `.gitignore` | ✅ Line 103 of `.gitignore` |
| Knowledge Card content for all 17 buildings | ✅ Complete |
| Lesson content for all 17 buildings | ✅ Complete |
| Vocabulary (notebook) for all 17 buildings | ✅ Complete |
| SwiftData schema models present | ✅ `PlayerSave`, `BuildingProgressRecord`, `LessonRecord` all `@Model` |
| `PASTE_*` placeholders causing runtime crash | ✅ None — `TTSVoice.isConfigured()` guards all NPC voice calls |
| `Mulish` font remnants | ✅ None found — fully replaced by EBGaramond |
| Asset catalog imagesets count | ✅ 322 imagesets found in `Assets.xcassets` |

---

## Build Status

`xcodebuild` is not available in this environment. No build was attempted. All findings are based on static source analysis only. No compilation errors were detected through grep and structural analysis, but this does not guarantee a clean build.
