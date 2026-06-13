import XCTest
@testable import WooWoo

final class SettingsTests: XCTestCase {
    var defaults: UserDefaults!
    override func setUp() {
        defaults = UserDefaults(suiteName: #file)!
        defaults.removePersistentDomain(forName: #file)
    }
    override func tearDown() {
        defaults.removePersistentDomain(forName: #file)
        super.tearDown()
    }
    func testDefaultsToOffLikeOriginalIntZero() {
        let s = Settings(defaults: defaults)
        XCTAssertFalse(s.isAudioOn)  // chiave "audio" assente → 0 → off
    }
    func testTogglePersistsAsIntOnOriginalKeys() {
        let s = Settings(defaults: defaults)
        s.isAudioOn = true; s.isSoundOn = true; s.isVibroOn = false
        XCTAssertEqual(defaults.integer(forKey: "audio"), 1)
        XCTAssertEqual(defaults.integer(forKey: "sound"), 1)
        XCTAssertEqual(defaults.integer(forKey: "vibro"), 0)
    }
    func testFirstTime() {
        let s = Settings(defaults: defaults)
        XCTAssertTrue(s.isFirstTime)            // "first" == 0 → prima volta
        s.markFirstTimeDone()
        XCTAssertFalse(s.isFirstTime)
        XCTAssertEqual(defaults.integer(forKey: "first"), 1)
    }
}
