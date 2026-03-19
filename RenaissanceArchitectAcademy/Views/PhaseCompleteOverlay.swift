import SwiftUI

/// Celebration overlay when a phase is completed — bird guides player to the next environment
struct PhaseCompleteOverlay: View {
    let completedPhase: BuildingPhase
    let buildingName: String
    let buildingId: Int
    let onNavigate: (SidebarDestination) -> Void
    let onDismiss: () -> Void

    var viewModel: CityViewModel? = nil

    @State private var showContent = false
    @State private var birdEntered = false

    private var nextDestName: String {
        viewModel?.nextDestinationName(after: completedPhase) ?? "next area"
    }

    private var celebrationMessage: String {
        switch completedPhase {
        case .learn:
            return "You've mastered the knowledge of the \(buildingName)! Time to gather materials at the Workshop."
        case .collect:
            return "Materials collected! Explore the Italian Forest to discover timber and more science."
        case .explore:
            return "Forest explored! Head to the Crafting Room to transform your materials."
        case .craft:
            return "All materials crafted for the \(buildingName)! Return to the City Map to begin construction."
        case .build:
            return "The \(buildingName) is complete! Your city grows!"
        }
    }

    private var tutorialHint: String? {
        guard buildingId == 4 else { return nil } // Pantheon only
        return viewModel?.pantheonTutorialHint(for: completedPhase)
    }

    private var nextIcon: String {
        switch completedPhase {
        case .learn:   return "hammer.fill"
        case .collect: return "leaf.fill"
        case .explore: return "flame.fill"
        case .craft:   return "building.columns.fill"
        case .build:   return "checkmark.seal.fill"
        }
    }

    var body: some View {
        ZStack {
            // Dimming background — tap to dismiss
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            VStack(spacing: Spacing.lg) {
                // Bird companion
                if birdEntered {
                    BirdCharacter(isSitting: false)
                        .frame(width: 80, height: 80)
                        .transition(.scale.combined(with: .opacity))
                }

                // Phase progress dots
                phaseProgressDots

                // Celebration card
                VStack(spacing: Spacing.md) {
                    // Title
                    Text("\(completedPhase.displayName) Phase Complete!")
                        .font(RenaissanceFont.title)
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                        .multilineTextAlignment(.center)

                    // Divider line
                    Rectangle()
                        .fill(RenaissanceColors.ochre.opacity(0.3))
                        .frame(height: 1)
                        .padding(.horizontal, Spacing.xl)

                    // Message
                    Text(celebrationMessage)
                        .font(RenaissanceFont.body)
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                        .multilineTextAlignment(.center)
                        .lineSpacing(LineHeight.relaxed)
                        .padding(.horizontal, Spacing.md)

                    // Pantheon tutorial hint
                    if let hint = tutorialHint {
                        Text(hint)
                            .font(RenaissanceFont.italicSmall)
                            .foregroundStyle(RenaissanceColors.renaissanceBlue)
                            .multilineTextAlignment(.center)
                            .lineSpacing(LineHeight.normal)
                            .padding(.horizontal, Spacing.md)
                            .padding(.vertical, Spacing.xs)
                            .background(
                                RoundedRectangle(cornerRadius: CornerRadius.sm)
                                    .fill(RenaissanceColors.renaissanceBlue.opacity(0.08))
                            )
                    }

                    // Card progress
                    if let vm = viewModel, let bid = vm.activeBuildingId {
                        let progress = vm.cardProgress(for: bid)
                        Text("\(progress.completed)/\(progress.total) knowledge cards collected")
                            .font(RenaissanceFont.caption)
                            .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.5))
                    }

                    // Navigate button
                    if completedPhase != .build {
                        Button {
                            let dest = viewModel?.nextDestination(after: completedPhase) ?? .cityMap
                            onNavigate(dest)
                        } label: {
                            HStack(spacing: Spacing.xs) {
                                Image(systemName: nextIcon)
                                    .font(.system(size: 16))
                                Text("Go to \(nextDestName)!")
                                    .font(RenaissanceFont.button)
                                    .tracking(Tracking.button)
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, Spacing.xl)
                            .padding(.vertical, Spacing.sm)
                            .background(
                                Capsule()
                                    .fill(RenaissanceColors.renaissanceBlue)
                            )
                            .renaissanceShadow(.elevated)
                        }
                        .buttonStyle(.plain)
                        .padding(.top, Spacing.xs)
                    }
                }
                .padding(Spacing.dialogPadding)
                .background(
                    RoundedRectangle(cornerRadius: CornerRadius.lg)
                        .fill(RenaissanceColors.parchment)
                )
                .borderModal(radius: CornerRadius.lg)
                .renaissanceShadow(.modal)
                .adaptiveWidth(420)
                .padding(.horizontal, Spacing.dialogMargin)
            }
            .scaleEffect(showContent ? 1.0 : 0.85)
            .opacity(showContent ? 1.0 : 0.0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                showContent = true
            }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
                birdEntered = true
            }
        }
    }

    // MARK: - Phase Progress Dots

    private var phaseProgressDots: some View {
        HStack(spacing: Spacing.sm) {
            ForEach(BuildingPhase.allCases, id: \.rawValue) { phase in
                VStack(spacing: 4) {
                    Circle()
                        .fill(dotColor(for: phase))
                        .frame(width: 14, height: 14)
                        .overlay(
                            Circle()
                                .stroke(RenaissanceColors.sepiaInk.opacity(0.2), lineWidth: 1)
                        )

                    Text(phase.displayName)
                        .font(RenaissanceFont.captionSmall)
                        .foregroundStyle(
                            phase <= completedPhase
                                ? RenaissanceColors.sepiaInk
                                : RenaissanceColors.sepiaInk.opacity(0.3)
                        )
                }
            }
        }
    }

    private func dotColor(for phase: BuildingPhase) -> Color {
        if phase < completedPhase {
            return RenaissanceColors.sageGreen           // Already done
        } else if phase == completedPhase {
            return RenaissanceColors.goldSuccess          // Just completed
        } else {
            return RenaissanceColors.stoneGray.opacity(0.3) // Future
        }
    }
}
