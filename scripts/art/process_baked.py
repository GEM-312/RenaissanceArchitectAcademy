#!/usr/bin/env python3
"""Turn a building painted into the map (start image, end image, Kling frames) into
game assets that sit pixel-exact on the zone terrain. See docs/baked-buildings-recipe.md.

Usage:
  scripts/art/process_baked.py NAME CROP.png ORIGIN_X ORIGIN_Y START.png END.png FRAMES_DIR IDX OUT_DIR [TERRAIN.png]

  NAME       asset name: writes NAME.png and NAMEBuildFrame00..14.png
  CROP.png   the untouched terrain crop the edits were made from
  ORIGIN_*   the crop's top-left corner in terrain pixels
  START/END  Nano Banana start (piles of materials) and end (finished) images
  FRAMES_DIR the Kling clip extracted to PNGs (ffmpeg -i clip.mp4 dir/f%03d.png)
  IDX        13 comma-separated 0-based clip frame indices for frames 01..13
             (00 is START, 14 is END, both exact)
  TERRAIN    defaults to the Ancient Rome terrain

Prints the ZoneBuildingPlacement position and the BuildingNode spriteSizeMultiplier.
"""
import glob
import os
import sys
import numpy as np
from PIL import Image, ImageFilter

ROME = os.path.join(os.path.dirname(__file__), '../../RenaissanceArchitectAcademy/Assets.xcassets/Terrain.imageset/Terrain_buildings.png')
name, src_p, ox, oy, start_p, end_p, fdir, idx_s, out = sys.argv[1:10]
terrain_p = sys.argv[10] if len(sys.argv) > 10 else ROME
ox, oy = int(ox), int(oy)

TERRAIN = Image.open(terrain_p).convert('RGBA')
MAP_W, MAP_H = TERRAIN.size
SX, SY = MAP_W / 3500, MAP_H / 2500     # terrain px per scene point (scene is 3500×2500)
BOX = 420                                # BuildingNode's nominal sprite box

src = Image.open(src_p).convert('RGB'); W, H = src.size
A = np.asarray(src, np.float32)
def load(p): return np.asarray(Image.open(p).convert('RGB').resize((W, H), Image.LANCZOS), np.float32)
start, end = load(start_p), load(end_p)

def best_shift(ref, img, r=14):
    g1, g2 = ref.mean(2), img.mean(2); best = None
    for dy in range(-r, r + 1, 2):
        for dx in range(-r, r + 1, 2):
            e = np.abs(g1[40:-40, 40:-40] - np.roll(np.roll(g2, dy, 0), dx, 1)[40:-40, 40:-40]).mean()
            if best is None or e < best[0]:
                best = (e, dx, dy)
    return best
def shift(img, dx, dy): return np.roll(np.roll(img, dy, 0), dx, 1)

e, dx, dy = best_shift(A, end); end = shift(end, dx, dy); print('end shift', dx, dy, round(e, 1))
e, dx, dy = best_shift(end, start); start = shift(start, dx, dy); print('start shift', dx, dy, round(e, 1))

# Alpha: everywhere START or END differs from the untouched crop, softened, with a
# 30 px untouched border so the patch never shows a seam.
def diff_mask(b):
    d = np.abs(A - b).mean(2)
    m = Image.fromarray(np.clip(d * 4, 0, 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(14))
    return np.asarray(m.point(lambda v: 255 if v > 60 else 0), np.float32)
m = np.maximum(diff_mask(end), diff_mask(start)).astype(np.uint8)
m = Image.fromarray(m).filter(ImageFilter.MaxFilter(31)).filter(ImageFilter.GaussianBlur(20))
mask = np.asarray(m, np.float32) / 255
r = 30; edge = np.ones((H, W), np.float32); ramp = np.linspace(0, 1, r)
edge[:r] *= ramp[:, None]; edge[-r:] *= ramp[::-1][:, None]; edge[:, :r] *= ramp[None]; edge[:, -r:] *= ramp[None, ::-1]
mask *= edge

# Clip frames: align to END, then match colour to the map in the ring just outside the change
frames = sorted(glob.glob(os.path.join(fdir, '*.png')))
last = load(frames[-1]); e, vdx, vdy = best_shift(end, last); print('clip shift', vdx, vdy, round(e, 1))
ring = (mask > 0.02) & (mask < 0.5)
def colour_match(f): return f * (A[ring].mean(0) / np.maximum(f[ring].mean(0), 1))
idx = [int(i) for i in idx_s.split(',')]
seq = [start] + [colour_match(shift(load(frames[i]), vdx, vdy)) for i in idx] + [end]
assert len(seq) == 15, f'need 13 clip indices, got {len(idx)}'

ys, xs = np.where(mask > 0.01)
x0, x1, y0, y1 = xs.min(), xs.max() + 1, ys.min(), ys.max() + 1
alpha = Image.fromarray((mask[y0:y1, x0:x1] * 255).astype(np.uint8))
os.makedirs(out, exist_ok=True)
def rgba(f):
    im = Image.fromarray(np.clip(f[y0:y1, x0:x1], 0, 255).astype(np.uint8)).convert('RGBA'); im.putalpha(alpha); return im
for k, f in enumerate(seq):
    rgba(f).save(f'{out}/{name}BuildFrame{k:02d}.png')
rgba(end).save(f'{out}/{name}.png')

w, h = x1 - x0, y1 - y0
cx, cy = ox + x0 + w / 2, oy + y0 + h / 2
print(f'sprite {w}x{h}px')
print(f'ZoneRegistry position: CGPoint(x: {cx / SX:.0f}, y: {(MAP_H - cy) / SY:.0f})')
print(f'BuildingNode spriteSizeMultiplier: {max(w / SX, h / SY) / BOX:.4f}')

# Preview: frames 00, 07, 14 on the real terrain
tiles = []
for k in (0, 7, 14):
    t = TERRAIN.crop((ox - 150, oy - 150, ox + W + 150, oy + H + 150)).copy()
    t.alpha_composite(Image.open(f'{out}/{name}BuildFrame{k:02d}.png'), (150 + x0, 150 + y0))
    t = t.convert('RGB'); t.thumbnail((600, 600)); tiles.append(t)
pv = Image.new('RGB', (sum(t.width for t in tiles) + 20, tiles[0].height), (255, 255, 255)); x = 0
for t in tiles:
    pv.paste(t, (x, 0)); x += t.width + 10
pv.save(f'{out}/preview_00_07_14.jpg', quality=88)
