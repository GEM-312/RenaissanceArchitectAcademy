import SwiftUI

/// Building Detail Overlay - Leonardo's Notebook aesthetic
/// Shows building info in a parchment card with decorative borders
struct BuildingDetailOverlay: View {
    let plot: BuildingPlot
    let onDismiss: () -> Void
    var isLargeScreen: Bool = false

    @State private var showContent = false

    // Adaptive sizing
    private var titleSize: CGFloat { isLargeScreen ? 36 : 28 }
    private var cardMaxWidth: CGFloat { isLargeScreen ? 600 : 500 }
    private var cardMaxHeight: CGFloat { isLargeScreen ? 550 : 450 }

    var body: some View {
        ZStack {
            // Dimmed background with blur
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }

            // Detail card
            VStack(spacing: isLargeScreen ? 24 : 20) {
                // Header with completion seal
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(plot.building.name)
                            .font(.custom("Cinzel-Bold", size: titleSize, relativeTo: .title))
                            .foregroundStyle(RenaissanceColors.sepiaInk)

                        HStack(spacing: 8) {
                            Image(systemName: plot.building.era.iconName)
                                .font(.subheadline)
                            Text(plot.building.era.rawValue)
                                .font(.custom("EBGaramond-Italic", size: isLargeScreen ? 20 : 16, relativeTo: .subheadline))
                        }
                        .foregroundStyle(RenaissanceColors.renaissanceBlue)
                    }

                    Spacer()

                    // Completion wax seal
                    if plot.isCompleted {
                        ZStack {
                            Circle()
                                .fill(RenaissanceColors.goldSuccess)
                                .frame(width: 44, height: 44)
                                .shadow(color: RenaissanceColors.goldSuccess.opacity(0.4), radius: 8)

                            Image(systemName: "checkmark")
                                .font(.title3.weight(.bold))
                                .foregroundStyle(.white)
                        }
                    }

                    Button(action: onDismiss) {
                        Image(systemName: "xmark.circle.fill")
                            .font(isLargeScreen ? .title : .title2)
                            .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.5))
                    }
                    .buttonStyle(.plain)
                    #if os(macOS)
                    .keyboardShortcut(.escape, modifiers: [])
                    #endif
                }

                // Decorative divider
                HStack(spacing: 12) {
                    Rectangle()
                        .fill(RenaissanceColors.ochre.opacity(0.4))
                        .frame(height: 1)
                    Image(systemName: "leaf.fill")
                        .font(.caption)
                        .foregroundStyle(RenaissanceColors.sageGreen)
                    Rectangle()
                        .fill(RenaissanceColors.ochre.opacity(0.4))
                        .frame(height: 1)
                }

                // Sciences involved
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "books.vertical.fill")
                            .foregroundStyle(RenaissanceColors.warmBrown)
                        Text("Sciences Required")
                            .font(.custom("Cinzel-Regular", size: isLargeScreen ? 16 : 14, relativeTo: .caption))
                            .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))
                    }

                    FlowLayout(spacing: isLargeScreen ? 12 : 8) {
                        ForEach(plot.building.sciences, id: \.self) { science in
                            ScienceBadge(science: science, isLargeScreen: isLargeScreen)
                        }
                    }
                }

                // Building description
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "scroll.fill")
                            .foregroundStyle(RenaissanceColors.warmBrown)
                        Text("Description")
                            .font(.custom("Cinzel-Regular", size: isLargeScreen ? 16 : 14, relativeTo: .caption))
                            .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))
                    }

                    Text(plot.building.description)
                        .font(.custom("EBGaramond-Regular", size: isLargeScreen ? 16 : 14, relativeTo: .body))
                        .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.8))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Spacer()

                // Action buttons
                HStack(spacing: 16) {
                    if isLargeScreen {
                        RenaissanceSecondaryButton(title: "Cancel", icon: "arrow.left", action: onDismiss)
                        #if os(macOS)
                        .keyboardShortcut(.cancelAction)
                        #endif
                    }

                    RenaissanceButton(
                        title: plot.isCompleted ? "Review Challenge" : "Begin Challenge",
                        icon: plot.isCompleted ? "eye.fill" : "hammer.fill",
                        action: {}
                    )
                    #if os(macOS)
                    .keyboardShortcut(.defaultAction)
                    #endif
                }
            }
            .padding(isLargeScreen ? 32 : 24)
            .frame(maxWidth: cardMaxWidth, maxHeight: cardMaxHeight)
            .background(
                ZStack {
                    // Main card background
                    RoundedRectangle(cornerRadius: isLargeScreen ? 20 : 16)
                        .fill(RenaissanceColors.parchment)

                    // Decorative border
                    RoundedRectangle(cornerRadius: isLargeScreen ? 20 : 16)
                        .stroke(RenaissanceColors.ochre.opacity(0.3), lineWidth: 2)
                        .padding(4)
                }
                .shadow(color: .black.opacity(0.25), radius: isLargeScreen ? 30 : 20, x: 0, y: 10)
            )
            .padding(isLargeScreen ? 60 : 40)
            .scaleEffect(showContent ? 1 : 0.9)
            .opacity(showContent ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                showContent = true
            }
        }
    }
}

/// Science badge with color-coded background
struct ScienceBadge: View {
    let science: Science
    var isLargeScreen: Bool = false

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: science.iconName)
                .font(isLargeScreen ? .body : .caption)
                .foregroundStyle(RenaissanceColors.color(for: science))

            Text(science.rawValue)
                .font(.custom("EBGaramond-Regular", size: isLargeScreen ? 15 : 13, relativeTo: .caption))
                .foregroundStyle(RenaissanceColors.sepiaInk)
        }
        .padding(.horizontal, isLargeScreen ? 14 : 10)
        .padding(.vertical, isLargeScreen ? 8 : 6)
        .background(
            Capsule()
                .fill(RenaissanceColors.color(for: science).opacity(0.15))
                .overlay(
                    Capsule()
                        .stroke(RenaissanceColors.color(for: science).opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// Simple flow layout for tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func arrangeSubviews(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth && currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            positions.append(CGPoint(x: currentX, y: currentY))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
            maxX = max(maxX, currentX)
        }

        return (CGSize(width: maxX, height: currentY + lineHeight), positions)
    }
}

#Preview("iPhone") {
    BuildingDetailOverlay(
        plot: BuildingPlot(
            id: 1,
            building: Building(
                name: "Aqueduct",
                era: .ancientRome,
                sciences: [.engineering, .mathematics, .physics],
                iconName: "water.waves"
            ),
            isCompleted: false
        ),
        onDismiss: {},
        isLargeScreen: false
    )
}

#Preview("iPad / Mac") {
    BuildingDetailOverlay(
        plot: BuildingPlot(
            id: 1,
            building: Building(
                name: "Aqueduct",
                era: .ancientRome,
                sciences: [.engineering, .mathematics, .physics],
                iconName: "water.waves"
            ),
            isCompleted: false
        ),
        onDismiss: {},
        isLargeScreen: true
    )
}
