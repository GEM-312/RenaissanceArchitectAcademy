import SwiftUI

/// Character selection screen — choose boy/girl apprentice and enter a name
struct CharacterSelectView: View {
    @Bindable var onboardingState: OnboardingState
    var onContinue: () -> Void

    @State private var selectedGender: ApprenticeGender? = nil
    @State private var name: String = ""
    @State private var showContent = false
    @FocusState private var nameFieldFocused: Bool

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
                        .font(.custom("Cinzel-Bold", size: 32))
                        .foregroundStyle(RenaissanceColors.sepiaInk)

                    Text("Florence, 1485")
                        .font(.custom("EBGaramond-Italic", size: 18))
                        .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.6))

                    DividerOrnament()
                        .frame(width: 200)
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : -20)

                // Gender cards
                HStack(spacing: 24) {
                    genderCard(gender: .boy)
                    genderCard(gender: .girl)
                }
                .opacity(showContent ? 1 : 0)

                // Name entry
                VStack(spacing: 12) {
                    Text("Your Name")
                        .font(.custom("Cinzel-Regular", size: 16))
                        .foregroundStyle(RenaissanceColors.sepiaInk)

                    TextField("Enter your name...", text: $name)
                        .font(.custom("EBGaramond-Regular", size: 18))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .frame(maxWidth: 280)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.5))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .strokeBorder(RenaissanceColors.ochre.opacity(0.4), lineWidth: 1)
                                )
                        )
                        .focused($nameFieldFocused)
                        #if os(iOS)
                        .textInputAutocapitalization(.words)
                        #endif
                }
                .opacity(showContent ? 1 : 0)

                Spacer()

                // Continue button
                Button {
                    if let gender = selectedGender {
                        onboardingState.apprenticeGender = gender
                        onboardingState.apprenticeName = name.isEmpty ? "Apprentice" : name
                        onContinue()
                    }
                } label: {
                    Text("Continue")
                        .font(.custom("Cinzel-Bold", size: 18))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(selectedGender != nil
                                      ? RenaissanceColors.renaissanceBlue
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
        }
    }

    // MARK: - Gender Card

    private func genderCard(gender: ApprenticeGender) -> some View {
        let isSelected = selectedGender == gender

        return Button {
            withAnimation(.spring(response: 0.3)) {
                selectedGender = gender
            }
        } label: {
            VStack(spacing: 12) {
                // Placeholder silhouette using SF Symbol
                Image(systemName: gender == .boy ? "figure.stand" : "figure.stand.dress")
                    .font(.system(size: 64))
                    .foregroundStyle(isSelected ? RenaissanceColors.renaissanceBlue : RenaissanceColors.sepiaInk.opacity(0.4))

                Text(gender.displayName)
                    .font(.custom("Cinzel-Regular", size: 16))
                    .foregroundStyle(RenaissanceColors.sepiaInk)
            }
            .frame(width: 140, height: 160)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected
                          ? RenaissanceColors.renaissanceBlue.opacity(0.08)
                          : RenaissanceColors.parchment)
                    .shadow(color: .black.opacity(isSelected ? 0.12 : 0.05), radius: isSelected ? 8 : 4, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        isSelected ? RenaissanceColors.renaissanceBlue : RenaissanceColors.ochre.opacity(0.3),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
        }
        .buttonStyle(.plain)
    }
}
