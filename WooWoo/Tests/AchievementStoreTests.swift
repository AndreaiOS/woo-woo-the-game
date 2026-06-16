import XCTest
@testable import WooWoo

final class AchievementStoreTests: XCTestCase {
    var defaults: UserDefaults!
    var store: AchievementStore!
    override func setUp() {
        defaults = UserDefaults(suiteName: #file + "ach")!
        defaults.removePersistentDomain(forName: #file + "ach")
        store = AchievementStore(defaults: defaults)
    }
    override func tearDown() {
        defaults.removePersistentDomain(forName: #file + "ach")
        super.tearDown()
    }
    func testStartsLocked() {
        XCTAssertFalse(store.isUnlocked("combo_5"))
    }
    func testUnlockReturnsTrueOnceThenFalse() {
        XCTAssertTrue(store.unlock("combo_5", at: 100))
        XCTAssertFalse(store.unlock("combo_5", at: 200))
        XCTAssertTrue(store.isUnlocked("combo_5"))
    }
    func testUnlockPersists() {
        store.unlock("combo_5", at: 100)
        let reread = AchievementStore(defaults: defaults)
        XCTAssertTrue(reread.isUnlocked("combo_5"))
    }
    func testUnlockDate() {
        store.unlock("combo_5", at: 1000)
        XCTAssertEqual(store.unlockDate("combo_5"), Date(timeIntervalSince1970: 1000))
        XCTAssertNil(store.unlockDate("combo_10"))
    }
}
