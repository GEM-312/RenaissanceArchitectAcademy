#!/usr/bin/env python3
"""Blend a Nano Banana "painted into the map" edit back into the original map crop.

Only the area the edit actually changed is taken (a soft mask from the colour
difference); everything else stays the original pixels, and a 30 px border is kept
untouched so the patch has no seam. Used to show Marina candidates on the real map
before any animation is made. See docs/baked-buildings-recipe.md.

Usage:
  scripts/art/bake_preview.py CROP.png EDIT.png OUT.png
Writes OUT.png and OUT_mask.png.
"""
import sys
import numpy as np
from PIL import Image, ImageFilter

src_p, gen_p, out_p = sys.argv[1:4]
src = Image.open(src_p).convert('RGB'); W, H = src.size
gen = Image.open(gen_p).convert('RGB').resize((W, H), Image.LANCZOS)
a = np.asarray(src, np.float32); b = np.asarray(gen, np.float32)

# Best integer shift of the edit against the crop, ±12 px
ga, gb = a.mean(2), b.mean(2); best = None
for dy in range(-12, 13, 2):
    for dx in range(-12, 13, 2):
        e = np.abs(ga[40:-40, 40:-40] - np.roll(np.roll(gb, dy, 0), dx, 1)[40:-40, 40:-40]).mean()
        if best is None or e < best[0]:
            best = (e, dx, dy)
e, dx, dy = best; print('shift', dx, dy, 'mean abs diff', round(e, 2))
b = np.roll(np.roll(b, dy, 0), dx, 1)

d = np.abs(a - b).mean(2)
m = Image.fromarray(np.clip(d * 4, 0, 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(14))
m = m.point(lambda v: 255 if v > 60 else 0).filter(ImageFilter.MaxFilter(31)).filter(ImageFilter.GaussianBlur(20))
mm = np.asarray(m, np.float32) / 255
r = 30; edge = np.ones((H, W), np.float32); ramp = np.linspace(0, 1, r)
edge[:r] *= ramp[:, None]; edge[-r:] *= ramp[::-1][:, None]; edge[:, :r] *= ramp[None]; edge[:, -r:] *= ramp[None, ::-1]
mm *= edge
o = a * (1 - mm[..., None]) + b * mm[..., None]
Image.fromarray(o.clip(0, 255).astype(np.uint8)).save(out_p)
Image.fromarray((mm * 255).astype(np.uint8)).save(out_p.replace('.png', '_mask.png'))
print('mask coverage', round(float(mm.mean()) * 100, 1), '%')
