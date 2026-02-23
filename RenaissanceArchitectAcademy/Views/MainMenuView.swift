import SwiftUI

/// Main Menu - Leonardo's Notebook aesthetic
/// Title on top, dome image centered, buttons in a horizontal row at the bottom
struct MainMenuView: View {
    var onStartGame: () -> Void
    var onContinue: () -> Void = {}
    var onOpenWorkshop: () -> Void = {}
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var showContent = false
    @State private var showButtons = false
    @State private var revealedZones: [Bool] = Array(repeating: false, count: 7)

    // Adaptive sizing
    private var titleSize: CGFloat { horizontalSizeClass == .regular ? 72 : 56 }
    private var subtitleSize: CGFloat { horizontalSizeClass == .regular ? 44 : 36 }
    private var taglineSize: CGFloat { horizontalSizeClass == .regular ? 24 : 20 }

    var body: some View {
        ZStack {
            // Parchment background
            RenaissanceColors.parchment
                .ignoresSafeArea()

            // Decorative corner flourishes
            DecorativeCorners()

            VStack(spacing: 0) {
                // MARK: - Title section at top
                VStack(spacing: 8) {
                    DividerOrnament()
                        .frame(width: 200)
                        .opacity(showContent ? 1 : 0)

                    AnimatedText(
                        text: "Renaissance",
                        font: .custom("Cinzel-Regular", size: titleSize, relativeTo: .largeTitle),
                        color: RenaissanceColors.sepiaInk,
                        isAnimating: showContent,
                        delayPerLetter: 0.1,
                        letterSpacing: 4
                    )

                    AnimatedText(
                        text: "Architect Academy",
                        font: .custom("Mulish-Light", size: subtitleSize, relativeTo: .title),
                        color: RenaissanceColors.sepiaInk,
                        isAnimating: showContent,
                        initialDelay: 1.2,
                        delayPerLetter: 0.07,
                        letterSpacing: 2
                    )

                    HStack(spacing: 12) {
                        Image(systemName: "leaf.fill")
                            .font(.caption)
                            .foregroundStyle(RenaissanceColors.sageGreen)

                        Text("Where Science Builds Civilization")
                            .font(.custom("Amellina", size: taglineSize + 6, relativeTo: .headline))
                            .foregroundStyle(Color.black)

                        Image(systemName: "leaf.fill")
                            .font(.caption)
                            .foregroundStyle(RenaissanceColors.sageGreen)
                            .scaleEffect(x: -1, y: 1)
                    }
                    .padding(.top, 8)
                    .opacity(showContent ? 1 : 0)

                    DividerOrnament()
                        .frame(width: 200)
                        .opacity(showContent ? 1 : 0)
                }
                .padding(.top, horizontalSizeClass == .regular ? 40 : 24)

                // MARK: - Dome image with dust-reveal effect
                Image("BackgroundMain")
                    .resizable()
                    .interpolation(.high)
                    .antialiased(true)
                    .scaledToFit()
                    .padding(.horizontal, horizontalSizeClass == .regular ? 80 : 20)
                    .frame(maxHeight: .infinity)
                    .offset(y: -50)
                    .mask {
                        GeometryReader { imgGeo in
                            // Dust-reveal zones positioned at dome elements
                            let zones: [(x: CGFloat, y: CGFloat, r: CGFloat)] = [
                                (0.50, 0.08, 0.20),  // Lantern/crown at top
                                (0.50, 0.30, 0.30),  // Main dome body
                                (0.25, 0.40, 0.25),  // Left side — blueprint lines
                                (0.75, 0.40, 0.25),  // Right side — watercolor splashes
                                (0.50, 0.70, 0.30),  // Arch entrance base
                                (0.30, 0.85, 0.25),  // Bottom-left columns
                                (0.50, 0.50, 0.65),  // Final sweep — fills everything
                            ]
                            ZStack {
                                ForEach(Array(zones.enumerated()), id: \.offset) { index, zone in
                                    RadialGradient(
                                        gradient: Gradient(colors: [
                                            .white,
                                            .white.opacity(0.85),
                                            .white.opacity(0.4),
                                            .clear
                                        ]),
                                        center: .center,
                                        startRadius: 0,
                                        endRadius: imgGeo.size.width * zone.r
                                    )
                                    .frame(
                                        width: imgGeo.size.width * zone.r * 2.5,
                                        height: imgGeo.size.width * zone.r * 2.5
                                    )
                                    .position(
                                        x: imgGeo.size.width * zone.x,
                                        y: imgGeo.size.height * zone.y
                                    )
                                    .scaleEffect(revealedZones[index] ? 1 : 0.01)
                                }
                            }
                            .frame(width: imgGeo.size.width, height: imgGeo.size.height)
                        }
                    }

                // MARK: - Buttons in horizontal row at bottom
                HStack(spacing: horizontalSizeClass == .regular ? 20 : 12) {
                    RenaissanceButton(title: "Begin Journey", action: onStartGame)
                        #if os(macOS)
                        .keyboardShortcut(.return, modifiers: [])
                        #endif

                    RenaissanceButton(title: "Continue", action: onContinue)
                        #if os(macOS)
                        .keyboardShortcut("c", modifiers: [.command])
                        #endif
                }
                .opacity(showButtons ? 1 : 0)
                .offset(y: showButtons ? 0 : 20)
                .padding(.bottom, horizontalSizeClass == .regular ? 40 : 24)
                .padding(.horizontal, 20)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                showContent = true
            }

            // Dust-reveal: dome elements appear one by one
            let revealDelays: [Double] = [0.5, 1.0, 1.5, 1.9, 2.3, 2.7, 3.2]
            for (index, delay) in revealDelays.enumerated() {
                withAnimation(.easeOut(duration: 1.4).delay(delay)) {
                    revealedZones[index] = true
                }
            }

            withAnimation(.easeOut(duration: 0.6).delay(2.5)) {
                showButtons = true
            }
        }
    }

}

/// Decorative divider with Renaissance ornament style
struct DividerOrnament: View {
    var body: some View {
        HStack(spacing: 8) {
            Rectangle()
                .fill(RenaissanceColors.ochre.opacity(0.5))
                .frame(height: 1)

            Image(systemName: "fleuron")
                .font(.caption)
                .foregroundStyle(RenaissanceColors.sepiaInk)

            Rectangle()
                .fill(RenaissanceColors.ochre.opacity(0.5))
                .frame(height: 1)
        }
    }
}

/// Decorative corner flourishes for parchment frame
struct DecorativeCorners: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Top-left
                CornerFlourish()
                    .position(x: 40, y: 40)

                // Top-right
                CornerFlourish()
                    .rotationEffect(.degrees(90))
                    .position(x: geometry.size.width - 40, y: 40)

                // Bottom-left
                CornerFlourish()
                    .rotationEffect(.degrees(-90))
                    .position(x: 40, y: geometry.size.height - 40)

                // Bottom-right
                CornerFlourish()
                    .rotationEffect(.degrees(180))
                    .position(x: geometry.size.width - 40, y: geometry.size.height - 40)
            }
        }
    }
}

struct CornerFlourish: View {
    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 30))
            path.addLine(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 30, y: 0))
        }
        .stroke(RenaissanceColors.ochre.opacity(0.4), lineWidth: 2)
    }
}

/// Animated text that reveals letter by letter - like a quill writing
struct AnimatedText: View {
    let text: String
    let font: Font
    let color: Color
    let isAnimating: Bool
    var initialDelay: Double = 0
    var delayPerLetter: Double = 0.05
    var letterSpacing: CGFloat = 0

    var body: some View {
        HStack(spacing: letterSpacing) {
            ForEach(Array(text.enumerated()), id: \.offset) { index, letter in
                Text(String(letter))
                    .font(font)
                    .foregroundStyle(color)
                    .opacity(isAnimating ? 1 : 0)
                    .offset(y: isAnimating ? 0 : 15)
                    .scaleEffect(isAnimating ? 1 : 0.8)
                    .animation(
                        .spring(response: 0.4, dampingFraction: 0.7)
                        .delay(initialDelay + Double(index) * delayPerLetter),
                        value: isAnimating
                    )
            }
        }
    }
}

#Preview("iPhone") {
    MainMenuView(onStartGame: {})
}

#Preview("iPad", traits: .landscapeLeft) {
    MainMenuView(onStartGame: {})
}

