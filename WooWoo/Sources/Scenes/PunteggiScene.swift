import SpriteKit
import GameKit

/// Classifica unificata (modalità figlia e mamma).
/// Porta PunteggiScene.m + PunteggiSceneMamma.m — differenze solo in GameMode
/// (leaderboardID e chiavi UserDefaults). Tutto il resto è identico.
final class PunteggiScene: SKScene {
    private let mode: GameMode
    private let scoreStore = ScoreStore()

    init(size: CGSize, mode: GameMode) {
        self.mode = mode
        super.init(size: size)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) non supportato") }

    override func didMove(to view: SKView) {
        buildLayout()
        // :165-171 — al load, se autenticato, invia il record a Game Center
        if GameCenterService.shared.isAuthenticated {
            GameCenterService.shared.submit(score: scoreStore.best(for: mode), mode: mode)
        }
    }

    private func buildLayout() {
        let isIT = Locale.current.language.languageCode?.identifier == "it"
        let record = scoreStore.best(for: mode)
        let partite = scoreStore.gamesPlayed(for: mode)
        let totali = scoreStore.totalPoints(for: mode)
        // :40-43 — media a 0 se una delle due quantità è 0
        let media: Double = (totali != 0 && partite != 0) ? Double(totali) / Double(partite) : 0

        // Background :46-50
        let bg = SKSpriteNode(imageNamed: "splashscreeniPhone5")
        bg.position = CGPoint(x: size.width / 2, y: size.height / 2)
        bg.setScale(size.width / bg.size.width)
        bg.color = .black                          // CCSprite setColor:ccc3(200,200,200) = multiply ×0.784
        bg.colorBlendFactor = 1.0 - 200.0 / 255.0  // LERP verso nero ≡ moltiplicazione su grigio uniforme
        addChild(bg)

        // Titolo :52-65  Moon Flower Bold 60 giallo (0.70, 0.90)
        addLabel(isIT ? "Punteggi" : "Scoreboard",
                 GameConfig.fontNameBold, 60, .yellow, norm(0.70, 0.90))

        // Record: :67-72  Moon Flower 30 bianco (0.70, 0.75)
        addLabel("Record:", GameConfig.fontName, 30, .white, norm(0.70, 0.75))

        // Valore record :74-79  (0.70, 0.65)
        addLabel("\(record) Gabbiani", GameConfig.fontName, 30, .white, norm(0.70, 0.65))

        // Label media :81-96  IT="Punteggio Medio :"  EN="Average points :"  (0.70, 0.50)
        addLabel(isIT ? "Punteggio Medio :" : "Average points :",
                 GameConfig.fontName, 30, .white, norm(0.70, 0.50))

        // Valore media :99-104  (0.70, 0.40)
        addLabel(String(format: "%.2f Gabbiani", media),
                 GameConfig.fontName, 30, .white, norm(0.70, 0.40))

        // Numero partite :107-121  (0.70, 0.25)
        addLabel(isIT ? "Hai giocato \(partite) volte" : "You played \(partite) times",
                 GameConfig.fontName, 30, .white, norm(0.70, 0.25))

        // Bottone chiudi :124-128  (0.05, 0.10) → IntroScene
        let back = SKButtonNode(imageNamed: "btn_chiudi")
        back.position = CGPoint(x: safeX(norm(0.05, 0).x), y: norm(0, 0.10).y)
        back.action = { [weak self] in
            guard let self else { return }
            self.go(to: IntroScene(size: self.size), .quick)
        }
        addChild(back)

        // Bottone Punteggi (leaderboard) :130-139  (0.70, 0.10)
        let classifica = SKButtonNode(imageNamed: "btn_label", title: "Punteggi")
        classifica.position = norm(0.70, 0.10)
        classifica.action = { [weak self] in
            guard let self else { return }
            GameCenterService.shared.showPanel(.leaderboards, mode: self.mode)
        }
        addChild(classifica)

        // Bottone Medaglie (achievements) :141-150  (0.30, 0.10)
        let medaglie = SKButtonNode(imageNamed: "btn_label", title: "Medaglie")
        medaglie.position = norm(0.30, 0.10)
        medaglie.action = { [weak self] in
            guard let self else { return }
            GameCenterService.shared.showPanel(.achievements, mode: self.mode)
        }
        addChild(medaglie)

        // Bottone cestino :159-163  (0.95, 0.10) → cancella + re-init
        // share_punteggi era vuoto e il bottone share era commentato (:151-157) → omesso
        let cestino = SKButtonNode(imageNamed: "btn_cestino")
        cestino.position = CGPoint(x: safeX(norm(0.95, 0).x), y: norm(0, 0.10).y)
        cestino.action = { [weak self] in
            guard let self else { return }
            self.scoreStore.reset(self.mode)       // cancella_punteggi[_mamma] :183-184
            self.removeAllChildren()
            self.buildLayout()                     // re-init come [self init] dell'originale
        }
        addChild(cestino)
    }

    /// Aggiunge una SKLabelNode centrata sul punto, per replicare l'anchor (0.5, 0.5) di
    /// CCLabelTTF (CCPositionTypeNormalized). Impostiamo `.center` orizzontale — ridondante
    /// perché è già il default orizzontale di SKLabelNode, ma esplicito — e `.center`
    /// verticale, che invece è necessario (il default verticale è `.baseline`, non centrato).
    private func addLabel(_ text: String, _ font: String, _ fontSize: CGFloat,
                          _ color: SKColor, _ position: CGPoint) {
        let label = SKLabelNode(fontNamed: font)
        label.text = text
        label.fontSize = fontSize
        label.fontColor = color
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.position = position
        addChild(label)
    }
}
