# Filone: stack full-stack collaudati come benchmark tecnico

> Aperto il 2026-10-16 su richiesta del proprietario. L'idea: i progetti che il template ha già allineato e che funzionano sono un corpus di soluzioni provate, e da essi si astraggono le scelte di stack e di gestione del version control che il template può proporre a un progetto nuovo, con alle spalle un benchmark tecnico reale invece di una preferenza. Stato: idea registrata, studio da impostare, nessuna lezione ancora estratta. Indice dei filoni in `docs/FILONI.md`.

## Il mandato

Il proprietario sviluppa stack reali e li fa funzionare, per esempio Neon con l'adattatore di base dati in `civitanext`, e vuole che il template impari da ciò che è già collaudato. La regola che governa il filone è netta: un progetto diventa benchmark tecnico solo se una cosa è collaudata e funziona per risolvere un problema simile. Non basta che un progetto usi una tecnologia; deve averla fatta funzionare per un problema che un progetto nuovo riconoscerebbe come il proprio. Da quei progetti si astraggono due cose distinte: la soluzione di stack, cioè quali componenti open source e tecnologicamente adatti risolvono un certo scopo, e la gestione del version control di quello stack, cioè come si tengono separati ambienti, segreti, migrazioni e rilasci.

## Dove sta il corpus, e come lo si guarda

Il corpus sono i progetti che `.claude/templates/tools/allinea-tutti.ps1` già raggiunge: il template ne conosce l'elenco perché li allinea, quindi lo studio parte da lì e non da una ricerca a mano. Lo studio è una passata di sola lettura su quei progetti che, per ciascuno, legge lo stack dichiarato nelle schede di contesto, in particolare `STACK.md` e `deployment.md`, e la forma del version control, cioè la separazione fra test e produzione, la gestione dei segreti e il flusso di rilascio. È lavoro meccanico e verificabile, quindi si delega a un subagent per progetto o a un lotto, secondo `token-economy.md`, e il suo esito è uno stato su disco e non una risposta in chat.

Il filtro del benchmark si applica dopo la raccolta, non durante: si raccoglie che cosa ogni progetto usa, poi si tiene solo ciò che è collaudato, dove il collaudo si legge dallo stato del progetto e non si assume. Un progetto che dichiara uno stack ma lo ha lasciato a metà non è un benchmark; lo diventa quando la sua scheda e la sua storia dicono che quello stack regge in produzione. Questo è il punto in cui il filone si lega alla regola sull'onestà del contenuto: collaudato è un'affermazione verificabile, e si verifica sul progetto prima di promuoverlo a benchmark del template.

## Che cosa produce

Due uscite. La prima è un arricchimento del pacchetto `stack-profiles`, che già descrive stack ricorrenti: ogni profilo guadagna un benchmark, cioè il progetto reale in cui quello stack è stato fatto funzionare, con la forma del suo version control. Quando il gate propone un profilo a un progetto nuovo, non propone più una preferenza ma una soluzione con una prova alle spalle. La seconda è una raccolta di lezioni di gestione del version control per stack, per esempio come si gestiscono le migrazioni di una base di dati serverless come Neon fra ambiente di test e produzione, che vive accanto alla skill `separazione-ambienti` e la rende concreta su tecnologie precise invece che in astratto.

Il primo caso da studiare, indicato dal proprietario, è Neon con l'adattatore di base dati in `civitanext`, quando sarà collaudato. Finché non lo è, resta un candidato e non un benchmark, ed è la prova che la regola del filone funziona: si aspetta il collaudo prima di astrarre.

## Perché è un filone e non subito un pacchetto

Manca ancora lo studio che estrae le lezioni, e manca la prova che i progetti allineati abbiano stack abbastanza simili fra loro da produrre profili riusabili invece di un elenco di casi unici. Il filone si chiude, diventando un arricchimento di `stack-profiles` e una raccolta di lezioni, quando una prima passata sui progetti allineati avrà prodotto almeno due profili con un benchmark reale e collaudato ciascuno. Prima di allora è un'idea registrata, non una capacità del template.
