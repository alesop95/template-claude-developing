# Guida d'uso: come sfruttare davvero questo template

> Il `README.md` dice che cosa c'è, `docs/feature-map.html` lo inventaria, `.claude/PROJECT-SYSTEM.md` è la norma. Questo documento risponde a una domanda diversa e più pratica: davanti a un obiettivo concreto, quale leva si tira, in che ordine, e con quale cadenza. È scritto per essere letto una volta per intero e poi consultato per sezione, e vive nel repository del template: non si copia nei progetti, perché parla del template e non di ciò che il template installa.

## Il malinteso da togliere subito

Il sistema non è un insieme di settantaquattro pacchetti fra cui scegliere. È un motore piccolo, che vale sempre, più un catalogo grande, che vale a condizione. Chi comincia dal catalogo si perde, e chi comincia dal motore ha già l'ottanta per cento del valore prima di aver installato niente.

Il motore è questo: una memoria del progetto versionata dentro il repository, schede di contesto ancorate a un commit, un work-log e un registro di decisioni, e un ciclo che le tiene allineate al codice. Tutto il resto è opzionale per costruzione. Se si adottasse solo il motore e nessun pacchetto, il sistema funzionerebbe: quello che si perderebbe sono capacità specifiche, non la tenuta.

Da qui discende il criterio di lettura di tutto ciò che segue: prima si impara il ciclo, poi si aprono i settori del catalogo che il progetto riguarda davvero, che sono due o tre su dieci.

## Le tre porte d'ingresso

**Un progetto nuovo.** Si incolla `.claude/PROMPT-nuovo-progetto.md` in Claude Code nella radice del progetto. È un prompt fisso, si usa sempre identico, e conduce l'agente attraverso l'account attivo, l'identità git, l'anatomia, il gate dei pacchetti e la gestione dell'auto-memory. Alla fine restano da fare a mano il primo commit e il push, perché il sistema non committa mai.

**Un progetto che esiste già.** Si incolla `.claude/PROMPT-allinea-progetto-esistente.md`. La differenza non è di quantità ma di direzione: qui non si scaffolda, si rileva che cosa c'è, lo si mappa contro l'anatomia canonica, e si ricostruisce la memoria dalla storia dei commit senza inventare. Le schede si allineano poche alla volta, non tutte in una sessione.

**Una sessione qualunque, su un progetto già allineato.** Si invoca la skill `riprendi`, che prima verifica e poi legge. Non è una formalità: la procedura di ripresa presuppone che la sessione precedente sia arrivata alla fine, e quando non è così il file di ripresa descrive un passato che ha lo stesso aspetto del presente.

## Il ciclo di una sessione

All'apertura si esegue `riprendi`. La skill lancia `tools/verifica-ripresa.py`, che confronta l'impronta registrata alla chiusura precedente con lo stato reale di git e dice che cosa diverge: commit comparsi dopo l'ultima registrazione, file rimasti a metà, memoria arretrata, schede ancorate a un commit che non c'è più. Una divergenza si riporta all'utente prima di qualunque altra cosa, perché un file lasciato a metà può essere un lavoro da riprendere o uno da buttare e la differenza non si legge dal contenuto.

Poi si legge `.claude/memory/index.md`, che è lo snapshot, e `.claude/context/current-work.md` se c'è una feature attiva. Si invoca `sync-context` per misurare il drift fra schede e codice. Si leggono le sole schede pertinenti al task, mai tutte insieme: è la prima e più efficace misura di economia del contesto, e non richiede alcun pacchetto.

Durante il lavoro vale una regola sola, ed è quella che il sistema difende con più insistenza: ciò che si scrive in sessione si scrive anche su disco, nel medesimo giro di lavoro in cui nasce. Un numero misurato va in un documento, una correzione nel work-log, una decisione nel registro come ADR, un lavoro rimandato nel registro delle pendenze, una fonte nel registro delle fonti. Alla fine di ogni giro sostanziale l'agente dichiara in una riga quali file ha scritto: se quella riga manca, il contenuto è rimasto in chat ed è già perduto.

Alla chiusura si aggiorna `_notes/RESUME-PROMPT.md` con lo stato raggiunto e il prossimo passo, l'utente fa i propri commit, e solo dopo si registra l'impronta con `python tools/verifica-ripresa.py --registra`. L'ordine conta: registrare prima dei commit produce alla sessione successiva una divergenza che non è una caduta ma una registrazione fatta troppo presto, e un falso positivo insegna a ignorare il controllo, che è il modo in cui un presidio muore.

## Il calendario: che cosa si fa, e ogni quanto

| Cadenza | Che cosa | Con che cosa |
|---|---|---|
| Ogni apertura di sessione | Verificare che il file di ripresa descriva il presente | skill `riprendi`, `tools/verifica-ripresa.py` |
| Ogni apertura di sessione | Misurare il drift fra schede e codice | skill `sync-context` |
| Ogni giro di lavoro sostanziale | Scrivere su disco ciò che è nato in chat, e dichiarare quali file | regola `chat-non-e-memoria.md` |
| Ogni file `.md` scritto o modificato | Riportare i paragrafi su riga sorgente unica | `tools/md-unwrap.py` |
| Prima di preparare un commit | Convenzione Markdown, tipografia, comandi copiabili, riferimenti | `md-unwrap --check`, `fix-accents`, `fix-dashes`, `lint-md-commands`, `lint-doc-references` |
| Ogni chiusura di sessione | Aggiornare il file di ripresa e registrare l'impronta | `tools/verifica-ripresa.py --registra` |
| Ogni tornata di allineamento | Riattraversare il gate dei pacchetti per settore | skill `gate-pacchetti` |
| Periodicamente, su un progetto lungo | Rigenerare la linea temporale e guardare i passi senza ragione | `tools/costruisci-timeline.py --senza-ragione` |
| Periodicamente | Controllare le affermazioni che invecchiano | `alignment`, `tools/Test-Allineamento.py` |
| Una volta per macchina | Igiene dell'account e profili SSH reali | `check-account-hygiene`, `detect-ssh-profiles.py` |

## Diagnosi: dal sintomo allo strumento

Questa è la tabella da tenere aperta quando qualcosa non torna. La colonna del sintomo è scritta come la si formula davvero, non come la formulerebbe chi conosce già la risposta.

| Sintomo | Che cosa sta succedendo | Che cosa si lancia |
|---|---|---|
| "Non ricordo dove eravamo, e il file di ripresa sembra vecchio" | Una sessione è caduta senza chiudersi | `verifica-ripresa.py` |
| "La documentazione descrive un file che non trovo" | Una fotografia invecchiata in un documento vivo | `lint-doc-references.py --solo-vivi` |
| "Le schede non corrispondono più al codice" | Drift fra documentazione e commit | skill `sync-context` |
| "Perché a marzo abbiamo scelto questa libreria?" | Il fatto è registrato, la ragione no | `costruisci-timeline.py`, poi `--senza-ragione` |
| "Questo documento dice una cosa che forse non è più vera" | Un'affermazione con una scadenza implicita | `alignment` |
| "Il diff è pieno di righe che nessuno ha toccato" | Paragrafi hard-wrapped che si ri-avvolgono | `md-unwrap.py` |
| "Questo comando incollato si è spezzato in due" | Una continuazione di riga dentro un blocco di codice | `lint-md-commands.py` |
| "Sto per rendere pubblico il repository" | Dati che identificano persone o infrastrutture reali | `anonymization`, `Test-Anonymization.py` |
| "Il commit è partito con l'email sbagliata" | Identità git non impostata a livello locale | `detect-ssh-profiles.py --repo .` |
| "Questa fonte esiste ma non riesco a leggerla" | Una fonte fuori dalla portata degli strumenti di sessione | regola `web-sources-not-fetchable.md`, poi `community-sources` |
| "La sessione consuma troppo contesto" | Prima si misura, poi si interviene | `ccusage`, poi il settore dell'economia del contesto |
| "Ho un video che documenta la cosa e nessuna trascrizione" | Sottotitoli se ci sono, riconoscimento vocale se no | `vtt-to-text.py`, altrimenti `voicestudio` |

## I dieci settori, e come si riconosce il proprio progetto

Il catalogo è diviso in dieci settori e la skill `gate-pacchetti` li attraversa così: raccoglie i fatti del progetto, dichiara quali settori ha riconosciuto e da che cosa, li fa correggere, e propone i soli pacchetti dei settori riconosciuti. Conoscere in anticipo le domande di riconoscimento rende quella conversazione più veloce.

Le fondamenta e l'igiene non dipendono dal dominio ma dalla durata: un progetto che vivrà mesi e passerà di mano li vuole quasi tutti, uno che dura una settimana quasi nessuno. La scrittura e la tipografia riguardano chi produce prosa destinata a qualcuno, anche quando quel qualcuno è la sessione di fra tre mesi. Le fonti riguardano chi poggia su materiale che non ha scritto, e hanno tre famiglie che quasi nessun progetto possiede tutte insieme: documenti da ingerire, letteratura con una bibliografia, discussioni di community. La voce ha due usi opposti, leggere il parlato altrui e produrre il proprio. I domini scientifici si riconoscono dall'oggetto, e la domanda giusta non è se servano le skill scientifiche ma di quale disciplina si tratti. La comprensione di una codebase serve quando il codice esiste già e va capito. Lo sviluppo e la qualità servono a chi scrive codice. L'apprendimento guidato serve dove l'obiettivo dichiarato è imparare, non dove si producono contenuti didattici per altri. L'economia del contesto è sempre valutabile, con una regola d'ordine: prima si misura la linea di partenza, poi si installa. L'orchestrazione ha un trigger quantitativo, cioè tre sessioni o tre rami paralleli, sotto il quale costa più di quanto renda.

## Ricette per archetipo di progetto

Sono combinazioni che funzionano insieme, non elenchi di pacchetti buoni. Ciascuna dichiara che cosa lascia fuori, perché è la parte che si dimentica.

**Un progetto di codice che durerà mesi.** Motore completo, più `stack-profiles` per le convenzioni dello stack riconosciuto, `hooks-starter` con il solo hook di apertura sessione, `dev-skills` scegliendo caso per caso quali skill e dichiarando la sovrapposizione con quelle native, `github-mcp` se il lavoro passa da pull request e issue, `context7` se lo stack evolve in fretta, e `ccusage` come misura di partenza. Resta fuori tutto il settore delle fonti, e resta fuori l'orchestrazione finché non ci sono tre rami paralleli davvero.

**Un progetto documentale, una tesi, un libro.** Motore completo, più `md-unwrap` e `fix-typography` che sono quasi obbligatori perché la prosa è il prodotto, `docx-to-docs` o `doc-ingest` secondo che il materiale sia un documento voluminoso o un corpus, `latex` se l'uscita è composta tipograficamente, `academic-researcher` se c'è una bibliografia da tenere, `humanizer` per la prosa destinata a un lettore esterno, e `documentazione-didattica` se chi scrive vuole anche imparare rileggendo. Resta fuori tutto ciò che riguarda il codice, e restano fuori le tre skill di ingegneria che presuppongono un tracciatore di problemi.

**Un progetto ereditato, di cui non si conosce la struttura.** Si parte dal prompt di allineamento, si attiva `code-context` come primo strato perché costa poco e dà struttura e simboli, e si sale di profondità solo se serve: `repomix` per una vista consolidata iniziale, `serena` per la navigazione a livello di simbolo, `codebase-memory-mcp` per il grafo delle chiamate su un repository davvero grande, `codebase-learning` se l'obiettivo è capirlo e non solo modificarlo. La tentazione da evitare è attivarli tutti insieme: sono quattro indici dello stesso codice, e su un progetto piccolo tre sono rumore.

**Un progetto che raccoglie fonti di community.** `community-sources` con i suoi sei strumenti, e la regola `web-sources-not-fetchable.md` che ne è il criterio: il pacchetto è lo strumento, la regola dice quando usarlo e quale via scegliere. Si aggiunge `voicestudio` se fra le fonti ci sono video senza sottotitoli, e `censimento-fonti.py` chiude il cerchio trasformando una corsa in righe di registro. Resta fuori la tentazione di esportare tutto: la ricerca mirata dentro il canale, fatta da chi conosce la domanda, rende più di un export in blocco, perché il filtro incorpora la domanda.

**Un progetto scientifico.** `scientific-skills` per la mappa, e poi una skill per volta dalla porzione che riguarda la propria disciplina, seguendo la procedura in quattro mosse invece di installare in blocco. Si valuta se tenere la catena bibliografica di quella raccolta oppure `academic-researcher`, e la scelta si registra come decisione: due sistemi di citazioni che convivono producono due bibliografie che divergono.

**Un progetto lungo seguito da una persona sola.** È il caso in cui i registri valgono di più, perché l'unica persona che sa perché una cosa è fatta così è anche l'unica che se ne dimenticherà. `operations-log` per i microstep con la loro verifica, `documentazione-didattica` per il perché di una scelta contro l'alternativa scartata, `timeline-progetto` per leggerli come una storia sola, `alignment` per le affermazioni che invecchiano. È anche il caso in cui `riprendi` conta di più, perché nessun altro si accorgerà che una sessione è caduta.

## Le tre cose che il sistema si rifiuta di fare, e perché

Non committa e non pusha mai. L'agente prepara i file e consegna i comandi; le operazioni di version control restano dell'utente. Non è diffidenza verso lo strumento ma la sola garanzia che nessuna modifica entri nella storia senza che una persona l'abbia guardata.

Non scrive di propria iniziativa nella memoria e nelle schede. Propone il delta e lo applica quando l'utente lo chiede, perché il versionamento della memoria deve restare sotto controllo umano. L'eccezione dichiarata riguarda i documenti di conoscenza, cioè studi, censimenti e registri di fonti, che l'agente scrive sempre: là il rischio è opposto, ed è che il contenuto resti in chat.

Non lascia che la memoria del progetto viva fuori dal progetto. L'auto-memory nativa è disattivata per default, il magazzino nascosto si ripulisce a fine sessione, e ogni artefatto che il sistema produce vive nel repository. Una conoscenza che stia nell'account non entra in nessun clone, è invisibile a chiunque altro, e sparisce al primo wipe.

## Che cosa leggere quando

`README.md` è il riferimento: che cosa esiste, con i crediti e l'indice dei README dei pacchetti. `.claude/PROJECT-SYSTEM.md` è la norma, e vince su tutto il resto quando divergono. `.claude/rules/` sono le regole sempre caricate, e sono la parte che cambia davvero il comportamento di una sessione. `.claude/templates/PACKAGES.md` è il catalogo, diviso per settore. `CASE-STUDIES.md` racconta che cosa è stato provato sul campo e che cosa si è imparato, compreso ciò che non ha funzionato. `docs/feature-map.html` e `docs/project-flow.html` sono le due mappe visive, la prima come inventario e la seconda come flusso narrato dal giorno zero.

E questo documento è la risposta alla domanda che nessuno degli altri risponde, cioè da dove si comincia.
