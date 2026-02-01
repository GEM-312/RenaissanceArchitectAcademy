# Claude Memory - Renaissance Architect Academy

## Project Overview
Educational city-building game where students solve architectural challenges across 13+ sciences. Leonardo da Vinci notebook aesthetic with watercolor + blueprint style.

**Developer:** Marina Pollak
**School:** Columbia College Chicago - Final Semester
**Timeline:** Jan 30 - May 15, 2025

## Tech Stack
- Unity 2022.3 LTS
- C#
- TextMeshPro for UI text
- Midjourney AI art (style ref: `--sref 3186415970`)
- WebGL build target
- GitHub: https://github.com/GEM-312/RenaissanceArchitectAcademy

## Project Structure
```
RenaissanceArchitectAcademy/
├── Assets/
│   ├── Fonts/           # Custom Renaissance fonts (Cinzel, EBGaramond, PetitFormalScript, Playwrite)
│   ├── Scenes/          # MainMenu.unity, Florence_City.unity
│   ├── Scripts/
│   │   ├── Core/        # GameManager, ResourceManager, SealRewardSystem
│   │   ├── Buildings/   # BuildingPlot, BuildingAnimator, ScienceVisualizationOverlay
│   │   ├── Challenges/  # ChallengeManager, SampleChallenges
│   │   ├── UI/          # UIManager, MainMenuController, RenaissanceButton, PageCurlTransition
│   │   └── Editor/      # RenaissanceAcademySetup, FontRegenerator
│   └── Art/             # Cities, Buildings, Nature, UI folders
└── DEVELOPMENT_GUIDE.md # Full project documentation
```

## Color Palette (GameColors.cs)
- Parchment: #F5E6D3
- Sepia Ink: #4A4035
- Renaissance Blue: #5B8FA3
- Terracotta: #D4876B
- Ochre: #C9A86A
- Sage Green: #7A9B76

## Current Status (Jan 31, 2025)

### Completed
- [x] Unity project setup
- [x] Core scripts (GameManager, ResourceManager, UIManager, etc.)
- [x] MainMenu scene with title, subtitle, tagline, buttons
- [x] Custom Renaissance fonts imported
- [x] FontRegenerator tool to fix TMP font shadow issues
- [x] Development Guide documentation

### Known Issues Fixed
- **Font shadow/outline bug**: Custom fonts (EBGaramond, PetitFormalScript) had unwanted shadows. Fixed by:
  1. Creating FontRegenerator.cs editor tool
  2. Run: Tools > Renaissance Academy > Fix Font Shadows
  3. Currently using LiberationSans as fallback until fonts are fixed

### Next Steps
- [ ] Run font fixer tool and restore custom fonts
- [ ] Generate Midjourney art assets
- [ ] Build Florence city scene with 6 building plots
- [ ] Implement camera pan/zoom
- [ ] Create building selection system
- [ ] Implement challenge system
- [ ] Bloom animation (gray sketch → watercolor)

## Important Commands

### Unity Editor Tools
- **Tools > Renaissance Academy > Setup Main Menu Scene** - Creates MainMenu scene structure
- **Tools > Renaissance Academy > Setup Florence City Scene** - Creates city scene
- **Tools > Renaissance Academy > Fix Font Shadows** - Fixes TMP font rendering issues
- **Tools > Renaissance Academy > Apply Renaissance Style to Selected UI** - Applies color palette

### Git
```bash
cd /Users/pollakmarina/RenaissanceArchitectAcademy
git add . && git commit -m "message" && git push origin main
```

## Key Design Decisions
1. **Single isometric view** - No first-person, always 3/4 top-down
2. **6 building plots** - Focused scope, not open-world
3. **2 eras** - Ancient Rome + Renaissance (3 buildings each)
4. **Science challenges** - Math, Physics, Chemistry, Geometry integrated into gameplay
5. **Bloom animation** - Buildings transform from gray sketch to full watercolor when challenge solved

## Notes for Future Sessions
- Marina prefers direct fixes over long explanations
- Font issues were caused by TMP material settings (OutlineWidth, GradientScale)
- Scene files are YAML - can be edited directly but need careful formatting
- Always push to GitHub after significant changes
