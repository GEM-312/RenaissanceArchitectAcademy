#!/usr/bin/env python3
"""
typography_audit.py — every text style used in a file: resolved point size,
family, weight, and whether it comes from a `RenaissanceFont` token or is a
raw `.font(.system(...))` / `Font.custom(...)` / `.custom(...)` literal.

Every literal usage is flagged as a violation, per RAA's design-token
convention (`RenaissanceFont.*` is the single source of truth for type —
see CLAUDE.md). This mirrors what a `RenaissanceFont.*` token audit would
flag; it does not judge whether the *chosen* size/family is good design.

Usage:
    python3 typography_audit.py <file.swift> [--json]
"""
from __future__ import annotations

import argparse
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
import raa_common as c


def analyze(text: str) -> dict:
    tokens = c.parse_font_tokens()
    usages = c.find_font_usages(text, tokens)

    rows = []
    violations = []
    for u in usages:
        is_violation = u.source in ("literal-custom", "literal-system")
        row = {
            "line": u.line,
            "text": u.nearby_text,
            "source": u.source,
            "family": u.family,
            "size": u.size,
            "size_expr": u.size_expr,
            "dynamic": u.dynamic,
            "weight": u.weight,
            "token": u.token_name,
            "violation": is_violation,
        }
        rows.append(row)
        if is_violation:
            violations.append(row)

    distinct_sizes = sorted({r["size"] for r in rows if r["size"] is not None}, reverse=True)
    token_usage_count = sum(1 for r in rows if r["source"] == "token")
    literal_count = len(violations)
    unresolved = [r for r in rows if r["source"] in ("variable", "unresolved")]

    return {
        "rows": rows,
        "violations": violations,
        "distinct_point_sizes": distinct_sizes,
        "token_usage_count": token_usage_count,
        "literal_count": literal_count,
        "unresolved": unresolved,
        "total_font_calls": len(rows),
    }


def render_text(data: dict, file: str) -> None:
    print(f"━━━ TYPOGRAPHY AUDIT — {file} ━━━")
    print(f".font(...) call sites: {data['total_font_calls']}  |  "
          f"RenaissanceFont tokens: {data['token_usage_count']}  |  "
          f"raw literals (violations): {data['literal_count']}  |  "
          f"unresolved (computed/variable font): {len(data['unresolved'])}\n")

    print(f"Distinct point sizes in use: {', '.join(c.fmt_num(s) for s in data['distinct_point_sizes'])}\n")

    print("All font call sites:")
    for r in data["rows"]:
        text_hint = f' text≈"{r["text"]}"' if r["text"] else ""
        size_str = f"{c.fmt_num(r['size'])}pt" if r["size"] is not None else "?"
        if r["dynamic"] and r["size"] is not None:
            size_str += " (base, scales with cardTextScale/DynamicType)"
        flag = " 🔴 VIOLATION (raw literal, not a RenaissanceFont token)" if r["violation"] else ""
        family = r["family"] or "?"
        token = f" [{r['token']}]" if r["token"] else ""
        print(f"  L{r['line']}: {family}{token} @ {size_str} weight={r['weight'] or '?'}"
              f" source={r['source']}{text_hint}{flag}")

    if data["unresolved"]:
        print("\nUnresolved (font comes from a variable/helper — not judged, listed for completeness):")
        for r in data["unresolved"]:
            print(f"  L{r['line']}: .font({r['size_expr']})")

    print(f"\n━━━ {data['literal_count']} raw-literal violations out of {data['total_font_calls']} font call sites ━━━")


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
