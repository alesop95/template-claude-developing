# Filone: memoria di progetto e vault

> Aperto il 2026-11-12 dal mandato del proprietario, che lo indica come la parte principale: ogni memoria di progetto deve poter diventare un vault Obsidian, secondo il metodo che Andrej Karpathy ha descritto per il proprio wiki, senza togliere niente alla gestione della memoria che il template ha già. Settori di destinazione: «Scrittura, documentazione e tipografia» e «Fonti, ricerca e corpus documentali». Stato al 2026-11-14: il vault è un pacchetto, i due video sono trascritti e letti, il confronto con gli strumenti a monte non è cominciato.

## Che cosa dicono i due video

Il proprietario ha indicato due video, web:https://www.youtube.com/watch?v=t7IXUaRyUAY e web:https://www.youtube.com/watch?v=EP9zPS1jNwA , già nel registro delle fonti. Sono stati trascritti in locale il 2026-11-13, con il riconoscitore sul processore, e letti dalla trascrizione, che è inglese ed è una trascrizione automatica: i nomi propri vi compaiono storpiati e una frase può essere stata resa male. Le trascrizioni stanno nel livello privato del template.

Il primo, di sette minuti, applica il metodo alla ricerca di prodotto. La struttura che descrive è di tre parti: una cartella di materiale grezzo, in sola lettura, dove si mettono articoli, PDF e dati; una cartella di wiki che l'agente compila da quel materiale, fatta di file Markdown con rimandi fra loro e alle fonti; e un file di istruzioni che dice all'agente le regole e lo schema dei dati. A ogni ingestione l'agente crea pagine di concetto e di entità e aggiorna un indice e un registro cronologico. Obsidian serve da interfaccia: il grafo mostra i rimandi. L'autore dichiara tre vantaggi, cioè soglia d'ingresso bassa, costo limitato ai token e relazioni fra i dati rese esplicite, e un limite: funziona fino a circa cinquecento file o un milione di parole, oltre diventa caro. Sono affermazioni dell'autore, non misure.

Il secondo, di venti minuti, spiega prima che cosa fa un recupero per somiglianza, poi costruisce un vault da zero e fa compilare il wiki all'agente con un prompt che crea indice, registro e schema, con pagine per persone e concetti. Aggiunge una distinzione utile: un recupero per somiglianza non conserva l'ordine nel tempo né il perché di un fatto, un grafo sì, e per questo l'autore indica un grafo accanto ai vettori quando il corpus cresce.

In nessuno dei due compare Jev. Il nome che il mandato accostava a questo metodo viene dall'altro materiale consegnato: nel post incollato dal proprietario è un modello che decide in fretta fra azioni, affiancato a quello che ragiona, e nella schermata 457 fa da strato di smistamento fra file, strumento e ripetizione. È quindi materia del filone sull'orchestrazione, non della memoria, e resta da leggere a una fonte primaria.

## Che cosa il template ha già

Il metodo dei video è quello del pacchetto `knowledge-wiki`, che ha fonti immutabili, pagine compilate, uno schema in `WIKI-SCHEMA.md` e un registro `log.md`, e che cita lo stesso testo di Karpathy. Il template non deve quindi adottare il metodo: deve verificare che cosa i video e gli strumenti a monte fanno in più. Da un confronto dei soli nomi, senza prova, mancano a `knowledge-wiki` due cose che i video mostrano: un indice generato delle pagine, e l'apertura del wiki in Obsidian come passo previsto.

La memoria di progetto è un'altra cosa, ed è il punto che il mandato chiede di non confondere: non è un sapere compilato da fonti, è lo stato del lavoro, con indice, registro delle decisioni e work-log, scritto a ogni giro. Per questa il template non cambia formato: la rende navigabile. Il pacchetto `vault-di-progetto`, del 2026-11-13, crea un vault di soli collegamenti sopra memoria, schede e documentazione, perché Obsidian non mostra le cartelle che cominciano con un punto, e vi copia i tre plugin che i vault del proprietario avevano in comune. Niente viene copiato né versionato.

## Che cosa resta da fare, in ordine

Il primo passo è l'osservazione che manca al pacchetto: il proprietario apre il vault di un progetto in Obsidian e dice se i collegamenti si vedono e se il grafo mostra i rimandi. Il secondo è il confronto con le fonti a monte già registrate, ciascuna con le quattro domande di `docs/FILONI.md`: superpowers contro `init-project-system` e `micro-passi`, per capire che cosa aggiunge prima del prompt zero; Understand-Anything e code-review-graph contro graphify, sul costo per domanda; llm_wiki e llm-wiki-v2 contro `knowledge-wiki`, sull'indice e sull'aggiornamento incrementale. Il terzo è la misura che il proprietario ha in mente: se più agenti che leggono la stessa memoria dal vault consumano meno di più agenti che la ricostruiscono, misurato su un progetto reale prima e dopo. Il quarto è la skill che tiene la documentazione poco frammentata, da disegnare dopo aver guardato come l'hanno organizzata i progetti già allineati, che è materia dell'onda 5.

## Limiti di questo documento

Le trascrizioni sono automatiche e non sono state confrontate con il video. Il confronto con `knowledge-wiki` è fatto sui nomi dei file e sulle intestazioni del suo README, non su una corsa. Nessuna delle fonti a monte è stata installata.
