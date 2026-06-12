import XCTest
@testable import WooWoo

final class SmokeTests: XCTestCase {
    func testSceneSizeKeepsFixedHeightAndDeviceAspect() {
        let size = GameHostView.sceneSize(for: CGSize(width: 2556, height: 1179))  // iPhone 15 Pro landscape px
        XCTAssertEqual(size.height, 320)
        XCTAssertEqual(size.width, 694, accuracy: 1)
    }
}
