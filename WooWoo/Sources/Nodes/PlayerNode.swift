import SpriteKit

/// Port 1:1 di PlayerSprite.m (2014).
/// Meccanica chiave: durante lo swing il CORPO del player diventa l'arma cambiando
/// categoria in `colpi`; a fine animazione torna `player` (PlayerSprite.m:66/73, :122/129).
final class PlayerNode: SKSpriteNode {
    private var isSinistra = true
    private var primo = false

    /// Factory: PlayerSprite.m:17-25 — initWithImageNamed:@"figlia_cammina01".
    static func make() -> PlayerNode { PlayerNode(imageNamed: "figlia_cammina01") }

    /// I 7 punti del poligono fisico, relativi al centro dello sprite.
    /// Sorgente canonico: MyScene.m:95-110 (offsetX senza extra, offsetY con -5).
    /// `extraOffsetX`: 0 per sinistra, +30 per destra (PlayerSprite.m:102).
    ///
    /// Nota di parità: l'originale ricostruisce il body anche dentro zacca
    /// (PlayerSprite.m:48-63 / 102-117) dove però l'offsetY NON ha il -5 presente in
    /// MyScene.m. Le due varianti differiscono di 5px; il port usa una sola factory
    /// allineata a MyScene.m (la scena la userà per il body iniziale e zacca la riusa).
    func polygonBody(extraOffsetX: CGFloat = 0) -> SKPhysicsBody {
        let offX = size.width * anchorPoint.x - size.width / 2 + extraOffsetX
        let offY = size.height * anchorPoint.y - size.height / 2 - 5
        let raw: [(CGFloat, CGFloat)] = [(95, 119), (120, 117), (143, 52), (144, 0), (51, 0), (47, 49), (75, 115)]
        let path = CGMutablePath()
        let pts = raw.map { CGPoint(x: $0.0 - offX - size.width / 2, y: $0.1 - offY - size.height / 2) }
        path.addLines(between: pts)
        path.closeSubpath()
        let body = SKPhysicsBody(polygonFrom: path)
        body.isDynamic = true
        body.affectedByGravity = false
        body.allowsRotation = false
        body.collisionBitMask = 0
        body.contactTestBitMask = PhysicsCategory.gabbiano | PhysicsCategory.fuoco
        return body
    }

    /// PlayerSprite.m:138-170 — camminata, 5 frame 0.05 forever.
    func cammina() {
        if !primo { primo = true; isSinistra = true }
        run(.repeatForever(.frames("figlia_cammina", count: 5, timePerFrame: 0.05)), withKey: "cammina")
    }

    /// PlayerSprite.m:28-80 — swing a sinistra: 7 frame, corpo→colpi durante, →player a fine.
    func zaccaASinistra() {
        removeAllActions(); cammina()
        xScale = abs(xScale)                       // setFlipX:false
        if !isSinistra {
            position.x -= 30                       // PlayerSprite.m:46
            physicsBody = polygonBody()            // PlayerSprite.m:48-63
        }
        physicsBody?.categoryBitMask = PhysicsCategory.colpi
        let swing = SKAction.frames("figlia_colpisce", count: 7, timePerFrame: 0.05)
        run(.sequence([swing, .run { [weak self] in
            self?.physicsBody?.categoryBitMask = PhysicsCategory.player
        }]), withKey: "zacca")
        isSinistra = true
    }

    /// PlayerSprite.m:82-136 — speculare: flipX e offset +30.
    func zaccaADestra() {
        removeAllActions(); cammina()
        xScale = -abs(xScale)                      // setFlipX:true
        if isSinistra {
            position.x += 30                       // PlayerSprite.m:100
            physicsBody = polygonBody(extraOffsetX: 30)   // PlayerSprite.m:102-117
        }
        physicsBody?.categoryBitMask = PhysicsCategory.colpi
        let swing = SKAction.frames("figlia_colpisce", count: 7, timePerFrame: 0.05)
        run(.sequence([swing, .run { [weak self] in
            self?.physicsBody?.categoryBitMask = PhysicsCategory.player
        }]), withKey: "zacca")
        isSinistra = false
    }

    /// PlayerSprite.m:172-204 — colpita: categoria `colpita` durante l'animazione
    /// (immune a colpi multipli per-frame), torna `player` a fine. 5 frame 0.05.
    func colpita() {
        physicsBody?.categoryBitMask = PhysicsCategory.colpita
        let anim = SKAction.frames("figlia_colpita", count: 5, timePerFrame: 0.05)
        run(.sequence([anim, .run { [weak self] in
            self?.physicsBody?.categoryBitMask = PhysicsCategory.player
        }]), withKey: "colpita")
    }

    /// PlayerSprite.m:206-238 — morte: ferma cammina, 9 frame 0.10.
    func muore() {
        removeAction(forKey: "cammina")
        isSinistra = true
        run(.frames("figlia_muore", count: 9, timePerFrame: 0.10), withKey: "muore")
    }
}
