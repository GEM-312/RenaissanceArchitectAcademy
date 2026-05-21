import Foundation

/// Real-world topic mapping for each of the 17 buildings.
///
/// Drives contextual suggestions: when the player's calendar mentions
/// "Art Institute" or "Florence trip", the system finds buildings whose
/// keywords overlap, then asks Foundation Models to pick the best one
/// and write a personalized reason.
///
/// Keywords are matched case-insensitively as substrings against calendar
/// event titles + locations. Keep them specific enough to avoid false matches
/// (e.g. "dome" alone is fine; "art" alone is too generic).
struct BuildingTopic {
    let buildingId: Int
    let buildingName: String
    let city: String              // "Rome", "Florence", "Venice", "Padua", "Milan"
    let keywords: [String]        // real-world terms a calendar event might use
    let suggestedBookQuery: String? // search term for itms-books:// deep link
}

enum BuildingTopicMap {

    static let all: [BuildingTopic] = [
        // MARK: - Ancient Rome (1-8)
        BuildingTopic(
            buildingId: 1, buildingName: "Aqueduct", city: "Rome",
            keywords: ["aqueduct", "Roman water", "Pont du Gard", "Roman engineering",
                       "hydraulics", "ancient Rome", "Roman ruins"],
            suggestedBookQuery: "Roman aqueducts engineering"
        ),
        BuildingTopic(
            buildingId: 2, buildingName: "Colosseum", city: "Rome",
            keywords: ["Colosseum", "Roman amphitheater", "gladiator", "Flavian",
                       "ancient Rome", "Roman architecture", "arena"],
            suggestedBookQuery: "Colosseum Rome history"
        ),
        BuildingTopic(
            buildingId: 3, buildingName: "Roman Baths", city: "Rome",
            keywords: ["Roman bath", "thermae", "Caracalla", "hypocaust", "Pompeii",
                       "Bath England", "ancient Rome"],
            suggestedBookQuery: "Roman baths thermae"
        ),
        BuildingTopic(
            buildingId: 4, buildingName: "Pantheon", city: "Rome",
            keywords: ["Pantheon", "Roman dome", "oculus", "Hadrian", "concrete dome",
                       "Roman concrete", "ancient Rome"],
            suggestedBookQuery: "Pantheon Rome architecture"
        ),
        BuildingTopic(
            buildingId: 5, buildingName: "Roman Roads", city: "Rome",
            keywords: ["Appian Way", "Via Appia", "Roman road", "Roman empire roads",
                       "Roman engineering"],
            suggestedBookQuery: "Roman roads empire"
        ),
        BuildingTopic(
            buildingId: 6, buildingName: "Harbor", city: "Rome",
            keywords: ["Ostia", "Portus", "Roman harbor", "ancient port",
                       "Roman ships", "Mediterranean trade"],
            suggestedBookQuery: "Ostia Roman harbor"
        ),
        BuildingTopic(
            buildingId: 7, buildingName: "Siege Workshop", city: "Rome",
            keywords: ["catapult", "ballista", "Roman siege", "Heron", "Hero of Alexandria",
                       "Roman military engineering"],
            suggestedBookQuery: "Roman military engineering siege"
        ),
        BuildingTopic(
            buildingId: 8, buildingName: "Insula", city: "Rome",
            keywords: ["insula", "Roman apartment", "Ostia", "Roman daily life",
                       "Roman housing"],
            suggestedBookQuery: "Roman insula housing"
        ),

        // MARK: - Renaissance Italy (9-17)
        BuildingTopic(
            buildingId: 9, buildingName: "Duomo", city: "Florence",
            keywords: ["Duomo", "Florence Cathedral", "Brunelleschi", "Santa Maria del Fiore",
                       "Florence", "Florentine Renaissance", "Tuscany",
                       "Renaissance architecture", "dome"],
            suggestedBookQuery: "Brunelleschi Duomo Florence"
        ),
        BuildingTopic(
            buildingId: 10, buildingName: "Botanical Garden", city: "Florence",
            keywords: ["botanical garden", "Boboli", "Giardino dei Semplici", "Florence garden",
                       "Renaissance botany", "Medici garden"],
            suggestedBookQuery: "Renaissance botanical gardens"
        ),
        BuildingTopic(
            buildingId: 11, buildingName: "Glassworks", city: "Venice",
            keywords: ["Murano", "Venetian glass", "Venice", "Barovier", "glassblowing",
                       "Venetian Renaissance"],
            suggestedBookQuery: "Murano glass history Venice"
        ),
        BuildingTopic(
            buildingId: 12, buildingName: "Arsenal", city: "Venice",
            keywords: ["Venetian Arsenal", "Arsenale", "Venice shipyard", "Venice",
                       "Venetian Republic", "Renaissance shipbuilding"],
            suggestedBookQuery: "Venetian Arsenal shipbuilding"
        ),
        BuildingTopic(
            buildingId: 13, buildingName: "Anatomy Theater", city: "Padua",
            keywords: ["anatomy theater", "Padua", "Padova", "Vesalius", "anatomy",
                       "Renaissance medicine", "University of Padua"],
            suggestedBookQuery: "Vesalius anatomy Padua"
        ),
        BuildingTopic(
            buildingId: 14, buildingName: "Leonardo's Workshop", city: "Milan",
            keywords: ["Leonardo da Vinci", "Leonardo", "Da Vinci", "Milan",
                       "Sforza", "Renaissance workshop", "Codex"],
            suggestedBookQuery: "Leonardo da Vinci Milan workshop"
        ),
        BuildingTopic(
            buildingId: 15, buildingName: "Flying Machine", city: "Milan",
            keywords: ["flying machine", "Leonardo flying", "ornithopter", "Leonardo da Vinci",
                       "Renaissance invention", "aerodynamics"],
            suggestedBookQuery: "Leonardo flying machine inventions"
        ),
        BuildingTopic(
            buildingId: 16, buildingName: "Vatican Observatory", city: "Rome",
            keywords: ["Vatican", "Vatican Observatory", "Gregorian calendar",
                       "Renaissance astronomy", "telescope history", "Galileo"],
            suggestedBookQuery: "Renaissance astronomy Vatican"
        ),
        BuildingTopic(
            buildingId: 17, buildingName: "Printing Press", city: "Rome",
            keywords: ["printing press", "Gutenberg", "Aldus Manutius", "Manutius",
                       "Renaissance printing", "incunabula", "Renaissance books"],
            suggestedBookQuery: "Gutenberg printing press Renaissance"
        ),
    ]

    /// Italian travel keywords that hint at any Italy trip — used to widen the
    /// candidate pool when a calendar event mentions Italy without naming a city.
    static let italyTravelKeywords: [String] = [
        "Italy", "Italia", "Italian", "Roma", "Firenze", "Venezia", "Milano",
        "flight to Italy", "trip to Italy", "vacation Italy"
    ]

    /// Generic art/architecture/history keywords that suggest the broader theme
    /// but don't pinpoint a specific building. Match → use all Renaissance + Rome topics.
    /// Mix of named venues (Art Institute, MoMA, Met) and generic terms (museum, gallery,
    /// exhibit). Matched as case-insensitive substrings, so include common partials.
    static let broadCultureKeywords: [String] = [
        // generic single-word signals — strongest
        "museum", "gallery", "exhibit", "exhibition", "fine arts",
        // named major art venues most likely on a student's calendar
        "art institute",
        "metropolitan museum", "met museum",
        "museum of modern art", "moma",
        "national gallery",
        "uffizi", "louvre", "prado",
        "vatican museum", "borghese", "british museum",
        "guggenheim", "getty",
        // themes / educational
        "renaissance painting", "renaissance art", "italian art",
        "art history", "architecture tour",
        "painting exhibit", "sculpture exhibit"
    ]

    // MARK: - Matching

    /// Find building topics whose keywords appear in the given calendar text.
    /// Case-insensitive substring match. Returns deduplicated by buildingId.
    /// Logs which path matched (specific keyword / city / Italy travel / broad
    /// culture) so failures are diagnosable from the console.
    static func match(eventText: String) -> [BuildingTopic] {
        let haystack = eventText.lowercased()
        var seen = Set<Int>()
        var hits: [BuildingTopic] = []

        for topic in all {
            for keyword in topic.keywords {
                if haystack.contains(keyword.lowercased()) {
                    if seen.insert(topic.buildingId).inserted {
                        hits.append(topic)
                        print("[BuildingTopicMap] direct match — '\(keyword)' → \(topic.buildingName)")
                    }
                    break
                }
            }
        }

        // City-level fallback: if no direct keyword hits, check city names.
        if hits.isEmpty {
            for topic in all {
                if haystack.contains(topic.city.lowercased()) {
                    if seen.insert(topic.buildingId).inserted {
                        hits.append(topic)
                        print("[BuildingTopicMap] city match — '\(topic.city)' → \(topic.buildingName)")
                    }
                }
            }
        }

        // Broader Italian travel — widen to all Renaissance + Rome topics.
        if hits.isEmpty,
           let italyKw = italyTravelKeywords.first(where: { haystack.contains($0.lowercased()) }) {
            print("[BuildingTopicMap] italy-travel match — '\(italyKw)' → all topics")
            hits = all
        }

        // Art/culture theme — bias toward Renaissance topics first.
        if hits.isEmpty,
           let cultureKw = broadCultureKeywords.first(where: { haystack.contains($0.lowercased()) }) {
            print("[BuildingTopicMap] broad-culture match — '\(cultureKw)' → renaissance-first")
            hits = all.filter { $0.buildingId >= 9 } + all.filter { $0.buildingId < 9 }
        }

        return hits
    }

    /// Lookup by id — used when FM returns a buildingId to dereference.
    static func topic(forBuildingId id: Int) -> BuildingTopic? {
        all.first { $0.buildingId == id }
    }
}
