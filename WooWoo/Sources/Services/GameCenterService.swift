import GameKit
import UIKit

/// Pannello Game Center da mostrare — enum locale per evitare di esporre
/// GKGameCenterViewControllerState (da header deprecato in iOS 26) nella firma pubblica.
enum GameCenterPanel { case leaderboards, achievements }

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
                    UIApplication.shared.keyRootViewController?.present(viewController, animated: true)
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
    /// `.leaderboards` → apre la classifica della modalità corrente (iOS 18+) o default (iOS 17).
    /// `.achievements` → apre il pannello achievements.
    /// iOS 26 SDK: usa GKAccessPoint invece di GKGameCenterViewController (deprecato).
    /// trigger(leaderboardID:playerScope:timeScope:) richiede iOS 18; su iOS 17 si
    /// ricade su trigger(state: .leaderboards) che mostra la classifica di default.
    func showPanel(_ panel: GameCenterPanel, mode: GameMode) {
        // Prima il no-op silenzioso nascondeva il problema: se non autenticato i bottoni
        // "Punteggi"/"Medaglie" sembravano non fare niente. Ora il caso è visibile e
        // ritenta l'autenticazione (es. simulatore/device non loggato a Game Center).
        guard isAuthenticated else {
            authenticate()
            presentNotAuthenticatedAlert()
            return
        }
        let ap = GKAccessPoint.shared
        switch panel {
        case .leaderboards:
            if #available(iOS 18.0, *) {
                // Apre direttamente la classifica della modalità corrente (iOS 18+)
                ap.trigger(leaderboardID: mode.leaderboardID,
                           playerScope: .global,
                           timeScope: .allTime) {}
            } else {
                // Fallback iOS 17: mostra la lista leaderboard (trigger(state:) — iOS 14+)
                ap.trigger(state: .leaderboards) {}
            }
        case .achievements:
            // trigger(state:handler:) — iOS 14+
            ap.trigger(state: .achievements) {}
        }
    }

    /// Feedback quando Game Center non è disponibile (non loggato): l'originale degradava
    /// in silenzio, ma in test sembrava un bug ("i bottoni non fanno niente").
    private func presentNotAuthenticatedAlert() {
        let isIT = Locale.current.language.languageCode?.identifier == "it"
        let alert = UIAlertController(
            title: isIT ? "Game Center" : "Game Center",
            message: isIT
                ? "Accedi a Game Center (Impostazioni › Game Center) per vedere classifiche e medaglie."
                : "Sign in to Game Center (Settings › Game Center) to view leaderboards and achievements.",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        UIApplication.shared.keyRootViewController?.present(alert, animated: true)
    }
}
