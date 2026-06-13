import XCTest
@testable import WooWoo

final class ScoreStoreTests: XCTestCase {
    var defaults: UserDefaults!
    var store: ScoreStore!
    override func setUp() {
        defaults = UserDefaults(suiteName: #file + "score")!
        defaults.removePersistentDomain(forName: #file + "score")
        store = ScoreStore(defaults: defaults)
    }
    override func tearDown() {
        defaults.removePersistentDomain(forName: #file + "score")
        super.tearDown()
    }
    func testBestUsesOriginalKeysPerMode() {
        store.setBest(42, for: .figlia)
        store.setBest(7, for: .mamma)
        XCTAssertEqual(defaults.integer(forKey: "punteggio_massimo"), 42)
        XCTAssertEqual(defaults.integer(forKey: "punteggio_massimo_mamma"), 7)
        XCTAssertEqual(store.best(for: .figlia), 42)
    }
    func testGamesPlayedIncrement() {
        store.addGamePlayed(for: .figlia)
        store.addGamePlayed(for: .figlia)
        XCTAssertEqual(store.gamesPlayed(for: .figlia), 2)
        XCTAssertEqual(defaults.integer(forKey: "numero_partite"), 2)
        XCTAssertEqual(store.gamesPlayed(for: .mamma), 0)
    }
    func testTotalPointsAccumulate() {
        store.addTotalPoints(10, for: .mamma)
        store.addTotalPoints(5, for: .mamma)
        XCTAssertEqual(store.totalPoints(for: .mamma), 15)
        XCTAssertEqual(defaults.integer(forKey: "punti_totali_mamma"), 15)
    }
    func testResetClearsOnlyThatMode() {
        store.setBest(9, for: .figlia); store.addGamePlayed(for: .figlia); store.addTotalPoints(9, for: .figlia)
        store.setBest(5, for: .mamma)
        store.reset(.figlia)   // cancella_punteggi — Singleton.m:190
        XCTAssertEqual(store.best(for: .figlia), 0)
        XCTAssertEqual(store.gamesPlayed(for: .figlia), 0)
        XCTAssertEqual(store.totalPoints(for: .figlia), 0)
        XCTAssertEqual(store.best(for: .mamma), 5)
        XCTAssertEqual(store.gamesPlayed(for: .mamma), 0)
        XCTAssertEqual(store.totalPoints(for: .mamma), 0)
    }
}
