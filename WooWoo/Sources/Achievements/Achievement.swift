import Foundation

enum AchievementCategory: String {
    case combo, punteggio, sopravvivenza, carriera, chicche
}

enum AchievementRarity: String {
    case comune, raro, epico
}

/// Condizione di sblocco. Valutata dal service contro lo stato di gioco / ScoreStore.
enum AchievementTrigger: Equatable {
    case streak(Int)            // streak >= n (uccisioni di fila senza danni)
    case scoreInGame(Int)       // punteggio partita >= n
    case scoreExact(Int)        // punteggio partita == n (Niente panico)
    case survival(TimeInterval) // tempo partita >= n
    case gamesPlayed(Int)       // ScoreStore.gamesPlayed >= n
    case totalKills(Int)        // ScoreStore.totalPoints >= n
    case selfie                 // primo selfie
}

struct Achievement: Identifiable, Equatable {
    let id: String
    let title: String
    let detail: String
    let category: AchievementCategory
    let rarity: AchievementRarity
    let trigger: AchievementTrigger
    let gcID: String?       // mirror Game Center se presente
    let isSecret: Bool
}
