# Claude Memory - Renaissance Architect Academy

## Project Overview
Educational city-building game where students solve architectural challenges across 13+ sciences. Leonardo da Vinci notebook aesthetic with watercolor + blueprint style.

**Developer:** Marina Pollak
**School:** Columbia College Chicago - Final Semester
**Timeline:** Jan 30 - May 15, 2025

## Tech Stack
- SwiftUI (iOS 17+ / macOS 14+)
- Swift 5.9+
- Swift Playgrounds App format (.swiftpm)
- Midjourney AI art (style ref: `--sref 3186415970`)
- GitHub: https://github.com/GEM-312/RenaissanceArchitectAcademy

## Project Structure
```
RenaissanceArchitectAcademy/
├── RenaissanceArchitectAcademy.swiftpm/
│   ├── Package.swift
│   └── Sources/RenaissanceArchitectAcademy/
│       ├── RenaissanceArchitectAcademyApp.swift  # App entry point
│       ├── Views/
│       │   ├── ContentView.swift          # Root view with navigation
│       │   ├── MainMenuView.swift         # Title screen
│       │   ├── CityView.swift             # City with building plots
│       │   ├── BuildingPlotView.swift     # Individual plot display
│       │   └── BuildingDetailOverlay.swift # Building info modal
│       ├── ViewModels/
│       │   └── CityViewModel.swift        # City state management
│       ├── Models/
│       │   └── Building.swift             # Building, BuildingPlot, Era, Science
│       ├── Styles/
│       │   ├── RenaissanceColors.swift    # Color palette
│       │   └── RenaissanceButton.swift    # Custom button style
│       └── Resources/                     # Assets, fonts, images
├── CLAUDE.md
├── LICENSE
└── .gitignore
```

## Color Palette (RenaissanceColors.swift)
- Parchment: #F5E6D3
- Sepia Ink: #4A4035
- Renaissance Blue: #5B8FA3
- Terracotta: #D4876B
- Ochre: #C9A86A
- Sage Green: #7A9B76

## Current Status (Feb 2, 2025)

### Completed
- [x] SwiftUI project setup (migrated from Unity)
- [x] Color palette defined
- [x] Main menu view with title and buttons
- [x] City view with 6 building plots
- [x] Building models (Era, Science, Building, BuildingPlot)
- [x] CityViewModel for state management
- [x] Building detail overlay

### Next Steps
- [ ] Add custom Renaissance fonts (Cinzel, EBGaramond, PetitFormalScript)
- [ ] Implement challenge system
- [ ] Generate Midjourney art assets
- [ ] Add "bloom" animation (gray sketch → watercolor)
- [ ] Implement seal reward system
- [ ] Build challenge UI for each science type

## Key Design Decisions
1. **SwiftUI Multiplatform** - Works on iOS and macOS
2. **Swift Playgrounds format** - Easy to open and edit
3. **6 building plots** - Focused scope (3 Ancient Rome + 3 Renaissance)
4. **MVVM Architecture** - ViewModels manage state
5. **Science challenges** - Math, Physics, Chemistry, etc. integrated into gameplay
6. **Bloom animation** - Buildings transform when challenge is solved

## 6 Buildings
### Ancient Rome
1. **Aqueduct** - Engineering, Hydraulics, Mathematics
2. **Colosseum** - Architecture, Engineering, Acoustics
3. **Roman Baths** - Hydraulics, Chemistry, Materials Science

### Renaissance
4. **Duomo** - Geometry, Architecture, Physics
5. **Observatory** - Astronomy, Optics, Mathematics
6. **Workshop** - Engineering, Physics, Materials Science

## How to Run
1. Open `RenaissanceArchitectAcademy.swiftpm` in Xcode or Swift Playgrounds
2. Select target device (iOS Simulator, Mac, or physical device)
3. Build and run

## Notes for Future Sessions
- Marina prefers direct fixes over long explanations
- Always push to GitHub after significant changes
- Custom fonts need to be added to Resources folder and registered
