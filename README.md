# Renaissance Architect Academy

<p align="center">
  <img src="docs/Domo.png" alt="Renaissance Architect Academy" width="500">
</p>

<p align="center">
  <em>Where Science Builds Civilization</em>
</p>

---

## About

**Renaissance Architect Academy** is an educational city-building game where students solve architectural challenges across 13+ sciences. Inspired by Leonardo da Vinci's notebooks, the game features a unique watercolor + blueprint aesthetic that brings the Renaissance era to life.

Build iconic structures from Ancient Rome and the Renaissance period while mastering mathematics, physics, engineering, and more!

## The 13 Sciences

<p align="center">
  <img src="docs/icons/ScienceMath.png" alt="Mathematics" width="80">
  <img src="docs/icons/SciencePhysics.png" alt="Physics" width="80">
  <img src="docs/icons/ScienceChemistry.png" alt="Chemistry" width="80">
  <img src="docs/icons/ScienceGeometry.png" alt="Geometry" width="80">
  <img src="docs/icons/ScienceEngineering.jpg" alt="Engineering" width="80">
  <img src="docs/icons/ScienceAstronomy.png" alt="Astronomy" width="80">
  <img src="docs/icons/ScienceBiology.png" alt="Biology" width="80">
</p>

<p align="center">
  <img src="docs/icons/ScienceGeology.png" alt="Geology" width="80">
  <img src="docs/icons/ScienceOptics.png" alt="Optics" width="80">
  <img src="docs/icons/ScienceHydraulics.png" alt="Hydraulics" width="80">
  <img src="docs/icons/ScienceAcoustics.png" alt="Acoustics" width="80">
  <img src="docs/icons/ScienceMaterials.png" alt="Materials" width="80">
  <img src="docs/icons/ScienceArchitecture.png" alt="Architecture" width="80">
</p>

<p align="center">
  <sub>Mathematics • Physics • Chemistry • Geometry • Engineering • Astronomy • Biology</sub><br>
  <sub>Geology • Optics • Hydraulics • Acoustics • Materials Science • Architecture</sub>
</p>

## Features

- **17 Historic Buildings** - Construct aqueducts, colosseums, duomos, glassworks, and more across 6 zones
- **13 Sciences** - Master real architectural and scientific principles through hands-on challenges
- **Leonardo's Notebook Aesthetic** - Hand-drawn engineering style with watercolor touches
- **SpriteKit City Map** - Pan, zoom, and tap buildings on a 3500x2500 interactive map
- **Workshop Mini-Game** - Township-style crafting: collect materials, mix at workbench, fire in furnace
- **PencilKit Watercolor Paint** - Draw watercolor strokes directly on the map (iPad)
- **Two Historic Eras** - Ancient Rome and Renaissance Italy (Florence, Venice, Padua, Milan, Rome)
- **Mascot Characters** - Splash (ink blob) + Bird companion follow you around the map
- **Bird Animation** - 13-frame hand-drawn flying animation from Midjourney/Pika, background removed in Photoshop
- **Molecule Diagrams** - Chemical structure visualizations (H₂O, Ca(OH)₂, SiO₂, CaCO₃, CO₂, Na₂O, C₆H₆) with animated sketch-in effect
- **Match-3 Puzzle** - Collect chemical elements to build structures
- **Progress Tracking** - Track mastery levels from Apprentice to Master
- **Custom AI Art** - Midjourney icons and Gemini-generated map backgrounds

## 17 Buildings

### Ancient Rome (8 buildings)
| # | Building | Sciences |
|---|----------|----------|
| 1 | **Aqueduct** | Engineering, Hydraulics, Mathematics |
| 2 | **Colosseum** | Architecture, Engineering, Acoustics |
| 3 | **Roman Baths** | Hydraulics, Chemistry, Materials |
| 4 | **Pantheon** | Geometry, Architecture, Materials |
| 5 | **Roman Roads** | Engineering, Geology, Materials |
| 6 | **Harbor** | Engineering, Physics, Hydraulics |
| 7 | **Siege Workshop** | Physics, Engineering, Mathematics |
| 8 | **Insula** | Architecture, Materials, Mathematics |

### Renaissance Italy (9 buildings)
| # | City | Building | Sciences |
|---|------|----------|----------|
| 9 | Florence | **Il Duomo** | Geometry, Architecture, Physics |
| 10 | Florence | **Botanical Garden** | Biology, Chemistry, Geology |
| 11 | Venice | **Glassworks** | Chemistry, Optics, Materials |
| 12 | Venice | **Arsenal** | Engineering, Physics, Materials |
| 13 | Padua | **Anatomy Theater** | Biology, Optics, Chemistry |
| 14 | Milan | **Leonardo's Workshop** | Engineering, Physics, Materials |
| 15 | Milan | **Flying Machine** | Physics, Engineering, Mathematics |
| 16 | Rome | **Vatican Observatory** | Astronomy, Optics, Mathematics |
| 17 | Rome | **Printing Press** | Engineering, Chemistry, Physics |

## Tech Stack

- **SwiftUI** - iOS 17+ / macOS 14+
- **Swift 5.0+**
- **Xcode** - Multiplatform (iPad + macOS)
- **SPM Packages:**
  - Pow 1.0.5 (animations)
  - Subsonic 0.2.0 (audio)
  - Vortex 1.0.4 (particle effects)
- **Midjourney AI** - Art generation (style ref: `--sref 3186415970`)

## Team

| Role | Name |
|------|------|
| **Developer** | Marina Pollak |
| **Level Designer** | Ray Garmon |
| **Game Designer** | Brianna Walker |
| **Game Designer** | Richard Calleja |

## Installation

1. Clone the repository
   ```bash
   git clone https://github.com/GEM-312/RenaissanceArchitectAcademy.git
   ```

2. Open `RenaissanceArchitectAcademy.xcodeproj` in Xcode

3. Select iPad simulator or "My Mac"

4. Press `Cmd+R` to build and run

## Project Structure

```
RenaissanceArchitectAcademy/
├── Views/           # SwiftUI views
├── ViewModels/      # MVVM view models
├── Models/          # Data models
├── Styles/          # Colors, buttons, UI components
├── Services/        # Audio, persistence
├── Fonts/           # Cinzel, EBGaramond, PetitFormalScript
└── Assets.xcassets/ # Images and custom icons
```

## Map Art Generation (Gemini Prompts)

The city map background is generated as 6 zone tiles (1500x1200 px each), then stitched in Photoshop at 7000x5000 px (2x retina of 3500x2500 map). **Terrain ground only** — buildings, trees, rivers, and labels are SpriteKit nodes rendered on top. Style matches existing Midjourney science icons: fine sepia ink lines, soft transparent watercolor washes, cream parchment, faint geometric construction lines.

### Zone I — Ancient Rome (left side, 8 buildings)
> Top-down terrain map, fine sepia ink line drawing with soft transparent watercolor washes on aged cream parchment. Faint geometric construction lines and circles in the background. Warm sandy ground with subtle terracotta and ochre watercolor tints. Worn dirt paths, rocky patches, dry grass texture sketched in thin sepia lines. Delicate, airy, minimal. Pale warm tones — tan, sandy beige, light terracotta wash. No buildings, no trees, no bushes, no water, no rivers, no text, no words, no labels. Leonardo da Vinci notebook study style. 1500x1200 pixels.

### Zone II — Florence (top right, 2 buildings)
> Top-down terrain map, fine sepia ink line drawing with soft transparent watercolor washes on aged cream parchment. Faint geometric construction lines and arcs in the background. Rolling gentle hill contours with sage green and warm gold watercolor tints. Vineyard row patterns etched in thin sepia ink. Dirt footpaths, meadow ground texture. Delicate, airy, minimal. Pale green and gold washes. No buildings, no trees, no bushes, no rivers, no water, no text, no words, no labels. Leonardo da Vinci notebook study style. 1500x1200 pixels.

### Zone III — Venice (right side, 2 buildings)
> Top-down terrain map, fine sepia ink line drawing with soft transparent watercolor washes on aged cream parchment. Faint geometric construction lines and circles in the background. Cobblestone paving patterns and worn stone ground textures sketched in thin sepia ink. Subtle pale blue-gray and teal watercolor tints near edges. Weathered stone squares. Delicate, airy, minimal. No buildings, no bridges, no canals, no water, no trees, no bushes, no text, no words, no labels. Leonardo da Vinci notebook study style. 1500x1200 pixels.

### Zone IV — Padua (center, 1 building)
> Top-down terrain map, fine sepia ink line drawing with soft transparent watercolor washes on aged cream parchment. Faint geometric construction lines and arcs in the background. Cobblestone courtyard patterns and gravel path textures in thin sepia ink. Subtle muted green and warm stone watercolor tints. Geometric paving details. Delicate, airy, minimal. No buildings, no trees, no bushes, no fountains, no water, no text, no words, no labels. Leonardo da Vinci notebook study style. 1500x1200 pixels.

### Zone V — Milan (upper center, 2 buildings)
> Top-down terrain map, fine sepia ink line drawing with soft transparent watercolor washes on aged cream parchment. Faint geometric construction lines, gear diagrams, and engineering sketches fading into the background. Packed dirt ground, brick-paved path patterns in thin sepia ink. Subtle ochre and pale blue watercolor tints. Delicate, airy, minimal. No buildings, no trees, no bushes, no canals, no water, no text, no words, no labels. Leonardo da Vinci notebook study style. 1500x1200 pixels.

### Zone VI — Renaissance Rome (lower right, 2 buildings)
> Top-down terrain map, fine sepia ink line drawing with soft transparent watercolor washes on aged cream parchment. Faint geometric construction lines, star chart circles, and astronomical diagrams in the background. Grand stone plaza paving patterns and ceremonial pathway markings in thin sepia ink. Subtle pale gold and terracotta watercolor tints. Delicate, airy, minimal. No buildings, no trees, no bushes, no columns, no fountains, no water, no text, no words, no labels. Leonardo da Vinci notebook study style. 1500x1200 pixels.

### Stitching Guide
| Zone | Canvas Position (7000x5000) | Description |
|------|----------------------------|-------------|
| I | Left third (x: 0-2000) | Ancient Rome terrain |
| V | Upper center (x: 2000-3600, y: 2500-5000) | Milan terrain |
| IV | Center (x: 3000-5000, y: 2000-4000) | Padua terrain |
| II | Top right (x: 4000-7000, y: 3000-5000) | Florence terrain |
| III | Right (x: 5000-7000, y: 1500-3500) | Venice terrain |
| VI | Bottom right (x: 3500-6000, y: 0-2500) | Renaissance Rome terrain |

Era divider: vertical blend line around x: 2000-2400. Use soft-edge blending between tiles. Parchment background: #F5E6D3.

## License

This project is part of Columbia College Chicago - Final Semester (Jan 30 - May 15, 2025)

---

<p align="center">
  Built with SwiftUI
</p>
