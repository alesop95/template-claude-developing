# Filone: prima installazione di un PC Windows

> Aperto il 2026-11-25 dal mandato del proprietario, che chiede che la preparazione di un PC Windows vergine sia ripetibile e sfrutti al massimo Win11Debloat, e che i dischi esterni dei backup ritrovino da soli la loro lettera. Settore di destinazione: «Macchine e continuità operativa». Stato: implementazione di riferimento in un progetto istanziato, nessun pacchetto del template, niente provato su una macchina vergine.

## La domanda a cui risponde

Una macchina Windows nuova va portata allo stesso stato delle altre: app preinstallate tolte, funzioni AI spente, interfaccia sistemata, software di base installato, dischi esterni con la lettera che gli script si aspettano. Farlo a mano produce macchine tutte un po' diverse e nessuna traccia di che cosa è cambiato. Lanciare gli strumenti di pulizia così come sono pubblicati risolve la prima metà e lascia aperta la seconda: codice remoto eseguito al volo, nessuna versione fissata, nessuna fotografia prima e dopo.

## Lo strumento centrale: Win11Debloat

La fonte è github:Raphire/Win11Debloat, di Raphire, licenza MIT. È uno script PowerShell che toglie le app preinstallate, spegne telemetria, contenuti suggeriti e funzioni AI, e sistema barra delle applicazioni, menu Start ed Esplora file. L'autore dichiara reversibili tutte le modifiche e documenta come tornare indietro; quasi tutte le app si reinstallano dallo Store. Pubblica rilasci con tag datati: al 2026-11-25 l'ultimo è `2026.10.30`, con 117 parametri, letti dal blocco `param` del file d'ingresso con il parser di PowerShell e non dalla documentazione. Quel rilascio aggiunge `-DisableChromeAI`, `-DisableDriverUpdates` e `-Language`, e toglie `-DisableSearchHistory`, `-DisableSearchHighlights` e `-DisableDragTray`: un profilo scritto per il rilascio precedente va ricontrollato, ed è il motivo per cui la versione si fissa.

Lo si sfrutta al massimo in tre modi, nessuno dei quali chiede di modificarne il codice. Si usa da riga di comando con `-Silent` e un elenco di parametri scritto una volta in un profilo, così che la decima macchina esca uguale alla prima. Si fissa al tag di rilascio con il commit e l'impronta SHA-256 del file d'ingresso, e si aggiorna come atto deliberato, rileggendo i parametri. Si accompagna con un secondo strumento per la parte AI che Win11Debloat non copre per intero, zoicware/RemoveWindowsAI, che però è reversibile solo in parte e va eseguito prima, su un sistema intatto.

Alcuni parametri toccano Windows Update, telemetria, Defender, Edge e cifratura automatica BitLocker: `-DisableTelemetry`, `-DisableUpdateASAP`, `-DisableDeliveryOptimization`, `-DisableBitlockerAutoEncryption`, `-DisableDriverUpdates`, `-DisableEdgeAds`, `-ForceRemoveEdge`. Su una macchina personale sono scelte libere; su una registrata a un tenant o gestita via MDM si escludono, ed è la ragione per cui un profilo d'esempio deve nominarle invece di ometterle in silenzio.

## L'implementazione di riferimento

Vive nel progetto istanziato `windows-status`, che è pubblico e anonimo. Lo script `scripts/Prima-Installazione.ps1` è una catena di custodia attorno ai due strumenti: li scarica al commit fissato nel manifesto `scripts/prima-installazione/strumenti.json` e verifica l'impronta prima di eseguirli, fa una fotografia della macchina prima e una dopo e le confronta, crea un punto di ripristino, chiede conferma digitando SI a ogni passo che modifica, si ferma su una macchina aziendale finché non riceve un parametro esplicito, e a fine corsa stampa la riga da incollare nel changelog. Le scelte stanno in `profilo.json`, ignorato da git, con `profilo.esempio.json` versionato accanto. Il documento d'uso è il sedicesimo della sua cartella dei documenti.

Il passo `SUPPORTI`, aggiunto il 2026-11-25, risponde alla seconda metà del mandato. Gli script di backup cercano il loro disco per lettera prima che per modello e numero di serie, e su un PC nuovo Windows gli assegnerebbe la prima lettera libera. Il passo legge dal profilo un elenco di dischi con modello, numero di serie facoltativo e lettera, e assegna la lettera una volta; Windows la ricorda per quel volume e la riassegna a ogni collegamento successivo. Il numero di serie è un identificativo reale e sta solo nel profilo locale.

Lo stesso giorno è stato aggiunto `scripts/Espelli-Supporto.ps1`, che dice chi impedisce la rimozione sicura di un disco USB e la richiede con la stessa chiamata di sistema, che restituisce il motivo del rifiuto. Nasce da un backup fermato su un volume exFAT da riparare dopo uno stacco forzato, e da un rifiuto la cui causa era un job di backup della macchina che includeva il disco esterno. Il racconto con gli eventi da leggere sta nel diciottesimo documento del progetto, paragrafo 12.

## Che cosa è verificato e che cosa no

Verificato il 2026-11-25: l'impronta del file d'ingresso di Win11Debloat al tag `2026.08.24` coincide con quella del manifesto, quindi il metodo di calcolo è quello giusto, e quella al tag `2026.10.30` è stata calcolata con lo stesso metodo; tutte le opzioni del profilo d'esempio esistono nel rilascio nuovo; il passo `SUPPORTI` riconosce in anteprima un disco già sulla sua lettera; lo strumento di espulsione risale dalla lettera al dispositivo USB e legge gli eventi di rifiuto su questa macchina.

Non verificato: la catena intera su una macchina vergine con il rilascio nuovo, l'assegnazione effettiva di una lettera su un PC nuovo, l'espulsione con chiusura delle anteprime. La prova naturale è una macchina virtuale Windows 11 appena installata, con un disco virtuale al posto di quello USB.

## Criterio di chiusura

Il filone diventa una voce di catalogo quando la catena è stata eseguita almeno una volta su una macchina vergine con il rilascio fissato, e quando la parte generica, cioè il manifesto con l'impronta, il profilo e il passo `SUPPORTI`, si separa dalle parti di `windows-status` legate a quella macchina. Il trigger da mettere nella colonna «quando offrirlo» è un progetto che prepara o ripristina postazioni Windows. Fino ad allora resta un rimando all'implementazione di riferimento, e il template non propone niente.
