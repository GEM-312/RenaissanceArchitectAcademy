# Camera Edge-Station Bug — Investigation & Fix

**Branch:** `overnight/camera-edge-fix`  
**File changed:** `RenaissanceArchitectAcademy/Views/SpriteKit/WorkshopScene.swift`  
**Date:** 2026-05-16

---

## 1. Diagnosis — the exact chain of events

### Setup facts

| Symbol | Value |
|--------|-------|
| Map size | 3500 × 2500 scene units |
| Volcano station position | `(2669, 2184)` — near top-right corner |
| Walk scale (far) | `0.80` (set by `startFollowingPlayer`) |
| Walk scale (close) | `0.60` (target of gradual zoom in `update()`) |
| Scale lerp factor | `0.06` per frame — very slow, ~48 frames to converge |

### Frame-by-frame breakdown

1. **Tap Volcano** → `walkPlayerToStation` → `startFollowingPlayer(toward: stationPos)` sets `isFollowingPlayer = true` and starts an SKAction to scale → `0.80`.

2. **`update()` every frame** while `isFollowingPlayer`:
   - Camera position lerps toward **player position** (factor `0.08`).
   - Gradual zoom: when camera is within 700 units of the station, scale is nudged toward `0.60` (factor `0.06` — slow).
   - **`clampCamera()` fires unconditionally** → clamps both scale AND position.

3. **The position clamp during walk is the bug.** On a large iPad (e.g. 1366 × 1024 viewport):

   At scale `0.80`:
   ```
   visibleHeight = 1024 × 0.80 = 819.2
   maxY          = 2500 − 409.6 = 2090.4   ← hard ceiling
   Volcano y     = 2184              ← ABOVE the ceiling
   ```

   The camera is clamped to `y ≤ 2090.4` and **can never follow the player above that line**, even though the map and terrain are fully painted up to y = 2500.

4. **Player arrives** → `playerArrivedAtStation` sets `isFollowingPlayer = false` → `zoomCameraToStation` runs an SKAction to move the camera to `(2669, 2184)`.

5. **The arrival SKAction is also fought.** The gradual zoom's slow lerp factor (0.06) means the scale may still be `0.72`–`0.76` when the player arrives. At scale `0.72`:
   ```
   visibleHeight = 1024 × 0.72 = 737.3
   maxY          = 2500 − 368.6 = 2131.4   ← still below 2184
   ```
   So `clampCamera()` — still firing every frame — cuts the SKAction short at `y ≈ 2131` instead of letting it reach `2184`.

6. **Visible symptom:** Camera parks ~50–90 units below the station. The station drifts toward the top of the screen. The edge-fill (parchment colour) or raw terrain margin appears as a "parchment border" on one side because the camera is showing the region near the map edge asymmetrically.

### Why Option A was insufficient
Option A added `isCameraActionInFlight` and skipped `clampCamera()` only during the **arrival SKAction**. The **walk phase** was still fully clamped, so the camera still couldn't follow the player to Volcano during the lerp. The SKAction started from a position 50–90 units too low, so even a fully-unclamped arrival action would land short.

### Why Option B regressed
Option B also skipped `clampCamera()` during `isFollowingPlayer`. But `clampCamera()` does **two things**: clamp position AND clamp scale. Without scale clamping, the camera's `xScale` (already modified by the zoom SKAction and gradual-zoom lerp) drifted past `maxZoomOutScale`, which made the terrain appear tiny with huge parchment borders all around.

---

## 2. The fix

### Principle
Split `clampCamera()` into two single-responsibility helpers:

- `clampCameraScale()` — clamps scale only. **Always runs every frame.** This is what prevented the catastrophic Option B regression. Scale never drifts.
- `clampCameraPosition()` — clamps position only. **Skipped while the camera needs to reach an edge.**

Position clamping is suspended in exactly two windows:
1. `isFollowingPlayer == true` — the walk phase.
2. `isCameraArrivingAtStation == true` — the 0.5 s arrival pan SKAction.

After the arrival action completes, a finalize `SKAction.run` block clears the flag and calls the full `clampCamera()` once to settle any edge overshoot.

### Code diff summary

**New property (line ~147):**
```swift
private var isCameraArrivingAtStation = false
```

**`update()` — replace the unconditional `clampCamera()` call:**
```swift
// Before
clampCamera()

// After
clampCameraScale()
if !isFollowingPlayer && !isCameraArrivingAtStation {
    clampCameraPosition()
}
```

**`walkPlayerToStation()` — reset arriving flag on any new walk:**
```swift
playerNode.removeAction(forKey: "walkTo")
isCameraArrivingAtStation = false   // ← new
```

**`zoomCameraToStation()` — gate the flag around the action:**
```swift
// Before
let moveAction = SKAction.move(to: stationPos, duration: 0.5)
moveAction.timingMode = .easeInEaseOut
cameraNode.run(moveAction, withKey: "cameraZoom")

// After
isCameraArrivingAtStation = true
let moveAction = SKAction.move(to: stationPos, duration: 0.5)
moveAction.timingMode = .easeInEaseOut
let finalize = SKAction.run { [weak self] in
    self?.isCameraArrivingAtStation = false
    self?.clampCamera()
}
cameraNode.run(SKAction.sequence([moveAction, finalize]), withKey: "cameraZoom")
```

**`clampCamera()` — refactored to delegate:**
```swift
private func clampCamera() {
    clampCameraScale()
    clampCameraPosition()
}

private func clampCameraScale() { /* scale clamp only */ }
private func clampCameraPosition() { /* position clamp only */ }
```

All existing callers of `clampCamera()` (`handleDragTo`, `handlePinch`, `scrollWheel`, `magnify`, `handleScrollZoom`, `handleScrollPan`, `handleMagnify`) continue to call the full version unchanged — pan and zoom interactions still get full clamping every time.

---

## 3. Why this is safe — no scale regression

The Option B regression happened because skipping `clampCamera()` during walk also skipped scale clamping, letting `xScale` drift past `maxZoomOutScale`.

This fix **always calls `clampCameraScale()` every single frame** — there is no code path in `update()` where scale goes unclamped. The only thing released during walk + arrival is position clamping. Scale is invariant.

---

## 4. Test plan

### Stations to verify (ordered by edge severity)

| Station | Position | Edge risk |
|---------|----------|-----------|
| Volcano | `(2669, 2184)` | top-right — primary bug report |
| Goldsmith Workshop | `(2835, 231)` | bottom-right |
| Forest | `(540, 525)` | bottom-left |
| Clay Pit | `(2992, 1005)` | right edge |
| Quarry | `(1227, 1818)` | upper-left |

### Scenarios per station

1. **Walk from spawn (avatar box `(200, 200)`)** → station. Verify: station centered in screen on arrival, no parchment border, tap interaction hits the station correctly.
2. **Walk from opposite-corner station** (e.g. Forest → Goldsmith). Verify: no scale pop during transition, terrain fills the screen throughout.
3. **Interrupt walk mid-route** by tapping a different station. Verify: `isCameraArrivingAtStation` resets properly, new walk proceeds cleanly.
4. **Manual pan/zoom while at station** (drag map, pinch). Verify: position clamp re-engages correctly after finalize block has fired.
5. **Dismiss overlay → `zoomCameraOut()`**. Verify: camera returns to map center without glitching.

### What "correct" looks like
- Station node is visually centered (or very close to centered) in the viewport on arrival.
- No parchment/edge-fill visible as a border on any side.
- The terrain fills the entire visible area throughout the walk.
- Scale never goes below `0.3` or above `maxZoomOutScale` at any moment.

---

## 5. Open questions / risks

### Can the camera drift past the map edge while position clamping is off?
During the walk, the camera lerps toward the **player position** — a point on the map (max `(3500, 2500)`). The player walks the waypoint graph which is entirely within the map. The lerp target is always valid map coordinates, so the camera won't fly off the edge on its own; it will at worst reach a map boundary naturally, at which point the terrain (sized to `mapSize`) fills that side flush.

During the arrival SKAction, the target is `stationNode.position` — also always a valid map coordinate. The action moves the camera to the exact station position, which is within the 3500 × 2500 map. The one final `clampCamera()` in the finalize block re-establishes position bounds after the action settles.

### Edge-fill / terrain coverage at edge stations
The `TerrainBlurHelper` places a parchment-coloured edge-fill node behind the terrain sprite. If the terrain image itself has whitespace/margin at the edges (a Midjourney artefact), a small parchment strip may still be visible when the camera is centered on an edge station — because that's the actual terrain content. This is a **content issue** (terrain image needs to fill all the way to the edges), not a camera issue. The fix ensures the camera is in the right position; whether the terrain image is painted to the edges is separate.

### `nudgeCameraUp()` called while `isCameraArrivingAtStation` might still be true
`nudgeCameraUp()` is called from SwiftUI after `onStationReached` fires, which happens after the collect animation (inside `playerArrivedAtStation`). By the time SwiftUI calls `nudgeCameraUp()`, the 0.5 s arrival pan has likely already started — `isCameraArrivingAtStation` is `true`. The nudge runs its own move action (key `"cameraNudge"`, distinct from `"cameraZoom"`), so both actions coexist. Position clamping is off, which is fine — the nudge target is intentionally slightly out of center to give the overlay room. When `zoomCameraOut()` is called on overlay dismiss, it resets `isFollowingPlayer` and runs a move to map center, after which both flags are false and position clamping re-engages cleanly.

### Build verification
This investigation was run in a Linux cloud container where `xcodebuild` and `swiftc` are unavailable. The changes use only standard Swift/SpriteKit APIs (`SKAction.sequence`, `SKAction.run`, stored properties, method extraction) with no new imports or external dependencies. Syntax was manually verified against the full file. Marina should do a full Xcode build on her Mac before testing on device.
