import Foundation
#if canImport(FoundationModels)
import FoundationModels
#endif

/// What action the bird suggests the player take.
enum SuggestedAction: String, Codable {
    case openLesson      // route to the building's lesson reader
    case openCards       // route to the building's knowledge cards
    case openSketching   // route to the sketching phase if available
}

/// The contextual suggestion the bird surfaces when a calendar event
/// overlaps with one of the game's buildings.
///
/// Foundation Models fills this in via guided generation (iOS 26+). On
/// older OSes we construct a hand-built fallback from the topic map +
/// event title without invoking the model.
@available(iOS 26.0, macOS 26.0, *)
@Generable
struct ContextualSuggestion: Equatable {
    @Guide(description: "The building ID (1-17) most relevant to the calendar event")
    var buildingId: Int

    @Guide(description: "1-2 sentences. The bird's voice — playful, warm, references the calendar event by topic (not literal title) and what the player can learn. Under 200 characters.")
    var reason: String

    @Guide(description: "Relevance score 1-10 (10 = exact match like 'Florence trip' for Duomo)")
    var urgencyScore: Int

    @Guide(description: "Short label for the event topic — e.g. 'your Italy trip' or 'the art museum visit'. 2-5 words.")
    var eventTopicLabel: String

    @Guide(description: "Which game action to suggest. Must be exactly one of: openLesson, openCards, openSketching")
    var suggestedAction: String
}

/// Non-Generable mirror used at API boundaries / older-OS fallback path.
/// Keeps the rest of the app off the iOS 26 availability gate.
struct ContextualSuggestionPayload: Codable, Equatable {
    var buildingId: Int
    var reason: String
    var urgencyScore: Int
    var eventTopicLabel: String
    var suggestedAction: SuggestedAction
    /// Optional Apple Books deep-link search query. Built from BuildingTopic.suggestedBookQuery
    /// at the service layer — the model doesn't fill this in.
    var booksSearchQuery: String?

    /// Resolve the building name from the topic map.
    var buildingName: String {
        BuildingTopicMap.topic(forBuildingId: buildingId)?.buildingName ?? ""
    }

    /// itms-books:// deep link to the Books app search.
    var booksAppURL: URL? {
        guard let q = booksSearchQuery,
              let encoded = q.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        else { return nil }
        return URL(string: "itms-books://search?term=\(encoded)")
    }
}

@available(iOS 26.0, macOS 26.0, *)
extension ContextualSuggestion {
    /// Convert the Generable struct into the OS-agnostic payload, attaching
    /// the suggested book query from the topic map. Maps the raw action
    /// string (constrained by the @Guide) to the SuggestedAction enum;
    /// falls back to .openLesson if the model returns something unexpected.
    func toPayload() -> ContextualSuggestionPayload {
        let topic = BuildingTopicMap.topic(forBuildingId: buildingId)
        let action = SuggestedAction(rawValue: suggestedAction) ?? .openLesson
        return ContextualSuggestionPayload(
            buildingId: buildingId,
            reason: reason,
            urgencyScore: urgencyScore,
            eventTopicLabel: eventTopicLabel,
            suggestedAction: action,
            booksSearchQuery: topic?.suggestedBookQuery
        )
    }
}
