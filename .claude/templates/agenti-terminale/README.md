# Pacchetto opzionale: agenti-terminale

> Catena completa per far convivere **N radici di Claude Code e M radici di Codex CLI** sulla stessa macchina, isolate, ripristinabili da zero e ripulite all'uscita. Installazione, avvio, pulizia selettiva, comandi brevi di shell e misura del consumo. E' generico: non contiene alcun valore di alcuna macchina.

## Cosa risolve

Usare piu' account dello stesso agente, o due agenti diversi, sulla stessa macchina pone quattro problemi che nessuno dei due strumenti risolve da se': tenere le identita' **isolate**, poterle **ricostruire** dopo una formattazione, **ripulire** cio' che resta a fine sessione, e **sapere quanto si e' consumato** su ciascuna.

Il pacchetto li copre tutti e quattro, per entrambi gli agenti, sotto un unico punto d'ingresso.

## L'asimmetria fra i due agenti, che spiega perche' i motori sono diversi

E' l'unica cosa da capire prima di leggere il resto, e non e' arbitraria.

**Claude Code ha un hook di fine sessione**: un comando registrato nel `settings.json` dell'account che punta a un file. Lo script di pulizia **deve** quindi esistere come copia dentro ogni radice, e l'installatore lo mette li' sostituendo i segnaposto.

**Codex non ha un hook di ciclo di vita.** Si avvia da un **wrapper**, che imposta la radice, verifica le guardie e fa la pulizia al ritorno del processo. I suoi script restano quindi nel pacchetto e nessuna copia finisce nelle radici.

Stessa invocazione per l'utente, motori diversi sotto. Cio' che l'utente vede e' simmetrico:

```powershell
cd <progetto>
claude-account2
codex-account2
```

## I pezzi

| File | Ruolo |
|---|---|
| `tools/Installa-Agenti.ps1` | **punto d'ingresso**: prerequisiti, dipendenze, chiama i due installatori e i comandi |
| `tools/Installa-Claude.ps1` + `merge-claude-settings.js` | installa il wipe di fine sessione nelle radici Claude e registra l'hook nel `settings.json` preservando ogni altra chiave |
| `tools/Installa-Codex.ps1` | crea le radici Codex, vi scrive la configurazione di riferimento e il puntatore `AGENTS.md` |
| `tools/Avvia-Codex.ps1` | avvio su radice isolata, con vincolo sulla cartella di lavoro e pulizia all'uscita |
| `tools/Pulisci-Codex.ps1` | wipe selettivo degli store, con tre guardie |
| `tools/Installa-Comandi.ps1` | scrive nel profilo PowerShell i comandi brevi per tutte le radici presenti |
| `tools/Consumo-Agenti.ps1` | consumo di token di **tutte** le radici dei due agenti, radici di default comprese |
| `codex-config.riferimento.toml` | configurazione di una radice Codex |
| `codex-agents.riferimento.md` | `AGENTS.md` distribuito nelle radici: puntatore, mai copia |

## Che cosa NON contiene, e perche'

**Nessun valore di macchina.** I due soli valori specifici sono i **prefissi degli slug da preservare** nel wipe, che dipendono dalle lettere di disco su cui vivono i progetti, e il **numero di radici**. Sono parametri, e vivono nel repository della macchina insieme al suo punto d'ingresso.

**Nessuna credenziale, mai.** Il ripristino ricostruisce radici e configurazioni, non gli accessi: si rifa' un login per radice e per agente. Non e' un limite ma la scelta corretta, e vale dirla per esteso perche' la tentazione opposta e' forte: una credenziale copiata da una macchina all'altra e' una credenziale uscita dal proprio custode, e sopravvive in un backup molto piu' a lungo della ragione per cui era stata copiata.

**Nessun orchestratore.** Far lavorare piu' agenti insieme su un compito e' materia del pacchetto `lavoro-a-lotti`, che poggia su questo ma non lo richiede.

## La chiusura di una sessione

Il pacchetto porta con se' la regola `rules/chiusura-delle-sessioni.md`, che va dichiarata fra quelle caricate. Il principio in una riga: **una sessione che si considera chiusa per davvero va rimossa, non abbandonata**, perche' abbandonarla la lascia in un magazzino che il wipe preserva apposta.

Le attuazioni differiscono: Codex ha il comando nativo `/delete`, che cancella la sessione ed esce; Claude Code non ha un equivalente e la rimozione va fatta a mano sul magazzino dell'account.

E' il completamento del wipe, non un suo doppione: **il wipe copre l'incuria, questa regola copre la volonta'.**

## Mappa di istanziazione

| Dal pacchetto | Nel progetto di macchina |
|---|---|
| tutto `tools/` e i due riferimenti | **niente**: si chiamano dal template, non si copiano |
| — | uno script sottile che conosce il percorso del template e i prefissi della macchina |

E' la differenza rispetto agli altri pacchetti, e va detta: **questo non si istanzia copiando.** Il repository della macchina non ne contiene una copia ma una **chiamata**, perche' due copie divergerebbero in silenzio e la correzione fatta in una non arriverebbe all'altra.

## Ripristino dopo una formattazione

```powershell
.\scripts\Agenti.ps1 verifica
.\scripts\Agenti.ps1 installa
```

Il primo non modifica nulla. Il secondo installa Codex se manca, crea le radici dei due agenti, vi scrive configurazioni e hook, registra i comandi brevi, e stampa l'elenco dei login da fare.

Su una macchina nuova servono due cloni: il template, che porta la catena, e il repository di macchina, che porta i valori.

## Vincoli e onesta'

Gli installatori sono **idempotenti**: rieseguirli non sovrascrive cio' che c'e', salvo `-Forza`, che riallinea dai riferimenti. Ma `-Forza` sostituisce **l'intero** file di configurazione, e Codex vi scrive anche proprio stato: cio' che l'agente ha messo da se' viene perso. E' successo davvero con la scelta della sandbox di Windows, riportando radici gia' configurate allo stato iniziale.

I **prefissi del wipe non si indovinano, si leggono**, con il modo di sola lettura di `Pulisci-Codex.ps1`. Un insieme sbagliato non produce un errore: preserva l'insieme vuoto e cancella tutto, facendo esattamente cio' che gli e' stato chiesto.

I **server MCP di account** non sono ripristinati e vanno ricreati a mano.
