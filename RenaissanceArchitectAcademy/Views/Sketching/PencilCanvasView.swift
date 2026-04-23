#if os(iOS)
import SwiftUI
import PencilKit

/// SwiftUI wrapper around `PKCanvasView` for free-hand sketching on top of
/// a blueprint. The system-provided `PKToolPicker` gives pencil / pen /
/// marker / **ruler** / eraser.
///
/// PKCanvasView is a `UIScrollView` subclass — without explicit
/// configuration it applies a content offset / inset adjustment that
/// visibly drifts touches relative to the pencil nib. We disable scrolling,
/// lock zoom to 1.0, and turn off content-inset adjustment so the touch
/// location exactly matches the pencil tip.
///
/// The tool picker is attached in `updateUIView` once the canvas has a
/// window (it doesn't have one yet in `makeUIView`, which is why earlier
/// versions never showed the picker).
struct PencilCanvasView: UIViewRepresentable {
    @Binding var drawing: PKDrawing
    /// When false, the canvas resigns first responder so the system tool
    /// picker dismisses. Used to hide the picker while Study Mode is open.
    var isToolPickerVisible: Bool = true

    func makeUIView(context: Context) -> PKCanvasView {
        let canvas = PKCanvasView()
        canvas.drawing = drawing
        canvas.delegate = context.coordinator
        canvas.drawingPolicy = .anyInput          // Pencil OR finger — not every student has a Pencil
        canvas.backgroundColor = .clear           // Let the blueprint show through on Peek
        canvas.isOpaque = false

        // CRITICAL — kill every scroll-view behavior that offsets touches
        canvas.isScrollEnabled = false
        canvas.minimumZoomScale = 1.0
        canvas.maximumZoomScale = 1.0
        canvas.zoomScale = 1.0
        canvas.bouncesZoom = false
        canvas.alwaysBounceHorizontal = false
        canvas.alwaysBounceVertical = false
        canvas.contentInsetAdjustmentBehavior = .never
        canvas.contentInset = .zero
        canvas.verticalScrollIndicatorInsets = .zero
        canvas.horizontalScrollIndicatorInsets = .zero
        canvas.showsVerticalScrollIndicator = false
        canvas.showsHorizontalScrollIndicator = false

        return canvas
    }

    func updateUIView(_ canvas: PKCanvasView, context: Context) {
        // Only push drawing into the canvas if it actually differs — prevents
        // feedback loops where every stroke round-trips through the binding.
        if canvas.drawing != drawing {
            canvas.drawing = drawing
        }

        // Keep contentSize glued to bounds so PencilKit doesn't auto-scroll
        // after strokes approach the edge of the canvas.
        if canvas.contentSize != canvas.bounds.size, canvas.bounds.size != .zero {
            canvas.contentSize = canvas.bounds.size
        }

        // Attach the tool picker exactly once, after the canvas is in a
        // window — PKToolPicker.setVisible is a no-op while the canvas has
        // no window, which is why the picker never appeared on first mount.
        if canvas.window != nil, !context.coordinator.pickerAttached {
            context.coordinator.toolPicker.addObserver(canvas)
            context.coordinator.pickerAttached = true
        }

        // Toggle picker visibility — when Study Mode is open we hide it so
        // the picker doesn't float over the blueprint reader. Resigning
        // first responder is the iOS-idiomatic way to dismiss it.
        if canvas.window != nil, context.coordinator.pickerAttached {
            let picker = context.coordinator.toolPicker
            if isToolPickerVisible {
                picker.setVisible(true, forFirstResponder: canvas)
                if !canvas.isFirstResponder { canvas.becomeFirstResponder() }
            } else {
                picker.setVisible(false, forFirstResponder: canvas)
                if canvas.isFirstResponder { canvas.resignFirstResponder() }
            }
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: PencilCanvasView
        let toolPicker = PKToolPicker()
        var pickerAttached = false

        /// Strokes seen so far — lets us detect when exactly one new
        /// stroke was added so we can run shape-snap on it without
        /// re-entering on our own mutation.
        private var seenStrokeCount = 0
        private var isSnappingStroke = false

        init(_ parent: PencilCanvasView) { self.parent = parent }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            // Reentrancy guard — our own `canvas.drawing = …` below re-fires
            // this delegate. Skip the second fire.
            if isSnappingStroke {
                isSnappingStroke = false
                seenStrokeCount = canvasView.drawing.strokes.count
                parent.drawing = canvasView.drawing
                return
            }

            let count = canvasView.drawing.strokes.count

            // Only run snap when exactly one stroke was appended. Undo,
            // erase, or batch mutations shouldn't trigger it.
            if count == seenStrokeCount + 1,
               let latest = canvasView.drawing.strokes.last,
               let snapped = ShapeSnap.snapIfHeld(stroke: latest) {
                isSnappingStroke = true
                var strokes = Array(canvasView.drawing.strokes.dropLast())
                strokes.append(snapped)
                canvasView.drawing = PKDrawing(strokes: strokes)
                // Confirmation haptic — lets the student feel the snap fired
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                return   // the re-entered call will sync the binding
            }

            seenStrokeCount = count
            parent.drawing = canvasView.drawing
        }
    }
}

/// Render a `PKDrawing` to a PNG-ready `UIImage` on a white background so
/// Claude receives a clean sketch to compare against the blueprint.
extension PKDrawing {
    func renderedImage(size: CGSize, scale: CGFloat = 2.0) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        format.opaque = true
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { ctx in
            UIColor.white.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
            let img = image(from: CGRect(origin: .zero, size: size), scale: scale)
            img.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
#endif
