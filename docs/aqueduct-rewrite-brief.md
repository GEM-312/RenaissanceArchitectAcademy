# Aqueduct Cards — Storyteller Rewrite Brief

**Building:** Aqueduct (Aqua Claudia) — Building #1, first in the apprentice's journey
**Cards to rewrite:** 12 (5 cityMap, 4 workshop, 3 craftingRoom — no forest cards)
**Target file:** `RenaissanceArchitectAcademy/Models/KnowledgeCardContentRome.swift` (lines 12–329)
**Reference template:** Pantheon's 14 cards (already shipped in storyteller register, May 5)
**Prerequisite:** Marina approves this brief before any `lessonText` edits

---

## Act position

**Act I — Welcome.** Per the 5-act arc in `voice-cast-plan.md` (line 122), Aqueduct opens with **Roads** and **Insula** as the apprentice's introduction to Rome. The Storyteller treats the apprentice like a newcomer — **patient**, **defines every term**, doesn't assume prior knowledge.

This is the **first building** the apprentice ever studies. The lead card needs to **welcome them in**, not jump straight into engineering specs. Pantheon (Act II) opens with "Look. Sixteen columns…" — Aqueduct should open softer, like meeting a teacher for the first time.

## Narrator(s)

- **Storyteller (Roman Master)** — voice ID `yUUnPL3w0TMlYSSSuEO8`, the same voice we shipped on Pantheon. Warm Italian-accented Roman elder, theatrical but not over-performed.
- **Vitruvius cameo** (Step 2 — Gradient Math) — when explaining the math, the Storyteller can quote Vitruvius directly ("Vitruvius wrote it down for us — quarter-inch fall per hundred feet…"). Once Vitruvius gets his own voice, this quoted line can be re-recorded in his voice. For now: single-voice with attribution.
- **Frontinus cameo** (final card — Flow Rate Testing) — Storyteller introduces Frontinus by name as the man who actually measured the water. Same setup as Vitruvius: quoted attribution now, swappable to a real voice later.

The architect attribution map in `voice-cast-plan.md` line 41 lists Vitruvius + Frontinus for Aqueduct — both are threaded into the current cards but **not named by title or relationship to the apprentice**. The rewrite should make their roles vivid: *Vitruvius the writer*, *Frontinus the inspector*.

## Signature register

Match the Pantheon rules:

- **Periods over ellipses** for clear pauses ("Down. Down to eight massive piers.")
- **Em dashes for asides** ("six meters thick — six.")
- **Conversational openers**: "Look.", "Now.", "Listen.", "See?", "Imagine."
- **One comprehension check per card**: "Strange — no?", "Beautiful — no?", "Are you ready?", "Feel it?"
- **Short sentences** — the audio rhythm needs to breathe
- **"We" inclusive** — narrator + apprentice doing it together ("Together, we will build it…")
- **Land the lesson** — end on a punchy line that crystallizes the takeaway

## Aqueduct-specific signature aside

Pantheon's recurring beat was "the strongest part is the part nobody sees" (foundation), "the prettiest part is the smartest" (coffers), "the weakest-looking point is the strongest" (oculus) — **paradoxes**.

Aqueduct's recurring beat is **invisibility + precision**. 85% of it is underground. The gradient drops a marble's width per kilometer. The genius is hidden. Recommend the Storyteller repeats variants of: **"You cannot see it — but it is there."** Threaded through 3–4 cards as a callback to the lead card.

## Callbacks (forward, not backward)

This is Building #1 — there are no prior buildings to call back to. Instead, **plant seeds** for future buildings:

- **Voussoirs + keystone** (Step 5 card) — same physics returns at Colosseum, Pantheon dome. Storyteller hints: "You will see this again — when we build greater things."
- **Pozzolana** (Step 7 card) — same volcanic ash returns at Pantheon Step 4 (concrete). Same setup line.
- **Lime burning** (Crafting Room furnace card) — returns at Pantheon Step 1 quicklime. Hint at it.

These callbacks make Pantheon (Act II) **feel earned** when the apprentice meets the same materials again.

## Per-card register notes (12 cards)

Current `lessonText` is good factual content but reads like a textbook narrator — third-person, expository, no warmth. Rewrites preserve **every fact** but switch register to first-person Storyteller addressing the apprentice.

### City Map (5 cards)

| # | Current title | Rewrite focus |
|---|---|---|
| 0 | The Aqua Claudia | **LEAD CARD** — flag `isLeadCard: true`. Welcome the apprentice. Don't open with "69 kilometers" — open with "Welcome to Rome." Establish the journey. Name Claudius. Land the invisibility paradox. |
| 1 | Step 1: The Chorobates | Open with "Before a single stone — we must measure." Storyteller's hands describing the wooden beam. The marble-on-floor metaphor stays — it's perfect for audio. |
| 2 | Step 2: Gradient Math | **Vitruvius cameo lands here.** Storyteller quotes him. Math without calculators — frame it as patience. "A million people needed water." |
| 3 | Step 5: Arches & Voussoirs | The "strong because it wants to fall apart" paradox is already there — keep verbatim, just rephrase around it. Plant the callback for Colosseum + Pantheon. |
| 4 | Step 6: The Specus | The "fountains → baths → homes" hierarchy is a great social-history beat. Frame it as Roman priorities. "If water ran low — your home lost first." |

### Workshop (4 cards)

| # | Current title | Rewrite focus |
|---|---|---|
| 5 | Step 4: Mortar vs Concrete | Opens the "binders" thread that runs through every Roman building. "Same glue. Different recipe." |
| 6 | Step 7: Waterproof Lining | The pozzolana discovery story — frame it as accident, then planet-changing. Plant the Pantheon callback. |
| 7 | Opus Signinum | The "crushed pottery → waterproof" surprise. "Smoother than your modern plumbing." Storyteller earns a small joke. |
| 8 | Lead Fistulae Pipes | The toxicity note at the end is a hard pivot — soften it. "The Romans did not know. Centuries would pass before we did." |

### Crafting Room (3 cards)

| # | Current title | Rewrite focus |
|---|---|---|
| 9 | Mixing Aqueduct Mortar | Hands-on register. "Now — your hands get dirty." (Mirrors Pantheon Step 4 opener.) Trowel test as ritual. |
| 10 | Firing Signinum Lining | The "ring test" is sensory — perfect for audio. "Listen — when it rings clear, it is ready." |
| 11 | Flow Rate Testing | **Frontinus cameo lands here.** Storyteller introduces him by name + role. "Measure everything. Waste nothing." Close on infrastructure-runs-on-data line. Last card = closing beat for the building. |

## NPC moments

- **Vitruvius** (Card 2 — Gradient Math): quoted, attributed by name. Not a separate voice yet.
- **Frontinus** (Card 11 — Flow Rate Testing): introduced by name + title ("Rome's water commissioner"). Last word of the building.

Both names should also appear in the **on-screen card text**, not just narration — per `voice-cast-plan.md` line 132 ("most buildings don't name their architect in the on-screen text").

## Architect names to thread in

- **Claudius** — already in card 0. Keep.
- **Vitruvius** — add to card 2's lessonText AND its `notebookSummary`. Currently not named in this building's cards.
- **Frontinus** — already in card 11 (workshop shelf). Strengthen — make him the closing beat of the whole building.

## Lead card flag

Card 0 (`1_cityMap_building_0`) needs `isLeadCard: true` appended (currently missing — only Pantheon's first card has it). This triggers the "Ah, {name} —" personalized vocative the Storyteller speaks when the card is first narrated.

## Out of scope for this rewrite

- **Voice variety** — staying on Storyteller for all 12 cards. Vitruvius + Frontinus cameos are textual attributions now; separate voices come later.
- **Visual changes** — `CardVisual`, infographics, keywords, activities — all unchanged. Only `lessonText`, `notebookSummary`, and the `isLeadCard` flag on card 0.
- **Italian title polish** — keep current Italian titles.
- **Card structure** — 12 cards stays 12 cards. No additions, no removals.

## Process per voice-cast-plan.md step-by-step

1. ✅ Read existing 12 cards in full
2. ⏳ **Marina approves this brief** ← we are here
3. Rewrite 12 `lessonText` strings in `KnowledgeCardContentRome.swift` (one commit per ~4 cards for review, OR one commit for all 12 — Marina's call)
4. Add `isLeadCard: true` to card 0
5. Build & verify (`xcodebuild -scheme RenaissanceArchitectAcademy -destination 'platform=macOS' build`)
6. Marina tests on device — narrates each card via SpeakerButton
7. Marina gives feedback, tune individual cards
8. Commit, move to next building (Roads — Act I continues)
