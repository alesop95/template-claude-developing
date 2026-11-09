# Proposta: un motore di lettura ancorata come pacchetto, due vault separati

**Stato.** Decisione del proprietario arrivata il 9 novembre 2026 da un canale fuori dal template, registrata nel giro in cui è arrivata secondo la regola `.claude/rules/chat-non-e-memoria.md`. Non implementata, non attiva e fuori dal catalogo dei pacchetti. La specifica del motore idempotente è annunciata in arrivo dal progetto aziendale che lo sta sviluppando: questo documento registra la sostanza della decisione, non il suo progetto tecnico, e va completato quando la specifica arriva.

## La decisione

Il motore di lettura ancorata, cioè la pipeline che estrae da un documento le porzioni e le cita con un riferimento verificabile, diventa un pacchetto del template, installato nei tre progetti che oggi ne hanno una copia propria, allineato dal canale ufficiale e idempotente, cioè rilanciabile senza rifare il lavoro già fatto e senza duplicare ciò che ha già scritto.

I vault restano due e separati, uno privato e uno aziendale, e questo è il punto che la decisione risolve esplicitamente: non si costruisce un secondo motore e non si mescolano i dati dei due vault. La formulazione precedente, secondo cui il vault lo avrebbe gestito il progetto che lo ospita, è dichiarata sbagliata dal proprietario nello stesso messaggio. Un motore, due vault.

## I tre progetti e che cosa porta ciascuno

Il progetto privato dove la lettura ancorata è nata la ha già collaudata, ed è quindi la base di partenza del pacchetto. Il progetto aziendale che la usa su documenti di lavoro vi ha aggiunto due miglioramenti che il template conosce già come lezioni salite da lì: il vincolo a elenco chiuso sul campo con cui il modello cita la propria fonte, che elimina per costruzione i riferimenti inesistenti, e il taglio dell'unità di citazione sui confini del senso invece che a lunghezza fissa, che è la prescrizione nata dalla misura del 58,9 per cento di riferimenti confinanti. Il terzo progetto, privato, aggiunge il lato vault, cioè grafo e collegamenti fra le note.

Ne segue il perimetro minimo del pacchetto: il motore con i due miglioramenti già misurati, l'idempotenza, e l'installazione nei tre progetti con i loro vault distinti. Resta da decidere, quando arriva la specifica, dove finisca il confine fra il motore e il vault, perché è quel confine a tenere separati i dati.

## La specifica dell'idempotenza, consegnata il 2026-11-09

Il progetto aziendale ha consegnato la specifica che il filone aspettava da lui, nel proprio documento `idempotenza-del-motore-di-lettura` sotto la sua cartella `docs`, e l'attesa nel registro è chiusa. Quello che segue è ciò che la specifica stabilisce, riportato qui perché il filone possa essere valutato senza aprire il repository di quel progetto; le misure restano nel documento d'origine.

Idempotente vi è enunciato come una misura e non come un'intenzione, in tre clausole: rilanciare il motore su un ingresso immutato non deve scrivere niente, nemmeno riscrivere lo stesso valore, e la verifica è che il numero di righe resti identico e nessuna data di aggiornamento cambi; rilanciarlo dopo che un solo documento è cambiato deve toccare le sole righe di quel documento, contate; rilanciarlo dopo che un parametro di lettura è cambiato deve produrre un risultato nuovo accanto a quello vecchio e non al suo posto, perché il vecchio è costato ore di calcolo e senza di esso nessun confronto prima e dopo è più possibile.

La chiave non è una sola ma una per stadio, e la chiave di uno stadio comprende quella del precedente, altrimenti un cambiamento a monte non si propaga: impronta del file di origine per la conversione; terna di impronta del documento convertito, versione dell'algoritmo di spezzatura e misura della porzione per la spezzatura; quintupla di identificatore della porzione, modello, impronta delle istruzioni, impronta dello schema e modo di taglio delle ancore per la lettura; nessuna chiave propria per l'indice a testo pieno, che non è una produzione ma uno specchio e si verifica contando una riga per ogni porzione viva.

La specifica dichiara anche i quattro punti in cui il motore di oggi non rispetta il contratto, nessuno dei quali produce un errore e tutti un risultato plausibile e sbagliato, e la decisione di disegno che ne discende: una porzione non si aggiorna mai sul posto, un documento la cui impronta è cambiata produce porzioni nuove e le vecchie si marcano superate, così che le schede già prodotte restino valide per ciò che erano e nessun lavoro di calcolo si perda.

Sul confine fra il motore e il vault, che questo documento lasciava aperto, la risposta è ricavata da una misura e non da un'opinione: il motore finisce alla scheda, cioè il suo ultimo atto è depositare una scheda strutturata con l'evidenza risolta e i parametri registrati, mentre tutto ciò che trasforma le schede in note, collegamenti e grafo è il vault, sta fuori dal pacchetto e vive nel progetto che lo ospita. È anche il punto in cui la separazione dei dati si tiene da sé, perché il pacchetto non sa dove scrive il vault.

Il perimetro del pacchetto è quindi misurato e non supposto: quindici concetti in comune fra le due implementazioni, dalla configurazione alla validazione della scheda. Restano fuori l'acquisizione dei formati, che appartiene al progetto perché quali formati entrino è una scelta di dominio, e la produzione delle note, che appartiene al vault; i due miglioramenti al nucleo, cioè il vincolo a elenco chiuso e il taglio sui confini di senso, appartengono invece al pacchetto perché migliorano la lettura di chiunque.

## Che cosa manca prima del catalogo

Delle quattro domande per entrare nel catalogo, che stanno in `docs/FILONI.md`, la specifica consegnata risponde alle prime due, cioè che cosa fa lo strumento e a chi serve, e fissa le quattro prove che il pacchetto deve superare: corsa a vuoto che non scrive, documento cambiato che tocca le sole righe sue, parametro cambiato che produce due schede entrambe raggiungibili, sparizione a monte che marca superate le porzioni e conserva le schede. Restano la terza e la quarta domanda. Il costo va dichiarato per intero, dipendenze comprese, insieme ai caratteri che il pacchetto aggiungerebbe al carico di avvio di una sessione e al fatto che il modello gira in locale e nessun dato esce dalla macchina. E va scritto come si toglie, che per un pacchetto con una banca dati propria non è la cancellazione di qualche file.
