#!/usr/bin/env python3
"""
overlap_check.py — find text blocks (from different layers) whose bounding
boxes intersect, at a given width, with how much separation is needed to
clear them.

Two overlap domains are checked, since RAA's cards mix both:

  1. SwiftUI layout text (ZStack children with a literal `.frame()` AND an
     `.offset()`/`.position()`) — most Text in these cards has neither
     (it flows in a VStack, which cannot overlap by construction), so this
     domain usually reports nothing to check; that is expected, not a bug
     in the tool.

  2. `Canvas { context, size in ... context.draw(Text(...).font(...), at:
     CGPoint(x:, y:)) }` diagrams (CardVisualView.swift's science visuals).
     This is the domain the tool was actually commissioned for: text drawn
     directly over artwork at explicit coordinates. Each `drawXxx(context:,
     size:)` function is analyzed on its own — draws in different drawing
     functions are never simultaneous (only one draw function runs per
     visual) — but within one function, a later `guard currentStep >= N
     else { return }` does NOT hide earlier draws once the guard is past,
     so every draw in the function is compared against every other draw in
     it, at the diagram's final (fully revealed) step.

ESTIMATES, clearly labeled: text box size is never measured by a renderer.
  - box width  = character_count * fontSize * avg_char_width_factor
  - box height = fontSize * NATURAL_LINE_HEIGHT_FACTOR (~1.2x)
  - Canvas text draws default to a CENTER anchor, so the box is centered on
    the `at:` point.
  - When the drawn text is a literal string, character_count is exact. When
    it's a variable/interpolation (`visual.labels[i]`, `"\\(Int(x))m"`), the
    real length is unknowable statically — `--assumed-chars` (default 10)
    is used instead, and every such row is marked `text_is_estimated`.
  - `w`/`h` in Canvas draw math come from `size.width`/`size.height`, which
    is NOT known until the view is laid out. `--width`/`--height` supply a
    stand-in (defaults: 320x180, matching CardVisualView's own "~180pt
    tall" doc comment) — pass real numbers for your target device if you
    have them.

Usage:
    python3 overlap_check.py <file.swift> [--width 320] [--height 180]
                              [--safe-margin 8] [--assumed-chars 10] [--json]
"""
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
import raa_common as c

DRAW_CALL_RE = re.compile(r"context\.draw\(")
DRAW_FUNC_RE = re.compile(
    r"(?:private\s+|fileprivate\s+)?func\s+(draw\w*)\s*\(\s*context:\s*GraphicsContext\s*,\s*size:\s*CGSize\s*\)"
)
CGPOINT_RE = re.compile(r"CGPoint\(\s*x:\s*(.+?),\s*y:\s*(.+?)\s*\)")
STRING_TEXT_RE = re.compile(r'Text\(\s*"((?:[^"\\]|\\.)*)"')
VAR_TEXT_RE = re.compile(r"Text\(\s*([^)]+?)\s*\)")
SIZE_ALIAS_RE = re.compile(r"let\s+(\w+)\s*=\s*size\.width\s*,\s*(\w+)\s*=\s*size\.height")


_SAFE_GEOMETRY_EXPR = re.compile(r"^[\d.\s+\-*/(),whminax]+$", re.I)


def safe_eval_geometry(expr: str, w: float, h: float) -> float | None:
    """Evaluate a simple `w`/`h` arithmetic expression (as used for Canvas
    draw coordinates, e.g. `w * 0.2`). Refuses anything containing
    identifiers other than w/h/min/max/CGFloat, so it never executes
    arbitrary code from the source file."""
    expr = expr.strip().rstrip(",")
    expr = re.sub(r"\bCGFloat\(([^)]*)\)", r"(\1)", expr)
    if not _SAFE_GEOMETRY_EXPR.match(expr):
        return None
    try:
        return float(eval(expr, {"__builtins__": {}}, {"w": w, "h": h, "min": min, "max": max}))
    except Exception:
        return None


def split_top_level_commas(s: str) -> list[str]:
    parts, current, depth = [], [], 0
    for ch in s:
        if ch == "(":
            depth += 1
        elif ch == ")":
            depth -= 1
        if ch == "," and depth == 0:
            parts.append("".join(current))
            current = []
        else:
            current.append(ch)
    parts.append("".join(current))
    return parts


_LET_LINE_RE = re.compile(r"^\s*(?:private\s+)?let\s+(.+)$")
_LET_BINDING_RE = re.compile(r"^(\w+)\s*(?::\s*CGFloat)?\s*=\s*(.+)$")


def parse_local_lets(body: str) -> dict[str, str]:
    """`let NAME = EXPR` (incl. `let a = X, b = Y` on one line) -> {NAME: EXPR}.
    Best-effort — only single-line, non-string-literal RHS expressions are
    useful here since we only ever resolve geometry (numeric) variables."""
    lets: dict[str, str] = {}
    for line in body.split("\n"):
        m = _LET_LINE_RE.match(line)
        if not m:
            continue
        for part in split_top_level_commas(m.group(1)):
            bm = _LET_BINDING_RE.match(part.strip())
            if bm:
                lets.setdefault(bm.group(1), bm.group(2).strip())
    return lets


_IDENTIFIER_RE = re.compile(r"[A-Za-z_]\w*")
_RESOLVE_STOPWORDS = {"w", "h", "min", "max", "CGFloat"}


def resolve_and_eval(expr: str, local_vars: dict[str, str], w: float, h: float,
                      w_name: str, h_name: str, depth: int = 0) -> float | None:
    """Resolve `expr` to a number by substituting w/h aliases and any local
    `let` variables it references (recursively, up to a small depth), then
    evaluating with safe_eval_geometry. Returns None if it can't be reduced
    to pure arithmetic (e.g. it depends on @State or a function argument)."""
    expr = expr.strip().rstrip(",")
    if w_name != "w":
        expr = re.sub(rf"\b{re.escape(w_name)}\b", "w", expr)
    if h_name != "h":
        expr = re.sub(rf"\b{re.escape(h_name)}\b", "h", expr)

    direct = safe_eval_geometry(expr, w, h)
    if direct is not None:
        return direct
    if depth > 6:
        return None

    ids = set(_IDENTIFIER_RE.findall(expr)) - _RESOLVE_STOPWORDS
    if not ids:
        return None

    substituted = expr
    any_sub = False
    for ident in ids:
        if ident in local_vars:
            sub_val = resolve_and_eval(local_vars[ident], local_vars, w, h, w_name, h_name, depth + 1)
            if sub_val is not None:
                substituted = re.sub(rf"\b{re.escape(ident)}\b", f"({sub_val})", substituted)
                any_sub = True
    if not any_sub:
        return None
    return safe_eval_geometry(substituted, w, h)


def char_width_factor(family: str | None) -> float:
    if not family:
        return c.DEFAULT_CHAR_WIDTH_FACTOR
    return c.AVG_CHAR_WIDTH_FACTOR.get(family, c.DEFAULT_CHAR_WIDTH_FACTOR)


def extract_canvas_draws(text: str, width: float, height: float, assumed_chars: int, tokens: dict) -> list[dict]:
    events = c.scan_brackets(text)
    func_matches = list(DRAW_FUNC_RE.finditer(text))
    results = []
    for i, fm in enumerate(func_matches):
        func_name = fm.group(1)
        # function body: from the '{' right after the signature to its match
        brace_search_start = fm.end()
        brace_m = re.search(r"\{", text[brace_search_start: brace_search_start + 20])
        if not brace_m:
            continue
        open_idx = brace_search_start + brace_m.start()
        close = c.matching_close(events, open_idx)
        if close is None:
            continue
        body = text[open_idx + 1: close.index]
        base_line = c.line_of(text, open_idx + 1)

        alias = SIZE_ALIAS_RE.search(body)
        w_name, h_name = (alias.group(1), alias.group(2)) if alias else ("w", "h")
        local_vars = parse_local_lets(body)

        draws = []
        body_events = c.scan_brackets(body)
        for dm in DRAW_CALL_RE.finditer(body):
            open_paren = dm.end() - 1
            close_paren = c.matching_bracket_close(body_events, open_paren)
            if close_paren is None:
                continue
            args_text = body[open_paren + 1: close_paren.index]
            line = base_line + body[:dm.start()].count("\n")

            pt_m = CGPOINT_RE.search(args_text)
            if not pt_m:
                continue
            x_expr, y_expr = pt_m.groups()
            x = resolve_and_eval(x_expr, local_vars, width, height, w_name, h_name)
            y = resolve_and_eval(y_expr, local_vars, width, height, w_name, h_name)

            str_m = STRING_TEXT_RE.search(args_text)
            if str_m:
                literal = str_m.group(1)
                char_count = len(literal)
                text_is_estimated = False
                text_desc = f'"{literal}"'
            else:
                var_m = VAR_TEXT_RE.search(args_text)
                text_desc = f"<{var_m.group(1).strip()}>" if var_m else "<unresolved text>"
                char_count = assumed_chars
                text_is_estimated = True

            font_m = c._FONT_CALL.search(args_text)
            family, size = None, None
            if font_m:
                usage = c._resolve_font_usage(font_m.group(1).strip(), line, tokens, args_text, font_m.start())
                family, size = usage.family, usage.size

            nearest_guard = _nearest_preceding_guard(body, dm.start())

            draws.append({
                "line": line,
                "text": text_desc,
                "text_is_estimated": text_is_estimated,
                "char_count": char_count,
                "family": family,
                "size": size,
                "x": x,
                "y": y,
                "x_expr": x_expr.strip(),
                "y_expr": y_expr.strip(),
                "guard": nearest_guard,
            })
        if draws:
            results.append({"function": func_name, "line": fm.start() and c.line_of(text, fm.start()), "draws": draws})
    return results


_GUARD_LINE_RE = re.compile(r"^\s*guard\s+(.+?)\s*else\s*\{\s*return\s*\}\s*$", re.M)


def _nearest_preceding_guard(body: str, char_pos: int) -> str | None:
    best = None
    for m in _GUARD_LINE_RE.finditer(body):
        if m.start() < char_pos:
            best = m.group(1)
        else:
            break
    return best


def box_for_draw(d: dict, char_width_default: float) -> dict | None:
    if d["x"] is None or d["y"] is None or d["size"] is None:
        return None
    factor = char_width_factor(d["family"])
    w = round(d["char_count"] * d["size"] * factor, 1)
    h = round(d["size"] * c.NATURAL_LINE_HEIGHT_FACTOR, 1)
    x, y = round(d["x"], 1), round(d["y"], 1)
    return {
        "x0": x - w / 2, "x1": x + w / 2,
        "y0": y - h / 2, "y1": y + h / 2,
        "w": w, "h": h, "cx": x, "cy": y,
    }


def intersect(a: dict, b: dict, safe_margin: float) -> dict | None:
    ox = min(a["x1"], b["x1"]) - max(a["x0"], b["x0"])
    oy = min(a["y1"], b["y1"]) - max(a["y0"], b["y0"])
    if ox > 0 and oy > 0:
        return {
            "overlaps": True,
            "overlap_w": round(ox, 1), "overlap_h": round(oy, 1),
            "needed_separation": round(min(ox, oy) + safe_margin, 1),
        }
    # not overlapping — check gap against safe margin
    gap_x = max(0.0, max(a["x0"], b["x0"]) - min(a["x1"], b["x1"]))
    gap_y = max(0.0, max(a["y0"], b["y0"]) - min(a["y1"], b["y1"]))
    gap = gap_x if oy > 0 else (gap_y if ox > 0 else min(gap_x, gap_y))
    if gap < safe_margin:
        return {
            "overlaps": False,
            "gap": round(gap, 1),
            "needed_separation": round(safe_margin - gap, 1),
        }
    return None


FRAME_WH_RE = re.compile(r"\.frame\(\s*width:\s*([\d.]+)\s*,\s*height:\s*([\d.]+)\s*\)")
OFFSET_RE = re.compile(r"\.offset\(\s*x:\s*(-?[\d.]+)\s*,\s*y:\s*(-?[\d.]+)\s*\)")
POSITION_RE = re.compile(r"\.position\(\s*x:\s*(-?[\d.]+)\s*,\s*y:\s*(-?[\d.]+)\s*\)")


def find_zstack_text_layers(text: str) -> list[dict]:
    """Domain 1: ZStack direct children that carry BOTH a literal
    `.frame(width:height:)` AND an `.offset()`/`.position()` — the only case
    where two ZStack siblings' absolute boxes are knowable without a
    renderer. Most RAA card Text sits in an auto-laid-out VStack instead
    (no overlap possible there by construction), so an empty result here is
    the common, expected case."""
    events = c.scan_brackets(text)
    zstacks = c.find_blocks(text, r"ZStack", events)
    findings = []
    for z in zstacks:
        stmts = c.top_level_statements(z.body, z.start_line, c.scan_brackets(z.body))
        items = []
        for stmt_text, line_no in stmts:
            first = next((ln.strip() for ln in stmt_text.splitlines() if ln.strip() and not ln.strip().startswith("//")), "")
            if not first:
                continue
            frame_m = FRAME_WH_RE.search(stmt_text)
            if not frame_m:
                continue
            off_m = OFFSET_RE.search(stmt_text) or POSITION_RE.search(stmt_text)
            fw, fh = float(frame_m.group(1)), float(frame_m.group(2))
            ox, oy = (float(off_m.group(1)), float(off_m.group(2))) if off_m else (0.0, 0.0)
            is_text_bearing = "Text(" in stmt_text
            guard = re.match(r"^(if |else if |else)\b", first)
            items.append({
                "line": line_no, "summary": first[:80], "w": fw, "h": fh,
                "cx": ox, "cy": oy, "is_text": is_text_bearing,
                "guarded": bool(guard),
            })
        for i in range(len(items)):
            for j in range(i + 1, len(items)):
                a, b = items[i], items[j]
                if a["guarded"] or b["guarded"]:
                    continue  # can't statically prove simultaneity across if/else
                box_a = {"x0": a["cx"] - a["w"] / 2, "x1": a["cx"] + a["w"] / 2,
                          "y0": a["cy"] - a["h"] / 2, "y1": a["cy"] + a["h"] / 2}
                box_b = {"x0": b["cx"] - b["w"] / 2, "x1": b["cx"] + b["w"] / 2,
                          "y0": b["cy"] - b["h"] / 2, "y1": b["cy"] + b["h"] / 2}
                result = intersect(box_a, box_b, 0)  # margin handled by caller for report only
                if result and result["overlaps"]:
                    findings.append({"zstack_line": z.start_line, "a": a, "b": b, **result})
    return findings


def analyze(text: str, width: float, height: float, safe_margin: float, assumed_chars: int) -> dict:
    tokens = c.parse_font_tokens()
    zstack_findings = find_zstack_text_layers(text)
    canvas_groups = extract_canvas_draws(text, width, height, assumed_chars, tokens)
    canvas_findings = []
    unresolved_draws = []
    for group in canvas_groups:
        draws = group["draws"]
        boxes = [box_for_draw(d, c.DEFAULT_CHAR_WIDTH_FACTOR) for d in draws]
        for i, d in enumerate(draws):
            if boxes[i] is None:
                unresolved_draws.append({"function": group["function"], **d})
        for i in range(len(draws)):
            for j in range(i + 1, len(draws)):
                if boxes[i] is None or boxes[j] is None:
                    continue
                result = intersect(boxes[i], boxes[j], safe_margin)
                if result:
                    canvas_findings.append({
                        "function": group["function"],
                        "a": draws[i], "b": draws[j],
                        "box_a": boxes[i], "box_b": boxes[j],
                        **result,
                    })

    return {
        "width": width, "height": height, "safe_margin": safe_margin, "assumed_chars": assumed_chars,
        "zstack_findings": zstack_findings,
        "canvas_groups_analyzed": len(canvas_groups),
        "canvas_draws_total": sum(len(g["draws"]) for g in canvas_groups),
        "canvas_findings": canvas_findings,
        "unresolved_draws": unresolved_draws,
    }


def render_text(data: dict, file: str) -> None:
    print(f"━━━ OVERLAP CHECK — {file} ━━━")
    print(f"Canvas width×height assumed: {c.fmt_num(data['width'])}×{c.fmt_num(data['height'])}pt  |  "
          f"safe margin: {c.fmt_num(data['safe_margin'])}pt  |  "
          f"assumed chars for dynamic text: {data['assumed_chars']}")
    print(f"Canvas draw() text calls found: {data['canvas_draws_total']} across "
          f"{data['canvas_groups_analyzed']} drawing function(s)")

    print(f"\n--- Domain 1: ZStack siblings with literal .frame()+.offset()/.position() ---")
    if not data["zstack_findings"]:
        print("None found. (Expected in most RAA cards — Text here flows in an auto-laid-out")
        print("VStack, which can't overlap by construction; this domain only catches the rarer")
        print("absolutely-positioned case.)")
    else:
        for f in data["zstack_findings"]:
            print(f"  ZStack L{f['zstack_line']}: L{f['a']['line']} \"{f['a']['summary']}\" × "
                  f"L{f['b']['line']} \"{f['b']['summary']}\" — overlap {f['overlap_w']}×{f['overlap_h']}pt")
    print("\n--- Domain 2: Canvas context.draw() text over artwork ---")

    if not data["canvas_findings"]:
        print("No overlaps or too-close pairs found among the Canvas text draws whose position/font/text")
        print("were all statically resolvable.")
    else:
        print(f"⚠ {len(data['canvas_findings'])} finding(s):\n")
        for f in data["canvas_findings"]:
            kind = "OVERLAP" if f["overlaps"] else "TOO CLOSE"
            print(f"[{kind}] {f['function']}: L{f['a']['line']} {f['a']['text']} × L{f['b']['line']} {f['b']['text']}")
            print(f"    a: center=({f['box_a']['cx']},{f['box_a']['cy']}) "
                  f"box={f['box_a']['w']}×{f['box_a']['h']}"
                  f"{'  (text length ESTIMATED)' if f['a']['text_is_estimated'] else ''}")
            print(f"    b: center=({f['box_b']['cx']},{f['box_b']['cy']}) "
                  f"box={f['box_b']['w']}×{f['box_b']['h']}"
                  f"{'  (text length ESTIMATED)' if f['b']['text_is_estimated'] else ''}")
            if f["overlaps"]:
                print(f"    overlap: {f['overlap_w']}×{f['overlap_h']}pt — needs ≥{f['needed_separation']}pt"
                      f" separation to clear (incl. {c.fmt_num(data['safe_margin'])}pt margin)")
            else:
                print(f"    gap: {f['gap']}pt (< {c.fmt_num(data['safe_margin'])}pt margin) — needs "
                      f"{f['needed_separation']}pt more separation")
            guards = {f["a"]["guard"], f["b"]["guard"]}
            if guards != {None}:
                print(f"    guard context: a←`{f['a']['guard']}`  b←`{f['b']['guard']}`"
                      f"  (both reachable simultaneously once the later guard passes — see script docstring)")
            print()

    if data["unresolved_draws"]:
        print(f"{len(data['unresolved_draws'])} draw(s) excluded from overlap math (position/font not statically resolvable):")
        for d in data["unresolved_draws"]:
            reason = []
            if d["x"] is None or d["y"] is None:
                reason.append("position depends on runtime value")
            if d["size"] is None:
                reason.append("font size unresolved")
            print(f"  {d['function']} L{d['line']}: {d['text']} — {', '.join(reason)}")


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("file")
    ap.add_argument("--width", type=float, default=320.0, help="Assumed Canvas width in points (default 320).")
    ap.add_argument("--height", type=float, default=180.0, help="Assumed Canvas height in points (default 180).")
    ap.add_argument("--safe-margin", type=float, default=8.0, help="Minimum clear separation in points (default 8).")
    ap.add_argument("--assumed-chars", type=int, default=10,
                     help="Character count to assume for dynamic (non-literal) text (default 10).")
    ap.add_argument("--json", action="store_true")
    args = ap.parse_args()

    text = c.read_file(args.file)
    data = analyze(text, args.width, args.height, args.safe_margin, args.assumed_chars)

    if args.json:
        print(c.json.dumps(data, indent=2, default=str))
    else:
        render_text(data, args.file)


if __name__ == "__main__":
    main()
