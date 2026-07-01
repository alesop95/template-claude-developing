---
name: gap-analysis
description: >
  Dato un insieme di paper gia' letti in profondita', produce un verdetto per ciascuna possibile
  direzione di ricerca: da non perseguire, condizionale, o promettente, con motivazione
  strutturata, ispirandosi al pattern gap-to-topic. STUB: il formato esatto del verdetto e i
  criteri di soglia si definiscono all'attivazione del pacchetto, sul dominio disciplinare
  specifico del progetto.
disable-model-invocation: true
---

## Stato: stub da completare all'attivazione

Il documento di riferimento descrive questa skill come stadio 5 della pipeline (sezione 9 punto 5), ispirata al pattern community `gap-to-topic` (sezione 8), ma non fissa i criteri operativi con cui una direzione di ricerca si classifica come promettente piuttosto che condizionale: quei criteri dipendono dal dominio disciplinare del progetto (una soglia di evidenza ragionevole in econometria non e' la stessa che in biologia molecolare), che si stabilisce nel gate di `research-scoping`.

## Cosa e' gia' fissato

Il verdetto finale si esprime su una scala a tre valori: da non perseguire, condizionale, promettente, sempre con una motivazione esplicita legata ai paper effettivamente letti, mai a conoscenza generale del modello. Il riferimento completo e' la sezione 9 punto 5 di `research-vault/reference/claude-ricercatore-universitario-completo.md`; per il pattern community citato come ispirazione, vedi la voce `WenyuChiou/ai-research-skills` nella sezione 8 dello stesso documento.

## Come completarla

All'attivazione, una volta noto il dominio disciplinare (da `research-scoping`), riscrivere questo file con i criteri di soglia specifici del dominio e il formato tabellare del verdetto, coerente con l'output gia' prodotto da `deep-paper-reading` e da `corpus-analysis`.
