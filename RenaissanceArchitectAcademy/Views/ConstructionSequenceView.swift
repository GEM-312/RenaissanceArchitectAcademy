import SwiftUI

/// Interactive construction sequence puzzle — drag steps into the correct order
/// Each building has 8 construction steps that must be arranged chronologically
struct ConstructionSequenceView: View {
    let sequence: ConstructionSequence
    let onComplete: () -> Void
    let onDismiss: () -> Void

    @State private var steps: [ConstructionStep] = []      // Current order (shuffled)
    @State private var draggedStep: ConstructionStep?
    @State private var correctPositions: Set<UUID> = []    // Steps in correct position
    @State private var wrongFlash: UUID?                   // Brief red flash on wrong check
    @State private var showIntro = true
    @State private var showCompletion = false
    @State private var checkedOnce = false                 // Has player checked at least once
    @State private var auroraPhase = false

    @Environment(\.horizontalSizeClass) private var sizeClass
    private var isLargeScreen: Bool { sizeClass == .regular }
    private var settings: GameSettings { GameSettings.shared }

    var body: some View {
        ZStack {
            // Dimmed background
            RenaissanceColors.overlayDimming
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            if showIntro {
                introCard
            } else if showCompletion {
                completionCard
            } else {
                puzzleView
            }
        }
        .onAppear {
            steps = sequence.steps.shuffled()
            auroraPhase = true
            GameCenterManager.shared.startActivity(GameCenterManager.ActivityID.construction)
        }
        .onDisappear {
            GameCenterManager.shared.endCurrentActivity()
        }
    }

    // MARK: - Introduction Card

    private var introCard: some View {
        VStack(spacing: 20) {
            Image(systemName: "hammer.fill")
                .font(.system(size: 44))
                .foregroundStyle(RenaissanceColors.ochre)

            Text("Construction Sequence")
                .font(.custom("Cinzel-Bold", size: 24))
                .foregroundStyle(settings.cardTextColor)

            Text(sequence.buildingName)
                .font(.custom("Cinzel-Regular", size: 18))
                .foregroundStyle(RenaissanceColors.warmBrown)

            Rectangle()
                .fill(RenaissanceColors.ochre.opacity(0.3))
                .frame(height: 1)
                .padding(.horizontal, 30)

            Text(sequence.introduction)
                .font(.custom("EBGaramond-Regular", size: 16))
                .foregroundStyle(settings.cardTextColor.opacity(0.8))
                .multilineTextAlignment(.center)
                .lineSpacing(5)
                .padding(.horizontal, 20)

            Text("Arrange the 8 construction steps in the correct order — from first to last.")
                .font(.custom("EBGaramond-Regular", size: 14))
                .foregroundStyle(settings.cardTextColor.opacity(0.5))
                .multilineTextAlignment(.center)

            Button {
                withAnimation(.easeOut(duration: 0.3)) {
                    showIntro = false
                }
            } label: {
                Text("Begin")
                    .font(.custom("EBGaramond-SemiBold", size: 18))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 50)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(RenaissanceColors.ochre)
                    )
            }
        }
        .padding(30)
        .adaptiveWidth(500)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(settings.dialogBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(RenaissanceColors.ochre.opacity(0.3), lineWidth: 1.5)
        )
        .shadow(color: RenaissanceColors.ochre.opacity(0.3), radius: 20, y: 6)
        .adaptivePadding(.all, regular: 40, compact: 16)
    }

    // MARK: - Puzzle View

    private var puzzleView: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button { onDismiss() } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "xmark")
                        Text("Close")
                    }
                    .font(.custom("EBGaramond-Regular", size: 14))
                    .foregroundStyle(settings.cardTextColor.opacity(0.5))
                }

                Spacer()

                Text(sequence.buildingName)
                    .font(.custom("Cinzel-Bold", size: 20))
                    .foregroundStyle(settings.cardTextColor)

                Spacer()

                // Progress indicator
                Text("\(correctPositions.count)/\(steps.count)")
                    .font(.custom("EBGaramond-SemiBold", size: 16))
                    .foregroundStyle(correctPositions.count == steps.count ? RenaissanceColors.sageGreen : RenaissanceColors.ochre)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 8)

            // Step list — draggable
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(Array(steps.enumerated()), id: \.element.id) { index, step in
                        stepRow(step: step, index: index)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            }

            // Bottom bar — Check / Complete
            HStack(spacing: 16) {
                if correctPositions.count == steps.count {
                    Button {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                            showCompletion = true
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Complete!")
                        }
                        .font(.custom("EBGaramond-SemiBold", size: 18))
                        .foregroundStyle(.white)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(RenaissanceColors.sageGreen)
                        )
                    }
                } else {
                    Button {
                        checkOrder()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.diamond.fill")
                            Text("Check Order")
                        }
                        .font(.custom("EBGaramond-SemiBold", size: 16))
                        .foregroundStyle(.white)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(RenaissanceColors.ochre)
                        )
                    }

                    if checkedOnce {
                        Button {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                steps.sort { $0.order < $1.order }
                                checkOrder()
                            }
                        } label: {
                            Text("Show Answer")
                                .font(.custom("EBGaramond-Regular", size: 14))
                                .foregroundStyle(settings.cardTextColor.opacity(0.5))
                                .padding(.vertical, 12)
                                .padding(.horizontal, 16)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            .padding(.top, 8)
        }
        .adaptiveWidth(650)
        .frame(maxHeight: 700)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(settings.dialogBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(RenaissanceColors.ochre.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: RenaissanceColors.ochre.opacity(0.3), radius: 20, y: 6)
        .adaptivePadding(.all, regular: 30, compact: 12)
    }

    // MARK: - Step Row

    private func stepRow(step: ConstructionStep, index: Int) -> some View {
        let isCorrect = correctPositions.contains(step.id)
        let isWrong = wrongFlash == step.id
        let scienceColor = scienceCardColor(step.science)

        return HStack(spacing: 12) {
            // Position number
            ZStack {
                Circle()
                    .fill(isCorrect ? RenaissanceColors.sageGreen : scienceColor.opacity(0.15))
                    .frame(width: 36, height: 36)
                Text("\(index + 1)")
                    .font(.custom("EBGaramond-SemiBold", size: 16))
                    .foregroundStyle(isCorrect ? .white : scienceColor)
            }

            // Step content
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Image(systemName: step.icon)
                        .font(.system(size: 13))
                        .foregroundStyle(scienceColor)
                    Text(step.name)
                        .font(.custom("EBGaramond-SemiBold", size: 15))
                        .foregroundStyle(settings.cardTextColor)
                }

                Text(step.italianName)
                    .font(.custom("EBGaramond-Italic", size: 12))
                    .foregroundStyle(RenaissanceColors.warmBrown.opacity(0.7))

                // Show description when correct
                if isCorrect {
                    Text(step.description)
                        .font(.custom("EBGaramond-Regular", size: 12))
                        .foregroundStyle(settings.cardTextColor.opacity(0.7))
                        .lineSpacing(3)
                        .padding(.top, 2)
                }
            }

            Spacer()

            // Drag handle
            if !isCorrect {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 16))
                    .foregroundStyle(settings.cardTextColor.opacity(0.25))
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(RenaissanceColors.sageGreen)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, isCorrect ? 14 : 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    isWrong ? RenaissanceColors.errorRed.opacity(0.15)
                    : isCorrect ? RenaissanceColors.sageGreen.opacity(0.08)
                    : settings.dialogBackground.opacity(0.5)
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    isWrong ? RenaissanceColors.errorRed.opacity(0.5)
                    : isCorrect ? RenaissanceColors.sageGreen.opacity(0.3)
                    : scienceColor.opacity(0.15),
                    lineWidth: 1
                )
        )
        .draggable(step.id.uuidString) {
            // Drag preview
            HStack(spacing: 8) {
                Image(systemName: step.icon)
                    .foregroundStyle(scienceColor)
                Text(step.name)
                    .font(.custom("EBGaramond-SemiBold", size: 14))
                    .foregroundStyle(settings.cardTextColor)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(settings.dialogBackground)
                    .shadow(color: scienceColor.opacity(0.3), radius: 8)
            )
        }
        .dropDestination(for: String.self) { droppedItems, _ in
            guard let droppedId = droppedItems.first,
                  let droppedUUID = UUID(uuidString: droppedId),
                  let fromIndex = steps.firstIndex(where: { $0.id == droppedUUID }),
                  let toIndex = steps.firstIndex(where: { $0.id == step.id }),
                  fromIndex != toIndex else { return false }

            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                steps.move(fromOffsets: IndexSet(integer: fromIndex),
                          toOffset: toIndex > fromIndex ? toIndex + 1 : toIndex)
            }
            return true
        }
        .animation(.easeInOut(duration: 0.2), value: isWrong)
        .animation(.easeInOut(duration: 0.3), value: isCorrect)
    }

    // MARK: - Completion Card

    private var completionCard: some View {
        VStack(spacing: 20) {
            Image(systemName: "building.columns.fill")
                .font(.system(size: 50))
                .foregroundStyle(RenaissanceColors.sageGreen)
                .shadow(color: RenaissanceColors.sageGreen.opacity(0.5), radius: 10)

            Text("Construction Complete!")
                .font(.custom("Cinzel-Bold", size: 24))
                .foregroundStyle(settings.cardTextColor)

            Text(sequence.buildingName)
                .font(.custom("Cinzel-Regular", size: 18))
                .foregroundStyle(RenaissanceColors.warmBrown)

            Rectangle()
                .fill(RenaissanceColors.sageGreen.opacity(0.3))
                .frame(height: 1)
                .padding(.horizontal, 30)

            Text(sequence.completionText)
                .font(.custom("EBGaramond-Italic", size: 17))
                .foregroundStyle(settings.cardTextColor.opacity(0.8))
                .multilineTextAlignment(.center)
                .lineSpacing(5)
                .padding(.horizontal, 20)

            // Florins reward
            HStack(spacing: 6) {
                Image(systemName: "dollarsign.circle.fill")
                    .foregroundStyle(RenaissanceColors.goldSuccess)
                Text("+\(GameRewards.constructionSequenceFlorins) florins")
                    .font(.custom("EBGaramond-SemiBold", size: 16))
                    .foregroundStyle(RenaissanceColors.goldSuccess)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(RenaissanceColors.goldSuccess.opacity(0.12))
            )

            Button {
                onComplete()
            } label: {
                Text("Continue")
                    .font(.custom("EBGaramond-SemiBold", size: 18))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 50)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(RenaissanceColors.sageGreen)
                    )
            }
        }
        .padding(30)
        .adaptiveWidth(500)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(settings.dialogBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(RenaissanceColors.sageGreen.opacity(0.3), lineWidth: 1.5)
        )
        .shadow(color: RenaissanceColors.sageGreen.opacity(0.4), radius: 25, y: 8)
        .adaptivePadding(.all, regular: 40, compact: 16)
    }

    // MARK: - Logic

    private func checkOrder() {
        checkedOnce = true
        var newCorrect = Set<UUID>()

        for (index, step) in steps.enumerated() {
            if step.order == index + 1 {
                newCorrect.insert(step.id)
            }
        }

        // Flash wrong ones briefly
        for (index, step) in steps.enumerated() {
            if step.order != index + 1 && !correctPositions.contains(step.id) {
                withAnimation {
                    wrongFlash = step.id
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation {
                        if wrongFlash == step.id { wrongFlash = nil }
                    }
                }
            }
        }

        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            correctPositions = newCorrect
        }
    }

    private func scienceCardColor(_ science: Science) -> Color {
        RenaissanceColors.color(for: science)
    }
}
