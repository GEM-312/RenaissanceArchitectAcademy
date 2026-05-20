# Weekly Health Check — 2026-05-20

## 1. Files Read (Step 0 Complete)

**148 Swift files read in full.**

Theme/style files read:
- `Services/Styles/RenaissanceColors.swift`
- `Services/Styles/RenaissanceTheme.swift` (defines `RenaissanceFont`, `Spacing`, `CornerRadius`, `RenaissanceShadow`, `Tracking`, `LineHeight`, `DialogWidth`)
- `Services/Styles/RenaissanceButton.swift`
- `Services/Styles/GameSceneKitView.swift`
- `Services/Styles/GameSpriteView.swift`

All ViewModels, Models, Services, and Views were read before the checks below.

---

## 2. TL;DR

🟡 **YELLOW** — No crashes or secrets found. Two systemic hardcoding patterns (font sizes + corner radii) span >900 sites across ForestMapView and WorkshopMapView. SoundManager has a timer-racing hazard in its audio crossfade. Five TestFlight feedback items remain open.

| Severity | Count |
|----------|-------|
| CRITICAL | 0 |
| WARNING  | 7 |
| INFO     | 4 |

---

## 3. CRITICAL

_None found._

No API keys, hardcoded secrets, or missing crash-causing assets detected.

---

## 4. WARNING

### W-01 — Systemic: 276 hardcoded `.font(.system(size:))` calls in Views
**Scope:** Entire Views/ directory (highest density: `ForestMapView.swift`, `WorkshopMapView.swift`, `RecipeBookView.swift`, `GameTopBarView.swift`)

These text and icon modifiers bypass the `RenaissanceFont` token system. If the font scale or typeface changes, all 276 sites need manual updates.

**Top offenders (Text views, not SF Symbol icons):**

| File | Line | Hardcoded | Token to use |
|------|------|-----------|--------------|
| `GameTopBarView.swift` | 73 | `.custom("EBGaramond-Medium", size: 15)` | `RenaissanceFont.bodySmall` |
| `GameTopBarView.swift` | 243 | `.custom("EBGaramond-Medium", size: 13)` | `RenaissanceFont.caption` |
| `GameTopBarView.swift` | 286 | `.custom("EBGaramond-Regular", size: 16, relativeTo: .subheadline)` | `RenaissanceFont.bodyMedium` |
| `RecipeBookView.swift` | 153 | `.system(size: 11)` | `RenaissanceFont.captionSmall` |
| `RecipeBookView.swift` | 268 | `.system(size: 11)` | `RenaissanceFont.captionSmall` |
| `RecipeBookView.swift` | 288 | `.system(size: 11, weight: .bold)` | `RenaissanceFont.captionSmall` |
| `RecipeBookView.swift` | 384 | `.system(size: 12)` | `RenaissanceFont.footnoteSmall` |
| `ForestMapView.swift` | 853 | `.system(size: 13)` | `RenaissanceFont.caption` |
| `ForestMapView.swift` | 884, 906, 1075 | `.system(size: 16)` | `RenaissanceFont.bodyMedium` |
| `WorkshopMapView.swift` | 1426, 1457 | `.system(size: 14)` | `RenaissanceFont.footnote` |
| `WorkshopMapView.swift` | 1844, 3075 | `.system(size: 12)` | `RenaissanceFont.footnoteSmall` |

**Sizes with no existing token** — add to `RenaissanceTheme.swift`:

| Hardcoded size | Suggested new token | Where used |
|---------------|---------------------|------------|
| `.system(size: 68)` | `RenaissanceFont.displayIcon` | `RecipeBookView.swift:125` (emoji/icon) |
| `.system(size: 52)` | `RenaissanceFont.displayEmoji` | `WorkshopMapView.swift:2988` |
| `.system(size: 36)` | `RenaissanceFont.displayMedium` | `ForestMapView.swift:841` |
| `.system(size: 28)` | `RenaissanceFont.displaySmall` | `ForestMapView.swift:1664` |
| `.system(size: 10)` | `RenaissanceFont.micro` | `GameTopBarView.swift:246`, `WorkshopMapView.swift:2421` |
| `.system(size: 8)` | `RenaissanceFont.nano` | `WorkshopMapView.swift:1993` |

---

### W-02 — Systemic: 686 hardcoded `cornerRadius:` literals in Views
**Scope:** `ForestMapView.swift` (18 sites), `WorkshopMapView.swift` (20+ sites), `SketchingChallengeView.swift`, and others.

Most common values and their token mappings:

| Hardcoded value | Correct token |
|----------------|---------------|
| `cornerRadius: 8` | `CornerRadius.sm` |
| `cornerRadius: 10` | No token — add `CornerRadius.xs: CGFloat = 10` OR use `CornerRadius.sm` (8) |
| `cornerRadius: 12` | `CornerRadius.md` |
| `cornerRadius: 14` | No token — add `CornerRadius.mdLg: CGFloat = 14` OR use `CornerRadius.md` (12) |
| `cornerRadius: 16` | `CornerRadius.lg` |
| `cornerRadius: 20` | `CornerRadius.xl` |

**Highest priority fixes (reusable card shapes):**
- `ForestMapView.swift:768,777,828,861,863,990,994` — all `cornerRadius: 14` → add `CornerRadius.mdLg` token
- `WorkshopMapView.swift:2214,2223,2394` — all `cornerRadius: 10` → add `CornerRadius.xs` token

**Missing tokens to add to `RenaissanceTheme.swift` under `CornerRadius`:**
```swift
static let xs:   CGFloat = 10   // small cards, pills
static let mdLg: CGFloat = 14   // card borders (used extensively in ForestMapView)
```

---

### W-03 — `RenaissanceButton.swift:26` hardcoded `cornerRadius: 20`
`RoundedRectangle(cornerRadius: 20)` in the overlay stroke of `RenaissanceButton.body`.
**Fix:** Replace `20` with `CornerRadius.xl` (already defined as 20).
```swift
// Before
RoundedRectangle(cornerRadius: 20)
// After
RoundedRectangle(cornerRadius: CornerRadius.xl)
```

---

### W-04 — `MainMenuView.swift:16-18` hardcoded adaptive font sizes
Three computed properties use raw sizes (72/46, 44/36, 24/20) not in `RenaissanceFont`:
```swift
private var titleSize: CGFloat { horizontalSizeClass == .regular ? 72 : 46 }
private var subtitleSize: CGFloat { horizontalSizeClass == .regular ? 44 : 36 }
private var taglineSize: CGFloat { horizontalSizeClass == .regular ? 24 : 20 }
```
Used at lines 38, 47, 61 with `.custom("Cinzel-Regular"…)` and `.custom("EBGaramond-Regular"…)`.

**Fix:** Add these tokens to `RenaissanceTheme.swift` under `RenaissanceFont`:
```swift
// Main menu display sizes (adaptive)
@MainActor static var displayHero: Font   { .custom("Cinzel-Regular",    size: 72, relativeTo: .largeTitle) } // iPad
@MainActor static var displayHeroCompact: Font { .custom("Cinzel-Regular", size: 46, relativeTo: .largeTitle) } // iPhone
@MainActor static var displayTitle: Font  { .custom("EBGaramond-Regular", size: 44, relativeTo: .title) }
@MainActor static var displayTitleCompact: Font { .custom("EBGaramond-Regular", size: 36, relativeTo: .title) }
```
Then MainMenuView uses `RenaissanceFont.displayHero` / `.displayHeroCompact` etc. and removes the raw numbers.

---

### W-05 — `SoundManager.swift:341-370` — Timer racing in audio crossfade
`fadeIn` and `fadeOut` each create a new `Timer.scheduledTimer` with no way to cancel a previous one. If `playMusic()` is called while a `stopMusic()` fade is already running (e.g., during rapid scene transitions), two independent timers fight over `player.volume` simultaneously. No crash, but volume jumps.

```swift
// SoundManager.swift ~line 341
private func fadeIn(player: AVAudioPlayer, targetVolume: Float, duration: TimeInterval) {
    // ...
    Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in  // no reference kept
```

**Fix:** Store timers as instance variables and invalidate before creating a new one:
```swift
private var fadeInTimer: Timer?
private var fadeOutTimer: Timer?

private func fadeIn(player: AVAudioPlayer, ...) {
    fadeInTimer?.invalidate()
    fadeInTimer = Timer.scheduledTimer(...) { [weak self] timer in
        ...
        if step >= steps { timer.invalidate(); self?.fadeInTimer = nil }
    }
}
```

---

### W-06 — `GameTopBarView.swift:50,246,295` — system font inside top bar
Three remaining system-font sites on icon/label glyphs:
- Line 50: `.font(.system(size: 11, weight: .semibold))` — icon badge. Use `RenaissanceFont.captionSmall` or add `RenaissanceFont.iconBadge`.
- Line 246: `.font(.system(size: 10))` — label. Add `RenaissanceFont.micro = .system(size: 10)`.
- Line 295: `.font(.system(size: 8, weight: .medium, design: .monospaced))` — debug label. Add `RenaissanceFont.debugMono` or guard with `#if DEBUG`.

---

### W-07 — Open TestFlight feedback, all from build 2 (build 3 has none yet)
Five unresolved items. None have been acknowledged in a commit message.

| ID | Tester | Issue | Build |
|----|--------|-------|-------|
| AFEkX5L | Ray Garmon | "Tapping gold objects instead of sifting. One gold I had to tap was brown." — River mini-game gesture UX | 2 |
| AOVEMjw | Ray Garmon | "Not related with question. It asked why and I had to tap picture." — Card interaction mismatch | 2 |
| AN75Jh3 | Brianna Walker | "iPad horizontal: scale down 'Choose your apprentice' screen. No back button in All/Rome/Ren/Tests. 2 different animations after choosing apprentice." | 2 |
| ALyw50q | Brianna Walker | "iPhone vertical: minor scaling, text adjustments. Bird companion appears over text." | 2 |
| APY9_82 | Marina | "Every card asking to tap somewhere on the picture but some questions and interactions doesn't make much sense." | 2 |

**Priority actions:**
1. River mini-game: verify sift gesture is discoverable on iPhone 11 (tester on iPhone11,8)
2. Character select screen: add back button; fix duplicate animation after selection
3. Knowledge card tap targets: audit cards that trigger "tap the picture" for clarity

---

## 5. INFO

### I-01 — `APIKeys.swift` missing from disk (expected)
The file is referenced in the pbxproj but gitignored. Any fresh clone silently fails to build until the developer manually creates it with `APIKeys.proxyToken`. The `WorkerClient.isConfigured` guard handles the unconfigured state gracefully at runtime. No action needed; document in onboarding README.

### I-02 — `TTSVoice.npcMale` / `TTSVoice.npcFemale` are placeholders
`TTSService.swift:32-33` contains `"PASTE_NPC_MALE_VOICE_ID_HERE"` and `"PASTE_NPC_FEMALE_VOICE_ID_HERE"`. The `TTSVoice.isConfigured()` guard correctly skips TTS for these. No action until NPC voice actors are cast.

### I-03 — `RenaissanceColors.parchmentGradient` has one inline color literal
`RenaissanceColors.swift:83`: `Color(red: 0.941, green: 0.878, blue: 0.788)` is inlined in the gradient definition rather than named. It's in the theme file itself so consistent, but worth extracting as `static let parchmentDark = Color(...)` to match the pattern of all other swatches.

### I-04 — `EngineeringBorder` decorative radii (1, 2) — acceptable
`RenaissanceButton.swift:45,50,136`: `cornerRadius: 2` and `cornerRadius: 1` are used in the `EngineeringBorder` and `EngineeringBorder`-like decoration path. These are intentionally sub-pixel architectural details that don't correspond to any semantic UI radius. No change needed.

---

## 6. Missing Tokens

Add these to `RenaissanceTheme.swift`:

```swift
// MARK: - CornerRadius (add to existing enum)
enum CornerRadius {
    // existing: sm=8, md=12, lg=16, xl=20
    static let xs:   CGFloat = 10   // small interactive chips, pills, progress tracks
    static let mdLg: CGFloat = 14   // card overlays (heavy use in ForestMapView, WorkshopMapView)
}

// MARK: - RenaissanceFont (add to existing enum)
enum RenaissanceFont {
    // Display sizes (Main Menu title screen — adaptive)
    static let displayHero        = Font.custom("Cinzel-Regular",     size: 72, relativeTo: .largeTitle)
    static let displayHeroCompact = Font.custom("Cinzel-Regular",     size: 46, relativeTo: .largeTitle)
    static let displayTitle       = Font.custom("EBGaramond-Regular", size: 44, relativeTo: .title)
    static let displayTitleCompact = Font.custom("EBGaramond-Regular", size: 36, relativeTo: .title)

    // Emoji / icon display sizes (station mini-games, recipe book)
    static let displayIcon   = Font.system(size: 68)  // large collectible emoji
    static let displayEmoji  = Font.system(size: 52)  // medium collectible emoji
    static let displayMedium = Font.system(size: 36)  // medium icon
    static let displaySmall  = Font.system(size: 28)  // small icon

    // Sub-caption sizes
    static let micro = Font.system(size: 10)          // nav badge, small counter labels
    static let nano  = Font.system(size: 8)           // debug indicators, progress pip

    // Debug (DEBUG builds only)
    #if DEBUG
    static let debugMono = Font.system(size: 8, weight: .medium, design: .monospaced)
    #endif
}
```

---

## 7. Clean Scans

The following files were reviewed and are clean:

| Area | Files | Status |
|------|-------|--------|
| Theme files | `RenaissanceColors.swift`, `RenaissanceTheme.swift`, `RenaissanceButton.swift` | ✅ No issues (modulo W-03, I-03, I-04) |
| AI services | `AIService.swift`, `ClaudeService.swift`, `AppleAIService.swift`, `MockAIService.swift` | ✅ No secrets, [weak self] correct |
| SpriteKit scenes | `CityScene.swift`, `WorkshopScene.swift`, `ForestScene.swift`, `CraftingRoomScene.swift`, `GoldsmithScene.swift` | ✅ All closures use `[weak self]` |
| SpriteKit nodes | `PlayerNode.swift`, `MascotNode.swift`, `BuildingNode.swift`, `ResourceNode.swift` | ✅ `[weak self]` in SKAction.run blocks |
| Timer animations | `AvatarTransitionView.swift`, `StoryNarrativeView.swift`, `MascotDialogueView.swift` | ✅ All play ONCE and stop (no `% frameCount` loop) |
| Models | All 41 files under `Models/` | ✅ No UI hardcoding; no secrets |
| ViewModels | `CityViewModel.swift`, `WorkshopState.swift`, `PersistenceManager.swift`, `NotebookState.swift`, `BirdChatViewModel.swift`, `MuseumSketchService.swift` | ✅ |
| Game services | `AssetManager.swift`, `GameCenterManager.swift`, `HapticsManager.swift`, `DataManagementService.swift`, `SubscriptionManager.swift` | ✅ |
| Wolfram services | `WolframService.swift`, `WolframGeometryHelper.swift` | ✅ |
| API/Network | `WorkerClient.swift`, `PubChemService.swift`, `TTSService.swift`, `SketchValidator.swift` | ✅ No keys in source; proxy pattern correct |
| Mini-games | `QuarryMiniGameView.swift`, `ClayPitMiniGameView.swift`, `FarmMiniGameView.swift`, `RiverMiniGameView.swift`, `VolcanoMiniGameView.swift` | ✅ All timers have invalidation |
| Combine anti-pattern | All views | ✅ No `Timer.publish().connect()` found |
| Missing assets | `BackgroundMain`, `BirdFrame00-12`, `BookBackground`, `InteriorFurnace/Pigment/Shelf/Workbench`, `VolcanoFrame00-14`, `QuarryFrame00-14`, `BirdSitBlinkFrame00-14`, `Forest1`, `ButtonBackground`, `Market` | ✅ All exist in catalog |
| Asset consistency | pbxproj ↔ disk | ✅ All 148 disk files are in pbxproj; only `APIKeys.swift` is in pbxproj but absent from disk (intentional) |

---

## 8. Build Status

**Skipped — no macOS toolchain in sandbox.**

xcodebuild is not on PATH in this Linux environment. Build verification must be run locally with Xcode or on a CI Mac runner.

Last commit: `6246f8f Weekly camera health check — 2026-05-17`
