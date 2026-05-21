import SwiftUI

/// Bird-themed overlay that surfaces a proactive contextual suggestion
/// driven by [[ContextualSuggestionService]]. Tapping the primary CTA
/// routes the user to the relevant building lesson; an optional secondary
/// CTA opens the Apple Books app to a related search.
///
/// Wraps the shared [[BirdModalOverlay]] primitive so the chrome matches
/// every other bird modal in the app.
struct BirdContextualSuggestionOverlay: View {
    let suggestion: ContextualSuggestionPayload
    let onOpenLesson: (Int) -> Void
    let onOpenBooks: (URL) -> Void
    let onDismiss: () -> Void

    var body: some View {
        BirdModalOverlay(onDismissBackground: onDismiss) {
            VStack(spacing: Spacing.md) {
                Text("A note from the Maestro")
                    .font(RenaissanceFont.dialogTitle)
                    .foregroundStyle(RenaissanceColors.sepiaInk)
                    .multilineTextAlignment(.center)

                eventTopicPill

                Text(suggestion.reason)
                    .font(RenaissanceFont.bodyItalic)
                    .foregroundStyle(RenaissanceColors.sepiaInk)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.xs)

                Text("Building: \(suggestion.buildingName)")
                    .font(RenaissanceFont.caption)
                    .foregroundStyle(RenaissanceColors.sepiaInk.opacity(0.7))

                actionStack
                    .padding(.top, Spacing.xs)
            }
        }
    }

    private var eventTopicPill: some View {
        Text(suggestion.eventTopicLabel)
            .font(RenaissanceFont.footnoteBold)
            .tracking(Tracking.label)
            .foregroundStyle(RenaissanceColors.sepiaInk)
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xxs)
            .background(
                Capsule()
                    .fill(RenaissanceColors.ochre.opacity(0.18))
            )
            .overlay(
                Capsule()
                    .stroke(RenaissanceColors.ochre.opacity(0.4), lineWidth: 0.8)
            )
    }

    private var actionStack: some View {
        VStack(spacing: Spacing.xs) {
            RenaissanceButton(title: primaryCTATitle) {
                onOpenLesson(suggestion.buildingId)
            }

            if let booksURL = suggestion.booksAppURL {
                RenaissanceSecondaryButton(title: "Find in Books") {
                    onOpenBooks(booksURL)
                }
            }

            RenaissanceSecondaryButton(title: "Not now", action: onDismiss)
        }
    }

    private var primaryCTATitle: String {
        switch suggestion.suggestedAction {
        case .openLesson:    return "Open Lesson"
        case .openCards:     return "Open Cards"
        case .openSketching: return "Start Sketching"
        }
    }
}

#Preview {
    BirdContextualSuggestionOverlay(
        suggestion: ContextualSuggestionPayload(
            buildingId: 9,
            reason: "I noticed your trip to Florence! Brunelleschi's dome is the heart of that city — Leonardo would want you to see how he solved the impossible.",
            urgencyScore: 9,
            eventTopicLabel: "your Florence trip",
            suggestedAction: .openLesson,
            booksSearchQuery: "Brunelleschi Duomo Florence"
        ),
        onOpenLesson: { _ in },
        onOpenBooks: { _ in },
        onDismiss: { }
    )
    .background(RenaissanceColors.parchment)
}
