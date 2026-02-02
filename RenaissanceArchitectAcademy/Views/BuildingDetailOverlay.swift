import SwiftUI

struct BuildingDetailOverlay: View {
    let plot: BuildingPlot
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture(perform: onDismiss)

            // Detail card
            VStack(spacing: 20) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(plot.building.name)
                            .font(.custom("Cinzel-Bold", size: 28, relativeTo: .title))
                            .foregroundStyle(RenaissanceColors.sepiaInk)

                        Text(plot.building.era.rawValue)
                            .font(.custom("EBGaramond-Italic", size: 16, relativeTo: .subheadline))
                            .foregroundStyle(RenaissanceColors.renaissanceBlue)
                    }

                    Spacer()

                    Button(action: onDismiss) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.5))
                    }
                }

                Divider()

                // Sciences involved
                VStack(alignment: .leading, spacing: 12) {
                    Text("Sciences Required")
                        .font(.custom("Cinzel-Regular", size: 14, relativeTo: .caption))
                        .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))

                    FlowLayout(spacing: 8) {
                        ForEach(plot.building.sciences, id: \.self) { science in
                            ScienceBadge(science: science)
                        }
                    }
                }

                Spacer()

                // Action button
                RenaissanceButton(
                    title: plot.isCompleted ? "Review Challenge" : "Begin Challenge",
                    action: {}
                )
            }
            .padding(24)
            .frame(maxWidth: 500, maxHeight: 400)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(RenaissanceColors.parchment)
                    .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
            )
            .padding(40)
        }
    }
}

struct ScienceBadge: View {
    let science: Science

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: science.iconName)
                .font(.caption)
            Text(science.rawValue)
                .font(.custom("EBGaramond-Regular", size: 13, relativeTo: .caption))
        }
        .foregroundStyle(RenaissanceColors.sepiaInk)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(RenaissanceColors.ochre.opacity(0.2))
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

#Preview {
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
        onDismiss: {}
    )
}
