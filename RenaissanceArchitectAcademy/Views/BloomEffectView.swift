import SwiftUI
import Vortex
import Pow

/// The "bloom" effect when a building transforms from gray sketch to full watercolor
struct BloomEffectView: View {
    let isActive: Bool
    var onComplete: (() -> Void)?

    @State private var showParticles = false
    @State private var bloomProgress: CGFloat = 0

    var body: some View {
        ZStack {
            if showParticles {
                // Magic sparkle particles during bloom
                VortexView(.magic) {
                    Circle()
                        .fill(RenaissanceColors.ochre)
                        .frame(width: 8, height: 8)
                        .blur(radius: 1)
                        .tag("sparkle")
                }
                .allowsHitTesting(false)
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
        withAnimation(.easeIn(duration: 0.3)) {
            showParticles = true
        }

        // Animate bloom progress
        withAnimation(.easeInOut(duration: 1.5)) {
            bloomProgress = 1.0
        }

        // Play sound
        Task { @MainActor in
            SoundManager.shared.play(.buildingComplete)
        }

        // Clean up after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            showParticles = false
            onComplete?()
        }
    }
}

// MARK: - Custom Vortex Presets for Renaissance Theme
extension VortexSystem {
    /// Magic sparkles for building completion - Renaissance gold and blue
    static let renaissanceMagic: VortexSystem = {
        var system = VortexSystem(tags: ["sparkle"])
        system.position = [0.5, 0.5]
        system.speed = 0.5
        system.speedVariation = 0.25
        system.lifespan = 1.5
        system.shape = .ellipse(radius: 0.4)
        system.angle = .degrees(0)
        system.angleRange = .degrees(360)
        system.size = 0.1
        system.sizeVariation = 0.05
        system.birthRate = 50
        return system
    }()

    /// Ink drops effect for sketch-to-color transition
    static let inkDrop: VortexSystem = {
        var system = VortexSystem(tags: ["ink"])
        system.position = [0.5, 0.5]
        system.speed = 0.1
        system.lifespan = 2.0
        system.shape = .ellipse(radius: 0.3)
        system.size = 0.15
        system.sizeVariation = 0.1
        system.birthRate = 20
        return system
    }()
}

// MARK: - Pow Transition Extensions
extension AnyTransition {
    /// Page curl transition for menu screens
    static var pageCurl: AnyTransition {
        .asymmetric(
            insertion: .movingParts.flip,
            removal: .movingParts.vanish
        )
    }

    /// Sketch to watercolor bloom transition
    static var bloom: AnyTransition {
        .asymmetric(
            insertion: .movingParts.glare,
            removal: .opacity
        )
    }

    /// Building construction reveal
    static var buildReveal: AnyTransition {
        .movingParts.iris(blurRadius: 20)
    }
}

// MARK: - View Modifier for Bloom Effect on Buildings
struct BuildingBloomModifier: ViewModifier {
    let isCompleted: Bool
    @State private var hasAnimated = false

    func body(content: Content) -> some View {
        content
            .saturation(isCompleted || hasAnimated ? 1.0 : 0.0)
            .overlay {
                if isCompleted && !hasAnimated {
                    BloomEffectView(isActive: true) {
                        hasAnimated = true
                    }
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
