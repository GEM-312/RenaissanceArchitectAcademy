import SwiftUI
import AVFoundation

/// Full-screen transition played after character selection
/// Girl: sprite frames on parchment + audio with crossfade; Boy: video playback
struct AvatarTransitionView: View {
    let gender: ApprenticeGender
    var onFinished: () -> Void

    // Video (boy)
    @State private var player: AVPlayer?

    // Sprite frames (girl) — direct frame swap at ~6.4 fps for smooth playback
    @State private var currentFrame: Int = 0
    @State private var frameTimer: Timer?
    @State private var audioPlayer: AVAudioPlayer?
    @State private var showContent = false

    private let girlFrameCount = 30
    private let girlDuration: Double = 4.7  // match audio length
    private var frameInterval: Double { girlDuration / Double(girlFrameCount - 1) }

    var body: some View {
        ZStack {
            if gender == .girl {
                // Parchment background + crossfading sprite frames + audio
                RenaissanceColors.parchment
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()

                    Image("GirlIntroFrame\(String(format: "%02d", currentFrame))")
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 600)
                        .opacity(showContent ? 1 : 0)
                        .scaleEffect(showContent ? 1 : 0.95)

                    Spacer()
                }
                .padding(.horizontal, 40)
            } else {
                // Boy: video playback (unchanged)
                Color.black.ignoresSafeArea()

                if let player = player {
                    PlayerLayerView(player: player)
                        .ignoresSafeArea()
                }
            }
        }
        .onAppear {
            if gender == .girl {
                startGirlTransition()
            } else {
                startBoyVideo()
            }
        }
        .onDisappear {
            frameTimer?.invalidate()
            frameTimer = nil
            audioPlayer?.stop()
            audioPlayer = nil
            player?.pause()
            player = nil
        }
    }

    // MARK: - Girl: Sprite Frames + Audio

    private func startGirlTransition() {
        // Fade in
        withAnimation(.easeOut(duration: 0.5)) {
            showContent = true
        }

        // Start audio
        if let url = Bundle.main.url(forResource: "GirlIntroAudio", withExtension: "m4a") {
            audioPlayer = try? AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        }

        // Direct frame swap — 30 frames at ~6.4 fps for smooth playback
        frameTimer = Timer.scheduledTimer(withTimeInterval: frameInterval, repeats: true) { timer in
            if currentFrame < girlFrameCount - 1 {
                currentFrame += 1
            } else {
                timer.invalidate()
                frameTimer = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    onFinished()
                }
            }
        }
    }

    // MARK: - Boy: Video Playback

    private func startBoyVideo() {
        guard let url = Bundle.main.url(forResource: "BoyAvatarTransition", withExtension: "mp4") else {
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
}

// MARK: - Raw AVPlayerLayer wrapper (no controls)

#if os(iOS)
struct PlayerLayerView: UIViewRepresentable {
    let player: AVPlayer

    func makeUIView(context: Context) -> PlayerUIView {
        let view = PlayerUIView()
        view.playerLayer.player = player
        view.playerLayer.videoGravity = .resizeAspect
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
        playerLayer.videoGravity = .resizeAspect
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
