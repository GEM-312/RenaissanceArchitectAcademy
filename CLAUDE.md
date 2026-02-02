# Claude Memory - Renaissance Architect Academy

## Project Overview
Educational city-building game where students solve architectural challenges across 13+ sciences. Leonardo da Vinci notebook aesthetic with watercolor + blueprint style.

**Developer:** Marina Pollak
**School:** Columbia College Chicago - Final Semester
**Timeline:** Jan 30 - May 15, 2025

## Tech Stack
- SwiftUI (iOS 17+ / macOS 14+)
- Swift 5.0+
- Xcode project (multiplatform)
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
│   │   ├── MainMenuView.swift         # Title screen with buttons
│   │   ├── CityView.swift             # 6 building plots grid
│   │   ├── BuildingPlotView.swift     # Individual plot card
│   │   └── BuildingDetailOverlay.swift # Modal with sciences
│   ├── ViewModels/
│   │   └── CityViewModel.swift        # @MainActor, @Published state
│   ├── Models/
│   │   └── Building.swift             # Era, Science, Building, BuildingPlot
│   └── Styles/
│       ├── RenaissanceColors.swift    # Color palette enum
│       └── RenaissanceButton.swift    # Custom button component
├── CLAUDE.md
├── LICENSE
└── .gitignore
```

## Color Palette (RenaissanceColors.swift)
```swift
RenaissanceColors.parchment       // #F5E6D3 - Background
RenaissanceColors.sepiaInk        // #4A4035 - Text
RenaissanceColors.renaissanceBlue // #5B8FA3 - Accent
RenaissanceColors.terracotta      // #D4876B - Buildings
RenaissanceColors.ochre           // #C9A86A - Highlights
RenaissanceColors.sageGreen       // #7A9B76 - Completion
```

## Models

### Era
- `.ancientRome` - "Ancient Rome"
- `.renaissance` - "Renaissance"

### Science (13 types)
Mathematics, Physics, Chemistry, Geometry, Engineering, Astronomy, Biology, Geology, Optics, Hydraulics, Acoustics, Materials Science, Architecture

Each has an `iconName` property for SF Symbols.

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
- [x] MVVM architecture
- [x] Main menu with navigation
- [x] City view with 6 building plots
- [x] Building detail overlay with science badges
- [x] Color palette and custom button style

### Next Steps
- [ ] Add custom fonts (Cinzel, EBGaramond, PetitFormalScript)
- [ ] Create challenge system/UI
- [ ] Generate Midjourney art assets
- [ ] Implement "bloom" animation (gray sketch → watercolor)
- [ ] Add seal reward system
- [ ] Persist game progress

## How to Run
1. Open `RenaissanceArchitectAcademy.xcodeproj` in Xcode
2. Select "My Mac" or iOS Simulator
3. Press Cmd+R to build and run

## Key Architecture Patterns
- **MVVM**: Views observe ViewModels via `@StateObject`
- **@MainActor**: CityViewModel runs on main thread
- **Identifiable**: All models conform for ForEach
- **SF Symbols**: Used for icons (no custom assets yet)

## Git Commands
```bash
cd /Users/pollakmarina/RenaissanceArchitectAcademy
git add . && git commit -m "message" && git push origin main
```

## Notes
- Marina prefers direct fixes over long explanations
- Always push to GitHub after significant changes
- Custom fonts: add .ttf to project, register in Info.plist
- Target: iOS 17+, macOS 14+
