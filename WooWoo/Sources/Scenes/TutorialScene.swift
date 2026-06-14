import SpriteKit

/// Tutorial a 5 pagine. Port di TutorialScene.m.
/// Un contenitore `background` scorre orizzontalmente (move(to:) 0.5s) per mostrare
/// una pagina alla volta; lo swipe destra→sinistra avanza, la quinta pagina avvia il gioco.
///
/// FRAMING — derivato dal sorgente Cocos2D (:33-60). Lì `background` è una CCSprite con
/// contentSize (w*5, h) e anchorPoint (0.5,0.5): le figlie sono posizionate rispetto al suo
/// angolo basso-sinistro, che con quell'anchor cade a (bgPos.x - 2.5w, bgPos.y - 0.5h).
/// Con bgPos = (2w, 0) e figlia a (w*N, h) la pagina N finisce in world ((N-2.5)w + 2w, 0.5h):
/// all'avvio (nessun move) tutorial1 è centrata a (0.5w, 0.5h) = centro schermo; ogni move(to:)
/// sposta il contenitore di -w e centra l'immagine successiva (t2..t5). In SpriteKit `background`
/// è un SKNode puro (origine = sua position, niente offset d'anchor), quindi per ottenere lo
/// stesso risultato la X locale dev'essere localX(N) = (N - 2.5)*w e la Y = h/2 (centro verticale,
/// non h). I 4 target di move(to:) (w, 0, -w, -2w) e la position iniziale (2w, 0) restano ESATTI.
/// Le tutorial sono 568pt di design ma i device moderni sono più larghi: scalo ogni immagine alla
/// larghezza della scena (come IntroScene per lo sfondo) così riempiono e tassellano senza gap.
/// UIPageControl dell'originale → 5 pallini SKShapeNode (sostituto deciso nel piano).
final class TutorialScene: SKScene {
    private let background = SKNode()
    private var pagina = 0
    private var monoMovimento = false
    private var dots: [SKShapeNode] = []

    override func didMove(to view: SKView) {
        // :28-29 — playEffect controlla già internamente isSoundOn (== [singleton is_sound]).
        AudioService.shared.playEffect("intro_02.mp3")
        isUserInteractionEnabled = true

        // :34 — con questa position iniziale tutorial1 è già centrata a schermo (vedi nota in testa);
        // i move(to:) successivi (-w ciascuno) scorrono verso t2..t5.
        background.position = CGPoint(x: size.width * 2, y: 0)
        addChild(background)

        for i in 1...5 {
            let img = SKSpriteNode(imageNamed: String(format: "tutorial%02d_iPhone", i))
            img.color = SKColor(red: 200 / 255, green: 200 / 255, blue: 200 / 255, alpha: 1)
            img.colorBlendFactor = 1.0                       // tinta ccc3(200,200,200) — :38
            img.setScale(size.width / img.size.width)        // schermo pieno (design 568pt → device più largo)
            // :39-59 — X = (N-2.5)w (centro pagina ai target di gestisci_pagina), Y centrata (vedi nota in testa).
            img.position = CGPoint(x: (CGFloat(i) - 2.5) * size.width, y: size.height / 2)
            background.addChild(img)
        }

        addButton()
        addDots()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        monoMovimento = true                                 // :120-124
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {  // :126-165
        guard monoMovimento, let t = touches.first else { return }
        // :130-137 — movimento = vecchiaX - nuovaX; >0 ⇒ swipe verso sinistra (avanza).
        let movimento = t.previousLocation(in: self).x - t.location(in: self).x
        if movimento > 0, pagina < 5 {                       // :143-153 (pagine 1-5; la 5 avvia il gioco, no overshoot)
            pagina += 1
            gestisciPagina(pagina)
        }
        monoMovimento = false                                // :155
        updateDots()                                         // :158 (pageControl.currentPage = pagina)
    }

    private func gestisciPagina(_ p: Int) {                  // :167-202
        let targets: [Int: CGFloat] = [1: size.width, 2: 0, 3: -size.width, 4: -size.width * 2]
        if let x = targets[p] {
            background.run(.move(to: CGPoint(x: x, y: 0), duration: 0.5))
        } else if p >= 5 {                                   // :194-197 case 5 → start_game
            startGame()
        }
    }

    private func startGame() {                               // :109-118
        AudioService.shared.stopAllEffects()
        go(to: GameScene(size: size), .pushLeft(0.7))
    }

    private func addButton() {
        // :62-69 — Start (0.80, 0.10) → MyScene (GameScene), pushLeft 0.7.
        let start = SKButtonNode(imageNamed: "btn_label", title: "Start")
        start.position = norm(0.80, 0.10)
        start.action = { [weak self] in self?.startGame() }
        addChild(start)

        // :71-76 / :204-210 — chiudi (0.10, 0.90) → IntroScene, pushRight 0.1.
        let close = SKButtonNode(imageNamed: "btn_chiudi")
        close.position = CGPoint(x: safeX(norm(0.10, 0).x), y: norm(0, 0.90).y)
        close.action = { [weak self] in
            guard let self else { return }
            AudioService.shared.stopAllEffects()
            self.go(to: IntroScene(size: self.size), .pushRight(0.1))
        }
        addChild(close)
    }

    private func addDots() {
        for i in 0..<5 {
            let dot = SKShapeNode(circleOfRadius: 4)
            dot.position = CGPoint(x: size.width / 2 + CGFloat(i - 2) * 16, y: 24)
            dot.fillColor = .white
            dot.strokeColor = .clear
            addChild(dot)
            dots.append(dot)
        }
        updateDots()
    }

    private func updateDots() {
        // :158 — pageControl.currentPage = pagina (0-indexato): all'avvio pagina=0 ⇒ dot 0
        // (tutorial1), dopo ogni swipe l'indice segue pagina. Clamp 0...4 a fine corsa.
        let current = min(max(pagina, 0), 4)
        for (i, d) in dots.enumerated() {
            d.alpha = (i == current) ? 1.0 : 0.4
        }
    }
}
