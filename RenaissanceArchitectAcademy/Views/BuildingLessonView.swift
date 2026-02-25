import SwiftUI
#if os(iOS)
import PencilKit
#endif

/// Helper to pair two inline sections for 2-column layout
private struct InlinePair {
    let leftIdx: Int
    let rightIdx: Int
    var indices: ClosedRange<Int> {
        min(leftIdx, rightIdx)...max(leftIdx, rightIdx)
    }
}

private extension Array where Element == LessonSection {
    /// Finds two sections that should render side-by-side:
    /// - curiosity + environmentPrompt
    /// - two environmentPrompts
    var inlinePair: InlinePair? {
        var curiosityIdx: Int?
        var promptIndices: [Int] = []
        for (i, section) in self.enumerated() {
            if case .curiosity = section { curiosityIdx = i }
            if case .environmentPrompt = section { promptIndices.append(i) }
        }
        // Two environment prompts → side by side
        if promptIndices.count >= 2 {
            return InlinePair(leftIdx: promptIndices[0], rightIdx: promptIndices[1])
        }
        // Curiosity + environment prompt → prompt left, curiosity right
        if let c = curiosityIdx, let p = promptIndices.first {
            return InlinePair(leftIdx: p, rightIdx: c)
        }
        return nil
    }
}

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
    @State private var frozenWordBank: [String] = []  // shuffled, reshuffles periodically
    @State private var wordBankShuffleTimer: Timer?

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
            RenaissanceColors.overlayDimming
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar: progress + close
                topBar

                // Content area
                if currentIndex < pages.count {
                    GeometryReader { scrollGeo in
                        ScrollView {
                            VStack(spacing: 0) {
                                VStack(alignment: .leading, spacing: 20) {
                                    let pageSections = pages[currentIndex]
                                    let inlineGroup = pageSections.inlinePair
                                    ForEach(Array(pageSections.enumerated()), id: \.offset) { idx, section in
                                        if let pair = inlineGroup, pair.indices.contains(idx) {
                                            // Render two inline sections side-by-side
                                            if idx == pair.indices.lowerBound {
                                                HStack(alignment: .top, spacing: 8) {
                                                    sectionView(pageSections[pair.leftIdx])
                                                        .frame(maxWidth: .infinity, alignment: .top)
                                                    sectionView(pageSections[pair.rightIdx])
                                                        .frame(maxWidth: .infinity, alignment: .top)
                                                }
                                                .padding(.top, 0)
                                            }
                                            // Skip the second index — already rendered above
                                        } else {
                                            sectionView(section)
                                        }
                                    }
                                }
                                .padding(.horizontal, 24)
                                .padding(.top, 20)
                                .padding(.bottom, 12)

                                Spacer(minLength: 16)

                                // Continue / Next button pinned to bottom
                                continueButton
                                    .padding(.horizontal, 24)
                                    .padding(.bottom, 24)
                            }
                            .frame(minHeight: scrollGeo.size.height)
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
            )
            .borderModal(radius: 20)
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
            stopWordBankShuffleTimer()
            // Save bookmark when leaving (unless lesson is complete)
            if currentIndex < pages.count {
                viewModel.saveLessonBookmark(for: plot.id, sectionIndex: currentIndex)
            }
        }
        // Environment navigation uses onNavigate to go to full scene (not a sheet)
    }

    // MARK: - Top Bar

    private var topBar: some View {
        VStack(spacing: 12) {
            HStack {
                // Back button
                if currentIndex > 0 {
                    Button {
                        goBack()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.custom("EBGaramond-SemiBold", size: 16, relativeTo: .subheadline))
                            .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.6))
                            .frame(width: 36, height: 36)
                    }
                    .buttonStyle(.plain)
                } else {
                    Color.clear.frame(width: 36, height: 36)
                }

                Spacer()

                // Title
                Text(lesson?.title ?? plot.building.name)
                    .font(.custom("EBGaramond-SemiBold", size: 17))
                    .foregroundStyle(RenaissanceColors.sepiaInk)
                    .lineLimit(1)

                Spacer()

                // Close button
                Button {
                    onDismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.custom("EBGaramond-SemiBold", size: 14, relativeTo: .footnote))
                        .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.6))
                        .frame(width: 36, height: 36)
                        .background(
                            Circle()
                                .fill(RenaissanceColors.sepiaInk.opacity(0.08))
                        )
                }
                .buttonStyle(.plain)
            }

            // Circle progress indicator
            progressCircles
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 10)
    }

    /// Position along the wavy path for a given page index
    private func pathPoint(index: Int, total: Int, in size: CGSize) -> CGPoint {
        let padding: CGFloat = 24
        let usableWidth = size.width - padding * 2
        let x = total > 1 ? padding + usableWidth * CGFloat(index) / CGFloat(total - 1) : size.width / 2
        let midY: CGFloat = 20
        let wave: CGFloat = 3
        let y = midY + sin(CGFloat(index) * 1.1) * wave
        return CGPoint(x: x, y: y)
    }

    private var progressCircles: some View {
        let total = pages.count
        let endpointSize: CGFloat = 20
        let currentSize: CGFloat = 30
        let completedColor = RenaissanceColors.ochre
        let futureColor = RenaissanceColors.stoneGray.opacity(0.25)
        let currentColor = RenaissanceColors.goldSuccess

        return GeometryReader { geo in
            let sz = geo.size

            // Wavy path line
            Canvas { ctx, canvasSize in
                guard total > 1 else { return }
                var completedPath = Path()
                var futurePath = Path()

                for i in 0..<(total - 1) {
                    let from = pathPoint(index: i, total: total, in: canvasSize)
                    let to = pathPoint(index: i + 1, total: total, in: canvasSize)
                    if i < currentIndex {
                        completedPath.move(to: from)
                        completedPath.addLine(to: to)
                    } else {
                        futurePath.move(to: from)
                        futurePath.addLine(to: to)
                    }
                }

                ctx.stroke(completedPath, with: .color(completedColor), lineWidth: 2.5)
                ctx.stroke(futurePath, with: .color(futureColor), lineWidth: 1.5)
            }

            // Start circle (always visible)
            let startPt = pathPoint(index: 0, total: total, in: sz)
            if currentIndex != 0 {
                ZStack {
                    Circle()
                        .fill(completedColor)
                        .frame(width: endpointSize, height: endpointSize)
                    Text("Start")
                        .font(.custom("EBGaramond-Regular", size: 7))
                        .foregroundStyle(.white)
                }
                .position(startPt)
            }

            // Finish circle (always visible)
            let endPt = pathPoint(index: total - 1, total: total, in: sz)
            if currentIndex != total - 1 {
                ZStack {
                    Circle()
                        .fill(futureColor)
                        .frame(width: endpointSize, height: endpointSize)
                    Text("Finish")
                        .font(.custom("EBGaramond-Regular", size: 7))
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                }
                .position(endPt)
            }

            // Current page circle — clamped so it never goes past Finish
            let clampedIndex = min(currentIndex, total - 1)
            let pt = pathPoint(index: clampedIndex, total: total, in: sz)
            ZStack {
                Circle()
                    .fill(currentColor.opacity(0.2))
                    .frame(width: currentSize + 8, height: currentSize + 8)
                Circle()
                    .fill(currentColor)
                    .frame(width: currentSize, height: currentSize)
                if clampedIndex == 0 {
                    Text("Start")
                        .font(.custom("EBGaramond-Regular", size: 8))
                        .foregroundStyle(.white)
                } else if clampedIndex >= total - 1 {
                    Text("Finish")
                        .font(.custom("EBGaramond-Regular", size: 8))
                        .foregroundStyle(.white)
                } else {
                    Text("\(clampedIndex + 1)")
                        .font(.custom("EBGaramond-Regular", size: 15))
                        .foregroundStyle(.white)
                }
            }
            .position(pt)
        }
        .frame(height: 42)
        .animation(.spring(response: 0.3), value: currentIndex)
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
                            .fill(Color.white.opacity(0.6))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(RenaissanceColors.ochre.opacity(0.25), lineWidth: 1)
                            )
                            .frame(width: 100, height: 100)
                        Image(systemName: icon)
                            .font(.custom("EBGaramond-Regular", size: 40, relativeTo: .title3))
                            .foregroundStyle(RenaissanceColors.ochre.opacity(0.5))
                    }
                    Spacer()
                }
                if let caption = reading.caption {
                    Text(caption)
                        .font(.custom("EBGaramond-Regular", size: 13))
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                }
            }

            // Title
            if let title = reading.title {
                Text(title)
                    .font(.custom("EBGaramond-SemiBold", size: 24))
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
                    .font(.custom("EBGaramond-Regular", size: 18, relativeTo: .body))
                    .foregroundStyle(RenaissanceColors.sepiaInk)
                    .rotationEffect(.degrees(-30))
                Text("Fun Fact")
                    .font(.custom("EBGaramond-SemiBold", size: 18))
                    .foregroundStyle(RenaissanceColors.sepiaInk)
            }

            markdownText(fact.text)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(RenaissanceColors.parchment)
        )
        .borderAccent(radius: 16)
    }

    // MARK: - Question View

    private func questionView(_ question: LessonQuestion) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Science badge
            scienceChip(question.science)

            // Question text
            Text(question.question)
                .font(.custom("EBGaramond-SemiBold", size: 20))
                .foregroundStyle(RenaissanceColors.sepiaInk)
                .lineSpacing(2)

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
                            .font(.custom("EBGaramond-SemiBold", size: 17))
                            .foregroundStyle(selectedAnswer == question.correctIndex ? RenaissanceColors.sageGreen : RenaissanceColors.errorRed)
                    }

                    Text(question.explanation)
                        .font(.custom("EBGaramond-Regular", size: 16, relativeTo: .subheadline))
                        .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.8))
                        .lineSpacing(3)
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
                        .font(.custom("EBGaramond-Regular", size: 14, relativeTo: .footnote))
                    Text(showScratchPad ? "Hide Scratch Pad" : "Show Scratch Pad")
                        .font(.custom("EBGaramond-Regular", size: 15))
                }
                .foregroundStyle(RenaissanceColors.sepiaInk)
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
                            .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.4))
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
                            .fill(RenaissanceColors.parchment)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
                            .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.4))
                    )
                    .overlay(alignment: .topLeading, content: {
                        if scratchPadText.isEmpty {
                            Text("Show your work here...")
                                .font(.custom("EBGaramond-Regular", size: 15))
                                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.5))
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
                            .font(.custom("EBGaramond-Regular", size: 13, relativeTo: .footnote))
                        Text(hintLevel == 0 ? "Need a hint?" : "Next hint (\(hintLevel)/\(hints.count))")
                            .font(.custom("EBGaramond-Regular", size: 15))
                    }
                    .foregroundStyle(RenaissanceColors.sepiaInk)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(RenaissanceColors.ochre.opacity(0.1))
                    )
                    .borderCard(radius: 10)
                }
                .buttonStyle(.plain)
            } else if hintLevel > 0 {
                HStack(spacing: 6) {
                    Image(systemName: "lightbulb.slash")
                        .font(.custom("EBGaramond-Regular", size: 13, relativeTo: .footnote))
                    Text("All hints used")
                        .font(.custom("EBGaramond-Regular", size: 15))
                }
                .foregroundStyle(RenaissanceColors.sepiaInk)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
            }

            // Revealed hint cards
            ForEach(0..<hintLevel, id: \.self) { index in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "lightbulb.fill")
                        .font(.custom("EBGaramond-Regular", size: 12, relativeTo: .caption))
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                        .padding(.top, 2)

                    Text(hints[index])
                        .font(.custom("EBGaramond-Regular", size: 16, relativeTo: .subheadline))
                        .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.85))
                        .lineSpacing(3)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(RenaissanceColors.ochre.opacity(0.06))
                )
                .borderCard(radius: 10)
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
                    .font(.custom("EBGaramond-Regular", size: 16))
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
                    .font(.custom("EBGaramond-Regular", size: 16, relativeTo: .subheadline))
                    .foregroundStyle(RenaissanceColors.sepiaInk)
                    .multilineTextAlignment(.leading)

                Spacer()

                if isRevealed && isCorrect {
                    Image(systemName: "checkmark")
                        .font(.custom("EBGaramond-Bold", size: 14, relativeTo: .footnote))
                        .foregroundStyle(RenaissanceColors.sageGreen)
                }
                if isRevealed && isSelected && !isCorrect {
                    Image(systemName: "xmark")
                        .font(.custom("EBGaramond-Bold", size: 14, relativeTo: .footnote))
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
                    .font(.custom("EBGaramond-SemiBold", size: 20))
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
                        .font(.custom("EBGaramond-SemiBold", size: 18))
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
                        .foregroundStyle(correct ? RenaissanceColors.sageGreen : RenaissanceColors.sepiaInk)
                    Text(correct ? "All correct!" : "Some answers need fixing — tap a blank to change it")
                        .font(.custom("EBGaramond-Regular", size: 15, relativeTo: .subheadline))
                        .foregroundStyle(correct ? RenaissanceColors.sageGreen : RenaissanceColors.sepiaInk)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))

                if !allBlanksCorrect(activity) {
                    Button {
                        withAnimation {
                            blanksChecked = false
                        }
                    } label: {
                        Text("Try Again")
                            .font(.custom("EBGaramond-Regular", size: 14))
                            .foregroundStyle(RenaissanceColors.sepiaInk)
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
                .font(.custom("EBGaramond-Regular", size: 15))
                .foregroundStyle(RenaissanceColors.sepiaInk)

            LessonFlowLayout(spacing: 8) {
                ForEach(bank, id: \.self) { word in
                    let isUsed = usedWords.contains(word)
                    Button {
                        guard !isUsed else { return }
                        placeWord(word, from: activity)
                    } label: {
                        Text(word)
                            .font(.custom("EBGaramond-Regular", size: 16, relativeTo: .subheadline))
                            .foregroundStyle(isUsed ? RenaissanceColors.sepiaInk.opacity(0.4) : RenaissanceColors.sepiaInk)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(isUsed ? RenaissanceColors.sepiaInk.opacity(0.08) : RenaissanceColors.ochre.opacity(0.12))
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
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: frozenWordBank)
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

    // MARK: - Material Status

    private struct RecipeStatus: Identifiable {
        let id: CraftedItem
        let item: CraftedItem
        let alreadyCrafted: Bool
        let canCraft: Bool
        let missingMaterials: [Material: Int]  // what's still needed
    }

    private struct MaterialStatus {
        let recipeStatuses: [RecipeStatus]
        let shortfallRawMaterials: [Material: Int]
        let totalCostToBuy: Int
        let playerFlorins: Int

        var totalRecipes: Int { recipeStatuses.count }
        var readyCount: Int { recipeStatuses.filter { $0.alreadyCrafted || $0.canCraft }.count }
        var craftedCount: Int { recipeStatuses.filter { $0.alreadyCrafted }.count }

        var allCraftedReady: Bool { recipeStatuses.allSatisfy { $0.alreadyCrafted } }
        var hasAllRawMaterials: Bool { shortfallRawMaterials.isEmpty }
        var canAffordAll: Bool { playerFlorins >= totalCostToBuy }
        var hasSomeRawMaterials: Bool {
            // Player has collected some raw materials but not enough for all recipes
            readyCount > craftedCount || recipeStatuses.contains(where: { !$0.alreadyCrafted && !$0.missingMaterials.isEmpty && $0.missingMaterials.count < 4 })
        }
    }

    private var materialStatus: MaterialStatus {
        let ws = workshopState
        let required = plot.building.requiredMaterials
        let craftedOwned = ws?.craftedMaterials ?? [:]
        let rawOwned = ws?.rawMaterials ?? [:]

        var recipeStatuses: [RecipeStatus] = []
        var totalShortfall: [Material: Int] = [:]

        // Sort by crafted item name for stable display order
        for (item, needed) in required.sorted(by: { $0.key.rawValue < $1.key.rawValue }) {
            let have = craftedOwned[item] ?? 0
            if have >= needed {
                recipeStatuses.append(RecipeStatus(
                    id: item, item: item, alreadyCrafted: true,
                    canCraft: true, missingMaterials: [:]
                ))
                continue
            }

            // Check if player has raw materials for this recipe
            let qty = needed - have
            if let recipe = Recipe.allRecipes.first(where: { $0.output == item }) {
                var missing: [Material: Int] = [:]
                for (mat, count) in recipe.ingredients {
                    let need = count * qty
                    let owned = rawOwned[mat] ?? 0
                    if owned < need {
                        missing[mat] = need - owned
                        totalShortfall[mat, default: 0] += need - owned
                    }
                }
                recipeStatuses.append(RecipeStatus(
                    id: item, item: item, alreadyCrafted: false,
                    canCraft: missing.isEmpty, missingMaterials: missing
                ))
            } else {
                recipeStatuses.append(RecipeStatus(
                    id: item, item: item, alreadyCrafted: false,
                    canCraft: false, missingMaterials: [:]
                ))
            }
        }

        let cost = totalShortfall.reduce(0) { $0 + $1.key.cost * $1.value }

        return MaterialStatus(
            recipeStatuses: recipeStatuses,
            shortfallRawMaterials: totalShortfall,
            totalCostToBuy: cost,
            playerFlorins: viewModel.goldFlorins
        )
    }

    private func buyMissingMaterials() {
        let status = materialStatus
        guard viewModel.spendFlorins(status.totalCostToBuy) else { return }
        workshopState?.addRawMaterials(status.shortfallRawMaterials)
    }

    // MARK: - Environment Prompt View

    private func environmentPromptView(_ prompt: LessonEnvironmentPrompt) -> some View {
        let status = materialStatus
        let destColor = destinationColor(prompt.destination)

        // Determine state
        let promptState: EnvironmentPromptState = {
            if status.allCraftedReady {
                return .allReady
            } else if status.hasAllRawMaterials {
                return .canCraft
            } else if status.hasSomeRawMaterials {
                return .hasSome
            } else if status.canAffordAll {
                return .canBuy
            } else {
                return .broke
            }
        }()

        let stateIcon: String = {
            switch promptState {
            case .allReady: return "checkmark.seal.fill"
            case .canCraft: return "hammer.fill"
            case .hasSome: return "chart.bar.fill"
            case .canBuy: return "dollarsign.circle.fill"
            case .broke: return "map.fill"
            }
        }()

        let stateColor: Color = {
            switch promptState {
            case .allReady: return RenaissanceColors.sageGreen
            case .canCraft: return RenaissanceColors.renaissanceBlue
            case .hasSome: return RenaissanceColors.ochre
            case .canBuy: return RenaissanceColors.goldSuccess
            case .broke: return RenaissanceColors.stoneGray
            }
        }()

        let statusText: String = {
            switch promptState {
            case .allReady:
                return "All \(status.totalRecipes) materials crafted!"
            case .canCraft:
                return "\(status.readyCount) of \(status.totalRecipes) ready to craft"
            case .hasSome:
                return "\(status.readyCount) of \(status.totalRecipes) ready — collect more raw materials"
            case .canBuy:
                return "Missing materials cost \(status.totalCostToBuy) florins"
            case .broke:
                return "Explore to earn florins and collect materials"
            }
        }()

        let descriptionText: String = {
            switch prompt.destination {
            case .workshop:
                switch promptState {
                case .allReady: return prompt.description
                case .canCraft: return "You have enough raw materials. Head to the Crafting Room to combine them!"
                case .hasSome: return "Keep collecting from the quarry, volcano, river, and other stations."
                case .canBuy: return "You can buy the missing materials with your florins, or collect them at the Workshop."
                case .broke: return "Visit the Workshop to gather resources from the quarry, volcano, and river."
                }
            case .forest:
                switch promptState {
                case .allReady: return prompt.description
                case .canCraft: return "You have enough timber. Head to the Crafting Room to shape it into beams!"
                case .hasSome: return "Keep collecting timber from the forest."
                case .canBuy: return "You can buy timber with your florins, or collect it in the forest."
                case .broke: return "Explore the forest to collect timber for building."
                }
            case .craftingRoom:
                switch promptState {
                case .allReady: return prompt.description
                case .canCraft: return "Your raw materials are ready! Mix them at the workbench and fire them in the furnace."
                case .hasSome: return "You still need more raw materials before you can craft. Visit the Workshop first."
                case .canBuy: return "You're short on raw materials. Buy them or collect more at the Workshop first."
                case .broke: return "You need raw materials before crafting. Visit the Workshop to gather resources."
                }
            }
        }()

        return VStack(spacing: 8) {
            // Header: icon + title + status on one row
            HStack(spacing: 10) {
                Image(systemName: stateIcon)
                    .font(.custom("EBGaramond-Regular", size: 22, relativeTo: .title3))
                    .foregroundStyle(stateColor)
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(stateColor.opacity(0.1))
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(prompt.title)
                        .font(.custom("EBGaramond-SemiBold", size: 18))
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                        .lineLimit(1)

                    Text(statusText)
                        .font(.custom("EBGaramond-Medium", size: 13, relativeTo: .caption))
                        .foregroundStyle(stateColor)
                }

                Spacer()
            }

            // Description (short)
            Text(descriptionText)
                .font(.custom("EBGaramond-Regular", size: 15, relativeTo: .subheadline))
                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.8))
                .lineSpacing(2)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Compact recipe checklist
            VStack(alignment: .leading, spacing: 3) {
                ForEach(status.recipeStatuses) { recipe in
                    HStack(spacing: 6) {
                        Image(systemName: recipe.alreadyCrafted ? "checkmark.circle.fill"
                              : recipe.canCraft ? "hammer.circle.fill"
                              : "circle")
                            .font(.system(size: 13))
                            .foregroundStyle(recipe.alreadyCrafted ? RenaissanceColors.sageGreen
                                             : recipe.canCraft ? RenaissanceColors.renaissanceBlue
                                             : RenaissanceColors.stoneGray.opacity(0.5))

                        Text(recipe.item.rawValue)
                            .font(.custom("EBGaramond-Medium", size: 13, relativeTo: .caption))
                            .foregroundStyle(recipe.alreadyCrafted ? RenaissanceColors.sageGreen
                                             : RenaissanceColors.sepiaInk)

                        Spacer()

                        if recipe.canCraft && !recipe.alreadyCrafted {
                            Text("Ready")
                                .font(.custom("EBGaramond-Regular", size: 11))
                                .foregroundStyle(RenaissanceColors.sepiaInk)
                        } else if !recipe.alreadyCrafted && !recipe.missingMaterials.isEmpty {
                            let names = recipe.missingMaterials
                                .sorted(by: { $0.key.rawValue < $1.key.rawValue })
                                .map { "\($0.value) \($0.key.rawValue)" }
                                .joined(separator: ", ")
                            Text(names)
                                .font(.custom("EBGaramond-Regular", size: 11))
                                .foregroundStyle(RenaissanceColors.sepiaInk)
                                .lineLimit(1)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                }
            }
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(RenaissanceColors.sepiaInk.opacity(0.02))
            )

            // Buttons row
            HStack(spacing: 8) {
                // Primary navigation button
                Button {
                    onDismiss()
                    if promptState == .canCraft {
                        onNavigate?(.workshop)
                    } else {
                        navigateToDestination(prompt.destination)
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: prompt.icon)
                            .font(.system(size: 13))
                        Text(primaryButtonLabel(promptState, destination: prompt.destination))
                            .font(.custom("EBGaramond-Regular", size: 16))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(destColor)
                    )
                }
                .buttonStyle(.plain)

                if promptState == .canBuy {
                    Button {
                        buyMissingMaterials()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "dollarsign.circle.fill")
                                .font(.system(size: 13))
                            Text("Buy (\(status.totalCostToBuy) f)")
                                .font(.custom("EBGaramond-Regular", size: 16))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(RenaissanceColors.goldSuccess)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(destColor.opacity(0.04))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(destColor.opacity(0.15), lineWidth: 1)
        )
    }

    private enum EnvironmentPromptState {
        case allReady, canCraft, hasSome, canBuy, broke
    }

    private func primaryButtonLabel(_ state: EnvironmentPromptState, destination: LessonDestination) -> String {
        switch state {
        case .allReady:
            return "Visit \(destination.rawValue.capitalized)"
        case .canCraft:
            return "Visit Crafting Room"
        case .hasSome:
            return destination == .forest ? "Visit Forest" : "Visit Workshop"
        case .canBuy:
            return destination == .forest ? "Visit Forest" : "Visit Workshop"
        case .broke:
            return "Explore"
        }
    }

    private func navigateToDestination(_ dest: LessonDestination) {
        switch dest {
        case .workshop: onNavigate?(.workshop)
        case .forest: onNavigate?(.forest)
        case .craftingRoom: onNavigate?(.workshop)
        }
    }

    private func destinationColor(_ dest: LessonDestination) -> Color {
        switch dest {
        case .workshop: return RenaissanceColors.warmBrown
        case .forest: return RenaissanceColors.sageGreen
        case .craftingRoom: return RenaissanceColors.renaissanceBlue
        }
    }

    // MARK: - Curiosity Q&A ("Students Also Ask")

    @State private var curiosityExpanded = false  // card-level expand/collapse

    private func curiosityView(_ curiosity: LessonCuriosity) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header — tap to reveal/hide questions
            Button {
                withAnimation(.spring(response: 0.3)) {
                    curiosityExpanded.toggle()
                    if !curiosityExpanded { expandedCuriosityIndex = nil }
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "questionmark.bubble.fill")
                        .font(.custom("EBGaramond-Regular", size: 18, relativeTo: .body))
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                    Text("Students Also Ask")
                        .font(.custom("EBGaramond-SemiBold", size: 18))
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                    Spacer()
                    Image(systemName: curiosityExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.5))
                }
            }
            .buttonStyle(.plain)

            // Questions — only shown when card is expanded
            if curiosityExpanded {
                ForEach(Array(curiosity.questions.enumerated()), id: \.offset) { index, qa in
                    VStack(alignment: .leading, spacing: 0) {
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
                                    .font(.custom("EBGaramond-Medium", size: 16, relativeTo: .subheadline))
                                    .foregroundStyle(RenaissanceColors.sepiaInk)
                                    .multilineTextAlignment(.leading)

                                Spacer()

                                Image(systemName: expandedCuriosityIndex == index ? "chevron.up" : "chevron.down")
                                    .font(.custom("EBGaramond-SemiBold", size: 12, relativeTo: .caption))
                                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.6))
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                        }
                        .buttonStyle(.plain)

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
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(RenaissanceColors.renaissanceBlue.opacity(0.03))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(RenaissanceColors.renaissanceBlue.opacity(0.12), lineWidth: 1)
        )
    }

    // MARK: - Continue Button

    private var continueButton: some View {
        Group {
            if canContinue {
                Button {
                    advance()
                } label: {
                    Text(currentIndex < pages.count - 1 ? "Continue" : "Finish Lesson")
                        .font(.custom("EBGaramond-SemiBold", size: 18))
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(RenaissanceColors.ochre.opacity(0.2))
                        )
                        .borderAccent(radius: 12)
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
                    .font(.custom("EBGaramond-Regular", size: 60, relativeTo: .title3))
                    .foregroundStyle(RenaissanceColors.goldSuccess)

                Text("Lesson Complete!")
                    .font(.custom("Cinzel-Regular", size: 26))
                    .foregroundStyle(RenaissanceColors.sepiaInk)

                // Science badges earned
                VStack(spacing: 8) {
                    Text("Sciences Studied")
                        .font(.custom("EBGaramond-Regular", size: 16))
                        .foregroundStyle(RenaissanceColors.sepiaInk)

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
                                        .font(.custom("EBGaramond-Regular", size: 24, relativeTo: .title3))
                                        .foregroundStyle(RenaissanceColors.sepiaInk)
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
                                .font(.custom("EBGaramond-Regular", size: 16, relativeTo: .subheadline))
                            Text(alreadyRead ? "Done" : "Claim Reward")
                                .font(.custom("EBGaramond-SemiBold", size: 20))
                            if !alreadyRead {
                                Text("+\(GameRewards.lessonReadFlorins)")
                                    .font(.custom("EBGaramond-SemiBold", size: 18))
                                    .foregroundStyle(RenaissanceColors.goldSuccess)
                                Image(systemName: "dollarsign.circle.fill")
                                    .font(.custom("EBGaramond-Regular", size: 16, relativeTo: .subheadline))
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
                        .borderAccent(radius: 14)
                    }
                    .buttonStyle(.plain)
                }

                if hasClaimedReward {
                    VStack(spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(RenaissanceColors.sageGreen)
                            Text("Knowledge earned!")
                                .font(.custom("EBGaramond-SemiBold", size: 18))
                                .foregroundStyle(RenaissanceColors.sageGreen)
                        }

                        HStack(spacing: 4) {
                            ForEach(plot.building.sciences, id: \.self) { _ in
                                Image(systemName: "seal.fill")
                                    .font(.custom("EBGaramond-Regular", size: 14, relativeTo: .footnote))
                                    .foregroundStyle(RenaissanceColors.sepiaInk)
                            }
                            Text("\(plot.building.sciences.count) science badges")
                                .font(.custom("EBGaramond-Regular", size: 13))
                                .foregroundStyle(RenaissanceColors.sepiaInk)
                        }

                        // View in Notebook button
                        if notebookState != nil {
                            Button {
                                onDismiss()
                                onNavigate?(.notebook(plot.id))
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "book.closed.fill")
                                        .font(.custom("EBGaramond-Regular", size: 14, relativeTo: .footnote))
                                    Text("View in Notebook")
                                        .font(.custom("EBGaramond-Regular", size: 16))
                                }
                                .foregroundStyle(RenaissanceColors.sepiaInk)
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
                        .font(.custom("EBGaramond-Regular", size: 16))
                        .foregroundStyle(RenaissanceColors.sepiaInk)
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
        stopWordBankShuffleTimer()
        expandedCuriosityIndex = nil
        curiosityExpanded = false
        mathVisualStep = 1
    }

    /// Shuffle the word bank and start a periodic reshuffle timer
    private func freezeWordBankIfNeeded() {
        guard currentIndex < pages.count else { return }
        for section in pages[currentIndex] {
            if case .fillInBlanks(let activity) = section {
                frozenWordBank = (activity.correctWords + activity.distractors).shuffled()
                startWordBankShuffleTimer()
                return
            }
        }
    }

    private func startWordBankShuffleTimer() {
        wordBankShuffleTimer?.invalidate()
        wordBankShuffleTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            let usedWords = Set(blankAnswers.values)
            // Only reshuffle if there are still unused words to move around
            let unusedCount = frozenWordBank.filter { !usedWords.contains($0) }.count
            guard unusedCount > 1 else {
                wordBankShuffleTimer?.invalidate()
                wordBankShuffleTimer = nil
                return
            }
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                frozenWordBank.shuffle()
            }
        }
    }

    private func stopWordBankShuffleTimer() {
        wordBankShuffleTimer?.invalidate()
        wordBankShuffleTimer = nil
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
                    .font(.custom("EBGaramond-Regular", size: 11, relativeTo: .caption))
                    .foregroundStyle(RenaissanceColors.sepiaInk)
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
                    .font(.custom("EBGaramond-Bold", size: 17, relativeTo: .body))
                    .foregroundColor(RenaissanceColors.sepiaInk)
            } else {
                return result + Text(part.text)
                    .font(.custom("EBGaramond-Regular", size: 17, relativeTo: .body))
                    .foregroundColor(RenaissanceColors.sepiaInk)
            }
        }
        .tracking(0.15)
        .lineSpacing(2)
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
                                .font(.custom("EBGaramond-SemiBold", size: 16, relativeTo: .subheadline))
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
                                .font(.custom("EBGaramond-Regular", size: 16, relativeTo: .subheadline))
                                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.5))
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
                        .font(.custom("EBGaramond-Regular", size: 17, relativeTo: .body))
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                        .lineSpacing(2)
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
        canvas.backgroundColor = UIColor(RenaissanceColors.parchment)
        canvas.tool = PKInkingTool(.pen, color: UIColor(RenaissanceColors.sepiaInk), width: 2)
        return canvas
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {}
}
#endif
