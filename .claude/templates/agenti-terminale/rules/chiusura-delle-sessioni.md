# Chiusura delle sessioni degli agenti da terminale

> Regola modulare del pacchetto `agenti-terminale`. Si carica sempre dove esiste piu' di una radice di agente. Riguarda cio' che resta sul disco quando una sessione finisce, ed e' il completamento del wipe: il wipe copre l'incuria, questa regola copre la volonta'.

## Il principio

> **Una sessione che si considera chiusa per davvero va rimossa, non abbandonata.**

Abbandonarla non la fa sparire: la lascia in un magazzino che il wipe **preserva apposta**, perche' appartiene a un progetto vivo. E' il comportamento corretto del wipe, non un suo difetto: senza quella preservazione non si potrebbe riprendere il lavoro del giorno prima.

Ne discende la distinzione che va fatta ogni volta, e che nessuno strumento puo' fare al posto di chi lavora:

| Intenzione | Azione | Cosa resta |
|---|---|---|
| **Riprendero' questa conversazione** | si esce e basta | tutto, ed e' quello che si vuole |
| **Ho finito con questa conversazione** | si **rimuove** la sessione | niente |

Nessun automatismo distingue i due casi, perche' la differenza sta nell'intenzione di chi ha lavorato, non in un dato osservabile. Un wipe che decidesse da se' cancellerebbe lavoro che serviva ancora; uno che non cancella mai accumula per sempre.

## Le due attuazioni

Sono diverse perche' i due agenti offrono meccanismi diversi, e la differenza va conosciuta per non dare per scontato che l'altro faccia lo stesso.

**Codex ha un comando nativo.** Dentro la sessione:

```text
/delete
```

Cancella quella sessione ed esce. E' la via corretta e non richiede altro.

**Claude Code non ha un equivalente.** Non esiste un comando per cancellare la sessione corrente, e il wipe di fine sessione **preserva** i progetti che si e' scelto di preservare. Una conversazione chiusa per davvero su un progetto preservato **resta** finche' non la si toglie a mano dal magazzino dell'account.

## Perche' la regola esiste, invece di lasciar fare al wipe

Il wipe risponde alla domanda *"che cosa e' rimasto indietro?"*. Questa regola risponde a *"che cosa ho deciso che non serve piu'?"*, e sono domande diverse con risposte diverse.

Il caso che le distingue si e' presentato davvero: una sessione chiusa per errore e' stata **recuperata** il giorno dopo proprio perche' il wipe l'aveva preservata, e in quel momento la preservazione era esattamente cio' che serviva. La stessa preservazione, su una sessione che non serviva piu', sarebbe stata accumulo.

## Che cosa questa regola non risolve

**Non rende una sessione irrecuperabile lato server.** Cio' che e' stato inviato al modello vive secondo la politica di conservazione dell'area di lavoro, che e' una configurazione lato fornitore e non si tocca da qui. Cancellare la sessione locale e credere di aver cancellato la conversazione e' l'errore da non fare.

**Non sostituisce il wipe.** Copre solo cio' che si e' deciso di chiudere; tutto il resto, comprese le sessioni interrotte, i log e gli store effimeri, resta materia del wipe.
