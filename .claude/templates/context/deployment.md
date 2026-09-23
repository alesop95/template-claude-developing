---
generated-from-commit: <hash del commit di prima scrittura>
generated-from-branch: <branch>
generated-date: <YYYY-MM-DD>
covers-paths:
  - <glob delle aree descritte, es. infra/**, .github/**>
last-verified-commit: <hash dell'ultima verifica o aggiornamento>
---

# Deployment

> Popolare leggendo la configurazione reale di infrastruttura e CI. Commit, push e deploy restano operazioni manuali dell'utente.

## Livelli

<descrizione dei livelli test/staging e produzione, hosting, domini>

## Alberi di lavoro

> Da compilare solo se il progetto tiene gli ambienti in alberi di lavoro separati (`git worktree`), secondo la regola `.claude/rules/alberi-di-lavoro.md`. Con un albero solo la sezione si rimuove.

| Percorso assoluto | Branch | Ambiente | Porta | Note |
|---|---|---|---|---|
| <percorso> | <main> | <produzione> | <porta> | <albero da non toccare durante il lavoro> |
| <percorso> | <staging> | <test> | <porta> | <base dati e `.env` propri> |

Albero autorevole per la memoria: `<percorso assoluto>` (branch `<branch più avanti>`). La memoria sotto `.claude/memory/` si legge da quell'albero per percorso assoluto e non si copia né si fonde negli altri; le decisioni prese altrove si registrano lì. La riga si aggiorna quando un'altra branch passa avanti, per esempio dopo una fusione.

## Comandi

<comandi di build, di rilascio e di rollback, con il contesto in cui si eseguono>

## Variabili d'ambiente e segreti

<elenco delle variabili richieste e dove sono gestite; i valori non si committano mai>
