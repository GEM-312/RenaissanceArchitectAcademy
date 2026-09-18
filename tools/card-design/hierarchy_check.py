#!/usr/bin/env python3
"""
hierarchy_check.py — text hierarchy for a card: map each text run to a
level (H1/H2/H3/body/caption), then check:
  - exactly one H1 per "card unit"
  - no level skipped against the file's own heading-size ladder
  - each level strictly larger than the one below (within a unit)
  - consistent level usage across card units (same role, same size/family)

Levels are assigned from the font actually resolved at each Text(...)
call site (RenaissanceFont token OR raw literal — see typography_audit.py;
this tool does not care which, it only cares about the resolved family and
point size), NOT from a fixed table of RenaissanceFont names. That is a
deliberate choice: real card Text mostly uses raw `.font(.custom(...))`
literals rather than named tokens (see typography_audit.py output), so a
name-based table would silently miss most of the hierarchy.

RAA convention (confirmed in RenaissanceTheme.swift + every card file):
Cinzel is the titles/headers typeface, EBGaramond is body/caption. So:
  - "heading-like" runs = Cinzel family
  - "body-like" runs    = EBGaramond family
  - anything else (PetitFormalScript, Delius, system/SF Symbols) = other,
    reported but excluded from the H1/H2/H3 ladder.

A "card unit" is a `private func cardXxx(...)` / `private var cardXxx: some
View` block (front/back/chrome functions are exactly how these three files
are structured); if none are found, the whole file is treated as one unit.

Usage:
    python3 hierarchy_check.py <file.swift> [file2.swift ...] [--json]

Passing multiple files lets the cross-file "consistent usage" check compare
the same role (e.g. "card title") across DiscoveryCardOverlay.swift and
KnowledgeCardsOverlay.swift.
"""
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
import raa_common as c

UNIT_RE = re.compile(
    r"(?:private\s+)?func\s+(\w*[Cc]ard\w*)\s*\([^)]*\)\s*(?:->\s*[\w\s]+)?\{"
    r"|(?:private\s+)?var\s+(\w*[Cc]ard\w*)\s*:\s*some\s+View\s*\{"
)


def find_card_units(text: str) -> list[tuple[str, str, int]]:
    """[(unit_name, body, base_line), ...]. Falls back to the whole file as
    a single unit named after the struct if no cardXxx func/var is found."""
    events = c.scan_brackets(text)
    units = []
    for m in UNIT_RE.finditer(text):
        name = m.group(1) or m.group(2)
        open_idx = m.end() - 1
        close = c.matching_close(events, open_idx)
        if close is None:
            continue
        body = text[open_idx + 1: close.index]
        units.append((name, body, c.line_of(text, open_idx + 1)))
    if not units:
        struct_m = re.search(r"struct\s+(\w+)\s*:\s*View", text)
        name = struct_m.group(1) if struct_m else "(whole file)"
        units.append((name, text, 1))
    return units


def classify_family(family: str | None) -> str:
    if family is None:
        return "unresolved"
    if family.startswith("Cinzel"):
        return "heading"
    if family.startswith("EBGaramond"):
        return "body"
    if family == "system":
        return "icon/system"
    return "other"


def analyze_unit(name: str, body: str, base_line: int, tokens: dict, global_ladder: list[float]) -> dict:
    usages = c.find_font_usages(body, tokens)
    runs = []
    for u in usages:
        if u.size is None:
            continue
        # u.line is 1-indexed relative to `body`; convert to file-absolute.
        runs.append({
            "line": base_line + u.line - 1,
            "family": u.family, "size": u.size, "text": u.nearby_text,
            "class": classify_family(u.family),
        })

    headings = [r for r in runs if r["class"] == "heading"]
    body_runs = [r for r in runs if r["class"] == "body"]

    heading_sizes = sorted({r["size"] for r in headings}, reverse=True)
    level_of_size = {size: f"H{i+1}" for i, size in enumerate(heading_sizes)}
    for r in headings:
        r["level"] = level_of_size[r["size"]]

    h1_size = heading_sizes[0] if heading_sizes else None
    h1_runs = [r for r in headings if r["size"] == h1_size] if h1_size else []
    distinct_h1_texts = {r["text"] for r in h1_runs if r["text"]}

    skipped_rungs = []
    if len(heading_sizes) >= 2:
        for i in range(len(heading_sizes) - 1):
            hi, lo = heading_sizes[i], heading_sizes[i + 1]
            between = [g for g in global_ladder if lo < g < hi]
            if between:
                skipped_rungs.append({
                    "between": [f"H{i+1}", f"H{i+2}"],
                    "sizes": [hi, lo],
                    "skipped_global_sizes": between,
                })

    body_max = max((r["size"] for r in body_runs), default=None)
    heading_smaller_than_body = [
        r for r in headings if body_max is not None and r["size"] < body_max
    ]

    return {
        "unit": name,
        "base_line": base_line,
        "runs": runs,
        "headings": headings,
        "heading_sizes": heading_sizes,
        "h1_size": h1_size,
        "h1_run_count": len(h1_runs),
        "distinct_h1_texts": sorted(distinct_h1_texts),
        "skipped_rungs": skipped_rungs,
        "heading_smaller_than_body": heading_smaller_than_body,
        "body_max": body_max,
    }


def build_global_ladder(tokens: dict) -> list[float]:
    sizes = {t.size for t in tokens.values() if t.family.startswith("Cinzel") and t.size is not None}
    return sorted(sizes, reverse=True)


def render_text(all_units: list[dict], cross_file: dict, files: list[str]) -> None:
    print(f"━━━ HIERARCHY CHECK — {', '.join(files)} ━━━\n")

    for u in all_units:
        print(f"[{u['unit']}]  (L{u['base_line']}, from {u['file']})")
        if not u["headings"]:
            print("  No Cinzel (heading-family) text found in this unit.")
        else:
            print(f"  Heading sizes found (largest→smallest): "
                  f"{', '.join(c.fmt_num(s) for s in u['heading_sizes'])}")
            for r in u["headings"]:
                print(f"    {r['level']} L{r['line']}: {r['family']} @ {c.fmt_num(r['size'])}pt"
                      + (f'  text≈"{r["text"]}"' if r["text"] else ""))

            if u["h1_run_count"] == 0:
                print("  🔴 No H1 (largest heading) text found.")
            elif len(u["distinct_h1_texts"]) > 1:
                print(f"  ⚠ {u['h1_run_count']} H1-sized runs with {len(u['distinct_h1_texts'])} different"
                      f" strings — check these are meant to be separate H1s: {u['distinct_h1_texts']}")
            else:
                print(f"  ✓ exactly one distinct H1 text ({u['h1_run_count']} run(s))")

            if u["skipped_rungs"]:
                for s in u["skipped_rungs"]:
                    print(f"  ⚠ {s['between'][0]}→{s['between'][1]} ({c.fmt_num(s['sizes'][0])}pt→"
                          f"{c.fmt_num(s['sizes'][1])}pt) skips file-wide heading size(s) "
                          f"{', '.join(c.fmt_num(x) for x in s['skipped_global_sizes'])}pt")
            else:
                print("  ✓ no rungs skipped against the file-wide Cinzel size ladder")

        if u["heading_smaller_than_body"]:
            for r in u["heading_smaller_than_body"]:
                print(f"  🔴 heading at L{r['line']} ({c.fmt_num(r['size'])}pt) is SMALLER than the largest "
                      f"body text in this unit ({c.fmt_num(u['body_max'])}pt) — hierarchy inversion")
        print()

    print("--- Cross-unit consistency (same role, different card) ---")
    if not cross_file["inconsistent_roles"]:
        print("No clearly-named repeated roles (e.g. 'cardFront'/'cardBack' appearing in more than")
        print("one analyzed unit) were found to compare, or all matching roles agree.")
    else:
        for role, variants in cross_file["inconsistent_roles"].items():
            print(f"  Role-ish name \"{role}\" — H1 size differs across units:")
            for v in variants:
                print(f"    {v['unit']} ({v['file']}): H1 = {c.fmt_num(v['h1_size'])}pt")


def cross_unit_consistency(all_units: list[dict]) -> dict:
    """Group units whose name (lowercased, stripped of the building/card
    noun) looks like the same role across files, e.g. any unit containing
    'front' vs 'back' vs 'chrome', and flag if their H1 sizes disagree."""
    role_groups: dict[str, list[dict]] = {}
    for u in all_units:
        lname = u["unit"].lower()
        for role in ("front", "back", "chrome", "flipped"):
            if role in lname:
                role_groups.setdefault(role, []).append(u)
    inconsistent = {}
    for role, group in role_groups.items():
        sizes = {g["h1_size"] for g in group if g["h1_size"] is not None}
        if len(sizes) > 1:
            inconsistent[role] = [{"unit": g["unit"], "file": g["file"], "h1_size": g["h1_size"]} for g in group]
    return {"inconsistent_roles": inconsistent}


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("files", nargs="+")
    ap.add_argument("--json", action="store_true")
    args = ap.parse_args()

    tokens = c.parse_font_tokens()
    global_ladder = build_global_ladder(tokens)

    all_units = []
    for f in args.files:
        text = c.read_file(f)
        for name, body, base_line in find_card_units(text):
            result = analyze_unit(name, body, base_line, tokens, global_ladder)
            result["file"] = f
            all_units.append(result)

    cross_file = cross_unit_consistency(all_units)

    if args.json:
        print(c.json.dumps({"units": all_units, "cross_file": cross_file, "global_heading_ladder": global_ladder},
                            indent=2, default=str))
    else:
        render_text(all_units, cross_file, args.files)


if __name__ == "__main__":
    main()
