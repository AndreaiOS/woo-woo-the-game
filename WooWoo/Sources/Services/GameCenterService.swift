import GameKit

/// Game Center: auth (IntroScene.m:385-414), invio punteggi (GameOverScene.m:231-240,
/// PunteggiScene.m:200-213), achievements (GameOverScene.m:242-319), pannello GC.
/// Degrada con grazia: se non autenticato, ogni chiamata è un no-op (come l'originale).
///
/// iOS 26 SDK: GKGameCenterViewController e GKGameCenterControllerDelegate sono deprecati
/// a favore di GKAccessPoint. showPanel usa GKAccessPoint.shared.trigger(...) che gestisce
/// autonomamente la presentazione — rootViewController non è più necessario.
@MainActor
final class GameCenterService {
    static let shared = GameCenterService()
    var isAuthenticated: Bool { GKLocalPlayer.local.isAuthenticated }

    private init() {}

    func authenticate() {
        GKLocalPlayer.local.authenticateHandler = { viewController, error in
            if let viewController {
                // authenticateHandler può essere chiamato off-main: dispatch esplicito sul main actor
                Task { @MainActor [viewController] in
                    Self.rootViewController?.present(viewController, animated: false)
                }
            }
            if let error { print("GameCenter auth: \(error.localizedDescription)") }
        }
    }

    func submit(score: Int, mode: GameMode) {
        guard isAuthenticated else { return }
        GKLeaderboard.submitScore(score, context: 0, player: GKLocalPlayer.local,
                                  leaderboardIDs: [mode.leaderboardID]) { error in
            if let error { print("GameCenter submit: \(error.localizedDescription)") }
        }
    }

    func report(achievementIDs: [String]) {
        guard isAuthenticated, !achievementIDs.isEmpty else { return }
        let achievements = achievementIDs.map { id -> GKAchievement in
            let a = GKAchievement(identifier: id)
            a.percentComplete = 100
            return a
        }
        GKAchievement.report(achievements) { error in
            if let error { print("GameCenter achievements: \(error.localizedDescription)") }
        }
    }

    /// Mostra il pannello Game Center.
    /// `state == .leaderboards` → apre la classifica della modalità corrente.
    /// Qualsiasi altro stato → apre lo stato richiesto (es. .achievements).
    /// iOS 26 SDK: usa GKAccessPoint invece di GKGameCenterViewController (deprecato).
    /// trigger(leaderboardID:playerScope:timeScope:) richiede iOS 18; su iOS 17 si
    /// ricade su trigger(state: .leaderboards) che mostra la classifica di default.
    func showPanel(state: GKGameCenterViewControllerState, mode: GameMode) {
        guard isAuthenticated else { return }
        let ap = GKAccessPoint.shared
        if state == .leaderboards {
            if #available(iOS 18.0, *) {
                // Apre direttamente la classifica della modalità corrente (iOS 18+)
                ap.trigger(leaderboardID: mode.leaderboardID,
                           playerScope: .global,
                           timeScope: .allTime) {}
            } else {
                // Fallback iOS 17: mostra la lista leaderboard (trigger(state:) — iOS 14+)
                ap.trigger(state: .leaderboards) {}
            }
        } else {
            // trigger(state:handler:) — iOS 14+
            ap.trigger(state: state) {}
        }
    }

    // MARK: - Root view controller helper (usato solo per auth viewController)

    private static var rootViewController: UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first?.rootViewController
    }
}
