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
- SwiftUI (iOS 17+ / macOS 14+)
- Swift 5.0+
- Xcode project (multiplatform - iPad + macOS only)
- SPM packages:
  - Vortex 1.0.4 (particle effects)
  - Pow 1.0.5 (animations)
  - Subsonic 0.2.0 (audio)
  - Inferno 1.0.0 (Metal shader effects - watercolor, emboss, ripples)
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
│   │   └── ButtonFrame.imageset/             # Button frame (unused now)
│   ├── Fonts/                                # Custom Renaissance fonts
│   │   ├── Cinzel-*.ttf                      # Titles
│   │   ├── EBGaramond-*.ttf                  # Body text, buttons
│   │   └── PetitFormalScript-Regular.ttf     # Tagline
│   ├── Views/
│   │   ├── ContentView.swift          # Root view, navigation state
│   │   ├── MainMenuView.swift         # Title + particles + background image
│   │   ├── CityView.swift             # 6 building plots grid + progress
│   │   ├── BuildingPlotView.swift     # Individual plot card (engineering style)
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
│   │   └── RenaissanceButton.swift    # Engineering blueprint style buttons
│   ├── Services/
│   │   └── SoundManager.swift         # Audio playback with AVFoundation
│   └── building_complete.mp3          # Victory sound effect
├── CLAUDE.md
├── README.md
├── LICENSE
└── .gitignore
```

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

## UI Style - Engineering Blueprint

### Buttons (RenaissanceButton.swift)
- Double-line border (outer + inner rectangle)
- EBGaramond-Italic font with `.tracking(2)` letter spacing
- No icons (clean look)
- Parchment background with sepia ink text
- Staggered appearance animation on menu

### Building Cards (BuildingPlotView.swift)
- Ochre tinted background (10% opacity)
- Engineering grid pattern (minor lines every 15pt, major every 60pt)
- Double-line blueprint border
- UltraLight placeholder icons for incomplete buildings

## Main Menu Effects
- **Renaissance dome background** - Flipped horizontally, positioned left
- **Vortex dust particles** - Golden dust motes floating upward
- **Letter-by-letter animation** - "Renaissance" then "Architect Academy" appear like quill writing
- **Staggered button animation** - Buttons appear one by one with delay

## Sound Effects (Simplified)
Only meaningful moments - no button sounds:
- `building_complete.mp3` ✅ Added
- `challenge_success.mp3` - TODO
- `challenge_fail.mp3` - TODO
- `seal_stamp.mp3` - TODO
- `page_flip.mp3` - TODO (optional)

## Color Palette (RenaissanceColors.swift)
```swift
// Primary
RenaissanceColors.parchment       // #F5E6D3 - Aged paper
RenaissanceColors.sepiaInk        // #4A4035 - Text
RenaissanceColors.renaissanceBlue // #5B8FA3 - Accents
RenaissanceColors.terracotta      // #D4876B - Roofs/buildings
RenaissanceColors.ochre           // #C9A86A - Stone/highlights, card backgrounds
RenaissanceColors.sageGreen       // #7A9B76 - Completion/nature

// Accent
RenaissanceColors.deepTeal        // #2B7A8C - Astronomy/water
RenaissanceColors.warmBrown       // #8B6F47 - Engineering, wood accents
RenaissanceColors.stoneGray       // #A39D93 - Materials

// Special Effects
RenaissanceColors.goldSuccess     // #DAA520 - Success glow
RenaissanceColors.errorRed        // #CD5C5C - Errors
RenaissanceColors.blueprintBlue   // #4169E1 - Technical overlays
RenaissanceColors.highlightAmber  // #FFBF00 - Highlights
```

## Inferno Shader Effects (Available)
```swift
import Inferno

// Examples for Renaissance effects:
.colorEffect(ShaderLibrary.emboss())     // Sketch/engraving look
.distortionEffect(ShaderLibrary.water()) // Water ripple transitions
.colorEffect(ShaderLibrary.noise())      // Aged paper texture
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
- [x] Custom fonts (Cinzel, EBGaramond, PetitFormalScript) via CoreText
- [x] Main menu with Vortex dust particle effects
- [x] Letter-by-letter quill writing animation for title
- [x] Renaissance dome background image (flipped, positioned left)
- [x] Engineering blueprint style buttons (double-line border)
- [x] Staggered button appearance animation
- [x] City view with 6 building plots + blueprint grid overlay
- [x] Building cards with engineering style (ochre tint, grid pattern)
- [x] Building detail overlay with color-coded science badges
- [x] iPad sidebar navigation with profile section
- [x] ProfileView with achievements, resources, science mastery
- [x] BloomEffectView for completion animations
- [x] SoundManager (simplified - meaningful moments only)
- [x] building_complete.mp3 sound effect
- [x] Assets.xcassets setup
- [x] Inferno package added (Metal shader effects)
- [x] README.md

### Next Steps
- [ ] Use Inferno shaders for watercolor/artistic effects
- [ ] Generate more Midjourney art assets
- [ ] Create challenge system/UI
- [ ] Add remaining sound effects
- [ ] Implement full bloom animation (gray sketch → watercolor)
- [ ] Persist game progress with UserDefaults/SwiftData

## How to Run
1. Open `RenaissanceArchitectAcademy.xcodeproj` in Xcode
2. Select iPad simulator or "My Mac"
3. Press Cmd+R to build and run

## Key Architecture Patterns
- **MVVM**: Views observe ViewModels via `@StateObject`
- **@MainActor**: ViewModels run on main thread
- **Identifiable/Codable**: All models conform for persistence
- **SF Symbols**: Used for icons
- **NavigationSplitView**: iPad/Mac sidebar navigation
- **horizontalSizeClass**: Adaptive layouts for different screens
- **CoreText**: Manual font registration at app launch
- **Vortex**: Particle effects (dust motes on main menu)
- **Inferno**: Metal shader effects (watercolor, emboss, ripples)

## Git Commands
```bash
cd /Users/pollakmarina/RenaissanceArchitectAcademy
git add . && git commit -m "message" && git push origin main
```

## Notes
- Marina prefers direct fixes over long explanations
- Teach concepts as you go when making changes
- Always push to GitHub after significant changes
- iPad only (TARGETED_DEVICE_FAMILY = 2)
- Fonts: Must use CoreText registration (Info.plist UIAppFonts doesn't work with auto-generated plist)
- Target: iOS 17+, macOS 14+
