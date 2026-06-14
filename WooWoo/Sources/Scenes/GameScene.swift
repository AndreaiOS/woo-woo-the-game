import SpriteKit
import CoreMotion
import UIKit

/// Port 1:1 di MyScene.m (2014) — modalità Figlia, la scena di gioco principale.
/// Riferimenti file:riga puntano a Woo Woo The Game/Classes/MyScene.m.
///
/// Concorrenza Swift 6: SKScene è @MainActor (UIKit). Le closure di `Timer` e degli
/// SKAction.run girano sul main thread (RunLoop.main / SKScene update loop), e
/// SKPhysicsContactDelegate.didBegin è invocato dal motore fisico DURANTE lo step di
/// simulazione sul thread di rendering della scena (main). Per questo la conformance è
/// isolata con `@MainActor` (isolated conformance): è l'annotazione suggerita dal compilatore
/// e riflette il fatto reale che i callback di contatto avvengono sul main actor, come update(_:).
/// Le chiamate ad AudioService/Haptics (@MainActor) sono quindi already-on-actor.
final class GameScene: SKScene, @MainActor SKPhysicsContactDelegate {
    private var player: PlayerNode!
    private var mamma: MammaNode!
    private var lifeBar: LifeBarNode!
    private let motionManager = CMMotionManager()
    private var playerVelocity = CGPoint.zero
    private var comeEraGirato = true
    private var mostri = 0
    private var punteggio = 0
    private var colpiMostro = 0
    private var lastSpawnTimeInterval: TimeInterval = 0
    private var lastUpdateTime: TimeInterval = 0
    private var time: Double = 0
    private var gameTimer: Timer?
    private var pauseStart: Date?
    private var previousFireDate: Date?
    private var scoreLabel: SKLabelNode!
    private var timeLabel: SKLabelNode!
    private var accelerometerActive = false

    override func didMove(to view: SKView) {
        physicsWorld.gravity = .zero                       // :55
        physicsWorld.contactDelegate = self
        isUserInteractionEnabled = false                   // abilitato a fine countdown (:850)

        buildBackground()                                  // :61-81
        buildPauseButton()                                 // :83-90
        buildPlayer()                                      // :92-115
        buildMamma()                                       // :118-156
        buildLifeBar()                                     // :158-165
        AudioService.shared.playMusic("main_theme_w_intro.mp3", volume: GameConfig.musicVolume)  // :173-177
        setupHud()                                         // :544-562
        countDown()                                        // :819-870
    }

    // MARK: - Setup (:61-194)

    private func buildBackground() {
        func fullWidth(_ name: String, anchorBottom: Bool = false) -> SKSpriteNode {
            let s = SKSpriteNode(imageNamed: name)
            s.setScale(size.width / s.size.width)
            if anchorBottom { s.anchorPoint = CGPoint(x: 0.5, y: 0); s.position = CGPoint(x: size.width / 2, y: 0) }
            else { s.position = CGPoint(x: size.width / 2, y: size.height / 2) }
            return s
        }
        addChild(fullWidth("bkg_cielo"))                                       // :61-63
        let nuvole = SKSpriteNode(imageNamed: "bkg_nuvole")
        nuvole.position = CGPoint(x: size.width * 2, y: size.height / 2)        // :66
        addChild(nuvole)
        let left = SKAction.move(to: CGPoint(x: -size.width, y: size.height / 2), duration: GameConfig.cloudCycleDuration)
        let right = SKAction.move(to: CGPoint(x: size.width * 2, y: size.height / 2), duration: GameConfig.cloudCycleDuration)
        nuvole.run(.repeatForever(.sequence([left, right])))                   // :70-73
        addChild(fullWidth("bkg_palazzi"))                                     // :75-77
        addChild(fullWidth("bkg_terrazzo", anchorBottom: true))               // :79-81
    }

    private func buildPauseButton() {
        let pause = SKButtonNode(imageNamed: "btn_pausa")
        pause.position = norm(0.25, 0.87)                  // :88
        pause.action = { [weak self] in self?.checkPause() }
        addChild(pause)
    }

    private func buildPlayer() {
        player = PlayerNode.make()
        player.position = GameConfig.Figlia.playerStart     // :93
        player.physicsBody = player.polygonBody()           // :95-110
        player.physicsBody?.categoryBitMask = PhysicsCategory.player   // :112
        addChild(player)
    }

    private func buildMamma() {
        mamma = MammaNode.make()
        mamma.position = CGPoint(x: size.width / 2, y: size.height / 4)   // :119
        mamma.physicsBody = mamma.polygonBody()             // :121-155
        addChild(mamma)
        mamma.vive()                                        // :156
    }

    private func buildLifeBar() {
        lifeBar = LifeBarNode.make()
        lifeBar.position = CGPoint(x: size.width / 2 + 20, y: size.height - 40)   // :159
        lifeBar.setScale(GameConfig.lifeBarScale)           // :161
        addChild(lifeBar)
    }

    private func setupHud() {
        scoreLabel = SKLabelNode(fontNamed: GameConfig.fontNameBold)
        scoreLabel.text = "Hits 000"; scoreLabel.fontSize = GameConfig.hudFontSize
        scoreLabel.fontColor = .red
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.verticalAlignmentMode = .center
        scoreLabel.position = CGPoint(x: size.width - 20, y: size.height - GameConfig.hudY)  // :549
        addChild(scoreLabel)
        timeLabel = SKLabelNode(fontNamed: GameConfig.fontNameBold)
        timeLabel.text = "Time 0"; timeLabel.fontSize = GameConfig.hudFontSize
        timeLabel.fontColor = .red
        timeLabel.horizontalAlignmentMode = .left
        timeLabel.verticalAlignmentMode = .center
        timeLabel.position = CGPoint(x: 25, y: size.height - GameConfig.hudY)                // :558
        addChild(timeLabel)
    }

    // MARK: - Countdown (:819-870)

    private func countDown() {
        let box = SKSpriteNode(imageNamed: "box_pausa")
        box.position = CGPoint(x: size.width / 2, y: size.height / 2)
        box.name = "countdownBox"; addChild(box)
        let label = SKLabelNode(fontNamed: GameConfig.fontNameBold)
        label.text = "3"; label.fontSize = GameConfig.countdownFontSize
        label.fontColor = .black; label.verticalAlignmentMode = .center
        label.position = CGPoint(x: size.width / 2, y: size.height / 2)
        label.name = "countdownLabel"; addChild(label)

        var countTime = GameConfig.countdownStart
        run(.repeatForever(.sequence([.wait(forDuration: GameConfig.countdownInterval), .run { [weak self] in
            guard let self else { return }
            countTime -= 1
            label.text = "\(countTime)"
            if countTime == 0 {                             // :849
                self.isUserInteractionEnabled = true        // :850
                label.removeFromParent(); box.removeFromParent()   // :852-853
                self.removeAction(forKey: "countdown")      // :854
                self.startGameTimer()                       // :856-859
                self.startMonitoringAcceleration()          // :861-863
                self.player.cammina()                       // :865
            }
        }])), withKey: "countdown")
    }

    private func startGameTimer() {
        time = 0                                            // :859
        // Il blocco del Timer è @Sendable ma tocca stato @MainActor (time, timeLabel).
        // Aggiungendolo al RunLoop *corrente* (main, siamo in countDown sul main actor) il fire
        // avviene sul main thread: assumeIsolated rende esplicito questo invariante senza hop.
        let t = Timer(timeInterval: GameConfig.gameTimerInterval, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated {
                guard let self else { return }
                self.time += 0.1                            // :565
                self.timeLabel.text = ScoreFormatter.time(self.time)
            }
        }
        RunLoop.current.add(t, forMode: .common)            // :857 NSRunLoopCommonModes
        gameTimer = t
    }

    // MARK: - Accelerometer (:269-326)

    private func startMonitoringAcceleration() {            // :269-275
        guard motionManager.isAccelerometerAvailable else { return }
        motionManager.startAccelerometerUpdates()
        accelerometerActive = true
    }
    private func stopMonitoringAcceleration() {             // :277-283
        guard accelerometerActive else { return }
        motionManager.stopAccelerometerUpdates()
        accelerometerActive = false
    }

    private func updatePlayerVelocityFromMotion() {         // :285-326
        guard accelerometerActive, let data = motionManager.accelerometerData else { return }
        let dec = GameConfig.Figlia.accelDeceleration
        let sens = GameConfig.Figlia.accelSensitivity
        let maxV = GameConfig.Figlia.accelMaxVelocity
        switch UIDevice.current.orientation {
        case .landscapeLeft:                                // :295-297
            playerVelocity.x = playerVelocity.x * dec + CGFloat(data.acceleration.y) * sens
            comeEraGirato = true
        case .landscapeRight:                               // :299-301
            playerVelocity.x = playerVelocity.x * dec - CGFloat(data.acceleration.y) * sens
            comeEraGirato = false
        default:                                            // :303-306
            playerVelocity.x = comeEraGirato
                ? playerVelocity.x * dec + CGFloat(data.acceleration.y) * sens
                : playerVelocity.x * dec - CGFloat(data.acceleration.y) * sens
        }
        playerVelocity.x = min(max(playerVelocity.x, -maxV), maxV)   // :308-315
        playerVelocity.y = min(max(playerVelocity.y, -maxV), maxV)   // :318-325
    }

    // MARK: - Update loop (:328-386)

    override func update(_ currentTime: TimeInterval) {
        let delta = lastUpdateTime == 0 ? 0 : currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        var pos = player.position
        pos.x += playerVelocity.x                           // :344
        pos.y += playerVelocity.y                           // :345
        // :350 imageWidthHalved = texture.width/5 (NON /2 — peculiarità dell'originale)
        let halfW = (player.texture?.size().width ?? player.size.width) / 5.0
        let halfH = (player.texture?.size().height ?? player.size.height) * 0.5   // :352
        // :359-378 — clamp + azzeramento velocity nello stesso ramo (replica esatta delle 4 if)
        if pos.x < halfW { pos.x = halfW; playerVelocity.x = 0 }
        else if pos.x > size.width - halfW { pos.x = size.width - halfW; playerVelocity.x = 0 }
        if pos.y < halfH { pos.y = halfH; playerVelocity.y = 0 }
        else if pos.y > size.height - halfH { pos.y = size.height - halfH; playerVelocity.y = 0 }
        player.position = pos                               // :380

        updatePlayerVelocityFromMotion()                    // :382

        lastSpawnTimeInterval += delta                      // :330
        if lastSpawnTimeInterval > GameConfig.Figlia.spawnThreshold {   // :331
            lastSpawnTimeInterval = GameConfig.Figlia.spawnReset        // :332
            addMonster()
        }
    }

    // MARK: - Spawn (:388-542)

    private func addMonster() {
        AudioService.shared.playEffect("woowoo.mp3")        // :391-392
        mostri += 1                                         // :394
        let monster = GabbianoNode.make()
        monster.physicsBody = SKPhysicsBody(rectangleOf: monster.size)        // :399
        monster.physicsBody?.isDynamic = true
        monster.physicsBody?.affectedByGravity = false
        monster.physicsBody?.allowsRotation = false         // :436
        monster.physicsBody?.collisionBitMask = 0
        monster.physicsBody?.categoryBitMask = PhysicsCategory.gabbiano       // :401
        monster.physicsBody?.contactTestBitMask = PhysicsCategory.player | PhysicsCategory.mamma | PhysicsCategory.colpi
        monster.vola()                                      // :402

        var movimenti: [SKAction] = []
        // :405 — `(arc4random() % 2) - 1`: di fatto un coin-flip uniforme 50/50. Bool.random() è fedele.
        let isDestra = Bool.random()
        if isDestra {
            monster.position = CGPoint(x: size.width + GameConfig.spawnMargin, y: size.height)   // :408
            movimenti.append(.run { [weak monster] in monster?.xScale = -abs(monster!.xScale) }) // :410 FlipX true
        } else {
            monster.position = CGPoint(x: -GameConfig.spawnMargin, y: size.height)               // :415
        }
        addChild(monster)                                   // :428

        let base = GameConfig.Figlia.velocityBase
        let durata = base / (CGFloat(mostri) + base / 2.0)  // :431-432

        var precX = monster.position.x, precY = monster.position.y   // :420-421
        var precDeltaX: CGFloat = 0                                  // :422
        let maxX = size.width + GameConfig.spawnMargin              // :442
        for _ in 0..<GameConfig.waypointCount {                      // :439-494
            let actualX = CGFloat.random(in: -GameConfig.spawnMargin...maxX)        // :440-443
            let actualY = CGFloat.random(in: monster.size.height...(size.height - 10))   // :445-448
            let deltaX = precX - actualX, deltaY = precY - actualY  // :451-452
            let distance = hypot(deltaX, deltaY)                    // :454
            let dur = (distance / maxX) * durata                    // :456
            appendFlip(&movimenti, deltaX: deltaX, precDeltaX: precDeltaX, node: monster)   // :461-482
            movimenti.append(.move(to: CGPoint(x: actualX, y: actualY), duration: dur))     // :459/:484
            precX = actualX; precY = actualY; precDeltaX = deltaX   // :487-489
        }
        let deltaX = precX - monster.position.x                     // :496
        let distance = hypot(deltaX, precY - monster.position.y)    // :497-499
        appendFlip(&movimenti, deltaX: deltaX, precDeltaX: precDeltaX, node: monster)       // :507-528
        movimenti.append(.move(to: monster.position, duration: (distance / (size.width - 10)) * durata))   // :500-505/:529
        if !isDestra { movimenti.append(.run { [weak monster] in monster?.xScale = -abs(monster!.xScale) }) }   // :531-534
        monster.run(.repeatForever(.sequence(movimenti)), withKey: "path")    // :535-538
    }

    /// :461-482 — le 4 if dell'originale collassano in `flip = deltaX > 0`, ma scattano SOLO
    /// quando sia precDeltaX sia deltaX sono non-zero (i rami con un delta a 0 cadevano nell'else
    /// → nessun flip). FlipX:true ⇒ xScale negativo; FlipX:false ⇒ positivo.
    private func appendFlip(_ actions: inout [SKAction], deltaX: CGFloat, precDeltaX: CGFloat, node: SKSpriteNode) {
        guard precDeltaX != 0, deltaX != 0 else { return }
        let flip: Bool = deltaX > 0
        actions.append(.run { [weak node] in
            guard let node else { return }
            node.xScale = flip ? -abs(node.xScale) : abs(node.xScale)
        })
    }

    // MARK: - Touch (:232-253)

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let t = touches.first else { return }
        if t.location(in: self).x > size.width / 2 {        // :239
            player.zaccaADestra()                           // :240
            AudioService.shared.playEffect("swing_00.mp3")  // :243
        } else {
            player.zaccaASinistra()                         // :247
            AudioService.shared.playEffect("swing_01.mp3")  // :249
        }
    }

    // MARK: - Collisioni (:570-750) — solo le 5 coppie gestite, le altre erano return NO (no-op)

    func didBegin(_ contact: SKPhysicsContact) {
        let a = contact.bodyA, b = contact.bodyB
        let pair = a.categoryBitMask | b.categoryBitMask
        func node(_ cat: UInt32) -> SKNode? {
            a.categoryBitMask == cat ? a.node : (b.categoryBitMask == cat ? b.node : nil)
        }

        switch pair {
        case PhysicsCategory.player | PhysicsCategory.gabbiano,    // :570-578
             PhysicsCategory.player | PhysicsCategory.fuoco:       // :625-634
            colpiMostro += 1
            if colpiMostro <= GameConfig.maxColpi { player.colpita() }
            controllaVita()
        case PhysicsCategory.mamma | PhysicsCategory.gabbiano:     // :580-588
            mamma.soffre()
            colpiMostro += 1
            if colpiMostro <= GameConfig.maxColpi { controllaVita() }
        case PhysicsCategory.colpi | PhysicsCategory.gabbiano:     // :594-601
            if let g = node(PhysicsCategory.gabbiano) as? GabbianoNode { valutaColpo(g) }
        case PhysicsCategory.colpi | PhysicsCategory.fuoco:        // :607-623
            if let f = node(PhysicsCategory.fuoco) as? GabbianoNode {
                f.removeAllActions()                        // :610
                f.muore()                                   // :612
                punteggio += 1                              // :615
                scoreLabel.text = ScoreFormatter.hits(punteggio)   // :617
                AudioService.shared.playEffect("con_la_scopa.mp3") // :620
            }
        default: break
        }
    }

    private func valutaColpo(_ gabbiano: GabbianoNode) {            // :740-750
        // :741 — l'originale chiamava stopActionByTag:777 (nessuna azione con tag 777 → no-op):
        // il gabbiano continua il suo percorso mentre brucia. Non rimuovere "path".
        gabbiano.fuoco()                                    // :743
        AudioService.shared.playEffect("bird_00.mp3")       // :745
        player.physicsBody?.categoryBitMask = PhysicsCategory.esente   // :747
    }

    // MARK: - Vita / Game Over (:761-817)

    private func controllaVita() {
        if colpiMostro < GameConfig.maxColpi {              // :762
            lifeBar.setVita(colpiMostro)                    // :764
        } else if colpiMostro == GameConfig.maxColpi {      // :766
            Haptics.gameOverVibration()                     // :767-768
            isUserInteractionEnabled = false                // :770
            stopMonitoringAcceleration()                    // :771
            player.removeAllActions()                       // :772
            player.muore()                                  // :773
            run(.sequence([.wait(forDuration: GameConfig.gameOverDelay), .run { [weak self] in self?.gameOver() }]))  // :774
        }
    }

    private func gameOver() {                                       // :779-817
        removeAllActions()                                  // :780
        gameTimer?.invalidate()
        AudioService.shared.stopMusic()                     // :806-807
        AudioService.shared.playEffect("mai_capitato.mp3")  // :808-812
        go(to: GameOverScene(size: size, mode: .figlia, score: punteggio), .quick)   // :784-785
    }

    // MARK: - Pausa (:874-941)

    private func checkPause() {
        isPaused = true                                     // :875
        stopMonitoringAcceleration()                        // :876
        player.removeAllActions()                           // :877
        isUserInteractionEnabled = false                    // :878
        pauseStart = Date()                                 // :880
        previousFireDate = gameTimer?.fireDate              // :882
        gameTimer?.fireDate = .distantFuture                // :884

        let riprendi = SKButtonNode(imageNamed: "btn_label", title: "Resume")
        riprendi.position = CGPoint(x: GameConfig.Figlia.pauseResumePos.x * size.width,
                                    y: GameConfig.Figlia.pauseResumePos.y * size.height)   // :892
        riprendi.name = "riprendi"
        riprendi.action = { [weak self] in self?.riprendiDaPause() }
        addChild(riprendi)

        let esci = SKButtonNode(imageNamed: "btn_label", title: "Exit")
        esci.position = CGPoint(x: GameConfig.Figlia.pauseExitPos.x * size.width,
                                y: GameConfig.Figlia.pauseExitPos.y * size.height)         // :903
        esci.name = "esci"
        esci.action = { [weak self] in self?.esci() }
        addChild(esci)
    }

    private func riprendiDaPause() {                                // :926-941
        isPaused = false                                    // :927
        startMonitoringAcceleration()                       // :928
        player.cammina()                                    // :929
        isUserInteractionEnabled = true                     // :931
        if let pauseStart, let previousFireDate {           // :933-935
            let pauseTime = -pauseStart.timeIntervalSinceNow
            gameTimer?.fireDate = previousFireDate.addingTimeInterval(pauseTime)
        }
        childNode(withName: "riprendi")?.removeFromParent() // :937
        childNode(withName: "esci")?.removeFromParent()
    }

    private func esci() {                                           // :911-924
        removeAllActions()                                  // :912
        gameTimer?.invalidate()
        AudioService.shared.stopMusic()                     // :922-923
        go(to: IntroScene(size: size), .quick)              // :915-916
    }

    override func willMove(from view: SKView) {
        gameTimer?.invalidate()
        stopMonitoringAcceleration()
    }
}
