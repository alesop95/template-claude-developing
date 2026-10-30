# Ponte Codex nei progetti già istanziati

Correzione del29/10/2026, lezione L-008 dal progetto home-lab. Il progetto aveva wrapper allineati e controllo verde, ma non aveva AGENTS.md alla radice. Quindi non era garantito che Codex ricevesse all’avvio il rinvio alle istruzioni canoniche CLAUDE.md. Un controllo del solo adattatore non copriva l’intera catena.

## Comportamento corretto

sync-codex-skills.py controlla anche il ponte nei progetti con .claude/PROJECT-SYSTEM.md sulla destinazione standard. Con --check un ponte mancante produce esito1 senza scrivere; senza --check viene copiato byte per byte dal modello .claude/templates/AGENTS.md. Modello assente o destinazione non valida producono errore. Un AGENTS personalizzato esistente resta intatto nel generatore; la destinazione alternativa di test non adotta il ponte nella radice.

allinea-dal-template.py include il ponte nel rapporto ordinario dei progetti già predisposti per Codex, riconosciuti da .agents/skills oppure AGENTS.md. Usa storia, confronto e merge già previsti per gli altri file. Un progetto solo Claude non viene convertito per effetto della passata. allinea-tutti.ps1 riconosce entrambi i segnali e ammette AGENTS.md nel perimetro della radice. chiudi-allineamento ricava i file dal rapporto, quindi include il ponte senza un percorso di commit separato.

Le skill restano canoniche sotto .claude/skills; i wrapper non duplicano il corpo. La policy allow_implicit_invocation:false delle procedure esplicite resta attiva. La parità riguarda istruzioni, memoria, controlli e autorizzazioni: non promette che un nome slash di Claude sia un comando nativo identico di ogni client Codex.

## Verifiche e limite della consegna

Otto prove funzionali in tests/test_codex_bridge.py coprono check senza ponte e senza scritture, creazione canonica, personalizzazione byte per byte, destinazione alternativa, modello assente, passata con NUOVO poi UGUALE, progetto solo Claude e contenuto personalizzato nell’allineamento. Le fixture git sono temporanee e non committano nei progetti reali.

Prova di non vacuità su copie isolate: togliendo il controllo del ponte nel generatore falliscono3 prove su8; togliendo la gestione nella passata ne falliscono2 su8. Baseline8/8 positiva e impronte dei sorgenti reali invariate. La suite storica dell’allineatore e l’autotest PowerShell vanno riportati nel checkpoint di consegna con il loro esito reale.

La distribuzione si completa solo dopo il commit manuale nel template, seguito da allinea-tutti.ps1 -Applica e chiudi-allineamento.ps1 -Applica. Il rapporto decide quali progetti sono applicati o in conflitto. Non aggiornare un marcatore per dichiarare già distribuita una modifica locale non committata, e non cancellare un ponte per forzare una personalizzazione a diventare canonica.

## Estensione del30/10: descrizione generata e controlli di stile

Il wrapper della skill ISO27001 copiava nella descrizione un trattino em inglese e il controllo di chiusura lo rifiutava. Il generatore normalizza ora soltanto i trattini en/em della descrizione generata, conservando intatta la skill canonica di terzi. Una nona regressione verifica output compatibile e sorgente invariato; non si aggiunge un’esclusione generale al linter e non si corregge a mano un wrapper destinato a essere rigenerato.

La ripresa conserva anche la distinzione fra test impedito dalla sandbox e test funzionalmente fallito. Il riferimento prove-che-misurano descrive il caso delle fixture temporanee; la documentazione agenti-terminale chiarisce pulizia automatica per account, anteprima globale e protezione di tutte le sessioni vive. Corretto il commento di Installa-Comandi che negava in assoluto l’esistenza di SessionEnd in Codex: il limite è la copertura e il momento dell’evento.
