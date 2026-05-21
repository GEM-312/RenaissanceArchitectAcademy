# Roman Baths Cards — Storyteller Rewrite Brief

**Building:** Roman Baths (Thermae) — Building #4 in apprentice journey, **opens Act II**
**Cards to rewrite:** 13 (5 cityMap, 3 workshop, 2 forest, 3 craftingRoom)
**Target file:** `RenaissanceArchitectAcademy/Models/KnowledgeCardContentRome.swift` (lines 550–816)

## Act position
**Act II opener — "You're starting to see it."** Apprentice has finished Act I (water, roads, housing). The Storyteller treats them as fluent in basics. Less hand-holding, more recognition. Heavy backward callbacks.

## Building one-liner
The thermae is **Rome at its most generous**. Public, almost-free, all-functions-in-one (bath + library + gym + garden). The most democratic Roman building. Slaves bathed beside senators.

## Narrator(s)
- **Storyteller (Roman Master)** — Act II register, more knowing
- **Caracalla** brief mention (Card 0) — emperor who built the 1,600-bather complex
- No named architect per `voice-cast-plan.md` line 43 (anonymous bath architects)

## Signature aside
**"Justice built into the plumbing."** The bath is where social equity meets engineering. Callback opportunity to Aqueduct specus hierarchy (Card 2 castellum). Recurring on Cards 0, 2.

## Callbacks
**Backward (Acts I → II first time):**
- Card 2 — Castellum 3-outlet rationing **callbacks Aqueduct specus** ("you remember the castellum…")
- Card 5 — Marble + opus signinum **callbacks Aqueduct waterproofing** ("you remember? Opus signinum.")
- Card 6 — 1:4 pozzolana **callbacks Aqueduct/Roads recipe** ("you remember the pozzolana?")
- Card 8 — King-post truss **callbacks Insula 1/20 rule** ("you remember the rule?")

**Forward:**
- Card 7 — Glass at 1,100°C **plants Glassworks** ("we will return to this material. Soon, in Venice, glass becomes something else entirely.")

## Per-card focus

| # | Title | Beat |
|---|---|---|
| 0 | Thermae — Social Center | **LEAD** + isLeadCard:true. "Act Two begins." Caracalla 1,600 bathers. "A happy citizen does not revolt." Social engineering disguised as architecture. |
| 1 | Step 1: The Hypocaust | "The greatest Roman invention you have never heard of." Pilae + tubuli. Central heating 2,000 years early. |
| 2 | Step 2: Water Supply | **AQUEDUCT CALLBACK.** "Justice built into the plumbing." 3-outlet rationing without an awake engineer. |
| 3 | Step 5: The Tepidarium | The bath route. Body opens, body seals. Floor plan as physics. |
| 4 | Step 6: The Caldarium | 10M liters/day → Cloaca Maxima. Reuse for latrines. "Nothing wasted. Only gravity and patience." |
| 5 | Marble and Waterproofing | **AQUEDUCT CALLBACK.** "Marble takes the praise. Signinum does the work." Face + shield. |
| 6 | Thermal Cycling Concrete | **AQUEDUCT + ROADS POZZOLANA CALLBACK.** "Self-healing stone." 1:4 recipe. |
| 7 | Silica for Glass Windows | "Dark cave becomes a palace." **Plant Glassworks forward callback.** |
| 8 | Frigidarium Roof Trusses | **INSULA 1/20 RULE CALLBACK.** 25m span / 1.25m deep beams. King-post. "The tree that grows slowest carries the most weight." |
| 9 | Furnace Fuel | The unnamed stoker beat. Chestnut over oak. Temperature control as craft. |
| 10 | Glass Recipe | Cullet, manganese, "chemistry corrects what nature gives." Lime callback. |
| 11 | Furnace Firing | Praefurnium + Venturi. "Oxygen is the real fuel. Wood is only the messenger." |
| 12 | Waterproof Storage | Pine pitch + wax + lead-for-quicklime. "The most boring detail — also the most important." |

## Lead card flag
Card 0 needs `isLeadCard: true`.

## Out of scope
Same as prior briefs. Only `lessonText` + `notebookSummary` + `isLeadCard` on Card 0.
