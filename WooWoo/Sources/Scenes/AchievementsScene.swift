import SpriteKit

/// Galleria "Medaglie": griglia degli achievement, sbloccati colorati / bloccati grigi,
/// progresso sui cumulativi, segreti come "???". Stile scoreboard (come PunteggiScene).
final class AchievementsScene: SKScene {
    private let service = AchievementService.shared

    override func didMove(to view: SKView) {
        buildBackground()
        buildHeader()
        buildGrid()
        buildBackButton()
    }

    private func buildBackground() {
        let bg = SKSpriteNode(imageNamed: "splashscreeniPhone5")
        bg.position = CGPoint(x: size.width / 2, y: size.height / 2)
        bg.setScale(size.width / bg.size.width)
        bg.color = .black
        bg.colorBlendFactor = 1.0 - 200.0 / 255.0   // come PunteggiScene
        addChild(bg)
    }

    private func buildHeader() {
        let unlocked = AchievementCatalog.all.filter { service.isUnlocked($0.id) }.count
        let title = SKLabelNode(fontNamed: GameConfig.fontNameBold)
        title.text = "Medaglie"
        title.fontSize = 40; title.fontColor = .yellow
        title.verticalAlignmentMode = .center
        title.position = norm(0.5, 0.90)
        addChild(title)

        let count = SKLabelNode(fontNamed: GameConfig.fontName)
        count.text = "\(unlocked) / \(AchievementCatalog.all.count) sbloccate"
        count.fontSize = 16; count.fontColor = .white
        count.verticalAlignmentMode = .center
        count.position = norm(0.5, 0.80)
        addChild(count)
    }

    /// Griglia 5 colonne × 3 righe per i 15 achievement, area centrale.
    private func buildGrid() {
        let cols = 5, rows = 3
        let x0: CGFloat = 0.12, x1: CGFloat = 0.88
        let y0: CGFloat = 0.62, y1: CGFloat = 0.24
        for (i, a) in AchievementCatalog.all.enumerated() {
            let c = i % cols, r = i / cols
            let nx = x0 + (x1 - x0) * (CGFloat(c) / CGFloat(cols - 1))
            let ny = y0 - (y0 - y1) * (CGFloat(r) / CGFloat(rows - 1))
            addChild(makeTile(a, at: norm(nx, ny)))
        }
    }

    private func makeTile(_ a: Achievement, at p: CGPoint) -> SKNode {
        let node = SKNode()
        node.position = p
        let unlocked = service.isUnlocked(a.id)

        let medal = SKShapeNode(circleOfRadius: 16)
        medal.fillColor = unlocked ? a.rarity.medalColor : SKColor(white: 0.3, alpha: 1)
        medal.strokeColor = unlocked ? .white : SKColor(white: 0.5, alpha: 1)
        medal.lineWidth = 2
        node.addChild(medal)

        let medalIcon = medalIconLabel(a.isSecret && !unlocked ? "❓" : a.category.icon, radius: 16)
        medalIcon.alpha = unlocked ? 1.0 : 0.55
        node.addChild(medalIcon)

        let label = SKLabelNode(fontNamed: GameConfig.fontName)
        if a.isSecret && !unlocked {
            label.text = "???"
        } else {
            label.text = a.title
        }
        label.fontSize = 11
        label.fontColor = unlocked ? .white : SKColor(white: 0.6, alpha: 1)
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.position = CGPoint(x: 0, y: -28)
        node.addChild(label)

        // progresso sui cumulativi non ancora sbloccati
        if !unlocked, let prog = service.progress(for: a) {
            let p = SKLabelNode(fontNamed: GameConfig.fontName)
            p.text = "\(prog.current)/\(prog.target)"
            p.fontSize = 9; p.fontColor = SKColor(white: 0.7, alpha: 1)
            p.verticalAlignmentMode = .center
            p.position = CGPoint(x: 0, y: -40)
            node.addChild(p)
        }
        return node
    }

    private func buildBackButton() {
        let back = SKButtonNode(imageNamed: "btn_chiudi")
        back.position = CGPoint(x: safeX(norm(0.06, 0).x), y: norm(0, 0.12).y)
        back.action = { [weak self] in
            guard let self else { return }
            self.go(to: IntroScene(size: self.size), .quick)
        }
        addChild(back)
    }
}
