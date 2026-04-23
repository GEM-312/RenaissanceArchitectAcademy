# Sketching Phase Redesign Plan

**Status:** Planned — not yet executing
**Date:** 2026-04-23
**Target:** Ship before App Store submission (May 15, 2026)

---

## Why this redesign

Marina's feedback on the current sketch canvas: *"our sketching canvas is BS — we can't trace the picture on this canvas, we have to redesign it."*

Two core problems:
1. **Grid-snap tools** (wall / circle / column / room) are the wrong abstraction — they force schematic drawing that doesn't match how an architect would actually trace or study a building.
2. **iPhone is broken** — no Apple Pencil + small screen = sketching is frustrating.

Solution: switch to **PencilKit** on iPad (free-form tracing with the blueprint visible underneath), and **drop sketching entirely on iPhone** in favor of a blueprint-study reader.

---

## Design decisions (locked)

| Decision | Value |
|----------|-------|
| Drawing engine (iPad) | **PencilKit** — `PKCanvasView` + `PKToolPicker` |
| Drawing engine (iPhone) | **None** — study-only mode |
| Blueprint visibility while sketching | Always visible at 30% opacity (traceable) |
| Peek button behavior | Boost blueprint to 60% opacity while held |
| Ruler tool | Built into PKToolPicker (no custom work) |
| Study Mode presentation | **Full-screen cover**, not sheet |
| iPad skip option | "Just Study Today" button on Study Mode → completes with full credit |
| Completion credit parity | iPhone study = iPad sketch = iPad skip = same florins, same `.sketched` state |
| Claude validation | Only on iPad sketch path — iPhone/skip get unconditional completion |

---

## Phase breakdown

### Phase 1 — PencilKit foundation
**Goal:** Create the SwiftUI-friendly drawing canvas component.

- Create `Views/Sketching/PencilCanvasView.swift`
  - `UIViewRepresentable` wrapping `PKCanvasView`
  - Bindings for: `drawing: PKDrawing`, `isToolPickerVisible: Bool`
  - Exposes `PKToolPicker` (system-provided pencil/pen/marker/eraser/**ruler**)
  - Handles `allowsFingerDrawing` based on `drawingPolicy` (Apple Pencil + finger both OK)
  - `#if os(iOS)` guards — PencilKit is not available on macOS

**Effort:** 45 min
**Files:** +1 new, ~80 LOC

---

### Phase 2 — iPad canvas rewrite
**Goal:** Replace the grid-snap canvas with PencilKit, keep the blueprint peek + Claude validation flow.

- Strip `Views/Sketching/PiantaCanvasView.swift`:
  - Delete: grid background, wall drawing, circle drawing, column placement, room detection, hint overlays, validation feedback view, `ValidationResult`, `DetectedRoom`, `RoomValidationResult`, `WallEdge`, `selectedTool`, `undoStack`, drag-gesture handling, the whole `canvasGesture` closure
  - Net removal: ~700–800 LOC
- Add:
  - Full-page canvas with blueprint as **background layer** at 30% opacity
  - `PencilCanvasView` on top, transparent background
  - Peek button: animates opacity 30% → 60% while held
  - `PKToolPicker` floating along bottom edge (or follows system default placement)
  - `Check Plan` → snapshot current drawing + blueprint composite → Claude

**New snapshot approach:**
```swift
// Composite blueprint (dimmed) + student drawing for Claude
let combinedImage = compositeBlueprintAndDrawing(...)
```
Or simpler: send JUST the PKDrawing image on its own (cleaner for Claude comparison; blueprint already in reference image we send as image 2).

**Effort:** 2–3 hours
**Files:** ~1 modified, -700 LOC / +100 LOC

---

### Phase 3 — Full-page layouts
**Goal:** Kill the cramped modal feel. Everything edge-to-edge.

- Study Mode: `.sheet(isPresented:)` → `.fullScreenCover(isPresented:)`
- PiantaCanvasView body: add `.ignoresSafeArea(.container, edges: .bottom)` where appropriate; let canvas fill available space
- Remove outer `.padding()` that shrinks the canvas
- Study Mode's blueprint image: use `.aspectRatio(contentMode: .fit)` with max available height

**Effort:** 30 min
**Files:** ~1 modified

---

### Phase 4 — iPhone study-only view
**Goal:** A full-page scrollable reader that presents the blueprint + all educational content, completion gated on a "Mark Studied" button.

- Create `Views/Sketching/BlueprintStudyView.swift`
  - Full-page scroll view
  - Sections in order:
    1. Title header (building name + "Pianta: Floor Plan")
    2. Pinch-zoomable blueprint image (2x tap to fit, 2-finger pinch for detail)
    3. "Introduction" card — pulls from `SketchingChallenge.introduction`
    4. "What to look for" card — pulls from `SketchingPhase.introduction`
    5. "Architecture in Context" card — pulls from `PiantaPhaseData.educationalText`
    6. "Historical Context" card — pulls from `PiantaPhaseData.historicalContext`
    7. "Educational Summary" card — pulls from `SketchingChallenge.educationalSummary`
  - Bottom pinned button: **"Mark as Studied"** → calls the same `onComplete([.pianta])` callback
  - Design: parchment background, sepia ink, Cinzel headers, EBGaramond body — matches existing lesson aesthetic

**Effort:** 1.5–2 hours
**Files:** +1 new, ~180 LOC

---

### Phase 5 — Device split entry point
**Goal:** Route iPhone to study view, iPad to canvas, with zero duplication.

- Update `PiantaCanvasView.swift` body:
```swift
var body: some View {
    if horizontalSizeClass == .compact {
        BlueprintStudyView(phaseData: phaseData,
                           challenge: challenge,  // need parent to pass down
                           buildingName: buildingName,
                           onComplete: onComplete)
    } else {
        iPadCanvasBody
    }
}
```
- Alternative: do the split one level up in `SketchingChallengeView.swift` (cleaner separation)

**Effort:** 30 min
**Files:** ~2 modified

---

### Phase 6 — "Just Study Today" skip on iPad
**Goal:** Let iPad students opt into study-only without being punished.

- Study Mode modal (already full-screen from Phase 3) gets two buttons stacked:
  - **Begin Sketching** (primary, ochre)
  - **Just Study Today** (secondary, underlined text-button)
- "Just Study Today" → dismiss Study Mode → call `onComplete([.pianta])` immediately, same florins as sketch completion
- Optional bird copy: *"No drawing today? Still counts — mastery comes from study too."*

**Effort:** 30 min
**Files:** ~1 modified (StudyModeView in PiantaCanvasView.swift)

---

### Phase 7 — Dead code cleanup + model simplification
**Goal:** Strip everything the new flow doesn't need.

- `Models/SketchingChallenge.swift`:
  - Delete legacy `PiantaPhaseData` fields: `targetRooms`, `targetColumns`, `symmetryAxis`, `proportionalRatios` (now truly unused)
  - Delete `RoomDefinition`, `RoomShape`, `GridCoord`, `WallSegment`, `ColumnPlacement`, `CirclePlacement`, `ProportionalRatio`, `SymmetryAxis`
  - Simplify `SketchingTool` enum — delete (PKToolPicker replaces)
- Delete `Views/Sketching/SketchingToolbarView.swift` (dead)
- Delete dead helpers in PiantaCanvasView: `validateGrid`, `detectRooms`, `hintAreaHighlight`, `hintOverlay`, `hintColumnMarkers`, `neatnessFeedbackMessage`, etc.
- Update `.pbxproj` to remove deleted file references

**Effort:** 1 hour
**Files:** ~5 modified, 1–2 deleted

---

## File impact summary

| File | Action | LOC delta |
|------|--------|-----------|
| `Views/Sketching/PencilCanvasView.swift` | **NEW** | +80 |
| `Views/Sketching/BlueprintStudyView.swift` | **NEW** | +180 |
| `Views/Sketching/PiantaCanvasView.swift` | **Major rewrite** | −700, +120 |
| `Views/Sketching/SketchingToolbarView.swift` | **DELETE** | −? |
| `Views/Sketching/SketchingChallengeView.swift` | Minor — may split device here | +20 |
| `Models/SketchingChallenge.swift` | Simplify | −100 |
| `Services/SketchValidator.swift` | Minor prompt tweak | ±10 |
| `RenaissanceArchitectAcademy.xcodeproj/project.pbxproj` | Register new files, unregister deleted | +40, −20 |

**Net:** significant code reduction (~500 LOC net deletion) + cleaner architecture.

---

## Effort estimate

| Phase | Time |
|-------|------|
| 1. PencilKit foundation | 45 min |
| 2. iPad canvas rewrite | 2–3 hours |
| 3. Full-page layouts | 30 min |
| 4. iPhone study view | 1.5–2 hours |
| 5. Device split | 30 min |
| 6. Skip option | 30 min |
| 7. Cleanup | 1 hour |
| **Total** | **7–9 hours focused** |

Realistically: **1 full work day** start-to-finish if uninterrupted.

---

## Testing plan

- **iPad simulator (regular size class)**
  - Tap Pantheon 🧪 button → Study Mode opens full-screen
  - "Just Study Today" → completion fires, florins awarded, building marks `.sketched`
  - Reopen → Study Mode → "Begin Sketching" → canvas appears full-page with blueprint @ 30%
  - Draw freely with finger (or Pencil) → Peek button boosts to 60% while held
  - PKToolPicker shows pencil / pen / marker / **ruler** / eraser
  - Ruler: two-finger rotate, lines snap to ruler
  - Check Plan → Claude validates → Result view displays score
  - Repeat for Colosseum, Roman Baths, Aqueduct (4 buildings with blueprints)

- **iPhone simulator (compact size class)**
  - Tap any building with sketch content → BlueprintStudyView opens full-page
  - Blueprint is pinch-zoomable
  - All 5 educational cards readable, scrollable
  - "Mark as Studied" → completion fires, same florins, same `.sketched` state

- **Mac build**
  - PencilKit unavailable — verify graceful fallback (likely: route Mac to study-only view too, same as iPhone)

- **End-to-end user loop**
  - Start fresh build → complete lesson → complete sketch (new flow) → collect materials → craft → build → construction sequence → building complete

---

## Open questions / risks

| Question | Default answer | Revisit if |
|----------|----------------|------------|
| Send JUST PKDrawing to Claude, or composite (blueprint + drawing)? | **JUST drawing** — cleaner for Claude to compare sketch-to-reference | Scoring feels off in testing |
| Mac fallback? | Route to BlueprintStudyView (same as iPhone) | Marina wants Mac sketching later |
| What if student has no Apple Pencil? | `drawingPolicy = .anyInput` allows finger drawing | Feedback says finger drawing is bad |
| Blueprint aspect ratio is 16:9 but canvas is portrait? | Scale blueprint `.fit` on canvas — letterboxing is fine | Visually awkward in testing |
| Should we detect "empty drawing" and prevent Check Plan? | Yes — keep the existing empty-check | n/a |

---

## Non-goals (punt / future)

- Saving sketches to a persistent sketchbook
- Sharing / exporting sketches
- Multi-page sketching across a single building
- Replaying drawing (time-lapse)
- Comparison with previous attempts
- Custom tool brushes beyond what PKToolPicker offers
- Haptic feedback for Pencil pressure

---

## Execution order

1. Wait for Swift-6 migration PR from ultraplan session to land (or decide to sequence)
2. Execute Phase 1 → Phase 2 → Phase 3 together (test after each)
3. Execute Phase 4 → Phase 5 together (iPhone path)
4. Execute Phase 6 (skip)
5. Execute Phase 7 (cleanup)
6. Run `/ultrareview` on the branch before merging
7. Merge → test on physical iPad + iPhone → commit + push

---

## Decisions already made (don't relitigate)

- ✅ PencilKit over custom canvas
- ✅ iPhone = study-only
- ✅ iPad sketch = full-page with always-visible blueprint @ 30%
- ✅ "Just Study Today" skip button on iPad
- ✅ Completion credit parity across all three paths
- ✅ Full-screen cover for Study Mode (not sheet)
- ✅ PKToolPicker gives us ruler for free — no custom ruler code
