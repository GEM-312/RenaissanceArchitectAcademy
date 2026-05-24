# Camera System Health Check — 2026-05-24

**Project:** Renaissance Architect Academy  
**Auditor:** Automated weekly health check  
**Scope:** Read-only static analysis of all camera-owning SpriteKit scenes + PlayerNode

---

## 1. Files Read

| File | Lines | Notes |
|------|-------|-------|
| `Views/SpriteKit/WorkshopScene.swift` | 2067 | Canonical / most complex camera implementation |
| `Views/SpriteKit/CityScene.swift` | 1317 | Same outdoor pattern, 17 buildings |
| `Views/SpriteKit/ForestScene.swift` | 1361 | Same outdoor pattern, 5 POIs |
| `Views/SpriteKit/CraftingRoomScene.swift` | 1119 | Interior, no walk-follow camera |
| `Views/SpriteKit/GoldsmithScene.swift` | 868 | Interior, no walk-follow camera |
| `Views/SpriteKit/PlayerNode.swift` | 401 | Walk/collect/celebrate animations; no camera code |

---

## 2. TL;DR

**Overall: 🟡 YELLOW** — Core edge-station snap-back bug (May 15) is resolved. Three new findings: one dead-code flag, one unclamped focusOnBuilding action, one unclamped nudge action. All outdoor scenes share the same healthy structural pattern but with inconsistent constants.

| Severity | Count | Items |
|----------|-------|-------|
| P0 (provable bugs) | 3 | Dead flag, focusOnBuilding, nudgeCameraUp |
| P1 (anti-patterns) | 4 | A (dead gate), B (dual-job clamp ×5), E (hardcoded constants + ForestScene intra-inconsistency), F (overlaps P0.2/P0.3) |

---

## 3. Open Branches

```
git branch -a output:
* main
  remotes/origin/main
```

**No overnight or camera-fix branches exist.** All camera work is on `main`.

---

## 4. P0 Findings (provable bugs, file:line)

### P0.1 — `isCameraActionInFlight` is dead code in WorkshopScene

**File:** `WorkshopScene.swift:144` (declaration), `WorkshopScene.swift:1183` (read)

```swift
// Line 141-143 — comment claims protection:
/// True while a camera SKAction (zoomCameraToStation/nudge/out) is in flight.
/// Skip clampCamera() while this is true so the action can reach edge stations
/// without being yanked inward each frame (fixes Volcano/edge-station snap-back).
private var isCameraActionInFlight = false   // ← line 144

// Line 1183 — gate that reads the flag:
if !isCameraActionInFlight {
    clampCamera()
}
```

**The flag is NEVER set to `true` anywhere in the file.** All four camera action sites — `startFollowingPlayer` (line 1556), `zoomCameraToStation` (line 1569), `nudgeCameraUp` (line 1586), `zoomCameraOut` (line 1599) — run `cameraNode.run(SKAction…)` without setting `isCameraActionInFlight = true`. The gate at line 1183 is permanently false. `clampCamera()` is called unconditionally every frame.

**Why it doesn't crash today:** Fix Attempt 2 (from the May 15 postmortem) replaced the bypass approach with a different strategy: `zoomCameraToStation()` now calls `clampedPosition(for:)` on the move target before passing it to the SKAction. So the action only moves to a reachable position and never needs to bypass clamp. The dead flag is vestigial, but its comment promises protection that doesn't exist. Future changes that rely on this flag will be silently broken.

**Risk:** HIGH (confusion and future misfire). **Impact today:** LOW (alternative fix covers it).

---

### P0.2 — `CityScene.focusOnBuilding()` runs an unclamped SKAction.move

**File:** `CityScene.swift:1151–1157`

```swift
func focusOnBuilding(_ buildingId: String) {
    guard let node = buildingNodes[buildingId] else { return }
    let moveAction = SKAction.move(to: node.position, duration: 0.5)    // ← raw position, not clamped
    moveAction.timingMode = .easeInEaseOut
    let zoomAction = SKAction.scale(to: 1.0, duration: 0.5)             // ← hardcoded scale
    zoomAction.timingMode = .easeInEaseOut
    cameraNode.run(SKAction.group([moveAction, zoomAction]))             // ← no completion clamp
}
```

Three issues:

1. **Unclamped move target.** `node.position` is used directly. For edge buildings where the camera cannot legally center on the node (see §6), `clampCamera()` overrides the action's position every frame, creating a 0.5 s fight where the action tries to reach the target and clampCamera slams it back. The camera never reaches the intended position.

2. **Scale 1.0 is a magic number.** This is within the valid zoom range (0.5 – maxZoomOutScale), but it ignores the min/max constants defined elsewhere in the scene. A future tightening of the min zoom would silently make 1.0 invalid.

3. **No completion clamp.** After the action ends, if the action was fighting clampCamera, the final resting position is wherever clampCamera last settled it — no explicit terminal clamp is issued.

**Directly affected building:** `botanicalGarden` at `(2497, 151)`. At closeZoom scale 0.6 on an iPad Air (≈1180×820 logical pts), `minY ≈ 246`. The action targets `y=151`, 95 pts below `minY`. Camera stays pinned to `minY` for the full 0.5 s animation.

**Risk:** MEDIUM. **Impact:** `focusOnBuilding()` is broken for at least one building.

---

### P0.3 — `WorkshopScene.nudgeCameraUp()` uses an unclamped Y target

**File:** `WorkshopScene.swift:1579–1589`

```swift
func nudgeCameraUp(by screenFraction: CGFloat = 0.25) {
    guard let cameraNode = cameraNode else { return }
    let visibleHeight = self.size.height * cameraNode.xScale
    let offset = visibleHeight * screenFraction
    let newY = cameraNode.position.y - offset      // ← not clamped
    let moveAction = SKAction.moveTo(y: newY, duration: 0.4)
    moveAction.timingMode = .easeInEaseOut
    cameraNode.run(moveAction, withKey: "cameraNudge")  // ← no completion clamp
}
```

`newY` is computed as current Y minus an offset, with no lower-bound check. If the camera is near `minY` (e.g., after arriving at `goldsmithWorkshop` at station Y=231, camera clamped to `minY≈230`), calling `nudgeCameraUp()` will push the target below `minY`. The action fights `clampCamera()` every frame for 0.4 s. The camera barely moves and the overlay being nudged for will appear in the wrong position.

**Risk:** MEDIUM. **Impact:** Affects the quarry mini-game overlay nudge if the station is near the map's bottom edge.

---

## 5. P1 Findings (anti-patterns A–G)

### P1.A — clampCamera in update() with no effective gate

| Scene | Gate present? | Gate effective? |
|-------|--------------|-----------------|
| WorkshopScene:1183 | Yes — `if !isCameraActionInFlight` | **No** — flag is always false (P0.1) |
| CityScene:366 | No | N/A |
| ForestScene:848 | No | N/A |
| CraftingRoomScene:311 | No | N/A (no walk-follow SKActions in this scene) |
| GoldsmithScene:421 | No | N/A (same) |

All three outdoor scenes that use `startFollowingPlayer` + zoom SKActions run `clampCamera()` unconditionally every frame. The current fix (pre-clamping the move target via `clampedPosition()`) works around this, but structurally any new camera action that needs to temporarily escape `clampCamera` will silently fail unless a working gate is added.

---

### P1.B — All 5 scenes: `clampCamera()` does two jobs (scale + position) in one function

All scenes follow the same pattern:

```swift
private func clampCamera() {
    // Job 1: clamp SCALE
    let clampedScale = max(minZoom, min(maxZoomOutScale, cameraNode.xScale))
    if cameraNode.xScale != clampedScale { cameraNode.setScale(clampedScale) }

    // Job 2: clamp POSITION
    // ...compute visibleWidth/Height from scale...
    cameraNode.position.x = max(minX, min(maxX, cameraNode.position.x))
    cameraNode.position.y = max(minY, min(maxY, cameraNode.position.y))
}
```

Per the May 15 bug history: skipping the whole function to let position SKActions run free simultaneously releases the scale clamp. No scene has split these into `clampScale()` + `clampPosition()`. This is the structural root cause of the May 15 regression.

**Files:** `WorkshopScene.swift:1649`, `CityScene.swift:1049`, `ForestScene.swift:403`, `CraftingRoomScene.swift:626`, `GoldsmithScene.swift:688`

---

### P1.E — Hardcoded constants; ForestScene internally inconsistent

No `CameraConstants` enum exists. All magic numbers are scattered inline:

| Constant | WorkshopScene | CityScene | ForestScene | CraftingRoomScene | GoldsmithScene |
|----------|--------------|-----------|-------------|-------------------|----------------|
| Close zoom | 0.6 | 0.6 | 0.6 | — | — |
| Lerp factor | 0.08 | 0.08 | 0.08 | — | — |
| Min zoom (clampCamera) | **0.3** | **0.5** | **0.3** | 0.5 | 0.5 |
| Min zoom (gesture handlers) | **0.3** | **0.5** | **0.5 ← !!** | 0.5 | 0.5 |

**ForestScene is internally inconsistent.** `clampCamera()` allows zoom to 0.3, but all five gesture handlers (`handlePinch`, `handleScrollZoom`, `handleScrollPan`, `handleMagnify`, macOS `scrollWheel`/`magnify`) clamp at 0.5. A user pinching cannot zoom past 0.5 but the scale clamp in `clampCamera()` would accept down to 0.3. If the scale ever gets set to 0.3 by a code path other than gesture (e.g., a programmatic `setScale`), `clampCamera()` would allow it but gestures would snap back to 0.5 on first touch.

**File:** `ForestScene.swift:406` (clampCamera min 0.3) vs `ForestScene.swift:979,989,993,1009,928,936` (gesture handler min 0.5).

---

### P1.F — SKAction.move without completion clamp (subsumes P0.2, P0.3)

Both P0.2 and P0.3 are instances of anti-pattern F. Listed here for completeness.

`zoomCameraOut()` in all three outdoor scenes pans to map center (always within bounds) — not a risk. All arrival-at-station/building/POI actions use `clampedPosition()` — not a risk. The only unsafe uses are `focusOnBuilding` and `nudgeCameraUp`.

---

## 6. Per-Scene Station/POI Edge Analysis

### Reference geometry
iPad Air landscape (≈ 1180 × 820 logical pts), scene fills view, `.aspectFill`.  
At `closeZoom = 0.6`: `visW ≈ 708 pt`, `visH ≈ 492 pt`.  
Bounds: `minX ≈ 354`, `maxX ≈ 3146`, `minY ≈ 246`, `maxY ≈ 2254`.  
(Exact bounds scale with device; analysis identifies structural edge cases that hold across iPad sizes.)

Player walk-to target offset: `(stationX − 200, stationY − 65)`.

---

### WorkshopScene (map 3500 × 2500)

| Station | Position | Player target | Edge risk |
|---------|----------|---------------|-----------|
| quarry | (1227, 1818) | (1027, 1753) | ✅ safe |
| river | (1057, 1104) | (857, 1039) | ✅ safe |
| volcano | (2669, 2184) | (2469, 2119) | ✅ safe |
| clayPit | (2992, 1005) | (2792, 940) | ✅ safe |
| mine | (2209, 1487) | (2009, 1422) | ✅ safe |
| farm | (1769, 850) | (1569, 785) | ✅ safe |
| craftingRoom | (3160, 1350) | (2960, 1285) | ✅ safe |
| market | (1487, 365) | (1287, 300) | ✅ safe |
| forest | (540, 525) | (340, 460) | ⚠️ X=340 ≈ minX (within, marginal) |
| goldsmithWorkshop | (2835, 231) | **(2635, 166)** | ⚠️ **Y=166 < minY≈246** |

`goldsmithWorkshop` player target Y (166) is below `minY`. Camera stops at ~246 while the player walks to Y=166 — player briefly exits the camera frame at the bottom. No snap-back (handled gracefully by `clampedPosition`), but player goes off-screen. Potential for `nudgeCameraUp()` (P0.3) to fight clampCamera when departing from this station.

---

### CityScene (map 3500 × 2500)

| Building | Position | Player target | Edge risk |
|----------|----------|---------------|-----------|
| aqueduct | (2771, 1558) | (2631, 1483) | ✅ |
| colosseum | (799, 687) | (659, 612) | ✅ |
| romanBaths | (801, 1878) | (661, 1803) | ✅ |
| romanRoads | (2607, 861) | (2467, 786) | ✅ |
| harbor | (2877, 2269) | (2737, 2194) | ✅ |
| siegeWorkshop | (1667, 1891) | (1527, 1816) | ✅ |
| duomo | (1945, 1143) | (1805, 1068) | ✅ |
| glassworks | (1657, 548) | (1517, 473) | ✅ |
| arsenal | (2906, 709) | (2766, 634) | ✅ |
| anatomyTheater | (2393, 1934) | (2253, 1859) | ✅ |
| leonardoWorkshop | (536, 471) | (396, 406) | ✅ (X marginal) |
| flyingMachine | (922, 1321) | (782, 1246) | ✅ |
| **pantheon** | **(344, 2194)** | **(204, 2129)** | ⚠️ **X=204 < minX≈354** |
| **insula** | **(372, 966)** | **(232, 901)** | ⚠️ **X=232 < minX≈354** |
| **botanicalGarden** | **(2497, 151)** | **(2357, 86)** | ⚠️ **Y=86 < minY≈246** |
| **vaticanObservatory** | **(1028, 254)** | **(888, 189)** | ⚠️ **Y=189 < minY≈246** |
| **printingPress** | **(3121, 262)** | **(2981, 197)** | ⚠️ **Y=197 < minY≈246** |

Five buildings with player targets outside camera bounds. All are handled gracefully by `clampedPosition()` — camera stops at the boundary and player walks in from the edge. **No snap-back.** However, the player is partially off-screen upon arrival at pantheon and insula. For botanicalGarden, vaticanObservatory, and printingPress, the player exits the bottom of the camera frame.

Additionally, `focusOnBuilding(botanicalGarden)` is broken (P0.2).

---

### ForestScene (map 3500 × 2500)

| POI | Position | Player target | Edge risk |
|-----|----------|---------------|-----------|
| Cypress | (1750, 1900) | (1550, 1835) | ✅ |
| Chestnut | (2900, 1700) | (2700, 1635) | ✅ |
| Walnut | (600, 750) | (400, 685) | ✅ |
| Poplar | (2800, 700) | (2600, 635) | ✅ |
| **Oak** | **(500, 1650)** | **(300, 1585)** | ⚠️ **X=300 < minX≈354** |

Oak player target X (300) is below `minX`. Camera stops at ~354; player enters the left-edge of frame from outside. Handled gracefully by `clampedPosition`. Spawn point waypoint[24] = (200, 200) is also below both `minX` and `minY` — camera initializes to (354, 246) while player is at (200, 200).

---

### CraftingRoomScene (map 4433 × 2500) — Interior, no walk-follow camera

Camera is static (not player-following). No edge-station analysis applicable.  
`fitCameraToMap` uses `max` (fill formula) — intentional for interior scenes. All furniture positions are well within the 4433×2500 space.

---

### GoldsmithScene (map 3500 × 2500) — Interior, no walk-follow camera

Camera is static. No edge-station analysis applicable.  
`fitCameraToMap` uses `min` (fit formula) — consistent with outdoor scenes. Furniture positions well within bounds.

---

## 7. Consistency Across Scenes

| Feature | WorkshopScene | CityScene | ForestScene | CraftingRoomScene | GoldsmithScene |
|---------|--------------|-----------|-------------|-------------------|----------------|
| Walk-follow camera | ✅ | ✅ | ✅ | ❌ | ❌ |
| `isFollowingPlayer` flag | ✅ | ✅ | ✅ | — | — |
| `isCameraActionInFlight` flag | ✅ (dead) | ❌ | ❌ | — | — |
| `clampedPosition(for:)` helper | ✅ | ✅ | ✅ | — | — |
| Lerp in update() toward clamped target | ✅ | ✅ | ✅ | — | — |
| Gate on clampCamera in update() | Dead | None | None | None | None |
| fitCameraToMap formula | min (fit) | min (fit) | min (fit) | **max (fill)** | min (fit) |
| maxZoomOutScale recomputed in clampCamera | ❌ | **✅ every frame** | ❌ | ❌ | ❌ |
| Min zoom in clampCamera | 0.3 | 0.5 | 0.3 | 0.5 | 0.5 |
| Unclamped nudge/focus action | nudgeCameraUp | focusOnBuilding | ❌ | ❌ | ❌ |

**Notable divergences:**

1. **CraftingRoomScene uses `max` in `fitCameraToMap`** (line 160) — intentional (interior fill vs outdoor fit). Not a bug but worth noting for maintainers.

2. **CityScene recomputes `maxZoomOutScale` inside `clampCamera()` every frame** (line 1054–1056). Other scenes only update on `didChangeSize`. This is the correct approach for handling device rotation mid-session but adds per-frame computation. Others are at risk of stale `maxZoomOutScale` if rotated.

3. **Min zoom inconsistency across scenes**: WorkshopScene and ForestScene allow 0.3; CityScene, CraftingRoomScene, GoldsmithScene clamp at 0.5. No documented reason. ForestScene's gesture handlers additionally disagree with its own clampCamera (gestures: 0.5; clampCamera: 0.3 — P1.E).

4. **WorkshopScene alone has `isCameraActionInFlight`** (dead). CityScene and ForestScene implement the same camera follow pattern without it.

---

## 8. Recommendations

### R1 — Remove or activate `isCameraActionInFlight` in WorkshopScene (fixes P0.1)

**Option A (remove):** Delete the flag, the comment, and the `if !isCameraActionInFlight` wrapper at WorkshopScene:1183. The current fix (clamped move targets) doesn't need it.

**Option B (activate):** If a future camera action ever needs to bypass clampCamera's position logic without releasing the scale clamp, implement the split first (R3), then set/clear the flag around the action. But don't leave it as a half-finished promise.

---

### R2 — Fix `focusOnBuilding` and `nudgeCameraUp` to use clamped targets (fixes P0.2, P0.3)

**`CityScene.focusOnBuilding`** (line 1151):
```swift
// Replace:
let moveAction = SKAction.move(to: node.position, duration: 0.5)

// With:
let clampedTarget = clampedPosition(for: node.position)
let moveAction = SKAction.move(to: clampedTarget, duration: 0.5)
```

**`WorkshopScene.nudgeCameraUp`** (line 1584):
```swift
// Replace:
let newY = cameraNode.position.y - offset

// With:
let rawY = cameraNode.position.y - offset
let clampedPos = clampedPosition(for: CGPoint(x: cameraNode.position.x, y: rawY))
let newY = clampedPos.y
```

Both changes follow the same pattern already used in `zoomCameraToStation`, `zoomCameraToBuilding`, and `zoomCameraToPOI`.

---

### R3 — Split `clampCamera()` into `clampScale()` + `clampPosition()` in all scenes (fixes P1.B)

The May 15 regression happened because skipping `clampCamera()` released both jobs. Proposed split:

```swift
private func clampScale() {
    let clamped = max(minZoom, min(maxZoomOutScale, cameraNode.xScale))
    if cameraNode.xScale != clamped { cameraNode.setScale(clamped) }
}

private func clampPosition() {
    let scale = cameraNode.xScale
    // ... same visibleWidth/Height math ...
    cameraNode.position.x = max(minX, min(maxX, cameraNode.position.x))
    cameraNode.position.y = max(minY, min(maxY, cameraNode.position.y))
}

private func clampCamera() { clampScale(); clampPosition() }
```

A future camera action that needs to temporarily move outside position bounds can skip `clampPosition()` in the gate without releasing the scale guard. This prevents the May 15 regression class structurally.

---

### R4 — Extract shared camera constants into a `CameraConstants` enum (fixes P1.E)

```swift
enum CameraConstants {
    static let closeZoom: CGFloat = 0.6
    static let lerpFactor: CGFloat = 0.08
    static let minZoomOutdoor: CGFloat = 0.3
    static let minZoomIndoor: CGFloat = 0.5
    static let zoomActionDuration: TimeInterval = 0.5
    static let panActionDuration: TimeInterval = 0.6
}
```

Resolve ForestScene's internal inconsistency (clampCamera uses 0.3, gesture handlers use 0.5) by picking one value and applying it everywhere in that file.

---

### R5 — Propagate CityScene's per-frame `maxZoomOutScale` update to other outdoor scenes (consistency)

CityScene correctly recomputes `maxZoomOutScale` via `computeFitScale()` inside `clampCamera()` (line 1054). WorkshopScene and ForestScene only update on `didChangeSize`. For apps that support split-screen multitasking or rotation without a new scene, the other scenes could stale. Either copy CityScene's approach or add a check in `didChangeSize`.

---

### R6 — Add closing clamp after all SKAction.move completions

As a general rule: any `cameraNode.run(SKAction.move…)` that doesn't target a pre-clamped position should end with an `SKAction.run { self.clampCamera() }` in a sequence. Adopt a helper:

```swift
private func runCameraMove(_ action: SKAction, key: String) {
    let finalize = SKAction.run { [weak self] in self?.clampCamera() }
    cameraNode.run(SKAction.sequence([action, finalize]), withKey: key)
}
```

---

## 9. Clean Scans

### ✅ CraftingRoomScene — CLEAN

No walk-follow camera, no zoom actions, `clampCamera()` in update() with no gate needed. The only camera mutations are user-driven (pan drag, pinch, scroll). All clamp correctly. `fitCameraToMap` intentionally uses `max` (fill) for the interior. No outstanding issues beyond the structural P1.B (dual-job clamp shared with all scenes).

### ✅ GoldsmithScene — CLEAN

Same situation as CraftingRoomScene. Static camera, no follow system, all user gestures clamp correctly. `fitCameraToMap` uses `min` (fit) — consistent with outdoor scenes. No unclamped actions.

### ✅ ForestScene (mostly) — CLEAN except P1.E intra-inconsistency

The walk-follow pattern is correctly implemented: `startFollowingPlayer` front-loads zoom to 0.6, lerp in `update()` targets `clampedPosition()`, `zoomCameraToPOI` uses a pre-clamped target. No dead flags, no unclamped actions (aside from the structural P1.B). The only issue is the min-zoom inconsistency between `clampCamera` (0.3) and all gesture handlers (0.5) — a one-line fix.

### PlayerNode — CLEAN (no camera code)

`PlayerNode` contains only sprite animation, walking via `SKAction.move`, footstep sounds, and sparkle effects. It holds no reference to `cameraNode` and issues no camera mutations. Correctly decoupled.

---

*Generated by automated weekly health check — 2026-05-24*
