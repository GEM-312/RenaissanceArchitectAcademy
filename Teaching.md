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

*(Teaching moments about Swift syntax, protocols, generics, closures, and language features will appear here)*

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

*Last updated: 2026-03-17*
