import SwiftUI

/// Dust Reveal Transition — uses the same radial gradient mask technique
/// as the MainMenuView dome reveal, but in reverse-then-forward:
///
/// 1. Parchment dust zones expand to COVER the current scene
/// 2. Scene swaps while fully covered
/// 3. Dust zones shrink to REVEAL the new scene
struct SceneTransitionOverlay: View {
    @Binding var isActive: Bool
    var duration: Double = 0.8
    var onMidpoint: () -> Void

    @State private var phase: TransitionPhase = .idle
    @State private var coverZones: [Bool] = Array(repeating: false, count: 7)
    @State private var revealZones: [Bool] = Array(repeating: true, count: 7)

    private enum TransitionPhase {
        case idle, covering, covered, revealing
    }

    /// Zone positions — spread across the screen for organic coverage
    private let zones: [(x: CGFloat, y: CGFloat, r: CGFloat)] = [
        (0.50, 0.50, 0.45),  // Center — largest, anchors the transition
        (0.20, 0.25, 0.30),  // Top-left
        (0.80, 0.25, 0.30),  // Top-right
        (0.20, 0.75, 0.30),  // Bottom-left
        (0.80, 0.75, 0.30),  // Bottom-right
        (0.50, 0.15, 0.25),  // Top-center
        (0.50, 0.85, 0.25),  // Bottom-center
    ]

    var body: some View {
        GeometryReader { geo in
            if phase != .idle {
                // Parchment layer masked by expanding/contracting radial zones
                RenaissanceColors.parchment
                    .mask {
                        ZStack {
                            if phase == .covering || phase == .covered {
                                dustMask(geo: geo, expanded: coverZones)
                            } else {
                                dustMask(geo: geo, expanded: revealZones)
                            }
                        }
                        .frame(width: geo.size.width, height: geo.size.height)
                    }
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(phase != .idle)
        .onChange(of: isActive) { _, active in
            if active && phase == .idle {
                startTransition()
            }
        }
    }

    /// Radial gradient mask — same pattern as MainMenuView dome reveal
    private func dustMask(geo: GeometryProxy, expanded: [Bool]) -> some View {
        let maxDim = max(geo.size.width, geo.size.height)
        return ZStack {
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
                    endRadius: maxDim * zone.r
                )
                .frame(
                    width: maxDim * zone.r * 2.5,
                    height: maxDim * zone.r * 2.5
                )
                .position(
                    x: geo.size.width * zone.x,
                    y: geo.size.height * zone.y
                )
                .scaleEffect(expanded[index] ? 1 : 0.01)
            }
        }
    }

    // MARK: - Animation Sequence

    private func startTransition() {
        phase = .covering
        let coverTime = duration * 0.4
        let revealTime = duration * 0.6

        // Stagger zone expansion to cover screen (fast, organic)
        let coverDelays: [Double] = [0.0, 0.03, 0.03, 0.06, 0.06, 0.08, 0.08]
        for (index, delay) in coverDelays.enumerated() {
            withAnimation(.easeIn(duration: coverTime - delay).delay(delay)) {
                coverZones[index] = true
            }
        }

        // Midpoint: swap scene
        DispatchQueue.main.asyncAfter(deadline: .now() + coverTime + 0.05) {
            phase = .covered
            onMidpoint()

            // Start reveal: shrink zones to expose new scene
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                phase = .revealing
                let revealDelays: [Double] = [0.0, 0.04, 0.04, 0.08, 0.08, 0.10, 0.12]
                for (index, delay) in revealDelays.enumerated() {
                    withAnimation(.easeOut(duration: revealTime - delay).delay(delay)) {
                        revealZones[index] = false
                    }
                }

                // Reset after reveal completes
                DispatchQueue.main.asyncAfter(deadline: .now() + revealTime + 0.1) {
                    resetState()
                }
            }
        }
    }

    private func resetState() {
        phase = .idle
        coverZones = Array(repeating: false, count: 7)
        revealZones = Array(repeating: true, count: 7)
        isActive = false
    }
}
