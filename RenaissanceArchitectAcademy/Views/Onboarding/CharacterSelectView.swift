import SwiftUI

/// Character selection screen — choose boy/girl apprentice and enter a name
struct CharacterSelectView: View {
    @Bindable var onboardingState: OnboardingState
    var onContinue: () -> Void

    @State private var selectedGender: ApprenticeGender? = nil
    @State private var name: String = ""
    @State private var showContent = false
    @FocusState private var nameFieldFocused: Bool

    /// Current animation frame index (0-14), shared between both avatars
    @State private var currentFrame: Int = 0
    private let frameCount = 15
    private let fps: Double = 10

    var body: some View {
        ZStack {
            RenaissanceColors.parchment
                .ignoresSafeArea()

            DecorativeCorners()

            VStack(spacing: 32) {
                Spacer()

                // Title
                VStack(spacing: 8) {
                    DividerOrnament()
                        .frame(width: 200)

                    Text("Choose Your Apprentice")
                        .font(.custom("Cinzel-Regular", size: 32))
                        .foregroundStyle(RenaissanceColors.sepiaInk)

                    Text("Florence, 1485")
                        .font(.custom("Mulish-Light", size: 18))
                        .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.6))

                    DividerOrnament()
                        .frame(width: 200)
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : -20)

                // Gender cards — 2x bigger with animated avatars
                HStack(spacing: 24) {
                    genderCard(gender: .boy)
                    genderCard(gender: .girl)
                }
                .opacity(showContent ? 1 : 0)

                // Name entry
                VStack(spacing: 12) {
                    Text("Your Name")
                        .font(.custom("EBGaramond-SemiBold", size: 18))
                        .foregroundStyle(RenaissanceColors.sepiaInk)

                    TextField("Enter your name...", text: $name)
                        .textFieldStyle(.plain)
                        .font(.custom("Mulish-Light", size: 18))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .frame(maxWidth: 280)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(RenaissanceColors.parchment)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .strokeBorder(RenaissanceColors.ochre.opacity(0.4), lineWidth: 1)
                                )
                        )
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                        .colorScheme(.light)
                        .focused($nameFieldFocused)
                        #if os(iOS)
                        .textInputAutocapitalization(.words)
                        #endif
                }
                .opacity(showContent ? 1 : 0)

                Spacer()

                // Continue button — ochre instead of blue
                Button {
                    if let gender = selectedGender {
                        onboardingState.apprenticeGender = gender
                        onboardingState.apprenticeName = name.isEmpty ? "Apprentice" : name
                        onContinue()
                    }
                } label: {
                    Text("Continue")
                        .font(.custom("EBGaramond-SemiBold", size: 20))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(selectedGender != nil
                                      ? RenaissanceColors.ochre
                                      : RenaissanceColors.stoneGray.opacity(0.4))
                        )
                }
                .disabled(selectedGender == nil)
                .opacity(showContent ? 1 : 0)
                .padding(.bottom, 40)
            }
            .padding(.horizontal, 32)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                showContent = true
            }
            startFrameAnimation()
        }
    }

    // MARK: - Frame Animation (plays once, no loop, no crossfade)

    private func startFrameAnimation() {
        Timer.scheduledTimer(withTimeInterval: 1.0 / fps, repeats: true) { timer in
            if currentFrame < frameCount - 1 {
                currentFrame += 1
            } else {
                timer.invalidate()
            }
        }
    }

    // MARK: - Gender Card (2x bigger with animated avatar)

    private func genderCard(gender: ApprenticeGender) -> some View {
        let isSelected = selectedGender == gender
        let framePrefix = gender == .boy ? "AvatarBoyFrame" : "AvatarGirlFrame"
        let frameName = String(format: "%@%02d", framePrefix, currentFrame)

        return Button {
            withAnimation(.spring(response: 0.3)) {
                selectedGender = gender
            }
        } label: {
            VStack(spacing: 12) {
                // Animated avatar from extracted frames
                Image(frameName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 270, height: 270)
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                Text(gender.displayName)
                    .font(.custom("EBGaramond-SemiBold", size: 22))
                    .foregroundStyle(RenaissanceColors.sepiaInk)
            }
            .frame(width: 300, height: 360)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected
                          ? RenaissanceColors.ochre.opacity(0.1)
                          : RenaissanceColors.parchment)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(
                        isSelected ? RenaissanceColors.ochre : RenaissanceColors.ochre.opacity(0.3),
                        lineWidth: isSelected ? 2.5 : 1
                    )
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
        }
        .buttonStyle(.plain)
    }
}
