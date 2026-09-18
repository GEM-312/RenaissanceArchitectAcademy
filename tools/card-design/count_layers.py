#!/usr/bin/env python3
"""
count_layers.py — layer count and z-order for a card view.

Reports, for every ZStack found in the file: its nesting depth, its direct
children in source (= paint) order — SwiftUI stacks ZStack children back-to-
front in the order they're written, so line order IS z-order — plus every
`.overlay(...)` / `.background(...)` attached nearby, which are themselves
implicit compositing layers on top of / behind whatever they're chained to.

Static analysis only. `if`/`else` branches inside a ZStack are usually
mutually exclusive (only one paints at a time) — this tool labels each
child with the `if`/`else if` condition text guarding it, if any, so you can
judge for yourself which children can be on-screen simultaneously. It does
NOT attempt to prove mutual exclusivity.

Usage:
    python3 count_layers.py <file.swift> [--json]
"""
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
import raa_common as c

OVERLAY_RE = re.compile(r"\.(overlay|background)\(")
GUARD_RE = re.compile(r"^(if|else if|else)\b\s*(.*?)\s*\{?\s*$")


def guard_condition(statement: str) -> str | None:
    first_line = next((ln.strip() for ln in statement.splitlines() if ln.strip()), "")
    m = GUARD_RE.match(first_line)
    if not m:
        return None
    kind, cond = m.groups()
    return f"{kind} {cond}".strip()


def summarize_child(statement: str) -> str:
    for ln in statement.splitlines():
        s = ln.strip()
        if s and not s.startswith("//"):
            return s[:90]
    return statement.strip()[:90]


def count_overlay_style_layers(text: str) -> list[dict]:
    results = []
    for m in OVERLAY_RE.finditer(text):
        line = c.line_of(text, m.start())
        results.append({"line": line, "kind": m.group(1)})
    return results


def analyze(text: str) -> dict:
    events = c.scan_brackets(text)
    zstacks = c.find_blocks(text, r"ZStack", events)

    # nesting depth of each ZStack relative to other ZStacks
    zstack_tree = []
    for b in zstacks:
        depth = sum(
            1 for other in zstacks
            if other is not b and other.open_index < b.open_index and other.close_index > b.close_index
        )
        stmts = c.top_level_statements(b.body, b.start_line, c.scan_brackets(b.body))
        children = []
        z = 0
        for stmt_text, line_no in stmts:
            summary = summarize_child(stmt_text)
            if not summary or summary.startswith("//"):
                continue
            guard = guard_condition(stmt_text)
            entry = {
                "z_order": z,
                "line": line_no,
                "summary": summary,
                "guard": guard,
            }
            children.append(entry)
            z += 1
        zstack_tree.append({
            "start_line": b.start_line,
            "end_line": b.end_line,
            "nesting_depth": depth,
            "child_count": len(children),
            "children": children,
        })

    return {
        "zstack_count": len(zstacks),
        "max_nesting_depth": max((z["nesting_depth"] for z in zstack_tree), default=0),
        "zstacks": sorted(zstack_tree, key=lambda z: z["start_line"]),
        "overlay_background_layers": count_overlay_style_layers(text),
    }


def render_text(data: dict, file: str) -> None:
    print(f"━━━ LAYER COUNT — {file} ━━━")
    print(f"ZStack blocks: {data['zstack_count']}  |  max nesting depth: {data['max_nesting_depth']}"
          f"  |  .overlay()/.background() call sites: {len(data['overlay_background_layers'])}\n")

    for z in data["zstacks"]:
        indent = "  " * z["nesting_depth"]
        print(f"{indent}ZStack L{z['start_line']}-{z['end_line']}  "
              f"(nesting depth {z['nesting_depth']}, {z['child_count']} direct children)")
        for ch in z["children"]:
            guard_str = f"  [guarded by: {ch['guard']}]" if ch["guard"] else ""
            print(f"{indent}  z{ch['z_order']} (back→front) L{ch['line']}: {ch['summary']}{guard_str}")
        if not z["children"]:
            print(f"{indent}  (no directly-summarizable children found)")
        print()

    if data["overlay_background_layers"]:
        print("`.overlay()` / `.background()` call sites (each adds one implicit compositing layer):")
        for ov in data["overlay_background_layers"]:
            print(f"  L{ov['line']}: .{ov['kind']}(...)")

    unguarded_multi = [
        z for z in data["zstacks"]
        if sum(1 for ch in z["children"] if ch["guard"] is None) > 1
    ]
    if unguarded_multi:
        print("\n⚠ ZStacks with more than one UNGUARDED child (no if/else) — these paint")
        print("  simultaneously by definition and are the ones worth checking for overlap:")
        for z in unguarded_multi:
            unguarded = [ch for ch in z["children"] if ch["guard"] is None]
            print(f"  L{z['start_line']}-{z['end_line']}: {len(unguarded)} unguarded children"
                  f" (lines {', '.join(str(ch['line']) for ch in unguarded)})")


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("file")
    ap.add_argument("--json", action="store_true")
    args = ap.parse_args()

    text = c.read_file(args.file)
    data = analyze(text)

    if args.json:
        print(c.json.dumps(data, indent=2, default=str))
    else:
        render_text(data, args.file)


if __name__ == "__main__":
    main()
