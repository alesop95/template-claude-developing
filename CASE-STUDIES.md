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

Si aggiungono, sempre in data 2026-07-02, i quattro pacchetti derivati dal bundle Cranot dell'utente. `claude-code-handoff` e' parzialmente verificato gia' all'integrazione: il percorso di confronto versione contro la fonte upstream e' stato esercitato dal vivo (lettura di `.update-state.json`, release v2.1.39, rilevamento dello stallo della fonte ferma da febbraio 2026), mentre restano da validare la ri-distillazione via `claude -p`, il comando `/refresh-handoff` su una guida reale scaricata, e il workflow GitHub Actions su un repository con il secret configurato. `stack-profiles` e' da validare sull'istanziazione reale di un profilo e sulla sua tenuta come regola nelle sessioni successive. `hooks-starter` e' da validare sulla registrazione degli hook nel `settings.json` di un progetto reale su entrambe le piattaforme, in particolare la resa dell'output di `session-context` nel contesto di sessione e il comportamento non bloccante degli script difensivi. `dev-skills` e' da validare sull'uso reale di `test-generator` e `mcp-tool-scaffold`, e per le due skill di review sulla convivenza dichiarata con le skill native omonime.

Si aggiunge inoltre, sempre in data 2026-07-02, il pacchetto `automation-starter`, rimasto fuori da questo registro al momento della sua introduzione. E' da validare sulle tre vie dichiarate nel proprio README: la corsa locale via `headless-run.ps1`/`.sh` con autenticazione da abbonamento, il workflow GitHub Actions con token `CLAUDE_CODE_OAUTH_TOKEN` generato da `claude setup-token`, e in particolare i limiti di quota e la cadenza minima della terza via nativa (`/schedule`), che il proprio README dichiara esplicitamente non verificati con una fonte esterna al momento della stesura.

Si aggiunge, in data 2026-07-02, il pacchetto `agent-catalog`. E' parzialmente verificato gia' all'integrazione, sullo stesso modello di `claude-code-handoff`: il meccanismo di elenco, fetch e controllo aggiornamento e' stato esercitato dal vivo contro la fonte reale `0xfurai/claude-code-subagents` su entrambe le varianti PowerShell e POSIX, incluso il download effettivo di un agente (`react-expert.md`), il rifiuto corretto di sovrascriverlo senza `-Force`/`--force`, e il confronto di commit sha con rilevamento corretto di "nessuno stato precedente" alla prima corsa e "nessuna novita'" alla corsa successiva. Restano da validare su un progetto reale la scelta e l'integrazione effettiva di un agente pescato nel workflow di sviluppo, e l'effettivo comportamento dopo trenta giorni di mancato controllo (segnalazione di stallo della verifica locale, non ancora osservata perche' il pacchetto e' nuovo).

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
