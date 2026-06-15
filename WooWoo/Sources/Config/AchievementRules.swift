/// Port esatto di GameOverScene.m:242-343 (identico nella variante Mamma), incluse le stranezze.
enum AchievementRules {
    static func isPrimeLikeOriginal(_ number: Int) -> Bool {   // :321-343
        var i = 2
        while i < number - 1 {
            if number % i == 0 { return false }
            i += 1
        }
        return true
    }

    /// Ordine di ritorno: [level, score] come :311. Vuoto se manca lo score achievement (:310).
    /// `gamesPlayed` è il contatore POST-incremento (semantica originale).
    static func achievements(score: Int, gamesPlayed: Int) -> [String] {
        var scoreAchievement: String?
        var levelAchievement: String?
        if isPrimeLikeOriginal(score) { scoreAchievement = "badge_numeriprimi" }   // :255
        if score == 0 { levelAchievement = "badge_0uccisi" }                       // :262
        if score == 42 { scoreAchievement = "badge_42" }                           // :269
        if score >= 50 { scoreAchievement = "badge_50uccisi" }                     // :275
        if score >= 100 { scoreAchievement = "badge_100uccisi" }                   // :281
        if gamesPlayed == 0 { levelAchievement = "badge_1partita" }                // :287 (irraggiungibile, bug 2014)
        if gamesPlayed == 9 { levelAchievement = "badge_10partite" }               // :294
        if gamesPlayed == 99 { levelAchievement = "badge_100partite" }             // :301
        guard let scoreAchievement else { return [] }                              // :310
        return [levelAchievement, scoreAchievement].compactMap { $0 }
    }
}
