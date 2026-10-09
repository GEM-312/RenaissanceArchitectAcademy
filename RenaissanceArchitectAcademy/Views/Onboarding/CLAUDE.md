# Onboarding — notes for Claude

Moved from the root CLAUDE.md on 2026-10-09 so it loads only when working in this folder.

### Onboarding System (Models/OnboardingState + OnboardingContent, Views/Onboarding/)
- Character selection (boy/girl) + name entry → 3-page animated narrative → bird companion intro
- `OnboardingState` @Observable with UserDefaults persistence (hasCompletedOnboarding, gender, name)
- `StoryNarrativeView` — typewriter text reveal, BirdCharacter entrance animation
- `StationLessonOverlay` — bird teaches history/science before first station visit (per session)
- `stationsLessonSeen: Set<ResourceStationType>` in WorkshopState tracks which lessons shown
- Currently always shows onboarding (skip check commented out in ContentView for development)
- Forest station: after lesson, shows choice dialogue (Collect Timber vs Explore the Forest)
