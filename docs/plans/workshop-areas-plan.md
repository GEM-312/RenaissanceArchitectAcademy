# Workshop Areas Plan — split the outdoor Workshop into 3 maps

**Date:** 2026-10-09
**Status:** DONE Oct 24 2026. All three areas live with signpost travel (`f4d2a31`), the old single
map deleted (`legacy`, `WorkshopTerrain`, `Tree1–9`, and the quarry-crane / river-house / fisherman /
woodcutter / chicken overlays with their art). **Correction to step 6 below:** `WorkshopBackground`
was NOT deleted — it is the Crafting Room and Goldsmith interior art. Still open: no trees or
animated overlays on the new maps yet (new animations planned), Countryside has no painted bridge.
**Why:** the outdoor Workshop terrain (`WorkshopTerrain`, a May 2026 Midjourney map) is out of
style with the Forest + Padua target look, and with 10 stations on one canvas it is crowded.
The city map was split into zones for the same reasons (`docs/plans/zone-system-plan.md`); this
follows the same method.

## Decisions (Marina, 2026-10-09)

- **3 areas.**
- **Travel by signpost at the map edge.** A painted road leaves the map; a tappable signpost
  sits on it. The apprentice walks there like any station, then the next area loads.

| Area (working name) | Stations | Leads to |
|---|---|---|
| **Bottega** — home, where you arrive | Crafting Room, Goldsmith, Market | Countryside, Hills |
| **Countryside** | Farm, River, Forest (opens the existing Forest map) | Bottega |
| **Hills & Quarries** | Quarry, Mine, Clay Pit, Volcano | Bottega |

**Bottega is the hub, not the first link of a chain.** The most frequent cross-area trips are
"no tool → go to the Market → come back" (`WorkshopMapView.swift:1637`, `:1766`) and "go to the
Crafting Room". Both destinations are in the Bottega, so with a hub every such trip is one map
change, and the worst case anywhere is two. A straight Bottega → Countryside → Hills chain
would make every Hills tool trip cross two maps each way. *(Proposed in the planning session;
Marina to confirm or overrule.)*

## What exists today (verified at `7a1447a`)

- `WorkshopScene.swift` (2067 lines), one map, `mapSize` 3500×2500, terrain pair
  `WorkshopTerrain` / `BlurredWorkshopTerrain` via `TerrainBlurHelper` (`:273`). *(Since then:
  the blur layer and `BlurredWorkshopTerrain` were removed 2026-10-13, and the helper is now
  `TerrainHelper`, sharp terrain only.)*
- **10 outdoor stations** in `stationPositions` (`:46-57`). Three of them already leave this map:
  Crafting Room → `CraftingRoomScene`, Goldsmith → `GoldsmithScene` (both via
  `WorkshopView.activeInterior`), Forest → `onNavigate(.forest)` (`WorkshopMapView.swift:771-789`).
- **Walk graph:** 17 waypoints, ~31 edges, `stationWaypoints` (`:71-135`), hub-and-spoke, Dijkstra.
- **Station art is not drawn by code.** `ResourceNode.hideSprites = true` — the stations are
  painted into the terrain; nodes are invisible tap targets + label pills. New terrain art
  therefore *is* the new station art.
- **Ambient overlays, all positioned for the current art** (`setupAmbientEffects` and siblings):
  volcano smoke, lava, glow, 2 smoke accents, crafting-room chimney, quarry crane loop, river flow,
  fisherman, woodcutter, chicken, swaying trees.
- **Bird guidance** points at stations: ~12 `guidanceStationType = …` sites plus
  `walkToStation(_:)` calls (`WorkshopMapView.swift:233`, `:1637`, `:1766`).
- `WorkshopView` is rebuilt whenever you navigate back to the Workshop
  (`ContentView.swift:280`), so anything stored in its `@State` resets on every return.

**Regenerating the terrain invalidates, for every area:** station positions, the waypoint graph,
every ambient-overlay position, and tree cut-outs. Same warning as the zone system. Nothing is lost
that the restyle wasn't already throwing away.

## Where each existing overlay goes

| Area | Overlays that move with it |
|---|---|
| Bottega | crafting-room chimney smoke, smoke accent 2 |
| Countryside | river flow, fisherman, woodcutter, chicken |
| Hills | volcano smoke, lava, glow, smoke accent 1, quarry crane loop |

Whether each one survives depends on the new art — e.g. the fisherman only makes sense if the
Countryside river is painted with a bank to stand on. Drop any that no longer fit; don't force them.

## Architecture

Mirror `CityScene(zone:)`: **one scene class, data per area.** No subclasses, no base class.

```swift
// Models/WorkshopAreaDefinition.swift — pure data, no SpriteKit
struct WorkshopAreaDefinition {
    let id: WorkshopAreaID                 // .bottega, .countryside, .hills
    let displayName: String
    let mapSize: CGSize                    // 3500×2500, same as today
    let terrainPixelWidth: CGFloat         // 4500
    let sharpTerrainImageName: String
    let stations: [ResourceStationType: CGPoint]
    let exits: [WorkshopAreaExit]          // the signposts
    let waypoints: [CGPoint]
    let waypointEdges: [[Int]]
    let stationWaypoints: [ResourceStationType: [Int]]
    let playerSpawn: CGPoint               // used on first entry
    let trees: [ZoneTreePlacement]         // reuse the city struct as-is
    let ambient: [WorkshopAmbientPlacement]
}

struct WorkshopAreaExit {
    let destination: WorkshopAreaID
    let label: String                      // "To the Hills"
    let position: CGPoint                  // the signpost
    let waypoints: [Int]                   // like stationWaypoints
    let arrivalSpawn: CGPoint              // where you appear in the destination
}

struct WorkshopAmbientPlacement {
    let kind: Kind                         // .volcanoSmoke, .lava, .chimney, .riverFlow, …
    let position: CGPoint
    enum Kind { case volcanoSmoke, volcanoLava, volcanoGlow, smallSmoke, chimney,
                quarryCrane, riverFlow, fisherman, woodcutter, chicken }
}
```

Why a new struct instead of reusing `ZoneDefinition`: zones hold *buildings* (`ZoneBuildingPlacement`,
plot IDs, labels, banners); areas hold *stations* and *exits*. Sharing one struct would give both
sides fields they never use. `ZoneTreePlacement` is genuinely the same thing, so it is reused.

**Signposts are their own small node, not new `ResourceStationType` cases.** That enum is switched
on across materials, tools, sounds, Game Center activities, knowledge cards and NPC prewarm.
Adding `.exitToHills` would ripple into all of them. An `AreaExitNode` with its own tap branch in
`handleTapAt` and an `onExitReached(WorkshopAreaID)` callback stays contained in `WorkshopScene`.

**Where the current area lives:** `WorkshopState.currentArea` (in memory, not saved to disk). It must
survive `WorkshopView` being rebuilt, so returning from the Forest lands you in the Countryside and
leaving the Crafting Room or Goldsmith lands you in the Bottega. Entry from the city lands in the
Bottega.

**Swap the scene, keep the view.** On an area change, `WorkshopMapView` builds a new
`WorkshopScene(area:)` (`.id(areaID)` on the sprite view, the way the DEBUG Padua toggle swaps city
maps) but keeps its own `@State`. That matters: `returnToStationAfterMarket` and the guidance state
are `@State` in `WorkshopMapView`, and they must survive the trip to the Market and back. Only one
`WorkshopScene` is alive at a time; the old one's terrain is released in `willMove(from:)` as today.

**Cross-area guidance.** `walkToStation(station)` in a scene that does not contain `station` walks to
the exit toward the station's area instead. On arrival in the new area, guidance re-runs (it already
does on appear) and now points at the station directly. No new guidance text is needed for v1. The
bird's message still names the real station ("Head to the Quarry"); the walk just goes via the sign.

## Steps — each one ships on its own, `main` builds after every step

1. **Data move, no visible change.** Add `WorkshopAreaDefinition` + `WorkshopAreaRegistry`, give
   `WorkshopScene` an `init(area:)`, and move today's hardcoded values into
   `WorkshopAreaRegistry.legacy`, byte-identical (10 stations, 17 waypoints, edges,
   `stationWaypoints`, overlay positions, trees, `"WorkshopTerrain"`). Verify by comparing parsed
   values old vs new, as was done for `ZoneRegistry.ancientRome`, then Marina's iPad smoke test:
   walk to all 10 stations, every overlay where it was.
2. **Art: three Midjourney terrains, 4500×3214,** Forest + Padua style (`--sref` Forest1 +
   PaduaTerrain), low oblique camera like Forest, stations painted in, one road leaving the map
   per signpost. Prompts to be added to `docs/zone-terrain-prompts.md`. Resize/desaturate with
   `scripts/photoshop/ResizeBackgrounds.jsx` and `DesaturateOpenDocs.jsx`.
3. **First real area behind a DEBUG switch** — the one whose art lands first. Placeholder station
   and waypoint positions, Marina drags them in editor mode, positions baked into the registry.
   Players still get `legacy`.
4. **Signposts + `currentArea` + cross-area guidance** (the only genuinely new logic). Testable with
   two areas: Hills → no pickaxe → Market in Bottega → back to Quarry.
5. **Remaining areas,** one at a time, each verified in isolation.
6. **Switch players over and delete `legacy`**, plus the old `WorkshopTerrain` /
   `WorkshopBackground` assets once nothing references them.

## Open questions

- **Bottega as hub vs. a straight chain** — see Decisions above.
- **Area names** shown on signposts. Working names: Bottega / Countryside / Hills & Quarries.
  Italian (*Bottega / Campagna / Colline*) would match "Bottega di Lotti" and the Renaissance
  setting; English is easier for young players.
- **Ambient overlays that no longer fit the new art** — decide per overlay after seeing each terrain.

## Risks

- **Asset size:** 3 new terrains replace 1. Set lossy compression at authoring time
  (`docs/research/asset-size-plan.md`), as the zone plan recommends.
- **Tutorial and onboarding text** that names a station's position ("the quarry up north") may stop
  being true. Search `OnboardingContent.swift` and the station lessons when the art lands.
- **Station lessons and knowledge cards** are keyed by `ResourceStationType`, not position, so they
  carry over untouched.

## Applying the art — plan agreed 2026-10-20, start next session

**Where the art is.** Marina's edited terrains, 4500×3214 PNG, in `~/Downloads` (Dropbox):
`bottega_market_goldsmith_layout.png`, `countryside_workshop_layout.png`,
`cuarry_mine_clay_pit_layout.png`. Generated in Midjourney from the Forest style reference only
(no image prompt), then `scripts/photoshop/ResizeAndCameraRaw.jsx` + her Camera Raw pass. No PSDs
were saved, so the editable Camera Raw smart filters exist only while those Photoshop tabs stay open.

**What the art shows (checked Oct 20):**
- **Bottega** — Crafting Room (workshop with tall chimney, open doors), Goldsmith (carved shopfront),
  Market (striped-awning stalls on paving), a well, a road + signpost leaving left and another leaving right.
- **Countryside** — farm with garden and paddock, river with a sandbank, wheat field, olive grove,
  forest at top right with a footpath into it, one road + signpost leaving right (toward the Bottega).
- **Hills** — quarry terraces, mine entrance with timber frame, red clay pit, volcano with painted
  smoke and lava, one road + signpost leaving left (toward the Bottega). Ore heaps are not visible.
- **Already painted, so their animated overlays would show twice:** Bottega chimney smoke,
  Hills volcano smoke and lava. Decide per overlay in editor mode.
- **Hills clay pit** is painted bright red and may read as lava next to the volcano; Marina to judge.

**Steps** (each ends with Marina's iPad test; no Mac builds; commit only when she says):
1. **Assets.** Add `WorkshopBottegaTerrain`, `WorkshopCountrysideTerrain`, `WorkshopHillsTerrain`
   imagesets, copying `WorkshopTerrain.imageset/Contents.json` (`gpu-optimized-best`). Check:
   4500×3214, `WorkshopTerrain` untouched, game unchanged. ~20–28 MB each.
2. **Bottega behind a DEBUG button.** `WorkshopAreaRegistry.bottega` (3 stations, rough waypoints
   placed from the art, spawn, no trees, ambient empty or chimney only). DEBUG-only button in
   `WorkshopMapView` toggling legacy ↔ Bottega, copied from the city zone button
   (`CityMapView.swift:753`: nil the scene callbacks, nil `sceneHolder.scene`, change an `@State`
   id; add `.id(areaId)` to the `GameSpriteView` at `WorkshopMapView.swift:108`; `makeScene()` at
   `:719` reads the registry by id). Marina drags positions in editor mode (E), pastes the dump,
   values baked into the registry. Check: 3 stations walk + open; switching back shows legacy.
   Note: `WorkshopScene.walkToStation` silently does nothing for a station not on the map
   (`resourceNodes[stationType]` is nil), so bird guidance to off-map stations is a no-op until step 3.
3. **Signposts + `WorkshopState.currentArea` + cross-area guidance** (design under Architecture
   above). Needs Marina's call on signpost names: English or Italian. Check: Hills → no pickaxe →
   Market in Bottega → back to Quarry.
4. **Countryside, then Hills,** same routine as step 2.
5. **Switch players over,** delete `legacy` + `WorkshopTerrain`/`WorkshopBackground`; search
   onboarding and lesson text for position words ("the quarry up north").

Also after approval: add the final workshop + forest no-hatching prompts to `docs/zone-terrain-prompts.md`.
