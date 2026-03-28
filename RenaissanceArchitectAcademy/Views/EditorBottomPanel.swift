#if DEBUG
import SwiftUI

// MARK: - Editor Bottom Panel

/// Slide-up inspector panel for the Visual Editor.
/// Shows size, spacing, typography, and color controls for the selected element.
struct EditorBottomPanel: View {
    @ObservedObject var editor = VisualEditorState.shared

    @State private var expandedSection: String? = "size"

    var body: some View {
        VStack(spacing: 0) {
            // Drag handle
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.gray.opacity(0.4))
                .frame(width: 36, height: 4)
                .padding(.top, 6)
                .padding(.bottom, 4)

            if let id = editor.selectedId {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 8) {
                        // Element ID header
                        HStack {
                            Image(systemName: "square.dashed")
                                .font(.system(size: 12))
                                .foregroundStyle(.yellow)
                            Text(id)
                                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                                .foregroundStyle(.white)
                            Spacer()
                            Button("Reset") {
                                editor.resetSelected()
                            }
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.orange)
                            .buttonStyle(.plain)
                        }

                        Divider().background(Color.white.opacity(0.2))

                        // Section 1: Size
                        editorSection("Size", icon: "arrow.up.left.and.arrow.down.right", tag: "size") {
                            sizeControls(id: id)
                        }

                        // Section 2: Spacing
                        editorSection("Spacing", icon: "square.resize", tag: "spacing") {
                            spacingControls(id: id)
                        }

                        // Section 3: Typography
                        editorSection("Typography", icon: "textformat.size", tag: "type") {
                            typographyControls(id: id)
                        }

                        // Section 4: Colors
                        editorSection("Colors", icon: "paintpalette", tag: "colors") {
                            colorControls(id: id)
                        }

                        // Copy button
                        Button {
                            editor.copyValues()
                        } label: {
                            HStack {
                                Image(systemName: "doc.on.clipboard")
                                Text("Copy Values to Console")
                            }
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Capsule().fill(.yellow))
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 4)
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 12)
                }
            } else {
                Text("Tap an element to inspect it")
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.5))
                    .padding(.vertical, 16)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .environment(\.colorScheme, .dark)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }

    // MARK: - Collapsible Section

    @ViewBuilder
    private func editorSection<Content: View>(_ title: String, icon: String, tag: String,
                                               @ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 6) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    expandedSection = expandedSection == tag ? nil : tag
                }
            } label: {
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 11))
                        .frame(width: 16)
                    Text(title)
                        .font(.system(size: 12, weight: .semibold))
                    Spacer()
                    Image(systemName: expandedSection == tag ? "chevron.up" : "chevron.down")
                        .font(.system(size: 10))
                }
                .foregroundStyle(.white.opacity(0.8))
            }
            .buttonStyle(.plain)

            if expandedSection == tag {
                content()
                    .padding(.leading, 4)
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Size Controls

    @ViewBuilder
    private func sizeControls(id: String) -> some View {
        let binding = overridesBinding(for: id)

        // Sizing mode
        HStack(spacing: 4) {
            Text("Mode:")
                .font(.system(size: 10))
                .foregroundStyle(.white.opacity(0.5))
            ForEach(SizingMode.allCases, id: \.self) { mode in
                Button {
                    binding.wrappedValue.sizingMode = mode
                } label: {
                    Text(mode.rawValue)
                        .font(.system(size: 10, weight: binding.wrappedValue.sizingMode == mode ? .bold : .regular))
                        .foregroundStyle(binding.wrappedValue.sizingMode == mode ? .yellow : .white.opacity(0.5))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            Capsule().fill(binding.wrappedValue.sizingMode == mode ? Color.yellow.opacity(0.2) : Color.clear)
                        )
                }
                .buttonStyle(.plain)
            }
            Spacer()
        }

        // Width
        editorSlider(label: "W", value: Binding(
            get: { binding.wrappedValue.width ?? 300 },
            set: { binding.wrappedValue.width = $0 }
        ), range: 50...800, display: binding.wrappedValue.width.map { "\(Int($0))pt" } ?? "auto")

        // Height
        editorSlider(label: "H", value: Binding(
            get: { binding.wrappedValue.height ?? 275 },
            set: { binding.wrappedValue.height = $0 }
        ), range: 30...600, display: binding.wrappedValue.height.map { "\(Int($0))pt" } ?? "auto")

        // Rotation
        editorSlider(label: "Rot", value: Binding(
            get: { CGFloat(binding.wrappedValue.rotation) },
            set: { binding.wrappedValue.rotation = Double($0) }
        ), range: -180...180, display: "\(Int(binding.wrappedValue.rotation))°")
    }

    // MARK: - Spacing Controls

    @ViewBuilder
    private func spacingControls(id: String) -> some View {
        let binding = overridesBinding(for: id)

        editorSlider(label: "Pad H", value: binding.paddingH, range: 0...40,
                     display: "\(Int(binding.wrappedValue.paddingH))pt")

        editorSlider(label: "Pad V", value: binding.paddingV, range: 0...40,
                     display: "\(Int(binding.wrappedValue.paddingV))pt")

        // Corner radius
        editorSlider(label: "Radius", value: Binding(
            get: { binding.wrappedValue.cornerRadius ?? 0 },
            set: { binding.wrappedValue.cornerRadius = $0 }
        ), range: 0...30, display: "\(Int(binding.wrappedValue.cornerRadius ?? 0))pt")
    }

    // MARK: - Typography Controls

    @ViewBuilder
    private func typographyControls(id: String) -> some View {
        let binding = overridesBinding(for: id)

        editorSlider(label: "Font", value: Binding(
            get: { binding.wrappedValue.fontSize ?? 14 },
            set: { binding.wrappedValue.fontSize = $0 }
        ), range: 8...32, display: "\(Int(binding.wrappedValue.fontSize ?? 14))pt")

        editorSlider(label: "Line Sp", value: Binding(
            get: { binding.wrappedValue.lineSpacing ?? 0 },
            set: { binding.wrappedValue.lineSpacing = $0 }
        ), range: 0...20, display: "\(Int(binding.wrappedValue.lineSpacing ?? 0))pt")
    }

    // MARK: - Color Controls

    @ViewBuilder
    private func colorControls(id: String) -> some View {
        let binding = overridesBinding(for: id)

        // Color swatches in a grid
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 6), spacing: 4) {
            // "None" option
            Button {
                binding.wrappedValue.colorIndex = nil
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.white.opacity(0.1))
                        .frame(height: 28)
                    if binding.wrappedValue.colorIndex == nil {
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(.yellow, lineWidth: 2)
                            .frame(height: 28)
                    }
                    Text("∅")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.5))
                }
            }
            .buttonStyle(.plain)

            ForEach(0..<EditorPalette.colors.count, id: \.self) { i in
                Button {
                    binding.wrappedValue.colorIndex = i
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(EditorPalette.color(at: i))
                            .frame(height: 28)
                        if binding.wrappedValue.colorIndex == i {
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(.yellow, lineWidth: 2)
                                .frame(height: 28)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }

        // Color name
        if let ci = binding.wrappedValue.colorIndex {
            Text(EditorPalette.name(for: ci))
                .font(.system(size: 10, design: .monospaced))
                .foregroundStyle(.white.opacity(0.5))
        }
    }

    // MARK: - Shared Slider

    private func editorSlider(label: String, value: Binding<CGFloat>, range: ClosedRange<CGFloat>, display: String) -> some View {
        HStack(spacing: 6) {
            Text(label)
                .font(.system(size: 10, design: .monospaced))
                .foregroundStyle(.white.opacity(0.5))
                .frame(width: 44, alignment: .leading)
            Slider(value: value, in: range)
                .tint(.yellow)
            Text(display)
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .foregroundStyle(.yellow)
                .frame(width: 52, alignment: .trailing)
        }
    }

    // MARK: - Binding Helper

    private func overridesBinding(for id: String) -> Binding<ElementOverrides> {
        Binding(
            get: { editor.overrides[id] ?? ElementOverrides() },
            set: { editor.overrides[id] = $0 }
        )
    }
}

// MARK: - Editor Activation Badge

struct EditorBadge: View {
    @ObservedObject var editor = VisualEditorState.shared

    var body: some View {
        if editor.isActive {
            HStack(spacing: 4) {
                Circle()
                    .fill(.red)
                    .frame(width: 6, height: 6)
                Text("EDITOR")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Capsule().fill(.red.opacity(0.8)))
        }
    }
}
#endif
