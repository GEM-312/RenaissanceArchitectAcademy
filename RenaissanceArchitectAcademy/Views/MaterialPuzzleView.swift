import SwiftUI

/// Grid position helper
struct GridPosition: Equatable, Hashable {
    let row: Int
    let col: Int
}

/// Element tile for the puzzle grid
struct ElementTile: Identifiable, Equatable {
    let id = UUID()
    let symbol: String
    let color: Color
    var isMatched = false
    var isSelected = false

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
    @State private var selectedTiles: [GridPosition] = []  // Track selected positions
    @State private var collectedElements: [String: Int] = [:]
    @State private var showSuccess = false
    @State private var showHint = false
    @State private var revealedProduct = false

    private let gridSize = 5
    private let tileSize: CGFloat = 60

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
        VStack(spacing: 6) {
            ForEach(0..<gridSize, id: \.self) { row in
                HStack(spacing: 6) {
                    ForEach(0..<gridSize, id: \.self) { col in
                        if row < grid.count && col < grid[row].count {
                            let tile = grid[row][col]
                            let position = GridPosition(row: row, col: col)
                            let isSelected = selectedTiles.contains(position)
                            let isNeeded = formula.elements.contains(tile.symbol)

                            TileView(
                                tile: tile,
                                size: tileSize,
                                isNeeded: isNeeded,
                                isHighlighted: isSelected
                            )
                            .onTapGesture {
                                tileTapped(row: row, col: col)
                            }
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(RenaissanceColors.sepiaInk.opacity(0.08))
        )
    }

    private var hintButton: some View {
        Button(action: { showHint.toggle() }) {
            HStack {
                Image(systemName: "lightbulb")
                Text(showHint ? "Match 3 tiles of the same element (tap them in sequence)" : "Need a hint?")
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

        // Add enough of each needed element (at least 6 of each to ensure playability)
        for element in formula.elements {
            for _ in 0..<6 {
                let color = elementColors[element] ?? RenaissanceColors.stoneGray
                tiles.append(ElementTile(symbol: element, color: color))
            }
        }

        // Fill rest with random elements
        let allElements = Array(elementColors.keys)
        while tiles.count < gridSize * gridSize {
            let element = allElements.randomElement()!
            let color = elementColors[element] ?? RenaissanceColors.stoneGray
            tiles.append(ElementTile(symbol: element, color: color))
        }

        // Shuffle
        tiles.shuffle()

        // Convert to 2D grid
        grid = stride(from: 0, to: tiles.count, by: gridSize).map {
            Array(tiles[$0..<min($0 + gridSize, tiles.count)])
        }
    }

    private func tileTapped(row: Int, col: Int) {
        let position = GridPosition(row: row, col: col)
        let tile = grid[row][col]

        // If tile already matched, ignore
        if tile.isMatched { return }

        // If already selected, deselect
        if selectedTiles.contains(position) {
            selectedTiles.removeAll { $0 == position }
            grid[row][col].isSelected = false
            return
        }

        // If we have selections, check if same element
        if let firstPos = selectedTiles.first {
            let firstTile = grid[firstPos.row][firstPos.col]
            if firstTile.symbol != tile.symbol {
                // Different element - clear selection and start new
                clearSelections()
            }
        }

        // Add to selection
        selectedTiles.append(position)
        grid[row][col].isSelected = true

        // Check if we have 3 of the same
        if selectedTiles.count >= 3 {
            matchTiles()
        }
    }

    private func clearSelections() {
        for pos in selectedTiles {
            grid[pos.row][pos.col].isSelected = false
        }
        selectedTiles.removeAll()
    }

    private func matchTiles() {
        guard selectedTiles.count >= 3 else { return }

        let firstTile = grid[selectedTiles[0].row][selectedTiles[0].col]
        let element = firstTile.symbol

        // Mark as matched with animation
        withAnimation(.spring(response: 0.3)) {
            for pos in selectedTiles {
                grid[pos.row][pos.col].isMatched = true
            }
        }

        // Add to collected (only if needed element)
        if formula.elements.contains(element) {
            collectedElements[element, default: 0] += selectedTiles.count
        }

        // Clear selection
        selectedTiles.removeAll()

        // Replace matched tiles after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            replaceMatchedTiles()
            checkWinCondition()
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

            // Selection highlight
            if isHighlighted {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.white, lineWidth: 3)
                    .frame(width: size, height: size)

                RoundedRectangle(cornerRadius: 10)
                    .fill(.white.opacity(0.3))
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
