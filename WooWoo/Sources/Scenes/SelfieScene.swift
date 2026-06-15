import SpriteKit
import UIKit

/// Woowoo Selfie — porting di SelfieScene.m (555 righe).
/// Stato SOLO in memoria (nessuna persistenza, confermato nell'originale).
final class SelfieScene: SKScene {
    private var photoNode: SKSpriteNode?            // foto scattata (:129-134, :363-365)
    private var overlayNode: SKSpriteNode?          // cornice sopra la foto, scale 0.8 (:136-152)
    private var currentCanvas = "WooWooSelfie_canvas01"   // default :111
    private var frameButtons: [SKButtonNode] = []
    private var lastImage: UIImage?
    private var flipped = false

    private let yPositions: [CGFloat] = [0.10, 0.30, 0.50, 0.70, 0.90]

    override func didMove(to view: SKView) { buildLayout() }

    private func buildLayout() {
        let bg = SKSpriteNode(imageNamed: "bkg_cielo")
        bg.position = CGPoint(x: size.width / 2, y: size.height / 2)
        bg.setScale(size.width / bg.size.width)
        bg.color = SKColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)   // :37 ccc3(200,200,200)
        bg.colorBlendFactor = 1.0
        addChild(bg)

        let back = SKButtonNode(imageNamed: "btn_chiudi")
        back.position = CGPoint(x: safeX(norm(0.90, 0).x), y: norm(0, 0.90).y)       // :45
        back.action = { [weak self] in
            guard let self else { return }
            self.go(to: IntroScene(size: self.size), .quick)    // :178-181
        }
        addChild(back)

        // 5 cornici: bottone N usa btn_cornice0(6-N) e canvas0(6-N) (:50-88, :431-505)
        // selfie1 → btn_cornice05/canvas05 ... selfie5 → btn_cornice01/canvas01.
        for (i, y) in yPositions.enumerated() {
            let idx = 5 - i                                    // bottone 1 → cornice 05 … bottone 5 → cornice 01
            let b = SKButtonNode(imageNamed: String(format: "btn_cornice%02d", idx))
            b.setScale(0.8)
            b.position = norm(i == 4 ? 0.15 : 0.10, y)         // la 5ª parte già a 0.15 (:85) — coerente col default canvas01
            b.action = { [weak self] in self?.selectFrame(canvasIndex: idx, buttonRow: i) }
            addChild(b); frameButtons.append(b)
        }

        let foto = SKButtonNode(imageNamed: "btn_foto")
        foto.setScale(0.8)                                                          // :95
        foto.position = CGPoint(x: safeX(norm(0.90, 0).x), y: norm(0, 0.50).y)      // :93
        foto.action = { [weak self] in self?.takePhoto() }
        addChild(foto)

        let flip = SKButtonNode(imageNamed: "btn_rotate_right")
        flip.position = CGPoint(x: safeX(norm(0.90, 0).x), y: norm(0, 0.30).y)      // :101
        flip.action = { [weak self] in self?.flipImage() }
        addChild(flip)

        let share = SKButtonNode(imageNamed: "btn_share")
        share.position = CGPoint(x: safeX(norm(0.90, 0).x), y: norm(0, 0.10).y)     // :107
        share.action = { [weak self] in self?.share() }
        addChild(share)

        updateOverlay()
    }

    private func selectFrame(canvasIndex: Int, buttonRow: Int) {   // :431-505
        currentCanvas = String(format: "WooWooSelfie_canvas%02d", canvasIndex)
        for (i, b) in frameButtons.enumerated() {
            b.position = norm(i == buttonRow ? 0.15 : 0.10, yPositions[i])   // evidenzia la selezionata
        }
        updateOverlay()
    }

    private func takePhoto() {
        CameraPicker.shared.pick { [weak self] image in
            guard let self else { return }
            guard let image else { self.showCameraDeniedAlertIfNeeded(); return }
            self.lastImage = image
            self.flipped = false
            self.showPhoto(image)
        }
    }

    private func showPhoto(_ image: UIImage) {                  // :303-373
        photoNode?.removeFromParent()
        let node = SKSpriteNode(texture: SKTexture(image: image))
        node.position = CGPoint(x: size.width / 2, y: size.height / 2)
        // Riempie la cornice overlay (scale 0.8). La resa esatta dipendeva da
        // costanti per schermi 2014 (IS_WIDESCREEN, :147-151, :363) → DA TARARE A VISTA
        // su device con fotocamera reale (Task 17).
        let target = (overlayNode?.size.height ?? size.height * 0.8) * 0.9
        node.setScale(target / node.size.height)
        addChild(node)
        photoNode = node
        // la foto va SOTTO la cornice: riassicura l'ordine
        updateOverlay()
    }

    private func updateOverlay() {                              // :136-152
        overlayNode?.removeFromParent()
        let o = SKSpriteNode(imageNamed: currentCanvas)
        o.position = CGPoint(x: size.width / 2, y: size.height / 2)
        o.setScale(0.8)
        addChild(o)
        overlayNode = o
    }

    private func flipImage() {                                  // :375-416 — specchia orizzontalmente
        guard let node = photoNode else { return }
        flipped.toggle()
        node.xScale = flipped ? -abs(node.xScale) : abs(node.xScale)
    }

    private func share() {                                      // :164-176 — testo/URL ESATTI
        guard let composite = compositeImage() else { return }  // :165 gate su foto presente → no-op senza foto
        let items: [Any] = ["Woo woo Selfie", URL(string: "http://www.woowoothegame.com/")!, composite]
        let vc = UIActivityViewController(activityItems: items, applicationActivities: nil)
        UIApplication.shared.keyRootViewController?.present(vc, animated: true)
    }

    /// Foto + cornice → UIImage (sostituisce convertSpriteToImage/CCRenderTexture :418-429).
    /// Cattura la regione che unisce foto e cornice direttamente dalla scena renderizzata.
    private func compositeImage() -> UIImage? {
        guard let view, photoNode != nil else { return nil }
        let region = (photoNode?.calculateAccumulatedFrame() ?? .zero).union(overlayNode?.calculateAccumulatedFrame() ?? .zero)
        guard let texture = view.texture(from: self, crop: region) else { return nil }
        return UIImage(cgImage: texture.cgImage())
    }

    private func showCameraDeniedAlertIfNeeded() {
        let alert = UIAlertController(title: "Fotocamera non disponibile",
            message: "Per scattare il Woowoo Selfie abilita la fotocamera in Impostazioni > Privacy.",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        UIApplication.shared.keyRootViewController?.present(alert, animated: true)
    }
}
