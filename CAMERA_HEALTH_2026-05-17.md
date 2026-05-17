# Camera Health Check — 2026-05-17

**Auditor:** Claude Code (automated read-only audit)
**Scope:** All SpriteKit camera-owning scenes + PlayerNode
**Status:** 🔴 RED — 2 confirmed P0 bugs, 4 P1 anti-pattern classes affecting 3 scenes

---

## 1. Files Read

| File | Lines |
|---|---|
| `Views/SpriteKit/WorkshopScene.swift` | 1867 |
| `Views/SpriteKit/CityScene.swift` | 1158 |
| `Views/SpriteKit/CraftingRoomScene.swift` | 1120 |
| `Views/SpriteKit/GoldsmithScene.swift` | 868 |
| `Views/SpriteKit/ForestScene.swift` | 1344 |
| `Views/SpriteKit/PlayerNode.swift` | 401 |

---

## 2. TL;DR

| Severity | Count | Status |
|---|---|---|
| P0 — Active bugs (provable) | 2 | 🔴 |
| P1 — Anti-patterns (will cause bugs) | 4 classes, 15+ sites | 🟡 |
| Clean scenes | 2 (Crafting, Goldsmith) | 🟢 |

The root cause of the May 15 Volcano snap-back is **still present** in WorkshopScene and has **additional undetected instances** in CityScene (Arsenal, BotanicalGarden, PrintingPress buildings).

---

## 3. Open Branches

```
git branch -a output:
  * (HEAD detached at refs/heads/main)
    main
    remotes/origin/main
```

No overnight/camera/edge branches detected. All work is on main; the May 15 partial fixes are the last camera commits.

---

## 4. P0 Findings — Confirmed Active Bugs

### P0-1: Volcano snap-back still present — WorkshopScene

**File:** `WorkshopScene.swift`
**Root cause chain:**

1. `playerArrivedAtStation()` at line 1357 sets `isFollowingPlayer = false` then calls `zoomCameraToStation(stationNode.position)` at line 1369.
2. `zoomCameraToStation()` at line 1406 runs `SKAction.move(to: stationPos, duration: 0.5)` — a 0.5-second animation.
3. `update()` at line 1032 calls `clampCamera()` **unconditionally every frame** with no flag gate.
4. `clampCamera()` corrects `cameraNode.position` toward map-interior bounds on every frame, fighting the SKAction.

**Volcano-specific geometry** (station at `CGPoint(x: 2669, y: 2184)`, map 3500×2500):

At `closeZoom = 0.60` on iPad 1024×768:
```
renderScale = 1.0  (scene fills view)
visibleHeight = 768 * 0.60 = 461 scene-units
maxY = 2500 − 230 = 2270
Camera target: y = 2184
Margin: 2270 − 2184 = 86 pt
```

86 pt is a very tight margin. On iPhone SE (667×375), `visibleHeight = 375 * 0.60 = 225`, `maxY = 2500 − 112 = 2388` — there the margin expands. But if the gradual zoom in `update()` hasn't fully reached 0.60 when the player arrives (it asymptotically approaches), the actual scale could still be at 0.70 or 0.75, which changes the math:

At scale 0.75: `visibleHeight = 768 * 0.75 = 576`, `maxY = 2500 − 288 = 2212`. Camera trying to reach 2184 < 2212 — still OK.

At scale 0.80 (`farZoom`): `visibleHeight = 614`, `maxY = 2500 − 307 = 2193`. Camera tries to reach y=2184 < 2193 — **1 pt margin**. Any rounding or device-DPI variation causes a clamp.

The bug is intermittent because zoom level at arrival depends on travel distance, device, and timing. This matches the "partial fix" history.

**GoldsmithWorkshop outdoor station is also at risk:**
Station `goldsmithWorkshop` at `CGPoint(x: 2835, y: 231)`. At closeZoom 0.60: `minY = 230`. Camera trying to reach y=231 has **1 pt clearance** — essentially guaranteed to snap on most devices.

---

### P0-2: Three CityScene buildings hard-clamped by map edge

**File:** `CityScene.swift`
**Buildings:** `arsenal`, `botanicalGarden`, `printingPress`

CityScene uses `closeZoom = 0.55` (line 347). On iPad 1024×768:
```
visibleWidth  = 1024 * 0.55 = 563 scene-units  →  minX = 282, maxX = 3218
visibleHeight =  768 * 0.55 = 422 scene-units  →  minY = 211, maxY = 2289
```

| Building | Position | Clamp check | Result |
|---|---|---|---|
| `arsenal` | `(1300, 113)` | y=113 < minY=211 | **HARD CLAMP — camera can't reach it** |
| `botanicalGarden` | `(2497, 151)` | y=151 < minY=211 | **HARD CLAMP — camera can't reach it** |
| `printingPress` | `(3339, 336)` | x=3339 > maxX=3218 | **HARD CLAMP — camera can't reach it** |
| `glassworks` | `(2190, 280)` | y=280 > minY=211 | 69pt margin — OK on iPad |
| `vaticanObservatory` | `(1028, 254)` | y=254 > minY=211 | 43pt margin — tight on smaller devices |

When the player walks to Arsenal or BotanicalGarden, `zoomCameraToBuilding(buildingNode.position)` at line 962 runs an SKAction targeting (e.g.) y=113. `clampCamera()` at line 367 overrides this every frame, clamping to y=211. The camera never reaches the building — same mechanic as the Volcano bug, but geometrically guaranteed (not device-dependent).

**Evidence:** Same code path as WorkshopScene. `playerArrivedAtBuilding()` at line 911 → `zoomCameraToBuilding()` at line 923 → SKAction fights `clampCamera()` in `update()`:367.

---

## 5. P1 Findings — Anti-Patterns A–G

### P1-A: clampCamera() in update() with no flag gate

**Affected:** WorkshopScene:1032, CityScene:367, ForestScene:830

```swift
// WorkshopScene update() — line 1006–1038
if isFollowingPlayer {
    cameraNode.position = lerp(...)
    cameraNode.setScale(...)      // gradual zoom
}
clampCamera()                     // ← NO GATE — fights SKActions every frame
```

`clampCamera()` is called unconditionally every frame, including when `zoomCameraToStation/Building/POI` SKActions are running. This is the direct mechanism that causes snap-back (P0-1 and P0-2).

Neither CraftingRoomScene nor GoldsmithScene have camera-follow SKActions, so the same anti-pattern is harmless there (they only pan via user gestures).

---

### P1-B: clampCamera() clamps scale AND position in the same function

**Affected:** All 5 scenes — same implementation copy-pasted.

```swift
// WorkshopScene clampCamera() — lines 1461–1495
private func clampCamera() {
    // Job 1: Clamp scale
    let clampedScale = max(0.3, min(maxZoomOutScale, cameraNode.xScale))
    if cameraNode.xScale != clampedScale { cameraNode.setScale(clampedScale) }

    // Job 2: Clamp position
    let scale = cameraNode.xScale
    ...
    cameraNode.position.x = max(minX, min(maxX, cameraNode.position.x))
    cameraNode.position.y = max(minY, min(maxY, cameraNode.position.y))
}
```

This dual responsibility is the **root cause of the May 15 catastrophic regression**: when the team tried to fix Volcano snap-back by skipping `clampCamera()` during `isFollowingPlayer`, the scale clamp was also skipped, allowing `xScale` to exceed `maxZoomOutScale` and produce zoom-out to infinity.

The two jobs need to be split into separate functions before any fix attempt, so each can be gated independently.

---

### P1-E: Hardcoded camera constants (magic numbers in update())

**Affected:** WorkshopScene, CityScene, ForestScene

| Constant | WorkshopScene | CityScene | ForestScene |
|---|---|---|---|
| `lerpFactor` | `0.08` (line 1009) | `0.08` (line 338) | `0.08` (line 808) |
| `scaleLerpFactor` | `0.06` (line 1026) | `0.06` (line 355) | `0.06` (line 825) |
| `farZoom` | `0.80` (line 1019) | `0.80` (line 348) | `0.65` (line 819) |
| `closeZoom` | `0.60` (line 1019) | `0.55` (line 347) | `0.45` (line 818) |
| `zoomStartDist` | `700` (line 1021) | `800` (line 349) | `700` (line 820) |
| Initial zoom action | `scale(to: 0.80)` (line 1400) | `scale(to: 0.8)` (line 952) | `scale(to: 0.65)` (line 423) |
| Min scale floor | `max(0.3, ...)` | `max(0.5, ...)` | `max(0.3, ...)` |

None of these are in a `CameraConstants` enum or per-scene struct. Tuning any value requires finding all occurrences manually. The min-scale floor inconsistency (0.3 vs 0.5) is particularly risky — WorkshopScene allows a zoom level that CityScene prohibits, with no documentation of the design intent.

---

### P1-F: SKAction.move/scale run on cameraNode without a completion clamp

**Affected:** WorkshopScene, CityScene, ForestScene

Every camera SKAction that isn't inside the `isFollowingPlayer` lerp block:

| Scene | Function | Action | Line |
|---|---|---|---|
| WorkshopScene | `startFollowingPlayer()` | `scale(to: 0.80, duration: 0.5)` | 1400 |
| WorkshopScene | `zoomCameraToStation()` | `move(to: stationPos, duration: 0.5)` | 1408 |
| WorkshopScene | `nudgeCameraUp()` | `moveTo(y: newY, duration: 0.4)` | 1422 |
| WorkshopScene | `zoomCameraOut()` | `move(to: mapCenter, duration: 0.6)` | 1436 |
| CityScene | `startFollowingPlayer()` | `scale(to: 0.8, duration: 0.5)` | 952 |
| CityScene | `zoomCameraToBuilding()` | `move(to: buildingPos, duration: 0.5)` | 962 |
| CityScene | `zoomCameraOut()` | `move(to: mapCenter, duration: 0.6)` | 979 |
| CityScene | `focusOnBuilding()` | `group([move, scale(to: 1.0)])` | 1126 |
| ForestScene | `startFollowingPlayer()` | `scale(to: 0.65, duration: 0.5)` | 423 |
| ForestScene | `zoomCameraToPOI()` | `move(to: poiPos, duration: 0.5)` | 436 |
| ForestScene | `zoomCameraOut()` | `move(to: mapCenter, duration: 0.6)` | 452 |

None have a `SKAction.run { self.clampCamera() }` appended as a completion step. Positions set by these actions are only clamped by the next frame's `update()` call — which, for the move actions targeting out-of-bounds positions, means the camera immediately gets corrected (the active snap-back bug described in P0).

**Special case — CityScene `focusOnBuilding()` (line 1117):** This action uses no key ("cameraZoom"), so it can run concurrently with a "cameraZoom"-keyed action from `zoomCameraToBuilding()`. Race condition possible if called while a building zoom is in progress.

---

## 6. Per-Scene Station/Building Edge Analysis

### WorkshopScene (map 3500×2500, closeZoom=0.60, iPad 1024×768)

At closeZoom 0.60: `minX=307, maxX=3193, minY=230, maxY=2270`

| Station | Position | Edge proximity | Risk |
|---|---|---|---|
| goldsmithWorkshop | (2835, **231**) | **y=231, minY=230 → 1pt margin** | 🔴 SNAP-BACK |
| volcano | (2669, **2184**) | y=2184, maxY=2270 → 86pt margin | 🟡 Tight |
| craftingRoom | (**3160**, 1350) | x=3160, maxX=3193 → 33pt margin | 🟡 Tight |
| forest | (540, 525) | x=540, minX=307 → 233pt margin | 🟢 OK |
| quarry | (1227, 1818) | interior | 🟢 OK |
| river | (1057, 1104) | interior | 🟢 OK |
| clayPit | (2992, 1005) | x=2992, maxX=3193 → 201pt margin | 🟢 OK |
| mine | (2209, 1487) | interior | 🟢 OK |
| market | (1487, 365) | y=365, minY=230 → 135pt margin | 🟢 OK |
| farm | (1769, 850) | interior | 🟢 OK |

**Two additional edge-station risks beyond Volcano:** `goldsmithWorkshop` has a near-zero y margin (essentially guaranteed snap-back). `craftingRoom` x has a 33pt margin that disappears on smaller screens.

---

### CityScene (map 3500×2500, closeZoom=0.55, iPad 1024×768)

At closeZoom 0.55: `minX=282, maxX=3218, minY=211, maxY=2289`

| Building | Position | Edge proximity | Risk |
|---|---|---|---|
| arsenal | (1300, **113**) | **y=113 < minY=211** | 🔴 HARD CLAMP |
| botanicalGarden | (2497, **151**) | **y=151 < minY=211** | 🔴 HARD CLAMP |
| printingPress | (**3339**, 336) | **x=3339 > maxX=3218** | 🔴 HARD CLAMP |
| vaticanObservatory | (1028, **254**) | y=254, minY=211 → 43pt margin | 🟡 Tight (fails on smaller devices) |
| glassworks | (2190, **280**) | y=280, minY=211 → 69pt margin | 🟡 Tight |
| leonardoWorkshop | (536, 471) | x=536, minX=282 → 254pt margin | 🟢 OK |
| insula | (372, **966**) | x=372, minX=282 → 90pt margin | 🟢 OK |
| All others | — | interior | 🟢 OK |

**Three buildings are geometrically unreachable** by the camera at closeZoom on iPad — always snap-back.

---

### ForestScene (map 3500×2500, closeZoom=0.45, iPad 1024×768)

At closeZoom 0.45: `minX=230, maxX=3270, minY=173, maxY=2327`

| POI | Position | Edge proximity | Risk |
|---|---|---|---|
| Oak | (500, 1650) | x=500, minX=230 → 270pt margin | 🟢 OK |
| Chestnut | (2900, 1700) | interior | 🟢 OK |
| Cypress | (1750, 1900) | interior | 🟢 OK |
| Walnut | (600, 750) | x=600>230, y=750>173 | 🟢 OK |
| Poplar | (2800, 700) | interior | 🟢 OK |

ForestScene POIs are all safe at the current zoom constants. However, the **avatar box spawn waypoint at (200, 200)** is inside minX=230 and minY=173 bounds — the camera lerp will be clamped even when the player is at spawn, creating a slight visual offset between player and camera center at the start of every session.

---

### CraftingRoomScene (map 4433×2500)

No camera follow. Player walks to fixed furniture positions; camera is manual-pan only. No SKAction camera movements. All furniture positions are interior:
- furnace: (560, 1820), workbench: (1930, 1645), pigmentTable: (2843, 940), shelf: (4038, 1146)
- `shelf.x = 4038` in a 4433-wide map — at maxZoomOut scale, this is interior. No edge risk detected.

---

### GoldsmithScene (map 3500×2500)

No camera follow. Same manual-pan-only pattern as CraftingRoom. All furniture positions are interior (600–2800 x, 900–1600 y in a 3500×2500 map). No edge risks.

---

## 7. Cross-Scene Consistency

| Feature | Workshop | City | Forest | CraftingRoom | Goldsmith |
|---|---|---|---|---|---|
| Camera follow (lerp) | ✅ | ✅ | ✅ | ❌ | ❌ |
| Gradual zoom in update() | ✅ | ✅ | ✅ | ❌ | ❌ |
| `clampCamera()` in update() | ✅ | ✅ | ✅ | ✅ | ✅ |
| `fitCameraToMap()` uses min() | ✅ | ✅ (via `computeFitScale()`) | ✅ | **❌ uses max()** | ✅ |
| Min scale floor | `0.3` | `0.5` | `0.3` | `0.5` | `0.5` |
| `clampCamera()` min scale | `0.3` | `0.5` | `0.3` | `0.5` | `0.5` |
| SKAction completion clamp | ❌ | ❌ | ❌ | n/a | n/a |
| `isCameraActionInFlight` flag | ❌ | ❌ | ❌ | n/a | n/a |
| `maxZoomOutScale` updated in clamp | ❌ | **✅ CityScene only** | ❌ | ❌ | ❌ |

**Notable CityScene difference:** `clampCamera()` in CityScene recomputes `maxZoomOutScale` via `computeFitScale()` on every frame (line 1023). This is correct — it handles device rotation / window resize mid-session — but WorkshopScene and ForestScene only update `maxZoomOutScale` in `fitCameraToMap()` / `didChangeSize()`. If those scenes resize between `didChangeSize` calls, their `maxZoomOutScale` can be stale.

**CraftingRoomScene `fitCameraToMap()` uses `max()` not `min()`:** This means the initial scale zooms out enough to show the full WIDTH (4433pt) of the room, but the visible height (at that scale) exceeds the map height (2500pt), exposing the parchment fill at top/bottom. This appears intentional for the wide interior scene, but is undocumented and inconsistent with the three exterior scenes.

**`forestScene` avatar spawn inside clamp bounds:** The avatar box waypoint at `(200, 200)` sits inside `minX≈230, minY≈173` at closeZoom. At farZoom 0.65: `minX=333, minY=250`. The spawn is inside the clamp zone at ALL zoom levels — the camera is always offset from the player at spawn.

---

## 8. Recommendations

> These are proposals only. No code has been modified.

### R1 — Split clampCamera() into two functions (prerequisite for all other fixes)

```swift
// Instead of one dual-job function:
private func clampCameraScale() {
    let clamped = max(minZoomScale, min(maxZoomOutScale, cameraNode.xScale))
    if cameraNode.xScale != clamped { cameraNode.setScale(clamped) }
}

private func clampCameraPosition() {
    // ...existing position math...
}
```

Call both from the current `clampCamera()` call site during normal use. But now each can be gated independently when SKActions are in flight.

---

### R2 — Add `isCameraActionInFlight` flag; gate position clamp in update()

```swift
private var isCameraActionInFlight = false

// In update():
clampCameraScale()                        // Always clamp scale — prevents zoom escape
if !isCameraActionInFlight {
    clampCameraPosition()                 // Only clamp position when no SKAction owns it
}

// In zoomCameraToStation():
isCameraActionInFlight = true
cameraNode.run(SKAction.sequence([
    SKAction.move(to: stationPos, duration: 0.5),
    SKAction.run { [weak self] in
        self?.isCameraActionInFlight = false
        self?.clampCameraPosition()       // Single terminal clamp after action completes
    }
]), withKey: "cameraZoom")
```

This resolves P0-1, P0-2, and P1-A without touching the gradual-zoom logic.

---

### R3 — Move building/station positions away from map edges (immediate workaround)

For the three hard-clamped CityScene buildings, nudge positions inward in editor mode:
- `arsenal` y=113 → move to y≥250 (needs +137pt minimum)
- `botanicalGarden` y=151 → move to y≥250 (needs +99pt minimum)
- `printingPress` x=3339 → move to x≤3200 (needs −139pt minimum)

For `goldsmithWorkshop` in WorkshopScene: y=231 → move to y≥300.

This is a content fix, not a camera fix, but unblocks the P0 bugs while R1+R2 are implemented.

---

### R4 — Extract CameraConstants enum per scene (or shared)

```swift
struct CameraConstants {
    static let lerpFactor:       CGFloat = 0.08
    static let scaleLerpFactor:  CGFloat = 0.06
    static let zoomStartDist:    CGFloat = 700
}
struct WorkshopCameraConstants {
    static let farZoom:  CGFloat = 0.80
    static let closeZoom: CGFloat = 0.60
    static let minScale: CGFloat = 0.3
}
```

Eliminates P1-E. Tuning zoom feel for one scene no longer requires hunting magic numbers.

---

### R5 — Standardize min-scale floor across all scenes

All five scenes should use the same minimum: either 0.3 or 0.5. Current state (0.3 in Workshop/Forest, 0.5 in City/CraftingRoom/Goldsmith) has no documented design rationale. Recommend 0.3 as it allows closer zoom in interior scenes too, but any consistent value is an improvement.

---

### R6 — Update CityScene `maxZoomOutScale` pattern to all scenes

CityScene already recomputes `maxZoomOutScale` inside `clampCamera()`. Port this behavior to WorkshopScene and ForestScene to handle mid-session resize events correctly.

---

## 9. Clean Scans

### GoldsmithScene ✅
No camera follow system. Camera is manual-pan only. `clampCamera()` in `update()` with no gate is harmless here because no SKActions ever run on `cameraNode`. Scale and position clamping work correctly for all furniture positions. Minor: uses `min()` in `fitCameraToMap()` unlike CraftingRoom (inconsistency between the two interior scenes).

### CraftingRoomScene ✅ (with noted inconsistency)
Same manual-pan pattern as Goldsmith. `fitCameraToMap()` intentionally uses `max()` to show the full width of the 4433×2500 map. Parchment fill covers the vertical overshoot. No station positions are near map edges. Depth-scaling (`updatePlayerDepthScale()`) is unique to this scene and works independently of the camera system.

### PlayerNode ✅
No camera code. `walkTo()` and `walkPath()` correctly manage `isWalking` flag and call `completion` exactly once. Animation frame playback uses `SKAction.repeatForever` appropriately (ambient world animation exemption applies per CLAUDE.md). `setFacingDirection()` preserves magnitude when flipping xScale sign — correct.

---

*Generated 2026-05-17. Next audit target: 2026-05-24.*
