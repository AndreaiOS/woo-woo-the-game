import XCTest
@testable import WooWoo

final class AchievementRulesTests: XCTestCase {
    func testPrimeQuirks() {     // GameOverScene.m:321-343
        XCTAssertTrue(AchievementRules.isPrimeLikeOriginal(0))   // loop non eseguito → YES
        XCTAssertTrue(AchievementRules.isPrimeLikeOriginal(1))
        XCTAssertTrue(AchievementRules.isPrimeLikeOriginal(2))
        XCTAssertTrue(AchievementRules.isPrimeLikeOriginal(7))
        XCTAssertFalse(AchievementRules.isPrimeLikeOriginal(4))
        XCTAssertFalse(AchievementRules.isPrimeLikeOriginal(9))
    }
    func testReportOnlyWhenScoreAchievementExists() {
        // gamesPlayed è il contatore DOPO l'incremento della partita corrente
        // (GameOverScene.m: aggiungi_partita_giocata :78, updateAchievements :107).
        // badge_1partita (gamesPlayed == 0) era IRRAGGIUNGIBILE già nel 2014 — bug preservato.
        XCTAssertEqual(AchievementRules.achievements(score: 0, gamesPlayed: 5),
                       ["badge_0uccisi", "badge_numeriprimi"])
        XCTAssertEqual(AchievementRules.achievements(score: 6, gamesPlayed: 9), [])
        XCTAssertEqual(AchievementRules.achievements(score: 42, gamesPlayed: 5), ["badge_42"])
        XCTAssertEqual(AchievementRules.achievements(score: 101, gamesPlayed: 5), ["badge_100uccisi"])
        XCTAssertEqual(AchievementRules.achievements(score: 2, gamesPlayed: 9),
                       ["badge_10partite", "badge_numeriprimi"])
        XCTAssertEqual(AchievementRules.achievements(score: 2, gamesPlayed: 1), ["badge_numeriprimi"])
    }
}
