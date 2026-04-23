#if os(iOS)
import UIKit
import PencilKit

/// Apple-Notes-style "hold to snap" shape recognition on top of PencilKit.
///
/// PencilKit does not expose shape recognition in its public API (Apple
/// Notes has its own private layer). We implement our own: watch each new
/// stroke; if the student held the pencil still at the end (≥ `holdWindow`
/// seconds with spatial drift < `holdTolerance` points), classify the
/// stroke as a line or circle and replace it with a clean geometric version.
enum ShapeSnap {

    /// Hold detection — pencil barely moves but time keeps advancing.
    /// Relaxed from the first cut so a natural "pause and lift" triggers.
    static let holdWindow: TimeInterval = 0.22      // seconds
    static let holdTolerance: CGFloat = 22          // points — pencil wobbles on hold

    /// Line detection — max perpendicular distance from the best-fit line.
    static let lineTolerance: CGFloat = 22          // points

    /// Circle detection — relative standard deviation of radii.
    static let circleTolerance: CGFloat = 0.25
    /// Circle must span this fraction of 2π of angular coverage to count.
    static let circleMinArc: CGFloat = 0.70

    /// If the stroke ends in a hold AND classifies as a line/circle,
    /// return a new stroke with clean geometry. Otherwise nil (leave alone).
    static func snapIfHeld(stroke: PKStroke) -> PKStroke? {
        let pts = Array(stroke.path)
        guard let first = pts.first, let last = pts.last, pts.count >= 6 else {
            print("[ShapeSnap] reject — too few samples (\(pts.count))")
            return nil
        }

        let totalDuration = last.timeOffset - first.timeOffset

        // 1. Require a hold at the end of the stroke.
        let holdSamples = pts.filter { last.timeOffset - $0.timeOffset <= holdWindow }
        let holdExtent = spatialExtent(of: holdSamples.map(\.location))
        let heldLongEnough = holdSamples.count >= 3 && holdExtent < holdTolerance
        print("[ShapeSnap] stroke pts=\(pts.count) dur=\(String(format: "%.2f", totalDuration))s "
              + "holdSamples=\(holdSamples.count) holdDrift=\(String(format: "%.1f", holdExtent))pt "
              + "held=\(heldLongEnough)")

        guard heldLongEnough else { return nil }

        // 2. Strip the hold region before classifying shape.
        let body = pts.filter { last.timeOffset - $0.timeOffset > holdWindow * 0.6 }
        guard body.count >= 4 else {
            print("[ShapeSnap] reject — body too short after stripping hold")
            return nil
        }
        let locs = body.map(\.location)

        // 3. Try line first (most common — walls of a floor plan).
        if let (a, b) = fitLine(points: locs) {
            print("[ShapeSnap] ✅ LINE snap (\(Int(hypot(b.x - a.x, b.y - a.y)))pt)")
            return makeLineStroke(from: a, to: b, sourceStroke: stroke, sampleCount: 40)
        }

        // 4. Try circle.
        if let (center, radius) = fitCircle(points: locs) {
            print("[ShapeSnap] ✅ CIRCLE snap (r=\(Int(radius))pt)")
            return makeCircleStroke(center: center, radius: radius,
                                    sourceStroke: stroke, sampleCount: 64)
        }

        print("[ShapeSnap] held but no shape matched — leaving free-hand")
        return nil
    }

    // MARK: - Fitting

    /// Returns endpoints if the points lie along a straight line (within
    /// `lineTolerance`). We use the first and last body points as the
    /// target line; that's what the student drew toward.
    static func fitLine(points: [CGPoint]) -> (CGPoint, CGPoint)? {
        guard let first = points.first, let last = points.last else { return nil }
        let dx = last.x - first.x
        let dy = last.y - first.y
        let length = (dx * dx + dy * dy).squareRoot()
        guard length > 40 else { return nil }   // too short to mean a line intent

        var maxPerp: CGFloat = 0
        for p in points {
            // Perpendicular distance from point to line through first/last
            let area2 = abs(dx * (first.y - p.y) - (first.x - p.x) * dy)
            let perp = area2 / length
            if perp > maxPerp { maxPerp = perp }
        }

        return maxPerp <= lineTolerance ? (first, last) : nil
    }

    /// Returns (center, radius) if the points form a near-complete circle
    /// with low radial variance. Centroid + mean radius is close enough
    /// for hand-drawn shapes; full Kasa/Pratt fit is overkill here.
    static func fitCircle(points: [CGPoint]) -> (CGPoint, CGFloat)? {
        guard points.count >= 8 else { return nil }
        let cx = points.map(\.x).reduce(0, +) / CGFloat(points.count)
        let cy = points.map(\.y).reduce(0, +) / CGFloat(points.count)
        let center = CGPoint(x: cx, y: cy)

        let radii = points.map { hypot($0.x - cx, $0.y - cy) }
        let meanR = radii.reduce(0, +) / CGFloat(radii.count)
        guard meanR > 25 else { return nil }
        let variance = radii.reduce(0) { $0 + pow($1 - meanR, 2) } / CGFloat(radii.count)
        let stddev = variance.squareRoot()
        guard stddev / meanR <= circleTolerance else { return nil }

        // Require meaningful angular coverage — otherwise a sloppy curve
        // wrongly classifies as a circle.
        let angles = points.map { atan2($0.y - cy, $0.x - cx) }.sorted()
        var maxGap: CGFloat = 0
        for i in 0..<angles.count - 1 {
            maxGap = max(maxGap, angles[i + 1] - angles[i])
        }
        // Wrap-around gap across the -π / π seam
        let wrap = (angles.first! + 2 * .pi) - angles.last!
        maxGap = max(maxGap, wrap)
        let coverage = (2 * .pi - maxGap) / (2 * .pi)
        guard coverage >= circleMinArc else { return nil }

        return (center, meanR)
    }

    // MARK: - Stroke construction

    /// Build a clean straight-line PKStroke between two points, copying ink
    /// properties (color, tool type, average pressure) from the original.
    static func makeLineStroke(from a: CGPoint, to b: CGPoint,
                               sourceStroke: PKStroke, sampleCount: Int) -> PKStroke {
        let template = templatePoint(from: sourceStroke)
        var controls: [PKStrokePoint] = []
        for i in 0...sampleCount {
            let t = CGFloat(i) / CGFloat(sampleCount)
            let location = CGPoint(x: a.x + (b.x - a.x) * t, y: a.y + (b.y - a.y) * t)
            controls.append(pointAt(location: location,
                                    timeOffset: TimeInterval(t) * 0.25,
                                    template: template))
        }
        let path = PKStrokePath(controlPoints: controls, creationDate: Date())
        return PKStroke(ink: sourceStroke.ink, path: path, transform: sourceStroke.transform)
    }

    /// Build a clean circle PKStroke around `center` with `radius`.
    static func makeCircleStroke(center: CGPoint, radius: CGFloat,
                                 sourceStroke: PKStroke, sampleCount: Int) -> PKStroke {
        let template = templatePoint(from: sourceStroke)
        var controls: [PKStrokePoint] = []
        for i in 0...sampleCount {
            let angle = CGFloat(i) / CGFloat(sampleCount) * 2 * .pi
            let location = CGPoint(
                x: center.x + cos(angle) * radius,
                y: center.y + sin(angle) * radius
            )
            controls.append(pointAt(location: location,
                                    timeOffset: TimeInterval(i) * 0.01,
                                    template: template))
        }
        let path = PKStrokePath(controlPoints: controls, creationDate: Date())
        return PKStroke(ink: sourceStroke.ink, path: path, transform: sourceStroke.transform)
    }

    /// A mid-stroke sample from the original — we reuse its pressure /
    /// size / azimuth so the snapped stroke visually matches the pen the
    /// student had selected.
    private static func templatePoint(from stroke: PKStroke) -> PKStrokePoint {
        let all = Array(stroke.path)
        return all[all.count / 2]
    }

    private static func pointAt(location: CGPoint,
                                timeOffset: TimeInterval,
                                template: PKStrokePoint) -> PKStrokePoint {
        PKStrokePoint(
            location: location,
            timeOffset: timeOffset,
            size: template.size,
            opacity: template.opacity,
            force: template.force,
            azimuth: template.azimuth,
            altitude: template.altitude
        )
    }

    // MARK: - Small math helpers

    private static func spatialExtent(of points: [CGPoint]) -> CGFloat {
        guard !points.isEmpty else { return 0 }
        let xs = points.map(\.x), ys = points.map(\.y)
        return max(xs.max()! - xs.min()!, ys.max()! - ys.min()!)
    }
}
#endif
