import SpriteKit

/// Scia del dito in modalità mamma. Segmenti che sfumano in `fade` secondi.
/// Parametri originali: streakWithFade:0.3 minSeg:20 width:6 (MyScene2.m:197).
///
/// Design: TrailNode è sempre a position (0,0) nella scena.
/// I punti vengono forniti in coordinate della scena tramite `addPoint(_:)`.
/// I segmenti (SKShapeNode) sono figli di TrailNode e usano le stesse coordinate
/// della scena, perché TrailNode è all'origine — nessun offset da correggere.
final class TrailNode: SKNode {
    private var lastPoint: CGPoint?

    /// Aggiunge un punto della scia in coordinate della scena (o del parent di TrailNode).
    /// Se la distanza dall'ultimo punto è >= streakMinSegment viene disegnato un segmento.
    func addPoint(_ point: CGPoint) {
        defer { lastPoint = point }
        guard let last = lastPoint,
              hypot(point.x - last.x, point.y - last.y) >= GameConfig.Mamma.streakMinSegment
        else { return }

        let path = CGMutablePath()
        path.move(to: last)
        path.addLine(to: point)

        let segment = SKShapeNode(path: path)
        segment.strokeColor = .white
        segment.lineWidth = GameConfig.Mamma.streakWidth
        segment.lineCap = .round
        addChild(segment)
        segment.run(.sequence([
            .fadeOut(withDuration: GameConfig.Mamma.streakFade),
            .removeFromParent()
        ]))
    }

    /// Cancella la scia e resetta l'ultimo punto.
    func reset() {
        lastPoint = nil
        removeAllChildren()
    }
}
