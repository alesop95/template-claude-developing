# Case-studies di validazione del sistema

> Registro anonimo degli esperimenti con cui si valida il sistema di progetto. Serve a capire
> perche, come e dove funziona meglio, accumulando evidenza riusabile. Regola di anonimato: niente
> nomi di progetto, owner o dominio specifico; si tiene solo l'archetipo tecnico e la lezione.

## Schema di una voce

Data, archetipo del progetto (anonimo), cosa si e testato, esito (cosa ha funzionato e cosa no),
perche/come/dove funziona meglio (la lezione), rifiniture derivate (eventuali cambi al sistema).

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
