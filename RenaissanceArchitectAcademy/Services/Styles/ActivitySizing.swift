import SwiftUI

/// Single source of truth for sizing on the knowledge-card back-side
/// activities (hangman, scramble, number fishing, multiple choice,
/// true/false, keyword match, fill-in-blank).
///
/// Activity views ONLY read from here. Adjust a token and every activity
/// reflows. Size class is a parameter, not an inline check — views grab
/// `@Environment(\.horizontalSizeClass)` once and pass it through, keeping
/// the call sites declarative.
///
/// Device buckets:
/// - `.regular` → iPad (full activity treatment)
/// - `.compact` / nil → iPhone (scaled down, fewer grid columns)
enum ActivitySizing {

    // MARK: - Outer Layout

    /// Padding around activity content inside the card-back container.
    static let outerPadding: CGFloat = 24

    /// Spacing between major sections (title → content → footer indicator).
    static let sectionSpacing: CGFloat = 28

    /// Spacing inside a tile grid (between rows / columns).
    static let tileGridSpacing: CGFloat = 12

    /// Spacing between dashed letter slots in a word puzzle.
    static let slotSpacing: CGFloat = 10

    /// Spacing between buttons in vertical option stacks.
    static let buttonStackSpacing: CGFloat = 16

    // MARK: - Card Header (card-back chrome — title bar above activity)

    static func cardHeaderTitleFont(_ sizeClass: UserInterfaceSizeClass?) -> Font {
        sizeClass == .regular
            ? .custom("Cinzel-Bold", size: 30, relativeTo: .title)
            : .custom("Cinzel-Bold", size: 22, relativeTo: .title2)
    }

    static func cardHeaderIconSize(_ sizeClass: UserInterfaceSizeClass?) -> CGFloat {
        sizeClass == .regular ? 28 : 20
    }

    static func cardHeaderBackFont(_ sizeClass: UserInterfaceSizeClass?) -> Font {
        sizeClass == .regular
            ? .custom("EBGaramond-SemiBold", size: 22, relativeTo: .title3)
            : .custom("EBGaramond-SemiBold", size: 16, relativeTo: .body)
    }

    // MARK: - Activity Title (hint / question / statement / prompt)

    static func titleFont(_ sizeClass: UserInterfaceSizeClass?) -> Font {
        sizeClass == .regular
            ? .custom("Cinzel-Bold", size: 32, relativeTo: .title)
            : .custom("Cinzel-Bold", size: 22, relativeTo: .title2)
    }

    /// Allow long titles to shrink rather than truncate.
    static let titleMinScale: CGFloat = 0.7

    // MARK: - Word-Puzzle Slots (hangman dashes, scramble answer blanks)

    /// Base slot font when the puzzle fits comfortably.
    /// For dynamic sizing based on word length, use `slotFontFor(slotCount:)`.
    static func slotFont(_ sizeClass: UserInterfaceSizeClass?) -> Font {
        sizeClass == .regular
            ? .custom("Cinzel-Bold", size: 56, relativeTo: .largeTitle)
            : .custom("Cinzel-Bold", size: 36, relativeTo: .title)
    }

    static func slotFrame(_ sizeClass: UserInterfaceSizeClass?) -> CGSize {
        sizeClass == .regular
            ? CGSize(width: 64, height: 84)
            : CGSize(width: 40, height: 56)
    }

    /// Slot font scaled down for long words so they stay on one row.
    static func slotFontFor(_ sizeClass: UserInterfaceSizeClass?, slotCount: Int) -> Font {
        let size = slotFontSize(sizeClass, slotCount: slotCount)
        return .custom("Cinzel-Bold", size: size, relativeTo: .largeTitle)
    }

    /// Slot frame scaled down for long words so they stay on one row.
    static func slotFrameFor(_ sizeClass: UserInterfaceSizeClass?, slotCount: Int) -> CGSize {
        let regular = sizeClass == .regular
        // Tiered by count — small words bigger, long words shrink to fit.
        if regular {
            switch slotCount {
            case ...6:   return CGSize(width: 72, height: 92)
            case 7...8:  return CGSize(width: 60, height: 80)
            case 9...10: return CGSize(width: 52, height: 68)
            default:     return CGSize(width: 44, height: 60)
            }
        } else {
            switch slotCount {
            case ...5:  return CGSize(width: 44, height: 60)
            case 6...7: return CGSize(width: 38, height: 52)
            case 8...9: return CGSize(width: 32, height: 44)
            default:    return CGSize(width: 28, height: 38)
            }
        }
    }

    private static func slotFontSize(_ sizeClass: UserInterfaceSizeClass?, slotCount: Int) -> CGFloat {
        let regular = sizeClass == .regular
        if regular {
            switch slotCount {
            case ...6:   return 56
            case 7...8:  return 48
            case 9...10: return 40
            default:     return 32
            }
        } else {
            switch slotCount {
            case ...5:  return 36
            case 6...7: return 30
            case 8...9: return 26
            default:    return 22
            }
        }
    }

    // MARK: - Letter Tile (hangman alphabet, scramble pool)

    /// Base tile font (used by hangman grid where col count is fixed).
    static func tileFont(_ sizeClass: UserInterfaceSizeClass?) -> Font {
        sizeClass == .regular
            ? .custom("Cinzel-Bold", size: 32, relativeTo: .title)
            : .custom("Cinzel-Bold", size: 22, relativeTo: .title3)
    }

    /// Base tile frame.
    static func tileFrame(_ sizeClass: UserInterfaceSizeClass?) -> CGFloat {
        sizeClass == .regular ? 64 : 48
    }

    /// Tile font scaled down so a row of `tileCount` fits on a single line.
    static func tileFontFor(_ sizeClass: UserInterfaceSizeClass?, tileCount: Int) -> Font {
        let size = tileFontSize(sizeClass, tileCount: tileCount)
        return .custom("Cinzel-Bold", size: size, relativeTo: .title)
    }

    /// Tile frame scaled down so a row of `tileCount` fits on a single line.
    static func tileFrameFor(_ sizeClass: UserInterfaceSizeClass?, tileCount: Int) -> CGFloat {
        let regular = sizeClass == .regular
        if regular {
            switch tileCount {
            case ...6:   return 80
            case 7...8:  return 68
            case 9...10: return 56
            default:     return 48
            }
        } else {
            switch tileCount {
            case ...5:  return 52
            case 6...7: return 44
            case 8...9: return 38
            default:    return 32
            }
        }
    }

    private static func tileFontSize(_ sizeClass: UserInterfaceSizeClass?, tileCount: Int) -> CGFloat {
        let regular = sizeClass == .regular
        if regular {
            switch tileCount {
            case ...6:   return 44
            case 7...8:  return 36
            case 9...10: return 28
            default:     return 24
            }
        } else {
            switch tileCount {
            case ...5:  return 28
            case 6...7: return 22
            case 8...9: return 18
            default:    return 16
            }
        }
    }

    // MARK: - Number Bubble (number-fishing activity)

    static func bubbleFont(_ sizeClass: UserInterfaceSizeClass?) -> Font {
        sizeClass == .regular
            ? .custom("Cinzel-Bold", size: 36, relativeTo: .title)
            : .custom("Cinzel-Bold", size: 24, relativeTo: .title3)
    }

    static func bubbleFrame(_ sizeClass: UserInterfaceSizeClass?) -> CGFloat {
        sizeClass == .regular ? 96 : 72
    }

    /// Pond container height for number fishing.
    static func pondHeight(_ sizeClass: UserInterfaceSizeClass?) -> CGFloat {
        sizeClass == .regular ? 420 : 300
    }

    // MARK: - Button-Based Activities (multiple choice, keyword match)

    static func buttonTextFont(_ sizeClass: UserInterfaceSizeClass?) -> Font {
        sizeClass == .regular
            ? .custom("EBGaramond-SemiBold", size: 24, relativeTo: .title3)
            : .custom("EBGaramond-SemiBold", size: 18, relativeTo: .body)
    }

    static func buttonHPadding(_ sizeClass: UserInterfaceSizeClass?) -> CGFloat {
        sizeClass == .regular ? 24 : 18
    }

    static func buttonVPadding(_ sizeClass: UserInterfaceSizeClass?) -> CGFloat {
        sizeClass == .regular ? 22 : 16
    }

    /// Allow long option text (e.g. multiple-choice answers) to shrink rather
    /// than truncate when it brushes the button edge.
    static let buttonTextMinScale: CGFloat = 0.7

    // MARK: - True/False Toggle (bigger, more deliberate buttons)

    static func toggleButtonFont(_ sizeClass: UserInterfaceSizeClass?) -> Font {
        sizeClass == .regular
            ? .custom("EBGaramond-SemiBold", size: 32, relativeTo: .title2)
            : .custom("EBGaramond-SemiBold", size: 22, relativeTo: .title3)
    }

    static func toggleButtonVPadding(_ sizeClass: UserInterfaceSizeClass?) -> CGFloat {
        sizeClass == .regular ? 28 : 20
    }

    // MARK: - Grids — Column Counts

    /// Hangman alphabet grid columns. Reducing this on regular vs the old 13
    /// keeps tiles big enough to read at the new tile font size.
    static func hangmanColumns(_ sizeClass: UserInterfaceSizeClass?) -> Int {
        sizeClass == .regular ? 7 : 5
    }

    /// Scramble tile pool columns — dynamic so short words fit on one row.
    static func scrambleColumns(_ sizeClass: UserInterfaceSizeClass?, tileCount: Int) -> Int {
        let maxCols = sizeClass == .regular ? 10 : 7
        return max(min(tileCount, maxCols), 1)
    }

    // MARK: - Hangman Scaffold

    static func scaffoldSize(_ sizeClass: UserInterfaceSizeClass?) -> CGSize {
        sizeClass == .regular
            ? CGSize(width: 220, height: 280)
            : CGSize(width: 160, height: 200)
    }

    /// Diameter of the wrong-guesses-remaining indicator circles.
    static func indicatorDotSize(_ sizeClass: UserInterfaceSizeClass?) -> CGFloat {
        sizeClass == .regular ? 18 : 14
    }

    // MARK: - Progress / Match Indicator

    /// Match-count dots (e.g. "3/5 matched" pip indicator).
    static func progressDotSize(_ sizeClass: UserInterfaceSizeClass?) -> CGFloat {
        sizeClass == .regular ? 14 : 10
    }
}
