import Foundation
import FoundationModels
import SwiftUI

// ━━━ TEACHING MOMENT: NPC Caching & Prewarm Timing ━━━
//
// THE CONCEPT: Generated NPCs are cached to disk so the player sees the same
// character on repeat visits (until a new building is activated). Prewarming
// happens during the Dijkstra pathfinding walk — by the time the apprentice
// arrives at the station, the NPC is ready.
//
// STEP BY STEP:
// 1. Player taps a station → Dijkstra path starts → prewarm NPC session
// 2. Player arrives 2-3 seconds later → check NPC cache
// 3. Cache hit? Show cached NPC immediately
// 4. Cache miss + generation available? Generate + cache + show
// 5. Generation unavailable? Show existing DiscoveryCard (fallback)
//
// IN OUR CODE: NPCEncounterManager.prewarmForStation() fires when
// WorkshopScene starts walking. By arrival, the session is warm.
//
// KEY TAKEAWAY: The player never waits. Cache makes repeat visits instant,
// prewarm makes first visits fast, fallback makes offline work.

// MARK: - NPC Display Data

/// Simple display struct for NPC data — works with both generated and cached NPCs.
/// @Generable types can't be easily reconstructed from cache, so this is our view-layer type.
struct NPCDisplayData: Codable, Equatable, Identifiable {
    var id: String { "\(name)_\(trade)" }
    let name: String
    let trade: String
    let greeting: String
    let historicalFact: String
    let scienceTip: String
    let portraitPrompt: String
}

/// Manages NPC generation, caching, and session tracking for station encounters.
/// NPCs are cached per (station, building) pair — same NPC appears until building changes.
@available(iOS 26.0, macOS 26.0, *)
@MainActor
class NPCEncounterManager: ObservableObject {

    // MARK: - Singleton

    static let shared = NPCEncounterManager()

    // MARK: - Published State

    @Published var currentNPC: NPCDisplayData?
    @Published var currentPortrait: CGImage?

    // MARK: - Session Tracking

    /// NPCs already shown this session — prevents repeating within one play session
    private var npcSeenThisSession: Set<String> = []

    // MARK: - Cache

    private let cacheDirectory: URL

    private init() {
        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        cacheDirectory = caches.appendingPathComponent("GeneratedNPCs", isDirectory: true)
        try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }

    // MARK: - Cache Key

    private func cacheKey(station: String, buildingId: Int) -> String {
        "\(station)_\(buildingId)"
    }

    // MARK: - Prewarm

    /// Call when player starts walking toward a station. Warms the generation session.
    func prewarmForStation(_ stationType: String, buildingName: String, sciences: [String]) {
        guard GenerationService.isAvailable else { return }

        let contextId = "npc_\(stationType)_\(buildingName)"
        let instructions = """
            You are a creative writer for an educational game about Renaissance architecture. \
            Generate historically accurate Italian Renaissance characters who work in specific trades. \
            Characters should be warm, knowledgeable, and passionate about their craft. \
            Use real historical details from 1400-1550 Italy.
            """
        GenerationService.shared.prewarm(for: contextId, instructions: instructions)
    }

    // MARK: - Generate or Load NPC

    /// Get an NPC for a station encounter. Checks cache first, generates if needed.
    /// Returns nil if generation is unavailable and no cache exists.
    func getNPC(
        station: String,
        buildingId: Int,
        buildingName: String,
        sciences: [String]
    ) async -> NPCDisplayData? {
        let key = cacheKey(station: station, buildingId: buildingId)

        // Already shown this session? Skip
        if npcSeenThisSession.contains(key) {
            return nil
        }

        // Check disk cache first (previously generated)
        if let cached = loadFromCache(key: key) {
            currentNPC = cached
            npcSeenThisSession.insert(key)
            return cached
        }

        // Try AI generation with real historical figure context
        if GenerationService.isAvailable {

            do {
                let generated = try await GenerationService.shared.generateNPC(
                    stationType: station,
                    buildingName: buildingName,
                    sciences: sciences
                )

                let displayData = NPCDisplayData(
                    name: generated.name,
                    trade: generated.trade,
                    greeting: generated.greeting,
                    historicalFact: generated.historicalFact,
                    scienceTip: generated.scienceTip,
                    portraitPrompt: generated.portraitPrompt
                )

                saveToCache(npc: displayData, key: key)
                currentNPC = displayData
                npcSeenThisSession.insert(key)
                return displayData

            } catch {
                print("[NPCEncounterManager] AI generation failed, using fallback: \(error)")
            }
        }

        // Fallback: pre-written historical NPC (offline / AI unavailable)
        if let historical = HistoricalNPCContent.npc(for: buildingName) {
            currentNPC = historical
            npcSeenThisSession.insert(key)
            return historical
        }

        print("[NPCEncounterManager] No NPC available for \(buildingName)")
        return nil
    }

    /// Check if an NPC encounter should happen for this station.
    func shouldShowNPC(station: String, buildingId: Int) -> Bool {
        let key = cacheKey(station: station, buildingId: buildingId)
        if npcSeenThisSession.contains(key) { return false }
        if loadFromCache(key: key) != nil { return true }
        return GenerationService.isAvailable
    }

    // MARK: - Disk Cache (Codable JSON)

    private func saveToCache(npc: NPCDisplayData, key: String) {
        let fileURL = cacheDirectory.appendingPathComponent("\(key).json")
        if let data = try? JSONEncoder().encode(npc) {
            try? data.write(to: fileURL, options: .atomic)
        }
    }

    private func loadFromCache(key: String) -> NPCDisplayData? {
        let fileURL = cacheDirectory.appendingPathComponent("\(key).json")
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return try? JSONDecoder().decode(NPCDisplayData.self, from: data)
    }

}
