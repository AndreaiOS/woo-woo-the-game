import SpriteKit

/// Equivalente di CCButton: sprite + label opzionale, tap → azione.
/// Supporta toggle a due texture (ON/OFF) come i bottoni audio/sound/vibro.
final class SKButtonNode: SKNode {
    private let sprite: SKSpriteNode
    private var normalTexture: SKTexture
    private var selectedTexture: SKTexture?
    private(set) var isSelected = false
    var togglesSelectedState = false
    var action: (() -> Void)?
    var isEnabled = true { didSet { alpha = isEnabled ? 1.0 : 0.5 } }

    init(imageNamed name: String, selectedImageNamed: String? = nil, title: String = "") {
        normalTexture = SKTexture(imageNamed: name)
        selectedTexture = selectedImageNamed.map(SKTexture.init(imageNamed:))
        sprite = SKSpriteNode(texture: normalTexture)
        super.init()
        addChild(sprite)
        if !title.isEmpty {
            let label = SKLabelNode(fontNamed: GameConfig.fontNameBold)
            label.text = title
            label.fontSize = GameConfig.buttonFontSize
            label.fontColor = .black
            label.verticalAlignmentMode = .center
            addChild(label)
        }
        isUserInteractionEnabled = true
    }
    required init?(coder: NSCoder) { fatalError() }

    func setSelected(_ selected: Bool) {
        isSelected = selected
        sprite.texture = (selected ? selectedTexture : nil) ?? normalTexture
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // touch.location(in: self) inverte tutta la catena di scale del node graph:
        // l'hit test resta corretto anche se il bottone stesso è scalato (es. setScale(0.8)).
        guard isEnabled, let touch = touches.first,
              sprite.contains(touch.location(in: self)) else { return }
        if togglesSelectedState { setSelected(!isSelected) }
        action?()
    }
}
