import Foundation
import FoundationModels
import EventKit

// ━━━ TEACHING MOMENT: Tool Protocol & Autonomous Calling ━━━
//
// THE CONCEPT: The Tool protocol bridges the AI model's knowledge with your
// app's live data. You don't write "if user says X, call Y" — the model
// AUTONOMOUSLY decides when to invoke tools based on conversation context.
//
// STEP BY STEP:
// 1. Define a struct conforming to Tool with a short name + description
// 2. Define @Generable Arguments — the model fills these in
// 3. Implement call(arguments:) — your code runs, returns a String
// 4. Pass tools to LanguageModelSession(tools: [...])
// 5. The model decides when to call your tool — you don't control this
//
// IN OUR CODE: When a student asks the bird "what should I work on?",
// the model autonomously calls BuildingProgressTool to check their progress,
// then InventoryTool to check materials, then gives personalized advice.
//
// KEY TAKEAWAY: Tools make AI personal. The bird doesn't just know architecture —
// it knows YOUR progress, YOUR materials, YOUR calendar. All on-device, private.

// MARK: - Building Progress Tool

/// Lets the AI check which buildings the player has completed, started, or needs.
/// The model calls this autonomously when the conversation touches on progress.
@available(iOS 26.0, macOS 26.0, *)
struct BuildingProgressTool: FoundationModels.Tool {

    let name = "checkBuildingProgress"

    let description = """
        Check the player's progress on building construction. \
        Returns which buildings are complete, in progress, or locked, \
        and what the player needs to do next for each building.
        """

    @Generable
    struct Arguments {
        @Guide(description: "Optional: specific building name to check, or 'all' for overview")
        var buildingName: String
    }

    /// Snapshot of progress data (set before session creation)
    let progressSummary: String

    func call(arguments: Arguments) async throws -> String {
        return progressSummary
    }

    /// Create a progress summary string from CityViewModel state.
    /// Called once when configuring tools — captures a snapshot.
    static func makeSummary(
        buildingPlots: [(name: String, state: String, phase: String)],
        activeBuildingName: String?,
        totalComplete: Int
    ) -> String {
        var lines: [String] = []
        lines.append("Buildings completed: \(totalComplete) of 17")

        if let active = activeBuildingName {
            lines.append("Currently working on: \(active)")
        }

        lines.append("")
        for plot in buildingPlots {
            let marker: String
            switch plot.state {
            case "complete": marker = "✅"
            case "construction", "sketched": marker = "🔨"
            case "available": marker = "📖"
            default: marker = "🔒"
            }
            lines.append("\(marker) \(plot.name) — \(plot.phase)")
        }

        return lines.joined(separator: "\n")
    }
}

// MARK: - Inventory Tool

/// Lets the AI check what materials, tools, and florins the player has.
/// Enables personalized crafting guidance: "You have enough to make concrete!"
@available(iOS 26.0, macOS 26.0, *)
struct InventoryTool: FoundationModels.Tool {

    let name = "checkInventory"

    let description = """
        Check the player's current inventory of raw materials, crafted items, \
        tools, and gold florins. Use this to suggest what the player can craft \
        or what they need to collect.
        """

    @Generable
    struct Arguments {
        @Guide(description: "What to check: 'materials', 'tools', 'crafted', 'florins', or 'all'")
        var category: String
    }

    /// Snapshot of inventory data
    let inventorySummary: String

    func call(arguments: Arguments) async throws -> String {
        let cat = arguments.category.lowercased()

        if cat == "all" {
            return inventorySummary
        }

        // Filter to requested category
        let lines = inventorySummary.split(separator: "\n").map(String.init)
        var inSection = false
        var result: [String] = []

        for line in lines {
            if line.contains("---") {
                inSection = false
            }
            if cat == "materials" && line.contains("Raw Materials") {
                inSection = true
            } else if cat == "tools" && line.contains("Tools") {
                inSection = true
            } else if cat == "crafted" && line.contains("Crafted Items") {
                inSection = true
            } else if cat == "florins" && line.contains("Florins") {
                return line
            }
            if inSection {
                result.append(line)
            }
        }

        return result.isEmpty ? inventorySummary : result.joined(separator: "\n")
    }

    /// Create an inventory summary string from WorkshopState.
    static func makeSummary(
        rawMaterials: [String: Int],
        craftedItems: [String: Int],
        tools: [String],
        florins: Int
    ) -> String {
        var lines: [String] = []

        lines.append("💰 Florins: \(florins)")
        lines.append("")

        lines.append("--- Raw Materials ---")
        if rawMaterials.isEmpty {
            lines.append("  (none collected yet)")
        } else {
            for (name, count) in rawMaterials.sorted(by: { $0.key < $1.key }) {
                lines.append("  \(name): \(count)")
            }
        }

        lines.append("")
        lines.append("--- Crafted Items ---")
        if craftedItems.isEmpty {
            lines.append("  (none crafted yet)")
        } else {
            for (name, count) in craftedItems.sorted(by: { $0.key < $1.key }) {
                lines.append("  \(name): \(count)")
            }
        }

        lines.append("")
        lines.append("--- Tools ---")
        if tools.isEmpty {
            lines.append("  (no tools yet — visit the Market to buy your first!)")
        } else {
            for tool in tools.sorted() {
                lines.append("  🔧 \(tool)")
            }
        }

        return lines.joined(separator: "\n")
    }
}

// MARK: - Calendar Tool

/// Lets the AI check the student's upcoming calendar events to personalize learning.
/// Example: "I see you have a History test on Friday! Let's practice Roman engineering."
///
/// Privacy: All processing is on-device. EventKit permission is requested once.
/// If denied, the tool returns a graceful message and the bird continues without calendar data.
@available(iOS 26.0, macOS 26.0, *)
struct CalendarTool: FoundationModels.Tool {

    let name = "checkCalendar"

    let description: String

    init() {
        description = """
            Check the student's upcoming calendar events for school-related activities \
            like tests, exams, field trips, or classes. \
            Today is \(Date().formatted(date: .complete, time: .omitted)). \
            Use this to connect architecture lessons to their real schedule.
            """
    }

    @Generable
    struct Arguments {
        @Guide(description: "Number of days ahead to look for events, between 1 and 14")
        var daysAhead: Int
    }

    func call(arguments: Arguments) async throws -> String {
        do {
            let eventStore = EKEventStore()

            // Request calendar access
            try await eventStore.requestFullAccessToEvents()

            let calendars = eventStore.calendars(for: .event)
            let startDate = Date()
            let daysToCheck = min(max(arguments.daysAhead, 1), 14)
            guard let endDate = Calendar.current.date(byAdding: .day, value: daysToCheck, to: startDate) else {
                return "Could not check calendar"
            }

            let predicate = eventStore.predicateForEvents(
                withStart: startDate,
                end: endDate,
                calendars: calendars
            )

            let events = eventStore.events(matching: predicate)

            if events.isEmpty {
                return "The student has no upcoming events in the next \(daysToCheck) days. A great time to explore the workshop!"
            }

            // Filter for events that could connect to game content — school work,
            // museum/gallery visits, Italy travel, Renaissance/Roman themes.
            let educationKeywords = [
                // school
                "test", "exam", "quiz", "class", "school", "homework", "study",
                "project", "presentation", "field trip",
                // museum / gallery / cultural
                "museum", "gallery", "exhibit", "exhibition", "tour",
                // subject areas
                "science", "history", "math", "art", "architecture",
                "painting", "sculpture", "drawing",
                // themes the game maps to
                "renaissance", "roman", "ancient rome", "da vinci", "leonardo",
                "brunelleschi", "michelangelo", "galileo", "vesalius", "medici",
                // travel that overlaps with game cities
                "italy", "italia", "italian",
                "rome", "roma", "florence", "firenze", "venice", "venezia",
                "milan", "milano", "padua", "padova", "tuscany",
                "flight", "hotel", "reservation", "vacation", "trip", "travel"
            ]

            var relevant: [String] = []
            var other: [String] = []

            for event in events {
                let title = event.title ?? "Untitled"
                let dateStr = event.startDate.formatted(date: .abbreviated, time: .shortened)
                let entry = "\(dateStr): \(title)"

                let isEducational = educationKeywords.contains { keyword in
                    title.lowercased().contains(keyword)
                }

                if isEducational {
                    relevant.append("📚 \(entry)")
                } else {
                    other.append("📅 \(entry)")
                }
            }

            var result = "Upcoming events (next \(daysToCheck) days):\n"
            if !relevant.isEmpty {
                result += "School-related:\n" + relevant.joined(separator: "\n") + "\n"
            }
            if !other.isEmpty {
                result += "Other:\n" + other.prefix(3).joined(separator: "\n")
            }

            return result

        } catch {
            // Calendar access denied or error — graceful fallback
            return "Calendar not available — the student hasn't granted access. Continue without calendar context."
        }
    }
}

// MARK: - Tool Factory

/// Creates configured tool instances from current game state.
/// Call this when setting up an AI session that needs tool access.
@available(iOS 26.0, macOS 26.0, *)
enum GameToolFactory {

    /// Create a LanguageModelSession pre-configured with all game tools.
    ///
    /// This is the recommended way to create a tool-enabled session — it avoids
    /// the `[any Tool]` type erasure issue by creating the session directly with
    /// concrete tool instances (following Apple's WWDC25 sample pattern).
    ///
    /// - Parameters:
    ///   - instructions: The Instructions string for the session
    ///   - buildingPlots: Array of (name, state, phase) tuples from CityViewModel
    ///   - activeBuildingName: Currently active building name
    ///   - totalComplete: Number of completed buildings
    ///   - rawMaterials: Dictionary of material name → count
    ///   - craftedItems: Dictionary of crafted item name → count
    ///   - tools: Array of tool names the player owns
    ///   - florins: Current gold florins
    /// - Returns: A LanguageModelSession with all 3 game tools attached
    static func makeSession(
        instructions: String,
        buildingPlots: [(name: String, state: String, phase: String)],
        activeBuildingName: String?,
        totalComplete: Int,
        rawMaterials: [String: Int],
        craftedItems: [String: Int],
        tools: [String],
        florins: Int
    ) -> LanguageModelSession {
        let progressSummary = BuildingProgressTool.makeSummary(
            buildingPlots: buildingPlots,
            activeBuildingName: activeBuildingName,
            totalComplete: totalComplete
        )

        let inventorySummary = InventoryTool.makeSummary(
            rawMaterials: rawMaterials,
            craftedItems: craftedItems,
            tools: tools,
            florins: florins
        )

        return LanguageModelSession(
            tools: [
                BuildingProgressTool(progressSummary: progressSummary),
                InventoryTool(inventorySummary: inventorySummary),
                CalendarTool()
            ],
            instructions: Instructions(instructions)
        )
    }
}
