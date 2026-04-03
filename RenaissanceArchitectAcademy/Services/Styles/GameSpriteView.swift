import SwiftUI
import SpriteKit

/// Holds a SpriteKit scene reference without triggering SwiftUI re-renders.
/// Use with `@State var sceneHolder = SceneHolder<MyScene>()` — the class identity
/// stays stable across body evaluations so the scene is created exactly once.
class SceneHolder<T: SKScene> {
    var scene: T?
}

/// Custom SpriteView replacement that properly handles scroll-to-pan and pinch-to-zoom.
///
/// WHY THIS EXISTS:
/// SwiftUI's built-in `SpriteView` swallows `scrollWheel` and `magnify` events —
/// the SKScene never receives them. This wrapper creates an `SKView` directly via
/// NSViewRepresentable/UIViewRepresentable, so all native events flow through.
///
/// CONTROLS (macOS):
/// - Scroll (trackpad / Magic Mouse) = pan the camera
/// - Pinch (trackpad) = zoom in/out
/// - Option + scroll = zoom in/out (for mouse wheel users)
/// - Click + drag = pan (handled by SKScene's mouseDown/mouseDragged)

#if os(macOS)
import AppKit

struct GameSpriteView: NSViewRepresentable {
    let scene: SKScene
    let options: SpriteView.Options

    init(scene: SKScene, options: SpriteView.Options = []) {
        self.scene = scene
        self.options = options
    }

    func makeNSView(context: Context) -> GameSKView {
        let skView = GameSKView()
        skView.allowsTransparency = options.contains(.allowsTransparency)
        skView.ignoresSiblingOrder = options.contains(.ignoresSiblingOrder)

        #if DEBUG
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.showsDrawCount = true
        #endif

        // Present the scene
        skView.presentScene(scene)

        return skView
    }

    func updateNSView(_ nsView: GameSKView, context: Context) {
        // Scene is already presented; nothing to update
    }

    /// Custom SKView subclass that forwards scroll/magnify to the presented scene
    class GameSKView: SKView {

        override var acceptsFirstResponder: Bool { true }

        // Scroll wheel: regular = pan, Option-held = zoom
        override func scrollWheel(with event: NSEvent) {
            guard let scene = self.scene else { return }

            if event.modifierFlags.contains(.option) {
                // Option + scroll = zoom
                if let zoomable = scene as? ScrollZoomable {
                    zoomable.handleScrollZoom(deltaY: event.deltaY)
                }
            } else {
                // Regular scroll = pan
                if let pannable = scene as? ScrollZoomable {
                    pannable.handleScrollPan(deltaX: event.deltaX, deltaY: event.deltaY)
                }
            }
        }

        // Trackpad pinch-to-zoom
        override func magnify(with event: NSEvent) {
            guard let scene = self.scene as? ScrollZoomable else { return }
            scene.handleMagnify(magnification: event.magnification)
        }
    }
}

/// Protocol that SpriteKit scenes conform to for camera control from the view layer
protocol ScrollZoomable: AnyObject {
    func handleScrollZoom(deltaY: CGFloat)
    func handleScrollPan(deltaX: CGFloat, deltaY: CGFloat)
    func handleMagnify(magnification: CGFloat)
}

#else
import UIKit

struct GameSpriteView: UIViewRepresentable {
    let scene: SKScene
    let options: SpriteView.Options

    init(scene: SKScene, options: SpriteView.Options = []) {
        self.scene = scene
        self.options = options
    }

    func makeUIView(context: Context) -> SKView {
        let skView = SKView()
        skView.allowsTransparency = options.contains(.allowsTransparency)
        skView.ignoresSiblingOrder = options.contains(.ignoresSiblingOrder)

        // Ensure full Retina resolution rendering
        skView.contentScaleFactor = UIScreen.main.nativeScale

        #if DEBUG
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.showsDrawCount = true
        print("[GameSpriteView] contentScaleFactor: \(skView.contentScaleFactor), nativeScale: \(UIScreen.main.nativeScale)")
        #endif

        skView.presentScene(scene)

        // Add pinch gesture for iOS
        let pinch = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePinch(_:)))
        skView.addGestureRecognizer(pinch)

        return skView
    }

    func updateUIView(_ uiView: SKView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(scene: scene)
    }

    class Coordinator: NSObject {
        weak var scene: SKScene?
        private var lastPinchScale: CGFloat = 1.0

        init(scene: SKScene) {
            self.scene = scene
        }

        @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
            guard let zoomable = scene as? ScrollZoomable else { return }
            switch gesture.state {
            case .began:
                lastPinchScale = gesture.scale
            case .changed:
                let delta = gesture.scale / lastPinchScale
                zoomable.handleMagnify(magnification: delta - 1.0)
                lastPinchScale = gesture.scale
            default:
                lastPinchScale = 1.0
            }
        }
    }
}

protocol ScrollZoomable: AnyObject {
    func handleScrollZoom(deltaY: CGFloat)
    func handleScrollPan(deltaX: CGFloat, deltaY: CGFloat)
    func handleMagnify(magnification: CGFloat)
}
#endif
