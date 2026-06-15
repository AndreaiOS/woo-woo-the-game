import XCTest
@testable import WooWoo

final class GameConfigTests: XCTestCase {
    func testDurataFormulaFiglia() {
        // MyScene.m:432 — durata = 180 / (mostri + 90): col 1° mostro ≈ 1.978
        let durata = GameConfig.Figlia.velocityBase / (1 + GameConfig.Figlia.velocityBase / 2)
        XCTAssertEqual(durata, 180.0 / 91.0, accuracy: 0.001)
    }
    func testDurataFormulaMamma() {
        // MyScene2.m:532 — durata = 360 / (mostri + 180)
        let durata = GameConfig.Mamma.velocityBase / (1 + GameConfig.Mamma.velocityBase / 2)
        XCTAssertEqual(durata, 360.0 / 181.0, accuracy: 0.001)
    }
    func testCostantiCardine() {
        XCTAssertEqual(GameConfig.maxColpi, 9)
        XCTAssertEqual(GameConfig.Mamma.bonusGates, [17, 34, 51, 68, 81, 98, 115, 132])
        XCTAssertEqual(GameConfig.Figlia.spawnReset, 3.0)
        XCTAssertEqual(GameConfig.Mamma.spawnReset, 4.5)
    }
}
