import SwiftUI

/// Main Menu - Leonardo's Notebook aesthetic
/// Features aged parchment, decorative borders, and Renaissance typography
struct MainMenuView: View {
    var onStartGame: () -> Void
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var showContent = false
    @State private var showButton1 = false
    @State private var showButton2 = false
    @State private var showButton3 = false

    // Adaptive sizing
    private var titleSize: CGFloat { horizontalSizeClass == .regular ? 72 : 56 }
    private var subtitleSize: CGFloat { horizontalSizeClass == .regular ? 44 : 36 }
    private var taglineSize: CGFloat { horizontalSizeClass == .regular ? 24 : 20 }

    var body: some View {
        ZStack {
            // Parchment background
            RenaissanceColors.parchment
                .ignoresSafeArea()

            // Renaissance dome background image
            GeometryReader { geo in
                Image("BackgroundMain")
                    .resizable()
                    .interpolation(.high)
                    .antialiased(true)
                    .scaledToFit()
                    .frame(height: min(geo.size.height, 900))
                    .scaleEffect(x: -1, y: 1)
                    .position(x: geo.size.height * 0.1, y: geo.size.height / 1.5)
                    .opacity(0.9)
            }
            .ignoresSafeArea()


            // Decorative corner flourishes
            DecorativeCorners()

            VStack(spacing: horizontalSizeClass == .regular ? 32 : 24) {
                Spacer()

                // Decorative top border
                DividerOrnament()
                    .frame(width: 200)
                    .opacity(showContent ? 1 : 0)

                // Title section with quill-writing animation
                VStack(spacing: 8) {
                    AnimatedText(
                        text: "Renaissance",
                        font: .custom("Cinzel-Bold", size: titleSize, relativeTo: .largeTitle),
                        color: RenaissanceColors.sepiaInk,
                        isAnimating: showContent,
                        delayPerLetter: 0.1
                    )

                    AnimatedText(
                        text: "Architect Academy",
                        font: .custom("EBGaramond-Italic", size: subtitleSize, relativeTo: .title),
                        color: RenaissanceColors.sepiaInk.opacity(0.8),
                        isAnimating: showContent,
                        initialDelay: 1.2,
                        delayPerLetter: 0.07
                    )
                }

                // Tagline with quill-written style
                HStack(spacing: 12) {
                    Image(systemName: "leaf.fill")
                        .font(.caption)
                        .foregroundStyle(RenaissanceColors.sageGreen)

                    Text("Where Science Builds Civilization")
                        .font(.custom("PetitFormalScript-Regular", size: taglineSize, relativeTo: .headline))
                        .foregroundStyle(RenaissanceColors.renaissanceBlue)

                    Image(systemName: "leaf.fill")
                        .font(.caption)
                        .foregroundStyle(RenaissanceColors.sageGreen)
                        .scaleEffect(x: -1, y: 1)
                }
                .padding(.top, 8)
                .opacity(showContent ? 1 : 0)

                // Decorative bottom border
                DividerOrnament()
                    .frame(width: 200)
                    .opacity(showContent ? 1 : 0)

                Spacer()

                // Menu Buttons - appear one by one
                VStack(spacing: horizontalSizeClass == .regular ? 20 : 16) {
                    RenaissanceButton(title: "Begin Journey", action: onStartGame)
                        .opacity(showButton1 ? 1 : 0)
                        .offset(y: showButton1 ? 0 : 20)
                        #if os(macOS)
                        .keyboardShortcut(.return, modifiers: [])
                        #endif

                    RenaissanceButton(title: "Continue", action: {})
                        .opacity(showButton2 ? 1 : 0)
                        .offset(y: showButton2 ? 0 : 20)
                        #if os(macOS)
                        .keyboardShortcut("c", modifiers: [.command])
                        #endif

                    RenaissanceButton(title: "Codex", action: {})
                        .opacity(showButton3 ? 1 : 0)
                        .offset(y: showButton3 ? 0 : 20)
                        #if os(macOS)
                        .keyboardShortcut("k", modifiers: [.command])
                        #endif
                }
                .padding(.bottom, horizontalSizeClass == .regular ? 80 : 60)
            }
            .padding(horizontalSizeClass == .regular ? 40 : 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                showContent = true
            }
            // Buttons appear one by one after title animation
            withAnimation(.easeOut(duration: 0.5).delay(2.5)) {
                showButton1 = true
            }
            withAnimation(.easeOut(duration: 0.5).delay(2.8)) {
                showButton2 = true
            }
            withAnimation(.easeOut(duration: 0.5).delay(3.1)) {
                showButton3 = true
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
                .foregroundStyle(RenaissanceColors.ochre)

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

    var body: some View {
        HStack(spacing: 0) {
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

