# GitHub Project Seed — Renaissance Architect Academy Roadmap

Pre-drafted issues to paste into the Roadmap project. Each block = one GitHub issue: copy the **title** into the title field, the **body** into the description, and assign to the suggested lane + labels.

**How auto-close works:** in the PR description for any PR that finishes one of these, write `Closes #42` (or `Fixes`, `Resolves`) using the actual issue number. When the PR merges, the issue auto-closes and moves to Done on the board.

---

## 🚢 Lane 1 — Ship v1 (by May 15)

### Frame opacity + size pass on onboarding pages
**Labels:** `ship-blocker`, `polish`, `onboarding`
**Body:**
Final visual pass on opacity (0.30–0.70 range tested) and size for animated background frames across all 4 onboarding pages. This is the last thing between PR #13 and TestFlight.

---

### Add BoyIntroAudio.m4a to onboarding bundle
**Labels:** `ship-blocker`, `audio`, `onboarding`
**Body:**
Boy gender variant of the onboarding intro narration. Currently has working fallback so build is green, but audio asset is still missing for parity with girl variant. Bundle into pbxproj at the existing audio IDs.

---

### Add InvitationParchment.png art
**Labels:** `ship-blocker`, `art`, `onboarding`
**Body:**
Page 3 background art for the Invitation letter. Currently has working fallback. Need final Midjourney pass + Photoshop cleanup, then drop into Assets.xcassets.

---

### Archive + upload PR #13 (`lorenzo-frames`) to TestFlight
**Labels:** `ship-blocker`, `release`
**Body:**
PR #13 is 25 commits ahead of main. Once frame pass + audio + parchment art are in, archive in Xcode and upload to App Store Connect for TestFlight distribution.

---

### App Store screenshots (iPhone + iPad)
**Labels:** `ship-blocker`, `app-store`
**Body:**
Need screenshot sets for both iPhone and iPad sizes. Capture: city map, workshop, sketching canvas, knowledge card flip, lesson reader, onboarding cinematic.

---

### App Store metadata (title, subtitle, description, keywords, category)
**Labels:** `ship-blocker`, `app-store`
**Body:**
Write App Store listing copy. Category: Education or Games > Educational. Subtitle: one-line hook. Keywords: research what learner-app keywords convert.

---

### App Store privacy nutrition label
**Labels:** `ship-blocker`, `app-store`, `compliance`
**Body:**
Declare what data the app collects. Cloudflare Worker proxy means no third-party SDKs are talking to the user's device. Game Center is the main data flow. Check what counts as "linked to user" vs "not linked."

---

### Submit for App Review
**Labels:** `ship-blocker`, `release`
**Body:**
Final step. Build, screenshots, metadata, privacy label all ready. Submit and start the review countdown.

---

## 🎬 Lane 2 — Portfolio (May 15–22)

### Pick portfolio site stack + register domain
**Labels:** `portfolio`, `setup`
**Body:**
Decide: Next.js + Vercel, plain HTML/CSS, Astro, or framework-of-choice. Register a personal domain (marinapollak.com or similar). 30 minutes max — don't overthink.

---

### Portfolio site v1 — landing page + bio
**Labels:** `portfolio`
**Body:**
Single landing page: who I am, what I do, links to both case studies, GitHub, LinkedIn, contact. Don't try to make it perfect — ship it.

---

### Case study: Renaissance Architect Academy
**Labels:** `portfolio`, `case-study`
**Body:**
Write the long-form case study: problem, design decisions, tech stack (SwiftUI + SpriteKit + Cloudflare Worker + Claude/ElevenLabs/Wolfram), the Unity → SwiftUI migration, screenshots, lessons learned, GitHub link, App Store link once live.

---

### Case study: earlier project
**Labels:** `portfolio`, `case-study`
**Body:**
Write up the earlier project at the same depth. Gives the portfolio range — shows it's not a one-trick portfolio.

---

### 30-second FM Calendar Demo video
**Labels:** `portfolio`, `video`, `depends-on:fm-calendar-demo`
**Body:**
Film the demo on iOS 26 device once `fm-calendar-demo` branch is working. Script: add real calendar event → trigger from Profile → bird suggests relevant building → tap into lesson. Edit in iMovie or similar.

---

### Unity → SwiftUI migration postmortem
**Labels:** `portfolio`, `writing`
**Body:**
Standalone written piece (could be Medium, blog on portfolio site, or LinkedIn article). Why we migrated, what surprised us, what would we do again, what we'd skip. This is the kind of writing that gets shared.

---

### 60–90 second pitch video
**Labels:** `portfolio`, `video`
**Body:**
The "elevator pitch" video for the portfolio landing page. Hook: "kids don't hate learning, they hate being told they're learning" (from Apr 24 game show pitch). Problem → twist → proof → ask.

---

## 📜 Lane 3 — Certifications (May–July)

### Build study schedule for both certs
**Labels:** `cert`, `planning`
**Body:**
Map out weeks: Databricks Associate first (foundation), then Databricks Professional, then Claude Certified Architect. Block calendar time. Decide on study materials (official courses, practice exams).

---

### Pass Databricks Associate exam
**Labels:** `cert`, `databricks`
**Body:**
Required for new role. Study from official Databricks Academy. Schedule exam date once first study pass complete.

---

### Pass Databricks Professional exam
**Labels:** `cert`, `databricks`
**Body:**
Required for new role. Builds on Associate. Hands-on Databricks practice ideal.

---

### Pass Claude Certified Architect exam
**Labels:** `cert`, `anthropic`, `ai`
**Body:**
Required for new role. The Cloudflare Worker proxy + multi-API orchestration in this game is real proof-of-skill — leverage it for the practical portion.

---

## 🪶 Lane 4 — v2 Features (post-cert)

### Implement FM Calendar contextual suggestions (full ship version)
**Labels:** `v2`, `ai`, `foundation-models`
**Body:**
Promote `fm-calendar-demo` from device-only demo to shipped feature. Polish UI, handle edge cases (no events, no permission), expand building-topic mapping, write proper onboarding for the calendar permission.

---

### Add ElevenLabs KV caching to Cloudflare Worker
**Labels:** `v2`, `worker`, `cost-optimization`
**Body:**
~30 min mirror of `cachedWolfram` pattern. Cache key: `tts:${voiceId}:${sha256(text)}`, store audio bytes in KV, 30-day TTL, return `x-cache: HIT/MISS` header. Pantheon narration is deterministic so hit rate ~100% after first play. ElevenLabs is the most expensive upstream service per character.

---

### Forest scene rebuild
**Labels:** `v2`, `scene`, `forest`
**Body:**
Forest scene didn't move all semester (was Brianna's ownership, didn't progress). Pull into own scope OR cut from v1. Decision needed: rebuild from existing skeleton, or remove from city map until ready.

---

### Knowledge Cards for remaining 16 buildings
**Labels:** `v2`, `content`, `knowledge-cards`
**Body:**
Pantheon has 14 cards (5 cityMap + 4 workshop + 2 forest + 3 craftingRoom). Replicate the pattern across all 16 remaining buildings. Morgan Housel writing style — punchy, story-driven, ~60–80 words per card. Aurora glow uses per-science color.

---

### Sketching Phase 2 (Alzato — elevation)
**Labels:** `v2`, `sketching`
**Body:**
Drag-drop facade elements. Phase 1 (Pianta) and Sezione (cross-section) shipped. Alzato is the next phase in the original 4-phase sketching design.

---

### Sketching Phase 4 (Prospettiva — perspective)
**Labels:** `v2`, `sketching`
**Body:**
Vanishing points + perspective drawing. Final phase in the 4-phase sketching system.

---

### Expand sketching content to all 17 buildings
**Labels:** `v2`, `sketching`, `content`
**Body:**
Currently only Pantheon, Colosseum, Aqueduct, Duomo have sketching challenges authored. Expand to all 17.

---

### Source missing music tracks (5 of 6)
**Labels:** `v2`, `audio`, `music`
**Body:**
Per audio inventory: 35 SFX shipped, but 5 of 6 music tracks are MISSING. Need ambient Renaissance loops for: main menu, city map, workshop, forest, crafting room. Source from royalty-free libraries or commission.

---

### Tree sway animation (Old Man's Journey style)
**Labels:** `v2`, `animation`, `forest`
**Body:**
Code sketch ready, awaiting Photoshop tree cuts. Adds atmospheric life to the Forest scene.

---

### Bug bash — 6 queued issues
**Labels:** `v2`, `bug`
**Body:**
Bird/cards mismatch, station overlay, stale counter, card text size (15→30), GC activity, haptics. See `project_bug_fix_plan.md` in memory.

---

## 🪞 Lane 5 — Retrospective (after May 15)

### End-of-semester retrospective writeup
**Labels:** `retro`, `writing`
**Body:**
What went well, what didn't, what surprised me, what I'd do differently. Solo+AI team dynamics, Photoshop bottleneck, Brianna's lane stalling, Ray's flexibility being the high-leverage human, Foundation Models pivots (Medici scrapped, calendar resurrected). Material for the Unity→SwiftUI postmortem AND for future interviews.
