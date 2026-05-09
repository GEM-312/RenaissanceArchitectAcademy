import SwiftUI

// MARK: - Shared Colors for Interactive Visuals

/// Single source of truth for colors used across all 17 InteractiveVisuals files.
/// Building-specific unique colors stay as private lets in each file.
enum IVMaterialColors {
    // Base drawing colors (used by helpers)
    static let gridColor  = RenaissanceColors.warmBrown.opacity(0.06)
    static let sepiaInk   = RenaissanceColors.sepiaInk
    static let waterBlue  = Color(red: 0.35, green: 0.55, blue: 0.75)
    static let dimColor   = Color(red: 0.7, green: 0.35, blue: 0.25)

    // Shared building materials — deduplicated from 17 files.
    // (stoneGray was removed — it had drifted ~0.01 per channel from
    // RenaissanceColors.stoneGray; call sites now reference the canonical
    // token directly.)
    static let marbleWhite = Color(red: 0.92, green: 0.90, blue: 0.88)
    static let leadGray    = Color(red: 0.50, green: 0.52, blue: 0.55)
    static let ironDark    = Color(red: 0.35, green: 0.33, blue: 0.32)
    static let oakBrown    = Color(red: 0.55, green: 0.42, blue: 0.28)
    static let bronzeGold  = Color(red: 0.72, green: 0.55, blue: 0.32)
    static let hotRed      = Color(red: 0.85, green: 0.35, blue: 0.25)
    static let limeTan     = Color(red: 0.88, green: 0.84, blue: 0.76)
    static let cherryRed   = Color(red: 0.80, green: 0.25, blue: 0.20)
    static let poplarLight = Color(red: 0.78, green: 0.72, blue: 0.58)
}


// MARK: - Visual Title

struct IVVisualTitle: View {
    let text: String
    let color: Color
    var body: some View {
        Text(text)
            .font(RenaissanceFont.visualTitle)
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
                context.stroke(path, with: .color(IVMaterialColors.gridColor), lineWidth: 0.5)
            }
            for y in stride(from: CGFloat(0), through: size.height, by: spacing) {
                var path = Path()
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                context.stroke(path, with: .color(IVMaterialColors.gridColor), lineWidth: 0.5)
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
    var height: CGFloat = 340
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
                    .font(RenaissanceFont.bodySmall)
                    .foregroundStyle(IVMaterialColors.sepiaInk.opacity(0.7))
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
                    HStack(spacing: 3) {
                        Image(systemName: "chevron.left").font(.system(size: 13))
                        Text("Back").font(RenaissanceFont.bodySmall)
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
                    .frame(width: 8, height: 8)
            }
            Spacer()
            if currentStep < totalSteps {
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) { currentStep += 1 }
                    SoundManager.shared.play(.tapSoft)
                } label: {
                    HStack(spacing: 3) {
                        Text("Next").font(RenaissanceFont.bodySmall)
                        Image(systemName: "chevron.right").font(.system(size: 13))
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
    var fontSize: CGFloat? = nil  // Optional override; nil = use theme token
    var body: some View {
        Text(text)
            .font(fontSize.map { Font.custom("EBGaramond-SemiBold", size: $0) } ?? RenaissanceFont.ivLabel)
            .foregroundStyle(IVMaterialColors.dimColor)
    }
}

// MARK: - Formula Text

struct IVFormulaText: View {
    let text: String
    var highlighted: Bool = false
    var fontSize: CGFloat? = nil  // Optional override; nil = use theme token
    var body: some View {
        Text(text)
            .font(fontSize.map { Font.custom("EBGaramond-Bold", size: $0) } ?? RenaissanceFont.ivFormula)
            .foregroundStyle(highlighted ? RenaissanceColors.sageGreen : IVMaterialColors.sepiaInk)
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
