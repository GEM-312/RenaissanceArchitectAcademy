import SwiftUI

/// Cinematic infographic reward view with dust-reveal effect.
/// Shown after completing a knowledge card's activity.
/// Zones auto-reveal one by one, same RadialGradient mask as MainMenuView.
struct InfographicRevealView: View {
    let infographic: InfographicReveal
    let onDismiss: () -> Void

    @State private var revealedZones: [Bool]
    @State private var allRevealed = false

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    private var isLargeScreen: Bool { horizontalSizeClass == .regular }

    init(infographic: InfographicReveal, onDismiss: @escaping () -> Void) {
        self.infographic = infographic
        self.onDismiss = onDismiss
        self._revealedZones = State(initialValue: Array(repeating: false, count: infographic.zones.count))
    }

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            // Infographic with dust-reveal mask
            Image(infographic.imageName)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(RenaissanceColors.ochre.opacity(0.5), lineWidth: 1.5)
                )
                .mask {
                    GeometryReader { geo in
                        ZStack {
                            // Faint base so image isn't fully invisible
                            Color.white.opacity(0.05)

                            ForEach(Array(infographic.zones.enumerated()), id: \.offset) { index, zone in
                                RadialGradient(
                                    gradient: Gradient(colors: [
                                        .white,
                                        .white.opacity(0.9),
                                        .white.opacity(0.45),
                                        .clear
                                    ]),
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: geo.size.width * zone.radius
                                )
                                .frame(
                                    width: geo.size.width * zone.radius * 2.5,
                                    height: geo.size.width * zone.radius * 2.5
                                )
                                .position(
                                    x: geo.size.width * zone.x,
                                    y: geo.size.height * zone.y
                                )
                                .scaleEffect(revealedZones[index] ? 1 : 0.01)
                            }
                        }
                        .frame(width: geo.size.width, height: geo.size.height)
                    }
                }
                .padding(.horizontal, isLargeScreen ? 40 : 16)

            // Done button (appears after all zones revealed)
            if allRevealed {
                Button {
                    onDismiss()
                } label: {
                    Text("Continue")
                        .font(.custom("Cinzel-Bold", size: 16))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(RenaissanceColors.sageGreen)
                        )
                }
                .buttonStyle(.plain)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(RenaissanceColors.parchmentGradient.ignoresSafeArea())
        .onAppear {
            startRevealSequence()
        }
    }

    /// Auto-reveal zones one by one with staggered delays
    private func startRevealSequence() {
        for (index, _) in infographic.zones.enumerated() {
            let delay = 0.4 + Double(index) * 0.6
            withAnimation(.easeOut(duration: 1.2).delay(delay)) {
                revealedZones[index] = true
            }
        }
        // Show done button after all zones revealed
        let totalDuration = 0.4 + Double(infographic.zones.count) * 0.6 + 1.0
        withAnimation(.easeOut(duration: 0.4).delay(totalDuration)) {
            allRevealed = true
        }
    }
}
