# Woo Woo The Game — Pre-submission (release v2.0.0)

Gioco **nuovo** sull'App Store. Bundle `com.woowoothegame`. Solo landscape, iOS 17+.
Questo è l'indice: stato di cosa serve per pubblicare.

## ✅ Fatto (lato codice)
- Porting SpriteKit completo; sistema achievement (15 medaglie, toast, recap, galleria)
- Entitlement Game Center + permessi camera/galleria in `Info.plist`
- Niente ads/analytics; punteggi/achievement solo locali
- Build verde, 36 test verdi

## ⏳ Da fare prima della submission (in gran parte su App Store Connect / lato tuo)

| # | Cosa | Dove | Doc |
|---|------|------|-----|
| 1 | Creare il record app per `com.woowoothegame` | App Store Connect | — |
| 2 | Abilitare Game Center: leaderboard + 5 achievement con `gcID` | App Store Connect | [app-store-setup.md](app-store-setup.md) |
| 3 | Compilare App Privacy ("Data Not Collected") | App Store Connect | [privacy-labels.md](privacy-labels.md) |
| 4 | Incollare nome/descrizione/keyword/novità (it+en) | App Store Connect | [store-listing.md](store-listing.md) |
| 5 | App icon completa + screenshot (landscape) | App Store Connect | — |
| 6 | URL supporto + privacy policy | App Store Connect | — |
| 7 | Classificazione età (questionario) | App Store Connect | [store-listing.md](store-listing.md) |
| 8 | QA completo su device reali + TestFlight | device | [qa-checklist.md](qa-checklist.md) |
| 9 | Archive firmato **Distribution** + upload | Xcode | — |

## Note
- Gli achievement **locali** (10 su 15) NON vanno configurati su ASC: vivono in-app.
  Solo i 5 con `gcID` e le leaderboard richiedono setup GC (vedi #2).
- Privacy labels: l'esito è "Data Not Collected" **finché** non si aggiungono
  analytics/ads/backend. Se cambia, aggiornare prima della submission.
- Materiali che restano **solo tuoi** (non generabili da codice): app icon definitiva,
  screenshot reali, URL di supporto/privacy, account/provisioning di distribuzione.
