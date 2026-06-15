import XCTest
import SpriteKit
@testable import WooWoo

final class TrailNodeTests: XCTestCase {
    func testSegmentsAppearAndResetClears() {
        let trail = TrailNode()
        // API: addPoint(_:) riceve coordinate scena; TrailNode è fisso a (0,0).
        trail.addPoint(CGPoint(x: 0, y: 0))      // primo punto — nessun segmento
        trail.addPoint(CGPoint(x: 100, y: 0))    // distanza 100 > minSeg 20 → 1 segmento
        XCTAssertEqual(trail.children.count, 1)
        trail.addPoint(CGPoint(x: 105, y: 0))    // distanza 5 < minSeg → nessun segmento
        XCTAssertEqual(trail.children.count, 1)
        trail.reset()
        XCTAssertEqual(trail.children.count, 0)
    }
}
