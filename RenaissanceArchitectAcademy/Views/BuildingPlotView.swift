import SwiftUI

/// Building Plot View - Leonardo's Notebook aesthetic
/// Shows buildings as sketch-to-watercolor transition cards
struct BuildingPlotView: View {
    let plot: BuildingPlot
    var isLargeScreen: Bool = false
    let onTap: () -> Void

    @State private var isHovered = false

    // Adaptive sizing
    private var iconSize: CGFloat { isLargeScreen ? 56 : 40 }
    private var titleSize: CGFloat { isLargeScreen ? 18 : 14 }
    private var badgeSize: CGFloat { isLargeScreen ? 13 : 11 }
    private var cornerRadius: CGFloat { isLargeScreen ? 16 : 12 }

    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Plot background with notebook paper effect
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(RenaissanceColors.parchment)
                    .overlay(
                        // Sketch lines for incomplete buildings
                        Group {
                            if !plot.isCompleted {
                                SketchLinesOverlay(cornerRadius: cornerRadius)
                            }
                        }
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(
                                plot.isCompleted
                                    ? RenaissanceColors.sageGreen
                                    : (isHovered ? RenaissanceColors.ochre : RenaissanceColors.sepiaInk.opacity(0.3)),
                                lineWidth: isLargeScreen ? 3 : 2
                            )
                    )
                    .shadow(
                        color: isHovered
                            ? RenaissanceColors.ochre.opacity(0.2)
                            : RenaissanceColors.sepiaInk.opacity(0.1),
                        radius: isLargeScreen ? 8 : 4,
                        x: 2,
                        y: 2
                    )

                VStack(spacing: isLargeScreen ? 12 : 8) {
                    // Building icon container
                    ZStack {
                        // Background circle for completed buildings
                        if plot.isCompleted {
                            Circle()
                                .fill(RenaissanceColors.terracotta.opacity(0.15))
                                .frame(width: iconSize + 16, height: iconSize + 16)
                        }

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
                    }

                    // Building name
                    Text(plot.building.name)
                        .font(.custom("Cinzel-Regular", size: titleSize, relativeTo: .caption))
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)

                    // Era badge with wax seal style
                    HStack(spacing: 4) {
                        Image(systemName: plot.building.era.iconName)
                            .font(.system(size: badgeSize - 2))

                        Text(plot.building.era.rawValue)
                            .font(.custom("EBGaramond-Regular", size: badgeSize, relativeTo: .caption2))
                    }
                    .foregroundStyle(RenaissanceColors.renaissanceBlue)
                    .padding(.horizontal, isLargeScreen ? 12 : 8)
                    .padding(.vertical, isLargeScreen ? 4 : 2)
                    .background(
                        Capsule()
                            .fill(RenaissanceColors.renaissanceBlue.opacity(0.1))
                    )

                    // Sciences preview (small icons)
                    if isLargeScreen {
                        HStack(spacing: 6) {
                            ForEach(plot.building.sciences.prefix(3), id: \.self) { science in
                                Image(systemName: science.iconName)
                                    .font(.system(size: 12))
                                    .foregroundStyle(RenaissanceColors.color(for: science))
                            }
                            if plot.building.sciences.count > 3 {
                                Text("+\(plot.building.sciences.count - 3)")
                                    .font(.caption2)
                                    .foregroundStyle(RenaissanceColors.stoneGray)
                            }
                        }
                    }

                    // Progress indicator
                    if !plot.isCompleted {
                        Text(isLargeScreen ? "Tap to begin challenge" : "Begin")
                            .font(.custom("EBGaramond-Italic", size: isLargeScreen ? 12 : 10, relativeTo: .caption2))
                            .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.5))
                    } else if isLargeScreen {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.caption2)
                            Text("Completed")
                                .font(.custom("EBGaramond-Regular", size: 12, relativeTo: .caption2))
                        }
                        .foregroundStyle(RenaissanceColors.sageGreen)
                    }
                }
                .padding(isLargeScreen ? 20 : 12)
            }
        }
        .buttonStyle(.plain)
        .aspectRatio(1, contentMode: .fit)
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isHovered)
        #if os(macOS)
        .onHover { hovering in
            isHovered = hovering
            if hovering {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
            }
        }
        #endif
        #if os(iOS)
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            isHovered = pressing
        }, perform: {})
        #endif
    }
}

/// Sketch lines overlay for incomplete buildings
struct SketchLinesOverlay: View {
    let cornerRadius: CGFloat

    var body: some View {
        GeometryReader { geometry in
            Path { path in
                // Diagonal sketch lines
                let spacing: CGFloat = 12
                var offset: CGFloat = -geometry.size.height

                while offset < geometry.size.width + geometry.size.height {
                    path.move(to: CGPoint(x: offset, y: 0))
                    path.addLine(to: CGPoint(x: offset + geometry.size.height, y: geometry.size.height))
                    offset += spacing
                }
            }
            .stroke(RenaissanceColors.blueprintBlue.opacity(0.08), lineWidth: 0.5)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        }
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
