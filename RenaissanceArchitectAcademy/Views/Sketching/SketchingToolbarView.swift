import SwiftUI

/// Shared toolbar for all sketching phase views
/// Renaissance blueprint aesthetic with tool selection
struct SketchingToolbarView: View {
    @Binding var selectedTool: SketchingTool
    let onUndo: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            ForEach(SketchingTool.allCases, id: \.self) { tool in
                if tool == .undo {
                    // Undo is a button, not a toggle
                    Button(action: onUndo) {
                        toolContent(tool, isSelected: false)
                    }
                    .buttonStyle(.plain)
                } else {
                    Button {
                        selectedTool = tool
                    } label: {
                        toolContent(tool, isSelected: selectedTool == tool)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(RenaissanceColors.parchment)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(RenaissanceColors.sepiaInk.opacity(0.3), lineWidth: 1)
                )
        )
    }

    private func toolContent(_ tool: SketchingTool, isSelected: Bool) -> some View {
        VStack(spacing: 4) {
            Image(systemName: tool.iconName)
                .font(.custom("Mulish-Light", size: 18, relativeTo: .body))
                .foregroundStyle(isSelected ? RenaissanceColors.renaissanceBlue : RenaissanceColors.sepiaInk.opacity(0.6))
                .frame(width: 36, height: 36)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? RenaissanceColors.renaissanceBlue.opacity(0.15) : Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(isSelected ? RenaissanceColors.renaissanceBlue.opacity(0.4) : Color.clear, lineWidth: 1)
                        )
                )

            Text(tool.rawValue)
                .font(.custom("Mulish-Light", size: 10, relativeTo: .caption2))
                .foregroundStyle(isSelected ? RenaissanceColors.renaissanceBlue : RenaissanceColors.sepiaInk.opacity(0.5))
        }
    }
}

#Preview {
    SketchingToolbarView(
        selectedTool: .constant(.wall),
        onUndo: {}
    )
    .padding()
    .background(RenaissanceColors.parchment)
}
