import SwiftUI

/// Reusable draggable Bézier curve component — Old Man's Journey-inspired
/// Player drags control points to shape arches, domes, columns.
/// Draws a smooth Catmull-Rom spline through all points.
struct BezierDragShape: View {

    let element: AlzatoElement
    @Binding var currentPoints: [CGPoint]   // player's current control point positions (normalized 0-1)
    let showTarget: Bool                     // show ghost target curve (for hints)
    let isLocked: Bool                       // true when validated correct — no more dragging

    /// Whether all control points are within tolerance of target
    var isCorrect: Bool {
        guard currentPoints.count == element.targetPoints.count else { return false }
        let totalDistance = zip(currentPoints, element.targetPoints).reduce(CGFloat(0)) { sum, pair in
            sum + hypot(pair.0.x - pair.1.x, pair.0.y - pair.1.y)
        }
        let avgDistance = totalDistance / CGFloat(currentPoints.count)
        return avgDistance <= element.tolerance
    }

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack {
                // Target ghost curve (hint)
                if showTarget {
                    curveShape(points: element.targetPoints, in: geo.size)
                        .stroke(style: StrokeStyle(lineWidth: 2, dash: [6, 4]))
                        .foregroundStyle(RenaissanceColors.sageGreen.opacity(0.4))

                    curveShape(points: element.targetPoints, in: geo.size)
                        .fill(RenaissanceColors.sageGreen.opacity(0.06))
                }

                // Player's current curve — filled
                curveShape(points: currentPoints, in: geo.size)
                    .fill(curveColor.opacity(0.15))

                curveShape(points: currentPoints, in: geo.size)
                    .stroke(curveColor, lineWidth: isLocked ? 3 : 2)

                // Control point handles
                if !isLocked {
                    ForEach(currentPoints.indices, id: \.self) { i in
                        let pt = denormalize(currentPoints[i], in: geo.size)

                        Circle()
                            .fill(isCorrect ? RenaissanceColors.sageGreen : RenaissanceColors.ochre)
                            .frame(width: 20, height: 20)
                            .overlay(
                                Circle()
                                    .strokeBorder(.white.opacity(0.6), lineWidth: 1.5)
                            )
                            .shadow(color: .black.opacity(0.2), radius: 2, y: 1)
                            .position(pt)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        let normalized = normalize(value.location, in: geo.size)
                                        var newPoint = currentPoints[i]

                                        switch element.fixedAxis {
                                        case .horizontal:
                                            // Only Y moves
                                            newPoint.y = clamp(normalized.y, to: element.clampRange)
                                        case .vertical:
                                            // Only X moves
                                            newPoint.x = clamp(normalized.x, to: element.clampRange)
                                        case .free:
                                            newPoint.x = clamp(normalized.x, to: 0...1)
                                            newPoint.y = clamp(normalized.y, to: element.clampRange)
                                        }

                                        currentPoints[i] = newPoint
                                    }
                                    .onEnded { _ in
                                        SoundManager.shared.play(.tapSoft)
                                    }
                            )
                    }
                }

                // Correct checkmark
                if isLocked {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(RenaissanceColors.sageGreen)
                        .position(x: w * 0.9, y: h * 0.1)
                }
            }
        }
    }

    // MARK: - Curve Color

    private var curveColor: Color {
        if isLocked { return RenaissanceColors.sageGreen }
        if isCorrect { return RenaissanceColors.sageGreen }
        return RenaissanceColors.sepiaInk
    }

    // MARK: - Catmull-Rom Spline

    /// Build a smooth curve through all control points using Catmull-Rom interpolation
    private func curveShape(points: [CGPoint], in size: CGSize) -> Path {
        let pts = points.map { denormalize($0, in: size) }
        guard pts.count >= 2 else { return Path() }

        return Path { path in
            path.move(to: pts[0])

            if pts.count == 2 {
                path.addLine(to: pts[1])
            } else {
                for i in 0..<pts.count - 1 {
                    let p0 = i > 0 ? pts[i - 1] : pts[i]
                    let p1 = pts[i]
                    let p2 = pts[i + 1]
                    let p3 = i + 2 < pts.count ? pts[i + 2] : pts[i + 1]

                    let cp1 = CGPoint(
                        x: p1.x + (p2.x - p0.x) / 6,
                        y: p1.y + (p2.y - p0.y) / 6
                    )
                    let cp2 = CGPoint(
                        x: p2.x - (p3.x - p1.x) / 6,
                        y: p2.y - (p3.y - p1.y) / 6
                    )
                    path.addCurve(to: p2, control1: cp1, control2: cp2)
                }
            }

            // Close the bottom for filled shapes (arch, dome)
            if let last = pts.last, let first = pts.first {
                path.addLine(to: CGPoint(x: last.x, y: size.height))
                path.addLine(to: CGPoint(x: first.x, y: size.height))
                path.closeSubpath()
            }
        }
    }

    // MARK: - Coordinate Helpers

    private func denormalize(_ pt: CGPoint, in size: CGSize) -> CGPoint {
        CGPoint(x: pt.x * size.width, y: pt.y * size.height)
    }

    private func normalize(_ pt: CGPoint, in size: CGSize) -> CGPoint {
        CGPoint(x: pt.x / size.width, y: pt.y / size.height)
    }

    private func clamp(_ value: CGFloat, to range: ClosedRange<CGFloat>) -> CGFloat {
        min(max(value, range.lowerBound), range.upperBound)
    }
}
