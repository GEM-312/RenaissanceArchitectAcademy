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
                // Solid ochre background for cards
                Rectangle()
                    .fill(RenaissanceColors.parchment)
                Rectangle()
                    .fill(RenaissanceColors.ochre.opacity(0.1))

                // Engineering grid for incomplete buildings
                if !plot.isCompleted {
                    SketchLinesOverlay(cornerRadius: 2)
                }

                // Engineering blueprint border
                EngineeringCardBorder(
                    isCompleted: plot.isCompleted,
                    isHovered: isHovered
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
                            // Engineering-style placeholder
                            Image(systemName: "square.dashed")
                                .font(.system(size: iconSize, weight: .ultraLight))
                                .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.25))
                                .overlay(
                                    Image(systemName: "plus")
                                        .font(.system(size: iconSize * 0.4, weight: .ultraLight))
                                        .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.2))
                                )
                        }
                    }

                    // Building name
                    Text(plot.building.name)
                        .font(.custom("EBGaramond-Italic", size: titleSize, relativeTo: .caption))
                        .tracking(1)
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

/// Engineering grid overlay for cards
struct SketchLinesOverlay: View {
    let cornerRadius: CGFloat

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Main grid lines
                Path { path in
                    let spacing: CGFloat = 15

                    // Vertical lines
                    var x: CGFloat = spacing
                    while x < geometry.size.width {
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: geometry.size.height))
                        x += spacing
                    }

                    // Horizontal lines
                    var y: CGFloat = spacing
                    while y < geometry.size.height {
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                        y += spacing
                    }
                }
                .stroke(RenaissanceColors.sepiaInk.opacity(0.06), lineWidth: 0.5)

                // Major grid lines (every 4th line)
                Path { path in
                    let spacing: CGFloat = 60

                    // Vertical major lines
                    var x: CGFloat = spacing
                    while x < geometry.size.width {
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: geometry.size.height))
                        x += spacing
                    }

                    // Horizontal major lines
                    var y: CGFloat = spacing
                    while y < geometry.size.height {
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                        y += spacing
                    }
                }
                .stroke(RenaissanceColors.sepiaInk.opacity(0.1), lineWidth: 0.5)
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        }
    }
}

/// Engineering/architectural blueprint style border for cards
struct EngineeringCardBorder: View {
    var isCompleted: Bool = false
    var isHovered: Bool = false

    private var borderColor: Color {
        if isCompleted {
            return RenaissanceColors.sageGreen
        } else if isHovered {
            return RenaissanceColors.ochre
        } else {
            return RenaissanceColors.sepiaInk
        }
    }

    private var borderOpacity: Double {
        isCompleted || isHovered ? 0.7 : 0.5
    }

    var body: some View {
        ZStack {
            // Outer rectangle - main border
            RoundedRectangle(cornerRadius: 2)
                .stroke(borderColor.opacity(borderOpacity), lineWidth: 1)
                .padding(2)

            // Inner rectangle - double line effect
            RoundedRectangle(cornerRadius: 1)
                .stroke(borderColor.opacity(borderOpacity * 0.6), lineWidth: 0.5)
                .padding(5)
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
