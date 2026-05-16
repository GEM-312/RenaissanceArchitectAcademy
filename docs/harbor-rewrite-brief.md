# Harbor Cards — Storyteller Rewrite Brief

**Building:** Harbor (Portus) — Building #5 (Act II)
**Cards:** 12 (5 cityMap, 3 workshop, 2 forest, 2 craftingRoom)
**File:** `KnowledgeCardContentRome.swift` lines 1150–1469

## Act position
Act II — apprentice fluent in basics. Heavy callbacks. First Act II building with a **named architect cameo**.

## Narrator + cameos
- **Storyteller** — Act II register
- **Apollodorus of Damascus** (Card 0, lead) — Trajan's architect who designed the hexagonal inner harbor. Per `voice-cast-plan.md` line 46 (✅ named architect)
- **Vitruvius brief return** (Card 3, breakwater blocks) — callback to Aqueduct Card 2 cameo, strengthening his recurring presence
- **Claudius + Trajan** mentioned as patrons (Card 0)

## Signature aside
**"Building where the water rules."** The sea destroys everything else — but here, we use the sea against itself (marine concrete, salt-resistant tufa, swelling poplar piles).

## Callbacks
**Backward:**
- Card 3 (breakwater blocks) — **Vitruvius callback** to Aqueduct Card 2
- Card 8 (warehouse trusses) — **Insula 1/20 rule callback**
- Card 10 (marine mortar) — **all three prior concrete recipes** (Aqueduct 1:2:½, Roads 1:3, Insula 1:4 no pozzolana, Baths 1:4 extra)
- Card 11 (lead casting) — **Aqueduct fistulae callback** (same metal)

**Forward:** Card 0 plants Pantheon ("Apollodorus may also have designed our next great temple")

## Per-card focus

| # | Title | Beat |
|---|---|---|
| 0 | Portus — Rome's Gateway | **LEAD + isLeadCard:true.** Rome could not feed itself — grain from Egypt arrives here. Claudius + Trajan as patrons, **Apollodorus as architect**. Plant Pantheon. |
| 1 | Tides & Currents | "The strongest wall isn't the thickest — it's the one that refuses to fight." Wave force physics. |
| 2 | Underwater Concrete (cofferdam) | "Make the water leave first." Archimedean screw + double pile ring + clay. |
| 3 | The Breakwater | **VITRUVIUS RETURNS.** 10–15 ton block 3× rule. "Overbuilding by 3× sounds wasteful until the first storm proves you right." |
| 4 | The Lighthouse | Pharos design. "Fire and reflection — finding your way in the dark." |
| 5 | Breakwater Stone (tufa) | Soft over hard. "Salt fills pores instead of cracking. The softest stone wins at the harbor." |
| 6 | Marine Concrete | Al-tobermorite crystal. "The ocean that destroys everything else makes this concrete immortal." |
| 7 | Channel Markers (lead) | Teredo worms vs lead sheeting. "Protection weighs something. It always does." |
| 8 | Warehouse Trusses | **INSULA 1/20 CALLBACK.** Oak queen-post. Tannins repel moisture. |
| 9 | Cofferdam Piles (poplar) | Poplar swells wet → tighter seal. "Temporary by design, permanent in effect." |
| 10 | Marine Mortar | **FOUR-RECIPE CALLBACK.** Now seawater on purpose. |
| 11 | Lead Casting at 327°C | **FISTULAE CALLBACK.** "You remember the lead pipes of the aqueduct? Same metal, now wraps the ships." Closing beat. |

## Lead card flag
Card 0 needs `isLeadCard: true`.

## Out of scope
Only `lessonText` + `notebookSummary` + `isLeadCard` on Card 0.
