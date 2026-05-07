import SwiftUI

/// Master onboarding orchestrator — state machine through character select, transition video, and story pages
struct OnboardingView: View {
    @Bindable var onboardingState: OnboardingState
    var onComplete: () -> Void

    enum Phase: Equatable {
        case characterSelect
        case avatarTransition   // sprite-frame intro after choosing character
        case story(Int)         // index into OnboardingContent.storyPages
        case tierPicker         // subscription picker — fires after the last story page
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
                    StoryNarrativeView(
                        page: pages[index],
                        apprenticeName: onboardingState.apprenticeName,
                        apprenticeGender: onboardingState.apprenticeGender,
                    ) {
                        let nextIndex = index + 1
                        if nextIndex < pages.count {
                            withAnimation(.easeInOut(duration: 0.6)) {
                                phase = .story(nextIndex)
                            }
                        } else {
                            // Story complete — show the tier picker before exiting onboarding
                            withAnimation(.easeInOut(duration: 0.6)) {
                                phase = .tierPicker
                            }
                        }
                    }
                    .id(index) // force view recreation per page
                    .transition(.opacity)
                }

            case .tierPicker:
                SubscriptionPickerView(onboardingState: onboardingState) {
                    onboardingState.completeOnboarding()
                    onComplete()
                }
                .transition(.opacity)
            }
        }
        .overlay(alignment: .topTrailing) {
            // Skip button — available during avatar intro and story pages only.
            // The tier picker has no skip — players must choose a tier to enter the game.
            // Skip jumps to the tier picker phase, NOT past it. Without this,
            // players could bypass the paywall by tapping Skip during the story.
            if showsSkipButton {
                Button {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        phase = .tierPicker
                    }
                } label: {
                    Text("Skip")
                        .font(RenaissanceFont.bodySmall)
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

    private var showsSkipButton: Bool {
        switch phase {
        case .characterSelect, .tierPicker: return false
        case .avatarTransition, .story:     return true
        }
    }
}
