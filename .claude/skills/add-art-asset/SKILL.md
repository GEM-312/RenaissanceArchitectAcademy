---
name: add-art-asset
description: Resize and add a still image (science/nav icon, city or station sprite, terrain, UI art) into Assets.xcassets. OpenArt/Midjourney exports are huge and MUST be resized first. Use when Marina says "add this icon", "add art for X", "put this image in the assets", "/add-art-asset", or drops a PNG that needs wiring into the app. For animated GIFs / video → sprite frames, use /extract-frames instead.
user-invocable: true
---

# add-art-asset

Add a still image to `Assets.xcassets` the right way. Art is generated in OpenArt (mixed models incl. Midjourney) and exports are **huge** (often 2000px+). Always resize before adding — an unresized asset bloats the app and slows the build.

> **Animated frames?** This skill is for single still images. For GIF/video → sprite-frame sequences (avatars, volcano, apprentice), use **`/extract-frames`** — it handles extraction + background removal + trim.
>
> **Asset catalog vs pbxproj:** images inside `Assets.xcassets` do **not** need pbxproj entries — the catalog is already a folder reference in the build. That's `add-swift-file`'s job, and it does not apply here.

## Step 1 — Resize first (mandatory)

Pick the target size by asset role and resize in place with `sips`:

```bash
sips -Z 180 f.png   # science icons  (Science*)
sips -Z 120 f.png   # nav icons      (Nav*)
sips -Z 512 f.png   # city / station / interior sprites, terrain accents
```

`-Z` caps the **longest** side and preserves aspect ratio. If the role isn't listed, ask Marina for the target — don't guess. Verify it shrank:

```bash
sips -g pixelWidth -g pixelHeight f.png   # confirm new dimensions
```

## Step 2 — Create the imageset

Add the resized PNG to `RenaissanceArchitectAcademy/Assets.xcassets/<Name>.imageset/` with a `Contents.json`. Match the naming already in the catalog (`Science*`, `Nav*`, `Station*`, `Interior*`, `City*`, etc.). Copy an existing sibling imageset's `Contents.json` and swap the filename rather than authoring it from scratch — that guarantees the schema matches.

## Working-folder convention (for multi-frame raw art, if not using /extract-frames)

Raw frames live outside the catalog, gitignored, and get promoted through stages:

```
Styles/[name]_frames/          # raw extracts (gitignored)
Styles/[name]_frames/selected  # 15 evenly-spaced picks
Styles/[name]_frames/clean     # background removed (Marina, Photoshop)
```

Only the final `clean` frames become `Assets.xcassets/[Name]Frame00-14.imageset/`.

## Verify

The asset catalog is picked up automatically — a build is the check that the image resolves and nothing is oversized:

```bash
cd /Users/pollakmarina/RenaissanceArchitectAcademy
xcodebuild -scheme RenaissanceArchitectAcademy -destination 'platform=macOS' build > /tmp/raa_build.log 2>&1; echo "EXIT=$?"; grep -E "BUILD SUCCEEDED|BUILD FAILED|error:" /tmp/raa_build.log | head
```

Then confirm the image renders where it's used (ask Marina to eyeball it, or drive the flow via `/run-raa`).
