---
name: artefatto
description: Consegna il risultato come artefatto visivo o interattivo invece che come testo: pagina, diagramma, tabella navigabile.
argument-hint: "[su che cosa applicarlo]"
disable-model-invocation: true
---

# Risultato da guardare

Produci il risultato di `$ARGUMENTS` in una forma che si guarda o si usa: una pagina HTML autonoma, un diagramma, una tabella ordinabile, una linea del tempo, secondo che cosa rende il contenuto più chiaro di un testo.

Prima scegli la forma dal contenuto: relazioni fra parti chiedono un diagramma, confronti una tabella, sequenze una linea del tempo, molti dati un grafico.

Per il design segui l'identità del progetto: il design system indicato dalle istruzioni di account o di progetto, se c'è, e altrimenti lo stile sobrio dei documenti del sistema. Se va prodotto un documento, una presentazione o un PDF, invoca prima la skill `craft-apps`, che usa in locale le applicazioni della suite Craft.

Una pagina di documentazione o di analisi, con qualunque dei due design, ha due proprietà fisse, chieste dal proprietario il 2026-11-26. La prosa occupa tutta la larghezza del contenitore e non si chiude in una colonna stretta, anche dove il design system fissa una misura di riga per il sito. Ogni sezione e sottosezione è comprimibile: l'interruttore è un più/meno a destra del titolo e non una freccia, la pagina si apre con tutte le sezioni chiuse, ha in cima i comandi Espandi tutto e Comprimi tutto, si apre e si chiude anche da tastiera ed esce intera in stampa. Con il design system aziendale l'aspetto è quello del suo componente Accordion, con il filo fra le righe e l'apertura animata; con lo stile sobrio il comportamento è lo stesso e l'animazione non è obbligatoria. Il raggruppamento si fa con uno script in testa alla pagina, che lascia intatto il contenuto statico per chi lo rilegge o lo estrae.

Il file prodotto sta nel progetto, in una cartella dichiarata, e la risposta dice dove. In Claude Code, dove lo strumento degli artefatti è disponibile, lo si può anche pubblicare, ma solo se l'utente lo chiede.

Il nome è `artefatto` perché `/artifacts` in Claude Code è già un comando del client.

Se dopo il comando non c'è testo, l'oggetto è l'ultima cosa di cui si stava parlando: il piano, la proposta, il codice o il documento appena prodotti. Se non è chiaro quale, lo si chiede in una riga prima di cominciare.
