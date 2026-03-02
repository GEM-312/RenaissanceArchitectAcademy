import SwiftUI
import SceneKit
import Subsonic

/// SwiftUI view that hosts a 3D SceneKit activity for a KnowledgeCard.
/// Replaces the flat 2D activity content in the flipped card back.
/// Manages activity state and translates SCNHitTest results into game actions.
struct SceneKitActivityView: View {
    let card: KnowledgeCard
    let onComplete: () -> Void

    // MARK: - Shared State

    @State private var scene: SCNScene?
    @State private var activityDone = false

    // Word Scramble
    @State private var tileNodeNames: [String: Character] = [:]
    @State private var spelledLetters: [Character] = []
    @State private var targetWord: String = ""
    @State private var usedTileNames: Set<String> = []

    // Number Fishing
    @State private var bubbleNodeNames: [String: Int] = [:]
    @State private var correctFishingAnswer: Int = 0
    @State private var sunkBubbles: Set<String> = []

    // Hangman
    @State private var hangmanGuessed: Set<Character> = []
    @State private var hangmanWrongCount: Int = 0
    @State private var hangmanWord: String = ""
    @State private var hangmanWon = false
    @State private var hangmanRevealed = false

    // Keyword Match
    @State private var termNodeNames: [String: Int] = [:]
    @State private var defNodeNames: [String: Int] = [:]
    @State private var selectedTermIndex: Int? = nil
    @State private var selectedDefIndex: Int? = nil
    @State private var selectedTermName: String? = nil
    @State private var selectedDefName: String? = nil
    @State private var matchedIndices: Set<Int> = []
    @State private var shuffledDefOrder: [Int] = []

    // Multiple Choice
    @State private var optionNodeNames: [String: Int] = [:]
    @State private var mcCorrectIndex: Int = 0
    @State private var mcAnswered = false

    // True/False
    @State private var tfIsTrue = false
    @State private var tfAnswered = false

    var body: some View {
        ZStack(alignment: .bottom) {
            if let scene = scene {
                // 3D Scene fills the full card area
                GameSceneKitView(scene: scene) { hit in
                    handleHit(hit)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Activity-specific 2D overlay pinned to bottom
                VStack(spacing: 0) {
                    Spacer()
                    activityOverlay
                        .background(
                            RenaissanceColors.parchment.opacity(0.85)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        )
                        .padding(.horizontal, 8)
                        .padding(.bottom, 8)
                }
            } else {
                RenaissanceColors.parchment
                ProgressView()
            }
        }
        .onAppear { buildScene() }
    }

    // MARK: - Overlay (shows progress info below 3D scene)

    @ViewBuilder
    private var activityOverlay: some View {
        switch card.activity {
        case .wordScramble:
            wordScrambleOverlay
        case .hangman:
            hangmanOverlay
        case .keywordMatch:
            keywordMatchOverlay
        default:
            EmptyView()
        }
    }

    // Word scramble: show progress dashes
    private var wordScrambleOverlay: some View {
        HStack(spacing: 5) {
            ForEach(Array(targetWord.enumerated()), id: \.offset) { index, _ in
                let filled = index < spelledLetters.count
                Text(filled ? String(spelledLetters[index]) : "_")
                    .font(.custom("Cinzel-Bold", size: 18))
                    .foregroundStyle(filled ? card.color : RenaissanceColors.sepiaInk.opacity(0.3))
                    .frame(width: 24, height: 28)
            }
        }
        .padding(.vertical, 6)
    }

    // Hangman: word dashes + alphabet grid
    private var hangmanOverlay: some View {
        VStack(spacing: 6) {
            // Word dashes
            HStack(spacing: 4) {
                ForEach(Array(hangmanWord.enumerated()), id: \.offset) { _, char in
                    let revealed = hangmanGuessed.contains(char) || hangmanRevealed
                    Text(revealed ? String(char) : "_")
                        .font(.custom("Cinzel-Bold", size: 16))
                        .foregroundStyle(
                            hangmanRevealed && !hangmanGuessed.contains(char)
                            ? RenaissanceColors.errorRed
                            : revealed ? card.color : RenaissanceColors.sepiaInk.opacity(0.3)
                        )
                        .frame(width: 20, height: 24)
                }
            }

            // Wrong count dots
            HStack(spacing: 3) {
                ForEach(0..<6, id: \.self) { i in
                    Circle()
                        .fill(i < hangmanWrongCount ? RenaissanceColors.errorRed : RenaissanceColors.sepiaInk.opacity(0.12))
                        .frame(width: 8, height: 8)
                }
            }

            // Alphabet grid (2 rows)
            let alphabet: [Character] = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
            let columns = Array(repeating: GridItem(.fixed(30), spacing: 2), count: 13)

            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(alphabet, id: \.self) { letter in
                    let isGuessed = hangmanGuessed.contains(letter)
                    let uniqueLetters = Set(hangmanWord)
                    let isCorrectLetter = uniqueLetters.contains(letter) && isGuessed
                    let isWrongLetter = !uniqueLetters.contains(letter) && isGuessed

                    Button {
                        guessHangmanLetter(letter)
                    } label: {
                        Text(String(letter))
                            .font(.custom("EBGaramond-SemiBold", size: 12))
                            .foregroundStyle(
                                isCorrectLetter ? RenaissanceColors.sageGreen
                                : isWrongLetter ? RenaissanceColors.errorRed.opacity(0.5)
                                : card.color
                            )
                            .frame(width: 28, height: 28)
                            .background(
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(
                                        isCorrectLetter ? RenaissanceColors.sageGreen.opacity(0.1)
                                        : isWrongLetter ? RenaissanceColors.errorRed.opacity(0.06)
                                        : card.color.opacity(0.06)
                                    )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(
                                        isCorrectLetter ? RenaissanceColors.sageGreen.opacity(0.4)
                                        : isWrongLetter ? RenaissanceColors.errorRed.opacity(0.2)
                                        : card.color.opacity(0.15),
                                        lineWidth: 1
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                    .disabled(isGuessed || hangmanRevealed || hangmanWon)
                    .opacity(isGuessed ? 0.5 : 1)
                }
            }

            // Retry if lost
            if hangmanRevealed && !hangmanWon {
                Button {
                    hangmanGuessed = []
                    hangmanWrongCount = 0
                    hangmanRevealed = false
                    hangmanWon = false
                    // Reset 3D body parts
                    resetHangmanScene()
                } label: {
                    Text("Try Again")
                        .font(.custom("EBGaramond-SemiBold", size: 13))
                        .foregroundStyle(card.color)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(card.color.opacity(0.08))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(card.color.opacity(0.3), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }

    // Keyword match: progress
    private var keywordMatchOverlay: some View {
        HStack(spacing: 4) {
            ForEach(0..<card.keywords.count, id: \.self) { i in
                Circle()
                    .fill(matchedIndices.contains(i) ? RenaissanceColors.sageGreen : RenaissanceColors.sepiaInk.opacity(0.15))
                    .frame(width: 8, height: 8)
            }
            Text("\(matchedIndices.count)/\(card.keywords.count)")
                .font(.custom("EBGaramond-Regular", size: 11))
                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.4))
        }
        .padding(.vertical, 4)
    }

    // MARK: - Scene Building

    private func buildScene() {
        switch card.activity {
        case .wordScramble(let word, _):
            targetWord = word.uppercased()
            var names: [String: Character] = [:]
            let s = ActivityScene3D.makeWordScrambleScene(letters: Array(targetWord), tileNodeNames: &names)
            tileNodeNames = names
            scene = s

        case .numberFishing(_, let correct, let decoys):
            correctFishingAnswer = correct
            var names: [String: Int] = [:]
            let s = ActivityScene3D.makeNumberFishingScene(correctAnswer: correct, decoys: decoys, bubbleNodeNames: &names)
            bubbleNodeNames = names
            scene = s

        case .hangman(let word, _):
            hangmanWord = word.uppercased()
            scene = ActivityScene3D.makeHangmanScene()

        case .keywordMatch:
            let keywords = card.keywords.map { $0.keyword }
            let definitions = card.keywords.map { $0.definition }
            shuffledDefOrder = Array(0..<definitions.count).shuffled()
            let shuffledDefs = shuffledDefOrder.map { definitions[$0] }
            var tNames: [String: Int] = [:]
            var dNames: [String: Int] = [:]
            let s = ActivityScene3D.makeKeywordMatchScene(
                keywords: keywords, definitions: shuffledDefs,
                termNames: &tNames, defNames: &dNames
            )
            termNodeNames = tNames
            defNodeNames = dNames
            scene = s

        case .multipleChoice(let question, let options, let correctIndex):
            mcCorrectIndex = correctIndex
            var names: [String: Int] = [:]
            let s = ActivityScene3D.makeMultipleChoiceScene(question: question, options: options, optionNames: &names)
            optionNodeNames = names
            scene = s

        case .trueFalse(_, let isTrue):
            tfIsTrue = isTrue
            if case .trueFalse(let statement, _) = card.activity {
                scene = ActivityScene3D.makeTrueFalseScene(statement: statement)
            }

        case .fillInBlanks:
            // Fall back to keyword match for fill-in-blanks
            let keywords = card.keywords.map { $0.keyword }
            let definitions = card.keywords.map { $0.definition }
            shuffledDefOrder = Array(0..<definitions.count).shuffled()
            let shuffledDefs = shuffledDefOrder.map { definitions[$0] }
            var tNames: [String: Int] = [:]
            var dNames: [String: Int] = [:]
            let s = ActivityScene3D.makeKeywordMatchScene(
                keywords: keywords, definitions: shuffledDefs,
                termNames: &tNames, defNames: &dNames
            )
            termNodeNames = tNames
            defNodeNames = dNames
            scene = s
        }
    }

    // MARK: - Hit Handling

    private func handleHit(_ hit: SCNHitTestResult) {
        guard !activityDone else { return }
        let nodeName = hit.node.name ?? hit.node.parent?.name ?? ""

        switch card.activity {
        case .wordScramble:
            handleWordScrambleHit(nodeName)
        case .numberFishing:
            handleNumberFishingHit(nodeName)
        case .hangman:
            break // Hangman uses 2D alphabet grid, not 3D taps
        case .keywordMatch, .fillInBlanks:
            handleKeywordMatchHit(nodeName)
        case .multipleChoice:
            handleMultipleChoiceHit(nodeName)
        case .trueFalse:
            handleTrueFalseHit(nodeName)
        }
    }

    // MARK: - Word Scramble Hit

    private func handleWordScrambleHit(_ nodeName: String) {
        // Could be hitting the label child — check parent
        let tileName: String
        if tileNodeNames[nodeName] != nil {
            tileName = nodeName
        } else if let parent = scene?.rootNode.childNode(withName: nodeName, recursively: true)?.parent?.name,
                  tileNodeNames[parent] != nil {
            tileName = parent
        } else {
            return
        }

        guard !usedTileNames.contains(tileName),
              let char = tileNodeNames[tileName] else { return }

        let nextIndex = spelledLetters.count
        guard nextIndex < targetWord.count else { return }

        let expected = targetWord[targetWord.index(targetWord.startIndex, offsetBy: nextIndex)]
        if char == expected {
            SubsonicController.shared.play(sound: "tap_soft.mp3")
            spelledLetters.append(char)
            usedTileNames.insert(tileName)

            // Animate tile flying to slot
            if let tileNode = scene?.rootNode.childNode(withName: tileName, recursively: false),
               let slotNode = scene?.rootNode.childNode(withName: "slot_\(nextIndex)", recursively: false) {
                let target = slotNode.position
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.35
                tileNode.position = SCNVector3(target.x, target.y + 0.35, target.z + 0.1)
                SCNTransaction.commit()

                // Hide the dash
                if let dash = scene?.rootNode.childNode(withName: "dash_\(nextIndex)", recursively: false) {
                    dash.isHidden = true
                }
            }

            // Check completion
            if spelledLetters.count == targetWord.count {
                SubsonicController.shared.play(sound: "correct_chime.mp3")
                activityDone = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { onComplete() }
            }
        } else {
            SubsonicController.shared.play(sound: "wrong_buzz.mp3")
            if let tileNode = scene?.rootNode.childNode(withName: tileName, recursively: false) {
                ActivityScene3D.shakeNode(tileNode)
                ActivityScene3D.flashRed(tileNode)
            }
        }
    }

    // MARK: - Number Fishing Hit

    private func handleNumberFishingHit(_ nodeName: String) {
        let bubbleName: String
        if bubbleNodeNames[nodeName] != nil {
            bubbleName = nodeName
        } else if let parent = scene?.rootNode.childNode(withName: nodeName, recursively: true)?.parent?.name,
                  bubbleNodeNames[parent] != nil {
            bubbleName = parent
        } else {
            return
        }

        guard !sunkBubbles.contains(bubbleName),
              let number = bubbleNodeNames[bubbleName],
              let node = scene?.rootNode.childNode(withName: bubbleName, recursively: false) else { return }

        if number == correctFishingAnswer {
            SubsonicController.shared.play(sound: "correct_chime.mp3")
            ActivityScene3D.riseNode(node)
            activityDone = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { onComplete() }
        } else {
            SubsonicController.shared.play(sound: "water_plop.mp3")
            sunkBubbles.insert(bubbleName)
            ActivityScene3D.sinkNode(node)
        }
    }

    // MARK: - Hangman

    private func guessHangmanLetter(_ letter: Character) {
        guard !hangmanGuessed.contains(letter), !hangmanRevealed, !hangmanWon else { return }
        let uniqueLetters = Set(hangmanWord)

        hangmanGuessed.insert(letter)

        if !uniqueLetters.contains(letter) {
            SubsonicController.shared.play(sound: "hangman_wrong.mp3")
            hangmanWrongCount += 1
            // Reveal body part in 3D
            if let s = scene {
                ActivityScene3D.revealBodyPart(scene: s, stage: hangmanWrongCount)
            }
            if hangmanWrongCount >= 6 {
                hangmanRevealed = true
            }
        } else {
            SubsonicController.shared.play(sound: "tap_soft.mp3")
            if uniqueLetters.isSubset(of: hangmanGuessed) {
                SubsonicController.shared.play(sound: "correct_chime.mp3")
                hangmanWon = true
                activityDone = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { onComplete() }
            }
        }
    }

    private func resetHangmanScene() {
        guard let s = scene else { return }
        for i in 1...6 {
            if let part = s.rootNode.childNode(withName: "body_\(i)", recursively: false) {
                part.isHidden = true
            }
        }
    }

    // MARK: - Keyword Match Hit

    private func handleKeywordMatchHit(_ nodeName: String) {
        let actualName: String
        if termNodeNames[nodeName] != nil || defNodeNames[nodeName] != nil {
            actualName = nodeName
        } else if let parent = scene?.rootNode.childNode(withName: nodeName, recursively: true)?.parent?.name,
                  (termNodeNames[parent] != nil || defNodeNames[parent] != nil) {
            actualName = parent
        } else {
            return
        }

        if let termIdx = termNodeNames[actualName] {
            guard !matchedIndices.contains(termIdx) else { return }
            selectedTermIndex = termIdx
            selectedTermName = actualName
            // Highlight
            if let node = scene?.rootNode.childNode(withName: actualName, recursively: false) {
                node.geometry?.firstMaterial = ActivityScene3D.ochreMaterial()
            }
            tryKeywordMatch()
        } else if let defIdx = defNodeNames[actualName] {
            let originalIdx = shuffledDefOrder[defIdx]
            guard !matchedIndices.contains(originalIdx) else { return }
            selectedDefIndex = originalIdx
            selectedDefName = actualName
            // Highlight
            if let node = scene?.rootNode.childNode(withName: actualName, recursively: false) {
                node.geometry?.firstMaterial = ActivityScene3D.ochreMaterial()
            }
            tryKeywordMatch()
        }
    }

    private func tryKeywordMatch() {
        guard let tIdx = selectedTermIndex, let dIdx = selectedDefIndex else { return }

        if tIdx == dIdx {
            // Correct match
            SubsonicController.shared.play(sound: "correct_chime.mp3")
            matchedIndices.insert(tIdx)
            if let tName = selectedTermName, let dName = selectedDefName, let s = scene {
                ActivityScene3D.connectMatch(scene: s, termName: tName, defName: dName)
            }
            selectedTermIndex = nil
            selectedDefIndex = nil
            selectedTermName = nil
            selectedDefName = nil

            if matchedIndices.count == card.keywords.count {
                activityDone = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { onComplete() }
            }
        } else {
            // Wrong match
            SubsonicController.shared.play(sound: "wrong_buzz.mp3")
            if let tName = selectedTermName, let node = scene?.rootNode.childNode(withName: tName, recursively: false) {
                ActivityScene3D.shakeNode(node)
                ActivityScene3D.flashRed(node)
            }
            if let dName = selectedDefName, let node = scene?.rootNode.childNode(withName: dName, recursively: false) {
                ActivityScene3D.shakeNode(node)
                ActivityScene3D.flashRed(node)
            }
            selectedTermIndex = nil
            selectedDefIndex = nil
            selectedTermName = nil
            selectedDefName = nil
        }
    }

    // MARK: - Multiple Choice Hit

    private func handleMultipleChoiceHit(_ nodeName: String) {
        guard !mcAnswered else { return }

        let actualName: String
        if optionNodeNames[nodeName] != nil {
            actualName = nodeName
        } else if let parent = scene?.rootNode.childNode(withName: nodeName, recursively: true)?.parent?.name,
                  optionNodeNames[parent] != nil {
            actualName = parent
        } else {
            return
        }

        guard let idx = optionNodeNames[actualName],
              let node = scene?.rootNode.childNode(withName: actualName, recursively: false) else { return }

        mcAnswered = true

        if idx == mcCorrectIndex {
            SubsonicController.shared.play(sound: "correct_chime.mp3")
            ActivityScene3D.flashGold(node)
            activityDone = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { onComplete() }
        } else {
            SubsonicController.shared.play(sound: "wrong_buzz.mp3")
            ActivityScene3D.shakeNode(node)
            ActivityScene3D.flashRed(node)
            // Show correct one in gold
            let correctName = optionNodeNames.first(where: { $0.value == mcCorrectIndex })?.key ?? ""
            if let correctNode = scene?.rootNode.childNode(withName: correctName, recursively: false) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    ActivityScene3D.flashGold(correctNode)
                }
            }
            // Allow retry after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                mcAnswered = false
                // Reset materials
                for (name, _) in optionNodeNames {
                    if let n = scene?.rootNode.childNode(withName: name, recursively: false) {
                        SCNTransaction.begin()
                        SCNTransaction.animationDuration = 0.2
                        n.geometry?.firstMaterial = ActivityScene3D.stoneMaterial()
                        SCNTransaction.commit()
                    }
                }
            }
        }
    }

    // MARK: - True/False Hit

    private func handleTrueFalseHit(_ nodeName: String) {
        guard !tfAnswered else { return }

        let actualName: String
        if nodeName == "true_btn" || nodeName == "false_btn" {
            actualName = nodeName
        } else if let parent = scene?.rootNode.childNode(withName: nodeName, recursively: true)?.parent?.name,
                  parent == "true_btn" || parent == "false_btn" {
            actualName = parent
        } else {
            return
        }

        tfAnswered = true
        let tappedTrue = actualName == "true_btn"
        let isCorrect = tappedTrue == tfIsTrue

        guard let node = scene?.rootNode.childNode(withName: actualName, recursively: false) else { return }

        if isCorrect {
            SubsonicController.shared.play(sound: "correct_chime.mp3")
            ActivityScene3D.flashGold(node)
            activityDone = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { onComplete() }
        } else {
            SubsonicController.shared.play(sound: "wrong_buzz.mp3")
            ActivityScene3D.shakeNode(node)
            ActivityScene3D.flashRed(node)
            // Highlight correct
            let correctName = tfIsTrue ? "true_btn" : "false_btn"
            if let correctNode = scene?.rootNode.childNode(withName: correctName, recursively: false) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    ActivityScene3D.flashGold(correctNode)
                }
            }
            // Allow retry
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                tfAnswered = false
                // Reset materials
                if let trueNode = scene?.rootNode.childNode(withName: "true_btn", recursively: false) {
                    SCNTransaction.begin()
                    SCNTransaction.animationDuration = 0.2
                    trueNode.geometry?.firstMaterial = ActivityScene3D.sageMaterial()
                    SCNTransaction.commit()
                }
                if let falseNode = scene?.rootNode.childNode(withName: "false_btn", recursively: false) {
                    SCNTransaction.begin()
                    SCNTransaction.animationDuration = 0.2
                    falseNode.geometry?.firstMaterial = ActivityScene3D.terracottaMaterial()
                    SCNTransaction.commit()
                }
            }
        }
    }
}
