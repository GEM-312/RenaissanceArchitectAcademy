import SwiftUI

struct BuildingPlotView: View {
    let plot: BuildingPlot
    var isLargeScreen: Bool = false
    let onTap: () -> Void

    // Adaptive sizing
    private var iconSize: CGFloat { isLargeScreen ? 56 : 40 }
    private var titleSize: CGFloat { isLargeScreen ? 18 : 14 }
    private var badgeSize: CGFloat { isLargeScreen ? 13 : 11 }
    private var cornerRadius: CGFloat { isLargeScreen ? 16 : 12 }

    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Plot background
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(RenaissanceColors.parchment)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(
                                plot.isCompleted ? RenaissanceColors.sageGreen : RenaissanceColors.sepiaInk.opacity(0.3),
                                lineWidth: isLargeScreen ? 3 : 2
                            )
                    )
                    .shadow(color: .black.opacity(0.1), radius: isLargeScreen ? 8 : 4, x: 2, y: 2)

                VStack(spacing: isLargeScreen ? 12 : 8) {
                    // Building icon or placeholder
                    if plot.isCompleted {
                        Image(systemName: plot.building.iconName)
                            .font(.system(size: iconSize))
                            .foregroundStyle(RenaissanceColors.terracotta)
                    } else {
                        Image(systemName: "plus.square.dashed")
                            .font(.system(size: iconSize))
                            .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.4))
                    }

                    // Building name
                    Text(plot.building.name)
                        .font(.custom("Cinzel-Regular", size: titleSize, relativeTo: .caption))
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                        .multilineTextAlignment(.center)

                    // Era badge
                    Text(plot.building.era.rawValue)
                        .font(.custom("EBGaramond-Regular", size: badgeSize, relativeTo: .caption2))
                        .foregroundStyle(RenaissanceColors.renaissanceBlue)
                        .padding(.horizontal, isLargeScreen ? 12 : 8)
                        .padding(.vertical, isLargeScreen ? 4 : 2)
                        .background(
                            Capsule()
                                .fill(RenaissanceColors.renaissanceBlue.opacity(0.1))
                        )

                    // Progress indicator for large screens
                    if isLargeScreen && !plot.isCompleted {
                        Text("Tap to begin challenge")
                            .font(.custom("EBGaramond-Italic", size: 12, relativeTo: .caption2))
                            .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.5))
                    }
                }
                .padding(isLargeScreen ? 20 : 12)
            }
        }
        .buttonStyle(.plain)
        .aspectRatio(1, contentMode: .fit)
        #if os(macOS)
        .onHover { hovering in
            if hovering {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
            }
        }
        #endif
    }
}

#Preview("iPhone") {
    BuildingPlotView(
        plot: BuildingPlot(
            id: 1,
            building: Building(
                name: "Aqueduct",
                era: .ancientRome,
                sciences: [.engineering, .mathematics],
                iconName: "water.waves"
            ),
            isCompleted: false
        ),
        isLargeScreen: false,
        onTap: {}
    )
    .frame(width: 150, height: 150)
    .padding()
}

#Preview("iPad / Mac") {
    BuildingPlotView(
        plot: BuildingPlot(
            id: 1,
            building: Building(
                name: "Aqueduct",
                era: .ancientRome,
                sciences: [.engineering, .mathematics],
                iconName: "water.waves"
            ),
            isCompleted: false
        ),
        isLargeScreen: true,
        onTap: {}
    )
    .frame(width: 250, height: 250)
    .padding()
}
