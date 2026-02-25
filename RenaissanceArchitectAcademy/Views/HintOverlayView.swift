import SwiftUI

/// 5-phase hint overlay: riddle → choose method → craft/earn → hint scroll → done
/// Visual: phase progress bar at top, mascot, content card, action button
struct HintOverlayView: View {
    let hintData: HintData
    let workshopState: WorkshopState?
    let onDismiss: () -> Void

    enum Phase: Int, CaseIterable {
        case riddle = 1
        case chooseMethod = 2
        case crafting = 3   // also used for trueFalse
        case hintScroll = 4
        case done = 5
    }

    @State private var phase: Phase = .riddle
    @State private var showContent = false
    @State private var trueFalseAnswer: Bool? = nil
    @State private var trueFalseShake = false
    @State private var craftingMaterials: [(String, CGFloat)] = []
    @State private var showScrollReveal = false
    @State private var phaseDirection: Edge = .trailing

    // True when user chose "Earn by Activity" (true/false path)
    @State private var isTrueFalsePath = false

    // Transaction display
    @State private var transactionMaterials: [(Material, Int)] = []
    @State private var wasEarnPath: Bool = false
    // Pre-generated earn reward (shown on activity card, awarded on correct answer)
    @State private var pendingEarnReward: [(Material, Int)] = []

    private var totalMaterials: Int {
        workshopState?.rawMaterials.values.reduce(0, +) ?? 0
    }

    /// Which step number is active (for the progress bar)
    private var activeStep: Int {
        switch phase {
        case .riddle: return 1
        case .chooseMethod: return 2
        case .crafting: return 3
        case .hintScroll: return 4
        case .done: return 5
        }
    }

    var body: some View {
        ZStack {
            // Dimmed background
            RenaissanceColors.overlayDimming
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            VStack(spacing: 0) {
                // Phase progress bar
                phaseProgressBar
                    .padding(.top, 40)
                    .padding(.bottom, 20)

                // Mascot
                mascotSection
                    .padding(.bottom, 12)

                // Phase content card
                phaseContent
                    .padding(.horizontal, 32)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                showContent = true
            }
        }
    }

    // MARK: - Phase Progress Bar

    private var phaseProgressBar: some View {
        let labels = ["Riddle", "Choose", isTrueFalsePath ? "Earn" : "Craft", "Hint", "Done"]

        return HStack(spacing: 0) {
            ForEach(1...5, id: \.self) { step in
                if step > 1 {
                    // Connecting line
                    Rectangle()
                        .fill(step <= activeStep ? RenaissanceColors.sageGreen : RenaissanceColors.stoneGray.opacity(0.3))
                        .frame(height: 2)
                        .animation(.easeInOut(duration: 0.3), value: activeStep)
                }

                // Step circle + label
                VStack(spacing: 4) {
                    ZStack {
                        Circle()
                            .fill(
                                step < activeStep
                                    ? RenaissanceColors.sageGreen
                                    : step == activeStep
                                        ? RenaissanceColors.goldSuccess
                                        : Color.clear
                            )
                            .frame(width: 32, height: 32)

                        Circle()
                            .stroke(
                                step < activeStep
                                    ? RenaissanceColors.sageGreen
                                    : step == activeStep
                                        ? RenaissanceColors.goldSuccess
                                        : RenaissanceColors.stoneGray.opacity(0.4),
                                lineWidth: 2
                            )
                            .frame(width: 32, height: 32)

                        if step < activeStep {
                            // Completed: checkmark
                            Image(systemName: "checkmark")
                                .font(.custom("EBGaramond-Bold", size: 14, relativeTo: .footnote))
                                .foregroundStyle(.white)
                        } else {
                            // Number
                            Text("\(step)")
                                .font(.custom("EBGaramond-Regular", size: 15))
                                .foregroundStyle(
                                    step == activeStep ? .white : RenaissanceColors.sepiaInk.opacity(0.6)
                                )
                        }
                    }
                    .scaleEffect(step == activeStep ? 1.15 : 1.0)
                    .animation(.spring(response: 0.4, dampingFraction: 0.6), value: activeStep)

                    Text(labels[step - 1])
                        .font(.custom("EBGaramond-Regular", size: 10))
                        .foregroundStyle(
                            step == activeStep
                                ? RenaissanceColors.goldSuccess
                                : step < activeStep
                                    ? RenaissanceColors.sageGreen
                                    : RenaissanceColors.sepiaInk.opacity(0.5)
                        )
                }
            }
        }
        .padding(.horizontal, 40)
    }

    // MARK: - Mascot Section

    private var mascotSection: some View {
        BirdCharacter(isSitting: true)
            .frame(width: 140, height: 140)
            .scaleEffect(showContent ? 1 : 0.3)
            .opacity(showContent ? 1 : 0)
    }

    // MARK: - Phase Content (with slide transition)

    @ViewBuilder
    private var phaseContent: some View {
        Group {
            switch phase {
            case .riddle:
                riddleCard
            case .chooseMethod:
                chooseMethodCard
            case .crafting:
                if isTrueFalsePath {
                    trueFalseCard
                } else {
                    craftingCard
                }
            case .hintScroll:
                hintScrollCard
            case .done:
                EmptyView()
            }
        }
        .transition(.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        ))
        .id(phase)
    }

    // MARK: - Phase 1: Riddle Card

    private var riddleCard: some View {
        VStack(spacing: 16) {
            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .foregroundStyle(RenaissanceColors.goldSuccess)
                Text("A Riddle for You...")
                    .font(.custom("EBGaramond-SemiBold", size: 20))
                    .foregroundStyle(RenaissanceColors.sepiaInk)
            }

            Text(hintData.riddle)
                .font(.custom("EBGaramond-Regular", size: 18))
                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.9))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 8)

            Divider()
                .background(RenaissanceColors.ochre.opacity(0.3))

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

    // MARK: - Phase 2: Choose Method Card

    private var chooseMethodCard: some View {
        VStack(spacing: 16) {
            Text("How would you like your hint?")
                .font(.custom("EBGaramond-SemiBold", size: 20))
                .foregroundStyle(RenaissanceColors.sepiaInk)

            // Craft option
            Button {
                withAnimation(.spring(response: 0.4)) {
                    isTrueFalsePath = false
                    deductMaterials()
                    phase = .crafting
                }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "hammer.fill")
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Craft a Hint Scroll")
                            .font(.custom("EBGaramond-Regular", size: 17, relativeTo: .body))
                            .foregroundStyle(RenaissanceColors.sepiaInk)
                        Text("Costs 2 raw materials")
                            .font(.custom("EBGaramond-Regular", size: 13))
                            .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.6))
                    }
                    Spacer()
                    if totalMaterials >= 2 {
                        Image(systemName: "chevron.right")
                            .foregroundStyle(RenaissanceColors.sepiaInk)
                    } else {
                        Text("Not enough")
                            .font(.custom("EBGaramond-Regular", size: 12))
                            .foregroundStyle(RenaissanceColors.errorRed)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(totalMaterials >= 2 ? RenaissanceColors.parchment : RenaissanceColors.parchment.opacity(0.5))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(RenaissanceColors.ochre.opacity(0.3), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            .disabled(totalMaterials < 2)
            .opacity(totalMaterials >= 2 ? 1 : 0.6)

            // Earn option
            Button {
                withAnimation(.spring(response: 0.4)) {
                    isTrueFalsePath = true
                    generatePendingReward()
                    phase = .crafting
                }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "brain.head.profile")
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Earn by Activity")
                            .font(.custom("EBGaramond-Regular", size: 17, relativeTo: .body))
                            .foregroundStyle(RenaissanceColors.sepiaInk)
                        Text("Answer correctly to earn 3 materials")
                            .font(.custom("EBGaramond-Regular", size: 13))
                            .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.6))
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(RenaissanceColors.parchment)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(RenaissanceColors.ochre.opacity(0.3), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
        .padding(24)
        .background(DialogueBubble())
    }

    // MARK: - Phase 3a: Crafting Animation Card

    private var craftingCard: some View {
        VStack(spacing: 24) {
            Text("Crafting Hint Scroll...")
                .font(.custom("EBGaramond-SemiBold", size: 22))
                .foregroundStyle(RenaissanceColors.sepiaInk)

            ZStack {
                ForEach(Array(craftingMaterials.enumerated()), id: \.offset) { index, item in
                    Text(item.0)
                        .font(.custom("EBGaramond-Regular", size: 36, relativeTo: .title3))
                        .offset(y: item.1)
                        .opacity(item.1 < -80 ? 0 : 1)
                }

                Image(systemName: "scroll.fill")
                    .font(.custom("EBGaramond-Regular", size: 48, relativeTo: .title3))
                    .foregroundStyle(RenaissanceColors.sepiaInk)
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

    // MARK: - Phase 3b: True/False Activity Card

    private var trueFalseCard: some View {
        VStack(spacing: 16) {
            Text("Quick Question!")
                .font(.custom("EBGaramond-SemiBold", size: 20))
                .foregroundStyle(RenaissanceColors.sepiaInk)

            if case .trueFalse(let statement, _, let explanation) = hintData.activityType {
                Text(statement)
                    .font(.custom("EBGaramond-Regular", size: 17, relativeTo: .body))
                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 8)

                // Reward preview
                if !pendingEarnReward.isEmpty {
                    HStack(spacing: 4) {
                        Text("Reward:")
                            .font(.custom("EBGaramond-Regular", size: 14))
                            .foregroundStyle(RenaissanceColors.sepiaInk)
                        ForEach(pendingEarnReward, id: \.0) { material, count in
                            HStack(spacing: 2) {
                                Text(material.icon)
                                    .font(.custom("EBGaramond-Regular", size: 18, relativeTo: .body))
                                Text("×\(count)")
                                    .font(.custom("EBGaramond-Regular", size: 15))
                                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }

                HStack(spacing: 16) {
                    trueFalseButton(label: "True", value: true)
                    trueFalseButton(label: "False", value: false)
                }
                .offset(x: trueFalseShake ? -8 : 0)

                if let answer = trueFalseAnswer, !isAnswerCorrect(answer) {
                    Text(explanation)
                        .font(.custom("EBGaramond-Regular", size: 14))
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

    // MARK: - Phase 4: Hint Scroll Reveal Card

    private var hintScrollCard: some View {
        VStack(spacing: 20) {
            Image(systemName: "scroll.fill")
                .font(.custom("EBGaramond-Regular", size: 40, relativeTo: .title3))
                .foregroundStyle(RenaissanceColors.sepiaInk)
                .scaleEffect(showScrollReveal ? 1 : 0.5)
                .opacity(showScrollReveal ? 1 : 0)

            VStack(spacing: 16) {
                Text("Hint Scroll")
                    .font(.custom("EBGaramond-SemiBold", size: 22))
                    .foregroundStyle(RenaissanceColors.sepiaInk)

                Divider()
                    .background(RenaissanceColors.ochre.opacity(0.3))

                Text(hintData.detailedHint)
                    .font(.custom("EBGaramond-Regular", size: 17, relativeTo: .body))
                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
                    .padding(.horizontal, 8)

                // Transaction display
                if !transactionMaterials.isEmpty {
                    Divider()
                        .background(RenaissanceColors.ochre.opacity(0.3))

                    VStack(spacing: 6) {
                        Text("You spent:")
                            .font(.custom("EBGaramond-Regular", size: 14))
                            .foregroundStyle(RenaissanceColors.sepiaInk)

                        HStack(spacing: 12) {
                            ForEach(transactionMaterials, id: \.0) { material, count in
                                HStack(spacing: 4) {
                                    Text(material.icon)
                                        .font(.custom("EBGaramond-Regular", size: 20, relativeTo: .title3))
                                    Text("×\(count)")
                                        .font(.custom("EBGaramond-Regular", size: 16))
                                        .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.8))
                                }
                            }
                        }
                    }
                }

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
                .font(.custom("EBGaramond-Regular", size: 16, relativeTo: .subheadline))
                .foregroundStyle(RenaissanceColors.sepiaInk)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(RenaissanceColors.sepiaInk)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(RenaissanceColors.parchment)
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
                awardEarnMaterials()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    withAnimation(.spring(response: 0.4)) {
                        phase = .hintScroll
                    }
                }
            } else {
                trueFalseAnswer = value
                withAnimation(.easeInOut(duration: 0.08).repeatCount(4, autoreverses: true)) {
                    trueFalseShake = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    trueFalseShake = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        withAnimation { trueFalseAnswer = nil }
                    }
                }
            }
        } label: {
            Text(label)
                .font(.custom("EBGaramond-SemiBold", size: 18))
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

    /// Deduct 2 materials from workshop inventory (1 each from most abundant)
    private func deductMaterials() {
        guard let workshop = workshopState else { return }
        let sorted = workshop.rawMaterials.sorted { $0.value > $1.value }
        var toDeduct = 2
        var icons: [String] = []
        var spent: [Material: Int] = [:]
        for (material, count) in sorted where toDeduct > 0 && count > 0 {
            let take = min(count, toDeduct)
            workshop.rawMaterials[material, default: 0] -= take
            toDeduct -= take
            spent[material, default: 0] += take
            for _ in 0..<take {
                icons.append(material.icon)
            }
        }
        craftingMaterials = icons.map { ($0, CGFloat(0)) }
        transactionMaterials = spent.map { ($0.key, $0.value) }
        wasEarnPath = false
    }

    /// Pre-generate 3 random materials to show as reward on the activity card
    private func generatePendingReward() {
        let pool: [Material] = [.limestone, .sand, .water, .clay, .ironOre, .timber]
        var reward: [Material: Int] = [:]
        for _ in 0..<3 {
            let mat = pool.randomElement()!
            reward[mat, default: 0] += 1
        }
        pendingEarnReward = reward.map { ($0.key, $0.value) }
    }

    /// Award 3 earned materials, then deduct 2 to pay for the hint scroll
    private func awardEarnMaterials() {
        guard let workshop = workshopState else { return }
        // Add earned materials
        for (mat, count) in pendingEarnReward {
            workshop.rawMaterials[mat, default: 0] += count
        }
        // Deduct 2 for scroll cost (from most abundant)
        let sorted = workshop.rawMaterials.sorted { $0.value > $1.value }
        var toDeduct = 2
        var spent: [Material: Int] = [:]
        for (material, count) in sorted where toDeduct > 0 && count > 0 {
            let take = min(count, toDeduct)
            workshop.rawMaterials[material, default: 0] -= take
            toDeduct -= take
            spent[material, default: 0] += take
        }
        transactionMaterials = spent.map { ($0.key, $0.value) }
        wasEarnPath = true
    }

    /// Animate materials floating up and dissolving, then show scroll
    private func startCraftingAnimation() {
        for i in craftingMaterials.indices {
            let delay = Double(i) * 0.3
            withAnimation(.easeIn(duration: 0.8).delay(delay)) {
                craftingMaterials[i].1 = -100
            }
        }
        let totalDelay = Double(craftingMaterials.count) * 0.3 + 0.5
        DispatchQueue.main.asyncAfter(deadline: .now() + totalDelay) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                showScrollReveal = true
            }
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
