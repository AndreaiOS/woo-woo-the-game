# Sistema Achievement — Design

**Data:** 2026-06-16
**Stato:** in revisione
**Modalità target:** Figlia (modalità attiva). Tracking generico → Mamma lo eredita se riattivata.

## Obiettivo

Aggiungere al gioco un sistema di achievement con **feedback visivo in-game coerente
con lo stile dell'app**, inclusa una categoria "combo / di fila". Sostituisce l'attuale
`AchievementRules` (badge 2014 riportati silenziosamente a Game Center, senza feedback).

## Decisioni di design (validate in brainstorming)

1. **Streak = combo senza danni.** Uccisioni consecutive senza subire colpi. Si azzera
   quando il giocatore subisce un colpo (`colpiMostro` aumenta).
2. **Storage locale + mirror Game Center.** Definizioni e progresso in-app (UserDefaults);
   gli achievement con un `gcID` vengono anche riportati a GC. Nuovi achievement NON
   richiedono configurazione su App Store Connect.
3. **Feedback in due momenti:** toast durante la partita + recap nella schermata Game Over.
4. **Stile:** banner "cartello" (`btn_label`) per Comune/Raro; **medaglia con nastro** per
   Epico. Medaglie colorate per rarità: bronzo (Comune) · argento (Raro) · oro (Epico).
5. **Galleria in-app "Medaglie"** (nuova scena) raggiunta dal menu, con sbloccati/bloccati,
   barra di progresso sui cumulativi, e **segreti** mostrati come ❓.

## Lista achievement (15)

Rarità → stile feedback: Comune/Raro = cartello, Epico = medaglia.
Condizioni espresse su dati che il gioco già traccia + il nuovo contatore `streak`.

| id | Nome | Categoria | Condizione (precisa) | Rarità | gcID (mirror) | Segreto |
|---|---|---|---|---|---|---|
| `combo_5` | Raffica | Combo | `streak` raggiunge 5 | Comune | — | no |
| `combo_10` | Furia | Combo | `streak` raggiunge 10 | Raro | — | no |
| `combo_20` | Scatenato | Combo | `streak` raggiunge 20 | Epico | — | no |
| `score_25` | Cacciatore | Punteggio | `punteggio` raggiunge 25 in una partita | Comune | — | no |
| `score_50` | Cecchino | Punteggio | `punteggio` raggiunge 50 | Raro | `badge_50uccisi` | no |
| `score_100` | Sterminatore | Punteggio | `punteggio` raggiunge 100 | Epico | `badge_100uccisi` | no |
| `time_60` | Resistente | Sopravvivenza | `time` ≥ 60 s in una partita | Comune | — | no |
| `time_120` | Maratoneta | Sopravvivenza | `time` ≥ 120 s | Raro | — | no |
| `games_10` | Habitué | Carriera | partite giocate ≥ 10 | Comune | `badge_10partite` | no |
| `total_500` | Collezionista | Carriera | gabbiani totali ≥ 500 | Raro | — | no |
| `games_100` | Veterano | Carriera | partite giocate ≥ 100 | Epico | `badge_100partite` | no |
| `total_1000` | Millennio | Carriera | gabbiani totali ≥ 1000 | Epico | — | no |
| `first_game` | Battesimo | Chicche | completa la 1ª partita (partite ≥ 1) | Comune | — | no |
| `answer_42` | Niente panico | Chicche | `punteggio` raggiunge esattamente 42 in una partita | Raro | `badge_42` | **sì** |
| `selfie_1` | Star | Chicche | scatta il 1º Woowoo Selfie | Comune | — | no |

**Sorgenti dati:**
- `punteggio` (uccisioni partita), `colpiMostro` (danni), `time` (secondi) → stato runtime delle scene di gioco.
- partite giocate, gabbiani totali → `ScoreStore` (`gamesPlayed`, `totalPoints`).
- `streak` → **nuovo** contatore runtime (vedi sotto).
- selfie → sblocco diretto da `SelfieScene`.

**Badge 2014 ritirati** (non ripotrati): `badge_numeriprimi`, `badge_0uccisi`, `badge_1partita`
(irraggiungibile/strani). `AchievementRules.swift` viene rimosso.

## Architettura

Unità piccole e isolate, in un nuovo gruppo `WooWoo/Sources/Achievements/`.

### Modello e catalogo
```
enum AchievementCategory { case combo, punteggio, sopravvivenza, carriera, chicche }
enum AchievementRarity   { case comune, raro, epico }   // → colore medaglia + stile toast

enum AchievementTrigger {
    case streak(Int)            // streak >= n
    case scoreInGame(Int)       // punteggio >= n
    case scoreExact(Int)        // punteggio == n (Niente panico)
    case survival(TimeInterval) // time >= n
    case gamesPlayed(Int)       // ScoreStore.gamesPlayed >= n
    case totalKills(Int)        // ScoreStore.totalPoints >= n
    case selfie
}

struct Achievement: Identifiable {
    let id: String
    let title: String
    let detail: String
    let category: AchievementCategory
    let rarity: AchievementRarity
    let trigger: AchievementTrigger
    let gcID: String?           // mirror Game Center se presente
    let isSecret: Bool
}

enum AchievementCatalog { static let all: [Achievement] = [ ... 15 voci ... ] }
```

### Persistenza — `AchievementStore`
- UserDefaults. Un solo set persistente: **id sbloccati** (con data).
  - Chiave: `ach_unlocked` → `[String: Double]` (id → timestamp), oppure chiavi `ach_<id>`.
- Nessuno stato extra: il progresso dei cumulativi (Collezionista/Millennio/…) si calcola
  live da `ScoreStore`. "Star sbloccato" ⇒ selfie fatto (nessun flag separato).
- Inietta `UserDefaults` (come `ScoreStore`) per i test con suite isolata.

### Logica — `AchievementService`
Il cervello. Valuta i trigger, filtra i già-sbloccati, persiste, fa mirror a GC, ritorna i **nuovi** sblocchi.
```
@MainActor final class AchievementService {
    static let shared = AchievementService()

    // Ritornano SOLO i nuovi sblocchi (idempotente):
    func onKill(score: Int, streak: Int) -> [Achievement]   // combo_*, score_* (incl. answer_42)
    func onTick(survival: TimeInterval) -> [Achievement]    // time_*
    func onGameEnd(mode: GameMode) -> [Achievement]         // games_*, total_*, first_game (legge ScoreStore)
    func onSelfie() -> [Achievement]                        // selfie_1

    func isUnlocked(_ id: String) -> Bool
    func progress(for: Achievement) -> (current: Int, target: Int)?  // per la galleria (cumulativi)
}
```
- Sblocco: registra in `Store`, e se `gcID != nil` chiama `GameCenterService.report(achievementIDs:)`
  (che già degrada con grazia se non autenticati).
- Funziona **anche senza Game Center**: il sistema è local-first.

### Feedback in-game — `AchievementToastNode`
- `SKNode` overlay aggiunto alla scena, sopra il gameplay.
- Comune/Raro → **cartello** (sfondo tipo `btn_label`, titolo Moon Flower Bold rosso, medaglia a sx).
  Epico → **medaglia + nastro** centrale.
- Animazione: slide-in dall'alto → hold ~2 s → slide-out (SKAction).
- **Coda**: se scattano più sblocchi insieme, vengono mostrati in sequenza (un presenter
  leggero per-scena gestisce la coda; non si sovrappongono).

### Recap fine partita — `GameOverScene`
- Mostra la lista degli achievement sbloccati **in quella partita** (Epico con stile medaglia).
- Riceve gli sblocchi accumulati dalla scena di gioco (più quelli di `onGameEnd`).

### Galleria — `AchievementsScene` (nuova)
- Stile scoreboard (sfondo scuro multiply, titolo giallo Moon Flower Bold).
- Griglia per categoria: medaglia colorata per rarità se sbloccata, grigia + 🔒 se no.
- Barra di progresso sui cumulativi (`progress(for:)`).
- Segreti (`isSecret && !unlocked`) mostrati come ❓ con condizione nascosta.
- Bottone chiudi → torna al menu/scena chiamante.

## Punti di innesto nelle scene esistenti

- **GameScene / GameSceneMamma:**
  - Nuovo `private var streak = 0`. `streak += 1` a ogni uccisione; `streak = 0` quando
    `colpiMostro` aumenta (colpo subito).
  - Su uccisione → `onKill(score:streak:)`; su tick timer → `onTick(survival:)`. Gli
    sblocchi tornati → toast in-game + **accumulati** in un array `[Achievement]`.
  - In `gameOver()`: l'array accumulato viene passato a `GameOverScene` (nuovo parametro init,
    es. `inGameUnlocks:`). NB: gli achievement di **carriera** NON si valutano qui, perché
    dipendono da `ScoreStore` che è ancora pre-incremento.
- **GameOverScene:**
  - In `didMove`, **dopo** `addGamePlayed`/`addTotalPoints` (che aggiornano `ScoreStore`),
    chiama `onGameEnd(mode:)` → sblocchi di carriera (`games_*`, `total_*`, `first_game`).
  - Recap mostrato = `inGameUnlocks` (passati dalla scena) **∪** sblocchi di `onGameEnd`.
- **SelfieScene:** dopo uno scatto valido → `onSelfie()` (toast se nuovo).
- **IntroScene / PunteggiScene:** il bottone **"Medaglie"** apre `AchievementsScene`
  (invece di `GameCenterService.showPanel(.achievements)`).
- **Rimozione:** `AchievementRules.swift` e la sua chiamata in `GameOverScene` (logica
  migrata nel `Catalog` + mirror).

## Mirror Game Center

Solo gli achievement con `gcID` vengono riportati (`badge_50uccisi`, `badge_100uccisi`,
`badge_42`, `badge_10partite`, `badge_100partite`). Gli altri sono local-only finché (e se)
verranno creati i corrispettivi su App Store Connect — in tal caso basta aggiungere il `gcID`
nel catalogo. (Vedi `docs/app-store-setup.md`.)

## Casi limite / errori

- **Idempotenza:** un achievement già sbloccato non ri-scatta (niente toast doppi).
- **Streak reset:** azzerato a ogni colpo subito, anche se la partita continua.
- **Sblocchi multipli simultanei:** coda toast sequenziale.
- **`answer_42`:** scatta quando `punteggio` tocca 42 (transito), non "esattamente 42 a fine partita".
- **GC non autenticato / offline:** sblocco locale avviene comunque; il mirror è best-effort.
- **Mamma nascosta:** gli achievement valgono in Figlia; il tracking è generico ma Mamma
  non è raggiungibile dal menu → nessun impatto pratico ora.

## Test

- **`AchievementService`** (unit, suite UserDefaults isolata come `ScoreStoreTests`):
  ogni soglia di trigger, idempotenza, reset streak, sblocco esatto (42), cumulativi via `ScoreStore`.
- **`AchievementCatalog`**: id univoci; `gcID` solo su voci previste; coerenza rarità/categoria.
- **Smoke**: `AchievementToastNode` e `AchievementsScene` si istanziano/buildano.

## Fuori scope (YAGNI)

- Sync cloud oltre il mirror GC.
- Punti/score achievement, condivisione social dedicata, notifiche locali.
- Achievement specifici della modalità Mamma (bonus/cura) — eventualmente in futuro.
