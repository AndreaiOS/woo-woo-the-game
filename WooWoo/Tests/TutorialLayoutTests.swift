import XCTest
@testable import WooWoo

/// Le tutorial hanno il testo disegnato dentro l'immagine (fino a ~17pt dal bordo alto):
/// la pagina scalata non deve MAI eccedere la scena, altrimenti le scritte vengono tagliate.
final class TutorialLayoutTests: XCTestCase {
    private let design = CGSize(width: 568, height: 320)   // tutorial01..05 @ design pt

    func testPageFitsModernWideScene() {
        // iPhone 19.5:9 landscape → GameHostView.sceneSize = 693x320
        let scene = CGSize(width: 693, height: 320)
        let scale = TutorialScene.pageScale(scene: scene, image: design)
        XCTAssertLessThanOrEqual(design.height * scale, scene.height)
        XCTAssertLessThanOrEqual(design.width * scale, scene.width)
        XCTAssertEqual(scale, 1.0, accuracy: 0.001)        // sui wide vince il fit in altezza
    }

    func testPageFillsExactDesignAspect() {
        // iPhone 5 (16:9): la scena coincide col design, nessun letterbox
        let scale = TutorialScene.pageScale(scene: design, image: design)
        XCTAssertEqual(scale, 1.0, accuracy: 0.001)
    }
}
