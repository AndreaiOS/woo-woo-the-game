import SpriteKit

extension AchievementRarity {
    /// Colore medaglia: bronzo / argento / oro.
    var medalColor: SKColor {
        switch self {
        case .comune: SKColor(red: 0.77, green: 0.48, blue: 0.24, alpha: 1)
        case .raro:   SKColor(red: 0.80, green: 0.82, blue: 0.86, alpha: 1)
        case .epico:  SKColor(red: 0.96, green: 0.77, blue: 0.26, alpha: 1)
        }
    }
    /// Epico → trattamento "medaglia" più grande/solenne.
    var isMedalStyle: Bool { self == .epico }
}

/// Toast singolo: cartello (comune/raro) o medaglia (epico). Si compone da btn_label + label.
@MainActor
final class AchievementToastNode: SKNode {
    init(_ a: Achievement) {
        super.init()
        let scale: CGFloat = a.rarity.isMedalStyle ? 1.15 : 1.0

        let plate = SKSpriteNode(imageNamed: "btn_label")
        plate.setScale(scale)
        addChild(plate)

        // medaglia (cerchio colorato per rarità) a sinistra
        let r: CGFloat = 14 * scale
        let medal = SKShapeNode(circleOfRadius: r)
        medal.fillColor = a.rarity.medalColor
        medal.strokeColor = .white
        medal.lineWidth = 2
        medal.position = CGPoint(x: -plate.size.width * 0.36, y: 0)
        addChild(medal)

        let title = SKLabelNode(fontNamed: GameConfig.fontNameBold)
        title.text = a.title
        title.fontSize = 18 * scale
        title.fontColor = SKColor(red: 0.71, green: 0.19, blue: 0.04, alpha: 1) // rosso "btn"
        title.verticalAlignmentMode = .center
        title.horizontalAlignmentMode = .center
        title.position = CGPoint(x: r * 0.4, y: 4 * scale)
        addChild(title)

        let detail = SKLabelNode(fontNamed: GameConfig.fontName)
        detail.text = a.isSecret ? "Segreto svelato!" : a.detail
        detail.fontSize = 9 * scale
        detail.fontColor = SKColor(red: 0.35, green: 0.23, blue: 0.0, alpha: 1)
        detail.verticalAlignmentMode = .center
        detail.horizontalAlignmentMode = .center
        detail.position = CGPoint(x: r * 0.4, y: -10 * scale)
        addChild(detail)

        alpha = 0
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) non supportato") }

    /// Slide-in dall'alto, hold ~2s, slide-out, rimozione. Chiama completion alla fine.
    func animate(to shownY: CGFloat, hiddenY: CGFloat, completion: @escaping () -> Void) {
        position.y = hiddenY
        let appear = SKAction.group([.fadeIn(withDuration: 0.25),
                                     .moveTo(y: shownY, duration: 0.25)])
        appear.timingMode = .easeOut
        let disappear = SKAction.group([.fadeOut(withDuration: 0.25),
                                        .moveTo(y: hiddenY, duration: 0.25)])
        run(.sequence([appear, .wait(forDuration: 2.0), disappear, .removeFromParent(),
                       .run(completion)]))
    }
}

/// Mostra i toast in coda (uno alla volta) sopra una scena.
@MainActor
final class AchievementToastPresenter {
    private weak var scene: SKScene?
    private var queue: [Achievement] = []
    private var showing = false
    init(scene: SKScene) { self.scene = scene }

    func enqueue(_ achievements: [Achievement]) {
        guard !achievements.isEmpty else { return }
        queue += achievements
        showNext()
    }

    private func showNext() {
        guard !showing, let scene, !queue.isEmpty else { return }
        showing = true
        let a = queue.removeFirst()
        let toast = AchievementToastNode(a)
        let shownY = scene.size.height - 36
        let hiddenY = scene.size.height + 30
        toast.position = CGPoint(x: scene.size.width / 2, y: hiddenY)
        toast.zPosition = 1000
        scene.addChild(toast)
        toast.animate(to: shownY, hiddenY: hiddenY) { [weak self] in
            self?.showing = false
            self?.showNext()
        }
    }
}
