# Insula Cards — Storyteller Rewrite Brief

**Building:** Insula (Roman apartment buildings) — Building #3 in apprentice journey, **closes Act I**
**Cards to rewrite:** 12 (5 cityMap, 3 workshop, 2 forest, 2 craftingRoom)
**Target file:** `RenaissanceArchitectAcademy/Models/KnowledgeCardContentRome.swift` (lines 821–1143)
**Reference:** Pantheon + Aqueduct + Roads
**Prerequisite:** Marina approves this brief before edits (auto-approved per "proceed with next building cards")

---

## Act position

**Act I closer.** Aqueduct (water) + Roads (movement) + Insula (housing) = the everyday architecture of Rome. By the end of Insula, the apprentice has the complete picture of how an empire is lived in. The Storyteller acknowledges this on the lead card: third building, body of the empire complete.

After this, Act II opens with the monumental — Pantheon, Colosseum. **Storyteller plants the contrast on the last card:** "From homes for the many — to temples for the gods."

## Building one-liner

Per `voice-cast-plan.md` line 48: Insula has **anonymous urban architecture** — no famous architect, no commissioning emperor (just code enforcers Augustus + Nero). The voice of Insula is **the builders themselves** — the unnamed thousands. Storyteller frames it: "These were not built by famous men. They were built by hands like yours."

## Narrator(s)

- **Storyteller (Roman Master)** — same voice
- **Augustus** brief mention (Card 1 — height limit, 20m). Code enforcer, not architect.
- **Nero** brief mention (Card 1 — height limit reduced to 17.5m after Great Fire). Code enforcer.
- **No lead architect cameo.** This is the building where the Storyteller's voice carries it alone.

## Signature register

Same Pantheon/Aqueduct/Roads rules. Periods, em-dashes, conversational openers, comprehension checks.

## Insula-specific signature aside

Two paradox beats already in the content — lean into both:

1. **"The richest lived lowest, the poorest lived highest"** (Card 0) — social-priority truth. Mirrors Aqueduct's specus hierarchy ("public fountains → baths → private homes"). This is a CALLBACK opportunity.
2. **"Building codes are written in blood"** (Card 1) — written after collapses. Strong Pantheon parallel ("the strongest part nobody sees").
3. **"The cheapest material had the highest cost"** (Card 10, poplar fires) — direct paradox.

Recurring closing beat for the building: **"Every Roman, no matter how poor, had a roof."** Plant on Card 0, return at Card 7 (tegulae roof tiles), close near Card 12.

## Callbacks

### Backward — TWO buildings to call back to now (Aqueduct + Roads)

- **Card 0 (overview)** — social hierarchy callback to **Aqueduct specus** ("fountains → baths → homes"). Same Roman truth, vertical instead of horizontal.
- **Card 5 (cheap mortar 1:4)** — callback to **Aqueduct mortar (1:2:½)** AND **Road mortar (1:3)**. "You have learned two recipes already. This is the third — the cheapest. No pozzolana. Just lime and sand."
- **Card 11 (lime plaster)** — callback to **Aqueduct + Road lime**. "Same lime you have made before. Now — aged three months. Patience changes the material."
- **Card 12 (Fire Tiles)** — callback to **Aqueduct opus signinum firing** ("you have fired clay before — these tiles fire hotter").

### Forward — set up Act II (Pantheon especially)

- **Card 12 (final)** — close the Act with a forward beat: "We have built the body of an empire. Now — we go higher. To temples. To gods." Plant Pantheon.

## Per-card register notes (12 cards)

### City Map (5 cards)

| # | Current title | Rewrite focus |
|---|---|---|
| 0 | First Apartment Buildings | **LEAD CARD** — flag `isLeadCard: true`. "Welcome to your third building." A million Romans, no land — build up. Land the "richest lowest, poorest highest" social truth. Callback to specus hierarchy. |
| 1 | Step 4: Five Stories | "Building codes are written in blood." Augustus's 20m, Nero's 17.5m after the Great Fire. Frame: foundations couldn't support more weight. |
| 2 | Step 2: Tabernae Shops | Ground floor as prime real estate. Bakers, butchers, fullers (introduce the fuller-with-urine fun fact). Arch = door + window. |
| 3 | Step 4: Brick Walls | The tapered-wall physics. "Lightest where it is tallest." 60→45→30→timber. |
| 4 | Spiral Stairways | Maximum vertical / minimum floor. The wedge step, the newel column. Geometry as solution. |

### Workshop (3 cards)

| # | Current title | Rewrite focus |
|---|---|---|
| 5 | Mortar Binding Science | **TRIPLE CALLBACK.** "You have learned two recipes — aqueduct and road. This is the third. Cheapest." 1:4 no pozzolana. Thicker joints compensate. "Economy and engineering, balanced on a budget." |
| 6 | Tegulae and Imbrices | The roof system. 3,000 tiles per insula. "No nails — only gravity and overlap." Land "Every Roman, no matter how poor, had a roof." |
| 7 | Step 7: Mica Windows | Lapis specularis (mica) vs glass. Light as a luxury. "What money buys — what poverty pays." |

### Forest (2 cards)

| # | Current title | Rewrite focus |
|---|---|---|
| 8 | Step 3: Floor Beams (oak) | The 1/20 rule — beam depth = span ÷ 20. Roman carpenters "knew by apprenticeship, not textbooks." Address the apprentice directly here. |
| 9 | Lightweight Upper Frames (poplar) | **THE GREAT FIRE BEAT.** Poplar is 40% lighter, perfect for top floors. But — flammable. "The cheapest material had the highest cost." Rome's great fires started up there. Lands hard. |

### Crafting Room (2 cards)

| # | Current title | Rewrite focus |
|---|---|---|
| 10 | Step 4: Lime Plaster | **LIME CALLBACK to both prior buildings.** Aged 3+ months. "Patience is an ingredient. The oldest lime makes the strongest mortar." |
| 11 | Step 8: Fire Tiles | **ACT I CLOSER.** Brick firing 950–1050°C sweet spot. Storyteller closes with: "We have walked from water, to road, to home. Together we have built the body of an empire. But there is more. Soon — we go higher. To temples. To gods." Plants Pantheon. |

## NPC moments

- **Augustus + Nero** (Card 1, height limit) — brief mentions, framed as the men who responded to disaster with law. Not voice cameos.
- **The fuller** (Card 2, taberna) — fun-fact opportunity (cleaned clothes with urine — kids love this).
- **The Roman carpenter** (Card 8) — frame as someone "who never wrote a book — who knew the 1/20 rule by hand and by year."

## Architect names

- **Augustus** — already in Card 1. Keep, frame as code enforcer.
- **Nero** — already in Card 1. Keep, strengthen the Great Fire context.
- No new names to add. The Storyteller is the voice of all anonymous builders.

## Lead card flag

Card 0 (`8_cityMap_building_0`) needs `isLeadCard: true` appended.

## Out of scope

Same as Aqueduct/Roads:
- Voice variety — Storyteller only.
- Visual / activity / keyword changes — unchanged.
- Italian title polish — keep.
- Card structure — 12 cards stays 12.

## Process

1. ✅ Read all 12 cards in full
2. ✅ Brief drafted
3. ⏳ Apply 12 lessonText rewrites + 12 notebookSummary updates + `isLeadCard: true` on Card 0
4. Build & verify
5. Commit — closes Act I
6. Marina tests at her own pace
