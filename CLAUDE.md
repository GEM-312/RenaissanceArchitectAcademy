# Claude Memory - Renaissance Architect Academy

## Project Overview
Educational city-building game where students solve architectural challenges across 13+ sciences. Leonardo da Vinci notebook aesthetic with watercolor + blueprint style.

**Developer:** Marina Pollak

## Tech Stack
- **SwiftUI + SpriteKit** (migrated from Unity Feb 2025)
- Art: OpenArt (mixed models, incl. a Midjourney mix)
- GitHub: https://github.com/GEM-312/RenaissanceArchitectAcademy
- Target: iOS 26+, macOS 14+

## 17 Buildings

### Ancient Rome (8)
| # | Building | Sciences | Quiz | Sketching |
|---|----------|----------|------|-----------|
| 1 | Aqueduct | Engineering, Hydraulics, Math | Yes | Phase 1 |
| 2 | Colosseum | Architecture, Engineering, Acoustics | Yes | Phase 1 |
| 3 | Roman Baths | Hydraulics, Chemistry, Materials | Yes | No |
| 4 | Pantheon | Geometry, Architecture, Materials | No | Phase 1 |
| 5 | Roman Roads | Engineering, Geology, Materials | No | No |
| 6 | Harbor | Engineering, Physics, Hydraulics | No | No |
| 7 | Siege Workshop | Physics, Engineering, Math | No | No |
| 8 | Insula | Architecture, Materials, Math | No | No |

### Renaissance Italy (9)
| # | City | Building | Sciences | Quiz | Sketching |
|---|------|----------|----------|------|-----------|
| 9 | Florence | Duomo | Geometry, Architecture, Physics | Yes | Phase 1 |
| 10 | Florence | Botanical Garden | Biology, Chemistry, Geology | No | No |
| 11 | Venice | Glassworks | Chemistry, Optics, Materials | No | No |
| 12 | Venice | Arsenal | Engineering, Physics, Materials | No | No |
| 13 | Padua | Anatomy Theater | Biology, Optics, Chemistry | No | No |
| 14 | Milan | Leonardo's Workshop | Engineering, Physics, Materials | Yes | No |
| 15 | Milan | Flying Machine | Physics, Engineering, Math | No | No |
| 16 | Rome | Vatican Observatory | Astronomy, Optics, Math | Yes | No |
| 17 | Rome | Printing Press | Engineering, Chemistry, Physics | No | No |

## Game Systems

City Map, Workshop, Sketching and Onboarding notes live in `CLAUDE.md` files inside `Views/SpriteKit/`, `Views/Sketching/` and `Views/Onboarding/` — they load when you work in those folders.

### Lesson System (Read to Earn) — ALL 17 BUILDINGS COMPLETE
- Paged lesson experience: readings → fun facts → questions → fill-in-blanks → environment prompts
- Models: `BuildingLesson.swift` defines section types; `LessonContent.swift` routes by building name
- Content split across 3 files: `LessonContent.swift` (Pantheon), `LessonContentRome.swift` (7), `LessonContentRenaissance.swift` (9)
- Each lesson: ~18-22 sections, 3 sciences per building, math questions with progressive hints
- Lookup: `LessonContent.lesson(for: buildingName)` — returns `BuildingLesson?`
- Vocabulary: `NotebookContent.vocabularyFor(buildingName:)` — 6 terms per building (96 total + 8 Pantheon)
- Notebook split: `NotebookContentRome.swift` (7 buildings), `NotebookContentRenaissance.swift` (9 buildings)
- Environment prompts link to `.workshop` and `.forest` destinations
- +10 florins awarded on lesson completion

### Challenge System
- Question types: multipleChoice, dragDropEquation, hydraulicsFlow
- 6 buildings have quiz content (see table above)
- Lookup: `ChallengeContent.interactiveChallenge(for: buildingName)`
- Uses Pow library for celebration effects

### Material Puzzle (MaterialPuzzleView)
- Match-3 game: 6x6 grid, swap adjacent tiles, collect chemical elements
- 3 formulas: limeMortar, concrete, glass (mapped per building)
- Gravity, auto-reshuffle, distractor elements

### GameTopBarView
- Shared nav bar across City Map, Workshop, Crafting Room
- Nav buttons → `onNavigate(SidebarDestination)` callback
- Building progress strip (green=complete, ochre=sketched, gray=locked)

## Art Asset Pipeline (OpenArt)
Art is generated in OpenArt (mixed models incl. Midjourney) and exports are huge — **always resize before adding**. Full procedure (sips sizes, imageset + working-folder conventions) lives in the **`/add-art-asset`** skill; animated GIF/video → sprite frames lives in **`/extract-frames`**.

## Roadmap
Open work lives on GitHub Project board #9 (`gh project item-list 9 --owner GEM-312 --limit 100`), not here.

Durable constraints (not just TODOs):
- **Re-enable onboarding skip** — uncomment the check in `ContentView` once onboarding is finalized.
- **Image Playground**: NO people/names/non-English — only objects, scenes, animals (see memory).

## Key Architecture Patterns
- **MVVM**: Views observe ViewModels via `@ObservedObject` (shared) or `@StateObject`
- **SpriteKit + SwiftUI**: SpriteView bridges SKScene into SwiftUI; callbacks for communication
- **Platform conditionals**: `#if os(iOS)` / `#else` for UIKit vs AppKit (PlatformColor typealias in CityScene.swift)
- **Shared ViewModel**: ContentView owns CityViewModel, passes to child views
- **Editor Mode REQUIRED for ALL scenes/views**: Every scene/view with positioned elements MUST have DEBUG editor mode. Press E to toggle, drag to reposition, dumps positions to console. SpriteKit: `SceneEditorMode`. SwiftUI: `#if DEBUG` + DragGesture.
- **Camera pattern for SpriteKit**: `.aspectFill`, zoom 0.5-3.5, `fitCameraToMap()`, `clampCamera()` with padding.
- **Frame animations play ONCE, never loop**: All Timer-based frame animations (avatars, backgrounds, etc.) must play through once and stop — do NOT use `% frameCount` to loop. Stop the timer when the last frame is reached.

## Available Agent Skills (Auto-Activate)

Five user-level SwiftUI/Apple-platform skills are installed at `~/.claude/skills/` and auto-activate when relevant. Use them as the primary reference for generic Swift/SwiftUI/SwiftData/concurrency/security questions — this CLAUDE.md is for project-specific rules ONLY (decisions, file refs, past bugs, counter-defaults).

When a skill's generic guidance conflicts with CLAUDE.md project rules, **CLAUDE.md wins** (project decisions, history, and file refs are non-negotiable).

## MANDATORY Rules
- **BE 100% HONEST about every status, estimate, and outcome.** No softening, no aspirational claims dressed as facts, no hidden mistakes. If a build failed, say it failed. If a commit's message claimed something the edit didn't include, surface it and fix it (don't paper over). If an estimate is wrong, correct it openly the moment you realize. End-of-task summaries describe what actually shipped, not what was attempted. Push back on weak approaches with reasoning rather than acquiescing to keep things smooth. Trust depends on accurate signal; polite lies cost real hours of misallocation later.
- **NEVER read, edit, write, or otherwise access `RenaissanceArchitectAcademy/Services/APIKeys.swift`** — by Read, Edit, Write, Bash (`cat`, `grep`, `head`, `tail`, `less`, `xxd`, `od`, or any other reader), or any indirect means. The file holds secrets. Read/Edit/Write are denied at the harness level in `.claude/settings.json`; this rule covers every other channel. If you need to know whether the proxy is configured, infer it from `WorkerClient.isConfigured` callers — not from the file. For token rotations: Marina runs them manually outside Claude Code.
- **NEVER inline a secret value into a Bash command line.** No `PROXY_TOKEN="<hex>" node script.js`, no `curl -H "Authorization: Bearer <key>"` with the literal key, no environment-variable assignments where the value is the real secret. If a command needs a secret: (1) ask Marina to `export VAR=...` in her shell once, or (2) `export VAR=$(cat ~/path/to/gitignored-file)`, then run the **bare** command with no secret in the string. Reason: Claude Code's permission system saves "Always allow" patterns as the literal command string — any secret inlined into the command leaks into `.claude/settings.local.json` permanently. Past incident: May 7 2026, a Claude session inlined `PROXY_TOKEN="4dbd…"` into a generate-sfx.mjs call; Marina clicked Always allow; token persisted in settings.local.json line 33 until discovered May 21.
- **NEVER change design, colors, sizes, layout, or visual appearance unless Marina specifically asks for it.** Fix only what is requested. If you think a design change would help, ASK FIRST — do not just do it.
- **ALWAYS read the FULL file before editing it.** Never edit a file based on memory, summaries, or assumptions. Use the Read tool on every file you are about to modify, every single time, no exceptions. If the file is large, read it in chunks until you have seen all relevant sections. Failure to do this causes wrong edits, missed context, and broken code.
- **ALWAYS read related files before making cross-file changes.** If a change touches callbacks, state, or UI across multiple files (e.g. a Scene + its MapView wrapper), read ALL of them first.

## Teaching System (PROACTIVE)
- **ALWAYS teach while coding** (proactively — new pattern, avoided pitfall, bug fix, or non-trivial logic triggers a short teaching moment). The full mechanics (green-title format, CONCEPT→STEP→IN OUR CODE→KEY TAKEAWAY structure, `Teaching.md` append format, MIT-professor style) live in the **`/teach`** skill. Use `/teach [topic]` for a lesson on demand.

## Notes
- Marina prefers direct fixes over long explanations
- Teach concepts as you go when making changes — use the Teaching System above
- Always push to GitHub after significant changes

## Karpathy Coding Guidelines (added 2026-05-27)
Behavioral guidelines to reduce common LLM coding mistakes, from Andrej Karpathy's observations on where LLMs go wrong (wrong assumptions, overcomplication, changing code they don't fully understand). Source: github.com/multica-ai/andrej-karpathy-skills (MIT). These COMPLEMENT the MANDATORY Rules above — where they overlap, the MANDATORY Rules and project decisions still win.

**Tradeoff:** these bias toward caution over speed. For trivial tasks, use judgment.

### 1. Think Before Coding
**Don't assume. Don't hide confusion. Surface tradeoffs.** Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them — don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

### 2. Simplicity First
**Minimum code that solves the problem. Nothing speculative.**
- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.
- Ask: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

### 3. Surgical Changes
**Touch only what you must. Clean up only your own mess.** When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it — don't delete it.
- Remove imports/variables/functions that YOUR changes made unused; don't remove pre-existing dead code unless asked.
- The test: every changed line should trace directly to the user's request.
- (Reinforces the existing MANDATORY rule: never change design/colors/sizes/layout unless asked.)

### 4. Goal-Driven Execution
**Define success criteria. Loop until verified.** Transform tasks into verifiable goals:
- "Add validation" → "test invalid inputs, then make them pass"
- "Fix the bug" → "reproduce it with a check, then make it pass"
- "Refactor X" → "ensure it verifies before and after"
- For multi-step tasks, state a brief plan with a verify step each: `1. [step] → verify: [check]`
- Strong success criteria let you loop independently; weak ones ("make it work") force constant clarification.
- **RAA fit:** this project has no XCTest suite — the standard "verify" here is `xcodebuild ... > /tmp/log 2>&1` (one build at a time) + an iPad/sim smoke test for UI/behavior, not unit tests. Apply the principle (define the check, loop until it passes) using build + run as the verification loop.
