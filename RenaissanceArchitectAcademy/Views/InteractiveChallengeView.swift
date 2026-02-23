import SwiftUI

/// Interactive Challenge View - Supports multiple question types
/// Combines multiple choice, drag-drop equations, and future interactive types
struct InteractiveChallengeView: View {
    let challenge: InteractiveChallenge
    var workshopState: WorkshopState? = nil
    let onComplete: (Int, Int) -> Void  // (correctAnswers, totalQuestions)
    let onDismiss: () -> Void

    @State private var currentQuestionIndex = 0
    @State private var correctAnswers = 0
    @State private var showIntro = true
    @State private var hasAnsweredCurrent = false
    @State private var currentAnswerCorrect = false

    // Multiple choice state
    @State private var selectedAnswer: Int? = nil

    // Hint system state
    @State private var showHintOverlay = false
    @State private var hintsUsed: Set<UUID> = []

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    // Adaptive sizing
    private var isLargeScreen: Bool { horizontalSizeClass == .regular }
    private var cardMaxWidth: CGFloat { isLargeScreen ? 700 : .infinity }
    private var titleSize: CGFloat { isLargeScreen ? 32 : 24 }
    private var bodySize: CGFloat { isLargeScreen ? 18 : 16 }

    private var currentQuestion: InteractiveQuestion? {
        guard currentQuestionIndex < challenge.questions.count else { return nil }
        return challenge.questions[currentQuestionIndex]
    }

    private var scorePercentage: Double {
        guard challenge.questions.count > 0 else { return 0 }
        return Double(correctAnswers) / Double(challenge.questions.count)
    }

    var body: some View {
        ZStack {
            // Parchment background
            RenaissanceColors.parchment
                .ignoresSafeArea()

            if showIntro {
                introView
            } else if currentQuestionIndex >= challenge.questions.count {
                completionView
            } else if let question = currentQuestion {
                questionView(question)
            }

            // Hint overlay (shown on top of everything)
            if showHintOverlay, let question = currentQuestion, let hintData = question.hint {
                HintOverlayView(
                    hintData: hintData,
                    workshopState: workshopState,
                    onDismiss: {
                        hintsUsed.insert(question.id)
                        withAnimation(.spring(response: 0.3)) {
                            showHintOverlay = false
                        }
                    }
                )
                .transition(.opacity)
            }
        }
    }

    // MARK: - Introduction View

    private var introView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text(challenge.buildingName)
                        .font(.custom("Cinzel-Regular", size: titleSize, relativeTo: .title))
                        .foregroundStyle(RenaissanceColors.sepiaInk)

                    Text("Interactive Challenge")
                        .font(.custom("Mulish-Light", size: isLargeScreen ? 22 : 18, relativeTo: .title2))
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                }

                decorativeDivider

                // Introduction text
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "scroll.fill")
                            .foregroundStyle(RenaissanceColors.sepiaInk)
                        Text("Historical Context")
                            .font(.custom("Cinzel-Regular", size: 14, relativeTo: .caption))
                            .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))
                    }

                    Text(challenge.introduction)
                        .font(.custom("Mulish-Light", size: bodySize, relativeTo: .body))
                        .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.9))
                        .lineSpacing(6)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(RenaissanceColors.ochre.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(RenaissanceColors.ochre.opacity(0.3), lineWidth: 1)
                        )
                )

                // Question count info
                HStack(spacing: 20) {
                    infoCard(icon: "questionmark.circle", title: "\(challenge.questions.count)", subtitle: "Questions")

                    // Count interactive questions (drag-drop and flow drawing)
                    let interactiveCount = challenge.questions.filter {
                        switch $0.questionType {
                        case .dragDropEquation, .hydraulicsFlow:
                            return true
                        case .multipleChoice:
                            return false
                        }
                    }.count

                    infoCard(icon: "hand.draw", title: "\(interactiveCount)", subtitle: "Interactive")
                }

                Spacer(minLength: 40)

                RenaissanceButton(title: "Begin Challenge") {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showIntro = false
                    }
                }

                RenaissanceSecondaryButton(title: "Go Back") {
                    onDismiss()
                }
            }
            .padding(isLargeScreen ? 40 : 24)
            .frame(maxWidth: cardMaxWidth)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Question View (dispatches to correct type)

    private func questionView(_ question: InteractiveQuestion) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                // Progress header
                progressHeader

                // Science badge
                ScienceBadge(science: question.science, isLargeScreen: isLargeScreen)

                // Question text
                Text(question.questionText)
                    .font(.custom("Mulish-Light", size: isLargeScreen ? 22 : 18, relativeTo: .title3))
                    .foregroundStyle(RenaissanceColors.sepiaInk)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // Question content based on type
                switch question.questionType {
                case .multipleChoice:
                    multipleChoiceContent(question)

                case .dragDropEquation(let data):
                    dragDropContent(data: data, question: question)

                case .hydraulicsFlow(let data):
                    hydraulicsFlowContent(data: data, question: question)
                }

                // Show explanation after answering
                if hasAnsweredCurrent {
                    explanationCard(question)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.top, 8)
                }

                Spacer(minLength: 20)

                // Next button
                if hasAnsweredCurrent {
                    RenaissanceButton(
                        title: currentQuestionIndex < challenge.questions.count - 1
                            ? "Next Question"
                            : "See Results"
                    ) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentQuestionIndex += 1
                            hasAnsweredCurrent = false
                            selectedAnswer = nil
                            currentAnswerCorrect = false
                        }
                    }
                }
            }
            .padding(isLargeScreen ? 40 : 24)
            .frame(maxWidth: cardMaxWidth)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Multiple Choice Content

    private func multipleChoiceContent(_ question: InteractiveQuestion) -> some View {
        VStack(spacing: 12) {
            ForEach(Array(question.options.enumerated()), id: \.offset) { index, option in
                answerButton(
                    text: option,
                    index: index,
                    isCorrect: index == question.correctAnswerIndex
                )
            }
        }
        .padding(.horizontal)
    }

    private func answerButton(text: String, index: Int, isCorrect: Bool) -> some View {
        let isSelected = selectedAnswer == index
        let showResult = hasAnsweredCurrent

        return Button {
            guard !hasAnsweredCurrent else { return }

            withAnimation(.easeInOut(duration: 0.2)) {
                selectedAnswer = index
                hasAnsweredCurrent = true
                currentAnswerCorrect = isCorrect

                if isCorrect {
                    correctAnswers += 1
                }
            }
        } label: {
            HStack {
                // Letter badge (A, B, C, D)
                Text(String(UnicodeScalar(65 + index)!))
                    .font(.custom("Cinzel-Regular", size: 16, relativeTo: .body))
                    .foregroundStyle(
                        showResult && isCorrect ? .white :
                        showResult && isSelected && !isCorrect ? .white :
                        RenaissanceColors.sepiaInk
                    )
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(
                                showResult && isCorrect ? RenaissanceColors.sageGreen :
                                showResult && isSelected && !isCorrect ? RenaissanceColors.errorRed :
                                RenaissanceColors.ochre.opacity(0.2)
                            )
                    )

                Text(text)
                    .font(.custom("Mulish-Light", size: isLargeScreen ? 17 : 15, relativeTo: .body))
                    .foregroundStyle(RenaissanceColors.sepiaInk)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if showResult && (isCorrect || isSelected) {
                    Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundStyle(isCorrect ? RenaissanceColors.sageGreen : RenaissanceColors.errorRed)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        showResult && isCorrect ? RenaissanceColors.sageGreen.opacity(0.15) :
                        showResult && isSelected && !isCorrect ? RenaissanceColors.errorRed.opacity(0.15) :
                        isSelected ? RenaissanceColors.ochre.opacity(0.15) :
                        RenaissanceColors.parchment
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                showResult && isCorrect ? RenaissanceColors.sageGreen :
                                showResult && isSelected && !isCorrect ? RenaissanceColors.errorRed :
                                isSelected ? RenaissanceColors.ochre :
                                RenaissanceColors.ochre.opacity(0.3),
                                lineWidth: isSelected || (showResult && isCorrect) ? 2 : 1
                            )
                    )
            )
        }
        .buttonStyle(.plain)
        .disabled(hasAnsweredCurrent)
    }

    // MARK: - Drag & Drop Content

    private func dragDropContent(data: DragDropEquationData, question: InteractiveQuestion) -> some View {
        DragDropEquationView(data: data) { isCorrect in
            withAnimation(.easeInOut(duration: 0.3)) {
                hasAnsweredCurrent = true
                currentAnswerCorrect = isCorrect
                if isCorrect {
                    correctAnswers += 1
                }
            }
        }
    }

    // MARK: - Hydraulics Flow Content

    private func hydraulicsFlowContent(data: HydraulicsFlowData, question: InteractiveQuestion) -> some View {
        HydraulicsFlowView(data: data) { isCorrect in
            withAnimation(.easeInOut(duration: 0.3)) {
                hasAnsweredCurrent = true
                currentAnswerCorrect = isCorrect
                if isCorrect {
                    correctAnswers += 1
                }
            }
        }
    }

    // MARK: - Completion View

    private var completionView: some View {
        VStack(spacing: 24) {
            // Success seal
            ZStack {
                Circle()
                    .fill(scorePercentage >= 0.7
                          ? RenaissanceColors.goldSuccess
                          : RenaissanceColors.terracotta)
                    .frame(width: 100, height: 100)
                    .shadow(color: RenaissanceColors.goldSuccess.opacity(0.4), radius: 20)

                Image(systemName: scorePercentage >= 0.7 ? "checkmark" : "arrow.clockwise")
                    .font(.custom("Mulish-Bold", size: 44, relativeTo: .title3))
                    .foregroundStyle(.white)
            }

            Text("Challenge Complete!")
                .font(.custom("Cinzel-Regular", size: titleSize, relativeTo: .title))
                .foregroundStyle(RenaissanceColors.sepiaInk)

            VStack(spacing: 8) {
                Text("\(correctAnswers) of \(challenge.questions.count)")
                    .font(.custom("Cinzel-Regular", size: 36, relativeTo: .largeTitle))
                    .foregroundStyle(RenaissanceColors.sepiaInk)

                Text("Questions Correct")
                    .font(.custom("Mulish-Light", size: 18, relativeTo: .body))
                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))
            }

            decorativeDivider

            Text(feedbackMessage)
                .font(.custom("Mulish-Light", size: bodySize, relativeTo: .body))
                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer(minLength: 40)

            RenaissanceButton(
                title: scorePercentage >= 0.7 ? "Claim Your Building" : "Try Again"
            ) {
                if scorePercentage >= 0.7 {
                    onComplete(correctAnswers, challenge.questions.count)
                } else {
                    // Reset
                    withAnimation {
                        currentQuestionIndex = 0
                        correctAnswers = 0
                        hasAnsweredCurrent = false
                        selectedAnswer = nil
                        showIntro = true
                    }
                }
            }

            if scorePercentage >= 0.7 {
                RenaissanceSecondaryButton(title: "Review Answers") {
                    withAnimation {
                        currentQuestionIndex = 0
                        correctAnswers = 0
                        hasAnsweredCurrent = false
                        selectedAnswer = nil
                        showIntro = false
                    }
                }
            }
        }
        .padding(isLargeScreen ? 40 : 24)
        .frame(maxWidth: cardMaxWidth)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Components

    private var progressHeader: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Question \(currentQuestionIndex + 1) of \(challenge.questions.count)")
                    .font(.custom("Cinzel-Regular", size: 14, relativeTo: .caption))
                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))

                Spacer()

                // Hint button (visible when hint exists and question not yet answered)
                if let question = currentQuestion, question.hint != nil, !hasAnsweredCurrent {
                    let hintAlreadyUsed = hintsUsed.contains(question.id)
                    Button {
                        if hintAlreadyUsed {
                            // Re-show just the scroll directly
                            showHintOverlay = true
                        } else {
                            withAnimation(.spring(response: 0.3)) {
                                showHintOverlay = true
                            }
                        }
                    } label: {
                        Image(systemName: hintAlreadyUsed ? "lightbulb.fill" : "lightbulb")
                            .font(.custom("Mulish-Light", size: 18, relativeTo: .body))
                            .foregroundStyle(hintAlreadyUsed ? RenaissanceColors.goldSuccess : RenaissanceColors.sepiaInk)
                            .frame(width: 32, height: 32)
                            .background(
                                Circle()
                                    .fill(RenaissanceColors.ochre.opacity(0.15))
                            )
                    }
                    .buttonStyle(.plain)
                }

                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(RenaissanceColors.sageGreen)
                    Text("\(correctAnswers)")
                        .font(.custom("Mulish-Light", size: 17, relativeTo: .body))
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                }
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(RenaissanceColors.ochre.opacity(0.2))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(RenaissanceColors.renaissanceBlue)
                        .frame(
                            width: geo.size.width * CGFloat(currentQuestionIndex + 1) / CGFloat(challenge.questions.count),
                            height: 8
                        )
                }
            }
            .frame(height: 8)
        }
    }

    private func explanationCard(_ question: InteractiveQuestion) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Result indicator
            HStack {
                Image(systemName: currentAnswerCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundStyle(currentAnswerCorrect ? RenaissanceColors.sageGreen : RenaissanceColors.errorRed)
                Text(currentAnswerCorrect ? "Correct!" : "Not quite...")
                    .font(.custom("Cinzel-Regular", size: 16, relativeTo: .headline))
                    .foregroundStyle(currentAnswerCorrect ? RenaissanceColors.sageGreen : RenaissanceColors.errorRed)
            }

            // Explanation
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .foregroundStyle(RenaissanceColors.highlightAmber)
                    Text("Explanation")
                        .font(.custom("Cinzel-Regular", size: 14, relativeTo: .caption))
                        .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))
                }

                Text(question.explanation)
                    .font(.custom("Mulish-Light", size: bodySize, relativeTo: .body))
                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.9))
                    .lineSpacing(4)
            }

            Divider()
                .background(RenaissanceColors.ochre.opacity(0.3))

            // Fun fact
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "sparkles")
                        .foregroundStyle(RenaissanceColors.goldSuccess)
                    Text("Did You Know?")
                        .font(.custom("Cinzel-Regular", size: 14, relativeTo: .caption))
                        .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))
                }

                Text(question.funFact)
                    .font(.custom("Mulish-Light", size: bodySize, relativeTo: .body))
                    .foregroundStyle(RenaissanceColors.sepiaInk)
                    .lineSpacing(4)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(RenaissanceColors.ochre.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(RenaissanceColors.ochre.opacity(0.25), lineWidth: 1)
                )
        )
    }

    private var decorativeDivider: some View {
        HStack(spacing: 12) {
            Rectangle()
                .fill(RenaissanceColors.ochre.opacity(0.4))
                .frame(height: 1)
            Image(systemName: "leaf.fill")
                .font(.caption)
                .foregroundStyle(RenaissanceColors.sageGreen)
            Rectangle()
                .fill(RenaissanceColors.ochre.opacity(0.4))
                .frame(height: 1)
        }
        .padding(.horizontal)
    }

    private func infoCard(icon: String, title: String, subtitle: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(RenaissanceColors.sepiaInk)
            Text(title)
                .font(.custom("Cinzel-Regular", size: 24, relativeTo: .title2))
                .foregroundStyle(RenaissanceColors.sepiaInk)
            Text(subtitle)
                .font(.custom("Mulish-Light", size: 14, relativeTo: .caption))
                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))
        }
        .padding()
        .frame(minWidth: 100)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(RenaissanceColors.ochre.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(RenaissanceColors.ochre.opacity(0.3), lineWidth: 1)
                )
        )
    }

    private var feedbackMessage: String {
        if scorePercentage >= 0.9 {
            return "Magnificent! You have the mind of a true Renaissance master. Leonardo himself would be impressed!"
        } else if scorePercentage >= 0.7 {
            return "Well done, young architect! You've proven your knowledge and may proceed to build."
        } else if scorePercentage >= 0.5 {
            return "A worthy attempt! Review the sciences and try again."
        } else {
            return "The path to mastery requires study. Return to your scrolls and challenge yourself again!"
        }
    }
}

// MARK: - Preview

#Preview("Interactive Roman Baths") {
    InteractiveChallengeView(
        challenge: ChallengeContent.romanBathsInteractive,
        workshopState: WorkshopState(),
        onComplete: { correct, total in
            print("Completed: \(correct)/\(total)")
        },
        onDismiss: {}
    )
}
