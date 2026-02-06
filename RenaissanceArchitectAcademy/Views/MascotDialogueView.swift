import SwiftUI

/// Player's choice when starting a building
enum BuildingStartChoice: String, CaseIterable {
    case needMaterials = "I need materials"
    case dontKnow = "I don't know"
    case needToSketch = "I need to sketch it"

    var icon: String {
        switch self {
        case .needMaterials: return "cube.box"
        case .dontKnow: return "questionmark.circle"
        case .needToSketch: return "pencil.and.outline"
        }
    }
}

/// Mascot dialogue view with Splash (watercolor) and Bird companion
/// Appears when user taps a building to start
struct MascotDialogueView: View {
    let buildingName: String
    let onChoice: (BuildingStartChoice) -> Void
    let onDismiss: () -> Void

    @State private var showMascot = false
    @State private var showDialogue = false
    @State private var showChoices = false
    @State private var birdOffset: CGFloat = 0

    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            VStack(spacing: 24) {
                Spacer()

                // Mascot characters
                HStack(alignment: .bottom, spacing: -20) {
                    // Splash - watercolor ink character
                    SplashCharacter()
                        .frame(width: 150, height: 180)
                        .scaleEffect(showMascot ? 1 : 0.5)
                        .opacity(showMascot ? 1 : 0)

                    // Bird companion
                    BirdCharacter()
                        .frame(width: 60, height: 60)
                        .offset(y: birdOffset)
                        .scaleEffect(showMascot ? 1 : 0.3)
                        .opacity(showMascot ? 1 : 0)
                }
                .padding(.bottom, -20)

                // Dialogue bubble
                VStack(spacing: 20) {
                    // Dialogue text
                    VStack(spacing: 12) {
                        Text("Great choice!")
                            .font(.custom("Cinzel-Bold", size: 24))
                            .foregroundColor(RenaissanceColors.sepiaInk)

                        Text("Do you know what you need to build the \(buildingName)?")
                            .font(.custom("EBGaramond-Regular", size: 18))
                            .foregroundColor(RenaissanceColors.sepiaInk.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    .opacity(showDialogue ? 1 : 0)
                    .offset(y: showDialogue ? 0 : 20)

                    // Choice buttons
                    VStack(spacing: 12) {
                        ForEach(BuildingStartChoice.allCases, id: \.self) { choice in
                            ChoiceButton(choice: choice) {
                                withAnimation(.spring()) {
                                    onChoice(choice)
                                }
                            }
                            .opacity(showChoices ? 1 : 0)
                            .offset(x: showChoices ? 0 : -50)
                            .animation(
                                .spring(response: 0.5, dampingFraction: 0.7)
                                .delay(Double(BuildingStartChoice.allCases.firstIndex(of: choice)!) * 0.1),
                                value: showChoices
                            )
                        }
                    }
                    .padding(.top, 8)
                }
                .padding(28)
                .background(
                    DialogueBubble()
                )
                .padding(.horizontal, 40)

                Spacer()
            }
        }
        .onAppear {
            // Animate entrance
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                showMascot = true
            }

            withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
                showDialogue = true
            }

            withAnimation(.spring(response: 0.5).delay(0.6)) {
                showChoices = true
            }

            // Bird bobbing animation
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                birdOffset = -10
            }
        }
    }
}

/// Splash - the main watercolor ink mascot
struct SplashCharacter: View {
    @State private var wiggle = false

    var body: some View {
        ZStack {
            // Body - watercolor splash shape
            WatercolorSplash()
                .fill(
                    LinearGradient(
                        colors: [
                            RenaissanceColors.ochre,
                            RenaissanceColors.warmBrown,
                            RenaissanceColors.terracotta.opacity(0.8)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 120, height: 140)
                .rotationEffect(.degrees(wiggle ? 2 : -2))

            // Face
            VStack(spacing: 8) {
                // Eyes
                HStack(spacing: 24) {
                    Eye()
                    Eye()
                }

                // Friendly smile
                Smile()
                    .stroke(RenaissanceColors.sepiaInk, lineWidth: 3)
                    .frame(width: 30, height: 15)
            }
            .offset(y: -10)

            // Ink drips at bottom
            HStack(spacing: 15) {
                InkDrip(height: 20)
                InkDrip(height: 35)
                InkDrip(height: 25)
            }
            .offset(y: 60)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                wiggle = true
            }
        }
    }
}

/// Bird companion character
struct BirdCharacter: View {
    @State private var wingFlap = false

    var body: some View {
        ZStack {
            // Body
            Ellipse()
                .fill(RenaissanceColors.renaissanceBlue)
                .frame(width: 40, height: 35)

            // Wing
            Ellipse()
                .fill(RenaissanceColors.deepTeal)
                .frame(width: 25, height: 15)
                .rotationEffect(.degrees(wingFlap ? -20 : 20))
                .offset(x: -8, y: -5)

            // Head
            Circle()
                .fill(RenaissanceColors.renaissanceBlue)
                .frame(width: 25, height: 25)
                .offset(x: 10, y: -15)

            // Eye
            Circle()
                .fill(RenaissanceColors.sepiaInk)
                .frame(width: 6, height: 6)
                .offset(x: 15, y: -18)

            // Beak
            Triangle()
                .fill(RenaissanceColors.ochre)
                .frame(width: 12, height: 8)
                .rotationEffect(.degrees(90))
                .offset(x: 25, y: -15)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.3).repeatForever(autoreverses: true)) {
                wingFlap = true
            }
        }
    }
}

/// Choice button for dialogue
struct ChoiceButton: View {
    let choice: BuildingStartChoice
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: choice.icon)
                    .font(.title3)
                    .foregroundColor(RenaissanceColors.warmBrown)

                Text(choice.rawValue)
                    .font(.custom("EBGaramond-Regular", size: 17))
                    .foregroundColor(RenaissanceColors.sepiaInk)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(RenaissanceColors.stoneGray)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(RenaissanceColors.parchment)
                    .shadow(color: RenaissanceColors.warmBrown.opacity(0.2), radius: 4, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(RenaissanceColors.ochre.opacity(0.5), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.97 : 1)
        .animation(.spring(response: 0.2), value: isPressed)
    }
}

// MARK: - Shape Components

struct WatercolorSplash: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height

        // Organic blob shape
        path.move(to: CGPoint(x: w * 0.5, y: 0))
        path.addCurve(
            to: CGPoint(x: w, y: h * 0.4),
            control1: CGPoint(x: w * 0.8, y: 0),
            control2: CGPoint(x: w, y: h * 0.2)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.7, y: h),
            control1: CGPoint(x: w, y: h * 0.7),
            control2: CGPoint(x: w * 0.9, y: h)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.3, y: h),
            control1: CGPoint(x: w * 0.5, y: h),
            control2: CGPoint(x: w * 0.4, y: h)
        )
        path.addCurve(
            to: CGPoint(x: 0, y: h * 0.4),
            control1: CGPoint(x: w * 0.1, y: h),
            control2: CGPoint(x: 0, y: h * 0.7)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.5, y: 0),
            control1: CGPoint(x: 0, y: h * 0.2),
            control2: CGPoint(x: w * 0.2, y: 0)
        )

        return path
    }
}

struct Eye: View {
    @State private var blink = false

    var body: some View {
        ZStack {
            // White
            Ellipse()
                .fill(.white)
                .frame(width: 20, height: blink ? 3 : 18)

            // Pupil
            Circle()
                .fill(RenaissanceColors.sepiaInk)
                .frame(width: 10, height: 10)
                .offset(y: 2)
                .opacity(blink ? 0 : 1)
        }
        .onAppear {
            // Random blinking
            Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
                withAnimation(.easeInOut(duration: 0.15)) {
                    blink = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        blink = false
                    }
                }
            }
        }
    }
}

struct Smile: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addQuadCurve(
            to: CGPoint(x: rect.width, y: 0),
            control: CGPoint(x: rect.width / 2, y: rect.height)
        )
        return path
    }
}

struct InkDrip: View {
    let height: CGFloat
    @State private var drip = false

    var body: some View {
        Capsule()
            .fill(RenaissanceColors.warmBrown.opacity(0.7))
            .frame(width: 8, height: height)
            .offset(y: drip ? 5 : 0)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true).delay(Double.random(in: 0...0.5))) {
                    drip = true
                }
            }
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct DialogueBubble: View {
    var body: some View {
        ZStack {
            // Main bubble
            RoundedRectangle(cornerRadius: 20)
                .fill(RenaissanceColors.parchment)
                .shadow(color: .black.opacity(0.2), radius: 20, y: 10)

            // Border
            RoundedRectangle(cornerRadius: 20)
                .stroke(RenaissanceColors.ochre.opacity(0.5), lineWidth: 2)

            // Decorative corner flourishes
            VStack {
                HStack {
                    DialogueCornerFlourish()
                    Spacer()
                    DialogueCornerFlourish()
                        .scaleEffect(x: -1)
                }
                Spacer()
                HStack {
                    DialogueCornerFlourish()
                        .scaleEffect(y: -1)
                    Spacer()
                    DialogueCornerFlourish()
                        .scaleEffect(x: -1, y: -1)
                }
            }
            .padding(8)
        }
    }
}

struct DialogueCornerFlourish: View {
    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 20))
            path.addQuadCurve(
                to: CGPoint(x: 20, y: 0),
                control: CGPoint(x: 0, y: 0)
            )
        }
        .stroke(RenaissanceColors.ochre.opacity(0.4), lineWidth: 2)
        .frame(width: 20, height: 20)
    }
}

// MARK: - Preview

#Preview {
    MascotDialogueView(
        buildingName: "Pantheon",
        onChoice: { choice in
            print("Chose: \(choice.rawValue)")
        },
        onDismiss: {}
    )
}
