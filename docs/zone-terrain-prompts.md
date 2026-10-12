# Zone Terrain Prompts — Ancient Rome, Padua, Venice, Renaissance Rome, Milan, Florence

Art prompts for the 6 terrain backgrounds the zone system needs, plus the 3 workshop areas.
Written for **Midjourney**. Map art stays in Midjourney: a GPT Image 2.5 redraw of Padua
(Oct 9 2026) kept the layout but lost the dreamy Midjourney look, and Gemini did the same
on the Workshop in September.

**House style (decided Oct 12 2026): the Forest map.** Every city and workshop map is made
with the same recipe that made `Forest1`, with only the subject changed. This replaces the
Oct 9 "Forest + Padua" plan (two style references, a long shared style block, `--sw 250`),
which came out grainy and washed out. The style words were not the problem — the Forest prompt
uses the same ones. The references and parameters were.

Zone order follows the storyteller's 5-act arc in `docs/voice-cast-plan.md` — the
Duomo is building 17, the finale, where Brunelleschi takes over and Cosimo de Medici
returns. So **Florence is last, and it holds only the Duomo.**

| | zone | plots | act |
|---|---|---|---|
| I | Ancient Rome — *regenerate in the house style* | 8 | I–II |
| II | Padua | 2 — Botanical Garden, Anatomy Theater | III |
| III | Venice | 2 — Glassworks, Arsenal | III–IV |
| IV | Renaissance Rome | 2 — Vatican Observatory, Printing Press | IV |
| V | Milan | 2 — Leonardo's Workshop, Flying Machine | V |
| VI | **Florence** | **1 — Il Duomo** | **V, finale** |

Read "Hard requirements" first — those are the things that cost real rework on Rome.

---

## Hard requirements (every zone)

These aren't style notes, they're what makes the terrain usable as a game map.

1. **Empty building plots.** Each zone's buildings are separate sprites drawn on top.
   The terrain must leave an open patch where each one goes — no structure, no walls,
   no roof. The first Rome terrain had the buildings painted in and every one had to be
   cut out and the hole filled by hand. In the Forest recipe a plot is a **"round grassy
   clearing"**, and the layout image puts each one where its building stands.

2. **Aspect ratio 7:5 (= 1.4:1), exported at 4500×3214.** The scene is 3500×2500,
   also 1.4:1. Anything else stretches.

3. **The map floats on parchment.** The painted land should fade out into bare aged
   paper at the edges — no hard border, no frame. The camera clamps to the map bounds,
   so a hard edge reads as a cut-off. ("softly faded edges" in the prompt tail does this.)

4. **Trees that can be lifted out.** A handful (6–10) of clearly separated, fully
   visible trees standing on open ground, not overlapping each other or a plot.
   Those become the swaying sprites. **You'll still need to fill the hole behind
   each one after cutting** — that's the step that got missed on Rome.

5. **No text, no labels, no people, no compass rose, no cartouche.** Labels are
   drawn by the game. People break the scale.

6. **Roads painted in.** A connected path network linking the plots. The waypoint
   graph gets drawn to follow them, so they should actually join up.

---

## The recipe (every map)

Cloned from the Forest job — a Midjourney V8 Variation,
<https://www.midjourney.com/jobs/19290ef9-1ead-4e89-b32b-108812fe0f57?index=1>.
Confirmed working on Padua, Oct 12 2026.

| slot | what goes in it |
|---|---|
| **Style Reference** | the **old terrain image** (the May map) — the same one the Forest job used. *Not* Forest1. |
| **Image Prompt** | the map's **layout image** from `~/Desktop/AssetTrim/CityLayouts/` (below). The Forest used a beige clay maze here; the layout image does the same job but puts the clearings where the buildings are. |
| **Prompt** | the map's prompt below — subject first, then the shared tail |
| **Parameters** | `--chaos 10 --ar 7:5 --raw --v 8.2` — nothing else (no `--sw`, no `--stylize`). `--v 8.2` pins the model: HD and "Run batch as HD" only exist in V8.1+, so a job that ran as V7 (an old `--v 7`, or V7 as the settings default) can't be made HD. Add `--hd` to skip the HD rerun on a prompt you already trust. |
| **Personalization** | **off** — it adds your profile's taste on top |

Then: pick the best result → **Vary (Strong)** → **Run batch as HD**. HD is ~2K and can't be
upscaled further inside Midjourney, so the step to 4500×3214 happens in Photoshop (see
"After generation").

**If it goes wrong:**
- Too flat or game-like, copying the layout's blocks literally → add `--iw 0.5`.
- Ignoring the layout, clearings in the wrong places → add `--iw 1.5`.
- Grainy or washed out → check Personalization is off and nothing beyond these four
  parameters crept in. Don't rewrite the style words.

### Shared tail

Every prompt ends with this, exactly as the Forest prompt did:

```
fine sepia ink linework, loose cross-hatching, soft transparent watercolor washes, muted sage green, olive, ochre and warm brown, aged cream parchment, faint pencil construction lines, softly faded edges --chaos 10 --ar 7:5 --raw --v 8.2
```

and every prompt starts with `top-down overhead map of …, a page from Leonardo da Vinci's
notebook`. The prompts below are written out in full so they can be pasted as they are.

### Layout images

`~/Desktop/AssetTrim/CityLayouts/make_layouts.py` draws them with PIL: green land, blue water,
pale roads, and a round clearing at each building's position in scene coordinates (3500×2500,
y up), output at 1960×1400. Change a position there and rerun it rather than editing the PNGs.

| map | layout |
|---|---|
| Ancient Rome | `rome_layout.png` — the 8 current `ZoneRegistry.ancientRome` positions; the river runs east of the Aqueduct and the Harbor sits on its east bank |
| Padua | `padua_layout.png` |
| Venice | `venice_layout.png` |
| Renaissance Rome | `renaissance_rome_layout.png` |
| Milan | `milan_layout.png` |
| Florence | `florence_layout.png` — one octagonal clearing |

---

## I. Ancient Rome — regenerate

The finished zone, so keep everything the game already relies on: **eight** plots, a road
network joining them, a river with a bridge. The 8 building sprites and their build
animations were made against the old map, so after regenerating, check that they still fit
before redoing them (Claude can mock them up on the new map, no credits).

Image Prompt: `rome_layout.png`

```
top-down overhead map of the Ancient Roman countryside, a page from Leonardo da Vinci's notebook, rolling hills framed by dense groves of rounded olive and oak crowns and dark narrow cypress, a winding river with one arched stone bridge, a small walled town on the far hills, winding pale sandy roads that join across the whole page, eight round grassy clearings of different sizes, the largest in the centre, one on the hillside, one beside the river, fine sepia ink linework, loose cross-hatching, soft transparent watercolor washes, muted sage green, olive, ochre and warm brown, aged cream parchment, faint pencil construction lines, softly faded edges --chaos 10 --ar 7:5 --raw --v 8.2
```

Plots: **Aqueduct** (on the slope, so it can carry water down), **Harbor** (on the
riverbank, open water on one side), then Colosseum, Roman Baths, Pantheon, Roman Roads,
Siege Workshop and Insula on the open ground. The Colosseum needs the largest clearing.

---

## II. Padua

Image Prompt: `padua_layout.png`

```
top-down overhead map of a Renaissance university garden, a page from Leonardo da Vinci's notebook, a low circular brick wall enclosing a round grassy clearing, a small brick college courtyard with a second square grassy clearing, a thin canal with a low arched stone bridge, rows of rounded trees, dark narrow cypress, winding pale sandy gravel paths, fine sepia ink linework, loose cross-hatching, soft transparent watercolor washes, muted sage green, olive, ochre and warm brown, aged cream parchment, faint pencil construction lines, softly faded edges --chaos 10 --ar 7:5 --raw --v 8.2
```

Plots: **Botanical Garden** (the round clearing inside the circular wall — this is the
Orto Botanico, 1545, the world's first academic botanical garden), **Anatomy Theater**
(the square courtyard clearing). Both are University of Padua, so they should read as
one campus, not two separate places.

---

## III. Venice

Image Prompt: `venice_layout.png`

```
top-down overhead map of a Renaissance Venetian lagoon, a page from Leonardo da Vinci's notebook, low marshy islands with wind-bent trees and reeds, thin winding water channels, wooden plank boardwalks and small stone bridges, clusters of mooring posts, two round grassy clearings on raised islands, one small island of its own, one large island beside open water, fine sepia ink linework, loose cross-hatching, soft transparent watercolor washes, muted sage green, olive, ochre and warm brown, aged cream parchment, faint pencil construction lines, softly faded edges --chaos 10 --ar 7:5 --raw --v 8.2
```

Plots: **Glassworks** (its own small island — Murano), **Arsenal** (the largest island,
with open water on one side for the shipyard).

---

## IV. Renaissance Rome

Image Prompt: `renaissance_rome_layout.png`

```
top-down overhead map of Renaissance Rome beside a winding river, a page from Leonardo da Vinci's notebook, broken ancient columns and ruins half-hidden among umbrella pines and dark narrow cypress, stacked stone blocks and timber scaffolding, winding pale sandy roads, two round grassy clearings, one on the highest hill, one beside the road, fine sepia ink linework, loose cross-hatching, soft transparent watercolor washes, muted sage green, olive, ochre and warm brown, aged cream parchment, faint pencil construction lines, softly faded edges --chaos 10 --ar 7:5 --raw --v 8.2
```

Plots: **Vatican Observatory** (the clearing on the highest hill, for sightlines),
**Printing Press** (beside the road, in the working part of the map).

---

## V. Milan

Image Prompt: `milan_layout.png`

```
top-down overhead map of the Renaissance Lombard plain, a page from Leonardo da Vinci's notebook, straight thin irrigation canals with small brick lock gates, long rows of slender poplar, a mulberry orchard of rounded crowns, pale sandy roads beside the canals, two round grassy clearings, one beside the main canal, one wide open clearing with space all around, fine sepia ink linework, loose cross-hatching, soft transparent watercolor washes, muted sage green, olive, ochre and warm brown, aged cream parchment, faint pencil construction lines, softly faded edges --chaos 10 --ar 7:5 --raw --v 8.2
```

Plots: **Leonardo's Workshop** (beside the canal), **Flying Machine** (the wide open
clearing — it needs clear space around it for the launch).

---

## VI. Florence — the finale

This one carries the ending, so it should look like the reward. It is also the only
single-plot zone, so the Duomo's empty clearing must read as *the* destination —
everything points at it.

Image Prompt: `florence_layout.png`

```
top-down overhead map of Renaissance Florence, a page from Leonardo da Vinci's notebook, a winding river with a covered bridge, terracotta rooftops of the old town packed around a wide central square, an empty octagonal grassy clearing in the middle of the square with stacked marble blocks and timber scaffolding at its edge, no dome, no cathedral, Tuscan hills with olive groves and dark narrow cypress behind, every street leading to the square, fine sepia ink linework, loose cross-hatching, soft transparent watercolor washes, muted sage green, olive, ochre and warm brown, aged cream parchment, faint pencil construction lines, softly faded edges --chaos 10 --ar 7:5 --raw --v 8.2
```

Plot: **Il Duomo** — octagonal, because Brunelleschi's dome is octagonal and the
sprite will sit exactly there. Midjourney may still paint a dome, since a Florence map
without the Duomo is not what it has seen before; if it does, pick the result with the
emptiest square before Vary (Strong), or paint the square out in Photoshop.

---

## Workshop areas — Bottega, Countryside, Hills

The outdoor Workshop is being split into three maps the same way the city was split into
zones — see `docs/plans/workshop-areas-plan.md`. Same recipe as the cities (old-terrain Style
Reference, shared tail, same parameters, Personalization off), same 4500×3214. **There are no
layout images for these yet** — either leave the Image Prompt empty, or ask Claude to add the
three areas to `make_layouts.py` once the station positions are settled.

**Two hard requirements are different from the city zones:**

- **Stations are painted IN, not left as empty clearings.** On the city maps buildings are
  separate sprites, so plots must be bare. Workshop stations have no sprite —
  `ResourceNode.hideSprites` is on, and the game draws only an invisible tap target and a label
  pill. Whatever the terrain shows *is* the station. Ask for each station by name and count them.
- **Roads leave the map.** Each signpost to another area sits on a road that runs off one side
  edge and fades into the parchment. Ask for an empty wooden signpost (no lettering — the game
  draws the label) where the road meets the edge.

Geography, so the three maps agree with each other: the **Countryside is to the west** of the
Bottega and the **Hills are to the east**. So the Bottega's roads leave by the left and right
edges, the Countryside's road leaves by the right edge, and the Hills' road leaves by the left.

Animated overlays are drawn on top of some stations — the Crafting Room chimney smoke, the
volcano smoke and lava, the quarry crane, the river flow, a fisherman, a woodcutter, chickens.
Paint the place they need (a chimney, a crater, a riverbank) but **not the moving thing itself**,
or the overlay doubles it. The quarry is the one to watch: leave the crane out.

### Workshop I. Bottega — the home yard, where the player arrives

```
top-down overhead map of a Renaissance artisan workshop yard at the edge of a Tuscan town, a page from Leonardo da Vinci's notebook, three places clearly separated across the page, a stone workshop with a tall brick chimney and open double doors, a small goldsmith's shop with a carved wooden shopfront, an open-air market of striped canvas awnings over empty stalls with crates, barrels and sacks, a cobbled yard with a well between them, terracotta rooftops of the town at the top edge, groves of rounded trees and dark narrow cypress, two winding pale sandy roads leaving the page at the left and right edges, an empty wooden signpost beside each road, fine sepia ink linework, loose cross-hatching, soft transparent watercolor washes, muted sage green, olive, ochre and warm brown, aged cream parchment, faint pencil construction lines, softly faded edges --chaos 10 --ar 7:5 --raw --v 8.2
```

Stations: **Crafting Room** (the chimney building — the chimney-smoke overlay sits on that
chimney), **Goldsmith** (Bottega di Lotti), **Market**. Signposts: left → Countryside,
right → Hills.

### Workshop II. Countryside

```
top-down overhead map of Renaissance Tuscan farmland in a river valley, a page from Leonardo da Vinci's notebook, three places clearly separated across the page, a stone farmhouse with a barn, hay stacks, a vegetable plot, beehives and an empty fenced poultry yard, a slow winding river with a wide pale sandbank and a grassy bank, the dark edge of a dense oak and chestnut forest with a footpath leading into the trees, wheat fields and olive groves between them, dark narrow cypress, a winding pale sandy road leaving the page at the right edge, an empty wooden signpost beside the road, fine sepia ink linework, loose cross-hatching, soft transparent watercolor washes, muted sage green, olive, ochre and warm brown, aged cream parchment, faint pencil construction lines, softly faded edges --chaos 10 --ar 7:5 --raw --v 8.2
```

Stations: **Farm**, **River** (water + sand, so the sandbank matters; the river-flow,
fisherman and woodcutter overlays go here), **Forest** (opens the Forest map — so the
footpath into the trees is the entrance). Signpost: right → Bottega. The poultry yard is
empty because the chicken overlay supplies the chickens.

### Workshop III. Hills & Quarries

```
top-down overhead map of the rocky Renaissance Apennine hills, a page from Leonardo da Vinci's notebook, four places clearly separated across the page, a pale limestone and marble quarry cut in stepped white terraces into a cliff, a mine entrance braced with heavy timber beams in a dark hillside, an open clay pit of wet red-ochre earth with puddles, a smoking volcano at the top edge with a dark crater, sulphur-yellow vents and a cooled lava slope reaching down the page, gravel tracks linking all four, scrub, broom and umbrella pines, one track leaving the page at the left edge, an empty wooden signpost beside the track, fine sepia ink linework, loose cross-hatching, soft transparent watercolor washes, muted sage green, olive, ochre and warm brown, aged cream parchment, faint pencil construction lines, softly faded edges --chaos 10 --ar 7:5 --raw --v 8.2
```

Stations: **Quarry** (the crane overlay is drawn on top — if Midjourney paints a crane, pick
another result or paint it out), **Mine**, **Clay Pit**, **Volcano** (the smoke, lava and glow
overlays sit on the crater and slope; it can sit at the top edge as long as its slope comes
down far enough for a path to reach it). Signpost: left → Bottega.

For all three, install as `Workshop<Area>Terrain` + `BlurredWorkshop<Area>Terrain`
(e.g. `WorkshopBottegaTerrain`).

---

## After generation

1. In Photoshop, **File → Scripts → ResizeAndCameraRaw** (`scripts/photoshop/ResizeAndCameraRaw.jsx`):
   pick the HD exports, and each opens at 4500×3214 (scaled to fill, centre-cropped, never
   stretched) as a Smart Object with the Camera Raw window up — press Auto (⌘U), fix the dark
   spots (U shows clipped shadows in blue), OK. Then the colour pass — the Forest map needed one
   too (greener, stream recoloured, sharpened).
2. Install as `<Zone>Terrain.imageset` + `Blurred<Zone>Terrain.imageset`, set
   `compression-type` at authoring time — the catalog is already ~315 MB compiled
   (see `docs/research/asset-size-plan.md`).
3. Cut the trees out, **fill each hole**, export with a soft anti-aliased matte
   (not a hard magic-wand selection — Rome's first cut came back with 1-bit alpha
   and a white keyline). The tree cut-outs made for the old terrains don't carry over.
4. Send me the terrain and the cut-outs and I'll match each clearing to its building
   position, template-match the trees back to their exact positions, and write the
   `ZoneDefinition`.
