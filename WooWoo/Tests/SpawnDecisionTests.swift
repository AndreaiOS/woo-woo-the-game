import XCTest
@testable import WooWoo

final class SpawnDecisionTests: XCTestCase {
    func testPattern() {
        XCTAssertEqual(SpawnDecision.mamma(mostri: 0), .amico)     // :464 primo è amico
        XCTAssertEqual(SpawnDecision.mamma(mostri: 17), .bonus)    // :466 gate
        XCTAssertEqual(SpawnDecision.mamma(mostri: 34), .bonus)
        XCTAssertEqual(SpawnDecision.mamma(mostri: 81), .bonus)
        XCTAssertEqual(SpawnDecision.mamma(mostri: 3), .amico)     // :469 mostri%5 != 0 → amico
        XCTAssertEqual(SpawnDecision.mamma(mostri: 5), .monster)   // :471 multiplo di 5 → mostro
        XCTAssertEqual(SpawnDecision.mamma(mostri: 10), .monster)
        XCTAssertEqual(SpawnDecision.mamma(mostri: 51), .bonus)    // gate vince sul %5
    }
}
