import SwiftUI

/// River "Il Fiume" station — TWO distinct mini-games:
/// • Water → "Le Tubature" — rotate pipe tiles to connect water flow from source to drain
///   Real engineering: Roman aqueducts used gravity-fed pipe networks (lead, terracotta, stone)
/// • Sand  → "Il Setaccio" — tap sand grains in a fixed grid, avoid rocks and shells
///   Real geology: SiO₂ quartz grains sorted by density and grain size in river sediment
struct RiverMiniGameView: View {

    let onComplete: (Material, Int) -> Void
    let onDismiss: () -> Void
    var onNudgeCamera: (() -> Void)? = nil

    // MARK: - Shared Phases

    enum Phase: Equatable {
        case choose
        case introWater
        case introSand
        case playingWater
        case playingSand
        case success
        case failed
    }

    @State private var phase: Phase = .choose
    @State private var selectedMaterial: Material = .water

    // ── Water (pipe puzzle) state ──
    @State private var pipeGrid: [[PipeTile]] = []
    @State private var flowTiles: Set<GridPos> = []
    @State private var isFlowing = false
    @State private var moveCount = 0

    private let gridCols = 5
    private let gridRows = 5

    // ── Sand (grid sifting) state ──
    @State private var sieveItems: [SieveItem] = []
    @State private var sandCollected = 0
    @State private var sieveMisses = 0
    @State private var sieveScore = 0
    @State private var sieveFeedback: String?
    @State private var sieveFeedbackColor: Color = .white

    private let sandNeeded = 8
    private let maxSieveMisses = 3
    private let sieveGridCols = 4
    private let sieveGridRows = 4

    // MARK: - Body

    var body: some View {
        ZStack {
            if phase == .playingWater || phase == .playingSand {
                RenaissanceColors.overlayDimming
                    .ignoresSafeArea()

                if phase == .playingWater {
                    pipeGameView
                        .transition(.opacity)
                } else {
                    sandGameView
                        .transition(.opacity)
                }
            } else {
                Color.clear
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if phase == .choose { onDismiss() }
                    }

                VStack {
                    Spacer()

                    Group {
                        switch phase {
                        case .choose:       materialChoiceCard
                        case .introWater:   introWaterCard
                        case .introSand:    introSandCard
                        case .success:      successCard
                        case .failed:       failedCard
                        default:            EmptyView()
                        }
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.bottom, Spacing.xl)
                }
                .padding(.horizontal, Spacing.md)
            }
        }
        .animation(.spring(response: 0.4), value: phase)
    }

    // MARK: - Phase 1: Material Choice

    private var materialChoiceCard: some View {
        VStack(spacing: Spacing.lg) {
            HStack(spacing: 14) {
                BirdCharacter()
                    .frame(width: 70, height: 70)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Il Fiume")
                        .font(RenaissanceFont.title)
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                    Text("The river gives both water and sand — each requires different skill.")
                        .font(RenaissanceFont.body)
                        .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))
                }
                Spacer()
            }

            VStack(spacing: 12) {
                materialOptionRow(
                    material: .water,
                    difficulty: "Easy",
                    description: "Rotate pipes to channel the flow — Roman hydraulic engineering"
                )
                materialOptionRow(
                    material: .sand,
                    difficulty: "Medium",
                    description: "Sift quartz grains from riverbed debris — SiO₂ geology"
                )
            }

            Button("Back") { onDismiss() }
                .font(RenaissanceFont.body)
                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.5))
        }
        .padding(Spacing.xl)
        .padding(.bottom, 60)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.xl)
                .fill(RenaissanceColors.parchment)
        )
        .borderModal(radius: CornerRadius.xl)
    }

    private func materialOptionRow(material: Material, difficulty: String, description: String) -> some View {
        Button {
            selectedMaterial = material
            withAnimation {
                phase = material == .water ? .introWater : .introSand
            }
        } label: {
            HStack(spacing: 14) {
                Text(material.icon)
                    .font(.title2)
                    .frame(width: 44, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: CornerRadius.sm)
                            .fill(RenaissanceColors.renaissanceBlue.opacity(0.1))
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(material.rawValue)
                        .font(RenaissanceFont.bodySemibold)
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                    Text(description)
                        .font(RenaissanceFont.bodySmall)
                        .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.6))
                        .lineLimit(2)
                }

                Spacer()

                Text(difficulty)
                    .font(RenaissanceFont.bodySemibold)
                    .foregroundStyle(difficulty == "Easy" ? RenaissanceColors.sageGreen : RenaissanceColors.ochre)

                Image(systemName: "chevron.right")
                    .font(.body)
                    .foregroundStyle(RenaissanceColors.sepiaInk)
            }
            .padding(Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(RenaissanceColors.parchment.opacity(0.6))
                    .borderWorkshop(radius: 10)
            )
        }
    }

    // MARK: - Phase 2a: Water Intro

    private var introWaterCard: some View {
        VStack(spacing: 20) {
            HStack(spacing: 12) {
                Image(systemName: "drop.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(RenaissanceColors.renaissanceBlue)
                    .frame(width: 44, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: CornerRadius.sm)
                            .fill(RenaissanceColors.renaissanceBlue.opacity(0.1))
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text("Le Tubature")
                        .font(.custom("Cinzel-Bold", size: 22))
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                    Text("Connect the Water Pipes")
                        .font(RenaissanceFont.dialogSubtitle)
                        .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))
                }
            }

            Text("Connect the pipes to fill your bucket at the drain end. Roman engineers built pipe networks that moved water across entire cities using nothing but gravity. Lead pipes (fistulae), terracotta channels, and stone aqueducts — all connected with precision joints. One misaligned section and the whole system leaked.")
                .font(.custom("EBGaramond-Regular", size: 16))
                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: 10) {
                ruleRow(icon: "arrow.triangle.2.circlepath", text: "Tap pipes to rotate them 90°", color: RenaissanceColors.renaissanceBlue)
                ruleRow(icon: "drop.fill", text: "Connect source (top-left) to drain (bottom-right)", color: RenaissanceColors.sageGreen)
                ruleRow(icon: "star.fill", text: "Fewer moves = bonus florins", color: RenaissanceColors.goldSuccess)
            }

            Button {
                startWaterGame()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "drop.fill")
                        .font(.caption)
                    Text("Begin Plumbing")
                        .font(.custom("EBGaramond-SemiBold", size: 16))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(RenaissanceColors.renaissanceBlue)
                )
            }

            Button("Back") {
                withAnimation { phase = .choose }
            }
            .font(RenaissanceFont.bodySmall)
            .foregroundStyle(RenaissanceColors.sepiaInk)
        }
        .padding(Spacing.xl)
        .adaptiveWidth(400)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.lg)
                .fill(RenaissanceColors.parchment)
        )
        .borderWorkshop()
    }

    // MARK: - Phase 2b: Sand Intro

    private var introSandCard: some View {
        VStack(spacing: 20) {
            HStack(spacing: 12) {
                Image(systemName: "circle.grid.3x3.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(RenaissanceColors.ochre)
                    .frame(width: 44, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: CornerRadius.sm)
                            .fill(RenaissanceColors.ochre.opacity(0.1))
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text("Il Setaccio")
                        .font(.custom("Cinzel-Bold", size: 22))
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                    Text("Sift the Riverbed Sand")
                        .font(RenaissanceFont.dialogSubtitle)
                        .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))
                }
            }

            Text("Sift sand into your bucket. River sand isn't just dirt — it's quartz crystals (SiO₂), ground by millennia of water flow. Roman builders needed clean sand for concrete. The trick: sieve out the shells, pebbles, and organic debris. Only pure silica grains make strong mortar.")
                .font(.custom("EBGaramond-Regular", size: 16))
                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: 10) {
                ruleRow(icon: "hand.tap.fill", text: "Tap sand grains (golden) to collect them", color: RenaissanceColors.ochre)
                ruleRow(icon: "xmark.circle", text: "Avoid rocks and shells — \(maxSieveMisses) mistakes allowed", color: RenaissanceColors.errorRed)
                ruleRow(icon: "star.fill", text: "Collect \(sandNeeded) grains to fill your bucket", color: RenaissanceColors.goldSuccess)
            }

            Button {
                startSandGame()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "circle.grid.3x3.fill")
                        .font(.caption)
                    Text("Begin Sifting")
                        .font(.custom("EBGaramond-SemiBold", size: 16))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(RenaissanceColors.ochre)
                )
            }

            Button("Back") {
                withAnimation { phase = .choose }
            }
            .font(RenaissanceFont.bodySmall)
            .foregroundStyle(RenaissanceColors.sepiaInk)
        }
        .padding(Spacing.xl)
        .adaptiveWidth(400)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.lg)
                .fill(RenaissanceColors.parchment)
        )
        .borderWorkshop()
    }

    // MARK: - Shared UI Helpers

    private func ruleRow(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(color)
                .frame(width: 32, height: 32)
                .background(
                    RoundedRectangle(cornerRadius: CornerRadius.sm)
                        .fill(color.opacity(0.1))
                )

            Text(text)
                .font(.custom("EBGaramond-Regular", size: 14))
                .foregroundStyle(RenaissanceColors.sepiaInk)

            Spacer()
        }
        .padding(Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(RenaissanceColors.parchment.opacity(0.6))
                .borderWorkshop(radius: 10)
        )
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: - WATER PIPE PUZZLE
    // ═══════════════════════════════════════════════════════════════

    private var pipeGameView: some View {
        GeometryReader { geo in
            let tileSize = min((geo.size.width - 80) / CGFloat(gridCols),
                               (geo.size.height - 200) / CGFloat(gridRows),
                               70)

            ZStack {
                RoundedRectangle(cornerRadius: CornerRadius.lg)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.15, green: 0.25, blue: 0.35),
                                Color(red: 0.10, green: 0.18, blue: 0.25)
                            ],
                            startPoint: .top, endPoint: .bottom
                        )
                    )

                VStack(spacing: Spacing.md) {
                    // HUD
                    HStack {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .foregroundStyle(.white.opacity(0.7))
                            Text("Moves: \(moveCount)")
                                .font(.custom("EBGaramond-Regular", size: 14))
                                .foregroundStyle(.white.opacity(0.8))
                        }

                        Spacer()

                        HStack(spacing: 4) {
                            Text("\u{1FAA3}")
                            Text("Le Tubature")
                                .font(.custom("Cinzel-Bold", size: 16))
                                .foregroundStyle(.white)
                        }

                        Spacer()

                        Button {
                            checkFlow()
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "drop.fill")
                                    .font(.caption2)
                                Text("Test Flow")
                                    .font(.custom("EBGaramond-SemiBold", size: 13))
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(RenaissanceColors.renaissanceBlue)
                            )
                        }
                    }
                    .padding(.horizontal, Spacing.lg)
                    .padding(.vertical, Spacing.sm)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.black.opacity(0.3))
                    )
                    .padding(.horizontal, Spacing.md)
                    .padding(.top, Spacing.md)

                    Spacer()

                    // Pipe grid
                    VStack(spacing: 2) {
                        ForEach(0..<gridRows, id: \.self) { row in
                            HStack(spacing: 2) {
                                ForEach(0..<gridCols, id: \.self) { col in
                                    pipeTileView(row: row, col: col, tileSize: tileSize)
                                }
                            }
                        }
                    }

                    // Source / Drain labels
                    HStack {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(RenaissanceColors.renaissanceBlue)
                                .frame(width: 10, height: 10)
                            Text("Source")
                                .font(.custom("EBGaramond-Regular", size: 12))
                                .foregroundStyle(.white.opacity(0.6))
                        }
                        Spacer()
                        HStack(spacing: 4) {
                            Circle()
                                .fill(RenaissanceColors.sageGreen)
                                .frame(width: 10, height: 10)
                            Text("Drain")
                                .font(.custom("EBGaramond-Regular", size: 12))
                                .foregroundStyle(.white.opacity(0.6))
                        }
                    }
                    .padding(.horizontal, Spacing.xl)

                    Spacer()

                    Text("Tap pipes to rotate. Fill your bucket! \u{1FAA3}")
                        .font(.custom("EBGaramond-Italic", size: 14))
                        .foregroundStyle(.white.opacity(0.5))
                        .padding(.bottom, Spacing.lg)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
            .borderWorkshop()
            .padding(Spacing.xl)
        }
    }

    private func pipeTileView(row: Int, col: Int, tileSize: CGFloat) -> some View {
        let tile = pipeGrid.indices.contains(row) && pipeGrid[row].indices.contains(col)
            ? pipeGrid[row][col]
            : PipeTile(type: .empty, rotation: 0, tileType: .normal)
        let pos = GridPos(row: row, col: col)
        let hasFlow = flowTiles.contains(pos)
        let isSource = row == 0 && col == 0
        let isDrain = row == gridRows - 1 && col == gridCols - 1

        return Button {
            guard tile.tileType == .normal else { return }
            rotateTile(row: row, col: col)
        } label: {
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        isSource ? RenaissanceColors.renaissanceBlue.opacity(0.2) :
                        isDrain ? RenaissanceColors.sageGreen.opacity(0.2) :
                        Color(red: 0.2, green: 0.25, blue: 0.3)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .strokeBorder(
                                hasFlow ? RenaissanceColors.renaissanceBlue.opacity(0.8) :
                                Color.white.opacity(0.1),
                                lineWidth: hasFlow ? 2 : 1
                            )
                    )

                // Pipe shape
                PipeShape(type: tile.type, rotation: tile.rotation)
                    .stroke(
                        hasFlow ? RenaissanceColors.renaissanceBlue : Color.white.opacity(0.6),
                        style: StrokeStyle(lineWidth: hasFlow ? 6 : 4, lineCap: .round)
                    )
                    .padding(6)

                // Flow fill
                if hasFlow {
                    PipeShape(type: tile.type, rotation: tile.rotation)
                        .stroke(
                            Color.cyan.opacity(0.3),
                            style: StrokeStyle(lineWidth: 10, lineCap: .round)
                        )
                        .padding(6)
                }

                // Source/Drain icons
                if isSource {
                    Image(systemName: "drop.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(RenaissanceColors.renaissanceBlue)
                        .offset(x: -tileSize * 0.3, y: -tileSize * 0.3)
                }
                if isDrain {
                    Image(systemName: "arrow.down.to.line")
                        .font(.system(size: 10))
                        .foregroundStyle(RenaissanceColors.sageGreen)
                        .offset(x: tileSize * 0.3, y: tileSize * 0.3)
                }
            }
            .frame(width: tileSize, height: tileSize)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Water Game Logic

    private func startWaterGame() {
        moveCount = 0
        flowTiles = []
        isFlowing = false
        generatePipePuzzle()
        withAnimation { phase = .playingWater }
    }

    private func generatePipePuzzle() {
        // 1. Generate a valid path from (0,0) to (gridRows-1, gridCols-1)
        let path = generatePath()

        // 2. Create grid with pipes along the path
        var grid = Array(repeating: Array(repeating: PipeTile(type: .empty, rotation: 0, tileType: .normal), count: gridCols), count: gridRows)

        // 3. Place pipes along the solution path
        for i in 0..<path.count {
            let pos = path[i]
            let prev: GridPos? = i > 0 ? path[i - 1] : nil
            let next: GridPos? = i < path.count - 1 ? path[i + 1] : nil

            let dirs = connectedDirections(from: prev, to: pos, next: next)
            let (pipeType, rotation) = pipeForDirections(dirs)
            grid[pos.row][pos.col] = PipeTile(type: pipeType, rotation: rotation, tileType: .normal)
        }

        // 4. Fill empty cells with random pipes
        for row in 0..<gridRows {
            for col in 0..<gridCols {
                if grid[row][col].type == .empty {
                    let randomType: PipeType = [.straight, .corner, .tee].randomElement()!
                    let randomRot = Int.random(in: 0...3)
                    grid[row][col] = PipeTile(type: randomType, rotation: randomRot, tileType: .normal)
                }
            }
        }

        // 5. Scramble all rotations (but remember solution)
        for row in 0..<gridRows {
            for col in 0..<gridCols {
                let scrambleAmount = Int.random(in: 1...3)
                grid[row][col].rotation = (grid[row][col].rotation + scrambleAmount) % 4
            }
        }

        pipeGrid = grid
    }

    /// Generate a random path from top-left to bottom-right using random walk
    private func generatePath() -> [GridPos] {
        var path: [GridPos] = [GridPos(row: 0, col: 0)]
        var visited: Set<GridPos> = [GridPos(row: 0, col: 0)]
        let target = GridPos(row: gridRows - 1, col: gridCols - 1)

        while path.last != target {
            guard let current = path.last else { break }

            // Prefer moving toward target, with some randomness
            var neighbors: [GridPos] = []
            let directions: [(Int, Int)] = [(0, 1), (1, 0), (0, -1), (-1, 0)]
            for (dr, dc) in directions {
                let nr = current.row + dr
                let nc = current.col + dc
                let neighbor = GridPos(row: nr, col: nc)
                if nr >= 0 && nr < gridRows && nc >= 0 && nc < gridCols && !visited.contains(neighbor) {
                    neighbors.append(neighbor)
                }
            }

            if neighbors.isEmpty {
                // Backtrack
                path.removeLast()
                if path.isEmpty { break }
                continue
            }

            // Weight toward target direction
            let sorted = neighbors.sorted { a, b in
                let distA = abs(a.row - target.row) + abs(a.col - target.col)
                let distB = abs(b.row - target.row) + abs(b.col - target.col)
                return distA < distB
            }

            // 70% chance pick best direction, 30% random
            let chosen: GridPos
            if Double.random(in: 0...1) < 0.7 {
                chosen = sorted[0]
            } else {
                chosen = sorted.randomElement()!
            }

            path.append(chosen)
            visited.insert(chosen)
        }

        // Fallback: if path generation failed, create a simple L-path
        if path.last != target {
            path = []
            for col in 0..<gridCols {
                path.append(GridPos(row: 0, col: col))
            }
            for row in 1..<gridRows {
                path.append(GridPos(row: row, col: gridCols - 1))
            }
        }

        return path
    }

    /// Determine which directions a path cell connects to
    private func connectedDirections(from prev: GridPos?, to current: GridPos, next: GridPos?) -> Set<Direction> {
        var dirs = Set<Direction>()
        if let p = prev {
            dirs.insert(directionFrom(current, to: p))
        } else {
            // Source — needs an opening toward the path
        }
        if let n = next {
            dirs.insert(directionFrom(current, to: n))
        } else {
            // Drain — needs an opening from the path
        }
        // Ensure at least straight if only one connection
        if dirs.count == 1 {
            // For endpoints, add the single direction they face
            // Source faces right or down; drain faces left or up
            if prev == nil {
                if let n = next {
                    let d = directionFrom(current, to: n)
                    // Add opposite to create a straight pipe
                    dirs.insert(d.opposite)
                }
            } else if next == nil {
                if let p = prev {
                    let d = directionFrom(current, to: p)
                    dirs.insert(d.opposite)
                }
            }
        }
        return dirs
    }

    private func directionFrom(_ from: GridPos, to: GridPos) -> Direction {
        if to.row < from.row { return .up }
        if to.row > from.row { return .down }
        if to.col < from.col { return .left }
        return .right
    }

    /// Convert a set of directions to a pipe type + rotation
    private func pipeForDirections(_ dirs: Set<Direction>) -> (PipeType, Int) {
        if dirs.count >= 3 {
            // T-piece — find which direction is missing
            let all: [Direction] = [.up, .right, .down, .left]
            for (i, d) in all.enumerated() {
                if !dirs.contains(d) {
                    // Rotation: 0 = missing up, 1 = missing right, etc.
                    return (.tee, (i + 2) % 4)
                }
            }
            return (.cross, 0)
        }

        if dirs.count == 2 {
            let sorted = dirs.sorted { $0.rawValue < $1.rawValue }
            let a = sorted[0]
            let b = sorted[1]

            // Check if straight
            if a.opposite == b {
                // Straight pipe
                if a == .up || a == .down { return (.straight, 0) }
                return (.straight, 1)
            }

            // Corner — determine rotation based on which two directions
            // rotation 0 = up+right, 1 = right+down, 2 = down+left, 3 = left+up
            if dirs.contains(.up) && dirs.contains(.right) { return (.corner, 0) }
            if dirs.contains(.right) && dirs.contains(.down) { return (.corner, 1) }
            if dirs.contains(.down) && dirs.contains(.left) { return (.corner, 2) }
            if dirs.contains(.left) && dirs.contains(.up) { return (.corner, 3) }
        }

        // Default: straight horizontal
        return (.straight, 1)
    }

    private func rotateTile(row: Int, col: Int) {
        guard pipeGrid.indices.contains(row) && pipeGrid[row].indices.contains(col) else { return }
        pipeGrid[row][col].rotation = (pipeGrid[row][col].rotation + 1) % 4
        moveCount += 1
        // Clear previous flow visualization
        flowTiles = []
        isFlowing = false
    }

    private func checkFlow() {
        // BFS from source (0,0) following connected openings
        let source = GridPos(row: 0, col: 0)
        let drain = GridPos(row: gridRows - 1, col: gridCols - 1)

        var visited = Set<GridPos>()
        var queue: [GridPos] = [source]
        visited.insert(source)

        while !queue.isEmpty {
            let current = queue.removeFirst()
            let tile = pipeGrid[current.row][current.col]
            let openings = tileOpenings(type: tile.type, rotation: tile.rotation)

            for dir in openings {
                let nr = current.row + dir.dRow
                let nc = current.col + dir.dCol
                let neighbor = GridPos(row: nr, col: nc)

                guard nr >= 0 && nr < gridRows && nc >= 0 && nc < gridCols else { continue }
                guard !visited.contains(neighbor) else { continue }

                // Check if neighbor has an opening facing back
                let neighborTile = pipeGrid[nr][nc]
                let neighborOpenings = tileOpenings(type: neighborTile.type, rotation: neighborTile.rotation)
                if neighborOpenings.contains(dir.opposite) {
                    visited.insert(neighbor)
                    queue.append(neighbor)
                }
            }
        }

        withAnimation(.easeInOut(duration: 0.3)) {
            flowTiles = visited
            isFlowing = visited.contains(drain)
        }

        if isFlowing {
            // Win!
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                onNudgeCamera?()
                withAnimation { phase = .success }
            }
        }
    }

    /// Returns which directions a tile has openings, given its type and rotation
    private func tileOpenings(type: PipeType, rotation: Int) -> Set<Direction> {
        // Base openings (rotation 0)
        let base: Set<Direction>
        switch type {
        case .straight:  base = [.up, .down]
        case .corner:    base = [.up, .right]
        case .tee:       base = [.up, .right, .down]
        case .cross:     base = [.up, .right, .down, .left]
        case .empty:     base = []
        }

        // Rotate
        return Set(base.map { $0.rotated(by: rotation) })
    }

    private var waterBonusFlorins: Int {
        // Fewer moves = more bonus (minimum moves is roughly path length)
        let pathEstimate = gridRows + gridCols - 1
        let optimalMoves = pathEstimate * 2
        if moveCount <= optimalMoves { return 4 }
        if moveCount <= optimalMoves * 2 { return 2 }
        return 0
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: - SAND SIFTING GAME
    // ═══════════════════════════════════════════════════════════════

    private var sandGameView: some View {
        GeometryReader { geo in
            let cellSize = min((geo.size.width - 100) / CGFloat(sieveGridCols), 80)

            ZStack {
                RoundedRectangle(cornerRadius: CornerRadius.lg)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.45, green: 0.38, blue: 0.28),
                                Color(red: 0.35, green: 0.28, blue: 0.18)
                            ],
                            startPoint: .top, endPoint: .bottom
                        )
                    )

                VStack(spacing: Spacing.md) {
                    // HUD
                    HStack {
                        HStack(spacing: 6) {
                            ForEach(0..<sandNeeded, id: \.self) { i in
                                Circle()
                                    .fill(i < sandCollected ? RenaissanceColors.goldSuccess : Color.white.opacity(0.2))
                                    .frame(width: 10, height: 10)
                            }
                            Text("\(sandCollected)/\(sandNeeded)")
                                .font(.custom("EBGaramond-Regular", size: 13))
                                .foregroundStyle(.white.opacity(0.7))
                        }

                        Spacer()

                        HStack(spacing: 4) {
                            Text("\u{1FAA3}")
                            Text("Il Setaccio")
                                .font(.custom("Cinzel-Bold", size: 16))
                                .foregroundStyle(.white)
                        }

                        Spacer()

                        HStack(spacing: 4) {
                            ForEach(0..<maxSieveMisses, id: \.self) { i in
                                Image(systemName: i < sieveMisses ? "xmark.circle.fill" : "xmark.circle")
                                    .font(.caption)
                                    .foregroundStyle(i < sieveMisses ? RenaissanceColors.errorRed : .white.opacity(0.3))
                            }
                        }
                    }
                    .padding(.horizontal, Spacing.lg)
                    .padding(.vertical, Spacing.sm)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.black.opacity(0.3))
                    )
                    .padding(.horizontal, Spacing.md)
                    .padding(.top, Spacing.md)

                    // Feedback text
                    if let fb = sieveFeedback {
                        Text(fb)
                            .font(.custom("EBGaramond-SemiBold", size: 16))
                            .foregroundStyle(sieveFeedbackColor)
                            .transition(.opacity)
                    }

                    Spacer()

                    // Sieve grid — fixed layout, stable positions
                    VStack(spacing: 8) {
                        ForEach(0..<sieveGridRows, id: \.self) { row in
                            HStack(spacing: 8) {
                                ForEach(0..<sieveGridCols, id: \.self) { col in
                                    let index = row * sieveGridCols + col
                                    if index < sieveItems.count {
                                        sieveItemButton(item: sieveItems[index], index: index, cellSize: cellSize)
                                    } else {
                                        // Empty cell placeholder
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.clear)
                                            .frame(width: cellSize, height: cellSize)
                                    }
                                }
                            }
                        }
                    }

                    Spacer()

                    Text("Sift into your bucket \u{1FAA3}")
                        .font(.custom("EBGaramond-Italic", size: 14))
                        .foregroundStyle(.white.opacity(0.5))
                        .padding(.bottom, Spacing.lg)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
            .borderWorkshop()
            .padding(Spacing.xl)
        }
    }

    private func sieveItemButton(item: SieveItem, index: Int, cellSize: CGFloat) -> some View {
        Button {
            handleSieveTap(index: index)
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        item.tapped
                            ? (item.isSand ? RenaissanceColors.sageGreen.opacity(0.3) : RenaissanceColors.errorRed.opacity(0.3))
                            : Color(red: 0.55, green: 0.48, blue: 0.38).opacity(0.6)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(
                                item.tapped
                                    ? (item.isSand ? RenaissanceColors.sageGreen : RenaissanceColors.errorRed)
                                    : Color.white.opacity(0.15),
                                lineWidth: 1.5
                            )
                    )

                if item.tapped {
                    // Show result
                    Image(systemName: item.isSand ? "checkmark" : "xmark")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(item.isSand ? RenaissanceColors.sageGreen : RenaissanceColors.errorRed)
                } else {
                    // Show item icon
                    Text(item.icon)
                        .font(.system(size: cellSize * 0.45))
                }
            }
            .frame(width: cellSize, height: cellSize)
        }
        .buttonStyle(.plain)
        .disabled(item.tapped)
    }

    // MARK: - Sand Game Logic

    private func startSandGame() {
        sandCollected = 0
        sieveMisses = 0
        sieveScore = 0
        sieveFeedback = nil
        generateSieveGrid()
        withAnimation { phase = .playingSand }
    }

    private func generateSieveGrid() {
        let totalCells = sieveGridRows * sieveGridCols
        // At least sandNeeded sand items, rest are debris
        let sandCount = sandNeeded + 2  // A couple extra sand grains
        let debrisCount = totalCells - sandCount

        var items: [SieveItem] = []

        // Sand grains — golden icons
        let sandIcons = ["🟡", "🟤", "✨", "🔶"]
        for i in 0..<sandCount {
            items.append(SieveItem(
                id: i,
                icon: sandIcons[i % sandIcons.count],
                isSand: true,
                tapped: false
            ))
        }

        // Debris — rocks, shells, sticks
        let debrisIcons = ["🪨", "🐚", "🪵", "🦴", "🍂", "🌿", "🪸", "🪹"]
        for i in 0..<debrisCount {
            items.append(SieveItem(
                id: sandCount + i,
                icon: debrisIcons[i % debrisIcons.count],
                isSand: false,
                tapped: false
            ))
        }

        sieveItems = items.shuffled()
    }

    private func handleSieveTap(index: Int) {
        guard index < sieveItems.count, !sieveItems[index].tapped else { return }

        sieveItems[index].tapped = true
        let item = sieveItems[index]

        if item.isSand {
            sandCollected += 1
            sieveScore += 1
            withAnimation {
                sieveFeedback = "SiO₂ quartz grain! +1"
                sieveFeedbackColor = RenaissanceColors.goldSuccess
            }

            if sandCollected >= sandNeeded {
                // Win!
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    onNudgeCamera?()
                    withAnimation { phase = .success }
                }
                return
            }
        } else {
            sieveMisses += 1
            withAnimation {
                sieveFeedback = "That's debris! Be careful."
                sieveFeedbackColor = RenaissanceColors.errorRed
            }

            if sieveMisses >= maxSieveMisses {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    onNudgeCamera?()
                    withAnimation { phase = .failed }
                }
                return
            }
        }

        // Clear feedback after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation { sieveFeedback = nil }
        }

        // Check if all items revealed but not enough sand (auto-regenerate remaining)
        let untapped = sieveItems.filter { !$0.tapped }
        let untappedSand = untapped.filter { $0.isSand }
        if untappedSand.count == 0 && sandCollected < sandNeeded {
            // Refill the grid with new items
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                generateSieveGrid()
            }
        }
    }

    private var sandBonusFlorins: Int {
        // Fewer misses = more bonus
        if sieveMisses == 0 { return 4 }
        if sieveMisses == 1 { return 2 }
        return 0
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: - SUCCESS / FAILED CARDS
    // ═══════════════════════════════════════════════════════════════

    private var currentBonusFlorins: Int {
        selectedMaterial == .water ? waterBonusFlorins : sandBonusFlorins
    }

    private var successCard: some View {
        VStack(spacing: 20) {
            HStack(spacing: 12) {
                BirdCharacter()
                    .frame(width: 70, height: 70)

                VStack(alignment: .leading, spacing: 4) {
                    Text(selectedMaterial == .water ? "Bucket Filled!" : "Sabbia Pura!")
                        .font(.custom("Cinzel-Bold", size: 22))
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                    Text("You collected 1x \(selectedMaterial.rawValue)")
                        .font(RenaissanceFont.dialogSubtitle)
                        .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))
                }
            }

            VStack(spacing: 10) {
                HStack(spacing: 12) {
                    Image(systemName: selectedMaterial == .water ? "drop.fill" : "circle.grid.3x3.fill")
                        .font(.body)
                        .foregroundStyle(RenaissanceColors.renaissanceBlue)
                        .frame(width: 32, height: 32)
                        .background(
                            RoundedRectangle(cornerRadius: CornerRadius.sm)
                                .fill(RenaissanceColors.renaissanceBlue.opacity(0.1))
                        )

                    Text(selectedMaterial == .water
                         ? "Bucket filled in \(moveCount) moves"
                         : "Your bucket is full! \(sandCollected) grains, \(sieveMisses) mistake\(sieveMisses == 1 ? "" : "s")")
                        .font(.custom("EBGaramond-Regular", size: 16))
                        .foregroundStyle(RenaissanceColors.sepiaInk)

                    Spacer()

                    Text(selectedMaterial.icon)
                        .font(.title3)
                }
                .padding(Spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(RenaissanceColors.parchment.opacity(0.6))
                        .borderWorkshop(radius: 10)
                )

                if currentBonusFlorins > 0 {
                    HStack(spacing: 12) {
                        Image(systemName: "star.fill")
                            .font(.body)
                            .foregroundStyle(RenaissanceColors.goldSuccess)
                            .frame(width: 32, height: 32)
                            .background(
                                RoundedRectangle(cornerRadius: CornerRadius.sm)
                                    .fill(RenaissanceColors.goldSuccess.opacity(0.1))
                            )

                        Text(selectedMaterial == .water ? "Efficient plumbing!" : "Your bucket is full!")
                            .font(.custom("EBGaramond-Regular", size: 16))
                            .foregroundStyle(RenaissanceColors.sepiaInk)

                        Spacer()

                        Text("+\(currentBonusFlorins) florins")
                            .font(.custom("EBGaramond-SemiBold", size: 13))
                            .foregroundStyle(RenaissanceColors.goldSuccess)
                    }
                    .padding(Spacing.sm)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(RenaissanceColors.parchment.opacity(0.6))
                            .borderWorkshop(radius: 10)
                    )
                }
            }

            Button {
                onComplete(selectedMaterial, currentBonusFlorins)
            } label: {
                HStack(spacing: 8) {
                    Text(selectedMaterial.icon)
                    Text("Collect \(selectedMaterial.rawValue)")
                        .font(.custom("EBGaramond-SemiBold", size: 16))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(RenaissanceColors.sageGreen)
                )
            }
        }
        .padding(Spacing.xl)
        .adaptiveWidth(400)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.lg)
                .fill(RenaissanceColors.parchment)
        )
        .borderWorkshop()
    }

    private var failedCard: some View {
        VStack(spacing: 20) {
            HStack(spacing: 12) {
                BirdCharacter()
                    .frame(width: 70, height: 70)

                VStack(alignment: .leading, spacing: 4) {
                    Text(selectedMaterial == .water ? "Pipes Leaking!" : "Too Much Debris!")
                        .font(.custom("Cinzel-Bold", size: 22))
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                    Text(selectedMaterial == .water
                         ? "The water escaped through gaps."
                         : "Your sand is full of impurities.")
                        .font(RenaissanceFont.dialogSubtitle)
                        .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))
                }
            }

            Text(selectedMaterial == .water
                 ? "Roman plumbers tested every joint before opening the valves. Patience and precision — that's how you move water uphill."
                 : "A good builder can tell pure sand by feel. SiO₂ quartz grains are smooth and angular — shells and clay feel different. Try again with sharper eyes.")
                .font(.custom("EBGaramond-Regular", size: 16))
                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))

            VStack(spacing: 10) {
                Button {
                    if selectedMaterial == .water {
                        startWaterGame()
                    } else {
                        startSandGame()
                    }
                    withAnimation {
                        phase = selectedMaterial == .water ? .introWater : .introSand
                    }
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.body)
                            .foregroundStyle(RenaissanceColors.sepiaInk)
                            .frame(width: 32, height: 32)
                            .background(
                                RoundedRectangle(cornerRadius: CornerRadius.sm)
                                    .fill(RenaissanceColors.warmBrown.opacity(0.1))
                            )

                        Text("Try Again")
                            .font(.custom("EBGaramond-Regular", size: 16))
                            .foregroundStyle(RenaissanceColors.sepiaInk)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(RenaissanceColors.sepiaInk)
                    }
                    .padding(Spacing.sm)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(RenaissanceColors.parchment.opacity(0.6))
                            .borderWorkshop(radius: 10)
                    )
                }

                Button {
                    onDismiss()
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "xmark")
                            .font(.body)
                            .foregroundStyle(RenaissanceColors.sepiaInk)
                            .frame(width: 32, height: 32)
                            .background(
                                RoundedRectangle(cornerRadius: CornerRadius.sm)
                                    .fill(RenaissanceColors.warmBrown.opacity(0.1))
                            )

                        Text("Leave River")
                            .font(.custom("EBGaramond-Regular", size: 16))
                            .foregroundStyle(RenaissanceColors.sepiaInk)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(RenaissanceColors.sepiaInk)
                    }
                    .padding(Spacing.sm)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(RenaissanceColors.parchment.opacity(0.6))
                            .borderWorkshop(radius: 10)
                    )
                }
            }
        }
        .padding(Spacing.xl)
        .adaptiveWidth(400)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.lg)
                .fill(RenaissanceColors.parchment)
        )
        .borderWorkshop()
    }
}

// ═══════════════════════════════════════════════════════════════
// MARK: - Pipe Puzzle Models
// ═══════════════════════════════════════════════════════════════

struct GridPos: Hashable {
    let row: Int
    let col: Int
}

enum Direction: Int, CaseIterable, Hashable {
    case up = 0, right = 1, down = 2, left = 3

    var opposite: Direction {
        switch self {
        case .up: return .down
        case .down: return .up
        case .left: return .right
        case .right: return .left
        }
    }

    var dRow: Int {
        switch self {
        case .up: return -1
        case .down: return 1
        case .left, .right: return 0
        }
    }

    var dCol: Int {
        switch self {
        case .left: return -1
        case .right: return 1
        case .up, .down: return 0
        }
    }

    /// Rotate clockwise by N quarter-turns
    func rotated(by quarters: Int) -> Direction {
        Direction(rawValue: (self.rawValue + quarters) % 4)!
    }
}

enum PipeType: CaseIterable {
    case straight   // ─ connects 2 opposite sides
    case corner     // ╮ connects 2 adjacent sides
    case tee        // ├ connects 3 sides
    case cross      // ┼ connects all 4 sides
    case empty      // no connections
}

enum TileType {
    case normal
    case source
    case drain
}

struct PipeTile {
    var type: PipeType
    var rotation: Int      // 0-3 quarter turns clockwise
    var tileType: TileType
}

// MARK: - Sand Sieve Model

struct SieveItem: Identifiable {
    let id: Int
    let icon: String
    let isSand: Bool
    var tapped: Bool
}

// MARK: - Pipe Shape (draws pipe connections inside a tile)

struct PipeShape: Shape {
    let type: PipeType
    let rotation: Int

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let midTop = CGPoint(x: rect.midX, y: rect.minY)
        let midRight = CGPoint(x: rect.maxX, y: rect.midY)
        let midBottom = CGPoint(x: rect.midX, y: rect.maxY)
        let midLeft = CGPoint(x: rect.minX, y: rect.midY)

        // Get endpoints based on base type
        let endpoints: [[CGPoint]]
        switch type {
        case .straight:
            endpoints = [[midTop, midBottom]]
        case .corner:
            endpoints = [[midTop, center], [center, midRight]]
        case .tee:
            endpoints = [[midTop, midBottom], [center, midRight]]
        case .cross:
            endpoints = [[midTop, midBottom], [midLeft, midRight]]
        case .empty:
            return path
        }

        // Apply rotation by transforming endpoints
        for segment in endpoints {
            let p1 = rotatePoint(segment[0], around: center, quarters: rotation, in: rect)
            let p2 = rotatePoint(segment[1], around: center, quarters: rotation, in: rect)
            path.move(to: p1)
            path.addLine(to: p2)
        }

        return path
    }

    private func rotatePoint(_ point: CGPoint, around center: CGPoint, quarters: Int, in rect: CGRect) -> CGPoint {
        // Normalize to unit square centered at origin
        let dx = point.x - center.x
        let dy = point.y - center.y

        let rotated: CGPoint
        switch quarters % 4 {
        case 0: rotated = CGPoint(x: dx, y: dy)
        case 1: rotated = CGPoint(x: -dy, y: dx)
        case 2: rotated = CGPoint(x: -dx, y: -dy)
        case 3: rotated = CGPoint(x: dy, y: -dx)
        default: rotated = CGPoint(x: dx, y: dy)
        }

        return CGPoint(x: center.x + rotated.x, y: center.y + rotated.y)
    }
}
