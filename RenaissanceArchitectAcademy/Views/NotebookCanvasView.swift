import SwiftUI

#if os(iOS)
import PencilKit

/// Single shared PKToolPicker used by ALL notebook canvases.
/// Creating one per card causes picker conflicts and tool switching bugs.
final class SharedToolPicker {
    static let instance = SharedToolPicker()
    let picker = PKToolPicker()
    private init() {}

    /// Hide the picker from whatever canvas currently owns it
    func hideFromAll() {
        // Setting visible=false for nil firstResponder is safe — just ensures it's hidden
        picker.setVisible(false, forFirstResponder: UIView())
    }
}

/// Transparent PencilKit overlay — sits ON TOP of note content so users can
/// highlight, circle, and write directly over the saved text.
/// In read mode touches pass through; in draw mode PencilKit captures them.
///
/// All canvases share a single PKToolPicker so tool switching and eraser work correctly.
struct NotebookCanvasView: UIViewRepresentable {
    var notebookState: NotebookState
    var entryId: UUID
    var isDrawing: Bool  // true = draw mode, false = read mode (pass-through)

    func makeCoordinator() -> Coordinator {
        Coordinator(notebookState: notebookState, entryId: entryId)
    }

    func makeUIView(context: Context) -> PKCanvasView {
        let canvas = PKCanvasView()
        canvas.drawingPolicy = .anyInput
        canvas.backgroundColor = .clear  // Transparent — text shows through
        canvas.isOpaque = false
        canvas.delegate = context.coordinator

        // Default tool: marker highlighter in warm yellow (for highlighting text)
        let highlightColor = UIColor(red: 1.0, green: 0.85, blue: 0.3, alpha: 0.4)
        canvas.tool = PKInkingTool(.marker, color: highlightColor, width: 15)

        canvas.isUserInteractionEnabled = isDrawing

        // Load existing drawing
        if let drawing = notebookState.loadDrawing(for: entryId) {
            canvas.drawing = drawing
        }

        // Register with the shared picker (never create our own)
        let shared = SharedToolPicker.instance
        shared.picker.addObserver(canvas)
        context.coordinator.canvas = canvas

        if isDrawing {
            shared.picker.setVisible(true, forFirstResponder: canvas)
            canvas.becomeFirstResponder()
        }

        return canvas
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        uiView.isUserInteractionEnabled = isDrawing

        let shared = SharedToolPicker.instance
        if isDrawing {
            shared.picker.setVisible(true, forFirstResponder: uiView)
            uiView.becomeFirstResponder()
        } else {
            shared.picker.setVisible(false, forFirstResponder: uiView)
            uiView.resignFirstResponder()
        }
    }

    static func dismantleUIView(_ uiView: PKCanvasView, coordinator: Coordinator) {
        // Clean up: remove observer and hide picker when the view is torn down
        let shared = SharedToolPicker.instance
        shared.picker.removeObserver(uiView)
        shared.picker.setVisible(false, forFirstResponder: uiView)
        uiView.resignFirstResponder()
    }

    class Coordinator: NSObject, PKCanvasViewDelegate {
        let notebookState: NotebookState
        let entryId: UUID
        weak var canvas: PKCanvasView?

        init(notebookState: NotebookState, entryId: UUID) {
            self.notebookState = notebookState
            self.entryId = entryId
        }

        deinit {
            // Extra safety: hide picker if coordinator is deallocated
            if let canvas = canvas {
                let shared = SharedToolPicker.instance
                shared.picker.removeObserver(canvas)
                shared.picker.setVisible(false, forFirstResponder: canvas)
                canvas.resignFirstResponder()
            }
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            notebookState.saveDrawing(canvasView.drawing, for: entryId)
        }
    }
}

#elseif os(macOS)

/// macOS equivalent — NSView-based stroke drawing overlay using Core Graphics.
/// Mirrors the iOS PKCanvasView pattern: transparent overlay on top of note content.
struct NotebookCanvasView: NSViewRepresentable {
    var notebookState: NotebookState
    var entryId: UUID
    var isDrawing: Bool
    var currentTool: StrokeTool = .marker
    var currentColor: StrokeColor = .yellow

    func makeNSView(context: Context) -> MacDrawingNSView {
        let view = MacDrawingNSView()
        view.strokes = notebookState.loadStrokes(for: entryId)
        view.currentTool = currentTool
        view.currentColor = currentColor
        view.onStrokesChanged = { strokes in
            notebookState.saveStrokes(strokes, for: entryId)
        }
        return view
    }

    func updateNSView(_ nsView: MacDrawingNSView, context: Context) {
        nsView.isDrawingEnabled = isDrawing
        nsView.currentTool = currentTool
        nsView.currentColor = currentColor
    }
}

/// Custom NSView that captures mouse drag events and renders strokes via Core Graphics.
class MacDrawingNSView: NSView {
    var strokes: [NotebookStroke] = []
    var currentPoints: [CGPoint] = []
    var currentTool: StrokeTool = .marker
    var currentColor: StrokeColor = .yellow
    var isDrawingEnabled = false
    var onStrokesChanged: (([NotebookStroke]) -> Void)?

    override var isFlipped: Bool { true }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        guard let ctx = NSGraphicsContext.current?.cgContext else { return }

        // Draw completed strokes
        for stroke in strokes {
            drawStroke(stroke, in: ctx)
        }

        // Draw in-progress stroke
        if !currentPoints.isEmpty {
            let inProgress = NotebookStroke(
                points: currentPoints,
                color: currentTool == .eraser ? .yellow : currentColor,
                width: widthForTool(currentTool),
                tool: currentTool
            )
            drawStroke(inProgress, in: ctx)
        }
    }

    private func drawStroke(_ stroke: NotebookStroke, in ctx: CGContext) {
        guard stroke.points.count >= 2 else { return }

        ctx.saveGState()

        if stroke.tool == .eraser {
            ctx.setBlendMode(.clear)
            ctx.setStrokeColor(NSColor.clear.cgColor)
        } else {
            ctx.setBlendMode(.normal)
            let alpha: CGFloat = stroke.tool == .marker ? 0.4 : 1.0
            ctx.setStrokeColor(stroke.color.nsColor.withAlphaComponent(alpha).cgColor)
        }

        ctx.setLineWidth(stroke.width)
        ctx.setLineCap(.round)
        ctx.setLineJoin(.round)

        ctx.beginPath()
        ctx.move(to: stroke.points[0])
        for point in stroke.points.dropFirst() {
            ctx.addLine(to: point)
        }
        ctx.strokePath()

        ctx.restoreGState()
    }

    private func widthForTool(_ tool: StrokeTool) -> CGFloat {
        switch tool {
        case .pen:    return 2.0
        case .marker: return 15.0
        case .eraser: return 20.0
        }
    }

    // MARK: - Mouse Events

    override func mouseDown(with event: NSEvent) {
        guard isDrawingEnabled else { super.mouseDown(with: event); return }
        let point = convert(event.locationInWindow, from: nil)
        currentPoints = [point]
    }

    override func mouseDragged(with event: NSEvent) {
        guard isDrawingEnabled else { super.mouseDragged(with: event); return }
        let point = convert(event.locationInWindow, from: nil)
        currentPoints.append(point)
        needsDisplay = true
    }

    override func mouseUp(with event: NSEvent) {
        guard isDrawingEnabled, currentPoints.count >= 2 else {
            currentPoints = []
            super.mouseUp(with: event)
            return
        }

        if currentTool == .eraser {
            eraseStrokesNear(currentPoints)
        } else {
            let stroke = NotebookStroke(
                points: currentPoints,
                color: currentColor,
                width: widthForTool(currentTool),
                tool: currentTool
            )
            strokes.append(stroke)
        }

        currentPoints = []
        needsDisplay = true
        onStrokesChanged?(strokes)
    }

    /// Remove any strokes that intersect the eraser path
    private func eraseStrokesNear(_ eraserPath: [CGPoint]) {
        let threshold: CGFloat = 12.0
        strokes.removeAll { stroke in
            for eraserPt in eraserPath {
                for strokePt in stroke.points {
                    let dx = eraserPt.x - strokePt.x
                    let dy = eraserPt.y - strokePt.y
                    if dx * dx + dy * dy < threshold * threshold {
                        return true
                    }
                }
            }
            return false
        }
    }
}

#endif
