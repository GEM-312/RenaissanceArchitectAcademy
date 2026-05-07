import SwiftUI

/// Displayed after `SketchValidator` returns a comparison between the student's
/// sketch and the reference engineering plan. Shows the score counting up,
/// strengths (what they got right) and gaps (what's missing), with a large
/// "Continue" button that fires the supplied completion callback.
///
/// Pass threshold = 70. Florins awarded = `score / 2` when passing.
struct SketchResultView: View {
    let result: SketchValidator.Result
    let buildingName: String
    var onRetry: (() -> Void)? = nil
    var onContinue: () -> Void

    @State private var displayedScore: Int = 0
    @State private var revealStep: Int = 0  // 0: score, 1: strengths, 2: gaps, 3: button

    private var passed: Bool { result.passed }            // score >= 70
    private var florinsEarned: Int { passed ? result.score / 2 : 0 }
    private var scoreColor: Color {
        if result.score >= 85 { return RenaissanceColors.goldSuccess }
        if result.score >= 70 { return RenaissanceColors.sageGreen }
        return RenaissanceColors.errorRed
    }

    var body: some View {
        VStack(spacing: 28) {
            // Header
            Text(passed ? "Masterful Work!" : "Not Quite Yet")
                .font(.custom("Cinzel-Bold", size: 28))
                .foregroundStyle(RenaissanceColors.sepiaInk)

            Text(buildingName)
                .font(.custom("EBGaramond-Italic", size: 18))
                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.65))

            // Score ring
            ZStack {
                Circle()
                    .stroke(RenaissanceColors.sepiaInk.opacity(0.12), lineWidth: 14)
                    .frame(width: 200, height: 200)
                Circle()
                    .trim(from: 0, to: CGFloat(displayedScore) / 100.0)
                    .stroke(scoreColor, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 1.6), value: displayedScore)

                VStack(spacing: 4) {
                    Text("\(displayedScore)")
                        .font(.custom("Cinzel-Bold", size: 56))
                        .foregroundStyle(scoreColor)
                        .contentTransition(.numericText(value: Double(displayedScore)))
                    Text("of 100")
                        .font(RenaissanceFont.footnote)
                        .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.55))
                }
            }

            // Strengths
            if revealStep >= 1, !result.strengths.isEmpty {
                feedbackSection(
                    title: "What you got right",
                    items: result.strengths,
                    icon: "checkmark.circle.fill",
                    tint: RenaissanceColors.sageGreen
                )
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }

            // Gaps
            if revealStep >= 2, !result.gaps.isEmpty {
                feedbackSection(
                    title: "What to work on",
                    items: result.gaps,
                    icon: "arrow.up.right.circle.fill",
                    tint: RenaissanceColors.terracotta
                )
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }

            Spacer(minLength: 8)

            // Florin line + buttons
            if revealStep >= 3 {
                VStack(spacing: 16) {
                    if passed {
                        HStack(spacing: 6) {
                            Image(systemName: "dollarsign.circle.fill")
                                .foregroundStyle(RenaissanceColors.iconOchre)
                            Text("+\(florinsEarned) florins")
                                .font(.custom("Cinzel-Bold", size: 18))
                                .foregroundStyle(RenaissanceColors.sepiaInk)
                        }
                    } else {
                        Text("You need a score of at least 70 to pass. Try again!")
                            .font(RenaissanceFont.footnote)
                            .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }

                    HStack(spacing: 12) {
                        if !passed, let onRetry {
                            Button {
                                onRetry()
                            } label: {
                                Text("Try Again")
                                    .font(RenaissanceFont.bodySemibold)
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(RenaissanceColors.terracotta)
                                    )
                            }
                            .buttonStyle(.plain)
                        }

                        Button {
                            onContinue()
                        } label: {
                            Text(passed ? "Continue" : "Skip")
                                .font(RenaissanceFont.bodySemibold)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(passed ? RenaissanceColors.sageGreen : RenaissanceColors.warmBrown)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .transition(.opacity)
            }
        }
        .padding(28)
        .frame(maxWidth: 560)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(RenaissanceColors.parchment)
                .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 4)
        )
        .onAppear { animateIn() }
    }

    // MARK: - Feedback section

    private func feedbackSection(title: String, items: [String], icon: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.custom("Cinzel-Bold", size: 14))
                .foregroundStyle(RenaissanceColors.sepiaInk)

            ForEach(items, id: \.self) { item in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: icon)
                        .font(.system(size: 14))
                        .foregroundStyle(tint)
                        .padding(.top, 2)
                    Text(item)
                        .font(RenaissanceFont.bodySmall)
                        .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.85))
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: 0)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(tint.opacity(0.08))
        )
    }

    // MARK: - Reveal animation

    private func animateIn() {
        // Count the score up
        withAnimation(.easeOut(duration: 1.6)) {
            displayedScore = result.score
        }
        // Stagger the reveal of strengths → gaps → buttons
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            withAnimation(.spring(response: 0.4)) { revealStep = 1 }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.1) {
            withAnimation(.spring(response: 0.4)) { revealStep = 2 }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.6) {
            withAnimation(.easeIn(duration: 0.3)) { revealStep = 3 }
        }
    }
}

#Preview {
    SketchResultView(
        result: SketchValidator.Result(
            score: 78,
            strengths: ["Circular rotunda in the center", "8 front columns across the portico façade", "Portico abuts the rotunda correctly"],
            gaps: ["Missing 4 inner pronaos columns", "Rotunda wall thickness not represented"]
        ),
        buildingName: "Pantheon",
        onRetry: {},
        onContinue: {}
    )
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(RenaissanceColors.parchmentGradient)
}
