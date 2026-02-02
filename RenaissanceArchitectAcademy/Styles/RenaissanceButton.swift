import SwiftUI

struct RenaissanceButton: View {
    let title: String
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.custom("Cinzel-Regular", size: 18, relativeTo: .body))
                .foregroundStyle(RenaissanceColors.parchment)
                .padding(.horizontal, 32)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(RenaissanceColors.sepiaInk)
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

#Preview {
    VStack(spacing: 20) {
        RenaissanceButton(title: "Begin Journey", action: {})
        RenaissanceButton(title: "Continue", action: {})
        RenaissanceButton(title: "Codex", action: {})
    }
    .padding()
    .background(RenaissanceColors.parchment)
}
