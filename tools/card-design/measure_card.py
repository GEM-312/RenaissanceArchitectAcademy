#!/usr/bin/env python3
"""
measure_card.py — report a card view's frame/size, padding, corner radius,
and the boxes of its direct child blocks.

Static analysis only: this reads the Swift source and resolves literal
`.frame(width:height:)`, `.padding(...)`, and `cornerRadius:` calls, plus
simple `let name = <number>` / `<number> * scale` constants referenced by
those calls. Anything that depends on runtime state (GeometryReader size,
@State, a ternary on `isFlipped`, GameSettings.shared.cardTextScale) is
reported as such — NOT resolved to a fake number.

Usage:
    python3 measure_card.py <file.swift> [--device-width 768] [--json]
"""
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
import raa_common as c

FRAME_RE = re.compile(r"\.frame\(([^()]*(?:\([^()]*\)[^()]*)*)\)")
PADDING_RE = re.compile(r"\.padding\(([^()]*(?:\([^()]*\)[^()]*)*)\)")
CORNER_RE = re.compile(r"cornerRadius:\s*([^,)\n]+)")
LET_CONST_RE = re.compile(r"(?:private\s+)?let\s+(\w+)\s*(?::\s*CGFloat)?\s*=\s*([^\n]+)")
COMPUTED_VAR_RE = re.compile(
    r"(?:private\s+)?var\s+(\w+)\s*:\s*CGFloat\s*\{\s*([^\n}]+)\}"
)


SPACING_RE = re.compile(r"static\s+let\s+(\w+)\s*:\s*CGFloat\s*=\s*([\d.]+)")


def resolve_theme_tokens() -> dict[str, str]:
    """Spacing.* / CornerRadius.* values from RenaissanceTheme.swift, keyed
    as e.g. 'Spacing.md' -> '16'."""
    tokens: dict[str, str] = {}
    if not c.THEME_PATH.exists():
        return tokens
    theme_text = c.THEME_PATH.read_text(encoding="utf-8")
    for enum_name in ("Spacing", "CornerRadius"):
        block = re.search(rf"enum\s+{enum_name}\s*\{{(.*?)\n\}}", theme_text, re.S)
        if not block:
            continue
        for m in SPACING_RE.finditer(block.group(1)):
            tokens[f"{enum_name}.{m.group(1)}"] = m.group(2)
    return tokens


def resolve_constants(text: str) -> dict[str, str]:
    """Collect `let NAME = EXPR` / single-line computed `var NAME: CGFloat { EXPR }`
    so .frame(width: cardW, ...) can show what cardW actually is, plus the
    project's Spacing.*/CornerRadius.* design tokens."""
    consts: dict[str, str] = dict(resolve_theme_tokens())
    for m in LET_CONST_RE.finditer(text):
        name, expr = m.groups()
        consts[name] = expr.strip().rstrip(",")
    for m in COMPUTED_VAR_RE.finditer(text):
        name, expr = m.groups()
        consts.setdefault(name, expr.strip())
    return consts


def describe_expr(expr: str, consts: dict[str, str]) -> dict:
    expr = expr.strip()
    numeric = re.match(r"^-?[\d.]+$", expr)
    if numeric:
        return {"raw": expr, "value": float(expr), "resolved": True, "note": None}
    if expr in consts:
        sub = consts[expr]
        sub_numeric = re.match(r"^-?[\d.]+$", sub)
        if sub_numeric:
            return {"raw": expr, "value": float(sub), "resolved": True,
                     "note": f"resolved from `{expr} = {sub}`"}
        return {"raw": expr, "value": None, "resolved": False,
                "note": f"`{expr}` = `{sub}` — not a plain literal, needs runtime state"}
    if "?" in expr and ":" in expr:
        return {"raw": expr, "value": None, "resolved": False,
                "note": "ternary on runtime @State — multiple possible sizes, see below"}
    if "GameSettings" in expr or "sizeClass" in expr or "GeometryReader" in expr or "proxy" in expr.lower():
        return {"raw": expr, "value": None, "resolved": False,
                "note": "depends on runtime state (settings/size class/geometry) — cannot resolve statically"}
    return {"raw": expr, "value": None, "resolved": False, "note": "unresolved expression"}


def parse_ternary_values(expr: str) -> list[str]:
    """`isFlipped ? 540 : 220` -> ['540', '220']"""
    m = re.search(r"\?\s*([^:]+?)\s*:\s*(.+)$", expr)
    if not m:
        return []
    return [m.group(1).strip(), m.group(2).strip()]


def extract_frame_calls(text: str, consts: dict[str, str]) -> list[dict]:
    results = []
    for m in FRAME_RE.finditer(text):
        args = m.group(1)
        line = c.line_of(text, m.start())
        width_m = re.search(r"width:\s*([^,)]+(?:\([^)]*\))?)", args)
        height_m = re.search(r"height:\s*([^,)]+(?:\([^)]*\))?)", args)
        max_w_m = re.search(r"maxWidth:\s*([^,)]+)", args)
        max_h_m = re.search(r"maxHeight:\s*([^,)]+)", args)
        entry = {"line": line, "args": args.strip()}
        if width_m:
            expr = width_m.group(1).strip()
            entry["width"] = describe_expr(expr, consts)
            if "?" in expr:
                entry["width"]["ternary_options"] = parse_ternary_values(expr)
        if height_m:
            expr = height_m.group(1).strip()
            entry["height"] = describe_expr(expr, consts)
            if "?" in expr:
                entry["height"]["ternary_options"] = parse_ternary_values(expr)
        if max_w_m:
            entry["maxWidth"] = max_w_m.group(1).strip()
        if max_h_m:
            entry["maxHeight"] = max_h_m.group(1).strip()
        if len(entry) > 2:
            results.append(entry)
    return results


def extract_padding_calls(text: str, consts: dict[str, str]) -> list[dict]:
    results = []
    for m in PADDING_RE.finditer(text):
        args = m.group(1).strip()
        line = c.line_of(text, m.start())
        edges_m = re.match(r"^(\.\w+)\s*,\s*(.+)$", args)
        if edges_m:
            edges, value_expr = edges_m.groups()
        elif args == "":
            edges, value_expr = "all", None
        elif re.match(r"^\.\w+$", args):
            edges, value_expr = args, None
        else:
            edges, value_expr = "all", args
        entry = {"line": line, "edges": edges}
        if value_expr:
            entry["value"] = describe_expr(value_expr, consts)
        else:
            entry["value"] = {"raw": None, "value": None, "resolved": False,
                               "note": "uses SwiftUI's default padding (~16pt, platform-dependent)"}
        results.append(entry)
    return results


def extract_corner_radii(text: str, consts: dict[str, str]) -> list[dict]:
    results = []
    for m in CORNER_RE.finditer(text):
        expr = m.group(1).strip()
        results.append({"line": c.line_of(text, m.start()), **describe_expr(expr, consts)})
    return results


def find_child_blocks(text: str) -> list[dict]:
    """Direct VStack/HStack/ZStack/Text/Image children found anywhere in the
    file, each with its own resolved .frame/.padding if declared on the same
    statement. This is file-wide (not scoped to one container) since RAA
    card views are usually one big `body`/helper-function tree."""
    events = c.scan_brackets(text)
    blocks = c.find_blocks(text, r"VStack|HStack|ZStack|ScrollView|Canvas", events)
    children = []
    for b in blocks:
        # Look at the ~2 lines after the block's own header for an attached
        # .frame/.padding chain (common RAA style: block on its own lines,
        # modifiers right after the closing brace).
        tail_start = b.close_index + 1
        tail = text[tail_start: tail_start + 300]
        frame_m = FRAME_RE.search(tail)
        pad_m = PADDING_RE.search(tail)
        entry = {
            "kind": b.keyword,
            "start_line": b.start_line,
            "end_line": b.end_line,
        }
        if frame_m and frame_m.start() < 40:
            entry["frame"] = frame_m.group(1).strip()
        if pad_m and pad_m.start() < 40:
            entry["padding"] = pad_m.group(1).strip()
        children.append(entry)
    return children


def render_text(data: dict) -> None:
    print(f"━━━ CARD MEASUREMENTS — {data['file']} ━━━")
    if data["device_width"]:
        print(f"(device width context: {data['device_width']}pt — informational only; no GeometryReader values were resolved against it)")
    print()
    print(f"Frame declarations found: {len(data['frames'])}")
    for f in data["frames"]:
        w = f.get("width")
        h = f.get("height")
        pieces = []
        if w:
            pieces.append(f"width={_short(w)}")
        if h:
            pieces.append(f"height={_short(h)}")
        if "maxWidth" in f:
            pieces.append(f"maxWidth={f['maxWidth']}")
        if "maxHeight" in f:
            pieces.append(f"maxHeight={f['maxHeight']}")
        print(f"  L{f['line']}: .frame({', '.join(pieces)})")
        for key in ("width", "height"):
            v = f.get(key)
            if v and v.get("ternary_options"):
                print(f"      {key} is a ternary → possible values: {', '.join(v['ternary_options'])} ({v['note']})")
            elif v and not v["resolved"]:
                print(f"      {key}: {v['note']}")

    print(f"\nPadding declarations found: {len(data['paddings'])}")
    for p in data["paddings"]:
        v = p["value"]
        val_str = _fmt(v) if v["value"] is not None else (v["note"] or "?")
        print(f"  L{p['line']}: .padding({p['edges']}) = {val_str}")

    print(f"\nCorner radii found: {len(data['corner_radii'])}")
    for r in data["corner_radii"]:
        val_str = _fmt(r) if r["value"] is not None else (r["note"] or "?")
        print(f"  L{r['line']}: cornerRadius = {val_str}")

    print(f"\nChild container blocks (VStack/HStack/ZStack/ScrollView/Canvas): {len(data['children'])}")
    for ch in data["children"]:
        extra = []
        if "frame" in ch:
            extra.append(f"frame({ch['frame']})")
        if "padding" in ch:
            extra.append(f"padding({ch['padding']})")
        extra_str = f"  [{', '.join(extra)}]" if extra else ""
        print(f"  L{ch['start_line']}-{ch['end_line']}: {ch['kind']}{extra_str}")

    print("\nNOTE: sizes derived from @State ternaries, GameSettings.shared.cardTextScale,")
    print("GeometryReader, or a size class are reported as unresolved by design — turning")
    print("them into a single number would be fabricating data. A render pass (Xcode preview")
    print("/ simulator) is the only way to get the exact resolved pixel values for those.")


def _short(v: dict) -> str:
    if v.get("value") is not None:
        return f"{c.fmt_num(v['value'])}pt"
    return v.get("raw") or "?"


def _fmt(v: dict) -> str:
    if v.get("value") is not None:
        suffix = f" ({v['note']})" if v.get("note") else ""
        return f"{c.fmt_num(v['value'])}pt{suffix}"
    return v.get("note") or v.get("raw") or "?"


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("file")
    ap.add_argument("--device-width", type=float, default=None,
                     help="Informational target device width in points (not used to resolve GeometryReader).")
    ap.add_argument("--json", action="store_true")
    args = ap.parse_args()

    text = c.read_file(args.file)
    consts = resolve_constants(text)

    data = {
        "file": args.file,
        "device_width": args.device_width,
        "frames": extract_frame_calls(text, consts),
        "paddings": extract_padding_calls(text, consts),
        "corner_radii": extract_corner_radii(text, consts),
        "children": find_child_blocks(text),
        "resolved_constants": consts,
    }

    if args.json:
        print(c.json.dumps(data, indent=2, default=str))
    else:
        render_text(data)


if __name__ == "__main__":
    main()
