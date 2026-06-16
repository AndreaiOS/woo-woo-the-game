import XCTest
@testable import WooWoo

@MainActor
final class AchievementServiceTests: XCTestCase {
    final class SpyMirror: GameCenterMirror {
        var reported: [String] = []
        func report(achievementIDs: [String]) { reported += achievementIDs }
    }

    var defaults: UserDefaults!
    var spy: SpyMirror!
    var service: AchievementService!

    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: #file + "svc")!
        defaults.removePersistentDomain(forName: #file + "svc")
        spy = SpyMirror()
        service = AchievementService(store: AchievementStore(defaults: defaults),
                                     scoreStore: ScoreStore(defaults: defaults),
                                     gameCenter: spy)
    }
    override func tearDown() {
        defaults.removePersistentDomain(forName: #file + "svc")
        super.tearDown()
    }

    func testStreakUnlocksRaffica() {
        let new = service.onKill(score: 5, streak: 5)
        XCTAssertEqual(new.map(\.id), ["combo_5"])   // a score 5 nessun achievement di punteggio scatta
    }
    func testStreakAndScoreTogether() {
        // a 25 uccisioni con streak 25: Raffica(5), Furia(10), Scatenato(20), Cacciatore(25)
        let new = service.onKill(score: 25, streak: 25)
        XCTAssertEqual(Set(new.map(\.id)), ["combo_5", "combo_10", "combo_20", "score_25"])
    }
    func testIdempotent() {
        _ = service.onKill(score: 5, streak: 5)
        let again = service.onKill(score: 5, streak: 5)
        XCTAssertTrue(again.isEmpty)
    }
    func testScoreExact42Secret() {
        XCTAssertTrue(service.onKill(score: 41, streak: 1).isEmpty)
        let at42 = service.onKill(score: 42, streak: 1)
        XCTAssertTrue(at42.contains { $0.id == "answer_42" })
    }
    func testSurvival() {
        XCTAssertTrue(service.onTick(survival: 59).isEmpty)
        XCTAssertEqual(service.onTick(survival: 60).map(\.id), ["time_60"])
    }
    func testGameEndCareerUsesScoreStore() {
        let s = ScoreStore(defaults: defaults)
        for _ in 0..<10 { s.addGamePlayed(for: .figlia) }
        s.addTotalPoints(500, for: .figlia)
        let new = service.onGameEnd(mode: .figlia)
        XCTAssertEqual(Set(new.map(\.id)), ["first_game", "games_10", "total_500"])
    }
    func testSelfie() {
        XCTAssertEqual(service.onSelfie().map(\.id), ["selfie_1"])
        XCTAssertTrue(service.onSelfie().isEmpty)
    }
    func testMirrorReportsOnlyGCBacked() {
        _ = service.onKill(score: 50, streak: 1)   // score_50 ha gcID badge_50uccisi; score_25 no
        XCTAssertEqual(spy.reported, ["badge_50uccisi"])
    }
    func testProgressForCumulative() {
        let s = ScoreStore(defaults: defaults)
        s.addTotalPoints(320, for: .figlia)
        let coll = AchievementCatalog.with(id: "total_500")!
        XCTAssertEqual(service.progress(for: coll, mode: .figlia)?.current, 320)
        XCTAssertEqual(service.progress(for: coll, mode: .figlia)?.target, 500)
        let combo = AchievementCatalog.with(id: "combo_5")!
        XCTAssertNil(service.progress(for: combo, mode: .figlia))
    }
}
