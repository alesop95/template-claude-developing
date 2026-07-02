# Case-studies di validazione del sistema

> Registro anonimo degli esperimenti con cui si valida il sistema di progetto. Serve a capire
> perche, come e dove funziona meglio, accumulando evidenza riusabile. Regola di anonimato: niente
> nomi di progetto, owner o dominio specifico; si tiene solo l'archetipo tecnico e la lezione.

## Schema di una voce

Data, archetipo del progetto (anonimo), cosa si e testato, esito (cosa ha funzionato e cosa no),
perche/come/dove funziona meglio (la lezione), rifiniture derivate (eventuali cambi al sistema).

## Pacchetti in attesa di validazione — progetto pilota

> Sezione di lavoro, non un case-study concluso: tiene traccia dei pacchetti che nel loro stesso README dichiarano di derivare da una ricerca dell'utente non ancora esercitata su un progetto reale, in attesa di produrre la voce di validazione vera e propria secondo lo schema sopra. Il piano concordato e' lanciare un progetto pilota dedicato, distinto dai progetti di produzione, con il solo scopo di avviare il template su un caso reale e attraversare ogni feature dei pacchetti elencati qui sotto, cosi che ciascuno riceva la propria voce datata con archetipo, esito e lezione, invece di restare dichiarato "da calibrare" a tempo indeterminato.

Pacchetti in attesa, aggiornati il 2026-07-02: `academic-researcher`, per le tre skill dichiarate parzialmente stub nel proprio README (`deep-paper-reading`, `gap-analysis`, `skill-autogen`), le cui soglie e orchestrazioni restano da calibrare su un corpus reale; `learning-agent`, per l'intero pacchetto, il cui livello di orchestrazione e' gia completo ma non e' mai stato eseguito su un learner reale; `codebase-learning`, per l'intero pacchetto, nella stessa condizione di `learning-agent` e con la stessa distinzione da tenere presente al momento della validazione; `notebooklm-bridge`, per l'intero pacchetto, che deriva da screenshot di un metodo pubblico condiviso dall'utente e non e' mai stato eseguito su un progetto reale, con da validare in particolare la verifica di disponibilita' dell'account Google e del browser, il funzionamento del modo assistito via `notebooklm-mcp`, e la resa effettiva del risparmio di token tenendo il corpus fuori dal contesto. Quando il progetto pilota esercita un pacchetto di questo elenco, la voce corrispondente si toglie da qui e si aggiunge sotto come case-study datato, con archetipo, cosa si e' testato, esito, lezione e rifiniture derivate.

Il pilota del 2026-07-02 (voce datata sotto) ha ridotto ma non azzerato questo elenco. `claude-code-handoff` resta parzialmente verificato: il confronto versione contro la fonte upstream e' stato esercitato dal vivo una seconda volta, ma restano da validare la ri-distillazione via `claude -p`, `/refresh-handoff` su una guida reale scaricata, e il workflow GitHub Actions. `dev-skills` resta parzialmente in attesa: verificato solo `test-generator` a livello strutturale (nessuna invocazione LLM); `mcp-tool-scaffold`, `code-review` e `security-review` restano non esercitati. `stack-profiles` e' verificato solo meccanicamente (istanziazione del profilo `ts-mcp`): la tenuta della regola nelle sessioni di sviluppo successive non e' stata osservata. `automation-starter` e' verificato solo sulla prima delle tre vie dichiarate (corsa locale `headless-run`): il workflow GitHub Actions e la terza via nativa `/schedule` restano non testati. `agent-catalog` e' l'unico uscito interamente da questo elenco: list/fetch/check sono stati esercitati due volte, in isolamento e dentro un progetto ospite reale, con esito pulito la seconda volta. `academic-researcher`, `learning-agent`, `codebase-learning` e `notebooklm-bridge` restano nello stato descritto sopra, non toccati da questo pilota.

---

## 2026-06-17 — Gate dei pacchetti in allineamento

**Archetipo.** Allineamento di un progetto esistente: pipeline Python di analisi documentale che
produce una knowledge base con grafo e sintesi; `.claude/` parziale (un agent e skill di dominio
piu i settings) ma senza il motore di riconciliazione (niente `memory/` ne `context/`), niente file
`.tex` ne `.mmd`, git gia presente.

**Cosa si e testato.** Il gate dei pacchetti opzionali (registro `PACKAGES.md`) e il flusso di
allineamento della sezione 11, in simulazione di sola lettura.

**Esito.** Il gate ha saltato correttamente `latex` e `diagrams`, assenti i rispettivi trigger
(`.tex`, `.mmd`). Ha offerto `code-context`, pertinente in allineamento su un progetto Python. Ha
fatto emergere che `knowledge-wiki` non andrebbe proposto, perche il progetto implementa gia quella
capacita in proprio.

**Perche/come/dove funziona meglio.** Un gate guidato da trigger concreti evita proposte
irrilevanti. La selezione per "file gia presenti" non basta: serve riconoscere quando il progetto
fornisce gia quella capacita nativamente, per non proporre un duplicato. Il valore di `code-context`
in allineamento e soprattutto per l'agente, che deve mappare il codice e popolare le schede, piu che
per l'utente che spesso la struttura la conosce gia.

**Rifiniture derivate.** Due micro-edit a `PACKAGES.md`: check "capacita gia implementata in
proprio" nella sezione d'uso, e riformulazione del trigger di `code-context` verso la mappatura del
codice in allineamento.

---

## 2026-06-17 — Pacchetto knowledge-wiki su un progetto-libro

**Archetipo.** Progetto di scrittura di un libro in LaTeX, con sorgenti e build gia strutturati,
dove durante la scrittura si accumulano fonti di ricerca.

**Cosa si e testato.** Il gate dei pacchetti su un progetto-libro: come si comportano `latex` e
`knowledge-wiki`, in simulazione di sola lettura.

**Esito.** `latex` ha trigger fortissimo (presenza di sorgenti `.tex`) e va proposto o confermato.
`knowledge-wiki` non e implicato dal solo fatto che sia un libro: va proposto come scelta, perche
serve solo se si accumulano fonti di ricerca da organizzare, e decide l'utente.

**Perche/come/dove funziona meglio.** La guida al gate funziona meglio quando distingue i trigger
forti e oggettivi (un'estensione di file) dalle scelte di metodo (accumulare o no una wiki di
ricerca). Per queste ultime il valore sta nel proporre con una domanda chiara e, all'attivazione,
nel dare subito il recap d'uso e dei comandi, invece di creare cartelle vuote senza spiegazione.

**Rifiniture derivate.** Regola "all'attivazione mostra il recap d'uso del pacchetto" aggiunta al
gate (`PACKAGES.md` e skill di init), e documentazione d'uso chiara con crediti agli strumenti open
source nel README.

---

## 2026-06-17 — Mining di una pipeline documentale (pattern agnostici)

**Archetipo.** Progetto-pipeline che ingerisce un corpus di documenti e produce una knowledge base,
separando il lavoro deterministico (script) da quello linguistico (LLM), con stati intermedi su disco.

**Cosa si e testato.** Lettura mirata dell'architettura di un progetto maturo per estrarre solo le
strategie agnostiche al dominio, scartando quelle specifiche.

**Esito.** Estratti quattro pattern riusabili: disclosure progressiva a tre livelli sui documenti,
deterministico prima del linguistico, ingest incrementale via hash del contenuto, generazione
idempotente via identificatori stabili. Scartato tutto cio che era di dominio: tassonomia,
classificazione, regex di lingua, export pubblico, formula del grafo pesato.

**Perche/come/dove funziona meglio.** I pattern infrastrutturali di un progetto maturo si riusano
solo se separati dal dominio. La disclosure a livelli e il principio deterministico-prima abbattono i
token su corpora grandi; l'ingest via hash rende ripetibile l'aggiornamento; gli ID stabili evitano
duplicati nelle rigenerazioni.

**Rifiniture derivate.** `rules/token-economy.md` esteso (disclosure progressiva, deterministico vs
linguistico), `wiki-digest` con ingest-state via hash e re-ingestione idempotente, e `graphify`
aggiunto al catalogo come pacchetto opzionale per il grafo di conoscenza di un progetto.

---

## 2026-07-01 — Pacchetto docx-to-docs da un .docx voluminoso

**Archetipo.** Progetto che parte da un unico `.docx` di circa 200 pagine, scritto a mano, denso e
non lineare: titoli a livelli profondi, sezioni marcate TBC/aborted, emoji, refusi segnaposto e
molti riferimenti a fonti esterne, da trasformare in documentazione tecnica navigabile e versionata.

**Cosa si e testato.** La conversione deterministica in albero `docs/` con un file per sezione e
`README.md` indice generati, i tre livelli curati (annotazioni LEGACY, redazioni di materiale fuori
policy, pulizia `--clean` del rumore) e la verifica di completezza integrata.

**Esito.** La conversione ha preservato l'intero contenuto testuale, con verifica per paragrafo e
per cella di tabella superata salvo divergenze volute, ha estratto le immagini in `assets/` locali e
prodotto un report con conteggi e trasformazioni. Annotazioni e redazioni sono sopravvissute alle
rigenerazioni; `--clean` ha rimosso centinaia di emoji e trattini lunghi e le righe segnaposto senza
toccare i simboli tecnici (impedenza, frecce). Un hub `DEVELOPMENT.md` scritto a mano e collegato
dalla home con un'annotazione ha reso l'albero navigabile da un unico punto di ingresso.

**Perche/come/dove funziona meglio.** Il pattern conviene quando il `.docx` e la fonte di verita
umana e va reso conoscenza recuperabile da un clone, non solo letto a fette. La chiave e separare
l'output verbatim dai livelli curati in sidecar deterministici, cosi le correzioni non si perdono
alla rigenerazione. Tenere il `.docx` e le redazioni locali, versionando solo l'albero e il
convertitore, evita di pubblicare materiale sensibile.

**Rifiniture derivate.** Nascita del pacchetto `docx-to-docs`, con `MACRO_NAMES` generalizzato
(nomi cartella auto-derivati dallo slug) e la pulizia `--clean` come controparte attiva di
`interaction-style`.

---

## 2026-07-01 — Pacchetto doc-ingest, dry-run su un corpus di prova

**Archetipo.** Verifica a se stante dello script di un pacchetto nuovo, senza un progetto ospite:
un corpus minimo di prova con un `.html` e un `.pdf` fittizio (non un vero documento), usato solo
per esercitare i percorsi di codice dello script.

**Cosa si e testato.** Corsa pulita (file nuovo), rilevamento di un sorgente modificato
(riconversione mirata), corsa ripetuta senza modifiche (cache-hit, nessuna riconversione), il
flag `--engine docling` senza il pacchetto opzionale installato, e il flag `--ocr` senza
`pytesseract` installato, in assenza del binario di sistema `tesseract-ocr`.

**Esito.** Tutti i percorsi si sono comportati come progettato. Il file nuovo genera un mirror
Markdown e una riga "nuovo" nell'indice; la modifica del sorgente produce "aggiornato" e
riconverte solo quel file; la corsa invariata produce "invariato" per entrambi senza toccare la
cache. La dipendenza opzionale mancante per `--engine docling` produce un messaggio d'errore
guidato con il comando di installazione, non un traceback, e il file resta segnalato come errore
senza bloccare gli altri. La dipendenza opzionale mancante per `--ocr` degrada senza bloccare la
corsa: il file viene comunque processato con il testo nativo disponibile e una nota nell'indice
spiega perche l'OCR non e stato applicato.

**Perche/come/dove funziona meglio.** Separare l'errore bloccante (dipendenza core assente, es.
`markitdown` non installato) dalla degradazione controllata (dipendenza opzionale assente per un
flag esplicito) evita due estremi sbagliati: fermare l'intera corsa per un flag opzionale, o
fallire in silenzio senza dire perche un file non ha l'output atteso. Il controllo
`cache_path.exists()` nella logica di stato, oltre al confronto hash, rende il manifest
autocorrettivo: se una conversione precedente e fallita dopo aver gia registrato l'hash, la
corsa successiva la ritenta comunque, perche il file di cache atteso non c'e.

**Rifiniture derivate.** Nascita del pacchetto `doc-ingest`, generalizzazione del pattern
`_notes/.tmp-docx-*` esistente a `_notes/.tmp-doc-*` (PROJECT-SYSTEM.md, README, gitignore
snippet, skill di inizializzazione), e cross-reference aggiunto in `token-economy.md` dalla
disclosure progressiva alla sua implementazione di riferimento.

---

## 2026-07-02 — Progetto pilota disposable: init greenfield end-to-end

**Archetipo.** Progetto pilota dedicato, volutamente giocattolo e disposable: un piccolo server MCP TypeScript/Node a tool singolo (nessuna persistenza, nessuna rete), con test `vitest`, un documento LaTeX e un diagramma Mermaid gia' presenti allo scaffold iniziale, pensato apposta per attraversare il maggior numero di pacchetti del catalogo. Identita' git personale, solo locale, nessun remote GitHub. Account Claude attivo `.claude-account2`.

**Cosa si e' testato.** Per la prima volta un'inizializzazione greenfield reale (non simulata) del sistema portabile: import del bundle (`PROJECT-SYSTEM.md`, `rules/`, le 5 skill del motore, l'intera cartella `templates/`), anatomia minima di `.claude`, e poi il gate dei pacchetti eseguito in autonomia (senza conferma utente pacchetto per pacchetto, per scelta esplicita di velocita' su un pilota) su un sottoinsieme ampio del catalogo: `latex`, `diagrams`, `code-context` (MCP), `stack-profiles` (profilo `ts-mcp`), `hooks-starter` (solo `session-context`), `claude-code-handoff`, `automation-starter`, `agent-catalog`, `subagent-template` (due agenti), `dev-skills` (solo `test-generator`). Esclusi consapevolmente i pacchetti che richiedono account a pagamento, Docker, o toccano lo stato globale dell'account Claude (MCP con OAuth reale, `wshobson-agents`/`voltagent-subagents` via `/plugin marketplace add`, `academic-researcher`/`learning-agent`/`codebase-learning`/`notebooklm-bridge` per non pertinenza col progetto giocattolo).

**Esito.** Tre pacchetti hanno funzionato correttamente al primo tentativo: `diagrams` (rendering Mermaid -> SVG riuscito subito con Edge auto-rilevato), `subagent-template` e `dev-skills` (istanziazione strutturale pulita), `agent-catalog` (list/fetch/check tutti corretti dentro un vero progetto ospite, coerenti con la validazione isolata precedente), `claude-code-handoff` (`-Check` ha rilevato correttamente l'aggiornamento disponibile e la fonte ferma da 142 giorni, coerente con quanto gia' noto), `automation-starter` (`headless-run.ps1` ha eseguito un prompt reale in 12,7s per $0,14, rispondendo correttamente). Due pacchetti hanno rivelato bug reali, corretti seduta stante: `latex` falliva la build (`Font T1/pcr/.../not loadable`) perche' il manifesto base non elencava `courier`, necessario insieme a `psnfss`/`times` quando il documento usa `\texttt` su un preambolo T1 — TinyTeX non lo installa di default, a differenza di una TeX Live completa; risolto installando `courier` via `tlmgr` (che ha richiesto anche un `tlmgr update --self` preliminare) e aggiungendo la coppia al manifesto. `hooks-starter` (variante Windows di `session-context.ps1`) aveva tre difetti mai esercitati prima dal vivo: `git rev-parse --abbrev-ref HEAD` su un repo senza commit stampava letteralmente "HEAD" invece del branch reale; `Get-Content` senza `-Encoding UTF8` produceva testo accentato corrotto leggendo `memory/index.md`; `git log` su un repo senza commit lasciava passare un "fatal:" di git su stderr nell'output iniettato in sessione. Tutti e tre corretti e riverificati con una nuova corsa dello script. Un attrito non bloccante, non un bug del pacchetto: la prima corsa di `headless-run` su una cartella mai aperta interattivamente in Claude Code ignora la allowlist di `settings.json` finche' il workspace non risulta "trusted", con un warning esplicito ma senza fermare l'esecuzione. Il codice applicativo del pilota stesso (`npm install`, `npm test`, `npm run build`) e' risultato pulito al primo colpo.

**Perche/come/dove funziona meglio.** Solo un'esecuzione dal vivo, non una simulazione di sola lettura, fa emergere i bug reali di ambiente (font TeX mancanti, quirk di git su repo senza commit, encoding PowerShell): tutti e tre gli attriti trovati erano invisibili a una revisione statica del codice degli script. La differenza tra `latex`/`hooks-starter` (bug trovati) e `diagrams`/`agent-catalog` (nessun bug) non e' casuale: i primi due non erano mai stati eseguiti fuori da un ambiente di sviluppo gia' "caldo" (TinyTeX con `courier` gia' installato altrove, o un repo con storia git preesistente), mentre `diagrams` era gia' stato validato in condizioni simili e `agent-catalog` era gia' stato testato in isolamento in questa stessa sessione prima del pilota, quindi i suoi bug erano gia' stati trovati e corretti altrove. La lezione generale: un pacchetto va considerato validato solo dopo una corsa su un repository davvero allo stato zero (zero commit, ambiente non pre-scaldato), non dopo una corsa su una macchina di sviluppo gia' matura dove le dipendenze mancanti sono gia' presenti per altri motivi.

**Rifiniture derivate.** `templates/latex/tex-packages.txt` e `templates/latex/README.md`: aggiunta la coppia `psnfss`+`courier` con nota esplicita del sintomo osservato. `templates/hooks-starter/hooks/session-context.ps1`: tre fix (branch via `git branch --show-current`, lettura `-Encoding UTF8`, guard esplicita su `git rev-parse --verify HEAD` prima di richiamare `git log`). `templates/automation-starter/README.md`: nuova nota sull'attrito del workspace non "trusted" al primo avvio headless in una cartella nuova.

**Osservazione aperta, non ancora una decisione.** Seguendo alla lettera il Passo 1 di `PROMPT-nuovo-progetto.md`, l'intera cartella `templates/` (129 file, 817 KB al momento del pilota) e' stata copiata dentro il progetto pilota anche se solo una decina dei quindici pacchetti a cartella e' stata effettivamente istanziata. Per un progetto reale non e' un problema di token (non si legge tutto, si copia soltanto) ma e' comunque massa versionata inerte nel repository di destinazione. Non si e' cambiata la procedura sulla base di una sola osservazione: da verificare in un pilota successivo se convenga invece copiare solo i pacchetti la cui riga di `PACKAGES.md` risulta accettata al gate, lasciando gli altri raggiungibili tornando al repository di riferimento in `E:\template-claude-developing` solo quando servono davvero.
