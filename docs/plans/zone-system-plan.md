# Zone System Implementation Plan — One Map Per Zone

**Date:** 2026-09-19
**Status:** Planning only. No Swift, asset, or `project.pbxproj` files were touched to produce this document.
**Decision already made (not re-litigated here):** Option B — each of the 6 zones gets its own terrain image and its own set of building sprites, and the player travels between zones.

Every claim below is grounded in a file read in this repo at HEAD (`511982e`, branch `plan/zone-system` off `main`). Where I could not verify something the September prompt asserted, I say so rather than repeat it.

---

## 0. What exists today (verified)

- **`CityScene.swift`** (1336 lines) is one `SKScene` holding all 17 buildings on a single `mapSize = CGSize(width: 3500, height: 2500)` canvas (`CityScene.swift:105`). It has:
  - A terrain sprite pair via `TerrainBlurHelper`: sharp `"Terrain"` + blurred `"BlurredTerrain"` (`CityScene.swift:459`).
  - A **40-node** waypoint array (`waypoints`, indices 0–39, `CityScene.swift:114-170`) and a **56-edge** adjacency list (`waypointEdges`, `CityScene.swift:173-205`), searched with a from-scratch Dijkstra over virtual start/end nodes (`buildAdjacency()`, `findPath(from:to:startWaypoints:endWaypoints:)`, `CityScene.swift:764-860`).
  - A `buildingWaypoints: [String: [Int]]` map, one entry per building, pointing at its 2 nearest junctions (`CityScene.swift:208-226`).
  - Camera: `maxZoomOutScale` starts at 3.5 (`CityScene.swift:22`), scale is clamped to `max(0.5, min(maxZoomOutScale, …))` everywhere (e.g. `CityScene.swift:1073`, `:706`, `:717`, `:1112`, `:1123`, `:1144`), `fitCameraToMap()`/`computeFitScale()` derive the zoomed-out fit from `mapSize` vs. the view's `.aspectFill` visible area (`CityScene.swift:433-450`), and `clampCamera()` re-clamps position to map bounds every frame (`CityScene.swift:1061-1108`).
  - A `hiddenBuildingIds: Set<String> = ["duomo"]` (`CityScene.swift:109`) — **the terrain currently painted is Ancient-Rome-only**, and Duomo (Florence) is deliberately hidden rather than drawn on ground that isn't there yet. This is the existing, if partial, precedent for "buildings that don't belong on this terrain get suppressed."
  - Six zone labels already exist purely as decoration — Roman numerals I–VI with English names, positioned over where each zone's buildings cluster (`addZoneLabel`, `CityScene.swift:556-573`), named `zone_ancientRome`, `zone_florence`, `zone_venice`, `zone_padua`, `zone_milan`, `zone_renaissanceRome`. They carry no gameplay meaning today — no locking, no camera framing, nothing reads them except DEBUG editor-mode registration (`CityScene.swift:1326-1328`).

- **`BuildingNode.swift`** (601 lines): per-building `buildingSpriteImageName()` (`:153-171`) and `buildAnimationAtlasName()` (`:176-190`) are hardcoded `switch buildingId` statements, each entry independently pointing at an `Assets.xcassets` imageset / 15-frame `.spriteatlas`. `spriteSizeMultiplier` (`:203-214`) hand-tunes per-building foreground/background scale for this one terrain's painted perspective. zPosition: `BuildingNode` itself is added at 10 (`CityScene.swift:547`), its internal `visualContainer` at 1 (`BuildingNode.swift:46`), so art sits at effective 11; swaying trees are placed at 11.5 specifically to clear that (`CityScene.swift:1225-1232`).

  **Correction to the September brief:** it is not quite true that only the 8 Ancient Rome buildings have art. `buildingSpriteImageName()`/`buildAnimationAtlasName()` also have a `"duomo"` case (`BuildingNode.swift:155,178`), and on disk **`Glassworks.imageset` (760 KB) and `GlassworksBuild.spriteatlas` (12 MB, 15 frames) already exist too** — but `BuildingNode`'s switch statements have no `"glassworks"` case, so that art is present but unwired (comment at `BuildingNode.swift:168,187` confirms: *"Glassworks has no plot on this terrain yet"*). So **2 of the 9 Renaissance buildings (Duomo, Glassworks) already have a complete sprite + 15-frame build atlas sitting in the catalog, just not placed on any terrain or referenced by `updateState`.** This matters directly for §6's inventory.

- **`CityViewModel.swift`** (630 lines): one `@Observable` class, one flat `buildingPlots: [BuildingPlot]` array of all 17 (`:17-231`), no notion of zone membership beyond `Building.city: RenaissanceCity?` and `Building.era: Era` (`Building.swift:115-116`). Unlock logic is tier-based (`apprentice`/`architect`/`master`), not zone-based: `isTierUnlocked` gates `.architect` on 3 completed `.apprentice` buildings and `.master` on 3 completed `.architect` buildings, globally, with no zone dimension (`CityViewModel.swift:298-329`).

- **`Building.swift`**: `enum Era { ancientRome, renaissance }` (`:4-15`) and `enum RenaissanceCity { florence, venice, padua, milan, rome }` (`:18-24`) exist, but nothing currently reads `RenaissanceCity` for navigation — only `CityViewModel.buildingsFor(city:)` (`:339-341`), which nothing calls outside grid-view filtering.

- **`GameTopBarView.swift`** (339 lines): the nav dropdown is a flat, hardcoded `[NavItem]` array — Map / All / Rome / Ren. / Workshop / Forest / Notes / (Game Center) / Profile / Settings / Home (`:189-197` + `:202-229`). "Rome" and "Ren." map to `.era(.ancientRome)` / `.era(.renaissance)`, **not** to individual cities — there is no per-city nav entry today.

- **`SidebarView.swift:4-14`** — `SidebarDestination` is the single enum driving all top-level navigation: `.cityMap`, `.allBuildings`, `.era(Era)`, `.profile`, `.workshop`, `.forest`, `.notebook(Int)`, `.notebookPicker`. `ContentView.swift` holds `@State private var selectedDestination: SidebarDestination? = .cityMap` (`ContentView.swift:7`) and a single `switch selectedDestination` (`ContentView.swift:261`) with one `case .cityMap:` that always constructs the same `CityMapView(viewModel:workshopState:notebookState:onNavigate:onBackToMenu:onboardingState:returnToLessonPlotId:)` (`ContentView.swift:263`, repeated verbatim at `:304` and `:314` for other cases that also want the map). There is no zone parameter anywhere in this call chain today.

- **`CityMapView.swift`** (1491 lines) owns scene lifecycle: `@State private var sceneHolder = SceneHolder<CityScene>()` (`:114`) — **`SceneHolder<T>` is already a generic wrapper**, reusable as-is for per-zone scenes. `makeScene()` (`:872-`) creates the `CityScene` exactly once, sets `newScene.size = CGSize(width: 3500, height: 2500)` to match `mapSize` (`:884`), sets `apprenticeIsBoy`, and wires `onMascotReachedBuilding` through a hardcoded `buildingIdToPlotId: [String: Int]` dictionary (`:124`) that translates SpriteKit string IDs to `CityViewModel` integer plot IDs.

- **`PlayerSave.swift`** (SwiftData `@Model`, 89 lines): stores florins, science badges, raw/crafted materials, tools, play time, `activeBuildingId`. **No player position field exists anywhere** — not for the city map, not for Workshop/Forest/CraftingRoom. Camera/player always spawn at a hardcoded point (`CityScene.swift:296`: `CGPoint(x: 620, y: 540)`). Zone-position persistence would be new work, not an extension of an existing field.

- **`PersistenceManager.swift`** (159 lines): `PlayerSave` is fetched/created by `apprenticeName` (`:15-38`); `BuildingProgressRecord` by `(buildingId, playerName)` (`:82-95`). Nothing here is zone-aware; a zone concept would need either a new field on `PlayerSave` or a parallel small model.

- **Sibling scenes already do "separate map," but as full copy-paste, not shared infrastructure.** I read `WorkshopScene.swift` (2067 lines), `ForestScene.swift` (1534), `CraftingRoomScene.swift` (1119), and `GoldsmithScene.swift` (868, a Workshop sub-room wired through `WorkshopView.swift:48`, not part of the 17-building city map). Every one of them independently declares:
  - `class ⟨Name⟩Scene: SKScene, ScrollZoomable` (protocol at `Services/Styles/GameSpriteView.swift:88` — shared, but the scene bodies are not)
  - its own `private let mapSize` — `WorkshopScene.swift:26` and `ForestScene.swift:31` both `3500×2500`; `CraftingRoomScene.swift:41` is `4433×2500`; `GoldsmithScene.swift:63` is `3500×2500`
  - its own `private var waypoints: [CGPoint]` array (`WorkshopScene.swift:71`, `ForestScene.swift:193`, `CraftingRoomScene.swift:75`, `GoldsmithScene.swift:88`)
  - its own copy of `fitCameraToMap`/`computeFitScale`/`clampCamera`/pan/pinch/scroll handlers, each re-typed with the same formulas as `CityScene`'s.

  **There is no existing example in this codebase of a data-driven, parameterized scene.** Every "new map" to date has been a full copy-paste of a previous scene file. This is the single most important fact for §1 below.

---

## 1. Scene architecture

### Recommendation: one shared `ZoneScene` base class + a `ZoneDefinition` data struct, one small `⟨Zone⟩Scene: ZoneScene` subclass per zone

This is a **deliberate departure from the codebase's established convention** (full copy-paste per scene, confirmed in §0). I'm recommending it anyway, and flagging that departure explicitly rather than silently picking it, because of the scale of what copy-paste would mean here: `CityScene.swift` alone is 1336 lines, and of that, roughly 700–800 lines (camera setup/clamp/pan/pinch/scroll, theme toggling, Dijkstra pathfinding, dark-mode glow, tree-sway math, editor-mode registration) are *generic* — they don't depend on which 2–8 buildings are on the map or what the terrain looks like. Copy-pasting `CityScene.swift` six times means six copies of that ~750 lines (~4500 lines total) that all have to be bug-fixed in lockstep forever (the walk-follow lerp comment at `CityScene.swift:351-357` is exactly the kind of subtle fix that would need to land in 6 places). The Workshop/Forest/CraftingRoom/Goldsmith precedent tolerates this because there are only 4 of them and they were built one at a time over months; asking for 6 new near-identical scenes in one project is a different order of duplication risk.

**Shape:**

```swift
// Models/ZoneDefinition.swift — new file, pure data, no SpriteKit import
struct ZoneDefinition {
    let id: String                       // "ancientRome", "florence", "venice", "padua", "milan", "renaissanceRome"
    let displayName: String              // "Ancient Rome"
    let mapSize: CGSize                  // e.g. 3500×2500 — kept per-zone, not hardcoded, since Padua (§5) may want a smaller canvas
    let sharpTerrainImageName: String    // "Terrain", "FlorenceTerrain", …
    let blurredTerrainImageName: String  // "BlurredTerrain", "BlurredFlorenceTerrain", …
    let buildings: [ZoneBuildingPlacement]
    let waypoints: [CGPoint]
    let waypointEdges: [[Int]]
    let buildingWaypoints: [String: [Int]]
    let playerSpawn: CGPoint
    let cameraMaxZoomOutScale: CGFloat   // computed per-zone from mapSize like today's fitCameraToMap, not hand-set
}

struct ZoneBuildingPlacement {
    let buildingId: String   // "aqueduct", matches BuildingNode.buildingId today
    let name: String
    let position: CGPoint
    let era: String
    let rotation: CGFloat
}
```

```swift
// Views/SpriteKit/ZoneScene.swift — new file
/// Everything CityScene.swift:16-1336 has that does NOT depend on which
/// buildings/terrain/waypoints are on the map: camera setup, clamp, pan/pinch/
/// scroll, theme toggle, Dijkstra pathfinding, tree sway, dark glow, editor mode.
class ZoneScene: SKScene, ScrollZoomable {
    let zone: ZoneDefinition
    init(zone: ZoneDefinition) { self.zone = zone; super.init(size: zone.mapSize) }
    // setupCamera(), fitCameraToMap(), computeFitScale(), clampCamera(),
    // findPath(from:to:startWaypoints:endWaypoints:), applyTheme(),
    // setupSwayingTrees()/disturbTreesNearPlayer(), all read `zone.*`
    // instead of a hardcoded `mapSize`/`waypoints`/`waypointEdges`.
}
```

```swift
// Views/SpriteKit/Zones/AncientRomeZoneScene.swift — new file, thin
final class AncientRomeZoneScene: ZoneScene {
    convenience init() { self.init(zone: ZoneRegistry.ancientRome) }
}
// …one per zone, ~5 lines each, OR skip the subclasses entirely and let
// CityMapView-equivalent wrappers instantiate `ZoneScene(zone: ZoneRegistry.florence)`
// directly. A subclass per zone only earns its keep if a specific zone needs
// scene-level behavior CityScene doesn't have today (Padua's special-case in §5
// is the one candidate). Recommend starting with NO subclasses — bare
// `ZoneScene(zone:)` — and only introducing a subclass when a zone actually
// needs one.
```

**Why not a `CityScene(zone:)` parameter on the existing class instead of a new `ZoneScene` base?** Renaming/retrofitting the working, shipped `CityScene` in place is riskier than adding `ZoneScene` alongside it and migrating call sites zone-by-zone (see §7's ordering) — `CityScene` stays exactly as it is until the last migration step, so every step before that is independently revertible without touching the code that's live in the shipped Ancient Rome zone.

**Why not per-zone subclasses with everything hardcoded (matching the Workshop/Forest/CraftingRoom convention exactly)?** That's the lower-risk, zero-new-abstraction alternative, and it's worth naming explicitly since CLAUDE.md's "no abstractions beyond what's requested" principle cuts against inventing `ZoneScene`/`ZoneDefinition`. If Marina would rather match the existing pattern precisely (6 independent `⟨Zone⟩Scene: SKScene` files, each ~600-1300 lines, no shared base), that is a completely valid call — it costs ~3000-4500 lines of near-duplicate code but zero new architecture, and it's what every other "new map" in this repo has done. I'm recommending the shared base because 6 is enough copies that the duplication cost now clearly exceeds the abstraction cost, but this is a judgment call Marina should confirm before implementation starts.

**What each zone-specific piece owns**, restated as the answers to the prompt's four "account for" items:
1. **Per-zone terrain asset names** → `ZoneDefinition.sharpTerrainImageName`/`blurredTerrainImageName`, passed to the existing `TerrainBlurHelper.setup(in:sharp:blurred:mapSize:)` unchanged (`CityScene.swift:459`, `TerrainBlurHelper.swift` already takes these as parameters — no change needed there).
2. **Per-zone building list** → `ZoneDefinition.buildings: [ZoneBuildingPlacement]`, replacing the hardcoded tuple array at `CityScene.swift:498-535`.
3. **Per-zone waypoint graph** → `ZoneDefinition.waypoints`/`waypointEdges`/`buildingWaypoints`, replacing `CityScene.swift:114-226`. `Dijkstra`/`findPath` itself is zone-agnostic and moves to `ZoneScene` unchanged.
4. **Per-zone map size / camera clamp** → `ZoneDefinition.mapSize` drives `computeFitScale()`/`clampCamera()` exactly as `mapSize` does today (`CityScene.swift:433-450`, `:1061-1108`); no formula changes, just reading from `zone.mapSize` instead of the `private let`.

---

## 2. Navigation

**Recommendation: a travel/world map screen, reached from the existing top-bar dropdown, replacing the current "Rome"/"Ren." era buttons with one "Travel" entry.**

Evaluated against the brief's four options:

- **Top-bar zone picker (a flat list of 6 zones in the dropdown).** Cheapest to build — `GameTopBarView.swift:189-197`'s `allItems` array gets 6 more entries instead of the current 2 era buttons. Rejected as the *primary* mechanism because 6 flat text rows with no map context is a worse fit for a spatial city-building game aimed at kids than an actual map, and it does nothing to sell "you are traveling between real Renaissance cities" — which is the whole point of Option B. Keep as a **secondary** fast-travel path once a zone is unlocked (see below), because it's nearly free to add and useful once the player has been everywhere once.
- **Walking to an edge exit** (à la a Metroidvania). Rejected: `CityScene`'s waypoint graph and camera clamp are built around one bounded `mapSize`; an "exit off the east edge of Florence into Venice" model means every zone's terrain has to be drawn with a matching edge and a matching entry point on the neighbor, which multiplies the art constraint in §6 (every border must line up with its neighbor) for no clear gameplay payoff, since these are historically separate, non-adjacent Italian cities, not a contiguous open world.
- **Medici-letter narrative trigger** (a story beat unlocks the next city). Good as the **unlock mechanism** (see §4), poor as the **navigation widget** — it tells the player a zone exists, but the player still needs a way to get there on the 3rd, 10th, 50th visit without replaying a cutscene. Use it to *unlock*, pair it with the travel map to *navigate*.
- **A travel/world map screen** — a new SwiftUI (not SpriteKit) view showing 6 stylized city markers on an Italy-shaped background, tap → travel. This is the recommendation. It reuses the existing "modal overlay on a parchment background" visual language already established by `BuildingDetailOverlay.swift` and `OnboardingView.swift`'s narrative pages, needs no new waypoint math, and gives the Medici-letter unlock beats somewhere concrete to point at ("a letter arrives — Florence is now on your map").

**Fit with existing navigation:**
- **`SidebarDestination`** (`SidebarView.swift:4-14`) gains one case: `case zone(String)` (using the same `String` zone-id scheme as `BuildingNode.buildingId` today, e.g. `"ancientRome"`, `"florence"`) or, if Marina wants stronger typing, a new `enum ZoneID: String, CaseIterable` mirrored from `ZoneDefinition.id`. Recommend the latter for compile-time safety over stringly-typed zone IDs threaded through `ContentView`'s switch.
- Add `case travelMap` to `SidebarDestination` for the new screen itself.
- **`GameTopBarView.swift`**: replace the two `NavItem`s at `:192-193` (`Rome` → `.era(.ancientRome)`, `Ren.` → `.era(.renaissance)`) with one `NavItem(icon: "map.fill", label: "Travel", destination: .travelMap) { onNavigate(.travelMap) }`. The existing `Map` button (`:190`) keeps meaning "show me the zone I'm currently in."
- **`ContentView.swift`**: the single `switch selectedDestination` (`:261`) gains `case .travelMap: TravelMapView(...)` and `case .zone(let id): ZoneMapView(zone: id, viewModel: cityViewModel, …)` alongside the existing `case .cityMap:`. `CityMapView` itself either becomes zone-parameterized (rename to `ZoneMapView(zone:viewModel:workshopState:notebookState:onNavigate:onBackToMenu:onboardingState:returnToLessonPlotId:)`, one wrapper for all 6 zones) or `CityMapView` stays as today's Ancient-Rome-specific wrapper and 5 new thin wrappers are added — same build-vs-copy tradeoff as §1, and the same recommendation (one parameterized wrapper) for the same reason: `CityMapView.swift` is 1491 lines, and the zone-agnostic parts (scene lifecycle via `SceneHolder<T>`, mascot dialogue routing, locked-tier messaging, editor-mode toggle) dwarf the zone-specific parts (the `buildingIdToPlotId` dictionary and the `newScene.size` literal).

---

## 3. State

**What should persist per zone:** which zones are unlocked, and (optionally, lower priority) last player position within each zone, for "resume where you left off." **What should NOT be duplicated per zone:** building completion, science badges, florins, materials — these are already tracked per building/globally and have no zone dimension to split.

- **`CityViewModel`: stays one view model, not one per zone.** The buildings are a flat, cross-referenced list today (`buildingPlots: [BuildingPlot]`, `CityViewModel.swift:5`) and tier-unlock logic already reasons about *all* buildings globally (`isTierUnlocked`, `:306-315`); splitting into 6 view models would mean either duplicating that cross-zone logic or having 6 view models reach into a 7th "global" one, which is more moving parts for no benefit — nothing in the unlock/completion/scoring logic is naturally zone-scoped. Add a computed property `func buildingsFor(zone: String) -> [BuildingPlot]` alongside the existing `buildingsFor(city:)` (`:339-341`) for the travel-map / zone-scene building lists; that's the only new surface `CityViewModel` needs.
- **New, small, zone-unlock state.** Add `var unlockedZoneIds: Set<String>` to `CityViewModel` (mirrors the existing `earnedScienceBadges: Set<Science>` pattern at `:8`), seeded with `["ancientRome"]`. Gate `ZoneScene` construction / the travel-map's tap target on membership in this set.
- **`PersistenceManager`/`PlayerSave`:** add `var unlockedZoneIdsRaw: [String] = ["ancientRome"]` to `PlayerSave.swift` (same computed-accessor pattern already used for `earnedScienceBadges` at `PlayerSave.swift:22-29`) and load/save it in `CityViewModel.loadFromPersistence()`/`persistPlayerSave()` (`CityViewModel.swift:236-266`, `:268-276`) next to the existing fields. This is a pure *addition* to the `@Model` — SwiftData model additions with a default value don't require a migration for existing saves.
- **Player position per zone:** genuinely new — nothing today persists position for *any* scene (§0). Recommend **skipping this for v1**: every existing scene (Workshop, Forest, CraftingRoom, City) already resets the player to a hardcoded spawn point on every scene creation (`CityScene.swift:296`), and nobody has asked for "remember where I was standing." Don't add `lastPositionInZone: [String: CGPoint]` speculatively — CLAUDE.md's Karpathy guidelines are explicit about this ("no error handling for impossible scenarios," "no configurability that wasn't requested"). If Marina wants it later, it's a small addition once the zone system itself is live and she's felt the need.
- **Building progress** (`BuildingProgressRecord`, `PersistenceManager.swift:82-95`) needs **no change** — it's already keyed by `buildingId` (an `Int` matching `BuildingPlot.id`), and that ID space doesn't change under Option B; a building simply now renders on its zone's terrain instead of the shared one.

---

## 4. Unlocking

**Recommendation: linear era progression — Ancient Rome unlocked from the start; the 5 Renaissance zones unlock as a group once Ancient Rome's 8 buildings are complete, each with its own Medici-letter narrative beat as the *reveal*, not as a further gate between them.**

Reasoning:
- `CityViewModel.completeCount(for:)`/`isTierUnlocked(_:)` already encode a global "3 apprentice buildings done → architect tier unlocks" rule (`:298-315`) that's orthogonal to zone — a building's `difficultyTier` (`MasteryLevel`) is independent of which zone it's in. Layering a *second*, zone-based gate on top (e.g. "Venice needs Florence done first") would mean a building can be tier-unlocked but zone-locked or vice versa, which is confusing to explain to an 8-year-old player and to debug. Keep it to one axis: **Ancient Rome first (matching the existing `Era` split and the game's own framing — you learn Roman engineering before Renaissance science), then all 5 Renaissance zones open together.**
- Gating the 5 Renaissance zones individually behind each other (Florence → Venice → Padua → Milan → Rome, in some order) invites an arbitrary ordering decision with no historical or pedagogical basis — the sciences taught (biology in Padua, optics in Venice, astronomy in Rome) don't have a natural prerequisite chain, unlike Rome-before-Renaissance which the game already frames as "ancient engineering, then Renaissance science built on it."
- Where this lives in data: `CityViewModel.unlockedZoneIds` (§3) starts as `["ancientRome"]`; the moment `completeChallenge(for:)` (`CityViewModel.swift:347-364`) detects `romeComplete` (already computed at `:360` for the existing Game Center achievement!), also do `unlockedZoneIds.formUnion(["florence", "venice", "padua", "milan", "renaissanceRome"])` and persist. The Medici-letter beats become 5 short `StoryNarrativeView`-style pages (that view and its typewriter-text pattern already exist, `Views/Onboarding/StoryNarrativeView.swift`) shown once, in sequence, right after Rome completes — narrative dressing on a single unlock event, not 5 separate gates.

---

## 5. Padua

**Padua has one building (Anatomy Theater, `CityViewModel.swift:167-178`). Recommendation: give it a small special-location terrain rather than merging it into Venice or Milan, or authoring more buildings for it.**

- **Don't merge it into another zone.** Anatomy Theater's sciences (Biology, Optics, Chemistry — `CityViewModel.swift:173`) don't share a terrain-appropriate visual identity with Venice's canal city or Milan's workshop-district framing; grafting one building onto a terrain painted for a different city's skyline is a bigger art ask (repainting part of that terrain to make room, and explaining historically why a Paduan anatomy theater sits inside Venice) than giving Padua its own small canvas.
- **Don't add more buildings speculatively.** There's no pedagogical gap being filled — Padua's one science trio is already covered, and CLAUDE.md's roadmap doesn't list "more Padua buildings" as a planned item. Inventing buildings just to fill out a zone is exactly the kind of unrequested scope the Karpathy guidelines warn against.
- **Do give it a small special location.** A `ZoneDefinition` for Padua with a proportionally smaller `mapSize` than the other zones (e.g. 1500×1200 instead of 3500×2500 — this is exactly why `ZoneDefinition.mapSize` is per-zone data in §1, not a shared constant) works with the same `ZoneScene` base, the same terrain-pair convention (just a smaller/cheaper terrain image, §6), and the same travel-map entry, at minimal extra art cost — one building, one small courtyard-scale terrain, no waypoint graph complexity (a 1-node "walk straight to the theater" graph, or skip pathfinding entirely and walk direct like `CityScene`'s `directWalkThreshold` short-circuit already does for close targets, `CityScene.swift:891-898`).

---

## 6. Asset inventory

Per the brief's spec: terrain PNG at **4500×3214** (verified: `Terrain_buildings.png` is exactly `4500×3214`, aspect `4500/3214 = 1.40015`, matching the `mapSize` 3500:2500 = 1.4 aspect — `file` output confirmed directly), blurred companion at **2048 wide** (verified: `BlurredTerrain.png` is `2048×1463`, same 1.4 aspect), N building sprites, N 15-frame build atlases.

**Ancient Rome is done** — confirmed: `BuildingNode.swift:154-171` and `:176-190` list all 8 (`aqueduct`, `colosseum`, `romanBaths`, `pantheon`, `romanRoads`, `harbor`, `siegeWorkshop`, `insula`), all 8 `.spriteatlas` folders exist with 15 `Frame00`–`Frame14` imagesets each (measured on `AqueductBuild`/etc. per `docs/research/asset-size-plan.md` row 2: "8 building-construction atlases … 120 files … 89.3 MB").

**Correction from §0: 2 of the 9 Renaissance buildings are also already fully drawn**, just unwired and un-terrained:
| Building | Zone | Sprite | Build atlas | Wired in `BuildingNode.swift`? |
|---|---|---|---|---|
| Duomo | Florence | ✅ `Duomo.imageset` (952 KB) | ✅ `DuomoBuild.spriteatlas`, 15 frames (14 MB) | ✅ yes, but suppressed by `hiddenBuildingIds` |
| Glassworks | Venice | ✅ `Glassworks.imageset` (760 KB) | ✅ `GlassworksBuild.spriteatlas`, 15 frames (12 MB) | ❌ no — switch has no `"glassworks"` case |

**What's still needed — 7 buildings, from scratch:**

| Building | Zone | Sprite needed | Build atlas needed |
|---|---|---|---|
| Botanical Garden | Florence | ✅ | ✅ (15 frames) |
| Arsenal | Venice | ✅ | ✅ (15 frames) |
| Anatomy Theater | Padua | ✅ | ✅ (15 frames) |
| Leonardo's Workshop | Milan | ✅ | ✅ (15 frames) |
| Flying Machine | Milan | ✅ | ✅ (15 frames) |
| Vatican Observatory | Renaissance Rome | ✅ | ✅ (15 frames) |
| Printing Press | Renaissance Rome | ✅ | ✅ (15 frames) |

= **7 sprites + 7×15 = 105 build-animation frames.**

**Terrain — 5 zones need a full pair** (Ancient Rome's is done; Padua's can be smaller per §5 but still needs its own pair):

| Zone | Sharp terrain | Blurred companion |
|---|---|---|
| Florence | 1 | 1 |
| Venice | 1 | 1 |
| Padua (smaller canvas, §5) | 1 | 1 |
| Milan | 1 | 1 |
| Renaissance Rome | 1 | 1 |

= **5 sharp + 5 blurred = 10 terrain images.**

**Totals still needed:** 7 building sprites, 105 build-animation frames (7×15), 10 terrain images (5 sharp + 5 blurred) = **122 new art assets**, plus **2 buildings' worth of already-drawn art (Duomo, Glassworks) that only needs code wiring, not new art.**

**A cost note the brief didn't ask for but §8 needs:** per `docs/research/asset-size-plan.md` (measured on this exact repo, row 1), the *existing* `Terrain`+`BlurredTerrain`+`WorkshopTerrain`+`WorkshopBackground` four-file group is **125.3 MB of source PNG before compression**, and the same doc's row 2 shows the 8 existing build atlases are **89.3 MB before compression**. Naively adding 5 more terrain pairs and 105 more full-depth-RGBA build frames at similar resolutions would roughly **double** the terrain contribution and add **~78 MB more** at current per-frame weight (89.3 MB ÷ 8 buildings × 7 new ≈ 78 MB) to the asset catalog — on top of a catalog that `docs/research/asset-size-plan.md` already measured at ~485 MB on disk / ~315 MB compiled, with an *unexecuted* plan (Phases 0–3, "stop after phase 3") to bring it down to ~65–85 MB. **This is a sequencing risk, not just a size number — see §8.**

---

## 7. Migration path

Each step below is independently shippable and buildable — i.e. `main` builds and the app runs correctly after every step, even if the next step never lands.

1. **Add `ZoneDefinition`/`ZoneBuildingPlacement` (pure data, `Models/ZoneDefinition.swift`) and `ZoneScene` (pure refactor, `Views/SpriteKit/ZoneScene.swift`) — no behavior change.** Extract `CityScene`'s zone-agnostic code (camera, clamp, pathfinding, theme, tree sway, editor mode — §1) into `ZoneScene`. Make `CityScene` itself a thin `ZoneScene` subclass constructed with a `ZoneDefinition` built from today's exact hardcoded values (same 40 waypoints, same 56 edges, same `"Terrain"`/`"BlurredTerrain"`, same 17-building list minus `hiddenBuildingIds`). **This step touches all 40 waypoints and all 17 building placements — it's a pure data move, not a redesign, and should be a mechanical, verifiable-by-diff refactor with zero visual/behavioral change.** Verify: build + smoke-test the city map exactly as it works today (walk to every building, zoom, pan, tap).
2. **Wire the 2 already-drawn-but-unused buildings (Duomo, Glassworks) into their real zones**, as a small, low-risk, high-payoff step that ships visible progress before any new art exists. Requires: (a) a Florence `ZoneDefinition` with just Duomo placed + a minimal waypoint graph + a terrain pair (new art — the first of the 5 terrain pairs from §6, or a placeholder/solid-color terrain if Marina wants to sequence code before art), (b) same for Venice/Glassworks, (c) removing `"duomo"` from `hiddenBuildingIds` (`CityScene.swift:109`) since it now lives in its own zone rather than suppressed on Rome's terrain, (d) adding the `"glassworks"` case to `BuildingNode.swift`'s two switches (`:153-171`, `:176-190`) — one line each, the asset is already there. **Does not touch the 40 Ancient Rome waypoints.**
3. **Add `SidebarDestination.zone(ZoneID)` and `.travelMap`, and the `TravelMapView` SwiftUI screen** (§2), wired to only the 2 zones that exist after step 2 (Ancient Rome, Florence) plus a "locked" visual state for the other 4. This is the first step a player-facing build can demo end-to-end: leave Rome, arrive in Florence, see the Duomo.
4. **Add `unlockedZoneIds` to `CityViewModel`/`PlayerSave`/`PersistenceManager`** (§3) and wire the Rome-completion unlock event (§4). Independently testable: complete all 8 Rome buildings in a debug build, confirm the unlock fires and the travel map updates — no new zones need to exist yet for this step to be verifiable (can unlock into the 2 zones from step 2).
5. **One zone at a time: Venice (Arsenal + Glassworks already placed from step 2), Milan (2 buildings), Renaissance Rome (2 buildings), Padua (1 building, smaller canvas per §5).** Each is: author the terrain pair (§6), author sprites + build atlases for that zone's *new* buildings, write the `ZoneDefinition` (building placements + a small waypoint graph — reuse `CityScene`'s existing junction *density* per building as a sizing reference, not the exact coordinates), verify in isolation. **None of these touch the Ancient Rome or Florence waypoint graphs already shipped.**
6. **Remove the now-dead code**: once all 6 zones are live through `ZoneScene`, delete the original hardcoded 17-building list, 40-waypoint array, and single-`mapSize` fields from `CityScene.swift` if anything of the original file still exists standalone (it may not, if step 1 already converted it into a thin subclass) — confirm nothing references the old single-map `CityScene()` constructor from `CityMapView.swift:883` or elsewhere before deleting.

---

## 8. Risks

1. **Asset catalog size — sequencing conflict with the in-flight size-reduction effort.** `docs/research/asset-size-plan.md` (committed, research-only, **not yet executed** — its Phase 0–3 work is proposed, and `git log` shows no follow-up commit applying it) measured the catalog at ~485 MB on disk / ~315 MB compiled `.car`, with lossy imageset compression getting that to an estimated ~65–85 MB shipped. §6 estimates the zone system adds roughly another 80–100+ MB of *uncompressed* source PNG (5 terrain pairs + 105 build frames) if authored the same way the existing art was (full-depth RGBA, no lossy compression set). **Recommendation: set lossy compression on every new zone-system imageset/atlas at authoring time** (the `add-art-asset` skill's resize step is the natural place to also set `compression-type` per `docs/research/asset-size-plan.md §8`'s recommendation), rather than adding ~100 MB of uncompressed art now and re-compressing it later as a second pass. Doing the zone system's art *after* that plan's Phase 2 (catalog-wide lossy compression) lands would also work, and avoids doing the compression pass twice.
2. **Memory from six terrains.** Today one `4500×3214` sharp + `2048×1463` blurred pair is resident whenever the city map scene exists; `willMove(from:)` (`CityScene.swift:326-339`) already calls `terrainBlur.cleanup()` and `removeAllChildren()` on scene teardown, so the existing pattern (one zone's terrain loaded at a time, freed on exit) should carry over directly *if* each zone truly gets its own `SKScene` instance that's torn down on zone switch — this needs to be an explicit design constraint on `TravelMapView`'s navigation (never keep more than one `ZoneScene` alive at once), not an incidental property, since `SceneHolder<T>` (`CityMapView.swift:114`) exists specifically to *keep* a scene alive across SwiftUI re-renders — that's the right behavior *within* a zone, but the wrong behavior *across* zones if not bounded correctly.
3. **ODR / Background Assets implications.** `docs/research/asset-size-plan.md §3.e` already concluded On-Demand Resources is deprecated (iOS 27+) and unsuitable, and recommends Background Assets (Apple-hosted, managed) only if/when the catalog outgrows what compression alone can hold, scoped to the 8 (now potentially 15) build-animation atlases specifically — **not** terrain. That plan's own verdict ("stop after Phase 3," Background Assets only "if still wanted... for reasons other than size") applies unchanged here: the zone system's 7 new build atlases are exactly the kind of content that plan already designed a per-building `onDemand` pack for (`asset-size-plan.md §5`, `"PantheonBuild"`-style pack IDs) — if Background Assets is ever adopted, extending §7.1's `buildAnimationPackID(for:)` switch with the 7 new building IDs is a natural, already-anticipated extension. Terrain images are large but few (11 total including Rome) and load one-at-a-time per §8.2's constraint, so they were correctly out of scope for that plan and should stay out of scope here.
4. **`hiddenBuildingIds` and the "one terrain = one era" assumption baked into `BuildingNode.swift` today.** `spriteSizeMultiplier` (`BuildingNode.swift:203-214`) hand-tunes scale per building *for the specific perspective the Rome terrain was painted in* ("the Rome terrain is drawn in perspective, so apparent size has to fall off with distance," comment at `:198-201`). Each new zone's terrain will need its own perspective-scale tuning pass per building — this is real per-zone art-integration work, not just "drop in a sprite," and should be budgeted as part of each zone's step in §7, not assumed to be free once the sprite exists.
5. **Waypoint-graph sizing is a judgment call with no existing small-zone precedent.** `CityScene`'s 40 waypoints serve 17 buildings on one 3500×2500 map; §7's zones range from 1 building (Padua) to 2 (Florence, Venice, Milan, Renaissance Rome). There's no existing "small map, 1-2 buildings" waypoint graph in this codebase to copy from — `WorkshopScene`/`ForestScene`/`GoldsmithScene` all serve many more stations on comparably large maps. Expect the per-zone waypoint graphs in §7 step 5 to need original design (or, per §5, skipping pathfinding for Padua and using the existing `directWalkThreshold` direct-walk path), not a scaled-down copy of Rome's.

---

## Summary

- **Scene architecture:** new `ZoneScene` base class (extracted from `CityScene`'s zone-agnostic ~750 lines) + a `ZoneDefinition` data struct per zone, rather than 6 independent copy-pasted scene files. This deviates from the Workshop/Forest/CraftingRoom/Goldsmith precedent (each fully self-contained) — flagged as a judgment call for Marina to confirm, since the codebase has zero existing precedent for a parameterized scene.
- **Navigation:** a new `TravelMapView` SwiftUI screen, reached via the top-bar dropdown (replacing the current "Rome"/"Ren." era buttons with one "Travel" entry), with `SidebarDestination` gaining `.travelMap` and `.zone(ZoneID)` cases.
- **Padua:** keep it as its own small special-location zone (smaller `mapSize`, same `ZoneScene`/terrain-pair convention, possibly no pathfinding graph) rather than merging it into Venice/Milan or inventing new buildings for it.
- **Art still needed:** 7 building sprites + 105 build-animation frames (7 buildings × 15) + 10 terrain images (5 zones × sharp+blurred) = **122 new assets** — smaller than a naive "9 Renaissance buildings from scratch" count because Duomo and Glassworks already have complete, unwired art sitting in the catalog.
