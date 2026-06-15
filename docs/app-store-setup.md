# App Store Connect — setup pre-lancio

Gioco **nuovo** (non update). Bundle ID: `com.woowoothegame`. Versione `2.0.0` (build 1).

## 1. Game Center

Abilita **Game Center** nella scheda dell'app in App Store Connect, poi crea gli oggetti
sotto con questi ID **esatti** (il codice li referenzia hardcoded — devono combaciare).

### Leaderboard
| ID (Leaderboard ID) | Quando | Note |
|---|---|---|
| `Woo_Woo_Leaderboard` | modalità Figlia (l'unica esposta) | **obbligatoria** |
| `Woo_Woo_Leaderboard_Mamma` | modalità Mamma | **opzionale** — Mamma è nascosta dal menu, non viene mai inviata in pratica. Crearla solo se riattivi la modalità. |

- Tipo punteggio: **intero**, "Higher is Better" (numero di gabbiani colpiti).
- Codice: `WooWoo/Sources/Config/GameMode.swift`, invio in `GameCenterService.submit(...)`.

### Achievement (8 ID)
Definiti in `WooWoo/Sources/Config/AchievementRules.swift`. Crea questi identifier:

| Achievement ID | Sblocco |
|---|---|
| `badge_numeriprimi` | punteggio "primo" (vedi `isPrimeLikeOriginal`) |
| `badge_0uccisi` | punteggio == 0 |
| `badge_42` | punteggio == 42 |
| `badge_50uccisi` | punteggio >= 50 |
| `badge_100uccisi` | punteggio >= 100 |
| `badge_10partite` | 10ª partita giocata |
| `badge_100partite` | 100ª partita giocata |
| `badge_1partita` | ⚠️ **mai sbloccabile** (bug originale 2014 portato fedelmente). Crearlo per completezza o ometterlo — non si attiverà mai. |

> Nota logica: un achievement "di livello" (partite) viene inviato **solo** insieme a uno
> "di punteggio". Tutti vengono riportati a 100% al raggiungimento.

## 2. Privacy (App Privacy / "nutrition labels")

- Gli SDK di **ads e analytics sono stati rimossi** nel port (vedi commento in `GameOverScene.swift`).
- Punteggi salvati **solo localmente** (UserDefaults), niente server.
- **Fotocamera/Selfie**: la foto è elaborata on-device e condivisa solo tramite share sheet
  avviato dall'utente → non "raccolta" da te.
- **Game Center**: gestito da Apple (player ID).

➡️ Configurazione consigliata: **"Data Not Collected"** per i dati raccolti da te.
   Verifica solo se aggiungerai analytics/ads in futuro.

### Permessi (Info.plist) — già presenti
- `NSCameraUsageDescription` — scatto selfie.
- `NSPhotoLibraryAddUsageDescription` — aggiunto: il share sheet del selfie ha "Salva immagine";
  senza questa chiave l'app **crasha** al salvataggio.

## 3. Materiali store (da preparare)
App icon completa, screenshot (landscape), descrizione, classificazione età, testo novità,
URL supporto/privacy policy.
