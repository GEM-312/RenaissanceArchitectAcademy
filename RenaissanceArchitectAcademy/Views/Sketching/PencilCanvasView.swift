#if os(iOS)
import SwiftUI
import PencilKit

/// SwiftUI wrapper around `PKCanvasView` so the student can free-hand trace
/// the blueprint with Apple Pencil or finger. The system-provided
/// `PKToolPicker` is shown alongside — it gives pencil / pen / marker /
/// **ruler** / eraser for free, no custom tool code required.
///
/// Caller owns the `PKDrawing` binding so the canvas can be snapshotted for
/// Claude validation without going through the view tree.
struct PencilCanvasView: UIViewRepresentable {
    @Binding var drawing: PKDrawing
    var isToolPickerVisible: Bool = true

    func makeUIView(context: Context) -> PKCanvasView {
        let canvas = PKCanvasView()
        canvas.drawing = drawing
        canvas.drawingPolicy = .anyInput   // Pencil OR finger — not every student has a Pencil
        canvas.backgroundColor = .clear     // Let the blueprint show through
        canvas.isOpaque = false
        canvas.delegate = context.coordinator

        if isToolPickerVisible {
            DispatchQueue.main.async {
                let picker = PKToolPicker.shared(for: canvas.window ?? UIWindow()) ?? PKToolPicker()
                picker.setVisible(true, forFirstResponder: canvas)
                picker.addObserver(canvas)
                canvas.becomeFirstResponder()
            }
        }

        return canvas
    }

    func updateUIView(_ canvas: PKCanvasView, context: Context) {
        // Only push drawing into the canvas if it actually differs — prevents
        // feedback loops where every stroke round-trips through the binding.
        if canvas.drawing != drawing {
            canvas.drawing = drawing
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: PencilCanvasView
        init(_ parent: PencilCanvasView) { self.parent = parent }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            parent.drawing = canvasView.drawing
        }
    }
}

/// Render a `PKDrawing` to a PNG-ready `UIImage` on a white background so
/// Claude receives a clean sketch to compare against the blueprint.
extension PKDrawing {
    func renderedImage(size: CGSize, scale: CGFloat = 2.0) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size, format: {
            let f = UIGraphicsImageRendererFormat()
            f.scale = scale
            f.opaque = true
            return f
        }())
        return renderer.image { ctx in
            UIColor.white.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
            let img = image(from: CGRect(origin: .zero, size: size), scale: scale)
            img.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
#endif
