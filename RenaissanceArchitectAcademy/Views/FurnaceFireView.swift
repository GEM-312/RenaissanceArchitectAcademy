import SwiftUI

/// Animated fire effect using MeshGradient — warm blobs that morph organically.
/// Place directly over the furnace in the crafting room scene.
///
/// Uses techniques from WWDC 2024 "Create Custom Visual Effects in SwiftUI":
/// MeshGradient with animated control points creating visible, dramatic blob movement.
struct FurnaceFireView: View {
    var width: CGFloat = 200
    var height: CGFloat = 200

    var body: some View {
        if #available(iOS 18.0, macOS 15.0, *) {
            TimelineView(.animation) { context in
                let t = context.date.timeIntervalSinceReferenceDate

                MeshGradient(
                    width: 4,
                    height: 4,
                    points: firePoints(t),
                    colors: fireColors(t),
                    smoothsColors: true
                )
                .frame(width: width, height: height)
                .blur(radius: 8)
                .blendMode(.screen)
            }
        } else {
            // iOS 17 fallback — simple radial glow
            RadialGradient(
                colors: [
                    Color.orange.opacity(0.5),
                    Color.red.opacity(0.3),
                    Color.clear
                ],
                center: .center,
                startRadius: 5,
                endRadius: width * 0.4
            )
            .frame(width: width, height: height)
            .blur(radius: 10)
            .blendMode(.screen)
        }
    }

    // MARK: - 4x4 Grid Points — dramatic blob movement

    private func firePoints(_ t: Double) -> [SIMD2<Float>] {
        [
            // Row 0 — top (flame tips, wild movement)
            s(0.0,  0.0),
            s(0.33 + d(t, 1.7, 2.9, 0.12), 0.0  + d(t, 2.3, 1.1, 0.08)),
            s(0.67 + d(t, 2.1, 1.5, 0.12), 0.0  + d(t, 1.3, 2.7, 0.08)),
            s(1.0,  0.0),

            // Row 1 — upper body (large organic drift)
            s(0.0  + d(t, 1.3, 2.1, 0.08), 0.33 + d(t, 1.9, 2.5, 0.10)),
            s(0.33 + d(t, 2.7, 1.3, 0.20), 0.33 + d(t, 1.1, 3.1, 0.18)),
            s(0.67 + d(t, 1.5, 2.8, 0.20), 0.33 + d(t, 2.9, 1.4, 0.18)),
            s(1.0  + d(t, 2.3, 1.7, 0.08), 0.33 + d(t, 1.6, 2.2, 0.10)),

            // Row 2 — lower body (moderate drift)
            s(0.0  + d(t, 1.1, 1.9, 0.05), 0.67 + d(t, 2.1, 1.5, 0.06)),
            s(0.33 + d(t, 2.3, 1.7, 0.15), 0.67 + d(t, 1.3, 2.9, 0.12)),
            s(0.67 + d(t, 1.9, 2.3, 0.15), 0.67 + d(t, 2.7, 1.1, 0.12)),
            s(1.0  + d(t, 2.1, 1.3, 0.05), 0.67 + d(t, 1.8, 2.4, 0.06)),

            // Row 3 — bottom (ember base, mostly anchored)
            s(0.0,  1.0),
            s(0.33 + d(t, 1.4, 2.0, 0.04), 1.0),
            s(0.67 + d(t, 1.8, 2.6, 0.04), 1.0),
            s(1.0,  1.0),
        ]
    }

    /// Clamped SIMD2 point
    private func s(_ x: Float, _ y: Float) -> SIMD2<Float> {
        SIMD2(min(1, max(0, x)), min(1, max(0, y)))
    }

    /// Layered sine drift — irrational frequency ratios prevent visible looping
    private func d(_ t: Double, _ f1: Double, _ f2: Double, _ amp: Float) -> Float {
        Float(sin(t * f1) * 0.6 + sin(t * f2 + 0.7) * 0.4) * amp
    }

    // MARK: - 4x4 Colors — high contrast fire blobs

    private func fireColors(_ t: Double) -> [Color] {
        let p1 = (sin(t * 1.3) + 1) / 2
        let p2 = (sin(t * 0.9 + 1.0) + 1) / 2
        let p3 = (sin(t * 1.7 + 2.0) + 1) / 2

        return [
            // Row 0 — top: ALL clear edges, only center glows
            .clear,
            .clear,
            .clear,
            .clear,

            // Row 1 — clear edges, bright blobs in center
            .clear,
            Color(red: 1, green: 0.7 + p1 * 0.3, blue: 0.1 + p1 * 0.2),   // bright blob
            Color(red: 1, green: 0.6 + p3 * 0.3, blue: 0.05 + p3 * 0.15), // bright blob
            .clear,

            // Row 2 — clear edges, warm glow in center
            .clear,
            Color(red: 0.95, green: 0.35 + p2 * 0.2, blue: 0.02),
            Color(red: 0.95, green: 0.3 + p1 * 0.2, blue: 0.02),
            .clear,

            // Row 3 — bottom: ALL clear
            .clear,
            .clear,
            .clear,
            .clear,
        ]
    }
}
