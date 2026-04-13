#if DEBUG
import SwiftUI

/// Unified editor controls for ALL SpriteKit scenes.
///
/// Provides toggle, rotate, and nudge buttons. Place in any map view's ZStack.
/// Only compiled in DEBUG builds — never appears in TestFlight or App Store.
struct SceneEditorButtons: View {
    let isActive: Bool
    let onToggle: () -> Void
    let onRotateLeft: () -> Void
    let onRotateRight: () -> Void
    let onNudge: (_ dx: CGFloat, _ dy: CGFloat) -> Void

    var body: some View {
        VStack {
            HStack {
                Spacer()
                VStack(spacing: 8) {
                    // Editor mode toggle
                    Button(action: onToggle) {
                        Text(isActive ? "📐 Editing" : "📐 Editor")
                            .font(.custom("Cinzel-Bold", size: 13))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                (isActive ? Color.red.opacity(0.8) : RenaissanceColors.warmBrown.opacity(0.9))
                            )
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)

                    // Controls (visible when editing)
                    if isActive {
                        VStack(spacing: 4) {
                            // Rotate
                            HStack(spacing: 4) {
                                editorButton("↺") { onRotateLeft() }
                                editorButton("↻") { onRotateRight() }
                            }
                            // Nudge
                            editorButton("▲") { onNudge(0, 5) }
                            HStack(spacing: 4) {
                                editorButton("◀") { onNudge(-5, 0) }
                                editorButton("▶") { onNudge(5, 0) }
                            }
                            editorButton("▼") { onNudge(0, -5) }
                        }
                    }
                }
                .shadow(color: .black.opacity(0.3), radius: 6, y: 3)
                .padding(.trailing, 16)
                .padding(.top, 50)
            }
            Spacer()
        }
        .zIndex(100)
    }

    private func editorButton(_ label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: label.count > 1 ? 14 : 18))
                .frame(width: 36, height: label.count > 1 ? 28 : 32)
                .background(Color.white.opacity(0.9))
                .cornerRadius(6)
        }
        .buttonStyle(.plain)
    }
}
#endif
