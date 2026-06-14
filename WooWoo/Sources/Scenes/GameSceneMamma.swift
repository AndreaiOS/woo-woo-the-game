import SpriteKit

/// STUB — modalità Mamma, riscritto in un task successivo. Tap → IntroScene.
final class GameSceneMamma: SKScene {
    override func didMove(to view: SKView) {
        backgroundColor = .black
        let label = SKLabelNode(text: "GameSceneMamma (stub) — tap to go back")
        label.fontSize = 24
        label.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(label)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        go(to: IntroScene(size: size), .quick)
    }
}
