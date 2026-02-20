import SwiftUI
import AVFoundation

/// Full-screen video transition played after character selection
/// Uses raw AVPlayerLayer — no controls, no chrome, fills the entire screen
struct AvatarTransitionView: View {
    let gender: ApprenticeGender
    var onFinished: () -> Void

    @State private var player: AVPlayer?

    private var videoName: String {
        switch gender {
        case .boy: return "BoyAvatarTransition"
        case .girl: return "GirlAvatarTransition"
        }
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if let player = player {
                PlayerLayerView(player: player)
                    .ignoresSafeArea()
            }
        }
        .onAppear {
            guard let url = Bundle.main.url(forResource: videoName, withExtension: "mp4") else {
                onFinished()
                return
            }
            let avPlayer = AVPlayer(url: url)
            self.player = avPlayer

            NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: avPlayer.currentItem,
                queue: .main
            ) { _ in
                onFinished()
            }

            avPlayer.play()
        }
        .onDisappear {
            player?.pause()
            player = nil
        }
    }
}

// MARK: - Raw AVPlayerLayer wrapper (no controls)

#if os(iOS)
struct PlayerLayerView: UIViewRepresentable {
    let player: AVPlayer

    func makeUIView(context: Context) -> PlayerUIView {
        let view = PlayerUIView()
        view.playerLayer.player = player
        view.playerLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: PlayerUIView, context: Context) {
        uiView.playerLayer.player = player
    }

    class PlayerUIView: UIView {
        override class var layerClass: AnyClass { AVPlayerLayer.self }
        var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
    }
}
#else
struct PlayerLayerView: NSViewRepresentable {
    let player: AVPlayer

    func makeNSView(context: Context) -> PlayerNSView {
        let view = PlayerNSView()
        view.wantsLayer = true
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        view.layer?.addSublayer(playerLayer)
        view.playerLayer = playerLayer
        return view
    }

    func updateNSView(_ nsView: PlayerNSView, context: Context) {
        nsView.playerLayer?.player = player
    }

    class PlayerNSView: NSView {
        var playerLayer: AVPlayerLayer?

        override func layout() {
            super.layout()
            playerLayer?.frame = bounds
        }
    }
}
#endif
