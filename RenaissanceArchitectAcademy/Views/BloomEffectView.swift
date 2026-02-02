import SwiftUI

/// The "bloom" effect when a building transforms from gray sketch to full watercolor
/// Uses native SwiftUI animations - can be enhanced with Vortex/Pow packages later
struct BloomEffectView: View {
    let isActive: Bool
    var onComplete: (() -> Void)?

    @State private var showParticles = false
    @State private var bloomProgress: CGFloat = 0
    @State private var particleOpacity: Double = 0

    var body: some View {
        ZStack {
            // Sparkle particles (native SwiftUI version)
            if showParticles {
                ForEach(0..<12, id: \.self) { index in
                    SparkleParticle(
                        index: index,
                        progress: bloomProgress
                    )
                }
            }

            // Central glow
            if showParticles {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                RenaissanceColors.ochre.opacity(0.6),
                                RenaissanceColors.ochre.opacity(0)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 100 * bloomProgress
                        )
                    )
                    .frame(width: 200, height: 200)
                    .opacity(particleOpacity)
            }
        }
        .onChange(of: isActive) { _, newValue in
            if newValue {
                triggerBloom()
            }
        }
    }

    private func triggerBloom() {
        // Start particles
        withAnimation(.easeIn(duration: 0.2)) {
            showParticles = true
            particleOpacity = 1.0
        }

        // Animate bloom progress
        withAnimation(.easeInOut(duration: 1.5)) {
            bloomProgress = 1.0
        }

        // Play sound
        Task { @MainActor in
            SoundManager.shared.play(.buildingComplete)
        }

        // Fade out particles
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.easeOut(duration: 0.5)) {
                particleOpacity = 0
            }
        }

        // Clean up after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            showParticles = false
            bloomProgress = 0
            onComplete?()
        }
    }
}

/// Individual sparkle particle for the bloom effect
struct SparkleParticle: View {
    let index: Int
    let progress: CGFloat

    private var angle: Angle {
        .degrees(Double(index) * 30)
    }

    private var distance: CGFloat {
        progress * 80
    }

    var body: some View {
        Circle()
            .fill(index % 2 == 0 ? RenaissanceColors.ochre : RenaissanceColors.renaissanceBlue)
            .frame(width: 8 - progress * 4, height: 8 - progress * 4)
            .offset(
                x: cos(angle.radians) * distance,
                y: sin(angle.radians) * distance
            )
            .opacity(1 - progress * 0.8)
            .blur(radius: progress * 2)
    }
}

// MARK: - Native SwiftUI Transitions (no external dependencies)
extension AnyTransition {
    /// Fade with scale transition
    static var bloom: AnyTransition {
        .asymmetric(
            insertion: .scale(scale: 0.8).combined(with: .opacity),
            removal: .scale(scale: 1.1).combined(with: .opacity)
        )
    }

    /// Slide up with fade
    static var buildReveal: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal: .opacity
        )
    }

    /// Page flip simulation
    static var pageCurl: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        )
    }
}

// MARK: - View Modifier for Bloom Effect on Buildings
struct BuildingBloomModifier: ViewModifier {
    let isCompleted: Bool
    @State private var hasAnimated = false
    @State private var showBloom = false

    func body(content: Content) -> some View {
        content
            .saturation(isCompleted || hasAnimated ? 1.0 : 0.0)
            .overlay {
                if showBloom {
                    BloomEffectView(isActive: true) {
                        hasAnimated = true
                        showBloom = false
                    }
                }
            }
            .onChange(of: isCompleted) { _, newValue in
                if newValue && !hasAnimated {
                    showBloom = true
                }
            }
            .animation(.easeInOut(duration: 1.0), value: isCompleted)
    }
}

extension View {
    /// Apply bloom effect when building is completed
    func bloomOnComplete(_ isCompleted: Bool) -> some View {
        modifier(BuildingBloomModifier(isCompleted: isCompleted))
    }
}

#Preview {
    VStack {
        BloomEffectView(isActive: true)
            .frame(width: 200, height: 200)
            .background(RenaissanceColors.parchment)
    }
}
