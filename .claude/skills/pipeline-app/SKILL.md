---
name: pipeline-app
description: >
  Riconosce in un'applicazione quali controlli servono prima del commit, quali prove
  devono girare in CI dopo il push e se occorre un percorso di deploy. Propone e
  realizza ciascuna fase separatamente quando l'utente chiede di costruire o
  allineare la pipeline; valuta OpenNext solo per app Next.js destinate a
  Cloudflare Workers. Non si attiva per il solo fatto che esista un repository Git.
---

# Pipeline di un'applicazione

Leggi `RIFERIMENTO.md` prima di progettare o modificare una pipeline. Parti dai file del progetto: manifest, test, hook Git, workflow, configurazione degli ambienti e hosting scelto. Dichiara per ciascuna fase se è presente, assente, soltanto prevista o non pertinente, citando il file che lo dimostra. Non inferire un deploy da un comando `build`, né un test eseguito dal solo colore verde della CI.

Le quattro decisioni sono indipendenti: **pre-commit locale**, **CI su push o pull request**, **prova del runtime di destinazione**, **CD verso staging o produzione**. Offri soltanto le fasi motivate dai rischi e dall'obiettivo del progetto; una decisione su una fase non autorizza le altre. Se l'utente ne sceglie una o tutte, implementa il perimetro scelto e verifica il comportamento con un test che attraversi il punto di guasto. Per un'app che scrive su un servizio di prova, controlla che il servizio esista e che i test lo raggiungano davvero; se i test possono saltarlo in silenzio, valuta il tool della skill `prove-che-misurano` prima della suite.

Quando il progetto usa Next.js e vuole girare su Cloudflare Workers, leggi la sezione OpenNext del riferimento e la documentazione corrente di Next.js, OpenNext e Cloudflare. Verifica versioni, output server, compatibilità delle dipendenze e risorse esterne. OpenNext è un adapter condizionale, non una dipendenza da aggiungere a ogni app React o Next.js.

Scrivi le scelte e le prove in `context/dev-testing.md`, `context/deployment.md` e, se architetturali, in `memory/decisions.md` del progetto; lascia un rinvio esplicito per le fasi non scelte. Non creare account, segreti o ambienti remoti come conseguenza implicita della progettazione. `git add`, commit, push e deploy restano manuali dell'utente secondo le regole della macchina.
