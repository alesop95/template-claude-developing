# community-sources

Pacchetto per le fonti che vivono dentro canali di conversazione di community, cioè quelle che nessuno strumento di sessione raggiunge e che per certi domini tecnici sono la sola documentazione esistente. Contiene oggi un solo strumento, il lettore di canali Discord attraverso un bot account ufficiale, e la sua ragione d'essere è meno ovvia di quanto sembri: non è che leggere un canale sia difficile, è che le vie per farlo sono tre e due di esse hanno conseguenze che vale conoscere prima di scegliere.

La regola che le distingue è `.claude/rules/web-sources-not-fetchable.md`, che appartiene alle regole sempre caricate e non a questo pacchetto: il pacchetto è lo strumento, la regola è il criterio. Chi istanzia questo pacchetto senza quella regola si ritrova con un programma che funziona e senza il vocabolario per decidere quando usarlo.

## Che cosa istanzia

Un solo file, `tools/fetch-discord.py`, che va copiato in `tools/` del progetto ospite. Python 3, sola libreria standard, nessuna dipendenza.

## Perché un programma e non un server MCP

La scelta va motivata perché la letteratura sul tema raccomanda l'altra strada, e la raccomandazione non è sbagliata: è giusta per un contesto diverso. Un server MCP dedicato a Discord serve quando un agente residente deve poter chiamare quel tool nel mezzo di una conversazione, decidendo lui quando leggere; è il caso di un assistente che vive su un server e a cui si chiede che cosa sia stato detto in un canale.

Qui il compito è un altro: leggere una fonte e trasferirne la sintesi nel registro delle fonti del progetto. È lavoro deterministico, e la regola `token-economy.md` prescrive di tenere il lavoro deterministico su codice invece che su modello. Un programma sulla sola libreria standard fa quel lavoro senza aggiungere un ambiente di esecuzione ulteriore, un pacchetto di terze parti a cui affidare una credenziale, e uno strato di protocollo interposto fra il chiamante e una richiesta HTTP.

Le due vie non si escludono, perché usano il medesimo bot account: un progetto che avesse entrambe le esigenze può istanziare questo strumento e configurare un server MCP con lo stesso token.

## Le tre vie di accesso, e quale implementa questo strumento

La prima via è il token del proprio account personale, cioè il self-bot. Funziona tecnicamente e non richiede il permesso di nessuno, perché l'account è già dentro il server. È vietata dalle condizioni d'uso di Discord, che dedicano alla questione una pagina di supporto, e la sanzione dichiarata è la terminazione dell'account senza distinzione di intenzioni. Va aggiunto un argomento che di solito manca nella valutazione: un token utente dà accesso a tutto ciò che vede l'account, messaggi privati compresi, quindi il danno di una sua fuga è incomparabilmente più ampio di quello di un token con permessi ristretti.

La seconda via è la copia manuale del materiale pertinente. Non richiede nulla, non ha rischi, e ha una qualità che le vie automatiche non hanno: chi copia sa che cosa sta cercando, quindi il filtro incorpora la domanda. Su un progetto reale questa via ha corretto tre affermazioni errate del progetto in poche decine di schermate, con un rapporto fra segnale e volume che una lettura automatica integrale non avrebbe avuto.

La terza via è quella che questo strumento implementa, cioè un bot account creato nel portale per sviluppatori. La distinzione dalla prima poggia su fatti verificabili e non su una interpretazione benevola: il tipo di token è diverso e la documentazione ufficiale descrive il bot account come dedicato all'automazione; l'accesso a un server passa da un invito che chi amministra autorizza esplicitamente, scegliendo i permessi e potendoli revocare; il bot porta un contrassegno visibile a tutti, quindi non finge di essere una persona; l'API è pubblica, con limiti di frequenza pensati per traffico automatico, mentre un self-bot deve imitare artificialmente il ritmo di un umano; e il rischio in caso di uso scorretto ricade sull'applicazione e non sull'account personale.

## Il limite da conoscere prima di allestire

Un bot entra in un server soltanto se qualcuno con il permesso di gestione lo invita, e non esiste alcuna altra via perché è l'unico flusso che l'API espone. Su un server di cui non si è amministratori la terza via richiede quindi il consenso di terzi.

Il punto va capito nella sua forma esatta, perché è facile fraintenderlo: il cancello non è sui dati ma sul bot. I messaggi di un canale di cui si è membri sono già visibili, e nessuno autorizza a leggere ciò che il server mostra già; ciò che l'invito autorizza è far entrare una seconda identità dentro quel server. È questo che richiede il consenso, ed è corretto che lo richieda, perché altrimenti chiunque potrebbe immettere programmi nei server altrui.

Ne segue una prescrizione operativa in tre passi. Si chiede, perché chiedere è gratuito e alcune community di sviluppo accettano un lettore dichiarato. Si dichiara nella richiesta a che cosa serve e quali permessi si chiedono, cioè soltanto vedere il canale e leggerne la cronologia. E si accetta che un no sia un esito, dopo il quale resta la seconda via.

Esiste una eccezione parziale, ed è la sola che non richieda il consenso del server di origine: i canali di annunci di un server di tipo community si possono seguire da un altro server, con replica dei messaggi pubblicati, e il permesso necessario è quello di gestire i webhook nel server di destinazione, cioè nel proprio. Il limite è netto: riguarda i canali di annunci e non le discussioni, che è il posto dove sta la conoscenza tecnica. È utile per non perdere un rilascio, non per studiare un protocollo.

## Allestimento

Cinque passi, una volta sola.

Su `https://discord.com/developers/applications` si crea una applicazione e, nella sezione Bot, il bot; si copia il token, che il portale mostra una volta sola e che va trattato come una password.

Nella stessa sezione si abilita Message Content Intent, senza il quale Discord consegna i messaggi privi di testo anche a un bot che ha i permessi. La soglia oltre la quale quell'intent richiede una revisione è di diecimila utenti, non di cento server: i cento server sono la soglia della verifica formale dell'applicazione, che è cosa diversa, e confondere le due porta a credere di dover chiedere un'approvazione che non serve. Conviene spegnere Public Bot, cosicché nessun altro possa installare l'applicazione, e lasciare spento Requires OAuth2 Code Grant, che romperebbe l'invito.

Si genera l'URL di invito con i soli permessi di lettura, cioè View Channels e Read Message History, che sommati danno 66560, ossia 1024 più 65536. Il numero va calcolato e non copiato da un forum: ogni permesso è un bit di un intero, e un numero trovato altrove può concedere molto più di quanto si crede.

Si invita il bot nel server, che richiede di esserne amministratori o di ottenere il consenso di chi lo è.

Si scrive a mano `DISCORD_BOT_TOKEN` in `.env` nella radice del progetto, che il `.gitignore` esclude. Dove le regole di permesso negano i percorsi che corrispondono a `.env*`, e nel sistema di progetto di questo template lo fanno, l'agente non può creare quel file nemmeno come modello: è una limitazione voluta e non va aggirata.

## Uso

```
python tools/fetch-discord.py guilds
python tools/fetch-discord.py channels <id del server>
python tools/fetch-discord.py fetch <id del canale> --limit 500
python tools/fetch-discord.py fetch <id del canale> --limit 0 --nuovi
python tools/fetch-discord.py fetch <id> --grep "parola" --min-length 40 --since 2026-01-01
python tools/fetch-discord.py fetch <id> --append --out _notes/fonti/2026-01-31-canale.md
python tools/fetch-discord.py --self-test
```

Il cursore di `--nuovi` vive in `_notes/.discord-cursori.json` e avanza fino all'ultimo messaggio letto e non all'ultimo scritto, cosicché un filtro restrittivo non faccia rileggere ogni volta i messaggi che ha scartato. È la sola parte del costo che dipende da chi legge.

## Il presidio, e il principio che esemplifica

Lo strumento invia sempre l'intestazione di autorizzazione nella forma prevista per i bot, e prima di qualunque lettura verifica che l'account autenticato sia dichiarato tale, arrestandosi con la ragione se non lo è. Un token personale inserito per errore in quella variabile non produce quindi una lettura riuscita ma un rifiuto.

Il principio vale oltre il caso e governa anche il controllo degli identificativi e quello della data del filtro: una distinzione normativa diventa effettiva soltanto quando è resa meccanica nel punto in cui potrebbe essere violata per distrazione. Dichiararla nella documentazione la rende conoscibile, verificarla nel codice la rende operante.

Il presidio non va rimosso per far funzionare la prima via. Se un progetto decide di percorrerla, quella decisione va registrata come tale e richiede uno strumento diverso, non la disattivazione di un controllo dentro questo.

## Le difese contro un canale vero

Sette difese esistono perché un canale di prova non esercita nulla, e la circostanza vale come lezione generale sul collaudo. La prima esecuzione riuscita, su un progetto reale, era avvenuta su un canale con cinque messaggi e aveva dato esito positivo su ogni passo; ma un canale con cinque messaggi non impagina, non raggiunge alcun limite di frequenza, non produce guasti di rete, non contiene discussioni annidate né contenuti non testuali, e non ospita testo di terzi capace di rompere il file prodotto. Un collaudo riuscito misura anche ciò che l'apparato di prova sapeva sollecitare, e quel secondo dato non compare nel suo esito.

Il limite di frequenza è governato in modo reattivo, attendendo quanto il servizio dichiara nel rifiuto e prendendo il maggiore fra il valore dell'intestazione e quello del corpo, e in modo preventivo, leggendo a ogni risposta quante richieste restano nella finestra e attendendo quando sono esaurite: la seconda modalità evita il rifiuto invece di reagirvi.

I guasti transitori, cioè errori di rete, timeout e risposte di errore del servizio, non interrompono una cronologia a metà ma fanno riprovare con attesa raddoppiata fino a un tetto, e l'abbandono definitivo riferisce l'ultimo esito osservato invece di un messaggio generico.

Le discussioni e i post di forum sono canali con identificativo proprio e nelle community di sviluppo sono il posto dove sta la conoscenza: l'elenco dei canali li include interrogando l'endpoint dedicato, e la lettura funziona su un loro identificativo come su quello di un canale.

Il contenuto che non è testo, cioè i blocchi incorporati e la citazione del messaggio a cui una risposta si riferisce, entra nella resa e nei filtri: ignorarlo renderebbe vuoti messaggi che portano contenuto, e li farebbe scartare proprio dal filtro di lunghezza.

Il testo di terzi che apre con un cancelletto viene protetto, perché altrimenti forgerebbe un'intestazione e spezzerebbe la nota, con l'eccezione dei blocchi di codice recintati dove quel carattere appartiene al linguaggio.

La data del filtro viene verificata nella forma, perché una data scritta con le barre passerebbe senza errore e scarterebbe tutto o nulla: è il genere di filtro che sbaglia senza dirlo.

E la scrittura può aggiungersi in coda a un file esistente invece di sovrascriverlo, con l'intestazione scritta una volta sola; quando sovrascrive, avvisa.

## Collaudo

`--self-test` esercita l'intera logica contro un trasporto finto e non richiede credenziali: trentasette controlli, quattro dei quali negativi, cioè che fallirebbero se un presidio venisse rimosso. Il trasporto finto accetta un programma di risposte, cosicché un rifiuto o un guasto si possano collocare in una posizione precisa della sequenza e si verifichi non soltanto che la lettura riesca, ma quanto si è atteso e quante richieste sono state fatte.

Contro il servizio sono stati esercitati, su un progetto reale, l'elenco dei server, l'elenco dei canali e delle discussioni attive, la lettura della cronologia con il testo presente, i filtri, l'aggiunta in coda e il cursore. Restano non osservati sul servizio l'impaginazione oltre i cento messaggi, le due attese sui limiti di frequenza, la ripresa dopo un guasto e la lettura di una discussione popolata: tutto questo è provato contro il trasporto finto, e la distinzione fra i due stati è dichiarata nella nota di collaudo dentro il file e va conservata.

## Che cosa resta da rispettare comunque

La legittimità del token non esaurisce la questione, perché i messaggi di un canale sono scritti da altre persone e archiviarli sistematicamente tocca la loro privacy anche quando il canale è visibile a tutti i membri.

Quattro accorgimenti rendono la conservazione difendibile invece di soltanto dichiarata, e lo strumento ne attua il primo per costruzione. Si conserva l'identificativo dell'autore accanto al contenuto, perché senza di esso una richiesta di cancellazione mirata non è eseguibile e prometterla sarebbe una promessa vuota. Si tiene il materiale in un luogo unico, cosicché una cancellazione sia un'operazione e non una ricerca. Si elimina il materiale grezzo quando la sintesi con l'attribuzione lo ha reso superfluo, che è già la forma minima di limitazione della conservazione. E si richiedono i soli permessi necessari, perché domandarne di ampi per prudenza è il contrario della prudenza.

Se il server non è proprio, va inoltre considerato che la comunità ha diritto di sapere: una regola visibile nel canale, o la dichiarazione nella richiesta di invito, rende i tre accorgimenti precedenti verificabili dall'esterno invece che soltanto affermati.

## Che cosa manca a questo pacchetto

Tre strumenti della stessa famiglia esistono su un progetto reale e non sono ancora qui, e l'assenza è dichiarata perché la regola li nomina: il lettore dell'API di Reddit a sole credenziali applicative, il convertitore di un export di chat Discord o Telegram in Markdown filtrato, e il ripulitore dei sottotitoli di un video. Vanno portati con lo stesso metodo usato per questo, cioè copiando il file e adattando la sola prosa, così che le due copie non divergano nella logica.
