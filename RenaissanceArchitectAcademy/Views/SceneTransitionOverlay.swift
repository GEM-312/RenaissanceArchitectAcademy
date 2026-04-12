import SwiftUI

/// Full-screen "ink wash" transition overlay for scene changes.
///
/// HOW IT WORKS:
/// 1. Caller sets `isActive = true` → concentric parchment circles expand from center
/// 2. At the midpoint (screen fully covered), `onMidpoint` fires — swap the scene there
/// 3. Circles contract, revealing the new scene underneath
///
/// The effect evokes ink spreading on parchment, fitting the Leonardo notebook aesthetic.
struct SceneTransitionOverlay: View {
    @Binding var isActive: Bool
    var onMidpoint: () -> Void
    var duration: Double = 0.8

    // Internal animation state
    @State private var phase: TransitionPhase = .idle
    @State private var coverProgress: CGFloat = 0  // 0 = invisible, 1 = fully covered
    @State private var particleProgress: CGFloat = 0
    @State private var particleOpacity: Double = 0

    private enum TransitionPhase {
        case idle, covering, covered, revealing
    }

    // 5 concentric circles, staggered
    private let circleCount = 5
    private let staggerDelay: Double = 0.04

    // 8 ink spatter particles
    private let particleCount = 8

    var body: some View {
        if phase != .idle {
            GeometryReader { geo in
                let maxDim = max(geo.size.width, geo.size.height) * 1.5

                ZStack {
                    // Concentric ink-wash circles
                    ForEach(0..<circleCount, id: \.self) { i in
                        Circle()
                            .fill(circleColor(index: i))
                            .frame(
                                width: maxDim * coverProgress,
                                height: maxDim * coverProgress
                            )
                            .opacity(circleOpacity(index: i))
                    }

                    // Ink spatter particles
                    ForEach(0..<particleCount, id: \.self) { i in
                        InkSpatterParticle(
                            index: i,
                            progress: particleProgress,
                            maxRadius: maxDim * 0.3
                        )
                        .opacity(particleOpacity)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .ignoresSafeArea()
            .allowsHitTesting(true) // Block interaction during transition
        }
    }

    // MARK: - Circle Styling

    private func circleColor(index: Int) -> Color {
        switch index {
        case 0: return RenaissanceColors.parchment
        case 1: return RenaissanceColors.parchment.opacity(0.95)
        case 2: return RenaissanceColors.ochre.opacity(0.08)
        case 3: return RenaissanceColors.parchment.opacity(0.9)
        default: return RenaissanceColors.parchment
        }
    }

    private func circleOpacity(index: Int) -> Double {
        // Stagger: inner circles appear slightly before outer ones
        let stagger = Double(index) * staggerDelay
        let adjusted = max(0, min(1, (Double(coverProgress) - stagger) / (1.0 - stagger * Double(circleCount))))
        return adjusted
    }

    // MARK: - Trigger

    /// Start the transition sequence. Called via onChange when isActive becomes true.
    private func startTransition() {
        guard phase == .idle else { return }

        let halfDuration = duration / 2.0

        // Phase 1: Cover
        phase = .covering
        withAnimation(.easeIn(duration: halfDuration)) {
            coverProgress = 1.0
        }
        withAnimation(.easeOut(duration: halfDuration * 0.8)) {
            particleProgress = 1.0
            particleOpacity = 0.7
        }

        // Phase 2: Midpoint — swap scene while covered
        DispatchQueue.main.asyncAfter(deadline: .now() + halfDuration) {
            phase = .covered
            onMidpoint()

            // Brief hold at midpoint for the scene swap to settle
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                // Phase 3: Reveal
                phase = .revealing
                withAnimation(.easeOut(duration: halfDuration)) {
                    coverProgress = 0
                }
                withAnimation(.easeOut(duration: halfDuration * 0.6)) {
                    particleOpacity = 0
                    particleProgress = 0
                }

                // Cleanup
                DispatchQueue.main.asyncAfter(deadline: .now() + halfDuration + 0.05) {
                    phase = .idle
                    coverProgress = 0
                    particleProgress = 0
                    particleOpacity = 0
                    isActive = false
                }
            }
        }
    }
}

// MARK: - onChange listener (extracted for clarity)

extension SceneTransitionOverlay {
    /// Attach this modifier so the overlay auto-triggers when isActive changes.
    func listenForActivation() -> some View {
        self.onChange(of: isActive) { _, newValue in
            if newValue && phase == .idle {
                startTransition()
            }
        }
    }
}

/// Individual ink spatter dot that flies outward during the cover phase
private struct InkSpatterParticle: View {
    let index: Int
    let progress: CGFloat
    let maxRadius: CGFloat

    private var angle: Angle {
        // Distribute unevenly for organic feel
        .degrees(Double(index) * 45 + Double(index * index) * 7)
    }

    private var distance: CGFloat {
        progress * maxRadius * CGFloat(0.4 + 0.6 * Double((index % 3)) / 2.0)
    }

    private var size: CGFloat {
        let base: CGFloat = CGFloat(4 + (index % 3) * 3)
        return base * (1.0 - progress * 0.5)
    }

    var body: some View {
        Ellipse()
            .fill(index % 2 == 0 ? RenaissanceColors.ochre.opacity(0.3) : RenaissanceColors.sepiaInk.opacity(0.15))
            .frame(width: size, height: size * 0.7)
            .rotationEffect(.degrees(Double(index) * 23))
            .offset(
                x: cos(angle.radians) * distance,
                y: sin(angle.radians) * distance
            )
            .blur(radius: progress * 1.5)
    }
}

// MARK: - View Modifier for easy attachment

/// Wraps any view with the scene transition overlay.
/// Usage: `.sceneTransition(isActive: $isTransitioning, onMidpoint: { swapScene() })`
struct SceneTransitionModifier: ViewModifier {
    @Binding var isActive: Bool
    var onMidpoint: () -> Void
    var duration: Double = 0.8

    func body(content: Content) -> some View {
        content.overlay {
            SceneTransitionOverlay(
                isActive: $isActive,
                onMidpoint: onMidpoint,
                duration: duration
            )
            .listenForActivation()
        }
    }
}

extension View {
    /// Apply the ink-wash scene transition overlay.
    func sceneTransition(isActive: Binding<Bool>, duration: Double = 0.8, onMidpoint: @escaping () -> Void) -> some View {
        modifier(SceneTransitionModifier(isActive: isActive, onMidpoint: onMidpoint, duration: duration))
    }
}

// MARK: - Preview

#Preview("Scene Transition") {
    struct TransitionDemo: View {
        @State private var isActive = false
        @State private var colorIndex = 0
        private let colors: [Color] = [.blue.opacity(0.3), .green.opacity(0.3), .orange.opacity(0.3)]

        var body: some View {
            ZStack {
                colors[colorIndex]
                    .ignoresSafeArea()

                Button("Trigger Transition") {
                    isActive = true
                }
                .font(.title2)
            }
            .sceneTransition(isActive: $isActive) {
                colorIndex = (colorIndex + 1) % colors.count
            }
        }
    }

    return TransitionDemo()
}
