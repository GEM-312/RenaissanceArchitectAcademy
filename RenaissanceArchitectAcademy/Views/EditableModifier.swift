import SwiftUI

#if DEBUG

// MARK: - Editable View Modifier

/// Makes any view selectable and adjustable in the Visual Editor.
/// In editor mode: shows dashed border, tap to select, applies overrides.
/// Not in editor mode: complete passthrough, zero overhead.
struct EditableModifier: ViewModifier {
    let id: String
    var defaultWidth: CGFloat? = nil
    var defaultHeight: CGFloat? = nil
    var defaultPaddingH: CGFloat = 0
    var defaultPaddingV: CGFloat = 0
    var defaultFontSize: CGFloat? = nil
    var defaultCornerRadius: CGFloat? = nil

    @ObservedObject private var editor = VisualEditorState.shared

    private var isSelected: Bool { editor.selectedId == id }
    private var ov: ElementOverrides { editor.overrides[id] ?? ElementOverrides() }

    func body(content: Content) -> some View {
        if editor.isActive {
            editableContent(content)
        } else {
            content
        }
    }

    @ViewBuilder
    private func editableContent(_ content: Content) -> some View {
        let appliedContent = content
            .applyFontOverride(ov.fontSize)
            .applyLineSpacingOverride(ov.lineSpacing)
            .padding(.horizontal, ov.paddingH)
            .padding(.vertical, ov.paddingV)
            .applySize(width: ov.width, height: ov.height, mode: ov.sizingMode)
            .applyCornerRadius(ov.cornerRadius)
            .applyColorOverlay(ov.colorIndex)
            .rotationEffect(.degrees(ov.rotation))

        appliedContent
            .overlay(
                RoundedRectangle(cornerRadius: ov.cornerRadius ?? 4)
                    .stroke(
                        isSelected ? Color.yellow : Color.blue.opacity(0.4),
                        style: StrokeStyle(lineWidth: isSelected ? 2 : 1, dash: isSelected ? [] : [4, 3])
                    )
            )
            .overlay(alignment: .topLeading) {
                Text(id)
                    .font(.system(size: 7, weight: .medium, design: .monospaced))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 3)
                    .padding(.vertical, 1)
                    .background(Capsule().fill(isSelected ? Color.yellow.opacity(0.8) : Color.blue.opacity(0.5)))
                    .offset(x: 2, y: 2)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                editor.select(id)
            }
            .onAppear {
                // Register defaults
                editor.defaults[id] = ElementDefaults(
                    width: defaultWidth,
                    height: defaultHeight,
                    paddingH: defaultPaddingH,
                    paddingV: defaultPaddingV,
                    fontSize: defaultFontSize,
                    cornerRadius: defaultCornerRadius
                )
            }
    }
}

// MARK: - Size/Color Application Helpers

private extension View {
    @ViewBuilder
    func applySize(width: CGFloat?, height: CGFloat?, mode: SizingMode) -> some View {
        switch mode {
        case .auto:
            if let w = width, let h = height {
                self.frame(width: w, height: h)
            } else if let w = width {
                self.frame(width: w)
            } else if let h = height {
                self.frame(height: h)
            } else {
                self
            }
        case .hug:
            self.fixedSize()
        case .fill:
            self.frame(maxWidth: width ?? .infinity, maxHeight: height ?? .infinity)
        }
    }

    @ViewBuilder
    func applyCornerRadius(_ radius: CGFloat?) -> some View {
        if let r = radius {
            self.clipShape(RoundedRectangle(cornerRadius: r))
        } else {
            self
        }
    }

    @ViewBuilder
    func applyColorOverlay(_ colorIndex: Int?) -> some View {
        if let idx = colorIndex {
            self.background(EditorPalette.color(at: idx).opacity(0.15))
        } else {
            self
        }
    }

    @ViewBuilder
    func applyFontOverride(_ size: CGFloat?) -> some View {
        if let s = size {
            self.font(.custom("EBGaramond-Regular", size: s))
        } else {
            self
        }
    }

    @ViewBuilder
    func applyLineSpacingOverride(_ spacing: CGFloat?) -> some View {
        if let s = spacing {
            self.lineSpacing(s)
        } else {
            self
        }
    }
}

// MARK: - View Extension

extension View {
    /// Make this view editable in the Visual Editor. DEBUG only.
    /// - Parameters:
    ///   - id: Unique identifier (e.g., "card-visual", "lesson-text")
    ///   - width: Default width (nil = auto)
    ///   - height: Default height (nil = auto)
    ///   - paddingH: Default horizontal padding
    ///   - paddingV: Default vertical padding
    func editable(_ id: String,
                  width: CGFloat? = nil,
                  height: CGFloat? = nil,
                  paddingH: CGFloat = 0,
                  paddingV: CGFloat = 0,
                  fontSize: CGFloat? = nil,
                  cornerRadius: CGFloat? = nil) -> some View {
        modifier(EditableModifier(
            id: id,
            defaultWidth: width,
            defaultHeight: height,
            defaultPaddingH: paddingH,
            defaultPaddingV: paddingV,
            defaultFontSize: fontSize,
            defaultCornerRadius: cornerRadius
        ))
    }
}
#else
// Release builds: .editable() is a no-op
extension View {
    func editable(_ id: String,
                  width: CGFloat? = nil,
                  height: CGFloat? = nil,
                  paddingH: CGFloat = 0,
                  paddingV: CGFloat = 0,
                  fontSize: CGFloat? = nil,
                  cornerRadius: CGFloat? = nil) -> some View {
        self
    }
}
#endif
