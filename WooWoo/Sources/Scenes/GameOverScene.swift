import SpriteKit

/// STUB — game over (figlia/mamma) con punteggio, riscritto in un task successivo. Tap → IntroScene.
final class GameOverScene: SKScene {
    private let mode: GameMode
    private let score: Int

    init(size: CGSize, mode: GameMode, score: Int) {
        self.mode = mode
        self.score = score
        super.init(size: size)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) non supportato") }

    override func didMove(to view: SKView) {
        backgroundColor = .black
        let label = SKLabelNode(text: "GameOverScene (stub) [\(mode)] score=\(score) — tap to go back")
        label.fontSize = 22
        label.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(label)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        go(to: IntroScene(size: size), .quick)
    }
}
