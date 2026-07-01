---
name: literature-search
description: >
  Cerca nuovi paper sui MCP di letteratura scelti in research-scoping (tipicamente academix e
  semantic-scholar-mcp, vedi ../PACKAGES.md), aggiungendo ogni risultato a una lista di candidati
  prima che citation-tracker lo verifichi: nessun paper si cita direttamente dalla memoria del
  modello. STUB: l'operativita' esatta (quali MCP sono connessi in questo progetto, come si
  usa arxiv-cli per uno scan rapido preliminare) si definisce all'attivazione del pacchetto,
  leggendo research-vault/scope.md prodotto da research-scoping.
disable-model-invocation: true
---

## Stato: stub da completare all'attivazione

Questa skill non ha ancora un corpo operativo completo, perche' il documento di riferimento la descrive a livello architetturale (sezione 9 punto 2, sezione 14) ma senza fissare i dettagli specifici di ogni progetto: quali MCP di ricerca sono effettivamente connessi (`academix`, `semantic-scholar-mcp`, o alternative), se `arxiv-cli` e' installato per uno scan rapido preliminare, e quali credenziali API sono disponibili. Scrivere qui un flusso dettagliato senza conoscere queste scelte violerebbe la regola di onesta' del contenuto del template: si rischierebbe di presentare come operativo un comportamento non ancora verificabile.

## Cosa e' gia' fissato, e va rispettato quando la skill si completa

Il vincolo esplicito e non negoziabile, gia' definito nel documento di riferimento (sezione 9 punto 2): ogni paper trovato va aggiunto a una lista di candidati prima di essere citato, mai citato direttamente dalla memoria del modello. Ogni candidato passa poi da `citation-tracker` prima di poter comparire in un testo o nel `.bib`. Il capitolo di riferimento completo, coi MCP disponibili e le raccomandazioni, e' la sezione 5 e la sezione 11 (per `arxiv-cli`) di `research-vault/reference/claude-ricercatore-universitario-completo.md`.

## Come completarla

All'attivazione del pacchetto, una volta noto quali MCP il progetto ha effettivamente connesso (domanda di gate in `research-scoping`), riscrivere questo file con il flusso reale: quale MCP interrogare per primo, come si usa `arxiv-cli` se presente, e come i risultati confluiscono nella lista candidati.
