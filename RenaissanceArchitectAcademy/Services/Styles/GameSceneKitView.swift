import SwiftUI
import SceneKit

/// NSViewRepresentable / UIViewRepresentable wrapper for SCNView.
/// Follows the same pattern as GameSpriteView but for SceneKit 3D scenes.
/// Transparent background so the parchment card shows through.

#if os(macOS)
import AppKit

struct GameSceneKitView: NSViewRepresentable {
    let scene: SCNScene
    let onTap: ((SCNHitTestResult) -> Void)?

    init(scene: SCNScene, onTap: ((SCNHitTestResult) -> Void)? = nil) {
        self.scene = scene
        self.onTap = onTap
    }

    func makeNSView(context: Context) -> GameSCNView {
        let scnView = GameSCNView()
        scnView.scene = scene
        scnView.backgroundColor = PlatformColor(RenaissanceColors.parchment)
        scnView.allowsCameraControl = false
        scnView.autoenablesDefaultLighting = false
        scnView.antialiasingMode = .multisampling4X
        scnView.onTap = onTap
        // Set camera explicitly
        if let cam = scene.rootNode.childNode(withName: "camera", recursively: true) {
            scnView.pointOfView = cam
        }
        return scnView
    }

    func updateNSView(_ nsView: GameSCNView, context: Context) {
        nsView.onTap = onTap
    }

    class GameSCNView: SCNView {
        var onTap: ((SCNHitTestResult) -> Void)?

        override func mouseDown(with event: NSEvent) {
            let location = convert(event.locationInWindow, from: nil)
            let hits = hitTest(location, options: [.searchMode: SCNHitTestSearchMode.closest.rawValue])
            if let first = hits.first {
                onTap?(first)
            }
        }
    }
}

#else
import UIKit

struct GameSceneKitView: UIViewRepresentable {
    let scene: SCNScene
    let onTap: ((SCNHitTestResult) -> Void)?

    init(scene: SCNScene, onTap: ((SCNHitTestResult) -> Void)? = nil) {
        self.scene = scene
        self.onTap = onTap
    }

    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.scene = scene
        scnView.backgroundColor = PlatformColor(RenaissanceColors.parchment)
        scnView.allowsCameraControl = false
        scnView.autoenablesDefaultLighting = false
        scnView.antialiasingMode = .multisampling4X
        // Set camera explicitly
        if let cam = scene.rootNode.childNode(withName: "camera", recursively: true) {
            scnView.pointOfView = cam
        }

        let tapGR = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        scnView.addGestureRecognizer(tapGR)
        return scnView
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        context.coordinator.onTap = onTap
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onTap: onTap)
    }

    class Coordinator: NSObject {
        var onTap: ((SCNHitTestResult) -> Void)?

        init(onTap: ((SCNHitTestResult) -> Void)?) {
            self.onTap = onTap
        }

        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let scnView = gesture.view as? SCNView else { return }
            let location = gesture.location(in: scnView)
            let hits = scnView.hitTest(location, options: [.searchMode: NSNumber(value: SCNHitTestSearchMode.closest.rawValue)])
            if let first = hits.first {
                onTap?(first)
            }
        }
    }
}
#endif
