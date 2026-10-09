# SpriteKit scenes (City Map + Workshop) — notes for Claude

Moved from the root CLAUDE.md on 2026-10-09 so it loads only when working in this folder.

### City Map (CityScene + CityMapView)
- SpriteKit tile-based terrain (3500x2500 base, expandable via `terrainTiles` array)
- Rivers: Tiber, Arno, Grand Canal. Zone labels I-VI
- Player (PlayerNode) walks to tapped buildings, camera follows + zooms in
- Terrain blur (SKEffectNode + CIGaussianBlur) activates during walking, persists while zoomed in
- All overlays auto-dismiss on any user interaction (walk, scroll, pinch, drag)
- Mascot (Bird) rendered as SwiftUI overlay on top of SpriteKit (position tracked via callback)
- Tap building → player walks there → camera zooms to 0.7 → MascotDialogueView with 3 choices:
  - "I need materials" → MaterialPuzzleView (match-3)
  - "I don't know" → Quiz challenge
  - "I need to sketch it" → Sketching challenge

### Workshop (outdoor SpriteKit + indoor SpriteKit)
- **Outdoor** (WorkshopScene + WorkshopMapView): Apprentice walks between 8 resource stations + 1 crafting room (Dijkstra pathfinding, 64 waypoints)
- **Indoor** (CraftingRoomScene + CraftingRoomMapView): Apprentice walks between 4 furniture stations (Dijkstra pathfinding, 11 waypoints)
  - Furniture: Workbench (mix), Furnace (fire), Pigment Table (pigment collection + recipes), Storage Shelf (inventory)
  - `CraftingStation` enum: `.workbench`, `.furnace`, `.pigmentTable`, `.shelf`
  - Tap furniture → apprentice walks there → SwiftUI overlay appears
  - Player spawns at door position (bottom-center), walks to furniture via waypoint graph
- Crafting flow: Collect outdoors → enter Crafting Room → Mix at workbench → Fire in furnace → Educational popup
- 6 resource stations have OpenArt sprites; volcano has 15-frame animation
- Crafting room station pulses like resource stations on outdoor map
- Footstep sound (footstep.wav) plays during apprentice walking (0.55s interval)
- Master assignments: `MasterAssignment` model, random crafting tasks with bonus florins
