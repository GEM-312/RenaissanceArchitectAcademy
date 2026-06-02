import Foundation

/// Curated real-world venue/city knowledge for contextual suggestions.
///
/// When a calendar event names a real museum or city, code looks it up here and
/// injects the highlights into the prompt — so the bird can recommend something
/// SPECIFIC and TRUE to see there ("at the Uffizi, find Botticelli's…") and tie
/// it to a game building, instead of just describing the building.
///
/// This is a code-side knowledge map the service consults, NOT a model-invoked
/// Foundation Models tool — on-device tool-calling + guided generation crashes
/// the model (see [[ContextualSuggestionService]]). Same working pattern: our
/// code supplies the grounded facts, the model writes the prose.
///
/// All highlights are well-known permanent collections / landmarks — no current
/// exhibitions, hours, or anything that goes stale. Starter set; grows over time.
struct VenueHighlight {
    /// Lowercased substrings an event might use to name this place.
    let keywords: [String]
    /// How the bird should refer to it, e.g. "the Uffizi", "Florence".
    let displayName: String
    /// One concrete, true thing to look for there.
    let highlights: String
    /// The game building this connects to.
    let buildingId: Int
}

enum VenueGuide {

    /// Order = match priority: specific venues before cities, so "Uffizi in
    /// Florence" matches the Uffizi entry, not the generic Florence one.
    static let all: [VenueHighlight] = [

        // MARK: - Named museums
        VenueHighlight(keywords: ["uffizi"], displayName: "the Uffizi",
            highlights: "Botticelli's Birth of Venus and Primavera, and Leonardo's early Annunciation", buildingId: 9),
        VenueHighlight(keywords: ["accademia"], displayName: "the Galleria dell'Accademia",
            highlights: "Michelangelo's David and his unfinished marble Prisoners", buildingId: 9),
        VenueHighlight(keywords: ["louvre"], displayName: "the Louvre",
            highlights: "the Italian Renaissance rooms — Leonardo's Mona Lisa and Virgin of the Rocks", buildingId: 14),
        VenueHighlight(keywords: ["sistine", "vatican museum"], displayName: "the Vatican Museums",
            highlights: "Raphael's Rooms and Michelangelo's Sistine Chapel ceiling", buildingId: 9),
        VenueHighlight(keywords: ["british museum"], displayName: "the British Museum",
            highlights: "the Roman Empire galleries — engineering, mosaics, and sculpture", buildingId: 2),
        VenueHighlight(keywords: ["metropolitan museum", "met museum"], displayName: "the Met",
            highlights: "the European Paintings wing of Italian Renaissance masters", buildingId: 9),
        VenueHighlight(keywords: ["art institute"], displayName: "the Art Institute",
            highlights: "the Italian Renaissance galleries", buildingId: 9),
        VenueHighlight(keywords: ["national gallery"], displayName: "the National Gallery",
            highlights: "Leonardo's Virgin of the Rocks and Botticelli's paintings", buildingId: 9),
        VenueHighlight(keywords: ["prado"], displayName: "the Prado",
            highlights: "its Italian Renaissance collection", buildingId: 9),
        VenueHighlight(keywords: ["galileo museum", "museo galileo"], displayName: "the Museo Galileo",
            highlights: "Galileo's original telescopes and scientific instruments", buildingId: 16),
        VenueHighlight(keywords: ["leonardo museum", "da vinci museum", "science and technology museum"], displayName: "the Leonardo da Vinci science museum",
            highlights: "the wooden models built straight from Leonardo's machine drawings", buildingId: 15),
        VenueHighlight(keywords: ["murano", "glass museum"], displayName: "the Murano glass museum",
            highlights: "live glassblowing and centuries of Venetian glass", buildingId: 11),
        VenueHighlight(keywords: ["natural history"], displayName: "the natural history museum",
            highlights: "the anatomy, skeleton, and botanical specimen halls", buildingId: 13),
        VenueHighlight(keywords: ["planetarium", "science museum"], displayName: "the science museum",
            highlights: "the astronomy hall and the history of the telescope", buildingId: 16),
        VenueHighlight(keywords: ["capitoline", "roman forum", "forum romanum"], displayName: "the Roman Forum",
            highlights: "Roman arches, engineering, and aqueduct remains", buildingId: 1),

        // MARK: - Cities / travel
        VenueHighlight(keywords: ["florence", "firenze"], displayName: "Florence",
            highlights: "Brunelleschi's dome crowning the Cathedral, and the Uffizi", buildingId: 9),
        VenueHighlight(keywords: ["roma"], displayName: "Rome",
            highlights: "the Pantheon's 2,000-year-old dome and the Colosseum", buildingId: 4),
        VenueHighlight(keywords: ["venice", "venezia"], displayName: "Venice",
            highlights: "Murano's glass furnaces and the Arsenal shipyard", buildingId: 11),
        VenueHighlight(keywords: ["milan", "milano"], displayName: "Milan",
            highlights: "Leonardo's Last Supper and the Sforza Castle", buildingId: 14),
        VenueHighlight(keywords: ["padua", "padova"], displayName: "Padua",
            highlights: "the world's oldest anatomical theatre at the university", buildingId: 13),
        VenueHighlight(keywords: ["paris"], displayName: "Paris",
            highlights: "the Louvre's Italian Renaissance wing", buildingId: 14),
        VenueHighlight(keywords: ["london"], displayName: "London",
            highlights: "the British Museum's Roman galleries", buildingId: 2),
        VenueHighlight(keywords: ["madrid"], displayName: "Madrid",
            highlights: "the Prado's Italian Renaissance paintings", buildingId: 9),
        VenueHighlight(keywords: ["pisa"], displayName: "Pisa",
            highlights: "the Leaning Tower and Galileo's experiments on gravity", buildingId: 16),
    ]

    /// First venue/city whose keyword appears in the event text, or nil.
    static func match(eventText: String) -> VenueHighlight? {
        let t = eventText.lowercased()
        return all.first { $0.keywords.contains { t.contains($0) } }
    }
}
