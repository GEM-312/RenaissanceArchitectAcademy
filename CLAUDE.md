# Claude Memory - Renaissance Architect Academy

## Project Overview
Educational city-building game where students solve architectural challenges across 13+ sciences. Leonardo da Vinci notebook aesthetic with watercolor + blueprint style.

**Developer:** Marina Pollak
**School:** Columbia College Chicago - Final Semester
**Timeline:** Jan 30 - May 15, 2025

## Tech Stack
- **SwiftUI + SpriteKit** (migrated from Unity Feb 2025)
- Midjourney AI art (style ref: `--sref 3186415970`)
- GitHub: https://github.com/GEM-312/RenaissanceArchitectAcademy
- Target: iOS 17+, macOS 14+

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
- Mascot (Bird) rendered as SwiftUI overlay on top of SpriteKit (position tracked via callback)
- Tap building → mascot walks there → MascotDialogueView with 3 choices:
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
- 6 resource stations have Midjourney sprites; volcano has 15-frame animation
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
- **Mulish-Light** (body text, buttons), **Mulish-Medium/SemiBold/Bold** (emphasis)
- **LibreBaskerville** (serif body alternative), **LibreFranklin** (sans-serif alternative)
- **EBGaramond-Regular/Italic** (legacy body — being replaced by Mulish)
- **PetitFormalScript-Regular** (tagline), **Delius-Regular** (handwritten accent)

### Resizing New Midjourney Assets
```bash
sips -Z 180 "filename.png"   # Science icons
sips -Z 120 "filename.png"   # Navigation icons
sips -Z 512 "filename.png"   # City/station icons
```

## GIF Frame Extraction Workflow
For turning Midjourney/Pika animated GIFs into sprite frames:

1. **Extract** all frames at 512x512 (Claude): `PIL Image.open → seek → resize → save`
2. **Select** 15 key frames evenly spaced → `selected/` subfolder
3. **Remove backgrounds** (Marina in Photoshop) → `clean/` subfolder
4. **Create imagesets** (Claude): `Assets.xcassets/[Name]Frame00-14.imageset/`

```
Styles/[name]_frames/          # All extracted (gitignored)
Styles/[name]_frames/selected/ # 15 key frames
Styles/[name]_frames/clean/    # Photoshop exports (no bg)
```

## Next Steps

### PRIORITY 1: Forest Scene (next session)
- [ ] Build out ForestScene.swift — Italian tree biodiversity, biology & environment education
- [ ] ForestScene.swift and ForestMapView.swift already exist as stubs — need full implementation
- [ ] Forest terrain image needed (ForestTerrain.png) — or use Forest1-4 assets already in xcassets
- [ ] Tree stations: oak, pine, cypress, chestnut, olive — each with educational content
- [ ] Timber collection mechanics (connects to building `requiredMaterials` needing `.timberBeams`)
- [ ] Lesson environment prompts already link to `.forest` — need ForestScene to handle arrival
- [ ] Biology/ecology lessons per tree species (growth patterns, wood properties, uses in construction)
- [ ] Apprentice walks between tree stations (same Dijkstra pattern as Workshop/CraftingRoom)

### PRIORITY 2: Crafting Room Scene Polish (next session)
- [ ] Tune furniture positions and waypoints using editor mode (press E)
- [ ] Test all 4 station overlays end-to-end (workbench → furnace → educational popup)
- [ ] Verify crafting room terrain/background looks right at 3500×2500
- [ ] Consider adding door entrance animation when transitioning from outdoor

### PRIORITY 3: App-Wide Style Consistency (next session)
- [ ] Audit font usage across all views — standardize on Cinzel (titles) + Mulish (body/buttons)
- [ ] Remove remaining EBGaramond references, replace with Mulish-Light
- [ ] Consistent overlay styling (background opacity, corner radius, shadow, padding)
- [ ] Consistent button styling across scenes (glass buttons vs filled vs outlined)
- [ ] Color palette audit — ensure all views use RenaissanceColors consistently
- [ ] Spacing and padding consistency (16pt standard margins, 12pt inner padding)

### Game Flow & Progression
- [ ] Prompt user to explore cities/buildings after workshop play (bird nudge system)
- [ ] Trigger quizzes after certain gameplay milestones (time played, materials collected, buildings visited)
- [ ] Award system — badges, achievements for completing challenges, crafting, sketching
- [ ] Re-enable onboarding skip (uncomment check in ContentView after onboarding is finalized)

### New Scenes
- [ ] Building-specific scenes for each of the 17 buildings

### Content
- [x] ~~Create lessons for all 17 buildings~~ (DONE — Feb 2026)
- [x] ~~Create vocabulary for all 17 buildings~~ (DONE — Feb 2026)
- [ ] Create challenges for remaining 11 buildings
- [ ] Add building images to city map
- [ ] Sketching Phase 2 (Alzato elevation) — drag-drop facade elements
- [ ] Sketching Phase 3 (Sezione cross-section) — structural + light rays
- [ ] Sketching Phase 4 (Prospettiva perspective) — vanishing points
- [ ] Add sketching content for remaining buildings

### Art & Assets
- [ ] Remove backgrounds from volcano frames (Marina in Photoshop)
- [x] ~~Add station sprites for remaining stations (market, crafting room)~~ (DONE — Feb 22 2026)

### PRIORITY 4: Audio & Sound Design (next session)
- [ ] Background music — ambient Renaissance lute/harpsichord loop for main menu, city map, workshop
- [ ] Forest ambience — birds, wind, rustling leaves (looping)
- [ ] Crafting room ambience — crackling fire, workshop sounds
- [ ] UI sounds — button tap, overlay open/close, page turn (lessons)
- [ ] Crafting sounds — workbench mixing, furnace fire whoosh, crafting complete chime
- [ ] Collection sounds — resource pickup, timber chop, stone quarry hit
- [ ] Challenge sounds — correct answer ding, wrong answer buzz, quiz complete fanfare
- [ ] Walking sounds — footstep.wav already exists (0.55s interval), add surface variants (stone, grass, wood)
- [ ] Transition sounds — scene enter/exit swoosh, crafting room door creak
- [ ] Bird companion — chirp on hint, squawk on wrong answer, happy trill on success
- [ ] Sketch sounds — pencil scratch on canvas, stamp for column placement
- [ ] Consider AVAudioPlayer for music loops, SKAction.playSoundFileNamed for SFX
- [ ] Volume controls — separate sliders for music vs SFX in settings/profile

### Technical
- [ ] Adjust 64 waypoints to match new terrain in editor mode
- [ ] Persist progress with UserDefaults/SwiftData
- [ ] Building construction animation
- [ ] Full bloom animation (gray sketch → watercolor)
- [ ] Generate expansion terrain tiles for map growth

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

## Notes
- Marina prefers direct fixes over long explanations
- Teach concepts as you go when making changes
- Always push to GitHub after significant changes
- New Midjourney assets are usually huge — always resize before adding
- Challenge.swift contains all quiz questions
