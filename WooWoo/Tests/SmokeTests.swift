import XCTest
@testable import WooWoo

final class SmokeTests: XCTestCase {
    func testSceneSizeKeepsFixedHeightAndDeviceAspect() {
        let size = GameHostView.sceneSize(for: CGSize(width: 2556, height: 1179))  // iPhone 15 Pro landscape (2556:1179 ha lo stesso aspect di 852x393 pt)
        XCTAssertEqual(size.height, 320)
        XCTAssertEqual(size.width, 694, accuracy: 1)
    }

    @MainActor
    func testAchievementToastNodeBuilds() {
        let a = AchievementCatalog.with(id: "combo_5")!
        let node = AchievementToastNode(a)
        XCTAssertFalse(node.children.isEmpty)   // plate + medal + 2 label
    }

    @MainActor
    func testAchievementsSceneBuilds() {
        let scene = AchievementsScene(size: CGSize(width: 694, height: 320))
        XCTAssertNotNil(scene)
    }
}
