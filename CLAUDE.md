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
│   │   └── State*.imageset/                  # Building state icons
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
│   │   ├── WorkshopView.swift               # Workshop entry (wraps WorkshopMapView)
│   │   ├── WorkshopMapView.swift            # SwiftUI wrapper for WorkshopScene + overlays
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
│   │   └── Challenge.swift            # Challenge system + all building challenges
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

### Next Steps
- [ ] Generate map background art with Gemini (see prompts below)
- [ ] Create challenges for remaining 11 buildings
- [ ] Add building images to map
- [ ] Rising answer mechanic (LinguaLeo-style)
- [ ] Sound effects (challenge_success, challenge_fail, puzzle_match)
- [ ] Persist progress with UserDefaults/SwiftData
- [ ] Building construction animation
- [ ] Full bloom animation (gray sketch → watercolor)
- [ ] Sketching game (for "I need to sketch it" option)

## Gemini Map Art Prompts

The city map (3500x2500 points) is divided into 6 zones. Generate each tile at **1500x1200 px**, then stitch in Photoshop on a **7000x5000** canvas (2x retina).

### Zone I — Ancient Rome (left side, 8 buildings)
> Top-down bird's eye view of ancient Roman terrain, Leonardo da Vinci notebook style. Aged parchment paper background with faint grid lines. Warm terracotta and sandy ground with worn cobblestone paths connecting building plots. The Tiber River flows along the left edge, painted in soft watercolor blue-green washes. Scattered Mediterranean cypress trees drawn in sepia ink with sage green watercolor canopy. Dry golden-brown hills, Roman-era stone walls, dusty roads. Subtle ink-drawn topographic contour lines. Warm palette: terracotta, ochre, sandy beige, sepia brown. Hand-drawn map illustration style, watercolor on parchment. 1500x1200 pixels.

### Zone II — Florence (top right, 2 buildings)
> Top-down bird's eye view of Renaissance Florence terrain, Leonardo da Vinci notebook style. Aged parchment with faint grid lines. Rolling Tuscan hills with olive groves and vineyard rows drawn in fine sepia ink. The Arno River curves through the scene as a gentle watercolor blue wash. Lush green gardens with terracotta-tiled rooftop hints in the distance. Stone bridges, cypress-lined paths, and wildflower meadows. Soft watercolor washes of sage green, warm gold, and dusty rose. Elegant Italian countryside feel. Hand-drawn map illustration on aged paper. 1500x1200 pixels.

### Zone III — Venice (right side, 2 buildings)
> Top-down bird's eye view of Renaissance Venice terrain, Leonardo da Vinci notebook style. Aged parchment with faint grid lines. The Grand Canal flows in deep teal watercolor, with smaller canals branching off. Wooden dock pilings and gondola moorings sketched in sepia ink. Cobblestone squares (campi), small stone bridges arching over canals. Watercolor washes of deep teal, blue-green, warm stone gray, and ochre. Reflections shimmer in the water with soft white highlights. Maritime atmosphere with rope coils and fishing nets. Hand-drawn Venetian map on aged paper. 1500x1200 pixels.

### Zone IV — Padua (center, 1 building)
> Top-down bird's eye view of Renaissance Padua university town terrain, Leonardo da Vinci notebook style. Aged parchment with faint grid lines. Academic courtyard gardens with geometric herb beds and anatomical plant specimens. Cobblestone piazzas, arched colonnades drawn in fine sepia ink. Formal Italian garden paths with trimmed hedges in sage green watercolor. Stone walls, a small fountain, scattered books and scrolls as decorative elements. Scholarly atmosphere. Palette: warm stone, muted green, parchment gold, sepia. Hand-drawn map illustration. 1500x1200 pixels.

### Zone V — Milan (upper center, 2 buildings)
> Top-down bird's eye view of Renaissance Milan terrain, Leonardo da Vinci notebook style. Aged parchment with faint grid lines. An inventor's landscape: scattered engineering sketches fade into the ground like palimpsest. Workshop yards with timber stacks, gears, and pulleys sketched in sepia ink. Open fields for testing flying contraptions, with wind direction arrows. Lombardy poplar trees in soft green watercolor, irrigation canals, and brick paths. Industrial yet artistic atmosphere. Palette: warm brown, ochre, sage green, blueprint hints of blue ink. Hand-drawn map on aged paper. 1500x1200 pixels.

### Zone VI — Renaissance Rome (lower right, 2 buildings)
> Top-down bird's eye view of Renaissance papal Rome terrain, Leonardo da Vinci notebook style. Aged parchment with faint grid lines. Grand stone plazas with fountain sketches, obelisks, and ceremonial paths. Star charts and astronomical diagrams subtly watermarked into the ground. Printing press ink splatters as decorative texture. Marble columns, cypress trees, and formal gardens. Vatican-inspired grandeur with papal banners suggested in faded red and gold watercolor. Palette: marble white, gold, terracotta, deep sepia. Hand-drawn cartographic style on aged paper. 1500x1200 pixels.

### Stitching Instructions
- Canvas: 7000x5000 px (2x retina of 3500x2500 map)
- Zone I: left third (x: 0-2000)
- Zone V: upper center (x: 2000-3600, y: 2500-5000)
- Zone IV: center (x: 3000-5000, y: 2000-4000)
- Zone II: top right (x: 4000-7000, y: 3000-5000)
- Zone III: right (x: 5000-7000, y: 1500-3500)
- Zone VI: bottom right (x: 3500-6000, y: 0-2500)
- Era divider: vertical blend line around x: 2000-2400
- Use soft-edge blending between tiles for seamless transitions
- All tiles share the same parchment background (#F5E6D3) for consistency

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
