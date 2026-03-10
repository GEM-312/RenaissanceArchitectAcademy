# API Integration Plan — Renaissance Architect Academy

## Overview
Integrate external APIs to transform passive learning into interactive, real-time educational experiences. All API data rendered in the game's Renaissance aesthetic (parchment, sepia ink, Cinzel fonts, watercolor atoms).

---

## API Stack Summary

| API | Role | Cost | Priority |
|-----|------|------|----------|
| **Claude API (Haiku 4.5)** | Bird companion Q&A, math tutoring, Socratic hints | ~$5/month (100 users) | P0 |
| **PubChem** | Molecule data, 2D/3D structures, compound info | Free forever | P0 |
| **Met Museum** | Real Renaissance art/architecture photos | Free, no key needed | P1 |
| **Wolfram Alpha** | Precise math computation, balanced equations, step-by-step | Free (2,000 calls/month) | P2 |
| **Desmos** | Interactive graphing (external link / deep-dive) | Free | P3 |

---

## Phase 1: Claude API — Bird Companion Chat (P0)

### Goal
Make the bird companion conversational. Students can ask questions after reading knowledge cards, during crafting, or while exploring.

### Architecture
```
iOS App → HTTPS → Backend Proxy → Claude API (Haiku 4.5)
                   (hides API key)
```

### Backend Proxy Options
| Option | Cost | Complexity |
|--------|------|------------|
| Cloudflare Worker | Free tier | Low |
| Firebase Cloud Function | Free tier | Low |
| AWS Lambda | Free tier (1M req/month) | Medium |
| Vapor (Swift server) | ~$5/month hosting | Medium |

### Files to Create
```
RenaissanceArchitectAcademy/
├── Services/
│   ├── ClaudeService.swift          # API client, request/response models
│   └── APIConfiguration.swift       # Endpoint URL, rate limits, caching config
├── Views/
│   └── BirdChatOverlay.swift        # Chat UI overlay (3-5 message limit)
├── Models/
│   └── ChatMessage.swift            # Message model (role, content, timestamp)
```

### System Prompt Template
```
You are a Renaissance bird companion named [BirdName] in an educational
architecture game. You help young apprentices (ages 12-18) learn about
Renaissance and Ancient Roman architecture, science, and engineering.

Current context:
- Building: [buildingName]
- Science: [scienceType]
- Card topic: [knowledgeCard.lessonText]
- Player level: [masteryLevel]

Rules:
- Keep answers under 3 sentences
- Use Renaissance-era language flavor (but stay clear)
- Reference the specific building when possible
- Stay on topic: architecture, science, math, history
- If asked unrelated questions, redirect playfully
- Use concrete numbers and real measurements
```

### Use Cases
1. **Post-card Q&A**: "Why does volcanic ash make concrete stronger?"
2. **Crafting guidance**: "What temperature melts sand into glass?"
3. **Socratic hints**: During construction sequence, ask "why" questions
4. **Math tutoring**: Generate building-specific geometry problems
5. **Personalized encouragement**: Adapt to player's struggle areas

### Rate Limiting
- Free: 10 bird questions/day per user
- Could gate behind in-app purchase later if needed
- Cache common questions (same card → same question patterns)

### Cost Projection
| Scale | Monthly Cost |
|-------|-------------|
| 100 students (Columbia class) | ~$5 |
| 1,000 students (App Store) | ~$50 |
| 10,000 students | ~$500 |

---

## Phase 2: PubChem — Renaissance Molecule Viewer (P0)

### Goal
Show real molecular structures when students craft materials. Animate chemical reactions on parchment with Renaissance styling.

### PubChem Endpoints (No API Key Required)
```
# Compound data by name
GET https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/name/{name}/JSON

# 2D structure (atom coordinates + bonds)
GET https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/name/{name}/record/JSON

# 3D conformer (x,y,z coordinates)
GET https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/{cid}/conformers/JSON
```

### Files to Create
```
RenaissanceArchitectAcademy/
├── Services/
│   └── PubChemService.swift              # Fetch + parse + cache molecule data
├── Models/
│   └── MoleculeData.swift                # Parsed atom/bond model from PubChem
├── Views/
│   ├── RenaissanceMoleculeView.swift     # 2D molecule renderer (SwiftUI Canvas)
│   └── ReactionAnimationView.swift       # Animated bond formation sequences
├── Data/
│   └── CachedMolecules.json              # Pre-fetched data for all game compounds
```

### Renaissance Element Color Palette
| Element | Color | Hex | Historical Reference |
|---------|-------|-----|---------------------|
| Ca (Calcium) | Ochre | #C9A86A | Limestone/marble |
| C (Carbon) | Warm Brown | #8B6F47 | Charcoal |
| O (Oxygen) | Renaissance Blue | #5B8FA3 | Air/water |
| Si (Silicon) | Terracotta | #D4876B | Sand/clay |
| Fe (Iron) | Sepia Ink | #4A4035 | Dark metal |
| Cu (Copper) | Sage Green | #7A9B76 | Verdigris patina |
| S (Sulfur) | Gold | #DAA520 | Alchemist's gold |
| Na (Sodium) | Deep Teal | #2B7A8C | Salt/sea |
| Hg (Mercury) | Red | #CD5C5C | Vermillion pigment |

### Molecules to Cache (per building)

#### Ancient Rome
| Building | Compounds | Key Reaction |
|----------|-----------|-------------|
| Aqueduct | CaCO₃, CaO, Ca(OH)₂ | CaCO₃ → CaO + CO₂ (calcination) |
| Colosseum | Ca(OH)₂ + volcanic ash | Pozzolanic reaction |
| Roman Baths | H₂O, steam | 2H₂O → steam (thermal) |
| Pantheon | CaSiO₃ (Roman concrete) | Ca(OH)₂ + SiO₂ → CaSiO₃ |
| Roman Roads |ite basalt,iteite calcium compounds | Aggregate bonding |
| Harbor | NaCl, CaSiO₃ | Saltwater-resistant concrete |
| Siege Workshop | Cu + Sn (bronze alloy) | Alloy phase diagram |
| Insula | CaCO₃, SiO₂ (brick clay) | Brick firing |

#### Renaissance Italy
| Building | Compounds | Key Reaction |
|----------|-----------|-------------|
| Duomo | CaCO₃ (marble), Fe₂O₃ (brick) | Herringbone brick bonding |
| Botanical Garden | C₆H₁₂O₆, chlorophyll | Photosynthesis |
| Glassworks | SiO₂, Na₂CO₃ | SiO₂ + Na₂CO₃ → Na₂SiO₃ + CO₂ |
| Arsenal | Fe, Cu, pitch (C compounds) | Iron smelting |
| Anatomy Theater | Hemoglobin (C₇₃₈H₁₁₆₆N₈₁₂O₂₀₃S₂Fe) | O₂ binding |
| Leonardo's Workshop | Various pigments, metals | Pigment chemistry |
| Flying Machine | Silk (fibroin), wood cellulose | Material properties |
| Vatican Observatory | SiO₂ (glass lenses) | Light refraction |
| Printing Press | Carbon (lampblack), linseed oil | Ink formulation |

### Animation Types
1. **Bond Formation**: Atoms float in → approach → bonds draw (Path trim 0→1)
2. **Bond Breaking**: Bonds shake → trim 1→0 → atoms drift apart
3. **Gas Release**: Product molecule fades + rises (CO₂ escaping)
4. **Heat Effect**: Color shift warm→hot + glow overlay
5. **Water Addition**: Ripple circles expanding from reaction center
6. **Molecule Rotation**: Slow `rotation3DEffect` for 3D conformers
7. **Energy Pulse**: `scaleEffect` + gold burst for exothermic reactions

### Integration Point
```
Player crafts at workbench
    → CraftingRoomMapView detects recipe completion
    → Show ReactionAnimationView with recipe's chemical reaction
    → Bird narrates each phase
    → Award chemistry badge + florins
```

---

## Phase 3: Met Museum API — Real Art & Architecture (P1)

### Goal
Show real photographs and artwork of buildings after students complete them. "See the real thing" moment.

### Endpoint (No API Key Required)
```
# Search
GET https://collectionapi.metmuseum.org/public/collection/v1/search?q=pantheon+rome

# Object details (includes image URLs)
GET https://collectionapi.metmuseum.org/public/collection/v1/objects/{objectID}
```

### Files to Create
```
RenaissanceArchitectAcademy/
├── Services/
│   └── MetMuseumService.swift       # Search + fetch artwork data
├── Views/
│   └── RealWorldArtOverlay.swift    # "See the Real Thing" modal
├── Data/
│   └── CachedArtwork.json           # Pre-fetched artwork IDs per building
```

### Pre-Mapped Artwork per Building
| Building | Search Query | Expected Results |
|----------|-------------|-----------------|
| Pantheon | "pantheon rome interior" | Piranesi engravings, photos |
| Colosseum | "colosseum rome" | Historical prints, photos |
| Duomo | "brunelleschi florence dome" | Architectural drawings |
| Glassworks | "murano glass venice" | Venetian glassware objects |
| Anatomy Theater | "anatomical drawing renaissance" | Da Vinci anatomy studies |
| Leonardo's Workshop | "leonardo da vinci" | Notebooks, mechanical drawings |
| Printing Press | "gutenberg printing" | Early printed books |

### Integration Point
```
Building state → .complete
    → Celebration animation
    → "See the Real Thing" button appears
    → Met Museum overlay with real artwork
    → Pinch to zoom, swipe between related works
```

---

## Phase 4: Wolfram Alpha — Precise Computation (P2)

### Goal
Precise math and chemistry computation for advanced student questions. Step-by-step solutions with proper math notation.

### Endpoint (API Key Required)
```
GET https://api.wolframalpha.com/v2/query?input={query}&appid={key}&output=json
```

### Cost Strategy
- **Pre-cache** all ~40 building-specific queries during development (uses 40 of 2,000 free calls)
- Ship cached results in app bundle → zero runtime API calls for core content
- Reserve live calls for student free-form math questions via bird chat
- Estimated: well within 2,000 free calls/month

### Files to Create
```
RenaissanceArchitectAcademy/
├── Services/
│   └── WolframService.swift          # Query + parse + cache
├── Data/
│   └── CachedComputations.json       # Pre-fetched results for known queries
```

### Pre-Cached Queries
```
"volume of hemisphere radius 21.6 meters"           → Pantheon dome
"area of ellipse 189 by 156 meters"                 → Colosseum arena
"slope 1 meter per 400 meters over 50 kilometers"   → Aqueduct gradient
"surface area of sphere diameter 42 meters"          → Pantheon interior
"catenary curve equation"                            → Duomo dome
"tensile strength bronze vs iron"                    → Arsenal/Siege Workshop
"focal length convex lens radius 0.5 meters"         → Vatican Observatory
"force on arch keystone 500kg load"                  → General architecture
```

---

## Phase 5: Custom Renaissance Graph View (P2)

### Goal
Replace Desmos embeds with native SwiftUI graphing that matches game aesthetic. Extends existing MathVisualView system.

### Files to Create
```
RenaissanceArchitectAcademy/
├── Views/
│   └── RenaissanceGraphView.swift    # Parchment + blueprint grid + sepia curves
```

### Features
- Blueprint grid on parchment background
- Sepia ink curve plotting
- Cinzel axis labels with building-specific units (meters, degrees, kg)
- Interactive: pinch to zoom, drag to trace
- Animated curve drawing (Path trim)
- Builds on existing GradientSlopeVisual.swift and FlowRateVisual.swift patterns

---

## Implementation Order

### Sprint 1: Foundation (1-2 weeks)
- [ ] Create `Services/` directory
- [ ] Build `ClaudeService.swift` with mock responses for testing
- [ ] Build `BirdChatOverlay.swift` UI
- [ ] Set up backend proxy (Cloudflare Worker)
- [ ] Wire bird chat to one knowledge card (Pantheon) as proof of concept

### Sprint 2: Chemistry System (1-2 weeks)
- [ ] Build `PubChemService.swift` with fetch + cache
- [ ] Pre-fetch all ~30 compound datasets, save as `CachedMolecules.json`
- [ ] Build `RenaissanceMoleculeView.swift` (2D renderer)
- [ ] Build `ReactionAnimationView.swift` (bond formation animations)
- [ ] Wire to crafting system — show reaction after workbench crafting

### Sprint 3: Art & Computation (1 week)
- [ ] Build `MetMuseumService.swift`, pre-cache artwork IDs
- [ ] Build `RealWorldArtOverlay.swift`
- [ ] Wire to building completion flow
- [ ] Build `WolframService.swift` with pre-cached computations
- [ ] Wire to bird chat for math questions

### Sprint 4: Polish & Scale (1 week)
- [ ] Build `RenaissanceGraphView.swift`
- [ ] Add reaction animations for all 17 buildings
- [ ] Rate limiting and error handling
- [ ] Offline fallback (cached data + pre-written bird responses)
- [ ] Analytics: track API usage per user

---

## Security Considerations
- **Never ship API keys in app binary** — all keyed APIs go through backend proxy
- **PubChem and Met Museum need no keys** — safe to call directly from app
- **Rate limiting** — enforce per-user limits server-side
- **Content filtering** — Claude system prompt constrains to educational topics
- **Caching** — reduces API calls and enables offline play

## Offline Strategy
| API | Offline Fallback |
|-----|-----------------|
| Claude API | Pre-written FAQ per knowledge card topic |
| PubChem | CachedMolecules.json ships with app |
| Met Museum | CachedArtwork.json + downloaded thumbnails |
| Wolfram Alpha | CachedComputations.json ships with app |

## Monitoring
- Track API calls per user per day
- Alert if costs exceed $20/month threshold
- Dashboard: total calls, cache hit rate, error rate
- Claude API: monitor for off-topic responses (log + review)

---

## Tomorrow's Session (Mar 10, 2026)

### 1. Phase 2: PubChem Molecule Viewer
- Build `PubChemService.swift`, `RenaissanceMoleculeView.swift`, `ReactionAnimationView.swift`
- Wire to crafting system — show animated reactions after workbench crafting
- Cache Pantheon compounds (CaCO₃, CaO, Ca(OH)₂, CaSiO₃)

### 2. Spread Pantheon Knowledge Cards Across All Environments
- Currently: 14 Pantheon cards defined in `KnowledgeCard.swift` but only ForestMapView has card UI
- Extract reusable `KnowledgeCardsOverlay.swift` from ForestMapView's science card system
- Integrate into all 4 environments:
  - **CityMapView** — 5 cityMap cards (show when player taps Pantheon building)
  - **WorkshopMapView** — 4 workshop cards (show at quarry, volcano, river, mine stations)
  - **CraftingRoomMapView** — 3 craftingRoom cards (show at workbench, furnace, pigmentTable)
  - **ForestMapView** — 2 forest cards (show at oak, poplar POIs) alongside existing tree cards
- Wire "Ask the Bird" button on each card → BirdChatOverlay
- Bird guidance: `nextSuggestedEnvironment()` tells player where to go next for uncompleted cards
- Track completion via `BuildingProgress.completedCardIDs`

### 3. Integrate Book Findings
- Marina will bring research/findings from a book to weave into game content
- Update knowledge card lesson text with new historical/scientific details
- Potentially add new cards or expand existing ones based on book material
- All card text follows Morgan Housel writing style (hook → punchy facts → twist)

### Priority Order
1. Knowledge cards across environments (biggest gameplay impact)
2. Book findings integration (content enrichment)
3. PubChem molecule viewer (visual wow factor)
