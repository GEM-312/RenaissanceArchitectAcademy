# Sketching mini-game — notes for Claude

Moved from the root CLAUDE.md on 2026-10-09 so it loads only when working in this folder.

### Sketching Mini-Game (4 phases, Phase 1 implemented)
- Phases: Pianta (floor plan), Alzato (elevation), Sezione (cross-section), Prospettiva (perspective)
- Phase 1: SwiftUI Canvas grid, wall drawing, column placement, circle drawing, room detection
- Strict validation: 90% wall coverage, exact circle match, neatness checks
- Bird companion hint system (3-level progressive hints)
- Content for: Pantheon, Colosseum, Aqueduct, Duomo
- Lookup: `SketchingContent.sketchingChallenge(for: buildingName)`
- BuildingState progression: `.available` → `.sketched` → `.construction` → `.complete`
