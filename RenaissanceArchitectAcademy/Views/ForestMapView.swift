import SwiftUI
import SpriteKit

/// SwiftUI wrapper for the ForestScene SpriteKit experience
/// Layers: SpriteKit scene → bird companion → nav panel + inventory → science cards overlay → truffle overlay
struct ForestMapView: View {

    var workshop: WorkshopState
    var viewModel: CityViewModel? = nil
    var onNavigate: ((SidebarDestination) -> Void)? = nil
    var onBackToWorkshop: (() -> Void)? = nil
    var onBackToMenu: (() -> Void)? = nil
    var onboardingState: OnboardingState? = nil
    @Binding var returnToLessonPlotId: Int?

    @State private var scene: ForestScene?
    @State private var playerPosition: CGPoint = CGPoint(x: 0.5, y: 0.5)
    @State private var playerIsWalking = false

    // POI info overlay state
    @State private var selectedPOIIndex: Int?

    // Science Cards state
    @State private var scienceCards: [ScienceCardData] = []
    @State private var cardPhases: [ForestCardCategory: CardPhase] = [:]
    @State private var completedCards: Set<ForestCardCategory> = []
    @State private var flippedCards: Set<ForestCardCategory> = []  // which cards are face-down (showing lesson)
    @State private var activeCard: ForestCardCategory? = nil       // which card is in activity mode
    @State private var cardsAppeared = false

    // Keyword matching state
    @State private var matchedPairIDs: Set<UUID> = []
    @State private var selectedKeywordID: UUID? = nil
    @State private var selectedDefinitionID: UUID? = nil
    @State private var shuffledDefinitions: [KeywordPair] = []
    @State private var wrongMatchFlash = false
    @State private var earnedFlorinsFloat: Int? = nil

    // Truffle discovery overlay state
    @State private var discoveredTruffle: ForestScene.TruffleFind?
    @State private var pendingTruffle: ForestScene.TruffleFind?

    // Floating timber collection feedback
    @State private var showTimberFloat = false
    @State private var timberFloatAmount = 0
    @State private var timberFloatFlorins = 0

    // Floating truffle sale feedback
    @State private var showTruffleSaleFloat = false
    @State private var truffleSaleFlorins = 0

    // Magic Mouse scroll-to-zoom
    @State private var scrollMonitor: Any?

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Layer 1: SpriteKit scene
                SpriteView(scene: makeScene(), options: [.allowsTransparency])
                    .ignoresSafeArea()
                    .gesture(pinchGesture)

                // Layer 2: Bird companion overlay
                BirdCharacter(isSitting: !playerIsWalking)
                    .frame(width: 100, height: 100)
                    .position(
                        x: playerPosition.x * geometry.size.width + 70,
                        y: playerPosition.y * geometry.size.height - 50
                    )
                    .allowsHitTesting(false)

                // Layer 3: Nav panel + inventory bar (same layout as Workshop)
                VStack(spacing: 0) {
                    navigationPanel
                        .frame(maxWidth: .infinity)
                    Spacer()
                    inventoryBar
                }
                .frame(maxWidth: .infinity)
                .padding(16)

                // Layer 4: Science Cards overlay (replaces old poiInfoOverlay)
                if let poiIndex = selectedPOIIndex,
                   let poi = scene?.getPOI(at: poiIndex) {
                    scienceCardsOverlay(poi: poi)
                        .transition(.opacity.combined(with: .scale(scale: 0.9)))
                }

                // Layer 5: Truffle discovery overlay
                if let truffle = discoveredTruffle {
                    truffleDiscoveryOverlay(truffle: truffle)
                        .transition(.opacity.combined(with: .scale(scale: 0.85)))
                }

                // Layer 6: Floating "+N timber +N florins" feedback
                if showTimberFloat {
                    HStack(spacing: 8) {
                        Text("+\(timberFloatAmount) 🪵")
                            .font(.custom("Cinzel-Bold", size: 22))
                            .foregroundStyle(RenaissanceColors.sepiaInk)
                        if timberFloatFlorins > 0 {
                            Text("+\(timberFloatFlorins) florins")
                                .font(.custom("Cinzel-Bold", size: 20))
                                .foregroundStyle(RenaissanceColors.goldSuccess)
                        }
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    .padding(.bottom, 80)
                    .allowsHitTesting(false)
                }

                // Layer 7: Floating truffle sale feedback
                if showTruffleSaleFloat {
                    Text("+\(truffleSaleFlorins) florins")
                        .font(.custom("Cinzel-Bold", size: 24))
                        .foregroundStyle(RenaissanceColors.goldSuccess)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                        .padding(.bottom, 80)
                        .allowsHitTesting(false)
                }

                // Layer 8: Floating florins earned from keyword match
                if let florins = earnedFlorinsFloat {
                    Text("+\(florins) florins")
                        .font(.custom("Cinzel-Bold", size: 20))
                        .foregroundStyle(RenaissanceColors.goldSuccess)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .offset(y: -40)
                        .allowsHitTesting(false)
                }
            }
            .onChange(of: selectedPOIIndex) { _, newValue in
                if newValue != nil {
                    // Initialize science cards for the new POI
                    if let poi = scene?.getPOI(at: newValue!) {
                        setupScienceCards(for: poi)
                    }
                } else {
                    // When POI overlay is dismissed, show any pending truffle
                    if let truffle = pendingTruffle {
                        pendingTruffle = nil
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                discoveredTruffle = truffle
                            }
                        }
                    }
                }
            }
            .onAppear {
                #if os(macOS)
                scrollMonitor = NSEvent.addLocalMonitorForEvents(matching: .scrollWheel) { [self] event in
                    if selectedPOIIndex == nil && discoveredTruffle == nil {
                        scene?.handleScrollZoom(deltaY: event.deltaY)
                    }
                    return event
                }
                #endif
            }
            .onDisappear {
                #if os(macOS)
                if let monitor = scrollMonitor {
                    NSEvent.removeMonitor(monitor)
                    scrollMonitor = nil
                }
                #endif
            }
        }
    }

    // MARK: - Science Cards Setup

    private func setupScienceCards(for poi: ForestScene.ForestPOI) {
        scienceCards = ScienceCardContent.cards(for: poi.name)
        cardPhases = [:]
        completedCards = []
        flippedCards = []
        flippedOpenCard = nil
        activeCard = nil
        cardsAppeared = false
        floatOffset = 0
        matchedPairIDs = []
        selectedKeywordID = nil
        selectedDefinitionID = nil
        shuffledDefinitions = []
        wrongMatchFlash = false

        for cat in ForestCardCategory.allCases {
            cardPhases[cat] = .faceUp
        }

        // Staggered card appearance animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                cardsAppeared = true
            }
        }
    }

    // MARK: - Science Cards Overlay

    /// Which card is currently flipped open (showing lesson back). nil = all face-up spread.
    @State private var flippedOpenCard: ForestCardCategory? = nil
    /// Floating bob offset, animated on appear
    @State private var floatOffset: CGFloat = 0
    /// Rotating aura angle for magical glow on card fronts
    @State private var auraAngle: Double = 0

    private let cardW: CGFloat = 200
    private let cardH: CGFloat = 280  // ~5:7 poker ratio
    private let flippedW: CGFloat = 400
    private let flippedH: CGFloat = 560

    private func scienceCardsOverlay(poi: ForestScene.ForestPOI) -> some View {
        GeometryReader { geo in
            ZStack {
                RenaissanceColors.overlayDimming
                    .ignoresSafeArea()
                    .onTapGesture {
                        if activeCard != nil {
                            closeActiveCard()
                        } else if flippedOpenCard != nil {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                                flippedOpenCard = nil
                            }
                        } else {
                            dismissScienceCards()
                        }
                    }

                if let expanded = activeCard,
                   let cardData = scienceCards.first(where: { $0.category == expanded }) {
                    // ACTIVITY MODE: keyword matching
                    activityCardView(cardData: cardData)
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.85).combined(with: .opacity),
                            removal: .scale(scale: 0.9).combined(with: .opacity)
                        ))
                } else {
                    // Tree header (top)
                    VStack(spacing: 5) {
                        Text(poi.name)
                            .font(.custom("Cinzel-Bold", size: 22))
                            .foregroundStyle(RenaissanceColors.sepiaInk)
                        Text(poi.italianName)
                            .font(.custom("Mulish-Light", size: 14))
                            .foregroundStyle(RenaissanceColors.warmBrown)
                        HStack(spacing: 6) {
                            poiBadge(poi.woodType, color: RenaissanceColors.ochre)
                            poiBadge(poi.leafType, color: RenaissanceColors.sageGreen)
                            poiBadge(poi.maxHeight, color: RenaissanceColors.warmBrown)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 20)
                    .frame(maxHeight: .infinity, alignment: .top)

                    // Cards row — spread in center, pile when one flips
                    cardsRowView(screenSize: geo.size)

                    // Flipped card — rendered at full readable size, centered
                    if let flipped = flippedOpenCard,
                       let cardData = scienceCards.first(where: { $0.category == flipped }) {
                        let isCompleted = completedCards.contains(flipped)
                        flippedCardBack(cardData: cardData, isCompleted: isCompleted)
                            .onTapGesture {
                                if !isCompleted {
                                    openActivityForCard(flipped)
                                }
                            }
                            .transition(.scale(scale: 0.5).combined(with: .opacity))
                            .zIndex(20)
                    }

                    // Bottom bar: bird + timber button
                    VStack(spacing: 10) {
                        birdEncouragement
                        collectTimberButton(poi: poi)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                floatOffset = 8
            }
            withAnimation(.linear(duration: 4.0).repeatForever(autoreverses: false)) {
                auraAngle = 360
            }
        }
    }

    // MARK: - Cards Row (single row, pile when one is flipped)

    private func cardsRowView(screenSize: CGSize) -> some View {
        let allCategories = ForestCardCategory.allCases
        let spacing: CGFloat = 16
        let totalWidth = CGFloat(allCategories.count) * cardW + CGFloat(allCategories.count - 1) * spacing

        return ZStack {
            // Connection line behind spread cards
            if flippedOpenCard == nil {
                Rectangle()
                    .fill(RenaissanceColors.ochre.opacity(0.2))
                    .frame(width: totalWidth - 60, height: 2)
            }

            ForEach(Array(allCategories.enumerated()), id: \.element) { index, category in
                let isCompleted = completedCards.contains(category)
                let isThisFlipped = flippedOpenCard == category
                let someCardFlipped = flippedOpenCard != nil
                let isPiled = someCardFlipped && !isThisFlipped

                // Spread position: center the row
                let spreadX = CGFloat(index) * (cardW + spacing) - (totalWidth - cardW) / 2

                // Pile position: stack to the left
                let pileX = -screenSize.width * 0.35 + CGFloat(pileStackIndex(category)) * 8

                cardFront(category: category, isCompleted: isCompleted)
                    .frame(width: cardW, height: cardH)
                    .opacity(isThisFlipped ? 0 : 1) // hide front when back is shown centered
                    .scaleEffect(isPiled ? 0.5 : 1.0)
                    .offset(
                        x: someCardFlipped ? (isPiled ? pileX : 0) : spreadX,
                        y: isPiled ? CGFloat(pileStackIndex(category)) * 5 : floatOffset * (index.isMultiple(of: 2) ? 1 : -1)
                    )
                    .rotation3DEffect(.degrees(isPiled ? -5 + Double(pileStackIndex(category)) * 3 : 0), axis: (x: 0, y: 0, z: 1))
                    .opacity(isPiled ? 0.65 : 1.0)
                    .zIndex(isThisFlipped ? 10 : Double(isPiled ? pileStackIndex(category) : index))
                    // Appear animation
                    .scaleEffect(cardsAppeared ? 1.0 : 0.2)
                    .opacity(cardsAppeared ? 1.0 : 0)
                    .animation(
                        .spring(response: 0.5, dampingFraction: 0.65)
                            .delay(Double(index) * 0.1),
                        value: cardsAppeared
                    )
                    .animation(.spring(response: 0.55, dampingFraction: 0.75), value: flippedOpenCard)
                    .onTapGesture {
                        handleCardTap(category: category, isCompleted: isCompleted)
                    }
            }
        }
    }

    /// Stack order for piled cards
    private func pileStackIndex(_ category: ForestCardCategory) -> Int {
        let others = ForestCardCategory.allCases.filter { $0 != flippedOpenCard }
        return others.firstIndex(of: category) ?? 0
    }

    /// Handle tap on a card — flip or go to activity
    private func handleCardTap(category: ForestCardCategory, isCompleted: Bool) {
        if isCompleted { return }

        if flippedOpenCard == category {
            // Already flipped — go to activity
            openActivityForCard(category)
        } else {
            // Flip this card: it scales up centered, others pile left
            withAnimation(.spring(response: 0.55, dampingFraction: 0.75)) {
                flippedOpenCard = category
                flippedCards.insert(category)
                cardPhases[category] = .reading
            }
        }
    }

    // MARK: - Card Front (icon + science name)

    private func cardFront(category: ForestCardCategory, isCompleted: Bool) -> some View {
        ZStack {
            // Aura glow layer (behind the glass card)
            if !isCompleted {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        AngularGradient(
                            colors: [
                                category.color.opacity(0.6),
                                category.color.opacity(0.1),
                                RenaissanceColors.goldSuccess.opacity(0.4),
                                category.color.opacity(0.1),
                                category.color.opacity(0.6),
                            ],
                            center: .center,
                            angle: .degrees(auraAngle)
                        )
                    )
                    .blur(radius: 12)
                    .frame(width: cardW + 16, height: cardH + 16)
            }

            // Glass card body
            VStack(spacing: 12) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(isCompleted ? RenaissanceColors.sageGreen.opacity(0.2) : category.color.opacity(0.15))
                        .frame(width: 70, height: 70)

                    Image(systemName: isCompleted ? "checkmark.circle.fill" : category.icon)
                        .font(.system(size: 36))
                        .foregroundStyle(isCompleted ? RenaissanceColors.sageGreen : category.color)
                        .shadow(color: isCompleted ? .clear : category.color.opacity(0.5), radius: 6)
                }

                Text(category.rawValue)
                    .font(.custom("Cinzel-Bold", size: 15))
                    .foregroundStyle(isCompleted ? RenaissanceColors.sageGreen : RenaissanceColors.sepiaInk)

                if !isCompleted {
                    Image(systemName: "hand.tap.fill")
                        .font(.system(size: 13))
                        .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.3))
                }

                Spacer()
            }
            .frame(width: cardW, height: cardH)
            .background(
                ZStack {
                    // Frosted glass layers
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            isCompleted
                            ? RenaissanceColors.sageGreen.opacity(0.06)
                            : RenaissanceColors.parchmentLight.opacity(0.5)
                        )
                    RoundedRectangle(cornerRadius: 14)
                        .fill(.ultraThinMaterial)
                        .opacity(isCompleted ? 0 : 1)
                    // Inner shimmer highlight
                    if !isCompleted {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.25),
                                        Color.white.opacity(0.0),
                                        Color.white.opacity(0.1),
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        LinearGradient(
                            colors: isCompleted
                                ? [RenaissanceColors.sageGreen.opacity(0.4)]
                                : [
                                    category.color.opacity(0.6),
                                    Color.white.opacity(0.3),
                                    category.color.opacity(0.4),
                                ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: isCompleted ? 1.5 : 2
                    )
            )
            .shadow(color: isCompleted ? .clear : category.color.opacity(0.3), radius: 10, y: 4)
        }
    }

    // MARK: - Flipped Card Back (full-size, centered, with highlighted keywords + visual space)

    private func flippedCardBack(cardData: ScienceCardData, isCompleted: Bool) -> some View {
        VStack(spacing: 0) {
            // Category header
            HStack(spacing: 8) {
                Image(systemName: cardData.category.icon)
                    .font(.system(size: 20))
                Text(cardData.category.rawValue)
                    .font(.custom("Cinzel-Bold", size: 20))
            }
            .foregroundStyle(cardData.category.color)
            .padding(.top, 16)
            .padding(.bottom, 8)

            Rectangle()
                .fill(cardData.category.color.opacity(0.2))
                .frame(height: 1)
                .padding(.horizontal, 12)

            // Visual area — decorative science illustration placeholder
            HStack(spacing: 12) {
                ForEach(cardData.keywords.prefix(4)) { pair in
                    VStack(spacing: 4) {
                        Circle()
                            .fill(cardData.category.color.opacity(0.1))
                            .frame(width: 44, height: 44)
                            .overlay(
                                Image(systemName: cardData.category.icon)
                                    .font(.system(size: 18))
                                    .foregroundStyle(cardData.category.color.opacity(0.5))
                            )
                        Text(pair.keyword)
                            .font(.custom("Mulish-SemiBold", size: 10))
                            .foregroundStyle(cardData.category.color)
                            .lineLimit(1)
                    }
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 8)

            Rectangle()
                .fill(cardData.category.color.opacity(0.1))
                .frame(height: 1)
                .padding(.horizontal, 12)

            // Lesson text with highlighted keywords
            ScrollView(.vertical, showsIndicators: false) {
                highlightedLessonText(cardData: cardData)
                    .padding(.top, 10)
            }
            .padding(.horizontal, 4)

            Spacer(minLength: 8)

            if !isCompleted {
                Button {
                    openActivityForCard(cardData.category)
                } label: {
                    Text("Done Reading")
                        .font(.custom("Mulish-SemiBold", size: 16))
                        .foregroundStyle(.white)
                        .padding(.vertical, 11)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(cardData.category.color)
                        )
                }
            }
        }
        .padding(16)
        .frame(width: flippedW, height: flippedH)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(RenaissanceColors.parchment)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(cardData.category.color.opacity(0.4), lineWidth: 2.5)
        )
        .shadow(color: cardData.category.color.opacity(0.2), radius: 14, y: 5)
    }

    // MARK: - Highlighted Lesson Text (keywords colored by category)

    private func highlightedLessonText(cardData: ScienceCardData) -> Text {
        let lesson = cardData.lessonText
        let keywords = cardData.keywords.map { $0.keyword }
        let color = cardData.category.color

        // Build ranges of keyword matches
        var segments: [(String, Bool)] = [] // (text, isKeyword)
        var remaining = lesson

        while !remaining.isEmpty {
            // Find the earliest keyword match
            var earliestRange: Range<String.Index>? = nil
            var earliestKeyword = ""

            for kw in keywords {
                if let range = remaining.range(of: kw, options: .caseInsensitive) {
                    if earliestRange == nil || range.lowerBound < earliestRange!.lowerBound {
                        earliestRange = range
                        earliestKeyword = kw
                    }
                }
            }

            if let range = earliestRange {
                // Add text before the keyword
                let before = String(remaining[remaining.startIndex..<range.lowerBound])
                if !before.isEmpty {
                    segments.append((before, false))
                }
                // Add the keyword (use original casing from text)
                segments.append((String(remaining[range]), true))
                remaining = String(remaining[range.upperBound...])
            } else {
                // No more keywords found
                segments.append((remaining, false))
                remaining = ""
            }
        }

        // Build the styled Text
        var result = Text("")
        for (text, isKeyword) in segments {
            if isKeyword {
                result = result + Text(text)
                    .font(.custom("Mulish-SemiBold", size: 15))
                    .foregroundColor(color)
            } else {
                result = result + Text(text)
                    .font(.custom("Mulish-Light", size: 15))
                    .foregroundColor(RenaissanceColors.sepiaInk)
            }
        }

        return result
    }

    // MARK: - Activity Card View (keyword matching)

    private func activityCardView(cardData: ScienceCardData) -> some View {
        VStack(spacing: 14) {
            HStack {
                Button {
                    closeActiveCard()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back to Cards")
                    }
                    .font(.custom("Mulish-Medium", size: 14))
                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.6))
                }
                Spacer()
                Image(systemName: cardData.category.icon)
                    .font(.system(size: 18))
                    .foregroundStyle(cardData.category.color)
                Text(cardData.category.rawValue)
                    .font(.custom("Cinzel-Bold", size: 16))
                    .foregroundStyle(cardData.category.color)
            }

            Divider()

            activityPhaseView(cardData: cardData)
        }
        .padding(20)
        .frame(maxWidth: 420)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(RenaissanceColors.parchmentLight)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(cardData.category.color.opacity(0.4), lineWidth: 2)
        )
        .shadow(color: cardData.category.color.opacity(0.2), radius: 10, y: 4)
    }

    // MARK: - Activity Phase (Keyword Matching)

    private func activityPhaseView(cardData: ScienceCardData) -> some View {
        VStack(spacing: 14) {
            Text("Match each term to its meaning")
                .font(.custom("Mulish-Medium", size: 13))
                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.6))

            // Keywords column
            VStack(spacing: 8) {
                ForEach(cardData.keywords) { pair in
                    let isMatched = matchedPairIDs.contains(pair.id)
                    let isSelected = selectedKeywordID == pair.id

                    Button {
                        if !isMatched { selectKeyword(pair.id, cardData: cardData) }
                    } label: {
                        HStack {
                            Image(systemName: isMatched ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 14))
                                .foregroundStyle(isMatched ? RenaissanceColors.sageGreen : cardData.category.color.opacity(0.4))

                            Text(pair.keyword)
                                .font(.custom("Mulish-SemiBold", size: 14))
                                .foregroundStyle(
                                    isMatched ? RenaissanceColors.sageGreen
                                    : isSelected ? cardData.category.color
                                    : RenaissanceColors.sepiaInk
                                )

                            Spacer()
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(
                                    isMatched ? RenaissanceColors.sageGreen.opacity(0.08)
                                    : isSelected ? cardData.category.color.opacity(0.12)
                                    : RenaissanceColors.ochre.opacity(0.04)
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(
                                    isSelected ? cardData.category.color.opacity(0.6) : Color.clear,
                                    lineWidth: 1.5
                                )
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(isMatched)
                    .opacity(isMatched ? 0.6 : 1)
                }
            }

            // Divider with arrow
            HStack {
                Rectangle()
                    .fill(RenaissanceColors.sepiaInk.opacity(0.1))
                    .frame(height: 1)
                Image(systemName: "arrow.down")
                    .font(.system(size: 11))
                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.25))
                Rectangle()
                    .fill(RenaissanceColors.sepiaInk.opacity(0.1))
                    .frame(height: 1)
            }

            // Definitions column (shuffled)
            VStack(spacing: 8) {
                ForEach(shuffledDefinitions) { pair in
                    let isMatched = matchedPairIDs.contains(pair.id)
                    let isSelected = selectedDefinitionID == pair.id
                    let isWrong = wrongMatchFlash && isSelected

                    Button {
                        if !isMatched { selectDefinition(pair.id, cardData: cardData) }
                    } label: {
                        HStack {
                            Text(pair.definition)
                                .font(.custom("Mulish-Light", size: 13))
                                .foregroundStyle(
                                    isWrong ? RenaissanceColors.errorRed
                                    : isMatched ? RenaissanceColors.sageGreen
                                    : isSelected ? cardData.category.color
                                    : RenaissanceColors.sepiaInk.opacity(0.8)
                                )
                                .multilineTextAlignment(.leading)

                            Spacer()

                            if isMatched {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(RenaissanceColors.sageGreen)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(
                                    isWrong ? RenaissanceColors.errorRed.opacity(0.08)
                                    : isMatched ? RenaissanceColors.sageGreen.opacity(0.08)
                                    : isSelected ? cardData.category.color.opacity(0.08)
                                    : RenaissanceColors.ochre.opacity(0.04)
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(
                                    isWrong ? RenaissanceColors.errorRed.opacity(0.5)
                                    : isSelected ? cardData.category.color.opacity(0.5)
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

            // Progress indicator
            let total = cardData.keywords.count
            let matched = matchedPairIDs.count
            HStack(spacing: 4) {
                ForEach(0..<total, id: \.self) { i in
                    Circle()
                        .fill(i < matched ? RenaissanceColors.sageGreen : RenaissanceColors.sepiaInk.opacity(0.15))
                        .frame(width: 8, height: 8)
                }
            }
        }
    }

    // MARK: - Keyword Matching Logic

    private func selectKeyword(_ id: UUID, cardData: ScienceCardData) {
        withAnimation(.easeOut(duration: 0.15)) {
            selectedKeywordID = id
        }
        // If a definition is already selected, try to match
        if let defID = selectedDefinitionID {
            tryMatch(keywordID: id, definitionID: defID, cardData: cardData)
        }
    }

    private func selectDefinition(_ id: UUID, cardData: ScienceCardData) {
        withAnimation(.easeOut(duration: 0.15)) {
            selectedDefinitionID = id
        }
        // If a keyword is already selected, try to match
        if let kwID = selectedKeywordID {
            tryMatch(keywordID: kwID, definitionID: id, cardData: cardData)
        }
    }

    private func tryMatch(keywordID: UUID, definitionID: UUID, cardData: ScienceCardData) {
        // Both IDs should refer to the same KeywordPair (keyword tapped = definition tapped)
        if keywordID == definitionID {
            // Correct match!
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                matchedPairIDs.insert(keywordID)
                selectedKeywordID = nil
                selectedDefinitionID = nil
            }

            // Award florins
            let florins = GameRewards.scienceCardMatchFlorins
            viewModel?.earnFlorins(florins)

            // Show floating florins
            withAnimation(.spring(response: 0.3)) {
                earnedFlorinsFloat = florins
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeOut(duration: 0.3)) {
                    earnedFlorinsFloat = nil
                }
            }

            // Check if all pairs matched — card complete
            if matchedPairIDs.count == cardData.keywords.count {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    completeCard(cardData.category)
                }
            }
        } else {
            // Wrong match — flash red
            withAnimation(.easeOut(duration: 0.15)) {
                wrongMatchFlash = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeOut(duration: 0.15)) {
                    wrongMatchFlash = false
                    selectedKeywordID = nil
                    selectedDefinitionID = nil
                }
            }
        }
    }

    // MARK: - Card Actions

    /// User tapped "Done Reading" — open the keyword matching activity
    private func openActivityForCard(_ category: ForestCardCategory) {
        if let cardData = scienceCards.first(where: { $0.category == category }) {
            shuffledDefinitions = cardData.keywords.shuffled()
            matchedPairIDs = []
            selectedKeywordID = nil
            selectedDefinitionID = nil
        }

        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            activeCard = category
            cardPhases[category] = .activity
        }
    }

    /// Close the activity view and return to the card row
    private func closeActiveCard() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            activeCard = nil
            flippedOpenCard = nil
        }
    }

    /// Mark a card as completed after all keyword pairs are matched
    private func completeCard(_ category: ForestCardCategory) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            cardPhases[category] = .completed
            completedCards.insert(category)
            activeCard = nil
            flippedOpenCard = nil
        }
    }

    private func dismissScienceCards() {
        withAnimation(.easeOut(duration: 0.2)) {
            selectedPOIIndex = nil
            cardsAppeared = false
        }
    }

    // MARK: - Bird Encouragement

    private var birdEncouragement: some View {
        HStack(spacing: 10) {
            BirdCharacter(isSitting: true)
                .frame(width: 36, height: 36)

            let count = completedCards.count
            Text(count == 0 ? "Tap a card to discover this tree's secrets!"
                 : count < 4 ? "\(4 - count) card\(4 - count == 1 ? "" : "s") left — keep going!"
                 : "All done! Collect your timber!")
                .font(.custom("Mulish-Light", size: 13))
                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(RenaissanceColors.ochre.opacity(0.06))
        )
    }

    // MARK: - Collect Timber Button (gated behind card completion)

    private func collectTimberButton(poi: ForestScene.ForestPOI) -> some View {
        let allDone = completedCards.count == 4

        return VStack(spacing: 6) {
            Button {
                if allDone { collectTimber(from: poi) }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: allDone ? "leaf.fill" : "lock.fill")
                        .font(.body)
                    Text(allDone
                         ? "Collect Timber (+\(poi.timberYield) 🪵)"
                         : "Complete all cards to collect")
                        .font(.custom("Mulish-SemiBold", size: 15))
                }
                .foregroundStyle(.white)
                .padding(.vertical, 11)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(allDone ? RenaissanceColors.ochre : RenaissanceColors.stoneGray.opacity(0.5))
                )
            }
            .disabled(!allDone)
            .scaleEffect(allDone ? 1.0 : 0.97)
            .animation(.easeInOut(duration: 0.3), value: allDone)

            Button {
                dismissScienceCards()
            } label: {
                Text("Continue Exploring")
                    .font(.custom("Mulish-Light", size: 13))
                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.4))
            }
        }
    }

    // MARK: - Badges

    private func poiBadge(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.custom("Mulish-Medium", size: 11))
            .foregroundStyle(RenaissanceColors.sepiaInk)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(
                Capsule()
                    .fill(color.opacity(0.12))
            )
    }

    // MARK: - Truffle Discovery Overlay — compact excitement card

    private func truffleDiscoveryOverlay(truffle: ForestScene.TruffleFind) -> some View {
        ZStack {
            RenaissanceColors.overlayDimming
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeOut(duration: 0.2)) {
                        discoveredTruffle = nil
                    }
                }

            VStack(spacing: 14) {
                Text("You found something!")
                    .font(.custom("Cinzel-Bold", size: 13))
                    .foregroundStyle(RenaissanceColors.ochre)
                    .tracking(2)

                Text(truffle.name)
                    .font(.custom("Cinzel-Bold", size: 22))
                    .foregroundStyle(RenaissanceColors.sepiaInk)

                HStack(spacing: 8) {
                    Text(truffle.italianName)
                        .font(.custom("Mulish-Light", size: 14))
                        .foregroundStyle(RenaissanceColors.warmBrown)

                    Text(truffle.rarity)
                        .font(.custom("Mulish-SemiBold", size: 11))
                        .foregroundStyle(truffle.rarity == "Rare" ? RenaissanceColors.goldSuccess : RenaissanceColors.sepiaInk)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(truffle.rarity == "Rare"
                                      ? RenaissanceColors.goldSuccess.opacity(0.15)
                                      : RenaissanceColors.ochre.opacity(0.12))
                        )
                }

                Text(truffle.description)
                    .font(.custom("Mulish-Light", size: 14))
                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.75))
                    .multilineTextAlignment(.center)
                    .lineLimit(3)

                HStack(alignment: .top, spacing: 10) {
                    BirdCharacter(isSitting: true)
                        .frame(width: 40, height: 40)

                    Text(birdTruffleAdvice(for: truffle))
                        .font(.custom("Mulish-Light", size: 13))
                        .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.75))
                        .lineLimit(3)
                }
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(RenaissanceColors.ochre.opacity(0.05))
                )

                Button {
                    sellTruffle(truffle)
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.body)
                        Text("Sell at Market (+\(truffle.value) florins)")
                            .font(.custom("Mulish-SemiBold", size: 16))
                    }
                    .foregroundStyle(.white)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(RenaissanceColors.goldSuccess)
                    )
                }

                Button {
                    withAnimation(.easeOut(duration: 0.2)) {
                        discoveredTruffle = nil
                    }
                } label: {
                    Text("Keep Exploring")
                        .font(.custom("Mulish-Light", size: 14))
                        .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.5))
                }
            }
            .padding(20)
            .frame(maxWidth: 380)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(RenaissanceColors.parchment)
            )
            .borderAccent(radius: 16)
        }
    }

    private func birdTruffleAdvice(for truffle: ForestScene.TruffleFind) -> String {
        switch truffle.rarity {
        case "Rare":
            return "A \(truffle.italianName)! Nobles paid fortunes for these — sell it for \(truffle.value) florins!"
        default:
            return "A truffle! Sell it at the market for \(truffle.value) florins. Not bad for something hiding in the dirt!"
        }
    }

    // MARK: - Truffle Sale

    private func sellTruffle(_ truffle: ForestScene.TruffleFind) {
        viewModel?.earnFlorins(truffle.value)
        scene?.playPlayerCelebrateAnimation()

        withAnimation(.easeOut(duration: 0.2)) {
            discoveredTruffle = nil
        }

        truffleSaleFlorins = truffle.value
        withAnimation(.spring(response: 0.4)) {
            showTruffleSaleFloat = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            withAnimation(.easeOut(duration: 0.3)) {
                showTruffleSaleFloat = false
            }
        }
    }

    // MARK: - Timber Collection

    private func collectTimber(from poi: ForestScene.ForestPOI) {
        var collected = 0
        for _ in 0..<poi.timberYield {
            if workshop.collectFromStation(.forest, material: .timber) {
                collected += 1
            }
        }

        let florinsEarned = collected * GameRewards.timberCollectFlorins
        if florinsEarned > 0 {
            viewModel?.earnFlorins(florinsEarned)
            scene?.playPlayerCelebrateAnimation()
        }

        withAnimation(.easeOut(duration: 0.2)) {
            selectedPOIIndex = nil
            cardsAppeared = false
        }

        if collected > 0 {
            timberFloatAmount = collected
            timberFloatFlorins = florinsEarned
            withAnimation(.spring(response: 0.4)) {
                showTimberFloat = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeOut(duration: 0.3)) {
                    showTimberFloat = false
                }
            }
        }
    }

    // MARK: - Navigation Panel

    private var navigationPanel: some View {
        Group {
            if let viewModel = viewModel {
                GameTopBarView(
                    title: "Italian Forest",
                    viewModel: viewModel,
                    onNavigate: { destination in
                        onNavigate?(destination)
                    },
                    showBackButton: true,
                    onBack: { onBackToWorkshop?() },
                    onBackToMenu: onBackToMenu,
                    onboardingState: onboardingState,
                    returnToLessonBuildingName: returnToLessonPlotId.flatMap { id in
                        viewModel.buildingPlots.first(where: { $0.id == id })?.building.name
                    },
                    onReturnToLesson: returnToLessonPlotId != nil ? {
                        onNavigate?(.cityMap)
                    } : nil
                )
            } else {
                VStack(spacing: 8) {
                    Button { onBackToWorkshop?() } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                            Text("Workshop")
                        }
                        .font(.custom("Mulish-Light", size: 16))
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .glassButton(shape: Capsule())
                    }
                    Text("Italian Forest")
                        .font(.custom("Mulish-SemiBold", size: 22))
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .glassButton(shape: Capsule())
                }
            }
        }
    }

    // MARK: - Inventory Bar

    private var inventoryBar: some View {
        HStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Material.allCases) { material in
                        let count = workshop.rawMaterials[material] ?? 0
                        if count > 0 {
                            HStack(spacing: 3) {
                                Text(material.icon)
                                    .font(.caption)
                                Text("\(count)")
                                    .font(.custom("Mulish-Light", size: 12))
                                    .foregroundStyle(RenaissanceColors.sepiaInk)
                            }
                            .padding(.horizontal, 6)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(RenaissanceColors.parchment.opacity(0.8))
                            )
                        }
                    }
                }
            }

            Divider()
                .frame(height: 30)
                .padding(.horizontal, 8)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(CraftedItem.allCases) { item in
                        let count = workshop.craftedMaterials[item] ?? 0
                        if count > 0 {
                            HStack(spacing: 3) {
                                Text(item.icon)
                                    .font(.caption)
                                Text("\(count)")
                                    .font(.custom("Mulish-Light", size: 12))
                                    .foregroundStyle(RenaissanceColors.sageGreen)
                            }
                            .padding(.horizontal, 6)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(RenaissanceColors.goldSuccess.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .strokeBorder(RenaissanceColors.goldSuccess.opacity(0.4), lineWidth: 1)
                                    )
                            )
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(RenaissanceColors.parchment.opacity(0.92))
        )
    }

    // MARK: - Scene Setup

    private func makeScene() -> ForestScene {
        if let existing = scene { return existing }

        let newScene = ForestScene()
        newScene.size = CGSize(width: 3500, height: 2500)
        newScene.scaleMode = .aspectFill
        newScene.apprenticeIsBoy = onboardingState?.apprenticeGender == .boy || onboardingState == nil

        newScene.onPlayerPositionChanged = { position, isWalking in
            playerPosition = position
            playerIsWalking = isWalking
        }

        newScene.onBackRequested = {
            onBackToWorkshop?()
        }

        newScene.onPOISelected = { index in
            withAnimation(.easeOut(duration: 0.25)) {
                selectedPOIIndex = index
            }
        }

        newScene.onTruffleFound = { truffle in
            pendingTruffle = truffle
        }

        DispatchQueue.main.async {
            scene = newScene
        }

        return newScene
    }

    // MARK: - Gestures

    private var pinchGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                scene?.handlePinch(scale: value)
            }
    }
}

#Preview {
    ForestMapView(workshop: WorkshopState(), returnToLessonPlotId: .constant(nil))
}
