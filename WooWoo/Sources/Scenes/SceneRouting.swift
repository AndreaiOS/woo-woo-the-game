import SpriteKit

/// Le tre transizioni usate dall'originale.
enum SceneTransition {
    case pushLeft(TimeInterval)   // CCTransitionDirectionLeft
    case pushRight(TimeInterval)  // CCTransitionDirectionRight
    case quick                    // CCTransitionDirectionInvalid, 0.1s → fade rapido

    var skTransition: SKTransition {
        switch self {
        case .pushLeft(let d): SKTransition.push(with: .left, duration: d)
        case .pushRight(let d): SKTransition.push(with: .right, duration: d)
        case .quick: SKTransition.fade(withDuration: 0.1)
        }
    }
}

extension SKScene {
    /// Sostituisce [[CCDirector sharedDirector] replaceScene:withTransition:]
    func go(to scene: SKScene, _ transition: SceneTransition) {
        scene.scaleMode = .aspectFill
        view?.presentScene(scene, transition: transition.skTransition)
    }
    /// positionType CCPositionTypeNormalized
    func norm(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * size.width, y: y * size.height) }
    /// Clamp X dentro la safe area laterale (notch in landscape) per i bottoni ai bordi.
    func safeX(_ x: CGFloat) -> CGFloat {
        guard let view else { return x }
        let insetL = view.safeAreaInsets.left * (size.height / view.bounds.height)
        let insetR = view.safeAreaInsets.right * (size.height / view.bounds.height)
        return min(max(x, insetL + 16), size.width - insetR - 16)
    }
}
