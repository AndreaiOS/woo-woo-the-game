import SpriteKit

/// Port 1:1 di MammaSprite.m (2014).
final class MammaNode: SKSpriteNode {
    /// Factory: MammaSprite.m:16-22 — initWithImageNamed:@"mamma_statica01".
    static func make() -> MammaNode { MammaNode(imageNamed: "mamma_statica01") }

    /// I 6 punti del poligono (MyScene.m:141-152), offset −20/−5 come l'originale (MyScene.m:121-122).
    func polygonBody() -> SKPhysicsBody {
        let offX = size.width * anchorPoint.x - size.width / 2 - 20
        let offY = size.height * anchorPoint.y - size.height / 2 - 5
        let raw: [(CGFloat, CGFloat)] = [(21, 127), (82, 37), (85, 4), (2, 2), (0, 113), (9, 127)]
        let path = CGMutablePath()
        path.addLines(between: raw.map { CGPoint(x: $0.0 - offX - size.width / 2, y: $0.1 - offY - size.height / 2) })
        path.closeSubpath()
        let body = SKPhysicsBody(polygonFrom: path)
        body.isDynamic = true; body.affectedByGravity = false
        body.allowsRotation = false; body.collisionBitMask = 0
        body.categoryBitMask = PhysicsCategory.mamma
        body.contactTestBitMask = PhysicsCategory.gabbiano
        return body
    }

    /// MammaSprite.m:24-48 — respiro, 3 frame delay 1.0 forever.
    func vive() {
        run(.repeatForever(.frames("mamma_statica", count: 3, timePerFrame: 1.0)), withKey: "vive")
    }

    /// MammaSprite.m:50-86 — sofferenza: categoria `mammaColpita` durante (2 frame x 1.0s),
    /// poi torna `mamma`.
    func soffre() {
        physicsBody?.categoryBitMask = PhysicsCategory.mammaColpita
        let anim = SKAction.frames("mamma_soffre", count: 2, timePerFrame: 1.0)
        run(.sequence([anim, .run { [weak self] in
            self?.physicsBody?.categoryBitMask = PhysicsCategory.mamma
        }]), withKey: "soffre")
    }
}
