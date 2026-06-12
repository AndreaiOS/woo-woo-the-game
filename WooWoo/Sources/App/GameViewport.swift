import SwiftUI
import SpriteKit

/// SKView ospitata in SwiftUI. Presenta la prima scena al primo layout,
/// quando le dimensioni reali della view sono note.
struct GameViewport: UIViewRepresentable {
    func makeUIView(context: Context) -> GameHostView { GameHostView() }
    func updateUIView(_ uiView: GameHostView, context: Context) {}
}

final class GameHostView: SKView {
    override func layoutSubviews() {
        super.layoutSubviews()
        guard scene == nil, bounds.width > 0 else { return }
        ignoresSiblingOrder = false  // l'originale si affida all'ordine di addChild
        let intro = IntroScene(size: GameHostView.sceneSize(for: bounds.size))
        intro.scaleMode = .aspectFill
        presentScene(intro)
    }

    /// Altezza logica fissa 320 pt (design iPhone 5 landscape 568x320),
    /// larghezza estesa all'aspect ratio reale del device.
    static func sceneSize(for viewSize: CGSize) -> CGSize {
        let height: CGFloat = 320
        return CGSize(width: (viewSize.width / viewSize.height * height).rounded(), height: height)
    }
}
