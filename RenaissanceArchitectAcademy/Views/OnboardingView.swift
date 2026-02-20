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

    var body: some View {
        ZStack {
            switch phase {
            case .characterSelect:
                CharacterSelectView(onboardingState: onboardingState) {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        phase = .avatarTransition
                    }
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
                    StoryNarrativeView(page: pages[index]) {
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
        .animation(.easeInOut(duration: 0.5), value: phase)
    }
}
