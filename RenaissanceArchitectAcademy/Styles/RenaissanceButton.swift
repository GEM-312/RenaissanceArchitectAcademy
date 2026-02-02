import SwiftUI

/// Renaissance-styled button with wax seal accent
/// Leonardo's Notebook aesthetic - aged parchment and sepia ink
struct RenaissanceButton: View {
    let title: String
    var icon: String? = nil
    let action: () -> Void

    @State private var isPressed = false
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var buttonWidth: CGFloat {
        horizontalSizeClass == .regular ? 280 : 240
    }

    var body: some View {
        Button(action: {
            Task { @MainActor in
                SoundManager.shared.play(.buttonTap)
            }
            action()
        }) {
            HStack(spacing: 12) {
                // Optional wax seal icon
                if let icon = icon {
                    ZStack {
                        Circle()
                            .fill(RenaissanceColors.terracotta)
                            .frame(width: 28, height: 28)

                        Image(systemName: icon)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(RenaissanceColors.parchment)
                    }
                }

                Text(title)
                    .font(.custom("Cinzel-Regular", size: 18, relativeTo: .body))
                    .foregroundStyle(RenaissanceColors.parchment)
            }
            .frame(width: buttonWidth)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(
                ZStack {
                    // Main button background
                    RoundedRectangle(cornerRadius: 8)
                        .fill(RenaissanceColors.sepiaInk)

                    // Subtle border for depth
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(RenaissanceColors.ochre.opacity(0.3), lineWidth: 1)
                }
                .shadow(
                    color: RenaissanceColors.sepiaInk.opacity(0.3),
                    radius: isPressed ? 2 : 4,
                    x: 0,
                    y: isPressed ? 1 : 3
                )
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

/// Secondary button style for less prominent actions
struct RenaissanceSecondaryButton: View {
    let title: String
    var icon: String? = nil
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: {
            Task { @MainActor in
                SoundManager.shared.play(.buttonTap)
            }
            action()
        }) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.body)
                }
                Text(title)
                    .font(.custom("Cinzel-Regular", size: 16, relativeTo: .body))
            }
            .foregroundStyle(RenaissanceColors.sepiaInk)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(RenaissanceColors.sepiaInk.opacity(0.5), lineWidth: 1.5)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(isHovered ? RenaissanceColors.ochre.opacity(0.1) : Color.clear)
                    )
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
    VStack(spacing: 20) {
        RenaissanceButton(title: "Begin Journey", icon: "map.fill", action: {})
        RenaissanceButton(title: "Continue", icon: "book.fill", action: {})
        RenaissanceButton(title: "Codex", action: {})

        Divider()

        RenaissanceSecondaryButton(title: "Settings", icon: "gearshape", action: {})
        RenaissanceSecondaryButton(title: "Back", action: {})
    }
    .padding(40)
    .background(RenaissanceColors.parchment)
}
