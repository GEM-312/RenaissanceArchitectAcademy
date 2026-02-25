import SwiftUI

/// Card 3 destination — requirements checklist for building construction
struct BuildingChecklistView: View {
    let plot: BuildingPlot
    @ObservedObject var viewModel: CityViewModel
    var workshopState: WorkshopState
    let onBeginConstruction: () -> Void
    let onDismiss: () -> Void

    private var progress: BuildingProgress {
        viewModel.buildingProgressMap[plot.id] ?? BuildingProgress()
    }

    private var allRequirementsMet: Bool {
        viewModel.canStartBuilding(for: plot.id, workshopState: workshopState)
    }

    var body: some View {
        ZStack {
            RenaissanceColors.overlayDimming
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            ScrollView {
                VStack(spacing: 18) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.shield.fill")
                            .font(.custom("Mulish-Light", size: 32, relativeTo: .title3))
                            .foregroundStyle(RenaissanceColors.sageGreen)

                        Text(plot.building.name)
                            .font(.custom("EBGaramond-SemiBold", size: 26))
                            .foregroundStyle(RenaissanceColors.sepiaInk)

                        Text("Construction Requirements")
                            .font(.custom("EBGaramond-Regular", size: 17))
                            .foregroundStyle(RenaissanceColors.sepiaInk)
                    }

                    Divider()
                        .overlay(RenaissanceColors.ochre.opacity(0.3))

                    // Science badges section
                    requirementSection(title: "Science Knowledge", icon: "books.vertical.fill") {
                        ForEach(plot.building.sciences, id: \.self) { science in
                            checklistRow(
                                icon: science.sfSymbolName,
                                label: science.rawValue,
                                isMet: progress.scienceBadgesEarned.contains(science),
                                customImage: science.customImageName
                            )
                        }
                    }

                    // Sketch section
                    let hasSketchContent = SketchingContent.sketchingChallenge(for: plot.building.name) != nil
                    requirementSection(title: "Architectural Sketch", icon: "pencil.and.outline") {
                        if hasSketchContent {
                            checklistRow(
                                icon: "pencil.and.outline",
                                label: "Floor Plan (Pianta)",
                                isMet: progress.sketchCompleted
                            )
                        } else {
                            HStack(spacing: 8) {
                                Image(systemName: "minus.circle")
                                    .font(.custom("Mulish-Light", size: 14, relativeTo: .footnote))
                                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.5))
                                Text("Not required for this building")
                                    .font(.custom("Mulish-Light", size: 14))
                                    .foregroundStyle(RenaissanceColors.sepiaInk)
                            }
                        }
                    }

                    // Materials section
                    requirementSection(title: "Crafted Materials", icon: "shippingbox.fill") {
                        ForEach(Array(plot.building.requiredMaterials.sorted(by: { $0.key.rawValue < $1.key.rawValue })), id: \.key) { item, needed in
                            let have = workshopState.craftedMaterials[item] ?? 0
                            HStack(spacing: 10) {
                                Image(systemName: have >= needed ? "checkmark.circle.fill" : "circle")
                                    .font(.custom("Mulish-Light", size: 16, relativeTo: .subheadline))
                                    .foregroundStyle(have >= needed ? RenaissanceColors.sageGreen : RenaissanceColors.sepiaInk.opacity(0.5))

                                Text(item.icon)
                                    .font(.custom("Mulish-Light", size: 18, relativeTo: .body))

                                Text(item.rawValue)
                                    .font(.custom("Mulish-Light", size: 15))
                                    .foregroundStyle(RenaissanceColors.sepiaInk)

                                Spacer()

                                Text("\(have)/\(needed)")
                                    .font(.custom("EBGaramond-Regular", size: 15))
                                    .foregroundStyle(have >= needed ? RenaissanceColors.sageGreen : RenaissanceColors.errorRed)
                            }
                        }
                    }

                    // Quiz section
                    let hasQuiz = ChallengeContent.interactiveChallenge(for: plot.building.name) != nil
                    requirementSection(title: "Knowledge Test", icon: "questionmark.circle.fill") {
                        if hasQuiz {
                            checklistRow(
                                icon: "checkmark.seal.fill",
                                label: "Quiz Passed",
                                isMet: progress.quizPassed
                            )
                        } else {
                            HStack(spacing: 8) {
                                Image(systemName: "minus.circle")
                                    .font(.custom("Mulish-Light", size: 14, relativeTo: .footnote))
                                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.5))
                                Text("No quiz available yet")
                                    .font(.custom("Mulish-Light", size: 14))
                                    .foregroundStyle(RenaissanceColors.sepiaInk)
                            }
                        }
                    }

                    Divider()
                        .overlay(RenaissanceColors.ochre.opacity(0.3))

                    // Begin Construction button
                    Button {
                        onBeginConstruction()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: allRequirementsMet ? "hammer.fill" : "lock.fill")
                                .font(.custom("Mulish-Light", size: 16, relativeTo: .subheadline))
                            Text(allRequirementsMet ? "Begin Construction" : "Requirements Not Met")
                                .font(.custom("Mulish-Light", size: 18))
                                .tracking(1)
                            if allRequirementsMet {
                                Text("+\(GameRewards.buildCompleteFlorins)")
                                    .font(.custom("EBGaramond-Regular", size: 16))
                                    .foregroundStyle(RenaissanceColors.goldSuccess)
                                Image(systemName: "dollarsign.circle.fill")
                                    .font(.custom("Mulish-Light", size: 14, relativeTo: .footnote))
                                    .foregroundStyle(RenaissanceColors.goldSuccess)
                            }
                        }
                        .foregroundStyle(allRequirementsMet ? RenaissanceColors.sepiaInk : RenaissanceColors.sepiaInk)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RenaissanceColors.parchment.opacity(allRequirementsMet ? 0.95 : 0.6)
                        )
                        .overlay(EngineeringBorder())
                        .opacity(allRequirementsMet ? 1.0 : 0.6)
                    }
                    .buttonStyle(.plain)
                    .disabled(!allRequirementsMet)

                    // Close
                    Button {
                        onDismiss()
                    } label: {
                        Text("Close")
                            .font(.custom("Mulish-Light", size: 16))
                            .foregroundStyle(RenaissanceColors.sepiaInk)
                    }
                    .buttonStyle(.plain)
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(RenaissanceColors.parchment)
                )
                .borderModal(radius: 20)
                .padding(.horizontal, 32)
                .padding(.vertical, 40)
            }
        }
    }

    // MARK: - Components

    private func requirementSection<Content: View>(title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.custom("Mulish-Light", size: 14, relativeTo: .footnote))
                    .foregroundStyle(RenaissanceColors.sepiaInk)
                Text(title)
                    .font(.custom("EBGaramond-Regular", size: 16))
                    .foregroundStyle(RenaissanceColors.sepiaInk)
            }

            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(RenaissanceColors.parchment.opacity(0.5))
                .borderCard(radius: 12)
        )
    }

    private func checklistRow(icon: String, label: String, isMet: Bool, customImage: String? = nil) -> some View {
        HStack(spacing: 10) {
            Image(systemName: isMet ? "checkmark.circle.fill" : "circle")
                .font(.custom("Mulish-Light", size: 16, relativeTo: .subheadline))
                .foregroundStyle(isMet ? RenaissanceColors.sageGreen : RenaissanceColors.sepiaInk.opacity(0.5))

            if let imageName = customImage {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            } else {
                Image(systemName: icon)
                    .font(.custom("Mulish-Light", size: 14, relativeTo: .footnote))
                    .foregroundStyle(RenaissanceColors.sepiaInk)
            }

            Text(label)
                .font(.custom("Mulish-Light", size: 15))
                .foregroundStyle(isMet ? RenaissanceColors.sepiaInk : RenaissanceColors.sepiaInk.opacity(0.6))

            Spacer()

            if isMet {
                Image(systemName: "seal.fill")
                    .font(.custom("Mulish-Light", size: 12, relativeTo: .caption))
                    .foregroundStyle(RenaissanceColors.goldSuccess)
            }
        }
    }
}
