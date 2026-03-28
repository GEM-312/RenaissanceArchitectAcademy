---
description: Scan all View files for UI/UX design rule violations (spacing, fonts, sizing, colors, anti-patterns)
---

# UI/UX Audit Agent

You are a UI/UX auditor. Scan ALL SwiftUI View files in this project and find violations of the design rules defined in `.claude/commands/ui-review.md`.

## Rules Reference

The project uses:
- **8pt grid**: All spacing must be multiples of 4pt (4, 8, 12, 16, 20, 24, 32, 40). Use `Spacing.*` tokens.
- **Type scale**: Minimum 9pt. Scale: 9, 10, 11, 13, 15, 17, 18, 22, 28pt. Use `RenaissanceFont.*` tokens.
- **Touch targets**: Minimum 44×44pt for tappable elements.
- **Fill space**: Primary content should use 50-70% of container. Never leave 30%+ empty.
- **Theme colors only**: Use `RenaissanceColors.*`, never raw `Color(red:...)` in View files.
- **No anti-patterns**: No nested ScrollViews, no `.padding()` without direction, minimize `.position(x:y:)`.

## Instructions

Launch 3 parallel agents to scan the codebase. Each agent searches the Views directory:
**Path:** `RenaissanceArchitectAcademy/RenaissanceArchitectAcademy/Views/`

### Agent 1: Spacing + Typography
Search for:
1. **Magic number padding** — `padding` with raw numbers NOT multiples of 4 (e.g., padding(5), padding(7), padding(10), padding(13), padding(15)). Valid values: 4, 8, 12, 16, 20, 24, 32, 40. Use Grep for `.padding` with content mode to see the values.
2. **Magic number spacing** — `spacing:` with values not multiples of 4 (e.g., spacing: 3, spacing: 5, spacing: 6, spacing: 7, spacing: 10, spacing: 14).
3. **Font sizes under 9pt** — `size:` followed by a number less than 9.
4. **Font sizes not on scale** — Custom font sizes that aren't 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 20, 22, 24, 28 (allow some flexibility for Canvas/SpriteKit code).

For each finding, report: `file:line — what was found → what it should be`

**Exclude from results:**
- Files in `Services/Styles/` (these define the tokens)
- SpriteKit scene files (CityScene, WorkshopScene, ForestScene, CraftingRoomScene, GoldsmithScene — different coordinate system)
- Comments and string literals

### Agent 2: Sizing + Colors
Search for:
1. **Hardcoded frame widths** — `.frame(width:` with a raw number > 50. Flag if not using `.infinity` or a computed value.
2. **Undersized containers** — `* 0.` followed by a number < 0.4 (e.g., `* 0.35`, `* 0.25`) — may indicate undersized primary content.
3. **Raw Color() usage** — `Color(red:` or `Color(` with RGB values in View files. These should use RenaissanceColors tokens.
4. **Raw Color.name** — `Color.blue`, `Color.red`, `Color.green`, `Color.orange` in View files (not theme colors).

For each finding, report: `file:line — what was found → suggested fix`

**Exclude from results:**
- `RenaissanceColors.swift` and `RenaissanceTheme.swift` (they define colors)
- `PantheonInteractiveVisuals.swift` (visual drawing code uses raw colors intentionally for science diagrams)
- `EditorBottomPanel.swift` and `EditableModifier.swift` (debug-only editor)
- Color usage inside `#if DEBUG` blocks

### Agent 3: Anti-patterns + Touch Targets
Search for:
1. **Hardcoded .position()** — `.position(x:` outside of GeometryReader context. Position-based layout breaks on different screen sizes.
2. **Nested ScrollViews** — A ScrollView inside another ScrollView (causes gesture conflicts).
3. **Ambiguous padding** — `.padding()` with no direction argument and no specific value (applies all sides with system default — not intentional).
4. **Small touch targets** — `.frame(width:` or `.frame(height:` values < 44 on elements that appear to be buttons (look for `Button` or `.onTapGesture` nearby).
5. **Missing minimumScaleFactor** — `Text(` with `.lineLimit(1)` but no `.minimumScaleFactor` (text will truncate instead of shrink).

For each finding, report: `file:line — what was found → suggested fix`

**Exclude from results:**
- SpriteKit files (different layout system)
- Debug/editor files

## Output Format

After all 3 agents return, compile the full report. Categorize each violation:

- **CRITICAL** (🔴): Font < 9pt, touch target < 44pt, nested ScrollViews
- **WARNING** (🟡): Magic number spacing, hardcoded widths > 100pt, raw Color() in Views, undersized containers
- **INFO** (🔵): Magic number spacing that's close to a valid value (e.g., 10 → 8 or 12), ambiguous padding, missing minimumScaleFactor

Print the report in this format:
```
━━━ UI/UX AUDIT REPORT ━━━
Scanned: [N] files
Date: [today]

🔴 CRITICAL ([count])
  [Category]: [file]:[line] — [finding] → [fix]

🟡 WARNING ([count])
  [Category]: [file]:[line] — [finding] → [fix]

🔵 INFO ([count])
  [Category]: [file]:[line] — [finding] → [fix]

━━━ Total: [N] critical, [N] warnings, [N] info ━━━
```

Sort each section by file name, then line number. Deduplicate — don't report the same line twice.

After the report, suggest the TOP 3 files that need the most attention (most violations).
