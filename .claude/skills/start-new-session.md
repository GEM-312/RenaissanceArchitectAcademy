---
name: start-new-session
description: Run the mandatory session-start protocol — read full memory + CLAUDE.md, ask Marina what to work on before assuming. ALWAYS run this at the start of a new session.
user_invocable: true
---

# Start New Session — Mandatory Protocol

This protocol exists because past sessions broke working code by skipping it. Origin: `feedback_session_mistakes.md` (Mar 17 2026). Follow every step in order. No shortcuts.

## The Protocol

### 1. Read ALL memory files — not just the index
The MEMORY.md file is an **index**, not the memory itself. Open each linked file under "🎯 NEXT SESSION — START HERE", "Active Work Plans" (the entries flagged as relevant to the current branch), and any `feedback_*.md` not yet absorbed this session. Note the age stamp on each file — if it's >30 days old and contradicts a newer file, trust the newer one.

Minimum read set every session:
- `/Users/pollakmarina/.claude/projects/-Users-pollakmarina-RenaissanceArchitectAcademy/memory/MEMORY.md` (index)
- The most recent `project_session_*.md` (latest EOD log)
- `next-session-priority.md` if present
- All `feedback_*.md` files (rules — these are durable, re-read them)
- Any file MEMORY.md flags as "START HERE" for today

### 2. Read CLAUDE.md — follow MANDATORY rules
The project CLAUDE.md is loaded automatically into context. Confirm you've seen the **MANDATORY Rules** block (no design changes without asking, read FULL file before editing, plan before any code update, zero hardcoding, search before creating) and the **Concurrency** + **Optimization** rules. These override defaults.

### 3. Ask Marina what she wants to work on — DO NOT assume
Even if memory says "next session: do X", Marina's priorities shift. State what you read in memory, then ask her what's first. Never start editing files based on a memory plan alone.

### 4. Read ALL files involved before any changes
If a task touches 5 files, read all 5 FULLY before writing a single line. No edits from memory or summaries. No partial reads when the file is small enough to read whole. For cross-file changes (e.g. SpriteKit scene + SwiftUI wrapper), read both before touching either.

### 5. Plan the full change — trace the flow, identify all files
Before any code update, state the approach in 2–4 bullets: what files, what changes, what risk. Trace the complete flow on paper: user action → which function → what state changes → which views react. Wait for Marina's nod before editing. No "trivial" carve-out — even a 1-line fix gets a one-bullet plan.

### 6. One file at a time — build/verify after each
Never make the same change to 4+ files simultaneously without testing the first one. Edit one file → build (`xcodebuild -scheme RenaissanceArchitectAcademy -destination 'platform=macOS' build`) → confirm green → move to the next. Incremental fixes that break other things compound fast (Mar 17 lost 3 hours this way).

### 7. Use the teaching system as you code
Drop a teaching moment DURING coding, not after. New pattern, avoided pitfall, non-trivial logic → invoke `/teach` style: green title via Bash, then CONCEPT → STEP BY STEP → IN OUR CODE → KEY TAKEAWAY. Append to `Teaching.md`.

### 8. Trace through code yourself before telling Marina to test
Read the change end-to-end. Walk through the user flow mentally. Only ask Marina to test once you've convinced yourself it works. "Try it" without tracing wastes her time.

### 9. Don't rush
Slower and correct beats fast and broken. If you feel rushed, that's exactly when you skip step 4 and break something. Pause, re-read, then proceed.

## How to use this skill

When Marina runs `/start-new-session`:

1. Execute steps 1–2 yourself (read memory + CLAUDE.md). Report back briefly: which files you read and the one-line takeaway from each.
2. Surface the current branch state, pending PRs, and what memory says is "next" — but frame it as "memory suggests X; what do you actually want to work on?"
3. STOP. Do not proceed to step 4+ until Marina answers.

Steps 4–9 then apply to every subsequent task in the session, not just this kickoff.

## What this skill is NOT

- Not a summary of the project — that's CLAUDE.md
- Not a place to dump session notes — those go in `project_session_<date>.md` at EOD
- Not optional — if Marina says "start session" or opens a new conversation, run this
