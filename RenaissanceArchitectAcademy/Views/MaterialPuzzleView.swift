import SwiftUI
import Pow

/// Grid position helper
struct GridPosition: Equatable, Hashable {
    let row: Int
    let col: Int

    /// Check if two positions are adjacent (up/down/left/right)
    func isAdjacent(to other: GridPosition) -> Bool {
        let rowDiff = abs(row - other.row)
        let colDiff = abs(col - other.col)
        // Adjacent means exactly 1 step in one direction, 0 in the other
        return (rowDiff == 1 && colDiff == 0) || (rowDiff == 0 && colDiff == 1)
    }
}

/// Element tile for the puzzle grid
struct ElementTile: Identifiable, Equatable {
    let id = UUID()
    let symbol: String
    let color: Color
    var isMatched = false

    static func == (lhs: ElementTile, rhs: ElementTile) -> Bool {
        lhs.id == rhs.id
    }
}

/// Material formula to solve
struct MaterialFormula {
    let name: String           // "Lime Mortar"
    let reactants: String      // "CaO + H₂O"
    let product: String        // "Ca(OH)₂" (hidden until solved)
    let requiredElements: [String: Int]  // ["Ca": 1, "O": 2, "H": 2] - actual atom counts!
    let description: String

    // All element symbols needed (for grid generation)
    var elements: [String] {
        Array(requiredElements.keys)
    }

    // CaO + H₂O → Ca(OH)₂ (x3 for building materials)
    // Ca: 3, O: 6, H: 6
    static let limeMortar = MaterialFormula(
        name: "Lime Mortar",
        reactants: "3(CaO + H₂O)",
        product: "3Ca(OH)₂",
        requiredElements: ["Ca": 3, "O": 6, "H": 6],
        description: "Gather enough calcium hydroxide for mortar!"
    )

    // Roman concrete needs lots of materials
    // Ca: 3, Si: 3, Al: 3, O: 6
    static let concrete = MaterialFormula(
        name: "Roman Concrete",
        reactants: "Ca(OH)₂ + SiO₂ + Al₂O₃",
        product: "Calcium Alumino-Silicate",
        requiredElements: ["Ca": 3, "Si": 3, "Al": 3, "O": 6],
        description: "The secret of Roman engineering!"
    )

    // SiO₂ + Na₂O → sodium silicate glass (x2 for window)
    // Si: 4, O: 6, Na: 4
    static let glass = MaterialFormula(
        name: "Venetian Glass",
        reactants: "2(SiO₂ + Na₂O)",
        product: "Glass Pane",
        requiredElements: ["Si": 4, "O": 6, "Na": 4],
        description: "Create beautiful Murano glass!"
    )
}

/// Drag and combine puzzle game for collecting building materials
struct MaterialPuzzleView: View {
    let buildingName: String
    let formula: MaterialFormula
    let onComplete: () -> Void
    let onDismiss: () -> Void

    @State private var grid: [[ElementTile]] = []
    @State private var collectedElements: [String: Int] = [:]
    @State private var showSuccess = false
    @State private var showHint = false
    @State private var revealedProduct = false
    @State private var isAnimating = false  // Prevent interactions during animations

    // Drag state
    @State private var draggingPosition: GridPosition? = nil
    @State private var dragOffset: CGSize = .zero

    // Pow effect trigger
    @State private var matchEffectTrigger: Int = 0
    @State private var matchedPositions: Set<GridPosition> = []
    @State private var showReshuffleMessage = false

    // Mascot entrance animation
    @State private var mascotOffset: CGFloat = -300  // Start far off-screen left
    @State private var mascotBounce: CGFloat = 0
    @State private var mascotWalkCycle: CGFloat = 0  // For walking bounce
    @State private var mascotLean: Double = 0  // Lean left/right while walking
    @State private var isWalking: Bool = true  // Show walking legs

    private let gridSize = 5  // Bigger grid = harder
    private let tileSize: CGFloat = 58  // Slightly smaller tiles
    private let tileSpacing: CGFloat = 8  // Spacing for drag

    // Distractor elements (make puzzle harder)
    private let distractorElements = ["Fe", "C", "Mg", "S"]

    // Elements with their colors
    private var elementColors: [String: Color] {
        [
            // Needed elements
            "Ca": RenaissanceColors.ochre,
            "O": RenaissanceColors.renaissanceBlue,
            "H": RenaissanceColors.sageGreen,
            "Si": RenaissanceColors.stoneGray,
            "Na": RenaissanceColors.terracotta,
            "Al": RenaissanceColors.warmBrown,
            // Distractor elements
            "Fe": RenaissanceColors.errorRed,
            "C": RenaissanceColors.sepiaInk,
            "Mg": RenaissanceColors.deepTeal,
            "S": Color.yellow.opacity(0.8)
        ]
    }

    var body: some View {
        ZStack {
            // Background
            RenaissanceColors.parchmentGradient
                .ignoresSafeArea()

            HStack(spacing: 0) {
                // Mascot characters on the left side
                VStack {
                    Spacer()
                    puzzleMascotView
                        .offset(x: mascotOffset + 60, y: mascotBounce)  // +60 to end more right
                        .rotationEffect(.degrees(mascotLean))  // Lean while walking
                    Spacer()
                }
                .frame(width: 160)  // Wider area for mascot

                // Main puzzle content
                VStack(spacing: 16) {
                    // Header
                    header

                    // Formula card (answer hidden)
                    formulaCard

                    // Element collection progress
                    elementProgressView

                    // Puzzle grid
                    puzzleGrid

                    // Hint button
                    hintButton

                    Spacer()

                    // Cancel button
                    Button("Return to City") {
                        onDismiss()
                    }
                    .font(.custom("EBGaramond-Italic", size: 16))
                    .foregroundColor(RenaissanceColors.stoneGray)
                    .padding(.bottom, 20)
                }
                .padding()
            }

            // Success overlay
            if showSuccess {
                successOverlay
            }

            // Reshuffle message
            if showReshuffleMessage {
                VStack {
                    Spacer()
                    HStack {
                        Image(systemName: "shuffle")
                        Text("No moves! Reshuffling...")
                    }
                    .font(.custom("EBGaramond-Regular", size: 18))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(RenaissanceColors.warmBrown)
                            .shadow(radius: 5)
                    )
                    .padding(.bottom, 100)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .onAppear {
            setupGame()
            // Mascot walks in with stepping animation
            animateMascotWalkIn()
        }
    }

    // MARK: - Mascot in Puzzle View

    private var puzzleMascotView: some View {
        VStack(spacing: -15) {
            // Bird flying above
            BirdCharacter()
                .frame(width: 50, height: 50)
                .offset(x: 20, y: -10)

            // Splash character with walking legs
            WalkingSplashCharacter(isWalking: isWalking, walkCycle: mascotWalkCycle)
                .frame(width: 100, height: 140)
        }
        .scaleEffect(0.85)
        .offset(y: mascotWalkCycle)  // Walking bounce
    }

    /// Animate mascot walking in from left with bouncy steps
    private func animateMascotWalkIn() {
        isWalking = true

        // Walking steps - bounce up and down while moving right
        let stepDuration = 0.12
        let totalSteps = 12  // More steps for longer walk

        for step in 0..<totalSteps {
            let delay = Double(step) * stepDuration

            // Move right
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeOut(duration: stepDuration)) {
                    mascotOffset = -300 + (CGFloat(step + 1) * (300 / CGFloat(totalSteps)))
                }
            }

            // Bounce up on odd steps, down on even
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeInOut(duration: stepDuration)) {
                    mascotWalkCycle = step % 2 == 0 ? -12 : 0
                }
            }

            // Lean left/right alternating (like shifting weight)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeInOut(duration: stepDuration)) {
                    mascotLean = step % 2 == 0 ? -8 : 8
                }
            }
        }

        // Finish walking, start idle bounce
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(totalSteps) * stepDuration + 0.1) {
            withAnimation(.spring(response: 0.3)) {
                mascotOffset = 0
                mascotWalkCycle = 0
                mascotLean = 0
                isWalking = false
            }
            startMascotBounce()
        }
    }

    private func startMascotBounce() {
        // Gentle idle bounce
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            mascotBounce = -8
        }
    }

    /// Make mascot react to successful match
    private func mascotCelebrate() {
        // Quick jump
        withAnimation(.spring(response: 0.2, dampingFraction: 0.4)) {
            mascotBounce = -30
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                mascotBounce = 0
            }
            // Resume idle bounce
            startMascotBounce()
        }
    }

    // MARK: - Views

    private var header: some View {
        VStack(spacing: 4) {
            Text("Gather Materials")
                .font(.custom("Cinzel-Bold", size: 26))
                .foregroundColor(RenaissanceColors.sepiaInk)

            Text("for the \(buildingName)")
                .font(.custom("EBGaramond-Italic", size: 17))
                .foregroundColor(RenaissanceColors.warmBrown)
        }
    }

    private var formulaCard: some View {
        VStack(spacing: 10) {
            Text(formula.name)
                .font(.custom("Cinzel-Regular", size: 18))
                .foregroundColor(RenaissanceColors.sepiaInk)

            // Show formula with hidden answer until solved
            HStack(spacing: 8) {
                Text(formula.reactants)
                    .font(.custom("EBGaramond-Regular", size: 22))
                    .foregroundColor(RenaissanceColors.renaissanceBlue)

                Text("→")
                    .font(.title2)
                    .foregroundColor(RenaissanceColors.sepiaInk)

                // Hidden answer
                Text(revealedProduct ? formula.product : "???")
                    .font(.custom("EBGaramond-Regular", size: 22))
                    .foregroundColor(revealedProduct ? RenaissanceColors.sageGreen : RenaissanceColors.stoneGray)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(revealedProduct ? RenaissanceColors.sageGreen.opacity(0.2) : RenaissanceColors.stoneGray.opacity(0.2))
                    )
            }

            Text(formula.description)
                .font(.custom("EBGaramond-Italic", size: 14))
                .foregroundColor(RenaissanceColors.stoneGray)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(RenaissanceColors.parchment)
                .shadow(color: .black.opacity(0.1), radius: 5, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(RenaissanceColors.ochre.opacity(0.3), lineWidth: 1)
        )
    }

    private var elementProgressView: some View {
        VStack(spacing: 8) {
            Text("Discovered Elements:")
                .font(.custom("EBGaramond-Regular", size: 15))
                .foregroundColor(RenaissanceColors.sepiaInk)

            HStack(spacing: 16) {
                // Show discovered elements (ones that have been collected)
                let discoveredElements = formula.elements.filter { (collectedElements[$0] ?? 0) > 0 }

                if discoveredElements.isEmpty {
                    // Nothing discovered yet - show mystery
                    ForEach(0..<3, id: \.self) { _ in
                        ZStack {
                            Circle()
                                .fill(RenaissanceColors.stoneGray.opacity(0.3))
                                .frame(width: 45, height: 45)
                            Text("?")
                                .font(.custom("Cinzel-Bold", size: 20))
                                .foregroundColor(RenaissanceColors.stoneGray)
                        }
                    }
                } else {
                    ForEach(discoveredElements, id: \.self) { element in
                        let collected = collectedElements[element] ?? 0
                        let required = formula.requiredElements[element] ?? 1
                        let isComplete = collected >= required

                        VStack(spacing: 4) {
                            ZStack {
                                Circle()
                                    .fill(elementColors[element]?.opacity(isComplete ? 1 : 0.6) ?? RenaissanceColors.stoneGray)
                                    .frame(width: 45, height: 45)

                                if isComplete {
                                    Image(systemName: "checkmark")
                                        .font(.title3.bold())
                                        .foregroundColor(.white)
                                } else {
                                    Text(element)
                                        .font(.custom("Cinzel-Bold", size: 16))
                                        .foregroundColor(.white)
                                }
                            }

                            Text("\(min(collected, required))/\(required)")
                                .font(.custom("EBGaramond-Regular", size: 13))
                                .foregroundColor(isComplete ? RenaissanceColors.sageGreen : RenaissanceColors.stoneGray)
                        }
                    }

                    // Show remaining mystery slots
                    let remaining = formula.elements.count - discoveredElements.count
                    if remaining > 0 {
                        ForEach(0..<remaining, id: \.self) { _ in
                            ZStack {
                                Circle()
                                    .fill(RenaissanceColors.stoneGray.opacity(0.3))
                                    .frame(width: 45, height: 45)
                                Text("?")
                                    .font(.custom("Cinzel-Bold", size: 20))
                                    .foregroundColor(RenaissanceColors.stoneGray)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(RenaissanceColors.parchment.opacity(0.8))
        )
    }

    private var puzzleGrid: some View {
        VStack(spacing: tileSpacing) {
            ForEach(0..<gridSize, id: \.self) { row in
                HStack(spacing: tileSpacing) {
                    ForEach(0..<gridSize, id: \.self) { col in
                        if row < grid.count && col < grid[row].count {
                            let tile = grid[row][col]
                            let position = GridPosition(row: row, col: col)
                            let isDragging = draggingPosition == position
                            let isNeeded = formula.elements.contains(tile.symbol)
                            let isMatching = matchedPositions.contains(position)

                            TileView(
                                tile: tile,
                                size: tileSize,
                                isNeeded: isNeeded,
                                isHighlighted: isDragging,
                                isValidTarget: false
                            )
                            .zIndex(isDragging ? 100 : 0)
                            .offset(isDragging ? dragOffset : .zero)
                            // Pow explosion effect when matched!
                            .changeEffect(
                                .spray(origin: UnitPoint(x: 0.5, y: 0.5)) {
                                    Group {
                                        Image(systemName: "sparkle")
                                            .foregroundStyle(tile.color)
                                        Image(systemName: "star.fill")
                                            .foregroundStyle(.yellow)
                                        Text(tile.symbol)
                                            .font(.caption.bold())
                                            .foregroundStyle(tile.color)
                                    }
                                },
                                value: isMatching ? matchEffectTrigger : 0
                            )
                            // Scale down and fade when matched
                            .scaleEffect(tile.isMatched ? 0.01 : 1)
                            .opacity(tile.isMatched ? 0 : 1)
                            // Fall animation with transition
                            .transition(.asymmetric(
                                insertion: .move(edge: .top).combined(with: .opacity),
                                removal: .scale.combined(with: .opacity)
                            ))
                            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: tile.id)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        if !isAnimating && !tile.isMatched {
                                            draggingPosition = position
                                            dragOffset = value.translation
                                        }
                                    }
                                    .onEnded { value in
                                        if !isAnimating {
                                            handleDragEnd(from: position, translation: value.translation)
                                        }
                                    }
                            )
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(RenaissanceColors.sepiaInk.opacity(0.08))
        )
    }

    private var hintButton: some View {
        Button(action: { showHint.toggle() }) {
            HStack {
                Image(systemName: "lightbulb")
                Text(showHint ? "Drag tiles to swap them - line up 3 in a row!" : "Need a hint?")
            }
            .font(.custom("EBGaramond-Italic", size: 14))
            .foregroundColor(RenaissanceColors.warmBrown)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(RenaissanceColors.ochre.opacity(0.2))
            )
        }
    }

    private var successOverlay: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 70))
                    .foregroundColor(RenaissanceColors.goldSuccess)

                Text("Formula Complete!")
                    .font(.custom("Cinzel-Bold", size: 26))
                    .foregroundColor(.white)

                Text("\(formula.reactants) → \(formula.product)")
                    .font(.custom("EBGaramond-Regular", size: 20))
                    .foregroundColor(RenaissanceColors.sageGreen)

                Text("You created \(formula.name)!")
                    .font(.custom("EBGaramond-Italic", size: 17))
                    .foregroundColor(.white.opacity(0.9))

                RenaissanceButton(title: "Continue Building") {
                    onComplete()
                }
                .padding(.top, 10)
            }
            .padding(36)
        }
        .transition(.opacity)
    }

    // MARK: - Game Logic

    private func setupGame() {
        // Initialize collected elements
        for element in formula.elements {
            collectedElements[element] = 0
        }

        // Create grid with needed elements + distractors
        var tiles: [ElementTile] = []

        // Add tiles for needed elements (enough for matches)
        for (element, required) in formula.requiredElements {
            let tileCount = max(4, required * 3)  // Need enough for multiple matches
            for _ in 0..<tileCount {
                let color = elementColors[element] ?? RenaissanceColors.stoneGray
                tiles.append(ElementTile(symbol: element, color: color))
            }
        }

        // Add distractor elements (make it harder!)
        let distractorCount = gridSize * gridSize / 3  // About 1/3 distractors
        for _ in 0..<distractorCount {
            let element = distractorElements.randomElement() ?? "Fe"
            let color = elementColors[element] ?? RenaissanceColors.stoneGray
            tiles.append(ElementTile(symbol: element, color: color))
        }

        // Fill rest with mix of needed and distractors
        while tiles.count < gridSize * gridSize {
            let useDistractor = Bool.random()
            let element: String
            if useDistractor {
                element = distractorElements.randomElement() ?? "Fe"
            } else {
                element = formula.elements.randomElement() ?? "Ca"
            }
            let color = elementColors[element] ?? RenaissanceColors.stoneGray
            tiles.append(ElementTile(symbol: element, color: color))
        }

        // Trim if we have too many
        if tiles.count > gridSize * gridSize {
            tiles = Array(tiles.shuffled().prefix(gridSize * gridSize))
        }

        // Shuffle until no initial matches BUT has valid moves
        var attempts = 0
        repeat {
            tiles.shuffle()
            grid = stride(from: 0, to: tiles.count, by: gridSize).map {
                Array(tiles[$0..<min($0 + gridSize, tiles.count)])
            }
            attempts += 1
        } while (!findAllMatches().isEmpty || !hasValidMoves()) && attempts < 100

        // Safety: if we couldn't find a good configuration, force a valid move
        if !hasValidMoves() {
            forceValidMove()
        }
    }

    /// Handle drag end - determine which direction user dragged and swap tiles
    private func handleDragEnd(from: GridPosition, translation: CGSize) {
        // Reset drag state
        withAnimation(.spring(response: 0.2)) {
            dragOffset = .zero
            draggingPosition = nil
        }

        // Determine drag direction (need to drag at least half a tile)
        let threshold: CGFloat = tileSize / 2

        var targetPosition: GridPosition?

        if abs(translation.width) > abs(translation.height) {
            // Horizontal drag
            if translation.width > threshold && from.col < gridSize - 1 {
                targetPosition = GridPosition(row: from.row, col: from.col + 1)  // Right
            } else if translation.width < -threshold && from.col > 0 {
                targetPosition = GridPosition(row: from.row, col: from.col - 1)  // Left
            }
        } else {
            // Vertical drag
            if translation.height > threshold && from.row < gridSize - 1 {
                targetPosition = GridPosition(row: from.row + 1, col: from.col)  // Down
            } else if translation.height < -threshold && from.row > 0 {
                targetPosition = GridPosition(row: from.row - 1, col: from.col)  // Up
            }
        }

        // If we have a valid target, swap tiles
        if let target = targetPosition {
            swapTiles(from: from, to: target)
        }
    }

    private func swapTiles(from: GridPosition, to: GridPosition) {
        isAnimating = true

        // Perform the swap with animation
        withAnimation(.spring(response: 0.3)) {
            let temp = grid[from.row][from.col]
            grid[from.row][from.col] = grid[to.row][to.col]
            grid[to.row][to.col] = temp
        }

        // Check for matches after swap
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            let matches = self.findAllMatches()

            if matches.isEmpty {
                // No matches - swap back!
                withAnimation(.spring(response: 0.3)) {
                    let temp = self.grid[from.row][from.col]
                    self.grid[from.row][from.col] = self.grid[to.row][to.col]
                    self.grid[to.row][to.col] = temp
                }
                self.isAnimating = false
            } else {
                // Found matches - collect them!
                self.collectMatches(matches)
            }
        }
    }

    /// Find all matching rows and columns (3+ in a line)
    private func findAllMatches() -> Set<GridPosition> {
        var matches = Set<GridPosition>()

        // Check horizontal matches
        for row in 0..<gridSize {
            var col = 0
            while col < gridSize - 2 {
                let symbol = grid[row][col].symbol
                var matchLength = 1

                while col + matchLength < gridSize && grid[row][col + matchLength].symbol == symbol {
                    matchLength += 1
                }

                if matchLength >= 3 {
                    for i in 0..<matchLength {
                        matches.insert(GridPosition(row: row, col: col + i))
                    }
                }
                col += max(1, matchLength)
            }
        }

        // Check vertical matches
        for col in 0..<gridSize {
            var row = 0
            while row < gridSize - 2 {
                let symbol = grid[row][col].symbol
                var matchLength = 1

                while row + matchLength < gridSize && grid[row + matchLength][col].symbol == symbol {
                    matchLength += 1
                }

                if matchLength >= 3 {
                    for i in 0..<matchLength {
                        matches.insert(GridPosition(row: row + i, col: col))
                    }
                }
                row += max(1, matchLength)
            }
        }

        return matches
    }

    /// Collect matched tiles and replace them
    private func collectMatches(_ matches: Set<GridPosition>) {
        // Count elements collected
        var elementCounts: [String: Int] = [:]
        for pos in matches {
            let symbol = grid[pos.row][pos.col].symbol
            elementCounts[symbol, default: 0] += 1
        }

        // Add to collected (only needed elements)
        for (element, count) in elementCounts {
            if formula.elements.contains(element) {
                collectedElements[element, default: 0] += count
            }
        }

        // Trigger Pow explosion effect!
        matchedPositions = matches
        matchEffectTrigger += 1

        // Mascot celebrates!
        mascotCelebrate()

        // Mark as matched with animation (after a tiny delay for Pow to show)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.spring(response: 0.3)) {
                for pos in matches {
                    self.grid[pos.row][pos.col].isMatched = true
                }
            }
        }

        // Replace matched tiles after delay (let explosion finish)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Clear matched positions
            self.matchedPositions = []

            self.replaceMatchedTiles()

            // Check for chain reactions (new matches after tiles fall)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                let newMatches = self.findAllMatches()
                if !newMatches.isEmpty {
                    self.collectMatches(newMatches)
                } else {
                    // Check if there are valid moves, reshuffle if stuck
                    if !self.hasValidMoves() {
                        self.reshuffleGrid()
                    }
                    self.isAnimating = false
                    self.checkWinCondition()
                }
            }
        }
    }

    /// Check if any valid move exists (swap that creates a match)
    private func hasValidMoves() -> Bool {
        // Try every possible swap and see if it creates a match
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                // Try swap right
                if col < gridSize - 1 {
                    if wouldCreateMatch(swapping: GridPosition(row: row, col: col),
                                       with: GridPosition(row: row, col: col + 1)) {
                        return true
                    }
                }
                // Try swap down
                if row < gridSize - 1 {
                    if wouldCreateMatch(swapping: GridPosition(row: row, col: col),
                                       with: GridPosition(row: row + 1, col: col)) {
                        return true
                    }
                }
            }
        }
        return false
    }

    /// Check if swapping two positions would create a match
    private func wouldCreateMatch(swapping pos1: GridPosition, with pos2: GridPosition) -> Bool {
        // Temporarily swap
        var tempGrid = grid
        let temp = tempGrid[pos1.row][pos1.col]
        tempGrid[pos1.row][pos1.col] = tempGrid[pos2.row][pos2.col]
        tempGrid[pos2.row][pos2.col] = temp

        // Check for matches at both positions
        return checkMatchAt(pos1, in: tempGrid) || checkMatchAt(pos2, in: tempGrid)
    }

    /// Check if there's a match at a specific position in a grid
    private func checkMatchAt(_ pos: GridPosition, in checkGrid: [[ElementTile]]) -> Bool {
        let symbol = checkGrid[pos.row][pos.col].symbol

        // Check horizontal
        var hCount = 1
        // Left
        var c = pos.col - 1
        while c >= 0 && checkGrid[pos.row][c].symbol == symbol {
            hCount += 1
            c -= 1
        }
        // Right
        c = pos.col + 1
        while c < gridSize && checkGrid[pos.row][c].symbol == symbol {
            hCount += 1
            c += 1
        }
        if hCount >= 3 { return true }

        // Check vertical
        var vCount = 1
        // Up
        var r = pos.row - 1
        while r >= 0 && checkGrid[r][pos.col].symbol == symbol {
            vCount += 1
            r -= 1
        }
        // Down
        r = pos.row + 1
        while r < gridSize && checkGrid[r][pos.col].symbol == symbol {
            vCount += 1
            r += 1
        }
        if vCount >= 3 { return true }

        return false
    }

    /// Reshuffle the grid when no valid moves exist
    private func reshuffleGrid() {
        // Show reshuffle message
        withAnimation {
            showReshuffleMessage = true
        }

        // Collect all current tiles
        var allTiles: [ElementTile] = []
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                // Create new tile with same symbol (reset matched state)
                let tile = grid[row][col]
                let color = elementColors[tile.symbol] ?? RenaissanceColors.stoneGray
                allTiles.append(ElementTile(symbol: tile.symbol, color: color))
            }
        }

        // Shuffle until we have valid moves but no immediate matches
        var attempts = 0
        repeat {
            allTiles.shuffle()
            grid = stride(from: 0, to: allTiles.count, by: gridSize).map {
                Array(allTiles[$0..<min($0 + gridSize, allTiles.count)])
            }
            attempts += 1
        } while (findAllMatches().isEmpty == false || !hasValidMoves()) && attempts < 100

        // If still stuck after 100 attempts, add some matching tiles
        if !hasValidMoves() {
            forceValidMove()
        }

        // Hide message after a moment
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                self.showReshuffleMessage = false
            }
        }
    }

    /// Force at least one valid move by placing matching tiles
    private func forceValidMove() {
        // Pick a random position and create a match opportunity
        let row = Int.random(in: 0..<gridSize-2)
        let col = Int.random(in: 0..<gridSize)
        let element = formula.elements.randomElement() ?? "Ca"
        let color = elementColors[element] ?? RenaissanceColors.stoneGray

        // Place two of the same element vertically, with third nearby
        grid[row][col] = ElementTile(symbol: element, color: color)
        grid[row+1][col] = ElementTile(symbol: element, color: color)
        // Put the third one adjacent so a swap creates a match
        if col > 0 {
            grid[row+2][col-1] = ElementTile(symbol: element, color: color)
        } else {
            grid[row+2][col+1] = ElementTile(symbol: element, color: color)
        }
    }

    /// Apply gravity - tiles fall down, new tiles spawn from top
    private func replaceMatchedTiles() {
        withAnimation(.spring(response: 0.4)) {
            // Process each column separately
            for col in 0..<gridSize {
                // Collect non-matched tiles in this column (from bottom to top)
                var remainingTiles: [ElementTile] = []
                for row in (0..<gridSize).reversed() {
                    if !grid[row][col].isMatched {
                        remainingTiles.append(grid[row][col])
                    }
                }

                // Calculate how many new tiles we need
                let newTilesNeeded = gridSize - remainingTiles.count

                // Create new tiles for the top
                var newTiles: [ElementTile] = []
                for _ in 0..<newTilesNeeded {
                    let element = randomElement()
                    let color = elementColors[element] ?? RenaissanceColors.stoneGray
                    newTiles.append(ElementTile(symbol: element, color: color))
                }

                // Fill column: new tiles at top, remaining tiles fall to bottom
                // Row 0 is top, row (gridSize-1) is bottom
                for row in 0..<gridSize {
                    if row < newTilesNeeded {
                        // Top rows get new tiles
                        grid[row][col] = newTiles[row]
                    } else {
                        // Bottom rows get remaining tiles (reversed back to correct order)
                        let remainingIndex = remainingTiles.count - 1 - (row - newTilesNeeded)
                        if remainingIndex >= 0 && remainingIndex < remainingTiles.count {
                            grid[row][col] = remainingTiles[remainingIndex]
                        }
                    }
                }
            }
        }
    }

    /// Get a random element (mix of needed and distractors)
    private func randomElement() -> String {
        // 60% chance of needed element, 40% distractor
        if Double.random(in: 0...1) < 0.6 {
            return formula.elements.randomElement() ?? "Ca"
        } else {
            return distractorElements.randomElement() ?? "Fe"
        }
    }

    private func checkWinCondition() {
        // Check if we have enough of each needed element (based on formula)
        var allCollected = true
        for (element, required) in formula.requiredElements {
            if (collectedElements[element] ?? 0) < required {
                allCollected = false
                break
            }
        }

        if allCollected {
            withAnimation {
                revealedProduct = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    showSuccess = true
                }
            }
        }
    }
}

/// Individual tile view
struct TileView: View {
    let tile: ElementTile
    let size: CGFloat
    let isNeeded: Bool
    var isHighlighted: Bool = false
    var isValidTarget: Bool = false  // Show as valid swap destination

    var body: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 10)
                .fill(tile.color)
                .frame(width: size, height: size)
                .shadow(color: .black.opacity(0.15), radius: 2, y: 1)

            // Golden border if needed element
            if isNeeded && !tile.isMatched {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(RenaissanceColors.goldSuccess, lineWidth: 2)
                    .frame(width: size, height: size)
            }

            // Selection highlight (selected tile)
            if isHighlighted {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.white, lineWidth: 3)
                    .frame(width: size, height: size)

                RoundedRectangle(cornerRadius: 10)
                    .fill(.white.opacity(0.3))
                    .frame(width: size, height: size)
            }

            // Valid swap target highlight (pulsing border)
            if isValidTarget {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(RenaissanceColors.highlightAmber, lineWidth: 2)
                    .frame(width: size, height: size)
            }

            // Element symbol
            Text(tile.symbol)
                .font(.custom("Cinzel-Bold", size: size * 0.38))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 1, y: 1)
        }
        .opacity(tile.isMatched ? 0.3 : 1)
        .scaleEffect(tile.isMatched ? 0.8 : (isHighlighted ? 1.1 : 1))
        .animation(.spring(response: 0.25), value: tile.isMatched)
        .animation(.spring(response: 0.2), value: isHighlighted)
    }
}

// MARK: - Walking Splash Character

/// Splash character with animated walking legs
struct WalkingSplashCharacter: View {
    let isWalking: Bool
    let walkCycle: CGFloat

    @State private var leftLegOffset: CGFloat = 0
    @State private var rightLegOffset: CGFloat = 0

    var body: some View {
        ZStack {
            // Ink drip "legs" at bottom - animate when walking
            HStack(spacing: 25) {
                // Left leg
                Capsule()
                    .fill(RenaissanceColors.warmBrown.opacity(0.8))
                    .frame(width: 12, height: 30)
                    .offset(y: isWalking ? leftLegOffset : 0)

                // Right leg
                Capsule()
                    .fill(RenaissanceColors.warmBrown.opacity(0.8))
                    .frame(width: 12, height: 30)
                    .offset(y: isWalking ? rightLegOffset : 0)
            }
            .offset(y: 50)

            // Main body - watercolor splash shape
            SplashBody()
        }
        .onChange(of: walkCycle) { _, newValue in
            // Alternate legs based on walk cycle
            withAnimation(.easeInOut(duration: 0.1)) {
                if newValue < -5 {
                    leftLegOffset = -15
                    rightLegOffset = 10
                } else {
                    leftLegOffset = 10
                    rightLegOffset = -15
                }
            }
        }
        .onAppear {
            if !isWalking {
                leftLegOffset = 0
                rightLegOffset = 0
            }
        }
    }
}

/// Just the Splash body without the drips (used by WalkingSplashCharacter)
struct SplashBody: View {
    @State private var wiggle = false

    var body: some View {
        ZStack {
            // Body - watercolor splash shape
            WatercolorSplash()
                .fill(
                    LinearGradient(
                        colors: [
                            RenaissanceColors.ochre,
                            RenaissanceColors.warmBrown,
                            RenaissanceColors.terracotta.opacity(0.8)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 90, height: 100)
                .rotationEffect(.degrees(wiggle ? 2 : -2))

            // Face
            VStack(spacing: 8) {
                // Eyes
                HStack(spacing: 20) {
                    Circle()
                        .fill(.white)
                        .frame(width: 16, height: 16)
                        .overlay(
                            Circle()
                                .fill(RenaissanceColors.sepiaInk)
                                .frame(width: 8, height: 8)
                                .offset(y: 2)
                        )

                    Circle()
                        .fill(.white)
                        .frame(width: 16, height: 16)
                        .overlay(
                            Circle()
                                .fill(RenaissanceColors.sepiaInk)
                                .frame(width: 8, height: 8)
                                .offset(y: 2)
                        )
                }

                // Smile
                SplashSmile()
                    .stroke(RenaissanceColors.sepiaInk, lineWidth: 3)
                    .frame(width: 25, height: 12)
            }
            .offset(y: -10)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                wiggle = true
            }
        }
    }
}

/// Simple smile shape
struct SplashSmile: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addQuadCurve(
            to: CGPoint(x: rect.width, y: 0),
            control: CGPoint(x: rect.width / 2, y: rect.height)
        )
        return path
    }
}

// MARK: - Preview

#Preview {
    MaterialPuzzleView(
        buildingName: "Pantheon",
        formula: .limeMortar,
        onComplete: {},
        onDismiss: {}
    )
}
