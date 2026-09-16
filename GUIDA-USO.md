# Guida d'uso: come sfruttare davvero questo template

> Il `README.md` dice che cosa c'è, `docs/feature-map.html` lo inventaria, `.claude/PROJECT-SYSTEM.md` è la norma. Questo documento risponde a una domanda diversa e più pratica: davanti a un obiettivo concreto, che cosa parte da solo, che cosa devi digitare, e che cosa devi aver registrato una volta perché parta da solo. È scritto per essere letto una volta per intero e poi consultato per sezione, e vive nel repository del template: non si copia nei progetti, perché parla del template e non di ciò che il template installa.

## Il malinteso da togliere subito

Il sistema non è un insieme di settantaquattro pacchetti fra cui scegliere. È un motore piccolo, che vale sempre, più un catalogo grande, che vale a condizione. Chi comincia dal catalogo si perde, e chi comincia dal motore ha già l'ottanta per cento del valore prima di aver installato niente.

Il motore è questo: una memoria del progetto versionata dentro il repository, schede di contesto ancorate a un commit, un work-log e un registro di decisioni, e un ciclo che le tiene allineate al codice. Tutto il resto è opzionale per costruzione. Se si adottasse solo il motore e nessun pacchetto, il sistema funzionerebbe: quello che si perderebbe sono capacità specifiche, non la tenuta.

## Il secondo malinteso, che è più costoso del primo

Niente in questo sistema è automatico appena installato. Gli hook esistono come file e non fanno nulla finché qualcuno non li registra nel `settings.json` del progetto, e questa non è una svista ma una scelta: un hook è codice che gira senza che nessuno lo chieda, e un pacchetto che ne attivasse sette di sua iniziativa sarebbe un pacchetto che esegue programmi sulla macchina di chi lo installa.

Ne segue la distinzione che governa tutta questa guida, e che va tenuta a mente ogni volta che qui si legge "parte da solo": significa che parte da solo **dopo che lo hai registrato una volta**. La registrazione si fa una volta per progetto, si verifica con `/hooks`, ed è il singolo investimento che trasforma una lista di buone pratiche in un comportamento.

## Che cosa parte da solo, e a quale condizione

| Momento | Che cosa succede senza che tu faccia niente | Meccanismo | Perché parta, serve |
|---|---|---|---|
| Apertura sessione | Lo stato viene stampato in contesto: branch, commit, file modificati, testa della memoria | hook `session-context`, evento `SessionStart` | registrarlo una volta |
| Apertura sessione | L'impronta registrata alla chiusura viene confrontata con lo stato reale, e le divergenze entrano in contesto | hook `apertura-sessione`, evento `SessionStart` | registrarlo una volta, più `tools/verifica-ripresa.py` istanziato |
| Apertura sessione | L'agente riceve l'istruzione di invocare `sync-context` come secondo atto | lo stesso hook, che la stampa in contesto | come sopra |
| Ogni scrittura di un `.md` | I paragrafi tornano su riga sorgente unica | hook `md-unwrap-auto`, evento `PostToolUse` su `Write` ed `Edit` | registrarlo una volta, più `tools/md-unwrap.py` istanziato |
| Ogni `git commit` dell'agente | Girano i quattro controlli di convenzione, e il commit si ferma se uno fallisce | hook `pre-commit-checks`, evento `PreToolUse` su `Bash` | registrarlo una volta |
| Ogni `git commit` dell'agente | Il diff in stage viene scansionato alla ricerca di segreti | hook `secret-scan`, evento `PreToolUse` su `Bash` | registrarlo una volta |
| Ogni scrittura su un file sensibile | La scrittura viene bloccata | hook `protect-sensitive-files`, evento `PreToolUse` | registrarlo una volta |
| Chiusura sessione | L'impronta di ripresa viene registrata | hook `chiusura-sessione`, evento `SessionEnd` | registrarlo una volta |
| Chiusura sessione | Il magazzino nascosto dell'account viene ripulito | hook `session-end-wipe`, registrato **nell'account** e non nel progetto | installarlo una volta per macchina |

Tre avvertenze rendono questa tabella onesta invece che ottimistica.

La prima è che **nessun hook può invocare una skill**. Un hook esegue un comando di shell, e una skill è una procedura che esegue l'agente. Per questo l'apertura di sessione non invoca `sync-context`: stampa in contesto l'istruzione di invocarla, e l'agente la esegue. È automatico nella pratica e non garantito nel meccanismo, e la differenza va conosciuta: se una sessione salta quel passo, lo si vede perché il recap iniziale non nomina il drift.

La seconda è che i due hook sul `git commit` vedono **il commit dell'agente**, non il tuo. In questo sistema le operazioni git restano dell'utente, quindi il caso normale è che i tuoi commit non passino di lì. Per coprirli serve un hook nativo di git, cioè `core.hooksPath`, e il README di `hooks-starter` spiega come. Finché non lo si fa, quei due hook valgono come rete per il caso in cui un progetto allenti il divieto di commit all'agente, non come garanzia sui tuoi.

La terza riguarda la chiusura. Un hook `SessionEnd` gira quando la sessione si chiude, comprese le chiusure ordinate, ma **non gira quando il processo muore davvero**, per un crash o per la corrente che manca. È esattamente il comportamento che serve: copre la chiusura distratta, cioè la finestra chiusa senza aggiornare il file di ripresa, e lascia scoperta la caduta vera, che è la cosa che si vuole restare visibile alla sessione successiva.

## Che cosa devi digitare tu

Le skill si invocano digitando il loro nome preceduto dalla barra, nel terminale di Claude Code. Sono procedure che esegue l'agente, e nessuna di esse parte da sola.

| Digiti | Che cosa fa | Quando |
|---|---|---|
| `/riprendi` | Verifica che il file di ripresa descriva il presente, poi ricostruisce il punto di ripresa | Primo atto di ogni sessione, se non hai registrato l'hook di apertura |
| `/sync-context` | Misura il drift fra le schede di `.claude/context/` e il codice, e propone i delta | Secondo atto di ogni sessione; dopo un `git pull`; dopo modifiche significative |
| `/gate-pacchetti` | Riconosce i settori del progetto e propone i pacchetti pertinenti uno per uno | A ogni tornata di allineamento, e quando l'obiettivo del progetto cambia |
| `/repo-status` | Riepilogo di branch, commit recenti, file modificati, differenze non committate | Quando vuoi lo stato senza altro |
| `/git-sync` | Prepara le operazioni git e ti consegna i comandi da eseguire | Prima di committare |
| `/onboard` | Spiega il progetto da zero leggendo schede, memoria e decisioni | Quando entra qualcuno, o quando rientri dopo mesi |
| `/studio-didattico` | Aggiunge una voce al racconto evolutivo e la sua scheda di dettaglio | A ogni refactor o scelta di qualità non ovvia, se il progetto ha adottato la pratica |
| `/hooks` | Mostra quali hook sono registrati davvero | Dopo aver registrato un hook, per verificare che ci sia |

Gli strumenti si lanciano invece come programmi, dalla radice del progetto. Il percorso è quello che hanno **dopo l'istanziazione**, cioè dentro `tools/` del progetto ospite; nel repository del template vivono sotto `.claude/templates/`, e là si eseguono solo per provarli.

| Lanci | Che cosa fa |
|---|---|
| `python tools/verifica-ripresa.py` | Confronta l'impronta con lo stato reale e dice che cosa diverge |
| `python tools/verifica-ripresa.py --registra` | Registra l'impronta; ultimo atto della sessione, dopo i commit |
| `python tools/md-unwrap.py <file o cartella>` | Riporta i paragrafi su riga sorgente unica |
| `python tools/md-unwrap.py --check --oracle require .` | Verifica senza scrivere; esce diverso da zero se qualcosa non rispetta la convenzione |
| `python tools/fix-accents.py --check .` | Accenti scritti con l'apostrofo |
| `python tools/fix-missing-accents.py --check .` | Accenti mancanti del tutto, con i casi indecidibili dichiarati |
| `python tools/fix-dashes.py --check .` | Trattini lunghi e segni che somigliano a un trattino |
| `python tools/lint-md-commands.py .` | Comandi spezzati dentro i blocchi di codice, che non si copiano in una riga sola |
| `python tools/lint-doc-references.py --solo-vivi` | Documenti vivi che nominano file inesistenti |
| `python tools/costruisci-timeline.py` | Rigenera la linea temporale del progetto |
| `python tools/costruisci-timeline.py --senza-ragione` | Elenca i microstep senza una ragione dichiarata |
| `python tools/Test-Allineamento.py` | Le affermazioni che stanno invecchiando: scadenze, misure vecchie, invarianti |
| `python tools/Test-Anonymization.py` | Dati che identificano persone, luoghi e infrastrutture reali |
| `python tools/lint-didattica.py` | Voci di work-log senza didattica dichiarata, e schede orfane |
| `python tools/indice-refactor.py` | Rigenera l'indice per argomento delle schede didattiche |

E due strumenti che non stanno in `tools/` del progetto perché riguardano la macchina e non il progetto, e si eseguono dal bundle:

```
python .claude/templates/tools/detect-ssh-profiles.py --repo .
powershell -NoProfile -ExecutionPolicy Bypass -File .claude/templates/tools/check-account-hygiene.ps1
```

## Le regole: che cosa vuol dire "usarle"

Questa è la domanda che `chat-non-e-memoria.md` solleva, e vale per tutte le regole sotto `.claude/rules/`, quindi conviene rispondere una volta sola.

Una regola non si lancia e non si invoca. È un file Markdown che entra nel contesto della sessione e cambia il comportamento dell'agente, e il modo in cui la si "usa" è che esista nel progetto e sia indicizzata. Non c'è un comando, non c'è un momento in cui si attiva: se il file c'è, la regola è in vigore.

Per `chat-non-e-memoria.md` in particolare, ciò che la regola prescrive è un comportamento dell'agente e ha un **osservabile preciso**, che è il modo in cui puoi verificare che stia funzionando invece di sperarlo. La regola dice che nessun contenuto sostanziale resti nella sola conversazione: un numero misurato va in un documento, una correzione nel work-log, una decisione nel registro come ADR, un lavoro rimandato fra le pendenze, una fonte nel registro delle fonti. E dice che l'aggiornamento avvenga nel medesimo giro di lavoro in cui il contenuto nasce, non a fine sessione quando il contesto è pieno e l'attenzione bassa.

L'osservabile è l'ultima riga: **alla fine di ogni giro di lavoro sostanziale l'agente dichiara quali file ha scritto**. Quella riga è il presidio della regola. Se c'è, il contenuto è su disco; se manca, il contenuto è rimasto in chat ed è già perduto, anche quando la risposta era ottima. Quindi il modo in cui usi questa regola è: leggere quella riga, e quando non c'è, chiederla.

Una seconda cosa la regola la dice e vale ripeterla qui perché è la parte che sorprende: l'agente **non** scrive di propria iniziativa in `.claude/memory/` e in `.claude/context/`. Propone il delta e lo applica quando glielo chiedi, perché il versionamento della memoria resta sotto controllo umano. L'eccezione dichiarata riguarda i documenti di conoscenza, cioè studi, censimenti e registri di fonti, che l'agente scrive sempre: là il rischio è opposto, ed è che il contenuto resti in chat.

## Il ciclo di una sessione, nella forma concreta

All'apertura, se hai registrato l'hook, la verifica e lo stato arrivano da soli e ti trovi davanti un recap. Se non lo hai registrato, digiti `/riprendi`. In entrambi i casi il passo successivo è `/sync-context`, che l'hook chiede all'agente di fare e che puoi sempre digitare tu.

Se la verifica ha trovato divergenze, l'agente deve riportarle **prima** di leggere il file di ripresa e prima di cominciare. La regola in questa situazione è che non decide: un file lasciato a metà può essere un lavoro da riprendere o uno da buttare, e la differenza non si legge dal contenuto. Se l'agente comincia a lavorare senza avertele riportate, fermalo.

Durante il lavoro vale la regola sulla persistenza appena descritta, con il suo osservabile.

Alla chiusura l'ordine conta e vale scriverlo per esteso, perché è l'unico punto della guida in cui invertire due passi produce un falso allarme ricorrente. Prima l'agente aggiorna `_notes/RESUME-PROMPT.md` con lo stato raggiunto e il prossimo passo. Poi esegui i tuoi commit. Solo dopo si registra l'impronta, con `python tools/verifica-ripresa.py --registra` oppure lasciandolo fare all'hook di chiusura. Registrare prima dei commit produce alla sessione successiva una divergenza che non è una caduta ma una registrazione fatta troppo presto, e un falso positivo ricorrente insegna a ignorare il controllo, che è il modo in cui un presidio muore.

## Il calendario, con la colonna che conta

| Cadenza | Che cosa | Parte da solo? | Altrimenti |
|---|---|---|---|
| Ogni apertura di sessione | Verificare che il file di ripresa descriva il presente | sì, con l'hook `apertura-sessione` | `/riprendi` |
| Ogni apertura di sessione | Misurare il drift fra schede e codice | l'hook lo chiede all'agente, che lo esegue | `/sync-context` |
| Ogni giro di lavoro sostanziale | Scrivere su disco ciò che è nato in chat | sì, è la regola `chat-non-e-memoria.md` in vigore | verifichi la riga che dichiara i file scritti |
| Ogni file `.md` scritto | Paragrafi su riga sorgente unica | sì, con l'hook `md-unwrap-auto` | `python tools/md-unwrap.py <file>` |
| Prima di un commit | I quattro controlli di convenzione | sui commit dell'agente sì, con `pre-commit-checks`; sui tuoi solo con un hook nativo di git | lanci i quattro comandi della tabella sopra |
| Prima di un commit | Segreti nel diff in stage | come sopra, con `secret-scan` | `git diff --cached` e lo guardi |
| Ogni chiusura di sessione | Registrare l'impronta | sì, con l'hook `chiusura-sessione` | `python tools/verifica-ripresa.py --registra` |
| Ogni chiusura di sessione | Ripulire il magazzino nascosto dell'account | sì, con il wipe registrato nell'account | vedi la sezione sulla memoria |
| Ogni tornata di allineamento | Riattraversare il gate dei pacchetti | no | `/gate-pacchetti` |
| Periodicamente | Microstep senza ragione dichiarata | no | `python tools/costruisci-timeline.py --senza-ragione` |
| Periodicamente | Affermazioni che invecchiano | no | `python tools/Test-Allineamento.py` |
| Una volta per macchina | Igiene dell'account e profili SSH | no | i due comandi dal bundle |

## Diagnosi: dal sintomo allo strumento

Qui la risposta alla domanda "si lancia automatico?" è: quasi mai, e per una ragione che vale capire. Un controllo che gira a ogni sessione su tutto costa tempo e produce rumore; questi si lanciano quando un sintomo li rende pertinenti, ed è il sintomo a dire quale. Le due eccezioni sono marcate nella colonna a destra.

| Sintomo | Che cosa sta succedendo | Che cosa lanci |
|---|---|---|
| "Non ricordo dove eravamo, e il file di ripresa sembra vecchio" | Una sessione è caduta senza chiudersi | automatico all'apertura con l'hook; altrimenti `/riprendi` |
| "La documentazione descrive un file che non trovo" | Una fotografia invecchiata in un documento vivo | `python tools/lint-doc-references.py --solo-vivi` |
| "Le schede non corrispondono più al codice" | Drift fra documentazione e commit | `/sync-context` |
| "Perché a marzo abbiamo scelto questa libreria?" | Il fatto è registrato, la ragione no | `python tools/costruisci-timeline.py`, poi apri `docs/TIMELINE.html` |
| "Questo documento dice una cosa che forse non è più vera" | Un'affermazione con una scadenza implicita | `python tools/Test-Allineamento.py` |
| "Il diff è pieno di righe che nessuno ha toccato" | Paragrafi hard-wrapped che si ri-avvolgono | automatico a ogni scrittura con l'hook; altrimenti `python tools/md-unwrap.py .` |
| "Questo comando incollato si è spezzato in due" | Una continuazione di riga dentro un blocco di codice | `python tools/lint-md-commands.py .` |
| "Sto per rendere pubblico il repository" | Dati che identificano persone o infrastrutture | `python tools/Test-Anonymization.py` |
| "Il commit è partito con l'email sbagliata" | Identità git non impostata a livello locale | `python .claude/templates/tools/detect-ssh-profiles.py --repo .` |
| "Questa fonte esiste ma non riesco a leggerla" | Una fonte fuori dalla portata degli strumenti di sessione | leggi `.claude/rules/web-sources-not-fetchable.md`, poi gli strumenti di `community-sources` |
| "La sessione consuma troppo contesto" | Prima si misura, poi si interviene | `ccusage`, poi il settore dell'economia del contesto |
| "Ho un video e nessuna trascrizione" | Sottotitoli se ci sono, riconoscimento vocale se no | `python tools/vtt-to-text.py FILE.vtt`, altrimenti `python tools/trascrivi.py VIDEO --nome fonte` |

## Le ricette: che cosa Claude capisce da solo e che cosa no

La domanda è legittima e la risposta onesta è: **capisce i settori, non sceglie i pacchetti**.

Quando incolli il prompt iniziale e descrivi il progetto, la skill `gate-pacchetti` usa quella descrizione insieme ai fatti che legge sul disco, cioè quali linguaggi ci sono, se esista una cartella di documenti o di fonti, quanto è lunga la storia git, quanti server MCP sono già configurati. Da lì ricava a quali dei dieci settori il progetto appartiene, e **te li dichiara con il fatto da cui li ha riconosciuti**, perché tu possa correggerli. Un settore che aggiungi si attraversa, uno che togli si salta con la ragione registrata.

Quello che non fa, e non deve fare, è decidere. Dentro un settore riconosciuto ogni pacchetto arriva con tre frasi, cioè che cosa fa, perché a questo progetto potrebbe servire legando la ragione a un fatto del tuo repository invece che a una categoria generica, e che cosa costa, comprese le capacità che duplicherebbe. Poi chiede, e un silenzio non è un sì.

Le ricette che seguono sono quindi una scorciatoia per te, non un comportamento dell'agente: servono a farti riconoscere il tuo caso prima che il gate te lo chieda, così la conversazione è di conferme invece che di scoperte. Ciascuna dichiara che cosa lascia fuori, perché è la parte che si dimentica.

**Un progetto di codice che durerà mesi.** Motore completo, più `stack-profiles` per le convenzioni dello stack riconosciuto, `hooks-starter` con i quattro hook di ciclo registrati, `dev-skills` scegliendo caso per caso e dichiarando la sovrapposizione con le skill native, `github-mcp` se il lavoro passa da pull request e issue, `context7` se lo stack evolve in fretta, e `ccusage` come misura di partenza. Resta fuori tutto il settore delle fonti, e resta fuori l'orchestrazione finché non ci sono tre rami paralleli davvero.

**Un progetto documentale, una tesi, un libro.** Motore completo, più `md-unwrap` e `fix-typography` che qui sono quasi obbligatori perché la prosa è il prodotto, `docx-to-docs` o `doc-ingest` secondo che il materiale sia un documento voluminoso o un corpus, `latex` se l'uscita è composta tipograficamente, `academic-researcher` se c'è una bibliografia, `humanizer` per la prosa destinata a un lettore esterno, e `documentazione-didattica` se chi scrive vuole anche imparare rileggendo. Resta fuori tutto ciò che riguarda il codice.

**Un progetto ereditato, di cui non conosci la struttura.** Prompt di allineamento, poi `code-context` come primo strato perché costa poco e dà struttura e simboli. Si sale di profondità solo se serve: `repomix` per una vista consolidata iniziale, `serena` per la navigazione a livello di simbolo, `codebase-memory-mcp` per il grafo delle chiamate su un repository davvero grande, `codebase-learning` se l'obiettivo è capirlo e non solo modificarlo. La tentazione da evitare è attivarli tutti: sono quattro indici dello stesso codice, e su un progetto piccolo tre sono rumore.

**Un progetto che raccoglie fonti di community.** `community-sources` con i suoi sei strumenti, e la regola `web-sources-not-fetchable.md` che ne è il criterio: il pacchetto è lo strumento, la regola dice quale via scegliere. Si aggiunge `voicestudio` se fra le fonti ci sono video senza sottotitoli. Resta fuori la tentazione di esportare tutto: la ricerca mirata dentro il canale, fatta da chi conosce la domanda, rende più di un export in blocco, perché il filtro incorpora la domanda.

**Un progetto scientifico.** `scientific-skills` per la mappa, poi una skill per volta dalla porzione che riguarda la tua disciplina, seguendo la procedura in quattro mosse invece di installare in blocco. Si decide se tenere la catena bibliografica di quella raccolta oppure `academic-researcher`, e la scelta si registra: due sistemi di citazioni che convivono producono due bibliografie che divergono.

**Un progetto lungo seguito da una persona sola.** È il caso in cui i registri valgono di più, perché l'unica persona che sa perché una cosa è fatta così è anche l'unica che se ne dimenticherà. `operations-log` per i microstep con la loro verifica, `documentazione-didattica` per il perché di una scelta contro l'alternativa scartata, `timeline-progetto` per leggerli come una storia sola, `alignment` per le affermazioni che invecchiano. È anche il caso in cui gli hook di ciclo contano di più, perché nessun altro si accorgerà che una sessione è caduta.

## La memoria del progetto, strato per strato

Questa sezione risponde alla domanda che tiene insieme tutto il sistema: dove finisce ciò che sai del progetto, che cosa sopravvive a un clone, e che cosa viene cancellato e quando. Il principio è uno solo, e le quattro sezioni che seguono sono le sue conseguenze: **la memoria del progetto vive dentro la cartella del progetto, e tutto ciò che si accumula altrove è materiale transitorio da ripulire.**

Il modo di verificare che il principio regga è secco, e conviene usarlo davvero ogni tanto: clona il repository in una cartella nuova, aprilo, e chiediti se basta. Se per capire lo stato serve qualcosa che nel clone non c'è, quella cosa è nel posto sbagliato.

### Strato uno: dentro il repository, tracciato

È la memoria vera, l'unica che sopravvive a un clone, ed è versionata sotto controllo umano.

```
.claude/memory/index.md        snapshot: branch, commit di riferimento, stato di verifica delle schede, punto di ripresa
.claude/memory/progress.md     work-log append-only: ogni passo con data, file toccati, motivo, commit
.claude/memory/decisions.md    registro ADR-lite: le decisioni architetturali, numerate e mai riscritte
.claude/context/*.md           schede tecniche con frontmatter ancorato a un commit
CLAUDE.md                      indice dei satelliti e procedura di ripresa
docs/                          documenti generati che il progetto decide di versionare
```

Non viene cancellato da niente e da nessuno. Cresce, e l'unico presidio è che non diverga dal codice, che è il mestiere di `sync-context`. L'agente non vi scrive di propria iniziativa: propone il delta e lo applica quando glielo chiedi.

### Strato due: dentro il repository, ignorato da git

È il privato del progetto: sta nella tua cartella, non entra in nessun clone, e non esce dalla tua macchina.

```
_notes/                        materiale grezzo, appunti, stati di lavorazione
_notes/RESUME-PROMPT.md        stato raggiunto e prompt di ripresa, con l'impronta in coda
_notes/fonti/                  fonti procurate a mano, trascrizioni, corse dei lettori di fonti
_notes/.tmp-doc-*/             estratti temporanei di documenti voluminosi
.tmp-skills/                   copia locale di raccolte di skill di terze parti
CLAUDE.local.md                preferenze personali di sessione
.claude/settings.local.json    permessi personali, non condivisi
```

Il `.gitignore` li esclude, e il blocco che li esclude arriva da `templates/gitignore.snippet`: va unito **prima** di creare `_notes/`, altrimenti la cartella finisce indicizzata e toglierla dopo è un'operazione sulla storia. Nessuno li cancella automaticamente: li cancelli tu quando non servono più, e la regola per il materiale grezzo di terzi è di eliminarlo quando la sintesi con l'attribuzione lo ha reso superfluo.

La conseguenza da tenere presente è che questo strato **non sopravvive a un clone**, ed è voluto: se qualcosa che sta qui serve a capire il progetto, va promosso allo strato uno.

### Strato tre: fuori dal repository, nella home dell'account Claude

È lo strato che nessuno guarda, ed è quello per cui esiste metà della disciplina di questo sistema. Claude Code accumula per conto proprio, sotto la directory di configurazione dell'account, che è `%USERPROFILE%\.claude` per difetto oppure la cartella indicata da `CLAUDE_CONFIG_DIR` quando si usano più profili.

```
<CLAUDE_CONFIG_DIR>/projects/<slug-del-percorso>/   trascrizioni JSONL di ogni sessione su quel progetto, e la auto-memory nativa
<CLAUDE_CONFIG_DIR>/history.jsonl                   la cronologia dei prompt digitati
<CLAUDE_CONFIG_DIR>/todos/                          le liste di cose da fare per sessione
<CLAUDE_CONFIG_DIR>/shell-snapshots/                istantanee dell'ambiente di shell
<CLAUDE_CONFIG_DIR>/file-history/                   copie dei file prima delle modifiche
<CLAUDE_CONFIG_DIR>/plans/, tasks/, jobs/           piani, task e lavori in background
<CLAUDE_CONFIG_DIR>/paste-cache/, backups/, cache/  materiale incollato e copie di servizio
<CLAUDE_CONFIG_DIR>/sessions/, session-env/, ide/   stato di sessione e integrazione con l'editor
<CLAUDE_CONFIG_DIR>/statsig/, telemetry/            cache di telemetria
<CLAUDE_CONFIG_DIR>/.claude.json                    configurazione, con dentro una mappa 'projects' che tiene una storia per progetto
```

Lo slug è il percorso assoluto del progetto reso in forma di nome di cartella: su Windows `E:\mio-progetto` diventa `E--mio-progetto`, su Linux deriva dal percorso assoluto e non ha quella forma. È il dettaglio che rende specifica della macchina qualunque configurazione che lo nomini, ed è la ragione per cui lo script di wipe esce dal template con i prefissi a segnaposto invece che con un default.

Di tutto questo, la cosa che conta di più è la prima riga: le trascrizioni di ogni sessione. Sono il testo integrale di ciò che è stato detto, e su un progetto lungo diventano decine di megabyte. Non sono memoria del progetto, sono la registrazione delle conversazioni, e vivono fuori dal repository, cioè in un posto che nessun clone vede e nessun collaboratore ha.

### Come lo strato tre viene ripulito, e la cosa che non funziona

Si ripulisce con `session-end-wipe`, che si installa **una volta per macchina** nella home dell'account e si registra come hook `SessionEnd` del `settings.json` dell'account, non del progetto. A ogni chiusura di sessione rimuove le trascrizioni e la memoria nascosta dei progetti non preservati, gli store effimeri dell'elenco sopra, la cronologia dei prompt, e dalla mappa `projects` del `.claude.json` le voci dei percorsi non preservati.

Che cosa preserva, sempre: i progetti il cui slug comincia con uno dei prefissi che hai dichiarato, la configurazione, il login, le skill, i plugin, gli hook e lo stato del daemon. E non tocca mai i file dei progetti su disco: agisce solo dentro la home dell'account.

I prefissi da preservare non si indovinano, e lo script si rifiuta di partire se non li hai compilati. L'ordine corretto è elencare, scegliere, provare a vuoto, e solo allora registrare l'hook.

```
powershell -NoProfile -ExecutionPolicy Bypass -File "<CLAUDE_CONFIG_DIR>\hooks\session-end-wipe.ps1" -List
powershell -NoProfile -ExecutionPolicy Bypass -File "<CLAUDE_CONFIG_DIR>\hooks\session-end-wipe.ps1" -DryRun
```

E qui va detta la cosa che non funziona, perché è documentata e non è un difetto da nascondere: **l'hook `SessionEnd` è best-effort**. Claude Code può riscrivere alcuni file di sessione dopo che l'hook è già scattato, quindi la coda dell'ultima sessione può sopravvivere fino alla chiusura successiva. La conseguenza pratica è che il wipe automatico non basta da solo: dopo aver chiuso Claude, per la pulizia garantita anche sulla coda dell'ultima sessione, si rilancia lo script a mano.

```
powershell -NoProfile -ExecutionPolicy Bypass -File "<CLAUDE_CONFIG_DIR>\hooks\session-end-wipe.ps1"
```

Che l'account sia in regola si verifica in sola lettura, e il controllo guarda tre cose: che la auto-memory nativa sia disattivata, che l'hook di wipe sia registrato, e che lo script installato sia configurato per **questa** macchina e non per un'altra, il che è la firma di una configurazione copiata da altrove.

```
powershell -NoProfile -ExecutionPolicy Bypass -File .claude/templates/tools/check-account-hygiene.ps1
```

### Strato quattro: quello che si spegne invece di ripulire

La auto-memory nativa di Claude Code è una memoria che l'agente scrive di sua iniziativa nel magazzino nascosto dello strato tre. Il sistema la disattiva con `"autoMemoryEnabled": false` nel `settings.json` del progetto, e la ragione è la stessa del principio generale: quella memoria non vive nel repository, non è versionata, resta solo sulla macchina, e quindi viola la recuperabilità totale da un clone.

Spegnere è meglio che ripulire, perché una cartella che non si riempie non ha bisogno di essere svuotata, e il wipe resta come seconda difesa per ciò che si fosse accumulato prima. La scelta però non è imposta una volta per tutte: a ogni progetto, e a ogni sessione, la domanda si pone esplicitamente, e chi vuole la memoria nativa per una sessione può portare il flag a `true` con l'impegno di riportarlo a `false` prima di chiudere o di cambiare progetto.

Chi preferisce imporre la regola a livello di macchina imposta lo stesso flag nel `settings.json` dell'account, oppure esporta `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1`.

### Il riassunto in tre righe

Ciò che il progetto sa di sé sta nello strato uno, è versionato, e sopravvive a un clone. Ciò che serve solo a te sta nello strato due, è ignorato da git, e lo cancelli quando vuoi. Ciò che Claude accumula per conto suo sta nello strato tre, fuori dal repository, e viene ripulito a ogni chiusura più una volta a mano; lo strato quattro è la parte di quell'accumulo che il sistema preferisce non far nascere affatto.

## Le tre cose che il sistema si rifiuta di fare, e perché

Non committa e non pusha mai. L'agente prepara i file e consegna i comandi; le operazioni di version control restano dell'utente. Non è diffidenza verso lo strumento ma la sola garanzia che nessuna modifica entri nella storia senza che una persona l'abbia guardata.

Non scrive di propria iniziativa nella memoria e nelle schede, per la ragione già detta sopra.

Non lascia che la memoria del progetto viva fuori dal progetto, che è l'intera sezione precedente.

## Che cosa leggere quando

`README.md` è il riferimento: che cosa esiste, con i crediti e l'indice dei README dei pacchetti. `.claude/PROJECT-SYSTEM.md` è la norma, e vince su tutto il resto quando divergono. `.claude/rules/` sono le regole sempre caricate, e sono la parte che cambia davvero il comportamento di una sessione. `.claude/templates/PACKAGES.md` è il catalogo, diviso per settore. `.claude/templates/hooks-starter/README.md` spiega ogni hook e come registrarlo. `CASE-STUDIES.md` racconta che cosa è stato provato sul campo, compreso ciò che non ha funzionato. `docs/feature-map.html` e `docs/project-flow.html` sono le due mappe visive.

E questo documento è la risposta alla domanda che nessuno degli altri risponde, cioè che cosa parte da solo, che cosa devi digitare, e dove finisce ciò che il progetto sa di sé.
