import SwiftUI
import Subsonic

// MARK: - Fishing Bubble Model

struct ScrambleTile: Identifiable {
    let id = UUID()
    let character: Character
}

struct FishingBubble: Identifiable {
    let id = UUID()
    let number: Int
    let isCorrect: Bool
    var offset: CGSize
}

/// Reusable overlay that displays Knowledge Cards with 3D flip, lessons, and activities.
/// Adapts the proven ForestMapView science card pattern for any KnowledgeCard set.
///
/// Usage: Show this overlay when a player visits a location that has knowledge cards.
/// Cards flip to show a lesson, then a keyword-match or quiz activity.
/// Completed cards save their `notebookSummary` to the notebook.
struct KnowledgeCardsOverlay: View {

    let cards: [KnowledgeCard]
    let buildingId: Int
    @ObservedObject var viewModel: CityViewModel
    var notebookState: NotebookState? = nil
    let onDismiss: () -> Void
    /// Called when all cards in this set are complete
    var onAllComplete: (() -> Void)? = nil

    // MARK: - Card Layout

    private let cardW: CGFloat = 200
    private let cardH: CGFloat = 280
    private let flippedW: CGFloat = 560
    private let flippedH: CGFloat = 780

    // MARK: - Card State

    @State private var flipAngles: [String: Double] = [:]      // card.id → angle
    @State private var flippedOpenCard: String? = nil           // which card is flipped open
    @State private var cardPhases: [String: CardPhase] = [:]   // card.id → phase
    @State private var completedCardIDs: Set<String> = []
    @State private var cardsAppeared = false
    @State private var floatOffset: CGFloat = 0
    @State private var auroraPhase = false

    // MARK: - Activity State

    @State private var matchedPairIDs: Set<UUID> = []
    @State private var selectedKeywordID: UUID? = nil
    @State private var selectedDefinitionID: UUID? = nil
    @State private var shuffledDefinitions: [KeywordPair] = []
    @State private var wrongMatchFlash = false
    @State private var earnedFlorinsFloat: Int? = nil

    // Multiple choice / true-false
    @State private var selectedMCIndex: Int? = nil
    @State private var mcAnswered = false
    @State private var tfAnswered = false
    @State private var tfSelected: Bool? = nil

    // Word Scramble
    @State private var scramblePool: [ScrambleTile] = []
    @State private var spelledTiles: [ScrambleTile] = []
    @State private var scrambleWrongFlash = false

    // Number Fishing
    @State private var fishingBubbles: [FishingBubble] = []
    @State private var fishingAnswered = false
    @State private var fishingSunkIDs: Set<UUID> = []
    @State private var fishingTimer: Timer?

    // Hangman
    @State private var hangmanGuessed: Set<Character> = []
    @State private var hangmanWrongCount: Int = 0
    @State private var hangmanRevealed = false
    @State private var hangmanWon = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Dimmed background
                RenaissanceColors.overlayDimming
                    .ignoresSafeArea()
                    .onTapGesture { handleBackgroundTap() }

                VStack(spacing: 16) {
                    Spacer()

                    // Bird encouragement
                    birdEncouragement

                    // Card progress
                    cardProgressBar

                    // Cards row
                    cardsRowView(screenSize: geo.size)

                    Spacer()

                    // Floating florins feedback
                    if let florins = earnedFlorinsFloat {
                        Text("+\(florins) florins")
                            .font(.custom("Cinzel-Bold", size: 20))
                            .foregroundStyle(RenaissanceColors.goldSuccess)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    // Next environment hint
                    if completedCardIDs.count == cards.count && !cards.isEmpty {
                        nextEnvironmentHint
                    }

                    Spacer()
                }
            }
        }
        .onAppear {
            // Load already-completed cards from progress
            let progress = viewModel.buildingProgressMap[buildingId] ?? BuildingProgress()
            completedCardIDs = progress.completedCardIDs.intersection(Set(cards.map { $0.id }))

            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                floatOffset = 8
            }
            auroraPhase = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                SubsonicController.shared.play(sound: "cards_appear.mp3")
                withAnimation(.spring(response: 0.5, dampingFraction: 0.65)) {
                    cardsAppeared = true
                }
            }
        }
        .onDisappear {
            fishingTimer?.invalidate()
            fishingTimer = nil
        }
    }

    // MARK: - Cards Row (3D flip + pile)

    private func cardsRowView(screenSize: CGSize) -> some View {
        let spacing: CGFloat = 16
        let totalWidth = CGFloat(cards.count) * cardW + CGFloat(max(cards.count - 1, 0)) * spacing

        return ZStack {
            // Connection line behind spread cards
            if flippedOpenCard == nil {
                Rectangle()
                    .fill(RenaissanceColors.ochre.opacity(0.2))
                    .frame(width: max(totalWidth - 60, 0), height: 2)
            }

            ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                let isCompleted = completedCardIDs.contains(card.id)
                let isThisFlipped = flippedOpenCard == card.id
                let someCardFlipped = flippedOpenCard != nil
                let isPiled = someCardFlipped && !isThisFlipped
                let angle = flipAngles[card.id] ?? 0

                let spreadX = CGFloat(index) * (cardW + spacing) - (totalWidth - cardW) / 2
                let pileX = -screenSize.width * 0.35 + CGFloat(pileStackIndex(card.id)) * 8

                ZStack {
                    // 3D FLIP VISUAL — front and back with full 3D rotation (non-interactive back)
                    ZStack {
                        // FRONT face
                        cardFront(card: card, isCompleted: isCompleted)
                            .frame(width: cardW, height: cardH)
                            .opacity(angle < 90 ? 1 : 0)
                            .allowsHitTesting(angle < 90)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                handleCardTap(card: card, isCompleted: isCompleted)
                            }

                        // BACK face — visual only, no interaction (3D breaks macOS clicks)
                        flippedCardBack(card: card, isCompleted: isCompleted)
                            .frame(width: flippedW, height: flippedH)
                            .scaleEffect(isThisFlipped ? 1.0 : 0.15)
                            .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                            .opacity(angle >= 90 ? 1 : 0)
                            .allowsHitTesting(false)
                            .animation(.spring(response: 0.5, dampingFraction: 0.7), value: isThisFlipped)
                    }
                    .rotation3DEffect(.degrees(angle), axis: (x: 0, y: 1, z: 0), perspective: 0.4)

                    // FLAT INTERACTIVE OVERLAY — appears when fully flipped, receives all clicks
                    if isThisFlipped && angle >= 90 {
                        flippedCardBack(card: card, isCompleted: isCompleted)
                            .frame(width: flippedW, height: flippedH)
                    }
                }
                .scaleEffect(isPiled ? 0.5 : 1.0)
                .offset(
                    x: someCardFlipped ? (isPiled ? pileX : 0) : spreadX,
                    y: isPiled ? CGFloat(pileStackIndex(card.id)) * 5 : floatOffset * (index.isMultiple(of: 2) ? 1 : -1)
                )
                .rotation3DEffect(.degrees(isPiled ? -5 + Double(pileStackIndex(card.id)) * 3 : 0), axis: (x: 0, y: 0, z: 1))
                .opacity(isPiled ? 0.65 : 1.0)
                .zIndex(isThisFlipped ? 10 : Double(isPiled ? pileStackIndex(card.id) : index))
                .scaleEffect(cardsAppeared ? 1.0 : 0.2)
                .opacity(cardsAppeared ? 1.0 : 0)
                .animation(
                    .spring(response: 0.5, dampingFraction: 0.65).delay(Double(index) * 0.1),
                    value: cardsAppeared
                )
                .animation(.spring(response: 0.6, dampingFraction: 0.75), value: flippedOpenCard)
                .animation(.spring(response: 0.6, dampingFraction: 0.75), value: flipAngles[card.id])
            }
        }
    }

    private func pileStackIndex(_ cardId: String) -> Int {
        let others = cards.filter { $0.id != flippedOpenCard }
        return others.firstIndex(where: { $0.id == cardId }) ?? 0
    }

    // MARK: - Card Tap

    private func handleCardTap(card: KnowledgeCard, isCompleted: Bool) {
        if isCompleted && flippedOpenCard != card.id { return }

        if flippedOpenCard == card.id {
            // Unflip
            SubsonicController.shared.play(sound: "card_flip.mp3")
            withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
                flipAngles[card.id] = 0
                flippedOpenCard = nil
            }
        } else {
            // Unflip current
            if let current = flippedOpenCard {
                flipAngles[current] = 0
            }
            // Flip this card
            SubsonicController.shared.play(sound: "card_flip.mp3")
            withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
                flippedOpenCard = card.id
                flipAngles[card.id] = 180
                cardPhases[card.id] = .reading
            }
        }
    }

    private func handleBackgroundTap() {
        if let open = flippedOpenCard, cardPhases[open] == .activity {
            withAnimation(.easeInOut(duration: 0.4)) {
                cardPhases[open] = .reading
            }
        } else if let open = flippedOpenCard {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
                flipAngles[open] = 0
                flippedOpenCard = nil
            }
        } else {
            onDismiss()
        }
    }

    // MARK: - Card Front

    private func cardFront(card: KnowledgeCard, isCompleted: Bool) -> some View {
        let color = card.color
        return ZStack {
            RoundedRectangle(cornerRadius: 14)
                .fill(isCompleted ? RenaissanceColors.sageGreen.opacity(0.06) : RenaissanceColors.parchmentLight.opacity(0.5))
                .overlay(
                    Group {
                        if !isCompleted {
                            RoundedRectangle(cornerRadius: 14).fill(.ultraThinMaterial)
                        }
                    }
                )
                .overlay(
                    ZStack {
                        if !isCompleted {
                            Ellipse()
                                .fill(color.opacity(0.55))
                                .frame(width: 180, height: 120)
                                .blur(radius: 38)
                                .offset(x: auroraPhase ? 40 : -30, y: auroraPhase ? 100 : 130)
                                .animation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true), value: auroraPhase)
                            Ellipse()
                                .fill(color.opacity(0.4))
                                .frame(width: 128, height: 165)
                                .blur(radius: 33)
                                .offset(x: auroraPhase ? -35 : 25, y: auroraPhase ? 110 : 140)
                                .animation(.easeInOut(duration: 5.5).repeatForever(autoreverses: true), value: auroraPhase)
                            Ellipse()
                                .fill(RenaissanceColors.goldSuccess.opacity(0.3))
                                .frame(width: 135, height: 90)
                                .blur(radius: 36)
                                .offset(x: auroraPhase ? 20 : -40, y: auroraPhase ? 105 : 135)
                                .animation(.easeInOut(duration: 6.5).repeatForever(autoreverses: true), value: auroraPhase)
                            Circle()
                                .fill(Color.white.opacity(0.25))
                                .frame(width: 82, height: 82)
                                .blur(radius: 27)
                                .offset(x: auroraPhase ? -15 : 30, y: auroraPhase ? 115 : 120)
                                .animation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true), value: auroraPhase)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                )

            VStack(spacing: 12) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(isCompleted ? RenaissanceColors.sageGreen.opacity(0.2) : color.opacity(0.15))
                        .frame(width: 70, height: 70)
                    Image(systemName: isCompleted ? "checkmark.circle.fill" : card.icon)
                        .font(.system(size: 36))
                        .foregroundStyle(isCompleted ? RenaissanceColors.sageGreen : color)
                        .shadow(color: isCompleted ? .clear : color.opacity(0.5), radius: 6)
                }

                Text(card.title)
                    .font(.custom("Cinzel-Bold", size: 14))
                    .foregroundStyle(isCompleted ? RenaissanceColors.sageGreen : color)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)

                Text(card.science.rawValue)
                    .font(.custom("EBGaramond-Regular", size: 11))
                    .foregroundStyle(color.opacity(0.7))

                if !isCompleted {
                    Image(systemName: "hand.tap.fill")
                        .font(.system(size: 13))
                        .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.3))
                }

                Spacer()
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(isCompleted ? RenaissanceColors.sageGreen.opacity(0.4) : color.opacity(0.3), lineWidth: 1.5)
        )
        .shadow(color: isCompleted ? .clear : color.opacity(0.5), radius: 20, y: 6)
        .shadow(color: isCompleted ? .clear : color.opacity(0.3), radius: 40, y: 10)
    }

    // MARK: - Card Back (reading ↔ activity)

    private func flippedCardBack(card: KnowledgeCard, isCompleted: Bool) -> some View {
        let isActivity = cardPhases[card.id] == .activity
        let color = card.color

        return VStack(spacing: 0) {
            // Header
            HStack(spacing: 8) {
                Image(systemName: card.icon)
                    .font(.system(size: 16))
                Text(card.title)
                    .font(.custom("Cinzel-Bold", size: 16))
                    .lineLimit(1)
                Spacer()
                if isActivity {
                    Button {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            cardPhases[card.id] = .reading
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.left").font(.system(size: 12))
                            Text("Lesson").font(.custom("EBGaramond-Medium", size: 13))
                        }
                        .foregroundStyle(color.opacity(0.6))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
                if isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(RenaissanceColors.sageGreen)
                }
            }
            .foregroundStyle(color)
            .padding(.top, 12)
            .padding(.bottom, 6)
            .padding(.horizontal, 4)

            Rectangle()
                .fill(color.opacity(0.2))
                .frame(height: 1)
                .padding(.horizontal, 8)

            // Content
            ZStack {
                if !isActivity {
                    readingContent(card: card, isCompleted: isCompleted)
                        .transition(.opacity)
                }
                if isActivity {
                    ScrollView(.vertical, showsIndicators: false) {
                        activityContent(card: card)
                    }
                    .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.4), value: isActivity)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14).fill(RenaissanceColors.parchment)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14).stroke(color.opacity(0.4), lineWidth: 2)
        )
        .shadow(color: color.opacity(0.15), radius: 8, y: 3)
    }

    // MARK: - Reading Content

    private func readingContent(card: KnowledgeCard, isCompleted: Bool) -> some View {
        VStack(spacing: 0) {
            // Keyword circles
            HStack(spacing: 10) {
                ForEach(card.keywords.prefix(4)) { pair in
                    VStack(spacing: 3) {
                        Circle()
                            .fill(card.color.opacity(0.1))
                            .frame(width: 36, height: 36)
                            .overlay(
                                Image(systemName: card.icon)
                                    .font(.system(size: 14))
                                    .foregroundStyle(card.color.opacity(0.5))
                            )
                        Text(pair.keyword)
                            .font(.custom("EBGaramond-SemiBold", size: 9))
                            .foregroundStyle(card.color)
                            .lineLimit(1)
                    }
                }
            }
            .padding(.vertical, 8)

            Rectangle()
                .fill(card.color.opacity(0.1))
                .frame(height: 1)
                .padding(.horizontal, 8)

            // Lesson text
            ScrollView(.vertical, showsIndicators: false) {
                highlightedLessonText(card: card)
                    .padding(.top, 8)
            }

            Spacer(minLength: 6)

            if !isCompleted {
                Button {
                    openActivity(for: card)
                } label: {
                    Text("Done Reading")
                        .font(.custom("EBGaramond-SemiBold", size: 16))
                        .foregroundStyle(.white)
                        .padding(.vertical, 14)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 9).fill(card.color)
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Highlighted Lesson Text

    private func highlightedLessonText(card: KnowledgeCard) -> Text {
        let lesson = card.lessonText
        let keywords = card.keywords.map { $0.keyword }
        let color = card.color

        var segments: [(String, Bool)] = []
        var remaining = lesson

        while !remaining.isEmpty {
            var earliestRange: Range<String.Index>? = nil
            for kw in keywords {
                if let range = remaining.range(of: kw, options: .caseInsensitive) {
                    if earliestRange == nil || range.lowerBound < earliestRange!.lowerBound {
                        earliestRange = range
                    }
                }
            }
            if let range = earliestRange {
                let before = String(remaining[remaining.startIndex..<range.lowerBound])
                if !before.isEmpty { segments.append((before, false)) }
                segments.append((String(remaining[range]), true))
                remaining = String(remaining[range.upperBound...])
            } else {
                segments.append((remaining, false))
                remaining = ""
            }
        }

        var result = Text("")
        for (text, isKeyword) in segments {
            if isKeyword {
                result = result + Text(text)
                    .font(.custom("EBGaramond-SemiBold", size: 15))
                    .foregroundColor(color)
            } else {
                result = result + Text(text)
                    .font(.custom("EBGaramond-Regular", size: 15))
                    .foregroundColor(RenaissanceColors.sepiaInk)
            }
        }
        return result
    }

    // MARK: - Activity Content (dispatches by type)

    @ViewBuilder
    private func activityContent(card: KnowledgeCard) -> some View {
        switch card.activity {
        case .keywordMatch:
            keywordMatchView(card: card)
        case .multipleChoice(let question, let options, let correctIndex):
            multipleChoiceView(card: card, question: question, options: options, correctIndex: correctIndex)
        case .trueFalse(let statement, let isTrue):
            trueFalseView(card: card, statement: statement, isTrue: isTrue)
        case .fillInBlanks:
            keywordMatchView(card: card)
        case .wordScramble(let word, let hint):
            wordScrambleView(card: card, word: word, hint: hint)
        case .numberFishing(let question, let correct, let decoys):
            numberFishingView(card: card, question: question, correctAnswer: correct, decoys: decoys)
        case .hangman(let word, let hint):
            hangmanView(card: card, word: word, hint: hint)
        }
    }

    // MARK: - Keyword Match Activity

    private func keywordMatchView(card: KnowledgeCard) -> some View {
        VStack(spacing: 10) {
            Text("Match each term to its meaning")
                .font(.custom("EBGaramond-Medium", size: 12))
                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.6))

            // Keywords
            VStack(spacing: 6) {
                ForEach(card.keywords) { pair in
                    let isMatched = matchedPairIDs.contains(pair.id)
                    let isSelected = selectedKeywordID == pair.id

                    Button {
                        if !isMatched { selectKeyword(pair.id, card: card) }
                    } label: {
                        HStack {
                            Image(systemName: isMatched ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 16))
                                .foregroundStyle(isMatched ? RenaissanceColors.sageGreen : card.color.opacity(0.4))
                            Text(pair.keyword)
                                .font(.custom("EBGaramond-SemiBold", size: 15))
                                .foregroundStyle(
                                    isMatched ? RenaissanceColors.sageGreen
                                    : isSelected ? card.color
                                    : RenaissanceColors.sepiaInk
                                )
                            Spacer()
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(
                                    isMatched ? RenaissanceColors.sageGreen.opacity(0.08)
                                    : isSelected ? card.color.opacity(0.12)
                                    : RenaissanceColors.ochre.opacity(0.04)
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(isSelected ? card.color.opacity(0.6) : Color.clear, lineWidth: 1.5)
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(isMatched)
                    .opacity(isMatched ? 0.6 : 1)
                }
            }

            // Arrow divider
            HStack {
                Rectangle().fill(RenaissanceColors.sepiaInk.opacity(0.1)).frame(height: 1)
                Image(systemName: "arrow.down")
                    .font(.system(size: 11))
                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.25))
                Rectangle().fill(RenaissanceColors.sepiaInk.opacity(0.1)).frame(height: 1)
            }

            // Definitions (shuffled)
            VStack(spacing: 6) {
                ForEach(shuffledDefinitions) { pair in
                    let isMatched = matchedPairIDs.contains(pair.id)
                    let isSelected = selectedDefinitionID == pair.id
                    let isWrong = wrongMatchFlash && isSelected

                    Button {
                        if !isMatched { selectDefinition(pair.id, card: card) }
                    } label: {
                        HStack {
                            Text(pair.definition)
                                .font(.custom("EBGaramond-Regular", size: 14))
                                .foregroundStyle(
                                    isWrong ? RenaissanceColors.errorRed
                                    : isMatched ? RenaissanceColors.sageGreen
                                    : isSelected ? card.color
                                    : RenaissanceColors.sepiaInk.opacity(0.8)
                                )
                                .multilineTextAlignment(.leading)
                            Spacer()
                            if isMatched {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundStyle(RenaissanceColors.sageGreen)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(
                                    isWrong ? RenaissanceColors.errorRed.opacity(0.08)
                                    : isMatched ? RenaissanceColors.sageGreen.opacity(0.08)
                                    : isSelected ? card.color.opacity(0.08)
                                    : RenaissanceColors.ochre.opacity(0.04)
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(
                                    isWrong ? RenaissanceColors.errorRed.opacity(0.5)
                                    : isSelected ? card.color.opacity(0.5)
                                    : Color.clear,
                                    lineWidth: 1.5
                                )
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(isMatched)
                    .opacity(isMatched ? 0.6 : 1)
                }
            }

            // Progress dots
            progressDots(total: card.keywords.count, matched: matchedPairIDs.count)
        }
    }

    // MARK: - Multiple Choice Activity

    private func multipleChoiceView(card: KnowledgeCard, question: String, options: [String], correctIndex: Int) -> some View {
        VStack(spacing: 12) {
            Text(question)
                .font(.custom("EBGaramond-SemiBold", size: 15))
                .foregroundStyle(RenaissanceColors.sepiaInk)
                .multilineTextAlignment(.center)
                .padding(.top, 8)

            ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                let isCorrect = index == correctIndex
                let isSelected = selectedMCIndex == index
                let showResult = mcAnswered

                Button {
                    guard !mcAnswered else { return }
                    selectedMCIndex = index
                    mcAnswered = true
                    if isCorrect {
                        SubsonicController.shared.play(sound: "correct_chime.mp3")
                        awardFlorins(GameRewards.scienceCardMatchFlorins * 2)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            completeCard(card)
                        }
                    } else {
                        SubsonicController.shared.play(sound: "wrong_buzz.mp3")
                    }
                } label: {
                    HStack {
                        Text(option)
                            .font(.custom("EBGaramond-Regular", size: 15))
                            .foregroundStyle(
                                showResult && isCorrect ? RenaissanceColors.sageGreen
                                : showResult && isSelected && !isCorrect ? RenaissanceColors.errorRed
                                : RenaissanceColors.sepiaInk
                            )
                        Spacer()
                        if showResult && isCorrect {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(RenaissanceColors.sageGreen)
                        } else if showResult && isSelected && !isCorrect {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(RenaissanceColors.errorRed)
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                showResult && isCorrect ? RenaissanceColors.sageGreen.opacity(0.1)
                                : showResult && isSelected && !isCorrect ? RenaissanceColors.errorRed.opacity(0.1)
                                : RenaissanceColors.ochre.opacity(0.04)
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                showResult && isCorrect ? RenaissanceColors.sageGreen.opacity(0.5)
                                : showResult && isSelected && !isCorrect ? RenaissanceColors.errorRed.opacity(0.5)
                                : Color.clear,
                                lineWidth: 1.5
                            )
                    )
                }
                .buttonStyle(.plain)
            }

            // Retry if wrong
            if mcAnswered && selectedMCIndex != correctIndex {
                Button {
                    mcAnswered = false
                    selectedMCIndex = nil
                } label: {
                    Text("Try Again")
                        .font(.custom("EBGaramond-SemiBold", size: 15))
                        .foregroundStyle(card.color)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(card.color.opacity(0.08))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(card.color.opacity(0.3), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
                .padding(.top, 6)
            }
        }
    }

    // MARK: - True/False Activity

    private func trueFalseView(card: KnowledgeCard, statement: String, isTrue: Bool) -> some View {
        VStack(spacing: 16) {
            Text(statement)
                .font(.custom("EBGaramond-Regular", size: 15))
                .foregroundStyle(RenaissanceColors.sepiaInk)
                .multilineTextAlignment(.center)
                .padding(.top, 8)

            HStack(spacing: 16) {
                ForEach([true, false], id: \.self) { value in
                    let label = value ? "True" : "False"
                    let isCorrect = value == isTrue
                    let isSelected = tfSelected == value
                    let showResult = tfAnswered

                    Button {
                        guard !tfAnswered else { return }
                        tfSelected = value
                        tfAnswered = true
                        if isCorrect {
                            SubsonicController.shared.play(sound: "correct_chime.mp3")
                            awardFlorins(GameRewards.scienceCardMatchFlorins * 2)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                completeCard(card)
                            }
                        } else {
                            SubsonicController.shared.play(sound: "wrong_buzz.mp3")
                        }
                    } label: {
                        Text(label)
                            .font(.custom("EBGaramond-SemiBold", size: 16))
                            .foregroundStyle(
                                showResult && isCorrect ? RenaissanceColors.sageGreen
                                : showResult && isSelected && !isCorrect ? RenaissanceColors.errorRed
                                : card.color
                            )
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(
                                        showResult && isCorrect ? RenaissanceColors.sageGreen.opacity(0.1)
                                        : showResult && isSelected && !isCorrect ? RenaissanceColors.errorRed.opacity(0.1)
                                        : card.color.opacity(0.08)
                                    )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(
                                        showResult && isCorrect ? RenaissanceColors.sageGreen.opacity(0.5)
                                        : showResult && isSelected && !isCorrect ? RenaissanceColors.errorRed.opacity(0.5)
                                        : card.color.opacity(0.3),
                                        lineWidth: 1.5
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                }
            }

            // Retry if wrong
            if tfAnswered && tfSelected != isTrue {
                Button {
                    tfAnswered = false
                    tfSelected = nil
                } label: {
                    Text("Try Again")
                        .font(.custom("EBGaramond-SemiBold", size: 15))
                        .foregroundStyle(card.color)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(card.color.opacity(0.08))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(card.color.opacity(0.3), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Word Scramble Activity

    private func wordScrambleView(card: KnowledgeCard, word: String, hint: String) -> some View {
        let upperWord = word.uppercased()
        let color = card.color

        return VStack(spacing: 14) {
            // Hint
            Text(hint)
                .font(.custom("EBGaramond-Regular", size: 14))
                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.top, 4)

            // Dashes showing progress
            HStack(spacing: 6) {
                ForEach(Array(upperWord.enumerated()), id: \.offset) { index, _ in
                    let filled = index < spelledTiles.count
                    Text(filled ? String(spelledTiles[index].character) : "_")
                        .font(.custom("Cinzel-Bold", size: 22))
                        .foregroundStyle(filled ? color : RenaissanceColors.sepiaInk.opacity(0.3))
                        .frame(width: 28, height: 36)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(filled ? color.opacity(0.08) : RenaissanceColors.ochre.opacity(0.04))
                        )
                }
            }

            // Scrambled letter tiles
            let colCount = max(min(scramblePool.count, 6), 1)
            let columns = Array(repeating: GridItem(.fixed(52), spacing: 8), count: colCount)
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(scramblePool) { tile in
                    Button {
                        tapScrambleTile(tile, word: upperWord, card: card)
                    } label: {
                        Text(String(tile.character))
                            .font(.custom("Cinzel-Bold", size: 18))
                            .foregroundStyle(color)
                            .frame(width: 48, height: 48)
                            .contentShape(Rectangle())
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(scrambleWrongFlash ? RenaissanceColors.errorRed.opacity(0.12) : color.opacity(0.08))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(scrambleWrongFlash ? RenaissanceColors.errorRed.opacity(0.4) : color.opacity(0.3), lineWidth: 1.5)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }

            // Undo button
            if !spelledTiles.isEmpty {
                Button {
                    if let last = spelledTiles.popLast() {
                        scramblePool.append(last)
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.uturn.backward")
                            .font(.system(size: 13))
                        Text("Undo")
                            .font(.custom("EBGaramond-SemiBold", size: 14))
                    }
                    .foregroundStyle(color.opacity(0.6))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .contentShape(Rectangle())
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(color.opacity(0.06))
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func tapScrambleTile(_ tile: ScrambleTile, word: String, card: KnowledgeCard) {
        let nextIndex = spelledTiles.count
        guard nextIndex < word.count else { return }

        let expected = word[word.index(word.startIndex, offsetBy: nextIndex)]
        if tile.character == expected {
            // Correct
            SubsonicController.shared.play(sound: "tap_soft.mp3")
            withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                spelledTiles.append(tile)
                scramblePool.removeAll { $0.id == tile.id }
            }
            // Check completion
            if spelledTiles.count == word.count {
                SubsonicController.shared.play(sound: "correct_chime.mp3")
                awardFlorins(GameRewards.scienceCardMatchFlorins * 2)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    completeCard(card)
                }
            }
        } else {
            // Wrong — flash red
            SubsonicController.shared.play(sound: "wrong_buzz.mp3")
            withAnimation(.easeOut(duration: 0.1)) { scrambleWrongFlash = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation(.easeOut(duration: 0.15)) { scrambleWrongFlash = false }
            }
        }
    }

    // MARK: - Number Fishing Activity

    private func numberFishingView(card: KnowledgeCard, question: String, correctAnswer: Int, decoys: [Int]) -> some View {
        let color = card.color

        return VStack(spacing: 12) {
            // Question
            Text(question)
                .font(.custom("EBGaramond-SemiBold", size: 15))
                .foregroundStyle(RenaissanceColors.sepiaInk)
                .multilineTextAlignment(.center)
                .padding(.top, 4)

            // Answer blank
            HStack(spacing: 4) {
                Text("Answer:")
                    .font(.custom("EBGaramond-Regular", size: 14))
                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.5))
                if fishingAnswered {
                    Text("\(correctAnswer)")
                        .font(.custom("Cinzel-Bold", size: 22))
                        .foregroundStyle(RenaissanceColors.goldSuccess)
                        .transition(.scale.combined(with: .opacity))
                } else {
                    Text("?")
                        .font(.custom("Cinzel-Bold", size: 22))
                        .foregroundStyle(color.opacity(0.4))
                }
            }

            // Pond area with floating bubbles
            ZStack {
                // Pond background
                RoundedRectangle(cornerRadius: 14)
                    .fill(RenaissanceColors.renaissanceBlue.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(RenaissanceColors.renaissanceBlue.opacity(0.15), lineWidth: 1)
                    )

                // Ripple decoration
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .stroke(RenaissanceColors.renaissanceBlue.opacity(0.06), lineWidth: 1)
                        .frame(width: CGFloat(60 + i * 40), height: CGFloat(60 + i * 40))
                        .offset(x: CGFloat([-50, 60, -20][i]), y: CGFloat([20, -30, 40][i]))
                }

                // Floating number bubbles
                ForEach(fishingBubbles) { bubble in
                    let isSunk = fishingSunkIDs.contains(bubble.id)
                    if !isSunk {
                        Button {
                            tapFishingBubble(bubble, correct: correctAnswer, card: card)
                        } label: {
                            Text("\(bubble.number)")
                                .font(.custom("Cinzel-Bold", size: 18))
                                .foregroundStyle(
                                    fishingAnswered && bubble.isCorrect ? RenaissanceColors.goldSuccess : color
                                )
                                .frame(width: 56, height: 56)
                                .background(
                                    Circle()
                                        .fill(
                                            fishingAnswered && bubble.isCorrect
                                            ? RenaissanceColors.goldSuccess.opacity(0.15)
                                            : color.opacity(0.08)
                                        )
                                )
                                .overlay(
                                    Circle()
                                        .stroke(
                                            fishingAnswered && bubble.isCorrect
                                            ? RenaissanceColors.goldSuccess.opacity(0.6)
                                            : color.opacity(0.25),
                                            lineWidth: 1.5
                                        )
                                )
                                .shadow(color: fishingAnswered && bubble.isCorrect ? RenaissanceColors.goldSuccess.opacity(0.4) : .clear, radius: 8)
                                .contentShape(Circle())
                        }
                        .buttonStyle(.plain)
                        .disabled(fishingAnswered)
                        .offset(bubble.offset)
                        .transition(.scale.combined(with: .opacity))
                    }
                }
            }
            .frame(height: 240)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }

    private func tapFishingBubble(_ bubble: FishingBubble, correct: Int, card: KnowledgeCard) {
        guard !fishingAnswered else { return }

        if bubble.isCorrect {
            // Correct — gold glow, rise to top
            SubsonicController.shared.play(sound: "correct_chime.mp3")
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                fishingAnswered = true
            }
            fishingTimer?.invalidate()
            fishingTimer = nil
            awardFlorins(GameRewards.scienceCardMatchFlorins * 2)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                completeCard(card)
            }
        } else {
            // Wrong — shrink and sink
            SubsonicController.shared.play(sound: "water_plop.mp3")
            withAnimation(.easeIn(duration: 0.4)) {
                fishingSunkIDs.insert(bubble.id)
            }
        }
    }

    // MARK: - Hangman Activity

    private func hangmanView(card: KnowledgeCard, word: String, hint: String) -> some View {
        let upperWord = word.uppercased()
        let uniqueLetters = Set(upperWord)
        let wrongGuesses = hangmanGuessed.subtracting(uniqueLetters)
        let maxWrong = 6
        let color = card.color

        return VStack(spacing: 10) {
            // Hint
            Text(hint)
                .font(.custom("EBGaramond-Regular", size: 13))
                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))
                .multilineTextAlignment(.center)

            // Scaffold + figure
            hangmanFigure(wrongCount: hangmanWrongCount, color: color)
                .frame(height: 130)

            // Word dashes
            HStack(spacing: 5) {
                ForEach(Array(upperWord.enumerated()), id: \.offset) { _, char in
                    let revealed = hangmanGuessed.contains(char) || hangmanRevealed
                    Text(revealed ? String(char) : "_")
                        .font(.custom("Cinzel-Bold", size: 20))
                        .foregroundStyle(
                            hangmanRevealed && !hangmanGuessed.contains(char)
                            ? RenaissanceColors.errorRed
                            : revealed ? color : RenaissanceColors.sepiaInk.opacity(0.3)
                        )
                        .frame(width: 24, height: 30)
                }
            }
            .padding(.vertical, 4)

            // Wrong count
            HStack(spacing: 4) {
                ForEach(0..<maxWrong, id: \.self) { i in
                    Circle()
                        .fill(i < hangmanWrongCount ? RenaissanceColors.errorRed : RenaissanceColors.sepiaInk.opacity(0.12))
                        .frame(width: 10, height: 10)
                }
                Text("\(hangmanWrongCount)/\(maxWrong)")
                    .font(.custom("EBGaramond-Regular", size: 12))
                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.4))
            }

            // Alphabet grid (2 rows × 13)
            let alphabet: [Character] = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
            let columns = Array(repeating: GridItem(.fixed(36), spacing: 3), count: 13)

            LazyVGrid(columns: columns, spacing: 3) {
                ForEach(alphabet, id: \.self) { letter in
                    let isGuessed = hangmanGuessed.contains(letter)
                    let isCorrectLetter = uniqueLetters.contains(letter) && isGuessed
                    let isWrongLetter = !uniqueLetters.contains(letter) && isGuessed

                    Button {
                        guessHangmanLetter(letter, word: upperWord, card: card)
                    } label: {
                        Text(String(letter))
                            .font(.custom("EBGaramond-SemiBold", size: 14))
                            .foregroundStyle(
                                isCorrectLetter ? RenaissanceColors.sageGreen
                                : isWrongLetter ? RenaissanceColors.errorRed.opacity(0.5)
                                : color
                            )
                            .frame(width: 34, height: 34)
                            .contentShape(Rectangle())
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(
                                        isCorrectLetter ? RenaissanceColors.sageGreen.opacity(0.1)
                                        : isWrongLetter ? RenaissanceColors.errorRed.opacity(0.06)
                                        : color.opacity(0.06)
                                    )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(
                                        isCorrectLetter ? RenaissanceColors.sageGreen.opacity(0.4)
                                        : isWrongLetter ? RenaissanceColors.errorRed.opacity(0.2)
                                        : color.opacity(0.15),
                                        lineWidth: 1
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                    .disabled(isGuessed || hangmanRevealed || hangmanWon)
                    .opacity(isGuessed ? 0.5 : 1)
                }
            }

            // Game over / retry
            if hangmanRevealed && !hangmanWon {
                Button {
                    // Retry
                    hangmanGuessed = []
                    hangmanWrongCount = 0
                    hangmanRevealed = false
                    hangmanWon = false
                } label: {
                    Text("Try Again")
                        .font(.custom("EBGaramond-SemiBold", size: 15))
                        .foregroundStyle(color)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(color.opacity(0.08))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(color.opacity(0.3), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func guessHangmanLetter(_ letter: Character, word: String, card: KnowledgeCard) {
        guard !hangmanGuessed.contains(letter), !hangmanRevealed, !hangmanWon else { return }
        let uniqueLetters = Set(word)

        withAnimation(.easeOut(duration: 0.2)) {
            hangmanGuessed.insert(letter)
        }

        if !uniqueLetters.contains(letter) {
            // Wrong guess
            SubsonicController.shared.play(sound: "hangman_wrong.mp3")
            withAnimation(.easeOut(duration: 0.3)) {
                hangmanWrongCount += 1
            }
            if hangmanWrongCount >= 6 {
                // Game over — reveal word
                withAnimation(.easeOut(duration: 0.4)) {
                    hangmanRevealed = true
                }
            }
        } else {
            // Correct letter
            SubsonicController.shared.play(sound: "tap_soft.mp3")
            // Check if all letters guessed
            if uniqueLetters.isSubset(of: hangmanGuessed) {
                SubsonicController.shared.play(sound: "correct_chime.mp3")
                hangmanWon = true
                awardFlorins(GameRewards.scienceCardMatchFlorins * 3)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    completeCard(card)
                }
            }
        }
    }

    /// Draws the hangman scaffold and body parts progressively
    private func hangmanFigure(wrongCount: Int, color: Color) -> some View {
        Canvas { context, size in
            let scaffold = RenaissanceColors.warmBrown
            let figure = RenaissanceColors.sepiaInk

            // Base
            var basePath = Path()
            basePath.move(to: CGPoint(x: 20, y: size.height - 10))
            basePath.addLine(to: CGPoint(x: 100, y: size.height - 10))
            context.stroke(basePath, with: .color(scaffold), lineWidth: 3)

            // Pole
            var polePath = Path()
            polePath.move(to: CGPoint(x: 40, y: size.height - 10))
            polePath.addLine(to: CGPoint(x: 40, y: 15))
            context.stroke(polePath, with: .color(scaffold), lineWidth: 3)

            // Top beam
            var beamPath = Path()
            beamPath.move(to: CGPoint(x: 40, y: 15))
            beamPath.addLine(to: CGPoint(x: 120, y: 15))
            context.stroke(beamPath, with: .color(scaffold), lineWidth: 3)

            // Rope
            var ropePath = Path()
            ropePath.move(to: CGPoint(x: 120, y: 15))
            ropePath.addLine(to: CGPoint(x: 120, y: 35))
            context.stroke(ropePath, with: .color(scaffold), lineWidth: 2)

            // Body parts (6 stages)
            if wrongCount >= 1 {
                // Head
                let headRect = CGRect(x: 108, y: 35, width: 24, height: 24)
                context.stroke(Path(ellipseIn: headRect), with: .color(figure), lineWidth: 2)
            }
            if wrongCount >= 2 {
                // Body
                var bodyPath = Path()
                bodyPath.move(to: CGPoint(x: 120, y: 59))
                bodyPath.addLine(to: CGPoint(x: 120, y: 90))
                context.stroke(bodyPath, with: .color(figure), lineWidth: 2)
            }
            if wrongCount >= 3 {
                // Left arm
                var lArmPath = Path()
                lArmPath.move(to: CGPoint(x: 120, y: 65))
                lArmPath.addLine(to: CGPoint(x: 100, y: 80))
                context.stroke(lArmPath, with: .color(figure), lineWidth: 2)
            }
            if wrongCount >= 4 {
                // Right arm
                var rArmPath = Path()
                rArmPath.move(to: CGPoint(x: 120, y: 65))
                rArmPath.addLine(to: CGPoint(x: 140, y: 80))
                context.stroke(rArmPath, with: .color(figure), lineWidth: 2)
            }
            if wrongCount >= 5 {
                // Left leg
                var lLegPath = Path()
                lLegPath.move(to: CGPoint(x: 120, y: 90))
                lLegPath.addLine(to: CGPoint(x: 100, y: 112))
                context.stroke(lLegPath, with: .color(figure), lineWidth: 2)
            }
            if wrongCount >= 6 {
                // Right leg
                var rLegPath = Path()
                rLegPath.move(to: CGPoint(x: 120, y: 90))
                rLegPath.addLine(to: CGPoint(x: 140, y: 112))
                context.stroke(rLegPath, with: .color(figure), lineWidth: 2)
            }
        }
    }

    // MARK: - Keyword Matching Logic

    private func selectKeyword(_ id: UUID, card: KnowledgeCard) {
        withAnimation(.easeOut(duration: 0.15)) { selectedKeywordID = id }
        if let defID = selectedDefinitionID {
            tryMatch(keywordID: id, definitionID: defID, card: card)
        }
    }

    private func selectDefinition(_ id: UUID, card: KnowledgeCard) {
        withAnimation(.easeOut(duration: 0.15)) { selectedDefinitionID = id }
        if let kwID = selectedKeywordID {
            tryMatch(keywordID: kwID, definitionID: id, card: card)
        }
    }

    private func tryMatch(keywordID: UUID, definitionID: UUID, card: KnowledgeCard) {
        if keywordID == definitionID {
            // Correct
            SubsonicController.shared.play(sound: "correct_chime.mp3")
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                matchedPairIDs.insert(keywordID)
                selectedKeywordID = nil
                selectedDefinitionID = nil
            }
            awardFlorins(GameRewards.scienceCardMatchFlorins)

            if matchedPairIDs.count == card.keywords.count {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    completeCard(card)
                }
            }
        } else {
            // Wrong
            SubsonicController.shared.play(sound: "wrong_buzz.mp3")
            withAnimation(.easeOut(duration: 0.15)) { wrongMatchFlash = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeOut(duration: 0.15)) {
                    wrongMatchFlash = false
                    selectedKeywordID = nil
                    selectedDefinitionID = nil
                }
            }
        }
    }

    // MARK: - Activity Helpers

    private func openActivity(for card: KnowledgeCard) {
        // Reset keyword match state
        matchedPairIDs = []
        selectedKeywordID = nil
        selectedDefinitionID = nil
        shuffledDefinitions = card.keywords.shuffled()
        wrongMatchFlash = false
        selectedMCIndex = nil
        mcAnswered = false
        tfSelected = nil
        tfAnswered = false

        // Reset word scramble state
        scramblePool = []
        spelledTiles = []
        scrambleWrongFlash = false
        if case .wordScramble(let word, _) = card.activity {
            scramblePool = word.uppercased().map { ScrambleTile(character: $0) }.shuffled()
        }

        // Reset number fishing state
        fishingTimer?.invalidate()
        fishingTimer = nil
        fishingBubbles = []
        fishingAnswered = false
        fishingSunkIDs = []
        if case .numberFishing(_, let correct, let decoys) = card.activity {
            var numbers = decoys + [correct]
            numbers.shuffle()
            fishingBubbles = numbers.map { num in
                FishingBubble(
                    number: num,
                    isCorrect: num == correct,
                    offset: CGSize(
                        width: CGFloat.random(in: -180...180),
                        height: CGFloat.random(in: -80...80)
                    )
                )
            }
            // Start gentle drift
            fishingTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
                withAnimation(.easeInOut(duration: 2.0)) {
                    for i in fishingBubbles.indices {
                        fishingBubbles[i].offset = CGSize(
                            width: CGFloat.random(in: -180...180),
                            height: CGFloat.random(in: -80...80)
                        )
                    }
                }
            }
        }

        // Reset hangman state
        hangmanGuessed = []
        hangmanWrongCount = 0
        hangmanRevealed = false
        hangmanWon = false

        withAnimation(.easeInOut(duration: 0.4)) {
            cardPhases[card.id] = .activity
        }
    }

    private func completeCard(_ card: KnowledgeCard) {
        SubsonicController.shared.play(sound: "card_complete.mp3")
        completedCardIDs.insert(card.id)

        // Save to ViewModel + notebook
        let entry = NotebookEntry(
            buildingId: buildingId,
            entryType: .scienceConcept,
            science: card.science,
            title: card.title,
            body: card.notebookSummary
        )
        viewModel.markCardCompleted(
            for: buildingId,
            cardID: card.id,
            notebookEntry: entry,
            notebookState: notebookState
        )

        // Flip card back to front showing green checkmark
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            cardPhases[card.id] = .completed
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
                flipAngles[card.id] = 0
                flippedOpenCard = nil
            }
        }

        // Check if all cards in this set complete
        if completedCardIDs.count == cards.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                onAllComplete?()
            }
        }
    }

    private func awardFlorins(_ amount: Int) {
        viewModel.earnFlorins(amount)
        withAnimation(.spring(response: 0.3)) { earnedFlorinsFloat = amount }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeOut(duration: 0.3)) { earnedFlorinsFloat = nil }
        }
    }

    // MARK: - Progress Dots

    private func progressDots(total: Int, matched: Int) -> some View {
        HStack(spacing: 4) {
            ForEach(0..<total, id: \.self) { i in
                Circle()
                    .fill(i < matched ? RenaissanceColors.sageGreen : RenaissanceColors.sepiaInk.opacity(0.15))
                    .frame(width: 8, height: 8)
            }
        }
    }

    // MARK: - Bird Encouragement

    private var birdEncouragement: some View {
        HStack(spacing: 10) {
            BirdCharacter(isSitting: true)
                .frame(width: 36, height: 36)

            let done = completedCardIDs.count
            let total = cards.count
            Text(done == 0 ? "Tap a card to start learning!"
                 : done < total ? "\(total - done) card\(total - done == 1 ? "" : "s") left — keep going!"
                 : "All done here! Check other environments for more.")
                .font(.custom("EBGaramond-Regular", size: 13))
                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(RenaissanceColors.ochre.opacity(0.06))
        )
    }

    // MARK: - Card Progress Bar

    private var cardProgressBar: some View {
        let total = KnowledgeCardContent.cards(for: viewModel.buildingPlots.first(where: { $0.id == buildingId })?.building.name ?? "").count
        let progress = viewModel.buildingProgressMap[buildingId]?.completedCardIDs.count ?? 0

        return HStack(spacing: 6) {
            Image(systemName: "square.stack.fill")
                .font(.system(size: 12))
                .foregroundStyle(RenaissanceColors.ochre)
            Text("\(progress)/\(total) cards")
                .font(.custom("EBGaramond-SemiBold", size: 13))
                .foregroundStyle(RenaissanceColors.sepiaInk)

            // Env breakdown
            Text("·")
                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.3))
            Text("Here: \(completedCardIDs.count)/\(cards.count)")
                .font(.custom("EBGaramond-Regular", size: 12))
                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.6))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 6)
        .background(
            Capsule().fill(RenaissanceColors.parchment.opacity(0.9))
        )
    }

    // MARK: - Next Environment Hint

    private var nextEnvironmentHint: some View {
        Group {
            if let env = viewModel.nextSuggestedEnvironment(for: buildingId) {
                let envName: String = {
                    switch env {
                    case .workshop: return "Workshop"
                    case .forest: return "Forest"
                    case .craftingRoom: return "Crafting Room"
                    case .cityMap: return "City Map"
                    }
                }()
                let envIcon: String = {
                    switch env {
                    case .workshop: return "hammer.fill"
                    case .forest: return "tree.fill"
                    case .craftingRoom: return "wrench.and.screwdriver.fill"
                    case .cityMap: return "building.columns.fill"
                    }
                }()

                HStack(spacing: 8) {
                    BirdCharacter(isSitting: true)
                        .frame(width: 36, height: 36)
                    Image(systemName: envIcon)
                        .font(.system(size: 14))
                        .foregroundStyle(RenaissanceColors.renaissanceBlue)
                    Text("More cards at the \(envName)!")
                        .font(.custom("EBGaramond-Regular", size: 14))
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(RenaissanceColors.renaissanceBlue.opacity(0.08))
                )
            }
        }
    }
}

// MARK: - CardPhase (shared with ForestMapView)

// CardPhase is already defined in ScienceCardContent.swift — reuse it
