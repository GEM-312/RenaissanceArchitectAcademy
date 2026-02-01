# Building Data - Renaissance Architect Academy

This folder contains ScriptableObject data files for buildings.

## Creating New Buildings in Unity

1. In Unity, right-click in this folder
2. Select: **Create > Renaissance Academy > Building Data**
3. Fill in the building properties

## Building Structure

Each building has:
- **Basic Info**: Name, Era (Ancient Rome / Renaissance), Description
- **Sprites**: Blueprint, Watercolor, Icon (3 stages for animation)
- **Costs**: Gold, Stone, Wood
- **Challenge**: Science questions tied to the building
- **Educational**: Historical facts and STEM connections

## Sample Buildings (To Create)

### Ancient Rome Era
1. **Roman Column (Doric)** - Geometry challenge (proportions)
2. **Roman Arch** - Physics challenge (load distribution)
3. **Roman Aqueduct Section** - Engineering challenge (water flow)

### Renaissance Era
1. **Florentine House** - Math challenge (golden ratio)
2. **Cathedral Window** - Optics challenge (light rays)
3. **Dome Structure** - Physics challenge (structural forces)

## Challenge Types
- Mathematics (Golden ratio, proportions)
- Geometry (Arches, symmetry)
- Physics (Load distribution, forces)
- Chemistry (Mortar mixing, pigments)
- Optics (Light, windows)
- Engineering (Foundations)

## Visual Style Notes

### The 3-Stage Animation:
1. **THE SKETCH** - Blueprint lines draw themselves (blue ink)
2. **THE LOGIC** - Measurements and grid fade in
3. **THE RENDER** - Watercolor bloom fills shapes

### Each building needs 3 sprite versions:
- `BuildingName_Sketch.png` - Blue ink outline
- `BuildingName_Logic.png` - With measurements/grid overlay
- `BuildingName_Render.png` - Final watercolor version

## Midjourney Prompt Template
```
[building name], renaissance watercolor architectural sketch,
Leonardo da Vinci notebook style, parchment background,
sepia ink annotations, golden ratio overlay --sref 3186415970 --ar 1:1
```
