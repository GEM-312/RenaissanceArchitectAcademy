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

    /// Start background generation of Medici commission text.
    /// Called during avatar transition — text only, no images (Marina generates art in Midjourney).
    private func startMediciGeneration() {
        if #available(iOS 26.0, macOS 26.0, *) {
            Task {
                if let commission = await OnboardingContent.generateMediciCommission() {
                    let text = OnboardingContent.mediciStoryText(from: commission)
                    if case .avatarTransition = phase {
                        generatedMediciText = text
                    }
                }
            }
        }
    }
}
