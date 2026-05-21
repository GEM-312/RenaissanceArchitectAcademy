# Final Gnomic Self — Spring 2026

**Marina Pollak**
Columbia College Chicago — Final Semester
Week of May 1–7, 2026
10-min check-in with: _[Alex / Bill / faculty — fill in]_

---

## Part 1 — Final Reflection on the Weekly Check-In Work

### How is it going?
Honestly going strong. Weekly check-ins kinda became the spine of my semester. Looking back at the last 4 weeks i can see the pattern:

- **Apr 10–16:** 13 commits, 4 PRs, **−3,357 net lines** — cleanup week. @Observable migration, killed the old quiz system, theme + dark mode pass.
- **Apr 17–23:** 37 commits, 5 PRs, **+4,324 net lines** — build week. Game Center, Sezione sketching, full PencilKit redesign, new 7000×5000 terrain art.
- **May 1–7 (this week):** 46 commits, 2 PRs merged + a 3rd queued (`lorenzo-frames`, 25 commits ahead of main), **+4,551 net lines** — cinematic + audit week. Onboarding cinematic, font token migration (497 calls), ElevenLabs TTS through the Cloudflare Worker.

So basically cleanup weeks alternate with feature weeks. That rhythm is healthy. The check-ins themselves force me to actually look at what i shipped vs what i think i shipped, and the gap is always smaller than it feels mid-week.

### What do i need help with?
Honestly **Photoshop work**. The frame animation pipeline eats hours — extract frames from Midjourney/Pika videos, clean them up, re-export, drop into imagesets. Hard part is not every animation will allow for batch photoshop editing, some stuff have to be edited frame by frame. When all 15 frames are uniform i can run a Photoshop action across the whole set, that's quick. But most of mine have moving subjects, shifting lighting, or background details that change frame to frame, so i have to hand-mask the subject, clean the edges, fix bleed-through and repeat 15 times. Lorenzo letter alone is 56 frames. Avatar walk cycles, bird arrivals, volcano, river, tree sway — most of them fall on the manual side. I can do it but it's the slowest thing in my workflow and the easiest place for someone else to plug in. Pairing with someone strong in Photoshop would unblock weeks of polish.

### Career-plan honesty
My career field maybe end up different from what i imagined and im ok with that. The skills i built this semester — Swift/SwiftUI, AI API integration, serverless proxies, design systems, content authoring at scale — are exactly what my future employer is looking for, even if the job title isn't "iOS game developer." Game build still stays priority through May 15 cuz the game is what proves all those skills in one place.

### How is the career plan going?
Better than i expected: **i got a job lined up.** Im not 100% sure yet exactly what my role will look like day to day, but the position requires me to pass two certifications:
- **Databricks Associate / Professional**
- **Claude Certified Architect**

Both are in scope for me — Databricks builds on the data + cloud thinking i already use, and Claude Certified Architect maps directly to the AI work i've been doing all semester (Cloudflare Worker proxy, prompt caching, multi-API orchestration). Plan post graduation: ship the game, study for both exams, pass them, start the job. The game is what got me in the door even though the role isnt iOS.

### How is the portfolio going?
Havent even started yet — that's the next big lift after submission. Plan is one portfolio website with **both my projects as case studies**: Renaissance Architect Academy (the iOS game, AI integration, design system) plus my earlier project. Case study format means screenshots, written walkthrough of decisions and trade-offs, the Unity → SwiftUI migration story, links to the GitHub repos. If i can ship a v1 of the portfolio site between TestFlight submission and graduation that's the goal.

### How is the game going?
Better than i expected at the start of the semester.
- **17 buildings** in city map with era filtering (8 Ancient Rome + 9 Renaissance Italy)
- **All 17 buildings have lessons + vocabulary** authored — ~18–22 sections each
- **4 sketching phases** designed; Phase 1 (Pianta) + Sezione (cross-section) shipped via PencilKit
- **3 SpriteKit interiors** (Workshop outdoor, Crafting Room, Goldsmith) with Dijkstra pathfinding
- **Cloudflare Worker proxy** live at `raa-api.pollak.workers.dev` with prompt caching — no API keys in the bundle
- **Game Center** integration with 13 science achievements + leaderboards
- **Onboarding cinematic** with TTS narration on Page 1
- **Construction sequence puzzle** + Knowledge Cards system for Pantheon

**Forest scene** is the one area that didnt move this semester. It was under Brianna's ownership and looks completely the same as we started cuz nothing is done for it. The skeleton is there in code but the scene is not in a shippable state. After submission im either pulling it into my own scope or cutting it from v1.

What's left before May 15: TestFlight upload (PR #13), polish on the 4 frame adjustments, App Store submission, and authoring Knowledge Cards for the remaining 16 buildings (stretch goal — Pantheon proves the pattern).

### How is the team?
- **Ray** is doing an outstanding job on the Architect tier and master level content. He is so flexible, which is great for business. Rigid contributors slow everything down. Ray adapts when scope shifts, picks up what needs picking up, and ships. He's been the highest leverage human on the team this semester.
- **Brianna** — im not waiting much from her at this point and its fine with me. The work redistributes around the people who actually deliver, and that's how it has to be in the final weeks.
- **Me (Marina)** — design, code direction, art curation, content authoring, audio direction, all the final calls.
- **Marcus, Ariel and Jake** — audio support. They've been pitching in on sound design and audio assets which has been a real help given how many sound layers the game needs (UI sounds, ambient loops, station SFX, narration). Audio is one of those things that's invisible when it works and obvious when it's missing — having three people willing to contribute has made the difference.
- **Claude** — implementation partner. 46 commits in a week with one human is only possible cuz Claude handles the SwiftUI/SpriteKit grinding while i drive the decisions. Every taste call, every "no not that", every architectural choice is still mine.
- **OpenArt + ElevenLabs** — the art and voice pipeline.

Lesson on team this semester: it's not about how big the team is. It's about who delivers and who is flexible. Ray is both. That matters way more than headcount.

---

## Part 2 — New Gnomic Self (Post-Graduation)

### Three Values

1. **Craft.** Ship work i would put my name on without flinching. Quality is a long-term compounding asset — shortcuts taken in May show up in October. The Renaissance Architect Academy commit log is what craft looks like as a daily practice: small, honest, traceable, reviewed. Im taking that same standard into the new job.

2. **Leverage.** Build with tools and collaborators that multiply what one person can do. The Claude + Midjourney + Worker stack proved that one person plus the right AI partners can ship what used to take a team of five. The post-grad self chooses problems and roles where leverage compounds — which is exactly why a Claude Certified Architect track makes sense for me.

3. **Freedom through finished work.** Finished things buy options, unfinished things consume them. The job offer didnt come from a polished resume — it came from work i actually shipped. Every project from here forward gets carried to "done", cuz finished work is the only currency that buys real freedom.

### Three Hard Skills

1. **AI systems architecture.** Designing and shipping production AI features — Claude API integration, Cloudflare Worker proxy with prompt caching + KV stores, multi-API orchestration (Claude + ElevenLabs + Wolfram), no keys in the client, costs controlled, latency hidden. This is the foundation im building toward the **Claude Certified Architect** exam, and it's already a working system in the game today.

2. **iOS engineering (SwiftUI + SpriteKit) + Xcode fluency.** Production grade Swift with @Observable MVVM, SpriteKit ↔ SwiftUI bridging via SceneHolder, PencilKit, Game Center, AVAudio, on-device Foundation Models. End-to-end shipped product — design system, 17 buildings of content, sketching pipeline, onboarding cinematic. Im also adding **Xcode** itself — it's an amazing tool and i went from barely knowing it to actually fluent. My **Photoshop** skills also got way more fluent through all the frame animation work — masking, batching, frame-by-frame cleanup. And one of the biggest things i learned this semester: **game design is hard.** Way harder than i thought. Balancing learning + fun + difficulty + flow + accessibility is a real discipline, and i have respect for it now in a way i didnt before. Even if the day job isnt iOS, this whole stack is the credential that got me in the door.

3. **Design systems + content authoring at scale.** Color token systems (RenaissanceColors), font token migration (497 calls across 66 files), 17 buildings of original lesson + vocabulary + construction sequence content, Midjourney prompt engineering with consistent style refs, sprite-frame pipelines. Engineering taste + visual taste + content taste, all in one stack. This is the cross-functional skill that AI and data roles increasingly need, cuz the systems they ship still have to be designed and explained to humans.

---

## This Week's 10-Min Check-In Result

**Date:** _[fill in]_
**Faculty member:** _[Alex / Bill / other — fill in]_
**Notes from the conversation:**

- _[1–3 bullets on what was discussed]_
- _[Any commitments made for next week]_
- _[Any guidance / pushback received]_
