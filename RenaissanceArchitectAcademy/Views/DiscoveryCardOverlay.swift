import SwiftUI

// MARK: - Discovery Card Overlay
// Shown when the player visits a station WITHOUT an active building.
// Fun historical story + "Choose a Building" CTA.

struct DiscoveryCardOverlay: View {
    let card: DiscoveryCard
    let onDismiss: () -> Void
    let onChooseBuilding: () -> Void  // Navigate to city map to pick a building
    var playerName: String = "Apprentice"

    @State private var isFlipped = false
    @State private var showContent = false
    @State private var animateStory = false

    var body: some View {
        ZStack {
            // Dimmed background
            RenaissanceColors.overlayDimming
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            // Card
            VStack(spacing: 0) {
                if !isFlipped {
                    cardFront
                } else {
                    cardBack
                }
            }
            .frame(width: isFlipped ? 540 : 220, height: isFlipped ? 700 : 300)
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isFlipped)
            .rotation3DEffect(
                .degrees(isFlipped ? 180 : 0),
                axis: (x: 0, y: 1, z: 0),
                perspective: 0.4
            )
            .onTapGesture {
                if !isFlipped {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        isFlipped = true
                    }
                    // Start story animation after flip
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(.easeIn(duration: 0.3)) {
                            showContent = true
                        }
                        withAnimation(.easeIn(duration: 0.8).delay(0.3)) {
                            animateStory = true
                        }
                    }
                }
            }
        }
        .transition(.opacity)
    }

    // MARK: - Card Front

    private var cardFront: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [card.color.opacity(0.15), RenaissanceColors.parchment],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(card.color.opacity(0.5), lineWidth: 2)
                )
                .shadow(color: card.color.opacity(0.3), radius: 8, y: 4)

            VStack(spacing: 12) {
                // Discovery badge
                Text("DISCOVERY")
                    .font(.custom("Cinzel-Bold", size: 10))
                    .tracking(2)
                    .foregroundStyle(card.color)

                // Icon
                Image(systemName: card.icon)
                    .font(.system(size: 44))
                    .foregroundStyle(card.color)
                    .shadow(color: card.color.opacity(0.3), radius: 4)

                // Station name
                Text(card.stationName)
                    .font(.custom("Cinzel-Bold", size: 18))
                    .foregroundStyle(RenaissanceColors.sepiaInk)
                    .multilineTextAlignment(.center)

                // Italian name
                Text(card.italianName)
                    .font(.custom("EBGaramond-Italic", size: 14))
                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.6))

                Spacer().frame(height: 8)

                // Tap hint
                Text("Tap to discover")
                    .font(.custom("EBGaramond-Regular", size: 13))
                    .foregroundStyle(card.color.opacity(0.7))
            }
            .padding(20)
        }
    }

    // MARK: - Card Back (flipped, so mirrored)

    private var cardBack: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 16)
                .fill(RenaissanceColors.parchment)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(card.color.opacity(0.4), lineWidth: 2)
                )
                .renaissanceShadow(.modal)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 16) {
                    // Header
                    HStack(spacing: 8) {
                        Image(systemName: card.icon)
                            .font(.system(size: 24))
                            .foregroundStyle(card.color)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(card.stationName)
                                .font(.custom("Cinzel-Bold", size: 18))
                                .foregroundStyle(RenaissanceColors.sepiaInk)
                            Text(card.italianName)
                                .font(.custom("EBGaramond-Italic", size: 13))
                                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.6))
                        }

                        Spacer()

                        // Discovery badge
                        Text("DISCOVERY")
                            .font(.custom("Cinzel-Bold", size: 9))
                            .tracking(1.5)
                            .foregroundStyle(RenaissanceColors.parchment)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(card.color.opacity(0.8), in: Capsule())
                    }

                    // Divider
                    Rectangle()
                        .fill(card.color.opacity(0.3))
                        .frame(height: 1)

                    if showContent {
                        // Story text with fade-in
                        Text(card.storyText)
                            .font(.custom("EBGaramond-Regular", size: 16))
                            .lineSpacing(6)
                            .foregroundStyle(RenaissanceColors.sepiaInk)
                            .opacity(animateStory ? 1 : 0)

                        // Fun fact callout
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "lightbulb.fill")
                                .foregroundStyle(RenaissanceColors.ochre)
                                .font(.system(size: 16))

                            Text(card.funFact)
                                .font(.custom("EBGaramond-Italic", size: 14))
                                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.8))
                                .lineSpacing(4)
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(card.color.opacity(0.08))
                        )
                        .opacity(animateStory ? 1 : 0)

                        // Building teaser
                        Text(card.buildingTeaser)
                            .font(.custom("EBGaramond-Regular", size: 13))
                            .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.6))
                            .multilineTextAlignment(.center)
                            .opacity(animateStory ? 1 : 0)

                        // Bird companion message
                        HStack(spacing: 10) {
                            Image("BirdFrame00")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)

                            Text("Interesting, \(playerName)! To collect this station's knowledge cards and earn florins, choose a building to work on first!")
                                .font(.custom("EBGaramond-Regular", size: 14))
                                .foregroundStyle(RenaissanceColors.sepiaInk)
                                .lineSpacing(4)
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(RenaissanceColors.ochre.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(RenaissanceColors.ochre.opacity(0.3), lineWidth: 1)
                                )
                        )
                        .opacity(animateStory ? 1 : 0)

                        // Buttons
                        HStack(spacing: 12) {
                            // Choose building button
                            Button {
                                onChooseBuilding()
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "building.columns.fill")
                                        .font(.system(size: 14))
                                    Text("Choose a Building")
                                        .font(.custom("Cinzel-Bold", size: 13))
                                }
                                .foregroundStyle(RenaissanceColors.parchment)
                                .padding(.horizontal, Spacing.md)
                                .padding(.vertical, Spacing.xs)
                                .background(card.color, in: RoundedRectangle(cornerRadius: CornerRadius.sm))
                            }

                            // Continue exploring button
                            Button {
                                onDismiss()
                            } label: {
                                Text("Keep Exploring")
                                    .font(.custom("EBGaramond-Regular", size: 14))
                                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))
                                    .padding(.horizontal, Spacing.sm)
                                    .padding(.vertical, Spacing.xs)
                                    .background(
                                        RoundedRectangle(cornerRadius: CornerRadius.sm)
                                            .strokeBorder(RenaissanceColors.sepiaInk.opacity(0.2), lineWidth: 1)
                                    )
                            }
                        }
                        .opacity(animateStory ? 1 : 0)
                    }
                }
                .padding(24)
            }
        }
        // Mirror content so it reads correctly after 3D flip
        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
    }
}
