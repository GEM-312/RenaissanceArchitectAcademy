"""
Shared helpers for the card-design tools (tools/card-design/*.py).

This is a lightweight, regex/heuristic Swift "reader" — NOT a real Swift
parser. It is deliberately conservative: where it cannot resolve a value
statically (a runtime expression, a variable defined elsewhere, a value
that depends on device state) it says so rather than guessing a number.

Every tool in this directory imports this module. Keep it stdlib-only.
"""

from __future__ import annotations

import json
import re
import sys
from dataclasses import dataclass, field
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
THEME_PATH = REPO_ROOT / "RenaissanceArchitectAcademy/Services/Styles/RenaissanceTheme.swift"

# Family name -> approximate average glyph width as a fraction of point size.
# These are rough, well-known-typeface heuristics (serif vs. display serif),
# used ONLY for --estimate-text-width style overlap math. Real values need a
# render pass (see overlap_check.py's caveats).
AVG_CHAR_WIDTH_FACTOR = {
    "Cinzel-Bold": 0.62,
    "Cinzel-Regular": 0.60,
    "EBGaramond-Regular": 0.50,
    "EBGaramond-Italic": 0.48,
    "EBGaramond-SemiBold": 0.52,
    "EBGaramond-Bold": 0.53,
    "LibreBaskerville": 0.52,
    "LibreFranklin": 0.55,
    "PetitFormalScript-Regular": 0.45,
    "Delius-Regular": 0.55,
    "Mulish": 0.53,
    "system": 0.55,
}
DEFAULT_CHAR_WIDTH_FACTOR = 0.55
# Natural (font-native) line-height factor used when SwiftUI's .lineSpacing()
# ADDS to the font's own line height. This is a widely-used approximation for
# serif text faces, not a measured value for these specific fonts.
NATURAL_LINE_HEIGHT_FACTOR = 1.2


def die(msg: str) -> None:
    print(f"error: {msg}", file=sys.stderr)
    sys.exit(1)


def read_file(path: str) -> str:
    p = Path(path)
    if not p.exists():
        die(f"file not found: {path}")
    return p.read_text(encoding="utf-8")


def line_of(text: str, char_index: int) -> int:
    """1-indexed line number for a character offset."""
    return text.count("\n", 0, char_index) + 1


def line_text(text: str, line_no: int) -> str:
    lines = text.split("\n")
    if 1 <= line_no <= len(lines):
        return lines[line_no - 1].strip()
    return ""


# ---------------------------------------------------------------------------
# Brace-aware scanning
#
# Swift source, minus strings/comments, is scanned char-by-char so callers
# can find the `{ ... }` body that matches a given opening brace — this is
# what lets us pull out "the body of this ZStack" or "the body of this
# struct" without a real parser.
# ---------------------------------------------------------------------------


@dataclass
class BraceEvent:
    index: int
    line: int
    delta: int  # +1 for opener, -1 for closer
    char: str = "{"


def scan_brackets(text: str) -> list[BraceEvent]:
    """Scan for '{','}','(',')' outside strings/comments, in source order."""
    events: list[BraceEvent] = []
    i = 0
    n = len(text)
    line = 1
    in_line_comment = False
    in_block_comment = False
    in_string = False
    while i < n:
        c = text[i]
        if c == "\n":
            line += 1
            in_line_comment = False
            i += 1
            continue
        if in_line_comment:
            i += 1
            continue
        if in_block_comment:
            if c == "*" and i + 1 < n and text[i + 1] == "/":
                in_block_comment = False
                i += 2
                continue
            i += 1
            continue
        if in_string:
            if c == "\\":
                i += 2
                continue
            if c == '"':
                in_string = False
            i += 1
            continue
        if c == "/" and i + 1 < n and text[i + 1] == "/":
            in_line_comment = True
            i += 2
            continue
        if c == "/" and i + 1 < n and text[i + 1] == "*":
            in_block_comment = True
            i += 2
            continue
        if c == '"':
            in_string = True
            i += 1
            continue
        if c in "{(":
            events.append(BraceEvent(i, line, 1, c))
        elif c in "})":
            events.append(BraceEvent(i, line, -1, c))
        i += 1
    return events


# Backwards-compatible name used by earlier drafts / external callers.
def scan_braces(text: str) -> list[BraceEvent]:
    return [e for e in scan_brackets(text) if e.char in "{}"]


def matching_bracket_close(events: list[BraceEvent], open_index: int) -> BraceEvent | None:
    """Like matching_close, but works for a '(' opener too (matches '(' with
    ')', independent of any '{'/'}' also present in `events`)."""
    depth = 0
    started = False
    open_char = None
    for ev in events:
        if ev.index < open_index:
            continue
        if ev.index == open_index:
            depth = 1
            started = True
            open_char = ev.char
            continue
        if not started:
            continue
        same_family = (open_char in "{}" and ev.char in "{}") or (open_char in "()" and ev.char in "()")
        if not same_family:
            continue
        depth += ev.delta
        if depth == 0:
            return ev
    return None


def matching_close(events: list[BraceEvent], open_index: int) -> BraceEvent | None:
    """Given the char index of a '{', find its matching '}' BraceEvent.
    `events` may be brace-only or brace+paren; only '{'/'}' are counted."""
    depth = 0
    started = False
    for ev in events:
        if ev.char not in "{}":
            continue
        if ev.index < open_index:
            continue
        if ev.index == open_index and ev.delta == 1:
            depth = 1
            started = True
            continue
        if not started:
            continue
        depth += ev.delta
        if depth == 0:
            return ev
    return None


@dataclass
class Block:
    keyword: str          # e.g. "ZStack", "VStack", "struct CardName"
    header: str            # the source line(s) that precede the opening brace, trimmed
    open_index: int
    close_index: int
    start_line: int
    end_line: int
    body: str


def find_blocks(text: str, keyword_pattern: str, events: list[BraceEvent] | None = None) -> list[Block]:
    """
    Find all `<keyword...> {` blocks matching keyword_pattern (a regex for the
    keyword itself, e.g. r"ZStack" or r"struct\\s+\\w+"). Handles an optional
    parenthesized argument list between the keyword and the brace, e.g.
    `ZStack(alignment: .top) {`.
    """
    if events is None:
        events = scan_braces(text)
    blocks: list[Block] = []
    pattern = re.compile(
        rf"\b({keyword_pattern})\b\s*(\([^{{}}]*\))?\s*\{{"
    )
    for m in pattern.finditer(text):
        open_index = m.end() - 1  # index of the '{' itself
        close = matching_close(events, open_index)
        if close is None:
            continue
        body = text[open_index + 1 : close.index]
        blocks.append(
            Block(
                keyword=m.group(1),
                header=m.group(0).strip(),
                open_index=open_index,
                close_index=close.index,
                start_line=line_of(text, m.start()),
                end_line=close.line,
                body=body,
            )
        )
    return blocks


def top_level_statements(body: str, base_line: int, events: list[BraceEvent] | None = None) -> list[tuple[str, int]]:
    """
    Split a block body into top-level "statements" (depth-0 relative to the
    block's own body, counting BOTH `{}` and `()`) by watching bracket depth.
    Returns (text, line_no) pairs. This is a heuristic line-grouping, not a
    real statement parser — good enough to say "here are the N direct
    children of this ZStack". A line only starts a new statement when the
    previous statement's brackets are balanced AND the line doesn't open
    with a modifier-chain continuation (`.foo(`, `,`, a bare `)`/`}`, etc.).
    """
    if events is None:
        events = scan_brackets(body)
    lines = body.split("\n")
    depth_before: list[int] = []
    depth = 0
    ev_iter = iter(events)
    ev = next(ev_iter, None)
    char_pos = 0
    for ln in lines:
        depth_before.append(depth)
        line_end = char_pos + len(ln)
        while ev is not None and ev.index < line_end:
            depth += ev.delta
            ev = next(ev_iter, None)
        char_pos = line_end + 1  # +1 for the '\n'

    statements: list[tuple[str, int]] = []
    current: list[str] = []
    current_start_line = None
    for idx, ln in enumerate(lines):
        stripped = ln.strip()
        if not stripped:
            continue
        at_zero_depth = depth_before[idx] == 0
        is_continuation = bool(re.match(r"^[.,)\]}]", stripped)) or stripped.startswith("//")
        if at_zero_depth and current and not is_continuation:
            statements.append(("\n".join(current), base_line + current_start_line))
            current = [ln]
            current_start_line = idx
        else:
            if current_start_line is None:
                current_start_line = idx
            current.append(ln)
    if current:
        statements.append(("\n".join(current), base_line + current_start_line))
    return statements


# ---------------------------------------------------------------------------
# RenaissanceFont token table
# ---------------------------------------------------------------------------


@dataclass
class FontToken:
    name: str
    family: str
    size_expr: str
    size: float | None      # resolved numeric base size, if it's a plain literal
    dynamic: bool           # True if size depends on GameSettings.shared.cardTextScale etc.
    relative_to: str | None
    line: int


def parse_font_tokens(theme_path: Path = THEME_PATH) -> dict[str, FontToken]:
    if not theme_path.exists():
        return {}
    text = theme_path.read_text(encoding="utf-8")
    tokens: dict[str, FontToken] = {}

    # `static let NAME = Font.custom("Family", size: N, relativeTo: .anchor)`
    let_pattern = re.compile(
        r'static\s+let\s+(\w+)\s*(?::\s*Font)?\s*=\s*Font\.custom\(\s*"([^"]+)"\s*,\s*size:\s*([\d.]+)\s*'
        r'(?:,\s*relativeTo:\s*\.(\w+))?\s*\)'
    )
    for m in let_pattern.finditer(text):
        name, family, size_str, rel = m.groups()
        tokens[name] = FontToken(
            name=name,
            family=family,
            size_expr=size_str,
            size=float(size_str),
            dynamic=False,
            relative_to=rel,
            line=line_of(text, m.start()),
        )

    # computed vars: `@MainActor static var NAME: Font { .custom("Family", size: EXPR, relativeTo: .anchor) }`
    var_pattern = re.compile(
        r'static\s+var\s+(\w+)\s*:\s*Font\s*\{\s*\.custom\(\s*"([^"]+)"\s*,\s*size:\s*([^,]+?)\s*'
        r'(?:,\s*relativeTo:\s*\.(\w+))?\s*\)\s*\}'
    )
    for m in var_pattern.finditer(text):
        name, family, size_expr, rel = m.groups()
        size_expr = size_expr.strip()
        numeric = re.match(r"^([\d.]+)\s*\*", size_expr)
        base_size = float(numeric.group(1)) if numeric else None
        tokens[name] = FontToken(
            name=name,
            family=family,
            size_expr=size_expr,
            size=base_size,
            dynamic=True,
            relative_to=rel,
            line=line_of(text, m.start()),
        )

    return tokens


def font_weight_hint(family: str) -> str:
    lower = family.lower()
    if "bold" in lower and "semibold" not in lower:
        return "bold"
    if "semibold" in lower:
        return "semibold"
    if "italic" in lower:
        return "italic"
    if "script" in lower:
        return "script"
    return "regular"


def is_heading_family(family: str) -> bool:
    """RAA convention: Cinzel is the titles/headers typeface, EBGaramond is body."""
    return family.startswith("Cinzel")


# ---------------------------------------------------------------------------
# Font-usage extraction: every `.font(...)` call site in a file, resolved
# against the token table where possible.
# ---------------------------------------------------------------------------


@dataclass
class FontUsage:
    line: int
    raw: str                 # the raw .font(...) argument expression
    source: str               # "token" | "literal-custom" | "literal-system" | "variable" | "unresolved"
    token_name: str | None
    family: str | None
    size: float | None
    size_expr: str | None
    dynamic: bool
    weight: str | None
    nearby_text: str | None   # best-effort nearest Text(...) literal on the same/prior lines


_FONT_CALL = re.compile(r"\.font\(\s*([^()]*(?:\([^()]*\)[^()]*)*)\s*\)")
_TEXT_LITERAL = re.compile(r'Text\(\s*"([^"]{0,80})')


def find_font_usages(text: str, tokens: dict[str, FontToken]) -> list[FontUsage]:
    usages: list[FontUsage] = []
    for m in _FONT_CALL.finditer(text):
        raw = m.group(1).strip()
        line = line_of(text, m.start())
        usage = _resolve_font_usage(raw, line, tokens, text, m.start())
        usages.append(usage)
    return usages


def _resolve_font_usage(raw: str, line: int, tokens: dict[str, FontToken], text: str, char_pos: int) -> FontUsage:
    nearby = _find_nearby_text(text, char_pos)

    token_match = re.match(r"RenaissanceFont\.(\w+)", raw)
    if token_match:
        name = token_match.group(1)
        tok = tokens.get(name)
        if tok:
            return FontUsage(
                line=line, raw=raw, source="token", token_name=name,
                family=tok.family, size=tok.size, size_expr=tok.size_expr,
                dynamic=tok.dynamic, weight=font_weight_hint(tok.family),
                nearby_text=nearby,
            )
        return FontUsage(
            line=line, raw=raw, source="unresolved", token_name=name,
            family=None, size=None, size_expr=None, dynamic=False,
            weight=None, nearby_text=nearby,
        )

    custom_match = re.match(r'\.custom\(\s*"([^"]+)"\s*,\s*size:\s*([^,)]+)', raw) or \
        re.match(r'Font\.custom\(\s*"([^"]+)"\s*,\s*size:\s*([^,)]+)', raw)
    if custom_match:
        family, size_expr = custom_match.groups()
        size_expr = size_expr.strip()
        numeric = re.match(r"^([\d.]+)\s*$", size_expr)
        dynamic = numeric is None
        size = float(numeric.group(1)) if numeric else _leading_number(size_expr)
        return FontUsage(
            line=line, raw=raw, source="literal-custom", token_name=None,
            family=family, size=size, size_expr=size_expr, dynamic=dynamic,
            weight=font_weight_hint(family), nearby_text=nearby,
        )

    system_match = re.match(r"\.system\(\s*size:\s*([^,)]+)", raw)
    if system_match:
        size_expr = system_match.group(1).strip()
        numeric = re.match(r"^([\d.]+)\s*$", size_expr)
        weight_match = re.search(r"weight:\s*\.(\w+)", raw)
        return FontUsage(
            line=line, raw=raw, source="literal-system", token_name=None,
            family="system", size=(float(numeric.group(1)) if numeric else _leading_number(size_expr)),
            size_expr=size_expr, dynamic=numeric is None,
            weight=(weight_match.group(1) if weight_match else "regular"),
            nearby_text=nearby,
        )

    # e.g. `.font(font)` or `.font(ActivitySizing.cardHeaderTitleFont(sizeClass))`
    if re.match(r"^[A-Za-z_][\w.]*(\([^)]*\))?$", raw):
        return FontUsage(
            line=line, raw=raw, source="variable", token_name=None,
            family=None, size=None, size_expr=raw, dynamic=True,
            weight=None, nearby_text=nearby,
        )

    return FontUsage(
        line=line, raw=raw, source="unresolved", token_name=None,
        family=None, size=None, size_expr=raw, dynamic=False,
        weight=None, nearby_text=nearby,
    )


def _leading_number(expr: str) -> float | None:
    m = re.match(r"^([\d.]+)", expr.strip())
    return float(m.group(1)) if m else None


def _find_nearby_text(text: str, char_pos: int) -> str | None:
    window_start = max(0, char_pos - 200)
    window = text[window_start:char_pos]
    matches = list(_TEXT_LITERAL.finditer(window))
    if matches:
        return matches[-1].group(1)
    # Text(someVariable) with no literal — grab the variable name instead.
    var_matches = list(re.finditer(r"Text\(\s*([^\")\n]{1,60})\)", window))
    if var_matches:
        return f"<{var_matches[-1].group(1).strip()}>"
    return None


# ---------------------------------------------------------------------------
# CLI output helpers
# ---------------------------------------------------------------------------


def emit(data: dict, as_json: bool, text_renderer) -> None:
    if as_json:
        print(json.dumps(data, indent=2, default=str))
    else:
        text_renderer(data)


def fmt_num(v) -> str:
    if v is None:
        return "?"
    if isinstance(v, float) and v == int(v):
        return str(int(v))
    return str(v)
