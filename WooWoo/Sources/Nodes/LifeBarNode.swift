import SpriteKit

/// Port 1:1 di LifeBarSprite.m (2014).
final class LifeBarNode: SKSpriteNode {
    /// Factory: LifeBarSprite.m:12-16 — initWithImageNamed:@"lifebar-01".
    static func make() -> LifeBarNode { LifeBarNode(imageNamed: "lifebar-01") }

    /// LifeBarSprite.m:18-81 — colpi 0...9 → texture lifebar-01...lifebar-10 (case N → N+1).
    /// Fuori range: default vuoto (nessun cambio texture), come lo switch originale.
    func setVita(_ colpi: Int) {
        guard (0...9).contains(colpi) else { return }
        texture = SKTexture(imageNamed: String(format: "lifebar-%02d", colpi + 1))
    }
}
