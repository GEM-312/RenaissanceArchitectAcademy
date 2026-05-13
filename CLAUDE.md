# Claude Memory - Renaissance Architect Academy

## Project Overview
Educational city-building game where students solve architectural challenges across 13+ sciences. Leonardo da Vinci notebook aesthetic with watercolor + blueprint style.

- **Developer:** Marina Pollak (Columbia College Chicago, final semester)
- **Ship target:** May 15, 2026
- **Tech:** SwiftUI + SpriteKit (migrated from Unity Feb 2025), iOS 17+ / macOS 14+
- **Art:** Midjourney (style ref `--sref 3186415970`)
- **Repo:** https://github.com/GEM-312/RenaissanceArchitectAcademy

## 17 Buildings

### Ancient Rome (8)
| # | Building | Sciences | Quiz | Sketching |
|---|----------|----------|------|-----------|
| 1 | Aqueduct | Engineering, Hydraulics, Math | Yes | Phase 1 |
| 2 | Colosseum | Architecture, Engineering, Acoustics | Yes | Phase 1 |
| 3 | Roman Baths | Hydraulics, Chemistry, Materials | Yes | No |
| 4 | Pantheon | Geometry, Architecture, Materials | No | Phase 1 |
| 5 | Roman Roads | Engineering, Geology, Materials | No | No |
| 6 | Harbor | Engineering, Physics, Hydraulics | No | No |
| 7 | Siege Workshop | Physics, Engineering, Math | No | No |
| 8 | Insula | Architecture, Materials, Math | No | No |

### Renaissance Italy (9)
| # | City | Building | Sciences | Quiz | Sketching |
|---|------|----------|----------|------|-----------|
| 9 | Florence | Duomo | Geometry, Architecture, Physics | Yes | Phase 1 |
| 10 | Florence | Botanical Garden | Biology, Chemistry, Geology | No | No |
| 11 | Venice | Glassworks | Chemistry, Optics, Materials | No | No |
| 12 | Venice | Arsenal | Engineering, Physics, Materials | No | No |
| 13 | Padua | Anatomy Theater | Biology, Optics, Chemistry | No | No |
| 14 | Milan | Leonardo's Workshop | Engineering, Physics, Materials | Yes | No |
| 15 | Milan | Flying Machine | Physics, Engineering, Math | No | No |
| 16 | Rome | Vatican Observatory | Astronomy, Optics, Math | Yes | No |
| 17 | Rome | Printing Press | Engineering, Chemistry, Physics | No | No |

### Building ID Mapping (SpriteKit string → ViewModel int)
```swift
"aqueduct": 1, "colosseum": 2, "romanBaths": 3, "pantheon": 4,
"romanRoads": 5, "harbor": 6, "siegeWorkshop": 7, "insula": 8,
"duomo": 9, "botanicalGarden": 10, "glassworks": 11, "arsenal": 12,
"anatomyTheater": 13, "leonardoWorkshop": 14, "flyingMachine": 15,
"vaticanObservatory": 16, "printingPress": 17
```

## Game Systems (high level — read the code for details)

- **City Map** (`CityScene` + `CityMapView`): 3500×2500 SpriteKit terrain, Tiber/Arno/Grand Canal rivers, player walks to tapped buildings, camera zooms to 0.7, MascotDialogueView with 3 choices (materials → MaterialPuzzleView, quiz, sketch).
- **Lesson System** (Read to Earn): paged reader, all 17 buildings have lessons + 6-term vocabulary. Lookup `LessonContent.lesson(for:)` and `NotebookContent.vocabularyFor(buildingName:)`. +10 florins on completion.
- **Challenge System**: multipleChoice / dragDropEquation / hydraulicsFlow. 6 buildings have quizzes. Pow library for celebrations.
- **Sketching Mini-Game**: 4 phases (Pianta/Alzato/Sezione/Prospettiva); Phase 1 + 2 + 3 implemented. PencilKit canvas. Content for Pantheon, Colosseum, Aqueduct, Duomo. State: `.available` → `.sketched` → `.construction` → `.complete`.
- **Material Puzzle**: 6×6 match-3, 3 formulas (limeMortar, concrete, glass).
- **Onboarding**: character select (boy/girl) + name → 5 cinematic narrative pages → bird companion intro. State persisted in UserDefaults via `OnboardingState` @Observable.
- **Workshop**: 3 interiors via `WorkshopView` — `.outdoor` (10 stations), `.craftingRoom` (4 furniture), `.goldsmith` (4 furniture). All Dijkstra pathfinding on 3500×2500 maps. See `master-level-system.md` in memory.
- **Forest** (`ForestScene` + `ForestMapView`): 5 tree POIs, truffle discovery system, 4 science cards per tree (Architecture/Furniture/Modern Use/Biology) gating timber collection.
- **Knowledge Cards** (`KnowledgeCardsOverlay`): per-building cards across 4 environments. Pantheon has 14; 16 buildings still need content authored. Morgan Housel style, ~60-80 words/card.
- **Construction Sequence**: drag-to-reorder puzzle, 8 steps per building, +20 florins. Lookup `ConstructionSequenceContent.sequence(for:)`.
- **Tools System**: 9 tools, buy at Market (10 florins) or craft via `ToolRecipe`. Required at stations except Market.
- **GameTopBarView**: shared nav bar (City/Workshop/Crafting/Forest). Building progress strip (green=complete, ochre=sketched, gray=locked).

## Key Architecture Patterns

- **MVVM**: views observe ViewModels via `@ObservedObject` (shared) or `@StateObject`. ContentView owns `CityViewModel` and passes it down.
- **SpriteKit + SwiftUI**: `SpriteView` bridges SKScene; callbacks communicate back.
- **SceneHolder pattern (CRITICAL)**: NEVER store SpriteKit scenes in `@State` — use `@State var sceneHolder = SceneHolder<SomeScene>()` (class wrapper in `GameSpriteView.swift`). `@State` mutations during body eval are silently dropped.
- **Platform conditionals**: `#if os(iOS)` / `#else` for UIKit vs AppKit. `PlatformColor` typealias lives in `CityScene.swift`.
- **Editor Mode required**: every scene/view with positioned elements has `#if DEBUG` editor mode. Press E to toggle, drag to reposition, dumps to console. SpriteKit: `SceneEditorMode`. SwiftUI: `DragGesture`.
- **Camera (SpriteKit)**: `.aspectFill`, zoom 0.5–3.5, `fitCameraToMap()`, `clampCamera()` 200pt padding.
- **Scene size standard**: ALL scenes use `mapSize = 3500×2500`, grid spacing 100, walk speed 467 pts/sec. Scale smaller logical content into this space.
- **SwiftUI Timer frame animations play ONCE**: do NOT use `% frameCount`. Stop the timer at last frame. (SKAction ambient loops are fine — see `feedback_skaction_loops_ok.md`.)
- **pbxproj editing**: tabs for indentation; new files need entries in PBXBuildFile, PBXFileReference, PBXGroup, PBXSourcesBuildPhase.

## Fonts & Style

- Custom fonts registered via CoreText in `RenaissanceArchitectAcademyApp.swift`: Cinzel (titles), EBGaramond (body — replaced Mulish Feb 2026), LibreBaskerville, LibreFranklin, PetitFormalScript (tagline), Delius (handwritten).
- Color palette: `Styles/RenaissanceColors.swift` — read it for hex values, don't duplicate here.

## Asset Workflow

Resize Midjourney exports before adding:
```bash
sips -Z 180 "filename.png"   # Science icons
sips -Z 120 "filename.png"   # Navigation icons
sips -Z 512 "filename.png"   # City/station icons
```

GIF/video → sprite frames:
1. Extract all frames at 512×512 (Claude, PIL).
2. Pick 15 evenly spaced → `selected/`.
3. Marina removes backgrounds in Photoshop → `clean/`.
4. Create `Assets.xcassets/[Name]Frame00-14.imageset/`.

## Build & Run

- Open `RenaissanceArchitectAcademy.xcodeproj` in Xcode, pick iPad sim or My Mac, Cmd+R.
- Headless: `xcodebuild -scheme RenaissanceArchitectAcademy -destination 'platform=macOS' build`

## MANDATORY Rules

- **NEVER change design, colors, sizes, layout, or visual appearance unless Marina asks.** Fix only what is requested. If a design change would help, ASK FIRST.
- **ALWAYS read the FULL file before editing it.** Never edit from memory or summaries. Read in chunks if large.
- **ALWAYS read related files before cross-file changes.** Callbacks/state/UI spanning Scene + MapView wrapper → read both.
- **PLAN before ANY code update.** State the approach in 2-4 bullets — what files, what changes, what risk — and wait for Marina's nod before editing. No exceptions, no "trivial" carve-out. Even a 1-line fix gets a one-bullet plan. If the change feels too obvious to plan, that's exactly when planning catches the misread.
- **ZERO hardcoding. Use the design system, always.**
  - **Colors:** only `RenaissanceColors` tokens (`.parchment`, `.sepiaInk`, `.terracotta`, `.ochre`, `.candleGlow`, …). NEVER `Color(red:green:blue:)`, NEVER raw `Color.gray/.white/.black` in views. If a needed shade doesn't exist, ADD it to `RenaissanceColors.swift` and use the token.
  - **Fonts:** only registered font tokens (`Cinzel-Bold`, `EBGaramond-Regular`, `PetitFormalScript-Regular`, …). NEVER `.font(.system(size:))`, NEVER raw `.title/.body/.caption` in shipped views. The 497-token migration (May 6) is the standard — don't regress it.
  - **Components:** reuse existing primitives — `themedCard`, `pillBackground`, `BirdModalOverlay`, `GameTopBarView`, `RenaissanceButton`, `SceneHolder`, `KnowledgeCardsOverlay`. Search first; only create a new one if nothing fits, and make it reusable from day one.
  - **Spacing / sizes:** no magic numbers in layout. If a value repeats, name it. Padding/corner radii/icon sizes should come from constants on the component, not littered across call sites.
  - **Assets:** every image goes through `Assets.xcassets` (resized via `sips` per workflow above). No inline base64, no loose PNGs in the bundle root.
- **Search before you create.** Before adding a view, modifier, color, or helper, grep for an existing one. Duplicates are the bug — consolidation is the fix.

## Concurrency Rules (SwiftUI + SpriteKit)

- **ViewModels touching UI are `@MainActor`.** `CityViewModel`, `WorkshopState`, `NotebookState`, `OnboardingState` all are — keep new ones that way.
- **Prefer `.task { }` over `.onAppear { Task { } }`.** `.task` auto-cancels when the view disappears; `.onAppear`+`Task` leaks work.
- **Prefer `try await Task.sleep(for: .seconds(x))` over `DispatchQueue.main.asyncAfter`** in new code. Old `asyncAfter` call sites can stay until they're touched.
- **Never block the main thread.** Disk I/O, network, JSON decode of large payloads, heavy compute → background `Task`, then hop with `await MainActor.run { … }` or `@MainActor` annotation before touching state/UI.
- **SpriteKit is NOT main-actor-isolated, but mutations from background tasks must still hop to main before touching nodes or the scene graph.** SKActions themselves run on SpriteKit's render thread — don't wrap them in `Task`.
- **`@Observable` (iOS 17+) for any NEW ViewModel.** Existing `ObservableObject`/`@Published` ones stay until intentionally migrated — no drive-by migrations.
- **No `[weak self]` cargo cult inside `Task { }`.** Structured tasks tied to a view's `.task` don't need it. Only use `[weak self]` when a closure escapes the owner's lifetime (timers, long SKActions, NotificationCenter).
- **No `Thread.sleep`. Ever.** Use `try await Task.sleep`.

## Optimization Rules

- **`LazyVStack` / `LazyHStack` / `LazyVGrid` for any list >10 items.** Eager stacks instantiate every child up front — fine for nav rows, deadly for building grids or notebook entries.
- **Never `AnyView`.** It erases the view type and kills SwiftUI's diffing. Use `@ViewBuilder` or `some View` instead.
- **Don't recompute expensive things in `body`.** Body runs constantly. Hoist to a `let`, computed property, or cached `@State`. No `Date()`/JSON decode/filter-sort-map chains inside `body`.
- **No `print()` in hot paths.** Frame loops (`update(_:)` in SKScene), `body` accessors, gesture handlers fired per drag-pixel. One tap shouldn't dump 60 logs/sec.
- **SpriteKit textures: preload at scene init, never inside `update()`.** Use `SKTextureAtlas` for sprite frames (boy/girl walk, volcano, bird) — atlases batch into one draw call.
- **Resize Midjourney assets BEFORE adding** (see Asset Workflow). Shipping a 4096×4096 PNG for a 120pt nav icon is a memory leak you ship to the user.
- **`@StateObject` only at the owner.** Pass down with `@ObservedObject`. Never `@StateObject` the same VM in two views — you'll get two instances and silent state drift.
- **Profile with Instruments before optimizing.** Don't guess at bottlenecks — Time Profiler / Allocations / Core Animation will tell you. Premature optimization is its own bug.

## Teaching System (PROACTIVE)

- Teach while coding when introducing a new pattern, avoiding a pitfall, fixing a bug, or writing non-trivial logic.
- Title in green via Bash: `echo -e "\n\033[1;32m━━━ TEACHING MOMENT: [Title] ━━━\033[0m\n"`
- Format: THE CONCEPT (1-2 sentences) → STEP BY STEP (numbered) → IN OUR CODE (specific reference) → KEY TAKEAWAY (1 sentence).
- Append to `Teaching.md`. Use `/teach [topic]` for on-demand lessons. MIT professor style — clear, no fluff.

## Notes

- Marina prefers direct fixes over long explanations.
- Push to GitHub after significant changes.
- `Challenge.swift` contains all quiz questions.
- Active work plans and session logs live in `~/.claude/projects/.../memory/` — check `MEMORY.md` for the index.
