import Foundation

/// Punteggi persistenti per modalità. Chiavi originali di Singleton.m:119-223.
struct ScoreStore {
    private let defaults: UserDefaults
    init(defaults: UserDefaults = .standard) { self.defaults = defaults }

    func best(for mode: GameMode) -> Int { defaults.integer(forKey: "punteggio_massimo" + mode.keySuffix) }
    func setBest(_ value: Int, for mode: GameMode) { defaults.set(value, forKey: "punteggio_massimo" + mode.keySuffix) }

    func gamesPlayed(for mode: GameMode) -> Int { defaults.integer(forKey: "numero_partite" + mode.keySuffix) }
    func addGamePlayed(for mode: GameMode) {
        defaults.set(gamesPlayed(for: mode) + 1, forKey: "numero_partite" + mode.keySuffix)
    }

    func totalPoints(for mode: GameMode) -> Int { defaults.integer(forKey: "punti_totali" + mode.keySuffix) }
    func addTotalPoints(_ value: Int, for mode: GameMode) {
        defaults.set(totalPoints(for: mode) + value, forKey: "punti_totali" + mode.keySuffix)
    }

    func reset(_ mode: GameMode) {                       // cancella_punteggi[_mamma]
        defaults.set(0, forKey: "punti_totali" + mode.keySuffix)
        defaults.set(0, forKey: "numero_partite" + mode.keySuffix)
        defaults.set(0, forKey: "punteggio_massimo" + mode.keySuffix)
    }
}
