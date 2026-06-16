# App Privacy ("nutrition labels") — risposte per App Store Connect

Compilazione della sezione **App Privacy** in ASC. Basata su cosa l'app fa davvero
(verificato nel codice). **Esito: "Data Not Collected".**

## Risposta principale
Alla domanda *"Do you or your third-party partners collect data from this app?"*
→ **No, we do not collect data from this app.**

### Perché (motivazione, verificata nel codice)
- **Nessun SDK di pubblicità o analytics.** AdMob/Analytics dell'originale sono stati
  rimossi (vedi commento in `GameOverScene.swift`). Nessun network call verso server propri.
- **Punteggi e progressi**: salvati **solo localmente** in `UserDefaults`
  (`ScoreStore`, `AchievementStore`). Non lasciano il dispositivo.
- **Fotocamera / Woowoo Selfie**: la foto è elaborata **on-device** e condivisa solo
  se l'utente tocca "Condividi" (share sheet di sistema). Non viene inviata a server tuoi
  né conservata da te → non è "raccolta" ai sensi delle linee guida Apple.
- **Game Center**: gestito interamente da **Apple**. L'app non memorizza né trasmette
  identificativi del giocatore per conto proprio.

## Avvertenze / da verificare
- ⚠️ **Game Center**: se in futuro aggiungi un backend che associa dati al giocatore,
  questa risposta cambia. Oggi, con solo Game Center "puro", "Data Not Collected" è corretto.
- ⚠️ Se aggiungerai analytics, crash reporting di terze parti o ads, **aggiorna** questa
  dichiarazione PRIMA della submission.

## Permessi (Info.plist) — già presenti, niente da fare
| Chiave | Testo mostrato | Quando |
|---|---|---|
| `NSCameraUsageDescription` | "Serve la fotocamera per scattare il tuo Woowoo Selfie…" | apertura camera nel Selfie |
| `NSPhotoLibraryAddUsageDescription` | "Per salvare il tuo Woowoo Selfie nella galleria foto." | "Salva immagine" dallo share sheet |

> Questi permessi NON implicano "raccolta dati": chiedono accesso a fotocamera/galleria
> per funzioni on-device richieste dall'utente.
