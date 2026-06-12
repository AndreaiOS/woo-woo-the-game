# Woo Woo The Game — Piano di porting a Swift + SpriteKit

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Riscrivere Woo Woo The Game (2014, Objective-C + Cocos2D) in Swift + SpriteKit con parità totale di gameplay, asset e bilanciamento, target iOS 17+, landscape.

**Architecture:** App SwiftUI che ospita una `SKView`; le scene SpriteKit si rimpiazzano tra loro come faceva `CCDirector replaceScene`. Logica di gioco estratta in funzioni pure testabili (`SpawnDecision`, `ScoreFormatter`, `AchievementRules`), costanti centralizzate in `GameConfig` con riferimento riga-per-riga ai sorgenti 2014. Persistenza su UserDefaults con le chiavi originali.

**Tech Stack:** Swift 6, SpriteKit, SwiftUI (shell), CoreMotion, GameKit, AVFoundation, XCTest, XcodeGen.

**Spec di riferimento:** `docs/superpowers/specs/2026-06-12-woowoo-spritekit-port-design.md`

---

## Fonte di verità: i sorgenti 2014

I sorgenti originali sono committati nel repo e sono LA specifica del gameplay. Riferimenti chiave (path base: `Woo Woo The Game/Classes/`):

| Feature | File legacy | Righe chiave |
|---|---|---|
| Gameplay figlia | `MyScene.m` | init 45-194, touch 232-253, accelerometro 269-326, spawn 328-337/388-542, collisioni 570-750, HUD 544-568, vita/gameover 761-817, countdown 819-870, pausa 874-941 |
| Gameplay mamma | `MyScene2.m` | init 48-204, touch 273-381, spawn 458-474, addBonus 482-648, addAmico 650-812, addMonster 814-971, collisioni 1009-1052, vita 1187-1203, gameover 1205-1226, countdown 1228-1272, pausa 1274-1343 |
| Menu | `IntroScene.m` | layout 50-237, toggle 261-296, crediti 300-330, navigazione 338-369, Game Center auth 385-414 |
| Tutorial | `TutorialScene.m` | layout 25-100, swipe 120-165, gestisci_pagina 168-201 |
| Game over | `GameOverScene.m` (+`Mamma`) | layout 25-100, record 78-90, achievements 242-343, navigazione 205-230, GC 345-369 |
| Punteggi | `PunteggiScene.m` (+`Mamma`) | stats 30-122, bottoni 124-170, reportScore 200-213, delete 180-190 |
| Selfie | `SelfieScene.m` | layout 30-130, picker 194-301, didFinish 303-373, flip 375-416, share 164-176 |
| Sprite | `PlayerSprite.m`, `GabbianoSprite.m`, `MammaSprite.m`, `LifeBarSprite.m` | interi (243/147/87/82 righe) |
| Stato/punteggi | `Singleton.m` | 49-223, 319-333 |

**Regola d'oro:** quando un dettaglio non è nel piano (una posizione, una stringa, un if), si apre il file legacy alla riga indicata e si porta 1:1. Non inventare mai un valore.

## Tabella di traduzione Cocos2D → SpriteKit

| Cocos2D | SpriteKit |
|---|---|
| `CCScene` | `SKScene` |
| `CCSprite spriteWithImageNamed:` | `SKSpriteNode(imageNamed:)` (nome senza `-hd`, risolve l'asset catalog) |
| `CCLabelTTF` | `SKLabelNode(fontNamed:)` |
| `CCButton` | `SKButtonNode` (nostro, Task 7) |
| `positionType = Normalized; position = ccp(nx,ny)` | `node.position = scene.norm(nx, ny)` (helper, Task 7) |
| `CCActionMoveTo` | `SKAction.move(to:duration:)` |
| `CCActionSequence` / `RepeatForever` / `CallBlock` | `SKAction.sequence` / `.repeatForever` / `.run` |
| `CCActionAnimate(frames, delay: d)` | `SKAction.animate(with: textures, timePerFrame: d)` |
| `CCActionFlipX actionWithFlipX:true` | `SKAction.run { node.xScale = -abs(node.xScale) }` (false → `+abs`) |
| `setFlipX:true` / `setFlipY:true` | `xScale = -abs(xScale)` / `yScale = -abs(yScale)` |
| `stopAllActions` / `stopActionByTag:` | `removeAllActions()` / `removeAction(forKey:)` |
| `schedule(sel, interval: i)` / `unschedule` | `run(.repeatForever(.sequence([.wait(forDuration: i), .run {…}])), withKey:)` / `removeAction(forKey:)` |
| `CCPhysicsBody bodyWithPolygonFromPoints` | `SKPhysicsBody(polygonFrom: CGPath)` |
| `bodyWithRect:cornerRadius:0` | `SKPhysicsBody(rectangleOf: size, center:)` |
| `collisionType = @"X"` | `categoryBitMask = PhysicsCategory.x` |
| `ccPhysicsCollisionPreSolve … return NO` | `collisionBitMask = 0` ovunque + `didBegin(contact)` solo per le 5 coppie gestite |
| `CCDirector replaceScene:withTransition:` | `go(to:_:)` (helper, Task 7) |
| `self.contentSize` | `self.size` |
| `update:(CCTime)delta` | `update(_ currentTime:)` — **attenzione: currentTime è assoluto, il delta va calcolato** con `lastUpdateTime` |
| `CCMotionStreak` | `TrailNode` (nostro, Task 7) |
| `OALSimpleAudio playBg/playEffect` | `AudioService.shared.playMusic/playEffect` |
| `[[CCDirector] pause]/[resume]` | `scene.isPaused = true/false` |
| `UIPageControl` | 5 pallini `SKShapeNode` (Task 10) |
| `AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)` | `Haptics.gameOverVibration()` |

**Coordinate:** entrambi gli engine hanno origine in basso a sinistra, anchor point default al centro per gli sprite. Le posizioni si copiano senza conversioni.

**Micro-deviazioni accettate (documentate, impatto zero o trascurabile):**
1. `MyScene.m:914`: uscendo dalla pausa in modalità figlia salvava il punteggio nel temp *mamma* (bug originale, valore mai letto). Il port non salva nulla all'uscita.
2. Le collisioni originali usavano `preSolve` (ogni frame); SpriteKit usa `didBegin` (una volta per contatto). L'effetto resta uno-colpo-per-contatto perché l'originale si autolimitava cambiando collisionType durante le animazioni colpita/soffre, che replichiamo.
3. I bottoni del Game Over si abilitano subito (l'originale li abilitava dopo il caricamento dell'interstitial AdMob o timeout 15 s; gli ads sono rimossi).
4. Singleton: i membri morti di un altro progetto (`FBAT`, `listaId/Nomi/Codici`, `scelto`, `setting`) non vengono portati.
5. `LifeBarSprite` aveva scale 1.4 su iPhone 5 e 1.1 su iPhone 4: tutti i device moderni sono widescreen → sempre 1.4.

---

### Task 1: Scaffold del progetto Xcode

**Files:**
- Create: `WooWoo/project.yml`
- Create: `WooWoo/Sources/App/WooWooApp.swift`
- Create: `WooWoo/Sources/App/GameViewport.swift`
- Create: `WooWoo/Sources/App/Info.plist`
- Create: `WooWoo/Sources/Scenes/IntroScene.swift` (stub temporaneo)
- Create: `WooWoo/Tests/SmokeTests.swift`

- [ ] **Step 1: Installa XcodeGen se manca**

Run: `which xcodegen || brew install xcodegen`

- [ ] **Step 2: Crea la struttura cartelle**

```bash
cd "/Users/andreamurru/Documents/Developer/Projects/Woo Woo The Game"
mkdir -p WooWoo/Sources/{App,Scenes,Nodes,Services,Config} WooWoo/Resources WooWoo/Tests
```

- [ ] **Step 3: Scrivi `WooWoo/project.yml`**

```yaml
name: WooWoo
options:
  deploymentTarget:
    iOS: "17.0"
  createIntermediateGroups: true
targets:
  WooWoo:
    type: application
    platform: iOS
    sources:
      - Sources
      - Resources
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: com.woowoothegame
        TARGETED_DEVICE_FAMILY: "1"
        INFOPLIST_FILE: Sources/App/Info.plist
        SWIFT_VERSION: "6.0"
        CODE_SIGN_STYLE: Automatic
        SUPPORTED_INTERFACE_ORIENTATIONS: "UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight"
  WooWooTests:
    type: bundle.unit-test
    platform: iOS
    sources: [Tests]
    dependencies:
      - target: WooWoo
schemes:
  WooWoo:
    build:
      targets:
        WooWoo: all
    test:
      targets: [WooWooTests]
```

- [ ] **Step 4: Scrivi `WooWoo/Sources/App/Info.plist`**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDisplayName</key>
	<string>Woo Woo The Game</string>
	<key>CFBundleShortVersionString</key>
	<string>2.0.0</string>
	<key>CFBundleVersion</key>
	<string>1</string>
	<key>LSRequiresIPhoneOS</key>
	<true/>
	<key>UILaunchScreen</key>
	<dict/>
	<key>UIStatusBarHidden</key>
	<true/>
	<key>UIRequiresFullScreen</key>
	<true/>
	<key>UISupportedInterfaceOrientations</key>
	<array>
		<string>UIInterfaceOrientationLandscapeLeft</string>
		<string>UIInterfaceOrientationLandscapeRight</string>
	</array>
	<key>UIAppFonts</key>
	<array>
		<string>Moon Flower.ttf</string>
		<string>Moon Flower Bold.ttf</string>
	</array>
	<key>NSCameraUsageDescription</key>
	<string>Serve la fotocamera per scattare il tuo Woowoo Selfie con le cornici del gioco.</string>
</dict>
</plist>
```

- [ ] **Step 5: Scrivi `WooWoo/Sources/App/WooWooApp.swift`**

```swift
import SwiftUI

@main
struct WooWooApp: App {
    var body: some Scene {
        WindowGroup {
            GameViewport()
                .ignoresSafeArea()
                .statusBarHidden(true)
                .persistentSystemOverlays(.hidden)
        }
    }
}
```

- [ ] **Step 6: Scrivi `WooWoo/Sources/App/GameViewport.swift`**

```swift
import SwiftUI
import SpriteKit

/// SKView ospitata in SwiftUI. Presenta la prima scena al primo layout,
/// quando le dimensioni reali della view sono note.
struct GameViewport: UIViewRepresentable {
    func makeUIView(context: Context) -> GameHostView { GameHostView() }
    func updateUIView(_ uiView: GameHostView, context: Context) {}
}

final class GameHostView: SKView {
    override func layoutSubviews() {
        super.layoutSubviews()
        guard scene == nil, bounds.width > 0 else { return }
        ignoresSiblingOrder = false  // l'originale si affida all'ordine di addChild
        let intro = IntroScene(size: GameHostView.sceneSize(for: bounds.size))
        intro.scaleMode = .aspectFill
        presentScene(intro)
    }

    /// Altezza logica fissa 320 pt (design iPhone 5 landscape 568x320),
    /// larghezza estesa all'aspect ratio reale del device.
    static func sceneSize(for viewSize: CGSize) -> CGSize {
        let height: CGFloat = 320
        return CGSize(width: (viewSize.width / viewSize.height * height).rounded(), height: height)
    }
}
```

- [ ] **Step 7: Stub `WooWoo/Sources/Scenes/IntroScene.swift`**

```swift
import SpriteKit

final class IntroScene: SKScene {
    override func didMove(to view: SKView) {
        backgroundColor = .systemTeal
        let label = SKLabelNode(text: "WooWoo — scaffold OK")
        label.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(label)
    }
}
```

- [ ] **Step 8: Scrivi `WooWoo/Tests/SmokeTests.swift`**

```swift
import XCTest
@testable import WooWoo

final class SmokeTests: XCTestCase {
    func testSceneSizeKeepsFixedHeightAndDeviceAspect() {
        let size = GameHostView.sceneSize(for: CGSize(width: 2556, height: 1179))  // iPhone 15 Pro landscape px
        XCTAssertEqual(size.height, 320)
        XCTAssertEqual(size.width, 694, accuracy: 1)
    }
}
```

- [ ] **Step 9: Genera il progetto e builda**

```bash
cd "/Users/andreamurru/Documents/Developer/Projects/Woo Woo The Game/WooWoo"
xcodegen generate
xcodebuild -project WooWoo.xcodeproj -scheme WooWoo \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build
```
Expected: `BUILD SUCCEEDED`

- [ ] **Step 10: Lancia i test**

```bash
xcodebuild -project WooWoo.xcodeproj -scheme WooWoo \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' test
```
Expected: `TEST SUCCEEDED` (1 test)

- [ ] **Step 11: Commit**

```bash
git add WooWoo/ && git commit -m "port: scaffold progetto Swift+SpriteKit (XcodeGen, shell SwiftUI, landscape)"
```
Nota: `WooWoo/WooWoo.xcodeproj` è generato — aggiungi `WooWoo/WooWoo.xcodeproj` a `.gitignore` PRIMA del commit.

---

### Task 2: Migrazione asset

**Files:**
- Create: `WooWoo/tools/migrate_assets.sh`
- Create: `WooWoo/Resources/Assets.xcassets/` (generato dallo script)
- Create: `WooWoo/Resources/Audio/` e `WooWoo/Resources/Fonts/` (copiati)

Convenzione legacy: Cocos2D risolveva `nome.png` → `nome-hd.png` (2x). Nel catalog ogni file `-hd` diventa l'immagine **@2x** di un imageset chiamato `nome` (senza suffisso). Dove esiste la variante `-iphone5hd` (più larga, 1136 px) si usa QUELLA come 2x e si ignora la `-hd`. I file senza suffisso (`btn_label.png` + `btn_label@2x.png`, `btn_cornice01-05.png`, `btn_foto.png`, `box_pausa.png`, `spada.png`, `woowoothegame_titolo.png`) si mappano: liscio → 1x, `@2x` → 2x; se esiste solo il liscio → 2x (verifica visiva al primo run).

- [ ] **Step 1: Scrivi `WooWoo/tools/migrate_assets.sh`**

```bash
#!/bin/bash
# Genera Assets.xcassets dagli asset legacy. Idempotente: rigenerabile da zero.
set -euo pipefail
LEGACY="../Woo Woo The Game/Resources"
OUT="Resources/Assets.xcassets"
rm -rf "$OUT" Resources/Audio Resources/Fonts
mkdir -p "$OUT" Resources/Audio Resources/Fonts

cat > "$OUT/Contents.json" <<'EOF'
{ "info": { "author": "xcode", "version": 1 } }
EOF

imageset() {  # $1 = nome imageset, $2 = file 2x, [$3 = file 1x]
  local name="$1" twox="$2" onex="${3:-}"
  local dir="$OUT/$name.imageset"
  mkdir -p "$dir"
  cp "$twox" "$dir/$(basename "$twox")"
  local images="{ \"filename\": \"$(basename "$twox")\", \"idiom\": \"universal\", \"scale\": \"2x\" }"
  if [[ -n "$onex" ]]; then
    cp "$onex" "$dir/$(basename "$onex")"
    images="$images, { \"filename\": \"$(basename "$onex")\", \"idiom\": \"universal\", \"scale\": \"1x\" }"
  fi
  printf '{ "images": [ %s ], "info": { "author": "xcode", "version": 1 } }\n' "$images" > "$dir/Contents.json"
}

# 1. Sprites di animazione: tutte le sottocartelle di sprites/, solo i file -hd
find "$LEGACY/sprites" -name '*-hd.png' | while read -r f; do
  base="$(basename "$f" -hd.png)"
  imageset "$base" "$f"
done

# 2. GamePlay: preferisci -iphone5hd, fallback -hd
for f in "$LEGACY/GamePlay/"*-iphone5hd.png; do
  imageset "$(basename "$f" -iphone5hd.png)" "$f"
done
for f in "$LEGACY/GamePlay/"*-hd.png; do
  base="$(basename "$f" -hd.png)"
  [[ -d "$OUT/$base.imageset" ]] || imageset "$base" "$f"
done

# 3. Pulsanti: -hd come 2x; senza -hd come 2x singolo
for f in "$LEGACY/pulsanti/"*-hd.png; do
  imageset "$(basename "$f" -hd.png)" "$f"
done
for f in "$LEGACY/pulsanti/"*.png; do
  [[ "$f" == *-hd.png ]] && continue
  base="$(basename "$f" .png)"
  [[ -d "$OUT/$base.imageset" ]] || imageset "$base" "$f"
done

# 4. Tutorial (preferisci iphone5hd), selfie, root
for f in "$LEGACY/tutorial/"*-iphone5hd.png; do
  imageset "$(basename "$f" -iphone5hd.png)" "$f"
done
for f in "$LEGACY/selfie/"*.png; do
  imageset "$(basename "$f" .png)" "$f"
done
imageset "splashscreeniPhone5" "$LEGACY/splashscreeniPhone5-iphone5hd.png"
imageset "woowoothegame_titolo" "$LEGACY/woowoothegame_titolo.png"
imageset "btn_label" "$LEGACY/btn_label@2x.png" "$LEGACY/btn_label.png"
imageset "spada" "$LEGACY/spada.png"
imageset "riga_pattern" "$LEGACY/riga_pattern.png"

# 5. Audio e font
cp "$LEGACY/audio/"*.mp3 Resources/Audio/
cp "$LEGACY/fonts/"*.ttf Resources/Fonts/

# 6. AppIcon dalla 1024
mkdir -p "$OUT/AppIcon.appiconset"
cp "$LEGACY/App-ico/AppIco1024.png" "$OUT/AppIcon.appiconset/AppIco1024.png"
cat > "$OUT/AppIcon.appiconset/Contents.json" <<'EOF'
{ "images": [ { "filename": "AppIco1024.png", "idiom": "universal", "platform": "ios", "size": "1024x1024" } ],
  "info": { "author": "xcode", "version": 1 } }
EOF

echo "Imageset generati: $(ls "$OUT" | wc -l)"
```

- [ ] **Step 2: Esegui lo script**

```bash
cd "/Users/andreamurru/Documents/Developer/Projects/Woo Woo The Game/WooWoo"
chmod +x tools/migrate_assets.sh && ./tools/migrate_assets.sh
```
Expected: `Imageset generati:` ~100+ (53 animazioni + GamePlay + pulsanti + tutorial + selfie + root + AppIcon)

- [ ] **Step 3: Aggiungi `ASSETCATALOG_COMPILER_APPICON_NAME: AppIcon` ai settings del target in `project.yml`, rigenera e builda**

```bash
xcodegen generate && xcodebuild -project WooWoo.xcodeproj -scheme WooWoo \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build
```
Expected: `BUILD SUCCEEDED` (il catalog compila; eventuali warning su PNG sono OK)

- [ ] **Step 4: Verifica che gli imageset critici esistano**

```bash
for n in figlia_cammina01 gabbiano-zampeVola01 mamma_statica01 lifebar-01 bkg_cielo bkg_terrazzo btn_label btn_pausa box_pausa splashscreeniPhone5 tutorial01_iPhone WooWooSelfie_canvas01 btn_cornice01; do
  test -d "Resources/Assets.xcassets/$n.imageset" && echo "OK $n" || echo "MANCA $n"; done
```
Expected: tutti `OK`

- [ ] **Step 5: Commit**

```bash
git add WooWoo/ && git commit -m "port: migrazione asset (xcassets da -hd/@2x, audio mp3, font Moon Flower)"
```

---

### Task 3: GameConfig — le costanti di gameplay

**Files:**
- Create: `WooWoo/Sources/Config/GameConfig.swift`
- Test: `WooWoo/Tests/GameConfigTests.swift`

- [ ] **Step 1: Scrivi `GameConfig.swift`** (ogni valore cita il sorgente legacy)

```swift
import CoreGraphics

/// Costanti di gameplay estratte 1:1 dai sorgenti 2014.
/// NON modificare i valori: la parità di gameplay si verifica confrontando
/// questo file con i riferimenti file:riga indicati.
enum GameConfig {
    /// Altezza logica della scena (design iPhone 5 landscape: 568x320 pt)
    static let designHeight: CGFloat = 320

    enum Figlia {                                    // MyScene.m
        static let spawnThreshold: TimeInterval = 5.2    // :331
        static let spawnReset: TimeInterval = 3.0        // :332
        static let velocityBase: CGFloat = 180.0         // :431 (durata = 180/(mostri+90))
        static let playerStart = CGPoint(x: 100, y: 105) // :93
        static let accelDeceleration: CGFloat = 0.1      // :293
        static let accelSensitivity: CGFloat = 20.0      // :293
        static let accelMaxVelocity: CGFloat = 1400      // :293
        static let pauseResumePos = CGPoint(x: 0.50, y: 0.50)  // :892
        static let pauseExitPos = CGPoint(x: 0.50, y: 0.65)    // :903
    }

    enum Mamma {                                     // MyScene2.m
        static let spawnThreshold: TimeInterval = 5.2    // :461
        static let spawnReset: TimeInterval = 4.5        // :462
        static let velocityBase: CGFloat = 360.0         // :532, :859 (durata = 360/(mostri+180))
        static let touchRadiusBegan: CGFloat = 50        // :289
        static let touchRadiusMoved: CGFloat = 40        // :339
        static let bonusGates: Set<Int> = [17, 34, 51, 68, 81, 98, 115, 132]  // :466
        static let bonusHealAmount = 3                   // :301-306
        static let streakFade: TimeInterval = 0.3        // :197
        static let streakMinSegment: CGFloat = 20        // :197
        static let streakWidth: CGFloat = 6              // :197
        static let pauseResumePos = CGPoint(x: 0.50, y: 0.35)  // :1292
        static let pauseExitPos = CGPoint(x: 0.50, y: 0.65)    // :1303
    }

    // Comuni a entrambe le modalità
    static let maxColpi = 9                          // MyScene.m:766, MyScene2.m:1188
    static let gameOverDelay: TimeInterval = 0.90    // MyScene.m:774
    static let countdownStart = 3                    // MyScene.m:832
    static let countdownInterval: TimeInterval = 1.0 // MyScene.m:834
    static let gameTimerInterval: TimeInterval = 0.1 // MyScene.m:856
    static let musicVolume: Float = 0.5              // MyScene.m:175
    static let cloudCycleDuration: TimeInterval = 60 // MyScene.m:70-71
    static let waypointCount = 10                    // MyScene.m:439
    static let spawnMargin: CGFloat = 30             // MyScene.m:408, :415, :440-441
    static let gabbianoScale: CGFloat = 1.4          // GabbianoSprite.m:44
    static let lifeBarScale: CGFloat = 1.4           // MyScene.m:161 (ramo iPhone 5)
    static let hudFontSize: CGFloat = 30             // MyScene.m:545
    static let hudY: CGFloat = 40                    // MyScene.m:549 (height - 40)
    static let countdownFontSize: CGFloat = 120      // MyScene.m:825
    static let buttonFontSize: CGFloat = 28          // IntroScene.m e ovunque
    static let fontName = "Moon Flower"
    static let fontNameBold = "Moon Flower Bold"
}
```

- [ ] **Step 2: Test di sanità in `GameConfigTests.swift`** (blocca regressioni accidentali sui valori)

```swift
import XCTest
@testable import WooWoo

final class GameConfigTests: XCTestCase {
    func testDurataFormulaFiglia() {
        // MyScene.m:432 — durata = 180 / (mostri + 90): col 1° mostro ≈ 1.978
        let durata = GameConfig.Figlia.velocityBase / (1 + GameConfig.Figlia.velocityBase / 2)
        XCTAssertEqual(durata, 180.0 / 91.0, accuracy: 0.001)
    }
    func testDurataFormulaMamma() {
        // MyScene2.m:532 — durata = 360 / (mostri + 180)
        let durata = GameConfig.Mamma.velocityBase / (1 + GameConfig.Mamma.velocityBase / 2)
        XCTAssertEqual(durata, 360.0 / 181.0, accuracy: 0.001)
    }
    func testCostantiCardine() {
        XCTAssertEqual(GameConfig.maxColpi, 9)
        XCTAssertEqual(GameConfig.Mamma.bonusGates, [17, 34, 51, 68, 81, 98, 115, 132])
        XCTAssertEqual(GameConfig.Figlia.spawnReset, 3.0)
        XCTAssertEqual(GameConfig.Mamma.spawnReset, 4.5)
    }
}
```

- [ ] **Step 3: Builda e testa** (stesso comando del Task 1 Step 10). Expected: `TEST SUCCEEDED`

- [ ] **Step 4: Commit** — `git add WooWoo/ && git commit -m "port: GameConfig con costanti 1:1 dai sorgenti 2014"`

---

### Task 4: Settings + ScoreStore (TDD)

**Files:**
- Create: `WooWoo/Sources/Services/Settings.swift`
- Create: `WooWoo/Sources/Services/ScoreStore.swift`
- Create: `WooWoo/Sources/Config/GameMode.swift`
- Test: `WooWoo/Tests/SettingsTests.swift`, `WooWoo/Tests/ScoreStoreTests.swift`

Sostituiscono `Singleton.m`. **Le chiavi UserDefaults sono quelle originali** — i salvataggi 2014 sopravvivono. I flag erano `NSInteger` 0/1: si conserva il formato Int.

- [ ] **Step 1: Scrivi `GameMode.swift`**

```swift
enum GameMode {
    case figlia, mamma

    var leaderboardID: String {
        switch self {
        case .figlia: "Woo_Woo_Leaderboard"          // PunteggiScene.m:30
        case .mamma: "Woo_Woo_Leaderboard_Mamma"     // PunteggiSceneMamma.m:29, MyScene2.m:199
        }
    }
    /// Suffisso chiavi UserDefaults ("" o "_mamma") — Singleton.m
    var keySuffix: String { self == .mamma ? "_mamma" : "" }
}
```

- [ ] **Step 2: Scrivi i test PRIMA (`SettingsTests.swift`)**

```swift
import XCTest
@testable import WooWoo

final class SettingsTests: XCTestCase {
    var defaults: UserDefaults!
    override func setUp() {
        defaults = UserDefaults(suiteName: #file)!
        defaults.removePersistentDomain(forName: #file)
    }
    func testDefaultsToOffLikeOriginalIntZero() {
        let s = Settings(defaults: defaults)
        XCTAssertFalse(s.isAudioOn)  // chiave "audio" assente → 0 → off
    }
    func testTogglePersistsAsIntOnOriginalKeys() {
        var s = Settings(defaults: defaults)
        s.isAudioOn = true; s.isSoundOn = true; s.isVibroOn = false
        XCTAssertEqual(defaults.integer(forKey: "audio"), 1)
        XCTAssertEqual(defaults.integer(forKey: "sound"), 1)
        XCTAssertEqual(defaults.integer(forKey: "vibro"), 0)
    }
    func testFirstTime() {
        var s = Settings(defaults: defaults)
        XCTAssertTrue(s.isFirstTime)            // "first" == 0 → prima volta
        s.markFirstTimeDone()
        XCTAssertFalse(s.isFirstTime)
        XCTAssertEqual(defaults.integer(forKey: "first"), 1)
    }
}
```

- [ ] **Step 3: Run → verifica che falliscano** (`Settings` non esiste). Expected: BUILD FAILED / compile error.

- [ ] **Step 4: Scrivi `Settings.swift`**

```swift
import Foundation

/// Flag audio/sound/vibro + first-launch. Chiavi e formato (Int 0/1) di Singleton.m:49-117.
struct Settings {
    private let defaults: UserDefaults
    init(defaults: UserDefaults = .standard) { self.defaults = defaults }

    var isAudioOn: Bool {
        get { defaults.integer(forKey: "audio") != 0 }
        nonmutating set { defaults.set(newValue ? 1 : 0, forKey: "audio") }
    }
    var isSoundOn: Bool {
        get { defaults.integer(forKey: "sound") != 0 }
        nonmutating set { defaults.set(newValue ? 1 : 0, forKey: "sound") }
    }
    var isVibroOn: Bool {
        get { defaults.integer(forKey: "vibro") != 0 }
        nonmutating set { defaults.set(newValue ? 1 : 0, forKey: "vibro") }
    }
    var isFirstTime: Bool { defaults.integer(forKey: "first") == 0 }   // Singleton.m:49
    func markFirstTimeDone() { defaults.set(1, forKey: "first") }      // Singleton.m:55
}
```

- [ ] **Step 5: Scrivi i test di `ScoreStoreTests.swift`**

```swift
import XCTest
@testable import WooWoo

final class ScoreStoreTests: XCTestCase {
    var defaults: UserDefaults!
    var store: ScoreStore!
    override func setUp() {
        defaults = UserDefaults(suiteName: #file + "score")!
        defaults.removePersistentDomain(forName: #file + "score")
        store = ScoreStore(defaults: defaults)
    }
    func testBestUsesOriginalKeysPerMode() {
        store.setBest(42, for: .figlia)
        store.setBest(7, for: .mamma)
        XCTAssertEqual(defaults.integer(forKey: "punteggio_massimo"), 42)
        XCTAssertEqual(defaults.integer(forKey: "punteggio_massimo_mamma"), 7)
        XCTAssertEqual(store.best(for: .figlia), 42)
    }
    func testGamesPlayedIncrement() {
        store.addGamePlayed(for: .figlia)
        store.addGamePlayed(for: .figlia)
        XCTAssertEqual(store.gamesPlayed(for: .figlia), 2)
        XCTAssertEqual(defaults.integer(forKey: "numero_partite"), 2)
        XCTAssertEqual(store.gamesPlayed(for: .mamma), 0)
    }
    func testTotalPointsAccumulate() {
        store.addTotalPoints(10, for: .mamma)
        store.addTotalPoints(5, for: .mamma)
        XCTAssertEqual(store.totalPoints(for: .mamma), 15)
        XCTAssertEqual(defaults.integer(forKey: "punti_totali_mamma"), 15)
    }
    func testResetClearsOnlyThatMode() {
        store.setBest(9, for: .figlia); store.addGamePlayed(for: .figlia); store.addTotalPoints(9, for: .figlia)
        store.setBest(5, for: .mamma)
        store.reset(.figlia)   // cancella_punteggi — Singleton.m:190
        XCTAssertEqual(store.best(for: .figlia), 0)
        XCTAssertEqual(store.gamesPlayed(for: .figlia), 0)
        XCTAssertEqual(store.totalPoints(for: .figlia), 0)
        XCTAssertEqual(store.best(for: .mamma), 5)
    }
}
```

- [ ] **Step 6: Run → fail.** Poi scrivi `ScoreStore.swift`:

```swift
import Foundation

/// Punteggi persistenti per modalità. Chiavi originali di Singleton.m:119-223.
struct ScoreStore {
    private let defaults: UserDefaults
    init(defaults: UserDefaults = .standard) { self.defaults = defaults }

    func best(for mode: GameMode) -> Int { defaults.integer(forKey: "punteggio_massimo" + mode.keySuffix) }
    func setBest(_ value: Int, for mode: GameMode) { defaults.set(value, forKey: "punteggio_massimo" + mode.keySuffix) }

    func gamesPlayed(for mode: GameMode) -> Int { defaults.integer(forKey: "numero_partite" + mode.keySuffix) }
    func addGamePlayed(for mode: GameMode) {
        defaults.set(gamesPlayed(for: mode) + 1, forKey: "numero_partite" + mode.keySuffix)
    }

    func totalPoints(for mode: GameMode) -> Int { defaults.integer(forKey: "punti_totali" + mode.keySuffix) }
    func addTotalPoints(_ value: Int, for mode: GameMode) {
        defaults.set(totalPoints(for: mode) + value, forKey: "punti_totali" + mode.keySuffix)
    }

    func reset(_ mode: GameMode) {                       // cancella_punteggi[_mamma]
        defaults.set(0, forKey: "punti_totali" + mode.keySuffix)
        defaults.set(0, forKey: "numero_partite" + mode.keySuffix)
        defaults.set(0, forKey: "punteggio_massimo" + mode.keySuffix)
    }
}
```
Nota: `punteggio_temp[_mamma]` (Singleton.m:319-333) era solo in-memory per passare il punteggio al Game Over → nel port si passa via `GameOverScene(mode:score:)`, niente stato globale.

- [ ] **Step 7: Run test → PASS. Commit** — `git commit -m "port: Settings e ScoreStore su chiavi UserDefaults originali (TDD)"`

---

### Task 5: AudioService + Haptics

**Files:**
- Create: `WooWoo/Sources/Services/AudioService.swift`
- Create: `WooWoo/Sources/Services/Haptics.swift`

- [ ] **Step 1: Scrivi `AudioService.swift`** (sostituisce OALSimpleAudio; i chiamanti NON controllano più i flag — li controlla il servizio, comportamento equivalente)

```swift
import AVFoundation

/// Musica di fondo + effetti. Rispetta Settings.isAudioOn (musica) e isSoundOn (effetti),
/// come i check `[singleton is_audio]/[singleton is_sound]` sparsi nell'originale.
final class AudioService {
    static let shared = AudioService()
    var settings = Settings()
    private var musicPlayer: AVAudioPlayer?
    private var effectPlayers: [String: AVAudioPlayer] = [:]

    private init() {
        try? AVAudioSession.sharedInstance().setCategory(.ambient)
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    func playMusic(_ name: String, volume: Float = 1.0, loop: Bool = true) {
        guard settings.isAudioOn,
              let url = Bundle.main.url(forResource: name, withExtension: nil) else { return }
        musicPlayer = try? AVAudioPlayer(contentsOf: url)
        musicPlayer?.numberOfLoops = loop ? -1 : 0
        musicPlayer?.volume = volume
        musicPlayer?.play()
    }
    func stopMusic() { musicPlayer?.stop(); musicPlayer = nil }

    func playEffect(_ name: String) {
        guard settings.isSoundOn else { return }
        if effectPlayers[name] == nil,
           let url = Bundle.main.url(forResource: name, withExtension: nil) {
            effectPlayers[name] = try? AVAudioPlayer(contentsOf: url)
            effectPlayers[name]?.prepareToPlay()
        }
        effectPlayers[name]?.currentTime = 0
        effectPlayers[name]?.play()
    }
    func stopAllEffects() { effectPlayers.values.forEach { $0.stop() } }
}
```

- [ ] **Step 2: Scrivi `Haptics.swift`**

```swift
import UIKit

enum Haptics {
    /// Sostituisce AudioServicesPlayAlertSound(kSystemSoundID_Vibrate) al game over
    /// (MyScene.m:768). Rispetta il flag vibro.
    static func gameOverVibration(settings: Settings = Settings()) {
        guard settings.isVibroOn else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
}
```

- [ ] **Step 3: Builda. Commit** — `git commit -m "port: AudioService (AVFoundation) e Haptics al posto di ObjectAL/AudioServices"`

---

### Task 6: GameCenterService

**Files:**
- Create: `WooWoo/Sources/Services/GameCenterService.swift`

- [ ] **Step 1: Scrivi `GameCenterService.swift`** (API GameKit moderne al posto di GKScore deprecato)

```swift
import GameKit
import UIKit

/// Game Center: auth (IntroScene.m:385-414), invio punteggi (GameOverScene.m:231-240,
/// PunteggiScene.m:200-213), achievements (GameOverScene.m:242-319), pannello GC.
/// Degrada con grazia: se non autenticato, ogni chiamata è un no-op (come l'originale).
final class GameCenterService: NSObject {
    static let shared = GameCenterService()
    var isAuthenticated: Bool { GKLocalPlayer.local.isAuthenticated }

    func authenticate() {
        GKLocalPlayer.local.authenticateHandler = { viewController, error in
            if let viewController { Self.rootViewController?.present(viewController, animated: false) }
            if let error { print("GameCenter auth: \(error.localizedDescription)") }
        }
    }

    func submit(score: Int, mode: GameMode) {
        guard isAuthenticated else { return }
        GKLeaderboard.submitScore(score, context: 0, player: GKLocalPlayer.local,
                                  leaderboardIDs: [mode.leaderboardID]) { error in
            if let error { print("GameCenter submit: \(error.localizedDescription)") }
        }
    }

    func report(achievementIDs: [String]) {
        guard isAuthenticated, !achievementIDs.isEmpty else { return }
        let achievements = achievementIDs.map {
            let a = GKAchievement(identifier: $0); a.percentComplete = 100; return a
        }
        GKAchievement.report(achievements) { error in
            if let error { print("GameCenter achievements: \(error.localizedDescription)") }
        }
    }

    func showPanel(state: GKGameCenterViewControllerState, mode: GameMode) {
        guard isAuthenticated else { return }
        let vc = state == .leaderboards
            ? GKGameCenterViewController(leaderboardID: mode.leaderboardID, playerScope: .global, timeScope: .allTime)
            : GKGameCenterViewController(state: state)
        vc.gameCenterDelegate = self
        Self.rootViewController?.present(vc, animated: true)
    }

    static var rootViewController: UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first?.rootViewController
    }
}

extension GameCenterService: GKGameCenterControllerDelegate {
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true)   // GameOverScene.m:366-369
    }
}
```

- [ ] **Step 2: Builda. Commit** — `git commit -m "port: GameCenterService con API GameKit moderne"`

---

### Task 7: Fondamenta UI — PhysicsCategory, SKButtonNode, transizioni, helper, TrailNode

**Files:**
- Create: `WooWoo/Sources/Config/PhysicsCategory.swift`
- Create: `WooWoo/Sources/Nodes/SKButtonNode.swift`
- Create: `WooWoo/Sources/Scenes/SceneRouting.swift`
- Create: `WooWoo/Sources/Nodes/TrailNode.swift`
- Test: `WooWoo/Tests/TrailNodeTests.swift` (smoke)

- [ ] **Step 1: `PhysicsCategory.swift`** (mappa i collisionType stringa)

```swift
/// I collisionType stringa di Cocos2D come bit mask.
/// Tutti i body sono sensori puri: collisionBitMask = 0 (ogni preSolve originale ritornava NO).
enum PhysicsCategory {
    static let player: UInt32       = 1 << 0  // "playerCollision"
    static let mamma: UInt32        = 1 << 1  // "mammaCollision"
    static let gabbiano: UInt32     = 1 << 2  // "gabbianoCollision"
    static let colpi: UInt32        = 1 << 3  // "colpiCollision" (player durante lo swing)
    static let fuoco: UInt32        = 1 << 4  // "fuocoCollision" (gabbiano colpito una volta)
    static let colpita: UInt32      = 1 << 5  // "colpitaCollision" (player durante anim. colpita)
    static let esente: UInt32       = 1 << 6  // "esenteCollision" (player immune dopo colpo a segno)
    static let mammaColpita: UInt32 = 1 << 7  // "mammaColpitaCollision"
    static let morto: UInt32        = 1 << 8  // "gabbianoMortoCollision"
    static let all: UInt32          = .max
}
```

- [ ] **Step 2: `SKButtonNode.swift`** — equivalente di CCButton (completo)

```swift
import SpriteKit

/// Equivalente di CCButton: sprite + label opzionale, tap → azione.
/// Supporta toggle a due texture (ON/OFF) come i bottoni audio/sound/vibro.
final class SKButtonNode: SKNode {
    private let sprite: SKSpriteNode
    private var normalTexture: SKTexture
    private var selectedTexture: SKTexture?
    private(set) var isSelected = false
    var togglesSelectedState = false
    var action: (() -> Void)?
    var isEnabled = true { didSet { alpha = isEnabled ? 1.0 : 0.5 } }

    init(imageNamed name: String, selectedImageNamed: String? = nil, title: String = "") {
        normalTexture = SKTexture(imageNamed: name)
        selectedTexture = selectedImageNamed.map(SKTexture.init(imageNamed:))
        sprite = SKSpriteNode(texture: normalTexture)
        super.init()
        addChild(sprite)
        if !title.isEmpty {
            let label = SKLabelNode(fontNamed: GameConfig.fontNameBold)
            label.text = title
            label.fontSize = GameConfig.buttonFontSize
            label.fontColor = .black
            label.verticalAlignmentMode = .center
            addChild(label)
        }
        isUserInteractionEnabled = true
    }
    required init?(coder: NSCoder) { fatalError() }

    func setSelected(_ selected: Bool) {
        isSelected = selected
        sprite.texture = (selected ? selectedTexture : nil) ?? normalTexture
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isEnabled, let touch = touches.first,
              sprite.contains(touch.location(in: self)) else { return }
        if togglesSelectedState { setSelected(!isSelected) }
        action?()
    }
}
```

- [ ] **Step 3: `SceneRouting.swift`** — transizioni e helper posizioni

```swift
import SpriteKit

/// Le tre transizioni usate dall'originale.
enum SceneTransition {
    case pushLeft(TimeInterval)   // CCTransitionDirectionLeft
    case pushRight(TimeInterval)  // CCTransitionDirectionRight
    case quick                    // CCTransitionDirectionInvalid, 0.1s → fade rapido

    var skTransition: SKTransition {
        switch self {
        case .pushLeft(let d): SKTransition.push(with: .left, duration: d)
        case .pushRight(let d): SKTransition.push(with: .right, duration: d)
        case .quick: SKTransition.fade(withDuration: 0.1)
        }
    }
}

extension SKScene {
    /// Sostituisce [[CCDirector sharedDirector] replaceScene:withTransition:]
    func go(to scene: SKScene, _ transition: SceneTransition) {
        scene.scaleMode = .aspectFill
        view?.presentScene(scene, transition: transition.skTransition)
    }
    /// positionType CCPositionTypeNormalized
    func norm(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * size.width, y: y * size.height) }
    /// Clamp X dentro la safe area laterale (notch in landscape) per i bottoni ai bordi.
    func safeX(_ x: CGFloat) -> CGFloat {
        guard let view else { return x }
        let insetL = view.safeAreaInsets.left * (size.height / view.bounds.height)
        let insetR = view.safeAreaInsets.right * (size.height / view.bounds.height)
        return min(max(x, insetL + 16), size.width - insetR - 16)
    }
}
```

- [ ] **Step 4: `TrailNode.swift`** — sostituto di CCMotionStreak (MyScene2.m:197)

```swift
import SpriteKit

/// Scia del dito in modalità mamma. Segmenti che sfumano in `fade` secondi.
/// Parametri originali: streakWithFade:0.3 minSeg:20 width:6 (MyScene2.m:197).
final class TrailNode: SKNode {
    private var lastPoint: CGPoint?

    override var position: CGPoint {
        didSet { appendSegment(to: position) }
    }

    private func appendSegment(to point: CGPoint) {
        defer { lastPoint = point }
        guard let last = lastPoint, hypot(point.x - last.x, point.y - last.y) >= GameConfig.Mamma.streakMinSegment else { return }
        let path = CGMutablePath()
        path.move(to: convert(last, from: parent ?? self))
        path.addLine(to: convert(point, from: parent ?? self))
        let segment = SKShapeNode(path: path)
        segment.strokeColor = .white
        segment.lineWidth = GameConfig.Mamma.streakWidth
        segment.lineCap = .round
        addChild(segment)
        segment.run(.sequence([.fadeOut(withDuration: GameConfig.Mamma.streakFade), .removeFromParent()]))
    }

    func reset() {
        lastPoint = nil
        removeAllChildren()
    }
}
```

- [ ] **Step 5: Smoke test `TrailNodeTests.swift`**

```swift
import XCTest
import SpriteKit
@testable import WooWoo

final class TrailNodeTests: XCTestCase {
    func testSegmentsAppearAndResetClears() {
        let trail = TrailNode()
        trail.position = CGPoint(x: 0, y: 0)
        trail.position = CGPoint(x: 100, y: 0)   // > minSeg 20 → segmento
        XCTAssertEqual(trail.children.count, 1)
        trail.position = CGPoint(x: 105, y: 0)   // < minSeg → niente
        XCTAssertEqual(trail.children.count, 1)
        trail.reset()
        XCTAssertEqual(trail.children.count, 0)
    }
}
```

- [ ] **Step 6: Builda + test → PASS. Commit** — `git commit -m "port: fondamenta UI (PhysicsCategory, SKButtonNode, transizioni, TrailNode)"`

---

### Task 8: I quattro nodi sprite

**Files:**
- Create: `WooWoo/Sources/Nodes/GabbianoNode.swift`
- Create: `WooWoo/Sources/Nodes/PlayerNode.swift`
- Create: `WooWoo/Sources/Nodes/MammaNode.swift`
- Create: `WooWoo/Sources/Nodes/LifeBarNode.swift`
- Create: `WooWoo/Sources/Nodes/SKAction+Frames.swift`

- [ ] **Step 1: Helper animazioni `SKAction+Frames.swift`**

```swift
import SpriteKit

extension SKAction {
    /// CCAnimation da frame numerati: prefix01.png … prefixNN.png
    static func frames(_ prefix: String, count: Int, timePerFrame: TimeInterval, suffix: String = "") -> SKAction {
        let textures = (1...count).map { SKTexture(imageNamed: String(format: "%@%02d%@", prefix, $0, suffix)) }
        return .animate(with: textures, timePerFrame: timePerFrame)
    }
}
```

- [ ] **Step 2: `GabbianoNode.swift`** — port integrale di GabbianoSprite.m

```swift
import SpriteKit

final class GabbianoNode: SKSpriteNode {
    var isAmico = false   // setAmico/returnAmico (GabbianoSprite.m:131-137)
    var isBonus = false   // setBonus/returnBonus (:139-145)

    static func make() -> GabbianoNode {
        let node = GabbianoNode(imageNamed: "gabbiano-zampeVola01")   // factory :18
        return node
    }

    /// :30-52 — 8 frame, delay 0.05, forever, scale 1.4
    func vola() {
        xScale = abs(xScale); yScale = abs(yScale)
        setScale(GameConfig.gabbianoScale)
        run(.repeatForever(.frames("gabbiano-zampeVola", count: 8, timePerFrame: 0.05)), withKey: "vola")
    }

    /// :54-78 — come vola ma capovolto in verticale (l'amico vola a testa in giù!)
    func volaAmico() {
        setScale(GameConfig.gabbianoScale)
        yScale = -abs(yScale)
        run(.repeatForever(.frames("gabbiano-zampeVola", count: 8, timePerFrame: 0.05)), withKey: "vola")
    }

    /// :80-109 — gabbiano "in fuoco" dopo il primo colpo; cambia categoria
    func fuoco() {
        removeAction(forKey: "vola")
        physicsBody?.categoryBitMask = PhysicsCategory.fuoco
        run(.repeatForever(.frames("gabbiano-zampeVola", count: 8, timePerFrame: 0.05, suffix: "Muore")), withKey: "fuoco")
    }

    /// :111-129 — frame singolo gabbiano-zampeMuore 0.15s poi rimozione
    func muore() {
        physicsBody?.categoryBitMask = PhysicsCategory.morto
        let anim = SKAction.animate(with: [SKTexture(imageNamed: "gabbiano-zampeMuore")], timePerFrame: 0.15)
        run(.sequence([anim, .removeFromParent()]))
    }
}
```

- [ ] **Step 3: `PlayerNode.swift`** — port integrale di PlayerSprite.m (la meccanica chiave: durante lo swing il CORPO del player diventa l'arma cambiando categoria in `colpi`, a fine animazione torna `player`)

```swift
import SpriteKit

final class PlayerNode: SKSpriteNode {
    private var isSinistra = true
    private var primo = false

    static func make() -> PlayerNode { PlayerNode(imageNamed: "figlia_cammina01") }   // :19

    /// I 7 punti del poligono fisico (MyScene.m:98-110), relativi al centro dello sprite.
    /// extraOffsetX: 0 per sinistra (:48), +30 per destra (:102).
    func polygonBody(extraOffsetX: CGFloat = 0) -> SKPhysicsBody {
        let offX = size.width * anchorPoint.x - size.width / 2 + extraOffsetX
        let offY = size.height * anchorPoint.y - size.height / 2 - 5
        let raw: [(CGFloat, CGFloat)] = [(95, 119), (120, 117), (143, 52), (144, 0), (51, 0), (47, 49), (75, 115)]
        let path = CGMutablePath()
        let pts = raw.map { CGPoint(x: $0.0 - offX - size.width / 2, y: $0.1 - offY - size.height / 2) }
        path.addLines(between: pts)
        path.closeSubpath()
        let body = SKPhysicsBody(polygonFrom: path)
        body.isDynamic = true
        body.affectedByGravity = false
        body.allowsRotation = false
        body.collisionBitMask = 0
        body.contactTestBitMask = PhysicsCategory.gabbiano | PhysicsCategory.fuoco
        return body
    }

    /// :138-170 — camminata, 5 frame 0.05 forever
    func cammina() {
        if !primo { primo = true; isSinistra = true }
        run(.repeatForever(.frames("figlia_cammina", count: 5, timePerFrame: 0.05)), withKey: "cammina")
    }

    /// :28-80 — swing a sinistra: 7 frame, corpo→colpi durante, →player a fine
    func zaccaASinistra() {
        removeAllActions(); cammina()
        xScale = abs(xScale)                       // setFlipX:false
        if !isSinistra {
            position.x -= 30                       // :46
            physicsBody = polygonBody()            // :48-63
        }
        physicsBody?.categoryBitMask = PhysicsCategory.colpi
        let swing = SKAction.frames("figlia_colpisce", count: 7, timePerFrame: 0.05)
        run(.sequence([swing, .run { [weak self] in
            self?.physicsBody?.categoryBitMask = PhysicsCategory.player
        }]), withKey: "zacca")
        isSinistra = true
    }

    /// :82-136 — speculare, flipX e offset +30
    func zaccaADestra() {
        removeAllActions(); cammina()
        xScale = -abs(xScale)                      // setFlipX:true
        if isSinistra {
            position.x += 30                       // :100
            physicsBody = polygonBody(extraOffsetX: 30)   // :102-117
        }
        physicsBody?.categoryBitMask = PhysicsCategory.colpi
        let swing = SKAction.frames("figlia_colpisce", count: 7, timePerFrame: 0.05)
        run(.sequence([swing, .run { [weak self] in
            self?.physicsBody?.categoryBitMask = PhysicsCategory.player
        }]), withKey: "zacca")
        isSinistra = false
    }

    /// :172-204 — colpita: categoria colpita durante l'animazione (la rende immune
    /// a colpi multipli per-frame), torna player a fine
    func colpita() {
        physicsBody?.categoryBitMask = PhysicsCategory.colpita
        let anim = SKAction.frames("figlia_colpita", count: 5, timePerFrame: 0.05)
        run(.sequence([anim, .run { [weak self] in
            self?.physicsBody?.categoryBitMask = PhysicsCategory.player
        }]), withKey: "colpita")
    }

    /// :206-238 — morte, 9 frame 0.10
    func muore() {
        removeAction(forKey: "cammina")
        isSinistra = true
        run(.frames("figlia_muore", count: 9, timePerFrame: 0.10), withKey: "muore")
    }
}
```

- [ ] **Step 4: `MammaNode.swift`** — port di MammaSprite.m

```swift
import SpriteKit

final class MammaNode: SKSpriteNode {
    static func make() -> MammaNode { MammaNode(imageNamed: "mamma_statica01") }   // :18

    /// I 6 punti del poligono (MyScene.m:141-152), offset −20/−5 come l'originale (:121-122).
    func polygonBody() -> SKPhysicsBody {
        let offX = size.width * anchorPoint.x - size.width / 2 - 20
        let offY = size.height * anchorPoint.y - size.height / 2 - 5
        let raw: [(CGFloat, CGFloat)] = [(21, 127), (82, 37), (85, 4), (2, 2), (0, 113), (9, 127)]
        let path = CGMutablePath()
        path.addLines(between: raw.map { CGPoint(x: $0.0 - offX - size.width / 2, y: $0.1 - offY - size.height / 2) })
        path.closeSubpath()
        let body = SKPhysicsBody(polygonFrom: path)
        body.isDynamic = true; body.affectedByGravity = false
        body.allowsRotation = false; body.collisionBitMask = 0
        body.categoryBitMask = PhysicsCategory.mamma
        body.contactTestBitMask = PhysicsCategory.gabbiano
        return body
    }

    /// :24-48 — respiro, 3 frame delay 1.0 forever
    func vive() {
        run(.repeatForever(.frames("mamma_statica", count: 3, timePerFrame: 1.0)), withKey: "vive")
    }

    /// :50-86 — sofferenza: categoria mammaColpita durante (2 frame x 1.0s), poi torna mamma
    func soffre() {
        physicsBody?.categoryBitMask = PhysicsCategory.mammaColpita
        let anim = SKAction.frames("mamma_soffre", count: 2, timePerFrame: 1.0)
        run(.sequence([anim, .run { [weak self] in
            self?.physicsBody?.categoryBitMask = PhysicsCategory.mamma
        }]), withKey: "soffre")
    }
}
```

- [ ] **Step 5: `LifeBarNode.swift`** — port di LifeBarSprite.m (vita N → lifebar-(N+1))

```swift
import SpriteKit

final class LifeBarNode: SKSpriteNode {
    static func make() -> LifeBarNode { LifeBarNode(imageNamed: "lifebar-01") }

    /// LifeBarSprite.m:18-81 — colpi 0...9 → texture lifebar-01...lifebar-10
    func setVita(_ colpi: Int) {
        guard (0...9).contains(colpi) else { return }
        texture = SKTexture(imageNamed: String(format: "lifebar-%02d", colpi + 1))
    }
}
```

- [ ] **Step 6: Builda. Commit** — `git commit -m "port: nodi sprite (Player, Gabbiano, Mamma, LifeBar) 1:1 dagli originali"`

---

### Task 9: IntroScene

**Files:**
- Rewrite: `WooWoo/Sources/Scenes/IntroScene.swift` (sostituisce lo stub)

Layout esatto da IntroScene.m (report posizioni: titolo (0.70, 0.85) scala 0.5; Start Mamma (0.30, 0.60); Start (0.70, 0.60); Punteggi (0.70, 0.45); Punteggi Mamma (0.30, 0.45); Woowoo Selfie (0.70, 0.30); store (0.52, 0.15); audio (0.61, 0.15); sound (0.70, 0.15); vibro (0.79, 0.15); crediti (0.88, 0.15)).

- [ ] **Step 1: Scrivi la scena completa**

```swift
import SpriteKit
import GameKit

final class IntroScene: SKScene {
    private let settings = Settings()
    private var audioButton: SKButtonNode!
    private var soundButton: SKButtonNode!
    private var vibroButton: SKButtonNode!

    override func didMove(to view: SKView) {
        buildLayout()
        applySettingsState()       // IntroScene.m:203-236
        GameCenterService.shared.authenticate()   // :237, :385-414
    }

    private func buildLayout() {
        let bg = SKSpriteNode(imageNamed: "splashscreeniPhone5")
        bg.position = CGPoint(x: size.width / 2, y: size.height / 2)
        bg.setScale(size.width / bg.size.width)   // copre la larghezza estesa
        addChild(bg)

        let title = SKSpriteNode(imageNamed: "woowoothegame_titolo")
        title.position = norm(0.70, 0.85); title.setScale(0.5)
        addChild(title)

        let isIT = Locale.current.language.languageCode?.identifier == "it"

        addButton("Start Mamma", at: norm(0.30, 0.60)) { [weak self] in
            guard let self else { return }
            self.go(to: GameSceneMamma(size: self.size), .pushLeft(0.7))      // :346
        }
        addButton("Start", at: norm(0.70, 0.60)) { [weak self] in
            guard let self else { return }
            self.go(to: TutorialScene(size: self.size), .pushLeft(0.7))       // :340
        }
        addButton(isIT ? "Punteggi" : "Score records", at: norm(0.70, 0.45)) { [weak self] in
            guard let self else { return }
            self.go(to: PunteggiScene(size: self.size, mode: .figlia), .quick)
        }
        addButton(isIT ? "Punteggi Mamma" : "Score records Mother", at: norm(0.30, 0.45)) { [weak self] in
            guard let self else { return }
            self.go(to: PunteggiScene(size: self.size, mode: .mamma), .quick)
        }
        addButton("Woowoo Selfie", at: norm(0.70, 0.30)) { [weak self] in
            guard let self else { return }
            self.go(to: SelfieScene(size: self.size), .quick)
        }

        let store = SKButtonNode(imageNamed: "btn_store")
        store.position = norm(0.52, 0.15)
        store.action = { UIApplication.shared.open(URL(string: "http://bit.ly/woowoostore")!) }  // :257
        addChild(store)

        audioButton = toggle("btn_audioON", "btn_audioOFF", at: norm(0.61, 0.15)) { [weak self] on in
            self?.settings.isAudioOn = on
            if on { AudioService.shared.playEffect("music_on.mp3") }          // :264
        }
        soundButton = toggle("btn_soundON", "btn_soundOFF", at: norm(0.70, 0.15)) { [weak self] on in
            self?.settings.isSoundOn = on
            if on { AudioService.shared.playEffect("woowoo.mp3") }            // :277
        }
        vibroButton = toggle("btn_vibroON", "btn_vibroOFF", at: norm(0.79, 0.15)) { [weak self] on in
            self?.settings.isVibroOn = on
            if on { UINotificationFeedbackGenerator().notificationOccurred(.warning) }  // :291
        }

        let info = SKButtonNode(imageNamed: "btn_crediti")
        info.position = norm(0.88, 0.15)
        info.action = { [weak self] in self?.showCredits(isIT: isIT) }
        addChild(info)
    }

    private func addButton(_ title: String, at p: CGPoint, action: @escaping () -> Void) {
        let b = SKButtonNode(imageNamed: "btn_label", title: title)
        b.position = p; b.action = action
        addChild(b)
    }

    /// Convenzione Cocos2D: selected == false mostra lo sprite ON (IntroScene report)
    private func toggle(_ onImage: String, _ offImage: String, at p: CGPoint,
                        changed: @escaping (Bool) -> Void) -> SKButtonNode {
        let b = SKButtonNode(imageNamed: onImage, selectedImageNamed: offImage)
        b.togglesSelectedState = true
        b.position = p
        b.action = { [weak b] in changed(!(b?.isSelected ?? false)) }
        addChild(b)
        return b
    }

    /// IntroScene.m:203-236 — primo avvio: tutto ON; poi: stato letto da UserDefaults
    private func applySettingsState() {
        if settings.isFirstTime {
            settings.isAudioOn = true; settings.isSoundOn = true; settings.isVibroOn = true
            settings.markFirstTimeDone()
        }
        audioButton.setSelected(!settings.isAudioOn)
        soundButton.setSelected(!settings.isSoundOn)
        vibroButton.setSelected(!settings.isVibroOn)
    }

    /// IntroScene.m:300-330 — alert crediti. Testo ESATTO dal sorgente.
    private func showCredits(isIT: Bool) {
        let text = isIT
            ? "Grazie del download!\nSeguici su Facebook:\nfb.com/woowoothegame\n\nCreato e ideato da:\nGiusepe Broccia e Davide Melis\n(sviluppo)\nfb.com/giudasoft\nRiccardo Atzeni (Grafica)\nAndrea Murru (swooluppo iOS)\n\nRingraziamo Sensational Gianni per la musica e l'ispirazione\nfb.com/sensationalgianni"
            : "Thank you for download!\nFollow us on Facebook:\nfb.com/woowoothegame\n\nCreated by:\nGiusepe Broccia and Davide Melis\n(Develop)\nfb.com/giudasoft\nRiccardo Atzeni (Graphics)\nAndrea Murru (Dewoolop iOS)\n\nThanks to Sensational Gianni music and ispiration\nfb.com/sensationalgianni"
        let alert = UIAlertController(title: nil, message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        GameCenterService.rootViewController?.present(alert, animated: true)
    }
}
```

- [ ] **Step 2: Crea stub vuoti per le scene referenziate** (`TutorialScene`, `GameScene`, `GameSceneMamma`, `PunteggiScene(size:mode:)`, `SelfieScene`) in modo che il progetto compili — ognuno è `final class X: SKScene` con `didMove` che mostra solo il nome scena e un bottone back verso IntroScene. PunteggiScene riceve `mode: GameMode` nell'init custom: `init(size: CGSize, mode: GameMode)` + `required init?(coder:)`. (`GameScene` serve già al Task 10: il tutorial ci naviga.)

- [ ] **Step 3: Builda e lancia sul simulatore**

```bash
xcodebuild -project WooWoo.xcodeproj -scheme WooWoo \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build
xcrun simctl boot "iPhone 16 Pro" 2>/dev/null; open -a Simulator
xcrun simctl install "iPhone 16 Pro" ~/Library/Developer/Xcode/DerivedData/WooWoo-*/Build/Products/Debug-iphonesimulator/WooWoo.app
xcrun simctl launch "iPhone 16 Pro" com.woowoothegame
```
Verifica manuale: menu landscape con titolo, 5 bottoni label, 4 icone toggle/store/crediti; i toggle invertono icona e persistono al riavvio; crediti mostra l'alert.

- [ ] **Step 4: Commit** — `git commit -m "port: IntroScene completa (menu, toggle, crediti, GC auth)"`

---

### Task 10: TutorialScene

**Files:**
- Rewrite: `WooWoo/Sources/Scenes/TutorialScene.swift`

Port di TutorialScene.m: contenitore `background` SKNode con le 5 immagini `tutorial0N_iPhone` figlie a x = larghezza×N (righe 34-59), swipe destra→sinistra avanza pagina (120-165), animazione `move(to:)` 0.5 s alle posizioni (w,0), (0,0), (−w,0), (−2w,0) per pagina 1-4 (168-201), pagina 5 → `start_game` → GameScene. Bottone "Start" (0.80, 0.10), chiudi (0.10, 0.90) → IntroScene pushRight 0.1 s. Suono `intro_02.mp3` all'ingresso. UIPageControl → 5 pallini SKShapeNode aggiornati a ogni pagina.

- [ ] **Step 1: Scrivi la scena.** Struttura completa:

```swift
import SpriteKit

final class TutorialScene: SKScene {
    private let background = SKNode()
    private var pagina = 0
    private var monoMovimento = false
    private var dots: [SKShapeNode] = []

    override func didMove(to view: SKView) {
        AudioService.shared.playEffect("intro_02.mp3")          // :28-29
        isUserInteractionEnabled = true

        background.position = CGPoint(x: size.width * 2, y: 0)  // :34 — il moveTo a (w,0) della pagina 1 mostra la prima immagine
        addChild(background)
        for i in 1...5 {
            let img = SKSpriteNode(imageNamed: String(format: "tutorial%02d_iPhone", i))
            img.color = SKColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
            img.colorBlendFactor = 1.0                          // tinta ccc3(200,200,200) — :38
            img.position = CGPoint(x: size.width * CGFloat(i), y: size.height)   // :39-59 (verifica visiva il framing!)
            background.addChild(img)
        }
        // ⚠️ PARITÀ VISIVA: l'originale posiziona le immagini a y = contentSize.height con anchor
        // centrale e il contenitore a x = width*2. Al primo run confronta framing e prima pagina
        // visibile col gioco originale (le tutorial sono 1136x640 → 568x320 pt = schermo pieno):
        // se il quadro o la pagina iniziale sono sbagliati, leggi TutorialScene.m:25-100 e replica
        // anchor/posizioni ESATTE — non interpretare.

        addButton(); addDots()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) { monoMovimento = true }   // :120-124

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {  // :126-165
        guard monoMovimento, let t = touches.first else { return }
        let movimento = t.previousLocation(in: self).x - t.location(in: self).x
        if movimento > 0, pagina < 6 {
            pagina += 1
            gestisciPagina(pagina)
        }
        monoMovimento = false
        updateDots()
    }

    private func gestisciPagina(_ p: Int) {     // :168-201
        let targets: [Int: CGFloat] = [1: size.width, 2: 0, 3: -size.width, 4: -size.width * 2]
        if let x = targets[p] {
            background.run(.move(to: CGPoint(x: x, y: 0), duration: 0.5))
        } else if p >= 5 {
            startGame()
        }
    }

    private func startGame() {                  // :105-117
        AudioService.shared.stopAllEffects()
        go(to: GameScene(size: size), .pushLeft(0.7))
    }

    private func addButton() {
        let start = SKButtonNode(imageNamed: "btn_label", title: "Start")
        start.position = norm(0.80, 0.10)
        start.action = { [weak self] in self?.startGame() }
        addChild(start)
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
            dot.fillColor = .white; dot.strokeColor = .clear
            addChild(dot); dots.append(dot)
        }
        updateDots()
    }
    private func updateDots() {
        for (i, d) in dots.enumerated() { d.alpha = (i == min(max(pagina - 1, 0), 4)) ? 1.0 : 0.4 }
    }
}
```
Nota: rimuovi lo stub di TutorialScene creato nel Task 9.

- [ ] **Step 2: Builda, lancia, verifica:** swipe avanza le 5 pagine, quinta swipe → countdown del gioco (GameScene è ancora stub: basta che si arrivi alla scena), chiudi torna al menu, framing tutorial corretto vs. originale.

- [ ] **Step 3: Commit** — `git commit -m "port: TutorialScene (5 pagine swipe, pallini, navigazione)"`

---

### Task 11: GameScene (modalità figlia) — il cuore del porting

**Files:**
- Create: `WooWoo/Sources/Scenes/GameScene.swift`
- Create: `WooWoo/Sources/Config/ScoreFormatter.swift`
- Test: `WooWoo/Tests/ScoreFormatterTests.swift`

- [ ] **Step 1: TDD su `ScoreFormatter`** — test prima:

```swift
import XCTest
@testable import WooWoo

final class ScoreFormatterTests: XCTestCase {
    func testHitsPadding() {   // MyScene.m:752-759
        XCTAssertEqual(ScoreFormatter.hits(0), "Hits 000")
        XCTAssertEqual(ScoreFormatter.hits(7), "Hits 007")
        XCTAssertEqual(ScoreFormatter.hits(42), "Hits 042")
        XCTAssertEqual(ScoreFormatter.hits(150), "Hits 150")
    }
    func testTime() {          // MyScene.m:566
        XCTAssertEqual(ScoreFormatter.time(0), "Time 0.0")
        XCTAssertEqual(ScoreFormatter.time(12.34), "Time 12.3")
    }
}
```

Implementazione:

```swift
enum ScoreFormatter {
    static func hits(_ score: Int) -> String { String(format: "Hits %03d", score) }   // MyScene.m:752-759
    static func time(_ t: Double) -> String { String(format: "Time %.1f", t) }        // MyScene.m:566
}
```

- [ ] **Step 2: Scrivi `GameScene.swift`.** Codice completo del cuore (init, sfondi, countdown, accelerometro, spawn, collisioni, HUD, pausa, game over):

```swift
import SpriteKit
import CoreMotion

final class GameScene: SKScene, SKPhysicsContactDelegate {
    // Stato (MyScene.h)
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
        physicsWorld.gravity = .zero                       // MyScene.m:55
        physicsWorld.contactDelegate = self
        isUserInteractionEnabled = false                   // abilitato a fine countdown

        buildBackground()                                  // :61-81
        buildPauseButton()                                 // :83-90
        buildPlayer()                                      // :92-115
        buildMamma()                                       // :118-156
        buildLifeBar()                                     // :158-165
        AudioService.shared.playMusic("main_theme_w_intro.mp3", volume: GameConfig.musicVolume)  // :173-177
        setupHud()                                         // :544-562
        countDown()                                        // :819-870
    }

    // MARK: - Setup (port 1:1 di MyScene.m:45-194)

    private func buildBackground() {
        func fullWidth(_ name: String, anchorBottom: Bool = false) -> SKSpriteNode {
            let s = SKSpriteNode(imageNamed: name)
            s.setScale(size.width / s.size.width)
            if anchorBottom { s.anchorPoint = CGPoint(x: 0.5, y: 0); s.position = CGPoint(x: size.width / 2, y: 0) }
            else { s.position = CGPoint(x: size.width / 2, y: size.height / 2) }
            return s
        }
        addChild(fullWidth("bkg_cielo"))
        let nuvole = SKSpriteNode(imageNamed: "bkg_nuvole")
        nuvole.position = CGPoint(x: size.width * 2, y: size.height / 2)       // :66
        addChild(nuvole)
        let left = SKAction.move(to: CGPoint(x: -size.width, y: size.height / 2), duration: GameConfig.cloudCycleDuration)
        let right = SKAction.move(to: CGPoint(x: size.width * 2, y: size.height / 2), duration: GameConfig.cloudCycleDuration)
        nuvole.run(.repeatForever(.sequence([left, right])))                   // :70-73
        addChild(fullWidth("bkg_palazzi"))
        addChild(fullWidth("bkg_terrazzo", anchorBottom: true))
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
        player.physicsBody?.categoryBitMask = PhysicsCategory.player
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
        lifeBar.setScale(GameConfig.lifeBarScale)
        addChild(lifeBar)
    }

    private func setupHud() {
        scoreLabel = SKLabelNode(fontNamed: GameConfig.fontNameBold)
        scoreLabel.text = "Hits 000"; scoreLabel.fontSize = GameConfig.hudFontSize
        scoreLabel.fontColor = .red
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: size.width - 20, y: size.height - GameConfig.hudY - 10)  // :549
        addChild(scoreLabel)
        timeLabel = SKLabelNode(fontNamed: GameConfig.fontNameBold)
        timeLabel.text = "Time 0"; timeLabel.fontSize = GameConfig.hudFontSize
        timeLabel.fontColor = .red
        timeLabel.horizontalAlignmentMode = .left
        timeLabel.position = CGPoint(x: 25, y: size.height - GameConfig.hudY - 10)                // :558
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
            if countTime == 0 {
                self.isUserInteractionEnabled = true
                label.removeFromParent(); box.removeFromParent()
                self.removeAction(forKey: "countdown")
                self.startGameTimer()                       // :856-859
                self.startMonitoringAcceleration()          // :861-863
                self.player.cammina()                       // :865
            }
        }])), withKey: "countdown")
    }

    private func startGameTimer() {
        time = 0
        let t = Timer(timeInterval: GameConfig.gameTimerInterval, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.time += 0.1                                // :565
            self.timeLabel.text = ScoreFormatter.time(self.time)
        }
        RunLoop.current.add(t, forMode: .common)            // :857 NSRunLoopCommonModes
        gameTimer = t
    }

    // MARK: - Accelerometro (:269-326)

    private func startMonitoringAcceleration() {
        guard motionManager.isAccelerometerAvailable else { return }
        motionManager.startAccelerometerUpdates()
        accelerometerActive = true
    }
    private func stopMonitoringAcceleration() {
        motionManager.stopAccelerometerUpdates()
        accelerometerActive = false
    }

    private func updatePlayerVelocityFromMotion() {         // :285-326
        guard accelerometerActive, let data = motionManager.accelerometerData else { return }
        let dec = GameConfig.Figlia.accelDeceleration
        let sens = GameConfig.Figlia.accelSensitivity
        let maxV = GameConfig.Figlia.accelMaxVelocity
        switch UIDevice.current.orientation {
        case .landscapeLeft:
            playerVelocity.x = playerVelocity.x * dec + data.acceleration.y * sens
            comeEraGirato = true
        case .landscapeRight:
            playerVelocity.x = playerVelocity.x * dec - data.acceleration.y * sens
            comeEraGirato = false
        default:
            playerVelocity.x = comeEraGirato
                ? playerVelocity.x * dec + data.acceleration.y * sens
                : playerVelocity.x * dec - data.acceleration.y * sens
        }
        playerVelocity.x = min(max(playerVelocity.x, -maxV), maxV)
        playerVelocity.y = min(max(playerVelocity.y, -maxV), maxV)
    }

    // MARK: - Update loop (:341-386, :328-337)

    override func update(_ currentTime: TimeInterval) {
        let delta = lastUpdateTime == 0 ? 0 : currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        var pos = player.position
        pos.x += playerVelocity.x
        pos.y += playerVelocity.y
        let halfW = player.texture!.size().width / 5.0      // :350 (width/5, peculiarità originale)
        let halfH = player.texture!.size().height * 0.5     // :352
        pos.x = min(max(pos.x, halfW), size.width - halfW)
        if pos.x == halfW || pos.x == size.width - halfW { playerVelocity.x = 0 }
        pos.y = min(max(pos.y, halfH), size.height - halfH)
        if pos.y == halfH || pos.y == size.height - halfH { playerVelocity.y = 0 }
        player.position = pos

        updatePlayerVelocityFromMotion()

        lastSpawnTimeInterval += delta                      // :330
        if lastSpawnTimeInterval > GameConfig.Figlia.spawnThreshold {
            lastSpawnTimeInterval = GameConfig.Figlia.spawnReset
            addMonster()
        }
    }

    // MARK: - Spawn (:388-542)

    private func addMonster() {
        AudioService.shared.playEffect("woowoo.mp3")        // :392
        mostri += 1
        let monster = GabbianoNode.make()
        monster.physicsBody = SKPhysicsBody(rectangleOf: monster.size)        // :399
        monster.physicsBody?.isDynamic = true
        monster.physicsBody?.affectedByGravity = false
        monster.physicsBody?.allowsRotation = false         // :436
        monster.physicsBody?.collisionBitMask = 0
        monster.physicsBody?.categoryBitMask = PhysicsCategory.gabbiano
        monster.physicsBody?.contactTestBitMask = PhysicsCategory.player | PhysicsCategory.mamma | PhysicsCategory.colpi
        monster.vola()                                      // :402

        var movimenti: [SKAction] = []
        let isDestra = Bool.random()                        // :405
        if isDestra {
            monster.position = CGPoint(x: size.width + GameConfig.spawnMargin, y: size.height)   // :408
            movimenti.append(.run { [weak monster] in monster?.xScale = -abs(monster!.xScale) }) // FlipX true :410
        } else {
            monster.position = CGPoint(x: -GameConfig.spawnMargin, y: size.height)               // :415
        }
        addChild(monster)

        // :430-432 — durata = 180 / (mostri + 90)
        let base = GameConfig.Figlia.velocityBase
        let durata = base / (CGFloat(mostri) + base / 2.0)

        // :439-534 — 10 waypoint casuali con flip in base alla direzione
        var precX = monster.position.x, precY = monster.position.y
        var precDeltaX: CGFloat = 0
        let maxX = size.width + GameConfig.spawnMargin
        for _ in 0..<GameConfig.waypointCount {
            let actualX = CGFloat.random(in: -GameConfig.spawnMargin...maxX)
            let actualY = CGFloat.random(in: monster.size.height...(size.height - 10))
            let deltaX = precX - actualX, deltaY = precY - actualY
            let distance = hypot(deltaX, deltaY)
            let dur = (distance / maxX) * durata
            appendFlip(&movimenti, deltaX: deltaX, precDeltaX: precDeltaX, node: monster)
            movimenti.append(.move(to: CGPoint(x: actualX, y: actualY), duration: dur))
            precX = actualX; precY = actualY; precDeltaX = deltaX
        }
        // :496-529 — ritorno al punto di partenza, poi flip finale se partiva da sinistra
        let deltaX = precX - monster.position.x
        let distance = hypot(deltaX, precY - monster.position.y)
        appendFlip(&movimenti, deltaX: deltaX, precDeltaX: precDeltaX, node: monster)
        movimenti.append(.move(to: monster.position, duration: (distance / (size.width - 10)) * durata))
        if !isDestra { movimenti.append(.run { [weak monster] in monster?.xScale = -abs(monster!.xScale) }) }   // :531-534
        monster.run(.repeatForever(.sequence(movimenti)), withKey: "path")    // :538
    }

    /// :461-482 — CCActionFlipX in base al segno dei delta.
    /// I 4 rami originali collassano: flip = (deltaX > 0); il ramo "else" (uno dei due delta a 0)
    /// non aggiungeva nessun flip → guard su ENTRAMBI non-zero.
    private func appendFlip(_ actions: inout [SKAction], deltaX: CGFloat, precDeltaX: CGFloat, node: SKSpriteNode) {
        guard precDeltaX != 0, deltaX != 0 else { return }
        let flip: Bool = deltaX > 0   // delta > 0 → va a sinistra → flip true (come :466-478)
        actions.append(.run { [weak node] in
            guard let node else { return }
            node.xScale = flip ? -abs(node.xScale) : abs(node.xScale)
        })
    }

    // MARK: - Touch (:232-253)

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let t = touches.first else { return }
        if t.location(in: self).x > size.width / 2 {
            player.zaccaADestra()
            AudioService.shared.playEffect("swing_00.mp3")
        } else {
            player.zaccaASinistra()
            AudioService.shared.playEffect("swing_01.mp3")
        }
    }

    // MARK: - Collisioni (:570-750) — solo le 5 coppie gestite, il resto era no-op

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
                f.removeAllActions()
                f.muore()
                punteggio += 1
                scoreLabel.text = ScoreFormatter.hits(punteggio)
                AudioService.shared.playEffect("con_la_scopa.mp3")
            }
        default: break
        }
    }

    private func valutaColpo(_ gabbiano: GabbianoNode) {            // :740-750
        // NB: l'originale chiamava stopActionByTag:777, ma nessuna azione aveva tag 777 → no-op.
        // Il gabbiano CONTINUA a volare il suo percorso mentre brucia. Non rimuovere "path".
        gabbiano.fuoco()
        AudioService.shared.playEffect("bird_00.mp3")
        player.physicsBody?.categoryBitMask = PhysicsCategory.esente   // :747 — immune finché lo swing non finisce
    }

    // MARK: - Vita e game over (:761-817)

    private func controllaVita() {
        if colpiMostro < GameConfig.maxColpi {
            lifeBar.setVita(colpiMostro)
        } else if colpiMostro == GameConfig.maxColpi {
            Haptics.gameOverVibration()                             // :767-768
            isUserInteractionEnabled = false
            stopMonitoringAcceleration()
            player.removeAllActions()
            player.muore()
            run(.sequence([.wait(forDuration: GameConfig.gameOverDelay), .run { [weak self] in self?.gameOver() }]))
        }
    }

    private func gameOver() {                                       // :779-817
        removeAllActions()
        gameTimer?.invalidate()
        AudioService.shared.stopMusic()
        AudioService.shared.playEffect("mai_capitato.mp3")
        go(to: GameOverScene(size: size, mode: .figlia, score: punteggio), .quick)
    }

    // MARK: - Pausa (:874-941)

    private func checkPause() {
        isPaused = true                                             // [[CCDirector] pause]
        stopMonitoringAcceleration()
        player.removeAllActions()
        isUserInteractionEnabled = false
        pauseStart = Date()                                         // :880
        previousFireDate = gameTimer?.fireDate                      // :882
        gameTimer?.fireDate = .distantFuture                        // :884

        let riprendi = SKButtonNode(imageNamed: "btn_label", title: "Resume")
        riprendi.position = CGPoint(x: GameConfig.Figlia.pauseResumePos.x * size.width,
                                    y: GameConfig.Figlia.pauseResumePos.y * size.height)
        riprendi.name = "riprendi"
        riprendi.action = { [weak self] in self?.riprendiDaPause() }
        addChild(riprendi)

        let esci = SKButtonNode(imageNamed: "btn_label", title: "Exit")
        esci.position = CGPoint(x: GameConfig.Figlia.pauseExitPos.x * size.width,
                                y: GameConfig.Figlia.pauseExitPos.y * size.height)
        esci.name = "esci"
        esci.action = { [weak self] in self?.esci() }
        addChild(esci)
    }

    private func riprendiDaPause() {                                // :926-941
        isPaused = false
        startMonitoringAcceleration()
        player.cammina()
        isUserInteractionEnabled = true
        if let pauseStart, let previousFireDate {
            let pauseTime = -pauseStart.timeIntervalSinceNow
            gameTimer?.fireDate = previousFireDate.addingTimeInterval(pauseTime)   // :933-935
        }
        childNode(withName: "riprendi")?.removeFromParent()
        childNode(withName: "esci")?.removeFromParent()
    }

    private func esci() {                                           // :911-924
        removeAllActions()
        gameTimer?.invalidate()
        AudioService.shared.stopMusic()
        go(to: IntroScene(size: size), .quick)
    }

    override func willMove(from view: SKView) {
        gameTimer?.invalidate()
        stopMonitoringAcceleration()
    }
}
```
Nota su `isPaused = true`: SpriteKit ferma azioni, fisica e update della scena, ma i tocchi continuano ad arrivare → i bottoni Resume/Exit funzionano. Identico al pause del CCDirector.

- [ ] **Step 3: Crea uno stub `GameOverScene(size:mode:score:)`** che mostri solo il punteggio e un bottone verso IntroScene (sostituito nel Task 13).

- [ ] **Step 4: Builda + test** (`xcodebuild … test`). Expected: TEST SUCCEEDED (ScoreFormatter).

- [ ] **Step 5: Verifica sul simulatore** — Start → tutorial → gioco: countdown 3-2-1, musica, gabbiani che entrano dopo ~5 s con percorsi erratici, tap destro/sinistro fa "zaccare" la figlia, colpire un gabbiano lo incendia, ricolpirlo lo uccide e Hits sale, collisione col gabbiano riempie la life bar, 9 colpi → morte + game over. NB: l'accelerometro sul simulatore non muove il player (Device > Motion non c'è): la verifica completa del movimento è al Task 17 su device. Pausa: Resume riprende esattamente, Exit torna al menu.

- [ ] **Step 6: Commit** — `git commit -m "port: GameScene modalità figlia completa (spawn, fisica, accelerometro, pausa)"`

---

### Task 12: GameSceneMamma

**Files:**
- Create: `WooWoo/Sources/Scenes/GameSceneMamma.swift`
- Create: `WooWoo/Sources/Config/SpawnDecision.swift`
- Test: `WooWoo/Tests/SpawnDecisionTests.swift`

- [ ] **Step 1: TDD sul pattern di spawn** (MyScene2.m:458-474) — test prima:

```swift
import XCTest
@testable import WooWoo

final class SpawnDecisionTests: XCTestCase {
    func testPattern() {
        XCTAssertEqual(SpawnDecision.mamma(mostri: 0), .amico)     // :464 primo è amico
        XCTAssertEqual(SpawnDecision.mamma(mostri: 17), .bonus)    // :466 gate
        XCTAssertEqual(SpawnDecision.mamma(mostri: 34), .bonus)
        XCTAssertEqual(SpawnDecision.mamma(mostri: 81), .bonus)
        XCTAssertEqual(SpawnDecision.mamma(mostri: 3), .amico)     // :469 mostri%5 != 0 → amico
        XCTAssertEqual(SpawnDecision.mamma(mostri: 5), .monster)   // :471 multiplo di 5 → mostro
        XCTAssertEqual(SpawnDecision.mamma(mostri: 10), .monster)
        XCTAssertEqual(SpawnDecision.mamma(mostri: 51), .bonus)    // gate vince sul %5
    }
}
```

Implementazione (`SpawnDecision.swift`):

```swift
enum SpawnKind { case amico, bonus, monster }

enum SpawnDecision {
    /// MyScene2.m:458-474 — port esatto della catena if/else
    static func mamma(mostri: Int) -> SpawnKind {
        if mostri == 0 { return .amico }
        if GameConfig.Mamma.bonusGates.contains(mostri) { return .bonus }
        if mostri % 5 != 0 { return .amico }
        return .monster
    }
}
```

- [ ] **Step 2: Run test → PASS.**

- [ ] **Step 3: Scrivi `GameSceneMamma.swift`.** Differenze strutturali vs GameScene (tutto il resto si porta con lo stesso schema del Task 11, leggendo MyScene2.m alle righe indicate):

```swift
import SpriteKit

final class GameSceneMamma: SKScene, SKPhysicsContactDelegate {
    private var mamma: MammaNode!
    private var lifeBar: LifeBarNode!
    private let trail = TrailNode()
    private var movableSprites: [GabbianoNode] = []
    private var mostri = 0
    private var punteggio = 0
    private var colpiMostro = 0
    private var lastSpawnTimeInterval: TimeInterval = 0
    private var lastUpdateTime: TimeInterval = 0
    // + time/gameTimer/pause/HUD identici a GameScene (MyScene2.m:973-997, 1228-1343)
    // NB: niente player, niente accelerometro (commentato nell'originale, :398-457)
```

Punti obbligati del port (con riferimento):
- `didMove`: sfondi e musica come GameScene; mamma al centro `(w/2, h/4)` (:119) con `polygonBody()`; lifeBar a `(w/2+20, h-40)` scale 1.4 (:159-163); HUD con label a colori/posizioni di :973-991; countdown identico al Task 11 ma SENZA accelerometro e con bottoni pausa alle posizioni `GameConfig.Mamma.pause*Pos` (:1292, :1303).
- `update`: solo spawn — accumula delta, `> 5.2 → reset 4.5` e switch su `SpawnDecision.mamma(mostri:)` (:458-474).
- `addAmico` (:650-812) / `addBonus` (:482-648) / `addMonster` (:814-971): stessa generazione waypoint del Task 11 (estraila in un helper privato condiviso copiandola, parametrizzata su `velocityBase` 360 e `removeAtEnd`); ogni `add*` fa `mostri += 1`, suona `woowoo.mp3`, appende il nodo a `movableSprites`. Differenze: amico usa `volaAmico()` e `isAmico = true`; bonus `isBonus = true`; il monster di MyScene2 termina con fadeOut + remove (sequenza singola, NON repeatForever — :814-971), amico e bonus loopano forever.
- Touch (:273-381) — codice completo:

```swift
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let t = touches.first else { return }
        let loc = t.location(in: self)
        trail.reset()
        trail.position = loc
        if trail.parent == nil { addChild(trail) }          // :276-277
        hitTest(at: loc, radius: GameConfig.Mamma.touchRadiusBegan)
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let t = touches.first else { return }
        let loc = t.location(in: self)
        trail.position = loc                                 // :328
        hitTest(at: loc, radius: GameConfig.Mamma.touchRadiusMoved)
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        trail.removeFromParent()                             // :377-381
        trail.reset()
    }

    /// MyScene2.m:281-319 — hit detection manuale a distanza euclidea
    private func hitTest(at loc: CGPoint, radius: CGFloat) {
        for sprite in movableSprites {
            let distance = hypot(sprite.position.x - loc.x, sprite.position.y - loc.y)
            guard distance <= radius else { continue }
            sprite.removeAllActions()
            sprite.muore()                                   // :292-294
            if sprite.isAmico {                              // :296-299
                punteggio += 1
                AudioService.shared.playEffect("bird_00.mp3")
            } else if sprite.isBonus {                       // :300-307 — cura 3, clamp a 0
                for _ in 0..<GameConfig.Mamma.bonusHealAmount where colpiMostro != 0 {
                    colpiMostro -= 1
                    controllaVita()
                }
            } else {                                         // :308-314 — colpire un mostro col dito ferisce la mamma!
                mamma.soffre()
                colpiMostro += 1
                if colpiMostro <= GameConfig.maxColpi { controllaVita() }
            }
            scoreLabel.text = ScoreFormatter.hits(punteggio) // :315
            movableSprites.removeAll { $0 === sprite }       // :316
        }
    }
```

- Collisioni `didBegin` (:1009-1052): mamma|gabbiano → `soffre` + colpi++ + vita; colpi|gabbiano e colpi|fuoco come Task 11 (presenti nell'originale anche se in questa modalità la categoria `colpi` non viene mai assegnata — portare per fedeltà).
- `controllaVita` (:1187-1203) e `gameOver` (:1205-1226): identici al Task 11 ma `GameOverScene(size:mode:.mamma, score:)`; rimuovi anche i gabbiani da `movableSprites` quando muoiono/escono.
- Pausa (:1274-1343): identica, posizioni bottoni Mamma.

- [ ] **Step 4: Builda, verifica sul simulatore:** "Start Mamma" → countdown → primo uccello amico (a testa in giù) dopo ~5 s, tap/swipe con scia bianca, colpire amici fa salire Hits, colpire mostri ferisce la mamma, bonus ogni tanto cura 3 tacche, 9 colpi → game over mamma.

- [ ] **Step 5: Commit** — `git commit -m "port: GameSceneMamma (streak, hit manuale, spawn amico/bonus/mostro)"`

---

### Task 13: GameOverScene unificata

**Files:**
- Rewrite: `WooWoo/Sources/Scenes/GameOverScene.swift`
- Create: `WooWoo/Sources/Config/AchievementRules.swift`
- Test: `WooWoo/Tests/AchievementRulesTests.swift`

- [ ] **Step 1: TDD su `AchievementRules`** — replica ESATTA di GameOverScene.m:242-343, comprese le stranezze: `isPrimeNumber` con loop `for i in 2..<(number-1)` (0, 1, 2, 3 risultano "primi"!); al massimo UN achievement "score" e UNO "level" (le condizioni successive sovrascrivono); si invia SOLO se quello "score" esiste.

```swift
import XCTest
@testable import WooWoo

final class AchievementRulesTests: XCTestCase {
    func testPrimeQuirks() {     // GameOverScene.m:321-343
        XCTAssertTrue(AchievementRules.isPrimeLikeOriginal(0))   // loop non eseguito → YES
        XCTAssertTrue(AchievementRules.isPrimeLikeOriginal(1))
        XCTAssertTrue(AchievementRules.isPrimeLikeOriginal(2))
        XCTAssertTrue(AchievementRules.isPrimeLikeOriginal(7))
        XCTAssertFalse(AchievementRules.isPrimeLikeOriginal(4))
        XCTAssertFalse(AchievementRules.isPrimeLikeOriginal(9))
    }
    func testReportOnlyWhenScoreAchievementExists() {
        // NB: gamesPlayed è il contatore DOPO l'incremento della partita corrente
        // (GameOverScene.m: aggiungi_partita_giocata a :78, updateAchievements a :107).
        // Conseguenza: badge_1partita (gamesPlayed == 0) era IRRAGGIUNGIBILE già nel 2014 — bug preservato.

        // punteggio 0, partite 5 → 0 è "primo" per l'algoritmo originale → report con entrambi
        XCTAssertEqual(AchievementRules.achievements(score: 0, gamesPlayed: 5),
                       ["badge_0uccisi", "badge_numeriprimi"])
        // punteggio 6 (non primo, < 50) → nessun score achievement → NIENTE report (:310)
        XCTAssertEqual(AchievementRules.achievements(score: 6, gamesPlayed: 9), [])
        // 42 non è primo → solo badge_42
        XCTAssertEqual(AchievementRules.achievements(score: 42, gamesPlayed: 5), ["badge_42"])
        // 101 ≥ 50 e ≥ 100 → badge_100uccisi sovrascrive 50 e numeriprimi
        XCTAssertEqual(AchievementRules.achievements(score: 101, gamesPlayed: 5), ["badge_100uccisi"])
        // 2 primo, 9ª partita post-incremento → level badge_10partite + score numeriprimi
        XCTAssertEqual(AchievementRules.achievements(score: 2, gamesPlayed: 9),
                       ["badge_10partite", "badge_numeriprimi"])
        // prima partita reale (gamesPlayed == 1 dopo incremento): NIENTE badge_1partita
        XCTAssertEqual(AchievementRules.achievements(score: 2, gamesPlayed: 1), ["badge_numeriprimi"])
    }
}
```

Implementazione:

```swift
/// Port esatto di GameOverScene.m:242-343 (identico nella variante Mamma),
/// incluse le stranezze: vedi i test.
enum AchievementRules {
    static func isPrimeLikeOriginal(_ number: Int) -> Bool {   // :321-343
        var i = 2
        while i < number - 1 {
            if number % i == 0 { return false }
            i += 1
        }
        return true
    }

    /// Ordine di ritorno: [level, score] come :311. Vuoto se manca lo score achievement (:310).
    /// `gamesPlayed` è il contatore POST-incremento (semantica originale, vedi test).
    static func achievements(score: Int, gamesPlayed: Int) -> [String] {
        var scoreAchievement: String?
        var levelAchievement: String?
        if isPrimeLikeOriginal(score) { scoreAchievement = "badge_numeriprimi" }   // :255
        if score == 0 { levelAchievement = "badge_0uccisi" }                       // :262
        if score == 42 { scoreAchievement = "badge_42" }                           // :269
        if score >= 50 { scoreAchievement = "badge_50uccisi" }                     // :275
        if score >= 100 { scoreAchievement = "badge_100uccisi" }                   // :281
        if gamesPlayed == 0 { levelAchievement = "badge_1partita" }                // :287 (irraggiungibile, bug 2014)
        if gamesPlayed == 9 { levelAchievement = "badge_10partite" }               // :294
        if gamesPlayed == 99 { levelAchievement = "badge_100partite" }             // :301
        guard let scoreAchievement else { return [] }                              // :310
        return [levelAchievement, scoreAchievement].compactMap { $0 }
    }
}
```

- [ ] **Step 2: Run test → PASS.**

- [ ] **Step 3: Scrivi `GameOverScene.swift`** (sostituisce lo stub del Task 11; unifica GameOverScene.m + GameOverSceneMamma.m — uniche differenze: chiavi/metodi `_mamma`, scena rigioca, scena punteggi):

```swift
import SpriteKit
import GameKit

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
        bg.color = SKColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
        bg.colorBlendFactor = 1.0                                  // :28
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
        label.fontSize = 50; label.fontColor = .white
        label.position = norm(0.70, 0.55)
        addChild(label)

        if isRecord {                                              // :81-90
            let record = SKLabelNode(fontNamed: GameConfig.fontName)
            record.text = "Nuovo record!! "
            record.fontSize = 50; record.fontColor = .white
            record.position = norm(0.70, 0.30)
            addChild(record)
        }

        buildButtons()

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
            GameCenterService.shared.showPanel(state: .achievements, mode: self.mode)
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
```

- [ ] **Step 4: Builda, verifica:** partita persa → schermata con punteggio, "Nuovo record!!" quando battuto, rigioca riavvia la modalità giusta, punteggi/medaglie navigano, le statistiche si accumulano tra le partite (riavvia l'app e controlla).

- [ ] **Step 5: Commit** — `git commit -m "port: GameOverScene unificata + AchievementRules (TDD, quirk inclusi)"`

---

### Task 14: PunteggiScene unificata

**Files:**
- Rewrite: `WooWoo/Sources/Scenes/PunteggiScene.swift`

Port di PunteggiScene.m + variante Mamma (differenze: solo chiavi/leaderboard). Stringhe e posizioni esatte da :46-122 (già verificate nei sorgenti):

- [ ] **Step 1: Scrivi la scena**

```swift
import SpriteKit
import GameKit

final class PunteggiScene: SKScene {
    private let mode: GameMode
    private let scoreStore = ScoreStore()

    init(size: CGSize, mode: GameMode) {
        self.mode = mode
        super.init(size: size)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func didMove(to view: SKView) {
        buildLayout()
        if GameCenterService.shared.isAuthenticated {     // :165, :200-213 — invia il record al load
            GameCenterService.shared.submit(score: scoreStore.best(for: mode), mode: mode)
        }
    }

    private func buildLayout() {
        let isIT = Locale.current.language.languageCode?.identifier == "it"
        let record = scoreStore.best(for: mode)
        let partite = scoreStore.gamesPlayed(for: mode)
        let totali = scoreStore.totalPoints(for: mode)
        // :40-43 — media a 0 se una delle due è 0
        let media: Double = (totali != 0 && partite != 0) ? Double(totali) / Double(partite) : 0

        let bg = SKSpriteNode(imageNamed: "splashscreeniPhone5")
        bg.position = CGPoint(x: size.width / 2, y: size.height / 2)
        bg.setScale(size.width / bg.size.width)
        bg.color = SKColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
        bg.colorBlendFactor = 1.0
        addChild(bg)

        addLabel(isIT ? "Punteggi" : "Scoreboard", GameConfig.fontNameBold, 60, .yellow, norm(0.70, 0.90))  // :52-65
        addLabel("Record:", GameConfig.fontName, 30, .white, norm(0.70, 0.75))                              // :67-72
        addLabel("\(record) Gabbiani", GameConfig.fontName, 30, .white, norm(0.70, 0.65))                   // :74-79
        addLabel(isIT ? "Punteggio Medio :" : "Average points :", GameConfig.fontName, 30, .white, norm(0.70, 0.50))  // :81-96
        addLabel(String(format: "%.2f Gabbiani", media), GameConfig.fontName, 30, .white, norm(0.70, 0.40)) // :99-104
        addLabel(isIT ? "Hai giocato \(partite) volte" : "You played \(partite) times",
                 GameConfig.fontName, 30, .white, norm(0.70, 0.25))                                         // :107-121

        let back = SKButtonNode(imageNamed: "btn_chiudi")                                                   // :124-128
        back.position = CGPoint(x: safeX(norm(0.05, 0).x), y: norm(0, 0.10).y)
        back.action = { [weak self] in
            guard let self else { return }
            self.go(to: IntroScene(size: self.size), .quick)
        }
        addChild(back)

        let classifica = SKButtonNode(imageNamed: "btn_label", title: "Punteggi")                           // :130-139
        classifica.position = norm(0.70, 0.10)
        classifica.action = { [weak self] in
            guard let self else { return }
            GameCenterService.shared.showPanel(state: .leaderboards, mode: self.mode)
        }
        addChild(classifica)

        let medaglie = SKButtonNode(imageNamed: "btn_label", title: "Medaglie")                             // :141-150
        medaglie.position = norm(0.30, 0.10)
        medaglie.action = { [weak self] in
            guard let self else { return }
            GameCenterService.shared.showPanel(state: .achievements, mode: self.mode)
        }
        addChild(medaglie)

        let cestino = SKButtonNode(imageNamed: "btn_cestino")                                               // :157-165
        cestino.position = CGPoint(x: safeX(norm(0.95, 0).x), y: norm(0, 0.10).y)
        cestino.action = { [weak self] in
            guard let self else { return }
            self.scoreStore.reset(self.mode)            // :184 cancella_punteggi[_mamma]
            self.removeAllChildren()
            self.buildLayout()                          // re-init scena come l'originale
        }
        addChild(cestino)
    }

    private func addLabel(_ text: String, _ font: String, _ fontSize: CGFloat, _ color: SKColor, _ p: CGPoint) {
        let l = SKLabelNode(fontNamed: font)
        l.text = text; l.fontSize = fontSize; l.fontColor = color; l.position = p
        addChild(l)
    }
}
```
Nota: rimuovi lo stub del Task 9.

- [ ] **Step 2: Builda, verifica:** entrambe le schermate punteggi (normale e Mamma) mostrano stats coerenti e separate; il cestino azzera solo la propria modalità; con Game Center non autenticato nessun crash.

- [ ] **Step 3: Commit** — `git commit -m "port: PunteggiScene unificata (stats, GC, reset per modalità)"`

---

### Task 15: SelfieScene

**Files:**
- Rewrite: `WooWoo/Sources/Scenes/SelfieScene.swift`
- Create: `WooWoo/Sources/Services/CameraPicker.swift`

Port di SelfieScene.m: fotocamera frontale con cornice overlay, 5 cornici (`WooWooSelfie_canvas01-05`), flip orizzontale, condivisione. Stato solo in memoria (nessuna persistenza — verificato).

- [ ] **Step 1: Scrivi `CameraPicker.swift`** — bridge UIImagePickerController (API tuttora supportata per lo scatto):

```swift
import UIKit

/// Fotocamera frontale come SelfieScene.m:194-301.
/// Gestisce il permesso negato mostrando un alert (requisito spec: degradazione con grazia).
final class CameraPicker: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    static let shared = CameraPicker()
    private var completion: ((UIImage?) -> Void)?

    func pick(completion: @escaping (UIImage?) -> Void) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else { completion(nil); return }
        self.completion = completion
        let picker = UIImagePickerController()
        picker.sourceType = .camera                     // :268
        picker.cameraDevice = .front                    // :277
        picker.cameraCaptureMode = .photo               // :271
        picker.allowsEditing = true                     // :274
        picker.delegate = self
        GameCenterService.rootViewController?.present(picker, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        completion?((info[.editedImage] ?? info[.originalImage]) as? UIImage)   // :303-310
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
        completion?(nil)
    }
}
```

- [ ] **Step 2: Scrivi `SelfieScene.swift`.** Layout esatto (:36-111): sfondo `bkg_cielo` tinta (200,200,200); back `btn_chiudi` (0.90, 0.90); cornici `btn_cornice05→01` alle posizioni (0.10, 0.10/0.30/0.50/0.70) e (0.15, 0.90), scala 0.8 — la selezionata si sposta a x 0.15 (:431-505); `btn_foto` (0.90, 0.50) scala 0.8; `btn_rotate_right` (0.90, 0.30); `btn_share` (0.90, 0.10). Comportamento:

```swift
import SpriteKit
import UIKit

final class SelfieScene: SKScene {
    private var photoNode: SKSpriteNode?            // foto scattata, scale 0.4, al centro (:129-134, :363-365)
    private var overlayNode: SKSpriteNode?          // cornice sopra la foto, scale 0.8 (:136-152)
    private var currentCanvas = "WooWooSelfie_canvas01"   // default :111
    private var frameButtons: [SKButtonNode] = []
    private var lastImage: UIImage?
    private var flipped = false

    override func didMove(to view: SKView) { buildLayout() }

    private func buildLayout() {
        let bg = SKSpriteNode(imageNamed: "bkg_cielo")
        bg.position = CGPoint(x: size.width / 2, y: size.height / 2)
        bg.setScale(size.width / bg.size.width)
        bg.color = SKColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
        bg.colorBlendFactor = 1.0
        addChild(bg)

        let back = SKButtonNode(imageNamed: "btn_chiudi")
        back.position = CGPoint(x: safeX(norm(0.90, 0).x), y: norm(0, 0.90).y)
        back.action = { [weak self] in
            guard let self else { return }
            self.go(to: IntroScene(size: self.size), .quick)    // :178-181
        }
        addChild(back)

        // 5 cornici: bottone N usa btn_cornice0(6-N) e canvas0(6-N) (:50-88, :431-505)
        let yPositions: [CGFloat] = [0.10, 0.30, 0.50, 0.70, 0.90]
        for (i, y) in yPositions.enumerated() {
            let idx = 5 - i                                    // bottone 1 → cornice 05 … bottone 5 → cornice 01
            let b = SKButtonNode(imageNamed: String(format: "btn_cornice%02d", idx))
            b.setScale(0.8)
            b.position = norm(i == 4 ? 0.15 : 0.10, y)         // la 5ª parte già a 0.15 (:83-88)
            b.action = { [weak self] in self?.selectFrame(canvasIndex: idx, buttonRow: i) }
            addChild(b); frameButtons.append(b)
        }

        let foto = SKButtonNode(imageNamed: "btn_foto")
        foto.setScale(0.8)
        foto.position = CGPoint(x: safeX(norm(0.90, 0).x), y: norm(0, 0.50).y)
        foto.action = { [weak self] in self?.takePhoto() }
        addChild(foto)

        let flip = SKButtonNode(imageNamed: "btn_rotate_right")
        flip.position = CGPoint(x: safeX(norm(0.90, 0).x), y: norm(0, 0.30).y)
        flip.action = { [weak self] in self?.flipImage() }
        addChild(flip)

        let share = SKButtonNode(imageNamed: "btn_share")
        share.position = CGPoint(x: safeX(norm(0.90, 0).x), y: norm(0, 0.10).y)
        share.action = { [weak self] in self?.share() }
        addChild(share)

        updateOverlay()
    }

    private func selectFrame(canvasIndex: Int, buttonRow: Int) {   // :431-505
        currentCanvas = String(format: "WooWooSelfie_canvas%02d", canvasIndex)
        let yPositions: [CGFloat] = [0.10, 0.30, 0.50, 0.70, 0.90]
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
        node.setScale(0.4 * (size.height / node.size.height) * 2.5)   // ≈ resa originale; tarare a vista vs 2014
        addChild(node)
        photoNode = node
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
        guard let composite = compositeImage() else { return }
        let items: [Any] = ["Woo woo Selfie", URL(string: "http://www.woowoothegame.com/")!, composite]
        let vc = UIActivityViewController(activityItems: items, applicationActivities: nil)
        GameCenterService.rootViewController?.present(vc, animated: true)
    }

    /// Foto + cornice → UIImage (sostituisce convertSpriteToImage/CCRenderTexture :418-429)
    private func compositeImage() -> UIImage? {
        guard let view, let photoNode else { return nil }
        let region = photoNode.calculateAccumulatedFrame().union(overlayNode?.calculateAccumulatedFrame() ?? .zero)
        guard let texture = view.texture(from: self, crop: region) else { return nil }
        return UIImage(cgImage: texture.cgImage())
    }

    private func showCameraDeniedAlertIfNeeded() {
        let alert = UIAlertController(title: "Fotocamera non disponibile",
            message: "Per scattare il Woowoo Selfie abilita la fotocamera in Impostazioni > Privacy.",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        GameCenterService.rootViewController?.present(alert, animated: true)
    }
}
```
⚠️ Le scale della foto e dell'overlay nell'originale dipendevano da costanti per schermi 2014 (:147-151, :363): la resa va **tarata a vista** confrontando con gli screenshot del gioco originale; i punti di taratura sono i due `setScale` qui sopra.

- [ ] **Step 3: Builda, verifica sul simulatore:** la scena si apre, le cornici si selezionano e si alzano, share senza foto non crasha (no-op). NB: la fotocamera nel simulatore non esiste → `pick` ritorna nil e mostra l'alert: corretto. Test completo fotocamera al Task 17 su device.

- [ ] **Step 4: Commit** — `git commit -m "port: SelfieScene (camera, cornici, flip, share)"`

---### Task 16: Rifinitura — musica menu, transizioni audio, pulizia

- [ ] **Step 1: Audit audio di navigazione.** Nell'originale la musica parte SOLO nelle scene di gioco (`main_theme_w_intro.mp3` in MyScene/MyScene2 init) e si ferma al game over / exit; IntroScene non suona musica. Verifica con `grep -n "OALSimpleAudio" "Woo Woo The Game/Classes/"*.m` che il port non abbia introdotto o perso chiamate: ogni `playBg/playEffect/stopBg/stopAllEffects` legacy deve avere il suo equivalente `AudioService` nello stesso punto del flusso.

- [ ] **Step 2: Rimuovi gli `showsFPS/showsNodeCount`** se attivati durante lo sviluppo; rimuovi eventuali `print` di debug dal codice nuovo.

- [ ] **Step 3: Confronto GameConfig ↔ sorgenti.** Rilettura finale di `GameConfig.swift` con i sorgenti aperti: ogni valore citato deve coincidere con la riga citata.

```bash
grep -nE "5\.2|4\.5|360\.0|180\.0|1400|0\.1f|20\.0f" "Woo Woo The Game/Woo Woo The Game/Classes/MyScene.m" "Woo Woo The Game/Woo Woo The Game/Classes/MyScene2.m" | head -20
```

- [ ] **Step 4: Builda + tutti i test. Commit** — `git commit -m "port: rifinitura audio e pulizia debug"`

---

### Task 17: Verifica finale

- [ ] **Step 1: Suite test completa**

```bash
xcodebuild -project WooWoo.xcodeproj -scheme WooWoo \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' test
```
Expected: TEST SUCCEEDED, tutti verdi.

- [ ] **Step 2: Checklist manuale sul simulatore** (ogni voce va spuntata):

| # | Percorso | Atteso |
|---|---|---|
| 1 | Avvio | Menu landscape, titolo, niente bande nere, niente elementi sotto il notch |
| 2 | Toggle audio/sound/vibro | Cambiano icona, persistono al riavvio dell'app |
| 3 | Crediti | Alert con testo originale |
| 4 | Start → Tutorial | 5 pagine a swipe, pallini, Start parte, chiudi torna |
| 5 | Partita figlia | Countdown, musica, spawn ~5 s, zacca dx/sx col tap, gabbiano→fuoco→morto (+1), 9 colpi → game over |
| 6 | Pausa figlia | Resume riprende (timer incluso), Exit → menu |
| 7 | Game over | Punteggio giusto, record quando battuto, rigioca/punteggi/menu |
| 8 | Start Mamma | Primo uccello amico capovolto, scia bianca, amico +1, mostro ferisce, bonus cura 3 |
| 9 | Punteggi (entrambe) | Record/media/partite coerenti e separate; cestino azzera solo la sua modalità |
| 10 | Selfie | Cornici selezionabili, alert fotocamera nel simulatore |
| 11 | Background/foreground | L'app in background mette in pausa, al ritorno non salta frame |

- [ ] **Step 3: Verifica su device reale** (unico posto dove si testano davvero):
- Movimento ad accelerometro della figlia (inclinare = muoversi, deceleration/sensitivity come da gioco originale)
- Vibrazione al game over (flag vibro on/off)
- Fotocamera selfie: scatto, cornice, flip, share sheet
- Game Center: se l'app esiste in App Store Connect appare il login; altrimenti nessun crash (degradazione corretta)
- Performance: 60/120 fps stabili, nessun hitch durante lo spawn

```bash
xcrun devicectl list devices   # trova il device collegato
xcodebuild -project WooWoo.xcodeproj -scheme WooWoo -destination 'platform=iOS,name=<NOME DEVICE>' build
```
(L'installazione su device richiede il team di firma configurato in project.yml → `DEVELOPMENT_TEAM`.)

- [ ] **Step 4: Confronto fianco a fianco con la spec** — rileggi `docs/superpowers/specs/2026-06-12-woowoo-spritekit-port-design.md` sezione per sezione e spunta che ogni requisito sia implementato.

- [ ] **Step 5: Commit finale + merge**

```bash
git add -A && git commit -m "port: verifica finale completata"
```
Poi usa la skill superpowers:finishing-a-development-branch per integrare il branch.

---

## Note di esecuzione

- **Branch:** esegui su un branch dedicato (`port/spritekit`) creato con la skill superpowers:using-git-worktrees.
- **Un task = un commit** (minimo). Mai proseguire con build rossa.
- **Quando un dettaglio visivo non torna** (posizione, scala, framing): la risposta è SEMPRE nel sorgente legacy alla riga indicata nella tabella in testa al piano. Aprirlo e portarlo 1:1, non interpretare.
- **Parità ≠ pixel-perfect sugli schermi nuovi:** le posizioni normalizzate si applicano alla larghezza estesa (~693 pt vs 568): è la scelta di design approvata (schermo pieno adattivo). Le posizioni ASSOLUTE (player a x=100, label a 25 px dal bordo) restano assolute.
