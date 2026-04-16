import SwiftUI

// MARK: - 1. Typography Tokens

enum RenaissanceFont {
    // Titles (Cinzel)
    static let hero        = Font.custom("Cinzel-Bold", size: 36, relativeTo: .largeTitle)
    static let largeTitle  = Font.custom("Cinzel-Bold", size: 32, relativeTo: .largeTitle)
    static let title       = Font.custom("Cinzel-Bold", size: 26, relativeTo: .title)
    static let title2      = Font.custom("Cinzel-Regular", size: 22, relativeTo: .title2)
    static let title3      = Font.custom("Cinzel-Regular", size: 18, relativeTo: .title3)
    static let cardTitle   = Font.custom("Cinzel-Bold", size: 15, relativeTo: .headline)
    static let visualTitle = Font.custom("Cinzel-Bold", size: 16, relativeTo: .headline)
    static let title2Bold  = Font.custom("Cinzel-Bold", size: 22, relativeTo: .title2)

    // Body (EBGaramond)
    static let bodyLarge   = Font.custom("EBGaramond-Regular", size: 19, relativeTo: .body)
    static let body        = Font.custom("EBGaramond-Regular", size: 17, relativeTo: .body)
    static let bodySemibold = Font.custom("EBGaramond-SemiBold", size: 17, relativeTo: .body)
    static let bodyMedium  = Font.custom("EBGaramond-Regular", size: 16, relativeTo: .body)
    static let bodySmall   = Font.custom("EBGaramond-Regular", size: 15, relativeTo: .body)
    static let caption     = Font.custom("EBGaramond-Regular", size: 13, relativeTo: .caption)
    static let captionSmall = Font.custom("EBGaramond-Regular", size: 11, relativeTo: .caption2)
    static let footnote     = Font.custom("EBGaramond-Regular", size: 14, relativeTo: .caption)
    static let footnoteSmall = Font.custom("EBGaramond-Regular", size: 12, relativeTo: .caption2)
    static let italic      = Font.custom("EBGaramond-Italic", size: 17, relativeTo: .body)
    static let italicSmall = Font.custom("EBGaramond-Italic", size: 15, relativeTo: .body)

    // Buttons (EBGaramond-SemiBold)
    static let button      = Font.custom("EBGaramond-SemiBold", size: 18, relativeTo: .body)
    static let buttonSmall = Font.custom("EBGaramond-SemiBold", size: 15, relativeTo: .body)

    // Special
    static let tagline     = Font.custom("PetitFormalScript-Regular", size: 20, relativeTo: .title3)
    static let dialogTitle = Font.custom("EBGaramond-SemiBold", size: 22, relativeTo: .title2)
    static let dialogSubtitle = Font.custom("EBGaramond-Regular", size: 14, relativeTo: .caption)
}

// MARK: - 2. Letter Spacing (Tracking)

enum Tracking {
    static let body: CGFloat     = 0.15
    static let label: CGFloat    = 1.0
    static let button: CGFloat   = 2.0
}

// MARK: - 3. Line Spacing

enum LineHeight {
    static let tight: CGFloat    = 2
    static let normal: CGFloat   = 3
    static let relaxed: CGFloat  = 5
    static let heading: CGFloat  = 6
}

// MARK: - 4. Spacing Scale (4pt base grid)

enum Spacing {
    static let xxs: CGFloat  = 4
    static let xs:  CGFloat  = 8
    static let sm:  CGFloat  = 12
    static let md:  CGFloat  = 16
    static let lg:  CGFloat  = 20
    static let xl:  CGFloat  = 24
    static let xxl: CGFloat  = 32
    static let xxxl: CGFloat = 40

    // Dialog-specific
    static let dialogPadding: CGFloat = 24
    static let dialogMargin: CGFloat  = 32
    static let dialogVSpacing: CGFloat = 16
}

// MARK: - 5. Corner Radius

enum CornerRadius {
    static let sm: CGFloat  = 8
    static let md: CGFloat  = 12
    static let lg: CGFloat  = 16
    static let xl: CGFloat  = 20
}

// MARK: - 6. Shadow Presets

enum RenaissanceShadow {
    case card
    case elevated
    case modal
    case glow(Color)

    var color: Color {
        switch self {
        case .card:         return .black.opacity(0.08)
        case .elevated:     return .black.opacity(0.12)
        case .modal:        return .black.opacity(0.15)
        case .glow(let c):  return c.opacity(0.4)
        }
    }

    var radius: CGFloat {
        switch self {
        case .card:     return 4
        case .elevated: return 8
        case .modal:    return 12
        case .glow:     return 8
        }
    }

    var y: CGFloat {
        switch self {
        case .card:     return 2
        case .elevated: return 4
        case .modal:    return 6
        case .glow:     return 0
        }
    }
}

struct RenaissanceShadowModifier: ViewModifier {
    let shadow: RenaissanceShadow

    func body(content: Content) -> some View {
        content.shadow(color: shadow.color, radius: shadow.radius, y: shadow.y)
    }
}

extension View {
    func renaissanceShadow(_ shadow: RenaissanceShadow) -> some View {
        modifier(RenaissanceShadowModifier(shadow: shadow))
    }
}

// MARK: - 7. Text Hierarchy (Opacity)

enum TextEmphasis {
    static let primary: Double   = 1.0
    static let secondary: Double = 0.7
    static let tertiary: Double  = 0.5
    static let faint: Double     = 0.3
}

// MARK: - 8. Dialog/Overlay MaxWidth

enum DialogWidth {
    static let compact: CGFloat  = 280
    static let standard: CGFloat = 480
    static let wide: CGFloat     = 520
    static let full: CGFloat     = 600
}

// MARK: - Adaptive Width (iPhone vs iPad/Mac)

/// On compact (iPhone), dialog cards expand to fill available width.
/// On regular (iPad/Mac), they stay at a fixed max width.
struct AdaptiveWidthModifier: ViewModifier {
    let regularWidth: CGFloat
    let compactWidth: CGFloat
    @Environment(\.horizontalSizeClass) private var sizeClass

    func body(content: Content) -> some View {
        content.frame(maxWidth: sizeClass == .compact ? compactWidth : regularWidth)
    }
}

extension View {
    /// Adaptive maxWidth — `.infinity` on iPhone, fixed on iPad/Mac
    func adaptiveWidth(_ regularWidth: CGFloat, compact: CGFloat = .infinity) -> some View {
        modifier(AdaptiveWidthModifier(regularWidth: regularWidth, compactWidth: compact))
    }
}

// MARK: - Adaptive Padding (iPhone vs iPad/Mac)

/// Applies different padding amounts based on size class.
/// Usage: `.adaptivePadding(.horizontal, regular: 40, compact: 16)`
struct AdaptivePaddingModifier: ViewModifier {
    let edges: Edge.Set
    let regular: CGFloat
    let compact: CGFloat
    @Environment(\.horizontalSizeClass) private var sizeClass

    func body(content: Content) -> some View {
        content.padding(edges, sizeClass == .compact ? compact : regular)
    }
}

extension View {
    /// Adaptive padding — smaller on iPhone, larger on iPad/Mac
    func adaptivePadding(_ edges: Edge.Set = .all, regular: CGFloat, compact: CGFloat) -> some View {
        modifier(AdaptivePaddingModifier(edges: edges, regular: regular, compact: compact))
    }
}

// MARK: - 9. Card Background ViewModifiers

struct ParchmentCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.md)
                    .fill(RenaissanceColors.parchment)
            )
            .borderCard(radius: CornerRadius.md)
            .renaissanceShadow(.card)
    }
}

struct ParchmentModalModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.lg)
                    .fill(RenaissanceColors.parchment)
            )
            .borderModal(radius: CornerRadius.lg)
            .renaissanceShadow(.modal)
    }
}

struct WorkshopCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.md)
                    .fill(RenaissanceColors.warmBrown.opacity(0.06))
            )
            .borderWorkshop(radius: CornerRadius.md)
            .renaissanceShadow(.card)
    }
}

struct ScienceCardModifier: ViewModifier {
    let color: Color

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.md)
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.15), color.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .borderAccent(radius: CornerRadius.md)
            .renaissanceShadow(.glow(color))
    }
}

extension View {
    func parchmentCard() -> some View {
        modifier(ParchmentCardModifier())
    }

    func parchmentModal() -> some View {
        modifier(ParchmentModalModifier())
    }

    func workshopCard() -> some View {
        modifier(WorkshopCardModifier())
    }

    func scienceCard(color: Color) -> some View {
        modifier(ScienceCardModifier(color: color))
    }
}

// MARK: - 10. Parchment Button Background (single source of truth)

/// Reusable parchment texture background for ALL buttons in the app.
/// Use `.parchmentButton(color:shape:)` on any button content.
struct ParchmentButtonModifier<S: Shape>: ViewModifier {
    let color: Color
    let shape: S
    var textureOpacity: Double = 0.35

    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    Image("ButtonBackground")
                        .resizable()
                        .opacity(textureOpacity)
                    color
                        .blendMode(.multiply)
                }
                .clipShape(shape)
            )
    }
}

extension View {
    /// Parchment texture button background — use on ANY button in the app.
    /// - `color`: the accent fill color (blended with parchment texture)
    /// - `radius`: corner radius for rounded rectangle shape (default 8)
    func parchmentButton(color: Color, radius: CGFloat = CGFloat(CornerRadius.sm)) -> some View {
        modifier(ParchmentButtonModifier(color: color, shape: RoundedRectangle(cornerRadius: radius)))
    }

    /// Parchment texture capsule button background.
    func parchmentCapsule(color: Color) -> some View {
        modifier(ParchmentButtonModifier(color: color, shape: Capsule()))
    }
}

// MARK: - 11. Button Style ViewModifiers

struct ActionButtonModifier: ViewModifier {
    let color: Color

    func body(content: Content) -> some View {
        content
            .font(RenaissanceFont.button)
            .foregroundStyle(.white)
            .padding(.horizontal, Spacing.xl)
            .padding(.vertical, Spacing.xs)
            .parchmentButton(color: color)
    }
}

struct CapsuleButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(RenaissanceFont.buttonSmall)
            .foregroundStyle(RenaissanceColors.sepiaInk)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.xs)
            .parchmentCapsule(color: RenaissanceColors.renaissanceBlue.opacity(0.1))
    }
}

struct GhostButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(RenaissanceFont.buttonSmall)
            .foregroundStyle(RenaissanceColors.sepiaInk)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.xs)
            .parchmentButton(color: .clear)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.sm)
                    .stroke(RenaissanceColors.sepiaInk.opacity(0.3), lineWidth: 1)
            )
    }
}

extension View {
    func actionButton(color: Color) -> some View {
        modifier(ActionButtonModifier(color: color))
    }

    func capsuleButton() -> some View {
        modifier(CapsuleButtonModifier())
    }

    func ghostButton() -> some View {
        modifier(GhostButtonModifier())
    }
}

// MARK: - 11. Divider Styles

struct ThematicDivider: View {
    var body: some View {
        Rectangle()
            .fill(RenaissanceColors.ochre.opacity(0.2))
            .frame(height: 2)
    }
}

extension View {
    func thematicDivider() -> some View {
        overlay(alignment: .bottom) {
            ThematicDivider()
        }
    }
}

// MARK: - Hero Animation (matchedGeometryEffect)

extension View {
    /// Conditionally applies matchedGeometryEffect when a namespace is provided.
    /// Allows views to opt into hero animations without breaking when used standalone (e.g. previews).
    @ViewBuilder
    func heroEffect(id: String, namespace: Namespace.ID?, properties: MatchedGeometryProperties = .frame) -> some View {
        if let namespace {
            self.matchedGeometryEffect(id: id, in: namespace, properties: properties)
        } else {
            self
        }
    }
}
