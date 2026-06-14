import SpriteKit

extension SKAction {
    /// Equivalente di CCAnimation costruita da frame numerati: prefix01 … prefixNN (+ suffisso opzionale).
    /// Gli asset nel catalog non hanno estensione né suffisso "-hd": "gabbiano-zampeVola01" ecc.
    static func frames(_ prefix: String, count: Int, timePerFrame: TimeInterval, suffix: String = "") -> SKAction {
        let textures = (1...count).map { SKTexture(imageNamed: String(format: "%@%02d%@", prefix, $0, suffix)) }
        return .animate(with: textures, timePerFrame: timePerFrame)
    }
}
