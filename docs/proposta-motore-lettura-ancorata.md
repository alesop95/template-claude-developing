# Proposta: un motore di lettura ancorata come pacchetto, due vault separati

**Stato.** Decisione del proprietario arrivata il 9 novembre 2026 da un canale fuori dal template, registrata nel giro in cui è arrivata secondo la regola `.claude/rules/chat-non-e-memoria.md`. Non implementata, non attiva e fuori dal catalogo dei pacchetti. La specifica del motore idempotente è annunciata in arrivo dal progetto aziendale che lo sta sviluppando: questo documento registra la sostanza della decisione, non il suo progetto tecnico, e va completato quando la specifica arriva.

## La decisione

Il motore di lettura ancorata, cioè la pipeline che estrae da un documento le porzioni e le cita con un riferimento verificabile, diventa un pacchetto del template, installato nei tre progetti che oggi ne hanno una copia propria, allineato dal canale ufficiale e idempotente, cioè rilanciabile senza rifare il lavoro già fatto e senza duplicare ciò che ha già scritto.

I vault restano due e separati, uno privato e uno aziendale, e questo è il punto che la decisione risolve esplicitamente: non si costruisce un secondo motore e non si mescolano i dati dei due vault. La formulazione precedente, secondo cui il vault lo avrebbe gestito il progetto che lo ospita, è dichiarata sbagliata dal proprietario nello stesso messaggio. Un motore, due vault.

## I tre progetti e che cosa porta ciascuno

Il progetto privato dove la lettura ancorata è nata la ha già collaudata, ed è quindi la base di partenza del pacchetto. Il progetto aziendale che la usa su documenti di lavoro vi ha aggiunto due miglioramenti che il template conosce già come lezioni salite da lì: il vincolo a elenco chiuso sul campo con cui il modello cita la propria fonte, che elimina per costruzione i riferimenti inesistenti, e il taglio dell'unità di citazione sui confini del senso invece che a lunghezza fissa, che è la prescrizione nata dalla misura del 58,9 per cento di riferimenti confinanti. Il terzo progetto, privato, aggiunge il lato vault, cioè grafo e collegamenti fra le note.

Ne segue il perimetro minimo del pacchetto: il motore con i due miglioramenti già misurati, l'idempotenza, e l'installazione nei tre progetti con i loro vault distinti. Resta da decidere, quando arriva la specifica, dove finisca il confine fra il motore e il vault, perché è quel confine a tenere separati i dati.

## Che cosa manca prima del catalogo

Mancano la specifica dell'idempotenza, cioè su quale chiave il motore riconosce il lavoro già fatto; la prova che il rilancio non duplichi e non riscriva; e la misura di che cosa resti davvero comune ai tre progetti, perché un pacchetto che astrae troppo presto diventa tre rami di codice con un nome solo. Le quattro domande per entrare nel catalogo stanno in `docs/FILONI.md`.
