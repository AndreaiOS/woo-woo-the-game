import XCTest
@testable import WooWoo

final class AchievementCatalogTests: XCTestCase {
    func testHas15Achievements() {
        XCTAssertEqual(AchievementCatalog.all.count, 15)
    }
    func testIDsAreUnique() {
        let ids = AchievementCatalog.all.map(\.id)
        XCTAssertEqual(Set(ids).count, ids.count)
    }
    func testGCMirrorOnlyOnExpectedFive() {
        let withGC = AchievementCatalog.all.filter { $0.gcID != nil }.map(\.id).sorted()
        XCTAssertEqual(withGC, ["answer_42", "games_10", "games_100", "score_100", "score_50"])
    }
    func testOnlyAnswer42IsSecret() {
        let secrets = AchievementCatalog.all.filter(\.isSecret).map(\.id)
        XCTAssertEqual(secrets, ["answer_42"])
    }
    func testLookupByID() {
        XCTAssertEqual(AchievementCatalog.with(id: "combo_5")?.title, "Raffica")
        XCTAssertNil(AchievementCatalog.with(id: "nope"))
    }
}
