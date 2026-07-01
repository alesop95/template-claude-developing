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

## Ingestione di documenti voluminosi (.docx, .pdf e affini)

Un documento di contesto voluminoso non si legge mai per intero, sia esso `.docx` o `.pdf`. Si
estrae il contenuto una sola volta in una cartella scratch ignorata e si caricano solo le
porzioni utili al task. La data di riconciliazione, il nome del documento sorgente e l'esito si
annotano in `memory/progress.md`. Sono previste anche le direzioni inverse, da repository a Word
per i deliverable e da Word a mirror Markdown versionato quando il Word e la fonte di verita
umana.

Quando i documenti da consultare sono piu di uno, il pacchetto opzionale `doc-ingest` (vedi
`.claude/templates/doc-ingest/`) automatizza l'estrazione a corpus intero: converte `.pdf`,
`.docx`, `.pptx`, `.xlsx` e `.html` in una cache Markdown locale con un manifest a content-hash
che salta i file invariati tra una corsa e l'altra, e rigenera a ogni corsa un indice `_INDEX.md`
con titoli, conteggi e stato di ciascun documento: lo scheletro di Livello 1 della disclosure
progressiva descritta nella sezione "Token economy" qui sotto. E interamente locale e a zero
consumo di token; una modalita accurata e un fallback OCR sono disponibili come flag opzionali
per i PDF piu difficili.

Quando invece il `.docx` va trasformato in documentazione tecnica navigabile e versionata, e non
solo letto a fette, il pacchetto opzionale `docx-to-docs` (vedi `.claude/templates/docx-to-docs/`)
automatizza questa direzione: converte il documento in un albero `docs/` con un file per sezione,
`README.md` indice generati che linkano ai figli e un hub `DEVELOPMENT.md`, con conversione
deterministica e livelli curati (banner LEGACY, redazioni, pulizia `--clean`) che sopravvivono
alla rigenerazione. Entrambi i pacchetti si offrono al gate dei pacchetti.

## Igiene del version control e identita git

Prima di considerare sano un repository si verifica che non siano rimasti file indicizzati per errore e soprattutto che non siano mai stati committati segreti, controllando i file tracciati e l'intera storia dei commit. La regola `.claude/rules/git-identity-and-repo.md` definisce come impostare sempre l'identita git a livello locale di repository, come collegare il remoto tramite l'alias SSH corretto, e come proteggersi con `user.useConfigOnly` dal commit con l'identita sbagliata su una macchina con piu profili.

La convenzione degli alias SSH, ad esempio `github-personal` per l'identita personale e `github-corp` per quella di lavoro, e uno schema riusabile su qualsiasi macchina: si possono adottare gli stessi nomi ovunque. I valori concreti dietro ogni alias, ovvero il percorso della chiave, lo `user.name` e lo `user.email`, sono invece specifici della macchina e si rileggono dal relativo `~/.ssh/config` senza inventarli.

## Sicurezza e permessi

Il file `settings.json` del bundle porta una baseline esplicita di permessi: le operazioni git irreversibili (commit, push, reset, rebase, modifica della config globale), la lettura di file sensibili (`.env`, chiavi SSH, credenziali AWS) e la cancellazione ricorsiva sono negate per default; le operazioni di publish (`npm publish`, `docker push`) richiedono conferma esplicita. La regola `.claude/rules/security-permissions.md` documenta le sei modalita' di esecuzione disponibili in Claude Code (default, acceptEdits, plan, dontAsk, auto, bypassPermissions), con i casi d'uso e i rischi di ciascuna, le limitazioni del sandboxing su Windows nativo e WSL2, e le linee guida per `--dangerously-skip-permissions` negli ambienti CI/CD automatizzati.

Le modalita' piu' permissive, auto e bypassPermissions, propagano le loro autorizzazioni anche agli strumenti MCP connessi: un server MCP riceve le stesse autorizzazioni dell'agente che lo ha attivato. Per questo il numero di server connessi va tenuto al minimo (tre-sei al massimo) e si preferisce sempre l'implementazione ufficiale del vendor rispetto a fork community non verificati: un audit pubblico ha trovato problemi nel 66% dei server MCP scansionati.

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

Per una comprensione piu olistica, soprattutto di un progetto grande o sconosciuto o di una collezione di documenti, c'e il pacchetto opzionale `graphify`, che costruisce un grafo di conoscenza dell'intero progetto: nodi e relazioni, community tematiche, nodi centrali e connessioni sorprendenti, con visualizzazione interattiva e report di insight. Sul piano concettuale serve a vedere le relazioni che leggendo i file singoli non emergono; sul piano operativo si installa con `uv tool install graphifyy` (oppure `pipx install graphifyy`), si registra con `graphify install` e si lancia con `/graphify .` nella cartella, ottenendo `graph.html`, `GRAPH_REPORT.md` e `graph.json`. Il codice e analizzato localmente via tree-sitter, mentre documenti e PDF passano dall'LLM e consumano token. Complementa `code-context` (simboli precisi del codice) e `knowledge-wiki` (pagine curate): graphify e la mappa delle relazioni, la wiki e la conoscenza sintetizzata.

## Knowledge wiki: accumulare conoscenza nel tempo

Per i progetti dove si accumula conoscenza trasversale (ricerca, studio di un dominio, o le fonti dietro un libro che si sta scrivendo), il pacchetto opzionale `knowledge-wiki` scaffolda una LLM Wiki: una cartella `knowledge/` con le fonti grezze immutabili in `sources/`, le pagine compilate dall'LLM in `wiki/`, e lo schema `WIKI-SCHEMA.md` che governa tipi di pagina, collegamenti e contraddizioni. Il flusso e semplice: metti una fonte in `knowledge/sources/`, invochi la skill `wiki-digest`, e la wiki aggiorna o crea le pagine collegandole al resto, senza che tu colleghi nulla a mano. Si attiva al gate dei pacchetti e non viene proposto se il progetto ha gia una propria knowledge base nativa. Il dettaglio e il recap dei comandi sono in `.claude/templates/knowledge-wiki/README.md`.

## Libri come skill (book-to-skill)

Per i progetti con libri o PDF tecnici di riferimento, il pacchetto opzionale `book-to-skill` installa la skill `book-digest`, che trasforma un PDF in una skill-libro densa e interrogabile on-demand: durante il lavoro `/<slug> argomento` restituisce la sintesi del tema senza rileggere il PDF. Le skill-libro nascono dentro il progetto (`.claude/skills/<slug>/`, versionate), perche ogni progetto puo avere libri suoi; si possono promuovere al contesto globale di Claude (`~/.claude/skills/`) solo su conferma esplicita e tracciando la scelta. La stessa skill-libro ha un doppio uso: resta una skill che gli agenti consultano (path A), oppure, se il progetto ha `knowledge-wiki`, alimenta la wiki accumulatoria copiando i file capitolo in `knowledge/sources/books/<slug>/` (path B). Dettaglio e comandi in `.claude/templates/book-to-skill/README.md`.

## Ricerca accademica (academic-researcher)

Per i progetti di ricerca accademica, di tesi, o di analisi sistematica di un corpus di paper, il pacchetto opzionale `academic-researcher` scaffolda un intero ambiente di ricerca assistita: scoping del topic con le domande di gate corrette (dominio disciplinare, libreria Zotero esistente o meno, output LaTeX o Word, livello di autonomia), tracciamento tripartito di ogni fonte come verificata, da verificare o scartata, sincronizzazione di `research-vault/bibliography.bib` tra Zotero come libreria di lavoro e JabRef come validatore umano finale, e la Corpus Analysis Suite, dieci prompt collaudati (Intake Protocol, Contradiction Finder, Citation Chain, Gap Scanner, Methodology Audit, Master Synthesis, Assumption Killer, Knowledge Map Builder, So What Test, Canon Update) per analizzare un corpus di paper gia' caricato in conversazione. Il pacchetto e' distillato da un modulo di ricerca dedicato, che si instanzia insieme al pacchetto come riferimento consultabile in `research-vault/reference/`, integrato con un metodo esterno attribuito (screenshot di un post pubblico, account `@techwith.ram`) per la parte di ricerca letteratura, lo scoping di progetto, la lettura profonda e l'ultima delle dieci modalita' della Corpus Analysis Suite.

Cinque delle otto skill del pacchetto (`corpus-analysis`, `citation-tracker`, `bib-sync`, `research-scoping`, `literature-search`) hanno un corpo operativo completo, perche' il modulo di origine o il metodo esterno attribuito ne fissa il comportamento in modo concreto; le altre tre (`deep-paper-reading`, `gap-analysis`, `skill-autogen`) sono parzialmente stub: dispongono gia' di un prompt o di un'euristica di default usabile da subito, ma lasciano aperta una calibrazione specifica del progetto, quali MCP di ricerca sono connessi, se Docker e GROBID sono disponibili, quale dominio disciplinare calibra le soglie di rilevanza. Il pacchetto non installa da solo alcun MCP: le voci concrete raccomandate dal modulo di origine, `zotero-mcp`, `academix`, `semantic-scholar-mcp`, `refchecker-mcp`, piu i tool esterni `arxiv-cli`, `grobid` e `paperqa2`, restano righe separate del catalogo, proposte una alla volta rispettando il limite di 3-4 MCP nuovi per sessione. Il dettaglio completo, coi crediti e la mappa di istanziazione, e' in `.claude/templates/academic-researcher/README.md`.

## Agenti di progetto

I subagent sono agenti con una persona specializzata, un system prompt focalizzato e un insieme ristretto di strumenti. Si definiscono come file Markdown in `.claude/agents/` del progetto, con un frontmatter YAML che specifica nome, modello e tool disponibili, e lavorano in un contesto isolato rispetto all'agente principale, riportando solo il risultato finale. Il bundle include due definizioni di agente pronte all'uso sotto `templates/agents/`: `code-reviewer`, che esamina struttura, gestione degli errori e sicurezza del codice classificando i finding per severita' (CRITICAL / HIGH / MEDIUM / LOW) e concludendo con APPROVE, REQUEST_CHANGES o NEEDS_DISCUSSION; e `security-auditor`, che conduce un audit sistematico per autenticazione, autorizzazione, validazione degli input, esposizione di dati, dipendenze con CVE note e segreti hardcoded. Entrambi operano esclusivamente in lettura e si copiano in `.claude/agents/` del progetto al momento dell'attivazione del pacchetto `subagent-template`.

## Token economy

Il sistema e' progettato per non sprecare contesto: densita' sopra completezza, caricamento on-demand di skill, schede e capitoli, niente riletture integrali (il motore di riconciliazione legge solo le schede pertinenti, i `.docx` si estraggono a fette), e il `CLAUDE.md` indicizza i satelliti invece di incorporarli. La regola `.claude/rules/token-economy.md` documenta anche le pratiche di igiene di sessione: il comando `/compact` va invocato proattivamente quando il contesto raggiunge il 40-60% (non aspettando il limite automatico) e puo' essere guidato con istruzioni esplicite; prima di `/clear` o di chiudere una sessione non ancora conclusa si fa scrivere a Claude un file `HANDOFF.md` con decisioni, pattern e file toccati; la finestra da un milione di token e' utile come assicurazione ma non come obiettivo, dato che oltre i 120-150K token utili la qualita' tende a degradare per accumulo di rumore; il principio "un task, una chat" mantiene il contesto fresco.

Quando serve di piu', al gate dei pacchetti si propone uno stack di sette strumenti open source, uno per fronte di consumo: `ccusage` per la misurazione baseline (sempre, prima degli altri), `rtk` per l'output shell, `ponytail` per il codice generato, `context-mode` per l'output di tool pesanti, `caveman` per la prosa di risposta, `headroom` come compressore generale, e `claude-code-router` per il routing tra modelli. Nessuno e' abilitato di default; ogni scelta richiede gate e conferma esplicita dell'utente per quel progetto.

## Niente AI slop

Lo stile pulito e' garantito sempre dalla regola `interaction-style` (niente trattini lunghi, niente stilemi da testo generativo). Quando serve una pulizia attiva, al gate si possono attivare due strumenti esterni a scelta, distinti per ambito. Per il testo, `humanizer` e' una skill che rimuove i segni di scrittura AI (frasi riempitive, regola del tre, trattini lunghi e grassetto in eccesso, hedging, tono promozionale, 33 pattern): si clona in `.claude/skills/humanizer/` e si usa con `/humanizer <testo>`. Per le interfacce, `taste-skill` migliora layout, tipografia, spaziatura e motion delle UI generate per evitare l'aspetto generico-AI: si aggiunge con `npx skills add https://github.com/Leonxlnx/taste-skill`. Il primo serve ai progetti che producono prosa, il secondo ai progetti con frontend.

## Componenti del bundle

```
template-claude-developing/
  README.md                      questo file, solo per la repo, non trasportato nei progetti
  docs/
    feature-map.html             inventario completo delle feature con source e repo, apribile localmente
    project-flow.html            flusso di progetto annotato con tutte le feature e la tabella fonti
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
      security-permissions.md    modalita di permesso, sandbox, baseline deny e ask rules
      token-economy.md           pratiche di risparmio contesto, igiene sessione, stack 7 tool
    skills/
      init-project-system/       installa l'anatomia, modalita nuovo o allineamento
      sync-context/              misura la divergenza schede contro codice
      git-sync/                  prepara le operazioni git, non committa
      repo-status/               riepilogo dello stato del repository
      onboard/                   spiegazione completa del progetto per chi parte da zero
    agents/  commands/  hooks/  plugins/    livelli di orchestrazione, vuoti di default
    templates/
      PACKAGES.md  registro dei pacchetti opzionali offerti al init/align
      CLAUDE.md  CLAUDE.local.md  settings.json  gitignore.snippet  mcp.json  mcp.windows.json
      README.md  README-project.md
      agents/    code-reviewer.md  security-auditor.md  (agenti template, da copiare in .claude/agents/)
      memory/    index.md  progress.md  decisions.md
      context/   STACK.md  design-and-security.md  deployment.md  dev-testing.md  current-work.md  roadmap.md
      _notes/    DIARIO.md  RESOCONTO.md  TEST-CHECKLIST.md  RESUME-PROMPT.md
      latex/           pacchetto opzionale per progetti LaTeX, con script .ps1 e .sh
      knowledge-wiki/  pacchetto opzionale LLM Wiki (sources/ + wiki/ + schema + skill wiki-digest)
      book-to-skill/   pacchetto opzionale: skill book-digest (PDF in skill on-demand, locale)
      academic-researcher/  pacchetto opzionale: 8 skill di ricerca (5 complete, 3 parzialmente stub), regola no-uncited-claims, documento di riferimento
      tools/     render-diagrams.mjs  latest-screenshot.ps1  check-account-hygiene  session-end-wipe  claude-incognito  README.md
```

## Cosa non finisce nei progetti

Questo `README.md` di radice e la cartella `docs/` (con i due file HTML di documentazione) restano nella repository del template e non vengono copiati nei progetti. Gli strumenti di igiene dell'account, `check-account-hygiene` e `session-end-wipe`, agiscono sulla home dell'account Claude Code e non sul repository del progetto: il wipe si installa una volta per-account, non per-progetto. I file personali e locali, `CLAUDE.local.md` e `.claude/settings.local.json`, sono ignorati da git.

## Origine

Questo sistema non nasce da zero. E la distillazione di un modo di lavorare gia maturato su un progetto reale e completo, ripulito dalle parti legate a quel dominio specifico e reso astratto e portabile. Le strategie riusabili emerse anche da altri progetti sono state innestate qui, scartando cio che era specifico di un singolo dominio o gia coperto. Il risultato e un bundle unico, fatto del file di sistema, della skill di inizializzazione, della regola di identita git e delle skill di riconciliazione, che si copia in un progetto nuovo per rendere disponibili altrove queste stesse strategie.

## Come estendere il sistema

Il sistema cresce aggiungendo pacchetti al catalogo quando si trova uno strumento o un pattern utile, tipicamente open source. Il percorso e' lo stesso ogni volta.

1. Trova lo strumento o il pattern e verifica cosa fa, come si installa e con quale licenza, cercando se esiste gia invece di ricostruirlo.
2. Decidi il tipo. Un pacchetto a cartella scaffolda file nel progetto: vive sotto `.claude/templates/<nome>/` con un proprio `README.md` manifest, sul modello di `latex`, `knowledge-wiki`, `book-to-skill`. Uno strumento esterno non scaffolda nulla: e' solo una voce di catalogo che si installa su conferma, sul modello di `code-context`, `caveman`, `graphify`.
3. Aggiungi una riga a `.claude/templates/PACKAGES.md` con un trigger concreto nella colonna "quando offrirlo", piu cosa istanzia, note e crediti. Il trigger e' cio che permette al gate di proporlo senza assumere.
4. Spiega lo strumento su due piani, concettuale e operativo: cosa risolve e perche, e i comandi per usarlo. La spiegazione va nel `README.md` del pacchetto, se a cartella, e in sintesi nel `README.md` di radice.
5. Aggiungi il credito nella sezione "Riferimenti e strumenti open source", con il link al repo e la licenza.
6. Aggiorna le due mappe visive in `docs/`: `feature-map.html` (riga di catalogo nella sezione pertinente, badge Nuovo, contatore pacchetti opt-in) e `project-flow.html` (contatore pacchetti, riga nella tabella fonti se il pacchetto introduce una dipendenza open source non ancora elencata). Sono generate una volta e poi mantenute a mano: un pacchetto o una funzionalita' aggiunta al sistema senza questo passo le lascia disallineate rispetto a `PACKAGES.md`, com'e' gia successo una volta. Questo passo si applica a ogni estensione del sistema, non solo ai pacchetti a se stanti: anche una funzionalita' che cambia il numero o la natura di skill, regole o agenti va riflessa negli stessi contatori.
7. Non serve toccare il gate: la skill `init-project-system` e i due prompt leggono `PACKAGES.md`, propongono il pacchetto quando il trigger e' pertinente e ne mostrano il recap d'uso all'attivazione.
8. Valida su un progetto reale, anche solo in simulazione di sola lettura, e registra l'esito in `CASE-STUDIES.md` come voce anonima: perche, come e dove funziona meglio.
9. Le operazioni git restano manuali: prepara i file e lascia commit e push all'utente.

Due principi guida nella scelta. Si preferisce non introdurre stato globale o dipendenze pesanti: meglio un pacchetto self-contained e versionato col progetto. E non si propone un pacchetto se il progetto fornisce gia quella capacita nativamente, per non duplicare.

## Riferimenti e strumenti open source

Il sistema integra o adatta alcuni strumenti e pattern open source:

- `code-context-provider-mcp` di AB498, server MCP tree-sitter in WebAssembly (licenza MIT), per struttura e simboli del codice: https://github.com/AB498/code-context-provider-mcp
- `book-to-skill` di virgiliojr94, per pre-digerire un PDF tecnico in skill: https://github.com/virgiliojr94/book-to-skill
- `python-docx`, libreria per leggere e scrivere documenti Word, base del pacchetto `docx-to-docs` (licenza MIT): https://github.com/python-openxml/python-docx
- `markitdown` di Microsoft, motore di default del pacchetto `doc-ingest` per l'estrazione multi-formato (`.pdf`, `.docx`, `.pptx`, `.xlsx`, `.html`) in Markdown (licenza MIT): https://github.com/microsoft/markitdown
- `Docling` di IBM Research, motore accurato opzionale di `doc-ingest` per PDF con layout complessi (codice open source; licenze dei pesi dei modelli di layout da verificare all'installazione): https://github.com/docling-project/docling
- `pytesseract`, wrapper del motore OCR `tesseract-ocr`, fallback opzionale di `doc-ingest` sui PDF senza testo nativo (entrambi Apache-2.0): https://github.com/madmaze/pytesseract
- `LiteDoc` di 0xovo, convertitore `.pdf` in Markdown interamente nel browser, senza dipendenze server (licenza AGPL-3.0): alternativa manuale per conversioni singole quando non si vuole installare nulla, non scriptabile da un agente, non adottata direttamente in `doc-ingest`: https://github.com/0xovo/LiteDoc
- `PyMuPDF4LLM`, motore "veloce" citato dalla guida pdf-to-markdown di mcp.directory che ha ispirato l'architettura a due motori di `doc-ingest`; non adottato perche si appoggia a `PyMuPDF`, sotto doppia licenza AGPL-3.0 o commerciale, da valutare caso per caso nei progetti proprietari: https://github.com/pymupdf/pymupdf4llm
- LLM Wiki, pattern di Andrej Karpathy: https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f
- mermaid-cli del progetto Mermaid, usato dalla resa dei diagrammi: https://github.com/mermaid-js/mermaid-cli
- `caveman` di JuliusBrussee, riduzione dei token di output a scelta dell'utente: https://github.com/juliusbrussee/caveman
- `token-optimizer-mcp` di ooples, compressione e caching del contesto via MCP: https://github.com/ooples/token-optimizer-mcp
- `graphify` di safishamsi, grafo di conoscenza di codice e documenti (licenza MIT): https://github.com/safishamsi/graphify
- `humanizer` di blader, skill che rimuove i segni di scrittura AI dal testo (licenza MIT): https://github.com/blader/humanizer
- `taste-skill` di Leonxlnx, skill di design-taste per interfacce non generiche (licenza MIT): https://github.com/Leonxlnx/taste-skill
- `ccusage` di ryoppippi, misura baseline del consumo token per sessione e modello (MIT): https://github.com/ryoppippi/ccusage
- `rtk` di rtk-ai, comprime l'output shell (git, cargo, pytest, npm, 100+ comandi) prima che entri nel contesto (MIT): https://github.com/rtk-ai/rtk
- `ponytail` di DietrichGebert, impone la disciplina "senior developer pigro" al codice generato (MIT): https://github.com/DietrichGebert/ponytail
- `context-mode` di mksglu, sandboxa l'output di tool pesanti (Playwright, log, dump) in SQLite locale (MIT): https://github.com/mksglu/context-mode
- `headroom` di chopratejas, proxy locale che comprime tutto l'input dell'LLM (MIT): https://github.com/chopratejas/headroom
- `claude-code-router` di musistudio, routing automatico tra modelli per costo API (MIT): https://github.com/musistudio/claude-code-router
- `claude-mem` di thedotmack, memoria semantica persistente cross-sessione SQLite e Chroma, tutto locale (MIT): https://github.com/thedotmack/claude-mem
- `codebase-memory-mcp` di DeusData, grafo strutturale del codice con call chain, 158 linguaggi via tree-sitter (MIT): https://github.com/DeusData/codebase-memory-mcp
- `andrej-karpathy-skills` di forrestchang, quattro principi comportamentali anti-over-engineering come skill (MIT): https://github.com/forrestchang/andrej-karpathy-skills
- `code-simplifier`, plugin ufficiale Anthropic per semplificazione del codice prodotto: https://github.com/anthropics/claude-plugins-official
- `github-mcp-server`, server MCP ufficiale GitHub per issue, PR, code search e repository management (MIT): https://github.com/github/github-mcp-server
- `context7` di Upstash, documentazione aggiornata di librerie e framework via MCP (MIT): https://github.com/upstash/context7
- `playwright-mcp`, server MCP ufficiale Microsoft per automazione browser e test E2E (MIT): https://github.com/microsoft/playwright-mcp
- `multiclaude` di dlorenc, supervisore per feature branch paralleli con gate di review umana (MIT): https://github.com/dlorenc/multiclaude
- `psmux`, tmux nativo per Windows senza WSL, con supporto agent teams Claude Code (MIT): https://github.com/psmux/psmux
- `tmux-claude-session-manager` di craftzdog, plugin tmux con stato live di tutte le sessioni Claude Code via hook nativi (MIT): https://github.com/craftzdog/tmux-claude-session-manager
- `claudecode.nvim` di coder, plugin Neovim con protocollo MCP WebSocket in Lua pura (MIT): https://github.com/coder/claudecode.nvim
- `sentry-mcp`, server MCP ufficiale Sentry per stack trace e correlazione errori-release: implementazione ufficiale Sentry
- `figma-mcp`, server MCP ufficiale Figma per accesso all'albero dei nodi del design: implementazione ufficiale Figma
- `vercel-mcp`, server MCP ufficiale Vercel per monitoraggio deploy e variabili d'ambiente: implementazione ufficiale Vercel
- `linear-mcp`, server MCP ufficiale Linear per CRUD issue e sprint (richiede piano Standard+): implementazione ufficiale Linear
- `zotero-mcp` di 54yyyu, MCP per la libreria bibliografica Zotero con ricerca semantica e CLI, base del pacchetto `academic-researcher`: https://github.com/54yyyu/zotero-mcp
- `Academix` di xingyulu23, MCP di ricerca letteratura aggregata su OpenAlex, DBLP, Semantic Scholar, arXiv e Crossref con export BibTeX: https://github.com/xingyulu23/Academix
- `semantic-scholar-mcp` di akapet00, MCP di ricerca su Semantic Scholar con export BibTeX e tracking di sessione: https://github.com/akapet00/semantic-scholar-mcp
- `mcp-refchecker` di JonasBaath, MCP di verifica anti-hallucination delle citazioni contro Semantic Scholar, OpenAlex e Crossref (costruito su `academic-refchecker`, MIT): https://github.com/JonasBaath/mcp-refchecker
- GROBID, motore open source di parsing PDF scientifico in XML/TEI strutturato, mantenuto da Luca Foppiano/Inria dal 2011, usato dal pacchetto `academic-researcher` per la lettura profonda dei paper
- `paper-qa` (PaperQA2) di Future-House, framework RAG agentico per letteratura scientifica con citazioni verificate: https://github.com/Future-House/paper-qa
- `arxiv-cli` di AstraBert, CLI standalone per recupero rapido di paper arXiv senza MCP (licenza MIT): https://github.com/AstraBert/arxiv-cli

## Repository

Identita personale, alias SSH `github-personal`, remoto `git@github-personal:alesop95/template-claude-developing.git`. Identita e remoto si preparano a livello locale del repo; il primo commit e il push restano manuali.
