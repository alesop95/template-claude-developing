# vault-di-progetto

<!-- readme-summary: Un vault Obsidian sopra la memoria e la documentazione del progetto, fatto di soli collegamenti, con i tre plugin di base copiati da un vault già presente sulla macchina. -->

> Rende navigabili in Obsidian la memoria versionata, le schede di contesto e la documentazione di un progetto, con il grafo dei rimandi fra i documenti, senza copiare un solo file e senza versionare niente di nuovo. Nasce dal mandato del proprietario del 2026-11-12: ogni memoria di progetto deve poter diventare un vault.

## Il problema che risolve

La memoria del sistema sta sotto `.claude/`, e Obsidian non mostra le cartelle il cui nome comincia con un punto: aprire la radice del progetto come vault lascia fuori proprio la memoria e le schede. La via comoda, copiarle in una cartella visibile, produce due verità, e la regola `chat-non-e-memoria.md` esiste per impedirlo. Qui il vault è una cartella di soli collegamenti alle cartelle vere, quindi ciò che si legge è il file versionato e ciò che si scrive in Obsidian finisce in quel file.

## Che cosa crea

```
_vault/
  memoria   ->  .claude/memory
  contesto  ->  .claude/context
  docs      ->  docs
  .obsidian/    plugin di base e impostazioni
```

Su Windows i collegamenti sono giunzioni di cartella, che non chiedono privilegi di amministratore; su Linux e macOS sono collegamenti simbolici. Una cartella che il progetto non ha viene saltata e il comando lo dice. La cartella `_vault/` è una vista e non si versiona: si ricrea con un comando, e `--ignora` aggiunge la riga al `.gitignore`.

## Uso

```bash
python tools/vault-progetto.py crea --ignora
python tools/vault-progetto.py verifica
python tools/vault-progetto.py togli
```

Dopo `crea`, in Obsidian si sceglie «Apri cartella come vault» sulla cartella `_vault`. La prima apertura chiede di fidarsi dei plugin della cartella: è la domanda di Obsidian, e la risposta spetta a chi apre. `verifica` esce con zero se i collegamenti puntano alle cartelle vere, i tre plugin sono installati e la cartella è ignorata da git. `togli` rimuove collegamenti e configurazione, e si ferma se al posto di un collegamento trova una cartella vera.

## I plugin di base

Sono tre, e non sono una scelta di questo pacchetto: il 2026-11-12 erano i plugin comuni a cinque vault del proprietario, ed è lui che ha indicato di prendere quelli. `obsidian42-brat`, da `https://github.com/TfTHacker/obsidian42-brat`, installa e aggiorna plugin che non stanno nel catalogo ufficiale. `new-3d-graph`, da `https://github.com/Apoo711/obsidian-3d-graph`, mostra il grafo dei documenti in tre dimensioni, con filtri. `embed-html`, da `https://github.com/mnaoumov/obsidian-embed-html`, incorpora in una nota un file HTML, che è ciò che serve per le mappe e le guide del sistema. I primi due sono sotto licenza MIT, letta a monte lo stesso giorno; la licenza del terzo non è stata letta.

Il comando li copia da un vault già presente sulla macchina, indicato con `--da-vault <cartella>` o in `~/.config/vault-riferimento.txt`, una riga con il percorso. È una copia locale e senza rete di codice che il proprietario ha già scelto di eseguire, con le sue impostazioni. Dove un vault di riferimento non c'è, il comando scrive la sola configurazione ed elenca i plugin da installare da Obsidian. Un plugin è codice che gira dentro Obsidian con i permessi dell'utente, quindi questo strumento non ne scarica nessuno da sé, e la versione copiata è quella del vault di riferimento, non l'ultima: ad aggiornarla pensa Obsidian, e BRAT per ciò che è installato da lui.

## Quando offrirlo, e quando no

Il gate lo propone quando Obsidian è installato sulla macchina e il progetto ha una documentazione abbastanza ampia da perdersi, cioè qualche decina di file Markdown fra `docs/`, memoria e schede, oppure quando l'utente chiede di vedere le relazioni fra i documenti. Si verifica con un comando: su Windows la cartella `Obsidian` sotto i dati locali dell'utente, altrove il comando `obsidian`.

Non si propone dove Obsidian non c'è, perché il pacchetto non lo installa. Non serve a un progetto con pochi documenti, dove l'indice della memoria basta. Non sostituisce `knowledge-wiki`, che costruisce un sapere da fonti, né il motore di lettura ancorata, che legge documenti esterni: qui si guarda soltanto ciò che il progetto ha già scritto. E su una macchina remota senza interfaccia grafica non ha oggetto.

## Limiti dichiarati

Che Obsidian segua le giunzioni di Windows e i collegamenti simbolici è il comportamento su cui il pacchetto poggia: lo strumento è stato provato il 2026-11-12, tredici prove interne più una corsa reale sul template con i plugin del vault di riferimento, ma l'apertura del vault dentro Obsidian non è stata osservata da chi ha scritto il pacchetto, che non vede l'interfaccia. La prima apertura da parte del proprietario è la verifica che manca. Obsidian scrive nella cartella del vault anche il proprio stato di lavoro, che resta lì e non entra nel repository. I collegamenti fra documenti scritti come percorsi relativi al progetto, per esempio da `docs/` verso `.claude/memory/`, dentro il vault non si risolvono, perché la cartella si chiama `memoria`: il grafo mostra i rimandi interni a ciascuna delle tre cartelle e non quelli che le attraversano.

## Rimozione

`python tools/vault-progetto.py togli`, poi si cancella la riga di `_vault/` dal `.gitignore`. Nessun file del progetto viene toccato.
