# Perimetro d'uso di REA

> Riferimento del pacchetto `rea`, da leggere prima di installare e prima di aprire qualunque bersaglio. Non è un disclaimer di cortesia: è la parte del pacchetto che decide se l'uso è legittimo, e a differenza di ogni altro pacchetto del catalogo la risposta non dipende da come è configurato il progetto ma da chi possiede la cosa che si sta guardando.

## La domanda che viene prima di ogni altra

Prima di aprire un binario, un pacchetto distribuito, una pagina o un dispositivo, si risponde a una domanda sola: quel bersaglio è mio, oppure qualcuno che ne ha titolo mi ha autorizzato a esaminarlo? Se la risposta non è sì, non si apre. Non esiste una via di mezzo che renda legittima l'analisi di qualcosa su cui non si ha titolo, e il fatto che l'analisi giri in locale e non esca dalla macchina non cambia la risposta, perché la questione è di autorizzazione e non di riservatezza.

Il progetto dichiara il proprio scopo come ricerca lecita, didattica, interoperabilità, preservazione del software e analisi di software che si possiede o si è autorizzati a esaminare, e include esplicitamente la ricerca di sicurezza, l'analisi di malware e di incidenti, e le competizioni di tipo cattura la bandiera. Dichiara altrettanto esplicitamente che cosa resta fuori: l'aggiramento di protezioni tecniche, di controlli di licenza, di sistemi antimanomissione, e il superamento di autenticazione, protezioni antibot o controlli di accesso su sistemi che non si è autorizzati a provare. Copie piratate, chiavi rubate, condivisione non autorizzata di chiavi e aggiramento di restrizioni di licenza non sono usi autorizzati, e la posizione vale per tutte le versioni dello strumento.

## La distinzione che si dimentica: ispezionare non è eseguire

La frase più utile del progetto, e quella che in pratica separa un uso prudente da uno avventato, è che l'autorizzazione a ispezionare un artefatto non autorizza di per sé a eseguirlo o a intercettarne il traffico. Sono tre permessi distinti e vanno ottenuti distintamente.

Leggere un file e ricavarne struttura, simboli e pseudocodice è un'operazione statica: non esegue nulla, non parla con nessuno, e il bersaglio resta inerte. Lanciare un programma per osservarne il comportamento, attaccarsi a un browser e leggere quel che la pagina fa, pilotare un debugger: queste sono operazioni a runtime, eseguono o guidano codice che non è proprio, e toccano anche ciò che quel codice raggiunge, compresi servizi di terzi e dati di altre persone. Il protocollo marca queste ultime come tali, ma quella marcatura è un suggerimento per il client e non un controllo di autorizzazione: la decisione resta di chi lancia.

Ne segue una regola pratica. Si comincia sempre dalla parte statica, che è anche quella che su Windows funziona meglio. Si passa al runtime solo quando la domanda non ha risposta senza, e dopo aver verificato di avere il permesso anche per quello.

## Gli strumenti commerciali hanno una licenza propria

REA non fornisce licenze, chiavi né diritti di attivazione per i motori di analisi che pilota. Hopper, IDA Pro con i decompilatori Hex-Rays e JEB sono prodotti commerciali e vanno ottenuti legittimamente e usati secondo le rispettive condizioni, versioni di prova comprese, che restano soggette ai limiti del fornitore su utenti, funzioni, automazione e condivisione dei risultati. Ghidra è libero ed è la via senza costo di licenza, ed è anche la sola disponibile su Windows.

Questo punto riguarda il template per una ragione concreta: automatizzare uno strumento commerciale tramite un agente può ricadere nei limiti sull'automazione che quella licenza pone, e la verifica va fatta sulla propria licenza prima di costruirci sopra un flusso di lavoro.

## Non c'è contenimento, e va previsto per conto proprio

Il pacchetto lo dice nel proprio README e vale ripeterlo qui perché è il punto in cui un uso legittimo può comunque fare danno. REA non è una sandbox. L'analisi gira con i permessi dell'utente che l'ha lanciata; i limiti imposti al motore servono a non lasciare residui e a non consumare la macchina, non a contenere codice ostile. L'osservazione del browser si attacca a un profilo vero con un canale che dà accesso profondo a quel profilo.

Chi analizza qualcosa di cui non si fida mette il contenimento dove manca: una macchina virtuale o un contenitore, un profilo di browser dedicato e vuoto, e nessuna credenziale reale nell'ambiente da cui si lancia. Vale anche per un campione che si crede innocuo, perché la differenza fra i due casi è esattamente ciò che l'analisi deve ancora stabilire.

## Che cosa si scrive nel progetto

Quando una indagine con REA produce un risultato che entra in un repository, la voce che la registra dice tre cose: quale bersaglio è stato esaminato, con quale autorizzazione, e quale parte del risultato è prova diretta e quale è inferenza. La prima e la seconda servono a chi rileggerà fra un anno senza ricordare il contesto; la terza è la stessa onestà che `interaction-style.md` chiede a ogni misura, e qui pesa di più perché una conclusione su un binario ha l'aria di un fatto anche quando è una lettura possibile fra due.

Non si versionano mai dentro il progetto il binario altrui, le catture di traffico, i contenuti del progetto del motore di analisi, né le credenziali che una osservazione può avere raccolto senza che nessuno le abbia chieste. La documentazione del progetto avverte che parametri di interrogazione, frammenti di indirizzo, contenuto di script e testo della console possono contenere segreti dell'applicazione e finire nell'evidenza: l'evidenza si rilegge prima di allegarla, esattamente come si rilegge un log prima di aprire una segnalazione.
