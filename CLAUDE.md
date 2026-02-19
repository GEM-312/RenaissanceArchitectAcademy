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
│   ├── Fonts/                                # Cinzel, EBGaramond, PetitFormalScript
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
│   │   ├── WorkshopInteriorView.swift        # Interior crafting room
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
│   │   └── SpriteKit/
│   │       ├── CityScene.swift               # Main SKScene - terrain tiles, rivers, buildings, camera
│   │       ├── BuildingNode.swift            # Tappable building sprites
│   │       ├── CityMapView.swift             # SwiftUI wrapper + mascot overlay
│   │       ├── PlayerNode.swift              # Da Vinci stick figure (Workshop)
│   │       ├── ResourceNode.swift            # Resource station nodes (Workshop)
│   │       └── WorkshopScene.swift           # Workshop SpriteKit scene
│   ├── ViewModels/
│   │   ├── CityViewModel.swift               # @MainActor, @Published state, 17 buildings
│   │   └── WorkshopState.swift               # Crafting state, station stocks, recipes
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
│   │   └── OnboardingContent.swift           # Story pages + 8 station lesson content
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

### Workshop (outdoor SpriteKit + indoor SwiftUI)
- **Outdoor**: Apprentice walks between 8 resource stations + 1 crafting room (Dijkstra pathfinding, 64 waypoints)
- **Indoor** (WorkshopInteriorView): Workbench (mix), Furnace (fire), Pigment Table, Storage Shelf
- Crafting flow: Collect → enter Crafting Room → Mix at workbench → Fire in furnace → Educational popup
- 6 resource stations have Midjourney sprites; volcano has 15-frame animation
- Crafting Room replaces old outdoor workbench/furnace/pigmentTable — single entry to interior
- Footstep sound (footstep.wav) plays during apprentice walking (0.55s interval)

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
Cinzel-Bold (titles), Cinzel-Regular (labels), EBGaramond-Regular (body), EBGaramond-Italic (buttons/hints), PetitFormalScript-Regular (tagline)

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

### Game Flow & Progression
- [ ] Prompt user to explore cities/buildings after workshop play (bird nudge system)
- [ ] Trigger quizzes after certain gameplay milestones (time played, materials collected, buildings visited)
- [ ] Award system — badges, achievements for completing challenges, crafting, sketching
- [ ] Currency system — coins/ducats earned from quizzes, crafting, exploration; spent on building upgrades
- [ ] Re-enable onboarding skip (uncomment check in ContentView after onboarding is finalized)

### New Scenes
- [ ] Forest Scene — Italian tree biodiversity, biology & environment education (connected from workshop forest choice)
- [ ] Building-specific scenes for each of the 17 buildings

### Content
- [ ] Create challenges for remaining 11 buildings
- [ ] Add building images to city map
- [ ] Sketching Phase 2 (Alzato elevation) — drag-drop facade elements
- [ ] Sketching Phase 3 (Sezione cross-section) — structural + light rays
- [ ] Sketching Phase 4 (Prospettiva perspective) — vanishing points
- [ ] Add sketching content for remaining buildings

### Art & Assets
- [ ] Remove backgrounds from volcano frames (Marina in Photoshop)
- [ ] Add station sprites for remaining stations (market, crafting room)

### Technical
- [ ] Adjust 64 waypoints to match new terrain in editor mode
- [ ] Sound effects (challenge_success, challenge_fail, puzzle_match)
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
