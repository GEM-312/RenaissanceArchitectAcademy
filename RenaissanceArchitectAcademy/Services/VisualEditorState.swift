#if DEBUG
import SwiftUI

// MARK: - Visual Editor State

/// Singleton that manages the in-app layout inspector.
/// Tracks which element is selected and stores per-element property overrides.
/// DEBUG only — stripped from release builds.
@MainActor
class VisualEditorState: ObservableObject {
    static let shared = VisualEditorState()

    @Published var isActive: Bool = false
    @Published var selectedId: String? = nil
    @Published var overrides: [String: ElementOverrides] = [:]

    /// All registered element IDs with their default values
    @Published var defaults: [String: ElementDefaults] = [:]

    func toggle() {
        isActive.toggle()
        if !isActive {
            selectedId = nil
        }
    }

    func select(_ id: String) {
        selectedId = id
        // Initialize overrides from defaults if not yet set
        if overrides[id] == nil, let def = defaults[id] {
            overrides[id] = ElementOverrides(
                width: def.width,
                height: def.height,
                paddingH: def.paddingH,
                paddingV: def.paddingV,
                fontSize: def.fontSize,
                lineSpacing: def.lineSpacing,
                cornerRadius: def.cornerRadius
            )
        }
    }

    func deselect() {
        selectedId = nil
    }

    func resetSelected() {
        guard let id = selectedId, let def = defaults[id] else { return }
        overrides[id] = ElementOverrides(
            width: def.width,
            height: def.height,
            paddingH: def.paddingH,
            paddingV: def.paddingV,
            fontSize: def.fontSize,
            lineSpacing: def.lineSpacing,
            cornerRadius: def.cornerRadius
        )
    }

    func copyValues() {
        guard let id = selectedId, let ov = overrides[id] else { return }
        let def = defaults[id]
        print("━━━ VISUAL EDITOR VALUES ━━━")
        print("Element: \"\(id)\"")
        if let w = ov.width {
            let was = def?.width.map { " (was \(Int($0))pt)" } ?? ""
            print("  width: \(Int(w))pt\(was)")
        } else {
            print("  width: auto")
        }
        if let h = ov.height {
            let was = def?.height.map { " (was \(Int($0))pt)" } ?? ""
            print("  height: \(Int(h))pt\(was)")
        } else {
            print("  height: auto")
        }
        print("  sizingMode: \(ov.sizingMode)")
        print("  paddingH: \(Int(ov.paddingH))pt")
        print("  paddingV: \(Int(ov.paddingV))pt")
        if let fs = ov.fontSize { print("  fontSize: \(Int(fs))pt") }
        if let ls = ov.lineSpacing { print("  lineSpacing: \(Int(ls))pt") }
        if let cr = ov.cornerRadius { print("  cornerRadius: \(Int(cr))pt") }
        if let ci = ov.colorIndex { print("  colorIndex: \(ci) (\(EditorPalette.name(for: ci)))") }
        if ov.rotation != 0 { print("  rotation: \(Int(ov.rotation))°") }
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    }
}

// MARK: - Element Overrides (current adjusted values)

struct ElementOverrides {
    var width: CGFloat? = nil
    var height: CGFloat? = nil
    var sizingMode: SizingMode = .auto
    var paddingH: CGFloat = 0
    var paddingV: CGFloat = 0
    var fontSize: CGFloat? = nil
    var lineSpacing: CGFloat? = nil
    var cornerRadius: CGFloat? = nil
    var colorIndex: Int? = nil
    var rotation: Double = 0
}

enum SizingMode: String, CaseIterable {
    case auto = "Auto"
    case hug = "Hug"
    case fill = "Fill"
}

// MARK: - Element Defaults (original values before editing)

struct ElementDefaults {
    var width: CGFloat? = nil
    var height: CGFloat? = nil
    var paddingH: CGFloat = 0
    var paddingV: CGFloat = 0
    var fontSize: CGFloat? = nil
    var lineSpacing: CGFloat? = nil
    var cornerRadius: CGFloat? = nil
}

// MARK: - Theme Color Palette for Editor

enum EditorPalette {
    static let colors: [(String, Color)] = [
        ("parchment", RenaissanceColors.parchment),
        ("sepiaInk", RenaissanceColors.sepiaInk),
        ("terracotta", RenaissanceColors.terracotta),
        ("ochre", RenaissanceColors.ochre),
        ("renaissanceBlue", RenaissanceColors.renaissanceBlue),
        ("sageGreen", RenaissanceColors.sageGreen),
        ("deepTeal", RenaissanceColors.deepTeal),
        ("warmBrown", RenaissanceColors.warmBrown),
        ("goldSuccess", RenaissanceColors.goldSuccess),
        ("errorRed", RenaissanceColors.errorRed),
        ("furnaceOrange", RenaissanceColors.furnaceOrange),
        ("stoneGray", RenaissanceColors.stoneGray),
    ]

    static func color(at index: Int) -> Color {
        guard index >= 0 && index < colors.count else { return .clear }
        return colors[index].1
    }

    static func name(for index: Int) -> String {
        guard index >= 0 && index < colors.count else { return "none" }
        return colors[index].0
    }
}
#endif
