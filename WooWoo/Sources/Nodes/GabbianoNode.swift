import SpriteKit

/// Port 1:1 di GabbianoSprite.m (2014).
/// Nota: l'ivar `vita = 2` dell'originale (vola/volaAmico) era il contatore colpi interno;
/// nel port la vita del gabbiano è gestita dalla scena tramite le transizioni di categoria
/// (gabbiano → fuoco → morto), quindi non è modellata qui.
final class GabbianoNode: SKSpriteNode {
    var isAmico = false   // setAmico/returnAmico (GabbianoSprite.m:131-137)
    var isBonus = false   // setBonus/returnBonus (GabbianoSprite.m:139-145)

    /// Factory: GabbianoSprite.m:16-21 — initWithImageNamed:@"gabbiano-zampeVola01".
    static func make() -> GabbianoNode {
        GabbianoNode(imageNamed: "gabbiano-zampeVola01")
    }

    /// GabbianoSprite.m:30-52 — 8 frame, delay 0.05, forever, scale 1.4.
    /// L'originale fa [self setFlipX:false] poi [self setScale:1.4]: setScale impone
    /// scaleX/scaleY positivi, equivalente a flipX:false. Nessun flip verticale.
    func vola() {
        setScale(GameConfig.gabbianoScale)
        run(.repeatForever(.frames("gabbiano-zampeVola", count: 8, timePerFrame: 0.05)), withKey: "vola")
    }

    /// GabbianoSprite.m:54-78 — come vola ma con [self setFlipY:true]: l'amico vola a testa in giù.
    /// setScale:1.4 + flipY:true ⇒ scaleY negativo.
    func volaAmico() {
        setScale(GameConfig.gabbianoScale)
        yScale = -abs(yScale)
        run(.repeatForever(.frames("gabbiano-zampeVola", count: 8, timePerFrame: 0.05)), withKey: "vola")
    }

    /// GabbianoSprite.m:80-109 — gabbiano "in fuoco" dopo il primo colpo: ferma vola (tag 7 e 5),
    /// cambia categoria in fuoco, anima i frame "...Muore" (8 frame, 0.05) forever.
    func fuoco() {
        removeAction(forKey: "vola")
        physicsBody?.categoryBitMask = PhysicsCategory.fuoco
        run(.repeatForever(.frames("gabbiano-zampeVola", count: 8, timePerFrame: 0.05, suffix: "Muore")), withKey: "fuoco")
    }

    /// GabbianoSprite.m:111-129 — frame singolo gabbiano-zampeMuore 0.15s poi removeFromParent.
    func muore() {
        physicsBody?.categoryBitMask = PhysicsCategory.morto
        let anim = SKAction.animate(with: [SKTexture(imageNamed: "gabbiano-zampeMuore")], timePerFrame: 0.15)
        run(.sequence([anim, .removeFromParent()]))
    }
}
