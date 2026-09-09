# Pacchetto opzionale: alignment

> Controllo eseguibile che dice quali affermazioni di un progetto stanno invecchiando in silenzio: le scadenze scritte in prosa che nessuno guarda, le misure piu' vecchie della loro cadenza, le domande aperte che nessun programma puo' chiudere, e gli invarianti fra cio' che i documenti affermano e cio' che sta davvero nel repository. E' l'attuazione meccanica della regola `rules/affermazioni-verificabili.md` di questo pacchetto, che va istanziata insieme allo strumento perche' e' il criterio, e lo strumento da solo non decide nulla.

## Il problema, e perche' non e' il drift delle schede

Il sistema di questo template ha gia' un motore di riconciliazione, la skill `sync-context`, e copre bene la domanda "questa scheda descrive ancora il codice che dichiara di coprire". Confronta il frontmatter con il diff dei percorsi coperti e propone edit chirurgici.

C'e' pero' una classe di obsolescenza che quel motore non vede, e non e' un difetto della skill: e' una domanda diversa. Il drift si misura contro il **codice**, cioe' contro qualcosa che sta nel repository e che git conosce. Un'affermazione su un fatto esterno non ha nulla contro cui essere misurata: che una copia di backup fuori sede esista, che una licenza sia coperta, che un'automazione stia girando, che una persona abbia risposto a una domanda. Nessun `git diff` la contraddice mai. Nasce vera e il momento in cui smette di esserlo non lascia traccia.

La differenza pratica fra i due strumenti e' anche di natura. `sync-context` e' una procedura guidata dall'LLM, quindi costa contesto, richiede una sessione e produce un giudizio; questo e' un test deterministico con un codice di uscita, quindi si mette in un hook di avvio, non consuma contesto e produce un fatto. I due si usano insieme: il primo aggiorna le schede, il secondo dice che c'e' qualcosa da guardare.

## Perche' la buona volonta' non basta, in tre numeri

Nel progetto reale da cui questo pacchetto e' estratto, in una sola mattina sono state misurate tre obsolescenze, e **nessuna era una contraddizione** che un lettore attento avrebbe potuto cogliere leggendo i documenti. La copia di backup fuori sede era ferma da sei settimane e ogni documento del progetto continuava ad affermare che esisteva. La scheda dello stack elencava cinque script su ventuno. Una pendenza dichiarava scaduta una cadenza che era invece rispettata.

Nello stesso passaggio si e' contato che nei file tracciati vivevano **sedici date** di scadenza o di presidio scritte in prosa, e che nessun meccanismo le guardava. Ogni incidente che in quel progetto aveva fatto danno era una di quelle date: una licenza scaduta che ha spento per due giorni la fonte automatica con cui si verificava il lavoro, e un abbonamento di spazio cloud scaduto che ha messo una data di cancellazione sull'unica copia storica dei backup.

Nei cinque giorni successivi all'adozione, lo stesso impianto ha trovato un'automazione pianificata che non era mai partita, una replica fuori sede che i documenti davano per esistente e che non esisteva, un guard-rail che non cercava dodici valori reali, e due voci di un registro arrivate in un commit con lo stesso numero perche' scritte lo stesso giorno da due sessioni di lavoro diverse. Il punto non e' la quantita': e' che nessuno di questi era visibile leggendo.

## Le quattro famiglie di controllo

Le **scadenze** sono le date scritte in prosa, portate nel registro con il loro preavviso e con la conseguenza scritta accanto. La conseguenza non e' un ornamento: una data senza la sua ricaduta non fa agire nessuno, ed e' la differenza fra "il 22 novembre scade una licenza" e "il 22 novembre la fonte con cui verifichiamo la configurazione smette di rispondere".

La **freschezza** confronta l'eta' di una misura con la cadenza dichiarata per la fonte che la produce. Della misura si legge la sola data di modifica, mai il contenuto, cosi' nomi host, utenti e indirizzi non entrano nell'output nemmeno per errore. Se il file dichiara dentro di se' la data della misura, il campo `campo_data` la preferisce alla data di modifica, che e' piu' fragile.

Le **asserzioni umane** sono le affermazioni che nessun programma puo' verificare, e ricevono percio' una validita' dichiarata: quando scade tornano a video come domanda, con la domanda gia' scritta e il ruolo della persona a cui porla. Scrivere la domanda adesso e' la parte che si dimentica, ed e' quella che conta: fra due mesi nessuno ricostruira' che cosa andava chiesto.

Gli **invarianti** sono quattro e stanno nel codice, non nel registro, perche' un invariante e' strutturale mentre una scadenza e' un fatto. Gli script presenti nella cartella e non citati nella scheda dello stack. Le decisioni richiamate da qualunque documento e non definite nel registro delle decisioni. L'unicita' dei numeri e degli identificatori di un registro numerato, se il progetto ne ha uno. E il campo di firma delle schede, che merita un paragrafo a se'.

## L'invariante sul campo di firma, sbagliato due volte prima di essere giusto

Vale la pena conoscere entrambi gli errori, perche' sono la ragione per cui questo invariante e' scritto in un modo che a prima vista sembra troppo complicato.

La prima versione confrontava `last-verified-commit` con HEAD. Segnalava tutte le schede dopo qualunque commit, anche uno che non le riguardava: un giallo perpetuo, cioe' il difetto che tutto questo impianto esiste per evitare.

La seconda lo confrontava con il commit che aveva toccato la scheda per ultimo. Meglio, e ancora impossibile: la regola prescrive di bumpare dopo il commit, ma il bump scrive dentro la scheda, quindi genera un commit nuovo che la tocca e riporta il confronto in giallo. Una sessione veniva segnalata **per aver rispettato la regola**, che e' la forma peggiore di avviso perpetuo perche' punisce il comportamento corretto e insegna a ignorare il controllo proprio a chi lo sta usando bene.

La distinzione che scioglie il nodo e' fra una **modifica** e una **firma**. Un commit che tocca i soli campi di firma non cambia la scheda, la firma. Il controllo risale la storia del singolo file saltando i commit di sola firma, trova l'ultima modifica di contenuto, e verifica per **discendenza** e non per uguaglianza: la scheda e' allineata se l'hash dichiarato e' quel commit o un suo discendente. Ne discende che resta verde anche chi rilegge una scheda immutata a una data successiva e porta l'hash in avanti, che e' esattamente cio' che la regola del bump chiede di fare.

Due dettagli del comportamento, entrambi scelti. Un commit che aggiunge una riga di contenuto e ribumpa insieme conta come modifica di contenuto: nel dubbio il controllo segnala. E un hash che non risolve nella storia non e' un disallineamento ma un **riferimento rotto**, riportato in rosso a parte, perche' la causa e' diversa, cioe' un hash scritto a mano male o una storia riscritta sotto i piedi.

## Che cosa ha trovato la prova su questo repository, e perche' e' scritto qui

Il pacchetto e' stato provato sul template, che per un controllo del genere e' il caso peggiore: il repository del template non adotta il proprio sistema su di se', quindi non ha schede, ne' registro delle decisioni, ne' cartella di script. La prova ha trovato tre difetti che la prova sul progetto di origine non poteva trovare, e vale conoscerli perche' due riguardano il modo in cui lo strumento va usato.

Il primo: senza registro lo strumento esce con codice 2, correttamente, ma con un registro **vuoto** dichiarava "allineato, nessuna affermazione scaduta", cioe' esattamente il verde non calcolato che tutta la sua ragione d'essere condanna. Ora un registro vuoto e' un esito giallo dichiarato, e gli invarianti restano calcolati perche' non dipendono dal registro.

Il secondo: le voci di esempio, copiate senza modifiche, producevano un rosso finto su date segnaposto illeggibili. Nascono percio' **inerti**, nelle chiavi che cominciano per `_esempio` e che lo strumento non legge, e si copiano dentro gli array quando si scrive la prima voce vera.

Il terzo riguarda una scelta di generalizzazione. Allargando l'ampiezza del richiamo numerico da tre a quattro cifre, per accogliere registri piu' grandi, il controllo ha segnalato come riferimento a una voce inesistente il numero di un ticket di un sistema esterno citato in prosa: un falso positivo inventato alla prima esecuzione su un corpus reale, che e' il modo piu' rapido per perdere la fiducia di chi legge il report. Il default e' quindi tornato stretto, due o tre cifre, e l'ampiezza si dichiara nel registro con `richiami_cifre` quando un progetto numera oltre il migliaio.

## Rumoroso e non bloccante, che e' una scelta

Lo strumento gira a ogni avvio di sessione e non blocca. La ragione e' la stessa che governa le tolleranze dei singoli invarianti: un controllo che fallisce sempre smette di essere letto, e questo gira ogni volta. Distingue percio' nel codice di uscita il **giallo** dal **rosso**, dove il giallo e' un'affermazione che sta invecchiando e non marca la sessione come fallita, e il rosso e' qualcosa di gia' rotto. Esce comunque con un codice diverso da zero sul rosso, cosi' che un domani possa diventare bloccante senza riscriverlo.

Ne discende una pratica sullo scrivere il registro. Un'eccezione decisa da una persona si dichiara nel posto dove il controllo la legge, con la sua ragione accanto, e il controllo la conta a parte: un'eccezione dichiarata resta visibile come eccezione, un'eccezione subita diventa rumore.

## Cosa istanzia, e dove

Nel progetto vanno tre cose.

Lo strumento `tools/Test-Allineamento.py` va in `tools/`, oppure in `scripts/` se il progetto usa quella convenzione. Non porta cablata l'anatomia di nessun progetto: i percorsi si dichiarano nel blocco `percorsi` del registro, e una voce messa a `null` dichiara che quella cosa nel progetto non esiste, cosi' l'invariante corrispondente si annuncia non applicabile invece di fallire.

Il registro va tracciato. Si copia `scadenze.example.json` in `data/scadenze.json`, oppure altrove passando `--registro`, e si sostituiscono le voci di esempio con quelle vere. Va tracciato perche' e' la parte del progetto che dichiara cosa scade, e va tenuto pulito allo stesso modo dei documenti: date, cadenze e riferimenti, mai importi ne' identificativi ne' nomi di persona, perche' l'esito del controllo finisce sotto gli occhi di chiunque guardi la sessione. Se il file manca, lo strumento esce con codice 2 e lo dichiara, invece di stampare un verde che non ha calcolato.

La regola `rules/affermazioni-verificabili.md` va in `.claude/rules/` e va dichiarata fra quelle da caricare sempre nel `CLAUDE.md` del progetto. E' il passo che si dimentica, ed e' quello che rende il registro non vuoto: senza il vincolo su cio' che si scrive, il controllo ha pochi dati da guardare e sembra inutile.

Infine si registra l'esecuzione in un hook `SessionStart` di `settings.json`, accanto agli altri controlli di avvio del progetto.

```
python tools/Test-Allineamento.py                report completo
python tools/Test-Allineamento.py --silenzioso   solo il verdetto
python tools/Test-Allineamento.py --giorni 30    orizzonte delle scadenze mostrate
python tools/Test-Allineamento.py --registro X   registro in una posizione diversa
python tools/Test-Allineamento.py --radice Y     radice del repository
```

## Quando offrirlo

Si offre a un progetto che ha almeno una di queste tre cose: fatti esterni che il repository non contiene, cioe' licenze, abbonamenti, contratti, misure prese da fonti vive; documentazione che descrive un'infrastruttura o un sistema di terzi, che cambia senza notificare; oppure piu' sessioni di lavoro o piu' persone che scrivono sugli stessi file.

Non si offre a un progetto di solo codice dove ogni affermazione e' verificabile eseguendo i test: la' il posto giusto per un invariante e' la suite, non un registro di scadenze.

## Portabilita'

Lo strumento risale alla radice del repository dalla posizione del proprio file, cercando `.git` sia come cartella sia come file perche' in un worktree e in un submodulo e' un file che punta altrove, e accetta `--radice` per i casi in cui la risalita non basti. La ragione e' che la cartella corrente dipende da chi invoca, e chi invoca puo' essere una sessione, un hook, un'attivita' pianificata o un altro script: quattro cartelle diverse per lo stesso comando.

Non usa dipendenze esterne, non apre connessioni, non legge credenziali e non scrive nulla: legge file gia' sul disco e interroga git. E' la ragione per cui si automatizza senza pensarci, a differenza degli script che rinfrescano una misura interrogando un fornitore.

## Requisiti e stato

Python 3.8 o superiore, git nel PATH. Nessuna libreria esterna.

Estratto da un progetto reale di documentazione infrastrutturale, dove gira a ogni avvio di sessione da settembre 2026 su ventisei controlli fra scadenze, cadenze, asserzioni e invarianti. La versione di questo pacchetto e' generalizzata: i percorsi sono configurabili, gli invarianti specifici di quel dominio non sono risaliti, e la verifica meccanica prescritta da questo template e' che una ricerca dei nomi del progetto di origine dentro questi file dia zero riscontri.
