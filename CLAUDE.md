# Claude Memory - Renaissance Architect Academy

## Project Overview
Educational city-building game where students solve architectural challenges across 13+ sciences. Leonardo da Vinci notebook aesthetic with watercolor + blueprint style.

**Developer:** Marina Pollak
**School:** Columbia College Chicago - Final Semester
**Timeline:** Jan 30 - May 15, 2025

## Tech Stack
- SwiftUI (iOS 17+ / macOS 14+)
- Swift 5.0+
- Xcode project (multiplatform - iPad + macOS only)
- SPM packages: Vortex 1.0.4, Pow 1.0.5, Subsonic 0.2.0
- Midjourney AI art (style ref: `--sref 3186415970`)
- GitHub: https://github.com/GEM-312/RenaissanceArchitectAcademy

## Project Structure
```
RenaissanceArchitectAcademy/
├── RenaissanceArchitectAcademy.xcodeproj/
├── RenaissanceArchitectAcademy/
│   ├── RenaissanceArchitectAcademyApp.swift  # @main entry point
│   ├── Views/
│   │   ├── ContentView.swift          # Root view, navigation state
│   │   ├── MainMenuView.swift         # Title screen with decorative corners
│   │   ├── CityView.swift             # 6 building plots grid + progress
│   │   ├── BuildingPlotView.swift     # Individual plot card
│   │   ├── BuildingDetailOverlay.swift # Modal with sciences
│   │   ├── SidebarView.swift          # iPad sidebar navigation
│   │   ├── ProfileView.swift          # Student profile, achievements
│   │   └── BloomEffectView.swift      # Particle effects for completion
│   ├── ViewModels/
│   │   └── CityViewModel.swift        # @MainActor, @Published state
│   ├── Models/
│   │   ├── Building.swift             # Era, Science, Building, BuildingPlot
│   │   └── StudentProfile.swift       # MasteryLevel, Achievement, Resources
│   ├── Styles/
│   │   ├── RenaissanceColors.swift    # Full color palette + gradients
│   │   └── RenaissanceButton.swift    # Custom button components
│   └── Services/
│       └── SoundManager.swift         # Audio playback with AVFoundation
├── CLAUDE.md
├── LICENSE
└── .gitignore
```

## Color Palette (RenaissanceColors.swift)
```swift
// Primary
RenaissanceColors.parchment       // #F5E6D3 - Aged paper
RenaissanceColors.sepiaInk        // #4A4035 - Text
RenaissanceColors.renaissanceBlue // #5B8FA3 - Accents
RenaissanceColors.terracotta      // #D4876B - Roofs/buildings
RenaissanceColors.ochre           // #C9A86A - Stone/highlights
RenaissanceColors.sageGreen       // #7A9B76 - Completion/nature

// Accent
RenaissanceColors.deepTeal        // #2B7A8C - Astronomy/water
RenaissanceColors.warmBrown       // #8B6F47 - Wood accents
RenaissanceColors.stoneGray       // #A39D93 - Materials

// Special Effects
RenaissanceColors.goldSuccess     // #DAA520 - Success glow
RenaissanceColors.errorRed        // #CD5C5C - Errors
RenaissanceColors.blueprintBlue   // #4169E1 - Technical overlays
RenaissanceColors.highlightAmber  // #FFBF00 - Highlights

// Gradients
RenaissanceColors.parchmentGradient  // Background
RenaissanceColors.goldenGlow         // Success radial
RenaissanceColors.blueprintOverlay   // Technical overlay
```

## Models

### Era
- `.ancientRome` - "Ancient Rome" (building.columns icon)
- `.renaissance` - "Renaissance" (paintpalette icon)

### Science (13 types)
Mathematics, Physics, Chemistry, Geometry, Engineering, Astronomy, Biology, Geology, Optics, Hydraulics, Acoustics, Materials Science, Architecture

Each has `iconName` (SF Symbols) and corresponding color via `RenaissanceColors.color(for:)`

### MasteryLevel
- `.apprentice` - Learning with guided tutorials
- `.architect` - Solving challenges with optional hints
- `.master` - No hints, full accuracy required

### StudentProfile
- Achievements (wax seal badges)
- ScienceMastery (per-science progress)
- Resources (goldFlorins, stoneBlocks, woodPlanks, pigmentJars)

## 6 Buildings
| # | Name | Era | Sciences |
|---|------|-----|----------|
| 1 | Aqueduct | Ancient Rome | Engineering, Hydraulics, Mathematics |
| 2 | Colosseum | Ancient Rome | Architecture, Engineering, Acoustics |
| 3 | Roman Baths | Ancient Rome | Hydraulics, Chemistry, Materials |
| 4 | Duomo | Renaissance | Geometry, Architecture, Physics |
| 5 | Observatory | Renaissance | Astronomy, Optics, Mathematics |
| 6 | Workshop | Renaissance | Engineering, Physics, Materials |

## Current Status (Feb 2, 2025)

### Completed
- [x] SwiftUI Xcode project (migrated from Unity)
- [x] MVVM architecture with @MainActor
- [x] Leonardo's Notebook aesthetic throughout
- [x] Main menu with decorative corners and animations
- [x] City view with 6 building plots + progress bar
- [x] Building detail overlay with science badges
- [x] iPad sidebar navigation with profile section
- [x] ProfileView with achievements, resources, science mastery
- [x] BloomEffectView for completion animations
- [x] SoundManager with AVFoundation
- [x] Complete color palette with 13+ science colors
- [x] Blueprint grid overlay effect
- [x] Wax seal achievement badges

### Next Steps
- [ ] Add custom fonts (Cinzel, EBGaramond, PetitFormalScript)
- [ ] Create challenge system/UI
- [ ] Generate Midjourney art assets
- [ ] Implement full bloom animation (gray sketch → watercolor)
- [ ] Add seal reward system
- [ ] Persist game progress with UserDefaults/SwiftData
- [ ] Integrate Vortex particle effects

## How to Run
1. Open `RenaissanceArchitectAcademy.xcodeproj` in Xcode
2. Select iPad simulator or "My Mac"
3. Press Cmd+R to build and run

## Key Architecture Patterns
- **MVVM**: Views observe ViewModels via `@StateObject`
- **@MainActor**: ViewModels run on main thread
- **Identifiable/Codable**: All models conform for persistence
- **SF Symbols**: Used for icons (no custom assets yet)
- **NavigationSplitView**: iPad/Mac sidebar navigation
- **horizontalSizeClass**: Adaptive layouts for different screens

## Git Commands
```bash
cd /Users/pollakmarina/RenaissanceArchitectAcademy
git add . && git commit -m "message" && git push origin main
```

## Notes
- Marina prefers direct fixes over long explanations
- Always push to GitHub after significant changes
- iPad only (TARGETED_DEVICE_FAMILY = 2)
- Custom fonts: add .ttf to project, register in Info.plist
- Target: iOS 17+, macOS 14+
