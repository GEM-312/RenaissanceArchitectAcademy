# Claude Memory - Renaissance Architect Academy

## Project Overview
Educational city-building game where students solve architectural challenges across 13+ sciences. Leonardo da Vinci notebook aesthetic with watercolor + blueprint style.

**Developer:** Marina Pollak

## Tech Stack
- **SwiftUI + SpriteKit** (migrated from Unity Feb 2025)
- Art: OpenArt (mixed models, incl. a Midjourney mix)
- GitHub: https://github.com/GEM-312/RenaissanceArchitectAcademy
- Target: iOS 26+, macOS 14+

## Project Structure
```
RenaissanceArchitectAcademy/
├── RenaissanceArchitectAcademy/
│   ├── RenaissanceArchitectAcademyApp.swift  # @main + font registration (CoreText)
│   ├── Assets.xcassets/                      # Science*, Nav*, State*, City*, BirdFrame00-12,
│   │                                         # ApprenticeFrame00-14, VolcanoFrame00-14,
│   │                                         # Station*, Interior*, WorkshopTerrain, etc.
│   ├── Fonts/                                # Cinzel, EBGaramond, PetitFormalScript, Mulish,
│   │                                         # LibreBaskerville, LibreFranklin, Delius
│   ├── Views/
│   │   ├── ContentView.swift                 # Root view, navigation state, shared ViewModel
│   │   ├── MainMenuView.swift                # Title + background image
│   │   ├── CityView.swift                    # Building plots grid + era filtering
│   │   ├── BuildingPlotView.swift            # Individual plot card
│   │   ├── BuildingDetailOverlay.swift       # Modal with sciences + Begin Challenge
│   │   ├── SidebarView.swift                 # iPad sidebar navigation
│   │   ├── ProfileView.swift                 # Student profile, science mastery
│   │   ├── InteractiveChallengeView.swift    # Master challenge view (mixed question types)
│   │   ├── DragDropEquationView.swift        # Chemistry drag-drop equations
│   │   ├── HydraulicsFlowView.swift          # Water flow path tracing
│   │   ├── MascotDialogueView.swift          # Mascot dialogue + choice buttons
│   │   ├── MaterialPuzzleView.swift          # Match-3 puzzle for collecting materials
│   │   ├── MoleculeView.swift                # Chemical structure diagrams (7 molecules)
│   │   ├── WorkshopView.swift                # Workshop entry (outdoor/indoor toggle)
│   │   ├── WorkshopMapView.swift             # SwiftUI wrapper for outdoor WorkshopScene
│   │   ├── SketchingChallengeView.swift      # Master orchestrator for sketching mini-game
│   │   ├── KnowledgeTestsView.swift          # Quiz challenges list
│   │   ├── GameTopBarView.swift              # Shared top nav bar + building strip
│   │   ├── OnboardingView.swift              # Onboarding orchestrator (character → story → bird)
│   │   ├── Onboarding/
│   │   │   ├── CharacterSelectView.swift     # Boy/girl selection + name entry
│   │   │   ├── StoryNarrativeView.swift      # Animated story page with typewriter text
│   │   │   └── StationLessonOverlay.swift    # Bird lesson modal before first station visit
│   │   ├── Sketching/
│   │   │   ├── PiantaCanvasView.swift        # Phase 1: Floor plan grid canvas
│   │   │   └── SketchingToolbarView.swift    # Tool palette
│   │   ├── BuildingLessonView.swift          # Paged lesson reader (Read to Earn)
│   │   ├── BuildingChecklistView.swift       # Building material checklist
│   │   ├── ForestMapView.swift               # SwiftUI wrapper for ForestScene
│   │   ├── NotebookView.swift                # Building notebook with entries
│   │   ├── NotebookCanvasView.swift          # Drawing canvas for notebook
│   │   └── SpriteKit/
│   │       ├── CityScene.swift               # Main SKScene - terrain tiles, rivers, buildings, camera
│   │       ├── BuildingNode.swift            # Tappable building sprites
│   │       ├── CityMapView.swift             # SwiftUI wrapper + mascot overlay
│   │       ├── PlayerNode.swift              # Da Vinci stick figure (Workshop)
│   │       ├── ResourceNode.swift            # Resource station nodes (Workshop)
│   │       ├── WorkshopScene.swift           # Workshop outdoor SpriteKit scene
│   │       ├── CraftingRoomScene.swift       # Crafting room interior SpriteKit scene
│   │       ├── CraftingRoomMapView.swift     # SwiftUI wrapper for CraftingRoomScene
│   │       └── ForestScene.swift             # Forest exploration SpriteKit scene
│   ├── ViewModels/
│   │   ├── CityViewModel.swift               # @MainActor, @Published state, 17 buildings
│   │   ├── WorkshopState.swift               # Crafting state, station stocks, recipes
│   │   ├── NotebookState.swift               # Notebook entries per building
│   │   └── PersistenceManager.swift          # Save/load game progress
│   ├── Models/
│   │   ├── Building.swift                    # Era, RenaissanceCity, Science, Building, BuildingPlot, BuildingState
│   │   ├── Material.swift                    # Raw materials enum
│   │   ├── CraftedItem.swift                 # Crafted items enum
│   │   ├── Recipe.swift                      # Crafting recipes + educational text
│   │   ├── StudentProfile.swift              # MasteryLevel, Achievement, Resources
│   │   ├── Challenge.swift                   # Challenge system + all building challenges
│   │   ├── SketchingChallenge.swift          # Sketching data models
│   │   ├── SketchingContent.swift            # Static sketching challenge data per building
│   │   ├── OnboardingState.swift             # ApprenticeGender, OnboardingState (UserDefaults)
│   │   ├── OnboardingContent.swift           # Story pages + 8 station lesson content
│   │   ├── BuildingLesson.swift              # Lesson section types (reading, funFact, question, fillInBlanks, environmentPrompt)
│   │   ├── LessonContent.swift               # Pantheon lesson + switch router for all 17 buildings
│   │   ├── LessonContentRome.swift           # 7 Ancient Rome lessons (buildings 1-3, 5-8)
│   │   ├── LessonContentRenaissance.swift    # 9 Renaissance lessons (buildings 9-17)
│   │   ├── NotebookEntry.swift               # Notebook entry model + drawing strokes
│   │   ├── NotebookContent.swift             # Pantheon vocab + switch router for all 17 buildings
│   │   ├── NotebookContentRome.swift         # 7 Rome vocabulary sets (6 terms each)
│   │   ├── NotebookContentRenaissance.swift  # 9 Renaissance vocabulary sets (6 terms each)
│   │   ├── BuildingProgress.swift            # Building progress tracking
│   │   ├── BuildingProgressRecord.swift      # Progress persistence record
│   │   ├── PlayerSave.swift                  # Player save data model
│   │   ├── MasterAssignment.swift            # Master crafting task assignments
│   │   └── LessonRecord.swift               # Lesson completion tracking
│   └── Styles/
│       ├── RenaissanceColors.swift           # Full color palette + gradients
│       └── RenaissanceButton.swift           # Engineering blueprint style buttons
```

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

### Building ID Mapping (SpriteKit string → ViewModel int)
```swift
"aqueduct": 1, "colosseum": 2, "romanBaths": 3, "pantheon": 4,
"romanRoads": 5, "harbor": 6, "siegeWorkshop": 7, "insula": 8,
"duomo": 9, "botanicalGarden": 10, "glassworks": 11, "arsenal": 12,
"anatomyTheater": 13, "leonardoWorkshop": 14, "flyingMachine": 15,
"vaticanObservatory": 16, "printingPress": 17
```

## Game Systems

### City Map (CityScene + CityMapView)
- SpriteKit tile-based terrain (3500x2500 base, expandable via `terrainTiles` array)
- Rivers: Tiber, Arno, Grand Canal. Zone labels I-VI
- Player (PlayerNode) walks to tapped buildings, camera follows + zooms in
- Terrain blur (SKEffectNode + CIGaussianBlur) activates during walking, persists while zoomed in
- All overlays auto-dismiss on any user interaction (walk, scroll, pinch, drag)
- Mascot (Bird) rendered as SwiftUI overlay on top of SpriteKit (position tracked via callback)
- Tap building → player walks there → camera zooms to 0.7 → MascotDialogueView with 3 choices:
  - "I need materials" → MaterialPuzzleView (match-3)
  - "I don't know" → Quiz challenge
  - "I need to sketch it" → Sketching challenge

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

### Sketching Mini-Game (4 phases, Phase 1 implemented)
- Phases: Pianta (floor plan), Alzato (elevation), Sezione (cross-section), Prospettiva (perspective)
- Phase 1: SwiftUI Canvas grid, wall drawing, column placement, circle drawing, room detection
- Strict validation: 90% wall coverage, exact circle match, neatness checks
- Bird companion hint system (3-level progressive hints)
- Content for: Pantheon, Colosseum, Aqueduct, Duomo
- Lookup: `SketchingContent.sketchingChallenge(for: buildingName)`
- BuildingState progression: `.available` → `.sketched` → `.construction` → `.complete`

### Material Puzzle (MaterialPuzzleView)
- Match-3 game: 6x6 grid, swap adjacent tiles, collect chemical elements
- 3 formulas: limeMortar, concrete, glass (mapped per building)
- Gravity, auto-reshuffle, distractor elements

### Onboarding System (Models/OnboardingState + OnboardingContent, Views/Onboarding/)
- Character selection (boy/girl) + name entry → 3-page animated narrative → bird companion intro
- `OnboardingState` @Observable with UserDefaults persistence (hasCompletedOnboarding, gender, name)
- `StoryNarrativeView` — typewriter text reveal, BirdCharacter entrance animation
- `StationLessonOverlay` — bird teaches history/science before first station visit (per session)
- `stationsLessonSeen: Set<ResourceStationType>` in WorkshopState tracks which lessons shown
- Currently always shows onboarding (skip check commented out in ContentView for development)
- Forest station: after lesson, shows choice dialogue (Collect Timber vs Explore the Forest)

### Workshop (outdoor SpriteKit + indoor SpriteKit)
- **Outdoor** (WorkshopScene + WorkshopMapView): Apprentice walks between 8 resource stations + 1 crafting room (Dijkstra pathfinding, 64 waypoints)
- **Indoor** (CraftingRoomScene + CraftingRoomMapView): Apprentice walks between 4 furniture stations (Dijkstra pathfinding, 11 waypoints)
  - Furniture: Workbench (mix), Furnace (fire), Pigment Table (pigment collection + recipes), Storage Shelf (inventory)
  - `CraftingStation` enum: `.workbench`, `.furnace`, `.pigmentTable`, `.shelf`
  - Tap furniture → apprentice walks there → SwiftUI overlay appears
  - Player spawns at door position (bottom-center), walks to furniture via waypoint graph
- Crafting flow: Collect outdoors → enter Crafting Room → Mix at workbench → Fire in furnace → Educational popup
- 6 resource stations have OpenArt sprites; volcano has 15-frame animation
- Crafting room station pulses like resource stations on outdoor map
- Footstep sound (footstep.wav) plays during apprentice walking (0.55s interval)
- Master assignments: `MasterAssignment` model, random crafting tasks with bonus florins

### GameTopBarView
- Shared nav bar across City Map, Workshop, Crafting Room
- Nav buttons → `onNavigate(SidebarDestination)` callback
- Building progress strip (green=complete, ochre=sketched, gray=locked)

## Models Reference

### BuildingState
`.locked` → `.available` → `.sketched` → `.construction` → `.complete`

### Science (13 types)
Mathematics, Physics, Chemistry, Geometry, Engineering, Astronomy, Biology, Geology, Optics, Hydraulics, Acoustics, Materials Science, Architecture

### Color Palette (RenaissanceColors.swift)
| Color | Hex | Usage |
|-------|-----|-------|
| parchment | #F5E6D3 | Aged paper background |
| sepiaInk | #4A4035 | Text |
| renaissanceBlue | #5B8FA3 | Accents, water |
| terracotta | #D4876B | Rome buildings |
| ochre | #C9A86A | Renaissance buildings |
| sageGreen | #7A9B76 | Completion |
| deepTeal | #2B7A8C | Venice water |
| warmBrown | #8B6F47 | Engineering |
| blueprintBlue | #4169E1 | Grid lines |
| goldSuccess | #DAA520 | Success glow |
| errorRed | #CD5C5C | Errors |

### Custom Fonts (registered via CoreText in App.swift)
- **Cinzel-Bold** (titles), **Cinzel-Regular** (labels, section headers)
- **EBGaramond-Regular** (body text, buttons), **EBGaramond-Italic** (emphasis)
- **LibreBaskerville** (serif body alternative), **LibreFranklin** (sans-serif alternative)
- **Mulish** (7 weights available, previously used for body — replaced by EBGaramond Feb 2026)
- **PetitFormalScript-Regular** (tagline), **Delius-Regular** (handwritten accent)

## Art Asset Pipeline (OpenArt)
Art is generated in OpenArt (mixed models incl. Midjourney). Always resize before adding — assets are huge:
```bash
sips -Z 180 f.png   # science icons    sips -Z 120 f.png   # nav icons    sips -Z 512 f.png   # city/station icons
```
Animated GIF → sprite frames: extract all at 512x512 (Claude, PIL seek/resize) → pick 15 evenly-spaced → remove bg (Marina, Photoshop) → build `Assets.xcassets/[Name]Frame00-14.imageset/`. Folders: `Styles/[name]_frames/` (raw, gitignored) → `/selected` → `/clean`.

## Roadmap (high-level — active priorities live in session memory)
Done: lessons + vocab for all 17 buildings (Feb 2026); KnowledgeCardsOverlay + card integration; station sprites.

Remaining (high-level):
- Knowledge cards for the remaining 16 buildings (only Pantheon authored, 14 cards)
- Challenges for the remaining 11 buildings; building images on the city map
- Sketching Phases 2–4 (Alzato / Sezione / Prospettiva) + content for more buildings
- Audio pass: music, ambience, UI/crafting/collection/challenge SFX, volume sliders (see audio inventory in memory)
- Foundation Models on-device: bird tool calling, NPC text, Medici onboarding text
- Award/badge system; bird nudge to explore after workshop; quiz triggers on milestones
- Persist progress (UserDefaults/SwiftData); construction + bloom animations; expansion terrain tiles
- iPhone layout testing (all mini-games + flows); terrain/camera polish (LOD, micro-environments)

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

## How to Run
1. Open `RenaissanceArchitectAcademy.xcodeproj` in Xcode
2. Select iPad simulator or "My Mac"
3. Press Cmd+R to build and run

## Available Agent Skills (Auto-Activate)

Five user-level SwiftUI/Apple-platform skills are installed at `~/.claude/skills/` and auto-activate when relevant. Use them as the primary reference for generic Swift/SwiftUI/SwiftData/concurrency/security questions — this CLAUDE.md is for project-specific rules ONLY (decisions, file refs, past bugs, counter-defaults).

- **`swiftui-pro`** (Paul Hudson) — SwiftUI code review: modern API, views, data flow, navigation, accessibility, performance, hygiene
- **`swiftdata-pro`** (Paul Hudson) — SwiftData core rules, predicate safety, CloudKit constraints, indexing, class inheritance
- **`swift-concurrency`** (Antoine van der Lee) — `@MainActor` judgment, Task isolation, Sendable, Swift 6 strict concurrency, data races
- **`app-intents`** (Anton Novoselov) — `AppIntent` / `AppEntity` / Apple Intelligence (`AssistantEntity`/`AssistantIntent`), Spotlight, Snippets
- **`swift-security-expert`** (Ivan Magda) — Keychain, biometrics, CryptoKit, Secure Enclave, certificate pinning, OWASP MASTG

When a skill's generic guidance conflicts with CLAUDE.md project rules, **CLAUDE.md wins** (project decisions, history, and file refs are non-negotiable).

## MANDATORY Rules
- **BE 100% HONEST about every status, estimate, and outcome.** No softening, no aspirational claims dressed as facts, no hidden mistakes. If a build failed, say it failed. If a commit's message claimed something the edit didn't include, surface it and fix it (don't paper over). If an estimate is wrong, correct it openly the moment you realize. End-of-task summaries describe what actually shipped, not what was attempted. Push back on weak approaches with reasoning rather than acquiescing to keep things smooth. Trust depends on accurate signal; polite lies cost real hours of misallocation later.
- **NEVER read, edit, write, or otherwise access `RenaissanceArchitectAcademy/Services/APIKeys.swift`** — by Read, Edit, Write, Bash (`cat`, `grep`, `head`, `tail`, `less`, `xxd`, `od`, or any other reader), or any indirect means. The file holds secrets. Read/Edit/Write are denied at the harness level in `.claude/settings.json`; this rule covers every other channel. If you need to know whether the proxy is configured, infer it from `WorkerClient.isConfigured` callers — not from the file. For token rotations: Marina runs them manually outside Claude Code.
- **NEVER inline a secret value into a Bash command line.** No `PROXY_TOKEN="<hex>" node script.js`, no `curl -H "Authorization: Bearer <key>"` with the literal key, no environment-variable assignments where the value is the real secret. If a command needs a secret: (1) ask Marina to `export VAR=...` in her shell once, or (2) `export VAR=$(cat ~/path/to/gitignored-file)`, then run the **bare** command with no secret in the string. Reason: Claude Code's permission system saves "Always allow" patterns as the literal command string — any secret inlined into the command leaks into `.claude/settings.local.json` permanently. Past incident: May 7 2026, a Claude session inlined `PROXY_TOKEN="4dbd…"` into a generate-sfx.mjs call; Marina clicked Always allow; token persisted in settings.local.json line 33 until discovered May 21.
- **NEVER change design, colors, sizes, layout, or visual appearance unless Marina specifically asks for it.** Fix only what is requested. If you think a design change would help, ASK FIRST — do not just do it.
- **ALWAYS read the FULL file before editing it.** Never edit a file based on memory, summaries, or assumptions. Use the Read tool on every file you are about to modify, every single time, no exceptions. If the file is large, read it in chunks until you have seen all relevant sections. Failure to do this causes wrong edits, missed context, and broken code.
- **ALWAYS read related files before making cross-file changes.** If a change touches callbacks, state, or UI across multiple files (e.g. a Scene + its MapView wrapper), read ALL of them first.

## Teaching System (PROACTIVE)
- **ALWAYS teach while coding.** When introducing a new pattern, avoiding a pitfall, fixing a bug, or writing non-trivial logic, deliver a short teaching moment.
- Print the title in green via Bash: `echo -e "\n\033[1;32m━━━ TEACHING MOMENT: [Title] ━━━\033[0m\n"`
- Follow with: THE CONCEPT (1-2 sentences) → STEP BY STEP (numbered) → IN OUR CODE (specific reference) → KEY TAKEAWAY (1 sentence)
- Append every teaching moment to `Teaching.md` under the appropriate section
- Use `/teach [topic]` to request a specific lesson on demand
- Teaching style: MIT professor — clear, step-by-step, real-world analogies, no fluff

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
