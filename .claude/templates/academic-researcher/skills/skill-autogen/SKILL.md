---
name: skill-autogen
description: >
  Quando un topic disciplinare specialistico ricorre attraverso piu' paper o piu' sessioni di
  ricerca, propone la creazione di una nuova skill dedicata per quel topic invece di reinserire
  lo stesso contesto ogni volta, seguendo il formato di skill-creator. STUB: la soglia di
  ricorrenza che giustifica una nuova skill e il dominio specifico si definiscono
  all'attivazione, per non generare sprawl di skill poco mantenibili.
disable-model-invocation: true
---

## Stato: stub da completare all'attivazione

Il documento di riferimento descrive questa capacita' come stadio 6 della pipeline (sezione 9 punto 6) e come obiettivo esplicito del progetto (sezione 1 punto 4, sezione 8), ma segnala anche un vincolo che impedisce di renderla automatica senza calibrazione: una nuova skill si crea solo quando un topic e' ricorrente e specialistico attraverso piu' sessioni, non per ogni singola query di ricerca (sezione 17). Cosa conti come "ricorrente" dipende dal volume di ricerca del progetto specifico, non e' un numero fisso che il documento definisca.

## Cosa e' gia' fissato

Lo strumento di generazione e' `skill-creator`, gia' disponibile come skill di esempio in ambiente Claude Code, che segue le best practice Anthropic di frontmatter, trigger description e progressive disclosure. Il pattern community citato come riferimento aggiuntivo e' `Skiller` (InternScience), che trasforma log di conversazione o requisiti in linguaggio naturale in pacchetti skill conformi. Prima di proporre una nuova skill, va sempre verificato che il topic non sia gia' coperto da una skill esistente nel progetto.

## Come completarla

All'attivazione, stabilire con l'utente la soglia di ricorrenza che giustifica la proposta (per esempio, un topic emerso in almeno due paper letti in profondita' o in due sessioni distinte), e riscrivere questo file con il flusso concreto: come si rileva la ricorrenza, come si invoca `skill-creator`, e come si presenta la proposta all'utente prima di crearla.
