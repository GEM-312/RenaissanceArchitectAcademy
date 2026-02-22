import SwiftUI

/// Router that selects the correct animated math diagram based on MathVisualType
struct MathVisualView: View {
    let visual: LessonMathVisual
    @Binding var currentStep: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Title
            Text(visual.title)
                .font(.custom("Cinzel-Bold", size: 22))
                .foregroundStyle(RenaissanceColors.sepiaInk)

            // Science badge
            HStack(spacing: 4) {
                if let imageName = visual.science.customImageName {
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                        .clipShape(RoundedRectangle(cornerRadius: 3))
                } else {
                    Image(systemName: visual.science.sfSymbolName)
                        .font(.system(size: 11))
                        .foregroundStyle(RenaissanceColors.warmBrown)
                }
                Text(visual.science.rawValue)
                    .font(.custom("EBGaramond-Regular", size: 11))
                    .foregroundStyle(RenaissanceColors.sepiaInk)
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(
                Capsule()
                    .fill(RenaissanceColors.ochre.opacity(0.1))
            )

            // Diagram
            switch visual.type {
            case .aqueductGradient:
                GradientSlopeVisual(currentStep: $currentStep)
            case .aqueductFlowRate:
                FlowRateVisual(currentStep: $currentStep)
            }

            // Caption
            Text(visual.caption)
                .font(.custom("EBGaramond-Italic", size: 14))
                .foregroundStyle(RenaissanceColors.stoneGray)
                .lineSpacing(4)

            // Step dots + Next Step button
            HStack {
                // Step dots
                HStack(spacing: 6) {
                    ForEach(1...visual.totalSteps, id: \.self) { step in
                        Circle()
                            .fill(step <= currentStep
                                  ? RenaissanceColors.blueprintBlue
                                  : RenaissanceColors.blueprintBlue.opacity(0.2))
                            .frame(width: 8, height: 8)
                    }
                }

                Spacer()

                // Next Step button
                if currentStep < visual.totalSteps {
                    Button {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            currentStep += 1
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Text("Next Step")
                                .font(.custom("Cinzel-Bold", size: 14))
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundStyle(RenaissanceColors.blueprintBlue)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(RenaissanceColors.blueprintBlue.opacity(0.1))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(RenaissanceColors.blueprintBlue.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                } else {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(RenaissanceColors.sageGreen)
                        Text("Complete")
                            .font(.custom("Cinzel-Bold", size: 14))
                            .foregroundStyle(RenaissanceColors.sageGreen)
                    }
                }
            }
        }
    }
}
