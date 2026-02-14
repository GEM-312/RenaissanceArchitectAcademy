import SwiftUI
import Pow

/// Master orchestrator for sketching challenges
/// Shows intro → routes to correct phase view → tracks progress → completion
struct SketchingChallengeView: View {
    let challenge: SketchingChallenge
    let onComplete: (Set<SketchingPhaseType>) -> Void
    let onDismiss: () -> Void

    @State private var showIntro = true
    @State private var currentPhaseIndex = 0
    @State private var completedPhases: Set<SketchingPhaseType> = []
    @State private var showCompletion = false
    @State private var showSuccessEffect = false

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    private var isLargeScreen: Bool { horizontalSizeClass == .regular }

    private var currentPhase: SketchingPhase? {
        guard currentPhaseIndex < challenge.phases.count else { return nil }
        return challenge.phases[currentPhaseIndex]
    }

    var body: some View {
        ZStack {
            // Parchment background
            RenaissanceColors.parchmentGradient
                .ignoresSafeArea()
                .overlay(
                    BlueprintGridOverlay()
                        .opacity(0.03)
                )

            if showIntro {
                introView
            } else if showCompletion {
                completionView
            } else if let phase = currentPhase {
                phaseView(phase)
            }
        }
        .changeEffect(
            .spray(origin: UnitPoint(x: 0.5, y: 0.3)) {
                Image(systemName: "star.fill")
                    .foregroundStyle(RenaissanceColors.goldSuccess)
            },
            value: showSuccessEffect
        )
    }

    // MARK: - Introduction

    private var introView: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer(minLength: 40)

                // Header
                VStack(spacing: 8) {
                    Text(challenge.buildingName)
                        .font(.custom("Cinzel-Bold", size: isLargeScreen ? 36 : 28, relativeTo: .title))
                        .foregroundStyle(RenaissanceColors.sepiaInk)

                    Text("Sketching Challenge")
                        .font(.custom("EBGaramond-Italic", size: isLargeScreen ? 20 : 16, relativeTo: .subheadline))
                        .foregroundStyle(RenaissanceColors.renaissanceBlue)
                }

                // Decorative divider
                HStack(spacing: 12) {
                    Rectangle()
                        .fill(RenaissanceColors.ochre.opacity(0.4))
                        .frame(height: 1)
                    Image(systemName: "pencil.and.ruler")
                        .font(.caption)
                        .foregroundStyle(RenaissanceColors.warmBrown)
                    Rectangle()
                        .fill(RenaissanceColors.ochre.opacity(0.4))
                        .frame(height: 1)
                }
                .padding(.horizontal, 40)

                // Introduction text
                Text(challenge.introduction)
                    .font(.custom("EBGaramond-Regular", size: isLargeScreen ? 18 : 16, relativeTo: .body))
                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, isLargeScreen ? 60 : 24)

                // Phase list
                VStack(alignment: .leading, spacing: 12) {
                    Text("Drawing Phases")
                        .font(.custom("Cinzel-Regular", size: 14, relativeTo: .caption))
                        .foregroundStyle(RenaissanceColors.warmBrown)

                    ForEach(Array(challenge.phases.enumerated()), id: \.offset) { index, phase in
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(RenaissanceColors.renaissanceBlue.opacity(0.15))
                                    .frame(width: 32, height: 32)
                                Text("\(index + 1)")
                                    .font(.custom("Cinzel-Bold", size: 14, relativeTo: .caption))
                                    .foregroundStyle(RenaissanceColors.renaissanceBlue)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(phase.title)
                                    .font(.custom("EBGaramond-Regular", size: 15, relativeTo: .body))
                                    .foregroundStyle(RenaissanceColors.sepiaInk)

                                HStack(spacing: 4) {
                                    ForEach(phase.sciencesFocused, id: \.self) { science in
                                        Image(systemName: science.sfSymbolName)
                                            .font(.system(size: 10))
                                            .foregroundStyle(RenaissanceColors.color(for: science))
                                    }
                                }
                            }

                            Spacer()

                            Image(systemName: phase.phaseType.iconName)
                                .foregroundStyle(RenaissanceColors.stoneGray)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(RenaissanceColors.parchment)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(RenaissanceColors.ochre.opacity(0.2), lineWidth: 1)
                        )
                )
                .padding(.horizontal, isLargeScreen ? 60 : 24)

                // Buttons
                VStack(spacing: 12) {
                    RenaissanceButton(title: "Begin Drawing") {
                        withAnimation(.spring(response: 0.4)) {
                            showIntro = false
                        }
                    }

                    Button("Back") {
                        onDismiss()
                    }
                    .font(.custom("EBGaramond-Italic", size: 14, relativeTo: .caption))
                    .foregroundStyle(RenaissanceColors.stoneGray)
                    .buttonStyle(.plain)
                }
                .padding(.top, 8)

                Spacer(minLength: 40)
            }
            .frame(maxWidth: isLargeScreen ? 600 : .infinity)
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Phase View

    @ViewBuilder
    private func phaseView(_ phase: SketchingPhase) -> some View {
        VStack(spacing: 0) {
            // Top bar
            HStack {
                Button {
                    if currentPhaseIndex > 0 {
                        withAnimation { currentPhaseIndex -= 1 }
                    } else {
                        withAnimation { showIntro = true }
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.6))
                }
                .buttonStyle(.plain)

                Spacer()

                // Phase progress
                HStack(spacing: 6) {
                    ForEach(Array(challenge.phases.enumerated()), id: \.offset) { index, p in
                        Circle()
                            .fill(completedPhases.contains(p.phaseType)
                                  ? RenaissanceColors.sageGreen
                                  : (index == currentPhaseIndex
                                     ? RenaissanceColors.renaissanceBlue
                                     : RenaissanceColors.stoneGray.opacity(0.3)))
                            .frame(width: 8, height: 8)
                    }
                }

                Spacer()

                Button {
                    onDismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.4))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            // Phase content
            switch phase.phaseData {
            case .pianta(let data):
                PiantaCanvasView(phaseData: data) { phases in
                    completedPhases.formUnion(phases)
                    advanceOrComplete()
                }
            case .alzato, .sezione, .prospettiva:
                // Future phases — placeholder
                VStack(spacing: 20) {
                    Spacer()
                    Image(systemName: "hammer.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(RenaissanceColors.stoneGray)
                    Text("Coming Soon")
                        .font(.custom("Cinzel-Bold", size: 24, relativeTo: .title))
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                    Text("This drawing phase is under construction.")
                        .font(.custom("EBGaramond-Italic", size: 16, relativeTo: .body))
                        .foregroundStyle(RenaissanceColors.stoneGray)
                    Spacer()
                }
            }
        }
    }

    // MARK: - Completion

    private var completionView: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer(minLength: 60)

                // Victory icon
                ZStack {
                    Circle()
                        .fill(RenaissanceColors.goldSuccess.opacity(0.15))
                        .frame(width: 100, height: 100)
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(RenaissanceColors.goldSuccess)
                }

                Text("Masterful Work!")
                    .font(.custom("Cinzel-Bold", size: isLargeScreen ? 32 : 26, relativeTo: .title))
                    .foregroundStyle(RenaissanceColors.sepiaInk)

                Text(challenge.buildingName)
                    .font(.custom("EBGaramond-Italic", size: 18, relativeTo: .subheadline))
                    .foregroundStyle(RenaissanceColors.renaissanceBlue)

                // Decorative divider
                HStack(spacing: 12) {
                    Rectangle()
                        .fill(RenaissanceColors.goldSuccess.opacity(0.4))
                        .frame(height: 1)
                    Image(systemName: "seal.fill")
                        .font(.caption)
                        .foregroundStyle(RenaissanceColors.goldSuccess)
                    Rectangle()
                        .fill(RenaissanceColors.goldSuccess.opacity(0.4))
                        .frame(height: 1)
                }
                .padding(.horizontal, 40)

                // Educational summary
                Text(challenge.educationalSummary)
                    .font(.custom("EBGaramond-Regular", size: isLargeScreen ? 17 : 15, relativeTo: .body))
                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, isLargeScreen ? 60 : 24)

                // Completed phases
                HStack(spacing: 16) {
                    ForEach(challenge.phases) { phase in
                        VStack(spacing: 4) {
                            Image(systemName: completedPhases.contains(phase.phaseType)
                                  ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(completedPhases.contains(phase.phaseType)
                                                 ? RenaissanceColors.sageGreen : RenaissanceColors.stoneGray)
                            Text(phase.phaseType.italianTitle)
                                .font(.custom("EBGaramond-Regular", size: 12, relativeTo: .caption2))
                                .foregroundStyle(RenaissanceColors.sepiaInk)
                        }
                    }
                }

                RenaissanceButton(title: "Continue") {
                    onComplete(completedPhases)
                }
                .padding(.horizontal, 60)

                Spacer(minLength: 40)
            }
            .frame(maxWidth: isLargeScreen ? 600 : .infinity)
            .frame(maxWidth: .infinity)
        }
        .onAppear {
            showSuccessEffect.toggle()
        }
    }

    // MARK: - Navigation

    private func advanceOrComplete() {
        if currentPhaseIndex + 1 < challenge.phases.count {
            withAnimation(.spring(response: 0.4)) {
                currentPhaseIndex += 1
            }
        } else {
            withAnimation(.spring(response: 0.4)) {
                showCompletion = true
            }
        }
    }
}

#Preview {
    SketchingChallengeView(
        challenge: SketchingContent.pantheonSketching,
        onComplete: { _ in },
        onDismiss: {}
    )
}
