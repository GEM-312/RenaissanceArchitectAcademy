import Foundation

/// Extracts notebook entries from lessons and provides curated vocabulary
/// Same static-lookup pattern as ChallengeContent and SketchingContent
enum NotebookContent {

    // MARK: - Lesson → Notebook Extraction

    /// Convert a completed lesson's sections into notebook entries
    static func entriesFromLesson(_ lesson: BuildingLesson, buildingId: Int) -> [NotebookEntry] {
        var entries: [NotebookEntry] = []

        for section in lesson.sections {
            switch section {
            case .reading(let reading):
                let title = reading.title ?? "Key Fact"
                entries.append(NotebookEntry(
                    buildingId: buildingId,
                    entryType: .keyFact,
                    science: reading.science,
                    title: title,
                    body: reading.body
                ))

            case .funFact(let fact):
                entries.append(NotebookEntry(
                    buildingId: buildingId,
                    entryType: .funFact,
                    title: "Fun Fact",
                    body: fact.text
                ))

            case .question(let question):
                let correctAnswer = question.options[question.correctIndex]
                let body = """
                **Q:** \(question.question)

                **A:** \(correctAnswer)

                \(question.explanation)
                """
                entries.append(NotebookEntry(
                    buildingId: buildingId,
                    entryType: .quizResult,
                    science: question.science,
                    title: question.question,
                    body: body
                ))

            case .fillInBlanks(let activity):
                // Reconstruct the passage with blanks filled in bold
                var filledText = activity.text
                for word in activity.correctWords {
                    filledText = filledText.replacingOccurrences(of: "{{\(word)}}", with: "**\(word)**")
                }
                let title = activity.title ?? "Key Terms"
                entries.append(NotebookEntry(
                    buildingId: buildingId,
                    entryType: .vocabulary,
                    science: activity.science,
                    title: title,
                    body: filledText
                ))

            case .environmentPrompt:
                // Skip environment prompts — not knowledge content
                break
            }
        }

        return entries
    }

    // MARK: - Curated Vocabulary

    /// Curated key terms for each building
    static func vocabularyFor(buildingName: String) -> [NotebookEntry]? {
        switch buildingName {
        case "Aqueduct":            return aqueductVocabulary
        case "Colosseum":           return colosseumVocabulary
        case "Roman Baths":         return romanBathsVocabulary
        case "Pantheon":            return pantheonVocabulary
        case "Roman Roads":         return romanRoadsVocabulary
        case "Harbor":              return harborVocabulary
        case "Siege Workshop":      return siegeWorkshopVocabulary
        case "Insula":              return insulaVocabulary
        case "Duomo", "Il Duomo":   return duomoVocabulary
        case "Botanical Garden":    return botanicalGardenVocabulary
        case "Glassworks":          return glassworksVocabulary
        case "Arsenal":             return arsenalVocabulary
        case "Anatomy Theater":     return anatomyTheaterVocabulary
        case "Leonardo's Workshop": return leonardoWorkshopVocabulary
        case "Flying Machine":      return flyingMachineVocabulary
        case "Vatican Observatory": return vaticanObservatoryVocabulary
        case "Printing Press":      return printingPressVocabulary
        default:                    return nil
        }
    }

    // MARK: - Station Lesson → Notebook Entries

    /// Convert a bird station lesson into notebook entries for all buildings that share sciences
    static func entriesFromStationLesson(_ lesson: StationLesson, buildings: [BuildingPlot]) -> [(buildingId: Int, buildingName: String, entry: NotebookEntry)] {
        var results: [(Int, String, NotebookEntry)] = []
        let lessonSciences = Set(lesson.sciences)

        for plot in buildings {
            let buildingSciences = Set(plot.building.sciences)
            let shared = lessonSciences.intersection(buildingSciences)
            guard !shared.isEmpty else { continue }

            let entry = NotebookEntry(
                buildingId: plot.id,
                entryType: .environmentNote,
                science: lesson.sciences.first,
                title: "\(lesson.stationLabel): \(lesson.title)",
                body: lesson.text
            )
            results.append((plot.id, plot.building.name, entry))
        }
        return results
    }

    // MARK: - Pantheon Vocabulary

    private static var pantheonVocabulary: [NotebookEntry] {
        let bid = 4 // Pantheon building ID
        return [
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .architecture,
                title: "Firmitas",
                body: "**Firmitas** — structural strength and durability. One of Vitruvius's three principles of architecture. The Pantheon's 6.4-meter-thick walls exemplify this quality."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .architecture,
                title: "Utilitas",
                body: "**Utilitas** — usefulness and function. The circular interior allows worship in every direction, and the oculus connects earth to the heavens."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .architecture,
                title: "Venustas",
                body: "**Venustas** — beauty and delight. The perfect proportions, marble surfaces, and ethereal light from the oculus create a space that has inspired awe for 2,000 years."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .geometry,
                title: "Oculus",
                body: "**Oculus** — Latin for \"eye.\" The 8.2-meter circular opening at the dome's summit. It is the only source of natural light, and its diameter is exactly one-fifth of the dome's diameter (43.3m)."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .materials,
                title: "Pozzolana",
                body: "**Pozzolana** — volcanic ash from the slopes of Mount Vesuvius. When mixed with lime and water, it creates Roman concrete (*opus caementicium*) — stronger than modern Portland cement and capable of setting underwater."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .architecture,
                title: "Coffers",
                body: "**Coffers** — sunken decorative panels in the dome's interior. The Pantheon has **28 coffers** in each of its 5 rings. 28 is a perfect number (1 + 2 + 4 + 7 + 14 = 28)."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .architecture,
                title: "Relieving Arches",
                body: "**Relieving arches** — semicircular arches of brick embedded within the concrete walls. Invisible from inside, they redirect the dome's 4,535-tonne weight around doorways and niches into 8 massive piers."
            ),
            NotebookEntry(
                buildingId: bid,
                entryType: .vocabulary,
                science: .architecture,
                title: "Corinthian Order",
                body: "**Corinthian order** — the most ornate of the three Greek column styles, described by Vitruvius. The Pantheon's portico has 16 columns of Egyptian granite, 12 meters tall, with acanthus leaf capitals."
            ),
        ]
    }
}
