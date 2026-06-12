# Woo Woo The Game — Porting a Swift + SpriteKit

**Data:** 2026-06-12
**Stato:** approvato in brainstorming, in attesa di review finale della spec

## Obiettivo

Portare il gioco "Woo Woo The Game" (2014, Objective-C + Cocos2D-iPhone 3.x/SpriteBuilder) sulle tecnologie Apple correnti, mantenendo **identici asset, gameplay e bilanciamento**. Obiettivo dichiarato: *preservazione con futuro aperto* — il gioco deve girare bene su iOS 2026 ed essere architetturalmente pronto per un'eventuale ripubblicazione su App Store, senza ads né analytics per ora.

Non è un aggiornamento incrementale: Cocos2D-iPhone è abbandonato dal ~2017 e non compila su Xcode moderno. È una **riscrittura con porting 1:1 della logica**.

## Stato del progetto originale

- ~6.150 righe di Objective-C in 16 classi (`Woo Woo The Game/Classes/`)
- Engine: Cocos2D-iPhone 3.x via SpriteBuilder, fisica Chipmunk, audio ObjectAL, rendering OpenGL ES
- Target: iOS 7.0, design per schermi iPhone 5 (16:9), portrait, solo iPhone
- Bundle id: `com.woowoothegame`
- Dipendenze morte: Google Analytics "GAI" (servizio spento da Google), AdMob SDK ~2014
- Due modalità di gioco:
  - **Modalità figlia** (`MyScene`): il player controlla la figlia, gabbiani come nemici
  - **Modalità mamma** (`MyScene2`): variante con la mamma protagonista
- Feature: tutorial, selfie con fotocamera + cornici (`SelfieScene`), classifiche locali (UserDefaults) e Game Center, controlli ad accelerometro (CoreMotion), vibrazione

## Decisioni prese

| Decisione | Scelta |
|---|---|
| Engine | **Swift + SpriteKit** (no Unity/Godot, no patch del vecchio Cocos2D) |
| Obiettivo | Preservazione + futuro aperto (App Store-ready, senza pubblicare subito) |
| Schermi moderni | **Schermo pieno adattivo**: campo di gioco esteso a tutto schermo, HUD nella safe area |
| Ads/Analytics | **Rimossi** (servizi morti; eventuale reintroduzione è fuori scope) |
| Game Center | Portato con GameKit moderno, degrada con grazia se non autenticato |
| Asset | Riusati identici (sprite PNG, audio MP3, font Moon Flower) |

## Architettura nuova

### Struttura del repository

```
Woo Woo The Game/            ← repo git (baseline 2014 committata)
├── Woo Woo The Game/        ← progetto 2014, intoccato, riferimento permanente
├── Woo Woo The Game.xcodeproj
├── docs/superpowers/specs/  ← questa spec
└── WooWoo/                  ← nuovo progetto Xcode (Swift + SpriteKit)
```

### App shell

- **SwiftUI** `@main App` con `SpriteView` a schermo pieno (ignora safe area a livello di view; è il contenuto a rispettarla dove serve)
- Le scene SpriteKit si rimpiazzano tra loro con `SKView.presentScene` — stessa architettura di `CCDirector replaceScene` dell'originale
- Ponti UIKit (`UIViewControllerRepresentable`) solo per: fotocamera (selfie) e pannello Game Center
- **Target: iOS 17+**, solo iPhone, portrait

### Mappa dei componenti

| Originale (Cocos2D) | Nuovo (SpriteKit) | Note |
|---|---|---|
| `IntroScene` | `IntroScene` | Menu principale |
| `TutorialScene` | `TutorialScene` | |
| `MyScene` | `GameScene` | Modalità figlia |
| `MyScene2` | `GameSceneMamma` | Modalità mamma |
| `GameOverScene` + `GameOverSceneMamma` | `GameOverScene` parametrizzata per modalità | Erano duplicate ~90% |
| `PunteggiScene` + `PunteggiSceneMamma` | `PunteggiScene` parametrizzata per modalità | Idem |
| `SelfieScene` | `SelfieScene` | Camera con API moderne + `NSCameraUsageDescription` |
| `PlayerSprite`, `MammaSprite`, `GabbianoSprite`, `LifeBarSprite` | Stesse classi, sottoclassi `SKNode`/`SKSpriteNode` | |
| `Singleton` (335 righe) | `Settings` + `ScoreStore` | Stesse chiavi UserDefaults (sotto) |
| Chipmunk / `CCPhysicsNode` | `SKPhysicsBody` + `SKPhysicsContactDelegate` | Category bit mask per i tipi di collisione |
| ObjectAL | `AudioService` su AVFoundation | Stessi MP3; musica di fondo + effetti |
| `CMMotionManager` (accelerometro) | Identico | Stessi valori e soglie |
| `CustomIOS7AlertView` | Alert nativi | Esisteva solo per lo styling iOS 7 |
| Game Center (`GKScore`, deprecato) | `GKLeaderboard.submitScore` | Degrada se non autenticato |
| Vibrazione (AudioServices) | Haptics moderni (`UIImpactFeedbackGenerator`) | Rispetta il flag `vibro` |
| Google Analytics (GAI) | **Rimosso** | Servizio spento |
| AdMob | **Rimosso** | |
| `CCRenderTexture` (selfie in-game) | `SKTexture` da `UIImage` | |

### Fedeltà della logica: `GameConfig`

Tutte le costanti di gameplay vengono estratte dai sorgenti 2014 e centralizzate in un `GameConfig` Swift, con riferimento al file/riga originale:

- intervalli e logica di spawn dei gabbiani
- velocità di movimento (player, nemici, proiettili)
- valori di punteggio e moltiplicatori
- soglie accelerometro
- vita / numero colpi (`colpi_mostro`)
- durate timer e countdown

Questo rende la parità di comportamento **verificabile a colpo d'occhio** confrontando `GameConfig` con i `.m` originali.

### Persistenza: chiavi UserDefaults preservate

Stesse chiavi dell'originale, così i salvataggi esistenti sopravvivono al porting:

`first`, `first_mamma`, `sound`, `audio`, `vibro`, `punteggio_massimo`, `punteggio_massimo_mamma`, `numero_partite`, `numero_partite_mamma`, `punti_totali`, `punti_totali_mamma`

- `Settings`: audio / sound / vibro
- `ScoreStore`: punteggi massimi, partite giocate, punti totali (per modalità)

### Schermi moderni

- Altezza logica di design fissa (pari al design originale); la larghezza si estende sui display 19.5:9
- Sfondi a copertura piena dello schermo
- HUD (punteggio, timer, pausa) ancorato alla **safe area** — mai sotto notch/Dynamic Island
- Spawn e limiti di movimento calcolati sulle dimensioni reali della scena, non hardcoded

### Asset

- Sprite PNG riusati (i file `-hd` dell'originale mappati come `@2x` in asset catalog)
- Audio MP3 riusati così come sono
- Font `Moon Flower` / `Moon Flower Bold` registrati in Info.plist (`UIAppFonts`)
- Icone app rigenerate dalle sorgenti in `App-ico` per i formati moderni

## Gestione errori

- **Permesso fotocamera negato** → alert con spiegazione, la SelfieScene degrada (si torna indietro senza selfie)
- **Game Center non autenticato** → nessun invio punteggio, gioco normale (comportamento originale)
- **Interruzioni audio** (telefonate, Siri) → pausa/ripresa pulite della musica
- **App in background** → pausa automatica del gameplay (come l'originale)

## Verifica "stesso gioco"

1. **Unit test** su `ScoreStore`, `Settings` (persistenza, stesse chiavi) e sulla logica di punteggio/spawn estraibile
2. **`GameConfig` confrontabile** fianco a fianco con i sorgenti 2014
3. **Verifica manuale** su simulatore e device reale, scena per scena, a fine porting (intro → tutorial → entrambe le modalità → game over → punteggi → selfie)

## Fuori scope (esplicito)

- Nuove feature o cambi di bilanciamento
- Ads e analytics (eventuale reintroduzione in futuro, non ora)
- Android / cross-platform
- Ritocco o rifacimento asset
- iPad layout dedicato
- Pubblicazione App Store (il progetto deve solo essere *pronto*)
