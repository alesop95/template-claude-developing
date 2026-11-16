# Filone: il nativo dei client prima delle skill scritte

> Voce 1.3 di `docs/piano-potenziamento-2026-11.md`, dal mandato del proprietario del 2026-11-12: «se una parte si realizza già nativamente si usa». Confronta ciò che Claude Code e Codex offrono da sé con le diciannove skill di sistema del template e con i suoi pacchetti che toccano la revisione del codice. Chiuso il 2026-11-16 come osservazione con tre conseguenze pratiche. Indice dei filoni in `docs/FILONI.md`.

## Che cosa è stato letto, e come

Un subagent ha letto il 2026-11-16 le documentazioni ufficiali dei due client: per Claude Code le pagine dei comandi, delle skill, dei subagent, degli hook e della memoria su web:https://code.claude.com/docs/en/commands ; per Codex la pagina dei comandi e quelle di skill, subagent, hook e `AGENTS.md`, che dall'indirizzo storico rinviano a web:https://learn.chatgpt.com/docs/developer-commands . Due limiti vanno detti. Solo la pagina dei comandi di Claude Code è stata letta per intero; le altre fino ai primi centomila caratteri. E l'elenco dei comandi di Codex è arrivato come riassunto dello strumento di lettura, quindi le sue descrizioni sono parafrasi e non citazioni. Il giudizio «copre, copre in parte, non copre» è un'inferenza dall'assenza di un meccanismo nelle pagine lette, non una frase delle documentazioni.

## L'esito in una riga

Nessuna delle diciannove skill di sistema è un doppione di un meccanismo nativo. Nove non hanno alcun equivalente, dieci ne hanno uno parziale, e in tutti e dieci i casi la parte nativa è il gesto e la parte del template è la regola che lo governa.

## Dove il nativo copre una parte

La ripresa. Entrambi i client riaprono una conversazione, con `/resume` e i suoi parenti, e Claude Code riporta indietro codice e conversazione con `/rewind`. Nessuno dei due verifica che un file di ripresa descriva ancora lo stato del repository, che è ciò che fa `riprendi` con l'impronta. Sono due cose diverse e convivono: il nativo riapre la chat, la skill dice se credere a ciò che la chat ricorda.

Lo stato del repository. `/diff` esiste in entrambi e mostra le modifiche non committate; ramo e commit recenti non hanno un comando. `repo-status` resta, ed è la skill più vicina a un doppione: se un giorno i client aggiungono il riepilogo, è la prima da togliere.

La creazione di un agente. In Claude Code si chiede al modello di scrivere il file sotto `.claude/agents/`, e la pagina documenta il front matter; in Codex l'agente è un file TOML sotto `.codex/agents/`. La parte che `crea-agente` aggiunge è leggere il progetto, dire che cosa ha capito e chiedere solo ciò che manca. Conseguenza pratica, la prima: la skill oggi scrive il solo formato di Claude Code, e la parità chiede che scriva anche il file TOML di Codex quando il progetto ha scelto Codex. È un lavoro piccolo e non è fatto.

Gli alberi di lavoro. Entrambi i client creano alberi di lavoro, Claude Code per i subagent isolati e Codex con `/worktree`. Nessuno dice da quale albero leggere la memoria versionata, e la memoria automatica di Claude Code è per dichiarazione condivisa fra gli alberi dello stesso repository, cioè il contrario di ciò che `alberi-di-lavoro` prescrive per la memoria di un ramo. Il template la tiene spenta, e questa lettura conferma il perché.

Il piano e i passi. `/plan` e `/goal` esistono in entrambi. `micro-passi` aggiunge la prova per passo, che non è nativa. L'inizializzazione: `/init` scrive un file di istruzioni iniziale, `init-project-system` istanzia memoria, regole e schede. La memoria: i file di istruzioni e le memorie automatiche dei due client ricordano, ma fuori dal repository e senza versione; `memoria-di-progetto` è dentro il repository per scelta. La prova: `/verify` di Claude Code esegue una modifica e osserva che cosa succede, ed è il gesto; `prove-che-misurano` è il criterio per decidere se quella prova misura il difetto. La pipeline: i client installano un'integrazione con la CI, `pipeline-app` decide quali controlli servono.

## Dove il nativo copre tutto, fuori dalle skill di sistema

La revisione del codice e quella di sicurezza sono native in Claude Code, con `/code-review` e `/security-review`, e Codex ha `/review`. Il template non ha una skill di sistema che le duplichi, ma il pacchetto `subagent-template` offre due agenti di esempio, `code-reviewer` e `security-auditor`. Conseguenza pratica, la seconda: al gate quei due agenti si propongono solo dove il progetto vuole un revisore con istruzioni proprie del dominio, e per la revisione ordinaria si indica il comando nativo. La riga di catalogo va precisata in questo senso alla prossima modifica del pacchetto. Per Codex una revisione di sicurezza nativa non è stata trovata nelle pagine lette, quindi lì l'agente del pacchetto conserva una ragione in più.

## Ciò che la lettura ha mostrato in più

Tre fatti che non rispondono alla domanda ma servono alla parità. Codex ha hook con eventi quasi sovrapponibili a quelli di Claude Code, compresi l'avvio e la fine della sessione e il momento prima dell'uso di uno strumento, e li esegue solo se la cartella `.codex` del progetto è fidata e dopo un'approvazione. Conseguenza pratica, la terza: alcune cose che oggi il template fa per Codex con un wrapper, cioè la pulizia all'uscita e la riserva dei subagent decisa all'avvio, potrebbero farsi con un hook nativo, che vale anche per una sessione avviata senza il wrapper. Non è stato provato, ed è il prossimo passo del filone sulla parità: prima si verifica dal vero che un hook di Codex possa negare l'avvio di un subagent.

Entrambi i client importano la configurazione dell'altro, con `/import`. Il template genera gli adattatori di Codex da sé e non ne ha bisogno, ma è la via per chi adotta il template partendo da un progetto che ha già una configurazione dell'altro client.

Codex cerca le skill in `.agents/skills`, che è dove il template scrive già gli adattatori, e ha due skill incorporate per crearne e installarne.

## Limiti

Le versioni dei client installate sulla macchina non sono state confrontate con quelle delle pagine. Nessun comando nativo è stato eseguito per questo confronto. La pagina delle memorie di Codex e quella delle sue attività programmate non sono state aperte.
