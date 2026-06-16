import SpriteKit
import GameKit

/// Game over unificata (figlia/mamma). Port di GameOverScene.m + GameOverSceneMamma.m
/// (duplicate al 90%): l'unica differenza erano i metodi `_mamma` del singleton, la scena
/// di rigioca (MyScene/MyScene2) e la scena punteggi — tutto parametrizzato su `mode`.
/// AdMob/Analytics rimossi: nell'originale i bottoni restavano disabilitati fino al
/// caricamento dell'interstitial o al timeout di 15s (:128-166); senza ads li abilitiamo subito.
final class GameOverScene: SKScene {
    private let mode: GameMode
    private let score: Int
    private let inGameUnlocks: [Achievement]
    private let scoreStore = ScoreStore()

    init(size: CGSize, mode: GameMode, score: Int, inGameUnlocks: [Achievement] = []) {
        self.mode = mode
        self.score = score
        self.inGameUnlocks = inGameUnlocks
        super.init(size: size)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func didMove(to view: SKView) {
        let bg = SKSpriteNode(imageNamed: "splashscreeniPhone5")
        bg.position = CGPoint(x: size.width / 2, y: size.height / 2)
        bg.setScale(size.width / bg.size.width)
        bg.color = .black                          // CCSprite setColor:ccc3(200,200,200) = multiply ×0.784
        bg.colorBlendFactor = 1.0 - 200.0 / 255.0  // LERP verso nero ≡ moltiplicazione su grigio uniforme :28
        addChild(bg)

        // Statistiche PRIMA del check record (ordine originale :78-83)
        scoreStore.addGamePlayed(for: mode)
        scoreStore.addTotalPoints(score, for: mode)
        let isRecord = scoreStore.best(for: mode) < score          // :81
        if isRecord { scoreStore.setBest(score, for: mode) }

        // Achievement di carriera (ScoreStore già aggiornato sopra) + quelli accumulati in partita.
        let careerUnlocks = AchievementService.shared.onGameEnd(mode: mode)
        let recap = inGameUnlocks + careerUnlocks

        let label = SKLabelNode(fontNamed: GameConfig.fontName)
        label.text = "Hai colpito\n\(score) gabbiani "             // :37 (testo esatto)
        label.numberOfLines = 2
        label.preferredMaxLayoutWidth = size.width * 0.6          // serve per il wrap su \n in SKLabelNode
        label.fontSize = 50; label.fontColor = .white
        label.verticalAlignmentMode = .center                     // CCLabelTTF anchor (0.5,0.5); default SKLabelNode è .baseline
        label.position = norm(0.70, 0.55)
        addChild(label)

        if isRecord {                                              // :81-90
            let record = SKLabelNode(fontNamed: GameConfig.fontName)
            record.text = "Nuovo record!! "
            record.fontSize = 50; record.fontColor = .white
            record.verticalAlignmentMode = .center                 // come sopra: centrato verticale per parità con l'originale
            record.position = norm(0.70, 0.30)
            addChild(record)
        }

        buildButtons()

        // Punteggio in classifica come prima. Gli achievement sono ora gestiti dal nuovo
        // AchievementService (recap aggiunto nel task di integrazione GameScene/GameOverScene).
        if GameCenterService.shared.isAuthenticated {
            GameCenterService.shared.submit(score: score, mode: mode)
        }

        buildRecap(recap)
    }

    /// Lista degli achievement sbloccati in questa partita (vuota → niente).
    /// Pannello scuro per contrasto + mini-medaglia (colore=rarità, icona=categoria) per riga.
    private func buildRecap(_ achievements: [Achievement]) {
        guard !achievements.isEmpty else { return }
        let shown = Array(achievements.prefix(4))

        let topYN: CGFloat = 0.66
        let headerYN: CGFloat = 0.58
        let firstRowYN: CGFloat = 0.48
        let stepYN: CGFloat = 0.085
        let bottomYN = firstRowYN - stepYN * CGFloat(shown.count - 1) - 0.05

        // Pannello scuro semitrasparente: fa risaltare il testo sullo sfondo.
        let panel = SKShapeNode(rectOf: CGSize(width: size.width * 0.44,
                                               height: size.height * (topYN - bottomYN)),
                                cornerRadius: 10)
        panel.fillColor = SKColor(white: 0, alpha: 0.55)
        panel.strokeColor = SKColor(white: 1, alpha: 0.25)
        panel.lineWidth = 1
        panel.position = norm(0.30, (topYN + bottomYN) / 2)
        addChild(panel)

        let header = SKLabelNode(fontNamed: GameConfig.fontNameBold)
        header.text = shown.count == 1 ? "Achievement sbloccato!" : "Achievement sbloccati!"
        header.fontSize = 18
        header.fontColor = .yellow
        header.verticalAlignmentMode = .center
        header.horizontalAlignmentMode = .center
        header.position = norm(0.30, headerYN)
        addChild(header)

        for (i, a) in shown.enumerated() {
            let y = firstRowYN - stepYN * CGFloat(i)
            let medal = SKShapeNode(circleOfRadius: 9)
            medal.fillColor = a.rarity.medalColor
            medal.strokeColor = .white
            medal.lineWidth = 1
            medal.position = norm(0.17, y)
            addChild(medal)

            let icon = medalIconLabel(a.category.icon, radius: 9)
            icon.position = medal.position
            addChild(icon)

            let title = SKLabelNode(fontNamed: GameConfig.fontName)
            title.text = a.title
            title.fontSize = 15
            title.fontColor = .white
            title.verticalAlignmentMode = .center
            title.horizontalAlignmentMode = .left
            title.position = norm(0.21, y)
            addChild(title)
        }
    }

    private func buildButtons() {   // posizioni :43-77; abilitati subito (ads rimossi)
        let back = SKButtonNode(imageNamed: "btn_chiudi")
        back.position = CGPoint(x: safeX(norm(0.05, 0).x), y: norm(0, 0.10).y)
        back.action = { [weak self] in
            guard let self else { return }
            self.go(to: IntroScene(size: self.size), .quick)
        }
        addChild(back)

        let punteggi = SKButtonNode(imageNamed: "btn_label", title: "Punteggi")
        punteggi.position = norm(0.70, 0.10)
        punteggi.action = { [weak self] in
            guard let self else { return }
            self.go(to: PunteggiScene(size: self.size, mode: self.mode), .quick)
        }
        addChild(punteggi)

        let medaglie = SKButtonNode(imageNamed: "btn_label", title: "Medaglie")
        medaglie.position = norm(0.30, 0.10)
        medaglie.action = { [weak self] in
            guard let self else { return }
            self.go(to: AchievementsScene(size: self.size), .quick)
        }
        addChild(medaglie)

        let rigioca = SKButtonNode(imageNamed: "btn_rotate_right")
        rigioca.position = CGPoint(x: safeX(norm(0.95, 0).x), y: norm(0, 0.10).y)
        rigioca.action = { [weak self] in
            guard let self else { return }
            let next: SKScene = self.mode == .figlia
                ? GameScene(size: self.size) : GameSceneMamma(size: self.size)
            self.go(to: next, .quick)
        }
        addChild(rigioca)
    }
}
