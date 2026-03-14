import SwiftUI

/// "Study the Masters" overlay — shows a real Met Museum architectural sketch
/// with an interactive study prompt from the bird companion.
/// Used as an activity between knowledge cards to break up reading.
struct SketchStudyOverlay: View {
    let sketch: MuseumSketch
    let onDismiss: () -> Void
    let onComplete: (Int) -> Void  // florins earned

    @StateObject private var sketchService = MuseumSketchService.shared
    @State private var showHint = false
    @State private var showAnswer = false
    @State private var imageLoaded = false
    @State private var appearAnimation = false

    private let florinsReward = 3

    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture { /* block dismiss on background tap */ }

            // Main card
            VStack(spacing: 0) {
                headerBar
                sketchImageSection
                studyPromptSection
                actionButtons
            }
            .background(RenaissanceColors.parchment)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.3), radius: 20, y: 10)
            .frame(maxWidth: 580)
            .padding(.horizontal, 20)
            .padding(.vertical, 40)
            .scaleEffect(appearAnimation ? 1.0 : 0.9)
            .opacity(appearAnimation ? 1.0 : 0)
        }
        .onAppear {
            Task { await sketchService.loadImage(for: sketch) }
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                appearAnimation = true
            }
        }
    }

    // MARK: - Header

    private var headerBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Study the Masters")
                    .font(.custom("Cinzel-Bold", size: 16))
                    .foregroundColor(RenaissanceColors.sepiaInk)

                Text(sketch.artist + ", " + sketch.date)
                    .font(.custom("EBGaramond-Italic", size: 13))
                    .foregroundColor(RenaissanceColors.sepiaInk.opacity(0.6))
            }

            Spacer()

            Button {
                onDismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(RenaissanceColors.sepiaInk.opacity(0.4))
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 14)
        .padding(.bottom, 8)
    }

    // MARK: - Sketch Image

    private var sketchImageSection: some View {
        VStack(spacing: 0) {
            ZStack {
                // Parchment paper texture background
                RoundedRectangle(cornerRadius: 8)
                    .fill(RenaissanceColors.sepiaInk.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(RenaissanceColors.sepiaInk.opacity(0.15), lineWidth: 1)
                    )

                if let cachedImage = sketchService.imageCache[sketch.id] {
                    cachedImage
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .transition(.opacity)
                        .onAppear { imageLoaded = true }
                } else if sketchService.loadingIDs.contains(sketch.id) {
                    VStack(spacing: 12) {
                        ProgressView()
                            .tint(RenaissanceColors.warmBrown)
                        Text("Loading sketch from the Metropolitan Museum...")
                            .font(.custom("EBGaramond-Italic", size: 13))
                            .foregroundColor(RenaissanceColors.sepiaInk.opacity(0.5))
                    }
                } else {
                    VStack(spacing: 8) {
                        Image(systemName: "photo.artframe")
                            .font(.system(size: 40))
                            .foregroundColor(RenaissanceColors.sepiaInk.opacity(0.2))
                        Text(sketch.title)
                            .font(.custom("EBGaramond-Regular", size: 14))
                            .foregroundColor(RenaissanceColors.sepiaInk.opacity(0.4))
                            .multilineTextAlignment(.center)
                    }
                }
            }
            .frame(maxHeight: 300)
            .padding(.horizontal, 16)

            // Title caption below image
            Text(sketch.title)
                .font(.custom("EBGaramond-Regular", size: 13))
                .foregroundColor(RenaissanceColors.sepiaInk.opacity(0.5))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .padding(.horizontal, 20)
                .padding(.top, 6)
        }
    }

    // MARK: - Study Prompt (Bird)

    private var studyPromptSection: some View {
        VStack(spacing: 10) {
            HStack(alignment: .top, spacing: 10) {
                // Bird icon
                Image("BirdFrame00")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 36, height: 36)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(RenaissanceColors.ochre.opacity(0.3), lineWidth: 1))

                VStack(alignment: .leading, spacing: 6) {
                    Text(sketch.studyPrompt)
                        .font(.custom("EBGaramond-Regular", size: 15))
                        .foregroundColor(RenaissanceColors.sepiaInk)
                        .fixedSize(horizontal: false, vertical: true)

                    if showHint && !showAnswer {
                        Text(sketch.featureHint)
                            .font(.custom("EBGaramond-Italic", size: 14))
                            .foregroundColor(RenaissanceColors.warmBrown)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    if showAnswer {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(RenaissanceColors.sageGreen)
                            Text(sketch.featureToFind)
                                .font(.custom("EBGaramond-Regular", size: 14))
                                .foregroundColor(RenaissanceColors.sageGreen)
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
    }

    // MARK: - Actions

    private var actionButtons: some View {
        HStack(spacing: 12) {
            if !showAnswer {
                // Hint button
                if !showHint {
                    Button {
                        withAnimation(.easeOut(duration: 0.3)) {
                            showHint = true
                        }
                    } label: {
                        Label("Hint", systemImage: "lightbulb")
                            .font(.custom("EBGaramond-Regular", size: 14))
                            .foregroundColor(RenaissanceColors.warmBrown)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(RenaissanceColors.warmBrown.opacity(0.4), lineWidth: 1)
                            )
                    }
                }

                // "I see it!" button
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        showAnswer = true
                    }
                } label: {
                    Text("I found it!")
                        .font(.custom("Cinzel-Bold", size: 14))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(RenaissanceColors.renaissanceBlue)
                        )
                }
            } else {
                // Continue button (after answer revealed)
                Button {
                    onComplete(florinsReward)
                } label: {
                    HStack(spacing: 6) {
                        Text("Continue")
                            .font(.custom("Cinzel-Bold", size: 14))
                        Text("+\(florinsReward) florins")
                            .font(.custom("EBGaramond-Regular", size: 13))
                            .foregroundColor(RenaissanceColors.ochre)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(RenaissanceColors.sageGreen)
                    )
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 16)
    }
}

// MARK: - Medium badge

private struct MediumBadge: View {
    let medium: String

    var body: some View {
        Text(medium)
            .font(.custom("EBGaramond-Italic", size: 11))
            .foregroundColor(RenaissanceColors.sepiaInk.opacity(0.5))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(
                Capsule()
                    .fill(RenaissanceColors.sepiaInk.opacity(0.05))
            )
    }
}
