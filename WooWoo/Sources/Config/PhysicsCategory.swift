/// I collisionType stringa di Cocos2D come bit mask.
/// Tutti i body sono sensori puri: collisionBitMask = 0 (ogni preSolve originale ritornava NO).
enum PhysicsCategory {
    static let player: UInt32       = 1 << 0  // "playerCollision"
    static let mamma: UInt32        = 1 << 1  // "mammaCollision"
    static let gabbiano: UInt32     = 1 << 2  // "gabbianoCollision"
    static let colpi: UInt32        = 1 << 3  // "colpiCollision" (player durante lo swing)
    static let fuoco: UInt32        = 1 << 4  // "fuocoCollision" (gabbiano colpito una volta)
    static let colpita: UInt32      = 1 << 5  // "colpitaCollision" (player durante anim. colpita)
    static let esente: UInt32       = 1 << 6  // "esenteCollision" (player immune dopo colpo a segno)
    static let mammaColpita: UInt32 = 1 << 7  // "mammaColpitaCollision"
    static let morto: UInt32        = 1 << 8  // "gabbianoMortoCollision"
    static let all: UInt32          = .max
}
