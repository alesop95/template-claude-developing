# Pacchetto academic-researcher

> Pacchetto opzionale del sistema di progetto. Trasforma un progetto Claude in un ambiente di ricerca accademica assistita: scoping del topic, ricerca della letteratura, lettura profonda dei paper, tracciamento tripartito delle fonti (verificata, da verificare, scartata), analisi di un corpus gia' caricato secondo nove modalita' collaudate, e sincronizzazione di un file `.bib` tra Zotero e JabRef. Deriva per intero dal modulo di ricerca `references/claude-ricercatore-universitario-completo.md`, che resta la fonte di verita' per ogni scelta architetturale qui riportata: in caso di dubbio interpretativo su una skill, si consulta quel documento prima di improvvisare. Si offre al gate dei pacchetti (vedi `../PACKAGES.md`) ai progetti di ricerca accademica, di tesi, o di analisi sistematica di un corpus di paper; non si propone se il progetto ha gia' un proprio sistema di gestione bibliografica equivalente.

## Cosa e' concreto e cosa e' stub

Non tutte le sette skill che compongono il pacchetto hanno lo stesso livello di completezza, ed e' importante saperlo prima di attivarle: la trasparenza su questo punto e' un requisito di onesta' del contenuto del template, non un dettaglio implementativo. Quattro skill hanno un corpo operativo completo perche' il documento di riferimento ne fissa il comportamento in modo concreto: `corpus-analysis` (i nove prompt collaudati, sezione 10), `citation-tracker` (la tripartizione verificata/da verificare/scartata, sezione 7), `bib-sync` (il flusso Zotero-JabRef, sezione 3), `research-scoping` (le domande di gate, sezione 18). Quattro skill sono invece stub dichiarati: `literature-search`, `deep-paper-reading`, `gap-analysis`, `skill-autogen` descrivono cosa fanno e citano la sezione del documento di riferimento rilevante, ma rimandano il dettaglio operativo (quali MCP sono connessi, se Docker e GROBID sono disponibili, quali soglie di ricorrenza) al momento dell'attivazione in un progetto reale, quando quelle scelte sono note. Completarle senza quel contesto avrebbe significato inventare un comportamento non verificato.

## Mappa di istanziazione

```
templates/academic-researcher/rules/no-uncited-claims.md          ->  <radice>/.claude/rules/no-uncited-claims.md               (tracciato)
templates/academic-researcher/skills/corpus-analysis/              ->  <radice>/.claude/skills/corpus-analysis/                  (tracciato)
templates/academic-researcher/skills/citation-tracker/              ->  <radice>/.claude/skills/citation-tracker/                 (tracciato)
templates/academic-researcher/skills/bib-sync/                      ->  <radice>/.claude/skills/bib-sync/                         (tracciato)
templates/academic-researcher/skills/research-scoping/              ->  <radice>/.claude/skills/research-scoping/                 (tracciato)
templates/academic-researcher/skills/literature-search/             ->  <radice>/.claude/skills/literature-search/                (tracciato, stub)
templates/academic-researcher/skills/deep-paper-reading/            ->  <radice>/.claude/skills/deep-paper-reading/               (tracciato, stub)
templates/academic-researcher/skills/gap-analysis/                  ->  <radice>/.claude/skills/gap-analysis/                     (tracciato, stub)
templates/academic-researcher/skills/skill-autogen/                 ->  <radice>/.claude/skills/skill-autogen/                    (tracciato, stub)
templates/academic-researcher/references/claude-ricercatore-universitario-completo.md -> <radice>/research-vault/reference/claude-ricercatore-universitario-completo.md (tracciato)
(creato vuoto alla prima sincronizzazione)                           <radice>/research-vault/bibliography.bib                     (tracciato)
(creato alla prima invocazione di research-scoping)                  <radice>/research-vault/scope.md                             (tracciato)
(creato alla prima invocazione di citation-tracker)                  <radice>/research-vault/tracked-sources.md                   (tracciato)
```

Il documento di riferimento si instanzia dentro `research-vault/` invece che restare nella cartella del template, cosi' che ogni skill lo raggiunga con lo stesso percorso relativo (`research-vault/reference/...`) indipendentemente da dove il pacchetto viene attivato, e cosi' che un collega che clona il repository lo trovi accanto ai dati bibliografici che descrive.

## MCP server e tool esterni collegati

Il pacchetto non installa da solo alcun MCP server ne' alcun tool esterno: la scelta resta al gate dei pacchetti, con `research-scoping` che raccoglie le preferenze dell'utente e le registra in `research-vault/scope.md`. Il catalogo `../PACKAGES.md` elenca separatamente le voci concrete raccomandate dal documento di riferimento (sezione 15): i server MCP `zotero-mcp`, `academix`, `semantic-scholar-mcp` e `refchecker-mcp`, e i tool esterni `arxiv-cli`, `grobid` e `paperqa2`. Nessuno di questi e' un prerequisito per attivare `academic-researcher`: le skill concrete (`citation-tracker`, `bib-sync`) hanno un percorso manuale di fallback quando il MCP corrispondente non e' connesso, descritto nel loro stesso `SKILL.md`.

## Come si usa, passo per passo

1. Attivazione, al gate dei pacchetti in init o allineamento: si crea l'anatomia sopra, con `research-vault/reference/` gia' popolato dal documento di riferimento.
2. Si invoca `research-scoping`: definisce la domanda di ricerca e raccoglie le risposte alle domande di gate (dominio disciplinare, libreria Zotero esistente o meno, output LaTeX o Word, livello di autonomia, abbonamenti istituzionali). L'esito va in `research-vault/scope.md`.
3. Sulla base dello scope, si decide con l'utente quali MCP o tool esterni del catalogo attivare (`zotero-mcp`, `academix`, `semantic-scholar-mcp`, `refchecker-mcp`, `arxiv-cli`, `grobid`, `paperqa2`), rispettando il limite di 3-4 MCP nuovi per sessione gia' fissato in `../PACKAGES.md`.
4. Si completano gli stub pertinenti (`literature-search`, `deep-paper-reading`, `gap-analysis`, `skill-autogen`) alla luce delle scelte appena fatte, seguendo la sezione "Come completarla" di ciascun `SKILL.md`.
5. Da qui in avanti il ciclo e' quello descritto nella sezione 14 del documento di riferimento: `literature-search` produce candidati, `citation-tracker` li verifica, `bib-sync` li sincronizza in Zotero e nel `.bib`, `deep-paper-reading` legge in profondita' i paper verificati, `corpus-analysis` applica le nove modalita' al sottoinsieme verificato e caricato in conversazione, `gap-analysis` produce i verdetti sulle direzioni di ricerca, e `skill-autogen` propone nuove skill quando un topic diventa ricorrente.
6. Prima di ogni consegna o sottomissione, `research-vault/bibliography.bib` va aperto e validato in JabRef: nessuna skill del pacchetto lo considera mai definitivo da sola.

## Recap dei comandi

- Definire lo scope di un nuovo topic: invoca la skill `research-scoping`.
- Verificare una fonte: invoca la skill `citation-tracker`.
- Sincronizzare Zotero e il `.bib`: invoca la skill `bib-sync`.
- Analizzare un corpus gia' caricato: invoca la skill `corpus-analysis`, per nome di modalita' (per esempio "fai il Gap Scanner") o per intento.
- Consultare l'architettura completa e le raccomandazioni originali: apri `research-vault/reference/claude-ricercatore-universitario-completo.md`.
- Versionare l'avanzamento della ricerca: `git add research-vault/ .claude/skills/ .claude/rules/no-uncited-claims.md` seguito da commit (operazione manuale dell'utente).

## Riferimenti e crediti

Il documento di riferimento cita l'intero ecosistema di strumenti alla base delle scelte architetturali del pacchetto; i crediti completi, con licenza e repository, sono nella sezione "Riferimenti e strumenti open source" del `README.md` di radice del template e nelle righe di catalogo dedicate in `../PACKAGES.md`. In sintesi: Zotero e Better BibTeX come libreria di lavoro, JabRef come editor e validatore del `.bib`, `54yyyu/zotero-mcp` per l'integrazione MCP con Zotero, `xingyulu23/Academix` e `akapet00/semantic-scholar-mcp` per la ricerca letteratura, `JonasBaath/mcp-refchecker` per la verifica anti-hallucination delle citazioni, GROBID e `Future-House/paper-qa` (PaperQA2) per il parsing e la lettura profonda dei paper, `AstraBert/arxiv-cli` per il recupero rapido senza MCP.
