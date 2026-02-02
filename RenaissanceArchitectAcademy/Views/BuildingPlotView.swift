import SwiftUI

struct BuildingPlotView: View {
    let plot: BuildingPlot
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Plot background
                RoundedRectangle(cornerRadius: 12)
                    .fill(RenaissanceColors.parchment)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                plot.isCompleted ? RenaissanceColors.sageGreen : RenaissanceColors.sepiaInk.opacity(0.3),
                                lineWidth: 2
                            )
                    )
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 2, y: 2)

                VStack(spacing: 8) {
                    // Building icon or placeholder
                    if plot.isCompleted {
                        Image(systemName: plot.building.iconName)
                            .font(.system(size: 40))
                            .foregroundStyle(RenaissanceColors.terracotta)
                    } else {
                        Image(systemName: "plus.square.dashed")
                            .font(.system(size: 40))
                            .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.4))
                    }

                    // Building name
                    Text(plot.building.name)
                        .font(.custom("Cinzel-Regular", size: 14, relativeTo: .caption))
                        .foregroundStyle(RenaissanceColors.sepiaInk)
                        .multilineTextAlignment(.center)

                    // Era badge
                    Text(plot.building.era.rawValue)
                        .font(.custom("EBGaramond-Regular", size: 11, relativeTo: .caption2))
                        .foregroundStyle(RenaissanceColors.renaissanceBlue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(RenaissanceColors.renaissanceBlue.opacity(0.1))
                        )
                }
                .padding()
            }
        }
        .buttonStyle(.plain)
        .aspectRatio(1, contentMode: .fit)
    }
}

#Preview {
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
        onTap: {}
    )
    .frame(width: 200, height: 200)
    .padding()
}
