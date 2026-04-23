# Renaissance Architect Academy - Teaching Log

> Your personal coding notebook. Every concept explained during our sessions is saved here
> so you can revisit and study them anytime. Organized by topic for easy reference.

---

## Table of Contents

- [SwiftUI](#swiftui)
- [SpriteKit](#spritekit)
- [Swift Language](#swift-language)
- [Architecture & Patterns](#architecture--patterns)
- [Xcode & Build System](#xcode--build-system)
- [Git & Version Control](#git--version-control)
- [Performance & Optimization](#performance--optimization)
- [Debugging](#debugging)
- [iOS/macOS Platform](#iosmacos-platform)
- [General CS Concepts](#general-cs-concepts)

---

## SwiftUI

*(Teaching moments about SwiftUI views, modifiers, state management, and layout will appear here)*

---

## SpriteKit

*(Teaching moments about SpriteKit scenes, nodes, physics, and animations will appear here)*

---

## Swift Language

### Swift Concurrency Fundamentals (Big Picture) — 2026-04-23

**The Concept:** Your iPad runs code on multiple CPU cores at once. That's fast but dangerous — two threads writing the same variable = race condition = weird bugs. Swift's concurrency model gives you safe ways to do multiple things at once without data corruption or UI freezes.

**Key Terms:**

1. **Main thread / `@MainActor`** — The UI thread. All SwiftUI state changes and drawing happen here. If you block it, the UI freezes. If you touch UI from another thread, you crash.

2. **Actor** — A special class where only ONE caller can touch data at a time. Like a house with one key. Swift enforces this at compile time. `@MainActor` is Apple's pre-built actor that IS the main thread.

3. **`@Observable`** — Macro that makes any SwiftUI view reading a property automatically re-render when that property changes. Replaces the older `ObservableObject` + `@Published` pattern.

4. **`async` function** — Can pause without blocking the thread. Other work runs during the pause.

5. **`await`** — The word you put at the pause point. Read it as "wait for."

6. **`Task`** — Wraps async work so you can start it.

7. **`Sendable`** — Marks a type as "safe to pass between threads/actors." Swift 6 strict mode requires this for values crossing actor boundaries.

**In Our Code:**

| Concept | Where |
|---|---|
| `@MainActor @Observable class` | `ClaudeService`, `FalSketchService`, `SketchValidator`, `GameSettings` |
| `async` function calling network | `SketchValidator.validate(...)`, `FalSketchService.render(...)` |
| `Task { ... }` launching work from a view | `PiantaCanvasView.triggerAIValidation` |
| `@Observable` driving re-renders | `GameSettings.cardTextScale` slider → all `RenaissanceFont.iv*` tokens recompute |

**Key Takeaway:** `@MainActor` = UI-safe, `async/await` = non-blocking, `@Observable` = auto re-render SwiftUI, `Sendable` = safe to cross between them.

### Swift Concurrency (async/await/Task) — 2026-03-26

**The Concept:** Swift Concurrency lets code **wait** for slow work (network, disk) without freezing the UI. Like ordering at a restaurant — you place the order (`async` call), do other things (UI stays responsive), and get notified when it's ready (`await`).

**Three Patterns in Our App:**

1. **`async/await` + `actor`** — For network calls (the REAL concurrency):
   - `ClaudeService` — bird chat API (~1-3 seconds)
   - `MuseumSketchService` — Met Museum image downloads
   - `WolframService` / `PubChemService` — science API calls
   - `actor` protects caches from race conditions (like a lock on a filing cabinet)

2. **`DispatchQueue.main.asyncAfter`** — For animation delays (155+ uses):
   - NOT real concurrency — just "do this later"
   - Perfect for staggered animations, dialog sequences, game timing

3. **`Timer.scheduledTimer`** — For repeating updates (16 uses):
   - Frame animations, game loops, typewriter text
   - **Pitfall:** Timer fires on the run loop and can block keyboard/touch events
   - **Fix:** Replace with `Task { @MainActor in ... Task.sleep() }` which **yields** to the system

**Timer vs Task.sleep — The Key Difference:**
```swift
// Timer DEMANDS — fires on run loop, can starve keyboard events
Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { ... }

// Task.sleep YIELDS — tells system "wake me later", lets keyboard work
Task { @MainActor in
    try? await Task.sleep(for: .milliseconds(100))
}
```

**In Our Code:** CharacterSelectView's avatar animation used Timer at 10fps — it blocked the name TextField from receiving focus. Replaced with `Task { @MainActor in }` loop using `Task.sleep`, keyboard now appears instantly.

**Key Takeaway:** Use `async/await` for slow operations (network, disk). Use `DispatchQueue.asyncAfter` for one-shot delays. Replace `Timer` with `Task.sleep` when the timer competes with user interaction (keyboard, gestures).

---

### Extension-Based Content Splitting — 2026-03-18

**The Concept:** When a single file grows too large (our 208 knowledge cards would be 4000+ lines), Swift extensions let you split content across multiple files while keeping the same type.

**Step by Step:**
1. Define the main enum/struct in one file (`KnowledgeCard.swift` — model + router)
2. Create extensions in separate files (`KnowledgeCardContentRome.swift`, `...Renaissance.swift`)
3. Each extension adds `static var` computed properties to the same enum
4. The compiler treats them as one type — no imports needed between files

**In Our Code:** `KnowledgeCardContent` is an enum in `KnowledgeCard.swift`. The Rome/Renaissance files use `extension KnowledgeCardContent { ... }` to add building card arrays. The router switch in the main file references them all seamlessly.

**Key Takeaway:** Extensions across files = unlimited content scaling without a 5000-line monster file. Same pattern used for `LessonContent` → `LessonContentRome` + `LessonContentRenaissance`.

---

## SwiftUI

### Guard Clauses & Silent Failures — 2026-03-17

**The Concept:** A `guard` statement exits early if a condition fails. But if it exits *silently* (no error, no log, no UI), the user sees nothing and thinks the app is broken.

**Step by Step:**
1. `guard` checks a condition — if it fails, executes the `else` block
2. If the `else` block just does `return`, the function exits with zero feedback
3. The user stares at a blank screen wondering what's wrong
4. Fix: the `else` block should ALWAYS do something visible — show a default message, log an error, or provide a fallback

**In Our Code:** `ForestMapView.swift:241` — the old code was `guard let bid = vm.activeBuildingId else { return }`. The forest guidance never showed because `activeBuildingId` was nil. Fixed by showing a generic "Tap a tree" message in the else block.

**Key Takeaway:** Never let a guard clause fail silently in UI code. If the user can see the screen, the guard's else block should show them *something*.

---

### Dismiss Overlays Before Showing New Ones — 2026-03-17

**The Concept:** When multiple overlays can appear in a ZStack, showing a new one without hiding the old creates visual stacking — guidance bubbles showing behind knowledge cards, etc.

**Step by Step:**
1. View has guidance bubble (z-index 50) + knowledge card overlay (z-index higher)
2. Player does action → knowledge card appears on top
3. Old guidance bubble is still visible behind the card
4. Fix: set `showGuidance = false` before showing any new overlay

**In Our Code:** `WorkshopMapView.swift` — added `showArrivalGuidance = false` to `dismissAllOverlays()`. Also added it to `showKnowledgeCardForStation()`, and similar dismissals in CityMapView, CraftingRoomMapView, ForestMapView.

**Key Takeaway:** In any view with layered overlays, always dismiss the previous layer before showing a new one. Create a `dismissAllOverlays()` helper and call it everywhere.

---

## Architecture & Patterns

### Root Cause vs Symptom Fixing — 2026-03-18

**The Concept:** When a state machine returns the wrong state, fixing the UI that reads it is a band-aid. Fix the computation layer first, then add safety nets in the display layer.

**Step by Step:**
1. `currentPhase()` only checked card completion → returned `.build` prematurely (cards done ≠ materials crafted)
2. CityMapView `.build` detected missing materials → sent player to Workshop
3. WorkshopMapView `.build` didn't check materials → sent player back to City
4. **Infinite loop** — neither view could resolve the contradiction
5. **Root fix:** Made `currentPhase()` stay at `.craft` until materials are ACTUALLY crafted, not just until cards are done
6. **Safety net:** Fixed guidance in all 3 views so even if phase is `.build`, they verify materials before routing

**In Our Code:** `BuildingProgress.swift:108-119` — new material check using `Building.requiredCraftedItems(for:)` keeps phase at `.craft` until `workshopState.craftedMaterials` has all required items.

**Key Takeaway:** Always fix the computation layer (state machine) first, then the display layer (guidance messages). A wrong state will always find new ways to cause bugs if you only patch the UI.

---

### Actionable Checklists — Navigate From Status to Action — 2026-03-18

**The Concept:** A static checklist that only shows "done/not done" is a UI dead end. Making incomplete items tappable turns the checklist into a navigation hub — the player sees what's missing AND can do it right there.

**Step by Step:**
1. Checklist shows requirements with checkmarks for completed items
2. Incomplete item (e.g., "Floor Plan") becomes a `Button` instead of a static `HStack`
3. Button fires a callback (`onBeginSketching`) that the parent view handles
4. Parent dismisses checklist, then presents the next activity (sketching challenge)

**In Our Code:** `BuildingChecklistView.swift:87-109` — the sketch row is now a tappable `Button` with blue "Begin Sketch >" text when incomplete. `CityMapView.swift:593-601` — `onBeginSketching` dismisses checklist then opens the sketching sheet.

**Key Takeaway:** Every "not yet done" item in a UI should tell the user HOW to do it. Callbacks bridge the gap between "showing status" and "enabling action."

---

### Two Card Systems = Two Bugs — 2026-03-17

**The Concept:** The forest had TWO card systems that were never connected — ScienceCards (old, 4 per tree, gates timber) and KnowledgeCards (new, 2 for Pantheon, gates phase progression). The phase system checked KnowledgeCards, but the forest only showed ScienceCards. Result: phase stuck on `.explore` forever.

**Step by Step:**
1. Player completes 8 ScienceCards (2 trees x 4) — local state only, not in BuildingProgress
2. Phase system checks `KnowledgeCardContent.cards(for: "Pantheon", in: .forest)` — finds 2 unfinished cards
3. Those 2 KnowledgeCards are never shown to the player in the forest
4. `currentPhase()` returns `.explore` forever
5. Guidance says "keep exploring" in an infinite loop

**In Our Code:** Fixed in `ForestMapView.swift` by ignoring the phase system for forest exit guidance and checking timber count directly instead.

**Key Takeaway:** When you have parallel systems tracking similar things (two card types), make sure the gating logic uses the system the player actually interacts with. Otherwise you create invisible walls.

---

### The Phase State Machine Pattern — 2026-03-17

**The Concept:** A State Machine has a finite set of states and rules for transitioning between them. In our game, each building progresses through 5 phases: Learn -> Collect -> Explore -> Craft -> Build.

**Step by Step:**
1. **Define states** — `BuildingPhase` enum with 5 cases, each mapping to an environment
2. **Compute current state** — `currentPhase()` checks which conditions are met and returns the first incomplete phase
3. **Detect transitions** — Each view tracks `lastCheckedPhase`. When the phase changes, it means the player just advanced
4. **React to transitions** — Show `PhaseCompleteOverlay` to celebrate and guide the player to the next environment

**In Our Code:** `BuildingProgress.swift:75` — `currentPhase()` is a *computed state*, not a stored one. It re-derives the phase from progress data every time. This means it's always correct even after app restart — no stale state bugs.

**Key Takeaway:** State machines make complex game logic predictable. Instead of checking dozens of conditions scattered across views, you check one phase value and each view only handles its own phase.

---

---

## Xcode & Build System

*(Teaching moments about pbxproj, build settings, schemes, and Xcode workflows will appear here)*

---

## Git & Version Control

*(Teaching moments about git commands, branching, merging, and collaboration will appear here)*

---

## Performance & Optimization

*(Teaching moments about memory management, rendering performance, and optimization will appear here)*

---

## Debugging

*(Teaching moments about debugging techniques, breakpoints, and troubleshooting will appear here)*

---

## iOS/macOS Platform

*(Teaching moments about UIKit/AppKit, platform APIs, and system frameworks will appear here)*

---

## General CS Concepts

*(Teaching moments about algorithms, data structures, and computer science fundamentals will appear here)*

---

## Responsive Layout

### Size Classes & AdaptiveWidthModifier — 2026-03-18

**The Concept:** SwiftUI provides `@Environment(\.horizontalSizeClass)` to detect iPhone (`.compact`) vs iPad/Mac (`.regular`). Instead of hardcoding pixel sizes, compute them relative to screen width using GeometryReader or toggle between two presets.

**Step by Step:**
1. Read `horizontalSizeClass` from environment → derive `isLargeScreen` boolean
2. For maxWidth constraints: use `.adaptiveWidth(420)` — expands to `.infinity` on iPhone, stays 420pt on iPad
3. For padding: use `.adaptivePadding(.horizontal, regular: 40, compact: 16)` — one modifier replaces inline ternaries
4. For cards/grids: use computed properties (`var cardW: CGFloat { isLargeScreen ? 200 : 140 }`)
5. For layout changes: switch `HStack` → `VStack` on compact (`Group { if isLargeScreen { HStack { ... } } else { VStack { ... } } }`)

**In Our Code:** KnowledgeCardsOverlay flipped card was 560pt (overflows 375pt iPhone SE by 185pt). Now 340pt on compact. CharacterSelectView gender cards were 300pt each (624pt total) — now 160pt (332pt total). MaterialPuzzleView switches from HStack to VStack on compact.

**Key Takeaway:** One `@Environment` + computed properties = responsive across all Apple devices. SpriteKit scenes need no changes — the camera system handles all sizes automatically.

### AdaptivePaddingModifier Pattern — 2026-03-18

**The Concept:** When `padding(isLargeScreen ? 40 : 16)` repeats across dozens of files, extract into a ViewModifier that reads `horizontalSizeClass` internally, so callers don't need their own `@Environment`.

**Step by Step:**
1. `AdaptivePaddingModifier` takes edges, regular, and compact parameters
2. Reads `@Environment(\.horizontalSizeClass)` inside the modifier
3. Usage: `.adaptivePadding(.horizontal, regular: 40, compact: 16)`
4. Pair with `.adaptiveWidth()` for maxWidth constraints

**In Our Code:** Added to `RenaissanceTheme.swift` alongside `AdaptiveWidthModifier`. Used in ConstructionSequenceView, HintOverlayView, BuildingChecklistView.

**Key Takeaway:** One modifier call replaces two lines of Environment + ternary per file.

---

*Last updated: 2026-03-18*

## Timer Lifecycle in SwiftUI Structs

**THE CONCEPT:** Unlike classes, SwiftUI view structs are value types — so there's no retain cycle risk. But `Timer.scheduledTimer` runs on the RunLoop indefinitely. If you don't store a reference, you lose the ability to stop it. The timer fires forever, even after the view leaves the screen.

**STEP BY STEP:**
1. Timer created in `.onAppear` → discarded immediately (not stored)
2. SwiftUI RunLoop holds a strong reference → timer keeps firing
3. View disappears → no way to call `.invalidate()` → timer leaks

**IN OUR CODE:** `MascotDialogueView.swift` — `Eye` struct's blink timer was anonymous. Now stored as `@State private var blinkTimer: Timer?` and invalidated in `.onDisappear`.

**KEY TAKEAWAY:** Every repeating `Timer` needs a stored reference and a corresponding `.invalidate()` on cleanup.
