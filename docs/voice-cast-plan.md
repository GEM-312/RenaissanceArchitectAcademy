# Knowledge Card Voice Cast — Decision Document

**Date:** 2026-05-05
**Author:** Marina Pollak (with Claude)
**Audience:** Marina, Ray, Brianna, advisors
**Decision needed by:** before we rewrite the remaining 16 buildings' card content

---

## Context

The game has 17 buildings, 208 knowledge cards total. Each card teaches one architectural / scientific concept — read on screen + optionally narrated aloud via ElevenLabs TTS (Apprentice subscription tier).

We just shipped a **Storyteller voice** for the Pantheon's 14 cards: a warm Italian-accented Roman elder, theatrical but not over-performed. Marina tested 8 of them and approved the tone. The rewrite uses periods over ellipses for clear pauses, em dashes for asides, conversational openers ("Look.", "Now."), one comprehension check per card ("Strange — no?"). The bird's chat companion uses a separate, more playful voice.

The question now: **for the remaining 16 buildings, do we keep one Storyteller, or use multiple voices — including the actual historical architects?**

---

## What good narration achieves

1. **Memorable history** — kids remember Brunelleschi if Brunelleschi *speaks* to them, not if a generic narrator describes him
2. **Authority** — the architect of the building IS the credible voice for it
3. **Variety across 17 buildings** — one voice for 200+ cards risks tuning out; distinct voices keep attention
4. **Narrative payoff** — meeting Brunelleschi + Cosimo de Medici at the Duomo finale lands harder if those characters have been *introduced earlier*

## What complicates it

- **Roman buildings have anonymous architects.** Most Roman engineers went unrecorded. Pantheon's architect is debated. Colosseum's is unknown. Aqueducts and apartment buildings (insulae) had no single designer.
- **Voice generation is real work.** Each voice = generate + listen + tune + lock the ID. Plus per-character writing if the cast diverges in personality.
- **Per-card audio caching.** When we change voice IDs, the audio cache for old text is invalidated. New voice = fresh ElevenLabs fetch on first play (cheap, but adds latency on first hit).

---

## Architect attribution map

How clearly we can name an architect for each building.

| # | Building | Named architect / master | Confidence |
|---|---|---|---|
| 1 | Aqueduct | **Vitruvius** wrote the manual; **Frontinus** ran Rome's water | Stand-in (no original architect named) |
| 2 | Colosseum | Commissioned by **Vespasian**; architect unknown | Patron-voice, not architect |
| 3 | Roman Baths | Vitruvius wrote about them; specific bath architects anonymous | Stand-in |
| 4 | Pantheon | **Apollodorus of Damascus** (debated); commissioned by **Hadrian** | Likely-but-not-certain |
| 5 | Roman Roads | **Appius Claudius Caecus** commissioned the Via Appia | Patron, not architect |
| 6 | Harbor | **Apollodorus of Damascus** (Portus / Trajan's harbor) | ✅ named |
| 7 | Siege Workshop | **Heron of Alexandria** wrote about siege engines | ✅ named (engineer, not architect of any single workshop) |
| 8 | Insula | Anonymous urban architecture | Stand-in |
| 9 | Botanical Garden | **Daniele Barbaro** (Padua, 1545) or **Luca Ghini** (Pisa, 1544) | ✅ named |
| 10 | Glassworks | **Angelo Barovier** (Murano, 1405–1460) | ✅ named |
| 11 | Arsenal | Generic Venetian shipwright tradition | Stand-in |
| 12 | Anatomy Theater | **Hieronymus Fabricius** (built it, 1594); **Andreas Vesalius** lectured there | ✅ named |
| 13 | Leonardo's Workshop | **Leonardo da Vinci** | ✅ named |
| 14 | Flying Machine | **Leonardo da Vinci** (notebook designs) | ✅ named |
| 15 | Vatican Observatory | **Christoph Clavius** (calendar reform); **Galileo** related | ✅ named |
| 16 | Printing Press | **Aldus Manutius** (Venice, 1490s) | ✅ named |
| 17 | Duomo | **Filippo Brunelleschi**; commissioned by **Cosimo de Medici** | ✅ named |

**Summary:** 9 of 17 buildings have a clear named historical figure (mostly Renaissance). 8 need a stand-in voice (mostly Rome).

---

## Three voice cast options

### Option A — Maximum (12 voices)

Every named figure gets their own voice; anonymous buildings share a "Master" stand-in.

```
Phase 1 (Rome):    Roman Master, Vitruvius, Apollodorus, Heron, Vespasian
Phase 2 (Renaissance):  Barovier, Vesalius (or Fabricius), Leonardo, Clavius, Aldus Manutius
Phase 3 (Finale): Brunelleschi
Recurring patron: Cosimo de Medici (introduced Phase 2, returns at finale)
```

- **Pros:** every building voice is unique, maximum variety, full historical authenticity
- **Cons:** 12 voices to generate, write for, calibrate. Risk of voices feeling thin if any character only narrates one building.
- **Effort:** ~12 hours of voice generation + ~50% more writing time per building (we're inhabiting different characters each time)
- **Cost:** ~$30 in ElevenLabs credit for first audio fetch across all 208 cards

### Option B — Sweet spot (6 voices) ⭐ recommended

The historically vivid figures, plus a Master stand-in for unnamed buildings.

```
1. Roman Master      — narrates all 8 Roman buildings (warm Italian elder, what we already have)
2. Vitruvius         — guest moments inside Pantheon + Aqueduct
3. Leonardo da Vinci — Leonardo's Workshop, Flying Machine, cameos at Anatomy / Observatory
4. Cosimo de Medici  — Botanical Garden (intro) + Duomo (return)
5. Renaissance Master — Glassworks, Arsenal, Anatomy Theater (when not Vesalius), Observatory, Printing Press
6. Brunelleschi      — Duomo (finale)
```

- **Pros:** named voices where they're vivid; steady guides where they're not. Cosimo introduced early so Duomo finale lands. Leonardo's broad presence reflects his actual broad influence.
- **Cons:** still puts 5–6 buildings on a generic "Renaissance Master." Some kids may not register this is a different voice from Roman Master if we don't make them distinct enough.
- **Effort:** ~6 hours of voice generation. Standard rewrite time per building (~1.5 hrs each).
- **Cost:** ~$15 in ElevenLabs credit for first audio fetch across all 208 cards

### Option C — Minimal (3 voices)

Closest to current state. Ship fast.

```
1. Roman Master     — all 8 Roman buildings (already shipped, working)
2. Renaissance Master — all 9 Renaissance buildings except Duomo
3. Brunelleschi    — Duomo only
```

- **Pros:** smallest engineering surface, lowest writing burden, shippable in 2 weeks
- **Cons:** the apprentice "meets Brunelleschi at the end" loses dramatic weight because he's the only named figure. No buildup, no setup. Cosimo de Medici becomes a name in narration, not a voice.
- **Effort:** ~3 hours voice generation
- **Cost:** ~$10 in ElevenLabs credit

---

## Storyteller's character arc (independent of voice cast)

Regardless of which option we pick, the apprentice's journey through the 17 buildings should feel like a relationship developing. Recommended 5-act structure:

| Act | Buildings | Tone | Notes |
|---|---|---|---|
| **I — Welcome** | 1–3 (Aqueduct, Roads, Insula) | "Watch carefully, [name]." Patient, defines every term. | Apprentice is a newcomer. |
| **II — Apprentice grows** | 4–8 (Baths, Pantheon, Harbor, Siege, Colosseum) | "You're starting to see it." Callbacks to earlier buildings. Less hand-holding. | Apprentice is fluent in basics. |
| **III — Renaissance opens** | 9–11 (Botanical, Glassworks, Anatomy) | New world. Cosimo de Medici introduced. | Wonder + new vocabulary. |
| **IV — Master peers** | 12–14 (Observatory, Printing, Arsenal) | "You know this now, no?" Apprentice is treated as competent. | Light cameos from named figures. |
| **V — Leonardo & finale** | 15–17 (Workshop, Flying, Duomo) | Leonardo's voice; Brunelleschi takes over at Duomo; Cosimo returns. | Apprentice is now an architect. |

---

## Architect names in card content

Independent observation while reviewing existing cards: **most buildings don't name their architect in the on-screen text.** Pantheon says "Emperor Hadrian built this"; Step 4 mentions Vitruvius. But Aqueduct doesn't name Frontinus, Glassworks doesn't name Barovier, Anatomy Theater doesn't name Vesalius.

This is an easy fix during the rewrite pass — thread the architect's name into each building's lead card. Educational + sets up the voice reveal if we go with Option A or B.

---

## Wiring (technical implementation, any option)

Add a `narratorVoiceID: String?` field per `KnowledgeCard`, with a default that resolves by building name:

```swift
extension KnowledgeCard {
    var resolvedVoiceID: String {
        narratorVoiceID ?? NarratorVoice.forBuilding(buildingName)
    }
}

enum NarratorVoice {
    static let romanMaster = "..."
    static let leonardo = "..."
    static let brunelleschi = "..."
    // etc.

    static func forBuilding(_ name: String) -> String {
        switch name {
        case "Aqueduct", "Colosseum", ...: return romanMaster
        case "Leonardo's Workshop", "Flying Machine": return leonardo
        case "Duomo": return brunelleschi
        // etc.
        default: return romanMaster
        }
    }
}
```

`SpeakerButton` already accepts a `voiceID:` parameter — we'd pass `card.resolvedVoiceID` instead of the hardcoded `TTSVoice.storyteller`. Per-card override (the optional `narratorVoiceID`) lets us drop in Vitruvius for one specific card inside a Roman Master-narrated building.

---

## Open questions for the team

### 1. Which option (A / B / C)?
Marina + Claude lean toward **B**. Ray + Brianna's vote?

### 2. If B or A, do you agree with the architect choices?

| # | Building | Proposed voice | Alternatives to consider |
|---|---|---|---|
| 4 | Pantheon | Vitruvius (cameo) inside Roman Master narration | Apollodorus? Hadrian? |
| 12 | Anatomy Theater | Renaissance Master | Vesalius (more dramatic) — adds 1 voice |
| 15 | Vatican Observatory | Renaissance Master or Clavius | Galileo (more famous, but anachronistic to the building's founding) |
| 16 | Printing Press | Renaissance Master | Aldus Manutius (Venetian printer) — adds 1 voice |

### 3. Where does the **bird** fit?
The bird already has its own voice (Curious Bird — playful Italian, used for chat). When the architect speaks on a card, does the bird:
- (a) Stay silent during card reads
- (b) React occasionally — "Ah, the master is speaking!" / "Listen — Brunelleschi himself!"
- (c) Become the *opener* before the architect's voice — "Hey [name], this one is special. Listen."

Marina's instinct?

### 4. Do we name all architects in the on-screen card text, or only the ones who get a voice?
Recommend naming all of them regardless — it's just educational accuracy.

### 5. Architect-level (Ray's content) — does this voice cast extend, or does Architect level have its own?
If the apprentice "graduates" at the Duomo, Architect level could open with a fresh voice scheme (older apprentice, more peer-level dialogue). Or it could continue the same cast.

---

## Recommendation summary

**Pick:** Option B (6 voices)
**Rationale:** balanced cost + variety + narrative payoff. Brings 4 historical figures to life where it matters most; uses anonymous-master voices to keep the work tractable. Cosimo de Medici introduced at Botanical Garden makes the Duomo finale earn its emotional weight.

**Then:**
1. Generate the 5 new voices (we already have Roman Master)
2. I write a 1-page brief per building (act, callbacks, NPC moments, signature aside)
3. Marina approves the brief
4. I rewrite that building's cards
5. Marina tests on device, gives feedback
6. Move to next building

**Total time** for Apprentice level (16 remaining buildings): ~24 hours of paired work, spread across 4–6 sessions.

---

## Decision form (please mark)

- [ ] **Voice cast option:** A / B / C / other: ___
- [ ] **Brunelleschi voice gender + age range:** male, 50s, gruff master engineer (default)
- [ ] **Cosimo de Medici voice:** male, 40s, dignified patron
- [ ] **Leonardo voice:** male, 30s, restless and curious
- [ ] **Vitruvius voice:** male, 60s, scholarly Roman elder
- [ ] **Renaissance Master:** male, 50s, similar to Roman Master but Tuscan rather than Roman accent
- [ ] **Bird's role during card reads:** silent / reactive / opener
- [ ] **Architect names in on-screen card text:** all named where known / only voiced ones
- [ ] **Architect level scope:** continues this voice cast / starts fresh / TBD with Ray

---

## Sign-off

| Name | Role | Decision |
|---|---|---|
| Marina Pollak | Project Lead | |
| Ray Gramon | Level Designer | |
| Brianna Walker | Designer | |
