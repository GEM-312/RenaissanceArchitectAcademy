import SwiftUI

/// 3-tier hint overlay: riddle → choose method (craft/earn) → detailed hint scroll
/// Phases: riddle → chooseMethod → crafting → trueFalse → hintScroll
struct HintOverlayView: View {
    let hintData: HintData
    let workshopState: WorkshopState?
    let onDismiss: () -> Void

    enum Phase {
        case riddle
        case chooseMethod
        case crafting
        case trueFalse
        case hintScroll
    }

    @State private var phase: Phase = .riddle
    @State private var showContent = false
    @State private var trueFalseAnswer: Bool? = nil
    @State private var trueFalseShake = false
    @State private var craftingMaterials: [(String, CGFloat)] = []  // (icon, offset)
    @State private var showScrollReveal = false

    // How many total raw materials the player has
    private var totalMaterials: Int {
        workshopState?.rawMaterials.values.reduce(0, +) ?? 0
    }

    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            VStack(spacing: 20) {
                Spacer()

                switch phase {
                case .riddle:
                    riddlePhase
                case .chooseMethod:
                    chooseMethodPhase
                case .crafting:
                    craftingPhase
                case .trueFalse:
                    trueFalsePhase
                case .hintScroll:
                    hintScrollPhase
                }

                Spacer()
            }
            .padding(.horizontal, 32)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                showContent = true
            }
        }
    }

    // MARK: - Phase 1: Riddle (Free)

    private var riddlePhase: some View {
        VStack(spacing: 20) {
            // Bird mascot
            BirdCharacter(isSitting: true)
                .frame(width: 140, height: 140)
                .scaleEffect(showContent ? 1 : 0.3)
                .opacity(showContent ? 1 : 0)

            // Dialogue bubble with riddle
            VStack(spacing: 16) {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .foregroundStyle(RenaissanceColors.goldSuccess)
                    Text("A Riddle for You...")
                        .font(.custom("Cinzel-Bold", size: 18))
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                }

                Text(hintData.riddle)
                    .font(.custom("EBGaramond-Italic", size: 18))
                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 8)

                Divider()
                    .background(RenaissanceColors.ochre.opacity(0.3))

                // Two buttons
                VStack(spacing: 10) {
                    Button {
                        onDismiss()
                    } label: {
                        hintChoiceLabel(icon: "lightbulb.fill", text: "That helps!", color: RenaissanceColors.sageGreen)
                    }
                    .buttonStyle(.plain)

                    Button {
                        withAnimation(.spring(response: 0.4)) {
                            phase = .chooseMethod
                        }
                    } label: {
                        hintChoiceLabel(icon: "arrow.right.circle", text: "I need more help...", color: RenaissanceColors.renaissanceBlue)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(24)
            .background(DialogueBubble())
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : 30)
        }
    }

    // MARK: - Phase 2: Choose Method

    private var chooseMethodPhase: some View {
        VStack(spacing: 20) {
            BirdCharacter(isSitting: true)
                .frame(width: 120, height: 120)

            VStack(spacing: 16) {
                Text("How would you like your hint?")
                    .font(.custom("Cinzel-Bold", size: 18))
                    .foregroundStyle(RenaissanceColors.sepiaInk)

                // Craft option
                Button {
                    withAnimation(.spring(response: 0.4)) {
                        deductMaterials()
                        phase = .crafting
                    }
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "hammer.fill")
                            .foregroundStyle(RenaissanceColors.warmBrown)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Craft a Hint Scroll")
                                .font(.custom("EBGaramond-Regular", size: 17))
                                .foregroundStyle(RenaissanceColors.sepiaInk)
                            Text("Costs 3 raw materials")
                                .font(.custom("EBGaramond-Italic", size: 13))
                                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.6))
                        }
                        Spacer()
                        if totalMaterials >= 3 {
                            Image(systemName: "chevron.right")
                                .foregroundStyle(RenaissanceColors.stoneGray)
                        } else {
                            Text("Not enough")
                                .font(.custom("EBGaramond-Italic", size: 12))
                                .foregroundStyle(RenaissanceColors.errorRed)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(totalMaterials >= 3 ? RenaissanceColors.parchment : RenaissanceColors.parchment.opacity(0.5))
                            .shadow(color: RenaissanceColors.warmBrown.opacity(0.2), radius: 4, y: 2)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(RenaissanceColors.ochre.opacity(0.5), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                .disabled(totalMaterials < 3)
                .opacity(totalMaterials >= 3 ? 1 : 0.6)

                // Earn option
                Button {
                    withAnimation(.spring(response: 0.4)) {
                        phase = .trueFalse
                    }
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "brain.head.profile")
                            .foregroundStyle(RenaissanceColors.renaissanceBlue)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Earn by Activity")
                                .font(.custom("EBGaramond-Regular", size: 17))
                                .foregroundStyle(RenaissanceColors.sepiaInk)
                            Text("Answer a true/false question")
                                .font(.custom("EBGaramond-Italic", size: 13))
                                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.6))
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(RenaissanceColors.stoneGray)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(RenaissanceColors.parchment)
                            .shadow(color: RenaissanceColors.warmBrown.opacity(0.2), radius: 4, y: 2)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(RenaissanceColors.ochre.opacity(0.5), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(24)
            .background(DialogueBubble())
        }
    }

    // MARK: - Phase 3: Crafting Animation

    private var craftingPhase: some View {
        VStack(spacing: 24) {
            Text("Crafting Hint Scroll...")
                .font(.custom("Cinzel-Bold", size: 20))
                .foregroundStyle(RenaissanceColors.sepiaInk)

            // Floating material icons
            ZStack {
                ForEach(Array(craftingMaterials.enumerated()), id: \.offset) { index, item in
                    Text(item.0)
                        .font(.system(size: 36))
                        .offset(y: item.1)
                        .opacity(item.1 < -80 ? 0 : 1)
                }

                // Scroll appearing
                Image(systemName: "scroll.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(RenaissanceColors.ochre)
                    .scaleEffect(showScrollReveal ? 1 : 0)
                    .opacity(showScrollReveal ? 1 : 0)
            }
            .frame(height: 120)
        }
        .padding(32)
        .background(DialogueBubble())
        .onAppear {
            startCraftingAnimation()
        }
    }

    // MARK: - Phase 4: True/False Activity

    private var trueFalsePhase: some View {
        VStack(spacing: 20) {
            BirdCharacter(isSitting: true)
                .frame(width: 120, height: 120)

            VStack(spacing: 16) {
                Text("Quick Question!")
                    .font(.custom("Cinzel-Bold", size: 18))
                    .foregroundStyle(RenaissanceColors.sepiaInk)

                if case .trueFalse(let statement, _, let explanation) = hintData.activityType {
                    Text(statement)
                        .font(.custom("EBGaramond-Regular", size: 17))
                        .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 8)

                    HStack(spacing: 16) {
                        trueFalseButton(label: "True", value: true)
                        trueFalseButton(label: "False", value: false)
                    }
                    .offset(x: trueFalseShake ? -8 : 0)

                    // Show explanation after wrong answer
                    if let answer = trueFalseAnswer, !isAnswerCorrect(answer) {
                        Text(explanation)
                            .font(.custom("EBGaramond-Italic", size: 14))
                            .foregroundStyle(RenaissanceColors.errorRed.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.top, 4)
                            .transition(.opacity)
                    }
                }
            }
            .padding(24)
            .background(DialogueBubble())
        }
    }

    // MARK: - Phase 5: Hint Scroll Reveal

    private var hintScrollPhase: some View {
        VStack(spacing: 20) {
            // Scroll icon
            Image(systemName: "scroll.fill")
                .font(.system(size: 40))
                .foregroundStyle(RenaissanceColors.ochre)
                .scaleEffect(showScrollReveal ? 1 : 0.5)
                .opacity(showScrollReveal ? 1 : 0)

            VStack(spacing: 16) {
                Text("Hint Scroll")
                    .font(.custom("Cinzel-Bold", size: 20))
                    .foregroundStyle(RenaissanceColors.sepiaInk)

                Divider()
                    .background(RenaissanceColors.ochre.opacity(0.3))

                Text(hintData.detailedHint)
                    .font(.custom("EBGaramond-Regular", size: 17))
                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
                    .padding(.horizontal, 8)

                Divider()
                    .background(RenaissanceColors.ochre.opacity(0.3))

                RenaissanceButton(title: "Got it!") {
                    onDismiss()
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(RenaissanceColors.parchment)
                    .shadow(color: RenaissanceColors.goldSuccess.opacity(0.3), radius: 16, y: 4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(RenaissanceColors.goldSuccess.opacity(0.5), lineWidth: 2)
                    )
            )
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                showScrollReveal = true
            }
        }
    }

    // MARK: - Helpers

    private func hintChoiceLabel(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(color)
            Text(text)
                .font(.custom("EBGaramond-Regular", size: 16))
                .foregroundStyle(RenaissanceColors.sepiaInk)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(RenaissanceColors.stoneGray)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(RenaissanceColors.parchment)
                .shadow(color: color.opacity(0.15), radius: 3, y: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }

    private func trueFalseButton(label: String, value: Bool) -> some View {
        let isCorrect = isAnswerCorrect(value)
        let wasSelected = trueFalseAnswer == value
        let hasAnswered = trueFalseAnswer != nil

        return Button {
            guard trueFalseAnswer == nil || !isAnswerCorrect(trueFalseAnswer!) else { return }
            if isCorrect {
                trueFalseAnswer = value
                // Advance to scroll after short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    withAnimation(.spring(response: 0.4)) {
                        phase = .hintScroll
                    }
                }
            } else {
                trueFalseAnswer = value
                // Shake animation
                withAnimation(.easeInOut(duration: 0.08).repeatCount(4, autoreverses: true)) {
                    trueFalseShake = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    trueFalseShake = false
                    // Reset so they can try again
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        withAnimation { trueFalseAnswer = nil }
                    }
                }
            }
        } label: {
            Text(label)
                .font(.custom("Cinzel-Bold", size: 16))
                .foregroundStyle(
                    hasAnswered && wasSelected
                        ? .white
                        : RenaissanceColors.sepiaInk
                )
                .frame(width: 100, height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            hasAnswered && wasSelected && isCorrect
                                ? RenaissanceColors.sageGreen
                                : hasAnswered && wasSelected && !isCorrect
                                    ? RenaissanceColors.errorRed
                                    : RenaissanceColors.ochre.opacity(0.15)
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(
                            hasAnswered && wasSelected && isCorrect
                                ? RenaissanceColors.sageGreen
                                : hasAnswered && wasSelected
                                    ? RenaissanceColors.errorRed
                                    : RenaissanceColors.ochre.opacity(0.4),
                            lineWidth: 1.5
                        )
                )
        }
        .buttonStyle(.plain)
    }

    private func isAnswerCorrect(_ answer: Bool) -> Bool {
        if case .trueFalse(_, let isTrue, _) = hintData.activityType {
            return answer == isTrue
        }
        return false
    }

    /// Deduct 3 materials from workshop inventory (1 each from most abundant)
    private func deductMaterials() {
        guard let workshop = workshopState else { return }
        let sorted = workshop.rawMaterials.sorted { $0.value > $1.value }
        var toDeduct = 3
        var icons: [String] = []
        for (material, count) in sorted where toDeduct > 0 && count > 0 {
            let take = min(count, toDeduct)
            workshop.rawMaterials[material, default: 0] -= take
            toDeduct -= take
            for _ in 0..<take {
                icons.append(material.icon)
            }
        }
        craftingMaterials = icons.map { ($0, CGFloat(0)) }
    }

    /// Animate materials floating up and dissolving, then show scroll
    private func startCraftingAnimation() {
        // Float materials upward
        for i in craftingMaterials.indices {
            let delay = Double(i) * 0.3
            withAnimation(.easeIn(duration: 0.8).delay(delay)) {
                craftingMaterials[i].1 = -100
            }
        }
        // Show scroll after materials dissolve
        let totalDelay = Double(craftingMaterials.count) * 0.3 + 0.5
        DispatchQueue.main.asyncAfter(deadline: .now() + totalDelay) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                showScrollReveal = true
            }
            // Auto-advance to hint scroll phase
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation(.spring(response: 0.4)) {
                    phase = .hintScroll
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("Hint Riddle") {
    HintOverlayView(
        hintData: HintData(
            riddle: "When fire-born powder meets the river's gift, a new stone rises...",
            detailedHint: "Metal oxides react with water to form hydroxides. Calcium is the metal here.",
            activityType: .trueFalse(
                statement: "Quicklime (CaO) is cold when mixed with water.",
                isTrue: false,
                explanation: "The reaction is exothermic — it releases enough heat to boil water!"
            )
        ),
        workshopState: WorkshopState(),
        onDismiss: {}
    )
}
