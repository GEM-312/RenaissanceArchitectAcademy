#!/usr/bin/env python3
"""Turn tree/prop cut-outs into imagesets + paste-ready ZoneTreePlacement lines.

Each cut-out PNG is a piece lifted out of one zone terrain. This finds where it sat,
trims it, and prints the scene position CityScene needs (trunk base, anchor (0.5, 0)).

Two kinds of input, detected per file:
  * FULL CANVAS (same size as the terrain — what ExportCutouts.jsx writes): the position
    is read straight from the transparent margin. Exact.
  * TRIMMED (smaller than the terrain): located by alpha-masked template matching against
    the terrain. Only works if the terrain still has the tree painted in — match against
    the ORIGINAL art, not the holes-filled version.

--split: a full-canvas PNG holding SEVERAL trees (all cut onto one layer) is split into
one cut-out per tree. Pieces closer than SPLIT_GAP px count as one tree (a trunk drawn a
little apart from its crown stays attached); specks under SPLIT_MIN_AREA px are dropped.

Scene coordinates: SpriteKit y points up, origin bottom-left; terrain pixel width maps to
the zone's 3500pt map width, so scale = map_width / terrain_px_width (Rome: 3500/4500).

Usage:
  scripts/art/place_cutouts.py CUTOUT_DIR --terrain TERRAIN.png --prefix PaduaTree --start 1
  ... add --install to write imagesets into Assets.xcassets (default: preview only)

Dry run prints the Swift and a summary; nothing is written without --install or --out.
"""
import argparse
import json
import pathlib
import sys

import numpy as np
from PIL import Image
from scipy import ndimage
from scipy.signal import fftconvolve

REPO = pathlib.Path(__file__).resolve().parents[2]
ASSETS = REPO / "RenaissanceArchitectAcademy" / "Assets.xcassets"
ALPHA_FLOOR = 8  # alpha below this counts as empty when trimming / masking
SPLIT_GAP = 12  # px — pieces this close belong to the same tree
SPLIT_MIN_AREA = 150  # px — smaller islands are stray specks, not trees

IMAGESET_CONTENTS = {
    "images": [
        {"filename": None, "idiom": "universal", "scale": "1x"},
        {"idiom": "universal", "scale": "2x"},
        {"idiom": "universal", "scale": "3x"},
    ],
    "info": {"author": "xcode", "version": 1},
}


def alpha_bbox(rgba):
    """(left, top, right, bottom) of non-empty pixels, right/bottom exclusive."""
    ys, xs = np.nonzero(rgba[:, :, 3] >= ALPHA_FLOOR)
    if len(xs) == 0:
        return None
    return xs.min(), ys.min(), xs.max() + 1, ys.max() + 1


def split_trees(cut):
    """Full-canvas RGBA -> one full-canvas RGBA per tree, ordered left to right."""
    solid = cut[:, :, 3] >= ALPHA_FLOOR
    # Grow by half the gap so pieces closer than SPLIT_GAP touch and get one label
    grown = ndimage.binary_dilation(solid, iterations=SPLIT_GAP // 2)
    labels, count = ndimage.label(grown)
    labels[~solid] = 0  # the grown margin is only for grouping; keep the real pixels
    pieces = []
    for i, box in enumerate(ndimage.find_objects(labels), start=1):
        if box is None:
            continue
        member = labels == i
        if member.sum() < SPLIT_MIN_AREA:
            continue
        piece = np.zeros_like(cut)
        piece[member] = cut[member]
        pieces.append((box[1].start, piece))
    return [p for _, p in sorted(pieces, key=lambda item: item[0])]


def locate_by_matching(cutout, terrain_rgb):
    """Top-left pixel in the terrain where the trimmed cut-out fits best, plus mean error.

    Masked SSD: sum over the cut-out's opaque pixels of (T - I)^2, expanded into three
    correlations so it runs as FFTs instead of a 4500x3214 sliding loop.
    """
    mask = (cutout[:, :, 3] >= 128).astype(np.float64)
    template = cutout[:, :, :3].astype(np.float64)
    image = terrain_rgb.astype(np.float64)
    m = mask[::-1, ::-1]
    score = np.zeros((image.shape[0] - mask.shape[0] + 1, image.shape[1] - mask.shape[1] + 1))
    for c in range(3):
        t = template[:, :, c] * mask
        i = image[:, :, c]
        sum_i2 = fftconvolve(i * i, m, mode="valid")
        sum_ti = fftconvolve(i, t[::-1, ::-1], mode="valid")
        score += sum_i2 - 2 * sum_ti + (t * t).sum()
    y, x = np.unravel_index(np.argmin(score), score.shape)
    rms = np.sqrt(max(score[y, x], 0) / (mask.sum() * 3))
    return int(x), int(y), rms


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("cutout_dir", type=pathlib.Path)
    ap.add_argument("--terrain", type=pathlib.Path, required=True, help="the zone's terrain PNG (original art if cut-outs are trimmed)")
    ap.add_argument("--prefix", required=True, help="imageset name prefix, e.g. PaduaTree")
    ap.add_argument("--start", type=int, default=1, help="first number, e.g. 1 -> PaduaTree01")
    ap.add_argument("--map-width", type=float, default=3500, help="zone mapSize.width in points")
    ap.add_argument("--scale-name", default="treeScale", help="Swift constant printed in the scale: argument")
    ap.add_argument("--out", type=pathlib.Path, help="write imagesets here instead of the asset catalog")
    ap.add_argument("--install", action="store_true", help="write imagesets into Assets.xcassets")
    ap.add_argument("--split", action="store_true", help="split full-canvas PNGs holding several trees into one cut-out per tree")
    args = ap.parse_args()

    terrain = np.asarray(Image.open(args.terrain).convert("RGBA"))
    th, tw = terrain.shape[:2]
    scale = args.map_width / tw
    files = sorted(p for p in args.cutout_dir.iterdir() if p.suffix.lower() == ".png" and not p.name.startswith("."))
    if not files:
        sys.exit(f"No PNGs in {args.cutout_dir}")

    # (label for the report, RGBA array) — one entry per tree
    cutouts = []
    for path in files:
        cut = np.asarray(Image.open(path).convert("RGBA"))
        if args.split and cut.shape[:2] == (th, tw):
            pieces = split_trees(cut)
            print(f"{path.name}: split into {len(pieces)} trees")
            cutouts += [(f"{path.stem} #{i + 1}", piece) for i, piece in enumerate(pieces)]
        else:
            cutouts.append((path.stem, cut))

    dest = ASSETS if args.install else args.out
    if dest is not None:
        dest.mkdir(parents=True, exist_ok=True)
        clashes = [f"{args.prefix}{args.start + i:02d}" for i in range(len(cutouts))
                   if (dest / f"{args.prefix}{args.start + i:02d}.imageset").exists()]
        if clashes:
            sys.exit(f"Refusing to overwrite existing imagesets: {', '.join(clashes)}")

    print(f"Terrain {tw}x{th}px -> {args.map_width:.0f}pt wide, scale {scale:.4f}\n")
    lines = []
    for n, (label, cut) in enumerate(cutouts):
        name = f"{args.prefix}{args.start + n:02d}"
        box = alpha_bbox(cut)
        if box is None:
            print(f"  SKIP {label}: fully transparent")
            continue
        left, top, right, bottom = box
        trimmed = cut[top:bottom, left:right]

        if cut.shape[:2] == (th, tw):
            how = "full canvas"
        elif cut.shape[0] <= th and cut.shape[1] <= tw:
            mx, my, rms = locate_by_matching(trimmed, terrain[:, :, :3])
            left, top, right, bottom = mx, my, mx + trimmed.shape[1], my + trimmed.shape[0]
            how = f"matched, rms {rms:.1f}/255" + ("  <-- POOR MATCH, check terrain" if rms > 12 else "")
        else:
            print(f"  SKIP {label}: {cut.shape[1]}x{cut.shape[0]} is bigger than the terrain")
            continue

        # Trunk base = bottom-centre of the trimmed sprite; flip y for SpriteKit
        x_pt = (left + right) / 2 * scale
        y_pt = (th - bottom) * scale
        lines.append(f'ZoneTreePlacement(imageName: "{name}", position: CGPoint(x: {x_pt:4.0f}, y: {y_pt:4.0f}), scale: {args.scale_name}),   // {label}')
        print(f"  {name:<14} <- {label:<40} {right - left}x{bottom - top}px  {how}")

        if dest is not None:
            imageset = dest / f"{name}.imageset"
            imageset.mkdir()
            Image.fromarray(trimmed).save(imageset / f"{name}.png", optimize=True)
            contents = json.loads(json.dumps(IMAGESET_CONTENTS))
            contents["images"][0]["filename"] = f"{name}.png"
            (imageset / "Contents.json").write_text(json.dumps(contents, indent=2) + "\n")

    print("\n// Paste into the zone's `trees:` array in Models/ZoneRegistry.swift")
    print(f"// (needs `private static let {args.scale_name}: CGFloat = {args.map_width:.0f} / {tw}`)")
    for line in lines:
        print(line)
    if dest is None:
        print("\nPreview only — rerun with --install (or --out DIR) to write imagesets.")
    else:
        print(f"\nWrote {len(lines)} imagesets to {dest}")


if __name__ == "__main__":
    main()
