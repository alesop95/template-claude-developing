# Fonti di scouting del template

> Registro delle fonti che si ricontrollano ogni tanto per trovare strumenti da portare nel template. Una fonte di scouting segnala un repository e basta: ciò che il template ne scrive si legge sempre sul repository. Indice dei filoni in `docs/FILONI.md`; percorso di ingresso nel catalogo nella sezione «Come estendere il sistema» del `README.md` di radice.

## Come si usa

Un passaggio di scouting parte dalla tabella delle fonti e guarda solo ciò che la fonte ha pubblicato dopo l'ultimo controllo. Per ogni progetto pertinente legge licenza, ultimo push e stato di archiviazione sul repository, sceglie il settore del catalogo o il filone che lo accoglierebbe, e lo scrive fra i candidati con l'esito. Un candidato diventa voce di catalogo solo dopo le quattro domande di `docs/FILONI.md`. A fine passaggio si aggiorna la data dell'ultimo controllo, anche quando non è emerso niente, perché una fonte senza data sembra mai guardata.

Dal 2026-10-21 il feed di ogni fonte e ogni repository fra i candidati stanno anche nel registro delle fonti a monte, `.claude/templates/fonti-a-monte.json`, il primo con il ruolo `scouting` e i secondi con il ruolo `candidati`, e il documento generato `.claude/templates/fonti-a-monte.md` li traccia insieme a tutte le altre fonti del template. Il passaggio quindi non dipende più dal ricordarsene: `fonti-a-monte.py controlla`, all'apertura di ogni sessione del template, dice quante voci il feed ha pubblicato dopo l'ultima verifica e se un candidato è stato archiviato, rinominato o ha cambiato licenza. A fine passaggio, oltre alla data in tabella, si registra la verifica del feed con `fonti-a-monte.py segna feed:<url>`; una fonte nuova si aggiunge alla tabella con l'URL completo del suo feed, che il censimento riconosce da sé.

## Fonti

| Fonte | Che cosa vi si cerca | Come si legge | Ultimo controllo | Affidabilità |
|---|---|---|---|---|
| `opensourceprojects.dev` | Repository open source segnalati a raffiche, prevalentemente strumenti per sviluppatori, self-hosting e agenti di programmazione | Il sito è un'applicazione che senza JavaScript non mostra contenuti: si legge dal feed RSS `/rss` (solo le 12 voci più recenti), dal feed Atom `https://www.opensourceprojects.dev/feed.xml` e dalla sitemap, che è l'unico indice completo | 2026-10-16, 240 post dal 2026-09-20 | Operatore non dichiarato, nessuna categoria, pubblicazione automatica in lotti, testi probabilmente generati, nessuna licenza sui contenuti: radar di segnalazioni, mai testo da citare o copiare |
| Thread del subreddit ClaudeAI «Drop your best Claude skills in here!», post `1xevkyg` del 2026-10-25, `https://www.reddit.com/r/ClaudeAI/comments/1xevkyg/` | Skill e plugin che gli utenti dichiarano di usare davvero, segnalati dal proprietario il 2026-10-27 come fonte per aggiornare le skill del template | Reddit rifiuta il recupero diretto con 403; si legge dall'archivio pubblico Arctic Shift con `python .claude/templates/community-sources/tools/fetch-reddit.py --radice <template> post 1xevkyg`, che salva il thread in `_notes/fonti/`. A ogni passaggio si confronta il numero di commenti con quello dell'ultimo controllo e si leggono solo i nuovi | 2026-10-27, 65 commenti su 63 dichiarati, 13 collegamenti esterni | Commenti di utenti anonimi, punteggi bassi tranne pochi: una segnalazione e basta. L'archivio ha latenza verso Reddit e conserva anche ciò che è stato cancellato |

## Candidati dal passaggio del 2026-10-16

Selezione di venti progetti su 240 post, delegata a un subagent e riletta. Licenza, ultimo push e archiviazione letti dall'API di GitHub il 2026-10-16; nessun repository è archiviato; nessuno è stato installato o provato. Quelli con licenza «da leggere» hanno un file di licenza che GitHub non riconosce come standard, e lo si legge prima di qualunque proposta. Gli strumenti di assessment di sicurezza segnalati dalla fonte sono stati instradati al filone `docs/filone-cybersecurity.md` e non compaiono qui.

| Progetto | Che cosa fa | Destinazione | Licenza | Esito |
|---|---|---|---|---|
| `Dicklesworthstone/destructive_command_guard` | Hook che ferma comandi git e di shell distruttivi prima che l'agente li esegua | Fondamenta e igiene | Da leggere | Da valutare accanto alle regole deny di `settings.json`, come seconda barriera |
| `onecli/onecli` | Ambiente per agenti in sandbox in cui le credenziali non lasciano il gateway | Orchestrazione di agenti | Apache-2.0 | Riferimento per l'isolamento dei segreti degli agenti |
| `hashgraph-online/awesome-codex-plugins` | Elenco curato di plugin e skill per Codex | Orchestrazione di agenti | Apache-2.0 | Seconda fonte di scouting per Codex, da aggiungere alla tabella delle fonti dopo un controllo |
| `cocoindex-io/cocoindex-code` | Ricerca nel codice basata sull'albero sintattico, a riga di comando | Economia del contesto | Apache-2.0 | Dichiara di ridurre i token: si misura prima e dopo, come chiede `token-economy.md` |
| `CodeGraphContext/CodeGraphContext` | Server MCP e CLI che indicizza il codice in un grafo | Comprensione di una codebase | MIT | Da confrontare con `graphify`; costo di contesto del server MCP da dichiarare |
| `sourcebot-dev/sourcebot` | Ricerca self-hosted su molti repository, con citazioni | Comprensione di una codebase | MIT | Utile per cercare fra tutti i progetti istanziati dal template |
| `zvec-ai/zvec-grep` | Ricerca locale ibrida, testuale e vettoriale, per persone e agenti | Fonti e corpus documentali | Apache-2.0 | Da affiancare a `doc-ingest` |
| `camelot-dev/camelot` | Estrae tabelle da PDF in modo deterministico | Fonti e corpus documentali | MIT | Coerente con il principio deterministico prima del linguistico |
| `b4rtaz/distributed-llama` | Inferenza distribuita su più macchine domestiche in rete | Filone modelli locali senza GPU | MIT | Da aggiungere a `docs/filone-llm-locali-senza-gpu.md` come alternativa: più CPU invece di più RAM |
| `handy-computer/transcribe.cpp` | Trascrizione vocale su CPU in C/C++ | Voce e audio | MIT | Trascrizione locale senza servizi a pagamento |
| `borgmatic-collective/borgmatic` | Backup deduplicati e cifrati configurati da file, con controlli integrati | Macchine e continuità operativa | GPL-3.0 | Il repository GitHub è un mirror: la sede ufficiale va letta prima |
| `langfuse/langfuse` | Tracciamento, valutazione e misura dei costi di applicazioni LLM | Economia del contesto | Da leggere: nucleo MIT e cartelle enterprise separate, secondo il repository | Richiede un servizio ospitato; pertinente alla misura dei token |
| `backnotprop/plannotator` | Annotazione visiva di piani e diff degli agenti, con ritorno all'agente | Sviluppo, qualità e revisione | Apache-2.0 | Da provare su un progetto reale |
| `asheshgoplani/agent-deck` | Gestore da terminale di sessioni Claude, Codex e altri agenti | Orchestrazione di agenti | MIT | Da confrontare con `nimbalyst` e `psmux` |
| `kdlbs/kandev` | Kanban che orchestra più agenti e apre pull request | Orchestrazione di agenti | AGPL-3.0 | Solo come strumento esterno, mai come dipendenza |
| `miqdadbadjuber/anti-slop` | Regole per agenti contro interfacce, testi e codice dall'aspetto generico | Artefatti visivi | MIT | Omonimo del pacchetto `anti-slop` del template ma distinto: le regole sulle interfacce possono integrarlo |
| `Manavarya09/design-extract` | Estrae i token di design di un sito nel formato DTCG | Artefatti visivi | MIT | Rispettare i diritti dei siti analizzati |
| `Zettlr/Zettlr` | Editor Markdown con Pandoc e citazioni Zotero | Scrittura e tipografia | GPL-3.0 | Applicazione desktop, non pacchetto di progetto |
| `aipoch/open-science` | Banco di lavoro per la ricerca scientifica, locale | Domini scientifici | Apache-2.0 | Maturità da verificare su un caso reale |

## Candidati dal thread del subreddit ClaudeAI, passaggio del 2026-10-27

Thread letto per intero dall'archivio Arctic Shift il 2026-10-27; licenza, ultimo push, stelle e archiviazione letti dall'API di GitHub lo stesso giorno. Nessun progetto è stato installato o provato. Le idee senza repository, come la skill di chiusura della sessione descritta in un commento o la conversione da Markdown a un documento con il marchio aziendale, sono già coperte da `chiudi` con la regola `chat-non-e-memoria` e dal pacchetto `craft-apps`, e restano osservazioni.

| Progetto | Che cosa fa | Destinazione | Licenza | Esito |
|---|---|---|---|---|
| `Sushegaad/Claude-Skills-Governance-Risk-and-Compliance` | Trentasei skill di conformità, aggiornate ogni mese | Sicurezza informatica e assessment | MIT | Catalogato il 2026-10-27 come pacchetto `grc-skills` |
| `kunchenguid/no-mistakes` | Controllo che si interpone al push, 8.986 stelle | Fondamenta e igiene | MIT | Da confrontare con i controlli di `chiudi` e con il gancio pre-commit di `gancio-globale`, come seconda barriera prima del push |
| `k45sle/Claude-auto-pause` | Plugin che ferma Claude prima del limite d'uso e lascia una nota di passaggio verificata | Economia del contesto | MIT | Pertinente a `token-economy` e alla nota di passaggio; da leggere, 9 stelle, push del 2026-10-22 |
| `integralist/agent-skills` | Raccolta personale di skill d'uso quotidiano | Orchestrazione, sessioni e cataloghi di agenti | Nessuna dichiarata | Si studia e non si riusa |
| `ehosca/hosca-plugins` | Marketplace di plugin per Claude Code | Orchestrazione, sessioni e cataloghi di agenti | MIT | Nessuna stella, ultimo push del 2026-07-05: maturità da verificare prima di qualunque proposta |
| Gist `falsifier` di xificurC | Skill che cerca contraddizioni, regole nascoste e presupposti sbagliati in una specifica o in un codice, e restituisce un elenco ordinato | Sviluppo, qualità e revisione | Da leggere: un gist non dichiara licenza di per sé | Vicina alla skill `prove-che-misurano`; da leggere prima di proporla |
| `manish-uxai/design-review` | Skill installata con `npx skills add` che cerca valori di colore scritti a mano e componenti duplicati | Artefatti visivi | Nessuna dichiarata, ultimo push del 2026-07-02 | Si studia e non si riusa; da confrontare con il controllo di interfaccia di `anti-slop` |
