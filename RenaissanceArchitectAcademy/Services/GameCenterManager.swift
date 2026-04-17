import GameKit
import SwiftUI

@MainActor
@Observable
class GameCenterManager: NSObject {
    static let shared = GameCenterManager()

    var isAuthenticated = false
    var playerDisplayName: String?
    var showingDashboard = false

    // MARK: - Leaderboard IDs (must match App Store Connect)

    enum LeaderboardID {
        static let goldFlorins        = "com.marinapollak.raa.leaderboard.florins"
        static let buildingsCompleted = "com.marinapollak.raa.leaderboard.buildings"
        static let totalPlayTime      = "com.marinapollak.raa.leaderboard.playtime"
    }

    // MARK: - Achievement IDs (must match App Store Connect)

    enum AchievementID {
        static let firstBuilding  = "com.marinapollak.raa.achievement.firstBuilding"
        static let fiveBuildings  = "com.marinapollak.raa.achievement.fiveBuildings"
        static let allBuildings   = "com.marinapollak.raa.achievement.allBuildings"
        static let apprenticeRank = "com.marinapollak.raa.achievement.apprentice"
        static let architectRank  = "com.marinapollak.raa.achievement.architect"
        static let masterRank     = "com.marinapollak.raa.achievement.master"
        static let allSciences    = "com.marinapollak.raa.achievement.allSciences"
        static let firstCraft     = "com.marinapollak.raa.achievement.firstCraft"
        static let hundredFlorins = "com.marinapollak.raa.achievement.hundredFlorins"
    }

    // MARK: - Authentication

    func authenticate() {
        GKLocalPlayer.local.authenticateHandler = { viewController, error in
            if let error {
                print("[GameCenter] Auth error: \(error.localizedDescription)")
                return
            }

            #if os(iOS)
            if let vc = viewController {
                Task { @MainActor in
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let rootVC = windowScene.windows.first?.rootViewController {
                        rootVC.present(vc, animated: true)
                    }
                }
                return
            }
            #endif

            Task { @MainActor [weak self] in
                self?.isAuthenticated = GKLocalPlayer.local.isAuthenticated
                self?.playerDisplayName = GKLocalPlayer.local.displayName
                if GKLocalPlayer.local.isAuthenticated {
                    print("[GameCenter] Authenticated as \(GKLocalPlayer.local.displayName)")
                }
            }
        }
    }

    // MARK: - Leaderboard Scores

    func submitScore(_ value: Int, to leaderboardID: String) {
        guard isAuthenticated else { return }
        Task {
            do {
                try await GKLeaderboard.submitScore(
                    value,
                    context: 0,
                    player: GKLocalPlayer.local,
                    leaderboardIDs: [leaderboardID]
                )
                print("[GameCenter] Score \(value) submitted to \(leaderboardID)")
            } catch {
                print("[GameCenter] Score submit error: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Achievements

    func reportAchievement(_ id: String, percentComplete: Double = 100.0) {
        guard isAuthenticated else { return }
        let achievement = GKAchievement(identifier: id)
        achievement.percentComplete = percentComplete
        achievement.showsCompletionBanner = true
        Task {
            do {
                try await GKAchievement.report([achievement])
                print("[GameCenter] Achievement reported: \(id) (\(percentComplete)%)")
            } catch {
                print("[GameCenter] Achievement error: \(error.localizedDescription)")
            }
        }
    }
}
