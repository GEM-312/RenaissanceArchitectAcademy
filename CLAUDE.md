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
│   │   └── SpriteKit/                      # NEW: SpriteKit city map
│   │       ├── CityScene.swift             # Main SKScene with buildings, rivers, zones
│   │       ├── BuildingNode.swift          # Tappable building sprites
│   │       └── CityMapView.swift           # SwiftUI wrapper for SpriteKit
│   ├── ViewModels/
│   │   └── CityViewModel.swift        # @MainActor, @Published state, 17 buildings
│   ├── Models/
│   │   ├── Building.swift             # Era, RenaissanceCity, Science, Building, BuildingPlot, BuildingState
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

### Next Steps
- [ ] Create challenges for remaining 11 buildings
- [ ] Add Midjourney building images to map
- [ ] Mascot character (watercolor splash)
- [ ] Rising answer mechanic (LinguaLeo-style)
- [ ] Sound effects (challenge_success, challenge_fail)
- [ ] Persist progress with UserDefaults/SwiftData
- [ ] Building construction animation
- [ ] Full bloom animation (gray sketch → watercolor)

## How to Run
1. Open `RenaissanceArchitectAcademy.xcodeproj` in Xcode
2. Select iPad simulator or "My Mac"
3. Press Cmd+R to build and run

## Key Architecture Patterns
- **MVVM**: Views observe ViewModels via `@ObservedObject` (shared) or `@StateObject`
- **@MainActor**: ViewModels run on main thread
- **SpriteKit + SwiftUI**: SpriteView bridges SKScene into SwiftUI hierarchy
- **Platform conditionals**: `#if os(iOS)` / `#else` for UIKit vs AppKit types
- **NavigationSplitView**: iPad/Mac sidebar navigation
- **Shared ViewModel**: ContentView owns CityViewModel, passes to child views

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
