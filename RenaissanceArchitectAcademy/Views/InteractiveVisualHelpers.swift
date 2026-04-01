import SwiftUI

// MARK: - Shared Colors for Interactive Visuals

let ivGridColor = Color.brown.opacity(0.06)
let ivSepiaInk = Color(red: 0.29, green: 0.25, blue: 0.21)
let ivWaterBlue = Color(red: 0.35, green: 0.55, blue: 0.75)
let ivDimColor = Color(red: 0.7, green: 0.35, blue: 0.25)

// MARK: - Visual Title

struct IVVisualTitle: View {
    let text: String
    let color: Color
    var body: some View {
        Text(text)
            .font(.custom("Cinzel-Bold", size: 12))
            .tracking(1)
            .foregroundStyle(color)
    }
}

// MARK: - Blueprint Grid

struct IVBlueprintGrid: View {
    var body: some View {
        Canvas { context, size in
            let spacing: CGFloat = 15
            for x in stride(from: CGFloat(0), through: size.width, by: spacing) {
                var path = Path()
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
                context.stroke(path, with: .color(ivGridColor), lineWidth: 0.5)
            }
            for y in stride(from: CGFloat(0), through: size.height, by: spacing) {
                var path = Path()
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                context.stroke(path, with: .color(ivGridColor), lineWidth: 0.5)
            }
        }
    }
}

// MARK: - Teaching Container

struct IVTeachingContainer<Content: View>: View {
    let title: String
    let color: Color
    let totalSteps: Int
    @Binding var step: Int
    let stepLabel: String
    var height: CGFloat = 275
    @ViewBuilder let content: () -> Content

    var body: some View {
        ZStack(alignment: .bottom) {
            // Full-size canvas
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(RenaissanceColors.parchment)
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(color.opacity(0.2), lineWidth: 1)
                IVBlueprintGrid()
                content()
                    .padding(.horizontal, 10)
                    .padding(.top, 8)
                    .padding(.bottom, 42)
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))

            // Step controls + label overlaid at bottom
            VStack(spacing: 2) {
                IVStepControls(totalSteps: totalSteps, currentStep: $step, color: color)
                    .padding(.horizontal, 8)
                Text(stepLabel)
                    .font(.custom("EBGaramond-Regular", size: 10))
                    .foregroundStyle(ivSepiaInk.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(.horizontal, 12)
            }
            .padding(.bottom, 4)
            .background(
                LinearGradient(colors: [RenaissanceColors.parchment.opacity(0), RenaissanceColors.parchment],
                               startPoint: .top, endPoint: .bottom)
                    .frame(height: 50)
                    .offset(y: -10)
            )
        }
        .frame(height: height)
    }
}

// MARK: - Step Controls

struct IVStepControls: View {
    let totalSteps: Int
    @Binding var currentStep: Int
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            if currentStep > 1 {
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) { currentStep -= 1 }
                    SoundManager.shared.play(.tapSoft)
                } label: {
                    HStack(spacing: 2) {
                        Image(systemName: "chevron.left").font(.system(size: 9))
                        Text("Back").font(.custom("EBGaramond-Regular", size: 11))
                    }
                    .foregroundStyle(color.opacity(0.6))
                }
                .buttonStyle(.plain)
            } else {
                Spacer().frame(width: 40)
            }
            Spacer()
            ForEach(1...totalSteps, id: \.self) { s in
                Circle()
                    .fill(s <= currentStep ? color : color.opacity(0.2))
                    .frame(width: 5, height: 5)
            }
            Spacer()
            if currentStep < totalSteps {
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) { currentStep += 1 }
                    SoundManager.shared.play(.tapSoft)
                } label: {
                    HStack(spacing: 2) {
                        Text("Next").font(.custom("EBGaramond-Regular", size: 11))
                        Image(systemName: "chevron.right").font(.system(size: 9))
                    }
                    .foregroundStyle(color)
                }
                .buttonStyle(.plain)
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(RenaissanceColors.sageGreen)
                    .font(.system(size: 14))
            }
        }
    }
}

// MARK: - Dimension Label

struct IVDimLabel: View {
    let text: String
    var fontSize: CGFloat = 11
    var body: some View {
        Text(text)
            .font(.custom("EBGaramond-SemiBold", size: fontSize))
            .foregroundStyle(ivDimColor)
    }
}

// MARK: - Formula Text

struct IVFormulaText: View {
    let text: String
    var highlighted: Bool = false
    var fontSize: CGFloat = 14
    var body: some View {
        Text(text)
            .font(.custom("EBGaramond-Bold", size: fontSize))
            .foregroundStyle(highlighted ? RenaissanceColors.sageGreen : ivSepiaInk)
    }
}

// MARK: - Dimension Line Shape

/// Draws a dimension line with perpendicular end ticks
struct IVDimLine: Shape {
    let from: CGPoint
    let to: CGPoint
    let tickSize: CGFloat
    init(from: CGPoint, to: CGPoint, tickSize: CGFloat = 3) {
        self.from = from; self.to = to; self.tickSize = tickSize
    }
    func path(in rect: CGRect) -> Path {
        Path { p in
            p.move(to: from)
            p.addLine(to: to)
            let horiz = abs(to.y - from.y) < abs(to.x - from.x)
            if horiz {
                p.move(to: CGPoint(x: from.x, y: from.y - tickSize))
                p.addLine(to: CGPoint(x: from.x, y: from.y + tickSize))
                p.move(to: CGPoint(x: to.x, y: to.y - tickSize))
                p.addLine(to: CGPoint(x: to.x, y: to.y + tickSize))
            } else {
                p.move(to: CGPoint(x: from.x - tickSize, y: from.y))
                p.addLine(to: CGPoint(x: from.x + tickSize, y: from.y))
                p.move(to: CGPoint(x: to.x - tickSize, y: to.y))
                p.addLine(to: CGPoint(x: to.x + tickSize, y: to.y))
            }
        }
    }
}
