# Claude Memory - Renaissance Architect Academy

## Project Overview
Educational city-building game where students solve architectural challenges across 13+ sciences. Leonardo da Vinci notebook aesthetic with watercolor + blueprint style.

**Developer:** Marina Pollak
**School:** Columbia College Chicago - Final Semester
**Timeline:** Jan 30 - May 15, 2025

## Team
- **Developer:** Marina Pollak
- **Level Designer:** [Name]
- **Game Designer:** [Name]
- **Game Designer:** [Name]

## Tech Stack
- **SwiftUI + SpriteKit** (migrated from Unity Feb 2025)
- Midjourney AI art (style ref: `--sref 3186415970`)
- GitHub: https://github.com/GEM-312/RenaissanceArchitectAcademy

## Project Structure
```
RenaissanceArchitectAcademy/
├── RenaissanceArchitectAcademy.xcodeproj/
├── RenaissanceArchitectAcademy/
│   ├── RenaissanceArchitectAcademyApp.swift  # @main + font registration
│   ├── Info.plist                            # Font declarations
│   ├── Assets.xcassets/                      # Image assets
│   │   ├── BackgroundMain.imageset/          # Renaissance dome background
│   │   ├── Science*.imageset/                # 13 custom science icons
│   │   ├── City*.imageset/                   # Rome, Florence city images
│   │   ├── Nav*.imageset/                    # Navigation icons (Home, Back, etc.)
│   │   ├── State*.imageset/                  # Building state icons
│   │   ├── BirdFrame00-12.imageset/         # 13-frame flying bird animation
│   │   ├── SittingBird1-2.imageset/         # 2-frame sitting bird animation
│   │   ├── ApprenticeFrame00-14.imageset/   # 15-frame apprentice walk animation
│   │   ├── WorkshopTerrain.imageset/        # Workshop outdoor terrain (2912x1632)
│   │   ├── WorkshopBackground.imageset/     # Workshop interior room background
│   │   ├── Station*.imageset/               # 6 station sprites (Quarry,River,Volcano,ClayPit,Mine,Forest)
│   │   ├── VolcanoFrame00-14.imageset/      # 15-frame volcano animation
│   │   ├── Interior*.imageset/              # 4 interior furniture (Furnace,Workbench,PigmentTable,Shelf)
│   │   └── FlyingBird1-2.imageset/          # Legacy flying bird (unused)
│   ├── Fonts/                                # Custom Renaissance fonts
│   │   ├── Cinzel-*.ttf                      # Titles
│   │   ├── EBGaramond-*.ttf                  # Body text, buttons
│   │   └── PetitFormalScript-Regular.ttf     # Tagline
│   ├── Views/
│   │   ├── ContentView.swift          # Root view, navigation state, shared ViewModel
│   │   ├── MainMenuView.swift         # Title + background image
│   │   ├── CityView.swift             # Building plots grid + challenge navigation
│   │   ├── BuildingPlotView.swift     # Individual plot card (engineering style)
│   │   ├── BuildingDetailOverlay.swift # Modal with sciences + Begin Challenge
│   │   ├── SidebarView.swift          # iPad sidebar navigation + Home icon
│   │   ├── ProfileView.swift          # Student profile, science mastery cards
│   │   ├── ScienceIconView.swift      # Helper views for custom icons
│   │   ├── BloomEffectView.swift      # Particle effects for completion
│   │   ├── ChallengeView.swift        # Legacy multiple choice challenge view
│   │   ├── InteractiveChallengeView.swift  # Master challenge view (mixed question types)
│   │   ├── DragDropEquationView.swift      # Chemistry drag-drop equations
│   │   ├── HydraulicsFlowView.swift        # Water flow path tracing
│   │   ├── MascotDialogueView.swift        # Mascot dialogue + choice buttons
│   │   ├── MaterialPuzzleView.swift        # Match-3 puzzle for collecting materials
│   │   ├── MoleculeView.swift              # Chemical structure diagrams (7 molecules)
│   │   ├── WorkshopView.swift               # Workshop entry (outdoor/indoor toggle)
│   │   ├── WorkshopMapView.swift            # SwiftUI wrapper for outdoor WorkshopScene
│   │   ├── WorkshopInteriorView.swift       # Interior crafting room (workbench, furnace, pigment, shelf)
│   │   ├── SketchingChallengeView.swift     # Master orchestrator for sketching mini-game
│   │   ├── KnowledgeTestsView.swift         # Quiz challenges list (relocated from building cards)
│   │   ├── GameTopBarView.swift             # Shared top nav bar (Profile/Map/Eras/Workshop + building strip)
│   │   ├── Sketching/                       # Sketching phase views
│   │   │   ├── PiantaCanvasView.swift       # Phase 1: Floor plan grid canvas
│   │   │   └── SketchingToolbarView.swift   # Shared tool palette (wall/column/room/eraser/undo)
│   │   └── SpriteKit/                      # SpriteKit scenes
│   │       ├── CityScene.swift             # Main SKScene with buildings, rivers, mascot position
│   │       ├── BuildingNode.swift          # Tappable building sprites
│   │       ├── MascotNode.swift            # (Legacy - not used, SwiftUI renders mascot)
│   │       ├── CityMapView.swift           # SwiftUI wrapper + mascot overlay + PencilKit paint
│   │       ├── PlayerNode.swift            # Da Vinci stick figure player (Workshop)
│   │       ├── ResourceNode.swift          # Resource station nodes (Workshop)
│   │       └── WorkshopScene.swift         # SpriteKit workshop mini-game scene
│   ├── ViewModels/
│   │   ├── CityViewModel.swift        # @MainActor, @Published state, 17 buildings
│   │   └── WorkshopState.swift        # Workshop crafting state, station stocks, recipes
│   ├── Models/
│   │   ├── Building.swift             # Era, RenaissanceCity, Science, Building, BuildingPlot, BuildingState
│   │   ├── Material.swift             # Raw materials enum (limestone, clay, iron ore, etc.)
│   │   ├── CraftedItem.swift          # Crafted items enum (mortar, concrete, glass, etc.)
│   │   ├── Recipe.swift               # Crafting recipes with temperature + educational text
│   │   ├── StudentProfile.swift       # MasteryLevel, Achievement, Resources
│   │   ├── Challenge.swift            # Challenge system + all building challenges
│   │   ├── SketchingChallenge.swift   # Sketching data models (phases, grid types, validation)
│   │   └── SketchingContent.swift     # Static sketching challenge data per building
│   ├── Styles/
│   │   ├── RenaissanceColors.swift    # Full color palette + gradients
│   │   └── RenaissanceButton.swift    # Engineering blueprint style buttons
│   ├── Services/
│   │   └── SoundManager.swift         # Audio playback with AVFoundation
│   ├── Science Icons/                  # Original Midjourney source files
│   ├── City Icons/                     # Original city source files
│   ├── UINavigation/                   # Original nav icon source files
│   └── building_complete.mp3          # Victory sound effect
├── level_design_sketch.JPG             # Original hand-drawn map design
├── CLAUDE.md
├── README.md
├── LICENSE
└── .gitignore
```

## SpriteKit City Map (NEW - Feb 6, 2025)

### Overview
Interactive isometric city map built with SpriteKit, based on `level_design_sketch.JPG`. Features pan, zoom, and tap-to-select buildings.

### Key Files
| File | Purpose |
|------|---------|
| `CityScene.swift` | Main SKScene - terrain, rivers, buildings, camera controls |
| `BuildingNode.swift` | SKNode subclass for tappable buildings with state icons |
| `CityMapView.swift` | SwiftUI wrapper using SpriteView, connects to shared ViewModel |

### Map Features
- **Size:** 3500 x 2500 points
- **Rivers:** Tiber (Rome), Arno (Florence), Grand Canal (Venice)
- **Zone Labels:** Roman numerals (I-VI) for each region
- **Era Divider:** Dotted line separating Ancient Rome from Renaissance Italy

### Controls
| Platform | Pan | Zoom |
|----------|-----|------|
| **iPad** | Drag | Pinch |
| **macOS** | Scroll / Drag | Pinch / Option+Scroll |

### Building States
Buildings display state icons from Assets.xcassets:
- `.available` - Pulse animation, ready to tap
- `.complete` - Green tint + StateComplete icon
- `.locked` - Grayed out (future feature)
- `.construction` - Shake animation (future feature)

### Shared ViewModel
CityViewModel is created in ContentView and passed to both CityMapView and CityView:
```swift
// ContentView.swift
@StateObject private var cityViewModel = CityViewModel()

// Pass to views
CityMapView(viewModel: cityViewModel)
CityView(viewModel: cityViewModel, filterEra: era)
```
This ensures progress syncs across map and era tabs.

### Building ID Mapping
SpriteKit uses string IDs, ViewModel uses integer IDs:
```swift
private let buildingIdToPlotId: [String: Int] = [
    "aqueduct": 1, "colosseum": 2, "romanBaths": 3, "pantheon": 4,
    "romanRoads": 5, "harbor": 6, "siegeWorkshop": 7, "insula": 8,
    "duomo": 9, "botanicalGarden": 10, "glassworks": 11, "arsenal": 12,
    "anatomyTheater": 13, "leonardoWorkshop": 14, "flyingMachine": 15,
    "vaticanObservatory": 16, "printingPress": 17
]
```

## 17 Buildings (Expanded Feb 6, 2025)

### Ancient Rome (8 buildings)
| # | Building | Sciences | Has Challenge |
|---|----------|----------|---------------|
| 1 | Aqueduct | Engineering, Hydraulics, Mathematics | ✅ |
| 2 | Colosseum | Architecture, Engineering, Acoustics | ✅ |
| 3 | Roman Baths | Hydraulics, Chemistry, Materials | ✅ |
| 4 | Pantheon | Geometry, Architecture, Materials | ❌ |
| 5 | Roman Roads | Engineering, Geology, Materials | ❌ |
| 6 | Harbor | Engineering, Physics, Hydraulics | ❌ |
| 7 | Siege Workshop | Physics, Engineering, Mathematics | ❌ |
| 8 | Insula | Architecture, Materials, Mathematics | ❌ |

### Renaissance Italy (9 buildings across 5 cities)
| # | City | Building | Sciences | Has Challenge |
|---|------|----------|----------|---------------|
| 9 | Florence | Duomo | Geometry, Architecture, Physics | ✅ |
| 10 | Florence | Botanical Garden | Biology, Chemistry, Geology | ❌ |
| 11 | Venice | Glassworks | Chemistry, Optics, Materials | ❌ |
| 12 | Venice | Arsenal | Engineering, Physics, Materials | ❌ |
| 13 | Padua | Anatomy Theater | Biology, Optics, Chemistry | ❌ |
| 14 | Milan | Leonardo's Workshop | Engineering, Physics, Materials | ✅ |
| 15 | Milan | Flying Machine | Physics, Engineering, Mathematics | ❌ |
| 16 | Rome | Vatican Observatory | Astronomy, Optics, Mathematics | ✅ |
| 17 | Rome | Printing Press | Engineering, Chemistry, Physics | ❌ |

## Challenge System

### Architecture
The challenge system supports multiple question types:
- **Multiple Choice** - Traditional 4-option questions
- **Drag & Drop Equations** - Chemistry equations where students drag elements to blanks
- **Flow Tracing** - Hydraulics questions where students draw water flow paths

### Key Files
| File | Purpose |
|------|---------|
| `Challenge.swift` | All data models + questions for buildings with challenges |
| `InteractiveChallengeView.swift` | Master view that routes to correct question type |
| `DragDropEquationView.swift` | Chemistry equation drag-drop interface |
| `HydraulicsFlowView.swift` | Water flow path drawing canvas |
| `ChallengeView.swift` | Legacy multiple choice only (kept for reference) |

### Challenge Lookup
```swift
// In ChallengeContent enum
static func interactiveChallenge(for buildingName: String) -> InteractiveChallenge? {
    switch buildingName {
    case "Roman Baths": return romanBathsInteractive
    case "Aqueduct": return aqueductInteractive
    case "Colosseum": return colosseumInteractive
    case "Duomo": return duomoInteractive
    case "Observatory", "Vatican Observatory": return observatoryInteractive
    case "Workshop", "Leonardo's Workshop": return workshopInteractive
    default: return nil  // Shows "Challenge coming soon!"
    }
}
```

### Question Types
```swift
enum QuestionType {
    case multipleChoice
    case dragDropEquation(DragDropEquationData)
    case hydraulicsFlow(HydraulicsFlowData)
}
```

### Pow Celebration Effects
DragDropEquationView and HydraulicsFlowView use Pow for success animations:
```swift
import Pow

.changeEffect(
    .spray(origin: UnitPoint(x: 0.5, y: 0.5)) {
        Image(systemName: "drop.fill")
            .foregroundStyle(RenaissanceColors.renaissanceBlue)
    },
    value: showSuccessEffect
)
```

## Mascot System (NEW - Feb 6, 2025)

### Characters
Two mascot characters appear throughout the game:

**Splash** - Main watercolor ink blob mascot
- Body: 120x140 organic blob shape (ochre/warmBrown gradient)
- Eyes: 20x18 ellipses with 24pt spacing, blinking animation
- Smile: 30x15 curved path
- Ink drips: Heights [20, 35, 25] with 15pt spacing, dripping animation

**Bird** - Companion character
- Body: 40x35 ellipse (renaissanceBlue)
- Wing: 25x15 ellipse (deepTeal) with flapping animation
- Head: 25x25 circle
- Beak: Ochre triangle
- Bobbing animation

### Game Flow
1. **User taps building** → Mascot walks to building (bounce animation)
2. **Mascot reaches building** → MascotDialogueView appears with 3 choices:
   - "I need materials" → MaterialPuzzleView (match-3 game)
   - "I don't know" → BuildingDetailOverlay (info)
   - "I need to sketch it" → Challenge (future: sketching game)
3. **User completes puzzle** → Challenge begins

### Key Files
| File | Purpose |
|------|---------|
| `MascotDialogueView.swift` | SwiftUI mascot + dialogue bubble + choice buttons |
| `CityScene.swift` | Tracks mascot position, reports to SwiftUI via callback |
| `CityMapView.swift` | Renders SwiftUI mascot overlay, handles view transitions |

### Architecture: SwiftUI Overlay (Not SpriteKit)
The mascot is rendered as a **SwiftUI overlay** on top of the SpriteKit map, not as a SpriteKit node. This ensures the mascot looks identical everywhere:

```
CityScene (SpriteKit)          CityMapView (SwiftUI)
├── Tracks mascot position  →  ├── Receives position via callback
├── Handles cursor following   ├── Positions SwiftUI mascot overlay
├── Animates walk path         ├── SplashCharacter + BirdCharacter
└── Converts to screen coords  └── Same look as dialogue/puzzle views
```

**Why SwiftUI overlay?**
- SpriteKit and SwiftUI render shapes differently
- Using SwiftUI everywhere = identical appearance
- Easier to maintain one mascot design

### SwiftUI Components (MascotDialogueView.swift)
```swift
SplashCharacter()      // Main ink blob
BirdCharacter()        // Companion bird
WatercolorSplash       // Shape for blob body
Eye                    // Blinking eye component
Smile                  // Curved smile shape
InkDrip                // Animated drip capsule
Triangle               // Beak shape
DialogueBubble         // Parchment bubble with flourishes
ChoiceButton           // Styled choice options
```

### CityScene Mascot Position Tracking
```swift
// Callback to update SwiftUI mascot position
var onMascotPositionChanged: ((CGPoint, Bool) -> Void)?  // (position, isWalking)

// Convert world position to normalized screen position (0-1)
private func updateMascotScreenPosition()

// Get mascot facing direction for SwiftUI
func getMascotFacingRight() -> Bool
```

### CityMapView Mascot Overlay
```swift
// SwiftUI mascot rendered on top of SpriteKit
private func mascotOverlay(in size: CGSize) -> some View {
    HStack(alignment: .bottom, spacing: -20) {
        SplashCharacter()
            .scaleEffect(x: mascotFacingRight ? 1 : -1, y: 1)
        BirdCharacter()
    }
    .position(x: screenX, y: screenY)
}
```

## Material Puzzle System (NEW - Feb 6, 2025)

### Overview
Match-3 puzzle game where players collect chemical elements to build structures. Drag tiles to swap adjacent elements - matching 3+ of the same element collects them.

### Key File: MaterialPuzzleView.swift

### Data Structures
```swift
struct GridPosition: Hashable {
    let row: Int
    let col: Int
}

struct ElementTile: Identifiable {
    let id = UUID()
    var element: ChemicalElement
    var position: GridPosition
}

enum MaterialFormula {
    case limeMortar   // CaO + H₂O → Ca(OH)₂ (Ca: 3, O: 6, H: 6)
    case concrete     // Caiteiteite +ite...
    case glass        // SiO₂ + Na₂O → Glass
}
```

### Mechanics
- **Grid:** 6x6 tiles
- **Swap:** Drag to swap adjacent tiles (no diagonal)
- **Match:** 3+ same elements in row/column
- **Gravity:** Tiles fall down, new spawn from top
- **Distractors:** Fe, C, Mg, S elements that don't count toward formula
- **Win:** Collect required atoms (e.g., Ca=3, O=6, H=6 for lime mortar)

### Features
- Pow explosion effects on match
- Auto-reshuffle when no valid moves
- Mascot entrance animation (walks in from left)
- Progress bars for each required element
- Slide-in transition from right

### Building-to-Formula Mapping
```swift
func formulaForBuilding(_ buildingName: String) -> MaterialFormula {
    switch buildingName.lowercased() {
    case "aqueduct", "roman baths", "pantheon":
        return .limeMortar
    case "colosseum", "roman roads", "harbor", "siege workshop", "insula":
        return .concrete
    case "duomo", "glassworks", "arsenal", "leonardo's workshop", "flying machine", "vatican observatory", "printing press":
        return .glass
    default:
        return .limeMortar
    }
}
```

## Workshop Mini-Game (NEW - Feb 8, 2025)

### Overview
Township-style SpriteKit crafting experience. Player (da Vinci stick figure) walks between resource stations to collect materials, mix at workbench, and fire in furnace to create building supplies.

### Key Files
| File | Purpose |
|------|---------|
| `WorkshopScene.swift` | SpriteKit scene with stations, player movement, camera |
| `PlayerNode.swift` | Da Vinci stick figure with walk/idle animations |
| `ResourceNode.swift` | 10 station types (quarry, river, forest, furnace, etc.) |
| `WorkshopMapView.swift` | SwiftUI wrapper with 7-layer overlay system |
| `WorkshopState.swift` | Crafting state, station stocks, recipes, educational popups |
| `WorkshopView.swift` | Entry point, wraps WorkshopMapView |
| `Material.swift` | Raw materials (limestone, clay, iron ore, timber, etc.) |
| `CraftedItem.swift` | Crafted outputs (mortar, concrete, glass, etc.) |
| `Recipe.swift` | Recipes with ingredients, temperature, educational text |

### Crafting Flow
1. **Collect** - Walk to resource stations, tap materials to gather
2. **Mix** - Walk to Workbench, add 4 materials to slots, recipe auto-detected
3. **Fire** - Walk to Furnace, set temperature, press FIRE
4. **Learn** - "Did You Know?" educational popup after crafting

### Station Types
Quarry, River, Volcano, Clay Pit, Mine, Pigment Table, Forest, Market, Workbench, Furnace

### Overlay Layers (WorkshopMapView)
1. SpriteKit scene
2. Companion overlay (Splash + Bird follow player)
3. Top bar + inventory bar
4. Hint bubble (educational facts, positioned at top)
5. Collection overlay (material buttons, positioned at bottom)
6. Workbench overlay (mixing slots + recipe detection)
7. Furnace overlay (temperature picker + fire button)
8. Educational popup ("Did You Know?" after crafting)

## PencilKit Watercolor Paint Mode (NEW - Feb 8, 2025)

### Overview
PencilKit canvas overlay on the city map lets users draw watercolor strokes directly on the map. iOS uses Apple's `PKInkingTool(.watercolor)`, macOS uses a SwiftUI Canvas fallback.

### Key File: `CityMapView.swift`

### Features
- Toggle paint mode with brush button in top bar
- iOS: Full PKToolPicker with watercolor brush pre-selected
- macOS: SwiftUI Canvas with green+yellow stroke drawing
- Drawings saved/loaded via `UserDefaults` key `"cityMapWatercolorDrawing"`
- Clear button to reset canvas

### Platform Handling
```swift
#if os(iOS)
import PencilKit
@State private var watercolorDrawing = PKDrawing()
// WatercolorCanvasView wraps PKCanvasView + PKToolPicker
#else
@State private var watercolorDrawing = MacDrawing()
// MacDrawing = simple [[CGPoint]] strokes rendered in SwiftUI Canvas
#endif
```

## Models

### Era
```swift
enum Era: String, CaseIterable, Codable {
    case ancientRome = "Ancient Rome"
    case renaissance = "Renaissance Italy"
}
```

### RenaissanceCity (NEW)
```swift
enum RenaissanceCity: String, CaseIterable, Codable {
    case florence = "Florence"
    case venice = "Venice"
    case padua = "Padua"
    case milan = "Milan"
    case rome = "Rome"
}
```

### Building
```swift
struct Building: Identifiable {
    let id = UUID()
    let name: String
    let era: Era
    let city: RenaissanceCity?  // Only for Renaissance buildings
    let sciences: [Science]
    let iconName: String
}
```

### Science (13 types)
Mathematics, Physics, Chemistry, Geometry, Engineering, Astronomy, Biology, Geology, Optics, Hydraulics, Acoustics, Materials Science, Architecture

Each has:
- `sfSymbolName` - SF Symbol fallback
- `customImageName` - Custom Midjourney asset name (all 13 have custom images now)
- Corresponding color via `RenaissanceColors.color(for:)`

### BuildingState
- `.locked` - StateLocked image
- `.available` - StateAvailable image
- `.construction` - StateConstruction image
- `.complete` - StateComplete image

## Custom Fonts
Fonts are registered programmatically in `RenaissanceArchitectAcademyApp.swift` using CoreText:
```swift
CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, nil)
```

| Font | Usage |
|------|-------|
| Cinzel-Bold | Main titles |
| Cinzel-Regular | Labels |
| EBGaramond-Regular | Body text |
| EBGaramond-Italic | Buttons, subtitles, hints |
| PetitFormalScript-Regular | Tagline |

**Note:** Info.plist `UIAppFonts` didn't work with auto-generated plist, so we use CoreText manual registration.

## Custom Art Assets (Midjourney)

### Science Icons (13 total)
Located in `Assets.xcassets/Science*.imageset/`
- ScienceMath, SciencePhysics, ScienceChemistry, ScienceGeometry, ScienceEngineering
- ScienceAstronomy, ScienceBiology, ScienceGeology, ScienceOptics
- ScienceHydraulics, ScienceAcoustics, ScienceMaterials, ScienceArchitecture

### Navigation Icons
Located in `Assets.xcassets/Nav*.imageset/`
- NavHome, NavBack, NavClose, NavCorrect, NavInfo, NavSettings

### City & State Icons
- CityRome, CityFlorence
- StateAvailable, StateComplete, StateConstruction, StateLocked, StateRibbon

### Resizing New Assets
```bash
sips -Z 180 "filename.png"   # Science icons
sips -Z 120 "filename.png"   # Navigation icons
sips -Z 512 "filename.png"   # City icons
sips -Z 600 "filename.png"   # Challenge diagrams
```

## Color Palette (RenaissanceColors.swift)
```swift
// Primary
RenaissanceColors.parchment       // #F5E6D3 - Aged paper
RenaissanceColors.sepiaInk        // #4A4035 - Text
RenaissanceColors.renaissanceBlue // #5B8FA3 - Accents, water
RenaissanceColors.terracotta      // #D4876B - Rome buildings
RenaissanceColors.ochre           // #C9A86A - Renaissance buildings
RenaissanceColors.sageGreen       // #7A9B76 - Completion

// Accent
RenaissanceColors.deepTeal        // #2B7A8C - Venice water
RenaissanceColors.warmBrown       // #8B6F47 - Engineering
RenaissanceColors.stoneGray       // #A39D93 - Materials

// Special
RenaissanceColors.goldSuccess     // #DAA520 - Success glow
RenaissanceColors.errorRed        // #CD5C5C - Errors
RenaissanceColors.blueprintBlue   // #4169E1 - Grid lines
```

## Current Status (Feb 6, 2025)

### Completed
- [x] SwiftUI + SpriteKit Xcode project
- [x] MVVM architecture with shared ViewModel
- [x] Leonardo's Notebook aesthetic throughout
- [x] Custom fonts via CoreText
- [x] Main menu with quill animation
- [x] **SpriteKit city map with 17 buildings**
- [x] **Pan, zoom, tap controls (iOS + macOS)**
- [x] **Rivers: Tiber, Arno, Grand Canal**
- [x] **Zone labels for 6 regions**
- [x] **Shared progress between map and era views**
- [x] City grid view with era filtering
- [x] Building detail overlay with science badges
- [x] iPad sidebar navigation
- [x] Profile view with science mastery
- [x] Challenge system (6 buildings have content)
- [x] Interactive drag-drop + flow tracing questions
- [x] Pow celebration effects
- [x] All 13 custom Midjourney science icons
- [x] **Mascot characters (Splash + Bird)**
- [x] **MascotDialogueView with 3 choice buttons**
- [x] **MaterialPuzzleView - Match-3 puzzle game**
- [x] **Gravity system (tiles fall, new spawn from top)**
- [x] **Distractor elements (Fe, C, Mg, S)**
- [x] **Auto-reshuffle when no valid moves**
- [x] **Mascot follows cursor on map**
- [x] **Mascot walks to buildings with bounce animation**
- [x] **Mascot entrance animation in puzzle view**
- [x] **SwiftUI mascot overlay (consistent look everywhere!)**
- [x] **Workshop mini-game (Township-style SpriteKit crafting)**
- [x] **PlayerNode (da Vinci stick figure with walk/idle animations)**
- [x] **10 resource stations with collection + respawn**
- [x] **Workbench mixing + Furnace firing with temperature**
- [x] **Educational "Did You Know?" popups after crafting**
- [x] **PencilKit watercolor paint mode on city map (iOS)**
- [x] **Drawing save/load via UserDefaults**
- [x] **Waypoint pathfinding (64-node Dijkstra) for Workshop**
- [x] **Apprentice 15-frame walk animation (ApprenticeFrame00-14)**
- [x] **Editor mode: drag waypoints, toggle edges, dump positions**
- [x] **Workshop terrain (separate from city terrain)**
- [x] **6 station sprite images (quarry, river, volcano, clay pit, mine, forest)**
- [x] **Volcano 15-frame animation (VolcanoFrame00-14 at 15fps)**
- [x] **Interior crafting room (WorkshopInteriorView) with 4 tappable stations**
- [x] **Outdoor → indoor transition (workbench/furnace enters crafting room)**
- [x] **Interior furniture art (furnace, workbench, pigment table, storage shelf)**

### Session Log - Feb 6, 2025
- Fixed mascot consistency: Now using SwiftUI overlay instead of SpriteKit rendering
- CityScene tracks position, CityMapView renders SwiftUI SplashCharacter + BirdCharacter
- Mascot looks identical on map, in dialogue, and in puzzle views
- Added resize_assets.sh utility script
- Updated .gitignore for backup files and original Midjourney sources

### Session Log - Feb 8, 2025
- Workshop mini-game: Township-style SpriteKit crafting (PlayerNode, ResourceNode, WorkshopScene)
- Material/Recipe/CraftedItem models with workbench mixing + furnace firing
- WorkshopState with station stocks, collection, respawn timer, educational popups
- PencilKit watercolor paint mode on CityMapView (iOS) with save/load via UserDefaults
- macOS fallback: SwiftUI Canvas drawing with green+yellow strokes
- Fixed hint bubble overlapping collection panel (moved hint to top of screen)
- Explored GPU shaders (watercolorFill, waterFill) — removed in favor of PencilKit manual painting

### Session Log - Feb 10, 2025
- Added Terrain.png background to city map and workshop scenes
- Added BackgroundMain.png asset, new fonts (Amellina, GreatVibes)
- Added SceneEditorMode.swift (DEBUG-only drag-to-reposition nodes)
- Fixed terrain sizing: terrain sprite = mapSize so full image visible at default zoom
- Both scenes use `.aspectFill` scaleMode — camera scale 1.0 shows entire map
- Removed redundant parchment color rectangles behind terrain
- Scene backgroundColor matches terrain edge color for seamless look

### Session Log - Feb 11, 2025
- **MoleculeView.swift** — Chemical structure diagrams for 7 molecules (H₂O, Ca(OH)₂, SiO₂, CaCO₃, CO₂, Na₂O, C₆H₆)
  - Custom SwiftUI Canvas rendering with atom circles + bond lines
  - Animated sketch-in effect: bonds first, then atoms pop in
  - Shown in MaterialPuzzleView success overlay after completing a formula
  - Data models: BondType, MoleculeAtom, MoleculeBond, MoleculeData (in Challenge.swift)
- **Bird 13-frame animation** — Extracted 125 frames from Midjourney/Pika GIF, selected 13 key frames
  - Marina removed backgrounds in Photoshop, exported to `Styles/bird_frames/clean/`
  - BirdFrame00-12 imagesets in Assets.xcassets, Timer-based animation at 15fps
  - BirdCharacter supports `isSitting` mode (SittingBird1/SittingBird2 alternation)
- **Bird behavior updates** — Bird sits on dialogue box, flies in then lands on puzzle screen
  - MaterialPuzzleView: replaced walking animation with fly-in + land (birdHasLanded)
  - All bird frames set to 200px across views (map, dialogue, puzzle, workshop)
  - Workshop hint bubble bird: 80px
- **Bond rendering fix** — Removed dashed ionic bonds, all bonds now solid with fixed 16pt inset

## GIF Frame Extraction Workflow

Standard process for turning Midjourney/Pika animated GIFs into sprite frame animations:

### Step 1 — Extract all frames from GIF (Claude does this)
```python
python3 -c "
from PIL import Image
import os
gif = Image.open('INPUT.gif')
os.makedirs('OUTPUT_FOLDER', exist_ok=True)
frame = 0
while True:
    gif.seek(frame)
    img = gif.copy().convert('RGBA').resize((512, 512), Image.LANCZOS)
    img.save(f'OUTPUT_FOLDER/frame_{frame:03d}.png')
    frame += 1
"
```
- **IMPORTANT:** Always extract at **512x512** (not 320). Sprites displayed at 170pt need 340px on 2x retina — 512px source gives SpriteKit room to downsample cleanly instead of upscaling.
- Typically yields 100-125 frames

### Step 2 — Select best 15 key frames (Claude does this)
- Pick every Nth frame for even spacing (e.g., every 8th from 125 frames)
- Copy to `OUTPUT_FOLDER/selected/` subfolder
- Name them with original frame numbers (e.g., `frame_000.png`, `frame_008.png`, ...)

### Step 3 — Remove backgrounds (Marina does this in Photoshop)
- Open each selected frame in Photoshop
- Remove background, export as PNG with transparency
- Save clean PNGs to `OUTPUT_FOLDER/clean/` subfolder

### Step 4 — Create imagesets (Claude does this)
- Create `Assets.xcassets/[Name]Frame00-14.imageset/` from clean PNGs
- Each imageset gets a `Contents.json` + the PNG
- Update BirdCharacter-style animation code: Timer at 15fps, `frameCount` = number of frames

### Folder Structure
```
Styles/[name]_frames/          # All extracted frames (gitignored)
Styles/[name]_frames/selected/ # 15 key frames (originals with bg)
Styles/[name]_frames/clean/    # Marina's Photoshop exports (no bg)
Assets.xcassets/[Name]Frame00-14.imageset/  # Final imagesets for app
```

### Session Log - Feb 12, 2025
- **Waypoint pathfinding** for Workshop scene — apprentice walks along roads instead of straight lines
  - 64-waypoint graph with ~100 bidirectional edges, Dijkstra shortest-path
  - PlayerNode.walkPath() chains waypoint segments with facing direction updates at corners
  - Stations within 150pt walk directly (Workbench ↔ Furnace), longer routes go through road network
  - Editor mode (press E): shows numbered orange dots + orange edge lines, drag to reposition
  - Press C with waypoint selected → click another to toggle edge connection
  - Press R to redraw edges after dragging
  - Exit editor (E again) dumps full waypoints + edges arrays to console in copy-paste Swift format
- **SceneEditorMode** — added `onToggle` and `onNodeSelected` callbacks
- **Apprentice sprite animation** — 15-frame walk cycle from Midjourney GIF (ApprenticeFrame00-14)

## Waypoint Pathfinding System (Feb 12, 2025)

### Overview
Workshop apprentice walks along a waypoint road network instead of straight lines. 64 road junctions connected by ~100 edges, with Dijkstra shortest-path routing.

### Key Files
| File | Change |
|------|--------|
| `PlayerNode.swift` | `walkPath(_:speed:completion:)` — chains waypoint segments with per-corner facing |
| `WorkshopScene.swift` | 64 waypoints, adjacency edges, Dijkstra, station-to-waypoint mapping |
| `SceneEditorMode.swift` | `onToggle` + `onNodeSelected` callbacks for workshop debug overlay |

### Road Network Layout (6 rows)
| Row | Y range | Contents |
|-----|---------|----------|
| A | ~830-870 | Top edge: quarry, river, volcano, clay pit approaches |
| B | ~700-760 | Upper roads |
| C | ~550-650 | Mid band |
| D | ~420-500 | Center: forest, workbench, furnace, mine |
| E | ~280-370 | South roads |
| F | ~150-220 | Bottom: market, pigment table |

### Editor Mode Workflow
1. Open Workshop, press **E** → 64 orange numbered dots + edge lines appear
2. **Drag** dots to match new terrain roads
3. **C** + click another dot → toggle edge between them
4. **R** → redraw edge lines after dragging
5. **E** again → dumps `waypoints` array + `waypointEdges` array to Xcode console

### How Pathfinding Works
1. Player taps a station
2. If distance < 150pt → walk directly (adjacent stations)
3. Otherwise: find nearest 2-3 waypoints to player, look up station's waypoints
4. Dijkstra with virtual start/end nodes finds shortest path
5. `playerNode.walkPath(path, speed: 200)` walks segment-by-segment

## Workshop Crafting System (Implemented Feb 13, 2025)

### Architecture: Outdoor + Indoor
Split into **outdoor gathering** (SpriteKit map) + **indoor crafting** (SwiftUI view):

**Outdoor Map (WorkshopScene + WorkshopMapView):**
- Apprentice walks between 8 resource stations collecting materials
- 6 stations have Midjourney sprite images (quarry, river, volcano, clay pit, mine, forest)
- Volcano has 15-frame looping animation (VolcanoFrame00-14 at 15fps)
- Walking to Workbench or Furnace → transitions to interior crafting room
- WorkshopTerrain.png (2912x1632) — dedicated terrain separate from city map

**Interior Room (WorkshopInteriorView):**
- WorkshopBackground.png fills screen — Leonardo's workshop room interior
- 4 tappable furniture stations positioned in the room:
  - **Workbench** (InteriorWorkbench) — 4 mixing slots, material picker, recipe detection, Mix button
  - **Furnace** (InteriorFurnace) — temperature picker (Low/Medium/High), FIRE button, progress bar
  - **Pigment Table** (InteriorPigmentTable) — shows pigment recipes with ingredient checklist
  - **Storage Shelf** (InteriorShelf) — full inventory display of raw materials + crafted items
- Educational "Did You Know?" popup after successful crafting
- "Back to Workshop" button returns to outdoor map

### Navigation Flow
```
WorkshopView (manages outdoor/indoor state)
├── WorkshopMapView (outdoor - SpriteKit)
│   ├── Collect materials from resource stations
│   └── Walk to Workbench/Furnace → showInterior = true
└── WorkshopInteriorView (indoor - SwiftUI)
    ├── Tap furniture → crafting overlay
    └── "Back to Workshop" → showInterior = false
```

### Station Sprite Images
| Station | Asset Name | Source Image |
|---------|-----------|--------------|
| Quarry | StationQuarry | LimestoneQuarry.png |
| River | StationRiver | FreshWaterSpring.png |
| Volcano | StationVolcano | Volcano.png (+ 15-frame animation) |
| Clay Pit | StationClayPit | ClayPit.png |
| Mine | StationMine | Mining.png |
| Forest | StationForest | Forest.png |
| Pigment Table | (shape fallback) | — |
| Market | (shape fallback) | — |
| Workbench | (shape fallback) | — |
| Furnace | (shape fallback) | — |

ResourceNode uses `stationType.imageName` to load sprites (120pt SKSpriteNode). Falls back to hand-drawn SKShapeNode paths for stations without images.

### Session Log - Feb 13, 2025
- **Workshop terrain** — WorkshopTerrain.png replaces shared Terrain.png for workshop scene
- **6 station sprite images** — Midjourney art resized to 512px, displayed as 120pt SKSpriteNode
- **Volcano 15-frame animation** — extracted 125 GIF frames, selected 15 at 512x512, SKAction.animate at 15fps
  - Pauses when depleted, resumes when restocked
  - Frames need background removal in Photoshop (Styles/volcano_frames/selected/)
- **Interior crafting room** — new WorkshopInteriorView.swift with room background + 4 tappable furniture
  - Workbench: 4 mixing slots + material picker + recipe detection
  - Furnace: temperature picker + fire button + progress animation
  - Pigment Table: shows pigment recipes with ingredient availability
  - Storage Shelf: full inventory grid of raw materials + crafted items
- **Outdoor→indoor transition** — WorkshopView manages state, slide animation between views
- **Updated .gitignore** — added volcano_frames/, apprentice_frames/, bird_turn_frames/ to exclusions
- **Workshop camera fix** — matched all camera params to city map: .aspectFill, zoom 0.5-3.5, padding 500, removed position reset in fitCameraToMap
- **Interior editor mode** — SwiftUI drag-to-reposition editor for WorkshopInteriorView furniture positions
  - Press E to toggle, drag furniture to new positions, yellow highlight + coordinate label
  - Dumps relative positions (0-1) to console on exit in copy-paste Swift format
- **CLAUDE.md rule** — editor mode REQUIRED for all new scenes/views, camera panning pattern documented

### Session Log - Feb 13, 2025 (Part 2)
- **Tile-based expandable map system** — CityScene terrain converted from single sprite to tile grid
  - `TerrainTile` struct: imageName (nil = placeholder), origin point, size
  - `terrainTiles` array in CityScene.swift — add entries to expand map in any direction
  - `mapSize` is now a computed `lazy var` that auto-calculates from all tiles
  - Placeholder tiles render parchment rectangle + dashed border + "Expansion Area" label
  - Camera, grid, buildings all auto-adjust since they reference `mapSize`
  - To expand: add terrain art to Assets, add TerrainTile entry, build — done

### Session Log - Feb 13, 2025 (Part 3)
- **Sketching Mini-Game** — Renaissance architectural drawing system replacing quizzes as primary building interaction
  - 4 historical phases: Pianta (floor plan), Alzato (elevation), Sezione (section), Prospettiva (perspective)
  - Phase 1 (Pianta) fully implemented: squared grid canvas, wall drawing, column placement, room detection, proportion validation
  - Data models: `SketchingChallenge`, `SketchingPhase`, `SketchingPhaseContent`, `PiantaPhaseData`, grid/validation types
  - Content for 4 buildings: Pantheon, Colosseum, Aqueduct, Duomo (each with Phase 1)
  - `SketchingChallengeView` orchestrator: intro → phase selector → canvas → completion with Pow effects
  - `PiantaCanvasView`: SwiftUI Canvas grid, DragGesture wall drawing, snap-to-grid, flood-fill room detection
  - `SketchingToolbarView`: wall/column/room label/eraser/undo tool palette
  - 3-level hint system: tap hint button → area highlight → dotted outline → full guide lines
  - BuildingState expanded: `.sketched` state between `.available` and `.construction`
  - `SketchingProgress` tracks completed phases per building in `BuildingPlot`
  - BuildingPlotView shows 4-stage visual progression (blank → sketched → construction → complete)
  - Routing updated: building cards → sketching first, quiz fallback for buildings without sketching content
  - Mascot "I need to sketch it" choice now routes to sketching challenge
  - `KnowledgeTestsView` — quizzes relocated to separate sidebar section "Knowledge Tests"
  - All existing quiz code untouched — still accessible via Knowledge Tests and "I don't know" mascot path

### Session Log - Feb 13, 2025 (Part 4)
- **Bird companion hint system** — interactive hint guide on PiantaCanvasView
  - BirdCharacter (80x80) sits at top-right of canvas with idle bounce animation
  - 3-level progressive hints: tap "Ask Bird" → area highlight → dotted outline → full guide lines + column markers
  - Bird flies to target rooms, shows speech bubbles with contextual messages
  - Encouragement: "Great first wall!" (first wall), "Column placed!" (first column), "A perfect circle!" (first circle)
  - Celebration: bird excited jump + "Perfect ratio!" when room matches target proportions
  - Final validation: "Magnifico! A true architect!" on plan completion
- **Circle drawing tool** — Pantheon rotunda is now a circle (historically accurate)
  - `RoomShape` enum: `.rectangle`, `.circle` added to `RoomDefinition`
  - `CirclePlacement` struct (center + radius in grid cells)
  - Circle tool in toolbar: drag from center outward to set radius, preview shows "r=N"
  - Circle detection: exact center + radius match required (strict validation)
  - Hint overlays show circle outlines for circle targets
  - Pantheon rotunda data updated: circle with center (5,6), diameter 6
- **Strict validation system** — prevents passing with messy/random drawings
  - Circle: center and radius must match exactly (0 tolerance)
  - Rectangles: 90% wall coverage required per side (was 70%)
  - Neatness check: max 1 extra circle, max 3x expected walls, max 2 extra columns
  - Visual feedback panel: room-by-room checklist, neatness warnings, column count
  - Bird speech on failure: "Too many circles!" / "Too many walls!" / etc.
- **GameTopBarView** — shared top navigation bar across City Map, Workshop, Crafting Room
  - Left: quick-nav buttons (Profile, Map, Eras, Workshop) with icons + labels
  - Center-right: screen title capsule
  - Bottom strip: horizontal scrollable building progress icons with plot numbers
  - Each building shows colored icon (green=complete, ochre=sketched, gray=locked)
  - Back button (optional) for Workshop/Crafting Room screens
  - `onNavigate` callback routes to `SidebarDestination` from any screen
  - Replaces per-view custom top bars with consistent UI system

## Sketching Mini-Game System (Feb 13, 2025)

### Architecture
```
Building card → BuildingDetailOverlay → "Begin Sketching" → SketchingChallengeView → Phase views
                                      → "Begin Challenge" (fallback if no sketching content)
```

### Key Files
| File | Purpose |
|------|---------|
| `Models/SketchingChallenge.swift` | All data models: phases, grid types, validation |
| `Models/SketchingContent.swift` | Static challenge data per building (Pantheon, Colosseum, Aqueduct, Duomo) |
| `Views/SketchingChallengeView.swift` | Master orchestrator: intro → phases → completion |
| `Views/Sketching/PiantaCanvasView.swift` | Phase 1: grid canvas, wall drawing, room detection |
| `Views/Sketching/SketchingToolbarView.swift` | Shared tool palette |
| `Views/KnowledgeTestsView.swift` | Quiz challenges list (relocated from building cards) |

### Building Flow (New vs Old)
```
OLD: Building card → Quiz questions
NEW: Building card → Sketching phases → (future: materials → construction)
     Quizzes → Sidebar "Knowledge Tests" or mascot "I don't know" path
```

### 4-Stage Building Card Progression
1. **Blank** — dashed placeholder + grid lines (no sketching done)
2. **Sketched** — sepia ink icon + "Sketched" label (sketching phases complete)
3. **Under Construction** — (future: materials gathered)
4. **Complete** — green tint + checkmark (all done)

### PiantaCanvasView Mechanics
- SwiftUI Canvas with squared grid (12x12 or 16x16)
- DragGesture draws walls (snaps to horizontal/vertical)
- Tap places columns at grid intersections
- Room detection: checks wall coverage (70% threshold per side) against target rooms
- Proportion validation: compares room width:height to required ratio (tolerance 0.15)
- 3-level hint: area highlight → dotted outline → full guide lines
- Pow spray celebration on successful validation

### Data Model Pattern
```swift
SketchingContent.sketchingChallenge(for: "Pantheon")  // Same pattern as ChallengeContent
```

## Shared UI System — GameTopBarView (Feb 13, 2025)

### Overview
Consistent top navigation bar displayed across City Map, Workshop, and Crafting Room screens. Based on UISystem.JPG hand-drawn wireframe.

### Layout
```
+--[←]--[👤 Profile]--[🗺 Map]--[🏛 Eras]--[🔨 Workshop]------[Screen Title]--+
|                                                                                 |
+--[ 01 ][ 02 ][ 03 ][ 04 ][ 05 ][ 06 ][ 07 ]... (scrollable building strip)--+
```

### Integration
| Screen | File | Title | Back Button |
|--------|------|-------|-------------|
| City Map | CityMapView.swift | "City of Learning" | No |
| Workshop (outdoor) | WorkshopMapView.swift | "Workshop" | Yes (dismiss) |
| Crafting Room | WorkshopInteriorView.swift | "Crafting Room" | Yes (onBack) |

### Navigation Flow
Nav buttons trigger `onNavigate(SidebarDestination)` callback → ContentView's `selectedDestination` changes → view switches.

### Building Strip
Horizontal ScrollView showing all 17 buildings:
- **Green** icon = completed
- **Ochre** icon = sketched
- **Gray** icon = locked/available
- Plot number (01-17) below each icon

### Key File
`Views/GameTopBarView.swift` — shared component, takes `title`, `viewModel`, `onNavigate`, optional `showBackButton` + `onBack`.

## Tile-Based Expandable Map (Feb 13, 2025)

### How It Works
CityScene uses a `terrainTiles` array instead of a single terrain sprite. Each tile has an optional image, an origin point, and a size. `mapSize` auto-computes from tile bounds.

### Adding New Tiles
```swift
// In CityScene.swift — terrainTiles array
private let terrainTiles: [TerrainTile] = [
    TerrainTile(imageName: "Terrain", origin: .zero, size: CGSize(width: 3500, height: 2500)),          // Current map
    TerrainTile(imageName: "TerrainEast", origin: CGPoint(x: 3500, y: 0), size: CGSize(width: 3500, height: 2500)),  // East expansion
]
```

### Expansion Directions
| Direction | Origin | Notes |
|-----------|--------|-------|
| East (right) | `(3500, 0)` | Zero-effort, no coordinate shifts |
| North (up) | `(0, 2500)` | Zero-effort, no coordinate shifts |
| Northeast | `(3500, 2500)` | Zero-effort |
| West/South | Negative origins | Requires shifting all existing building/decoration coordinates |

### Next Steps
- [ ] Remove backgrounds from volcano frames (Marina in Photoshop)
- [ ] Adjust 64 waypoints to match new terrain in editor mode
- [ ] Add station sprites for remaining 4 stations (pigment table, market, workbench, furnace)
- [ ] Create challenges for remaining 11 buildings
- [ ] Add building images to map
- [x] Design architecture/sketching gameplay (see Research + Sketching System sections)
- [x] Sketching game Phase 1 (Pianta floor plan) — implemented
- [ ] Sketching game Phase 2 (Alzato elevation) — drag-drop facade elements
- [ ] Sketching game Phase 3 (Sezione cross-section) — structural + light rays
- [ ] Sketching game Phase 4 (Prospettiva perspective) — vanishing points
- [ ] Add sketching content for remaining buildings (currently: Pantheon, Colosseum, Aqueduct, Duomo)
- [ ] Rising answer mechanic (LinguaLeo-style)
- [ ] Sound effects (challenge_success, challenge_fail, puzzle_match)
- [ ] Persist progress with UserDefaults/SwiftData
- [ ] Building construction animation
- [ ] Full bloom animation (gray sketch → watercolor)
- [ ] Generate expansion terrain tiles for map growth

## How to Run
1. Open `RenaissanceArchitectAcademy.xcodeproj` in Xcode
2. Select iPad simulator or "My Mac"
3. Press Cmd+R to build and run

## Key Architecture Patterns
- **MVVM**: Views observe ViewModels via `@ObservedObject` (shared) or `@StateObject`
- **@MainActor**: ViewModels run on main thread
- **SpriteKit + SwiftUI**: SpriteView bridges SKScene into SwiftUI hierarchy
- **Platform conditionals**: `#if os(iOS)` / `#else` for UIKit vs AppKit (PlatformColor typealias)
- **NavigationSplitView**: iPad/Mac sidebar navigation
- **Shared ViewModel**: ContentView owns CityViewModel, passes to child views
- **Callback-based communication**: SpriteKit → SwiftUI via closures (onBuildingSelected, onMascotReachedBuilding)
- **Consistent character design**: MascotNode (SpriteKit) matches SplashCharacter/BirdCharacter (SwiftUI)
- **Editor Mode REQUIRED for ALL scenes/views**: Every new scene or view with positioned elements MUST have editor mode integrated on creation (DEBUG-only). This is a MANDATORY requirement — no exceptions.
  - **SpriteKit scenes**: Use `SceneEditorMode` class. Press E to toggle, drag nodes to reposition, arrows to nudge, dumps positions to console on exit. See CityScene.swift and WorkshopScene.swift for reference.
  - **SwiftUI views with positioned elements**: Add `#if DEBUG` editor state variables, `DragGesture` on positionable items, yellow highlight on selected item, coordinate labels, `.onKeyPress("e")` to toggle, and `dumpPositions()` on exit. See WorkshopInteriorView.swift for reference.
  - Both types: Press E to toggle on/off, print all positions to Xcode console on deactivation in copy-paste Swift format.
- **Camera/panning for ALL SpriteKit scenes**: Every SpriteKit scene with a camera must use the same camera pattern as CityScene.swift: `.aspectFill` scale mode, zoom range `0.5-3.5`, `fitCameraToMap()` on setup + `didChangeSize`, `clampCamera()` with generous padding. Smaller maps need larger padding to maintain panning freedom (e.g., workshop uses 500 vs city's 200).

## Git Commands
```bash
cd /Users/pollakmarina/RenaissanceArchitectAcademy
git add . && git commit -m "message" && git push origin main
```

## Notes
- Marina prefers direct fixes over long explanations
- Teach concepts as you go when making changes
- Always push to GitHub after significant changes
- Target: iOS 17+, macOS 14+
- New Midjourney assets are usually huge - always resize before adding
- Challenge.swift contains all questions - edit there to add/modify
- SpriteKit uses string building IDs, ViewModel uses integer plot IDs
