#!/usr/bin/env python3
"""
line_spacing.py — every `.lineSpacing()` value in a file, the resulting line
height for the font size it applies to, and whether that lands in a
readable band for children.

SwiftUI's `.lineSpacing(N)` ADDS N points between lines; it is not a
line-height multiplier. Resulting line height is estimated as:

    lineHeight ≈ fontSize * NATURAL_LINE_HEIGHT_FACTOR + lineSpacing

`NATURAL_LINE_HEIGHT_FACTOR` (see raa_common.py) is a widely-used ~1.2x
approximation for a serif text face's own leading — it is NOT a measured
value for Cinzel/EBGaramond specifically. Getting the real number requires
either the font's exact line-height metrics or a render pass. This tool
says so on every line and treats the result as an estimate throughout.

Readable band (flagged if outside): ratio (lineHeight / fontSize) should be
roughly 1.2x-1.9x for young readers, per the tool's brief. Below ~1.2x lines
crowd together; above ~1.9x paragraphs start looking disconnected.

Usage:
    python3 line_spacing.py <file.swift> [--json]
"""
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
import raa_common as c

LINE_SPACING_RE = re.compile(r"\.lineSpacing\(\s*([^)]+)\s*\)")
MIN_RATIO = 1.2
MAX_RATIO = 1.9


def nearest_font_before(text: str, char_pos: int, tokens: dict) -> "c.FontUsage | None":
    """Search backward from char_pos for the nearest `.font(...)` call, but
    resolve it against the FULL text so line numbers stay correct."""
    search_from = 0
    best = None
    for m in c._FONT_CALL.finditer(text):
        if m.start() >= char_pos:
            break
        best = m
    if best is None:
        return None
    if char_pos - best.start() > 400:
        return None
    usage = c._resolve_font_usage(best.group(1).strip(), c.line_of(text, best.start()), tokens, text, best.start())
    return usage


def resolve_spacing_value(expr: str) -> tuple[float | None, str | None]:
    expr = expr.strip()
    m = re.match(r"^-?[\d.]+$", expr)
    if m:
        return float(expr), None
    return None, f"`{expr}` is not a plain literal — depends on runtime state"


def analyze(text: str) -> dict:
    tokens = c.parse_font_tokens()
    rows = []
    for m in LINE_SPACING_RE.finditer(text):
        line = c.line_of(text, m.start())
        spacing_expr = m.group(1)
        spacing_val, spacing_note = resolve_spacing_value(spacing_expr)

        font = nearest_font_before(text, m.start(), tokens)
        font_size = font.size if font else None
        font_desc = None
        if font:
            font_desc = f"{font.family or '?'}" + (f" [{font.token_name}]" if font.token_name else "")

        row = {
            "line": line,
            "spacing_raw": spacing_expr.strip(),
            "spacing_value": spacing_val,
            "spacing_note": spacing_note,
            "font_line": font.line if font else None,
            "font": font_desc,
            "font_size": font_size,
            "font_dynamic": font.dynamic if font else None,
        }

        if spacing_val is not None and font_size is not None:
            line_height = font_size * c.NATURAL_LINE_HEIGHT_FACTOR + spacing_val
            ratio = line_height / font_size
            row["estimated_line_height"] = round(line_height, 1)
            row["ratio"] = round(ratio, 2)
            row["flag"] = ratio < MIN_RATIO or ratio > MAX_RATIO
        else:
            row["estimated_line_height"] = None
            row["ratio"] = None
            row["flag"] = None
        rows.append(row)

    flagged = [r for r in rows if r["flag"]]
    return {"rows": rows, "flagged": flagged, "total": len(rows)}


def render_text(data: dict, file: str) -> None:
    print(f"━━━ LINE SPACING — {file} ━━━")
    print(f".lineSpacing() call sites: {data['total']}")
    print(f"(readable band target: {MIN_RATIO}x-{MAX_RATIO}x of point size; line height is an ESTIMATE — "
          f"see script docstring)")
    print("(the paired font is the NEAREST PRECEDING `.font()` call in source order — for text produced by a "
          "helper function, that may be a sibling element's font, not the actual one; verify by eye when in doubt)\n")

    for r in data["rows"]:
        font_str = r["font"] or "no preceding .font() found within 400 chars"
        size_str = f"{c.fmt_num(r['font_size'])}pt" if r["font_size"] is not None else "?"
        loc_str = f" (L{r['font_line']})" if r["font_line"] else ""
        print(f"  L{r['line']}: .lineSpacing({r['spacing_raw']})  |  nearest font: {font_str} @ {size_str}{loc_str}")
        if r["spacing_note"]:
            print(f"      spacing: {r['spacing_note']}")
        if r["estimated_line_height"] is not None:
            flag = "  ⚠ OUTSIDE READABLE BAND" if r["flag"] else ""
            print(f"      estimated line height ≈ {r['estimated_line_height']}pt "
                  f"(ratio {r['ratio']}x of {c.fmt_num(r['font_size'])}pt){flag}")
        else:
            print("      cannot estimate ratio (spacing or font size unresolved)")

    if data["flagged"]:
        print(f"\n⚠ {len(data['flagged'])} outside the {MIN_RATIO}x-{MAX_RATIO}x readable band:")
        for r in data["flagged"]:
            print(f"  L{r['line']}: ratio {r['ratio']}x")
    else:
        print("\nNo resolved line-spacing/font-size pairs fall outside the readable band.")


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
