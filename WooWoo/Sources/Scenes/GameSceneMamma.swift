import SpriteKit

/// Port 1:1 di MyScene2.m (2014) — modalità Mamma, la seconda scena di gioco.
/// Riferimenti file:riga puntano a Woo Woo The Game/Classes/MyScene2.m.
///
/// Differenze strutturali rispetto alla modalità Figlia (GameScene.swift):
/// - NESSUN player e NESSUN accelerometro: nell'originale tutto il blocco player/motion è
///   commentato (MyScene2.m:92-115, :398-457, :1196-1199, :1276-1277, :1329-1330). Si gioca
///   solo col dito che "becca" i gabbiani.
/// - I colpi del dito usano hit-test MANUALE a distanza euclidea (MyScene2.m:281-319/:331-373),
///   non la fisica.
/// - Tre tipi di gabbiano: amico (punto), bonus (cura), mostro (ferisce la mamma se toccato).
///
/// Concorrenza Swift 6: identica a GameScene — conformance @MainActor isolata perché
/// didBegin(_:) è invocato sul main durante lo step fisico, e il blocco del Timer è schedulato
/// sul RunLoop.main (assumeIsolated). Vedi note in GameScene.swift.
final class GameSceneMamma: SKScene, @MainActor SKPhysicsContactDelegate {
    private var mamma: MammaNode!
    private var lifeBar: LifeBarNode!
    private let trail = TrailNode()
    private var movableSprites: [GabbianoNode] = []
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
    // NB: niente player, niente CMMotionManager — l'originale li ha commentati (MyScene2.m:92-115, :398-457).

    override func didMove(to view: SKView) {
        physicsWorld.gravity = .zero                       // :56
        physicsWorld.contactDelegate = self
        isUserInteractionEnabled = false                   // abilitato a fine countdown (:1259)

        buildBackground()                                  // :62-82
        buildPauseButton()                                 // :84-90
        buildMamma()                                       // :118-156
        buildLifeBar()                                     // :158-165
        AudioService.shared.playMusic("main_theme_w_intro.mp3", volume: GameConfig.musicVolume)  // :173-177
        setupHud()                                         // :973-991
        countDown()                                        // :1228-1248
    }

    // MARK: - Setup (:62-201)

    private func buildBackground() {
        func fullWidth(_ name: String, anchorBottom: Bool = false) -> SKSpriteNode {
            let s = SKSpriteNode(imageNamed: name)
            s.setScale(size.width / s.size.width)
            if anchorBottom { s.anchorPoint = CGPoint(x: 0.5, y: 0); s.position = CGPoint(x: size.width / 2, y: 0) }
            else { s.position = CGPoint(x: size.width / 2, y: size.height / 2) }
            return s
        }
        addChild(fullWidth("bkg_cielo"))                                       // :62-64
        let nuvole = SKSpriteNode(imageNamed: "bkg_nuvole")
        nuvole.position = CGPoint(x: size.width * 2, y: size.height / 2)        // :67
        addChild(nuvole)
        let left = SKAction.move(to: CGPoint(x: -size.width, y: size.height / 2), duration: GameConfig.cloudCycleDuration)
        let right = SKAction.move(to: CGPoint(x: size.width * 2, y: size.height / 2), duration: GameConfig.cloudCycleDuration)
        nuvole.run(.repeatForever(.sequence([left, right])))                   // :71-74
        addChild(fullWidth("bkg_palazzi"))                                     // :76-78
        // NB: in MyScene2.m il terrazzo è centrato (:81), non ancorato in basso come nella figlia.
        addChild(fullWidth("bkg_terrazzo"))                                    // :80-82
    }

    private func buildPauseButton() {
        let pause = SKButtonNode(imageNamed: "btn_pausa")
        pause.position = norm(0.25, 0.87)                  // :88
        pause.action = { [weak self] in self?.checkPause() }
        addChild(pause)
    }

    private func buildMamma() {
        mamma = MammaNode.make()
        mamma.position = CGPoint(x: size.width / 2, y: size.height / 4)   // :119
        mamma.physicsBody = mamma.polygonBody()             // :121-154
        addChild(mamma)
        mamma.vive()                                        // :156
    }

    private func buildLifeBar() {
        lifeBar = LifeBarNode.make()
        lifeBar.position = CGPoint(x: size.width / 2 + 20, y: size.height - 40)   // :159
        lifeBar.setScale(GameConfig.lifeBarScale)           // :161 (ramo iPhone 5)
        addChild(lifeBar)
    }

    private func setupHud() {
        // :974-978 — scoreLabel "Hits 000" a destra, rosso.
        scoreLabel = SKLabelNode(fontNamed: GameConfig.fontNameBold)
        scoreLabel.text = "Hits 000"; scoreLabel.fontSize = GameConfig.hudFontSize
        scoreLabel.fontColor = .red
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.verticalAlignmentMode = .center
        scoreLabel.position = CGPoint(x: size.width - 20, y: size.height - GameConfig.hudY)  // :978
        addChild(scoreLabel)
        // :983-987 — timeLabel "Time 0" a sinistra, rosso.
        timeLabel = SKLabelNode(fontNamed: GameConfig.fontNameBold)
        timeLabel.text = "Time 0"; timeLabel.fontSize = GameConfig.hudFontSize
        timeLabel.fontColor = .red
        timeLabel.horizontalAlignmentMode = .left
        timeLabel.verticalAlignmentMode = .center
        timeLabel.position = CGPoint(x: 25, y: size.height - GameConfig.hudY)                // :987
        addChild(timeLabel)
    }

    // MARK: - Countdown (:1228-1272)

    private func countDown() {
        let box = SKSpriteNode(imageNamed: "box_pausa")     // :1230-1232
        box.position = CGPoint(x: size.width / 2, y: size.height / 2)
        box.name = "countdownBox"; addChild(box)
        let label = SKLabelNode(fontNamed: GameConfig.fontNameBold)   // :1234-1240
        label.text = "3"; label.fontSize = GameConfig.countdownFontSize
        label.fontColor = .black; label.verticalAlignmentMode = .center
        label.position = CGPoint(x: size.width / 2, y: size.height / 2)
        label.name = "countdownLabel"; addChild(label)

        var countTime = GameConfig.countdownStart           // :1241
        run(.repeatForever(.sequence([.wait(forDuration: GameConfig.countdownInterval), .run { [weak self] in
            guard let self else { return }
            countTime -= 1                                  // :1253
            label.text = "\(countTime)"                     // :1255
            if countTime == 0 {                             // :1258
                self.isUserInteractionEnabled = true        // :1259
                label.removeFromParent(); box.removeFromParent()   // :1261-1262
                self.removeAction(forKey: "countdown")      // :1263 unschedule
                self.startGameTimer()                       // :1265-1268
                // NB: nessun accelerometro né cammina — l'originale crea solo _motionManager (:1270)
                // ma non lo avvia (tutto il movimento player è commentato).
            }
        }])), withKey: "countdown")
    }

    private func startGameTimer() {
        dispatchPrecondition(condition: .onQueue(.main))    // assumeIsolated sotto dipende da questo
        time = 0                                            // :1268
        // Il blocco del Timer è @Sendable ma tocca stato @MainActor (time, timeLabel).
        // Schedulandolo sul RunLoop *corrente* (main, siamo in countDown sul main actor) il fire
        // avviene sul main thread: assumeIsolated rende esplicito l'invariante senza hop.
        let t = Timer(timeInterval: GameConfig.gameTimerInterval, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated {
                guard let self else { return }
                self.time += 0.1                            // :994
                self.timeLabel.text = ScoreFormatter.time(self.time)   // :995
            }
        }
        RunLoop.current.add(t, forMode: .common)            // :1266 NSRunLoopCommonModes
        gameTimer = t
    }

    // MARK: - Update loop (:458-480)

    override func update(_ currentTime: TimeInterval) {
        let delta = lastUpdateTime == 0 ? 0 : currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        lastSpawnTimeInterval += delta                      // :460
        if lastSpawnTimeInterval > GameConfig.Mamma.spawnThreshold {   // :461
            lastSpawnTimeInterval = GameConfig.Mamma.spawnReset        // :462
            switch SpawnDecision.mamma(mostri: mostri) {              // :464-472
            case .amico:   addAmico()
            case .bonus:   addBonus()
            case .monster: addMonster()
            }
        }
    }

    // MARK: - Spawn (:482-971)

    /// Amico (:650-812): gabbiano normale (`vola`), vale 1 punto, percorso a LOOP infinito.
    /// NB: l'originale `addAmico` chiama `[monster vola]` (NON `volaAmico`), quindi l'amico
    /// vola dritto, non capovolto. È il BONUS che viene capovolto (FlipY), vedi addBonus.
    private func addAmico() {
        let monster = makeGabbiano()                        // :659-667
        monster.isAmico = true                              // :661
        monster.vola()                                      // :667
        let (isDestra, start) = configureStart(monster, leadingFlip: [])   // :670-687
        spawnGabbiano(monster, isDestra: isDestra, leading: start, repeatForever: true, removeAtEnd: false)
    }

    /// Bonus (:482-648): cura la mamma di 3, percorso a LOOP infinito.
    /// L'originale antepone una `CCActionFlipY:true` come PRIMO movimento (:485-486) ⇒
    /// il bonus vola a testa in giù, e resta tale perché la sequenza loopa.
    private func addBonus() {
        let monster = makeGabbiano()                        // :495-503
        monster.isBonus = true                              // :497
        monster.vola()                                      // :503
        // :485-486 — FlipY:true prepende: capovolge verticalmente (yScale negativo).
        let flipY = SKAction.run { [weak monster] in monster?.yScale = -abs(monster!.yScale) }
        let (isDestra, start) = configureStart(monster, leadingFlip: [flipY])   // :508-519
        spawnGabbiano(monster, isDestra: isDestra, leading: start, repeatForever: true, removeAtEnd: false)
    }

    /// Mostro (:814-971): nemico. Creato già in stato `fuoco` (:853). Se toccato col dito
    /// ferisce la mamma. Percorso SINGOLO che termina con fadeOut + removeFromParent (:958-959).
    private func addMonster() {
        let monster = makeGabbiano()                        // :823-831
        monster.isAmico = false                             // :825 setAmico:0
        monster.vola()                                      // :831
        monster.fuoco()                                     // :853
        let (isDestra, start) = configureStart(monster, leadingFlip: [])   // :834-851
        spawnGabbiano(monster, isDestra: isDestra, leading: start, repeatForever: false, removeAtEnd: true)
    }

    /// Parte comune della creazione (suono + contatore + body sensore gabbiano).
    private func makeGabbiano() -> GabbianoNode {
        AudioService.shared.playEffect("woowoo.mp3")        // :490/:654/:818
        mostri += 1                                         // :492/:656/:820
        let monster = GabbianoNode.make()
        monster.physicsBody = SKPhysicsBody(rectangleOf: monster.size)   // :500/:664/:828
        monster.physicsBody?.isDynamic = true
        monster.physicsBody?.affectedByGravity = false
        monster.physicsBody?.allowsRotation = false         // :537/:701/:863
        monster.physicsBody?.collisionBitMask = 0
        monster.physicsBody?.categoryBitMask = PhysicsCategory.gabbiano   // :502/:666/:830
        // contatti: mamma (ferisce) + colpi (preSolve dell'originale, qui mai assegnata ma fedele).
        monster.physicsBody?.contactTestBitMask = PhysicsCategory.mamma | PhysicsCategory.colpi
        return monster
    }

    /// Posiziona il gabbiano sul lato di partenza e prepara la lista dei flip iniziali.
    /// `leadingFlip` sono azioni (es. FlipY del bonus) che precedono il flip di lato.
    /// Ritorna `(isDestra, azioni iniziali)`. NB: nell'originale `(arc4random() % 2) - 1`
    /// è di fatto un coin-flip uniforme; `Bool.random()` è fedele.
    private func configureStart(_ monster: GabbianoNode, leadingFlip: [SKAction]) -> (Bool, [SKAction]) {
        let isDestra = Bool.random()                        // :506/:670/:834
        if isDestra {
            monster.position = CGPoint(x: size.width + GameConfig.spawnMargin, y: size.height)   // :509/:673/:837
            return (true, leadingFlip + [.run { [weak monster] in monster?.xScale = -abs(monster!.xScale) }])   // :511-513 FlipX:true
        } else {
            monster.position = CGPoint(x: -GameConfig.spawnMargin, y: size.height)               // :516/:680/:844
            return (false, leadingFlip)
        }
    }

    /// Genera i 10 waypoint random + il ritorno alla posizione di partenza, costruisce la
    /// sequenza di movimenti (con i flip orizzontali in base ai delta) e la avvia.
    /// `repeatForever` per amico/bonus; `removeAtEnd` aggiunge fadeOut+remove per il mostro.
    private func spawnGabbiano(_ monster: GabbianoNode, isDestra: Bool, leading: [SKAction], repeatForever: Bool, removeAtEnd: Bool) {
        addChild(monster)                                   // :529/:693/:855
        var movimenti: [SKAction] = leading                 // FlipY (bonus) + FlipX lato

        let base = GameConfig.Mamma.velocityBase            // :532/:696/:859
        let durata = base / (CGFloat(mostri) + base / 2.0)  // :533/:697/:860

        var precX = monster.position.x, precY = monster.position.y   // :521-522/:685-686/:849-850
        var precDeltaX: CGFloat = 0                                  // :523/:687/:851
        let maxX = size.width + GameConfig.spawnMargin              // :542/:707/:868
        for _ in 0..<GameConfig.waypointCount {                      // :540-595 / :704-759 / :866-916
            let actualX = CGFloat.random(in: -GameConfig.spawnMargin...maxX)              // :541-544
            let actualY = CGFloat.random(in: monster.size.height...(size.height - 10))    // :546-549
            let deltaX = precX - actualX, deltaY = precY - actualY  // :552-553
            let distance = hypot(deltaX, deltaY)                    // :555
            let dur = (distance / maxX) * durata                    // :557
            appendFlip(&movimenti, deltaX: deltaX, precDeltaX: precDeltaX, node: monster)   // :562-583
            movimenti.append(.move(to: CGPoint(x: actualX, y: actualY), duration: dur))     // :560/:585
            precX = actualX; precY = actualY; precDeltaX = deltaX   // :588-590
        }
        let deltaX = precX - monster.position.x                     // :597
        let distance = hypot(deltaX, precY - monster.position.y)    // :598-600
        appendFlip(&movimenti, deltaX: deltaX, precDeltaX: precDeltaX, node: monster)       // :608-629
        movimenti.append(.move(to: monster.position, duration: (distance / (size.width - 10)) * durata))   // :601-606/:630
        if !isDestra { movimenti.append(.run { [weak monster] in monster?.xScale = -abs(monster!.xScale) }) }   // :632-635 FlipX:true
        if removeAtEnd {                                            // :958-959 (solo mostro)
            movimenti.append(.fadeOut(withDuration: 0.5))
            movimenti.append(.removeFromParent())
        }

        let sequence = SKAction.sequence(movimenti)
        if repeatForever {
            monster.run(.repeatForever(sequence), withKey: "path")   // :806/:642
        } else {
            // Mostro: sequenza singola; a fine percorso si auto-rimuove dalla scena e dall'array.
            monster.run(.sequence([sequence, .run { [weak self, weak monster] in
                guard let monster else { return }
                self?.movableSprites.removeAll { $0 === monster }
            }]), withKey: "path")                                    // :966
        }
        // looper (amico/bonus) rimossi solo dal tocco del dito (fedele a MyScene2.m); l'array è limitato in pratica dal game-over a 9 colpi
        movableSprites.append(monster)                              // :644/:808/:967
    }

    /// :562-583 — le 4 if collassano in `flip = deltaX > 0`, ma scattano SOLO quando sia
    /// precDeltaX sia deltaX sono non-zero (i rami con un delta a 0 cadevano nell'else → niente
    /// flip). FlipX:true ⇒ xScale negativo; FlipX:false ⇒ positivo.
    private func appendFlip(_ actions: inout [SKAction], deltaX: CGFloat, precDeltaX: CGFloat, node: SKSpriteNode) {
        guard precDeltaX != 0, deltaX != 0 else { return }
        let flip: Bool = deltaX > 0
        actions.append(.run { [weak node] in
            guard let node else { return }
            node.xScale = flip ? -abs(node.xScale) : abs(node.xScale)
        })
    }

    // MARK: - Touch (:273-381) — hit-test MANUALE a distanza euclidea (non fisica)

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let t = touches.first else { return }
        let loc = t.location(in: self)
        trail.reset()
        if trail.parent == nil { addChild(trail) }          // :277 streak fisso a (0,0)
        trail.addPoint(loc)                                 // :276-277 (API addPoint, NON position)
        hitTest(at: loc, radius: GameConfig.Mamma.touchRadiusBegan)   // :281-319 (raggio 50)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let t = touches.first else { return }
        let loc = t.location(in: self)
        trail.addPoint(loc)                                 // :328
        hitTest(at: loc, radius: GameConfig.Mamma.touchRadiusMoved)   // :331-373 (raggio 40)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        trail.removeFromParent()                            // :378
        trail.reset()                                       // :379
    }

    /// Port fedele del doppio loop di MyScene2.m:281-319/:331-373.
    /// L'originale itera per indice e, quando colpisce a `i`, rimuove l'elemento e fa `i++`:
    /// la rimozione fa scorrere indietro gli elementi successivi, e l'`i++` aggiuntivo SALTA
    /// l'elemento appena scivolato in posizione `i`. Replico esattamente questo comportamento
    /// (un singolo tocco può colpire più gabbiani, ma con lo skip dovuto al bug originale).
    private func hitTest(at loc: CGPoint, radius: CGFloat) {
        var i = 0
        while i < movableSprites.count {                    // bound rivalutato come [movableSprites count]
            let sprite = movableSprites[i]
            let distance = hypot(sprite.position.x - loc.x, sprite.position.y - loc.y)   // :285-287
            if distance <= radius {                         // :289/:339
                sprite.removeAllActions()                   // :292/:342
                sprite.muore()                              // :294/:344
                if sprite.isAmico {                         // :296-299/:348-351
                    punteggio += 1
                    AudioService.shared.playEffect("bird_00.mp3")
                } else if sprite.isBonus {                  // :300-307/:352-358 — cura fino a 3, clamp a 0
                    for _ in 0..<GameConfig.Mamma.bonusHealAmount where colpiMostro != 0 {
                        colpiMostro -= 1
                        controllaVita()
                    }
                } else {                                    // :308-314/:360-366 — toccare un mostro ferisce la mamma
                    mamma.soffre()
                    colpiMostro += 1
                    if colpiMostro <= GameConfig.maxColpi { controllaVita() }
                }
                scoreLabel.text = ScoreFormatter.hits(punteggio)   // :315/:369
                movableSprites.remove(at: i)                // :316/:370 removeObject
                i += 1                                      // :317/:371 — skip dovuto al bug originale
            } else {
                i += 1
            }
        }
    }

    // MARK: - Collisioni (:1009-1167) — solo le coppie gestite; tutte le altre erano return NO (no-op)

    func didBegin(_ contact: SKPhysicsContact) {
        let a = contact.bodyA, b = contact.bodyB
        let pair = a.categoryBitMask | b.categoryBitMask
        func node(_ cat: UInt32) -> SKNode? {
            a.categoryBitMask == cat ? a.node : (b.categoryBitMask == cat ? b.node : nil)
        }

        switch pair {
        case PhysicsCategory.mamma | PhysicsCategory.gabbiano:     // :1009-1017
            mamma.soffre()
            colpiMostro += 1
            if colpiMostro <= GameConfig.maxColpi { controllaVita() }
        case PhysicsCategory.colpi | PhysicsCategory.gabbiano:     // :1023-1030 (categoria colpi mai assegnata qui)
            if let g = node(PhysicsCategory.gabbiano) as? GabbianoNode { valutaColpo(g) }
        case PhysicsCategory.colpi | PhysicsCategory.fuoco:        // :1036-1052
            if let f = node(PhysicsCategory.fuoco) as? GabbianoNode {
                f.removeAllActions()                        // :1039
                f.muore()                                   // :1041
                punteggio += 1                              // :1044
                scoreLabel.text = ScoreFormatter.hits(punteggio)   // :1046
                AudioService.shared.playEffect("con_la_scopa.mp3") // :1049
            }
        default: break
        }
    }

    private func valutaColpo(_ gabbiano: GabbianoNode) {            // :1169-1176
        // :1170 — stopActionByTag:777 (nessuna azione con quel tag → no-op): il gabbiano
        // continua il percorso mentre brucia. Non rimuovere "path".
        gabbiano.fuoco()                                    // :1172
        AudioService.shared.playEffect("bird_00.mp3")       // :1174
    }

    // MARK: - Vita / Game Over (:1187-1226)

    private func controllaVita() {
        if colpiMostro < GameConfig.maxColpi {              // :1188
            lifeBar.setVita(colpiMostro)                    // :1190
        } else if colpiMostro == GameConfig.maxColpi {      // :1192
            Haptics.gameOverVibration()                     // :1193-1194
            isUserInteractionEnabled = false                // :1196
            // NB: niente stop accelerometro / player (commentati :1197-1199).
            run(.sequence([.wait(forDuration: GameConfig.gameOverDelay), .run { [weak self] in self?.gameOver() }]))  // :1200
        }
    }

    private func gameOver() {                                       // :1205-1226
        removeAllActions()                                  // :1206
        gameTimer?.invalidate()
        AudioService.shared.stopMusic()                     // :1215-1216
        AudioService.shared.playEffect("mai_capitato.mp3")  // :1217-1221
        go(to: GameOverScene(size: size, mode: .mamma, score: punteggio), .quick)   // :1210-1211
    }

    // MARK: - Pausa (:1274-1343)

    private func checkPause() {
        isPaused = true                                     // :1275
        isUserInteractionEnabled = false                    // :1278
        pauseStart = Date()                                 // :1280
        previousFireDate = gameTimer?.fireDate              // :1282
        gameTimer?.fireDate = .distantFuture                // :1284

        let riprendi = SKButtonNode(imageNamed: "btn_label", title: "Resume")
        riprendi.position = CGPoint(x: GameConfig.Mamma.pauseResumePos.x * size.width,
                                    y: GameConfig.Mamma.pauseResumePos.y * size.height)   // :1292
        riprendi.name = "riprendi"
        riprendi.action = { [weak self] in self?.riprendiDaPause() }
        addChild(riprendi)

        let esci = SKButtonNode(imageNamed: "btn_label", title: "Exit")
        esci.position = CGPoint(x: GameConfig.Mamma.pauseExitPos.x * size.width,
                                y: GameConfig.Mamma.pauseExitPos.y * size.height)         // :1303
        esci.name = "esci"
        esci.action = { [weak self] in self?.esci() }
        addChild(esci)
    }

    private func riprendiDaPause() {                                // :1327-1343
        isPaused = false                                    // :1328
        // NB: niente start accelerometro / cammina (commentati :1329-1330).
        isUserInteractionEnabled = true                     // :1332
        if let pauseStart, let previousFireDate {           // :1334-1336
            let pauseTime = -pauseStart.timeIntervalSinceNow
            gameTimer?.fireDate = previousFireDate.addingTimeInterval(pauseTime)
        }
        childNode(withName: "riprendi")?.removeFromParent() // :1338
        childNode(withName: "esci")?.removeFromParent()     // :1339
    }

    private func esci() {                                           // :1311-1324
        removeAllActions()                                  // :1312
        gameTimer?.invalidate()
        AudioService.shared.stopMusic()                     // :1321-1322
        go(to: IntroScene(size: size), .quick)              // :1315-1316
    }

    override func willMove(from view: SKView) {
        gameTimer?.invalidate()
    }
}
