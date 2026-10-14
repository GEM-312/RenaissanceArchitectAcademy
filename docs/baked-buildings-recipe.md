# Baked buildings: painting a building into the map

A "baked" building is painted into the zone terrain itself, in the map's own ink
and watercolour, rather than drawn on beige and placed on top. In the game it is
still an ordinary `BuildingNode`. Its sprite is a patch cut from the map at the
map's own resolution, so it sits pixel-exact over the spot it was painted on.

- Before it's built, the patch shows piles of materials.
- When it's built, the patch plays the construction frames.
- Once it's complete, the patch shows the finished building.

Nothing around the patch ever changes.

First used on Oct 14 2026 for Roman Roads and the Harbor on the Ancient Rome map.
Marina's verdict: "this is perfect".

Use it for buildings that are part of the ground: roads, harbors, quays, gardens,
anything sitting in water or along a path. Tall standalone buildings can still use
the sprite-on-beige pipeline.

## Tools

- **OpenArt Nano Banana Pro**, image2image, 2K, 2 images per call: about 72 credits.
- **OpenArt Kling 3 Omni**, image2video, pro, 5 s, no sound, start and end frame: about 158 credits.
- `scripts/art/bake_preview.py` blends an edit back into its crop, for showing candidates.
- `scripts/art/process_baked.py` turns the frames into game assets and prints the position and multiplier.

Cost per building is about 72 + 72 + 158 = **300 credits** if the first picks work.

## Steps

### 1. Crop the spot

Cut a 1200×1200 px square from the terrain PNG around the spot. Rome's terrain is
`Terrain.imageset/Terrain_buildings.png`, 4500×3214. Keep the crop's top-left corner,
`ORIGIN_X, ORIGIN_Y`, in terrain pixels.

To convert between scene points and terrain pixels:
- `px = pt × 1.2857`
- `py = 3214 − pt_y × 1.2856`

Upload the crop as a JPEG (quality 93) for create-image.

### 2. End frame: paint the finished building into the crop

Run Nano Banana with the map crop as image 1 and a design reference as image 2. The
design reference is an existing sprite of the building on beige, ideally already
facing the right way.

Prompt pattern (Harbor):

> Edit image 1, a section of a hand-painted map: *[describe what is in the crop:
> land, river, bank direction]*. Keep the whole picture identical: same framing,
> *[name the landmarks]*, ink lines and paper texture, nothing moved. Make ONE change:
> paint *[the building]* into the map on *[the exact place]*, as part of the painting
> itself. Use *[the building]* in image 2 as the design: *[parts and which way it
> faces]*. Paint it in image 1's own technique and light: fine loose brown-sepia ink,
> soft transparent watercolour washes, warm light from the upper left, the same scale
> as if it were part of the original painting. No other changes: no new buildings
> elsewhere, no people, no text.

For a road, describe the sketched band it should follow: "the wide pale band between
the long pencil lines". Also add: "copy only its paving pattern, not its shape, its
background or its viewing angle. The road lies flat on the ground."

**Pick the version that left the surroundings alone.** One of the two often reshapes
the bank or the landscape; drop that one.

Check the pick with `bake_preview.py CROP EDIT OUT`, then composite OUT back onto the
full map.

### 3. Start frame: edit the END image, not the crop

Run Nano Banana on the end frame you picked, so the surroundings match it exactly.

> Edit this hand-painted map. Keep everything identical: *[landmarks]*, nothing
> moved. Make ONE change: *[the building]* has NOT been built yet. Remove *[every
> part, by name]*; where it stood, the natural *[ground / bank / water]* continues.
> Along the exact strip where it was, place neat low piles of building materials
> waiting to be used: *[stone blocks, timber, rope / paving stones, kerb blocks,
> gravel]*, spread evenly along that strip. Paint the piles in the map's own
> technique… No other changes.

**Pick the version that really removed the building.** One of the two often keeps
part of it.

The road was the exception: its start frame was edited from the original crop, with
the end frame as a location reference. That also works when the building is flat.

### 4. Kling: start → end

Upload both frames as JPEGs for create-video.

Prompt pattern:

> Locked static camera, no camera movement, no zoom, no pan. A hand-painted
> watercolour map; only *[the area]* changes. Architectural time-lapse of *[the
> building]* building itself from the piles of materials: *[the build order, step by
> step]*, ending exactly on the finished *[building]* in the last frame. The piles
> shrink and are fully consumed. Everything else stays perfectly still: *[landmarks]*,
> paper texture and ink lines. No people, no new objects, no camera shake.

Extract the frames with `ffmpeg -i clip.mp4 frames/f%03d.png` (121 frames). Pick 13
indices for frames 01–13. Weight them toward the visible build and skip any
odd-looking frames. Frame 00 is the start image and frame 14 is the end image, both
exact.

### 5. Process

```
scripts/art/process_baked.py NAME CROP.png ORIGIN_X ORIGIN_Y START.png END.png FRAMES_DIR IDX OUT_DIR [TERRAIN.png]
```

The script does the following:
- aligns all frames to the crop;
- builds the alpha from wherever the start or end differs from the untouched crop, softened, with a 30 px untouched border so there's no seam;
- colour-matches the clip frames to the map;
- trims everything to one shared box;
- writes `NAME.png`, `NAMEBuildFrame00…14.png` and a preview (frames 00, 07, 14 on the real terrain).

It also prints:
- `ZoneRegistry position: CGPoint(...)`
- `BuildingNode spriteSizeMultiplier: …`

Check the preview: there should be no visible edge in any of the three frames.

### 6. Install

- Copy `NAME.png` into `NAME.imageset/` and the 15 frames into
  `NAMEBuild.spriteatlas/NAMEBuildFrameNN.imageset/`, keeping the existing filenames.
- In `ZoneRegistry.swift`, set the building's position to the printed one.
- In `BuildingNode.swift`, set `spriteSizeMultiplier` to the printed one. It works out
  as patch px ÷ 1.2857 ÷ 420, about 2.2 for a 1200 px patch. Without it the patch
  won't line up with the map.
- Archive the sources in `~/Desktop/AssetTrim/Building_<Name>/<date>_baked/`: crop,
  start, end, clip, outputs.

## Things to check after placing

- Other building plots, labels, waypoints and the player spawn inside the patch area.
  On Oct 14, Leonardo's Workshop and the Rome spawn sat on the new harbor.
- The pill label sits 56 pt below the patch centre. Long diagonal patches have their
  centre off the structure, so check the label lands somewhere sensible.
- The patch replaces the terrain under it in every state. If the terrain behind it is
  ever repainted, the building has to be baked again.
