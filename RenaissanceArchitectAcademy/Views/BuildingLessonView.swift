import SwiftUI
#if os(iOS)
import PencilKit
#endif

/// Nibble-style paged interactive lesson viewer
/// Shows one section at a time with progress bar, inline quizzes,
/// fill-in-the-blanks, fun fact cards, and environment prompts
struct BuildingLessonView: View {
    let plot: BuildingPlot
    @ObservedObject var viewModel: CityViewModel
    var workshopState: WorkshopState?
    var notebookState: NotebookState? = nil
    var onNavigate: ((SidebarDestination) -> Void)?
    let onDismiss: () -> Void

    // MARK: - State

    @State private var currentIndex = 0
    @State private var hasClaimedReward = false
    // Environment navigation removed — now uses onNavigate to go to full scene

    // Quiz state
    @State private var selectedAnswer: Int? = nil
    @State private var showExplanation = false
    @State private var hintLevel: Int = 0           // 0 = no hints shown
    @State private var showScratchPad = false        // toggle scratch pad visibility
    @State private var scratchPadText: String = ""   // macOS text fallback

    // Curiosity Q&A state
    @State private var expandedCuriosityIndex: Int? = nil  // which Q is tapped open

    // Math visual state
    @State private var mathVisualStep: Int = 1  // starts at step 1 on appear

    // Fill-in-blanks state
    @State private var blankAnswers: [Int: String] = [:]  // blankIndex → word placed
    @State private var activeBlankIndex: Int? = nil
    @State private var blanksChecked = false
    @State private var frozenWordBank: [String] = []  // shuffled once, not every render

    private var lesson: BuildingLesson? {
        LessonContent.lesson(for: plot.building.name)
    }

    private var sections: [LessonSection] {
        lesson?.sections ?? []
    }

    /// Group sections into pages: inline sections attach to their preceding primary section
    /// Primary: .reading, .funFact, .question, .fillInBlanks → start a new page
    /// Inline: .curiosity, .mathVisual, .environmentPrompt → attach to previous page
    private var pages: [[LessonSection]] {
        var result: [[LessonSection]] = []
        for section in sections {
            switch section {
            case .curiosity, .mathVisual, .environmentPrompt:
                if result.isEmpty {
                    result.append([section])
                } else {
                    result[result.count - 1].append(section)
                }
            default:
                result.append([section])
            }
        }
        return result
    }

    private var progress: BuildingProgress {
        viewModel.buildingProgressMap[plot.id] ?? BuildingProgress()
    }

    private var alreadyRead: Bool {
        progress.lessonRead
    }

    /// Whether the current page is "complete" (user can advance)
    private var canContinue: Bool {
        guard currentIndex < pages.count else { return true }
        for section in pages[currentIndex] {
            switch section {
            case .reading, .funFact, .environmentPrompt, .curiosity:
                continue
            case .question:
                if !showExplanation { return false }
            case .fillInBlanks(let activity):
                if !(blanksChecked && allBlanksCorrect(activity)) { return false }
            case .mathVisual(let visual):
                if mathVisualStep < visual.totalSteps { return false }
            }
        }
        return true
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar: progress + close
                topBar

                // Content area
                if currentIndex < pages.count {
                    ScrollView {
                        VStack(spacing: 0) {
                            VStack(alignment: .leading, spacing: 20) {
                                ForEach(Array(pages[currentIndex].enumerated()), id: \.offset) { _, section in
                                    sectionView(section)
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 20)
                            .padding(.bottom, 12)

                            // Continue / Next button
                            continueButton
                                .padding(.horizontal, 24)
                                .padding(.bottom, 24)
                        }
                    }
                } else {
                    // Lesson complete
                    completionView
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(RenaissanceColors.parchment)
                    .shadow(color: .black.opacity(0.3), radius: 20, y: 10)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(RenaissanceColors.ochre.opacity(0.4), lineWidth: 2)
            )
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
        }
        .animation(.spring(response: 0.3), value: currentIndex)
        .animation(.spring(response: 0.3), value: showExplanation)
        .animation(.spring(response: 0.3), value: blanksChecked)
        .animation(.spring(response: 0.3), value: hasClaimedReward)
        .animation(.spring(response: 0.3), value: hintLevel)
        .animation(.spring(response: 0.3), value: showScratchPad)
        .onAppear {
            // Restore bookmark from previous session
            let saved = viewModel.loadLessonBookmark(for: plot.id)
            if saved > 0 && saved < pages.count {
                currentIndex = saved
            }
            freezeWordBankIfNeeded()
        }
        .onDisappear {
            // Save bookmark when leaving (unless lesson is complete)
            if currentIndex < pages.count {
                viewModel.saveLessonBookmark(for: plot.id, sectionIndex: currentIndex)
            }
        }
        // Environment navigation uses onNavigate to go to full scene (not a sheet)
    }

    // MARK: - Top Bar

    private var topBar: some View {
        VStack(spacing: 8) {
            HStack {
                // Back button
                if currentIndex > 0 {
                    Button {
                        goBack()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.6))
                            .frame(width: 36, height: 36)
                    }
                    .buttonStyle(.plain)
                } else {
                    Color.clear.frame(width: 36, height: 36)
                }

                Spacer()

                // Title
                VStack(spacing: 2) {
                    Text(lesson?.title ?? plot.building.name)
                        .font(.custom("Cinzel-Bold", size: 15))
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                        .lineLimit(1)

                    // Science chips
                    HStack(spacing: 4) {
                        ForEach(plot.building.sciences, id: \.self) { science in
                            scienceChip(science)
                        }
                    }
                }

                Spacer()

                // Close button
                Button {
                    onDismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.6))
                        .frame(width: 36, height: 36)
                        .background(
                            Circle()
                                .fill(RenaissanceColors.sepiaInk.opacity(0.08))
                        )
                }
                .buttonStyle(.plain)
            }

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(RenaissanceColors.ochre.opacity(0.15))
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 3)
                        .fill(RenaissanceColors.ochre)
                        .frame(width: progressWidth(in: geo.size.width), height: 6)
                        .animation(.easeInOut(duration: 0.3), value: currentIndex)
                }
            }
            .frame(height: 6)
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 8)
    }

    private func progressWidth(in totalWidth: CGFloat) -> CGFloat {
        guard !pages.isEmpty else { return totalWidth }
        let fraction = CGFloat(currentIndex) / CGFloat(pages.count)
        return max(6, totalWidth * fraction)
    }

    // MARK: - Section Views

    @ViewBuilder
    private func sectionView(_ section: LessonSection) -> some View {
        switch section {
        case .reading(let reading):
            readingView(reading)
        case .funFact(let fact):
            funFactView(fact)
        case .question(let question):
            questionView(question)
        case .fillInBlanks(let activity):
            fillInBlanksView(activity)
        case .environmentPrompt(let prompt):
            environmentPromptView(prompt)
        case .curiosity(let curiosity):
            curiosityView(curiosity)
        case .mathVisual(let visual):
            MathVisualView(visual: visual, currentStep: $mathVisualStep)
        }
    }

    // MARK: - Reading Section

    private func readingView(_ reading: LessonReading) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Illustration placeholder
            if let icon = reading.illustrationIcon {
                HStack {
                    Spacer()
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(RenaissanceColors.ochre.opacity(0.08))
                            .frame(width: 100, height: 100)
                        Image(systemName: icon)
                            .font(.system(size: 40))
                            .foregroundStyle(RenaissanceColors.ochre.opacity(0.5))
                    }
                    Spacer()
                }
                if let caption = reading.caption {
                    Text(caption)
                        .font(.custom("EBGaramond-Italic", size: 13))
                        .foregroundStyle(RenaissanceColors.stoneGray)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                }
            }

            // Title
            if let title = reading.title {
                Text(title)
                    .font(.custom("Cinzel-Bold", size: 22))
                    .foregroundStyle(RenaissanceColors.sepiaInk)
            }

            // Science badge
            if let science = reading.science {
                scienceChip(science)
            }

            // Body text with bold markdown
            markdownText(reading.body)
        }
    }

    // MARK: - Fun Fact Card

    private func funFactView(_ fact: LessonFunFact) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with paperclip icon
            HStack(spacing: 8) {
                Image(systemName: "paperclip")
                    .font(.system(size: 18))
                    .foregroundStyle(RenaissanceColors.ochre)
                    .rotationEffect(.degrees(-30))
                Text("Fun Fact")
                    .font(.custom("Cinzel-Bold", size: 16))
                    .foregroundStyle(RenaissanceColors.ochre)
            }

            markdownText(fact.text)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.99, green: 0.96, blue: 0.88))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(RenaissanceColors.ochre.opacity(0.3), lineWidth: 1.5)
        )
        .shadow(color: RenaissanceColors.ochre.opacity(0.1), radius: 6, y: 3)
    }

    // MARK: - Question View

    private func questionView(_ question: LessonQuestion) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Science badge
            scienceChip(question.science)

            // Question text
            Text(question.question)
                .font(.custom("Cinzel-Bold", size: 18))
                .foregroundStyle(RenaissanceColors.sepiaInk)
                .lineSpacing(4)

            // Scratch Pad (only for math questions with hints)
            if question.hints != nil {
                scratchPadSection
            }

            // Options
            VStack(spacing: 8) {
                ForEach(Array(question.options.enumerated()), id: \.offset) { index, option in
                    questionOptionButton(
                        text: option,
                        index: index,
                        correctIndex: question.correctIndex
                    )
                }
            }

            // Hint system (only for questions with hints, before answering)
            if let hints = question.hints, !showExplanation {
                hintSection(hints: hints)
            }

            // Explanation (shown after answering)
            if showExplanation {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: selectedAnswer == question.correctIndex ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundStyle(selectedAnswer == question.correctIndex ? RenaissanceColors.sageGreen : RenaissanceColors.errorRed)
                        Text(selectedAnswer == question.correctIndex ? "Correct!" : "Not quite")
                            .font(.custom("Cinzel-Bold", size: 15))
                            .foregroundStyle(selectedAnswer == question.correctIndex ? RenaissanceColors.sageGreen : RenaissanceColors.errorRed)
                    }

                    Text(question.explanation)
                        .font(.system(size: 16))
                        .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.8))
                        .lineSpacing(6)
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(selectedAnswer == question.correctIndex
                              ? RenaissanceColors.sageGreen.opacity(0.08)
                              : RenaissanceColors.errorRed.opacity(0.08))
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }

    // MARK: - Scratch Pad

    private var scratchPadSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                withAnimation(.spring(response: 0.3)) {
                    showScratchPad.toggle()
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "pencil.and.outline")
                        .font(.system(size: 14))
                    Text(showScratchPad ? "Hide Scratch Pad" : "Show Scratch Pad")
                        .font(.custom("EBGaramond-Italic", size: 15))
                }
                .foregroundStyle(RenaissanceColors.warmBrown)
            }
            .buttonStyle(.plain)

            if showScratchPad {
                #if os(iOS)
                MathScratchPadCanvas()
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
                            .foregroundStyle(RenaissanceColors.warmBrown.opacity(0.4))
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))
                #else
                TextEditor(text: $scratchPadText)
                    .font(.custom("EBGaramond-Regular", size: 15))
                    .foregroundStyle(RenaissanceColors.sepiaInk)
                    .scrollContentBackground(.hidden)
                    .frame(height: 200)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(red: 0.96, green: 0.90, blue: 0.80))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
                            .foregroundStyle(RenaissanceColors.warmBrown.opacity(0.4))
                    )
                    .overlay(alignment: .topLeading, content: {
                        if scratchPadText.isEmpty {
                            Text("Show your work here...")
                                .font(.custom("EBGaramond-Italic", size: 15))
                                .foregroundStyle(RenaissanceColors.stoneGray.opacity(0.5))
                                .padding(.horizontal, 13)
                                .padding(.vertical, 16)
                                .allowsHitTesting(false)
                        }
                    })
                    .transition(.move(edge: .top).combined(with: .opacity))
                #endif
            }
        }
    }

    // MARK: - Hint System

    private func hintSection(hints: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // Hint button
            if hintLevel < hints.count {
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        hintLevel += 1
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: 13))
                        Text(hintLevel == 0 ? "Need a hint?" : "Next hint (\(hintLevel)/\(hints.count))")
                            .font(.custom("EBGaramond-Italic", size: 15))
                    }
                    .foregroundStyle(RenaissanceColors.ochre)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(RenaissanceColors.ochre.opacity(0.1))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(RenaissanceColors.ochre.opacity(0.3), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            } else if hintLevel > 0 {
                HStack(spacing: 6) {
                    Image(systemName: "lightbulb.slash")
                        .font(.system(size: 13))
                    Text("All hints used")
                        .font(.custom("EBGaramond-Italic", size: 15))
                }
                .foregroundStyle(RenaissanceColors.stoneGray)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
            }

            // Revealed hint cards
            ForEach(0..<hintLevel, id: \.self) { index in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(RenaissanceColors.ochre)
                        .padding(.top, 2)

                    Text(hints[index])
                        .font(.system(size: 16))
                        .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.85))
                        .lineSpacing(6)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(RenaissanceColors.ochre.opacity(0.06))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(RenaissanceColors.ochre.opacity(0.15), lineWidth: 1)
                )
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }

    private func questionOptionButton(text: String, index: Int, correctIndex: Int) -> some View {
        let isSelected = selectedAnswer == index
        let isCorrect = index == correctIndex
        let isRevealed = showExplanation

        return Button {
            guard !showExplanation else { return }
            selectedAnswer = index
            withAnimation(.spring(response: 0.3)) {
                showExplanation = true
            }
        } label: {
            HStack(spacing: 12) {
                // Letter label
                Text(String(UnicodeScalar(65 + index)!))
                    .font(.custom("Cinzel-Bold", size: 14))
                    .foregroundStyle(isRevealed && isCorrect ? .white : RenaissanceColors.sepiaInk)
                    .frame(width: 28, height: 28)
                    .background(
                        Circle()
                            .fill(isRevealed && isCorrect
                                  ? RenaissanceColors.sageGreen
                                  : isRevealed && isSelected && !isCorrect
                                  ? RenaissanceColors.errorRed
                                  : RenaissanceColors.ochre.opacity(0.12))
                    )

                Text(text)
                    .font(.system(size: 16))
                    .foregroundStyle(RenaissanceColors.sepiaInk)
                    .multilineTextAlignment(.leading)

                Spacer()

                if isRevealed && isCorrect {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(RenaissanceColors.sageGreen)
                }
                if isRevealed && isSelected && !isCorrect {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(RenaissanceColors.errorRed)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isRevealed && isCorrect
                          ? RenaissanceColors.sageGreen.opacity(0.1)
                          : isRevealed && isSelected && !isCorrect
                          ? RenaissanceColors.errorRed.opacity(0.08)
                          : isSelected && !isRevealed
                          ? RenaissanceColors.ochre.opacity(0.12)
                          : RenaissanceColors.parchment)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isRevealed && isCorrect
                            ? RenaissanceColors.sageGreen.opacity(0.5)
                            : isRevealed && isSelected && !isCorrect
                            ? RenaissanceColors.errorRed.opacity(0.4)
                            : RenaissanceColors.ochre.opacity(0.2),
                            lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Fill in Blanks View

    private func fillInBlanksView(_ activity: LessonFillInBlanks) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Title
            if let title = activity.title {
                Text(title)
                    .font(.custom("Cinzel-Bold", size: 18))
                    .foregroundStyle(RenaissanceColors.sepiaInk)
            }

            if let science = activity.science {
                scienceChip(science)
            }

            // Text with blanks
            blanksTextView(activity)

            // Word bank
            wordBankView(activity)

            // Check button
            if !blanksChecked && allBlanksFilled(activity) {
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        blanksChecked = true
                    }
                } label: {
                    Text("Check Answers")
                        .font(.custom("Cinzel-Bold", size: 16))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(RenaissanceColors.renaissanceBlue)
                        )
                }
                .buttonStyle(.plain)
            }

            // Feedback
            if blanksChecked {
                HStack(spacing: 6) {
                    let correct = allBlanksCorrect(activity)
                    Image(systemName: correct ? "checkmark.circle.fill" : "arrow.counterclockwise.circle.fill")
                        .foregroundStyle(correct ? RenaissanceColors.sageGreen : RenaissanceColors.ochre)
                    Text(correct ? "All correct!" : "Some answers need fixing — tap a blank to change it")
                        .font(.system(size: 15))
                        .foregroundStyle(correct ? RenaissanceColors.sageGreen : RenaissanceColors.ochre)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))

                if !allBlanksCorrect(activity) {
                    Button {
                        withAnimation {
                            blanksChecked = false
                        }
                    } label: {
                        Text("Try Again")
                            .font(.custom("EBGaramond-Italic", size: 14))
                            .foregroundStyle(RenaissanceColors.renaissanceBlue)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func blanksTextView(_ activity: LessonFillInBlanks) -> some View {
        let segments = activity.segments
        var blankCounter = -1

        return WrappingHStack(segments: segments.map { segment in
            if segment.blankWord != nil {
                blankCounter += 1
                let idx = blankCounter
                let placed = blankAnswers[idx]
                let isCorrect = blanksChecked && placed == segment.blankWord
                let isWrong = blanksChecked && placed != nil && placed != segment.blankWord
                return BlanksSegment(
                    text: segment.text,
                    blankIndex: idx,
                    blankWord: segment.blankWord,
                    placedWord: placed,
                    isCorrect: isCorrect,
                    isWrong: isWrong
                )
            } else {
                return BlanksSegment(
                    text: segment.text,
                    blankIndex: nil,
                    blankWord: nil,
                    placedWord: nil,
                    isCorrect: false,
                    isWrong: false
                )
            }
        }, activeBlankIndex: $activeBlankIndex, blankAnswers: $blankAnswers, blanksChecked: blanksChecked)
    }

    private func wordBankView(_ activity: LessonFillInBlanks) -> some View {
        let usedWords = Set(blankAnswers.values)
        let bank = frozenWordBank

        return VStack(alignment: .leading, spacing: 8) {
            Text("Word Bank")
                .font(.custom("Cinzel-Bold", size: 13))
                .foregroundStyle(RenaissanceColors.stoneGray)

            LessonFlowLayout(spacing: 8) {
                ForEach(Array(bank.enumerated()), id: \.offset) { _, word in
                    let isUsed = usedWords.contains(word)
                    Button {
                        guard !isUsed else { return }
                        placeWord(word, from: activity)
                    } label: {
                        Text(word)
                            .font(.system(size: 16))
                            .foregroundStyle(isUsed ? RenaissanceColors.stoneGray.opacity(0.4) : RenaissanceColors.sepiaInk)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(isUsed ? RenaissanceColors.stoneGray.opacity(0.08) : RenaissanceColors.ochre.opacity(0.12))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(isUsed ? Color.clear : RenaissanceColors.ochre.opacity(0.3), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                    .disabled(isUsed)
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(RenaissanceColors.sepiaInk.opacity(0.03))
        )
    }

    private func placeWord(_ word: String, from activity: LessonFillInBlanks) {
        // If a blank is selected, place the word there
        if let idx = activeBlankIndex {
            // If there was already a word there, remove it first
            blankAnswers[idx] = word
            activeBlankIndex = nil
            blanksChecked = false
        } else {
            // Place in first empty blank
            let totalBlanks = activity.correctWords.count
            for i in 0..<totalBlanks {
                if blankAnswers[i] == nil {
                    blankAnswers[i] = word
                    blanksChecked = false
                    return
                }
            }
        }
    }

    private func allBlanksFilled(_ activity: LessonFillInBlanks) -> Bool {
        let total = activity.correctWords.count
        for i in 0..<total {
            if blankAnswers[i] == nil { return false }
        }
        return true
    }

    private func allBlanksCorrect(_ activity: LessonFillInBlanks) -> Bool {
        let correct = activity.correctWords
        for (i, word) in correct.enumerated() {
            if blankAnswers[i] != word { return false }
        }
        return true
    }

    // MARK: - Environment Prompt View

    private func environmentPromptView(_ prompt: LessonEnvironmentPrompt) -> some View {
        let hasRawMaterials = workshopState?.rawMaterials.values.contains(where: { $0 > 0 }) ?? false
        let needsMaterialsFirst = prompt.destination == .craftingRoom && !hasRawMaterials

        return VStack(spacing: 14) {
            Image(systemName: needsMaterialsFirst ? "exclamationmark.triangle.fill" : prompt.icon)
                .font(.system(size: 36))
                .foregroundStyle(needsMaterialsFirst ? RenaissanceColors.ochre : destinationColor(prompt.destination))
                .frame(width: 64, height: 64)
                .background(
                    Circle()
                        .fill((needsMaterialsFirst ? RenaissanceColors.ochre : destinationColor(prompt.destination)).opacity(0.1))
                )

            Text(prompt.title)
                .font(.custom("Cinzel-Bold", size: 18))
                .foregroundStyle(RenaissanceColors.sepiaInk)
                .multilineTextAlignment(.center)

            Text(needsMaterialsFirst
                 ? "You haven't collected any raw materials yet. Visit the Workshop first to gather resources from the quarry, volcano, and river — then come back to craft them."
                 : prompt.description)
                .font(.system(size: 16))
                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.8))
                .multilineTextAlignment(.center)
                .lineSpacing(6)

            Button {
                onDismiss()
                if needsMaterialsFirst {
                    onNavigate?(.workshop)
                } else {
                    switch prompt.destination {
                    case .workshop:
                        onNavigate?(.workshop)
                    case .forest:
                        onNavigate?(.forest)
                    case .craftingRoom:
                        onNavigate?(.workshop)
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: needsMaterialsFirst ? "hammer.fill" : prompt.icon)
                        .font(.system(size: 14))
                    Text(needsMaterialsFirst ? "Visit Workshop First" : "Visit \(prompt.destination.rawValue.capitalized)")
                        .font(.custom("Cinzel-Bold", size: 14))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(needsMaterialsFirst ? RenaissanceColors.warmBrown : destinationColor(prompt.destination))
                )
            }
            .buttonStyle(.plain)

            Text("Return to the lesson from the navigation bar")
                .font(.custom("EBGaramond-Italic", size: 12))
                .foregroundStyle(RenaissanceColors.stoneGray)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(destinationColor(prompt.destination).opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(destinationColor(prompt.destination).opacity(0.2), lineWidth: 1)
        )
    }

    private func destinationColor(_ dest: LessonDestination) -> Color {
        switch dest {
        case .workshop: return RenaissanceColors.warmBrown
        case .forest: return RenaissanceColors.sageGreen
        case .craftingRoom: return RenaissanceColors.renaissanceBlue
        }
    }

    // MARK: - Curiosity Q&A ("Students Also Ask")

    private func curiosityView(_ curiosity: LessonCuriosity) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(spacing: 8) {
                Image(systemName: "questionmark.bubble.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(RenaissanceColors.renaissanceBlue)
                Text("Students Also Ask")
                    .font(.custom("Cinzel-Bold", size: 16))
                    .foregroundStyle(RenaissanceColors.renaissanceBlue)
            }

            // Expandable Q&A cards
            ForEach(Array(curiosity.questions.enumerated()), id: \.offset) { index, qa in
                VStack(alignment: .leading, spacing: 0) {
                    // Question row (tappable)
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            if expandedCuriosityIndex == index {
                                expandedCuriosityIndex = nil
                            } else {
                                expandedCuriosityIndex = index
                            }
                        }
                    } label: {
                        HStack(spacing: 10) {
                            Text(qa.question)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(RenaissanceColors.sepiaInk)
                                .multilineTextAlignment(.leading)

                            Spacer()

                            Image(systemName: expandedCuriosityIndex == index ? "chevron.up" : "chevron.down")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(RenaissanceColors.renaissanceBlue.opacity(0.6))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                    }
                    .buttonStyle(.plain)

                    // Answer (revealed when expanded)
                    if expandedCuriosityIndex == index {
                        markdownText(qa.answer)
                            .padding(.horizontal, 14)
                            .padding(.bottom, 14)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(RenaissanceColors.renaissanceBlue.opacity(0.04))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(RenaissanceColors.renaissanceBlue.opacity(0.15), lineWidth: 1)
                )
            }
        }
    }

    // MARK: - Continue Button

    private var continueButton: some View {
        Group {
            if canContinue {
                Button {
                    advance()
                } label: {
                    Text(currentIndex < pages.count - 1 ? "Continue" : "Finish Lesson")
                        .font(.custom("Cinzel-Bold", size: 16))
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(RenaissanceColors.ochre.opacity(0.2))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(RenaissanceColors.ochre.opacity(0.4), lineWidth: 1.5)
                        )
                }
                .buttonStyle(.plain)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }

    // MARK: - Completion View

    private var completionView: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer(minLength: 20)

                Image(systemName: "star.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(RenaissanceColors.goldSuccess)

                Text("Lesson Complete!")
                    .font(.custom("Cinzel-Bold", size: 26))
                    .foregroundStyle(RenaissanceColors.sepiaInk)

                // Science badges earned
                VStack(spacing: 8) {
                    Text("Sciences Studied")
                        .font(.custom("Cinzel-Bold", size: 14))
                        .foregroundStyle(RenaissanceColors.stoneGray)

                    HStack(spacing: 12) {
                        ForEach(plot.building.sciences, id: \.self) { science in
                            VStack(spacing: 4) {
                                if let img = science.customImageName {
                                    Image(img)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 36, height: 36)
                                        .clipShape(RoundedRectangle(cornerRadius: 6))
                                } else {
                                    Image(systemName: science.sfSymbolName)
                                        .font(.system(size: 24))
                                        .foregroundStyle(RenaissanceColors.ochre)
                                }
                                Text(science.rawValue)
                                    .font(.custom("EBGaramond-Regular", size: 11))
                                    .foregroundStyle(RenaissanceColors.sepiaInk)
                            }
                        }
                    }
                }

                if !hasClaimedReward {
                    Button {
                        if !alreadyRead {
                            viewModel.markLessonRead(for: plot.id)
                        }
                        // Auto-populate notebook on first completion
                        if let ns = notebookState, let lesson = lesson,
                           !ns.isLessonAdded(for: plot.id) {
                            let entries = NotebookContent.entriesFromLesson(lesson, buildingId: plot.id)
                            let vocab = NotebookContent.vocabularyFor(buildingName: plot.building.name) ?? []
                            ns.addEntries(entries + vocab, buildingId: plot.id, buildingName: plot.building.name)
                            ns.markLessonAdded(for: plot.id)
                        }
                        // Clear bookmark — lesson is complete
                        viewModel.saveLessonBookmark(for: plot.id, sectionIndex: 0)
                        hasClaimedReward = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "book.closed.fill")
                                .font(.system(size: 16))
                            Text(alreadyRead ? "Done" : "Claim Reward")
                                .font(.custom("Cinzel-Bold", size: 18))
                            if !alreadyRead {
                                Text("+\(GameRewards.lessonReadFlorins)")
                                    .font(.custom("Cinzel-Bold", size: 16))
                                    .foregroundStyle(RenaissanceColors.goldSuccess)
                                Image(systemName: "dollarsign.circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundStyle(RenaissanceColors.goldSuccess)
                            }
                        }
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(RenaissanceColors.ochre.opacity(0.2))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(RenaissanceColors.ochre.opacity(0.5), lineWidth: 2)
                        )
                    }
                    .buttonStyle(.plain)
                }

                if hasClaimedReward {
                    VStack(spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(RenaissanceColors.sageGreen)
                            Text("Knowledge earned!")
                                .font(.custom("Cinzel-Bold", size: 16))
                                .foregroundStyle(RenaissanceColors.sageGreen)
                        }

                        HStack(spacing: 4) {
                            ForEach(plot.building.sciences, id: \.self) { _ in
                                Image(systemName: "seal.fill")
                                    .font(.system(size: 14))
                                    .foregroundStyle(RenaissanceColors.ochre)
                            }
                            Text("\(plot.building.sciences.count) science badges")
                                .font(.custom("EBGaramond-Regular", size: 13))
                                .foregroundStyle(RenaissanceColors.stoneGray)
                        }

                        // View in Notebook button
                        if notebookState != nil {
                            Button {
                                onDismiss()
                                onNavigate?(.notebook(plot.id))
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "book.closed.fill")
                                        .font(.system(size: 14))
                                    Text("View in Notebook")
                                        .font(.custom("Cinzel-Bold", size: 14))
                                }
                                .foregroundStyle(RenaissanceColors.renaissanceBlue)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(RenaissanceColors.renaissanceBlue.opacity(0.1))
                                )
                            }
                            .buttonStyle(.plain)
                            .padding(.top, 4)
                        }
                    }
                    .transition(.scale.combined(with: .opacity))
                }

                // Close
                Button {
                    onDismiss()
                } label: {
                    Text("Return to Map")
                        .font(.custom("EBGaramond-Italic", size: 16))
                        .foregroundStyle(RenaissanceColors.stoneGray)
                }
                .buttonStyle(.plain)
                .padding(.top, 8)

                Spacer(minLength: 20)
            }
            .padding(.horizontal, 24)
        }
    }

    // MARK: - Navigation

    private func advance() {
        resetSectionState()
        if currentIndex < pages.count - 1 {
            currentIndex += 1
        } else {
            // Past last page → completion
            currentIndex = pages.count
        }
        freezeWordBankIfNeeded()
    }

    private func goBack() {
        guard currentIndex > 0 else { return }
        resetSectionState()
        currentIndex -= 1
        freezeWordBankIfNeeded()
    }

    private func resetSectionState() {
        selectedAnswer = nil
        showExplanation = false
        hintLevel = 0
        showScratchPad = false
        scratchPadText = ""
        blankAnswers = [:]
        activeBlankIndex = nil
        blanksChecked = false
        frozenWordBank = []
        expandedCuriosityIndex = nil
        mathVisualStep = 1
    }

    /// Shuffle the word bank once and store it so it doesn't re-shuffle on every render
    private func freezeWordBankIfNeeded() {
        guard currentIndex < pages.count else { return }
        for section in pages[currentIndex] {
            if case .fillInBlanks(let activity) = section {
                frozenWordBank = (activity.correctWords + activity.distractors).shuffled()
                return
            }
        }
    }

    // MARK: - Helpers

    private func scienceChip(_ science: Science) -> some View {
        HStack(spacing: 4) {
            if let imageName = science.customImageName {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                    .clipShape(RoundedRectangle(cornerRadius: 3))
            } else {
                Image(systemName: science.sfSymbolName)
                    .font(.system(size: 11))
                    .foregroundStyle(RenaissanceColors.warmBrown)
            }
            Text(science.rawValue)
                .font(.custom("EBGaramond-Regular", size: 11))
                .foregroundStyle(RenaissanceColors.sepiaInk)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(
            Capsule()
                .fill(RenaissanceColors.ochre.opacity(0.1))
        )
    }

    /// Render text with **bold** markdown markers
    private func markdownText(_ text: String) -> some View {
        let parts = parseBold(text)
        return parts.reduce(Text("")) { result, part in
            if part.isBold {
                return result + Text(part.text)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(RenaissanceColors.sepiaInk)
            } else {
                return result + Text(part.text)
                    .font(.system(size: 17))
                    .foregroundColor(RenaissanceColors.sepiaInk)
            }
        }
        .tracking(0.15)
        .lineSpacing(8)
        .multilineTextAlignment(.leading)
    }

    private struct TextPart {
        let text: String
        let isBold: Bool
    }

    private func parseBold(_ text: String) -> [TextPart] {
        var parts: [TextPart] = []
        var remaining = text
        while let startRange = remaining.range(of: "**") {
            let before = String(remaining[remaining.startIndex..<startRange.lowerBound])
            if !before.isEmpty {
                parts.append(TextPart(text: before, isBold: false))
            }
            let afterStart = String(remaining[startRange.upperBound...])
            if let endRange = afterStart.range(of: "**") {
                let boldText = String(afterStart[afterStart.startIndex..<endRange.lowerBound])
                parts.append(TextPart(text: boldText, isBold: true))
                remaining = String(afterStart[endRange.upperBound...])
            } else {
                parts.append(TextPart(text: "**" + afterStart, isBold: false))
                remaining = ""
            }
        }
        if !remaining.isEmpty {
            parts.append(TextPart(text: remaining, isBold: false))
        }
        return parts
    }
}

// MARK: - Blanks Segment Model

struct BlanksSegment {
    let text: String
    let blankIndex: Int?
    let blankWord: String?
    let placedWord: String?
    let isCorrect: Bool
    let isWrong: Bool
}

// MARK: - Wrapping HStack for Fill-in-Blanks Text

/// Renders text with inline blanks that wrap naturally
struct WrappingHStack: View {
    let segments: [BlanksSegment]
    @Binding var activeBlankIndex: Int?
    @Binding var blankAnswers: [Int: String]
    let blanksChecked: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(Array(segments.enumerated()), id: \.offset) { _, segment in
                if let blankIdx = segment.blankIndex {
                    // Blank slot
                    Button {
                        if blanksChecked && !segment.isWrong { return }
                        if let _ = blankAnswers[blankIdx] {
                            // Remove the word
                            blankAnswers[blankIdx] = nil
                            activeBlankIndex = nil
                        } else {
                            activeBlankIndex = blankIdx
                        }
                    } label: {
                        if let placed = segment.placedWord {
                            Text(placed)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(
                                    segment.isCorrect ? RenaissanceColors.sageGreen :
                                    segment.isWrong ? RenaissanceColors.errorRed :
                                    RenaissanceColors.renaissanceBlue
                                )
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(
                                            segment.isCorrect ? RenaissanceColors.sageGreen.opacity(0.1) :
                                            segment.isWrong ? RenaissanceColors.errorRed.opacity(0.1) :
                                            RenaissanceColors.renaissanceBlue.opacity(0.1)
                                        )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(
                                            segment.isCorrect ? RenaissanceColors.sageGreen.opacity(0.5) :
                                            segment.isWrong ? RenaissanceColors.errorRed.opacity(0.5) :
                                            RenaissanceColors.renaissanceBlue.opacity(0.4),
                                            lineWidth: 1.5
                                        )
                                )
                        } else {
                            Text("_______")
                                .font(.system(size: 16))
                                .foregroundStyle(RenaissanceColors.stoneGray.opacity(0.5))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(activeBlankIndex == blankIdx
                                              ? RenaissanceColors.renaissanceBlue.opacity(0.1)
                                              : RenaissanceColors.stoneGray.opacity(0.06))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(activeBlankIndex == blankIdx
                                                ? RenaissanceColors.renaissanceBlue.opacity(0.5)
                                                : RenaissanceColors.stoneGray.opacity(0.2),
                                                lineWidth: activeBlankIndex == blankIdx ? 2 : 1)
                                )
                        }
                    }
                    .buttonStyle(.plain)
                } else {
                    // Plain text
                    Text(segment.text)
                        .font(.system(size: 17))
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                        .lineSpacing(8)
                }
            }
        }
    }
}

// MARK: - Flow Layout for Word Bank

/// A simple flow layout that wraps items to the next line
struct LessonFlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth && currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            currentX += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }

        return CGSize(width: maxWidth, height: currentY + lineHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var currentX: CGFloat = bounds.minX
        var currentY: CGFloat = bounds.minY
        var lineHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > bounds.maxX && currentX > bounds.minX {
                currentX = bounds.minX
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            subview.place(at: CGPoint(x: currentX, y: currentY), proposal: ProposedViewSize(size))
            currentX += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
    }
}

// MARK: - PencilKit Scratch Pad (iOS only)

#if os(iOS)
struct MathScratchPadCanvas: UIViewRepresentable {
    func makeUIView(context: Context) -> PKCanvasView {
        let canvas = PKCanvasView()
        canvas.drawingPolicy = .anyInput
        canvas.backgroundColor = UIColor(red: 0.96, green: 0.90, blue: 0.80, alpha: 1)
        canvas.tool = PKInkingTool(.pen, color: UIColor(red: 0.29, green: 0.25, blue: 0.21, alpha: 1), width: 2)
        return canvas
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {}
}
#endif
