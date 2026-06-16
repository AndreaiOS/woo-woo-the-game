import SpriteKit
import GameKit

/// Menu principale. Port 1:1 di IntroScene.m.
/// Layout in coordinate normalizzate (CCPositionTypeNormalized) come l'originale.
final class IntroScene: SKScene {
    private let settings = Settings()
    private var audioButton: SKButtonNode!
    private var soundButton: SKButtonNode!
    private var vibroButton: SKButtonNode!

    override func didMove(to view: SKView) {
        buildLayout()
        applySettingsState()                      // IntroScene.m:203-236
        GameCenterService.shared.authenticate()   // IntroScene.m:237, :385-414
    }

    private func buildLayout() {
        let bg = SKSpriteNode(imageNamed: "splashscreeniPhone5")
        bg.position = CGPoint(x: size.width / 2, y: size.height / 2)
        bg.setScale(size.width / bg.size.width)   // copre la larghezza estesa
        addChild(bg)

        let title = SKSpriteNode(imageNamed: "woowoothegame_titolo")
        title.position = norm(0.70, 0.85)
        title.setScale(0.5)                        // IntroScene.m:75
        addChild(title)

        let isIT = Locale.current.language.languageCode?.identifier == "it"

        // Nascosto su richiesta: modalità Mamma non esposta nel menu.
        // (GameSceneMamma resta nel codice; per riattivarla scommentare.)
        // // Start Mamma → GameSceneMamma, push left 0.7 (IntroScene.m:344-348)
        // addButton("Start Mamma", at: norm(0.30, 0.60)) { [weak self] in
        //     guard let self else { return }
        //     self.go(to: GameSceneMamma(size: self.size), .pushLeft(0.7))
        // }
        // Start → TutorialScene, push left 0.7 (IntroScene.m:338-342)
        addButton("Start", at: norm(0.70, 0.60)) { [weak self] in
            guard let self else { return }
            self.go(to: TutorialScene(size: self.size), .pushLeft(0.7))
        }
        // Punteggi → PunteggiScene .figlia, transizione "quick" (IntroScene.m:351-356)
        addButton(isIT ? "Punteggi" : "Score records", at: norm(0.70, 0.45)) { [weak self] in
            guard let self else { return }
            self.go(to: PunteggiScene(size: self.size, mode: .figlia), .quick)
        }
        // Nascosto su richiesta: classifica modalità Mamma non esposta nel menu.
        // // Punteggi Mamma → PunteggiScene .mamma, transizione "quick" (IntroScene.m:358-363)
        // addButton(isIT ? "Punteggi Mamma" : "Score records Mother", at: norm(0.30, 0.45)) { [weak self] in
        //     guard let self else { return }
        //     self.go(to: PunteggiScene(size: self.size, mode: .mamma), .quick)
        // }
        // Medaglie → AchievementsScene (galleria achievement in-app)
        addButton(isIT ? "Medaglie" : "Achievements", at: norm(0.30, 0.45)) { [weak self] in
            guard let self else { return }
            self.go(to: AchievementsScene(size: self.size), .quick)
        }
        // Woowoo Selfie → SelfieScene, transizione "quick" (IntroScene.m:365-369)
        addButton("Woowoo Selfie", at: norm(0.70, 0.30)) { [weak self] in
            guard let self else { return }
            self.go(to: SelfieScene(size: self.size), .quick)
        }

        // Nascosto su richiesta: pulsante Store non esposto.
        // let store = SKButtonNode(imageNamed: "btn_store")
        // store.position = norm(0.52, 0.15)
        // store.action = {                          // IntroScene.m:249-258
        //     if let url = URL(string: "http://bit.ly/woowoostore") {
        //         UIApplication.shared.open(url)
        //     }
        // }
        // addChild(store)

        audioButton = toggle("btn_audioON", "btn_audioOFF", at: norm(0.61, 0.15)) { [weak self] on in
            self?.settings.isAudioOn = on
            if on { AudioService.shared.playEffect("music_on.mp3") }   // IntroScene.m:261-272
        }
        soundButton = toggle("btn_soundON", "btn_soundOFF", at: norm(0.70, 0.15)) { [weak self] on in
            self?.settings.isSoundOn = on
            if on { AudioService.shared.playEffect("woowoo.mp3") }     // IntroScene.m:274-285
        }
        vibroButton = toggle("btn_vibroON", "btn_vibroOFF", at: norm(0.79, 0.15)) { [weak self] on in
            self?.settings.isVibroOn = on
            if on { UINotificationFeedbackGenerator().notificationOccurred(.warning) }  // IntroScene.m:287-297
        }

        let info = SKButtonNode(imageNamed: "btn_crediti")
        info.position = norm(0.88, 0.15)
        info.action = { [weak self] in self?.showCredits(isIT: isIT) }   // IntroScene.m:299-336
        addChild(info)
    }

    private func addButton(_ title: String, at p: CGPoint, action: @escaping () -> Void) {
        let b = SKButtonNode(imageNamed: "btn_label", title: title)
        b.position = p
        b.action = action
        addChild(b)
    }

    /// Convenzione Cocos2D (CCButton): selected == false mostra lo sprite ON.
    /// `changed` riceve il nuovo stato ON/OFF *dopo* il toggle del bottone.
    /// SKButtonNode in touchesEnded fa setSelected(!isSelected) PRIMA di action,
    /// quindi a quel punto isSelected riflette già il nuovo stato (come CCButton):
    /// isSelected==false → ora ON → changed(true). Nessun doppio-toggle/inversione.
    private func toggle(_ onImage: String, _ offImage: String, at p: CGPoint,
                        changed: @escaping (Bool) -> Void) -> SKButtonNode {
        let b = SKButtonNode(imageNamed: onImage, selectedImageNamed: offImage)
        b.togglesSelectedState = true
        b.position = p
        b.action = { [weak b] in changed(!(b?.isSelected ?? false)) }
        addChild(b)
        return b
    }

    /// IntroScene.m:203-236 — primo avvio: tutto ON; poi: stato letto da UserDefaults.
    /// setSelected(false) → mostra normalTexture (icona ON), coerente con la convenzione CCButton.
    private func applySettingsState() {
        if settings.isFirstTime {
            settings.isAudioOn = true
            settings.isSoundOn = true
            settings.isVibroOn = true
            settings.markFirstTimeDone()
        }
        audioButton.setSelected(!settings.isAudioOn)
        soundButton.setSelected(!settings.isSoundOn)
        vibroButton.setSelected(!settings.isVibroOn)
    }

    /// IntroScene.m:299-336 — alert crediti. Testo ESATTO dal sorgente (it/en).
    /// L'originale usava CustomIOS7AlertView; qui UIAlertController nativo (deciso nel piano).
    private func showCredits(isIT: Bool) {
        let text = isIT
            ? "Grazie del download!\nSeguici su Facebook:\nfb.com/woowoothegame\n\nCreato e ideato da:\nGiusepe Broccia e Davide Melis\n(sviluppo)\nfb.com/giudasoft\nRiccardo Atzeni (Grafica)\nAndrea Murru (swooluppo iOS)\n\nRingraziamo Sensational Gianni per la musica e l'ispirazione\nfb.com/sensationalgianni"
            : "Thank you for download!\nFollow us on Facebook:\nfb.com/woowoothegame\n\nCreated by:\nGiusepe Broccia and Davide Melis\n(Develop)\nfb.com/giudasoft\nRiccardo Atzeni (Graphics)\nAndrea Murru (Dewoolop iOS)\n\nThanks to Sensational Gianni music and ispiration\nfb.com/sensationalgianni"
        let alert = UIAlertController(title: nil, message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        UIApplication.shared.keyRootViewController?.present(alert, animated: true)
    }
}
