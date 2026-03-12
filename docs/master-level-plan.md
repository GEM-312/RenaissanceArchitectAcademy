# Master Level System (Mar 10 2026)

## What Was Built (Phase 1)

### New Materials (8) — Material.swift
| Material | Icon | Station | Cost | Level |
|----------|------|---------|------|-------|
| Sulfur 🔥 | volcano | 4 | Apprentice |
| Copper 🪙 | mine | 5 | Apprentice |
| Gold 👑 | market | 10 | Master-gated |
| Herbs 🌿 | forest (future) | 3 | Apprentice |
| Letame 💩 | farm | 2 | Master-gated |
| Charred Ox Horn 🦴 | farm | 3 | Master-gated |
| Beeswax 🐝 | farm | 4 | Apprentice |
| Eggs 🥚 | farm | 2 | Apprentice |

### New Crafted Items (8) — CraftedItem.swift
- rawBronze 🥉, goldLeaf ✨, fumigationIncense 🪔, castingMold 🫕, temperaPaint 🎭
- apprenticeSeal 🔰, architectSeal 🏛️, masterSeal 🏆

### New Recipes (8) — Recipe.swift
| Output | Ingredients | Temp | Level |
|--------|------------|------|-------|
| Raw Bronze | copper×2 + ironOre×1 | High | Apprentice |
| Gold Leaf | gold×1 + lead×1 | Medium | Master |
| Fumigation Incense | herbs×2 + sulfur×1 | Low | Apprentice |
| Casting Mold | clay×2 + letame×1 + charredOxHorn×1 | Medium | Master |
| Tempera Paint | eggs×2 + groundRedOchre×1 | Low | Apprentice |
| Apprentice Seal | beeswax×2 + clay×1 | Low | End of Apprentice |
| Architect Seal | beeswax×2 + copper×1 + clay×1 | Medium | End of Architect |
| Master Seal | beeswax×1 + gold×1 + lead×1 | Medium | End of Master |

### New Stations — ResourceNode.swift
- **Farm (La Fattoria)**: materials=[letame, charredOxHorn, beeswax, eggs], tool=pitchfork 🔱
- **Goldsmith Workshop**: enters interior (no materials on outdoor map), isCraftingStation=true
- Updated: volcano += sulfur, mine += copper, market += gold

### New Tool — Tool.swift
- **Pitchfork** (il Forcone 🔱): requiredAtStation = .farm

### GoldsmithScene.swift (NEW) — Views/SpriteKit/
- `GoldsmithStation` enum: `.engravingBench`, `.castingStation`, `.goldsmithFurnace`, `.polishingWheel`
- Each with imageName, displayName, italianName, educationalText
- 3500x2500 map, 11 waypoints, Dijkstra pathfinding, editor mode
- Shape-based furniture placeholders (pending Midjourney assets)
- pbxproj IDs: 1A0 (fileRef), 0A0 (buildFile)

### GoldsmithMapView.swift (NEW) — Views/SpriteKit/
- SwiftUI wrapper with SceneHolder pattern
- GameTopBarView "Bottega di Lotti", station overlay, "Back to Workshop" button
- pbxproj IDs: 1A1 (fileRef), 0A1 (buildFile)

### WorkshopView.swift — 3 Interior States
- `WorkshopInterior` enum: `.outdoor`, `.craftingRoom`, `.goldsmith`
- WorkshopMapView receives `onEnterGoldsmith` callback
- Slide transitions between all 3 interiors

### Updated Recipes
- Bronze Fittings: changed from ironOre(2)+clay(1) → copper(1)+ironOre(1)+clay(1) (historically accurate)
- WorkshopJob "Cast Bronze Fittings" updated to match

### Wax Seal Progression (from style guide)
- Apprentice (Levels 1-5): Ionic column seal — bird brings at onboarding
- Architect (Levels 6-15): Corinthian capital — player crafts (beeswax+copper+clay)
- Master (Levels 16+): Duomo dome — player crafts (beeswax+gold+lead)

## TODO — Still Needs Development

### Phase 1 Remaining
- [ ] Gating logic: Farm open at apprentice (letame+oxHorn locked until master tier), Goldsmith locked until Maestro tier + 2 Renaissance buildings
- [ ] Goldsmith interior activities/mini-games: niello engraving, lost-wax casting, gem setting, embossing, gears & weights
- [ ] Knowledge cards for goldsmith workshop (14 cards, Pantheon pattern)

### Phase 2: Forest Herbs
- [ ] Add wormwood, juniper, lavender as herb POIs in ForestScene
- [ ] Shrub shapes (smaller than trees), herb science cards, herb collection flow
- [ ] Connect herbs to fumigation incense recipe

### Phase 3: Black Death Knowledge Cards
- [ ] Cards for Florence buildings about plague, fumigation, public health
- [ ] Historical context: 1400 plague, wormwood/sulfur fumigation, sparrows falling from rooftops

### Camera System (Mar 10 2026) — DONE
- [x] Forest camera follow + gradual approach zoom (new)
- [x] Workshop camera softened — gradual approach (was instant 0.4x snap)
- [x] City Map camera softened — gradual approach (was instant 0.5x snap)
- All scenes now use same pattern: gentle initial zoom → progressive close-up during last 700-800pts
- Settings: Forest 0.7→0.45, Workshop 0.65→0.45, City 0.8→0.55

### Midjourney Assets Needed (13)
**Station/Environment Art:**
1. StationFarm — barn/stable with animals, Tuscan countryside
2. StationGoldsmith — Florentine bottega storefront in Santa Croce
3. InteriorEngravingBench — workbench with burin tools, magnifying lens
4. InteriorCastingStation — crucible, clay molds, tongs
5. InteriorGoldsmithFurnace — bellows furnace with tall chimney
6. InteriorPolishingWheel — foot-pedal grinding/polishing wheel
7. GoldsmithTerrain — interior floor/walls (stone + timber beams)

**Forest Herb POIs (Phase 2):**
8. ForestWormwood — silvery-green artemisia shrub
9. ForestJuniper — blue-berry evergreen bush
10. ForestLavender — purple flowering rows

**Wax Seal Badges (from style guide):**
11. SealApprentice — Ionic column seal (bronze/simple)
12. SealArchitect — Corinthian capital seal (silver/detailed)
13. SealMaster — Duomo dome seal (gold/ornate)

### Audio Needed (39 sounds — for composer)

**Background Music (7 looping tracks):**
1. main_menu_theme — Renaissance lute/harpsichord, gentle (~2 min loop)
2. city_map_ambient — Bustling city, distant bells, market chatter (~3 min)
3. workshop_ambient — Outdoor nature + distant hammering (~2 min)
4. crafting_room_ambient — Crackling fire, indoor workshop (~2 min)
5. goldsmith_ambient — Metalwork tapping, bellows, intimate (~2 min)
6. forest_ambient — Birds, wind, rustling leaves, creek (~3 min)
7. lesson_reading_theme — Calm study music, contemplative (~2 min)

**Collection & Crafting SFX (13):**
8. stone_quarry_hit — Pickaxe striking stone
9. timber_chop — Axe hitting wood
10. mining_hammer — Metal on rock
11. clay_dig — Wet earth scooping
12. herb_pick — Soft plant rustling (future)
13. farm_collect — Pitchfork/hay rustling
14. material_pickup — Generic sparkly collect (market, river, volcano)
15. workbench_mix — Materials scraping/combining
16. furnace_fire_whoosh — Flame ignition
17. furnace_crackling — Sustained fire loop (~5 sec)
18. crafting_complete — Forge-ding + sparkle
19. pigment_grind — Mortar & pestle grinding (~3 sec)
20. anvil_strike — Hammer on anvil (goldsmith)

**UI & Navigation SFX (7):**
21. page_turn — Paper turning (lessons)
22. overlay_open — Parchment unroll/swoosh
23. overlay_close — Parchment roll-up
24. scene_transition — Whoosh/door for entering interiors
25. florins_earned — Coin jingle
26. seal_stamp — Wax seal pressing
27. level_up — Fanfare for tier promotion

**Bird Companion SFX (4):**
28. bird_chirp — Short chirp (hint appears)
29. bird_squawk — Quick squawk (wrong answer)
30. bird_happy_trill — Melodic trill (celebration)
31. bird_fly_in — Wing flaps (entrance)

**Challenge SFX (5):**
32. sketch_pencil — Pencil scratch on canvas
33. column_stamp — Stone placement in sketch
34. quiz_fanfare — Short trumpet fanfare
35. construction_step — Stone block sliding into place
36. truffle_discover — Magical earthy pop

**Walking Surface Variants (3 — nice-to-have):**
37. footstep_stone — Stone/marble surface
38. footstep_grass — Soft grass
39. footstep_wood — Wooden floor

**Priority order:** Background loops (1-7) → Collection SFX (8-20) → Bird sounds (28-31) → UI/Challenge (21-36)

### Historical Source
Based on 2 chapters about Brunelleschi's apprenticeship to goldsmith Benincasa Lotti in Santa Croce, Florence. Key themes: Black Death fumigation (1400), goldsmith guild training, bronze casting with organic molds (letame + charred ox horn), gold leaf beating, Brunelleschi's ox-head seal.
