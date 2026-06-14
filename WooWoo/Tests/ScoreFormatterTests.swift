import XCTest
@testable import WooWoo

final class ScoreFormatterTests: XCTestCase {
    func testHitsPadding() {   // MyScene.m:752-759
        XCTAssertEqual(ScoreFormatter.hits(0), "Hits 000")
        XCTAssertEqual(ScoreFormatter.hits(7), "Hits 007")
        XCTAssertEqual(ScoreFormatter.hits(42), "Hits 042")
        XCTAssertEqual(ScoreFormatter.hits(150), "Hits 150")
    }
    func testTime() {          // MyScene.m:566
        XCTAssertEqual(ScoreFormatter.time(0), "Time 0.0")
        XCTAssertEqual(ScoreFormatter.time(12.34), "Time 12.3")
    }
}
