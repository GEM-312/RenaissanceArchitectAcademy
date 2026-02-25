import SwiftUI

/// Challenge View - Interactive quiz with Leonardo's Notebook aesthetic
/// Students answer questions, see explanations, and learn fun facts
struct ChallengeView: View {
    let challenge: Challenge
    let onComplete: (Int, Int) -> Void  // (correctAnswers, totalQuestions)
    let onDismiss: () -> Void

    @State private var progress = ChallengeProgress()
    @State private var showIntro = true
    @State private var selectedAnswer: Int? = nil
    @State private var animateCorrect = false
    @State private var animateWrong = false

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    // Adaptive sizing
    private var isLargeScreen: Bool { horizontalSizeClass == .regular }
    private var cardMaxWidth: CGFloat { isLargeScreen ? 700 : .infinity }
    private var titleSize: CGFloat { isLargeScreen ? 32 : 24 }
    private var bodySize: CGFloat { isLargeScreen ? 18 : 16 }

    private var currentQuestion: ChallengeQuestion? {
        guard progress.currentQuestionIndex < challenge.questions.count else { return nil }
        return challenge.questions[progress.currentQuestionIndex]
    }

    var body: some View {
        ZStack {
            // Parchment background
            RenaissanceColors.parchment
                .ignoresSafeArea()

            if showIntro {
                introView
            } else if progress.currentQuestionIndex >= challenge.questions.count {
                completionView
            } else if let question = currentQuestion {
                questionView(question)
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

                    Text("Challenge")
                        .font(.custom("Mulish-Light", size: isLargeScreen ? 22 : 18, relativeTo: .title2))
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                }

                // Decorative divider
                decorativeDivider

                // Introduction text
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "scroll.fill")
                            .foregroundStyle(RenaissanceColors.sepiaInk)
                        Text("Historical Context")
                            .font(.custom("EBGaramond-Regular", size: 16, relativeTo: .caption))
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
                        .borderCard(radius: 8)
                )

                // Question count info
                HStack(spacing: 20) {
                    infoCard(
                        icon: "questionmark.circle",
                        title: "\(challenge.questions.count)",
                        subtitle: "Questions"
                    )

                    infoCard(
                        icon: "books.vertical",
                        title: "\(Set(challenge.questions.map(\.science)).count)",
                        subtitle: "Sciences"
                    )
                }

                Spacer(minLength: 40)

                // Start button
                RenaissanceButton(title: "Begin Challenge") {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showIntro = false
                        progress.totalQuestions = challenge.questions.count
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

    // MARK: - Question View

    private func questionView(_ question: ChallengeQuestion) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                // Progress header
                progressHeader

                // Science badge
                ScienceBadge(science: question.science, isLargeScreen: isLargeScreen)

                // Question
                Text(question.questionText)
                    .font(.custom("Mulish-Light", size: isLargeScreen ? 22 : 18, relativeTo: .title3))
                    .foregroundStyle(RenaissanceColors.sepiaInk)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // Answer options
                VStack(spacing: 12) {
                    ForEach(Array(question.options.enumerated()), id: \.offset) { index, option in
                        answerButton(
                            text: option,
                            index: index,
                            isCorrect: index == question.correctAnswerIndex,
                            question: question
                        )
                    }
                }
                .padding(.horizontal)

                // Show explanation after answering
                if progress.hasAnswered {
                    explanationCard(question)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                Spacer(minLength: 20)

                // Navigation buttons
                if progress.hasAnswered {
                    RenaissanceButton(
                        title: progress.currentQuestionIndex < challenge.questions.count - 1
                            ? "Next Question"
                            : "See Results"
                    ) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            progress.currentQuestionIndex += 1
                            progress.hasAnswered = false
                            selectedAnswer = nil
                            animateCorrect = false
                            animateWrong = false
                        }
                    }
                }
            }
            .padding(isLargeScreen ? 40 : 24)
            .frame(maxWidth: cardMaxWidth)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Completion View

    private var completionView: some View {
        VStack(spacing: 24) {
            // Wax seal success indicator
            ZStack {
                Circle()
                    .fill(progress.scorePercentage >= 0.7
                          ? RenaissanceColors.goldSuccess
                          : RenaissanceColors.terracotta)
                    .frame(width: 100, height: 100)

                Image(systemName: progress.scorePercentage >= 0.7 ? "checkmark" : "arrow.clockwise")
                    .font(.custom("Mulish-Bold", size: 44, relativeTo: .title3))
                    .foregroundStyle(.white)
            }

            Text("Challenge Complete!")
                .font(.custom("Cinzel-Regular", size: titleSize, relativeTo: .title))
                .foregroundStyle(RenaissanceColors.sepiaInk)

            // Score
            VStack(spacing: 8) {
                Text("\(progress.correctAnswers) of \(progress.totalQuestions)")
                    .font(.custom("Cinzel-Regular", size: 36, relativeTo: .largeTitle))
                    .foregroundStyle(RenaissanceColors.sepiaInk)

                Text("Questions Correct")
                    .font(.custom("Mulish-Light", size: 18, relativeTo: .body))
                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))
            }

            decorativeDivider

            // Feedback message
            Text(feedbackMessage)
                .font(.custom("Mulish-Light", size: bodySize, relativeTo: .body))
                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer(minLength: 40)

            // Complete button
            RenaissanceButton(
                title: progress.scorePercentage >= 0.7 ? "Claim Your Building" : "Try Again"
            ) {
                if progress.scorePercentage >= 0.7 {
                    onComplete(progress.correctAnswers, progress.totalQuestions)
                } else {
                    // Reset and try again
                    withAnimation {
                        progress = ChallengeProgress()
                        progress.totalQuestions = challenge.questions.count
                        showIntro = true
                    }
                }
            }

            if progress.scorePercentage >= 0.7 {
                RenaissanceSecondaryButton(title: "Review Answers") {
                    withAnimation {
                        progress = ChallengeProgress()
                        progress.totalQuestions = challenge.questions.count
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
                Text("Question \(progress.currentQuestionIndex + 1) of \(challenge.questions.count)")
                    .font(.custom("EBGaramond-Regular", size: 16, relativeTo: .caption))
                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))

                Spacer()

                // Score so far
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(RenaissanceColors.sageGreen)
                    Text("\(progress.correctAnswers)")
                        .font(.custom("Mulish-Light", size: 17, relativeTo: .body))
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                }
            }

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(RenaissanceColors.ochre.opacity(0.2))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(RenaissanceColors.renaissanceBlue)
                        .frame(
                            width: geo.size.width * CGFloat(progress.currentQuestionIndex + 1) / CGFloat(challenge.questions.count),
                            height: 8
                        )
                }
            }
            .frame(height: 8)
        }
    }

    private func answerButton(text: String, index: Int, isCorrect: Bool, question: ChallengeQuestion) -> some View {
        let isSelected = selectedAnswer == index
        let showResult = progress.hasAnswered

        return Button {
            guard !progress.hasAnswered else { return }

            withAnimation(.easeInOut(duration: 0.2)) {
                selectedAnswer = index
                progress.hasAnswered = true

                if isCorrect {
                    progress.correctAnswers += 1
                    animateCorrect = true
                } else {
                    animateWrong = true
                }
            }
        } label: {
            HStack {
                // Letter badge (A, B, C, D)
                Text(String(UnicodeScalar(65 + index)!))
                    .font(.custom("EBGaramond-SemiBold", size: 18, relativeTo: .body))
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

                // Result indicator
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
        .disabled(progress.hasAnswered)
    }

    private func explanationCard(_ question: ChallengeQuestion) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Explanation
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .foregroundStyle(RenaissanceColors.highlightAmber)
                    Text("Explanation")
                        .font(.custom("EBGaramond-Regular", size: 16, relativeTo: .caption))
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
                        .font(.custom("EBGaramond-Regular", size: 16, relativeTo: .caption))
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
                .borderCard(radius: 12)
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
                .borderCard(radius: 8)
        )
    }

    private var feedbackMessage: String {
        let percentage = progress.scorePercentage
        if percentage >= 0.9 {
            return "Magnificent! You have the mind of a true Renaissance master. Leonardo himself would be impressed!"
        } else if percentage >= 0.7 {
            return "Well done, young architect! You've proven your knowledge and may proceed to build. The Roman engineers would be proud."
        } else if percentage >= 0.5 {
            return "A worthy attempt! Review the sciences and try again. Even the great builders made mistakes before achieving perfection."
        } else {
            return "The path to mastery requires study. Return to your scrolls, review the sciences, and challenge yourself again!"
        }
    }
}

#Preview("Roman Baths Challenge") {
    ChallengeView(
        challenge: ChallengeContent.romanBaths,
        onComplete: { correct, total in
            print("Completed: \(correct)/\(total)")
        },
        onDismiss: {}
    )
}
