# template-claude-developing

Sistema portabile di contesto, documentazione e version control per progetti gestiti con Claude Code. Si installa nella radice di un progetto e fa in modo che lo stato del progetto resti interamente recuperabile dal repository in qualsiasi momento e da chiunque lo cloni. La sessione di chat e effimera e si perde alla chiusura; cio che persiste e il contesto strutturato su disco, riletto in automatico a ogni nuova sessione aperta nella stessa cartella.

Questo file e il README della repository GitHub. Serve a far capire cos'e il template a chi lo trova su GitHub. Non viene copiato nei progetti quando si lancia uno dei due prompt: quei prompt importano solo lo standard e il motore, non questo README. Ogni volta che si aggiunge una funzionalita al template, questo README va aggiornato di conseguenza.

## A cosa serve

L'obiettivo e disporre di una base di conoscenza che si aggiorna a ogni avanzamento dello sviluppo, in modo che ogni passo di codice e ogni intervento manuale lascino una traccia versionata e riconciliata, senza dover rileggere per intero la documentazione a ogni sessione. Ogni feature segue lo stesso ciclo: si descrivono gli obiettivi, si produce un piano, si analizzano pro e contro con le mitigazioni, si risolvono le incertezze con domande mirate, e solo allora si implementa. A feature completata si fissa la logica in un documento permanente, si aggiorna il work log e si riallineano le schede tecniche al codice.

## Come si usa

Il punto di ingresso sono i due prompt fissi sotto `.claude/`, da incollare in Claude Code dentro la radice del progetto di destinazione.

`.claude/PROMPT-nuovo-progetto.md` inizializza un progetto nuovo o quasi vuoto. Importa il bundle dello standard e del motore dentro il `.claude` del progetto, poi esegue la skill di inizializzazione che crea l'anatomia minima istanziando i template.

`.claude/PROMPT-allinea-progetto-esistente.md` allinea retroattivamente allo standard un progetto che ha gia codice e storia git, senza riscrivere la storia e senza inventare contenuto. Fa l'inventario di cio che esiste, ricostruisce la memoria dalla storia dei commit, e crea le schede mancanti leggendo il codice attuale.

Entrambi i prompt si fermano a chiedere conferma prima di ogni azione difficilmente reversibile o che tocca il version control, e non eseguono mai `git add`, `commit` o `push`: preparano i file e lasciano le operazioni git all'utente.

## Cosa viene installato in un progetto

La cartella `.claude/` e il centro di controllo del progetto, tenuto all'essenziale. La struttura canonica, da adottare nella forma minima e da estendere solo quando serve, e descritta per intero in `.claude/PROJECT-SYSTEM.md`. In sintesi un progetto inizializzato ottiene un `CLAUDE.md` di radice che indicizza i file satellite tracciati, un `CLAUDE.local.md` ignorato per gli override personali, e sotto `.claude/` le cartelle `rules`, `skills`, `agents`, `commands`, l'eventuale `hooks`, una cartella `memory` con `index.md`, `progress.md` e `decisions.md`, e una cartella `context` con le schede tecniche `STACK.md`, `design-and-security.md`, `deployment.md`, `dev-testing.md`, `current-work.md`, `roadmap.md` e i diagrammi. Il livello privato e verboso vive in `_notes/`, ignorato da git.

## I due livelli documentali

Il sistema separa cio che e tracciato da cio che resta locale, con un principio unico. Un documento e tracciato se e conoscenza tecnica che un qualsiasi contributore deve poter recuperare da un clone ed e sicuro pubblicarlo. Resta in `_notes/`, ignorato, se e narrativa personale, materiale transitorio o contenuto sensibile. Questo garantisce la recuperabilita totale, perche tutto cio che serve a ricostruire lo stato finisce nei commit, mentre in locale resta solo il rumore.

## Il motore di riconciliazione

Ogni scheda tecnica tracciata porta in testa un blocco di metadati che la ancora a un commit e ne misura la divergenza rispetto allo stato attuale del repository. La skill `sync-context` legge l'ultimo commit verificato e i percorsi coperti da ciascuna scheda, esegue un confronto ristretto a quei percorsi, e classifica la scheda come aggiornata, da aggiornare oppure obsoleta, proponendo un intervento mirato senza mai rigenerare i documenti da zero e senza scrivere su git. A ogni passo significativo si aggiornano le schede impattate, si porta avanti il commit di verifica, si aggiorna lo snapshot in `memory/index.md` e si appende una voce a `memory/progress.md`.

## Ripresa di una sessione

A inizio sessione lo stato si recupera leggendo per primo `.claude/memory/index.md`, che da il branch, il commit di riferimento, lo stato di verifica di ogni scheda e il punto di ripresa come prossima azione concreta. Si legge poi `context/current-work.md` se c'e una feature attiva, si invoca `sync-context` per misurare la divergenza, e si leggono solo le schede pertinenti al task. Il prompt di ripresa privato `_notes/RESUME-PROMPT.md` si aggiorna alla fine di ogni sessione con lo stato raggiunto e con il prompt da incollare alla riapertura.

## Ingestione di documenti .docx

Un documento di contesto voluminoso non si legge mai per intero. Si estrae il contenuto una sola volta in una cartella scratch ignorata e si caricano solo le porzioni utili al task. La data di riconciliazione, il nome del documento sorgente e l'esito si annotano in `memory/progress.md`. Sono previste anche le direzioni inverse, da repository a Word per i deliverable e da Word a mirror Markdown versionato quando il Word e la fonte di verita umana.

## Igiene del version control e identita git

Prima di considerare sano un repository si verifica che non siano rimasti file indicizzati per errore e soprattutto che non siano mai stati committati segreti, controllando i file tracciati e l'intera storia dei commit. La regola `.claude/rules/git-identity-and-repo.md` definisce come impostare sempre l'identita git a livello locale di repository, come collegare il remoto tramite l'alias SSH corretto, e come proteggersi con `user.useConfigOnly` dal commit con l'identita sbagliata su una macchina con piu profili.

La convenzione degli alias SSH, ad esempio `github-personal` per l'identita personale e `github-corp` per quella di lavoro, e uno schema riusabile su qualsiasi macchina: si possono adottare gli stessi nomi ovunque. I valori concreti dietro ogni alias, ovvero il percorso della chiave, lo `user.name` e lo `user.email`, sono invece specifici della macchina e si rileggono dal relativo `~/.ssh/config` senza inventarli.

## Diagrammi e stile della documentazione

I flussi applicativi si rappresentano con mappe versionate sotto `context/diagrams/`, in `.svg` per la versione resa e con il sorgente `.mmd` accanto, con corrispondenza uno a uno tra componenti disegnati e componenti descritti. Lo strumento `templates/tools/render-diagrams.mjs` rende i Mermaid riusando il browser Chromium gia installato sul sistema, senza scaricare un browser dedicato. Lo stile della documentazione tecnica e codificato nella regola `.claude/rules/interaction-style.md`: prosa discorsiva, niente elenchi puntati superflui, niente emoji, acronimi spiegati in nota, niente trattini lunghi, e nessun contenuto presentato come fatto se e inferito o non verificato.

## Igiene dell'auto-memory di Claude Code

Claude Code ha una memoria automatica nativa che, se attiva, scrive file in un magazzino nascosto fuori dal progetto, sotto la home dell'account. Questa memoria non e versionata e resta solo sulla macchina, quindi viola il principio di recuperabilita totale. Il sistema la disattiva per default con `autoMemoryEnabled: false` nel `settings.json`, cosi che l'unica memoria sia quella versionata sotto `.claude/memory/` e il `_notes/RESUME-PROMPT.md` ignorato. All'avvio di ogni progetto l'agente chiede comunque se lasciarla disattivata oppure attivarla solo per la sessione corrente, con l'impegno a riportarla a disattivata prima di chiudere o cambiare progetto.

Per tenere pulito il magazzino nascosto nel tempo, il bundle fornisce uno strumento di wipe da installare per-account come hook `SessionEnd`, e uno strumento di verifica che controlla che l'account attivo abbia la memoria nativa disattivata e l'hook di wipe installato. Sono in `templates/tools/`, in versione PowerShell per Windows e shell POSIX per Linux. Il wipe preserva i progetti il cui slug corrisponde a un prefisso indicato, la configurazione, il login, le skill e i plugin, e non tocca mai i file dei progetti su disco. Il prefisso da preservare dipende dalla macchina: dove i progetti di sviluppo stanno su un disco dedicato, ad esempio `D:` su questa macchina, il prefisso e quello degli slug di quel disco, e va impostato di conseguenza nello script installato.

## Windows o Linux

Diverse parti del sistema cambiano a seconda del sistema operativo: il forzare o meno `core.sshCommand` all'OpenSSH di sistema, gli script di setup e build dell'ambiente, gli script di wipe e di verifica dell'account, e la sintassi degli hook. Per questo i due prompt chiedono al punto giusto, in fase di inizializzazione o allineamento, se si sviluppa su Windows o su Linux, e da quel momento usano la variante corretta degli strumenti. Gli strumenti che hanno una doppia forma, come il pacchetto LaTeX e gli strumenti di igiene dell'account, sono forniti sia in PowerShell sia in shell POSIX.

## Screenshot per i passi manuali

Quando uno sviluppo ha parti necessariamente manuali e visive, che l'agente non puo osservare da se, l'agente chiede all'utente uno screenshot del punto preciso e lo legge dalla cartella di cattura invece di proseguire per ipotesi. Su Windows lo strumento e Screenpresso, con cartella di default `%USERPROFILE%\Pictures\Screenpresso`, e `tools/latest-screenshot.ps1` individua l'immagine piu recente da leggere. La regola completa, con il caso Linux e l'igiene degli screenshot come materiale effimero non versionato, e in `.claude/rules/manual-screenshots.md`.

## Comprensione del codice esistente

Per allineare un progetto che ha già codice, l'agente deve capirne la struttura. Oltre a leggere il codice, può appoggiarsi a un server MCP basato su tree-sitter, `code-context-provider-mcp`, che gira via `npx` senza dipendenze native, con licenza MIT, e restituisce l'albero delle cartelle e i simboli del codice, cioè funzioni, classi, import ed export, per JavaScript, TypeScript e Python. È già configurato in `templates/mcp.json` e viene offerto al gate MCP soprattutto nel prompt di allineamento, dove la struttura non è nota a priori; in un progetto nuovo lo stack è già noto e resta opzionale.

## Componenti del bundle

```
template-claude-developing/
  README.md                      questo file, solo per la repo, non trasportato nei progetti
  CLAUDE.md                      segnaposto di radice del template
  CLAUDE.local.md                override personali, ignorato
  .gitignore
  .claude/
    PROJECT-SYSTEM.md            fonte di verita della procedura, in sezioni numerate
    PROMPT-nuovo-progetto.md     prompt fisso per un progetto nuovo
    PROMPT-allinea-progetto-esistente.md   prompt fisso per un progetto esistente
    settings.json                permessi condivisi e variabili di progetto
    settings.local.json          permessi personali, ignorato
    rules/
      git-identity-and-repo.md   identita git locale, alias SSH, bootstrap del remoto
      interaction-style.md       stile della documentazione tecnica
      manual-screenshots.md      quando e come chiedere uno screenshot per i passi manuali
    skills/
      init-project-system/       installa l'anatomia, modalita nuovo o allineamento
      sync-context/              misura la divergenza schede contro codice
      git-sync/                  prepara le operazioni git, non committa
      repo-status/               riepilogo dello stato del repository
      onboard/                   spiegazione completa del progetto per chi parte da zero
    agents/  commands/  hooks/  plugins/    livelli di orchestrazione, vuoti di default
    templates/
      CLAUDE.md  CLAUDE.local.md  settings.json  gitignore.snippet  mcp.json  mcp.windows.json
      README.md  README-project.md
      memory/    index.md  progress.md  decisions.md
      context/   STACK.md  design-and-security.md  deployment.md  dev-testing.md  current-work.md  roadmap.md
      _notes/    DIARIO.md  RESOCONTO.md  TEST-CHECKLIST.md  RESUME-PROMPT.md
      latex/     pacchetto opzionale per progetti LaTeX, con script .ps1 e .sh
      tools/     render-diagrams.mjs  latest-screenshot.ps1  check-account-hygiene  session-end-wipe  README.md
```

## Cosa non finisce nei progetti

Questo `README.md` di radice resta nella repository del template e non viene copiato nei progetti. Gli strumenti di igiene dell'account, `check-account-hygiene` e `session-end-wipe`, agiscono sulla home dell'account Claude Code e non sul repository del progetto: il wipe si installa una volta per-account, non per-progetto. I file personali e locali, `CLAUDE.local.md` e `.claude/settings.local.json`, sono ignorati da git.

## Origine

Questo sistema non nasce da zero. E la distillazione di un modo di lavorare gia maturato su un progetto reale e completo, ripulito dalle parti legate a quel dominio specifico e reso astratto e portabile. Le strategie riusabili emerse anche da altri progetti sono state innestate qui, scartando cio che era specifico di un singolo dominio o gia coperto. Il risultato e un bundle unico, fatto del file di sistema, della skill di inizializzazione, della regola di identita git e delle skill di riconciliazione, che si copia in un progetto nuovo per rendere disponibili altrove queste stesse strategie.

## Repository

Identita personale, alias SSH `github-personal`, remoto `git@github-personal:alesop95/template-claude-developing.git`. Identita e remoto si preparano a livello locale del repo; il primo commit e il push restano manuali.
