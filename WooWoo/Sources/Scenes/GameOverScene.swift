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
    private let scoreStore = ScoreStore()

    init(size: CGSize, mode: GameMode, score: Int) {
        self.mode = mode
        self.score = score
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
        let gamesPlayed = scoreStore.gamesPlayed(for: mode)        // POST-incremento, come :243 letto dopo :78
        let isRecord = scoreStore.best(for: mode) < score          // :81
        if isRecord { scoreStore.setBest(score, for: mode) }

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

        // Miglioramento voluto vs originale: l'originale (:103) inviava solo se
        // getLeaderBoardIdentifier era già impostato (dopo aver visitato Punteggi);
        // qui mode.leaderboardID è sempre valido, quindi inviamo sempre se autenticati.
        if GameCenterService.shared.isAuthenticated {              // :102-110
            GameCenterService.shared.submit(score: score, mode: mode)
            GameCenterService.shared.report(achievementIDs:
                AchievementRules.achievements(score: score, gamesPlayed: gamesPlayed))
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
            GameCenterService.shared.showPanel(.achievements, mode: self.mode)   // FIRMA NUOVA
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
