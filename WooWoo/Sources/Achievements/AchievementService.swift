import Foundation

/// Valuta i trigger contro lo stato di gioco, sblocca (idempotente), fa mirror a Game Center,
/// e ritorna SOLO i nuovi sblocchi (per i toast). Local-first: funziona anche senza GC.
@MainActor
final class AchievementService {
    static let shared = AchievementService()

    private let store: AchievementStore
    private let scoreStore: ScoreStore
    private let gameCenter: GameCenterMirror

    init(store: AchievementStore = AchievementStore(),
         scoreStore: ScoreStore = ScoreStore(),
         gameCenter: GameCenterMirror = GameCenterService.shared) {
        self.store = store
        self.scoreStore = scoreStore
        self.gameCenter = gameCenter
    }

    func isUnlocked(_ id: String) -> Bool { store.isUnlocked(id) }

    // MARK: - Eventi

    /// Uccisione: valuta streak e punteggio-partita.
    func onKill(score: Int, streak: Int) -> [Achievement] {
        evaluate { trigger in
            switch trigger {
            case .streak(let n):      return streak >= n
            case .scoreInGame(let n): return score == n
            case .scoreExact(let n):  return score == n
            default:                  return false
            }
        }
    }

    /// Tick del timer di gioco: valuta la sopravvivenza.
    func onTick(survival: TimeInterval) -> [Achievement] {
        evaluate { if case .survival(let n) = $0 { return survival >= n }; return false }
    }

    /// Fine partita: valuta carriera. CHIAMARE DOPO l'update di ScoreStore in GameOverScene.
    func onGameEnd(mode: GameMode) -> [Achievement] {
        let games = scoreStore.gamesPlayed(for: mode)
        let kills = scoreStore.totalPoints(for: mode)
        return evaluate { trigger in
            switch trigger {
            case .gamesPlayed(let n): return games >= n
            case .totalKills(let n):  return kills >= n
            default:                  return false
            }
        }
    }

    /// Selfie scattato.
    func onSelfie() -> [Achievement] {
        evaluate { if case .selfie = $0 { return true }; return false }
    }

    // MARK: - Galleria

    /// Progresso corrente/target per gli achievement cumulativi (per la galleria). nil per gli altri.
    func progress(for a: Achievement, mode: GameMode = .figlia) -> (current: Int, target: Int)? {
        switch a.trigger {
        case .gamesPlayed(let n): return (min(scoreStore.gamesPlayed(for: mode), n), n)
        case .totalKills(let n):  return (min(scoreStore.totalPoints(for: mode), n), n)
        default:                  return nil
        }
    }

    // MARK: - Core

    private func evaluate(_ matches: (AchievementTrigger) -> Bool) -> [Achievement] {
        var newly: [Achievement] = []
        let now = Date().timeIntervalSince1970
        for a in AchievementCatalog.all where !store.isUnlocked(a.id) && matches(a.trigger) {
            if store.unlock(a.id, at: now) {
                newly.append(a)
                if let gcID = a.gcID { gameCenter.report(achievementIDs: [gcID]) }
            }
        }
        return newly
    }
}
