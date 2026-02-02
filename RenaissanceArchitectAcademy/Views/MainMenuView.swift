import SwiftUI
import Vortex

/// Main Menu - Leonardo's Notebook aesthetic
/// Features aged parchment, decorative borders, and Renaissance typography
struct MainMenuView: View {
    var onStartGame: () -> Void
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var showContent = false

    // Adaptive sizing
    private var titleSize: CGFloat { horizontalSizeClass == .regular ? 72 : 56 }
    private var subtitleSize: CGFloat { horizontalSizeClass == .regular ? 44 : 36 }
    private var taglineSize: CGFloat { horizontalSizeClass == .regular ? 24 : 20 }

    var body: some View {
        ZStack {
            // Parchment background with subtle texture effect
            RenaissanceColors.parchmentGradient
                .ignoresSafeArea()

            // Floating dust motes particle effect
            VortexView(dustMotesSystem) {
                Circle()
                    .fill(RenaissanceColors.ochre.opacity(0.6))
                    .frame(width: 4, height: 4)
                    .tag("dust")
            }
            .ignoresSafeArea()

            // Ink splatters particle effect
            VortexView(inkSplatterSystem) {
                Circle()
                    .fill(RenaissanceColors.sepiaInk.opacity(0.15))
                    .frame(width: 24, height: 24)
                    .blur(radius: 2)
                    .tag("ink")
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

                // Title section with book-like framing
                VStack(spacing: 8) {
                    Text("Renaissance")
                        .font(.custom("Cinzel-Bold", size: titleSize, relativeTo: .largeTitle))
                        .foregroundStyle(RenaissanceColors.sepiaInk)

                    Text("Architect Academy")
                        .font(.custom("EBGaramond-Italic", size: subtitleSize, relativeTo: .title))
                        .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.8))
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)

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

                // Menu Buttons with wax seal accents
                VStack(spacing: horizontalSizeClass == .regular ? 20 : 16) {
                    RenaissanceButton(title: "Begin Journey", icon: "map.fill", action: onStartGame)
                        #if os(macOS)
                        .keyboardShortcut(.return, modifiers: [])
                        #endif

                    RenaissanceButton(title: "Continue", icon: "book.fill", action: {})
                        #if os(macOS)
                        .keyboardShortcut("c", modifiers: [.command])
                        #endif

                    RenaissanceButton(title: "Codex", icon: "scroll.fill", action: {})
                        #if os(macOS)
                        .keyboardShortcut("k", modifiers: [.command])
                        #endif
                }
                .padding(.bottom, horizontalSizeClass == .regular ? 80 : 60)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 30)
            }
            .padding(horizontalSizeClass == .regular ? 40 : 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                showContent = true
            }
        }
    }

    // MARK: - Particle Systems

    /// Floating golden dust motes - like sunlight through a window
    private var dustMotesSystem: VortexSystem {
        VortexSystem(
            tags: ["dust"],
            shape: .box(width: 1, height: 0),
            birthRate: 15,
            lifespan: 8,
            speed: 0.1,
            speedVariation: 0.05,
            angle: .degrees(270),
            angleRange: .degrees(30),
            size: 0.5,
            sizeVariation: 0.3
        )
    }

    /// Ink splatters drifting slowly - larger, softer blobs
    private var inkSplatterSystem: VortexSystem {
        VortexSystem(
            tags: ["ink"],
            shape: .box(width: 1, height: 0),
            birthRate: 2,
            lifespan: 15,
            speed: 0.02,
            speedVariation: 0.01,
            angle: .degrees(270),
            angleRange: .degrees(60),
            size: 1.0,
            sizeVariation: 0.5,
            sizeMultiplierAtDeath: 0.3
        )
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

#Preview("iPhone") {
    MainMenuView(onStartGame: {})
}

#Preview("iPad", traits: .landscapeLeft) {
    MainMenuView(onStartGame: {})
}

