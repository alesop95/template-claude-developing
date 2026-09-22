# Prove che misurano davvero qualcosa

> Regola modulare. Non riguarda come si scrive un test in un linguaggio o con un framework, che cambia da progetto a progetto, ma come si stabilisce che un test stia misurando il difetto che dice di misurare. Si applica ogni volta che si scrive o si valuta una prova automatica. Le quattro sezioni vengono tutte da difetti sopravvissuti a prove verdi in progetti istanziati da questo template, non da considerazioni generali.

## Il problema

Una prova verde può significare due cose diverse e indistinguibili dall'esterno: che il comportamento è corretto, oppure che la prova non esercita il comportamento. Il secondo caso è peggiore dell'assenza di prove, perché produce una copertura dichiarata che nessuno mette in dubbio, e perché la riga verde nel rapporto è esattamente ciò che impedisce di guardare.

Nessuna delle quattro pratiche seguenti riguarda quante prove ci sono. Riguardano tutte la stessa domanda, posta prima di considerare chiusa una correzione: se il difetto tornasse, questa prova cadrebbe?

## Verifica di non vacuità: si reintroduce il difetto e si guarda che cosa cade

La pratica centrale, e l'unica che risponde a quella domanda con una prova invece che con un'opinione. Scritta la correzione e la sua prova, si *rimette il difetto* nel codice, si esegue la suite, e si osserva quali prove cadono. Poi si ripristina il file e si verifica il ripristino con uno strumento, non a memoria.

Due esiti sono interessanti e nessuno dei due è quello atteso. Se *non cade niente*, la prova non misura il difetto: è vacua, e va riscritta prima di andare avanti. Se cade più di quanto previsto, o cadono prove che con quel difetto non c'entrano, allora quelle prove dipendevano dal comportamento corretto per ragioni accidentali, e il legame va reso esplicito o rimosso. In un caso reale una prova cadeva perché si appoggiava a un comportamento che non stava verificando: è stata riscritta, e il difetto che questo ha reso visibile non era nel codice ma nella prova.

Il costo è di minuti e va pagato ogni volta che si chiude un difetto, non solo quando si è in dubbio. Il dubbio non è un segnale affidabile: le prove vacue si scrivono proprio quando si è sicuri.

## Una prova che sceglie gli argomenti può scegliere quelli che il difetto non produce

Caso osservato: una funzione riceveva un insieme di celle occupate e un ordinale, e restituiva una cella libera. Le prove la chiamavano due volte con ordinali diversi e confrontavano i risultati. Una si chiamava perfino "due elementi nuovi finiscono in due celle diverse". Era verde, leggibile, e sembrava esattamente la prova giusta.

Il difetto è sopravvissuto perché in esercizio quell'ordinale non lo sceglieva nessuno: lo calcolava un elenco che cambiava composizione da solo, e due chiamate reali potevano riceverne uno uguale, o uno diverso da quello del passaggio precedente. Chiamando con `0` e poi con `1`, la prova aveva costruito il caso facile senza accorgersene.

La regola che ne discende. Quando una proprietà riguarda un insieme, l'unità da provare è l'insieme, non l'elemento. La domanda che il chiamante pone davvero non era "dove va questo elemento" ma "dove vanno tutti", e finché la funzione rispondeva alla prima domanda nessuna prova poteva esprimere la seconda. La correzione ha cambiato la firma prima delle prove, da "un risultato dato un indice" a "una mappa da identificativo a risultato", e la prova è diventata una sola chiamata seguita da "non ci sono due risultati uguali". Quella forma non ha argomenti da scegliere, quindi non può sceglierli gentili.

Il corollario, che vale come criterio di scrittura: se una prova deve *inventare* un valore che in esercizio viene calcolato da qualcun altro, quel valore è un'ipotesi non verificata dentro la prova. O lo si fa calcolare alla funzione stessa, allargando l'unità, oppure si prova anche chi lo calcola.

## Il calcolo giusto che non arriva a destinazione

Caso osservato, e il più istruttivo perché la funzione pura era *già corretta* e tutte le sue prove passavano. Il risultato del calcolo veniva consegnato una volta sola, alla prima costruzione del componente, a un contenitore che ignorava gli aggiornamenti successivi. Ricalcolare non muoveva niente. Il difetto non stava nel calcolo ma nella relazione fra un valore ricalcolato e ciò che l'utente vede, che per definizione non esiste dentro una funzione pura.

Formulazione generale, da tenere presente prima di dichiarare chiusa una correzione: nessuna quantità di prove su funzioni pure dimostra che il risultato di quelle funzioni arrivi a destinazione. Serve una prova che monti il pezzo vero, faccia cambiare l'ingresso e osservi l'uscita osservabile. È la stessa famiglia dei difetti che vivono nella relazione temporale fra due scritture, invisibili a qualunque prova su una funzione sola.

Due trappole pratiche nello scriverla, entrambe capaci di produrre una prova che passa senza misurare niente. Molte librerie di interfaccia non scrivono nel supporto durante l'aggiornamento ma in un proprio ciclo differito: leggere subito dopo misura lo stato precedente, e l'asserzione va messa dentro un'attesa. E ciò che si osserva deve essere il *contratto pubblico* del pezzo, cioè il modo in cui il risultato diventa visibile a chi guarda, non una struttura interna: osservare l'interno produce una prova che si rompe a ogni riorganizzazione senza che nulla sia peggiorato.

## Verificare il carico non basta quando il destinatario interpreta

Verificare che cosa si è scritto, e non solo che una scrittura sia avvenuta, è già meglio di quanto molte suite facciano. Ma vale finché chi riceve è trasparente, cioè scrive ciò che gli arriva così com'è.

Caso osservato: un'interfaccia di persistenza con semantica di *fusione*, dove una chiave assente significa "non toccare quel campo" e non "cancellalo". La prova verificava che il componente consegnasse il campo con valore nullo, e passava; sul dato reale il campo restava al valore precedente, e il difetto compariva solo ricaricando. Per cancellare serviva un valore sentinella, che è un valore e non un'assenza.

La domanda da porsi prima di fermarsi al carico: fra quello che consegno e l'effetto che voglio, c'è qualcosa che interpreta? Se sì, la prova va scritta al livello dove quell'interpretazione è osservabile, non a quello che ci sta sopra.

## Quando una verifica manuale smentisce una prova verde

Succede, ed è successo due volte in due giorni nello stesso progetto. La reazione corretta non è correggere il sintomo ma capire perché la prova non l'aveva visto, e scrivere quella ragione dove la leggerà chi scriverà la prossima prova. Un difetto trovato a mano dopo una suite verde è un difetto *della suite* oltre che del codice, e ignorare la seconda metà garantisce la ripetizione.

Vale anche il verso positivo, da dire a chi esegue la verifica manuale: un risultato inatteso vale più di uno atteso, e va riportato insieme al passo che lo ha prodotto invece di essere aggiustato a mano e dimenticato.

## In una verifica manuale si marca quale passo è quello discriminante

Caso osservato su una sequenza di quattro passi, scritta apposta per riverificare una correzione che al primo tentativo non aveva chiuso il difetto. I passi erano: creare un elemento e controllare che nasca in una posizione libera, crearne un secondo e controllare che non si sovrapponga, *spostarne uno a mano*, crearne un terzo e controllare che non atterri sopra nessuno.

Solo il terzo e il quarto passo, presi insieme, esercitano il difetto, e la ragione è che lo spostamento cambia la *composizione dell'insieme* da cui il calcolo deriva la posizione: l'elemento spostato acquista una collocazione propria, esce dall'insieme di quelli senza, e fa scalare l'indice di tutti gli altri. I primi due passi percorrono il caso facile.

Che cosa è successo davvero, ed è il motivo per cui la lezione merita di essere scritta. La prima esecuzione si è fermata dopo il primo passo e la cosa è stata registrata come verifica parziale, il che ha funzionato. Ma la seconda esecuzione, in una sessione diversa, ha rifatto **di nuovo il primo passo** prima di arrivare al terzo, e senza un richiamo esplicito si sarebbe fermata di nuovo lì: dall'esterno i passi si assomigliano tutti, sono tutti "crea un elemento e guarda dove finisce", e nulla nella lista diceva quale dei quattro portasse l'informazione. *Il passo facile è stato eseguito due volte, quello discriminante ha rischiato di non esserlo mai.*

La prescrizione che ne discende è minima e costa una riga. Chi scrive una sequenza di verifica manuale dichiara, accanto al passo che conta, **perché** conta e che cosa distingue: non "crea un terzo elemento" ma "crea un terzo elemento, ed è questo che la correzione precedente sbagliava, perché lo spostamento del passo prima ha cambiato l'insieme". Chi esegue, allora, sa che fermarsi prima non è fermarsi a metà ma fermarsi a zero.

Il criterio per riconoscere il passo discriminante, quando la sequenza la si sta scrivendo: è quello che *modifica lo stato da cui il codice deriva il risultato*, non quello che ripete l'operazione osservata. Un passo che ripete l'operazione precedente con un nome diverso aggiunge fiducia e non aggiunge informazione, ed è utile dirlo, perché a quel punto chi esegue può anche saltarlo consapevolmente invece di saltare l'altro per stanchezza.

## Una finzione scritta guardando il codice descrive il codice, non la dipendenza

Quarta forma di prova che passa senza misurare, osservata su un progetto istanziato e distinta dalle tre precedenti perché non riguarda l'asserzione ma ciò che la circonda.

Una prova unitaria sostituisce le dipendenze con oggetti scritti a mano. È una pratica corretta, e dimostra esattamente questo: **il mio codice si comporta come mi aspetto, dato che questa dipendenza si comporta come l'ho immaginata.** La seconda metà di quella frase è il limite, e di solito non si legge.

Nel caso osservato, tre file di codice pubblicato usavano una proprietà che nel sistema reale non esisteva nella forma in cui la usavano. Tutte le loro prove erano verdi, e la ragione è la più insidiosa possibile: ogni finzione dichiarava quella proprietà a mano, **proprio perché il codice ne aveva bisogno**, senza che nessuno si chiedesse se esistesse davvero. La finzione era stata costruita per far passare il codice, non per descrivere la dipendenza, e da quel momento confermava qualunque cosa il codice facesse.

Il difetto è stato trovato solo da una prova che attraversava un sistema reale, la prima volta che ne è stata scritta una.

Due conseguenze operative.

Quando si scrive una finzione, ci si chiede se la si stia costruendo **guardando la documentazione della dipendenza oppure guardando il codice che deve passare**. Il secondo caso produce una prova che conferma se stessa, e nessuna revisione la distingue dall'altra leggendola.

E la piramide che raccomanda molte prove unitarie e poche che attraversano il sistema vero non viene smentita da questo: **il valore delle poche non sta in quanto coprono, ma nel fatto che esista almeno un percorso in cui nessuno ha potuto immaginare la dipendenza.** Per quella ragione non sono facoltative, per quanto poche.
