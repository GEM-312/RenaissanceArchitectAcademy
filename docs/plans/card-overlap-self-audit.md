# Card Overlap Self-Audit — Make the App Measure Itself

**Date:** 2026-09-21
**Status:** Planning only. **No Swift file, no file under `tools/card-design/`, and no `.claude/agents/card-designer.md` was modified to produce this document.** The only file this branch adds is this one.
**Repo state:** branch `plan/card-overlap-self-audit` off `main` at `4f4e5f0` ("Zone order: Florence is the finale, the Botanical Garden is Padua's").

Every number below was re-derived by grep/Python against this checkout. Where the September 20 brief's number was wrong, the corrected number is used and the correction is called out inline in **§1.1**. Where an Apple API's behaviour matters and I am not certain of it, it is marked **NEEDS A SPIKE** rather than asserted.

---

## 0. Verdict

**Stop estimating text size from Swift source. Make the app report its own overlaps at runtime.**

`GraphicsContext.resolve(_:)` + `ResolvedText.measure(in:)` return the *exact* rendered size of a `Text` at the real font, real Dynamic Type setting and real device. `anchorPreference(key:value:.bounds)` returns the *exact* placed frame of a SwiftUI view. Neither is an estimate. Both are cheap. Together they cover the entire surface where Marina's complaint lives — Canvas labels and absolutely-positioned SwiftUI labels — and they produce a machine-readable fix list across all 208 cards instead of one card at a time by eye.

The static tools cannot ever do this. `overlap_check.py`'s own docstring concedes it (`overlap_check.py:27-41`: *"text box size is never measured by a renderer"*, *"Getting the true, exact resolved numbers requires a render pass"*). Its SwiftUI domain has structurally never fired on a real card (**§2.2**). Its Canvas domain is the only working part and it was pointed at 3 files while 95% of the positioned text lives in 17 others.

**Recommended sequencing, and the honest reason for it:** Phase 1 is small, self-contained, and produces real findings this week. Phase 2 is where the actual bulk of the problem is (485 positioned elements vs 117 canvas draws) and is also where the "barely visible" half of Marina's complaint gets caught. Phase 3 is the one with a real chance of not working as designed — the off-screen driver depends on `ImageRenderer` behaviour I cannot confirm from here, and this project **has no test target at all** (§4.3), so the XCTest fallback is not a fallback, it is a new Xcode target. **Do Phases 1 and 2 even if Phase 3 never ships**; they are useful standalone with a manual on-device pass.

**Effort: 3–5 working days for Phases 1+2 (confidence: medium-high). Phase 3 is 1 day if `ImageRenderer` cooperates and 3–4 days if it does not (confidence: low until the spike in §4.4 is run).**

---

## 1. What is actually there (verified at `4f4e5f0`)

### 1.1 Corrections to the September 20 brief

I was asked to re-verify the brief's numbers. Five were right, four were wrong. **Corrected numbers are used everywhere else in this document.**

| Brief said | Verified | Verdict |
|---|---|---|
| 17 `*InteractiveVisuals.swift` files, ~18,051 lines | 17 files, **18,051** lines exactly | ✅ correct |
| ~485 `.position()` calls, per-file split Colosseum 80 / Pantheon 79 / Aqueduct 62 / RomanBaths 62 / SiegeWorkshop 57 / Insula 51 / Harbor 48 / RomanRoads 44 | **485** exactly; per-file split matches; the "other nine" are Botanical Garden 1, Duomo 1, and seven at 0 | ✅ correct |
| `overlap_check.py` domain 1 requires literal `.frame()` **and** literal `.offset()`/`.position()` | Confirmed at `overlap_check.py:9-13` and `find_zstack_text_layers()` (`:295`) | ✅ correct |
| `~112 context.draw(` sites across 6 files | **117 sites across 7 files.** The brief's grep matched only the receiver spelled `context`. `AnatomyTheaterInteractiveVisuals.swift` uses `ctx.draw(` — **5 more sites in a 7th file** the brief never counted. | ❌ **corrected: 117 / 7 files** |
| *"Every one uses the `context.draw(Text(...), at: CGPoint)` form; there are no `anchor:` arguments in CardVisualView.swift… This uniformity is what makes a mechanical swap viable"* | **The premise of uniformity is false project-wide.** `CardVisualView.swift` has 0 `anchor:` args across its 59 draws (that part is right). But `MathVisualTemplates.swift` (38/38), `FlowRateVisual.swift` (9/9) and `GradientSlopeVisual.swift` (4/4) pass `anchor:` on **every** draw, and they use the `context.draw(context.resolve(x), at:, anchor:)` form, not `context.draw(Text(…), at:)`. Two of those anchors are **not** `.center`: `FlowRateVisual.swift:191` (`.topLeading`) and `GradientSlopeVisual.swift:228` (`.leading`). `WolframGeometryView.swift:641` uses a third form again (`context.draw(resolved, at:)` with a pre-resolved local). | ❌ **corrected — this changes the Phase 1 edit plan, see §3.3** |
| ~211 knowledge cards | **208.** The brief's grep for `KnowledgeCard(` caught 3 hits on `hasKnowledgeCard(` in `WorkshopMapView.swift` (`:1162`, `:2764`, `:3016`). Real constructions: `KnowledgeCard.swift` 14 (Pantheon) + `KnowledgeCardContentRome.swift` 85 + `KnowledgeCardContentRenaissance.swift` 109 = **208**. | ❌ **corrected: 208** |
| 228 `lessonText:` literals, median 641 / mean 624 / max 1617 | **228** literals (230 raw grep hits, 2 non-literal). median **643**, mean **624**, max **1617**, min 269. Median differs by 2 characters — escape-sequence handling. Immaterial; the brief's conclusion stands. | ✅ substantially correct |
| Sizing: `CardVisualView.swift:20-21`, `KnowledgeCardsOverlay.swift:59/60/647`, clamp `0.8...1.3` in `GameSettings.swift`, slider step `0.05` in `SettingsView.swift` | All confirmed verbatim: `CardVisualView.swift:20-22`, `KnowledgeCardsOverlay.swift:59`, `:60`, `:647`, `GameSettings.swift:226` (`max(0.8, min(1.3, stored))`), `SettingsView.swift:254` (`in: 0.8...1.3, step: 0.05`) | ✅ correct |
| PR #25's domain 3 is a false positive — both nodes are inside a `ScrollView(.vertical)` at `KnowledgeCardsOverlay.swift` ~L626 | Confirmed. `ScrollView(.vertical, showsIndicators: false)` at **`KnowledgeCardsOverlay.swift:626`**, comment at `:623-625` reads *"Lesson content in a ScrollView so long reading text never clips."* `highlightedLessonText(card:)` at `:637` and `CardVisualView(...)` at `:647` are both inside it. | ✅ correct — **but see §6.1: PR #25 is already closed** |

### 1.2 The two overlaps that are already proven, re-read line by line

Both survive at every canvas size, because both pairs are drawn at the same x with a fixed y delta that does not scale.

**`CardVisualView.swift` `drawScaffolding` — `:1344` and `:1349`**
```swift
guard currentStep >= 3 else { return }
context.draw(
    Text("Steps 2→3→4→5").font(RenaissanceFont.buttonSmall).foregroundColor(color),
    at: CGPoint(x: centerX, y: groundY - domeRadius - 16)
)
context.draw(
    Text("walls → coffers → concrete → dome").font(RenaissanceFont.italicSmall).foregroundColor(sepiaInk.opacity(0.5)),
    at: CGPoint(x: centerX, y: groundY - domeRadius - 4)
)
```
Same `centerX`, **12pt apart in y**, both center-anchored, both past the same guard. `RenaissanceFont.buttonSmall` is `EBGaramond-SemiBold @ 15pt, relativeTo: .body` (`RenaissanceTheme.swift:35`); `italicSmall` is `EBGaramond-Italic @ 15pt, relativeTo: .body` (`:28`). A 15pt line box is ~18pt tall, so two center-anchored boxes 12pt apart overlap by ~6pt **at default Dynamic Type** and worse at every larger size — `relativeTo: .body` means these grow with the accessibility text setting, which no static estimate models.

**`CardVisualView.swift` `drawChorobatesBeam` — `:663` and `:678`**
```swift
let dimY = beamY - 10
...
context.draw(Text("6 meters")…,     at: CGPoint(x: centerX, y: dimY - 10))    // = beamY - 20
guard currentStep >= 2 else { return }
...
context.draw(Text("water channel")…, at: CGPoint(x: centerX, y: beamY - 24))
```
Same `centerX`, **4pt apart**, both visible from `currentStep >= 2`. Two ~18pt-tall boxes 4pt apart are almost entirely on top of each other. This is the clearest single instance of the reported bug in the codebase.

### 1.3 The structure of the interactive visuals — the thing the static tools never looked at

This is the most important architectural fact for Phase 2, and it makes the phase much cheaper than 485 individual edits.

- **208 visual structs** across the 17 files (`private struct Xxx: View`), **202** of which own a `@State private var step: Int = 1`.
- All of them wrap their content in `IVTeachingContainer` (aliased per-file as `TeachingContainer`, e.g. `PantheonInteractiveVisuals.swift:64`), which takes `@Binding var step: Int` and renders `IVStepControls` — a Back/Next pager (`InteractiveVisualHelpers.swift:67-163`).
- Step counts: **180 visuals at `totalSteps: 3`, 17 at 4, 1 at 6** — **614 distinct step states** in total.
- Content is `GeometryReader { geo in ZStack { … } }` with children placed by `.position(x: w * 0.5, y: baseY - 12)` — proportional expressions, which is exactly why `overlap_check.py` domain 1 can never see them.
- Visibility is gated by `if step >= N { … }`, so **everything from step 1 through the current step is on screen simultaneously** — same accumulation semantics as the Canvas `guard currentStep >= N` chains, and the same reason overlaps appear only at the later steps.

**What the 485 `.position()` calls are attached to** (classified by walking back to the head of each view expression):

| Attached view | Count | Text-bearing? |
|---|---:|---|
| `Text` | 71 | yes |
| `FormulaText` (= `IVFormulaText`) | 64 | yes |
| `DimLabel` (= `IVDimLabel`) | 47 | yes |
| `RoundedRectangle` | 52 | no |
| `Image` | 33 | legibility only |
| `Circle` / `Rectangle` / `Ellipse` | 74 | no |
| `Slider` | 12 | no |
| closing brace of a `VStack`/`HStack`/`ZStack`/`Button` block | ~103 | mixed |
| other | ~29 | mixed |

**`IVDimLabel` and `IVFormulaText` are each defined exactly once**, in `InteractiveVisualHelpers.swift:169` and `:181`, and re-exported into all 17 files by `private typealias`. Instrumenting those two struct bodies is a **single-file, ~6-line change that covers 111 of the 485 sites**. See §4.2.

---

## 2. Why the static approach failed (so we do not rebuild it)

### 2.1 It measured the wrong thing

`overlap_check.py` computes `box width = character_count × fontSize × avg_char_width_factor` (`overlap_check.py:30`). Every term is wrong or unknowable for this codebase:

- `character_count` — when the drawn text is `visual.labels[i]` or `"\(Int(x))m"` the real length is unknowable statically; the tool substitutes `--assumed-chars` (default 10) and marks the row `text_is_estimated` (`:34-36`). On `CardVisualView.swift` **22 of 59 draws are excluded on exactly these grounds**.
- `fontSize` — every `RenaissanceFont` token in play carries `relativeTo: .body` (`RenaissanceTheme.swift:21,28,35`), so the rendered size is the literal times the user's Dynamic Type multiplier. Nothing in the source says what that is.
- `avg_char_width_factor` — a single scalar per font family (`char_width_factor()`, `:158`). EB Garamond is a proportional serif; `"Steps 2→3→4→5"` and `"walls → coffers"` at the same character count have very different advance widths, and the arrow glyphs come from a fallback font entirely.
- `w`/`h` in the position math come from `size.width`/`size.height`, unknown until layout; the tool substitutes `--width 320 --height 180` (`:37-41`) against a real `visualHeight = containerHeight × 0.55 × cardTextScale` that on an iPad at scale 1.3 is nearer 480pt.

### 2.2 Its SwiftUI domain has never fired, by construction

Domain 1 only builds a box when a ZStack child has **both** a literal `.frame(width:height:)` **and** a literal `.offset()`/`.position()` (`:9-13`). Zero of the 485 positioned elements in the interactive visuals have a literal `.position()` — they are all proportional (`w * 0.5`, `(topY + 6 + baseY) / 2`, `geo.size.height / 2`). So the domain returns nothing, and `render_text()` prints (`:386`) that the text *"flows in a VStack, which can't overlap by construction"* — about 18,051 lines of absolutely-positioned labels. The tool is not lying; it was simply never pointed at this code, and cannot see it if it is.

### 2.3 Its scope was 3 files out of 20

The `card-designer` agent (`.claude/agents/card-designer.md`) scopes the tools to `KnowledgeCardsOverlay.swift`, `DiscoveryCardOverlay.swift` and — after PR #23 carved it out and PR #25 tried to put it back — `CardVisualView.swift`. The 17 `*InteractiveVisuals.swift` files are named nowhere in the agent doc or the tool README. That is where 485 of the ~600 positioned text elements live.

---

## 3. Phase 1 — Canvas labels measure themselves

**Surface:** 117 `draw(` sites across 7 files.

| File | draws | uses `anchor:` | form |
|---|---:|---:|---|
| `Views/CardVisualView.swift` | 59 | 0 | `context.draw(Text(…), at:)`, multi-line |
| `Views/MathVisualTemplates.swift` | 38 | 38 | `context.draw(context.resolve(x), at:, anchor:)`, single-line |
| `Views/FlowRateVisual.swift` | 9 | 9 | same; **one `.topLeading`** at `:191` |
| `Views/AnatomyTheaterInteractiveVisuals.swift` | 5 | 2 | receiver is `ctx`, not `context`; `.leading` at `:351`, `.trailing` at `:367` |
| `Views/GradientSlopeVisual.swift` | 4 | 4 | same; **one `.leading`** at `:228` |
| `Views/WolframGeometryView.swift` | 1 | 0 | `context.draw(resolved, at:)` — pre-resolved local |
| `Views/SketchTeachingView.swift` | 1 | 0 | `context.draw(Text(…), at:)` |

### 3.1 The API, and why it is exact

```swift
let resolved: GraphicsContext.ResolvedText = context.resolve(text)
let size: CGSize = resolved.measure(in: CGSize(width: maxWidth, height: .infinity))
```

`resolve(_:)` binds the `Text` to *this* `GraphicsContext` — its environment, which carries the real `Font`, the real `dynamicTypeSize`, the real `displayScale` and the real locale. `measure(in:)` then returns the typeset size using the actual font metrics for the actual glyphs. There is no character count and no width factor anywhere in that path. It is the same measurement the renderer itself will use one line later when `draw` is called, so the recorded rect is the drawn rect by definition, not a model of it.

`draw(_ text: ResolvedText, at point: CGPoint, anchor: UnitPoint = .center)` takes the already-resolved value, so measuring costs one `resolve` that the draw would have performed anyway.

**Confidence: high.** `GraphicsContext.resolve(_:)`, `ResolvedText.measure(in:)` and the `ResolvedText` overload of `draw` are all iOS 15+/macOS 12+ SwiftUI, well within this project's iOS 26 / macOS 14 target.

**NEEDS A SPIKE (small):** `measure(in:)` takes a proposed size. For a single-line label `CGSize(width: .infinity, height: .infinity)` should return the unwrapped typeset size, but I have not confirmed that `.infinity` is accepted rather than producing a degenerate result. The spike is five minutes in a preview: measure `Text("walls → coffers → concrete → dome")` at `.infinity` and at `1_000_000` and compare. Use whichever is well-defined; pick a large finite number if `.infinity` misbehaves.

### 3.2 The helper

New file: **`RenaissanceArchitectAcademy/Services/Debug/CanvasAuditContext.swift`**, ~140 lines, entirely inside `#if DEBUG`. It must be registered in `project.pbxproj` — use the `/add-swift-file` skill, this project has no `PBXFileSystemSynchronizedRootGroup` so membership is explicit.

```swift
#if DEBUG
import SwiftUI

/// One recorded label draw: what was drawn, where it landed, and under which guard.
struct AuditedLabel {
    let tag: String          // "drawScaffolding#2"
    let text: String         // the literal, for the report
    let rect: CGRect         // EXACT — from ResolvedText.measure, not estimated
}

/// Per-draw-pass collector. Not thread-safe by design: a Canvas draw closure
/// runs on the main actor and one pass at a time.
@MainActor
final class CanvasAuditCollector {
    static let shared = CanvasAuditCollector()
    private(set) var labels: [AuditedLabel] = []
    var isRecording = false
    var currentPass = ""      // "pantheon-11 / step 3 / regular / 1.30"

    func begin(_ pass: String) { currentPass = pass; labels.removeAll() }
    func record(_ l: AuditedLabel) { if isRecording { labels.append(l) } }

    /// Intersect every recorded pair. Called at the end of the draw pass.
    func collisions(minOverlap: CGFloat = 1.0) -> [(AuditedLabel, AuditedLabel, CGRect)] {
        var out: [(AuditedLabel, AuditedLabel, CGRect)] = []
        for i in labels.indices {
            for j in (i + 1)..<labels.count {
                let hit = labels[i].rect.intersection(labels[j].rect)
                guard !hit.isNull, hit.width > minOverlap, hit.height > minOverlap else { continue }
                out.append((labels[i], labels[j], hit))
            }
        }
        return out
    }
}

extension GraphicsContext {
    /// Drop-in for `draw(_:at:anchor:)` that also records the EXACT drawn rect.
    /// Behaviour when not recording is byte-identical to `draw`.
    func drawAudited(_ text: Text,
                     at point: CGPoint,
                     anchor: UnitPoint = .center,
                     tag: String,
                     label: String = "") {
        let resolved = resolve(text)
        let size = resolved.measure(in: CGSize(width: 10_000, height: 10_000))
        let origin = CGPoint(x: point.x - size.width  * anchor.x,
                             y: point.y - size.height * anchor.y)
        CanvasAuditCollector.shared.record(
            AuditedLabel(tag: tag, text: label,
                         rect: CGRect(origin: origin, size: size)))
        draw(resolved, at: point, anchor: anchor)
    }
}
#endif
```

In release builds `drawAudited` does not exist, so the call sites need a `#if DEBUG` shim or — simpler and what I recommend — a **non-DEBUG `drawAudited` that just forwards to `draw`**, with only the collector compiled out. One function, no `#if` at 117 call sites.

### 3.3 The mechanical edit — and why it is three edits, not one

The brief assumed one uniform call shape. There are four, so the rewrite is four targeted passes:

- **Pass A — `CardVisualView.swift` (59), `SketchTeachingView.swift` (1).** `context.draw(\n Text(…)…,\n at: CGPoint(…)\n)` → `context.drawAudited(\n Text(…)…,\n at: CGPoint(…),\n tag: "<fn>#<n>"\n)`. Multi-line, so a line-oriented regex is not enough; the rewriter must brace-match the argument list.
- **Pass B — `MathVisualTemplates.swift` (38), `FlowRateVisual.swift` (9), `GradientSlopeVisual.swift` (4).** These already pass `context.resolve(x)`. Two options: add a `drawAudited(_ resolved: ResolvedText, …)` overload — but then `measure` has to be called on the already-resolved value, which is fine and is in fact cheaper — or unwrap back to the `Text` local. **Recommend the overload**; it is a 10-line addition and touches zero call-site semantics. The 3 non-`.center` anchors (`FlowRateVisual.swift:191`, `GradientSlopeVisual.swift:228`, plus `AnatomyTheater`'s two) then just pass through the existing `anchor:` argument, which the helper already handles in its origin math.
- **Pass C — `AnatomyTheaterInteractiveVisuals.swift` (5).** Receiver is `ctx`. Same as pass B with a different receiver name.
- **Pass D — `WolframGeometryView.swift:641`.** One site, pre-resolved local, multi-line `at:`. **Do this one by hand.**

**Do not use `sed`.** CLAUDE.md records the reason directly (the BSD-`sed` incident: a regex that failed silently and produced a diff that looked exactly like success). Write a Python rewriter at `tools/card-design/instrument_canvas_draws.py` — or better, at `scripts/instrument_canvas_draws.py`, keeping it out of the retiring directory — that brace-matches argument lists rather than matching lines.

**Verification, and this is the part that must not be skipped:**

```bash
# 1. Count before. Must be 117 across 7 files.
grep -rnE '\b(context|ctx)\.draw\(' --include=*.swift RenaissanceArchitectAcademy | wc -l

# 2. Run the rewriter in --dry-run; it prints one line per intended edit.
python3 scripts/instrument_canvas_draws.py --dry-run   # expect exactly 116 (117 minus the hand-done Wolfram site)

# 3. Apply, then count again. draw( must drop to 0 (bar the one inside the helper),
#    drawAudited( must be 117.
grep -rnE '\b(context|ctx)\.draw\(' --include=*.swift RenaissanceArchitectAcademy | wc -l   # expect 1 (helper only)
grep -rn 'drawAudited(' --include=*.swift RenaissanceArchitectAcademy | wc -l                # expect 117

# 4. The real check: line counts must be additive-only, no deletions beyond the
#    renamed lines, and no file touched that shouldn't be.
git diff --numstat
#    expect exactly 7 rows + the new helper; for each, deletions == the draw count
#    in that file (the renamed line) and insertions == deletions + the tag lines.

# 5. Build. There is no unit-test suite in this project; the build IS the check.
xcodebuild -project RenaissanceArchitectAcademy.xcodeproj \
           -scheme RenaissanceArchitectAcademy -destination 'platform=macOS' \
           build > /tmp/canvas-audit-build.log 2>&1; tail -40 /tmp/canvas-audit-build.log
```

Step 4 is the one that catches a silent partial rewrite: if `--numstat` shows a file with 0 changes that grep said had 38 draws, the rewriter skipped it.

### 3.4 Done looks like

Running the Pantheon "Scaffolding Around Dome" card (card 11) and the Aqueduct "Chorobates" card (card 2) with `isRecording = true` prints exactly the two known collisions from §1.2 with real point values, plus whatever else the other 57 draws turn up. If it prints those two, the mechanism is correct; if it prints zero, it is not wired up.

### 3.5 Risks

- **Overlap is sometimes intentional.** A unit suffix deliberately tucked against a number, a label sitting on a translucent plate. Expect a false-positive rate; the fix is an `allowedOverlaps` set keyed by tag pair, not a looser threshold. Budget half a day for triage of the first full run.
- **`measure(in:)` with an unbounded proposal** — see the spike in §3.1.
- **Tag churn.** `"drawScaffolding#2"` breaks if a draw is inserted earlier in the function. Prefer a stable tag derived from the literal text where there is one, falling back to the index.
- **The helper changes draw order semantics if someone reorders.** It does not — `draw` is still called in the same place with the same arguments — but it is worth a reviewer's eye on the first file's diff.

### 3.6 Effort

**1 day.** Helper 2h, rewriter + the four passes 3h, verification and build 1h, first-run triage 2h. **Confidence: high.** Nothing here depends on an API I am unsure of except the trivial `measure(in:)` proposal question.

---

## 4. Phase 2 — Positioned SwiftUI elements measure themselves

**Surface:** 485 `.position()` sites across 8 files (the 17 interactive-visuals files, of which 8 have any positions at all). This is where the bulk of the problem is, and where "barely visible" gets caught.

### 4.1 The API, and why it is exact

```swift
extension View {
    func auditFrame(_ tag: String) -> some View {
        anchorPreference(key: AuditFrameKey.self, value: .bounds) { anchor in
            [AuditFrameEntry(tag: tag, anchor: anchor)]
        }
    }
}
```

`.bounds` produces an `Anchor<CGRect>` — an opaque token, *not* a rect. It becomes a rect only when a `GeometryProxy` resolves it: `proxy[entry.anchor]` returns the element's frame **in that proxy's coordinate space**, after every layout modifier in between has been applied. That is the whole point: `.position()` is a layout modifier, so the resolved rect is the *placed* rect, with the real intrinsic size the label actually took at the real font.

Collection happens once, at the container:

```swift
.overlayPreferenceValue(AuditFrameKey.self) { entries in
    GeometryReader { proxy in
        Color.clear.onAppear {
            let rects = entries.map { ($0.tag, proxy[$0.anchor]) }
            AuditReporter.shared.report(pass: currentPass,
                                        container: proxy.size,
                                        rects: rects)
        }
    }
}
```

**Confidence: high on the mechanism** — `anchorPreference`/`overlayPreferenceValue` is the standard SwiftUI idiom for exactly this, and it is used specifically because it survives intervening layout.

**NEEDS A SPIKE (the one that decides the phase):** I have not verified in *this* codebase that a preference set **inside** a leaf view's body (e.g. inside `IVDimLabel.body`) resolves to the frame *after* the `.position()` that the caller applies **outside** the component. My understanding of anchor resolution says yes — anchors are resolved against the reader's coordinate space at read time, and the leaf's geometry at that point already includes the caller's `.position()`. But the whole §4.2 cost saving rests on it. **Spike: put `.auditFrame("x")` inside `IVDimLabel.body`, place one at `.position(x: 100, y: 50)` in a 200×200 container, and print the resolved rect. If its centre is (100, 50), the cheap path works. If it is the component's pre-position origin, fall back to instrumenting at the call sites.** 30 minutes.

### 4.2 The cheap path — 111 sites for a 2-struct change

`IVDimLabel` (`InteractiveVisualHelpers.swift:169`) and `IVFormulaText` (`:181`) are each defined once and typealiased into all 17 files. If the spike above passes, adding `.auditFrame(…)` to those two bodies instruments **47 + 64 = 111 call sites by editing one file**. The remaining text-bearing sites are the 71 bare `Text` and the ~103 container-block positions, which need per-site tagging.

**Do not instrument the 74 `Circle`/`Rectangle`/`Ellipse` sites for overlap.** Diagram geometry is *supposed* to overlap — an arrow over a column, a dimension line crossing a wall. Overlap detection is for text-vs-text and text-vs-control. Shapes matter only for the clipping and legibility checks below.

### 4.3 The "barely visible" half — three additional checks, now possible

Once true frames exist, all three are trivial rect arithmetic and none of them was reachable with the static tools:

1. **Clipped or out of bounds.** `IVTeachingContainer` applies `.clipShape(RoundedRectangle(cornerRadius: 10))` (`InteractiveVisualHelpers.swift:90`) and insets its content by `.padding(.horizontal, 10) .padding(.top, 8) .padding(.bottom, 42)` (`:86-88`). Any label whose resolved rect is not fully inside the padded content rect is being clipped *right now*, silently. Flag `rect ⊄ contentRect`.
   **This check alone probably explains a large share of the "barely visible" complaints**, especially the bottom 42pt where the step controls and their parchment gradient sit.
2. **Below minimum legible size.** `RenaissanceFont.ivLabel`/`ivFormula` plus the per-call `fontSize:` overrides on `IVDimLabel`/`IVFormulaText` mean some labels render small. Flag any text rect under a height threshold (start at 11pt rendered and tune with Marina — this is a *report* threshold, not a design change).
3. **Low contrast (optional, do last).** Several labels are drawn at `.opacity(0.4)`–`0.6` over the parchment fill and the `IVBlueprintGrid`. WCAG contrast needs a resolved foreground and background colour; the foreground is knowable from the style, the effective background under a grid line is not, without sampling the rendered image. **Defer this to Phase 3**, where an `ImageRenderer` pass would give a real `CGImage` to sample. Do not block Phase 2 on it.

### 4.4 Sequencing — one file first, as asked

**Do `PantheonInteractiveVisuals.swift` alone first (79 positions, 14 structs, 12 with a step binding) and stop.** Reasons: it is the largest single file bar Colosseum; `docs/card-visual-audit.md` already names two specific Pantheon complaints (card 4 *"28 Rows of Coffers: Overlapping elements"*, card 11 *"Scaffolding Around Dome: Small dome, hard to read"*), so there is prior-art ground truth to check the harness against; and Pantheon card 11's Canvas twin is one of the two proven Phase 1 findings, so both mechanisms can be sanity-checked on the same card.

Marina reviews that one file's diff and the report it produces. Only then roll out to Colosseum (80), Aqueduct (62), RomanBaths (62), SiegeWorkshop (57), Insula (51), Harbor (48), RomanRoads (44) — and Botanical Garden and Duomo, 1 each.

### 4.5 Verification

```bash
# per-file, before and after
grep -c '\.position(' RenaissanceArchitectAcademy/Views/PantheonInteractiveVisuals.swift   # 79
grep -c '\.auditFrame(' RenaissanceArchitectAcademy/Views/PantheonInteractiveVisuals.swift # target count for text-bearing sites only
git diff --numstat   # one row; insertions == sites tagged, deletions == 0 if tags are added on new lines
```
Then build (`xcodebuild … > /tmp/log 2>&1`) and run the card on an iPad simulator with recording on.

### 4.6 Risks

- **The anchor spike (§4.1) fails.** Then the cheap 111-for-one-file path is gone and Phase 2 becomes ~290 individual call-site edits. That roughly doubles the phase. This is the single biggest schedule risk in the plan and it is resolvable in half an hour — **run the spike before committing to an estimate.**
- **Preference plumbing is per-container, not global.** Each of the 202 step-bearing visual structs would need the `.overlayPreferenceValue` collector. But they all go through `IVTeachingContainer`, so **put the collector in `IVTeachingContainer.body` once** — one edit, 198 containers covered. Confirm this holds for the handful of visuals that do not use the container.
- **`onAppear` inside the overlay may not re-fire on step change.** The preference value changes when `step` changes, but `onAppear` fires once. Use `.onPreferenceChange` or `.onChange(of: entries)` instead, or read inside the `GeometryReader` body via a side-effecting `Color.clear.task(id:)`. **NEEDS A SPIKE** — this is a known-fiddly corner of SwiftUI and getting it wrong means the report only ever shows step 1.
- **Touching 8 files × dozens of sites is a large diff over code Marina has hand-tuned.** Every added line must be a pure `.auditFrame("tag")` append. CLAUDE.md's rule stands: no reformatting, no reordering, no "while I'm here".

### 4.7 Effort

**2–3 days if the anchor spike passes** (helper + preference key 3h; `IVTeachingContainer` collector 2h; the two shared label structs 1h; Pantheon file + review cycle 1 day; remaining 7 files 1 day). **4–6 days if it fails.** **Confidence: medium** — the range is wide and it is wide because of one unverified API behaviour, not because the work is vague.

---

## 5. Phase 3 — The driver, and an honest assessment of whether it can exist

**Goal:** walk every card × every step × both size classes × every `cardTextScale` stop, render off-screen, collect every report, emit one table.

**Combinatorics, from the real numbers:** 208 cards, 614 distinct step states across the 198 interactive containers, × 2 size classes × 11 scale stops (0.8 to 1.3 step 0.05) = **~13,500 renders**. At even 20ms each that is under five minutes. Volume is not the problem.

### 5.1 The problem is that the app cannot currently be driven

Three hard blockers, all verified:

1. **`step` is `@State private`.** Every one of the 202 step-bearing structs owns its own `@State private var step: Int = 1` (e.g. `PantheonInteractiveVisuals.swift:74`). `IVTeachingContainer` takes a `@Binding`, but the binding's *source* is private to the child. **Nothing outside can set it.** Options: (a) an `EnvironmentValue` `\.auditForcedStep` that each struct's `step` initialiser reads — a one-line change in 202 places, mechanically applicable but a real diff; (b) drive it by tapping `IVStepControls`' Next button, which needs a UI test; (c) an `#if DEBUG` initialiser parameter. **Recommend (a)** and instrument it in the same mechanical pass as Phase 2 so it is one review, not two.
2. **There is no test target.** `project.pbxproj` has exactly one `productType`, `com.apple.product-type.application`. No XCTest bundle, no UI-test bundle. So "or an XCTest / snapshot approach is required instead" is not a fallback that costs an afternoon — it is **creating and maintaining a new Xcode target**, plus a scheme, plus CI that does not exist yet.
3. **Cards are static data, but routing is a 17-branch `if/else` chain.** `CardVisualView.body` (`:28-46+`) dispatches by `XxxInteractiveVisuals.hasInteractiveVisual(for:)`. A driver can enumerate all 208 `KnowledgeCard`s from the content files and hand each `card.visual` to `CardVisualView`, so enumeration is easy; it just has to accept whatever the chain returns.

### 5.2 Can `ImageRenderer` do it? — **I do not know, and I will not assert that it can.**

`ImageRenderer` (iOS 16+, `@MainActor`) renders a SwiftUI view to a `CGImage`/`UIImage` off-screen. What I can say with confidence: the view's `body` is evaluated and laid out, so a `Canvas`'s draw closure **does** run, which means Phase 1's collector fires. What I genuinely cannot confirm from here:

- **Do `PreferenceKey` reductions and `overlayPreferenceValue` readers run during an `ImageRenderer` pass?** Preferences are a layout-phase mechanism and layout does happen, so probably yes — but "probably" is not good enough to plan a day around, and `onAppear`/`task` lifecycle in particular is known to behave differently off-screen.
- **Can `@State` be advanced between renders?** `ImageRenderer` holds a `content` view; re-assigning it re-renders, but `@State` belongs to the view's identity and may be re-initialised (giving always step 1) or preserved (giving a stuck value). Either failure mode is silent. This is exactly why blocker 1's environment-value approach is the right design — it makes step an *input* rather than internal state, which sidesteps the question.
- **Does `.environment(\.horizontalSizeClass, .compact)` on the rendered content actually propagate?** Size class is normally supplied by the hosting environment, not the view.

**NEEDS A SPIKE — and this spike decides the phase.** Half a day: render one `CardVisualView` through `ImageRenderer` with the Phase 1 collector on, assert it reports; add a Phase 2 `.auditFrame` and assert the preference reader fires; force two different steps via environment and assert two different reports. If all three pass, Phase 3 is ~1 day of driver code. **If the preference reader does not fire off-screen, Phase 3's Phase-2 half needs a hosted view instead** (`UIHostingController` in a real, off-screen `UIWindow`, sized and laid out), which is more code and more fragile but is a known-working technique. Snapshot-test libraries exist for precisely this reason.

### 5.3 The output table

One CSV/TSV written to the simulator's Documents directory, one row per collision:

| column | source |
|---|---|
| `card_id` | `KnowledgeCard.id` |
| `card_title` | for cross-referencing `docs/card-visual-audit.md` |
| `visual` | `CardVisual` kind, e.g. `force/scaffolding` |
| `step` | 1…6 |
| `size_class` | compact / regular |
| `scale` | 0.80…1.30 |
| `element_a`, `element_b` | the two tags |
| `text_a`, `text_b` | the literals, so a row is readable without opening Xcode |
| `overlap_w`, `overlap_h` | points |
| `kind` | `overlap` / `clipped` / `too-small` |

Sorted by `overlap_h × overlap_w` descending, the first page of that table *is* the fix list. **Done = re-running the driver after the fixes produces zero rows**, and that is a check anyone can run, which is the entire point of the exercise.

### 5.4 How this maps back onto `docs/card-visual-audit.md`

That file (158 lines) is per-card, hand-written, and mixes two different kinds of complaint: *"Overlapping elements"* / *"Small dome, hard to read"* (Pantheon 4 and 11) are **defects this harness detects mechanically**; *"Should Be: Tap coffers to remove them, weight counter decreases"* is a **design wish the harness has nothing to say about**.

The right relationship is: **add a `Detected` column to `card-visual-audit.md`**, populated from the driver's table by card title, and let the Problem column keep its human judgement. Where the harness finds nothing on a card the audit flagged as overlapping, that is information too — either the complaint was about the design wish, or the harness has a gap. Do **not** replace the audit file with generated output; it carries intent the table cannot.

### 5.5 Effort

**1 day if the §5.2 spike passes cleanly; 3–4 days if the hosted-view route is required; add ~1 day if a test target has to be created and wired into a scheme.** **Confidence: low** until the spike runs. I would not quote Marina a Phase 3 date before that half-day is spent.

---

## 6. Dispositions

### 6.1 PR #25 — **already closed; no action needed, and closing it was right**

The brief asked me to recommend closing it. Checking the actual state first: **PR #25 was closed unmerged on 2026-09-20 at 21:58 UTC**, the same day as the session that produced the brief. So the recommendation is already executed. Recording *why*, for the file:

Its domain 3 compares `highlightedLessonText(card:)` + `CardVisualView` combined height against an assumed 700pt container and reports `⚠ OVERFLOW` from `cardTextScale = 1.00` upward. Both nodes are inside `ScrollView(.vertical, showsIndicators: false)` at `KnowledgeCardsOverlay.swift:626`, whose own comment at `:623-625` says *"Lesson content in a ScrollView so long reading text never clips"* — and "Done Reading" is deliberately pinned outside it. Content taller than the container is the designed behaviour, not a defect. Neither the PR's code nor its README mentions `ScrollView` anywhere.

It compounds that with an assumed 500 characters of lesson text against a verified median of **643** (mean 624, max 1617) across 228 literals, so the check would fire on essentially every card at essentially every scale. A check that reports a defect on 208 of 208 cards, for behaviour the code comment says is intentional, is not a check. **If any part of it is worth keeping it is `find_scale_range()` and `find_visual_height_multiplier()`, which parse real constants out of `GameSettings.swift`/`SettingsView.swift`/`CardVisualView.swift` and were correct** — the Phase 3 driver needs those same constants and can lift that ~40 lines rather than re-deriving them.

### 6.2 `tools/card-design/` — **keep four, retire one, fold nothing**

| Tool | Disposition | Reason |
|---|---|---|
| `typography_audit.py` | **Keep** | Token-vs-raw-literal is a pure source question. A renderer cannot answer it; a parser answers it exactly. It found real violations (11/44 in `KnowledgeCardsOverlay.swift`, 7/66 in `CardVisualView.swift`). |
| `hierarchy_check.py` | **Keep** | Heading-level consistency across files is a source-level question with a known false-positive mode (badges read as headings) that the tool already declares. |
| `line_spacing.py` | **Keep** | `.lineSpacing()` values are literals in source. |
| `count_layers.py` | **Keep** | ZStack depth and z-order are structural facts, read exactly. |
| `measure_card.py` | **Keep** | Its honest behaviour — resolving `Spacing.md`-style constants, reporting a ternary as *both* values, refusing to guess `GeometryReader` output — is genuinely useful orientation. |
| `overlap_check.py` | **Retire for overlap detection.** Do not delete the file; add a header block saying overlap is now measured at runtime, point at this plan and at the Phase 3 table, and stop running it for overlap questions. | Domain 1 is structurally incapable (§2.2). Domain 2 is superseded by an exact measurement of the same draws. Deleting it loses the documented reasoning about *why* estimation failed, which is worth keeping where the next person will find it. |

**Do not fold the keepers into the new harness.** They answer source-level questions and run in milliseconds without a simulator; the harness answers render-level questions and needs a device. Different questions, different tools, and merging them would make the fast checks slow.

### 6.3 `.claude/agents/card-designer.md` — **rewrite the scope and the tool list, keep the agent**

The agent's core value — *"give her precise measurements instead of vibes"*, plus the discipline of reading each cited `file:line` before reporting — is right and should survive. Three things are wrong with it as written:

1. **Its file scope is three files.** It names `KnowledgeCardsOverlay.swift`, `DiscoveryCardOverlay.swift` and `CardVisualView.swift`. It does not mention the 17 `*InteractiveVisuals.swift` files, which hold 485 of the ~600 positioned text elements. Add them.
2. **It instructs the agent to run `overlap_check.py` "whenever the complaint could plausibly be a layering/overlap issue"** — the one tool that cannot answer that question on this codebase. Replace with: run the Phase 3 harness table if one exists; if not, say so and read the source at the cited lines by hand.
3. **It carries dead history.** The PR #23 / PR #25 back-and-forth about whether `CardVisualView.swift` is in scope is settled, and PR #25 is closed. Collapse it to a statement of current scope.

**Do this edit in a separate PR after Phase 1 lands**, not in this plan branch — the brief explicitly scopes this branch to the plan document only, and the agent doc should describe tooling that exists rather than tooling that is planned.

---

## 7. Honest summary of effort and confidence

| Phase | Work | Effort | Confidence | What would blow it up |
|---|---|---|---|---|
| Spikes (do these first) | `measure(in:)` proposal; anchor-through-`.position()`; preference re-fire on step change | **0.5 day** | high that half a day is enough | — |
| 1 — Canvas | helper + 4 rewrite passes over 117 sites in 7 files + verification + triage | **1 day** | **high** | nothing significant |
| 2 — SwiftUI positions | modifier + `IVTeachingContainer` collector + 2 shared label structs + Pantheon + 7 more files | **2–3 days** | **medium** | anchor spike fails → 4–6 days |
| 3 — Driver | step-as-environment in 202 structs + enumerate 208 cards + `ImageRenderer` loop + CSV | **1 day** or **3–4 days** | **low** | `ImageRenderer` can't drive preferences/state → hosted view; no test target exists |
| Fix work itself | driven by the table; unknown until the table exists | **not estimated** | — | this is deliberately not estimated; estimating a fix list before generating it is exactly the guessing this plan replaces |

**Phases 1+2, which are the useful-standalone part: 3–5 days including spikes.** Phase 3 should not be quoted until its spike runs.

**What this plan does not do:** it does not fix a single overlap. It builds the instrument that produces the fix list. That is the right order — the current state is that nobody knows how many overlaps there are, and 208 cards × up to 6 steps × 2 size classes × 11 scales is not a thing anyone is going to eyeball.
