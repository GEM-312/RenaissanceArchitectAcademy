#!/usr/bin/env python3
"""Draw a zone's data from Models/ZoneRegistry.swift on top of its terrain — no app build.

Shows building plots (red; hidden ones grey), the waypoint graph (blue, numbered),
building→waypoint links (dashed orange), tree cut-out footprints (green boxes), labels
and the player spawn (magenta), plus a short report of graph problems: buildings that
can't be reached from the spawn, edges pointing at missing waypoints, points off the map.

Usage:
  scripts/art/zone_overlay.py ancientRome
  scripts/art/zone_overlay.py padua --terrain ~/path/to/padua_4500.png --out /tmp/padua.png

The terrain defaults to the zone's `sharpTerrainImageName` imageset in Assets.xcassets.
"""
import argparse
import collections
import math
import pathlib
import re
import sys

from PIL import Image, ImageDraw, ImageFont

REPO = pathlib.Path(__file__).resolve().parents[2]
REGISTRY = REPO / "RenaissanceArchitectAcademy" / "Models" / "ZoneRegistry.swift"
ASSETS = REPO / "RenaissanceArchitectAcademy" / "Assets.xcassets"
PREVIEW_WIDTH = 2250  # half of a 4500px terrain — big enough to read the numbers

NUM = r"(-?[\d.]+)"
POINT = rf"CGPoint\(x:\s*{NUM},\s*y:\s*{NUM}\)"


def zone_source(zone_id):
    text = REGISTRY.read_text()
    text = re.sub(r"//[^\n]*", "", text)  # line comments can hold stale coordinates
    m = re.search(rf"static let {zone_id}\s*=\s*ZoneDefinition\((.*?)(?=\n\s*static let |\Z)", text, re.S)
    if not m:
        names = re.findall(r"static let (\w+)\s*=\s*ZoneDefinition\(", text)
        sys.exit(f"No zone '{zone_id}' in ZoneRegistry.swift. Zones: {', '.join(names)}")
    return m.group(1)


def block(src, label):
    """Text inside `label: [ ... ]`, bracket-matched."""
    start = re.search(rf"\b{label}:\s*\[", src)
    if not start:
        return ""
    depth, i = 1, start.end()
    while depth and i < len(src):
        depth += {"[": 1, "]": -1}.get(src[i], 0)
        i += 1
    return src[start.end():i - 1]


def parse_zone(zone_id):
    src = zone_source(zone_id)
    size = re.search(rf"mapSize:\s*CGSize\(width:\s*{NUM},\s*height:\s*{NUM}\)", src)
    terrain = re.search(r'sharpTerrainImageName:\s*"([^"]+)"', src)
    spawn = re.search(rf"playerSpawn:\s*{POINT}", src)
    return {
        "map": (float(size.group(1)), float(size.group(2))),
        "terrain": terrain.group(1) if terrain else None,
        "buildings": [(b, (float(x), float(y))) for b, x, y in re.findall(
            rf'ZoneBuildingPlacement\(buildingId:\s*"(\w+)".*?position:\s*{POINT}', src)],
        "hidden": set(re.findall(r'"(\w+)"', block(src, "hiddenBuildingIds"))),
        "waypoints": [(float(x), float(y)) for x, y in re.findall(POINT, block(src, "waypoints"))],
        "edges": [(int(a), int(b)) for a, b in re.findall(r"\[(\d+),\s*(\d+)\]", block(src, "waypointEdges"))],
        "links": {b: [int(n) for n in re.findall(r"\d+", ids)] for b, ids in re.findall(
            r'"(\w+)":\s*\[([\d,\s]*)\]', block(src, "buildingWaypoints"))},
        "trees": [(n, (float(x), float(y))) for n, x, y in re.findall(
            rf'ZoneTreePlacement\(imageName:\s*"(\w+)",\s*position:\s*{POINT}', src)],
        "labels": [(f"{num} {name}", (float(x), float(y))) for num, name, x, y in re.findall(
            rf'ZoneLabel\(numeral:\s*"([^"]+)",\s*name:\s*"([^"]+)",\s*position:\s*{POINT}', src)],
        "spawn": (float(spawn.group(1)), float(spawn.group(2))) if spawn else None,
    }


def imageset_png(name):
    folder = ASSETS / f"{name}.imageset"
    pngs = sorted(folder.glob("*.png")) if folder.exists() else []
    return pngs[0] if pngs else None


def report(zone):
    wps, problems = zone["waypoints"], []
    w, h = zone["map"]
    for i, (x, y) in enumerate(wps):
        if not (0 <= x <= w and 0 <= y <= h):
            problems.append(f"waypoint {i} {x:.0f},{y:.0f} is off the {w:.0f}x{h:.0f} map")
    graph = collections.defaultdict(set)
    for a, b in zone["edges"]:
        if a >= len(wps) or b >= len(wps):
            problems.append(f"edge [{a}, {b}] points past the last waypoint ({len(wps) - 1})")
            continue
        graph[a].add(b)
        graph[b].add(a)
    if zone["spawn"] and wps:
        sx, sy = zone["spawn"]
        start = min(range(len(wps)), key=lambda i: math.dist(wps[i], (sx, sy)))
        seen, todo = {start}, [start]
        while todo:
            for n in graph[todo.pop()] - seen:
                seen.add(n)
                todo.append(n)
        for b, _ in zone["buildings"]:
            if b in zone["hidden"]:
                continue
            ids = zone["links"].get(b, [])
            if not ids:
                problems.append(f"{b} has no buildingWaypoints entry")
            elif not seen.intersection(ids):
                problems.append(f"{b} can't be reached from the spawn (waypoints {ids})")
    return problems


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("zone", help="ZoneRegistry static name, e.g. ancientRome")
    ap.add_argument("--terrain", type=pathlib.Path, help="terrain PNG (default: the zone's imageset)")
    ap.add_argument("--out", type=pathlib.Path, help="output PNG (default: ./zone-overlay-<zone>.png)")
    args = ap.parse_args()

    zone = parse_zone(args.zone)
    terrain_path = args.terrain or (imageset_png(zone["terrain"]) if zone["terrain"] else None)
    if not terrain_path:
        sys.exit("No terrain found — pass --terrain")
    terrain = Image.open(terrain_path).convert("RGB")
    map_w, map_h = zone["map"]
    preview_h = round(PREVIEW_WIDTH * terrain.height / terrain.width)
    img = terrain.resize((PREVIEW_WIDTH, preview_h), Image.LANCZOS)
    k = PREVIEW_WIDTH / map_w  # points -> preview pixels

    def px(p):  # SpriteKit y-up points -> image y-down pixels
        return p[0] * k, preview_h - p[1] * k

    draw = ImageDraw.Draw(img, "RGBA")
    font = ImageFont.load_default(size=22)
    small = ImageFont.load_default(size=16)
    wps = zone["waypoints"]

    for a, b in zone["edges"]:
        if a < len(wps) and b < len(wps):
            draw.line([px(wps[a]), px(wps[b])], fill=(40, 90, 220, 200), width=4)
    for b, pos in zone["buildings"]:
        for n in zone["links"].get(b, []):
            if n < len(wps):
                x0, y0 = px(pos)
                x1, y1 = px(wps[n])
                steps = max(1, int(math.dist((x0, y0), (x1, y1)) // 12))
                for s in range(0, steps, 2):
                    t0, t1 = s / steps, min(1, (s + 1) / steps)
                    draw.line([(x0 + (x1 - x0) * t0, y0 + (y1 - y0) * t0),
                               (x0 + (x1 - x0) * t1, y0 + (y1 - y0) * t1)], fill=(240, 140, 20, 230), width=3)
    for i, p in enumerate(wps):
        x, y = px(p)
        draw.ellipse([x - 9, y - 9, x + 9, y + 9], fill=(40, 90, 220, 255), outline="white", width=2)
        draw.text((x + 11, y - 11), str(i), fill="white", font=small, stroke_width=3, stroke_fill=(20, 40, 120))

    tree_scale = map_w / terrain.width  # cut-outs are terrain pixels, shrunk to the map
    for name, pos in zone["trees"]:
        png = imageset_png(name)
        x, y = px(pos)
        if png:
            tw, th = Image.open(png).size
            w, h = tw * tree_scale * k, th * tree_scale * k
            draw.rectangle([x - w / 2, y - h, x + w / 2, y], outline=(30, 160, 60, 255), width=3)
        draw.ellipse([x - 5, y - 5, x + 5, y + 5], fill=(30, 160, 60, 255))
        draw.text((x + 7, y + 2), name, fill="white", font=small, stroke_width=3, stroke_fill=(20, 90, 30))

    for b, pos in zone["buildings"]:
        x, y = px(pos)
        hidden = b in zone["hidden"]
        color = (120, 120, 120, 220) if hidden else (210, 40, 40, 255)
        draw.ellipse([x - 14, y - 14, x + 14, y + 14], fill=color, outline="white", width=3)
        draw.text((x + 17, y - 14), b + (" (hidden)" if hidden else ""), fill="white", font=font, stroke_width=3, stroke_fill=color[:3])

    for text, pos in zone["labels"]:
        x, y = px(pos)
        draw.text((x, y), text, fill=(255, 255, 255), font=font, anchor="mm", stroke_width=3, stroke_fill=(90, 60, 30))
    if zone["spawn"]:
        x, y = px(zone["spawn"])
        draw.regular_polygon((x, y, 18), 5, fill=(220, 40, 200, 255), outline="white")
        draw.text((x + 20, y - 12), "spawn", fill="white", font=font, stroke_width=3, stroke_fill=(120, 20, 110))

    out = args.out or pathlib.Path(f"zone-overlay-{args.zone}.png")
    img.save(out)
    print(f"{args.zone}: {len(zone['buildings'])} buildings ({len(zone['hidden'])} hidden), "
          f"{len(wps)} waypoints, {len(zone['edges'])} edges, {len(zone['trees'])} trees")
    print(f"terrain {terrain_path.name} {terrain.width}x{terrain.height} -> {out}")
    problems = report(zone)
    print("\n".join(["\nProblems:"] + [f"  - {p}" for p in problems]) if problems else "\nNo graph problems found.")


if __name__ == "__main__":
    main()
