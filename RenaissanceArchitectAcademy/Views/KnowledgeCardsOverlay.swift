import SwiftUI
// Audio via SoundManager

// MARK: - Falling Florin Model

struct FallingFlorin: Identifiable {
    let id = UUID()
    let burstX: CGFloat       // horizontal burst offset from center
    let burstY: CGFloat       // vertical burst offset (upward)
    let finalX: CGFloat       // where it lands horizontally
    let size: CGFloat         // coin size
    let spinSpeed: Double     // rotation per phase
    var phase: FlorinPhase = .atCard   // animation state

    enum FlorinPhase {
        case atCard     // at card center
        case burst      // flew outward from card
        case falling    // gravity pulling down
        case landed     // on the ground
        case collected  // shrunk into counter
    }
}

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
    var viewModel: CityViewModel
    var notebookState: NotebookState? = nil
    let onDismiss: () -> Void
    /// Called when all cards in this set are complete
    var onAllComplete: (() -> Void)? = nil
    /// Navigate to another environment (for bird guidance)
    var onNavigate: ((SidebarDestination) -> Void)? = nil
    /// Player name for bird chat
    var playerName: String = "Apprentice"
    /// Show AI provider picker (at parent level so it survives overlay changes)
    var onShowAIPicker: (() -> Void)? = nil
    /// When true, open bird chat (set after AI picker completes at parent level)
    @Binding var triggerBirdChat: Bool
    /// Workshop state for game-loop-aware guidance (tools, materials, etc.)
    var workshopState: WorkshopState? = nil
    /// Current station type (when shown from workshop)
    var currentStation: ResourceStationType? = nil

    private var settings: GameSettings { GameSettings.shared }

    // MARK: - Card Layout (responsive)

    @Environment(\.horizontalSizeClass) private var sizeClass
    private var isLargeScreen: Bool { sizeClass == .regular }

    // Screen size captured from GeometryReader — responsive card sizing
    @State private var screenWidth: CGFloat = 400
    @State private var screenHeight: CGFloat = 800

    private var cardW: CGFloat { isLargeScreen ? 200 : min(200, screenWidth * 0.6) }
    private var cardH: CGFloat { isLargeScreen ? 280 : min(280, cardW * 1.4) }
    private var flippedW: CGFloat { isLargeScreen ? screenWidth * 0.65 : screenWidth * 0.90 }
    private var flippedH: CGFloat { isLargeScreen ? screenHeight * 0.85 : screenHeight * 0.80 }

    // MARK: - Card State

    @State private var flipAngles: [String: Double] = [:]      // card.id → angle
    @State private var flippedOpenCard: String? = nil           // which card is flipped open
    @State private var cardPhases: [String: CardPhase] = [:]   // card.id → phase
    @State private var completedCardIDs: Set<String> = []
    @State private var cardsAppeared = false
    @State private var floatOffset: CGFloat = 0
    @State private var auroraPhase = false
    @State private var showFlippedContent = false
    @State private var animateFlippedStory = false

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

    // Infographic reveal (shown after activity completion as reward)
    @State private var showInfographic: InfographicReveal? = nil
    @State private var pendingCompleteCard: KnowledgeCard? = nil

    // Card crack → florin burst animation
    @State private var crackingCardID: String? = nil
    @State private var cardCrackPhase: Int = 0          // 0=none, 1=shake, 2=crack, 3=burst
    @State private var shakeOffset: CGFloat = 0
    @State private var fallingFlorins: [FallingFlorin] = []
    @State private var showFlorinTotal = false

    // Guidance bubble (replaces bird chat auto-popup)
    @State private var showGuidanceBubble = false
    @State private var guidanceBubbleCard: KnowledgeCard? = nil

    // Bird chat (manual "Ask the Bird" only)
    @State private var chatViewModel = BirdChatViewModel()
    @State private var showBirdChat = false
    @State private var showAIPicker = false
    @State private var birdChatCard: KnowledgeCard? = nil

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Dimmed background
                RenaissanceColors.overlayDimming
                    .ignoresSafeArea()
                    .onTapGesture { handleBackgroundTap() }
                    .onAppear { screenWidth = geo.size.width; screenHeight = geo.size.height }
                    .onChange(of: geo.size) { screenWidth = $1.width; screenHeight = $1.height }

                VStack(spacing: 16) {
                    Spacer()

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

                    // Guidance bubble REMOVED — CityMapView guidance handles navigation

                    Spacer()
                }

                // AI picker removed from here — lives at CityMapView level

                // Bird chat overlay — only after provider chosen
                if showBirdChat, !showAIPicker, let chatCard = birdChatCard {
                    BirdChatOverlay(
                        card: chatCard,
                        playerName: playerName,
                        chatViewModel: chatViewModel,
                        onDismiss: {
                            showBirdChat = false
                            birdChatCard = nil
                            // If all cards were completed while chatting, continue the flow now
                            if completedCardIDs.count == cards.count {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    onAllComplete?()
                                }
                            }
                        }
                    )
                    .transition(.opacity)
                }

                // Infographic is shown inline on the card back, not here
            }
        }
        .onChange(of: triggerBirdChat) { _, open in
            if open, let card = birdChatCard {
                triggerBirdChat = false
                let context = BirdContext(
                    buildingName: card.buildingName,
                    buildingId: card.buildingId,
                    sciences: [card.science.rawValue],
                    cardTitle: card.title,
                    cardLesson: card.lessonText,
                    playerName: playerName,
                    masteryLevel: "Apprentice"
                )
                chatViewModel.startSession(context: context)
                withAnimation(.spring(response: 0.3)) {
                    showBirdChat = true
                }
            }
        }
        .onAppear {
            // Load already-completed cards from progress
            let progress = viewModel.buildingProgressMap[buildingId] ?? BuildingProgress()
            completedCardIDs = progress.completedCardIDs.intersection(Set(cards.map { $0.id }))

            // Configure game tool context for bird chat (iOS 26+ tool calling)
            let ws = workshopState
            chatViewModel.gameToolContext = GameToolContext(
                buildingPlots: viewModel.buildingPlots.map { plot in
                    let state = plot.isCompleted ? "complete" : "in_progress"
                    return (name: plot.building.name, state: state, phase: state)
                },
                activeBuildingName: viewModel.buildingPlots.first(where: { $0.id == viewModel.activeBuildingId })?.building.name,
                totalComplete: viewModel.buildingPlots.filter { $0.isCompleted }.count,
                rawMaterials: ws?.rawMaterials.reduce(into: [String: Int]()) { dict, pair in
                    dict[pair.key.rawValue] = pair.value
                } ?? [:],
                craftedItems: ws?.craftedMaterials.reduce(into: [String: Int]()) { dict, pair in
                    dict[pair.key.rawValue] = pair.value
                } ?? [:],
                tools: ws?.tools.compactMap { $0.value > 0 ? $0.key.displayName : nil } ?? [],
                florins: viewModel.goldFlorins
            )

            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                floatOffset = 8
            }
            auroraPhase = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                SoundManager.shared.play(.cardsAppear)
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

                        // BACK face — only rendered during/after flip to save ~150 MB
                        // (each back instantiates CardVisualView with full Canvas drawing)
                        if angle > 0 {
                            flippedCardBack(card: card, isCompleted: isCompleted)
                                .frame(width: flippedW, height: flippedH)
                                .scaleEffect(isThisFlipped ? 1.0 : 0.15)
                                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                                .opacity(angle >= 90 ? 1 : 0)
                                .allowsHitTesting(false)
                                .animation(.spring(response: 0.5, dampingFraction: 0.7), value: isThisFlipped)
                        }
                    }
                    .rotation3DEffect(.degrees(angle), axis: (x: 0, y: 1, z: 0), perspective: 0.4)

                    // FLAT INTERACTIVE OVERLAY — appears when fully flipped, receives all clicks
                    if isThisFlipped && angle >= 90 {
                        flippedCardBack(card: card, isCompleted: isCompleted)
                            .frame(width: flippedW, height: flippedH)
                    }
                }
                .scaleEffect(isPiled ? 0.5 : 1.0)
                .opacity(isPiled ? 0.65 : 1.0)
                .offset(
                    x: someCardFlipped ? (isPiled ? pileX : 0) : spreadX,
                    y: isPiled ? CGFloat(pileStackIndex(card.id)) * 5 : floatOffset * (index.isMultiple(of: 2) ? 1 : -1)
                )
                .rotation3DEffect(.degrees(isPiled ? -5 + Double(pileStackIndex(card.id)) * 3 : 0), axis: (x: 0, y: 0, z: 1))
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
            showFlippedContent = false
            animateFlippedStory = false
            SoundManager.shared.play(.cardFlip)
            withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
                flipAngles[card.id] = 0
                flippedOpenCard = nil
            }
        } else {
            // Unflip current
            if let current = flippedOpenCard {
                flipAngles[current] = 0
            }
            showFlippedContent = false
            animateFlippedStory = false
            // Flip this card
            SoundManager.shared.play(.cardFlip)
            withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
                flippedOpenCard = card.id
                flipAngles[card.id] = 180
                cardPhases[card.id] = .reading
            }
            // Start content fade-in after flip completes
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeIn(duration: 0.3)) {
                    showFlippedContent = true
                }
                withAnimation(.easeIn(duration: 0.8).delay(0.3)) {
                    animateFlippedStory = true
                }
            }
        }
    }

    private func handleBackgroundTap() {
        if let open = flippedOpenCard, cardPhases[open] == .activity {
            withAnimation(.easeInOut(duration: 0.4)) {
                cardPhases[open] = .reading
            }
        } else if let open = flippedOpenCard {
            showFlippedContent = false
            animateFlippedStory = false
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
        let color = isCompleted ? RenaissanceColors.sageGreen : card.color
        return ZStack {
            // Parchment gradient background (matches Discovery Card)
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [color.opacity(0.15), settings.dialogBackground],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(color.opacity(0.5), lineWidth: 2)
                )
                .shadow(color: color.opacity(0.3), radius: 8, y: 4)

            VStack(spacing: 12) {
                // Science badge
                Text(card.science.rawValue.uppercased())
                    .font(.custom("Cinzel-Bold", size: 10))
                    .tracking(2)
                    .foregroundStyle(color)

                // Icon (bare, no circle — matches Discovery)
                Image(systemName: isCompleted ? "checkmark.circle.fill" : card.icon)
                    .font(.system(size: 44))
                    .foregroundStyle(color)
                    .shadow(color: color.opacity(0.3), radius: 4)

                // Title
                Text(card.title)
                    .font(.custom("Cinzel-Bold", size: 18))
                    .foregroundStyle(settings.cardTextColor)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)

                // Italian name
                Text(card.italianTitle)
                    .font(.custom("EBGaramond-Italic", size: 14))
                    .foregroundStyle(settings.cardTextColor.opacity(0.6))

                Spacer().frame(height: 8)

                if isCompleted {
                    // "Ask the Bird" button on completed cards
                    Button {
                        birdChatCard = card
                        // First time? Show AI picker at parent level. Otherwise open chat.
                        if !GameSettings.shared.hasChosenAIProvider {
                            onShowAIPicker?()
                        } else {
                            let context = BirdContext(
                                buildingName: card.buildingName,
                                buildingId: card.buildingId,
                                sciences: [card.science.rawValue],
                                cardTitle: card.title,
                                cardLesson: card.lessonText,
                                playerName: playerName,
                                masteryLevel: "Apprentice"
                            )
                            chatViewModel.startSession(context: context)
                            withAnimation(.spring(response: 0.3)) {
                                showBirdChat = true
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "bird.fill")
                                .font(.system(size: 11))
                            Text("Ask the Bird")
                                .font(.custom("EBGaramond-Regular", size: 12))
                        }
                        .foregroundStyle(RenaissanceColors.sageGreen)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .fill(RenaissanceColors.sageGreen.opacity(0.1))
                        )
                    }
                    .buttonStyle(.plain)
                } else {
                    // Tap hint text (matches Discovery)
                    Text("Tap to learn")
                        .font(.custom("EBGaramond-Regular", size: 13))
                        .foregroundStyle(color.opacity(0.7))
                }
            }
            .padding(20)
        }
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
                            Text("Lesson").font(RenaissanceFont.caption)
                        }
                        .foregroundStyle(color.opacity(0.6))
                        .padding(.horizontal, Spacing.xs)
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
            .padding(.top, Spacing.xs)
            .padding(.bottom, Spacing.xxs)
            .padding(.horizontal, Spacing.xxs)
            .editable("card-header", fontSize: 16)

            Rectangle()
                .fill(color.opacity(0.2))
                .frame(height: 1)
                .padding(.horizontal, Spacing.xs)

            // Content
            ZStack {
                if showInfographic != nil && pendingCompleteCard?.id == card.id {
                    // Infographic reward — shown inline on the card after activity
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 12) {
                            InfographicRevealView(infographic: showInfographic!) {
                                withAnimation(.spring(response: 0.3)) {
                                    showInfographic = nil
                                }
                                if let pending = pendingCompleteCard {
                                    pendingCompleteCard = nil
                                    finalizeCardCompletion(pending)
                                }
                            }
                        }
                        .padding(.vertical, Spacing.sm)
                    }
                    .transition(.opacity)
                } else if !isActivity {
                    readingContent(card: card, isCompleted: isCompleted)
                        .transition(.opacity)
                } else if isActivity {
                    ScrollView(.vertical, showsIndicators: false) {
                        activityContent(card: card)
                    }
                    .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.4), value: isActivity)
            .animation(.easeInOut(duration: 0.4), value: showInfographic != nil)
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: 14).fill(settings.dialogBackground)
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
            HStack(spacing: Spacing.sm) {
                ForEach(card.keywords.prefix(4)) { pair in
                    VStack(spacing: 2) {
                        Circle()
                            .fill(card.color.opacity(0.1))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Image(systemName: card.icon)
                                    .font(.system(size: 13))
                                    .foregroundStyle(card.color.opacity(0.5))
                            )
                        Text(pair.keyword)
                            .font(.custom("EBGaramond-SemiBold", size: 10))
                            .foregroundStyle(card.color)
                            .lineLimit(1)
                    }
                }
            }
            .padding(.vertical, Spacing.xs)
            .opacity(showFlippedContent ? 1 : 0)
            .editable("keyword-circles", fontSize: 10)

            Rectangle()
                .fill(card.color.opacity(0.1))
                .frame(height: 1)
                .padding(.horizontal, Spacing.xs)
                .opacity(showFlippedContent ? 1 : 0)

            // Lesson text
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: Spacing.sm) {
                    highlightedLessonText(card: card)
                        .lineSpacing(5)
                        .padding(.top, Spacing.xxs)
                        .opacity(animateFlippedStory ? 1 : 0)
                        .editable("lesson-text", paddingV: Spacing.xs)

                    // Interactive science visual
                    if let visual = card.visual {
                        CardVisualView(visual: visual, color: card.color, containerHeight: flippedH)
                            .frame(minHeight: flippedH * 0.4)
                            .opacity(animateFlippedStory ? 1 : 0)
                    }

                    // Fun fact lightbulb callout
                    if let funFact = card.funFact {
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "lightbulb.fill")
                                .foregroundStyle(RenaissanceColors.ochre)
                                .font(.system(size: 16))
                            Text(funFact)
                                .font(RenaissanceFont.italicSmall)
                                .foregroundStyle(settings.cardTextColor.opacity(0.8))
                                .lineSpacing(4)
                        }
                        .padding(Spacing.sm)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(card.color.opacity(0.08))
                        )
                        .opacity(animateFlippedStory ? 1 : 0)
                        .editable("fun-fact", fontSize: 15, cornerRadius: 10)
                    }
                }
            }

            Spacer(minLength: 6)

            if !isCompleted {
                Button {
                    openActivity(for: card)
                } label: {
                    Text("Done Reading")
                        .font(RenaissanceFont.buttonSmall)
                        .foregroundStyle(.white)
                        .padding(.vertical, Spacing.sm)
                        .frame(maxWidth: .infinity)
                        .parchmentButton(color: card.color, radius: 9)
                }
                .buttonStyle(.plain)
                .opacity(animateFlippedStory ? 1 : 0)
                .editable("done-button", cornerRadius: 9)
            }
        }
    }

    // MARK: - Wolfram Geometry Helper

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
                    .font(.custom("EBGaramond-SemiBold", size: 16))
                    .foregroundColor(color)
            } else {
                result = result + Text(text)
                    .font(RenaissanceFont.bodyMedium)
                    .foregroundColor(settings.cardTextColor)
            }
        }
        return result
    }

    // MARK: - Activity Content (dispatches by type)

    @ViewBuilder
    private func activityContent(card: KnowledgeCard) -> some View {
        VStack(spacing: Spacing.sm) {
            // Standard activity
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
    }

    // MARK: - Keyword Match Activity

    private func keywordMatchView(card: KnowledgeCard) -> some View {
        VStack(spacing: 10) {
            Text("Match each term to its meaning")
                .font(.custom("EBGaramond-Medium", size: 12))
                .foregroundStyle(settings.cardTextColor.opacity(0.6))

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
                                .font(RenaissanceFont.buttonSmall)
                                .foregroundStyle(
                                    isMatched ? RenaissanceColors.sageGreen
                                    : isSelected ? card.color
                                    : settings.cardTextColor
                                )
                            Spacer()
                        }
                        .padding(.horizontal, Spacing.sm)
                        .padding(.vertical, Spacing.sm)
                        .background(
                            RoundedRectangle(cornerRadius: CornerRadius.sm)
                                .fill(
                                    isMatched ? RenaissanceColors.sageGreen.opacity(0.08)
                                    : isSelected ? card.color.opacity(0.12)
                                    : RenaissanceColors.ochre.opacity(0.04)
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: CornerRadius.sm)
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
                Rectangle().fill(settings.cardTextColor.opacity(0.1)).frame(height: 1)
                Image(systemName: "arrow.down")
                    .font(.system(size: 11))
                    .foregroundStyle(settings.cardTextColor.opacity(0.25))
                Rectangle().fill(settings.cardTextColor.opacity(0.1)).frame(height: 1)
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
                                .font(RenaissanceFont.dialogSubtitle)
                                .foregroundStyle(
                                    isWrong ? RenaissanceColors.errorRed
                                    : isMatched ? RenaissanceColors.sageGreen
                                    : isSelected ? card.color
                                    : settings.cardTextColor.opacity(0.8)
                                )
                                .multilineTextAlignment(.leading)
                            Spacer()
                            if isMatched {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundStyle(RenaissanceColors.sageGreen)
                            }
                        }
                        .padding(.horizontal, Spacing.sm)
                        .padding(.vertical, Spacing.sm)
                        .background(
                            RoundedRectangle(cornerRadius: CornerRadius.sm)
                                .fill(
                                    isWrong ? RenaissanceColors.errorRed.opacity(0.08)
                                    : isMatched ? RenaissanceColors.sageGreen.opacity(0.08)
                                    : isSelected ? card.color.opacity(0.08)
                                    : RenaissanceColors.ochre.opacity(0.04)
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: CornerRadius.sm)
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
                .font(RenaissanceFont.buttonSmall)
                .foregroundStyle(settings.cardTextColor)
                .multilineTextAlignment(.center)
                .padding(.top, Spacing.xs)

            ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                let isCorrect = index == correctIndex
                let isSelected = selectedMCIndex == index
                let showResult = mcAnswered

                Button {
                    guard !mcAnswered else { return }
                    selectedMCIndex = index
                    mcAnswered = true
                    if isCorrect {
                        SoundManager.shared.play(.correctChime)
                        awardFlorins(GameRewards.scienceCardMatchFlorins * 2)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            completeCard(card)
                        }
                    } else {
                        SoundManager.shared.play(.wrongBuzz)
                    }
                } label: {
                    HStack {
                        Text(option)
                            .font(RenaissanceFont.bodySmall)
                            .foregroundStyle(
                                showResult && isCorrect ? RenaissanceColors.sageGreen
                                : showResult && isSelected && !isCorrect ? RenaissanceColors.errorRed
                                : settings.cardTextColor
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
                        RoundedRectangle(cornerRadius: CornerRadius.sm)
                            .fill(
                                showResult && isCorrect ? RenaissanceColors.sageGreen.opacity(0.1)
                                : showResult && isSelected && !isCorrect ? RenaissanceColors.errorRed.opacity(0.1)
                                : RenaissanceColors.ochre.opacity(0.04)
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.sm)
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
                        .font(RenaissanceFont.buttonSmall)
                        .foregroundStyle(card.color)
                        .padding(.horizontal, Spacing.xl)
                        .padding(.vertical, Spacing.sm)
                        .background(
                            RoundedRectangle(cornerRadius: CornerRadius.sm)
                                .fill(card.color.opacity(0.08))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: CornerRadius.sm)
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
                .font(RenaissanceFont.bodySmall)
                .foregroundStyle(settings.cardTextColor)
                .multilineTextAlignment(.center)
                .padding(.top, Spacing.xs)

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
                            SoundManager.shared.play(.correctChime)
                            awardFlorins(GameRewards.scienceCardMatchFlorins * 2)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                completeCard(card)
                            }
                        } else {
                            SoundManager.shared.play(.wrongBuzz)
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
                        .font(RenaissanceFont.buttonSmall)
                        .foregroundStyle(card.color)
                        .padding(.horizontal, Spacing.xl)
                        .padding(.vertical, Spacing.sm)
                        .background(
                            RoundedRectangle(cornerRadius: CornerRadius.sm)
                                .fill(card.color.opacity(0.08))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: CornerRadius.sm)
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
                .font(RenaissanceFont.dialogSubtitle)
                .foregroundStyle(settings.cardTextColor.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.top, Spacing.xxs)

            // Dashes showing progress
            HStack(spacing: 6) {
                ForEach(Array(upperWord.enumerated()), id: \.offset) { index, _ in
                    let filled = index < spelledTiles.count
                    Text(filled ? String(spelledTiles[index].character) : "_")
                        .font(.custom("Cinzel-Bold", size: 22))
                        .foregroundStyle(filled ? color : settings.cardTextColor.opacity(0.3))
                        .frame(width: 28, height: 36)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(filled ? color.opacity(0.08) : RenaissanceColors.ochre.opacity(0.04))
                        )
                }
            }

            // Scrambled letter tiles (responsive grid)
            let scrambleColMax = isLargeScreen ? 6 : 5
            let scrambleTileSize: CGFloat = isLargeScreen ? 52 : 44
            let colCount = max(min(scramblePool.count, scrambleColMax), 1)
            let columns = Array(repeating: GridItem(.fixed(scrambleTileSize), spacing: 8), count: colCount)
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(scramblePool) { tile in
                    Button {
                        tapScrambleTile(tile, word: upperWord, card: card)
                    } label: {
                        Text(String(tile.character))
                            .font(.custom("Cinzel-Bold", size: 18))
                            .foregroundStyle(color)
                            .frame(width: scrambleTileSize - 4, height: scrambleTileSize - 4)
                            .contentShape(Rectangle())
                            .background(
                                RoundedRectangle(cornerRadius: CornerRadius.sm)
                                    .fill(scrambleWrongFlash ? RenaissanceColors.errorRed.opacity(0.12) : color.opacity(0.08))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: CornerRadius.sm)
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
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.xs)
                    .contentShape(Rectangle())
                    .background(
                        RoundedRectangle(cornerRadius: CornerRadius.sm)
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
            SoundManager.shared.play(.tapSoft)
            withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                spelledTiles.append(tile)
                scramblePool.removeAll { $0.id == tile.id }
            }
            // Check completion
            if spelledTiles.count == word.count {
                SoundManager.shared.play(.correctChime)
                awardFlorins(GameRewards.scienceCardMatchFlorins * 2)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    completeCard(card)
                }
            }
        } else {
            // Wrong — flash red
            SoundManager.shared.play(.wrongBuzz)
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
                .font(RenaissanceFont.buttonSmall)
                .foregroundStyle(settings.cardTextColor)
                .multilineTextAlignment(.center)
                .padding(.top, Spacing.xxs)

            // Answer blank
            HStack(spacing: 4) {
                Text("Answer:")
                    .font(RenaissanceFont.dialogSubtitle)
                    .foregroundStyle(settings.cardTextColor.opacity(0.5))
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
            SoundManager.shared.play(.correctChime)
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
            SoundManager.shared.play(.waterPlop)
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
                .font(RenaissanceFont.caption)
                .foregroundStyle(settings.cardTextColor.opacity(0.7))
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
                            : revealed ? color : settings.cardTextColor.opacity(0.3)
                        )
                        .frame(width: 24, height: 30)
                }
            }
            .padding(.vertical, 4)

            // Wrong count
            HStack(spacing: 4) {
                ForEach(0..<maxWrong, id: \.self) { i in
                    Circle()
                        .fill(i < hangmanWrongCount ? RenaissanceColors.errorRed : settings.cardTextColor.opacity(0.12))
                        .frame(width: 10, height: 10)
                }
                Text("\(hangmanWrongCount)/\(maxWrong)")
                    .font(.custom("EBGaramond-Regular", size: 12))
                    .foregroundStyle(settings.cardTextColor.opacity(0.4))
            }

            // Alphabet grid (responsive: 13 cols on iPad, 9 cols on iPhone)
            let alphabet: [Character] = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
            let hangmanColCount = isLargeScreen ? 13 : 9
            let hangmanCellSize: CGFloat = isLargeScreen ? 36 : 32
            let columns = Array(repeating: GridItem(.fixed(hangmanCellSize), spacing: 3), count: hangmanColCount)

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
                            .frame(width: hangmanCellSize - 2, height: hangmanCellSize - 2)
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
                        .font(RenaissanceFont.buttonSmall)
                        .foregroundStyle(color)
                        .padding(.horizontal, Spacing.xl)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: CornerRadius.sm)
                                .fill(color.opacity(0.08))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: CornerRadius.sm)
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
            SoundManager.shared.play(.hangmanWrong)
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
            SoundManager.shared.play(.tapSoft)
            // Check if all letters guessed
            if uniqueLetters.isSubset(of: hangmanGuessed) {
                SoundManager.shared.play(.correctChime)
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
            let figure = settings.cardTextColor

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
            SoundManager.shared.play(.correctChime)
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
            SoundManager.shared.play(.wrongBuzz)
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
        // If card has an infographic, show it as a reward before finalizing
        if let infographic = card.infographic {
            pendingCompleteCard = card
            withAnimation(.spring(response: 0.4)) {
                flippedOpenCard = nil
                showInfographic = infographic
            }
            return
        }

        finalizeCardCompletion(card)
    }

    private func finalizeCardCompletion(_ card: KnowledgeCard) {
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

        // Mark card as completed with simple flip-back animation
        SoundManager.shared.play(.correctChime)
        withAnimation(.easeOut(duration: 0.4)) {
            flippedOpenCard = nil
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completedCardIDs.insert(card.id)
            cardPhases[card.id] = .completed
            flipAngles[card.id] = 0
        }

        // Show guidance bubble only when current environment's cards are all done (phase transition)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            let progress = viewModel.cardProgress(for: buildingId)
            guard progress.completed < progress.total else { return }

            // Check if all cards for THIS environment are now done
            let buildingName = viewModel.buildingPlots.first(where: { $0.id == buildingId })?.building.name ?? ""
            let envCards = KnowledgeCardContent.cards(for: buildingName, in: card.environment)
            let buildingProgress = viewModel.buildingProgressMap[buildingId] ?? BuildingProgress()
            let allEnvDone = envCards.allSatisfy { buildingProgress.completedCardIDs.contains($0.id) }

            if allEnvDone {
                // Environment complete — show guidance to next phase
                guidanceBubbleCard = card
                withAnimation(.spring(response: 0.4)) {
                    showGuidanceBubble = true
                }
            }
        }

        // Check if all cards in this set complete
        if Set(completedCardIDs).union([card.id]).count == cards.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                // Don't auto-dismiss if player is chatting with the bird
                guard !showBirdChat else { return }
                onAllComplete?()
            }
        }
    }

    /// Create florin coins with pre-computed positions for each phase
    private func spawnFlorins() {
        fallingFlorins = (0..<10).map { _ in
            FallingFlorin(
                burstX: CGFloat.random(in: -140...140),
                burstY: CGFloat.random(in: -160 ... -60),    // burst UPWARD
                finalX: CGFloat.random(in: -100...100),
                size: CGFloat.random(in: 20...32),
                spinSpeed: Double.random(in: 120...360)
            )
        }
    }

    // MARK: - Florin Burst Layer

    private func florinBurstLayer(screenSize: CGSize) -> some View {
        ZStack {
            ForEach(fallingFlorins) { florin in
                let pos = florinPosition(florin, screenHeight: screenSize.height)

                florinCoinView(size: florin.size)
                    .offset(x: pos.x, y: pos.y)
                    .rotationEffect(.degrees(florinRotation(florin)))
                    .scaleEffect(florin.phase == .collected ? 0.1 : 1.0)
                    .opacity(florin.phase == .collected ? 0 : 1)
            }

            // "+X florins" counter when coins land
            if showFlorinTotal {
                VStack(spacing: 4) {
                    if let florins = earnedFlorinsFloat {
                        Text("+\(florins)")
                            .font(.custom("Cinzel-Bold", size: 32))
                            .foregroundStyle(RenaissanceColors.goldSuccess)
                            .shadow(color: RenaissanceColors.goldSuccess.opacity(0.6), radius: 10)
                    }
                    Text("florins")
                        .font(.custom("EBGaramond-SemiBold", size: 18))
                        .foregroundStyle(RenaissanceColors.goldSuccess.opacity(0.8))
                }
                .offset(y: screenSize.height * 0.28)
                .transition(.scale.combined(with: .opacity))
            }
        }
    }

    /// Compute position for each florin based on its current phase
    private func florinPosition(_ florin: FallingFlorin, screenHeight: CGFloat) -> CGPoint {
        switch florin.phase {
        case .atCard:
            return .zero  // at screen center (where card was)
        case .burst:
            return CGPoint(x: florin.burstX, y: florin.burstY)  // burst upward + outward
        case .falling:
            return CGPoint(x: florin.finalX, y: screenHeight * 0.3)  // fall to lower area
        case .landed:
            return CGPoint(x: florin.finalX, y: screenHeight * 0.25)  // slight bounce up
        case .collected:
            return CGPoint(x: 0, y: screenHeight * 0.25)  // converge to center
        }
    }

    private func florinRotation(_ florin: FallingFlorin) -> Double {
        switch florin.phase {
        case .atCard: return 0
        case .burst: return florin.spinSpeed * 0.5
        case .falling: return florin.spinSpeed
        case .landed: return florin.spinSpeed + 15
        case .collected: return florin.spinSpeed + 30
        }
    }

    /// Single gold florin coin with Florentine fleur-de-lis
    private func florinCoinView(size: CGFloat) -> some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            RenaissanceColors.ochre,
                            RenaissanceColors.goldSuccess,
                            RenaissanceColors.warmBrown
                        ],
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: size
                    )
                )
                .frame(width: size, height: size)
            Circle()
                .stroke(RenaissanceColors.warmBrown, lineWidth: 1.5)
                .frame(width: size, height: size)
            Text("⚜")
                .font(.system(size: size * 0.45))
                .foregroundStyle(RenaissanceColors.warmBrown.opacity(0.7))
        }
        .shadow(color: RenaissanceColors.goldSuccess.opacity(0.5), radius: 4, y: 2)
    }

    /// Build a contextual guidance message following the full game loop:
    /// card → tools → minigame → materials → crafting → next environment → build
    private func buildGuidanceMessage(card: KnowledgeCard, progress: (completed: Int, total: Int), nextEnv: CardEnvironment?) -> String {
        let buildingName = card.buildingName

        // All cards done → guide to building
        if progress.completed >= progress.total {
            return "Magnifico! All \(progress.total) cards collected for the \(buildingName)! Head to the City Map — you're ready to build!"
        }

        // GAME LOOP GUIDANCE — prioritize action over cards
        // If we're at a workshop station, guide through: tools → minigame → materials → next
        if let ws = workshopState, let station = currentStation, card.environment == .workshop {
            // Step 1: Does the player need a tool for this station?
            if let tool = Tool.requiredFor(station: station), !ws.hasTool(for: station) {
                return "Well done! Now you need a \(tool.displayName) to collect materials here. Head to the Market to buy one!"
            }
            // Step 2: Player has tool → minigame is next (will auto-show after dismissal)
            return "Well done! Now it's time to collect materials! Close this card and play the \(station.label) mini-game."
        }

        // For other environments, suggest the next game-loop step
        let envHint: String
        if let ws = workshopState {
            // Check if player needs tools first
            let stationsNeedingTools: [ResourceStationType] = [.quarry, .volcano, .river, .clayPit, .mine, .forest, .farm]
            let missingTools = stationsNeedingTools.filter { !ws.hasTool(for: $0) }

            if !missingTools.isEmpty && card.environment == .cityMap {
                // Player is on city map, needs tools → send to workshop/market
                envHint = "Head to the Workshop and visit the Market to get tools — you'll need them to collect building materials!"
            } else if let env = nextEnv {
                envHint = gameLoopHintForEnvironment(env, buildingName: buildingName)
            } else {
                envHint = "Keep exploring to find more cards!"
            }
        } else if let env = nextEnv {
            envHint = gameLoopHintForEnvironment(env, buildingName: buildingName)
        } else {
            envHint = "Keep exploring to find more cards!"
        }

        return "Well done! That's \(progress.completed) of \(progress.total) cards for the \(buildingName). \(envHint)"
    }

    private func gameLoopHintForEnvironment(_ env: CardEnvironment, buildingName: String) -> String {
        switch env {
        case .workshop:
            return "Head to the Workshop — learn about materials, buy tools at the Market, and collect resources!"
        case .forest:
            return "Try the Forest next — discover the timber used in the \(buildingName) and collect wood!"
        case .craftingRoom:
            return "Visit the Crafting Room — mix your collected materials into building components!"
        case .cityMap:
            return "Go back to the City Map — tap the \(buildingName) to continue learning!"
        }
    }

    /// Hint about which specific station has the next card
    private func nextStationHint(for buildingId: Int, in environment: CardEnvironment) -> String {
        let buildingName = viewModel.buildingPlots.first(where: { $0.id == buildingId })?.building.name ?? ""
        let envCards = KnowledgeCardContent.cards(for: buildingName, in: environment)
        let progress = viewModel.buildingProgressMap[buildingId] ?? BuildingProgress()
        if let nextCard = envCards.first(where: { !progress.completedCardIDs.contains($0.id) }) {
            let stationName = nextCard.stationKey
            return " (\(stationName) station)"
        }
        return ""
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
                    .fill(i < matched ? RenaissanceColors.sageGreen : settings.cardTextColor.opacity(0.15))
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
            let overallProgress = viewModel.cardProgress(for: buildingId)
            Text(done == 0 ? (total == 1 ? "Tap the card to discover something new!" : "Tap a card to start learning!")
                 : done < total ? "\(total - done) card\(total - done == 1 ? "" : "s") left — keep going!"
                 : overallProgress.completed < overallProgress.total ? "Card complete! Explore other environments for more."
                 : "All cards collected! You've mastered this building.")
                .font(RenaissanceFont.caption)
                .foregroundStyle(settings.cardTextColor.opacity(0.7))
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.xs)
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
                .foregroundStyle(settings.cardTextColor)

            // Env breakdown (only show when multiple cards)
            if cards.count > 1 {
                Text("·")
                    .foregroundStyle(settings.cardTextColor.opacity(0.3))
                Text("Here: \(completedCardIDs.count)/\(cards.count)")
                    .font(.custom("EBGaramond-Regular", size: 12))
                    .foregroundStyle(settings.cardTextColor.opacity(0.6))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 6)
        .background(
            Capsule().fill(settings.dialogBackground.opacity(0.9))
        )
    }

    // MARK: - Guidance Bubble (after card completion)

    private func guidanceBubbleView(card: KnowledgeCard) -> some View {
        let progress = viewModel.cardProgress(for: buildingId)
        let buildingProgress = viewModel.buildingProgressMap[buildingId] ?? BuildingProgress()
        let buildingName = viewModel.buildingPlots.first(where: { $0.id == buildingId })?.building.name ?? ""
        let phase = buildingProgress.currentPhase(for: buildingName, workshopState: workshopState ?? WorkshopState(), craftedMaterials: workshopState?.craftedMaterials ?? [:])
        let nextEnv = phase.environment  // nil means .build phase → city map
        let message = buildGuidanceMessage(card: card, progress: progress, nextEnv: nextEnv)

        // Determine the primary action button based on game loop state
        let actionInfo = guidanceAction(card: card, nextEnv: nextEnv)

        return VStack(spacing: 12) {
            HStack(alignment: .top, spacing: 10) {
                BirdCharacter(isSitting: true)
                    .frame(width: 44, height: 44)

                Text(message)
                    .font(RenaissanceFont.dialogSubtitle)
                    .foregroundStyle(settings.cardTextColor)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }

            HStack(spacing: 14) {
                Button {
                    switch actionInfo.type {
                    case .dismiss:
                        // Dismiss overlay → proceed to minigame/tool check
                        onDismiss()
                    case .navigate(let env):
                        navigateToEnvironment(env)
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: actionInfo.icon)
                            .font(.system(size: 14))
                        Text(actionInfo.label)
                            .font(.custom("EBGaramond-SemiBold", size: 15))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 9)
                    .parchmentCapsule(color: RenaissanceColors.renaissanceBlue)
                }
                .buttonStyle(.plain)

                Button {
                    withAnimation(.easeOut(duration: 0.3)) {
                        showGuidanceBubble = false
                        guidanceBubbleCard = nil
                    }
                } label: {
                    Text("Later")
                        .font(RenaissanceFont.caption)
                        .foregroundStyle(settings.cardTextColor.opacity(0.5))
                        .underline()
                }
                .buttonStyle(.plain)
            }
        }
        .padding(Spacing.md)
        .adaptiveWidth(420)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.md)
                .fill(settings.dialogBackground)
                .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: CornerRadius.md)
                .stroke(RenaissanceColors.renaissanceBlue.opacity(0.2), lineWidth: 1)
        )
    }

    private func navigateToEnvironment(_ env: CardEnvironment) {
        let destination: SidebarDestination = {
            switch env {
            case .workshop: return .workshop
            case .forest: return .forest
            case .craftingRoom: return .workshop  // crafting room is inside workshop
            case .cityMap: return .cityMap
            }
        }()
        withAnimation(.easeOut(duration: 0.2)) {
            showGuidanceBubble = false
            guidanceBubbleCard = nil
        }
        onNavigate?(destination)
    }

    // MARK: - Game Loop Guidance Action

    private enum GuidanceActionType {
        case dismiss  // close overlay → proceed to minigame/tool check at current station
        case navigate(CardEnvironment)  // go to another environment
    }

    private struct GuidanceAction {
        let type: GuidanceActionType
        let label: String
        let icon: String
    }

    /// Determine the primary button action based on full game loop state
    private func guidanceAction(card: KnowledgeCard, nextEnv: CardEnvironment?) -> GuidanceAction {
        // At a workshop station → guide through tools/minigame flow
        if let ws = workshopState, let station = currentStation, card.environment == .workshop {
            if let tool = Tool.requiredFor(station: station), !ws.hasTool(for: station) {
                // Needs tool → dismiss overlay, which triggers pendingStationAfterCard → tool dialog → market
                return GuidanceAction(type: .dismiss, label: "Get \(tool.displayName)!", icon: "cart.fill")
            }
            // Has tool → dismiss overlay, which triggers minigame
            return GuidanceAction(type: .dismiss, label: "Collect Materials!", icon: "pickaxe")
        }

        // Check if player needs tools (from city map)
        if let ws = workshopState, card.environment == .cityMap {
            let stationsNeedingTools: [ResourceStationType] = [.quarry, .volcano, .river, .clayPit, .mine, .forest, .farm]
            let missingTools = stationsNeedingTools.filter { !ws.hasTool(for: $0) }
            if !missingTools.isEmpty {
                return GuidanceAction(type: .navigate(.workshop), label: "Go to Workshop!", icon: "hammer.fill")
            }
        }

        // Navigate to suggested environment
        if let env = nextEnv {
            switch env {
            case .workshop:
                return GuidanceAction(type: .navigate(.workshop), label: "Go to Workshop!", icon: "hammer.fill")
            case .forest:
                return GuidanceAction(type: .navigate(.forest), label: "Go to Forest!", icon: "tree.fill")
            case .craftingRoom:
                return GuidanceAction(type: .navigate(.craftingRoom), label: "Go to Crafting Room!", icon: "wrench.and.screwdriver.fill")
            case .cityMap:
                return GuidanceAction(type: .navigate(.cityMap), label: "Back to City Map!", icon: "building.columns.fill")
            }
        }

        // Fallback: dismiss
        return GuidanceAction(type: .dismiss, label: "Continue!", icon: "arrow.right")
    }
}

// MARK: - CardPhase (shared with ForestMapView)

// CardPhase is already defined in ScienceCardContent.swift — reuse it
