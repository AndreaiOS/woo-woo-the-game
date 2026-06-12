import SpriteKit

final class IntroScene: SKScene {
    override func didMove(to view: SKView) {
        backgroundColor = .systemTeal
        let label = SKLabelNode(text: "WooWoo — scaffold OK")
        label.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(label)
    }
}
