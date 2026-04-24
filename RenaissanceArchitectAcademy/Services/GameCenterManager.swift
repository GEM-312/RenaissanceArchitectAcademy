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
        static let totalFlorins       = "Total_Florins"
        static let buildingsCompleted = "Buildings_Completed"
        static let cardsCompleted     = "Knowledge_Cards"
        static let sciencesMastered   = "Sciences_Mastered"
        static let totalCrafted       = "Master_Craftsman"
    }

    // MARK: - Achievement IDs (must match App Store Connect)

    enum AchievementID {
        // Buildings (5)
        static let firstBuilding      = "com.raa.ach.first.building"
        static let romeComplete       = "com.raa.ach.rome.complete"
        static let renaissanceComplete = "com.raa.ach.renaissance.complete"
        static let allBuildings       = "com.raa.ach.all.buildings"
        static let firstConstruction  = "com.raa.ach.first.construction"

        // Florins (3)
        static let florins100         = "com.raa.ach.florins.100"
        static let florins500         = "com.raa.ach.florins.500"
        static let florins1000        = "com.raa.ach.florins.1000"

        // Knowledge (4)
        static let firstLesson        = "com.raa.ach.first.lesson"
        static let allLessons         = "com.raa.ach.all.lessons"
        static let cards50            = "com.raa.ach.cards.50"
        static let cardsAll           = "com.raa.ach.cards.all"

        // Science — milestones (2)
        static let sciences3          = "com.raa.ach.sciences.3"
        static let sciencesAll        = "com.raa.ach.sciences.all"

        // Crafting & Tools (4)
        static let firstTool          = "com.raa.ach.first.tool"
        static let allTools           = "com.raa.ach.all.tools"
        static let firstCraft         = "com.raa.ach.first.craft"
        static let crafts25           = "com.raa.ach.crafts.25"

        // Exploration (2)
        static let firstSketch        = "com.raa.ach.first.sketch"
        static let firstTruffle       = "com.raa.ach.first.truffle"

        // Individual Sciences (13)
        static func science(_ science: Science) -> String {
            return "com.raa.ach.science.\(science.achievementKey)"
        }
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

    // MARK: - Dashboard

    func showDashboard() {
        guard isAuthenticated else { return }
        #if os(iOS)
        let gcVC = GKGameCenterViewController(state: .default)
        gcVC.gameCenterDelegate = self
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            // Find the topmost presented VC
            var topVC = rootVC
            while let presented = topVC.presentedViewController {
                topVC = presented
            }
            topVC.present(gcVC, animated: true)
        }
        #elseif os(macOS)
        let gcVC = GKGameCenterViewController(state: .default)
        gcVC.gameCenterDelegate = self
        GKDialogController.shared().present(gcVC)
        #endif
    }

    func showAchievements() {
        guard isAuthenticated else { return }
        #if os(iOS)
        let gcVC = GKGameCenterViewController(state: .achievements)
        gcVC.gameCenterDelegate = self
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            var topVC = rootVC
            while let presented = topVC.presentedViewController {
                topVC = presented
            }
            topVC.present(gcVC, animated: true)
        }
        #endif
    }

    func showLeaderboards() {
        guard isAuthenticated else { return }
        #if os(iOS)
        let gcVC = GKGameCenterViewController(state: .leaderboards)
        gcVC.gameCenterDelegate = self
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            var topVC = rootVC
            while let presented = topVC.presentedViewController {
                topVC = presented
            }
            topVC.present(gcVC, animated: true)
        }
        #endif
    }

    // MARK: - Activity IDs (must match App Store Connect)

    enum ActivityID {
        static let quarry        = "com.raa.activity.quarry"
        static let river         = "com.raa.activity.river"
        static let volcano       = "com.raa.activity.volcano"
        static let clayPit       = "com.raa.activity.claypit"
        static let mine          = "com.raa.activity.mine"
        static let forest        = "com.raa.activity.forest"
        static let farm          = "com.raa.activity.farm"
        static let market        = "com.raa.activity.market"
        static let crafting      = "com.raa.activity.crafting"
        static let sketching     = "com.raa.activity.sketching"
        static let lesson        = "com.raa.activity.lesson"
        static let construction  = "com.raa.activity.construction"

        static func forStation(_ station: ResourceStationType) -> String? {
            switch station {
            case .quarry:       return quarry
            case .river:        return river
            case .volcano:      return volcano
            case .clayPit:      return clayPit
            case .mine:         return mine
            case .forest:       return forest
            case .farm:         return farm
            case .market:       return market
            case .furnace:      return crafting
            case .workbench, .pigmentTable, .craftingRoom, .goldsmithWorkshop:
                return nil // No separate activity for these
            }
        }
    }

    // MARK: - Activities (iOS 26+)
    // Store as Any to avoid @available on stored properties (incompatible with @Observable)

    private var _activityDefinitions: Any = [String: Any]()
    private var _currentActivity: Any?

    /// Load all activity definitions from App Store Connect. Call once after authentication.
    func loadActivityDefinitions() async {
        guard isAuthenticated else { return }
        if #available(iOS 26.0, macOS 26.0, *) {
            do {
                let definitions = try await GKGameActivityDefinition.all
                var defs = [String: GKGameActivityDefinition]()
                for def in definitions {
                    defs[def.identifier] = def
                }
                _activityDefinitions = defs
                print("[GameCenter] Loaded \(definitions.count) activity definitions")
            } catch {
                print("[GameCenter] Activity definitions error: \(error.localizedDescription)")
            }
        }
    }

    /// Start a Game Center activity. Ends any current activity first.
    func startActivity(_ vendorID: String) {
        if #available(iOS 26.0, macOS 26.0, *) {
            endCurrentActivity()

            guard let defs = _activityDefinitions as? [String: GKGameActivityDefinition],
                  let definition = defs[vendorID] else {
                print("[GameCenter] No activity definition for \(vendorID)")
                return
            }
            do {
                let activity = try GKGameActivity.start(definition: definition)
                _currentActivity = activity
                print("[GameCenter] Started activity: \(vendorID)")
            } catch {
                print("[GameCenter] Start activity error: \(error.localizedDescription)")
            }
        }
    }

    /// End the current activity. Auto-reports all linked achievements and scores.
    func endCurrentActivity(withAchievement achievementID: String? = nil) {
        if #available(iOS 26.0, macOS 26.0, *) {
            guard let activity = _currentActivity as? GKGameActivity else { return }
            if let achID = achievementID {
                let ach = GKAchievement(identifier: achID)
                activity.setAchievementCompleted(ach)
            }
            activity.end()
            print("[GameCenter] Ended activity")
            _currentActivity = nil
        }
    }

    /// Pause the current activity (e.g., app backgrounded).
    func pauseCurrentActivity() {
        if #available(iOS 26.0, macOS 26.0, *) {
            (_currentActivity as? GKGameActivity)?.pause()
        }
    }

    /// Resume the current activity (e.g., app foregrounded).
    func resumeCurrentActivity() {
        if #available(iOS 26.0, macOS 26.0, *) {
            (_currentActivity as? GKGameActivity)?.resume()
        }
    }

    // MARK: - Access Point

    func showAccessPoint() {
        #if os(iOS)
        GKAccessPoint.shared.location = .topTrailing
        GKAccessPoint.shared.isActive = true
        #endif
    }

    func hideAccessPoint() {
        #if os(iOS)
        GKAccessPoint.shared.isActive = false
        #endif
    }
}

// MARK: - GKGameCenterControllerDelegate

extension GameCenterManager: GKGameCenterControllerDelegate {
    nonisolated func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        #if os(iOS)
        Task { @MainActor in
            gameCenterViewController.dismiss(animated: true)
        }
        #elseif os(macOS)
        Task { @MainActor in
            GKDialogController.shared().dismiss(gameCenterViewController)
        }
        #endif
    }
}
