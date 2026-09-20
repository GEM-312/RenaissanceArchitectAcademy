# Zone Terrain Prompts — Padua, Venice, Renaissance Rome, Milan, Florence

Art prompts for the 5 terrain backgrounds the zone system needs (Ancient Rome is done).
Written for **Midjourney**, which is what the current Rome terrain came from.

Zone order follows the storyteller's 5-act arc in `docs/voice-cast-plan.md` — the
Duomo is building 17, the finale, where Brunelleschi takes over and Cosimo de Medici
returns. So **Florence is last, and it holds only the Duomo.**

| | zone | plots | act |
|---|---|---|---|
| I | Ancient Rome — *done* | 8 | I–II |
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
   The terrain must show *flat, bare, slightly-sunken ground patches* where they go —
   no structure, no walls, no roof. The first Rome terrain had the buildings painted
   in and every one had to be cut out and the hole filled by hand. Ask for the plots
   explicitly, and count them (table above).

2. **Aspect ratio 7:5 (= 1.4:1), exported at 4500×3214.** The scene is 3500×2500,
   also 1.4:1. Anything else stretches.

3. **The map floats on parchment.** The painted land should sit in the middle and
   fade out into bare aged paper at all four edges — no hard border, no frame. The
   camera clamps to the map bounds, so a hard edge reads as a cut-off.

4. **Trees that can be lifted out.** A handful (6–10) of clearly separated, fully
   visible trees standing on open ground, not overlapping each other or a plot.
   Those become the swaying sprites. **You'll still need to fill the hole behind
   each one after cutting** — that's the step that got missed on Rome.

5. **No text, no labels, no people, no compass rose, no cartouche.** Labels are
   drawn by the game. People break the scale.

6. **Roads painted in.** A connected path network linking the plots. The waypoint
   graph gets drawn to follow them, so they should actually join up.

---

## Shared style block

Paste this at the end of every prompt below:

```
aerial three-quarter bird's-eye view, Leonardo da Vinci notebook study, soft
watercolor wash over fine brown ink linework, muted earth palette, aged cream
parchment background showing through, painted area fading softly to bare paper
at all edges, no text, no labels, no people, no border --ar 7:5 --style raw
```

---

## II. Padua

> Renaissance university quarter seen from above, a walled circular botanical garden
> divided into geometric quadrant planting beds beside a compact brick college
> courtyard, a narrow canal along one edge with a low arched bridge, gravel walks,
> ordered rows of medicinal herbs, muted sage-green and warm brick palette,
> **two flat empty building plots of bare pale earth, completely vacant, no
> structures** — one circular at the centre of the walled garden, one rectangular in
> the courtyard — joined by a straight gravel path, six separate small trees spaced
> along the garden wall

Plots: **Botanical Garden** (the circular one inside the walled garden — this is the
Orto Botanico, 1545, the world's first academic botanical garden), **Anatomy Theater**
(the rectangular courtyard plot). Both are University of Padua, so they should read as
one campus, not two separate places.

---

## III. Venice

> Renaissance lagoon seen from above, shallow blue-green water threaded with narrow
> channels and mudflats, low marshy islands joined by timber walkways and small stone
> bridges, clusters of wooden mooring piles in the water, salt marsh grass, teal and
> pale sand palette cooler than the mainland, **two large flat empty rectangular
> building plots of bare packed earth raised just above the waterline, completely
> vacant, no structures**, linked by boardwalk paths, seven separate wind-bent trees
> and shrubs on the island edges

Plots: **Glassworks** (its own small island — Murano), **Arsenal** (the largest island,
with open water on one side for the shipyard).

---

## IV. Renaissance Rome

> Renaissance Rome seen from above, the Tiber curving through, weathered ancient ruins
> and broken columns half-buried in meadow alongside fresh construction, stacked
> travertine blocks and timber scaffolding, umbrella pines, dusty ochre and warm grey
> palette, **two large flat empty rectangular building plots of bare levelled earth
> with foundation stones only, completely vacant, no structures**, joined by a paved
> road along the riverbank, seven separate umbrella pines and cypresses standing alone

Plots: **Vatican Observatory** (highest ground, for sightlines), **Printing Press**
(near the road, in the working part of the map).

---

## V. Milan

> Renaissance Lombard plain seen from above, flat farmland cut by straight man-made
> irrigation canals with brick lock gates, poplar rows along the waterways, a mulberry
> orchard, low mist, cooler grey-green and straw palette, flatter and more geometric
> than Tuscan hills, **two large flat empty rectangular building plots of bare swept
> earth, completely vacant, no structures**, joined by a straight paved road running
> beside the main canal, eight separate tall poplars standing alone

Plots: **Leonardo's Workshop** (beside the canal), **Flying Machine** (the most open
ground — it needs clear space around it for the launch).

---

## VI. Florence — the finale

This one carries the ending, so it should look like the reward: the richest, warmest,
most finished map in the game. It is also the only single-plot zone, so the Duomo's
empty plot must read as *the* destination — everything points at it.

> Renaissance Florence seen from above, the Arno curving through with the covered
> Ponte Vecchio, dense terracotta rooftops of the old city packed around a wide
> central cathedral square, the Tuscan hills and cypress rows rising behind, golden
> late-afternoon light, warm terracotta, ochre and olive-green palette, richer and
> more saturated than the other maps, **one large flat empty octagonal building plot
> of bare pale earth at the centre of the cathedral square, completely vacant, no
> dome, no cathedral, no structure of any kind**, surrounded by low scaffolding
> timbers and stacked marble blocks, every street converging on the empty square,
> seven separate cypress and olive trees standing alone on the hillside

Plot: **Il Duomo** — octagonal, because Brunelleschi's dome is octagonal and the
sprite will sit exactly there. Say "no dome" in the prompt as many times as it takes;
Midjourney will fight you on this one, since a Florence aerial without the Duomo is
not what it has seen before.

---

## After generation

1. Resize/export to 4500×3214.
2. Install as `<Zone>Terrain.imageset` + `Blurred<Zone>Terrain.imageset`, set
   `compression-type` at authoring time — the catalog is already ~315 MB compiled
   (see `docs/research/asset-size-plan.md`).
3. Cut the trees out, **fill each hole**, export with a soft anti-aliased matte
   (not a hard magic-wand selection — Rome's first cut came back with 1-bit alpha
   and a white keyline).
4. Send me the terrain and the cut-outs and I'll template-match the trees back to
   their exact positions and write the `ZoneDefinition`.
