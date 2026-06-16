# Sistema Achievement — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Aggiungere un sistema di achievement con feedback visivo in-game (toast + recap + galleria) coerente con lo stile dell'app, basato su tracking locale con mirror Game Center.

**Architecture:** Nuovo gruppo `WooWoo/Sources/Achievements/` con modello+catalogo, store (UserDefaults) e service (valutazione + mirror GC). UI nuova: `AchievementToastNode` (overlay in gioco) e `AchievementsScene` (galleria "Medaglie"). Le scene di gioco notificano eventi al service e mostrano i toast. Sostituisce `AchievementRules` (badge 2014).

**Tech Stack:** Swift 6, SpriteKit, GameKit, XCTest, UserDefaults. XcodeGen genera il progetto (`xcodegen generate --spec "WooWoo/project.yml"` se aggiungi file e usi Xcode senra auto-glob — le `sources: [Sources]` sono a cartella, quindi i nuovi file vengono inclusi al prossimo generate).

**Scope note:** L'integrazione in gioco è limitata a **GameScene (Figlia)**, l'unica modalità raggiungibile (Mamma è nascosta dal menu). Il service è generico: il wiring di `GameSceneMamma` è esplicitamente **rimandato** e annotato come tale.

**Comandi ricorrenti:**
- Rigenera progetto (dopo aver creato file nuovi): `xcodegen generate --spec "WooWoo/project.yml"`
- Test: `xcodebuild test -project "WooWoo/WooWoo.xcodeproj" -scheme WooWoo -destination 'platform=iOS Simulator,name=iPhone 15'`
- Build: `xcodebuild build -project "WooWoo/WooWoo.xcodeproj" -scheme WooWoo -destination 'generic/platform=iOS Simulator'`

---

## File Structure

**Nuovi:**
- `WooWoo/Sources/Achievements/Achievement.swift` — modello + enum (Category, Rarity, Trigger)
- `WooWoo/Sources/Achievements/AchievementCatalog.swift` — i 15 achievement
- `WooWoo/Sources/Achievements/AchievementStore.swift` — persistenza UserDefaults
- `WooWoo/Sources/Achievements/GameCenterMirror.swift` — protocollo per il mirror (testabilità)
- `WooWoo/Sources/Achievements/AchievementService.swift` — valutazione + sblocco + mirror
- `WooWoo/Sources/Nodes/AchievementToastNode.swift` — toast visivo + presenter con coda
- `WooWoo/Sources/Scenes/AchievementsScene.swift` — galleria "Medaglie"
- `WooWoo/Tests/AchievementCatalogTests.swift`
- `WooWoo/Tests/AchievementStoreTests.swift`
- `WooWoo/Tests/AchievementServiceTests.swift`

**Modificati:**
- `WooWoo/Sources/Scenes/GameScene.swift` — streak + hook + toast
- `WooWoo/Sources/Scenes/GameOverScene.swift` — `onGameEnd` + recap, init con `inGameUnlocks`
- `WooWoo/Sources/Scenes/SelfieScene.swift` — hook `onSelfie`
- `WooWoo/Sources/Scenes/IntroScene.swift` — bottone "Medaglie" (nuovo) → galleria
- `WooWoo/Sources/Scenes/PunteggiScene.swift` — bottone "Medaglie" → galleria

**Rimossi:**
- `WooWoo/Sources/Config/AchievementRules.swift`
- `WooWoo/Tests/AchievementRulesTests.swift`

---

## Task 1: Modello Achievement

**Files:**
- Create: `WooWoo/Sources/Achievements/Achievement.swift`

- [ ] **Step 1: Scrivi il modello**

```swift
import Foundation

enum AchievementCategory: String {
    case combo, punteggio, sopravvivenza, carriera, chicche
}

enum AchievementRarity: String {
    case comune, raro, epico
}

/// Condizione di sblocco. Valutata dal service contro lo stato di gioco / ScoreStore.
enum AchievementTrigger: Equatable {
    case streak(Int)            // streak >= n (uccisioni di fila senza danni)
    case scoreInGame(Int)       // punteggio partita >= n
    case scoreExact(Int)        // punteggio partita == n (Niente panico)
    case survival(TimeInterval) // tempo partita >= n
    case gamesPlayed(Int)       // ScoreStore.gamesPlayed >= n
    case totalKills(Int)        // ScoreStore.totalPoints >= n
    case selfie                 // primo selfie
}

struct Achievement: Identifiable, Equatable {
    let id: String
    let title: String
    let detail: String
    let category: AchievementCategory
    let rarity: AchievementRarity
    let trigger: AchievementTrigger
    let gcID: String?       // mirror Game Center se presente
    let isSecret: Bool
}
```

- [ ] **Step 2: Build per verificare che compili**

Run: `xcodegen generate --spec "WooWoo/project.yml"` poi il comando build.
Expected: BUILD SUCCEEDED (file vuoto di logica, solo tipi).

- [ ] **Step 3: Commit**

```bash
git add WooWoo/Sources/Achievements/Achievement.swift
git commit -m "feat(achievements): modello Achievement + trigger"
```

---

## Task 2: Catalogo dei 15 achievement

**Files:**
- Create: `WooWoo/Sources/Achievements/AchievementCatalog.swift`
- Test: `WooWoo/Tests/AchievementCatalogTests.swift`

- [ ] **Step 1: Scrivi il test di integrità**

```swift
import XCTest
@testable import WooWoo

final class AchievementCatalogTests: XCTestCase {
    func testHas15Achievements() {
        XCTAssertEqual(AchievementCatalog.all.count, 15)
    }
    func testIDsAreUnique() {
        let ids = AchievementCatalog.all.map(\.id)
        XCTAssertEqual(Set(ids).count, ids.count)
    }
    func testGCMirrorOnlyOnExpectedFive() {
        let withGC = AchievementCatalog.all.filter { $0.gcID != nil }.map(\.id).sorted()
        XCTAssertEqual(withGC, ["answer_42", "games_10", "games_100", "score_100", "score_50"])
    }
    func testOnlyAnswer42IsSecret() {
        let secrets = AchievementCatalog.all.filter(\.isSecret).map(\.id)
        XCTAssertEqual(secrets, ["answer_42"])
    }
    func testLookupByID() {
        XCTAssertEqual(AchievementCatalog.with(id: "combo_5")?.title, "Raffica")
        XCTAssertNil(AchievementCatalog.with(id: "nope"))
    }
}
```

- [ ] **Step 2: Run test — deve fallire (catalogo inesistente)**

Run: `xcodebuild test -project "WooWoo/WooWoo.xcodeproj" -scheme WooWoo -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:WooWooTests/AchievementCatalogTests`
Expected: FAIL — "cannot find 'AchievementCatalog' in scope".

- [ ] **Step 3: Scrivi il catalogo**

```swift
enum AchievementCatalog {
    static let all: [Achievement] = [
        // 🔥 Combo
        Achievement(id: "combo_5",  title: "Raffica",   detail: "5 gabbiani di fila senza farti colpire",  category: .combo, rarity: .comune, trigger: .streak(5),  gcID: nil, isSecret: false),
        Achievement(id: "combo_10", title: "Furia",     detail: "10 di fila senza farti colpire",           category: .combo, rarity: .raro,   trigger: .streak(10), gcID: nil, isSecret: false),
        Achievement(id: "combo_20", title: "Scatenato", detail: "20 di fila senza farti colpire",           category: .combo, rarity: .epico,  trigger: .streak(20), gcID: nil, isSecret: false),
        // 🎯 Punteggio
        Achievement(id: "score_25",  title: "Cacciatore",   detail: "25 gabbiani in una partita",  category: .punteggio, rarity: .comune, trigger: .scoreInGame(25),  gcID: nil,               isSecret: false),
        Achievement(id: "score_50",  title: "Cecchino",     detail: "50 gabbiani in una partita",  category: .punteggio, rarity: .raro,   trigger: .scoreInGame(50),  gcID: "badge_50uccisi",  isSecret: false),
        Achievement(id: "score_100", title: "Sterminatore", detail: "100 gabbiani in una partita", category: .punteggio, rarity: .epico,  trigger: .scoreInGame(100), gcID: "badge_100uccisi", isSecret: false),
        // ⏱️ Sopravvivenza
        Achievement(id: "time_60",  title: "Resistente", detail: "Sopravvivi 60 secondi",  category: .sopravvivenza, rarity: .comune, trigger: .survival(60),  gcID: nil, isSecret: false),
        Achievement(id: "time_120", title: "Maratoneta", detail: "Sopravvivi 120 secondi", category: .sopravvivenza, rarity: .raro,   trigger: .survival(120), gcID: nil, isSecret: false),
        // 📈 Carriera
        Achievement(id: "games_10",   title: "Habitué",      detail: "Gioca 10 partite",        category: .carriera, rarity: .comune, trigger: .gamesPlayed(10),  gcID: "badge_10partite",  isSecret: false),
        Achievement(id: "total_500",  title: "Collezionista", detail: "500 gabbiani in totale",  category: .carriera, rarity: .raro,   trigger: .totalKills(500),  gcID: nil,                isSecret: false),
        Achievement(id: "games_100",  title: "Veterano",     detail: "Gioca 100 partite",       category: .carriera, rarity: .epico,  trigger: .gamesPlayed(100), gcID: "badge_100partite", isSecret: false),
        Achievement(id: "total_1000", title: "Millennio",    detail: "1000 gabbiani in totale", category: .carriera, rarity: .epico,  trigger: .totalKills(1000), gcID: nil,                isSecret: false),
        // 🎉 Chicche
        Achievement(id: "first_game", title: "Battesimo",     detail: "Completa la prima partita",                       category: .chicche, rarity: .comune, trigger: .gamesPlayed(1),  gcID: nil,        isSecret: false),
        Achievement(id: "answer_42",  title: "Niente panico", detail: "Colpisci esattamente 42 gabbiani in una partita", category: .chicche, rarity: .raro,   trigger: .scoreExact(42),  gcID: "badge_42", isSecret: true),
        Achievement(id: "selfie_1",   title: "Star",          detail: "Scatta il tuo primo Woowoo Selfie",               category: .chicche, rarity: .comune, trigger: .selfie,          gcID: nil,        isSecret: false),
    ]

    static func with(id: String) -> Achievement? { all.first { $0.id == id } }
}
```

- [ ] **Step 4: Run test — deve passare**

Run: stesso comando dello Step 2.
Expected: PASS (5 test).

- [ ] **Step 5: Commit**

```bash
git add WooWoo/Sources/Achievements/AchievementCatalog.swift WooWoo/Tests/AchievementCatalogTests.swift
git commit -m "feat(achievements): catalogo dei 15 achievement + test integrità"
```

---

## Task 3: AchievementStore (persistenza)

**Files:**
- Create: `WooWoo/Sources/Achievements/AchievementStore.swift`
- Test: `WooWoo/Tests/AchievementStoreTests.swift`

- [ ] **Step 1: Scrivi i test (suite UserDefaults isolata, come ScoreStoreTests)**

```swift
import XCTest
@testable import WooWoo

final class AchievementStoreTests: XCTestCase {
    var defaults: UserDefaults!
    var store: AchievementStore!
    override func setUp() {
        defaults = UserDefaults(suiteName: #file + "ach")!
        defaults.removePersistentDomain(forName: #file + "ach")
        store = AchievementStore(defaults: defaults)
    }
    override func tearDown() {
        defaults.removePersistentDomain(forName: #file + "ach")
        super.tearDown()
    }
    func testStartsLocked() {
        XCTAssertFalse(store.isUnlocked("combo_5"))
    }
    func testUnlockReturnsTrueOnceThenFalse() {
        XCTAssertTrue(store.unlock("combo_5", at: 100))
        XCTAssertFalse(store.unlock("combo_5", at: 200))
        XCTAssertTrue(store.isUnlocked("combo_5"))
    }
    func testUnlockPersists() {
        store.unlock("combo_5", at: 100)
        let reread = AchievementStore(defaults: defaults)
        XCTAssertTrue(reread.isUnlocked("combo_5"))
    }
    func testUnlockDate() {
        store.unlock("combo_5", at: 1000)
        XCTAssertEqual(store.unlockDate("combo_5"), Date(timeIntervalSince1970: 1000))
        XCTAssertNil(store.unlockDate("combo_10"))
    }
}
```

- [ ] **Step 2: Run test — deve fallire**

Run: `xcodebuild test ... -only-testing:WooWooTests/AchievementStoreTests`
Expected: FAIL — "cannot find 'AchievementStore' in scope".

- [ ] **Step 3: Scrivi lo store**

```swift
import Foundation

/// Persistenza degli achievement sbloccati (id → timestamp). UserDefaults iniettabile per i test.
struct AchievementStore {
    private let defaults: UserDefaults
    private let key = "achievements_unlocked"
    init(defaults: UserDefaults = .standard) { self.defaults = defaults }

    private func map() -> [String: Double] {
        defaults.dictionary(forKey: key) as? [String: Double] ?? [:]
    }

    func isUnlocked(_ id: String) -> Bool { map()[id] != nil }

    /// Sblocca; ritorna true solo se era ancora bloccato (idempotente).
    @discardableResult
    func unlock(_ id: String, at time: Double) -> Bool {
        var m = map()
        guard m[id] == nil else { return false }
        m[id] = time
        defaults.set(m, forKey: key)
        return true
    }

    func unlockDate(_ id: String) -> Date? {
        map()[id].map { Date(timeIntervalSince1970: $0) }
    }
}
```

- [ ] **Step 4: Run test — deve passare**

Expected: PASS (4 test).

- [ ] **Step 5: Commit**

```bash
git add WooWoo/Sources/Achievements/AchievementStore.swift WooWoo/Tests/AchievementStoreTests.swift
git commit -m "feat(achievements): AchievementStore (UserDefaults) + test"
```

---

## Task 4: Protocollo GameCenterMirror

**Files:**
- Create: `WooWoo/Sources/Achievements/GameCenterMirror.swift`

- [ ] **Step 1: Scrivi protocollo + conformance**

`GameCenterService` ha già `func report(achievementIDs: [String])`. Astraiamo per poterlo
sostituire nei test.

```swift
/// Astrazione per il mirror Game Center (testabile). GameCenterService la implementa già.
@MainActor
protocol GameCenterMirror {
    func report(achievementIDs: [String])
}

extension GameCenterService: GameCenterMirror {}
```

- [ ] **Step 2: Build**

Expected: BUILD SUCCEEDED.

- [ ] **Step 3: Commit**

```bash
git add WooWoo/Sources/Achievements/GameCenterMirror.swift
git commit -m "feat(achievements): protocollo GameCenterMirror"
```

---

## Task 5: AchievementService (cervello)

**Files:**
- Create: `WooWoo/Sources/Achievements/AchievementService.swift`
- Test: `WooWoo/Tests/AchievementServiceTests.swift`

- [ ] **Step 1: Scrivi i test**

```swift
import XCTest
@testable import WooWoo

@MainActor
final class AchievementServiceTests: XCTestCase {
    final class SpyMirror: GameCenterMirror {
        var reported: [String] = []
        func report(achievementIDs: [String]) { reported += achievementIDs }
    }

    var defaults: UserDefaults!
    var spy: SpyMirror!
    var service: AchievementService!

    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: #file + "svc")!
        defaults.removePersistentDomain(forName: #file + "svc")
        spy = SpyMirror()
        service = AchievementService(store: AchievementStore(defaults: defaults),
                                     scoreStore: ScoreStore(defaults: defaults),
                                     gameCenter: spy)
    }
    override func tearDown() {
        defaults.removePersistentDomain(forName: #file + "svc")
        super.tearDown()
    }

    func testStreakUnlocksRaffica() {
        let new = service.onKill(score: 5, streak: 5)
        XCTAssertEqual(new.map(\.id), ["combo_5"])   // a score 5 nessun achievement di punteggio scatta
    }
    func testStreakAndScoreTogether() {
        // a 25 uccisioni con streak 25: Raffica(5), Furia(10), Scatenato(20), Cacciatore(25)
        let new = service.onKill(score: 25, streak: 25)
        XCTAssertEqual(Set(new.map(\.id)), ["combo_5", "combo_10", "combo_20", "score_25"])
    }
    func testIdempotent() {
        _ = service.onKill(score: 5, streak: 5)
        let again = service.onKill(score: 5, streak: 5)
        XCTAssertTrue(again.isEmpty)
    }
    func testScoreExact42Secret() {
        XCTAssertTrue(service.onKill(score: 41, streak: 1).isEmpty)
        let at42 = service.onKill(score: 42, streak: 1)
        XCTAssertTrue(at42.contains { $0.id == "answer_42" })
    }
    func testSurvival() {
        XCTAssertTrue(service.onTick(survival: 59).isEmpty)
        XCTAssertEqual(service.onTick(survival: 60).map(\.id), ["time_60"])
    }
    func testGameEndCareerUsesScoreStore() {
        let s = ScoreStore(defaults: defaults)
        for _ in 0..<10 { s.addGamePlayed(for: .figlia) }
        s.addTotalPoints(500, for: .figlia)
        let new = service.onGameEnd(mode: .figlia)
        XCTAssertEqual(Set(new.map(\.id)), ["first_game", "games_10", "total_500"])
    }
    func testSelfie() {
        XCTAssertEqual(service.onSelfie().map(\.id), ["selfie_1"])
        XCTAssertTrue(service.onSelfie().isEmpty)
    }
    func testMirrorReportsOnlyGCBacked() {
        _ = service.onKill(score: 50, streak: 1)   // score_50 ha gcID badge_50uccisi; score_25 no
        XCTAssertEqual(spy.reported, ["badge_50uccisi"])
    }
    func testProgressForCumulative() {
        let s = ScoreStore(defaults: defaults)
        s.addTotalPoints(320, for: .figlia)
        let coll = AchievementCatalog.with(id: "total_500")!
        XCTAssertEqual(service.progress(for: coll, mode: .figlia)?.current, 320)
        XCTAssertEqual(service.progress(for: coll, mode: .figlia)?.target, 500)
        let combo = AchievementCatalog.with(id: "combo_5")!
        XCTAssertNil(service.progress(for: combo, mode: .figlia))
    }
}
```

> Nota: in `testStreakUnlocksRaffica` la condizione attesa è semplicemente `["combo_5"]`
> (a score 5 nessun achievement di punteggio scatta). L'espressione contorta esiste solo per
> chiarire l'intento; sostituiscila pure con `XCTAssertEqual(new.map(\.id), ["combo_5"])`.

- [ ] **Step 2: Run test — deve fallire**

Run: `xcodebuild test ... -only-testing:WooWooTests/AchievementServiceTests`
Expected: FAIL — "cannot find 'AchievementService' in scope".

- [ ] **Step 3: Scrivi il service**

```swift
import Foundation

/// Valuta i trigger contro lo stato di gioco, sblocca (idempotente), fa mirror a Game Center,
/// e ritorna SOLO i nuovi sblocchi (per i toast). Local-first: funziona anche senza GC.
@MainActor
final class AchievementService {
    static let shared = AchievementService()

    private let store: AchievementStore
    private let scoreStore: ScoreStore
    private let gameCenter: GameCenterMirror

    init(store: AchievementStore = AchievementStore(),
         scoreStore: ScoreStore = ScoreStore(),
         gameCenter: GameCenterMirror = GameCenterService.shared) {
        self.store = store
        self.scoreStore = scoreStore
        self.gameCenter = gameCenter
    }

    func isUnlocked(_ id: String) -> Bool { store.isUnlocked(id) }

    // MARK: - Eventi

    /// Uccisione: valuta streak e punteggio-partita.
    func onKill(score: Int, streak: Int) -> [Achievement] {
        evaluate { trigger in
            switch trigger {
            case .streak(let n):      return streak >= n
            case .scoreInGame(let n): return score >= n
            case .scoreExact(let n):  return score == n
            default:                  return false
            }
        }
    }

    /// Tick del timer di gioco: valuta la sopravvivenza.
    func onTick(survival: TimeInterval) -> [Achievement] {
        evaluate { if case .survival(let n) = $0 { return survival >= n }; return false }
    }

    /// Fine partita: valuta carriera. CHIAMARE DOPO l'update di ScoreStore in GameOverScene.
    func onGameEnd(mode: GameMode) -> [Achievement] {
        let games = scoreStore.gamesPlayed(for: mode)
        let kills = scoreStore.totalPoints(for: mode)
        return evaluate { trigger in
            switch trigger {
            case .gamesPlayed(let n): return games >= n
            case .totalKills(let n):  return kills >= n
            default:                  return false
            }
        }
    }

    /// Selfie scattato.
    func onSelfie() -> [Achievement] {
        evaluate { if case .selfie = $0 { return true }; return false }
    }

    // MARK: - Galleria

    /// Progresso corrente/target per gli achievement cumulativi (per la galleria). nil per gli altri.
    func progress(for a: Achievement, mode: GameMode = .figlia) -> (current: Int, target: Int)? {
        switch a.trigger {
        case .gamesPlayed(let n): return (min(scoreStore.gamesPlayed(for: mode), n), n)
        case .totalKills(let n):  return (min(scoreStore.totalPoints(for: mode), n), n)
        default:                  return nil
        }
    }

    // MARK: - Core

    private func evaluate(_ matches: (AchievementTrigger) -> Bool) -> [Achievement] {
        var newly: [Achievement] = []
        let now = Date().timeIntervalSince1970
        for a in AchievementCatalog.all where !store.isUnlocked(a.id) && matches(a.trigger) {
            if store.unlock(a.id, at: now) {
                newly.append(a)
                if let gcID = a.gcID { gameCenter.report(achievementIDs: [gcID]) }
            }
        }
        return newly
    }
}
```

- [ ] **Step 4: Run test — deve passare**

Expected: PASS (tutti).

- [ ] **Step 5: Commit**

```bash
git add WooWoo/Sources/Achievements/AchievementService.swift WooWoo/Tests/AchievementServiceTests.swift
git commit -m "feat(achievements): AchievementService (valutazione + mirror) + test"
```

---

## Task 6: Ritira AchievementRules

**Files:**
- Delete: `WooWoo/Sources/Config/AchievementRules.swift`, `WooWoo/Tests/AchievementRulesTests.swift`
- Modify: `WooWoo/Sources/Scenes/GameOverScene.swift` (rimuovi la chiamata al vecchio sistema)

- [ ] **Step 1: Rimuovi il blocco GC vecchio in GameOverScene**

In `GameOverScene.didMove`, sostituisci il blocco achievement esistente:

```swift
        // Miglioramento voluto vs originale: l'originale (:103) inviava solo se
        // getLeaderBoardIdentifier era già impostato (dopo aver visitato Punteggi);
        // qui mode.leaderboardID è sempre valido, quindi inviamo sempre se autenticati.
        if GameCenterService.shared.isAuthenticated {              // :102-110
            GameCenterService.shared.submit(score: score, mode: mode)
            GameCenterService.shared.report(achievementIDs:
                AchievementRules.achievements(score: score, gamesPlayed: gamesPlayed))
        }
```

con (manteniamo l'invio del punteggio in classifica; gli achievement passano al nuovo sistema in Task 9):

```swift
        // Punteggio in classifica come prima. Gli achievement sono gestiti dal nuovo
        // AchievementService (vedi sotto, in questo stesso didMove).
        if GameCenterService.shared.isAuthenticated {
            GameCenterService.shared.submit(score: score, mode: mode)
        }
```

- [ ] **Step 2: Cancella i file del vecchio sistema**

```bash
git rm "WooWoo/Sources/Config/AchievementRules.swift" "WooWoo/Tests/AchievementRulesTests.swift"
```

- [ ] **Step 3: Rigenera e builda**

Run: `xcodegen generate --spec "WooWoo/project.yml"` poi build.
Expected: BUILD SUCCEEDED (nessun riferimento residuo ad `AchievementRules`).

- [ ] **Step 4: Commit**

```bash
git add -A
git commit -m "refactor(achievements): ritira AchievementRules (sostituito dal nuovo sistema)"
```

---

## Task 7: AchievementToastNode + presenter

**Files:**
- Create: `WooWoo/Sources/Nodes/AchievementToastNode.swift`
- Test: aggiungi un caso a `WooWoo/Tests/SmokeTests.swift`

- [ ] **Step 1: Scrivi il nodo + presenter**

```swift
import SpriteKit

extension AchievementRarity {
    /// Colore medaglia: bronzo / argento / oro.
    var medalColor: SKColor {
        switch self {
        case .comune: SKColor(red: 0.77, green: 0.48, blue: 0.24, alpha: 1)
        case .raro:   SKColor(red: 0.80, green: 0.82, blue: 0.86, alpha: 1)
        case .epico:  SKColor(red: 0.96, green: 0.77, blue: 0.26, alpha: 1)
        }
    }
    /// Epico → trattamento "medaglia" più grande/solenne.
    var isMedalStyle: Bool { self == .epico }
}

/// Toast singolo: cartello (comune/raro) o medaglia (epico). Si compone da btn_label + label.
@MainActor
final class AchievementToastNode: SKNode {
    init(_ a: Achievement) {
        super.init()
        let scale: CGFloat = a.rarity.isMedalStyle ? 1.15 : 1.0

        let plate = SKSpriteNode(imageNamed: "btn_label")
        plate.setScale(scale)
        addChild(plate)

        // medaglia (cerchio colorato per rarità) a sinistra
        let r: CGFloat = 14 * scale
        let medal = SKShapeNode(circleOfRadius: r)
        medal.fillColor = a.rarity.medalColor
        medal.strokeColor = .white
        medal.lineWidth = 2
        medal.position = CGPoint(x: -plate.size.width * 0.36, y: 0)
        addChild(medal)

        let title = SKLabelNode(fontNamed: GameConfig.fontNameBold)
        title.text = a.title
        title.fontSize = 18 * scale
        title.fontColor = SKColor(red: 0.71, green: 0.19, blue: 0.04, alpha: 1) // rosso "btn"
        title.verticalAlignmentMode = .center
        title.horizontalAlignmentMode = .center
        title.position = CGPoint(x: r * 0.4, y: 4 * scale)
        addChild(title)

        let detail = SKLabelNode(fontNamed: GameConfig.fontName)
        detail.text = a.isSecret ? "Segreto svelato!" : a.detail
        detail.fontSize = 9 * scale
        detail.fontColor = SKColor(red: 0.35, green: 0.23, blue: 0.0, alpha: 1)
        detail.verticalAlignmentMode = .center
        detail.horizontalAlignmentMode = .center
        detail.position = CGPoint(x: r * 0.4, y: -10 * scale)
        addChild(detail)

        alpha = 0
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) non supportato") }

    /// Slide-in dall'alto, hold ~2s, slide-out, rimozione. Chiama completion alla fine.
    func animate(to shownY: CGFloat, hiddenY: CGFloat, completion: @escaping () -> Void) {
        position.y = hiddenY
        let appear = SKAction.group([.fadeIn(withDuration: 0.25),
                                     .moveTo(y: shownY, duration: 0.25)])
        appear.timingMode = .easeOut
        let disappear = SKAction.group([.fadeOut(withDuration: 0.25),
                                        .moveTo(y: hiddenY, duration: 0.25)])
        run(.sequence([appear, .wait(forDuration: 2.0), disappear, .removeFromParent(),
                       .run(completion)]))
    }
}

/// Mostra i toast in coda (uno alla volta) sopra una scena.
@MainActor
final class AchievementToastPresenter {
    private weak var scene: SKScene?
    private var queue: [Achievement] = []
    private var showing = false
    init(scene: SKScene) { self.scene = scene }

    func enqueue(_ achievements: [Achievement]) {
        guard !achievements.isEmpty else { return }
        queue += achievements
        showNext()
    }

    private func showNext() {
        guard !showing, let scene, !queue.isEmpty else { return }
        showing = true
        let a = queue.removeFirst()
        let toast = AchievementToastNode(a)
        let shownY = scene.size.height - 36
        let hiddenY = scene.size.height + 30
        toast.position = CGPoint(x: scene.size.width / 2, y: hiddenY)
        toast.zPosition = 1000
        scene.addChild(toast)
        toast.animate(to: shownY, hiddenY: hiddenY) { [weak self] in
            self?.showing = false
            self?.showNext()
        }
    }
}
```

- [ ] **Step 2: Aggiungi uno smoke test (istanziazione)**

In `WooWoo/Tests/SmokeTests.swift`, dentro la classe, aggiungi:

```swift
    @MainActor
    func testAchievementToastNodeBuilds() {
        let a = AchievementCatalog.with(id: "combo_5")!
        let node = AchievementToastNode(a)
        XCTAssertFalse(node.children.isEmpty)   // plate + medal + 2 label
    }
```

- [ ] **Step 3: Rigenera, build, run del solo smoke test**

Run: `xcodegen generate --spec "WooWoo/project.yml"` poi
`xcodebuild test ... -only-testing:WooWooTests/SmokeTests/testAchievementToastNodeBuilds`
Expected: PASS.

- [ ] **Step 4: Commit**

```bash
git add WooWoo/Sources/Nodes/AchievementToastNode.swift WooWoo/Tests/SmokeTests.swift
git commit -m "feat(achievements): AchievementToastNode + presenter con coda"
```

---

## Task 8: Integra in GameScene (Figlia)

**Files:**
- Modify: `WooWoo/Sources/Scenes/GameScene.swift`

> Riferimenti: il "kill" è il ramo `colpi|fuoco` di `didBegin` (`punteggio += 1`); i "danni"
> sono i rami dove `colpiMostro += 1`. Il timer è in `startGameTimer`. Il game over in `gameOver()`.

- [ ] **Step 1: Aggiungi stato achievement (in cima alla classe, vicino agli altri `private var`)**

```swift
    private var streak = 0
    private var sessionUnlocks: [Achievement] = []
    private lazy var toasts = AchievementToastPresenter(scene: self)
```

- [ ] **Step 2: Incrementa streak + valuta sull'uccisione**

Nel `didBegin`, ramo `case PhysicsCategory.colpi | PhysicsCategory.fuoco:`, subito dopo
`AudioService.shared.playEffect("con_la_scopa.mp3")`, aggiungi:

```swift
                streak += 1
                let unlocked = AchievementService.shared.onKill(score: punteggio, streak: streak)
                if !unlocked.isEmpty { sessionUnlocks += unlocked; toasts.enqueue(unlocked) }
```

- [ ] **Step 3: Azzera streak quando subisci un colpo**

Sempre in `didBegin`, in OGNI ramo che fa `colpiMostro += 1` (i due rami:
`player|gabbiano`/`player|fuoco` e `mamma|gabbiano`), aggiungi subito dopo l'incremento:

```swift
            streak = 0
```

Risultato atteso del primo ramo:

```swift
        case PhysicsCategory.player | PhysicsCategory.gabbiano,    // :570-578
             PhysicsCategory.player | PhysicsCategory.fuoco:       // :625-634
            colpiMostro += 1
            streak = 0
            if colpiMostro <= GameConfig.maxColpi { player.colpita() }
            controllaVita()
        case PhysicsCategory.mamma | PhysicsCategory.gabbiano:     // :580-588
            mamma.soffre()
            colpiMostro += 1
            streak = 0
            if colpiMostro <= GameConfig.maxColpi { controllaVita() }
```

- [ ] **Step 4: Valuta la sopravvivenza nel timer**

In `startGameTimer`, dentro `MainActor.assumeIsolated`, dopo
`self.timeLabel.text = ScoreFormatter.time(self.time)`, aggiungi:

```swift
                let unlocked = AchievementService.shared.onTick(survival: self.time)
                if !unlocked.isEmpty { self.sessionUnlocks += unlocked; self.toasts.enqueue(unlocked) }
```

- [ ] **Step 5: Passa gli sblocchi a GameOverScene**

In `gameOver()`, sostituisci:

```swift
        go(to: GameOverScene(size: size, mode: .figlia, score: punteggio), .quick)   // :784-785
```

con:

```swift
        go(to: GameOverScene(size: size, mode: .figlia, score: punteggio,
                             inGameUnlocks: sessionUnlocks), .quick)   // :784-785
```

- [ ] **Step 6: Build (GameOverScene init aggiornato in Task 9; per ora atteso errore)**

Run: build.
Expected: FAIL — `GameOverScene` non ha ancora il parametro `inGameUnlocks`. Procedi al Task 9 e poi builda di nuovo. (Questa dipendenza è intenzionale: i due task si completano insieme.)

- [ ] **Step 7: Commit (dopo che il Task 9 fa compilare)**

> Esegui il commit alla fine del Task 9 insieme alle modifiche di GameOverScene.

---

## Task 9: GameOverScene — onGameEnd + recap

**Files:**
- Modify: `WooWoo/Sources/Scenes/GameOverScene.swift`

- [ ] **Step 1: Aggiungi il parametro `inGameUnlocks` all'init**

Sostituisci le proprietà e l'init:

```swift
    private let mode: GameMode
    private let score: Int
    private let scoreStore = ScoreStore()

    init(size: CGSize, mode: GameMode, score: Int) {
        self.mode = mode
        self.score = score
        super.init(size: size)
    }
```

con:

```swift
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
```

> Il default `= []` mantiene valido il call-site di `GameSceneMamma` (integrazione Mamma rimandata).

- [ ] **Step 2: Valuta carriera DOPO l'update di ScoreStore e raccogli il recap**

In `didMove`, il codice attuale aggiorna ScoreStore così:

```swift
        scoreStore.addGamePlayed(for: mode)
        scoreStore.addTotalPoints(score, for: mode)
        let gamesPlayed = scoreStore.gamesPlayed(for: mode)        // POST-incremento, come :243 letto dopo :78
        let isRecord = scoreStore.best(for: mode) < score          // :81
        if isRecord { scoreStore.setBest(score, for: mode) }
```

Dopo il Task 6 la variabile `gamesPlayed` non è più usata (la usava solo `AchievementRules`).
**Rimuovi quella riga** e, subito dopo il blocco, aggiungi la valutazione carriera e il merge:

```swift
        scoreStore.addGamePlayed(for: mode)
        scoreStore.addTotalPoints(score, for: mode)
        let isRecord = scoreStore.best(for: mode) < score          // :81
        if isRecord { scoreStore.setBest(score, for: mode) }

        // Achievement di carriera (ScoreStore è già aggiornato sopra) + quelli accumulati in partita.
        let careerUnlocks = AchievementService.shared.onGameEnd(mode: mode)
        let recap = inGameUnlocks + careerUnlocks
```

- [ ] **Step 3: Mostra il recap (sotto i bottoni esistenti)**

In fondo a `didMove`, dopo la chiamata esistente a `buildButtons()` e il blocco GC del submit,
aggiungi:

```swift
        buildRecap(recap)
```

e aggiungi il metodo:

```swift
    /// Lista compatta degli achievement sbloccati in questa partita (vuota → niente).
    private func buildRecap(_ achievements: [Achievement]) {
        guard !achievements.isEmpty else { return }
        let header = SKLabelNode(fontNamed: GameConfig.fontNameBold)
        header.text = achievements.count == 1 ? "Achievement sbloccato!" : "Achievement sbloccati!"
        header.fontSize = 16
        header.fontColor = .yellow
        header.verticalAlignmentMode = .center
        header.position = norm(0.30, 0.62)
        addChild(header)

        for (i, a) in achievements.prefix(4).enumerated() {
            let row = SKLabelNode(fontNamed: GameConfig.fontName)
            row.text = "• \(a.title)"
            row.fontSize = 13
            row.fontColor = a.rarity.medalColor
            row.verticalAlignmentMode = .center
            row.horizontalAlignmentMode = .center
            row.position = norm(0.30, 0.52 - CGFloat(i) * 0.08)
            addChild(row)
        }
    }
```

- [ ] **Step 4: Rigenera, build, run di tutti i test**

Run: `xcodegen generate --spec "WooWoo/project.yml"` poi build, poi
`xcodebuild test ... -scheme WooWoo -destination 'platform=iOS Simulator,name=iPhone 15'`.
Expected: BUILD SUCCEEDED, tutti i test PASS.

- [ ] **Step 5: Commit (insieme al Task 8)**

```bash
git add WooWoo/Sources/Scenes/GameScene.swift WooWoo/Sources/Scenes/GameOverScene.swift
git commit -m "feat(achievements): streak + toast in GameScene, recap in GameOverScene"
```

---

## Task 10: SelfieScene — hook onSelfie

**Files:**
- Modify: `WooWoo/Sources/Scenes/SelfieScene.swift`

- [ ] **Step 1: Aggiungi presenter + sblocco dopo uno scatto valido**

In `SelfieScene`, aggiungi la proprietà:

```swift
    private lazy var toasts = AchievementToastPresenter(scene: self)
```

In `takePhoto()`, dentro la closure di `CameraPicker.shared.pick`, dopo `self.showPhoto(image)`,
aggiungi:

```swift
            let unlocked = AchievementService.shared.onSelfie()
            self.toasts.enqueue(unlocked)
```

- [ ] **Step 2: Build**

Expected: BUILD SUCCEEDED.

- [ ] **Step 3: Commit**

```bash
git add WooWoo/Sources/Scenes/SelfieScene.swift
git commit -m "feat(achievements): sblocco Star al primo Woowoo Selfie"
```

---

## Task 11: AchievementsScene (galleria "Medaglie")

**Files:**
- Create: `WooWoo/Sources/Scenes/AchievementsScene.swift`
- Test: aggiungi un caso a `WooWoo/Tests/SmokeTests.swift`

- [ ] **Step 1: Scrivi la scena**

```swift
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
```

- [ ] **Step 2: Smoke test**

In `WooWoo/Tests/SmokeTests.swift` aggiungi:

```swift
    @MainActor
    func testAchievementsSceneBuilds() {
        let scene = AchievementsScene(size: CGSize(width: 694, height: 320))
        XCTAssertNotNil(scene)
    }
```

- [ ] **Step 3: Rigenera, build, run smoke test**

Run: `xcodegen generate --spec "WooWoo/project.yml"` poi
`xcodebuild test ... -only-testing:WooWooTests/SmokeTests/testAchievementsSceneBuilds`
Expected: PASS.

- [ ] **Step 4: Commit**

```bash
git add WooWoo/Sources/Scenes/AchievementsScene.swift WooWoo/Tests/SmokeTests.swift
git commit -m "feat(achievements): galleria Medaglie (AchievementsScene)"
```

---

## Task 12: Collega i bottoni "Medaglie" alla galleria

**Files:**
- Modify: `WooWoo/Sources/Scenes/IntroScene.swift`, `WooWoo/Sources/Scenes/PunteggiScene.swift`

- [ ] **Step 1: PunteggiScene — il bottone "Medaglie" apre la galleria**

In `PunteggiScene.buildLayout`, sostituisci l'azione del bottone Medaglie:

```swift
        medaglie.action = { [weak self] in
            guard let self else { return }
            GameCenterService.shared.showPanel(.achievements, mode: self.mode)
        }
```

con:

```swift
        medaglie.action = { [weak self] in
            guard let self else { return }
            self.go(to: AchievementsScene(size: self.size), .quick)
        }
```

- [ ] **Step 2: IntroScene — aggiungi un bottone "Medaglie" nel menu**

In `IntroScene.buildLayout`, dopo il bottone "Woowoo Selfie" (a `norm(0.70, 0.30)`), aggiungi
un bottone Medaglie nella colonna sinistra liberata dai bottoni Mamma:

```swift
        // Medaglie → AchievementsScene (galleria achievement)
        addButton(isIT ? "Medaglie" : "Achievements", at: norm(0.30, 0.45)) { [weak self] in
            guard let self else { return }
            self.go(to: AchievementsScene(size: self.size), .quick)
        }
```

- [ ] **Step 3: Build**

Expected: BUILD SUCCEEDED.

- [ ] **Step 4: Commit**

```bash
git add WooWoo/Sources/Scenes/IntroScene.swift WooWoo/Sources/Scenes/PunteggiScene.swift
git commit -m "feat(achievements): bottoni Medaglie aprono la galleria in-app"
```

---

## Task 13: Verifica finale

- [ ] **Step 1: Suite completa + build**

Run: `xcodegen generate --spec "WooWoo/project.yml"` poi
`xcodebuild test -project "WooWoo/WooWoo.xcodeproj" -scheme WooWoo -destination 'platform=iOS Simulator,name=iPhone 15'`
Expected: BUILD SUCCEEDED, tutti i test PASS.

- [ ] **Step 2: Verifica manuale sul simulatore/device** (checklist)

- [ ] Gioca in Figlia: colpisci 5 gabbiani di fila → compare il toast "Raffica".
- [ ] Fatti colpire, poi riparti: la streak riparte da 0 (nessun toast a 4+1).
- [ ] Raggiungi 25 in una partita → toast "Cacciatore".
- [ ] Sopravvivi 60s → toast "Resistente".
- [ ] A fine partita: recap con gli achievement della partita.
- [ ] Menu → "Medaglie": galleria con sbloccati colorati, bloccati grigi, "Niente panico" come "???", progresso sui cumulativi.
- [ ] Scatta un selfie → toast "Star".
- [ ] Se loggato a Game Center: "Cecchino"/"Sterminatore"/"42"/partite risultano anche su GC.

- [ ] **Step 3: Commit finale (se ci sono ritocchi visivi dopo la verifica)**

```bash
git add -A
git commit -m "fix(achievements): ritocchi dopo verifica manuale"
```

- [ ] **Step 4: Push + PR**

```bash
git push -u origin feat/achievements-system
```
Apri PR verso `main`: `https://github.com/AndreaiOS/woo-woo-the-game/compare/main...feat/achievements-system?expand=1`

---

## Note di self-review (copertura spec)

- ✅ Streak combo senza danni → Task 8 (streak++/=0) + trigger `.streak` (Task 5)
- ✅ Storage locale + mirror GC → Task 3 (store) + Task 5 (mirror, solo gcID)
- ✅ Toast in-game + recap → Task 7 (node) + Task 8 (in gioco) + Task 9 (recap)
- ✅ Stile cartello/medaglia + colori rarità → Task 7 (`medalColor`, `isMedalStyle`)
- ✅ Galleria con segreti/progresso → Task 11
- ✅ 15 achievement con condizioni precise → Task 2
- ✅ Ritiro AchievementRules → Task 6
- ✅ Bottone Medaglie → galleria → Task 12
- ⏸️ Mamma: integrazione rimandata (modalità nascosta) — default `inGameUnlocks: []` lascia il call-site valido
