import SwiftUI
import Pow

/// Interactive drag-and-drop chemistry equation view
/// Students drag chemical elements to fill in blanks in an equation
struct DragDropEquationView: View {
    let data: DragDropEquationData
    let onComplete: (Bool) -> Void  // Called with true if correct

    @State private var droppedAnswers: [String?]  // Answers placed in blanks
    @State private var availableElements: [ChemicalElement]
    @State private var showHint = false
    @State private var hasSubmitted = false
    @State private var isCorrect = false
    @State private var wrongSlotIndex: Int? = nil
    @State private var showSuccessEffect = false  // For Pow animation

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    private var isLargeScreen: Bool { horizontalSizeClass == .regular }

    init(data: DragDropEquationData, onComplete: @escaping (Bool) -> Void) {
        self.data = data
        self.onComplete = onComplete

        // Initialize state
        let blankCount = data.equationTemplate.components(separatedBy: "[BLANK]").count - 1
        _droppedAnswers = State(initialValue: Array(repeating: nil, count: blankCount))
        _availableElements = State(initialValue: data.availableElements.shuffled())
    }

    var body: some View {
        VStack(spacing: isLargeScreen ? 32 : 24) {
            // Equation display with drop zones
            equationView
                .padding(.vertical, 20)

            // Available elements to drag
            elementsBank

            // Hint button (if available)
            if let hint = data.hint, !hasSubmitted {
                hintSection(hint: hint)
            }

            // Check answer button
            if !hasSubmitted {
                checkAnswerButton
            }
        }
        .padding()
    }

    // MARK: - Equation View with Drop Zones

    private var equationView: some View {
        // Parse equation template and create views
        let parts = data.equationTemplate.components(separatedBy: "[BLANK]")

        return HStack(spacing: 8) {
            ForEach(Array(parts.enumerated()), id: \.offset) { index, part in
                // Text part of equation
                Text(part)
                    .font(.custom("Cinzel-Regular", size: isLargeScreen ? 28 : 22))
                    .foregroundStyle(RenaissanceColors.sepiaInk)

                // Drop zone (if not last part)
                if index < parts.count - 1 {
                    dropZone(at: index)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(RenaissanceColors.parchment)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            hasSubmitted && isCorrect
                                ? RenaissanceColors.sageGreen
                                : RenaissanceColors.ochre.opacity(0.5),
                            lineWidth: hasSubmitted && isCorrect ? 3 : 2
                        )
                )
        )
        // Pow celebration effect for correct answers!
        .changeEffect(
            .spray(origin: UnitPoint(x: 0.5, y: 0.5)) {
                Image(systemName: "sparkle")
                    .foregroundStyle(RenaissanceColors.goldSuccess)
            },
            value: showSuccessEffect
        )
    }

    private func dropZone(at index: Int) -> some View {
        let hasAnswer = droppedAnswers.indices.contains(index) && droppedAnswers[index] != nil
        let isWrong = wrongSlotIndex == index

        return ZStack {
            // Drop zone background
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    hasAnswer
                        ? (hasSubmitted
                            ? (isCorrect ? RenaissanceColors.sageGreen.opacity(0.2) : RenaissanceColors.errorRed.opacity(0.2))
                            : RenaissanceColors.renaissanceBlue.opacity(0.15))
                        : RenaissanceColors.ochre.opacity(0.1)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(
                            hasAnswer
                                ? (hasSubmitted
                                    ? (isCorrect ? RenaissanceColors.sageGreen : RenaissanceColors.errorRed)
                                    : RenaissanceColors.renaissanceBlue)
                                : RenaissanceColors.ochre.opacity(0.4),
                            style: hasAnswer ? StrokeStyle(lineWidth: 2) : StrokeStyle(lineWidth: 2, dash: [6, 4])
                        )
                )
                .frame(minWidth: isLargeScreen ? 100 : 80, minHeight: isLargeScreen ? 50 : 40)

            // Dropped element or placeholder
            if let answer = droppedAnswers[index] {
                Text(answer)
                    .font(.custom("Cinzel-Regular", size: isLargeScreen ? 22 : 18))
                    .foregroundStyle(
                        hasSubmitted
                            ? (isCorrect ? RenaissanceColors.sageGreen : RenaissanceColors.errorRed)
                            : RenaissanceColors.renaissanceBlue
                    )
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .scaleEffect(isWrong ? 1.0 : 1.0)
                    .animation(.easeInOut, value: isWrong)
            } else {
                Text("?")
                    .font(.custom("EBGaramond-Regular", size: isLargeScreen ? 20 : 16))
                    .foregroundStyle(RenaissanceColors.sepiaInk)
            }
        }
        .onTapGesture {
            // Tap to remove placed element
            if !hasSubmitted, let answer = droppedAnswers[index] {
                // Return element to bank
                if let element = data.availableElements.first(where: { $0.symbol == answer }) {
                    if !availableElements.contains(where: { $0.symbol == element.symbol }) {
                        availableElements.append(element)
                    }
                }
                droppedAnswers[index] = nil
            }
        }
        .dropDestination(for: String.self) { items, _ in
            guard !hasSubmitted, let symbol = items.first else { return false }

            // Remove from bank
            availableElements.removeAll { $0.symbol == symbol }

            // If slot already has answer, return it to bank
            if let existingAnswer = droppedAnswers[index],
               let existingElement = data.availableElements.first(where: { $0.symbol == existingAnswer }) {
                availableElements.append(existingElement)
            }

            // Place new answer
            droppedAnswers[index] = symbol
            return true
        }
    }

    // MARK: - Elements Bank

    private var elementsBank: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Drag elements to complete the equation:")
                .font(.custom("EBGaramond-Regular", size: isLargeScreen ? 16 : 14))
                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))

            // Draggable elements in a flow layout
            FlowLayout(spacing: 12) {
                ForEach(availableElements) { element in
                    draggableElement(element)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(RenaissanceColors.ochre.opacity(0.08))
                .borderCard(radius: 12)
        )
    }

    private func draggableElement(_ element: ChemicalElement) -> some View {
        VStack(spacing: 4) {
            Text(element.symbol)
                .font(.custom("Cinzel-Regular", size: isLargeScreen ? 20 : 16))
                .foregroundStyle(elementColor(element.color))

            Text(element.name)
                .font(.custom("EBGaramond-Regular", size: isLargeScreen ? 12 : 10))
                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.6))
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .frame(minWidth: isLargeScreen ? 100 : 80)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(RenaissanceColors.parchment)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(elementColor(element.color).opacity(0.5), lineWidth: 2)
                )
        )
        .draggable(element.symbol) {
            // Drag preview
            Text(element.symbol)
                .font(.custom("EBGaramond-SemiBold", size: 22))
                .foregroundStyle(elementColor(element.color))
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(RenaissanceColors.parchment)
                )
        }
    }

    private func elementColor(_ colorName: String) -> Color {
        switch colorName {
        case "green": return RenaissanceColors.sageGreen
        case "blue": return RenaissanceColors.renaissanceBlue
        case "gray": return RenaissanceColors.stoneGray
        case "orange": return RenaissanceColors.terracotta
        case "yellow": return RenaissanceColors.ochre
        case "black": return RenaissanceColors.sepiaInk
        default: return RenaissanceColors.renaissanceBlue
        }
    }

    // MARK: - Hint Section

    private func hintSection(hint: String) -> some View {
        VStack(spacing: 8) {
            Button {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showHint.toggle()
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: showHint ? "lightbulb.fill" : "lightbulb")
                        .foregroundStyle(RenaissanceColors.highlightAmber)
                    Text(showHint ? "Hide Hint" : "Show Hint")
                        .font(.custom("EBGaramond-Regular", size: 14))
                        .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))
                }
            }
            .buttonStyle(.plain)

            if showHint {
                Text(hint)
                    .font(.custom("EBGaramond-Regular", size: isLargeScreen ? 16 : 14))
                    .foregroundStyle(RenaissanceColors.sepiaInk)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(RenaissanceColors.highlightAmber.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(RenaissanceColors.highlightAmber.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    // MARK: - Check Answer Button

    private var checkAnswerButton: some View {
        let allFilled = !droppedAnswers.contains(nil)

        return Button {
            checkAnswer()
        } label: {
            HStack {
                Image(systemName: "checkmark.seal")
                Text("Check Answer")
            }
            .font(.custom("EBGaramond-Regular", size: 18))
            .tracking(2)
            .foregroundStyle(allFilled ? RenaissanceColors.sepiaInk : RenaissanceColors.stoneGray)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(
                RenaissanceColors.parchment.opacity(allFilled ? 0.9 : 0.5)
            )
            .overlay(
                ZStack {
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(RenaissanceColors.sepiaInk.opacity(allFilled ? 0.6 : 0.3), lineWidth: 1)
                        .padding(2)
                    RoundedRectangle(cornerRadius: 1)
                        .stroke(RenaissanceColors.sepiaInk.opacity(allFilled ? 0.35 : 0.15), lineWidth: 0.5)
                        .padding(5)
                }
            )
        }
        .buttonStyle(.plain)
        .disabled(!allFilled)
    }

    // MARK: - Logic

    private func checkAnswer() {
        // Compare dropped answers with correct answers
        let studentAnswers = droppedAnswers.compactMap { $0 }
        isCorrect = studentAnswers == data.correctAnswers

        if !isCorrect {
            // Find which slot is wrong
            for (index, answer) in droppedAnswers.enumerated() {
                if index < data.correctAnswers.count && answer != data.correctAnswers[index] {
                    wrongSlotIndex = index
                    break
                }
            }
        }

        withAnimation(.easeInOut(duration: 0.3)) {
            hasSubmitted = true
        }

        // Trigger Pow celebration for correct answers
        if isCorrect {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                showSuccessEffect.toggle()
            }
        }

        // Notify parent after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            onComplete(isCorrect)
        }
    }
}

// MARK: - Preview

#Preview("Lime Water Reaction") {
    ScrollView {
        VStack {
            DragDropEquationView(
                data: DragDropEquationData(
                    equationTemplate: "CaO + H₂O → [BLANK]",
                    availableElements: [
                        ChemicalElement(symbol: "Ca(OH)₂", name: "Calcium Hydroxide", color: "green"),
                        ChemicalElement(symbol: "CaCO₃", name: "Calcium Carbonate", color: "gray"),
                        ChemicalElement(symbol: "Ca", name: "Pure Calcium", color: "yellow"),
                        ChemicalElement(symbol: "H₂", name: "Hydrogen Gas", color: "blue")
                    ],
                    correctAnswers: ["Ca(OH)₂"],
                    hint: "When an oxide reacts with water, it forms a hydroxide..."
                ),
                onComplete: { correct in
                    print("Answer is \(correct ? "correct" : "incorrect")")
                }
            )
        }
        .padding()
    }
    .background(RenaissanceColors.parchment)
}

#Preview("Carbonation Reaction") {
    ScrollView {
        VStack {
            DragDropEquationView(
                data: DragDropEquationData(
                    equationTemplate: "Ca(OH)₂ + CO₂ → [BLANK] + H₂O",
                    availableElements: [
                        ChemicalElement(symbol: "CaCO₃", name: "Calcium Carbonate", color: "gray"),
                        ChemicalElement(symbol: "CaO", name: "Calcium Oxide", color: "orange"),
                        ChemicalElement(symbol: "Ca(OH)₂", name: "Calcium Hydroxide", color: "green"),
                        ChemicalElement(symbol: "C", name: "Carbon", color: "black")
                    ],
                    correctAnswers: ["CaCO₃"],
                    hint: "The hydroxide absorbs CO₂ and turns back into rock..."
                ),
                onComplete: { _ in }
            )
        }
        .padding()
    }
    .background(RenaissanceColors.parchment)
}
