## Complete Development Guide - Spring 2025

**Educational city-building game teaching architecture through science**

---

## 🎯 Project Overview

### What We're Building

An educational city-builder where students solve real architectural challenges across 13+ sciences - not just math but physics for structural loads, chemistry for mixing mortar and pigments, geometry for arches and domes, material science for choosing stone vs wood, even optics for window placement and acoustics for cathedral design.

The whole thing looks like Leonardo da Vinci's notebooks with gorgeous watercolor + blueprint aesthetic. When you solve a challenge correctly, your building blooms from a gray sketch into full color and gets placed in your 3/4 isometric city view of Florence.

### Core Concept

**"Learn Like Leonardo"** - Science isn't tacked on, it IS the gameplay.

**Target Audience:** Ages 11-16 (Middle/Early High School)

**Platform:** WebGL Browser Game

**Timeline:** 6 weeks (Jan 30 - May 15, 2025)

**Tech Stack:** Unity 2022.3 LTS, C#, Midjourney AI art

---

## 🎮 Game Design

### Single View - Pannable Isometric

**Always 3/4 isometric view** - no first-person mode!

**Controls:**

- WASD / Arrow Keys: Pan camera around city
- Mouse Wheel: Zoom in/out
- Right Click + Drag: Pan camera (alternative)
- Left Click on Plot: Build menu

### Complete Gameplay Loop

**1. Game starts** → Florence city loads in isometric view

- See 6 empty building plots with blueprint outlines
- Grass, trees, gardens, river, mountains
- UI shows: Gold 💰1000, Stone 🪨50, Wood 🪵50

**2. Player pans camera** → Explore the city

- WASD to look around
- Mouse wheel to zoom
- "Oh, Plot 3 is next to that cypress tree!"

**3. Player clicks Plot** → Building menu appears

- Choose Era: [Ancient Rome] or [Renaissance]
- Choose Building Type
- See cost and preview

**4. Player confirms** → Challenge appears

- Math: Calculate golden ratio for windows
- Physics: Determine foundation depth for load
- Chemistry: Mix correct mortar ratio
- Geometry: Design semicircular arch

**5. Player solves correctly** → Building blooms!

- Gray sketch appears on plot
- Blooms into watercolor over 2-3 seconds
- Building now permanent
- Camera focuses briefly on new building

**6. Repeat** → Fill all 6 plots

- Mix Roman and Renaissance buildings
- Pan around to admire your city
- Take screenshots!

---

## 🏗️ City Structure

### Florence Layout (3/4 Isometric View)

**Visual Layers (back to front):**

**Layer -10:** Sky, mountains (fixed background)

**Layer -5:** Duomo cathedral, Palazzo Vecchio (city scenery)

**Layer -2:** Grass patches, background trees 🌳🌿

**Layer 0:** Cobblestone roads

**Layer 3:** Foreground gardens, trees 🌸🌳

**Layer 5:** Building plots (clickable)

**Layer 10:** Player buildings (constructed)

**Layer 15:** Building details

**Layer 100:** UI overlays

### 6 Building Plots Grid

```
Plot 1    Plot 2    Plot 3
  🏗️        🏗️        🏗️

Plot 4    Plot 5    Plot 6
  🏗️        🏗️        🏗️
```

**Between plots:** Grass, trees, gardens, roads

**Around edges:** River, more vegetation, decorative elements

**Background:** Mountains, distant city scenery

---

## 🎨 Art Generation - Week 1

### Midjourney Style Reference

**ALL assets use:** `--sref 3186415970`

**Color Palette:**

- Parchment: #F5E6D3
- Sepia Ink: #4A4035
- Renaissance Blue: #5B8FA3
- Terracotta: #D4876B
- Ochre: #C9A86A
- Sage Green: #7A9B76

### Priority Assets (Generate These First!)

**Asset #1: Florence City Base Scene**

```
Renaissance Florence city layout for video game, 3/4 isometric
aerial view, watercolor and ink on aged parchment background,
beautiful LUSH GREENERY, Duomo cathedral in far background, red
tile rooftops, distant mountains, Arno river at bottom with trees
lining the banks, cobblestone streets winding through, GREEN GRASS
MEADOWS between roads, TALL CYPRESS TREES scattered throughout
scene, OLIVE TREES and OAK TREES for variety, small FLOWER GARDENS
with roses and Italian wildflowers, garden courtyards with fountains,
6 empty building plots marked with foundation blueprint outlines,
natural Italian Tuscan landscape, warm golden hour lighting,
Leonardo da Vinci botanical and architectural notebook aesthetic,
vibrant nature, living city --ar 16:9 --sref 3186415970
```

**Generate:** 10 variations, pick the BEST one!

**Asset #2-7: Individual Tree Sprites**

**Cypress Tree (Tall Italian):**

```
Single tall Italian cypress tree, 3/4 isometric view for game,
watercolor on aged parchment, dark green narrow columnar foliage,
straight trunk, Mediterranean landscape, Leonardo da Vinci botanical
study style, transparent PNG background, game sprite asset, highly
detailed leaves --ar 1:1 --sref 3186415970
```

Generate: 5 variations (different heights)

**Olive Tree:**

```
Single Mediterranean olive tree, 3/4 isometric view for game,
watercolor on parchment, gray-green leaves, twisted gnarled trunk,
silver-green foliage, Italian countryside, Leonardo botanical
illustration, transparent background, game sprite
--ar 1:1 --sref 3186415970
```

Generate: 5 variations

**Oak Tree:**

```
Single oak tree, 3/4 isometric view for game, watercolor on
parchment, full rounded green canopy, thick brown trunk, broad
leaves, shade tree, Leonardo nature sketch, transparent background,
game asset --ar 1:1 --sref 3186415970
```

Generate: 3-4 variations

**Asset #8-15: Grass & Gardens**

**Grass Patches:**

```
Lush green grass patch, 3/4 isometric view for game, watercolor
on aged parchment, bright Italian grass, natural texture, small
wildflowers scattered (daisies, poppies), clover, Leonardo nature
study, soft edges, seamless sides, game terrain asset
--ar 1:1 --sref 3186415970
```

Generate: 3 large, 3 medium, 3 small sizes

**Flower Gardens:**

```
Renaissance Italian garden bed, 3/4 isometric view, watercolor on
parchment, COLORFUL FLOWERS: red roses, yellow sunflowers, purple
lavender, pink geraniums, organized flower beds, green bushes,
garden border, Italian villa courtyard style, Leonardo botanical
illustration, game decoration asset --ar 1:1 --sref 3186415970
```

Generate: 5-6 variations

### Building Sprites (6 Types × 2 Each)

**Renaissance Buildings:**

**1. Simple Palazzo**

```
Renaissance Italian palazzo, 3/4 isometric view for game, two
stories, rectangular design, watercolor and ink on parchment,
warm ochre stone walls, red terracotta tile roof, arched windows,
wooden doors, balcony with iron railings, blueprint measurement
overlay, Leonardo notebook style, game sprite --ar 1:1 --sref 3186415970
```

**ALSO generate BLUEPRINT version:**

```
Same palazzo building, but ONLY blueprint lines, technical drawing,
no color, just sepia ink lines and measurements on parchment, gray
sketch style --ar 1:1 --sref 3186415970
```

**2. Arched Building**

```
Renaissance building with arcade arches, 3/4 isometric game view,
watercolor on parchment, ground floor with stone arched passages,
second floor with windows, blue tile roof, warm stone, shops under
arches, blueprint overlay, Leonardo aesthetic --ar 1:1 --sref 3186415970
```

- Blueprint version

**3. Domed Chapel**

```
Renaissance chapel with dome, 3/4 isometric game view, watercolor
and ink, aged parchment, terracotta dome with cross on top, small
size fits plot, arched entrance, blueprint measurements, Leonardo
style --ar 1:1 --sref 3186415970
```

- Blueprint version

**Ancient Roman Buildings:**

**4. Roman Temple**

```
Ancient Roman temple, 3/4 isometric view for game, watercolor
and ink on aged parchment, Corinthian columns, triangular
pediment, marble white stone, red tile roof, classical
proportions, steps leading to entrance, blueprint measurement
overlay, Leonardo da Vinci notebook aesthetic style,
architectural game sprite --ar 1:1 --sref 3186415970
```

- Blueprint version

**5. Roman Villa**

```
Ancient Roman villa house, 3/4 isometric view for game,
watercolor on parchment, atrium with impluvium courtyard,
red tile roof, white stucco walls, mosaic floor details,
classical Roman architecture, blueprint grid overlay,
Leonardo sketch style --ar 1:1 --sref 3186415970
```

- Blueprint version

**6. Roman Bath House**

```
Ancient Roman bath house, 3/4 isometric view for game,
watercolor and ink on parchment, arched windows, dome roof,
brick and stone construction, steam vents, classical design,
blueprint technical drawing overlay --ar 1:1 --sref 3186415970
```

- Blueprint version

### UI Elements

**Parchment backgrounds, wax seal buttons, resource icons (gold coin, stone block, wood plank), era selection panels**

**Total Week 1 Assets: ~70-80 items**

---

## 💻 Unity Implementation

### Project Structure

```
Assets/
├── Scenes/
│   ├── MainMenu.unity
│   ├── CitySelection.unity
│   └── Florence_City.unity
├── Scripts/
│   ├── City/
│   │   ├── CityManager.cs
│   │   ├── BuildingPlot.cs
│   │   └── IsometricCameraController.cs
│   ├── Buildings/
│   │   ├── Building.cs
│   │   └── BuildingData.cs
│   ├── Challenges/
│   │   ├── ChallengeManager.cs
│   │   ├── MathChallenge.cs
│   │   └── ChemistryChallenge.cs
│   ├── UI/
│   │   ├── UIManager.cs
│   │   └── BuildingSelectionMenu.cs
│   └── Core/
│       ├── GameManager.cs
│       └── ResourceManager.cs
├── Art/
│   ├── Cities/Florence/
│   ├── Buildings/{Renaissance,AncientRome}/
│   ├── Nature/{Trees,Grass,Gardens}/
│   └── UI/
└── Prefabs/
```

### Core Scripts

**IsometricCameraController.cs** - Pan/zoom camera around city

**BuildingPlot.cs** - Clickable plots with hover effects

**BuildingData.cs** - ScriptableObject for building properties

**ResourceManager.cs** - Track gold, stone, wood

**ChallengeManager.cs** - Display and validate science challenges

### Bloom Animation System

```csharp
private IEnumerator BloomIntoWatercolor(SpriteRenderer renderer, Sprite watercolorSprite)
{
    float bloomDuration = 2.5f;
    float elapsed = 0f;

    // Start with gray
    renderer.color = Color.gray;

    while (elapsed < bloomDuration)
    {
        elapsed += Time.deltaTime;
        float t = elapsed / bloomDuration;

        // Switch to watercolor sprite at halfway
        if (t >= 0.5f && renderer.sprite != watercolorSprite)
        {
            renderer.sprite = watercolorSprite;
        }

        // Fade from gray to full color
        renderer.color = Color.Lerp(Color.gray, Color.white, t);

        // Subtle pulse for bloom effect
        float scale = 1f + Mathf.Sin(t * Mathf.PI) * 0.1f;
        renderer.transform.localScale = Vector3.one * scale;

        yield return null;
    }

    // Final state
    renderer.color = Color.white;
    renderer.transform.localScale = Vector3.one;
}
```

---

## 🔬 Educational Content

### 13+ Sciences Integrated

**Mathematics:**

- Golden ratio (φ = 1.618) for proportions
- Volume calculations for materials
- Area and perimeter for foundations
- Ratios and fractions

**Geometry:**

- Semicircular arches (compass construction)
- Symmetry and reflection
- Tessellations and patterns
- 3D visualization

**Physics:**

- Structural loads and forces
- Compression vs tension
- Center of gravity
- Material strength

**Chemistry:**

- Mortar mixing (lime + sand + water)
- Pigment creation (minerals + binders)
- Material reactions
- pH and alkalinity

**Material Science:**

- Stone properties (marble, limestone, granite)
- Wood characteristics (oak, pine)
- Durability and weathering
- Thermal properties

**Engineering:**

- Foundation design
- Load-bearing structures
- Arch mechanics
- Dome construction

**Plus:** Optics (light), Acoustics (sound), Hydrology (water), Geology (stone sources)

### Sample Challenges

**Renaissance Palazzo - Math Challenge:**

```
"Renaissance architects used the golden ratio for window proportions.

If your palazzo is 10 meters tall, and windows should be placed
using φ = 1.618, calculate the window height.

Formula: Building Height ÷ φ = Window Height

Answer: _____ meters"

Correct: 6.18 meters (10 ÷ 1.618)
```

**Roman Temple - Physics Challenge:**

```
"Roman columns must support the temple roof weight.

Roof weight: 50,000 kg
Number of columns: 6
Safety factor: 2x

Calculate load per column with safety margin.

Answer: _____ kg per column"

Correct: 16,667 kg ((50,000 ÷ 6) × 2)
```

**Chapel - Chemistry Challenge:**

```
"Mix mortar for chapel walls using Roman recipe.

Ratio: 3 parts lime : 1 part volcanic ash : 4 parts sand

You have 60 kg of lime. Calculate other ingredients.

Volcanic ash: _____ kg
Sand: _____ kg"

Correct: 20 kg ash, 80 kg sand
```

---

## 📅 6-Week Development Timeline

### Week 1 (Jan 30 - Feb 5): Art Generation

**Day 1-2:** Florence city scene + trees

**Day 3-4:** Building sprites (6 types × 2 versions)

**Day 5:** Grass, gardens, nature elements

**Day 6-7:** UI elements, polish selections

**Deliverable:** ~70-80 Midjourney assets organized in folders

### Week 2 (Feb 6 - Feb 12): Unity Scene Setup

**Day 1:** Unity project setup, import assets

**Day 2-3:** Build Florence scene with all layers

**Day 4:** Camera pan/zoom system

**Day 5-6:** Place 6 building plots

**Day 7:** Test camera movement

**Deliverable:** Florence scene playable with camera controls

### Week 3 (Feb 13 - Feb 19): Building System

**Day 1-2:** Click plot → menu system

**Day 3:** Era selection (Rome vs Renaissance)

**Day 4:** Building selection with previews

**Day 5:** Resource deduction system

**Day 6-7:** Test building placement

**Deliverable:** Can select and preview buildings

### Week 4 (Feb 20 - Feb 26): Challenges & Animation

**Day 1-3:** Challenge UI and validation

**Day 4:** Bloom animation (gray → watercolor)

**Day 5:** Camera focus on new buildings

**Day 6:** Sound effects

**Day 7:** Test complete loop

**Deliverable:** Full build → challenge → bloom cycle working

### Week 5 (Feb 27 - Mar 5): Content & Polish

**Day 1-2:** Create all 18 challenges (3 per building)

**Day 3:** Tutorial system

**Day 4:** Achievement notifications

**Day 5-6:** Playtesting with classmates

**Day 7:** Bug fixes

**Deliverable:** Complete game with all content

### Week 6 (Mar 6 - May 15): Launch & Presentation

**Week of Mar 6:** WebGL build and optimization

**Week of Mar 13:** Upload to itch.io

**Week of Mar 20:** Create presentation materials

**May 15:** Final presentation and submission

**Deliverable:** Live WebGL game + presentation

---

## 🚀 Deployment

### WebGL Build Process

**1. Optimize for Web:**

- Compress textures (RGBA Compressed)
- Reduce audio quality slightly
- Limit max texture size to 2048px

**2. Build Settings:**

- File → Build Settings
- Platform: WebGL
- Compression: Gzip
- Enable Exception: None (for smaller size)

**3. Build:**

- Click "Build"
- Wait 5-15 minutes
- Output folder with index.html + Build folder

**4. Upload to Itch.io:**

- Create new project on itch.io
- Upload as HTML/WebGL
- Zip the build folder
- Set viewport to 1920×1080
- Enable fullscreen

**5. Share:**

- Copy itch.io link
- Share on social media
- Add to portfolio

---

## 📊 Success Metrics

### By May 15, We Will Have:

✅ Beautiful Florence city with abundant nature

✅ 6 clickable building plots

✅ 2 architectural eras (Rome + Renaissance)

✅ 6 building types (3 per era)

✅ 18 science challenges (3 per building)

✅ Bloom animation working perfectly

✅ Pan/zoom camera exploration

✅ Resource management system

✅ WebGL build running in browser

✅ Uploaded to itch.io

✅ Professional presentation ready

✅ Portfolio-quality project

### Educational Impact:

- Students learn 13+ sciences through application
- Historical comparison (Rome vs Renaissance)
- Visual + mathematical connection
- Emotional engagement (watch calculations bloom)
- Cross-curricular value (Math + History + Art + Science)

---

## 💡 Design Philosophy

### "Learn Like Leonardo"

Leonardo da Vinci didn't separate art from science. His notebooks contain anatomy, engineering, painting, and mathematics all intertwined. This game follows that philosophy.

**Three Core Principles:**

1. **Science as Gameplay** - Not edutainment, education that IS fun
2. **Historical Authenticity** - Real math Renaissance architects used
3. **Emotional Connection** - Your calculations create visible beauty

### Why This Works:

**Traditional Education:**

Learn formula → Do worksheet → Forget it

**Renaissance Architect Academy:**

Need to build → Learn formula → Apply it → See result → Remember it

**The difference:** Context, application, visual reward, emotional payoff.

---

## 🎯 Market Potential

### Target Market:

**Primary:** Middle schools (ages 11-14)

**Secondary:** Early high schools (ages 14-16)

**Tertiary:** Homeschool families

### Business Model:

**School Licensing:** $99 per classroom/year

**District Licensing:** $999 per district/year

**Consumer Version:** Free with ads OR $4.99 one-time

### Curriculum Alignment:

- Common Core Math Standards (Ratios, Geometry)
- NGSS Science Standards (Engineering, Chemistry)
- History Standards (Renaissance, Ancient Rome)
- Art Standards (Proportion, Composition)

### Competitive Advantage:

- Beautiful (not typical educational game aesthetic)
- Multiple sciences (not just math)
- Historical depth (compare civilizations)
- Proven game genre (city-builder)
- Browser-based (no download barrier)

---

## 📬 Resources & Links

**GitHub Repository:**

https://github.com/GEM-312/RenaissanceArchitectAcademy

**Itch.io Page (After Launch):**

https://YOUR-USERNAME.itch.io/renaissance-architect-academy

**Midjourney Style Reference:**

`--sref 3186415970`

**Unity Version:**

2022.3 LTS (Long Term Support)

**Documentation:**

See /Documentation folder in GitHub repo

---

## ✅ Quick Reference Checklist

### Week 1:

- [ ] Generate Florence city base scene
- [ ] Generate 13-14 tree sprites
- [ ] Generate 12-14 grass/garden patches
- [ ] Generate 6 building types × 2 versions each
- [ ] Generate UI elements
- [ ] Organize all assets in folders

### Week 2:

- [ ] Create Unity project
- [ ] Import all Midjourney assets
- [ ] Build Florence_City scene
- [ ] Implement camera pan/zoom
- [ ] Place 6 building plots
- [ ] Test scene navigation

### Week 3:

- [ ] Create BuildingPlot click system
- [ ] Build era selection menu
- [ ] Build building selection menu
- [ ] Implement resource system
- [ ] Create building preview

### Week 4:

- [ ] Create ChallengeManager
- [ ] Build challenge UI panels
- [ ] Implement answer validation
- [ ] Create bloom animation
- [ ] Add camera focus effect
- [ ] Add sound effects

### Week 5:

- [ ] Write all 18 challenges
- [ ] Create tutorial sequence
- [ ] Add achievements
- [ ] Playtest with 5+ people
- [ ] Fix all bugs
- [ ] Polish UI

### Week 6:

- [ ] Optimize for WebGL
- [ ] Create WebGL build
- [ ] Upload to itch.io
- [ ] Create presentation
- [ ] Prepare screenshots/GIFs
- [ ] Final polish
- [ ] Submit project!

---

## 🎓 Final Notes

**This is achievable in one semester because:**

1. Focused scope (6 buildings, not 60)
2. One viewing angle (isometric only)
3. Midjourney speeds up art (no manual illustration)
4. Proven tech stack (Unity/C# you already know)
5. Clear milestones (weekly deliverables)
6. Educational value justifies simplicity

**Remember:**

- **Don't scope creep** - resist adding features mid-development
- **Finish > Perfect** - complete game beats incomplete masterpiece
- **Test early** - show to classmates in Week 3, not Week 6
- **Document progress** - take screenshots weekly for presentation
- **Ask for help** - professors, classmates, online communities

**You're building something meaningful** - a game that could actually help students learn. That's worth the effort.

**Let's build this! 🏛️✨**

---

*Last Updated: January 30, 2025*

*Developer: Marina Pollak*

*Columbia College Chicago - Final Semester*
