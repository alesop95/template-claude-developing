# Filone: crediti di un fornitore di modelli inclusi in un abbonamento

> Aperto il 2026-10-28 su richiesta del proprietario, dopo che un progetto istanziato ha collegato per la prima volta la propria organizzazione di sviluppo a un abbonamento che include crediti mensili per l'API del fornitore. Raccoglie il meccanismo, le conseguenze che un progetto deve conoscere prima di usarlo e la lista di controllo che ne discende. Stato: osservazione con lista di controllo verificata su un caso solo; non è un pacchetto. Settore di destinazione: «Economia e fondamenta». Indice dei filoni in `docs/FILONI.md`.

## Il meccanismo, letto alla fonte

Alcuni abbonamenti a piattaforme di modelli linguistici includono, oltre all'uso interattivo dell'applicazione, una dotazione mensile di credito spendibile sull'API della stessa piattaforma. La dotazione non è automatica: va riscattata collegando una volta sola l'organizzazione di sviluppo all'abbonamento, e il collegamento è esclusivo nei due sensi, cioè un abbonamento alimenta una sola organizzazione e un'organizzazione riceve da un solo abbonamento. Sui piani a postazioni l'importo si calcola per postazione e confluisce in un saldo comune con un tetto massimo; gli importi per tipo di piano stanno nella fonte, cambiano nel tempo e non si copiano qui.

Le proprietà che contano per chi progetta, verificate sulla documentazione del fornitore il 2026-10-27 e sul caso reale del giorno successivo: il credito incluso si consuma prima di qualunque credito acquistato; scade alla fine di ogni ciclo di fatturazione e non si riporta al ciclo successivo; è condiviso da tutte le chiavi e tutti gli spazi di lavoro dell'organizzazione collegata; non copre l'assistente interattivo da terminale, che resta sui limiti dell'abbonamento; e alza automaticamente la fascia di frequenza dell'organizzazione. Il tetto di spesa dell'organizzazione si azzera sul mese solare, mentre il credito si rinnova sul ciclo di fatturazione, che quasi mai comincia il primo del mese.

## Sei conseguenze che un progetto deve conoscere

**La dotazione è una provvista, non uno sconto.** Il registro dei costi di un progetto continua a prezzare ogni chiamata a listino, e un job coperto dalla dotazione non si scrive a costo zero. La ragione non è contabile ma decisionale: il numero che serve è il costo mensile a regime, cioè quello che il progetto pagherebbe quando la dotazione finisce o cambia, ed è proprio il numero da cui dipende la scelta di tenere o spegnere il fornitore esterno. Un registro che segna zero rende quel numero irrecuperabile, e lo rende irrecuperabile in silenzio, perché il totale continua a sembrare corretto.

**Un saldo unico non si divide con le chiavi.** Dare una chiave per ambiente, o una per persona, separa la *contabilità* e non i *fondi*: tutte le chiavi dell'organizzazione attingono allo stesso saldo, quindi una corsa di prova fuori controllo consuma la dotazione del lavoro serio. La separazione reale si ottiene solo con uno spazio di lavoro per ambiente o per persona, ciascuno con il proprio tetto di spesa. È una distinzione che si scopre tardi, perché un progetto che prima comprava il credito per ambiente aveva già la separazione senza doverla chiedere.

**Il blocco deve arrivare dal proprio codice.** Il tetto dello spazio di lavoro è l'unico punto in cui il fornitore ferma davvero la spesa, ma ferma con un errore di credito esaurito, che a valle somiglia a un guasto. Una guardia applicativa impostata sotto quel tetto, come la variabile di budget mensile che alcuni progetti già hanno, fa arrivare lo stop dal proprio codice con un messaggio leggibile e una riga di registro, prima che il fornitore risponda con un errore che nessuno sa interpretare alle tre di notte.

**La provvista non cambia il perimetro.** Chi paga e che cosa è lecito mandare sono due questioni separate, e una dotazione gratuita non sposta di un millimetro le regole di autorizzazione, l'esclusione del materiale riservato o i vincoli contrattuali con il fornitore. Va scritto esplicitamente nella decisione che registra la dotazione, perché è l'inferenza sbagliata più naturale: il credito arriva, sembra un invito a usarlo, e la condizione che lo governava sta in un documento diverso.

**Due calendari che non coincidono.** Il credito si rinnova sul ciclo di fatturazione dell'abbonamento, il tetto di spesa dell'organizzazione sul mese solare. Una lavorazione pesante a cavallo dei due può trovare credito disponibile e tetto quasi esaurito, o il contrario. Quando si pianifica un giro di misura su più giorni si guarda il vincolo più vicino dei due, e lo si scrive accanto al piano.

**La scadenza è un incentivo, non un rischio.** Il credito non consumato muore ogni ciclo. Ne discende una pianificazione diversa da quella di un budget acquistato: le corse di misura e gli esperimenti si collocano dentro il ciclo in cui la dotazione esiste, perché rimandarli non li fa costare meno, li fa costare la dotazione intera del ciclo che passa. È il raro caso in cui spendere presto è la scelta prudente.

## Lista di controllo per un progetto che adotta la dotazione

1. Registrare la dotazione come decisione architetturale, non come nota: quello che va fissato è il rapporto fra provvista e registro dei costi, che una nota non dichiara.
2. Lasciare il registro dei costi a listino, e verificare che nessun percorso scriva zero per i job coperti dalla dotazione.
3. Creare uno spazio di lavoro per ambiente con il proprio tetto, prima di creare la prima chiave.
4. Impostare la guardia applicativa di budget sotto il tetto dello spazio di lavoro, non sopra e non uguale.
5. Aggiungere al registro delle affermazioni che invecchiano una voce che chieda periodicamente se il collegamento è attivo e se la dotazione del ciclo è arrivata: una dotazione che smette di arrivare non produce nessun errore finché il saldo non finisce.
6. Tenere importi, date e saldi nel livello privato del progetto, perché sono dati economici e la regola di anonimizzazione li esclude dai file tracciati; nei file tracciati resta il fatto operativo.

## Che cosa è verificato e che cosa no

Verificato: il meccanismo come lo descrive la documentazione del fornitore, letta il 2026-10-27; un collegamento reale eseguito il 2026-10-28, con accredito immediato della dotazione del primo ciclo e passaggio automatico alla fascia di frequenza superiore; l'assenza di qualunque addebito e di qualunque richiesta di metodo di pagamento sul lato API.

Non verificato: il comportamento su più cicli, cioè che la dotazione arrivi davvero ogni mese senza intervento; il comportamento al raggiungimento del tetto del saldo comune; ciò che accade al credito residuo in caso di cambio o disdetta del piano, che la fonte descrive ma che non è stato osservato; e l'effetto della condivisione del saldo fra spazi di lavoro quando più di uno consuma davvero, che oggi è un ragionamento sulla documentazione e non una misura.

## Perché resta un filone e non diventa una riga di catalogo

Delle quattro domande che una voce di catalogo deve saper chiudere, questa linea ne chiude due. Si sa che cosa fa, letto alla fonte primaria, e si sa a quale progetto serve, cioè a un progetto che chiama un fornitore di modelli a consumo e la cui organizzazione è pagata da un abbonamento che include una dotazione. Non si sa ancora che cosa costa in termini di lavoro ricorrente, perché la lista di controllo è stata applicata una volta sola e su un progetto solo, e non si sa come si toglie, cioè che cosa comporta scollegare un'organizzazione, visto che il fornitore dichiara che l'operazione non è autonoma e richiede l'assistenza.

Si riapre quando un secondo progetto istanziato adotta la stessa dotazione, perché è il momento in cui la lista di controllo smette di essere la descrizione di un caso e diventa una procedura. Diventa una riga di catalogo nel settore «Economia e fondamenta» quando la lista è stata applicata due volte e il costo ricorrente è noto; resta un'osservazione se nel frattempo il fornitore cambia il meccanismo, cosa che una dotazione promozionale rende possibile da un ciclo all'altro.

## Fonti

- web:https://platform.claude.com/docs/en/about-claude/api-credits-for-subscribers — documentazione del fornitore sui crediti inclusi nei piani ad abbonamento; letta il 2026-10-27.
- web:https://www.anthropic.com/legal/credit-terms — termini supplementari sui crediti: natura promozionale, scadenza, non trasferibilità, assenza di valore monetario; letti il 2026-10-27.
