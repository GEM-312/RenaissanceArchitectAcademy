import SwiftUI

/// Master onboarding orchestrator — state machine through character select, transition video, and story pages
struct OnboardingView: View {
    @Bindable var onboardingState: OnboardingState
    var onComplete: () -> Void

    enum Phase: Equatable {
        case characterSelect
        case avatarTransition   // travel video after choosing character
        case story(Int)         // index into OnboardingContent.storyPages
    }

    @State private var phase: Phase = .characterSelect

    /// Generated Medici commission text — populated in background during avatar transition.
    /// If nil by the time story page 0 displays, static text is used (guaranteed fallback).
    @State private var generatedMediciText: String?
    /// Generated scene: Renaissance study room (background)
    @State private var mediciSceneImage: CGImage?
    /// Generated letter: sealed parchment with wax seal (inline)
    @State private var mediciLetterImage: CGImage?
    /// Generated Florin mascot: walking gold coin with painter's beret (inline)
    @State private var florinMascotImage: CGImage?

    var body: some View {
        ZStack {
            switch phase {
            case .characterSelect:
                CharacterSelectView(onboardingState: onboardingState) {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        phase = .avatarTransition
                    }
                    // Start Medici generation in background while avatar transition plays
                    // This gives ~5-10 seconds before story page 0 appears
                    startMediciGeneration()
                }
                .transition(.opacity)

            case .avatarTransition:
                AvatarTransitionView(gender: onboardingState.apprenticeGender) {
                    withAnimation(.easeInOut(duration: 0.6)) {
                        phase = .story(0)
                    }
                }
                .transition(.opacity)

            case .story(let index):
                let pages = OnboardingContent.storyPages
                if index < pages.count {
                    StoryNarrativeView(
                        page: pages[index],
                        // Only override on page 0 (Medici commission) when generated
                        dynamicTextOverride: index == 0 ? generatedMediciText : nil,
                        dynamicSceneImage: index == 0 ? mediciSceneImage : nil,
                        dynamicLetterImage: index == 0 ? mediciLetterImage : nil,
                        dynamicMascotImage: index == 0 ? florinMascotImage : nil
                    ) {
                        let nextIndex = index + 1
                        if nextIndex < pages.count {
                            withAnimation(.easeInOut(duration: 0.6)) {
                                phase = .story(nextIndex)
                            }
                        } else {
                            // Story complete — mark onboarding done and exit
                            onboardingState.completeOnboarding()
                            onComplete()
                        }
                    }
                    .id(index) // force view recreation per page
                    .transition(.opacity)
                }
            }
        }
        .overlay(alignment: .topTrailing) {
            // Skip button — available after character select
            if phase != .characterSelect {
                Button {
                    onboardingState.completeOnboarding()
                    onComplete()
                } label: {
                    Text("Skip")
                        .font(.custom("EBGaramond-Regular", size: 15))
                        .foregroundStyle(.white.opacity(0.7))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(.black.opacity(0.3)))
                }
                .buttonStyle(.plain)
                .padding(.top, 16)
                .padding(.trailing, 20)
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: phase)
    }

    // MARK: - Medici Commission Generation

    /// Start background generation of Medici content: text + scene image + letter image.
    /// All 3 generate in parallel during the avatar transition (~5-10 seconds).
    /// Whatever finishes in time gets shown; whatever doesn't uses static fallback.
    private func startMediciGeneration() {
        if #available(iOS 26.0, macOS 26.0, *) {
            print("🎨 [Medici] Starting generation — Foundation Models available: \(GenerationService.isAvailable)")
            print("🎨 [Medici] Image Playground available: \(ImageGenerationService.isAvailable)")
            print("🎨 [Medici] Unavailability reason: \(GenerationService.unavailabilityReason ?? "none")")

            // Simple test: generate the most basic possible image to verify Image Playground works
            Task {
                guard ImageGenerationService.isAvailable else { return }
                print("🎨 [TEST] Trying simplest possible image: 'a red apple'...")
                do {
                    let testImage = try await ImageGenerationService.shared.generateImage(
                        prompt: "A red apple on a wooden table",
                        cacheKey: "test_apple"
                    )
                    print("🎨 [TEST] ✅ Simple image result: \(testImage != nil ? "SUCCESS" : "nil")")
                } catch {
                    print("🎨 [TEST] ❌ Simple image error: \(error)")
                }
            }

            // Generate text — only set if still on avatarTransition (can't swap mid-typewriter)
            Task {
                print("🎨 [Medici] Generating commission text...")
                if let commission = await OnboardingContent.generateMediciCommission() {
                    let text = OnboardingContent.mediciStoryText(from: commission)
                    print("🎨 [Medici] ✅ Text generated: \(text.prefix(80))...")
                    if case .avatarTransition = phase {
                        generatedMediciText = text
                    } else {
                        print("🎨 [Medici] ⚠️ Text too late — typewriter already started, using static")
                    }
                } else {
                    print("🎨 [Medici] ❌ Text generation returned nil")
                }
            }

            // Generate scene image — NO people, just the room/objects
            // Images can arrive late — they fade in gracefully on story(0)
            Task {
                guard ImageGenerationService.isAvailable else {
                    print("🎨 [Medici] ⏭️ Skipping scene image — Image Playground not available")
                    return
                }
                print("🎨 [Medici] Generating scene image...")
                do {
                    let image = try await ImageGenerationService.shared.generateImage(
                        prompt: "An ornate Renaissance study with a carved wooden desk, open letters, a feather quill in a brass ink pot, and a red wax seal stamp. Leather-bound books on shelves, architectural drawings on the wall. Through an arched window, a sunset skyline with domed rooftops. Warm candlelight, golden atmosphere.",
                        cacheKey: "onboarding_study_room"
                    )
                    if let image {
                        print("🎨 [Medici] ✅ Scene image generated (phase: \(phase))")
                        mediciSceneImage = image
                    } else {
                        print("🎨 [Medici] ⚠️ Scene image returned nil")
                    }
                } catch {
                    print("🎨 [Medici] ❌ Scene image error: \(error)")
                }
            }

            // Generate letter image — can also arrive late
            Task {
                guard ImageGenerationService.isAvailable else {
                    print("🎨 [Medici] ⏭️ Skipping letter image — Image Playground not available")
                    return
                }
                print("🎨 [Medici] Generating letter image...")
                do {
                    let image = try await ImageGenerationService.shared.generateImage(
                        prompt: "A folded aged parchment letter sealed with a red wax stamp, lying on a dark wooden desk. A feather quill rests in a brass ink pot beside it. The paper is yellowed and textured with visible creases. Warm candlelight illuminates the scene.",
                        cacheKey: "onboarding_medici_letter"
                    )
                    if let image {
                        print("🎨 [Medici] ✅ Letter image generated (phase: \(phase))")
                        mediciLetterImage = image
                    } else {
                        print("🎨 [Medici] ⚠️ Letter image returned nil")
                    }
                } catch {
                    print("🎨 [Medici] ❌ Letter image error: \(error)")
                }
            }

            // Generate Florin mascot: walking gold coin with painter's beret
            Task {
                guard ImageGenerationService.isAvailable else { return }
                print("🎨 [Medici] Generating Florin mascot...")
                do {
                    let image = try await ImageGenerationService.shared.generateImage(
                        prompt: "A cheerful golden coin character with small arms and legs, wearing a Renaissance painter's beret and carrying a tiny easel and paintbrush. The coin face shows a lily flower emblem. Whimsical, elegant, warm golden glow.",
                        cacheKey: "onboarding_florin_mascot_anim",
                        style: .animation
                    )
                    if let image {
                        print("🎨 [Medici] ✅ Florin mascot generated")
                        florinMascotImage = image
                    }
                } catch {
                    print("🎨 [Medici] ❌ Florin mascot error: \(error)")
                }
            }
        } else {
            print("🎨 [Medici] ⏭️ Skipping — iOS/macOS 26 not available")
        }
    }
}
