# Weekly Health Check — 2026-05-15

## 1. Files Read (Step 0)

**178 Swift files read** across Models, Services, ViewModels, and Views.

Style/theme files read in full:
- `Services/Styles/RenaissanceColors.swift`
- `Services/Styles/RenaissanceTheme.swift` (Spacing, CornerRadius, RenaissanceFont, RenaissanceShadow, all modifiers)
- `Services/Styles/RenaissanceButton.swift`

---

## 2. TL;DR

**YELLOW** — No crashes or security secrets exposed; 1 build blocker on fresh clone, 2 performance risks, widespread hardcoded font sizes in View layer.

| Severity | Count |
|----------|-------|
| CRITICAL | 1 |
| WARNING  | 26 |
| INFO     | 5 |

---

## 3. CRITICAL

### C-01 — `APIKeys.swift` missing from repo — fresh clone won't compile
**File:** `Services/APIKeys.swift` (referenced in pbxproj, gitignored)  
`WorkerClient.swift:49` and `TTSService.swift:87` both reference `APIKeys.proxyToken`. The file is correctly gitignored so the real token stays out of git. However, there is **no `APIKeys.swift.example` template** anywhere in the repo. A new developer or CI environment that clones the project gets a build failure with "undeclared identifier 'APIKeys'" and no documentation of what file to create.

**Fix:** Add `RenaissanceArchitectAcademy/Services/APIKeys.swift.example` (also gitignored or committed as `.example`) containing:
```swift
enum APIKeys {
    static let proxyToken = "PASTE_YOUR_HEX_TOKEN_HERE"
}
```
Update `README.md` or `CLAUDE.md` to note that this file must be created before building.

---

## 4. WARNING

### Performance / Memory

#### W-01 — `repeatForever` animations with no cancellation path
**File:** `Views/InteractiveVisualHelpers.swift`  
Four `withAnimation(.repeatForever...)` calls start continuous animations but have no `.onDisappear` cancellation. If the parent `KnowledgeCardsOverlay` or `BuildingLessonView` is dismissed while any of these visuals are active, SwiftUI continues driving the animation state indefinitely on a detached view.

| Line | Visual | State driven |
|------|--------|-------------|
| ~70 | `RatioDiagramVisual` | `animateFlow` |
| ~218 | `ForceArrowVisual` | `arrowPulse` |
| ~365 | `FlowCycleVisual` | `flowAngle` |
| ~756 | `MechanismVisual` | `rotation` |

**Fix:** Add `.onDisappear { animateFlow = false }` (and equivalent) on each visual, or wrap the `withAnimation` in a `.task { }` that runs only while the view is alive.

#### W-02 — Orphaned fade timers in SoundManager
**File:** `Services/SoundManager.swift:347,363`  
`fadeIn(player:targetVolume:duration:)` and `fadeOut(player:duration:)` each create a `Timer.scheduledTimer` that is **not stored in a property**. If `playMusic(_:)` is called again before a fade completes, the orphaned timer keeps mutating the replaced `AVAudioPlayer`'s volume. Rapid scene transitions (e.g., City → Workshop → City) can stack multiple conflicting fade timers.

**Fix:** Assign the timer to a stored `private var fadingTimer: Timer?` property in `SoundManager`, invalidating the previous one before starting a new fade.

---

### Dead Code

#### W-03 — Legacy geometric-validation fields on `PiantaPhaseData` always empty
**File:** `Models/SketchingChallenge.swift:148–173`  
`targetRooms: [RoomDefinition]`, `targetColumns: [GridCoord]`, `symmetryAxis: SymmetryAxis?`, and `proportionalRatios: [ProportionalRatio]` are all defaulted to `[]` / `nil` in every entry in `SketchingContent.swift` and are acknowledged in comments as "no longer enforced." Types `RoomShape`, `RoomDefinition`, `ProportionalRatio`, and `SymmetryAxis` have zero live callers anywhere in the codebase. Additionally `WallSegment.isHorizontal`, `.isVertical`, and `.length` (lines 31–42) are never accessed.

**Fix:** Remove the four dead fields, the three `WallSegment` computed properties, and the four dead types. They add ~80 lines of noise and mislead readers into thinking validation is stricter than it is.

#### W-04 — `StudentProfile` struct is largely unused
**File:** `Models/StudentProfile.swift:71–158`  
`Resources` struct (lines 71–84) is never instantiated. `StudentProfile` instance properties, `newStudent(name:)` factory, `overallProgress`, and `totalAchievements` are never read anywhere — the live game drives state through `CityViewModel` and `PlayerSave` (SwiftData). Only the static `defaultAchievements` is used externally (`ProfileView`).

**Fix:** Remove `Resources` entirely. Remove `newStudent`, `overallProgress`, `totalAchievements`, and the unused instance fields from `StudentProfile`. Keep only `defaultAchievements` (static) and `MasteryLevel`/`Achievement` enums that are referenced.

#### W-05 — Multiple unused functions in Services layer

| File | Line | Symbol | Notes |
|------|------|--------|-------|
| `Services/GenerationService.swift` | 107 | `registerSession(_:for:)` | Never called |
| `Services/GenerationService.swift` | 119 | `releaseSession(for:)` | Never called |
| `Services/GenerationService.swift` | 124 | `releaseAllSessions()` | Never called |
| `Services/GenerationService.swift` | 163 | `generateText(prompt:contextId:instructions:)` | Never called |
| `Services/NPCEncounterManager.swift` | 166 | `clearCurrentNPC()` | Never called |
| `Services/NPCEncounterManager.swift` | 172 | `resetSession()` | Never called |
| `Services/NPCEncounterManager.swift` | 193 | `clearCache()` | Never called |
| `Services/WolframService.swift` | 20 | `WolframResult.imageURL(for:)` | Never called |
| `Services/WolframService.swift` | 137 | `shortAnswer(_:)` | Never called |
| `Services/WolframService.swift` | 157 | `chemicalProperties(of:)` | Never called |
| `Services/WolframService.swift` | 173 | `reaction(_:)` | Never called |
| `Services/GameCenterManager.swift` | 154 | `showAchievements()` | Never called |
| `Services/GameCenterManager.swift` | 170 | `showLeaderboards()` | Never called |
| `Services/GameCenterManager.swift` | 293 | `showAccessPoint()` | Never called |
| `Services/GameCenterManager.swift` | 300 | `hideAccessPoint()` | Never called |
| `Services/SubscriptionManager.swift` | 77 | `productID(for:plan:)` | Only referenced by commented-out StoreKit 2 block |
| `ViewModels/PersistenceManager.swift` | 65 | `migrateFromUserDefaults` | Never called, dead migration path |
| `Services/StationCompounds.swift` | 173 | `compoundForVisit(station:visitNumber:)` | Never called; callers use `compounds(for:)` directly |

#### W-06 — Unused `@Published` / `@State` properties

| File | Line | Property | Issue |
|------|------|----------|-------|
| `Services/GenerationService.swift` | 37 | `@Published isGenerating` | Set internally, never observed by any view |
| `Services/NPCEncounterManager.swift` | 53 | `@Published isGenerating` | Set internally, never observed |
| `Services/AppleAIService.swift` | 41 | `currentTask: Task<Void,Never>?` | Declared but never assigned; `.cancel()` always no-ops |
| `Views/ConstructionSequenceView.swift` | 17 | `@State private var auroraPhase = false` | Set to `true` in `.onAppear`, never read anywhere in the view |

**Fix:** Remove `auroraPhase` from `ConstructionSequenceView`. Remove or wire up the two `isGenerating` publishers if they're ever needed for loading indicators.

#### W-07 — Unused model properties

| File | Line | Symbol |
|------|------|--------|
| `Models/Building.swift` | 205 | `Building.locationName` — never read externally |
| `Models/BuildingProgress.swift` | 141 | `GameRewards.jobCompleteFlorins = 10` — never referenced |
| `Models/ChatMessage.swift` | 8 | `timestamp` — stored, never read |
| `Models/GameSettings.swift` | 170 | `spritePillFillRGBA` — never used in any SpriteKit scene |
| `Models/GameSettings.swift` | 177 | `spriteTextColor` — never referenced outside file |
| `Models/LessonRecord.swift` | 11 | `version` — stored, never queried or migrated on |
| `Models/LessonRecord.swift` | 12 | `lastModified` — stored, never queried |
| `Models/SketchingChallenge.swift` | 217 | `SketchingProgress.completedCount` — never read anywhere |
| `Services/HapticsManager.swift` | 13 | `isEnabled` — always `true`; no external toggle wired to Settings |

#### W-08 — `Tool.pitchfork` has no `ToolRecipe` (functional gap)
**File:** `Models/Tool.swift:9`  
`Tool.pitchfork` declares `requiredAtStation: .farm`, so `Tool.requiredFor(station: .farm)` returns `.pitchfork`. However, `ToolRecipe.allRecipes` contains no entry for `.pitchfork`. The player can never craft it. The farm station will always show an uncraftable requirement.

**Fix:** Either add a recipe for `.pitchfork` in `ToolRecipe.swift`, or remove `.pitchfork` from `Tool.swift` and the farm station requirement.

---

### Hardcoded Values

#### W-09 — ElevenLabs voice IDs hardcoded in binary
**File:** `Services/TTSService.swift:24,28`
```swift
static let bird        = "bNHG92L4700oZ2OVXQSc"
static let storyteller = "yUUnPL3w0TMlYSSSuEO8"
```
Voice IDs identify paid ElevenLabs voice assets and ride along in the app binary. They are not API keys, but they can be extracted and used by anyone who reverse-engineers the binary to call the ElevenLabs API directly. Already behind the Worker proxy (which requires `APIKeys.proxyToken`), so risk is low — but they should move to the Worker's server-side config or `APIKeys.swift`.

**Fix:** Move voice IDs to the Cloudflare Worker config or add them to `APIKeys.swift` alongside the proxy token.

#### W-10 — `Amellina` font used directly without a `RenaissanceFont` token
**File:** `Views/MainMenuView.swift:61`
```swift
.font(.custom("Amellina", size: taglineSize + 6, relativeTo: .headline))
```
`Amellina` is registered in `RenaissanceArchitectAcademyApp.swift` but has no token in `RenaissanceTheme.swift`. The expression `taglineSize + 6` is also a raw arithmetic offset, not a token.

**Fix:** Add to `RenaissanceTheme.swift`:
```swift
static let taglineAccent = Font.custom("Amellina", size: 26, relativeTo: .headline)
```
Then use `RenaissanceFont.taglineAccent` at the call site.

#### W-11 — `UIColor` highlight duplicates `RenaissanceColors.notebookYellow`
**File:** `Views/NotebookCanvasView.swift:42`
```swift
let highlightColor = UIColor(red: 1.0, green: 0.85, blue: 0.3, alpha: 0.4)
```
The RGB values are identical to `RenaissanceColors.notebookYellow` (`Color(red: 1.0, green: 0.85, blue: 0.3)`). Because PencilKit requires `UIColor`, a perfect conversion cannot use `SwiftUI.Color` directly, but it should reference the same source of truth.

**Fix:** Add to `RenaissanceColors.swift`:
```swift
static let notebookYellowUIColor = UIColor(red: 1.0, green: 0.85, blue: 0.3, alpha: 1.0)
```
Then use `.withAlphaComponent(0.4)` at the call site.

#### W-12 — Hardcoded `.font(.system(size: N))` throughout View layer
The following files use raw `.font(.system(size: N))` calls instead of `RenaissanceFont` tokens. Since `RenaissanceFont` tokens use `EBGaramond`/`Cinzel`, `.system(size:)` breaks the Renaissance aesthetic.

| File | Occurrences | Example |
|------|-------------|---------|
| `Views/ForestMapView.swift` | 11 | `.font(.system(size: 36))` (line 841) |
| `Views/WorkshopMapView.swift` | 8 | `.font(.system(size: 52))` (line 2988) |
| `Views/RecipeBookView.swift` | 5 | `.font(.system(size: 68))` (line 125) |
| `Views/AnatomyTheaterInteractiveVisuals.swift` | 5 | `.font(.system(size: 30))` (line 98) |
| `Views/MascotDialogueView.swift` | 1 | `.font(.system(size: isCompact ? 20 : 36))` (line 222) |
| `Models/Material.swift` | 1 | `.font(.system(size: size * 0.7))` (line 164) |
| `Models/Tool.swift` | 1 | `.font(.system(size: size * 0.75))` (line 125) |
| `Models/CraftedItem.swift` | 1 | `.font(.system(size: size * 0.7))` (line 99) |

**Fix:** Map each to an appropriate `RenaissanceFont` token (e.g., size 36 → `RenaissanceFont.title`, size 13-14 → `RenaissanceFont.caption`). For icon-size views in Models that pass `size` as a parameter, use `RenaissanceFont.caption` or `RenaissanceFont.bodySmall` as a baseline.

#### W-13 — Raw system color literals in Views (non-debug)

| File | Line | Color | Suggested token |
|------|------|-------|-----------------|
| `Views/ForestMapView.swift` | 462 | `.foregroundStyle(.yellow)` | `RenaissanceColors.goldSuccess` |
| `Views/MaterialPuzzleView.swift` | 505 | `.foregroundStyle(.yellow)` | `RenaissanceColors.goldSuccess` |
| `Views/ColosseumInteractiveVisuals.swift` | 875 | `.foregroundStyle(.orange)` | `RenaissanceColors.furnaceOrange` |
| `Views/HarborInteractiveVisuals.swift` | 537 | `.foregroundStyle(.orange)` | `RenaissanceColors.furnaceOrange` |
| `Views/InsulaInteractiveVisuals.swift` | 1082 | `.foregroundStyle(.orange)` | `RenaissanceColors.furnaceOrange` |

Note: `.foregroundStyle(.white)` appears ~94 times across View files. Most of these are on text/icons laid over colored backgrounds where `Color.white` is intentional and correct. No change needed for those.

---

### Commented-Out Code Blocks

#### W-14 — StoreKit 2 purchase logic commented out
**File:** `Services/SubscriptionManager.swift:39–44`  
6-line block of real StoreKit 2 logic marked `// TODO: StoreKit 2`. The subscription purchase flow is currently a stub. If any user attempts in-app purchase, they will see no product and no confirmation.

#### W-15 — Claude subscription gate disabled for dev
**File:** `ViewModels/BirdChatViewModel.swift:112–116`  
5-line block that was gating bird chat behind a subscription check, currently bypassed with "skip for now — always allow in dev." All users get premium bird chat for free.

*(W-14 and W-15 are known development stubs — document here for tracking.)*

#### W-16 — Dead florin animation system in `KnowledgeCardsOverlay`
**File:** `Views/KnowledgeCardsOverlay.swift:1756–1828`  
Five functions (`spawnFlorins`, `florinBurstLayer`, `florinPosition`, `florinRotation`, `florinCoinView`) and one computed view (`birdEncouragement`) plus two state properties (`@State private var fallingFlorins: [FallingFlorin]`, `@State private var showFlorinTotal`) are completely dead. `spawnFlorins()` is never called, so `fallingFlorins` is always empty and `showFlorinTotal` is never set to `true`. An earlier guidance-bubble feature was also removed: `guidanceBubbleView(card:)` (line ~2001) still exists but the comment at line 176 confirms it was removed from the view body; `showGuidanceBubble` and `guidanceBubbleCard` state properties (lines 138–139) are written but never consumed.

**Fix:** Delete the entire florin-animation block (~75 lines), the `birdEncouragement` view, `guidanceBubbleView`, and the four dead state properties.

#### W-17 — `NotebookView.swift` bold path is visually dead
**File:** `Views/NotebookView.swift:689`  
Both branches of `markdownText(_:)` apply `Font.custom("Delius-Regular", size: 15)` — the `isBold` branch should use a bold or semibold variant but doesn't. The entire `parseBold` function and `isBold` field produce no visible difference.

**Fix:** Change the bold branch to `Font.custom("EBGaramond-SemiBold", size: 15)` (maps to `RenaissanceFont.bodySmall` weight).

#### W-18 — Dead types and unused functions across View files

| File | Symbol | Type |
|------|--------|------|
| `Views/MascotDialogueView.swift:351` | `SplashCharacter` struct | Defined, never instantiated |
| `Views/MascotDialogueView.swift:639` | `Triangle` struct | Defined, never used |
| `Views/MascotDialogueView.swift` | `BirdCharacter.playFlyToSit()` | Defined, never called |
| `Views/PantheonInteractiveVisuals.swift:1463` | `BowlShape` struct | Defined, never used |
| `Views/KnowledgeCardsOverlay.swift:1912` | `nextStationHint(for:in:)` | Defined, never called in file |
| `Views/HintOverlayView.swift:31` | `@State var wasEarnPath: Bool` | Set at L599/L631, never read in any UI path |
| `Views/ProfileView.swift:579` | `isUnlocked` ternary | Both branches return same `RenaissanceColors.sepiaInk`; unlock state has no visual effect |

#### W-19 — `PulseModifier` duplicated across two files
**Files:** `Views/Sketching/SketchStudyOverlay.swift` and `Views/SketchTeachingView.swift`  
Identical `PulseModifier: ViewModifier` struct is defined independently in both files. Extract to a shared location (e.g., `RenaissanceTheme.swift` or a new `Views/Shared/` file).

#### W-20 — Interactive visual color drift: shared material colors redefined with slightly different RGB values

`IVMaterialColors` in `InteractiveVisualHelpers.swift` is the canonical source, but several files redefine the same color names with drifted values:

| Color name | Canonical (`IVMaterialColors`) | Drifted redefinition | File |
|------------|-------------------------------|----------------------|------|
| `oakBrown` | `(0.55, 0.42, 0.28)` | `(0.58, 0.44, 0.30)` | `InsulaInteractiveVisuals.swift:59` |
| `oakBrown` | `(0.55, 0.42, 0.28)` | `(0.55, 0.40, 0.28)` | `SiegeWorkshopInteractiveVisuals.swift:63` |
| `bronzeGold` | `(0.72, 0.55, 0.32)` | `(0.72, 0.58, 0.35)` | `SiegeWorkshopInteractiveVisuals.swift:64` |
| `leadGray` | `(0.50, 0.52, 0.55)` | `(0.48, 0.50, 0.53)` | `PrintingPressInteractiveVisuals.swift:55` |
| `ironDark` | `(0.35, 0.33, 0.32)` | `(0.32, 0.30, 0.29)` | `PrintingPressInteractiveVisuals.swift:56` |
| `poplarLight` | `(0.78, 0.72, 0.58)` | `(0.80, 0.74, 0.60)` | `InsulaInteractiveVisuals.swift:60` |
| `poplarLight` | `(0.78, 0.72, 0.58)` | `(0.76, 0.70, 0.55)` | `LeonardoWorkshopInteractiveVisuals.swift:61` |

**Fix:** Remove the private redefinitions and reference `IVMaterialColors.*` directly.

#### W-21 — `.foregroundColor()` deprecated API in `KnowledgeCardsOverlay`
**File:** `Views/KnowledgeCardsOverlay.swift:770,775`  
Two calls use the deprecated `.foregroundColor(color)` modifier; should be `.foregroundStyle(color)`.

#### W-22 — `ProfileView` animation timer not stored — can't be cancelled
**File:** `Views/ProfileView.swift:374`  
`Timer.scheduledTimer(withTimeInterval: 1.0 / fps, repeats: true)` is created in `.onAppear` but the timer reference is not stored in a `@State` property. If the view is dismissed before the animation completes, the timer fires after the view is gone. The timer correctly calls `timer.invalidate()` when it reaches the last frame (line 378), but there is no `.onDisappear` cancellation for early dismissal.

**Fix:** Store the timer in `@State private var animTimer: Timer?` and invalidate in `.onDisappear`.

#### W-23 — `SketchStudyOverlay` has an unfilled Xcode placeholder comment
**File:** `Views/SketchStudyOverlay.swift:518`  
```swift
/// <#Description#>
```
Unfilled template documentation placeholder. Remove or fill in.

---

## 5. INFO

### I-01 — `HistoricalNPCContent` portrait prompts are all empty
**File:** `Models/HistoricalNPCContent.swift`  
All 23 NPC entries have `portraitPrompt: ""`. If Image Playground NPC art is ever added, this field must be populated. Not a crash risk since no view reads it today.

### I-02 — `GreatVibes-Regular` font registered but has no `RenaissanceFont` token
**File:** `RenaissanceArchitectAcademyApp.swift:53`  
`GreatVibes-Regular` is registered at startup and the .ttf exists in `Fonts/` but is never referenced in any view. Either add a token and use it, or remove it from registration (saves startup time).

### I-03 — Onboarding skip still commented out (known)
**File:** `Views/ContentView.swift:72–73`  
```swift
// TODO: Re-enable skip after onboarding is finalized:
// if onboardingState.hasCompletedOnboarding { showingMainMenu = false; return }
```
Intentional per CLAUDE.md — listed here for completeness.

### I-04 — Unreachable `default` case in `StationCompounds.compounds(for:)`
**File:** `Models/StationCompounds.swift:167`  
`ResourceStationType` is exhaustively handled; the `default: return []` can never fire. This is a false-safety net that hides missing-case warnings if a new station type is added.

**Fix:** Replace with no `default` so the compiler warns on a new unhandled case.

### I-05 — Previous weekly health check commits not on `main`
Commits for 2026-05-13 and 2026-05-14 (`5111db6`, `d8bdc06`) are on orphaned commits disconnected from `main`. The current `main` HEAD is at `91fc6dc` (PR #12 merge). The detached-HEAD environment may be writing health checks to a floating branch. No source code is affected, but the health check history is fragmented.

---

## 6. Missing Tokens

These values appear in production code but have no corresponding design token. Add them to `RenaissanceTheme.swift` / `RenaissanceColors.swift`.

| Value | Suggested token | File(s) |
|-------|-----------------|---------|
| `Font.custom("Amellina", size: 26)` | `RenaissanceFont.taglineAccent` | `MainMenuView.swift` |
| `UIColor(red: 1.0, green: 0.85, blue: 0.3, alpha: 1.0)` | `RenaissanceColors.notebookYellowUIColor` | `NotebookCanvasView.swift` |

---

## 7. Clean Scans

The following files were read in full and are clean (no hardcoded values, no dead code, no secrets, no performance issues):

**Models:** `BuildingLesson.swift`, `BuildingProgressRecord.swift`, `Challenge.swift`, `ConstructionPhase.swift`, `DiscoveryCard.swift`, `GeneratedContent.swift`, `KnowledgeCard.swift`, `KnowledgeCardContentRenaissance.swift`, `KnowledgeCardContentRome.swift`, `LessonContent.swift`, `LessonContentRenaissance.swift`, `LessonContentRome.swift`, `MasterAssignment.swift`, `Material.swift` (except W-12), `MuseumSketch.swift`, `NotebookContent.swift`, `NotebookContentRenaissance.swift`, `NotebookContentRome.swift`, `NotebookEntry.swift`, `OnboardingContent.swift`, `OnboardingState.swift`, `PigmentRecipe.swift`, `PlayerSave.swift`, `Recipe.swift`, `ScienceCardContent.swift`, `SketchTeachingData.swift`, `SketchingContent.swift`, `SubscriptionTier.swift`, `WorkshopJob.swift`

**Services:** `AIService.swift`, `AppleAIService.swift` (except W-06), `ClaudeService.swift`, `DataManagementService.swift`, `MockAIService.swift`, `PubChemService.swift`, `SketchValidator.swift`, `VisualEditorState.swift`, `WolframGeometryHelper.swift`, `GameSceneKitView.swift`, `GameSpriteView.swift`

**ViewModels:** `BirdChatViewModel.swift` (except W-15 stub), `CityViewModel.swift`, `MuseumSketchService.swift`, `NotebookState.swift`, `WorkshopState.swift`

**Views:** `BottomDialogPanel.swift`, `InfographicRevealView.swift`, `PhaseCompleteOverlay.swift`, `SceneTransitionOverlay.swift`, `SpeakerButton.swift`, `SidebarView.swift`, `ScienceIconView.swift`

**SpriteKit:** `WorkshopScene.swift` (properly uses `[weak self]` in all callbacks), `MascotNode.swift` (animation plays once, stops on last frame — correct)

---

## 8. Build Status

**SKIPPED** — `xcodebuild` not available in cloud sandbox.

**KNOWN BLOCKER:** Fresh clone will fail to compile until `Services/APIKeys.swift` is manually created (see C-01).

---

## 9. TestFlight Feedback (feedback/latest_feedback.json)

Synced 2026-04-18 from build v3. 5 items total, 3 unresolved:

| ID | Tester | Date | Issue | Status |
|----|--------|------|-------|--------|
| AFEkX5LN | Ray Garmon | 2026-04-17 | Gold sifting confusion — some gold objects appear brown; tapping instead of sifting | **Unresolved** |
| AOVEMjw | Ray Garmon | 2026-04-17 | Card question asked "why" but expected a tap on a picture — mismatch between question text and interaction type | **Unresolved** |
| APY9_829 | Marina Pollak | 2026-04-04 | "Every card asking to tap somewhere on the picture but questions and interactions don't make much sense" | **Unresolved** |
| AN75Jh3v | Brianna Walker | 2026-04-10 | iPad horizontal "Choose your apprentice" screen scale, missing back button | **Unresolved** (layout) |
| ALyw50q5 | Brianna Walker | 2026-04-10 | iPhone minor scaling, bird appears over text | **Unresolved** (layout) |

**Cross-reference:** The card interaction confusion (Ray + Marina) is consistent — users expect quiz-style questions but get tap-on-image activities. Consider auditing `CardActivityType` assignments in `KnowledgeCardContentRome.swift` / `KnowledgeCardContentRenaissance.swift` to ensure activity type matches question phrasing.
