import SwiftUI

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
    let elements: [String]     // ["Ca", "O", "H"]
    let description: String

    // Show formula with hidden answer
    var displayFormula: String {
        "\(reactants) → ?"
    }

    static let limeMortar = MaterialFormula(
        name: "Lime Mortar",
        reactants: "CaO + H₂O",
        product: "Ca(OH)₂",
        elements: ["Ca", "O", "H"],
        description: "Combine the elements to create mortar!"
    )

    static let concrete = MaterialFormula(
        name: "Roman Concrete",
        reactants: "Ca(OH)₂ + SiO₂ + Al₂O₃",
        product: "Calcium Alumino-Silicate",
        elements: ["Ca", "Si", "Al", "O"],
        description: "The secret of Roman engineering!"
    )

    static let glass = MaterialFormula(
        name: "Venetian Glass",
        reactants: "SiO₂ + Na₂O",
        product: "Glass",
        elements: ["Si", "O", "Na"],
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

    private let gridSize = 4  // Smaller grid = more space
    private let tileSize: CGFloat = 70  // Bigger tiles
    private let tileSpacing: CGFloat = 12  // More spacing

    // Elements with their colors
    private var elementColors: [String: Color] {
        [
            "Ca": RenaissanceColors.ochre,
            "O": RenaissanceColors.renaissanceBlue,
            "H": RenaissanceColors.sageGreen,
            "Si": RenaissanceColors.stoneGray,
            "Na": RenaissanceColors.terracotta,
            "Al": RenaissanceColors.warmBrown,
            "Fe": RenaissanceColors.errorRed,
            "C": RenaissanceColors.sepiaInk
        ]
    }

    var body: some View {
        ZStack {
            // Background
            RenaissanceColors.parchmentGradient
                .ignoresSafeArea()

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

            // Success overlay
            if showSuccess {
                successOverlay
            }
        }
        .onAppear {
            setupGame()
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
            Text("Collect 3 of each element:")
                .font(.custom("EBGaramond-Regular", size: 15))
                .foregroundColor(RenaissanceColors.sepiaInk)

            HStack(spacing: 16) {
                ForEach(formula.elements, id: \.self) { element in
                    let collected = collectedElements[element] ?? 0
                    let isComplete = collected >= 3

                    VStack(spacing: 4) {
                        ZStack {
                            Circle()
                                .fill(elementColors[element]?.opacity(isComplete ? 1 : 0.3) ?? RenaissanceColors.stoneGray)
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

                        Text("\(min(collected, 3))/3")
                            .font(.custom("EBGaramond-Regular", size: 13))
                            .foregroundColor(isComplete ? RenaissanceColors.sageGreen : RenaissanceColors.stoneGray)
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

                            TileView(
                                tile: tile,
                                size: tileSize,
                                isNeeded: isNeeded,
                                isHighlighted: isDragging,
                                isValidTarget: false
                            )
                            .zIndex(isDragging ? 100 : 0)
                            .offset(isDragging ? dragOffset : .zero)
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

        // Create grid with guaranteed needed elements
        var tiles: [ElementTile] = []

        // Add enough of each needed element (4 of each for 4x4 grid)
        for element in formula.elements {
            for _ in 0..<4 {
                let color = elementColors[element] ?? RenaissanceColors.stoneGray
                tiles.append(ElementTile(symbol: element, color: color))
            }
        }

        // Fill rest with random elements from needed list (to make matches possible)
        while tiles.count < gridSize * gridSize {
            let element = formula.elements.randomElement() ?? "Ca"
            let color = elementColors[element] ?? RenaissanceColors.stoneGray
            tiles.append(ElementTile(symbol: element, color: color))
        }

        // Shuffle until no initial matches (makes player work for it)
        repeat {
            tiles.shuffle()
            grid = stride(from: 0, to: tiles.count, by: gridSize).map {
                Array(tiles[$0..<min($0 + gridSize, tiles.count)])
            }
        } while !findAllMatches().isEmpty
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

        // Mark as matched with animation
        withAnimation(.spring(response: 0.3)) {
            for pos in matches {
                grid[pos.row][pos.col].isMatched = true
            }
        }

        // Replace matched tiles after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.replaceMatchedTiles()

            // Check for chain reactions (new matches after tiles fall)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                let newMatches = self.findAllMatches()
                if !newMatches.isEmpty {
                    self.collectMatches(newMatches)
                } else {
                    self.isAnimating = false
                    self.checkWinCondition()
                }
            }
        }
    }

    private func replaceMatchedTiles() {
        let allElements = Array(elementColors.keys)

        withAnimation(.spring()) {
            for row in 0..<gridSize {
                for col in 0..<gridSize {
                    if grid[row][col].isMatched {
                        // Prefer spawning needed elements
                        let element: String
                        if Bool.random() && !formula.elements.isEmpty {
                            element = formula.elements.randomElement()!
                        } else {
                            element = allElements.randomElement()!
                        }
                        let color = elementColors[element] ?? RenaissanceColors.stoneGray
                        grid[row][col] = ElementTile(symbol: element, color: color)
                    }
                }
            }
        }
    }

    private func checkWinCondition() {
        // Check if we have 3 of each needed element
        var allCollected = true
        for element in formula.elements {
            if (collectedElements[element] ?? 0) < 3 {
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

// MARK: - Preview

#Preview {
    MaterialPuzzleView(
        buildingName: "Pantheon",
        formula: .limeMortar,
        onComplete: {},
        onDismiss: {}
    )
}
