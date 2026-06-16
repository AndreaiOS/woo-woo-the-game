# Checklist QA pre-submission — da eseguire su device reale

Esegui su **almeno 2 device** (uno piccolo es. SE/mini, uno grande es. Pro Max) e,
se possibile, **2 versioni iOS** (la minima supportata 17.x e l'ultima). Spunta tutto.

## 1. Avvio & navigazione
- [ ] L'app parte su IntroScene, **solo landscape**, senza freeze
- [ ] Ogni voce porta alla scena giusta: Start → Tutorial → Partita · Score Records → Punteggi · Woowoo Selfie
- [ ] Doppio tap rapido su un pulsante **non** apre due scene
- [ ] I pulsanti in basso (audio/suono/vibro/crediti) sono **centrati**, non sballati a destra
- [ ] Toggle audio/suono/vibro: lo stato persiste dopo riavvio app

## 2. Gameplay (modalità Figlia)
- [ ] Countdown 3-2-1, poi il gioco parte
- [ ] Inclinazione muove il personaggio; tap sx/dx mena la scopa col suono giusto
- [ ] I gabbiani compaiono, prendono fuoco e muoiono se colpiti; il punteggio sale
- [ ] La barra vita cala quando vieni colpito; a 9 colpi → Game Over
- [ ] Pausa: mette in pausa davvero; Resume riprende dal punto giusto; Exit torna al menu

## 3. Achievement (la feature nuova — testare a fondo)
- [ ] **5 gabbiani di fila senza farti colpire** → toast "Raffica" scende dall'alto (~2s), con icona 🔥
- [ ] Fatti colpire e riparti → la **streak riparte da 0** (nessun toast a 4+1)
- [ ] Raggiungi 25 in una partita → toast "Cacciatore"; 50 → "Cecchino"
- [ ] Sopravvivi 60s → "Resistente"
- [ ] Sblocchi multipli insieme → i toast si mettono **in coda** (non sovrapposti)
- [ ] Fine partita: **recap** con gli achievement della partita, **testo bianco leggibile** sul pannello scuro
- [ ] Menu medaglie (Score Records → Medaglie): griglia 15, contatore "X/15", **icone dentro le medaglie**, sbloccate colorate, bloccate grigie, "Niente panico" come **❓**, progresso "n/500" sui cumulativi, pannello scuro dietro
- [ ] Scatta un Woowoo Selfie → toast "Star"
- [ ] Chiudi e riapri l'app → achievement e punteggi **persistono**

## 4. Woowoo Selfie
- [ ] Permesso fotocamera: alla prima volta compare la richiesta; se **neghi**, appare l'alert di fallback (no crash)
- [ ] Scatto, scelta cornice, flip orizzontale, composizione corretta
- [ ] Condividi → share sheet; **"Salva immagine"** salva in galleria senza crash (verifica il permesso foto)

## 5. Game Center
- [ ] Al primo avvio (device loggato a GC) compare il banner di benvenuto
- [ ] I bottoni "Punteggi"/"Medaglie" (in Punteggi) aprono i pannelli senza bloccare il flusso
- [ ] Se NON loggato: compare l'alert "Accedi a Game Center", nessun crash
- [ ] Dopo una partita, il punteggio risulta inviato alla leaderboard (se GC + leaderboard configurate in ASC)

## 6. Ciclo di vita & interruzioni
- [ ] Durante una partita, manda l'app in **background** (home/app switcher) → si mette in pausa; al ritorno **non salta avanti**
- [ ] Durante una partita con musica, fai partire **timer/chiamata/Siri** → l'audio si abbassa/ferma e **riprende** correttamente
- [ ] Blocco schermo durante la partita → pausa corretta

## 7. Rendering / safe area
- [ ] Device con **notch in landscape**: i pulsanti ai bordi non finiscono sotto il notch
- [ ] Nessun taglio/banda nera; proporzioni corrette su device piccolo e grande
- [ ] Recap e galleria leggibili anche sul device più piccolo (no overlap)

## 8. Build di distribuzione
- [ ] Archive con firma **Distribution** (non solo dev) va a buon fine
- [ ] Upload su App Store Connect / TestFlight senza errori di entitlement
- [ ] Giro veloce su una build **TestFlight** reale (non solo Debug)

---
**Regola:** se qualcosa fallisce, annota device + iOS + passi esatti. Niente submission con un punto rosso aperto.
