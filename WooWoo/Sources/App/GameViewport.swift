import SwiftUI
import SpriteKit

/// SKView ospitata in SwiftUI. Presenta la prima scena al primo layout,
/// quando le dimensioni reali della view sono note.
struct GameViewport: UIViewRepresentable {
    func makeUIView(context: Context) -> GameHostView { GameHostView() }
    func updateUIView(_ uiView: GameHostView, context: Context) {}
}

final class GameHostView: SKView {
    private var lifecycleObserved = false
    // `nonisolated(unsafe)`: la deinit di una UIView è nonisolated e deve leggere i token per
    // rimuovere gli observer. L'accesso è esclusivo (in deinit nessun'altra reference è viva),
    // quindi non c'è data race: l'unsafe è circoscritto e sicuro.
    private nonisolated(unsafe) var lifecycleTokens: [NSObjectProtocol] = []

    override func layoutSubviews() {
        super.layoutSubviews()
        guard scene == nil, bounds.width > 0, bounds.height > 0 else { return }
        ignoresSiblingOrder = false  // l'originale si affida all'ordine di addChild
        let intro = IntroScene(size: GameHostView.sceneSize(for: bounds.size))
        intro.scaleMode = .aspectFill
        presentScene(intro)
        observeLifecycle()
    }

    /// AppDelegate.m:74-92 — pausa globale come il CCDirector originale.
    /// Mettere in pausa la SKView ferma rendering, azioni e fisica di TUTTE le scene,
    /// equivalente moderno di `[[CCDirector sharedDirector] pause]/stopAnimation` su
    /// background e `resume`/`startAnimation` al ritorno in foreground.
    private func observeLifecycle() {
        guard !lifecycleObserved else { return }
        lifecycleObserved = true
        // Le notification UIApplication con `queue: .main` arrivano sul main thread;
        // GameHostView è @MainActor (UIView) → assumeIsolated è sicuro (stesso pattern del progetto).
        let center = NotificationCenter.default
        lifecycleTokens.append(center.addObserver(
            forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated { self?.isPaused = true }
        })
        lifecycleTokens.append(center.addObserver(
            forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated { self?.isPaused = false }
        })
    }

    deinit {
        lifecycleTokens.forEach(NotificationCenter.default.removeObserver)
    }

    /// Altezza logica fissa 320 pt (design iPhone 5 landscape 568x320),
    /// larghezza estesa all'aspect ratio reale del device.
    static func sceneSize(for viewSize: CGSize) -> CGSize {
        let height: CGFloat = 320
        return CGSize(width: (viewSize.width / viewSize.height * height).rounded(), height: height)
    }
}
