import SpriteKit

/// STUB — classifica (figlia/mamma), riscritto in un task successivo. Tap → IntroScene.
final class PunteggiScene: SKScene {
    private let mode: GameMode

    init(size: CGSize, mode: GameMode) {
        self.mode = mode
        super.init(size: size)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) non supportato") }

    override func didMove(to view: SKView) {
        backgroundColor = .black
        let label = SKLabelNode(text: "PunteggiScene (stub) [\(mode)] — tap to go back")
        label.fontSize = 24
        label.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(label)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        go(to: IntroScene(size: size), .quick)
    }
}
