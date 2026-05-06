import SwiftUI
import AVFoundation

/// Avatar introduction shown after character select. Sprite frames on parchment
/// + audio voiceover. Same pattern for both genders — boy uses BoyIntroFrame00-29
/// + BoyIntroAudio.m4a, girl uses GirlIntroFrame00-29 + GirlIntroAudio.m4a.
/// If frames are missing for a gender (e.g. boy assets not generated yet),
/// the view skips immediately to onFinished.
struct AvatarTransitionView: View {
    let gender: ApprenticeGender
    var onFinished: () -> Void

    @State private var currentFrame: Int = 0
    @State private var frameTimer: Timer?
    @State private var audioPlayer: AVAudioPlayer?
    @State private var showContent = false

    private let frameCount = 30
    private let duration: Double = 4.7  // matches audio length
    private var frameInterval: Double { duration / Double(frameCount - 1) }

    private var framePrefix: String {
        gender == .boy ? "BoyIntroFrame" : "GirlIntroFrame"
    }

    private var audioName: String {
        gender == .boy ? "BoyIntroAudio" : "GirlIntroAudio"
    }

    private var firstFrameName: String {
        "\(framePrefix)00"
    }

    var body: some View {
        ZStack {
            RenaissanceColors.parchment
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                Image("\(framePrefix)\(String(format: "%02d", currentFrame))")
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 600)
                    .opacity(showContent ? 1 : 0)
                    .scaleEffect(showContent ? 1 : 0.95)

                Spacer()
            }
            .padding(.horizontal, 40)
        }
        .onAppear { startTransition() }
        .onDisappear {
            frameTimer?.invalidate()
            frameTimer = nil
            audioPlayer?.stop()
            audioPlayer = nil
        }
    }

    private func startTransition() {
        // If frames aren't bundled yet (e.g. boy assets not generated), skip.
        guard assetExists(named: firstFrameName) else {
            onFinished()
            return
        }

        withAnimation(.easeOut(duration: 0.5)) {
            showContent = true
        }

        if let url = Bundle.main.url(forResource: audioName, withExtension: "m4a") {
            audioPlayer = try? AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        }

        frameTimer = Timer.scheduledTimer(withTimeInterval: frameInterval, repeats: true) { timer in
            if currentFrame < frameCount - 1 {
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

    private func assetExists(named name: String) -> Bool {
        #if os(iOS)
        return UIImage(named: name) != nil
        #else
        return NSImage(named: name) != nil
        #endif
    }
}
