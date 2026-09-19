# Card design tools

Six standalone, stdlib-only Python 3 scripts that read a card SwiftUI view
file and report precise-as-possible layout/typography measurements —
instead of eyeballing it. Built for the **`card-designer`** agent
(`.claude/agents/card-designer.md`), but runnable directly from the repo
root:

```
python3 tools/card-design/measure_card.py RenaissanceArchitectAcademy/Views/DiscoveryCardOverlay.swift
```

Every tool supports `--json` for machine-readable output.

## What these tools are, and are not

They are a lightweight, regex/brace-depth **reader** of Swift source
(`raa_common.py`), not a Swift compiler or a SwiftUI layout engine. They
never run Xcode, never launch a simulator, and never render anything. Where
a number can be read directly off the source (`.font(.custom("X", size:
18))`, `.padding(20)`, `cornerRadius: 16`) it's reported as exact. Where a
number depends on runtime state — `@State`, `GameSettings.shared.
cardTextScale`, a `GeometryReader` size, a ternary on `isFlipped` — the
tools say so explicitly instead of inventing a value. Text-box sizes for
the overlap checker are **always estimates** (character count × an
average glyph-width factor); see `overlap_check.py`'s docstring for the
exact formula and why. **Getting the true, exact resolved numbers requires
a render pass** (an Xcode preview or simulator run) — these tools narrow
down where to look, they don't replace looking.

All six were run against the three real card views on 2026-09-18, and again
on 2026-09-19 after `overlap_check.py` gained the domain-3 paragraph/visual
sweep below; see each PR's description for the actual output and what it
found.

---

## `measure_card.py`

Card frame/size, padding, corner radius, and every child container's box.

```
python3 measure_card.py <file.swift> [--device-width 768] [--json]
```

- `--device-width` — informational only (e.g. "this is for an iPad"); it is
  **not** substituted into any `GeometryReader`-derived value, since a
  static reader can't know what a `GeometryReader` will actually report.
- Resolves `let cardW = ...` / `Spacing.md` / `CornerRadius.lg` style
  constants back to their numeric value so you don't have to chase them by
  hand; a `?` ternary (`isFlipped ? 540 : 220`) is reported as **both**
  possible values, not collapsed to one.

**Worked example** (`DiscoveryCardOverlay.swift`):

```
Frame declarations found: 4
  L38: .frame(width=isFlipped ? 540 : 220, height=isFlipped ? 700 : 300)
      width is a ternary → possible values: 540, 220 (...)
      height is a ternary → possible values: 700, 300 (...)
  L209: .frame(width=40pt, height=40pt)

Padding declarations found: 10
  L240: .padding(.horizontal) = 16pt (resolved from `Spacing.md = 16`)
  ...

Corner radii found: 8
  L75: cornerRadius = 16pt
  ...
```

## `count_layers.py`

Layer count and z-order: every `ZStack`'s nesting depth and direct children
in **paint order** (SwiftUI stacks a ZStack's children back-to-front in
source order, so line order *is* z-order), plus every `.overlay()`/
`.background()` call site (each is an implicit extra compositing layer).

```
python3 count_layers.py <file.swift> [--json]
```

Each child is labeled with the `if`/`else if` condition guarding it, if
any — the tool does not try to prove two branches are mutually exclusive,
it just tells you which children are *unguarded* (i.e. provably
simultaneous) so you know where to look for real stacking.

**Worked example** (`KnowledgeCardsOverlay.swift`, abridged):

```
  ZStack L263-295  (nesting depth 1, 2 direct children)
    z0 (back→front) L265: ZStack {
    z1 (back→front) L291: if isThisFlipped && angle >= 90 {  [guarded by: if isThisFlipped && angle >= 90]

    ZStack L265-287  (nesting depth 2, 2 direct children)
      z0 (back→front) L267: cardFront(card: card, isCompleted: isCompleted)
      z1 (back→front) L280: if angle > 0 && isThisFlipped {  [guarded by: if angle > 0 && isThisFlipped]
```

## `typography_audit.py`

Every `.font(...)` call site: resolved family, point size, weight, and
whether it's a `RenaissanceFont` token or a raw literal. **Every literal is
flagged as a violation** — this mirrors the project's own `ui-auditor`
agent convention (`RenaissanceFont.*` is the single source of truth for
type; see CLAUDE.md).

```
python3 typography_audit.py <file.swift> [--json]
```

`.font(.system(size:))` calls attached to SF Symbol icons are included
(same modifier, same convention as `ui-auditor`) — they show up as
`family=system`, which is a useful signal on its own (icon sizes drifting
without a token) even though they aren't body text.

**Worked example** (`DiscoveryCardOverlay.swift`, abridged):

```
.font(...) call sites: 17  |  RenaissanceFont tokens: 5  |  raw literals (violations): 12

  L92: Cinzel-Bold @ 10pt weight=bold source=literal-custom text≈"DISCOVERY" 🔴 VIOLATION
  L117: EBGaramond-Regular [caption] @ 13pt weight=regular source=token text≈"Tap to discover"
  ...

━━━ 12 raw-literal violations out of 17 font call sites ━━━
```

## `line_spacing.py`

Every `.lineSpacing()` value, the resulting line height, and whether it's
in a readable band for children.

```
python3 line_spacing.py <file.swift> [--json]
```

SwiftUI's `.lineSpacing(N)` **adds** N points between lines — it is not a
multiplier. Resulting line height is estimated as:

```
lineHeight ≈ fontSize × 1.2 (NATURAL_LINE_HEIGHT_FACTOR) + lineSpacing
```

`1.2×` is a standard approximation for a serif face's own leading, **not** a
measured value for Cinzel/EBGaramond — flagged as an estimate throughout.
Flags anything with `lineHeight / fontSize` below **1.2x** or above **1.9x**.
The font paired with each `.lineSpacing()` call is the *nearest preceding*
`.font()` in source order — for text produced by a helper function, that
can be a sibling element's font rather than the true one; the tool says
this on every run, not just when it's uncertain.

**Worked example** (`DiscoveryCardOverlay.swift`):

```
  L175: .lineSpacing(6)  |  nearest font: EBGaramond-Regular [bodyMedium] @ 16pt (L174)
      estimated line height ≈ 25.2pt (ratio 1.57x of 16pt)

No resolved line-spacing/font-size pairs fall outside the readable band.
```

## `overlap_check.py` — the important one

Bounding boxes of text blocks across different layers, at a given width,
and how many points of separation are needed to clear any pair that
intersects or sits closer than `--safe-margin`.

```
python3 overlap_check.py <file.swift> [--width 320] [--height 180]
                          [--safe-margin 8] [--assumed-chars 10]
                          [--container-height 700] [--paragraph-width 380]
                          [--paragraph-chars 500]
                          [--scale-min M] [--scale-max M] [--scale-step S]
                          [--json]
```

Checks **three overlap domains**, because RAA's cards genuinely mix all three:

1. **SwiftUI ZStack siblings** with a literal `.frame(width:height:)` *and*
   an `.offset()`/`.position()`. Most card `Text` has neither — it flows in
   an auto-laid-out `VStack`, which cannot overlap by construction — so an
   empty result here is the expected common case, not a tool failure.
2. **`Canvas { context, size in ... context.draw(Text(...).font(...), at:
   CGPoint(...)) }`** diagrams — `CardVisualView.swift`'s science visuals,
   i.e. exactly "text layered over artwork." Each `drawXxx(context:,
   size:)` function is analyzed on its own (different drawing functions
   never render simultaneously — only one is selected per visual), but
   *within* one function every draw is compared against every other draw,
   because a later `guard currentStep >= N else { return }` does not hide
   earlier draws once passed — it only gates progressive reveal. The
   nearest preceding `guard` is shown per finding so you can see which step
   each text appears at.
3. **The lesson paragraph vs. `CardVisualView` boundary** in
   `KnowledgeCardsOverlay.swift` — `highlightedLessonText(card:)` (sized from
   its own content) immediately followed by `CardVisualView(...)` (sized as
   `containerHeight × <multiplier> × cardTextScale`, read live from
   `CardVisualView.swift`, never hardcoded in this tool). Both are
   auto-laid-out VStack siblings, so — like domain 1 — they cannot literally
   intersect in x/y; the real risk this domain checks is that their
   **combined height** (paragraph + the VStack's own inter-item spacing +
   the visual) outgrows the card's available height, since neither shrinks
   to make room for the other. `cardTextScale` (the "Card Text Size" slider
   in Settings, 0.8×-1.3×) scales BOTH sides of this boundary at once — the
   paragraph's font size *and* the visual's height fraction — so this domain
   **sweeps the full slider range** and reports the first value where they
   stop fitting. This sweep is the point: a single-size check would have
   missed that the collision starts at `cardTextScale=1.0`, the *default*,
   not just at the accessibility extreme (see the worked example below).

**All box math is an estimate**, stated on every run:
- `box width = character_count × fontSize × avg_char_width_factor` (a
  per-family constant in `raa_common.py`, tuned for a generic serif/display
  serif look — not measured against the actual Cinzel/EBGaramond glyphs).
- `box height = fontSize × 1.2`.
- Canvas text draws default to a **center** anchor (SwiftUI's
  `GraphicsContext.draw(_:at:anchor:)` default), so the box is centered on
  the `at:` point.
- When the drawn text is a string literal, `character_count` is exact. When
  it's a variable/interpolation (`visual.labels[i]`, `"\(Int(x))m"`), the
  real length is unknowable statically — `--assumed-chars` (default 10)
  stands in, and the finding is marked `text_is_estimated`.
- `w`/`h` in Canvas coordinate math come from `size.width`/`size.height`,
  unknown until layout — `--width`/`--height` are a stand-in (defaults
  320×180, matching `CardVisualView.swift`'s own "~180pt tall" doc
  comment). Local `let` variables built from `w`/`h` (e.g. `let reactantX =
  w * 0.2`) are resolved recursively so real diagram code — which almost
  always precomputes coordinates into named variables — actually resolves.

Position/font expressions that can't be reduced to plain arithmetic
(depend on a function argument, `@State`, etc.) are excluded from the
overlap math and listed separately, never silently skipped.

**Worked example — domains 1-2** (`CardVisualView.swift`, real finding):

```
[OVERLAP] drawChorobatesBeam: L663 "6 meters" × L678 "water channel"
    a: center=(160.0,52.0) box=62.4×18.0
    b: center=(160.0,48.0) box=93.6×18.0
    overlap: 62.4×14.0pt — needs ≥22.0pt separation to clear (incl. 8pt margin)
    guard context: a←`None`  b←`currentStep >= 2`  (both reachable simultaneously once the later guard passes)
```

**Domain 3's own estimates**, on top of domains 1-2's (stated on every run):
- `containerHeight` (real name `flippedH` in `KnowledgeCardsOverlay.swift` =
  `screenHeight × 0.80/0.85`) is a `GeometryReader` result — unresolvable
  statically. `--container-height` (default 700) stands in.
- The paragraph's wrap width and `card.lessonText.count` are likewise
  runtime values — `--paragraph-width` (default 380) and `--paragraph-chars`
  (default 500) stand in for them; real lesson paragraphs vary a lot in
  length per building.
- The visual's height-fraction multiplier (`0.55` in `CardVisualView.swift`
  at the time this was written) and `cardTextScale`'s min/max/step ARE
  parsed exactly from `CardVisualView.swift` / `GameSettings.swift` /
  `SettingsView.swift` — never hardcoded — so the sweep stays correct if
  those numbers move; the tool says so explicitly if a parse fails instead
  of silently falling back to a stale constant.

**Worked example — domain 3** (`KnowledgeCardsOverlay.swift`, real finding,
`--container-height 700 --paragraph-width 380 --paragraph-chars 500`):

```
L637 highlightedLessonText(card:) → L647 CardVisualView(...)
    paragraph font: EBGaramond-SemiBold base 18pt × cardTextScale
    lineSpacing: 5pt (L639)
    scale=0.95: font=17.1pt, 12 line(s) → paragraph≈306.2pt + spacing 12pt + visual≈365.8pt = 684.0pt vs 700pt container → gap 16.0pt
    scale=1.00: font=18.0pt, 13 line(s) → paragraph≈345.8pt + spacing 12pt + visual≈385.0pt = 742.8pt vs 700pt container → gap -42.8pt  ⚠ OVERFLOW

  ⚠ First collision at scale=1.00 (OVERFLOW) at these assumed dimensions.
```

At these assumed dimensions the collision starts at `cardTextScale=1.0` —
the slider's own default, not an accessibility extreme — and gets worse up
to `1.3`. This is an ESTIMATE (see above); it does not by itself prove the
real layout overflows, but it says exactly which assumption to check by eye
or in a render pass next.

## `hierarchy_check.py`

Maps each text run to a level (H1/H2/H3/body/caption) and checks: exactly
one H1 per card unit, no level skipped, each level strictly larger than the
one below, and consistent usage across cards.

```
python3 hierarchy_check.py <file.swift> [file2.swift ...] [--json]
```

Pass multiple files to compare the same role (e.g. a `cardFront`/
`cardBack` function appearing in more than one file) across cards.

Levels are assigned **from the resolved font at each call site**, not from
a fixed table of `RenaissanceFont` names — real card text mostly uses raw
`.font(.custom(...))` literals rather than named tokens (see
`typography_audit.py`), so a name-based table would miss most of it.
Per RAA's own convention (confirmed in `RenaissanceTheme.swift` and every
card file): **Cinzel = heading-like, EBGaramond = body-like**. Within a
"card unit" (a `private func/var cardXxx` block — how these three files are
actually structured; falls back to the whole file if none match), the
distinct Cinzel sizes found are ranked largest→smallest as H1, H2, H3, ...
"No level skipped" is checked against the *file-wide* Cinzel size ladder
(every distinct size any `RenaissanceFont` Cinzel token declares), not a
hardcoded scale.

**Known false-positive source**, stated plainly: a small Cinzel-Bold
"badge"/eyebrow label (e.g. a 10pt "DISCOVERY" tag) is still classified as
a heading level purely by family+size, which can trigger a "heading smaller
than body" flag even when the badge's small size is an intentional design
choice, not a hierarchy bug. The tool has no way to distinguish "badge" from
"heading" from source alone — use judgment on these.

**Worked example** (`DiscoveryCardOverlay.swift`, real finding):

```
[cardFront]  (L72, ...)
  Heading sizes found (largest→smallest): 18, 10
    H2 L92: Cinzel-Bold @ 10pt  text≈"DISCOVERY"
    H1 L104: Cinzel-Bold @ 18pt  text≈"<card.stationName>"
  ✓ exactly one distinct H1 text (1 run(s))
  ⚠ H1→H2 (18pt→10pt) skips file-wide heading size(s) 16, 15pt
  🔴 heading at L92 (10pt) is SMALLER than the largest body text in this unit (14pt) — hierarchy inversion
```

---

## `raa_common.py`

Shared helpers imported by all six tools — not runnable on its own:

- A brace/paren-depth-aware scanner (`scan_brackets`, `matching_close`,
  `matching_bracket_close`) that ignores string/comment contents, used to
  find the body of a `ZStack { ... }`, a `struct { ... }`, a `drawXxx(...)
  { ... }` function, or a balanced `context.draw(...)` call.
- `top_level_statements` — heuristically splits a block body into its
  direct-child statements (used to enumerate a ZStack's direct children).
- `parse_font_tokens` — parses `RenaissanceFont`'s `static let`/computed
  `static var` declarations straight out of `RenaissanceTheme.swift`, so
  every tool stays correct if the token table changes; nothing is
  hardcoded from a stale copy.
- `find_font_usages` — resolves every `.font(...)` call site in a file
  against that token table (or flags it as a raw literal/unresolved
  variable).

If `RenaissanceTheme.swift` moves or `enum RenaissanceFont` is renamed,
update `THEME_PATH` at the top of `raa_common.py`.
