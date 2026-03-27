# Knowledge Card Visual Audit — 99 Cards

## Problem
Current visuals are generic shapes (dome for everything, static "next" buttons).
They need to be INTERACTIVE and actually represent what each card teaches.

## Reference: What GOOD looks like
- `GradientSlopeVisual.swift` — 5 interactive steps, animated water flow, blueprint grid
- `FlowRateVisual.swift` — 5 interactive steps, basin filling animation, formula reveal

Every card visual should be at THIS quality level — interactive, animated, educational.

## Current State: 99 Cards by Building

### PANTHEON (14 cards)

| # | Card Title | Current Visual | Problem | Should Be |
|---|-----------|---------------|---------|-----------|
| 1 | 16 Columns Carrying Portico | force/portico | Generic columns, no interaction | Tap columns to count, drag to test weight |
| 2 | Ring Foundation Cross-Section | crossSection | Static layers | Dig animation — tap to reveal each layer |
| 3 | Perfect Sphere Inside Rotunda | geometry/dome | Just a dome outline | Drag slider to show sphere fitting inside, dimensions update live |
| 4 | 28 Rows of Coffers | force/coffers | Overlapping elements, unclear weight removal | Tap coffers to "remove" them, weight counter decreases |
| 5 | Oculus Compression Ring | force/oculus | Blue "sphere" confusion | Tap arrows to see compression direction, open/close the oculus |
| 6 | Limestone vs Marble | comparison | Static two-box | Drag heat slider — limestone transforms into marble |
| 7 | Roman vs Modern Concrete | comparison | Static two-box | Timeline slider — show aging (Roman gets stronger, modern cracks) |
| 8 | Dome Layers — Graded Aggregate | crossSection/dome | Static arcs | Pour animation — tap to add each ring, density color changes |
| 9 | 7-Meter Bronze Doors | force/doors | OK but passive | Drag doors open/closed, show pivot physics |
| 10 | Centering — Temporary Frame | force/centering | Arch with arrows | Build the centering — drag beams into position |
| 11 | Scaffolding Around Dome | force/scaffolding | Small dome, hard to read | Scroll up through scaffold levels, workers visible |
| 12 | Vitruvius Concrete Recipe 1:3 | ratio | Static bar | Drag ingredients into mix bowl, ratio adjusts live |
| 13 | Calcination CaCO₃ → CaO | temperature | Generic curve | Drag temperature slider, see limestone transform step by step |
| 14 | Opus Sectile Floor | geometry/tessellation | OK | Drag stone pieces to fit the pattern |

### AQUEDUCT (12 cards)

| # | Card Title | Current Visual | Problem | Should Be |
|---|-----------|---------------|---------|-----------|
| 1 | 69 km — Mostly Underground | crossSection | Static layers | Map view — tap sections to reveal underground/above ground |
| 2 | The Chorobates — Leveling Beam | geometry/beam | Fixed, NEW but not interactive | Tilt the beam — water moves to show level/unlevel |
| 3 | Gradient Math | comparison | "Too steep/Too gentle" boxes | Drag slope slider — water flows faster/slower/stops |
| 4 | Arches & Voussoirs | force/arch | Static arch + arrows | Build the arch — drag voussoirs into place, keystone last |
| 5 | Specus Channel Cross-Section | crossSection | Static layers | Tap layers to reveal — show water flowing through channel |
| 6 | Mortar vs Concrete | comparison | Static boxes | Tap to "apply" each — mortar between stones, concrete fills |
| 7 | Waterproof Lining | comparison | Static boxes | Pour water on each — normal dissolves, pozzolanic hardens |
| 8 | 3 Coats Opus Signinum | crossSection | Thin layers | Paint each coat — burnish animation on final layer |
| 9 | Lead Fistulae Pipes | crossSection | Static layers | Bend the lead sheet into tube — step by step fabrication |
| 10 | Aqueduct Mortar 1:2:½ | ratio | Static bar | Drag ingredients, ratio updates, trowel test animation |
| 11 | Firing Terracotta 600-900°C | temperature | Generic curve | Drag temp slider — clay changes color, ring-when-tapped test |
| 12 | Daily Flow 184,000 m³ | ratio | Static bar | Fill basin animation — counter shows liters per person |

### ROMAN ROADS (10 cards)

| # | Card Title | Problem | Should Be |
|---|-----------|---------|-----------|
| 1 | 400,000 km | Generic dome geometry | Radial map — tap to extend road lines from golden milestone |
| 2 | The Groma (survey tool) | Dome geometry | Cross-shaped tool — drag plumb lines to align sighting |
| 3 | Four Layers | Static layers | Build up — tap to add each layer, compaction animation |
| 4 | Basalt Polygons | Tessellation OK | Drag polygon stones to interlock — no mortar puzzle |
| 5 | Milestone System | Generic geometry | Drag milestone to position — distance counter updates |
| 6 | Ice Splitting Stone | Static comparison | Pour water in drill holes — freeze animation cracks stone |
| 7 | Pozzolanic Crystals | Static reaction | Time-lapse — drag slider to show crystals growing in pores |
| 8 | Camber for Drainage | Static flow line | Rain animation — water flows to side ditches on cambered road |
| 9 | Road Mortar 1:3 | Static ratio bar | Drag & mix ingredients, ram-packing animation |
| 10 | Milestone Markers | Generic | Carve the milestone — tap to add emperor name, road, distances |

### ROMAN BATHS (13 cards)

| # | Card Title | Problem | Should Be |
|---|-----------|---------|-----------|
| 1 | Thermae — Social Center | Static comparison | Floor plan — tap rooms to discover gym, library, garden |
| 2 | Hypocaust Central Heating | Static layers | Furnace animation — fire lights, air flows under floor, up walls |
| 3 | Castellum — 3 Outlets | Static layers | Water level slider — show which outlets cut off first |
| 4 | Temperature Gradient | Generic curve | Walk through rooms — tap cold/warm/hot, thermometer updates |
| 5 | Zero Waste Drain System | Static flow | Water flow animation — follows 2% slope to Cloaca Maxima |
| 6 | Bath Wall Layers | Static layers | Peel layers — tap to reveal marble → signinum → concrete |
| 7 | Bath Concrete 1:4 | Static ratio bar | Mix ingredients, thermal crack appears, self-heals with extra silica |
| 8 | Making Glass 1,100°C | Generic curve | Drag temp — sand melts into glass, pour flat |
| 9 | King-Post Roof Truss | Generic portico | Load test — drag weight onto truss, see force distribution |
| 10 | Furnace 300°C → Floor 40°C | Generic curve | Temperature gradient — furnace to floor visualization |
| 11 | Roman Glass Recipe | Static ratio | Mix 4 ingredients in crucible — color changes with each |
| 12 | Venturi Effect | Static flow | Narrow the chamber — air speed indicator increases, flame grows |
| 13 | Amphora Storage | Static layers | Build amphora — add pitch lining, seal with wax cork |

### INSULA (12 cards)

| # | Card Title | Problem | Should Be |
|---|-----------|---------|-----------|
| 1 | 6-7 Story Apartment | Static layers | Build floors — each floor shows different resident wealth |
| 2 | Building Height Limits | Static comparison | Slider — push building height, warning at 20m (Augustus), 17.5m (Nero) |
| 3 | Taberna — Ground Floor Shop | Static layers | Shop layout — tap to reveal mezzanine, street entrance |
| 4 | Wall Thickness Taper | Static layers | Stack floors — walls visibly thin as you go up |
| 5 | Spiral Staircase | Generic geometry | Top-down spiral view — drag to rotate, show wedge steps |
| 6 | Cheap Mortar 1:4 | Static ratio | Compare recipes — drag to test strength (crumbles vs holds) |
| 7 | Tegulae + Imbrices Tiles | Static comparison | Tile puzzle — interlock tegulae + imbrices on roof |
| 8 | Glass vs Mica Windows | Static comparison | Tap windows — glass (clear) vs mica (translucent), price shown |
| 9 | Beam Depth Rule | Static ratio | Drag span slider — beam depth auto-calculates (span/20) |
| 10 | Oak vs Poplar Frames | Static comparison | Fire test — tap to ignite, oak resists, poplar burns |
| 11 | Aged Lime Putty | Static ratio | Time-lapse — 3 months aging, consistency changes |
| 12 | Brick Firing Sweet Spot | Generic curve | Drag temp — brick changes: crumbly (900) → perfect (950) → brittle (1100) |

### HARBOR (12 cards)

| # | Card Title | Problem | Should Be |
|---|-----------|---------|-----------|
| 1 | Portus 200-Acre Harbor | Generic geometry | Hexagonal harbor plan — tap to place ships, lighthouse |
| 2 | Wave Impact Force | Generic portico | Wave animation — drag wave height, force counter updates |
| 3 | Cofferdam | Static layers | Pump animation — drag Archimedes screw, water drains |
| 4 | Breakwater Blocks | Generic portico | Stack blocks — waves test them, undersized blocks fail |
| 5 | Lighthouse | Generic geometry | Light beam — rotate mirror, beam sweeps across sea |
| 6 | Harbor Stone (Tufa vs Marble) | Static comparison | Salt test — pour salt water, tufa absorbs, marble cracks |
| 7 | Roman vs Modern Marine Concrete | Static comparison | Timeline — drag years, Roman strengthens, modern dissolves |
| 8 | Lead Hull Protection | Static layers | Build up — add planks, then lead, then tacks |
| 9 | Channel Markers | Static cross-section | Place markers — depth readings update |
| 10 | Warehouse Truss | Generic portico | Load test — add cargo weight, truss flexes |
| 11 | Poplar Piles | Static layers | Drive piles — hammer animation, swelling tight |
| 12 | Marine Concrete 1:3 | Static ratio | Mix with seawater (not fresh!) — reaction animation |

### COLOSSEUM (13 cards)

| # | Card Title | Problem | Should Be |
|---|-----------|---------|-----------|
| 1 | 76 Exits, 15 Minutes | Generic geometry | Crowd sim — tap exits, flow animation empties arena |
| 2 | Foundation on Drained Lake | Static layers | Drain animation — water recedes, piles driven in |
| 3 | Four Classical Orders | Static layers | Stack columns — Doric→Ionic→Corinthian→Composite |
| 4 | Acoustic Bowl 37° | Generic geometry | Drag rake angle — sound wave visualization changes |
| 5 | The Hypogeum | Static layers | Elevator mechanism — drag lift platform up/down |
| 6 | Travertine Foundation | Static comparison | Quarry and transport — crack block, load on cart |
| 7 | Iron Clamps | Generic force | Place clamp — dovetail cut locks blocks together |
| 8 | Silk Velarium Canvas | Generic geometry | Rope system — pull ropes to extend canvas over arena |
| 9 | Foundation Curing | Static reaction | Time-lapse — concrete sets, crystals form |
| 10 | Pozzolanic Vaults | Static layers | Build vault form — pour concrete, remove form |
| 11 | Marble Polishing | Static comparison | Polish stages — coarse → fine → mirror finish |
| 12 | Seating Mathematics | Generic geometry | Assign sections — calculator shows seats per tier |
| 13 | The Velarium | Generic force | Wind test — drag wind speed, canvas billows |

### SIEGE WORKSHOP (13 cards)

| # | Card Title | Problem | Should Be |
|---|-----------|---------|-----------|
| 1 | Ballista (The Onager) | Mechanism placeholder | Drag arm back → release → projectile arc |
| 2 | Launch Angles | Generic geometry | Angle slider — projectile path changes, range updates |
| 3 | Torsion Springs | Generic force | Twist rope — tension meter increases |
| 4 | Battering Ram | Generic force | Swing animation — rhythm timing for maximum impact |
| 5 | Siege Tower Frame | Static layers | Build up levels — soldiers climb inside |
| 6 | Terracotta Roof Tiles | Generic temperature | Fire tiles — drag temp, color changes |
| 7 | Forge Fittings | Generic temperature | Heat iron — drag bellows, temperature rises |
| 8 | Bronze Gear Mechanisms | Static ratio | Gear ratio — drag to mesh gears, speed changes |
| 9 | Soaking Wood | Static comparison | Soak timber — flexibility test (bend vs snap) |
| 10 | Catapult Design | Static comparison | Balance arm — adjust counterweight vs projectile |
| 11 | Precision Parts | Static comparison | Tolerance test — parts that fit vs parts that don't |
| 12 | Timber Joinery | Static comparison | Joint puzzle — mortise meets tenon |
| 13 | Forge Iron | Generic temperature | Bellows → heat → hammer → shape |

## Next Steps
1. Marina reviews this audit
2. Prioritize which buildings to fix first
3. Design proper interactive visuals with drag/tap/slider interactions
4. Implement one building at a time, test, then next
