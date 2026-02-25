import SwiftUI

/// Lists all buildings with quiz challenges
/// Relocated from building card flow — quizzes are now a separate "Knowledge Tests" section
struct KnowledgeTestsView: View {
    @ObservedObject var viewModel: CityViewModel
    var workshopState: WorkshopState

    @State private var showingChallenge = false
    @State private var activeChallenge: InteractiveChallenge? = nil
    @State private var selectedPlotId: Int? = nil

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    private var isLargeScreen: Bool { horizontalSizeClass == .regular }

    /// Buildings that have quiz content
    private var quizBuildings: [(plot: BuildingPlot, challenge: InteractiveChallenge)] {
        viewModel.buildingPlots.compactMap { plot in
            if let challenge = ChallengeContent.interactiveChallenge(for: plot.building.name) {
                return (plot, challenge)
            }
            return nil
        }
    }

    var body: some View {
        ZStack {
            RenaissanceColors.parchmentGradient
                .ignoresSafeArea()
                .overlay(
                    BlueprintGridOverlay()
                        .opacity(0.03)
                )

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Knowledge Tests")
                            .font(.custom("Cinzel-Regular", size: isLargeScreen ? 32 : 26, relativeTo: .title))
                            .foregroundStyle(RenaissanceColors.sepiaInk)

                        Text("Test your understanding of Renaissance sciences")
                            .font(.custom("Mulish-Light", size: isLargeScreen ? 16 : 14, relativeTo: .subheadline))
                            .foregroundStyle(RenaissanceColors.sepiaInk)
                    }
                    .padding(.horizontal, isLargeScreen ? 40 : 20)
                    .padding(.top, 20)

                    // Quiz list
                    LazyVStack(spacing: 12) {
                        ForEach(quizBuildings, id: \.plot.id) { item in
                            quizRow(plot: item.plot, challenge: item.challenge)
                        }
                    }
                    .padding(.horizontal, isLargeScreen ? 40 : 20)
                }
            }

            // Challenge view
            if showingChallenge, let challenge = activeChallenge {
                InteractiveChallengeView(
                    challenge: challenge,
                    workshopState: workshopState,
                    onComplete: { correct, total in
                        if let plotId = selectedPlotId {
                            let passThreshold = total / 2
                            if correct > passThreshold {
                                viewModel.completeChallenge(for: plotId)
                            }
                        }
                        showingChallenge = false
                        activeChallenge = nil
                        selectedPlotId = nil
                    },
                    onDismiss: {
                        showingChallenge = false
                        activeChallenge = nil
                        selectedPlotId = nil
                    }
                )
                .transition(.move(edge: .trailing))
            }
        }
        .navigationTitle("Knowledge Tests")
    }

    private func quizRow(plot: BuildingPlot, challenge: InteractiveChallenge) -> some View {
        Button {
            activeChallenge = challenge
            selectedPlotId = plot.id
            showingChallenge = true
        } label: {
            HStack(spacing: 16) {
                // Building icon
                ZStack {
                    Circle()
                        .fill(RenaissanceColors.color(for: plot.building.sciences.first ?? .architecture).opacity(0.12))
                        .frame(width: 48, height: 48)
                    Image(systemName: plot.building.iconName)
                        .font(.title3)
                        .foregroundStyle(RenaissanceColors.color(for: plot.building.sciences.first ?? .architecture))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(plot.building.name)
                        .font(.custom("Mulish-Light", size: 17, relativeTo: .body))
                        .foregroundStyle(RenaissanceColors.sepiaInk)

                    HStack(spacing: 6) {
                        Text("\(challenge.questions.count) questions")
                            .font(.custom("Mulish-Light", size: 13, relativeTo: .caption))
                            .foregroundStyle(RenaissanceColors.sepiaInk)

                        ForEach(plot.building.sciences.prefix(3), id: \.self) { science in
                            Image(systemName: science.sfSymbolName)
                                .font(.custom("Mulish-Light", size: 10, relativeTo: .caption2))
                                .foregroundStyle(RenaissanceColors.color(for: science))
                        }
                    }
                }

                Spacer()

                // Completion indicator
                if plot.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(RenaissanceColors.sageGreen)
                } else {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(RenaissanceColors.parchment)
                    .borderCard(radius: 12)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    KnowledgeTestsView(viewModel: CityViewModel(), workshopState: WorkshopState())
}
