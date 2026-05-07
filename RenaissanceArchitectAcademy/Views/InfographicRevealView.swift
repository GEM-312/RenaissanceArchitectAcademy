import SwiftUI

/// Compact infographic reward with dust-reveal effect.
/// Designed to render INSIDE a knowledge card (not fullscreen).
/// Zones auto-reveal one by one using the same RadialGradient mask as MainMenuView.
struct InfographicRevealView: View {
    let infographic: InfographicReveal
    let onDismiss: () -> Void

    @State private var revealedZones: [Bool]
    @State private var allRevealed = false

    init(infographic: InfographicReveal, onDismiss: @escaping () -> Void) {
        self.infographic = infographic
        self.onDismiss = onDismiss
        self._revealedZones = State(initialValue: Array(repeating: false, count: infographic.zones.count))
    }

    var body: some View {
        VStack(spacing: 12) {
            // Infographic with dust-reveal mask
            Image(infographic.imageName)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(RenaissanceColors.ochre.opacity(0.4), lineWidth: 1)
                )
                .mask {
                    GeometryReader { geo in
                        ZStack {
                            // Faint base
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

            // Done button
            if allRevealed {
                Button {
                    onDismiss()
                } label: {
                    Text("Continue")
                        .font(RenaissanceFont.footnoteBold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(RenaissanceColors.sageGreen)
                        )
                }
                .buttonStyle(.plain)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .onAppear {
            startRevealSequence()
        }
    }

    private func startRevealSequence() {
        for (index, _) in infographic.zones.enumerated() {
            let delay = 0.3 + Double(index) * 0.5
            withAnimation(.easeOut(duration: 1.0).delay(delay)) {
                revealedZones[index] = true
            }
        }
        let totalDuration = 0.3 + Double(infographic.zones.count) * 0.5 + 0.8
        withAnimation(.easeOut(duration: 0.3).delay(totalDuration)) {
            allRevealed = true
        }
    }
}
