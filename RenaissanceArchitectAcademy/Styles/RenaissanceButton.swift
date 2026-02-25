import SwiftUI

/// Renaissance-styled button with engineering blueprint sketch border
/// Leonardo's Notebook aesthetic - architectural drawing style
struct RenaissanceButton: View {
    let title: String
    let action: () -> Void

    @State private var isPressed = false
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var buttonWidth: CGFloat {
        horizontalSizeClass == .regular ? 280 : 240
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.custom("EBGaramond-Regular", size: 20, relativeTo: .body))
                .tracking(2)
                .foregroundStyle(RenaissanceColors.sepiaInk)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(RenaissanceColors.ochre.opacity(0.25), lineWidth: 1)
                )
                .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .buttonStyle(.plain)
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

/// Engineering/architectural blueprint style border
struct EngineeringBorder: View {
    var body: some View {
        ZStack {
            // Outer rectangle - main border
            RoundedRectangle(cornerRadius: 2)
                .stroke(RenaissanceColors.sepiaInk.opacity(0.6), lineWidth: 1)
                .padding(2)

            // Inner rectangle - double line effect
            RoundedRectangle(cornerRadius: 1)
                .stroke(RenaissanceColors.sepiaInk.opacity(0.35), lineWidth: 0.5)
                .padding(5)
        }
    }
}

/// Dimension/measurement lines outside the button - engineering style
struct DimensionLines: View {
    var body: some View {
        GeometryReader { geo in
            let offset: CGFloat = 10
            let arrowSize: CGFloat = 4

            // Top dimension line with arrows
            Path { path in
                let y = -offset
                // Left arrow
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: arrowSize, y: y - arrowSize/2))
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: arrowSize, y: y + arrowSize/2))
                // Line
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: geo.size.width * 0.35, y: y))
                path.move(to: CGPoint(x: geo.size.width * 0.65, y: y))
                path.addLine(to: CGPoint(x: geo.size.width, y: y))
                // Right arrow
                path.move(to: CGPoint(x: geo.size.width, y: y))
                path.addLine(to: CGPoint(x: geo.size.width - arrowSize, y: y - arrowSize/2))
                path.move(to: CGPoint(x: geo.size.width, y: y))
                path.addLine(to: CGPoint(x: geo.size.width - arrowSize, y: y + arrowSize/2))
                // Vertical ticks at ends
                path.move(to: CGPoint(x: 0, y: y - 3))
                path.addLine(to: CGPoint(x: 0, y: y + 3))
                path.move(to: CGPoint(x: geo.size.width, y: y - 3))
                path.addLine(to: CGPoint(x: geo.size.width, y: y + 3))
            }
            .stroke(RenaissanceColors.sepiaInk.opacity(0.4), lineWidth: 0.8)

            // Right dimension line with arrows
            Path { path in
                let x = geo.size.width + offset
                // Top arrow
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x - arrowSize/2, y: arrowSize))
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x + arrowSize/2, y: arrowSize))
                // Line
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: geo.size.height * 0.3))
                path.move(to: CGPoint(x: x, y: geo.size.height * 0.7))
                path.addLine(to: CGPoint(x: x, y: geo.size.height))
                // Bottom arrow
                path.move(to: CGPoint(x: x, y: geo.size.height))
                path.addLine(to: CGPoint(x: x - arrowSize/2, y: geo.size.height - arrowSize))
                path.move(to: CGPoint(x: x, y: geo.size.height))
                path.addLine(to: CGPoint(x: x + arrowSize/2, y: geo.size.height - arrowSize))
                // Horizontal ticks at ends
                path.move(to: CGPoint(x: x - 3, y: 0))
                path.addLine(to: CGPoint(x: x + 3, y: 0))
                path.move(to: CGPoint(x: x - 3, y: geo.size.height))
                path.addLine(to: CGPoint(x: x + 3, y: geo.size.height))
            }
            .stroke(RenaissanceColors.sepiaInk.opacity(0.4), lineWidth: 0.8)
        }
    }
}

/// Secondary button style for less prominent actions
struct RenaissanceSecondaryButton: View {
    let title: String
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.custom("EBGaramond-Regular", size: 18, relativeTo: .body))
                .tracking(2)
            .foregroundStyle(RenaissanceColors.sepiaInk)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(RenaissanceColors.sepiaInk.opacity(0.5), lineWidth: 0.8)
                        .padding(2)
                }
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
    }
}

#Preview {
    VStack(spacing: 30) {
        RenaissanceButton(title: "Begin Journey", action: {})
        RenaissanceButton(title: "Continue", action: {})
        RenaissanceButton(title: "Codex", action: {})

        Divider()

        RenaissanceSecondaryButton(title: "Settings", action: {})
        RenaissanceSecondaryButton(title: "Back", action: {})
    }
    .padding(40)
    .background(RenaissanceColors.parchment)
}
